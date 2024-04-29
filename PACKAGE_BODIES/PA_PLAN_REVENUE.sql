--------------------------------------------------------
--  DDL for Package Body PA_PLAN_REVENUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLAN_REVENUE" AS
-- $Header: PAXPLRTB.pls 120.11.12010000.3 2009/12/21 22:23:27 skkoppul ship $
 l_no_cost                       EXCEPTION;
 l_no_revenue                    EXCEPTION;
 l_no_bill_rate                  EXCEPTION;
 l_insufficeient_param	         EXCEPTION;
 l_more_than_one_row_excep       EXCEPTION;
 l_no_Override_rate_cost         EXCEPTION;
 l_cost_api                      EXCEPTION;
 l_bill_api                      EXCEPTION;
 l_rate_based_no_quantity        EXCEPTION;
 l_invalid_currency              EXCEPTION;
 l_invalid_currency_cost         EXCEPTION;
 l_invalid_currency_bill         EXCEPTION;
 l_Get_planning_Rates_api        EXCEPTION;
 l_Get_plan_actual_Rates         EXCEPTION; /* Added to handel when others in Get_plan_actual_Rates proc. */

 g_success CONSTANT  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
 g_error   CONSTANT  VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
 g1_debug_mode       varchar2(1)   := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
 g_module_name       VARCHAR2(100) := 'pa.plsql.PA_PLAN_REVENUE';
 g_expenditure_type_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
 g_uom_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
 g_count_init NUMBER:=0;



 /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
 /* PRIVATE PROCEDURE : Get_Res_Class_Hierarchy_Rate to get the rates based on the Resource Hierarcy*/
 /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE Get_Res_Class_Hierarchy_Rate(
                        p_res_class_rate_sch_id  IN  NUMBER,
		        p_item_date         	 IN  DATE ,
                        p_org_id                 IN  NUMBER,
		        p_resource_class_code    IN  VARCHAR2,
	                p_res_class_org_id       IN  NUMBER, /*p_project_organz_id revenue and nvl (p_override_to_organz_id ,p_incurred_by_organz_id for Costing */
		        x_rate 		         OUT NOCOPY NUMBER,
		        x_markup_percentage 	 OUT NOCOPY NUMBER,
		        x_uom  		         OUT NOCOPY VARCHAR2,
                        x_rate_currency_code	 OUT NOCOPY VARCHAR2,
		        x_return_status	         OUT NOCOPY VARCHAR2,
		        x_msg_count 		 OUT NOCOPY NUMBER,
		        x_msg_data 		 OUT NOCOPY VARCHAR2) AS
Cursor c_rule is
SELECT b.rate,b.markup_percentage,b.bill_rate_unit,b.rate_currency_code
FROM   pa_std_bill_rate_schedules_all sch,pa_bill_rates_all b
WHERE  sch.bill_rate_sch_id  = p_res_class_rate_sch_id
AND    b.bill_rate_sch_id = sch.bill_rate_sch_id
AND    sch.schedule_type = 'RESOURCE_CLASS'
AND    trunc(p_item_date)     BETWEEN trunc(b.start_date_active)        AND trunc(NVL(b.end_date_active ,p_item_date))
AND    b.res_class_organization_id = p_res_class_org_id
AND    b.resource_class_code  = p_resource_class_code;

/* Below cursor will get the rate and markup for the schedule if no rate exists for
   the Organization and resource Class  in the above cursor*/

cursor c_parent_rule (p_proj_org_version_id IN NUMBER) is
SELECT b.rate,b.markup_percentage,b.bill_rate_unit,b.rate_currency_code
From   pa_std_bill_rate_schedules_all sch,pa_bill_rates_all  b,
       (	select   organization_id_parent PARENT_ORGANIZATION_ID,level parent_level
			from     per_org_structure_elements
			where    org_structure_version_id = p_proj_org_version_id
			connect by prior  organization_id_parent=organization_id_child
			and prior   org_structure_version_id = org_structure_version_id
			start with  organization_id_child=p_res_class_org_id
			and         org_structure_version_id=p_proj_org_version_id) org
Where  sch.bill_rate_sch_id  = p_res_class_rate_sch_id
AND    b.bill_rate_sch_id = sch.bill_rate_sch_id
AND    sch.schedule_type = 'RESOURCE_CLASS'
AND    trunc(p_item_date)  BETWEEN trunc(b.start_date_active)     AND trunc(NVL(b.end_date_active, p_item_date))
AND    b.res_class_organization_id = org.PARENT_ORGANIZATION_ID
AND    b.resource_class_code  = p_resource_class_code
order by org.parent_level ;

l_rate 			   NUMBER:=NULL;
l_markup_percentage 	   NUMBER:=NULL;
l_rate_currency_code 	   VARCHAR2(30) :=NULL;
l_uom 			   VARCHAR2(30):=NULL;
l_true  		   BOOLEAN:= FALSE;
l_x_return_status 	   VARCHAR2(20):= g_success;
l_insufficient_param 	   EXCEPTION;
l_no_rate		   EXCEPTION;
l_PROJ_ORG_STRUCT_VERSION_ID pa_implementations_all.PROJ_ORG_STRUCTURE_VERSION_ID%TYPE;

BEGIN
   /*Checking all the mandatory Parameters */

             IF g1_debug_mode = 'Y' THEN
          		pa_debug.g_err_stage := 'p_res_class_rate_sch_id:'||p_res_class_rate_sch_id||'p_res_class_org_id :'||p_res_class_org_id||'p_org_id:'||p_org_id ;
                       pa_debug.write('PA_PLAN_REVENUE.Get_Res_Class_Hierarchy_Rate: ' || g_module_name,pa_debug.g_err_stage,3);
             END IF;
             IF g1_debug_mode = 'Y' THEN
          		pa_debug.g_err_stage := 'p_resource_class_code:'||p_resource_class_code||'p_item_date  :'||p_item_date  ;
                       pa_debug.write('PA_PLAN_REVENUE.Get_Res_Class_Hierarchy_Rate: ' || g_module_name,pa_debug.g_err_stage,3);
             END IF;

   IF p_res_class_rate_sch_id  IS NULL OR p_item_date IS NULL
   OR p_resource_class_code  IS NULL  THEN
      raise l_insufficient_param;
   END IF;
   open c_rule ;
   fetch c_rule
   into l_rate,l_markup_percentage,l_uom,l_rate_currency_code;
   begin
     select i. PROJ_ORG_STRUCTURE_VERSION_ID
     into l_PROJ_ORG_STRUCT_VERSION_ID
     from  pa_implementations_all i
     where   NVL(i.org_id,-99) = NVL(p_org_id,-99);
   exception
   when no_data_found then
       null;
   end;
   /* If Not found for the direct resourceOrganization Id go for Climbing the Hierarchy */
   IF c_rule%NOTFOUND THEN
      FOR r_parent_rule IN c_parent_rule(l_PROJ_ORG_STRUCT_VERSION_ID) LOOP
          -- Checking if the cursor is returning more than one row then exit getting the first row only
	      IF (l_true) THEN
		      EXIT;
	      ELSE
      	         l_rate:=r_parent_rule.rate;
		 l_markup_percentage := r_parent_rule.markup_percentage;
		 l_uom := r_parent_rule.bill_rate_unit;
                 l_rate_currency_code := r_parent_rule.rate_currency_code;
		 l_true := TRUE;
	      END IF;
	END LOOP;

    END IF;
 close c_rule;
   IF l_rate IS NULL AND l_markup_percentage  IS NULL THEN
      RAISE l_no_rate;
   END IF;
    x_rate	 	   :=l_rate;
    x_markup_percentage    :=l_markup_percentage ;
    x_uom		   :=l_uom;
    x_rate_currency_code   :=l_rate_currency_code;
    x_return_status	   :=l_x_return_status;

EXCEPTION
	WHEN l_insufficient_param THEN
	   x_rate               :=NULL;
	   x_markup_percentage  :=NULL;
	   x_uom		:=NULL;
	   x_rate_currency_code :=NULL;
	   x_return_status 	 := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     	 := 1;
           x_msg_data      	 := 'PA_FCST_INSUFFICIENT_PARA';
	WHEN l_no_rate THEN
	    x_rate	 	 :=NULL;
	    x_markup_percentage  :=NULL;
	    x_uom		 :=NULL;
	    x_rate_currency_code :=NULL;
            x_return_status := g_error;
            x_msg_count     := 1;
            x_msg_data      := 'PA_RES_NO_BILL_MARKUP';

      WHEN OTHERS THEN
           if c_rule%isopen then
              close c_rule;
           end if;
   	 x_rate	 		     :=NULL;
	 x_markup_percentage  :=NULL;
	 x_uom				 :=NULL;
	 x_rate_currency_code :=NULL;
   	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SUBSTR(SQLERRM,1,250);
         RAISE;
END Get_Res_Class_Hierarchy_Rate;



PROCEDURE Get_exp_type_uom AS

cursor temp is
select expenditure_type,unit_of_measure
from pa_expenditure_types;

BEGIN
OPEN temp;
FETCH temp BULK COLLECT INTO g_expenditure_type_tbl,g_uom_tbl;
CLOSE temp;


 g_count_init:= g_count_init+1;

   IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Before count of g_count_init'|| g_count_init||'g_expenditure_type_tbl.COUNT'||g_expenditure_type_tbl.COUNT;
       pa_debug.write('Get_exp_type_uom: ' || g_module_name,pa_debug.g_err_stage,2);
     END IF;
END;

-- This procedure will calculate the raw revenue and bill amount from one of the 12 criterias on the basis



PROCEDURE Get_planning_Rates (
	p_project_id                   	 IN     NUMBER,
	p_task_id                        IN     NUMBER      DEFAULT NULL,
        p_top_task_id                    IN     NUMBER      DEFAULT NULL, /* for costing top task Id */
	p_person_id                    	 IN     NUMBER,
	p_job_id                         IN     NUMBER,			  /* for costing p_proj_cost_job_id */
	p_bill_job_grp_id             	 IN     NUMBER      DEFAULT NULL,
	p_resource_class		 IN     VARCHAR2,                 /* resource_class_code for Resource Class */
	p_planning_resource_format       IN     VARCHAR2,                /* resource format required for Costing */
	p_use_planning_rates_flag    	 IN     VARCHAR2    DEFAULT 'N',  /* Rate using Actual Rates */
	p_rate_based_flag		 IN     VARCHAR2    DEFAULT 'Y',  /* to identify a rate based transaction */
	p_uom			    	 IN     VARCHAR2,		  /* Planning UOM */
	p_system_linkage		 IN     VARCHAR2,
	p_project_organz_id            	 IN     NUMBER	    DEFAULT NULL, /* For revenue calc use in Resource Class Sch carrying out Org Id */
	p_rev_res_class_rate_sch_id  	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Resource Class*/
	p_cost_res_class_rate_sch_id  	 IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on Resource Class*/
	p_rev_task_nl_rate_sch_id        IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Non Labor*/
   	p_rev_proj_nl_rate_sch_id        IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Non Labor*/
      --p_cost_nl_rate_sch_id            IN     NUMBER	    DEFAULT NULL,
        p_rev_job_rate_sch_id         	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Job*/
	p_rev_emp_rate_sch_id         	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Emp*/
	/* added for iteration2*/
	p_plan_rev_job_rate_sch_id 	  IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on job for planning*/
	p_plan_cost_job_rate_sch_id  	  IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on job for planning*/
	p_plan_rev_emp_rate_sch_id        IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on emp for planning*/
   	p_plan_cost_emp_rate_sch_id       IN     NUMBER	    DEFAULT NULL, /* For cost Rate Calculations based on emp for planning*/
	p_plan_rev_nlr_rate_sch_id       IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on non labor for planning*/
        p_plan_cost_nlr_rate_sch_id      IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on non labor for planning*/
	p_plan_burden_cost_sch_id         IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on burdening  for planning*/
	p_calculate_mode                  IN     VARCHAR2   DEFAULT 'COST_REVENUE' ,/* useed for calculating either only Cost(COST),only Revenue(REVENUE) or both Cost and Revenue(COST_REVENUE) */
	/* end here */
	p_mcb_flag                    	 IN     VARCHAR2    DEFAULT NULL,
        p_cost_rate_multiplier           IN     NUMBER      DEFAULT NULL ,
        p_bill_rate_multiplier      	 IN     NUMBER	    DEFAULT 1,
        p_quantity                	 IN     NUMBER,                    /* required param for People/Equipment Class */
        p_item_date                	 IN     DATE,                      /* Used as p_expenditure_item_date for non labor */
   	p_cost_sch_type		 	 IN     VARCHAR2 ,		   /* Costing Schedule Type'COST' / 'REVENUE' / 'INVOICE' */
        p_labor_sch_type            	 IN     VARCHAR2,		   /* Revenue Labor Schedule Type B/I */
        p_non_labor_sch_type       	 IN     VARCHAR2 ,                 /* Revenue Non_Labor Schedule Type B/I */
        p_labor_schdl_discnt         	 IN     NUMBER	    DEFAULT NULL,
        p_labor_bill_rate_org_id   	 IN     NUMBER	    DEFAULT NULL,
        p_labor_std_bill_rate_schdl 	 IN     VARCHAR2    DEFAULT NULL,
        p_labor_schdl_fixed_date   	 IN     DATE        DEFAULT NULL,
  	p_assignment_id               	 IN     NUMBER      DEFAULT NULL,  /* used as  p_item_id  in the internal APIs */
        p_project_org_id            	 IN     NUMBER,			   /* Project Org Id */
        p_project_type              	 IN     VARCHAR2,
        p_expenditure_type          	 IN     VARCHAR2,
        p_non_labor_resource         	 IN     VARCHAR2    DEFAULT NULL,
        p_incurred_by_organz_id     	 IN     NUMBER,                    /* Incurred By Org Id */
 	p_override_to_organz_id    	 IN     NUMBER,			   /* Override Org Id */
	p_expenditure_org_id        	 IN     NUMBER,                    /* p_expenditure_OU (p_exp_organization_id in costing) */
        p_assignment_precedes_task 	 IN     VARCHAR2,		   /* Added for Asgmt overide */
        p_planning_transaction_id    	 IN     NUMBER      DEFAULT NULL,  /* changeed from p_forecast_item_id will passed to client extension */
        p_task_bill_rate_org_id      	 IN     NUMBER      DEFAULT NULL,  /* Org Id of the Bill Rate at Project Level */
        p_project_bill_rate_org_id       IN     NUMBER      DEFAULT NULL,  /* Org Id of the Bill Rate at task Level */
 	p_nlr_organization_id            IN     NUMBER      DEFAULT NULL,   /* Org Id of the Non Labor Resource */
        p_project_sch_date          	 IN     DATE        DEFAULT NULL,   /* Revenue Non_Labor Schedule Date at project Level */
	p_task_sch_date             	 IN     DATE        DEFAULT NULL,   /* Revenue Non_Labor Schedule Date at task Level */
	p_project_sch_discount      	 IN     NUMBER      DEFAULT NULL ,  /* Revenue Non_Labor Schedule Discount at project Level */
        p_task_sch_discount        	 IN     NUMBER      DEFAULT NULL ,  /* Revenue Non_Labor Schedule Discount at task Level */
        p_inventory_item_id         	 IN	NUMBER      DEFAULT NULL,   /* Passed for Inventoty Items */
        p_BOM_resource_Id          	 IN	NUMBER      DEFAULT NULL,  /* Passed for BOM Resource  Id */
        P_mfc_cost_type_id           	 IN	NUMBER      DEFAULT 0,     /* Manufacturing cost api */
        P_item_category_id           	 IN	NUMBER      DEFAULT NULL,  /* Manufacturing cost api */
        p_mfc_cost_source                IN     NUMBER      DEFAULT 1,
        p_cost_override_rate        	 IN	NUMBER      DEFAULT NULL,  /*override rate if not null no call to costing internal api.*/
        p_revenue_override_rate     	 IN	NUMBER      DEFAULT NULL,  /*override rate if not null no call to billing internal api.*/
        p_override_burden_cost_rate 	 IN	NUMBER      DEFAULT NULL,  /*override burden multiplier and p_raw_cost is not null calculate x_burden_cost */
        p_override_currency_code  	 IN	VARCHAR2    DEFAULT NULL,  /*override currency Code */
        p_txn_currency_code		 IN	VARCHAR2    DEFAULT NULL,  /* if not null, amounts to be returned in this currency only else in x_txn_curr_code*/
        p_raw_cost                       IN 	NUMBER,		          /*If p_raw_cost is only passed,return the burden multiplier, burden_cost */
        p_burden_cost                    IN 	NUMBER      DEFAULT NULL,
        p_raw_revenue                	 IN     NUMBER      DEFAULT NULL,
        p_billability_flag               IN     VARCHAR2    DEFAULT 'Y',  /* Added rate calculation honoring billability flag */
	x_bill_rate                      OUT NOCOPY	NUMBER,
        x_cost_rate                      OUT NOCOPY	NUMBER,
        x_burden_cost_rate               OUT NOCOPY	NUMBER,
        x_burden_multiplier		 OUT NOCOPY	NUMBER,
        x_raw_cost                       OUT NOCOPY	NUMBER,
        x_burden_cost                    OUT NOCOPY	NUMBER,
        x_raw_revenue                	 OUT NOCOPY	NUMBER,
        x_bill_markup_percentage       	 OUT NOCOPY     NUMBER,
        x_cost_txn_curr_code         	 OUT NOCOPY     VARCHAR2,
        x_rev_txn_curr_code         	 OUT NOCOPY     VARCHAR2,
        x_raw_cost_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_burden_cost_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_revenue_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_cost_ind_compiled_set_id	 OUT NOCOPY	NUMBER,
        x_return_status              	 OUT NOCOPY     VARCHAR2,
        x_msg_data                   	 OUT NOCOPY     VARCHAR2,
        x_msg_count                  	 OUT NOCOPY     NUMBER
	)
IS

l_x_return_status               VARCHAR2(1):=g_success;
l_txn_bill_rate		        NUMBER:=NULL;
l_txn_cost_rate			NUMBER:=NULL;
l_i_txn_bill_rate		NUMBER:=NULL;
l_i_txn_cost_rate		NUMBER:=NULL;
l_i_txn_burden_cost_rate        NUMBER :=NUll;
l_i_txn_burden_multiplier       NUMBER;
l_txn_burden_cost_rate		NUMBER:=NULL;
l_txn_burden_multiplier		NUMBER;
l_raw_cost           	        NUMBER;
l_burden_cost                   NUMBER;
l_raw_revenue                   NUMBER;
l_txn_raw_cost           	NUMBER;
l_txn_burden_cost               NUMBER;
l_txn_raw_revenue               NUMBER;
l_bill_markup		        pa_bill_rates_all.markup_percentage%TYPE:=NULL;
l_txn_bill_markup		pa_bill_rates_all.markup_percentage%TYPE:=NULL;
l_txn_cost_markup		pa_bill_rates_all.markup_percentage%TYPE:=NULL;
l_txn_curr_code       		pa_bill_rates_all.rate_currency_code%TYPE:=NULL;
l_cost_txn_curr_code       	pa_bill_rates_all.rate_currency_code%TYPE:=NULL;
l_rev_txn_curr_code       	pa_bill_rates_all.rate_currency_code%TYPE:=NULL;
l_raw_cost_rejection_code	VARCHAR2(30);
l_burden_cost_rejection_code	VARCHAR2(30);
l_revenue_rejection_code	VARCHAR2(30);
l_cost_ind_compiled_set_id	NUMBER;
l_burd_organization_id          NUMBER;
l_x_msg_data                    VARCHAR2(1000);
l_x_msg_count                   NUMBER;
l_schedule_type			VARCHAR2(30);
l_burd_sch_id                   NUMBER;
l_burd_sch_rev_id		NUMBER;
l_burd_sch_fixed_date		DATE;
l_burd_sch_cost_base		VARCHAR2(50);
l_burd_sch_cp_structure		VARCHAR2(50);
l_cost_return_status		VARCHAR2(1):=g_success;
l_cost_msg_data			VARCHAR2(1000);
l_rev_res_txn_curr_code 	pa_bill_rates_all.rate_currency_code%TYPE:=NULL;
l_cost_res_txn_curr_code	pa_bill_rates_all.rate_currency_code%TYPE:=NULL;
l_expenditure_org_id            NUMBER;
l_calculate_mode                VARCHAR2(30);


BEGIN

   -- Initializing return status with success so that if some unexpected error comes
   -- , we change its status from succes to error so that we can take necessary step to rectify the problem
   l_x_return_status := g_success;
    PA_DEBUG.init_err_stack( 'PA_PLAN_REVENUE.Get_planning_rates');
     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_project_id :'||p_project_id ||'p_task_id :'||p_task_id;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_person_id :'||p_person_id||'p_job_id :'||p_job_id;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_resource_class :'||p_resource_class ||'p_use_planning_rates_flag :'||p_use_planning_rates_flag;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_rate_based_flag:'||p_rate_based_flag||'p_uom :'||p_uom;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

      IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_rev_res_class_rate_sch_id :'||p_rev_res_class_rate_sch_id ||'p_cost_res_class_rate_sch_id :'||p_cost_res_class_rate_sch_id;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

      IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_rev_task_nl_rate_sch_id :'||p_rev_task_nl_rate_sch_id||'p_rev_proj_nl_rate_sch_id :'||p_rev_proj_nl_rate_sch_id;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

      IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_rev_job_rate_sch_id :'||p_rev_job_rate_sch_id ||'p_rev_emp_rate_sch_id :'||p_rev_emp_rate_sch_id;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

      IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_plan_rev_job_rate_sch_id :'||p_plan_rev_job_rate_sch_id||'p_plan_cost_job_rate_sch_id :'||p_plan_cost_job_rate_sch_id;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

      IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_plan_rev_nlr_rate_sch_id :'||p_plan_rev_nlr_rate_sch_id ||'p_plan_cost_nlr_rate_sch_id :'||p_plan_cost_nlr_rate_sch_id;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

      IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_plan_burden_cost_sch_id  :'||p_plan_burden_cost_sch_id ||'p_calculate_mode :'||p_calculate_mode;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_quantity :'||p_quantity ||'p_labor_sch_type :'||p_labor_sch_type;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_non_labor_sch_type  :'||p_non_labor_sch_type ||'p_expenditure_type :'||p_expenditure_type;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;


     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_cost_override_rate :'||p_cost_override_rate ||'p_raw_cost :'||p_raw_cost;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_revenue_override_rate :'||p_revenue_override_rate ||'p_override_currency_code :'||p_override_currency_code;
      pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Input parameters:-> p_burden_cost :'||p_burden_cost ||'p_raw_revenue :'||p_raw_revenue  ;
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;


    IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters';
       pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;


   /* Change to honour billability flag */
    l_calculate_mode := p_calculate_mode;
    IF p_billability_flag = 'N' THEN
        IF l_calculate_mode='REVENUE' THEN
            RETURN;
        ELSE
           l_calculate_mode := 'COST';
        END IF;
    END IF;
  /* End of changes to honour billability flag */

   /* If p_raw_cost ,p_burden_cost and p_raw_revenue is passed then
    the API should pass the same value as it is without any further calculation */
   IF p_raw_cost  IS NOT NULL AND p_burden_cost  IS NOT NULL AND p_raw_revenue   IS NOT NULL THEN
      IF p_override_currency_code IS NULL THEN
           IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Validating Get_planning_rates :pass p_override_currency_code  for Override amounts';
              pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
	 RAISE l_invalid_currency   ;
      ELSE
          l_txn_raw_cost 	    :=p_raw_cost;
	  l_txn_burden_cost  	    :=p_burden_cost;
	  l_txn_raw_revenue	    :=p_raw_revenue ;
          IF p_quantity<>0 THEN
  	     l_txn_cost_rate  	    :=p_raw_cost/NVL(p_quantity,1);
	     l_txn_burden_cost_rate :=p_burden_cost/NVL(p_quantity,1);
	     l_txn_bill_rate	    :=p_raw_revenue /NVL(p_quantity,1);
	  END IF;
	  l_cost_txn_curr_code 	    :=p_override_currency_code;
  	  l_rev_txn_curr_code 	    :=p_override_currency_code;
  	  --l_txn_burden_multiplier   :=null;
	  IF  l_txn_raw_cost<>0 THEN
  	  l_txn_burden_multiplier   :=(l_txn_burden_cost/l_txn_raw_cost);
	  END IF;
          l_raw_cost_rejection_code    :=NULL;
	  l_burden_cost_rejection_code :=NULL;
	  l_revenue_rejection_code     :=NULL;
	  l_cost_ind_compiled_set_id   :=NULL;
      END IF;

   ELSE

   /* Validating Override Currency Code to be not null if any override attribute is passed */
      IF ((p_raw_cost  IS NOT NULL OR p_raw_revenue   IS NOT NULL)
      OR (p_cost_override_rate  IS NOT NULL OR p_revenue_override_rate  IS NOT NULL)) THEN
         IF p_override_currency_code  IS NULL THEN
            IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Validating Get_planning_rates :p_override_currency_code  cannot be null,if p_raw_cost,p_raw_revenue,p_cost_override_rate,p_revenue_override_rate is passed';
              pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            RAISE l_invalid_currency;
          END IF;
      END IF;

          /* Check for using Actual Calculation Flow for Planning Transactions */
      IF p_use_planning_rates_flag    = 'N' THEN
            IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling the Get_plan_actual_Rates ';
            pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
	    BEGIN
	    /* Calling the internal Api to get the actual Rates , this API is one to one mapped with the main API for Actuals*/


	    Get_plan_actual_Rates  (
				p_project_id 		  	  	=>p_project_id	   		,
				p_task_id    		  	  	=>p_task_id   			,
				p_top_task_id		  	  	=>p_top_task_id			,
				p_person_id				=>p_person_id   		,
				p_job_id				=>p_job_id            		,
				p_bill_job_grp_id			=>p_bill_job_grp_id		,
				p_resource_class			=>p_resource_class		,
				p_planning_resource_format		=>p_planning_resource_format	,
				p_rate_based_flag			=>p_rate_based_flag		,
				p_uom					=>p_uom				,
				p_system_linkage			=>p_system_linkage		,
				p_project_organz_id			=>p_project_organz_id		,
				p_rev_task_nl_rate_sch_id		=>p_rev_task_nl_rate_sch_id	,
				p_rev_proj_nl_rate_sch_id		=>p_rev_proj_nl_rate_sch_id	,
				p_rev_job_rate_sch_id 			=>p_rev_job_rate_sch_id		,
				p_rev_emp_rate_sch_id			=>p_rev_emp_rate_sch_id         ,
				p_calculate_mode			=>l_calculate_mode              ,
				p_mcb_flag				=>p_mcb_flag                  	,
				p_bill_rate_multiplier			=>p_bill_rate_multiplier      	,
				p_quantity				=>p_quantity                	,
				p_item_date 				=>p_item_date                	,
				p_labor_sch_type			=>p_labor_sch_type            	,
				p_labor_schdl_discnt			=>p_labor_schdl_discnt        	,
				p_labor_bill_rate_org_id		=>p_labor_bill_rate_org_id  	,
				p_labor_std_bill_rate_schdl		=>p_labor_std_bill_rate_schdl	,
				p_labor_schdl_fixed_date		=>p_labor_schdl_fixed_date   	,
				p_cost_sch_type				=>p_cost_sch_type		,
				p_cost_rate_multiplier			=>p_cost_rate_multiplier     	,
				p_assignment_id             	        =>p_assignment_id            	,
				p_project_org_id			=>p_project_org_id            	,
				p_project_type				=>p_project_type              	,
				p_expenditure_type			=>p_expenditure_type          	,
				p_incurred_by_organz_id			=>p_incurred_by_organz_id     	,
				p_override_to_organz_id			=>p_override_to_organz_id    	,
				p_expenditure_org_id			=>p_expenditure_org_id        	,
				p_assignment_precedes_task		=>p_assignment_precedes_task    ,
				p_planning_transaction_id		=>p_planning_transaction_id   	,
				p_task_bill_rate_org_id			=>p_task_bill_rate_org_id     	,
				p_project_bill_rate_org_id		=>p_project_bill_rate_org_id  	,
				p_non_labor_resource			=>p_non_labor_resource        	,
				p_nlr_organization_id			=>p_nlr_organization_id		,
				p_non_labor_sch_type			=>p_non_labor_sch_type       	,
				p_project_sch_date			=>p_project_sch_date		,
				p_task_sch_date				=>p_task_sch_date		,
				p_project_sch_discount			=>p_project_sch_discount	,
				p_task_sch_discount			=>p_task_sch_discount		,
				p_inventory_item_id			=>p_inventory_item_id		,
				p_BOM_resource_Id			=>p_BOM_resource_Id		,
				P_mfc_cost_type_id			=>P_mfc_cost_type_id		,
                                p_mfc_cost_source                       =>p_mfc_cost_source             ,
				P_item_category_id			=>P_item_category_id  	 	,
				p_cost_override_rate			=>p_cost_override_rate		,
				p_revenue_override_rate			=>p_revenue_override_rate	,
				p_override_burden_cost_rate 	        =>p_override_burden_cost_rate 	,
				p_override_currency_code		=>p_override_currency_code	,
				p_txn_currency_code			=>p_txn_currency_code		,
				p_raw_cost				=>p_raw_cost			,
				p_burden_cost				=>p_burden_cost       		,
				p_raw_revenue				=>p_raw_revenue           	,
				x_bill_rate				=>l_txn_bill_rate		,
				x_cost_rate				=>l_txn_cost_rate		,
				x_burden_cost_rate			=>l_txn_burden_cost_rate	,
				x_burden_multiplier			=>l_txn_burden_multiplier	,
				x_raw_cost          			=>l_raw_cost           		,
				x_burden_cost				=>l_burden_cost               	,
				x_raw_revenue				=>l_raw_revenue              	,
				x_bill_markup_percentage		=>l_bill_markup		        ,
				x_cost_txn_curr_code                    =>l_cost_txn_curr_code		,
			        x_rev_txn_curr_code                     =>l_rev_txn_curr_code		,
				x_raw_cost_rejection_code		=>l_raw_cost_rejection_code	,
				x_burden_cost_rejection_code	        =>l_burden_cost_rejection_code	,
				x_revenue_rejection_code		=>l_revenue_rejection_code	,
				x_cost_ind_compiled_set_id		=>l_cost_ind_compiled_set_id	,
				x_return_status				=>l_x_return_status             ,
				x_msg_data				=>l_x_msg_data                  ,
				x_msg_count				=>l_x_msg_count
			 );



          IF g1_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called the Get_plan_actual_Rates:l_return_status'||l_x_return_status||'x_msg_data'||l_x_msg_data||'x_cost_rej_code'||l_raw_cost_rejection_code;
                pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
	  IF g1_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Called the Get_plan_actual_Rates:l_burd_cost_rate'||l_txn_burden_cost_rate||'l_raw_cost'||l_raw_cost||'l_cost_rate'||l_txn_cost_rate||'l_cost_curr_code'||l_cost_txn_curr_code	;
           pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;
	   IF g1_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called the Get_plan_actual_Rates:l_txn_bill_rate'||l_txn_bill_rate||'l_bill_markup'||l_bill_markup	;
                pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;
	   IF g1_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called the Get_plan_actual_Rates:l_txn_bill_rate'||l_txn_bill_rate||'l_raw_revenue'||l_raw_revenue ||'rev_rej_code'||l_revenue_rejection_code||'curr_code'||l_rev_txn_curr_code	;
                pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;

	     EXCEPTION
	       WHEN OTHERS THEN
	       /* this will be called since the values of l_raw_cost_rejection_code,l_burden_cost_rejection_code are assigned before any
	         exception occurs in the parent procedure definition */
	         IF l_raw_cost_rejection_code IS NOT NULL  OR  l_burden_cost_rejection_code IS NOT NULL THEN
		   l_x_msg_data			:= 'PA_COST1.Get_Plan_Actual_Cost_Rates:' || SUBSTR(SQLERRM,1,250);
		 ELSE
		   l_x_msg_data			:= 'pa_plan_revenue.Get_Plan_Actual_Rev_Rates :' || SUBSTR(SQLERRM,1,250);
		END IF;
		  l_raw_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  l_burden_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  l_revenue_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  IF g1_debug_mode = 'Y' THEN
		     pa_debug.g_err_stage:=' Get_plan_actual_Rates_api is throwing When Others';
		     pa_debug.write('Get_planning_Rates : ' || g_module_name,pa_debug.g_err_stage,3);
		  END IF;
	          RAISE l_Get_planning_Rates_api;
	     END;
         ELSE

        	--	Call  pa_plan_revenue.Get_plan_plan_rates (parameters);

		 IF g1_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Before Calling the Get_plan_plan_Rates:p_use_planning_rates_flag '||p_use_planning_rates_flag ;
                    pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;
	  BEGIN
		Get_plan_plan_Rates  (
				p_project_id 		  	  	=>p_project_id	   		,
				p_task_id    		  	  	=>p_task_id   			,
				p_top_task_id		  	  	=>p_top_task_id			,
				p_person_id				=>p_person_id   		,
				p_job_id				=>p_job_id            		,
				p_bill_job_grp_id			=>p_bill_job_grp_id		,
				p_resource_class			=>p_resource_class		,
				p_rate_based_flag			=>p_rate_based_flag		,
				p_uom					=>p_uom				,
				p_system_linkage			=>p_system_linkage		,
				p_project_organz_id			=>p_project_organz_id		,
				p_plan_rev_job_rate_sch_id 		=>p_plan_rev_job_rate_sch_id    ,
				p_plan_cost_job_rate_sch_id  		=>p_plan_cost_job_rate_sch_id 	,
				p_plan_rev_emp_rate_sch_id		=>p_plan_rev_emp_rate_sch_id    ,
				p_plan_cost_emp_rate_sch_id 	        =>p_plan_cost_emp_rate_sch_id 	,
				p_plan_rev_nlr_rate_sch_id 		=>p_plan_rev_nlr_rate_sch_id   	,
				p_plan_cost_nlr_rate_sch_id 		=>p_plan_cost_nlr_rate_sch_id   ,
				p_plan_burden_cost_sch_id 		=>p_plan_burden_cost_sch_id     ,
				p_calculate_mode			=>l_calculate_mode		,
				p_mcb_flag				=>p_mcb_flag                  	,
	 			p_cost_rate_multiplier			=>p_cost_rate_multiplier        ,
				p_bill_rate_multiplier      		=>p_bill_rate_multiplier        ,
				p_quantity                		=>p_quantity                    ,
				p_item_date                		=>p_item_date                   ,
				p_project_org_id			=>p_project_org_id              ,
				p_project_type				=> p_project_type               ,
				p_expenditure_type			=>p_expenditure_type            ,
				p_non_labor_resource         		=>p_non_labor_resource          ,
				p_incurred_by_organz_id     		=>p_incurred_by_organz_id       ,
				p_override_to_organz_id    		=>p_override_to_organz_id       ,
				p_expenditure_org_id			=>p_expenditure_org_id          ,
				p_planning_transaction_id		=>p_planning_transaction_id     ,
				p_nlr_organization_id			=>p_nlr_organization_id		,
				p_inventory_item_id			=>p_inventory_item_id		,
				p_BOM_resource_Id			=>p_BOM_resource_Id		,
				P_mfc_cost_type_id			=>P_mfc_cost_type_id		,
                                p_mfc_cost_source                       =>p_mfc_cost_source             ,
				P_item_category_id			=>P_item_category_id  	 	,
				p_cost_override_rate			=>p_cost_override_rate		,
				p_revenue_override_rate			=>p_revenue_override_rate	,
				p_override_burden_cost_rate 	        =>p_override_burden_cost_rate 	,
				p_override_currency_code		=>p_override_currency_code	,
				p_txn_currency_code			=>p_txn_currency_code		,
				p_raw_cost				=>p_raw_cost			,
				p_burden_cost				=>p_burden_cost       		,
				p_raw_revenue				=>p_raw_revenue           	,
				x_bill_rate				=>l_txn_bill_rate		,
				x_cost_rate				=>l_txn_cost_rate		,
				x_burden_cost_rate			=>l_txn_burden_cost_rate	,
				x_burden_multiplier			=>l_txn_burden_multiplier	,
				x_raw_cost          			=>l_raw_cost           		,
				x_burden_cost				=>l_burden_cost               	,
				x_raw_revenue				=>l_raw_revenue               	,
				x_bill_markup_percentage		=>l_bill_markup		        ,
				x_cost_txn_curr_code                    =>l_cost_txn_curr_code		,
			        x_rev_txn_curr_code                     =>l_rev_txn_curr_code		,
				x_raw_cost_rejection_code		=>l_raw_cost_rejection_code	,
				x_burden_cost_rejection_code	        =>l_burden_cost_rejection_code	,
				x_revenue_rejection_code		=>l_revenue_rejection_code	,
				x_cost_ind_compiled_set_id		=>l_cost_ind_compiled_set_id	,
				x_return_status				=>l_x_return_status             ,
				x_msg_data				=>l_x_msg_data                  ,
				x_msg_count				=>l_x_msg_count
			 );

                 IF g1_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called the Get_plan_plan_Rates:l_return_status'||l_x_return_status||'x_msg_data'||l_x_msg_data;
                   pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;
		  IF g1_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called the Get_plan_plan_Rates:x_cost_rej_code'||l_raw_cost_rejection_code||'l_burden_cost_rate'||l_txn_burden_cost_rate;
                   pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;
		  IF g1_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called the Get_plan_plan_Rates:l_raw_cost'||l_raw_cost||'l_cost_rate'||l_txn_cost_rate||'l_cost_curr_code'||l_cost_txn_curr_code;
                   pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;
	         IF g1_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called the Get_plan_plan_Rates:l_txn_bill_rate'||l_txn_bill_rate||'l_bill_markup'||l_bill_markup||'l_txn_bill_rate'||l_txn_bill_rate;
                  pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;
		 IF g1_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called the Get_plan_plan_Rates:l_raw_revenue'||l_raw_revenue ||'rev_rej_code'||l_revenue_rejection_code||'revcurr_code'||l_rev_txn_curr_code;
                  pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;


	     EXCEPTION
	       WHEN OTHERS THEN
	         IF l_raw_cost_rejection_code IS NOT NULL  OR  l_burden_cost_rejection_code IS NOT NULL THEN
		   l_x_msg_data			:= 'PA_COST1.Get_Plan_actual_Cost_Rates:' || SUBSTR(SQLERRM,1,250);
		 ELSE
		   l_x_msg_data			:= 'pa_plan_revenue.Get_Plan_plan_Rev_Rates :' || SUBSTR(SQLERRM,1,250);
		END IF;
		  l_raw_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  l_burden_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  l_revenue_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  IF g1_debug_mode = 'Y' THEN
		     pa_debug.g_err_stage:=' Get_plan_plan_Rates_api is throwing When Others';
		     pa_debug.write('Get_planning_Rates : ' || g_module_name,pa_debug.g_err_stage,1);
		  END IF;
	          RAISE l_Get_planning_Rates_api;
	     END;

         END IF;/* End of check for calling for Actual or Planning rates Flow */

           IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='validating for Calling the Get_plan_res_class_rates ';
              pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
      /* Calling the Resource Class Schedule if Rate is not computed based on the Actual Enginee */
      /* here the l_schedule type is set based on l_raw_cost IS NULL  OR l_raw_revenue IS NULL and also based
        on the p_calculate_mode also its decided whether to call the ressource class code to get the  cost and revenue */
      IF ( l_raw_cost IS NULL OR l_burden_cost IS NULL OR l_raw_revenue IS NULL)  THEN
          IF ( l_raw_cost IS NULL
  	  AND  l_raw_revenue IS NULL) THEN
	       IF l_calculate_mode='COST_REVENUE' THEN
		  l_schedule_type:=NULL;
	       ELSE
 	          l_schedule_type:=l_calculate_mode;
	       END IF;
          ELSIF ( l_raw_cost IS NULL ) THEN
	    IF l_calculate_mode<>'REVENUE' THEN
                l_schedule_type:='COST';
		else
		l_schedule_type:='REVENUE';
	   END IF;
          ELSIF ( l_raw_revenue IS NULL ) THEN
	   IF l_calculate_mode<>'COST' THEN
                l_schedule_type:='REVENUE';
		else
		 l_schedule_type:='COST';
   	   END IF;
          END IF;
          IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Before Calling the Get_plan_res_class_rates:->l_schedule_type'||l_schedule_type||' l_raw_revenue'|| l_raw_revenue||'l_raw_cost'||l_raw_cost;
            pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

        /* don't remove the NVLs, the idea is to pass the override rate or any derive  rates to the output of the main api call */
	 /* The overrides should be otherway round, If the overrides present use the overrides else rates present
          l_i_txn_cost_rate	    :=NVL(l_txn_cost_rate,p_cost_override_rate);
          l_i_txn_bill_rate	    :=NVL(l_txn_bill_rate,p_revenue_override_rate);
          l_i_txn_burden_cost_rate :=NVL(l_txn_burden_cost_rate,p_override_burden_cost_rate);
	 */
          l_i_txn_cost_rate         :=NVL(p_cost_override_rate,l_txn_cost_rate);
          l_i_txn_bill_rate         :=NVL(p_revenue_override_rate,l_txn_bill_rate);
          l_i_txn_burden_cost_rate :=NVL(p_override_burden_cost_rate,l_txn_burden_cost_rate);
          l_i_txn_burden_multiplier :=l_txn_burden_multiplier;


	 IF (  (l_schedule_type='COST' and l_raw_cost IS NULL )
	     OR (l_schedule_type='REVENUE' and l_raw_revenue IS NULL )
	     OR  l_schedule_type IS NULL ) THEN
	        IF g1_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Now Calling the Get_plan_res_class_rates:->l_schedule_type'||l_schedule_type||' l_raw_revenue'|| l_raw_revenue||'l_raw_cost'||l_raw_cost;
                   pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;
          BEGIN
             Get_plan_res_class_rates  (
                 p_project_type 		=>p_project_type
                 ,p_project_id 		  	=>p_project_id
 		 ,p_task_id    		  	=>p_task_id
 	         ,p_person_id                   =>p_person_id
                 ,p_job_id                      =>p_job_id
	         ,p_resource_class              =>p_resource_class
                 ,p_use_planning_rates_flag     =>p_use_planning_rates_flag
                 ,p_rate_based_flag	        =>p_rate_based_flag
	         ,p_uom	                        =>p_uom
	         ,p_project_organz_id           =>p_project_organz_id
	        ,p_rev_res_class_rate_sch_id    =>p_rev_res_class_rate_sch_id
	        ,p_cost_res_class_rate_sch_id   =>p_cost_res_class_rate_sch_id
                ,p_plan_burden_cost_sch_id      =>p_plan_burden_cost_sch_id
	        ,p_cost_rate_multiplier         =>p_cost_rate_multiplier
                ,p_bill_rate_multiplier         =>p_bill_rate_multiplier
                ,p_quantity                     =>p_quantity
                ,p_item_date                    =>p_item_date
                ,p_schedule_type                =>l_schedule_type
                ,p_project_org_id               =>p_project_org_id
                ,p_incurred_by_organz_id        =>p_incurred_by_organz_id
	        ,p_override_to_organz_id        =>p_override_to_organz_id
	        ,p_expenditure_org_id           =>p_expenditure_org_id --l_expenditure_org_id
                ,p_nlr_organization_id          =>p_nlr_organization_id
                ,p_override_trxn_cost_rate      =>l_i_txn_cost_rate
		,p_override_burden_cost_rate    =>l_i_txn_burden_cost_rate
                ,p_override_trxn_bill_rate      =>l_i_txn_bill_rate
                ,p_override_txn_currency_code   =>p_override_currency_code
                ,p_txn_currency_code            =>NVL(l_cost_txn_curr_code,p_txn_currency_code)--4194214
                ,p_raw_cost                     =>NVL(l_raw_cost,p_raw_cost)
                ,p_burden_cost                  =>NVL(l_burden_cost,p_burden_cost)
                ,p_raw_revenue                  =>NVL(l_raw_revenue,p_raw_revenue)
                ,p_system_linkage	        =>p_system_linkage
		,p_expenditure_type		=>p_expenditure_type
                ,x_bill_rate                    =>l_txn_bill_rate
                ,x_cost_rate                    =>l_txn_cost_rate
                ,x_burden_cost_rate             =>l_txn_burden_cost_rate
	        ,x_raw_cost                     =>l_txn_raw_cost
                ,x_burden_cost                  =>l_txn_burden_cost
                ,x_raw_revenue                  =>l_txn_raw_revenue
                ,x_bill_markup_percentage       =>l_txn_bill_markup
	        ,x_cost_markup_percentage       =>l_txn_cost_markup
		,x_burden_multiplier            =>l_txn_burden_multiplier
                ,x_cost_txn_curr_code           =>l_cost_res_txn_curr_code
		,x_rev_txn_curr_code            =>l_rev_res_txn_curr_code
                ,x_raw_cost_rejection_code	=>l_raw_cost_rejection_code
		,x_burden_cost_rejection_code	=>l_burden_cost_rejection_code
                ,x_revenue_rejection_code	=>l_revenue_rejection_code
		,x_cost_ind_compiled_set_id	=>l_cost_ind_compiled_set_id
                ,x_return_status                =>l_x_return_status
                ,x_msg_count                    =>l_x_msg_count
                ,x_msg_data                     =>l_x_msg_data);


	    EXCEPTION
	       WHEN OTHERS THEN
	          l_x_msg_data  := 'pa_plan_revenue.Get_plan_res_class_rates:' || SUBSTR(SQLERRM,1,250);
		  l_raw_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  l_burden_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  l_revenue_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  IF g1_debug_mode = 'Y' THEN
		     pa_debug.g_err_stage:=' Get_plan_res_class_rates_api is throwing When Others';
		     pa_debug.write('Get_planing_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
		  END IF;
	 	  RAISE l_Get_planning_Rates_api;
	    END;
          /*++++++++++++++++++++++++++++++++++++++++++++++++++*/
            IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='after Get_plan_res_class_rates :return_status'||l_x_return_status||'msgdata'||l_x_msg_data||'rawcost_rej_code'||l_raw_cost_rejection_code;
              pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
	    IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='after Get_plan_res_class_rates :x_revenue_rejection_code'||l_revenue_rejection_code||'l_txn_raw_cost'||l_txn_raw_cost;
              pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
	     IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='after Get_plan_res_class_rates :l_txn_burden_cost'||l_txn_burden_cost||'l_txn_raw_revenue'||l_txn_raw_revenue;
              pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
       ELSE
            l_txn_raw_cost     := l_raw_cost;
            l_txn_burden_cost  := l_burden_cost	  ;
	    l_txn_raw_revenue  := l_raw_revenue;

        END IF;/*  IF (  (l_schedule_type='COST' and l_raw_cost IS NULL )OR (l_schedule_type='REVENUE' and l_raw_revenue IS NULL )*/

	 /* If Revenue or Cost is there that means rates must be associated to if computed by API
		    else pass the same cost and the override rate to the out parameters */

          ELSE
            l_txn_raw_cost     := l_raw_cost;
            l_txn_burden_cost  := l_burden_cost	  ;
	    l_txn_raw_revenue  := l_raw_revenue;
          END IF;/* End of check for calling Resourtce Calss schedule */

       END IF;/* IF p_raw_cost  IS NOT NULL AND p_burden_cost  IS NOT NULL AND p_raw_revenue   IS NOT NULL THEN */
           /* Assigning All the out parameters for the procedure */

         IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Setting all the out parameters for thr procedure';
            pa_debug.write('Get_planning_rates: ' || g_module_name,pa_debug.g_err_stage,3);
         END IF;

        x_bill_rate                   :=NVL(l_i_txn_bill_rate,l_txn_bill_rate);--4108291
        x_cost_rate                   :=NVL(l_i_txn_cost_rate,l_txn_cost_rate) ;--4108291
	x_burden_cost_rate            :=NVL(l_i_txn_burden_cost_rate,l_txn_burden_cost_rate) ;
	x_burden_multiplier	      :=NVL(l_i_txn_burden_multiplier,l_txn_burden_multiplier)	;--4108291
	x_raw_cost                    :=l_txn_raw_cost;
        x_burden_cost                 :=l_txn_burden_cost ;
	x_raw_revenue                 :=l_txn_raw_revenue  ;
        x_bill_markup_percentage      :=NVL(l_bill_markup,l_txn_bill_markup);
	IF l_txn_raw_cost IS NOT NULL THEN
	   x_cost_txn_curr_code          :=NVL(l_cost_txn_curr_code,l_cost_res_txn_curr_code) 	;
	END IF;
	IF l_txn_raw_revenue  IS NOT NULL THEN
	   x_rev_txn_curr_code           :=NVL(l_rev_txn_curr_code,l_rev_res_txn_curr_code)	;
	END IF;
	x_raw_cost_rejection_code     :=l_raw_cost_rejection_code	;
	x_burden_cost_rejection_code  :=l_burden_cost_rejection_code	;
	x_revenue_rejection_code      :=l_revenue_rejection_code;
	x_cost_ind_compiled_set_id    :=l_cost_ind_compiled_set_id	;
        x_return_status               :=l_x_return_status;
        x_msg_data                    :=l_x_msg_data;
	x_msg_count                   :=l_x_msg_count;
        PA_DEBUG.reset_err_stack;
  EXCEPTION
     WHEN l_rate_based_no_quantity THEN
 	 IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Quantity is required for a rate based  transaction ';
            pa_debug.write('Get_planning_Rates : ' || g_module_name,pa_debug.g_err_stage,1);
        END IF;
    	x_return_status           :=  g_ERROR;
        x_msg_count               := 1;
        x_msg_data                := 'PA_EX_QTY_EXIST';
        x_revenue_rejection_code  := 'PA_EX_QTY_EXIST';
        x_raw_cost_rejection_code := 'PA_EX_QTY_EXIST';
        x_raw_revenue		  := NULL;
	x_raw_cost		  := NULL;
	x_bill_rate		  := NULL;
	x_cost_rate		  := NULL;
	x_cost_txn_curr_code      := NULL	;
	x_rev_txn_curr_code       := NULL 	;

        PA_DEBUG.reset_err_stack;
    WHEN l_invalid_currency  THEN
 	IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Currecny Override is not entered  for the ammounts entered';
            pa_debug.write('Get_planning_Rates : ' || g_module_name,pa_debug.g_err_stage,1);
        END IF;
    	x_return_status           :=  g_ERROR;
        x_msg_count               := 1;
        x_msg_data                := 'PA_INVALID_DENOM_CURRENCY';
        x_revenue_rejection_code  := 'PA_INVALID_DENOM_CURRENCY';
        x_raw_cost_rejection_code := 'PA_INVALID_DENOM_CURRENCY';
        x_raw_revenue		  := NULL ;
	x_raw_cost		  := NULL ;
	x_bill_rate		  := NULL ;
	x_cost_rate		  := NULL ;
	x_cost_txn_curr_code      := NULL ;
	x_rev_txn_curr_code       := NULL ;

	PA_DEBUG.reset_err_stack;
WHEN l_Get_planning_Rates_api THEN
	 IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='plan_actual_Rates r Plan_plan_rates r res_class_rates throwing When Others:p_project_id'||p_project_id||'p_task_id'||p_task_id;
            pa_debug.write('Get_planning_Rates : ' || g_module_name,pa_debug.g_err_stage,1);
          END IF;
    	x_return_status		  := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count               := 1;
        x_msg_data	          := l_x_msg_data ;
        x_revenue_rejection_code  := l_revenue_rejection_code;
        x_raw_cost_rejection_code := l_raw_cost_rejection_code;
	x_burden_cost_rejection_code:=l_burden_cost_rejection_code;
        x_raw_revenue		  := NULL;
	x_raw_cost		  := NULL;
	x_bill_rate		  := NULL;
	x_cost_rate		  := NULL;
	x_cost_txn_curr_code      := NULL;
	x_rev_txn_curr_code       := NULL;
	x_bill_markup_percentage       := NULL;

       PA_DEBUG.reset_err_stack;

 WHEN OTHERS THEN
         IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='In the when others  of Get_Planning_Rates:p_project_id'||p_project_id||'p_task_id'||p_task_id;
            pa_debug.write('Get_planing_Rates : ' || g_module_name,pa_debug.g_err_stage,1);
            END IF;
    	x_return_status		  := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count               := 1;
        x_msg_data	          := 'Get_Planning_Rates'||SUBSTR(SQLERRM,1,250);
        x_revenue_rejection_code  := SUBSTR(SQLERRM,1,30);
        x_raw_cost_rejection_code := SUBSTR(SQLERRM,1,30);
	x_burden_cost_rejection_code:=SUBSTR(SQLERRM,1,30);
        x_raw_revenue		  := NULL;
	x_raw_cost		  := NULL;
	x_bill_rate		  := NULL;
	x_cost_rate		  := NULL;
	x_cost_txn_curr_code      := NULL;
	x_rev_txn_curr_code       := NULL;
   	x_bill_markup_percentage  := NULL;

	PA_DEBUG.reset_err_stack;

END Get_Planning_Rates;


--
-- Procedure            : Get_plan_actual_Rates
-- Purpose              : This is an internal procedure for calculating the  bill rate and raw revenue from one of
--                        the given criteria's on the basis of passed parameters for the 'ACTUAL RATES' of Planning Transaction
-- Parameters           :
--


PROCEDURE Get_plan_actual_Rates  (
	p_project_id                   	 IN     NUMBER,
	p_task_id                        IN     NUMBER      DEFAULT NULL,
        p_top_task_id                    IN     NUMBER      DEFAULT NULL, /* for costing top task Id */
	p_person_id                    	 IN     NUMBER,
	p_job_id                         IN     NUMBER,			  /* for costing p_proj_cost_job_id */
	p_bill_job_grp_id             	 IN     NUMBER      DEFAULT NULL,
	p_resource_class		 IN     VARCHAR2,                 /* resource_class_code for Resource Class */
	p_planning_resource_format       IN     VARCHAR2 ,                /* resource format required for Costing */
	p_use_planning_rates_flag    	 IN     VARCHAR2    DEFAULT 'N',  /* Rate using Actual Rates */
	p_rate_based_flag		 IN     VARCHAR2    DEFAULT 'Y',  /* to identify a rate based transaction */
	p_uom			    	 IN     VARCHAR2,		  /* Planning UOM */
	p_system_linkage		 IN     VARCHAR2,
	p_project_organz_id            	 IN     NUMBER	    DEFAULT NULL, /* For revenue calc use in Resource Class Sch carrying out Org Id */
	p_rev_task_nl_rate_sch_id        IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Non Labor*/
   	p_rev_proj_nl_rate_sch_id        IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Non Labor*/
        p_rev_job_rate_sch_id         	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Job*/
	p_rev_emp_rate_sch_id         	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Emp*/
	p_calculate_mode                  IN     VARCHAR2   DEFAULT 'COST_REVENUE' ,/* useed for calculating either only Cost(COST),only Revenue(REVENUE) or both Cost and Revenue(COST_REVENUE) */
	p_mcb_flag                    	 IN     VARCHAR2    DEFAULT NULL,
        p_cost_rate_multiplier           IN     NUMBER     DEFAULT NULL ,
        p_bill_rate_multiplier      	 IN     NUMBER	    DEFAULT 1,
        p_quantity                	 IN     NUMBER,                    /* required param for People/Equipment Class */
        p_item_date                	 IN     DATE,                      /* Used as p_expenditure_item_date for non labor */
   	p_cost_sch_type		 	 IN     VARCHAR2 ,		   /* Costing Schedule Type'COST' / 'REVENUE' / 'INVOICE' */
        p_labor_sch_type            	 IN     VARCHAR2,		   /* Revenue Labor Schedule Type B/I */
        p_non_labor_sch_type       	 IN     VARCHAR2 ,                  /* Revenue Non_Labor Schedule Type B/I */
        p_labor_schdl_discnt         	 IN     NUMBER	    DEFAULT NULL,
        p_labor_bill_rate_org_id   	 IN     NUMBER	    DEFAULT NULL,
        p_labor_std_bill_rate_schdl 	 IN     VARCHAR2    DEFAULT NULL,
        p_labor_schdl_fixed_date   	 IN     DATE        DEFAULT NULL,
 	p_assignment_id               	 IN     NUMBER      DEFAULT NULL,  /* used as  p_item_id  in the internal APIs */
        p_project_org_id            	 IN     NUMBER,			   /* Project Org Id */
        p_project_type              	 IN     VARCHAR2,
        p_expenditure_type          	 IN     VARCHAR2,
        p_non_labor_resource         	 IN     VARCHAR2    DEFAULT NULL,
        p_incurred_by_organz_id     	 IN     NUMBER,                    /* Incurred By Org Id */
	p_override_to_organz_id    	 IN     NUMBER,			   /* Override Org Id */
	p_expenditure_org_id        	 IN     NUMBER,                    /* p_expenditure_OU (p_exp_organization_id in costing) */
        p_assignment_precedes_task 	 IN     VARCHAR2,		   /* Added for Asgmt overide */
        p_planning_transaction_id    	 IN     NUMBER      DEFAULT NULL,  /* changeed from p_forecast_item_id will passed to client extension */
        p_task_bill_rate_org_id      	 IN     NUMBER      DEFAULT NULL,  /* Org Id of the Bill Rate at Project Level */
        p_project_bill_rate_org_id       IN     NUMBER      DEFAULT NULL,  /* Org Id of the Bill Rate at task Level */
	p_nlr_organization_id            IN     NUMBER     DEFAULT NULL,   /* Org Id of the Non Labor Resource */
        p_project_sch_date          	 IN     DATE        DEFAULT NULL,   /* Revenue Non_Labor Schedule Date at project Level */
	p_task_sch_date             	 IN     DATE        DEFAULT NULL,   /* Revenue Non_Labor Schedule Date at task Level */
	p_project_sch_discount      	 IN     NUMBER      DEFAULT NULL ,  /* Revenue Non_Labor Schedule Discount at project Level */
        p_task_sch_discount        	 IN     NUMBER      DEFAULT NULL ,  /* Revenue Non_Labor Schedule Discount at task Level */
        p_inventory_item_id         	 IN	NUMBER      DEFAULT NULL,  /* Passed for Inventoty Items */
        p_BOM_resource_Id          	 IN	NUMBER      DEFAULT NULL,  /* Passed for BOM Resource  Id */
        P_mfc_cost_type_id           	 IN	NUMBER      DEFAULT 0,     /* Manufacturing cost api */
        P_item_category_id           	 IN	NUMBER      DEFAULT NULL,  /* Manufacturing cost api */
        p_mfc_cost_source                IN     NUMBER      DEFAULT 1,
        p_cost_override_rate        	 IN	NUMBER      DEFAULT NULL,  /*override rate if not null no call to costing internal api.*/
        p_revenue_override_rate     	 IN	NUMBER      DEFAULT NULL,  /*override rate if not null no call to billing internal api.*/
        p_override_burden_cost_rate  	 IN	NUMBER      DEFAULT NULL,
        p_override_currency_code  	 IN	VARCHAR2    DEFAULT NULL,  /*override currency Code */
        p_txn_currency_code		 IN	VARCHAR2    DEFAULT NULL,  /* if not null, amounts to be returned in this currency only else in x_txn_curr_code*/
        p_raw_cost                       IN 	NUMBER,		           /*If p_raw_cost is only passed,return the burden multiplier, burden_cost */
        p_burden_cost                    IN 	NUMBER      DEFAULT NULL,
        p_raw_revenue                	 IN     NUMBER      DEFAULT NULL,
	x_bill_rate                      OUT NOCOPY	NUMBER,
        x_cost_rate                      OUT NOCOPY	NUMBER,
        x_burden_cost_rate               OUT NOCOPY	NUMBER,
        x_burden_multiplier		 OUT NOCOPY	NUMBER,
        x_raw_cost                       OUT NOCOPY	NUMBER,
        x_burden_cost                    OUT NOCOPY	NUMBER,
        x_raw_revenue                	 OUT NOCOPY	NUMBER,
        x_bill_markup_percentage       	 OUT NOCOPY     NUMBER,
        x_cost_txn_curr_code         	 OUT NOCOPY     VARCHAR2,
        x_rev_txn_curr_code         	 OUT NOCOPY     VARCHAR2,
        x_raw_cost_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_burden_cost_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_revenue_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_cost_ind_compiled_set_id	 OUT NOCOPY	NUMBER,
        x_return_status              	 OUT NOCOPY     VARCHAR2,
        x_msg_data                   	 OUT NOCOPY     VARCHAR2,
        x_msg_count                  	 OUT NOCOPY     NUMBER
	)
IS
l_raw_cost   						 NUMBER :=NULL;
l_burden_cost    					 NUMBER :=NULL;
l_raw_revenue           				 NUMBER:=NULL;
l_x_return_status       				 VARCHAR2(2):= g_success;
l_cost_msg_count           		   		 NUMBER;
l_cost_msg_data		           			 VARCHAR2(1000);
l_bill_msg_count             			         NUMBER;
l_bill_msg_data              			         VARCHAR2(1000);
l_called_process        				 VARCHAR2(40);
l_txn_curr_code         				 VARCHAR2(30);
l_trxn_curr_code         				 VARCHAR2(30);
l_cost_txn_curr_code         				 VARCHAR2(30);
l_rev_txn_curr_code         				 VARCHAR2(30);
l_rev_curr_code         				 VARCHAR2(30);
l_txn_cost         				         NUMBER:=NULL; /* to store the value of p_burden_cost or p_raw_cost */
l_proj_nl_bill_rate_sch_id 				 NUMBER;
l_task_nl_bill_rate_sch_id 				 NUMBER;
l_txn_cost_rate         				 NUMBER;
l_txn_raw_cost_rate    					 NUMBER;
l_txn_burden_cost_rate  				 NUMBER;
l_txn_bill_rate         				 NUMBER;
l_txn_bill_markup       				 NUMBER:=NULL;
l_txn_raw_cost          				 NUMBER;
l_txn_burden_cost       				 NUMBER;
l_txn_raw_revenue       				 NUMBER;
l_sl_function           				 NUMBER ;
l_exp_func_Curr_code    				 VARCHAR2(30);
l_raw_cost_rate         				 NUMBER ;
l_burden_cost_rate  		   			 NUMBER ;
l_bill_rate             				 NUMBER:=NULL;
l_burden_multiplier					 NUMBER;
l_raw_cost_rejection_code				 VARCHAR2(1000);
l_burden_cost_rejection_code				 VARCHAR2(1000);
l_cost_ind_compiled_set_id				 NUMBER;
l_proj_cost_job_id					 NUMBER;
l_expenditure_org_id					 NUMBER;



BEGIN
   l_raw_revenue := p_raw_revenue;
   l_raw_cost    := p_raw_cost;
   l_burden_cost := p_burden_cost;
    IF upper(p_resource_class)='PEOPLE' THEN
     l_expenditure_org_id :=nvl(p_incurred_by_organz_id, p_override_to_organz_id );
    ELSE
       l_expenditure_org_id :=nvl(p_nlr_organization_id,p_override_to_organz_id );
    END IF;

   	IF p_system_linkage='BTC' THEN
	  l_txn_cost := p_burden_cost;
	ELSE
	  l_txn_cost := p_raw_cost;
	END IF;
    IF ((p_raw_cost IS  NULL OR  p_burden_cost IS  NULL)
    AND p_calculate_mode IN ('COST','COST_REVENUE')) THEN
          IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Before Calling PA_COST1.Get_Plan_Actual_Cost_Rates';
            pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;

	BEGIN
	 PA_COST1.Get_Plan_Actual_Cost_Rates
        (p_calling_mode                 =>'ACTUAL_RATES'
        ,p_project_type                 =>p_project_type
        ,p_project_id                   =>p_project_id
        ,p_task_id                      =>p_task_id
        ,p_top_task_id                  =>p_top_task_id
        ,p_Exp_item_date                =>p_item_date
        ,p_expenditure_type             =>p_expenditure_type
        ,p_expenditure_OU               =>p_expenditure_org_id
        ,p_project_OU                   =>p_project_org_id
        ,p_Quantity                     =>p_Quantity
        ,p_resource_class               =>p_resource_class
        ,p_person_id                    =>p_person_id
        ,p_non_labor_resource           =>p_non_labor_resource
        ,p_NLR_organization_id          =>p_NLR_organization_id
        ,p_override_organization_id     =>p_override_to_organz_id
        ,p_incurred_by_organization_id  =>p_incurred_by_organz_id
        ,p_inventory_item_id            =>p_inventory_item_id
        ,p_BOM_resource_id              =>p_BOM_resource_id
        ,p_override_trxn_curr_code      =>p_override_currency_code
        ,p_override_burden_cost_rate    =>p_override_burden_cost_rate
        ,p_override_trxn_cost_rate      =>p_cost_override_rate
        ,p_override_trxn_raw_cost       =>p_raw_cost
        ,p_override_trxn_burden_cost    =>p_burden_cost
        ,p_mfc_cost_type_id             =>p_mfc_cost_type_id
        ,p_mfc_cost_source              =>p_mfc_cost_source --check
        ,p_item_category_id             =>p_item_category_id
	,p_job_id                       =>p_job_id
        , p_plan_cost_job_rate_sch_id   =>NULL
        , p_plan_cost_emp_rate_sch_id   =>NULL
        , p_plan_cost_nlr_rate_sch_id   =>NULL
	, p_plan_cost_burden_sch_id     =>NULL
        ,x_trxn_curr_code               =>l_trxn_curr_code
        ,x_trxn_raw_cost                =>l_txn_raw_cost
        ,x_trxn_raw_cost_rate           =>l_txn_cost_rate
        ,x_trxn_burden_cost             =>l_txn_burden_cost
        ,x_trxn_burden_cost_rate        =>l_txn_burden_cost_rate
        ,x_burden_multiplier            =>l_burden_multiplier
        ,x_cost_ind_compiled_set_id     =>l_cost_ind_compiled_set_id
        ,x_raw_cost_rejection_code      =>l_raw_cost_rejection_code
        ,x_burden_cost_rejection_code   =>l_burden_cost_rejection_code
        ,x_return_status                =>l_x_return_status
        ,x_error_msg_code               =>l_cost_msg_data ) ;

	   IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Called PA_COST1.Get_Plan_Actual_Cost_Rates:l_x_return_status'||l_x_return_status||'l_msg_data'||l_cost_msg_data||'x_cost_rej_code'||l_raw_cost_rejection_code;
            pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
	   IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Called PA_COST1.Get_Plan_Actual_Cost_Rates:x_burden_rej_code'||l_burden_cost_rejection_code||'l_txn_raw_cost'||l_txn_raw_cost;
            pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
	   IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Called PA_COST1.Get_Plan_Actual_Cost_Rates:l_txn_cost_rate'||l_txn_cost_rate||'l_trxn_curr_code'||l_trxn_curr_code;
            pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
	   EXCEPTION
	       WHEN OTHERS THEN
	          x_msg_data		:= 'PA_COST1.Get_Plan_Actual_Cost_Rates:' || SUBSTR(SQLERRM,1,250);
		  x_raw_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  x_burden_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

		  IF g1_debug_mode = 'Y' THEN
		     pa_debug.g_err_stage:=' PA_COST1.Get_Plan_Actual_Cost_Rates is throwing When Others';
		     pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,1);
		  END IF;
		  RAISE;
	      --  RAISE l_Get_plan_actual_Rates; /* Added to handle exception return by costing api */
	     END;
	    /* transferring the outout cost to one cost and checking if the costing API has computed Cost */
	    IF p_system_linkage='BTC' THEN
	       l_txn_cost := l_txn_burden_cost;
	    ELSE
	       l_txn_cost :=l_txn_raw_cost;
	    END IF;


     ELSE
        /* If p_raw_cost and p_burden Cost are passed Costing API
	    won't be called but the same value will be passed as it is */
        l_txn_raw_cost :=l_raw_cost ;
        l_txn_burden_cost :=l_burden_cost ;
	IF p_quantity <>0 THEN
	  l_txn_cost_rate :=l_raw_cost/(NVL(p_quantity,1)) ;
          l_txn_burden_cost_rate :=l_burden_cost/(NVL(p_quantity,1)) ;
	END IF;

     END IF;

   /* Sending out all the out parametrs of Costing , This is send out here as even if the costing API has failed
      Revenue API will be called and revenue calculated if the required values are passed to the Billing API,
	  though it'll pass the rejection code of Costing APi in the out parameters*/
        x_cost_rate                   := l_txn_cost_rate;
	x_burden_cost_rate            := l_txn_burden_cost_rate;
	x_burden_multiplier	      := l_burden_multiplier ;
	x_raw_cost                    := l_txn_raw_cost;
        x_burden_cost                 := l_txn_burden_cost;
        x_cost_txn_curr_code          := l_trxn_curr_code;
	x_raw_cost_rejection_code     := l_raw_cost_rejection_code ;
	x_burden_cost_rejection_code  := l_burden_cost_rejection_code;
	x_cost_ind_compiled_set_id    := l_cost_ind_compiled_set_id;
        x_return_status               := l_x_return_status ;
        x_msg_data		      := l_cost_msg_data	;

 /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

IF p_calculate_mode IN ('REVENUE','COST_REVENUE') THEN

   /* Calling the Billing Revenue  calculation Api only if p_raw_revenue is null */
   IF l_raw_revenue IS NULL THEN
    /* Checking for Rate based whether quantity is entered else */
      IF p_rate_based_flag ='Y' THEN
         null;
      ELSE
   	 IF NVL(l_txn_cost,0)=0 THEN
            IF p_quantity is  NOT NULL and p_revenue_override_rate  is not null then
               null;
            else
               RAISE  l_no_cost;
            END IF;
         END IF;
      END IF;

	 IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Calling Get_Plan_Actual_Rev_Rates';
              pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;

        Get_Plan_Actual_Rev_Rates  (
					p_project_id                   	 => p_project_id ,
					p_task_id                        => p_task_id,
				        p_person_id                    	 => p_person_id   ,
					p_job_id                         => p_job_id,
					p_bill_job_grp_id             	 => p_bill_job_grp_id,
					p_resource_class		 => p_resource_class,
					p_rate_based_flag		 => p_rate_based_flag,
					p_uom			    	 => p_uom,
					p_system_linkage		 => p_system_linkage,
					p_project_organz_id            	 => p_project_organz_id,
					p_rev_proj_nl_rate_sch_id      	 => p_rev_proj_nl_rate_sch_id ,
					p_rev_task_nl_rate_sch_id      	 => p_rev_task_nl_rate_sch_id ,
					p_rev_job_rate_sch_id            => p_rev_job_rate_sch_id,
					p_rev_emp_rate_sch_id            => p_rev_emp_rate_sch_id ,
					p_mcb_flag                       => p_mcb_flag,
					p_bill_rate_multiplier      	 => p_bill_rate_multiplier  ,
					p_quantity                	 => p_quantity ,
					p_item_date                	 => p_item_date,
					p_labor_sch_type                 => p_labor_sch_type,
					p_labor_schdl_discnt             => p_labor_schdl_discnt  ,
					p_labor_bill_rate_org_id         => p_labor_bill_rate_org_id ,
					p_labor_std_bill_rate_schdl 	 => p_labor_std_bill_rate_schdl ,
					p_labor_schdl_fixed_date         => p_labor_schdl_fixed_date   	 ,
					p_assignment_id                  => p_assignment_id         ,
					p_project_org_id                 => p_project_org_id ,
					p_project_type                   => p_project_type,
					p_expenditure_type               => p_expenditure_type    ,
				        p_incurred_by_organz_id          => p_incurred_by_organz_id     ,
					p_override_to_organz_id          => p_override_to_organz_id ,
					p_expenditure_org_id             => l_expenditure_org_id,    --p_expenditure_org_id  ,
					p_assignment_precedes_task 	 => p_assignment_precedes_task 	,
					p_planning_transaction_id        => p_planning_transaction_id,
					p_task_bill_rate_org_id          => p_task_bill_rate_org_id,
					p_project_bill_rate_org_id       => p_project_bill_rate_org_id  ,
					p_non_labor_resource         	 => p_non_labor_resource  ,
					p_NLR_organization_id            => p_NLR_organization_id ,
					p_non_labor_sch_type             => p_non_labor_sch_type ,
					p_project_sch_date          	 => p_project_sch_date  ,
					p_task_sch_date             	 => p_task_sch_date,
					p_project_sch_discount      	 => p_project_sch_discount,
					p_task_sch_discount        	 => p_task_sch_discount,
					p_revenue_override_rate     	 => p_revenue_override_rate,
					p_override_currency_code  	 => p_override_currency_code,
					p_txn_currency_code		 => l_trxn_curr_code	,
					p_raw_cost                       => l_txn_raw_cost,
					p_burden_cost                    => l_txn_burden_cost,
					p_raw_revenue                	 => l_raw_revenue,
					p_raw_cost_rate			 => l_txn_cost_rate   ,
					x_bill_rate                      => l_txn_bill_rate,
					x_raw_revenue                	 => l_txn_raw_revenue,
					x_bill_markup_percentage       	 => l_txn_bill_markup,
					x_txn_curr_code         	 => l_rev_txn_curr_code,
					x_return_status              	 => l_x_return_status,
					x_msg_data                   	 => l_bill_msg_data,
					x_msg_count                  	 => l_bill_msg_count
					);
		IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='OUT of Get_Plan_Actual_Rev_Rates:l_x_return_status'||l_x_return_status||'l_bill_msg_data'||l_bill_msg_data||'l_txn_raw_revenue'||l_txn_raw_revenue;
              pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;

		/* Raising the Billing Exception to pass the error values to the Main Api */
	  	IF   l_x_return_status <> g_success THEN
	  	     RAISE   l_bill_api;
		END IF;

	ELSE
            IF p_override_currency_Code IS NULL THEN
	       RAISE l_invalid_currency;
	    END IF;
	    l_txn_raw_revenue :=l_raw_revenue ;
	    IF p_quantity <>0  THEN
  	      l_txn_bill_rate :=l_raw_revenue/(NVL(p_quantity,1)) ;
	    END IF;
	    l_rev_txn_curr_code:=p_override_currency_Code;
	END IF;
       /* Passing the output parametrs of Billing for Revenue */
       END IF;/* End of IF p_calculate_mode IN ('REVENUE','COST_REVENUE') THEN */

        x_raw_revenue 			 :=l_txn_raw_revenue;
	x_bill_rate	  		 :=l_txn_bill_rate ;
        x_bill_markup_percentage         :=l_txn_bill_markup;
	x_rev_txn_curr_code              :=l_rev_txn_curr_code; /* x_txn_currency_code  for Labor and x_rev_curr_code   for non labor */
	x_revenue_rejection_code         :=NULL;
        x_return_status                  :=l_x_return_status;

EXCEPTION
    WHEN l_invalid_currency  THEN

	 IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Currecny Override is not entered  for the ammounts entered:p_project_id'||p_project_id||'p_task_id'||p_task_id;
              pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;
    	x_return_status           :=  g_ERROR;
        x_msg_count               := 1;
        x_msg_data                := 'PA_INVALID_DENOM_CURRENCY';
        x_revenue_rejection_code  := 'PA_INVALID_DENOM_CURRENCY';
        x_raw_cost_rejection_code := l_raw_cost_rejection_code;
	x_burden_cost_rejection_code     := l_burden_cost_rejection_code;
        x_raw_revenue		  := NULL;
	x_bill_rate		  := NULL;
	x_rev_txn_curr_code      :=NULL	;

   WHEN l_no_cost THEN
          x_raw_revenue 			:= NULL;
	  x_bill_rate	  			:= NULL;
          x_bill_markup_percentage               := NULL;
	  x_rev_txn_curr_code         	        := NULL;
	  x_revenue_rejection_code	        := 'PA_NO_ACCT_COST';
          x_return_status                       := g_error;
          x_msg_data                   	        := 'PA_NO_ACCT_COST';
	  x_msg_count                  	        := 1;


           IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='No Cost exist for the tranascation:p_project_id'||p_project_id||'p_task_id'||p_task_id;
              pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;
   WHEN l_bill_api THEN
	  x_raw_revenue 			:= NULL;
	  x_bill_rate	  			:= NULL;
          x_bill_markup_percentage              := NULL;
	  x_rev_txn_curr_code         	        := NULL;
	  x_revenue_rejection_code	        := l_bill_msg_data;
          x_return_status                       := l_x_return_status;
          x_msg_data                   	        := l_bill_msg_data;
	  x_msg_count                  	        := l_bill_msg_count;

         IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Billing api is throwing error';
              pa_debug.write('Get_plan_actual_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;


END Get_plan_actual_Rates;


-- Procedure            : Get_plan_actual_RevRates
-- Purpose              : This is an internal procedure for calculating the  bill rate and raw revenue from one of
--                        the given criteria's on the basis of passed parameters for the 'ACTUAL RATES' of Planning Transaction
-- Parameters           :
--

PROCEDURE Get_Plan_Actual_Rev_Rates  (
	p_project_id                   	 IN     NUMBER,
	p_task_id                        IN     NUMBER      DEFAULT NULL,
        p_person_id                    	 IN     NUMBER,
	p_job_id                         IN     NUMBER,			  /* for costing p_proj_cost_job_id */
	p_bill_job_grp_id             	 IN     NUMBER      DEFAULT NULL,
	p_resource_class		 IN     VARCHAR2,                 /* resource_class_code for Resource Class */
	p_rate_based_flag		 IN     VARCHAR2    DEFAULT 'Y',  /* to identify a rate based transaction */
	p_uom			    	 IN     VARCHAR2,		  /* Planning UOM */
	p_system_linkage		 IN     VARCHAR2,
	p_project_organz_id            	 IN     NUMBER	    DEFAULT NULL, /* For revenue calc use in Resource Class Sch carrying out Org Id */
	p_rev_proj_nl_rate_sch_id      	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Non Labor*/
        p_rev_task_nl_rate_sch_id      	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Non Labor*/
	p_rev_job_rate_sch_id         	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Job*/
	p_rev_emp_rate_sch_id         	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Emp*/
	p_mcb_flag                    	 IN     VARCHAR2    DEFAULT NULL,
        p_bill_rate_multiplier      	 IN     NUMBER	    DEFAULT 1,
        p_quantity                	 IN     NUMBER,                    /* required param for People/Equipment Class */
        p_item_date                	 IN     DATE,                      /* Used as p_expenditure_item_date for non labor */
 	p_labor_sch_type            	 IN     VARCHAR2,		   /* Revenue Labor Schedule Type B/I */
        p_labor_schdl_discnt         	 IN     NUMBER	    DEFAULT NULL,
        p_labor_bill_rate_org_id   	 IN     NUMBER	    DEFAULT NULL,
        p_labor_std_bill_rate_schdl 	 IN     VARCHAR2    DEFAULT NULL,
        p_labor_schdl_fixed_date   	 IN     DATE        DEFAULT NULL,
	p_assignment_id               	 IN     NUMBER      DEFAULT NULL,  /* used as  p_item_id  in the internal APIs */
        p_project_org_id            	 IN     NUMBER,			   /* Project Org Id */
        p_project_type              	 IN     VARCHAR2,
        p_expenditure_type          	 IN     VARCHAR2,
        p_incurred_by_organz_id     	 IN     NUMBER,                    /* Incurred By Org Id */
	p_override_to_organz_id    	 IN     NUMBER,			   /* Override Org Id */
	p_expenditure_org_id        	 IN     NUMBER,                    /* p_expenditure_OU (p_exp_organization_id in costing) */
        p_assignment_precedes_task 	 IN     VARCHAR2,		   /* Added for Asgmt overide */
        p_planning_transaction_id    	 IN     NUMBER      DEFAULT NULL,  /* changeed from p_forecast_item_id will passed to client extension */
        p_task_bill_rate_org_id      	 IN     NUMBER      DEFAULT NULL,  /* Org Id of the Bill Rate at Project Level */
        p_project_bill_rate_org_id       IN     NUMBER      DEFAULT NULL,  /* Org Id of the Bill Rate at task Level */
	p_non_labor_resource         	 IN     VARCHAR2    DEFAULT NULL,
	p_NLR_organization_id            IN      NUMBER     DEFAULT NULL,   /* Org Id of the Non Labor Resource */
	p_non_labor_sch_type       	 IN     VARCHAR2 ,                  /* Revenue Non_Labor Schedule Type B/I */
	p_project_sch_date          	 IN     DATE        DEFAULT NULL,   /* Revenue Non_Labor Schedule Date at project Level */
	p_task_sch_date             	 IN     DATE        DEFAULT NULL,   /* Revenue Non_Labor Schedule Date at task Level */
	p_project_sch_discount      	 IN     NUMBER      DEFAULT NULL ,  /* Revenue Non_Labor Schedule Discount at project Level */
        p_task_sch_discount        	 IN     NUMBER      DEFAULT NULL ,  /* Revenue Non_Labor Schedule Discount at task Level */
 	p_revenue_override_rate     	 IN	NUMBER      DEFAULT NULL,  /*override rate if not null no call to billing internal api.*/
	p_override_currency_code  	 IN	VARCHAR2    DEFAULT NULL, /*override currency Code */
        p_txn_currency_code		 IN	VARCHAR2    DEFAULT NULL,  /* if not null, amounts to be returned in this currency only else in x_txn_curr_code*/
	p_raw_cost                       IN 	NUMBER,		/*If p_raw_cost is only passed,return the burden multiplier, burden_cost */
        p_burden_cost                    IN 	NUMBER      DEFAULT NULL,
	p_raw_revenue                	 IN     NUMBER      DEFAULT NULL,
	p_raw_cost_rate			 IN     NUMBER      DEFAULT NULL,
	x_bill_rate                      OUT NOCOPY NUMBER,
	x_raw_revenue                	 OUT NOCOPY NUMBER,
        x_bill_markup_percentage       	 OUT NOCOPY NUMBER,
	x_txn_curr_code         	 OUT NOCOPY VARCHAR2, /* x_txn_currency_code  for Labor and x_rev_curr_code   for non labor */
        x_return_status              	 OUT NOCOPY VARCHAR2,
        x_msg_data                   	 OUT NOCOPY VARCHAR2,
	x_msg_count                  	 OUT NOCOPY NUMBER
	)
IS
l_x_return_status 				 VARCHAR2(20):=g_success;
l_msg_count 					 NUMBER;
l_msg_data 					 VARCHAR2(1000);
l_called_process 				 VARCHAR2(40);
l_txn_curr_code 				 VARCHAR2(30);
l_rev_curr_code 				 VARCHAR2(30);
l_override_cost 				 NUMBER:=NULL;
l_proj_nl_bill_rate_sch_id 			 NUMBER;
l_task_nl_bill_rate_sch_id 			 NUMBER;
l_txn_bill_rate                                  NUMBER:=NULL;
l_txn_bill_markup 				 NUMBER:=NULL;
l_raw_revenue 					 NUMBER:=NULL;
l_txn_raw_revenue 				 NUMBER;
l_sl_function 					 NUMBER ;
l_exp_func_Curr_code 				 VARCHAR2(30);
l_project_curr_code					 VARCHAR2(30);
l_projfunc_curr_code					VARCHAR2(30);
l_project_raw_cost					NUMBER;
l_project_raw_cost_rate					NUMBER;
l_project_burdened_cost					NUMBER;
l_project_burdened_cost_rate				NUMBER;
l_projfunc_raw_cost					NUMBER;
l_projfunc_raw_cost_rate				NUMBER;
l_projfunc_burdened_cost				NUMBER;
l_projfunc_burdened_cost_rate				NUMBER;
l_convert_return_status					VARCHAR2(30):= g_success;
l_error_msg_code					VARCHAR2(2000);
l_uom							VARCHAR2(30);
l_uom_flag						NUMBER:=1;
l_txn_adjusted_bill_rate                                NUMBER:=NULL;--4038485
l_quantity NUMBER:=NULL;                  --bug#4284806

BEGIN
        IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Validating all the input parameters';
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;


	IF p_system_linkage='BTC' THEN
	  l_override_cost := p_burden_cost;
          l_sl_function :=6;
	ELSE
	  l_override_cost := p_raw_cost;
          l_sl_function :=2;
	END IF;

   IF p_revenue_override_rate IS NOT NULL  AND  p_override_currency_code  IS NULL THEN
        IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Validating Get_plan_actual_rev_Rates:p_override_currency_code is required if passing any overrides';
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;
      RAISE l_invalid_currency;
   END IF;
   IF p_rate_based_flag ='Y' AND p_quantity IS NULL
   AND NVL(l_override_cost,0)=0 THEN
         IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Validating Get_plan_actual_rev_Rates:p_quantity is required for rate based';
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;
      RAISE l_rate_based_no_quantity;
    END IF;
    /* If revenue Override rate is not null compute the raw_revenue based on the override rate and the p_quantity or rawCost */
    IF p_revenue_override_rate IS NOT NULL THEN
        SELECT p_revenue_override_rate  b_rate,
                PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((p_revenue_override_rate * p_quantity), p_override_currency_code)  r_revenue,
                p_override_currency_code
          INTO l_txn_bill_rate,l_raw_revenue,l_txn_curr_code
	  FROM dual;
	  l_txn_raw_revenue:=l_raw_revenue;

     END IF;/* End of check for p_revenue_override_rate */
      /* If in the above case the Raw Revenue is null then go for calling
      actual internal api of billing to compute the raw Revenue */

   IF l_raw_revenue IS NULL THEN

       IF p_task_Id IS NOT NULL THEN
         l_called_process := 'TASK_LEVEL_PLANNING';
      ELSE
         l_called_process := 'PROJECT_LEVEL_PLANNING';
      END IF;
/*bug#4284806  If  the transaction is  non rate based which means the UOM is currency , then during revenue rate derivation ,
   for both actuals and resource class and for both labor ( people ) and non labor resource class  you should ignore rate,
   if the setup is rate.

   So setting the p_quanity to null for non-rate based transaction*/

IF p_rate_based_flag ='Y' THEN
    l_quantity:=p_quantity;
else
    l_quantity:=null;
end if;

      /* Going to Call the Core Billing API for Revenue Calculation based on the Resource Class */
      IF p_resource_class='PEOPLE' THEN
         IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Calling PA_REVENUE.Assignment_Rev_Amt';
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;

         PA_REVENUE.Assignment_Rev_Amt(
                   p_project_id                  => p_project_id                   ,
                   p_task_id                     => p_task_id                      ,
                   p_bill_rate_multiplier        => p_bill_rate_multiplier         ,
                   p_quantity                    => l_quantity                     ,
                   p_person_id                   => p_person_id                    ,
                   p_raw_cost                    => p_raw_cost,
                   p_item_date                   => p_item_date                    ,
                   p_labor_schdl_discnt          => p_labor_schdl_discnt           ,
                   p_labor_bill_rate_org_id      => p_labor_bill_rate_org_id       ,
                   p_labor_std_bill_rate_schdl   => p_labor_std_bill_rate_schdl    ,
                   p_labor_schdl_fixed_date      => p_labor_schdl_fixed_date   ,
                   p_bill_job_grp_id             => p_bill_job_grp_id      ,
                   p_item_id                     => p_assignment_id ,
                   p_forecast_item_id            => p_planning_transaction_id ,
                   p_labor_sch_type              => p_labor_sch_type          ,
                   p_project_org_id              => p_project_org_id               ,
                   p_project_type                => p_project_type                 ,
                   p_expenditure_type            => p_expenditure_type             ,
                   p_exp_func_curr_code          => p_txn_currency_code    ,
                   p_incurred_by_organz_id       => p_incurred_by_organz_id  ,
                   p_raw_cost_rate               => p_raw_cost_rate  ,
                   p_override_to_organz_id       => p_override_to_organz_id     ,
                   p_emp_bill_rate_schedule_id   => p_rev_emp_rate_sch_id   ,
                   p_job_bill_rate_schedule_id   => p_rev_job_rate_sch_id,
                   p_resource_job_id             => p_job_id              ,
                   p_exp_raw_cost                => p_raw_cost       ,
                   p_expenditure_org_id          => p_expenditure_org_id          ,
                   p_projfunc_currency_code      => p_txn_currency_code,
                   p_assignment_precedes_task    => p_assignment_precedes_task  ,
                   p_sys_linkage_function        => p_system_linkage,
                   p_called_process              => l_called_process ,
		   p_project_raw_cost		 => l_project_raw_cost,
		   p_project_currency_code	 => p_txn_currency_code,
		   p_denom_raw_cost		 => p_raw_cost,
		   p_denom_curr_code    	 => p_txn_currency_code,
		   p_mcb_flag                     => NULL,
                   x_bill_rate                   => l_txn_bill_rate ,
		   x_adjusted_bill_rate           => l_txn_adjusted_bill_rate , --4038485
                   x_raw_revenue                 => l_txn_raw_revenue,
                   x_markup_percentage           => l_txn_bill_markup ,
                   x_txn_currency_code           => l_txn_curr_code,
                   x_rev_currency_code           => l_rev_curr_code ,
                   x_return_status               => l_x_return_status            ,
                   x_msg_count                   => l_msg_count                  ,
                   x_msg_data                    => l_msg_data	  );
             IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='assignment_Rev_amount :l_return_status'||l_x_return_status||'l_msg_data'||l_msg_data||'l_raw_revenue'||l_txn_raw_revenue||'l_bill_rate'||l_txn_bill_rate||'l_bill_markup'||l_txn_bill_markup;
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
              END IF;


		  if NVL(p_rate_based_flag,'N') =  'N'  then
                          l_txn_bill_rate := NULL;
                          l_txn_adjusted_bill_rate:=NULL;
                    end if;
	  	 /* Rasising the Billing Exception to pass the error values to the Main Api */
  	     IF   l_x_return_status <> g_success THEN
	  	      RAISE   l_bill_api;
	     END IF;

      ELSE

          /* Expenditure Type is checked for UOM determination and to calculate p_uom_flag */
	   IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='========g_expenditure_type_tbl.COUNT'||g_expenditure_type_tbl.COUNT;
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;

          FOR i IN g_expenditure_type_tbl.FIRST .. g_expenditure_type_tbl.LAST LOOP
          IF   p_expenditure_type =g_expenditure_type_tbl(i) THEN
                IF g1_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='expendirure Type is::::'|| g_expenditure_type_tbl(i) ;
                  pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
               END IF;
	      IF g_uom_tbl.EXISTS(i) THEN
                l_uom := g_uom_tbl(i);
              END IF;
	    EXIT;
          END IF;
         END LOOP;

        IF l_uom<>p_uom THEN
          l_uom_flag:=0 ;
        ELSE
        l_uom_flag:=1 ;
       END IF;
         IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='l_uom is::::::'|| l_uom||'p_uom '||p_uom||'l_uom_flag'||l_uom_flag ;
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;


            IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Before Calling pa_revenue.Non_Labor_Rev_amount';
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;

          pa_revenue.Non_Labor_Rev_amount(
                                 p_called_process               =>l_called_process ,
                                 p_project_id                   => p_project_id,
                                 p_task_id                      => p_task_id,
                                 p_bill_rate_multiplier         => p_bill_rate_multiplier,
                                 p_quantity                     => l_quantity,
                                 p_raw_cost                     => p_raw_cost,
                                 p_burden_cost                  => p_burden_cost,
                                 p_denom_raw_cost               => p_raw_cost,
                                 p_denom_burdened_cost          => p_burden_cost,
                                 p_expenditure_item_date        => p_item_date,
                                 p_task_bill_rate_org_id        => p_task_bill_rate_org_id ,
                                 p_project_bill_rate_org_id     => p_project_bill_rate_org_id ,
                                 p_task_nl_std_bill_rate_sch_id => p_rev_task_nl_rate_sch_id,
                                 p_proj_nl_std_bill_rate_sch_id => p_rev_proj_nl_rate_sch_id,
                                 p_project_org_id               => p_project_org_id,
                                 p_sl_function                  => l_sl_function,
                                 p_denom_currency_code          => p_txn_currency_code,
                                 p_proj_func_currency           => p_txn_currency_code,
				 p_proj_func_burdened_cost      => p_burden_cost,
                                 p_expenditure_type             => p_expenditure_type,
                                 p_non_labor_resource           => p_non_labor_resource,
                                 p_task_sch_date                => p_task_sch_date ,
                                 p_project_sch_date             => p_project_sch_date ,
                                 p_project_sch_discount         => p_project_sch_discount,
                                 p_task_sch_discount            => p_task_sch_discount,
                                 p_mcb_flag                     => NULL,--p_mcb_flag,
				 p_uom_flag                     => l_uom_flag,
                                 p_non_labor_sch_type           => p_non_labor_sch_type,
                                 p_project_type                 => p_project_type,
                                 p_exp_raw_cost                 => p_raw_cost,
                                 p_raw_cost_rate                => p_raw_cost_rate,
                                 p_incurred_by_organz_id        => p_incurred_by_organz_id,
                                 p_override_to_organz_id        => p_override_to_organz_id,
                                 px_exp_func_curr_code          => l_exp_func_Curr_code,
                                 x_raw_revenue                  => l_txn_raw_revenue,
			         x_rev_curr_code                => l_txn_Curr_code,
                                 x_bill_rate                    => l_txn_bill_rate,
				 x_adjusted_bill_rate           => l_txn_adjusted_bill_rate , --4038485
                                 x_markup_percentage            => l_txn_bill_markup,
                                 x_return_status                => l_x_return_status,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data);
              IF g1_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Non_Labor_Rev_amount :l_return_status'||l_x_return_status||'l_msg_data'||l_msg_data||'l_raw_revenue'||l_txn_raw_revenue||'l_bill_rate'||l_txn_bill_rate||'l_bill_markup'||l_txn_bill_markup;
                 pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
              END IF;
	       if NVL(p_rate_based_flag,'N') =  'N'  then
                          l_txn_bill_rate := NULL;
                          l_txn_adjusted_bill_rate:=NULL;
               end if;
	     /* Raising the Billing Exception to pass the error values to the Main Api */
  	     IF   l_x_return_status <> g_success THEN
	  	     RAISE   l_bill_api;
	     END IF;

      END IF;/*IF p_resource_class='PEOPLE' THEN */
   END IF;/* End if of l_raw_revenue IS NULL THEN*/

     IF g1_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Get_Plan_Actual_Rev_Rates :l_raw_revenue'||l_txn_raw_revenue||'l_bill_rate:'||l_txn_bill_rate||'l_bill_markup:'||l_txn_bill_markup||'l_txn_adjusted_bill_rate:'||l_txn_adjusted_bill_rate;
                 pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
              END IF;
    x_raw_revenue 		 :=l_txn_raw_revenue;
    x_bill_rate	  		 :=NVL(l_txn_adjusted_bill_rate,l_txn_bill_rate) ;--4038485
    x_bill_markup_percentage     :=l_txn_bill_markup;
    x_txn_curr_code              :=l_txn_curr_code;
    x_return_status              :=l_x_return_status;

EXCEPTION
   WHEN l_bill_api THEN
      x_raw_revenue 		     :=NULL;
      x_bill_rate	  	     :=NULL;
      x_bill_markup_percentage       :=NULL;
      x_txn_curr_code         	     :=NULL;
      x_return_status                := g_error;
      x_msg_data                     := l_msg_data;
      x_msg_count                    := l_msg_count;

      IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Billing api is throwing error :p_project_id'||p_project_id||'p_task_id'||p_task_id;
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
      END IF;

  WHEN l_rate_based_no_quantity THEN
      x_raw_revenue 		     :=NULL;
      x_bill_rate	  	     :=NULL;
      x_bill_markup_percentage       :=NULL;
      x_txn_curr_code         	     :=NULL;
      x_return_status                := g_error;
      x_msg_data      		     := 'PA_EX_QTY_EXIST';
      x_msg_count                    := 1;

       IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Quantity is not passed to a rate based tranaction to the Get_Plan_Actual_Rev_Rates call';
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
       END IF;
 WHEN l_invalid_currency THEN
      x_raw_revenue 		     :=NULL;
      x_bill_rate	  	     :=NULL;
      x_bill_markup_percentage       :=NULL;
      x_txn_curr_code         	     :=NULL;
      x_return_status                := g_error;
      x_msg_data      		     := 'PA_INVALID_DENOM_CURRENCY';
      x_msg_count                    := 1;

       IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Override Currency  is not passed to a rate based tranaction to the Get_Plan_Actual_Rev_Rates call';
              pa_debug.write('Get_plan_actual_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
       END IF;


END Get_Plan_Actual_Rev_Rates;

--
-- Procedure            : Get_plan_res_class_rates
-- Purpose              :This procedure will calculate the raw revenue and bill amount from one of the 12
--                       criterias on the basis of passed parameters
-- Parameters           :
--

PROCEDURE Get_plan_res_class_rates  (
        p_project_type			 IN	VARCHAR2,
	p_project_id                   	 IN     NUMBER,
	p_task_id                        IN     NUMBER      DEFAULT NULL,
	p_person_id                    	 IN     NUMBER,
	p_job_id                         IN     NUMBER      DEFAULT NULL,
	p_resource_class        	 IN     VARCHAR2,                /* resource_class_code for Resource Class */
    p_use_planning_rates_flag    	 IN     VARCHAR2    DEFAULT 'N',  /* Rate using Actual Rates */
    p_rate_based_flag		 IN     VARCHAR2    DEFAULT 'Y', /* to identify a rate based transaction */
	p_uom			    	 IN     VARCHAR2,		 /* Planning UOM */
	p_project_organz_id            	 IN     NUMBER	DEFAULT NULL,   /* For revenue calculation use in Resource Class Sch carrying out*/
	p_rev_res_class_rate_sch_id  	 IN     NUMBER	DEFAULT NULL,   /* For Bill Rate Calculations based on Resource Class*/
	p_cost_res_class_rate_sch_id  	 IN     NUMBER	DEFAULT NULL,   /* For Cost Rate Calculations based on Resource Class*/
    p_plan_burden_cost_sch_id         IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on burdening  for planning*/
	p_cost_rate_multiplier           IN     NUMBER  DEFAULT 1,	/* p_bill_rate_multiplier or p_cost_rate_multiplier */
        p_bill_rate_multiplier           IN     NUMBER  DEFAULT 1,	/* p_bill_rate_multiplier or p_cost_rate_multiplier */
        p_quantity                  	 IN     NUMBER,
        p_item_date                	 IN     DATE,			/* Used as p_expenditure_item_date for non labor */
        p_schedule_type            	 IN     VARCHAR2 DEFAULT NULL, /* REVENUE OR COST  OR NULL , will calculate both cost and Revenue*/
        p_project_org_id            	 IN     NUMBER,
        p_incurred_by_organz_id     	 IN     NUMBER,
	p_override_to_organz_id    	 IN     NUMBER,
	p_expenditure_org_id        	 IN     NUMBER,
    p_nlr_organization_id            IN     NUMBER      DEFAULT NULL,   /* Org Id of the Non Labor Resource */
        p_override_trxn_cost_rate        IN     NUMBER   DEFAULT NULL,  /*p_override_trxn_cost_rate  for costing */
        p_override_burden_cost_rate   	 IN	NUMBER   DEFAULT NULL, /*override burden multiplier and p_raw_cost is not null calculate x_burden_cost */
        p_override_trxn_bill_rate        IN     NUMBER   DEFAULT NULL,  /*p_override_trxn_bill_rate or for billing */
        p_override_txn_currency_code     IN     VARCHAR2 DEFAULT NULL,
        p_txn_currency_code              IN     VARCHAR2,
        p_raw_cost                       IN     NUMBER,
        p_burden_cost                    IN     NUMBER   DEFAULT NULL,
        p_raw_revenue                	 IN     NUMBER   DEFAULT NULL,
        p_system_linkage		 IN     VARCHAR2,
	p_expenditure_type		 IN     VARCHAR2,
        x_bill_rate                      OUT   NOCOPY  NUMBER,
        x_cost_rate                      OUT   NOCOPY  NUMBER,
        x_burden_cost_rate               OUT   NOCOPY  NUMBER,
	x_burden_multiplier              OUT   NOCOPY  NUMBER,
        x_raw_cost                       OUT   NOCOPY  NUMBER,
        x_burden_cost                    OUT   NOCOPY  NUMBER,
        x_raw_revenue                	 OUT   NOCOPY  NUMBER,
        x_bill_markup_percentage       	 OUT   NOCOPY  NUMBER,
        x_cost_markup_percentage       	 OUT   NOCOPY  NUMBER,
        x_cost_txn_curr_code         	 OUT   NOCOPY  VARCHAR2,
        x_rev_txn_curr_code         	 OUT   NOCOPY  VARCHAR2,
        x_raw_cost_rejection_code        OUT   NOCOPY  VARCHAR2,
        x_burden_cost_rejection_code	 OUT   NOCOPY	VARCHAR2,
        x_revenue_rejection_code	 OUT   NOCOPY	VARCHAR2,
        x_cost_ind_compiled_set_id	 OUT   NOCOPY	NUMBER,
        x_return_status              	 OUT   NOCOPY  VARCHAR2,
        x_msg_count                  	 OUT   NOCOPY  NUMBER,
        x_msg_data                   	 OUT   NOCOPY  VARCHAR2)

IS

l_x_return_status       VARCHAR2(20):=g_success; -- store the return status
l_bill_rate             NUMBER:=NULL;
l_cost_rate             NUMBER:=NULL;
l_adjust_amount         NUMBER :=null;
l_markup		NUMBER :=null;
l_txn_curr_code         pa_bill_rates_all.rate_currency_code%TYPE;
l_raw_revenue           NUMBER :=null; -- store the raw revenue
l_true		     	BOOLEAN := FALSE;
l_txn_raw_revenue       NUMBER :=null; -- store the raw revenue trans. curr.
l_raw_cost              number := null;
l_burden_cost           number := null;
l_txn_currency_code     pa_bill_rates_all.rate_currency_code%TYPE;
l_inter_txn_curr_code   pa_bill_rates_all.rate_currency_code%TYPE;--4194214
l_burden_cost_rate      NUMBER:=NULL;
l_cost_ind_compiled_set_id	NUMBER;
l_burd_organization_id          NUMBER;
l_x_msg_data                    VARCHAR2(1000);
l_x_msg_count                   NUMBER;
l_schedule_type			VARCHAR2(60);
l_burd_sch_id                   NUMBER;
l_burd_sch_rev_id		NUMBER;
l_burd_sch_fixed_date		DATE;
l_burd_sch_cost_base		VARCHAR2(1000);
l_burd_sch_cp_structure		VARCHAR2(1000);
l_txn_burden_multiplier         NUMBER :=null;
l_cost_return_status		VARCHAR2(1):=g_success;
l_cost_msg_data			VARCHAR2(1000);
l_txn_burden_cost_rate		NUMBER :=null;
l_cost_txn_curr_code		VARCHAR2(50);
l_txn_burden_cost		NUMBER :=null;
l_txn_raw_cost		        NUMBER :=null;
l_txn_cost_rate		        NUMBER:=NULL;
l_burden_cost_rejection_code	VARCHAR2(50);
l_bill_txn_curr_code           pa_bill_rates_all.rate_currency_code%TYPE;
l_inter_return_status		VARCHAR2(1):=null;
l_calling_mode  VARCHAR2(20):=null;
l_override_organization_id  NUMBER;
l_ovr_return_status         VARCHAR2(20):=g_success;
l_ovr_msg_count             NUMBER;
l_ovr_msg_data              VARCHAR2(1000);

BEGIN

   pa_debug.init_err_stack('PA_PLAN_REVENUE.Get_plan_res_class_rates');

    IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters:->p_schedule_type'||p_schedule_type||'p_rate_based_flag'||p_rate_based_flag||'p_uom'||p_uom||'p_raw_cost'||p_raw_cost||'p_raw_revenue'||p_raw_revenue;
       pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
       IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters:->p_use_planning_rates_flag '||p_use_planning_rates_flag ||'p_plan_burden_cost_sch_id '||p_plan_burden_cost_sch_id  ;
       pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
       IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters:->p_nlr_organization_id '||p_nlr_organization_id ||'p_expenditure_org_id '||p_expenditure_org_id ||'p_override_to_organz_id '||p_override_to_organz_id;
       pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

  IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters:->p_rev_res_class_rate_sch_id  '||p_rev_res_class_rate_sch_id ||'p_incurred_by_organz_id'||p_incurred_by_organz_id ;
       pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
   /* Assigning the parameters to local variables */
       l_burden_cost        :=p_burden_cost;
       l_raw_cost           := p_raw_cost;
       l_cost_rate          := p_override_trxn_cost_rate;
       l_bill_rate          := p_override_trxn_bill_rate;
       l_override_organization_id  :=p_override_to_organz_id;
       l_txn_curr_code :=p_txn_currency_code; --bug#4317221
       if p_use_planning_rates_flag  ='Y' then
          l_calling_mode       :='PLAN_RATES';
       else
          l_calling_mode       :='ACTUAL_RATES';
       end if;

       l_raw_revenue        :=p_raw_revenue;
    /* Validating all the required Parameters */
   IF  p_resource_class IS NULL OR p_item_date IS  NULL
   OR  p_uom IS NULL THEN
       IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='validating Get_plan_res_class_rates: either p_resource_class or p_item_date or p_uom is null ';
       pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
       END IF;
       RAISE  l_insufficeient_param;
   ELSE
      null;
   END IF;/* Check for mandatory parameters done */

     /* First computing the raw_cost if p_schedule_type is passed COST or NULL
     If COST is passed then it'll compute only Costing but if passed nll it'll
     compute both Costing as well as Revenue */
      IF g1_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Calculating Costing data';
       pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
     END IF;

      IF l_override_organization_id is NULL and p_resource_class = 'PEOPLE' Then
          IF g1_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Calling pa_cost.Override_exp_organization api';
             pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
          end if;
           BEGIN
                                pa_cost.Override_exp_organization
                                (P_item_date                  => p_item_date
                                ,P_person_id                  => p_person_id
                                ,P_project_id                 => p_project_id
                                ,P_incurred_by_organz_id      => p_incurred_by_organz_id
                                ,P_Expenditure_type           => p_expenditure_type
                                ,X_overr_to_organization_id   => l_override_organization_id
                                ,X_return_status              => l_ovr_return_status
                                ,X_msg_count                  => l_ovr_msg_count
                                ,X_msg_data                   => l_ovr_msg_data
                                );
           EXCEPTION
  	           WHEN OTHERS THEN
  		          IF g1_debug_mode = 'Y' THEN
		            pa_debug.g_err_stage:='pa_cost.Override_exp_organization is throwing When Others'||SUBSTR(SQLERRM,1,250);
		            pa_debug.write('Get_plan_res_class_Rates : ' || g_module_name,pa_debug.g_err_stage,1);
  		          END IF;
 	       END;

           IF g1_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Return status of pa_cost.Override_exp_organization ['||l_ovr_return_status||
                                ']msgData['||l_ovr_msg_data||']OverideOrg['||l_override_organization_id||']' ;
             pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
           end if;

     End If;

   IF NVL(p_schedule_type,'COST')='COST' THEN
   --13.02
    IF l_cost_rate IS NOT NULL AND  l_raw_cost IS NULL THEN
          IF NVL(p_rate_based_flag,'N')='Y' THEN
           l_raw_cost :=l_cost_rate*p_quantity;
	   END IF;
       END IF;
     --13.02
      IF l_raw_cost IS NULL THEN
	  IF p_rate_based_flag ='Y' THEN
              IF p_quantity IS NULL THEN
	             IF g1_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='validating Get_plan_res_class_rates: p_quantity is required for rate based ';
                  pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
	             RAISE  l_rate_based_no_quantity;
              END IF;
           END IF;
         BEGIN
           DECLARE
              l_class_org_rate            NUMBER:=NULL;
              l_class_org_markup          NUMBER:=NULL;
              l_class_org_uom             pa_bill_rates_all.bill_rate_unit%TYPE :=NULL;
              l_class_org_rate_curr_code  pa_bill_rates_all.rate_currency_code%TYPE :=NULL;
              l_class_org_return_status   VARCHAR2(20):= g_success;
              l_class_org_return_data     VARCHAR2(30);
              l_class_org_return_count    NUMBER;
              l_item_date                 DATE := p_item_date;
              l_res_class_org_id          NUMBER := NVL (l_override_organization_id ,NVL(p_incurred_by_organz_id,p_project_organz_id));
           BEGIN
              IF g1_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Callling Get_Res_Class_Hierarchy_Rate:p_project_id'||p_project_id||'p_task_id'||p_task_id;
                 pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
              END IF;
              Get_Res_Class_Hierarchy_Rate(   p_res_class_rate_sch_id  => p_cost_res_class_rate_sch_id,
                                   	      p_item_date              => l_item_date,
                                              p_org_id                 => p_project_org_id ,
                    		              p_resource_class_code    => p_resource_class,
                	                      p_res_class_org_id       => l_res_class_org_id,
                                	      x_rate                   => l_class_org_rate ,
                                	      x_markup_percentage      => l_class_org_markup,
                            		       x_uom  		       => l_class_org_uom,
                                               x_rate_currency_code    => l_class_org_rate_curr_code,
                            		       x_return_status         => l_class_org_return_status,
                            		       x_msg_count             => l_class_org_return_count,
                            		       x_msg_data              => l_class_org_return_data);

		  /* Checking the status if the above proc has return no rate then no need to call the block*/
              IF l_class_org_return_status = g_success THEN

                 DECLARE

			     CURSOR C_std_res_class_sch_cost IS
				    SELECT DECODE  (p_uom,'DOLLARS',1, DECODE(p_uom,l_class_org_uom,l_class_org_rate  * NVL(p_cost_rate_multiplier,1),null)) b_rate,
                        DECODE  (p_uom,'DOLLARS',PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(p_quantity ,l_class_org_rate_curr_code)
                                               ,DECODE(p_uom,l_class_org_uom,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(l_class_org_rate  * NVL(p_cost_rate_multiplier,1)
                                                                       * p_quantity, l_class_org_rate_curr_code),null)
                               ) r_cost,
                       l_class_org_rate_curr_code rate_currency_code
		            FROM dual;


                 BEGIN
 	 		        -- Opening cursor and fetching row
			        OPEN  C_std_res_class_sch_cost ;
	                -- Assigning the Calculated raw revenue/adjusted to the local variable
                    FETCH C_std_res_class_sch_cost INTO l_cost_rate,l_raw_cost,l_txn_curr_code;
                    CLOSE C_std_res_class_sch_cost ;

                    IF g1_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='1002 cost rate : ' || l_cost_rate  || 'Raw Cost : '
             		      || l_raw_cost || 'currency_code : ' || l_txn_curr_code;
                      pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
                     END IF;
                 END;/*End of declare of cursor declaration for res_class_org_id*/
               END IF;/* End of Status check of Hierarcy Rate Procedure */
           END;/* End of proceduer call BEGIN */


        /* Getting the Rates and Revenue if the Rate is not present at the Resource Class and Res_class_organization_id Level */
        IF l_raw_cost  IS NULL THEN
           DECLARE
              CURSOR C_std_res_class_sch_cost IS
		      SELECT DECODE  (p_uom,'DOLLARS', 1,DECODE(p_uom,b.bill_rate_unit,b.rate * NVL(p_cost_rate_multiplier,1),null)) b_rate,
                       DECODE  (p_uom,'DOLLARS', PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(p_quantity ,b.rate_currency_code)
                                               ,DECODE(p_uom,b.bill_rate_unit,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_cost_rate_multiplier,1)
                                                       * p_quantity, b.rate_currency_code),null)
                               ) r_cost,
                       DECODE(p_uom,'DOLLARS', b.rate_currency_code,b.rate_currency_code) rate_currency_code
		      FROM   pa_std_bill_rate_schedules_all sch,pa_bill_rates_all b
              WHERE sch.bill_rate_sch_id=p_cost_res_class_rate_sch_id
              AND   sch.bill_rate_sch_id=b.bill_rate_sch_id
              AND   b.resource_class_code = p_resource_class
              AND   sch.schedule_type = 'RESOURCE_CLASS'
              AND   b.res_class_organization_id IS NULL
              AND   trunc(p_item_date)
              BETWEEN trunc(b.start_date_active)
                  AND NVL(trunc(b.end_date_active),trunc(p_item_date));


           BEGIN

 	 		  -- Opening cursor and fetching row
			  FOR Rec_std_res_class_sch_cost IN C_std_res_class_sch_cost LOOP
	          -- Checking if the cursor is returning more than one row then error out
	          IF (l_true) THEN
	             RAISE l_more_than_one_row_excep;
	          ELSE
	             l_true := TRUE;
	          END IF;

	          -- Assigning the Calculated raw cost to the local variable
                   l_cost_rate       := Rec_std_res_class_sch_cost.b_rate;
	           l_raw_cost        := Rec_std_res_class_sch_cost.r_cost;
		   l_txn_curr_code   := Rec_std_res_class_sch_cost.rate_currency_code;
              END LOOP;
                IF g1_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='1002 cost rate : ' || l_cost_rate  || 'Raw Cost : '
		              || l_raw_cost || 'currency_code : ' || l_txn_curr_code;
                    pa_debug.write('Get_Res_Class_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;

           EXCEPTION
              WHEN l_more_than_one_row_excep THEN
               x_raw_cost:= NULL;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               x_msg_count     := 1;
               x_msg_data      := 'TOO_MANY_ROWS';
	       x_raw_cost_rejection_code :='TOO_MANY_ROWS';
             IF g1_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
               pa_debug.write('Get_Res_Class_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
              END IF;
  	          RAISE;
  	       END;/*End of decalre cursor*/

           IF ( l_raw_cost IS NULL)   THEN
              RAISE l_no_cost;
           END IF;

           IF g1_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='9999  l_cost_rate: ' || l_cost_rate||
            	 'raw_cost : ' ||l_raw_cost || 'currency_code : ' || l_txn_curr_code;
             pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;

        END IF;/* End of  IF l_raw_cost */

        EXCEPTION
           WHEN l_no_cost THEN
              x_raw_cost:= NULL;
              l_inter_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_data:=  'PA_FCST_NO_COST_RATE';
              x_raw_cost_rejection_code :=  'PA_FCST_NO_COST_RATE';
              x_msg_count     := 1;
              IF g1_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='No Cost Rate Exists:p_project_id'||p_project_id||'p_task_id'||p_task_id;
                 pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
              END IF;

          WHEN OTHERS THEN
             x_raw_cost:= NULL;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM,1,30);
             x_raw_cost_rejection_code := SUBSTR(SQLERRM,1,30);

             IF g1_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                pa_debug.write('Get_Res_Class_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
             END IF;

             RAISE;

         END;/* End of Begin for Revenue Scedule Type */
     ELSE
	     IF  NVL(p_quantity,1) <>0 THEN
	     l_cost_rate:=NVL(p_override_trxn_cost_rate,l_raw_cost/p_quantity);
	     ELSE
	       l_cost_rate:=p_override_trxn_cost_rate;
           END IF;

     END IF;/* End of l_raw_cost */

   END IF; /*End if of l_schedule_type=Cost */


/*==========================================================================================*/
   /* If from the above raw_cost is computed and it needs to compute the burden cost on it
	   then the folowing code will be executed */
 	IF l_burden_cost is NOT NULL Then

	    --assigning override burden cost/or derived burden cost from Actual
	   IF g1_debug_mode = 'Y' THEN
  	      pa_debug.g_err_stage := 'Assignging override burden cost values to out params';
              pa_debug.write('Get_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;
	   l_txn_burden_cost :=l_burden_cost;
	   IF (p_quantity <> 0 ) THEN
		   l_txn_burden_cost_rate :=  l_burden_cost / NVL(p_quantity,1) ;
	END IF;
        IF NVL(l_raw_cost,0)<>0 THEN
	   l_txn_burden_multiplier := (l_burden_cost/l_raw_cost)-1;
	END IF;

	ElsIf ( p_override_burden_cost_rate is NULL and  l_burden_cost is NULL
	 and   l_raw_cost is NOT NULL and l_cost_rate is NOT NULL
	 and   pa_cost1.check_proj_burdened(p_project_type,p_project_id) = 'Y' ) Then
		l_burd_organization_id := NVL(l_override_organization_id, NVl(p_incurred_by_organz_id ,p_nlr_organization_id));
	       IF g1_debug_mode = 'Y' THEN
  	         pa_debug.g_err_stage := 'calling pa_cost1.Get_burden_sch_details fro  burden cost';
                 pa_debug.write('Get_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
               END IF;

begin

		pa_cost1.Get_burden_sch_details
                (p_calling_mode                 =>l_calling_mode
                ,p_exp_item_id                  => NULL
                ,p_trxn_type                    => NULL
                ,p_project_type                 => p_project_type
                ,p_project_id                   => p_project_id
                ,p_task_id                      => p_task_id
                ,p_exp_organization_id          => l_burd_organization_id
		        ,p_expenditure_type             => p_expenditure_type
                ,p_schedule_type                => 'COST'
                ,p_exp_item_date                => p_item_date
                ,p_trxn_curr_code               => NVL(l_txn_curr_code,p_override_txn_currency_code)
                ,p_burden_schedule_id           => p_plan_burden_cost_sch_id
                ,x_schedule_id                  => l_burd_sch_id
                ,x_sch_revision_id              => l_burd_sch_rev_id
                ,x_sch_fixed_date               => l_burd_sch_fixed_date
                ,x_cost_base                    => l_burd_sch_cost_base
                ,x_cost_plus_structure          => l_burd_sch_cp_structure
                ,x_compiled_set_id              => l_cost_ind_compiled_set_id
                ,x_burden_multiplier            => l_txn_burden_multiplier
                ,x_return_status                => l_cost_return_status
                ,x_error_msg_code               => l_cost_msg_data
		);

exception
when others  then

l_cost_return_status := 'E';
l_cost_msg_data := 'GET_BURDEN_DETAILS: '||substr(sqlerrm,1,30);
end;
		If ( l_cost_return_status <> g_success OR l_txn_burden_multiplier is NULL ) Then
			IF g1_debug_mode = 'Y' THEN
  	              	   pa_debug.g_err_stage := 'Error while Calculating burden costs';
                           pa_debug.write('Get_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;
                      l_burden_cost_rejection_code := l_cost_msg_data;

                -------------------------------------------------------
                -- Get Burden Cost and rate from Raw Cost and Quantity.
                -------------------------------------------------------
		ELSE

                     l_txn_burden_cost := pa_currency.round_trans_currency_amt(
                                            l_raw_cost * NVL(l_txn_burden_multiplier,0),NVL(l_txn_curr_code,p_override_txn_currency_code )) +
                                            l_raw_cost ;

                     /*bug3749153 no need to compute the burden cost rate if it equals raw_cost_rate */
                       If l_txn_burden_cost = l_raw_cost Then
                          l_txn_burden_cost_rate  := l_cost_rate;
                       Else
                         IF (p_quantity <> 0 ) THEN
                          l_txn_burden_cost_rate  := l_txn_burden_cost / NVL(P_quantity, 1) ;
                          END IF;
                        End if;
               end if;
	Elsif p_override_burden_cost_rate is NOT NULL and  l_burden_cost is NULL Then
			IF g1_debug_mode = 'Y' THEN
  	              	   pa_debug.g_err_stage := 'Calculating burden cost based on override burden multiplier ';
                           pa_debug.write('Get_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;

                   l_txn_burden_cost := p_quantity * p_override_burden_cost_rate;
		   l_txn_burden_cost_rate :=  p_override_burden_cost_rate;
		   IF NVL(l_raw_cost,0)<>0 THEN
           	        l_txn_burden_multiplier := ( l_txn_burden_cost / l_raw_cost)-1;
              	   END IF;

	ElsIF l_raw_cost IS NOT NULL THEN
		--copy the raw cost to the burden costs
		IF g1_debug_mode = 'Y' THEN
          		pa_debug.g_err_stage := 'Copying raw costs to burden costs';
                        pa_debug.write('Get_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;
		l_txn_burden_cost := l_raw_cost;
		l_txn_burden_cost_rate := l_cost_rate;
		l_txn_burden_multiplier := 0;

	End IF;

        /* Burden Cost Calucltaion complete */
/*==========================================================================================*/
l_inter_txn_curr_code :=NVL(l_txn_curr_code,p_override_txn_currency_code) ; --4194214
      /* Assigning out all the Cost and Burden Cost Parameters */
           x_raw_cost           := l_raw_cost ;
           x_cost_rate          := l_cost_rate  ;
	   x_burden_cost        := l_txn_burden_cost;
	   x_burden_cost_rate   := l_txn_burden_cost_rate  ;
	   x_burden_multiplier  := l_txn_burden_multiplier;
           x_cost_txn_curr_code := l_inter_txn_curr_code;--NVL(l_txn_curr_code,p_override_txn_currency_code)  ;--4194214
           x_return_status      :=  NVL(l_inter_return_status,l_x_return_status);
	   l_inter_return_status      := NVL(l_inter_return_status,l_x_return_status);
 	   x_burden_cost_rejection_code:=  l_burden_cost_rejection_code;

   /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
                IF g1_debug_mode = 'Y' THEN
          		pa_debug.g_err_stage := 'Going to calculate revenue:->p_schedule_type'||p_schedule_type||'l_raw_revenue'||l_raw_revenue||'l_raw_cost'||l_raw_cost||'l_txn_burden_cost'||l_txn_burden_cost;
                        pa_debug.write('Get_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;

   IF NVL(p_schedule_type,'REVENUE')='REVENUE' THEN
      IF p_system_linkage='BTC' THEN
        l_raw_cost:= NVL(l_txn_burden_cost,p_burden_cost);
	ELSE
        l_raw_cost:= NVL(l_raw_cost,p_raw_cost);
      END IF;
     /* This code is added beacuse if you choose to calculate only REVENUE then for Non-Rate based transaction it might happen that the
       l_raw_cost is null since we have not called the COSTing api to compute the  cost so just assigning p_quantity to l_raw_cost
       as l_raw_cost is used in the revenue calculation if its non-Rate based transaction */
      IF p_schedule_type ='REVENUE' AND l_raw_cost IS NULL THEN
        IF NVL(p_rate_based_flag,'N') ='N' THEN
           l_raw_cost:=p_quantity;
	END IF;
	    IF g1_debug_mode = 'Y' THEN
          		pa_debug.g_err_stage := 'p_quanity is directly getting converted to l_raw_cost for only REVENUE mode:l_raw_cost'||l_raw_cost;
                        pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,3);
             END IF;
      END IF;

      IF  l_raw_revenue IS NULL THEN
          l_true := FALSE;
          IF NVL(p_rate_based_flag,'N') ='N' AND l_raw_cost IS NULL THEN
            RAISE  l_no_cost;
          END IF;
      IF p_rate_based_flag ='Y' THEN
              IF p_quantity IS NULL   THEN
	             IF g1_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='validating Get_plan_res_class_rates: p_quantity is required for rate based ';
                   pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
	             RAISE  l_rate_based_no_quantity;
              END IF;
           END IF;



      IF l_bill_rate IS NOT NULL AND  l_raw_revenue IS NULL THEN
          l_raw_revenue :=l_bill_rate*p_quantity;
       END IF;


         BEGIN
            DECLARE
               l_class_org_rate            NUMBER:=NULL;
               l_class_org_markup          NUMBER:=NULL;
               l_class_org_uom             pa_bill_rates_all.bill_rate_unit%TYPE :=NULL;
               l_class_org_rate_curr_code  pa_bill_rates_all.rate_currency_code%TYPE :=NULL;
               l_class_org_return_status   VARCHAR2(1):= g_success;
               l_class_org_return_data     VARCHAR2(30);
               l_class_org_return_count    NUMBER;
               l_item_date                 DATE := p_item_date;
              -- bug 9167821 skkoppul : added to get the override org, incurred org or project org in the order if null
              l_res_class_org_id          NUMBER := NVL(l_override_organization_id ,NVL(p_incurred_by_organz_id,p_project_organz_id));

            BEGIN
	    IF l_raw_revenue IS NULL THEN  --4108291
               Get_Res_Class_Hierarchy_Rate(p_res_class_rate_sch_id  => p_rev_res_class_rate_sch_id,
                                 	    p_item_date              => l_item_date,
                                            p_org_id         => p_project_org_id ,
                    		            p_resource_class_code    => p_resource_class,
                	                    p_res_class_org_id       => l_res_class_org_id, -- bug 9167821:replaced p_project_organz_id
                                	    x_rate                   => l_class_org_rate ,
                                	    x_markup_percentage      => l_class_org_markup,
                            		    x_uom  		     => l_class_org_uom,
                                            x_rate_currency_code     => l_class_org_rate_curr_code,
                            		    x_return_status          => l_class_org_return_status,
                            		    x_msg_count              => l_class_org_return_count,
                            		    x_msg_data               => l_class_org_return_data);
              /* Checking the status*/
             IF l_class_org_return_status = g_success THEN

              /* Bug 5048677. Added to check if uom are same then if rate is null
              then compute revenue using mark up or use rate*/

	        DECLARE
                   CURSOR C_std_res_class_sch_rev IS
			   SELECT DECODE  (p_uom,'DOLLARS',NULL,DECODE(p_uom,l_class_org_uom,l_class_org_rate  * NVL(p_bill_rate_multiplier,1),NULL)) b_rate,
                       DECODE  (p_uom,'DOLLARS',PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 +l_class_org_markup)
   	                                	               * (l_raw_cost / 100), l_inter_txn_curr_code) --4194214
                                               ,DECODE(p_uom,l_class_org_uom,decode(l_class_org_rate,null,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 +l_class_org_markup) * (l_raw_cost / 100), l_inter_txn_curr_code),
					       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(l_class_org_rate  * NVL(p_bill_rate_multiplier,1)
                                                                               * p_quantity, l_class_org_rate_curr_code))
									      ,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 +l_class_org_markup)
   	                                	                               * (l_raw_cost / 100), l_inter_txn_curr_code) --4194214
							)
                               ) r_revenue,
                       DECODE(p_uom,'DOLLARS',l_inter_txn_curr_code,DECODE(p_uom,l_class_org_uom,decode(l_class_org_rate,null,l_inter_txn_curr_code,l_class_org_rate_curr_code),l_inter_txn_curr_code)  ) rate_currency_code,
		       DECODE  (p_uom,'DOLLARS',l_class_org_markup,DECODE(p_uom,l_class_org_uom,decode(l_class_org_rate,null,l_class_org_markup,NULL),l_class_org_markup))  markup
		       FROM dual;
                BEGIN
 	 	   -- Opening cursor and fetching row
		   OPEN C_std_res_class_sch_rev;
	           -- Assigning the Calculated raw revenue/adjusted to the local variable
	           FETCH C_std_res_class_sch_rev INTO l_bill_rate ,l_raw_revenue ,l_bill_txn_curr_code,l_markup ;
                   CLOSE C_std_res_class_sch_rev;

                   IF g1_debug_mode  = 'Y' THEN
                     pa_debug.g_err_stage:='1002 bill rate : ' || l_bill_rate  || 'Revenue : '
		          || l_raw_revenue || 'currency_code : ' || l_bill_txn_curr_code;
                     pa_debug.write('Get_plan_Res_Class_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
                   END IF;

        	END;/*End of declare of cursor declaration for C_std_res_class_sch_rev*/

            END IF;/* End of Status check for Get_hierarchy_rate */
	    END IF;/* IF l_raw_revenue IS NULL THEN  4108291*/
         END;/* End of proceduer call BEGIN */

                 l_txn_raw_revenue   := l_raw_revenue;

         /* Getting the Rates and Revenue if the Rate is not present at the Resource Class and Res_class_organization_id Level */
         IF l_txn_raw_revenue  IS NULL THEN
             /* Bug 5048677. Added to check if uom are same then if rate is null
              then compute revenue using mark up or use rate*/
            DECLARE
               CURSOR C_std_res_class_sch_rev IS
			   SELECT DECODE  (p_uom,'DOLLARS',NULL,DECODE(p_uom,b.bill_rate_unit, b.rate * NVL(p_bill_rate_multiplier,1),NULL)) b_rate,
                       DECODE  (p_uom,'DOLLARS',PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
     * (l_raw_cost / 100), l_inter_txn_curr_code)--4194214
                                               ,DECODE(p_uom,b.bill_rate_unit,decode(b.rate,null,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)     * (l_raw_cost / 100), l_inter_txn_curr_code),
					       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                                                 * p_quantity, b.rate_currency_code))
					    ,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
   	                                	               * (l_raw_cost / 100), l_inter_txn_curr_code)--4194214

						      )
                               ) r_revenue,
                       DECODE(p_uom,'DOLLARS',l_inter_txn_curr_code,DECODE(p_uom,b.bill_rate_unit,decode(b.rate,null,l_inter_txn_curr_code,b.rate_currency_code),l_inter_txn_curr_code)  ) rate_currency_code,
                     --  DECODE(p_uom,'DOLLARS', b.rate_currency_code,b.rate_currency_code ) rate_currency_code, --4194214
		       DECODE  (p_uom,'DOLLARS',b.markup_percentage,DECODE(p_uom,b.bill_rate_unit,decode(b.rate,null,b.markup_percentage,NULL),b.markup_percentage))  markup
		       FROM   pa_std_bill_rate_schedules_all sch,pa_bill_rates_all b
               WHERE sch.bill_rate_sch_id=p_rev_res_class_rate_sch_id
               AND   b.bill_rate_sch_id = sch.bill_rate_sch_id
               AND   b.resource_class_code = p_resource_class
               AND   sch.schedule_type = 'RESOURCE_CLASS'
               AND   b.res_class_organization_id IS NULL
               AND   trunc(p_item_date)
               BETWEEN trunc(b.start_date_active)
                AND NVL(trunc(b.end_date_active),trunc(p_item_date));

            BEGIN
		  -- Opening cursor and fetching row
		   FOR Rec_std_res_class_sch_rev IN C_std_res_class_sch_rev LOOP
	           -- Checking if the cursor is returning more than one row then error out
	           IF (l_true) THEN
	              RAISE l_more_than_one_row_excep;
	           ELSE
	              l_true := TRUE;
	           END IF;

	           -- Assigning the Calculated raw revenue/adjusted to the local variable
                    l_bill_rate       := Rec_std_res_class_sch_rev.b_rate;
	            l_raw_revenue     := Rec_std_res_class_sch_rev.r_revenue;
		    l_bill_txn_curr_code   := Rec_std_res_class_sch_rev.rate_currency_code;
		    l_markup       := Rec_std_res_class_sch_rev.markup;

               END LOOP;

               IF g1_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='l_bill_rate: ' || l_bill_rate ||
            	   'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_bill_txn_curr_code;
                  pa_debug.write('Get_plan_res_class_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
               END IF;
            EXCEPTION
               WHEN l_more_than_one_row_excep THEN
                  x_raw_revenue:= NULL;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  x_msg_count     := 1;
                  x_msg_data      := 'TOO_MANY_ROWS';
                  x_revenue_rejection_code := 'TOO_MANY_ROWS';

                  IF g1_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Too many Rows';
                     pa_debug.write('Get_plan_Res_Class_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
                  END IF;

                  RAISE;

	    END;/*End of decalre cursor*/

               l_txn_raw_revenue   := l_raw_revenue;

            IF ( l_txn_raw_revenue IS NULL)   THEN
               RAISE l_no_revenue;
            END IF;

       END IF;/* End of  IF l_txn_raw_revenue */

            x_raw_revenue        := l_txn_raw_revenue ;
            x_bill_rate          := l_bill_rate  ;
	    x_bill_markup_percentage         := l_markup  ;
            x_rev_txn_curr_code      := l_bill_txn_curr_code  ;
            x_return_status      := l_x_return_status;

	     IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='l_bill_rate: ' || l_bill_rate ||
            	 'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_bill_txn_curr_code;
              pa_debug.write('Get_plan_res_class_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;

       EXCEPTION
           WHEN l_no_revenue THEN
              RAISE l_no_revenue;
       END;/* End of Begin for Revenue Scedule Type */
       ELSE

          IF NVL(p_quantity,1)<>0 THEN
          l_bill_rate:=NVL(p_override_trxn_bill_rate,l_raw_revenue/p_quantity);
	  ELSE
            l_bill_rate:=p_override_trxn_bill_rate;
	  END IF;

	 END IF;/* end if of IF l_raw_revenue I NULL */
     ELSE
        l_bill_rate:=p_override_trxn_bill_rate;
    END IF; /*End if of l_schedule_type=Revenue */
            x_raw_revenue             := l_raw_revenue ;
            x_bill_rate               := l_bill_rate  ;
	    x_bill_markup_percentage  := l_markup  ;
            x_rev_txn_curr_code       := NVL(l_bill_txn_curr_code,p_override_txn_currency_code)  ;
            x_return_status           := l_x_return_status;

            pa_debug.reset_err_stack;
   EXCEPTION
   	  WHEN l_insufficeient_param THEN
	    IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='All the Required parameters are not passes to Resource Schedule';
              pa_debug.write('Get_plan_res_class_Rates : ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
	    	x_return_status           := g_ERROR;
		x_msg_count               := 1;
		x_msg_data                := 'PA_FCST_INSUFFICIENT_PARA';
		x_revenue_rejection_code  := 'PA_FCST_INSUFFICIENT_PARA';
	        x_raw_cost_rejection_code := 'PA_FCST_INSUFFICIENT_PARA';
		 x_burden_cost_rejection_code :=  'PA_FCST_INSUFFICIENT_PARA';
		x_raw_revenue			  := NULL;
		x_raw_cost			  := NULL;
		x_bill_rate			  := NULL;
		x_cost_rate			 := NULL;

                pa_debug.reset_err_stack;

	 WHEN l_rate_based_no_quantity THEN
	    IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Quantity is required for a rate based  transaction';
              pa_debug.write('Get_plan_res_class_Rates : ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
    		x_return_status           :=  g_ERROR;
		x_msg_count               := 1;
		x_msg_data                := 'PA_EX_QTY_EXIST';
		x_revenue_rejection_code  := 'PA_EX_QTY_EXIST';
		x_raw_cost_rejection_code := 'PA_EX_QTY_EXIST';
		x_raw_revenue		  := NULL;
		x_raw_cost		  := NULL;
		x_bill_rate		  := NULL;
		 x_cost_rate		    := NULL;

		pa_debug.reset_err_stack;
        WHEN l_no_cost THEN
              x_raw_revenue		 := NULL;
	      x_raw_cost		 := NULL;
	      x_bill_rate		 := NULL;
	      x_cost_rate		 := NULL;
              x_return_status           :=  NVL(l_inter_return_status,g_ERROR);
              x_msg_data                :=  'PA_FCST_NO_COST_RATE';
              x_raw_cost_rejection_code :=  'PA_FCST_NO_COST_RATE';
	      x_burden_cost_rejection_code :=  'PA_FCST_NO_COST_RATE';
	      x_revenue_rejection_code	:=  'PA_FCST_NO_COST_RATE';
              x_msg_count               := 1;
              IF g1_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='No Cost Rate Exists:p_project_id'||p_project_id||'p_task_id'||p_task_id;
                 pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
              END IF;

             pa_debug.reset_err_stack;
	WHEN l_no_revenue THEN
              x_raw_revenue			  := NULL;
	      x_bill_rate			  := NULL;
	      x_return_status                     := NVL(l_inter_return_status,g_ERROR);
              x_msg_data                          :=  'PA_FCST_NO_BILL_RATE';
              x_revenue_rejection_code	          :=  'PA_FCST_NO_BILL_RATE';
              x_msg_count                            := 1;
              IF g1_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='No Bill Rate Exists:p_project_id'||p_project_id||'p_task_id'||p_task_id;
                 pa_debug.write('Get_plan_res_class_rates: ' || g_module_name,pa_debug.g_err_stage,5);
              END IF;

	      pa_debug.reset_err_stack;

      WHEN OTHERS THEN
           x_raw_revenue		  := NULL;
	   x_raw_cost			  := NULL;
	   x_bill_rate			  := NULL;
	   x_cost_rate		          := NULL;
           x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count                    := 1;
           x_msg_data                     := SUBSTR(SQLERRM,1,30);
           x_revenue_rejection_code       := SUBSTR(SQLERRM,1,30);
           x_raw_cost_rejection_code      := SUBSTR(SQLERRM,1,30);
	   x_burden_cost_rejection_code   := SUBSTR(SQLERRM,1,30);

	   IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='SQLERROR ' || SQLCODE;
              pa_debug.write('Get_plan_res_class_Rates : ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;

            pa_debug.reset_err_stack;
            RAISE;



END Get_plan_res_class_rates ;


/**************************************************************************************************************************
***************************************************************************************************************************
*********************************** FOR DOOSAN ITERATION 2 PLANNING RATES *************************************************
***************************************************************************************************************************
**************************************************************************************************************************/
PROCEDURE Get_Plan_plan_Rev_Rates  (
	p_project_id                   	 IN     NUMBER,
	p_task_id                        IN     NUMBER      DEFAULT NULL,
        p_person_id                    	 IN     NUMBER,
	p_job_id                         IN     NUMBER,			  /* for costing p_proj_cost_job_id */
	p_bill_job_grp_id             	 IN     NUMBER      DEFAULT NULL,
	p_resource_class		 IN     VARCHAR2,                 /* resource_class_code for Resource Class */
	p_rate_based_flag		 IN     VARCHAR2    DEFAULT 'Y',  /* to identify a rate based transaction */
	p_uom			    	 IN     VARCHAR2,		  /* Planning UOM */
	p_system_linkage		 IN     VARCHAR2,
	p_project_organz_id            	 IN     NUMBER	    DEFAULT NULL, /* For revenue calc use in Resource Class Sch carrying out Org Id */
	p_plan_rev_job_rate_sch_id 	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on job for planning*/
	p_plan_rev_emp_rate_sch_id       IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on emp for planning*/
   	p_plan_rev_nlr_rate_sch_id       IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on non labor for planning*/
        p_mcb_flag                    	 IN     VARCHAR2    DEFAULT NULL,
   	p_bill_rate_multiplier      	 IN     NUMBER	    DEFAULT 1,
        p_quantity                	 IN     NUMBER,                    /* required param for People/Equipment Class */
        p_item_date                	 IN     DATE,                      /* Used as p_expenditure_item_date for non labor */
 	p_project_org_id            	 IN     NUMBER,			   /* Project Org Id */
        p_project_type              	 IN     VARCHAR2,
        p_expenditure_type          	 IN     VARCHAR2,
        p_incurred_by_organz_id     	 IN     NUMBER,                    /* Incurred By Org Id */
	p_override_to_organz_id    	 IN     NUMBER,			   /* Override Org Id */
	p_expenditure_org_id        	 IN     NUMBER,                    /* p_expenditure_OU (p_exp_organization_id in costing) */
        p_planning_transaction_id    	 IN     NUMBER      DEFAULT NULL,  /* changeed from p_forecast_item_id will passed to client extension */
   	p_non_labor_resource         	 IN     VARCHAR2    DEFAULT NULL,
	p_NLR_organization_id            IN      NUMBER     DEFAULT NULL,   /* Org Id of the Non Labor Resource */
	p_revenue_override_rate     	 IN	NUMBER      DEFAULT NULL,
	p_override_currency_code  	 IN	VARCHAR2    DEFAULT NULL,  /*override currency Code */
        p_txn_currency_code		 IN	VARCHAR2    DEFAULT NULL,
	p_raw_cost                       IN 	NUMBER,
        p_burden_cost                    IN 	NUMBER      DEFAULT NULL,
	p_raw_revenue                	 IN     NUMBER      DEFAULT NULL,
	x_bill_rate                      OUT NOCOPY NUMBER,
	x_raw_revenue                	 OUT NOCOPY NUMBER,
        x_bill_markup_percentage       	 OUT NOCOPY NUMBER,
	x_txn_curr_code         	 OUT NOCOPY VARCHAR2,
        x_return_status              	 OUT NOCOPY VARCHAR2,
        x_msg_data                   	 OUT NOCOPY VARCHAR2,
	x_msg_count                  	 OUT NOCOPY NUMBER
	)
	IS


l_x_return_status 				 VARCHAR2(20):=g_success;
l_msg_count 					 NUMBER;
l_msg_data 					 VARCHAR2(1000);
l_txn_curr_code 				 VARCHAR2(30);
l_rev_curr_code 				 VARCHAR2(30);
l_override_cost 				 NUMBER:=NULL;
l_txn_bill_rate 				 pa_bill_rates_all.rate%TYPE:=NULL;
l_bill_rate 			   	         pa_bill_rates_all.rate%TYPE:=NULL;
l_txn_bill_markup 				 NUMBER:=NULL;
l_markup 				         NUMBER:=NULL;
l_raw_revenue 					 NUMBER:=NULL;
l_txn_raw_revenue 				 NUMBER;
l_exp_func_Curr_code 				 VARCHAR2(30);
l_raw_cost					NUMBER;
l_true						BOOLEAN  :=FALSE;
l_bill_txn_curr_code				VARCHAR2(30);
-- Added for bug 5952621
l_job_group_id                                   pa_std_bill_rate_schedules_all.job_group_id%TYPE;
l_dest_job_id                                    pa_bill_rates_all.job_id%TYPE;

/* Bug 8407306 */
l_job_bl_rate             NUMBER;
l_emp_bl_rate             NUMBER;
l_r_curr_code             VARCHAR2(30);


-- Modified the select of all the four cursors for bug 5079161
CURSOR C_std_emp_sch_rev IS
   SELECT
       /* DECODE  (p_uom,'DOLLARS',NULL, b.rate * NVL(p_bill_rate_multiplier,1)) b_rate,
                   DECODE  (p_uom,'DOLLARS',PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
                              	               * (l_raw_cost / 100), p_txn_currency_code)
                                          ,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                                                    * p_quantity, b.rate_currency_code)
                            ) r_revenue,
                       DECODE(p_uom,'DOLLARS', p_txn_currency_code	,b.rate_currency_code ) rate_currency_code,
        DECODE  (p_uom,'DOLLARS',b.markup_percentage,NULL)  markup
*/
     DECODE(p_uom,'DOLLARS',NULL, DECODE(p_uom,b.bill_rate_unit,b.rate * NVL(p_bill_rate_multiplier,1),NULL)) b_rate,
     DECODE(p_uom,'DOLLARS',PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
            * (l_raw_cost / 100),p_txn_currency_code),
                 DECODE(p_uom,b.bill_rate_unit,DECODE(b.rate,NULL,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 +
                      b.markup_percentage) * (l_raw_cost / 100), p_txn_currency_code),
                        PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1) * p_quantity, b.rate_currency_code)),
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage) * (l_raw_cost / 100), p_txn_currency_code)
                       )
             ) r_revenue,
       DECODE(p_uom,'DOLLARS',p_txn_currency_code,DECODE(p_uom,b.bill_rate_unit, DECODE(b.rate,NULL,p_txn_currency_code,b.rate_currency_code),
              p_txn_currency_code)  ) rate_currency_code, -- 4194214
       DECODE(p_uom,'DOLLARS',b.markup_percentage,DECODE(p_uom,b.bill_rate_unit,DECODE(b.rate,NULL,b.markup_percentage,NULL),b.markup_percentage))  markup
    FROM   pa_std_bill_rate_schedules_all sch,pa_bill_rates_all b
    WHERE sch.bill_rate_sch_id=p_plan_rev_emp_rate_sch_id
    AND b.bill_rate_sch_id = sch.bill_rate_sch_id
    AND    sch.schedule_type = 'EMPLOYEE'
    AND b.person_id = p_person_id
    AND   trunc(p_item_date)
    BETWEEN trunc(b.start_date_active)
      AND NVL(trunc(b.end_date_active),trunc(p_item_date));

/* bug 3712539 removed the join to p_person_id*/
 CURSOR C_std_job_sch_rev IS
   SELECT
     DECODE(p_uom,'DOLLARS',NULL, DECODE(p_uom,b.bill_rate_unit,b.rate * NVL(p_bill_rate_multiplier,1),NULL)) b_rate,
     DECODE(p_uom,'DOLLARS',PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
            * (l_raw_cost / 100),p_txn_currency_code),
                 DECODE(p_uom,b.bill_rate_unit,DECODE(b.rate,NULL,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 +
                      b.markup_percentage) * (l_raw_cost / 100), p_txn_currency_code),
                        PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1) * p_quantity, b.rate_currency_code)),
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage) * (l_raw_cost / 100), p_txn_currency_code)
                       )
             ) r_revenue,
       DECODE(p_uom,'DOLLARS',p_txn_currency_code,DECODE(p_uom,b.bill_rate_unit, DECODE(b.rate,NULL,p_txn_currency_code,b.rate_currency_code),
              p_txn_currency_code)  ) rate_currency_code, -- 4194214
       DECODE(p_uom,'DOLLARS',b.markup_percentage,DECODE(p_uom,b.bill_rate_unit,DECODE(b.rate,NULL,b.markup_percentage,NULL),b.markup_percentage))  markup
    FROM   pa_std_bill_rate_schedules_all sch,pa_bill_rates_all b --, per_assignments_f pa
    WHERE sch.bill_rate_sch_id  = p_plan_rev_job_rate_sch_id
    AND b.bill_rate_sch_id = sch.bill_rate_sch_id
    AND sch.schedule_type = 'JOB'
     AND b.job_id = l_dest_job_id -- p_job_id  Modified for bug 5952621
    AND   trunc(p_item_date)
    BETWEEN trunc(b.start_date_active)
      AND NVL(trunc(b.end_date_active),trunc(p_item_date));

 CURSOR C_std_nl_nls_sch_rev IS
   SELECT
     DECODE(p_uom,'DOLLARS',NULL, DECODE(p_uom,b.bill_rate_unit,b.rate * NVL(p_bill_rate_multiplier,1),NULL)) b_rate,
     DECODE(p_uom,'DOLLARS',PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
            * (l_raw_cost / 100),p_txn_currency_code),
                 DECODE(p_uom,b.bill_rate_unit,DECODE(b.rate,NULL,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 +
                      b.markup_percentage) * (l_raw_cost / 100), p_txn_currency_code),
                        PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1) * p_quantity, b.rate_currency_code)),
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage) * (l_raw_cost / 100), p_txn_currency_code)
                       )
             ) r_revenue,
       DECODE(p_uom,'DOLLARS',p_txn_currency_code,DECODE(p_uom,b.bill_rate_unit, DECODE(b.rate,NULL,p_txn_currency_code,b.rate_currency_code),
              p_txn_currency_code)  ) rate_currency_code, -- 4194214
       DECODE(p_uom,'DOLLARS',b.markup_percentage,DECODE(p_uom,b.bill_rate_unit,DECODE(b.rate,NULL,b.markup_percentage,NULL),b.markup_percentage))  markup
    FROM  pa_std_bill_rate_schedules_all sch,pa_bill_rates_all b
    WHERE sch.bill_rate_sch_id  = p_plan_rev_nlr_rate_sch_id
    AND b.bill_rate_sch_id = sch.bill_rate_sch_id
    AND   b.expenditure_type = p_expenditure_type
    AND   b.non_labor_resource = p_non_labor_resource
    AND sch.schedule_type = 'NON-LABOR'
    AND   trunc(p_item_date)
    BETWEEN trunc(b.start_date_active)
      AND NVL(trunc(b.end_date_active),trunc(p_item_date));

CURSOR C_std_nl_exp_sch_rev IS
   SELECT
     DECODE(p_uom,'DOLLARS',NULL, DECODE(p_uom,b.bill_rate_unit,b.rate * NVL(p_bill_rate_multiplier,1),NULL)) b_rate,
     DECODE(p_uom,'DOLLARS',PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
            * (l_raw_cost / 100),p_txn_currency_code),
                 DECODE(p_uom,b.bill_rate_unit,DECODE(b.rate,NULL,PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 +
                      b.markup_percentage) * (l_raw_cost / 100), p_txn_currency_code),
                        PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1) * p_quantity, b.rate_currency_code)),
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage) * (l_raw_cost / 100), p_txn_currency_code)
                       )
             ) r_revenue,
       DECODE(p_uom,'DOLLARS',p_txn_currency_code,DECODE(p_uom,b.bill_rate_unit, DECODE(b.rate,NULL,p_txn_currency_code,b.rate_currency_code),
              p_txn_currency_code)  ) rate_currency_code, -- 4194214
       DECODE(p_uom,'DOLLARS',b.markup_percentage,DECODE(p_uom,b.bill_rate_unit,DECODE(b.rate,NULL,b.markup_percentage,NULL),b.markup_percentage))  markup
    FROM  pa_std_bill_rate_schedules_all sch,pa_bill_rates_all b
    WHERE sch.bill_rate_sch_id  = p_plan_rev_nlr_rate_sch_id
    AND b.bill_rate_sch_id = sch.bill_rate_sch_id
    AND   b.expenditure_type = p_expenditure_type
    AND sch.schedule_type = 'NON-LABOR'
    AND   b.non_labor_resource IS NULL
    AND   trunc(p_item_date)
    BETWEEN trunc(b.start_date_active)
    AND NVL(trunc(b.end_date_active),trunc(p_item_date));

    Cursor c_emp_rate_proj_level IS  /* 8407306 */
    select rate,rate_currency_code
    from PA_EMP_BILL_RATE_OVERRIDES
    where project_id = p_project_id
    and person_id = p_person_id;


    Cursor c_job_rate_proj_level IS  /* 8407306 */
     select rate,rate_currency_code
     from pa_job_bill_rate_overrides
     where project_id = p_project_id
     and job_id = p_job_id;


BEGIN
    IF g1_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating all the input parameters';
        pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
    END IF;

    IF p_system_linkage='BTC' THEN
	l_override_cost := p_burden_cost;
    ELSE
	l_override_cost := p_raw_cost;
    END IF;
    l_txn_raw_revenue :=p_raw_revenue;
    l_raw_cost        := p_raw_cost; -- Added for bug 5039918

    IF p_rate_based_flag ='Y' AND p_quantity IS NULL AND NVL(l_override_cost,0)=0 THEN
    IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Validating Get_plan_plan_rev_Rates:p_quantity is required for rate based';
              pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;
      RAISE l_rate_based_no_quantity;
     END IF;
     IF p_revenue_override_rate IS NOT NULL  AND  p_override_currency_code  IS NULL THEN
        IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Validating Get_plan_plan_rev_Rates:p_override_currency_code is required if passing any overrides';
              pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;
      RAISE l_invalid_currency;
     END IF;
    /* If revenue Override rate is not null compute the raw_revenue based on the override rate and the p_quantity or rawCost */
    IF p_revenue_override_rate IS NOT NULL AND l_txn_raw_revenue IS NULL THEN

         SELECT p_revenue_override_rate  b_rate,
              PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((p_revenue_override_rate * p_quantity), p_override_currency_code)  r_revenue,
              p_override_currency_code
          INTO l_txn_bill_rate,l_raw_revenue,l_txn_curr_code
	  FROM dual;


	  l_txn_raw_revenue :=l_raw_revenue;

     END IF;/* End of check for p_revenue_override_rate */
      /* If in the above case the Raw Revenue is null then go for calling
      actual internal api of billing to compute the raw Revenue */

   IF l_txn_raw_revenue IS NULL THEN
      /* Deriving  Planning rates based on planning rate schedules for emp n job and non labor*/
      IF p_resource_class='PEOPLE' THEN
         IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Deriving  Planning rates based on planning rate schedules for emp and job';
              pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;
	 /* Checking for Employee based Rates*/
            BEGIN
                /* bug8407306 */
    	        open c_emp_rate_proj_level;
		fetch c_emp_rate_proj_level
		into l_emp_bl_rate,l_r_curr_code;
		close c_emp_rate_proj_level;

		  -- Opening cursor and fetching row
		  l_true := FALSE;
		   FOR Rec_std_emp_sch_rev IN C_std_emp_sch_rev LOOP
	           -- Checking if the cursor is returning more than one row then error out
	           IF (l_true) THEN
	              RAISE l_more_than_one_row_excep;
	           ELSE
	              l_true := TRUE;
	           END IF;

	           -- Assigning the Calculated raw revenue/adjusted to the local variable
                    l_bill_rate       := Rec_std_emp_sch_rev.b_rate;
	            l_raw_revenue     := Rec_std_emp_sch_rev.r_revenue;
		    l_bill_txn_curr_code   := Rec_std_emp_sch_rev.rate_currency_code;
		    l_markup       := Rec_std_emp_sch_rev.markup;

               END LOOP;

               /* bug8407306 */
       	       IF (l_emp_bl_rate is not NULL AND l_bill_rate IS null) THEN
		l_bill_rate       := l_emp_bl_rate;
		l_bill_txn_curr_code   := l_r_curr_code;
	       END IF;

               IF g1_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='l_bill_rate: ' || l_bill_rate ||
            	   'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_bill_txn_curr_code;
                  pa_debug.write('Get_plan_plan_rev_Rates: ' || g_module_name,pa_debug.g_err_stage,2);
               END IF;
            EXCEPTION
               WHEN l_more_than_one_row_excep THEN
                  x_raw_revenue:= NULL;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  x_msg_count     := 1;
                  x_msg_data      := 'TOO_MANY_ROWS';


                  IF g1_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Too many Rows';
                     pa_debug.write('Get_plan_plan_rev_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
                  END IF;

                  RAISE;
	    END;/*End of decalre cursor*/

	    IF l_raw_revenue  IS NULL THEN
	        /* Checking for Job based Rates if not by Employee based*/
               BEGIN

                /* bug8407306 */
	       	open c_job_rate_proj_level;
		fetch c_job_rate_proj_level
		into l_job_bl_rate,l_r_curr_code;
		close c_job_rate_proj_level;

		  -- Opening cursor and fetching row
		  l_true := FALSE;

		   /* Start of changes for bug 5952621 */

		    -- Start Changes for bug 6050924
        -- Handling scenario when p_plan_rev_job_rate_sch_id is null then select raises
        -- NO_DATA_FOUND exception. l_dest_job_id is set to p_job_id
        BEGIN
          select job_group_id
          into l_job_group_id
          from pa_std_bill_rate_schedules_all
          where bill_rate_sch_id = p_plan_rev_job_rate_sch_id;
        EXCEPTION
          When NO_DATA_FOUND Then
            l_job_group_id := NULL;
        END;

        IF l_job_group_id IS NOT NULL THEN
          l_dest_job_id := pa_cross_business_grp.IsMappedToJob(p_job_id, l_job_group_id);
        ELSE
          l_dest_job_id := p_job_id;
        END IF;
 	      -- End Changes for bug 6050924

        /* End of changes for bug 5952621 */

		   FOR Rec_std_job_sch_rev IN C_std_job_sch_rev LOOP
	           -- Checking if the cursor is returning more than one row then error out
	           IF (l_true) THEN
	              RAISE l_more_than_one_row_excep;
	           ELSE
	              l_true := TRUE;
	           END IF;

	           -- Assigning the Calculated raw revenue/adjusted to the local variable
                    l_bill_rate       := Rec_std_job_sch_rev.b_rate;
	            l_raw_revenue     := Rec_std_job_sch_rev.r_revenue;
		    l_bill_txn_curr_code   := Rec_std_job_sch_rev.rate_currency_code;
		    l_markup       := Rec_std_job_sch_rev.markup;

               END LOOP;

               /* bug8407306 */
	       IF (l_job_bl_rate is not NULL AND l_bill_rate IS null) THEN
		l_bill_rate       := l_job_bl_rate;
		l_bill_txn_curr_code   := l_r_curr_code;
	       END IF;

               IF g1_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='l_bill_rate: ' || l_bill_rate ||
            	   'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_bill_txn_curr_code;
                  pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
               END IF;
            EXCEPTION
               WHEN l_more_than_one_row_excep THEN
                  x_raw_revenue:= NULL;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  x_msg_count     := 1;
                  x_msg_data      := 'TOO_MANY_ROWS';


                  IF g1_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Too many Rows';
                     pa_debug.write('Get_plan_plan_rev_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
                  END IF;

                  RAISE;
	    END;/*End of decalre cursor*/

	    END IF;/*IF l_raw_revenue  IS NULL THEN*/

 ELSE /* Else of p_resource_class='PEOPLE' */

        /* Checking for Non Labor based Rates first for Non Labor Resources*/
               BEGIN
		  -- Opening cursor and fetching row
		  l_true := FALSE;
		   FOR Rec_std_nl_sch_rev IN C_std_nl_nls_sch_rev LOOP
	           -- Checking if the cursor is returning more than one row then error out
	           IF (l_true) THEN
	              RAISE l_more_than_one_row_excep;
	           ELSE
	              l_true := TRUE;
	           END IF;

	           -- Assigning the Calculated raw revenue/adjusted to the local variable
                    l_bill_rate       := Rec_std_nl_sch_rev.b_rate;
	            l_raw_revenue     := Rec_std_nl_sch_rev.r_revenue;
		    l_bill_txn_curr_code   := Rec_std_nl_sch_rev.rate_currency_code;
		    l_markup       := Rec_std_nl_sch_rev.markup;

               END LOOP;
               IF g1_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='l_bill_rate: ' || l_bill_rate ||
            	   'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_bill_txn_curr_code;
                  pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
               END IF;
            EXCEPTION
               WHEN l_more_than_one_row_excep THEN
                  x_raw_revenue:= NULL;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  x_msg_count     := 1;
                  x_msg_data      := 'TOO_MANY_ROWS';


                  IF g1_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Too many Rows in non labor based on Non Labor Resources';
		      pa_debug.write('Get_plan_plan_rev_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
                  END IF;

                  RAISE;
	    END;/*End of decalre cursor*/

	    IF l_raw_revenue IS NULL THEN
               /* Checking for Non Labor based Rates first for Non Labor Resources*/
               BEGIN
		  -- Opening cursor and fetching row
		  l_true := FALSE;
		   FOR Rec_std_nl_sch_rev IN C_std_nl_exp_sch_rev LOOP
	           -- Checking if the cursor is returning more than one row then error out
	           IF (l_true) THEN
	              RAISE l_more_than_one_row_excep;
	           ELSE
	              l_true := TRUE;
	           END IF;

	           -- Assigning the Calculated raw revenue/adjusted to the local variable
                    l_bill_rate       := Rec_std_nl_sch_rev.b_rate;
	            l_raw_revenue     := Rec_std_nl_sch_rev.r_revenue;
		    l_bill_txn_curr_code   := Rec_std_nl_sch_rev.rate_currency_code;
		    l_markup       := Rec_std_nl_sch_rev.markup;

                   END LOOP;
                   IF g1_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='l_bill_rate: ' || l_bill_rate ||
            	      'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_bill_txn_curr_code;
                      pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
                   END IF;
               EXCEPTION
                  WHEN l_more_than_one_row_excep THEN
                     x_raw_revenue:= NULL;
                     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                     x_msg_count     := 1;
                     x_msg_data      := 'TOO_MANY_ROWS';


                     IF g1_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Too many Rows in non labor based on expenditure Type';
                        pa_debug.write('Get_plan_plan_rev_Rates: ' || g_module_name,pa_debug.g_err_stage,5);
                     END IF;

                     RAISE;
	       END;/*End of decalre cursor*/

	    END IF;/* If l_raw_revenue IS NULL */


	 IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Deriving  Planning rates based on planning rate schedules for Non Labor';
              pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;
      END IF;
   END IF ;/* End of l_txn_raw_revenue IS NULL */


    x_raw_revenue 	     :=NVL(l_txn_raw_revenue,l_raw_revenue);
    x_bill_rate               := l_bill_rate  ;
    x_bill_markup_percentage  := l_markup  ;
    x_txn_curr_code           := NVL(l_bill_txn_curr_code,p_override_currency_code)  ;
    x_return_status           := l_x_return_status;


EXCEPTION
 WHEN l_invalid_currency THEN
      x_raw_revenue 		     :=NULL;
      x_bill_rate	  	     :=NULL;
      x_bill_markup_percentage       :=NULL;
      x_txn_curr_code         	     :=NULL;
      x_return_status                := g_error;
      x_msg_data      		     := 'PA_INVALID_DENOM_CURRENCY';
      x_msg_count                    := 1;

       IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Override Currency is not passed to a rate based tranaction to the Get_Plan_Actual_Rev_Rates call';
              pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
       END IF;
  WHEN l_rate_based_no_quantity THEN
      x_raw_revenue 		     :=NULL;
      x_bill_rate	  	     :=NULL;
      x_bill_markup_percentage       :=NULL;
      x_txn_curr_code         	     :=NULL;
      x_return_status                := g_error;
      x_msg_data      		     := 'PA_EX_QTY_EXIST';
      x_msg_count                    := 1;

       IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Quantity is not passed to a rate based tranaction to the Get_Plan_Actual_Rev_Rates call';
              pa_debug.write('Get_plan_plan_rev_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
       END IF;

END Get_Plan_plan_Rev_Rates;



PROCEDURE Get_plan_plan_Rates  (	p_project_id                   	 IN     NUMBER,
	p_task_id                        IN     NUMBER      DEFAULT NULL,
        p_top_task_id                    IN     NUMBER      DEFAULT NULL, /* for costing top task Id */
	p_person_id                    	 IN     NUMBER,
	p_job_id                         IN     NUMBER,			  /* for costing p_proj_cost_job_id */
	p_bill_job_grp_id             	 IN     NUMBER      DEFAULT NULL,
	p_resource_class		 IN     VARCHAR2,                 /* resource_class_code for Resource Class */
	p_rate_based_flag		 IN     VARCHAR2    DEFAULT 'Y',  /* to identify a rate based transaction */
	p_uom			    	 IN     VARCHAR2,		  /* Planning UOM */
	p_system_linkage		 IN     VARCHAR2,
	p_project_organz_id            	 IN     NUMBER	    DEFAULT NULL, /* For revenue calc use in Resource Class Sch carrying out Org Id */
	p_plan_rev_job_rate_sch_id 	  IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on job for planning*/
	p_plan_cost_job_rate_sch_id  	  IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on job for planning*/
	p_plan_rev_emp_rate_sch_id        IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on emp for planning*/
   	p_plan_cost_emp_rate_sch_id       IN     NUMBER	    DEFAULT NULL, /* For cost Rate Calculations based on emp for planning*/
	p_plan_rev_nlr_rate_sch_id       IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on non labor for planning*/
        p_plan_cost_nlr_rate_sch_id      IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on non labor for planning*/
	p_plan_burden_cost_sch_id         IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on burdening  for planning*/
	p_calculate_mode                  IN     VARCHAR2   DEFAULT 'COST_REVENUE' ,/* useed for calculating either only Cost(COST),only Revenue(REVENUE) or both Cost and Revenue(COST_REVENUE) */
	p_mcb_flag                    	 IN     VARCHAR2    DEFAULT NULL,
        p_cost_rate_multiplier           IN     NUMBER      DEFAULT NULL ,
        p_bill_rate_multiplier      	 IN     NUMBER	    DEFAULT 1,
        p_quantity                	 IN     NUMBER,                    /* required param for People/Equipment Class */
        p_item_date                	 IN     DATE,                      /* Used as p_expenditure_item_date for non labor */
   	p_project_org_id            	 IN     NUMBER,			   /* Project Org Id */
        p_project_type              	 IN     VARCHAR2,
        p_expenditure_type          	 IN     VARCHAR2,
        p_non_labor_resource         	 IN     VARCHAR2    DEFAULT NULL,
        p_incurred_by_organz_id     	 IN     NUMBER,                    /* Incurred By Org Id */
	p_override_to_organz_id    	 IN     NUMBER,			   /* Override Org Id */
	p_expenditure_org_id        	 IN     NUMBER,                    /* p_expenditure_OU (p_exp_organization_id in costing) */
        p_planning_transaction_id    	 IN     NUMBER      DEFAULT NULL,  /* changeed from p_forecast_item_id will passed to client extension */
        p_nlr_organization_id            IN     NUMBER      DEFAULT NULL,   /* Org Id of the Non Labor Resource */
	p_inventory_item_id         	 IN	NUMBER      DEFAULT NULL,  /* Passed for Inventoty Items */
        p_BOM_resource_Id          	 IN	NUMBER      DEFAULT NULL,  /* Passed for BOM Resource  Id */
        P_mfc_cost_type_id           	 IN	NUMBER      DEFAULT 0,     /* Manufacturing cost api */
        P_item_category_id           	 IN	NUMBER      DEFAULT NULL,  /* Manufacturing cost api */
        p_mfc_cost_source                IN     NUMBER      DEFAULT 1,
        p_cost_override_rate        	 IN	NUMBER      DEFAULT NULL,  /*override rate if not null no call to costing internal api.*/
        p_revenue_override_rate     	 IN	NUMBER      DEFAULT NULL,  /*override rate if not null no call to billing internal api.*/
        p_override_burden_cost_rate   	 IN	NUMBER      DEFAULT NULL,  /*override burden multiplier and p_raw_cost is not null calculate x_burden_cost */
        p_override_currency_code  	 IN	VARCHAR2    DEFAULT NULL,  /*override currency Code */
        p_txn_currency_code		 IN	VARCHAR2    DEFAULT NULL,  /* if not null, amounts to be returned in this currency only else in x_txn_curr_code*/
        p_raw_cost                       IN 	NUMBER,		           /*If p_raw_cost is only passed,return the burden multiplier, burden_cost */
        p_burden_cost                    IN 	NUMBER      DEFAULT NULL,
        p_raw_revenue                	 IN     NUMBER      DEFAULT NULL,
        x_bill_rate                      OUT NOCOPY	NUMBER,
        x_cost_rate                      OUT NOCOPY	NUMBER,
        x_burden_cost_rate               OUT NOCOPY	NUMBER,
        x_burden_multiplier		 OUT NOCOPY	NUMBER,
        x_raw_cost                       OUT NOCOPY	NUMBER,
        x_burden_cost                    OUT NOCOPY	NUMBER,
        x_raw_revenue                	 OUT NOCOPY	NUMBER,
        x_bill_markup_percentage       	 OUT NOCOPY     NUMBER,
        x_cost_txn_curr_code         	 OUT NOCOPY     VARCHAR2,
        x_rev_txn_curr_code         	 OUT NOCOPY     VARCHAR2, /* x_txn_currency_code  for Labor and x_rev_curr_code   for non labor */
        x_raw_cost_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_burden_cost_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_revenue_rejection_code	 OUT NOCOPY	VARCHAR2,
        x_cost_ind_compiled_set_id	 OUT NOCOPY	NUMBER,
        x_return_status              	 OUT NOCOPY     VARCHAR2,
        x_msg_data                   	 OUT NOCOPY     VARCHAR2,
        x_msg_count                  	 OUT NOCOPY     NUMBER
	)
IS
l_raw_cost   						 NUMBER :=NULL;
l_burden_cost    					 NUMBER :=NULL;
l_raw_revenue           				 NUMBER:=NULL;
l_x_return_status       				 VARCHAR2(2):= g_success;
l_cost_msg_count           		   		 NUMBER;
l_cost_msg_data		           			 VARCHAR2(1000);
l_bill_msg_count             			         NUMBER;
l_bill_msg_data              			         VARCHAR2(1000);
l_called_process        				 VARCHAR2(40);
l_txn_curr_code         				 VARCHAR2(30);
l_trxn_curr_code         				 VARCHAR2(30);
l_cost_txn_curr_code         				 VARCHAR2(30);
l_rev_txn_curr_code         				 VARCHAR2(30);
l_rev_curr_code         				 VARCHAR2(30);
l_txn_cost         				         NUMBER:=NULL; /* to store the value of p_burden_cost or p_raw_cost */
l_proj_nl_bill_rate_sch_id 				 NUMBER;
l_task_nl_bill_rate_sch_id 				 NUMBER;
l_txn_cost_rate         				 NUMBER;
l_txn_raw_cost_rate    					 NUMBER;
l_txn_burden_cost_rate  				 NUMBER;
l_txn_bill_rate         				 NUMBER;
l_txn_bill_markup       				 NUMBER:=NULL;
l_txn_raw_cost          				 NUMBER;
l_txn_burden_cost       				 NUMBER;
l_txn_raw_revenue       				 NUMBER;
l_sl_function           				 NUMBER ;
l_exp_func_Curr_code    				 VARCHAR2(30);
l_raw_cost_rate         				 NUMBER ;
l_burden_cost_rate  		   			 NUMBER ;
l_bill_rate             				 NUMBER:=NULL;
l_burden_multiplier					 NUMBER;
l_raw_cost_rejection_code				 VARCHAR2(30);
l_burden_cost_rejection_code				 VARCHAR2(30);
l_cost_ind_compiled_set_id				 NUMBER;
l_proj_cost_job_id					 NUMBER;
l_expenditure_org_id					 NUMBER;
l_uom_flag						 NUMBER(1) :=1;


BEGIN
   l_raw_revenue := p_raw_revenue;
   l_raw_cost    := p_raw_cost;
   l_burden_cost := p_burden_cost;
    IF upper(p_resource_class)='PEOPLE' THEN
     l_expenditure_org_id :=nvl(p_incurred_by_organz_id, p_override_to_organz_id );
    ELSE
       l_expenditure_org_id :=nvl(p_nlr_organization_id,p_override_to_organz_id );
    END IF;

   	IF p_system_linkage='BTC' THEN
	  l_txn_cost := p_burden_cost;
	ELSE
	  l_txn_cost := p_raw_cost;
	END IF;
    IF ((p_raw_cost IS  NULL OR  p_burden_cost IS  NULL)
    AND p_calculate_mode IN ('COST','COST_REVENUE')) THEN
          IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Before Calling PA_COST1.Get_Plan_actual_Cost_Rates in PLAN mode';
            pa_debug.write('Get_plan_plan_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;

	BEGIN
	 PA_COST1.Get_Plan_Actual_Cost_Rates
        (p_calling_mode                 =>'PLAN_RATES'
        ,p_project_type                 =>p_project_type
        ,p_project_id                   =>p_project_id
        ,p_task_id                      =>p_task_id
        ,p_top_task_id                  =>p_top_task_id
        ,p_Exp_item_date                =>p_item_date
        ,p_expenditure_type             =>p_expenditure_type
        ,p_expenditure_OU               =>p_expenditure_org_id
        ,p_project_OU                   =>p_project_org_id
        ,p_Quantity                     =>p_Quantity
        ,p_resource_class               =>p_resource_class
        ,p_person_id                    =>p_person_id
        ,p_non_labor_resource           =>p_non_labor_resource
        ,p_NLR_organization_id          =>p_NLR_organization_id
        ,p_override_organization_id     =>p_override_to_organz_id
        ,p_incurred_by_organization_id  =>p_incurred_by_organz_id
        ,p_inventory_item_id            =>p_inventory_item_id
        ,p_BOM_resource_id              =>p_BOM_resource_id
        ,p_override_trxn_curr_code      =>p_override_currency_code
        ,p_override_burden_cost_rate    =>p_override_burden_cost_rate
        ,p_override_trxn_cost_rate      =>p_cost_override_rate
        ,p_override_trxn_raw_cost       =>p_raw_cost
        ,p_override_trxn_burden_cost    =>p_burden_cost
        ,p_mfc_cost_type_id             =>p_mfc_cost_type_id
        ,p_mfc_cost_source              =>p_mfc_cost_source --check
        ,p_item_category_id             =>p_item_category_id
	    ,p_job_id                       =>p_job_id
        , p_plan_cost_job_rate_sch_id   =>p_plan_cost_job_rate_sch_id
        , p_plan_cost_emp_rate_sch_id   =>p_plan_cost_emp_rate_sch_id
        , p_plan_cost_nlr_rate_sch_id   =>p_plan_cost_nlr_rate_sch_id
	    , p_plan_cost_burden_sch_id     =>p_plan_burden_cost_sch_id
        ,x_trxn_curr_code               =>l_trxn_curr_code
        ,x_trxn_raw_cost                =>l_txn_raw_cost
        ,x_trxn_raw_cost_rate           =>l_txn_cost_rate
        ,x_trxn_burden_cost             =>l_txn_burden_cost
        ,x_trxn_burden_cost_rate        =>l_txn_burden_cost_rate
        ,x_burden_multiplier            =>l_burden_multiplier
        ,x_cost_ind_compiled_set_id     =>l_cost_ind_compiled_set_id
        ,x_raw_cost_rejection_code      =>l_raw_cost_rejection_code
        ,x_burden_cost_rejection_code   =>l_burden_cost_rejection_code
        ,x_return_status                =>l_x_return_status
        ,x_error_msg_code               =>l_cost_msg_data ) ;

	   IF g1_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Called PA_COST1.Get_Plan_Actual_Cost_Rates:x_raw_cost_rejection_code'||l_raw_cost_rejection_code||'x_burden_cost_rejection_code'||l_burden_cost_rejection_code;
            pa_debug.write('Get_plan_plan_Rates : ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
	   EXCEPTION
	       WHEN OTHERS THEN
	          x_msg_data		:= 'PA_COST1.Get_Plan_Actual_Cost_Rates:' || SUBSTR(SQLERRM,1,250);
		  x_raw_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  x_burden_cost_rejection_code	:= SUBSTR(SQLERRM,1,30);
		  x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

		  IF g1_debug_mode = 'Y' THEN
		     pa_debug.g_err_stage:=' PA_COST1.Get_Plan_Actual_Cost_Rates is throwing When Others';
		     pa_debug.write('Get_plan_plan_Rates : ' || g_module_name,pa_debug.g_err_stage,1);
		  END IF;
		  RAISE;

	     END;
	    /* transferring the outout cost to one cost and checking if the costing API has computed Cost */
	    IF p_system_linkage='BTC' THEN
	       l_txn_cost := l_txn_burden_cost;
	    ELSE
	       l_txn_cost :=l_txn_raw_cost;
	    END IF;


     ELSE
        /* If p_raw_cost and p_burden Cost are passed Costing API
	    won't be called but the same value will be passed as it is */
        l_txn_raw_cost :=l_raw_cost ;
        l_txn_burden_cost :=l_burden_cost ;
	IF p_quantity <>0 THEN
	  l_txn_cost_rate :=l_raw_cost/(NVL(p_quantity,1)) ;
          l_txn_burden_cost_rate :=l_burden_cost/(NVL(p_quantity,1)) ;
	END IF;

     END IF;

   /* Sending out all the out parametrs of Costing , This is send out here as even if the costing API has failed
      Revenue API will be called and revenue calculated if the required values are passed to the Billing API,
	  though it'll pass the rejection code of Costing APi in the out parameters*/
        x_cost_rate                   := l_txn_cost_rate;
	x_burden_cost_rate            := l_txn_burden_cost_rate;
	x_burden_multiplier	      := l_burden_multiplier ;
	x_raw_cost                    := l_txn_raw_cost;
        x_burden_cost                 := l_txn_burden_cost;
        x_cost_txn_curr_code          := l_trxn_curr_code;
	x_raw_cost_rejection_code     := l_raw_cost_rejection_code ;
	x_burden_cost_rejection_code  := l_burden_cost_rejection_code;
	x_cost_ind_compiled_set_id    := l_cost_ind_compiled_set_id;
        x_return_status               := l_x_return_status ;
        x_msg_data		      := l_cost_msg_data	;

 /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

 IF p_calculate_mode IN ('REVENUE','COST_REVENUE') THEN
   /* Calling the Billing Revenue  calculation Api only if p_raw_revenue is null */
   IF l_raw_revenue IS NULL THEN
    /* Checking for Rate based whether quantity is entered else */

      IF p_rate_based_flag ='Y' THEN
          null;
      ELSE
   	 IF NVL(l_txn_cost,0)=0 THEN
	 /*4108291 added the beloe code to have same check as in get_plan_actual_rates to compute the revenue based on quanity
	   if revenue override is passed*/
	    IF p_quantity is  NOT NULL and p_revenue_override_rate  is not null then
               null;
            ELSE
               RAISE  l_no_cost;
	    END IF;
         END IF;
      END IF;
        IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Calling Get_Plan_plan_Rev_Rates';
              pa_debug.write('Get_plan_plan_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;

        Get_Plan_plan_Rev_Rates  (
					p_project_id                   	 => p_project_id ,
					p_task_id                        => p_task_id,
				        p_person_id                    	 => p_person_id   ,
					p_job_id                         => p_job_id,
					p_bill_job_grp_id             	 => p_bill_job_grp_id,
					p_resource_class		 => p_resource_class,
					p_rate_based_flag		 => p_rate_based_flag,
					p_uom			    	 => p_uom,
					p_system_linkage		 => p_system_linkage,
					p_project_organz_id            	 => p_project_organz_id,
					p_plan_rev_job_rate_sch_id       => p_plan_rev_job_rate_sch_id ,
					p_plan_rev_emp_rate_sch_id       => p_plan_rev_emp_rate_sch_id,
					p_plan_rev_nlr_rate_sch_id	 => p_plan_rev_nlr_rate_sch_id ,
					p_mcb_flag                       => p_mcb_flag,
					p_bill_rate_multiplier      	 => p_bill_rate_multiplier  ,
					p_quantity                	 => p_quantity ,
					p_item_date                	 => p_item_date,
					p_project_org_id                 => p_project_org_id ,
					p_project_type                   => p_project_type,
					p_expenditure_type               => p_expenditure_type    ,
				        p_incurred_by_organz_id          => p_incurred_by_organz_id     ,
					p_override_to_organz_id          => p_override_to_organz_id ,
					p_expenditure_org_id             => l_expenditure_org_id,    --p_expenditure_org_id  ,
					p_planning_transaction_id        => p_planning_transaction_id,
					p_non_labor_resource         	 => p_non_labor_resource  ,
					p_NLR_organization_id            => p_NLR_organization_id ,
					p_revenue_override_rate     	 => p_revenue_override_rate,
					p_override_currency_code  	 => p_override_currency_code,
					p_txn_currency_code		 => l_trxn_curr_code	,
					p_raw_cost                       => l_txn_raw_cost,
					p_burden_cost                    => l_txn_burden_cost,
					p_raw_revenue                	 => l_raw_revenue,
					x_bill_rate                      => l_txn_bill_rate,
					x_raw_revenue                	 => l_txn_raw_revenue,
					x_bill_markup_percentage       	 => l_txn_bill_markup,
					x_txn_curr_code         	 => l_rev_txn_curr_code,
					x_return_status              	 => l_x_return_status,
					x_msg_data                   	 => l_bill_msg_data,
					x_msg_count                  	 => l_bill_msg_count
					);


		/* Raising the Billing Exception to pass the error values to the Main Api */
	  	IF   l_x_return_status <> g_success THEN
	  	     RAISE   l_bill_api;
		END IF;

	ELSE
            IF p_override_currency_Code IS NULL THEN
	       RAISE l_invalid_currency;
	    END IF;
	    l_txn_raw_revenue :=l_raw_revenue ;
	    IF p_quantity <>0  THEN
  	      l_txn_bill_rate :=l_raw_revenue/(NVL(p_quantity,1)) ;
	    END IF;
	    l_rev_txn_curr_code:=p_override_currency_Code;
	END IF;

END IF; /* End of IF p_calculate_mode IN ('REVENUE','COST_REVENUE') THEN   */
 /* Passing the output parametrs of Billing for Revenue */
        x_raw_revenue 			 :=l_txn_raw_revenue;
	x_bill_rate	  		 :=l_txn_bill_rate ;
        x_bill_markup_percentage         :=l_txn_bill_markup;
	x_rev_txn_curr_code              :=l_rev_txn_curr_code;
	x_revenue_rejection_code         :=NULL;
        x_return_status                  :=l_x_return_status;
  IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='OUT of Get_plan_plan_Rates:p_project_id'||p_project_id||'p_task_id'||p_task_id||'l_txn_raw_revenue'||l_txn_raw_revenue||'l_txn_bill_rate'||l_txn_bill_rate||'l_rev_txn_curr_code'||l_rev_txn_curr_code;
              pa_debug.write('Get_plan_plan_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;
EXCEPTION

   WHEN l_no_cost THEN
          x_raw_revenue 					:= NULL;
	  x_bill_rate	  					:= NULL;
          x_bill_markup_percentage          := NULL;
	  x_rev_txn_curr_code         	        := NULL;
	  x_revenue_rejection_code	        := 'PA_NO_ACCT_COST';
          x_return_status                   := g_error;
          x_msg_data                   	    := 'PA_NO_ACCT_COST';
	  x_msg_count                  	    := 1;


        IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='No Cost exist for the tranascation:p_project_id'||p_project_id||'p_task_id'||p_task_id;
              pa_debug.write('Get_plan_plan_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
            END IF;
   WHEN l_bill_api THEN
	  x_raw_revenue 					:= NULL;
	  x_bill_rate	  					:= NULL;
          x_bill_markup_percentage          := NULL;
	  x_rev_txn_curr_code         	        := NULL;
	  x_revenue_rejection_code	        := l_bill_msg_data;
          x_return_status                   := l_x_return_status;
          x_msg_data                   	    := l_bill_msg_data;
	  x_msg_count                  	    := l_bill_msg_count;

         IF g1_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Billing api is throwing error';
              pa_debug.write('Get_plan_plan_Rates : ' || g_module_name,pa_debug.g_err_stage,2);
         END IF;


END Get_plan_plan_Rates;
BEGIN
Get_exp_type_uom;
END PA_PLAN_REVENUE;


/
