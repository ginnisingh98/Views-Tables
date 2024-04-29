--------------------------------------------------------
--  DDL for Package FEM_FEMAPPR_ITEM_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_FEMAPPR_ITEM_TYPE" AUTHID CURRENT_USER AS
/* $Header: FEMAPPRS.pls 120.1 2006/03/06 20:44:50 nmartine noship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

-- Constants for the Request Items
G_BUSINESS_RULE_ITEM         constant varchar2(30) := 'BUSINESS_RULE';

-- Constants for the Request Types
G_APPROVAL_TYPE              constant varchar2(30) := 'APPROVAL';
G_DELETE_TYPE                constant varchar2(30) := 'DELETE';

-- Types and constants for the FEM Approval's Business Events
G_BUSINESS_RULE_EVENT_APPROVAL constant varchar2(240) := 'oracle.apps.fem.brbase.event.approval';
G_BUSINESS_RULE_EVENT_DELETE   constant varchar2(240) := 'oracle.apps.fem.brbase.event.delete';

-- Item Attributes in the FEM Approvals workflow process
G_EVENT_NAME                 constant varchar2(30) := 'EVENT_NAME';
G_EVENT_KEY                  constant varchar2(30) := 'EVENT_KEY';

G_ORG_ID                     constant varchar2(30) := 'ORG_ID';
G_USER_ID                    constant varchar2(30) := 'USER_ID';
G_USER_NAME                  constant varchar2(30) := 'USER_NAME';
G_RESPONSIBILITY_ID          constant varchar2(30) := 'RESPONSIBILITY_ID';
G_APPLICATION_ID             constant varchar2(30) := 'APPLICATION_ID';

G_REQUEST_ID                 constant varchar2(30) := 'REQUEST_ID';
G_REQUEST_ITEM_CODE          constant varchar2(30) := 'REQUEST_ITEM_CODE';
G_REQUEST_ITEM               constant varchar2(30) := 'REQUEST_ITEM';
G_REQUEST_TYPE_CODE          constant varchar2(30) := 'REQUEST_TYPE_CODE';
G_REQUEST_TYPE               constant varchar2(30) := 'REQUEST_TYPE';
G_REQUEST_DATE               constant varchar2(30) := 'REQUEST_DATE';

G_APPROVER_ID                constant varchar2(30) := 'APPROVER_ID';
G_APPROVER_USER_ID           constant varchar2(30) := 'APPROVER_USER_ID';
G_APPROVER_NAME              constant varchar2(30) := 'APPROVER_NAME';
G_APPROVER_DISPLAY_NAME      constant varchar2(30) := 'APPROVER_DISPLAY_NAME';
G_APPROVER_ORIG_SYSTEM       constant varchar2(30) := 'APPROVER_ORIG_SYSTEM';
G_SUBMITTER_ID               constant varchar2(30) := 'SUBMITTER_ID';
G_SUBMITTER_NAME             constant varchar2(30) := 'SUBMITTER_NAME';
G_SUBMITTER_DISPLAY_NAME     constant varchar2(30) := 'SUBMITTER_DISPLAY_NAME';
G_SUBMITTER_ORIG_SYSTEM      constant varchar2(30) := 'SUBMITTER_ORIG_SYSTEM';
G_ROLE_NAME                  constant varchar2(30) := 'ROLE_NAME';

G_AME_AUTHORITY              constant varchar2(30) := 'AME_AUTHORITY';
G_AME_API_INSERTION          constant varchar2(30) := 'AME_API_INSERTION';
G_AME_APPROVAL_TYPE_ID       constant varchar2(30) := 'AME_APPROVAL_TYPE_ID';
G_AME_GROUP_OR_CHAIN_ID      constant varchar2(30) := 'AME_GROUP_OR_CHAIN_ID';
G_AME_OCCURRENCE             constant varchar2(30) := 'AME_OCCURRENCE';

G_ITEM_PLSQL_PKG_NAME        constant varchar2(30) := 'ITEM_PLSQL_PKG_NAME';
G_JUSTIFICATION              constant varchar2(30) := 'JUSTIFICATION';



--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------

--
-- FUNCTION
--   CreateWfRequestRow
--
-- DESCRIPTION
--   PL/SQL API for creating a row in the FEM_WF_REQUESTS table.  Used for
--   raising FEM Business Events.
--
-- IN
--   p_request_item_code    - Request Item Code (ie: BUSINESS_RULE)
--   p_request_type_code    - Request Type Code (ie: APPROVAL, DELETE)
--
-- RETURN
--   wf_request_id          - Workflow Request Id
--
--------------------------------------------------------------------------------
FUNCTION CreateWfRequestRow (
  p_request_item_code             in varchar2
  ,p_request_type_code            in varchar2
)
RETURN number;

--
-- PROCEDURE
--   RaiseEvent
--
-- DESCRIPTION
--   PL/SQL API for Raising any FEM Business Events
--
-- IN
--   p_event_name           - Business Event Name
--   p_request_id           - Workflow Request Id (FEM_WF_REQUEST_ID_SEQ)
--   p_user_id              - FND User ID
--   p_user_name            - FND User Name
--   p_responsibility_id    - FND Responsibility ID
--   p_application_id       - FND Application ID
--   p_org_id               - FND Organization ID
--
PROCEDURE RaiseEvent (
  p_event_name          in          varchar2,
  p_request_id          in          number,
  p_user_id             in          number,
  p_user_name           in          varchar2,
  p_responsibility_id   in          number,
  p_application_id      in          number,
  p_org_id              in          number
);

--
-- PROCEDURE
--   InitApprovalRequest
--
-- DESCRIPTION
--   Initializes the all the item attributes of an FEM Approvals Workflow.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_INIT_APPROVAL_REQ
--
PROCEDURE InitApprovalRequest (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   CheckApprovalItems
--
-- DESCRIPTION
--   Checks to see if this approval request contains approval items.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_CHECK_APPROVAL_ITEMS
--
PROCEDURE CheckApprovalItems (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   InitApprovalItems
--
-- DESCRIPTION
--   Initializes all the approval items.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_INIT_APPROVAL_ITEMS
--
PROCEDURE InitApprovalItems (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   GetNextApprover
--
-- DESCRIPTION
--   Gets the next approver for the approval request.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_GET_NEXT_APPROVER
--
PROCEDURE GetNextApprover (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   UpdateApprovalApproved
--
-- DESCRIPTION
--   Update the approval request with the approved response from the current
--   approver.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_UPDATE_APPROVAL_APPROVED
--
PROCEDURE UpdateApprovalApproved (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   UpdateApprovalRejected
--
-- DESCRIPTION
--   Update the approval request with the rejected response from the current
--   approver.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_UPDATE_APPROVAL_REJECTED
--
PROCEDURE UpdateApprovalRejected (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   UpdateApprovalNoResponse
--
-- DESCRIPTION
--   Update the approval request to indicate the lack of response from the
--   current approver.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_UPDATE_APPROVAL_NO_RESP
--
PROCEDURE UpdateApprovalNoResponse (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   ApprovalRequestHandler
--
-- DESCRIPTION
--   Notification Handler for FEM_APPROVAL_REQ_NTF.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_APPROVAL_REQ_NTF
--
PROCEDURE ApprovalRequestHandler (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   SetSubmittedState
--
-- DESCRIPTION
--   Sets the approval items to the submitted state.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_SET_SUBMITTED_STATE
--
PROCEDURE SetSubmittedState (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   SetApprovedState
--
-- DESCRIPTION
--   Sets the approval items to the approved state.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_SET_APPROVED_STATE
--
PROCEDURE SetApprovedState (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   SetRejectedState
--
-- DESCRIPTION
--   Sets the approval items to the rejected state.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_SET_REJECTED_STATE
--
PROCEDURE SetRejectedState (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   ApprovedStateFailure
--
-- DESCRIPTION
--   Handles the case when SetApprovedState fails.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_APPROVED_STATE_FAILURE
--
PROCEDURE ApprovedStateFailure (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   FinalizeApprovalRequest
--
-- DESCRIPTION
--   Finalizes the approval request.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_FINALIZE_APPROVAL_REQ
--
PROCEDURE FinalizeApprovalRequest (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
);

--
-- PROCEDURE
--   CallbackFunction
--
-- DESCRIPTION
--   Callback function.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR
--
PROCEDURE CallbackFunction (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_command             in          varchar2,
  x_result_out          out nocopy  varchar2
);



END FEM_FEMAPPR_ITEM_TYPE;

 

/
