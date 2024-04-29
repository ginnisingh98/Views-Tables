--------------------------------------------------------
--  DDL for Package Body HR_TRANSACTION_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRANSACTION_SS" as
/* $Header: hrtrnwrs.pkb 120.10.12010000.11 2010/03/14 18:48:31 ckondapi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_transaction_ss.';
g_update_object_version varchar2(30) := 'update_object_version';

g_debug boolean := hr_utility.debug_enabled;

--- -------------------------------------------------------------------------
--- -------------setRespondedUserCtx-----------------------------------
--- -------------------------------------------------------------------------
-- This method calls the fnd_global.apps_initialize if the context user
-- responding to approval notification does not match fnd_global.user_name
-- --------------------------------------------------------------------------

procedure setRespondedUserCtx(p_item_type in varchar2,
                              p_item_key      in varchar2) is

  c_proc constant varchar2(60) := 'setRespondedUserCtx';
  contextUser wf_users.name%type;
  contextProxyUser wf_users.name%type;

  userId   fnd_user.user_id%type;
  c_user_name wf_users.name%type;
  l_user_role_count number default 0;
  cursor username is
  select user_id from fnd_user where user_name=contextUser;
  cursor user_role_name is
   select name from wf_roles where UPPER(EMAIL_ADDRESS) = UPPER(substr (contextUser,  7)) and ORIG_SYSTEM = 'PER' and STATUS = 'ACTIVE';
begin
    if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
       hr_utility.set_location('p_item_type:'||p_item_type,2);
       hr_utility.set_location('p_item_key:'||p_item_key,3);
       hr_utility.set_location('fnd_global.user_name:'||fnd_global.user_name,4);
       hr_utility.set_location('fnd_global.user_id:'||fnd_global.user_id,5);
   end if;


   -- check if we have the context set by the Approver Notification
   -- call back function; if exists
   -- HR_CONTEXT_USER_ATTR
      contextUser := wf_engine.getitemattrtext(p_item_type,p_item_key,'HR_CONTEXT_USER_ATTR',true);
      contextProxyUser := wf_engine.getitemattrtext(p_item_type,p_item_key,'HR_CONTEXT_PROXY_ATTR',true);

      if g_debug then
        hr_utility.set_location('contextUser value :'|| contextUser,6);
	hr_utility.set_location('contextProxyUser value :'|| contextProxyUser,6);
      end if;
   /* possible values
      Case 1: Null => Call back function does not exists or context attribute
                      never set
      Case 2: valid WF role
      Case 3: email:<incoming email address>

       Note: In case of e-mail response the response it could yield into the
             following options
             1. email address of the responder found on more than one role in
               the directory service; then context_user = 'email:'<incoming email address>
             2. email address of the responder found on one and only one role
               in the directory service; then context_user = <role name>
             3. mail address of the responder not found on any role in the
                directory service,then context_user = 'email:'<incoming email address>


      Functionally we will call apps intialization only if we have valid FND user
      and context user does not match the fnd_global.user_name
     */

     if(contextUser is not null and substr (contextUser,  1,  6)<>'email:') then
       -- we have valid wf role
       -- check if the role is same as fnd_global.user_name
       if(contextUser<>fnd_global.user_name) then
	if(nvl(contextProxyUser,fnd_global.user_name)<>fnd_global.user_name) then

         -- check if the role is a valid FND user
         if g_debug then
           hr_utility.set_location('contextUser and contextProxyUser does not match fnd_global.user_name',7);
         end if;
         open username;
         fetch username into userId;
         if username%found then
           if g_debug then
             hr_utility.set_location('found  a valid fnd user corresponding to context user',8);
             hr_utility.set_location('calling fnd_global.apps_initialize for userId:'||userId,9);
           end if;
          -- call the apps intialization
           fnd_global.apps_initialize(userId,null,null,null,null);
          if g_debug then
            hr_utility.set_location('returned from calling fnd_global.apps_initialize for userId:'||userId,10);
            hr_utility.set_location('fnd_global.user_name after reset:'||fnd_global.user_name,11);
            hr_utility.set_location('fnd_global.user_id after reset:'||fnd_global.user_id,12);
           end if;
         end if;
         close username;
       end if;
       end if;
     end if;
   if((contextUser is not null) and (substr (contextUser,  1,  6) = 'email:')) then

       --check if only one PER role is attched with this Email address
       begin
       select count(name) into l_user_role_count from wf_roles where UPPER(EMAIL_ADDRESS) = UPPER(substr (contextUser,  7)) and ORIG_SYSTEM = 'PER' and STATUS = 'ACTIVE';
       exception
       when others then
       null;
       end;
       if (l_user_role_count  > 1) OR ((l_user_role_count = 0))then
         if g_debug and l_user_role_count > 1 then
           hr_utility.set_location('more than one PER Role is attched with email: ' || substr (contextUser,  7),13);
           hr_utility.set_location('So this is setup issue.',13);
         end if;
         if g_debug and l_user_role_count = 0 then
           hr_utility.set_location('no valid PER Role attached with email: ' || substr (contextUser,  7),13);
           hr_utility.set_location('So this is setup issue.',13);
         end if;
       	return;
       end if;
       -- we have valid wf role
       -- check if the role is same as fnd_global.user_name
          open user_role_name;
       fetch user_role_name into c_user_name;
       hr_utility.set_location('c_user_name ' || c_user_name,13);
       if user_role_name%found then

       if(c_user_name<>fnd_global.user_name) then
         -- check if the role is a valid FND user
         if g_debug then
           hr_utility.set_location('contextUser and contextProxyUser does not match fnd_global.user_name for email',13);
         end if;
         contextUser := c_user_name;
         open username;
         fetch username into userId;
         if username%found then
           if g_debug then
             hr_utility.set_location('found  a valid fnd user corresponding to context user',14);
             hr_utility.set_location('calling fnd_global.apps_initialize for userId:'||userId,15);
         end if;
          -- call the apps intialization
           fnd_global.apps_initialize(userId,null,null,null,null);
         if g_debug then
            hr_utility.set_location('returned from calling fnd_global.apps_initialize for userId:'||userId,16);
            hr_utility.set_location('fnd_global.user_name:'||fnd_global.user_name,17);
            hr_utility.set_location('fnd_global.user_id:'||fnd_global.user_id,18);
            hr_utility.set_location('fnd_profile.value(PER_SECURITY_PROFILE_ID):'||fnd_profile.value('PER_SECURITY_PROFILE_ID'),19);
            hr_utility.set_location('fnd_profile.value(PER_BUSINESS_GROUP_ID):'||fnd_profile.value('PER_BUSINESS_GROUP_ID'),20);
            hr_utility.set_location('fnd_global.resp_id :'||fnd_global.resp_id,21);
            hr_utility.set_location('fnd_global.resp_appl_id :'||fnd_global.resp_appl_id,22);
            hr_utility.set_location('fnd_global.per_business_group_id :'||fnd_global.per_business_group_id,23);
            hr_utility.set_location('fnd_global.security_group_id:'||fnd_global.security_group_id,24);
            hr_utility.set_location('fnd_global.per_security_profile_id:'||fnd_global.per_security_profile_id,25);
        end if;
       end if; --end of if username%found then
       close username;
       end if; -- end of if(c_user_name<>fnd_global.user_name) then
       end if; --end of if user_role_name%found then
       close user_role_name;
  end if; --end of if(contextUser is not null and substr (contextUser,  1,  6) = 'email:') then

   if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 26);
   end if;

exception
when others then
    if ( username%isopen ) then
     close username;
    end if;
  if g_debug then
       hr_utility.set_location('Error in  setRespondedUserCtx SQLERRM' ||' '||to_char(SQLCODE),30);
   end if;
  raise;
end setRespondedUserCtx;


--- -------------------------------------------------------------------------
--- -------------reset_ame_approval_status-----------------------------------
--- -------------------------------------------------------------------------
-- This method resets the approval status of all the approvers, when the
-- transaction is returned by the aprover for correction.
-- --------------------------------------------------------------------------
procedure reset_ame_approval_status
 (p_item_type in varchar2,
  p_item_key      in varchar2)
AS
-- Variables required for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approver_rec ame_util.approverRecord;
c_additional_approver_order ame_util.orderRecord;
c_additional_approver_rec ame_util.approversTable;
c_all_approvers ame_util.approversTable;
c_proc  varchar2(30) default 'reset_ame_approval_status';

--ns begin
c_creator_user   wf_users.name%Type;
c_return_user    wf_users.name%Type;
c_return_person  number;
c_match_found    varchar2(1)  := 'N';
c_rfc_initiator  varchar2(1);
l_proc constant varchar2(100) := g_package || ' reset_ame_approval_status';
--ns end

BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
END IF;


  -- get AME related WF attribute values
 if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'HR_AME_APP_ID_ATTR') then
     -- get the attribute value
     hr_utility.trace('In : (if hr_workflow_utility.item_attribute_exists) '|| l_proc);
   c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                 itemkey  => p_item_key,
                                                 aname => 'HR_AME_APP_ID_ATTR');

 else
 hr_utility.trace('In : else of (if hr_workflow_utility.item_attribute_exists) '|| l_proc);
   c_application_id := null;
 end if;

  c_application_id := nvl(c_application_id,800);

 if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'TRANSACTION_ID') then
  -- get the attribute value
  hr_utility.trace('In : (if hr_workflow_utility.item_attribute_exists) '|| l_proc);
     c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                  itemkey  => p_item_key,
                                                  aname => 'TRANSACTION_ID');
  else
  hr_utility.trace('In : else of (if hr_workflow_utility.item_attribute_exists) '|| l_proc);
    c_transaction_id := null;
  end if;


 if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'HR_AME_TRAN_TYPE_ATTR') then
 -- get the attribute value
 hr_utility.trace('In : (if hr_workflow_utility.item_attribute_exists) '|| l_proc);
    c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');
 else
  hr_utility.trace('In : else of (if hr_workflow_utility.item_attribute_exists) '|| l_proc);
   c_transaction_type := null;

 end if;




  c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');

 if(c_transaction_type is not null) then
hr_utility.trace('In : (if(c_transaction_type is not null) ) '|| l_proc);
IF g_debug THEN
   hr_utility.trace('calling ame_api.getAllApprovers ');
END IF;

       ame_api.getAllApprovers(applicationIdIn =>c_application_id,
                            transactionIdIn=>c_transaction_id,
                            transactionTypeIn =>c_transaction_type,
                            approversOut=>c_all_approvers);

--ns begin
   c_creator_user   := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'CREATOR_PERSON_USERNAME');
   Begin
   c_return_user    := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'RETURN_TO_USERNAME');
   Exception
      WHEN others then
      hr_utility.set_location('EXCEPTION: '|| l_proc,555);
          null; -- Bug 3050544
   End;
   IF ( c_return_user IS NULL OR c_creator_user = c_return_user ) THEN
        c_rfc_initiator := 'Y';
   ELSE
        c_rfc_initiator := 'N';
        select  employee_id into c_return_person from fnd_user where user_name = c_return_user ;
   END IF;
--ns end

  for i in 1..c_all_approvers.count loop

IF g_debug THEN
    hr_utility.trace('calling ame_api..updateApprovalStatus2 ');
END IF;

   -- call AME update approval status as null
--ns comment start
     -- If Return to initiator OR
     -- to other than initiator and matching record found the update approvel status to null.
     -- Assuming approver list is sorted. All approvers appearing after selected one will be removed--ns comment end
    IF (c_rfc_initiator = 'Y' OR (c_rfc_initiator = 'N' AND c_match_found = 'Y' ) ) THEN --ns
	    ame_api.updateApprovalStatus2(applicationIdIn => c_application_id,
                                  transactionIdIn         => c_transaction_id,
                                  approvalStatusIn        => null,
                                  approverPersonIdIn      => c_all_approvers(i).person_id,
                                  approverUserIdIn        => null,
                                  transactionTypeIn       => c_transaction_type,
                                  forwardeeIn             => null);

     END IF; --ns

     IF ( c_rfc_initiator = 'N' AND  ( c_return_person = c_all_approvers(i).person_id )) THEN  --ns
            c_match_found  := 'Y';   --ns
     END IF;  --ns

  end loop;



 end if;


IF g_debug THEN
  hr_utility.set_location('Leaving:'||g_package||'.'|| c_proc, 35);
END IF;

hr_utility.set_location('Leaving: '|| l_proc,40);
EXCEPTION
when others then
hr_utility.set_location('EXCEPTION: '|| l_proc,560);
  hr_utility.trace(' exception in  '||c_proc||' : ' || sqlerrm);
  Wf_Core.Context(g_package, c_proc, p_item_type, p_item_key);
    raise;

END reset_ame_approval_status;

-----------------------------------------------------------------------------
----------------reset_approval_status-----------------------------------
---------------------------------------------------------------------------
-- This method resets the approval status of all the approvers, when the
-- transaction is returned by the aprover for correction.
-----------------------------------------------------------------------------
procedure reset_approval_status
 (p_item_type in varchar2,
  p_item_key      in varchar2)
AS
c_proc  varchar2(30) default 'reset_approval_status';
l_approvalProcessVersion varchar2(10);
l_proc constant varchar2(100) := g_package || ' reset_approval_status';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 10);
END IF;

  -- need to reset all the Workflow item attributes used in the approval process

   -- FORWARD_FROM_DISPLAY_NAME
    if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'FORWARD_FROM_DISPLAY_NAME') then
     -- set the attribute value to null
        wf_engine.SetItemAttrText(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'FORWARD_FROM_DISPLAY_NAME',
                               avalue=>null);
    end if;
   -- FORWARD_FROM_USERNAME
    if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'FORWARD_FROM_USERNAME') then
     -- set the attribute value to null
        wf_engine.SetItemAttrText(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'FORWARD_FROM_USERNAME',
                               avalue=>null);
    end if;
   -- FORWARD_FROM_PERSON_ID
    if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'FORWARD_FROM_PERSON_ID') then
     -- set the attribute value to null
        wf_engine.SetItemAttrNumber(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'FORWARD_FROM_PERSON_ID',
                               avalue=>null);
    end if;
   -- FORWARD_TO_DISPLAY_NAME
     if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'FORWARD_TO_DISPLAY_NAME') then
     -- set the attribute value to null
        wf_engine.SetItemAttrText(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'FORWARD_TO_DISPLAY_NAME',
                               avalue=>null);
    end if;
   -- FORWARD_TO_USERNAME
     if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'FORWARD_TO_USERNAME') then
     -- set the attribute value to null
        wf_engine.SetItemAttrText(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'FORWARD_TO_USERNAME',
                               avalue=>null);
    end if;
   -- FORWARD_TO_PERSON_ID
     if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'FORWARD_TO_PERSON_ID') then
     -- set the attribute value to null
        wf_engine.SetItemAttrNumber(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'FORWARD_TO_PERSON_ID',
                               avalue=>null);
    end if;

/* Bug 2940951: No need to reset current approver index and last default approver in case
 * new approval process is used and the non-AME approval is used
 * as the two attributes are set when pqh_ss_workflow.return_for_correction is invoked.
 * CAUTION: IF this procedure is invoked from somewhere else (apart from RFC) then this needs
 * to be checked for that condition too.
 */
   Begin
   l_approvalProcessVersion := wf_engine.GetItemAttrText(
                                   itemtype => p_item_Type,
                                   itemkey  => p_item_Key,
                                   aname    => 'HR_APPROVAL_PRC_VERSION');
   Exception
         when others then
         hr_utility.set_location('EXCEPTION: '|| l_proc,555);
		 null;

   End;

   IF  ( NVL(l_approvalProcessversion,'X') <> 'V5' OR
         wf_engine.GetItemAttrText(
             itemtype => p_item_Type, itemkey => p_item_Key,
                         aname => 'HR_AME_TRAN_TYPE_ATTR') IS NOT NULL) THEN
     -- CURRENT_APPROVER_INDEX
     hr_utility.trace('In (  IF  ( NVL(l_approvalProcessversion,X) <> V5 OR
         wf_engine.GetItemAttrText(..,..,..,)IS NOT NULL '|| l_proc);
     if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'CURRENT_APPROVER_INDEX') then
         -- set the attribute value to null
        wf_engine.SetItemAttrNumber(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'CURRENT_APPROVER_INDEX',
                               avalue=>null);
    end if;

    -- 'LAST_DEFAULT_APPROVER'
    if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'LAST_DEFAULT_APPROVER') then
   -- set the attribute value to null
       wf_engine.SetItemAttrNumber(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'LAST_DEFAULT_APPROVER',
                               avalue=>null);
    end if;
   END IF;

   -- CURRENT_DEF_APPR_INDEX
     if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'CURRENT_DEF_APPR_INDEX') then
     -- set the attribute value to null
       wf_engine.SetItemAttrNumber(itemtype => p_item_type ,
                               itemkey  => p_item_key,
                               aname => 'CURRENT_DEF_APPR_INDEX',
                               avalue=>null);
    end if;



IF g_debug THEN
  hr_utility.set_location('Leaving:'||g_package||'.'|| c_proc, 20);
END IF;

hr_utility.set_location('Leaving: '|| l_proc,25);
EXCEPTION
when others then
hr_utility.set_location('EXCEPTION: '|| l_proc,560);
  hr_utility.trace(' exception in  '||c_proc||' : ' || sqlerrm);
  Wf_Core.Context(g_package, c_proc, p_item_type, p_item_key);
    raise;

END reset_approval_status;

-- ----------------------------------------------------------------------------
-- get workflow attribute p_effective_date.
-- ----------------------------------------------------------------------------

FUNCTION get_wf_effective_date
  (p_transaction_step_id in number)
RETURN varchar2 IS

  cursor csr_item_type_key is
  select item_type,item_key
    from hr_api_transaction_steps
   where transaction_step_id = p_transaction_step_id;

  l_item_type hr_api_transaction_steps.item_type%type;
  l_item_key hr_api_transaction_steps.item_key%type;
  l_effective_date varchar2(100);
l_proc constant varchar2(100) := g_package || ' get_wf_effective_date';
BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);
  open csr_item_type_key;
  fetch csr_item_type_key into l_item_type,l_item_key;
  close csr_item_type_key;
  if l_item_type is not null and l_item_key is not null then
    l_effective_date := wf_engine.getitemattrtext
                          (itemtype => l_item_type
                          ,itemkey  => l_item_key
                          ,aname    => 'P_EFFECTIVE_DATE');
  else
    l_effective_date := null;
  end if;
hr_utility.set_location('Leaving: '|| l_proc,10);
  return l_effective_date;

EXCEPTION
  when others then

hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    return null;

END get_wf_effective_date;

-------------------------------------------------------------------------------
-- set workflow item attribute 'TRAN_SUBMIT'
-- 'S' -- Save for Later
-- 'C' -- Returned for Correction
-- 'A' -- Submitted for Approval
-- 'N' -- this is the default value. It is for the system crash or system time
--        out.
-- ----------------------------------------------------------------------------
procedure set_save_for_later_status
    (p_item_type in     varchar2
    ,p_item_key  in     varchar2
    ,p_status    in     varchar2
    ,p_transaction_id in number default null) is
    l_proc constant varchar2(100) := g_package || ' set_save_for_later_status';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  If (p_item_type is not null  and
      p_item_key is not null )
  then
    wf_engine.SetItemAttrText(itemtype  => p_item_type,
                    itemkey     => p_item_key,
                    aname       => 'TRAN_SUBMIT',
                    avalue      => p_status);
  End If;

  If p_transaction_id is not null then

    hr_transaction_api.update_transaction(p_transaction_id => p_transaction_id,
                                        p_status => p_status );
  end If;

hr_utility.set_location('Leaving: '|| l_proc,10);
end set_save_for_later_status;

procedure set_initial_save_for_later
 (itemtype in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is
  l_proc constant varchar2(100) := g_package || ' set_initial_save_for_later';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  if ( funmode = 'RUN' ) then
    set_save_for_later_status
      (p_item_type => itemtype,
       p_item_key => itemkey,
       p_status => 'W');
    result := 'COMPLETE:SUCCESS';
  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,10);

end set_initial_save_for_later;

procedure set_delete_save_for_later
 (itemtype in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is
ln_transaction_id hr_api_transactions.transaction_id%TYPE;
l_proc constant varchar2(100) := g_package || ' set_delete_save_for_later';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  if ( funmode = 'RUN' ) then
    ln_transaction_id := get_transaction_id(itemtype, itemkey);
    set_save_for_later_status
      (p_item_type => itemtype,
       p_item_key => itemkey,
       p_status => 'D',
       p_transaction_id => ln_transaction_id);
    result := 'COMPLETE:SUCCESS';
  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
  end if;
hr_utility.set_location('Leaving: '|| l_proc,10);
end set_delete_save_for_later;


procedure set_save_for_later
 (itemtype in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is
  l_proc constant varchar2(100) := g_package || ' set_save_for_later';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  if ( funmode = 'RUN' ) then
    set_save_for_later_status
      (p_item_type => itemtype,
       p_item_key => itemkey,
       p_status => 'S');
    result := 'COMPLETE:SUCCESS';
  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
hr_utility.set_location('Leaving: '|| l_proc,10);
end set_save_for_later;


procedure set_return_for_correction
 (itemtype in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is
ln_transaction_id hr_api_transactions.transaction_id%TYPE;
l_result  varchar2(2000); --ns
l_transaction_ref_table hr_api_transactions.transaction_ref_table%type;
l_proc constant varchar2(100) := g_package || ' set_return_for_correction';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  if ( funmode = 'RUN' ) then
  hr_utility.trace('In (:  if ( funmode = RUN )'|| l_proc);
  --ns commented
  --ns this procedure is replace by the one below to set the return for correction status appropriately.
/*
    ln_transaction_id := get_transaction_id(itemtype, itemkey);
    set_save_for_later_status
      (p_item_type => itemtype,
       p_item_key => itemkey,
       p_status => 'C',
       p_transaction_id => ln_transaction_id);
*/
   --ns call this procedure
   pqh_ss_workflow.set_transaction_status (
        p_itemType  => itemType
       ,p_itemKey   => itemKey
       ,p_action    => 'RFC'
       ,p_result    => l_result );


   -- need to call the AME to reset the approval status of the approvers.
   reset_ame_approval_status (p_item_type =>itemtype,
                              p_item_key  =>itemkey);
   -- need to reset the workflow item attributes values used in Approval process
   reset_approval_status(p_item_type =>itemtype,
                         p_item_key  =>itemkey);

   -- as per the appraisals new build sshr5.1 check if we need call the appraisals routine
   -- in RFC
      begin
	-- check if this is a appraisal transaction
        -- the hr_api_transactions.transaction_ref_table should be used for reference
        -- get the transaction id
        ln_transaction_id := get_transaction_id(itemtype, itemkey);

        -- get the transaction_ref_table
        select transaction_ref_table
        into l_transaction_ref_table
        from hr_api_transactions
        where transaction_id=ln_transaction_id;

       if(upper(l_transaction_ref_table)='PER_APPRAISALS') then
         hr_appraisal_workflow_ss.set_appraisal_rfc_status(p_itemtype=>itemType
								,p_itemkey=>itemKey
								,p_actid=>actid
								,p_funcmode=>funmode
								,p_result=> l_result);
       end if;

      exception
      when others then
      hr_utility.set_location('EXCEPTION: '|| l_proc,555);
       raise;
      end;
    result := 'COMPLETE:SUCCESS';
  elsif ( funmode = 'CANCEL' ) then
    hr_utility.trace('In (:  if ( funmode = CANCEL )'|| l_proc);
    --
    null;
    --
    --
end if;
hr_utility.set_location('Leaving: '|| l_proc,20);

end set_return_for_correction;


procedure set_submit_for_approval
 (itemtype in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is
ln_transaction_id hr_api_transactions.transaction_id%TYPE;
l_proc constant varchar2(100) := g_package || ' set_submit_for_approval';
begin
hr_utility.set_location('Entering: '|| l_proc,5);

  if ( funmode = 'RUN' ) then
    ln_transaction_id := get_transaction_id(itemtype, itemkey);
    set_save_for_later_status
      (p_item_type => itemtype,
       p_item_key => itemkey,
       p_status => 'Y',
       p_transaction_id => ln_transaction_id);
    result := 'COMPLETE:SUCCESS';
  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
hr_utility.set_location('Leaving: '|| l_proc,10);
end set_submit_for_approval;


-- ----------------------------------------------------------------------------
-- |---------------------------< get_transaction_id >-------------------------|
-- ----------------------------------------------------------------------------
function get_transaction_id
  (p_item_type   in varchar2
  ,p_item_key    in varchar2) return number is
  l_proc constant varchar2(100) := g_package || ' get_transaction_id';
--
l_transaction_id number;
begin
hr_utility.set_location('Entering: '|| l_proc,5);
hr_utility.set_location('Leaving: '|| l_proc,10);
  return(wf_engine.getitemattrnumber
           (itemtype => p_item_type
           ,itemkey  => p_item_key
           ,aname    => 'TRANSACTION_ID'));
exception
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    -- the TRANSACTION_ID doesn't exist as an item so return null
    select transaction_id into l_transaction_id from hr_api_transactions where item_type = p_item_type and item_key = p_item_key;
    hr_utility.set_location('l_transaction_id: '|| l_transaction_id,10);
    return(l_transaction_id);

end get_transaction_id;

PROCEDURE populate_null_values
    (p_item_type IN VARCHAR2
    ,p_item_key IN VARCHAR2
    ,p_function_id                  in number
    ,p_selected_person_id           in number
    ,p_process_name                 in varchar2
    ,p_status                       in varchar2
    ,p_section_display_name          in varchar2
    ,p_assignment_id                in number
    ,p_transaction_effective_date   in date
    ,p_transaction_type             in varchar2
    ,l_function_id                  in out nocopy hr_api_transactions.function_id%TYPE
    ,ln_selected_person_id          in out nocopy hr_api_transactions.selected_person_id%TYPE
    ,lv_process_name                in out nocopy hr_api_transactions.process_name%TYPE
    ,lv_status                      in out nocopy hr_api_transactions.status%TYPE
    ,lv_section_display_name        in out nocopy hr_api_transactions.section_display_name%TYPE
    ,ln_assignment_id               in out nocopy hr_api_transactions.assignment_id%TYPE
    ,ld_trans_effec_date            in out nocopy hr_api_transactions.transaction_effective_date%TYPE
    ,lv_transaction_type            in out nocopy hr_api_transactions.transaction_type%TYPE
    )
AS
        cursor get_function_info ( p_item_type HR_API_TRANSACTION_STEPS.item_type%TYPE
                              ,p_item_key HR_API_TRANSACTION_STEPS.item_key%TYPE ) is
        select fff.function_id, fff.function_name from
        fnd_form_functions_vl fff
        where fff.function_name = ( select iav.text_value
                                    from wf_item_attribute_values iav
                                    where iav.item_type = p_item_type
                                    and iav.item_key = p_item_key
                                    and iav.name = 'P_CALLED_FROM') ;

        l_function_name fnd_form_functions_vl.function_name%TYPE default null;
l_proc constant varchar2(100) := g_package || '  populate_null_values';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
       If p_function_id is null then
       hr_utility.trace('In(If p_function_id is null)'|| l_proc);
          If p_item_type is not null and p_item_key is not null then
hr_utility.trace('In(p_item_type is not null and p_item_key is not null)'|| l_proc);
        	OPEN get_function_info(p_item_type => p_item_type,
                                      p_item_key => p_item_key);

        	FETCH get_function_info into l_function_id, l_function_name;
	-- fix for bug 7658326
        	/*IF(get_function_info%notfound) then
            		CLOSE get_function_info;
        	END if;*/
        	close get_function_info;
          end if;
       else
       hr_utility.trace('In else of (If p_function_id is null)'|| l_proc);
            l_function_id := p_function_id;
       end if;

       If p_selected_person_id is  null then
          If p_item_type is not null and p_item_key is not null then
            ln_selected_person_id := wf_engine.GetItemAttrNumber(p_item_type,
                                        p_item_key,
                                        'CURRENT_PERSON_ID');
          end if;
       else
            ln_selected_person_id := p_selected_person_id;
       end if;

       If p_process_name is  null then
          If p_item_type is not null and p_item_key is not null then
            lv_process_name := wf_engine.GetItemAttrText(p_item_type
                                                       ,p_item_key
                                                       ,'PROCESS_NAME');
          end if;
       else
            lv_process_name :=   p_process_name;
       end if;

       If p_status is  null then
          If  p_item_type is not null and p_item_key is not null then
            lv_status := wf_engine.GetItemAttrText(p_item_type
                                                   ,p_item_key
                                                   ,'TRAN_SUBMIT');
            end if;
       else
            lv_status := p_status;
       end if;

       If p_section_display_name is  null  then
          If p_item_type is not null and p_item_key is not null then
            lv_section_display_name := wf_engine.GetItemAttrText( p_item_type
                                                               ,p_item_key
                                                               ,'HR_SECTION_DISPLAY_NAME');
          end if;
       else
            lv_section_display_name := p_section_display_name;
       end if;

       If p_assignment_id is  null then
          If p_item_type is not null and p_item_key is not null then
            ln_assignment_id := wf_engine.GetItemAttrText(p_item_type
                                                       ,p_item_key
                                                       ,'CURRENT_ASSIGNMENT_ID');
          end if;
       else
          ln_assignment_id := p_assignment_id;
       end if;

       If p_transaction_effective_date is  null then
          If p_item_type is not null and p_item_key is not null then
            ld_trans_effec_date := wf_engine.GetItemAttrText(p_item_type
                                                       ,p_item_key
                                                       ,'CURRENT_EFFECTIVE_DATE');
          end if;
       else
          ld_trans_effec_date := p_transaction_effective_date;
       end if;


        If p_item_type is not null and p_item_key is not null then
          lv_transaction_type := nvl(p_transaction_type,'WF');
       	else
          lv_transaction_type := nvl(p_transaction_type,'NWF');
        end if;

hr_utility.set_location('Leaving: '|| l_proc,20);
END populate_null_values;

-- ----------------------------------------------------------------------------
-- |----------------------------< start_transaction >-------------------------|
-- ----------------------------------------------------------------------------
procedure start_transaction
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,p_login_person_id in number
  ,p_product_code                   in varchar2 default null
  ,p_url                          in varchar2 default null
  ,p_status                       in varchar2 default null
  ,p_section_display_name          in varchar2 default null
  ,p_function_id                  in number default null
  ,p_transaction_ref_table        in varchar2 default 'HR_API_TRANSACTIONS'
  ,p_transaction_ref_id           in number default null
  ,p_transaction_type             in varchar2 default null
  ,p_assignment_id                in number default null
  ,p_api_addtnl_info              in varchar2 default null
  ,p_selected_person_id           in number default null
  ,p_transaction_effective_date       in date default null
  ,p_process_name                 in varchar2 default null
  ,p_plan_id                      in number default null
  ,p_rptg_grp_id                  in number default null
  ,p_effective_date_option        in varchar2 default null
  ,result         out nocopy  varchar2) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_transaction_privilege    hr_api_transactions.transaction_privilege%type;
  l_transaction_id           hr_api_transactions.transaction_id%type;

  l_function_id           hr_api_transactions.function_id%TYPE;
  ln_selected_person_id   hr_api_transactions.selected_person_id%TYPE;
  lv_process_name         hr_api_transactions.process_name%TYPE;
  lv_status               hr_api_transactions.status%TYPE;
  lv_section_display_name hr_api_transactions.section_display_name%TYPE;
  ln_assignment_id        hr_api_transactions.assignment_id%TYPE;
  ld_trans_effec_date     hr_api_transactions.transaction_effective_date%TYPE;
  lv_transaction_type     hr_api_transactions.transaction_type%TYPE;
l_proc constant varchar2(100) := g_package || ' start_transaction';
  --
begin
hr_utility.set_location('Entering: '|| l_proc,5);
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.trace('In (IF g_debug )'|| l_proc);
END IF;

    populate_null_values
    (itemtype
    ,itemkey
    ,p_function_id
    ,p_selected_person_id
    ,p_process_name
    ,p_status
    ,p_section_display_name
    ,p_assignment_id
    ,p_transaction_effective_date
    ,p_transaction_type
    ,l_function_id
    ,ln_selected_person_id
    ,lv_process_name
    ,lv_status
    ,lv_section_display_name
    ,ln_assignment_id
    ,ld_trans_effec_date
    ,lv_transaction_type
    );



  if funmode = 'RUN' then
  hr_utility.trace('In (if funmode = RUN) '|| l_proc);
    savepoint start_transaction;
    -- check to see if the TRANSACTION_ID attribute has been created
    if hr_workflow_utility.item_attribute_exists
         (p_item_type => itemtype
         ,p_item_key  => itemkey
         ,p_name      => 'TRANSACTION_ID') then
         hr_utility.trace('In (if hr_workflow_utility.item_attribute_exists) '|| l_proc);
      -- the TRANSACTION_ID exists so ensure that it is null
      if get_transaction_id
        (p_item_type => itemtype
        ,p_item_key  => itemkey) is not null then
        -- a current transaction is in progress we cannot overwrite it
        -- hr_utility.set_message(801, 'HR_51750_WEB_TRANSAC_STARTED');
        -- hr_utility.raise_error;
        result := 'SUCCESS';
        hr_utility.set_location('Leaving: '|| l_proc,25);
        return;
      end if;
    else
    hr_utility.trace('In else of (if hr_workflow_utility.item_attribute_exists) '|| l_proc);
      -- the TRANSACTION_ID does not exist so create it
      wf_engine.additemattr
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'TRANSACTION_ID');
    end if;
     -- check to see if the TRANSACTION_PRIVILEGE attribute has been created
    if not hr_workflow_utility.item_attribute_exists
         (p_item_type => itemtype
         ,p_item_key  => itemkey
         ,p_name      => 'TRANSACTION_PRIVILEGE') then
      -- the TRANSACTION_PRIVILEGE does not exist so create it
      wf_engine.additemattr
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'TRANSACTION_PRIVILEGE');
    end if;
    -- get the TRANSACTION_PRIVILEGE
    l_transaction_privilege :=
      wf_engine.getitemattrtext
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'TRANSACTION_PRIVILEGE');
    -- check to see if the TRANSACTION_PRIVILEGE is null
    if l_transaction_privilege is null then
      -- default the TRANSACTION_PRIVILEGE to PRIVATE
      l_transaction_privilege := 'PRIVATE';
      wf_engine.setitemattrtext
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'TRANSACTION_PRIVILEGE'
        ,avalue   => l_transaction_privilege);
    end if;
    -- call the BP API to create the transaction
/*
    hr_transaction_api.create_transaction
      (p_validate               => false
      ,p_creator_person_id      => p_login_person_id
      ,p_transaction_privilege  => l_transaction_privilege
      ,p_transaction_id         => l_transaction_id);
*/


 hr_transaction_api.create_transaction(
		p_validate               => false
               ,p_creator_person_id      => p_login_person_id
               ,p_transaction_privilege  => l_transaction_privilege
               ,p_transaction_id         => l_transaction_id
               ,p_product_code => p_product_code
               ,p_url=> p_url
               ,p_status=>lv_status
               ,p_section_display_name=>lv_section_display_name
               ,p_function_id=>l_function_id
               ,p_transaction_ref_table=>p_transaction_ref_table
               ,p_transaction_ref_id=>p_transaction_ref_id
               ,p_transaction_type=>lv_transaction_type
               ,p_assignment_id=>ln_assignment_id
               ,p_selected_person_id=>ln_selected_person_id
               ,p_item_type=>itemtype
               ,p_item_key=>itemkey
               ,p_transaction_effective_date=>ld_trans_effec_date
               ,p_process_name=>lv_process_name
               ,p_plan_id=>p_plan_id
               ,p_rptg_grp_id=>p_rptg_grp_id
               ,p_effective_date_option=>p_effective_date_option
               ,p_api_addtnl_info=>p_api_addtnl_info);

    -- set the TRANSACTION_ID
    wf_engine.setitemattrnumber
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'TRANSACTION_ID'
        ,avalue   => l_transaction_id);
    -- transaction has been successfully created so commit and return success
    -- commit;
    result := 'SUCCESS';
  elsif funmode = 'CANCEL' then
  hr_utility.trace('In ( elsif funmode = CANCEL) '|| l_proc);
    null;
  end if;

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 30);
END IF;
hr_utility.set_location('Leaving: '|| l_proc,35);
exception
  when hr_util_web.g_error_handled then
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    -- error from validating the login
    rollback to start_transaction;
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,560);
    -- rollback any work
    rollback to start_transaction;
    raise;
  --
end start_transaction;

-- ----------------------------------------------------------------------------
-- |----------------------------< rollback_transaction >----------------------|
-- ----------------------------------------------------------------------------
procedure rollback_transaction
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result         out nocopy  varchar2) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  lv_transaction_ref_table hr_api_transactions.transaction_ref_table%type;
  l_proc constant varchar2(100) := g_package || ' rollback_transaction';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  if funmode = 'RUN' then
  hr_utility.trace('In ( if funmode = RUN ) '|| l_proc);
      -- Get the TRANSACTION_ID exists so ensure that it is null
      if get_transaction_id
                (p_item_type => itemtype
        ,p_item_key  => itemkey) is not null then
    hr_utility.trace('In ( if get_transaction_id(..,.., ) '|| l_proc);
          savepoint rollback_transaction;
            -- check if this is appraisal transaction
          -- we need to call the custom call to update the appraisal status
          begin
           select hr_api_transactions.transaction_ref_table
            into lv_transaction_ref_table
            from hr_api_transactions
            where hr_api_transactions.transaction_id=(get_transaction_id(itemtype,itemkey));
                /* BUG FIX 3112230
           	if(lv_transaction_ref_table='PER_APPRAISALS') then
                 -- call the custom call to update the status
                 hr_appraisal_workflow_ss.set_appraisal_reject_status(itemtype,itemkey, actid ,
                                                                    funmode,result );
                end if;
                */
           exception
           when others then
           hr_utility.set_location('EXCEPTION: '|| l_proc,555);
            hr_utility.trace(' exception in checking the hr_api_transactions.transaction_ref_table:'||
                             'rollback_transaction'||' : ' || sqlerrm);
            -- just log the message no need to raise it
           end;

          hr_transaction_api.rollback_transaction
                 (p_transaction_id => get_transaction_id
                             (p_item_type => itemtype
                             ,p_item_key  => itemkey));
       end if;
    --commit;
    result := 'SUCCESS';
  elsif funmode = 'CANCEL' then
  hr_utility.trace('In ( if funmode = CANCEL ) '|| l_proc);
    null;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,20);
exception
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,560);
    -- rollback any work
    rollback to rollback_transaction;
    -- raise a system error
    raise;
end rollback_transaction;

-- ----------------------------------------------------------------------------
-- |-------------------------< process_web_api_call >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will for the specified transaction step and web form API
--   name execute the API using dynamic PL/SQL.
--
-- Pre-Requisities:
--   The transaction step and API code must exist.
--
-- In Parameters:
--   p_transaction_step_id -> The transaction step identifier.
--   p_api_name            -> The API name to be called (e.g.
--                            hr_emp_marital_web.process_api).
--   p_validate            -> If set to TRUE all the work
--                            performed by the API will be
--                            rolled back. If set to FALSE,
--                            the work is not rolled back.
--
-- Post Success:
--   The API would be dynamically built, parsed and executed.
--
-- Post Failure:
--   The exception is raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure process_web_api_call
  (p_transaction_step_id   in number
  ,p_api_name              in varchar2
  ,p_extra_parameter_name  in varchar2 default null
  ,p_extra_parameter_value in varchar2 default null
  ,p_validate              in boolean  default false) is
  --
  l_sqlbuf               varchar2(1000);
  l_cursor               integer;
  l_row_processed        integer;
  l_extra_parameter_text varchar2(2000);
  l_process_api          boolean := false;
  l_error                varchar2(2000);
  l_proc constant varchar2(100) := g_package || ' process_web_api_call';
  --
  cursor csel is
    select nvl(varchar2_value, hr_api.g_varchar2)          varchar2_value
          ,nvl(number_value, hr_api.g_number)              number_value
          ,nvl(date_value, hr_api.g_date)                  date_value
          ,nvl(original_varchar2_value, hr_api.g_varchar2) original_varchar2_value
          ,nvl(original_number_value, hr_api.g_number)     original_number_value
          ,nvl(original_date_value, hr_api.g_date)         original_date_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = p_transaction_step_id;
  --
begin
  /* this step has been commented out nocopy and should not be used until */
  /* the transaction step is save on display_workspace. */
  /* post release 11 */
  /*
  -- before we do any processing lets determine if the step needs to be
  -- processed
  for hr_trs_csr in csel loop
    if not((hr_trs_csr.varchar2_value = hr_trs_csr.original_varchar2_value) and
      (hr_trs_csr.number_value = hr_trs_csr.original_number_value) and
      (hr_trs_csr.date_value = hr_trs_csr.original_date_value)) then
      l_process_api := true;
      exit;
    end if;
  end loop;
  */

  hr_utility.set_location('Entering: '|| l_proc,5);
  l_process_api := true;
  --
  if l_process_api then
  hr_utility.trace('In ( if l_process_api): '|| l_proc);
    --
    -- issue a savepoint if operating in validation only mode.
    --
    if p_validate then
      savepoint process_web_api_call;
    end if;
    -- define the anonymous pl/sql block that is going to be executed
    --
    -- begin
    --   hr_emp_marital_web.process_api
    --     (p_transaction_step_id => :transaction_step_id);
    -- end;
    --
    if p_extra_parameter_name is not null then
      l_extra_parameter_text := ','||p_extra_parameter_name||' => :'||
                                p_extra_parameter_name;
    end if;
    --
    l_sqlbuf :=
      'begin '||p_api_name||
      '(p_transaction_step_id => '||':transaction_step_id'||
      l_extra_parameter_text||'); end;';
    -- open the dynamic cursor
    l_cursor := dbms_sql.open_cursor;
    -- parse the dynamic cursor
    dbms_sql.parse(l_cursor, l_sqlbuf, dbms_sql.v7);
    -- bind the transaction step identifier
    dbms_sql.bind_variable
      (l_cursor, ':transaction_step_id', p_transaction_step_id);
    if l_extra_parameter_text is not null then
      dbms_sql.bind_variable
      (l_cursor, ':'||p_extra_parameter_name, p_extra_parameter_value);
    end if;
    -- execute the dynamic statement
    l_row_processed := dbms_sql.execute(l_cursor);
    -- close the cursor
    dbms_sql.close_cursor(l_cursor);
    --
    -- when in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,15);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    rollback to process_web_api_call;
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,560);

    --close the cursor
    dbms_sql.close_cursor(l_cursor);
    raise;
end process_web_api_call;

-- ----------------------------------------------------------------------------
-- |---------------------------< process_transaction >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will for a transaction, identify all the steps which need
--   to be processed. Each step is then processed by calling the
--   procedure process_web_api_call.
--
-- Pre-Requisities:
--   None.
--
-- In Parameters:
--   p_item_type      -> The internal name for the item type.
--   p_item_key       -> A string that represents a primary key generated by
--                       the application for the item type. The string
--                       uniquely identifies the item within an item type.
--   p_ignore_warings -> If set to 'Y' then all warnings encountered during
--                       processing are ignored (i.e. no error is raised).
--                       If set to 'N' then any warnings encountered are
--                       not ignored and raised.
--
-- Post Success:
--   The transaction will be converted in API calls.
--
-- Post Failure:
--   The exception is raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure process_transaction
  (p_item_type           in varchar2
  ,p_item_key            in varchar2
  ,p_ignore_warnings     in varchar2 default 'Y'
  ,p_validate            in boolean default false
  ,p_update_object_version in varchar2 default 'N'
  ,p_effective_date      in varchar2 default null) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_transaction_id      hr_api_transactions.transaction_id%type;
  l_application_error   boolean := false;
  l_object_version_error   boolean := false;
  l_obj_fatal_error     boolean := false;
  l_warning_error       boolean := false;
  l_ignore_warnings     boolean;
  l_obj_api_name        varchar2(200);
  l_api_error_name      varchar2(200);
  l_proc constant varchar2(100) := g_package || ' process_transaction';
  --
  cursor csr_trs is
    select trs.transaction_step_id
          ,trs.api_name
          ,trs.item_type
          ,trs.item_key
          ,trs.activity_id
          ,trs.creator_person_id
    from   hr_api_transaction_steps trs
    where  trs.transaction_id = l_transaction_id
    and trs.api_name <> 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API' --#4110654
    and object_type is null
    order by trs.processing_order,trs.transaction_step_id ; --#2313279
  --
  cursor cur_fn is
    select fff.parameters
      from fnd_form_functions fff, hr_api_transactions hat
     where fff.function_id = hat.function_id
       and hat.transaction_id = l_transaction_id;
  --
  l_parameter fnd_form_functions.parameters%TYPE;
  l_effectiveDate boolean := FALSE;
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  -- set the ignore warnings flag
  if upper(p_ignore_warnings) = 'Y' then
    l_ignore_warnings := true;
  else
    l_ignore_warnings := false;
  end if;
  -- get the transaction id
  l_transaction_id := get_transaction_id
                         (p_item_type => p_item_type
                         ,p_item_key  => p_item_key);
  if l_transaction_id is null then
     fnd_message.set_name('PER','l_transaction_id');
     hr_utility.raise_error;
  end if;
  -- set the Profiles before starting to process any step.
  hr_utility.set_location('Call Set_Transaction_Context: '|| l_proc, 10);
  -- Call Set_Transaction_Context
  hr_transaction_swi.set_transaction_context(l_transaction_id);

  -- If p_effective_date is not NULL then set it on the g_txn_ctx.EFFECTIVE_DATE
  if ( p_effective_date is not null ) then
    BEGIN
        hr_transaction_swi.g_txn_ctx.EFFECTIVE_DATE := trunc(fnd_date.canonical_to_date(p_effective_date));
      EXCEPTION When Others then
        hr_transaction_swi.g_txn_ctx.EFFECTIVE_DATE := trunc(fnd_date.chardate_to_date(p_effective_date));
    END;
  end if;

  hr_utility.set_location('Call Set_Person_Context: '|| l_proc, 15);
  -- Call Set_Person_Context

  hr_transaction_swi.set_person_context(
                      p_selected_person_id      => hr_transaction_swi.g_txn_ctx.SELECTED_PERSON_ID,
                      p_selected_assignment_id  => hr_transaction_swi.g_txn_ctx.ASSIGNMENT_ID,
                      p_effective_date          => hr_transaction_swi.g_txn_ctx.EFFECTIVE_DATE
                   );

  -- select each transaction steps to process
  hr_utility.set_location('select each transaction steps to process: '|| l_proc, 20);
  open  cur_fn;
  fetch cur_fn INTO l_parameter;
  close cur_fn;
  --
  if ( INSTR(l_parameter,'pEffectiveDate') > 0 ) then
       l_effectiveDate := true;
  else
       l_effectiveDate := false;
  end if;

  hr_process_person_ss.g_person_id := null;
  hr_process_person_ss.g_assignment_id := null;
  hr_process_person_ss.g_session_id := null;
  hr_new_user_reg_ss.g_ignore_emp_generation := 'NO';
hr_utility.trace('In (for I in csr_trs loop)  '|| l_proc);
  for I in csr_trs loop
    begin
      -- call the API for the transaction step
      if p_update_object_version = 'Y' then
        -- update object version for each step
        l_obj_api_name := substr(I.api_name,1, instr(I.api_name,'.'));
        l_obj_api_name := l_obj_api_name || g_update_object_version;
        process_web_api_call
        (p_transaction_step_id => I.transaction_step_id
        ,p_api_name            => l_obj_api_name
        ,p_extra_parameter_name => 'p_login_person_id'
        ,p_extra_parameter_value => I.creator_person_id
        ,p_validate => false);

      elsif p_effective_date is not null and l_effectiveDate then

/*      elsif p_effective_date is not null then
        --ns 11/06/2003: Bug 3223682: Validate non-Assignment data alone.
        IF  NOT( p_ignore_warnings = 'NON_ASGN' AND  I.api_name IN (
                  'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API',
                  'HR_SUPERVISOR_SS.PROCESS_API',
                  'HR_TERMINATION_SS.PROCESS_API',
                  'HR_PAY_RATE_SS.PROCESS_API' ,
                  'HR_CAED_SS.PROCESS_API'      )            ) THEN
-- Fix 3263968. Included HR_CAED_SS.PROCESS_API
*/
        --validate api with the new p_effective_date
        process_web_api_call
        (p_transaction_step_id => I.transaction_step_id
        ,p_api_name            => I.api_name
        ,p_extra_parameter_name => 'p_effective_date'
        ,p_extra_parameter_value => p_effective_date
        ,p_validate => p_validate);
/*
        END IF;
*/
      else
        --validate api
        process_web_api_call
        (p_transaction_step_id => I.transaction_step_id
        ,p_api_name            => I.api_name
        ,p_validate => p_validate);
      end if;
      -- do we ignore any warnings which may have been set?
      if not l_ignore_warnings then
        -- check to see if any warnings have been set
        if (not l_warning_error) and
          hr_emp_error_utility.exists_warning_text
            (p_item_type => I.item_type
            ,p_item_key  => I.item_key
            ,p_actid     => I.activity_id) then
          -- set the warning flag to true
          l_warning_error := true;
        end if;
      end if;
    exception
      when hr_utility.hr_error then
      hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        -- an application error has been raised. set the error flag
        -- to indicate an application error
        -- the error message should of been set already
        hr_message.provide_error;
        l_api_error_name := hr_message.last_message_name;
        if l_api_error_name = 'HR_7155_OBJECT_INVALID' then
          l_obj_fatal_error := true;
          exit;
          --if csr.api_name = 'BEN_PROCESS_COMPENSATION_W.PROCESS_API' then
          --  fnd_message.set_name('PER','HR_FATAL_OBJECT_ERROR');
          --  l_obj_fatal_error := true;
          --  exit;
          --end if;
        else
          l_application_error := true;

          -------------------------------------------------------------------
          -- 05/09/2002 Bug 2356339 Fix Begins
          -- We need to exit the loop here when there is an application error.
          -- This will happen when apporval is required and the final approver
          -- approved the change.  When the Workflow responsibility to approve
          -- the transaction has no Security Profile attached, and the
          -- Business Group profile option is null and Cross Business Group
          -- equals to 'N', you will get an Application Error after the final
          -- approver approves the transaction.  This problem usually happens
          -- in New Hire or Applicant Hire whereby the new employee created
          -- is not in the per_person_list table.  In hr_process_person_ss.
          -- process_api, it call hr_employee_api.create_employee which
          -- eventually will call dt_api.return_min_start_date.  This
          -- dt_api.return_min_start_date accesses the per_people_f secured
          -- view, you will get HR_7182_DT_NO_MIN_MAX_ROWS error with the
          -- following error text:
          --  No DateTrack row found in table per_people_f.
          -- When that happens, the l_application_error is set to true. However,
          -- if there is no Exit statement, this code will continue to call
          -- the next transaction step.  Each of the subsequent step will fail
          -- with an error until the last step is called and the error from
          -- the last step will overwrite the initial real error message.
          -- Without the exit statement, it will be very difficult to pinpoint
          -- the location where the real problem occurred.
          ---------------------------------------------------------------------

          EXIT;  -- Bug 2356339 Fix

          -- 05/09/2002 Bug 2356339 Fix Ends

        end if;
      when others then
      hr_utility.set_location('EXCEPTION: '|| l_proc,560);
        -- a system error has occurred so raise it to stop
        -- processing of the transaction steps
        raise;
    end;
  end loop;
  -- check to see if any application errors where raised
  if l_obj_fatal_error then
    fnd_message.set_name('PER','HR_FATAL_OBJECT_ERROR');
    raise hr_utility.hr_error;
  elsif l_object_version_error then
    fnd_message.set_name('PER','HR_7155_OBJECT_INVALID');
    raise hr_utility.hr_error;
  elsif l_application_error or l_warning_error then
    raise hr_utility.hr_error;
  end if;
hr_utility.set_location('Leaving: '|| l_proc,15);

exception
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,565);
    -- an application error, warning or system error was raised so
    -- keep raising it so the calling process must handle it
    raise;
end process_transaction;


-- ----------------------------------------------------------------------------
-- |----------------------------< validate_transaction >----------------------|
-- ----------------------------------------------------------------------------
procedure validate_transaction
  (p_item_type      in     varchar2
  ,p_item_key       in     varchar2
  ,p_effective_date in varchar2 default null
  ,p_update_object_version in varchar2 default 'N'
  ,p_result         out nocopy varchar2) is
l_proc constant varchar2(100) := g_package || '  validate_transaction';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
   validate_transaction (
       p_item_type   => p_item_type
      ,p_item_key    => p_item_key
      ,p_effective_date => p_effective_date
      ,p_update_object_version => p_update_object_version
      ,p_ignore_warnings  => 'N'
      ,p_result         => p_result );

hr_utility.set_location('Leaving: '|| l_proc,10);
end;


-- ns 11/06/2003: Bug 3223682: Overloaded validate_transaction with additional
-- parameter p_ignore_warnings. The value for this would be NON_ASGN
-- when invoked while editing a save/rfc/pending/wip action, since assignment
-- related validations are already performed elsewhere.
-- Dependency: Package specification modified
-- ----------------------------------------------------------------------------
-- |-----------------------< overloaded validate_transaction >-----------------|
-- ----------------------------------------------------------------------------
procedure validate_transaction
  (p_item_type      in     varchar2
  ,p_item_key       in     varchar2
  ,p_effective_date in varchar2 default null
  ,p_update_object_version in varchar2 default 'N'
  ,p_ignore_warnings in varchar2 default 'N'
  ,p_result         out nocopy varchar2) is
  l_proc constant varchar2(100) := g_package || ' validate_transaction';
begin
    hr_utility.set_location('Entering: '|| l_proc,5);
  p_result := 'N';
  savepoint VALIDATE_TRANSACTION;
  begin
    -- process the transaction reporting warnings if they exist
    process_transaction
        (p_item_type       => p_item_type
        ,p_item_key        => p_item_key
        ,p_update_object_version => p_update_object_version
        ,p_effective_date  => p_effective_date
        ,p_ignore_warnings => p_ignore_warnings
        ,p_validate => false);
   rollback to VALIDATE_TRANSACTION;
    p_result := null;
  exception
    when hr_utility.hr_error then
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      hr_message.provide_error;
      --result := fnd_message.get;
      p_result := hr_message.last_message_name;
      if p_result <> 'HR_7155_OBJECT_INVALID' and
         p_result <> 'HR_FATAL_OBJECT_ERROR' then
        p_result := hr_message.get_message_text;
      end if;
      rollback to VALIDATE_TRANSACTION;
    when others then
    hr_utility.set_location('EXCEPTION: '|| l_proc,560);
      p_result := sqlerrm;
      rollback to VALIDATE_TRANSACTION;
  end;
  hr_utility.set_location('Leaving: '|| l_proc,10);
end validate_transaction;
-- ----------------------------------------------------------------------------
-- |----------------------------< commit_transaction >------------------------|
-- ----------------------------------------------------------------------------
procedure commit_transaction
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result          out nocopy varchar2) is
  --
  l_error_text    varchar2(2000);
  l_sqlerrm       varchar2(2000);
  l_proc constant varchar2(100) := g_package || ' commit_transaction';
  --
  l_commit_error exception;
  l_merge_attachment_error exception;
  l_return_status varchar2(10);
  l_txn_id        number;

begin
hr_utility.set_location('Entering: '|| l_proc,5);

  if funmode = 'RUN' then
  hr_utility.trace('In(if funmode = RUN) '|| l_proc);


    -- new call to reset the apps context, if does not match
  -- the approving user context
   if g_debug then
       hr_utility.set_location('calling setRespondedUserCtx',10);
       hr_utility.set_location('itemtype:'||itemtype,11);
       hr_utility.set_location('itemkey:'||itemkey,12);
     end if;
   begin
     setRespondedUserCtx(itemtype,itemkey);
   exception
   when others then
      -- do nothing ??
       if g_debug then
        hr_utility.set_location('Error calling setRespondedUserCtx SQLERRM' ||' '||to_char(SQLCODE),20);
       end if;
      null;
    end;

  -- fix for bug 4454439
    begin
      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>itemtype
                                          ,p_item_key=>itemKey);
    exception
    when others then
      null;
    end;


    savepoint commit_transaction;
    begin
      -- process the transaction reporting warnings if they exist
      process_transaction
        (p_item_type       => itemtype
        ,p_item_key        => itemkey
        ,p_ignore_warnings => 'N');

      -- call SWI commit Transaction
      l_txn_id := get_transaction_id(itemtype,itemkey);

      if l_txn_id is not null then
          l_return_status :=hr_transaction_swi.commit_transaction
                          ( p_transaction_id  => l_txn_id );
          if l_return_status = 'E' then
            raise l_commit_error;
          end if;
      end if;
      IF l_txn_id is not null THEN
          hr_sflutil_ss.closeopensflnotification(l_txn_id);
      END IF;

      hr_util_misc_ss.saveAttachment(p_transaction_id => l_txn_id
                                       ,p_return_status => l_return_status);

      if l_return_status = 'E' then
            raise l_merge_attachment_error;
      end if;

    exception
      when l_commit_error then
       hr_utility.set_location('EXCEPTION: SWI COMMIT ERROR '|| l_proc,555);
       l_sqlerrm := sqlerrm;
       l_error_text := hr_utility.get_message;
       if l_error_text is null then
      	l_error_text := fnd_message.get;
       end if;
     wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'ERROR_MESSAGE_TEXT'
      ,avalue   => nvl(l_error_text,l_sqlerrm));

     wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'TRAN_SUBMIT'
      ,avalue   => 'E');
       raise;

       when l_merge_attachment_error then
       hr_utility.set_location('EXCEPTION: MERGE ATTCHMENT ERROR '|| l_proc,555);
       l_sqlerrm := sqlerrm;
       l_error_text := hr_utility.get_message;
       if l_error_text is null then
      	l_error_text := fnd_message.get;
       end if;
     wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'ERROR_MESSAGE_TEXT'
      ,avalue   => nvl(l_error_text,l_sqlerrm));

     wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'TRAN_SUBMIT'
      ,avalue   => 'E');
       raise;


      when others then
      hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        l_sqlerrm := sqlerrm;
        raise;
    end;
    -- transition workflow with SUCCESS
    result := 'COMPLETE:SUCCESS';
  elsif funmode = 'CANCEL' then
  hr_utility.trace('In(if funmode = CANCEL) '|| l_proc);
    result := 'COMPLETE:';
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,15);
exception
  when hr_utility.hr_error then
  hr_utility.set_location('EXCEPTION: '|| l_proc,560);
    -- rollback any work
    rollback to commit_transaction;
    --
    l_error_text := hr_utility.get_message;
    if l_error_text is null then
      l_error_text := fnd_message.get;
    end if;
    -- 1903606
    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'TRAN_SUBMIT'
      ,avalue   => 'E');

    -- set the ERROR_MESSAGE_TEXT
    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'ERROR_MESSAGE_TEXT'
      ,avalue   => nvl(l_error_text, l_sqlerrm));

   -- update the transaction table status
    hr_transaction_api.update_transaction(
      p_transaction_id => get_transaction_id
                          (p_item_type => itemtype
                          ,p_item_key => itemkey),
                          p_status => 'E');

    -- an application error or warning has been set
    result := 'COMPLETE:APPLICATION_ERROR';
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,565);
    -- rollback any work
    rollback to commit_transaction;
    -- 1903606
    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'TRAN_SUBMIT'
      ,avalue   => 'E');
    -- set the ERROR_MESSAGE_TEXT
    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'ERROR_MESSAGE_TEXT'
      ,avalue   => l_sqlerrm);
    -- update the transaction table status
       hr_transaction_api.update_transaction(
                    p_transaction_id => get_transaction_id
                          (p_item_type => itemtype
                          ,p_item_key => itemkey),
                          p_status => 'E');

    -- system error
    result := 'COMPLETE:SYSTEM_ERROR';
end commit_transaction;

-- ----------------------------------------------------------------------------
-- |---------------------< commit_approval_transaction >----------------------|
-- ----------------------------------------------------------------------------
procedure commit_approval_transaction
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result          out nocopy varchar2) is
  l_proc constant varchar2(100) := g_package || ' commit_approval_transaction';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  if funmode = 'RUN' then
    savepoint commit_approval_transaction;
    -- process the transaction reporting warnings if they exist
    process_transaction
      (p_item_type       => itemtype
      ,p_item_key        => itemkey
      ,p_ignore_warnings => 'Y');
    -- transition workflow with SUCCESS
    result := 'SUCCESS';
  elsif funmode = 'CANCEL' then
    null;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,10);
exception
  when others then
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    -- rollback any work
    rollback to commit_approval_transaction;
    -- system error
    raise;
end commit_approval_transaction;
-- ----------------------------------------------------------------------------
-- |-----------------------------< retry_transaction >------------------------|
-- ----------------------------------------------------------------------------
procedure retry_transaction
  (p_item_type in varchar2
  ,p_item_key  in varchar2
  ,p_actid     in number) is
  l_proc constant varchar2(100) := g_package || ' retry_transaction';

begin
hr_utility.set_location('Entering: '|| l_proc,5);
  savepoint retry_transaction;
  -- process the transaction ignoring warnings if they exist
  process_transaction
    (p_item_type       => p_item_type
    ,p_item_key        => p_item_key
    ,p_ignore_warnings => 'Y');
  -- Complete the activity with SUCCESS
  hr_workflow_utility.workflow_transition
    (p_item_type    => p_item_type
    ,p_item_key     => p_item_key
    ,p_actid        => p_actid
    ,p_result       => 'SUCCESS');
  --wf_engine.completeactivity
  --  (itemtype => p_item_type
  --  ,itemkey  => p_item_key
  --  ,activity => '#'||p_actid
  --  ,result   => 'SUCCESS');
  -- commit the transaction
  -- commit;
   hr_utility.set_location('Leaving: '|| l_proc,10);
exception
  when hr_utility.hr_error then
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    -- rollback any work
    rollback to retry_transaction;
    -- an application error has been set
    -- redisplay the errors
    raise;
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,560);
    -- rollback any work
    rollback to retry_transaction;
    -- system error
    raise;
end retry_transaction;

--
/*------------------------------------------------------------------------------
|
|       Name           : save_transaction_step
|
|       Purpose        :
|
|       Saves the records into Transaction Tables.
|
+-----------------------------------------------------------------------------*/
PROCEDURE save_transaction_step
		(p_item_type IN VARCHAR2
		,p_item_key IN VARCHAR2
                ,p_actid IN NUMBER
                ,p_login_person_id IN NUMBER
                ,p_transaction_step_id IN OUT NOCOPY NUMBER
		,p_api_name IN VARCHAR2  default null
		,p_api_display_name IN VARCHAR2 DEFAULT NULL
                ,p_transaction_data IN TRANSACTION_TABLE
                ,p_product_code                   in varchar2 default null
                ,p_url                          in varchar2 default null
                ,p_status                       in varchar2 default null
                ,p_section_display_name          in varchar2 default null
                ,p_function_id                  in number default null
                ,p_transaction_ref_table        in varchar2 default null
                ,p_transaction_ref_id           in number default null
                ,p_transaction_type             in varchar2 default null
                ,p_assignment_id                in number default null
                ,p_api_addtnl_info              in varchar2 default null
                ,p_selected_person_id           in number default null
                ,p_transaction_effective_date       in date default null
                ,p_process_name                 in varchar2 default null
                ,p_plan_id                      in number default null
                ,p_rptg_grp_id                  in number default null
                ,p_effective_date_option        in varchar2 default null
) AS


cursor get_trans_id ( p_trans_step_id HR_API_TRANSACTION_STEPS.transaction_step_id%TYPE) is
        select transaction_id from hr_api_transaction_steps
        where transaction_step_id = p_trans_step_id;

l_count           INTEGER := 0;
l_result          VARCHAR2(100);
l_trs_ovn         hr_api_transaction_steps.object_version_number%TYPE;
l_original_date   date;  --ns
l_original_number number; --ns
l_transaction_state varchar2(10) := hr_api.g_varchar2; --ns
l_date            date;
l_value_error     BOOLEAN := false;
l_proc constant varchar2(100) := g_package || ' save_transaction_step';

l_function_id           hr_api_transactions.function_id%TYPE;
ln_selected_person_id   hr_api_transactions.selected_person_id%TYPE;
lv_process_name         hr_api_transactions.process_name%TYPE;
lv_status               hr_api_transactions.status%TYPE;
lv_section_display_name hr_api_transactions.section_display_name%TYPE;
ln_assignment_id        hr_api_transactions.assignment_id%TYPE;
ld_trans_effec_date     hr_api_transactions.transaction_effective_date%TYPE;
lv_transaction_type     hr_api_transactions.transaction_type%TYPE;
ln_transaction_id       hr_api_transaction_steps.transaction_id%TYPE;

BEGIN

hr_utility.set_location('Entering: '|| l_proc,5);
    -- populate the values in case of null before passing it to API.
    -- CompWorkBench

    populate_null_values
    (p_item_type
    ,p_item_key
    ,p_function_id
    ,p_selected_person_id
    ,p_process_name
    ,p_status
    ,p_section_display_name
    ,p_assignment_id
    ,p_transaction_effective_date
    ,p_transaction_type
    ,l_function_id
    ,ln_selected_person_id
    ,lv_process_name
    ,lv_status
    ,lv_section_display_name
    ,ln_assignment_id
    ,ld_trans_effec_date
    ,lv_transaction_type
    );

  -- Check to see if Transaction Step exists
  IF p_transaction_step_id IS NULL THEN
    -- Create Transaction
    -- Following procedure will set item attribute 'TRANSACTION_ID'.
    -- Later on you can access the value of TRANSACTION_ID by
    -- calling HR_TRANSACTION_SS.GET_TRANSACTION_ID

    start_transaction
      (itemtype => p_item_type
      ,itemkey => p_item_key
      ,actid => p_actid
      ,funmode => 'RUN'
      ,p_login_person_id => p_login_person_id
      ,result => l_result
      ,p_product_code   =>  p_product_code
      ,p_url   => p_url
      ,p_status => lv_status
      ,p_section_display_name  => lv_section_display_name
      ,p_function_id    => l_function_id
      ,p_transaction_ref_table  => 'HR_API_TRANSACTIONS'
      ,p_transaction_ref_id  => p_transaction_ref_id
      ,p_transaction_type   =>   lv_transaction_type
      ,p_assignment_id  => ln_assignment_id
      ,p_api_addtnl_info => p_api_addtnl_info
      ,p_selected_person_id  => ln_selected_person_id
      ,p_transaction_effective_date => ld_trans_effec_date
      ,p_process_name => lv_process_name
      ,p_plan_id=> p_plan_id
      ,p_rptg_grp_id=> p_rptg_grp_id
      ,p_effective_date_option=> p_effective_date_option
    );
    -- Create a Transaction Step for this Transaction.
    hr_transaction_api.create_transaction_step
      (p_validate => false
      ,p_creator_person_id => p_login_person_id
      ,p_transaction_id => get_transaction_id
          (p_item_type => p_item_type
          ,p_item_key => p_item_key)
      ,p_api_name => p_api_name
      ,p_api_display_name => p_api_display_name
      ,p_item_type => p_item_type
      ,p_item_key => p_item_key
      ,p_activity_id => p_actid
      ,p_transaction_step_id => p_transaction_step_id
      ,p_object_version_number => l_trs_ovn);
  END IF;

  hr_transaction_api.g_update_flag := 'N';
  l_count := p_transaction_data.COUNT;
  hr_utility.trace('In(for I in csr_trs loop)'||l_proc);
  FOR i IN 1..l_count LOOP
    IF p_transaction_data(i).param_data_type = 'DATE' THEN
      --ensure that the effective date is in the correct format
      BEGIN
    	l_date := trunc(to_date(p_transaction_data(i).param_value,
                  g_date_format));
    	l_original_date := trunc(to_date(p_transaction_data(i).param_original_value,
                           g_date_format)); --ns
      EXCEPTION
        WHEN OTHERS THEN
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      	-- the date check failed therefore we must report the error
      	-- and reset to the original value
        l_value_error := true;
        fnd_message.set_name('PER', 'HR_51778_WEB_KIOSK_INV_EDATE');
     	l_date := trunc(sysdate);
      END;
      hr_transaction_api.set_date_value
	(p_transaction_step_id  => p_transaction_step_id
	,p_person_id            => p_login_person_id
	,p_name                 => p_transaction_data(i).param_name
	,p_value                => l_date
        ,p_original_value       => l_original_date);

      IF l_value_error THEN
	RAISE hr_utility.hr_error;
      END IF;
    ELSIF p_transaction_data(i).param_data_type = 'NUMBER' THEN
      BEGIN
        --ns start
        IF p_transaction_data(i).param_original_value is NULL   THEN
           l_original_number := null;
        ELSE
           l_original_number := to_number(p_transaction_data(i).param_original_value );
        END IF;
        --ns end
        -----------------------------------------------------------------------
        -- 11/07/00 Need to test that if the param_value is null or not.  If
        -- it is null, don't use the to_number function to try to convert a null
        -- to a number value.  Otherwise, you'll get ORA-06502 PL/SQL numeric
        -- or value error.
        -----------------------------------------------------------------------
        IF p_transaction_data(i).param_value is NULL
        THEN
           hr_transaction_api.set_number_value
             (p_transaction_step_id => p_transaction_step_id
             ,p_person_id           => p_login_person_id
             ,p_name                => p_transaction_data(i).param_name
             ,p_original_value      => l_original_number); --ns
        ELSE
	   hr_transaction_api.set_number_value
	     (p_transaction_step_id => p_transaction_step_id
	     ,p_person_id           => p_login_person_id
	     ,p_name                => p_transaction_data(i).param_name
	     ,p_value               => to_number(p_transaction_data(i).param_value)
             ,p_original_value      => l_original_number); --ns
        END IF;
      exception
        when others then
        hr_utility.set_location('EXCEPTION: '|| l_proc,560);
         --SQLERRM
         RAISE hr_utility.hr_error;
      END;
    ELSIF p_transaction_data(i).param_data_type = 'VARCHAR2' THEN
      BEGIN
        hr_transaction_api.set_varchar2_value
	(p_transaction_step_id => p_transaction_step_id
	,p_person_id           => p_login_person_id
	,p_name                => p_transaction_data(i).param_name
	,p_value               => p_transaction_data(i).param_value
        ,p_original_value      => p_transaction_data(i).param_original_value); --ns
      exception
	when others then
	hr_utility.set_location('EXCEPTION: '|| l_proc,565);
          --SQLERRM
          RAISE hr_utility.hr_error;
      END;
    END IF;
  END LOOP;

  if (hr_transaction_api.g_update_flag = 'Y') then
	l_transaction_state := 'W';
        hr_transaction_api.g_update_flag := 'N';
  end if;

  -- --------------------------------------------------------------------
  -- for each of the transaction values which need to be either created or
  -- updated set the transaction value
  -- --------------------------------------------------------------------
  -- Find out how many variables we have to set

  IF p_transaction_step_id IS NOT NULL THEN
  hr_utility.trace('In ( IF p_transaction_step_id IS NOT NULL ) '|| l_proc);

        OPEN get_trans_id(p_transaction_step_id);
        FETCH get_trans_id into ln_transaction_id;
        CLOSE get_trans_id;

        IF ln_transaction_id IS NOT NULL THEN
        hr_utility.trace('In ( I IF ln_transaction_id IS NOT NULL ) '|| l_proc);
           Begin
            if ( wf_engine.GetItemAttrText(p_item_type ,p_item_key ,'HR_APPROVAL_PRC_VERSION') = 'V5' ) then
                lv_status := hr_api.g_varchar2; -- so that the original value is picked from txn table;
            end if;
           Exception
              when Others then -- wf attribute not found
              	hr_utility.set_location('EXCEPTION: '|| l_proc,570);
                   null;
           End;

            hr_transaction_api.update_transaction
            (p_transaction_id             => ln_transaction_id
            ,p_status                     => lv_status
            ,p_transaction_state          => l_transaction_state
            ,p_transaction_effective_date => ld_trans_effec_date
            );
        END IF;
  END IF;

hr_utility.set_location('Leaving: '|| l_proc,25);
  EXCEPTION
    WHEN OTHERS THEN
    	hr_utility.set_location('EXCEPTION: '|| l_proc,575);
      --SQLERRM
      raise;
END save_transaction_step;

	/*
       ||=======================================================================
       || FUNCTION    : get_activity_trans_step_id
       || DESCRIPTION : This will return the transaction step id for a given
       ||               activity name and from possible 'active' transaction
       ||               steps.
       ||=======================================================================
       */
	FUNCTION get_activity_trans_step_id
		 (p_activity_name IN
			wf_item_activity_statuses_v.activity_name%TYPE
  		 ,p_trans_step_id_tbl  IN hr_util_web.g_varchar2_tab_type)
		 RETURN hr_api_transaction_steps.transaction_step_id%TYPE IS
  	ln_transaction_step_id
	  hr_api_transaction_steps.transaction_step_id%TYPE;
	li_step_count INTEGER;
	l_proc constant varchar2(100) := g_package || ' get_activity_trans_step_id';
	BEGIN

    hr_utility.set_location('Entering: '|| l_proc,5);
		li_step_count := p_trans_step_id_tbl.COUNT;
		    hr_utility.trace('Going to (	FOR i IN 0..li_step_count LOOP): '|| l_proc);
		FOR i IN 0..li_step_count LOOP
			IF p_activity_name =
			hr_transaction_api.get_varchar2_value
			(p_transaction_step_id => p_trans_step_id_tbl(i)
			,p_name => 'p_activity_name')
			THEN
				RETURN p_trans_step_id_tbl(i);
			END IF;
		END LOOP;
hr_utility.set_location('Leaving: '|| l_proc,15);


		RETURN NULL;


		EXCEPTION
		WHEN OTHERS		THEN
			hr_utility.set_location('EXCEPTION: '|| l_proc,555);
		  --SQLERRM
                  raise;
	END get_activity_trans_step_id;

 /* FUNCTION check_txn_step_exists
 -- function to check whether data exists in txn steps
 */
 FUNCTION check_txn_step_exists (
    p_item_type IN     wf_items.item_type%TYPE,
     p_item_key IN      wf_items.item_key%TYPE,
     p_actid IN        NUMBER  )
   RETURN BOOLEAN
   IS

   ln_transaction_id    NUMBER ;
   ltt_trans_step_ids  hr_util_web.g_varchar2_tab_type;
   ltt_trans_obj_vers_num  hr_util_web.g_varchar2_tab_type;
   ln_trans_step_rows  number ;
	l_proc constant varchar2(100) := g_package || ' check_txn_step_exists';
   BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
     ln_transaction_id := get_transaction_id
                             (p_Item_Type   => p_item_type
                ,             p_Item_Key    => p_item_key);

      IF ln_transaction_id IS NOT NULL
      THEN
             hr_utility.trace(' In(IF ln_transaction_id IS NOT NULL)'|| l_proc);
        hr_transaction_api.get_transaction_step_info
                   (p_Item_Type   => p_item_type,
                    p_Item_Key    => p_item_key,
                    p_activity_id =>p_actid,
                    p_transaction_step_id => ltt_trans_step_ids,
                    p_object_version_number => ltt_trans_obj_vers_num,
                    p_rows                  => ln_trans_step_rows);

        -- if no transaction steps are found , return
        IF ln_trans_step_rows >= 1
                THEN
                       hr_utility.trace(' In( IF ln_trans_step_rows >= 1)'|| l_proc);
                       hr_utility.set_location('Leaving: '|| l_proc,20);
          return TRUE ;
        ELSE
                       hr_utility.set_location('Leaving: '|| l_proc,20);
          return FALSE ;
        END IF ;

      END IF ;
                       hr_utility.set_location('Leaving: '|| l_proc,20);
      return FALSE ;
   END ;



-- ---------------------------------------------------------
-- Procedure to delete  a transaction step by p_activity_name
-- --------------------------------------------------------------
PROCEDURE delete_trn_step_by_act_name(
    p_item_type     IN varchar2,
    p_item_key      IN varchar2 ,
    p_actid         IN varchar2 ,
    p_activity_name IN varchar2,
    p_login_person_id IN varchar2 )
IS
    ln_ovn NUMBER ;
    ln_transaction_step_id NUMBER;
    ln_transaction_id      hr_api_transactions.transaction_id%TYPE;
    ltt_trans_step_ids     hr_util_web.g_varchar2_tab_type;
    ltt_trans_obj_vers_num hr_util_web.g_varchar2_tab_type;
    ln_trans_step_rows     NUMBER  ;
    ln_value_id            NUMBER ;
l_proc constant varchar2(100) := g_package || ' delete_trn_step_by_act_name';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
  IF p_activity_name is not null THEN
  hr_utility.trace('In(IF p_activity_name is not null) '|| l_proc);

    ln_transaction_id := get_transaction_id
                           (p_Item_Type   => p_item_type,
                            p_Item_Key    => p_item_key);
    IF ln_transaction_id IS NOT NULL
      THEN
      hr_utility.trace('In( IF ln_transaction_id IS NOT NULL) '|| l_proc);
      hr_transaction_api.get_transaction_step_info
                   (p_Item_Type   => p_item_type,
                    p_Item_Key    => p_item_key,
                    p_activity_id =>p_actid,
                    p_transaction_step_id => ltt_trans_step_ids,
                    p_object_version_number => ltt_trans_obj_vers_num,
                    p_rows                  => ln_trans_step_rows);


      -- if no transaction steps are found , return
      IF ln_trans_step_rows > 0
            THEN
            hr_utility.trace('In(  IF ln_trans_step_rows > 0) '|| l_proc);
        ln_transaction_step_id  :=
          hr_transaction_ss.get_activity_trans_step_id
          (p_activity_name =>p_activity_name,
           p_trans_step_id_tbl => ltt_trans_step_ids);
        delete_transaction_step(
          p_transaction_step_id => ln_transaction_step_id,
          p_login_person_id => p_login_person_id);
      END IF ;
    END IF;
  END IF;
hr_utility.set_location('Leaving: '|| l_proc,25);

EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;
END delete_trn_step_by_act_name;

-- -------------------------------------------------------------------------
-- delete_transaction_steps is used by FWK java class. The parameters are
-- defined as varchar2. Please do not change the parameter data type.
-- -------------------------------------------------------------------------

PROCEDURE delete_transaction_steps(
  p_item_type IN     varchar2,
  p_item_key  IN     varchar2,
  p_actid     IN     varchar2 default null,
  p_login_person_id  IN varchar2) IS

  l_trans_step_ids hr_util_web.g_varchar2_tab_type;
  l_trans_obj_vers_num hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows NUMBER;
l_proc constant varchar2(100) := g_package || ' delete_transaction_steps';

BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
  if p_actid IS NULL then
    hr_transaction_api.get_transaction_step_info (
    p_Item_Type             => p_item_type,
    p_Item_Key              => p_item_key,
    p_transaction_step_id   => l_trans_step_ids,
    p_object_version_number => l_trans_obj_vers_num,
    p_rows                  => l_trans_step_rows
    );
  else
    hr_transaction_api.get_transaction_step_info (
    p_Item_Type             => p_item_type,
    p_Item_Key              => p_item_key,
    p_activity_id           => to_number(p_actid),
    p_transaction_step_id   => l_trans_step_ids,
    p_object_version_number => l_trans_obj_vers_num,
    p_rows                  => l_trans_step_rows
    );
  end if;
hr_utility.trace('Going to ( FOR i IN 0..(l_trans_step_rows - 1) LOOP) '|| l_proc);
  FOR i IN 0..(l_trans_step_rows - 1) LOOP
    delete_transaction_step
      (p_transaction_step_id => l_trans_step_ids(i)
      ,p_object_version_number => l_trans_obj_vers_num(i)
      ,p_login_person_id => p_login_person_id);
  END LOOP;

  --hr_utility.set_message(801, 'HR_51750_WEB_TRANSAC_STARTED');
  --hr_utility.raise_error;
hr_utility.set_location('Leaving: '|| l_proc,15);

EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;

END delete_transaction_steps;

-- -------------------------------------------------------------------------
-- delete_transaction_step is used by FWK java class. The parameters are
-- defined as varchar2. Please do not change the parameter data type.
-- -------------------------------------------------------------------------

PROCEDURE delete_transaction_step(
  p_transaction_step_id IN varchar2,
  p_object_version_number IN varchar2 default null,
  p_login_person_id  IN varchar2) IS

  l_object_version_number number;
l_proc constant varchar2(100) := g_package || ' delete_transaction_step';

----- bug 5102128
  L_DEL_PHONE_TYPE varchar2(100):=null;
  L_DEL_PHONE_NUMBER varchar2(100):=null;
  L_DEL_PHONE_ID  number;
----- bug 5102128


BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
  if p_transaction_step_id is not null then
  hr_utility.trace('In (if p_transaction_step_id is not null ) '|| l_proc);
    if p_object_version_number is null then
      hr_utility.trace('In (if p_object_version_number is null ) '|| l_proc);
      l_object_version_number :=
        get_transaction_step_ovn(to_number(p_transaction_step_id));
    else
    hr_utility.trace('In else of (if p_object_version_number is null ) '|| l_proc);
      l_object_version_number := to_number(p_object_version_number);
    end if;

----- bug 5102128
       L_DEL_PHONE_NUMBER := hr_transaction_api.get_varchar2_value
			(p_transaction_step_id => to_number(p_transaction_step_id)
			,p_name => 'P_PHONE_NUMBER');
       L_DEL_PHONE_TYPE := hr_transaction_api.get_varchar2_value
			(p_transaction_step_id => to_number(p_transaction_step_id)
			,p_name => 'P_PHONE_TYPE');
       L_DEL_PHONE_ID := hr_transaction_api.get_number_value
			(p_transaction_step_id => to_number(p_transaction_step_id)
			,p_name => 'P_PHONE_ID');

    if L_DEL_PHONE_ID is not null and L_DEL_PHONE_TYPE = 'DELETE' and L_DEL_PHONE_NUMBER = 'DELETE_NUMBER' then
       null;
    else
----- bug 5102128

    hr_transaction_api.delete_transaction_step
      (p_validate => FALSE
      ,p_transaction_step_id => to_number(p_transaction_step_id)
      ,p_object_version_number => l_object_version_number
      ,p_person_id => to_number(p_login_person_id));
----- bug 5102128
  end if;
----- bug 5102128
  end if;
hr_utility.set_location('Leaving: '|| l_proc,20);

EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;

END delete_transaction_step;

function get_transaction_step_ovn(
  p_transaction_step_id in number)
return number is

  cursor csr_hats is
    select hats.object_version_number
    from   hr_api_transaction_steps hats
    where  hats.transaction_step_id = p_transaction_step_id;

  l_ovb number;
l_proc constant varchar2(100) := g_package || ' get_transaction_step_ovn';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  open csr_hats;
  fetch csr_hats into l_ovb;
  if csr_hats%notfound then
    l_ovb := null;
  end if;
  close csr_hats;
hr_utility.set_location('Leaving: '|| l_proc,10);
  return l_ovb;

EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;

end get_transaction_step_ovn;

procedure set_transaction_value
(p_transaction_step_id in varchar2
,p_login_person_id     in varchar2
,p_datatype            in varchar2
,p_name                in varchar2
,p_value               in varchar2) is

 l_varchar2_value      varchar2(2000);
 l_number_value        number;
 l_date                date;
l_proc constant varchar2(100) := g_package || ' set_transaction_value';
begin
hr_utility.set_location('Entering: '|| l_proc,5);
  if (p_datatype = 'VARCHAR2') then
  hr_utility.trace('In (if (p_datatype = VARCHAR2)) '|| l_proc);
    hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_login_person_id
    ,p_name                => p_name
    ,p_value               => p_value);
  elsif p_datatype = 'NUMBER' then
  hr_utility.trace('In ( elsif p_datatype = NUMBER) '|| l_proc);
    hr_transaction_api.set_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_login_person_id
    ,p_name                => p_name
    ,p_value               => to_number(p_value));
  elsif p_datatype = 'DATE' then
   hr_utility.trace('In ( elsif p_datatype = DATE) '|| l_proc);
    hr_transaction_api.set_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_login_person_id
    ,p_name                => p_name
    ,p_value               => to_date(p_value, g_date_format));
  else
  hr_utility.trace('In else of (if (p_datatype = VARCHAR2)) '|| l_proc);
    --raise datetype error;
    null;
  end if;
hr_utility.set_location('Leaving: '|| l_proc,15);
EXCEPTION
  WHEN OTHERS THEN

hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;
end set_transaction_value;

procedure create_transaction_step
(p_item_type      in varchar2
,p_item_key       in varchar2
,p_actid          in varchar2
,p_login_person_id  in  varchar2
,p_api_name       in varchar2
,p_transaction_step_id out nocopy varchar2
,p_object_version_number out nocopy varchar2) is

  l_transaction_id number;
  l_result         varchar2(100);
  l_trns_object_version_number number;
  l_proc constant varchar2(100) := g_package || ' create_transaction_step';

begin
hr_utility.set_location('Entering: '|| l_proc,5);
  l_transaction_id := get_transaction_id
                       (p_item_type => p_item_type
                        ,p_item_key => p_item_key);
  if l_transaction_id is null then
    start_transaction
      (itemtype    =>    p_item_type
      ,itemkey     =>    p_item_key
      ,actid       =>    to_number(p_actid)
      ,funmode     =>    'RUN'
      ,p_login_person_id => to_number(p_login_person_id)
      ,result      =>    l_result);
    --
    l_transaction_id:= get_transaction_id
                         (p_item_type   =>   p_item_type
                         ,p_item_key    =>   p_item_key);
  end if;

  hr_transaction_api.create_transaction_step
      (p_validate              => false
      ,p_creator_person_id     => to_number(p_login_person_id)
      ,p_transaction_id        => l_transaction_id
      ,p_api_name              => p_api_name
      ,p_item_type             => p_item_type
      ,p_item_key              => p_item_key
      ,p_activity_id           => to_number(p_actid)
      ,p_transaction_step_id   => p_transaction_step_id
      ,p_object_version_number => l_trns_object_version_number);
hr_utility.set_location('Leaving: '|| l_proc,10);
end create_transaction_step;

--
-- --------------------<get_review_regions>----------------------------- --
-- Procedure to get the review region item names, step ids and activity ids of the
-- update regions involved in a current transaction.
-- This procedure return one string which will in turn gets parsed by the
-- jdbc code that is calling this.
-- ---------------------------------------------------------------------- --
--
procedure get_review_regions
(p_item_key        IN  VARCHAR2
,p_item_Type       IN  VARCHAR2
,p_review_regions  OUT NOCOPY VARCHAR2
,p_status          OUT NOCOPY VARCHAR2) IS

  l_tmp_proc_call    varchar2(32000);
  l_tmp_proc_call1   varchar2(32000);
  l_transaction_step_id   hr_api_transaction_steps.transaction_step_id%type;
  l_delimiter        varchar2(3) := '|!|';
  l_start           number;
  l_start1          number;
  l_pos             number;
  l_pos1            number;
  l_count           number := 0;
  l_count1          number;
  l_index           number;
  l_loop_count      number;
  l_last_rec        boolean default TRUE;
  l_review_proc_list VARCHAR2(32000);

  l_tx_step_count   number := 0;
  l_proc constant varchar2(100) := g_package || ' get_review_regions';
  -- Local cursor definations
  -- csr_wf_active_item Returns the item key of any process which
  -- is currently active with the name of p_process and belonging to
  -- the given person id
 cursor csr_hatv  (
	p_item_key  in hr_api_transaction_steps.item_key%type
	,p_item_Type  in hr_api_transaction_steps.item_Type%type
        ,p_name            in hr_api_transaction_values.name%type
                  ) is
    select val.varchar2_value, val.transaction_step_id
    from  hr_api_transaction_values val, hr_api_transaction_steps step
    where step.item_type = p_item_type
      and step.item_key  = p_item_key
      and step.transaction_step_id = val.transaction_step_id
      and val.name = p_name
      and val.varchar2_value Is Not Null
    order by step.processing_order, step.transaction_step_id asc;

 cursor csr_act  (
        p_transaction_step_id
                           in hr_api_transaction_steps.transaction_step_id%type
        ,p_name            in hr_api_transaction_values.name%type
                  ) is
   select varchar2_value
   from   hr_api_transaction_values
   where  transaction_step_id =  p_transaction_step_id
   and name = p_name
   and varchar2_value Is Not Null;

 begin
 hr_utility.set_location('Entering: '|| l_proc,5);
   -- to hold error message if raised;
   p_status := 'SUCCESS';

   select count(transaction_step_id)
     into l_tx_step_count
     from  hr_api_transaction_steps
    where  item_key = p_item_key
      and  item_type = p_item_type;

   if l_tx_step_count <> 0 then -- user has changed data in one of the previous pages
   hr_utility.trace('In ( if l_tx_step_count <> 0 ) '|| l_proc);

      -- Initialize Table index to 0
      l_index := 0;
   hr_utility.trace('Going to (  for I in csr_hatv  ( p_item_key  => p_item_key ) '|| l_proc);
      for I in csr_hatv  ( p_item_key  => p_item_key
                            ,p_item_type => p_item_type
                            ,p_name => 'P_REVIEW_PROC_CALL'
                            ) loop
           l_tmp_proc_call := I.varchar2_value;
           l_transaction_step_id := I.transaction_step_id;

        open  csr_act  (p_transaction_step_id => l_transaction_step_id
                            ,p_name => 'P_REVIEW_ACTID'
                            );
        fetch csr_act into l_tmp_proc_call1;
          IF csr_act%NOTFOUND THEN
            l_tmp_proc_call1 := NULL;
          END IF;
        close csr_act;
         -- Parse the string based on |!|
         l_start := 1;
         l_start1 := 1;
         l_pos := instr(l_tmp_proc_call, l_delimiter,l_start, 1);
         l_pos1 := instr(l_tmp_proc_call1, l_delimiter,l_start1, 1);
         -- Go in into For loop only if there is delimiter
         if l_pos <> 0 then
             l_count := length(l_tmp_proc_call);
             l_count1 := length(l_tmp_proc_call1);
             if l_count <> 0 then
                 FOR i IN 1..l_count LOOP
                    -- Find the delimter and its position
                    l_pos := instr(l_tmp_proc_call, l_delimiter,l_start, 1);
                    l_pos1:= instr(l_tmp_proc_call1, l_delimiter,l_start1, 1);
                    if l_pos <> 0 then
      --  Now We need to Parse for reviewRegionItemName|!|reviewRegionItemName...
                       if length(l_review_proc_list) is null then
                          l_review_proc_list :=  Rtrim(Ltrim(substr( l_tmp_proc_call, l_start, l_pos - l_start)))||'~'||to_char(l_transaction_step_id)||'~'||Rtrim(Ltrim(substr( l_tmp_proc_call1, l_start1, l_pos1 - l_start1)));
                       else
                          l_review_proc_list :=  l_review_proc_list||'?'||Rtrim(Ltrim(substr( l_tmp_proc_call, l_start, l_pos - l_start)))||'~'||to_char(l_transaction_step_id)||'~'||Rtrim(Ltrim(substr( l_tmp_proc_call1, l_start1, l_pos1 - l_start1)));
                       end if;
                       l_index := l_index + 1;
                       -- increment the start location
                       l_start := l_pos + 3;
                       l_start1 := l_pos1 + 3;
                    else
                        --- exit loop as there are no more delimter matches
       --  Now We need to Parse for Last reviewRegionItemName
                        if length(l_review_proc_list) is null then
                          l_review_proc_list := Rtrim(Ltrim(substr( l_tmp_proc_call, l_start, l_count)))||'~'||to_char(l_transaction_step_id)||'~'||Rtrim(Ltrim(substr( l_tmp_proc_call1, l_start1,  l_count1)));
                        else
                          l_review_proc_list := l_review_proc_list||'?'||Rtrim(Ltrim(substr( l_tmp_proc_call, l_start, l_count)))||'~'||to_char(l_transaction_step_id)||'~'||Rtrim(Ltrim(substr( l_tmp_proc_call1, l_start1,  l_count1)));
                        end if;
                        l_index := l_index + 1;
                        -- increment the start location
                        l_start := l_pos + 3;
                        l_start1 := l_pos1 + 3;
                        exit;
                    end if;
                  END LOOP;
            end if;
         else
            if length(l_review_proc_list) is null then
               l_review_proc_list := l_tmp_proc_call||'~'||to_char(l_transaction_step_id)||'~'||l_tmp_proc_call1;
            else
               l_review_proc_list := l_review_proc_list||'?'||l_tmp_proc_call||'~'||to_char(l_transaction_step_id)||'~'||l_tmp_proc_call1;
            end if;
            l_index := l_index + 1;
         end if;
      end loop;

      if l_review_proc_list is not null then
        p_review_regions := l_review_proc_list;
      else
        p_review_regions := 'NO_REVIEW_PROC_CALL';  -- Update page has not stored the P_REVIEW_PROC_CALL or P_REVIEW_ACTID.
      end if;

   else
      p_review_regions := 'NO_CHANGES';
   end if;

   hr_utility.set_location('Leaving: '|| l_proc,20);

 --
    EXCEPTION WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    p_status := g_package||'get_review_regions Error :'||substr(SQLERRM,1,1000);
    -- handle this exception and raise it to jdbc call
end; -- get_review_regions

procedure get_transaction_data (
	 p_transaction_step_id  IN VARCHAR2
	,p_bulk_fetch_limit     IN NUMBER DEFAULT 200
	,p_transaction_data     OUT nocopy transaction_data) is

  cursor transaction_data_row is
    select NAME,
           VARCHAR2_VALUE,
           NUMBER_VALUE,
           DATE_VALUE
    from   hr_api_transaction_values
    where  transaction_step_id = p_transaction_step_id
    order by transaction_value_id;

  i integer := 0;
  l_proc constant varchar2(100) := g_package || ' get_transaction_data';

begin
 hr_utility.set_location('Entering: '|| l_proc,5);
  p_transaction_data := null;
  open transaction_data_row;
  if g_oracle_db_version >= 9 then
   hr_utility.trace('In(if g_oracle_db_version >= 9 ): '|| l_proc);
   loop
    fetch transaction_data_row bulk collect
    into p_transaction_data.name,
         p_transaction_data.VARCHAR2_VALUE,
         p_transaction_data.NUMBER_VALUE,
         p_transaction_data.DATE_VALUE
    limit p_bulk_fetch_limit;
    exit when transaction_data_row%notfound;
   end loop;
  else
     hr_utility.trace('In else of (if g_oracle_db_version >= 9 ): '|| l_proc);
   loop
      i := i + 1;
      fetch transaction_data_row
      into p_transaction_data.name(i),
           p_transaction_data.VARCHAR2_VALUE(i),
           p_transaction_data.NUMBER_VALUE(i),
           p_transaction_data.DATE_VALUE(i);
      exit when transaction_data_row%notfound;
    end loop;
  end if;
  close transaction_data_row;
  hr_utility.set_location('Leaving: '|| l_proc,15);
end get_transaction_data;

  procedure set_transaction_approved
 (itemtype in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funmode      in varchar2,
  result       out nocopy varchar2 ) is
ln_transaction_id hr_api_transactions.transaction_id%TYPE;
l_proc constant varchar2(100) := g_package || ' set_transaction_approved';
begin
hr_utility.set_location('Entering: '|| l_proc,5);

  if ( funmode = 'RUN' ) then
    ln_transaction_id := get_transaction_id(itemtype, itemkey);
    set_save_for_later_status
      (p_item_type => itemtype,
       p_item_key => itemkey,
       p_status => 'AC',
       p_transaction_id => ln_transaction_id);
    result := 'COMPLETE:SUCCESS';
  elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
hr_utility.set_location('Leaving: '|| l_proc,10);
end set_transaction_approved;


end hr_transaction_ss;

/
