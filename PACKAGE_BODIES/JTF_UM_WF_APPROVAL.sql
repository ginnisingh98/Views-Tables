--------------------------------------------------------
--  DDL for Package Body JTF_UM_WF_APPROVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_WF_APPROVAL" as
/* $Header: JTFUMWFB.pls 120.11.12010000.11 2011/07/19 11:35:55 anurtrip ship $ */

G_MODULE CONSTANT VARCHAR2(40) := 'JTF.UM.PLSQL.APPROVAL';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(G_MODULE);


/*
Internal procedure to check if a Workflow has started or not. The Workflow should have been
created before.
*/
function hasWorkFlowStarted(itemtype varchar2, itemkey varchar2) return boolean
is
status varchar2(50);
result varchar2(50);
begin
	  wf_engine.ItemStatus(itemType,itemkey,status,result);
	  if status is null then
	  	 return false;
	  else
	  	  return true;
	  end if;
end hasWorkFlowStarted;



-- Return the descriptive name of the usertype or enrollment request
function getRequestName(requestType in varchar2,
                        requestId   in number) return varchar2 is

requestName      varchar2 (1000);

cursor getUsertypeName(x_usertype_id in number) is
  select USERTYPE_SHORTNAME
  from   jtf_um_usertypes_vl
  where  usertype_id = x_usertype_id;

cursor getSubscriptionName(x_subscription_id in number) is
  select SUBSCRIPTION_NAME
  from   jtf_um_subscriptions_vl
  where  subscription_id = x_subscription_id;

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering getRequestName (' ||
      requestType || ',' || requestId || ') API');

  if requestType = 'USERTYPE' then
    open getUsertypeName(requestId);
    fetch getUsertypeName into requestName;
    close getUsertypeName;
  else
    open getSubscriptionName(requestId);
    fetch getSubscriptionName into requestName;
    close getSubscriptionName;
  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting getRequestName API');

  return requestName;

end getRequestName;

-- Return the application id of the usertype or enrollment request
function getRequestApplId (requestType in varchar2,
                           requestId   in number) return varchar2 is

l_application_id jtf_um_usertypes_b.application_id%type;

cursor getUsertypeApplID (x_usertype_id in number) is
  select application_id
  from   jtf_um_usertypes_b
  where  usertype_id = x_usertype_id;

cursor getSubscriptionApplID (x_subscription_id in number) is
  select application_id
  from   jtf_um_subscriptions_vl
  where  subscription_id = x_subscription_id;

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering getRequestApplId (' ||
      requestType || ',' || requestId || ') API');

  if requestType = 'USERTYPE' then
    open getUsertypeApplID (requestId);
    fetch getUsertypeApplID into l_application_id;
    close getUsertypeApplID;
  else
    open getSubscriptionApplID (requestId);
    fetch getSubscriptionApplID into l_application_id;
    close getSubscriptionApplID;
  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting getRequestApplId API');

  return l_application_id;

end getRequestApplId;

-- Return the requester username
function getRequesterUsername (userID in varchar2) return varchar2 is

requesterUsername fnd_user.user_name%type;

cursor getUserNameCursor is
        select  USER_NAME
        from    FND_USER
        where   USER_ID = userID
        and     (nvl (END_DATE, sysdate + 1) > sysdate
                 or to_char(END_DATE) = to_char(FND_API.G_MISS_DATE));
        -- Bug Fix: 4741111: Added the clause to look for pending users

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering getRequesterUsername (' ||
        userID || ') API');

  open getUserNameCursor;
  fetch getUserNameCursor into requesterUsername;
  if (getUserNameCursor%notfound) then
    close getUserNameCursor;
    raise_application_error (-20000, 'requester username is not found while calling JTF_UM_WF_APPROVAL.getRequesterUsername');
  end if;
  close getUserNameCursor;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting getRequesterUsername API');

  return requesterUsername;
end getRequesterUsername;

-- Return the userid from username
function getUserID (username in varchar2) return fnd_user.user_id%type is

userId fnd_user.user_id%type;

cursor getUserIDCursor is
        select  user_id
        from    FND_USER
        where   USER_NAME = username
        and     (nvl (END_DATE, sysdate + 1) > sysdate OR
               to_char(END_DATE) = to_char(FND_API.G_MISS_DATE));

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering getUserID (' ||
        userID || ') API');

  open getUserIDCursor;
  fetch getUserIDCursor into userId;
  if (getUserIDCursor%notfound) then
    close getUserIDCursor;
    raise_application_error (-20000, 'userId is not found while calling JTF_UM_WF_APPROVAL.getUserID');
  end if;
  close getUserIDCursor;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting getUserID API');

  return userId;
end getUserID;

  --
  --
  -- Procedure
  --    get_wf_owner_username (PRIVATE)
  --
  -- Description
  --    Return the workflow owner username from the fnd profile option
  -- IN
  --    p_request_id - request type id (Usertype ID or Enrollment ID)
  --    p_request_type    - The type of request type, either 'USERTYPE' or
  --                      'ENROLLMENT
  --
  function get_wf_owner_username (p_request_id in number,
                                  p_request_type in varchar2) return varchar2 is

    l_method_name     varchar2 (21) := 'GET_WF_OWNER_USERNAME';
    l_application_id  JTF_UM_USERTYPES_B.APPLICATION_ID%TYPE;
    l_owner_username  varchar2 (100);

  begin

    -- Log the entering
    JTF_DEBUG_PUB.LOG_ENTERING_METHOD (G_MODULE, l_method_name);

    -- Log parameters
    if l_is_debug_parameter_on then
    JTF_DEBUG_PUB.LOG_PARAMETERS (G_MODULE || '.' || l_method_name,
                                  'p_request_id=' || p_request_id);
    JTF_DEBUG_PUB.LOG_PARAMETERS (G_MODULE || '.' || l_method_name,
                                  'p_request_type=' || p_request_type);
    end if;

    l_application_id := getRequestApplId (p_request_type, p_request_id);

    l_owner_username := nvl (JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                            NAME           => 'JTF_UM_APPROVAL_OWNER',
                            APPLICATION_ID => l_application_id,
                            SITE_LEVEL     => true), 'SYSADMIN');

    JTF_DEBUG_PUB.LOG_EXITING_METHOD (G_MODULE, l_method_name);

    return l_owner_username;

  end get_wf_owner_username;

  --
  --
  -- Procedure
  --    get_org_info (PRIVATE)
  --
  -- Description
  --    Return the organization information of the user.
  -- IN
  --    p_user_id - fnd user_id
  -- OUT
  --    x_org_name - organization's name
  --    x_org_number - organization's number
  --
  procedure get_org_info (p_user_id    in  fnd_user.user_id%type,
                          x_org_name   out NOCOPY hz_parties.party_name%type,
                          x_org_number out NOCOPY hz_parties.party_number%type) is

  l_method_name varchar2 (12) := 'GET_ORG_INFO';

  cursor getOrgNameAndNumber is
    select hz.party_name, hz.party_number
    from fnd_user fnd, hz_parties hz, hz_relationships hzr
    where fnd.user_id = p_user_id
    and fnd.customer_id = hzr.party_id
    and hzr.start_date <= sysdate
    and nvl (hzr.end_date, sysdate + 1) > sysdate
    and hzr.relationship_code in ('EMPLOYEE_OF','CONTACT_OF')
    and hzr.object_table_name = 'HZ_PARTIES'
    and hzr.subject_table_name = 'HZ_PARTIES'
    and hzr.object_id = hz.party_id;

  begin

    -- Log the entering
    JTF_DEBUG_PUB.LOG_ENTERING_METHOD (G_MODULE, l_method_name);

    -- Log parameters
    if l_is_debug_parameter_on then
    JTF_DEBUG_PUB.LOG_PARAMETERS (G_MODULE || '.' || l_method_name,
                                  'p_user_id=' || p_user_id);
    end if;
    open getOrgNameAndNumber;
    fetch getOrgNameAndNumber into x_org_name, x_org_number;
    close getOrgNameAndNumber;


    JTF_DEBUG_PUB.LOG_EXITING_METHOD (G_MODULE, l_method_name);

  end get_org_info;

--
-- Procedure
--      ValidateWF
--
-- Description
--      Check if the required workflow attributes are defined in the WF.
-- IN
--   itemtype -- The itemtype of the workflow.
--
procedure ValidateWF (itemtype in varchar2) is

l_atype   varchar2 (8);
l_subtype varchar2 (8);
l_format  varchar2 (240);

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering ValidateWF (' ||
        itemtype || ') API');

  wf_engine.getItemAttrInfo (itemtype, 'REQUEST_TYPE', l_atype, l_subtype, l_format);
  wf_engine.getItemAttrInfo (itemtype, 'REQUEST_ID', l_atype, l_subtype, l_format);
  wf_engine.getItemAttrInfo (itemtype, 'REQUESTER_USER_ID', l_atype, l_subtype, l_format);
  wf_engine.getItemAttrInfo (itemtype, 'REQUESTER_USERTYPE_ID', l_atype, l_subtype, l_format);
  wf_engine.getItemAttrInfo (itemtype, 'APPROVAL_ID', l_atype, l_subtype, l_format);
  wf_engine.getItemAttrInfo (itemtype, 'APPROVER_ID', l_atype, l_subtype, l_format);
  wf_engine.getItemAttrInfo (itemtype, 'APPROVER_COMMENT', l_atype, l_subtype, l_format);

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting ValidateWF API');

exception
  when others then
    raise;
end ValidateWF;

--
-- Procedure
--      CreateProcess
--
-- Description
--      Initiate workflow for a um approval
--      This API will not launch the workflow process.
--      To launch workflow process, call LaunchProcess.
-- IN
--   ownerUserID     -- The FND userID of the workflow owner
--   requestType     -- The type of request, 'ENROLLMENT/USERTYPE'
--   requestID       -- ID of the request.
--   requesterUserID -- The FND userID of the requester
--   requestRegID    -- USERTYPE_REG_ID or SUBSCRIPTION_REG_ID
--
procedure CreateProcess (ownerUserId     in number := null,
                         requestType     in varchar2,
                         requestID       in number,
                         requesterUserID in number,
                         requestRegID    in number) is

itemtype            varchar2 (8);
itemkey             number := requestRegID;
itemUserKey         wf_items.user_key%type;
userID              number;
requesterUsername   fnd_user.user_name%type;
requesterUsertypeID number;
approvalID          number;
usePendingReqFlag   varchar2 (1);
processOwner        varchar2 (100);

cursor usertypeApprovalCursor is
        select  APPROVAL_ID
        from    JTF_UM_USERTYPES_B
        where   USERTYPE_ID = requestID;

cursor enrollApprovalCursor is
        select  APPROVAL_ID
        from    JTF_UM_SUBSCRIPTIONS_B
        where   SUBSCRIPTION_ID = requestID;

cursor getUsertypeIdCursor is
        select  USERTYPE_ID
        from    JTF_UM_USERTYPE_REG
        where   USER_ID = requesterUserID
		and 	STATUS_CODE <>'REJECTED'
        and     EFFECTIVE_START_DATE <= sysdate
        and     nvl (EFFECTIVE_END_DATE, sysdate + 1) > sysdate;

cursor approvalCursor is
        select  USE_PENDING_REQ_FLAG
        from    JTF_UM_APPROVALS_B
        where   APPROVAL_ID = approvalID
        and     EFFECTIVE_START_DATE <= sysdate
        and     nvl (EFFECTIVE_END_DATE, sysdate + 1) > sysdate;

cursor wfApprovalCursor is
        select  WF_ITEM_TYPE
        from    JTF_UM_APPROVALS_B
        where   APPROVAL_ID = approvalID;
--

begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering CreateProcess (' ||
            ownerUserId || ',' || requestType || ',' || requestID || ',' ||
            requesterUserID || ',' ||  requestRegID || ') API');

        -- Check input parameter
        if (requestType is null) then
          raise_application_error (-20000, 'requestType is null when calling JTF_UM_WF_APPROVAL.CreateProcess.');
        end if;

        if (requestID is null) then
          raise_application_error (-20000, 'requestID is null when calling JTF_UM_WF_APPROVAL.CreateProcess.');
        end if;

        if (requesterUserID is null) then
          raise_application_error (-20000, 'requesterUserID is null when calling JTF_UM_WF_APPROVAL.CreateProcess.');
        end if;

        if (requestRegID is null) then
          raise_application_error (-20000, 'requestRegID is null when calling JTF_UM_WF_APPROVAL.CreateProcess.');
        end if;

        -- Get the approvalID
        if (requestType = 'USERTYPE') then
          open usertypeApprovalCursor;
          fetch usertypeApprovalCursor into approvalID;
          if (usertypeApprovalCursor%notfound) then
            close usertypeApprovalCursor;
            raise_application_error (-20000, 'ApprovalID is not found when calling JTF_UM_WF_APPROVAL.CreateProcess requestType='||requestType||'.');
          end if;
          close usertypeApprovalCursor;
          requesterUsertypeID := requestId;
        else
          open enrollApprovalCursor;
          fetch enrollApprovalCursor into approvalID;
          if (enrollApprovalCursor%notfound) then
            close enrollApprovalCursor;
            raise_application_error (-20000, 'ApprovalID is not found when calling JTF_UM_WF_APPROVAL.CreateProcess requestType='||requestType||'.');
          end if;
          close enrollApprovalCursor;
          -- Get the requesterUsertypeID
          open getUsertypeIdCursor;
          fetch getUsertypeIdCursor into requesterUsertypeID;
          if (getUsertypeIdCursor%notfound) then
            close getUsertypeIdCursor;
            raise_application_error (-20000, 'requesterUsertypeID is not found when calling JTF_UM_WF_APPROVAL.CreateProcess.');
          end if;
          close getUsertypeIdCursor;
        end if;


        -- Get itemtype.  Return if notfound or is null
        open wfApprovalCursor;
        fetch wfApprovalCursor into itemtype;
        if (wfApprovalCursor%notfound) then
          close wfApprovalCursor;
          raise_application_error (-20000, 'Cannot find Approval from CreateProcess');
        end if;
        close wfApprovalCursor;

        -- Get the requester Username.
        userId := requesterUserID;
        requesterUsername := getRequesterUsername (requesterUserID);
        -- this should check whether the user is end dated, if so the account
        -- has already been rejected.

        -- the WF process owner should be the merchant sysadmin
        processOwner := get_wf_owner_username (p_request_id   => requestID,
                                               p_request_type => requestType);


		--
        -- Start Process
        --
        wf_engine.CreateProcess (itemtype => itemtype,
                                 itemkey  => itemkey);
        --
        itemUserKey := substrb (requesterUsername || ' requests for ' || requestType || ' : '|| getRequestName (requestType, requestId), 1, 238);



        wf_engine.SetItemUserKey (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  UserKey  => itemUserKey);
        --
        -- Initialize workflow item attributes
        --
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_TYPE',
                                   avalue   =>  requestType);

        wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'REQUEST_ID',
                                     avalue   => requestID);

        wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'REQUESTER_USER_ID',
                                     avalue   => requesterUserID);

        wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'REQUESTER_USERTYPE_ID',
                                     avalue   => requesterUsertypeID);

        wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVAL_ID',
                                     avalue   => approvalID);

        wf_engine.SetItemOwner (itemtype => itemtype,
                                itemkey  => itemkey,
                                owner    => processOwner);



        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting CreateProcess API');

end CreateProcess;

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
                         requestRegID    in number) is

cursor get_ut_itemtype is
select WF_ITEM_TYPE
from   JTF_UM_USERTYPE_REG
where  USERTYPE_REG_ID = requestRegID;

cursor get_enroll_itemtype is
select WF_ITEM_TYPE
from   JTF_UM_SUBSCRIPTION_REG
where  SUBSCRIPTION_REG_ID = requestRegID;

itemtype varchar2 (8);

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering LaunchProcess (' ||
        requestType || ',' || requestRegID || ') API');

  -- Get the WF item type from the reg table
  -- If WF item type is missing, raise an exception.
  if (requestType = 'USERTYPE') then

    open get_ut_itemtype;
    fetch get_ut_itemtype into itemtype;
    if (get_ut_itemtype%notfound) then
      close get_ut_itemtype;
      raise_application_error ('20000', 'Workflow itemtype is missing in the JTF_UM_USERTYPE_REG table with USERTYPE_REG_ID: ' || requestRegID);
    end if;
    close get_ut_itemtype;

  elsif (requestType = 'ENROLLMENT') then

    open get_enroll_itemtype;
    fetch get_enroll_itemtype into itemtype;
    if (get_enroll_itemtype%notfound) then
      close get_enroll_itemtype;
      raise_application_error ('20000', 'Workflow itemtype is missing in the JTF_UM_SUBSCRIPTION_REG table with SUBSCRIPTION_REG_ID: ' || requestRegID);
    end if;
    close get_enroll_itemtype;

  else
    raise_application_error ('20000', 'Not a valid request type: ' || requestType);
  end if;

  wf_engine.startProcess (itemtype => itemType,
                          itemkey  => to_char(requestRegID));

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting LaunchProcess API');

end LaunchProcess;

--
-- Procedure
--      Selector
--
-- Description
--      Determine which process to run
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   resultout - Name of workflow process to run
--
procedure Selector (item_type    in  varchar2,
                    item_key     in  varchar2,
                    activity_id  in  number,
                    command      in  varchar2,
                    resultout    out NOCOPY varchar2) is
--
begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering Selector (' ||
              item_type || ',' || item_key || ',' || activity_id || ',' ||
              command || ') API');

        --
        -- RUN mode - normal process execution
        --
        if (command = 'RUN') then
                --
                -- Return process to run
                --
                resultout := 'UM_APPROVAL';
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Selector API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'Selector', item_type, item_key, to_char (activity_id), command);
                raise;
end selector;

--
-- Initialization
-- DESCRIPTION
--   To initialize other variable(s)
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:'
--
procedure Initialization (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2) is
--
applicationURL    fnd_profile_option_values.profile_option_value%type;
applID            number;
approvalID        number;
approvalURL       fnd_profile_option_values.profile_option_value%type;
companyNumber     number;
senderName        fnd_profile_option_values.profile_option_value%type;
ownerUsername     fnd_user.user_name%type;
requesterUserID   fnd_user.user_id%type;
requesterUserName fnd_user.user_name%type;
requestId         number;
requestName       varchar2 (1000);
requestType       varchar2 (10);
respApplID        number;
responID          number;
supportContact    fnd_profile_option_values.profile_option_value%type;
timeout           number;
usertypeId        jtf_um_usertypes_b.usertype_id%type;
usertypeKey       jtf_um_usertypes_b.usertype_key%type;
usertypeName      jtf_um_usertypes_tl.usertype_name%type;
MISSING_REQUESTER_USER_ID exception;
x_wf_dispname		WF_LOCAL_ROLES.DISPLAY_NAME%TYPE;
Email_Address   WF_LOCAL_ROLES.EMAIL_ADDRESS%TYPE;
x_role_name	WF_LOCAL_ROLES.NAME%TYPE;
l_approver_display_name varchar2(1000);
l_role_name wf_local_roles.name%type;
l_notif_pref WF_LOCAL_ROLES.NOTIFICATION_PREFERENCE%TYPE;

--
cursor getCompanyNumber is
        select hz.party_number
        from   hz_parties hz, hz_relationships hzr, fnd_user fnd
        where  fnd.user_id = requesterUserID
        and    fnd.customer_id = hzr.party_id
        and    hzr.start_date <= sysdate
        and    nvl (hzr.end_date, sysdate + 1) > sysdate
	and    hzr.relationship_code in ('EMPLOYEE_OF','CONTACT_OF')
        and    hzr.object_table_name = 'HZ_PARTIES'
        and    hzr.subject_table_name = 'HZ_PARTIES'
        and    hzr.object_id = hz.party_id;

cursor getUsertypeKey is
        select USERTYPE_KEY
        from   JTF_UM_USERTYPES_B
        where  USERTYPE_ID = usertypeId
        and    nvl (EFFECTIVE_END_DATE, sysdate + 1) > sysdate;

cursor getUTRespApplID is
        select rvl.responsibility_id, rvl.application_id
        from   fnd_responsibility_vl rvl, jtf_um_usertype_resp utr
        where  utr.usertype_id = requestId
        and    utr.responsibility_key = rvl.responsibility_key
        and    nvl (rvl.end_date, sysdate + 1) > sysdate
        and    nvl (utr.effective_end_date, sysdate + 1) > sysdate
        and    rvl.version in ('W','4');

cursor getEnrollRespApplID is
        select rvl.responsibility_id, rvl.application_id
        from   fnd_responsibility_vl rvl, jtf_um_subscription_resp utr
        where  utr.subscription_id = requestId
        and    utr.responsibility_key = rvl.responsibility_key
        and    nvl (rvl.end_date, sysdate + 1) > sysdate
        and    nvl (utr.effective_end_date, sysdate + 1) > sysdate
        and    rvl.version in ('W','4');

cursor getEmailAddress is
	select email_address from wf_local_roles where name=upper(requesterUserName);

--------------Bug No: 	7270214-------------------

 cursor getADHocRole is
    select name, display_name
    from WF_LOCAL_ROLES
    where name = x_role_name;
--------------Bug No: 	7270214-------------------


begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering Initialization (' ||
              itemtype || ',' || itemkey || ',' || actid || ',' ||
              funcmode || ') API');

        --
        -- RUN mode - normal process execution
        --
        if (funcmode = 'RUN') then
                approvalID := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'APPROVAL_ID');

                requesterUserID := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUESTER_USER_ID');

                requestType := wf_engine.GetItemAttrText (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUEST_TYPE');

                requestId := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUEST_ID');

                usertypeId := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUESTER_USERTYPE_ID');

                usertypeName := getRequestName ('USERTYPE', usertypeId);
                if requestType = 'USERTYPE' then
                  requestName := usertypeName;
                else
                  requestName := getRequestName (requestType, requestId);
                end if;

                wf_engine.SetItemAttrText (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUEST_NAME',
                    avalue   => requestName);

                wf_engine.SetItemAttrText (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUESTER_USERTYPE_NAME',
                    avalue   => usertypeName);

                -- Need to get the approval URL from the profile option
                -- But first, we need responsibility_id and application_id of
                -- the responsibility.
                if (requestType = 'USERTYPE') then
                  open getUTRespApplID;
                  fetch getUTRespApplID into responID, respApplID;
                  close getUTRespApplID;
                else
                  -- requestType = 'ENROLLMENT'
                  open getEnrollRespApplID;
                  fetch getEnrollRespApplID into responID, respApplID;
                  close getEnrollRespApplID;
                end if;

                -- Get the application id of the requestType
                applID := getRequestApplId (requestType, requestId);

                -- Set the approval url
                -- first get the approval url from the profile option
                approvalURL := JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                                NAME              => 'JTF_UM_APPROVAL_URL',
                                RESPONSIBILITY_ID => responID,
                                RESP_APPL_ID      => respApplID,
                                APPLICATION_ID    => applID,
                                SITE_LEVEL        => true);

                wf_engine.SetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'APPROVAL_URL',
                                           avalue   => approvalURL);

                -- Set the Owner UserID
                -- first get the userID from the profile option
                ownerUsername := get_wf_owner_username (
                    p_request_id   => requestID,
                    p_request_type => requestType);

                wf_engine.SetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'OWNER_USERNAME',
                                           avalue   =>  ownerUsername);

                -- Set the timeout value
                -- first get the timeout from the profile option
                timeout := nvl (JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                               NAME           => 'JTF_UM_APPROVAL_TIMEOUT_MINS',
                               APPLICATION_ID => applID,
                               SITE_LEVEL     => true), 0);

                wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'MIN_TO_TIMEOUT',
                                             avalue   => timeout);

                -- Set the application url
                -- first get the application url from the profile option
                applicationURL := JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                                NAME              => 'JTA_UM_APPL_URL',
                                RESPONSIBILITY_ID => responID,
                                RESP_APPL_ID      => respApplID,
                                APPLICATION_ID    => applID,
                                SITE_LEVEL        => true);

                wf_engine.SetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'APPLICATION_URL',
                                           avalue   => applicationURL);

                -- Set the sender name
                -- first get the sender name from the profile option
                senderName := JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                               NAME           => 'JTA_UM_SENDER',
                               APPLICATION_ID => applID,
                               SITE_LEVEL     => true);

                wf_engine.SetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'SENDER_NAME',
                                           avalue   => senderName);

                -- Set the Support Contact
                -- first get the Support Contact name from the profile option
                supportContact := JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                    NAME              => 'JTA_UM_SUPPORT_CONTACT',
                    RESPONSIBILITY_ID => responID,
                    RESP_APPL_ID      => respApplID,
                    APPLICATION_ID    => applID,
                    SITE_LEVEL        => true);

                wf_engine.SetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'SUPPORT_CONTACT',
                                           avalue   => supportContact);

                -- get the usertype key from usertype id
                open getUsertypeKey;
                fetch getUsertypeKey into usertypeKey;
                close getUsertypeKey;

                if (requestType = 'USERTYPE') and ((usertypeKey = 'PRIMARYUSER') or (usertypeKey = 'PRIMARYUSERNEW')) then
                  open getCompanyNumber;
                  fetch getCompanyNumber into companyNumber;
                  close getCompanyNumber;

                  wf_engine.SetItemAttrText (
                      itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'COMPANY_NUMBER',
                      avalue   => to_char(companyNumber));

                end if;

                -- Get the requester Username.
                requesterUserName := getRequesterUsername (requesterUserID);

                wf_engine.SetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'REQUESTER_USERNAME',
                                           avalue   => requesterUserName);


                wf_engine.SetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'REQUESTER_USERNAME_DISPLAY',
                                           avalue   => lower (requesterUserName));

		-- set the ad hoc role
		x_role_name:='__JTA_UM' || itemkey;

		open getEmailAddress;
		fetch getEmailAddress into Email_Address;

		x_wf_dispname :=requesterUserName;


--------------Bug No: 	7661549-------------------
            l_notif_pref := fnd_profile.value_specific('JTA_UM_MAIL_PREFERENCE');   --added for bug# 7661549
            l_role_name := null;
--------------Bug No: 	7270214-------------------
            open getADHocRole;
            fetch getADHocRole into l_role_name, l_approver_display_name;
            close getADHocRole;

              if (l_role_name is null) then
		        WF_DIRECTORY.CreateAdHocRole(role_name => x_role_name, role_display_name =>x_wf_dispname, email_address => Email_Address,  notification_preference =>nvl(l_notif_pref,'MAILHTML') );
			  else
			    WF_DIRECTORY.SetAdHocRoleAttr(role_name=> x_role_name,email_address => Email_Address);
			  end if;

--------------Bug No: 	7270214-------------------
--------------Bug No: 	7661549-------------------
		wf_engine.SetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'USER_AD_HOC_ROLE',
                                           avalue   => x_role_name);

                resultout := 'COMPLETE:';
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Initialization API');

exception
        when MISSING_REQUESTER_USER_ID then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'Initialization', itemtype, itemkey, to_char (actid), funcmode,
                'Requester User ID is missing in the FND_USER');
                raise;
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'Initialization', itemtype, itemkey, to_char (actid), funcmode);
                raise;
end Initialization;

/**
 * Procedure: get_org_ad_hoc_role
 * Type: Private
 * Prereqs:
 * Description: This API will
 *                1) create/update an ad hoc role with named "JTAUM###".
 *                2) find all approvers from the same organization and with
 *                   "JTF_PRIMARY_USER_SUMMARY" permission.
 *                3) associate the ad hoc role with approvers
 * Parameters
 * input parameters: p_itemtype - itemtype of the workflow
 *                   p_itemkey  - itemkey of the workflow
 * output parameters: x_role_name - The name of the ad hoc role, null if
 *                                  role didn't get created.
 *                    x_role_name_display - The display name of the ad hoc role.
 * Errors:
 * Other Comments:
 */
procedure get_org_ad_hoc_role (p_itemtype  in  varchar2,
                               p_itemkey   in  varchar2,
                               x_role_name out NOCOPY varchar2,
                               x_role_name_display out NOCOPY varchar2) is

  l_method_name varchar2 (20) := 'GET_ORG_AD_HOC_ROLE';
  l_requester_user_id fnd_user.user_id%type;
  l_org_name hz_parties.party_name%type;
  l_org_number hz_parties.party_number%type;
  l_uni_approver_not_found boolean := true;
  l_role_name wf_local_roles.name%type;
  l_approver_display_name varchar2(1000);
  l_notif_pref WF_LOCAL_ROLES.NOTIFICATION_PREFERENCE%TYPE;

  cursor getADHocRole is
    select name, display_name
    from WF_LOCAL_ROLES
    where name = x_role_name;

  cursor getUniversalApprovers is
      select fnd.user_name
      from hz_parties hz_org, hz_relationships hzr, fnd_user fnd
      where hz_org.party_number = l_org_number
      and hz_org.party_type = 'ORGANIZATION'
      and hz_org.party_id = hzr.object_id
      and hzr.start_date <= sysdate
      and nvl (hzr.end_date, sysdate + 1) > sysdate
      and hzr.relationship_code = 'EMPLOYEE_OF'
      and hzr.object_table_name = 'HZ_PARTIES'
      and hzr.subject_table_name = 'HZ_PARTIES'
      and fnd.customer_id = hzr.party_id
      and fnd.start_date <= sysdate
      and nvl (fnd.end_date, sysdate + 1) > sysdate

      and exists (
          select prin_b.principal_name
          from jtf_auth_domains_b domains_b, jtf_auth_permissions_b perm,
          jtf_auth_principal_maps prin_maps, jtf_auth_role_perms role_perms,
          jtf_auth_principals_b prin_b, jtf_auth_principals_b prin_b2
          where prin_b.jtf_auth_principal_id = prin_maps.jtf_auth_principal_id
          and prin_maps.jtf_auth_parent_principal_id = prin_b2.jtf_auth_principal_id
          and prin_b2.jtf_auth_principal_id = role_perms.jtf_auth_principal_id
          and role_perms.jtf_auth_permission_id = perm.jtf_auth_permission_id
          and prin_maps.jtf_auth_domain_id = domains_b.jtf_auth_domain_id
          and domains_b.domain_name = 'CRM_DOMAIN'
          and perm.permission_name = 'JTF_PRIMARY_USER_SUMMARY'
          and prin_b.principal_name = fnd.user_name
      );
--changes for 4734470

UserTable WF_DIRECTORY.UserTable;
idx pls_integer :=0;

begin

  -- Log the entering
  JTF_DEBUG_PUB.LOG_ENTERING_METHOD (G_MODULE, l_method_name);

  -- Log parameters
  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS (G_MODULE || '.' || l_method_name,
                                'p_itemtype=' || p_itemtype);
  JTF_DEBUG_PUB.LOG_PARAMETERS (G_MODULE || '.' || l_method_name,
                                'p_itemkey=' || p_itemkey);
  end if;

  -- to construct the roleName, we need the organization number
  -- get the user id and find out what is his/her org number
  l_requester_user_id := wf_engine.GetItemAttrNumber (
      itemtype => p_itemtype,
      itemkey  => p_itemkey,
      aname    => 'REQUESTER_USER_ID');

  -- get the organization number
  get_org_info (p_user_id    => l_requester_user_id,
                x_org_name   => l_org_name,
                x_org_number => l_org_number);

  -- the name of the role
  x_role_name := g_adhoc_role_name_prefix || l_org_number;

  open getAdHocRole;
  fetch getAdHocRole into l_role_name, l_approver_display_name;
  if (getAdHocRole%found) then
    -- Update role
    WF_DIRECTORY.RemoveUsersFromAdHocRole (role_name => x_role_name);
  else
    -- Get the role display name from FND Message.
    fnd_message.set_name ('JTF', 'JTA_UM_APPROVAL_ROLE_DISP_NAME');
    fnd_message.set_token ('ORGNAME', l_org_name, false);
    fnd_message.set_token ('ORGNUMBER', l_org_number, false);
    l_approver_display_name := fnd_message.get;

    x_role_name_display:= substr(l_approver_display_name, 1, 100);

    -- Create role
    -- Changes for Bug 6010991
    -- restore to behaviour, prior to bug Bug 3361734,
    -- of JTA Ad Hoc Roles having notification pref of MAILHTML
    --
    l_notif_pref := nvl(fnd_profile.value_specific('JTA_UM_MAIL_PREFERENCE'),'MAILHTML'); --added for bug# 7661549
    WF_DIRECTORY.CreateAdHocRole (role_name => x_role_name,
                                  role_display_name => x_role_name_display,
				                  notification_preference =>l_notif_pref
				                  );
    -- End of changes for Bug 6010991
  end if;
  close getAdHocRole;

  for approver in getUniversalApprovers loop
    userTable(idx) := approver.user_name;
    idx :=idx + 1;
  end loop;
  If userTable.count >0 then
    l_uni_approver_not_found := false;
     WF_DIRECTORY.AddUsersToAdHocRole2 (role_name  => x_role_name,
                                      role_users => userTable);
 end if;

  if l_uni_approver_not_found then
    x_role_name := null;
  end if;

  JTF_DEBUG_PUB.LOG_EXITING_METHOD (G_MODULE, l_method_name);

end get_org_ad_hoc_role;

--
-- SelectApprover
-- DESCRIPTION
--   Select the next approver from the approver order.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:T' if there is a next approver
--                - 'COMPLETE:F' if there is not a next approver
--
procedure SelectApprover (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2) is
--
applID           number;
approverID       number   (15);
approverUsername fnd_user.user_name%type;
approverUserID   fnd_user.user_id%type;
requestType      varchar2 (10);
requestId        number;
resultType       varchar2 (5);
uniPrimaryUser   fnd_profile_option_values.profile_option_value%type;
l_approver_username_display varchar2 (100);

begin
  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering SelectApprover (' ||
        itemtype || ',' || itemkey || ',' || actid || ',' ||
        funcmode || ') API');

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then
    --
    -- Call API to retrieve the next approver.
    --
    GetApprover (itemtype, itemkey, approverUsername, approverUserID, approverID, resultType);

    --
    -- There are two resultTypes from GetApprover.
    -- OK - The api returns the next approver.
    -- END - There is no more approver in the approver order.
    --
    if (resultType = 'END') then
      -- Can't find any approver from GetApprover
      resultout := 'COMPLETE:F';
    else
      resultout := 'COMPLETE:T';

      -- Check to see if the approver is a Universal Approver
      -- Get the application id of the requestType
      requestType := wf_engine.GetItemAttrText (
          itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'REQUEST_TYPE');

      requestId := wf_engine.GetItemAttrNumber (
                     itemtype => itemtype,
                     itemkey  => itemkey,
                     aname    => 'REQUEST_ID');

      applID := getRequestApplId (requestType, requestId);

      uniPrimaryUser := JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                         NAME           => 'JTF_PRIMARY_USER',
                         APPLICATION_ID => applID,
                         SITE_LEVEL     => true);

      if (approverUsername = uniPrimaryUser) then
        -- the current approver is a Universal Approver
        get_org_ad_hoc_role (p_itemtype          => itemtype,
                             p_itemkey           => itemkey,
                             x_role_name         => approverUsername,
                             x_role_name_display => l_approver_username_display);
        if (approverUsername is null) then
          -- Which mean an ad hoc role didn't get created.  Use
          -- the default approver from the JTA_UM_DEFAULT_APPROVER
          -- profile option.
          approverUsername := nvl (JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                                  NAME           => 'JTA_UM_DEFAULT_APPROVER',
                                  APPLICATION_ID => applID,
                                  SITE_LEVEL     => true), 'SYSADMIN');

          l_approver_username_display := lower (approverUsername);
          approverUserID := getUserID (username => approverUsername);
        end if;
      else
        l_approver_username_display := lower (approverUsername);
      end if;

      -- We need to update the approver username and id
      wf_engine.SetItemAttrText (
          itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'APPROVER_USERNAME',
          avalue   =>  approverUsername);

      wf_engine.SetItemAttrText (
          itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'APPROVER_USERNAME_DISPLAY',
          avalue   =>  l_approver_username_display);

      wf_engine.SetItemAttrNumber (
          itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'APPROVER_ID',
          avalue   => approverID);

      -- update the APPROVER_USER_ID in the ****_REG table.
      requestType := wf_engine.GetItemAttrText (
          itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'REQUEST_TYPE');
      if (requestType = 'USERTYPE') then
        update JTF_UM_USERTYPE_REG
        set    LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
               LAST_UPDATE_DATE = sysdate,
               APPROVER_USER_ID = approverUserID
        where  USERTYPE_REG_ID  = itemkey;
      else
        update JTF_UM_SUBSCRIPTION_REG
        set    LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
               LAST_UPDATE_DATE = sysdate,
               APPROVER_USER_ID = approverUserID
        where  SUBSCRIPTION_REG_ID = itemkey;
      end if;
    end if;
    --
  end if;

  --
  -- CANCEL mode
  --
  if (funcmode = 'CANCEL') then
    --
    resultout := 'COMPLETE:';
    --
  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Initialization API');

exception
  when others then
    wf_core.context ('JTF_UM_WF_APPROVAL', 'SelectorApprover', itemtype,
        itemkey, to_char (actid), funcmode);
    raise;
end SelectApprover;

--
-- Procedure
--      GetApprover
--
-- Description
--      Private method to get the next approver
-- IN
--      itemtype - workflow itemtype
--      itemkey  - workflow itemkey
-- Out
--      approver's user_name
--      approver's user ID
--      approver ID
--      resultType - 'OK' return next approver.
--                   'END' no more approver in the approver list.
--
Procedure GetApprover (x_itemtype         in  varchar2,
                       x_itemkey          in  varchar2,
                       x_approverUsername out NOCOPY varchar2,
                       x_approverUserID   out NOCOPY number,
                       x_approverID       out NOCOPY number,
                       x_resultType       out NOCOPY varchar2) is
--
l_approvalID      number   (15);
l_approverSeq     number   (15);
l_requesterUserID number   (15);
l_requestType     varchar2 (10);
l_org_party_id    number;
l_org_override    varchar2 (1);
--
cursor approverSequenceCursor is
        select  APPROVER_SEQ
        from    JTF_UM_APPROVERS
        where   APPROVER_ID = x_approverID
        and     APPROVAL_ID = l_approvalID;

cursor nextApproverInfoCursor is
        select  a.APPROVER_ID, a.USER_ID, f.USER_NAME
        from    JTF_UM_APPROVERS a, FND_USER f
        where   a.APPROVER_SEQ > l_approverSeq
        and     a.APPROVAL_ID = l_approvalID
        and     a.org_party_id is null
        and     a.EFFECTIVE_START_DATE <= sysdate
        and     nvl (a.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
        and     a.USER_ID = f.USER_ID
        and     f.START_DATE <= sysdate
        and     nvl (f.END_DATE, sysdate + 1) > sysdate

        order by a.APPROVER_SEQ;

cursor nextOrgApproverInfoCursor is
        select  a.APPROVER_ID, a.USER_ID, f.USER_NAME
        from    JTF_UM_APPROVERS a, FND_USER f
        where   a.APPROVER_SEQ > l_approverSeq
        and     a.APPROVAL_ID = l_approvalID
        and     a.ORG_PARTY_ID = l_org_party_id
        and     a.EFFECTIVE_START_DATE <= sysdate
        and     nvl (a.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
        and     a.USER_ID = f.USER_ID
        and     f.START_DATE <= sysdate
        and     nvl (f.END_DATE, sysdate + 1) > sysdate
        order by a.APPROVER_SEQ;


cursor OrgApproverOverrideCursor is
        select  'X'
        from    JTF_UM_APPROVERS a,
                FND_USER f
        where   a.APPROVAL_ID = l_approvalID
        and     a.ORG_PARTY_ID = l_org_party_id
        and     a.EFFECTIVE_START_DATE <= sysdate
        and     nvl (a.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
        and     a.USER_ID = f.USER_ID
        and     f.START_DATE <= sysdate
        and     nvl (f.END_DATE, sysdate + 1) > sysdate;

-- select the requesters org party id
cursor requesterOrgCursor is
        select  hzr.object_id requester_org_id
        from    hz_relationships hzr,
                FND_USER fu
        where   fu.USER_ID = l_requesterUserID
        and     fu.CUSTOMER_ID = hzr.PARTY_ID
        and     hzr.start_date <= sysdate
        and     nvl (hzr.END_DATE, sysdate + 1) > sysdate
	and     hzr.relationship_code in ('EMPLOYEE_OF','CONTACT_OF')
        and     hzr.object_type = 'ORGANIZATION'
        and     hzr.subject_table_name = 'HZ_PARTIES'
        and     hzr.object_table_name = 'HZ_PARTIES';
--
begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering GetApprover (' ||
              x_itemtype || ',' || x_itemkey || ') API');

        -- check input parameter
        if (x_itemtype is null) then
          raise_application_error (-20000, 'itemtype is null when calling JTF_UM_WF_APPROVAL.GetApprover');
        end if;

        if (x_itemkey is null) then
          raise_application_error (-20000, 'itemkey is null when calling JTF_UM_WF_APPROVAL.GetApprover');
        end if;

        x_resultType := 'OK';
        -- Get the APPROVER_ID and APPROVAL_ID
        x_approverID := wf_engine.GetItemAttrNumber (
            itemtype => x_itemtype,
            itemkey  => x_itemkey,
            aname    => 'APPROVER_ID');

        l_approvalID := wf_engine.GetItemAttrNumber (
            itemtype => x_itemtype,
            itemkey  => x_itemkey,
            aname    => 'APPROVAL_ID');

        l_requesterUserID := wf_engine.GetItemAttrNumber (
            itemtype => x_itemtype,
            itemkey  => x_itemkey,
            aname    => 'REQUESTER_USER_ID');

        l_requestType := wf_engine.GetItemAttrText (
            itemtype => x_itemtype,
            itemkey  => x_itemkey,
            aname    => 'REQUEST_TYPE');

        -- Get the requesters Organization Party Id
        -- if null, then we use the default approvers
        open  requesterOrgCursor;
        fetch requesterOrgCursor into l_org_party_id;
        -- Are there any org specific approvers for the requesters org?
        -- if not we use the default approvers
        if requesterOrgCursor%FOUND then
          open OrgApproverOverrideCursor;
          fetch OrgApproverOverrideCursor into l_org_override;
          close OrgApproverOverrideCursor;
        end if;
        close requesterOrgCursor;


        -- if APPROVER_ID is null, then approverSeq will be 1, the first approver.
        -- else, use the APPROVER_ID to find the next approver.
        if (x_approverID is null) then
          l_approverSeq := -1;
        else
          open approverSequenceCursor;
          fetch approverSequenceCursor into l_approverSeq;
          if (approverSequenceCursor%notfound) then
            -- ERROR, can't find the approver's sequence.
            close approverSequenceCursor;
            wf_core.token ('MESSAGE', 'Cannot find the current approver (user_id = '||to_char(x_approverId)
            ||' approval_id ='||to_char(l_approvalId)||') in JTF_UM_APPROVERS - Data corruption.');
            wf_core.raise ('MISSING_APPROVER_SEQUENCE');
          end if;
          close approverSequenceCursor;
        end if;

        -- If there are org specific approvers, get the first/next one
        if l_org_override is not null then
          open nextOrgApproverInfoCursor;
          fetch nextOrgApproverInfoCursor into x_approverID, x_approverUserID, x_approverUserName;
          if (nextOrgApproverInfoCursor%notfound) then
            -- No more approvers, result 'END' -
            x_resultType := 'END';
            close nextOrgApproverInfoCursor;
            JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting GetApprover API');
            return;
          end if;
          close nextOrgApproverInfoCursor;
        -- If we should use the default approvers, find the first / next one
        else

          open nextApproverInfoCursor;
          fetch nextApproverInfoCursor into x_approverID, x_approverUserID, x_approverUserName;
          if (nextApproverInfoCursor%notfound) then
             -- No more approvers, result 'END'
            x_resultType := 'END';
            close nextApproverInfoCursor;
            JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting GetApprover API');
            return;
          end if;
          close nextApproverInfoCursor;
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting GetApprover API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'GetApprover', x_itemtype, x_itemkey);
                raise;
end GetApprover;

--
-- SelectRequestType
-- DESCRIPTION
--   Return what requesttype that the requester is requesting.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:USERTYPE' if it is a usertype request
--                - 'COMPLETE:ENROLLMENT' if it is a enrollment request
--
procedure SelectRequestType (itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout out NOCOPY varchar2) is
--
requestType varchar2 (10);
--
begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering Initialization (' ||
              itemtype || ',' || itemkey || ',' || actid || ',' ||
              funcmode || ') API');

        --
        -- RUN mode - normal process execution
        --
        if (funcmode = 'RUN') then
                requestType := wf_engine.GetItemAttrText (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUEST_TYPE');
                if (requestType = 'USERTYPE') then
                  resultout := 'COMPLETE:USERTYPE';
                else
                  resultout := 'COMPLETE:ENROLLMENT';
                end if;
        --
        -- CANCEL mode
        --
        elsif (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                --
        --
        -- TIMEOUT mode
        --
        elsif (funcmode = 'TIMEOUT') then
                resultout := 'COMPLETE:';
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting SelectRequestType API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'SelectRequestType', itemtype, itemkey, to_char (actid), funcmode);
                raise;
end SelectRequestType;

--
-- cancel_notification
-- DESCRIPTION
--   Cancel all open notifications
-- IN
--   p_itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   p_itemkey   - A string generated from the application object's primary key.
--
procedure cancel_notification (p_itemtype  in varchar2,
                               p_itemkey   in varchar2) is
--
notificationID  number   (15);

cursor getNotificationID is
  select wias.notification_id
  from   wf_process_activities wpa, wf_item_activity_statuses wias, wf_notifications wn
  where  wpa.PROCESS_ITEM_TYPE = p_itemtype
  and    wpa.ACTIVITY_ITEM_TYPE = wpa.PROCESS_ITEM_TYPE
  and    (wpa.INSTANCE_LABEL = 'NTF_APPROVAL_USERTYPE_REQUIRED'
  or      wpa.INSTANCE_LABEL = 'NTF_REMIND_USERTYPE_REQUIRED'
  or      wpa.INSTANCE_LABEL = 'NTF_FAIL_ESCALATE_USERTYPE_REQ')
  and    wias.item_type = wpa.PROCESS_ITEM_TYPE
  and    wias.item_key = p_itemkey
  and    wias.process_activity = wpa.instance_id
  and    wn.status = 'OPEN'
  and    wn.notification_id = wias.notification_id;
--
begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering cancel_notification (' ||
        p_itemtype || ',' || p_itemkey || ') API');

  -- check input parameter
  if (p_itemtype is null) then
    raise_application_error (-20000, 'itemtype is null when calling JTF_UM_WF_APPROVAL.cancel_notification');
  end if;

  if (p_itemkey is null) then
    raise_application_error (-20000, 'itemkey is null when calling JTF_UM_WF_APPROVAL.cancel_notification');
  end if;

  -- Need to end all open notifications.
  open getNotificationID;
  -- We have two notification that we need to cancel.
  fetch getNotificationID into notificationID;
  while getNotificationID%found loop
    wf_notification.cancel (notificationID);
    fetch getNotificationID into notificationID;
  end loop;
  close getNotificationID;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting cancel_notification API');

end cancel_notification;

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
                                    resultout out NOCOPY varchar2) is
--
ownerUsername   varchar2 (100);
ownerUserID     number   (15);
requestType     varchar2 (10);

cursor getUserID is
  select  USER_ID
  from    FND_USER
  where   USER_NAME = ownerUsername;
--
begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE,
              'Entering initialize_fail_escalate (' || itemtype || ',' ||
              itemkey || ',' || actid || ',' || funcmode || ') API');

        --
        -- RUN mode
        --
        if (funcmode = 'RUN') then

          -- Need to end all open notifications.
          cancel_notification (itemtype, itemkey);

          -- The result of the request has not been decided
          -- Forward the request to the owner of this process.
          ownerUsername := wf_engine.GetItemAttrText (
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'OWNER_USERNAME');

          -- This is for the next activity in the workflow, can_delegate.
          wf_engine.SetItemAttrText (
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'APPROVER_USERNAME',
              avalue   =>  ownerUsername);

          open getUserID;
          fetch getUserID into ownerUserID;
          close getUserID;

          -- Get the requestType.
          requestType := wf_engine.GetItemAttrText (
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'REQUEST_TYPE');

          -- We need to update the approver id in the reg table
          if (requestType = 'USERTYPE') then
            update JTF_UM_USERTYPE_REG
            set    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                   LAST_UPDATE_DATE = sysdate,
                   APPROVER_USER_ID = ownerUserID
            where  USERTYPE_REG_ID = to_number(itemkey);
          elsif (requestType = 'ENROLLMENT') then
            update JTF_UM_SUBSCRIPTION_REG
            set    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                   LAST_UPDATE_DATE = sysdate,
                   APPROVER_USER_ID = ownerUserID
            where  SUBSCRIPTION_REG_ID = to_number(itemkey);
          end if;
          resultout := 'COMPLETE';
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting initialize_fail_escalate API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'initialize_fail_escalate', itemtype, itemkey, to_char (actid), funcmode);
                raise;
end initialize_fail_escalate;

--
-- WaitForApproval
-- DESCRIPTION
--   Check whether the task is approved or rejected.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout    - 'COMPLETE:APPROVED' if the request is approved.
--                - 'COMPLETE:REJECTED' if the request is rejected.
--
procedure WaitForApproval (itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout out NOCOPY varchar2) is
--
requestResult varchar2 (8);
--
begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering WaitForApproval (' ||
              itemtype || ',' || itemkey || ',' || actid || ',' ||
              funcmode || ') API');

        --
        -- RUN mode - normal process execution
        --
        if (funcmode = 'RUN') then
                requestResult := wf_engine.GetItemAttrText (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUEST_RESULT');

                if (requestResult = 'APPROVED') then
                  resultout := 'COMPLETE:APPROVED';
                elsif (requestResult = 'REJECTED') then
                  resultout := 'COMPLETE:REJECTED';
                else
                  fnd_message.set_name ('JTF', 'JTA_UM_REQUIRED_FIELD');
                  fnd_message.set_token ('API_NAME', itemtype, false);
                  fnd_message.set_token ('FIELD', 'REQUEST_RESULT', false);
                  raise_application_error(-20000, fnd_message.get);
                end if;

        --
        -- CANCEL mode
        --
        elsif (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                --

        --
        -- TIMEOUT mode
        --
        elsif (funcmode = 'TIMEOUT') then
                resultout := 'COMPLETE:';
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting WaitForApproval API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'WaitForApproval', itemtype, itemkey, to_char (actid), funcmode);
                raise;
end WaitForApproval;

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
                             resultout out NOCOPY varchar2) is
--
requestType       varchar2 (10);
userId            number;
l_permission_flag number;
l_return_status   varchar2 (1);

cursor getUserID is
  select  USER_ID
  from    FND_USER
  where   USER_NAME = WF_ENGINE.context_text;
--
begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering post_notification (' ||
              itemtype || ',' || itemkey || ',' || actid || ',' ||
              funcmode || ') API');

        --
        -- FORWARD or TRANSFER mode
        --
        if (funcmode = 'FORWARD') or (funcmode = 'TRANSFER') then
          -- Get the new recipient_role.  In our case, a new userID.
          open getUserID;
          fetch getUserID into userId;
          close getUserID;
          -- First verifty if the new userId has the valid permission
          -- Check if the user is the SYSADMIN
          JTF_AUTH_SECURITY_PKG.CHECK_PERMISSION (
              x_flag => l_permission_flag,
              x_return_status => l_return_status,
              p_user_name => WF_ENGINE.context_text,
              p_permission_name => 'JTF_REG_APPROVAL');
          if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          end if;

          if (l_permission_flag = 0) then
            -- Not a SYSADMIN, check if the user is a Primary User
            JTF_AUTH_SECURITY_PKG.CHECK_PERMISSION (
                x_flag => l_permission_flag,
                x_return_status => l_return_status,
                p_user_name => WF_ENGINE.context_text,
                p_permission_name => 'JTF_PRIMARY_USER_SUMMARY');
            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
          end if;

          if (l_permission_flag = 0) then
            -- Not a Primary User, check if the user is an Owner
            JTF_AUTH_SECURITY_PKG.CHECK_PERMISSION (
                x_flag => l_permission_flag,
                x_return_status => l_return_status,
                p_user_name => WF_ENGINE.context_text,
                p_permission_name => 'JTF_APPROVER');
            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
          end if;

          if (l_permission_flag = 0) then
            -- Doesn't have the permission to be an approver.
            fnd_message.set_name ('JTF', 'JTF_APPROVAL_PERMISSION');
            raise_application_error (-20000, fnd_message.get);
          else
            -- Get the requestType.
            requestType := wf_engine.GetItemAttrText (
                             itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'REQUEST_TYPE');
            --
            if (requestType = 'USERTYPE') then
              update JTF_UM_USERTYPE_REG
              set    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                     LAST_UPDATE_DATE = sysdate,
                     APPROVER_USER_ID = userId
              where  USERTYPE_REG_ID = to_number(itemkey);
            elsif (requestType = 'ENROLLMENT') then
              update JTF_UM_SUBSCRIPTION_REG
              set    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                     LAST_UPDATE_DATE = sysdate,
                     APPROVER_USER_ID = userId
              where  SUBSCRIPTION_REG_ID = to_number(itemkey);
            end if;
            resultout := 'COMPLETE';
          end if;
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting post_notification API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'post_notification', itemtype, itemkey, to_char (actid), funcmode);
                raise;
end post_notification;

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
                               resultout out NOCOPY varchar2) is

l_bool_flag       boolean;
l_flag            varchar2 (1);
l_request_id      number;
l_requesterUserID number;

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering store_delegate_flag (' ||
        itemtype || ',' || itemkey || ',' || actid || ',' ||
        funcmode || ') API');

  --
  -- FORWARD or TRANSFER mode
  --
  if (funcmode = 'RUN') then

    -- Save the Grant Delegation Flag
    l_flag := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DELEGATION_FLAG');

    l_request_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'REQUEST_ID');

    l_requesterUserID := wf_engine.GetItemAttrNumber (
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'REQUESTER_USER_ID');

    if (l_flag = 'Y') then
      l_bool_flag := true;
    else
      l_bool_flag := false;
    end if;

    JTF_UM_SUBSCRIPTIONS_PKG.UPDATE_GRANT_DELEGATION_FLAG (
        P_SUBSCRIPTION_ID       => l_request_id,
        P_USER_ID               => l_requesterUserID,
        P_GRANT_DELEGATION_FLAG => l_bool_flag);

  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting store_delegate_flag API');

exception
  when others then
--          wf_core.context ('JTF_UM_WF_APPROVAL', 'store_delegate_flag', itemtype, itemkey, to_char (actid), funcmode);
          raise;

end store_delegate_flag;

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
                          itemkey   in  varchar2) is
--
approverComment   varchar2 (4000);
requesterUserID   number   (15);
requestID         number   (15);
requestType       varchar2 (10);
requesterUsername varchar2 (100);
langProfileValue  varchar2 (240);
terrProfileValue  varchar2 (240);
profileSave       boolean;

cursor enrollmentNoApprovalCursor is
        select  SUBSCRIPTION_ID
        from    JTF_UM_SUBSCRIPTION_REG
        where   USER_ID = requesterUserID
        and     EFFECTIVE_START_DATE <= sysdate
        and     nvl (EFFECTIVE_END_DATE, sysdate + 1) > sysdate
        and     WF_ITEM_TYPE is null
        and     STATUS_CODE = 'PENDING';

cursor enrollmentApprovalCursor is
        select  WF_ITEM_TYPE, SUBSCRIPTION_REG_ID
        from    JTF_UM_SUBSCRIPTION_REG
        where   USER_ID = requesterUserID
        and     EFFECTIVE_START_DATE <= sysdate
        and     nvl (EFFECTIVE_END_DATE, sysdate + 1) > sysdate
        and     WF_ITEM_TYPE is not null
        and     STATUS_CODE = 'PENDING';

cursor requesterUserNameCursor is
        select  USER_NAME
        from    FND_USER
        where   USER_ID = requesterUserID
        and     (nvl(END_DATE,sysdate) >= sysdate OR
                to_char(END_DATE) = to_char(FND_API.G_MISS_DATE));

enrollAppRegRow enrollmentApprovalCursor%ROWTYPE;
enrollNoAppRegRow enrollmentNoApprovalCursor%ROWTYPE;



begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering Do_Approve_Req (' ||
        itemtype || ',' || itemkey || ') API');


  if itemtype is null then
    raise_application_error (-20000, 'itemtype is null while calling JTF_UM_WF_APPROVAL.Do_Approve_Req.');
  end if;

  if itemkey is null then
    raise_application_error (-20000, 'itemkey is null while calling JTF_UM_WF_APPROVAL.Do_Approve_Req.');
  end if;

  requesterUserID := wf_engine.GetItemAttrNumber (
    itemtype => itemtype,
    itemkey  => itemkey,
    aname    => 'REQUESTER_USER_ID');

  requestType := wf_engine.GetItemAttrText (
    itemtype => itemtype,
    itemkey  => itemkey,
    aname    => 'REQUEST_TYPE');

  requestID := wf_engine.GetItemAttrNumber (
    itemtype => itemtype,
    itemkey  => itemkey,
    aname    => 'REQUEST_ID');

  approverComment := wf_engine.GetItemAttrText (
    itemtype => itemtype,
    itemkey  => itemkey,
    aname    => 'APPROVER_COMMENT');


	  -- Get the username from userID
  requesterUsername := getRequesterUsername ( requesterUserID );

  if (requestType = 'USERTYPE') then
-- bug 7675285  Set the profile ICX_LANG and ICX_TERRITORY profiles for the user id being approved to match the entries
-- for the ad hoc user role

      select language, territory into langProfileValue, terrProfileValue
      from wf_roles
      where name = '__JTA_UM' ||itemkey;

      -- Set the language and territory profile values for the pending user
      profileSave := FND_PROFILE.SAVE('ICX_LANGUAGE', langProfileValue, 'USER',  requesterUserID);
      profileSave := FND_PROFILE.SAVE('ICX_TERRITORY', terrProfileValue, 'USER', requesterUserID);

-- end bug 7675285

	 -- Call AssignUTCredential ()
    JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_USERTYPE_CREDENTIALS (
      X_USER_NAME   => requesterUsername,
      X_USER_ID     => requesterUserID,
      X_USERTYPE_ID => requestID);


    -- Save the approver comment to LAST_APPROVER_COMMENT in
    -- the JTF_UM_USERTYPE_REG table.
    update JTF_UM_USERTYPE_REG
    set    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_DATE = sysdate,
           LAST_APPROVER_COMMENT = approverComment
    where  USERTYPE_REG_ID = itemkey;



    for enrollNoAppRegRow in enrollmentNoApprovalCursor loop
      -- Call AssignEnrollCredential

      JTF_UM_ENROLLMENT_CREDENTIALS.ASSIGN_ENROLLMENT_CREDENTIALS (
        X_USER_NAME       => requesterUsername,
        X_USER_ID         => requesterUserID,
        X_SUBSCRIPTION_ID => enrollNoAppRegRow.SUBSCRIPTION_ID);

    end loop;


    for enrollAppRegRow in enrollmentApprovalCursor loop
      -- Launch workflow created during registration.
	  if Not hasWorkFlowStarted(enrollAppRegRow.WF_ITEM_TYPE,to_char(enrollAppRegRow.SUBSCRIPTION_REG_ID)) then
      wf_engine.StartProcess (itemtype => enrollAppRegRow.WF_ITEM_TYPE,
                              itemkey  => to_char(enrollAppRegRow.SUBSCRIPTION_REG_ID));
	  end if;

    end loop;

  else
    -- requestType is 'ENROLLMENT'

    -- Save the approver comment to LAST_APPROVER_COMMENT in
    -- the JTF_UM_USERTYPE_REG table.
    update JTF_UM_SUBSCRIPTION_REG
    set    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_DATE = sysdate,
           LAST_APPROVER_COMMENT = approverComment
    where  subscription_reg_id = itemkey;

    -- Call Assign Enroll Credential
    JTF_UM_ENROLLMENT_CREDENTIALS.ASSIGN_ENROLLMENT_CREDENTIALS (
       X_USER_NAME => requesterUsername,
       X_USER_ID   => requesterUserID,
       X_SUBSCRIPTION_ID => requestID);

  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Do_Approve_Req API');

end Do_Approve_Req;

--
-- Procedure
--      Approve_Req
--
-- Description -
--   Approve a request
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   resultout
--
procedure Approve_Req (itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) is
--
begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering Approve_Req (' ||
              itemtype || ',' || itemkey || ',' || actid || ',' ||
              funcmode || ') API');

        --
        -- RUN mode - normal process execution
        --
        if (funcmode = 'RUN') then
          Do_Approve_Req (itemtype, itemkey);

        --
        -- CANCEL mode
        --
        elsif (funcmode = 'CANCEL') then
          --
          -- Return process to run
          --
          resultout := 'COMPLETE:';

        --
        -- TIMEOUT mode
        --
        elsif (funcmode = 'TIMEOUT') then
                resultout := 'COMPLETE:';
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Approve_Req API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'Approve_Req', itemtype, itemkey, to_char(actid), funcmode);
                raise;
end Approve_Req;

--
-- Procedure
--      Reject_Req
--
-- Description -
--   Reject a request
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
                      resultout out NOCOPY varchar2) is
--
requestType       varchar2 (10);
requesterUserID   number;
approverComment   varchar2 (4000);

l_parameter_list wf_parameter_list_t :=
wf_parameter_list_t();

l_app_id number;
l_usertype_reg_id number;
l_usertype_key varchar2(30);
requesterUsername varchar2 (100);

userStartDate date;
userEndDate date;
-- adding for Bug 4320347
l_customer_id FND_USER.CUSTOMER_ID%TYPE;
l_person_party_id FND_USER.PERSON_PARTY_ID%TYPE;
-- end of changes for 4320347
--
cursor enrollmentsCursor is
        select  WF_ITEM_TYPE, SUBSCRIPTION_REG_ID
        from    JTF_UM_SUBSCRIPTION_REG
        where   USER_ID = requesterUserID
        and     EFFECTIVE_START_DATE <= sysdate
        and     nvl (EFFECTIVE_END_DATE, sysdate + 1) > sysdate
        and     STATUS_CODE = 'PENDING';


-- cursor for populating event parameters in case of user type rejection
cursor getRejectEventData is
   Select ut.APPLICATION_ID,ut.USERTYPE_KEY,reg.USERTYPE_REG_ID
   From JTF_UM_USERTYPES_B ut , JTF_UM_USERTYPE_REG reg
   where  ut.USERTYPE_ID=reg.USERTYPE_ID and reg.USERTYPE_REG_ID=to_number(itemkey);
  -- and reg.EFFECTIVE_START_DATE <= sysdate
  -- and reg.EFFECTIVE_END_DATE= sysdate;



--
begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering Reject_Req (' ||
              itemtype || ',' || itemkey || ',' || actid || ',' ||
              funcmode || ') API');

        --
        -- RUN mode - normal process execution
        --
        if (funcmode = 'RUN') then
          requestType := wf_engine.GetItemAttrText (
                             itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'REQUEST_TYPE');

          requesterUserID := wf_engine.GetItemAttrNumber (
                             itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'REQUESTER_USER_ID');

          approverComment := wf_engine.GetItemAttrText (
                              itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'APPROVER_COMMENT');

          if (requestType = 'USERTYPE') then

            -- Revoke pending resp.
            JTF_UM_USERTYPE_CREDENTIALS.REVOKE_RESPONSIBILITY (
               X_USER_ID            => requesterUserID,
               X_RESPONSIBILITY_KEY => 'JTF_PENDING_APPROVAL',
               X_APPLICATION_ID     => 690);

            -- End date and rejected Usertype Reg
            update      JTF_UM_USERTYPE_REG
            set         STATUS_CODE = 'REJECTED',
                        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                        LAST_UPDATE_DATE = sysdate,
                        LAST_APPROVER_COMMENT = approverComment,
                        EFFECTIVE_END_DATE = sysdate
            where       USERTYPE_REG_ID = itemkey;

            for enrollRegRow in enrollmentsCursor
              loop
                -- Abort all Workflow Enrollment
                --if (enrollRegRow.WF_ITEM_TYPE is not null) then
                --  wf_engine.AbortProcess (itemtype => enrollRegRow.WF_ITEM_TYPE,
                --                          itemkey  => enrollRegRow.SUBSCRIPTION_REG_ID);
                --end if;

                -- Set STATUS_CODE in JTF_UM_SUBSCRIPTION_REG to 'USER_REJECTED'
                update  JTF_UM_SUBSCRIPTION_REG
                set     STATUS_CODE = 'USER_REJECTED',
                        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                        LAST_UPDATE_DATE = sysdate,
                        EFFECTIVE_END_DATE = sysdate
                where   SUBSCRIPTION_REG_ID = enrollRegRow.SUBSCRIPTION_REG_ID;
              end loop;

			-- release the user name
 			-- check if user is a pending user
			Select start_date,end_date,USER_NAME,customer_id,person_party_id
			Into userStartDate,userEndDate,requesterUsername,l_customer_id,l_person_party_id
			From FND_USER
            Where user_id = requesterUserID;

			If  to_char(userStartDate) = to_char(FND_API.G_MISS_DATE)
            And to_char(userEndDate) = to_char(FND_API.G_MISS_DATE) then
				-- release user
				FND_USER_PKG.RemovePendingUser(requesterUsername);
			End If;

		-- Event handling
		-- Get the values for creation of parameters for the event

		JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Start Raising Event');

		open getRejectEventData;

		fetch getRejectEventData into l_app_id,l_usertype_key,l_usertype_reg_id;

		close getRejectEventData;
		JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Parameters '|| l_app_id ||' '||l_usertype_key|| ' '||l_usertype_reg_id   );

		-- create the parameter list
		       wf_event.AddParameterToList(
					p_name => 'USERTYPEREG_ID',
				      p_value=>to_char(l_usertype_reg_id),
				      p_parameterlist=>l_parameter_list
				      );
		       wf_event.AddParameterToList(
					p_name => 'APPID',
				      p_value=>to_char(l_app_id),
				      p_parameterlist=>l_parameter_list
				      );
		       wf_event.AddParameterToList(
					p_name => 'USER_TYPE_KEY',
				      p_value=>l_usertype_key,
				      p_parameterlist=>l_parameter_list
				      );
			--changes for 4320347
				wf_event.AddParameterToList(
					p_name => 'CUSTOMER_ID',
				      p_value=>to_char(nvl(l_customer_id,-1)) ,
				      p_parameterlist=>l_parameter_list
				      );
				wf_event.AddParameterToList(
					p_name => 'PERSON_PARTY_ID',
				      p_value=>to_char(nvl(l_person_party_id,-1)),
				      p_parameterlist=>l_parameter_list
				      );
				--end of changes for 4320347


		   -- raise the event
		       wf_event.raise(
						      p_event_name =>'oracle.apps.jtf.um.rejectUTEvent',
						     p_event_key =>requesterUserID ,
						     p_parameters => l_parameter_list
						    );

			   --  delete parameter list as it is no longer required
		     		l_parameter_list.DELETE;

			-- end of event handling



          else
            -- Set STATUS_CODE in JTF_UM_SUBSCRIPTION_REG to 'REJECTED'
            update  JTF_UM_SUBSCRIPTION_REG
            set     STATUS_CODE = 'REJECTED',
                    LAST_APPROVER_COMMENT = approverComment,
                    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                    LAST_UPDATE_DATE = sysdate,
                    EFFECTIVE_END_DATE = sysdate
            where   SUBSCRIPTION_REG_ID = itemkey;
          end if;
          resultout := 'COMPLETE:';

        --
        -- CANCEL mode
        --
        elsif (funcmode = 'CANCEL') then
                --
                -- Return process to run
                --
                resultout := 'COMPLETE:';

        --
        -- TIMEOUT mode
        --
        elsif (funcmode = 'TIMEOUT') then
                resultout := 'COMPLETE:';
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Reject_Req API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'Reject_Req', itemtype, itemkey, to_char(actid), funcmode);
                raise;
end Reject_Req;

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
                        resultout out NOCOPY varchar2) is
--
l_approver_userID   number;
l_approver_username varchar (100);
l_result            varchar (10);

cursor getFNDUserID is
  select user_id
  from fnd_user
  where (nvl (end_date, sysdate + 1) > sysdate
  OR to_char(END_DATE) = to_char(FND_API.G_MISS_DATE))

  and user_name = l_approver_username;
--
begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering Can_Delegate (' ||
        itemtype || ',' || itemkey || ',' || actid || ',' ||
        funcmode || ') API');

  --
  -- RUN mode - normal process execution
  --

  -- Default is No delegation
  resultout := 'COMPLETE:N';

  if (funcmode = 'RUN') then
    -- Get the Approver User ID
    l_approver_username := wf_engine.GetItemAttrText (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'APPROVER_USERNAME');

    open getFNDUserID;
    fetch getFNDUserID into l_approver_userID;
    if (getFNDUserID%notfound) then
      close getFNDUserID;
      raise_application_error (-20000, 'userid not found('||l_approver_username||')');
    end if;
    close getFNDUserID;

    -- Check if this enrollment has delegation
    JTF_UM_WF_DELEGATION_PVT.GET_CHECKBOX_STATUS (
      P_REG_ID   => to_number (itemkey),
      P_USER_ID  => l_approver_userID,
      X_RESULT   => l_result);

    if (l_result = JTF_UM_WF_DELEGATION_PVT.CHECKED_UPDATE) then
      -- Grant Delegation Flag is set to Yes.
      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DELEGATION_FLAG',
                                 avalue   => 'Y');
      resultout := 'COMPLETE:Y';

    elsif (l_result = JTF_UM_WF_DELEGATION_PVT.NOT_CHECKED_UPDATE) then
      -- Grant Delegation Flag is set to No.
      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DELEGATION_FLAG',
                                 avalue   => 'N');
      resultout := 'COMPLETE:Y';

    end if;
  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Can_Delegate API');

exception
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'Can_Delegate', itemtype, itemkey, to_char (actid), funcmode, 'l_approver_userID='||to_char (l_approver_userID));
                raise;
end Can_Delegate;

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
                                   resultout out NOCOPY varchar2) is

l_procedure_name CONSTANT varchar2(23) := 'can_enrollment_delegate';
l_request_id number;
l_requester_usertype_id number;
l_result boolean;

begin

  JTF_DEBUG_PUB.LOG_ENTERING_METHOD (p_module  => G_MODULE,
                                     p_message => l_procedure_name);

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS (p_module  => G_MODULE,
                                p_message =>  itemtype || ',' || itemkey ||
                                ',' || actid || ',' || funcmode || ') ');
      end if;

  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then
    -- Get the Requester Usertype ID
    l_requester_usertype_id := wf_engine.GetItemAttrNumber (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'REQUESTER_USERTYPE_ID');

    -- Get the Request ID
    l_request_id := wf_engine.GetItemAttrNumber(
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'REQUEST_ID');

    JTF_UM_WF_DELEGATION_PVT.CAN_ENROLLMENT_DELEGATE (
        p_subscription_id => l_request_id,
        p_usertype_id     => l_requester_usertype_id,
        x_result          => l_result);

    if (l_result) then
      resultout := 'COMPLETE:Y';
    else
      resultout := 'COMPLETE:N';
    end if;

  end if;

  JTF_DEBUG_PUB.LOG_EXITING_METHOD (p_module  => G_MODULE,
                                    p_message => l_procedure_name);

exception
  when others then
    wf_core.context ('JTF_UM_WF_APPROVAL', 'CAN_ENROLLMENT_DELEGATE', itemtype, itemkey, to_char (actid), funcmode);
    raise;
end can_enrollment_delegate;

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
                                      resultout out NOCOPY varchar2) is

l_appl_id             JTF_UM_USERTYPES_B.APPLICATION_ID%TYPE;
l_approver_username   fnd_user.user_name%type;
l_org_name            hz_parties.party_name%type;
l_org_number          hz_parties.party_number%type;
l_primary_user_role   fnd_profile_option_values.profile_option_value%type;
l_procedure_name      CONSTANT varchar2(26) := 'universal_approvers_exists';
l_request_id          number;
l_request_type        varchar2 (10);
l_requester_user_id   fnd_user.user_id%type;
l_universal_approvers fnd_profile_option_values.profile_option_value%type;

begin

  JTF_DEBUG_PUB.LOG_ENTERING_METHOD (p_module  => G_MODULE,
                                     p_message => l_procedure_name);

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS (p_module  => G_MODULE,
                                p_message => itemtype || ',' || itemkey ||
                                ',' || actid || ',' || funcmode || ') ');
                                end if;

  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then
    -- Get the Current Approver Username
    l_approver_username := wf_engine.GetItemAttrText (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'APPROVER_USERNAME');

    -- Get the profile option of Universal Approvers
    l_request_type := wf_engine.GetItemAttrText (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'REQUEST_TYPE');

    l_request_id := wf_engine.GetItemAttrNumber (
                   itemtype => itemtype,
                   itemkey  => itemkey,
                   aname    => 'REQUEST_ID');

    l_requester_user_id := wf_engine.GetItemAttrNumber (
    itemtype => itemtype,
    itemkey  => itemkey,
    aname    => 'REQUESTER_USER_ID');

    -- get the organization number
    get_org_info (p_user_id    => l_requester_user_id,
                  x_org_name   => l_org_name,
                  x_org_number => l_org_number);

    -- the name of the role
    l_primary_user_role := g_adhoc_role_name_prefix || l_org_number;

    if (l_approver_username = l_primary_user_role) then
      -- the current approver is a Universal Approver
      resultout := 'COMPLETE:Y';
    else
      resultout := 'COMPLETE:N';
    end if;

  end if;

  JTF_DEBUG_PUB.LOG_EXITING_METHOD (p_module  => G_MODULE,
                                    p_message => l_procedure_name);

exception
  when others then
    wf_core.context ('JTF_UM_WF_APPROVAL', l_procedure_name, itemtype, itemkey, to_char (actid), funcmode);
    raise;
end universal_approvers_exists;

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
procedure CHECK_EMAIL_NOTIFI_TYPE (itemtype  in varchar2,
                                   itemkey   in varchar2,
                                   actid     in number,
                                   funcmode  in varchar2,
                                   resultout out NOCOPY varchar2) is
--
requestType     varchar2 (10);
requestName     varchar2 (1000);
usertypeKey     varchar2 (30);
emailFlag       varchar2 (1);
usertypeID      number;
MISSING_USERTYPE_INFO exception;
--
cursor getUsertypeInfo is
        select  USERTYPE_KEY, EMAIL_NOTIFICATION_FLAG
        from    JTF_UM_USERTYPES_B
        where   USERTYPE_ID = usertypeID;

begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering CHECK_EMAIL_NOTIFI_TYPE (' ||
              itemtype || ',' || itemkey || ',' || actid || ',' ||
              funcmode || ') API');

        --
        -- RUN mode - normal process execution
        --

        if (funcmode = 'RUN') then
                usertypeID := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'REQUESTER_USERTYPE_ID');

                open getUsertypeInfo;
                fetch getUsertypeInfo into usertypeKey, emailFlag;
                if (getUsertypeInfo%notfound) then
                  close getUsertypeInfo;
                  raise MISSING_USERTYPE_INFO;
                end if;
                close getUsertypeInfo;

                if (emailFlag = 'N') then
                  resultout := 'COMPLETE:NO_NOTIFICATION';

                else
                  -- We will send email out.

                  requestType := wf_engine.GetItemAttrText (
                      itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'REQUEST_TYPE');

                  if (requestType = 'ENROLLMENT') then
                    -- Send enrollment email
                    resultout := 'COMPLETE:ENROLLMENT';
                  else
                    -- Send usertype email, but we need to know what kind
                    -- of usertype email are we sending.

                    if (usertypeKey = 'PRIMARYUSER') or (usertypeKey = 'PRIMARYUSERNEW') then
                      resultout := 'COMPLETE:PRIMARY_USER';
                    elsif (usertypeKey = 'BUSINESSUSER') then
                      resultout := 'COMPLETE:BUSINESS_USER';
                    elsif (usertypeKey = 'INDIVIDUALUSER') then
                      resultout := 'COMPLETE:INDIVIDUAL_USER';
                    else
                      resultout := 'COMPLETE:OTHER_USER';
                    end if;
                  end if;
                end if;

        --
        -- CANCEL mode
        --
        elsif (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                --

        --
        -- TIMEOUT mode
        --
        elsif (funcmode = 'TIMEOUT') then
                resultout := 'COMPLETE:';
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting CHECK_EMAIL_NOTIFI_TYPE API');

exception
        when MISSING_USERTYPE_INFO then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'CHECK_EMAIL_NOTIFI_TYPE', itemtype, itemkey, to_char (actid), funcmode, 'Usertype info is missing');
                raise;
        when others then
                wf_core.context ('JTF_UM_WF_APPROVAL', 'CHECK_EMAIL_NOTIFI_TYPE', itemtype, itemkey, to_char (actid), funcmode);
                raise;
end CHECK_EMAIL_NOTIFI_TYPE;

--
-- CompleteApprovalActivity
-- DESCRIPTION
--   Complete the blocking activity
--   This procedure will determine which request type this approval is for
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
                                    lastUpdateDate  in varchar2 := null) is

l_last_update_date   varchar2 (14);
request_type         varchar2 (10);
org_status varchar2(1);



UNKNOWN_REQUEST_TYPE exception;

cursor getLUDFromUserReg is
  select to_char (last_update_date, 'mmddyyyyhh24miss')
  from jtf_um_usertype_reg
  where usertype_reg_id = to_number (itemkey);

cursor getLUDFromEnrollReg is
  select to_char (last_update_date, 'mmddyyyyhh24miss')
  from jtf_um_subscription_reg
  where subscription_reg_id = to_number (itemkey);

  -- For bug fix 3894853
cursor  getOrgDetail is
 SELECT  party.status FROM HZ_PARTIES PARTY, HZ_RELATIONSHIPS PREL
    WHERE  PARTY.PARTY_ID = PREL.OBJECT_ID
    AND    PREL.PARTY_ID = (select fnd.customer_id
  from jtf_um_usertype_reg reg , fnd_user fnd
  where usertype_reg_id = to_number(itemkey)
  and reg.user_id=fnd.USER_ID
  )
    AND    PREL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND    PREL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND    PREL.START_DATE < SYSDATE
    AND    NVL(PREL.END_DATE, SYSDATE+1) > SYSDATE
    AND    PREL.RELATIONSHIP_CODE in ('EMPLOYEE_OF', 'CONTACT_OF');


  -- end Bug fix 3894853


begin

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering CompleteApprovalActivity (' ||
              itemtype || ',' || itemkey || ',' || resultCode || ',' ||
              approverComment || ') API');

        -- check on the input
        if itemtype is null then
          raise_application_error (-20000, 'itemtype is null while calling JTF_UM_WF_APPROVAL.CompleteApprovalActivity.');
        end if;

        if itemkey is null then
          raise_application_error (-20000, 'itemkey is null while calling JTF_UM_WF_APPROVAL.CompleteApprovalActivity.');
        end if;

        if resultCode is null then
          raise_application_error (-20000, 'resultCode is null while calling JTF_UM_WF_APPROVAL.CompleteApprovalActivity.');
        end if;

        -- Check Request type
        request_type := wf_engine.GetItemAttrText (
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'REQUEST_TYPE');

        if (request_type = 'USERTYPE') then

	-- bug fix 3894853
	-- check if there is an Organization associated with this usertype we are trying to approve
	-- also if that Organization Status is INACTIVE then raise an error

	open getOrgDetail;
	fetch getOrgDetail into org_status;
	close getOrgDetail;

	if org_status is not null and org_status <> 'A'  then
			raise_application_error (-20001, ' ORG_INACTIVE ' );
	end if;


	-- end of bug fix 3894853

          if lastUpdateDate is not null then

            open getLUDFromUserReg;
            fetch getLUDFromUserReg into l_last_update_date;
            close getLUDFromUserReg;

            if (lastUpdateDate <> l_last_update_date) then
              -- not the same request
              raise_application_error (-20001, 'The last update date from the input parameter and the last update date stored in the database is different.');
            end if;
          end if;

          Do_Complete_Approval_Activity (p_itemtype        => itemtype,
                                         p_itemkey         => itemkey,
                                         p_resultCode      => resultCode,
                                         p_approverComment => approverComment,
                                         p_act1            => 'NTF_BLOCK',
                                         p_act2            => 'REMINDER_NTF_BLOCK',
                                         p_act3            => 'FAIL_ESCLATE_NTF_BLOC');

        elsif (request_type = 'ENROLLMENT') then

          if lastUpdateDate is not null then

            open getLUDFromEnrollReg;
            fetch getLUDFromEnrollReg into l_last_update_date;
            close getLUDFromEnrollReg;

            if (lastUpdateDate <> l_last_update_date) then
              -- not the same request
              raise_application_error (-20001, 'The last update date from the input parameter and the last update date stored in the database is different.');
            end if;
          end if;

          -- Set the delegation flag
          if (delegationFlag is not null) then
            wf_engine.SetItemAttrText (itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'DELEGATION_FLAG',
                                       avalue   => delegationFlag);
          end if;

          Do_Complete_Approval_Activity (p_itemtype        => itemtype,
                                         p_itemkey         => itemkey,
                                         p_resultCode      => resultCode,
                                         p_approverComment => approverComment,
                                         p_act1            => 'NTF_APPROVAL_ENROLL_REQUIRED',
                                         p_act2            => 'NTF_REMIND_ENROLL_REQUIRED',
                                         p_act3            => 'NTF_FAIL_ESCALATE_ENROLL_REQ',
                                         p_act4            => 'NTF_APPROVAL_ENROLL_DELE_REQ',
                                         p_act5            => 'NTF_REMIND_ENROLL_DELE_REQ',
                                         p_act6            => 'NTF_FAIL_ESCA_ENROLL_DELE_REQ',
                                         p_act7            => 'NTF_APPROV_ENROL_DELE_DISP_REQ',
                                         p_act8            => 'NTF_REMIND_ENROL_DELE_DISP_REQ');



        else
          raise UNKNOWN_REQUEST_TYPE;
        end if;

        JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting CompleteApprovalActivity API');

exception
        when UNKNOWN_REQUEST_TYPE then
          wf_core.context ('JTF_UM_WF_APPROVAL', 'CompleteApprovalActivity',
          itemtype, itemkey, resultCode, approverComment);
          raise;
        when others then
          wf_core.context ('JTF_UM_WF_APPROVAL', 'CompleteApprovalActivity', itemtype, itemkey, resultCode, approverComment);
          raise;

end CompleteApprovalActivity;

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
                                         p_act6            in varchar2 := null)

is

begin

  Do_Complete_Approval_Activity (p_itemtype        => p_itemtype,
                                 p_itemkey         => p_itemkey,
                                 p_resultCode      => p_resultCode,
                                 p_approverComment => p_approverComment,
                                 p_act1            => p_act1,
                                 p_act2            => p_act2,
                                 p_act3            => p_act3,
                                 p_act4            => p_act4,
                                 p_act5            => p_act5,
                                 p_act6            => p_act6);

end Do_Complete_Approval_Activity;

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
                                         p_act7            in varchar2 := null,
                                         p_act8            in varchar2 := null)

IS

OK  boolean := FALSE;
act varchar2 (30);
requestType varchar2 (10);
wf_resultCode varchar2 (8) := p_resultCode;

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE,
      'Entering Do_Complete_Approval_Activity (' || p_itemtype ||
      ',' || p_itemkey || ',' || p_resultCode || ',' || p_approverComment ||
      ',' || p_act1 || ',' || p_act2 || ',' || p_act3 || ',' || p_act4 ||
      ',' || p_act5 || ',' || p_act6 || ',' || p_act7 || ',' || p_act8 || ') API');

  wf_engine.SetItemAttrText (itemtype => p_itemtype,
      itemkey  => p_itemkey,
      aname    => 'APPROVER_COMMENT',
      avalue   => p_approverComment);

  wf_engine.SetItemAttrText (itemtype => p_itemtype,
      itemkey  => p_itemkey,
      aname    => 'REQUEST_RESULT',
      avalue   => p_resultCode);

  -- Find out what kind of request type is it
  requestType := wf_engine.GetItemAttrText (itemtype => p_itemtype,
      itemkey  => p_itemkey,
      aname    => 'REQUEST_TYPE');

  if (p_act1 is not null) then
    begin
      act := p_act1;
      wf_engine.BeginActivity (itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               activity => act);
      OK := TRUE;
    exception
      when others then
        wf_core.clear;
    end;
  end if;

  if (not OK) and (p_act2 is not null) then
    begin
      act := p_act2;
      wf_engine.BeginActivity (itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               activity => act);
      OK := TRUE;
    exception
      when others then
        wf_core.clear;
    end;
  end if;

  if (not OK) and (p_act3 is not null) then
    begin
      act := p_act3;
      wf_engine.BeginActivity (itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               activity => act);
      OK := TRUE;
    exception
      when others then
        wf_core.clear;
    end;
  end if;

  if (not OK) and (p_act4 is not null) then
    begin
      act := p_act4;
      wf_engine.BeginActivity (itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               activity => act);
      OK := TRUE;
    exception
      when others then
        wf_core.clear;
    end;
  end if;

  if (not OK) and (p_act5 is not null) then
    begin
      act := p_act5;
      wf_engine.BeginActivity (itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               activity => act);
      OK := TRUE;
    exception
      when others then
        wf_core.clear;
    end;
  end if;

  if (not OK) and (p_act6 is not null) then
    begin
      act := p_act6;
      wf_engine.BeginActivity (itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               activity => act);
      OK := TRUE;
    exception
      when others then
        wf_core.clear;
    end;
  end if;

  if (not OK) and (p_act7 is not null) then
    begin
      act := p_act7;
      wf_engine.BeginActivity (itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               activity => act);
      OK := TRUE;
    exception
      when others then
        wf_core.clear;
    end;
  end if;


if (not OK) and (p_act8 is not null) then
    begin
      act := p_act8;
      wf_engine.BeginActivity (itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               activity => act);
      OK := TRUE;
    exception
      when others then
        wf_core.clear;
    end;
  end if;


  if OK then

    wf_engine.CompleteActivity (p_itemtype, p_itemkey, act, wf_resultCode);

  else

    raise_application_error (-20000, 'No Activity Found Failed at JTF_UM_WF_APPROVAL.Do_Complete_Approval_Activity ('
    ||p_itemtype||','||p_itemkey||','||p_resultCode||','||p_approverComment
    ||','||p_act1||','||p_act2||','||p_act3||','||p_act4||','||p_act5||','||
    p_act6||','||p_act7||','||p_act8||')');

  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Do_Complete_Approval_Activity API');

end Do_Complete_Approval_Activity;

--
-- abort_process
-- DESCRIPTION
--   Abort the Workflow Process with status is ACTIVE, ERROR, or SUSPENDED
-- IN
--   p_itemtype        - A valid item type from (WF_ITEM_TYPES table).
--   p_itemkey         - A string generated from the application object's
--                       primary key.
--
procedure abort_process (p_itemtype in varchar2,
                         p_itemkey  in varchar2)

IS

result varchar2 (10);
status varchar2 (10);
begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Entering abort_process (' ||
        p_itemtype || ',' || p_itemkey || ') API');

  if p_itemtype is null then
    raise_application_error (-20000, 'itemtype is null while calling JTF_UM_WF_APPROVAL.abort_process.');
  end if;

  if p_itemtype is null then
    raise_application_error (-20000, 'itemkey is null while calling JTF_UM_WF_APPROVAL.abort_process.');
  end if;

  wf_engine.ItemStatus (p_itemtype, p_itemkey, status, result);
  if (status <> 'COMPLETE') then
    -- need to cancel any open notification
    cancel_notification (p_itemtype, p_itemkey);
    -- now call the workflow abort process
    wf_engine.abortprocess (itemtype => p_itemtype,
                            itemkey  => p_itemkey);
  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting abort_process API');

end abort_process;

procedure usertype_approval_changed (p_usertype_id in number,
                                     p_new_approval_id in number,
                                     p_old_approval_id in number) is

cursor usertype_reg is
  select usertype_reg_id,user_id
  from jtf_um_usertype_reg
  where usertype_id = p_usertype_id
  and status_code = 'PENDING'
  and nvl (effective_end_date, sysdate + 1) > sysdate;

 p_usertype_reg_id number;
p_user_id number;

cursor find_old_item_type is
  select utreg.wf_item_type
  from jtf_um_usertype_reg utreg, jtf_um_usertypes_b ut
  where utreg.usertype_id = p_usertype_id
  and   utreg.usertype_id = ut.usertype_id
  and   utreg.status_code = 'PENDING'
  and   nvl (utreg.effective_end_date, sysdate + 1) > sysdate;

p_wf_old_item_type varchar2(8);

cursor find_new_item_type is
  select wf_item_type
  from jtf_um_approvals_b
  where approval_id = p_new_approval_id;

p_wf_new_item_type varchar2(8);
p_new_item_key number;

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE,
      'Entering usertype_approval_changed (' || p_usertype_id || ',' ||
      p_new_approval_id || ',' || p_old_approval_id || ') API');


  -- Find out the old item_type to abort Workflow process
  open find_old_item_type;
  fetch find_old_item_type into p_wf_old_item_type;
  close find_old_item_type;


  -- Find out the new item_type to create Workflow process
  open find_new_item_type;
  fetch find_new_item_type into p_wf_new_item_type;
  close find_new_item_type;




  open usertype_reg;
    loop
      fetch usertype_reg into p_usertype_reg_id,p_user_id;
      exit when usertype_reg%NOTFOUND;


      -- abort WF Process first
      abort_process (p_wf_old_item_type, p_usertype_reg_id);


      if p_wf_new_item_type is null then


        -- approve the approval request
        do_approve_req(itemtype => p_wf_old_item_type,
                       itemkey  => p_usertype_reg_id);

      else


        -- end date the old record in JTF_UM_USERTYPE_REG table
        update JTF_UM_USERTYPE_REG set effective_end_date = sysdate,
        last_update_date = sysdate, last_updated_by = FND_GLOBAL.USER_ID
        where usertype_reg_id = p_usertype_reg_id;


        -- create record in JTF_UM_USERTYPE_REG table
        JTF_UM_USERTYPES_PKG.INSERT_UMREG_ROW (
            X_USERTYPE_ID => p_usertype_id,
            X_LAST_APPROVER_COMMENT => null,
            X_APPROVER_USER_ID => null,
            X_EFFECTIVE_END_DATE => null,
            X_WF_ITEM_TYPE => p_wf_new_item_type,
            X_EFFECTIVE_START_DATE => sysdate,
            X_USERTYPE_REG_ID => p_new_item_key,
            X_USER_ID => p_user_id,
            X_STATUS_CODE => 'PENDING',
            X_CREATION_DATE => sysdate,
            X_CREATED_BY => FND_GLOBAL.USER_ID,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
            X_LAST_UPDATE_LOGIN => null);

        -- Create WF process
        CreateProcess (ownerUserId     => FND_GLOBAL.USER_ID,
                       requestType     => 'USERTYPE',
                       requestID       => p_usertype_id,
                       requesterUserID => p_user_id,
                       requestRegID    => p_new_item_key);

        -- Launch WF process
        LaunchProcess (requestType  => 'USERTYPE',
                       requestRegID => p_new_item_key);

      end if;

    end loop;
  close usertype_reg;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting usertype_approval_changed API');

end usertype_approval_changed;

procedure usertype_approval_changed (p_usertype_id     in number,
                                     p_new_approval_id in number,
                                     p_old_approval_id in number,
                                     p_org_party_id    in number) is

cursor usertype_reg is
  select utreg.usertype_reg_id, utreg.user_id
  from   jtf_um_usertype_reg utreg, fnd_user fu, hz_relationships hzr
  where  utreg.usertype_id = p_usertype_id
  and    utreg.status_code = 'PENDING'
  and    nvl (utreg.effective_end_date, sysdate + 1) > sysdate
  and    utreg.user_id = fu.user_id
  and    fu.customer_id = hzr.party_id
  and    hzr.start_date <= sysdate
  and    nvl (hzr.end_date, sysdate + 1) > sysdate
  and    hzr.relationship_code in ('EMPLOYEE_OF', 'CONTACT_OF')
  and    hzr.object_table_name = 'HZ_PARTIES'
  and    hzr.subject_table_name = 'HZ_PARTIES'
  and    hzr.object_id = p_org_party_id;

p_usertype_reg_id number;
p_user_id number;

cursor find_old_item_type is
  select utreg.wf_item_type
  from   jtf_um_usertype_reg utreg, jtf_um_usertypes_b ut
  where  utreg.usertype_id = p_usertype_id
  and    utreg.usertype_id = ut.usertype_id
  and    utreg.status_code = 'PENDING'
  and   nvl (utreg.effective_end_date, sysdate + 1) > sysdate;

p_wf_old_item_type varchar2(8);

cursor find_new_item_type is
  select wf_item_type
  from jtf_um_approvals_b
  where approval_id = p_new_approval_id;

p_wf_new_item_type varchar2(8);
p_new_item_key number;

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE,
      'Entering usertype_approval_changed (' || p_usertype_id || ',' ||
      p_new_approval_id || ',' || p_old_approval_id || ',' ||
      p_org_party_id || ') API');

  -- Find out the old item_type to abort Workflow process
  open find_old_item_type;
  fetch find_old_item_type into p_wf_old_item_type;
  close find_old_item_type;

  -- Find out the new item_type to create Workflow process
  open find_new_item_type;
  fetch find_new_item_type into p_wf_new_item_type;
  close find_new_item_type;

  open usertype_reg;
    loop
      fetch usertype_reg into p_usertype_reg_id,p_user_id;
      exit when usertype_reg%NOTFOUND;

      -- abort WF Process first
      abort_process (p_wf_old_item_type, p_usertype_reg_id);

      if p_wf_new_item_type is null then

        do_approve_req(itemtype => p_wf_old_item_type,
                       itemkey  => p_usertype_reg_id);
      else

        -- end date the old record in JTF_UM_USERTYPE_REG table
        update JTF_UM_USERTYPE_REG set effective_end_date = sysdate,
        last_update_date = sysdate, last_updated_by = FND_GLOBAL.USER_ID
        where usertype_reg_id = p_usertype_reg_id
        and   user_id = p_user_id and status_code='PENDING';

        -- create record in JTF_UM_USERTYPE_REG table
        JTF_UM_USERTYPES_PKG.INSERT_UMREG_ROW (
            X_USERTYPE_ID => p_usertype_id,
            X_LAST_APPROVER_COMMENT => null,
            X_APPROVER_USER_ID => null,
            X_EFFECTIVE_END_DATE => null,
            X_WF_ITEM_TYPE => p_wf_new_item_type,
            X_EFFECTIVE_START_DATE => sysdate,
            X_USERTYPE_REG_ID => p_new_item_key,
            X_USER_ID => p_user_id,
            X_STATUS_CODE => 'PENDING',
            X_CREATION_DATE => sysdate,
            X_CREATED_BY => FND_GLOBAL.USER_ID,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
            X_LAST_UPDATE_LOGIN => null);

        -- Create WF process
        CreateProcess (ownerUserId     => FND_GLOBAL.USER_ID,
                       requestType     => 'USERTYPE',
                       requestID       => p_usertype_id,
                       requesterUserID => p_user_id,
                       requestRegID    => p_new_item_key);

        -- Launch WF process
        LaunchProcess (requestType  => 'USERTYPE',
                       requestRegID => p_new_item_key);

      end if;
    end loop;
  close usertype_reg;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting usertype_approval_changed API');

end usertype_approval_changed;

procedure enrollment_approval_changed (p_subscription_id in number,
                                       p_new_approval_id in number,
                                       p_old_approval_id in number,
                                       p_org_party_id    in number default null) is

p_user_id             number;
p_subscription_reg_id number;
p_new_item_key        number;
p_usertype_status     varchar2(30);
p_wf_new_item_type    varchar2(8);
p_wf_old_item_type    varchar2(8);

cursor subscription_reg is
select subscription_reg_id, user_id, wf_item_type
from   jtf_um_subscription_reg
where  subscription_id = p_subscription_id
and    status_code = 'PENDING'
and    (effective_end_date is null
or      effective_end_date > sysdate);

cursor subscription_reg_w_org is
select subreg.subscription_reg_id, fu.user_id, subreg.wf_item_type
from   jtf_um_subscription_reg subreg, fnd_user fu, hz_relationships hzr
where  subreg.subscription_id = p_subscription_id
and    subreg.status_code = 'PENDING'
and    nvl (subreg.effective_end_date, sysdate + 1) > sysdate
and    subreg.user_id = fu.user_id
and    fu.customer_id = hzr.party_id
and    hzr.start_date <= sysdate
and    nvl (hzr.end_date, sysdate + 1) > sysdate
and    hzr.relationship_code in ('EMPLOYEE_OF', 'CONTACT_OF')
and    hzr.object_table_name = 'HZ_PARTIES'
and    hzr.subject_table_name = 'HZ_PARTIES'
and    hzr.object_id = p_org_party_id;

cursor find_new_item_type is
select wf_item_type
from   jtf_um_approvals_b
where  approval_id = p_new_approval_id
and    (effective_end_date is null
or      effective_end_date > sysdate);

cursor check_usertype_status is
select status_code
from   jtf_um_usertype_reg
where  user_id = p_user_id
and    (effective_end_date is null
or      effective_end_date > sysdate);

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE,
      'Entering enrollment_approval_changed (' || p_subscription_id || ',' ||
      p_new_approval_id || ',' || p_old_approval_id || ',' ||
      p_org_party_id || ') API');

  -- Find out the new item_type to create Workflow process
  open find_new_item_type;
  fetch find_new_item_type into p_wf_new_item_type;
  close find_new_item_type;

  if (p_org_party_id is null) then
    open subscription_reg;
  else
    open subscription_reg_w_org;
  end if;
    loop
      if (p_org_party_id is null) then
        fetch subscription_reg into p_subscription_reg_id, p_user_id, p_wf_old_item_type;
        exit when subscription_reg%NOTFOUND;
      else
        fetch subscription_reg_w_org into p_subscription_reg_id, p_user_id, p_wf_old_item_type;
        exit when subscription_reg_w_org%NOTFOUND;
      end if;

      -- abort WF Process first
      if (p_wf_old_item_type is not null) then
        abort_process (p_wf_old_item_type, p_subscription_reg_id);
      end if;

      if p_wf_new_item_type is null then
        -- The user selected no workflow
        -- Approve the request if the usertype status is approved.
        -- If status is PENDING, change the workflow in the
        -- JTF_UM_SUBSCRIPTION_REG to null.

        open check_usertype_status;
        fetch check_usertype_status into p_usertype_status;
        if (check_usertype_status%notfound) then
          close check_usertype_status;
          if (p_org_party_id is null) then
            close subscription_reg;
          else
            close subscription_reg_w_org;
          end if;
          -- all Users who are using the UM should be in the
          -- JTF_UM_USERTYPE_REG table.
          raise_application_error (20000, 'User info is missing');
        end if;
        close check_usertype_status;

        -- check if the user status code is pending.
        -- if pending, then we will not approve

        if (p_usertype_status = 'PENDING') or
           (p_usertype_status = 'UPGRADE_PENDING') then
          -- usertype is 'PENDING', end date the last record and add a new
          -- record with null in the workflow itemtype column.
          update JTF_UM_SUBSCRIPTION_REG
          set    EFFECTIVE_END_DATE  = sysdate,
                 LAST_UPDATE_DATE    = sysdate,
                 LAST_UPDATED_BY     = FND_GLOBAL.USER_ID
          where  SUBSCRIPTION_REG_ID = p_subscription_reg_id;

          -- create record in JTF_UM_SUBSCRIPTION_REG table
          JTF_UM_SUBSCRIPTIONS_PKG.INSERT_SUBREG_ROW
                                  (X_SUBSCRIPTION_ID => p_subscription_id,
                                   X_LAST_APPROVER_COMMENT => null,
                                   X_APPROVER_USER_ID => null,
                                   X_EFFECTIVE_END_DATE => null,
                                   X_WF_ITEM_TYPE => null,
                                   X_EFFECTIVE_START_DATE => sysdate,
                                   X_SUBSCRIPTION_REG_ID => p_new_item_key,
                                   X_USER_ID => p_user_id,
                                   X_STATUS_CODE => 'PENDING',
                                   X_CREATION_DATE => sysdate,
                                   X_CREATED_BY => FND_GLOBAL.USER_ID,
                                   X_LAST_UPDATE_DATE => sysdate,
                                   X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
                                   X_LAST_UPDATE_LOGIN => null);
        else
          -- User status is not PENDING
          do_approve_req (itemtype => p_wf_old_item_type,
                          itemkey  => p_subscription_reg_id);
        end if;
      else
        -- p_wf_new_item_type is not null
        -- end date the old record in JTF_UM_SUBSCRIPTION_REG table
        update JTF_UM_SUBSCRIPTION_REG
        set    EFFECTIVE_END_DATE  = sysdate,
               LAST_UPDATE_DATE    = sysdate,
               LAST_UPDATED_BY     = FND_GLOBAL.USER_ID
        where  SUBSCRIPTION_REG_ID = p_subscription_reg_id;

        -- create record in JTF_UM_SUBSCRIPTION_REG table
        JTF_UM_SUBSCRIPTIONS_PKG.INSERT_SUBREG_ROW
                                (X_SUBSCRIPTION_ID => p_subscription_id,
                                 X_LAST_APPROVER_COMMENT => null,
                                 X_APPROVER_USER_ID => null,
                                 X_EFFECTIVE_END_DATE => null,
                                 X_WF_ITEM_TYPE => p_wf_new_item_type,
                                 X_EFFECTIVE_START_DATE => sysdate,
                                 X_SUBSCRIPTION_REG_ID => p_new_item_key,
                                 X_USER_ID => p_user_id,
                                 X_STATUS_CODE => 'PENDING',
                                 X_CREATION_DATE => sysdate,
                                 X_CREATED_BY => FND_GLOBAL.USER_ID,
                                 X_LAST_UPDATE_DATE => sysdate,
                                 X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
                                 X_LAST_UPDATE_LOGIN => null);

        -- Create WF process
        CreateProcess (ownerUserId     => FND_GLOBAL.USER_ID,
                       requestType     => 'ENROLLMENT',
                       requestID       => p_subscription_id,
                       requesterUserID => p_user_id,
                       requestRegID    => p_new_item_key);

        -- Launch WF process if user type approval has gone through
        open check_usertype_status;
        fetch check_usertype_status into p_usertype_status;
        close check_usertype_status;

        if (p_usertype_status = 'APPROVED') then
          wf_engine.startProcess (itemType => p_wf_new_item_type,
                                  itemKey  => p_new_item_key);
        end if;
      end if;
    end loop;
  if (p_org_party_id is null) then
    close subscription_reg;
  else
    close subscription_reg_w_org;
  end if;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting Initialization API');

end enrollment_approval_changed;

procedure enrollment_approval_changed (p_subscription_id in number,
                                       p_new_approval_id in number,
                                       p_old_approval_id in number) is
begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE,
      'Entering enrollment_approval_changed (' || p_subscription_id || ',' ||
      p_new_approval_id || ',' || p_old_approval_id || ') API');

  enrollment_approval_changed (p_subscription_id,
                               p_new_approval_id,
                               p_old_approval_id,
                               null);

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting enrollment_approval_changed API');

end enrollment_approval_changed;

procedure approval_chain_changed(p_approval_id in number,
                                 p_org_party_id in number)
is

cursor usertype_approval is select usertype_id from jtf_um_usertypes_b
where approval_id = p_approval_id
and   nvl (effective_end_date, sysdate + 1) > sysdate;
p_usertype_id number;

cursor subscription_approval is select subscription_id from jtf_um_subscriptions_b
where approval_id = p_approval_id
and   nvl (effective_end_date, sysdate + 1) > sysdate;
p_subscription_id number;

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE,
      'Entering approval_chain_changed (' || p_approval_id || ',' ||
      p_org_party_id || ') API');

  open usertype_approval;
    loop
      fetch usertype_approval into p_usertype_id;
      exit when usertype_approval%NOTFOUND;

      -- Call procedure for usertype
      if p_org_party_id is not null then

        usertype_approval_changed (p_usertype_id     => p_usertype_id,
                                   p_new_approval_id => p_approval_id,
                                   p_old_approval_id => p_approval_id,
                                   p_org_party_id    => p_org_party_id);
      else

        usertype_approval_changed (p_usertype_id     => p_usertype_id,
                                   p_new_approval_id => p_approval_id,
                                   p_old_approval_id => p_approval_id);

      end if;

    end loop;
  close usertype_approval;

  open subscription_approval;
    loop
      fetch subscription_approval into p_subscription_id;
      exit when subscription_approval%NOTFOUND;

      -- Call procedure for enrollments
      if p_org_party_id is not null then

        enrollment_approval_changed (p_subscription_id => p_subscription_id,
                                     p_new_approval_id => p_approval_id,
                                     p_old_approval_id => p_approval_id,
                                     p_org_party_id    => p_org_party_id);

      else

        enrollment_approval_changed (p_subscription_id => p_subscription_id,
                                     p_new_approval_id => p_approval_id,
                                     p_old_approval_id => p_approval_id,
                                     p_org_party_id    => null);

      end if;
    end loop;
  close subscription_approval;

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting approval_chain_changed API');

end approval_chain_changed;

function get_approver_comment(p_reg_id in number,
                              p_wf_item_type in varchar2) return varchar2 is

p_approver_comment varchar2(4000);

begin

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE,
      'Entering get_approver_comment (' || p_reg_id || ',' ||
      p_wf_item_type || ') API');

  p_approver_comment := wf_engine.GetItemAttrText (
      itemtype => p_wf_item_type,
      itemkey  => to_char(p_reg_id),
      aname    => 'APPROVER_COMMENT');

  JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'Exiting get_approver_comment API');

  return p_approver_comment;

end get_approver_comment;


end JTF_UM_WF_APPROVAL;

/
