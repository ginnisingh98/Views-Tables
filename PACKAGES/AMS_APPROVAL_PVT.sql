--------------------------------------------------------
--  DDL for Package AMS_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_APPROVAL_PVT" AUTHID CURRENT_USER as
/* $Header: amsvapps.pls 120.3 2007/08/09 10:00:45 rsatyava ship $ */

TYPE appr_cursor is REF CURSOR;

---------------------------------------------------------------------------------
--
-- Procedure
--      Start_LineApproval
--
-- Description
--      get details of budget line(s)
-- IN
--   p_budget_source_id     - Budget line source identifier
--   p_budget_source_type   - Budget line soucre arc qualifier
--   p_activity_source_id   - Activity source identifier
--   p_activity_source_type - Activity source qualifier
--   p_parent_process_flag  - Indicate if process started from a parent process
--
---------------------------------------------------------------------------------
PROCEDURE Start_LineApproval(
    p_api_version            	IN  NUMBER
   ,p_init_msg_list          	IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 	IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_data                OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,p_user_id                 IN  NUMBER
   ,p_act_budget_id           IN  NUMBER
   ,p_orig_status_id          IN  NUMBER
   ,p_new_status_id           IN  NUMBER
   ,p_rejected_status_id      IN  NUMBER
   ,p_parent_process_flag     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_parent_process_key      IN  VARCHAR2  -- was g_miss_char
   ,p_parent_context          IN  VARCHAR2 -- was g_miss_char
   ,p_parent_approval_flag    IN  VARCHAR2 := FND_API.G_FALSE
   ,p_continue_flow           IN  VARCHAR2 := FND_API.G_FALSE );
---------------------------------------------------------------------------------
--
-- Procedure
--   Start_Line_Approval
--
--   Workflow cover: Get line details for an activity and start process for lines not acted on
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_START_LINE_APPROVAL
--
---------------------------------------------------------------------------------
PROCEDURE Start_Line_Approval( itemtype  in  varchar2,
                              itemkey   in  varchar2,
                              actid   	in  number,
                              funcmode  in  varchar2,
                              resultout OUT NOCOPY varchar2    );
---------------------------------------------------------------------------------
--
-- Procedure
--   Get_Line_Approver_Details
--
--   Workflow cover: Get and set the details for a budget line to start approval process
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:' after setting the approver details
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_GET_APPROVER_DETAILS
--
---------------------------------------------------------------------------------
PROCEDURE Get_Line_Approver_Details( itemtype   	in  varchar2,
                           itemkey    	in  varchar2,
                           actid   	in  number,
                           funcmode   	in  varchar2,
                           resultout   OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------
PROCEDURE Check_Line_Further_Approval( itemtype   	in  varchar2,
                           	itemkey    	in  varchar2,
                           	actid   	in  number,
                           	funcmode   	in  varchar2,
                           	resultout   OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--
-- Procedure
--   Approve_Budget_Line
--
--   Workflow cover: Approve a budget line
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
--  AMS_APPROVAL_PVT    AMS_APPROVE_BUDGET_LINE
--
---------------------------------------------------------------------------------
PROCEDURE Approve_Budget_Line(itemtype   in  varchar2,
                             itemkey    in  varchar2,
                             actid   	in  number,
                             funcmode   in  varchar2,
                             resultout  OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--
-- Procedure
--   Reject_Budget_Line
--
--   Workflow cover: Reject a budget line
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
--  AMS_APPROVAL_PVT    AMS_REJECT_BUDGET_LINE
--
---------------------------------------------------------------------------------
PROCEDURE Reject_Budget_Line( itemtype   in  varchar2,
                             itemkey    in  varchar2,
                             actid   	in  number,
                             funcmode   in  varchar2,
                             resultout  OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--
-- Procedure
--   Is_Parent_Waiting
--
--   Workflow cover: Check if there is a parent procoess waiting for further process
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_PARENT_EXISTS
--
--------------------------------------------------------------------------------
PROCEDURE Is_Parent_Waiting (itemtype   	in  varchar2,
                            itemkey    	in  varchar2,
                            actid   	in  number,
                            funcmode   	in  varchar2,
                            resultout   OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--
-- Procedure
--   Check_Line_Approval_Rule
--
--   Workflow cover: Check if approval rule is met after action on a particular line
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_CHECK_LINE_APPROVAL_RULE
--
--------------------------------------------------------------------------------
PROCEDURE Check_Line_Approval_Rule (itemtype      in  varchar2,
                            itemkey     in  varchar2,
                            actid       in  number,
                            funcmode    in  varchar2,
                            resultout   OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--
-- Procedure
--   Check_More_Line_Remaining
--
--   Workflow cover: Check if more lines are waiting for approval
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_MORE_LINES_REMAINING
--
--------------------------------------------------------------------------------
PROCEDURE Check_More_Lines_Remaining (itemtype      in  varchar2,
                            itemkey     in  varchar2,
                            actid       in  number,
                            funcmode    in  varchar2,
                            resultout   OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--
-- Procedure
--   Can_Continue_Flow
--
--   Workflow cover: Check if this process can continue the flow of the main process
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_PARENT_EXISTS
--
--------------------------------------------------------------------------------
PROCEDURE Can_Continue_Flow (itemtype   	in  varchar2,
                            itemkey    	in  varchar2,
                            actid   	in  number,
                            funcmode   	in  varchar2,
                            resultout   OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------
--
-- Procedure
--   Continue_Parent_Process
--
--   Workflow cover: continues the parent process from the block state
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:' none
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_CONTINUE_PARENT
--
--------------------------------------------------------------------------------
PROCEDURE Continue_Parent_Process (itemtype   	in  varchar2,
                            itemkey    	in  varchar2,
                            actid   	in  number,
                            funcmode   	in  varchar2,
                            resultout   OUT NOCOPY varchar2    );
--------------------------------------------------------------------------------

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
            p_item_type              IN   VARCHAR2   DEFAULT NULL
             );

/*****************************************************************

-- Start of Comments
--
-- NAME
--   set_activity_details
--
-- PURPOSE
--   This Procedure will set the workflow attributes for the
--   details of the activity. These Attributes will be used
--   throught the process espacially in Notifications.
--   It will also appropriate Approvers are availables for
--   the approvals seeked
--
--   Return - Success if the process is successful
--          - Error   If the process is errored out
--
-- IN
--    Itemtype - AMSAPPR
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:AMS_SUCCESS' If the Process is successful
--            - 'COMPLETE:AMS_ERROR'   If the Process is errored out
--
-- Used By Activities
-- 	  Item Type - AMSAPPR
--	  Activity  - AMS_SET_ACT_DETAILS
--
-- NOTES
--
--
-- HISTORY
-- End of Comments
*****************************************************************/

PROCEDURE Set_Activity_Details(itemtype    	IN  VARCHAR2,
                               itemkey       IN  VARCHAR2,
                               actid         IN  NUMBER,
                               funcmode      IN  VARCHAR2,
                               resultout     OUT NOCOPY VARCHAR2) ;


PROCEDURE Revert_Status( itemtype        in  varchar2,
                         itemkey         in  varchar2,
                         actid           in  number,
                         funcmode        in  varchar2,
                         resultout       OUT NOCOPY varchar2    );
PROCEDURE Approve_Activity_status( itemtype        in  varchar2,
                         itemkey         in  varchar2,
                         actid           in  number,
                         funcmode        in  varchar2,
                         resultout       OUT NOCOPY varchar2    );
PROCEDURE Reject_Activity_status( itemtype        in  varchar2,
                         itemkey         in  varchar2,
                         actid           in  number,
                         funcmode        in  varchar2,
                         resultout       OUT NOCOPY varchar2    );
PROCEDURE Check_Budget_Lines( itemtype        in  varchar2,
                              itemkey         in  varchar2,
                              actid           in  number,
                              funcmode        in  varchar2,
                              resultout       OUT NOCOPY varchar2    );

PROCEDURE Check_Approval_rules( itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in  number,
                                funcmode        in  varchar2,
                                resultout       OUT NOCOPY varchar2    );
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
     priority_desc        varchar2(80),
     source_code          varchar2(30),
     parent_source_code   VARCHAR2(30),
     Parent_name          VARCHAR2(240)
     );


--------------------------------------------------------------------------------

-- Start of Comments
--
-- NAME
--   DelvStartProcess
--
-- PURPOSE
--   This Procedure will Start the flow for the Delivarable Cancellation Process
--
--
-- IN

--  p_deliverable_id	    IN   Delivarable id
--  p_deliverable_name	    IN   Delivarable Name
--  p_object_version_number IN   Object Version Number
--  p_usedby_object_id	    IN  Used by object id(Ex: Event/Campaign using this deliverable)
--  p_usedby_object_name    IN  Used by object Name(Ex: Event/Campaign using this deliverable)
--  p_usedby_object_type_name    IN  Object Type Name(Ex: Event/Campaign)
--  p_requester_userid      IN   Userid
--  p_deliverable_userid    IN   Deliverable user id(Ex: owner of the Event using deliverable)
--  p_workflowprocess       IN   WF Process Name (AMSAPRV)
--  p_item_type             IN   WF Item type(AMS_DELV_CANCELLATION)
-- OUT
--
-- Used By Activities
--
-- NOTES
-- HISTORY
-- End of Comments

PROCEDURE DelvStartProcess
           (p_deliverable_id         IN   NUMBER,
            p_deliverable_name       IN   VARCHAR2,
            p_object_version_number  IN   NUMBER,
            p_usedby_object_id       IN   NUMBER,
            p_usedby_object_name     IN   VARCHAR2,
            p_usedby_object_type_name IN   VARCHAR2,
            p_requester_userid       IN   NUMBER,
            p_deliverable_userid     IN   NUMBER,
            p_workflowprocess        IN   VARCHAR2 DEFAULT 'AMSAPRV',
            p_item_type              IN   VARCHAR2 DEFAULT 'AMS_DELV_CANCELLATION'
             );

PROCEDURE RECONCILE_BUDGET_LINE(itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in  number,
                                funcmode        in  varchar2,
                                resultout       OUT NOCOPY varchar2    );

PROCEDURE Revert_Budget_Line(itemtype   in  varchar2,
                             itemkey    in  varchar2,
                             actid      in  number,
                             funcmode   in  varchar2,
                             resultout  OUT NOCOPY varchar2    );

PROCEDURE Validate_Object_Budget_WF(itemtype  in  varchar2,
                                   itemkey   in  varchar2,
                                   actid     in  number,
                                   funcmode  in  varchar2,
                                   resultout OUT NOCOPY varchar2);

PROCEDURE Approval_Required(itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2);

PROCEDURE Auto_Approve (itemtype  IN  VARCHAR2,
                        itemkey   IN  VARCHAR2,
                        actid     IN  NUMBER,
                        funcmode  IN  VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

PROCEDURE Get_Approval_Rule ( p_activity_id        IN  NUMBER,
                              p_activity_type      IN  VARCHAR2,
                              p_approval_type      IN  VARCHAR2,
                              p_act_budget_id      IN  NUMBER,
                              x_approval_detail_Id OUT NOCOPY NUMBER,
                              x_return_status      OUT NOCOPY  VARCHAR2);

PROCEDURE PostNotif_Update (itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Object_Budget_All_WF(itemtype  in  varchar2,
                                   itemkey   in  varchar2,
                                   actid     in  number,
                                   funcmode  in  varchar2,
                                   resultout OUT NOCOPY varchar2);

PROCEDURE Bypass_Approval (itemtype    IN  VARCHAR2,
                        itemkey     IN  VARCHAR2,
                        actid       IN  NUMBER,
                        funcmode    IN  VARCHAR2,
                        resultout   OUT NOCOPY VARCHAR2);

PROCEDURE must_preview (p_activity_id        IN  NUMBER,
                        p_activity_type      IN  VARCHAR2,
                        p_approval_type      IN  VARCHAR2,
                        p_act_budget_id      IN  NUMBER,
                        p_requestor_id       IN  NUMBER,
                        x_must_preview       OUT NOCOPY VARCHAR2,
                        x_return_status      OUT NOCOPY VARCHAR2);

PROCEDURE Check_Object_Type( itemtype        in  varchar2,
                             itemkey         in  varchar2,
                             actid           in  number,
                             funcmode        in  varchar2,
                             resultout   OUT NOCOPY varchar2);
END ams_approval_pvt;

/
