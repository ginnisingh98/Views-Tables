--------------------------------------------------------
--  DDL for Package Body CSM_SERVICE_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SERVICE_REQUESTS_PKG" AS
/* $Header: csmusrb.pls 120.16.12010000.11 2010/06/08 17:40:57 trajasek ship $ */

error EXCEPTION;


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_SERVICE_REQUESTS_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_INCIDENTS_ALL';
g_debug_level           NUMBER; -- debug level

/* Select all inq records */
CURSOR c_incident( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSM_INCIDENTS_ALL_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

/* Select all contact records for incident from inq table */
CURSOR c_contact( b_incident_id NUMBER, b_tranid NUMBER, b_user_name VARCHAR2 ) IS
  SELECT *
  FROM  CSF_M_SR_CONTACTS_INQ
  WHERE INCIDENT_ID = b_incident_id
  AND   TRANID$$ = b_tranid
  AND   clid$$cs = b_user_name;
--Since from r12 the app_id and responsiblity id is available in asg_user table the cursor is mordied to take the values
--from  asg_user table
CURSOR 	c_csm_appl(l_userid NUMBER)
IS
SELECT 	APP_ID
FROM 	asg_user
WHERE 	user_id = l_userid;

CURSOR 	c_csm_resp(l_userid NUMBER)
is
SELECT 	RESPONSIBILITY_ID
FROM 	asg_user
WHERE 	user_id = l_userid;


CURSOR c_validate_item_org(p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER)
IS
SELECT 	1
FROM 	mtl_system_items_b
WHERE 	inventory_item_id = p_inventory_item_id
AND 	organization_id = p_organization_id;

/* Cursor to select party Type */
CURSOR c_party  ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE )
IS
SELECT PARTY_TYPE
FROM   HZ_PARTIES
WHERE  party_id = b_customer_id;
/* Cursor for Free Form Instance */
CURSOR  C_FREE_FORM_IB_INFO (c_instance_number IN VARCHAR2)
IS
SELECT  INSTANCE_ID, INVENTORY_ITEM_ID, LAST_VLD_ORGANIZATION_ID,
        OWNER_PARTY_ID, INSTALL_LOCATION_ID, OWNER_PARTY_ACCOUNT_ID,
        SERIAL_NUMBER,  INVENTORY_REVISION,
        DECODE(INSTALL_LOCATION_TYPE_CODE,'HZ_PARTY_SITES','HZ_PARTY_SITE','HZ_LOCATIONS','HZ_LOCATION', NULL) AS INSTALL_LOCATION_TYPE_CODE,
        LOCATION_ID, DECODE(LOCATION_TYPE_CODE,'HZ_PARTY_SITES','HZ_PARTY_SITE','HZ_LOCATIONS','HZ_LOCATION', NULL) AS LOCATION_TYPE_CODE
FROM    CSI_ITEM_INSTANCES
WHERE   INSTANCE_NUMBER  = c_instance_number;

/* Cursor for Free Form Serial */
CURSOR  C_FREE_FORM_SER_INFO (c_serial_number IN VARCHAR2)
IS
SELECT  INSTANCE_ID, INVENTORY_ITEM_ID, LAST_VLD_ORGANIZATION_ID,
        OWNER_PARTY_ID, INSTALL_LOCATION_ID, OWNER_PARTY_ACCOUNT_ID,
        SERIAL_NUMBER,  INVENTORY_REVISION,
        DECODE(INSTALL_LOCATION_TYPE_CODE,'HZ_PARTY_SITES','HZ_PARTY_SITE','HZ_LOCATIONS','HZ_LOCATION', NULL) AS INSTALL_LOCATION_TYPE_CODE,
        LOCATION_ID, DECODE(LOCATION_TYPE_CODE,'HZ_PARTY_SITES','HZ_PARTY_SITE','HZ_LOCATIONS','HZ_LOCATION', NULL) AS LOCATION_TYPE_CODE
FROM    CSI_ITEM_INSTANCES
WHERE   SERIAL_NUMBER  = c_serial_number;

  /*   Cursor to get the customer account id */
CURSOR c_customer_account ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE)
IS
SELECT custa.cust_account_id
FROM   hz_cust_accounts custa
WHERE  custa.status = 'A'
AND    custa.party_id = b_customer_id;

/* Cursor to select object_version_number */
CURSOR C_OVN( B_INCIDENT_ID NUMBER)
  IS
    SELECT INCIDENT_ID
    ,      OBJECT_VERSION_NUMBER
    FROM   CS_INCIDENTS
    WHERE  INCIDENT_ID = B_INCIDENT_ID;
 R_OVN     C_OVN%ROWTYPE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_incident%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS

  /* Bug 3917132
     Cursor to get the Bill to Address */
  CURSOR c_bill_to_site_id( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE)
  IS
  SELECT use.party_site_use_id
  FROM   hz_party_sites site, hz_party_site_uses use
  WHERE  site.party_site_id = use.party_site_id
  AND site.status= 'A'
  AND use.site_use_type= 'BILL_TO'
  AND use.primary_per_type = 'Y'
  AND use.status = 'A'
  AND site.party_id = b_customer_id
  AND trunc(SYSDATE) BETWEEN TRUNC (NVL(use.begin_date, SYSDATE))
  AND (NVL(use.end_date, SYSDATE));

  /* Bug 3917132
     Cursor to get the Ship to Address */
  CURSOR c_ship_to_site_id ( b_customer_id CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE)
  IS
  SELECT use.party_site_use_id
  FROM   hz_party_sites site, hz_party_site_uses use

  WHERE  site.party_site_id = use.party_site_id
  AND   site.status= 'A'
  AND   use.site_use_type= 'SHIP_TO'
  AND   use.primary_per_type = 'Y'
  AND   use.status = 'A'
  AND   site.party_id = b_customer_id
  AND   trunc(SYSDATE) BETWEEN TRUNC (NVL(use.begin_date, SYSDATE))
  AND   (NVL(use.end_date, SYSDATE));

--115.10
  CURSOR l_install_site_csr (p_customer_product_id IN number)
  IS
  SELECT install_location_id
  FROM 	 csi_item_instances
  WHERE  instance_id = p_customer_product_id
  AND 	 install_location_type_code IN ('HZ_PARTY_SITES','HZ_LOCATIONS');

--Variable Declarations
  l_install_location_id   csi_item_instances.install_location_id%TYPE;
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
  x_individual_owner      NUMBER;
  x_individual_type       VARCHAR2(240);
  x_group_owner           NUMBER;
  l_profile_value         VARCHAR2(240);
  l_resp_id               NUMBER;
  l_csm_appl_id fnd_application.application_id%TYPE;
  l_customer_account_id   NUMBER;
  l_bill_to_site_use_id   NUMBER;
  l_ship_to_site_use_id   NUMBER;
  l_dummy                 NUMBER;
  l_org_id                NUMBER;
  l_created_by            NUMBER;
  l_party_type            VARCHAR2(30);
  l_responsibility_id     NUMBER;
  l_sr_out_rec            CS_ServiceRequest_PUB.sr_create_out_rec_type;
  l_auto_generate_task    VARCHAR2(255);
  l_freeform              VARCHAR2(255);
  l_free_form_rec         C_FREE_FORM_IB_INFO%ROWTYPE;
  l_free_form_ser_rec     C_FREE_FORM_SER_INFO%ROWTYPE;
  l_CS_INV_ORG_ID         NUMBER;
BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_INSERT for incident_id ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);

  l_user_id     := JTM_HOOK_UTIL_PKG.Get_User_Id( p_record.CLID$$CS );
  l_created_by  := p_record.CREATED_BY;
  l_resp_id     := TO_NUMBER(fnd_profile.value('CSM_SR_CREATE_RESP'));

  --get responsiblity from asg_user
  OPEN  c_csm_resp(l_user_id);
  FETCH c_csm_resp INTO l_responsibility_id;
  CLOSE c_csm_resp;

  -- get csm application id
  OPEN  c_csm_appl(l_user_id);
  FETCH c_csm_appl INTO l_csm_appl_id;
  CLOSE c_csm_appl;

  IF l_resp_id IS NULL THEN
      l_resp_id := l_responsibility_id;
  END IF;
  --get all Profile Values
  --Get the value for Free Form IB profile
  l_freeform := fnd_profile.value_specific('CSM_ALLOW_FREE_FORM_IB'
                                          , p_record.created_by
                                          , l_responsibility_id
                                          , l_csm_appl_id);
  l_auto_generate_task := fnd_profile.value_specific('CS_SR_AUTO_TASK_CREATE'
                                          , p_record.created_by
                                          , l_responsibility_id
                                          , l_csm_appl_id);

  l_CS_INV_ORG_ID     := fnd_profile.value_specific('CS_INV_VALIDATION_ORG'
                                          , p_record.created_by
                                          , l_responsibility_id
                                          , l_csm_appl_id);

  l_sr_rec.time_zone_id := TO_NUMBER(FND_PROFILE.VALUE_SPECIFIC(NAME => 'CLIENT_TIMEZONE_ID',
                                    USER_ID           => p_record.created_by ,
                                    RESPONSIBILITY_ID => l_responsibility_id ,
                                    APPLICATION_ID    => l_csm_appl_id ));

  IF   l_freeform IS NULL THEN
    l_freeform := 'N';
  END IF;

  IF   l_auto_generate_task IS NULL OR l_auto_generate_task ='NONE' THEN
    l_auto_generate_task := 'N';
  ELSE
    l_auto_generate_task := 'Y';
  END IF;

   -- Initialization
  CS_ServiceRequest_PUB.INITIALIZE_REC( p_sr_record => l_sr_rec );


  --SR ATTRIBUTES
  l_sr_rec.SUMMARY              := p_record.SUMMARY;
  l_sr_rec.request_date	        := p_record.incident_date ;
  l_sr_rec.severity_id		      := p_record.incident_severity_id ;
  l_sr_rec.status_id 		        := p_record.incident_status_id ;
  l_sr_rec.type_id 		          := p_record.incident_type_id ;
  l_sr_rec.urgency_id 		      := p_record.incident_urgency_id ;
  l_sr_rec.CUSTOMER_ID         	:= p_record.CUSTOMER_ID;
  l_sr_rec.sr_creation_channel  := 'MOBILE';
  l_sr_rec.owner_id             := NULL;
  l_sr_rec.owner_group_id       := NULL;
  l_sr_rec.PROBLEM_CODE         := p_record.PROBLEM_CODE;
  l_sr_rec.RESOLUTION_CODE      := p_record.RESOLUTION_CODE;
  l_sr_rec.CUST_PO_NUMBER       := p_record.CUSTOMER_PO_NUMBER;
  l_sr_rec.RESOLUTION_SUMMARY   := p_record.RESOLUTION_SUMMARY;
  l_sr_rec.creation_program_code:= 'CSM_UPSYNC_WRAPPER';
  l_sr_rec.OWNER_GROUP_ID        := p_record.OWNER_GROUP_ID;
  l_sr_rec.OWNER_ID              := p_record.INCIDENT_OWNER_ID;
  --SR DFF ATTRIBUTES
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

  IF l_freeform = 'Y' AND (p_record.FREE_FORM_INSTANCE IS NOT NULL OR p_record.FREE_FORM_SERIAL IS NOT NULL)THEN

    IF p_record.FREE_FORM_INSTANCE IS NOT NULL THEN
      --Fetch the Instance Details and fill the SR record
      OPEN  C_FREE_FORM_IB_INFO (p_record.FREE_FORM_INSTANCE);
      FETCH C_FREE_FORM_IB_INFO INTO l_free_form_rec;
      IF C_FREE_FORM_IB_INFO%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        p_error_msg     := 'The Instance Number :'  || p_record.FREE_FORM_INSTANCE||
        ' used for the creation of the SR :' || p_record.INCIDENT_NUMBER  || 'is INVALID.';
        CLOSE   C_FREE_FORM_IB_INFO;
        RETURN;
      END IF;
      CLOSE   C_FREE_FORM_IB_INFO;

     --Same as SR design in forms
      IF l_free_form_rec.LOCATION_TYPE_CODE ='HZ_LOCATION' THEN
        l_sr_rec.INSTALL_SITE_ID       := l_free_form_rec.INSTALL_LOCATION_ID;
      END IF;

      l_sr_rec.CUSTOMER_ID           := l_free_form_rec.OWNER_PARTY_ID;
      l_sr_rec.CUSTOMER_PRODUCT_ID   := l_free_form_rec.INSTANCE_ID;
      l_sr_rec.INVENTORY_ITEM_ID     := l_free_form_rec.INVENTORY_ITEM_ID;
      l_sr_rec.current_serial_number := l_free_form_rec.SERIAL_NUMBER;
      l_sr_rec.inventory_org_id      := NVL(l_free_form_rec.LAST_VLD_ORGANIZATION_ID, TO_NUMBER(l_CS_INV_ORG_ID)) ;
      l_sr_rec.incident_location_id  := l_free_form_rec.LOCATION_ID;
      l_sr_rec.incident_location_type:= nvl(l_free_form_rec.LOCATION_TYPE_CODE, 'HZ_PARTY_SITE');
      l_sr_rec.account_id            := l_free_form_rec.OWNER_PARTY_ACCOUNT_ID;
      l_sr_rec.INV_ITEM_REVISION     := l_free_form_rec.INVENTORY_REVISION;
    END IF;

    IF  p_record.FREE_FORM_SERIAL IS NOT NULL THEN
        --Fetch the Instance Details and fill the SR record
      OPEN  C_FREE_FORM_SER_INFO (p_record.FREE_FORM_SERIAL);
      FETCH C_FREE_FORM_SER_INFO INTO l_free_form_ser_rec;
      IF C_FREE_FORM_SER_INFO%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        p_error_msg     := 'The Serial Number :'  || p_record.FREE_FORM_SERIAL||
        ' used for the creation of the SR :' || p_record.INCIDENT_NUMBER  || 'is INVALID.';
        CLOSE   C_FREE_FORM_SER_INFO;
        RETURN;
      END IF;
      CLOSE   C_FREE_FORM_SER_INFO;

     --Same as SR design in forms
      IF l_free_form_ser_rec.LOCATION_TYPE_CODE ='HZ_LOCATION' THEN
        l_sr_rec.INSTALL_SITE_ID       := l_free_form_ser_rec.INSTALL_LOCATION_ID;
      END IF;

      l_sr_rec.CUSTOMER_ID           := l_free_form_ser_rec.OWNER_PARTY_ID;
      l_sr_rec.CUSTOMER_PRODUCT_ID   := l_free_form_ser_rec.INSTANCE_ID;
      l_sr_rec.INVENTORY_ITEM_ID     := l_free_form_ser_rec.INVENTORY_ITEM_ID;
      l_sr_rec.current_serial_number := l_free_form_ser_rec.SERIAL_NUMBER;
      l_sr_rec.inventory_org_id      := NVL(l_free_form_ser_rec.LAST_VLD_ORGANIZATION_ID, TO_NUMBER(l_CS_INV_ORG_ID)) ;
      l_sr_rec.incident_location_id  := l_free_form_ser_rec.LOCATION_ID;
      l_sr_rec.incident_location_type:= nvl(l_free_form_ser_rec.LOCATION_TYPE_CODE, 'HZ_PARTY_SITE');
      l_sr_rec.account_id            := l_free_form_ser_rec.OWNER_PARTY_ACCOUNT_ID;
      l_sr_rec.INV_ITEM_REVISION     := l_free_form_ser_rec.INVENTORY_REVISION;
    END IF;
  ELSE
    l_sr_rec.CUSTOMER_ID         := p_record.CUSTOMER_ID;
      --get location if missing
    IF p_record.CUSTOMER_PRODUCT_ID IS NOT NULL THEN
      OPEN  l_install_site_csr(p_record.customer_product_id);
      FETCH l_install_site_csr INTO l_install_location_id;
      CLOSE l_install_site_csr;
      IF	p_record.incident_location_type = 'HZ_PARTY_SITE' THEN
        l_sr_rec.INSTALL_SITE_ID 	:= l_install_location_id;
      ELSE
        l_sr_rec.INSTALL_SITE_ID 	:= NULL;
      END IF;
    ELSE
      l_sr_rec.INSTALL_SITE_ID 	:= NULL;
      l_sr_rec.INSTALL_SITE_USE_ID := NULL;
    END IF;

    l_sr_rec.CUSTOMER_PRODUCT_ID := p_record.CUSTOMER_PRODUCT_ID;
    l_sr_rec.INVENTORY_ITEM_ID   := p_record.INVENTORY_ITEM_ID;
    l_sr_rec.current_serial_number := p_record.current_serial_number ;
    l_sr_rec.INV_ITEM_REVISION   := p_record.INV_ITEM_REVISION;
    l_sr_rec.inventory_org_id      := NVL(p_record.inv_organization_id, TO_NUMBER(l_CS_INV_ORG_ID)) ;
    --validate only if inventory item is present
    IF l_sr_rec.INVENTORY_ITEM_ID IS NOT NULL THEN
      --Check if the item sent by client is valid
      OPEN  c_validate_item_org(p_inventory_item_id => l_sr_rec.INVENTORY_ITEM_ID,
                               p_organization_id =>l_sr_rec.inventory_org_id);
      FETCH c_validate_item_org INTO l_dummy;
      IF c_validate_item_org%NOTFOUND THEN
         SELECT master_organization_id
         INTO   l_org_id
         FROM   mtl_parameters
         WHERE  organization_id = l_sr_rec.inventory_org_id;
         l_sr_rec.inventory_org_id := l_org_id;
      END IF;
      CLOSE c_validate_item_org;
    END IF;

    l_sr_rec.incident_location_id   := p_record.incident_location_id;
    l_sr_rec.incident_location_type := nvl(p_record.incident_location_type, 'HZ_PARTY_SITE');
    /* Get customer Account id - Just pick the 1st record */
    OPEN  c_customer_account (p_record.CUSTOMER_ID);
    FETCH c_customer_account INTO l_customer_account_id;
    IF c_customer_account%NOTFOUND THEN
       l_customer_account_id := NULL;
    END IF;
    CLOSE c_customer_account;

    l_sr_rec.account_id := l_customer_account_id;

  END IF;

  --get caller type if not send by client
  IF p_record.CALLER_TYPE IS NULL THEN
    --get party type
    OPEN  c_party (l_sr_rec.CUSTOMER_ID);
    FETCH c_party INTO l_party_type;
    CLOSE c_party;
    l_sr_rec.CALLER_TYPE     := l_party_type;
  ELSE
    l_sr_rec.CALLER_TYPE          := p_record.CALLER_TYPE;
  END IF;

  /* Get Bill to Site id */
  OPEN  c_bill_to_site_id ( l_sr_rec.CUSTOMER_ID );
  FETCH c_bill_to_site_id INTO l_bill_to_site_use_id;
  IF c_bill_to_site_id%NOTFOUND THEN
     l_bill_to_site_use_id := NULL;
  END IF;
  CLOSE c_bill_to_site_id ;
  l_sr_rec.bill_to_site_use_id := l_bill_to_site_use_id;
  l_sr_rec.bill_to_party_id    := l_sr_rec.CUSTOMER_ID;

  /* Get Ship to Site id */
  OPEN  c_ship_to_site_id ( l_sr_rec.CUSTOMER_ID );
  FETCH c_ship_to_site_id INTO l_ship_to_site_use_id;
  IF c_ship_to_site_id%NOTFOUND THEN
     l_ship_to_site_use_id := NULL;
  END IF;
  CLOSE c_ship_to_site_id ;
  l_sr_rec.ship_to_site_use_id := l_ship_to_site_use_id;
  l_sr_rec.ship_to_party_id    := l_sr_rec.CUSTOMER_ID;

  /*Get all contacts */
  l_contact_index := 0;
  FOR r_contact IN c_contact( p_record.incident_id, p_record.tranid$$, p_record.clid$$cs ) LOOP
    /*Contact is passed from mobile*/
    l_contact_index := l_contact_index + 1;
    l_contact_rec.SR_CONTACT_POINT_ID := r_contact.SR_CONTACT_POINT_ID;
    l_contact_rec.PARTY_ID            := r_contact.PARTY_ID;
    l_contact_rec.CONTACT_POINT_ID    := r_contact.CONTACT_POINT_ID;
    l_contact_rec.CONTACT_POINT_TYPE  := r_contact.CONTACT_POINT_TYPE;
    l_contact_rec.PRIMARY_FLAG        := r_contact.PRIMARY_FLAG;
    l_contact_rec.CONTACT_TYPE        := r_contact.CONTACT_TYPE;
    l_contacts_tab( l_contact_index ) := l_contact_rec;
  END LOOP;


  CSM_UTIL_PKG.LOG('Before calling CS_ServiceRequest_PUB.Create_ServiceRequest for ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_INSERT',FND_LOG.LEVEL_EVENT);

  /* Calling CS API for actual insert */
  CS_ServiceRequest_PUB.Create_ServiceRequest
    ( p_api_version          => 4.0
    , p_init_msg_list        => FND_API.G_TRUE
    , p_commit               => FND_API.G_TRUE
    , x_return_status        => x_return_status
    , x_msg_count            => l_msg_count
    , x_msg_data             => l_msg_data
    , p_user_id              => l_created_by
    , p_org_id               => p_record.org_id
    , p_request_id           => p_record.incident_id
    , p_request_number       => p_record.incident_number
    , p_service_request_rec  => l_sr_rec
    , p_notes                => l_notes_tab
    , p_contacts             => l_contacts_tab
    , p_resp_id		         => l_resp_id
    , p_default_contract_sla_ind => 'Y'
    , p_auto_generate_tasks      => l_auto_generate_task
    , p_auto_assign 		 => 'Y'
    , x_sr_create_out_rec	 => l_sr_out_rec
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
               || ' ROOT ERROR: CS_ServiceRequest_PUB.Create_ServiceRequest ' || sqlerrm
               || ' for incident_id ' || p_record.incident_id,'CSM_SERVICE_REQUESTS_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR);
   x_return_status := FND_API.G_RET_STS_ERROR;
   return;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_INSERT for incident_id ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT: ' || sqlerrm
               || ' for incident_id ' || p_record.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);

  IF c_customer_account%ISOPEN THEN
    CLOSE c_customer_account;
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an updated record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_incident%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS
/* Cursor to select last_update_date */
  CURSOR c_last_update_date     ( b_incident_id NUMBER	 )
  IS
  SELECT LAST_UPDATE_DATE,
         LAST_UPDATED_BY
	FROM   CS_INCIDENTS_ALL_B
	WHERE  incident_id = b_incident_id;

--115.10
  CURSOR l_install_site_csr (p_customer_product_id IN number)
  IS
  SELECT install_location_id
  FROM   csi_item_instances
  WHERE  instance_id = p_customer_product_id
  AND    install_location_type_code = 'HZ_PARTY_SITES';

  l_install_location_id csi_item_instances.install_location_id%TYPE;
--

  r_last_update_date     c_last_update_date%ROWTYPE;
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
  l_resp_id               NUMBER;
  l_csm_appl_id fnd_application.application_id%TYPE;
  l_dummy                 NUMBER;
  l_org_id                NUMBER;
  l_last_updated_by       NUMBER;
  l_party_type            VARCHAR2(30);
  l_responsibility_id     NUMBER;
  l_freeform              VARCHAR2(255);
  l_free_form_rec         C_FREE_FORM_IB_INFO%ROWTYPE;
  l_free_form_ser_rec     C_FREE_FORM_SER_INFO%ROWTYPE;
  l_CS_INV_ORG_ID         NUMBER;
  l_customer_account_id   NUMBER;
BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE for incident_id ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_PROCEDURE);
  -- Check for Stale data
  l_profile_value := fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE);
  if l_profile_value = 'SERVER_WINS' AND
  ASG_DEFER.IS_DEFERRED(p_record.clid$$cs, p_record.tranid$$,g_pub_name, p_record.seqno$$) <> FND_API.G_TRUE  then
    open c_last_update_date(b_incident_id => p_record.incident_id);
    fetch c_last_update_date into r_last_update_date;
    if c_last_update_date%found then
      if r_last_update_date.last_update_date <> p_record.server_last_update_date and r_last_update_date.last_updated_by <> asg_base.get_user_id(p_record.clid$$cs) then
               close c_last_update_date;
               x_return_status := FND_API.G_RET_STS_ERROR;
               p_error_msg := 'UPWARD SYNC CONFLICT: CLIENT LOST: CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE: Incident_id = '
               || p_record.incident_id;
               csm_util_pkg.log('UPWARD SYNC CONFLICT: CLIENT LOST: CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE: Incident_id = '
               || p_record.incident_id,'CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_ERROR);
               return;
      end if;
    else
      CSM_UTIL_PKG.LOG('No record found in Apps Database for incident_id ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_PROCEDURE);
    end if;
    close c_last_update_date;
  end if;

  -- Initialization
  CS_ServiceRequest_PUB.INITIALIZE_REC
    ( p_sr_record => l_sr_rec
    );

  -- Lookup the user_id
  l_user_id := JTM_HOOK_UTIL_PKG.Get_User_Id( p_record.CLID$$CS );
  l_last_updated_by := p_record.LAST_UPDATED_BY;
  l_resp_id := TO_NUMBER(fnd_profile.value('CSM_SR_CREATE_RESP'));
  --Get Mobile responsibility
  OPEN  c_csm_resp(l_user_id);
  FETCH c_csm_resp INTO l_responsibility_id;
  CLOSE c_csm_resp;
  -- get csm application id
  OPEN c_csm_appl(l_user_id);
  FETCH c_csm_appl INTO l_csm_appl_id;
  CLOSE c_csm_appl;

  IF l_resp_id IS NULL THEN
     l_resp_id := l_responsibility_id;
  END IF;
  --Get all profile Values
  --Get the value for Free Form IB profile
  l_freeform := fnd_profile.value_specific('CSM_ALLOW_FREE_FORM_IB'
                                          , p_record.created_by
                                          , l_responsibility_id
                                          , l_csm_appl_id);

  l_CS_INV_ORG_ID     := fnd_profile.value_specific('CS_INV_VALIDATION_ORG'
                                          , p_record.created_by
                                          , l_responsibility_id
                                          , l_csm_appl_id);

  l_sr_rec.time_zone_id  := TO_NUMBER(FND_PROFILE.VALUE_SPECIFIC(NAME => 'CLIENT_TIMEZONE_ID',
                                        USER_ID           => p_record.created_by ,
                                        RESPONSIBILITY_ID => l_responsibility_id ,
                                        APPLICATION_ID    => l_csm_appl_id ));
  IF   l_freeform IS NULL THEN
    l_freeform := 'N';
  END IF;

  -- Retrieve the required object_version_number.
  OPEN  c_ovn ( b_incident_id => p_record.incident_id );
  FETCH c_ovn  INTO r_ovn;
  IF c_ovn%found THEN
    l_ovn := r_ovn.object_version_number;
  ELSE
    -- Let the API complain.
    l_ovn := FND_API.G_MISS_NUM;
  END IF;
  CLOSE c_ovn;

  -- instantiate the sr record
  --SR ATTRIBUTES
  l_sr_rec.SUMMARY              := p_record.SUMMARY;
  l_sr_rec.severity_id          := p_record.incident_severity_id ;
  l_sr_rec.status_id            := p_record.incident_status_id ;
  l_sr_rec.type_id              := p_record.incident_type_id ;
  l_sr_rec.urgency_id           := p_record.incident_urgency_id ;
  l_sr_rec.CUSTOMER_ID          := p_record.CUSTOMER_ID;
  l_sr_rec.PROBLEM_CODE         := p_record.PROBLEM_CODE;
  l_sr_rec.RESOLUTION_CODE      := p_record.RESOLUTION_CODE;
  l_sr_rec.CUST_PO_NUMBER       := p_record.CUSTOMER_PO_NUMBER;
  l_sr_rec.RESOLUTION_SUMMARY   := p_record.RESOLUTION_SUMMARY;
  l_sr_rec.OWNER_GROUP_ID       := p_record.OWNER_GROUP_ID;
  l_sr_rec.OWNER_ID             := p_record.INCIDENT_OWNER_ID;
  l_sr_rec.last_update_program_code := 'CSM_UPSYNC_WRAPPER';

  IF p_record.OWNER_GROUP_ID IS NOT NULL THEN
         l_sr_rec.group_type := nvl( FND_PROFILE.value('CS_SR_DEFAULT_GROUP_TYPE'), 'RS_GROUP');
  END IF;

  IF l_freeform = 'Y' AND (p_record.FREE_FORM_INSTANCE IS NOT NULL OR p_record.FREE_FORM_SERIAL IS NOT NULL)THEN

    IF p_record.FREE_FORM_INSTANCE IS NOT NULL THEN
      --Fetch the Instance Details and fill the SR record
      OPEN  C_FREE_FORM_IB_INFO (p_record.FREE_FORM_INSTANCE);
      FETCH C_FREE_FORM_IB_INFO INTO l_free_form_rec;
      IF C_FREE_FORM_IB_INFO%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        p_error_msg     := 'The Instance Number :'  || p_record.FREE_FORM_INSTANCE||
        ' used for the creation of the SR :' || p_record.INCIDENT_NUMBER  || 'is INVALID.';
        CLOSE   C_FREE_FORM_IB_INFO;
        RETURN;
      END IF;
      CLOSE   C_FREE_FORM_IB_INFO;

     --Same as SR design in forms
      IF l_free_form_rec.LOCATION_TYPE_CODE ='HZ_LOCATION' THEN
        l_sr_rec.INSTALL_SITE_ID       := l_free_form_rec.INSTALL_LOCATION_ID;
      END IF;

      l_sr_rec.CUSTOMER_ID           := l_free_form_rec.OWNER_PARTY_ID;
      l_sr_rec.CUSTOMER_PRODUCT_ID   := l_free_form_rec.INSTANCE_ID;
      l_sr_rec.INVENTORY_ITEM_ID     := l_free_form_rec.INVENTORY_ITEM_ID;
      l_sr_rec.current_serial_number := l_free_form_rec.SERIAL_NUMBER;
      l_sr_rec.inventory_org_id      := NVL(l_free_form_rec.LAST_VLD_ORGANIZATION_ID, TO_NUMBER(l_CS_INV_ORG_ID)) ;
      l_sr_rec.incident_location_id  := l_free_form_rec.LOCATION_ID;
      l_sr_rec.incident_location_type:= nvl(l_free_form_rec.LOCATION_TYPE_CODE, 'HZ_PARTY_SITE');
      l_sr_rec.account_id            := l_free_form_rec.OWNER_PARTY_ACCOUNT_ID;
      l_sr_rec.INV_ITEM_REVISION     := l_free_form_rec.INVENTORY_REVISION;
    END IF;

    IF  p_record.FREE_FORM_SERIAL IS NOT NULL THEN
        --Fetch the Instance Details and fill the SR record
      OPEN  C_FREE_FORM_SER_INFO (p_record.FREE_FORM_SERIAL);
      FETCH C_FREE_FORM_SER_INFO INTO l_free_form_ser_rec;
      IF C_FREE_FORM_SER_INFO%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        p_error_msg     := 'The Serial Number :'  || p_record.FREE_FORM_SERIAL||
        ' used for the creation of the SR :' || p_record.INCIDENT_NUMBER  || 'is INVALID.';
        RETURN;
        CLOSE   C_FREE_FORM_SER_INFO;
      END IF;
      CLOSE   C_FREE_FORM_SER_INFO;

     --Same as SR design in forms
      IF l_free_form_ser_rec.LOCATION_TYPE_CODE ='HZ_LOCATION' THEN
        l_sr_rec.INSTALL_SITE_ID       := l_free_form_ser_rec.INSTALL_LOCATION_ID;
      END IF;

      l_sr_rec.CUSTOMER_ID           := l_free_form_ser_rec.OWNER_PARTY_ID;
      l_sr_rec.CUSTOMER_PRODUCT_ID   := l_free_form_ser_rec.INSTANCE_ID;
      l_sr_rec.INVENTORY_ITEM_ID     := l_free_form_ser_rec.INVENTORY_ITEM_ID;
      l_sr_rec.current_serial_number := l_free_form_ser_rec.SERIAL_NUMBER;
      l_sr_rec.inventory_org_id      := NVL(l_free_form_ser_rec.LAST_VLD_ORGANIZATION_ID, TO_NUMBER(l_CS_INV_ORG_ID)) ;
      l_sr_rec.incident_location_id  := l_free_form_ser_rec.LOCATION_ID;
      l_sr_rec.incident_location_type:= nvl(l_free_form_ser_rec.LOCATION_TYPE_CODE, 'HZ_PARTY_SITE');
      l_sr_rec.account_id            := l_free_form_ser_rec.OWNER_PARTY_ACCOUNT_ID;
      l_sr_rec.INV_ITEM_REVISION     := l_free_form_ser_rec.INVENTORY_REVISION;
    END IF;
  ELSE
    l_sr_rec.CUSTOMER_ID         := p_record.CUSTOMER_ID;
    IF p_record.CUSTOMER_PRODUCT_ID IS NOT NULL THEN
      OPEN l_install_site_csr(p_record.customer_product_id);
      FETCH l_install_site_csr INTO l_install_location_id;
      CLOSE l_install_site_csr;
      IF	p_record.incident_location_type = 'HZ_PARTY_SITE' THEN
          l_sr_rec.INSTALL_SITE_ID 	:= l_install_location_id;
      ELSE
          l_sr_rec.INSTALL_SITE_ID 	:= NULL;
      END IF;
    ELSE
      l_sr_rec.INSTALL_SITE_ID := NULL;
      l_sr_rec.INSTALL_SITE_USE_ID := NULL;
    END IF;
    l_sr_rec.CUSTOMER_PRODUCT_ID := p_record.CUSTOMER_PRODUCT_ID;
    l_sr_rec.INVENTORY_ITEM_ID   := p_record.INVENTORY_ITEM_ID;
    l_sr_rec.current_serial_number := p_record.current_serial_number ;
    l_sr_rec.inventory_org_id := NVL(p_record.inv_organization_id, TO_NUMBER(l_CS_INV_ORG_ID)) ;
    l_sr_rec.INV_ITEM_REVISION    := p_record.INV_ITEM_REVISION;
        --validate only if inventory item is present
    IF l_sr_rec.INVENTORY_ITEM_ID IS NOT NULL THEN
      -- validate item/org; if invalid get org from master organization
      OPEN c_validate_item_org(p_inventory_item_id => l_sr_rec.INVENTORY_ITEM_ID,
                               p_organization_id =>l_sr_rec.inventory_org_id);
      FETCH c_validate_item_org INTO l_dummy;
      IF c_validate_item_org%NOTFOUND THEN
         SELECT master_organization_id
         INTO l_org_id
         FROM mtl_parameters
         WHERE organization_id = l_sr_rec.inventory_org_id;
         l_sr_rec.inventory_org_id := l_org_id;
      END IF;
      CLOSE c_validate_item_org;
    END IF;
    l_sr_rec.incident_location_id   := p_record.incident_location_id;
    l_sr_rec.incident_location_type := nvl(p_record.incident_location_type, 'HZ_PARTY_SITE');

    /* Get customer Account id - Just pick the 1st record */
    OPEN  c_customer_account (p_record.CUSTOMER_ID);
    FETCH c_customer_account INTO l_customer_account_id;
    IF c_customer_account%NOTFOUND THEN
       l_customer_account_id := NULL;
    END IF;
    CLOSE c_customer_account;
    l_sr_rec.account_id := l_customer_account_id;

  END IF;

  IF p_record.CALLER_TYPE IS NULL THEN
    --get party type
    OPEN  c_party (l_sr_rec.CUSTOMER_ID);
    FETCH c_party INTO l_party_type;
    CLOSE c_party;
    l_sr_rec.CALLER_TYPE     := l_party_type;
  ELSE
    l_sr_rec.CALLER_TYPE     := p_record.CALLER_TYPE;
  END IF;

  --SR DFF Attributes
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

  CSM_UTIL_PKG.LOG('Before calling CS_ServiceRequest_PUB.Update_ServiceRequest for ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_EVENT);

  -- Finally the update itself.
  CS_ServiceRequest_PUB.Update_ServiceRequest
    ( p_api_version           => 3.0
    , p_init_msg_list         => FND_API.G_TRUE
    , p_commit                => FND_API.G_TRUE
    , x_return_status         => x_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    , p_request_id            => p_record.incident_id
    , p_object_version_number => l_ovn
    , p_last_updated_by       => l_last_updated_by
    , p_last_update_date      => sysdate
    , p_service_request_rec   => l_sr_rec
    , p_notes                 => l_notes_tab
    , p_contacts              => l_contacts_tab
    , p_resp_id		          => l_resp_id
    , p_default_contract_sla_ind  => 'Y'
    , x_workflow_process_id   => l_workflow_id
    , x_interaction_id        => l_interaction_id
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_UPDATE:'
               || ' ROOT ERROR: CS_ServiceRequest_PUB.Update_ServiceRequest ' || sqlerrm
               || ' for incident_id ' || p_record.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_ERROR);
   x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE for incident_id ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE: ' || sqlerrm
               || ' for incident_id ' || p_record.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_UPDATE',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_incident%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS
  l_rc                    BOOLEAN;
  l_access_id             NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_RECORD for incident_id ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

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
      CSM_UTIL_PKG.LOG
        ( 'Delete is not supported for this entity'
      || ' for Incident_id ' || p_record.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type
      CSM_UTIL_PKG.LOG
        ( 'Invalid DML type: ' || p_record.dmltype$$ || ' is not supported for this entity'
      || ' for Incident_id ' || p_record.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_RECORD for incident_id ' || p_record.incident_id ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_RECORD: ' || sqlerrm
               || ' for incident_id ' || p_record.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;

/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CSM_INCIDENTS_ALL
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN out nocopy VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);

BEGIN
CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES ',
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through CSM_INCIDENTS_ALL_INQ records in inqueue ***/
  FOR r_incident IN c_incident( p_user_name, p_tranid) LOOP
    SAVEPOINT save_rec ;
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
      CSM_UTIL_PKG.DELETE_RECORD
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
       /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Deleting from inqueue failed, rolling back to savepoint'
      || ' for incident_id ' || r_incident.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
      /*** Yes -> Delete contact recs */
      FOR r_contacts IN c_contact( r_incident.incident_id, p_tranid, p_user_name ) LOOP
        /* Delete matching contact record(s) */
        CSM_UTIL_PKG.DELETE_RECORD
          (
            p_user_name,
            p_tranid,
            r_contacts.seqno$$,
            r_contacts.SR_CONTACT_POINT_ID,
            g_object_name,
            'CSF_M_SR_CONTACTS',
            l_error_msg,
            l_process_status
          );
          /*** was delete successful? ***/
          IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
          /*** no -> rollback ***/
              CSM_UTIL_PKG.LOG
              ( 'Deleting from inqueue failed, rolling back to savepoint'
                || ' for incident_id ' || r_incident.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
              ROLLBACK TO save_rec;
              x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END LOOP;
      END IF;
    ELSIF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not applied successfully -> defer and reject records ***/
      csm_util_pkg.log( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_incident.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
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

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_incident.incident_id ,'CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        /** Yes **/
        FOR r_contacts IN c_contact( r_incident.incident_id, p_tranid, p_user_name ) LOOP
        /* Defer matching contact record(s) */
        CSM_UTIL_PKG.DEFER_RECORD
          (
            p_user_name,
            p_tranid,
            r_contacts.seqno$$,
            r_contacts.SR_CONTACT_POINT_ID,
            g_object_name,
            'CSF_M_SR_CONTACTS',
	        l_error_msg,
            l_process_status
          ,  r_contacts.dmltype$$
          );
        END LOOP;
      END IF ;

    END IF;

  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES',
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_CLIENT_CHANGES: ' || sqlerrm
               ,'CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                     p_tran_id IN NUMBER,
                                     p_sequence IN NUMBER)
RETURN VARCHAR2 IS
l_profile_value VARCHAR2(30) ;
l_user_id NUMBER ;
cursor get_user_id(l_tran_id in number,
                   l_user_name in varchar2,
		   l_sequence in number)
IS
SELECT b.last_updated_by
FROM CS_INCIDENTS_ALL_B b,
     CSM_INCIDENTS_ALL_INQ a
WHERE a.clid$$cs = l_user_name
AND tranid$$ = l_tran_id
AND seqno$$ = l_sequence
AND a.incident_id = b.incident_id ;

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.CONFLICT_RESOLUTION_METHOD for user ' || p_user_name ,'CSM_SERVICE_REQUESTS_PKG.CONFLICT_RESOLUTION_METHOD',FND_LOG.LEVEL_PROCEDURE);
 l_profile_value := fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE);
OPEN get_user_id(p_tran_id, p_user_name, p_sequence) ;
FETCH get_user_id
 INTO l_user_id ;
CLOSE get_user_id ;

  if l_profile_value = 'SERVER_WINS' AND l_user_id <> asg_base.get_user_id(p_user_name) then
      RETURN 'S' ;
  else
      RETURN 'C' ;
  END IF ;

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'C';
END CONFLICT_RESOLUTION_METHOD;

PROCEDURE APPLY_HA_INSERT
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
l_HA_PAYLOAD_ID     NUMBER;
l_COL_NAME_LIST  CSM_VARCHAR_LIST;
l_COL_VALUE_LIST CSM_VARCHAR_LIST;
l_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
l_RETURN_STATUS  VARCHAR2(200);
L_ERROR_MESSAGE  VARCHAR2(2000);
L_AUD_RETURN_STATUS  VARCHAR2(200);
l_AUD_ERROR_MESSAGE  VARCHAR2(2000);
l_sr_rec                CS_ServiceRequest_PUB.service_request_rec_type;
l_contact_rec           CS_ServiceRequest_PUB.contacts_rec;
l_notes_tab             CS_ServiceRequest_PUB.notes_table;
l_contacts_tab          CS_ServiceRequest_PUB.contacts_table;
l_sr_out_rec            CS_ServiceRequest_PUB.sr_create_out_rec_type;
l_variable_assignment  vARCHAR2(2000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(1000);
s_msg_data VARCHAR2(1000);
l_created_by NUMBER;
l_org_id  NUMBER;
l_incident_id NUMBER;
L_Incident_Number Varchar2(240);
L_Contact_Index NUMBER;
l_resp_id  NUMBER := 23675;
l_ovn                   NUMBER;
l_is_onetime_add VARCHAR(1) := 'N';

Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME NOT IN('CS_INCIDENTS_AUDIT_B','CS_INCIDENTS_AUDIT_TL')
ORDER BY HA_PAYLOAD_ID ASC;

--cursor for Audit Insert
Cursor C_Get_Aud_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME IN('CS_INCIDENTS_AUDIT_B','CS_INCIDENTS_AUDIT_TL')
ORDER BY HA_PAYLOAD_ID ASC;

r_Get_Aux_objects C_Get_Aux_objects%ROWTYPE;

l_Aux_Name_List   Csm_Varchar_List;
l_aux_Value_List  Csm_Varchar_List;
L_Hzl_Name_List   Csm_Varchar_List;
L_Hzl_Value_List  Csm_Varchar_List;
L_HZPS_NAME_LIST   CSM_VARCHAR_LIST;
L_HZPS_VALUE_LIST  CSM_VARCHAR_LIST;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;
l_contact_index := 0;
L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
   -- Initialization
  CS_SERVICEREQUEST_PUB.INITIALIZE_REC( P_SR_RECORD => L_SR_REC );

--Process Aux Objects
  For R_Get_Aux_Objects In C_Get_Aux_Objects(P_Ha_Payload_Id)  Loop

    CSM_HA_PROCESS_PKG.Parse_Xml(P_Ha_Payload_Id =>R_Get_Aux_Objects.Ha_Payload_Id,
                        X_Col_Name_List  => l_Aux_Name_List,
                        x_COL_VALUE_LIST => l_Aux_Value_List,
                        X_Con_Name_List  => L_CON_NAME_LIST,
                        x_COn_VALUE_LIST => L_CON_VALUE_LIST,
                        X_Return_Status  => L_Return_Status,
                        X_ERROR_MESSAGE  => L_ERROR_MESSAGE);
    IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN

      IF R_GET_AUX_OBJECTS.OBJECT_NAME = 'CS_INCIDENTS_ALL_TL' THEN
           If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            For I In 1..L_Aux_Name_List.Count-1 Loop
              IF L_AUX_NAME_LIST(I) = 'SUMMARY' THEN
                L_SR_REC.SUMMARY := L_AUX_VALUE_LIST(I);
              ELSIF L_AUX_NAME_LIST(I) = 'RESOLUTION_SUMMARY' THEN
                L_SR_REC.RESOLUTION_SUMMARY := L_AUX_VALUE_LIST(I);
              END IF;

            END LOOP;
           END IF;
       ELSIF R_Get_Aux_Objects.Object_Name = 'CS_HZ_SR_CONTACT_POINTS' Then

          If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
              /*Contact is passed from Payload*/
           l_contact_index := l_contact_index + 1;
           For I In 1..L_Aux_Name_List.Count-1 Loop

              IF l_Aux_Name_List(I) = 'SR_CONTACT_POINT_ID' THEN
                L_Contact_Rec.Sr_Contact_Point_Id := l_Aux_Value_List(I);
              Elsif  l_Aux_Name_List(I) = 'PARTY_ID' Then
                L_Contact_Rec.Party_Id            := l_Aux_Value_List(I);
              Elsif  l_Aux_Name_List(I) = 'CONTACT_POINT_ID' Then
                l_contact_rec.CONTACT_POINT_ID            := l_Aux_Value_List(I);
              Elsif  l_Aux_Name_List(I) = 'CONTACT_POINT_TYPE' Then
                L_Contact_Rec.CONTACT_POINT_TYPE            := l_Aux_Value_List(I);
              Elsif  l_Aux_Name_List(I) = 'PRIMARY_FLAG' Then
                l_contact_rec.PRIMARY_FLAG            := l_Aux_Value_List(I);
              Elsif  l_Aux_Name_List(I) = 'CONTACT_TYPE' Then
                L_Contact_Rec.Contact_Type            := l_Aux_Value_List(I);
              Elsif  l_Aux_Name_List(I) = 'PARTY_ROLE_CODE' Then
                L_Contact_Rec.party_role_code         := l_Aux_Value_List(I);
              Elsif  L_Aux_Name_List(I) = 'START_DATE_ACTIVE' Then
                L_Contact_Rec.start_date_active       := l_Aux_Value_List(I);
              Elsif  l_Aux_Name_List(I) = 'END_DATE_ACTIVE' Then
                L_Contact_Rec.end_date_active          := l_Aux_Value_List(I);
              End If;
            END LOOP;
            --SEt the Contacts record to pass it to SR Api
            L_Contacts_Tab( l_contact_index ) := L_Contact_Rec;
          End If;
      Elsif R_Get_Aux_Objects.Object_Name = 'HZ_LOCATIONS' Then

         l_is_onetime_add := 'Y';
         --Incident location id is set to null to tell the SR api that one time address
         --is getting created.Else it will throw location not found error.
         l_sr_rec.INCIDENT_LOCATION_ID := NULL;

         For I In 1..L_Aux_Name_List.Count-1 Loop
            IF L_Aux_Name_List(I) = 'ADDRESS1' Then
               l_sr_rec.INCIDENT_ADDRESS := l_Aux_Value_List(I);
            ELSIF  L_Aux_Name_List(I) = 'ADDRESS2' THEN
             L_SR_REC.INCIDENT_ADDRESS2 := l_Aux_Value_List(I);
           ELSIF  L_Aux_Name_List(I) = 'ADDRESS3' THEN
             L_SR_REC.INCIDENT_ADDRESS3 := l_Aux_Value_List(I);
            ELSIF  L_Aux_Name_List(I) = 'ADDRESS4' THEN
               L_SR_REC.INCIDENT_ADDRESS4 := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'CITY' Then
               l_sr_rec.INCIDENT_CITY        := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'STATE' Then
               l_sr_rec.INCIDENT_STATE               := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'POSTAL_CODE' Then
              l_sr_rec.INCIDENT_POSTAL_CODE         := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'COUNTY' Then
              l_sr_rec.INCIDENT_COUNTY              := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'PROVINCE' Then
              l_sr_rec.INCIDENT_PROVINCE            := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'COUNTRY' Then
              l_sr_rec.INCIDENT_COUNTRY             := l_Aux_Value_List(I);
            End If;

          END LOOP;

      Elsif R_Get_Aux_Objects.Object_Name = 'HZ_PARTY_SITES' Then
          L_Hzps_Name_List  := l_Aux_Name_List;
          L_HZPS_VALUE_LIST := L_AUX_VALUE_LIST;
         /* Csm_Hz_Location_Pkg.APPLY_HA_CHANGES
            (P_Ha_Payload_Id   => P_Ha_Payload_Id,
             p_Hzl_Name_List   => L_Hzl_Name_List,
             p_Hzl_Value_List  => L_Hzl_Value_List,
             p_Hzps_Name_List  => L_Hzps_Name_List,
             P_HZPS_VALUE_LIST => L_HZPS_VALUE_LIST,
             p_dml_type        => R_Get_Aux_Objects.dml_type,
             X_Return_Status   => L_Return_Status,
             X_Error_Message   => L_Error_Message
           );*/
      END IF;
    END IF; --if parsing is a success

    If L_Aux_Name_List.Count > 0 Then
      L_Aux_Name_List.DELETE;
    End If;
    If L_Aux_Value_List.Count > 0 Then
      L_Aux_Value_List.Delete;
    End If;
  END LOOP;
  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
      X_Return_Status := L_Return_Status;
      X_Error_Message := L_Error_Message;
      Return;
  END IF;

---Create SR
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  l_COL_VALUE_LIST(i) IS NOT NULL THEN

      IF l_COL_NAME_LIST(i) = 'INCIDENT_STATUS_ID' THEN
        l_sr_rec.status_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_TYPE_ID' THEN
        l_sr_rec.type_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_URGENCY_ID' THEN
        l_sr_rec.urgency_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_SEVERITY_ID' THEN
        l_sr_rec.severity_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_OWNER_ID' THEN
        l_sr_rec.owner_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CUSTOMER_ID' THEN
        l_sr_rec.customer_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'BILL_TO_SITE_USE_ID' THEN
        l_sr_rec.bill_to_site_use_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SHIP_TO_SITE_USE_ID' THEN
        l_sr_rec.ship_to_site_use_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        l_created_by := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ORG_ID' THEN
        l_org_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_ID' THEN
        l_incident_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_NUMBER' THEN
       l_incident_number := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_DATE' THEN
       l_sr_rec.request_date := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CALLER_TYPE' THEN
       l_sr_rec.CALLER_TYPE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'PUBLISH_FLAG' THEN
       l_sr_rec.PUBLISH_FLAG := NULL; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RESOURCE_TYPE' THEN
       l_sr_rec.RESOURCE_TYPE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACCOUNT_ID' THEN
       l_sr_rec.ACCOUNT_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OWNER_GROUP_ID' THEN
       l_sr_rec.OWNER_GROUP_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OBLIGATION_DATE' THEN
       l_sr_rec.OBLIGATION_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OBJECT_VERSION_NUMBER' THEN
       l_ovn   := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TERRITORY_ID' THEN
       l_sr_rec.TERRITORY_ID := null; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'GROUP_TYPE' THEN
       l_sr_rec.GROUP_TYPE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_OCCURRED_DATE' THEN
       l_sr_rec.INCIDENT_OCCURRED_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SR_CREATION_CHANNEL' THEN
       l_sr_rec.SR_CREATION_CHANNEL := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAST_UPDATE_PROGRAM_CODE' THEN
       l_sr_rec.LAST_UPDATE_PROGRAM_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATION_PROGRAM_CODE' THEN
       l_sr_rec.CREATION_PROGRAM_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'BILL_TO_PARTY_ID' THEN
       l_sr_rec.BILL_TO_PARTY_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SHIP_TO_PARTY_ID' THEN
       l_sr_rec.SHIP_TO_PARTY_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'BILL_TO_SITE_ID' THEN
       l_sr_rec.BILL_TO_SITE_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SHIP_TO_SITE_ID' THEN
       l_sr_rec.SHIP_TO_SITE_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_LOCATION_TYPE' THEN
       l_sr_rec.INCIDENT_LOCATION_TYPE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INSTALL_SITE_ID' THEN
       L_SR_REC.INSTALL_SITE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EMPLOYEE_ID' THEN
       L_SR_REC.EMPLOYEE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROBLEM_CODE' THEN
       L_SR_REC.PROBLEM_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXPECTED_RESOLUTION_DATE' THEN
       L_SR_REC.exp_resolution_date := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_RESOLUTION_DATE' THEN
       L_SR_REC.ACT_RESOLUTION_DATE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_PRODUCT_ID' THEN
       L_SR_REC.CUSTOMER_PRODUCT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'BILL_TO_CONTACT_ID' THEN
       L_SR_REC.BILL_TO_CONTACT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SHIP_TO_CONTACT_ID' THEN
       L_SR_REC.SHIP_TO_CONTACT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CURRENT_SERIAL_NUMBER' THEN
       L_SR_REC.CURRENT_SERIAL_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_NUMBER' THEN
       L_SR_REC.CUSTOMER_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SYSTEM_ID' THEN
       L_SR_REC.SYSTEM_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_1' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_ATTRIBUTE_2' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_3' THEN
       L_SR_REC.request_attribute_3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_4' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_5' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_6' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_7' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_8' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_9' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_10' THEN
       L_SR_REC.request_attribute_10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_11' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_12' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_13' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_14' THEN
       L_SR_REC.request_attribute_14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_15' THEN
       L_SR_REC.request_attribute_15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_CONTEXT' THEN
       L_SR_REC.REQUEST_CONTEXT := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'RESOLUTION_CODE' THEN
       L_SR_REC.RESOLUTION_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ORIGINAL_ORDER_NUMBER' THEN
       L_SR_REC.ORIGINAL_ORDER_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PURCHASE_ORDER_NUM' THEN
       L_SR_REC.PURCHASE_ORDER_NUM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CLOSE_DATE' THEN
       L_SR_REC.CLOSED_DATE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'QA_COLLECTION_ID' THEN
       L_SR_REC.QA_COLLECTION_PLAN_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CONTRACT_ID' THEN
       L_SR_REC.CONTRACT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CONTRACT_NUMBER' THEN
       L_SR_REC.CONTRACT_SERVICE_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CONTRACT_SERVICE_ID' THEN
       L_SR_REC.CONTRACT_SERVICE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TIME_ZONE_ID' THEN
       L_SR_REC.TIME_ZONE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'RESOURCE_SUBTYPE_ID' THEN
       L_SR_REC.RESOURCE_SUBTYPE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TIME_DIFFERENCE' THEN
       L_SR_REC.TIME_DIFFERENCE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_PO_NUMBER' THEN
       L_SR_REC.CUST_PO_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_TICKET_NUMBER' THEN
       L_SR_REC.CUST_TICKET_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SITE_ID' THEN
       L_SR_REC.SITE_ID  := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_SITE_ID' THEN
       L_SR_REC.CUSTOMER_SITE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PLATFORM_VERSION_ID' THEN
       L_SR_REC.PLATFORM_VERSION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_COMPONENT_ID' THEN
       L_SR_REC.CP_COMPONENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_COMPONENT_VERSION_ID' THEN
       L_SR_REC.CP_COMPONENT_VERSION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_SUBCOMPONENT_ID' THEN
       L_SR_REC.CP_SUBCOMPONENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_SUBCOMPONENT_VERSION_ID' THEN
       L_SR_REC.CP_SUBCOMPONENT_VERSION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PLATFORM_ID' THEN
       L_SR_REC.PLATFORM_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LANGUAGE_ID' THEN
       L_SR_REC.LANGUAGE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_REVISION_ID' THEN
       L_SR_REC.CP_REVISION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_ITEM_REVISION' THEN
       L_SR_REC.INV_ITEM_REVISION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_COMPONENT_ID' THEN
       L_SR_REC.INV_COMPONENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_COMPONENT_VERSION' THEN
       L_SR_REC.INV_COMPONENT_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_SUBCOMPONENT_ID' THEN
       L_SR_REC.INV_SUBCOMPONENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_SUBCOMPONENT_VERSION' THEN
       L_SR_REC.INV_SUBCOMPONENT_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_ORGANIZATION_ID' THEN
       L_SR_REC.INVENTORY_ORG_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'REQUEST_ID' THEN
       L_SR_REC.CONC_REQUEST_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROGRAM_APPLICATION_ID' THEN
       L_SR_REC.PROGRAM_APPLICATION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROGRAM_ID' THEN
       L_SR_REC.PROGRAM_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROJECT_NUMBER' THEN
       L_SR_REC.PROJECT_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PLATFORM_VERSION' THEN
       L_SR_REC.PLATFORM_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DB_VERSION' THEN
       L_SR_REC.DB_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUST_PREF_LANG_ID' THEN
       L_SR_REC.CUST_PREF_LANG_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TIER' THEN
       L_SR_REC.TIER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TIER_VERSION' THEN
       L_SR_REC.TIER_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CATEGORY_ID' THEN
       L_SR_REC.CATEGORY_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OPERATING_SYSTEM' THEN
       L_SR_REC.OPERATING_SYSTEM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OPERATING_SYSTEM_VERSION' THEN
       L_SR_REC.OPERATING_SYSTEM_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DATABASE' THEN
       L_SR_REC.DATABASE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'GROUP_TYPE' THEN
       L_SR_REC.GROUP_TYPE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'GROUP_TERRITORY_ID' THEN
       L_SR_REC.GROUP_TERRITORY_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_PLATFORM_ORG_ID' THEN
       L_SR_REC.INV_PLATFORM_ORG_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'COMPONENT_VERSION' THEN
       L_SR_REC.COMPONENT_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SUBCOMPONENT_VERSION' THEN
       L_SR_REC.SUBCOMPONENT_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'COMM_PREF_CODE' THEN
       L_SR_REC.COMM_PREF_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_CHANNEL' THEN
       L_SR_REC.LAST_UPDATE_CHANNEL := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUST_PREF_LANG_CODE' THEN
       L_SR_REC.CUST_PREF_LANG_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ERROR_CODE' THEN
       L_SR_REC.ERROR_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CATEGORY_SET_ID' THEN
       L_SR_REC.CATEGORY_SET_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_REFERENCE' THEN
       L_SR_REC.EXTERNAL_REFERENCE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_RESOLVED_DATE' THEN
       L_SR_REC.INCIDENT_RESOLVED_DATE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INC_RESPONDED_BY_DATE' THEN
       L_SR_REC.INC_RESPONDED_BY_DATE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_NUMBER' THEN
       L_SR_REC.cc_number := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_TYPE_CODE' THEN
       L_SR_REC.cc_type_code := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_EXPIRATION_DATE' THEN
       L_SR_REC.cc_expiration_date := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_HOLDER_FNAME' THEN
       L_SR_REC.cc_first_name := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_HOLDER_MNAME' THEN
       L_SR_REC.cc_middle_name := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_HOLDER_LNAME' THEN
       L_SR_REC.cc_last_name := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_ID' THEN
       L_SR_REC.CC_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'COVERAGE_TYPE' THEN
       L_SR_REC.COVERAGE_TYPE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'BILL_TO_ACCOUNT_ID' THEN
       L_SR_REC.BILL_TO_ACCOUNT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SHIP_TO_ACCOUNT_ID' THEN
       L_SR_REC.SHIP_TO_ACCOUNT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_EMAIL_ID' THEN
       L_SR_REC.CUSTOMER_EMAIL_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_PHONE_ID' THEN
       L_SR_REC.CUSTOMER_PHONE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROGRAM_LOGIN_ID' THEN
       L_SR_REC.PROGRAM_LOGIN_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_POINT_OF_INTEREST' THEN
       L_SR_REC.INCIDENT_POINT_OF_INTEREST := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_CROSS_STREET' THEN
       L_SR_REC.INCIDENT_CROSS_STREET := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_DIRECTION_QUALIFIER' THEN
       L_SR_REC.INCIDENT_DIRECTION_QUALIFIER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_DISTANCE_QUALIFIER' THEN
       L_SR_REC.INCIDENT_DISTANCE_QUALIFIER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_DISTANCE_QUAL_UOM' THEN
       L_SR_REC.INCIDENT_DISTANCE_QUAL_UOM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS_STYLE' THEN
       L_SR_REC.INCIDENT_ADDRESS_STYLE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDR_LINES_PHONETIC' THEN
       L_SR_REC.INCIDENT_ADDR_LINES_PHONETIC := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_PO_BOX_NUMBER' THEN
       L_SR_REC.INCIDENT_PO_BOX_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_HOUSE_NUMBER' THEN
       L_SR_REC.INCIDENT_HOUSE_NUMBER := L_COL_VALUE_LIST(I);
     ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_STREET_SUFFIX' THEN
       L_SR_REC.INCIDENT_STREET_SUFFIX := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_STREET' THEN
       L_SR_REC.INCIDENT_STREET := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_STREET_NUMBER' THEN
       L_SR_REC.INCIDENT_STREET_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_FLOOR' THEN
       L_SR_REC.INCIDENT_FLOOR := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_SUITE' THEN
       L_SR_REC.INCIDENT_SUITE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_POSTAL_PLUS4_CODE' THEN
       L_SR_REC.INCIDENT_POSTAL_PLUS4_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_POSITION' THEN
       L_SR_REC.INCIDENT_POSITION  := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_LOCATION_DIRECTIONS' THEN
       L_SR_REC.INCIDENT_LOCATION_DIRECTIONS := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_LOCATION_DESCRIPTION' THEN
       L_SR_REC.INCIDENT_LOCATION_DESCRIPTION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INSTALL_SITE_ID' THEN
       L_SR_REC.INSTALL_SITE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OWNING_DEPARTMENT_ID' THEN
       L_SR_REC.OWNING_DEPARTMENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_LOCATION_TYPE' THEN
       L_SR_REC.INCIDENT_LOCATION_TYPE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'MAINT_ORGANIZATION_ID' THEN
       L_SR_REC.MAINT_ORGANIZATION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_1' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'EXTERNAL_ATTRIBUTE_2' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_3' THEN
       L_SR_REC.EXTERNAL_attribute_3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_4' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_5' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_6' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_7' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_8' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_9' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_10' THEN
       L_SR_REC.EXTERNAL_attribute_10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_11' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_12' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_13' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_14' THEN
       L_SR_REC.EXTERNAL_attribute_14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_15' THEN
       L_SR_REC.EXTERNAL_attribute_15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_CONTEXT' THEN
       L_SR_REC.EXTERNAL_CONTEXT := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INVENTORY_ITEM_ID' THEN
       L_SR_REC.INVENTORY_ITEM_ID := L_COL_VALUE_LIST(I);
      END IF;

      IF l_is_onetime_add = 'N' THEN
        IF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS' THEN
          L_SR_REC.INCIDENT_ADDRESS := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS2' THEN
          L_SR_REC.INCIDENT_ADDRESS2 := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS3' THEN
          L_SR_REC.INCIDENT_ADDRESS3 := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS4' THEN
          L_SR_REC.INCIDENT_ADDRESS4 := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_CITY' THEN
         L_SR_REC.INCIDENT_CITY := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_STATE' THEN
         L_SR_REC.INCIDENT_STATE := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_COUNTRY' THEN
         L_SR_REC.INCIDENT_COUNTRY := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_PROVINCE' THEN
         L_SR_REC.INCIDENT_PROVINCE := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_POSTAL_CODE' THEN
         L_SR_REC.INCIDENT_POSTAL_CODE := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_COUNTY' THEN
         L_SR_REC.INCIDENT_COUNTY := L_COL_VALUE_LIST(I);
        ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_LOCATION_ID' THEN
         l_sr_rec.INCIDENT_LOCATION_ID := L_COL_VALUE_LIST(I);
        END IF;
      END IF;  --one time add check
     END IF;
  END LOOP;

CS_ServiceRequest_PUB.Create_ServiceRequest
    ( p_api_version          => 4.0
    , P_INIT_MSG_LIST        => FND_API.G_TRUE
    , p_commit               => FND_API.G_false
    , x_return_status        => l_RETURN_STATUS
    , x_msg_count            => l_msg_count
    , x_msg_data             => l_msg_data
    , p_user_id              => l_created_by
    , p_org_id               => l_org_id
    , p_request_id           => l_incident_id
    , p_request_number       => l_incident_number
    , p_service_request_rec  => l_sr_rec
    , p_notes                => l_notes_tab
    , p_contacts             => l_contacts_tab
    , p_resp_id		           => l_resp_id
    , p_default_contract_sla_ind => 'Y'
    , p_auto_generate_tasks      => 'N'
    , p_auto_assign 		 => 'Y'
    , x_sr_create_out_rec	 => l_sr_out_rec
    );
  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT (p_api_error => TRUE );

    x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;
  ELSE
    --After Successful SR insert process SR audit
    BEGIN
      FOR R_GET_AUD_OBJECTS IN C_GET_AUD_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
        CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUD_OBJECTS.HA_PAYLOAD_ID
                            ,X_RETURN_STATUS => L_AUD_RETURN_STATUS
                            ,x_ERROR_MESSAGE => l_AUD_ERROR_MESSAGE);
      END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_INSERT', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_SERVICE_REQUESTS_PKG.APPLY_HA_INSERT: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_Error_Message := S_Msg_Data;
End Apply_Ha_Insert;


PROCEDURE APPLY_HA_UPDATE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
l_HA_PAYLOAD_ID     NUMBER;
l_COL_NAME_LIST  CSM_VARCHAR_LIST;
l_COL_VALUE_LIST CSM_VARCHAR_LIST;
l_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
l_RETURN_STATUS  VARCHAR2(200);
l_ERROR_MESSAGE  VARCHAR2(2000);
L_AUD_RETURN_STATUS  VARCHAR2(200);
l_AUD_ERROR_MESSAGE  VARCHAR2(2000);
l_sr_rec                CS_ServiceRequest_PUB.service_request_rec_type;
l_contact_rec           CS_ServiceRequest_PUB.contacts_rec;
l_notes_tab             CS_ServiceRequest_PUB.notes_table;
l_contacts_tab          CS_ServiceRequest_PUB.contacts_table;
l_sr_out_rec            CS_ServiceRequest_PUB.sr_update_out_rec_type;
l_variable_assignment  vARCHAR2(2000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(1000);
s_msg_data VARCHAR2(1000);
l_org_id  NUMBER;
l_incident_id NUMBER;
L_Incident_Number Varchar2(240);
L_Contact_Index NUMBER;
l_resp_id  NUMBER := 23675;
L_OVN                   NUMBER;
L_LAST_UPDATED_BY NUMBER;
L_LAST_UPDATE_LOGIN NUMBER;
L_LAST_UPDATE_DATE DATE;
L_HZ_PARTY_SITE_ID NUMBER;
L_HZ_DML_TYPE      VARCHAR2(1);
L_SR_CONTACT_POINT_ID NUMBER;
l_is_onetime_add VARCHAR(1) := 'N';

Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE,
       PK_VALUE
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME NOT IN('CS_INCIDENTS_AUDIT_B','CS_INCIDENTS_AUDIT_TL')
ORDER BY HA_PAYLOAD_ID ASC;

--cursor for Audit Insert
Cursor C_Get_Aud_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME IN('CS_INCIDENTS_AUDIT_B','CS_INCIDENTS_AUDIT_TL')
ORDER BY HA_PAYLOAD_ID ASC;

CURSOR C_GET_PARTY_SITE (C_PARTY_SITE_ID NUMBER)
IS
SELECT PARTY_SITE_ID
FROM HZ_PARTY_SITES
WHERE PARTY_SITE_ID = C_PARTY_SITE_ID;

CURSOR C_GET_CONTACT_POINTS (C_SR_CONTACT_POINT_ID NUMBER)
IS
SELECT SR_CONTACT_POINT_ID
FROM   CS_HZ_SR_CONTACT_POINTS
WHERE  SR_CONTACT_POINT_ID = C_SR_CONTACT_POINT_ID;

r_Get_Aux_objects C_Get_Aux_objects%ROWTYPE;

l_Aux_Name_List   Csm_Varchar_List;
l_aux_Value_List  Csm_Varchar_List;
L_Hzl_Name_List   Csm_Varchar_List;
L_Hzl_Value_List  Csm_Varchar_List;
L_HZPS_NAME_LIST   CSM_VARCHAR_LIST;
L_HZPS_VALUE_LIST  CSM_VARCHAR_LIST;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID   := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;
l_contact_index := 0;
CS_SERVICEREQUEST_PUB.INITIALIZE_REC( P_SR_RECORD => L_SR_REC );

--Process Aux Objects
  For R_Get_Aux_Objects In C_Get_Aux_Objects(P_Ha_Payload_Id)  Loop

    CSM_HA_PROCESS_PKG.Parse_Xml(P_Ha_Payload_Id =>R_Get_Aux_Objects.Ha_Payload_Id,
                        X_Col_Name_List  => l_Aux_Name_List,
                        x_COL_VALUE_LIST => l_Aux_Value_List,
                        X_Con_Name_List  => L_CON_NAME_LIST,
                        x_COn_VALUE_LIST => L_CON_VALUE_LIST,
                        X_Return_Status  => L_Return_Status,
                        X_Error_Message  => L_Error_Message);

    IF R_GET_AUX_OBJECTS.OBJECT_NAME = 'CS_INCIDENTS_ALL_TL' THEN
         If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
          For I In 1..L_Aux_Name_List.Count-1 Loop
            IF L_AUX_NAME_LIST(I) = 'SUMMARY' THEN
                L_SR_REC.SUMMARY := L_AUX_VALUE_LIST(I);
              ELSIF L_AUX_NAME_LIST(I) = 'RESOLUTION_SUMMARY' THEN
                L_SR_REC.RESOLUTION_SUMMARY := L_AUX_VALUE_LIST(I);
            END IF;
          END LOOP;
         END IF;
     ELSIF R_Get_Aux_Objects.Object_Name = 'CS_HZ_SR_CONTACT_POINTS' Then

        If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            /*Contact is passed from Payload*/
         l_contact_index := l_contact_index + 1;
         For I In 1..L_Aux_Name_List.Count-1 Loop

            IF l_Aux_Name_List(I) = 'SR_CONTACT_POINT_ID' THEN
              L_Contact_Rec.Sr_Contact_Point_Id := l_Aux_Value_List(I);
            Elsif  l_Aux_Name_List(I) = 'PARTY_ID' Then
              L_Contact_Rec.Party_Id            := l_Aux_Value_List(I);
            Elsif  l_Aux_Name_List(I) = 'CONTACT_POINT_ID' Then
              l_contact_rec.CONTACT_POINT_ID            := l_Aux_Value_List(I);
            Elsif  l_Aux_Name_List(I) = 'CONTACT_POINT_TYPE' Then
              L_Contact_Rec.CONTACT_POINT_TYPE            := l_Aux_Value_List(I);
            Elsif  l_Aux_Name_List(I) = 'PRIMARY_FLAG' Then
              l_contact_rec.PRIMARY_FLAG            := l_Aux_Value_List(I);
            Elsif  l_Aux_Name_List(I) = 'CONTACT_TYPE' Then
              L_Contact_Rec.Contact_Type            := l_Aux_Value_List(I);
            Elsif  l_Aux_Name_List(I) = 'PARTY_ROLE_CODE' Then
              L_Contact_Rec.party_role_code         := l_Aux_Value_List(I);
            Elsif  L_Aux_Name_List(I) = 'START_DATE_ACTIVE' Then
              L_Contact_Rec.start_date_active       := l_Aux_Value_List(I);
            Elsif  l_Aux_Name_List(I) = 'END_DATE_ACTIVE' Then
              L_Contact_Rec.end_date_active          := l_Aux_Value_List(I);
            End If;
          END LOOP;

          OPEN  C_GET_CONTACT_POINTS (C_SR_CONTACT_POINT_ID =>L_Contact_Rec.Sr_Contact_Point_Id);
          FETCH C_GET_CONTACT_POINTS INTO L_SR_CONTACT_POINT_ID;
          CLOSE C_GET_CONTACT_POINTS;

          IF L_SR_CONTACT_POINT_ID IS NULL THEN
            --SEt the Contacts record to pass it to SR Api
            L_Contacts_Tab( l_contact_index ) := L_Contact_Rec;
          END IF;
        End If;
    Elsif R_Get_Aux_Objects.Object_Name = 'HZ_LOCATIONS' Then

         l_is_onetime_add := 'Y';
         --Incident location id is set to null to tell the SR api that one time address
         --is getting created.Else it will throw location not found error.
         l_sr_rec.INCIDENT_LOCATION_ID := NULL;

         For I In 1..L_Aux_Name_List.Count-1 Loop
            IF L_Aux_Name_List(I) = 'ADDRESS1' Then
               l_sr_rec.INCIDENT_ADDRESS := l_Aux_Value_List(I);
            ELSIF  L_Aux_Name_List(I) = 'ADDRESS2' THEN
             L_SR_REC.INCIDENT_ADDRESS2 := l_Aux_Value_List(I);
           ELSIF  L_Aux_Name_List(I) = 'ADDRESS3' THEN
             L_SR_REC.INCIDENT_ADDRESS3 := l_Aux_Value_List(I);
            ELSIF  L_Aux_Name_List(I) = 'ADDRESS4' THEN
               L_SR_REC.INCIDENT_ADDRESS4 := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'CITY' Then
               l_sr_rec.INCIDENT_CITY        := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'STATE' Then
               l_sr_rec.INCIDENT_STATE               := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'POSTAL_CODE' Then
              l_sr_rec.INCIDENT_POSTAL_CODE         := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'COUNTY' Then
              l_sr_rec.INCIDENT_COUNTY              := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'PROVINCE' Then
              l_sr_rec.INCIDENT_PROVINCE            := l_Aux_Value_List(I);
            Elsif L_Aux_Name_List(I) = 'COUNTRY' Then
              l_sr_rec.INCIDENT_COUNTRY             := l_Aux_Value_List(I);
            End If;

          END LOOP;

    ELSIF R_GET_AUX_OBJECTS.OBJECT_NAME = 'HZ_PARTY_SITES' THEN
        --check if the record already exists and set the DML Type accdg.
        OPEN C_GET_PARTY_SITE (C_PARTY_SITE_ID =>R_GET_AUX_OBJECTS.PK_VALUE);
        FETCH C_GET_PARTY_SITE INTO L_HZ_PARTY_SITE_ID;
        CLOSE C_GET_PARTY_SITE;

   /*     IF L_HZ_PARTY_SITE_ID IS NULL THEN
          L_HZ_DML_TYPE := 'I';
        ELSE
          L_HZ_DML_TYPE := 'U';
        END IF;

        L_Hzps_Name_List  := l_Aux_Name_List;
        L_Hzps_Value_List := L_Aux_Value_List;
      Csm_Hz_Location_Pkg.APPLY_HA_CHANGES
          (P_Ha_Payload_Id   => P_Ha_Payload_Id,
           p_Hzl_Name_List   => L_Hzl_Name_List,
           p_Hzl_Value_List  => L_Hzl_Value_List,
           p_Hzps_Name_List  => L_Hzps_Name_List,
           P_HZPS_VALUE_LIST => L_HZPS_VALUE_LIST,
           p_dml_type        => L_HZ_DML_TYPE,
           X_Return_Status   => L_Return_Status,
           X_Error_Message   => L_Error_Message
         );*/
    END IF;

    If L_Aux_Name_List.Count > 0 Then
      L_Aux_Name_List.DELETE;
    End If;
    If L_Aux_Value_List.Count > 0 Then
      L_Aux_Value_List.Delete;
    End If;
  End Loop;
      IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        X_Return_Status := L_Return_Status;
        X_Error_Message := L_Error_Message;
        Return;
      END IF;
---Create SR
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  l_COL_VALUE_LIST(i) IS NOT NULL THEN
      IF l_COL_NAME_LIST(i) = 'INCIDENT_STATUS_ID' THEN
        l_sr_rec.status_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_TYPE_ID' THEN
        l_sr_rec.type_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_URGENCY_ID' THEN
        l_sr_rec.urgency_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_SEVERITY_ID' THEN
        l_sr_rec.severity_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_OWNER_ID' THEN
        l_sr_rec.owner_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CUSTOMER_ID' THEN
        l_sr_rec.customer_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'BILL_TO_SITE_USE_ID' THEN
        l_sr_rec.bill_to_site_use_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SHIP_TO_SITE_USE_ID' THEN
        L_SR_REC.SHIP_TO_SITE_USE_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ORG_ID' THEN
        l_org_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_ID' THEN
        l_incident_id := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_NUMBER' THEN
       l_incident_number := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_DATE' THEN
       l_sr_rec.request_date := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CALLER_TYPE' THEN
       l_sr_rec.CALLER_TYPE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'PUBLISH_FLAG' THEN
       l_sr_rec.PUBLISH_FLAG := NULL; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RESOURCE_TYPE' THEN
       l_sr_rec.RESOURCE_TYPE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACCOUNT_ID' THEN
       l_sr_rec.ACCOUNT_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OWNER_GROUP_ID' THEN
       l_sr_rec.OWNER_GROUP_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OBLIGATION_DATE' THEN
       l_sr_rec.OBLIGATION_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TERRITORY_ID' THEN
       l_sr_rec.TERRITORY_ID := null; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'GROUP_TYPE' THEN
       l_sr_rec.GROUP_TYPE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_OCCURRED_DATE' THEN
       l_sr_rec.INCIDENT_OCCURRED_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SR_CREATION_CHANNEL' THEN
       l_sr_rec.SR_CREATION_CHANNEL := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAST_UPDATE_PROGRAM_CODE' THEN
       l_sr_rec.LAST_UPDATE_PROGRAM_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'CREATION_PROGRAM_CODE' THEN
       l_sr_rec.CREATION_PROGRAM_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'BILL_TO_PARTY_ID' THEN
       l_sr_rec.BILL_TO_PARTY_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SHIP_TO_PARTY_ID' THEN
       l_sr_rec.SHIP_TO_PARTY_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'BILL_TO_SITE_ID' THEN
       l_sr_rec.BILL_TO_SITE_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SHIP_TO_SITE_ID' THEN
       l_sr_rec.SHIP_TO_SITE_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_LOCATION_TYPE' THEN
       l_sr_rec.INCIDENT_LOCATION_TYPE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'INSTALL_SITE_ID' THEN
       L_SR_REC.INSTALL_SITE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATED_BY' THEN
       L_LAST_UPDATED_BY        := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_LOGIN' THEN
       L_LAST_UPDATE_LOGIN      := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_DATE' THEN
       L_LAST_UPDATE_DATE       := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OBJECT_VERSION_NUMBER' THEN
       l_ovn                    := L_COL_VALUE_LIST(I) -1;
      ELSIF  L_COL_NAME_LIST(I) = 'EMPLOYEE_ID' THEN
       L_SR_REC.EMPLOYEE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROBLEM_CODE' THEN
       L_SR_REC.PROBLEM_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXPECTED_RESOLUTION_DATE' THEN
       L_SR_REC.exp_resolution_date := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_RESOLUTION_DATE' THEN
       L_SR_REC.ACT_RESOLUTION_DATE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_PRODUCT_ID' THEN
       L_SR_REC.CUSTOMER_PRODUCT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'BILL_TO_CONTACT_ID' THEN
       L_SR_REC.BILL_TO_CONTACT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SHIP_TO_CONTACT_ID' THEN
       L_SR_REC.SHIP_TO_CONTACT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CURRENT_SERIAL_NUMBER' THEN
       L_SR_REC.CURRENT_SERIAL_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_NUMBER' THEN
       L_SR_REC.CUSTOMER_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SYSTEM_ID' THEN
       L_SR_REC.SYSTEM_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_1' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_ATTRIBUTE_2' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_3' THEN
       L_SR_REC.request_attribute_3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_4' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_5' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_6' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_7' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_8' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_9' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_10' THEN
       L_SR_REC.request_attribute_10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_11' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_12' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_13' THEN
       L_SR_REC.REQUEST_ATTRIBUTE_13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_14' THEN
       L_SR_REC.request_attribute_14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ATTRIBUTE_15' THEN
       L_SR_REC.request_attribute_15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_CONTEXT' THEN
       L_SR_REC.REQUEST_CONTEXT := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'RESOLUTION_CODE' THEN
       L_SR_REC.RESOLUTION_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ORIGINAL_ORDER_NUMBER' THEN
       L_SR_REC.ORIGINAL_ORDER_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PURCHASE_ORDER_NUM' THEN
       L_SR_REC.PURCHASE_ORDER_NUM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CLOSE_DATE' THEN
       L_SR_REC.CLOSED_DATE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'QA_COLLECTION_ID' THEN
       L_SR_REC.QA_COLLECTION_PLAN_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CONTRACT_ID' THEN
       L_SR_REC.CONTRACT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CONTRACT_NUMBER' THEN
       L_SR_REC.CONTRACT_SERVICE_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CONTRACT_SERVICE_ID' THEN
       L_SR_REC.CONTRACT_SERVICE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TIME_ZONE_ID' THEN
       L_SR_REC.TIME_ZONE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'RESOURCE_SUBTYPE_ID' THEN
       L_SR_REC.RESOURCE_SUBTYPE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TIME_DIFFERENCE' THEN
       L_SR_REC.TIME_DIFFERENCE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_PO_NUMBER' THEN
       L_SR_REC.CUST_PO_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_TICKET_NUMBER' THEN
       L_SR_REC.CUST_TICKET_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SITE_ID' THEN
       L_SR_REC.SITE_ID  := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_SITE_ID' THEN
       L_SR_REC.CUSTOMER_SITE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PLATFORM_VERSION_ID' THEN
       L_SR_REC.PLATFORM_VERSION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_COMPONENT_ID' THEN
       L_SR_REC.CP_COMPONENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_COMPONENT_VERSION_ID' THEN
       L_SR_REC.CP_COMPONENT_VERSION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_SUBCOMPONENT_ID' THEN
       L_SR_REC.CP_SUBCOMPONENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_SUBCOMPONENT_VERSION_ID' THEN
       L_SR_REC.CP_SUBCOMPONENT_VERSION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PLATFORM_ID' THEN
       L_SR_REC.PLATFORM_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LANGUAGE_ID' THEN
       L_SR_REC.LANGUAGE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CP_REVISION_ID' THEN
       L_SR_REC.CP_REVISION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_ITEM_REVISION' THEN
       L_SR_REC.INV_ITEM_REVISION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_COMPONENT_ID' THEN
       L_SR_REC.INV_COMPONENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_COMPONENT_VERSION' THEN
       L_SR_REC.INV_COMPONENT_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_SUBCOMPONENT_ID' THEN
       L_SR_REC.INV_SUBCOMPONENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_SUBCOMPONENT_VERSION' THEN
       L_SR_REC.INV_SUBCOMPONENT_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_ORGANIZATION_ID' THEN
       L_SR_REC.INVENTORY_ORG_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'REQUEST_ID' THEN
       L_SR_REC.CONC_REQUEST_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROGRAM_APPLICATION_ID' THEN
       L_SR_REC.PROGRAM_APPLICATION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROGRAM_ID' THEN
       L_SR_REC.PROGRAM_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROJECT_NUMBER' THEN
       L_SR_REC.PROJECT_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PLATFORM_VERSION' THEN
       L_SR_REC.PLATFORM_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DB_VERSION' THEN
       L_SR_REC.DB_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUST_PREF_LANG_ID' THEN
       L_SR_REC.CUST_PREF_LANG_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TIER' THEN
       L_SR_REC.TIER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TIER_VERSION' THEN
       L_SR_REC.TIER_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CATEGORY_ID' THEN
       L_SR_REC.CATEGORY_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OPERATING_SYSTEM' THEN
       L_SR_REC.OPERATING_SYSTEM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OPERATING_SYSTEM_VERSION' THEN
       L_SR_REC.OPERATING_SYSTEM_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DATABASE' THEN
       L_SR_REC.DATABASE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'GROUP_TYPE' THEN
       L_SR_REC.GROUP_TYPE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'GROUP_TERRITORY_ID' THEN
       L_SR_REC.GROUP_TERRITORY_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INV_PLATFORM_ORG_ID' THEN
       L_SR_REC.INV_PLATFORM_ORG_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'COMPONENT_VERSION' THEN
       L_SR_REC.COMPONENT_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SUBCOMPONENT_VERSION' THEN
       L_SR_REC.SUBCOMPONENT_VERSION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'COMM_PREF_CODE' THEN
       L_SR_REC.COMM_PREF_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LAST_UPDATE_CHANNEL' THEN
       L_SR_REC.LAST_UPDATE_CHANNEL := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUST_PREF_LANG_CODE' THEN
       L_SR_REC.CUST_PREF_LANG_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ERROR_CODE' THEN
       L_SR_REC.ERROR_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CATEGORY_SET_ID' THEN
       L_SR_REC.CATEGORY_SET_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_REFERENCE' THEN
       L_SR_REC.EXTERNAL_REFERENCE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_RESOLVED_DATE' THEN
       L_SR_REC.INCIDENT_RESOLVED_DATE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INC_RESPONDED_BY_DATE' THEN
       L_SR_REC.INC_RESPONDED_BY_DATE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_NUMBER' THEN
       L_SR_REC.cc_number := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_TYPE_CODE' THEN
       L_SR_REC.cc_type_code := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_EXPIRATION_DATE' THEN
       L_SR_REC.cc_expiration_date := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_HOLDER_FNAME' THEN
       L_SR_REC.cc_first_name := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_HOLDER_MNAME' THEN
       L_SR_REC.cc_middle_name := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_HOLDER_LNAME' THEN
       L_SR_REC.cc_last_name := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREDIT_CARD_ID' THEN
       L_SR_REC.CC_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'COVERAGE_TYPE' THEN
       L_SR_REC.COVERAGE_TYPE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'BILL_TO_ACCOUNT_ID' THEN
       L_SR_REC.BILL_TO_ACCOUNT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SHIP_TO_ACCOUNT_ID' THEN
       L_SR_REC.SHIP_TO_ACCOUNT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_EMAIL_ID' THEN
       L_SR_REC.CUSTOMER_EMAIL_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_PHONE_ID' THEN
       L_SR_REC.CUSTOMER_PHONE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PROGRAM_LOGIN_ID' THEN
       L_SR_REC.PROGRAM_LOGIN_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_POINT_OF_INTEREST' THEN
       L_SR_REC.INCIDENT_POINT_OF_INTEREST := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_CROSS_STREET' THEN
       L_SR_REC.INCIDENT_CROSS_STREET := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_DIRECTION_QUALIFIER' THEN
       L_SR_REC.INCIDENT_DIRECTION_QUALIFIER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_DISTANCE_QUALIFIER' THEN
       L_SR_REC.INCIDENT_DISTANCE_QUALIFIER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_DISTANCE_QUAL_UOM' THEN
       L_SR_REC.INCIDENT_DISTANCE_QUAL_UOM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS_STYLE' THEN
       L_SR_REC.INCIDENT_ADDRESS_STYLE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDR_LINES_PHONETIC' THEN
       L_SR_REC.INCIDENT_ADDR_LINES_PHONETIC := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_PO_BOX_NUMBER' THEN
       L_SR_REC.INCIDENT_PO_BOX_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_HOUSE_NUMBER' THEN
       L_SR_REC.INCIDENT_HOUSE_NUMBER := L_COL_VALUE_LIST(I);
     ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_STREET_SUFFIX' THEN
       L_SR_REC.INCIDENT_STREET_SUFFIX := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_STREET' THEN
       L_SR_REC.INCIDENT_STREET := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_STREET_NUMBER' THEN
       L_SR_REC.INCIDENT_STREET_NUMBER := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_FLOOR' THEN
       L_SR_REC.INCIDENT_FLOOR := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_SUITE' THEN
       L_SR_REC.INCIDENT_SUITE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_POSTAL_PLUS4_CODE' THEN
       L_SR_REC.INCIDENT_POSTAL_PLUS4_CODE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_POSITION' THEN
       L_SR_REC.INCIDENT_POSITION  := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_LOCATION_DIRECTIONS' THEN
       L_SR_REC.INCIDENT_LOCATION_DIRECTIONS := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_LOCATION_DESCRIPTION' THEN
       L_SR_REC.INCIDENT_LOCATION_DESCRIPTION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INSTALL_SITE_ID' THEN
       L_SR_REC.INSTALL_SITE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OWNING_DEPARTMENT_ID' THEN
       L_SR_REC.OWNING_DEPARTMENT_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_LOCATION_TYPE' THEN
       L_SR_REC.INCIDENT_LOCATION_TYPE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'MAINT_ORGANIZATION_ID' THEN
       L_SR_REC.MAINT_ORGANIZATION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_1' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'EXTERNAL_ATTRIBUTE_2' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_3' THEN
       L_SR_REC.EXTERNAL_attribute_3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_4' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_5' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_6' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_7' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_8' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_9' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_10' THEN
       L_SR_REC.EXTERNAL_attribute_10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_11' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_12' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_13' THEN
       L_SR_REC.EXTERNAL_ATTRIBUTE_13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_14' THEN
       L_SR_REC.EXTERNAL_attribute_14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_ATTRIBUTE_15' THEN
       L_SR_REC.EXTERNAL_attribute_15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'EXTERNAL_CONTEXT' THEN
       L_SR_REC.EXTERNAL_CONTEXT := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'INVENTORY_ITEM_ID' THEN
       L_SR_REC.INVENTORY_ITEM_ID := L_COL_VALUE_LIST(I);
      END IF;

      IF l_is_onetime_add = 'N' THEN
        IF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS' THEN
          L_SR_REC.INCIDENT_ADDRESS := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS2' THEN
          L_SR_REC.INCIDENT_ADDRESS2 := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS3' THEN
          L_SR_REC.INCIDENT_ADDRESS3 := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_ADDRESS4' THEN
          L_SR_REC.INCIDENT_ADDRESS4 := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_CITY' THEN
         L_SR_REC.INCIDENT_CITY := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_STATE' THEN
         L_SR_REC.INCIDENT_STATE := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_COUNTRY' THEN
         L_SR_REC.INCIDENT_COUNTRY := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_PROVINCE' THEN
         L_SR_REC.INCIDENT_PROVINCE := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_POSTAL_CODE' THEN
         L_SR_REC.INCIDENT_POSTAL_CODE := L_COL_VALUE_LIST(I);
        ELSIF  L_COL_NAME_LIST(I) = 'INCIDENT_COUNTY' THEN
         L_SR_REC.INCIDENT_COUNTY := L_COL_VALUE_LIST(I);
        ELSIF  l_COL_NAME_LIST(i) = 'INCIDENT_LOCATION_ID' THEN
         l_sr_rec.INCIDENT_LOCATION_ID := L_COL_VALUE_LIST(I);
        END IF;
      END IF;  --one time add check
     END IF;
  END LOOP;

-- Retrieve the required object_version_number
--as passing the ovn from standby will give error.
  OPEN  C_OVN ( B_INCIDENT_ID => L_INCIDENT_ID );
  FETCH C_OVN  INTO R_OVN;
  IF C_OVN%FOUND THEN
    L_OVN := R_OVN.OBJECT_VERSION_NUMBER;
  ELSE
    -- Let the API complain.
    L_OVN := FND_API.G_MISS_NUM;
  END IF;
  CLOSE C_OVN;


CS_SERVICEREQUEST_PUB.UPDATE_SERVICEREQUEST
    ( p_api_version          => 4.0
    , P_INIT_MSG_LIST        => FND_API.G_TRUE
    , p_commit               => FND_API.G_FALSE
    , x_return_status        => l_RETURN_STATUS
    , x_msg_count            => l_msg_count
    , X_MSG_DATA             => L_MSG_DATA
    , P_REQUEST_ID           => L_INCIDENT_ID
--    , P_REQUEST_NUMBER       => L_INCIDENT_NUMBER
    , P_OBJECT_VERSION_NUMBER => L_OVN
    , P_LAST_UPDATED_BY      => L_LAST_UPDATED_BY
    , P_LAST_UPDATE_LOGIN    => L_LAST_UPDATE_LOGIN
    , p_last_update_date     => L_LAST_UPDATE_DATE
    , p_service_request_rec  => l_sr_rec
    , p_notes                => l_notes_tab
    , p_contacts             => l_contacts_tab
    , p_resp_id		           => l_resp_id
    , p_default_contract_sla_ind => 'Y'
    , P_VALIDATE_SR_CLOSURE      => 'N'
    , p_auto_assign 		         => 'Y'
    , x_sr_update_out_rec	 => l_sr_out_rec
    );

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;
  ELSE
    --After Successful SR insert process SR audit
    BEGIN
      FOR R_GET_AUD_OBJECTS IN C_GET_AUD_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
        CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUD_OBJECTS.HA_PAYLOAD_ID
                            ,X_RETURN_STATUS => L_AUD_RETURN_STATUS
                            ,x_ERROR_MESSAGE => l_AUD_ERROR_MESSAGE);
      END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_UPDATE', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_SERVICE_REQUESTS_PKG.APPLY_HA_UPDATE: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_EXCEPTION);
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;
    --After Successful SR update process SR audit
    BEGIN
      FOR R_GET_AUD_OBJECTS IN C_GET_AUD_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
        CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUD_OBJECTS.HA_PAYLOAD_ID
                            ,X_RETURN_STATUS => L_AUD_RETURN_STATUS
                            ,x_ERROR_MESSAGE => l_AUD_ERROR_MESSAGE);
      END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
End APPLY_HA_UPDATE;

PROCEDURE APPLY_HA_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           P_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )IS
L_RETURN_STATUS  VARCHAR2(100);
l_ERROR_MESSAGE  VARCHAR2(4000);
BEGIN
  /*** initialize return status and message list ***/
  L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_HA_INSERT
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='U' THEN
    -- Process update
            APPLY_HA_UPDATE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
  END IF;
  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_CHANGES;

END CSM_SERVICE_REQUESTS_PKG;

/
