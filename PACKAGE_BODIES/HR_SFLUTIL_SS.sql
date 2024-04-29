--------------------------------------------------------
--  DDL for Package Body HR_SFLUTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SFLUTIL_SS" AS
/* $Header: hrsflutlss.pkb 120.8.12000000.5 2007/09/27 10:47:14 dbatra ship $ */

-- Package Variables
--
g_package  constant varchar2(14) := 'hr_sflutil_ss.';
g_debug boolean ;

--5672792
function isCurrentTxnSFLClose ( p_transaction_id hr_api_transactions.transaction_id%type )
return varchar2
is
  result varchar2(10) := null;
  c_proc constant varchar2(50) :='isCurrentTxnSFLClose';
  l_temp boolean;
  p_item_type hr_api_transactions.item_type%type;
  p_item_key hr_api_transactions.item_key%type;
begin
  --hr_utility.trace_on(null,'Oracle');
  hr_utility.set_location('p_transaction_id : ' || p_transaction_id , 0 );
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

   begin
    -- check if there are any SFL transaction associated
   if g_debug then
     hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 2);
   end if;

   select item_type, item_key
   into p_item_type,p_item_key
   from wf_items
   where user_key=to_char(p_transaction_id)
   and rownum<2;
   if g_debug then
     hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 3);
   end if;
   exception
   when others then
--   null;
   result := 'FALSE';
   --hr_utility.trace_off();
   return result;
   end;

  if HR_SFLUTIL_SS.OpenNotificationsExist(wf_engine.getitemattrnumber(p_item_type,p_item_key,'HR_LAST_SFL_NTF_ID_ATTR',true))=false then
    if g_debug then
     hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 4);
    end if;
    result := 'TRUE';
  else
    if g_debug then
     hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 5);
    end if;
    result := 'FALSE';
  end if;
  if g_debug then
     hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 6);
  end if;
  return result;
  exception
  when others then
    if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 7);
    end if;
    raise;
  --hr_utility.trace_off();
end isCurrentTxnSFLClose;
--5672792


procedure sflBlock
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2)
  is
    --local variables
    c_proc constant varchar2(8) :='sflBlock';
  begin
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 10);
    end if;
    -- Do nothing in cancel or timeout mode
    if (funmode <> wf_engine.eng_run) then
      result := wf_engine.eng_null;
      return;
    end if;
    -- set the item attribute value with the current activity id
    -- this will be used when the recpients notification is sent.
    -- and to complete the blocked thread.
    -- HR_SFL_BLOCK_ID_ATTR
    wf_engine.setitemattrnumber(itemtype,itemkey,'HR_SFL_BLOCK_ID_ATTR',actid);
    wf_standard.block(itemtype,itemkey,actid,funmode,result);

    if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

  exception
    when others then
      Wf_Core.Context('HR_SFLUTIL_SS.sflBlock', itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
  end sflBlock;



procedure closeSFLTransaction
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2)
  is
    --local variables
    c_proc  constant varchar2(30)   :='closeSFLTransaction';
    lv_sendNtf varchar2(4);

    cursor sflNotificationsCursor is
     select  ias.notification_id notification_id
     from   wf_item_activity_statuses ias,
            wf_notifications ntf
     where   ias.item_type = itemtype
     and     ias.item_key   =itemkey
     and   ias.notification_id is not null
     and     ntf.notification_id  = ias.notification_id
     and    ntf.status='OPEN'
     union
     select  ias.notification_id notification_id
     from   wf_item_activity_statuses_h ias,
        wf_notifications ntf
     where   ias.notification_id is not null
     and ias.item_type = itemtype
     and     ias.item_key   =itemkey
     and     ntf.notification_id  = ias.notification_id
     and    ntf.status='OPEN' ;

  begin
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 10);
    end if;

    if (funmode = wf_engine.eng_run) then
      -- check if we need to send notification or end the SFL process
      -- HR_SEND_SFL_NTF_ATTR
      lv_sendNtf := NVL(wf_engine.GetItemAttrText(itemtype   => itemtype,
                                                  itemkey    => itemkey,
                                                  aname      => 'HR_SEND_SFL_NTF_ATTR',
                                                  ignore_notfound=>true),'N');
      result := 'COMPLETE:'|| lv_sendNtf;

      begin
        -- close all notifications pertaining to this transaction
        for ntfrow in sflNotificationsCursor loop
          wf_notification.close(ntfrow.notification_id,'SYSADMIN');
        end loop;
      exception
        when others then
          -- close the cursor
          if (sflNotificationsCursor%isopen) then
            close sflNotificationsCursor;
          end if;
      end;

      if g_debug then
        hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
      end if;
    end if;
  exception
    when others then
      Wf_Core.Context('HR_SFLUTIL_SS.closeSFLTransaction', itemtype,
                       itemkey, to_char(actid), funmode);
      raise;
  end closeSFLTransaction;

function OpenNotificationsExist( nid    in Number )
  return Boolean is
    --
    dummy pls_integer;
  --
  begin
    --
    select  1
    into    dummy
    from    sys.dual
    where   exists  ( select null
                      from   wf_notifications
                      where  notification_id = nid
                      and    status   = 'OPEN'
                     );
        --
        return(TRUE);
        --
  exception
    when no_data_found then
      --
      return(FALSE);
                --
    when others then
      --
      wf_core.context('hr_sfl_util_ss', 'OpenNotifications', to_char(nid) );
      raise;
  end OpenNotificationsExist;



-- ---------------------------------------------------------------------------
-- public Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< Notify>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is a public wrapper to engine notification call
-- This reads the activity attributes and sends notification to the ROLE defined
-- in the activity attribute PERFORMER with the message conigured in the activity
-- attribute MESSAGE. And also can send to group if configured through the activity
-- attribute EXPANDROLES.
--
procedure Notify(itemtype   in varchar2,
		  itemkey    in varchar2,
      	  actid      in number,
		  funcmode   in varchar2,
		  resultout  in out nocopy varchar2)
is
    msg varchar2(30);
    msgtype varchar2(8);
    prole wf_users.name%type;
    expand_role varchar2(1);

    colon pls_integer;
    avalue varchar2(240);
    notid pls_integer;
    comments wf_notifications .user_comment%type;
    document varchar2(240);
    document_type varchar2(240);
    ln_notification_id number;
begin
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     return;
   end if;

-- close the existing ntf id if any for this transaction
    ln_notification_id :=wf_engine.getitemattrnumber(itemtype,itemkey,'HR_LAST_SFL_NTF_ID_ATTR',true);
    if(ln_notification_id is not null and OpenNotificationsExist(ln_notification_id))then
      wf_notification.close(ln_notification_id,'SYSADMIN');
    end if;


--PERFORMER
prole := wf_engine.GetActivityAttrText(
                               itemtype => itemtype,
                               itemkey => itemkey,
                               actid  => actid,
                               aname => 'PERFORMER');


if prole is null then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_NOTIFICATION_PERFORMER');
   end if;

-- message name and expand roles will be null. Get these from attributes
   avalue := upper(Wf_Engine.GetActivityAttrText(itemtype, itemkey,
                 actid, 'MESSAGE'));

   -- let notification_send catch a missing message name.
   expand_role := nvl(Wf_Engine.GetActivityAttrText(itemtype, itemkey,
                 actid, 'EXPANDROLES'),'N');

   -- parse out the message type if given
   colon := instr(avalue, ':');
   if colon = 0   then
      msgtype := itemtype;
      msg := avalue;
   else
     msgtype := substr(avalue, 1, colon - 1);
     msg := substr(avalue, colon + 1);
   end if;


    -- Actually send the notification
    Wf_Engine_Util.Notification_Send(itemtype, itemkey, actid,
                       msg, msgtype, prole, expand_role,
                       resultout);

      notid:= Wf_Engine.g_nid ;

exception
  when others then
    Wf_Core.Context('HR_SFLUTIL_SS.Notify', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Notify;



procedure getSFLMsgSubject(document_id IN Varchar2,
                           display_type IN Varchar2,
                           document IN OUT NOCOPY varchar2,
                           document_type IN OUT NOCOPY Varchar2)
is
c_proc  constant varchar2(30) := 'getSFLMsgSubject';
ln_transaction_id        hr_api_transactions.transaction_id%type;
lv_parent_item_type wf_item_activity_statuses.item_type%type;
lv_parent_item_key wf_item_activity_statuses.item_key%type;
l_creator_person_id      per_people_f.person_id%type;
l_creator_disp_name      wf_users.display_name%type;
l_creator_username       wf_users.name%type;
l_current_person_id      per_people_f.person_id%type;
l_current_disp_name      wf_users.display_name%type;
l_current_username       wf_users.name%type;
lv_process_display_name wf_runnable_processes_v.display_name%type;
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
--ln_transaction_id        hr_api_transactions.transaction_id%type;
lv_selected_func_prompt  fnd_form_functions_vl.USER_FUNCTION_NAME%type;
lv_ntfSubMsg           wf_item_attribute_values.text_value%type;
lv_TransCtx_xpath varchar2(20000) default 'Transaction/TransCtx';

begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 10);
  end if;

  -- get the itemtype and item key for the notification id
     if g_debug then
       hr_utility.set_location('Calling hr_workflow_ss.get_item_type_and_key for NtfId:'||document_id, 11);
     end if;
  -- get the transaction id corresponding to this SFL notification, HR_SFL_TRANSACTION_REF_ID_ATTR
    --ln_transaction_id := wf_notification.GetAttrNumber(document_id,'HR_SFL_TRANSACTION_REF_ID_ATTR');
      ln_transaction_id := wf_notification.GetAttrNumber(document_id,'HR_TRANSACTION_REF_ID_ATTR');

    --document := getSubject(ln_transaction_id,null);
     -- set the document type
     document_type  := wf_notification.doc_html;
     -- default ouptut
     document :=ln_transaction_id;

     if (ln_transaction_id is not null) then
     begin
     select * into lr_hr_api_transaction_rec from hr_api_transactions
     where transaction_id=ln_transaction_id;
     exception
     when no_data_found then
           if(hr_utility.debug_enabled) then
          -- write debug statements
           hr_utility.set_location('no record found for the transaction :'|| ln_transaction_id, 4);
          end if;
         return ;
     when others then
        return ;
     end;
    else
      return ;
    end if;

/*
  begin
   -- get the user function name
   select USER_FUNCTION_NAME into lv_selected_func_prompt
   from fnd_form_functions_vl fffv
   where fffv.function_id=lr_hr_api_transaction_rec.FUNCTION_ID;
   exception
     when no_data_found then
           if(hr_utility.debug_enabled) then
          -- write debug statements
           hr_utility.set_location('no record found in fnd_form_functions_vl for the id :'|| ln_transaction_id, 4);
          end if;
     when others then
      -- fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
       --hr_utility.raise_error;
       return;
     end;

  -- add  the section display name
    if(lr_hr_api_transaction_rec.section_display_name is not null) then
       lv_selected_func_prompt:= lv_selected_func_prompt||' - ' ||lr_hr_api_transaction_rec.section_display_name;
    end if;
*/
  if(lr_hr_api_transaction_rec.item_key is null) then
      begin
         lv_ntfSubMsg := hr_xml_util.get_node_value(ln_transaction_id,
                                                 'pNtfSubMsg',
                                                 lv_TransCtx_xpath,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);
       fnd_message.set_name('PER',lv_ntfSubMsg);
       lv_ntfSubMsg :=  fnd_message.get;
        if (lr_hr_api_transaction_rec.transaction_ref_table = 'PER_ALL_VACANCIES') then
            lv_ntfSubMsg := lv_ntfSubMsg||' '||lr_hr_api_transaction_rec.api_addtnl_info;
       end if;

      exception
        when others then
          lv_ntfSubMsg   := ln_transaction_id;
      end;
  else
    lv_ntfSubMsg :=hr_workflow_ss.getprocessdisplayname(lr_hr_api_transaction_rec.item_type,
                                         lr_hr_api_transaction_rec.item_key);
  end if;

  l_creator_person_id := lr_hr_api_transaction_rec.CREATOR_PERSON_ID;
  l_current_person_id := lr_hr_api_transaction_rec.SELECTED_PERSON_ID;


  if g_debug then
       hr_utility.set_location('Creator_person_id:'||l_creator_person_id,15);
       hr_utility.set_location('Current_person_id:'||l_current_person_id,16);
   end if;
 if g_debug then
       hr_utility.set_location('Building subject for transaction:'||ln_transaction_id,17);
   end if;
if(l_creator_person_id=l_current_person_id or lr_hr_api_transaction_rec.transaction_ref_table = 'PER_ALL_VACANCIES') then
      if g_debug then
        hr_utility.set_location('calling  wf_directory.GetUserName for person_id:'||l_creator_person_id,18);
      end if;

       -- get creator display name from role
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_creator_person_id
          ,p_name           => l_creator_username
          ,p_display_name   => l_creator_disp_name);


      -- Subject pattern
      -- "Change Job is saved for later"
      if g_debug then
        hr_utility.set_location('Getting message HR_SS_SFL_MSG_SUB_SELF',19);
      end if;
      fnd_message.set_name('PER','HR_SS_SFL_MSG_SUB_SELF');
      fnd_message.set_token('USER_FUNCTION_NAME',lv_ntfSubMsg,false);
      document := fnd_message.get;

 else
 -- get creator display name from role
        if g_debug then
          hr_utility.set_location('calling  wf_directory.GetUserName for person_id:'||l_creator_person_id,20);
        end if;
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_creator_person_id
          ,p_name           => l_creator_username
          ,p_display_name   => l_creator_disp_name);

  -- get current person display name from role
        if g_debug then
        hr_utility.set_location('calling  wf_directory.GetUserName for person_id:'||l_current_person_id,21);
        end if;
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_current_person_id
          ,p_name           => l_current_username
          ,p_display_name   => l_current_disp_name);

 -- check if the username/wfrole is null or display name is null
      if(l_current_username is null OR l_current_disp_name is null) then
         -- default to the value set in the item attribute CURRENT_PERSON_DISPLAY_NAME
       begin
       select decode(
         fnd_profile.value('BEN_DISPLAY_EMPLOYEE_NAME')
         ,'FN',full_name,first_name||' '|| last_name||' '||suffix) FULL_NAME
       into l_current_disp_name
       from per_all_people_f
       where person_id=l_current_person_id
       and trunc(sysdate) between effective_start_date and effective_end_date;

       exception				-- start Bug 6055420
       when no_data_found then
            Begin
                SELECT varchar2_value into l_current_disp_name
                FROM hr_api_transaction_values
                WHERE transaction_step_id IN
                (SELECT transaction_step_id
                FROM hr_api_transaction_steps
                WHERE transaction_id = ln_transaction_id
                AND api_name = 'HR_PROCESS_PERSON_SS.PROCESS_API')
                AND name = 'P_FULL_NAME'
                AND 'NEW' =
                (SELECT varchar2_value
                FROM hr_api_transaction_values
                WHERE transaction_step_id IN
                (SELECT transaction_step_id
                FROM hr_api_transaction_steps
                WHERE transaction_id = ln_transaction_id
                AND api_name = 'HR_PROCESS_PERSON_SS.PROCESS_API')
                AND name = 'P_ACTION_TYPE');
             exception
                 when others then
                    l_current_disp_name:='';
             end;    				-- end Bug 6055420
        when others then
          l_current_disp_name:='';
        end;
      end if;

      -- Subject pattern
      -- "Change Job for Doe, John (proposed by Bond, James) is saved for later"
      if g_debug then
        hr_utility.set_location('Getting message HR_SS_SFL_MSG_SUB_REPORTS',22);
      end if;

    fnd_message.set_name('PER','HR_SS_SFL_MSG_SUB_REPORTS');
    fnd_message.set_token('USER_FUNCTION_NAME',lv_ntfSubMsg  ,false);
    fnd_message.set_token('SELECTED_PERSON_DISPLAY_NAME',l_current_disp_name,false);
    fnd_message.set_token('CREATOR_PERSON_DISPLAY_NAME',l_creator_disp_name,false);
    document := fnd_message.get;

 end if;





if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
 end if;

exception
when others then
    document  :=null;
    hr_utility.set_location('HR_SFLUTIL_SS.getSFLMsgSubject errored : '||SQLERRM ||' '||to_char(SQLCODE), 40);
    Wf_Core.Context('HR_SFLUTIL_SS', 'getSFLMsgSubject', document_id, display_type);
    raise;
end getSFLMsgSubject;



function getActionSubject(p_transaction_id in number) return varchar2
is

ln_function_id            hr_api_transactions.function_id%type;
lv_section_display_name   hr_api_transactions.section_display_name%type;
lv_subject varchar2(240);
begin
   -- default value
   lv_subject:=p_transaction_id;

   if (p_transaction_id is not null) then
     begin

     select fffv.user_function_name,hat.section_display_name
     into lv_subject,lv_section_display_name
     from hr_api_transactions hat,fnd_form_functions_vl fffv
     where hat.transaction_id=p_transaction_id
     and   hat.function_id=fffv.function_id;

     exception
     when no_data_found then
        if(hr_utility.debug_enabled) then
          -- write debug statements
           hr_utility.set_location('no record found for the transaction :'|| p_transaction_id, 4);
        end if;
        return lv_subject;
     when others then
        return lv_subject;
     end;
    else
      return lv_subject;
    end if;

  -- add  the section display name
  -- this has translation issues, need to change
  -- fnd message
    if(lv_section_display_name is not null) then
       lv_subject:= lv_subject||' - ' ||lv_section_display_name;
    end if;

 return lv_subject;

exception
when others then
   return lv_subject;
end getActionSubject;


function getSubject(p_transaction_id in number,
                    p_notification_id in number) return varchar2
is
lv_subject varchar2(240);

begin

 lv_subject := p_transaction_id;
 if(p_notification_id is not null) then
   return wf_notification.getsubject(p_notification_id);
 else
   return getActionSubject(p_transaction_id);
 end if;

    return lv_subject;
exception
when others then
  return p_transaction_id;
end getSubject;


procedure getSFLTransactionDetails (
              p_transaction_id IN NUMBER
             ,p_ntfId      OUT NOCOPY NUMBER
             ,p_itemType   IN OUT NOCOPY VARCHAR2
             ,p_itemKey    OUT NOCOPY VARCHAR2 )

IS
c_proc  constant varchar2(30) := 'getSFLTransactionDetails';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

  -- check the wf_items table
     begin
      select item_type,item_key
      into p_itemType,p_itemKey
      from wf_items
      where user_key=to_char(p_transaction_id)
      and item_type=nvl(p_itemType,'HRSFL')
      and end_date is null
      and rownum<2;
     exception
        when no_data_found then
           p_itemType := null;
           p_itemKey  := null;
           p_ntfId    := null;
        when others then
          p_itemType := null;
           p_itemKey  := null;
           p_ntfId    := null;
    	  raise;
     end;



exception
when others then
    hr_utility.set_location('HR_SFLUTIL_SS.getSFLTransactionDetails errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context('HR_SFLUTIL_SS', 'getSFLTransactionDetails', p_transaction_id);
    raise;
end getSFLTransactionDetails;

procedure startSFLTransaction(p_transaction_id IN NUMBER
                             ,p_transaction_ref_table in varchar2
                             ,p_itemType   IN OUT NOCOPY VARCHAR2
                             ,p_process_name IN VARCHAR2
                             ,p_itemKey    OUT NOCOPY VARCHAR2 )
 IS
   lv_item_key wf_items.item_key%type;
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;
BEGIN
  -- get the item key from sequence
   -- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   p_itemKey
  from   sys.dual;

  -- Create the Workflow Process
  wf_engine.CreateProcess
    (itemtype => p_itemType
    ,itemkey  => p_itemKey
    ,process  => p_process_name);

 -- set owner role
    wf_engine.setItemOwner(itemtype => p_itemType
                           ,itemkey => p_itemKey
                             ,owner => fnd_global.user_name);
  -- set the user key
    wf_engine.SetItemUserKey(itemtype => p_itemType
                            ,itemkey => p_itemKey
                            ,userkey => p_transaction_id);

  -- set the SFL transaction reference id, HR_SFL_TRANSACTION_REF_ID_ATTR
     wf_engine.setitemattrnumber(p_itemType,p_itemKey,'HR_SFL_TRANSACTION_REF_ID_ATTR',p_transaction_id);

  -- HR_SFL_TRANS_REF_TABLE_ATTR
     wf_engine.setitemattrtext(p_itemType,p_itemKey,'HR_SFL_TRANS_REF_TABLE_ATTR',p_transaction_ref_table);
  -- set the parent item type and item key ,if any for this SFL
    begin
    if(p_transaction_id is not null) then
      select * into lr_hr_api_transaction_rec from hr_api_transactions
      where transaction_id=p_transaction_id;

      wf_engine.setitemparent(p_itemType,p_itemKey,lr_hr_api_transaction_rec.item_type,lr_hr_api_transaction_rec.item_key,'SFL');
    end if;
    exception
    when others then
      null;
    end;

  -- Start the WF runtime process
   wf_engine.startprocess
    (itemtype => p_itemType
    ,itemkey  => p_itemKey);

  commit;
    --
  EXCEPTION
    WHEN others THEN
      raise;
  END startSFLTransaction;

procedure sendSFLNotification(p_transaction_id IN NUMBER,
                              p_transaction_ref_table in varchar2,
                              p_userName in varchar2,
			                  p_reentryPageFunction in varchar2,
			                  p_sflWFProcessName in varchar2,
                              p_notification_id out NOCOPY number)

IS
   --
     PRAGMA AUTONOMOUS_TRANSACTION;
   --
c_proc constant varchar2(30) := 'getSFLTransactionDetails';
lv_item_type wf_items.item_type%type;
lv_item_key wf_items.item_type%type;
ln_notification_id wf_notifications.notification_id%type;
lv_process_name wf_items.root_activity%type;
ln_sfl_block_activity_id number;
lv_relaunchSFLLink varchar2(2000);
begin
    hr_sflutil_ss.getsfltransactiondetails(p_transaction_id,
                                            ln_notification_id,
                                            lv_item_type,
                                            lv_item_key);
    if(lv_item_key is null) then
     -- the process was never started so start a new wf process
     -- and send notification to fnd_global.user_name
     lv_item_type :='HRSFL';
     lv_process_name :=nvl(p_sflWFProcessName,'HR_SFL_NOTIFICATION_JSP_PRC');
     startSFLTransaction(p_transaction_id,
                         p_transaction_ref_table,
                         lv_item_type,
                         lv_process_name,
                         lv_item_key);
    end if;

    -- finally check one more time
    if(lv_item_key is not null) then
      wf_engine.setitemattrtext(lv_item_type,
                                 lv_item_key,
                                 'HR_SFL_USERNAME_ATTR',
                                 nvl(p_userName,fnd_global.user_name));
      -- HR_SFL_BLOCK_ID_ATTR
      ln_sfl_block_activity_id :=wf_engine.GetItemAttrNumber(lv_item_type ,
                                                             lv_item_key,
                                                             'HR_SFL_BLOCK_ID_ATTR');
      -- set the relaunch pagefunction
      -- syntax JSP:/OA_HTML/OA.jsp?OAFunc=HR_WF_RELATED_APPS NtfId=-&#NID-
      lv_relaunchSFLLink := 'JSP:/OA_HTML/OA.jsp?OAFunc='||nvl(p_reentryPageFunction,'')||'&'||'NtfId=-'||'&'||'#NID-';
         wf_engine.setitemattrtext(lv_item_type,
                                 lv_item_key,
                                 'HR_SFL_RESURRECT_LINK_ATTR',
                                  lv_relaunchSFLLink);

      -- set the delete/reject link
      -- HR_SFL_DELETE_LINK_ATTR
         wf_engine.setitemattrtext(lv_item_type,
                                 lv_item_key,
                                 'HR_SFL_DELETE_LINK_ATTR',
                                  lv_relaunchSFLLink||'&'||'pAction=DELETE');
      -- now send the notification
      wf_engine.completeactivity(lv_item_type,lv_item_key,
                                  wf_engine.getactivitylabel(ln_sfl_block_activity_id),
                                  wf_engine.eng_trans_default);

      -- set the hr api transactions with the new notification id ??
      p_notification_id := wf_engine.getitemattrnumber(lv_item_type,lv_item_key,'HR_LAST_SFL_NTF_ID_ATTR');

    else
     -- raise exception.
     null;
    end if;
    commit;
    --
  EXCEPTION
    WHEN others THEN
      raise;
end sendSFLNotification;


procedure setSFLNtfDetails
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2)
  is
  -- local variables
  ln_notification_id number;
  begin
    -- set the ntf id value to HR_LAST_SFL_NTF_ID_ATTR
     wf_engine.setitemattrnumber(itemtype,itemkey,'HR_LAST_SFL_NTF_ID_ATTR',Wf_Engine.g_nid);
    -- set the hr_api_transactions_table

     result := wf_engine.eng_trans_default;
  EXCEPTION
    WHEN others THEN
      raise;
  end setSFLNtfDetails;

  function getSFLStatusForUpdate(
     p_currentTxnStatus in varchar2,
     p_proposedTxnStatus in varchar2) RETURN VARCHAR2
  is
  --local variables
  c_updateStatus hr_api_transactions.status%type;
  begin

  -- possible status of current transaction
       -- RO		Transactions returned to approver for correction
       -- ROS		Transactions returned to approver for correction and saved for later
       -- RI		Transactions returned to initiator for correction
       -- RIS		Transactions returned to initiator for correction and saved for later
       -- N 		Transactions initiated but not submitted for approval
       -- S	   	    Transactions saved for later
       -- W	  	    Transactions in progress
       -- Y         Transactions submitted for approval
       -- YS        Transactions save for later by approver editing.

      -- check if the current txn status is null
      -- no more iteration if null return the same status as proposed
       if(p_currentTxnStatus is null) then
         return p_proposedTxnStatus;
       end if;

       -- check the current status
       if(length(p_currentTxnStatus)=1) then
          -- possible status N, S, W, Y
          if(p_currentTxnStatus='Y') then
            -- update the transaction status as pending approval SFL
            c_updateStatus:= 'YS';
          else
             -- just SFL
             c_updateStatus:='S';
          end if;
       else
         -- fix for bug 4926377
         if(p_currentTxnStatus='YS') then
         -- update the transaction status as pending approval SFL
            c_updateStatus:= 'YS';

          -- so status is RFC
          elsif(p_currentTxnStatus in('RI','RIS')) then
            -- intiator RFC
            c_updateStatus:='RIS';
          elsif(p_currentTxnStatus in('RO','ROS')) then
            -- is there any other status possible ???
            -- possible status now could be RO ROS
            c_updateStatus:='ROS';
          else
            -- return same status
            c_updateStatus:=p_proposedTxnStatus;
          end if;

       end if;

   return c_updateStatus;
  exception
  when others then
   null;
  end getSFLStatusForUpdate;





function isTxnOwner(p_transaction_id in number,
                    p_person_id in number) return boolean
is
-- local variables
l_returnStatus boolean;
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
ln_person_id number;
begin

 -- set the default value
 l_returnStatus := false;
 ln_person_id := p_person_id;

  if(p_transaction_id is not null) then
    -- derive the transaction details
     select * into lr_hr_api_transaction_rec from hr_api_transactions
     where transaction_id=p_transaction_id;
  end if;

  --
     if(ln_person_id= fnd_global.employee_id) then
       l_returnStatus := true;
     else
       l_returnStatus :=false;
     end if;
  return l_returnStatus;
exception
when others then
  raise;
end;

procedure processApprovalSubmit(p_transaction_id in number)
 is
 -- local variables
   c_proc constant varchar2(30) := 'processApprovalSubmit';
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;
   ln_activity_id wf_item_activity_statuses.process_activity%type;
   lv_loginPersonDispName per_all_people_f.full_name%type;
   lv_loginPersonUserName fnd_user.user_name%type;
   ln_loginPersonId       fnd_user.employee_id%type;

   begin
     if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;

     -- code logic
     begin
       if(p_transaction_id is not null) then
         select * into lr_hr_api_transaction_rec
         from hr_api_transactions
         where transaction_id=p_transaction_id;

         if(lr_hr_api_transaction_rec.transaction_ref_table='PER_APPRAISALS') then
           -- appraisal specfic

           -- set the item attributes specific to appraisals
              -- get the wf role info for the login user
              wf_directory.getusername
                (p_orig_system      => 'PER'
                ,p_orig_system_id   => fnd_global.employee_id
                ,p_name             => lv_loginPersonUserName
                ,p_display_name     => lv_loginPersonDispName);
           --HR_APPRAISAL_FROM_USER_ATTR
             wf_engine.setitemattrtext(lr_hr_api_transaction_rec.item_type
                                      ,lr_hr_api_transaction_rec.item_key
                                      ,'HR_APPRAISAL_FROM_USER_ATTR',
                                      fnd_global.user_name);
           -- HR_APPRAISAL_FROM_NAME_ATTR
              wf_engine.setitemattrtext(lr_hr_api_transaction_rec.item_type
                                      ,lr_hr_api_transaction_rec.item_key
                                      ,'HR_APPRAISAL_FROM_NAME_ATTR'
                                      ,lv_loginPersonDispName);

           -- APPROVAL_COMMENT_COPY
              -- ??? module need to handle in the UI layer.

           -- set the blockid value
           hr_appraisal_workflow_ss.getapprovalblockid(
                                      lr_hr_api_transaction_rec.item_type,
                                      lr_hr_api_transaction_rec.item_key,
                                      ln_activity_id);


         else
           -- default logic
           -- get the blockid value corresponding to the UI page
           SELECT process_activity
           into ln_activity_id
           from
              (select process_activity
                FROM   WF_ITEM_ACTIVITY_STATUSES IAS
                WHERE  ias.item_type          = lr_hr_api_transaction_rec.item_type
                 and    ias.item_key           = lr_hr_api_transaction_rec.item_type
                 and    ias.activity_status    = 'NOTIFIED'
                 and    ias.process_activity   in (
                                                 select  wpa.instance_id
                                                 FROM    WF_PROCESS_ACTIVITIES     WPA,
                                                         WF_ACTIVITY_ATTRIBUTES    WAA,
                                                         WF_ACTIVITIES             WA,
                                                         WF_ITEMS                  WI
                                                 WHERE   wpa.process_item_type   = ias.item_type
                                                 and     wa.item_type           = wpa.process_item_type
                                                 and     wa.name                = wpa.activity_name
                                                 and     wi.item_type           = ias.item_type
                                                 and     wi.item_key            = ias.item_key
                                                 and     wi.begin_date         >= wa.begin_date
                                                 and     wi.begin_date         <  nvl(wa.end_date,wi.begin_date+1)
                                                 and     waa.activity_item_type  = wa.item_type
                                                 and     waa.activity_name       = wa.name
                                                 and     waa.activity_version    = wa.version
                                                 and     waa.type                = 'FORM'
                                               )
               order by begin_date desc)
           where rownum<=1;

         end if;

         -- set the workflow status TRAN_SUBMIT to Y
         wf_engine.setitemattrtext(lr_hr_api_transaction_rec.item_type
                                      ,lr_hr_api_transaction_rec.item_key
                                      ,'TRAN_SUBMIT'
                                      ,'Y');

         -- now transition the workflow to process approval notifications
           if(lr_hr_api_transaction_rec.status in('YS','RI','RIS','RO','RIS')) then
             -- complete the flow in resubmit mode
             wf_engine.CompleteActivity(
                   lr_hr_api_transaction_rec.item_type
                 , lr_hr_api_transaction_rec.item_key
                 , wf_engine.getactivitylabel(ln_activity_id)
                 , 'RESUBMIT')  ;

           else
             -- else intial submit
             wf_engine.CompleteActivity(
                   lr_hr_api_transaction_rec.item_type
                 , lr_hr_api_transaction_rec.item_key
                 , wf_engine.getactivitylabel(ln_activity_id)
                 , wf_engine.eng_trans_default)  ;
           end if;
       else
        -- raise error
        null;
       end if;
     exception
       when others then
         raise;
     end;



    if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;

   exception
     when others then
       raise;
   end processApprovalSubmit;


procedure closeSFLNotifications(p_transaction_id       IN NUMBER
                               ,p_approvalItemType     in     varchar2
                               ,p_approvalItemKey      in     varchar2)
is
  -- local variables
   c_proc constant varchar2(30) := 'closeSFLNotifications';
   lv_sfl_item_type wf_items.item_type%type;
   lv_sfl_item_key  wf_items.item_key%type;
   ln_sfl_block_activity_id number;

begin
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;

     -- close the SFL related WF process
          begin

            -- check if there are any SFL transaction associated
            select item_type, item_key
            into lv_sfl_item_type,lv_sfl_item_key
            from wf_items
            where user_key=to_char(p_transaction_id)
            --and   parent_item_type=nvl(p_approvalItemType,parent_item_type)
            --and   parent_item_key=nvl(p_approvalItemKey,parent_item_key)
            and rownum<2;

            if(lv_sfl_item_key is not null) then
              -- HR_SFL_BLOCK_ID_ATTR
              ln_sfl_block_activity_id :=wf_engine.GetItemAttrNumber(lv_sfl_item_type ,
                                                             lv_sfl_item_key,
                                                             'HR_SFL_BLOCK_ID_ATTR',true);
              if(ln_sfl_block_activity_id is not null) then
                -- set the item attribute for SFL transaction
                wf_engine.setitemattrtext(lv_sfl_item_type,lv_sfl_item_key,'HR_SEND_SFL_NTF_ATTR','N');

                wf_engine.completeactivity(lv_sfl_item_type,lv_sfl_item_key,
                                  wf_engine.getactivitylabel(ln_sfl_block_activity_id),
                                  wf_engine.eng_trans_default);
              end if;

            end if;
          exception
          when others then
           null;
          end;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    raise;
end closeSFLNotifications;


procedure closeOpenSFLNotification(p_transaction_id       IN NUMBER)
is
  -- local variables
   c_proc constant varchar2(40) := 'closeOpenSFLNotification';
   lv_sfl_item_type wf_items.item_type%type;
   lv_sfl_item_key  wf_items.item_key%type;
   ln_sfl_block_activity_id number;
   ln_notification_id wf_notifications.notification_id%type;

begin
    g_debug := hr_utility.debug_enabled;
     if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;

                 -- check if there are any SFL transaction associated
       hr_utility.set_location('check if there are any SFL transaction associated', 2);

          begin
            select item_type, item_key
            into lv_sfl_item_type,lv_sfl_item_key
            from wf_items
            where user_key=to_char(p_transaction_id)
            and rownum<2;
         exception
         when no_data_found then
           null;

         end;
       hr_utility.set_location('lv_sfl_item_key:'||lv_sfl_item_key, 3);

            if(lv_sfl_item_key is not null) then
              -- get the ntf id value to HR_LAST_SFL_NTF_ID_ATTR
              ln_notification_id:=
              wf_engine.getitemattrnumber(lv_sfl_item_type,
                                          lv_sfl_item_key,
                                          'HR_LAST_SFL_NTF_ID_ATTR',
                                          true);
     hr_utility.set_location('sfl ln_notification_id:'||ln_notification_id, 4);
              if(ln_notification_id is not null   and OpenNotificationsExist(ln_notification_id)) then
                -- close the FYI notification
                hr_utility.set_location(' calling wf_notification.close for:'||ln_notification_id, 4);
                wf_notification.close(ln_notification_id,null);
              end if;

            end if;


if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    raise;
end closeOpenSFLNotification;



END HR_SFLUTIL_SS;

/
