--------------------------------------------------------
--  DDL for Package AMS_GEN_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_GEN_APPROVAL_PVT" AUTHID CURRENT_USER as
/* $Header: amsvgaps.pls 115.16 2003/10/30 10:16:18 vmodur ship $ */
--
-- Procedure
--   Check_Line_Further_Approval
--
--   Workflow cover: Check if line needs further approvals
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If line needs further approvals
--             - 'COMPLETE:N' If line does not need further approvals
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_GET_APPROVER_DETAILS
--

Type ObjRecTyp is RECORD
   ( name                 VARCHAR2(240),
     business_unit_id     NUMBER(15),
     country_code         VARCHAR2(30),
     setup_type_id        NUMBER,
     total_header_amount  NUMBER,
     org_id               NUMBER,
     object_type          VARCHAR2(30),
     priority             VARCHAR2(30),
     start_date           DATE,
     end_date             DATE,
     purpose              VARCHAR2(30),
     description          VARCHAR2(4000),
     owner_id             NUMBER,
     currency             varchar2(10) ,
     priority_desc        varchar2(80)
     );

---------------------------------------------------------------------------------

PROCEDURE Check_Process_Type( itemtype   	in  varchar2,
                           	itemkey    	in  varchar2,
                           	actid   	in  number,
                           	funcmode   	in  varchar2,
                           	resultout   OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow for the Approval Process
--
--
-- IN
--  p_approval_for          IN   Approval for Object (i.e. CAMP/EVEH,...)
--  p_approval_for_id	    IN   Approval for Objectid (i.e. CAMP_id,...)
--  p_object_version_number IN   Object Version Number
--  p_orig_stat_id          IN   Original User Status Id(e.g. id for 'NEW')
--  p_new_stat_id           IN   New User Status Id(e.g. id for 'AVAILABLE')
--  p_requester_userid      IN   Userid
--  p_workflowprocess       IN   WF Process Name (Default Null)
--  p_item_type             IN   WF Item type(Default Null)
-- OUT
--
-- Used By Activities
--
-- NOTES
-- HISTORY
-- End of Comments
PROCEDURE StartProcess
           (p_activity_type          IN   VARCHAR2,
            p_activity_id            IN   NUMBER,
            p_approval_type          IN   VARCHAR2,
            p_object_version_number  IN   NUMBER,
            p_orig_stat_id           IN   NUMBER,
            p_new_stat_id            IN   NUMBER,
            p_reject_stat_id         IN   NUMBER,
            p_requester_userid       IN   NUMBER,
            p_notes_from_requester   IN   VARCHAR2   DEFAULT NULL,
            p_workflowprocess        IN   VARCHAR2   DEFAULT NULL,
            p_item_type              IN   VARCHAR2   DEFAULT NULL,
	    p_gen_process_flag       IN   VARCHAR2   DEFAULT NULL
             );

PROCEDURE Set_Activity_Details(itemtype    IN  VARCHAR2,
                               itemkey     IN  VARCHAR2,
			       actid       IN  NUMBER,
                               funcmode    IN  VARCHAR2,
			       resultout   OUT NOCOPY VARCHAR2);

PROCEDURE Revert_Status( itemtype        in  varchar2,
                         itemkey         in  varchar2,
                         actid           in  number,
                         funcmode        in  varchar2,
                         resultout       OUT NOCOPY varchar2);


PROCEDURE Prepare_Doc( itemtype        in  varchar2,
                       itemkey         in  varchar2,
                       actid           in  number,
                       funcmode        in  varchar2,
                       resultout       OUT NOCOPY varchar2 );

PROCEDURE Set_Approver_Details( itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in  number,
                                funcmode        in  varchar2,
                                resultout       OUT NOCOPY varchar2 );

PROCEDURE Set_Further_Approvals( itemtype        in  varchar2,
                                 itemkey         in  varchar2,
                                 actid           in  number,
                                 funcmode        in  varchar2,
                                 resultout       OUT NOCOPY varchar2 );

PROCEDURE Get_Approval_Details
  ( p_activity_id          IN  NUMBER,
    p_activity_type        IN   VARCHAR2,
    p_approval_type        IN   VARCHAR2 DEFAULT  'BUDGET',
  --  p_act_budget_id        IN    NUMBER DEFAULT FND_API.G_MISS_NUM,
    p_object_details       IN  ObjRecTyp,
    x_approval_detail_id   OUT NOCOPY  NUMBER,
    x_approver_seq         OUT NOCOPY  NUMBER,
    x_return_status        OUT NOCOPY  VARCHAR2);
/*****************************************************************
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
-- End of Comments
*****************************************************************/

PROCEDURE AbortProcess
                  (p_itemkey           IN  VARCHAR2
                  ,p_workflowprocess   IN  VARCHAR2 	DEFAULT NULL
                  ,p_itemtype          IN  VARCHAR2 	DEFAULT NULL
                  );

PROCEDURE Get_Api_Name( p_rule_used_by       in  varchar2,
                        p_rule_used_by_type  in  varchar2,
                        p_rule_type          in  VARCHAR2,
			p_appr_type          in  VARCHAR2,
                        x_pkg_name           OUT NOCOPY varchar2,
                        x_proc_name          OUT NOCOPY varchar2,
			x_return_stat        OUT NOCOPY varchar2);

PROCEDURE Ntf_Approval(document_id   in      varchar2,
                       display_type  in      varchar2,
                       document      in OUT NOCOPY  varchar2,
                       document_type in OUT NOCOPY  varchar2);

PROCEDURE Ntf_Approval_reminder(document_id   in      varchar2,
                                display_type  in      varchar2,
                                document      in OUT NOCOPY  varchar2,
                                document_type in OUT NOCOPY  varchar2);

PROCEDURE Ntf_Forward_FYI( document_id   in      varchar2,
                           display_type  in      varchar2,
                           document      in OUT NOCOPY  varchar2,
                           document_type in OUT NOCOPY  varchar2);

PROCEDURE Ntf_Approved_FYI(document_id   in      varchar2,
                           display_type  in      varchar2,
                           document      in OUT NOCOPY  varchar2,
                           document_type in OUT NOCOPY  varchar2);

PROCEDURE Ntf_Rejected_FYI(document_id   in      varchar2,
                           display_type  in      varchar2,
                           document      in OUT NOCOPY  varchar2,
                           document_type in OUT NOCOPY  varchar2);

PROCEDURE Ntf_Requestor_Of_Error(document_id   in      varchar2,
                                 display_type  in      varchar2,
                                 document      in OUT NOCOPY  varchar2,
                                 document_type in OUT NOCOPY  varchar2);

PROCEDURE Update_Status(itemtype  IN  varchar2,
                        itemkey   IN  varchar2,
                        actid     in  number,
                        funcmode  in  varchar2,
                        resultout OUT NOCOPY varchar2);

PROCEDURE Reject_Update_Status(itemtype  IN  varchar2,
                               itemkey   IN  varchar2,
                               actid     in  number,
                               funcmode  in  varchar2,
                               resultout OUT NOCOPY varchar2);

PROCEDURE Approved_Update_Status(itemtype  IN  varchar2,
                                 itemkey   IN  varchar2,
                                 actid     in  number,
                                 funcmode  in  varchar2,
                                 resultout OUT NOCOPY varchar2    );

PROCEDURE DynTst(itemtype   IN varchar2
                 ,itemkey   IN varchar2
                 ,resultout OUT NOCOPY varchar2);

PROCEDURE DynTst1(itemtype IN varchar2
                 ,itemkey  IN varchar2
          --       ,resultout       out varchar2
   );

PROCEDURE Get_approver_Info
  ( p_approval_detail_id   IN   NUMBER,
    p_current_seq          IN   NUMBER,
    x_approver_id          OUT NOCOPY  VARCHAR2,
    x_approver_type        OUT NOCOPY  VARCHAR2,
    x_role_name            OUT NOCOPY  VARCHAR2,
    x_object_approver_id   OUT NOCOPY  VARCHAR2,
    x_notification_type    OUT NOCOPY  VARCHAR2,
    x_notification_timeout OUT NOCOPY  VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2);

PROCEDURE Handle_Err
   (p_itemtype                 IN VARCHAR2    ,
    p_itemkey                  IN VARCHAR2    ,
    p_msg_count                IN NUMBER      , -- Number of error Messages
    p_msg_data                 IN VARCHAR2    ,
    p_attr_name                IN VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2
   );

PROCEDURE Approval_Required(itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2);
-- Added for 11.5.9
PROCEDURE Get_Approval_Rule ( p_activity_id        IN  NUMBER,
                              p_activity_type      IN  VARCHAR2,
                              p_approval_type      IN  VARCHAR2,
			      p_act_budget_id      IN  NUMBER,
			      x_approval_detail_id OUT NOCOPY NUMBER,
			      x_return_status      OUT NOCOPY  VARCHAR2);

PROCEDURE PostNotif_Update (itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
			    resultout OUT NOCOPY VARCHAR2);

END ams_gen_approval_pvt;

 

/
