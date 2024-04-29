--------------------------------------------------------
--  DDL for Package Body PA_RATE_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RATE_PVT_PKG" as
/* $Header: PAXRTPVB.pls 120.4.12010000.5 2009/03/12 14:23:58 spasala ship $ */
-- This procedure contains consolidated procedure and function to calculate the raw cost,
-- burdened cost and raw revenue on the basis of passed parameters
-- Input parameters
-- Parameters                     Type           Required      Description
-- p_calling_mode                 VARCHAR2        YES          Calling mode values are ACTUAL/ROLE/ASSIGNMENT
-- p_rate_calc_date               DATE            YES          Rate calculation date
-- P_item_id                      NUMBER          YES          Unique identifier
-- P_project_id                   NUMBER          YES          Project Id
-- P_quantity                     NUMBER          YES          Quantity in Hours
-- P_forecast_job_id              NUMBER          NO           Forecast job Id at assignment level
-- P_forecast_job_group_id        NUMBER          NO           Forecast job group id at assignment level
-- p_person_id                    NUMBER          NO           Person id
-- p_expenditure_org_id           NUMBER          NO           Expenditure org id
-- P_expenditure_type             VARCHAR2        NO           Expenditure Type
-- p_expenditure_organization_id  NUMBER          NO           Expenditure organization id
-- p_project_org_id               NUMBER          NO           Project  org id
-- p_labor_cost_multi_name        VARCHAR2        NO           Labor cost multiplier name for calculating the cost
-- p_expenditure_currency_code    VARCHAR2        NO           Expenditure functional currency code
-- P_proj_cost_job_group_id       NUMBER          NO           Project cost job gorup id
-- P_job_cost_rate_schedule_id    NUMBER          NO           Job cost rate schedule id
-- P_project_type                 VARCHAR2        NO           Project Type
-- P_task_id                      NUMBER          NO           Task Id  for the given project
-- p_projfunc_currency_code       VARCHAR2        NO           Project Functional currency code
-- P_bill_rate_multiplier         NUMBER          NO           Bill rate multiplier for calculating the revenue
-- P_project_bill_job_group_id    NUMBER          NO           Billing job group id for project
-- p_emp_bill_rate_schedule_id    NUMBER          NO           Employee bill rate schedule id
-- P_job_bill_rate_schedule_id    NUMBER          NO           Job bill rate schedule id
--                                                             and rate
-- p_distribution_rule            VARCHAR2        NO           Distribution rule
--
-- Out parameters
--
-- x_exp_func_raw_cost_rate       NUMBER          YES          Row cost rate in expenditure currency
-- x_exp_func_raw_cost            NUMBER          YES          Row cost in expenditure currency
-- x_exp_func_burdened_cost_rate  NUMBER          YES          Burdened cost rate in  expenditure currency
-- x_exp_func_burdened_cost       NUMBER          YES          Burdened cost in  expenditure currency
-- x_projfunc_bill_rate               NUMBER          YES          Bill rate in project currency
-- x_projfunc_raw_revenue             NUMBER          YES          Raw revenue in project currency
-- x_projfunc_raw_cost                NUMBER          YES          Raw cost in project currency
-- x_projfunc_raw_cost_rate           NUMBER          YES          Raw cost rate in project currency
-- x_projfunc_burdened_cost_rate      NUMBER          YES          Burdened cost rate in  project currency
-- x_projfunc_burdened_cost           NUMBER          YES          Burdened cost in  project currency
-- x_error_msg                    VARCHAR2        YES          Error message used in when others exception
-- x_rev_rejct_reason             VARCHAR2        YES          Rejection reason for revenue
-- x_cost_rejct_reason            VARCHAR2        YES          Rejection reason for cost
-- x_burdened_rejct_reason        VARCHAR2        YES          Rejection reason for burden
-- x_others_rejct_reason          VARCHAR2        YES          Rejection reason for other error like pl/sql etc.

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE get_item_amount(
        p_calling_mode                  IN     VARCHAR2   ,
        p_rate_calc_date                IN     DATE   ,
        p_item_id                       IN     NUMBER ,
        p_project_id                    IN     NUMBER ,
        p_quantity                      IN     NUMBER ,
        p_forecast_job_id               IN     NUMBER   DEFAULT NULL,
        p_forecast_job_group_id         IN     NUMBER   DEFAULT NULL,
        p_person_id                     IN     NUMBER   DEFAULT NULL,
        p_expenditure_org_id            IN     NUMBER   DEFAULT NULL,
        p_expenditure_type              IN     VARCHAR2 DEFAULT NULL,
        p_expenditure_organization_id   IN     NUMBER   DEFAULT NULL,
        p_project_org_id                IN     NUMBER   DEFAULT NULL,
        p_labor_cost_multi_name         IN     VARCHAR2 DEFAULT NULL,
        p_expenditure_currency_code     IN     VARCHAR2 DEFAULT NULL,
        p_proj_cost_job_group_id        IN     NUMBER   DEFAULT NULL,
        p_job_cost_rate_schedule_id     IN     NUMBER   DEFAULT NULL,
        p_project_type                  IN     VARCHAR2 DEFAULT NULL,
        p_task_id                       IN     NUMBER   DEFAULT NULL,
        p_bill_rate_multiplier          IN     NUMBER   DEFAULT NULL,
        p_project_bill_job_group_id     IN     NUMBER   DEFAULT NULL,
        p_emp_bill_rate_schedule_id     IN     NUMBER   DEFAULT NULL,
        p_job_bill_rate_schedule_id     IN     NUMBER   DEFAULT NULL,
        p_distribution_rule             IN     VARCHAR2 DEFAULT NULL,
        p_forecast_item_id              IN     NUMBER   DEFAULT NULL, /* added para for bug 2212852 */
        p_forecasting_type              IN     VARCHAR2 DEFAULT 'PROJECT_FORECASTING', /* added para for */
                                                                                       /* bug 2212852 */
        p_amount_calc_mode              IN     VARCHAR2, /* Added for Org Forecasting */
        p_system_linkage                IN     pa_expenditure_items_all.system_linkage_function%TYPE,/* Added */
                                               /* for Org Forecasting */
        p_assign_precedes_task          IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_schdl_discnt            IN     NUMBER   DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_bill_rate_org_id        IN     NUMBER   DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_std_bill_rate_schdl     IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_schedule_fixed_date     IN     DATE     DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_sch_type                IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
        p_projfunc_currency_code        IN     VARCHAR2 DEFAULT NULL,
        p_projfunc_rev_rt_dt_code       IN     VARCHAR2, /* Added for Org Forecasting */
        p_projfunc_rev_rt_date          IN     DATE,     /* Added for Org Forecasting */
        p_projfunc_rev_rt_type          IN     VARCHAR2, /* Added for Org Forecasting */
        p_projfunc_rev_exch_rt          IN     NUMBER,   /* Added for Org Forecasting */
        p_projfunc_cst_rt_date          IN     DATE,     /* Added for Org Forecasting */
        p_projfunc_cst_rt_type          IN     VARCHAR2, /* Added for Org Forecasting */
        x_projfunc_bill_rate            OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_projfunc_raw_revenue          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_projfunc_rev_rt_date          OUT    NOCOPY DATE,     /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_rev_rt_type          OUT    NOCOPY VARCHAR2, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_rev_exch_rt          OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_raw_cost             OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_projfunc_raw_cost_rate        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_projfunc_burdened_cost        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_projfunc_burdened_cost_rate   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_projfunc_cst_rt_date          OUT    NOCOPY DATE,     /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_cst_rt_type          OUT    NOCOPY VARCHAR2, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_cst_exch_rt          OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        p_project_currency_code         IN     VARCHAR2 DEFAULT NULL,           /* Added for org Forecasting */
        p_project_rev_rt_dt_code        IN     VARCHAR2, /* Added for org Forecasting */
        p_project_rev_rt_date           IN     DATE,     /* Added for org Forecasting */
        p_project_rev_rt_type           IN     VARCHAR2, /* Added for org Forecasting */
        p_project_rev_exch_rt           IN     NUMBER,   /* Added for org Forecasting */
        p_project_cst_rt_date           IN     DATE,     /* Added for org Forecasting */
        p_project_cst_rt_type           IN     VARCHAR2, /* Added for org Forecasting */
        x_project_bill_rt               OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_raw_revenue           OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_rev_rt_date           OUT    NOCOPY DATE,     /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_rev_rt_type           OUT    NOCOPY VARCHAR2, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_rev_exch_rt           OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_raw_cst               OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_raw_cst_rt            OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_burdned_cst           OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_burdned_cst_rt        OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_cst_rt_date           OUT    NOCOPY DATE,     /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_cst_rt_type           OUT    NOCOPY VARCHAR2, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_cst_exch_rt           OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_curr_code            OUT    NOCOPY VARCHAR2, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_raw_cost_rate        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_exp_func_raw_cost             OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_exp_func_burdened_cost_rate   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_exp_func_burdened_cost        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_exp_func_cst_rt_date          OUT    NOCOPY DATE,     /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_cst_rt_type          OUT    NOCOPY VARCHAR2, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_cst_exch_rt          OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_cst_txn_curr_code             OUT    NOCOPY VARCHAR2, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
        x_txn_raw_cst_rt                OUT    NOCOPY NUMBER , --File.Sql.39 bug 4440895
        x_txn_raw_cst                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_txn_burdned_cst_rt            OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_txn_burdned_cst               OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_rev_txn_curr_code             OUT    NOCOPY VARCHAR2, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
        x_txn_rev_bill_rt               OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_txn_rev_raw_revenue           OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_error_msg                     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_rev_rejct_reason              OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_cost_rejct_reason             OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_burdened_rejct_reason         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_others_rejct_reason           OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_return_status                 OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count                     OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data                      OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

  l_insufficient_parameters               EXCEPTION;
  l_raw_cost_null                         EXCEPTION;
  l_raw_proj_cost_null                    EXCEPTION;
  l_burdened_cost_null                    EXCEPTION;
  l_raw_revenue_null                      EXCEPTION;
  l_no_rule                               EXCEPTION;

  l_expenditure_org_id                    pa_project_assignments.expenditure_org_id%TYPE;
  l_expenditure_organization_id           pa_project_assignments.expenditure_organization_id%TYPE;
  l_expenditure_type                      pa_project_assignments.expenditure_type%TYPE;
  l_forecast_job_id                       pa_project_assignments.fcst_job_id%TYPE;
  l_forecast_job_group_id                 pa_project_assignments.fcst_job_group_id%TYPE;

  l_labor_cost_mult_name                  pa_tasks.labor_cost_multiplier_name%TYPE;
  l_project_type                          pa_project_types_all.project_type%TYPE;
  l_proj_cost_job_grp_id                  pa_std_bill_rate_schedules_all.job_group_id%TYPE;
  l_project_org_id                        pa_projects_all.org_id%TYPE;
  l_project_bill_job_group_id             pa_projects_all.bill_job_group_id%TYPE;
  l_emp_bill_rate_schedule_id             pa_projects_all.emp_bill_rate_schedule_id%TYPE;
  l_job_bill_rate_schedule_id             pa_projects_all.job_bill_rate_schedule_id%TYPE;
  l_distribution_rule                     pa_projects_all.distribution_rule%TYPE;

  l_job_cost_rate_schedule_id             pa_forecasting_options.job_cost_rate_schedule_id%TYPE;

  l_labor_schedule_fixed_date             pa_projects_all.labor_schedule_fixed_date%TYPE;
  l_labor_schedule_discount               NUMBER;
  l_labor_bill_rate_org_id                NUMBER;
  l_labor_std_bill_rate_schedule          pa_projects_all.labor_std_bill_rate_schdl%TYPE;
  l_labor_schedule_type                   pa_projects_all.labor_sch_type%TYPE;

  l_x_return_status                       VARCHAR2(50);
  l_x_process_return_status               VARCHAR2(50);
  l_schedule_type                         VARCHAR2(50);
  l_proj_cost_job_id                      NUMBER;
  l_proj_bill_job_id                      NUMBER;
  l_cost_rate_multiplier                  NUMBER;
  l_new_pvdr_acct_raw_cost                NUMBER;

  l_raw_cost_rate                         NUMBER;

  l_overr_to_organization_id              NUMBER;
  l_new_pvdr_acct_burdened_cost           NUMBER;
  l_burdened_cost_rate                    NUMBER;
  l_new_rcvr_acct_raw_cost                NUMBER;
  l_new_rcvr_acct_burdened_cost           NUMBER;
  l_new_rcvr_acct_raw_cost_rate           NUMBER;
  l_new_rcvr_acct_bur_cost_rate           NUMBER;
  l_new_rcvr_revenue                      NUMBER;

  l_class_code                            pa_project_types_all.project_type_class_code%TYPE;

  l_expenditure_currency_code        gl_sets_of_books.currency_code%TYPE;
  l_expenditure_curr_code_burdn      gl_sets_of_books.currency_code%TYPE;  /* Added for Org Forecasting */
  l_exp_func_cst_rt_date             DATE; /* Added for Org Forecasting */
  l_exp_func_cst_rt_type             PA_IMPLEMENTATIONS_ALL.default_rate_type%TYPE; /* Added for Org Forecasting */
  l_exp_func_cst_exch_rt             NUMBER; /* Added for Org Forecasting */
  l_exp_func_raw_cost_rate           NUMBER;
  l_exp_func_raw_cost                NUMBER;
  l_exp_func_burdened_cost_rate      NUMBER;
  l_exp_func_burdened_cost           NUMBER;

  /* Added for MCB2 */
   l_projfunc_currency_code          pa_projects_all.projfunc_currency_code%TYPE;
   l_projfunc_bil_rate_date_code     pa_projects_all.projfunc_bil_rate_date_code%TYPE;
   l_projfunc_bil_rate_type          pa_projects_all.projfunc_bil_rate_type%TYPE;
   l_projfunc_bil_rate_date          pa_projects_all.projfunc_bil_rate_date%TYPE;
   l_projfunc_bil_exchange_rate      pa_projects_all.projfunc_bil_exchange_rate%TYPE;
   l_projfunc_cost_rate_type         pa_projects_all.projfunc_cost_rate_type%TYPE;
   l_projfunc_cost_rate_date         pa_projects_all.projfunc_cost_rate_DATE%TYPE;
   l_projfunc_cost_exchange_rate     pa_projects_all.projfunc_bil_exchange_rate%TYPE;
   l_markup_percentage               pa_bill_rates_all.markup_percentage%TYPE; /* Added for Asgmt overide */
   l_assignment_precedes_task        pa_projects_all.assign_precedes_task%TYPE; /* Added for Asgmt overide */
/* Till here for mcb 2 */

/* Added for Org Foreasting */
   l_projfunc_bill_rate              NUMBER;
   l_projfunc_raw_revenue            NUMBER;
   l_projfunc_raw_cost               NUMBER;
   l_projfunc_raw_cost_rate          NUMBER;
   l_projfunc_burdened_cost          NUMBER;
   l_projfunc_burdened_cost_rate     NUMBER;

   l_amount_calc_mode               VARCHAR2(50);

   l_project_currency_code          pa_projects_all.project_currency_code%TYPE;
   l_project_bil_rate_date_code     pa_projects_all.project_bil_rate_date_code%TYPE;
   l_project_bil_rate_type          pa_projects_all.project_bil_rate_type%TYPE;
   l_project_bil_rate_date          pa_projects_all.project_bil_rate_date%TYPE;
   l_project_bil_exchange_rate      pa_projects_all.project_bil_exchange_rate%TYPE;
   l_project_cost_rate_type         pa_projects_all.project_rate_type%TYPE;
   l_project_cost_rate_date         pa_projects_all.project_rate_DATE%TYPE;
   l_project_cost_exchange_rate     pa_projects_all.project_bil_exchange_rate%TYPE;
   l_project_bill_rate              NUMBER;
   l_project_raw_revenue            NUMBER;
   l_project_raw_cost               NUMBER;
   l_project_raw_cost_rate          NUMBER;
   l_project_burdened_cost          NUMBER;
   l_project_burdened_cost_rate     NUMBER;

  l_cst_txn_curr_code               GL_SETS_OF_BOOKS.currency_code%TYPE;
  l_txn_raw_cst_rt                  NUMBER;
  l_txn_raw_cst                     NUMBER;
  l_txn_burdned_cst_rt              NUMBER;
  l_txn_burdned_cst                 NUMBER;

  l_rev_txn_curr_code               PA_BILL_RATES_ALL.rate_currency_code%TYPE;
  l_txn_rev_bill_rt                 NUMBER;
  l_txn_adjusted_bill_rt            NUMBER;--4038485
  l_txn_rev_raw_revenue             NUMBER;

  l_msg_data                        VARCHAR2(250); -- Added
  /* Till here for Org */

  /*LCE change*/
  l_err_code                        VARCHAR2(20);
  l_err_stage                       NUMBER;
  /*Till here for LCE.*/

BEGIN
     IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.Set_Curr_Function( p_function   => 'Get_Item_Amount');
      PA_DEBUG.g_err_stage := 'RT10 : Before Validation Entering PA_RATE_PVT_PKG.Get_Item_Amount';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;

    /* Validating that the required parameters should not be null  */
    IF ( p_calling_mode IS NULL) OR  (p_rate_calc_date IS NULL ) OR
       (p_item_id IS NULL) OR (p_project_id IS NULL) OR  (p_quantity  IS NULL) OR ( p_quantity = 0 ) THEN
           RAISE l_insufficient_parameters;
    END IF;

    /* Validating that the required parameters should not be null  */
    IF ( p_calling_mode  = 'ASSIGNMENT') THEN
      IF (p_person_id IS NULL) THEN
         RAISE l_insufficient_parameters;
      END IF;
    END IF;

     IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RTS10 : After sufficient parameter';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;
    /* Selecting distribution_rule from project all table only if the passed value is null
       otherwise storing passed values */
    /*
    IF (p_distribution_rule IS NULL) THEN
    ELSE
         l_distribution_rule           := p_distribution_rule    ;
    END IF;
    */
   BEGIN
      SELECT proj.distribution_rule,typ.project_type_class_code
      INTO   l_distribution_rule,l_class_code
      FROM pa_project_types_all typ, pa_projects_all proj
      WHERE   proj.project_id   = p_project_id
      AND     proj.project_type = typ.project_type
      AND     proj.org_id       = typ.org_id;      -- bug 7413961 skkoppul : removed NVL function

      IF ( l_class_code = 'CONTRACT') THEN
       IF ( l_distribution_rule IS NULL) THEN
         RAISE l_no_rule;
       END IF;
      END IF;
   EXCEPTION
         WHEN l_no_rule THEN
          x_others_rejct_reason := 'PA_FCST_DIST_RULE_NOT_FOUND';
          NULL;
         WHEN NO_DATA_FOUND THEN
           NULL;
   END;

     IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RTS11 : After Rule parameter'||to_char(p_rate_calc_date,'dd-mon-yyyy');
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

      PA_DEBUG.g_err_stage := 'RTS11.1 : checking para Quantity '||p_quantity||' calling mode '||p_calling_mode;
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     -- dbms_output.put_line('distribution_rule '||l_distribution_rule||'calling mode '||p_calling_mode||'item id' ||p_item_id||' proj id '||p_project_id||' p_person_id '||p_person_id||' date '||to_char(p_rate_calc_date,'dd-mon-yyyy'));
    END IF;

    /* Selecting expenditure org id , type ,organization id , forecast job id and forecast job group
    id from project assignments table only if the passed value is null otherwise storing passed
    values */
    IF (p_expenditure_org_id IS NULL) OR  (p_expenditure_type IS NULL ) OR
       (p_expenditure_organization_id IS NULL) OR (p_forecast_job_id IS NULL) OR
       (p_forecast_job_group_id IS NULL) THEN

       IF ( p_calling_mode  = 'ROLE') THEN
         SELECT NVL(expenditure_org_id,-99), expenditure_organization_id, expenditure_type,
                fcst_job_id, fcst_job_group_id
         INTO   l_expenditure_org_id,l_expenditure_organization_id,l_expenditure_type,
                l_forecast_job_id,l_forecast_job_group_id
         FROM pa_project_assignments
         WHERE project_id = p_project_id
         AND  assignment_id = p_item_id;

     IF g1_debug_mode  = 'Y' THEN
       PA_DEBUG.g_err_stage := 'RTS12 : After Role expenditure org id/orgnz id , job,job grp id par';
       PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;

       ELSIF ( p_calling_mode  = 'ASSIGNMENT') THEN
         BEGIN    -- Added for Bug 3877942
           SELECT NVL(resource_org_id,-99),resource_organization_id,
                  job_id
           INTO   l_expenditure_org_id,l_expenditure_organization_id,
                  l_forecast_job_id
           FROM pa_resources_denorm
           WHERE person_id    = p_person_id
           AND  ( p_rate_calc_date BETWEEN TRUNC(resource_effective_start_date) AND
                      NVL(TRUNC(Resource_effective_end_date),p_rate_calc_date));
         EXCEPTION  -- Added Exception block for Bug 3877942
	   WHEN NO_DATA_FOUND THEN
                IF g1_debug_mode  = 'Y' THEN
	          PA_DEBUG.g_err_stage := 'RTS12 : No Record in PA_RESOURCES_DENORM for this period start date' || p_rate_calc_date;
	          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                END IF;
                PA_DEBUG.Reset_Curr_Function;
                RETURN;
         END;

       IF g1_debug_mode  = 'Y' THEN
         PA_DEBUG.g_err_stage := 'RTS12 : After Asgn resource org id/orgnz id , job id par';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;

         SELECT job_group_id
         INTO   l_forecast_job_group_id
         FROM   per_jobs
         WHERE  job_id = l_forecast_job_id;

      IF g1_debug_mode  = 'Y' THEN
         PA_DEBUG.g_err_stage := 'RTS13 : After Asgn job grp id par';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

         SELECT expenditure_type
         INTO   l_expenditure_type
         FROM pa_project_assignments
         WHERE project_id = p_project_id
         AND  assignment_id = p_item_id;
        -- dbms_output.put_line(' after all assignment select ');

       ELSE                 /*for p_calling_mode <> 'ROLE' /'ASSIGNMENT'*/
/*LCE Changes : Selecting override organization if any. */

      IF g1_debug_mode  = 'Y' THEN
         PA_DEBUG.g_err_stage := 'RTS13.1 : Selecting override organization if any .';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

         PA_COST.override_exp_organization(P_item_date         => p_rate_calc_date              ,
                                  P_person_id                  => p_person_id                   ,
                                  P_project_id                 => p_project_id                  ,
                                  P_incurred_by_organz_id      => l_expenditure_organization_id ,
                                  P_Expenditure_type           => l_expenditure_type            ,
                                  X_overr_to_organization_id   => l_overr_to_organization_id    ,
                                  x_return_status              => l_x_return_status             ,
                                  x_msg_count                  => x_msg_count                   ,
                                  x_msg_data                   => l_msg_data
                                 );

        IF g1_debug_mode  = 'Y' THEN
          PA_DEBUG.g_err_stage := 'RTS13.2 : No override ...selecting expenditure organization id ';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

          IF l_overr_to_organization_id is NULL  THEN
           BEGIN
            SELECT organization_id
             INTO l_expenditure_organization_id
            FROM PER_ALL_ASSIGNMENTS_F     -- Bug 4358495 : per_assignments_f
            WHERE person_id = p_person_id
            AND   primary_flag ='Y'
            -- AND   assignment_type ='E'
            AND assignment_type IN ('E','C') -- Modified for CWK impacts
            AND   TRUNC (p_rate_calc_date) BETWEEN TRUNC(Effective_start_date)
                                               AND TRUNC(Effective_End_date);  /* Removed nvl on effective_end_date
                                                                                  as it is a NOT NULL column  For bug 2911451 */

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
         IF g1_debug_mode  = 'Y' THEN
            PA_DEBUG.g_err_stage :='RTS13.3 :No Expenditure organization id assigned to the person id :'||
                                   P_person_id;
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
            x_cost_rejct_reason     :='NO_ASSIGN';
           END;
         ELSE

         l_expenditure_organization_id := l_overr_to_organization_id;
        END IF;

         /*End of LCE changes*/

          END IF;

       IF g1_debug_mode  = 'Y' THEN
          PA_DEBUG.g_err_stage := 'RTS14 : After Asgn expenditure_type par';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;

	IF p_expenditure_org_id IS NOT NULL THEN
         	l_expenditure_org_id           := p_expenditure_org_id    ;
	END IF;
	IF p_expenditure_organization_id IS NOT NULL THEN
         	l_expenditure_organization_id  := p_expenditure_organization_id;
	END IF;

	IF p_expenditure_type IS NOT NULL THEN
         	l_expenditure_type             := p_expenditure_type;
	END IF;
	IF p_forecast_job_id IS NOT NULL THEN
            l_forecast_job_id              := p_forecast_job_id;
	END IF;
    ELSE

         l_expenditure_org_id           := p_expenditure_org_id    ;
         l_expenditure_organization_id  := p_expenditure_organization_id;
         l_expenditure_type             := p_expenditure_type;
         l_forecast_job_id              := p_forecast_job_id;
         l_forecast_job_group_id        := p_forecast_job_group_id;
    END IF;  /* Expenditure org id and others related if */



    -- dbms_output.put_line('l_expenditure_org_id '||to_char(l_expenditure_org_id));
    -- dbms_output.put_line('l_expenditure_organization_id '||to_char(l_expenditure_organization_id));
    -- dbms_output.put_line('l_expenditure_type '||l_expenditure_type);
    -- dbms_output.put_line('l_forecast_job_id '||to_char(l_forecast_job_id));
     -- dbms_output.put_line('l_forecast_job_group_id '||to_char(l_forecast_job_group_id));



    /* Selecting expenditure currency code from project set of books and implementations table
    only if the passed value is null otherwise storing passed  values */
    IF ( p_expenditure_currency_code IS NULL) THEN
      SELECT glsb.currency_code
      INTO   l_expenditure_currency_code
      FROM gl_sets_of_books glsb, pa_implementations_all paimp
      WHERE glsb.set_of_books_id = paimp.set_of_books_id
      AND  paimp.org_id  = l_expenditure_org_id;         -- bug 7413961 skkoppul: removed NVL function
    ELSE
      l_expenditure_currency_code     := p_expenditure_currency_code;
    END IF;

      l_expenditure_curr_code_burdn := l_expenditure_currency_code; /* Made for Org Forecasting */

    IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RTS15 : After currency code  par';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    -- dbms_output.put_line('l_expenditure_currency_code '||l_expenditure_currency_code);


    /* Selecting labor cost mult name from tasks  table only if the passed value is null and task id
    is not null otherwise storing passed  values */
    IF ( p_task_id IS NOT NULL ) THEN
      IF ( p_labor_cost_multi_name IS NULL ) THEN
        SELECT labor_cost_multiplier_name
        INTO   l_labor_cost_mult_name
        FROM pa_tasks
        WHERE task_id = p_task_id;
      ELSE
        l_labor_cost_mult_name     := p_labor_cost_multi_name;
      END IF;
    END IF;

   IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RTS16 : After task level cost multi name par - prj type '||p_project_type; --Bug 7423839
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;
     -- dbms_output.put_line('1');

    /* Selecting project type from project types table only if the
    passed value is null otherwise storing passed  values */
    IF ( p_project_type IS NULL) THEN

      SELECT typ.project_type
      INTO   l_project_type
      FROM   pa_project_types_all typ, pa_projects_all proj
      WHERE   proj.project_id      = p_project_id
      AND     proj.project_type    = typ.project_type
      AND     proj.org_id = typ.org_id;           -- bug 7413961 skkoppul: removed NVL function

    ELSE
      l_project_type           := p_project_type;
    END IF;

    IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RTS17 : After Project type par- prj type '||l_project_type; --Bug 7423839;
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    -- dbms_output.put_line('l_project_type '||l_project_type);
    END IF;

    /* Selecting  project org id, project currency code, project bill job
     group id, employee bill rate schedule id and job bill rate schedule id from project  all  table
     only if the passed value is null otherwise storing passed values */

    IF (p_project_org_id IS NULL) OR (p_projfunc_currency_code IS NULL)   OR  (p_project_bill_job_group_id IS NULL) OR
       (p_emp_bill_rate_schedule_id IS NULL) OR  (p_job_bill_rate_schedule_id  IS NULL) THEN
         SELECT NVL(org_id,-99), bill_job_group_id,
                emp_bill_rate_schedule_id,job_bill_rate_schedule_id,
                labor_schedule_fixed_date,
                projfunc_currency_code,
                projfunc_bil_rate_date_code, /* Added the following column for MCB2 */
                projfunc_bil_rate_type,
                projfunc_bil_rate_date,
                projfunc_bil_exchange_rate,
                projfunc_cost_rate_date,
                projfunc_cost_rate_type,
                NVL(assign_precedes_task,'1'),/* Added for Asgmt overide */
                project_currency_code,        /* Added for Org Forecasting */
                project_bil_rate_date_code,   /* Added for Org Forecasting */
                project_bil_rate_type,        /* Added for Org Forecasting */
                project_bil_rate_date,        /* Added for Org Forecasting */
                project_bil_exchange_rate,    /* Added for Org Forecasting */
                project_rate_date,            /* Added for Org Forecasting */
                project_rate_type,            /* Added for Org Forecasting */
                labor_schedule_discount,      /* Added for Org Forecasting */
                labor_bill_rate_org_id,       /* Added for Org Forecasting */
                labor_std_bill_rate_schdl,    /* Added for Org Forecasting */
                labor_schedule_fixed_date,    /* Added for Org Forecasting */
                labor_sch_type                /* Added for Org Forecasting */
         INTO   l_project_org_id,l_project_bill_job_group_id,
                l_emp_bill_rate_schedule_id,l_job_bill_rate_schedule_id ,
                l_labor_schedule_fixed_date,
                l_projfunc_currency_code,
                l_projfunc_bil_rate_date_code, /* Added the following columns for MCB2 */
                l_projfunc_bil_rate_type,
                l_projfunc_bil_rate_date,
                l_projfunc_bil_exchange_rate,
                l_projfunc_cost_rate_date,
                l_projfunc_cost_rate_type,
                l_assignment_precedes_task,
                l_project_currency_code,
                l_project_bil_rate_date_code,
                l_project_bil_rate_type,
                l_project_bil_rate_date,
                l_project_bil_exchange_rate,
                l_project_cost_rate_date,
                l_project_cost_rate_type,
                l_labor_schedule_discount,
                l_labor_bill_rate_org_id,
                l_labor_std_bill_rate_schedule,
                l_labor_schedule_fixed_date,
                l_labor_schedule_type
         FROM pa_projects_all
         WHERE project_id = p_project_id;

    IF g1_debug_mode  = 'Y' THEN
       -- dbms_output.put_line('projfunc currency '||l_projfunc_currency_code);
      PA_DEBUG.g_err_stage := 'RTS18 : After emp,job rate schedule , currency code  and org id  par';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    ELSE
	IF p_projfunc_currency_code IS NOT NULL THEN
         	l_projfunc_currency_code := p_projfunc_currency_code;
	 END IF;
	IF p_project_org_id IS NOT NULL THEN
         	l_project_org_id		:= p_project_org_id;
	END IF;
	IF p_project_bill_job_group_id IS NOT NULL THEN
         l_project_bill_job_group_id    := p_project_bill_job_group_id;
	END IF;
	IF p_emp_bill_rate_schedule_id IS NOT NULL THEN
         l_emp_bill_rate_schedule_id    := p_emp_bill_rate_schedule_id;
	END IF;
	IF p_job_bill_rate_schedule_id IS NOT NULL THEN
         l_job_bill_rate_schedule_id    := p_job_bill_rate_schedule_id;
	END IF;

        /* Added for Org Forecasting */
	IF p_labor_schdl_discnt IS NOT NULL THEN
         l_labor_schedule_discount    := p_labor_schdl_discnt;
	END IF;

	IF p_labor_bill_rate_org_id IS NOT NULL THEN
         l_labor_bill_rate_org_id    := p_labor_bill_rate_org_id;
	END IF;

	IF p_labor_std_bill_rate_schdl IS NOT NULL THEN
         l_labor_std_bill_rate_schedule    := p_labor_std_bill_rate_schdl;
	END IF;

	IF p_labor_schedule_fixed_date IS NOT NULL THEN
            l_labor_schedule_fixed_date := p_labor_schedule_fixed_date;
	END IF;

	IF p_labor_sch_type IS NOT NULL THEN
         l_labor_schedule_type    := p_labor_sch_type;
	END IF;

	IF p_projfunc_rev_rt_date IS NOT NULL THEN
         l_projfunc_bil_rate_date    := p_projfunc_rev_rt_date;
	END IF;

	IF p_projfunc_rev_rt_type IS NOT NULL THEN
         l_projfunc_bil_rate_type    := p_projfunc_rev_rt_type;
	END IF;

	IF p_projfunc_rev_exch_rt IS NOT NULL THEN
         l_projfunc_bil_exchange_rate    := p_projfunc_rev_exch_rt;
	END IF;

	IF p_projfunc_cst_rt_date IS NOT NULL THEN
         l_projfunc_cost_rate_date    := p_projfunc_cst_rt_date;
	END IF;

	IF p_projfunc_cst_rt_type IS NOT NULL THEN
         l_projfunc_cost_rate_type    := p_projfunc_cst_rt_type;
	END IF;

	IF p_project_currency_code IS NOT NULL THEN
         l_project_currency_code    := p_project_currency_code;
	END IF;

	IF p_project_rev_rt_date IS NOT NULL THEN
         l_project_bil_rate_date    := p_project_rev_rt_date;
	END IF;

	IF p_project_rev_rt_type IS NOT NULL THEN
         l_project_bil_rate_type    := p_project_rev_rt_type;
	END IF;

	IF p_project_rev_exch_rt IS NOT NULL THEN
         l_project_bil_exchange_rate    := p_project_rev_exch_rt;
	END IF;

	IF p_project_cst_rt_date IS NOT NULL THEN
         l_project_cost_rate_date    := p_project_cst_rt_date;
	END IF;

	IF p_project_cst_rt_type IS NOT NULL THEN
         l_project_cost_rate_type    := p_project_cst_rt_type;
	END IF;

    END IF;



     -- dbms_output.put_line('l_projfunc_currency_code '||l_projfunc_currency_code);
     -- dbms_output.put_line('l_project_org_id '||to_char(l_project_org_id));
    -- dbms_output.put_line('l_project_bill_job_group_id '||to_char(l_project_bill_job_group_id));
    -- dbms_output.put_line('l_emp_bill_rate_schedule_id '||to_char(l_emp_bill_rate_schedule_id));
    -- dbms_output.put_line('l_job_bill_rate_schedule_id '||to_char(l_job_bill_rate_schedule_id));




    /* Selecting project cost job group id,job cost rate schedule id from forecasting options and
       pa std billrate table only if the passed value is null otherwise storing passed  values */

    IF ( p_proj_cost_job_group_id IS NULL) OR ( p_job_cost_rate_schedule_id IS NULL) THEN
      SELECT bschal.job_group_id,foptal.job_cost_rate_schedule_id
      INTO   l_proj_cost_job_grp_id,l_job_cost_rate_schedule_id
      FROM   pa_std_bill_rate_schedules_all bschal,pa_forecasting_options_all foptal
      WHERE   bschal.bill_rate_sch_id  = foptal.job_cost_rate_schedule_id
  /* For Bug 4101595: Reverted the fix done for 3786192 */
/*  AND     nvl(foptal.org_id, -99) = nvl(l_expenditure_org_id, -99) */  /* Added for 3786192 */
      AND     foptal.org_id = l_project_org_id;      -- bug 7413961 skkoppul: removed NVL function, changed bschal.org_id to foptal.org_id

    ELSE
      l_proj_cost_job_grp_id       := p_proj_cost_job_group_id;
      l_job_cost_rate_schedule_id  := p_job_cost_rate_schedule_id;
    END IF;

    IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RTS19 : After cost job group id and cost rate schedule id par';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;
    -- dbms_output.put_line('l_proj_cost_job_grp_id '||to_char(l_proj_cost_job_grp_id));
     -- dbms_output.put_line('l_job_cost_rate_schedule_id '||to_char(l_job_cost_rate_schedule_id));

/* commented for Org Forecasting
    IF (l_labor_schedule_fixed_date IS NULL) THEN
      SELECT labor_schedule_fixed_date,
             projfunc_currency_code,
             projfunc_bil_rate_date_code, -- Added the following column for MCB2
             projfunc_bil_rate_type,
             projfunc_bil_rate_date,
             projfunc_bil_exchange_rate,
             projfunc_cost_rate_date,
             projfunc_cost_rate_type,
             NVL(assign_precedes_task,'1') -- Added for Asgmt overide
      INTO   l_labor_schedule_fixed_date,
             l_projfunc_currency_code,l_projfunc_bil_rate_date_code, -- Added the following columns for MCB2
             l_projfunc_bil_rate_type,l_projfunc_bil_rate_date,l_projfunc_bil_exchange_rate,
             l_projfunc_cost_rate_date,l_projfunc_cost_rate_type,
             l_assignment_precedes_task
      FROM pa_projects_all
      WHERE project_id = p_project_id;

    END IF;

*/

    IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RTS20 : After fixed date par';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     -- dbms_output.put_line('l_job_cost_rate_schedule_id '||to_char(l_job_cost_rate_schedule_id));


    PA_DEBUG.g_err_stage := 'RT11 : After Validation Entering PA_RATE_PVT_PKG.Get_Item_Amount';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     -- dbms_output.put_line('l_labor_schedule_fixed_date '||to_char(l_labor_schedule_fixed_date,'dd-mon-yyyy'));

    END IF;

    /* Calling the rate calculation APIs */

    l_Schedule_type := 'COST';
    l_amount_calc_mode  := p_amount_calc_mode; -- Added for Org Forecasting



    --------------------------------------------
    -- Initialize the successful return status
    --------------------------------------------

    l_x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_x_process_return_status := FND_API.G_RET_STS_SUCCESS;

    -------------------------------------------------
    --  Get the Raw Cost for Transaction Currency
    -------------------------------------------------

     -- dbms_output.put_line('starting of procs ');

   /* Added for Org Forecasting */
   IF ( (l_labor_schedule_type = 'I') AND ( l_amount_calc_mode = 'REVENUE') ) THEN
     l_amount_calc_mode := 'ALL';
   END IF;

     -- dbms_output.put_line('l_amount_calc_mode '||l_amount_calc_mode );
     -- dbms_output.put_line('p_calling_mode '||p_calling_mode);
   IF (l_amount_calc_mode <> 'REVENUE')  THEN /*  Added for Org For. { */

    IF ( (p_calling_mode = 'ASSIGNMENT') OR (p_calling_mode = 'UNASSIGNED') ) THEN

   IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RT12 : Entering PA_COST.get_raw_cost';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      PA_DEBUG.Log_Message ('p_person_id '||p_person_id||'l_expenditure_org_id '||l_expenditure_org_id); --skkoppul
      PA_DEBUG.Log_Message ('l_expenditure_organization_id '||l_expenditure_organization_id||' l_labor_cost_mult_name '||l_labor_cost_mult_name);
      PA_DEBUG.Log_Message ('p_rate_calc_date '||p_rate_calc_date||' l_expenditure_curr_code_burdn '||l_expenditure_curr_code_burdn||' p_quantity'||p_quantity);
   END IF;


      begin
     		pa_multi_currency_txn.G_calling_module:=p_calling_mode; --Bug 8243561: PRC: CALCULATE AMOUNTS DOES NOT PROCESS FUTURE DATED FIS
		-- dbms_output.put_line('pp_person_id '||p_person_id);
      PA_COST.get_raw_cost (
             P_person_id                  => p_person_id                  ,
             P_expenditure_org_id         => l_expenditure_org_id         ,
             P_expend_organization_id     => l_expenditure_organization_id ,          /*LCE*/
             P_labor_Cost_Mult_Name       => l_labor_cost_mult_name       ,
             P_Item_date                  => p_rate_calc_date             ,
             px_exp_func_curr_code        => l_expenditure_curr_code_burdn  ,
             P_Quantity                   => p_quantity                   ,
             X_Raw_cost_rate              => l_exp_func_raw_cost_rate     , /* Change for Org. Fore */
             X_Raw_cost                   => l_exp_func_raw_cost          , /* Change for Org. Fore */
             x_return_status              => l_x_return_status            ,
             x_msg_count                  => x_msg_count                  ,
             x_msg_data                   => l_msg_data
               );
       exception --Bug 7423839
        when others then
            PA_DEBUG.g_err_stage := 'Error in PA_COST.get_raw_cost';
            IF g1_debug_mode  = 'Y' THEN
               PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
               PA_DEBUG.Log_Message(p_message => 'x_msg_count '||x_msg_count || ' l_msg_data '||substr(l_msg_data,1,300)||' ret status '||l_x_return_status);
               PA_DEBUG.Log_Message(p_message => SQLERRM);
            END IF;
    end;


          x_exp_func_raw_cost_rate  := l_exp_func_raw_cost_rate;    /* Added for Org Forecasting */
          x_exp_func_raw_cost       := l_exp_func_raw_cost;         /* Added for Org Forecasting */
          x_exp_func_curr_code      := l_expenditure_curr_code_burdn; /* Added for Org Forecasting */

   IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RT13 : Leaving PA_COST.get_raw_cost';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;

    -- dbms_output.put_line('end of get raw cost '||l_x_return_status||' rate '||x_exp_func_raw_cost_rate||' raw cost '||x_exp_func_raw_cost||' Currency '||l_expenditure_currency_code);


    ELSIF (p_calling_mode = 'ROLE') THEN

    -- dbms_output.put_line('start of req raw cost '||l_x_return_status);


      IF g1_debug_mode  = 'Y' THEN
         PA_DEBUG.g_err_stage := 'RT12 : Entering PA_COST.requirement_raw_cost';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

         PA_COST.requirement_raw_cost(
                 p_forecast_cost_job_group_id   => l_forecast_job_group_id     ,
                 p_forecast_cost_job_id         => l_forecast_job_id           ,
                 p_proj_cost_job_group_id       => l_proj_cost_job_grp_id      ,
                 px_proj_cost_job_id            => l_proj_cost_job_id          ,
                 p_item_date                    => p_rate_calc_date            ,
                 p_job_cost_rate_sch_id         => l_job_cost_rate_schedule_id ,
                 p_schedule_date                => l_labor_schedule_fixed_date ,
                 p_quantity                     => p_quantity                  ,
                 p_cost_rate_multiplier         => l_cost_rate_multiplier      ,
                 P_expend_organization_id       => l_expenditure_organization_id ,          /*LCE*/
                 p_org_id                       => l_project_org_id            ,
                 x_raw_cost_rate                => l_exp_func_raw_cost_rate    ,
                 x_raw_cost                     => l_exp_func_raw_cost         ,
                 x_txn_currency_code            => l_expenditure_curr_code_burdn , /* Added for Org Forecasting */
                 x_return_status                => l_x_return_status           ,
                 x_msg_count                    => x_msg_count                 ,
                 x_msg_data                     => l_msg_data
                  );


          x_exp_func_raw_cost_rate  := l_exp_func_raw_cost_rate;    /* Added for Org Forecasting */
          x_exp_func_raw_cost       := l_exp_func_raw_cost;         /* Added for Org Forecasting */
          x_exp_func_curr_code      := l_expenditure_curr_code_burdn; /* Added for Org Forecasting */

     IF g1_debug_mode  = 'Y' THEN
         PA_DEBUG.g_err_stage := 'RT13 : Leaving PA_COST.requirement_raw_cost';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;
     -- dbms_output.put_line('end of req raw cost '||l_x_return_status||' : rate '||x_exp_func_raw_cost_rate||' cost '||x_exp_func_raw_cost||' Currency '||l_expenditure_currency_code);

    END IF;

    -- Validating that the called procedure has run without error , if not,then not calling others
    IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (NVL(l_exp_func_raw_cost,0) =   0) THEN

    -- dbms_output.put_line('in error of raw cost ');
        /* Commented this for bug 2199203 and write the other one */
       /*   x_cost_rejct_reason     := 'PA_FCST_NO_COST_RATE'; */
          x_cost_rejct_reason       := SUBSTR(l_msg_data,1,30);
          x_exp_func_raw_cost_rate  := 0;
          x_exp_func_raw_cost       := 0;
          x_exp_func_curr_code      := l_expenditure_currency_code; /* Added for Org Forecasting */

	  l_x_process_return_status  := l_x_return_status;

    -- dbms_output.put_line('in error of raw cost x_cost_rejct_reason '||NVL(x_cost_rejct_reason,'Bye Bye'));
      --   RAISE l_raw_cost_null;

    END IF;

    l_new_pvdr_acct_raw_cost    := l_exp_func_raw_cost;
    l_raw_cost_rate             := l_exp_func_raw_cost_rate;

-- dbms_output.put_line(' error in multi cost 1 '||x_cost_rejct_reason);
    --------------------------------------------------------------------
    -- To get the Override Organization Id, The procedure will be called,
    -- This is only for Staffed assignment. (Assignment)
    --------------------------------------------------------------------
    IF (p_calling_mode = 'ASSIGNMENT') THEN

    -- dbms_output.put_line('start of override '||l_x_return_status);
    IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RT14 : Entering PA_COST.override_exp_organization';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

      PA_COST.override_exp_organization(P_item_date                  => p_rate_calc_date              ,
                                        P_person_id                  => p_person_id                   ,
                                        P_project_id                 => p_project_id                  ,
                                        P_incurred_by_organz_id      => l_expenditure_organization_id ,
                                        P_Expenditure_type           => l_expenditure_type            ,
                                        X_overr_to_organization_id   => l_overr_to_organization_id    ,
                                        x_return_status              => l_x_return_status             ,
                                        x_msg_count                  => x_msg_count                   ,
                                        x_msg_data                   => l_msg_data
                                        );

    IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RT15 : Leaving PA_COST.override_exp_organization';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    -- dbms_output.put_line('end of override '||l_x_return_status ||' over id '||l_overr_to_organization_id);

    END IF;

    --    l_overr_to_organization_id := x_overr_to_organization_id;

    -- dbms_output.put_line('start of get burden cost '||l_x_return_status);

     l_expenditure_currency_code := NVL(l_expenditure_curr_code_burdn,l_expenditure_currency_code); /* Made for Org Forecasting */

    IF (NVL(l_exp_func_raw_cost,0) <> 0) THEN

    /* Added for Org forecasting */
   IF g1_debug_mode  = 'Y' THEN
    PA_DEBUG.g_err_stage := 'RT16 : Entering PA_COST.get_burdened_cost';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;

    PA_COST.get_burdened_cost(
            p_project_type                  => l_project_type                  ,
            p_project_id                    => p_project_id                    ,
            p_task_id                       => p_task_id                       ,
            p_item_date                     => p_rate_calc_date                ,
            p_expenditure_type              => l_expenditure_type              ,
            p_schedule_type                 => l_schedule_type                 ,
            px_exp_func_curr_code           => l_expenditure_currency_code   ,
            p_Incurred_by_organz_id         => l_expenditure_organization_id   ,
            p_raw_cost                      => l_new_pvdr_acct_raw_cost        ,
            p_raw_cost_rate                 => l_raw_cost_rate                 ,
            p_quantity                      => p_quantity                      ,
            p_override_to_organz_id         => l_overr_to_organization_id      ,
            x_burden_cost                   => l_exp_func_burdened_cost        , /* Changed for Org Forecasting */
            x_burden_cost_rate              => l_exp_func_burdened_cost_rate   , /* Changed for Org Forecasting */
            x_return_status                 => l_x_return_status               ,
            x_msg_count                     => x_msg_count                     ,
            x_msg_data                      => l_msg_data
            );


           x_exp_func_burdened_cost_rate := l_exp_func_burdened_cost_rate; /* Added for Org Forecasting */
           x_exp_func_burdened_cost      := l_exp_func_burdened_cost;      /* Added for Org Forecasting */
           x_exp_func_curr_code          := l_expenditure_currency_code;   /* Added for Org Forecasting */

   IF g1_debug_mode  = 'Y' THEN
    PA_DEBUG.g_err_stage := 'RT17 : Leaving PA_COST.get_burdened_cost';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;

     -- dbms_output.put_line('end of get burden cost '||l_x_return_status||' burden cost '||x_exp_func_burdened_cost||' rate '||x_exp_func_burdened_cost_rate);

   ELSIF (NVL(l_exp_func_raw_cost,0) = 0) THEN -- Added for bug 2347087
    l_msg_data := 'PA_FCST_NO_COST_RATE';
   END IF; /* Added for Org forecasting */

    -- Validating that the called procedure has run without error , if not,then not calling others
    IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (NVL(x_exp_func_burdened_cost,0) =  0) THEN

          /* Commented this for bug 2199203 and write the other one */
    	 /*  x_burdened_rejct_reason     := 'PA_FCST_NO_COST_RATE'; */
    	   x_burdened_rejct_reason       := SUBSTR(l_msg_data,1,30);
           x_exp_func_burdened_cost_rate := 0;
           x_exp_func_burdened_cost      := 0;
           x_exp_func_curr_code          := l_expenditure_currency_code; /* Added for Org Forecasting */

	   l_x_process_return_status := l_x_return_status;
       -- RAISE l_burdened_cost_null;

    END IF;

    l_new_pvdr_acct_burdened_cost        := l_exp_func_burdened_cost; /* Changed for Org Forecasting */
    l_burdened_cost_rate                 := l_exp_func_burdened_cost_rate; /* Changed for Org Forecasting */

     -- dbms_output.put_line('start of Get_Converted_Cost_Amounts '||l_x_return_status);

  IF g1_debug_mode  = 'Y' THEN
    PA_DEBUG.g_err_stage := 'RT18 : Entering PA_COST.get_proj_raw_burdened_cost';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  END IF;

-- dbms_output.put_line(' error in multi cost 2 '||x_cost_rejct_reason||' amount '||l_exp_func_raw_cost);

-- dbms_output.put_line('l_exp_func_raw_cost ' ||l_exp_func_raw_cost);
/* Added for Org Forecasting */
    IF (NVL(l_exp_func_raw_cost,0) <> 0) THEN
-- dbms_output.put_line(' inside l_exp_func_raw_cost ' ||l_exp_func_raw_cost);
    PA_COST.Get_Converted_Cost_Amounts(
              P_exp_org_id                   =>  l_expenditure_org_id,
              P_proj_org_id                  =>  l_project_org_id,
              P_project_id                   =>  p_project_id,
              P_task_id                      =>  p_task_id,
              P_item_date                    =>  p_rate_calc_date,
              p_system_linkage               =>  p_system_linkage,
              px_txn_curr_code               =>  l_cst_txn_curr_code,
              px_raw_cost                    =>  l_new_pvdr_acct_raw_cost,
              px_raw_cost_rate               =>  l_raw_cost_rate,
              px_burden_cost                 =>  l_new_pvdr_acct_burdened_cost,
              px_burden_cost_rate            =>  l_burdened_cost_rate,
              px_exp_func_curr_code          =>  l_expenditure_currency_code,
              px_exp_func_rate_date          =>  l_exp_func_cst_rt_date,
              px_exp_func_rate_type          =>  l_exp_func_cst_rt_type,
              px_exp_func_exch_rate          =>  l_exp_func_cst_exch_rt,
              px_exp_func_cost               =>  l_exp_func_raw_cost,
              px_exp_func_cost_rate          =>  l_exp_func_raw_cost_rate,
              px_exp_func_burden_cost        =>  l_exp_func_burdened_cost,
              px_exp_func_burden_cost_rate   =>  l_exp_func_burdened_cost_rate,
              px_proj_func_curr_code         =>  l_projfunc_currency_code,
              px_projfunc_cost_rate_date     =>  l_projfunc_cost_rate_date,
              px_projfunc_cost_rate_type     =>  l_projfunc_cost_rate_type,
              px_projfunc_cost_exch_rate     =>  l_projfunc_cost_exchange_rate,
              px_projfunc_raw_cost           =>  l_projfunc_raw_cost ,
              px_projfunc_raw_cost_rate      =>  l_projfunc_raw_cost_rate ,
              px_projfunc_burden_cost        =>  l_projfunc_burdened_cost ,
              px_projfunc_burden_cost_rate   =>  l_projfunc_burdened_cost_rate ,
              px_project_curr_code           =>  l_project_currency_code,
              px_project_rate_date           =>  l_project_cost_rate_date,
              px_project_rate_type           =>  l_project_cost_rate_type,
              px_project_exch_rate           =>  l_project_cost_exchange_rate,
              px_project_cost                =>  l_project_raw_cost,
              px_project_cost_rate           =>  l_project_raw_cost_rate,
              px_project_burden_cost         =>  l_project_burdened_cost,
              px_project_burden_cost_rate    =>  l_project_burdened_cost_rate,
              x_return_status                =>  l_x_return_status  ,
              x_msg_count                    =>  x_msg_count    ,
              x_msg_data                     =>  l_msg_data
              );

          x_projfunc_raw_cost       :=  l_projfunc_raw_cost;
          x_projfunc_raw_cost_rate  :=  l_projfunc_raw_cost_rate;
          x_projfunc_burdened_cost  :=  l_projfunc_burdened_cost;
          x_projfunc_burdened_cost_rate  := l_projfunc_burdened_cost_rate;
          x_projfunc_cst_rt_date         := l_projfunc_cost_rate_date;
          x_projfunc_cst_rt_type         := l_projfunc_cost_rate_type;
          x_projfunc_cst_exch_rt         := l_projfunc_cost_exchange_rate;

          x_project_raw_cst     := l_project_raw_cost;
          x_project_raw_cst_rt  := l_project_raw_cost_rate;
          x_project_burdned_cst := l_project_burdened_cost;
          x_project_burdned_cst_rt := l_project_burdened_cost_rate;
          x_project_cst_rt_date    := l_project_cost_rate_date;
          x_project_cst_rt_type    := l_project_cost_rate_type;
          x_project_cst_exch_rt    := l_project_cost_exchange_rate;

          x_exp_func_curr_code     := l_expenditure_currency_code;
          x_exp_func_raw_cost_rate := l_exp_func_raw_cost_rate;
          x_exp_func_raw_cost      := l_exp_func_raw_cost;
          x_exp_func_burdened_cost_rate  := l_exp_func_burdened_cost_rate;
          x_exp_func_burdened_cost       := l_exp_func_burdened_cost;
          x_exp_func_cst_rt_date         := l_exp_func_cst_rt_date;
          x_exp_func_cst_rt_type         := l_exp_func_cst_rt_type;
          x_exp_func_cst_exch_rt         := l_exp_func_cst_exch_rt;

          x_cst_txn_curr_code    := l_cst_txn_curr_code;
          x_txn_raw_cst_rt       := l_raw_cost_rate;
          x_txn_raw_cst          := l_new_pvdr_acct_raw_cost;
          x_txn_burdned_cst_rt   := l_burdened_cost_rate;
          x_txn_burdned_cst      := l_new_pvdr_acct_burdened_cost;

-- dbms_output.put_line(' Inside error in multi cost 3 '||x_cost_rejct_reason);
   /* Deleted this proc PA_COST.get_projfunc_raw_burdened_cost() for Org Forecasting */

  IF g1_debug_mode  = 'Y' THEN
    PA_DEBUG.g_err_stage := 'RT19 : Leaving PA_COST.get_proj_raw_burdened_cost';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  END IF;

     -- dbms_output.put_line('end of Get_Converted_Cost_Amounts '||l_x_return_status||' proj cost '||x_projfunc_raw_cost||' proj rate '||x_projfunc_raw_cost_rate
--   ||' proj bur co '||x_projfunc_burdened_cost||' proj bur rate '||x_projfunc_burdened_cost_rate||' PROJECT BURDEN COST '||x_project_burdned_cst);

     -- dbms_output.put_line('end of Get_Converted_Cost_Amounts exch rates '||l_x_return_status||' proj cost exch  '||l_project_cost_exchange_rate||' proj func exch rate '||l_projfunc_cost_exchange_rate ||' exp exch rate '||l_exp_func_cst_exch_rt);

 END IF; -- Added for Org Forecasting

    -- Validating that the called procedure has run without error , if not,then not calling others
    IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (NVL(l_projfunc_raw_cost,0) = 0 ) THEN

     -- dbms_output.put_line('inside if return status is error of Get_Converted_Cost_Amounts '||l_x_return_status||' proj cost '||x_projfunc_raw_cost
--  ||' proj rate '||x_projfunc_raw_cost_rate||' proj bur co '||x_projfunc_burdened_cost||' proj bur rate '||x_projfunc_burdened_cost_rate);

-- dbms_output.put_line(' CHECK error in multi co '||x_cost_rejct_reason);
         /* Commented this for bug 2199203 and write the other one */
	 /* x_cost_rejct_reason         := 'PA_FCST_NO_COST_RATE'; */
	  x_cost_rejct_reason           := SUBSTR(NVL(x_cost_rejct_reason,l_msg_data),1,30); -- Added for bug 2347087
          x_projfunc_raw_cost_rate      := 0;
          x_projfunc_raw_cost           := 0;
          x_projfunc_burdened_cost      := 0;
          x_projfunc_burdened_cost_rate := 0;

        --dbms_output.put_line(' The error is '||x_cost_rejct_reason);
          /* Added for Org Forecasting */
          x_projfunc_cst_rt_date         := l_projfunc_cost_rate_date;
          x_projfunc_cst_rt_type         := l_projfunc_cost_rate_type;
          x_projfunc_cst_exch_rt         := l_projfunc_cost_exchange_rate;

          x_project_raw_cst     := 0;
          x_project_raw_cst_rt  := 0;
          x_project_burdned_cst := 0;
          x_project_burdned_cst_rt := 0;

          x_project_cst_rt_date    := l_project_cost_rate_date;
          x_project_cst_rt_type    := l_project_cost_rate_type;
          x_project_cst_exch_rt    := l_project_cost_exchange_rate;

          x_exp_func_curr_code     := l_expenditure_currency_code;
          x_exp_func_raw_cost_rate := 0;
          x_exp_func_raw_cost      := 0;
          x_exp_func_burdened_cost_rate  := 0;
          x_exp_func_burdened_cost       := 0;

          x_exp_func_cst_rt_date         := l_exp_func_cst_rt_date;
          x_exp_func_cst_rt_type         := l_exp_func_cst_rt_type;
          x_exp_func_cst_exch_rt         := l_exp_func_cst_exch_rt;

          x_cst_txn_curr_code    := l_cst_txn_curr_code;
          x_txn_raw_cst_rt       := 0;
          x_txn_raw_cst          := 0;
          x_txn_burdned_cst_rt   := 0;
          x_txn_burdned_cst      := 0;

        l_x_process_return_status := l_x_return_status;

   --       RAISE l_raw_proj_cost_null;

    END IF;

-- dbms_output.put_line(' END Check error in multi cost 4 '||x_cost_rejct_reason);
    l_new_rcvr_acct_raw_cost           :=  x_projfunc_raw_cost;
    l_new_rcvr_acct_raw_cost_rate      :=  x_projfunc_raw_cost_rate;
    l_new_rcvr_acct_burdened_cost      :=  x_projfunc_burdened_cost;
    l_new_rcvr_acct_bur_cost_rate      :=  x_projfunc_burdened_cost_rate;


   END IF; /* End of p_amount_calc_mode } */

    --------------------------------------------------------------
    -- Calling Bill rate API to get the bill rate and raw Revenue.
    --------------------------------------------------------------

    l_Schedule_type := 'REVENUE';

     -- dbms_output.put_line('revenue start '||l_distribution_rule);

 IF (l_amount_calc_mode <> 'COST')  THEN /*  Added for Org For. { */

   IF ((SUBSTR(l_distribution_rule,1,4) = 'WORK') AND ( l_class_code = 'CONTRACT')
      AND (p_calling_mode <> 'UNASSIGNED') ) THEN /* Unasigned check added for Org { */

      l_msg_data := NULL;
      IF ( p_calling_mode = 'ASSIGNMENT') THEN

          -- dbms_output.put_line('start of get rev amt '||l_x_return_status);

     IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.g_err_stage := 'RT20 : Entering PA_REVENUE.get_rev_amt';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;

        PA_REVENUE.Assignment_Rev_Amt(
                   p_project_id                  => p_project_id                   ,
                   p_task_id                     => p_task_id                      ,
                   p_bill_rate_multiplier        => p_bill_rate_multiplier         ,
                   p_quantity                    => p_quantity                     ,
                   p_person_id                   => p_person_id                    ,
                   p_raw_cost                    => l_new_rcvr_acct_raw_cost       ,
                   p_item_date                   => p_rate_calc_date               ,
                   p_labor_schdl_discnt          => l_labor_schedule_discount      ,  -- can be null
                   p_labor_bill_rate_org_id      => l_labor_bill_rate_org_id       ,  -- can be null
                   p_labor_std_bill_rate_schdl   => l_labor_std_bill_rate_schedule ,  -- can be null
                   p_labor_schdl_fixed_date      => l_labor_schedule_fixed_date    ,  -- can be null
                   p_bill_job_grp_id             => l_project_bill_job_group_id    ,
                   p_item_id                     => p_item_id , /* changed for bug 2212852 */
                   p_forecast_item_id            => p_forecast_item_id , /* added for bug 2212852 */
                   p_forecasting_type            => p_forecasting_type , /* added for bug 2212852 */
                   p_labor_sch_type              => l_labor_schedule_type          ,
                   p_project_org_id              => l_project_org_id               ,
                   p_project_type                => l_project_type                 ,
                   p_expenditure_type            => l_expenditure_type             ,
                   p_exp_func_curr_code          => l_expenditure_currency_code    ,
                   p_incurred_by_organz_id       => l_expenditure_organization_id  ,
                   p_raw_cost_rate               => l_raw_cost_rate  ,
                   p_override_to_organz_id       => l_overr_to_organization_id     ,
                   p_emp_bill_rate_schedule_id   => l_emp_bill_rate_schedule_id    ,
                   p_resource_job_id             => l_forecast_job_id              ,
                   p_exp_raw_cost                => l_new_pvdr_acct_raw_cost       ,
                   p_expenditure_org_id          => l_expenditure_org_id           ,
                   p_projfunc_currency_code      => l_projfunc_currency_code       , -- The following 5
                   p_assignment_precedes_task    => l_assignment_precedes_task  , /* Added for Asgmt overide */
                   p_sys_linkage_function        => p_system_linkage, /* Added for Org FCST */
                   x_bill_rate                   => l_txn_rev_bill_rt , /*  Change for Org Forecsting */
                   x_raw_revenue                 => l_txn_rev_raw_revenue, /* Change for Org Forecasting */
                   x_markup_percentage           => l_markup_percentage ,/* Added for Asgmt overide */
                   x_txn_currency_code           => l_rev_txn_curr_code, /* added for Org */
                   x_rev_currency_code           => l_projfunc_currency_code ,
                   x_return_status               => l_x_return_status            ,
                   x_msg_count                   => x_msg_count                  ,
                   x_msg_data                    => l_msg_data                   ,
                    /* Added for bug 2668753 */
                   p_project_raw_cost            => l_project_raw_cost           ,
                   p_project_currency_code       => l_project_currency_code      ,
		   x_adjusted_bill_rate          => l_txn_adjusted_bill_rt  --added the parameter for 4038485
                   );

               x_txn_rev_bill_rt     := l_txn_rev_bill_rt;
               x_txn_rev_raw_revenue := l_txn_rev_raw_revenue;
               x_rev_txn_curr_code   := l_rev_txn_curr_code;

     IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.g_err_stage := 'RT21 : Leaving PA_REVENUE.get_rev_amt';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;
             -- dbms_output.put_line('end of get rev amt '||l_x_return_status|| ' rate '||x_projfunc_bill_rate||' rev '||x_projfunc_raw_revenue);
      ELSIF (p_calling_mode= 'ROLE' ) THEN

            -- dbms_output.put_line('start of req  rev amt '||l_x_return_status);

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT20 : Entering PA_REVENUE.requirement_rev_amt';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

           PA_REVENUE.Requirement_Rev_Amt(
                   p_project_id                  => p_project_id                   ,
                   p_task_id                     => p_task_id                      ,
                   p_bill_rate_multiplier        => p_bill_rate_multiplier         ,
                   p_quantity                    => p_quantity                     ,
                   p_raw_cost                    => l_new_rcvr_acct_raw_cost       ,
                   p_item_date                   => p_rate_calc_date               ,
                   p_project_bill_job_grp_id     => l_project_bill_job_group_id    ,
                   p_labor_schdl_discnt          => l_labor_schedule_discount      , -- can be null
                   p_labor_bill_rate_org_id      => l_labor_bill_rate_org_id       , -- can be null
                   p_labor_std_bill_rate_schdl   => l_labor_std_bill_rate_schedule , -- can be null
                   p_labor_schdl_fixed_date      => l_labor_schedule_fixed_date    , -- can be null
                   p_forecast_job_id             => l_forecast_job_id              ,
                   p_forecast_job_grp_id         => l_forecast_job_group_id        ,
                   p_labor_sch_type              => l_labor_schedule_type          , -- can be null
                   p_item_id                     => p_item_id , /* changed for bug 2212852 */
                   p_forecast_item_id            => p_forecast_item_id , /* added for bug 2212852 */
                   p_forecasting_type            => p_forecasting_type , /* added for bug 2212852 */
                   p_project_org_id              => l_project_org_id               ,
                   p_job_bill_rate_schedule_id   => l_job_bill_rate_schedule_id    ,
                   p_project_type                => l_project_type                 ,
                   p_expenditure_type            => l_expenditure_type             ,
                   px_exp_func_curr_code         => l_expenditure_currency_code    ,
                   p_incurred_by_organz_id       => l_expenditure_organization_id  ,
                   p_raw_cost_rate               => l_raw_cost_rate  ,
                   p_override_to_organz_id       => l_overr_to_organization_id     ,
                   p_exp_raw_cost                => l_new_pvdr_acct_raw_cost       ,
                   p_expenditure_org_id          => l_expenditure_org_id           ,
                   p_projfunc_currency_code      => l_projfunc_currency_code       , -- The following 5
                   p_assignment_precedes_task    => l_assignment_precedes_task  , /* Added for Asgmt overide */
                   p_sys_linkage_function        => p_system_linkage, /* Added for Org FCST */
                   px_project_bill_job_id        => l_proj_bill_job_id             ,
                   x_bill_rate                   => l_txn_rev_bill_rt , /*  Change for Org Forecsting */
                   x_raw_revenue                 => l_txn_rev_raw_revenue, /* Change for Org Forecasting */
                   x_markup_percentage           => l_markup_percentage ,/* Added for Asgmt overide */
                   x_txn_currency_code           => l_rev_txn_curr_code, /* added for Org */
                   x_return_status               => l_x_return_status              ,
                   x_msg_count                   => x_msg_count                    ,
                   x_msg_data                    => l_msg_data
                   );


               x_txn_rev_bill_rt     := l_txn_rev_bill_rt;
               x_txn_rev_raw_revenue := l_txn_rev_raw_revenue;
               x_rev_txn_curr_code   := l_rev_txn_curr_code;

         IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT21 : Leaving PA_REVENUE.requirement_rev_amt';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;

    -- dbms_output.put_line('end of req  rev amt '||l_x_return_status||' rate '||x_projfunc_bill_rate||' rev '||x_projfunc_raw_revenue);

      END IF;  /* End of calling mode if */


      -- Validating that the called procedure has run without error , if not,then not calling others
      IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (NVL(l_txn_rev_raw_revenue,0) = 0) THEN

          /* Commented this for bug 2199203 and write the other one */
          /* x_rev_rejct_reason          := 'PA_FCST_NO_BILL_RATE'; */
             x_rev_rejct_reason          := SUBSTR(l_msg_data,1,30);
             x_txn_rev_bill_rt           := 0;
             x_txn_rev_raw_revenue       := 0;
             x_rev_txn_curr_code         := l_rev_txn_curr_code;

           l_x_process_return_status := l_x_return_status;

      END IF; /* End of return status if */

     IF ( (NVL(l_txn_rev_raw_revenue,0) <> 0)  ) THEN

        PA_REVENUE.Get_Converted_Revenue_Amounts(
                   p_item_date                    => p_rate_calc_date,
                   px_txn_curr_code               => l_rev_txn_curr_code,
                   px_txn_raw_revenue             => l_txn_rev_raw_revenue,
                   px_txn_bill_rate               => l_txn_rev_bill_rt,
                   px_projfunc_curr_code          => l_projfunc_currency_code,
                   p_projfunc_bil_rate_date_code  => l_projfunc_bil_rate_date_code,
                   px_projfunc_bil_rate_type      => l_projfunc_bil_rate_type,
                   px_projfunc_bil_rate_date      => l_projfunc_bil_rate_date,
                   px_projfunc_bil_exchange_rate  => l_projfunc_bil_exchange_rate,
                   px_projfunc_raw_revenue        => l_projfunc_raw_revenue ,
                   px_projfunc_bill_rate          => l_projfunc_bill_rate ,
                   px_project_curr_code           => l_project_currency_code,
                   p_project_bil_rate_date_code   => l_project_bil_rate_date_code,
                   px_project_bil_rate_type       => l_project_bil_rate_type,
                   px_project_bil_rate_date       => l_project_bil_rate_date,
                   px_project_bil_exchange_rate   => l_project_bil_exchange_rate,
                   px_project_raw_revenue         => l_project_raw_revenue ,
                   px_project_bill_rate           => l_project_bill_rate ,
                   x_return_status                => l_x_return_status  ,
                   x_msg_count                    => x_msg_count    ,
                 /*  x_msg_data  => x_msg_data Commnted out for bug 3143819
                  and added modified one below i.e. instead of x_msg_data using
                  l_msg_data  */
                   x_msg_data                     => l_msg_data
                   );


          x_projfunc_bill_rate      := l_projfunc_bill_rate;
          x_projfunc_raw_revenue    := l_projfunc_raw_revenue;
          x_projfunc_rev_rt_date    := l_projfunc_bil_rate_date;
          x_projfunc_rev_rt_type    := l_projfunc_bil_rate_type;
          x_projfunc_rev_exch_rt    := l_projfunc_bil_exchange_rate;

          x_project_bill_rt     := l_project_bill_rate;
          x_project_raw_revenue := l_project_raw_revenue;
          x_project_rev_rt_date := l_project_bil_rate_date;
          x_project_rev_rt_type := l_project_bil_rate_type;
          x_project_rev_exch_rt := l_project_bil_exchange_rate;

          x_txn_rev_bill_rt           := l_txn_rev_bill_rt;
          x_txn_rev_raw_revenue       := l_txn_rev_raw_revenue;
          x_rev_txn_curr_code         := l_rev_txn_curr_code;
      -- dbms_output.put_line(' after revenue conversion ');
       END IF;

      -- Validating that the called procedure has run without error , if not,then not calling others
      IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (NVL(l_projfunc_raw_revenue,0) = 0) THEN

             x_rev_rejct_reason          := SUBSTR(l_msg_data,1,30);
             x_txn_rev_bill_rt           := 0;
             x_txn_rev_raw_revenue       := 0;
             x_rev_txn_curr_code         := l_rev_txn_curr_code;

             x_projfunc_bill_rate      := 0;
             x_projfunc_raw_revenue    := 0;
             x_projfunc_rev_rt_date    := l_projfunc_bil_rate_date;
             x_projfunc_rev_rt_type    := l_projfunc_bil_rate_type;
             x_projfunc_rev_exch_rt    := l_projfunc_bil_exchange_rate;

             x_project_bill_rt     := 0;
             x_project_raw_revenue := 0;
             x_project_rev_rt_date := l_project_bil_rate_date;
             x_project_rev_rt_type := l_project_bil_rate_type;
             x_project_rev_exch_rt := l_project_bil_exchange_rate;

             l_x_process_return_status := l_x_return_status;

      END IF; /* End of return status if */

   END IF;   /* End of rule and class code if } */
 END IF;  /* p_amount_calc_mode if } */

    l_new_rcvr_revenue      := x_projfunc_raw_revenue;

    -------------------------------------------------------
    -- Assign the successful status back to output variable
    -------------------------------------------------------

    x_return_status := l_x_process_return_status;
    x_msg_data := l_msg_data;

-- dbms_output.put_line(' End error in multi cost  '||x_cost_rejct_reason);
     -- dbms_output.put_line('end of procs '||l_x_return_status);
	 IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT22 : Leaving PA_RATE_PVT_PKG.get_item_amount';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           PA_DEBUG.Reset_Curr_Function;
         END IF;


  EXCEPTION
     WHEN l_insufficient_parameters THEN
	 IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
         END IF;
    	x_return_status           :=  FND_API.G_RET_STS_ERROR;
        x_msg_count               := 1;
        x_msg_data                := 'PA_FCST_INSUFFICIENT_PARA';
       x_others_rejct_reason      := 'PA_FCST_INSUFFICIENT_PARA';

     WHEN l_raw_cost_null THEN
	 IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
         END IF;
          x_return_status           :=  FND_API.G_RET_STS_ERROR;
          x_cost_rejct_reason       := 'PA_FCST_NO_COST_RATE';
          x_exp_func_raw_cost_rate  := 0;
          x_exp_func_raw_cost       := 0;
     WHEN l_raw_proj_cost_null THEN
	 IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
          END IF;
          x_return_status           :=  FND_API.G_RET_STS_ERROR;
          x_cost_rejct_reason       := 'PA_FCST_NO_COST_RATE';
          /* Added for Org Forecasting */
          x_projfunc_raw_cost_rate      := 0;
          x_projfunc_raw_cost           := 0;
          x_projfunc_burdened_cost      := 0;
          x_projfunc_burdened_cost_rate := 0;

          x_project_raw_cst     := 0;
          x_project_raw_cst_rt  := 0;
          x_project_burdned_cst := 0;
          x_project_burdned_cst_rt := 0;

          x_exp_func_raw_cost_rate := 0;
          x_exp_func_raw_cost      := 0;
          x_exp_func_burdened_cost_rate  := 0;
          x_exp_func_burdened_cost       := 0;

          x_txn_raw_cst_rt       := 0;
          x_txn_raw_cst          := 0;
          x_txn_burdned_cst_rt   := 0;
          x_txn_burdned_cst      := 0;

          --dbms_output.put_line('exp2');
     WHEN l_raw_revenue_null THEN
	 IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
          END IF;
           x_return_status           :=  FND_API.G_RET_STS_ERROR;
           x_rev_rejct_reason        := 'PA_FCST_NO_BILL_RATE';
           x_txn_rev_bill_rt         := 0;
           x_txn_rev_raw_revenue     := 0;

           --dbms_output.put_line('exp3');

     WHEN l_burdened_cost_null THEN
	 IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
         END IF;
           x_return_status               :=  FND_API.G_RET_STS_ERROR;
           x_burdened_rejct_reason       := 'PA_FCST_NO_COST_RATE';
           x_exp_func_burdened_cost_rate := 0;
           x_exp_func_burdened_cost      := 0;

           --dbms_output.put_line('exp4');

     WHEN OTHERS THEN
	 IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
         END IF;

          --dbms_output.put_line('exp5'||SQLERRM);

         /* ATG Changes */

        x_projfunc_bill_rate           := null;
        x_projfunc_raw_revenue         := null;
        x_projfunc_rev_rt_date         := null;
        x_projfunc_rev_rt_type         := null;
        x_projfunc_rev_exch_rt         := null;
        x_projfunc_raw_cost            := null;
        x_projfunc_raw_cost_rate       := null;
        x_projfunc_burdened_cost       := null;
        x_projfunc_burdened_cost_rate  := null;
        x_projfunc_cst_rt_date         := null;
        x_projfunc_cst_rt_type         := null;
        x_projfunc_cst_exch_rt         := null;
        x_project_bill_rt              := null;
        x_project_raw_revenue          := null;
        x_project_rev_rt_date          := null;
        x_project_rev_rt_type          := null;
        x_project_rev_exch_rt          := null;
        x_project_raw_cst              := null;
        x_project_raw_cst_rt           := null;
        x_project_burdned_cst          := null;
        x_project_burdned_cst_rt       := null;
        x_project_cst_rt_date          := null;
        x_project_cst_rt_type          := null;
        x_project_cst_exch_rt          := null;
        x_exp_func_curr_code           := null;
        x_exp_func_raw_cost_rate       := null;
        x_exp_func_raw_cost            := null;
        x_exp_func_burdened_cost_rate  := null;
        x_exp_func_burdened_cost       := null;
        x_exp_func_cst_rt_date         := null;
        x_exp_func_cst_rt_type         := null;
        x_exp_func_cst_exch_rt         := null;
        x_cst_txn_curr_code            := null;
        x_txn_raw_cst_rt               := null;
        x_txn_raw_cst                  := null;
        x_txn_burdned_cst_rt           := null;
        x_txn_burdned_cst              := null;
        x_rev_txn_curr_code            := null;
        x_txn_rev_bill_rt              := null;
        x_txn_rev_raw_revenue          := null;



          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_error_msg     := SUBSTR(SQLERRM,1,30);
      /* Checking error condition. Added for bug 2218386 */
      IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
          FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_RATE_PVT_PKG',
                                   p_procedure_name => 'Get_Item_Amount');
          RAISE;
      END IF;
  END Get_Item_Amount;


-- This procedure will calculate the revenue for fixed price in event based rule on basis of passed parameters
-- Input parameters
-- Parameters                   Type           Required      Description
-- P_project_id                 NUMBER          YES          Project Id
-- Out parameters
--
-- x_proj_revenue_tab           ProjAmt_TabTyp  YES          It store the amount and period name
--                                                           for fixed price project

PROCEDURE calc_event_based_revenue(
                                p_project_id                    IN     NUMBER ,
                                p_rev_amt                       IN     NUMBER,
                                p_completion_date               IN     DATE,
                                p_project_currency_code         IN     VARCHAR2,   -- The following 6
                                p_projfunc_currency_code        IN     VARCHAR2,
                                p_projfunc_bil_rate_date_code   IN     VARCHAR2,   -- columns have been
                                px_projfunc_bil_rate_type       IN OUT NOCOPY VARCHAR2,   -- added for MCB2 --File.Sql.39 bug 4440895
                                px_projfunc_bil_rate_date       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                px_projfunc_bil_exchange_rate   IN OUT NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                                x_error_code                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_projfunc_revenue_tab          OUT    NOCOPY PA_RATE_PVT_PKG.ProjAmt_TabTyp /* This tabwill store aount in project functional currency */) --File.Sql.39 bug 4440895
IS

   l_completion_date           pa_projects_all.completion_date%TYPE;
   l_period_type               pa_rep_period_dates_v.period_type%TYPE;
   l_period_name               pa_rep_period_dates_v.period_name%TYPE;
   l_start_date                pa_rep_period_dates_v.start_date%TYPE;
   l_end_date                  pa_rep_period_dates_v.end_date%TYPE;

   /* Added for MCB2 */
   l_converted_rev_amount      pa_projects_all.project_value%TYPE;
   l_conversion_fail           EXCEPTION;
   l_denominator               Number;
   l_numerator                 Number;
   l_status                     Varchar2(30);

   l_period_year               NUMBER; /* Added for bug 2691192 */
   l_error_value               VARCHAR2(50); /* Added for bug 2691192 */


     lx_projfunc_bil_rate_type       VARCHAR2(30);
     lx_projfunc_bil_rate_date       DATE;
     lx_projfunc_bil_exchange_rate   NUMBER;


BEGIN

   /* ATG Changes */

     lx_projfunc_bil_rate_type      := px_projfunc_bil_rate_type;
     lx_projfunc_bil_rate_date      := px_projfunc_bil_rate_date ;
     lx_projfunc_bil_exchange_rate  := px_projfunc_bil_exchange_rate ;



   /* Validating the project end date and project value if the project does not have
      end date the taking the max end date of the assignment schedule which belongs to
      this project */


   IF (p_completion_date IS NULL) THEN  /* Bug fix 1842755 */
     BEGIN
        SELECT MAX(end_date)
        INTO l_completion_date
        FROM pa_schedules
        WHERE project_id = p_project_id
        AND DECODE (schedule_type_code, 'OPEN_ASSIGNMENT',
                pa_assignment_utils.Is_Asgmt_In_Open_Status(status_code,'OPEN_ASGMT'),
                'STAFFED_ASSIGNMENT',DECODE(
                pa_assignment_utils.Is_Staffed_Asgmt_Cancelled(status_code,'STAFFED_ASGMT'),'Y','N','Y'),'N') = 'Y'
        AND DECODE(schedule_type_code,
                'OPEN_ASSIGNMENT', pa_project_utils.check_prj_stus_action_allowed(
                                   status_code, 'OPEN_ASGMT_PROJ_FORECASTING'),
                'STAFFED_ASSIGNMENT', pa_project_utils.check_prj_stus_action_allowed(
                                   status_code, 'STAFFED_ASGMT_PROJ_FORECASTING'),
                'STAFFED_ADMIN_ASSIGNMENT', pa_project_utils.check_prj_stus_action_allowed(
                                   status_code, 'STAFFED_ASGMT_PROJ_FORECASTING'),'N') = 'Y';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          x_error_code := 'PA_FCST_PDS_NOT_DEFINED';
          NULL;
     END;
   ELSE
     l_completion_date := p_completion_date;
   END IF;

-- dbms_output.put_line(' 11');
   -- Populating period type for forecasting it can be GL or PA using profile options
   l_period_type := FND_PROFILE.VALUE('PA_FORECASTING_PERIOD_TYPE');

-- dbms_output.put_line(' 12 '||l_period_type);

   /* Added code for bug 2691192, this proc. will replace the call of
     pa_rep_period_dates_v.Because of performance issue tis view has been split
     in this new call of proc. */

PA_RATE_PVT_PKG.get_rep_period_dates (
                                  p_period_type                  =>  l_period_type,
                                  p_completion_date              =>  l_completion_date,
                                  x_period_year                  =>  l_period_year,
                                  x_period_name                  =>  l_period_name,
                                  x_start_date                   =>  l_start_date,
                                  x_end_date                     =>  l_end_date,
                                  x_error_value                  =>  l_error_value
                                 );
-- dbms_output.put_line(' 13 '||l_error_value);

   IF ( l_error_value = 'NO_ERROR') THEN
     -- Do not raise error
        NULL;
   ELSIF ( l_error_value = 'NO_DATA_FOUND' ) THEN
        RAISE  NO_DATA_FOUND;
   ELSIF (l_error_value = 'TOO_MANY_ROWS') THEN
       RAISE TOO_MANY_ROWS;
   END IF;

  /* Fix for bug 2691192 till here */

   /* Taking period name corresponds to the period type */
   /* Commneting out for bug 2691192
   SELECT period_name,start_date,end_date
   INTO l_period_name,l_start_date,l_end_date
   FROM pa_rep_period_dates_v
   WHERE period_type = l_period_type
   AND l_completion_date BETWEEN start_date AND end_date;
 */

/* Commented the below condition for bug 2193832, because even if the
     start date of the period is in one particular year, the period year could be previous on or
     depending upon how the ct has setup e.g. start date 01-jan-2001, but period year will be 2000

   AND  TO_CHAR(l_completion_date,'YYYY') = period_year; */



  -- NOTE The following conversion is not going to be used in this dev drop
  --      because project value will be in PFC

   /* Converting the amount into project functional currency for MCB2
  IF (p_project_currency_code <> p_projfunc_currency_code ) THEN
             PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => p_project_currency_code,
                            P_TO_CURRENCY            => p_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_completion_date,
                            P_CONVERSION_TYPE        => px_projfunc_bil_rate_type,
                            P_AMOUNT                 => p_rev_amt,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_rev_amount,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => px_projfunc_bil_exchange_rate,
                            X_STATUS                 => l_status);

                           IF (l_status IS NOT NULL) THEN
                             RAISE l_conversion_fail;
                           END IF;

   x_projfunc_revenue_tab(1).amount         := l_converted_rev_amount;

    END IF; */

   x_projfunc_revenue_tab(1).amount         := p_rev_amt;
   x_projfunc_revenue_tab(1).period_name    := l_period_name;
   x_projfunc_revenue_tab(1).start_date     := l_start_date;
   x_projfunc_revenue_tab(1).end_date       := l_end_date;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
    x_error_code := 'PA_FCST_PDS_NOT_DEFINED';
    NULL;
   WHEN l_conversion_fail THEN
    x_error_code := l_status||'_BC_PF';
   WHEN OTHERS THEN

   /* ATG Changes */

     px_projfunc_bil_rate_type      := lx_projfunc_bil_rate_type;
     px_projfunc_bil_rate_date      := lx_projfunc_bil_rate_date ;
     px_projfunc_bil_exchange_rate  := lx_projfunc_bil_exchange_rate ;

      /* Checking error condition. Added for bug 2218386 */
      IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_RATE_PVT_PKG',
                                  p_procedure_name => 'calc_event_based_revenue');
         RAISE;
      END IF;

END calc_event_based_revenue;


-- This procedure will calculate the revenue for fixed price in cost based rule on basis of passed parameters
-- Input parameters
-- Parameters                   Type           Required      Description
-- P_project_id                 NUMBER          YES          Project Id
-- p_rev_amt                    NUMBER          YES          Revenue amount for project
-- p_proj_cost_tab              ProjAmt_TabTyp  YES          It contains the amount and period name
--                                                           for fixed price project
-- Out parameters
--
-- x_proj_revenue_tab           ProjAmt_TabTyp  YES          It stores the amount and period name
--                                                           for fixed price project

PROCEDURE calc_cost_based_revenue(
                                p_project_id                    IN     NUMBER ,
                                p_rev_amt                       IN     NUMBER ,
                                p_projfunc_cost_tab             IN     PA_RATE_PVT_PKG.ProjAmt_TabTyp,
                                p_project_currency_code         IN     VARCHAR2,   -- The following 6
                                p_projfunc_currency_code        IN     VARCHAR2,
                                p_projfunc_bil_rate_date_code   IN     VARCHAR2,   -- columns have been
                                px_projfunc_bil_rate_type       IN OUT NOCOPY VARCHAR2,   -- added for MCB2 --File.Sql.39 bug 4440895
                                px_projfunc_bil_rate_date       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                px_projfunc_bil_exchange_rate   IN OUT NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                                x_projfunc_revenue_tab          OUT    NOCOPY PA_RATE_PVT_PKG.ProjAmt_TabTyp, --File.Sql.39 bug 4440895
                                x_error_code                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                )
IS

  l_proj_rev            NUMBER;
  l_period_rev          NUMBER;
  l_tot_period_rev      NUMBER;
  l_last_num            NUMBER;
  l_proj_cost           NUMBER;
  l_running_cost	NUMBER:=0;

  /* Added for MCB2 */
  l_converted_rev_amount      pa_projects_all.project_value%TYPE;
  l_conversion_fail           EXCEPTION;
  l_denominator               Number;
  l_numerator                 Number;
  l_status                    Varchar2(30);
  l_conversion_date           DATE;

    lx_projfunc_bil_rate_type       VARCHAR2(30);
     lx_projfunc_bil_rate_date       DATE;
     lx_projfunc_bil_exchange_rate   NUMBER;


BEGIN

   /* ATG Changes */

     lx_projfunc_bil_rate_type      := px_projfunc_bil_rate_type;
     lx_projfunc_bil_rate_date      := px_projfunc_bil_rate_date ;
     lx_projfunc_bil_exchange_rate  := px_projfunc_bil_exchange_rate ;


   /* Checking that the passed table of records should have some value */
   IF (p_projfunc_cost_tab.count <> 0 ) THEN

      l_proj_rev   := NVL(p_rev_amt,0);
      l_proj_cost  := 0;

  -- NOTE The following conversion is not going to be used in this dev drop
  --      because project value will be in PFC
   /* Converting the amount into project functional currency for MCB2
  IF ( p_project_currency_code <> p_projfunc_currency_code ) THEN
      l_conversion_date  := p_projfunc_cost_tab(1).start_date;
             PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => p_project_currency_code,
                            P_TO_CURRENCY            => p_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conversion_date,
                            P_CONVERSION_TYPE        => px_projfunc_bil_rate_type,
                            P_AMOUNT                 => p_rev_amt,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_rev_amount,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => px_projfunc_bil_exchange_rate,
                            X_STATUS                 => l_status);

                           IF (l_status IS NOT NULL) THEN
                             RAISE l_conversion_fail;
                           END IF;
      l_proj_rev   := NVL(l_converted_rev_amount,0);
      l_proj_cost  := 0;
     END IF;  */

      -- Taking the total cost for the project by summing up all the amount for all periods
      --  l_last_num         := p_proj_cost_tab.last;
      FOR j IN p_projfunc_cost_tab.first..p_projfunc_cost_tab.last  LOOP
          l_proj_cost        := l_proj_cost + NVL(p_projfunc_cost_tab(j).amount,0);
      END LOOP;

      -- Initializing the local variable
      l_period_rev      := 0;
      l_tot_period_rev  := 0;

      /* Calculating the revenue period wise */
      IF l_proj_cost <> 0 THEN
         FOR i IN p_projfunc_cost_tab.first..p_projfunc_cost_tab.last  LOOP
            IF (  I = p_projfunc_cost_tab.last ) THEN
               l_period_rev  := NVL(l_proj_rev,0) - NVL(l_tot_period_rev,0);
               x_projfunc_revenue_tab(i).amount         := NVL(l_period_rev,0);
               x_projfunc_revenue_tab(i).period_name    := p_projfunc_cost_tab(i).period_name;
            ELSE
	       l_running_cost  := NVL(l_running_cost,0) + NVL(p_projfunc_cost_tab(i).amount,0);
               l_period_rev := ((NVL(l_running_cost,0)/ NVL(l_proj_cost,0)) * NVL(l_proj_rev,0)) -NVL(l_tot_period_rev,0);
               x_projfunc_revenue_tab(i).amount := l_period_rev;
               x_projfunc_revenue_tab(i).period_name := p_projfunc_cost_tab(i).period_name;
               l_tot_period_rev   := l_tot_period_rev + l_period_rev ;
            END IF;
         END LOOP;
      END IF; /* Closing if for l_proj_cost <> */
   END IF;  /* Closing if for p_proj_cost_tab validation */
 EXCEPTION
   WHEN l_conversion_fail THEN
    x_error_code := l_status||'_BC_PF';
    NULL;
   WHEN OTHERS THEN
   /* ATG Changes */

     px_projfunc_bil_rate_type      := lx_projfunc_bil_rate_type;
     px_projfunc_bil_rate_date      := lx_projfunc_bil_rate_date ;
     px_projfunc_bil_exchange_rate  := lx_projfunc_bil_exchange_rate ;

   /* Checking error condition. Added for bug 2218386 */
   IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
     FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_RATE_PVT_PKG',
                              p_procedure_name => 'calc_cost_based_revenue');
    RAISE;
  END IF;

 END calc_cost_based_revenue;


-- This procedure will return that whta type of the project is this on the basis of passed parameters
-- Input parameters
-- Parameters                   Type           Required      Description
-- P_project_id                 NUMBER          NO           Project Id
-- p_distribution_rule          NUMBER          NO           distribution  rule
-- Out parameters
--

PROCEDURE get_revenue_generation_method( p_project_id IN NUMBER DEFAULT NULL,
	                                p_distribution_rule IN VARCHAR2 DEFAULT NULL,
                                        x_rev_gen_method    OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                                        x_error_msg         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_rule            pa_projects_all.distribution_rule%TYPE;  -- Used to store the distribution rule for
                                                             -- further result e.g if rule starts with work
                                                             -- then project is T and M else Fixed price
  l_proj_typ        VARCHAR2(1);                             -- Used to store type of the project for return
                                                             -- statement i.e. if 'T' - 'T and M' ,'C' - 'Cost based'
                                                             -- and if 'E' - ' Event based'

 l_class_code        pa_project_types_all.project_type_class_code%TYPE;
 l_no_rule           EXCEPTION;

 BEGIN

    /*
       IF( p_distribution_rule IS NULL) THEN
       ELSE
       END IF   ;
       l_rule := p_distribution_rule;
    */
   /* Selecting distribution rule for checking wheather the project is Fixed Price or T and M */
     BEGIN
        SELECT proj.distribution_rule,typ.project_type_class_code
        INTO   l_rule,l_class_code
        FROM pa_project_types_all typ, pa_projects_all proj
        WHERE   proj.project_id   = p_project_id
        AND     proj.project_type = typ.project_type
        AND     proj.org_id       = typ.org_id;        -- bug 7413961 skkoppul : removed NVL function

        IF ( l_class_code = 'CONTRACT') THEN
          IF ( l_rule IS NULL ) THEN
            RAISE l_no_rule;
          END IF;
        END IF;
     END;

   --DBMS_OUTPUT.PUT_LINE('2');
   /* Checking wheather the project type is T and M  or Cost based or Event based */
 IF ( l_class_code = 'CONTRACT') THEN
   IF (l_rule  IS NOT NULL ) THEN
     IF ( l_rule = 'WORK/WORK') OR ( l_rule = 'WORK/EVENT') THEN
        x_rev_gen_method  := 'T';
     ELSIF (l_rule = 'COST/COST') OR ( l_rule = 'COST/EVENT')OR (l_rule = 'COST/WORK') THEN
          x_rev_gen_method  := 'C';
     ELSIF (l_rule = 'EVENT/EVENT') OR  (l_rule = 'EVENT/WORK') THEN
          x_rev_gen_method  := 'E';
     END IF;
   END IF;
 ELSE
  x_rev_gen_method := 'N';
 END IF;
 EXCEPTION
   WHEN l_no_rule   THEN
   x_rev_gen_method   := 'N';
   x_error_msg  := 'PA_FCST_DIST_RULE_NOT_FOUND';
   WHEN OTHERS THEN

    /* ATG Changes */
    x_rev_gen_method := null;


   /* Checking error condition. Added for bug 2218386 */
   IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
     FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_RATE_PVT_PKG',
                              p_procedure_name => 'get_revenue_generation_method');
    RAISE;
  END IF;

 END get_revenue_generation_method;



-- This procedure will calculate the initial bill rate for Assignment and Requirement
-- Input parameters
-- Parameters                     Type           Required      Description
-- p_assignment_type              VARCHAR2        YES          Type of assignment like REQUIREMENT(R)/ASSIGNMENT(A)
-- p_asgn_start_date              DATE            YES          Rate calculation date
-- P_assignment_id                NUMBER          YES          Unique identifier
-- P_project_id                   NUMBER          YES          Project Id
-- P_quantity                     NUMBER          YES          Quantity in Hours
-- P_forecast_job_id              NUMBER          NO           Forecast job Id at assignment level
-- P_forecast_job_group_id        NUMBER          NO           Forecast job group id at assignment level
-- p_person_id                    NUMBER          NO           Person id
-- p_expenditure_org_id           NUMBER          NO           Expenditure org id
-- P_expenditure_type             VARCHAR2        NO           Expenditure Type
-- p_expenditure_organization_id  NUMBER          NO           Expenditure organization id
-- p_project_org_id               NUMBER          NO           Project  org id
-- p_expenditure_currency_code    VARCHAR2        NO           Expenditure functional currency code
-- P_project_type                 VARCHAR2        NO           Project Type
-- P_task_id                      NUMBER          NO           Task Id  for the given project
-- p_projfunc_currency_code       VARCHAR2        NO           Project Functional currency code
-- P_bill_rate_multiplier         NUMBER          NO           Bill rate multiplier for calculating the revenue
-- P_project_bill_job_group_id    NUMBER          NO           Billing job group id for project
-- p_emp_bill_rate_schedule_id    NUMBER          NO           Employee bill rate schedule id
-- P_job_bill_rate_schedule_id    NUMBER          NO           Job bill rate schedule id
--                                                             and rate
--
-- Out parameters
--
-- x_projfunc_bill_rate               NUMBER          YES          Bill rate in project currency
-- x_projfunc_raw_revenue             NUMBER          YES          Raw revenue in project currency
-- x_rev_currency_code             VARCHAR2        YES          Revenue  currency code

PROCEDURE get_initial_bill_rate(
     p_assignment_type               IN     VARCHAR2   ,
     p_asgn_start_date               IN     DATE   ,
     p_project_id                    IN     NUMBER ,
     p_quantity                      IN     NUMBER ,
     p_expenditure_org_id            IN     NUMBER   ,
     p_expenditure_type              IN     VARCHAR2 ,
     p_expenditure_organization_id   IN     NUMBER   ,
     p_person_id                     IN     NUMBER   DEFAULT NULL,
     p_assignment_id                 IN     NUMBER   DEFAULT NULL,
     p_forecast_job_id               IN     NUMBER   DEFAULT NULL,
     p_forecast_job_group_id         IN     NUMBER   DEFAULT NULL,
     p_project_org_id                IN     NUMBER   DEFAULT NULL,
     p_expenditure_currency_code     IN     VARCHAR2 DEFAULT NULL,
     p_project_type                  IN     VARCHAR2 DEFAULT NULL,
     p_task_id                       IN     NUMBER   DEFAULT NULL,
     p_bill_rate_multiplier          IN     NUMBER   DEFAULT NULL,
     p_project_bill_job_group_id     IN     NUMBER   DEFAULT NULL,
     p_emp_bill_rate_schedule_id     IN     NUMBER   DEFAULT NULL,
     p_job_bill_rate_schedule_id     IN     NUMBER   DEFAULT NULL,
     p_job_cost_rate_schedule_id     IN     NUMBER   DEFAULT NULL,
     p_proj_cost_job_group_id        IN     NUMBER   DEFAULT NULL,
     p_calculate_cost_flag           IN     VARCHAR2 DEFAULT 'Y', /* Added to fix bug 2162965  */
     p_forecast_item_id              IN     NUMBER   DEFAULT NULL, /* Added para for bug 2212852 */
     p_forecasting_type              IN     VARCHAR2 DEFAULT 'PROJECT_FORECASTING', /* added para for bug 2212852 */
     p_assign_precedes_task          IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
     p_system_linkage                IN     pa_expenditure_items_all.system_linkage_function%TYPE DEFAULT NULL,/* Added */
                                                                         /* for Org Forecasting */
     p_labor_schdl_discnt            IN     NUMBER   DEFAULT NULL, /* Added for Org Forecasting */
     p_labor_bill_rate_org_id        IN     NUMBER   DEFAULT NULL, /* Added for Org Forecasting */
     p_labor_std_bill_rate_schdl     IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
     p_labor_schedule_fixed_date     IN     DATE     DEFAULT NULL, /* Added for Org Forecasting */
     p_labor_sch_type                IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
     p_projfunc_currency_code        IN     VARCHAR2 DEFAULT NULL,
     p_projfunc_rev_rt_dt_code       IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
     p_projfunc_rev_rt_date          IN     DATE     DEFAULT NULL, /* Added for Org Forecasting */
     p_projfunc_rev_rt_type          IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
     p_projfunc_rev_exch_rt          IN     NUMBER   DEFAULT NULL, /* Added for Org Forecasting */
     p_projfunc_cst_rt_date          IN     DATE     DEFAULT NULL, /* Added for Org Forecasting */
     p_projfunc_cst_rt_type          IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
     p_project_currency_code         IN     VARCHAR2 DEFAULT NULL, /* Added for org Forecasting */
     p_project_rev_rt_dt_code        IN     VARCHAR2 DEFAULT NULL, /* Added for org Forecasting */
     p_project_rev_rt_date           IN     DATE     DEFAULT NULL, /* Added for org Forecasting */
     p_project_rev_rt_type           IN     VARCHAR2 DEFAULT NULL, /* Added for org Forecasting */
     p_project_rev_exch_rt           IN     NUMBER   DEFAULT NULL, /* Added for org Forecasting */
     p_project_cst_rt_date           IN     DATE     DEFAULT NULL, /* Added for org Forecasting */
     p_project_cst_rt_type           IN     VARCHAR2 DEFAULT NULL, /* Added for org Forecasting */
     x_projfunc_bill_rate            OUT    NOCOPY NUMBER /* Changed for MCb2 */, --File.Sql.39 bug 4440895
     x_projfunc_raw_revenue          OUT    NOCOPY NUMBER /* Changed for MCb2 */, --File.Sql.39 bug 4440895
     x_rev_currency_code             OUT    NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
     x_markup_percentage             OUT    NOCOPY NUMBER  /* Added for Assignment Override */, --File.Sql.39 bug 4440895
     x_return_status                 OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                     OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                      OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

  l_insufficient_parameters               EXCEPTION;
  l_job_not_found                         EXCEPTION;
  l_no_rule                               EXCEPTION;

  l_calculate_cost_flag                   VARCHAR2(1); /* Added to fix bug 2162965 */

  l_forecast_job_id                       pa_project_assignments.fcst_job_id%TYPE;
  l_forecast_job_group_id                 pa_project_assignments.fcst_job_group_id%TYPE;

  l_labor_cost_mult_name                  pa_tasks.labor_cost_multiplier_name%TYPE;



  l_project_type                          pa_project_types_all.project_type%TYPE;
  l_proj_cost_job_grp_id                  pa_std_bill_rate_schedules_all.job_group_id%TYPE;

  l_project_org_id                        pa_projects_all.org_id%TYPE;
  l_project_bill_job_group_id             pa_projects_all.bill_job_group_id%TYPE;
  l_emp_bill_rate_schedule_id             pa_projects_all.emp_bill_rate_schedule_id%TYPE;
  l_job_bill_rate_schedule_id             pa_projects_all.job_bill_rate_schedule_id%TYPE;


  l_labor_schedule_fixed_date             pa_projects_all.labor_schedule_fixed_date%TYPE;
  l_labor_schedule_discount               NUMBER;
  l_labor_bill_rate_org_id                NUMBER;
  l_labor_std_bill_rate_schedule          pa_projects_all.labor_std_bill_rate_schdl%TYPE;
  l_labor_schedule_type                   pa_projects_all.labor_sch_type%TYPE;

  l_raw_cost_rate                         NUMBER;
  l_raw_cost                              NUMBER;

  l_x_return_status                       VARCHAR2(50);
  l_proj_bill_job_id                      NUMBER;
  l_overr_to_organization_id              NUMBER;
  l_job_cost_rate_schedule_id             pa_forecasting_options.job_cost_rate_schedule_id%TYPE;
  l_distribution_rule                     pa_projects_all.distribution_rule%TYPE;


  l_proj_cost_job_id                      NUMBER;
  l_cost_rate_multiplier                  NUMBER;
  l_class_code                            pa_project_types_all.project_type_class_code%TYPE;

  l_schedule_type                         VARCHAR2(50);

  l_expenditure_currency_code        gl_sets_of_books.currency_code%TYPE;
  l_expenditure_curr_code_burdn      gl_sets_of_books.currency_code%TYPE; /* Added for Org Forecasting */
  l_exp_func_cst_rt_date             DATE; /* Added for Org Forecasting */
  l_exp_func_cst_rt_type             PA_IMPLEMENTATIONS_ALL.default_rate_type%TYPE; /* Added for Org Forecasting */
  l_exp_func_cst_exch_rt             NUMBER; /* Added for Org Forecasting */
  l_exp_func_raw_cost_rate           NUMBER;
  l_exp_func_raw_cost                NUMBER;
  l_exp_func_burdened_cost_rate      NUMBER;
  l_exp_func_burdened_cost           NUMBER;

  /* Added for MCB2 */
   l_projfunc_currency_code          pa_projects_all.projfunc_currency_code%TYPE;
   l_projfunc_bil_rate_date_code     pa_projects_all.projfunc_bil_rate_date_code%TYPE;
   l_projfunc_bil_rate_type          pa_projects_all.projfunc_bil_rate_type%TYPE;
   l_projfunc_bil_rate_date          pa_projects_all.projfunc_bil_rate_date%TYPE;
   l_projfunc_bil_exchange_rate      pa_projects_all.projfunc_bil_exchange_rate%TYPE;
   l_projfunc_cost_rate_type         pa_projects_all.projfunc_cost_rate_type%TYPE;
   l_projfunc_cost_rate_date         pa_projects_all.projfunc_cost_rate_DATE%TYPE;
   l_projfunc_cost_exchange_rate     pa_projects_all.projfunc_bil_exchange_rate%TYPE;
   l_markup_percentage               pa_bill_rates_all.markup_percentage%TYPE; /* Added for Asgmt overide */
   l_assignment_precedes_task        pa_projects_all.assign_precedes_task%TYPE; /* Added for Asgmt overide */
/* Till here for mcb 2 */

/* Added for Org Foreasting */
   l_projfunc_bill_rate              NUMBER;
   l_projfunc_raw_revenue            NUMBER;
   l_projfunc_raw_cost               NUMBER;
   l_projfunc_raw_cost_rate          NUMBER;
   l_projfunc_burdened_cost          NUMBER;
   l_projfunc_burdened_cost_rate     NUMBER;

   l_amount_calc_mode               VARCHAR2(50);

   l_project_currency_code          pa_projects_all.project_currency_code%TYPE;
   l_project_bil_rate_date_code     pa_projects_all.project_bil_rate_date_code%TYPE;
   l_project_bil_rate_type          pa_projects_all.project_bil_rate_type%TYPE;
   l_project_bil_rate_date          pa_projects_all.project_bil_rate_date%TYPE;
   l_project_bil_exchange_rate      pa_projects_all.project_bil_exchange_rate%TYPE;
   l_project_cost_rate_type         pa_projects_all.project_rate_type%TYPE;
   l_project_cost_rate_date         pa_projects_all.project_rate_DATE%TYPE;
   l_project_cost_exchange_rate     pa_projects_all.project_bil_exchange_rate%TYPE;
   l_project_bill_rate              NUMBER;
   l_project_raw_revenue            NUMBER;
   l_project_raw_cost               NUMBER;
   l_project_raw_cost_rate          NUMBER;
   l_project_burdened_cost          NUMBER;
   l_project_burdened_cost_rate     NUMBER;

  l_cst_txn_curr_code               GL_SETS_OF_BOOKS.currency_code%TYPE;
  l_txn_raw_cst_rt                  NUMBER;
  l_txn_raw_cst                     NUMBER;
  l_txn_burdned_cst_rt              NUMBER;
  l_txn_burdned_cst                 NUMBER;

  l_rev_txn_curr_code               PA_BILL_RATES_ALL.rate_currency_code%TYPE;
  l_txn_rev_bill_rt                 NUMBER;

 l_txn_adjusted_bill_rt            NUMBER;-- 4038485
  l_txn_rev_raw_revenue             NUMBER;

  l_system_linkage                  pa_expenditure_items_all.system_linkage_function%TYPE;
 /* Till here for Org */


BEGIN

  IF g1_debug_mode  = 'Y' THEN
   PA_DEBUG.Set_Curr_Function( p_function   => 'Get Initial Bill Rate');
   PA_DEBUG.g_err_stage := 'RT50 : Before Validation PA_RATE_PVT_PKG.get_initial_bill_rate';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  END IF;

    /* Validating that the required parameters should not be null  */
    IF ( p_assignment_type IS NULL) OR  (p_asgn_start_date IS NULL ) OR (p_project_id IS NULL)
        OR  (p_quantity  IS NULL) OR (p_expenditure_type IS NULL )
      /*  OR (p_expenditure_organization_id IS NULL) OR (p_expenditure_org_id IS NULL)   commented because
          null condition is taken care in lower api */
        THEN
           RAISE l_insufficient_parameters;
    END IF;


    /* Validating that the required parameters should not be null  */
    IF ( p_assignment_type  = 'A') THEN
      IF (p_person_id IS NULL) THEN
         RAISE l_insufficient_parameters;
      END IF;
    END IF;

    /* Selecting expenditure org id , type ,organization id , forecast job id and forecast job group
    id from project assignments table only if the passed value is null otherwise storing passed
    values */
    IF (p_assignment_type = 'R') THEN
      IF (p_forecast_job_id IS NULL) OR (p_forecast_job_group_id IS NULL) THEN
        RAISE l_job_not_found;
      ELSE
         l_forecast_job_id              := p_forecast_job_id;
         l_forecast_job_group_id        := p_forecast_job_group_id;
      END IF;
    ELSIF ( p_assignment_type = 'A') THEN
         SELECT job_id
         INTO l_forecast_job_id
         FROM pa_resources_denorm
         WHERE person_id    = p_person_id
         AND  ( p_asgn_start_date BETWEEN TRUNC(resource_effective_start_date) AND
                    NVL(TRUNC(resource_effective_end_date),p_asgn_start_date));

    END IF;

   /* Selecting distribution rule for calculation rate */
   BEGIN
      SELECT proj.distribution_rule,typ.project_type_class_code,proj.labor_sch_type
      INTO   l_distribution_rule,l_class_code,l_labor_schedule_type
      FROM pa_project_types_all typ, pa_projects_all proj
      WHERE   proj.project_id   = p_project_id
      AND     proj.project_type = typ.project_type
      AND     proj.org_id       = typ.org_id;   -- bug 7413961 skkoppul : removed NVL function

      IF ( l_class_code = 'CONTRACT') THEN
       IF ( l_distribution_rule IS NULL) THEN
         RAISE l_no_rule;
       END IF;
      END IF;
   EXCEPTION
         WHEN l_no_rule THEN
          NULL;
         WHEN NO_DATA_FOUND THEN
           NULL;
   END;

    /* Selecting expenditure currency code from project set of books and implementations table
    only if the passed value is null otherwise storing passed  values */
    IF ( p_expenditure_currency_code IS NULL) THEN
       BEGIN
          SELECT glsb.currency_code
          INTO   l_expenditure_currency_code
          FROM gl_sets_of_books glsb, pa_implementations_all paimp
          WHERE glsb.set_of_books_id = paimp.set_of_books_id
          AND  paimp.org_id  = p_expenditure_org_id;         -- bug 7413961 skkoppul: removed NVL function
       END;
    ELSE
      l_expenditure_currency_code     := p_expenditure_currency_code;
    END IF;

      l_expenditure_curr_code_burdn := l_expenditure_currency_code; /* Made for Org Forecasting */

    /* Selecting labor cost mult name from tasks  table only if the passed value is null and task id
    is not null otherwise storing passed  values */
    IF ( p_task_id IS NOT NULL ) THEN
       BEGIN
        SELECT labor_cost_multiplier_name
        INTO   l_labor_cost_mult_name
        FROM pa_tasks
        WHERE task_id = p_task_id;
       END;
    END IF;

    /* Selecting project type from project types table only if the
    passed value is null otherwise storing passed  values */
    IF ( p_project_type IS NULL) THEN

      SELECT typ.project_type
      INTO   l_project_type
      FROM   pa_project_types_all typ, pa_projects_all proj
      WHERE   proj.project_id      = p_project_id
      AND     proj.project_type    = typ.project_type
      AND     proj.org_id          = typ.org_id;        -- bug 7413961 skkoppul: removed NVL function

    ELSE
      l_project_type           := p_project_type;
    END IF;


    /* Selecting  project org id, project currency code, project bill job
     group id, employee bill rate schedule id and job bill rate schedule id from project  all  table
     only if the passed value is null otherwise storing passed values */
    IF (p_project_org_id IS NULL) OR (p_project_bill_job_group_id IS NULL) OR
       (p_emp_bill_rate_schedule_id IS NULL) OR  (p_job_bill_rate_schedule_id  IS NULL)
       OR (p_labor_schedule_fixed_date  IS NULL) THEN
      BEGIN
         SELECT NVL(org_id,-99), bill_job_group_id,
                emp_bill_rate_schedule_id,job_bill_rate_schedule_id,
                labor_schedule_fixed_date,
                projfunc_currency_code,
                projfunc_bil_rate_date_code, /* Added the following column for MCB2 */
                projfunc_bil_rate_type,
                projfunc_bil_rate_date,
                projfunc_bil_exchange_rate,
                projfunc_cost_rate_date,
                projfunc_cost_rate_type,
                NVL(assign_precedes_task,'1'),/* Added for Asgmt overide */
                project_currency_code,        /* Added for Org Forecasting */
                project_bil_rate_date_code,   /* Added for Org Forecasting */
                project_bil_rate_type,        /* Added for Org Forecasting */
                project_bil_rate_date,        /* Added for Org Forecasting */
                project_bil_exchange_rate,    /* Added for Org Forecasting */
                project_rate_date,            /* Added for Org Forecasting */
                project_rate_type,            /* Added for Org Forecasting */
                labor_schedule_discount,      /* Added for Org Forecasting */
                labor_bill_rate_org_id,       /* Added for Org Forecasting */
                labor_std_bill_rate_schdl,    /* Added for Org Forecasting */
                labor_schedule_fixed_date,    /* Added for Org Forecasting */
                labor_sch_type                /* Added for Org Forecasting */
         INTO   l_project_org_id,l_project_bill_job_group_id,
                l_emp_bill_rate_schedule_id,l_job_bill_rate_schedule_id ,
                l_labor_schedule_fixed_date,
                l_projfunc_currency_code,
                l_projfunc_bil_rate_date_code, /* Added the following columns for MCB2 */
                l_projfunc_bil_rate_type,
                l_projfunc_bil_rate_date,
                l_projfunc_bil_exchange_rate,
                l_projfunc_cost_rate_date,
                l_projfunc_cost_rate_type,
                l_assignment_precedes_task,
                l_project_currency_code,
                l_project_bil_rate_date_code,
                l_project_bil_rate_type,
                l_project_bil_rate_date,
                l_project_bil_exchange_rate,
                l_project_cost_rate_date,
                l_project_cost_rate_type,
                l_labor_schedule_discount,
                l_labor_bill_rate_org_id,
                l_labor_std_bill_rate_schedule,
                l_labor_schedule_fixed_date,
                l_labor_schedule_type
         FROM pa_projects_all
         WHERE project_id = p_project_id;
      END;
    ELSE
	IF p_project_org_id IS NOT NULL THEN
         l_project_org_id		:= p_project_org_id;
	END IF;
	IF p_project_bill_job_group_id IS NOT NULL THEN
         l_project_bill_job_group_id    := p_project_bill_job_group_id;
	END IF;
	IF p_emp_bill_rate_schedule_id IS NOT NULL THEN
         l_emp_bill_rate_schedule_id    := p_emp_bill_rate_schedule_id;
	END IF;
	IF p_job_bill_rate_schedule_id IS NOT NULL THEN
         l_job_bill_rate_schedule_id    := p_job_bill_rate_schedule_id;
	END IF;

        /* Added for Org Forecasting */
        IF p_labor_schdl_discnt IS NOT NULL THEN
         l_labor_schedule_discount    := p_labor_schdl_discnt;
        END IF;

        IF p_labor_bill_rate_org_id IS NOT NULL THEN
         l_labor_bill_rate_org_id    := p_labor_bill_rate_org_id;
        END IF;

        IF p_labor_std_bill_rate_schdl IS NOT NULL THEN
         l_labor_std_bill_rate_schedule    := p_labor_std_bill_rate_schdl;
        END IF;

        IF p_labor_schedule_fixed_date IS NOT NULL THEN
            l_labor_schedule_fixed_date := p_labor_schedule_fixed_date;
        END IF;

        IF p_labor_sch_type IS NOT NULL THEN
         l_labor_schedule_type    := p_labor_sch_type;
        END IF;

        IF p_projfunc_rev_rt_date IS NOT NULL THEN
         l_projfunc_bil_rate_date    := p_projfunc_rev_rt_date;
        END IF;

        IF p_projfunc_rev_rt_type IS NOT NULL THEN
         l_projfunc_bil_rate_type    := p_projfunc_rev_rt_type;
        END IF;

        IF p_projfunc_rev_exch_rt IS NOT NULL THEN
         l_projfunc_bil_exchange_rate    := p_projfunc_rev_exch_rt;
        END IF;

        IF p_projfunc_cst_rt_date IS NOT NULL THEN
         l_projfunc_cost_rate_date    := p_projfunc_cst_rt_date;
        END IF;

        IF p_projfunc_cst_rt_type IS NOT NULL THEN
         l_projfunc_cost_rate_type    := p_projfunc_cst_rt_type;
        END IF;

        IF p_project_currency_code IS NOT NULL THEN
         l_project_currency_code    := p_project_currency_code;
        END IF;

        IF p_project_rev_rt_date IS NOT NULL THEN
         l_project_bil_rate_date    := p_project_rev_rt_date;
        END IF;

        IF p_project_rev_rt_type IS NOT NULL THEN
         l_project_bil_rate_type    := p_project_rev_rt_type;
        END IF;

        IF p_project_rev_exch_rt IS NOT NULL THEN
         l_project_bil_exchange_rate    := p_project_rev_exch_rt;
        END IF;

        IF p_project_cst_rt_date IS NOT NULL THEN
         l_project_cost_rate_date    := p_project_cst_rt_date;
        END IF;

        IF p_project_cst_rt_type IS NOT NULL THEN
         l_project_cost_rate_type    := p_project_cst_rt_type;
        END IF;


    END IF;

    IF (p_system_linkage IS NULL ) THEN
     /* Added for Org_forecasting */
      SELECT    default_assign_exp_type_class
      INTO      l_system_linkage
      FROM    pa_forecasting_options_all
      WHERE   NVL(org_id,-99) = nvl(l_project_org_id,-99);
   ELSE
      l_system_linkage   := p_system_linkage;
   END IF;

     /* Selecting project cost job group id,job cost rate schedule id from forecasting options and
        pa std billrate table only if the passed value is null otherwise storing passed  values */

    IF ( p_proj_cost_job_group_id IS NULL) OR ( p_job_cost_rate_schedule_id IS NULL) THEN
      SELECT bschal.job_group_id,foptal.job_cost_rate_schedule_id
      INTO   l_proj_cost_job_grp_id,l_job_cost_rate_schedule_id
      FROM   pa_std_bill_rate_schedules_all bschal,pa_forecasting_options_all foptal
      WHERE   bschal.bill_rate_sch_id  = foptal.job_cost_rate_schedule_id
      /* For bug 4101595: Reverted the fix done for bug 3786192 */
      /* AND     nvl(foptal.org_id, -99) = nvl(p_expenditure_org_id, -99) */ /* Added for 3786192 */
      AND     bschal.org_id = l_project_org_id;         -- bug 7413961 skkoppul: removed NVL function

    ELSE
      l_proj_cost_job_grp_id       := p_proj_cost_job_group_id;
      l_job_cost_rate_schedule_id  := p_job_cost_rate_schedule_id;
    END IF;

/* commented for Org Forecasting
  IF (l_labor_schedule_fixed_date IS NULL) OR (l_projfunc_currency_code IS NULL) THEN
    BEGIN
      SELECT labor_schedule_fixed_date,
             projfunc_currency_code,projfunc_bil_rate_date_code, -- Added the following column for MCB2
             projfunc_bil_rate_type,projfunc_bil_rate_date,projfunc_bil_exchange_rate,
             projfunc_cost_rate_date,projfunc_cost_rate_type,
              NVL(assign_precedes_task,'1'), -- Added for Asgmt overide
             labor_sch_type
      INTO   l_labor_schedule_fixed_date,
             l_projfunc_currency_code,l_projfunc_bil_rate_date_code, -- Added the following columns for MCB2
             l_projfunc_bil_rate_type,l_projfunc_bil_rate_date,l_projfunc_bil_exchange_rate,
             l_projfunc_cost_rate_date,l_projfunc_cost_rate_type,
             l_assignment_precedes_task,
             l_labor_schedule_type
      FROM pa_projects_all
      WHERE project_id      = p_project_id;
    END;
  END IF;
*/

  /* Added to fix bug 2162965, if the assignment api is calling this api then, we do not need to
     calculate the cost rate, else we do */
  IF (l_labor_schedule_type = 'I') THEN
     l_calculate_cost_flag := 'Y';
  ELSE
     l_calculate_cost_flag := p_calculate_cost_flag;
  END IF;

 IF g1_debug_mode  = 'Y' THEN
   PA_DEBUG.g_err_stage := 'RT51 : After Validation PA_RATE_PVT_PKG.get_initial_bill_rate';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
 END IF;
    /* Calling the rate calculation APIs */

    --------------------------------------------
    -- Initialize the successful return status
    --------------------------------------------

    l_x_return_status 		:= FND_API.G_RET_STS_SUCCESS;
    l_Schedule_type := 'COST';

  IF (l_calculate_cost_flag = 'Y') THEN /* Added this if to fix bug 2162965 */
   IF ( p_assignment_type = 'A')  THEN
    IF g1_debug_mode  = 'Y' THEN
     PA_DEBUG.g_err_stage := 'RT52 : Entering PA_COST.get_raw_cost';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

      PA_COST.get_raw_cost ( P_person_id                  => p_person_id                  ,
                             P_expenditure_org_id         => p_expenditure_org_id         ,
                             P_expend_organization_id     => p_expenditure_organization_id,  /*LCE*/
                             P_labor_Cost_Mult_Name       => l_labor_cost_mult_name       ,
                             P_Item_date                  => p_asgn_start_date            ,
                             px_exp_func_curr_code        => l_expenditure_curr_code_burdn,
                             P_Quantity                   => p_quantity                   ,
                             X_Raw_cost_rate              => l_raw_cost_rate              ,
                             X_Raw_cost                   => l_raw_cost                   ,
                             x_return_status              => l_x_return_status            ,
                             x_msg_count                  => x_msg_count                  ,
                             x_msg_data                   => x_msg_data
                             );

    IF g1_debug_mode  = 'Y' THEN
      PA_DEBUG.g_err_stage := 'RT53 : Leaving PA_COST.get_raw_cost';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;

      IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.g_err_stage := 'RT54 : Entering PA_COST.override_exp_organization';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;

       PA_COST.override_exp_organization(P_item_date                  => p_asgn_start_date              ,
                                         P_person_id                  => p_person_id                   ,
                                         P_project_id                 => p_project_id                  ,
                                         P_incurred_by_organz_id      => p_expenditure_organization_id ,
                                         P_Expenditure_type           => p_expenditure_type            ,
                                         X_overr_to_organization_id   => l_overr_to_organization_id    ,
                                         x_return_status              => l_x_return_status             ,
                                         x_msg_count                  => x_msg_count                   ,
                                         x_msg_data                   => x_msg_data
                                         );

      IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.g_err_stage := 'RT55 : Leaving PA_COST.override_exp_organization';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

      END IF;

   ELSIF (p_assignment_type = 'R') THEN
      IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.g_err_stage := 'RT52 : Entering PA_COST.requirement_raw_cost';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
         /* Four project functional attributes added for MCB2 */
         PA_COST.requirement_raw_cost( p_forecast_cost_job_group_id   => l_forecast_job_group_id     ,
                                       p_forecast_cost_job_id         => l_forecast_job_id           ,
                                       p_proj_cost_job_group_id       => l_proj_cost_job_grp_id      ,
                                       px_proj_cost_job_id            => l_proj_cost_job_id          ,
                                       p_item_date                    => p_asgn_start_date            ,
                                       p_job_cost_rate_sch_id         => l_job_cost_rate_schedule_id ,
                                       p_schedule_date                => l_labor_schedule_fixed_date ,
                                       p_quantity                     => p_quantity                  ,
                                       p_cost_rate_multiplier         => l_cost_rate_multiplier      ,
                                       p_org_id                       => l_project_org_id            ,
                                       p_expend_organization_id       => p_expenditure_organization_id ,  /*LCE*/
                                       x_raw_cost_rate                => l_raw_cost_rate             ,
                                       x_raw_cost                     => l_raw_cost                  ,
                                       x_txn_currency_code            => l_expenditure_curr_code_burdn,
                                       x_return_status                => l_x_return_status           ,
                                       x_msg_count                    => x_msg_count                 ,
                                       x_msg_data                     => x_msg_data
                                       );
   END IF;

      l_expenditure_currency_code   := NVL(l_expenditure_curr_code_burdn,l_expenditure_currency_code); /* added for Org Fcst */

            IF (NVL(l_raw_cost,0) <> 0 ) THEN

                 PA_COST.get_burdened_cost(p_project_type     => l_project_type                  ,
                              p_project_id                    => p_project_id                    ,
                              p_task_id                       => p_task_id                       ,
                              p_item_date                     => p_asgn_start_date               ,
                              p_expenditure_type              => p_expenditure_type              ,
                              p_schedule_type                 => l_schedule_type                 ,
                              px_exp_func_curr_code           => l_expenditure_currency_code     ,
                              p_Incurred_by_organz_id         => p_expenditure_organization_id   ,
                              p_raw_cost                      => l_raw_cost                      ,
                              p_raw_cost_rate                 => l_raw_cost_rate                 ,
                              p_quantity                      => p_quantity                      ,
                              p_override_to_organz_id         => l_overr_to_organization_id      ,
                              x_burden_cost                   => l_exp_func_burdened_cost        ,
                              x_burden_cost_rate              => l_exp_func_burdened_cost_rate   ,
                              x_return_status                 => l_x_return_status               ,
                              x_msg_count                     => x_msg_count                     ,
                              x_msg_data                      => x_msg_data
                              );

    PA_COST.Get_Converted_Cost_Amounts(
              P_exp_org_id                   =>  p_expenditure_org_id,
              P_proj_org_id                  =>  l_project_org_id,
              P_project_id                   =>  p_project_id,
              P_task_id                      =>  p_task_id,
              P_item_date                    =>  p_asgn_start_date,
              p_system_linkage               =>  l_system_linkage,
              px_txn_curr_code               =>  l_cst_txn_curr_code,
              px_raw_cost                    =>  l_raw_cost,
              px_raw_cost_rate               =>  l_raw_cost_rate,
              px_burden_cost                 =>  l_exp_func_burdened_cost,
              px_burden_cost_rate            =>  l_exp_func_burdened_cost_rate,
              px_exp_func_curr_code          =>  l_expenditure_currency_code,
              px_exp_func_rate_date          =>  l_exp_func_cst_rt_date,
              px_exp_func_rate_type          =>  l_exp_func_cst_rt_type,
              px_exp_func_exch_rate          =>  l_exp_func_cst_exch_rt,
              px_exp_func_cost               =>  l_exp_func_raw_cost,
              px_exp_func_cost_rate          =>  l_exp_func_raw_cost_rate,
              px_exp_func_burden_cost        =>  l_exp_func_burdened_cost,
              px_exp_func_burden_cost_rate   =>  l_exp_func_burdened_cost_rate,
              px_proj_func_curr_code         =>  l_projfunc_currency_code,
              px_projfunc_cost_rate_date     =>  l_projfunc_cost_rate_date,
              px_projfunc_cost_rate_type     =>  l_projfunc_cost_rate_type,
              px_projfunc_cost_exch_rate     =>  l_projfunc_cost_exchange_rate,
              px_projfunc_raw_cost           =>  l_projfunc_raw_cost ,
              px_projfunc_raw_cost_rate      =>  l_projfunc_raw_cost_rate ,
              px_projfunc_burden_cost        =>  l_projfunc_burdened_cost ,
              px_projfunc_burden_cost_rate   =>  l_projfunc_burdened_cost_rate ,
              px_project_curr_code           =>  l_project_currency_code,
              px_project_rate_date           =>  l_project_cost_rate_date,
              px_project_rate_type           =>  l_project_cost_rate_type,
              px_project_exch_rate           =>  l_project_cost_exchange_rate,
              px_project_cost                =>  l_project_raw_cost,
              px_project_cost_rate           =>  l_project_raw_cost_rate,
              px_project_burden_cost         =>  l_project_burdened_cost,
              px_project_burden_cost_rate    =>  l_project_burdened_cost_rate,
              x_return_status                =>  l_x_return_status  ,
              x_msg_count                    =>  x_msg_count    ,
              x_msg_data                     =>  x_msg_data
              );

          END IF;

/* Deleted this proc PA_COST.get_projfunc_raw_burdened_cost() for Org Forecasting */

   END IF; /* end of calculate cost flag */

   IF (SUBSTR(l_distribution_rule,1,4) = 'WORK' AND l_class_code = 'CONTRACT') THEN
     IF ( p_assignment_type = 'A')  THEN
      IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.g_err_stage := 'RT56 : Entering PA_REVENUE.get_rev_amt';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

        PA_REVENUE.Assignment_Rev_Amt(
                   p_project_id                  => p_project_id                   ,
                   p_task_id                     => p_task_id                      ,
                   p_bill_rate_multiplier        => p_bill_rate_multiplier         ,
                   p_quantity                    => p_quantity                     ,
                   p_person_id                   => p_person_id                    ,
                   p_raw_cost                    => l_projfunc_raw_cost                ,
                   p_item_date                   => p_asgn_start_date               ,
                   p_labor_schdl_discnt          => l_labor_schedule_discount      ,
                   p_labor_bill_rate_org_id      => l_labor_bill_rate_org_id       ,
                   p_labor_std_bill_rate_schdl   => l_labor_std_bill_rate_schedule ,
                   p_labor_schdl_fixed_date      => l_labor_schedule_fixed_date    ,
                   p_bill_job_grp_id             => l_project_bill_job_group_id    ,
                   p_item_id                     => p_assignment_id , /* changed for bug 2212852 */
                   p_forecast_item_id            => p_forecast_item_id, /* added for bug 2212852 */
                   p_forecasting_type            => p_forecasting_type , /* added for bug 2212852 */
                   p_labor_sch_type              => l_labor_schedule_type          ,
                   p_project_org_id              => l_project_org_id               ,
                   p_project_type                => l_project_type                 ,
                   p_expenditure_type            => p_expenditure_type             ,
                   p_exp_func_curr_code          => l_expenditure_currency_code    ,
                   p_incurred_by_organz_id       => p_expenditure_organization_id  ,
                   p_raw_cost_rate               => l_raw_cost_rate                ,
                   p_override_to_organz_id       => l_overr_to_organization_id     ,
                   p_emp_bill_rate_schedule_id   => l_emp_bill_rate_schedule_id    ,
                   p_resource_job_id             => l_forecast_job_id              ,
                   p_exp_raw_cost                => l_raw_cost                     ,
                   p_expenditure_org_id          => p_expenditure_org_id           ,
                   p_projfunc_currency_code      => l_projfunc_currency_code       , -- The following 5
                   p_assignment_precedes_task    => l_assignment_precedes_task , /* Added for Asgmt overide */
                   p_sys_linkage_function        => l_system_linkage, /* Added for Org FCST */
                   x_bill_rate                   => l_txn_rev_bill_rt,/* Change for Org Forecsting */
                   x_raw_revenue                 => l_txn_rev_raw_revenue ,
                   x_markup_percentage           => l_markup_percentage,/* Added for Asgmt overide */
                   x_txn_currency_code           => l_rev_txn_curr_code, /* added for Org */
                   x_rev_currency_code           => l_projfunc_currency_code        ,
                   x_return_status               => l_x_return_status              ,
                   x_msg_count                   => x_msg_count                    ,
                   x_msg_data                    => x_msg_data                     ,
                    /* Added for bug 2668753 */
                   p_project_raw_cost            => l_project_raw_cost             ,
                   p_project_currency_code       => l_project_currency_code   ,
		    x_adjusted_bill_rate         => l_txn_adjusted_bill_rt
                   );

        -- dbms_output.put_line(' Get Ini rev : '||l_txn_rev_raw_revenue||' curr : '||l_rev_txn_curr_code);
     IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.g_err_stage := 'RT57 : Leaving PA_REVENUE.get_rev_amt';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;
              /*   IF ( x_projfunc_raw_revenue IS NULL OR x_projfunc_raw_revenue = 0 ) THEN
                           x_projfunc_bill_rate   := 0;
                            x_projfunc_raw_revenue := 0;
                  END IF;   Commented for Org Forecasting */


   ELSIF (p_assignment_type = 'R') THEN
     IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.g_err_stage := 'RT53 : Leaving PA_COST.requirement_raw_cost';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;

           PA_REVENUE.requirement_rev_amt(
                      p_project_id                  => p_project_id                   ,
                      p_task_id                     => p_task_id                      ,
                      p_bill_rate_multiplier        => p_bill_rate_multiplier         ,
                      p_quantity                    => p_quantity                     ,
                      p_raw_cost                    => l_projfunc_raw_cost                ,
                      p_item_date                   => p_asgn_start_date              ,
                      p_project_bill_job_grp_id     => l_project_bill_job_group_id    ,
                      p_labor_schdl_discnt          => l_labor_schedule_discount      ,
                      p_labor_bill_rate_org_id      => l_labor_bill_rate_org_id       ,
                      p_labor_std_bill_rate_schdl   => l_labor_std_bill_rate_schedule ,
                      p_labor_schdl_fixed_date      => l_labor_schedule_fixed_date    ,
                      p_forecast_job_id             => l_forecast_job_id              ,
                      p_forecast_job_grp_id         => l_forecast_job_group_id        ,
                      p_labor_sch_type              => l_labor_schedule_type          ,
                      p_item_id                     => p_assignment_id , /* changed for bug 2212852 */
                      p_forecast_item_id            => p_forecast_item_id, /* added for bug 2212852 */
                      p_forecasting_type            => p_forecasting_type , /* added for bug 2212852 */
                      p_project_org_id              => l_project_org_id               ,
                      p_job_bill_rate_schedule_id   => l_job_bill_rate_schedule_id    ,
                      p_project_type                => l_project_type                 ,
                      p_expenditure_type            => p_expenditure_type             ,
                      px_exp_func_curr_code         => l_expenditure_currency_code    ,
                      p_incurred_by_organz_id       => p_expenditure_organization_id  ,
                      p_raw_cost_rate               => l_raw_cost_rate                ,
                      p_override_to_organz_id       => l_overr_to_organization_id     ,
                      p_exp_raw_cost                => l_raw_cost                     ,
                      p_expenditure_org_id          => p_expenditure_org_id           ,
                      p_projfunc_currency_code      => l_projfunc_currency_code      , -- The following 5
                      p_assignment_precedes_task    => l_assignment_precedes_task , /* Added for Asgmt overide */
                      p_sys_linkage_function        => l_system_linkage, /* Added for Org FCST */
                      px_project_bill_job_id        => l_proj_bill_job_id             ,
                      x_bill_rate                   => l_txn_rev_bill_rt,/*Change for Org Forecsting */
                      x_raw_revenue                 => l_txn_rev_raw_revenue ,
                      x_markup_percentage           => l_markup_percentage,/* Added for Asgmt overide */
                      x_txn_currency_code           => l_rev_txn_curr_code, /* added for Org */
                      x_return_status               => l_x_return_status              ,
                      x_msg_count                   => x_msg_count                    ,
                      x_msg_data                    => x_msg_data
                      );

         IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT55 : Leaving PA_REVENUE.requirement_rev_amt';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;

       END IF; /* End of assignment_type if */

       IF ( (NVL(l_txn_rev_raw_revenue,0) <> 0)  ) THEN

          -- dbms_output.put_line(' Get Ini rev 0.1 : '||l_txn_rev_raw_revenue||' curr : '||l_rev_txn_curr_code);
           PA_REVENUE.Get_Converted_Revenue_Amounts(
                   p_item_date                    => p_asgn_start_date,
                   px_txn_curr_code               => l_rev_txn_curr_code,
                   px_txn_raw_revenue             => l_txn_rev_raw_revenue,
                   px_txn_bill_rate               => l_txn_rev_bill_rt,
                   px_projfunc_curr_code          => l_projfunc_currency_code,
                   p_projfunc_bil_rate_date_code  => l_projfunc_bil_rate_date_code,
                   px_projfunc_bil_rate_type      => l_projfunc_bil_rate_type,
                   px_projfunc_bil_rate_date      => l_projfunc_bil_rate_date,
                   px_projfunc_bil_exchange_rate  => l_projfunc_bil_exchange_rate,
                   px_projfunc_raw_revenue        => l_projfunc_raw_revenue ,
                   px_projfunc_bill_rate          => l_projfunc_bill_rate ,
                   px_project_curr_code           => l_project_currency_code,
                   p_project_bil_rate_date_code   => l_project_bil_rate_date_code,
                   px_project_bil_rate_type       => l_project_bil_rate_type,
                   px_project_bil_rate_date       => l_project_bil_rate_date,
                   px_project_bil_exchange_rate   => l_project_bil_exchange_rate,
                   px_project_raw_revenue         => l_project_raw_revenue ,
                   px_project_bill_rate           => l_project_bill_rate ,
                   x_return_status                => l_x_return_status  ,
                   x_msg_count                    => x_msg_count    ,
                   x_msg_data                     => x_msg_data
                   );

        -- dbms_output.put_line(' Get Ini rev 1 : '||l_txn_rev_raw_revenue||' curr : '||l_rev_txn_curr_code);
          x_projfunc_bill_rate      := l_projfunc_bill_rate;
          x_projfunc_raw_revenue    := l_projfunc_raw_revenue;
      END IF;

      IF ( x_projfunc_raw_revenue IS NULL OR x_projfunc_raw_revenue = 0 ) THEN
        x_projfunc_bill_rate   := 0;
        x_projfunc_raw_revenue := 0;
      END IF;
   END IF; /* End of class code and rule if (for R and A) */

    -------------------------------------------------------
    -- Assign the successful status back to output variable
    -------------------------------------------------------

    x_return_status := l_x_return_status;

    x_rev_currency_code  := l_projfunc_currency_code;
    x_markup_percentage  := l_markup_percentage; /* Added for Asgmt overide */

         IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT58 : Leaving PA_RATE_PVT_PKG.get_initial_bill_rate';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           PA_DEBUG.Reset_Curr_Function;
         END IF;

  EXCEPTION
     WHEN l_insufficient_parameters THEN
         IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
          END IF;
           x_return_status           :=  FND_API.G_RET_STS_ERROR;
           x_msg_count               := 1;
           x_msg_data                := 'PA_FCST_INSUFFICIENT_PARA';
     WHEN l_job_not_found THEN
         IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
         END IF;
        x_return_status              :=  FND_API.G_RET_STS_ERROR;
        x_msg_count                  := 1;
        x_msg_data                   := 'PA_FCST_NO_JOB_FOUND';
     WHEN OTHERS THEN
         IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
          END IF;

    /* ATG Changes */

     x_projfunc_bill_rate    := null;
     x_projfunc_raw_revenue  := null;
     x_rev_currency_code     := null;
     x_markup_percentage     := null;


          x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_data       := SUBSTR(SQLERRM,1,30);
         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
          FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_RATE_PVT_PKG', /* Moved this here to fix bug 2434663 */
                                   p_procedure_name => 'get_initial_bill_rate');
            RAISE;
         END IF;

  END get_initial_bill_rate;


-- This procedure contains consolidated procedure and function to calculate the raw cost,
-- burdened cost and raw revenue on the basis of passed parameters on array basis
-- Input parameters
-- Parameters                     Type           Required      Description
-- p_calling_mode                 VARCHAR2        YES          Calling mode values are ACTUAL/ROLE/ASSIGNMENT
-- P_item_id                      NUMBER          YES          Unique identifier
-- P_project_id                   NUMBER          YES          Project Id
-- P_forecast_job_id              NUMBER          NO           Forecast job Id at assignment level
-- P_forecast_job_group_id        NUMBER          NO           Forecast job group id at assignment level
-- p_person_id                    NUMBER          NO           Person id
-- P_expenditure_type             VARCHAR2        NO           Expenditure Type
-- p_expenditure_organization_id  NUMBER          NO           Expenditure organization id
-- p_project_org_id               NUMBER          NO           Project  org id
-- p_labor_cost_multi_name        VARCHAR2        NO           Labor cost multiplier name for calculating the cost
-- p_expenditure_currency_code    VARCHAR2        NO           Expenditure functional currency code
-- P_proj_cost_job_group_id       NUMBER          NO           Project cost job gorup id
-- P_job_cost_rate_schedule_id    NUMBER          NO           Job cost rate schedule id
-- P_project_type                 VARCHAR2        NO           Project Type
-- P_task_id                      NUMBER          NO           Task Id  for the given project
-- p_projfunc_currency_code        VARCHAR2       NO           Project Functional currency code
-- P_bill_rate_multiplier         NUMBER          NO           Bill rate multiplier for calculating the revenue
-- P_project_bill_job_group_id    NUMBER          NO           Billing job group id for project
-- p_emp_bill_rate_schedule_id    NUMBER          NO           Employee bill rate schedule id
-- P_job_bill_rate_schedule_id    NUMBER          NO           Job bill rate schedule id
--                                                             and rate
-- p_distribution_rule            VARCHAR2        NO           Distribution rule
--
-- Out parameters
--
-- x_exp_func_raw_cost_rate       NUMBER          YES          Row cost rate in expenditure currency
-- x_exp_func_raw_cost            NUMBER          YES          Row cost in expenditure currency
-- x_exp_func_burdened_cost_rate  NUMBER          YES          Burdened cost rate in  expenditure currency
-- x_exp_func_burdened_cost       NUMBER          YES          Burdened cost in  expenditure currency
-- x_projfunc_bill_rate               NUMBER          YES          Bill rate in project currency
-- x_projfunc_raw_revenue             NUMBER          YES          Raw revenue in project currency
-- x_projfunc_raw_cost                NUMBER          YES          Raw cost in project currency
-- x_projfunc_raw_cost_rate           NUMBER          YES          Raw cost rate in project currency
-- x_projfunc_burdened_cost_rate      NUMBER          YES          Burdened cost rate in  project currency
-- x_projfunc_burdened_cost           NUMBER          YES          Burdened cost in  project currency
-- x_error_msg                    VARCHAR2        YES          Error message used in when others exception
-- x_rev_rejct_reason             VARCHAR2        YES          Rejection reason for revenue
-- x_cost_rejct_reason            VARCHAR2        YES          Rejection reason for cost
-- x_burdened_rejct_reason        VARCHAR2        YES          Rejection reason for burden
-- x_others_rejct_reason          VARCHAR2        YES          Rejection reason for other error like pl/sql etc.

PROCEDURE calc_rate_amount(

        p_calling_mode                 IN     VARCHAR2 , /* possible values 'ASSIGNMENT','ROLE','UNASSIGNED'  */
                                                         /* for Org forecasting */
        p_rate_calc_date_tab           IN     PA_PLSQL_DATATYPES.DateTabTyp   ,
        p_asgn_start_date              IN     DATE   ,
        p_item_id                      IN     NUMBER ,
        p_project_id                   IN     NUMBER ,
        p_quantity_tab                 IN     PA_PLSQL_DATATYPES.NumTabTyp,
        p_forecast_job_id              IN     NUMBER   DEFAULT NULL,
        p_forecast_job_group_id        IN     NUMBER   DEFAULT NULL,
        p_person_id                    IN     NUMBER   DEFAULT NULL,
        p_expenditure_org_id_tab       IN     PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_type             IN     VARCHAR2 DEFAULT NULL,
        p_expenditure_orgz_id_tab      IN     PA_PLSQL_DATATYPES.IdTabTyp ,
        p_project_org_id               IN     NUMBER   DEFAULT NULL,
        p_labor_cost_multi_name        IN     VARCHAR2 DEFAULT NULL,
        p_proj_cost_job_group_id       IN     NUMBER   DEFAULT NULL,
        p_job_cost_rate_schedule_id    IN     NUMBER   DEFAULT NULL,
        p_project_type                 IN     VARCHAR2 DEFAULT NULL,
        p_task_id                      IN     NUMBER   DEFAULT NULL,
        p_bill_rate_multiplier         IN     NUMBER   DEFAULT NULL,
        p_project_bill_job_group_id    IN     NUMBER   DEFAULT NULL,
        p_emp_bill_rate_schedule_id    IN     NUMBER   DEFAULT NULL,
        p_job_bill_rate_schedule_id    IN     NUMBER   DEFAULT NULL,
        p_distribution_rule            IN     VARCHAR2 DEFAULT NULL,
        p_amount_calc_mode             IN     VARCHAR2 DEFAULT 'ALL', /* Possible values 'ALL','COST','REVENUE'  */
                                                                      /* Added fro Org Forecasting*/
        P_system_linkage               IN     PA_PLSQL_DATATYPES.Char30TabTyp,/* Added */
                                                                             /* for Org Forecasting */
        p_assign_precedes_task         IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_schdl_discnt           IN     NUMBER   DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_bill_rate_org_id       IN     NUMBER   DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_std_bill_rate_schdl    IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_schedule_fixed_date    IN     DATE     DEFAULT NULL, /* Added for Org Forecasting */
        p_labor_sch_type               IN     VARCHAR2 DEFAULT NULL, /* Added for Org Forecasting */
        p_forecast_item_id_tab         IN     PA_PLSQL_DATATYPES.IdTabTyp, /* Added para for bug 2212852 */
        p_forecasting_type             IN     VARCHAR2 DEFAULT 'PROJECT_FORECASTING',/*Added par for bug2212852*/
        p_projfunc_currency_code       IN     VARCHAR2 DEFAULT NULL,
        p_projfunc_rev_rt_dt_code_tab  IN     PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for Org Forecasting */
        p_projfunc_rev_rt_date_tab     IN     PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for Org Forecasting */
        p_projfunc_rev_rt_type_tab     IN     PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for Org Forecasting */
        p_projfunc_rev_exch_rt_tab     IN     PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for Org Forecasting */
        p_projfunc_cst_rt_date_tab     IN     PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for Org Forecasting */
        p_projfunc_cst_rt_type_tab     IN     PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for Org Forecasting */
        x_projfunc_bill_rt_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_projfunc_raw_revenue_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_projfunc_rev_rt_date_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_rev_rt_type_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_rev_exch_rt_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_raw_cst_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_projfunc_raw_cst_rt_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_projfunc_burdned_cst_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_projfunc_burdned_cst_rt_tab  OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_projfunc_cst_rt_date_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_cst_rt_type_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_projfunc_cst_exch_rt_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        p_project_currency_code        IN     VARCHAR2 DEFAULT NULL,           /* Added for org Forecasting */
        p_project_rev_rt_dt_code_tab   IN     PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */
        p_project_rev_rt_date_tab      IN     PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for org Forecasting */
        p_project_rev_rt_type_tab      IN     PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */
        p_project_rev_exch_rt_tab      IN     PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */
        p_project_cst_rt_date_tab      IN     PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for org Forecasting */
        p_project_cst_rt_type_tab      IN     PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */
        x_project_bill_rt_tab          OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_raw_revenue_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_rev_rt_date_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_rev_rt_type_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_rev_exch_rt_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_raw_cst_tab          OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_raw_cst_rt_tab       OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_burdned_cst_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_burdned_cst_rt_tab   OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_cst_rt_date_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_cst_rt_type_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_project_cst_exch_rt_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_curr_code_tab       OUT    NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_raw_cst_rt_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp , --File.Sql.39 bug 4440895
        x_exp_func_raw_cst_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_exp_func_burdned_cst_rt_tab  OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_exp_func_burdned_cst_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_exp_func_cst_rt_date_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_cst_rt_type_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_cst_exch_rt_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_cst_txn_curr_code_tab        OUT    NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
        x_txn_raw_cst_rt_tab           OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp , --File.Sql.39 bug 4440895
        x_txn_raw_cst_tab              OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_txn_burdned_cst_rt_tab       OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_txn_burdned_cst_tab          OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
        x_rev_txn_curr_code_tab        OUT    NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
        x_txn_rev_bill_rt_tab          OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_txn_rev_raw_revenue_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_error_msg                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_rev_rejct_reason_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
        x_cst_rejct_reason_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
        x_burdned_rejct_reason_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
        x_others_rejct_reason_tab      IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, /* Changed for Org Forecasting */ --File.Sql.39 bug 4440895
        x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_msg_data                     OUT    NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_rate_calc_date                  DATE;
  l_rate_calc_date_tab              PA_PLSQL_DATATYPES.DateTabTyp;
  l_quantity                        NUMBER;
  l_expenditure_org_id              pa_project_assignments.expenditure_org_id%TYPE;
  l_expenditure_orgz_id             pa_project_assignments.expenditure_organization_id%TYPE;
  /* MCB2 related changes */
  l_projfunc_bill_rate              NUMBER;
  l_projfunc_raw_revenue            NUMBER;
  l_projfunc_raw_cost               NUMBER;
  l_projfunc_raw_cost_rate          NUMBER;
  l_projfunc_burdened_cost          NUMBER;
  l_projfunc_burdened_cost_rate     NUMBER;
  /* till here */
  l_rev_rejct_reason                VARCHAR2(30);
  l_cost_rejct_reason               VARCHAR2(30);
  l_burdened_rejct_reason           VARCHAR2(30);
  l_others_rejct_reason             VARCHAR2(30);

  l_return_status                   VARCHAR2(30);
  l_error_msg                       VARCHAR2(30);

  l_exp_func_raw_cost_rate          NUMBER;
  l_exp_func_raw_cost               NUMBER;
  l_exp_func_burdened_cost_rate     NUMBER;
  l_exp_func_burdened_cost          NUMBER;

  l_forecast_item_id                pa_forecast_items.forecast_item_id%TYPE; /* added for bug 2212852 */

  /* Adding for Org Forecasting */

  l_projfunc_rev_rt_dt_code            PA_PROJECTS_ALL.projfunc_bil_rate_date_code%TYPE;
  l_projfunc_rev_rt_type               PA_PROJECTS_ALL.projfunc_bil_rate_type%TYPE;
  l_projfunc_rev_rt_date               PA_PROJECTS_ALL.projfunc_bil_rate_date%TYPE;
  l_projfunc_rev_exch_rt               PA_PROJECTS_ALL.projfunc_bil_exchange_rate%TYPE;

  l_projfunc_cst_rt_type               PA_PROJECTS_ALL.projfunc_cost_rate_type%TYPE;
  l_projfunc_cst_rt_date               PA_PROJECTS_ALL.projfunc_cost_rate_date%TYPE;
  l_projfunc_cst_exch_rt               NUMBER;

  l_project_rev_rt_dt_code             PA_PROJECTS_ALL.project_bil_rate_date_code%TYPE;
  l_project_rev_rt_type                PA_PROJECTS_ALL.project_bil_rate_type%TYPE;
  l_project_rev_rt_date                PA_PROJECTS_ALL.project_bil_rate_date%TYPE;
  l_project_rev_exch_rt                PA_PROJECTS_ALL.project_bil_exchange_rate%TYPE;

  l_project_cst_rt_type                PA_PROJECTS_ALL.project_rate_type%TYPE;
  l_project_cst_rt_date                PA_PROJECTS_ALL.project_rate_date%TYPE;
  l_project_cst_exch_rt                NUMBER;

  l_project_bill_rate                  NUMBER;
  l_project_raw_revenue                NUMBER;
  l_project_raw_cost                   NUMBER;
  l_project_raw_cost_rate              NUMBER;
  l_project_burdened_cost              NUMBER;
  l_project_burdened_cost_rate         NUMBER;

  l_exp_func_curr_code                 GL_SETS_OF_BOOKS.currency_code%TYPE;
  l_exp_func_cst_rt_date               DATE;
  l_exp_func_cst_rt_type               PA_IMPLEMENTATIONS_ALL.default_rate_type%TYPE;
  l_exp_func_cst_exch_rt               NUMBER;

  l_cst_txn_curr_code                  GL_SETS_OF_BOOKS.currency_code%TYPE;
  l_txn_raw_cst_rt                     NUMBER;
  l_txn_raw_cst                        NUMBER;
  l_txn_burdned_cst_rt                 NUMBER;
  l_txn_burdned_cst                    NUMBER;

  l_rev_txn_curr_code                  PA_BILL_RATES_ALL.rate_currency_code%TYPE;
  l_txn_rev_bill_rt                    NUMBER;
  l_txn_rev_raw_revenue                NUMBER;

  l_system_linkage                      pa_expenditure_items_all.system_linkage_function%TYPE;

BEGIN

   --dbms_output.put_line(' I am in CALC RATE AMOUNT ');

  IF g1_debug_mode  = 'Y' THEN
   PA_DEBUG.Set_Curr_Function( p_function   => 'Calc Rate Amount');
   PA_DEBUG.g_err_stage := 'RT40 : Entering PA_RATE_PVT_PKG.Calc_Rate_Amount';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  END IF;

   x_return_status     :=  FND_API.G_RET_STS_SUCCESS;
  IF g1_debug_mode  = 'Y' THEN
   PA_DEBUG.g_err_stage := 'RTS1 : Checking tab count '||TO_CHAR(NVL(p_rate_calc_date_tab.count,0));
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);


   PA_DEBUG.g_err_stage := ' Rate CALC Amt : Inside API project id '||p_project_id||' Item Id '||p_item_id;
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  END IF;

   IF ((p_rate_calc_date_tab.count) >= 1 ) THEN
       --dbms_output.put_line(' First : '||p_rate_calc_date_tab.FIRST);
       --dbms_output.put_line(' Last : '||p_rate_calc_date_tab.LAST);
       --dbms_output.put_line(' count : '||p_rate_calc_date_tab.count);

     FOR l_J IN p_rate_calc_date_tab.FIRST..p_rate_calc_date_tab.LAST LOOP
       /* If the passed table does not have the specific index then inserting null at that possition
          so that other part of code should not execute for Org Forecasting */
       IF (p_rate_calc_date_tab.EXISTS(l_j)) THEN
         l_rate_calc_date_tab(l_j)  := p_rate_calc_date_tab(l_j);
       ELSE
          l_rate_calc_date_tab(l_j)  := NULL;
       END IF;
      END LOOP;

      FOR l_J IN l_rate_calc_date_tab.FIRST..l_rate_calc_date_tab.LAST LOOP

         -- dbms_output.put_line(' step 1 '||l_J);
       IF (l_rate_calc_date_tab(l_J) IS NOT NULL ) THEN /* { IF index in between is missing, then not calling  for Org Forecasting */

         -- dbms_output.put_line(' step 2 '||l_J);
       ----------------------------------------------------------------------------------------
       -- Assigning pl/sql table varibles to local varible and nulling out the OUT
       -- pl/sql table varibles
       -----------------------------------------------------------------------------------------

       /*                               Project Functional currency                                              */

       l_projfunc_rev_rt_dt_code            :=  p_projfunc_rev_rt_dt_code_tab(l_J); /* Added for Org Forecasting */
       l_projfunc_rev_rt_date               :=  p_projfunc_rev_rt_date_tab(l_J);    /* Added for Org Forecasting */
       l_projfunc_rev_rt_type               :=  p_projfunc_rev_rt_type_tab(l_J);    /* Added for Org Forecasting */
       l_projfunc_rev_exch_rt               :=  p_projfunc_rev_exch_rt_tab(l_J);    /* Added for Org Forecasting */

       l_projfunc_cst_rt_date               :=  p_projfunc_cst_rt_date_tab(l_J);    /* Added for Org Forecasting */
       l_projfunc_cst_rt_type               :=  p_projfunc_cst_rt_type_tab(l_J);    /* Added for Org Forecasting */

       x_projfunc_bill_rt_tab(l_J)          := 0;
       x_projfunc_raw_revenue_tab(l_J)      := 0;

       x_projfunc_rev_rt_date_tab(l_J)      := l_projfunc_rev_rt_date;   /* Added for org Forecasting */
       x_projfunc_rev_rt_type_tab(l_J)      := l_projfunc_rev_rt_type;   /* Added for org Forecasting */
       x_projfunc_rev_exch_rt_tab(l_J)      := l_projfunc_rev_exch_rt;   /* Added for org Forecasting */

       x_projfunc_raw_cst_tab(l_J)          := 0;
       x_projfunc_raw_cst_rt_tab(l_J)       := 0;
       x_projfunc_burdned_cst_tab(l_J)      := 0;
       x_projfunc_burdned_cst_rt_tab(l_J)   := 0;

       x_projfunc_cst_rt_date_tab(l_J)      := l_projfunc_cst_rt_date;   /* Added for org Forecasting */
       x_projfunc_cst_rt_type_tab(l_J)      := l_projfunc_cst_rt_type;   /* Added for org Forecasting */
       x_projfunc_cst_exch_rt_tab(l_J)      := l_projfunc_cst_exch_rt;   /* Added for org Forecasting */

       /*                               Project currency                                                   */

       l_project_rev_rt_dt_code            :=  p_project_rev_rt_dt_code_tab(l_J); /* Added for Org Forecasting */
       l_project_rev_rt_date               :=  p_project_rev_rt_date_tab(l_J);    /* Added for Org Forecasting */
       l_project_rev_rt_type               :=  p_project_rev_rt_type_tab(l_J);    /* Added for Org Forecasting */
       l_project_rev_exch_rt               :=  p_project_rev_exch_rt_tab(l_J);    /* Added for Org Forecasting */

       l_project_cst_rt_date               :=  p_project_cst_rt_date_tab(l_J);    /* Added for Org Forecasting */
       l_project_cst_rt_type               :=  p_project_cst_rt_type_tab(l_J);    /* Added for Org Forecasting */

       x_project_bill_rt_tab(l_J)          := 0;
       x_project_raw_revenue_tab(l_J)      := 0;

       x_project_rev_rt_date_tab(l_J)      := l_project_rev_rt_date;   /* Added for org Forecasting */
       x_project_rev_rt_type_tab(l_J)      := l_project_rev_rt_type;   /* Added for org Forecasting */
       x_project_rev_exch_rt_tab(l_J)      := l_project_rev_exch_rt;   /* Added for org Forecasting */

       x_project_raw_cst_tab(l_J)          := 0;
       x_project_raw_cst_rt_tab(l_J)       := 0;
       x_project_burdned_cst_tab(l_J)      := 0;
       x_project_burdned_cst_rt_tab(l_J)   := 0;

       x_project_cst_rt_date_tab(l_J)      := l_project_cst_rt_date;   /* Added for org Forecasting */
       x_project_cst_rt_type_tab(l_J)      := l_project_cst_rt_type;   /* Added for org Forecasting */
       x_project_cst_exch_rt_tab(l_J)      := l_project_cst_exch_rt;   /* Added for org Forecasting */

       -- dbms_output.put_line(' CALL CALC AMT EXCH RATE BEFORE PASSING : '||' rev_exch_rt '||l_project_rev_exch_rt||' _project_cst_exch_rt ' ||l_project_cst_exch_rt);

       /*                               Expenditure Functional currency                                  */

        l_system_linkage                    :=    P_system_linkage(l_J);

        x_exp_func_curr_code_tab(l_J)       :=    l_exp_func_curr_code;    /* Added for Org Forecasting */
        x_exp_func_cst_rt_date_tab(l_J)     :=    l_exp_func_cst_rt_date;  /* Added for Org Forecasting */
        x_exp_func_cst_rt_type_tab(l_J)     :=    l_exp_func_cst_rt_type;  /* Added for Org Forecasting */
        x_exp_func_cst_exch_rt_tab(l_J)     :=    l_exp_func_cst_exch_rt;  /* Added for Org Forecasting */

        x_exp_func_raw_cst_rt_tab(l_J)      :=    0;
        x_exp_func_raw_cst_tab(l_J)         :=    0;
        x_exp_func_burdned_cst_rt_tab(l_J)  :=    0;
        x_exp_func_burdned_cst_tab(l_J)     :=    0;


       /*                               Transactional currency                                  */

        x_cst_txn_curr_code_tab(l_J)        :=    l_cst_txn_curr_code; /* Added for Org Forecasting */
        x_txn_raw_cst_rt_tab(l_J)           :=    0;
        x_txn_raw_cst_tab(l_J)              :=    0;
        x_txn_burdned_cst_rt_tab(l_J)       :=    0;
        x_txn_burdned_cst_tab(l_J)          :=    0;

        x_rev_txn_curr_code_tab(l_J)        :=    l_rev_txn_curr_code;    /* Added for Org Forecasting */
        x_txn_rev_bill_rt_tab(l_J)          :=    0;      /* Added for Org Forecasting */
        x_txn_rev_raw_revenue_tab(l_J)      :=    0;  /* Added for Org Forecasting */

        x_rev_rejct_reason_tab(l_J)         := NULL;
        x_cst_rejct_reason_tab(l_J)         := NULL;
        x_burdned_rejct_reason_tab(l_J)     := NULL;
        x_others_rejct_reason_tab(l_J)      := NULL;

       IF (x_others_rejct_reason_tab(l_J) IS NULL ) THEN /* Added for Org Forecasting , Added if got error from
                                                     calling api { */

         -- dbms_output.put_line(' step 3 '||l_J);

          IF ( (p_calling_mode = 'ASSIGNMENT') OR (p_calling_mode = 'ROLE') )  THEN /* added for bug 2425570 */
            IF ( p_forecasting_type = 'PROJECT_FORECASTING') THEN /* Added this if for Org Forecasting */
               IF ( l_rate_calc_date_tab(1) >= p_asgn_start_date ) THEN
                  null;
               ELSE
                  l_rate_calc_date_tab(1) := p_asgn_start_date;
               END IF;
            END IF;
         END IF;

         -- dbms_output.put_line('Index '||l_J);
         -- dbms_output.put_line('l_rate_calc_date_tab '||l_rate_calc_date_tab(l_J));
         -- dbms_output.put_line('p_quantity_tab '||p_quantity_tab(l_J));
         -- dbms_output.put_line('p_expenditure_org_id_tab '||p_expenditure_org_id_tab(l_J));
         -- dbms_output.put_line('p_expenditure_orgz_id_tab '||p_expenditure_orgz_id_tab(l_J));
         -- dbms_output.put_line('p_forecast_item_id_tab '||p_forecast_item_id_tab(l_J));

         l_rate_calc_date               := l_rate_calc_date_tab(l_J);
         l_quantity                     := p_quantity_tab(l_J);
         l_expenditure_org_id           := p_expenditure_org_id_tab(l_J);
         l_expenditure_orgz_id          := p_expenditure_orgz_id_tab(l_J);
         l_forecast_item_id             := p_forecast_item_id_tab(l_J); /* added for bug 2212852 */

       IF g1_debug_mode  = 'Y' THEN
         PA_DEBUG.g_err_stage := 'RT41 : Entering PA_RATE_PVT_PKG.get_item_amount';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         PA_DEBUG.g_err_stage := 'prj type: '||p_project_type||' prj id:'||p_project_id;
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;

         -- dbms_output.put_line('before calling Get Item AMount the index is : '||l_J);
         PA_RATE_PVT_PKG.get_item_amount(
                  p_calling_mode                  => p_calling_mode                      ,
                  p_rate_calc_date                => l_rate_calc_date                    ,
                  p_item_id                       => p_item_id                           ,
                  p_project_id                    => p_project_id                        ,
                  p_quantity                      => l_quantity                          ,
                  p_forecast_job_id               => p_forecast_job_id                   ,
                  p_forecast_job_group_id         => p_forecast_job_group_id             ,
                  p_person_id                     => p_person_id                         ,
                  p_expenditure_org_id            => l_expenditure_org_id                ,
                  p_expenditure_type              => p_expenditure_type                  ,
                  p_expenditure_organization_id   => l_expenditure_orgz_id               ,
                  p_project_org_id                => p_project_org_id                    ,
                  p_labor_cost_multi_name         => p_labor_cost_multi_name             ,
                  p_expenditure_currency_code     => NULL                                ,
                  p_proj_cost_job_group_id        => p_proj_cost_job_group_id            ,
                  p_job_cost_rate_schedule_id     => p_job_cost_rate_schedule_id         ,
                  p_project_type                  => p_project_type                      ,
                  p_task_id                       => p_task_id                           ,
                  p_bill_rate_multiplier          => p_bill_rate_multiplier              ,
                  p_project_bill_job_group_id     => p_project_bill_job_group_id         ,
                  p_emp_bill_rate_schedule_id     => p_emp_bill_rate_schedule_id         ,
                  p_job_bill_rate_schedule_id     => p_job_bill_rate_schedule_id         ,
                  p_distribution_rule             => p_distribution_rule                 ,
                  p_forecast_item_id              => l_forecast_item_id, /* Added for bug 2212852 */
                  p_forecasting_type              => p_forecasting_type, /* Added for bug 2212852 */
                  p_amount_calc_mode              => p_amount_calc_mode, /* Added for Org Forcasting */
                  p_system_linkage                => l_system_linkage, /* Added for Org Forcasting */
                  p_assign_precedes_task          => p_assign_precedes_task     , /* Added for Org Forcasting */
                  p_labor_schdl_discnt            => p_labor_schdl_discnt  ,      /* Added for Org Forcasting */
                  p_labor_bill_rate_org_id        => p_labor_bill_rate_org_id ,   /* Added for Org Forcasting */
                  p_labor_std_bill_rate_schdl     => p_labor_std_bill_rate_schdl ,/* Added for Org Forcasting */
                  p_labor_schedule_fixed_date     => p_labor_schedule_fixed_date ,/* Added for Org Forcasting */
                  p_labor_sch_type                => p_labor_sch_type      ,      /* Added for Org Forcasting */
                  p_projfunc_currency_code        => p_projfunc_currency_code , /* MCB2 change */
                  p_projfunc_rev_rt_dt_code       => l_projfunc_rev_rt_dt_code,
                  p_projfunc_rev_rt_date          => l_projfunc_rev_rt_date,     /* Added for Org Forecasting */
                  p_projfunc_rev_rt_type          => l_projfunc_rev_rt_type,     /* Added for Org Forecasting */
                  p_projfunc_rev_exch_rt          => l_projfunc_rev_exch_rt,     /* Added for Org Forecasting */
                  p_projfunc_cst_rt_date          => l_projfunc_cst_rt_date,     /* Added for Org Forecasting */
                  p_projfunc_cst_rt_type          => l_projfunc_cst_rt_type,     /* Added for Org Forecasting */
                  x_projfunc_bill_rate            => l_projfunc_bill_rate ,
                  x_projfunc_raw_revenue          => l_projfunc_raw_revenue ,
                  x_projfunc_rev_rt_date          => l_projfunc_rev_rt_date,     /* Added for org Forecasting */
                  x_projfunc_rev_rt_type          => l_projfunc_rev_rt_type,     /* Added for org Forecasting */
                  x_projfunc_rev_exch_rt          => l_projfunc_rev_exch_rt,     /* Added for org Forecasting */
                  x_projfunc_raw_cost             => l_projfunc_raw_cost                     ,
                  x_projfunc_raw_cost_rate        => l_projfunc_raw_cost_rate                ,
                  x_projfunc_burdened_cost        => l_projfunc_burdened_cost                ,
                  x_projfunc_burdened_cost_rate   => l_projfunc_burdened_cost_rate           ,
                  x_projfunc_cst_rt_date          => l_projfunc_cst_rt_date,     /* Added for org Forecasting */
                  x_projfunc_cst_rt_type          => l_projfunc_cst_rt_type,     /* Added for org Forecasting */
                  x_projfunc_cst_exch_rt          => l_projfunc_cst_exch_rt,     /* Added for org Forecasting */
                  p_project_currency_code         => p_project_currency_code,    /* Added for org Forecasting */
                  p_project_rev_rt_dt_code        => l_project_rev_rt_dt_code,   /* Added for org Forecasting */
                  p_project_rev_rt_date           => l_project_rev_rt_date,      /* Added for org Forecasting */
                  p_project_rev_rt_type           => l_project_rev_rt_type,      /* Added for org Forecasting */
                  p_project_rev_exch_rt           => l_project_rev_exch_rt,      /* Added for org Forecasting */
                  p_project_cst_rt_date           => l_project_cst_rt_date,      /* Added for org Forecasting */
                  p_project_cst_rt_type           => l_project_cst_rt_type,      /* Added for org Forecasting */
                  x_project_bill_rt               => l_project_bill_rate,        /* Added for org Forecasting */
                  x_project_raw_revenue           => l_project_raw_revenue,      /* Added for org Forecasting */
                  x_project_rev_rt_date           => l_project_rev_rt_date,      /* Added for org Forecasting */
                  x_project_rev_rt_type           => l_project_rev_rt_type,      /* Added for org Forecasting */
                  x_project_rev_exch_rt           => l_project_rev_exch_rt,      /* Added for org Forecasting */
                  x_project_raw_cst               => l_project_raw_cost,         /* Added for org Forecasting */
                  x_project_raw_cst_rt            => l_project_raw_cost_rate,    /* Added for org Forecasting */
                  x_project_burdned_cst           => l_project_burdened_cost,    /* Added for org Forecasting */
                  x_project_burdned_cst_rt        => l_project_burdened_cost_rate,   /* Added for org Forecasting */
                  x_project_cst_rt_date           => l_project_cst_rt_date,          /* Added for org Forecasting */
                  x_project_cst_rt_type           => l_project_cst_rt_type,          /* Added for org Forecasting */
                  x_project_cst_exch_rt           => l_project_cst_exch_rt,          /* Added for org Forecasting */
                  x_exp_func_curr_code            => l_exp_func_curr_code,           /* Added for Org Forecasting */
                  x_exp_func_raw_cost_rate        => l_exp_func_raw_cost_rate            ,
                  x_exp_func_raw_cost             => l_exp_func_raw_cost                 ,
                  x_exp_func_burdened_cost_rate   => l_exp_func_burdened_cost_rate       ,
                  x_exp_func_burdened_cost        => l_exp_func_burdened_cost            ,
                  x_exp_func_cst_rt_date          => l_exp_func_cst_rt_date,         /* Added for org Forecasting */
                  x_exp_func_cst_rt_type          => l_exp_func_cst_rt_type,         /* Added for org Forecasting */
                  x_exp_func_cst_exch_rt          => l_exp_func_cst_exch_rt,         /* Added for org Forecasting */
                  x_cst_txn_curr_code             => l_cst_txn_curr_code,            /* Added for Org Forecasting */
                  x_txn_raw_cst_rt                => l_txn_raw_cst_rt ,
                  x_txn_raw_cst                   => l_txn_raw_cst,
                  x_txn_burdned_cst_rt            => l_txn_burdned_cst_rt,
                  x_txn_burdned_cst               => l_txn_burdned_cst,
                  x_rev_txn_curr_code             => l_rev_txn_curr_code,     /* Added for Org Forecasting */
                  x_txn_rev_bill_rt               => l_txn_rev_bill_rt,       /* Added for org Forecasting */
                  x_txn_rev_raw_revenue           => l_txn_rev_raw_revenue,   /* Added for org Forecasting */
                  x_error_msg                     => l_error_msg                         ,
                  x_rev_rejct_reason              => l_rev_rejct_reason                  ,
                  x_cost_rejct_reason             => l_cost_rejct_reason                 ,
                  x_burdened_rejct_reason         => l_burdened_rejct_reason             ,
                  x_others_rejct_reason           => l_others_rejct_reason               ,
                  x_return_status                 => l_return_status                     ,
                  x_msg_count                     => x_msg_count                         ,
                  x_msg_data                      => x_msg_data                          );

      IF g1_debug_mode  = 'Y' THEN
         PA_DEBUG.g_err_stage := 'RT42 : Leaving PA_RATE_PVT_PKG.get_item_amount';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         PA_DEBUG.g_err_stage := 'err msg '||substr(l_error_msg,1,300);
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         PA_DEBUG.g_err_stage := 'ret sts '||l_return_status||' rrr '||l_rev_rejct_reason||' crr '||l_cost_rejct_reason||' brr '||l_burdened_rejct_reason||' orr '||l_others_rejct_reason;
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         PA_DEBUG.g_err_stage := 'msg cnt '||x_msg_count||' err msg '||substr(x_msg_data,1,300);
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

   -- dbms_output.put_line(' I am in CALC RATE AMOUNT  end of get_item_amount :  '||l_J);
   -- dbms_output.put_line(' I am in CALC RATE AMOUNT  end of get_item_amount l_cost_rejct_reason :  '||l_J||l_cost_rejct_reason);
       ----------------------------------------------------------------------------------------
       -- Assigning back local varibles to pl/sql tables
       -----------------------------------------------------------------------------------------

       /*                               Project Functional currency                                              */


       x_projfunc_bill_rt_tab(l_J)          := l_projfunc_bill_rate;
       x_projfunc_raw_revenue_tab(l_J)      := l_projfunc_raw_revenue;

       x_projfunc_rev_rt_date_tab(l_J)      := l_projfunc_rev_rt_date;   /* Added for org Forecasting */
       x_projfunc_rev_rt_type_tab(l_J)      := l_projfunc_rev_rt_type;   /* Added for org Forecasting */
       x_projfunc_rev_exch_rt_tab(l_J)      := l_projfunc_rev_exch_rt;   /* Added for org Forecasting */

       x_projfunc_raw_cst_tab(l_J)          := l_projfunc_raw_cost;
       x_projfunc_raw_cst_rt_tab(l_J)       := l_projfunc_raw_cost_rate;
       x_projfunc_burdned_cst_tab(l_J)      := l_projfunc_burdened_cost;
       x_projfunc_burdned_cst_rt_tab(l_J)   := l_projfunc_burdened_cost_rate;

       x_projfunc_cst_rt_date_tab(l_J)      := l_projfunc_cst_rt_date;   /* Added for org Forecasting */
       x_projfunc_cst_rt_type_tab(l_J)      := l_projfunc_cst_rt_type;   /* Added for org Forecasting */
       x_projfunc_cst_exch_rt_tab(l_J)      := l_projfunc_cst_exch_rt;   /* Added for org Forecasting */

         --dbms_output.put_line(' I am in CALC RATE AMOUNT PROJ FUNC : '||'projfunc bill : '||x_projfunc_bill_rt_tab(l_J)
-- ||'projfunc revenue : '||x_projfunc_raw_revenue_tab(l_J)||' projfunc cost : '||x_projfunc_raw_cst_tab(l_J)||' burden cost :'||x_projfunc_burdned_cst_tab(l_J));

       /*                               Project currency                                                   */

       x_project_bill_rt_tab(l_J)          := l_project_bill_rate;
       x_project_raw_revenue_tab(l_J)      := l_project_raw_revenue;

       x_project_rev_rt_date_tab(l_J)      := l_project_rev_rt_date;   /* Added for org Forecasting */
       x_project_rev_rt_type_tab(l_J)      := l_project_rev_rt_type;   /* Added for org Forecasting */
       x_project_rev_exch_rt_tab(l_J)      := l_project_rev_exch_rt;   /* Added for org Forecasting */

       x_project_raw_cst_tab(l_J)          := l_project_raw_cost;
       x_project_raw_cst_rt_tab(l_J)       := l_project_raw_cost_rate;
       x_project_burdned_cst_tab(l_J)      := l_project_burdened_cost;
       x_project_burdned_cst_rt_tab(l_J)   := l_project_burdened_cost_rate;

       x_project_cst_rt_date_tab(l_J)      := l_project_cst_rt_date;   /* Added for org Forecasting */
       x_project_cst_rt_type_tab(l_J)      := l_project_cst_rt_type;   /* Added for org Forecasting */
       x_project_cst_exch_rt_tab(l_J)      := l_project_cst_exch_rt;   /* Added for org Forecasting */

--         dbms_output.put_line(' I am in CALC RATE AMOUNT PROJ : '||'proj bill : '||x_project_bill_rt_tab(l_J)
-- ||'proj revenue : '||x_project_raw_revenue_tab(l_J)||' proj cost : '||x_project_raw_cst_tab(l_J)||'proj cost exch rate '||NVL(l_project_cst_exch_rt,-99)||' proj burden cost :'||x_project_burdned_cst_tab(l_J));

         -- dbms_output.put_line(' I am in CALC RATE AMOUNT PROJ RATES : '||'proj bill : '||x_project_bill_rt_tab(l_J)
--  ||'proj rev_exch_rt : '||x_project_rev_exch_rt_tab(l_J)||' proj raw_cst_rt : '||x_project_raw_cst_rt_tab(l_J)||'proj burdned_cst_rt '||x_project_burdned_cst_rt_tab(l_J)||' project_cst_exch_rt '||x_project_cst_exch_rt_tab(l_J));

       /*                               Expenditure Functional currency                                  */

        x_exp_func_curr_code_tab(l_J)       :=    l_exp_func_curr_code;    /* Added for Org Forecasting */
        x_exp_func_cst_rt_date_tab(l_J)     :=    l_exp_func_cst_rt_date;  /* Added for Org Forecasting */
        x_exp_func_cst_rt_type_tab(l_J)     :=    l_exp_func_cst_rt_type;  /* Added for Org Forecasting */
        x_exp_func_cst_exch_rt_tab(l_J)     :=    l_exp_func_cst_exch_rt;  /* Added for Org Forecasting */

        x_exp_func_raw_cst_rt_tab(l_J)      :=    l_exp_func_raw_cost_rate;
        x_exp_func_raw_cst_tab(l_J)         :=    l_exp_func_raw_cost;
        x_exp_func_burdned_cst_rt_tab(l_J)  :=    l_exp_func_burdened_cost_rate;
        x_exp_func_burdned_cst_tab(l_J)     :=    l_exp_func_burdened_cost;


 --       dbms_output.put_line(' I am in CALC RATE AMOUNT EXP : '||' exp cost : '||x_exp_func_raw_cst_tab(l_J)||' exp burden cost :'||x_exp_func_burdned_cst_tab(l_J));

       /*                               Transactional currency                                  */

        x_cst_txn_curr_code_tab(l_J)        :=    l_cst_txn_curr_code; /* Added for Org Forecasting */
        x_txn_raw_cst_rt_tab(l_J)           :=    l_txn_raw_cst_rt;
        x_txn_raw_cst_tab(l_J)              :=    l_txn_raw_cst;
        x_txn_burdned_cst_rt_tab(l_J)       :=    l_txn_burdned_cst_rt;
        x_txn_burdned_cst_tab(l_J)          :=    l_txn_burdned_cst;

        x_rev_txn_curr_code_tab(l_J)        :=    l_rev_txn_curr_code;    /* Added for Org Forecasting */
        x_txn_rev_bill_rt_tab(l_J)          :=    l_txn_rev_bill_rt;      /* Added for Org Forecasting */
        x_txn_rev_raw_revenue_tab(l_J)      :=    l_txn_rev_raw_revenue;  /* Added for Org Forecasting */

        x_rev_rejct_reason_tab(l_J)         := l_rev_rejct_reason;
        x_cst_rejct_reason_tab(l_J)         := l_cost_rejct_reason;
        x_burdned_rejct_reason_tab(l_J)     := l_burdened_rejct_reason;
        x_others_rejct_reason_tab(l_J)      := l_others_rejct_reason;

        x_return_status                     := l_return_status;
        x_error_msg                         := l_error_msg;

        -- dbms_output.put_line(' I am in CALC RATE AMT ERROR : '||l_J ||x_cst_rejct_reason_tab(l_J));
        -- dbms_output.put_line(' I am in CALC RATE AMT ERROR 1 : '||l_J ||x_cst_rejct_reason_tab(l_J));
--        dbms_output.put_line(' I am in CALC RATE AMOUNT ERROR : '||'l_cost_rejct_reason : '||x_cst_rejct_reason_tab(l_J));
--        -- dbms_output.put_line(' I am in CALC RATE AMOUNT TXN : '||'txn bill : '||x_txn_rev_bill_rt_tab(l_J)||'txn revenue : '||x_txn_rev_raw_revenue_tab(l_J)||' txn cost : '||x_txn_raw_cst_tab(l_J)||' txn burden cost :'||x_txn_burdned_cst_tab(l_J));
         IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
             x_return_status  := l_return_status;
         END IF;
        END IF; /* End of other rejection if }*/
       END IF; /* } End of if date is null */
      END LOOP;
   ELSE
     -- DBMS_OUTPUT.PUT_LINE(' ERROR USER DEFINED ');
     RAISE NO_DATA_FOUND;
   END IF;  /* Ending of table of record check if */

        -- dbms_output.put_line(' I am in CALC RATE AMT ERROR END : ');

  IF g1_debug_mode  = 'Y' THEN
   PA_DEBUG.g_err_stage := 'RT43 : Leaving PA_RATE_PVT_PKG.calc rate amount';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   PA_DEBUG.Reset_Curr_Function;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
     IF g1_debug_mode  = 'Y' THEN
       PA_DEBUG.Reset_Curr_Function;
     END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_error_msg     := SUBSTR(SQLERRM,1,30);
      /* Checking error condition. Added for bug 2218386 */
      IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_RATE_PVT_PKG',
                                  p_procedure_name => 'Calc_Rate_Amount');
         RAISE;
      END IF;

END calc_rate_amount;



/* Added for performance bug 2691192, it replaces the use of view pa_rep_period_dates_v */

-- This procedure will display information about period types such as the name of the period
-- and the start and end dates.
-- Input parameters
-- Parameters                    Type           Required      Description
-- p_period_type                 VARCHAR2        YES          Period type
-- p_period_type                 DATE            YES          Schedule completion date
-- Out parameters
-- x_period_name                 VARCHAR2                    Period name
-- x_start_date                  DATE                        Start date of the period
-- x_end_datet                   DATE                        End date of the period
-- x_error_value                 VARCHAR2                    Error status
--

PROCEDURE get_rep_period_dates(
                                p_period_type                   IN     VARCHAR2 ,
                                p_completion_date               IN     DATE,
                                x_period_year                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_period_name                   OUT    NOCOPY gl_periods.period_name%TYPE, --File.Sql.39 bug 4440895
                                x_start_date                    OUT    NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_end_date                      OUT    NOCOPY DATE  , --File.Sql.39 bug 4440895
                                x_error_value                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                )
IS

   l_period_year               NUMBER;
   l_period_name               gl_periods.period_name%TYPE;
   l_start_date                DATE;
   l_end_date                  DATE;

BEGIN

  IF g1_debug_mode  = 'Y' THEN
   PA_DEBUG.Set_Curr_Function( p_function   => 'get_rep_period_dates ');
   PA_DEBUG.g_err_stage := 'RT 101 : Entering PA_RATE_PVT_PKG.get_rep_period_dates';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  END IF;

     x_error_value := 'NO_ERROR';

     IF (p_period_type = 'GL' ) THEN

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 102 : get_rep_period_dates-> Inside GL select prd typ '||p_period_type;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

         SELECT
                glper.period_year,
                glper.period_name,
                glper.start_date,
                glper.end_date
         INTO
               l_period_year,
               l_period_name,
               l_start_date,
               l_end_date
         FROM  pa_implementations imp,
               gl_sets_of_books gl,
               gl_periods glper,
               gl_period_statuses glpersts
         WHERE imp.set_of_books_id         = gl.set_of_books_id
         AND  gl.period_set_name          = glper.period_set_name
         AND  gl.accounted_period_type    = glper.period_type
         AND  glpersts.set_of_books_id    = gl.set_of_books_id
         AND  glpersts.period_type        = glper.period_type
         AND  glpersts.period_name        = glper.period_name
         AND  glpersts.period_year        = glper.period_year
         AND  glpersts.application_id     = PA_Period_Process_Pkg.Application_ID
         AND  p_completion_date BETWEEN glper.start_date AND glper.end_date
         AND  EXISTS ( SELECT NULL
                       FROM  gl_date_period_map glmaps
                       WHERE glmaps.period_type         = glper.period_type
                       AND  glmaps.period_name          = glper.period_name
                       AND  glmaps.period_set_name      = glper.period_set_name )
         AND  EXISTS ( SELECT NULL
                       FROM  gl_lookups prsts
                       WHERE prsts.lookup_code IN('C','F','N','O','P')
                       AND   prsts.lookup_type ='CLOSING_STATUS'
                       AND   glpersts.closing_status     = prsts.lookup_code);

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 103 : get_rep_period_dates-> Passed GL select prd nam '||l_period_name;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

     ELSIF (p_period_type = 'PA' ) THEN

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 104 : get_rep_period_dates-> Inside PA select prd typ '||p_period_type;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

            SELECT
                 glp.period_year
               , pap.period_name
               , pap.start_date
               , pap.end_date
          INTO
                l_period_year,
                l_period_name,
                l_start_date,
                l_end_date
          FROM  pa_periods pap,
                gl_period_statuses glp,
                pa_implementations paimp
          WHERE pap.gl_period_name = glp.period_name
          AND   glp.set_of_books_id = paimp.set_of_books_id
          AND   glp.application_id = Pa_Period_Process_Pkg.Application_id
          AND   glp.adjustment_period_flag = 'N'
          AND   p_completion_date BETWEEN pap.start_date and pap.end_date
          AND   EXISTS (SELECT NULL
                        FROM  pa_lookups pal
                        WHERE pal.lookup_type = 'CLOSING STATUS'
                        AND   pal.lookup_code =  pap.status);

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 104 : get_rep_period_dates-> Passed PA select prd nam '||l_period_name;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

     ELSIF (p_period_type = 'QR' ) THEN

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 105 : get_rep_period_dates-> Inside QR select prd typ '||p_period_type;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

          SELECT
                  period_yr
                , period_nam
                , start_dt
                , end_dt
          INTO
                l_period_year,
                l_period_name,
                l_start_date,
                l_end_date
          FROM (
                 SELECT
                        glper.period_year period_yr,
                        TO_CHAR(glper.quarter_num) period_nam,
                        MIN(glper.start_date) start_dt,
                        MAX(glper.end_date) end_dt
                 FROM   pa_implementations imp,
                        gl_sets_of_books gl,
                        gl_periods glper,
                        gl_period_statuses glpersts,
                        gl_date_period_map glmaps
                 WHERE  imp.set_of_books_id         = gl.set_of_books_id
                 AND    gl.period_set_name          = glper.period_set_name
                 AND    gl.accounted_period_type    = glper.period_type
                 AND    glpersts.set_of_books_id    = gl.set_of_books_id
                 AND    glpersts.period_type        = glper.period_type
                 AND    glpersts.period_name        = glper.period_name
                 AND    glpersts.period_year        = glper.period_year
                 AND    glmaps.period_type          = glper.period_type
                 AND    glmaps.period_name          = glper.period_name
                 AND    glmaps.period_set_name      = glper.period_set_name
                 AND    glpersts.application_id     = PA_Period_Process_Pkg.Application_ID
                 AND    EXISTS (SELECT null
                                FROM  gl_lookups prsts
                                WHERE prsts.lookup_code IN('C','F','N','O','P')
                                AND   prsts.lookup_type ='CLOSING_STATUS'
                                AND   glpersts.closing_status     = prsts.lookup_code)
                 GROUP BY glper.period_year,
                          glper.quarter_num
                )
          WHERE p_completion_date BETWEEN start_dt AND end_dt;

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 106 : get_rep_period_dates-> Passed QR select prd nam '||l_period_name;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

     ELSIF (p_period_type = 'YR' ) THEN

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 107 : get_rep_period_dates-> Inside YR select prd typ '||p_period_type;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

          SELECT
                  period_yr
                , period_nam
                , start_dt
                , end_dt
          INTO
                l_period_year,
                l_period_name,
                l_start_date,
                l_end_date
          FROM (
                 SELECT
                        glper.period_year period_yr,
                        TO_CHAR(glper.period_year) period_nam,
                        MIN(glper.start_date) start_dt,
                        MAX(glper.end_date) end_dt
                 FROM  pa_implementations imp,
                       gl_sets_of_books gl,
                       gl_periods glper,
                       gl_period_statuses glpersts,
                       gl_date_period_map glmaps
                 WHERE imp.set_of_books_id        = gl.set_of_books_id
                 AND  gl.period_set_name          = glper.period_set_name
                 AND  gl.accounted_period_type    = glper.period_type
                 AND  glpersts.set_of_books_id    = gl.set_of_books_id
                 AND  glpersts.period_type        = glper.period_type
                 AND  glpersts.period_name        = glper.period_name
                 AND  glpersts.period_year        = glper.period_year
                 AND  glmaps.period_type          = glper.period_type
                 AND  glmaps.period_name          = glper.period_name
                 AND  glmaps.period_set_name      = glper.period_set_name
                 AND  glpersts.application_id     = PA_Period_Process_Pkg.Application_ID
                 AND    EXISTS (SELECT null
                                FROM  gl_lookups prsts
                                WHERE prsts.lookup_code IN('C','F','N','O','P')
                                AND   prsts.lookup_type ='CLOSING_STATUS'
                                AND   glpersts.closing_status     = prsts.lookup_code)
                 GROUP BY glper.period_year
                  )
          WHERE p_completion_date BETWEEN start_dt AND end_dt;

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 108 : get_rep_period_dates-> Passed YR select prd nam '||l_period_name;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

     ELSIF (p_period_type = 'GE' ) THEN

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 109 : get_rep_period_dates-> Inside GE select prd typ '||p_period_type;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

          SELECT
                 period_yr
               , period_nam
               , start_dt
               , end_dt
          INTO
                l_period_year,
                l_period_name,
                l_start_date,
                l_end_date
          FROM (
                 SELECT
                  period_year period_yr,
                  TO_CHAR((NEXT_DAY(TO_DATE('01/01/'||TO_CHAR(period_Year),'MM/DD/YYYY'),
                    TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY'))) -1 ) + (seq_number-1) * 7) period_nam,
                 ( ((NEXT_DAY(TO_DATE('01/01/'||TO_CHAR(period_Year),'MM/DD/YYYY'),
                TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY'))) -1 ) + (seq_number-1) * 7) - 6 ) start_dt,
                 ( (NEXT_DAY(TO_DATE('01/01/'||TO_CHAR(period_Year),'MM/DD/YYYY'),
                    TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY'))) -1 ) + (seq_number-1) * 7 ) end_dt
               FROM pa_rep_year_cal_v,
                    pa_rep_seq_number
               WHERE seq_number BETWEEN 1 AND 53
               )
          WHERE p_completion_date BETWEEN start_dt AND end_dt;

        IF g1_debug_mode  = 'Y' THEN
           PA_DEBUG.g_err_stage := 'RT 110 : get_rep_period_dates-> Passed GE select prd nam '||l_period_name;
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

     END IF;

     x_period_year  :=    l_period_year;
     x_period_name  :=    l_period_name;
     x_start_date   :=    l_start_date;
     x_end_date     :=    l_end_date;

  IF g1_debug_mode  = 'Y' THEN
   PA_DEBUG.g_err_stage := 'RT 111 : Leaving PA_RATE_PVT_PKG.get_rep_period_dates';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   PA_DEBUG.Reset_Curr_Function;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
    x_error_value := 'NO_DATA_FOUND';
    IF g1_debug_mode  = 'Y' THEN
     PA_DEBUG.Reset_Curr_Function;
    END IF;
    NULL;
   WHEN TOO_MANY_ROWS THEN
    x_error_value := 'TOO_MANY_ROWS';
    IF g1_debug_mode  = 'Y' THEN
     PA_DEBUG.Reset_Curr_Function;
    END IF;
    NULL;
   WHEN OTHERS THEN
      IF g1_debug_mode  = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
      END IF;

    /* ATG Changes */

     x_period_name := null;
     x_start_date  := null;
     x_end_date    := null;

      IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_RATE_PVT_PKG',
                                  p_procedure_name => 'get_rep_period_dates');
         RAISE;
      END IF;

END get_rep_period_dates;


END PA_RATE_PVT_PKG;


/
