--------------------------------------------------------
--  DDL for Package Body PA_CE_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CE_INTEGRATION" AS
/* $Header: PAXCEINB.pls 120.2 2005/08/23 12:04:45 dlai noship $ */

-- ==========================================================================
-- = PROCEDURE Pa_Ce_Budgets
-- ==========================================================================


PROCEDURE  Pa_Ce_Budgets   ( X_project_id           IN NUMBER
                           , X_period_start_date    IN DATE
                           , X_period_end_date      IN DATE
                           , X_budget_type          IN VARCHAR2
                           , X_version              IN VARCHAR2
                           , X_cost_amount         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           , X_revenue_amount      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           , X_currency_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           , X_org_id              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           , X_err_stack        IN OUT NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
                           , X_err_stage        IN OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                           , X_err_code         IN OUT NOCOPY NUMBER   ) --File.Sql.39 bug 4440895
  IS

  CURSOR ce_budget_lines_csr IS
    SELECT  pbl.start_date, pbl.end_date,
            nvl(pbl.raw_cost,0)/(pbl.end_date-pbl.start_date+1) per_day_raw_cost ,
            nvl(pbl.revenue,0)/(pbl.end_date-pbl.start_date+1) per_day_revenue
    FROM    pa_budget_lines pbl ,
            pa_resource_assignments pra ,
            pa_budget_versions pbv
    WHERE   decode(X_version,'C', pbv.current_flag,'O',pbv.current_original_flag)='Y'
    AND     pbl.end_date   >= X_period_start_date
    AND     pbl.start_date <= X_period_end_date
    AND     pbv.project_id  = X_project_id
    AND     pbv.budget_type_code = X_budget_type
    AND     pbl.resource_assignment_id = pra.resource_assignment_id
    AND     pra.budget_version_id = pbv.budget_version_id;

  CURSOR ce_org_id_csr IS
   SELECT org_id
   FROM   pa_projects_all
   WHERE  project_id = X_project_id;

  budget_line_rec      ce_budget_lines_csr%ROWTYPE;
  l_total_raw_cost     number := 0;
  l_total_revenue      number := 0;
  l_start_date         date;
  l_end_date           date;

  l_old_stack          varchar2(630);

  BEGIN

   l_old_stack := X_err_stack;
   X_err_stack := X_err_stack ||'->PA_CE_INTERGRATION.Pa_Ce_Budgets';

   X_currency_code := pa_multi_currency_txn.get_proj_curr_code_sql(X_project_id);

   OPEN ce_org_id_csr;

   FETCH ce_org_id_csr INTO X_org_id;

   CLOSE ce_org_id_csr;

   FOR budget_line_rec IN ce_budget_lines_csr

   LOOP
    IF  (budget_line_rec.start_date < X_period_start_date) THEN

        IF  (budget_line_rec.end_date <  X_period_end_date)  THEN
             l_start_date := X_period_start_date;
             l_end_date   := budget_line_rec.end_date;
        ELSE
             l_start_date := X_period_start_date;
             l_end_date   := X_period_end_date;
       END IF;

    ELSE

        IF (budget_line_rec.end_date > X_period_end_date)  THEN
             l_start_date := budget_line_rec.start_date;
             l_end_date   := X_period_end_date;
        ELSE
             l_start_date := budget_line_rec.start_date;
             l_end_date   := budget_line_rec.end_date;
        END IF;

   END IF;

   l_total_raw_cost:= l_total_raw_cost
                    + budget_line_rec.per_day_raw_cost * (l_end_date - l_start_date+1);
   l_total_revenue := l_total_revenue
                    + budget_line_rec.per_day_revenue *(l_end_date - l_start_date + 1);

  END LOOP;

-- Removed reference to pa_currency.round_currency_amt because this function
-- requires an org_id but forecasting should work across orgs
/*
  X_cost_amount     := pa_currency.round_currency_amt(l_total_raw_cost);
  X_revenue_amount  := pa_currency.round_currency_amt(l_total_revenue);
*/

  X_cost_amount     := l_total_raw_cost;
  X_revenue_amount  := l_total_revenue;

-- Restore the old error stack

  X_err_stack := l_old_stack;

  EXCEPTION
    WHEN  OTHERS  THEN
     X_err_code := SQLCODE;
     RAISE;

  END  Pa_Ce_Budgets;

END PA_CE_INTEGRATION;

/
