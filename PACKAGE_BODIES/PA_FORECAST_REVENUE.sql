--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_REVENUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_REVENUE" as
/* $Header: PARFRTRB.pls 120.2 2006/06/30 23:36:09 lkan noship $ */

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
-- P_forecast_item_id           NUMBER          YES          Unique Identifier for forecast item used in client
--                                                           extension
-- P_labor_sch_type             VARCHAR2        NO           Labor schedule type
-- P_project_org_id             NUMBER          NO           Project Org ID
-- P_project_type               VARCHAR2        YES          Project Type
-- P_expenditure_type           VARCHAR2        YES          Expenditure Type
-- P_exp_func_curr_code         VARCHAR2        YES          Expenditure functional currency code
-- P_incurred_by_organz_id      NUMBER          YES          Incurred by organz id
-- P_raw_cost_rate              NUMBER          YES          Raw cost rate
-- P_override_to_organz_id      NUMBER          YES          Override to organz id
--
-- Out parameters
--
-- X_bill_rate                  NUMBER          YES
-- X_raw_revenue                NUMBER          YES
-- X_rev_currency_code          VARCHAR2        YES

PROCEDURE Get_Rev_Amt                        ( p_project_id                IN     NUMBER,
                                               p_task_id                   IN     NUMBER      DEFAULT NULL,
                                               p_bill_rate_multiplier      IN     NUMBER      DEFAULT NULL,
                                               p_quantity                  IN     NUMBER,
                                               p_person_id                 IN     NUMBER,
                                               p_raw_cost                  IN     NUMBER      DEFAULT NULL,
                                               p_item_date                 IN     DATE,
                                               p_labor_schdl_discnt        IN     NUMBER      DEFAULT NULL,
                                               p_labor_bill_rate_org_id    IN     NUMBER      DEFAULT NULL,
                                               p_labor_std_bill_rate_schdl IN     VARCHAR2    DEFAULT NULL,
                                               p_labor_schdl_fixed_date    IN     DATE        DEFAULT NULL,
                                               p_bill_job_grp_id           IN     NUMBER      DEFAULT NULL,
                                               p_forecast_item_id          IN     NUMBER      DEFAULT NULL,
                                               p_labor_sch_type            IN     VARCHAR2    DEFAULT NULL,
                                               p_project_org_id            IN     NUMBER      DEFAULT NULL,
                                               p_project_type              IN     VARCHAR2    DEFAULT NULL,
                                               p_expenditure_type          IN     VARCHAR2    DEFAULT NULL,
                                               p_exp_func_curr_code        IN     VARCHAR2    DEFAULT NULL,
                                               p_incurred_by_organz_id     IN     NUMBER      DEFAULT NULL,
                                               p_raw_cost_rate             IN     NUMBER      DEFAULT NULL,
                                               p_override_to_organz_id     IN     NUMBER      DEFAULT NULL,
                                               p_forecast_job_id             IN  NUMBER    DEFAULT NULL /* Required in case of Requirement,added for Assignment override */,
                                               p_forecast_job_group_id       IN NUMBER    DEFAULT NULL /* Required in case of Requirement,added for Assignment override */,
                                               p_expenditure_org_id           IN NUMBER    DEFAULT NULL /* Required in case of Requirement,added for Assignment override */ ,
                                               p_expenditure_organization_id   IN NUMBER   DEFAULT NULL /* Required in case of Requirement,added for Assignment override */,
                                               p_check_error_flag          IN     VARCHAR2      DEFAULT  'Y', /* Added for bug 2218386 */
                                               x_bill_rate                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                               x_raw_revenue               OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                               x_rev_currency_code         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                               x_markup_percentage         OUT    NOCOPY NUMBER,/* Added for Assignment overridea */ --File.Sql.39 bug 4440895
                                               x_return_status             OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                               x_msg_count                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                               x_msg_data                  OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

   l_raw_revenue                    NUMBER;        -- It will be used to store the raw revenue
                                                   -- from one of the raw revenue calculating
                                                   -- criteria
   l_bill_rate                      NUMBER;        -- It will be used to store bill amount
                                                   -- from one of the bill amount calculating
                                                   -- criteria
   l_x_return_status                VARCHAR2(50);  -- It will be used to store the return status
                                                   -- and used it to validate whether the
                                                   -- calling procedure has run successfully
                                                   -- or encounter any error

  l_rev_currency_code               pa_projects_all.project_currency_code%TYPE; -- variable to store exp_func_curr_code
  l_x_msg_data                     VARCHAR2(30);
  l_x_msg_count                    NUMBER;
  l_x_markup_percentage            NUMBER;
  l_asgn_type                      VARCHAR2(1);
  l_exp_res_org_id                pa_project_assignments.expenditure_org_id%TYPE;
  l_exp_orgz_res_id               pa_project_assignments.expenditure_organization_id%TYPE;
  l_exp_type                      pa_project_assignments.expenditure_type%TYPE;
  l_org_id                        pa_projects_all.org_id%TYPE;

BEGIN

   -- Initializing return status with success sothat if some unexpected error comes
   -- , we change its status from succes to error sothat we can take necessary step to rectify the problem
   l_x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Assigning the check error condition . Added for bug 2218386 */
   PA_RATE_PVT_PKG.G_add_error_to_stack_flag := p_check_error_flag;

  IF ( p_person_id IS NULL ) THEN
    l_asgn_type   := 'R';
  ELSE
   l_asgn_type   := 'A';
  END IF;
  /* Selecting all the necessary inputs for this api */

   SELECT  org_id
   INTO    l_org_id
   FROM    pa_projects_all
   WHERE   project_id = p_project_id;

   SELECT  default_assign_exp_type
   INTO    l_exp_type
   FROM    pa_forecasting_options_all
   WHERE   org_id = l_org_id; /*Bug 5368295*/

   IF (l_asgn_type = 'A') THEN
     SELECT NVL(resource_org_id,-99),resource_organization_id
     INTO   l_exp_res_org_id,l_exp_orgz_res_id
     FROM pa_resources_denorm
     WHERE person_id    = p_person_id
     AND  ( p_item_date BETWEEN TRUNC(resource_effective_start_date) AND
               NVL(TRUNC(resource_effective_end_date),p_item_date));
   ELSIF (l_asgn_type = 'R') THEN
      l_exp_res_org_id  := p_expenditure_org_id;
      l_exp_orgz_res_id := p_expenditure_organization_id;
   END IF;

  /* Calling the new rate api, in this case because the forecast_item_id is null so it will
     not execute the assignment level override  */

   PA_RATE_PVT_PKG.get_initial_bill_rate(
                           p_assignment_type               =>    l_asgn_type         ,
                           p_asgn_start_date               =>    p_item_date         ,
                           p_project_id                    =>    p_project_id        ,
                           p_quantity                      =>    1                   ,
                           p_expenditure_org_id            =>    l_exp_res_org_id    ,
                           p_expenditure_type              =>    l_exp_type          ,
                           p_expenditure_organization_id   =>    l_exp_orgz_res_id   ,
                           p_person_id                     =>    p_person_id         ,
                           p_forecast_job_id               =>    p_forecast_job_id   ,
                           p_forecast_job_group_id         =>    p_forecast_job_group_id,
                           p_calculate_cost_flag           =>    'N', /* Added to fix bug 2162965 */
                           x_projfunc_bill_rate            =>    l_bill_rate         ,
                           x_projfunc_raw_revenue          =>    l_raw_revenue       ,
                           x_rev_currency_code             =>    l_rev_currency_code ,
                           x_markup_percentage             =>    l_x_markup_percentage ,
                           x_return_status                 =>    l_x_return_status   ,
                           x_msg_count                     =>    l_x_msg_count       ,
                           x_msg_data                      =>    l_x_msg_data  );


/*
   Bug 3192856 - When the p_quantity passed is 1 to PA_RATE_PVT_PKG.get_initial_bill_rate,
   the parameter x_projfunc_raw_revenue (l_raw_revenue) will contain the Revenue and Adjusted Rate.
   Please refer bug for other details
*/
     x_bill_rate           := NVL(l_raw_revenue,0); /* 3192856 - Modified l_bill_rate to l_raw_revenue */
     x_raw_revenue         := NVL(l_raw_revenue,0);
     x_rev_currency_code   := l_rev_currency_code;
     x_markup_percentage   := l_x_markup_percentage;
     x_return_status       := l_x_return_status;
     x_msg_count           := l_x_msg_count;
     x_msg_data            := l_x_msg_data;

     IF ( l_x_return_status  <> FND_API.G_RET_STS_SUCCESS ) THEN
      /* Checking error condition. Added for bug 2218386 */
       IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.Add_Message ('PA', SUBSTR(l_x_msg_data,1,30));
       END IF;
     END IF;

 EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data  := substr(SQLERRM,1,240);
  /* Checking error condition. Added for bug 2218386 */
  IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FORECAST_REVENUE', /* Moved this here to fix bug 2434663 */
                             p_procedure_name   => 'Get_Rev_Amt');
     RAISE;
  END IF;

 END Get_Rev_Amt;


END PA_FORECAST_REVENUE;


/
