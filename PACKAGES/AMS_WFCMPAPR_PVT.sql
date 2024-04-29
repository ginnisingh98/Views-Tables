--------------------------------------------------------
--  DDL for Package AMS_WFCMPAPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_WFCMPAPR_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvwcas.pls 115.9 2002/12/02 20:30:58 dbiswas ship $*/


--  Start of Comments
--
-- NAME
--   AMS_WFCmpApr_PVT
--
-- PURPOSE
--   This package performs contains the workflow procedures for
--   Activity Approvals(Campaign Approvals) in Oracle Marketing
--
-- HISTORY
--   09/21/1999        ptendulk        CREATED
--  02-dec-2002  dbiswas    NOCOPY and debug-level changes for performance
--

/***************************  PRIVATE ROUTINES  *******************************/

-- Start of Comments
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow for the Approval Process
--
--
-- IN
--  p_approval_for				IN   Approval for Object (i.e. CAMP/EVEH,...)
--  p_approval_for_id			IN	 Approval for Objectid (i.e. CAMP_id,...)
--  p_object_version_number     IN   Object Version Number
--  p_orig_stat_id  			IN	 Original User Status Id(e.g. id for 'NEW')
--  p_new_stat_id			    IN	 New User Status Id(e.g. id for 'AVAILABLE')
--  p_requester_userid		    IN	 Userid
--  p_workflowprocess			IN	 WF Process Name (Default Null)
--  p_item_type		            IN   WF Item type(Default Null)
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   09/21/1999        ptendulk            created
-- End of Comments
PROCEDURE StartProcess
		   (p_approval_for				IN   VARCHAR2
		   ,p_approval_for_id			IN	 NUMBER
           ,p_object_version_number     IN   NUMBER
		   ,p_orig_stat_id  			IN	 NUMBER
		   ,p_new_stat_id			    IN	 NUMBER
		   ,p_requester_userid		    IN	 NUMBER
           ,p_notes_from_requester      IN   VARCHAR2   DEFAULT NULL
		   ,p_workflowprocess			IN	 VARCHAR2 	DEFAULT NULL
		   ,p_item_type					IN	 VARCHAR2 	DEFAULT NULL
		   ) ;
-- Start of Comments
--
-- NAME
--   Selector
--
-- PURPOSE
--   This Procedure will determine which process to run
--
-- IN
-- itemtype     - A Valid item type from (WF_ITEM_TYPES Table).
-- itemkey      - A string generated from application object's primary key.
-- actid        - The function Activity
-- funcmode     - Run / Cancel
--
-- OUT
-- resultout    - Name of workflow process to run
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   08/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments


PROCEDURE Selector( itemtype    IN      VARCHAR2,
                    itemkey     IN      VARCHAR2,
                    actid       IN      NUMBER,
                    funcmode    IN      VARCHAR2,
                    resultout   OUT NOCOPY     VARCHAR2
                    );


-- Start of Comments
--
-- NAME
--   set_activity_details
--
-- PURPOSE
--   This Procedure will set the workflow attributes for the details of the activity
--   These Attributes will be used throught the process espacially in Notifications
--   It will also appropriate Approvers are availables for the approvals seeked
--
--
--   It will Return - Success if the process is successful
--				 	- Error   If the process is errored out
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:AMS_SUCCESS' If the Process is successful
--	  		 - 'COMPLETE:AMS_ERROR'   If the Process is errored out
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_SET_ACT_DETAILS
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Set_Activity_Details(itemtype    	IN	  VARCHAR2,
		  					   itemkey	 	IN	  VARCHAR2,
							   actid	    IN	  NUMBER,
							   funcmode		IN	  VARCHAR2,
							   result       OUT NOCOPY   VARCHAR2) ;


-- Start of Comments
--
-- NAME
--   Appr_Required_Check
--
-- PURPOSE
--   This Procedure will check whether the Approval is required or not
--
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the approval is required
--	  		 - 'COMPLETE:N' If the approval is not required
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_APPR
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Appr_Required_Check 	(itemtype    IN	  VARCHAR2,
  				 		itemkey	 	 IN	  VARCHAR2,
				 		actid	     IN	  NUMBER,
				 		funcmode	 IN	  VARCHAR2,
				 		result       OUT NOCOPY  VARCHAR2)  ;
-- Start of Comments
--
-- NAME
--   Update_Status_Na
--
-- PURPOSE
--   This Procedure will Update the Status of the Activity as the
--   Approval is not required
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_UPDATE_STATUS_NA
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE UPDATE_STATUS_NA (itemtype    IN	  VARCHAR2,
		  			     	itemkey	 	 IN	  VARCHAR2,
    						actid	     IN	  NUMBER,
    						funcmode	 IN	  VARCHAR2,
    						result       OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Theme_Appr_Req_Check
--
-- PURPOSE
--   This Procedure will check whether the Theme Approval is required or not
--
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the approval is required
--	  		 - 'COMPLETE:N' If the approval is not required
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_MAN_APPR
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Theme_Appr_Req_Check 	(itemtype    IN	  VARCHAR2,
  				 		itemkey	 	 IN	  VARCHAR2,
				 		actid	     IN	  NUMBER,
				 		funcmode	 IN	  VARCHAR2,
				 		result       OUT NOCOPY  VARCHAR2) ;

 -- Start of Comments
--
-- NAME
--   Create_Notif_Document
--
-- PURPOSE
--   This Procedure will create the Document to be sent for the Approvals
-- 	 it will also Update the Status As the Activity as Submitted for Approvals
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_PREPARE_DOC
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Create_Notif_Document(document_id	in	varchar2,
				display_type	in	varchar2,
				document	in OUT NOCOPY varchar2,
				document_type	in OUT NOCOPY varchar2) ;
 -- Start of Comments
--
-- NAME
--   Prepare_Doc
--
-- PURPOSE
--   This Procedure will create the Document to be sent for the Approvals
-- 	 it will also Update the Status As the Activity as Submitted for Approvals
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_PREPARE_DOC
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Prepare_Doc	(itemtype    IN	  VARCHAR2,
		  				itemkey	 	 IN	  VARCHAR2,
						actid	     IN	  NUMBER,
						funcmode	 IN	  VARCHAR2,
						result       OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Owner_Appr_Check
--
-- PURPOSE
--   This Procedure will check whether the Owner's Approval is required for the Theme
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the Owner's Approval is required
--	  		 - 'COMPLETE:N' If the Owner's Approval is not required
--
--
-- OUT
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_OWN_APPR
-- NOTES
--
--
-- HISTORY
--   09/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Owner_Appr_Check 	(itemtype    IN	  VARCHAR2,
  				 		itemkey	 	 IN	  VARCHAR2,
				 		actid	     IN	  NUMBER,
				 		funcmode	 IN	  VARCHAR2,
				 		result       OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Update_Stat_ApprTA
--
-- PURPOSE
--   This Procedure will Update the Status of the Activity for Approval
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_UPDATE_STATUS_TA
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Update_Stat_ApprTA (itemtype    IN	  VARCHAR2,
		  			     	itemkey	 	 IN	  VARCHAR2,
    						actid	     IN	  NUMBER,
    						funcmode	 IN	  VARCHAR2,
    						result       OUT NOCOPY  VARCHAR2) ;

 -- Start of Comments
--
-- NAME
--   Update_Status_Rej
--
-- PURPOSE
--   This Procedure will Update the Status of the Activity for Rejection
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_UPDATE_STATUS_REJ
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Update_Status_Rej	(itemtype    IN	  VARCHAR2,
		  				itemkey	 	 IN	  VARCHAR2,
						actid	     IN	  NUMBER,
						funcmode	 IN	  VARCHAR2,
						result       OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Revert_Status
--
-- PURPOSE
--   This Procedure will Revert the Status of the Activity Back to Original
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_REVERT_STATUS
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Revert_Status	(itemtype    IN	  VARCHAR2,
		  				itemkey	 	 IN	  VARCHAR2,
						actid	     IN	  NUMBER,
						funcmode	 IN	  VARCHAR2,
						result       OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Fund_Appr_Req_Check
--
-- PURPOSE
--   This Procedure will check whether the Budget Approval is required or not
--
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the approval is required
--	  		 - 'COMPLETE:N' If the approval is not required
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_BUD_APPR
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Fund_Appr_Req_Check 	(itemtype    IN	  VARCHAR2,
  				 		itemkey	 	 IN	  VARCHAR2,
				 		actid	     IN	  NUMBER,
				 		funcmode	 IN	  VARCHAR2,
				 		result       OUT NOCOPY  VARCHAR2) ;
-- Start of Comments
--
-- NAME
--   Ba_Owner_Appr_Check
--
-- PURPOSE
--   This Procedure will check whether the Owner's Approval is required for the Budget
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the Owner's Approval is required
--	  		 - 'COMPLETE:N' If the Owner's Approval is not required
--
--
-- OUT
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_CHECK_BA_OWN_APPR
-- NOTES
--
--
-- HISTORY
--   09/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Ba_Owner_Appr_Check 	(itemtype    IN	  VARCHAR2,
  				 		itemkey	 	 IN	  VARCHAR2,
				 		actid	     IN	  NUMBER,
				 		funcmode	 IN	  VARCHAR2,
				 		result       OUT NOCOPY  VARCHAR2);
-- Start of Comments
--
-- NAME
--   Update_Stat_ApprBA
--
-- PURPOSE
--   This Procedure will Update the Status of the Activity for Approval
--
-- IN
--    Itemtype - AMSAPPR
--	  Itemkey  - p_approver_for||p_approval_for_id||to_char(sysdate,'ddmmyyhhmiss')
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - COMPLETE:AMS_SUCCESS If the Process is Success.
--             COMPLETE:AMS_ERROR   If the Process is errored out.
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_UPDATE_STATUS_BA
--
-- NOTES
--
--
-- HISTORY
--   08/20/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments

PROCEDURE Update_Stat_ApprBA (itemtype    IN	  VARCHAR2,
		  			     	itemkey	 	 IN	  VARCHAR2,
    						actid	     IN	  NUMBER,
    						funcmode	 IN	  VARCHAR2,
    						result       OUT NOCOPY  VARCHAR2) ;


-- Start of Comments
--
-- NAME
--   AbortProcess
--
-- PURPOSE
--   This Procedure will abort the process of Approvals
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   09/13/1999        ptendulk            created
--   11/30/1999        ptendulk            Modified
-- End of Comments
PROCEDURE AbortProcess
		   (p_itemkey         			IN   VARCHAR2
		   ,p_workflowprocess			IN	 VARCHAR2 	DEFAULT NULL
		   ,p_itemtype					IN	 VARCHAR2 	DEFAULT NULL
		   );
END	AMS_WFCmpApr_PVT ;

 

/
