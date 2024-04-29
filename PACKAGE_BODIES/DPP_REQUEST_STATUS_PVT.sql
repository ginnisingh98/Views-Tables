--------------------------------------------------------
--  DDL for Package Body DPP_REQUEST_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_REQUEST_STATUS_PVT" AS
/* $Header: dppvrstb.pls 120.11.12010000.3 2010/04/21 13:33:54 kansari ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_REQUEST_STATUS_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'dppvrstb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

DPP_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
DPP_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
DPP_UNEXP_ERROR_ON BOOLEAN :=FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error);
DPP_ERROR_ON BOOLEAN := FND_MSG_PUB.check_msg_level(fnd_msg_pub.g_msg_lvl_error);
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

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
l_object_type  varchar2(30) := 'PRICE PROTECTION';
l_object_id    number;
l_user_list    varchar2(2000);
l_msg_count number;
l_msg_data varchar2(2000);
l_return_status varchar2(10);
l_approval_rec DPP_APPROVAL_PVT.approval_rec_type;
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_REQUEST_STATUS_PVT.EVENT_SUBSCRIPTION';
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Event_Subscription_PVT;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': Start');


    l_parameter_list := p_event.getParameterList();
    l_event_key := p_event.getEventKey();


    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Event Key ' || l_event_key);


    IF l_parameter_list IS NOT NULL THEN
        i := l_parameter_list.FIRST;
        WHILE ( i <= l_parameter_list.last) LOOP

            dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Parameter Name ' || l_parameter_list(i).getName());
            dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Parameter Value ' || l_parameter_list(i).getValue());
            dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Parameter ' || i || ' of ' || l_parameter_list.last);

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

        l_msg_callback_api := 'DPP_REQUEST_STATUS_PVT.Set_Request_Message';

        l_approval_rec.object_type := l_object_type;
        l_approval_rec.object_id := l_object_id;
        l_approval_rec.status_code := l_status;


        -- Call api to send notification
        DPP_APPROVAL_PVT.Send_Notification(
            p_api_version         => l_api_version,
            p_init_msg_list       => FND_API.G_FALSE,
            --p_validation_level    => p_validation_level,
            x_return_status       => l_return_status,
            x_msg_data            => l_msg_data,
            x_msg_count           => l_msg_count,
            p_transaction_header_id      => l_object_id,
            p_msg_callback_api    => l_msg_callback_api,
            p_approval_rec        => l_approval_rec
        );

        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RETURN 'ERROR';
        END IF;

    END IF;

    RETURN 'SUCCESS';

    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': End');


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
---------------------------------------------------------------------
PROCEDURE Set_Request_Message (
   p_itemtype            IN VARCHAR2,
   p_itemkey             IN VARCHAR2,
   P_transaction_header_id           IN  NUMBER,
   P_STATUS              IN  VARCHAR2)
IS

l_api_name            CONSTANT VARCHAR2(30) := 'Set_Request_Message';

l_request_header_id       number;
l_request_number     varchar2(50);
l_request_name     varchar2(100);
l_comp_amount       varchar2(20);
l_entity_status     varchar2(100);
l_entity_creation_date varchar2(30);
l_notes_clob CLOB;
l_notes_varchar varchar2(4000);
l_note_size binary_integer := 4000;

l_last_approver_name        varchar2(200);
l_request_type        varchar2(20);
l_agreement_number        varchar2(30);
l_authorization_code        varchar2(30);
l_login_url varchar2(1000);
l_request_type_code varchar2(30);
l_user_dtail_url varchar2(200);
l_note_type varchar2(20);
l_offer_id  NUMBER;

l_transaction_header_id NUMBER;
l_transaction_number  VARCHAR2(40);
l_ref_document_number  VARCHAR2(40);
l_vendor_name  VARCHAR2(240);
l_vendor_site_code   VARCHAR2(240);
l_contact_name varchar2(360);
l_creator_name varchar2(360);
l_transaction_status varchar2(40);
l_creation_date date;
l_currency varchar2(15);
l_decline_code   varchar2(30);
l_return_code    varchar2(30);
l_decline_meaning        varchar2(200);
l_return_meaning        varchar2(200);
l_contact_phone varchar2(15);
l_contact_email VARCHAR2(2000);
l_start_date date;
l_days_covered number;
l_status varchar2(30);

l_function_id  NUMBER;
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_REQUEST_STATUS_PVT.SET_REQUEST_MESSAGE';

cursor lc_get_request_details (pc_header_id number) is
select dtha.transaction_header_id
,      dtha.transaction_number
,      dtha.ref_document_number
,      asp.vendor_name
,		   assa.vendor_site_code
,      dtha.vendor_contact_name SUP_CONTACT_name
,      creator.source_first_name || ' ' || creator.source_last_name creator_name
,      lkup.meaning
,      dtha.creation_date
,      dtha.trx_currency
,      dtha.contact_phone
,      dtha.contact_email_address
,      dtha.effective_start_date
,      dtha.days_covered,
       dtha.transaction_status
from   dpp_transaction_headers_all dtha
,      ap_suppliers asp
,      jtf_rs_resource_extns creator
,       dpp_lookups lkup
,      ap_supplier_sites_all assa
where  dtha.transaction_header_id = pc_header_id
and    dtha.vendor_id = asp.vendor_id
and    asp.vendor_id = assa.vendor_id
and    assa.vendor_site_id = dtha.vendor_site_id
and	assa.org_id = dtha.org_id
and    dtha.last_updated_by = creator.resource_id (+)
and    dtha.transaction_status = lkup.lookup_code
and    lkup.lookup_type = 'DPP_TRANSACTION_STATUSES';

cursor lc_get_notes(pc_entity_type varchar2, pc_transaction_header_id number) is
select notes_detail
from   jtf_notes_vl
where  source_object_code = pc_entity_type
AND    SOURCE_OBJECT_ID = pc_transaction_header_id
AND    NOTE_STATUS in ('E' , 'I')   -- only publish notes and also  Public
ORDER BY CREATION_DATE DESC;

cursor lc_last_approver_name (pc_entity_type varchar2, pc_transaction_header_id number) is
SELECT res.source_first_name || ' '|| res.source_last_name
FROM jtf_rs_resource_extns  res, dpp_approval_access dac
where res.user_id =  dac.approver_id
and dac.object_type = pc_entity_type
and dac.object_id = pc_transaction_header_id
and dac.approval_access_id = ( select max(approval_access_id)
               from dpp_approval_access
			   where dac.object_type = pc_entity_type
               and dac.object_id = pc_transaction_header_id );

cursor lc_media_name ( pc_media_id number) is
select media_type_name from
ams_media_vl
where media_id = pc_media_id;


cursor lc_get_function_id (pc_func_name varchar2) is
 select function_id from fnd_form_functions where function_name = pc_func_name ;


BEGIN

   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'dpp.plsql.DPP_REQUEST_STATUS_PVT.Set_Request_Message.start',
      'Item type:' || p_itemtype || 'Item key:' || p_itemkey || '. Entity id: ' ||
      p_transaction_header_id || '. Status:' || p_status );
   end if;

   open lc_get_request_details (pc_header_id => p_transaction_header_id);

   fetch lc_get_request_details into l_transaction_header_id
                                   , l_transaction_number
                                   , l_ref_document_number
                                   , l_vendor_name
                                   , l_vendor_site_code
                                   , l_contact_name
                                   , l_creator_name
                                   , l_transaction_status
                                   , l_creation_date
                                   , l_currency
                                --   , l_decline_code
                                --   , l_return_code
                                   , l_contact_phone
                                   , l_contact_email
                                   , l_start_date
                                   , l_days_covered
                                   ,l_status;

   close lc_get_request_details;

   if p_itemtype = 'DPPTXAPP' then
       l_note_type := 'PRICE PROTECTION';
   end if;

   open lc_get_notes(pc_entity_type => l_note_type, pc_transaction_header_id => p_transaction_header_id);
   fetch lc_get_notes into l_notes_clob;
   close lc_get_notes;


   l_notes_varchar := dbms_lob.substr(lob_loc => l_notes_clob, amount => l_note_size, offset => 1);

   if p_itemtype = 'DPPTXAPP' then
       l_request_type := 'PRICE PROTECTION';
   end if;

   open lc_last_approver_name(pc_entity_type => l_request_type, pc_transaction_header_id => p_transaction_header_id);
   fetch lc_last_approver_name into l_last_approver_name;
   close lc_last_approver_name;

   if p_itemtype = 'DPPTXAPP' then

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'inside  Notification   ' || p_itemKey  );
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Phone number is   ' || l_contact_phone  );


        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'SUPPLIER_NAME',
                                   avalue   => l_vendor_name);

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_vendor_name ' || l_vendor_name  );


        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'SUPPLIER_SITE_CODE',
                                   avalue   => l_vendor_site_code);

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_vendor_site_code ' || l_vendor_site_code  );

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'SUPPLIER_CONTACT',
                                   avalue   => l_contact_name
                                 );

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_contact_name ' || l_contact_name  );

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'SUPPLIER_CONTACT_PHONE',
                                   avalue   => l_contact_phone);

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_contact_phone ' || l_contact_phone  );

 /*     wf_engine.SetItemAttrDate( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'SUPPLIER_CONTACT_MAIL',
                                   avalue   => l_contact_email); */

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_contact_email ' || l_contact_email  );
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_transaction_header_id is   ' || l_transaction_header_id  );

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'TRANSACTION_HEADER_ID',
                                   avalue   => l_transaction_header_id);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'TRANSACTION_NUMBER',
                              avalue   => l_transaction_number);

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_ref_document_number is   ' || l_ref_document_number  );

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'REF_DOCUMENT_NUMBER',
                              avalue   => l_ref_document_number);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'CURRENCY',
                                   avalue   => l_currency);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'TRANSACTION_STATUS',
                                   avalue   => l_transaction_status);

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_start_date is   ' || l_start_date  );

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'EFFECTIVE_START_DATE',
                                   avalue   => l_start_date);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'DAYS_COVERED',
                                   avalue   => l_days_covered);

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_days_covered is   ' || l_days_covered  );

        open lc_get_function_id(pc_func_name => 'DPP_TXNUPDPG');
        fetch lc_get_function_id into l_function_id;
        close lc_get_function_id;

        l_login_url := fnd_run_function.get_run_function_url
		                   (l_function_id,
			                  -1,
			                  -1,
			                   0,
			                 'DPPReqFrmTxnHdrId=' || p_transaction_header_id );

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'USER_LOGIN_URL',
                                   avalue   => l_login_url );



        l_user_dtail_url :=
           '/OA_HTML/OA.jsp?akRegionApplicationId=9000'|| '&'||'OAFunc=DPP_TXNUPDPG'||'&'||
			'DPPReqFrmTxnHdrId=' || p_transaction_header_id ||'&'||
                        'DPPReqFrmTgtTb=INVTB'||'&'||
                        'DPPReqFrmFuncName=DPP_TXNUPDPG'||'&'||
                        'addBreadCrumb=Y'
                        --||'&'||'retainAM=Y'
                        ;


             -- Setting the attribute value for updated projects URL
             wf_engine.SetItemAttrText
              ( itemtype => p_itemtype,
                itemkey  => p_itemKey,
                aname    => 'USER_DTAIL_URL',
                avalue   => l_user_dtail_url
              );

     if l_decline_code IS NOT NULL THEN
        l_decline_meaning := OZF_Utility_PVT.get_lookup_meaning('DPP_TRANSACTION_DECLINE_CODE',l_decline_code);
        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'DECLINE_REASON',
                              avalue   => l_decline_meaning);
     END IF;

 end if;
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'dpp.plsql.DPP_REQUEST_STATUS_PVT.Set_Request_Message.end', 'Exiting');
    end if;

END;
END DPP_REQUEST_STATUS_PVT;

/
