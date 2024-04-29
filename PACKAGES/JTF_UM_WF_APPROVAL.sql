--------------------------------------------------------
--  DDL for Package JTF_UM_WF_APPROVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_WF_APPROVAL" AUTHID CURRENT_USER as
/* $Header: JTFUMWFS.pls 120.1.12010000.2 2011/07/19 11:28:44 anurtrip ship $ */

g_adhoc_role_name_prefix varchar2 (5) := 'JTAUM';
--
-- Procedure
--      ValidateWF
--
-- Description
--      Check if the required workflow attributes are defined in the WF.
-- IN
--   itemtype -- The itemtype of the workflow.
--
procedure ValidateWF (itemtype in varchar2);

--
-- Procedure
--      CreateProcess
--
-- Description
--      Initiate and launch workflow for a um approval
-- IN
--   ownerUserID     -- no longer required
--   requestType     -- The type of request, 'ENROLLMENT/USERTYPE'
--   requestID       -- ID of the request.
--   requesterUserID -- The FND userID of the requester
--   requestRegID    -- USERTYPE_REG_ID or SUBSCRIPTION_REG_ID
--
procedure CreateProcess (ownerUserId     in number := null,
                         requestType     in varchar2,
                         requestID       in number,
                         requesterUserID in number,
                         requestRegID    in number);

--
-- Procedure
--      LaunchProcess
--
-- Description
--      Launch the workflow process that has been created.
-- IN
--   requestType     -- The type of request, 'USERTYPE/ENROLLMENT'
--   requestRegID    -- USERTYPE_REG_ID or SUBSCRIPTION_REG_ID
--
procedure LaunchProcess (requestType     in varchar2,
                         requestRegID    in number);

--
-- Procedure
--      selector
--
-- Description
--
-- IN
--   itemtype    - A valid item type from (WF_ITEM_TYPES table).
--   itemkey     - A string generated from the application object's primary key.
--   activity_id - The function activity(instance id).
--   command     - Run/Cancel
-- OUT
--   resultout    - Name of workflow process to run
--
procedure Selector (item_type    in  varchar2,
                    item_key     in  varchar2,
                    activity_id in  number,
                    command     in  varchar2,
                    resultout   out NOCOPY varchar2);

--
-- Initialization
-- IN
--   Itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   Itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:'
--
procedure Initialization (Itemtype  in  varchar2,
                          Itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2);

--
-- SelectApprover
-- IN
--   Itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   Itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:T' if there is a next approver
--                - 'COMPLETE:F' if there is not a next approver
--
procedure SelectApprover (Itemtype  in  varchar2,
                          Itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2);

--
-- Procedure
--      GetApprover
--
-- Description
--      Select an approver
-- IN
--      Itemtype - workflow Itemtype
--      Itemkey  - workflow Itemkey
-- Out
--      approver's user_name
--      approver's user ID
--      approver ID
--      resultType - 'OK' return next approver.
--                   'ERROR' has error during running this api.
--                   'END' no more approver in the approver list.
--
Procedure GetApprover (x_Itemtype         in  varchar2,
                       x_Itemkey          in  varchar2,
                       x_approverUsername out NOCOPY varchar2,
                       x_approverUserID   out NOCOPY number,
                       x_approverID       out NOCOPY number,
                       x_resultType       out NOCOPY varchar2);

--
-- SelectRequestType
-- IN
--   Itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   Itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:USERTYPE' if it is a usertype request
--                - 'COMPLETE:ENROLLMENT' if it is a enrollment request
--
procedure SelectRequestType (Itemtype  in varchar2,
                             Itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout out NOCOPY varchar2);

--
-- cancel_notification
-- DESCRIPTION
--   Cancel all open notifications
-- IN
--   p_itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   p_itemkey   - A string generated from the application object's primary key.
--
procedure cancel_notification (p_itemtype  in varchar2,
                               p_itemkey   in varchar2);

--
-- initialize_fail_escalate
-- DESCRIPTION
--   Update the reg table and performer when fail to escalate approver.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode
-- OUT
--   Resultout    - 'COMPLETE:'
--
procedure initialize_fail_escalate (itemtype  in varchar2,
                                    itemkey   in varchar2,
                                    actid     in number,
                                    funcmode  in varchar2,
                                    resultout out NOCOPY varchar2);

--
-- WaitForApproval
-- IN
--   Itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   Itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:APPROVED' if the request is approved.
--                - 'COMPLETE:REJECTED' if the request is rejected.
--


procedure WaitForApproval (Itemtype  in  varchar2,
                           Itemkey   in  varchar2,
                           actid     in  number,
                           funcmode  in  varchar2,
                           resultout out NOCOPY varchar2);

--
-- post_notification
-- DESCRIPTION
--   Update the reg table when notification is transfered.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - FORWARD/TRANSFER
-- OUT
--   Resultout    - 'COMPLETE:'
--
procedure post_notification (itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout out NOCOPY varchar2);

--
-- store_delegate_flag
-- DESCRIPTION
--   Store the delegate flag into the database
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - FORWARD/TRANSFER
-- OUT
--   Resultout    - 'COMPLETE:'
--
procedure store_delegate_flag (itemtype  in varchar2,
                               itemkey   in varchar2,
                               actid     in number,
                               funcmode  in varchar2,
                               resultout out NOCOPY varchar2);

--
-- Procedure
--      Do_Approve_Req
--
-- Description -
--   Perform approve a request now
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--
procedure Do_Approve_Req (itemtype  in  varchar2,
                          itemkey   in  varchar2);

--
-- Procedure
--      Approve_Req
--
-- Description
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   resultout
--
procedure Approve_Req (itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);

--
-- Procedure
--      Reject_Req
--
-- Description
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   resultout
--
procedure Reject_Req (itemtype  in  varchar2,
                      itemkey   in  varchar2,
                      actid     in  number,
                      funcmode  in  varchar2,
                      resultout out NOCOPY varchar2);

--
-- Can_Delegate
-- DESCRIPTION
--   Check the enrollment request has the delegation role.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:Y' enrollment has the delegation role.
--                - 'COMPLETE:N' enrollment doesn't has the delegation role.
--
procedure Can_Delegate (itemtype  in varchar2,
                        itemkey   in varchar2,
                        actid     in number,
                        funcmode  in varchar2,
                        resultout out NOCOPY varchar2);

--
-- CAN_ENROLLMENT_DELEGATE
-- DESCRIPTION
--   Check the enrollment request if it is delegation or
--   delegation and self-service.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:Y' enrollment is a delegation or delegation
--                  and self-service.
--                - 'COMPLETE:N' enrollment is a implicit or self-service.
--
procedure Can_Enrollment_Delegate (itemtype  in varchar2,
                                   itemkey   in varchar2,
                                   actid     in number,
                                   funcmode  in varchar2,
                                   resultout out NOCOPY varchar2);

--
-- UNIVERSAL_APPROVERS_EXISTS
-- DESCRIPTION
--   Check if the current approver is universal approvers role.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:Y' current approver is universal approvers role.
--                - 'COMPLETE:N' current approver is not universal approvers
--                  role.
--
procedure universal_approvers_exists (itemtype  in varchar2,
                                      itemkey   in varchar2,
                                      actid     in number,
                                      funcmode  in varchar2,
                                      resultout out NOCOPY varchar2);

--
-- CHECK_EMAIL_NOTIFI_TYPE
-- DESCRIPTION
--   Check which email we will send to this requester.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:NO_NOTIFICATION' if email should not be sent.
--                - 'COMPLETE:PRIMARY_USER' if primary user email should be sent.
--                - 'COMPLETE:BUSINESS_USER' if business user email should be sent.
--                - 'COMPLETE:INDIVIDUAL_USER' if individual user email should be sent.
--                - 'COMPLETE:OTHER_USER' if other user email should be sent.
--                - 'COMPLETE:ENROLLMENT' if enrollment email should be sent.
--
procedure CHECK_EMAIL_NOTIFI_TYPE (Itemtype  in varchar2,
                                   Itemkey   in varchar2,
                                   actid     in number,
                                   funcmode  in varchar2,
                                   resultout out NOCOPY varchar2);

--
-- CompleteApprovalActivity
-- DESCRIPTION
--   Complete the blocking activity
-- IN
--   itemtype       - A valid item type from (WF_ITEM_TYPES table).
--   itemkey        - A string generated from the application object's primary key.
--   resultCode     - 'APPROVED' or 'REJECTED'
--   comment        - Approver's comment
--   delegationFlag - 'Y'  = Grant Delegation Flag
--                    'N'  = Do not grant delegation flag
--                    null = No delegation flag
--   lastUpdateDate - Last Update Date of the request record
--
procedure CompleteApprovalActivity (itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    resultCode      in varchar2,
                                    approverComment in varchar2,
                                    delegationFlag  in varchar2 := null,
                                    lastUpdateDate  in varchar2 := null);

--
-- Do_Complete_Approval_Activity
-- DESCRIPTION
--   Complete the blocking activity now
-- IN
--   p_itemtype        - A valid item type from (WF_ITEM_TYPES table).
--   p_itemkey         - A string generated from the application object's
--                       primary key.
--   p_resultCode      - 'APPROVED' or 'REJECTED'
--   p_wf_resultCode   - 'APPROVED' or 'REJECTED' but if approval is Usertype,
--                       this will be 'null'.
--   p_approverComment - Approver's comment
--   p_act1            - First Activity
--   p_act2            - Second Activity
--   p_act3            - Third Activity
--   p_act4            - Fourth Activity
--   p_act5            - Fifth Activity
--   p_act6            - Sixth Activity
--
procedure Do_Complete_Approval_Activity (p_itemtype        in varchar2,
                                         p_itemkey         in varchar2,
                                         p_resultCode      in varchar2,
                                         p_wf_resultCode   in varchar2,
                                         p_approverComment in varchar2,
                                         p_act1            in varchar2 := null,
                                         p_act2            in varchar2 := null,
                                         p_act3            in varchar2 := null,
                                         p_act4            in varchar2 := null,
                                         p_act5            in varchar2 := null,
                                         p_act6            in varchar2 := null);

--
-- Do_Complete_Approval_Activity
-- DESCRIPTION
--   Complete the blocking activity now
-- IN
--   p_itemtype        - A valid item type from (WF_ITEM_TYPES table).
--   p_itemkey         - A string generated from the application object's
--                       primary key.
--   p_resultCode      - 'APPROVED' or 'REJECTED'
--   p_approverComment - Approver's comment
--   p_act1            - First Activity
--   p_act2            - Second Activity
--   p_act3            - Third Activity
--   p_act4            - Fourth Activity
--   p_act5            - Fifth Activity
--   p_act6            - Sixth Activity
--
procedure Do_Complete_Approval_Activity (p_itemtype        in varchar2,
                                         p_itemkey         in varchar2,
                                         p_resultCode      in varchar2,
                                         p_approverComment in varchar2,
                                         p_act1            in varchar2 := null,
                                         p_act2            in varchar2 := null,
                                         p_act3            in varchar2 := null,
                                         p_act4            in varchar2 := null,
                                         p_act5            in varchar2 := null,
                                         p_act6            in varchar2 := null,
                                         p_act7           in varchar2 := null,
                                         p_act8            in varchar2 := null);

--
-- abort_process
-- DESCRIPTION
--   Abort the Workflow Process with status is ACTIVE, ERROR, or SUSPENDED
-- IN
--   p_itemtype        - A valid item type from (WF_ITEM_TYPES table).
--   p_itemkey         - A string generated from the application object's --                       primary key.
--
procedure abort_process (p_itemtype        in varchar2,
                         p_itemkey         in varchar2);

procedure usertype_approval_changed(p_usertype_id in number,
                                    p_new_approval_id in number,
                                    p_old_approval_id in number
				   );
procedure enrollment_approval_changed(p_subscription_id in number,
                                    p_new_approval_id in number,
                                    p_old_approval_id in number default null
				   );

procedure approval_chain_changed(p_approval_id  in number,
                                 p_org_party_id in number);
function get_approver_comment(p_reg_id in number,
                              p_wf_item_type in varchar2) return varchar2;

end JTF_UM_WF_APPROVAL;

/
