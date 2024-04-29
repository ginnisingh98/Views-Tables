--------------------------------------------------------
--  DDL for Package PA_FORECAST_REVENUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_REVENUE" AUTHID CURRENT_USER as
/* $Header: PARFRTRS.pls 120.1 2005/08/19 16:52:26 mwasowic noship $ */

PROCEDURE Get_Rev_Amt                        ( p_project_id                IN     NUMBER,
                                               p_task_id                   IN     NUMBER    DEFAULT NULL,
                                               p_bill_rate_multiplier      IN     NUMBER    DEFAULT NULL,
                                               p_quantity                  IN     NUMBER,
                                               p_person_id                 IN     NUMBER,
                                               p_raw_cost                  IN     NUMBER    DEFAULT NULL,
                                               p_item_date                 IN     DATE,
                                               p_labor_schdl_discnt        IN     NUMBER    DEFAULT NULL,
                                               p_labor_bill_rate_org_id    IN     NUMBER    DEFAULT NULL,
                                               p_labor_std_bill_rate_schdl IN     VARCHAR2  DEFAULT NULL,
                                               p_labor_schdl_fixed_date    IN     DATE      DEFAULT NULL,
                                               p_bill_job_grp_id           IN     NUMBER    DEFAULT NULL,
                                               p_forecast_item_id          IN     NUMBER    DEFAULT NULL,
                                               p_labor_sch_type            IN     VARCHAR2  DEFAULT NULL,
                                               p_project_org_id            IN     NUMBER    DEFAULT NULL,
                                               p_project_type              IN     VARCHAR2  DEFAULT NULL,
                                               p_expenditure_type          IN     VARCHAR2  DEFAULT NULL ,
                                               p_exp_func_curr_code        IN     VARCHAR2  DEFAULT NULL,
                                               p_incurred_by_organz_id     IN     NUMBER    DEFAULT NULL,
                                               p_raw_cost_rate             IN     NUMBER    DEFAULT NULL,
                                               p_override_to_organz_id     IN     NUMBER    DEFAULT NULL,
                                               p_forecast_job_id              IN  NUMBER    DEFAULT NULL /* Required in case of Requirement, added for Assignment override */,
                                               p_forecast_job_group_id         IN NUMBER    DEFAULT NULL /* Required in case of Requirement , added for Assignment override */,
                                               p_expenditure_org_id            IN NUMBER    DEFAULT NULL /* Required in case of Requirement , added for Assignment override */ ,
                                               p_expenditure_organization_id   IN NUMBER   DEFAULT NULL /* Required in case of Requirement , added for Assignment override */,
                                               p_check_error_flag          IN     VARCHAR2  DEFAULT  'Y', /* added for bug 2218386 */

                                               x_bill_rate                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                               x_raw_revenue               OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                               x_rev_currency_code         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                               x_markup_percentage         OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                               x_return_status             OUT    NOCOPY VARCHAR2, /* added for Assignment override */ --File.Sql.39 bug 4440895
                                               x_msg_count                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                               x_msg_data                  OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
-- Procedure            : Get_Rev_Amt
-- Purpose              :This procedure will calculate the raw revenue and bill amount from one of the 12
--                       criterias on the basis of passed parameters
-- Parameters           :
--

END PA_FORECAST_REVENUE;

 

/
