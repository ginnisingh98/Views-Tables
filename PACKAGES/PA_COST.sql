--------------------------------------------------------
--  DDL for Package PA_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST" AUTHID CURRENT_USER as
/* $Header: PAXCSRTS.pls 120.1 2005/08/03 11:06:11 aaggarwa noship $ */


PROCEDURE Get_raw_cost(P_person_id             IN     NUMBER    ,
                       P_expenditure_org_id    IN     NUMBER    ,
                       P_expend_organization_id IN    NUMBER    ,               /*LCE changes*/
                       P_labor_Cost_Mult_Name  IN     VARCHAR2  ,
                       P_Item_date             IN     DATE      ,
                       Px_exp_func_curr_code   IN OUT NOCOPY VARCHAR2  ,
                       P_Quantity              IN     NUMBER    ,
                       X_Raw_cost_rate         OUT    NOCOPY NUMBER    ,
                       X_Raw_cost              OUT    NOCOPY NUMBER    ,
                       x_return_status         OUT    NOCOPY VARCHAR2  ,
                       x_msg_count             OUT    NOCOPY NUMBER    ,
                       x_msg_data              OUT    NOCOPY VARCHAR2
                      );


PROCEDURE Override_exp_organization(
                                    P_item_date                IN  DATE,
                                    P_person_id                IN  NUMBER,
                                    P_project_id               IN  NUMBER,
                                    P_incurred_by_organz_id    IN  NUMBER,
                                    P_Expenditure_type         IN  VARCHAR2,
                                    X_overr_to_organization_id OUT NOCOPY NUMBER,
                                    x_return_status            OUT NOCOPY VARCHAR2  ,
                                    x_msg_count                OUT NOCOPY NUMBER    ,
                                    x_msg_data                 OUT NOCOPY VARCHAR2
                                   );


PROCEDURE Get_Burdened_cost(p_project_type          IN     VARCHAR2 ,
                            p_project_id            IN     NUMBER   ,
                            p_task_id               IN     NUMBER   ,
                            p_item_date             IN     DATE     ,
                            p_expenditure_type      IN     VARCHAR2 ,
                            p_schedule_type         IN     VARCHAR2 ,
                            px_exp_func_curr_code   IN OUT NOCOPY VARCHAR2 ,
                            p_Incurred_by_organz_id IN     NUMBER   ,
                            p_raw_cost              IN     NUMBER   ,
                            p_raw_cost_rate         IN     NUMBER   ,
                            p_quantity              IN     NUMBER   ,
                            p_override_to_organz_id IN     NUMBER   ,
                            x_burden_cost           OUT    NOCOPY NUMBER   ,
                            x_burden_cost_rate      OUT    NOCOPY NUMBER   ,
                            x_return_status         OUT    NOCOPY VARCHAR2 ,
                            x_msg_count             OUT    NOCOPY NUMBER   ,
                            x_msg_data              OUT    NOCOPY VARCHAR2
                           );

/* Changed the name of this proc from Get_proj_raw_Burdened_cost to
   Get_projfunc_raw_Burdened_cost  MCB II */
/* Changed the name of this proc from Get_projfunc_raw_Burdened_cost to
   Get_Converted_Cost_Amounts for Org Forecasting */
PROCEDURE  Get_Converted_Cost_Amounts(
              P_exp_org_id                   IN      NUMBER,
              P_proj_org_id                  IN      NUMBER,
              P_project_id                   IN      NUMBER,
              P_task_id                      IN      NUMBER,
              P_item_date                    IN      DATE,
              p_system_linkage               IN     pa_expenditure_items_all.system_linkage_function%TYPE,/* Added */
                                                    /* for Org Forecasting */
              px_txn_curr_code               IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_raw_cost                    IN  OUT NOCOPY NUMBER,  /* Txn raw cost,chnage from IN */
                                                              /* to IN OUT for Org forecasting */
              px_raw_cost_rate               IN  OUT NOCOPY NUMBER,  /* Txn raw cost rate,change from IN to */
                                                              /* IN OUT for Org forecasting */
              px_burden_cost                 IN  OUT NOCOPY NUMBER,  /* Txn burden cost,change from IN to */
                                                              /* IN OUT for Org forecasting */
              px_burden_cost_rate            IN  OUT NOCOPY NUMBER,  /* Txn burden cost rate,change from IN to
                                                              /* IN OUT for Org forecasting */
              px_exp_func_curr_code          IN  OUT NOCOPY VARCHAR2,
              px_exp_func_rate_date          IN  OUT NOCOPY DATE,    /* Added for Org Forecasting */
              px_exp_func_rate_type          IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_exp_func_exch_rate          IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_exp_func_cost               IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_exp_func_cost_rate          IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_exp_func_burden_cost        IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_exp_func_burden_cost_rate   IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_proj_func_curr_code         IN  OUT NOCOPY VARCHAR2,
              px_projfunc_cost_rate_date     IN  OUT NOCOPY DATE,    /* Added for Org Forecasting */
              px_projfunc_cost_rate_type     IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_projfunc_cost_exch_rate     IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_projfunc_raw_cost           IN  OUT NOCOPY NUMBER , /* The following 4 para name changed for MCB II */
                                                              /* change from OUT to IN OUT for Org forecasting */
              px_projfunc_raw_cost_rate      IN  OUT NOCOPY NUMBER , /* change from OUT to IN OUT for Org forecasting */
              px_projfunc_burden_cost        IN  OUT NOCOPY NUMBER , /* change from OUT to IN OUT for Org forecasting */
              px_projfunc_burden_cost_rate   IN  OUT NOCOPY NUMBER , /* change from OUT to IN OUT for Org forecasting */
              px_project_curr_code           IN  OUT NOCOPY VARCHAR2,
              px_project_rate_date           IN  OUT NOCOPY DATE,    /* Added for Org Forecasting */
              px_project_rate_type           IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_project_exch_rate           IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_project_cost                IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_project_cost_rate           IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_project_burden_cost         IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_project_burden_cost_rate    IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              x_return_status                OUT NOCOPY    VARCHAR2  ,
              x_msg_count                    OUT NOCOPY    NUMBER    ,
              x_msg_data                     OUT NOCOPY    VARCHAR2
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
                           x_burden_sch_rev_id      OUT  NOCOPY NUMBER   ,
                           x_burden_sch_fixed_date  OUT  NOCOPY DATE     ,
                           x_return_status          OUT  NOCOPY VARCHAR2  ,
                           x_msg_count              OUT  NOCOPY NUMBER    ,
                           x_msg_data               OUT  NOCOPY VARCHAR2
                         );



PROCEDURE  Requirement_raw_cost(
              p_forecast_cost_job_group_id    IN       NUMBER   ,
              p_forecast_cost_job_id          IN       NUMBER   ,
              p_proj_cost_job_group_id        IN       NUMBER   ,
              px_proj_cost_job_id             IN  OUT  NOCOPY NUMBER ,
              p_item_date                     IN       DATE     ,
              p_job_cost_rate_sch_id          IN       NUMBER   ,
              p_schedule_date                 IN       DATE     ,
              p_quantity                      IN       NUMBER   ,
              p_cost_rate_multiplier          IN       NUMBER   ,
              p_org_id                        IN       NUMBER   ,
              p_expend_organization_id        IN       NUMBER   ,               /*LCE changes*/
          /*  p_projfunc_currency_code        IN       VARCHAR2, -- The following 4
              px_projfunc_cost_rate_type      IN OUT NOCOPY   VARCHAR2, -- added for MCB2
              px_projfunc_cost_rate_date      IN OUT NOCOPY   DATE,
              px_projfunc_cost_exchange_rate  IN OUT NOCOPY   NUMBER  ,
               Commented for Org Forecasting */
              x_raw_cost_rate                 OUT NOCOPY      NUMBER   ,
              x_raw_cost                      OUT NOCOPY      NUMBER   ,
              x_txn_currency_code             OUT NOCOPY      VARCHAR2 , /* Added for Org Forecasting */
              x_return_status                 OUT NOCOPY      VARCHAR2 ,
              x_msg_count                     OUT NOCOPY      NUMBER   ,
              x_msg_data                      OUT NOCOPY      VARCHAR2
                 );


END PA_COST;

 

/
