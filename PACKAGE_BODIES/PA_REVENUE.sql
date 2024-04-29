--------------------------------------------------------
--  DDL for Package Body PA_REVENUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REVENUE" as
/* $Header: PAXBLRTB.pls 120.6.12010000.5 2010/01/25 08:47:43 dbudhwar ship $ */

 l_no_revenue                  EXCEPTION;
 l_no_bill_rate                EXCEPTION;
 /* Added for MCB2 */
 l_conversion_fail             EXCEPTION;
 l_invalid_projfunc_curr_code  EXCEPTION;
 l_invalid_txn_curr_code       EXCEPTION;
 l_invalid_proj_curr_code      EXCEPTION;



-- This procedure will calculate the  bill rate and raw revenue from one of the given criteria's on the basis
-- of passed parameters
-- Input parameters
-- Parameters                   Type           Required      Description
-- P_project_id                 NUMBER          YES          Project Id
-- P_task_id                    NUMBER          NO           Task Id  for the given project
-- P_bill_rate_multiplier       NUMBER          YES          Bill rate multiplier for calculating the revenue
--                                                           and rate
-- P_quantity                   NUMBER          YES          Quantity in Hours
-- P_raw_cost                   NUMBER          YES          Raw cost in project finctional currency
-- P_item_date                  DATE            YES          Forecast Item date
-- P_project_bill_job_grp_id    NUMBER          NO           Billing job group id for project
-- P_labor_schdl_discnt         NUMBER          NO           Labour schedule discount
-- P_labor_bill_rate_org_id     NUMBER          NO           Bill rate organization id
-- P_labor_std_bill_rate_schdl  VARCHAR2        NO           Standard bill rate schedule
-- P_labor_schdl_fixed_date     DATE            NO           Labor schedule fixed date
-- P_forecast_job_id            NUMBER          YES          Forecast job Id at assignment level
-- P_forecast_job_grp_id        NUMBER          YES          Forecast job group id at assignment level
-- P_labor_schdl_type           VARCHAR2        NO           Labor schedule type i.e. 'I' (Indirect) 'B'( Bill)
-- P_item_id                    NUMBER          NO           Unique id
-- P_forecast_item_id           NUMBER          NO           Unique identifier for forecast item used in
--                                                           client extension
-- P_forecasting_type           VARCHAR2        YES          It tells that from where we are calling extn.
-- P_project_org_id             NUMBER          NO           Project org Id
-- P_job_bill_rate_schedule_id  NUMBER          YES          Job bill rate schedule id
-- P_project_type               VARCHAR2        YES          Project Type
-- P_expenditure_type           VARCHAR2        YES          Expenditure Type
-- px_exp_func_curr_code        VARCHAR2        YES          Expenditure functional currency code
-- P_incurred_by_organz_id      NUMBER          YES          Incurred by organz id
-- P_raw_cost_rate              NUMBER          YES          Raw cost rate in expenditure currency
-- P_override_to_organz_id      NUMBER          YES          Override to organz id
-- p_exp_raw_cost               NUMBER          YES          Raw cost in Expenditure currency
-- p_expenditure_org_id         NUMBER          YES          Expenditure Org id
-- p_projfunc_currency_code     VARCHA2         No          Project functional currency(PFC)
-- p_projfunc_bil_rate_date_code VARCHAR2       No          Bill rate date code of PFC
--
--
-- Out parameters
--
-- X_bill_rate                  NUMBER          YES          Bill rate
-- X_raw_revenue                NUMBER          YES          Raw revenue
-- x_markup_percentage          NUMBER          YES          Markup percentage for that revenue
-- PX_project_bill_job_id       NUMBER          NO           Billing Job id for project
-- px_projfunc_bil_rate_type    VARCHAR2        No           Bill rate type of PFC
-- px_projfunc_bil_rate_date    DATE            No           Bill rate date code of PFC
-- px_projfunc_bil_exchange_rate NUMBER         No           Bill exchange rate of PFC


g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Requirement_Rev_Amt (
         p_project_id                IN     NUMBER,
         p_task_id                   IN     NUMBER,
         p_bill_rate_multiplier      IN     NUMBER,
         p_quantity                  IN     NUMBER,
         p_raw_cost                  IN     NUMBER,
         p_item_date                 IN     DATE,
         p_project_bill_job_grp_id   IN     NUMBER,
         p_labor_schdl_discnt        IN     NUMBER,
         p_labor_bill_rate_org_id    IN     NUMBER,
         p_labor_std_bill_rate_schdl IN     VARCHAR2,
         p_labor_schdl_fixed_date    IN     DATE,
         p_forecast_job_id           IN     NUMBER,
         p_forecast_job_grp_id       IN     NUMBER,
         p_labor_sch_type            IN     VARCHAR2,
         p_item_id                   IN     NUMBER DEFAULT NULL, /* change from forecast */
                                                /*  item id to item id for bug 2212852 */
         p_project_org_id            IN     NUMBER,
         p_job_bill_rate_schedule_id IN     NUMBER,
         p_project_type              IN     VARCHAR2,
         p_expenditure_type          IN     VARCHAR2,
         px_exp_func_curr_code       IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         p_incurred_by_organz_id     IN     NUMBER,
         p_raw_cost_rate             IN     NUMBER,
         p_override_to_organz_id     IN     NUMBER,
         p_exp_raw_cost              IN     NUMBER,
         p_expenditure_org_id        IN     NUMBER,
         p_projfunc_currency_code    IN     VARCHAR2,/* Added for MCB2 */
         p_assignment_precedes_task  IN     VARCHAR2, /* Added for Asgmt overide */
         p_forecast_item_id          IN     NUMBER DEFAULT NULL, /* added para for bug 2212852 */
         p_forecasting_type          IN     VARCHAR2 DEFAULT 'PROJECT_FORECASTING', /* added para for bug 2212852 */
         p_sys_linkage_function      IN     VARCHAR2 , /* Added for Org Forecasting */
         px_project_bill_job_id      IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_bill_rate                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_raw_revenue               OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_markup_percentage         OUT    NOCOPY NUMBER,   /* Added for Asgmt overide */ --File.Sql.39 bug 4440895
         x_txn_currency_code         OUT    NOCOPY VARCHAR2, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
         x_return_status             OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_msg_data                  OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS



   l_raw_revenue                    NUMBER :=null; -- It will be used to store the raw revenue
                                                   -- from one of the raw revenue calculating
                                                   -- criteria
   l_bill_rate                      NUMBER :=null; -- It will be used to store bill amount
                                                   -- from one of the bill amount calculating
                                                   -- criteria

   l_schedule_type                  VARCHAR2(50) := 'REVENUE';

   l_x_return_status                VARCHAR2(50);  -- It will be used to store the return status
                                                   -- and used it to validate whether the
                                                   -- calling procedure has run successfully
                                                   -- or encounter any error
  l_adjusted_revenue                NUMBER;        -- Local variable
  l_adjusted_rate                   NUMBER:=NULL;        -- Local variable
  l_labor_schdl_discnt              NUMBER;        -- Variable to store labor schedule discount
  l_discount_pct					NUMBER;        -- Variable to store the discount pct override
  l_labor_bill_rate_org_id          NUMBER;        -- Variable to store labor bill rate organization id
  l_labor_std_bill_rate_schdl       pa_projects_all.labor_std_bill_rate_schdl%TYPE;  -- store labor standard
                                                                                     --  bill rate schedule
  l_labor_schdl_fixed_date          DATE;          -- variable to store labor schedule fixed date
  l_labor_sch_type                  pa_projects_all.labor_sch_type%TYPE;  -- store labor schedule type

  l_no_revenue                      EXCEPTION;--no revenue
  l_no_val_in_funct                 EXCEPTION;     -- Exception if no record found from get to job proc.
  l_job_bill_rate_schedule_id       pa_projects_all.job_bill_rate_schedule_id%TYPE;  -- store job bill rate
                                                                                     -- schedule id
  l_project_org_id                  pa_projects_all.org_id%TYPE;

  /* Added for MCB2 */
   l_txn_bill_rate                   NUMBER :=null; -- store bill amount transaction curr.
   l_txn_raw_revenue                 NUMBER :=null; --  store the raw revenue trans. curr.
   l_rate_currency_code              pa_bill_rates_all.rate_currency_code%TYPE;

   l_projfunc_currency_code          pa_projects_all.projfunc_currency_code%TYPE;
   l_markup_percentage               pa_bill_rates_all.markup_percentage%TYPE; /* Added for Asgmt overide */
   l_assignment_precedes_task        pa_projects_all.assign_precedes_task%TYPE; /* Added for Asgmt overide */

   l_revenue_calculated_flag         VARCHAR2(1); /* Added for bug 2212852, if it is Y means it has calculated
                                                   the revenue from client extension */
   l_item_quantity                   pa_forecast_items.item_quantity%TYPE; /* Added for bug 2212852 */
   l_item_amount                     NUMBER; /* Added for bug 2212852  */
   l_bill_rate_flag                  VARCHAR(1); /* Added for bug 2212852  */
   l_status_client                   NUMBER; /* Added for bug 2212852  */
   l_dummy_rate                      NUMBER; /* Added for bug 2212852  */
   l_dummy_markup_percentage         NUMBER; /* Added for bug 2212852  */
   l_dummy_rate_source_id            NUMBER; /* Added for bug 2212852  */


lx_exp_func_curr_code   varchar2(15);
lx_project_bill_job_id  number;

BEGIN


        /* ATG Changes */

        lx_exp_func_curr_code  :=  px_exp_func_curr_code     ;
        lx_project_bill_job_id :=  px_project_bill_job_id;





  -- Initializing return status with success sothat if some unexpected error comes
  -- , we change its status from succes to error sothat we can take necessary step to rectify the problem
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_adjusted_revenue := NULL;
  l_markup_percentage  := NULL;  /* Added for Asgmt overide */

  l_revenue_calculated_flag := 'N'; /* added for bug 2212852 */
  l_item_quantity           := 0;   /* added for bug 2212852 */

  /*  Calling client extension if getting the value from ext. then ignore all
     Added for bug 2212852 */
    IF (p_forecast_item_id IS NOT NULL ) THEN
         pa_billing.Call_Calc_Bill_Amount(
                              x_transaction_type         => 'FORECAST',
                              x_expenditure_item_id      => p_forecast_item_id,
                           /*   x_sys_linkage_function   => 'ST',  */
                              x_sys_linkage_function     => p_sys_linkage_function, /* Added for Org Fcst */
                              x_amount                   => l_item_amount,
                              x_bill_rate_flag           => l_bill_rate_flag,
                              x_status                   => l_status_client,
                              x_bill_trans_currency_code => l_rate_currency_code,
                              x_bill_txn_bill_rate       => l_dummy_rate,
                              x_markup_percentage        => l_dummy_markup_percentage,
                              x_rate_source_id           => l_dummy_rate_source_id
                                 );
         l_rate_currency_code := NVL(l_rate_currency_code,p_projfunc_currency_code);
         l_projfunc_currency_code := p_projfunc_currency_code;
         IF (NVL(l_item_amount,0) <> 0) THEN
            l_revenue_calculated_flag := 'Y';
           IF (p_forecasting_type = 'PROJECT_FORECASTING') THEN

               --Bug 7184968
               BEGIN
               SELECT item_quantity
               INTO l_item_quantity
               FROM pa_forecast_items
               WHERE forecast_item_id = p_forecast_item_id;
	                      EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                   l_item_quantity := 0 ;
               End;
            End If;
            -- End Bug 7184968

            IF (NVL(l_item_quantity,0) <> 0) THEN  --Bug 7184968
               l_bill_rate := l_item_amount/l_item_quantity;
               l_raw_revenue := (l_bill_rate * p_quantity);
           ELSE
              l_bill_rate   := l_item_amount/p_quantity;
              l_raw_revenue := l_item_amount;
           END IF;
         END IF;

      /* Moved this bunch of statement from the if of project to  here, sothat it should execute every time */
	IF p_labor_schdl_discnt IS NOT NULL THEN
		l_labor_schdl_discnt := p_labor_schdl_discnt;
	END IF;

	IF p_labor_bill_rate_org_id IS NOT NULL THEN
		l_labor_bill_rate_org_id := p_labor_bill_rate_org_id;
	END IF;

	IF p_labor_std_bill_rate_schdl IS NOT NULL THEN
		l_labor_std_bill_rate_schdl := p_labor_std_bill_rate_schdl;
	END IF;
	IF p_labor_schdl_fixed_date IS NOT NULL THEN
		l_labor_schdl_fixed_date := p_labor_schdl_fixed_date;
	END IF;
	IF p_labor_sch_type IS NOT NULL THEN
		l_labor_sch_type := p_labor_sch_type;
	END IF;
	IF p_job_bill_rate_schedule_id IS NOT NULL THEN
		l_job_bill_rate_schedule_id := p_job_bill_rate_schedule_id;
	END IF;
	IF p_project_org_id IS NOT NULL THEN
		l_project_org_id := p_project_org_id;
	END IF;

        /* The following code have been added for MCB 2 */
	IF p_projfunc_currency_code IS NOT NULL THEN
		l_projfunc_currency_code := p_projfunc_currency_code;
	END IF;

        /* Added for Asgmt overide */
        IF p_assignment_precedes_task IS NOT NULL THEN
           l_assignment_precedes_task := p_assignment_precedes_task;
        END IF;
    END IF; /* end if of forecast_item_id */

  IF ( NVL(l_revenue_calculated_flag,'N') = 'N') THEN   /* added for bug 2212852 { */


  -- Selecting labor schedule discount,labor bill  rate orgnization id,labor standard bill rate
  -- schedule and labor schedule fixed date if any one of them is null then taking value from task
  -- table only if passed task id is not null if it is null then taking value from project table

  IF ( (p_labor_schdl_discnt IS NULL )OR (p_labor_bill_rate_org_id IS NULL)
        OR (p_labor_std_bill_rate_schdl IS NULL) OR (p_labor_schdl_fixed_date IS NULL)OR
           (p_labor_sch_type IS NULL)) THEN
    IF (p_task_id IS NULL ) THEN
     BEGIN
        SELECT labor_schedule_discount,labor_bill_rate_org_id,labor_std_bill_rate_schdl,
               labor_schedule_fixed_date,labor_sch_type,job_bill_rate_schedule_id,org_id,
               projfunc_currency_code, /* Added the following column for MCB2 */
               NVL(assign_precedes_task,'1') /* Added for Asgmt overide */
        INTO l_labor_schdl_discnt,l_labor_bill_rate_org_id,l_labor_std_bill_rate_schdl,
             l_labor_schdl_fixed_date,l_labor_sch_type,l_job_bill_rate_schedule_id,l_project_org_id,
            l_projfunc_currency_code, /* Added the following columns for MCB2 */
            l_assignment_precedes_task
        FROM pa_projects_all
        WHERE project_id = p_project_id;


     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         NULL;
     END;
    ELSE
     BEGIN
        SELECT labor_schedule_discount,labor_bill_rate_org_id,labor_std_bill_rate_schdl,
               labor_schedule_fixed_date,labor_sch_type
        INTO l_labor_schdl_discnt,l_labor_bill_rate_org_id,l_labor_std_bill_rate_schdl,
             l_labor_schdl_fixed_date,l_labor_sch_type
        FROM pa_tasks
        WHERE task_id = p_task_id;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         NULL;
     END;
    END IF;
  ELSE
    l_labor_schdl_discnt        := p_labor_schdl_discnt;
    l_labor_bill_rate_org_id    := p_labor_bill_rate_org_id;
    l_labor_std_bill_rate_schdl := p_labor_std_bill_rate_schdl;
    l_labor_schdl_fixed_date    := p_labor_schdl_fixed_date;
    l_labor_sch_type            := p_labor_sch_type;
    l_job_bill_rate_schedule_id := p_job_bill_rate_schedule_id;
  END IF;

      /* Moved this bunch of statement from the if of project to  here, sothat it should execute every time */
	IF p_labor_schdl_discnt IS NOT NULL THEN
		l_labor_schdl_discnt := p_labor_schdl_discnt;
	END IF;

	IF p_labor_bill_rate_org_id IS NOT NULL THEN
		l_labor_bill_rate_org_id := p_labor_bill_rate_org_id;
	END IF;

	IF p_labor_std_bill_rate_schdl IS NOT NULL THEN
		l_labor_std_bill_rate_schdl := p_labor_std_bill_rate_schdl;
	END IF;
	IF p_labor_schdl_fixed_date IS NOT NULL THEN
		l_labor_schdl_fixed_date := p_labor_schdl_fixed_date;
	END IF;
	IF p_labor_sch_type IS NOT NULL THEN
		l_labor_sch_type := p_labor_sch_type;
	END IF;
	IF p_job_bill_rate_schedule_id IS NOT NULL THEN
		l_job_bill_rate_schedule_id := p_job_bill_rate_schedule_id;
	END IF;
	IF p_project_org_id IS NOT NULL THEN
		l_project_org_id := p_project_org_id;
	END IF;

        /* The following code have been added for MCB 2 */
	IF p_projfunc_currency_code IS NOT NULL THEN
		l_projfunc_currency_code := p_projfunc_currency_code;
	END IF;

        /* Added for Asgmt overide */
        IF p_assignment_precedes_task IS NOT NULL THEN
           l_assignment_precedes_task := p_assignment_precedes_task;
        END IF;


  /* Checking if the labor schedule type is indirect then calling other api
     otherwise following the steps given below  { */

  IF ( l_labor_sch_type = 'I' ) THEN
    -- Calling burden cost API
   PA_COST.get_burdened_cost(p_project_type                   => p_project_type                  ,
                              p_project_id                    => p_project_id                    ,
                              p_task_id                       => p_task_id                       ,
                              p_item_date                     => p_item_date                     ,
                              p_expenditure_type              => p_expenditure_type              ,
                              p_schedule_type                 => l_schedule_type                 ,
                              px_exp_func_curr_code           => px_exp_func_curr_code           ,
                              p_Incurred_by_organz_id         => p_Incurred_by_organz_id         ,
                              p_raw_cost                      => p_exp_raw_cost                  ,
                              p_raw_cost_rate                 => p_raw_cost_rate                 ,
                              p_quantity                      => p_quantity                      ,
                              p_override_to_organz_id         => p_override_to_organz_id         ,
                              x_burden_cost                   => l_raw_revenue                   ,
                              x_burden_cost_rate              => l_bill_rate                     ,
                              x_return_status                 => l_x_return_status               ,
                              x_msg_count                     => x_msg_count                     ,
                              x_msg_data                      => x_msg_data);

  l_rate_currency_code   :=  px_exp_func_curr_code;
/* There was a call for PA_COST.get_projfunc_raw_burdened , it has been deleted
   for Org Forecasting */

  ELSIF (l_labor_sch_type = 'B' ) THEN
       -- Calling job id conversion procedure from resource
     PA_RESOURCE_UTILS.GetToJobId( p_forecast_job_grp_id,
                                    p_forecast_job_id,
                                    p_project_bill_job_grp_id,
                                    px_project_bill_job_id);


        /* This override is added for Assignment level override functionality ,
           it executed if the override precedence takes at assignment level i.e
           assignment_precedes_task is 'Y'                                  */

        /*------------------------------------------------------------------+
         | 1. Assignment level overrides                                    |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Assignment level          |
         |    overrides .                                                   |
         +------------------------------------------------------------------*/
 /* If the call is from Assignment api then the item_id will be null so this override will
    not execute */
 IF (p_item_id IS NOT NULL) THEN
   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL ) THEN
   --  IF ( l_assignment_precedes_task = 'Y') THEN
       BEGIN
          SELECT DECODE(asgn.bill_rate_override, NULL, NULL,
                      asgn.bill_rate_override * NVL(p_bill_rate_multiplier,1)
                      ),
               DECODE(asgn.bill_rate_override, NULL,
                      ((100 + asgn.markup_percent_override)
                           * p_raw_cost / 100),
                      (asgn.bill_rate_override * NVL(p_bill_rate_multiplier,1)
                           * p_quantity)),
                 DECODE(asgn.bill_rate_override,NULL,l_projfunc_currency_code,asgn.bill_rate_curr_override),
                 asgn.markup_percent_override,
        		 asgn.discount_percentage

          INTO   l_bill_rate,l_raw_revenue,
                 l_rate_currency_code,
                 l_markup_percentage,
				 l_discount_pct
          FROM  pa_project_assignments asgn
          WHERE asgn.assignment_id  = p_item_id;

       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           RAISE;
         WHEN NO_DATA_FOUND THEN
           l_raw_revenue := NULL;
           l_bill_rate   := NULL;
       END;
 --    END IF; /* end of l_assignment_precedes_task  flag check */
   END IF; /* end of revenue and rate check */
 END IF;


        /*------------------------------------------------------------------+
         | 2. Task job bill rate overrides                                  |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Task job bill rate        |
         |    overrides .                                                   |
         +------------------------------------------------------------------*/
  -- IT IS NOT FOR THIS PHASE
  /*
   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND p_task_id IS NOT NULL
          AND l_discount_pct IS NULL) THEN
     BEGIN
        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               (j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),
               j.rate_currency_code ,
			   j.discount_percentage
        INTO   l_bill_rate,l_raw_revenue,
               l_rate_currency_code ,-- Added for MCB2
			   l_discount_pct
        FROM    pa_job_bill_rate_overrides j
        WHERE j.task_id = p_task_id
        AND TO_DATE(p_item_date)
          BETWEEN TO_DATE(j.start_date_active)
          AND NVL(TO_DATE(j.end_date_active),
                  TO_DATE(p_item_date))
        AND j.job_id = px_project_bill_job_id;


     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;
*/

        /* This override is added for Assignment level override functionality ,
           it executed if the override precedence takes at Task level i.e
           assign_precedes_task = 'N'                                   */

        /*------------------------------------------------------------------+
         | 3. Assignment level overrides ,but Task take precedence          |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Assignment level          |
         |    overrides .                                                   |
         +------------------------------------------------------------------*/
 /* If the call is from Assignment api then the item_id will be null so this override will
    not execute */
   /*

 IF (p_item_id IS NOT NULL) THEN
   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL ) THEN
     IF ( ( l_assignment_precedes_task = 'N' and l_discount_pct is null) ) THEN -- Removed task id check to fix bug 2354746
       BEGIN
          SELECT DECODE(asgn.bill_rate_override, NULL, NULL,
                      asgn.bill_rate_override * NVL(p_bill_rate_multiplier,1)
                      ),
               DECODE(asgn.bill_rate_override, NULL,
                      ((100 + asgn.markup_percent_override)
                           * p_raw_cost / 100),
                      (asgn.bill_rate_override * NVL(p_bill_rate_multiplier,1)
                           * p_quantity)),
                 DECODE(asgn.bill_rate_override,NULL,l_projfunc_currency_code,asgn.bill_rate_curr_override),
                 asgn.markup_percent_override,
				 asgn.discount_percentage
          INTO   l_bill_rate,l_raw_revenue,
                 l_rate_currency_code,
                 l_markup_percentage,
				 l_discount_pct
          FROM  pa_project_assignments asgn
          WHERE asgn.assignment_id  = p_item_id;

       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           RAISE;
         WHEN NO_DATA_FOUND THEN
           l_raw_revenue := NULL;
           l_bill_rate   := NULL;
       END;
     END IF; -- end of l_assignment_precedes_task  flag check
  END IF; -- end of revenue and rate check
  END IF;
  */

        /*------------------------------------------------------------------+
         | 4. Project job bill rate overrides                               |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Project job bill rate     |
         |    overrides .                                                   |
         +------------------------------------------------------------------*/

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND l_discount_pct IS NULL) THEN

     BEGIN
        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               (j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),
               j.rate_currency_code,
			   j.discount_percentage /* Added for MCB2 */
        INTO   l_bill_rate,
               l_raw_revenue,
               l_rate_currency_code, /* Added for MCB2 */
			   l_discount_pct /* Added for discount percentage*/
        FROM pa_job_bill_rate_overrides j
        WHERE j.project_id = p_project_id
          /*  0.99999 added to the dates so that the starting clause of
             the between condition does not have aby function on it so
             as to better use the index  */
        AND trunc(p_item_date) + 0.99999               /* BUG#3118592 */
          BETWEEN j.start_date_active
          AND NVL(trunc(j.end_date_active) + 0.99999,       /* BUG#3118592 */
                  trunc(p_item_date) + 0.99999)		    /* BUG#3118592 */
        AND j.job_id    = px_project_bill_job_id;


     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate := NULL;
     END;
   END IF;

        /*------------------------------------------------------------+
         |5. Job based bill rate schedule for forecasting             |
         +------------------------------------------------------------+
         |    Set bill rate, raw revenue, adjusted rate, adjusted     |
         |    revenue using standard job bill rate schedule.          |
         +------------------------------------------------------------*/

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL ) THEN

     BEGIN
        SELECT DECODE(b.rate, NULL, NULL,
                      b.rate * NVL(p_bill_rate_multiplier,1)
                      ),
               DECODE(b.rate, NULL,
                      ((100 + b.markup_percentage)
                           * p_raw_cost / 100),
                      (b.rate * NVL(p_bill_rate_multiplier,1)
                           * p_quantity)),
               DECODE(NVL( l_discount_pct,l_labor_schdl_discnt), NULL, NULL,
                      (b.rate * NVL(p_bill_rate_multiplier,1)
                           * (100 - NVL( l_discount_pct,l_labor_schdl_discnt)) /100)),
               DECODE(NVL( l_discount_pct,l_labor_schdl_discnt), NULL, NULL,
                       DECODE(b.rate, NULL,
                              ((100 + b.markup_percentage)
                                    * (p_raw_cost / 100)
                                    * (100 - NVL( l_discount_pct,l_labor_schdl_discnt)) / 100),
                               ((b.rate * p_quantity)
                                        * NVL(p_bill_rate_multiplier,1)
                                        * (100 - NVL( l_discount_pct,l_labor_schdl_discnt)) / 100)
                             )
                     ),
                 DECODE(b.rate, NULL,l_projfunc_currency_code,b.rate_currency_code),
                 b.markup_percentage
        INTO   l_bill_rate,l_raw_revenue,l_adjusted_rate,l_adjusted_revenue,
               l_rate_currency_code /* Added for MCB2 */,
               l_markup_percentage /* Added for Asgmt overide */
        FROM  pa_bill_rates_all b
        WHERE b.bill_rate_sch_id  = l_job_bill_rate_schedule_id
        AND b.job_id = px_project_bill_job_id
        AND trunc(NVL(l_labor_schdl_fixed_date, p_item_date)) + 0.99999  /* BUG#3118592 */
          BETWEEN b.start_date_active
          AND NVL(trunc(b.end_date_active),trunc(NVL(l_labor_schdl_fixed_date, p_item_date))) + 0.99999;  /* BUG#3118592 */
      --   AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);    /* Commented for Bug 6041769 */


     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;
  END IF; /* Labor schedule type end if } */
 END IF; /* end if revenue calculated flag } */

  l_txn_bill_rate     := l_bill_rate; -- Removed NVL condition for bug 5079230

  IF (l_adjusted_revenue IS NOT NULL ) THEN
      l_txn_raw_revenue := NVL(l_adjusted_revenue,0);
  ELSE
     l_txn_raw_revenue   := NVL(l_raw_revenue,0);
  END IF;

  IF ( (l_txn_raw_revenue IS NULL) OR (l_txn_raw_revenue = 0) ) THEN
    RAISE l_no_revenue;
  END IF;

          x_raw_revenue       := NVL(l_txn_raw_revenue,0) ;
          x_bill_rate         := l_txn_bill_rate ; -- Removed NVL condition for bug 5079230
          x_markup_percentage := l_markup_percentage; /* Added for Asgmt overide */
          x_txn_currency_code := l_rate_currency_code; /* Added for Org Forecasting */

  x_return_status := l_x_return_status;

EXCEPTION
 WHEN l_no_revenue THEN
    x_bill_rate  := NULL;
    x_raw_revenue:= 0;
    x_markup_percentage := NULL; /* Added for Asgmt overide */
    /* Checking error condition. Added for bug 2218386 */
    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
      PA_UTILS.add_message('PA', 'PA_FCST_NO_BILL_RATE');
    END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count     := 1;
   x_msg_data      := 'PA_FCST_NO_BILL_RATE';
 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count     := 1;
   x_msg_data      := SUBSTR(SQLERRM,1,30);

   /* ATG Changes */
         px_project_bill_job_id  :=  lx_project_bill_job_id;
         px_exp_func_curr_code  :=  lx_exp_func_curr_code     ;
         x_bill_rate       := null;
         x_raw_revenue      := null;
         x_markup_percentage   := null;
         x_txn_currency_code   := null;

    /* Checking error condition. Added for bug 2218386 */

   IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_REVENUE',  /* Moved this here to fix bug 2434663 */
                               p_procedure_name   => 'Requirement_Rev_Amt');
      RAISE;
    END IF;


END Requirement_Rev_Amt;



-- This procedure will calculate the raw revenue and bill amount from one of the 12 criterias on the basis
-- of passed parameters
-- Input parameters
-- Parameters                   Type           Required      Description
-- P_project_id                 NUMBER          YES          Project Id
-- P_task_id                    NUMBER          NO           Task Id  for the given project
-- P_bill_rate_multiplier       NUMBER          YES          Bill rate multiplier for calculating the revenue
--                                                           and rate
-- P_quantity                   NUMBER          YES          Quantity in Hours
-- P_person_id                  NUMBER          YES          Person Id
-- P_raw_cost                   NUMBER          YES          Row cost
-- P_item_date                  DATE            YES          Forecast Item date
-- P_labor_schdl_discnt         NUMBER          NO           Labour schedule discount
-- P_labor_bill_rate_org_id     NUMBER          NO           Bill rate organization id
-- P_labor_std_bill_rate_schdl  VARCHAR2        NO           Standard bill rate schedule
-- P_labor_schdl_fixed_date     DATE            NO           Schedule date
-- P_bill_job_grp_id            NUMBER          NO           Project Group Id
-- P_item_id                    NUMBER          NO           Unique id
-- P_forecast_item_id           NUMBER          NO           Unique identifier for forecast item used in
--                                                           client extension
-- P_forecasting_type           VARCHAR2        YES          It tells that from where we are calling extn.
-- P_labor_sch_type             VARCHAR2        NO           Labor schedule type
-- P_project_org_id             NUMBER          NO           Project Org ID
-- P_project_type               VARCHAR2        YES          Project Type
-- P_expenditure_type           VARCHAR2        YES          Expenditure Type
-- p_exp_func_curr_code        VARCHAR2        YES          Expenditure functional currency code
-- P_incurred_by_organz_id      NUMBER          YES          Incurred by organz id
-- P_raw_cost_rate              NUMBER          YES          Raw cost rate
-- P_override_to_organz_id      NUMBER          YES          Override to organz id
--
-- Out parameters
--
-- X_bill_rate                  NUMBER          YES
-- X_raw_revenue                NUMBER          YES
-- X_rev_currency_code          VARCHAR2        YES

PROCEDURE Assignment_Rev_Amt(
      p_project_id                   IN     NUMBER,
      p_task_id                      IN     NUMBER      DEFAULT NULL,
      p_bill_rate_multiplier         IN     NUMBER      DEFAULT NULL,
      p_quantity                     IN     NUMBER,
      p_person_id                    IN     NUMBER,
      p_raw_cost                     IN     NUMBER      DEFAULT NULL,
      p_item_date                    IN     DATE,
      p_labor_schdl_discnt           IN     NUMBER      DEFAULT NULL,
      p_labor_bill_rate_org_id       IN     NUMBER      DEFAULT NULL,
      p_labor_std_bill_rate_schdl    IN     VARCHAR2    DEFAULT NULL,
      p_labor_schdl_fixed_date       IN     DATE        DEFAULT NULL,
      p_bill_job_grp_id              IN     NUMBER      DEFAULT NULL,
      p_item_id                      IN     NUMBER      DEFAULT NULL, /* change from forecast item id */
                                                                      /*  to item id for bug 2212852 */
      p_labor_sch_type               IN     VARCHAR2    DEFAULT NULL,
      p_project_org_id               IN     NUMBER      DEFAULT NULL,
      p_project_type                 IN     VARCHAR2    DEFAULT NULL,
      p_expenditure_type             IN     VARCHAR2    DEFAULT NULL,
      p_exp_func_curr_code           IN     VARCHAR2    DEFAULT NULL,
      p_incurred_by_organz_id        IN     NUMBER      DEFAULT NULL,
      p_raw_cost_rate                IN     NUMBER      DEFAULT NULL,
      p_override_to_organz_id        IN     NUMBER      DEFAULT NULL,
      p_emp_bill_rate_schedule_id    IN     VARCHAR2    DEFAULT NULL,
      p_resource_job_id              IN     NUMBER,
      p_exp_raw_cost                 IN     NUMBER,
      p_expenditure_org_id           IN     NUMBER,
      p_projfunc_currency_code       IN     VARCHAR2, /* Added for MCB2 */
      p_assignment_precedes_task     IN     VARCHAR2, /* Added for Asgmt overide */
      p_forecast_item_id             IN     NUMBER DEFAULT NULL, /* added para for bug 2212852 */
      p_forecasting_type             IN     VARCHAR2 DEFAULT 'PROJECT_FORECASTING', /* added para for bug 2212852 */
      p_sys_linkage_function         IN     VARCHAR2 , /* Added for Org Forecasting */
      x_bill_rate                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_raw_revenue                  OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_rev_currency_code            OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_markup_percentage            OUT    NOCOPY NUMBER,  /* Added for Asgmt overide */ --File.Sql.39 bug 4440895
      x_txn_currency_code            OUT    NOCOPY VARCHAR2,/*Added for Org Forecasting */ --File.Sql.39 bug 4440895
      x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      /*Bill rate Discount */
      p_mcb_flag                     IN     VARCHAR2  DEFAULT NULL,
      p_denom_raw_cost               IN     NUMBER    DEFAULT NULL,
      p_denom_curr_code              IN     VARCHAR2  DEFAULT NULL,
      p_called_process               IN     VARCHAR2  DEFAULT NULL,
      p_job_bill_rate_schedule_id    IN     NUMBER    DEFAULT NULL,
     /* Added for bug 2668753 */
      p_project_raw_cost             IN     NUMBER    DEFAULT NULL,
      p_project_currency_code        IN     VARCHAR2  DEFAULT NULL,
      x_adjusted_bill_rate           OUT    NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS

   l_raw_revenue                    NUMBER :=null; -- store the raw revenue
                                                   -- from one of the raw revenue calculating
                                                   -- criteria
   l_bill_rate                      NUMBER :=null; -- store bill amount
                                                   -- from one of the bill amount calculating
                                                   -- criteria
   l_schedule_type                  VARCHAR2(50) := 'REVENUE';

   l_x_return_status                VARCHAR2(50);  -- store the return status
                                                   -- and used it to validate whether the
                                                   -- calling procedure has run successfully
                                                   -- or encounter any error
  l_adjusted_revenue                NUMBER;        -- Local variable
  l_adjusted_rate                   NUMBER:=NULL;        -- Local variable
  l_labor_schdl_discnt              NUMBER;        -- store labor schedule discount
  l_labor_bill_rate_org_id          NUMBER;        -- store labor bill rate organization id
  l_labor_std_bill_rate_schdl       VARCHAR2(20);   -- store labor standard bill rate schedule
  l_labor_schdl_fixed_date          DATE;          -- store labor schedule fixed date
  l_labor_sch_type                  VARCHAR2(1);   -- store labor schedule type
  l_expenditure_currency_code       gl_sets_of_books.currency_code%TYPE  := null;
  l_bill_job_grp_id                 pa_projects_all.bill_job_group_id%TYPE; -- store bill job group id
  l_project_org_id                  pa_projects_all.org_id%TYPE;            -- store project org id
  l_rev_currency_code               pa_projects_all.project_currency_code%TYPE; -- store revenue currency code
  l_emp_bill_rate_schedule_id       NUMBER;
  l_job_bill_rate_schedule_id       NUMBER;

  /* Added for MCB2 */
   l_txn_bill_rate                        NUMBER :=null; -- store bill amount transaction curr.
   l_txn_raw_revenue                      NUMBER :=null; -- store the raw revenue trans. curr.
   l_rate_currency_code                   pa_bill_rates_all.rate_currency_code%TYPE;

   l_projfunc_currency_code          pa_projects_all.projfunc_currency_code%TYPE;

   l_markup_percentage               pa_bill_rates_all.markup_percentage%TYPE; /* Added for Asgmt overide */
   l_assignment_precedes_task        pa_projects_all.assign_precedes_task%TYPE; /* Added for Asgmt overide */

   l_revenue_calculated_flag         VARCHAR2(1); /* Added for bug 2212852, if it is Y means it has calculated
                                                   the revenue from client extension */
   l_item_quantity                   pa_forecast_items.item_quantity%TYPE; /* Added for bug 2212852 */
   l_item_amount                     NUMBER; /* Added for bug 2212852  */
   l_bill_rate_flag                  VARCHAR2(1); /* Added for bug 2212852  */
   l_status_client                   NUMBER; /* Added for bug 2212852  */
   l_dummy_rate                      NUMBER; /* Added for bug 2212852  */
   l_dummy_markup_percentage         NUMBER; /* Added for bug 2212852  */
   l_dummy_rate_source_id            NUMBER; /* Added for bug 2212852  */
   l_discount_percentage             NUMBER; /* Added for Transfer Price changes */
   l_amount_calculation_code         varchar2(1); /* Added for Transfer Price changes */
 /* Added for bug 2668753 */
   l_mcb_cost_flag                   varchar2(50) := null;
   l_mcb_raw_cost                    number := null;
   l_mcb_currency_code               varchar2(50) := null;
   l_called_process                  NUMBER; /*Added for Doosan rate api enhancement */
   l_txn_adjusted_bill_rate                        NUMBER :=null; --4038485
BEGIN

   -- Initializing return status with success so that if some unexpected error comes
   -- , we change its status from succes to error so that we can take necessary step to rectify the problem
   l_x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_markup_percentage := NULL; /* Added for Asgmt overide */

  l_revenue_calculated_flag := 'N'; /* added for bug 2212852 */
  l_item_quantity           := 0; /* added for bug 2212852 */

   l_adjusted_revenue := NULL;

 /* Changes for bug 2668753 */

  /* Adding the following piece of code for Doosan rate api changes . */

        l_called_process := 0;

     IF P_called_process ='PROJECT_LEVEL_PLANNING' THEN
        l_called_process :=1;
     END IF;

     IF P_called_process ='TASK_LEVEL_PLANNING' THEN
        l_called_process :=2;
     END IF;

  /* Bug 2668753 : Get the BTC_COST_BASE_REV_CODE from pa_projects_all table */
IF ( nvl(p_mcb_flag,'N') = 'Y' ) THEN
BEGIN
   /* Added the following nvl so that code doesn't break even if upgrade script fails - For bug 2668753 */

   select nvl(BTC_COST_BASE_REV_CODE,'EXP_TRANS_CURR')
   into l_mcb_cost_flag
   from pa_projects_all
   where project_id = p_project_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE ;
END;

    IF (l_mcb_cost_flag = 'EXP_TRANS_CURR') THEN
     l_mcb_raw_cost :=  p_denom_raw_cost;
     l_mcb_currency_code := p_denom_curr_code;

    ELSIF (l_mcb_cost_flag = 'EXP_FUNC_CURR') THEN
     l_mcb_raw_cost := p_exp_raw_cost;
     l_mcb_currency_code := p_exp_func_curr_code;

    ELSIF (l_mcb_cost_flag = 'PROJ_FUNC_CURR') THEN
     l_mcb_raw_cost  := p_raw_cost;
     l_mcb_currency_code := p_projfunc_currency_code;

    ELSIF (l_mcb_cost_flag = 'PROJECT_CURR') THEN
     l_mcb_raw_cost := p_project_raw_cost;
     l_mcb_currency_code := p_project_currency_code;

    END IF;
/* Added for bug 2742778 */
ELSE
     l_mcb_raw_cost  := p_raw_cost;
     l_mcb_currency_code := p_projfunc_currency_code;
/* End of changes for bug 2742778 */
END IF;
/* End of changes for bug 2668753 */


   IF (p_exp_func_curr_code IS NOT NULL) THEN
     l_expenditure_currency_code := p_exp_func_curr_code;
   END IF;



  IF (p_project_id IS NOT NULL and p_called_process is NULL) THEN
    BEGIN
      SELECT projfunc_currency_code
      INTO l_rev_currency_code
      FROM pa_projects_all
      WHERE project_id = p_project_id;
      x_rev_currency_code  := l_rev_currency_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      NULL;
    END;
  END IF;

    /*  Calling client extension if getting the value from ext. then ignore all
    Added for bug 2212852 */
    IF (p_forecast_item_id IS NOT NULL ) THEN
         pa_billing.Call_Calc_Bill_Amount(
                              x_transaction_type         => 'FORECAST',
                              x_expenditure_item_id      => p_forecast_item_id,
                            /*  x_sys_linkage_function   => 'ST',  */
                              x_sys_linkage_function     => p_sys_linkage_function, /* Added for Org Fcst */
                              x_amount                   => l_item_amount,
                              x_bill_rate_flag           => l_bill_rate_flag,
                              x_status                   => l_status_client,
                              x_bill_trans_currency_code => l_rate_currency_code,
                              x_bill_txn_bill_rate       => l_dummy_rate,
                              x_markup_percentage        => l_dummy_markup_percentage,
                              x_rate_source_id           => l_dummy_rate_source_id
                                 );
         l_rate_currency_code := NVL(l_rate_currency_code,p_projfunc_currency_code);
         l_projfunc_currency_code := p_projfunc_currency_code;
         IF (NVL(l_item_amount,0) <> 0) THEN
            l_revenue_calculated_flag := 'Y';
           IF (p_forecasting_type = 'PROJECT_FORECASTING') THEN

               --Bug 7184968
               BEGIN
               SELECT item_quantity
               INTO l_item_quantity
               FROM pa_forecast_items
               WHERE forecast_item_id = p_forecast_item_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                   l_item_quantity := 0 ;
               End;
            End If;
            -- End Bug 7184968

            IF (NVL(l_item_quantity,0) <> 0) THEN  --Bug 7184968
               l_bill_rate := l_item_amount/l_item_quantity;

               l_raw_revenue := (l_bill_rate * p_quantity);
           ELSE
              l_bill_rate   := l_item_amount/p_quantity;
              l_raw_revenue := l_item_amount;
           END IF;
         END IF;
        /* Moved these bunch of statement from if of project to here so that it execute every time */
	IF p_labor_schdl_discnt IS NOT NULL THEN
		l_labor_schdl_discnt := p_labor_schdl_discnt;
	END IF;

	IF p_labor_bill_rate_org_id IS NOT NULL THEN
		l_labor_bill_rate_org_id := p_labor_bill_rate_org_id;
	END IF;

	IF p_labor_std_bill_rate_schdl IS NOT NULL THEN
		l_labor_std_bill_rate_schdl := p_labor_std_bill_rate_schdl;
	END IF;
	IF p_labor_schdl_fixed_date IS NOT NULL THEN
		l_labor_schdl_fixed_date := p_labor_schdl_fixed_date;
	END IF;
	IF p_labor_sch_type IS NOT NULL THEN
		l_labor_sch_type := p_labor_sch_type;
	END IF;
	IF p_bill_job_grp_id IS NOT NULL THEN
		l_bill_job_grp_id := p_bill_job_grp_id;
	END IF;
	IF p_project_org_id IS NOT NULL THEN
		l_project_org_id := p_project_org_id;
	END IF;
	IF p_emp_bill_rate_schedule_id IS NOT NULL THEN
		l_emp_bill_rate_schedule_id := p_emp_bill_rate_schedule_id;
	END IF;

        /* The following code have been added for MCB 2 */
        IF p_projfunc_currency_code IS NOT NULL THEN
                l_projfunc_currency_code := p_projfunc_currency_code;
        END IF;

        /* Added for Asgmt overide */
	IF p_assignment_precedes_task IS NOT NULL THEN
	   l_assignment_precedes_task := p_assignment_precedes_task;
	END IF;
    END IF; /* end if of forecast_item_id */

  IF ( NVL(l_revenue_calculated_flag,'N') = 'N' ) THEN   /* added for bug 2212852 { */


  -- Selecting labor schedule discount,labor bill  rate orgnization id,labor standard bill rate
  -- schedule and labor schedule fixed date if any one of them is null then taking value from task
  -- table only if passed task id is not null if it is null then taking value from project table
/* bug#4245956, added the p_called_Process='TASK or PROJECT' for RATE API */
  IF ( ((p_labor_schdl_discnt IS NULL )OR (p_labor_bill_rate_org_id IS NULL)
        OR (p_labor_std_bill_rate_schdl IS NULL) OR (p_labor_schdl_fixed_date IS NULL)OR
           (p_labor_sch_type IS NULL)  OR (p_bill_job_grp_id IS NULL)OR
            (p_project_org_id IS NULL)) AND (p_called_process is NULL  OR
                                             ((p_called_process = 'TASK_LEVEL_PLANNING' OR
                                               p_called_process = 'PROJECT_LEVEL_PLANNING'
                                              ))) ) THEN
    IF (p_task_id IS NULL ) THEN
     BEGIN
       SELECT labor_schedule_discount,labor_bill_rate_org_id,labor_std_bill_rate_schdl,
               labor_schedule_fixed_date,labor_sch_type,bill_job_group_id,org_id,
               emp_bill_rate_schedule_id,job_bill_rate_schedule_id,
               projfunc_currency_code, /* Added the following column for MCB2 */
               NVL(assign_precedes_task,'1') /* Added for Asgmt overide */
       INTO l_labor_schdl_discnt,l_labor_bill_rate_org_id,l_labor_std_bill_rate_schdl,
            l_labor_schdl_fixed_date,l_labor_sch_type,l_bill_job_grp_id,l_project_org_id,
            l_emp_bill_rate_schedule_id,l_job_bill_rate_schedule_id,
            l_projfunc_currency_code, /* Added the following columns for MCB2 */
            l_assignment_precedes_task
        FROM pa_projects_all
        WHERE project_id = p_project_id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         NULL;
     END;
    ELSE
     BEGIN
        SELECT labor_schedule_discount,labor_bill_rate_org_id,labor_std_bill_rate_schdl,
               labor_schedule_fixed_date,labor_sch_type
        INTO l_labor_schdl_discnt,l_labor_bill_rate_org_id,l_labor_std_bill_rate_schdl,
             l_labor_schdl_fixed_date,l_labor_sch_type
        FROM pa_tasks
        WHERE task_id = p_task_id;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         NULL;
     END;
    END IF;
  ELSE
    l_labor_schdl_discnt        := p_labor_schdl_discnt;
    l_labor_bill_rate_org_id    := p_labor_bill_rate_org_id;
    l_labor_std_bill_rate_schdl := p_labor_std_bill_rate_schdl;
    l_labor_schdl_fixed_date    := p_labor_schdl_fixed_date;
    l_labor_sch_type            := p_labor_sch_type;
    l_bill_job_grp_id           := p_bill_job_grp_id;
    l_project_org_id            := p_project_org_id;
    l_job_bill_rate_schedule_id := p_job_bill_rate_schedule_id;
  END IF;


/* Moved these bunch of statement from if of project to here so that it execute every time */
	IF p_labor_schdl_discnt IS NOT NULL THEN
		l_labor_schdl_discnt := p_labor_schdl_discnt;
	END IF;

	IF p_labor_bill_rate_org_id IS NOT NULL THEN
		l_labor_bill_rate_org_id := p_labor_bill_rate_org_id;
	END IF;

	IF p_labor_std_bill_rate_schdl IS NOT NULL THEN
		l_labor_std_bill_rate_schdl := p_labor_std_bill_rate_schdl;
	END IF;
	IF p_labor_schdl_fixed_date IS NOT NULL THEN
		l_labor_schdl_fixed_date := p_labor_schdl_fixed_date;
	END IF;
	IF p_labor_sch_type IS NOT NULL THEN
		l_labor_sch_type := p_labor_sch_type;
	END IF;
	IF p_bill_job_grp_id IS NOT NULL THEN
		l_bill_job_grp_id := p_bill_job_grp_id;
	END IF;
	IF p_project_org_id IS NOT NULL THEN
		l_project_org_id := p_project_org_id;
	END IF;
	IF p_emp_bill_rate_schedule_id IS NOT NULL THEN
		l_emp_bill_rate_schedule_id := p_emp_bill_rate_schedule_id;
	END IF;

        IF p_job_bill_rate_schedule_id IS NOT NULL THEN
                  l_job_bill_rate_schedule_id := p_job_bill_rate_schedule_id;
        END IF;

        /* The following code have been added for MCB 2 */
        IF p_projfunc_currency_code IS NOT NULL THEN
                l_projfunc_currency_code := p_projfunc_currency_code;
        END IF;

        /* Added for Asgmt overide */
	IF p_assignment_precedes_task IS NOT NULL THEN
	   l_assignment_precedes_task := p_assignment_precedes_task;
	END IF;

 /* Checking if the labor schedule type is indirect then calling
    other api otherwise following the steps given be low  { */

/* As the revenue is generated by applying burden on mcb_raw_cost when labor_schd_type is 'Indirect'
   changing the p_exp_raw_cost and l_expenditure_currency_code to mcb values -bug 2742778*/

  IF ( l_labor_sch_type = 'I' ) THEN
    -- Calling burden cost API. This api will return the revnue so will skip the rest steps
   PA_COST.get_burdened_cost(p_project_type                   => p_project_type                  ,
                              p_project_id                    => p_project_id                    ,
                              p_task_id                       => p_task_id                       ,
                              p_item_date                     => p_item_date                     ,
                              p_expenditure_type              => p_expenditure_type              ,
                              p_schedule_type                 => l_schedule_type                 ,
                              px_exp_func_curr_code           => l_mcb_currency_code           ,
                              p_Incurred_by_organz_id         => p_Incurred_by_organz_id         ,
                              p_raw_cost                      => l_mcb_raw_cost                  ,
                              p_raw_cost_rate                 => p_raw_cost_rate                 ,
                              p_quantity                      => p_quantity                      ,
                              p_override_to_organz_id         => p_override_to_organz_id         ,
                              x_burden_cost                   => l_raw_revenue                   ,
                              x_burden_cost_rate              => l_bill_rate                     ,
                              x_return_status                 => l_x_return_status               ,
                              x_msg_count                     => x_msg_count                     ,
                              x_msg_data                      => x_msg_data);

/*  l_rate_currency_code  := l_expenditure_currency_code; -Commented for bug 2742778 and added the following line */

   l_rate_currency_code := l_mcb_currency_code;

/* There was a call for PA_COST.get_projfunc_raw_burdened , it has been deleted
   for Org Forecasting */

  ELSIF (l_labor_sch_type = 'B' ) THEN

        /* This override is added for Assignment level override functionality ,
           it executed if the override precedence takes at assignment level i.e
           assignment_precedes_task is 'Y'                                  */

        /*------------------------------------------------------------------+
         | 1. Assignment level overrides                                    |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Assignment level          |
         |    overrides .                                                   |
         +------------------------------------------------------------------*/
 /* If the call is from Assignment api then the item_id will be null so this override will
    not execute */
/* Changes done for bug 2668753. Whenever MCB is 'Y' the denom_raw_cost and denom_curr_code
   are changed to l_mcb_raw_cost and l_mcb_currency_code  */
 IF (p_item_id IS NOT NULL) THEN
   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL ) THEN
     IF ( l_assignment_precedes_task = 'Y') THEN
      IF (p_mcb_flag ='Y') THEN
        BEGIN
          SELECT DECODE(asgn.bill_rate_override, NULL, NULL,
                      asgn.bill_rate_override * NVL(p_bill_rate_multiplier,1)),
               DECODE(asgn.bill_rate_override, NULL,
               PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(((100 + asgn.markup_percent_override)
                           * l_mcb_raw_cost / 100),l_mcb_currency_code),
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT ((asgn.bill_rate_override *
                           NVL(p_bill_rate_multiplier,1) * p_quantity),asgn.bill_rate_curr_override)),
                 DECODE(asgn.bill_rate_override,NULL,l_mcb_currency_code,asgn.bill_rate_curr_override),
                 asgn.markup_percent_override,
                 'O',
                  asgn.discount_percentage
          INTO   l_bill_rate,l_raw_revenue,
                 l_rate_currency_code,
                 l_markup_percentage,
                 l_amount_calculation_code,
                 l_discount_percentage
          FROM  pa_project_assignments asgn
          WHERE asgn.assignment_id  = p_item_id;

        EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           RAISE;
         WHEN NO_DATA_FOUND THEN
           l_raw_revenue := NULL;
           l_bill_rate   := NULL;
        END;
     ELSE
       BEGIN
          SELECT DECODE(asgn.bill_rate_override, NULL, NULL,
                      asgn.bill_rate_override * NVL(p_bill_rate_multiplier,1)
                      ),
               DECODE(asgn.bill_rate_override, NULL,
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(((100 + asgn.markup_percent_override)
                           * p_raw_cost / 100),l_projfunc_currency_code),
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((asgn.bill_rate_override
                           * NVL(p_bill_rate_multiplier,1)
                           * p_quantity),asgn.bill_rate_curr_override)),
                 DECODE(asgn.bill_rate_override,NULL,l_projfunc_currency_code,asgn.bill_rate_curr_override),
                 asgn.markup_percent_override,
                 'O',
                  asgn.discount_percentage
          INTO   l_bill_rate,l_raw_revenue,
                 l_rate_currency_code,
                 l_markup_percentage,
                 l_amount_calculation_code,
                 l_discount_percentage
          FROM  pa_project_assignments asgn
          WHERE asgn.assignment_id  = p_item_id;

       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           RAISE;
         WHEN NO_DATA_FOUND THEN
           l_raw_revenue := NULL;
           l_bill_rate   := NULL;
       END;
      END IF; /* mcb flag */
     END IF; /* end of l_assignment_precedes_task  flag check */
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1000 Disc. Percent: ' || l_discount_percentage ||
			      'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
   END IF; /* end of revenue and rate check */
 END IF;



      /* When the procedure is called from finnancil planning api then
        the overrides should be used depending upon the value of p_called_process.
        If p_called_process ='PROJECT_LEVEL_PLANNING' THEN only project level overrides should be used and
        if  p_called_process ='TASK_LEVEL_PLANNING' THEN only task level overrides should be used .
        This check is implemented by the parameter l_called_process. */

        /*-------------------------------------------------------------+
         | 2. Emp Bill Rate Overrides for Task                         |
         +-------------------------------------------------------------+
         |    Set bill rate and raw revenue using employee bill rate   |
         |    overrides for Task                                       |
         +-------------------------------------------------------------*/
   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL and (p_called_process = 'PA' or p_called_process ='TASK_LEVEL_PLANNING')
        and l_discount_percentage is null) THEN

   DECLARE

     -- This cursor will select the bill rate and raw revenue on the basis of passed parameters i.e.
     -- if task id is not null then select will bring the task id row

     CURSOR C_Task IS SELECT o.rate * NVL(p_bill_rate_multiplier,1) b_rate,
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((o.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),o.rate_currency_code) r_revenue,
                          o.rate_currency_code,
                          'O',
                           o.discount_percentage
                   FROM   pa_emp_bill_rate_overrides o
                   WHERE  o.person_id+0 = p_person_id
                   AND    o.task_id = p_task_id
                   AND p_item_date
                     BETWEEN o.start_date_active
                     AND NVL(o.end_date_active,p_item_date);

      l_true                         BOOLEAN := FALSE; --Flag is used to determine that wheather the cursor
                                                       -- is returning more than one row or not.
      l_more_than_one_row            EXCEPTION;        -- Local exception using to check that cursor should not return
                                                       -- more than one row

   BEGIN
      -- Opening cursor and fetching row

      FOR l_v_c_task IN C_Task LOOP
        -- Checking if the cursor is returning more than one row then error out
        IF (l_true) THEN
          RAISE l_more_than_one_row;
        ELSE
          l_true := TRUE;
        END IF;

        -- Assigning the raw revenue to the local variable
        l_raw_revenue      := l_v_c_task.r_revenue;

        -- Assigning the bill rate to the local variable
        l_bill_rate        := l_v_c_task.b_rate;


        -- Assigning the bill rate currency to the local variable for MCB2
        l_rate_currency_code        := l_v_c_task.rate_currency_code;


        --Assigning Amount_calculation_code to the local variable.
        l_amount_calculation_code := 'O' ;

        --Assigning discount_percentage to the local variable
        l_discount_percentage := l_v_c_task.discount_percentage ;


     END LOOP;
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1001 Disc. Percent: ' || l_discount_percentage ||
			      'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;

   EXCEPTION
     WHEN l_more_than_one_row THEN
      RAISE;
     WHEN NO_DATA_FOUND THEN
      l_raw_revenue := NULL;
      l_bill_rate   := NULL;
   END;

 END IF;


        /* This override is added for Assignment level override functionality ,
           it executed if the override precedence takes at Task level i.e
           assign_precedes_task = 'N'                                   */

        /*------------------------------------------------------------------+
         | 7. Assignment level overrides ,but Task take precedence          |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Assignment level          |
         |    overrides .                                                   |
         +------------------------------------------------------------------*/
 /* If the call is from Assignment api then the item_id will be null so this override will
    not execute */
/* Changes done for bug 2668753. Whenever MCB is 'Y' the denom_raw_cost and denom_curr_code
   are changed to l_mcb_raw_cost and l_mcb_currency_code  */

 IF (p_item_id IS NOT NULL ) THEN
   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL and l_discount_percentage is null ) THEN
     IF ( ( l_assignment_precedes_task = 'N') ) THEN /* Removed task id check to fix bug 2354746 */
      IF (p_mcb_flag ='Y') then
        BEGIN
          SELECT DECODE(asgn.bill_rate_override, NULL, NULL,
                      asgn.bill_rate_override * NVL(p_bill_rate_multiplier,1)),
               DECODE(asgn.bill_rate_override, NULL,
               PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(((100 + asgn.markup_percent_override)
                           * l_mcb_raw_cost / 100),l_mcb_currency_code),
                PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((asgn.bill_rate_override
                           * NVL(p_bill_rate_multiplier,1)
                           * p_quantity),asgn.bill_rate_curr_override)),
                 DECODE(asgn.bill_rate_override,NULL,l_mcb_currency_code,asgn.bill_rate_curr_override),
                 asgn.markup_percent_override,
                 'O',
                 asgn.discount_percentage
          INTO   l_bill_rate,l_raw_revenue,
                 l_rate_currency_code,
                 l_markup_percentage,
                 l_amount_calculation_code,
  		 l_discount_percentage
          FROM  pa_project_assignments asgn
          WHERE asgn.assignment_id  = p_item_id;

        EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           RAISE;
         WHEN NO_DATA_FOUND THEN
           l_raw_revenue := NULL;
           l_bill_rate   := NULL;
        END;
     ELSE
       BEGIN
          SELECT DECODE(asgn.bill_rate_override, NULL, NULL,
                      asgn.bill_rate_override * NVL(p_bill_rate_multiplier,1)
                      ),
               DECODE(asgn.bill_rate_override, NULL,
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(((100 + asgn.markup_percent_override)
                           * p_raw_cost / 100),l_projfunc_currency_code),
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((asgn.bill_rate_override
                           * NVL(p_bill_rate_multiplier,1)
                           * p_quantity),asgn.bill_rate_curr_override)),
                 DECODE(asgn.bill_rate_override,NULL,l_projfunc_currency_code,asgn.bill_rate_curr_override),
                 asgn.markup_percent_override,
                 'O',
                 asgn.discount_percentage
          INTO   l_bill_rate,l_raw_revenue,
                 l_rate_currency_code,
                 l_markup_percentage,
                 l_amount_calculation_code,
	         l_discount_percentage
          FROM  pa_project_assignments asgn
          WHERE asgn.assignment_id  = p_item_id;

       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           RAISE;
         WHEN NO_DATA_FOUND THEN
           l_raw_revenue := NULL;
           l_bill_rate   := NULL;
       END;
      END IF; /* mcb flag */
   IF g1_debug_mode  = 'Y' THEN
       pa_debug.write_file('LOG','1111 Disc. Percent: ' || l_discount_percentage || 'Revenue : ' || l_raw_revenue );
   END IF;
     END IF; /* end of l_assignment_precedes_task  flag check */
   END IF; /* end of revenue and rate check */
 END IF;

        /*-------------------------------------------------------------+
         | 8. Emp Bill Rate Overrides for Project                      |
         +-------------------------------------------------------------+
         |    Set bill rate and raw revenue using employee bill rate   |
         |    overrides for Project                                    |
         +-------------------------------------------------------------*/
   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL  and l_discount_percentage is null) THEN

   DECLARE

     -- This cursor will select the bill rate and raw revenue on the basis of passed parameters i.e.
     -- if task id is null or not null then it will select according to the project id.
     -- select will bring all the raws except the row/rows which is already selected in
     -- task level select

     CURSOR C_Project IS
                   SELECT o2.rate * NVL(p_bill_rate_multiplier,1) b_rate,
                          PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((o2.rate *
                            NVL(p_bill_rate_multiplier,1) * p_quantity),o2.rate_currency_code) r_revenue,
                           o2.rate_currency_code,
                           'O',
                           o2.discount_percentage
                   FROM   pa_emp_bill_rate_overrides o2
                   WHERE  o2.person_id  = p_person_id
                   AND    o2.project_id = p_project_id
		    AND    l_called_process <>2  /*Added for Doosan rate api change */
                   AND p_item_date
                     BETWEEN o2.start_date_active
                     AND NVL(o2.end_date_active,p_item_date);

      l_true                         BOOLEAN := FALSE; --Flag is used to determine that wheather the cursor
                                                       -- is returning more than one row or not.
      l_more_than_one_row            EXCEPTION;        -- Local exception using to check that cursor should not return
                                                       -- more than one row

   BEGIN
      -- Opening cursor and fetching row

      FOR l_v_c_project IN C_Project LOOP
        -- Checking if the cursor is returning more than one row then error out
        IF (l_true) THEN
          RAISE l_more_than_one_row;
        ELSE
          l_true := TRUE;
        END IF;

        -- Assigning the raw revenue to the local variable
        l_raw_revenue      := l_v_c_project.r_revenue;

        -- Assigning the bill rate to the local variable
        l_bill_rate        := l_v_c_project.b_rate;


        -- Assigning the bill rate currency to the local variable for MCB2
        l_rate_currency_code        := l_v_c_project.rate_currency_code;


        --Assigning Amount_calculation_code to the local variable.
        l_amount_calculation_code := 'O' ;

        --Assigning discount_percentage to the local variable
        l_discount_percentage := l_v_c_project.discount_percentage ;


   END LOOP;

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1002 Disc. Percent: ' || l_discount_percentage ||
	  'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
   EXCEPTION
     WHEN l_more_than_one_row THEN
      RAISE;
     WHEN NO_DATA_FOUND THEN
      l_raw_revenue := NULL;
      l_bill_rate   := NULL;
   END;
 END IF;

         /*---------------------------------------------------------------+
         | 3. Task Job Bill Rate Overrides with Task Job Assn. Overrides |
         +---------------------------------------------------------------+
         |    Set bill rate and raw revenue using Task job bill rate     |
         |    overrides with Task Job Assignment Overrides.              |
         +---------------------------------------------------------------*/
 -- IT IS NOT IN THIS Forecasting so added p_called_process
  IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL
        and l_discount_percentage is null and (p_called_process = 'PA' OR p_called_process='TASK_LEVEL_PLANNING')) THEN

     BEGIN

        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               PA_CURRENCY.ROUND_CURRENCY_AMT(j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),
                j.rate_currency_code,
                decode(j.discount_percentage,NULL,'O','T'),
 	        j.discount_percentage
        INTO   l_bill_rate,l_raw_revenue,
               l_rate_currency_code,
               l_amount_calculation_code,
               l_discount_percentage
        FROM pa_job_assignment_overrides a, pa_job_bill_rate_overrides j
        WHERE j.task_id = p_task_id
        AND p_item_date
          BETWEEN j.start_date_active
          AND NVL(j.end_date_active,p_item_date)
        AND j.job_id+0 = a.job_id
        AND a.person_id = p_person_id
        AND a.task_id = p_task_id
        AND p_item_date
          BETWEEN a.start_date_active
          AND NVL(a.end_date_active,p_item_date);

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1003 Disc. Percent: ' || l_discount_percentage ||
	  'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;

     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;

        /*------------------------------------------------------------------+
         | 4. Project job bill rate overrides with Task Job Assn. Overrides |
         +------------------------------------------------------------------+
         | Set bill rate and raw revenue using Project job bill rate        |
         | overrides with Task Job Assignment Overrides.                    |
         +------------------------------------------------------------------*/

 -- IT IS NOT IN THIS Forecasting so added p_called_process
   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL
         and l_discount_percentage is null and p_called_process = 'PA') THEN

     BEGIN
        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               PA_CURRENCY.ROUND_CURRENCY_AMT(j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),
               j.rate_currency_code,
               decode(j.discount_percentage,NULL,'O','T'),
 	       j.discount_percentage
        INTO   l_bill_rate,l_raw_revenue,l_rate_currency_code,
               l_amount_calculation_code,l_discount_percentage
        FROM   pa_job_assignment_overrides a, pa_job_bill_rate_overrides j
        WHERE j.project_id = p_project_id
        AND p_item_date
          BETWEEN j.start_date_active
          AND NVL(j.end_date_active,p_item_date)
        AND j.job_id+0 = a.job_id
        AND a.person_id = p_person_id
        AND a.task_id = p_task_id
	 AND l_called_process =0  /*Added for Doosan rate api change */
        AND p_item_date
          BETWEEN a.start_date_active
          AND NVL(a.end_date_active,p_item_date);

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1004 Disc. Percent: ' || l_discount_percentage ||
		       'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;

        /*---------------------------------------------------------------------------+
         | 6. Task job bill rate overrides with project Job Assignments  overrides   |
         +---------------------------------------------------------------------------+
         | Set bill rate and raw revenue using Task job bill rate                    |
         | overrides with Project Job Assignment Overrides.                          |
         +--------------------------------------------------------------------------*/

 -- IT IS NOT IN THIS Forecasting so added p_called_process
 IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL
       and l_discount_percentage is null and p_called_process = 'PA') THEN
     BEGIN
        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               PA_CURRENCY.ROUND_CURRENCY_AMT(j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),
               j.rate_currency_code,
               decode(j.discount_percentage,NULL,'O','P'),
 	       j.discount_percentage
        INTO l_bill_rate,l_raw_revenue,l_rate_currency_code,
             l_amount_calculation_code,l_discount_percentage
        FROM pa_job_assignment_overrides a, pa_job_bill_rate_overrides j
        WHERE j.task_id = p_task_id
        AND p_item_date
          BETWEEN j.start_date_active
          AND NVL(j.end_date_active,
                  p_item_date)
        AND j.job_id+0   = a.job_id
        AND a.person_id  = p_person_id
        AND a.project_id = p_project_id
	 AND l_called_process =0  /*Added for Doosan rate api change */
        AND p_item_date
          BETWEEN a.start_date_active
          AND NVL(a.end_date_active,p_item_date);

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1005 Disc. Percent: ' || l_discount_percentage ||
			  'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;

        /*--------------------------------------------------------------------+
         | 9. Project job bill rate overrides with Project Job Assn. Overrides|
         +--------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Project job bill rate       |
         |    overrides with Project Job Assignment Overrides.                |
         +--------------------------------------------------------------------*/

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL
       and l_discount_percentage is null ) THEN

     BEGIN
        SELECT  j.rate * NVL(p_bill_rate_multiplier,1),
                PA_CURRENCY.ROUND_CURRENCY_AMT((j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity)),
                j.rate_currency_code,
                decode(j.discount_percentage,NULL,'O','P'),
                j.discount_percentage
        INTO   l_bill_rate,l_raw_revenue,
               l_rate_currency_code,
               l_amount_calculation_code,
	       l_discount_percentage
        FROM   pa_job_assignment_overrides a, pa_job_bill_rate_overrides j
        WHERE j.project_id = p_project_id
        AND p_item_date
          BETWEEN j.start_date_active
          AND NVL(j.end_date_active,p_item_date)
        AND j.job_id+0   = a.job_id
        AND a.person_id  = p_person_id
        AND a.project_id = p_project_id
	 AND l_called_process <>2  /*Added for Doosan rate api change */
        AND p_item_date
          BETWEEN a.start_date_active
          AND NVL(a.end_date_active,p_item_date) ;

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1006 Disc. Percent: ' || l_discount_percentage ||
   'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;

     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;

        /*------------------------------------------------------------------+
         | 12. Task job bill rate overrides with primary Job Assignments    |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Task job bill rate        |
         |    overrides with primary Job Assignment.                        |
         +------------------------------------------------------------------*/

 -- IT IS NOT IN THIS Forecasting so added p_called_process
 IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL
      and l_discount_percentage is null and (p_called_process = 'PA'/* or p_called_process='TASK_LEVEL_PLANNING'*/)) THEN

     BEGIN
        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               PA_CURRENCY.ROUND_CURRENCY_AMT((j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity)),
               j.rate_currency_code,
               decode(j.discount_percentage,NULL,'O','J'),
               j.discount_percentage
        INTO   l_bill_rate,l_raw_revenue,l_rate_currency_code,
               l_amount_calculation_code,
			   l_discount_percentage
        FROM  per_assignments_f a,  /* Bug 6058676 : Removed per_assignments_f and related joins *//*uncommented for 9257637 */
	           pa_job_bill_rate_overrides j
        -- Bug 4398492 query made to refer base table per_all_assignments_f
        --     (0 * a.person_id) is used to make assignments as the driving table
        WHERE j.task_id = p_task_id  + (0 * a.person_id)
        AND p_item_date
          BETWEEN j.start_date_active
          AND NVL(j.end_date_active,p_item_date)
        /* AND j.job_id = a.job_id commented for bug 3193077 */
        AND j.job_id = pa_cross_business_grp.IsmappedTojob(a.job_id,l_bill_job_grp_id) /* Added for bug 3193077 */
        AND a.person_id = p_person_id    /* Commented  for  Bug 6058676*//*uncommented for bug 9257637 */
        AND a.primary_flag || '' = 'Y'
        -- AND a.assignment_type = 'E'     /* bug 2911451 */
        AND a.assignment_type IN ('E','C') -- Modified for CWK changes  /* Commented  for  Bug 6058676*//*uncommented for bug 9257637 */
	 AND l_called_process <>1  /*Added for Doosan rate api change */
         AND p_item_date
          BETWEEN a.effective_start_date
          AND a.effective_end_date ; /*uncommented for bug 9257637 */

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1007 Disc. Percent: ' || l_discount_percentage ||
		       'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;

     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;

 ELSIF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL
      and l_discount_percentage is null and (/*p_called_process = 'PA' */  p_called_process='TASK_LEVEL_PLANNING')) THEN

     BEGIN
        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               PA_CURRENCY.ROUND_CURRENCY_AMT((j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity)),
               j.rate_currency_code,
               decode(j.discount_percentage,NULL,'O','J'),
               j.discount_percentage
        INTO   l_bill_rate,l_raw_revenue,l_rate_currency_code,
               l_amount_calculation_code,
			   l_discount_percentage
        FROM   pa_job_bill_rate_overrides j
        WHERE j.task_id = p_task_id
	AND j.job_id = p_resource_job_id /* Bug 6058676 */  /*bug3737994*/ /* modified for bug 9257637 */
        AND p_item_date
          BETWEEN j.start_date_active
          AND NVL(j.end_date_active,p_item_date)
	  AND l_called_process <>1;  /*Added for Doosan rate api change */

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1007 Disc. Percent: ' || l_discount_percentage ||
		       'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;

     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;

        /*------------------------------------------------------------------+
         | 13. Project job bill rate overrides with primary Job Assignment  |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using Project job bill rate     |
         |    overrides with primary Job Assignment.                        |
         +------------------------------------------------------------------*/

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL
       and l_discount_percentage is null and l_called_process = 0) THEN

     BEGIN
        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               PA_CURRENCY.ROUND_CURRENCY_AMT(j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),
                j.rate_currency_code,
                decode(j.discount_percentage,NULL,'O','J'),
                j.discount_percentage
        INTO   l_bill_rate,l_raw_revenue,
               l_rate_currency_code,
               l_amount_calculation_code,
			   l_discount_percentage
        FROM pa_job_bill_rate_overrides j , per_all_assignments_f a /* Bug 6058676: Removed per_assignments_f and related predicates*//*uncommented for bug 9257637 */
         -- Bug 4398492 query made to refer base table  per_all_assignments_f
       WHERE j.project_id = p_project_id  + (0 * a.person_id)
          AND p_item_date + 0.99999
          BETWEEN j.start_date_active
          AND NVL(j.end_date_active + 0.99999,p_item_date + 0.99999)
          AND j.job_id = pa_cross_business_grp.IsmappedTojob(a.job_id,l_bill_job_grp_id)
          AND a.person_id = p_person_id
          AND a.primary_flag = 'Y'
          -- AND a.assignment_type = 'E'     /* bug 2911451 */
          AND a.assignment_type IN ('E','C') -- Modified for CWK changes
          AND p_item_date  BETWEEN a.effective_start_date AND a.effective_end_date ;

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1008 Disc. Percent: ' || l_discount_percentage ||
      'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;

   ELSIF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL
       and l_discount_percentage is null and l_called_process = 1) THEN  /*Bug3737994 2 to 1*/
 /*Bug3737994 commented the code reference to per_assignments_f and added p_resource_job_id*/
     BEGIN
        SELECT j.rate * NVL(p_bill_rate_multiplier,1),
               PA_CURRENCY.ROUND_CURRENCY_AMT(j.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),
                j.rate_currency_code,
                decode(j.discount_percentage,NULL,'O','J'),
                j.discount_percentage
        INTO   l_bill_rate,l_raw_revenue,
               l_rate_currency_code,
               l_amount_calculation_code,
			   l_discount_percentage
         FROM pa_job_bill_rate_overrides j--, per_assignments_f a
       WHERE j.project_id = p_project_id --+ (0 * a.person_id)
          AND p_item_date + 0.99999
          BETWEEN j.start_date_active
          AND NVL(j.end_date_active + 0.99999,p_item_date + 0.99999)
          AND j.job_id = p_resource_job_id;--pa_cross_business_grp.IsmappedTojob(a.job_id,l_bill_job_grp_id) /* Bug 6058676 *//*modified for bug 9257637 */
        --  AND a.person_id = p_person_id
        --  AND a.primary_flag = 'Y'
          -- AND a.assignment_type = 'E'     /* bug 2911451 */
        --  AND a.assignment_type IN ('E','C') -- Modified for CWK changes
        --  AND p_item_date  BETWEEN a.effective_start_date AND a.effective_end_date ;

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1008 Disc. Percent: ' || l_discount_percentage ||
      'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;

        /*------------------------------------------------------------+
         |14. Labor Multipliers                                       |
         +------------------------------------------------------------+
         |    Set bill rate, raw revenue using labor multipliers.     |
         |    (Task first, then Project) V2.0                         |
         +------------------------------------------------------------*/
/* Changes done for bug 2668753. Whenever MCB is 'Y' the denom_raw_cost and denom_curr_code
   are changed to l_mcb_raw_cost and l_mcb_currency_code  */

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND p_raw_cost IS NOT NULL
       and l_discount_percentage is null ) THEN

     DECLARE
        -- This cursor will select the bill rate and raw revenue on the basis of passed parameters i.e.
        -- if task id is null then it will select according to the project id but if task id is not
        -- null then first select will bring the task id row and second select
        -- will bring all the raws ( If exists ) except the row which is already selected in first select

       CURSOR C1 IS( SELECT NULL b_rate,
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                      (m.labor_multiplier * decode(p_mcb_flag,'Y',l_mcb_raw_cost,p_raw_cost)),
                      decode(p_mcb_flag,'Y',l_mcb_currency_code,l_projfunc_currency_code))  r_revenue,
                      decode(p_mcb_flag,'Y',l_mcb_currency_code,l_projfunc_currency_code) curr_code
                     FROM   pa_labor_multipliers m
                     WHERE m.task_id = p_task_id
		      AND l_called_process <>1  /*Added for Doosan rate api change */
                     AND p_item_date
                       BETWEEN m.start_date_active
                       AND NVL(m.end_date_active,p_item_date)
                     UNION ALL
                     SELECT NULL b_rate,
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                      (m2.labor_multiplier * decode(p_mcb_flag,'Y',l_mcb_raw_cost,p_raw_cost)),
                      decode(p_mcb_flag,'Y',l_mcb_currency_code,l_projfunc_currency_code))  r_revenue,
                      decode(p_mcb_flag,'Y',l_mcb_currency_code,l_projfunc_currency_code) curr_code
                     FROM   pa_labor_multipliers m2
                     WHERE m2.project_id = p_project_id
		      AND l_called_process <>2  /*Added for Doosan rate api change */
                     AND p_item_date
                       BETWEEN m2.start_date_active
                       AND NVL(m2.end_date_active,p_item_date)
                     AND NOT EXISTS
                       ( SELECT NULL
                         FROM pa_labor_multipliers m3
                         WHERE m3.task_id = p_task_id
			  AND l_called_process <>1  /*Added for Doosan rate api change */
                         AND p_item_date
                           BETWEEN m3.start_date_active
                           AND NVL(m3.end_date_active,p_item_date)
                      ));
      l_true                         BOOLEAN := FALSE; --Flag is used to determine that wheather the cursor
                                                       -- is returning more than one row or not.
      l_more_than_one_row            EXCEPTION;        -- Local exception using to check that cursor should not return
                                                       -- more than one row

     BEGIN
        -- Opening cursor and fetching row

        FOR l_v_c1 IN C1 LOOP
          -- Checking if the cursor is returning more than one row then error out
          IF (l_true) THEN
            RAISE l_more_than_one_row;
          ELSE
            l_true := TRUE;
          END IF;

          -- Assigning the raw revenue to the local variable
          l_raw_revenue      := l_v_c1.r_revenue;

          -- Assigning the bill rate to the local variable
          l_bill_rate        := l_v_c1.b_rate;

          -- Assigning the bill rate currency to the local variable for MCB2
          l_rate_currency_code        := l_v_c1.curr_code ;

           --Assigning Amount_calculation_code to the local variable.
          l_amount_calculation_code := 'O' ;

          --Assigning discount_percentage to the local variable
          l_discount_percentage := Null;

        END LOOP;

        IF (l_raw_revenue IS NOT NULL) THEN
           x_raw_revenue  := l_raw_revenue;
           x_bill_rate    := l_bill_rate;
        END IF;

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1009 Disc. Percent: ' || l_discount_percentage ||
		     'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
     EXCEPTION
       WHEN l_more_than_one_row THEN
        RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF;

        /*------------------------------------------------------------+
         |15. Standard Employee bill rate schedule .                  |
         |    Set bill rate, raw revenue, adjusted rate, adjusted     |
         |    revenue using standard employee bill rate schedule.     |
         +------------------------------------------------------------*/
/* Changes done for bug 2668753. Whenever MCB is 'Y' the denom_raw_cost and denom_curr_code
   are changed to l_mcb_raw_cost and l_mcb_currency_code  */

  IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND nvl(l_amount_calculation_code,'O')='O') THEN
   IF(p_mcb_flag='Y') then
     BEGIN
        SELECT DECODE(b.rate, NULL, NULL,
                      b.rate * NVL(p_bill_rate_multiplier,1)
                      ),
               DECODE(b.rate, NULL,
                      ((100 + b.markup_percentage) * l_mcb_raw_cost / 100),
                      (b.rate * NVL(p_bill_rate_multiplier,1) *
                                                     p_quantity)),
                DECODE(nvl(l_discount_percentage,l_labor_schdl_discnt), NULL, NULL,
                      (b.rate * NVL(p_bill_rate_multiplier,1) *
                                     (100 - nvl(l_discount_percentage,l_labor_schdl_discnt)) /100)),
                DECODE(nvl(l_discount_percentage,l_labor_schdl_discnt), NULL, NULL,
                      DECODE(b.rate, NULL,
                        PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(((100 + b.markup_percentage)
                                      * (l_mcb_raw_cost / 100)
                                      * (100 - nvl(l_discount_percentage,l_labor_schdl_discnt)) / 100),
                                         l_mcb_currency_code),
                        PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(((b.rate * p_quantity) *
                                     NVL(p_bill_rate_multiplier,1) *
                                    (100 - nvl(l_discount_percentage,l_labor_schdl_discnt)) / 100),
                                     b.rate_currency_code))),
                       DECODE(b.rate, NULL,l_mcb_currency_code,b.rate_currency_code) /* Added for MCB2-Added for bug 2697945 */,
                       b.markup_percentage, /* Added for Asgmt overide */
                       DECODE(l_discount_percentage,NULL,'B','O'),
                       nvl(l_discount_percentage,l_labor_schdl_discnt)
        INTO   l_bill_rate,l_raw_revenue,l_adjusted_rate,l_adjusted_revenue,
               l_rate_currency_code   /* Added for MCB2 */,
               l_markup_percentage,   /* Added for Asgmt overide */
               l_amount_calculation_code,
			   l_discount_percentage
        FROM   pa_bill_rates_all b
        WHERE b.bill_rate_sch_id  = l_emp_bill_rate_schedule_id
        AND b.person_id = p_person_id
        AND NVL(l_labor_schdl_fixed_date,p_item_date)
            BETWEEN b.start_date_active
               AND NVL(b.end_date_active,NVL(l_labor_schdl_fixed_date,p_item_date));
      --   AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);    /* Commented for Bug 6041769 */

     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
    ElSE
     BEGIN
        SELECT DECODE(b.rate, NULL, NULL,
                      b.rate * NVL(p_bill_rate_multiplier,1)
                      ),
               DECODE(b.rate, NULL,((100 + b.markup_percentage) * p_raw_cost / 100),
                      (b.rate * NVL(p_bill_rate_multiplier,1) * p_quantity)),
                DECODE(nvl(l_discount_percentage,l_labor_schdl_discnt), NULL, NULL,
                      (b.rate * NVL(p_bill_rate_multiplier,1) *
                              (100 - nvl(l_discount_percentage,l_labor_schdl_discnt)) /100)),
                DECODE(nvl(l_discount_percentage,l_labor_schdl_discnt), NULL, NULL,
                      DECODE(b.rate, NULL,
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(((100 + b.markup_percentage)
                      * (p_raw_cost / 100) * (100 - nvl(l_discount_percentage,l_labor_schdl_discnt)) / 100), l_projfunc_currency_Code),
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(((b.rate * p_quantity)* NVL(p_bill_rate_multiplier,1)* (100 - nvl(l_discount_percentage,l_labor_schdl_discnt)) / 100), b.rate_currency_code))),
                       DECODE(b.rate, NULL,l_projfunc_currency_code,b.rate_currency_code) /* Added for MCB2 */,
                       b.markup_percentage ,/* Added for Asgmt overide */
                       DECODE(l_discount_percentage,NULL,'B','O'),
                       nvl(l_discount_percentage,l_labor_schdl_discnt)
        INTO   l_bill_rate,l_raw_revenue,l_adjusted_rate,l_adjusted_revenue,
               l_rate_currency_code /* Added for MCB2 */,
               l_markup_percentage ,/* Added for Asgmt overide */
               l_amount_calculation_code,
			   l_discount_percentage
        FROM   pa_bill_rates_all b
        WHERE b.bill_rate_sch_id  = l_emp_bill_rate_schedule_id
        AND b.person_id = p_person_id
        AND NVL(l_labor_schdl_fixed_date,p_item_date)
          BETWEEN b.start_date_active
          AND NVL(b.end_date_active,NVL(l_labor_schdl_fixed_date,p_item_date));
      --   AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);    /* Commented for Bug 6041769 */

     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF; /* MCB FLAG */
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1010 Disc. Percent: ' || l_discount_percentage ||
	    'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
  END IF;

        /*------------------------------------------------------------------+
         | 5. Task job bill rate schedule with task job assn. overrides     |
         +------------------------------------------------------------------+
         |    Set bill rate and raw revenue using task job bill rate        |
         |    schedule with task job assignment overrides -Kal              |
         +------------------------------------------------------------------*/


   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND p_task_id IS NOT NULL
   and (p_called_process = 'PA'or p_called_process = 'TASK_LEVEL_PLANNING') AND (nvl(l_amount_calculation_code,'O') IN ('T','O'))) THEN


     BEGIN
        SELECT DECODE(b.rate, NULL, NULL,b.rate * NVL(p_bill_rate_multiplier,1)),
               PA_CURRENCY.ROUND_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1) * p_quantity),
               DECODE(nvl(l_discount_percentage,l_labor_schdl_discnt), NULL, NULL,
                    PA_CURRENCY.ROUND_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1) *
                    (100 - nvl(l_discount_percentage,l_labor_schdl_discnt)) /100)),
               DECODE( nvl(l_discount_percentage,l_labor_schdl_discnt), NULL, NULL,
                     PA_CURRENCY.ROUND_CURRENCY_AMT((b.rate * p_quantity)
                                  * NVL(p_bill_rate_multiplier,1)
                                  * (100 - nvl(l_discount_percentage,l_labor_schdl_discnt)) / 100)),
                DECODE(l_discount_percentage,NULL,'B','O'),
                nvl(l_discount_percentage,l_labor_schdl_discnt),
		b.rate_currency_code
        INTO  l_bill_rate,l_raw_revenue,l_adjusted_rate,l_adjusted_revenue, l_amount_calculation_code,
			   l_discount_percentage,
                l_rate_currency_code /*Rate added for bug 2636678 */
        FROM  pa_bill_rates_all b, pa_job_assignment_overrides ao
        WHERE ao.person_id = p_person_id
        AND b.bill_rate_sch_id    = l_job_bill_rate_schedule_id
        AND b.job_id  = ao.job_id /*modified for bug 9257637 */
	--	AND b.job_id = pa_cross_business_grp.IsmappedTojob(p_resource_job_id,l_bill_job_grp_id) /* Bug 6058676 *//*commented for bug 9257637 */
        AND p_task_id = ao.task_id
	AND l_called_process <>1  /*Added for Doosan rate api change */
        AND p_item_date
          BETWEEN ao.start_date_active
          AND NVL(ao.end_date_active,p_item_date)
        AND NVL(l_labor_schdl_fixed_date,p_item_date)
          BETWEEN b.start_date_active
          AND NVL(b.end_date_active,NVL(l_labor_schdl_fixed_date,p_item_date));
      --   AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);    /* Commented for Bug 6041769 */

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1011 Disc. Percent: ' || l_discount_percentage ||
	'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;

     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END ;
   END IF;

        /*------------------------------------------------------------------+
         | 10. Task job bill rate schedule with Project Job Assn. Overrides |
         +------------------------------------------------------------------+
         | Set bill rate and raw revenue using task job bill rate           |
         | schedule with project job assignment overrides -Kal              |
         +------------------------------------------------------------------*/

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND (nvl(l_amount_calculation_code,'O') IN ('P','O')))
            THEN
       BEGIN
        SELECT DECODE(b.rate, NULL, NULL,b.rate * NVL(p_bill_rate_multiplier,1)),
                   PA_CURRENCY.ROUND_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)*
                   p_quantity * (100 - (nvl(l_discount_percentage,nvl(l_labor_schdl_discnt,0))))/100),
               b.rate_currency_code,
               DECODE(l_discount_percentage,NULL,'B','O'),
			   nvl(l_discount_percentage,l_labor_schdl_discnt)
        INTO   l_bill_rate,l_raw_revenue,l_rate_currency_code,
               l_amount_calculation_code,l_discount_percentage
        FROM   pa_bill_rates_all b, pa_job_assignment_overrides ao, pa_tasks t
        WHERE ao.person_id = p_person_id
        AND b.bill_rate_sch_id = l_job_bill_rate_schedule_id
        AND b.job_id = ao.job_id
	--	AND b.job_id = pa_cross_business_grp.IsmappedTojob(p_resource_job_id,l_bill_job_grp_id) /* Bug 6058676 *//*commented for bug 9257637 */
        AND t.project_id = ao.project_id
        AND t.task_id = p_task_id
	AND l_called_process <>2  /*Added for Doosan rate api change */
        AND p_item_date
          BETWEEN ao.start_date_active
          AND NVL(ao.end_date_active,p_item_date)
        AND NVL(l_labor_schdl_fixed_date,p_item_date)
          BETWEEN b.start_date_active
          AND NVL(b.end_date_active,NVL(l_labor_schdl_fixed_date,p_item_date));
      --   AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);    /* Commented for Bug 6041769 */

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1012 Disc. Percent: ' || l_discount_percentage || 'Revenue : '
		      || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
  END IF;

        /*---------------------------------------------------------------------+
         | 11. Project job bill rate schedule with Project Job Assn. Overrides |
         +---------------------------------------------------------------------+
         | Set bill rate and raw revenue using task job bill rate              |
         | schedule with project job assignment overrides -Kal                 |
         +--------------------------------------------------------------------

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND p_called_process is NULL ) THEN
     BEGIN
        SELECT DECODE(b.rate, NULL, NULL,
                      b.rate * NVL(p_bill_rate_multiplier,1)),
               PA_CURRENCY.ROUND_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                      * p_quantity * (100 - (nvl(l_discount_percentage,nvl(l_labor_schdl_discnt,0))))/100),
               b.rate_currency_code,
               DECODE(l_discount_percentage,NULL,'B','O'),
			   nvl(l_discount_percentage,l_labor_schdl_discnt)
        INTO   l_bill_rate,l_raw_revenue,
               l_rate_currency_code,
               l_amount_calculation_code,
			   l_discount_percentage
        FROM   pa_bill_rates_all b, pa_job_assignment_overrides ao
        WHERE ao.person_id = p_person_id
        AND b.bill_rate_sch_id = l_job_bill_rate_schedule_id
        AND b.job_id = ao.job_id
        AND ao.project_id = p_project_id
        AND p_item_date
          BETWEEN ao.start_date_active
          AND NVL(ao.end_date_active,p_item_date)
        AND NVL(l_labor_schdl_fixed_date,p_item_date)
          BETWEEN b.start_date_active
          AND NVL(b.end_date_active,NVL(l_labor_schdl_fixed_date,p_item_date))
        AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF; */


       /*------------------------------------------------------------+
         |16. Standard Job bill rate schedule                         |
         +------------------------------------------------------------+
         |    Set bill rate, raw revenue, adjusted rate, adjusted     |
         |    revenue using standard job bill rate schedule.          |
         +------------------------------------------------------------*/

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND l_called_process =0 AND
                          (nvl(l_amount_calculation_code,'O') IN ('J','O')) ) THEN
       BEGIN
        SELECT DECODE(b.rate, NULL, NULL,
                      b.rate * NVL(p_bill_rate_multiplier,1)),
               PA_CURRENCY.ROUND_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                      * p_quantity * (100 - (nvl(l_discount_percentage,nvl(l_labor_schdl_discnt,0))))/100),
               b.rate_currency_code,
               DECODE(l_discount_percentage,NULL,'B','O'),
			   nvl(l_discount_percentage,l_labor_schdl_discnt)
        INTO   l_bill_rate,l_raw_revenue,
               l_rate_currency_code,
               l_amount_calculation_code,
			   l_discount_percentage
        FROM   pa_bill_rates_all b -- per_assignments_f pa   Commented for Bug 4398492 query made to refer base table
               , per_all_assignments_f pa
        WHERE b.bill_rate_sch_id  = l_job_bill_rate_schedule_id
          AND pa.person_id = p_person_id
          AND pa.primary_flag = 'Y'
          -- AND pa.assignment_type = 'E'
          AND pa.assignment_type IN ('E','C') -- Modified for CWK changes
          AND p_item_date                   /* BUG#3118592 */
                BETWEEN pa.effective_start_date
                AND pa.effective_end_date
           AND b.job_id = pa_cross_business_grp.IsmappedTojob(nvl(p_resource_job_id,pa.job_id),l_bill_job_grp_id)
           /* Changed the join instead of joining with p_resource_job_id, now joining using function IsmappedTojob to fix bug 2155331 */ /* Bug 6058676 */
          AND NVL(l_labor_schdl_fixed_date,p_item_date)/*modified above line condition for bug 9257637 */
          BETWEEN b.start_date_active
          AND NVL(b.end_date_active,
                  NVL(l_labor_schdl_fixed_date,p_item_date));
      --   AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);    /* Commented for Bug 6041769 */
       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
          RAISE;
         WHEN NO_DATA_FOUND THEN
          l_raw_revenue := NULL;
          l_bill_rate   := NULL;
       END;
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1013 Disc. Percent: ' || l_discount_percentage ||
    'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
   ELSIF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND l_called_process <>0 AND
                          (nvl(l_amount_calculation_code,'O') IN ('J','O')) ) THEN
       BEGIN
        SELECT DECODE(b.rate, NULL, NULL,
                      b.rate * NVL(p_bill_rate_multiplier,1)),
               PA_CURRENCY.ROUND_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                      * p_quantity * (100 - (nvl(l_discount_percentage,nvl(l_labor_schdl_discnt,0))))/100),
               b.rate_currency_code,
               DECODE(l_discount_percentage,NULL,'B','O'),
			   nvl(l_discount_percentage,l_labor_schdl_discnt)
        INTO   l_bill_rate,l_raw_revenue,
               l_rate_currency_code,
               l_amount_calculation_code,
			   l_discount_percentage
        FROM   pa_bill_rates_all b
        WHERE b.bill_rate_sch_id  = l_job_bill_rate_schedule_id
          AND b.job_id = p_resource_job_id /* Bug 6058676 *//*modified for bug 9257637 */
          AND NVL(l_labor_schdl_fixed_date,p_item_date)
          BETWEEN b.start_date_active
          AND NVL(b.end_date_active,
                  NVL(l_labor_schdl_fixed_date,p_item_date));
      --   AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);    /* Commented for Bug 6041769 */
       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
          RAISE;
         WHEN NO_DATA_FOUND THEN
          l_raw_revenue := NULL;
          l_bill_rate   := NULL;
       END;
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','1013 Disc. Percent: ' || l_discount_percentage ||
    'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
   END IF ;



        /*------------------------------------------------------------+
         |16a. Standard Job bill rate schedule at Project             |
         +------------------------------------------------------------+
         |    Set bill rate, raw revenue, adjusted rate, adjusted     |
         |    revenue using standard job bill rate schedule.          |
         +------------------------------------------------------------

   IF ( l_raw_revenue IS NULL AND l_bill_rate IS NULL AND p_called_process !='PA') THEN

     BEGIN
        SELECT DECODE(b.rate, NULL, NULL,
                      b.rate * NVL(p_bill_rate_multiplier,1)
                      ),
               DECODE(b.rate, NULL,
                      ((100 + b.markup_percentage) *
                                                     p_raw_cost / 100),
                      (b.rate * NVL(p_bill_rate_multiplier,1) *
                                                     p_quantity)),
                DECODE(l_labor_schdl_discnt, NULL, NULL,
                      (b.rate * NVL(p_bill_rate_multiplier,1) *
                                     (100 - l_labor_schdl_discnt) /100)),
                DECODE(l_labor_schdl_discnt, NULL, NULL,
                      DECODE(b.rate, NULL,
                              ((100 + b.markup_percentage)
                                        * (p_raw_cost / 100)
                                        * (100 - l_labor_schdl_discnt) / 100),
                                  ((b.rate * p_quantity)
                                        * NVL(p_bill_rate_multiplier,1)
                                        * (100 - l_labor_schdl_discnt) / 100)
                              )
                       ),
                      DECODE(b.rate, NULL,l_projfunc_currency_code,b.rate_currency_code)
                      b.markup_percentage
        INTO   l_bill_rate,l_raw_revenue,l_adjusted_rate,l_adjusted_revenue,
               l_rate_currency_code
               l_markup_percentage
        FROM   pa_bill_rates_all b
        WHERE b.bill_rate_sch_id  = l_job_bill_rate_schedule_id
        AND b.job_id = pa_cross_business_grp.IsmappedTojob(p_resource_job_id,l_bill_job_grp_id)
        AND NVL(l_labor_schdl_fixed_date,p_item_date)
          BETWEEN b.start_date_active
          AND NVL(b.end_date_active,
                  NVL(l_labor_schdl_fixed_date,p_item_date))
        AND NVL(b.org_id,-99) = NVL(l_project_org_id,-99);

     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE;
       WHEN NO_DATA_FOUND THEN
         l_raw_revenue := NULL;
         l_bill_rate   := NULL;
     END;
   END IF; */

  END IF; /* end of sch check }*/
 END IF; /* end if revenue calculated flag } */


   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','9999 Disc. Percent: ' || l_discount_percentage ||
	 'Revenue : ' || l_raw_revenue || 'currency_code : ' || l_rate_currency_code);
   END IF;
  l_txn_bill_rate     := l_bill_rate; -- Removed NVL condition for bug 5079230

  IF (l_adjusted_revenue IS NOT NULL ) THEN
      l_txn_raw_revenue := NVL(l_adjusted_revenue,0);
  ELSE
     l_txn_raw_revenue   := NVL(l_raw_revenue,0);
  END IF;

  IF ( ( l_txn_raw_revenue IS NULL)  OR (l_txn_raw_revenue = 0) ) THEN
    RAISE l_no_revenue;
  END IF;

      /*bug 4169912 passed the adjusted rate after applying the discount percentage if its not calculated above*/
      l_adjusted_rate :=NVL(l_adjusted_rate ,(l_txn_bill_rate *(100 - l_discount_percentage)/100));
      IF  l_adjusted_rate =0 then
      l_adjusted_rate :=NULl;
      END IF;
      /*end of bug 4169912*/
          x_raw_revenue       := NVL(l_txn_raw_revenue,0) ;
          x_bill_rate         := l_txn_bill_rate ; -- Removed NVL condition for bug 5079230
	  x_adjusted_bill_rate:= l_adjusted_rate; --4038485
          x_txn_currency_code := l_rate_currency_code ; /* Added for Org Forecasting */
          x_markup_percentage := l_markup_percentage; /* Added for Asgmt overide */

  x_return_status := l_x_return_status;
   IF g1_debug_mode  = 'Y' THEN
  pa_debug.write_file('LOG','Last statement in Assignment rev');
   END IF;
EXCEPTION
 WHEN l_no_revenue THEN
  x_bill_rate  := NULL;
  x_raw_revenue:= 0;
  x_markup_percentage := NULL; /* Added for Asgmt overide */
  x_txn_currency_code := l_rate_currency_code; /* Added for bug 3385744 */
  x_adjusted_bill_rate         := NULL ; --4038485
  /* Checking error condition. Added for bug 2218386 */
  IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
    PA_UTILS.add_message('PA', 'PA_FCST_NO_BILL_RATE');
  END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count     := 1;
   IF p_called_process IS NULL THEN
     x_msg_data      := 'PA_FCST_NO_BILL_RATE';
   END IF;
 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count     := 1;
   x_msg_data      := SUBSTR(SQLERRM,1,30);

   /* ATG Changes */

      x_bill_rate              := null;
      x_raw_revenue            := null;
      x_rev_currency_code      := null;
      x_markup_percentage      := null;
      x_txn_currency_code      := null;
      x_adjusted_bill_rate     := null;

  IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_REVENUE', /* Moved this here to fix bug 2434663 */
                            p_procedure_name   => 'Assignment_Rev_Amt');
     RAISE;
  END IF;
  IF p_called_process ='PA' then
   raise;
   END IF;
 END Assignment_Rev_Amt;

/* This is new procedure created for Org Forecasting */

-- This procedure will convert the transaction amounts in Project,and Project Functional.
-- Input/Output parameters
-- Parameters                    Type           Required   Description
-- p_item_date                   DATE            YES        Forecast Item date
-- px_txn_curr_code              VARCHA2         YES        Transaction currency
-- px_txn_raw_revenue            NUMBER          YES        Raw revenue in Transaction currency
-- px_txn_bill_rate              NUMBER          YES        Bill rate in Transaction currency
-- px_projfunc_curr_code         VARCHA2         YES        Project functional currency(PFC)
-- p_projfunc_bil_rate_date_code VARCHAR2        No         Bill rate date code of PFC
-- px_projfunc_bil_rate_type     VARCHAR2        No         Bill rate type of PFC
-- px_projfunc_bil_rate_date     DATE            No         Bill rate date code of PFC
-- px_projfunc_bil_exchange_rate NUMBER          No         Bill exchange rate of PFC
-- px_projfunc_raw_revenue       NUMBER          YES        Raw revenue in PFC
-- px_projfunc_bill_rate         NUMBER          YES        Bill rate in PFC
-- px_project_curr_code          VARCHA2         YES        Project currency(PC)
-- p_project_bil_rate_date_code  VARCHAR2        No         Bill rate date code of PC
-- px_project_bil_rate_type      VARCHAR2        No         Bill rate type of PC
-- px_project_bil_rate_date      DATE            No         Bill rate date code of PC
-- px_project_bil_exchange_rate  NUMBER          No         Bill exchange rate of PC
-- px_project_raw_revenue        NUMBER          YES        Raw revenue in PC
-- px_project_bill_rate          NUMBER          YES        Bill rate in PC


PROCEDURE  Get_Converted_Revenue_Amounts(
              p_item_date                    IN      DATE,
              px_txn_curr_code               IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              px_txn_raw_revenue             IN  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
              px_txn_bill_rate               IN  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
              px_projfunc_curr_code          IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              p_projfunc_bil_rate_date_code  IN      VARCHAR2,
              px_projfunc_bil_rate_type      IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              px_projfunc_bil_rate_date      IN  OUT NOCOPY DATE, --File.Sql.39 bug 4440895
              px_projfunc_bil_exchange_rate  IN  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
              px_projfunc_raw_revenue        IN  OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
              px_projfunc_bill_rate          IN  OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
              px_project_curr_code           IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              p_project_bil_rate_date_code   IN      VARCHAR2,
              px_project_bil_rate_type       IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              px_project_bil_rate_date       IN  OUT NOCOPY DATE, --File.Sql.39 bug 4440895
              px_project_bil_exchange_rate   IN  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
              px_project_raw_revenue         IN  OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
              px_project_bill_rate           IN  OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
              x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
              x_msg_data                     OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

   l_x_return_status                      VARCHAR2(50);  -- It will be used to store the return status
                                                         -- and used it to validate whether the
                                                         -- calling procedure has run successfully
                                                         -- or encounter any error
   l_txn_bill_rate                        NUMBER :=null; -- store bill amount transaction curr.
   l_txn_raw_revenue                      NUMBER :=null; --  store the raw revenue trans. curr.
   l_rate_currency_code                   PA_BILL_RATES_all.rate_currency_code%TYPE;
   l_denominator                          NUMBER;
   l_numerator                            NUMBER;
   l_status                               VARCHAR2(30);

   l_converted_projfunc_rev_amt           NUMBER;
   l_converted_projfunc_bill_rate         NUMBER :=null;
   l_conversion_projfunc_date             DATE;          -- store item date
   l_converted_project_rev_amount         NUMBER;
   l_converted_project_bill_rate          NUMBER :=null;
   l_conversion_project_date              DATE;          -- store item date

   l_projfunc_currency_code               PA_PROJECTS_ALL.projfunc_currency_code%TYPE;
   l_projfunc_bil_rate_date_code          PA_PROJECTS_ALL.projfunc_bil_rate_date_code%TYPE;
   l_projfunc_bil_rate_type               PA_PROJECTS_ALL.projfunc_bil_rate_type%TYPE;
   l_projfunc_bil_rate_date               PA_PROJECTS_ALL.projfunc_bil_rate_date%TYPE;
   l_projfunc_bil_exchange_rate           PA_PROJECTS_ALL.projfunc_bil_exchange_rate%TYPE;

   l_project_currency_code                PA_PROJECTS_ALL.project_currency_code%TYPE;
   l_project_bil_rate_date_code           PA_PROJECTS_ALL.project_bil_rate_date_code%TYPE;
   l_project_bil_rate_type                PA_PROJECTS_ALL.project_bil_rate_type%TYPE;
   l_project_bil_rate_date                PA_PROJECTS_ALL.project_bil_rate_date%TYPE;
   l_project_bil_exchange_rate            PA_PROJECTS_ALL.project_bil_exchange_rate%TYPE;


/* ATG Changes */

              lx_txn_curr_code                  VARCHAR2(15);
              lx_txn_raw_revenue                NUMBER;
              lx_txn_bill_rate                  NUMBER;
              lx_projfunc_curr_code             VARCHAR2(15);
              lx_projfunc_bil_rate_type         VARCHAR2(30);
              lx_projfunc_bil_rate_date          DATE;
              lx_projfunc_bil_exchange_rate   NUMBER;
              lx_projfunc_raw_revenue         NUMBER;
              lx_projfunc_bill_rate          NUMBER;
              lx_project_curr_code           VARCHAR2(15);
              lx_project_bil_rate_type       VARCHAR2(30);
              lx_project_bil_rate_date       DATE;
              lx_project_bil_exchange_rate   NUMBER;
              lx_project_raw_revenue         NUMBER;
              lx_project_bill_rate           NUMBER;



BEGIN

   /* ATG Changes */

              lx_txn_curr_code                := px_txn_curr_code;
              lx_txn_raw_revenue              := px_txn_raw_revenue;
              lx_txn_bill_rate                := px_txn_bill_rate ;
              lx_projfunc_curr_code           := px_projfunc_curr_code ;
              lx_projfunc_bil_rate_type       := px_projfunc_bil_rate_type ;
              lx_projfunc_bil_rate_date       := px_projfunc_bil_rate_date;
              lx_projfunc_bil_exchange_rate   := px_projfunc_bil_exchange_rate;
              lx_projfunc_raw_revenue         := px_projfunc_raw_revenue;
              lx_projfunc_bill_rate           := px_projfunc_bill_rate;
              lx_project_curr_code            := px_project_curr_code ;
              lx_project_bil_rate_type        := px_project_bil_rate_type;
              lx_project_bil_rate_date        := px_project_bil_rate_date;
              lx_project_bil_exchange_rate    := px_project_bil_exchange_rate;
              lx_project_raw_revenue          := px_project_raw_revenue ;
              lx_project_bill_rate            := px_project_bill_rate;




  -- Initializing return status with success sothat if some unexpected error comes
  -- , we change its status from succes to error sothat we can take necessary step to rectify the problem
      l_x_return_status := FND_API.G_RET_STS_SUCCESS;

      -------------------------------------------------------------------------------
      -- Assigning the denorm raw revenue, rate and Project, Project Functional
      -- conversion attributes to local variables
      ------------------------------------------------------------------------------

       l_rate_currency_code            :=  px_txn_curr_code;
       l_txn_raw_revenue               :=  NVL(px_txn_raw_revenue,0);
       l_txn_bill_rate                 :=  px_txn_bill_rate; -- Removed NVL condition for bug 5079230

       l_projfunc_currency_code        :=  px_projfunc_curr_code;
       l_projfunc_bil_rate_date_code   :=  p_projfunc_bil_rate_date_code;
       l_projfunc_bil_rate_type        :=  px_projfunc_bil_rate_type;
       l_projfunc_bil_rate_date        :=  px_projfunc_bil_rate_date;
       l_projfunc_bil_exchange_rate    :=  px_projfunc_bil_exchange_rate;

       l_project_currency_code         :=  px_project_curr_code;
       l_project_bil_rate_date_code    :=  p_project_bil_rate_date_code;
       l_project_bil_rate_type         :=  px_project_bil_rate_type;
       l_project_bil_rate_date         :=  px_project_bil_rate_date;
       l_project_bil_exchange_rate     :=  px_project_bil_exchange_rate;


       --------------------------------------------------------------------------------------
       -- Checking for Currencies if null
       --------------------------------------------------------------------------------------
       IF (l_projfunc_currency_code IS NULL ) THEN
          RAISE l_invalid_projfunc_curr_code;
       END IF;
       IF (l_project_currency_code IS NULL ) THEN
          RAISE l_invalid_proj_curr_code;
       END IF;
       IF (l_rate_currency_code IS NULL ) THEN
          RAISE l_invalid_txn_curr_code;
       END IF;

       ---------------------------------------------------------------------------------------
       -- Start Conversion code to convert the Transaction Revenue/Rate in Project Functional
       -- Taking project rate date , because all the transaction has to go under same date for EIs and rate
       ---------------------------------------------------------------------------------------
       IF ( l_projfunc_bil_rate_date_code = 'FIXED_DATE') THEN
          l_conversion_projfunc_date := l_projfunc_bil_rate_date;
       ELSE
          l_conversion_projfunc_date := p_item_date;
       END IF;


       ----------------------------------------------------------------------------
       -- Get the Raw Revenue in Project Functional
       ---------------------------------------------------------------------------
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_rate_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conversion_projfunc_date,
                            P_CONVERSION_TYPE        => l_projfunc_bil_rate_type,
                            P_AMOUNT                 => l_txn_raw_revenue,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_projfunc_rev_amt,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_bil_exchange_rate,
                            X_STATUS                 => l_status);

                           IF (l_status IS NOT NULL) THEN
                             RAISE l_conversion_fail;
                           END IF;

       ----------------------------------------------------------------------------
       -- Get the Rate in Project Functional
       ---------------------------------------------------------------------------
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_rate_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conversion_projfunc_date,
                            P_CONVERSION_TYPE        => l_projfunc_bil_rate_type,
                            P_AMOUNT                 => l_txn_bill_rate,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_projfunc_bill_rate,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_bil_exchange_rate,
                            X_STATUS                 => l_status);

                           IF (l_status IS NOT NULL) THEN
                             RAISE l_conversion_fail;
                           END IF;

       ----------------------------------------------------------------------------
       -- Start Conversion code to convert the Transaction Revenue/Rate in Project
       -- Taking project rate date , because all the transaction has to go under same date for EIs and rate
       ---------------------------------------------------------------------------
       IF ( l_project_bil_rate_date_code = 'FIXED_DATE') THEN
          l_conversion_project_date := l_project_bil_rate_date;
       ELSE
          l_conversion_project_date := p_item_date;
       END IF;


       ----------------------------------------------------------------------------
       -- Get the Raw Revenue in Project
       ---------------------------------------------------------------------------
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_rate_currency_code,
                            P_TO_CURRENCY            => l_project_currency_code,
                            P_CONVERSION_DATE        => l_conversion_project_date,
                            P_CONVERSION_TYPE        => l_project_bil_rate_type,
                            P_AMOUNT                 => l_txn_raw_revenue,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_project_rev_amount,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_project_bil_exchange_rate,
                            X_STATUS                 => l_status);

                           IF (l_status IS NOT NULL) THEN
                             RAISE l_conversion_fail;
                           END IF;

       ----------------------------------------------------------------------------
       -- Get the Rate in Project
       ---------------------------------------------------------------------------
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_rate_currency_code,
                            P_TO_CURRENCY            => l_project_currency_code,
                            P_CONVERSION_DATE        => l_conversion_project_date,
                            P_CONVERSION_TYPE        => l_project_bil_rate_type,
                            P_AMOUNT                 => l_txn_bill_rate,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_project_bill_rate,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_project_bil_exchange_rate,
                            X_STATUS                 => l_status);

                           IF (l_status IS NOT NULL) THEN
                             RAISE l_conversion_fail;
                           END IF;

      -------------------------------------------------------------------------------
      -- Assigning the back the local variable to denorm raw revenue, rate and Project,
      -- Project Functional
      ------------------------------------------------------------------------------
              px_txn_curr_code              := l_rate_currency_code;
              px_txn_raw_revenue            := NVL(l_txn_raw_revenue,0);
              px_txn_bill_rate              := l_txn_bill_rate; -- Removed NVL condition for bug 5079230

              px_projfunc_curr_code         := l_projfunc_currency_code;
              px_projfunc_bil_rate_date     := l_conversion_projfunc_date;
              px_projfunc_bil_rate_type     := l_projfunc_bil_rate_type;
              px_projfunc_bil_exchange_rate := l_projfunc_bil_exchange_rate;
              px_projfunc_raw_revenue       := NVL(l_converted_projfunc_rev_amt,0);
              px_projfunc_bill_rate         := l_converted_projfunc_bill_rate; -- Removed NVL condition for bug 5079230

              px_project_curr_code          := l_project_currency_code;
              px_project_bil_rate_date      := l_conversion_project_date;
              px_project_bil_rate_type      := l_project_bil_rate_type;
              px_project_bil_exchange_rate  := l_project_bil_exchange_rate;
              px_project_raw_revenue        := NVL(l_converted_project_rev_amount,0);
              px_project_bill_rate          := l_converted_project_bill_rate; -- Removed NVL condition for bug 5079230

              x_return_status := l_x_return_status;
EXCEPTION
  WHEN l_invalid_projfunc_curr_code THEN
    px_txn_raw_revenue       := 0;
    px_txn_bill_rate         := NULL;
    px_projfunc_raw_revenue  := 0;
    px_projfunc_bill_rate    := 0;
    px_project_raw_revenue   := 0;
    px_project_bill_rate     := NULL;

    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
      PA_UTILS.add_message('PA', 'PA_MISSING_PRJFUNC_CURR');
    END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
    x_msg_count     :=  1;
    x_msg_data      :=  'PA_MISSING_PRJFUNC_CURR';
  WHEN l_invalid_txn_curr_code THEN
    px_txn_raw_revenue       := 0;
    px_txn_bill_rate         := NULL;
    px_projfunc_raw_revenue  := 0;
    px_projfunc_bill_rate    := 0;
    px_project_raw_revenue   := 0;
    px_project_bill_rate     := NULL;

    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
      PA_UTILS.add_message('PA', 'PA_REQUIRE_DENOM_CURR');
    END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
    x_msg_count     :=  1;
    x_msg_data      :=  'PA_REQUIRE_DENOM_CURR';
  WHEN l_invalid_proj_curr_code THEN
    px_txn_raw_revenue       := 0;
    px_txn_bill_rate         := NULL;
    px_projfunc_raw_revenue  := 0;
    px_projfunc_bill_rate    := 0;
    px_project_raw_revenue   := 0;
    px_project_bill_rate     := NULL;

    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
      PA_UTILS.add_message('PA', 'PA_MISSING_PROJ_CURR');
    END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
    x_msg_count     :=  1;
    x_msg_data      :=  'PA_MISSING_PROJ_CURR';
  WHEN l_conversion_fail THEN
    px_txn_raw_revenue       := 0;
    px_txn_bill_rate         := NULL;
    px_projfunc_raw_revenue  := 0;
    px_projfunc_bill_rate    := 0;
    px_project_raw_revenue   := 0;
    px_project_bill_rate     := NULL;

    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
      PA_UTILS.add_message('PA', l_status||'_BC_PF');
    END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
    x_msg_count     :=  1;
    x_msg_data      :=  l_status||'_BC_PF';

 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count     := 1;
   x_msg_data      := SUBSTR(SQLERRM,1,30);

   /* ATG Changes */

              px_txn_curr_code                := lx_txn_curr_code;
              px_txn_raw_revenue              := lx_txn_raw_revenue;
              px_txn_bill_rate                := lx_txn_bill_rate ;
              px_projfunc_curr_code           := lx_projfunc_curr_code ;
              px_projfunc_bil_rate_type       := lx_projfunc_bil_rate_type ;
              px_projfunc_bil_rate_date       := lx_projfunc_bil_rate_date;
              px_projfunc_bil_exchange_rate   := lx_projfunc_bil_exchange_rate;
              px_projfunc_raw_revenue         := lx_projfunc_raw_revenue;
              px_projfunc_bill_rate           := lx_projfunc_bill_rate;
              px_project_curr_code            := lx_project_curr_code ;
              px_project_bil_rate_type        := lx_project_bil_rate_type;
              px_project_bil_rate_date        := lx_project_bil_rate_date;
              px_project_bil_exchange_rate    := lx_project_bil_exchange_rate;
              px_project_raw_revenue          := lx_project_raw_revenue ;
              px_project_bill_rate            := lx_project_bill_rate;


    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_REVENUE', /* Moved this here to fix bug 2434663 */
                                p_procedure_name   => 'Get_Converted_Revenue_Amounts');
       RAISE;
    END IF;


END Get_Converted_Revenue_Amounts;


PROCEDURE Non_Labor_Rev_amount(
      p_project_id                   IN     NUMBER      ,
      p_task_id                      IN     NUMBER      ,
      p_bill_rate_multiplier         IN     NUMBER      ,
      p_quantity                     IN     NUMBER      ,
      p_raw_cost                     IN     NUMBER      ,
      p_burden_cost                  IN     NUMBER      ,
      p_denom_raw_cost               IN     NUMBER      ,
      p_denom_burdened_cost          IN     NUMBER      ,
      p_expenditure_item_date        IN     DATE        ,
      p_task_bill_rate_org_id        IN     NUMBER      ,
      p_project_bill_rate_org_id     IN     NUMBER      ,
      p_task_std_bill_rate_sch       IN     VARCHAR2 DEFAULT NULL  ,
      p_project_std_bill_rate_sch    IN     VARCHAR2 DEFAULT NULL  ,
      p_project_org_id               IN     NUMBER      ,
      p_sl_function                  IN     NUMBER,
      p_denom_currency_code          IN     VARCHAR2    ,
      p_proj_func_currency           IN     VARCHAR2    ,
      p_expenditure_type             IN     VARCHAR2    ,
      p_non_labor_resource           IN     VARCHAR2    ,
      p_task_sch_date                IN     DATE        ,
      p_project_sch_date             IN     DATE        ,
      p_project_sch_discount         IN     NUMBER      ,
      p_task_sch_discount            IN     NUMBER      ,
      p_mcb_flag                     IN     VARCHAR2    ,
      p_non_labor_sch_type           IN     VARCHAR2    ,
      p_project_type                 IN     VARCHAR2   ,
      p_exp_raw_cost                 IN     NUMBER,
      p_raw_cost_rate                IN     NUMBER    ,
      p_Incurred_by_organz_id        IN     NUMBER    ,
      p_override_to_organz_id        IN     VARCHAR2  ,
      px_exp_func_curr_code          IN OUT NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
      x_raw_revenue                  OUT    NOCOPY NUMBER    , --File.Sql.39 bug 4440895
      x_rev_Curr_code                OUT    NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
      x_return_status                OUT    NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
      x_msg_count                    OUT    NOCOPY NUMBER    , --File.Sql.39 bug 4440895
      x_msg_data                     OUT    NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
    /* Added for bug 2668753 */
      p_project_raw_cost             IN     NUMBER    DEFAULT NULL,
      p_project_currency_code        IN     VARCHAR2  DEFAULT NULL,
      p_project_burdened_cost        IN     NUMBER    DEFAULT NULL,
      p_proj_func_burdened_cost      IN     NUMBER    DEFAULT NULL,
      p_exp_func_burdened_cost       IN     NUMBER    DEFAULT NULL,
/*Added for Doosan rate api changes */
      p_task_nl_std_bill_rate_sch_id IN     NUMBER    DEFAULT NULL,
      p_proj_nl_std_bill_rate_sch_id IN     NUMBER    DEFAULT NULL,
      p_called_process               IN     VARCHAR2  DEFAULT NULL,
      x_bill_rate                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_markup_percentage            OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_adjusted_bill_rate           OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
      p_uom_flag                     IN     NUMBER    DEFAULT 1

  )
AS


   l_raw_revenue              NUMBER :=null; -- store the raw revenue
   l_bill_rate                NUMBER;
   l_trans_adjust_amount      NUMBER;
   l_more_than_one_row_excep  EXCEPTION;
   l_true		     		  BOOLEAN := FALSE;
   l_no_revenue               EXCEPTION;
   l_txn_raw_revenue          NUMBER :=null; -- store the raw revenue trans. curr.
   l_rate_discount_pct        NUMBER;
   l_x_return_status          VARCHAR2(50);  -- store the return status
                                                   -- and used it to validate whether the
                                                   -- calling procedure has run successfully
                                                   -- or encounter any error
/* Added for bug 2668753 */
   l_mcb_cost_flag                   varchar2(50) := null;
   l_mcb_raw_cost                    number := null;
   l_mcb_burdened_cost               number := null;
   l_mcb_currency_code               varchar2(50) := null;

	--l_msg_count               NUMBER;
--	l_msg_data                VARCHAR2(100);
        l_proj_std_bill_rate_sch_id   NUMBER;/*Added for bug 2690011*/
        l_task_std_bill_rate_sch_id   NUMBER;
	l_called_process                  NUMBER; /*Added for Doosan rate api enhancement */
	 l_adjusted_bill_rate                NUMBER:=NULL; --4038485

 lx_exp_func_curr_code          varchar2(15);


BEGIN

  /* ATG Changes */

   lx_exp_func_curr_code  := px_exp_func_curr_code ;


  /* Adding the following piece of code for Doosan rate api changes . */

        l_called_process := 0;

     IF P_called_process ='PROJECT_LEVEL_PLANNING' THEN
        l_called_process :=1;
     END IF;

     IF P_called_process ='TASK_LEVEL_PLANNING' THEN
        l_called_process :=2;
     END IF;
  -- Initializing return status with success so that if some unexpected error comes
  -- , we change its status from succes to error sothat we can take necessary step to rectify the problem
      l_x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Checking if the labor schedule type is indirect then calling other api
     otherwise following the steps given below  { */

/* Changes for bug 2668753 */

  /* Bug 2668753 : Get the BTC_COST_BASE_REV_CODE from pa_projects_all table */
IF ( nvl(p_mcb_flag,'N') = 'Y' ) THEN
BEGIN

  /* Added the following nvl so that code does not break even when upgrade script fails-bug 2742778 */

   select nvl(BTC_COST_BASE_REV_CODE,'EXP_TRANS_CURR')
   into l_mcb_cost_flag
   from pa_projects_all
   where project_id = p_project_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE ;
END;

    IF (l_mcb_cost_flag = 'EXP_TRANS_CURR') THEN
     l_mcb_raw_cost :=  p_denom_raw_cost;
     l_mcb_currency_code := p_denom_currency_code;
     l_mcb_burdened_cost := p_denom_burdened_cost;

    ELSIF (l_mcb_cost_flag = 'EXP_FUNC_CURR') THEN
     l_mcb_raw_cost := p_exp_raw_cost;
     l_mcb_currency_code := px_exp_func_curr_code;
     l_mcb_burdened_cost := p_exp_func_burdened_cost;

    ELSIF (l_mcb_cost_flag = 'PROJ_FUNC_CURR') THEN
     l_mcb_raw_cost  := p_raw_cost;
     l_mcb_currency_code := p_proj_func_currency;
     l_mcb_burdened_cost := p_proj_func_burdened_cost;

    ELSIF (l_mcb_cost_flag = 'PROJECT_CURR') THEN
     l_mcb_raw_cost := p_project_raw_cost;
     l_mcb_currency_code := p_project_currency_code;
     l_mcb_burdened_cost := p_project_burdened_cost;

    END IF;
/* Added for bug 2726298 */

ELSIF(nvl(p_mcb_flag,'N')='N') THEN
     l_mcb_raw_cost  := p_raw_cost;
     l_mcb_currency_code := p_proj_func_currency;
     l_mcb_burdened_cost := p_proj_func_burdened_cost;

END IF;
/* End of changes for bug 2668753 */

/* As the revenue is generated by applying burden on mcb_raw_cost when non_labor_schd_type is 'Indirect'
   changing the exp_raw_cost and exp_func_curr_code to mcb values -bug 2668753*/
  IF ( p_non_labor_sch_type = 'I' ) THEN
     -- Calling burden cost API
     PA_COST.get_burdened_cost(p_project_type                 => p_project_type                  ,
                              p_project_id                    => p_project_id                    ,
                              p_task_id                       => p_task_id                       ,
                              p_item_date                     => p_expenditure_item_date                      ,
                              p_expenditure_type              => p_expenditure_type              ,
                              p_schedule_type                 => 'REVENUE'            ,
                              px_exp_func_curr_code           => l_mcb_currency_code           ,
                              p_Incurred_by_organz_id         => p_Incurred_by_organz_id         ,
                              p_raw_cost                      => l_mcb_raw_cost                  ,
                              p_raw_cost_rate                 => p_raw_cost_rate                 ,
                              p_quantity                      => p_quantity                      ,
                              p_override_to_organz_id         => p_override_to_organz_id         ,
                              x_burden_cost                   => l_raw_revenue                   ,
                              x_burden_cost_rate              => l_bill_rate                     ,
                              x_return_status                 => l_x_return_status               ,
                              x_msg_count                     => x_msg_count                     ,
                              x_msg_data                      => x_msg_data);

   --     x_rev_curr_code   :=  px_exp_func_curr_code;  /* Commented this line and added the following line for bug 2726298 */
       x_rev_curr_code   := l_mcb_currency_code;

        x_raw_revenue     :=  l_raw_revenue;
	/* Added the following out parameters for Doosan rate api changes */

	x_bill_rate :=l_bill_rate;
        x_markup_percentage :=null;

  ELSIF (p_non_labor_sch_type = 'B' ) THEN

     /*------------------------------------------------------------+
       |22. Non non_labor resource bill rate overrides                  |
       +------------------------------------------------------------+
         |    Set bill rate and raw revenue using non non_labor resource  |
         |    bill rate overrides.                                    |
         +------------------------------------------------------------*/
     /*bill_rate, bill_trans_raw_revenue,bill_trans_currency_code,
       amount_calculation_code,bill_markup_percentage,discount_percentage,
       non_labor_multiplier,rate_source_id */

        /*** MCB Changes : Update the bill transaction bill rate, bill transaction raw revenue and
                            other audit columns.
                            - Amount calculation code = 'O' for overrides
                            - Bill Transaction Currency code is from overrides table.
                            - Change column from raw_revenue to bill_trans_raw_revnue
                              (Bill rate and Raw revenue should update only in Bill transaction currency)
                            - Change the WHERE clause from raw_revenue IS NULL to
                              bill_trans_raw_revenue IS NULL
                            - Update denom raw cost if markup applied
                          - Update denom burden cost if markup applied                           ***/

/* Changes done for bug 2668753. In the cursor C_Nl_Bill_Rate_Overrides_Mcb, denom_raw_cost,denom_burdened_cost and denom_currency_code
   are changed to l_mcb_raw_cost ,l_mcb_burdened_cost and l_mcb_currency_code  */

   	 IF ( l_raw_revenue IS NULL)  THEN

 		DECLARE

		   CURSOR C_Nl_Bill_Rate_Overrides_Mcb IS
			  SELECT DECODE(o.bill_rate, NULL, NULL,o.bill_rate * NVL(p_bill_rate_multiplier,1)) b_rate,
			  DECODE(o.markup_percentage, NULL, NULL,o.markup_percentage ) b_markup,
        	         DECODE(o.bill_rate, NULL,
                            PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o.markup_percentage)
      		                * (DECODE(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),l_mcb_currency_code),
                               PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o.bill_rate * NVL(p_bill_rate_multiplier,1)
                               * p_quantity , o.rate_currency_code)) r_revenue,
          	         DECODE(o.bill_rate, NULL, l_mcb_currency_code, o.rate_currency_code)  rate_currency_code,
                     o.discount_percentage discount_pct
       	   FROM pa_nl_bill_rate_overrides o
          WHERE o.task_id = p_task_id
            AND o.expenditure_type = p_expenditure_type
            AND o.non_labor_resource = p_non_labor_resource
	      AND l_called_process <> 1 /*Added for Doosan rate api change */
            AND (o.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
            AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
        BETWEEN trunc(o.start_date_active)				/* BUG#3118592 */
            AND trunc(NVL(o.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */

          UNION

         SELECT DECODE(o.bill_rate, NULL,NULL, o.bill_rate * NVL(p_bill_rate_multiplier,1)),
	 DECODE(o.markup_percentage, NULL, NULL,o.markup_percentage ) b_markup,
                DECODE(o.bill_rate, NULL,
                PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o.markup_percentage)
		        * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),l_mcb_currency_code),
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o.bill_rate * NVL(p_bill_rate_multiplier,1)
                                      * p_quantity, o.rate_currency_code)),
                DECODE(o.bill_rate, NULL, l_mcb_currency_code, o.rate_currency_code) rate_currency_code,
 			    o.discount_percentage discount_pct
          FROM pa_nl_bill_rate_overrides o
         WHERE o.task_id = p_task_id
           AND o.expenditure_type = p_expenditure_type
           AND o.non_labor_resource is NULL
	     AND l_called_process <> 1 /*Added for Doosan rate api change */
           AND (o.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
           AND trunc(p_expenditure_item_date)					/* BUG#3118592 */
               BETWEEN trunc(o.start_date_active)				/* BUG#3118592 */
                   AND trunc(NVL(o.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
     	   AND NOT EXISTS
               (SELECT o3.bill_rate
                FROM pa_nl_bill_rate_overrides o3
               WHERE o3.task_id = p_task_id
                 AND o3.expenditure_type = p_expenditure_type
                 AND o3.non_labor_resource = p_non_labor_resource
		   AND l_called_process <> 1 /*Added for Doosan rate api change */
		 AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                 AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                     BETWEEN trunc(o3.start_date_active)			/* BUG#3118592 */
                         AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
			 )

       UNION

      SELECT DECODE(o2.bill_rate, NULL,NULL,o2.bill_rate * NVL(p_bill_rate_multiplier,1)),
       DECODE(o2.markup_percentage, NULL, NULL,o2.markup_percentage ) b_markup,
             DECODE(o2.bill_rate, NULL,
             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o2.markup_percentage)
		     * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),l_mcb_currency_code),
                  PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o2.bill_rate * NVL(p_bill_rate_multiplier,1)
                                       * p_quantity, o2.rate_currency_code)),
             DECODE(o2.bill_rate, NULL, l_mcb_currency_code, o2.rate_currency_code) rate_currency_code,
			 o2.discount_percentage discount_pct
        FROM pa_nl_bill_rate_overrides o2
       WHERE o2.project_id = p_project_id
         AND o2.expenditure_type = p_expenditure_type
         AND o2.non_labor_resource = p_non_labor_resource
	   AND l_called_process <> 2 /*Added for Doosan rate api change */
	 AND (o2.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
         AND trunc(p_expenditure_item_date)					/* BUG#3118592 */
             BETWEEN trunc(o2.start_date_active)				/* BUG#3118592 */
                 AND trunc(NVL(o2.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
         AND NOT EXISTS
            (SELECT o3.bill_rate
               FROM pa_nl_bill_rate_overrides o3
              WHERE o3.task_id = p_task_id
                AND o3.expenditure_type = p_expenditure_type
		  AND l_called_process <> 1 /*Added for Doosan rate api change */
		AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                    BETWEEN trunc(o3.start_date_active)				/* BUG#3118592 */
                    AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
		    )

      UNION

     SELECT DECODE(o2.bill_rate, NULL,NULL,o2.bill_rate * NVL(p_bill_rate_multiplier,1)) b_rate,
            DECODE(o2.markup_percentage, NULL, NULL,o2.markup_percentage ) b_markup,
            DECODE(o2.bill_rate, NULL,
            PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o2.markup_percentage)
		    * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),l_mcb_currency_code),
                  PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o2.bill_rate * NVL(p_bill_rate_multiplier,1)
                                       * p_quantity, o2.rate_currency_code)) r_revenue,
            DECODE(o2.bill_rate, NULL, l_mcb_currency_code, o2.rate_currency_code) rate_currency_code,
			o2.discount_percentage discount_pct
      FROM pa_nl_bill_rate_overrides o2
     WHERE o2.project_id = p_project_id
       AND o2.expenditure_type = p_expenditure_type
       AND o2.non_labor_resource is NULL
         AND l_called_process <> 2 /*Added for Doosan rate api change */
       AND (o2.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
       AND trunc(p_expenditure_item_date)					/* BUG#3118592 */
           BETWEEN trunc(o2.start_date_active)					/* BUG#3118592 */
               AND trunc(NVL(o2.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
       AND NOT EXISTS
			(SELECT o3.bill_rate
               FROM pa_nl_bill_rate_overrides o3
              WHERE o3.task_id = p_task_id
                AND o3.expenditure_type = p_expenditure_type
		  AND l_called_process <> 1 /*Added for Doosan rate api change */
	        AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
            BETWEEN trunc(o3.start_date_active)					/* BUG#3118592 */
                AND trunc(NVL(o3.end_date_active,p_expenditure_item_date)))	/* BUG#3118592 */
				AND NOT EXISTS
				        (SELECT o3.bill_rate
                           FROM pa_nl_bill_rate_overrides o3
                          WHERE o3.project_id = p_project_id
                            AND o3.expenditure_type = p_expenditure_type
                            AND o3.non_labor_resource = p_non_labor_resource
			      AND l_called_process <> 2 /*Added for Doosan rate api change */
			    AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                            AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                        BETWEEN trunc(o3.start_date_active)				/* BUG#3118592 */
                            AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
						);



   	   CURSOR C_Nl_Bill_Rate_Overrides IS
   		  SELECT DECODE(o.bill_rate, NULL, NULL, o.bill_rate * NVL(p_bill_rate_multiplier,1)) b_rate,
	  	 DECODE(o.markup_percentage, NULL, NULL, o.markup_percentage) b_markup,
                 DECODE(o.bill_rate,NULL,
                 PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o.markup_percentage)
                 * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),p_proj_func_currency),
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o.bill_rate * NVL(p_bill_rate_multiplier,1)
                                      * p_quantity, o.rate_currency_code)) r_revenue,
                   DECODE(o.bill_rate, NULL, p_proj_func_currency, o.rate_currency_code) rate_currency_code,
				   o.discount_percentage discount_pct
              FROM pa_nl_bill_rate_overrides o
             WHERE o.task_id = p_task_id
               AND o.expenditure_type = p_expenditure_type
               AND o.non_labor_resource = p_non_labor_resource
	        AND l_called_process <> 1 /*Added for Doosan rate api change */
	       AND (o.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
               AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                   BETWEEN trunc(o.start_date_active)				/* BUG#3118592 */
                   AND trunc(NVL(o.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
            UNION
            SELECT DECODE(o.bill_rate, NULL,NULL, o.bill_rate * NVL(p_bill_rate_multiplier,1)),
	    	 DECODE(o.markup_percentage, NULL, NULL, o.markup_percentage) b_markup,
                   DECODE(o.bill_rate, NULL,
                   PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o.markup_percentage)
                   * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),p_proj_func_currency),
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o.bill_rate * NVL(p_bill_rate_multiplier,1)
                                      * p_quantity, o.rate_currency_code)),
                   DECODE(o.bill_rate, NULL, p_proj_func_currency, o.rate_currency_code) rate_currency_code ,
				   o.discount_percentage discount_pct
              FROM pa_nl_bill_rate_overrides o
             WHERE o.task_id = p_task_id
               AND o.expenditure_type = p_expenditure_type
               AND o.non_labor_resource is NULL
	        AND l_called_process <> 1 /*Added for Doosan rate api change */
	       AND (o.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
               AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                   BETWEEN trunc(o.start_date_active)				/* BUG#3118592 */
                   AND trunc(NVL(o.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
               AND NOT EXISTS
                  (SELECT o3.bill_rate
                     FROM pa_nl_bill_rate_overrides o3
                    WHERE o3.task_id = p_task_id
                      AND o3.expenditure_type = p_expenditure_type
                      AND o3.non_labor_resource = p_non_labor_resource
		       AND l_called_process <> 1 /*Added for Doosan rate api change */
		      AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                      AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                          BETWEEN trunc(o3.start_date_active)				/* BUG#3118592 */
                          AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
                  )
            UNION
            SELECT DECODE(o2.bill_rate, NULL,NULL,o2.bill_rate * NVL(p_bill_rate_multiplier,1)),
	    	 DECODE(o2.markup_percentage, NULL, NULL, o2.markup_percentage) b_markup,
                   DECODE(o2.bill_rate, NULL,
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o2.markup_percentage)
                    * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),p_proj_func_currency),
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o2.bill_rate * NVL(p_bill_rate_multiplier,1)
                                       * p_quantity, o2.rate_currency_code)),
                   DECODE(o2.bill_rate, NULL, p_proj_func_currency, o2.rate_currency_code) rate_currency_code ,
				   o2.discount_percentage discount_pct
              FROM pa_nl_bill_rate_overrides o2
             WHERE o2.project_id = p_project_id
               AND o2.expenditure_type = p_expenditure_type
               AND o2.non_labor_resource = p_non_labor_resource
	        AND l_called_process <> 2 /*Added for Doosan rate api change */
	       AND (o2.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
               AND trunc(p_expenditure_item_date)					/* BUG#3118592 */
                   BETWEEN trunc(o2.start_date_active)					/* BUG#3118592 */
                   AND trunc(NVL(o2.end_date_active,p_expenditure_item_date))		/* BUG#3118592 */
               AND NOT EXISTS
                  (SELECT o3.bill_rate
                     FROM pa_nl_bill_rate_overrides o3
                    WHERE o3.task_id = p_task_id
                      AND o3.expenditure_type = p_expenditure_type
		       AND l_called_process <> 1 /*Added for Doosan rate api change */
		      AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                      AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                          BETWEEN trunc(o3.start_date_active)				/* BUG#3118592 */
                          AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
                  )
            UNION
            SELECT DECODE(o2.bill_rate, NULL,NULL,o2.bill_rate * NVL(p_bill_rate_multiplier,1)),
	    	 DECODE(o2.markup_percentage, NULL, NULL, o2.markup_percentage) b_markup,
                   DECODE(o2.bill_rate, NULL,
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o2.markup_percentage)
                    * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100), p_proj_func_currency),
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o2.bill_rate * NVL(p_bill_rate_multiplier,1)
                                       * p_quantity, o2.rate_currency_code)),
                   DECODE(o2.bill_rate, NULL, p_proj_func_currency, o2.rate_currency_code) rate_currency_code,
   		           o2.discount_percentage discount_pct
              FROM pa_nl_bill_rate_overrides o2
             WHERE o2.project_id = p_project_id
               AND o2.expenditure_type = p_expenditure_type
               AND o2.non_labor_resource is NULL
	        AND l_called_process <> 2 /*Added for Doosan rate api change */
	       AND (o2.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
               AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                   BETWEEN trunc(o2.start_date_active)				/* BUG#3118592 */
                   AND trunc(NVL(o2.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
               AND NOT EXISTS
                  (SELECT o3.bill_rate
                     FROM pa_nl_bill_rate_overrides o3
                    WHERE o3.task_id = p_task_id
                      AND o3.expenditure_type = p_expenditure_type
		       AND l_called_process <> 1 /*Added for Doosan rate api change */
		      AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                      AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                          BETWEEN trunc(o3.start_date_active)				/* BUG#3118592 */
                          AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
                  )
               AND NOT EXISTS
                  (SELECT o3.bill_rate
                     FROM pa_nl_bill_rate_overrides o3
                    WHERE o3.project_id = p_project_id
                      AND o3.expenditure_type = p_expenditure_type
                      AND o3.non_labor_resource = p_non_labor_resource
		       AND l_called_process <> 2 /*Added for Doosan rate api change */
		      AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                      AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
                          BETWEEN trunc(o3.start_date_active)				/* BUG#3118592 */
                          AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */

           );


	BEGIN


	IF  ( p_mcb_flag='Y') THEN   /* MCB enabled */

			-- Opening cursor and fetching row
	      FOR Rec_Nl_Bill_Rate_Overrides IN C_Nl_Bill_Rate_Overrides_Mcb LOOP
	        -- Checking if the cursor is returning more than one row then error out
	        IF (l_true) THEN
	          RAISE l_more_than_one_row_excep;
	        ELSE
	          l_true := TRUE;
	        END IF;

	        -- Assigning the raw revenue to the local variable
	        l_raw_revenue      := Rec_Nl_Bill_Rate_Overrides.r_revenue;

                --Assigning the override discount rate to the local variable
                l_rate_discount_pct := Rec_Nl_Bill_Rate_Overrides.discount_pct;

	        x_Rev_curr_code     := rec_nl_bill_rate_overrides.rate_currency_code;
		/* Added the following out parameters for Doosan rate api changes */

            x_bill_rate :=Rec_Nl_Bill_Rate_Overrides.b_rate;
	    x_markup_percentage :=Rec_Nl_Bill_Rate_Overrides.b_markup;

	      END LOOP;
	ELSE /* IF p_mcb=N*/

	 	 		 -- Opening cursor and fetching row
	      FOR Rec_Nl_Bill_Rate_Overrides IN C_Nl_Bill_Rate_Overrides LOOP
	        -- Checking if the cursor is returning more than one row then error out
	        IF (l_true) THEN
	          RAISE l_more_than_one_row_excep;
	        ELSE
	          l_true := TRUE;
	        END IF;
	        -- Assigning the raw revenue to the local variable
	        l_raw_revenue      := Rec_Nl_Bill_Rate_Overrides.r_revenue;

            --Assigning the override discount rate to the local variable
            l_rate_discount_pct := Rec_Nl_Bill_Rate_Overrides.discount_pct;
	    x_Rev_curr_code     := rec_nl_bill_rate_overrides.rate_currency_code;
	    /* Added the following out parameters for Doosan rate api changes */

            x_bill_rate :=Rec_Nl_Bill_Rate_Overrides.b_rate;
	    x_markup_percentage :=Rec_Nl_Bill_Rate_Overrides.b_markup;
	        END LOOP;

	END IF;/* end of  p_mcb*/

	EXCEPTION
          WHEN l_more_than_one_row_excep THEN
	   RAISE;
	END;/*End of  Item 22 ,pcb_='Y'*/
   IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','1001 Disc. Percent: ' || l_rate_discount_pct || 'Revenue : '
		      || l_raw_revenue || 'currency_code : ' || x_Rev_curr_code);
   END IF;
    END IF;



 l_true :=false ;
     /*--------------------------------------------------------------+
         |23. Std non labor resource bill rates schedule                |
         +--------------------------------------------------------------+
         |    Set non labor markup bill rate, raw revenue, adjusted     |
         |    rate and adjusted revenue using std non labor resource    |
         |    bill rate schedules.                                      |
         |    If discounted revenue after markup is less than raw cost, |
         |    set adjusted revenue equal to raw cost.                   |
         +--------------------------------------------------------------*/
	 /** Change for Project Manufacturing, For bill markup raw_cost is used.
	     For System Linkage 'Burdened Transaction' the raw_cost = 0
	     So in this case we have to substitute raw_cost by burden_cost
      **/
/* Changes done for bug 2668753. In the cursor C_Std_Non_Labor_Mcb, denom_raw_cost,denom_burdened_cost and denom_currency_code
   are changed to l_mcb_raw_cost ,l_mcb_burdened_cost and l_mcb_currency_code  */

	  	IF  ( l_raw_revenue IS NULL)   THEN
/*added for bug 2690011 .If there is
any performance issue because of
the select statements below
then l_proj_std_bill_rate_sch_id and
l_task_std_bill_rate_sch_id can be passed as
input parameters to these functions*/


/* Commenting out the below select statements as the schedule ids are now passed as input
   parameters to the function */
/*  SELECT non_lab_std_bill_rt_sch_id
into l_proj_std_bill_rate_sch_id
FROM pa_projects_all
WHERE project_id=p_project_id;

SELECT non_lab_std_bill_rt_sch_id
into l_task_std_bill_rate_sch_id
FROM pa_tasks
WHERE task_id=p_task_id;   */

l_proj_std_bill_rate_sch_id := p_proj_nl_std_bill_rate_sch_id;
l_task_std_bill_rate_sch_id := p_task_nl_std_bill_rate_sch_id;

			 DECLARE
			   CURSOR C_Std_Non_Labor_Mcb IS
			   SELECT DECODE(b.rate, NULL,NULL, b.rate * NVL(p_bill_rate_multiplier,1)) b_rate,
			      DECODE(b.markup_percentage, NULL,NULL, b.markup_percentage ) b_markup,
                      DECODE(b.rate, NULL,
                      		 PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
		                     * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),l_mcb_currency_code),
                     		 PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                             * p_quantity, b.rate_currency_code)) r_revenue,
                      DECODE(NVL(l_rate_discount_pct,p_task_sch_discount), NULL, NULL,
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                             * (100 - NVL(l_rate_discount_pct,p_task_sch_discount)) /100 , b.rate_currency_code)) adjusted_rate,
                      DECODE(NVL(l_rate_discount_pct,p_task_sch_discount), NULL,NULL,DECODE(b.rate, NULL,
                      		 PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
							 * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100)
							 * ((100 - NVL(l_rate_discount_pct,p_task_sch_discount)) / 100), l_mcb_currency_code),
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((b.rate * p_quantity)
                             * NVL(p_bill_rate_multiplier,1)
                             * (100 - NVL(l_rate_discount_pct,p_task_sch_discount)) / 100, b.rate_currency_code))) trans_adjusted_revenue,
                      DECODE(b.rate, NULL, l_mcb_currency_code, b.rate_currency_code) rate_currency_code,
                      NVL(l_rate_discount_pct,p_task_sch_discount) discount_pct
                 FROM pa_bill_rates_all b
                WHERE /*b.std_bill_rate_schedule = p_task_std_bill_rate_sch
                  AND b.bill_rate_organization_id = p_task_bill_rate_org_id commented for bug2690011*/
                      b.bill_rate_sch_id=l_task_std_bill_rate_sch_id/*added for  bug2690011*/
                  AND b.expenditure_type = p_expenditure_type
                  AND b.non_labor_resource = p_non_labor_resource
		  AND (b.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                  AND trunc(NVL(p_task_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
              BETWEEN trunc(b.start_date_active)				/* BUG#3118592 */
                  AND NVL(trunc(b.end_date_active),trunc(NVL(p_task_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */

   			    UNION

               SELECT DECODE(b2.rate, NULL, NULL,b2.rate * NVL(p_bill_rate_multiplier,1)),
	          DECODE(b2.markup_percentage, NULL,NULL, b2.markup_percentage ) b_markup,
                      DECODE(b2.rate, NULL, PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b2.markup_percentage)
		                     * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),l_mcb_currency_code),
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b2.rate * NVL(p_bill_rate_multiplier,1)
                             * p_quantity, b2.rate_currency_code)),
                      DECODE(NVL(l_rate_discount_pct,p_project_sch_discount), NULL, NULL,
					         PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b2.rate * NVL(p_bill_rate_multiplier,1)
                             * (100 - NVL(l_rate_discount_pct,p_project_sch_discount)) /100, b2.rate_currency_code)),
                      DECODE(NVL(l_rate_discount_pct,p_project_sch_discount), NULL,NULL,DECODE(b2.rate, NULL,
					         PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b2.markup_percentage) *
                             (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100)
                             * ((100 - NVL(l_rate_discount_pct,p_project_sch_discount)) / 100), l_mcb_currency_code),
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((b2.rate * p_quantity)
                             * NVL(p_bill_rate_multiplier,1) * (100 - NVL(l_rate_discount_pct,p_project_sch_discount)) / 100, b2.rate_currency_code))),
                      DECODE(b2.rate, NULL, l_mcb_currency_code, b2.rate_currency_code) rate_currency_code,
                      NVL(l_rate_discount_pct,p_project_sch_discount) discount_pct
                 FROM pa_bill_rates_all b2
                WHERE /*b2.std_bill_rate_schedule = p_project_std_bill_rate_sch
                  AND b2.bill_rate_organization_id = p_project_bill_rate_org_id commented for bug2690011*/
                      b2.bill_rate_sch_id=l_proj_std_bill_rate_sch_id/*added for  bug2690011*/
                  AND b2.expenditure_type = p_expenditure_type
                  AND b2.non_labor_resource = p_non_labor_resource
		  AND (b2.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                  AND trunc(NVL(p_project_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
              BETWEEN trunc(b2.start_date_active)				/* BUG#3118592 */
                  AND NVL(trunc(b2.end_date_active),trunc(NVL(p_project_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */
				  AND NOT EXISTS
                     	  (SELECT b3.rate
                         FROM pa_bill_rates_all b3
                        WHERE /*b3.std_bill_rate_schedule = p_task_std_bill_rate_sch
                          AND b3.bill_rate_organization_id =p_task_bill_rate_org_id commented for bug2690011*/
                              b3.bill_rate_sch_id=l_task_std_bill_rate_sch_id/*added for  bug2690011*/
                          AND b3.expenditure_type = p_expenditure_type
                          AND b3.non_labor_resource = p_non_labor_resource
			  AND (b3.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                          AND trunc(NVL(p_task_sch_date,p_expenditure_item_date))		/* BUG#3118592 */
                      BETWEEN trunc(b3.start_date_active)					/* BUG#3118592 */
                          AND NVL(trunc(b3.end_date_active),trunc(NVL(p_task_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */
                     );

		 CURSOR C_Std_Non_Labor IS
			   SELECT DECODE(b.rate, NULL,NULL, b.rate * NVL(p_bill_rate_multiplier,1)) b_rate,
			      DECODE(b.markup_percentage, NULL,NULL, b.markup_percentage ) b_markup,
                      DECODE(b.rate, NULL,
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
                             * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),p_proj_func_currency),
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                             * p_quantity, b.rate_currency_code)) r_revenue,
                      DECODE(NVL(l_rate_discount_pct,p_task_sch_discount), NULL, NULL,
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                             * (100 - NVL(l_rate_discount_pct,p_task_sch_discount)) /100, b.rate_currency_code)) adjusted_rate,
                      DECODE(NVL(l_rate_discount_pct,p_task_sch_discount), NULL,NULL,DECODE(b.rate, NULL,
                      		 PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                             (100 + b.markup_percentage) * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100)
                             * ((100 - NVL(l_rate_discount_pct,p_task_sch_discount)) / 100), p_proj_func_currency ),
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((b.rate * p_quantity)
                             * NVL(p_bill_rate_multiplier,1)
                             * (100 - NVL(l_rate_discount_pct,p_task_sch_discount)) / 100, b.rate_currency_code))) trans_adjusted_revenue,
                      DECODE(b.rate, NULL, p_proj_func_currency, b.rate_currency_code) rate_currency_code,
                      NVL(l_rate_discount_pct,p_task_sch_discount) discount_pct
                 FROM pa_bill_rates_all b
                WHERE/* b.std_bill_rate_schedule = p_task_std_bill_rate_sch
                  AND b.bill_rate_organization_id = p_task_bill_rate_org_id commented for bug2690011*/
		       b.bill_rate_sch_id=l_task_std_bill_rate_sch_id/*added for  bug2690011*/
                  AND b.expenditure_type = p_expenditure_type
                  AND b.non_labor_resource = p_non_labor_resource
		  AND (b.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                  AND trunc(NVL(p_task_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
              BETWEEN trunc(b.start_date_active)				/* BUG#3118592 */
                  AND NVL(trunc(b.end_date_active),trunc(NVL(p_task_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */

                UNION

               SELECT DECODE(b2.rate, NULL, NULL,b2.rate * NVL(p_bill_rate_multiplier,1)),
	          DECODE(b2.markup_percentage, NULL,NULL, b2.markup_percentage ) b_markup,
                      DECODE(b2.rate, NULL,
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b2.markup_percentage)
                             * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),
                             p_proj_func_currency),
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b2.rate * NVL(p_bill_rate_multiplier,1)
                             * p_quantity, b2.rate_currency_code)),
                      DECODE(NVL(l_rate_discount_pct,p_project_sch_discount), NULL, NULL,
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b2.rate * NVL(p_bill_rate_multiplier,1)
                             * (100 - NVL(l_rate_discount_pct,p_project_sch_discount)) /100, b2.rate_currency_code)),
                      DECODE(NVL(l_rate_discount_pct,p_project_sch_discount), NULL,NULL,DECODE(b2.rate, NULL,
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b2.markup_percentage)
							 * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100)
							 * ((100 - NVL(l_rate_discount_pct,p_project_sch_discount)) / 100)
                             ,p_proj_func_currency),
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((b2.rate * p_quantity)
                             * NVL(p_bill_rate_multiplier,1)
                             * (100 - NVL(l_rate_discount_pct,p_project_sch_discount)) / 100, b2.rate_currency_code))),
                      DECODE(b2.rate, NULL, p_proj_func_currency, b2.rate_currency_code) rate_currency_code,
                      NVL(l_rate_discount_pct,p_project_sch_discount) discount_pct
                 FROM pa_bill_rates_all b2
                WHERE/* b2.std_bill_rate_schedule = p_project_std_bill_rate_sch
                  AND b2.bill_rate_organization_id = p_project_bill_rate_org_id commented for bug2690011*/
                      b2.bill_rate_sch_id=l_proj_std_bill_rate_sch_id/*added for  bug2690011*/
                  AND b2.expenditure_type = p_expenditure_type
                  AND b2.non_labor_resource = p_non_labor_resource
		  AND (b2.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                  AND trunc(NVL(p_project_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
              BETWEEN trunc(b2.start_date_active)				/* BUG#3118592 */
                  AND NVL(trunc(b2.end_date_active),trunc(NVL(p_project_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */
                  AND NOT EXISTS
				          (SELECT b3.rate
                 FROM pa_bill_rates_all b3
                WHERE /*b3.std_bill_rate_schedule = p_task_std_bill_rate_sch
                  AND b3.bill_rate_organization_id =p_task_bill_rate_org_id commented for bug2690011*/
		      b3.bill_rate_sch_id=l_task_std_bill_rate_sch_id/*added for bug2690011*/
                  AND b3.expenditure_type = p_expenditure_type
                  AND b3.non_labor_resource = p_non_labor_resource
		  AND (b3.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                  AND trunc(NVL(p_task_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
              BETWEEN trunc(b3.start_date_active)				/* BUG#3118592 */
                  AND NVL(trunc(b3.end_date_active),trunc(NVL(p_task_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */
			  );

	  BEGIN
		IF  ( p_mcb_flag='Y') THEN   /* MCB enabled */
			-- Opening cursor and fetching row
	          FOR Rec_Std_Non_Labor IN C_Std_Non_Labor_Mcb LOOP
	              -- Checking if the cursor is returning more than one row then error out
	             IF (l_true) THEN
	                RAISE l_more_than_one_row_excep;
	             ELSE
	                l_true := TRUE;
	             END IF;

	            -- Assigning the raw revenue to the local variable
	            l_raw_revenue      := Rec_Std_Non_Labor.r_revenue;

	            -- Assigning the trans adjusted amount to local varaible
	            l_trans_adjust_amount := Rec_Std_Non_Labor.trans_adjusted_revenue;
		    x_rev_curr_code        := Rec_std_non_Labor.rate_currency_code;

	     /* Added the following out parameters for Doosan rate api changes */

		    x_bill_rate :=Rec_Std_Non_Labor.b_rate;
		     x_adjusted_bill_rate :=Rec_Std_Non_Labor.adjusted_rate; --4038485
		    x_markup_percentage :=Rec_Std_Non_Labor.b_markup;

	          END LOOP;
 		ELSE /* IF p_mcb=N*/
	 		 -- Opening cursor and fetching row
	           FOR Rec_Std_Non_Labor IN C_Std_Non_Labor LOOP
	             -- Checking if the cursor is returning more than one row then error out
	             IF (l_true) THEN
	               RAISE l_more_than_one_row_excep;
	             ELSE
	               l_true := TRUE;
	             END IF;

	            -- Assigning the raw revenue to the local variable
	            l_raw_revenue      := Rec_Std_Non_Labor.r_revenue;

	            -- Assigning the trans adjusted amount to local varaible
	            l_trans_adjust_amount := Rec_Std_Non_Labor.trans_adjusted_revenue;
		    x_rev_curr_code        := Rec_std_non_Labor.rate_currency_code;

		     /* Added the following out parameters for Doosan rate api changes */

		    x_bill_rate :=Rec_Std_Non_Labor.b_rate;
		     x_adjusted_bill_rate :=Rec_Std_Non_Labor.adjusted_rate; --4038485
		    x_markup_percentage :=Rec_Std_Non_Labor.b_markup;

	          END LOOP;
	        END IF;/* end of  p_mcb*/
	   EXCEPTION
	       WHEN l_more_than_one_row_excep THEN
	 	   RAISE;
	   END;/*End of  Item 23 ,pcb_='Y'*/

   IF g1_debug_mode  = 'Y' THEN
      pa_debug.write_file('LOG','1002 Disc. Percent: ' || l_rate_discount_pct || 'Revenue : '
		  || l_raw_revenue || 'currency_code : ' || x_Rev_curr_code);
   END IF;
	END IF;


 l_true :=false ;

	 /*--------------------------------------------------------------+
       |24. Non non_labor expenditure type bill rate overrides            |
         +--------------------------------------------------------------+
         |    Set bill rate and raw revenue using non non_labor expenditure |
         |    type bill rate or markup overrides.                       |
         +--------------------------------------------------------------*/

	 /** Change for Project Manufacturing, For bill markup raw_cost is used.
	     For System Linkage 'Burdened Transaction' the raw_cost = 0
	     So in this case we have to substitute raw_cost by burden_cost
          **/


   /*** MCB Changes : Update the bill transaction bill rate, bill transaction raw revenue and
                              other audit columns.
                            - Amount calculation code = 'O' for Overrides
                            - Bill Transaction Currency code is from overrides table.
                            - Change column from raw_revenue to bill_trans_raw_revnue
                              (Bill rate and Raw revenue should update only in Bill transaction currency)
                            - Change the WHERE clause from raw_revenue IS NULL to
                              bill_trans_raw_revenue IS NULL
                            - Update denom raw cost if markup applied
                            - Update denom burden cost if markup applied  ***/
/* Changes done for bug 2668753. In the cursor C_Exp_Type_Overrides_Ncb , denom_raw_cost,denom_burdened_cost and denom_currency_code are changed to l_mcb_raw_cost ,l_mcb_burdened_cost and l_mcb_currency_code  */

	   IF  ( l_raw_revenue IS NULL and l_rate_discount_pct is null) THEN

	        DECLARE
			 CURSOR C_Exp_Type_Overrides_Ncb IS
 			   SELECT DECODE(o.bill_rate, NULL, NULL,o.bill_rate * NVL(p_bill_rate_multiplier,1)) b_rate,
			    DECODE(o.markup_percentage, NULL, NULL,o.markup_percentage ) b_markup,
                      DECODE(o.bill_rate, NULL,
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o.markup_percentage)
					  * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),
                      l_mcb_currency_code),
                      PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o.bill_rate * NVL(p_bill_rate_multiplier,1)
                      * p_quantity, o.rate_currency_code)) r_revenue,
                      DECODE(o.bill_rate, NULL, l_mcb_currency_code, o.rate_currency_code) rate_currency_code,
                      o.discount_percentage discount_pct
                FROM pa_nl_bill_rate_overrides o
               WHERE o.task_id = p_task_id
                 AND o.expenditure_type = p_expenditure_type
                 AND o.non_labor_resource IS NULL
		 AND l_called_process <> 1 /*Added for Doosan rate api change */
		 AND (o.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                 AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
             BETWEEN trunc(o.start_date_active)					/* BUG#3118592 */
                 AND trunc(NVL(o.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */

			   UNION

              SELECT DECODE(o2.bill_rate, NULL, NULL,o2.bill_rate * NVL(p_bill_rate_multiplier,1)),
	       DECODE(o2.markup_percentage, NULL, NULL,o2.markup_percentage ) b_markup,
                     DECODE(o2.bill_rate, NULL,
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o2.markup_percentage)
  		             * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),
                     l_mcb_currency_code),
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o2.bill_rate * NVL(p_bill_rate_multiplier,1)
                     * p_quantity, o2.rate_currency_code)),
                     DECODE(o2.bill_rate, NULL, l_mcb_currency_code, o2.rate_currency_code) rate_currency_code,
                     o2.discount_percentage
                FROM pa_nl_bill_rate_overrides o2
               WHERE o2.project_id = p_project_id
                 AND o2.expenditure_type = p_expenditure_type
                 AND o2.non_labor_resource IS NULL
		 AND l_called_process <> 2 /*Added for Doosan rate api change */
		 AND (o2.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                 AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
             BETWEEN trunc(o2.start_date_active)				/* BUG#3118592 */
                 AND trunc(NVL(o2.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
                 AND NOT EXISTS
                        (SELECT o3.bill_rate
                           FROM pa_nl_bill_rate_overrides o3
                          WHERE o3.task_id = p_task_id
                            AND o3.expenditure_type = p_expenditure_type
                            AND o3.non_labor_resource IS NULL
			    AND l_called_process <> 1 /*Added for Doosan rate api change */
			    AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                            AND trunc(p_expenditure_item_date)			/* BUG#3118592 */
                        BETWEEN trunc(o3.start_date_active)			/* BUG#3118592 */
                            AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
                        );


			 CURSOR C_Exp_Type_Overrides IS
				SELECT DECODE(o.bill_rate, NULL, NULL,o.bill_rate * NVL(p_bill_rate_multiplier,1)) b_rate,
				 DECODE(o.markup_percentage, NULL, NULL,o.markup_percentage ) b_markup,
                       DECODE(o.bill_rate, NULL,
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o.markup_percentage)
                       * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),p_proj_func_currency),
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o.bill_rate * NVL(p_bill_rate_multiplier,1)
                       * p_quantity, o.rate_currency_code)) r_revenue,
                       DECODE(o.bill_rate, NULL, p_proj_func_currency, o.rate_currency_code) rate_currency_code,
                       o.discount_percentage discount_pct
                  FROM pa_nl_bill_rate_overrides o
                 WHERE o.task_id = p_task_id
                   AND o.expenditure_type = p_expenditure_type
                   AND o.non_labor_resource IS NULL
		   AND l_called_process <> 1 /*Added for Doosan rate api change */
		   AND (o.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                   AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
               BETWEEN trunc(o.start_date_active)				/* BUG#3118592 */
                   AND trunc(NVL(o.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */

	             UNION

			    SELECT DECODE(o2.bill_rate, NULL, NULL,o2.bill_rate * NVL(p_bill_rate_multiplier,1)),
			     DECODE(o2.markup_percentage, NULL, NULL,o2.markup_percentage ) b_markup,
                       DECODE(o2.bill_rate, NULL,
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + o2.markup_percentage)
                       * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),p_proj_func_currency),
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(o2.bill_rate * NVL(p_bill_rate_multiplier,1)
                       * p_quantity, o2.rate_currency_code)),
                       DECODE(o2.bill_rate, NULL, p_proj_func_currency, o2.rate_currency_code) rate_currency_code,
                       o2.discount_percentage
                 FROM pa_nl_bill_rate_overrides o2
                WHERE o2.project_id = p_project_id
                  AND o2.expenditure_type = p_expenditure_type
                  AND o2.non_labor_resource IS NULL
		  AND l_called_process <> 2 /*Added for Doosan rate api change */
		  AND (o2.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                  AND trunc(p_expenditure_item_date)				/* BUG#3118592 */
              BETWEEN trunc(o2.start_date_active)				/* BUG#3118592 */
                  AND trunc(NVL(o2.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
                  AND NOT EXISTS
                          (SELECT o3.bill_rate
                             FROM pa_nl_bill_rate_overrides o3
                            WHERE o3.task_id = p_task_id
                              AND o3.expenditure_type = p_expenditure_type
                              AND o3.non_labor_resource IS NULL
			      AND l_called_process <> 1 /*Added for Doosan rate api change */
			      AND (o3.bill_rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                              AND trunc(p_expenditure_item_date)		/* BUG#3118592 */
                          BETWEEN trunc(o3.start_date_active)			/* BUG#3118592 */
                              AND trunc(NVL(o3.end_date_active,p_expenditure_item_date))	/* BUG#3118592 */
                          );

		BEGIN

	   	   IF  ( p_mcb_flag='Y') THEN   /* MCB enabled */

			   -- Opening cursor and fetching row
    	       FOR Rec_Exp_Type_Overrides IN C_Exp_Type_Overrides_Ncb LOOP
	        -- Checking if the cursor is returning more than one row then error out
	        IF (l_true) THEN
	          RAISE l_more_than_one_row_excep;
	        ELSE
	          l_true := TRUE;
	        END IF;

	        -- Assigning the raw revenue to the local variable
	        l_raw_revenue      := Rec_Exp_Type_Overrides.r_revenue;

            -- Assigning the Override discount percentage to the local variable
	        l_rate_discount_pct  := Rec_Exp_Type_Overrides.discount_pct;
		x_rev_curr_code      := Rec_exp_type_overrides.rate_currency_code;

	 /* Added the following out parameters for Doosan rate api changes */

		    x_bill_rate := Rec_Exp_Type_Overrides.b_rate;
		    x_markup_percentage := Rec_Exp_Type_Overrides.b_markup;


             	         END LOOP;
		  ELSE /* IF p_mcb=N*/

	 	 		 -- Opening cursor and fetching row
			 FOR Rec_Exp_Type_Overrides IN C_Exp_Type_Overrides LOOP
	        -- Checking if the cursor is returning more than one row then error out
	        IF (l_true) THEN
	          RAISE l_more_than_one_row_excep;
	        ELSE
	          l_true := TRUE;
	        END IF;

	        -- Assigning the raw revenue to the local variable
	        l_raw_revenue      := Rec_Exp_Type_Overrides.r_revenue;
		x_rev_curr_code      := Rec_exp_type_overrides.rate_currency_code;

    /* Added the following out parameters for Doosan rate api changes */

		    x_bill_rate := Rec_Exp_Type_Overrides.b_rate;
		    x_markup_percentage := Rec_Exp_Type_Overrides.b_markup;


	      END LOOP;

  END IF;/* end of  p_mcb*/
   IF g1_debug_mode  = 'Y' THEN
      pa_debug.write_file('LOG','1002 Disc. Percent: ' || l_rate_discount_pct || 'Revenue : '
		  || l_raw_revenue || 'currency_code : ' || x_Rev_curr_code);
   END IF;


	EXCEPTION
          WHEN l_more_than_one_row_excep THEN
  	   RAISE;
	END;/*End of  Item 24 ,pcb_='Y'*/
END IF;


       /*--------------------------------------------------------------+
         |25. Std non non_labor expenditure type bill rates schedule        |
         +--------------------------------------------------------------+
         |    Set non non_labor markup bill rate, raw revenue, adjusted     |
         |    rate and adjusted revenue using std non non_labor expenditure |
         |    type bill rates schedules.                                |
         |    If discounted revenue after markup is less than raw cost, |
         |    set adjusted revenue equal to raw cost.                   |
         +--------------------------------------------------------------*/

          /*** MCB Changes : Update the bill transaction bill rate, bill transaction raw revenue and
                              other audit columns.
                            - Amount calculation code = 'B' for Bill Rates.
                            - Bill Transaction Currency code is from overrides table.
                            - Change column from raw_revenue to bill_trans_raw_revnue
                              (Bill rate and Raw revenue should update only in Bill transaction currency)
                            - Change the WHERE clause from raw_revenue IS NULL to
                              bill_trans_raw_revenue IS NULL
                            - Update denom raw cost if markup applied
                            - Update denom burden cost if markup applied  ***/



           l_true :=false ;
/* Changes done for bug 2668753.In the cursor C_Std_Exp_Type_Sch_Ncb ,denom_raw_cost,denom_burdened_cost and denom_currency_code
   are changed to l_mcb_raw_cost ,l_mcb_burdened_cost and l_mcb_currency_code  */

                /* changes done for bug 4169912, in the cursor C_Std_Exp_Type_Sch_Ncb to change the p_task_sch_discount to
                   NVL(l_rate_discount_pct,p_task_sch_discount) so that it'll be taken into consideration
                   while calculating adjusted rate if any override discount Percentage is there */
	   IF  ( l_raw_revenue IS NULL )  THEN


	        DECLARE
 			   CURSOR C_Std_Exp_Type_Sch_Ncb IS
				SELECT DECODE  (b.rate, NULL,NULL, b.rate * NVL(p_bill_rate_multiplier,1)) b_rate,
				 DECODE  (b.markup_percentage, NULL,NULL, b.markup_percentage ) b_markup,
                       DECODE  (b.rate, NULL,
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
   		               * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),
                       l_mcb_currency_code) ,
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                       * p_quantity, b.rate_currency_code)) r_revenue,
                       DECODE (NVL(l_rate_discount_pct,p_task_sch_discount), NULL, NULL,
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                       * (100 - NVL(l_rate_discount_pct,p_task_sch_discount)) /100, b.rate_currency_code) ) adjusted_rate ,
                       DECODE(NVL(l_rate_discount_pct,p_task_sch_discount), NULL, NULL,
              		          DECODE(b.rate, NULL,
							  PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                    		  (100 + b.markup_percentage) * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100)
                              * ((100 - NVL(l_rate_discount_pct,p_task_sch_discount)) / 100),  l_mcb_currency_code),
                              PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((b.rate * p_quantity)
                              * NVL(p_bill_rate_multiplier,1)* (100 - NVL(l_rate_discount_pct,p_task_sch_discount)) / 100, b.rate_currency_code))
                             ) trans_adjusted_amount,
                       DECODE(b.rate, NULL, l_mcb_currency_code, b.rate_currency_code) rate_currency_code ,
                       NVL(l_rate_discount_pct,p_task_sch_discount) discount_pct
		          FROM pa_bill_rates_all b
                 WHERE /*b.std_bill_rate_schedule = p_task_std_bill_rate_sch
                   AND b.bill_rate_organization_id = p_task_bill_rate_org_id commented for bug2690011*/
		       b.bill_rate_sch_id=l_task_std_bill_rate_sch_id/*added for bug2690011*/
                   AND b.expenditure_type = p_expenditure_type
                   AND b.non_labor_resource IS NULL
	           AND (b.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                   AND trunc(NVL(p_task_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
               BETWEEN trunc(b.start_date_active)				/* BUG#3118592 */
                   AND NVL(trunc(b.end_date_active),trunc(NVL(p_task_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
                          )
                 UNION

                SELECT DECODE(b2.rate, NULL, NULL,b2.rate * NVL(p_bill_rate_multiplier,1)) b_rate,
		 DECODE  (b2.markup_percentage, NULL,NULL, b2.markup_percentage ) b_markup,
                       DECODE(b2.rate, NULL,
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b2.markup_percentage)
		               * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100),l_mcb_currency_code),
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b2.rate * NVL(p_bill_rate_multiplier,1)
                       * p_quantity, b2.rate_currency_code)) r_revenue,
                       DECODE(NVL(l_rate_discount_pct,p_project_sch_discount), NULL, NULL,
                       PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b2.rate * NVL(p_bill_rate_multiplier,1)
                       * (100 - NVL(l_rate_discount_pct,p_project_sch_discount)) /100, b2.rate_currency_code)) adjusted_rate,
                       DECODE(NVL(l_rate_discount_pct,p_project_sch_discount), NULL, NULL,
                		      DECODE(b2.rate, NULL,
                              PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                              (100 + b2.markup_percentage) * (decode(p_sl_function,6,l_mcb_burdened_cost,l_mcb_raw_cost) / 100)
                              * ((100 - NVL(l_rate_discount_pct,p_project_sch_discount)) / 100),l_mcb_currency_code),
                              PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((b2.rate * p_quantity)
                              * NVL(p_bill_rate_multiplier,1) * (100 - NVL(l_rate_discount_pct,p_project_sch_discount)) / 100,
							  b2.rate_currency_code))) trans_adjusted_amount,
                       DECODE(b2.rate, NULL, l_mcb_currency_code, b2.rate_currency_code) rate_currency_code,
                       NVL(l_rate_discount_pct,p_project_sch_discount) discount_pct
		        FROM pa_bill_rates_all b2
               WHERE /*b2.std_bill_rate_schedule = p_project_std_bill_rate_sch
                 AND b2.bill_rate_organization_id = p_project_bill_rate_org_id commented for bug2690011*/
		     b2.bill_rate_sch_id=l_proj_std_bill_rate_sch_id/*added for  bug2690011*/
                 AND b2.expenditure_type = p_expenditure_type
                 AND b2.non_labor_resource IS NULL
	         AND (b2.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                 AND trunc(NVL(p_project_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
             BETWEEN trunc(b2.start_date_active)				/* BUG#3118592 */
                 AND NVL(trunc(b2.end_date_active), trunc(NVL(p_project_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */
                 AND NOT EXISTS
                         (SELECT b3.rate
                            FROM pa_bill_rates_all b3
                           WHERE /*b3.std_bill_rate_schedule = p_task_std_bill_rate_sch
                             AND b3.bill_rate_organization_id = p_task_bill_rate_org_id commented for bug2690011*/
		                 b3.bill_rate_sch_id=l_task_std_bill_rate_sch_id/*added for  bug2690011*/
                             AND b3.expenditure_type = p_expenditure_type
                             AND b3.non_labor_resource IS NULL
		             AND (b3.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                             AND trunc(NVL(p_task_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
                         BETWEEN trunc(b3.start_date_active)				/* BUG#3118592 */
                             AND NVL(trunc(b3.end_date_active),				/* BUG#3118592 */
                                 trunc(NVL(p_task_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */
                         );


		   CURSOR C_Std_Exp_Type_Sch IS
		      SELECT DECODE(b.rate, NULL,NULL, b.rate * NVL(p_bill_rate_multiplier,1)) b_rate,
		       DECODE  (b.markup_percentage, NULL,NULL, b.markup_percentage ) b_markup,
			         DECODE(b.rate, NULL,
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b.markup_percentage)
                     * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),p_proj_func_currency),
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                     * p_quantity, b.rate_currency_code)) r_revenue,
                     DECODE(NVL(l_rate_discount_pct,p_task_sch_discount), NULL, NULL,
                     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b.rate * NVL(p_bill_rate_multiplier,1)
                     * (100 - NVL(l_rate_discount_pct,p_task_sch_discount)) /100, b.rate_currency_code)) adjusted_rate,
                     DECODE (NVL(l_rate_discount_pct,p_task_sch_discount), NULL,NULL,
					         DECODE(b.rate, NULL,
						     PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
                             (100 + b.markup_percentage) * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100)
                             * ((100 - NVL(l_rate_discount_pct,p_task_sch_discount)) / 100), p_proj_func_currency),
                             PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((b.rate * p_quantity)
                             * NVL(p_bill_rate_multiplier,1)* (100 - NVL(l_rate_discount_pct,p_task_sch_discount)) / 100,
							 b.rate_currency_code))) trans_adjusted_amount,
				     DECODE(b.rate, NULL, p_proj_func_currency, b.rate_currency_code) rate_currency_code ,
                     NVL(l_rate_discount_pct,p_task_sch_discount) discount_pct
		       FROM pa_bill_rates_all b
              WHERE /*b.std_bill_rate_schedule = p_task_std_bill_rate_sch
                AND b.bill_rate_organization_id = p_task_bill_rate_org_id commented for bug2690011*/
		    b.bill_rate_sch_id=l_task_std_bill_rate_sch_id/*added for  bug2690011*/
                AND b.expenditure_type = p_expenditure_type
                AND b.non_labor_resource IS NULL
	        AND (b.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                AND trunc(NVL(p_task_sch_date,p_expenditure_item_date))		/* BUG#3118592 */
            BETWEEN trunc(b.start_date_active)					/* BUG#3118592 */
                AND NVL(trunc(b.end_date_active),trunc(NVL(p_task_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */

			  UNION

			 SELECT DECODE(b2.rate, NULL, NULL,b2.rate * NVL(p_bill_rate_multiplier,1)),
			  DECODE  (b2.markup_percentage, NULL,NULL, b2.markup_percentage ) b_markup,
                    DECODE(b2.rate, NULL,
					PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((100 + b2.markup_percentage)
                    * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100),p_proj_func_currency),
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b2.rate * NVL(p_bill_rate_multiplier,1)
                    * p_quantity, b2.rate_currency_code)),
                    DECODE(NVL(l_rate_discount_pct,p_project_sch_discount), NULL, NULL,
                    PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(b2.rate * NVL(p_bill_rate_multiplier,1)
                    * (100 - NVL(l_rate_discount_pct,p_project_sch_discount)) /100, b2.rate_currency_code)),
                    DECODE(NVL(l_rate_discount_pct,p_project_sch_discount), NULL,NULL,
                           DECODE(b2.rate, NULL,
						   PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(
						   (100 + b2.markup_percentage) * (decode(p_sl_function,6,p_burden_cost,p_raw_cost) / 100)
                           * ((100 - NVL(l_rate_discount_pct,p_project_sch_discount)) / 100), p_proj_func_currency),
                           PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT((b2.rate * p_quantity)
                           * NVL(p_bill_rate_multiplier,1)* (100 - NVL(l_rate_discount_pct,p_project_sch_discount)) / 100, b2.rate_currency_code))),
                    DECODE(b2.rate, NULL, p_proj_func_currency, b2.rate_currency_code) rate_currency_code,
                    NVL(l_rate_discount_pct,p_project_sch_discount)
		       FROM pa_bill_rates_all b2
              WHERE /*b2.std_bill_rate_schedule = p_project_std_bill_rate_sch
                AND b2.bill_rate_organization_id = p_project_bill_rate_org_id commented for bug2690011*/
		    b2.bill_rate_sch_id=l_proj_std_bill_rate_sch_id /*added for  bug2690011*/
                AND b2.expenditure_type = p_expenditure_type
                AND b2.non_labor_resource IS NULL
	        AND (b2.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                AND trunc(NVL(p_project_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
                    BETWEEN trunc(b2.start_date_active)				/* BUG#3118592 */
					AND NVL(trunc(b2.end_date_active),trunc(NVL(p_project_sch_date,p_expenditure_item_date)))	/* BUG#3118592 */
                AND NOT EXISTS
                        (SELECT b3.rate
                           FROM pa_bill_rates_all b3
                          WHERE /*b3.std_bill_rate_schedule = p_task_std_bill_rate_sch
                            AND b3.bill_rate_organization_id = p_task_bill_rate_org_id commented for bug2690011*/
		                b3.bill_rate_sch_id=l_task_std_bill_rate_sch_id /*added for  bug2690011*/
                            AND b3.expenditure_type = p_expenditure_type
                            AND b3.non_labor_resource IS NULL
			    AND (b3.rate IS NULL OR p_uom_flag =1 ) /*Added for UOM enhancement */
                            AND trunc(NVL(p_task_sch_date,p_expenditure_item_date))	/* BUG#3118592 */
                                BETWEEN trunc(b3.start_date_active)			/* BUG#3118592 */
                                AND NVL(trunc(b3.end_date_active), trunc(NVL(p_task_sch_date, /* BUG#3118592 */
                                             p_expenditure_item_date)))
                         );

		BEGIN

	   	   IF  ( p_mcb_flag='Y') THEN   /* MCB enabled */

			   -- Opening cursor and fetching row
    	       FOR Rec_Std_Exp_Type_Sch IN C_Std_Exp_Type_Sch_Ncb LOOP
	        -- Checking if the cursor is returning more than one row then error out
	        IF (l_true) THEN
	          RAISE l_more_than_one_row_excep;
	        ELSE
	          l_true := TRUE;
	        END IF;

	        -- Assigning the raw revenue to the local variable
	        l_raw_revenue      := Rec_Std_Exp_Type_Sch.r_revenue;

			-- Assigning the bill rate to the local variable
	        l_trans_adjust_amount        := Rec_Std_Exp_Type_Sch.trans_adjusted_amount;
		x_rev_curr_code              := Rec_Std_Exp_type_sch.rate_currency_code;

		 /* Added the following out parameters for Doosan rate api changes */

	        x_bill_rate := Rec_Std_Exp_Type_Sch.b_rate;
		 x_adjusted_bill_rate :=Rec_Std_Exp_Type_Sch.adjusted_rate; --4038485
                x_markup_percentage := Rec_Std_Exp_Type_Sch.b_markup;



   	         END LOOP;
		  ELSE /* IF p_mcb=N*/

	 	 		 -- Opening cursor and fetching row
			 FOR Rec_Exp_Type_Sch IN C_Std_Exp_Type_Sch LOOP
	        -- Checking if the cursor is returning more than one row then error out
	        IF (l_true) THEN
	          RAISE l_more_than_one_row_excep;
	        ELSE
	          l_true := TRUE;
	        END IF;

	        -- Assigning the raw revenue to the local variable
	        l_raw_revenue      := Rec_Exp_Type_Sch.r_revenue;

			-- Assigning the bill rate to the local variable
	        l_trans_adjust_amount := Rec_Exp_Type_Sch.trans_adjusted_amount;
		x_rev_curr_code              := Rec_Exp_Type_Sch.rate_currency_code;

		 /* Added the following out parameters for Doosan rate api changes */

	        x_bill_rate := Rec_Exp_Type_Sch.b_rate;
		 x_adjusted_bill_rate :=Rec_Exp_Type_Sch.adjusted_rate; --4038485
                x_markup_percentage := Rec_Exp_Type_Sch.b_markup;

	      END LOOP;
	  END IF;/* end of  p_mcb*/

	EXCEPTION
	  WHEN l_more_than_one_row_excep THEN
	   RAISE;
	END;/*End of  Item 25 ,pcb_='Y'*/

   IF g1_debug_mode  = 'Y' THEN
        pa_debug.write_file('LOG','1004 Disc. Percent: ' || l_rate_discount_pct ||
	 'Revenue : ' || l_raw_revenue || 'currency_code : ' || x_Rev_curr_code);
   END IF;

	END IF;
END IF ;/*End of scheduled type check*/


    IF (l_trans_adjust_amount IS NOT NULL ) THEN
       l_txn_raw_revenue := l_trans_adjust_amount;
    ELSE
       l_txn_raw_revenue   := l_raw_revenue;
    END IF;

    IF ( l_txn_raw_revenue IS NULL)   THEN
       RAISE l_no_revenue;
    END IF;

    x_raw_revenue         := l_txn_raw_revenue ;
    x_return_status := l_x_return_status;

   IF g1_debug_mode  = 'Y' THEN
        pa_debug.write_file('LOG','9999 Disc. Percent: ' || l_rate_discount_pct ||
	 'Revenue : ' || l_raw_revenue || 'currency_code : ' || x_Rev_curr_code);
   END IF;

EXCEPTION

   WHEN l_no_revenue THEN
        x_raw_revenue:= NULL;
	/* Added the following out parameters for Doosan rate api changes */

	x_bill_rate :=null;
        x_markup_percentage :=null;
	 x_adjusted_bill_rate :=null; --4038485

        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_NO_BILL_RATE');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count     := 1;
   IF g1_debug_mode  = 'Y' THEN
        pa_debug.write_file('LOG','1.SQLERROR ' || SQLCODE);
   END IF;

   WHEN OTHERS THEN
        x_raw_revenue:= NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	/* Added the following out parameters for Doosan rate api changes */

	x_bill_rate :=null;
        x_markup_percentage :=null;
	 x_adjusted_bill_rate :=null; --4038485

      px_exp_func_curr_code   :=  lx_exp_func_curr_code;
      x_raw_revenue           :=  null;
      x_rev_Curr_code         := null;

        x_msg_count    := 1;
        x_msg_data      := SUBSTR(SQLERRM,1,30);
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_REVENUE', /* name of the package*/
                                    p_procedure_name   => 'Non_labor_Assignment');
   IF g1_debug_mode  = 'Y' THEN
        pa_debug.write_file('LOG','2.SQLERROR ' || SQLCODE);
   END IF;
           RAISE;
        END IF;

END Non_Labor_Rev_amount;

END PA_REVENUE;


/
