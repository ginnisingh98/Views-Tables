--------------------------------------------------------
--  DDL for Package PA_REVENUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REVENUE" AUTHID CURRENT_USER as
/* $Header: PAXBLRTS.pls 120.1 2005/08/19 17:09:37 mwasowic noship $ */

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
         p_item_id                   IN     NUMBER DEFAULT NULL, /* change from forecast item id */
                                                                 /* to item id for bug 2212852 */
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
         x_markup_percentage         OUT    NOCOPY NUMBER,/* Added for Asgmt overide */ --File.Sql.39 bug 4440895
         x_txn_currency_code         OUT    NOCOPY VARCHAR2, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
         x_return_status             OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_msg_data                  OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



--
-- Procedure            : Requirement_Rev_Amt
-- Purpose              : This procedure will calculate the  bill rate and raw revenue from one of
--                        the given criteria's on the basis of passed parameters
-- Parameters           :
--


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
      x_markup_percentage            OUT    NOCOPY NUMBER,/* Added for Asgmt overide */ --File.Sql.39 bug 4440895
      x_txn_currency_code            OUT    NOCOPY VARCHAR2,/*Added for Org Forecasting */ --File.Sql.39 bug 4440895
      x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      /*Bill rate Discount */
      p_mcb_flag                     IN     VARCHAR2 DEFAULT NULL,
      p_denom_raw_cost               IN     NUMBER   DEFAULT NULL,
      p_denom_curr_code              IN     VARCHAR2  DEFAULT NULL,
      p_called_process               IN     VARCHAR2  DEFAULT NULL,
      p_job_bill_rate_schedule_id    IN     NUMBER      DEFAULT NULL,
   /* Added for bug 2668753 */
      p_project_raw_cost             IN     NUMBER    DEFAULT NULL,
      p_project_currency_code        IN     VARCHAR2  DEFAULT NULL,
      x_adjusted_bill_rate           OUT    NOCOPY NUMBER); --File.Sql.39 bug 4440895



--
-- Procedure            : Assignment_Rev_Amt
-- Purpose              :This procedure will calculate the raw revenue and bill amount from one of the 12
--                       criterias on the basis of passed parameters
-- Parameters           :
--

/* New proc added for Org Forecasting */
PROCEDURE  Get_Converted_Revenue_Amounts(
              p_item_date                    IN      DATE,
              px_txn_curr_code               IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              px_txn_raw_revenue             IN  OUT NOCOPY NUMBER,   --File.Sql.39 bug 4440895
              px_txn_bill_rate               IN  OUT NOCOPY NUMBER,   --File.Sql.39 bug 4440895
              px_projfunc_curr_code          IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              p_projfunc_bil_rate_date_code  IN      VARCHAR2,
              px_projfunc_bil_rate_type      IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              px_projfunc_bil_rate_date      IN  OUT NOCOPY DATE,     --File.Sql.39 bug 4440895
              px_projfunc_bil_exchange_rate  IN  OUT NOCOPY NUMBER,   --File.Sql.39 bug 4440895
              px_projfunc_raw_revenue        IN  OUT NOCOPY NUMBER ,  --File.Sql.39 bug 4440895
              px_projfunc_bill_rate          IN  OUT NOCOPY NUMBER ,  --File.Sql.39 bug 4440895
              px_project_curr_code           IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              p_project_bil_rate_date_code   IN      VARCHAR2,
              px_project_bil_rate_type       IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              px_project_bil_rate_date       IN  OUT NOCOPY DATE,     --File.Sql.39 bug 4440895
              px_project_bil_exchange_rate   IN  OUT NOCOPY NUMBER,   --File.Sql.39 bug 4440895
              px_project_raw_revenue         IN  OUT NOCOPY NUMBER ,  --File.Sql.39 bug 4440895
              px_project_bill_rate           IN  OUT NOCOPY NUMBER ,  --File.Sql.39 bug 4440895
              x_return_status                OUT     NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
              x_msg_count                    OUT     NOCOPY NUMBER    , --File.Sql.39 bug 4440895
              x_msg_data                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              );


--
-- Procedure            : Get_Converted_Revenue_Amounts
-- Purpose              :This procedure will convert the transaction amounts in Project,and Project Functional
-- Parameters           :
--

/*Bill rate discount */
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

  );



END PA_REVENUE;


 

/
