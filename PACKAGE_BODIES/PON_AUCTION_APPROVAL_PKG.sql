--------------------------------------------------------
--  DDL for Package Body PON_AUCTION_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUCTION_APPROVAL_PKG" as
/* $Header: PONAPPRB.pls 120.11.12010000.20 2014/11/14 06:36:35 spapana ship $ */
/*=======================================================================+
 |  Copyright (c) 1995, 2014 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   PONAPPRB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package PON_AUCTION_APPROVAL_PKG
 |
 | NOTES
 |   PL/SQL  routines for negotiation approvals
 |
 | HISTORY
 | Date            UserName   Description
 | -------------------------------------------------------------------------------------------
 |
 | 25-Aug-05      sparames    Bug 4295915: Missing owner in Sourcing notifications
 |                            Added call to wf_engine.SetItemOwner
 |
 | 09-Sep-05  120.25   sparames   ECO 4456420: Added setting of ORIGIN_USER_NAME to the
 |                                current user for most operations
 |
 |
 =========================================================================+*/


FUNCTION Get_Emd_Update_Url (pn_aunction_header_id NUMBER)
RETURN VARCHAR2
IS
l_ext_fwk_agent     VARCHAR2(240);
l_auction_header_id NUMBER := pn_aunction_header_id;
l_emd_update_link   VARCHAR2(4000);

BEGIN
  -- Access the Sourcing external APPS_FRAMEWORK_AGENT
  --
  l_ext_fwk_agent := FND_PROFILE.value('PON_EXT_APPS_FRAMEWORK_AGENT');
  --
  -- If the profile is not set, then try the default responsibility approach
  --
  IF (l_ext_fwk_agent IS NULL) THEN
    --
     l_ext_fwk_agent := FND_PROFILE.value('APPS_FRAMEWORK_AGENT');
  END IF;
  --
  -- add OA_HTML/OA.jsp to the profile value
  --
  IF ( l_ext_fwk_agent IS NOT NULL ) THEN
    --
    IF ( substr(l_ext_fwk_agent, -1, 1) = '/' ) THEN
      --RETURN l_ext_fwk_agent ||  'OA_HTML/OA.jsp';
      l_ext_fwk_agent := l_ext_fwk_agent ||  'OA_HTML/OA.jsp';
    ELSE
      --RETURN l_ext_fwk_agent || '/' || 'OA_HTML/OA.jsp';
      l_ext_fwk_agent := l_ext_fwk_agent || '/' || 'OA_HTML/OA.jsp';
    END IF;

    l_emd_update_link := l_ext_fwk_agent || '?'|| 'page=/oracle/apps/pon/emd/creation/webui/ponEmdUpdatePG'
     || '&' ||'akRegionApplicationId=396' || '&' ||'OAHP=PON_EMD_ADMIN_HOME'||'&'||'OASF=PON_EMD_UPDATE'
     ||'&'||'OAPB=PON_SOURCING_BRAND'||'&'|| 'notificationId=&' || '#NID'  ||'&'||'language_code=' || fnd_global.current_language;
  -- No profiles are setup so return nothing...
  --
  ELSE
   l_emd_update_link :=  '';
  END IF;

  Return l_emd_update_link;
  --dbms_output.put_line(l_emd_update_link);
END Get_Emd_Update_Url;

-- choli add for emd update page link in notification
Procedure Get_Emd_HeaderId(pn_notification_id IN NUMBER,
l_auction_header_id OUT NOCOPY NUMBER)  IS

CURSOR wf_item_cur IS
  SELECT item_type,
         item_key
  FROM   wf_item_activity_statuses
  WHERE  notification_id  = pn_notification_id;
  CURSOR wf_notif_context_cur IS
  SELECT SUBSTR(context,1,INSTR(context,':',1)-1),
         SUBSTR(context,INSTR(context,':')+1,
                       (INSTR(context,':',1,2) - INSTR(context,':')-1)),
         message_name
  FROM   wf_notifications
  WHERE  notification_id   = pn_notification_id;

  p_itemtype WF_ITEM_ACTIVITY_STATUSES.item_type%TYPE;  -- VARCHAR2(8)
  p_itemkey  WF_ITEM_ACTIVITY_STATUSES.item_key%TYPE;   -- VARCHAR2(240)

  p_message_name wf_notifications.message_name%TYPE;

  BEGIN


   -- Fetch the item_type and item_key values from
   -- wf_item_activity_statuses for a given notification_id.
   OPEN wf_item_cur;
   FETCH wf_item_cur INTO p_itemtype, p_itemkey;
   CLOSE wf_item_cur;

   -- If the wf_item_activity_statuses does not contain an entry,
   -- then parse the wf_notifications.context field to
   -- get the item_type and item_key values for a given notification_id.
   IF ((p_itemtype IS NULL) AND (p_itemkey IS NULL))
   THEN
        OPEN  wf_notif_context_cur;
        FETCH wf_notif_context_cur INTO p_itemtype, p_itemkey, p_message_name;
        CLOSE wf_notif_context_cur;

   END IF;

   IF (p_itemtype = 'PONAPPRV' or p_itemtype = 'PONAWAPR') THEN
                l_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname    => 'AUCTION_HEADER_ID');
   END IF;


END Get_Emd_HeaderId;


Procedure Process_If_Doc_Approved(p_auction_header_id number,
                  p_top_process_item_key Varchar2) is
l_approved_count number;
l_approval_count number;
l_activity_status Varchar2(80);
l_item_type Varchar2(30) := 'PONAPPRV';
l_auction_approval_status Varchar2(30);
begin
select count(auction_header_id),
       nvl(sum(decode(approval_status,'APPROVED',1,0)),0)
into l_approval_count,l_approved_count
from pon_neg_team_members
where auction_header_id = p_auction_header_id
--FOR ERIC TEST ONLY,BEGIN
---------------------------------------------------------
--and approver_flag='Y';
  AND ( approver_flag = 'Y'  --for emd module
      );
---------------------------------------------------------
--FOR ERIC TEST ONLY,END
if l_approval_count =0 then
   l_auction_approval_status := 'NOT_REQUIRED';
elsif l_approval_count = l_approved_count then
   l_auction_approval_status := 'APPROVED';
else
   l_auction_approval_status := 'REQUIRED';
end if;

-- The doucment is approved
 if (l_auction_approval_status = 'APPROVED' or
     l_auction_approval_status = 'NOT_REQUIRED') then
     begin
      select activity_label
      into l_activity_status
      from wf_item_activity_statuses_v
      where item_type = 'PONAPPRV'
      and item_key = p_top_process_item_key
      and activity_status_code = 'NOTIFIED';
     exception when others then
             l_activity_status := 'DO Nothing';
     end;
 -- time to move the parent activity to the approved state
     if l_activity_status = 'WAITFOR APPROVALS' then
          if (l_auction_approval_status = 'APPROVED') then
             wf_engine.CompleteActivity(l_item_type,p_top_process_item_key,l_activity_status,'APPROVED');
        else wf_engine.CompleteActivity(l_item_type,p_top_process_item_key,l_activity_status,'NOT_REQUIRED');
          end if;
     end if;
 end if; -- APPROVED
End Process_If_Doc_Approved;

Procedure Process_Doc_Rejected(p_auction_header_id number, p_top_process_item_key Varchar2) is
l_activity_status Varchar2(80);
l_item_type Varchar2(30) := 'PONAPPRV';
begin
 begin
   select activity_label
   into l_activity_status
   from wf_item_activity_statuses_v
   where item_type = 'PONAPPRV'
   and item_key = p_top_process_item_key
   and activity_status_code = 'NOTIFIED';
 exception when others then
          l_activity_status := 'DO Nothing';
 end;
 -- time to move the parent activity to the rejected state
  if l_activity_status = 'WAITFOR APPROVALS' then
      wf_engine.CompleteActivity(l_item_type,p_top_process_item_key,l_activity_status,'REJECTED');
  end if;
End Process_Doc_Rejected;

PROCEDURE CANCEL_NOTIFICATION(p_auction_header_id number,
                                    p_user_name varchar2,
                                    p_resultOut out nocopy number) is
l_itemKey varchar2(240);
l_parent_process_itemKey varchar2(240);
l_itemType varchar2(25):= 'PONAPPRV';
l_nid number;
l_replied varchar2(1);
l_auction_status varchar2(30);
l_user_status varchar2(30);
l_user_approval varchar2(30);
l_user_id number;
begin
-- need to change after understanding requirment from Datta
p_resultOut := 0;
-- Check to see if this user has already approved
begin

   -- use user_id wherever possible
   select user_id
     into l_user_id
     from fnd_user
    where user_name = p_user_name;




select neg.approver_flag, neg.approval_status, auc.approval_status,
       wf_approval_item_key
into l_user_approval,l_user_status,l_auction_status,l_parent_process_itemKey
from pon_neg_team_members neg, pon_auction_headers_all auc
where auc.auction_header_id = p_auction_header_id
and neg.auction_header_id= auc.auction_header_id
and neg.user_id = l_user_id;

-- update user as  not an approver
update pon_neg_team_members
set approver_flag ='N'
where auction_header_id = p_auction_header_id
and user_id = l_user_id;
l_itemKey := l_parent_process_itemKey || '_' || l_user_id;
/* Select notification Id from the item key and user name */
select notification_id
into   l_nid
from WF_ITEM_ACTIVITY_STATUSES
where ASSIGNED_USER = p_user_name
and ITEM_TYPE = l_itemType
and ITEM_KEY = l_itemkey
and activity_status ='NOTIFIED';
WF_Notification.cancel(l_nid);
exception
when others then
p_resultOut := 1; -- unexpected
end;
/* Check for doc approval conditions */
Process_If_Doc_Approved(p_auction_header_id,l_parent_process_itemKey);

end CANCEL_NOTIFICATION;

PROCEDURE UPDATE_NOTIF_ONLINE (p_auction_header_id number,
                                    p_user_name varchar2,
                                    p_result varchar2,
                                    p_note_to_buyer varchar2,
                                    p_resultOut out nocopy number) is
l_itemKey varchar2(240);
l_itemType varchar2(25):= 'PONAPPRV';
l_nid number;
l_replied varchar2(1);
l_auction_status varchar2(30);
l_user_status varchar2(30);
l_user_approval varchar2(30);
l_user_id number;
begin
p_resultOut := 0;

   -- use user_id wherever possible
   select user_id
     into l_user_id
     from fnd_user
    where user_name = p_user_name;

-- Check to see if this user has already approved
begin
select neg.approver_flag, neg.approval_status, auc.approval_status,
       wf_approval_item_key
into l_user_approval,l_user_status,l_auction_status,l_itemKey
from pon_neg_team_members neg, pon_auction_headers_all auc
where auc.auction_header_id = p_auction_header_id
and neg.auction_header_id= auc.auction_header_id
and neg.user_id = l_user_id;

-- the item key for the user will be
l_itemKey := l_itemKey || '_' || l_user_id;
/* Select notification Id from the item key and user name */
begin
select notification_id
into   l_nid
from WF_ITEM_ACTIVITY_STATUSES
where ASSIGNED_USER = p_user_name
and ITEM_TYPE = l_itemType
and ITEM_KEY = l_itemkey
and activity_status ='NOTIFIED';
exception when no_data_found then
/* This is a situation where the user responded using E-Mail and
   edited the decision with a typo!!
*/
User_Decision_Without_WF(l_user_id, p_result, p_note_to_buyer,
                         p_auction_header_id);
return;
end;
wf_notification.SetAttrText(l_nid, 'RESULT',p_result);
wf_notification.SetAttrText(l_nid, 'APPROVER_NOTES',p_note_to_buyer);
WF_Notification.respond(l_nid,p_result,p_user_name);
exception
when others then
p_resultOut := 1; -- unexpected
end;

end UPDATE_NOTIF_ONLINE;

Procedure Close_Child_Process(p_parent_item_key Varchar2) is
Cursor List_of_Process(p_item_type varchar2, p_parent_item_key Varchar2) is
   select activity_label, item_key,notification_id
   from wf_item_activity_statuses_v
   where item_type = p_item_type
   and item_key like p_parent_item_key || '_%'
   and activity_status_code = 'NOTIFIED';
l_item_type Varchar2(30) :=  'PONAPPRV';
begin
for r1 in List_of_Process(l_item_type,p_parent_item_key) loop
 begin
    WF_Notification.cancel(r1.notification_id);

--Bug 9386801
--Uncommenting the CompleteActivity because of which
--workflow was not ending and resulting in unneeded reminder
--notifications after one approver rejects
     wf_engine.CompleteActivity(l_item_type,r1.item_key,
                     r1.activity_label,'CLOSE');

 exception when others then null;
 end;
end loop;

End Close_Child_Process;

PROCEDURE UPDATE_DOC_TO_CANCELLED ( itemtype in varchar2,
                                Itemkey		in varchar2,
                                actid	        in number,
                                uncmode		in varchar2,
                                resultout	out nocopy varchar2) is

l_auction_header_id NUMBER;
begin
l_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'AUCTION_HEADER_ID');
update pon_auction_headers_all
  set auction_status = 'CANCELLED'
  where auction_header_id=l_auction_header_id;

end UPDATE_DOC_TO_CANCELLED;

/* Entry procedure to start document approval process.
*/

PROCEDURE SUBMIT_FOR_APPROVAL(p_auction_header_id_encrypted   VARCHAR2,    -- 1
                              p_auction_header_id             number,      -- 2
                              p_note_to_approvers             varchar2,    -- 3
                              p_submit_user_name              varchar2,    -- 4
                              p_redirect_func                 varchar2) is -- 5
l_seq varchar2(100);
l_itemKey varchar2(240);
l_itemType varchar(25) := 'PONAPPRV';
l_creator_user_name varchar2(100);
l_creator_full_name varchar2(240);
l_creator_user_id number;
l_close_bidding_date date;
l_open_bidding_date  date;
l_auction_title varchar2(80);
l_creator_time_zone varchar2(80);
l_doctype_group_name varchar2(100);
l_doc_number  varchar2(25);
l_msg_suffix varchar2(10);
l_auction_contact_id number;
l_language_code varchar2(100);
l_timezone      varchar2(100);
l_timezone_disp varchar2(100);
l_oex_timezone varchar2(100);
l_url_preview  varchar2(500);
l_url_modify   varchar2(500);
l_timeout_factor number;
l_open_date_in_tz date;
l_close_date_in_tz date;
l_open_auction_now_flag varchar2(1);
l_trading_partner_name          PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE;
l_trading_partner_contact_name  PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
l_auction_start_date            PON_AUCTION_HEADERS_ALL.OPEN_BIDDING_DATE%TYPE;
l_auction_end_date              PON_AUCTION_HEADERS_ALL.CLOSE_BIDDING_DATE%TYPE;
l_round_number                  NUMBER;
l_amendment_number              NUMBER;
l_auction_header_id_orig_amend  NUMBER;
l_orig_document_number          PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
l_review_changes_url            VARCHAR2(2000);
l_preview_date   	        DATE;
l_preview_date_in_tz            DATE;
l_timezone1_disp                VARCHAR2(240);
l_submit_user_id number;

--SLM UI Enhancement
l_is_slm_doc VARCHAR2(1);
l_neg_assess_doctype VARCHAR2(15);

/* Get FND user name from trading_partner_contact_id */
CURSOR c_auction_info IS
select fnd.user_name, fnd.user_id, pon.close_bidding_date,
       pon.auction_title,
       decode(nvl(pon.open_auction_now_flag,'N'),'Y',to_date(null),pon.open_bidding_date) open_bidding_date,
       nvl(pon.open_auction_now_flag,'N') open_auction_now_flag,
       pon.document_number, trading_partner_contact_id, trading_partner_name, trading_partner_contact_name,
       open_bidding_date, close_bidding_date, nvl(auction_round_number, 1),
       nvl(amendment_number, 0), auction_header_id_orig_amend, view_by_date
from fnd_user fnd,pon_auction_headers_all pon
where fnd.person_party_id = pon.trading_partner_contact_id and
      pon.auction_header_id = p_auction_header_id and
      rownum=1;

begin

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
        message  => 'Start  ');
END IF; --}

--SLM UI Enhancement : Get message_suffix from other api that checks for SLM?
-- Bug 20015921 : Calling IS_SLM_DOCUMENT function here so that global varaible  g_is_slm_doc will be set to true/false.
-- Based on this we frame the URLs like l_review_changes_url based on this flag.
l_is_slm_doc := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_header_id);
l_msg_suffix := PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE_SUFFIX(l_is_slm_doc, l_doctype_group_name);
l_neg_assess_doctype := PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE(l_is_slm_doc);

OPEN c_auction_info;
FETCH c_auction_info
INTO l_creator_user_name, l_creator_user_id, l_close_bidding_date,l_auction_title,
     l_open_bidding_date,
     l_open_auction_now_flag,
     l_doc_number,
     l_auction_contact_id, l_trading_partner_name, l_trading_partner_contact_name,
     l_auction_start_date, l_auction_end_date, l_round_number,
     l_amendment_number, l_auction_header_id_orig_amend, l_preview_date;
CLOSE c_auction_info;

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
        message  => 'l_creator_user_name = '||l_creator_user_name||' l_creator_user_id = '|| l_creator_user_id||
                    ' l_close_bidding_date = '|| l_close_bidding_date|| ' l_auction_title = ' || l_auction_title || ' l_is_slm_doc = ' || l_is_slm_doc);
END IF; --}

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
        message  => 'l_open_bidding_date = '||l_open_bidding_date||
                    ' l_open_auction_now_flag = '|| l_open_auction_now_flag||
                    ' l_doc_number = '|| l_doc_number|| ' l_auction_contact_id = ' || l_auction_contact_id);
END IF; --}

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
        message  => 'l_trading_partner_name = '||l_trading_partner_name||
                    'l_trading_partner_contact_name  = '|| l_trading_partner_contact_name ||
                    ' l_auction_start_date = '|| l_auction_start_date|| ' l_round_number = ' || l_round_number);
END IF; --}

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
        message  => 'l_amendment_number = '||l_amendment_number||
        'l_auction_header_id_orig_amend  = '|| l_auction_header_id_orig_amend || 'l_preview_date = '|| l_preview_date);
END IF; --}

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
        message  => 'l_language_code : ' || l_language_code);
END IF; --}



/* Get sequence number to construct itemKey */
 PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(l_creator_user_id,l_language_code);

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
FND_LOG.string(log_level => FND_LOG.level_statement,
  module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
  message  => 'l_creator_user_id : '|| l_creator_user_id ||';'||' l_language_code : ' || l_language_code);
END IF; --}

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => '1. Calling SET_SESSION_LANGUAGE with l_language_code : ' || l_language_code);
END IF; --}

 PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null,l_language_code);

select to_char(PON_AUCTION_WF_APPROVALS_S.NEXTVAL)
into l_seq from sys.dual;

l_itemKey := to_char (p_auction_header_id)|| '-' || l_seq;

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' l_itemKey = '||l_itemKey);
END IF; --}

wf_engine.createProcess ( itemType  => l_itemType,
                          itemKey   => l_itemKey,
                          process   => 'SOURCINGAPPROVAL');


-- call to notification utility package to set the message header common attributes and #from_role
pon_wf_utl_pkg.set_hdr_attributes (p_itemtype	      => l_itemType
		                          ,p_itemkey	      => l_itemKey
                                  ,p_auction_tp_name  => l_trading_partner_name
	                              ,p_auction_title    => l_auction_title
	                              ,p_document_number  => l_doc_number
                                  ,p_auction_tp_contact_name => l_trading_partner_contact_name);



 -- call to notification utility package to get the redirect page url that
 -- is responsible for getting the Review and Submit page url and forward to it.
 l_review_changes_url := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func        => 'PON_NEG_CRT_HEADER'
                                 ,p_notif_performer  => 'BUYER');

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' l_review_changes_url = '||l_review_changes_url);
END IF; --}

 -- new item attribute to hold the redirect Function. Attribute value is going
 -- to be used as a parameter to access Review and Submit page
 wf_engine.SetItemAttrText (itemtype   => l_itemType,
                            itemkey    => l_itemKey,
                            aname      => 'REVIEWPG_REDIRECTFUNC',
                            avalue     => p_redirect_func);

 wf_engine.SetItemAttrText (itemtype   => l_itemType,
                            itemkey    => l_itemKey,
                            aname      => 'REVIEW_CHANGES_URL',
                            avalue     => l_review_changes_url);

  wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TRADING_PARTNER_CONTACT_ID',
                             avalue     => l_auction_contact_id);

 wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                               itemkey    => l_itemKey,
                               aname      => 'AUCTION_START_DATE',
                               avalue     => l_open_bidding_date);

 wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                               itemkey    => l_itemKey,
                               aname      => 'AUCTION_END_DATE',
                               avalue     => l_close_bidding_date);

wf_engine.SetItemAttrText   (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TOP_PROCESS_ITEM_KEY',
                             avalue     => l_itemKey);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_HEADER_ID',
                             avalue     => p_auction_header_id);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'DOC_ROUND_NUMBER',
                             avalue     => l_round_number);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'DOC_AMENDMENT_NUMBER',
                             avalue     => l_amendment_number);


wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TIMEOUT_MAINPROCESS',
                             avalue     => l_close_bidding_date);

wf_engine.SetItemAttrText  (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'CREATOR_USER_NAME',
                             avalue     => l_creator_user_name);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'CREATOR_USER_ID',
                             avalue     => l_creator_user_id);

            select dt.doctype_group_name
            into l_doctype_group_name
            from pon_auction_headers_all auh, pon_auc_doctypes dt
            where auh.auction_header_id = p_auction_header_id
            and auh.doctype_id = dt.doctype_id;

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' l_doctype_group_name = '||l_doctype_group_name);
END IF; --}



--SLM UI Enhancement : SLM_DOC_TYPE attribute will be used to set
--negotiation or assessment in notification messages.
PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => l_itemType,
                                            p_itemkey  => l_itemKey,
                                            p_value    => l_neg_assess_doctype);

wf_engine.SetItemAttrText  (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'MSG_SUFFIX',
                             avalue     => l_msg_suffix);
 -- Get the user's timezone
 l_timezone := PON_AUCTION_PKG.Get_Time_Zone(l_auction_contact_id);

 l_oex_timezone := PON_AUCTION_PKG.Get_Oex_Time_Zone;

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' l_timezone = '||l_timezone || ' l_oex_timezone = '||l_oex_timezone);
END IF; --}

 if (l_timezone is null or l_timezone = '' ) then
    l_timezone := l_oex_timezone;
 end if;


  IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(l_timezone) = 1) THEN
      l_open_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(l_open_bidding_date,l_oex_timezone,l_timezone);
      l_close_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(l_close_bidding_date,l_oex_timezone,l_timezone);
      l_preview_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(l_preview_date,l_oex_timezone,l_timezone);
  ELSE
      l_open_date_in_tz := l_open_bidding_date;
      l_close_date_in_tz := l_close_bidding_date;
      l_preview_date_in_tz := l_preview_date;
      l_timezone := l_oex_timezone;
  END IF;

l_timezone_disp := PON_AUCTION_PKG.Get_TimeZone_Description(l_timezone, l_language_code);

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' l_timezone_disp = '||l_timezone_disp);
END IF; --}

wf_engine.SetItemAttrText  (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TIMEZONE',
                             avalue     => l_timezone_disp);

  IF (l_preview_date IS NULL) THEN
      l_timezone1_disp := null;

      wf_engine.SetItemAttrDate (itemtype	=> l_itemtype,
				    itemkey	=> l_itemkey,
				    aname	=> 'PREVIEW_DATE',
				    avalue	=> null);

      wf_engine.SetItemAttrText (itemtype	=> l_itemtype,
				    itemkey	=> l_itemkey,
				    aname	=> 'TP_TIME_ZONE1',
				    avalue	=> l_timezone1_disp);

      wf_engine.SetItemAttrText (itemtype	=> l_itemtype,
				    itemkey	=> l_itemkey,
				    aname	=> 'PREVIEW_DATE_NOTSPECIFIED',
				    avalue	=> PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC',l_msg_suffix));
  ELSE
      l_timezone1_disp := l_timezone_disp;

      wf_engine.SetItemAttrDate (itemtype	=> l_itemtype,
				    itemkey	=> l_itemkey,
				    aname	=> 'PREVIEW_DATE',
				    avalue	=> l_preview_date_in_tz);

      wf_engine.SetItemAttrText (itemtype	=> l_itemtype,
				    itemkey	=> l_itemkey,
				    aname	=> 'TP_TIME_ZONE1',
				    avalue	=> l_timezone1_disp);

      wf_engine.SetItemAttrText (itemtype	=> l_itemtype,
				    itemkey	=> l_itemkey,
				    aname	=> 'PREVIEW_DATE_NOTSPECIFIED',
				    avalue	=> null);
  END IF;


wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_START_DATE',
                             avalue     => l_open_date_in_tz);
if (l_open_auction_now_flag = 'Y') then
   wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'OPEN_IMMEDIATELY',
                             avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_OPEN_IMM_AFTER_PUB',l_msg_suffix));

   wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'O_TIMEZONE',
                             avalue     => null);
else
   wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'OPEN_IMMEDIATELY',
                             avalue     =>null);
   wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'O_TIMEZONE',
                             avalue     => l_timezone_disp);
end if;

wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_END_DATE',
                             avalue     => l_close_date_in_tz);


wf_engine.SetItemAttrText  (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'NOTE_TO_APPROVERS',
                             avalue     => p_note_to_approvers);
select document_number
into   l_orig_document_number
from   pon_auction_headers_all
where  auction_header_id = l_auction_header_id_orig_amend;

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' l_orig_document_number = '||l_orig_document_number);
END IF; --}

-- set notification subjects
set_notification_subject(l_itemType, l_itemKey, l_msg_suffix, l_doc_number, l_orig_document_number, l_amendment_number, l_auction_title);

   /* Get the creator's full name */
   /*select emp.full_name into l_creator_full_name from
    per_all_people_f emp,
    fnd_user fnd
    where fnd.employee_id=emp.person_id and
       fnd.user_id = l_creator_user_id and
       trunc(sysdate) between emp.effective_start_date and emp.effective_end_date;*/
 l_creator_full_name := PON_LOCALE_PKG.get_party_display_name(l_auction_contact_id);

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' l_creator_full_name = '||l_creator_full_name);
END IF; --}

wf_engine.SetItemAttrText  (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTIONEER_NAME',
                             avalue     => l_creator_full_name);


wf_engine.SetItemAttrText  (itemtype    => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'ORIGIN_USER_NAME',
                             avalue     => fnd_global.user_name);


   -- use user_id wherever possible
   select user_id
     into l_submit_user_id
     from fnd_user
    where user_name = p_submit_user_name;

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' l_submit_user_id = '||l_submit_user_id);
END IF; --}

UPD_AUCTION_STATUSHISTORY(p_auction_header_id, 'SUBMIT',p_note_to_approvers,
                         l_submit_user_id,'USER');

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' updated action status history  ');
END IF; --}


-- Bug 4295915: Set the  workflow owner
wf_engine.SetItemOwner(itemtype => l_itemtype,
                       itemkey  => l_itemkey,
                       owner    => fnd_global.user_name);

wf_engine.StartProcess (itemType  => l_itemType,
                        itemKey   => l_itemKey );

/* Update Headers table */
UPDATE pon_auction_headers_all set
       wf_approval_item_key = l_itemKey,
       approval_status = 'INPROCESS'
WHERE auction_header_id = p_auction_header_id;

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'SUBMIT_FOR_APPROVAL',
   message  => ' updated auction header status ');
END IF; --}

--bug 7602688
PON_AUCTION_PKG.UNSET_SESSION_LANGUAGE;

end SUBMIT_FOR_APPROVAL;

PROCEDURE StartUserApprovalProcess(itemtype in varchar2,
                                   Itemkey         in varchar2,
                                   actid           in number,
                                   uncmode         in varchar2,
                                   resultout       out nocopy varchar2) is
l_auction_header_id number;
l_seq varchar2(100);
l_itemKey varchar2(240);
l_itemType varchar(25) := 'PONAPPRV';
l_creator_user_id number;
l_creator_full_name varchar2(240);
l_creator_user_name varchar2(100);
l_creator_session_lang_code varchar2(3);
l_creator_time_zone varchar2(80);
l_doctype_group_name varchar2(100);
l_msg_suffix varchar2(10);
l_auction_contact_id number;
l_language_code varchar2(3);
l_timezone      varchar2(100);
l_timezone_disp varchar2(100);
l_oex_timezone varchar2(100);
l_open_date_in_tz date;
l_close_date_in_tz date;
l_url_preview  varchar2(500);
l_url_modify   varchar2(500);
l_timeout_factor number;
l_subtab varchar(80);
l_note_to_approvers Varchar2(2000);
l_publish_auction_now_flag varchar2(1);
l_open_auction_now_flag varchar2(1);
l_reminder_date date;
l_preparer_tp_name  PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE;
l_auction_title     PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
l_doc_number        PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
l_preparer_tp_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
l_auction_start_date  DATE;
l_auction_end_date    DATE;
l_timezone_dsp       varchar2(100);
l_review_changes_url VARCHAR2(2000);
l_orig_document_number PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
l_round_number     NUMBER;
l_amendment_number NUMBER;
l_preview_date_in_tz   	    DATE;
l_timezone1_disp            varchar2(240);
l_preview_date_nspec        FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
l_redirect_func             VARCHAR2(50);

--SLM UI Enhancement
l_neg_assess VARCHAR2(15);

Cursor C_APPROVALS(p_auction_header_id number, p_timeout_factor number) is
select u.user_name user_name,
       u.user_id,
       auc.close_bidding_date close_bidding_date,
       auc.auction_title,
       decode(nvl(auc.open_auction_now_flag,'N'),'Y',to_date(null),auc.open_bidding_date) open_bidding_date,
       decode(nvl(auc.publish_auction_now_flag,'N'),'Y',to_date(null),auc.view_by_date) view_by_date,
       auc.document_number doc_number,
       trading_partner_contact_id auction_contact_id,
       nvl(auc.publish_auction_now_flag,'N') publish_auction_now_flag,
       nvl(auc.open_auction_now_flag,'N') open_auction_now_flag,
       auc.auction_header_id_orig_amend
from pon_neg_team_members neg, pon_auction_headers_all auc, fnd_user u
where neg.auction_header_id = auc.auction_header_id and
      auc.auction_header_id = p_auction_header_id
      and neg.APPROVER_FLAG ='Y'
      AND neg.MENU_NAME <> 'EMD_ADMIN' --FOR ERIC TEST ONLY
      and u.user_id = neg.user_id;
begin
--INSERT INTO ERIC_LOG VALUES ('INTO StartUserApprovalProcess','','','','','','','');--for eric test only

l_timeout_factor := .5; -- use to get this value from an item attribute
                        -- but WFLOAD was complaining....

if l_timeout_factor <= 0 or l_timeout_factor >=1 then
   l_timeout_factor := .5;
end if;

l_preparer_tp_name := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                   itemkey    => itemKey,
                                                   aname      => 'PREPARER_TP_NAME');

l_auction_title := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                   itemkey    => itemKey,
                                                   aname      => 'AUCTION_TITLE');

l_doc_number := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                   itemkey    => itemKey,
                                                   aname      => 'DOC_NUMBER');

l_preparer_tp_contact_name := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                          itemkey    => itemKey,
                                                          aname      => 'PREPARER_TP_CONTACT_NAME');

l_auction_start_date :=  wf_engine.GetItemAttrDate  (itemtype   => itemType,
                                                          itemkey    => itemKey,
                                                          aname      => 'AUCTION_START_DATE');

l_auction_end_date := wf_engine.GetItemAttrDate  (itemtype   => itemType,
                                                          itemkey    => itemKey,
                                                          aname      => 'AUCTION_END_DATE');

l_timezone_dsp           := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                          itemkey    => itemKey,
                                                          aname      => 'TIMEZONE');



l_note_to_approvers  := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                    itemkey    => itemKey,
                                                    aname      => 'NOTE_TO_APPROVERS');

   l_preview_date_in_tz     := wf_engine.GetItemAttrDate  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'PREVIEW_DATE');
   l_timezone1_disp     := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'TP_TIME_ZONE1');

   l_preview_date_nspec     := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'PREVIEW_DATE_NOTSPECIFIED');
l_msg_suffix := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                   itemkey    => itemKey,
                                                   aname      => 'MSG_SUFFIX');

l_auction_header_id := wf_engine.GetItemAttrNumber  (itemtype   => itemType,
                                                   itemkey    => itemKey,
                                                   aname      => 'AUCTION_HEADER_ID');

l_round_number := wf_engine.GetItemAttrNumber  (itemtype   => itemType,
                                                itemkey    => itemKey,
                                                aname      => 'DOC_ROUND_NUMBER');



l_amendment_number := wf_engine.GetItemAttrNumber  (itemtype   => itemType,
                                                   itemkey    => itemKey,
                                                   aname      => 'DOC_AMENDMENT_NUMBER');

l_creator_full_name:= wf_engine.GetItemAttrText  (itemtype   => itemType,
                             itemkey    => itemKey,
                             aname      => 'AUCTIONEER_NAME');

l_redirect_func:= wf_engine.GetItemAttrText  (itemtype   => itemType,
                                              itemkey    => itemKey,
                                              aname      => 'REVIEWPG_REDIRECTFUNC');

/* Preserve creator's session language */
l_creator_user_name :=      wf_engine.GetItemAttrText  (itemtype   => itemType,
                             itemkey    => itemKey,
                             aname      => 'CREATOR_USER_NAME');

l_creator_user_id :=      wf_engine.GetItemAttrNumber  (itemtype   => itemType,
                             itemkey    => itemKey,
                             aname      => 'CREATOR_USER_ID');

--SLM UI Enhancement
l_neg_assess := PON_SLM_UTIL_PKG.GET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype   => itemType,
                                                            p_itemkey    => itemKey);


PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(l_creator_user_id,l_creator_session_lang_code);

for r1 in C_APPROVALS(l_auction_header_id,l_timeout_factor) loop

 --INSERT INTO ERIC_LOG VALUES ('INTO for r1 in C_APPROVALS','','','','','','','');--for eric test only

 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'StartUserApprovalProcess',
   message  => 'r1.user_id : ' || r1.user_id);
 END IF; --}

 PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(r1.user_id,l_language_code);

 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'StartUserApprovalProcess',
   message  => 'r1.user_id : '|| r1.user_id ||';'|| 'l_language_code : ' || l_language_code);
 END IF; --}

 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 FND_LOG.string(log_level => FND_LOG.level_statement,
   module => g_module_prefix || 'StartUserApprovalProcess',
   message  => '1. Calling SET_SESSION_LANGUAGE with l_language_code : ' || l_language_code);
 END IF; --
-- bug 7602688 session language for workflow is already set in submit_for_approval procedure.
-- this process is called from 'sourcingapproval' workflow only. so no need to set again.
-- PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null,l_language_code);

--Bug 6472383 : If the Negotiation Preview date is mentioned as 'Not Specified', i.e. if the value of
-- l_preview_date_nspec is not null, we need to replace it with the string specific to recipient's language
 IF (l_preview_date_nspec is not null) THEN
      l_preview_date_nspec := PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC',l_msg_suffix);
 END IF;

l_itemKey := itemkey || '_' || r1.user_id;


wf_engine.createProcess ( itemType  => l_itemType,
                          itemKey   => l_itemKey,
                          process   => 'USERAPPROVALS');


if (r1.view_by_date is not null) then
l_reminder_date := r1.view_by_date;
elsif (r1.open_bidding_date is not null) then
l_reminder_date := r1.open_bidding_date;
else
l_reminder_date := r1.close_bidding_date;
end if;

select sysdate+((l_reminder_date - sysdate) * l_timeout_factor)
into l_reminder_date
from dual;

--SLM UI Enhancement
PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => l_itemType,
                                            p_itemkey => l_itemKey,
                                            p_value   => l_neg_assess);

wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TIMEOUT_USERPROCESS',
                             avalue     => l_reminder_date);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'CREATOR_USER_NAME',
                             avalue     => l_creator_user_name);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'CREATOR_USER_ID',
                             avalue     => l_creator_user_id);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'REVIEWPG_REDIRECTFUNC',
                             avalue     => l_redirect_func);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'PREPARER_TP_NAME',
                             avalue     => l_preparer_tp_name);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_TITLE',
                             avalue     => l_auction_title);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'DOC_NUMBER',
                             avalue     => l_doc_number);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'PREPARER_TP_CONTACT_NAME',
                             avalue     => l_preparer_tp_contact_name);

wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_START_DATE',
                             avalue     => l_auction_start_date);

wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_END_DATE',
                             avalue     => l_auction_end_date);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TIMEZONE',
                             avalue     => l_timezone_dsp);

wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'PREVIEW_DATE',
                             avalue     => l_preview_date_in_tz);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TP_TIME_ZONE1',
                             avalue     => l_timezone1_disp);


wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'PREVIEW_DATE_NOTSPECIFIED',
                             avalue     => l_preview_date_nspec);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'NOTE_TO_APPROVERS',
                             avalue     => l_note_to_approvers);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TOP_PROCESS_ITEM_KEY',
                             avalue     =>
                                  wf_engine.GetItemAttrText (itemtype   => l_itemType,
                                  itemkey    => itemKey,
                                  aname      => 'TOP_PROCESS_ITEM_KEY')
                             );

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_HEADER_ID',
                             avalue     => l_auction_header_id);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'DOC_ROUND_NUMBER',
                             avalue     => l_round_number);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'DOC_AMENDMENT_NUMBER',
                             avalue     => l_amendment_number);

l_review_changes_url := pon_wf_utl_pkg.get_dest_page_url (
                             p_dest_func        => 'PON_NEG_CRT_HEADER'
                             ,p_notif_performer  => 'BUYER');

--Bug 11898698
--Modifying the language_code in the URL with that of the recipient
--The profile "ICX_LANGUAGE" needs to be set for the recipient for this fix
l_review_changes_url:=regexp_replace(l_review_changes_url , 'language_code='||fnd_global.current_language, 'language_code='||l_language_code);

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'REVIEW_CHANGES_URL',
                             avalue     => l_review_changes_url);


wf_engine.SetItemAttrText   (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'APPOVER',
                             avalue     => r1.user_name);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'APPOVER_ID',
                             avalue     => r1.user_id);

wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'ORIGINAL_APPROVER_ID',
                             avalue     => r1.user_id);


wf_engine.SetItemAttrText   (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'ORIGIN_USER_NAME',
                             avalue     => fnd_global.user_name);

 l_timezone := PON_AUCTION_PKG.Get_Time_Zone(r1.user_name);

 l_oex_timezone := PON_AUCTION_PKG.Get_Oex_Time_Zone;

 if (l_timezone is null) then
    l_timezone := l_oex_timezone;
 end if;

 l_timezone_disp := PON_AUCTION_PKG.Get_TimeZone_Description(l_timezone, l_language_code);

  wf_engine.SetItemAttrText  (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'TIMEZONE',
                             avalue     => l_timezone_disp);

 l_open_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(r1.open_bidding_date,l_oex_timezone,l_timezone);
 l_close_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(r1.close_bidding_date,l_oex_timezone,l_timezone);

wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_START_DATE',
                             avalue     => l_open_date_in_tz);
if (r1.open_auction_now_flag = 'Y') then
   wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'OPEN_IMMEDIATELY',
                             avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_OPEN_IMM_AFTER_PUB',l_msg_suffix));

   wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'O_TIMEZONE',
                             avalue     => null);
else
   wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'OPEN_IMMEDIATELY',
                             avalue     =>null);

   wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'O_TIMEZONE',
                             avalue     => l_timezone_disp);
end if;

wf_engine.SetItemAttrDate (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'AUCTION_END_DATE',
                             avalue     => l_close_date_in_tz);


wf_engine.SetItemAttrText  (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'NOTE_TO_APPROVERS',
                             avalue     => l_note_to_approvers);

select document_number
into   l_orig_document_number
from   pon_auction_headers_all
where  auction_header_id = r1.auction_header_id_orig_amend;

-- set notification subjects
set_notification_subject(l_itemType, l_itemKey, l_msg_suffix, l_doc_number, l_orig_document_number, l_amendment_number, l_auction_title);

-- Bug 4295915: Set the  workflow owner
wf_engine.SetItemOwner(itemtype => l_itemtype,
                       itemkey  => l_itemkey,
                       owner    => fnd_global.user_name);

wf_engine.StartProcess (itemType  => l_itemType,
                        itemKey   => l_itemKey );
end loop;

/* Reset to creator's language */
-- bug 7602688
--PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null,l_creator_session_lang_code);

end StartUserApprovalProcess;


Function Is_Valid_Response(p_auction_header_id number,p_user_id varchar2,p_source VARCHAR2 DEFAULT 'USER')
             return Varchar2 is
l_result Varchar2(10) := 'N';
ls_error varchar2(4000); -- for eric test only
Begin
  --ADDED FOR ERIC TEST ONLY,BEGIN
  -----------------------------
  -- validate the response  source from EMD USER or NORMAL APPROVAL USER

  --INSERT INTO ERIC_LOG VALUES ('INTO Function Is_Valid_Response','','','','','','','');--for eric test only
  IF p_source ='EMD'
  THEN
    BEGIN
      SELECT 'Y'
        INTO l_result
        FROM
          pon_auction_headers_all auc
        , pon_neg_team_members    neg
       WHERE auc.auction_header_id = neg.auction_header_id
         AND auc.auction_header_id = p_auction_header_id
         AND auc.approval_status = 'INPROCESS'
         AND neg.user_id = p_user_id
         AND neg.MENU_NAME = 'EMD_ADMIN'
         and neg.approver_flag = 'Y'
         AND neg.approval_status IS NULL;
      EXCEPTION
      WHEN OTHERS
      THEN
      	ls_error := sqlcode||sqlerrm;
      	--INSERT INTO ERIC_LOG VALUES ('EMD Is_Valid_Response error : '||ls_error, 'l_result = '|| l_result,'p_user_id ='||p_user_id,'p_auction_header_id = '||p_auction_header_id,'','','','');--for eric test only
        l_result := 'N';
    END;

    --INSERT INTO ERIC_LOG VALUES ( 'p_source =EMD','l_result= '|| l_result,'','','','','','');--for eric test only
    RETURN (l_result) ;
  ELSE   --NORMAL APPROVAL USER
    begin
     select 'Y'
     into l_result
     from pon_auction_headers_all auc,
          pon_neg_team_members neg
     where auc.auction_header_id = neg.auction_header_id
     and auc.auction_header_id = p_auction_header_id
     and auc.approval_status = 'INPROCESS'
     and neg.user_id = p_user_id
     AND neg.MENU_NAME <> 'EMD_ADMIN' --FOR ERIC TEST ONLY
     and neg.approver_flag = 'Y'
     and neg.approval_status is null;
    exception when others then
         l_result := 'N';
    end;
    return(l_result);
  END IF;
End Is_Valid_Response;

PROCEDURE User_Approved(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              uncmode   in varchar2,
                              resultout  out nocopy varchar2) is
l_notes  varchar2(2000);
l_user_name varchar2(100);
l_user_id number;
l_auction_header_id number;
l_top_process_item_key  Varchar2(240);
l_result  Varchar2(30) := 'APPROVED';
l_original_approver_id number;
begin
/* Get auction header id from the workflow */
    l_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'AUCTION_HEADER_ID');

    l_user_name := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'APPOVER');

    l_user_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'APPOVER_ID');

    l_notes :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'APPROVER_NOTES');

    l_top_process_item_key := wf_engine.GetItemAttrText (itemtype   => itemType,
                                           itemkey    => itemKey,
                                           aname      => 'TOP_PROCESS_ITEM_KEY');
	l_original_approver_id	:=	wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORIGINAL_APPROVER_ID');

     wf_engine.SetItemAttrNumber (itemtype => itemtype,
                               itemkey  => l_top_process_item_key,
                               aname    => 'APPOVER_ID',
                               avalue => l_user_id);

     wf_engine.SetItemAttrText (itemtype => itemtype,
                               itemkey  => l_top_process_item_key,
                               aname    => 'APPOVER',
                               avalue => l_user_name);

/* Check is the responder a valid approver */
-- commented as part of bug 17173696 fix, as we are updating the approver id each time when
-- an action taken on negotiation, the below check fails and hence commenting it
--if (Is_Valid_Response(l_auction_header_id,l_user_id) = 'N') then
/* Responder is not a valid approver. Ignore this response */
  -- return;
--end if;

/* Insert a row into history table */
UPD_AUCTION_STATUSHISTORY(l_auction_header_id, l_result,
                         l_notes,l_user_id,'USER',l_original_approver_id);


Process_If_Doc_Approved(l_auction_header_id,l_top_process_item_key);


end User_approved;

/* This is a sort of "backup" to approve online if workflow
fails */
PROCEDURE User_Decision_Without_WF(p_user_id    in number,
                                   p_decision   in varchar2,
                                   p_notes      in varchar2,
                                   p_auctionHeaderId in number) is
l_top_process_itemKey varchar2(240);
begin
/* Check is the responder a valid approver */
if (Is_Valid_Response(p_auctionHeaderId,p_user_id) = 'N') then
/* Responder is not a valid approver. Ignore this response */
   return;
end if;

/* Insert a row into history table */
UPD_AUCTION_STATUSHISTORY(p_auctionHeaderId, p_decision,
                         p_notes, p_user_id,'USER');

/* Get the top process item key */
Select wf_approval_item_key
into   l_top_process_itemKey
from pon_auction_headers_all
where auction_header_id = p_auctionHeaderId;

if (p_decision = 'APPROVE') then
Process_If_Doc_Approved(p_auctionHeaderId,l_top_process_itemKey);
end if;
if (p_decision = 'REJECT') then
Process_Doc_Rejected(p_auctionHeaderId,l_top_process_itemKey);
end if;

end User_Decision_Without_WF;

PROCEDURE User_Rejected(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              uncmode   in varchar2,
                              resultout  out nocopy varchar2) is
l_notes  varchar2(2000);
l_user_name varchar2(100);
l_user_id number;
l_auction_header_id number;
l_top_process_item_key Varchar2(240);
l_result  Varchar2(30) := 'REJECTED';
l_original_approver_id number;
begin

/* Get auction header id from the workflow */
    l_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'AUCTION_HEADER_ID');

    l_user_name := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'APPOVER');

    l_user_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'APPOVER_ID');

    l_notes :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'APPROVER_NOTES');

    l_top_process_item_key := wf_engine.GetItemAttrText (itemtype   => itemType,
                                           itemkey    => itemKey,
                                           aname      => 'TOP_PROCESS_ITEM_KEY');
	l_original_approver_id := wf_engine.GetItemAttrText (itemtype   => itemType,
                                           itemkey    => itemKey,
                                           aname      => 'ORIGINAL_APPROVER_ID');

    wf_engine.SetItemAttrText (itemtype => itemtype,
                               itemkey  => l_top_process_item_key,
                               aname    => 'APPOVER',
                               avalue => l_user_name);

    wf_engine.SetItemAttrNumber (itemtype => itemtype,
                               itemkey  => l_top_process_item_key,
                               aname    => 'APPOVER_ID',
                               avalue => l_user_id);

/* Check is the responder a valid approver */
-- commented as part of bug 17173696 fix, as we are updating the approver id each time when
-- an action taken on negotiation, the below check fails and hence commenting it
--if (Is_Valid_Response(l_auction_header_id,l_user_id) = 'N') then
/* Responder is not a valid approver. Ignore this response */
--return;
--end if;
           wf_engine.SetItemAttrText (itemtype => itemtype,
                                     itemkey  => l_top_process_item_key,
                                     aname    => 'NOTE_TO_BUYER_ON_REJECT',
                                     avalue => l_notes);

/*Update PON_NEG_TEAM_MEMEBERS APPROVAL_STATUS field */
/* Insert a row into history table */
UPD_AUCTION_STATUSHISTORY(l_auction_header_id, l_result,
                          l_notes,l_user_id,'USER',l_original_approver_id);
Process_Doc_Rejected(l_auction_header_id,l_top_process_item_key);

end User_Rejected;

PROCEDURE Doc_Approved(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       uncmode   in varchar2,
                       resultout  out nocopy varchar2) is

l_auction_header_id         Number;
l_status                    Varchar2(30) := 'APPROVED';
l_user_id                   Number;
l_approve_date              PON_ACTION_HISTORY.ACTION_DATE%TYPE;
l_approve_date_in_tz        DATE;
l_language_code             varchar2(100);
l_timezone                  varchar2(100);
l_timezone_disp             varchar2(100);
l_oex_timezone              varchar2(100);
l_auction_contact_id        PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_ID%TYPE;
l_preview_date_in_tz   	    DATE;
l_timezone1_disp            varchar2(240);
l_preview_date_nspec        FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

Begin
 l_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AUCTION_HEADER_ID');

 l_user_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'CREATOR_USER_ID');

 l_auction_contact_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'TRADING_PARTNER_CONTACT_ID');


   l_preview_date_in_tz     := wf_engine.GetItemAttrDate  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'PREVIEW_DATE');
   l_timezone1_disp     := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'TP_TIME_ZONE1');

   l_preview_date_nspec     := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'PREVIEW_DATE_NOTSPECIFIED');
 SELECT max(action_date)
 INTO l_approve_date
 FROM pon_action_history
 WHERE object_id = l_auction_header_id
 and object_type_code = 'NEGOTIATION'
 and action_type = 'APPROVE';

    PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(l_user_id,l_language_code);
    l_oex_timezone := PON_AUCTION_PKG.Get_Oex_Time_Zone;

 -- Get the user's time zone
	l_timezone := PON_AUCTION_PKG.Get_Time_Zone(l_auction_contact_id);

	if (l_timezone is null or l_timezone = '') then
		l_timezone := l_oex_timezone;
	end if;


    -- Convert the date to the user's timezone.
	-- If the timezone is not recognized, just use server timezone
	IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(l_timezone) = 1) THEN
       l_approve_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(l_approve_date,l_oex_timezone,l_timezone);
    ELSE
       l_approve_date_in_tz := l_approve_date;
       l_timezone := l_oex_timezone;
    END IF;

    -- Set the dates based on the user's time zone
	   l_timezone_disp := PON_AUCTION_PKG.Get_TimeZone_Description(l_timezone, l_language_code);

    wf_engine.SetItemAttrDate   (itemtype   => itemType,
                             itemkey    => itemKey,
                             aname      => 'APPROVE_DATE',
                             avalue     => l_approve_date_in_tz);

    wf_engine.SetItemAttrText  (itemtype   => itemType,
                             itemkey    => itemKey,
                             aname      => 'TIMEZONE',
                             avalue     => l_timezone_disp);

 UPD_AUCTION_STATUSHISTORY(l_auction_header_id,
                           l_status,
                           NULL,
                           l_user_id,'AUCTION');

End Doc_Approved;

PROCEDURE Doc_Rejected(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       uncmode   in varchar2,
                       resultout  out nocopy varchar2) is

l_auction_header_id         Number;
l_status                    Varchar2(30) := 'REJECTED';
l_user_id                   Number;
l_rejection_note            Varchar2(2000);
l_reject_date               PON_ACTION_HISTORY.ACTION_DATE%TYPE;
l_reject_date_in_tz         DATE;
l_language_code             varchar2(100);
l_timezone                  varchar2(100);
l_timezone_disp             varchar2(100);
l_oex_timezone              varchar2(100);
l_auction_contact_id        PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_ID%TYPE;
l_preview_date_in_tz   	    DATE;
l_timezone1_disp            varchar2(240);
l_preview_date_nspec        FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

Begin
 l_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AUCTION_HEADER_ID');

 l_user_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'CREATOR_USER_ID');

 l_rejection_note := wf_engine.GetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'NOTE_TO_BUYER_ON_REJECT');

 l_auction_contact_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'TRADING_PARTNER_CONTACT_ID');


   l_preview_date_in_tz     := wf_engine.GetItemAttrDate  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'PREVIEW_DATE');


   l_timezone1_disp     := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'TP_TIME_ZONE1');

   l_preview_date_nspec     := wf_engine.GetItemAttrText  (itemtype   => itemType,
                                                         itemkey    => itemKey,
                                                         aname      => 'PREVIEW_DATE_NOTSPECIFIED');

 SELECT max(action_date)
 INTO l_reject_date
 FROM pon_action_history
 WHERE object_id = l_auction_header_id
 and object_type_code = 'NEGOTIATION'
 and action_type = 'REJECT';

   PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(l_user_id,l_language_code);
   l_oex_timezone := PON_AUCTION_PKG.Get_Oex_Time_Zone;

   -- Get the user's time zone
   l_timezone := PON_AUCTION_PKG.Get_Time_Zone(l_auction_contact_id);

	if (l_timezone is null or l_timezone = '') then
		l_timezone := l_oex_timezone;
	end if;


    -- Convert the date to the user's timezone.
	-- If the timezone is not recognized, just use server timezone
	IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(l_timezone) = 1) THEN
       l_reject_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(l_reject_date,l_oex_timezone,l_timezone);
    ELSE
       l_reject_date_in_tz := l_reject_date;
       l_timezone := l_oex_timezone;
    END IF;

    -- Set the dates based on the user's time zone
	   l_timezone_disp := PON_AUCTION_PKG.Get_TimeZone_Description(l_timezone, l_language_code);

  wf_engine.SetItemAttrDate   (itemtype   => itemType,
                             itemkey    => itemKey,
                             aname      => 'REJECT_DATE',
                             avalue     => l_reject_date_in_tz);

  wf_engine.SetItemAttrText  (itemtype   => itemType,
                             itemkey    => itemKey,
                             aname      => 'TIMEZONE',
                             avalue     => l_timezone_disp);

 UPD_AUCTION_STATUSHISTORY(l_auction_header_id,
                           l_status,
                           l_rejection_note,
                           l_user_id,'AUCTION');

 close_child_process(itemkey);

End Doc_Rejected;

PROCEDURE Doc_timedout(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       uncmode   in varchar2,
                       resultout  out nocopy varchar2) is
l_auction_header_id Number;
l_status Varchar2(30) := 'TIMEOUT';
l_user_id  Number;
l_rejection_note Varchar2(2000);
Begin
 l_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AUCTION_HEADER_ID');

 l_user_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'CREATOR_USER_ID');

 l_rejection_note := wf_engine.GetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'NOTE_TO_BUYER_ON_REJECT');

 UPD_AUCTION_STATUSHISTORY(l_auction_header_id,
                           l_status,
                           NULL,
                           l_user_id,'AUCTION');

 close_child_process(itemkey);

End Doc_timedout;

Procedure UPD_AUCTION_STATUSHISTORY(p_auction_header_id number,
                                      p_status Varchar2,
                                      p_notes Varchar2,
                                      p_user_id number,
                                      p_upd_history_type varchar2 ,
									  p_original_approver_id number DEFAULT -1) is

i number ; --for eric test only
l_original_approver_id 		wf_roles.orig_system_id%TYPE;

begin

--INSERT INTO ERIC_LOG VALUES ('go into UPD_AUCTION_STATUSHISTORY function','p_upd_history_type =' ||p_upd_history_type,'p_status =' ||p_status,'p_auction_header_id = ' ||p_auction_header_id,'','','','');--for eric test only
	IF (p_original_approver_id <> -1) THEN
		l_original_approver_id	:= p_original_approver_id;
	ELSE
		l_original_approver_id	:=p_user_id;
	END IF;
if p_upd_history_type = 'USER' then
	--INSERT INTO ERIC_LOG VALUES ('ENTER USER Branch','','','','','','','');  --for eric test only
if (p_status <> 'SUBMIT') then
 Update pon_neg_team_members
    set approval_status = decode(p_status,'APPROVE','APPROVED','REJECT','REJECTED',p_status)
    where auction_header_id = p_auction_header_id
  and user_id = l_original_approver_id
  AND approver_flag = 'Y'                   -- for eric test only
  AND MENU_NAME<>'EMD_ADMIN';  -- for eric test only

  i:=SQL%ROWCOUNT ;-- for eric test only
  --INSERT INTO ERIC_LOG VALUES (i ||'row(s) has been updated in pon_neg_team_members','','','','','','',''); --for eric test only
end if;

 insert into pon_action_history
   (object_id,
   object_id2,
   object_type_code,
   sequence_num,
   action_type,
   action_date,
   action_user_id,
   action_note)
 values (
   p_auction_header_id,
   p_auction_header_id,
   'NEGOTIATION',
   0,
   decode(p_status,'APPROVED','APPROVE','REJECTED','REJECT',p_status),
   sysdate,
   p_user_id,
   p_notes
   );
   --INSERT INTO ERIC_LOG VALUES ('go out USER Branch','','','','','','',''); --for eric test only
--FOR ERIC TEST ONLY ,BEGIN
----------------------------------------------------------------------------------------------
ELSIF p_upd_history_type = 'EMD'
THEN
  --INSERT INTO ERIC_LOG VALUES ('enter EMD Branch','','','','','','','');	 --for eric test only


  IF (p_status <> 'SUBMIT')
  THEN
    UPDATE pon_neg_team_members
       SET approval_status = decode(p_status
                                   ,'APPROVE'
                                   ,'APPROVED'
                                   ,'REJECT'
                                   ,'REJECTED'
                                   ,p_status
                                   )
     WHERE auction_header_id = p_auction_header_id
       AND user_id = p_user_id
       AND MENU_NAME='EMD_ADMIN'
       AND approver_flag = 'Y';

  i:=SQL%ROWCOUNT ;-- for eric test only
  --INSERT INTO ERIC_LOG VALUES (i ||'row(s) has been updated in pon_neg_team_members','','','','','','',''); --for eric test only
  END IF;

  INSERT INTO pon_action_history
  	(object_id
  	,object_id2
  	,object_type_code
  	,sequence_num
  	,action_type
  	,action_date
  	,action_user_id
  	,action_note)
  VALUES
  	(p_auction_header_id
  	,p_auction_header_id
  	,'NEGOTIATION-EMD'
  	,0
  	,decode(p_status
               ,'APPROVED'
               ,'APPROVE'
               ,'REJECTED'
               ,'REJECT'
               ,p_status
               )
  	,SYSDATE
  	,p_user_id
  	,p_notes);

    --INSERT INTO ERIC_LOG VALUES ('go out EMD Branch','','','','','','',''); --for eric test only
----------------------------------------------------------------------------
--FOR ERIC TEST ONLY ,END

elsif  p_upd_history_type = 'AUCTION' then
   --INSERT INTO ERIC_LOG VALUES ('ENTER AUCTION Branch','p_status= '||p_status,'p_auction_header_id = '||p_auction_header_id,'','','','',''); --for eric test only
   /*
    * In case the document has been APPROVED, REJECTED, TIMEOUT
    * then we unlock the negotiation. If we do not unlock the
    * neg the lock might remain with the approver in case he
    * navigated to the review page. Bug 4777895.
    */

    update pon_auction_headers_all
    set approval_status = p_status,
    draft_locked = 'N',
    draft_locked_by = null,
    draft_locked_by_contact_id = null,
    draft_locked_date = null
    where auction_header_id = p_auction_header_id;

    i:=SQL%ROWCOUNT;
    --INSERT INTO ERIC_LOG VALUES (i ||'row has been updated in pon_auction_headers_all','','','','','','',''); --for eric test only
    --INSERT INTO ERIC_LOG VALUES ('go out AUCTION Branch','','','','','','',''); --for eric test only
end if;

end UPD_AUCTION_STATUSHISTORY;


PROCEDURE SET_NOTIFICATION_SUBJECT(p_itemtype in varchar2,
                                   p_itemkey  in varchar2,
                                   p_msg_suffix in varchar2,
                                   p_doc_number in varchar2,
                                   p_orig_document_number in varchar2,
                                   p_amendment_number in number,
                                   p_auction_title in varchar2) IS
BEGIN


if (p_amendment_number is not null and p_amendment_number > 0) then
  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'REQUEST_FOR_APPROVALS_SUBJECT',
                              avalue     => PON_AUCTION_PKG.getMessage('PON_AMEND_APPR_REQ_SUBJECT',p_msg_suffix,'AMENDMENT_NUMBER', p_amendment_number, 'ORIG_NUMBER', p_orig_document_number, 'AUCTION_TITLE', p_auction_title));

  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                               itemkey    => p_itemKey,
                               aname      => 'PON_AUC_APPR_REMINDER_SUB',
                               avalue     => PON_AUCTION_PKG.getMessage('PON_AMEND_APPR_REMINDER_SUB',p_msg_suffix,'AMENDMENT_NUMBER', p_amendment_number, 'ORIG_NUMBER', p_orig_document_number));

  --added for eric test,begin
  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'EMD_REQ_FOR_APPROVALS_SUBJECT',
                              avalue     => 'EMD '||PON_AUCTION_PKG.getMessage('PON_AMEND_APPR_REQ_SUBJECT',p_msg_suffix,'AMENDMENT_NUMBER', p_amendment_number, 'ORIG_NUMBER', p_orig_document_number, 'AUCTION_TITLE', p_auction_title));

  wf_engine.SetItemAttrText  (itemtype    => p_itemType,
                               itemkey    => p_itemKey,
                               aname      => 'EMD_PON_AUC_APPR_REMINDER_SUB',
                               avalue     => 'EMD '||PON_AUCTION_PKG.getMessage('PON_AMEND_APPR_REMINDER_SUB',p_msg_suffix,'AMENDMENT_NUMBER', p_amendment_number, 'ORIG_NUMBER', p_orig_document_number));

  --added for eric test,end


  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'DOC_APPROVED_MAIL_SUBJECT',
                              avalue     =>  PON_AUCTION_PKG.getMessage('PON_AMEND_APPR_APPRD_SUBJECT',p_msg_suffix, 'AMENDMENT_NUMBER', p_amendment_number, 'ORIG_NUMBER',p_orig_document_number, 'AUCTION_TITLE', p_auction_title));

  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'DOC_REJECTED_MAIL_SUBJECT',
                              avalue     =>  PON_AUCTION_PKG.getMessage('PON_AMEND_APPR_REJ_SUBJECT', p_msg_suffix, 'AMENDMENT_NUMBER', p_amendment_number, 'ORIG_NUMBER',p_orig_document_number, 'AUCTION_TITLE', p_auction_title));

else
  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'REQUEST_FOR_APPROVALS_SUBJECT',
                              avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_APPR_REQ_SUBJECT',p_msg_suffix,'DOC_NUMBER', p_doc_number, 'AUCTION_TITLE', p_auction_title));


  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'PON_AUC_APPR_REMINDER_SUB',
                              avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_APPR_REMINDER_SUB',p_msg_suffix,'DOC_NUMBER', p_doc_number));


  --added for eric test,begin
  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'EMD_REQ_FOR_APPROVALS_SUBJECT',
                              avalue     => 'EMD '||PON_AUCTION_PKG.getMessage('PON_AUC_APPR_REQ_SUBJECT',p_msg_suffix,'DOC_NUMBER', p_doc_number, 'AUCTION_TITLE', p_auction_title));

  wf_engine.SetItemAttrText  (itemtype   =>  p_itemType,
                               itemkey    => p_itemKey,
                               aname      => 'EMD_PON_AUC_APPR_REMINDER_SUB',
                               avalue     => 'EMD '|| PON_AUCTION_PKG.getMessage('PON_AUC_APPR_REMINDER_SUB',p_msg_suffix,'DOC_NUMBER', p_doc_number));

  --added for eric test,end


  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'DOC_APPROVED_MAIL_SUBJECT',
                              avalue     =>  PON_AUCTION_PKG.getMessage('PON_AUC_APPR_APPRD_SUBJECT',p_msg_suffix, 'DOC_NUMBER',p_doc_number, 'AUCTION_TITLE', p_auction_title));

  wf_engine.SetItemAttrText  (itemtype   => p_itemType,
                              itemkey    => p_itemKey,
                              aname      => 'DOC_REJECTED_MAIL_SUBJECT',
                              avalue     =>  PON_AUCTION_PKG.getMessage('PON_AUC_APPR_REJ_SUBJECT', p_msg_suffix,'DOC_NUMBER',p_doc_number, 'AUCTION_TITLE', p_auction_title));
end if;

END SET_NOTIFICATION_SUBJECT;

  --PROCEDURE StartEmdApprovalProcess is ADDED FOR ERIC TEST ONLY
  PROCEDURE StartEmdApprovalProcess
  ( itemtype  IN VARCHAR2
   ,Itemkey   IN VARCHAR2
   ,actid     IN NUMBER
   ,uncmode   IN VARCHAR2
   ,resultout OUT NOCOPY VARCHAR2
  )
  IS
    l_auction_header_id         NUMBER;
    l_seq                       VARCHAR2(100);
    l_itemKey                   VARCHAR2(240);
    l_itemType                  VARCHAR(25) := 'PONAPPRV';
    l_creator_user_id           NUMBER;
    l_creator_full_name         VARCHAR2(240);
    l_creator_user_name         VARCHAR2(100);
    l_creator_session_lang_code VARCHAR2(3);
    l_creator_time_zone         VARCHAR2(80);
    l_doctype_group_name        VARCHAR2(100);
    l_msg_suffix                VARCHAR2(10);
    l_auction_contact_id        NUMBER;
    l_language_code             VARCHAR2(3);
    l_timezone                  VARCHAR2(100);
    l_timezone_disp             VARCHAR2(100);
    l_oex_timezone              VARCHAR2(100);
    l_open_date_in_tz           DATE;
    l_close_date_in_tz          DATE;
    l_timeout_factor            NUMBER;
    l_subtab                    VARCHAR(80);
    l_note_to_approvers         VARCHAR2(2000);
    l_publish_auction_now_flag  VARCHAR2(1);
    l_open_auction_now_flag     VARCHAR2(1);
    l_reminder_date             DATE;
    l_preparer_tp_name          PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE;
    l_auction_title             PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
    l_doc_number                PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
    l_preparer_tp_contact_name  PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
    l_auction_start_date        DATE;
    l_auction_end_date          DATE;
    l_timezone_dsp              VARCHAR2(100);
    l_review_emd_changes_url    VARCHAR2(2000);
    l_review_changes_url        VARCHAR2(2000);
    l_orig_document_number      PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
    l_round_number              NUMBER;
    l_amendment_number          NUMBER;
    l_preview_date_in_tz        DATE;
    l_timezone1_disp            VARCHAR2(240);
    l_preview_date_nspec        FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_redirect_func             VARCHAR2(50);

    CURSOR C_APPROVALS(p_auction_header_id NUMBER, p_timeout_factor NUMBER) IS
	SELECT
	  u.user_name user_name
        , u.user_id
        , auc.close_bidding_date close_bidding_date
        , auc.auction_title
        , decode( nvl(auc.open_auction_now_flag,'N')
                 ,'Y'
                 ,to_date(NULL)
                 ,auc.open_bidding_date) open_bidding_date
        , decode( nvl(auc.publish_auction_now_flag,'N')
                , 'Y'
                , to_date(NULL)
                , auc.view_by_date ) view_by_date
        , auc.document_number doc_number
        , trading_partner_contact_id auction_contact_id
        , nvl(auc.publish_auction_now_flag ,'N') publish_auction_now_flag
        , nvl(auc.open_auction_now_flag,'N') open_auction_now_flag
        , auc.auction_header_id_orig_amend
        FROM
          pon_neg_team_members    neg
        , pon_auction_headers_all auc
        , fnd_user                u
	WHERE neg.auction_header_id = auc.auction_header_id
	  AND auc.auction_header_id = p_auction_header_id
	  AND MENU_NAME='EMD_ADMIN'
	  AND approver_flag = 'Y' --for eric test only
	  AND u.user_id = neg.user_id;
  BEGIN
    --INSERT INTO ERIC_LOG VALUES ('INTO StartEmdApprovalProcess','','','','','','','');--for eric test only
    l_timeout_factor := .5; -- use to get this value from an item attribute

    l_preparer_tp_name := wf_engine.GetItemAttrText( itemtype => itemType
                                                   , itemkey  => itemKey
                                                   , aname    => 'PREPARER_TP_NAME');

    l_auction_title := wf_engine.GetItemAttrText( itemtype => itemType
                                                , itemkey  => itemKey
                                                , aname    => 'AUCTION_TITLE');

    l_doc_number := wf_engine.GetItemAttrText( itemtype => itemType
                                             , itemkey  => itemKey
                                             , aname    => 'DOC_NUMBER');

    l_preparer_tp_contact_name := wf_engine.GetItemAttrText( itemtype => itemType
                                                           , itemkey  => itemKey
                                                           , aname    => 'PREPARER_TP_CONTACT_NAME');

    l_auction_start_date := wf_engine.GetItemAttrDate( itemtype => itemType
                                                     , itemkey  => itemKey
                                                     , aname    => 'AUCTION_START_DATE');

    l_auction_end_date := wf_engine.GetItemAttrDate( itemtype => itemType
                                                   , itemkey  => itemKey
                                                   , aname    => 'AUCTION_END_DATE');

    l_timezone_dsp := wf_engine.GetItemAttrText( itemtype => itemType
                                               , itemkey  => itemKey
                                               , aname    => 'TIMEZONE');

    l_note_to_approvers := wf_engine.GetItemAttrText( itemtype => itemType
                                                    , itemkey  => itemKey
                                                    , aname    => 'NOTE_TO_APPROVERS');

    l_preview_date_in_tz := wf_engine.GetItemAttrDate( itemtype => itemType
                                                     , itemkey  => itemKey
                                                     , aname    => 'PREVIEW_DATE');
    l_timezone1_disp     := wf_engine.GetItemAttrText( itemtype => itemType
                                                     , itemkey  => itemKey
                                                     , aname    => 'TP_TIME_ZONE1');

    l_preview_date_nspec := wf_engine.GetItemAttrText( itemtype => itemType
                                                     , itemkey  => itemKey
                                                     , aname    => 'PREVIEW_DATE_NOTSPECIFIED');
    l_msg_suffix         := wf_engine.GetItemAttrText( itemtype => itemType
                                                     , itemkey  => itemKey
                                                     , aname    => 'MSG_SUFFIX');

    l_auction_header_id := wf_engine.GetItemAttrNumber( itemtype => itemType
                                                      , itemkey  => itemKey
                                                      , aname    => 'AUCTION_HEADER_ID');

    l_round_number := wf_engine.GetItemAttrNumber( itemtype => itemType
                                                 , itemkey  => itemKey
                                                 , aname    => 'DOC_ROUND_NUMBER');

    l_amendment_number := wf_engine.GetItemAttrNumber( itemtype => itemType
                                                     , itemkey  => itemKey
                                                     , aname    => 'DOC_AMENDMENT_NUMBER');

    l_creator_full_name := wf_engine.GetItemAttrText( itemtype => itemType
                                                    , itemkey  => itemKey
                                                    , aname    => 'AUCTIONEER_NAME');

    l_redirect_func := wf_engine.GetItemAttrText( itemtype => itemType
                                                , itemkey  => itemKey
                                                , aname    => 'REVIEWPG_REDIRECTFUNC');

    /* Preserve creator's session language */
    l_creator_user_name := wf_engine.GetItemAttrText( itemtype => itemType
                                                    , itemkey  => itemKey
                                                    , aname    => 'CREATOR_USER_NAME');

    l_creator_user_id := wf_engine.GetItemAttrNumber( itemtype => itemType
                                                    , itemkey  => itemKey
                                                    , aname    => 'CREATOR_USER_ID');

    PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE( l_creator_user_id
                                        , l_creator_session_lang_code);

    FOR r1 IN C_APPROVALS(l_auction_header_id,l_timeout_factor)
    LOOP
      --INSERT INTO ERIC_LOG VALUES ('EMD INTO FOR r1 IN C_APPROVALS','','','','','','','');--for eric test only

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)
      THEN
      --{
        FND_LOG.STRING( log_level => FND_LOG.level_statement
                      , module    => g_module_prefix ||'StartUserApprovalProcess'
                      , message   => 'r1.user_id : ' || r1.user_id);
      END IF; --}

      PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(r1.user_id,l_language_code);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)
      THEN
      --{
        FND_LOG.STRING( log_level => FND_LOG.level_statement
        	          , module    => g_module_prefix ||'StartEMDApprovalProcess'
        	          , message   => 'r1.user_id : ' || r1.user_id || ';' ||'l_language_code : ' || l_language_code
        	          );
      END IF; --}

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)
      THEN
      --{
        FND_LOG.STRING( log_level => FND_LOG.level_statement
                      , module    => g_module_prefix ||'StartEMDApprovalProcess'
      		  , message   => '1. Calling SET_SESSION_LANGUAGE with l_language_code : ' ||l_language_code
      		  );
      END IF; --}

	-- bug 7602688 session language for workflow is already set in submit_for_approval procedure.
	-- this process is called from 'sourcingapproval' workflow only. so no need to set again.
      --PON_AUCTION_PKG.SET_SESSION_LANGUAGE(NULL,l_language_code);

      --Bug 6472383 : If the Negotiation Preview date is mentioned as 'Not Specified', i.e. if the value of
      -- l_preview_date_nspec is not null, we need to replace it with the string specific to recipient's language
      IF (l_preview_date_nspec IS NOT NULL)
      THEN
        l_preview_date_nspec := PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC',l_msg_suffix);
      END IF;

      l_itemKey := itemkey || '_EMD_' || r1.user_id;

      wf_engine.createProcess( itemType => l_itemType
                             , itemKey  => l_itemKey
                             , process  => 'EMDAPPROVALS');

      IF (r1.view_by_date IS NOT NULL)
      THEN
        l_reminder_date := r1.view_by_date;
      ELSIF (r1.open_bidding_date IS NOT NULL)
      THEN
        l_reminder_date := r1.open_bidding_date;
      ELSE
        l_reminder_date := r1.close_bidding_date;
      END IF;

      SELECT SYSDATE + ((l_reminder_date - SYSDATE) * l_timeout_factor)
        INTO l_reminder_date
        FROM dual;


      wf_engine.SetItemAttrDate( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'TIMEOUT_USERPROCESS'
                               , avalue   => l_reminder_date);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'CREATOR_USER_NAME'
                               , avalue   => l_creator_user_name);
      wf_engine.SetItemAttrNumber( itemtype => l_itemType
                                 , itemkey  => l_itemKey
                                 , aname    => 'CREATOR_USER_ID'
                                 , avalue   => l_creator_user_id);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'REVIEWPG_REDIRECTFUNC'
                               , avalue   => l_redirect_func);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'PREPARER_TP_NAME'
                               , avalue   => l_preparer_tp_name);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'AUCTION_TITLE'
                               , avalue   => l_auction_title);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'DOC_NUMBER'
                               , avalue   => l_doc_number);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'PREPARER_TP_CONTACT_NAME'
                               , avalue   => l_preparer_tp_contact_name);
      wf_engine.SetItemAttrDate( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'AUCTION_START_DATE'
                               , avalue   => l_auction_start_date);
      wf_engine.SetItemAttrDate( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'AUCTION_END_DATE'
                               , avalue   => l_auction_end_date);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'TIMEZONE'
                               , avalue   => l_timezone_dsp);
      wf_engine.SetItemAttrDate( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'PREVIEW_DATE'
                               , avalue   => l_preview_date_in_tz);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'TP_TIME_ZONE1'
                               , avalue   => l_timezone1_disp);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'PREVIEW_DATE_NOTSPECIFIED'
                               , avalue   => l_preview_date_nspec);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'NOTE_TO_APPROVERS'
                               , avalue   => l_note_to_approvers);
      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'TOP_PROCESS_ITEM_KEY'
                               , avalue   => wf_engine.GetItemAttrText( itemtype => l_itemType
                                                                      , itemkey  => itemKey
                                                                      , aname    => 'TOP_PROCESS_ITEM_KEY'
                                                                      )
                               );
      wf_engine.SetItemAttrNumber( itemtype => l_itemType
                                 , itemkey  => l_itemKey
                                 , aname    => 'AUCTION_HEADER_ID'
                                 , avalue   => l_auction_header_id);
      	/*
                wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                                             itemkey    => l_itemKey,
                                             aname      => 'DOC_ROUND_NUMBER',
                                             avalue     => l_round_number);

                wf_engine.SetItemAttrNumber (itemtype   => l_itemType,
                                             itemkey    => l_itemKey,
                                             aname      => 'DOC_AMENDMENT_NUMBER',
                                             avalue     => l_amendment_number);
              */

      l_review_emd_changes_url :=  Get_Emd_Update_Url (l_auction_header_id ); --FOR ERIC TEST ONLY

      /*pon_wf_utl_pkg.get_dest_page_url (
                           p_dest_func        => 'PON_NEG_CRT_HEADER'
                           ,p_notif_performer  => 'BUYER');*/


      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'REVIEW_EMD_CHANGES_URL'
                               , avalue   => l_review_emd_changes_url);


l_review_changes_url := pon_wf_utl_pkg.get_dest_page_url (
                             p_dest_func        => 'PON_NEG_CRT_HEADER'
                             ,p_notif_performer  => 'BUYER');

wf_engine.SetItemAttrText (itemtype   => l_itemType,
                             itemkey    => l_itemKey,
                             aname      => 'REVIEW_CHANGES_URL',
                             avalue     => l_review_changes_url);

      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'EMD_APPROVER'
                               , avalue   => r1.user_name);

      wf_engine.SetItemAttrNumber( itemtype => l_itemType
                                 , itemkey  => l_itemKey
                                 , aname    => 'EMD_APPROVER_ID'
                                 , avalue   => r1.user_id);

      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'ORIGIN_USER_NAME'
                               , avalue   => fnd_global.user_name);

      l_timezone := PON_AUCTION_PKG.Get_Time_Zone(r1.user_name);

      l_oex_timezone := PON_AUCTION_PKG.Get_Oex_Time_Zone;

      IF (l_timezone IS NULL)
      THEN
        l_timezone := l_oex_timezone;
      END IF;

      l_timezone_disp := PON_AUCTION_PKG.Get_TimeZone_Description(l_timezone,l_language_code);

      wf_engine.SetItemAttrText( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'TIMEZONE'
                               , avalue   => l_timezone_disp);

      l_open_date_in_tz  := PON_OEX_TIMEZONE_PKG.CONVERT_TIME( r1.open_bidding_date
                                                             , l_oex_timezone
                                                             , l_timezone);
      l_close_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME( r1.close_bidding_date
                                                             , l_oex_timezone
                                                             , l_timezone);

      wf_engine.SetItemAttrDate(itemtype => l_itemType
                               ,itemkey  => l_itemKey
                               ,aname    => 'AUCTION_START_DATE'
                               ,avalue   => l_open_date_in_tz);
      IF (r1.open_auction_now_flag = 'Y')
      THEN
        wf_engine.SetItemAttrText( itemtype => l_itemType
                                 , itemkey  => l_itemKey
                                 , aname    => 'OPEN_IMMEDIATELY'
                                 , avalue   => PON_AUCTION_PKG.getMessage('PON_AUC_OPEN_IMM_AFTER_PUB'
        																																,l_msg_suffix));

        wf_engine.SetItemAttrText( itemtype => l_itemType
        			 , itemkey  => l_itemKey
        			 , aname    => 'O_TIMEZONE'
        			 , avalue   => NULL);
      ELSE
        wf_engine.SetItemAttrText( itemtype => l_itemType
        			 , itemkey  => l_itemKey
        			 , aname    => 'OPEN_IMMEDIATELY'
        			 , avalue   => NULL);

        wf_engine.SetItemAttrText( itemtype => l_itemType
        			 , itemkey  => l_itemKey
        			 , aname    => 'O_TIMEZONE'
        			 , avalue   => l_timezone_disp);
      END IF;

      wf_engine.SetItemAttrDate( itemtype => l_itemType
                               , itemkey  => l_itemKey
                               , aname    => 'AUCTION_END_DATE'
                               , avalue   => l_close_date_in_tz);

      wf_engine.SetItemAttrText( itemtype => l_itemType
      			 , itemkey  => l_itemKey
      			 , aname    => 'NOTE_TO_APPROVERS'
      			 , avalue   => l_note_to_approvers);

      SELECT document_number
        INTO l_orig_document_number
        FROM pon_auction_headers_all
       WHERE auction_header_id = r1.auction_header_id_orig_amend;

      -- set notification subjects
      set_notification_subject( l_itemType
      			, l_itemKey
      			, l_msg_suffix
      			, l_doc_number
      			, l_orig_document_number
      			, l_amendment_number
      			, l_auction_title);

      -- Bug 4295915: Set the  workflow owner
      wf_engine.SetItemOwner( itemtype => l_itemtype
                            , itemkey  => l_itemkey
                            , owner    => fnd_global.user_name);

      wf_engine.StartProcess( itemType => l_itemType
    		      , itemKey  => l_itemKey);

        --dbms_output.put_line('EMDAPPROVALS: Started: '||l_itemType ||l_itemKey);-- for eric test only
    END LOOP;

    /* Reset to creator's language */
    -- 7602688
    --PON_AUCTION_PKG.SET_SESSION_LANGUAGE(NULL,l_creator_session_lang_code);
  END StartEmdApprovalProcess;

  --PROCEDURE Emd_User_Approved is ADDED FOR ERIC TEST ONLY
  PROCEDURE Emd_User_Approved
  ( itemtype  IN VARCHAR2
   ,itemkey   IN VARCHAR2
   ,actid     IN NUMBER
   ,uncmode   IN VARCHAR2
   ,resultout OUT NOCOPY VARCHAR2
  )
  IS
    ls_error               VARCHAR2(4000); -- for eric test only
    l_notes                VARCHAR2(2000);
    l_user_name            VARCHAR2(100);
    l_user_id              NUMBER;
    l_auction_header_id    NUMBER;
    l_top_process_item_key VARCHAR2(240);
    l_result               VARCHAR2(30) := 'APPROVED';
    lv_wf_source           VARCHAR2(10) := 'EMD'; --FOR ERIC TEST ONLY
  BEGIN
    --INSERT INTO ERIC_LOG VALUES ('INTO Emd_User_Approved','','','','','','','');--for eric test only
    /* Get auction header id from the workflow */
    l_auction_header_id := wf_engine.GetItemAttrNumber( itemtype => itemtype
                                                      , itemkey  => itemkey
                                                      , aname    => 'AUCTION_HEADER_ID');

    l_user_name := wf_engine.GetItemAttrText( itemtype => itemtype
                                            , itemkey  => itemkey
                                            , aname    => 'EMD_APPROVER');

    l_user_id := wf_engine.GetItemAttrNumber( itemtype => itemtype
                                            , itemkey  => itemkey
                                            , aname    => 'EMD_APPROVER_ID');

    l_notes := wf_engine.GetItemAttrText( itemtype => itemtype
                                        , itemkey  => itemkey
                                        , aname    => 'APPROVER_NOTES');

    l_top_process_item_key := wf_engine.GetItemAttrText( itemtype => itemType
                                                       , itemkey  => itemKey
                                                       , aname    => 'TOP_PROCESS_ITEM_KEY');

    wf_engine.SetItemAttrNumber( itemtype => itemtype
                               , itemkey  => l_top_process_item_key
                               , aname    => 'EMD_APPROVER_ID'
                               , avalue   => l_user_id
                               );

    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => l_top_process_item_key
                             , aname    => 'EMD_APPROVER'
                             , avalue   => l_user_name
                             );

    --INSERT INTO ERIC_LOG VALUES ('BEFORE Is_Valid_Response',l_auction_header_id,l_user_id,lv_wf_source,'','','','');--for eric test only
    /* Check is the responder a valid approver */
    --IF (Is_Valid_Response(l_auction_header_id,l_user_id) = 'N')
    IF (Is_Valid_Response(l_auction_header_id,l_user_id,lv_wf_source) = 'N')
    THEN
      /* Responder is not a valid approver. Ignore this response */
      --INSERT INTO ERIC_LOG VALUES ('INTO Is_Valid_Response','','','','','','','');--for eric test only
      RETURN;
    END IF;

    --INSERT INTO ERIC_LOG VALUES ('BEFORE UPD_AUCTION_STATUSHISTORY',l_auction_header_id,l_result,l_notes,l_user_id,'','','');--for eric test only
    /* Insert a row into history table */
    UPD_AUCTION_STATUSHISTORY(l_auction_header_id
    			 ,l_result
    			 ,l_notes
    			 ,l_user_id
    			 ,'EMD');

    --INSERT INTO ERIC_LOG VALUES ('BEFORE Process_If_Doc_Approved',l_auction_header_id,l_top_process_item_key,'','','','','');--for eric test only
    Process_If_Doc_Approved(l_auction_header_id,l_top_process_item_key);

    --INSERT INTO ERIC_LOG VALUES ('GO OUT Emd_User_Approved','','','','','','','');--for eric test only
  EXCEPTION
  WHEN OTHERS
  THEN
    ls_error := sqlerrm	;
    --INSERT INTO ERIC_LOG VALUES ('Function EMD_User_Approved Exception: ',ls_error,'','','','','','');--for eric test only
  END EMD_User_Approved;

  --PROCEDURE Emd_User_Rejected is ADDED FOR ERIC TEST ONLY
  PROCEDURE Emd_User_Rejected
  ( itemtype  IN VARCHAR2
  , itemkey   IN VARCHAR2
  , actid     IN NUMBER
  , uncmode   IN VARCHAR2
  , resultout OUT NOCOPY VARCHAR2
  )
  IS
    l_notes                VARCHAR2(2000);
    l_user_name            VARCHAR2(100);
    l_user_id              NUMBER;
    l_auction_header_id    NUMBER;
    l_top_process_item_key VARCHAR2(240);
    l_result               VARCHAR2(30) := 'REJECTED';
    lv_wf_source           VARCHAR2(10) := 'EMD'; --FOR ERIC TEST ONLY
  BEGIN

    /* Get auction header id from the workflow */
    l_auction_header_id := wf_engine.GetItemAttrNumber( itemtype => itemtype
                                                      , itemkey  => itemkey
                                                      , aname    => 'AUCTION_HEADER_ID'
                                                      );

    l_user_name := wf_engine.GetItemAttrText( itemtype => itemtype
                                            , itemkey  => itemkey
                                            , aname    => 'EMD_APPROVER'
                                            );

    l_user_id := wf_engine.GetItemAttrNumber( itemtype => itemtype
                                            , itemkey  => itemkey
                                            , aname    => 'EMD_APPROVER_ID'
                                            );

    l_notes := wf_engine.GetItemAttrText( itemtype => itemtype
                                        , itemkey  => itemkey
                                        , aname    => 'APPROVER_NOTES');

    l_top_process_item_key := wf_engine.GetItemAttrText( itemtype => itemType
                                                       , itemkey  => itemKey
                                                       , aname    => 'TOP_PROCESS_ITEM_KEY'
                                                       );

    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => l_top_process_item_key
                             , aname    => 'EMD_APPROVER'
                             , avalue   => l_user_name
                             );

    wf_engine.SetItemAttrNumber( itemtype => itemtype
                               , itemkey  => l_top_process_item_key
                               , aname    => 'EMD_APPROVER_ID'
                               , avalue   => l_user_id
                               );

    /* Check is the responder a valid approver */
    --IF (Is_Valid_Response(l_auction_header_id,l_user_id) = 'N')

    IF (Is_Valid_Response(l_auction_header_id,l_user_id,lv_wf_source) = 'N')
    THEN
      /* Responder is not a valid approver. Ignore this response */
      RETURN;
    END IF;

    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => l_top_process_item_key
                             , aname    => 'NOTE_TO_BUYER_ON_REJECT'
                             , avalue   => l_notes);

    /*Update PON_NEG_TEAM_MEMEBERS APPROVAL_STATUS field */
    /* Insert a row into history table */
    UPD_AUCTION_STATUSHISTORY( l_auction_header_id
    			 , l_result
    			 , l_notes
    			 , l_user_id
    			 , 'EMD'
    			 );

    Process_Doc_Rejected(l_auction_header_id,l_top_process_item_key);

  END Emd_User_Rejected;
  --This procedure will be called when an user takes an action on negotiatiation approval notification
  --Added as part of bug 17173696 fix
  PROCEDURE post_approval_action
  ( itemtype  IN VARCHAR2
  , itemkey   IN VARCHAR2
  , actid     IN NUMBER
  , funcmode   IN VARCHAR2
  , resultout OUT NOCOPY VARCHAR2
  )
  IS
  l_new_recipient_id 			wf_roles.orig_system_id%TYPE;
  l_new_recipient_user_id 		wf_roles.orig_system_id%TYPE;
  l_original_recipient 			wf_notifications.original_recipient%TYPE;
  l_current_recipient_role 		wf_notifications.recipient_role%TYPE;
  l_origsys 					wf_roles.orig_system%TYPE;
  l_action  					VARCHAR2(100);
  l_notes						VARCHAR2(2000);
  l_signed_date 				DATE := null;
  l_auction_header_id			number;
  l_current_approver_id 		VARCHAR2(20);
  l_top_process_item_key  		Varchar2(240);
  l_new_approver_user_name 		VARCHAR2(240);
  l_current_approver_name 		VARCHAR2(240);
  l_original_approver_id 		wf_roles.orig_system_id%TYPE;
  l_progress                     VARCHAR2(4000);
  l_api_name                     VARCHAR2(50)  := 'POST_APPROVAL_NOTIF';
	BEGIN
    	l_progress:='started execution of procedure '||g_module_prefix||'.'||l_api_name;
		IF g_fnd_debug = yesChar THEN
		  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
			FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
		  END IF;
		END IF;

		l_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'AUCTION_HEADER_ID');
		l_top_process_item_key := wf_engine.GetItemAttrText (itemtype   => itemType,
                                           itemkey    => itemKey,
                                           aname      => 'TOP_PROCESS_ITEM_KEY');
		l_current_approver_name := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'APPOVER');

		l_current_approver_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
												 itemkey  => itemkey,
												 aname    => 'APPOVER_ID');
		l_original_approver_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
												 itemkey  => itemkey,
												 aname    => 'ORIGINAL_APPROVER_ID');
		l_progress:='Negotiation id:'||l_auction_header_id||'**action selected:'||funcmode||'**current approver name:'||l_current_approver_name;
		l_progress:=l_progress||'**current approver id:'||l_current_approver_id||'**original approver id:'||l_original_approver_id;
		l_progress:=l_progress||'**new recipient selected:'||WF_ENGINE.CONTEXT_NEW_ROLE;
		IF g_fnd_debug = yesChar THEN
		  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
			FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
		  END IF;
		END IF;
		IF (funcmode     IN ('FORWARD', 'TRANSFER', 'QUESTION', 'ANSWER','TIMEOUT')) THEN

			IF (funcmode   	= 'FORWARD') THEN
			  l_action     := 'DELEGATE';
			ELSIF (funcmode    = 'TRANSFER') THEN
			  l_action     := 'TRANSFER';
			ELSIF (funcmode = 'QUESTION') THEN
			  l_action     := 'QUESTION';
			ELSIF (funcmode = 'ANSWER') THEN
			  l_action     := 'ANSWER';
			ELSIF (funcmode = 'TIMEOUT') THEN
			  l_action     := 'NO ACTION';
			END IF;

			IF (l_action <> 'NO ACTION') THEN

			  Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_NEW_ROLE, l_origsys, l_new_recipient_id);

			ELSE

			  BEGIN
					SELECT original_recipient,
					  DECODE(MORE_INFO_ROLE, NULL, RECIPIENT_ROLE, MORE_INFO_ROLE)
					INTO l_original_recipient,
					  l_current_recipient_role
					FROM wf_notifications
					WHERE notification_id = WF_ENGINE.context_nid
					AND ( MORE_INFO_ROLE IS NOT NULL
					OR RECIPIENT_ROLE    <> ORIGINAL_RECIPIENT );
				  EXCEPTION
				  WHEN OTHERS THEN
					l_original_recipient := NULL;
			  END;
			  IF l_original_recipient IS NOT NULL THEN
				Wf_Directory.GetRoleOrigSysInfo(l_original_recipient, l_origsys, l_new_recipient_id);
			  END IF;

			END IF;

		-- We should not be allowing the delegation of a notication to a user who is not an employee.
		-- Or we shouldn't question user who is not an employee
		IF ( l_action IN ( 'DELEGATE' , 'TRANSFER' , 'QUESTION' ) ) THEN

		  IF ( l_origsys <> 'PER' ) THEN

			fnd_message.set_name('PON', 'PON_INVALID_USER_FOR_REASSIGN');
			app_exception.raise_exception;

		  END IF;

		END IF;


		IF l_new_recipient_id IS NOT NULL THEN
			/* log action into history table */
			UPD_AUCTION_STATUSHISTORY(l_auction_header_id,
                          l_action,
                          WF_ENGINE.CONTEXT_USER_COMMENT,
                          l_current_approver_id,
                          'USER');
			SELECT user_id,user_name INTO l_new_recipient_user_id,l_new_approver_user_name
			  FROM FND_USER
			  WHERE employee_id = l_new_recipient_id and user_name=WF_ENGINE.CONTEXT_NEW_ROLE;
			wf_engine.SetItemAttrNumber (itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'APPOVER_ID',
                               avalue => l_new_recipient_user_id);

			wf_engine.SetItemAttrText (itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'APPOVER',
                               avalue => l_new_approver_user_name);
			l_progress:='new recipient name:'||l_new_recipient_user_id||'**new recipient name:'||l_new_approver_user_name;
			IF g_fnd_debug = yesChar THEN
				IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
					FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
				END IF;
			END IF;
		END IF;
		END IF;
		l_progress:='end of execution of procedure '||g_module_prefix||'.'||l_api_name;
		IF g_fnd_debug = yesChar THEN
			IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
				FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
			END IF;
		END IF;
	END post_approval_action;
end PON_AUCTION_APPROVAL_PKG;

/
