--------------------------------------------------------
--  DDL for Package Body HR_APPRAISAL_WORKFLOW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPRAISAL_WORKFLOW_SS" AS
/* $Header: hrapwfss.pkb 120.5.12010000.2 2009/04/21 06:10:32 sbrahmad ship $ */


-- Global Variables
gv_package                  CONSTANT VARCHAR2(100)   DEFAULT 'hr_appraisal_workflow_ss';
g_debug                     boolean default  false ;
g_invalid_appraisal_id      exception;
g_invalid_participant_id      exception;
g_orig_system               constant varchar2(3) DEFAULT 'PER';
g_no_system_params          exception;
g_oa_media     constant varchar2(100) DEFAULT fnd_web_config.web_server||'OA_MEDIA/';
g_oa_html      constant varchar2(100) DEFAULT fnd_web_config.jsp_agent;
--
-- Private Variables
--

--
-- PRIVATE FUNCTIONS
--
FUNCTION isAppraiseeFeebackAllowed
(p_appraisal_id IN number) RETURN VARCHAR2;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< item_attribute_exists >------------------------|
-- ----------------------------------------------------------------------------
function item_attribute_exists
  (p_item_type in wf_items.item_type%type
  ,p_item_key  in wf_items.item_key%type
  ,p_name      in wf_item_attribute_values.name%type)
  return boolean is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_dummy  number(1);
  l_return boolean := TRUE;
  -- cursor determines if an attribute exists
  cursor csr_wiav is
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = p_name;
  --
begin
  -- open the cursor
  open csr_wiav;
  fetch csr_wiav into l_dummy;
  if csr_wiav%notfound then
    -- item attribute does not exist so return false
    l_return := FALSE;
  end if;
  close csr_wiav;
  return(l_return);
end item_attribute_exists;



procedure setAppraisalSystemParams
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2)  is
    --local variables
   ln_appraisal_id number;
   l_system_params per_appraisals.system_params%type;
begin
   -- Do nothing in cancel or timeout mode
   if (funmode <> wf_engine.eng_run) then
     result := wf_engine.eng_null;
     return;
    else
     ln_appraisal_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'APPRAISAL_ID',true);
     if(ln_appraisal_id is null) then
        raise g_invalid_appraisal_id;
     else
        -- get the system params from per_appraisals
        begin
        select system_params
        into l_system_params
        from per_appraisals
        where appraisal_id=ln_appraisal_id;

        -- add the itemkey to the system params
        l_system_params := l_system_params ||'&pItemKey='||itemkey;


        -- update the itemkey value for the current transaction
        update per_appraisals
        set
        system_params              = l_system_params
        where appraisal_id = ln_appraisal_id;
        exception
        when no_data_found then
          raise g_no_system_params;
        when others then
           raise;
        end;
     end if;
   end if;
   result:= 'COMPLETE:';

exception
  when others then
    Wf_Core.Context(gv_package, '.setAppraisalSystemParams', itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end setAppraisalSystemParams;



-- ----------------------------------------------------------------------------
-- |----------------------------< start_transaction >-------------------------|
-- ----------------------------------------------------------------------------
procedure start_transaction
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2)
 is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc                     varchar2(72);
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
  ln_login_person_id      number;
  ln_appraisal_id         number;
  --
begin

g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  l_proc     := gv_package||'start_transaction';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;
    ln_login_person_id := wf_engine.getitemattrnumber(itemtype,itemkey,'CREATOR_PERSON_ID',true);
    ln_assignment_id    := wf_engine.getitemattrnumber(itemtype,itemkey,'ASSIGNMENT_ID',true);
    ln_appraisal_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'APPRAISAL_ID',true);
    ln_selected_person_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HR_APPRAISEE_PERSON_ID',true);
    lv_process_name       := wf_engine.GetItemAttrNumber(itemtype,itemkey,'PROCESS_NAME',true);

    hr_transaction_ss.start_transaction(itemtype=>itemtype
                                        ,itemkey=>itemkey
                                        ,actid=>itemkey
                                        ,funmode=>funmode
                                        ,p_login_person_id=>ln_login_person_id
                                        ,p_product_code=>'PER'
                                        ,p_status=>'W'
                                        ,p_function_id=>''
                                        ,p_transaction_ref_table=>'PER_APPRAISALS'
                                        ,p_transaction_ref_id=>ln_appraisal_id
                                        ,p_transaction_type=>'#WF'
                                        ,p_assignment_id=>ln_assignment_id
                                        ,p_selected_person_id=>ln_selected_person_id
                                        ,p_transaction_effective_date=>trunc(sysdate)
                                        ,p_process_name=>lv_process_name
                                        ,result=>result) ;
exception
  when others then
    raise;
  --
end start_transaction;


PROCEDURE  create_hr_transaction
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
-- local variables
l_appraisal_id per_appraisals.appraisal_id%type;
l_main_appraiser_id per_appraisals.main_appraiser_id%type;
l_appraiser_person_id per_appraisals.appraiser_person_id%type;
l_appraisee_person_id per_appraisals.appraisee_person_id%type;
l_system_params per_appraisals.system_params%type;
l_system_type per_appraisals.system_type%type;
l_assignment_id per_appraisals.assignment_id%type;
l_username wf_users.name%type;
l_appraisee_user_name wf_users.name%type;
l_supervisor_user_name wf_users.name%type;
l_main_appraiser_user_name wf_users.name%type;
l_display_name wf_users.display_name%type;

begin
    hr_utility.set_location('Entered:'|| gv_package || '.create_hr_transaction', 1);
    -- get the appraisal_id from the item attribute , APPRAISAL_ID
    l_appraisal_id:= wf_engine.GetItemAttrNumber (itemtype => p_itemtype ,
                             itemkey  => p_itemkey ,
                             aname => 'APPRAISAL_ID',
                             ignore_notfound=>true);
    -- query the other details from per_appraisals for the given  l_appraisal_id
    -- check if l_appraisal_id is null, if null throw an error
    if(l_appraisal_id is not null) then
       select APPRAISAL_ID, MAIN_APPRAISER_ID,APPRAISER_PERSON_ID,
              APPRAISEE_PERSON_ID,SYSTEM_PARAMS,system_type,assignment_id
       into   l_appraisal_id,l_main_appraiser_id, l_appraiser_person_id,
              l_appraisee_person_id,l_system_params,l_system_type,l_assignment_id
       from per_appraisals
       where APPRAISAL_ID=l_appraisal_id;
    else
      raise g_invalid_appraisal_id;
    end if;

    -- initialize the item attributes
     -- HR_MAIN_APPRAISER
      hr_workflow_service.create_hr_directory_services
                              (p_item_type         => p_itemtype
                              ,p_item_key          => p_itemkey
                              ,p_service_name      => 'HR_MAIN_APPRAISER'
                              ,p_service_person_id => l_main_appraiser_id);
    -- details for the current person record
    --CURRENT_PERSON
      hr_workflow_service.create_hr_directory_services
                              (p_item_type         => p_itemtype
                              ,p_item_key          => p_itemkey
                              ,p_service_name      => 'CURRENT_PERSON'
                              ,p_service_person_id => l_appraisee_person_id);
      --HR_APPRAISEE_USER_NAME_ATTR
        -- get the role  for the Appraisee
        wf_directory.getrolename(g_orig_system,l_appraisee_person_id,l_appraisee_user_name,l_display_name);

        if(item_attribute_exists(p_itemtype,p_itemkey,'HR_APPRAISEE_USER_NAME_ATTR')) then
          wf_engine.setitemattrtext(p_itemtype,p_itemkey,'HR_APPRAISEE_USER_NAME_ATTR',l_appraisee_user_name);
        else
          wf_engine.additemattr(p_itemtype,p_itemkey,'HR_APPRAISEE_USER_NAME_ATTR',l_appraisee_user_name,null,null);
        end if;
      --SUPERVISOR_USERNAME
      -- get the role for appraisee supervisor
        wf_directory.getrolename(g_orig_system,l_main_appraiser_id,l_supervisor_user_name,l_display_name);
        if(item_attribute_exists(p_itemtype,p_itemkey,'SUPERVISOR_USERNAME')) then
          wf_engine.setitemattrtext(p_itemtype,p_itemkey,'SUPERVISOR_USERNAME',l_supervisor_user_name);
        else
          wf_engine.additemattr(p_itemtype,p_itemkey,'SUPERVISOR_USERNAME',l_supervisor_user_name,null,null);
        end if;


    --
    --set the RFC call back function
      if(item_attribute_exists(p_itemtype,p_itemkey,'HR_RFC_CB_ATTR')) then
          wf_engine.setitemattrtext(p_itemtype,p_itemkey,'HR_RFC_CB_ATTR','hr_appraisal_workflow_ss.set_appraisal_rfc_status');
      else
          wf_engine.additemattr(p_itemtype,p_itemkey,'HR_RFC_CB_ATTR','hr_appraisal_workflow_ss.set_appraisal_rfc_status',null,null);
      end if;

    -- 06/02/03
    -- 06/15/03
    start_transaction( p_itemtype,p_itemkey, p_actid, p_funcmode , p_result  );

    -- 07/10/03
    -- set the item key to the system params
       setAppraisalSystemParams(p_itemtype,p_itemkey, p_actid, p_funcmode, p_result );
       p_result:= wf_engine.eng_trans_default;


    hr_utility.set_location('Leaving:'|| gv_package || '.create_hr_transaction', 10);

EXCEPTION
    WHEN OTHERS THEN
      wf_core.Context(gv_package, '.create_hr_transaction', p_itemtype, p_itemkey, p_actid, p_funcmode);
      hr_utility.trace(' exception in  '||gv_package||'.create_hr_transaction : ' || sqlerrm);
      raise;

end create_hr_transaction;

procedure build_link(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2) is
c_proc  varchar2(30) default 'GetItemAttrText';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
lv_checkProfile   VARCHAR2(10);
lv_profileValue   VARCHAR2(1);
lv_status         hr_api_transactions.status%type;
lv_link_label wf_message_attributes_vl.display_name%type;
lv_pageFunc       wf_item_attribute_values.text_value%type;
lv_web_html_call  fnd_form_functions_vl.web_html_call%type;
lv_params         fnd_form_functions_vl.parameters%type;
lv_addtnlParams   VARCHAR2(30)  ;


begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| gv_package||'.'||c_proc, 1);
  end if;

  -- get the itemtype and item key for the notification id
     hr_workflow_ss.get_item_type_and_key(document_id,lv_item_type,lv_item_key);
  --   IF (lv_checkProfile = 'N' OR lv_profileValue ='Y' ) THEN
         -- get the translated display name for the url link
         begin
            select wma.display_name
             into   lv_link_label
             from   wf_notifications  wn, wf_message_attributes_vl  wma
             where  wn.notification_id  = document_id
             and    wn.message_name     = wma.message_name
             and    wma.message_type    = lv_item_type
             and    wma.name            = 'OBJECT_URL';
          exception
          when others then
                lv_link_label:= 'OBJECT_URL';
         end;

       -- build the url link
          --  get the link details
          --  get the item attribute holding the FND function name corresponding
          --  to the MDS document.
          lv_pageFunc :=  nvl(wf_engine.GetItemAttrText(lv_item_type,lv_item_key,'HR_OAF_EDIT_URL_ATTR',TRUE),'PQH_SS_EFFDATE');
          -- get the web_html_call value and params for this function
          begin
            select web_html_call,parameters
            into lv_web_html_call,lv_params
            from fnd_form_functions_vl
            where function_name=lv_pageFunc;
          exception
          when no_data_found then
             hr_utility.set_location('Unable to retrieve function details,web_html_call and parameters for:'||lv_pageFunc||' '|| gv_package||'.'||c_proc, 10);
          when others then
           raise;
       end;
        -- set the out variables
	lv_addtnlParams := '&'||'retainAM=Y'||'&'||'NtfId='||'&'||'#NID';
          document :=  '<tr><td> '||
          --  '<IMG SRC="'||g_oa_media||'afedit.gif"/>'||
            '</td><td>'||
            '<a href='
            --||g_oa_html
            ||lv_web_html_call||nvl(lv_params,'')||lv_addtnlParams||'>'
            ||lv_link_label||'</a></td></tr> ';
         -- set the document type
          document_type  := wf_notification.doc_html;

   --  else
  --      document := null;
--     end if;

 if g_debug then
    hr_utility.set_location('Leaving:'|| gv_package||'.'||c_proc, 30);
 end if;

exception
when others then
    document := null;
    document_type  :=null;
    hr_utility.set_location('hr_workflow_ss.build_edit_link errored : '||SQLERRM ||' '||to_char(SQLCODE), 20);
    Wf_Core.Context('hr_workflow_ss', 'build_edit_link', document_id, display_type);
    raise;
end build_link;


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
    prole wf_users.name%type; -- Fix 3210283.
    expand_role varchar2(1);

    colon pls_integer;
    avalue varchar2(240);
    notid pls_integer;
    comments wf_notifications .user_comment%type;
    document varchar2(240);
    document_type varchar2(240);

begin
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     return;
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
    Wf_Core.Context(gv_package, 'Notify', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Notify;

procedure notify_appraisee_or_appraiser(itemtype   in varchar2,
		         itemkey    in varchar2,
      		     actid      in number,
		         funcmode   in varchar2,
		         resultout  in out nocopy varchar2)
is
    --local variables
    ignore_notfound boolean default true;

begin

   if(funcmode=wf_engine.eng_run) then
      --check if we need to notify Main Appraiser,
      -- this will be the only mode this function will
      -- run the first time. On all other occassions it is
      -- in notified state and need to complete using the proper result code
      -- get the item attribute value , HR_BLOCK_ATTR
      if(wf_engine.getitemattrtext(itemtype,itemkey,'HR_BLOCK_ATTR',ignore_notfound)='N') then
         resultout:='HR_MAIN_APPRAISER';
         -- now reset item attribute so that next pass will block this activity
         wf_engine.setitemattrtext(itemtype,itemkey,'HR_BLOCK_ATTR','Y');
         -- check the item attribute 'HR_MAIN_APPRAISER_USERNAME' exists
         -- do we need make the check ???
      else
         resultout:=wf_engine.eng_notified;
         -- update the item attribute with the current activity id to
         -- be completed from external java or pl/sql program.
         -- HR_APPRAI_MAIN_BLOCK_ID_ATTR
         wf_engine.setitemattrnumber(itemtype,itemkey,'HR_APPRAI_MAIN_BLOCK_ID_ATTR',actid);
      end if;
   end if;




exception
  when others then
    Wf_Core.Context(gv_package, '.notify_appraisee_or_appraiser', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end notify_appraisee_or_appraiser;
procedure reset_appr_ntf_status(itemtype   in varchar2,
		         itemkey    in varchar2,
      		     actid      in number,
		         funcmode   in varchar2,
		         resultout  in out nocopy varchar2)
is
    --local variables

begin
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     return;
   end if;


--resultout := 'NOTIFIED';

exception
  when others then
    Wf_Core.Context(gv_package, '.reset_appr_ntf_status', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end reset_appr_ntf_status;
procedure block(itemtype   in varchar2,
		         itemkey    in varchar2,
      		     actid      in number,
		         funcmode   in varchar2,
		         resultout  in out nocopy varchar2)
is
    --local variables

begin
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     return;
   end if;


--resultout := 'NOTIFIED';

exception
  when others then
    Wf_Core.Context(gv_package, 'block', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end block;
procedure find_next_participant(itemtype   in varchar2,
		         itemkey    in varchar2,
      		     actid      in number,
		         funcmode   in varchar2,
		         resultout  in out nocopy varchar2)
is
    --local variables
 lv_participants_list    wf_item_attribute_values.text_value%type default '';
 ln_particpant_person_id varchar2(100);
 lv_particpant_user_name varchar2(320);
 lv_particpant_display_name varchar2(360);
 check_sep number;
 ignore_notfound boolean default true;
 test number;

begin
  -- test mode
  test := wf_engine.GetItemAttrNumber(itemtype,itemkey,'COUNTER',ignore_notfound);
  -- update the counter
  wf_engine.SetItemAttrNumber(itemtype,itemkey,'COUNTER',test+1);
  if(test >10) then
     resultout := 'COMPLETE:F';
     return;
  end if;

  -- end test mode
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     return;
   end if;

   if(funcmode=wf_engine.eng_run) then

     --   get the list HR_APPRA_PARTIC_LIST_ID_ATTR
     lv_participants_list := wf_engine.GetItemAttrText(itemtype,itemkey,'HR_APPRA_PARTIC_LIST_ID_ATTR',ignore_notfound);


      -- check if the list is empty
       if((lv_participants_list is null) or lv_participants_list='') then
         -- we have reached end of list
         resultout := 'COMPLETE:F';
         return;
       end if;

     -- check if the value has any delimiter in it
     select instr(lv_participants_list,hr_general_utilities.g_separator) into check_sep from dual;
     if(check_sep=0) then
        -- no seperator(delimiter) found
        ln_particpant_person_id := lv_participants_list;
        lv_participants_list := null;
     else
        -- reset the list
        ln_particpant_person_id := substr(lv_participants_list,1,instr(lv_participants_list,hr_general_utilities.g_separator)-1);
        lv_participants_list := substr(lv_participants_list,instr(lv_participants_list,hr_general_utilities.g_separator)+length(hr_general_utilities.g_separator));
     end if;
      -- get the role details for the  participant and set the item attributes
      wf_directory.getrolename(g_orig_system,ln_particpant_person_id,lv_particpant_user_name,lv_particpant_display_name);
      -- set the details to the performer for the participant
      --      HR_APPRA_PARTIC_USER_NAME_ATTR and HR_APPRA_PARTIC_DISP_NAME_ATTR , HR_APPRA_PARTICP_PER_ID_ATTR
      wf_engine.setitemattrtext(itemtype,itemkey,'HR_APPRA_PARTIC_USER_NAME_ATTR',lv_particpant_user_name);
      wf_engine.setitemattrtext(itemtype,itemkey,'HR_APPRA_PARTIC_DISP_NAME_ATTR',lv_particpant_display_name);
      wf_engine.setitemattrtext(itemtype,itemkey,'HR_APPRA_PARTICP_PER_ID_ATTR',ln_particpant_person_id);

      -- update the  lv_participants_list into item attribute        HR_APPRA_PARTIC_LIST_ID_ATTR
      wf_engine.setitemattrtext(itemtype,itemkey,'HR_APPRA_PARTIC_LIST_ID_ATTR',lv_participants_list);
      resultout := 'COMPLETE:T';

    end if;
exception
  when others then
    Wf_Core.Context(gv_package, '.find_next_participant', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end find_next_participant;

procedure branch_on_participant_type(itemtype   in varchar2,
		         itemkey    in varchar2,
      		     actid      in number,
		         funcmode   in varchar2,
		         resultout  in out nocopy varchar2)
is
    --local variables
ln_participant_person_id wf_item_attribute_values.number_value%type ;
lv_particpant_user_name varchar2(320);
lv_particpant_display_name varchar2(360);
lv_participant_type per_participants.participation_type%type;
ln_participant_id per_participants.participant_id%type;
ln_appraisal_id     number;
type_value          varchar2(30);
begin
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     return;
   end if;

   if(funcmode=wf_engine.eng_run) then
     -- get the Appraisal id
     ln_appraisal_id:= wf_engine.getitemattrNumber(itemtype,itemkey,'APPRAISAL_ID');
     -- get the partcipant id
     ln_participant_id := wf_engine.getitemattrNumber(itemtype,itemkey,'HR_APPRA_PARTICP_ID_ATTR');
     --ln_participant_person_id := wf_engine.getitemattrNumber(itemtype,itemkey,'HR_APPRA_PARTICP_PER_ID_ATTR');

     if(ln_appraisal_id is null) then
       raise g_invalid_appraisal_id;
     elsif (ln_participant_id is null) then
       raise g_invalid_participant_id;
     end if;
     -- participant person id and type from per_participants
     -- for the given appraisal id
     select person_id,participation_type
     into ln_participant_person_id,lv_participant_type
     from per_participants
     where participation_in_id = ln_appraisal_id
     and participant_id=ln_participant_id;

     -- get the role details for the  participant and set the item attributes
      wf_directory.getrolename(g_orig_system,ln_participant_person_id,lv_particpant_user_name,lv_particpant_display_name);
      -- set the details to the performer for the participant
      --      HR_APPRA_PARTIC_USER_NAME_ATTR and HR_APPRA_PARTIC_DISP_NAME_ATTR , HR_APPRA_PARTICP_PER_ID_ATTR
      wf_engine.setitemattrtext(itemtype,itemkey,'HR_APPRA_PARTIC_USER_NAME_ATTR',lv_particpant_user_name);
      wf_engine.setitemattrtext(itemtype,itemkey,'HR_APPRA_PARTIC_DISP_NAME_ATTR',lv_particpant_display_name);
      wf_engine.setitemattrtext(itemtype,itemkey,'HR_APPRA_PARTICP_PER_ID_ATTR',ln_participant_person_id);

     -- HR_APPRA_APPRAISER,HR_APPRA_OTHER_PARTICP,HR_APPRA_REVIEWER
     -- MAINAP REVIEWER GROUPAPPRAISER OTHERPARTICIPANT

     if(lv_participant_type='GROUPAPPRAISER') then
        type_value := 'HR_APPRA_APPRAISER';
     elsif(lv_participant_type='REVIEWER') then
        type_value := 'HR_APPRA_REVIEWER';
     elsif(lv_participant_type='OTHERPARTICIPANT') then
        type_value := 'HR_APPRA_OTHER_PARTICP';
     end if;

   end if;

resultout := 'COMPLETE:'||type_value;



exception
  when others then
    Wf_Core.Context(gv_package, '.branch_on_participant_type', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end branch_on_participant_type;


procedure participants_block
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
-- this will be used when the participants notification is sent.
-- and to complete the blocked thread.
-- HR_APPRAI_PARTCI_BLOCK_ID_ATTR
   wf_engine.setitemattrnumber(itemtype,itemkey,'HR_APPRAI_PARTCI_BLOCK_ID_ATTR',actid);
   WF_STANDARD.BLOCK(itemtype,itemkey,actid,funmode,result);

--resultout := 'NOTIFIED';

exception
  when others then
    Wf_Core.Context(gv_package, '.participants_block', itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end participants_block;

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
-- this will be used when the participants notification is sent.
-- and to complete the blocked thread.
-- HR_APPRAI_PARTCI_BLOCK_ID_ATTR

   if not hr_workflow_service.item_attribute_exists
          (p_item_type => itemtype
          ,p_item_key  => itemkey
          ,p_name      => 'HR_COMPETENCE_ENHANCEMENT_SS') then
     -- the item attribute does not exist so create it
     wf_engine.additemattr
              (itemtype => itemtype
              ,itemkey  => itemkey
              ,aname    => 'HR_COMPETENCE_ENHANCEMENT_SS');
   end if;
   wf_engine.setitemattrnumber(itemtype,itemkey,'HR_APPRAI_APPR_BLOCK_ID_ATTR',actid);
   WF_STANDARD.BLOCK(itemtype,itemkey,actid,funmode,result);

--resultout := 'NOTIFIED';

exception
  when others then
    Wf_Core.Context(gv_package, '.approvals_block', itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end approvals_block;

 procedure appraisee_or_appraiser_block
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2)
  is
    --local variables
    ignore_notfound boolean default true;

begin

   if(funmode=wf_engine.eng_run) then
    result:=wf_engine.eng_notified;
         -- update the item attribute with the current activity id to
         -- be completed from external java or pl/sql program.
         -- HR_APPRAI_MAIN_BLOCK_ID_ATTR
         wf_engine.setitemattrnumber(itemtype,itemkey,'HR_APPRAI_MAIN_BLOCK_ID_ATTR',actid);
    end if;
exception
  when others then
    Wf_Core.Context(gv_package, '.appraisee_or_appraiser_block', itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end appraisee_or_appraiser_block;


procedure getApprovalBlockId (p_itemType in VARCHAR2
                             ,p_itemKey    in VARCHAR2
                              ,p_blockId      OUT NOCOPY NUMBER)
is
lv_procedure_name varchar2(30) default 'getPageDetails';
ln_appr_main_block_id number;
ln_appr_particp_block_id number;
ln_appr_approval_block_id number;

begin
    ln_appr_main_block_id := wf_engine.getitemattrnumber(getApprovalBlockId.p_itemType,getApprovalBlockId.p_itemKey,'HR_APPRAI_MAIN_BLOCK_ID_ATTR');
    ln_appr_particp_block_id:= wf_engine.getitemattrnumber(getApprovalBlockId.p_itemType,getApprovalBlockId.p_itemKey,'HR_APPRAI_PARTCI_BLOCK_ID_ATTR');
     begin
       if(hr_utility.debug_enabled) then
        -- write debug statements
        hr_utility.set_location('Querying WF_ITEM_ACTIVITY_STATUSES for notified activity:'||lv_procedure_name||'with itemtype:', 3);
       end if;

       SELECT process_activity
       into ln_appr_approval_block_id
       FROM   WF_ITEM_ACTIVITY_STATUSES IAS
       WHERE  ias.item_type          = p_itemType
       and    ias.item_key           = p_itemKey
       and    ias.activity_status    = 'NOTIFIED'
       and    ias.process_activity   not in
                            (getApprovalBlockId.ln_appr_main_block_id,getApprovalBlockId.ln_appr_particp_block_id);

     exception
     when no_data_found then
           if(hr_utility.debug_enabled) then
          -- write debug statements
           hr_utility.set_location('no notified activity found in WF_ITEM_ACTIVITY_STATUSES  for itemtype:'|| p_itemType||' and item key:'||p_itemType, 4);
          end if;
      ln_appr_approval_block_id := null;
     when others then
       ln_appr_approval_block_id := null;
    end;

    begin
    -- finally if ln_appr_approval_block_id is null check if we have notified activities
       if(ln_appr_approval_block_id is null) then
       SELECT process_activity
       into ln_appr_approval_block_id
       FROM   WF_ITEM_ACTIVITY_STATUSES IAS
       WHERE  ias.item_type          = p_itemType
       and    ias.item_key           = p_itemKey
       and    ias.activity_status    = 'NOTIFIED'
       and    ias.notification_id is not null;
       end if;
    exception
    when no_data_found then
        wf_core.Context(gv_package, '.getApprovalBlockId', p_itemtype, p_itemkey);
        hr_utility.trace(' exception in  '||gv_package||'.getApprovalBlockId : ' || sqlerrm);
    when others then
	raise;
    end;
    p_blockId := ln_appr_approval_block_id;
exception
when others then
 wf_core.Context(gv_package, '.getApprovalBlockId', p_itemtype, p_itemkey);
 hr_utility.trace(' exception in  '||gv_package||'.getApprovalBlockId : ' || sqlerrm);
 raise;
end  getApprovalBlockId;



PROCEDURE  reset_main_appraiser
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
-- local variables
l_appraisal_id per_appraisals.appraisal_id%type;
l_main_appraiser_id per_appraisals.main_appraiser_id%type;
l_role_name varchar2(320);
l_role_displayname varchar2(360);

begin
    hr_utility.set_location('Entered:'|| gv_package || '.reset_main_appraiser', 1);
    -- get the appraisal_id from the item attribute , APPRAISAL_ID
    l_appraisal_id:= wf_engine.GetItemAttrNumber (itemtype => p_itemtype ,
                             itemkey  => p_itemkey ,
                             aname => 'APPRAISAL_ID',
                             ignore_notfound=>true);
        -- query the other details from per_appraisals for the given  l_appraisal_id
    -- check if l_appraisal_id is null, if null throw an error
    if(l_appraisal_id is not null) then
       select MAIN_APPRAISER_ID
       into   l_main_appraiser_id
       from per_appraisals
       where APPRAISAL_ID=l_appraisal_id;
    else
      raise g_invalid_appraisal_id;
    end if;

    -- initialize the item attributes
     -- HR_MAIN_APPRAISER
      hr_workflow_service.create_hr_directory_services
                              (p_item_type         => p_itemtype
                              ,p_item_key          => p_itemkey
                              ,p_service_name      => 'HR_MAIN_APPRAISER'
                              ,p_service_person_id => l_main_appraiser_id);
      -- reset the owner for the wf transaction
        wf_directory.getRoleName(p_orig_system => 'PER'
                                ,p_orig_system_id => l_main_appraiser_id
                                ,p_name => l_role_name
                                ,p_display_name => l_role_displayname);

    -- ---------------------------------------------------
    -- Set the Item Owner
    -- ---------------------------------------------------
       wf_engine.setItemOwner(itemtype => p_itemtype
                             ,itemkey => p_itemkey
                              ,owner => l_role_name);
      --CREATOR_PERSON
       hr_workflow_service.create_hr_directory_services
                              (p_item_type         => p_itemtype
                              ,p_item_key          => p_itemkey
                              ,p_service_name      => 'CREATOR_PERSON'
                              ,p_service_person_id => l_main_appraiser_id);
      --

    p_result := wf_engine.eng_trans_default;



    hr_utility.set_location('Leaving:'|| gv_package || '.reset_main_appraiser', 10);

EXCEPTION
    WHEN OTHERS THEN
      wf_core.Context(gv_package, '.reset_main_appraiser', p_itemtype, p_itemkey, p_actid, p_funcmode);
      hr_utility.trace(' exception in  '||gv_package||'.reset_main_appraiser : ' || sqlerrm);
      raise;

end reset_main_appraiser;

PROCEDURE  commit_transaction
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
-- local variables
l_appraisal_id per_appraisals.appraisal_id%type;
lv_result varchar2(3);
begin
    hr_utility.set_location('Entered:'|| gv_package || '.commit_transaction', 1);
    hr_utility.set_location('calling hr_complete_appraisal_ss.complete_appr', 2);
    hr_complete_appraisal_ss.complete_appr(p_itemtype,p_itemkey,lv_result);
    hr_utility.set_location('returned from  hr_complete_appraisal_ss.complete_appr with result:'
                                                             ||lv_result, 3);
    /*
     E : Error -- ntf to MA, HR/Sysadmin
     W : Warning -- ntf MA
     S: Success
    */
    if(lv_result='S' or lv_result='W') then
       p_result:= 'COMPLETE:SUCCESS';
    else
       p_result:= 'COMPLETE:APPLICATION_ERROR';
    end if;
    hr_utility.set_location('Leaving:'|| gv_package || '.commit_transaction', 10);

EXCEPTION
    WHEN OTHERS THEN
      wf_core.Context(gv_package, '.commit_transaction', p_itemtype, p_itemkey, p_actid, p_funcmode);
      hr_utility.trace(' exception in  '||gv_package||'.commit_transaction : ' || sqlerrm);
      raise;

end commit_transaction;



PROCEDURE  update_appraisal_system_status
( p_itemtype in varchar2
, p_itemkey in varchar2
,p_status   in varchar2
)
is
-- local variables
l_appraisal_id per_appraisals.appraisal_id%type;
l_appraiser_person_id per_appraisals.appraiser_person_id%type;
l_object_version_number per_appraisals.object_version_number%type;
l_system_params per_appraisals.system_params%type;

begin
    hr_utility.set_location('Entered:'|| gv_package || '.update_appraisal_system_status', 1);
    -- get the appraisal_id from the item attribute , APPRAISAL_ID
    if(hr_utility.debug_enabled) then
          -- write debug statements
    	hr_utility.set_location('Calling wf_engine.GetItemAttrNumber for APPRAISAL_ID with itemtype:itemkey '||p_itemtype||':'||p_itemkey,2);
    end if;
    l_appraisal_id:= wf_engine.GetItemAttrNumber (itemtype => p_itemtype ,
                             itemkey  => p_itemkey ,
                             aname => 'APPRAISAL_ID',
                             ignore_notfound=>true);
    begin
    -- get the required data from the per_appraisals for the update
     select appraiser_person_id, object_version_number,system_params
        into l_appraiser_person_id,l_object_version_number,l_system_params
    from per_appraisals
   where appraisal_id=l_appraisal_id;
 l_system_params := replace(l_system_params,'&pItemKey=' || p_itemkey ,'');
    exception
    when others then
      raise;
    end;
    -- call the api to update the system status
      if(hr_utility.debug_enabled) then
          -- write debug statements
        hr_utility.set_location('Calling hr_appraisals_api.update_appraisal with p_appraisal_id:
                                 p_object_version_number:p_appraiser_person_id:p_appraisal_system_status '
                                 || l_appraisal_id||':'||l_object_version_number||':'
                                 ||l_appraiser_person_id||p_status,3);
      end if;

     hr_appraisals_api.update_appraisal(p_effective_date=>trunc(sysdate),
                     p_appraisal_id=>l_appraisal_id,
                     p_object_version_number=>l_object_version_number,
                     p_appraiser_person_id=>l_appraiser_person_id,
                     p_appraisal_system_status=>p_status  --7210916 Bug Fix ,
                    --p_system_params => l_system_params
                    );

    hr_utility.set_location('Leaving:'|| gv_package || '.update_appraisal_system_status', 10);

EXCEPTION
    WHEN OTHERS THEN
      wf_core.Context(gv_package, '.update_appraisal_system_status', p_itemtype, p_itemkey);
      hr_utility.trace(' exception in  '||gv_package||'.update_appraisal_system_status : ' || sqlerrm);
      raise;

end update_appraisal_system_status;

PROCEDURE  set_appraisal_rfc_status
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
-- local variables

begin
    hr_utility.set_location('Entered:'|| gv_package || '.set_appraisal_rfc_status', 1);

    -- call the update_appraisal_system_status with proper status
       update_appraisal_system_status(p_itemtype=>p_itemtype, p_itemkey=>p_itemkey,p_status=>'RFC');

    hr_utility.set_location('Leaving:'|| gv_package || '.set_appraisal_rfc_status', 10);

EXCEPTION
    WHEN OTHERS THEN
      wf_core.Context(gv_package, '.set_appraisal_rfc_status', p_itemtype, p_itemkey, p_actid, p_funcmode);
      hr_utility.trace(' exception in  '||gv_package||'.set_appraisal_rfc_status : ' || sqlerrm);
      raise;

end set_appraisal_rfc_status;

PROCEDURE  set_appraisal_reject_status
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
-- local variables

begin
    hr_utility.set_location('Entered:'|| gv_package || '.set_appraisal_reject_status', 1);

    -- call the update_appraisal_system_status with proper status
       update_appraisal_system_status(p_itemtype=>p_itemtype, p_itemkey=>p_itemkey,p_status=>'ONGOING');
    -- set the our param as *
       p_result:='COMPLETE:*';
      wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'TRAN_SUBMIT','N');

    hr_utility.set_location('Leaving:'|| gv_package || '.set_appraisal_reject_status', 10);

EXCEPTION
    WHEN OTHERS THEN
      wf_core.Context(gv_package, '.set_appraisal_reject_status', p_itemtype, p_itemkey, p_actid, p_funcmode);
      hr_utility.trace(' exception in  '||gv_package||'.set_appraisal_reject_status : ' || sqlerrm);
      raise;

end set_appraisal_reject_status;

PROCEDURE  notify_appraisee_on_completion
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
-- local variables

begin
    hr_utility.set_location('Entered:'|| gv_package || '.notify_appraisee_on_completion', 1);
    --bug 4403850, to support old appraisals on upgrade, set the appraisal system status to COMPLETED,
    -- if APPRFEEDBACK
    appraisee_commit_aft_feedback(p_itemtype, p_itemkey, p_actid, p_funcmode, p_result);
    hr_complete_appraisal_ss.send_notification(p_itemtype,
                                               p_itemkey,
                                               p_result);
    hr_utility.set_location('Leaving:'|| gv_package || '.set_appraisal_commit_status', 10);


EXCEPTION
    WHEN OTHERS THEN
      wf_core.Context(gv_package, '.notify_appraisee_on_completion', p_itemtype, p_itemkey, p_actid, p_funcmode);
      hr_utility.trace(' exception in  '||gv_package||'.notify_appraisee_on_completion : ' || sqlerrm);
      raise;

end notify_appraisee_on_completion;


procedure build_ma_compl_log_msg(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2) is
c_proc  varchar2(30) default 'build_ma_compl_log_msg';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| gv_package||'.'||c_proc, 1);
  end if;
  -- get the itemtype and item key for the notification id
  hr_workflow_ss.get_item_type_and_key(document_id,lv_item_type,lv_item_key);
  -- build the log message, the log is restricted to 32k
  -- assumed the code setting the item attributes has the necessary format.
  document :=  wf_engine.GetItemAttrText(lv_item_type,
                                         lv_item_key,
                                         hr_complete_appraisal_ss.gv_upd_appr_status_log,
                                         true)
               ||wf_engine.GetItemAttrText(lv_item_type,
                                           lv_item_key,
                                           hr_complete_appraisal_ss.gv_apply_asses_comps_log,
                                           true)
               ||wf_engine.GetItemAttrText(lv_item_type,
                                           lv_item_key,
                                           hr_complete_appraisal_ss.gv_create_event_log,
                                           true)
              || wf_engine.GetItemAttrText(lv_item_type,
                                           lv_item_key,
                                           hr_complete_appraisal_ss.gv_upd_trn_act_status_log ,
                                           true);

  -- set the document type
  document_type  := wf_notification.doc_html;

  if g_debug then
    hr_utility.set_location('Leaving:'|| gv_package||'.'||c_proc, 30);
  end if;

exception
when others then
    document := null;
    document_type  :=null;
    hr_utility.set_location('hr_appraisal_workflow_ss.build_ma_compl_log_msg errored : '
                            ||SQLERRM ||' '||to_char(SQLCODE), 20);
    Wf_Core.Context('hr_workflow_ss', 'build_ma_compl_log_msg',
                            document_id, display_type);
    raise;
end build_ma_compl_log_msg;


FUNCTION isAppraiseeFeebackAllowed
(p_appraisal_id IN number) RETURN VARCHAR2
IS
l_provide_feedback PER_APPRAISALS.provide_overall_feedback%TYPE;

BEGIN
 SELECT NVL(appr.provide_overall_feedback,'N')
   INTO l_provide_feedback
   from per_appraisals appr
  where appr.appraisal_id = p_appraisal_id;

  RETURN l_provide_feedback;

END isAppraiseeFeebackAllowed;

PROCEDURE  appraisee_feedback_allowed
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
-- local variables
l_appraisal_id per_appraisals.appraisal_id%type;

l_log varchar2(4000);
lv_chg_appr_status_log wf_item_attributes.text_default%TYPE;
chg_appr_status varchar2(2);
begin
    hr_utility.set_location('Entered:'|| gv_package || '.appraisee_feedback_allowed', 1);

    l_appraisal_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype ,
                             itemkey  => p_itemkey ,
                             aname => 'APPRAISAL_ID',
                             ignore_notfound=>true);

        if l_appraisal_id is null then
         l_log := l_log || 'Error: No Appraisal Id for this WorkFlow Transaction';
         hr_utility.trace(l_log);
        end if;


    hr_utility.trace('calling isAppraiseeFeebackAllowed');
    chg_appr_status := isAppraiseeFeebackAllowed(p_appraisal_id => l_appraisal_id);
    hr_utility.trace('returned from isAppraiseeFeebackAllowed with result:'
                      ||chg_appr_status);

   if ( chg_appr_status = 'Y' ) then
            p_result := 'COMPLETE:'||'Y' ; -- TBD shud be made 'Y' for testing
   else
            p_result := 'COMPLETE:'||'N' ;
   end if;


    hr_utility.set_location('Exiting:'|| gv_package || '.appraisee_feedback_allowed', 1);


  exception
    when others then
        wf_core.Context(gv_package,'.appraisee_feedback_allowed',p_itemtype, p_itemkey
                                            , p_actid,p_funcmode );
        hr_utility.trace('Exception in ' || gv_package || '.appraisee_feedback_allowed' ||
                            sqlerrm );
        raise ;
end appraisee_feedback_allowed;

PROCEDURE  appraisee_commit_aft_feedback
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
-- local variables
l_appraisal_id per_appraisals.appraisal_id%type;

l_log varchar2(4000);
lv_chg_appr_status_log wf_item_attributes.text_default%TYPE;
chg_appr_status varchar2(2);
begin
    hr_utility.set_location('Entered:'|| gv_package || '.appraisee_commit_aft_feedback', 1);

    l_appraisal_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype ,
                             itemkey  => p_itemkey ,
                             aname => 'APPRAISAL_ID',
                             ignore_notfound=>true);

        if l_appraisal_id is null then
         l_log := l_log || 'No Appraisal Id for this WorkFlow Transaction';
         --raise ; -- Should raise an Exception ?????
        end if;

    hr_utility.set_location('calling hr_complete_appraisal_ss.change_appr_status', 2);
    hr_complete_appraisal_ss.change_appr_status(l_appraisal_id, p_itemtype,p_itemkey,
                                        lv_chg_appr_status_log,chg_appr_status);


  p_result := 'COMPLETE:SUCCESS';
    hr_utility.set_location('Exiting:'|| gv_package || '.appraisee_commit_aft_feedback', 1);

  exception
    when others then
        wf_core.Context(gv_package,'.appraisee_commit_aft_feedback',p_itemtype, p_itemkey
                                            , p_actid,p_funcmode );
        hr_utility.trace('Exception in ' || gv_package || '.appraisee_commit_aft_feedback' ||
                            sqlerrm );
        raise ;
end   appraisee_commit_aft_feedback ;

PROCEDURE  notify_appraisee
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
is
begin

   if (p_funcmode <> wf_engine.eng_run) then
     p_result := wf_engine.eng_null;
     return;
   end if;

    Notify(itemtype => p_itemtype,
           itemkey  => p_itemkey,
      	   actid    => p_actid,
		   funcmode => p_funcmode,
		   resultout=> p_result );

    -- check if item attribute 'HR_APPR_NOTIF_BLOCK_ID_ATTR' already exists
    if not hr_workflow_service.item_attribute_exists
        (p_item_type => p_itemtype
        ,p_item_key  => p_itemkey
        ,p_name      => 'HR_APPR_NOTIF_BLOCK_ID_ATTR') then
    -- the item attribute does not exist so create it
        wf_engine.additemattr
          (itemtype => p_itemtype
          ,itemkey  => p_itemkey
          ,aname    => 'HR_APPR_NOTIF_BLOCK_ID_ATTR');
    end if;

    wf_engine.setitemattrnumber(p_itemtype,p_itemkey,'HR_APPR_NOTIF_BLOCK_ID_ATTR',p_actid);
    WF_STANDARD.BLOCK(p_itemtype,p_itemkey,p_actid,p_funcmode,p_result);   --TBD uncomment this line

    exception
  when others then
    Wf_Core.Context(gv_package, '.notify_appraisee', p_itemtype,
                    p_itemkey, to_char(p_actid), p_funcmode);
    raise;
end notify_appraisee;

FUNCTION isAppraiser
  (
    p_notification_id in wf_notifications.item_key%type,
    p_loggedin_person_id in number
  )RETURN varchar2
IS
 l_result varchar2(2) := 'N';
 l_person_id wf_roles.orig_system_id%type;
BEGIN

 select orig_system_id into l_person_id from WF_NOTIFICATIONS ,wf_roles
   WHERE
 notification_id=p_notification_id and
 recipient_role = name and
 orig_system = 'PER';

 if (l_person_id= p_loggedin_person_id) then
   l_result := 'Y';
 end if;

  return  l_result;
exception
when others then
 return 'N';

END  isAppraiser;


end hr_appraisal_workflow_ss;   -- Package body

/
