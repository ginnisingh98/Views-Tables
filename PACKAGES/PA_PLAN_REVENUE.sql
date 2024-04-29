--------------------------------------------------------
--  DDL for Package PA_PLAN_REVENUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLAN_REVENUE" AUTHID CURRENT_USER as
/* $Header: PAXPLRTS.pls 120.1 2005/06/15 04:39:26 appldev  $ */

--
-- Procedure            : Get_Planning_Rates
-- Purpose              : This procedure will calculate the  bill rate and raw revenue from one of
--                        the given criteria's on the basis of passed parameters for the Planning Transaction
-- Parameters           :



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
        p_rev_job_rate_sch_id         	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Job*/
	p_rev_emp_rate_sch_id         	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on Emp*/
	p_plan_rev_job_rate_sch_id 	 IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on job for planning*/
	p_plan_cost_job_rate_sch_id  	 IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on job for planning*/
	p_plan_rev_emp_rate_sch_id       IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on emp for planning*/
   	p_plan_cost_emp_rate_sch_id      IN     NUMBER	    DEFAULT NULL, /* For cost Rate Calculations based on emp for planning*/
	p_plan_rev_nlr_rate_sch_id       IN     NUMBER	    DEFAULT NULL, /* For Bill Rate Calculations based on non labor for planning*/
        p_plan_cost_nlr_rate_sch_id      IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on non labor for planning*/
	p_plan_burden_cost_sch_id        IN     NUMBER	    DEFAULT NULL, /* For Cost Rate Calculations based on burdening  for planning*/
	p_calculate_mode                 IN     VARCHAR2    DEFAULT 'COST_REVENUE' ,/* useed for calculating either only Cost(COST),only Revenue(REVENUE) or both Cost and Revenue(COST_REVENUE) */
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
	);
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
	);
-- Procedure            : Get_plan_actual_Rates
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
	x_txn_curr_code         	 OUT NOCOPY VARCHAR2,
        x_return_status              	 OUT NOCOPY VARCHAR2,
        x_msg_data                   	 OUT NOCOPY VARCHAR2,
	x_msg_count                  	 OUT NOCOPY NUMBER
	);




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
	p_job_id                         IN     NUMBER DEFAULT NULL,
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
        x_msg_data                   	 OUT   NOCOPY  VARCHAR2);



--
-- Procedure            : Get_plan_plan_Rates
-- Purpose              : This is an internal procedure for calculating the cost/bill rate and raw cost/burden cost/raw revenue from one of
--                        the given criteria's on the basis of passed parameters for the 'PLANNING RATES' of Planning Transaction
-- Parameters           :
--

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
	);
-- Procedure            : Get_Plan_plan_Rev_Rates
-- Purpose              : This is an internal procedure for calculating the  bill rate and raw revenue from one of
--                        the given criteria's on the basis of passed parameters for the 'PLANNING RATES' of Planning Transaction
-- Parameters           :
--

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
	);




END PA_PLAN_REVENUE;


 

/
