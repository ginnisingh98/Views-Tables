--------------------------------------------------------
--  DDL for Package PA_BASELINE_FUNDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BASELINE_FUNDING_PKG" AUTHID CURRENT_USER AS
--$Header: PAXBBFPS.pls 120.1 2005/08/19 17:08:50 mwasowic noship $

    PROCEDURE create_draft (
           p_project_id         IN         NUMBER,
           p_start_date         IN         DATE,
           p_end_date           IN         DATE,
           p_resource_list_id   IN         NUMBER,
           x_budget_version_id  IN OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_err_code           OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_status             OUT        NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

    PROCEDURE create_line (
           p_project_id                IN         NUMBER,
           p_start_date                IN         DATE,
           p_end_date                  IN         DATE,
           p_resource_list_member_id   IN         NUMBER,
           p_budget_version_id         IN         NUMBER,
           x_err_code                  OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_status                    OUT        NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

    PROCEDURE create_budget_baseline (
           p_project_id         IN         NUMBER,
           x_err_code           OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_status             OUT        NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- FP_M changes:
-- Following APIs Proj_Agreement_Baseline and Change_Management_Baseline
-- are created from FP_M onwards

-- This API is for baselining only required Project's agreement's
-- funding lines
Procedure Proj_Agreement_Baseline (
  P_Project_ID		IN    NUMBER,
  P_Agreement_ID	IN    NUMBER,
  X_Err_Code		OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_Status		OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- This API is for baselining only required Project's agreement's
-- funding lines that are created thru change order management page
Procedure Change_Management_Baseline (
  P_Project_ID		IN    NUMBER,
  P_CI_ID_Tab		IN    PA_PLSQL_DATATYPES.IdTabTyp,
  X_Err_Code		OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_Status		OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END PA_BASELINE_FUNDING_PKG;
 

/
