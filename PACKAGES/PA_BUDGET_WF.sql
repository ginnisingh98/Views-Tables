--------------------------------------------------------
--  DDL for Package PA_BUDGET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_WF" AUTHID CURRENT_USER AS
/* $Header: PAWFBUVS.pls 120.2 2007/02/06 10:13:20 dthakker ship $ */

PROCEDURE Select_Budget_Approver
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Verify_Budget_Rules
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Baseline_Budget
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Reject_Budget
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Budget_WF_Is_Used
(p_draft_version_id		IN 	NUMBER
, p_project_id 			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_pm_product_code		IN 	VARCHAR2
, p_fin_plan_type_id            IN      NUMBER     default NULL
, p_version_type                IN      VARCHAR2   default NULL
, p_result			IN OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
, p_err_code                    IN OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_err_stage			IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_stack			IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Start_Budget_WF
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_fck_req_flag        IN      VARCHAR2  DEFAULT NULL
, p_bgt_intg_flag       IN      VARCHAR2  DEFAULT NULL
, p_fin_plan_type_id    IN      NUMBER     default NULL
, p_version_type        IN      VARCHAR2   default NULL
, p_err_code            IN OUT  NOCOPY NUMBER  --File.Sql.39 bug 4440895
, p_err_stage         	IN OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
, p_err_stack         	IN OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

--Name:                 IS_FEDERAL_ENABLED
--Type:                 Procedure
--Description:          This procedure is used to find if FV_ENABLED(Federal profile) option is enabled
--
--Called subprograms:   None
--
--Notes:
--  This is called from PA Budget Baseline Workflow to find if Federal Option is enabled. If yes, and also
--  if the BEM/Third part interface is successful, then a notification is sent to the Budget Approver to
--  inform the Budget Analyst to import the Budget data from Interface tables.

PROCEDURE IS_FEDERAL_ENABLED
(itemtype           IN      VARCHAR2
, itemkey           IN      VARCHAR2
, actid                         IN  NUMBER
, funcmode          IN      VARCHAR2
, resultout         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

G_Baselined_By_User_ID pa_budget_versions.baselined_by_person_id%TYPE;

END pa_budget_wf;

/
