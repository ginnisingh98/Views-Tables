--------------------------------------------------------
--  DDL for Package Body HR_APPROVAL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPROVAL_SS" AS
/* $Header: hraprvlss.pkb 120.22.12010000.18 2009/09/22 12:31:08 ckondapi ship $ */

-- Package Variables
--
g_package  constant varchar2(25) := 'HR_APPROVAL_SS.';
g_debug  boolean ;
g_no_transaction_id exception;
g_wf_not_initialzed exception;
g_wf_error_state exception;
g_invalid_responsibility exception;
g_transaction_status_invalid exception;


-- cursor determines if an attribute exists
  cursor csr_wiav (p_item_type in     varchar2
                  ,p_item_key  in     varchar2
                  ,p_name      in     varchar2)
    IS
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = p_name;


procedure create_item_attrib_if_notexist(itemtype in varchar2,
                      itemkey in varchar2,
                      aname in varchar2,
                      text_value   in varchar2,
                      number_value in number,
                      date_value   in date )is
--
    l_dummy  number(1);
    c_proc constant varchar2(60) := 'create_item_attrib_if_notexist';
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;


  if g_debug then
       hr_utility.set_location('opening cursor csr_wiav with itemtype:'|| itemtype ||' , itemkey: '|| itemkey ||' , aname: '|| aname, 1);
  end if;
  -- open the cursor to determine if the a
  open csr_wiav(itemtype,itemkey,aname);
  fetch csr_wiav into l_dummy;
  if csr_wiav%notfound then
    --
    -- item attribute does not exist so create it
      if g_debug then
       hr_utility.set_location('calling wf_engine.additemattr for aname:'||aname,2);
      end if;
      wf_engine.additemattr
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => aname
        ,text_value=>text_value
        ,number_value=>number_value
        ,date_value=>date_value);
  end if;


  if csr_wiav%found then
    -- set the values as per the type
    if(text_value is not null) then
      if g_debug then
       hr_utility.set_location('calling wf_engine.setitemattrtext for text_value:'|| text_value,3);
      end if;
      wf_engine.setitemattrtext(itemtype,itemkey,aname,text_value);
    end if;

    if(number_value is not null) then
       if g_debug then
       hr_utility.set_location('calling wf_engine.setitemattrnumber for text_value:'|| number_value,4);
      end if;
      wf_engine.setitemattrnumber(itemtype,itemkey,aname,number_value);
    end if;

    if(date_value is not null) then
     if g_debug then
       hr_utility.set_location('calling wf_engine.setitemattrDate for text_value:'|| date_value,5);
      end if;
     wf_engine.setitemattrDate(itemtype,itemkey,aname,date_value);
    end if;

  end if;

  close csr_wiav;

     if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;

exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  create_item_attrib_if_notexist SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
    raise;

end create_item_attrib_if_notexist;


PROCEDURE set_custom_wf_globals
  (p_itemtype in varchar2
  ,p_itemkey  in varchar2)
IS
-- Local Variables
l_proc constant varchar2(100) := g_package ||'.'|| 'set_custom_wf_globals';
BEGIN
g_debug := hr_utility.debug_enabled;
  hr_utility.set_location('Entering: '|| l_proc,1);

  if g_debug then
    hr_utility.set_location('Setting hr_approval_custom.g_itemtype as :'|| p_itemtype,2);
    hr_utility.set_location('Setting hr_approval_custom.g_itemkey as :'|| p_itemkey,3);
  end if;

  hr_approval_custom.g_itemtype := p_itemtype;
  hr_approval_custom.g_itemkey  := p_itemkey;
  hr_utility.set_location('Leaving: '|| l_proc,10);
END set_custom_wf_globals;

function getOAFPageActId(p_item_type in wf_items.item_type%type,
                         p_item_key in wf_items.item_key%type) return number
is
-- local variables
   c_proc constant varchar2(30) := 'storeApproverDetails';
   ln_activity_id WF_ITEM_ACTIVITY_STATUSES.process_activity%type;
begin
      g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;

     -- get the blockid value corresponding to the UI page
           SELECT process_activity
           into ln_activity_id
           from
              (select process_activity
                FROM   WF_ITEM_ACTIVITY_STATUSES IAS
                WHERE  ias.item_type          = p_item_type
                 and    ias.item_key           = p_item_key
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

     if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;

     return ln_activity_id;


exception
  when others then
    raise;


end getOAFPageActId;

procedure handleArchive( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )
is
  -- local variables
   c_proc constant varchar2(30) := 'handleArchive';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   lv_result_code WF_ITEM_ACTIVITY_STATUSES.activity_result_code%type;
   lv_result_display varchar2(250);
   lv_test_result_code varchar2(250);
   lv_comments wf_item_attribute_values.text_value%type;
   lv_recipient varchar2(250);
   lv_new_transaction varchar2(250);
   l_cpersonId VARCHAR2(15);
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

      -- get the transaction id of the sshr transaction
   c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID',
                                               ignore_notfound=>true);

    if ( funmode = 'RESPOND' ) then
        select text_value
        into lv_result_code
        from wf_notification_attributes
        where notification_id=wf_engine.context_nid
        and name='RESULT';

         begin
          hr_sflutil_ss.closeopensflnotification(c_transaction_id);
       exception
       when others then
         null;
       end ;



   --    WF_NOTE
      begin
        select text_value
        into lv_comments
        from wf_notification_attributes
        where notification_id=wf_engine.context_nid
        and name='WF_NOTE';
      exception
       when others then
         null;
      end;

	if g_debug then
       hr_utility.set_location('processing notification response, notification_id:'||wf_engine.context_nid,2);
       hr_utility.set_location('lv_result_code:'||lv_result_code,3);
	end if;

      -- possible actions
   /*   APPROVED	:Approve
        DEL		:Delete
        REJECTED	:Reject
        RESUBMIT	:Resubmit
        RETURNEDFORCORRECTION:Return for Correction
        SFL		:Saved For Later
        START		:Start Over
        TIMEOUT		:Timeout/No response

    */
    -- block update the approval action history
    begin
        if(lv_result_code ='APPROVED') then
           if g_debug then
              hr_utility.set_location('calling hr_trans_history_api.archive_approve',4);
	       end if;
        -- use the new routing api's to handle archive
        hr_trans_history_api.archive_approve(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            lv_comments);

        elsif(lv_result_code='RESUBMIT') then
           if g_debug then
              hr_utility.set_location('calling hr_trans_history_api.archive_approve',4);
	       end if;
            -- use the new routing api's to handle archive
            hr_trans_history_api.archive_resubmit(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            wf_engine.GetItemAttrText(
                               	                         p_item_type
                  	                                    ,p_item_key
                                                       ,'APPROVAL_COMMENT_COPY'));
        elsif(lv_result_code='REJECTED') then

	       if g_debug then
              hr_utility.set_location('calling hr_trans_history_api.archive_reject',5);
	        end if;
           -- archive the action to history
           hr_trans_history_api.archive_reject(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            lv_comments);
        elsif(lv_result_code='RETURNEDFORCORRECTION') then
    	    if g_debug then
              hr_utility.set_location('calling hr_trans_history_api.archive_rfc',6);
	       end if;
          -- archive the action to history
           hr_trans_history_api.archive_rfc(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            lv_comments);
                                            --wf_engine.context_user_comment);
        elsif(lv_result_code='DEL') then
    	    if g_debug then
              hr_utility.set_location('calling hr_trans_history_api.archive_delete',7);
	       end if;
           -- archive the action to history
           hr_trans_history_api.archive_delete(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            lv_comments);
        end if;
    exception
    when others then
      raise;
    end;
  elsif( funmode = 'FORWARD' ) then
       --  FORWARD - When a notification recipient forwards the notification.
       hr_trans_history_api.archive_forward(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            wf_engine.context_user_comment);
      null;
   elsif( funmode = 'TRANSFER' ) then
       -- TRANSFER - When a notification recipient transfers the notification.
       hr_trans_history_api.archive_transfer(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            wf_engine.context_user_comment);
   -- QUESTION
   elsif( funmode = 'QUESTION' ) then
       hr_trans_history_api.archive_req_moreinfo(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            wf_engine.context_user_comment);

   elsif( funmode = 'ANSWER' ) then
      hr_trans_history_api.archive_answer_moreinfo(c_transaction_id,
                                            wf_engine.context_nid,
                                            wf_engine.context_user,
                                            wf_engine.context_user_comment);
   elsif( funmode = 'TIMEOUT' ) then
     if hr_multi_tenancy_pkg.is_multi_tenant_system then
       l_cpersonId := NVL( wf_engine.getItemAttrText (
                            itemtype => p_item_type
                           ,itemkey  => p_item_key
                           ,aname    => 'CREATOR_PERSON_ID'),-1);

       hr_multi_tenancy_pkg.set_context_for_person(l_cpersonId);
     end if;
    if g_debug then
              hr_utility.set_location('calling hr_trans_history_api.archive_timeout',7);
    end if;
    lv_new_transaction := wf_engine.getitemattrtext(p_item_type,
                                                p_item_key,
                                                'HR_NEW_TRANSACTION',true);

    if( INSTR(lv_new_transaction,'TIMEOUT') > 0) then

        --Collect the username for whom timeout happened
      begin
        select RECIPIENT_ROLE
        into lv_recipient
        from wf_notifications
        where notification_id=wf_engine.context_nid;
      exception
       when others then
         null;
      end;
     -- archive the action to history
     hr_trans_history_api.archive_timeout(c_transaction_id,
                                            wf_engine.context_nid,
                                            lv_recipient,
                                            lv_comments);
     end if;
   end if;

   if(lv_result_code is null) then
      result  := wf_engine.eng_null;
    else
    result:= 'COMPLETE:'||lv_result_code;
    end if;

    if g_debug then
       hr_utility.set_location('returning with the  result'||result,8);
    end if;


  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
  hr_utility.set_location('Error:'|| g_package||'.'||c_proc, 10);
  raise;

end handleArchive;

procedure storeApproverDetails(p_item_type    in varchar2,
                               p_item_key     in varchar2)
is
  -- local variables
   c_proc constant varchar2(30) := 'storeApproverDetails';
   l_current_forward_to_id         per_people_f.person_id%type;
   l_current_forward_to_origSys    wf_users.orig_system%type;
   l_current_forward_to_username   wf_users.name%type;
   l_current_forward_to_disp_name  wf_users.display_name%type;

begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
  -- get the current forward to approver details
    l_current_forward_to_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype => p_item_type
            ,itemkey  => p_item_key
            ,aname    => 'FORWARD_TO_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'CREATOR_PERSON_ID'));

   create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_FROM_ORIG_SYS_ATTR'
                               ,text_value=>null
                               ,number_value=>null,
                               date_value=>null
                               );

     create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_ORIG_SYS_ATTR'
                               ,text_value=>null
                               ,number_value=>null,
                               date_value=>null
                               );

     l_current_forward_to_origSys := nvl( wf_engine.GetItemAttrText
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'FORWARD_TO_ORIG_SYS_ATTR'
	    ,ignore_notfound=>true),'PER');



      if g_debug then
         hr_utility.set_location('calling wf_directory.GetRoleName for p_orig_system:'|| l_current_forward_to_origSys ||' and p_orig_system_id:'|| l_current_forward_to_id,2);
      end if;

     wf_directory.GetRoleName--GetUserName
         (p_orig_system       => l_current_forward_to_origSys
         ,p_orig_system_id    => l_current_forward_to_id
         ,p_name              => l_current_forward_to_username
         ,p_display_name      => l_current_forward_to_disp_name);

    -- set the passed approver values to the forward to item attributes
       wf_engine.SetItemAttrText
          (itemtype => p_item_type
          ,itemkey  => p_item_key
          ,aname    => 'FORWARD_TO_ORIG_SYS_ATTR'
          ,avalue   =>wf_engine.getItemAttrText
                                (itemtype => p_item_type
                                ,itemkey  => p_item_key
                                ,aname    =>'HR_APR_ORIG_SYSTEM_ATTR'));

      wf_engine.SetItemAttrNumber
          (itemtype    => p_item_type
          ,itemkey     => p_item_key
          ,aname       => 'FORWARD_TO_PERSON_ID'
          ,avalue      =>wf_engine.getItemAttrNumber
                               (itemtype    => p_item_type
                              ,itemkey     => p_item_key
                              ,aname       => 'HR_APR_ORIG_SYSTEM_ID_ATTR'));
        --
        wf_engine.SetItemAttrText
          (itemtype => p_item_type
          ,itemkey  => p_item_key
          ,aname    => 'FORWARD_TO_USERNAME'
          ,avalue   => wf_engine.getItemAttrText
                              (itemtype => p_item_type
                              ,itemkey  => p_item_key
                              ,aname    => 'HR_APR_NAME_ATTR'));

        --
        Wf_engine.SetItemAttrText
          (itemtype => p_item_type
          ,itemkey  => p_item_key
          ,aname    => 'FORWARD_TO_DISPLAY_NAME'
          ,avalue   => wf_engine.getItemAttrText
                              (itemtype => p_item_type
                              ,itemkey  => p_item_key
                              ,aname    => 'HR_APR_DISPLAY_NAME_ATTR'));
        --
        -- set forward from to old forward to
        --
        wf_engine.SetItemAttrNumber
          (itemtype    => p_item_type
           ,itemkey     => p_item_key
          ,aname       => 'FORWARD_FROM_PERSON_ID'
          ,avalue      => l_current_forward_to_id);

         -- FORWARD_FROM_ORIG_SYS_ATTR
         wf_engine.SetItemAttrText
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => 'FORWARD_FROM_ORIG_SYS_ATTR'
        ,avalue   => l_current_forward_to_origSys);


       --
       -- Get the username and display name for forward from person
       -- and save to item attributes
       --
        if g_debug then
         hr_utility.set_location('calling wf_directory.GetRoleName for p_orig_system:'|| l_current_forward_to_origSys ||' and p_orig_system_id:'|| l_current_forward_to_id,2);
        end if;
       wf_directory.GetRoleName--GetUserName
         (p_orig_system       => l_current_forward_to_origSys
         ,p_orig_system_id    => l_current_forward_to_id
         ,p_name              => l_current_forward_to_username
         ,p_display_name      => l_current_forward_to_disp_name);
      --
      wf_engine.SetItemAttrText
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => 'FORWARD_FROM_USERNAME'
        ,avalue   => l_current_forward_to_username);
      --
      wf_engine.SetItemAttrText
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => 'FORWARD_FROM_DISPLAY_NAME'
        ,avalue   => l_current_forward_to_disp_name);

     -- store AME specific approver details

      -- FORWARD_TO_ITEM_CLASS_ATTR
      create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_ITEM_CLASS_ATTR'
                               ,text_value=>wf_engine.getItemAttrText
                              (itemtype => p_item_type
                              ,itemkey  => p_item_key
                              ,aname    => 'HR_APR_ITEM_CLASS_ATTR')
                               ,number_value=>null,
                               date_value=>null
                               );


      -- FORWARD_TO_ITEM_ID_ATTR
       create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_ITEM_ID_ATTR'
                               ,text_value=>wf_engine.getItemAttrText
                              (itemtype => p_item_type
                              ,itemkey  => p_item_key
                              ,aname    => 'HR_APR_ITEM_ID_ATTR')
                               ,number_value=>null,
                               date_value=>null
                               );

      -- FORWARD_TO_GROUPORCHAINID

      create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_GROUPORCHAINID'
                               ,text_value=>null
                               ,number_value=>wf_engine.getItemAttrNumber
                              (itemtype => p_item_type
                              ,itemkey  => p_item_key
                              ,aname    => 'HR_APR_GRPORCHN_ID_ATTR'),
                               date_value=>null
                               );


      -- FORWARD_TO_ACTIONTYPEID_ATTR
      create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_ACTIONTYPEID_ATTR'
                               ,text_value=>wf_engine.getItemAttrText
                              (itemtype => p_item_type
                              ,itemkey  => p_item_key
                              ,aname    => 'HR_APR_ACTION_TYPE_ID_ATTR')
                               ,number_value=>null,
                               date_value=>null
                               );

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    raise;
end storeApproverDetails;

procedure getNextCustomApprover(p_item_type    in varchar2,
                                p_item_key     in varchar2,
                                p_approvalprocesscompleteynout out nocopy varchar2,
                                p_approver_rec out nocopy ame_util.approverRecord2)
is
  -- local variables
    c_proc constant varchar2(30) := 'getNextCustomApprover';
    l_creator_person_id       per_people_f.person_id%type;
    l_forward_to_person_id              per_people_f.person_id%type;
    l_current_forward_to_id per_people_f.person_id%type;
    l_current_forward_from_id   per_people_f.person_id%type;
    ln_last_default_approver_id per_people_f.person_id%type;
    ln_addntl_approvers NUMBER  DEFAULT 0;
    ln_approval_level       NUMBER DEFAULT 0;
    ln_curr_def_appr_index   NUMBER DEFAULT 1;
    ln_current_approver_index   NUMBER ;
    ln_last_def_approver       NUMBER;
    l_dummy                  VARCHAR2(100);
    lv_dummy                    VARCHAR2(20);
    lv_exists               VARCHAR2(10);
    lv_isvalid              VARCHAR2(10);
    lv_response             VARCHAR2(10);
    lv_item_name             VARCHAR2(100);


    cv_item_name      constant            VARCHAR2(20) := 'ADDITIONAL_APPROVER_';
    cv_notifier_name  constant            VARCHAR2(9) := 'NOTIFIER_';



begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

  --
    l_creator_person_id := wf_engine.GetItemAttrNumber
                     (itemtype      => p_item_type
                         ,itemkey       => p_item_key
                         ,aname         => 'CREATOR_PERSON_ID');
    --
    l_forward_to_person_id := wf_engine.GetItemAttrNumber
                    (itemtype       => p_item_type
                        ,itemkey        => p_item_key
                        ,aname          =>'FORWARD_TO_PERSON_ID');

-- get the current forward to person
    l_current_forward_to_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype => p_item_type
            ,itemkey  => p_item_key
            ,aname    => 'FORWARD_TO_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'CREATOR_PERSON_ID'));


l_forward_to_person_id := NVL(l_forward_to_person_id,l_current_forward_to_id);

-- attribute to hold the last_default approver from the heirarchy tree.
  OPEN csr_wiav(p_item_type,p_item_key,'LAST_DEFAULT_APPROVER');
       FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'LAST_DEFAULT_APPROVER');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'LAST_DEFAULT_APPROVER',
                     avalue      => NULL);

        END IF;
   CLOSE csr_wiav;


 -- 'LAST_DEFAULT_APPROVER'
  ln_last_def_approver:=  wf_engine.GetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'LAST_DEFAULT_APPROVER'
                     );

ln_last_def_approver:= NVL(ln_last_def_approver,l_forward_to_person_id);

-- check if we have default approvers
lv_response := hr_approval_custom.Check_Final_approver
                  (p_forward_to_person_id       => ln_last_def_approver
                  ,p_person_id                  => l_creator_person_id );

IF lv_response <>'N' THEN
 p_approvalprocesscompleteynout := ame_util.booleanTrue;
 return;
else
 p_approvalprocesscompleteynout := ame_util.booleanFalse;
END IF;

      -- check if we have reached the max limit on the approvers level
      -- the level is based on the heirarchy tree.
      -- get the approval level as conifgured by the HR Rep or Sys Admin
    OPEN csr_wiav(p_item_type
                 ,p_item_key
                 ,'APPROVAL_LEVEL');

    FETCH csr_wiav into l_dummy;
      IF csr_wiav%notfound  THEN
         ln_approval_level := 0;
      ELSE
         ln_approval_level := wf_engine.GetItemAttrNumber
                                  (itemtype   => p_item_type,
                                   itemkey    => p_item_key,
                                   aname      => 'APPROVAL_LEVEL');
      END IF; -- for    csr_wiav%notfound
   CLOSE  csr_wiav;

  IF  ln_approval_level > 0 THEN
        -- get the current approval level reached
      -- first check if the attribute exists
            OPEN csr_wiav(p_item_type
                 ,p_item_key
                 ,'CURRENT_DEF_APPR_INDEX');

    FETCH csr_wiav into l_dummy;
      IF csr_wiav%notfound  THEN
         NULL;
      ELSE
        ln_curr_def_appr_index := wf_engine.GetItemAttrNumber
                                        (itemtype   => p_item_type,
                                        itemkey    => p_item_key,
                                        aname      => 'CURRENT_DEF_APPR_INDEX');
      END IF;-- for    csr_wiav%notfound
   CLOSE  csr_wiav;

END IF; -- for   ln_num_of_add_apprs > 0


-- Fix for the Bug # 1255826
IF (ln_approval_level> 0)

 THEN
          IF(  ln_curr_def_appr_index < ln_approval_level)
           THEN

           p_approvalprocesscompleteynout := ame_util.booleanFalse;
           ELSE
           p_approvalprocesscompleteynout := ame_util.booleanTrue;
           END IF;
 ELSE
    lv_response := hr_approval_custom.Check_Final_approver
                  (p_forward_to_person_id       => ln_last_def_approver
                  ,p_person_id                  => l_creator_person_id );
    if lv_response <>'N' then
     p_approvalprocesscompleteynout := ame_util.booleanTrue ;
    else
     p_approvalprocesscompleteynout := ame_util.booleanFalse;
    end if;
END IF;

   -- get the next approver details
    if(p_approvalprocesscompleteynout = ame_util.booleanFalse) then

    l_current_forward_from_id:=null;
    l_current_forward_to_id:=null;
    ln_addntl_approvers:= null;
    ln_current_approver_index:=null;
     -- get the current forward from person
    l_current_forward_from_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'FORWARD_FROM_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'CREATOR_PERSON_ID'));
    -- get the current forward to person
    l_current_forward_to_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype => p_item_type
            ,itemkey  => p_item_key
            ,aname    => 'FORWARD_TO_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'CREATOR_PERSON_ID'));


        -- get the total number of additional approvers for this transaction
        ln_addntl_approvers := NVL(wf_engine.GetItemAttrNumber
                              (itemtype   => p_item_type
                              ,itemkey    => p_item_key
                              ,aname      => 'ADDITIONAL_APPROVERS_NUMBER'),
                              0);

-- fix for the bug # 1252070

-- attribute to hold the last_default approver from the heirarchy tree.
  OPEN csr_wiav(p_item_type,p_item_key,'CURRENT_APPROVER_INDEX');
      FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'CURRENT_APPROVER_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_APPROVER_INDEX',
                     avalue      => NULL);

        END IF;
   CLOSE csr_wiav;





  -- get the current_approver_index
       ln_current_approver_index := NVL(wf_engine.GetItemAttrNumber
                              (itemtype   => p_item_type
                              ,itemkey    => p_item_key
                              ,aname      => 'CURRENT_APPROVER_INDEX'),
                              0);
  -- set the item name
      lv_item_name := cv_item_name || to_char(ln_current_approver_index + 1);

  -- check if we have additional approver for the next index.
 -- Fix for the bug # 1255826
  IF ln_current_approver_index <= ln_addntl_approvers
  THEN
    OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
      FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
            lv_exists := 'N';
         ELSE
            lv_exists := 'Y';
            lv_isvalid := wf_engine.GetItemAttrText
                                 (itemtype   => p_item_type,
                                  itemkey    => p_item_key,
                                  aname      => lv_item_name);
            lv_isvalid := NVL(lv_isvalid,' ');

         END IF;
   CLOSE csr_wiav;
 ELSE
    lv_exists := 'N';
 END IF;


 IF lv_exists <>'N' AND lv_isvalid <>'DELETED' THEN
      l_forward_to_person_id :=
          wf_engine.GetItemAttrNumber
                       (itemtype    => p_item_type,
                        itemkey     => p_item_key,
                        aname       => lv_item_name
                        );

 ELSE
 -- get the last default approver index

    ln_last_default_approver_id := wf_engine.GetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'LAST_DEFAULT_APPROVER');



-- get the next approver from the heirarchy tree.
-- fix for bug #2087458
-- the l_current_forward_to_id resetting was removed for default approver.
-- now the from column will show the last approver approved.
   l_forward_to_person_id :=
        hr_approval_custom.Get_Next_Approver
          (p_person_id =>  NVL(ln_last_default_approver_id,
                                   wf_engine.GetItemAttrNumber
                                       (itemtype   => p_item_type
                                       ,itemkey    => p_item_key
                                       ,aname      => 'CREATOR_PERSON_ID')));
    -- set the last default approver id
 -- 'LAST_DEFAULT_APPROVER'
   wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'LAST_DEFAULT_APPROVER',
                     avalue      => l_forward_to_person_id);
-- set cuurent approval levels reached
  OPEN csr_wiav(p_item_type,p_item_key,'CURRENT_DEF_APPR_INDEX');
       FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'CURRENT_DEF_APPR_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_DEF_APPR_INDEX',
                     avalue      => 0);
         ELSE
         ln_curr_def_appr_index  :=
                     wf_engine.GetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_DEF_APPR_INDEX'
                     );
       -- increment it and update the item attribute value
           ln_curr_def_appr_index  := ln_curr_def_appr_index + 1;
         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_DEF_APPR_INDEX',
                     avalue      => ln_curr_def_appr_index);
        END IF;
   CLOSE csr_wiav;

 END IF;

-- set the current_approver_index
 wf_engine.SetItemAttrNumber (itemtype   => p_item_type
                              ,itemkey    => p_item_key
                              ,aname      => 'CURRENT_APPROVER_INDEX'
                              ,avalue     => (ln_current_approver_index + 1));


-- derive wf role details for the selected person id
        if ( l_forward_to_person_id is not null ) then
            wf_directory.GetRoleName--GetUserName
              (p_orig_system    => 'PER'
              ,p_orig_system_id => l_forward_to_person_id
              ,p_name           => p_approver_rec.name
              ,p_display_name   => p_approver_rec.display_name);

               p_approver_rec.orig_system:='PER';
               p_approver_rec.orig_system_id:=l_forward_to_person_id;
	       p_approver_rec.approver_category:=ame_util.approvalApproverCategory;
         end if;


end if;

     if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    raise;
end getNextCustomApprover;

procedure populateApproverDetails(p_item_type    in varchar2,
                                  p_item_key     in varchar2,
			          p_approverRec  in ame_util.approverRecord2)
  is
  -- local variables
   c_proc constant varchar2(60) := 'populateApproverDetails';
  begin
  g_debug := hr_utility.debug_enabled;

	if g_debug then
	  hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
	end if;
   -- create and/or populate approver details to item attributes
   -- same structer as ame_util.approverRecord2
    --     HR_APR_NAME_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_NAME_ATTR',
                      text_value=>p_approverRec.name,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_ORIG_SYSTEM_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ORIG_SYSTEM_ATTR',
                      text_value=>p_approverRec.orig_system,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_ORIG_SYSTEM_ID_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ORIG_SYSTEM_ID_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.orig_system_id,
                      date_value=>null);

    --     HR_APR_DISPLAY_NAME_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_DISPLAY_NAME_ATTR',
                      text_value=>p_approverRec.display_name,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_CATEGORY_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_CATEGORY_ATTR',
                      text_value=>p_approverRec.approver_category,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_API_INSERTION_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_API_INSERTION_ATTR',
                      text_value=>p_approverRec.api_insertion,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_AUTHORITY_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_AUTHORITY_ATTR',
                      text_value=>p_approverRec.authority,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_APPROVAL_STATUS_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_APPROVAL_STATUS_ATTR',
                      text_value=>p_approverRec.approval_status,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_ACTION_TYPE_ID_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ACTION_TYPE_ID_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.action_type_id,
                      date_value=>null);

    --     HR_APR_GRPORCHN_ID_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_GRPORCHN_ID_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.group_or_chain_id,
                      date_value=>null);

    --     HR_APR_OCCURRENCE_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_OCCURRENCE_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.occurrence,
                      date_value=>null);

    --     HR_APR_SOURCE_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_SOURCE_ATTR',
                      text_value=>p_approverRec.source,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_ITEM_CLASS_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ITEM_CLASS_ATTR',
                      text_value=>p_approverRec.item_class,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_ITEM_ID_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ITEM_ID_ATTR',
                      text_value=>p_approverRec.item_id,
                      number_value=>null,
                      date_value=>null);

    --     HR_APR_ITM_CLS_ORD_NUM_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ITM_CLS_ORD_NUM_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.item_class_order_number,
                      date_value=>null);

    --     HR_APR_ITM_ORD_NUM_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ITM_ORD_NUM_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.item_order_number,
                      date_value=>null);

    --     HR_APR_SUB_LST_ORD_NUM_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_SUB_LST_ORD_NUM_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.sub_list_order_number,
                      date_value=>null);

    --     HR_APR_ACT_TYP_ORD_NUM_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ACT_TYP_ORD_NUM_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.action_type_order_number,
                      date_value=>null);

    --     HR_APR_GRPORCHN_ORD_NUM_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_GRPORCHN_ORD_NUM_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.group_or_chain_order_number,
                      date_value=>null);

    --     HR_APR_MEMBER_ORD_NUM_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_MEMBER_ORD_NUM_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.member_order_number,
                      date_value=>null);

    --     HR_APR_ORD_NUM_ATTR

        create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ORD_NUM_ATTR',
                      text_value=>null,
                      number_value=>p_approverRec.approver_order_number,
                      date_value=>null);


     if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;

  exception
  when others then
  raise;
  end populateApproverDetails;

procedure getNextApproverRole(p_item_type    in varchar2,
                              p_item_key     in varchar2,
                              p_act_id       in number,
                              funmode     in varchar2,
                              result      out nocopy varchar2  )
is
  -- local variables
   c_proc constant varchar2(30) := 'getNextApproverRole';
   lv_current_approver_category varchar2(4000);
   l_current_forward_to_username   wf_users.name%type;
   l_current_forward_to_disp_name  wf_users.display_name%type;

begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
     if ( funmode = wf_engine.eng_run ) then
      -- HR_APR_CATEGORY_ATTR
      lv_current_approver_category :=wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_APR_CATEGORY_ATTR',
                                               ignore_notfound=>true);
        -- default approvals
      lv_current_approver_category := nvl(lv_current_approver_category,'A');
      if(lv_current_approver_category='A') then
        storeApproverDetails(p_item_type,p_item_key);
        result := 'COMPLETE:APPROVAL';
      else

	  l_current_forward_to_disp_name :=
      nvl(wf_engine.GetItemAttrText
            (itemtype => p_item_type
            ,itemkey  => p_item_key
            ,aname    => 'FORWARD_TO_DISPLAY_NAME'),
          wf_engine.GetItemAttrText
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'CREATOR_PERSON_DISPLAY_NAME'));

    l_current_forward_to_username :=
      nvl(wf_engine.GetItemAttrText
            (itemtype => p_item_type
            ,itemkey  => p_item_key
            ,aname    => 'FORWARD_TO_USERNAME'),
          wf_engine.GetItemAttrText
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'CREATOR_PERSON_USERNAME'));


     wf_engine.SetItemAttrText
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => 'FORWARD_FROM_USERNAME'
        ,avalue   => l_current_forward_to_username);
      --
      wf_engine.SetItemAttrText
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => 'FORWARD_FROM_DISPLAY_NAME'
        ,avalue   => l_current_forward_to_disp_name);

        result := 'COMPLETE:FYI';
      end if;
     end if;


  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    raise;
end getNextApproverRole;



function isPreNonAMEFYIComplete( p_item_type    in varchar2,
                                 p_item_key     in varchar2) return boolean is
 lv_result varchar2(50);
 c_proc constant varchar2(60) := 'isPreNonAMEFYIComplete';
begin
   g_debug := hr_utility.debug_enabled;
   if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
   end if;

  -- call the initialize code
  --HR_DYNAMIC_APPROVAL_WEB.INITIALIZE_ITEM_ATTRIBUTES(p_item_type,p_item_key,null,wf_engine.eng_run,lv_result);


  -- check if we need to go through this cycle or completed
   HR_DYNAMIC_APPROVAL_WEB.CHECK_ONSUBMIT_NOTIFIER(p_item_type,p_item_key,null,wf_engine.eng_run,lv_result);

   if(lv_result='COMPLETE:N') then
     HR_DYNAMIC_APPROVAL_WEB.GET_ONSUBMIT_NOTIFIER(p_item_type,p_item_key,null,wf_engine.eng_run,lv_result);

     --  ONSUB_FWD_TO_USERNAME
      create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_NAME_ATTR',
                      text_value=>wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'ONSUB_FWD_TO_USERNAME',
                                               ignore_notfound=>true),
                      number_value=>null,
                      date_value=>null);


     -- fyiApproverCategory

     create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_APR_CATEGORY_ATTR'
                               ,text_value=>ame_util.fyiApproverCategory
                               ,number_value=>null,
                               date_value=>null
                               );


      --HR_APR_SUB_LST_ORD_NUM_ATTR
       create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_APR_SUB_LST_ORD_NUM_ATTR'
                               ,text_value=>null
                               ,number_value=>1,
                               date_value=>null
                               );
       create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_APR_ORIG_SYSTEM_ID_ATTR'
                               ,text_value=>null
                               ,number_value=>null,
                               date_value=>null
                               );
     wf_engine.SetItemAttrNumber
                               (itemtype    => p_item_type
                              ,itemkey     => p_item_key
                              ,aname       => 'HR_APR_ORIG_SYSTEM_ID_ATTR'
                              ,avalue=>null);

    if (g_debug ) then
     hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 11);
    end if;
    return false;
  else
    if (g_debug ) then
     hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 12);
    end if;
    return true;
  end if;
exception
when others then
     if g_debug then
       hr_utility.set_location('Error in  isPreNonAMEFYIComplete SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
  raise;
end isPreNonAMEFYIComplete;


function isPostNonAMEFYIComplete( p_item_type    in varchar2,
                                 p_item_key     in varchar2) return boolean is
 lv_result varchar2(50);
 c_proc constant varchar2(60) := 'isPostNonAMEFYIComplete';
begin
   g_debug := hr_utility.debug_enabled;

   if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
   end if;

 -- fyiApproverCategory
   HR_DYNAMIC_APPROVAL_WEB.CHECK_ONAPPROVAL_NOTIFIER(p_item_type,p_item_key,null,wf_engine.eng_run,lv_result);

if(lv_result='COMPLETE:N') then

   HR_DYNAMIC_APPROVAL_WEB.GET_ONAPPROVAL_NOTIFIER(p_item_type,p_item_key,null,wf_engine.eng_run,lv_result);

 -- ONAPPR_FWD_TO_USERNAME

 create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_NAME_ATTR',
                      text_value=>wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'ONAPPR_FWD_TO_USERNAME',
                                               ignore_notfound=>true),
                      number_value=>null,
                      date_value=>null);


  create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_APR_CATEGORY_ATTR'
                               ,text_value=>ame_util.fyiApproverCategory
                               ,number_value=>null,
                               date_value=>null
                               );


  --HR_APR_SUB_LST_ORD_NUM_ATTR
   create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_APR_SUB_LST_ORD_NUM_ATTR'
                               ,text_value=>null
                               ,number_value=>3,
                               date_value=>null
                               );

  create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_APR_ORIG_SYSTEM_ID_ATTR'
                               ,text_value=>null
                               ,number_value=>null,
                               date_value=>null
                               );
     wf_engine.SetItemAttrNumber
                               (itemtype    => p_item_type
                              ,itemkey     => p_item_key
                              ,aname       => 'HR_APR_ORIG_SYSTEM_ID_ATTR'
                              ,avalue=>null);
    if (g_debug ) then
     hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 11);
    end if;
    return false;
  else
     if (g_debug ) then
     hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 12);
    end if;
     return true;
  end if;
 exception
when others then
   if g_debug then
       hr_utility.set_location('Error in  isPostNonAMEFYIComplete SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
  raise;

end isPostNonAMEFYIComplete;



procedure isFinalApprover( p_item_type    in varchar2,
                p_item_key     in varchar2,
                p_act_id       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
AS
-- Local Variables
l_proc      constant    varchar2(61) := g_package||'isFinalApprover';
c_proc constant varchar2(60) := 'isFinalApprover';
l_name varchar2(60);

-- Variables required for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approvers  ame_util.approverstable2;
c_approvalprocesscompleteynout varchar2(1) ;
c_approver_to_notify_rec ame_util.approverRecord2;
error_message_text varchar2(2000);

--

BEGIN
   g_debug := hr_utility.debug_enabled;
   c_approvalprocesscompleteynout  := ame_util.booleanFalse;

   if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
   end if;

error_message_text := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'ERROR_MESSAGE_TEXT',
	                     ignore_notfound=>true);


if(error_message_text is not null) then

wf_engine.setitemattrtext(p_item_type,p_item_key,'ERROR_MESSAGE_TEXT',null);
wf_engine.setitemattrtext(p_item_type,p_item_key,'ERROR_ITEM_TYPE',null);
wf_engine.setitemattrtext(p_item_type,p_item_key,'ERROR_ITEM_KEY',null);

end if;

c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');

if ( funmode = 'RUN' ) then

  -- fix for bug 4454439
    begin
      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>p_item_type
                                          ,p_item_key=>p_item_key);
    exception
    when others then
      null;
    end;

  -- -----------------------------------------------------------------------
  -- expose the wf control variables to the custom package
  -- -----------------------------------------------------------------------
  -- Needed for backward compatibility
    if g_debug then
       hr_utility.set_location('calling set_custom_wf_globals with p_item_type: '|| p_item_type ||' and p_item_key:' || p_item_key,2);
   end if;

    set_custom_wf_globals
      (p_itemtype => p_item_type
      ,p_itemkey  => p_item_key);

  -- check if the pre-notification process for non-AME FYI is completed
  if g_debug then
       hr_utility.set_location('calling isPreNonAMEFYIComplete with p_item_type: '|| p_item_type ||' and p_item_key:' || p_item_key,3);
   end if;

  if(NOT isPreNonAMEFYIComplete(p_item_type,p_item_key)) then
     result := 'COMPLETE:'||'N';
     return;
  end if;

c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR');
c_application_id := nvl(c_application_id,800);
c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');
if(c_transaction_type is not null) then
  begin
    if g_debug then
       hr_utility.set_location('calling ame_api2.getNextApprovers4 ',4);
       hr_utility.set_location('c_application_id:'||c_application_id,5);
       hr_utility.set_location('c_transaction_type:'|| c_transaction_type,6);
       hr_utility.set_location('c_transaction_id:'|| c_transaction_id,7);
       hr_utility.set_location('flagApproversAsNotifiedIn:'|| ame_util.booleanFalse,8);
   end if;
    ame_api2.getNextApprovers4
    (applicationIdIn  => c_application_id
    ,transactionTypeIn => c_transaction_type
    ,transactionIdIn => c_transaction_id
    ,flagApproversAsNotifiedIn=>ame_util.booleanFalse
    ,approvalProcessCompleteYNOut => c_approvalprocesscompleteynout
    ,nextApproversOut => c_next_approvers);

    if g_debug then
       hr_utility.set_location('returned from ame_api2.getNextApprovers4, number records fetched:'||c_next_approvers.count,9);
   end if;

    -- Assumption no parallel approvers,
    -- to revisit for parallel approvers case
    if(c_approvalprocesscompleteynout<>'Y') then
     c_approver_to_notify_rec :=c_next_approvers(1);
    end if;

  exception
    when others then

    handleApprovalErrors(p_item_type, p_item_key, sqlerrm);
    result := 'COMPLETE:'||'E';
    return;
    end;

else
  -- non AME
  begin
  hr_approval_ss.getNextCustomApprover
            (p_item_type=>p_item_type,
             p_item_key =>p_item_key,
             p_approvalprocesscompleteynout=>c_approvalprocesscompleteynout,
             p_approver_rec=>c_approver_to_notify_rec);
  exception
  when others then
     if g_debug then
        hr_utility.set_location('Error in  isFinalApprover calling hr_approval_ss.getNextCustomApprover,  SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
    raise;
  end;
end if ; -- check for AME


if g_debug then
       hr_utility.set_location('c_approvalprocesscompleteynout:'||c_approvalprocesscompleteynout,12);
end if;

-- check if the approval process is complete
   if(c_approvalprocesscompleteynout='Y') then
     result := 'COMPLETE:'||'Y';
     -- check if the pre-notification process for non-AME FYI is completed
     if g_debug then
       hr_utility.set_location('calling isPostNonAMEFYIComplete',13);
     end if;

     if(NOT isPostNonAMEFYIComplete(p_item_type,p_item_key)) then
        result := 'COMPLETE:'||'N';
     return;
  end if;
   else
     if g_debug then
       hr_utility.set_location('calling populateApproverDetails',14);
     end if;

     populateApproverDetails(p_item_type,p_item_key,c_approver_to_notify_rec);
     result := 'COMPLETE:'||'N';
   end if;
end if;



if (g_debug ) then
  hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 50);
end if;


EXCEPTION
   WHEN OTHERS THEN
   if g_debug then
        hr_utility.set_location('Error in  isFinalApprover ,  SQLERRM' ||' '||to_char(SQLCODE),30);
      end if;
    raise;

END isFinalApprover ;


procedure updateApprovalHistory( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'updateApprovalHistory';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;

begin
   g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
   if ( funmode = wf_engine.eng_run ) then
    -- call PQH_SS_HISTORY.transfer_approval_to_history
	    if g_debug then
	       hr_utility.set_location('calling PQH_SS_HISTORY.transfer_approval_to_history ',2);
	       hr_utility.set_location('p_item_type:'|| p_item_type,3);
	       hr_utility.set_location('p_item_key:'|| p_item_key,4);
	    end if;

    PQH_SS_HISTORY.transfer_approval_to_history(p_item_type,p_item_key,p_act_id,funmode,result);
    -- reset the status to pending approval
	if g_debug then
	       hr_utility.set_location('calling PQH_SS_WORKFLOW.set_txn_approve_status ',5);
	       hr_utility.set_location('p_item_type:'|| p_item_type,6);
	       hr_utility.set_location('p_item_key:'|| p_item_key,7);
	    end if;

    PQH_SS_WORKFLOW.set_txn_approve_status(p_item_type,p_item_key,p_act_id,funmode,result);

   end if;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    raise;
end updateApprovalHistory;

procedure forwardToRoleReInit(p_item_type in wf_items.item_type%type,
                            p_item_key  in wf_items.item_key%type) is
  lv_role_name wf_roles.name%type;
  lv_role_disp_name wf_roles.name%type;
  lv_role_orig_system wf_roles.orig_system%type;
  lv_role_orig_sys_id wf_roles.orig_system_id%type;
begin

  -- FORWARD_TO_PERSON_ID
    lv_role_orig_sys_id:=wf_engine.getitemattrnumber(p_item_type,p_item_key,'FORWARD_TO_PERSON_ID',true);

    if(lv_role_orig_sys_id is not null) then
      -- need to revisit with role based support in SSHR transaction
      lv_role_orig_system := nvl( wf_engine.GetItemAttrText
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'FORWARD_TO_ORIG_SYS_ATTR'
	    ,ignore_notfound=>true),'PER');

      wf_directory.GetRoleName
         (p_orig_system       => lv_role_orig_system
         ,p_orig_system_id    => lv_role_orig_sys_id
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);
     -- set the concerned item attributes
     -- FORWARD_TO_USERNAME
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_USERNAME'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );
    end if;

end forwardToRoleReInit;


procedure updateApproveStatus( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'updateApproveStatus';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   notification_rec ame_util2.notificationRecord;

begin

   g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
   if ( funmode = wf_engine.eng_run ) then
       -- check if it is AME or custom approvals
       c_application_id :=nvl(wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR'),800);

       c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');

       c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');
       forwardToRoleReInit(p_item_type,p_item_key);
       if(c_transaction_type is not null) then
         hr_utility.set_location('In(if ( if(c_transaction_type is not null))): '|| c_proc,2);
          l_current_forward_to_username:=   Wf_engine.GetItemAttrText(itemtype => p_item_type
                                                                     ,itemkey  => p_item_key
                                                                     ,aname    => 'FORWARD_TO_USERNAME');
          l_current_forward_to_username := nvl(l_current_forward_to_username,wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'RETURN_TO_USERNAME'));

		notification_rec.notification_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
																		itemkey  => p_item_key,
																		aname => 'HR_CONTEXT_NID_ATTR');
		notification_rec.user_comments := wf_notification.getattrtext(
       			notification_rec.notification_id
       		       ,'WF_NOTE');

	   if g_debug then
	    hr_utility.set_location('calling ame_api2.updateApprovalStatus2', 3);
	    hr_utility.set_location('c_application_id:'|| c_application_id, 4);
	    hr_utility.set_location('c_transaction_type:'|| c_transaction_type, 5);
	    hr_utility.set_location('approvalStatusIn:'|| ame_util.approvedStatus, 6);
	    hr_utility.set_location('approverNameIn:'|| l_current_forward_to_username, 7);
	  end if;

	  begin
	  ame_api6.updateApprovalStatus2(applicationIdIn=>c_application_id,
                                   transactionTypeIn =>c_transaction_type,
                                   transactionIdIn=>c_transaction_id,
                                   approvalStatusIn =>ame_util.approvedStatus,
                                   approverNameIn =>l_current_forward_to_username,
                                   itemClassIn => null,
                                   itemIdIn =>null,
                                   actionTypeIdIn=> null,
                                   groupOrChainIdIn =>null,
                                   occurrenceIn =>null,
                                   notificationIn => notification_rec,
                                   forwardeeIn =>ame_util.emptyApproverRecord2,
								   updateItemIn =>false);
	  exception
	  when others then
	     if g_debug then
                hr_utility.set_location('Error in  updateApproveStatus SQLERRM' ||' '||to_char(SQLCODE),10);
             end if;
	     hr_utility.trace('ORCL error '||SQLERRM);
	     result := wf_engine.eng_trans_default;
	     return;
       end;

         if g_debug then
	    hr_utility.set_location('returned from calling ame_api2.updateApprovalStatus2', 8);
        end if;

         result := wf_engine.eng_trans_default;
       else
         null;
       end if;
       pqh_ss_workflow.set_txn_approve_status(p_item_type,p_item_key,p_act_id,funmode,result);
/*
        -- transfer the approval action to history
        -- call PQH_SS_HISTORY.transfer_approval_to_history
           updateApprovalHistory( p_item_type=>p_item_type,
                           p_item_key=>p_item_key,
                           p_act_id=>p_act_id,
                           funmode=>funmode,
                           result=>result);*/


     end if;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 20);
     end if;
exception
  when others then
    if g_debug then
                hr_utility.set_location('Error in  updateApproveStatus SQLERRM' ||' '||to_char(SQLCODE),30);
             end if;
    raise;
end updateApproveStatus;

procedure approver_category( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )
is
 --
 lv_current_approver_category varchar2(4000);
 ln_sublist_order_number number;
 c_proc constant varchar2(60) := 'approver_category';
begin
   g_debug := hr_utility.debug_enabled;

   if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

   -- get the current approver category
   --   HR_APR_CATEGORY_ATTR
   lv_current_approver_category:= wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_APR_CATEGORY_ATTR',
					       ignore_notfound=>true);
  --HR_APR_SUB_LST_ORD_NUM_ATTR
   ln_sublist_order_number:=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_APR_SUB_LST_ORD_NUM_ATTR',
					       ignore_notfound=>true);
  -- default approvals
  lv_current_approver_category := nvl(lv_current_approver_category,'A');
  -- default FYI approver
  ln_sublist_order_number:= nvl(ln_sublist_order_number,2);
  if(lv_current_approver_category='A') then
    result:= 'COMPLETE:'||'APPROVAL';
  elsif(ln_sublist_order_number=1) then
    result:= 'COMPLETE:'||'PRE';
  elsif(ln_sublist_order_number=2) then
    result:= 'COMPLETE:'||'AUTH';
   elsif(ln_sublist_order_number=3) then
    result:= 'COMPLETE:'||'POST';
  end if;

   if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
   end if;

  exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  approver_category SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
   raise;

end approver_category;


procedure flagApproversAsNotified( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )
is
-- local variables
   c_proc constant varchar2(30) := 'flagApproversAsNotified';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   l_current_forward_to_username   wf_users.name%type;
   l_curr_fwd_to_orig_system_id number;

begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
   if ( funmode = wf_engine.eng_run ) then
       -- check if it is AME or custom approvals
       c_application_id :=nvl(wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR'),800);

       c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');

       c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');
       if(c_transaction_type is not null) then
         hr_utility.set_location('In(if ( if(c_transaction_type is not null))): '|| c_proc,15);
          l_current_forward_to_username:=   Wf_engine.GetItemAttrText(itemtype => p_item_type
                                                                     ,itemkey  => p_item_key
                                                                     ,aname    => 'HR_APR_NAME_ATTR');
        l_curr_fwd_to_orig_system_id :=wf_engine.getItemAttrNumber
                               (itemtype    => p_item_type
                              ,itemkey     => p_item_key
                              ,aname       => 'HR_APR_ORIG_SYSTEM_ID_ATTR');
            if(l_curr_fwd_to_orig_system_id is not null) then

		 if g_debug then
		    hr_utility.set_location('calling  ame_api2.updateApprovalStatus2', 2);
		    hr_utility.set_location('c_application_id:'|| c_application_id, 3);
		    hr_utility.set_location('c_transaction_type:'|| c_transaction_type, 4);
		    hr_utility.set_location('c_transaction_id:'|| c_transaction_id, 5);
		    hr_utility.set_location('approvalStatusIn:'|| ame_util.notifiedStatus, 6);
		    hr_utility.set_location('approverNameIn:'|| l_current_forward_to_username, 7);
                 end if;

	         ame_api2.updateApprovalStatus2(applicationIdIn=>c_application_id,
                                   transactionTypeIn =>c_transaction_type,
                                   transactionIdIn=>c_transaction_id,
                                   approvalStatusIn =>ame_util.notifiedStatus,
                                   approverNameIn =>l_current_forward_to_username,
                                   itemClassIn => wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_APR_ITEM_CLASS_ATTR'),
                                   -- HR_APR_ITEM_ID_ATTR
                                   itemIdIn =>wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_APR_ITEM_ID_ATTR'),
                                   -- HR_APR_ACTION_TYPE_ID_ATTR
                                   actionTypeIdIn=> wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_APR_ACTION_TYPE_ID_ATTR'),
                                   -- HR_APR_GRPORCHN_ID_ATTR
                                   groupOrChainIdIn =>wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_APR_GRPORCHN_ID_ATTR'),
                                   occurrenceIn =>null,
                                   forwardeeIn =>ame_util.emptyApproverRecord2,
                                  updateItemIn =>false);
            end if;
         result := wf_engine.eng_trans_default;
       else
         null;
       end if;
     end if;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
     if g_debug then
       hr_utility.set_location('Error in  flagApproversAsNotified SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
    raise;
end flagApproversAsNotified;



procedure updateNoResponseStatus( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'updateNoResponseStatus';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;

begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
   if ( funmode = wf_engine.eng_run ) then
       -- check if it is AME or custom approvals
       c_application_id :=nvl(wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR'),800);

       c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');

       c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');
       if(c_transaction_type is not null) then
         hr_utility.set_location('In(if ( if(c_transaction_type is not null))): '|| c_proc,15);
          l_current_forward_to_username:=   Wf_engine.GetItemAttrText(itemtype => p_item_type
                                                                     ,itemkey  => p_item_key
                                                                     ,aname    => 'FORWARD_TO_USERNAME');
		if g_debug then
		    hr_utility.set_location('calling  ame_api2.updateApprovalStatus2', 2);
		    hr_utility.set_location('c_application_id:'|| c_application_id, 3);
		    hr_utility.set_location('c_transaction_type:'|| c_transaction_type, 4);
		    hr_utility.set_location('c_transaction_id:'|| c_transaction_id, 5);
		    hr_utility.set_location('approvalStatusIn:'|| ame_util.noResponseStatus, 6);
		    hr_utility.set_location('approverNameIn:'|| l_current_forward_to_username, 7);
                 end if;

	       ame_api2.updateApprovalStatus2(applicationIdIn=>c_application_id,
                                   transactionTypeIn =>c_transaction_type,
                                   transactionIdIn=>c_transaction_id,
                                   approvalStatusIn =>ame_util.noResponseStatus,
                                   approverNameIn =>l_current_forward_to_username,
                                   itemClassIn => null,
                                   itemIdIn =>null,
                                   actionTypeIdIn=> null,
                                   groupOrChainIdIn =>null,
                                   occurrenceIn =>null,
                                   forwardeeIn =>ame_util.emptyApproverRecord2,
                                  updateItemIn =>false);

         result := wf_engine.eng_trans_default;
       else
         result := wf_engine.eng_trans_default;
       end if;
     pqh_ss_workflow.set_txn_approve_status(p_item_type,p_item_key,p_act_id,funmode,result);
     end if;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
     result := wf_engine.eng_trans_default;
	   return;
end updateNoResponseStatus;

procedure setRespondedUserContext( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
 -- local variables
  c_proc constant varchar2(30) := 'setRespondedUserContext';

 begin
   g_debug := hr_utility.debug_enabled;

   if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
   end if;

   if ( funmode = 'RESPOND' ) then
     create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_NID_ATTR',
                      text_value=>null,
                      number_value=>wf_engine.context_nid,
                      date_value=>null);
     create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_USER_ATTR',
                      text_value=>wf_engine.context_user,
                      number_value=>null,
                      date_value=>null);
     create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_RECIPIENT_ROLE_ATTR',
                      text_value=>wf_engine.context_recipient_role,
                      number_value=>null,
                      date_value=>null);

     create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_ORIG_RECIPIENT_ATTR',
                      text_value=>wf_engine.context_original_recipient,
                      number_value=>null,
                      date_value=>null);

     create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_FROM_ROLE_ATTR',
                      text_value=>wf_engine.context_from_role,
                      number_value=>null,
                      date_value=>null);
    create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_NEW_ROLE_ATTR',
                      text_value=>wf_engine.context_new_role,
                      number_value=>null,
                      date_value=>null);
    create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_MORE_INFO_ROLE_ATTR',
                      text_value=>wf_engine.context_more_info_role,
                      number_value=>null,
                      date_value=>null);
    create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_USER_KEY_ATTR',
                      text_value=>wf_engine.context_user_key,
                      number_value=>null,
                      date_value=>null);

    create_item_attrib_if_notexist(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_CONTEXT_PROXY_ATTR',
                      text_value=>wf_engine.context_proxy,
                      number_value=>null,
                      date_value=>null);

     result := 'COMPLETE';
     return;
   end if;

   if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
   end if;



 exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  setRespondedUserContext SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
    raise;
 end setRespondedUserContext;

procedure submit_for_approval( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'submit_for_approval';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   lv_transaction_status varchar2(100);
   lv_approval_required varchar2(100);
   lv_result varchar2(100);
   lv_comments wf_item_attribute_values.text_value%type;

begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
   if ( funmode = wf_engine.eng_run ) then
     -- Creating attribute to check the new transaction
       create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_NEW_TRANSACTION'
                              ,text_value=>'TIMEOUT ^ APPROVETWICE' --bug 5414392
                               ,number_value=>null,
                               date_value=>null
                               );
    -- check if the transaction needs to be submitted for approval
    -- get the transaction status
    lv_transaction_status:=wf_engine.getItemAttrText(itemtype=> p_item_type,
                                                     itemkey => p_item_key,
                                                     aname   => 'TRAN_SUBMIT');
     if(lv_transaction_status<>'Y') then
      -- result := 'COMPLETE:'||'E';
      --return;
       raise g_transaction_status_invalid;
     end if;
     if(lv_transaction_status='Y') then
         lv_approval_required:= wf_engine.GetItemAttrText(itemtype => p_item_type,
                                          itemkey  => p_item_key,
                                          aname    => 'HR_RUNTIME_APPROVAL_REQ_FLAG');
         lv_approval_required := nvl(lv_approval_required,'N0');
         if(lv_approval_required in ('YES_DYNAMIC','YES','Y','YD')) then

           -- call the other intialization routines needed for approval
           -- notification process
           -- PQH_SS_HISTORY.transfer_submit_to_history
	      if g_debug then
                 hr_utility.set_location('calling PQH_SS_HISTORY.transfer_submit_to_history', 2);
		 hr_utility.set_location('p_item_type:'|| p_item_type, 3);
		 hr_utility.set_location('p_item_key:'|| p_item_key, 4);
              end if;
            --  PQH_SS_HISTORY.transfer_submit_to_history(p_item_type,p_item_key,p_act_id,funmode,result);
            -- use the new history API's
             -- add the code plugin transfer history
             c_transaction_id := wf_engine.getitemattrnumber(p_item_type,p_item_key,'TRANSACTION_ID');
             lv_comments     := wf_engine.getitemattrtext(p_item_type,p_item_key,'APPROVAL_COMMENT_COPY');
             hr_trans_history_api.archive_submit(c_transaction_id,
                                                  null,
                                                  fnd_global.user_name,
                                                  lv_comments);

           -- HR_APPROVAL_WF.INITIALIZE_ITEM_ATTRIBUTES
	      if g_debug then
                 hr_utility.set_location('calling HR_APPROVAL_WF.INITIALIZE_ITEM_ATTRIBUTES', 5);
		 hr_utility.set_location('p_item_type:'|| p_item_type, 6);
		 hr_utility.set_location('p_item_key:'|| p_item_key, 7);
              end if;

	      HR_DYNAMIC_APPROVAL_WEB.INITIALIZE_ITEM_ATTRIBUTES(p_item_type,p_item_key,null,wf_engine.eng_run,lv_result);
              HR_APPROVAL_WF.INITIALIZE_ITEM_ATTRIBUTES(p_item_type,p_item_key,p_act_id,funmode,result);

          -- PQH_SS_WORKFLOW.set_image_source
	     if g_debug then
                 hr_utility.set_location('calling PQH_SS_WORKFLOW.set_image_source', 8);
		 hr_utility.set_location('p_item_type:'|| p_item_type, 9);
		 hr_utility.set_location('p_item_key:'|| p_item_key, 10);
              end if;

             PQH_SS_WORKFLOW.set_image_source(p_item_type,p_item_key,p_act_id,funmode,result);
             result := 'COMPLETE:'||'Y';
         end if;

      else
        result := 'COMPLETE:'||'N';

      end if;

   end if;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  submit_for_approval SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
    raise;
end submit_for_approval;


procedure setSFLResponseContext( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'setSFLResponseContext';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   lv_result_code WF_ITEM_ACTIVITY_STATUSES.activity_result_code%type;
   lv_result_display varchar2(250);

begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

   handleArchive(p_item_type,
                   p_item_key,
                   p_act_id,
                   funmode,
                   result);

    if g_debug then
       hr_utility.set_location('returning with the  result'||result,8);
    end if;


  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
  end if;

exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  setSFLResponseContext SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
    raise;
end setSFLResponseContext;

procedure setRFCResponseContext( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'setRFCResponseContext';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   lv_result_code WF_ITEM_ACTIVITY_STATUSES.activity_result_code%type;
   lv_result_display varchar2(250);

begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

     --sturlapa coding starts for bug 3866581
     begin
        select text_value
        into lv_result_code
        from wf_notification_attributes
        where notification_id=wf_engine.context_nid
        and name='RESULT';

         if(funmode='RESPOND' and lv_result_code='RESUBMIT') Then

               WF_ENGINE.SetItemAttrText(p_item_type,p_item_key,'WF_NOTE',wf_engine.GetItemAttrText( p_item_type
                  	                                    ,p_item_key
                                                       ,'APPROVAL_COMMENT_COPY'));

         end if;

     exception
      when others then
        null;
     end;
     --sturlapa coding ends for bug 3866581

     handleArchive(p_item_type,
                   p_item_key,
                   p_act_id,
                   funmode,
                   result);
    if g_debug then
       hr_utility.set_location('returning with the  result'||result,8);
    end if;




  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
  end if;

exception
  when others then
  if g_debug then
       hr_utility.set_location('Error in  setRFCResponseContext SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
    raise;
end setRFCResponseContext;

--bug 5414392

procedure setNtfTransferCtx( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'setNtfTransferCtx';
   -- Variables required for AME API
   l_forward_to_person_id              per_people_f.person_id%type;
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   rec_forwardee ame_util.approverRecord2;

   l_new_fwd_person_id per_people_f.person_id%type;
   l_new_orig_system varchar2(30);
   l_new_fwd_display_name varchar2(360);

   cursor get_person_info is
   select orig_system,orig_system_id,display_name from wf_roles where name = wf_engine.context_new_role;

  /* cursor get_name_info is
   select last_name,first_name from per_all_people_f where
   person_id = l_new_fwd_person_id;*/

begin

       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);

   if ( funmode = 'TRANSFER' ) then
       -- TRANSFER - When a notification recipient transfers the notification.
       -- check if it is AME or custom approvals
       c_application_id :=nvl(wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR'),800);

       c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');

       c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');

       if(c_transaction_type is not null) then
         hr_utility.set_location('In(if ( if(c_transaction_type is not null))): '|| c_proc,2);
          l_current_forward_to_username:=   Wf_engine.GetItemAttrText(itemtype => p_item_type
                                                                     ,itemkey  => p_item_key
                                                                     ,aname    => 'FORWARD_TO_USERNAME');
          l_current_forward_to_username := nvl(l_current_forward_to_username,wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'RETURN_TO_USERNAME'));
          if g_debug then
	    hr_utility.set_location('calling ame_api2.updateApprovalStatus2', 3);
	    hr_utility.set_location('c_application_id:'|| c_application_id, 4);
	    hr_utility.set_location('c_transaction_type:'|| c_transaction_type, 5);
	    hr_utility.set_location('approvalStatusIn:'|| ame_util.approvedStatus, 6);
	    hr_utility.set_location('approverNameIn:'|| l_current_forward_to_username, 7);
	    hr_utility.set_location('new approver:'|| wf_engine.context_new_role, 7);
	  end if;

	  begin

	  open get_person_info;
        fetch get_person_info into l_new_orig_system,l_new_fwd_person_id,l_new_fwd_display_name;
        CLOSe get_person_info;

rec_forwardee.name:= wf_engine.context_new_role;
rec_forwardee.orig_system :=l_new_orig_system;
rec_forwardee.orig_system_id :=l_new_fwd_person_id;
rec_forwardee.display_name :=l_new_fwd_display_name;
--rec_forwardee.api_insertion:='Y';

hr_utility.set_location('new approver person id:'|| l_new_fwd_person_id, 7);



    ame_api2.updateApprovalStatus2(applicationIdIn=>c_application_id,
                                   transactionTypeIn =>c_transaction_type,
                                   transactionIdIn=>c_transaction_id,
                                   approvalStatusIn =>ame_util.forwardStatus,
                                   approverNameIn =>l_current_forward_to_username,
                                   itemClassIn => null,
                                   itemIdIn =>null,
                                   actionTypeIdIn=> null,
                                   groupOrChainIdIn =>null,
                                   occurrenceIn =>null,
                                   forwardeeIn =>rec_forwardee,
                                  updateItemIn =>false);

   --reset wf attributes

wf_engine.setItemAttrNumber(p_item_type,p_item_key,'FORWARD_TO_PERSON_ID',rec_forwardee.orig_system_id);
wf_engine.setItemAttrText(p_item_type,p_item_key,'FORWARD_TO_USERNAME',wf_engine.context_new_role);
wf_engine.setItemAttrText(p_item_type,p_item_key,'FORWARD_TO_DISPLAY_NAME',wf_directory.GetRoleDisplayName(wf_engine.context_new_role));

   if g_debug then
       hr_utility.set_location('calling ame_api2.getNextApprovers4 ',4);
       hr_utility.set_location('c_application_id:'||c_application_id,5);
       hr_utility.set_location('c_transaction_type:'|| c_transaction_type,6);
       hr_utility.set_location('c_transaction_id:'|| c_transaction_id,7);
       hr_utility.set_location('flagApproversAsNotifiedIn:'|| ame_util.booleanFalse,8);
   end if;

    ame_api2.getNextApprovers4
    (applicationIdIn  => c_application_id
    ,transactionTypeIn => c_transaction_type
    ,transactionIdIn => c_transaction_id
    ,flagApproversAsNotifiedIn=>ame_util.booleanFalse
    ,approvalProcessCompleteYNOut => c_approvalprocesscompleteynout
    ,nextApproversOut => c_next_approvers);


      exception
	  when others then
	     if g_debug then
                hr_utility.set_location('Error in  updateApproveStatus SQLERRM' ||' '||to_char(SQLCODE),10);
             end if;

	     result := 'COMPLETE:' || 'ERROR';
             return;
          end ;

         if g_debug then
	    hr_utility.set_location('returned from calling ame_api2.updateApprovalStatus2', 8);
        end if;



         result := wf_engine.eng_trans_default;
       else
         null;
       end if;


     end if;


      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 20);
-- hr_utility.trace_off;
exception
  when others then

                hr_utility.set_location('Error in  setNtfTransferCtx SQLERRM' ||' '||to_char(SQLCODE),30);

    raise;
end setNtfTransferCtx;


procedure setApproverResponseContext( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'setApproverResponseContext';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   lv_result_code WF_ITEM_ACTIVITY_STATUSES.activity_result_code%type;
   lv_result_display varchar2(250);
   lv_test_result_code varchar2(250);
   lv_comments wf_item_attribute_values.text_value%type;
   lv_new_transaction varchar2(240);

begin
   g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;

   -- capture the approver login context information
   if ( funmode = 'RESPOND' ) then
       hr_approval_ss.setrespondedusercontext(p_item_type,p_item_key,p_act_id,funmode,result);
   end if;

-- bug 5414392

   if ( funmode = 'TRANSFER' ) then
       lv_new_transaction := wf_engine.getitemattrtext(p_item_type,
                                                p_item_key,
                                                'HR_NEW_TRANSACTION',true);

    if( INSTR(lv_new_transaction,'APPROVETWICE') > 0) then
       setNtfTransferCtx(p_item_type,p_item_key,p_act_id,funmode,result);
       end if;
   end if;
    -- archive the user action
   handleArchive(p_item_type,
                   p_item_key,
                   p_act_id,
                   funmode,
                   result);


   if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  setRFCResponseContext SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;

    raise;
end setApproverResponseContext;


procedure reset_ame_to_rfc_state(p_item_type in varchar2,
  p_item_key      in varchar2)
is
-- Variables required for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_all_approvers ame_util.approverstable2;--ame_util.approversTable;
c_approvalprocesscompleteynout ame_util.charType;

c_creator_user   wf_users.name%Type;
c_return_user    wf_users.name%Type;
c_match_found    varchar2(1);
c_rfc_initiator  varchar2(1);
notification_rec ame_util2.notificationRecord;

l_proc constant varchar2(100) := g_package || ' reset_ame_to_rfc_state';
begin

g_debug := hr_utility.debug_enabled;
c_match_found      := 'N';

IF g_debug THEN
  hr_utility.set_location('Entering:'||l_proc, 1);
END IF;
    c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                  itemkey  => p_item_key,
                                                  aname => 'TRANSACTION_ID',
                                                  ignore_notfound=>true);
    c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR',
                                               ignore_notfound=>true);
    c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                 itemkey  => p_item_key,
                                                 aname => 'HR_AME_APP_ID_ATTR',
                                                 ignore_notfound=>true);
    c_application_id := nvl(c_application_id,800);

	notification_rec.notification_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_CONTEXT_NID_ATTR');
	notification_rec.user_comments :=  wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'NOTE_FROM_APPR');

    if(c_transaction_type is not null) then
        if g_debug then
		    hr_utility.set_location('calling  ame_api2.getAllApprovers7', 2);
		    hr_utility.set_location('c_application_id:'|| c_application_id, 3);
		    hr_utility.set_location('c_transaction_type:'|| c_transaction_type, 4);
		    hr_utility.set_location('c_transaction_id:'|| c_transaction_id, 5);
        end if;

        ame_api2.getAllApprovers7(applicationIdIn =>c_application_id,
                             transactionTypeIn =>c_transaction_type,
                             transactionIdIn => c_transaction_id,
                             approvalProcessCompleteYNOut =>c_approvalprocesscompleteynout,
                             approversOut =>c_all_approvers);
        c_creator_user   := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'CREATOR_PERSON_USERNAME');
        c_return_user    := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'RETURN_TO_USERNAME',
                                               ignore_notfound=>true);
        IF ( c_return_user IS NULL OR c_creator_user = c_return_user ) THEN
        c_rfc_initiator := 'Y';
        ELSE
        c_rfc_initiator := 'N';
        END IF;

        for i in 1..c_all_approvers.count loop
            IF ( c_rfc_initiator = 'N' AND c_return_user = c_all_approvers(i).name ) THEN
                c_match_found  := 'Y';
            END IF;
            IF (c_rfc_initiator = 'Y' OR (c_rfc_initiator = 'N' AND c_match_found = 'Y' ) ) THEN
	      if g_debug then
		    hr_utility.set_location('calling  ame_api2.updateApprovalStatus2', 2);
		    hr_utility.set_location('c_application_id:'|| c_application_id, 3);
		    hr_utility.set_location('c_transaction_type:'|| c_transaction_type, 4);
		    hr_utility.set_location('c_transaction_id:'|| c_transaction_id, 5);
		    hr_utility.set_location('approvalStatusIn:'|| null, 6);
		    hr_utility.set_location('approverNameIn:'|| c_all_approvers(i).name, 7);
                 end if;

            ame_api6.updateApprovalStatus2(applicationIdIn=>c_application_id,
                                   transactionTypeIn =>c_transaction_type,
                                   transactionIdIn=>c_transaction_id,
                                   approvalStatusIn =>null,
                                   approverNameIn =>c_all_approvers(i).name,
                                   itemClassIn => c_all_approvers(i).ITEM_CLASS,
                                   itemIdIn =>c_all_approvers(i).ITEM_ID,
                                   actionTypeIdIn=> c_all_approvers(i).ACTION_TYPE_ID,
                                   groupOrChainIdIn =>c_all_approvers(i).GROUP_OR_CHAIN_ID,
                                   occurrenceIn =>c_all_approvers(i).OCCURRENCE,
                                   notificationIn => notification_rec,
                                   forwardeeIn =>ame_util.emptyApproverRecord2,
                                   updateItemIn =>false);
            end if;

        end loop;
    end if;

IF g_debug THEN
  hr_utility.set_location('Leaving:'|| l_proc, 35);
END IF;

EXCEPTION
when others then
hr_utility.set_location('EXCEPTION: '|| l_proc,560);
  hr_utility.trace(' exception in  '||l_proc||' : ' || sqlerrm);

  Wf_Core.Context(g_package, l_proc, p_item_type, p_item_key);
    raise;
end reset_ame_to_rfc_state;

procedure reset_approval_rfc_data(p_item_type in varchar2,
  p_item_key      in varchar2) is

 -- local variables
  c_proc constant varchar2(60) := 'reset_approval_rfc_data';
  c_return_user    wf_users.name%Type;
  c_creator_user   wf_users.name%Type;
  l_approvalProcessVersion varchar2(10);
  l_curr_approver_role wf_roles.name%type;
  c_return_user_role_info_tbl wf_directory.wf_local_roles_tbl_type;
  l_curr_approver_role_info_tbl wf_directory.wf_local_roles_tbl_type;

begin
   g_debug := hr_utility.debug_enabled;
   if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
   end if;

   -- functional logic
   -- case : notification sent to M3 for approval
   --        M3 RFC to M1 or M0(initiating Manager)
   --        All FORWARD_TO should refelect M1 or M0
   --        All FORWARD_FROM should reflect M3

   -- reset the AME approval state
   reset_ame_to_rfc_state(p_item_type,p_item_key);

   -- reset the item attrtibutes
   c_return_user:= wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'RETURN_TO_USERNAME',
                                               ignore_notfound=>true);
   c_creator_user   := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'CREATOR_PERSON_USERNAME');

   c_return_user := nvl(c_return_user,c_creator_user);

   -- get the return to user orig system and sys id
   wf_directory.GetRoleInfo2(c_return_user,c_return_user_role_info_tbl);

   l_curr_approver_role :=wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'FORWARD_TO_USERNAME',
                                               ignore_notfound=>true);
   ---- get the current approver orig system and sys id

       wf_directory.GetRoleInfo2(l_curr_approver_role,l_curr_approver_role_info_tbl);

   -- FORWARD_FROM_DISPLAY_NAME
      -- set the attribute value to null
      create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_FROM_DISPLAY_NAME'
                               ,text_value=>l_curr_approver_role_info_tbl(1).display_name
                               ,number_value=>null,
                               date_value=>null
                               );

       -- FORWARD_FROM_USERNAME
       -- set the attribute value to null
         create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_FROM_USERNAME'
                               ,text_value=>l_curr_approver_role
                               ,number_value=>null,
                               date_value=>null
                               );


   -- FORWARD_FROM_PERSON_ID
     create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_FROM_PERSON_ID'
                               ,text_value=>null
                               ,number_value=>l_curr_approver_role_info_tbl(1).orig_system_id,
                               date_value=>null
                               );
   -- FORWARD_TO_DISPLAY_NAME
     create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_DISPLAY_NAME'
                               ,text_value=>c_return_user_role_info_tbl(1).display_name
                               ,number_value=>null,
                               date_value=>null
                               );

   -- FORWARD_TO_USERNAME
     create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_USERNAME'
                               ,text_value=>c_return_user
                               ,number_value=>null,
                               date_value=>null
                               );

   -- FORWARD_TO_PERSON_ID
     create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_PERSON_ID'
                               ,text_value=>null
                               ,number_value=>c_return_user_role_info_tbl(1).orig_system_id,
                               date_value=>null
                               );

   create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_FROM_ORIG_SYS_ATTR'
                               ,text_value=>l_curr_approver_role_info_tbl(1).orig_system
                               ,number_value=>null,
                               date_value=>null
                               );

     create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_TO_ORIG_SYS_ATTR'
                               ,text_value=>c_return_user_role_info_tbl(1).orig_system
                               ,number_value=>null,
                               date_value=>null
                               );

 /* Bug 2940951: No need to reset current approver index and last default approver in case
 * new approval process is used and the non-AME approval is used
 * as the two attributes are set when pqh_ss_workflow.return_for_correction is invoked.
 * CAUTION: IF this procedure is invoked from somewhere else (apart from RFC) then this needs
 * to be checked for that condition too.
 */

     l_approvalProcessVersion := wf_engine.GetItemAttrText(
                                   itemtype => p_item_Type,
                                   itemkey  => p_item_Key,
                                   aname    => 'HR_APPROVAL_PRC_VERSION',
                                   ignore_notfound=>true);

    IF  ( NVL(l_approvalProcessversion,'X') <> 'V5' OR
         wf_engine.GetItemAttrText(
             itemtype => p_item_Type, itemkey => p_item_Key,
                         aname => 'HR_AME_TRAN_TYPE_ATTR') IS NOT NULL) THEN

    -- CURRENT_APPROVER_INDEX
      create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'CURRENT_APPROVER_INDEX'
                               ,text_value=>null
                               ,number_value=>null,
                               date_value=>null
                               );
    -- 'LAST_DEFAULT_APPROVER'
      create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'LAST_DEFAULT_APPROVER'
                               ,text_value=>null
                               ,number_value=>null,
                               date_value=>null
                               );
   END IF;
   -- CURRENT_DEF_APPR_INDEX
     create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'CURRENT_DEF_APPR_INDEX'
                               ,text_value=>null
                               ,number_value=>0,
                               date_value=>null
                               );

   if (g_debug ) then
     hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
   end if;

exception
when others then
   if g_debug then
       hr_utility.set_location('Error in  reset_approval_rfc_data SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
  raise;
end reset_approval_rfc_data;



procedure processRFC( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'processRFC';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(25);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   lv_creatorUserName wf_roles.name%type;
   lv_rfcUserName     wf_roles.name%type;
   lv_customRFC       varchar2(5);

   lv_dynamicQuery varchar2(4000) ;
   lv_queryProcedure varchar2(4000);
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
   if ( funmode = wf_engine.eng_run ) then

   PQH_SS_WORKFLOW.set_txn_rfc_status(p_item_type,p_item_key,p_act_id,funmode,result);
     -- fix for bug 4454439
    begin
      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>p_item_type
                                          ,p_item_key=>p_item_key);

      if hr_workflow_ss.getOrganizationManagersubject(p_item_type,p_item_key) is not null then
          wf_engine.setItemAttrText (
            itemtype => p_item_type
           ,itemkey  => p_item_Key
           ,aname    => 'CURRENT_PERSON_DISPLAY_NAME'
           ,avalue   => hr_workflow_ss.getOrganizationManagersubject(p_item_type,p_item_key));
      end if;
    exception
    when others then
      null;
    end;

    -- check if we have product overwrite which does not allow RFC and
    -- action would default to delete the transaction
    -- HR_CUSTOM_RETURN_FOR_CORR
      if g_debug then
        hr_utility.set_location('checking product specific custom RFC',2);
      end if;
      lv_customRFC:=wf_engine.getitemattrtext(p_item_type,p_item_key,'HR_CUSTOM_RETURN_FOR_CORR',true);
      lv_customRFC:= nvl(lv_customRFC,'N');
      if g_debug then
        hr_utility.set_location('lv_customRFC:'||lv_customRFC,3);
      end if;

      if(lv_customRFC='Y') then
      -- no more processing return to delete the transaction
        result := wf_engine.eng_completed||':N';
        return;
      end if;

    -- call PQH_SS_HISTORY.transfer_approval_to_history
       if g_debug then
        hr_utility.set_location('calling  PQH_SS_WORKFLOW.set_txn_rfc_status',3);
	hr_utility.set_location('p_item_type:'|| p_item_type,4);
	hr_utility.set_location('p_item_key:'|| p_item_key,5);
      end if;

      PQH_SS_WORKFLOW.set_txn_rfc_status(p_item_type,p_item_key,p_act_id,funmode,result);

      if g_debug then
        hr_utility.set_location('calling  reset_approval_rfc_data',6);
	hr_utility.set_location('p_item_type:'|| p_item_type,7);
	hr_utility.set_location('p_item_key:'|| p_item_key,8);
      end if;

       begin
      	reset_approval_rfc_data(p_item_type,p_item_key);
       exception
    	when others then

    	handleApprovalErrors(p_item_type, p_item_key, sqlerrm);
   	result := 'COMPLETE:'||'ERROR';
   	return;

   	end;



      --
    begin
    -- finally see if we have any module specific call backs
    -- 'HR_RFC_CB_ATTR'
    lv_queryProcedure := wf_engine.getitemattrtext(p_item_type,p_item_key,'HR_RFC_CB_ATTR',true);

    if(lv_queryProcedure is not null  or lv_queryProcedure<>'') then

       if g_debug then
      hr_utility.set_location('Calling queryProcedure: '||lv_queryProcedure, 20);
      hr_utility.set_location('p_item_type: '|| p_item_type, 21);
      hr_utility.set_location('p_item_key: '|| p_item_key, 22);
      hr_utility.set_location('p_act_id: '|| p_act_id, 23);
    end if;

    lv_dynamicQuery :=
        'begin ' ||
        lv_queryProcedure ||
        '(:itemTypeIn, :itemKeyIn, :actIdIn, :funmodeIn, :resultOut); end;';
      execute immediate lv_dynamicQuery
        using
          in p_item_type,
          in p_item_key,
          in p_act_id,
          in funmode,
          in out result;
    if g_debug then
      hr_utility.set_location('After queryProcedure: '|| lv_queryProcedure, 40);
      hr_utility.set_location('result: '|| result, 41);
    end if;

    end if;
    exception
    when others then
     null; -- raise ???
    end;

    -- check if the RFC is to Initiator or Approver
    -- CREATOR_PERSON_USERNAME
       lv_creatorUserName:=wf_engine.getitemattrtext(p_item_type,p_item_key,'CREATOR_PERSON_USERNAME',true);
    -- RETURN_TO_USERNAME
        lv_rfcUserName:=wf_engine.getitemattrtext(p_item_type,p_item_key,'RETURN_TO_USERNAME',true);
      -- Compare

    if (lv_creatorUserName is null or lv_rfcUserName is null) then
      result := wf_engine.eng_completed||':YES_APPROVER';
    elsif (lv_creatorUserName < lv_rfcUserName) then
      result := wf_engine.eng_completed||':YES_APPROVER';
    elsif (lv_creatorUserName > lv_rfcUserName) then
      result := wf_engine.eng_completed||':YES_APPROVER';
    elsif (lv_creatorUserName = lv_rfcUserName) then
      result := wf_engine.eng_completed||':YES_INIT';
    end if;

     if g_debug then
        hr_utility.set_location('leaving with resultcode :'|| result,9);
      end if;


   end if;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  processRFC SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
    raise;
end processRFC;


function getRoleDisplayName(p_user_name  in varchar2,
                            p_orig_system  in varchar2,
                            p_orig_system_id  in number)
  return varchar2 is
-- local variables
   c_proc constant varchar2(30) := 'processRFC';
   lv_role_displayName  wf_users.display_name%type;
   lv_roleName          wf_users.name%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
  if(p_orig_system is null or p_orig_system_id is null) then
    lv_role_displayName :=wf_directory.getroledisplayname(p_user_name);
  else
   wf_directory.GetRoleName
         (p_orig_system       => p_orig_system
         ,p_orig_system_id    => p_orig_system_id
         ,p_name              => lv_roleName
         ,p_display_name      => lv_role_displayName);
   end if;
  return lv_role_displayName;
exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  getRoleDisplayName SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;

end getRoleDisplayName;


function isApproverEditAllowed(p_transaction_id number default null,
                            p_user_name  in varchar2,
                            p_orig_system  in varchar2,
                            p_orig_system_id  in number)
  return varchar2 is
-- local variables
   c_proc constant varchar2(30) := 'isApproverEditAllowed';
   lv_role_displayName  wf_users.display_name%type;
   lv_roleName          wf_users.name%type;
   lv_businessGroupId   per_all_people_f.business_group_id%type;
   lv_orig_systemId     wf_roles.orig_system_id%type;
   lv_orig_system       wf_roles.orig_system%type;
   lv_creator_person_id hr_api_transactions.creator_person_id%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
  lv_orig_system   := p_orig_system;
  lv_orig_systemId := p_orig_system_id;

  if(p_orig_system_id is null) then
    if(p_user_name is not null) then
     wf_directory.getroleorigsysinfo(p_user_name,lv_orig_system,lv_orig_systemId);
    end if;
  end if;

  -- need to revisit the functionality once the AME functionality
  -- regarding the productions is evaluated.
  if(lv_orig_system is not null and lv_orig_system ='PER') then
    --
    -- check the case for creator person id
    begin
      select creator_person_id
      into lv_creator_person_id
      from hr_api_transactions
      where transaction_id=p_transaction_id;

      if(lv_creator_person_id=lv_orig_systemId) then
        return 'Y';
      end if;
    exception
    when others then
     null;
    end;

    begin
      select business_group_id
      into lv_businessGroupId
      from per_all_people_f
      where person_id=p_orig_system_id
      and sysdate between effective_start_date and effective_end_date;
      return pqh_ss_utility.check_edit_privilege(p_orig_system_id,lv_businessGroupId);
   exception
   when others then
    return 'N';
   end;
  else
    return 'N';
  end if;

exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  getRoleDisplayName SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;

end isApproverEditAllowed;

function getuserOrigSystem(p_user_name in fnd_user.user_name%type,p_notification_id in number default null)
return wf_roles.parent_orig_system%type is
-- local variables
   c_proc constant varchar2(30) := 'getuserOrigSystem';
   lv_orig_system  wf_roles.parent_orig_system%type;
   lv_orig_system_id wf_roles.orig_system_id%type;
   lv_user_name wf_roles.name%type;
begin
g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
  if(p_notification_id is null) then
    wf_directory.getroleorigsysinfo(p_user_name,lv_orig_system,lv_orig_system_id);
  else
    -- get the original recipient role name
    select original_recipient
    into lv_user_name
    from wf_notifications
    where notification_id =p_notification_id;

    wf_directory.getroleorigsysinfo(lv_user_name,lv_orig_system,lv_orig_system_id);
    end if;

  return lv_orig_system;

exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  getRoleDisplayName SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;

end getuserOrigSystem;

function getUserOrigSystemId(p_user_name in fnd_user.user_name%type,p_notification_id in number default null)
return wf_roles.orig_system_id%type is
-- local variables
   c_proc constant varchar2(30) := 'getUserOrigSystemId';
   lv_orig_system  wf_roles.parent_orig_system%type;
   lv_orig_system_id wf_roles.orig_system_id%type;
   lv_user_name wf_roles.name%type;
begin
g_debug := hr_utility.debug_enabled;
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
  if(p_notification_id is null) then
    wf_directory.getroleorigsysinfo(p_user_name,lv_orig_system,lv_orig_system_id);
  else
    -- get the original recipient role name
    select original_recipient
    into lv_user_name
    from wf_notifications
    where notification_id =p_notification_id;

    wf_directory.getroleorigsysinfo(lv_user_name,lv_orig_system,lv_orig_system_id);
    end if;

  return lv_orig_system_id;

exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  getUserOrigSystemId SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;

end getUserOrigSystemId;


procedure handleRFCAction(p_approval_notification_id in wf_notifications.notification_id%type,
                          p_transaction_id in hr_api_transactions.transaction_id%type,
                          p_item_type in wf_items.item_type%type,
                          p_item_key  in wf_items.item_key%type,
                          p_rfcRoleName in wf_roles.name%type,
                          p_rfcUserOrigSystem in wf_roles.orig_system%type,
                          p_rfcUserOrigSystemId in wf_roles.orig_system_id%type,
                          p_rfc_comments in varchar2,
                          p_approverIndex in number
                          ) is
  -- local variables
   c_proc constant varchar2(30) := 'handleRFCAction';
   ln_rfc_notification_id wf_notifications.notification_id%type;
   l_lastDefaultApprover NUMBER;
   lv_dummy  varchar2(10);
   lv_role_name wf_roles.name%type;
   lv_role_disp_name wf_roles.name%type;
   l_return_status varchar2(10);
   lv_role_orig_sys_id wf_roles.orig_system_id%type;

   -- Cursor to find if the person (selected for RFC) is an additional approver
   CURSOR cur_add_appr IS
   SELECT 'X'
     FROM wf_item_attribute_values
    WHERE item_type = p_item_Type
      AND item_key  = p_item_Key
      AND name      like 'ADDITIONAL_APPROVER_%'
      AND number_value = p_rfcUserOrigSystemId;
  --
  -- Cursor to fetch the last default approver below the person performing
  -- RFC. It is used only in case of NON-AME approvals.
  --
  CURSOR  cur_appr  IS
  SELECT pth.employee_id
    FROM pqh_ss_approval_history pah,
         fnd_user pth
   WHERE pah.user_name = pth.user_name
     AND pah.transaction_history_id = p_transaction_id
     AND approval_history_id = (
      SELECT MAX(approval_history_id)
        FROM pqh_ss_approval_history  pah1,
             fnd_user pth1
       WHERE pah1.user_name = pth1.user_name
         AND pah1.transaction_history_id = pah.transaction_history_id
         AND pth1.employee_id IN (
           SELECT pth2.employee_id --, pth2.user_name, approval_history_id
             FROM pqh_ss_approval_history pah2,
                  fnd_user                pth2
            WHERE pah2.user_name = pth2.user_name
              AND pah2.transaction_history_id = pah.transaction_history_id
              AND approval_history_id < (
               SELECT MIN(approval_history_id)
                 FROM pqh_ss_approval_history
                WHERE transaction_history_id = pah.transaction_history_id
                  AND user_name = lv_role_name
                  AND approval_history_id > 0
               )
           and approval_history_id > 0
           MINUS
           SELECT number_value
             FROM wf_item_attribute_values
            WHERE item_type = p_item_Type
              AND item_key  = p_item_Key
              AND name      like 'ADDITIONAL_APPROVER_%'
      )
    );

begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;



  -- fix for bug 4481775
    begin
      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>p_item_type
                                          ,p_item_key=>p_item_key);
     wf_directory.GetRoleName--GetUserName
         (p_orig_system       => p_rfcUserOrigSystem
         ,p_orig_system_id    => p_rfcUserOrigSystemId
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);

    exception
    when others then
      null;
    end;

  -- set the item attributes used for RFC notification
  create_item_attrib_if_notexist(itemtype=>p_item_Type,
                      itemkey =>p_item_Key,
                      aname =>'RETURN_TO_USERNAME',
                      text_value =>lv_role_name,
                      number_value=>null,
                      date_value =>null );

  create_item_attrib_if_notexist(itemtype=>p_item_Type,
                      itemkey =>p_item_Key,
                      aname =>'RETURN_TO_USER_ORIG_SYS',
                      text_value =>p_rfcUserOrigSystem,
                      number_value=>null,
                      date_value =>null );
  create_item_attrib_if_notexist(itemtype=>p_item_Type,
                      itemkey =>p_item_Key,
                      aname =>'RETURN_TO_USER_ORIG_SYS_ID',
                      text_value =>null,
                      number_value=>p_rfcUserOrigSystemId,
                      date_value =>null );
 -- 'RETURN_TO_PERSON_DISPLAY_NAME'
  create_item_attrib_if_notexist(itemtype=>p_item_Type,
                      itemkey =>p_item_Key,
                      aname =>'RETURN_TO_PERSON_DISPLAY_NAME',
                      text_value => lv_role_disp_name,
                      number_value=>null,
                      date_value =>null );

-- Set the notes for RFC notification.
-- NOTE_FROM_APPR
   wf_engine.setItemAttrText (
            itemtype => p_item_type
           ,itemkey  => p_item_Key
           ,aname    => 'NOTE_FROM_APPR'
           ,avalue   => p_rfc_comments );
   wf_engine.setItemAttrText (
            itemtype => p_item_type
           ,itemkey  => p_item_Key
           ,aname    => 'WF_NOTE'
           ,avalue   => null );


  -- code logic to complete the approval notification with
  -- RETURNEDFORCORRECTION result
  wf_notification.setattrtext(p_approval_notification_id,
                              'RESULT',
                              'RETURNEDFORCORRECTION');
       BEGIN
           wf_notification.setattrtext(
       			p_approval_notification_id
       		       ,'WF_NOTE'
       		       ,p_rfc_comments);
        EXCEPTION WHEN OTHERS THEN
           -- RFC from SFL Other
           wf_notification.propagatehistory(
                               p_item_type
                              ,p_item_key
                              ,'APPROVAL_NOTIFICATION'
                              ,fnd_global.user_name
                              ,lv_role_name
                              ,'RETURNEDFORCORRECTION'
                              ,null
                              ,p_rfc_comments);
       END;

      -- now respond to the approval notification
      wf_notification.respond(p_approval_notification_id
      		                 ,null
               		         ,fnd_global.user_name
      		                 ,null);

      hr_sflutil_ss.closeopensflnotification(p_transaction_id);

      -- Bug 4898974 Fix.
       hr_transaction_api.finalize_transaction (
         P_TRANSACTION_ID => p_transaction_id
        ,P_EVENT => 'RFC'
        ,P_RETURN_STATUS => l_return_status
       );

     -- logic to set the from role for rfc notification
     -- Fetch the id for RFC notification.
     begin
        SELECT ias.notification_id
        into   ln_rfc_notification_id
        FROM   WF_ITEM_ACTIVITY_STATUSES IAS
        WHERE ias.item_type        = p_item_Type
        and   ias.item_key         = p_item_Key
        and   IAS.ACTIVITY_STATUS  = 'NOTIFIED'
        and   notification_id is not null
        and   rownum < 2;
     exception
     when others then
        null;
     end;

  -- Set the from attribute for RFC notification.
     wf_notification.setAttrText(
           nid           => ln_rfc_notification_id
          ,aname         => '#FROM_ROLE'
          ,avalue        => fnd_global.user_name );
  -- processing logic for non AME
  begin
    IF (wf_engine.GetItemAttrText(itemtype => p_item_Type ,
                                   itemkey  => p_item_key,
                                   aname    => 'HR_AME_TRAN_TYPE_ATTR') IS NULL) THEN
      --
      -- set the attribute value to null
        wf_engine.SetItemAttrNumber(
                 itemtype => p_item_Type ,
                 itemkey  => p_item_key,
                 aname    => 'CURRENT_APPROVER_INDEX',
                 avalue   => p_approverIndex);
      --
      -- If the selected person (for RFC) is additional approver
        -- then fetch the last default approver from history
        -- else selected person is the last default approver
        IF ( cur_add_appr%ISOPEN ) THEN
              CLOSE cur_add_appr;
        END IF;
         --
        OPEN  cur_add_appr;
        FETCH cur_add_appr INTO lv_dummy;
          if cur_add_appr%found then
             --
             IF ( cur_appr%ISOPEN ) THEN
              CLOSE cur_appr;
             END IF;
             --
             OPEN  cur_appr;
             FETCH cur_appr INTO l_lastDefaultApprover;
             CLOSE cur_appr;
             --
             IF ( l_lastDefaultApprover IS NULL ) THEN

                  begin
                    select employee_id into lv_role_orig_sys_id from (
                        SELECT pth.employee_id
                        FROM pqh_ss_approval_history pah,
                             fnd_user pth
                        WHERE pah.user_name = pth.user_name
                        AND pah.transaction_history_id = p_transaction_id
                        and approval_history_id > 0
                        and approval_history_id = (select min(approval_history_id) from pqh_ss_approval_history where USER_NAME = p_rfcRoleName and transaction_history_id = p_transaction_id)
                        and pah.last_update_date <(select min(last_update_date) from pqh_ss_approval_history where USER_NAME = p_rfcRoleName and transaction_history_id = p_transaction_id
                                and approval_history_id = (select min(approval_history_id) from pqh_ss_approval_history where USER_NAME = p_rfcRoleName and transaction_history_id = p_transaction_id))
                        order by pah.last_update_date desc
                        )
                        where rownum = 1;
            	 exception
                 when others then
                    null;
                 end;
                 l_lastDefaultApprover := lv_role_orig_sys_id;
             END IF;
          else
              l_lastDefaultApprover := p_rfcUserOrigSystemId;
          end if;

        CLOSE cur_add_appr;

        IF ( l_lastDefaultApprover IS NOT NULL ) THEN
           wf_engine.SetItemAttrNumber(
                 itemtype => p_item_Type ,
                 itemkey  => p_item_key,
                 aname    => 'LAST_DEFAULT_APPROVER',
                 avalue   => l_lastDefaultApprover);
        END IF;
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
    if g_debug then
       hr_utility.set_location('Error in  handleRFCAction SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;

end handleRFCAction;

procedure handleRFCAction(p_approval_notification_id in wf_notifications.notification_id%type
                         ) is
  lv_item_type wf_items.item_type%type;
  lv_item_key  wf_items.item_key%type;
  lv_creator_role wf_roles.name%type;
  lv_creator_orig_system wf_roles.orig_system%type;
  lv_creator_orig_sys_id wf_roles.orig_system_id%type;
begin
   hr_workflow_ss.get_item_type_and_key(p_approval_notification_id,lv_item_type,lv_item_key);

   -- fix for bug 4481775
    begin
      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>lv_item_type
                                          ,p_item_key=>lv_item_key);
    exception
    when others then
      null;
    end;


   lv_creator_role := wf_engine.getitemattrtext(lv_item_type,
                                                lv_item_key,
                                                'CREATOR_PERSON_USERNAME');
   -- get the orig sys info
   wf_directory.getroleorigsysinfo(lv_creator_role,
                                   lv_creator_orig_system,
                                   lv_creator_orig_sys_id);

   handleRFCAction(p_approval_notification_id =>p_approval_notification_id,
                          p_transaction_id =>wf_engine.getitemattrnumber
                                                        (lv_item_type,
                                                        lv_item_key,
                                                        'TRANSACTION_ID'),
                          p_item_type =>lv_item_type,
                          p_item_key  =>lv_item_key,
                          p_rfcRoleName =>lv_creator_role,
                          p_rfcUserOrigSystem =>lv_creator_orig_system,
                          p_rfcUserOrigSystemId =>lv_creator_orig_sys_id,
                          p_rfc_comments=>null,
                          p_approverIndex=>0
                          );

end handleRFCAction;

procedure creatorRoleReInit(p_item_type in wf_items.item_type%type,
                            p_item_key  in wf_items.item_key%type) is
  lv_role_name wf_roles.name%type;
  lv_role_disp_name wf_roles.name%type;
  lv_role_orig_system wf_roles.orig_system%type;
  lv_role_orig_sys_id wf_roles.orig_system_id%type;
begin

  -- CREATOR_PERSON_ID
    lv_role_orig_sys_id:=wf_engine.getitemattrnumber(p_item_type,p_item_key,'CREATOR_PERSON_ID',true);

    if(lv_role_orig_sys_id is not null) then
      -- need to revisit with role based support in SSHR transaction
      lv_role_orig_system := 'PER';

      wf_directory.GetRoleName
         (p_orig_system       => lv_role_orig_system
         ,p_orig_system_id    => lv_role_orig_sys_id
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);

     -- set the concerned item attributes
     -- CREATOR_PERSON_USERNAME
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'CREATOR_PERSON_USERNAME'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );
    -- APPROVAL_CREATOR_USERNAME
       create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'APPROVAL_CREATOR_USERNAME'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );

    end if;

end creatorRoleReInit;


procedure selPersonRoleReInit(p_item_type in wf_items.item_type%type,
                            p_item_key  in wf_items.item_key%type) is
  lv_role_name wf_roles.name%type;
  lv_role_disp_name wf_roles.name%type;
  lv_role_orig_system wf_roles.orig_system%type;
  lv_role_orig_sys_id wf_roles.orig_system_id%type;
begin

  -- CURRENT_PERSON_ID
    lv_role_orig_sys_id:=wf_engine.getitemattrnumber(p_item_type,p_item_key,'CURRENT_PERSON_ID',true);

    if(lv_role_orig_sys_id is not null) then
      -- need to revisit with role based support in SSHR transaction
      lv_role_orig_system := 'PER';
      wf_directory.GetRoleName
         (p_orig_system       => lv_role_orig_system
         ,p_orig_system_id    => lv_role_orig_sys_id
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);
     -- set the concerned item attributes
     -- CURRENT_PERSON_USERNAME
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'CURRENT_PERSON_USERNAME'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'CURRENT_PERSON_DISPLAY_NAME'
                               ,text_value=>lv_role_disp_name
                               ,number_value=>null,
                               date_value=>null
                               );
    end if;

end selPersonRoleReInit;

procedure forwardFromRoleReInit(p_item_type in wf_items.item_type%type,
                            p_item_key  in wf_items.item_key%type) is
  lv_role_name wf_roles.name%type;
  lv_role_disp_name wf_roles.name%type;
  lv_role_orig_system wf_roles.orig_system%type;
  lv_role_orig_sys_id wf_roles.orig_system_id%type;
begin

  -- FORWARD_FROM_PERSON_ID
    lv_role_orig_sys_id:=wf_engine.getitemattrnumber(p_item_type,p_item_key,'FORWARD_FROM_PERSON_ID',true);

    if(lv_role_orig_sys_id is not null) then
      -- need to revisit with role based support in SSHR transaction
      lv_role_orig_system := nvl( wf_engine.GetItemAttrText
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'FORWARD_FROM_ORIG_SYS_ATTR'
	    ,ignore_notfound=>true),'PER');

      wf_directory.GetRoleName
         (p_orig_system       => lv_role_orig_system
         ,p_orig_system_id    => lv_role_orig_sys_id
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);
     -- set the concerned item attributes
     -- FORWARD_FROM_USERNAME
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'FORWARD_FROM_USERNAME'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );
    end if;

end forwardFromRoleReInit;


procedure rfcUserRoleReInit(p_item_type in wf_items.item_type%type,
                            p_item_key  in wf_items.item_key%type) is
  lv_role_name wf_roles.name%type;
  lv_role_disp_name wf_roles.name%type;
  lv_role_orig_system wf_roles.orig_system%type;
  lv_role_orig_sys_id wf_roles.orig_system_id%type;
begin

  -- RETURN_TO_USER_ORIG_SYS_ID
    lv_role_orig_sys_id:=wf_engine.getitemattrnumber(p_item_type,p_item_key,'RETURN_TO_USER_ORIG_SYS_ID',true);

    if(lv_role_orig_sys_id is not null) then
      -- need to revisit with role based support in SSHR transaction
      lv_role_orig_system := wf_engine.GetItemAttrText
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'RETURN_TO_USER_ORIG_SYS'
	    ,ignore_notfound=>true);

      wf_directory.GetRoleName
         (p_orig_system       => lv_role_orig_system
         ,p_orig_system_id    => lv_role_orig_sys_id
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);
     -- set the concerned item attributes
     -- RETURN_TO_USERNAME
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'RETURN_TO_USERNAME'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );
    end if;

end rfcUserRoleReInit;


procedure appraisalRolesReInit(p_item_type in wf_items.item_type%type,
                            p_item_key  in wf_items.item_key%type) is
  lv_role_name wf_roles.name%type;
  lv_role_disp_name wf_roles.name%type;
  lv_role_orig_system wf_roles.orig_system%type;
  lv_role_orig_sys_id wf_roles.orig_system_id%type;
  l_appraisal_id per_appraisals.appraisal_id%type;
  l_main_appraiser_id per_appraisals.main_appraiser_id%type;
  l_appraiser_person_id per_appraisals.appraiser_person_id%type;
  l_appraisee_person_id per_appraisals.appraisee_person_id%type;
begin

   -- get the appraisal id
   l_appraisal_id:= wf_engine.GetItemAttrNumber (itemtype => p_item_type ,
                             itemkey  => p_item_key ,
                             aname => 'APPRAISAL_ID',
                             ignore_notfound=>true);

  -- get the appraisee, main appraiser and appraiser id
   if(l_appraisal_id is not null) then
    begin

    select MAIN_APPRAISER_ID,APPRAISER_PERSON_ID,APPRAISEE_PERSON_ID
    into   l_main_appraiser_id, l_appraiser_person_id,l_appraisee_person_id
    from per_appraisals
    where APPRAISAL_ID=l_appraisal_id;

    exception
    when others then
      null;
    end;

    -- need to revisit with role based support in SSHR transaction
    lv_role_orig_system := 'PER';

   -- derive the role for HR_APPRAISEE_USER_NAME_ATTR
    if((l_appraisee_person_id is not null)and (l_appraisee_person_id<>'')) then
      wf_directory.GetRoleName
         (p_orig_system       => lv_role_orig_system
         ,p_orig_system_id    => l_appraisee_person_id
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);
     -- set the concerned item attributes
     -- HR_APPRAISEE_USER_NAME_ATTR
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_APPRAISEE_USER_NAME_ATTR'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );
    end if;

    -- derive the role for HR_MAIN_APPRAISER_USERNAME
    if(l_main_appraiser_id is not null) then
      wf_directory.GetRoleName
         (p_orig_system       => lv_role_orig_system
         ,p_orig_system_id    => l_main_appraiser_id
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);
     -- set the concerned item attributes
     -- HR_MAIN_APPRAISER_USERNAME
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_MAIN_APPRAISER_USERNAME'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );
    end if;

    -- derive the role for SUPERVISOR_USERNAME
    if(l_appraiser_person_id is not null) then
      wf_directory.GetRoleName
         (p_orig_system       => lv_role_orig_system
         ,p_orig_system_id    => l_appraiser_person_id
         ,p_name              => lv_role_name
         ,p_display_name      => lv_role_disp_name);
     -- set the concerned item attributes
     -- SUPERVISOR_USERNAME
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'SUPERVISOR_USERNAME'
                               ,text_value=>lv_role_name
                               ,number_value=>null,
                               date_value=>null
                               );
    end if;
   end if;

end appraisalRolesReInit;


procedure reInitPerformerRoles(p_notification_id in wf_notifications.notification_id%type,
                               p_transaction_id in hr_api_transactions.transaction_id%type,
                               p_item_type in wf_items.item_type%type,
                               p_item_key  in wf_items.item_key%type) is
  c_proc constant varchar2(30) := 'reInitPerformerRoles';
  lv_item_type wf_items.item_type%type;
  lv_item_key  wf_items.item_key%type;

begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

   -- get the item type item key
     if(p_notification_id is not null) then
       begin
         select substr(context,1,instr(context,':',1)-1) itemtype
          ,substr(context,instr(context,':')+1, (
          instr(context,':',instr(context,':')+1 ) - instr(context,':')-1) ) itemkey
          into lv_item_type,lv_item_key
         from   wf_notifications
         where  notification_id   = p_notification_id;
       exception
       when others then
           null;
       end;
     elsif(p_transaction_id is not null) then
       begin
         select item_type,item_key
         into lv_item_type,lv_item_key
         from hr_api_transactions
         where transaction_id=p_transaction_id;
       exception
       when others then
           null;
       end;
     else
       lv_item_type := p_item_type;
       lv_item_key := p_item_key;
     end if;


     if((lv_item_type is not null) and (lv_item_key is not null)) then
  -- handle creator role reinit
     creatorRoleReInit(lv_item_type,lv_item_key);
  -- current or selected person role reinit
     selPersonRoleReInit(lv_item_type,lv_item_key);
  -- handle forward to user role reinit
     forwardToRoleReInit(lv_item_type,lv_item_key);
  -- handle forward from user role reinit
     forwardFromRoleReInit(lv_item_type,lv_item_key);
  -- handle RFC user reinit
     rfcUserRoleReInit(lv_item_type,lv_item_key);
  -- other module specifics
     appraisalRolesReInit(lv_item_type,lv_item_key);
     end if;

exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  reInitPerformerRoles SQLERRM' ||' '||to_char(SQLCODE),20);
    end if;
    raise;

end reInitPerformerRoles;


procedure approvals_block
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2)
  is
    --local variables

begin
   -- Do nothing in cancel or timeout mode
   if (funmode <> wf_engine.eng_run) then
     result := wf_engine.eng_null;
     return;
   end if;
-- set the item attribute value with the current activity id
-- this will be used when the  notification is sent.
-- and to complete the blocked thread.
-- HR_APPROVAL_BLOCK_ID_ATTR
  create_item_attrib_if_notexist(itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname   => 'HR_APPROVAL_BLOCK_ID_ATTR'
                               ,text_value=>null
                               ,number_value=>actid,
                               date_value=>null
                               );
   WF_STANDARD.BLOCK(itemtype,itemkey,actid,funmode,result);

--resultout := 'NOTIFIED';

exception
  when others then
    Wf_Core.Context(g_package, '.approvals_block', itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end approvals_block;




--  new code for generic approval process
-- without page navigation
-- ----------------------------------------------------------------------------
-- |--------------------< wf_get_runnable_process_name >----------------------|
-- ----------------------------------------------------------------------------
function wf_get_runnable_process_name
  (p_item_type    in wf_items.item_type%type
  ,p_process_name in wf_process_activities.process_name%type)
  return wf_runnable_processes_v.display_name%type is
  -- cursor determines is the specified process is runnable
  cursor csr_wrpv is
    select wrpv.display_name
    from   wf_runnable_processes_v wrpv
    where  wrpv.item_type    = p_item_type
    and    wrpv.process_name = p_process_name;
  --
  l_display_name wf_runnable_processes_v.display_name%type;
  --
begin
  -- Determine if the specified process is runnable
  open csr_wrpv;
  fetch csr_wrpv into l_display_name;
  if csr_wrpv%notfound then
    close csr_wrpv;
    return(NULL);
  end if;
  close csr_wrpv;
  return(l_display_name);
end wf_get_runnable_process_name;
-- ----------------------------------------------------------------------------
-- |-------------------------< wf_process_runnable >--------------------------|
-- ----------------------------------------------------------------------------
function wf_process_runnable
  (p_item_type    in wf_items.item_type%type
  ,p_process_name in wf_process_activities.process_name%type)
  return boolean is
  --
begin
  if wf_get_runnable_process_name
       (p_item_type    => p_item_type
       ,p_process_name => p_process_name) is NULL then
    return(FALSE);
  else
    return(TRUE);
  end if;
end wf_process_runnable;

-- ----------------------------------------------------------------------------
-- |------------------------< create_hr_directory_services >------------------|
-- ----------------------------------------------------------------------------
procedure create_hr_directory_services
  (p_item_type         in wf_items.item_type%type
  ,p_item_key          in wf_items.item_key%type
  ,p_service_name      in varchar2
  ,p_service_orig_sys_id in number
  ,p_service_orig_sys  in varchar2) is
--
  l_item_type_attribute_name varchar2(30);
  type l_suffix_tab is table of varchar2(30) index by binary_integer;
  l_suffix       l_suffix_tab;
  l_username     wf_users.name%type;
  l_display_name wf_users.display_name%type;
--
begin
  if p_service_orig_sys_id is not null then
    l_suffix(1) := 'ID';
    l_suffix(2) := 'USERNAME';
    l_suffix(3) := 'DISPLAY_NAME';
    l_suffix(4) := 'ORIG_SYS';
    -- get the USERNAME and DISPLAY_NAME from workflow
    begin
      wf_directory.getrolename
        (p_orig_system      => p_service_orig_sys
        ,p_orig_system_id   => p_service_orig_sys_id
        ,p_name             => l_username
        ,p_display_name     => l_display_name);
    exception
      when others then
        null;
    end;
    for i in 1..4 loop
      l_item_type_attribute_name := p_service_name||'_'||l_suffix(i);

      -- set the item attribue value
      if i = 1 then
        -- set the ID value
        create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => l_item_type_attribute_name
                               ,text_value=>null
                               ,number_value=>p_service_orig_sys_id,
                               date_value=>null
                               );

      elsif i = 2 then
        -- set the USERNAME value
         create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => l_item_type_attribute_name
                               ,text_value=>l_username
                               ,number_value=>null,
                               date_value=>null
                               );
      elsif i = 3 then
        -- set the DISPLAY_NAME value
         create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => l_item_type_attribute_name
                               ,text_value=>l_display_name
                               ,number_value=>null,
                               date_value=>null
                               );

      else
        -- set the ORIG_SYS value
         create_item_attrib_if_notexist(itemtype  => p_item_type
                               ,itemkey   => p_item_key
                               ,aname   => l_item_type_attribute_name
                               ,text_value=>p_service_orig_sys
                               ,number_value=>null,
                               date_value=>null
                               );

      end if;
    end loop;
  end if;
end create_hr_directory_services;
-- ----------------------------------------------------------------------------
--  getPersonNameFromID                                                      --
--     called internally to give the person name for the given user name     --
-- ----------------------------------------------------------------------------
--
FUNCTION getPersonNameFromID
(p_person_id per_all_people_f.person_id%type)
 return per_all_people_f.full_name%type is
--
cursor csr_full_name
  is   select full_name
         from per_all_people_f papf
        where papf.person_id = p_person_id
          and trunc(sysdate) between effective_start_date
          and effective_end_date;
--
l_employee_name per_all_people_f.full_name%type;
--
BEGIN
--
hr_utility.trace('Finding Person name for person_id :' || p_person_id || ':');
--
  open csr_full_name;
  fetch csr_full_name into l_employee_name;
--
  if csr_full_name%notfound then
    l_employee_name := ' ';
  end if;
  close csr_full_name;
--
hr_utility.trace('Found :' || l_employee_name || ':');
--
  return l_employee_name;
--
END getPersonNameFromID;

procedure startGenericApprovalProcess(p_transaction_id in number
                                     ,p_item_key  in out nocopy wf_items.item_key%type
                                     ,p_wf_ntf_sub_fnd_msg in fnd_new_messages.message_name%type
                                     ,p_relaunch_function hr_api_transactions.relaunch_function%type
                                     ,p_additional_wf_attributes in HR_WF_ATTR_TABLE
                                     ,p_status       out nocopy varchar2
                                     ,p_error_message out nocopy varchar2
                                     ,p_errstack     out nocopy varchar2
          )
is
  c_proc constant varchar2(30) := 'reInitPerformerRoles';
  lv_item_type wf_items.item_type%type;
  lv_item_key  wf_items.item_key%type;
  lr_transaction_rec hr_api_transactions%rowtype;
  lv_status    varchar2(8);
  lv_result    varchar2(30);
  lv_errorActid wf_item_activity_statuses.process_activity%type;
  lv_errname VARCHAR2(4000);
  l_index                binary_integer;
  l_temp_item_attribute       varchar2(2000);
  l_role_name wf_roles.name%type;
  l_role_displayname wf_roles.display_name%type;
  l_current_person_name per_all_people_f.full_name%type;
  l_manager_id per_all_people_f.person_id%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
   -- check if the transaction id is passed if not raise exception
   -- no more iterations
   if(p_transaction_id is not null) then
      -- block to get the transaction record details
      begin
        select *
        into lr_transaction_rec
        from hr_api_transactions
        where transaction_id=p_transaction_id;
      exception
      when no_data_found then
          raise;
          -- need proper error message propagated
      when others then
        raise;
      end;

       -- test value
      lr_transaction_rec.item_type:=nvl(lr_transaction_rec.item_type,'HRSSA');
      lr_transaction_rec.process_name :=nvl(lr_transaction_rec.process_name,'HR_GENERIC_APPROVAL_PRC');
      -- end of test value
      -- Determine if the specified process is runnable
      if NOT wf_process_runnable
           (p_item_type    => lr_transaction_rec.item_type
           ,p_process_name => lr_transaction_rec.process_name
           ) then
        -- supply HR error message, p_process_name either does not exist or
        -- is NOT a runnable process
        hr_utility.set_message(800,'HR_52958_WKF2TSK_INC_PROCESS');
        hr_utility.set_message_token('ITEM_TYPE', lr_transaction_rec.item_type);
        hr_utility.set_message_token('PROCESS_NAME', lr_transaction_rec.process_name);
        hr_utility.raise_error;
      end if;

      -- now check if we need to derive the item key from db seq
      if(p_item_key is null)then
         begin
           -- Get the next item key from the sequence
             select hr_workflow_item_key_s.nextval
             into   p_item_key
             from   sys.dual;
         exception
         when no_data_found then
            raise;
            -- need to pass proper error message
            -- this is a fatal error in getting the sequence value
         when others then
           raise;
         end;
      end if;

      -- Create the Workflow Process
      wf_engine.CreateProcess
        (itemtype => lr_transaction_rec.item_type
        ,itemkey  => p_item_key
        ,process  => lr_transaction_rec.process_name);

       -- check the process status before setting
       -- other mandatory attributes
        -- check the state of the workflow
  -- we need to check if the flow is in error state or not
     wf_engine.iteminfo(lr_transaction_rec.item_type,
                        p_item_key,
                        p_status,
                        lv_result,
                        lv_errorActid,
                        lv_errname,
                        p_error_message,
                        p_errstack);

    if(lv_status = 'ERROR') then
     raise g_wf_error_state;
    end if;

      -- Derive the mandatory roles and other details
      -- required for wf initalizations

      -- add new attribute for deriving the ntf subject
      -- HR_NTF_SUB_FND_MSG_ATTR
      create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_NTF_SUB_FND_MSG_ATTR'
                               ,text_value=>p_wf_ntf_sub_fnd_msg
                               ,number_value=>null,
                               date_value=>null
                               );
      --
      -- Create the standard set of item attributes
      -- CURRENT_PERSON_ID and CREATOR_PERSON_ID
      --
      create_hr_directory_services
        (p_item_type         => lr_transaction_rec.item_type
        ,p_item_key          => p_item_key
        ,p_service_name      => 'CREATOR_PERSON'
        ,p_service_orig_sys_id =>lr_transaction_rec.creator_person_id
        ,p_service_orig_sys  =>'PER' -- need to revisit for role based support
        );
      create_hr_directory_services
        (p_item_type         => lr_transaction_rec.item_type
        ,p_item_key          => p_item_key
        ,p_service_name      => 'CURRENT_PERSON'
        ,p_service_orig_sys_id =>lr_transaction_rec.selected_person_id
        ,p_service_orig_sys  =>'PER' -- need to revisit for role based support
        );

      -- Get Vacancy name and manager/creator name if the transaction is related to vacancy

    if lr_transaction_rec.transaction_ref_table ='PER_ALL_VACANCIES' then

	l_manager_id := hr_xml_util.get_node_value(lr_transaction_rec.transaction_id,
                                                 'ManagerId',
                                                 'Transaction/TransCache/AM/TXN/EO/PerRequisitionsEORow/CEO/EO/PerAllVacanciesEORow');

      if l_manager_id is not null then
         l_current_person_name := getpersonnamefromid(l_manager_id);
      else
         l_current_person_name := getpersonnamefromid(lr_transaction_rec.creator_person_id);
      end if;
         l_current_person_name := l_current_person_name||'('||lr_transaction_rec.api_addtnl_info||')';

      wf_engine.setItemattrtext(lr_transaction_rec.item_type,p_item_key,'CURRENT_PERSON_DISPLAY_NAME',l_current_person_name);
    end if;

    -- Get Applicant name  if the transaction is related to offers

    if lr_transaction_rec.transaction_ref_table ='IRC_OFFERS' then
        l_current_person_name := lr_transaction_rec.api_addtnl_info;
        wf_engine.setItemattrtext(lr_transaction_rec.item_type,p_item_key,'CURRENT_PERSON_DISPLAY_NAME',l_current_person_name);
    end if;
    -- Create Item Attributes for those passed in
    --
      l_index := 1;
      --
      WHILE l_index <= p_additional_wf_attributes.count LOOP
        begin
          -- upper the item attribute name
          -- if a NO_DATA_FOUND exception occurs, the exception is
          -- handled and the item is skipped
          l_temp_item_attribute       := upper(p_additional_wf_attributes(l_index).name);
          create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                                   ,itemkey   => p_item_key
                                   ,aname   => l_temp_item_attribute
                                   ,text_value=>p_additional_wf_attributes(l_index).text_value
                                   ,number_value=>p_additional_wf_attributes(l_index).number_value,
                                   date_value=>p_additional_wf_attributes(l_index).date_value
                                  );
          l_index := l_index + 1;
        exception
          when NO_DATA_FOUND then
            -- The array element at the index position has not been set
            -- Ignore, but increment the counter and continue with the LOOP
            l_index := l_index + 1;
        end;
      END LOOP;


        --
        -- ---------------------------------
        -- Get the Role for the Owner
        -- ---------------------------------
      wf_directory.getRoleName
      (p_orig_system => 'PER'
      ,p_orig_system_id => lr_transaction_rec.creator_person_id
      ,p_name => l_role_name
      ,p_display_name => l_role_displayname);

      IF l_role_name = '' OR l_role_name IS NULL THEN
        RAISE g_invalid_responsibility;
      END IF;
      -- ---------------------------------------------------
      -- Set the Item Owner
      -- ---------------------------------------------------
      wf_engine.setItemOwner
      (itemtype => lr_transaction_rec.item_type
      ,itemkey => p_item_key
      ,owner => l_role_name);

      -- set 'CURRENT_EFFECTIVE_DATE'
      create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'CURRENT_EFFECTIVE_DATE'
                               ,text_value=>null
                               ,number_value=>null,
                               date_value=>lr_transaction_rec.transaction_effective_date
                               );
      -- set 'CURRENT_EFFECTIVE_DATE'
      create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'CURRENT_EFFECTIVE_DATE'
                               ,text_value=>null
                               ,number_value=>null,
                               date_value=>lr_transaction_rec.transaction_effective_date
                               );
     -- set HR_OAF_EDIT_URL_ATTR
        create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_OAF_EDIT_URL_ATTR'
                               ,text_value=>p_relaunch_function
                               ,number_value=>null,
                               date_value=>null
                               );
     -- set HR_OAF_NAVIGATION_ATTR
       create_item_attrib_if_notexist(itemtype  => lr_transaction_rec.item_type
                               ,itemkey   => p_item_key
                               ,aname   => 'HR_OAF_NAVIGATION_ATTR'
                               ,text_value=>'N'
                               ,number_value=>null,
                               date_value=>null
                               );

    -- now start the process
    -- Start the WF runtime process
       wf_engine.startprocess
        (itemtype => lr_transaction_rec.item_type
        ,itemkey  => p_item_key);

     -- check the wf status before returning the status back to caller
     -- we need to check if the flow is in error state or not
     wf_engine.iteminfo(lr_transaction_rec.item_type,
                        p_item_key,
                        p_status,
                        lv_result,
                        lv_errorActid,
                        lv_errname,
                        p_error_message,
                        p_errstack);

    if(lv_status = 'ERROR') then
     raise g_wf_error_state;
    end if;


   else
      raise g_no_transaction_id;
   end if;

   if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
   end if;

  exception
  WHEN g_invalid_responsibility THEN
	fnd_message.set_name('PER','HR_SSA_INVALID_RESPONSIBILITY');
	hr_utility.raise_error;
  when g_wf_error_state then
  -- HR_WF_TRANSACTION_ERROR_SS
  fnd_message.set_name('PER','HR_WF_TRANSACTION_ERROR_SS');
  fnd_message.set_token('ERRORMSG',p_error_message,true);
  fnd_message.set_token('ERRORSTACK',p_errstack,true);
  hr_utility.raise_error;
  when g_no_transaction_id then
     null;
     -- handle the proper error message propagation
  when others then
    raise;
end startGenericApprovalProcess;


function getinitApprovalBlockId(p_transaction_id in number) return number
is

 c_proc constant varchar2(30) := 'getinitApprovalBlockId';
 lr_hr_api_transaction_rec hr_api_transactions%rowtype;
 ln_activity_id number;
 lv_loginPersonDispName per_all_people_f.full_name%type;
 lv_loginPersonUserName fnd_user.user_name%type;
 ln_loginPersonId       fnd_user.employee_id%type;
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
      -- generic approval process initial block id attribute
      --HR_APPROVAL_BLOCK_ID_ATTR
      ln_activity_id:=wf_engine.getitemattrnumber(lr_hr_api_transaction_rec.item_type,
                                   lr_hr_api_transaction_rec.item_key,
                                   'HR_APPROVAL_BLOCK_ID_ATTR',true);
    end if;
  end if;
 return ln_activity_id;

end getinitApprovalBlockId;

function getApproverNtfId(p_transaction_id in number) return number
is
  c_proc constant varchar2(30) := 'getApproverNtfId';
  lr_hr_api_transaction_rec hr_api_transactions%rowtype;
  ln_notification_id wf_notifications.notification_id%type;
begin
   if(p_transaction_id is not null) then
         select * into lr_hr_api_transaction_rec
         from hr_api_transactions
         where transaction_id=p_transaction_id;

         select notification_id
         into ln_notification_id
         FROM   WF_ITEM_ACTIVITY_STATUSES IAS
         WHERE  ias.item_type          = lr_hr_api_transaction_rec.item_type
         and    ias.item_key           = lr_hr_api_transaction_rec.item_key
         and    ias.activity_status    = 'NOTIFIED'
         and    ias.notification_id is not null
         and rownum<=1;
   end if;

   return ln_notification_id;
exception
when no_data_found then
   raise;
when others then
   raise;
end getApproverNtfId;

procedure processPageNavWFSubmit(p_transaction_id in number,
                                 p_approval_comments in varchar2)
is
  -- local variables
   c_proc constant varchar2(30) := 'processPageNavWFSubmit';
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;
   ln_activity_id wf_item_activity_statuses.process_activity%type;
    begin
      if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
      end if;

      if(p_transaction_id is not null) then

         select * into lr_hr_api_transaction_rec
         from hr_api_transactions
         where transaction_id=p_transaction_id;

         hr_transaction_api.update_transaction(
               p_transaction_id    => p_transaction_id,
               p_status            => 'Y',
               p_transaction_state => null);

        -- re-intialize the performer roles
               hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>lr_hr_api_transaction_rec.item_type
                                          ,p_item_key=>lr_hr_api_transaction_rec.item_key);


      -- default logic
           -- get the blockid value corresponding to the UI page
           ln_activity_id:=
                getOAFPageActId(lr_hr_api_transaction_rec.item_type,lr_hr_api_transaction_rec.item_key);
           -- check if the ln_activity_id is null
           if(ln_activity_id is null) then
             null; -- raise error
           end if;
           -- set the workflow status TRAN_SUBMIT to Y
         wf_engine.setitemattrtext(lr_hr_api_transaction_rec.item_type
                                      ,lr_hr_api_transaction_rec.item_key
                                      ,'TRAN_SUBMIT'
                                      ,'Y');


         --


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
      end if;

      if (g_debug ) then
          hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
      end if;
    exception
    when others then
    raise;
end processPageNavWFSubmit;


procedure update_comments(
          p_ntf_id  in number,
          p_txn_status in varchar2,
          p_approval_comments     in varchar2)
          is
          cursor csr_wf_note_exists is
          select 1
          from wf_notification_attributes wna
          where notification_id = p_ntf_id
          and NAME = 'WF_NOTE';
          l_dummy  number(1);
begin
 -- The parameter p_txn_status is currently not used but if this procedure requires
 -- modifications in the future it might be needed.

 -- Check if comments are present
 if p_approval_comments is not null then
     -- Check if WF_NOTE is a part of the notification
     open csr_wf_note_exists;
     fetch csr_wf_note_exists into l_dummy;
         if csr_wf_note_exists%found then
              -- Attribute exists so write into it
              wf_notification.setattrtext( p_ntf_id,'WF_NOTE',p_approval_comments);
         else
              -- Do we need to create the attribute ?
              -- Current implementation is a no-op
              null;
         end if;
      close csr_wf_note_exists;
 end if;

end update_comments;



procedure processNonPageNavWFSubmit(p_transaction_id in number,
                                 p_approval_comments in varchar2)
is
  -- local variables
   c_proc constant varchar2(30) := 'processNonPageNavWFSubmit';
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;
   ln_activity_id wf_item_activity_statuses.process_activity%type;
   ln_notification_id wf_notifications.notification_id%type;
   lv_loginPersonDispName per_all_people_f.full_name%type;
   lv_loginPersonUserName fnd_user.user_name%type;
   ln_loginPersonId       fnd_user.employee_id%type;

    begin
      if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
      end if;

      if(p_transaction_id is not null) then

         select * into lr_hr_api_transaction_rec
         from hr_api_transactions
         where transaction_id=p_transaction_id;

             hr_transaction_api.update_transaction(
               p_transaction_id    => p_transaction_id,
               p_status            => 'Y',
               p_transaction_state => null);


          -- re-intialize the performer roles
          hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>lr_hr_api_transaction_rec.item_type
                                          ,p_item_key=>lr_hr_api_transaction_rec.item_key);


         -- get the current transaction status
         -- If approver is editing and submitting the possible
         -- status are 'Y','YS','RI','RIS','RO','RIS'
         -- else it should be the initial creator submit

         begin
           -- get the current transaction status
           if(lr_hr_api_transaction_rec.status in ('Y','YS','RI','RIS','RO','RIS')) then
              -- approver edit and submit case
             ln_notification_id:= getApproverNtfId(p_transaction_id);

            wf_engine.setitemattrtext(lr_hr_api_transaction_rec.item_type,lr_hr_api_transaction_rec.item_key,
                     'APPROVAL_COMMENT_COPY',p_approval_comments);

             -- check if not null value
             if(ln_notification_id is not null) then
              -- add the code plugin transfer history
                 -- need to revisit as this is resubmit not submit action
                 hr_trans_history_api.archive_resubmit(p_transaction_id,
                                                  null,
                                                  fnd_global.user_name,
                                                  p_approval_comments);
               -- complete the notification
               wf_notification.setattrtext(
       			ln_notification_id
       		       ,'RESULT'
       		       ,'RESUBMIT');

              -- Fix for bug 4998216 starts
              update_comments(ln_notification_id,lr_hr_api_transaction_rec.status,p_approval_comments);
              -- Fix for bug 4998216 ends

              wf_notification.respond(
        			ln_notification_id
      		       ,p_approval_comments
      		       ,fnd_global.user_name
      		       ,null);
                 -- Fix for 5070814
                   if(lr_hr_api_transaction_rec.status in ('RI','RIS','RO','RIS')) then
                     -- propagate during RFC only
                          wf_notification.propagatehistory(
                               lr_hr_api_transaction_rec.item_type
                              ,lr_hr_api_transaction_rec.item_key
                              ,'APPROVAL_NOTIFICATION'
                              ,fnd_global.user_name
                              ,'WF_SYSTEM'
                              --,hr_workflow_ss.getNextApproverForHist(itemtype, itemkey)
                              ,'RESUBMIT'
                              ,null
                              ,p_approval_comments);
                   end if;
             else
               -- notification is null, raise exception
               null;
             end if;
              -- get the approver notification id
           else
              -- intiator submit case
              -- get the inital block id
              ln_activity_id:= getinitApprovalBlockId(p_transaction_id);

              -- update the transaction status before transitioning the flow
             hr_transaction_api.update_transaction(
               p_transaction_id    => p_transaction_id,
               p_status            => 'Y');




             -- set the initial submit comments
             -- APPROVAL_COMMENT_COPY
              hr_approval_ss.create_item_attrib_if_notexist(itemtype  => lr_hr_api_transaction_rec.item_type
                               ,itemkey   => lr_hr_api_transaction_rec.item_key
                               ,aname   => 'APPROVAL_COMMENT_COPY'
                               ,text_value=>p_approval_comments
                               ,number_value=>null,
                               date_value=>null
                               );

             WF_ENGINE.SetItemAttrText(lr_hr_api_transaction_rec.item_type,lr_hr_api_transaction_rec.item_key,
                              'WF_NOTE',p_approval_comments);

              -- else intial submit
             wf_engine.CompleteActivity(
                   lr_hr_api_transaction_rec.item_type
                 , lr_hr_api_transaction_rec.item_key
                 , wf_engine.getactivitylabel(ln_activity_id)
                 , wf_engine.eng_trans_default)  ;

           end if;
         end;

      else
       null; -- null transaction id  throw error ??
      end if;

      if (g_debug ) then
          hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
      end if;
    exception
    when others then
    raise;
end processNonPageNavWFSubmit;

procedure processApprovalSubmit(p_transaction_id in number,
                                p_approval_comments in varchar2)
 is
 -- local variables
   c_proc constant varchar2(30) := 'processApprovalSubmit';
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;
   ln_activity_id wf_item_activity_statuses.process_activity%type;
   lv_loginPersonDispName per_all_people_f.full_name%type;
   lv_loginPersonUserName fnd_user.user_name%type;
   ln_loginPersonId       fnd_user.employee_id%type;
   lv_item_type wf_items.item_type%type;
   lv_item_key  wf_items.item_key%type;
   lv_oaf_nav_attr wf_item_attribute_values.text_value%type;
   begin
     if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;

     -- code logic

       if(p_transaction_id is not null) then

         begin
         select item_type,item_key
          into lv_item_type,lv_item_key
         from hr_api_transactions
         where transaction_id=p_transaction_id;
         exception
         when no_data_found then
           -- get the fnd message and populate to the fnd message pub
              if(hr_multi_message.is_message_list_enabled) then
                fnd_message.set_name('PER', 'HR_SS_NO_TXN_DATA');
                hr_multi_message.add(p_message_type => hr_multi_message.G_ERROR_MSG  );
              end if;
              hr_utility.raise_error;
          when others then
            raise;
          end; -- finished fetching record

        -- do the processing logic
        begin
           -- check if we have valid item type and key
           if(lv_item_type is null or lv_item_key is null) then
            raise g_wf_not_initialzed;
           end if;
          -- check if the flow is used for page navigation
          -- HR_OAF_NAVIGATION_ATTR
          lv_oaf_nav_attr := wf_engine.getitemattrtext(lv_item_type,lv_item_key,'HR_OAF_NAVIGATION_ATTR',true);
          if(lv_oaf_nav_attr='Y') then
            -- process page navigation based wf approval submit
            processPageNavWFSubmit(p_transaction_id,p_approval_comments );
          else
             -- process wf approval submit with approvals only
            processNonPageNavWFSubmit(p_transaction_id,p_approval_comments );
          end if;

        exception
          when g_wf_not_initialzed then
              -- get the fnd message and populate to the fnd message pub
              if(hr_multi_message.is_message_list_enabled) then
                fnd_message.set_name('PER', 'HR_SS_WF_NOT_INITIALZED');
                hr_multi_message.add(p_message_type => hr_multi_message.G_ERROR_MSG  );
              end if;
              hr_utility.raise_error;
          when others then
            if hr_multi_message.unexpected_error_add(c_proc) then
             hr_utility.set_location(' Leaving:' || c_proc,40);
              raise;
            end if;
          end;

          -- finally close the sfl open notifications if any
         hr_sflutil_ss.closeopensflnotification(p_transaction_id);

       else
         -- get the fnd message and populate to the fnd message pub
              if(hr_multi_message.is_message_list_enabled) then
                fnd_message.set_name('PER', 'HR_SS_NULL_TXN_ID');
                hr_multi_message.add(p_message_type => hr_multi_message.G_ERROR_MSG  );
              end if;
              hr_utility.raise_error;
       end if;



    if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;

   exception
     when others then
       raise;
   end processApprovalSubmit;

procedure resetWfPageFlowState(p_transaction_id in number)
is
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
ln_activity_id  wf_item_attribute_values.number_value%type;
ln_oaf_page_act_id WF_ITEM_ACTIVITY_STATUSES.process_activity%type;
lv_oaf_nav_attr wf_item_attribute_values.text_value%type;
begin

   if(p_transaction_id is not null) then
     begin
       select * into lr_hr_api_transaction_rec
       from hr_api_transactions
       where transaction_id=p_transaction_id;
    exception
      when others then
        null;
     end;

     -- check the status
     if(lr_hr_api_transaction_rec.status<>'W') then
        if(lr_hr_api_transaction_rec.item_key is not null) then
          -- check if the flow uses wf for page navigation
            -- HR_OAF_NAVIGATION_ATTR
          lv_oaf_nav_attr := wf_engine.getitemattrtext(lr_hr_api_transaction_rec.item_type,
                                                       lr_hr_api_transaction_rec.item_key,
                                                       'HR_OAF_NAVIGATION_ATTR',
                                                       true);
              if(lv_oaf_nav_attr='Y') then
                -- for wf page navigation need to reset the wf state
                -- S, RIS,ROS,YS  reset the state to saved page actid
                 -- Y,RO,RI reset to first page activity id
                if(lr_hr_api_transaction_rec.status in ('S','RIS','ROS','YS')) then
                   ln_activity_id := wf_engine.getitemattrnumber(lr_hr_api_transaction_rec.item_type,
                                                                lr_hr_api_transaction_rec.item_key,
                                                                'SAVED_ACTIVITY_ID',
                                                                true);
                elsif(lr_hr_api_transaction_rec.status in ('RI','RO','Y')) then
                   ln_activity_id := wf_engine.getitemattrnumber(lr_hr_api_transaction_rec.item_type,
                                                                lr_hr_api_transaction_rec.item_key,
                                                                'HR_FIRST_ACTIVITY_ID',
                                                                true);

                end if;

                -- finally call wf engine handle to reset the state
                -- need to do only if the current activity id is not
                -- same as the ln_activity_id
                ln_oaf_page_act_id := hr_approval_ss.getoafpageactid(
                                                     lr_hr_api_transaction_rec.item_type,
                                                     lr_hr_api_transaction_rec.item_key);
                if(ln_activity_id is not null and ln_activity_id<>ln_oaf_page_act_id ) then
			WF_ENGINE.handleError(
                        itemType => lr_hr_api_transaction_rec.item_type
                       ,itemKey  => lr_hr_api_transaction_rec.item_type
                       ,activity => WF_ENGINE.GetActivityLabel(ln_activity_id)
                       ,command  => 'RETRY' ) ;
                end if;
            end if;
        end if;
    end if;
  end if;


exception
  when others then
    null;
end resetWfPageFlowState;


procedure checktransactionState(p_transaction_id       IN NUMBER)

is
  -- local variables
   c_proc constant varchar2(40) := 'checktransactionState';
   lv_status hr_api_transactions.status%type;
   lv_state  hr_api_transactions.transaction_state%type;
begin
     if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;


     begin
       select status,transaction_state
       into lv_status,lv_state
       from hr_api_transactions
       where transaction_id=p_transaction_id;

       -- check the transaction status
       if(lv_status in ('YS','RIS','ROS')) then
         -- saved transaction exists set the warning message

          if(hr_multi_message.is_message_list_enabled) then
            hr_utility.set_message(800,'HR_SS_SAVED_TXN_DATA_EXISTS');
            hr_multi_message.add( p_message_type => hr_multi_message.G_WARNING_MSG);
            hr_utility.set_warning;
          end if;
       end if;
       if(lv_state is not null) then
           -- in advertant saved transaction exists set the warning message

          if(hr_multi_message.is_message_list_enabled) then
            hr_utility.set_message(800,'HR_SS_INADV_TXN_DATA_EXISTS');
            hr_multi_message.add( p_message_type => hr_multi_message.G_WARNING_MSG);
          end if;

       end if;

     exception
     when others then
       null; -- do nothing
     end ;

if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    raise;
end checktransactionState;

procedure handleApprovalErrors(p_item_type in wf_items.item_type%type,
                         p_item_key in wf_items.item_key%type,
                         error_message_text in varchar2)
is

l_creator_disp_name      wf_users.display_name%type;
l_aprv_routing_username varchar2(60);
lv_process_display_name wf_runnable_processes_v.display_name%type;
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
l_forward_from_display_name wf_users.display_name%type;
l_forward_to_display_name wf_users.display_name%type;
c_approver_to_notify_rec ame_util.approverRecord2;
lv_ntf_sub_msg           wf_item_attribute_values.text_value%type;


begin

c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR');
c_application_id := nvl(c_application_id,800);
c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');
c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');

   ame_api2.getadminapprover(applicationidin => c_application_id
                                        ,transactiontypein => c_transaction_type
                                        ,adminapproverout => c_approver_to_notify_rec);

    l_aprv_routing_username := c_approver_to_notify_rec.name;

    if(l_aprv_routing_username is null) then
    l_aprv_routing_username := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'CREATOR_PERSON_USERNAME');
    end if;
    wf_engine.setitemattrtext(p_item_type,p_item_key,'APPROVAL_ROUTING_USERNAME1',l_aprv_routing_username);

    l_forward_from_display_name := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'FORWARD_FROM_DISPLAY_NAME');
    if(l_forward_from_display_name is null) then
    l_forward_from_display_name := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'CREATOR_PERSON_DISPLAY_NAME');
    end if;
    wf_engine.setitemattrtext(p_item_type,p_item_key,'FORWARD_FROM_DISPLAY_NAME',l_forward_from_display_name);

    l_forward_to_display_name := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'FORWARD_TO_DISPLAY_NAME');
    if(l_forward_to_display_name is null) then
    l_forward_to_display_name := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'CREATOR_PERSON_DISPLAY_NAME');
    end if;
    wf_engine.setitemattrtext(p_item_type,p_item_key,'FORWARD_TO_DISPLAY_NAME',l_forward_to_display_name);


wf_engine.setitemattrtext(p_item_type,p_item_key,'ERROR_MESSAGE_TEXT',error_message_text);
wf_engine.setitemattrtext(p_item_type,p_item_key,'ERROR_ITEM_TYPE',p_item_type);
wf_engine.setitemattrtext(p_item_type,p_item_key,'ERROR_ITEM_KEY',p_item_key);


lv_ntf_sub_msg := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_NTF_SUB_FND_MSG_ATTR',
                                               ignore_notfound=>true);

   if(lv_ntf_sub_msg is null) then
     lv_process_display_name := hr_workflow_ss.getProcessDisplayName(p_item_type,p_item_key);
   else
      fnd_message.set_name('PER',lv_ntf_sub_msg);
      lv_process_display_name:= fnd_message.get;
   end if;

exception
when others then
   if g_debug then
       hr_utility.set_location('Error in  handleApprovalErrors SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
  raise;
end handleApprovalErrors;

procedure updateRejectStatus( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2)

is
  -- local variables
   c_proc constant varchar2(30) := 'updateRejectStatus';
   -- Variables required for AME API
   c_application_id integer;
   c_transaction_id varchar2(25);
   c_transaction_type varchar2(50);
   c_next_approvers  ame_util.approverstable2;
   c_approvalprocesscompleteynout ame_util.charType;
   l_current_forward_to_username   wf_users.name%type;
   itemClass varchar2(100);
   itemId varchar2(100);
   actionTypeId number;
   groupOrChainId number;
   occurrence number;
   notification_rec ame_util2.notificationRecord;
   l_trans_ref_table	hr_api_transactions.transaction_ref_Table%type;


begin

   g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

	begin

	select transaction_ref_table into l_trans_ref_table
    from hr_api_transactions
    where item_type = p_item_type and item_key = p_item_key;

    exception
    when no_data_found then
 	l_trans_ref_table := null;

    when others then
    l_trans_ref_table := null;

	end;

  if l_trans_ref_table = 'PER_APPRAISALS' then
     return;
  end if;


   if ( funmode = wf_engine.eng_run ) then
       -- check if it is AME or custom approvals
       c_application_id :=nvl(wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR'),800);

       c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');

       c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');
       if(c_transaction_type is not null) then
         hr_utility.set_location('In(if ( if(c_transaction_type is not null))): '|| c_proc,2);
          l_current_forward_to_username:=   Wf_engine.GetItemAttrText(itemtype => p_item_type
                                                                     ,itemkey  => p_item_key
                                                                     ,aname    => 'FORWARD_TO_USERNAME');
          l_current_forward_to_username := nvl(l_current_forward_to_username,wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'RETURN_TO_USERNAME'));
          if g_debug then
	    hr_utility.set_location('calling ame_api2.updateApprovalStatus2', 3);
	    hr_utility.set_location('c_application_id:'|| c_application_id, 4);
	    hr_utility.set_location('c_transaction_type:'|| c_transaction_type, 5);
	    hr_utility.set_location('approvalStatusIn:'|| ame_util.approvedStatus, 6);
	    hr_utility.set_location('approverNameIn:'|| l_current_forward_to_username, 7);
	  end if;

	  --     HR_APR_ACTION_TYPE_ID_ATTR

        actionTypeId:=wf_engine.GetItemAttrNumber(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ACTION_TYPE_ID_ATTR');

    --     HR_APR_GRPORCHN_ID_ATTR

        groupOrChainId:=wf_engine.GetItemAttrNumber(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_GRPORCHN_ID_ATTR');

    --     HR_APR_OCCURRENCE_ATTR

        occurrence:= wf_engine.GetItemAttrNumber(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_OCCURRENCE_ATTR');

    --     HR_APR_ITEM_CLASS_ATTR

        itemClass:= wf_engine.GetItemAttrText(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ITEM_CLASS_ATTR');

    --     HR_APR_ITEM_ID_ATTR

        itemId:= wf_engine.GetItemAttrText(itemtype=>p_item_type,
                      itemkey=>p_item_key,
                      aname=>'HR_APR_ITEM_ID_ATTR');

notification_rec.notification_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_CONTEXT_NID_ATTR');
notification_rec.user_comments := wf_notification.getattrtext(
       			notification_rec.notification_id
       		       ,'WF_NOTE');


	  begin
	  ame_api6.updateApprovalStatus2(applicationIdIn=>c_application_id,
                                   transactionTypeIn =>c_transaction_type,
                                   transactionIdIn=>c_transaction_id,
                                   approvalStatusIn =>ame_util.rejectStatus,
                                   approverNameIn =>l_current_forward_to_username,
                                   itemClassIn => itemClass,
                                   itemIdIn => itemId,
                                   actionTypeIdIn=> actionTypeId,
                                   groupOrChainIdIn => groupOrChainId,
                                   occurrenceIn => occurrence,
                                   notificationIn => notification_rec,
                                   forwardeeIn =>ame_util.emptyApproverRecord2,
                                  updateItemIn =>false);

	  exception
	  when others then
	     if g_debug then
                hr_utility.set_location('Error in  updateRejectStatus SQLERRM' ||' '||to_char(SQLCODE),10);
             end if;
	     raise;
          end ;

		begin
			ame_api2.getNextApprovers4
			(applicationIdIn  => c_application_id
			,transactionTypeIn => c_transaction_type
			,transactionIdIn => c_transaction_id
			,flagApproversAsNotifiedIn=>ame_util.booleanFalse
			,approvalProcessCompleteYNOut => c_approvalprocesscompleteynout
			,nextApproversOut => c_next_approvers);

		exception
		when others then
		null;
		end;


         if g_debug then
	    hr_utility.set_location('returned from calling ame_api2.updateApprovalStatus2', 8);
        end if;

         result := wf_engine.eng_trans_default;
       else
         null;
       end if;
/*
        -- transfer the approval action to history
        -- call PQH_SS_HISTORY.transfer_approval_to_history
           updateApprovalHistory( p_item_type=>p_item_type,
                           p_item_key=>p_item_key,
                           p_act_id=>p_act_id,
                           funmode=>funmode,
                           result=>result);*/


     end if;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 20);
     end if;
exception
  when others then
    if g_debug then
      hr_utility.set_location('Error in  updateRejectStatus SQLERRM' ||' '||to_char(SQLCODE),30);
    end if;
    raise;
end updateRejectStatus;

END HR_APPROVAL_SS;

/
