--------------------------------------------------------
--  DDL for Package Body CSL_SERVICE_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_SERVICE_REQUESTS_PKG" AS
/* $Header: cslvincb.pls 120.1 2005/08/30 21:26:24 utekumal noship $ */

error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_SERVICE_REQUESTS_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSL_CS_INCIDENTS_ALL_VL';
g_debug_level           NUMBER; -- debug level

CURSOR c_incident( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSL_CS_INCIDENTS_ALL_VL_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

CURSOR c_contact( b_incident_id NUMBER, b_tranid NUMBER, b_user_name VARCHAR2 ) IS
  SELECT *
  FROM  CSL_CS_HZ_SR_CONTACT_PTS_INQ
  WHERE INCIDENT_ID = b_incident_id
  AND   TRANID$$ = b_tranid
  AND   clid$$cs = b_user_name;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_incident%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  -- Commented Out for Sql Repository Performance Fix

  /* CURSOR c_org_rel_contacts
    ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE
    ) IS
    SELECT b.party_id
    FROM   CSC_HZ_PARTIES_V  b
      WHERE  b.object_id = b_customer_id
--      AND    b.party_id = p_customer_contact_id
      AND    b.sub_status  =  'A'
      AND    b.obj_status  = 'A'
      AND    b.relation in ('CONTACT_OF','EMPLOYEE_OF')
      AND    b.party_type = 'PARTY_RELATIONSHIP'
--      AND    b.obj_party_type = 'ORGANIZATION' -- can be both org and person caller type
      AND    rownum <= 1;

  CURSOR c_person_contacts
    ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE
    ) IS
    SELECT b.subject_id
    FROM   CSC_HZ_PARTIES_V  b
    WHERE  b.object_id = b_customer_id
--    AND    b.subject_id = p_customer_contact_id
    AND    b.sub_status  =  'A'
    AND    b.obj_status  =  'A'
    AND    rownum <= 1
    UNION
    SELECT PARTY_ID
    FROM HZ_PARTIES
    WHERE party_id = b_customer_id
    AND status ='A';  */


  CURSOR c_org_rel_contacts
    ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE
    ) IS
    SELECT b.party_id FROM HZ_RELATIONSHIPS  b
      WHERE  b.object_id = b_customer_id
      AND    object_table_name = 'HZ_PARTIES'
      AND    status  =  'A'
      AND    b.relationship_code in ('CONTACT_OF','EMPLOYEE_OF')
      AND    rownum <= 1;


  CURSOR c_person_contacts
    ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE
    ) IS
    SELECT b.subject_id FROM HZ_RELATIONSHIPS  b
    WHERE  b.object_id = b_customer_id
      AND    object_table_name = 'HZ_PARTIES'
      AND    status  =  'A'
      AND    rownum <= 1;


  CURSOR c_party_contact
    ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE
    ) IS
    SELECT PARTY_ID FROM HZ_PARTIES
    WHERE party_id = b_customer_id AND status = 'A';


  /* ER 3746707
     Cursor to get the Bill to Address */
  CURSOR c_bill_to_site_id
    ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE
    ) IS
  SELECT use.party_site_use_id FROM
    hz_party_sites site, hz_party_site_uses use
  WHERE site.party_site_id = use.party_site_id
        AND site.status= 'A'
	AND use.site_use_type= 'BILL_TO'
        AND use.primary_per_type = 'Y'
	AND use.status = 'A'
        AND site.party_id = b_customer_id
        AND trunc(SYSDATE) BETWEEN TRUNC (NVL(use.begin_date, SYSDATE))
            AND (NVL(use.end_date, SYSDATE));

  /* ER 3746707
     Cursor to get the Ship to Address */
  CURSOR c_ship_to_site_id
    ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE
    ) IS
  SELECT use.party_site_use_id FROM
    hz_party_sites site, hz_party_site_uses use
  WHERE site.party_site_id = use.party_site_id
        AND site.status= 'A'
	AND use.site_use_type= 'SHIP_TO'
        AND use.primary_per_type = 'Y'
	AND use.status = 'A'
        AND site.party_id = b_customer_id
        AND trunc(SYSDATE) BETWEEN TRUNC (NVL(use.begin_date, SYSDATE))
            AND (NVL(use.end_date, SYSDATE));

  /* ER 3746707
     Cursor to get the customer account id */
  CURSOR c_customer_account
    ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE
    ) IS
  SELECT custa.cust_account_id FROM hz_cust_accounts custa
    WHERE custa.status = 'A'
    AND custa.party_id = b_customer_id;

  l_sr_rec                CS_ServiceRequest_PUB.service_request_rec_type;
  l_user_id               NUMBER;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(240);
  l_notes_tab             CS_ServiceRequest_PUB.notes_table;
  l_contacts_tab          CS_ServiceRequest_PUB.contacts_table;
  l_request_id            NUMBER;
  l_request_number        VARCHAR2(64);
  l_interaction_id        NUMBER;
  l_workflow_process_id   NUMBER;
  l_contact_rec           CS_ServiceRequest_PUB.contacts_rec;
  l_contact_index         BINARY_INTEGER;
  l_contact_id            CS_HZ_SR_CONTACT_POINTS.PARTY_ID%TYPE;
  l_profile_value         VARCHAR2(240);
  l_decript_value         VARCHAR2(250);

  -- CS 11.5.9 Uptake
  x_individual_owner      NUMBER;
  x_individual_type       VARCHAR2(240);
  x_group_owner           NUMBER;

  --ER 3746707
  l_bill_to_site_use_id   NUMBER;
  l_ship_to_site_use_id   NUMBER;
  l_customer_account_id   NUMBER;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Lookup the user_id
  l_user_id := JTM_HOOK_UTIL_PKG.Get_User_Id( p_record.CLID$$CS );

   -- Initialization
  CS_ServiceRequest_PUB.INITIALIZE_REC
    ( p_sr_record => l_sr_rec
    );

  l_sr_rec.CALLER_TYPE         := p_record.CALLER_TYPE;
  l_sr_rec.SUMMARY             := p_record.SUMMARY;
  l_sr_rec.CUSTOMER_ID         := p_record.CUSTOMER_ID;
  l_sr_rec.INSTALL_SITE_ID     := NVL(p_record.INSTALL_SITE_ID, p_record.INSTALL_SITE_USE_ID);
  l_sr_rec.INSTALL_SITE_USE_ID := l_sr_rec.INSTALL_SITE_ID;
  l_sr_rec.CUSTOMER_PRODUCT_ID := p_record.CUSTOMER_PRODUCT_ID;
  l_sr_rec.INVENTORY_ITEM_ID   := p_record.INVENTORY_ITEM_ID;
  l_sr_rec.inventory_org_id    := TO_NUMBER(fnd_profile.value(
                                               'CS_INV_VALIDATION_ORG') ) ;
  l_sr_rec.PROBLEM_CODE        := p_record.PROBLEM_CODE;
  l_sr_rec.RESOLUTION_CODE     := p_record.RESOLUTION_CODE;
  l_sr_rec.CONTRACT_SERVICE_ID := p_record.CONTRACT_SERVICE_ID;
  l_sr_rec.INV_ITEM_REVISION   := p_record.INV_ITEM_REVISION;
  l_sr_rec.CUST_PO_NUMBER      := p_record.CUSTOMER_PO_NUMBER;
  l_sr_rec.SEVERITY_ID          := p_record.INCIDENT_SEVERITY_ID;
  l_sr_rec.STATUS_ID            := p_record.INCIDENT_STATUS_ID;
  l_sr_rec.TYPE_ID              := p_record.INCIDENT_TYPE_ID;
  l_sr_rec.URGENCY_ID           := p_record.INCIDENT_URGENCY_ID;
  l_sr_rec.request_attribute_1   := p_record.INCIDENT_ATTRIBUTE_1;
  l_sr_rec.request_attribute_2   := p_record.INCIDENT_ATTRIBUTE_2;
  l_sr_rec.request_attribute_3   := p_record.INCIDENT_ATTRIBUTE_3;
  l_sr_rec.request_attribute_4   := p_record.INCIDENT_ATTRIBUTE_4;
  l_sr_rec.request_attribute_5   := p_record.INCIDENT_ATTRIBUTE_5;
  l_sr_rec.request_attribute_6   := p_record.INCIDENT_ATTRIBUTE_6;
  l_sr_rec.request_attribute_7   := p_record.INCIDENT_ATTRIBUTE_7;
  l_sr_rec.request_attribute_8   := p_record.INCIDENT_ATTRIBUTE_8;
  l_sr_rec.request_attribute_9   := p_record.INCIDENT_ATTRIBUTE_9;
  l_sr_rec.request_attribute_10  := p_record.INCIDENT_ATTRIBUTE_10;
  l_sr_rec.request_attribute_11  := p_record.INCIDENT_ATTRIBUTE_11;
  l_sr_rec.request_attribute_12  := p_record.INCIDENT_ATTRIBUTE_12;
  l_sr_rec.request_attribute_13  := p_record.INCIDENT_ATTRIBUTE_13;
  l_sr_rec.request_attribute_14  := p_record.INCIDENT_ATTRIBUTE_14;
  l_sr_rec.request_attribute_15  := p_record.INCIDENT_ATTRIBUTE_15;
  l_sr_rec.request_context       := p_record.INCIDENT_CONTEXT;

  --ER 3949138
  l_sr_rec.external_attribute_1   := p_record.EXTERNAL_ATTRIBUTE_1;
  l_sr_rec.external_attribute_2   := p_record.EXTERNAL_ATTRIBUTE_2;
  l_sr_rec.external_attribute_3   := p_record.EXTERNAL_ATTRIBUTE_3;
  l_sr_rec.external_attribute_4   := p_record.EXTERNAL_ATTRIBUTE_4;
  l_sr_rec.external_attribute_5   := p_record.EXTERNAL_ATTRIBUTE_5;
  l_sr_rec.external_attribute_6   := p_record.EXTERNAL_ATTRIBUTE_6;
  l_sr_rec.external_attribute_7   := p_record.EXTERNAL_ATTRIBUTE_7;
  l_sr_rec.external_attribute_8   := p_record.EXTERNAL_ATTRIBUTE_8;
  l_sr_rec.external_attribute_9   := p_record.EXTERNAL_ATTRIBUTE_9;
  l_sr_rec.external_attribute_10  := p_record.EXTERNAL_ATTRIBUTE_10;
  l_sr_rec.external_attribute_11  := p_record.EXTERNAL_ATTRIBUTE_11;
  l_sr_rec.external_attribute_12  := p_record.EXTERNAL_ATTRIBUTE_12;
  l_sr_rec.external_attribute_13  := p_record.EXTERNAL_ATTRIBUTE_13;
  l_sr_rec.external_attribute_14  := p_record.EXTERNAL_ATTRIBUTE_14;
  l_sr_rec.external_attribute_15  := p_record.EXTERNAL_ATTRIBUTE_15;
  l_sr_rec.external_context       := p_record.EXTERNAL_CONTEXT;

  /* 11.5.10 incident address changes - 3430663 */
  l_sr_rec.incident_location_id  := p_record.incident_location_id;
  l_sr_rec.incident_address  := p_record.incident_address;
  l_sr_rec.incident_city  := p_record.incident_city;
  l_sr_rec.incident_state  := p_record.incident_state;
  l_sr_rec.incident_country  := p_record.incident_country;
  l_sr_rec.incident_province  := p_record.incident_province;
  l_sr_rec.incident_postal_code  := p_record.incident_postal_code;
  l_sr_rec.incident_county  := p_record.incident_county;
  l_sr_rec.incident_location_type  := p_record.incident_location_type;

  /*Get all contacts*/
  l_contact_index := 0;
  FOR r_contact IN c_contact ( p_record.incident_id,
                               p_record.tranid$$, p_record.clid$$cs )
  LOOP
    /*Contact is passed from mobile*/
    l_contact_index := l_contact_index + 1;
    l_contact_rec.SR_CONTACT_POINT_ID := r_contact.SR_CONTACT_POINT_ID;
    l_contact_rec.PARTY_ID            := r_contact.PARTY_ID;
    l_contact_rec.CONTACT_POINT_ID    := r_contact.CONTACT_POINT_ID;
    l_contact_rec.PRIMARY_FLAG        := r_contact.PRIMARY_FLAG;
    l_contact_rec.CONTACT_TYPE        := r_contact.CONTACT_TYPE;
    l_contacts_tab( l_contact_index ) := l_contact_rec;
  END LOOP;

  /*
  -- Comment out the following section, as contact is not mandatory for
  -- CS APIs anymore, and we don't want to default wrong contact for the SR

  IF l_contact_index = 0 THEN

    -- Contact was not passed from mobile, so get the primary contact from
    -- the backend contact type is from profile CS_SR_DEFAULT_CONTACT_TYPE
    -- if person

    OPEN c_org_rel_contacts( p_record.customer_id );
    FETCH c_org_rel_contacts INTO l_contact_id;

    IF c_org_rel_contacts%FOUND THEN
      l_contact_rec.PARTY_ID     := l_contact_id;
      l_contact_rec.PRIMARY_FLAG := 'Y';
      l_contact_rec.CONTACT_TYPE := 'PARTY_RELATIONSHIP';

    ELSIF p_record.CALLER_TYPE = 'PERSON' THEN
      -- Get the person contact
      OPEN c_person_contacts( p_record.customer_id );
      FETCH c_person_contacts INTO l_contact_id;

      IF c_person_contacts%NOTFOUND THEN
        OPEN c_party_contact (p_record.customer_id);
        FETCH c_party_contact INTO l_contact_id;
        IF c_party_contact%NOTFOUND THEN
          l_contact_id := p_record.customer_id;
        END IF;
      END IF;

      CLOSE c_person_contacts;
      l_contact_rec.PARTY_ID     := l_contact_id;
      l_contact_rec.PRIMARY_FLAG := 'Y';
      l_contact_rec.CONTACT_TYPE := 'PERSON';
    END IF; -- c_org_rel_contacts%FOUND THEN

    CLOSE c_org_rel_contacts;
    -- Set the contact tab to the found contact
    l_contacts_tab( 1 ) := l_contact_rec;
  END IF; -- l_contact_index = 0

  */

  -- See if Credit Card profile is set?
  --Bug 4496299
  /*
  l_profile_value := fnd_profile.value('JTM_CREDIT_CARD_ENABLED');
  IF l_profile_value = 'Y' THEN
    IF p_record.CREDIT_CARD_NUMBER IS NOT NULL THEN
      l_decript_value := CS_SERVICEREQUEST_PUB.CC_DECODE(p_record.CREDIT_CARD_NUMBER);
      l_sr_rec.cc_number          := l_decript_value;
      l_sr_rec.cc_type_code       := p_record.CREDIT_CARD_TYPE_CODE;
      l_sr_rec.cc_expiration_date := p_record.CREDIT_CARD_EXPIRATION_DATE;
      l_sr_rec.cc_first_name      := p_record.CREDIT_CARD_HOLDER_FNAME;
      l_sr_rec.cc_middle_name     := p_record.CREDIT_CARD_HOLDER_MNAME;
      l_sr_rec.cc_last_name       := p_record.CREDIT_CARD_HOLDER_LNAME;
      l_sr_rec.cc_id              := p_record.CREDIT_CARD_ID;
    END IF;
  END IF;
*/

  /* ER 3746707
     Get Bill to Site id */
  OPEN c_bill_to_site_id ( p_record.CUSTOMER_ID );
  FETCH c_bill_to_site_id INTO l_bill_to_site_use_id;
  IF c_bill_to_site_id%NOTFOUND THEN
     l_bill_to_site_use_id := NULL;
  END IF;
  CLOSE c_bill_to_site_id ;

  l_sr_rec.bill_to_site_use_id := l_bill_to_site_use_id;
  l_sr_rec.bill_to_party_id := p_record.CUSTOMER_ID;

  /* ER 3746707
     Get Ship to Site id */
  OPEN c_ship_to_site_id ( p_record.CUSTOMER_ID );
  FETCH c_ship_to_site_id INTO l_ship_to_site_use_id;
  IF c_ship_to_site_id%NOTFOUND THEN
     l_ship_to_site_use_id := NULL;
  END IF;
  CLOSE c_ship_to_site_id ;

  l_sr_rec.ship_to_site_use_id := l_ship_to_site_use_id;
  l_sr_rec.ship_to_party_id := p_record.CUSTOMER_ID;

  /* ER 3746707
     Get customer Account id - Just pick the first record */
  OPEN c_customer_account ( p_record.CUSTOMER_ID );
  FETCH c_customer_account INTO l_customer_account_id;
  IF c_customer_account%NOTFOUND THEN
     l_customer_account_id := NULL;
  END IF;
  CLOSE c_customer_account;

  l_sr_rec.account_id := l_customer_account_id;


  -- CS 11.5.9 Uptake
  l_sr_rec.creation_program_code := 'CSL_LAPTOP';

  -- Api Modified, version 3.0, new parameters for Assignment Mgr
  CS_ServiceRequest_PUB.Create_ServiceRequest
    ( p_api_version          => 3.0
    , p_init_msg_list        => FND_API.G_TRUE
    , p_commit               => FND_API.G_TRUE
    , x_return_status        => x_return_status
    , x_msg_count            => l_msg_count
    , x_msg_data             => l_msg_data
    , p_user_id              => l_user_id
    , p_org_id               => p_record.org_id
    , p_request_id           => p_record.incident_id
    , p_request_number       => p_record.incident_number
    , p_service_request_rec  => l_sr_rec
    , p_notes                => l_notes_tab
    , p_contacts             => l_contacts_tab
    , p_resp_id              => to_number(fnd_profile.value('CSL_SR_CREATE_RESP'))
    , x_request_id           => l_request_id
    , x_request_number       => l_request_number
    , x_interaction_id       => l_interaction_id
    , x_workflow_process_id  => l_workflow_process_id
    -- CS Uptake 11.5.9 - Assignment Manager
    , x_individual_owner     => x_individual_owner
    , x_individual_type      => x_individual_type
    , x_group_owner          => x_group_owner
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_INSERT:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an updated record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_incident%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  cursor c_ovn
    ( b_incident_id number
    )
  is
    select incident_id
    ,      object_version_number
    from   cs_incidents
    where  incident_id = b_incident_id;

  r_ovn                   c_ovn%rowtype;

  cursor c_last_update_date
     ( b_incident_id NUMBER
	 )
  is
    SELECT LAST_UPDATE_DATE
	from CS_INCIDENTS_ALL_B
	where incident_id = b_incident_id;

  r_last_update_date     c_last_update_date%ROWTYPE;

  cursor c_credit_card
     ( b_incident_id NUMBER
	 )
  is
    SELECT CREDIT_CARD_NUMBER, CREDIT_CARD_TYPE_CODE,
           CREDIT_CARD_EXPIRATION_DATE, CREDIT_CARD_HOLDER_FNAME,
	   CREDIT_CARD_HOLDER_MNAME, CREDIT_CARD_HOLDER_LNAME, CREDIT_CARD_ID
    FROM CS_INCIDENTS_ALL_B
    WHERE incident_id = b_incident_id;

  r_credit_card     c_credit_card%ROWTYPE;


  l_sr_rec                CS_ServiceRequest_PUB.service_request_rec_type;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(240);
  l_notes_tab             CS_ServiceRequest_PUB.notes_table;
  l_contacts_tab          CS_ServiceRequest_PUB.contacts_table;
  l_interaction_id        NUMBER;
  l_ovn                   NUMBER;
  l_user_id               NUMBER;
  l_workflow_id           NUMBER;
  l_resource_id           NUMBER;
  l_profile_value         VARCHAR2(240);
  l_decript_value         VARCHAR2(250);

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Check for Stale data
  l_profile_value := fnd_profile.value('JTM_APPL_CONFLICT_RULE');
  if l_profile_value = 'SERVER_WINS' AND
  ASG_DEFER.IS_DEFERRED(p_record.clid$$cs, p_record.tranid$$,g_object_name, p_record.seqno$$) <> FND_API.G_TRUE  then
    open c_last_update_date(b_incident_id => p_record.incident_id);
    fetch c_last_update_date into r_last_update_date;
    if c_last_update_date%found then
      if r_last_update_date.last_update_date <> p_record.last_update_date then
        close c_last_update_date;
	IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_record.incident_id
          , v_object_name => g_object_name
          , v_message     => 'Record is stale data'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        fnd_message.set_name
          ( 'JTM'
          , 'JTM_STALE_DATA'
          );
        fnd_msg_pub.add;

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_record.incident_id
          , v_object_name => g_object_name
          , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
      end if;
    else
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.incident_id
        , v_object_name => g_object_name
        , v_message     => 'No record found in Apps Database.'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    end if;
    close c_last_update_date;
  end if;

  -- Initialization
  CS_ServiceRequest_PUB.INITIALIZE_REC
    ( p_sr_record => l_sr_rec
    );

  -- Lookup the user_id
  l_user_id := JTM_HOOK_UTIL_PKG.Get_User_Id( p_record.CLID$$CS );

  -- Retrieve the required object_version_number.
  open c_ovn
     ( b_incident_id => p_record.incident_id
     );
  fetch c_ovn
  into r_ovn;
  if c_ovn%found
  then
    l_ovn := r_ovn.object_version_number;
  else
    -- Let the API complain.
    --l_ovn := FND_API.G_MISS_NUM;
    -- FND_API.G_MISS_NUM is obsoleted. against GSCC standard
    l_ovn := -1;
  end if;
  close c_ovn;

  -- instantiate the sr record
  l_sr_rec.CALLER_TYPE         := p_record.CALLER_TYPE;
  l_sr_rec.SUMMARY             := p_record.SUMMARY;
  l_sr_rec.CUSTOMER_ID         := p_record.CUSTOMER_ID;
  l_sr_rec.INSTALL_SITE_ID     := NVL(p_record.INSTALL_SITE_ID, p_record.INSTALL_SITE_USE_ID);
  l_sr_rec.INSTALL_SITE_USE_ID := l_sr_rec.INSTALL_SITE_ID;
  l_sr_rec.CUSTOMER_PRODUCT_ID := p_record.CUSTOMER_PRODUCT_ID;
  l_sr_rec.INVENTORY_ITEM_ID   := p_record.INVENTORY_ITEM_ID;
  l_sr_rec.inventory_org_id    := p_record.inv_organization_id ;
  l_sr_rec.PROBLEM_CODE        := p_record.PROBLEM_CODE;
  l_sr_rec.RESOLUTION_CODE     := p_record.RESOLUTION_CODE;
/* Update of contract line must be removed see bug 2610677
l_sr_rec.CONTRACT_SERVICE_ID := p_record.CONTRACT_SERVICE_ID; */
  l_sr_rec.INV_ITEM_REVISION   := p_record.INV_ITEM_REVISION;
  l_sr_rec.CUST_PO_NUMBER      := p_record.CUSTOMER_PO_NUMBER;
  l_sr_rec.request_attribute_1  := p_record.INCIDENT_ATTRIBUTE_1;
  l_sr_rec.request_attribute_2  := p_record.INCIDENT_ATTRIBUTE_2;
  l_sr_rec.request_attribute_3  := p_record.INCIDENT_ATTRIBUTE_3;
  l_sr_rec.request_attribute_4  := p_record.INCIDENT_ATTRIBUTE_4;
  l_sr_rec.request_attribute_5  := p_record.INCIDENT_ATTRIBUTE_5;
  l_sr_rec.request_attribute_6  := p_record.INCIDENT_ATTRIBUTE_6;
  l_sr_rec.request_attribute_7  := p_record.INCIDENT_ATTRIBUTE_7;
  l_sr_rec.request_attribute_8  := p_record.INCIDENT_ATTRIBUTE_8;
  l_sr_rec.request_attribute_9  := p_record.INCIDENT_ATTRIBUTE_9;
  l_sr_rec.request_attribute_10 := p_record.INCIDENT_ATTRIBUTE_10;
  l_sr_rec.request_attribute_11 := p_record.INCIDENT_ATTRIBUTE_11;
  l_sr_rec.request_attribute_12 := p_record.INCIDENT_ATTRIBUTE_12;
  l_sr_rec.request_attribute_13 := p_record.INCIDENT_ATTRIBUTE_13;
  l_sr_rec.request_attribute_14 := p_record.INCIDENT_ATTRIBUTE_14;
  l_sr_rec.request_attribute_15 := p_record.INCIDENT_ATTRIBUTE_15;
  l_sr_rec.request_context      := p_record.INCIDENT_CONTEXT;

  --ER 3949138
  l_sr_rec.external_attribute_1   := p_record.EXTERNAL_ATTRIBUTE_1;
  l_sr_rec.external_attribute_2   := p_record.EXTERNAL_ATTRIBUTE_2;
  l_sr_rec.external_attribute_3   := p_record.EXTERNAL_ATTRIBUTE_3;
  l_sr_rec.external_attribute_4   := p_record.EXTERNAL_ATTRIBUTE_4;
  l_sr_rec.external_attribute_5   := p_record.EXTERNAL_ATTRIBUTE_5;
  l_sr_rec.external_attribute_6   := p_record.EXTERNAL_ATTRIBUTE_6;
  l_sr_rec.external_attribute_7   := p_record.EXTERNAL_ATTRIBUTE_7;
  l_sr_rec.external_attribute_8   := p_record.EXTERNAL_ATTRIBUTE_8;
  l_sr_rec.external_attribute_9   := p_record.EXTERNAL_ATTRIBUTE_9;
  l_sr_rec.external_attribute_10  := p_record.EXTERNAL_ATTRIBUTE_10;
  l_sr_rec.external_attribute_11  := p_record.EXTERNAL_ATTRIBUTE_11;
  l_sr_rec.external_attribute_12  := p_record.EXTERNAL_ATTRIBUTE_12;
  l_sr_rec.external_attribute_13  := p_record.EXTERNAL_ATTRIBUTE_13;
  l_sr_rec.external_attribute_14  := p_record.EXTERNAL_ATTRIBUTE_14;
  l_sr_rec.external_attribute_15  := p_record.EXTERNAL_ATTRIBUTE_15;
  l_sr_rec.external_context       := p_record.EXTERNAL_CONTEXT;

  /* 11.5.10 incident address changes - 3430663 */
  l_sr_rec.incident_location_id  := p_record.incident_location_id;
  l_sr_rec.incident_address  := p_record.incident_address;
  l_sr_rec.incident_city  := p_record.incident_city;
  l_sr_rec.incident_state  := p_record.incident_state;
  l_sr_rec.incident_country  := p_record.incident_country;
  l_sr_rec.incident_province  := p_record.incident_province;
  l_sr_rec.incident_postal_code  := p_record.incident_postal_code;
  l_sr_rec.incident_county  := p_record.incident_county;
  l_sr_rec.incident_location_type  := p_record.incident_location_type;

  -- See if Credit Card profile is set?
  --Bug 4496299
  /*
  l_profile_value := fnd_profile.value('JTM_CREDIT_CARD_ENABLED');
  IF l_profile_value = 'Y' THEN
    IF p_record.CREDIT_CARD_NUMBER IS NOT NULL THEN
      open c_credit_card(b_incident_id => p_record.incident_id);
      fetch c_credit_card into r_credit_card;
      IF c_credit_card%found AND (
        NVL(r_credit_card.CREDIT_CARD_NUMBER,FND_API.G_MISS_CHAR)      <> NVL(p_record.CREDIT_CARD_NUMBER,FND_API.G_MISS_CHAR) OR
        NVL(r_credit_card.CREDIT_CARD_TYPE_CODE,FND_API.G_MISS_CHAR)   <> NVL(p_record.CREDIT_CARD_TYPE_CODE,FND_API.G_MISS_CHAR) OR
        NVL(r_credit_card.CREDIT_CARD_EXPIRATION_DATE,FND_API.G_MISS_DATE) <> NVL(p_record.CREDIT_CARD_EXPIRATION_DATE,FND_API.G_MISS_DATE) OR
        NVL(r_credit_card.CREDIT_CARD_HOLDER_FNAME,FND_API.G_MISS_CHAR)    <> NVL(p_record.CREDIT_CARD_HOLDER_FNAME,FND_API.G_MISS_CHAR) OR
        NVL(r_credit_card.CREDIT_CARD_HOLDER_MNAME,FND_API.G_MISS_CHAR)    <> NVL(p_record.CREDIT_CARD_HOLDER_MNAME,FND_API.G_MISS_CHAR) OR
        NVL(r_credit_card.CREDIT_CARD_HOLDER_LNAME,FND_API.G_MISS_CHAR)    <> NVL(p_record.CREDIT_CARD_HOLDER_LNAME,FND_API.G_MISS_CHAR) OR
        NVL(r_credit_card.CREDIT_CARD_ID,FND_API.G_MISS_NUM)              <> NVL(p_record.CREDIT_CARD_ID,FND_API.G_MISS_NUM))
      THEN
        l_decript_value := CS_SERVICEREQUEST_PUB.CC_DECODE(p_record.CREDIT_CARD_NUMBER);
        l_sr_rec.cc_number          := l_decript_value;
        l_sr_rec.cc_type_code       := p_record.CREDIT_CARD_TYPE_CODE;
        l_sr_rec.cc_expiration_date := p_record.CREDIT_CARD_EXPIRATION_DATE;
        l_sr_rec.cc_first_name      := p_record.CREDIT_CARD_HOLDER_FNAME;
        l_sr_rec.cc_middle_name     := p_record.CREDIT_CARD_HOLDER_MNAME;
        l_sr_rec.cc_last_name       := p_record.CREDIT_CARD_HOLDER_LNAME;
        l_sr_rec.cc_id              := p_record.CREDIT_CARD_ID;
      END IF;
    END IF;
  END IF;
  */

  -- CS 11.5.9 Change New column
  l_sr_rec.last_update_program_code := 'CSL_LAPTOP';


  -- Finally the update itself.
  -- Api Modified for CS 11.5.9 Uptake Version changed to 3.0
  CS_ServiceRequest_PUB.Update_ServiceRequest
    ( p_api_version           => 3.0
    , p_init_msg_list         => FND_API.G_TRUE
    , p_commit                => FND_API.G_TRUE
    , x_return_status         => x_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    , p_request_id            => p_record.incident_id
    , p_object_version_number => l_ovn
    , p_last_updated_by       => l_user_id
    , p_last_update_date      => sysdate
    , p_service_request_rec   => l_sr_rec
    , p_notes                 => l_notes_tab
    , p_contacts              => l_contacts_tab
    , p_resp_id              => to_number(fnd_profile.value('CSL_SR_CREATE_RESP'))
    , x_workflow_process_id   => l_workflow_id
    , x_interaction_id        => l_interaction_id
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
       jtm_message_log_pkg.Log_Msg
       ( v_object_id   => p_record.incident_id
       , v_object_name => g_object_name
       , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
       , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    RETURN;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_UPDATE:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_incident%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  l_rc                    BOOLEAN;
  l_access_id             NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.incident_id
      , v_object_name => g_object_name
      , v_message     => 'Processing INCIDENT_ID = ' || p_record.incident_id || fnd_global.local_chr(10) ||
       'DMLTYPE = ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSIF p_record.dmltype$$='U' THEN
    -- Process update
    APPLY_UPDATE
      (
       p_record,
       p_error_msg,
       x_return_status
     );
  ELSIF p_record.dmltype$$='D' THEN
    -- Process delete; not supported for this entity
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.incident_id
        , v_object_name => g_object_name
        , v_message     => 'Delete is not supported for this entity'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.incident_id
      , v_object_name => g_object_name
      , v_message     => 'Invalid DML type: ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_record.dmltype$$ = 'U' AND x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_access_id := jtm_hook_util_pkg.get_acc_id(
                                    p_acc_table_name => 'CSL_CS_INCIDENTS_ALL_ACC',
                                    p_resource_id    => JTM_HOOK_UTIL_PKG.get_resource_id( p_record.clid$$cs ),
                                    p_pk1_name       => 'INCIDENT_ID',
                                    p_pk1_num_value  => p_record.INCIDENT_ID
                                               );
    l_rc := CSL_SERVICEL_WRAPPER_PKG.AUTONOMOUS_MARK_DIRTY(
                                    P_PUB_ITEM     => g_pub_name,
                                    P_ACCESSID     => l_access_id,
                                    P_RESOURCEID   => JTM_HOOK_UTIL_PKG.get_resource_id( p_record.clid$$cs ),
                                    P_DML          => 'U',
                                    P_TIMESTAMP    => sysdate
                                                          );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_RECORD:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.incident_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication item CSL_CS_INCIDENTS_ALL_VL
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** loop through CSL_CS_INCIDENTS_ALL_VL records in inqueue ***/
  FOR r_incident IN c_incident( p_user_name, p_tranid) LOOP

    /*** apply record ***/
    APPLY_RECORD
      (
        r_incident
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_incident.incident_id
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_incident.seqno$$,
          r_incident.incident_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );
      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_incident.incident_id
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
      END IF;


      FOR r_contacts IN c_contact( r_incident.incident_id, p_tranid, p_user_name ) LOOP
        /* Delete matching contact record(s) */
        CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
          (
            p_user_name,
            p_tranid,
            r_contacts.seqno$$,
            r_contacts.SR_CONTACT_POINT_ID,
            g_object_name,
            'CSL_CS_HZ_SR_CONTACT_PTS',
            l_error_msg,
            l_process_status
          );
          /*** was delete successful? ***/
          IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
              jtm_message_log_pkg.Log_Msg
               ( v_object_id   => r_contacts.SR_CONTACT_POINT_ID
               , v_object_name => g_object_name
               , v_message     => 'Deleting from inqueue failed'
               , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
            END IF;
         END IF;
      END LOOP;
    ELSIF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not applied successfully -> defer and reject records ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_incident.incident_id
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting records'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_incident.seqno$$
       , r_incident.incident_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_incident.dmltype$$
       );

      FOR r_contacts IN c_contact( r_incident.incident_id, p_tranid, p_user_name ) LOOP
        /* Defer matching contact record(s) */
        CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
          (
            p_user_name,
            p_tranid,
            r_contacts.seqno$$,
            r_contacts.SR_CONTACT_POINT_ID,
            g_object_name,
            'CSL_CS_HZ_SR_CONTACT_PTS',
	    l_error_msg,
            l_process_status,
            'I'
          );
      END LOOP;
    END IF;

  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_CLIENT_CHANGES:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSL_SERVICE_REQUESTS_PKG;

/
