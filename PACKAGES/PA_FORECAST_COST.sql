--------------------------------------------------------
--  DDL for Package PA_FORECAST_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_COST" AUTHID CURRENT_USER as
/* $Header: PARFRTCS.pls 120.1 2005/08/19 16:52:19 mwasowic noship $ */


PROCEDURE Get_raw_cost(P_person_id             IN   NUMBER    ,
                       P_expenditure_org_id    IN   NUMBER    ,
                       P_labor_Cost_Mult_Name  IN   VARCHAR2  ,
                       P_Item_date             IN   DATE      ,
                       P_exp_func_curr_code    IN OUT  NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                       P_Quantity              IN   NUMBER    ,
                       X_Raw_cost_rate         OUT  NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                       X_Raw_cost              OUT  NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                       x_return_status         OUT  NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                       x_msg_count             OUT  NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                       x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      );


PROCEDURE Override_exp_organization(
                                    P_item_date                IN  DATE,
                                    P_person_id                IN  NUMBER,
                                    P_project_id               IN  NUMBER,
                                    P_incurred_by_organz_id    IN  NUMBER,
                                    P_Expenditure_type         IN  VARCHAR2,
                                    X_overr_to_organization_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_return_status            OUT NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                                    x_msg_count                OUT NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );


PROCEDURE Get_Burden_cost(p_project_type         IN  VARCHAR2 ,
                          p_project_id           IN  NUMBER   ,
                          p_task_id              IN  NUMBER   ,
                          p_item_date            IN  DATE     ,
                          p_expenditure_type     IN  VARCHAR2 ,
                          p_schedule_type        IN  VARCHAR2 ,
                          p_exp_func_curr_code   IN OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                          p_Incurred_by_organz_id   IN  NUMBER   ,
                          p_raw_cost             IN  NUMBER   ,
                          p_raw_cost_rate        IN  NUMBER   ,
                          p_quantity             IN  NUMBER   ,
                          p_override_to_organz_id IN  NUMBER   ,
                          x_burden_cost          OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                          x_burden_cost_rate     OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                          x_return_status        OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                          x_msg_count            OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                          x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         );

PROCEDURE  Get_proj_raw_Burden_cost(P_exp_org_id             IN  NUMBER    ,
                                    P_proj_org_id            IN  NUMBER    ,
                                    P_project_id             IN  NUMBER    ,
                                    P_task_id                IN  NUMBER    ,
                                    P_item_date              IN  DATE      ,
                                    P_exp_func_curr_code     IN OUT  NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                                    p_proj_func_curr_code    IN OUT  NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                                    p_raw_cost               IN  NUMBER    ,
                                    p_burden_cost            IN  NUMBER    ,
                                    x_proj_raw_cost          OUT NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_proj_raw_cost_rate     OUT NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_proj_burden_cost       OUT NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_proj_burden_cost_rate  OUT NOCOPY NUMBER    ,  --File.Sql.39 bug 4440895
                                    x_return_status          OUT NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                                    x_msg_count              OUT NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );


FUNCTION Get_pa_date(P_item_date                 IN  DATE,
                     P_expenditure_org_id        IN  NUMBER
                    )
return date;

FUNCTION Get_curr_code(p_org_id         IN  NUMBER
                      )
RETURN VARCHAR2;


PROCEDURE get_schedule_id( p_schedule_type          IN   VARCHAR2 ,
                           p_project_id             IN   NUMBER   ,
                           p_task_id                IN   NUMBER   ,
                           p_item_date              IN   DATE     ,
                           p_exp_type               IN   VARCHAR2 ,
                           x_burden_sch_rev_id      OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                           x_burden_sch_fixed_date  OUT  NOCOPY DATE     , --File.Sql.39 bug 4440895
                           x_return_status          OUT  NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                           x_msg_count              OUT  NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                           x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         );

PROCEDURE requirement_raw_cost(
                                   p_forecast_cost_job_group_id  IN  NUMBER   ,
                                   p_forecast_cost_job_id        IN  NUMBER   ,
                                   p_proj_cost_job_group_id      IN  NUMBER   ,
                                   p_proj_cost_job_id            IN  OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                                   p_item_date                   IN  DATE  ,
                                   p_job_cost_rate_sch_id        IN  NUMBER   ,
                                   p_schedule_date               IN  DATE     ,
                                   p_quantity                    IN  NUMBER   ,
                                   p_cost_rate_multiplier        IN  NUMBER   ,
                                   x_raw_cost_rate               OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                                   x_raw_cost                    OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                                   x_return_status               OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                                   x_msg_count                   OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                                   x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  );

END PA_FORECAST_COST;

 

/
