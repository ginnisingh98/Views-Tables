--------------------------------------------------------
--  DDL for Package PA_DATE_RANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DATE_RANGE_PKG" AUTHID CURRENT_USER AS
/* $Header: PADTRNGS.pls 120.0 2005/05/30 20:51:47 appldev noship $ */
procedure DATE_RANGE_UPGRD(
  P_BUDGET_VERSIONS           IN SYSTEM.PA_NUM_TBL_TYPE,
  X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT  NOCOPY NUMBER,
  X_MSG_DATA                  OUT  NOCOPY VARCHAR2);

--Bug 4046492. This API returns the Time Phase into which a budget version should be upgraded. The values
--that can be returned are
--'P' if the budget version has to upgraded to PA Time Phase
--'G' if the budget version has to upgraded to GL Time Phase
--'N' if the budget version has to upgraded to None Time Phase
--This function will be called from the upgrade script paupg102.sql and PADTRNGB.DATE_RANGE_UPGRD
function get_time_phase_mode
(p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE
,p_pa_period_type     IN pa_implementations_all.pa_period_type%TYPE
,p_gl_period_type     IN gl_sets_of_books.accounted_period_type%TYPE
,p_org_id             IN pa_projects_all.org_id%TYPE) RETURN VARCHAR2;
end PA_DATE_RANGE_PKG;

 

/
