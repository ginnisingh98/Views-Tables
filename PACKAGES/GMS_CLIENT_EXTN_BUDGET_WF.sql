--------------------------------------------------------
--  DDL for Package GMS_CLIENT_EXTN_BUDGET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_CLIENT_EXTN_BUDGET_WF" AUTHID CURRENT_USER AS
/* $Header: gmsfbces.pls 115.8 2002/11/19 19:34:34 jmuthuku ship $ */

PROCEDURE Is_Budget_WF_Used
( p_project_id 			IN 	NUMBER
, p_award_id 			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_pm_product_code		IN 	VARCHAR2
, p_result			IN OUT NOCOPY VARCHAR2
, p_err_code             	IN OUT NOCOPY	NUMBER
, p_err_stage			IN OUT NOCOPY	VARCHAR2
, p_err_stack			IN OUT NOCOPY	VARCHAR2
);

PROCEDURE Start_Budget_WF
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_award_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_item_type           OUT NOCOPY	VARCHAR2
, p_item_key           	OUT NOCOPY	VARCHAR2
, p_err_code            IN OUT NOCOPY NUMBER
, p_err_stage         	IN OUT NOCOPY VARCHAR2
, p_err_stack         	IN OUT NOCOPY VARCHAR2
);

PROCEDURE Start_Budget_WF_Ntfy_Only
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_award_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_item_type           OUT NOCOPY	VARCHAR2
, p_item_key           	OUT NOCOPY	VARCHAR2
, p_err_code            IN OUT NOCOPY NUMBER
, p_err_stage         	IN OUT NOCOPY VARCHAR2
, p_err_stack         	IN OUT NOCOPY VARCHAR2
);


PROCEDURE Select_Budget_Approver
(p_item_type			IN VARCHAR2
, p_item_key  			IN VARCHAR2
, p_project_id			IN NUMBER
, p_award_id 			IN NUMBER
, p_budget_type_code		IN VARCHAR2
, p_workflow_started_by_id  	IN NUMBER
, p_budget_baseliner_id		OUT NOCOPY NUMBER
 );

PROCEDURE Verify_Budget_Rules
(p_item_type			IN   	VARCHAR2
, p_item_key  			IN   	VARCHAR2
, p_project_id			IN 	NUMBER
, p_award_id 			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_workflow_started_by_id  	IN 	NUMBER
, p_event			IN	VARCHAR2
, p_warnings_only_flag		OUT NOCOPY	VARCHAR2
, p_err_msg_count		OUT NOCOPY	NUMBER
);

--Start Bug 2204122

PROCEDURE call_gms_debug
(p_user_roles IN VARCHAR2
,p_disp_text  IN VARCHAR2
);


PROCEDURE call_wf_addusers_to_adhocrole
(p_user_roles IN VARCHAR2
,p_role_name  IN VARCHAR2
);

--End Bug 2204122

END gms_client_extn_budget_wf;

 

/
