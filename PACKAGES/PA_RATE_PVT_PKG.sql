--------------------------------------------------------
--  DDL for Package PA_RATE_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RATE_PVT_PKG" AUTHID CURRENT_USER as
/* $Header: PAXRTPVS.pls 120.1 2005/08/19 17:19:38 mwasowic noship $ */


TYPE ProjAmt_Record IS RECORD (  period_name           pa_rep_period_dates_v.period_name%TYPE,
                                 Amount                NUMBER,
                                 start_date            pa_rep_period_dates_v.start_date%TYPE,
                                 end_date              pa_rep_period_dates_v.end_date%TYPE);

TYPE ProjAmt_TabTyp IS TABLE OF ProjAmt_Record INDEX BY BINARY_INTEGER;

/* Declaring global varible , which is going to be used to check whether the error from
    Rate api is going to be added into the stack or not.
   This is added for bug 2218386 */

   G_add_error_to_stack_flag          VARCHAR2(1);

/* Added 47 parameters for Org Forecasting */
/* Name changed from project to project functional for MCB2 */
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
        P_system_linkage                IN     pa_expenditure_items_all.system_linkage_function%TYPE,/* Added */
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
	x_projfunc_raw_cost             OUT    NOCOPY NUMBER,                             --File.Sql.39 bug 4440895
	x_projfunc_raw_cost_rate        OUT    NOCOPY NUMBER,                         --File.Sql.39 bug 4440895
	x_projfunc_burdened_cost        OUT    NOCOPY NUMBER,                     --File.Sql.39 bug 4440895
	x_projfunc_burdened_cost_rate   OUT    NOCOPY NUMBER,                --File.Sql.39 bug 4440895
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
	x_exp_func_raw_cost_rate        OUT    NOCOPY NUMBER,                --File.Sql.39 bug 4440895
	x_exp_func_raw_cost             OUT    NOCOPY NUMBER,                     --File.Sql.39 bug 4440895
	x_exp_func_burdened_cost_rate   OUT    NOCOPY NUMBER,                       --File.Sql.39 bug 4440895
	x_exp_func_burdened_cost        OUT    NOCOPY NUMBER,                              --File.Sql.39 bug 4440895
        x_exp_func_cst_rt_date          OUT    NOCOPY DATE,     /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_cst_rt_type          OUT    NOCOPY VARCHAR2, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_exp_func_cst_exch_rt          OUT    NOCOPY NUMBER,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
        x_cst_txn_curr_code             OUT    NOCOPY VARCHAR2, /* Added for Org Forecasting */ --File.Sql.39 bug 4440895
        x_txn_raw_cst_rt                OUT    NOCOPY NUMBER ,           --File.Sql.39 bug 4440895
        x_txn_raw_cst                   OUT    NOCOPY NUMBER,                        --File.Sql.39 bug 4440895
        x_txn_burdned_cst_rt            OUT    NOCOPY NUMBER,                       --File.Sql.39 bug 4440895
        x_txn_burdned_cst               OUT    NOCOPY NUMBER,                  --File.Sql.39 bug 4440895
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
	x_msg_data                      OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- Procedure            : get_item_amount
-- Purpose              : This procedure contains consolidated procedure and function to
--                        calculate the raw cost, burdened cost and raw revenue
-- Parameters           :
--

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
                                x_projfunc_revenue_tab          OUT    NOCOPY PA_RATE_PVT_PKG.ProjAmt_TabTyp); --File.Sql.39 bug 4440895


--
-- Procedure            : calc_event_based_revenue
-- Purpose              : This procedure will calculate the revenue for fixed price in event based rule.
-- Parameters           :
--


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
                                x_error_code                    OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- Procedure            : calc_cost_based_revenue
-- Purpose              : This procedure will calculate the revenue for fixed price in cost based rule.
-- Parameters           :
--

PROCEDURE get_revenue_generation_method( p_project_id IN NUMBER DEFAULT NULL,
                                        p_distribution_rule IN VARCHAR2 DEFAULT NULL,
                                        x_rev_gen_method    OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                                        x_error_msg         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
-- Procedure            : get_revenue_generation_method
-- Purpose              :This procedure will return that whta type of the project is this on the basis
--                       of passed project id
-- Parameters           :
--
/* Added 20 new parameters for Org Forecasting */
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
     x_msg_data                      OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- Procedure            : get_initial_bill_rate
-- Purpose              :This procedure will calculate the initial bill rate for Assignment and Requirement
-- Parameters           :
--
/* Added 47 new paramaters  Org Forecasting */
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
	p_amount_calc_mode             IN     VARCHAR2 DEFAULT 'ALL',/*Possible values 'ALL','COST','REVENUE' */
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
	x_projfunc_bill_rt_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,                --File.Sql.39 bug 4440895
	x_projfunc_raw_revenue_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,              --File.Sql.39 bug 4440895
	x_projfunc_rev_rt_date_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.DateTabTyp,   /* Added for org Forecasting */ --File.Sql.39 bug 4440895
	x_projfunc_rev_rt_type_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for org Forecasting */ --File.Sql.39 bug 4440895
	x_projfunc_rev_exch_rt_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,    /* Added for org Forecasting */ --File.Sql.39 bug 4440895
	x_projfunc_raw_cst_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,          --File.Sql.39 bug 4440895
	x_projfunc_raw_cst_rt_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,            --File.Sql.39 bug 4440895
	x_projfunc_burdned_cst_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,                --File.Sql.39 bug 4440895
	x_projfunc_burdned_cst_rt_tab  OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,                  --File.Sql.39 bug 4440895
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
	x_exp_func_raw_cst_rt_tab      OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp ,                 --File.Sql.39 bug 4440895
	x_exp_func_raw_cst_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,                     --File.Sql.39 bug 4440895
	x_exp_func_burdned_cst_rt_tab  OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,                       --File.Sql.39 bug 4440895
	x_exp_func_burdned_cst_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,                        --File.Sql.39 bug 4440895
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
	x_error_msg                    OUT    NOCOPY VARCHAR2,                              --File.Sql.39 bug 4440895
	x_rev_rejct_reason_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,    --File.Sql.39 bug 4440895
	x_cst_rejct_reason_tab         OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,        --File.Sql.39 bug 4440895
	x_burdned_rejct_reason_tab     OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,         --File.Sql.39 bug 4440895
	x_others_rejct_reason_tab      IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,  /* Changed for Org Forecasting */ --File.Sql.39 bug 4440895
                                                                                /* from OUT to IN OUT */
        x_return_status                OUT    NOCOPY VARCHAR2,                                  --File.Sql.39 bug 4440895
	x_msg_count                    OUT    NOCOPY NUMBER,                                  --File.Sql.39 bug 4440895
	x_msg_data                     OUT    NOCOPY VARCHAR2);                                 --File.Sql.39 bug 4440895



--
-- Procedure            : calc_rate_amount
-- Purpose              : This procedure will calculate the bill rate for Assignment and Requirement for all period
-- Parameters           : Table of Record and Scalar
--


/* Added for performance bug 2691192, it replaces the use of view pa_rep_period_dates_v */
PROCEDURE get_rep_period_dates(
                                p_period_type                   IN     VARCHAR2 ,
                                p_completion_date               IN     DATE,
                                x_period_year                   OUT    NOCOPY NUMBER,    --File.Sql.39 bug 4440895
                                x_period_name                   OUT    NOCOPY gl_periods.period_name%TYPE,    --File.Sql.39 bug 4440895
                                x_start_date                    OUT    NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_end_date                      OUT    NOCOPY DATE  , --File.Sql.39 bug 4440895
                                x_error_value                   OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- Procedure            : get_rep_period_dates
-- Purpose              : This procedure will display information about period types such as the name of
--                        the period and the start and end dates.';
-- Parameters           :
--

END PA_RATE_PVT_PKG;


 

/
