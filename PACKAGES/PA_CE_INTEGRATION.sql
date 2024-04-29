--------------------------------------------------------
--  DDL for Package PA_CE_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CE_INTEGRATION" AUTHID CURRENT_USER AS
/* $Header: PAXCEINS.pls 120.1 2005/08/19 17:11:11 mwasowic noship $ */

-- PUBLIC PROCEDURES and FUNCTIONS
--
--  This procedure accepts as input a project ID, start and end dates of the
--  period for which forecast is to be done, budget type code and budget version
--  (C)urrent or (O)riginal. It computes the pro-rated raw cost or revenue amount
--  budgeted for that project for the specified forecast period

  PROCEDURE  Pa_Ce_Budgets ( X_project_id           IN NUMBER
                           , X_period_start_date    IN DATE
                           , X_period_end_date      IN DATE
                           , X_budget_type          IN VARCHAR2
                           , X_version              IN VARCHAR2
                           , X_cost_amount         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           , X_revenue_amount      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           , X_currency_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           , X_org_id              OUT NOCOPY NUMBER   --File.Sql.39 bug 4440895
                           , X_err_stack        IN OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                           , X_err_stage        IN OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                           , X_err_code         IN OUT NOCOPY NUMBER   ); --File.Sql.39 bug 4440895


END PA_CE_INTEGRATION;

 

/
