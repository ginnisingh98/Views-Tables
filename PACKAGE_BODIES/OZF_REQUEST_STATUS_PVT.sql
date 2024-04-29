--------------------------------------------------------
--  DDL for Package Body OZF_REQUEST_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_REQUEST_STATUS_PVT" AS
/* $Header: ozfvrstb.pls 120.5.12010000.3 2009/06/01 05:35:54 ateotia ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_REQUEST_STATUS_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ozfvrstb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
OZF_UNEXP_ERROR_ON BOOLEAN :=FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error);
OZF_ERROR_ON BOOLEAN := FND_MSG_PUB.check_msg_level(fnd_msg_pub.g_msg_lvl_error);
G_DEBUG BOOLEAN := true; --FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);


---------------------------------------------------------------------
-- PROCEDURE
--    Event_Subscription
--
-- PURPOSE
--    Subscription for the event raised during status change
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Event_Subscription(
   p_subscription_guid IN     raw,
   p_event             IN OUT NOCOPY wf_event_t)
RETURN varchar2
is

l_api_name    CONSTANT VARCHAR2(30) := 'Event_Subscription';
l_api_version CONSTANT number := 1.0;
l_rule                   varchar2(20);
l_parameter_list         wf_parameter_list_t := wf_parameter_list_t();
l_parameter_t            wf_parameter_t := wf_parameter_t(null, null);
l_parameter_name         l_parameter_t.name%type;
i                        pls_integer;

l_msg_callback_api varchar2(60);
l_user_callback_api varchar2(60);
l_benefit_id   number;
l_status       varchar2(30);
l_event_key    varchar2(240);
l_partner_id   number;
l_object_type  varchar2(30) := 'SPECIAL_PRICE';
l_object_id    number;
l_user_list    varchar2(2000);
l_msg_count number;
l_msg_data varchar2(2000);
l_return_status varchar2(10);
l_approval_rec OZF_APPROVAL_PVT.approval_rec_type;

CURSOR csr_benefit (p_object_id in number) IS
SELECT benefit_id, partner_id
FROM   ozf_request_headers_all_b
WHERE  request_header_id = p_object_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Event_Subscription_PVT;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;

    l_parameter_list := p_event.getParameterList();
    l_event_key := p_event.getEventKey();

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Event Key ' || l_event_key);
    END IF;

    IF l_parameter_list IS NOT NULL THEN
        i := l_parameter_list.FIRST;
        WHILE ( i <= l_parameter_list.last) LOOP

            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message( 'Parameter Name ' || l_parameter_list(i).getName());
               ozf_utility_pvt.debug_message( 'Parameter Value ' || l_parameter_list(i).getValue());
               ozf_utility_pvt.debug_message( 'Parameter ' || i || ' of ' || l_parameter_list.last);
            END IF;

            l_parameter_name := null;
            l_parameter_name  := l_parameter_list(i).getName();

            IF l_parameter_name = 'STATUS_CODE' THEN
                l_status := l_parameter_list(i).getValue();
            ELSIF l_parameter_name = 'OBJECT_TYPE' THEN
                l_object_type := l_parameter_list(i).getValue();
            ELSIF l_parameter_name = 'OBJECT_ID' THEN
                l_object_id := l_parameter_list(i).getValue();
            END IF;

            i := l_parameter_list.next(i);
        END LOOP;

        OPEN csr_benefit (l_object_id);
           FETCH csr_benefit INTO l_benefit_id, l_partner_id;
        CLOSE csr_benefit;

        l_msg_callback_api := 'OZF_REQUEST_STATUS_PVT.Set_Request_Message';
        l_user_callback_api := 'OZF_REQUEST_STATUS_PVT.Return_Request_Userlist';

        l_approval_rec.object_type := l_object_type;
        l_approval_rec.object_id := l_object_id;
        l_approval_rec.status_code := l_status;

        IF G_DEBUG THEN
           ozf_utility_pvt.debug_message( 'Before call create_interaction. ');
        END IF;

        -- Create_Interaction History
        Create_Interaction (
           p_api_version       => l_api_version,
           p_init_msg_list     => FND_API.G_FALSE,
           x_return_status     => l_return_status,
           x_msg_data          => l_msg_data,
           x_msg_count         => l_msg_count,
           p_approval_rec      => l_approval_rec );

       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

        -- Call api to send notification
        OZF_APPROVAL_PVT.Send_Notification(
            p_api_version         => l_api_version,
            p_init_msg_list       => FND_API.G_FALSE,
            --p_validation_level    => p_validation_level,
            x_return_status       => l_return_status,
            x_msg_data            => l_msg_data,
            x_msg_count           => l_msg_count,
            p_benefit_id          => l_benefit_id,
            p_partner_id          => l_partner_id,
            p_msg_callback_api    => l_msg_callback_api,
            p_user_callback_api   => l_user_callback_api,
            p_approval_rec        => l_approval_rec
        );

        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RETURN 'ERROR';
        END IF;

    END IF;

    RETURN 'SUCCESS';

    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;

EXCEPTION
   WHEN OTHERS THEN
        WF_CORE.CONTEXT(G_PKG_NAME, L_API_NAME, P_EVENT.GETEVENTNAME(), P_SUBSCRIPTION_GUID);
        WF_EVENT.SETERRORINFO(P_EVENT,'ERROR');
        RETURN 'ERROR';
--
END Event_Subscription;

---------------------------------------------------------------------
-- PROCEDURE
--    Set_Request_Message
--
-- PURPOSE
--    Handles the approvals and rejections of objects
--
-- PARAMETERS
--
-- NOTES
--
-- HISTORY
-- ateotia   01-Jun-2009   Bug# 8208686 fixed.
--                         Error on click of SPR notification link.
---------------------------------------------------------------------
PROCEDURE Set_Request_Message (
   p_itemtype            IN VARCHAR2,
   p_itemkey             IN VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_USER_TYPE           IN  VARCHAR2,

   P_STATUS              IN  VARCHAR2)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Set_Request_Message';
l_request_header_id     NUMBER;
l_request_number        VARCHAR2(50);
l_request_name          VARCHAR2(100);
l_comp_amount           VARCHAR2(20);
l_partner_org_name      VARCHAR2(100);
l_partner_cont_name     VARCHAR2(100);
l_creator_name          VARCHAR2(100);
l_customer_address      VARCHAR2(200);
l_customer_name         VARCHAR2(100);
l_customer_cont_name    VARCHAR2(100);
l_entity_status         VARCHAR2(100);
l_entity_creation_date  VARCHAR2(30);
l_notes_clob            CLOB;
l_notes_varchar         VARCHAR2(4000);
l_note_size             BINARY_INTEGER := 4000;
l_decline_code          VARCHAR2(30);
l_return_code           VARCHAR2(30);
l_decline_meaning       VARCHAR2(200);
l_return_meaning        VARCHAR2(200);
l_partner_cont_phone    VARCHAR2(40);
l_partner_cont_email    VARCHAR2(2000);
l_last_approver_name    VARCHAR2(200);
l_request_type          VARCHAR2(20);
l_agreement_number      VARCHAR2(30);
l_authorization_code    VARCHAR2(30);
l_start_date            DATE;
l_end_date              DATE;
l_activity_name         VARCHAR2(80);
l_activity_media_id     NUMBER;
l_vendor_name           VARCHAR2(360);
l_request_type_code     VARCHAR2(30);
l_note_type             VARCHAR2(20);
l_offer_id              NUMBER;
l_partner_profile_url   VARCHAR2(500);
l_function_id           NUMBER;
--Bug# 8208686 fixed by ateotia(+)
l_org_id                NUMBER;
--Maximum URL length is 2,083 characters in IE
l_vendor_dtail_url      VARCHAR2(2000);
l_partner_dtail_url     VARCHAR2(2000);
l_vendor_url            VARCHAR2(2000);
l_partner_url           VARCHAR2(2000);
--Bug# 8208686 fixed by ateotia(-)

cursor lc_get_request_details (pc_request_id number) is
select a.request_header_id
,      a.request_number
,      a.request_name
,      c.party_name
,      a.end_cust_name
,      ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS_LABEL(Null,a.end_cust_address1,a.end_cust_address2,
                     a.end_cust_address3,a.end_cust_address4,a.end_cust_city,a.end_cust_county,
                     a.end_cust_state,a.end_cust_province,a.end_cust_postal_code,
                     null,null,Null,Null,Null,Null,Null,FND_PROFILE.Value('ASF_DEFAULT_COUNTRY'),
                     NULL,NULL,2000,1,1) ADDRESS
-- BUG 4460277 (+)
--,      pt_cont.source_first_name || ' ' || pt_cont.source_last_name pt_contact_name
,      cont.person_last_name||
       DECODE(cont.person_middle_name, NULL, '', ', '||cont.person_middle_name)||
       DECODE(cont.person_first_name, NULL, '', ', '||cont.person_first_name) pt_contact_name
-- BUG 4460277 (-)
,      creator.source_first_name || ' ' || creator.source_last_name creator_name
,      a.end_cust_contact_first_name || ' ' || a.end_cust_contact_last_name
,      lkup.meaning
,      a.creation_date
,      a.requested_amount || ' ' || a.currency_code
,      a.decline_reason_code
,      a.return_reason_code
,      a.partner_contact_phone_number
,      a.partner_contact_email_address
,      a.agreement_number
,      a.authorization_code
,      a.start_date
,      a.end_date
,      a.activity_media_id
,      a.request_type_code
,      NVL(a.offer_id,-1)
--Bug# 8208686 fixed by ateotia(+)
,      a.org_id
--Bug# 8208686 fixed by ateotia(-)
from   ozf_request_headers_all_vl a
,      pv_partner_profiles b
,      hz_parties c
,      jtf_rs_resource_extns pt_cont
,      jtf_rs_resource_extns creator
,      ozf_lookups lkup
-- BUG 4460277 (+)
,      hz_relationships hz_cont_rel
,      hz_parties cont
,      pv_partner_profiles pvpp
-- BUG 4460277 (-)
where  a.request_header_id = pc_request_id
and    a.partner_id = b.partner_id
and    b.partner_party_id = c.party_id
and    a.submitted_by = creator.resource_id (+)
and    a.status_code = lkup.lookup_code
and    lkup.lookup_type = 'OZF_REQUEST_STATUS'
-- BUG 4460277 (+)
and    pvpp.partner_id = a.partner_id
and    hz_cont_rel.object_id = pvpp.partner_party_id
and    hz_cont_rel.object_table_name = 'HZ_PARTIES'
and    hz_cont_rel.subject_id = cont.party_id
and    hz_cont_rel.subject_table_name = 'HZ_PARTIES'
and    hz_cont_rel.relationship_type = 'EMPLOYMENT'
and    cont.party_type = 'PERSON'
and    hz_cont_rel.party_id = pt_cont.source_id
and    pt_cont.category = 'PARTY'
and    a.partner_contact_id = pt_cont.resource_id;
-- BUG 4460277 (-)

cursor lc_get_notes(pc_entity_type varchar2, pc_entity_id number) is
select notes_detail
from   jtf_notes_vl
where  source_object_code = pc_entity_type
AND    SOURCE_OBJECT_ID = pc_entity_id
AND    NOTE_STATUS in ('E' , 'I')   -- only publish notes and also  Public
ORDER BY CREATION_DATE DESC;

cursor lc_last_approver_name (pc_entity_type varchar2, pc_entity_id number) is
SELECT res.source_first_name || ' '|| res.source_last_name
FROM jtf_rs_resource_extns  res, ozf_approval_access oac
where res.user_id =  oac.approver_id
and oac.object_type = pc_entity_type
and oac.object_id = pc_entity_id
and oac.approval_access_id = ( select max(approval_access_id)
               from ozf_approval_access
                           where oac.object_type = pc_entity_type
               and oac.object_id = pc_entity_id );

cursor lc_media_name ( pc_media_id number) is
select media_type_name from
ams_media_vl
where media_id = pc_media_id;

cursor lc_vendor_name ( pc_entity_id number) is
select  vendor.party_name vendor_name
from    ozf_request_headers_all_vl  enrl_req,
pv_partner_profiles prtnr_profile,
hz_relationships rel_ship,
hz_parties vendor
where   enrl_req.request_header_id = pc_entity_id
and     enrl_req.partner_id= prtnr_profile.partner_id
and     prtnr_profile.partner_id = rel_ship.party_id
and     prtnr_profile.partner_party_id = rel_ship.object_id
and     enrl_req.partner_id = rel_ship.party_id
and     rel_ship.subject_id = vendor.party_id
and rownum < 2;

cursor lc_get_function_id (pc_func_name varchar2) is
select function_id from fnd_form_functions where function_name = pc_func_name ;

BEGIN

   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'ozf.plsql.OZF_REQUEST_STATUS_PVT.Set_Request_Message.start',
      'Item type:' || p_itemtype || 'Item key:' || p_itemkey || '. Entity id: ' ||
      p_entity_id || '. Status:' || p_status || '. User type: ' || p_user_type);
   end if;

   open lc_get_request_details (pc_request_id => p_entity_id);
   fetch lc_get_request_details into l_request_header_id
                                   , l_request_number
                                   , l_request_name
                                   , l_partner_org_name
                                   , l_customer_address
                                   , l_customer_name
                                   , l_partner_cont_name
                                   , l_creator_name
                                   , l_customer_cont_name
                                   , l_entity_status
                                   , l_entity_creation_date
                                   , l_comp_amount
                                   , l_decline_code
                                   , l_return_code
                                   , l_partner_cont_phone
                                   , l_partner_cont_email
                                   , l_agreement_number
                                   , l_authorization_code
                                   , l_start_date
                                   , l_end_date
                                   , l_activity_media_id
                                   , l_request_type_code
                                   ,l_offer_id
                                   --Bug# 8208686 fixed by ateotia(+)
                                   ,l_org_id;
                                   --Bug# 8208686 fixed by ateotia(-)
   close lc_get_request_details;

   if p_itemtype = 'OZFSPBEN' then
       l_note_type := 'OZF_SPECIAL_PRICE';
   else
       l_note_type := 'OZF_SOFT_FUND';
   end if;

   open lc_get_notes(pc_entity_type => l_note_type, pc_entity_id => p_entity_id);
   fetch lc_get_notes into l_notes_clob;
   close lc_get_notes;


   l_notes_varchar := dbms_lob.substr(lob_loc => l_notes_clob, amount => l_note_size, offset => 1);

   if p_itemtype = 'OZFSPBEN' then
       l_request_type := 'SPECIAL_PRICE';
   else
       l_request_type := 'SOFT_FUND';
   end if;

   open lc_last_approver_name(pc_entity_type => l_request_type, pc_entity_id => p_entity_id);
   fetch lc_last_approver_name into l_last_approver_name;
   close lc_last_approver_name;

   open lc_vendor_name(pc_entity_id => p_entity_id);
   fetch lc_vendor_name into l_vendor_name;
   close lc_vendor_name;

   if p_itemtype = 'OZFSPBEN' then

      ozf_utility_pvt.debug_message( 'inside  Notification   ' || p_itemKey  );
      ozf_utility_pvt.debug_message( 'Phone number is   ' || l_partner_cont_phone  );

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_NUMBER',
                                 avalue   => l_request_number);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_NAME',
                                 avalue   => l_request_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUESTER_NAME',
                                 avalue   => l_partner_cont_name --l_creator_name -- Bug 4460277
                                 );

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_STATUS',
                                 avalue   => l_entity_status);

      wf_engine.SetItemAttrDate( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_CREATION_DATE',
                                 avalue   => l_entity_creation_date);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_AMOUNT',
                                 avalue   => l_comp_amount);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_ORG_NAME',
                                 avalue   => l_partner_org_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_CONTACT',
                                 avalue   => l_partner_cont_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_CONTACT_PHONE',
                                 avalue   => l_partner_cont_phone);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_CONTACT_EMAIL',
                                 avalue   => l_partner_cont_email);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'LAST_APPROVER_NAME',
                                 avalue   => l_last_approver_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'AGREEMENT NUMBER',
                                 avalue   => l_agreement_number);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'AUTHORIZATION_CODE',
                                 avalue   => l_authorization_code);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_START_DATE',
                                 avalue   => l_start_date);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_END_DATE',
                                 avalue   => l_end_date);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'LAST_NOTE',
                                 avalue   => l_notes_varchar);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'VENDOR_ORG_NAME',
                                 avalue   => l_vendor_name);

      open lc_get_function_id(pc_func_name => 'OZF_SP_VENDOR_DTAIL');
      fetch lc_get_function_id into l_function_id;
      close lc_get_function_id;

      l_vendor_url := fnd_run_function.get_run_function_url(
                      l_function_id,
                      -1,
                      -1,
                      0,
                      'RequestHeaderId=' || p_entity_id || '&' ||
                      'RequestTypeCode=' || l_request_type_code || '&' ||
                      'OzfPartnerUser=N' || '&' ||
                      'FromPage=Dtail' || '&' ||
                      --Bug# 8208686 fixed by ateotia(+)
                      'RequestOrgId=' || l_org_id || '&' ||
                      'clickNotifLink=Y' || '&' ||
                      'addBreadCrumb=Y');
                      --Bug# 8208686 fixed by ateotia(-)

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'VENDOR_LOGIN_URL',
                                 avalue   => l_vendor_url );

      open lc_get_function_id(pc_func_name => 'OZF_SP_PARTNER_CRTPRO');
      fetch lc_get_function_id into l_function_id;
      close lc_get_function_id;

      l_partner_profile_url := fnd_profile.value('PV_WORKFLOW_ISTORE_URL');

      l_partner_profile_url := substr(l_partner_profile_url,1,instr(l_partner_profile_url,'/',1,3)-1); -- just get the http://<host>:<port>

      l_partner_url := fnd_run_function.get_run_function_url(
                       l_function_id,
                       -1,
                       -1,
                       0,
                       'RequestHeaderId=' || p_entity_id || '&' ||
                       'RequestTypeCode=' || l_request_type_code || '&' ||
                       'OzfPartnerUser=Y' || '&' ||
                       'FromPage=Dtail' || '&' ||
                       --Bug# 8208686 fixed by ateotia(+)
                       'RequestOrgId=' || l_org_id || '&' ||
                       'clickNotifLink=Y' || '&' ||
                       'addBreadCrumb=Y');
                       --Bug# 8208686 fixed by ateotia(-)

      if length(l_partner_profile_url) > 0 then -- if profile is set, use it for partner URL
         l_partner_url := l_partner_profile_url || substr(l_partner_url, instr(l_partner_url,'/',1,3));
      end if;

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_LOGIN_URL',
                                 avalue   => l_partner_url );

      l_vendor_dtail_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=682' || '&' ||
                            'OAFunc=OZF_SP_VENDOR_DTAIL' || '&' ||
                            'RequestHeaderId=' || p_entity_id || '&' ||
                            'RequestTypeCode=' || l_request_type_code || '&' ||
                            'OzfPartnerUser=N' || '&' ||
                            'FromPage=Dtail' || '&' ||
                            --Bug# 8208686 fixed by ateotia(+)
                            'RequestOrgId=' || l_org_id || '&' ||
                            'clickNotifLink=Y' || '&' ||
                            'addBreadCrumb=Y';
                            --Bug# 8208686 fixed by ateotia(-)

      l_partner_dtail_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=682' || '&' ||
                             'OAFunc=OZF_SP_PARTNER_CRTPRO' || '&' ||
                             'RequestHeaderId=' || p_entity_id || '&' ||
                             'RequestTypeCode=' || l_request_type_code || '&' ||
                             'OzfPartnerUser=Y' || '&' ||
                             'FromPage=Dtail' || '&' ||
                             --Bug# 8208686 fixed by ateotia(+)
                             'RequestOrgId=' || l_org_id || '&' ||
                             'clickNotifLink=Y' || '&' ||
                             'addBreadCrumb=Y';
                             --Bug# 8208686 fixed by ateotia(-)

      -- Setting the attribute value for updated projects URL
      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'VENDOR_DTAIL_URL',
                                 avalue   => l_vendor_dtail_url);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_DTAIL_URL',
                                 avalue   => l_partner_dtail_url);


      IF l_decline_code IS NOT NULL THEN
         l_decline_meaning := OZF_Utility_PVT.get_lookup_meaning('OZF_SP_REQUEST_DECLINE_CODE',l_decline_code);
         wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                    itemkey  => p_itemKey,
                                    aname    => 'DECLINE_REASON',
                                    avalue   => l_decline_meaning);
      END IF;


   elsif p_itemtype = 'OZFSFBEN' then

      open lc_media_name(pc_media_id => l_activity_media_id);
      fetch lc_media_name into l_activity_name;
      close lc_media_name;

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_NUMBER',
                                 avalue   => l_request_number);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_NAME',
                                 avalue   => l_request_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUESTER_NAME',
                                 avalue   => l_partner_cont_name); --l_creator_name -- Bug 4460277

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_STATUS',
                                 avalue   => l_entity_status);

      wf_engine.SetItemAttrDate( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_CREATION_DATE',
                                 avalue   => l_entity_creation_date);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_AMOUNT',
                                 avalue   => l_comp_amount);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_ORG_NAME',
                                 avalue   => l_partner_org_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_CONTACT',
                                 avalue   => l_partner_cont_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'LAST_APPROVER_NAME',
                                 avalue   => l_last_approver_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_START_DATE',
                                 avalue   => l_start_date);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'REQUEST_END_DATE',
                                 avalue   => l_end_date);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'LAST_NOTE',
                                 avalue   => l_notes_varchar);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'ACTIVITY_NAME',
                                 avalue   => l_activity_name);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'VENDOR_ORG_NAME',
                                 avalue   => l_vendor_name);

      open lc_get_function_id(pc_func_name => 'OZF_SF_VENDOR_DETAILS');
      fetch lc_get_function_id into l_function_id;
      close lc_get_function_id;


      l_vendor_url := fnd_run_function.get_run_function_url(
                      l_function_id,
                      -1,
                      -1,
                      0,
                      'reqId=' || p_entity_id || '&' ||
                      'OfferId=' || l_offer_id || '&' ||
                      'StatusCode=' || p_status || '&' ||
                      'ApprovePriv=1' || '&' || 'pgMode=VDT');

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'VENDOR_LOGIN_URL',
                                 avalue   => l_vendor_url );

      open lc_get_function_id(pc_func_name => 'OZF_SF_PARTNER_DETAILS');
      fetch lc_get_function_id into l_function_id;
      close lc_get_function_id;

      l_partner_url := fnd_run_function.get_run_function_url(
                       l_function_id,
                       -1,
                       -1,
                       0,
                       'reqId=' || p_entity_id || '&' ||
                       'pgMode=PDT');

      l_partner_profile_url := fnd_profile.value('PV_WORKFLOW_ISTORE_URL');
      l_partner_profile_url := substr(l_partner_profile_url,1,instr(l_partner_profile_url,'/',1,3)-1); -- just get the http://<host>:<port>

      if length(l_partner_profile_url) > 0 then -- if profile is set, use it for partner URL
         l_partner_url := l_partner_profile_url || substr(l_partner_url, instr(l_partner_url,'/',1,3));
      end if;

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_LOGIN_URL',
                                 avalue   => l_partner_url );

      l_vendor_dtail_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=682' || '&' ||
                            'OAFunc=OZF_SF_VENDOR_DETAILS' || '&' ||
                            'reqId=' || p_entity_id || '&' ||
                            'OfferId=' || l_offer_id || '&' ||
                            'StatusCode=' || p_status || '&' ||
                            'ApprovePriv=1' || '&' || 'pgMode=VDT';

      l_partner_dtail_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=682' || '&' ||
                             'OAFunc=OZF_SF_PARTNER_DETAILS' || '&' ||
                             'reqId=' || p_entity_id || '&' ||
                             'pgMode=PDT';


      -- Setting the attribute value for updated projects URL
      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'VENDOR_DTAIL_URL',
                                 avalue   => l_vendor_dtail_url);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemKey,
                                 aname    => 'PARTNER_DTAIL_URL',
                                 avalue   => l_partner_dtail_url);

      IF l_decline_code IS NOT NULL THEN
         l_decline_meaning := OZF_Utility_PVT.get_lookup_meaning('OZF_SF_DECLINE_CODE',l_decline_code);
         wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                    itemkey  => p_itemKey,
                                    aname    => 'DECLINE_REASON',
                                    avalue   => l_decline_meaning);
         ozf_utility_pvt.debug_message( l_decline_meaning||': l_decline_meaning');
      END IF;

      IF l_return_code IS NOT NULL AND l_return_code <> '' THEN
         l_return_meaning := OZF_Utility_PVT.get_lookup_meaning('OZF_SF_RETURN_CODE',l_return_code);
         wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                    itemkey  => p_itemKey,
                                    aname    => 'RETURN_REASON',
                                    avalue   => l_return_code);
      END IF;

   end if; --if p_itemtype = 'OZFSPBEN' then

   if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'ozf.plsql.OZF_REQUEST_STATUS_PVT.Set_Request_Message.end', 'Exiting');
   end if;

END;

---------------------------------------------------------------------
-- PROCEDURE
--    Return_Request_Userlist
--
-- PURPOSE
--    Handles the approvals and rejections of objects
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Return_Request_Userlist (
   p_benefit_type        IN VARCHAR2,
   p_entity_id           IN  NUMBER,
   p_user_role           IN  VARCHAR2,
   p_status              IN  VARCHAR2) RETURN VARCHAR2
is
l_role_list varchar2(1000);
l_partner_id number;

cursor lc_get_ext_super_users(pc_permission varchar2,
                              pc_partner_id number) is
   SELECT
      usr.user_name
   FROM
      pv_partner_profiles   prof,
      hz_relationships      pr2,
      jtf_rs_resource_extns pj,
      fnd_user              usr
   WHERE
             prof.partner_id        = pc_partner_id
      and    prof.partner_party_id  = pr2.object_id
      and    pr2.subject_table_name = 'HZ_PARTIES'
      and    pr2.object_table_name  = 'HZ_PARTIES'
      and    pr2.directional_flag   = 'F'
      and    pr2.relationship_code  = 'EMPLOYEE_OF'
      and    pr2.relationship_type  = 'EMPLOYMENT'
      and    (pr2.end_date is null or pr2.end_date > sysdate)
      and    pr2.status            = 'A'
      and    pr2.party_id           = pj.source_id
      and    pj.category       = 'PARTY'
      and    usr.user_id       = pj.user_id
      and   (usr.end_date > sysdate OR usr.end_date IS NULL)
      and exists(select 1 from jtf_auth_principal_maps jtfpm,
                 jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,
                 jtf_auth_principals_b jtfp2, jtf_auth_role_perms jtfrp,
                 jtf_auth_permissions_b jtfperm
                 where PJ.user_name = jtfp1.principal_name
                 and jtfp1.is_user_flag=1
                 and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
                 and jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
                 and jtfp2.is_user_flag=0
                 and jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
                 and jtfrp.positive_flag = 1
                 and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
                 and jtfperm.permission_name = pc_permission
                 and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
                 and jtfd.domain_name='CRM_DOMAIN' );

cursor lc_get_int_super_users(pc_permission varchar2) is
      select usr.user_name
      from jtf_auth_principal_maps jtfpm,
      jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,
      jtf_auth_principals_b jtfp2, jtf_auth_role_perms jtfrp,
      jtf_auth_permissions_b jtfperm, jtf_rs_resource_extns pj,
      fnd_user usr
      where PJ.user_name = jtfp1.principal_name
      and pj.category = 'EMPLOYEE'
      and usr.user_id       = pj.user_id
      and (usr.end_date > sysdate OR usr.end_date IS NULL)
      and jtfp1.is_user_flag=1
      and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
      and jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
      and jtfp2.is_user_flag=0
      and jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
      and jtfrp.positive_flag = 1
      and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      and jtfperm.permission_name = pc_permission
      and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
      and jtfd.domain_name='CRM_DOMAIN';

cursor lc_get_partner_id(pc_entity_id number) is
select partner_id
from   ozf_request_headers_all_b
where  request_header_id = pc_entity_id;

cursor lc_get_pt_cont(pc_entity_id number) is
select fnd.user_name
from   fnd_user fnd
,      ozf_request_headers_all_b ref
,      jtf_rs_resource_extns jtf
where  ref.partner_contact_id = jtf.resource_id
and    jtf.user_id = fnd.user_id
and    ref.request_header_id = pc_entity_id;

begin
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'ozf.plsql.OZF_REQUEST_STATUS_PVT.Return_Request_Userlist.start',
       'Benefit type:' || p_benefit_type || '. Entity id: ' || p_entity_id ||
       '. Status:' || p_status || '. User type: ' || p_user_role);
    end if;

    open lc_get_partner_id(pc_entity_id => p_entity_id);
    fetch lc_get_partner_id into l_partner_id;
    close lc_get_partner_id;

    if p_user_role = 'SPECIAL_PRICE_SUPERUSER_EXT' then

        for l_row in lc_get_ext_super_users(pc_permission => 'OZF_SPECIAL_PRICE_SUPERUSER',
        pc_partner_id => l_partner_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'SOFT_FUND_SUPERUSER_EXT' then

        for l_row in lc_get_ext_super_users(pc_permission => 'OZF_SOFTFUND_SUPERUSER',
        pc_partner_id => l_partner_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'SPECIAL_PRICE_SUPERUSER_INT' then

        for l_row in lc_get_int_super_users(pc_permission => 'OZF_SPECIAL_PRICE_SUPERUSER') loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'SOFT_FUND_SUPERUSER_INT' then

        for l_row in lc_get_int_super_users(pc_permission => 'OZF_SOFTFUND_SUPERUSER') loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'PT_CONTACT' then

        for l_row in lc_get_pt_cont(pc_entity_id => p_entity_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    else
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'ozf.plsql.OZF_REQUEST_STATUS_PVT.Return_Request_Userlist.info',
             'Unrecognized user role:' || p_user_role);
         END IF;
    end if;

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'ozf.plsql.OZF_REQUEST_STATUS_PVT.Return_Request_Userlist.end', 'Exiting');
    end if;

    return l_role_list;
end;
---------------------------------------------------------------------
-- PROCEDURE
--    Create_Interaction
--
-- PURPOSE
--    Created Interaction History
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Create_Interaction (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_approval_rec           IN  OZF_APPROVAL_PVT.approval_rec_type
)
IS
CURSOR csr_partner (v_request_id in number) IS
SELECT partner_id, request_number,
       agreement_number, authorization_code, activity_media_id
FROM   ozf_request_headers_all_b
WHERE  request_header_id = v_request_id;

CURSOR csr_activity_name (v_activity_id in number) IS
SELECT channel_name
FROM   ams_channels_vl
WHERE  channel_id = v_activity_id;

l_api_name CONSTANT   varchar2(80) := 'Create_Interaction';
l_api_version CONSTANT number := 1.0;
l_history_category  varchar2(30) := 'GENERAL';
l_message_code      varchar2(30);
l_access_level      varchar2(1) := 'V';
l_interaction_level number := PVX_UTILITY_PVT.G_INTERACTION_LEVEL_50;
l_comments          varchar2(2000);
l_status            varchar2(30) := p_approval_rec.status_code;
l_log_params_tbl    PVX_UTILITY_PVT.log_params_tbl_type;

l_partner_id        number;
l_request_number    varchar2(30);
l_agreement_number  varchar2(30);
l_authorization_code varchar2(30);
l_activity_id       number;
l_activity_name     varchar2(80);
l_return_status     varchar2(1);

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Create_Interaction_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Partner details
    OPEN csr_partner (p_approval_rec.object_id);
       FETCH csr_partner INTO l_partner_id,
                              l_request_number,
                              l_agreement_number,
                              l_authorization_code,
                              l_activity_id;
    CLOSE csr_partner;


    -- Construct Message details
    IF p_approval_rec.object_type = 'SPECIAL_PRICE' THEN

       IF l_status = 'DRAFT' THEN
          l_message_code := 'OZF_SP_DRAFT_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'SUBMITTED_FOR_APPROVAL' THEN
          l_message_code := 'OZF_SP_PENDING_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := 'l_request_number';

       ELSIF l_status = 'RETURNED' THEN
          l_message_code := 'OZF_SP_RETURNED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'DECLINED' THEN
          l_message_code := 'OZF_SP_REJECTED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'APPROVED' THEN
          l_message_code := 'OZF_SP_APPROVED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;
          l_log_params_tbl(2).param_name := 'AGREEMENT_NUM';
          l_log_params_tbl(2).param_value := l_agreement_number;
          l_log_params_tbl(3).param_name := 'AUTH_CODE';
          l_log_params_tbl(3).param_value := l_authorization_code;

       ELSIF l_status = 'BUDGETAPP' THEN
          l_message_code := 'OZF_SP_BUDGETAPP_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'CLOSED' THEN
          l_message_code := 'OZF_SP_CLOSED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;
          l_log_params_tbl(2).param_name := 'AGREEMENT_NUM';
          l_log_params_tbl(2).param_value := l_agreement_number;
          l_log_params_tbl(3).param_name := 'AUTH_CODE';
          l_log_params_tbl(3).param_value := l_authorization_code;

       ELSIF l_status = 'VOID' THEN
          l_message_code := 'OZF_SP_VOID_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;
          l_log_params_tbl(2).param_name := 'AGREEMENT_NUM';
          l_log_params_tbl(2).param_value := l_agreement_number;
          l_log_params_tbl(3).param_name := 'AUTH_CODE';
          l_log_params_tbl(3).param_value := l_authorization_code;

       ELSIF l_status = 'ARCHIVED' THEN
          l_message_code := 'OZF_SP_ARCHIVED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;
          l_log_params_tbl(2).param_name := 'AGREEMENT_NUM';
          l_log_params_tbl(2).param_value := l_agreement_number;
          l_log_params_tbl(3).param_name := 'AUTH_CODE';
          l_log_params_tbl(3).param_value := l_authorization_code;

       END IF;

    ELSIF p_approval_rec.object_type = 'SOFT_FUND' THEN

       -- Get Activity details
       OPEN csr_activity_name (l_activity_id);
          FETCH csr_activity_name INTO l_activity_name;
       CLOSE csr_activity_name;

       IF l_status = 'DRAFT' THEN
          l_message_code := 'OZF_SF_DRAFT_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'SUBMITTED_FOR_APPROVAL' THEN
          l_message_code := 'OZF_SF_PENDING_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'RETURNED' THEN
          l_message_code := 'OZF_SF_RETURNED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'DECLINED' THEN
          l_message_code := 'OZF_SF_REJECTED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'APPROVED' THEN
          l_message_code := 'OZF_SF_APPROVED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;
          l_log_params_tbl(2).param_name := 'ACTIVITY';
          l_log_params_tbl(2).param_value := l_activity_name;

       ELSIF l_status = 'BUDGETAPP' THEN
          l_message_code := 'OZF_SF_BUDGETAPP_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'CLOSED' THEN
          l_message_code := 'OZF_SF_CLOSED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'VOID' THEN
          l_message_code := 'OZF_SF_VOID_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       ELSIF l_status = 'ARCHIVED' THEN
          l_message_code := 'OZF_SF_ARCHIVED_LOG';
          l_log_params_tbl(1).param_name := 'REQ_NUM';
          l_log_params_tbl(1).param_value := l_request_number;

       END IF;

    END IF;

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Before creating interaction ' || l_message_code);
    END IF;

    IF l_message_code IS NOT null THEN
       -- Create Interaction History
       PVX_UTILITY_PVT.create_history_log(
          p_arc_history_for_entity_code => p_approval_rec.object_type,
          p_history_for_entity_id       => p_approval_rec.object_id,
          p_history_category_code       => l_history_category,
          p_message_code                => l_message_code,
          p_partner_id                  => l_partner_id,
          p_access_level_flag           => l_access_level,
          p_interaction_level           => l_interaction_level,
          p_comments                    => l_comments,
          p_log_params_tbl              => l_log_params_tbl,
          x_return_status               => l_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                    => x_msg_data
       );
       ozf_utility_pvt.debug_message( 'after creating interaction ' || l_return_status);
       IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Create_Interaction_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Interaction_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Create_Interaction_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Create_Interaction;

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(+)

---------------------------------------------------------------------
-- PROCEDURE
--    Event_SD_Subscription
--
-- PURPOSE
--    Subscription for the event raised for Ship & Debit Request
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Event_SD_Subscription(
   p_subscription_guid IN     raw,
   p_event             IN OUT NOCOPY wf_event_t)
RETURN varchar2
is

l_api_name    CONSTANT VARCHAR2(30) := 'Event_SD_Subscription';
l_api_version CONSTANT number := 1.0;
l_rule                   varchar2(20);
l_parameter_list         wf_parameter_list_t := wf_parameter_list_t();
l_parameter_t            wf_parameter_t := wf_parameter_t(null, null);
l_parameter_name         l_parameter_t.name%type;
i                        pls_integer;
l_event_key    varchar2(240);
l_object_id    number;
l_action_code varchar2(30);
l_user_list    varchar2(2000);
l_msg_count number;
l_msg_data varchar2(2000);
l_return_status varchar2(10);

BEGIN
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    l_parameter_list := p_event.getParameterList();
    l_event_key := p_event.getEventKey();

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Event Key ' || l_event_key);
    END IF;

    IF l_parameter_list IS NOT NULL THEN
       i := l_parameter_list.FIRST;
       WHILE ( i <= l_parameter_list.last) LOOP
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message( 'Parameter Name ' || l_parameter_list(i).getName());
             ozf_utility_pvt.debug_message( 'Parameter Value ' || l_parameter_list(i).getValue());
             ozf_utility_pvt.debug_message( 'Parameter ' || i || ' of ' || l_parameter_list.last);
          END IF;
          l_parameter_name := null;
          l_parameter_name  := l_parameter_list(i).getName();
          IF l_parameter_name = 'OBJECT_ID' THEN
             l_object_id := l_parameter_list(i).getValue();
          ELSIF l_parameter_name = 'ACTION_CODE' THEN
             l_action_code := l_parameter_list(i).getValue();
          END IF;
          i := l_parameter_list.next(i);
       END LOOP;

       -- Call api to send notification
       IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'before calling api to send notification');
       END IF;

        OZF_APPROVAL_PVT.Send_SD_Notification(
            p_api_version         => l_api_version,
            p_init_msg_list       => FND_API.G_FALSE,
            x_return_status       => l_return_status,
            x_msg_data            => l_msg_data,
            x_msg_count           => l_msg_count,
            p_object_id           => l_object_id,
            p_action_code         => l_action_code);

       IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Return Status: '||l_return_status);
       END IF;
        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RETURN 'ERROR';
        END IF;

    END IF;

    RETURN 'SUCCESS';

    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;

EXCEPTION
   WHEN OTHERS THEN
        WF_CORE.CONTEXT(G_PKG_NAME, L_API_NAME, P_EVENT.GETEVENTNAME(), P_SUBSCRIPTION_GUID);
        WF_EVENT.SETERRORINFO(P_EVENT,'ERROR');
        RETURN 'ERROR';
--
END Event_SD_Subscription;

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(-)


END OZF_REQUEST_STATUS_PVT;

/
