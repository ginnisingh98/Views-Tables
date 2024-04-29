--------------------------------------------------------
--  DDL for Package PA_BUDGET_ATTR_UPGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_ATTR_UPGR_PKG" AUTHID CURRENT_USER AS
/* $Header: PABDGATS.pls 120.0 2005/05/30 21:38:44 appldev noship $ */

procedure BUDGET_ATTR_UPGRD(
  P_PROJECT_ID                  IN   pa_projects_all.project_id%type
  , p_budget_version_id         IN   pa_budget_versions.budget_version_id%type
  , X_RETURN_STATUS             OUT  NOCOPY VARCHAR2
  , X_MSG_COUNT                 OUT  NOCOPY NUMBER
  , X_MSG_DATA                  OUT  NOCOPY VARCHAR2);

end PA_BUDGET_ATTR_UPGR_PKG;

 

/
