--------------------------------------------------------
--  DDL for Package Body FEM_FEMAPPR_ITEM_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_FEMAPPR_ITEM_TYPE" AS
/* $Header: FEMAPPRB.pls 120.2 2006/09/21 08:25:40 nmartine noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME              constant varchar2(30) := 'FEM_FEMAPPR_ITEM_TYPE';

-- Item Type Constants
G_FEMAPPR               constant varchar2(30) := 'FEMAPPR';
G_FEM_APPROVAL_PROCESS  constant varchar2(30) := 'FEM_APPROVAL_PROCESS';

-- AME Constants (Bug Fix 3922758: WORKFLOW SUBMIT NEEDS TO CHANGE APP ID LOGIC)
G_FEM_APPLICATION_ID    constant number       := 274;

-- Workflow Directory Services Constants
G_PER                   constant varchar2(30) := 'PER';
G_FND_USR               constant varchar2(30) := 'FND_USR';

-- Types and constants representing all notification response values
G_APPROVE               constant varchar2(30) := 'APPROVED';
G_REJECT                constant varchar2(30) := 'REJECTED';
G_NO_RESPONSE           constant varchar2(30) := 'NO_RESPONSE';
G_SUCCESS               constant varchar2(30) := 'SUCCESS';
G_FAILURE               constant varchar2(30) := 'FAILURE';

-- Types and constants representing yes/no values
G_YES                   constant varchar2(1)  := 'Y';
G_NO                    constant varchar2(1)  := 'N';

-- Types and constants representing boolean values
G_TRUE                  constant varchar2(30) := 'TRUE';
G_FALSE                 constant varchar2(30) := 'FALSE';

-- Constants used in dynamic message generation
NL                      constant varchar2(1)  := FND_GLOBAL.newline;

-- Miscellaneous Constants
G_NULL                  constant varchar2(30) := '';



--------------------------------------------------------------------------------
-- VARIABLE TYPE DEFINITIONS
--------------------------------------------------------------------------------

-- Business Event System
t_event_key             varchar2(240);
t_event_name            varchar2(240);

-- Lookup Code
t_code                  FND_LOOKUP_VALUES.lookup_code%TYPE;
t_meaning               FND_LOOKUP_VALUES.meaning%TYPE;

-- Workflow
t_item_type             WF_ITEMS.item_type%TYPE;
t_item_key              WF_ITEMS.item_key%TYPE;

-- Oracle Applications
t_org_id                number;
t_user_id               FND_USER.user_id%TYPE;
t_user_name             FND_USER.user_name%TYPE;
t_responsibility_id     FND_RESPONSIBILITY.responsibility_id%TYPE;
t_application_id        FND_APPLICATION.application_id%TYPE;

-- Oracle Approval Management (AME)
t_approval_status       varchar2(50);

-- Workflow Directory Services
t_id                    number;
t_name                  varchar2(30);
t_display_name          varchar2(80);
t_orig_system           varchar2(30);

-- FEM Approval Workflow
t_request_id            FEM_WF_REQUESTS.wf_request_id%TYPE;
t_plsql_pkg_name        FEM_WF_REQ_ITEMS.item_plsql_pkg_name%TYPE;
t_document              varchar2(32000);
t_url                   varchar2(2000);
t_justification         varchar2(2000);

-- API Error Messages
t_msg_count             number;
t_msg_data              varchar2(2000);



--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------

PROCEDURE InitApprovalRequestInternal (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2
);

PROCEDURE UpdateApproval (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_approval_status     in          varchar2
);

PROCEDURE PurgeApprovalRequest(
  p_item_type                      in varchar2
  ,p_item_key                      in varchar2
);

FUNCTION GetUserId (
  p_user_name           in          varchar2
)
RETURN t_id%TYPE;

PROCEDURE BuildErrorMsg (
  p_api_name            in          varchar2
  ,p_item_type          in          varchar2
  ,p_item_key           in          varchar2
  ,p_act_id             in          number
);



--------------------------------------------------------------------------------
-- PUBLIC BODIES
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
RETURN number
--------------------------------------------------------------------------------
IS

  l_wf_request_id                 number;

BEGIN

  select fem_wf_request_id_seq.NEXTVAL
  into l_wf_request_id
  from dual;

  insert into fem_wf_requests (
    wf_request_id
    ,wf_request_item_code
    ,wf_request_type_code
    ,creation_date
    ,created_by
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) values (
    l_wf_request_id
    ,p_request_item_code
    ,p_request_type_code
    ,sysdate
    ,FND_GLOBAL.User_Id
    ,FND_GLOBAL.User_Id
    ,sysdate
    ,FND_GLOBAL.Login_Id
    ,1
  );

  return l_wf_request_id;

END CreateWfRequestRow;


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
--------------------------------------------------------------------------------
PROCEDURE RaiseEvent (
  p_event_name          in          varchar2,
  p_request_id          in          number,
  p_user_id             in          number,
  p_user_name           in          varchar2,
  p_responsibility_id   in          number,
  p_application_id      in          number,
  p_org_id              in          number
)
--------------------------------------------------------------------------------
IS

  l_parameter_list          wf_parameter_list_t;
  l_event                   wf_event_t;
  l_event_key               t_event_key%TYPE;

BEGIN

  l_event_key := to_char(p_request_id);

  wf_event_t.initialize(l_event);

  l_event.AddParameterToList(G_REQUEST_ID, p_request_id);
  l_event.AddParameterToList(G_USER_ID, p_user_id);
  l_event.AddParameterToList(G_USER_NAME, p_user_name);
  l_event.AddParameterToList(G_RESPONSIBILITY_ID, p_responsibility_id);
  l_event.AddParameterToList(G_APPLICATION_ID, p_application_id);
  l_event.AddParameterToList(G_ORG_ID, p_org_id);

  l_parameter_list := l_event.getParameterList();

  WF_EVENT.raise(
    p_event_name => p_event_name
    ,p_event_key =>  l_event_key
    ,p_parameters => l_parameter_list);

  l_parameter_list.delete;

  commit;

END RaiseEvent;


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
--------------------------------------------------------------------------------
PROCEDURE InitApprovalRequest (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'InitApprovalRequest';

  l_user_name               t_user_name%TYPE;
  l_submitter_orig_system   t_orig_system%TYPE;
  l_submitter_id            t_id%TYPE;
  l_submitter_name          t_name%TYPE;
  l_submitter_display_name  t_display_name%TYPE;

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    -- Set all the Approval Type information on the Item Attributes
    InitApprovalRequestInternal(
      p_item_type   => p_item_type,
      p_item_key    => p_item_key
    );

    -- Set all the Submitter information on the Item Attributes
    l_user_name := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_USER_NAME);

    WF_DIRECTORY.GetRoleOrigSysInfo(
      l_user_name,
      l_submitter_orig_system,
      l_submitter_id);

    WF_DIRECTORY.GetRoleName(
      l_submitter_orig_system
      ,l_submitter_id
      ,l_submitter_name
      ,l_submitter_display_name);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_SUBMITTER_ORIG_SYSTEM, l_submitter_orig_system);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_SUBMITTER_ID, l_submitter_id);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_SUBMITTER_NAME, l_submitter_name);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_SUBMITTER_DISPLAY_NAME, l_submitter_display_name);

    -- Set the Approval information on the Item Attributes
    WF_ENGINE.SetItemAttrDate(
      p_item_type, p_item_key, G_REQUEST_DATE, trunc(sysdate));

    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END InitApprovalRequest;


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
--------------------------------------------------------------------------------
PROCEDURE CheckApprovalItems (
  p_item_type                     in varchar2,
  p_item_key                      in varchar2,
  p_act_id                        in number,
  p_func_mode                     in varchar2,
  x_result_out                    out nocopy varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'CheckApprovalItems';

  l_request_item_code             t_code%TYPE;
  l_item_plsql_pkg_name           t_plsql_pkg_name%TYPE;
  l_dynamic_query                 long;

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    l_item_plsql_pkg_name := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_ITEM_PLSQL_PKG_NAME);

    if (l_item_plsql_pkg_name is not null) then

      l_dynamic_query :=
      ' begin '||
      '   :b_result_out := '||l_item_plsql_pkg_name||'.CheckApprovalItems('||
      '     p_item_type => :b_item_type'||
      '     ,p_item_key => :b_item_key'||
      '   );'||
      ' end;';

      execute immediate l_dynamic_query
      using out x_result_out
      ,p_item_type
      ,p_item_key;

    else

      l_request_item_code := WF_ENGINE.GetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Invalid Approval Request Item: '||l_request_item_code);
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    -- Finished Checking Approval Items
    x_result_out := WF_ENGINE.eng_completed || ':' || x_result_out;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END CheckApprovalItems;


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
--------------------------------------------------------------------------------
PROCEDURE InitApprovalItems (
  p_item_type                     in varchar2,
  p_item_key                      in varchar2,
  p_act_id                        in number,
  p_func_mode                     in varchar2,
  x_result_out                    out nocopy varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'InitApprovalItems';

  l_request_item_code             t_code%TYPE;
  l_item_plsql_pkg_name           t_plsql_pkg_name%TYPE;
  l_dynamic_query                 long;

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    l_item_plsql_pkg_name := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_ITEM_PLSQL_PKG_NAME);

    if (l_item_plsql_pkg_name is not null) then

      l_dynamic_query :=
      ' begin '||
          l_item_plsql_pkg_name||'.InitApprovalItems('||
      '     p_item_type => :b_item_type'||
      '     ,p_item_key => :b_item_key'||
      '   );'||
      ' end;';

      execute immediate l_dynamic_query
      using p_item_type
      ,p_item_key;

    else

      l_request_item_code := WF_ENGINE.GetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Invalid Approval Request Item: '||l_request_item_code);
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    -- Finished Initializing Approval Items
    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END InitApprovalItems;


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
--------------------------------------------------------------------------------
PROCEDURE GetNextApprover (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'GetNextApprover';

  l_application_id          t_application_id%TYPE;
  l_request_id              t_request_id%TYPE;

  l_approver_id             t_id%TYPE;
  l_approver_user_id        t_id%TYPE;
  l_approver_name           t_name%TYPE;
  l_approver_display_name   t_display_name%TYPE;
  l_approver_orig_system    t_orig_system%TYPE;

  l_role_name               t_name%TYPE;
  l_role_display_name       t_display_name%TYPE;

  l_next_approver_rec       AME_UTIL.approverRecord;

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    l_application_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_APPLICATION_ID);

    l_request_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_REQUEST_ID);

    AME_API.GetNextApprover(
      -- Bug Fix 3922758: WORKFLOW SUBMIT NEEDS TO CHANGE APP ID LOGIC
      G_FEM_APPLICATION_ID --l_application_id
      ,l_request_id
      ,G_FEMAPPR
      ,l_next_approver_rec
    );

    if (l_next_approver_rec.approval_status = AME_UTIL.exceptionStatus) then

      FND_MESSAGE.set_name('FEM', 'FEM_WF_APPR_NEXT_APPR_ERR');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;

    end if;

    if (l_next_approver_rec.person_id is not null) then

      -- An Approver was found
      l_approver_id := l_next_approver_rec.person_id;
      l_approver_user_id := l_next_approver_rec.user_id;
      l_approver_orig_system := G_PER;

    elsif (l_next_approver_rec.user_id is not null) then

      -- An Approver was found
      l_approver_id := l_next_approver_rec.user_id;
      l_approver_user_id := l_next_approver_rec.user_id;
      l_approver_orig_system := G_FND_USR;

    else

      -- No more approvers were found
      x_result_out := WF_ENGINE.eng_completed || ':' || G_NO;
      return;

    end if;

    -- Setting all approver attributes
    WF_DIRECTORY.GetRoleName(
      l_approver_orig_system
      ,l_approver_id
      ,l_role_name
      ,l_role_display_name
    );

    WF_DIRECTORY.GetUserName(
      l_approver_orig_system
      ,l_approver_id
      ,l_approver_name
      ,l_approver_display_name
    );

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_ROLE_NAME, l_role_name);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_APPROVER_ID, l_approver_id);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_APPROVER_USER_ID, l_approver_user_id);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_APPROVER_NAME, l_approver_name);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_APPROVER_DISPLAY_NAME, l_approver_display_name);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_APPROVER_ORIG_SYSTEM, l_approver_orig_system);

    -- Setting all AME approver record attributes
    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_AME_AUTHORITY, l_next_approver_rec.authority);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_AME_API_INSERTION, l_next_approver_rec.api_insertion);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_AME_APPROVAL_TYPE_ID, l_next_approver_rec.approval_type_id);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_AME_GROUP_OR_CHAIN_ID, l_next_approver_rec.group_or_chain_id);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_AME_OCCURRENCE, l_next_approver_rec.occurrence);

    x_result_out := WF_ENGINE.eng_completed || ':' || G_YES;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END GetNextApprover;


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
--------------------------------------------------------------------------------
PROCEDURE UpdateApprovalApproved (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'UpdateApprovalApproved';

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    UpdateApproval(
      p_item_type           => p_item_type
      ,p_item_key           => p_item_key
      ,p_approval_status    => AME_UTIL.approvedStatus
    );

    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END UpdateApprovalApproved;


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
--------------------------------------------------------------------------------
PROCEDURE UpdateApprovalRejected (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'UpdateApprovalRejected';

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    UpdateApproval(
      p_item_type           => p_item_type
      ,p_item_key           => p_item_key
      ,p_approval_status    => AME_UTIL.rejectStatus
    );

    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END UpdateApprovalRejected;


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
--------------------------------------------------------------------------------
PROCEDURE UpdateApprovalNoResponse (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'UpdateApprovalNoResponse';

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    UpdateApproval(
      p_item_type           => p_item_type
      ,p_item_key           => p_item_key
      ,p_approval_status    => AME_UTIL.noResponseStatus
    );

    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END UpdateApprovalNoResponse;


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
--------------------------------------------------------------------------------
PROCEDURE ApprovalRequestHandler (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'ApprovalRequestHandler';

  l_application_id             t_application_id%TYPE;
  l_request_id                 t_request_id%TYPE;

  l_old_approver_id            t_id%TYPE;
  l_old_approver_orig_system   t_orig_system%TYPE;

  l_new_approver_id            t_id%TYPE;
  l_new_approver_user_id       t_id%TYPE;
  l_new_approver_name          WF_ENGINE.context_text%TYPE;
  l_new_approver_display_name  t_display_name%TYPE;
  l_new_approver_orig_system   t_orig_system%TYPE;

  l_old_approver_record        AME_UTIL.approverRecord;
  l_new_approver_record        AME_UTIL.approverRecord;

  l_approval_status            t_approval_status%TYPE;

BEGIN

  if (p_func_mode in ('FORWARD','TRANSFER')) then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    -- Get necessary attribute values for call to AME_API
    l_application_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_APPLICATION_ID);

    l_request_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_REQUEST_ID);

    -- Identify if a forward or a transfer
    if (p_func_mode = 'FORWARD') then

      l_approval_status := AME_UTIL.approveAndForwardStatus;

    elsif (p_func_mode = 'TRANSFER') then

      l_approval_status := AME_UTIL.forwardStatus;

    end if;

    -- Get all AME approver record attributes
    l_old_approver_record.approval_status := l_approval_status;
    l_old_approver_record.authority := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_AME_AUTHORITY);
    l_old_approver_record.api_insertion := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_AME_API_INSERTION);
    l_old_approver_record.approval_type_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_AME_APPROVAL_TYPE_ID);
    l_old_approver_record.group_or_chain_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_AME_GROUP_OR_CHAIN_ID);
    l_old_approver_record.occurrence := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_AME_OCCURRENCE);

    -- Get the forwarding approver info
    l_old_approver_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_APPROVER_ID);

    l_old_approver_orig_system := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_APPROVER_ORIG_SYSTEM);

    if (l_old_approver_orig_system = G_PER) then

      l_old_approver_record.person_id := l_old_approver_id;

    elsif (l_old_approver_orig_system = G_FND_USR) then

      l_old_approver_record.user_id := l_old_approver_id;

    else

      -- Invalid Original System for Old Approver
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Invalid Original System for Old Approver: '||l_old_approver_orig_system);
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    -- Get the new approver name for the forwarded notification
    l_new_approver_name := WF_ENGINE.context_text;

    WF_DIRECTORY.GetRoleOrigSysInfo(
      l_new_approver_name,
      l_new_approver_orig_system,
      l_new_approver_id);

    WF_DIRECTORY.GetRoleName(
      l_new_approver_orig_system
      ,l_new_approver_id
      ,l_new_approver_name
      ,l_new_approver_display_name);

    -- Populate the New Approver record
    if (l_new_approver_orig_system = G_PER) then

      l_new_approver_user_id := GetUserId(l_new_approver_name);
      l_new_approver_record.person_id := l_new_approver_id;

    elsif (l_new_approver_orig_system = G_FND_USR) then

      l_new_approver_user_id := l_new_approver_id;
      l_new_approver_record.user_id := l_new_approver_id;

    else

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Invalid Original System for New Approver: '||l_new_approver_orig_system);
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    -- Default some values from forwarding approver record
    l_new_approver_record.authority := l_old_approver_record.authority;
    if (l_new_approver_record.authority = AME_UTIL.authorityApprover) then

      l_new_approver_record.api_insertion := AME_UTIL.apiAuthorityInsertion;

    else

      l_new_approver_record.api_insertion := AME_UTIL.apiInsertion;

    end if;

    -- Updating Approval Request with new approver info
    AME_API.updateApprovalStatus(
      -- Bug Fix 3922758: WORKFLOW SUBMIT NEEDS TO CHANGE APP ID LOGIC
      applicationIdIn     => G_FEM_APPLICATION_ID --l_application_id
      ,transactionIdIn    => l_request_id
      ,approverIn         => l_old_approver_record
      ,forwardeeIn        => l_new_approver_record
      ,transactionTypeIn  => G_FEMAPPR
    );

    -- Setting all AME approver record attributes
    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_AME_AUTHORITY, l_new_approver_record.authority);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_AME_API_INSERTION, l_new_approver_record.api_insertion);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_AME_APPROVAL_TYPE_ID, l_new_approver_record.approval_type_id);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_AME_GROUP_OR_CHAIN_ID, l_new_approver_record.group_or_chain_id);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_AME_OCCURRENCE, l_new_approver_record.occurrence);

    -- Update Approver Attributes with new approver info
    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_APPROVER_ID, l_new_approver_id);

    WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, G_APPROVER_USER_ID, l_new_approver_user_id);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_APPROVER_NAME, l_new_approver_name);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_APPROVER_DISPLAY_NAME, l_new_approver_display_name);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_APPROVER_ORIG_SYSTEM, l_new_approver_orig_system);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_ROLE_NAME, l_new_approver_name);

    -- Finished Forwarding Approval Request to new Approver
    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END ApprovalRequestHandler;


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
--------------------------------------------------------------------------------
PROCEDURE SetSubmittedState (
  p_item_type                     in varchar2,
  p_item_key                      in varchar2,
  p_act_id                        in number,
  p_func_mode                     in varchar2,
  x_result_out                    out nocopy varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'SetSubmittedState';

  l_request_item_code             t_code%TYPE;
  l_item_plsql_pkg_name           t_plsql_pkg_name%TYPE;
  l_dynamic_query                 long;

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    l_item_plsql_pkg_name := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_ITEM_PLSQL_PKG_NAME);

    if (l_item_plsql_pkg_name is not null) then

      l_dynamic_query :=
      ' begin '||
          l_item_plsql_pkg_name||'.SetSubmittedState('||
      '     p_item_type => :b_item_type'||
      '     ,p_item_key => :b_item_key'||
      '   );'||
      ' end;';

      execute immediate l_dynamic_query
      using p_item_type
      ,p_item_key;

    else

      l_request_item_code := WF_ENGINE.GetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Invalid Approval Request Item: '||l_request_item_code);
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    -- Success in Setting Submitted State
    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END SetSubmittedState;


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
--------------------------------------------------------------------------------
PROCEDURE SetApprovedState (
  p_item_type                     in varchar2,
  p_item_key                      in varchar2,
  p_act_id                        in number,
  p_func_mode                     in varchar2,
  x_result_out                    out nocopy varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'SetApprovedState';

  l_request_item_code             t_code%TYPE;
  l_item_plsql_pkg_name           t_plsql_pkg_name%TYPE;
  l_dynamic_query                 long;

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    l_item_plsql_pkg_name := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_ITEM_PLSQL_PKG_NAME);

    if (l_item_plsql_pkg_name is not null) then

      begin

        l_dynamic_query :=
        ' begin '||
            l_item_plsql_pkg_name||'.SetApprovedState('||
        '     p_item_type => :b_item_type'||
        '     ,p_item_key => :b_item_key'||
        '   );'||
        ' end;';

        execute immediate l_dynamic_query
        using p_item_type
        ,p_item_key;

      exception
        when others then
          x_result_out := WF_ENGINE.eng_completed || ':' || G_FAILURE;
          return;
      end;

    else

      l_request_item_code := WF_ENGINE.GetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Invalid Approval Request Item: '||l_request_item_code);
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    -- Success in Setting Approved State
    x_result_out := WF_ENGINE.eng_completed || ':' || G_SUCCESS;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END SetApprovedState;


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
--------------------------------------------------------------------------------
PROCEDURE SetRejectedState (
  p_item_type                     in varchar2,
  p_item_key                      in varchar2,
  p_act_id                        in number,
  p_func_mode                     in varchar2,
  x_result_out                    out nocopy varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'SetRejectedState';

  l_request_item_code             t_code%TYPE;
  l_item_plsql_pkg_name           t_plsql_pkg_name%TYPE;
  l_dynamic_query                 long;

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    l_item_plsql_pkg_name := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_ITEM_PLSQL_PKG_NAME);

    if (l_item_plsql_pkg_name is not null) then

      l_dynamic_query :=
      ' begin '||
          l_item_plsql_pkg_name||'.SetRejectedState('||
      '     p_item_type => :b_item_type'||
      '     ,p_item_key => :b_item_key'||
      '   );'||
      ' end;';

      execute immediate l_dynamic_query
      using p_item_type
      ,p_item_key;

    else

      l_request_item_code := WF_ENGINE.GetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Invalid Approval Request Item: '||l_request_item_code);
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    -- Success in Setting Rejected State
    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END SetRejectedState;


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
--------------------------------------------------------------------------------
PROCEDURE ApprovedStateFailure (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'ApprovedStateFailure';

  l_justification           t_justification%TYPE;

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    l_justification :=
      FND_MESSAGE.get_string('FEM', 'FEM_WF_APPROVED_STATE_ERR');

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, G_JUSTIFICATION, l_justification);

    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END ApprovedStateFailure;


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
--------------------------------------------------------------------------------
PROCEDURE FinalizeApprovalRequest (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_func_mode           in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'FinalizeApprovalRequest';

BEGIN

  if (p_func_mode = 'RUN') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    PurgeApprovalRequest (
      p_item_type => p_item_type
      ,p_item_key => p_item_key
    );

    -- Finished Initializing Approval Request
    x_result_out := WF_ENGINE.eng_completed;

    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END FinalizeApprovalRequest;


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
--------------------------------------------------------------------------------
PROCEDURE CallbackFunction (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_act_id              in          number,
  p_command             in          varchar2,
  x_result_out          out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'CallbackFunction';

  l_org_id                  t_org_id%TYPE;
  l_user_id                 t_user_id%TYPE;
  l_responsibility_id       t_responsibility_id%TYPE;
  l_application_id          t_application_id%TYPE;

  l_session_org_id          t_org_id%TYPE;

BEGIN

  if (p_command = 'RUN') then

    x_result_out := WF_ENGINE.eng_completed || ':' || G_FEM_APPROVAL_PROCESS;
    return;

  elsif (p_command = 'TEST_CTX') THEN

    -- Code that compares current session context
    -- with the work item context required to execute
    -- the workflow safely
    FND_PROFILE.Get(name => G_ORG_ID, val => l_session_org_id);

    l_org_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_ORG_ID);

    if (l_session_org_id = l_org_id) then
      x_result_out := WF_ENGINE.eng_completed || ':' || G_TRUE;
      return;
    else
      -- If the background engine is executing the
      -- Selector/Callback function, the workflow engine
      -- will immediately run the Selector/Callback
      -- function in SET_CTX mode
      x_result_out := WF_ENGINE.eng_completed || ':' || G_FALSE;
      return;
    end if;

  elsif (p_command = 'SET_CTX') then

    -- Initialize API message list
    FND_MSG_PUB.Initialize;

    l_org_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_ORG_ID);

    l_user_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_USER_ID);

    l_responsibility_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_RESPONSIBILITY_ID);

    l_application_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_APPLICATION_ID);

    -- Set the database session context which also sets the org
    FND_GLOBAL.Apps_Initialize(l_user_id, l_responsibility_id, l_application_id);

    -- Finished the Callback Function
    x_result_out := WF_ENGINE.eng_completed;
    return;

  else

    x_result_out := WF_ENGINE.eng_completed;
    return;

  end if;

EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END CallbackFunction;



--------------------------------------------------------------------------------
-- PRIVATE PROCEDURES BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--   UpdateApproval
--
-- DESCRIPTION
--   Update the approval request with the responses from the approver.
--
-- IN
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_approval_status      - AME Approval Status
--
--------------------------------------------------------------------------------
PROCEDURE UpdateApproval (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2,
  p_approval_status     in          varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'UpdateApproval';

  l_application_id          t_application_id%TYPE;
  l_request_id              t_request_id%TYPE;

  l_approver_id             t_id%TYPE;
  l_approver_orig_system    t_orig_system%TYPE;

  l_approver_rec            AME_UTIL.approverRecord;

BEGIN

  l_approver_rec.approval_status := p_approval_status;
  l_approver_rec.authority := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_AME_AUTHORITY);
  l_approver_rec.api_insertion := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_AME_API_INSERTION);
  l_approver_rec.approval_type_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_AME_APPROVAL_TYPE_ID);
  l_approver_rec.group_or_chain_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_AME_GROUP_OR_CHAIN_ID);
  l_approver_rec.occurrence := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_AME_OCCURRENCE);

  l_application_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_APPLICATION_ID);

  l_request_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_REQUEST_ID);

  l_approver_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_APPROVER_ID);

  l_approver_orig_system := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_APPROVER_ORIG_SYSTEM);

  if (l_approver_orig_system = G_PER) then

    l_approver_rec.person_id := l_approver_id;

    AME_API.updateApprovalStatus(
      -- Bug Fix 3922758: WORKFLOW SUBMIT NEEDS TO CHANGE APP ID LOGIC
      applicationIdIn     => G_FEM_APPLICATION_ID --l_application_id
      ,transactionIdIn    => l_request_id
      ,approverIn         => l_approver_rec
      ,transactionTypeIn  => G_FEMAPPR
    );

  elsif (l_approver_orig_system = G_FND_USR) then

    l_approver_rec.user_id := l_approver_id;

    AME_API.updateApprovalStatus(
      -- Bug Fix 3922758: WORKFLOW SUBMIT NEEDS TO CHANGE APP ID LOGIC
      applicationIdIn     => G_FEM_APPLICATION_ID --l_application_id
      ,transactionIdIn    => l_request_id
      ,approverIn         => l_approver_rec
      ,transactionTypeIn  => G_FEMAPPR
    );

  else

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Approver Original System: '||l_approver_orig_system);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

END UpdateApproval;


--
-- PROCEDURE
--   PurgeApprovalRequest
--
-- DESCRIPTION
--   Deletes all the appropriate approval request records from the
--   FEM_WF_REQUESTS and FEM_WF_REQ_OBJECT_DEFS tables.
--
-- IN
--   p_request_id   - Workflow Request ID.
--
--------------------------------------------------------------------------------
PROCEDURE PurgeApprovalRequest(
  p_item_type                     in varchar2
  ,p_item_key                     in varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'PurgeApprovalRequest';

  l_request_item_code             t_code%TYPE;
  l_item_plsql_pkg_name           t_plsql_pkg_name%TYPE;
  l_request_id                    t_request_id%TYPE;
  l_dynamic_query                 long;

BEGIN

  l_item_plsql_pkg_name := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_ITEM_PLSQL_PKG_NAME);

  if (l_item_plsql_pkg_name is not null) then

    l_dynamic_query :=
    ' begin '||
        l_item_plsql_pkg_name||'.PurgeApprovalRequest('||
    '     p_item_type => :b_item_type'||
    '     ,p_item_key => :b_item_key'||
    '   );'||
    ' end;';

    execute immediate l_dynamic_query
    using p_item_type
    ,p_item_key;

  else

    l_request_item_code := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Approval Request Item: '||l_request_item_code);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

  l_request_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_REQUEST_ID);

  delete from fem_wf_requests
  where wf_request_id = l_request_id;

END PurgeApprovalRequest;


--
-- PROCEDURE
--   InitApprovalRequestInternal
--
-- DESCRIPTION
--   Internal implementation for initializing an FEM Approvals Workflow.
--
-- IN
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--
--------------------------------------------------------------------------------
PROCEDURE InitApprovalRequestInternal (
  p_item_type           in          varchar2,
  p_item_key            in          varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                    constant varchar2(30) := 'InitApprovalRequestInternal';

  l_event_name                  t_event_name%TYPE;
  l_request_item_code           t_code%TYPE;
  l_request_item                t_meaning%TYPE;
  l_request_type_code           t_code%TYPE;
  l_request_type                t_meaning%TYPE;
  l_item_plsql_pkg_name         t_plsql_pkg_name%TYPE;

BEGIN

  -- Set all the Approval Type information on the Item Attributes
  l_event_name := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_EVENT_NAME);

  if l_event_name in (
    G_BUSINESS_RULE_EVENT_APPROVAL
    ,G_BUSINESS_RULE_EVENT_DELETE
  ) then

    select wf_request_item_code, wf_request_type_code
    into l_request_item_code, l_request_type_code
    from fem_wf_requests
    where wf_request_id = p_item_key;

    if (l_request_item_code is not null) then

      WF_ENGINE.SetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_ITEM_CODE, l_request_item_code);

      select item_plsql_pkg_name
      into l_item_plsql_pkg_name
      from fem_wf_req_items
      where wf_request_item_code = l_request_item_code;

      WF_ENGINE.SetItemAttrText(
        p_item_type, p_item_key, G_ITEM_PLSQL_PKG_NAME, l_item_plsql_pkg_name);

      select meaning
      into l_request_item
      from fem_lookups
      where lookup_type = 'FEM_WF_REQUEST_ITEM_DSC'
      and lookup_code = l_request_item_code;

      WF_ENGINE.SetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_ITEM, l_request_item);

    else

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Approval Request ID cannot be NULL');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    if (l_request_type_code is not null) then

      WF_ENGINE.SetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_TYPE_CODE, l_request_type_code);

      select meaning
      into l_request_type
      from fem_lookups
      where lookup_type = 'FEM_WF_REQUEST_TYPE_DSC'
      and lookup_code = l_request_type_code;

      WF_ENGINE.SetItemAttrText(
        p_item_type, p_item_key, G_REQUEST_TYPE, l_request_type);

    else

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
        'Approval Request Type cannot be NULL');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

  else

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Event Name: '||l_event_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

END InitApprovalRequestInternal;


--
-- FUNCTION
--   GetUserId
--
-- DESCRIPTION
--   Gets the FND user id.
--
-- IN
--   p_user_name     - FND User Name
--
-- RETURNS
--   user_id         - FND User Id
--
--------------------------------------------------------------------------------
FUNCTION GetUserId (
  p_user_name           in          varchar2
)
RETURN t_id%TYPE
--------------------------------------------------------------------------------
IS

  l_user_id       fnd_user.user_id%TYPE := -1;

BEGIN

  select user_id
  into l_user_id
  from fnd_user
  where user_name = p_user_name;

  return l_user_id;

END GetUserId;


--
-- PROCEDURE
--   BuildErrorMsg
--
-- DESCRIPTION
--   Builds the Workflow Error Message by checking if there are any errors
--   in the FND_MSG_PUB message stack.
--
-- IN
--   p_api_name             - The PL/SQL Procedure or Function name.
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id               - The function activity
--
--------------------------------------------------------------------------------
PROCEDURE BuildErrorMsg (
  p_api_name            in          varchar2
  ,p_item_type          in          varchar2
  ,p_item_key           in          varchar2
  ,p_act_id             in          number
)
--------------------------------------------------------------------------------
IS

  l_msg_count       t_msg_count%TYPE;
  l_msg_data        t_msg_data%TYPE;

BEGIN

  FND_MSG_PUB.Count_And_Get(
    p_count   => l_msg_count
    ,p_data   => l_msg_data
  );

  if (l_msg_count > 1) then

    l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_FIRST);

  end if;

  WF_CORE.Context(
    G_PKG_NAME
    ,p_api_name
    ,p_item_type
    ,p_item_key
    ,to_char(p_act_id)
    ,l_msg_data
  );

END BuildErrorMsg;



END FEM_FEMAPPR_ITEM_TYPE;

/
