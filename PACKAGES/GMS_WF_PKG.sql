--------------------------------------------------------
--  DDL for Package GMS_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: gmsfbuvs.pls 120.0 2005/05/29 12:10:45 appldev noship $ */

-- Bug 3465169 : This function returns the Burden amount calculated
--               for  input parameters burdenable_raw_cost,expenditure_type
--               organization_id and ind_compiled_set_id.
--               This is introduced for performance fix inorder to avoid
--               a join with gms_commitment_encumbered_v .

 FUNCTION Get_Burden_amount  (p_expenditure_type VARCHAR2,
                              p_organization_id  NUMBER,
			      p_ind_compiled_set_id NUMBER,
			      p_burdenable_raw_cost NUMBER) RETURN NUMBER;


PROCEDURE Select_Budget_Approver
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT NOCOPY	VARCHAR2
);


PROCEDURE Verify_Budget_Rules
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT NOCOPY	VARCHAR2
);

PROCEDURE Baseline_Budget
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT NOCOPY	VARCHAR2
);

PROCEDURE Reject_Budget
(itemtype			IN   	VARCHAR2
, itemkey  			IN   	VARCHAR2
, actid				IN	NUMBER
, funcmode			IN   	VARCHAR2
, resultout			OUT NOCOPY	VARCHAR2
);

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
, p_err_code            IN OUT NOCOPY NUMBER
, p_err_stage         	IN OUT NOCOPY VARCHAR2
, p_err_stack         	IN OUT NOCOPY VARCHAR2
);

PROCEDURE Select_WF_Process
(itemtype        	IN  VARCHAR2
,itemkey         	IN  VARCHAR2
,actid           	IN  NUMBER
,funcmode        	IN  VARCHAR2
,resultout          	OUT NOCOPY VARCHAR2
);

PROCEDURE Funds_Check
(itemtype		IN   	VARCHAR2
, itemkey  		IN   	VARCHAR2
, actid			IN	NUMBER
, funcmode		IN   	VARCHAR2
, resultout		OUT NOCOPY	VARCHAR2
);

PROCEDURE Chk_Baselined_Budget_Exists
(itemtype		IN   	VARCHAR2
, itemkey  		IN   	VARCHAR2
, actid			IN	NUMBER
, funcmode		IN   	VARCHAR2
, resultout		OUT NOCOPY	VARCHAR2
);

PROCEDURE Start_Report_WF_Process( x_award_id IN NUMBER
				  ,x_award_number IN VARCHAR2
				  ,x_award_short_name IN VARCHAR2
				  ,x_installment_number IN VARCHAR2
				  ,x_report_name IN VARCHAR2
				  ,x_report_due_date IN VARCHAR2
				  ,x_funding_source_name IN VARCHAR2
				  ,x_role IN VARCHAR2
				  ,x_err_code OUT NOCOPY NUMBER
				  ,x_err_stage OUT NOCOPY VARCHAR2);

PROCEDURE Schedule_Notification( ERRBUF OUT NOCOPY Varchar2
			  ,RETCODE OUT NOCOPY Varchar2
			  ,p_offset_days IN NUMBER);


PROCEDURE Init_Installment_WF(x_award_id IN NUMBER
				     ,x_installment_id IN NUMBER);

PROCEDURE Start_Installment_WF( x_award_id IN NUMBER
                                  ,x_install_id IN NUMBER
                                  ,x_role IN VARCHAR2
                                  ,x_err_code OUT NOCOPY NUMBER
                                  ,x_err_stage OUT NOCOPY VARCHAR2);
/*Start:  Build of the installment closeout Nofification Enhancement*/

/*==================================================================================================================
 The procedure gets triggered off from the Installment Closeout Notification concurrent request.
 This  procedure selects the installments which are going to end by the offset days and kicks the workflow process.
 ===================================================================================================================*/

PROCEDURE Notify_Installment_Closeout(
	   	                     ERRBUF  OUT NOCOPY Varchar2
			 	     ,RETCODE OUT NOCOPY Varchar2
                                     ,p_offset_days IN NUMBER );



/*==================================================================================================================
 This procedure is called during the process of displaying the message in the notification .The procedure formats
 the message and also selects the list of open commitments.
 ===================================================================================================================*/
PROCEDURE   Get_Inst_Open_Commitments( document_id   IN	    VARCHAR2
                   	              ,display_type  IN	    VARCHAR2
                                      ,document	     IN OUT NOCOPY VARCHAR2
                            	      ,document_type IN OUT NOCOPY VARCHAR2);


/*End:  Build of the installment closeout Nofification Enhancement*/

  -----start bug# 3224843 ----
/*==========================================================================================
  This function returns either
         Y : To exclude person from getting notifications
         N : To receive notifications.
  ==========================================================================================*/
  FUNCTION Excl_Person_From_Notification
          (p_award_id IN NUMBER,
           p_user_id  IN NUMBER)
  RETURN VARCHAR2;
  -----end bug# 3224843 ----
END gms_wf_pkg;

 

/
