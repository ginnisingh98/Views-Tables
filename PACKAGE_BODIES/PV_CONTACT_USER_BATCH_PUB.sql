--------------------------------------------------------
--  DDL for Package Body PV_CONTACT_USER_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_CONTACT_USER_BATCH_PUB" AS
/* $Header: pvxpldcb.pls 120.24 2006/02/12 19:48 svnathan noship $ */

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);



L_LOG_FILE                              utl_file.file_type;




PROCEDURE Write_Error
(
p_errors_tbl IN LOG_MESSAGE_TBL_TYPE

)
IS
l_errors_tbl LOG_MESSAGE_TBL_TYPE:=p_errors_tbl;
BEGIN
    -- dbms_output.put_line('Error Count: ' || l_errors_tbl.count);
    if l_errors_tbl.count > 0 then
        for i in 1..l_errors_tbl.count
        loop
            utl_file.put_line(L_LOG_FILE, rpad(' ',160) || l_errors_tbl(i));
            -- dbms_output.put_line('Error: ' || l_errors_tbl(i));
        end loop;
        l_errors_tbl.delete;
    end if;

END Write_Error;



PROCEDURE upsert_attributes(
     p_api_version_number  IN  NUMBER
    ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
    ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
    ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,p_attr_details_tbl  	  IN	PV_CONTACT_USER_BATCH_PUB.attr_details_tbl_type
    ,p_contact_rel_id IN NUMBER
    ,x_log_msg OUT NOCOPY LOG_MESSAGE_TBL_TYPE
    ,x_attribute_creation_status OUT NOCOPY VARCHAR2
)
IS
l_attr_details_tbl PV_CONTACT_USER_BATCH_PUB.attr_details_tbl_type := p_attr_details_tbl;
l_version  NUMBER;
l_upsert_attr_tbl    PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
l_attribute_details_rec PV_CONTACT_USER_BATCH_PUB.attribute_details_rec_type;
l_contact_rel_id NUMBER := p_contact_rel_id;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
L_API_NAME           CONSTANT VARCHAR2(30) := 'upsert_attributes';
l_status VARCHAR2(100) := 'SUCCESS';
l_log_msg  LOG_MESSAGE_TBL_TYPE;
l_log_count NUMBER :=0;
  CURSOR get_attr_version(cv_entity_id IN NUMBER, cv_attr_id IN Number) IS
        SELECT
            	max(version)
		FROM
    			pv_enty_attr_values
    	WHERE
    			attribute_id = cv_attr_id and
    			entity_id = cv_entity_id;



BEGIN

      -- dbms_output.put_line ('Entered Attribute values upsert');
      x_attribute_creation_status:='ERROR';
           for j in l_attr_details_tbl.first..l_attr_details_tbl.last
            loop
                  -- dbms_output.put_line ('Entered for loop');

		  l_attribute_details_rec:=l_attr_details_tbl(j);
                  -- dbms_output.put_line ('Assigned the attr details rec');

                  OPEN get_attr_version(l_contact_rel_id,l_attribute_details_rec.attribute_id);
                     FETCH get_attr_version INTO l_version;
                  close get_attr_version;

                  -- dbms_output.put_line ('After the cursor');
                  if l_version is null then
			l_version := 0;
		  end if;
                  -- dbms_output.put_line ('After the version '|| l_version );
                  -- dbms_output.put_line ('l_contact_rel_id '|| l_contact_rel_id );
 		  -- dbms_output.put_line ('attribute id  '|| l_attribute_details_rec.attribute_id );

		      PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value (
                         p_api_version_number=> 1.0
                         ,p_init_msg_list    => FND_API.g_true
                         ,p_commit           => FND_API.g_false
                         ,p_validation_level => FND_API.g_valid_level_full
                         ,x_return_status    => l_return_status
                         ,x_msg_count        => l_msg_count
                         ,x_msg_data         => l_msg_data
                         ,p_attribute_id     => l_attribute_details_rec.attribute_id
                         ,p_entity	     => 'PARTNER_CONTACT'
                         ,p_entity_id	     => l_contact_rel_id
                         ,p_version          => l_version
                         ,p_attr_val_tbl     => l_attribute_details_rec.attr_values_tbl
                      );

		        -- dbms_output.put_line ('After API call'|| l_return_status);
			      -- dbms_output.put_line('Message count : '||l_msg_count);
			      -- dbms_output.put_line('Before message data : ');
			      -- dbms_output.put_line(' API msgdata=> '|| l_msg_data);


  		         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				 x_attribute_creation_status:='SUCCESS';
                         END IF;


  		         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				 x_attribute_creation_status:='ERROR';


				 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				    /*FOR l_msg_index IN 1..l_msg_count LOOP
					    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
					    -- dbms_output.put_line(fnd_message.get);
					    l_log_count:= l_log_count + 1;
					    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
				    END LOOP;
				    */

 			            l_log_count:= l_log_count + 1;
				    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_count));
				    x_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

				 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
				    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
				    FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value');
				    l_log_count:= l_log_count + 1;
				    x_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
				 END IF;
			  END IF;


            end loop;


      -- dbms_output.put_line ('Done with Attribute values upsert');





EXCEPTION


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      -- dbms_output.put_line ('entered unexpected error in attributes');
      x_attribute_creation_status:='ERROR';

   WHEN OTHERS THEN
      -- dbms_output.put_line ('entered other error in attributes');
      x_attribute_creation_status:='ERROR';
END upsert_attributes;











PROCEDURE contact_create (
     p_api_version_number  IN  NUMBER
    ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
    ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
    ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,p_contact_details_rec		IN	 CONTACT_DETAILS_REC_TYPE
    ,p_update_flag    IN VARCHAR2
    ,x_contact_rel_id OUT NOCOPY NUMBER
    ,x_contact_output_rec  OUT NOCOPY CONTACT_OUTPUT_REC_TYPE
    ,x_log_msg OUT NOCOPY LOG_MESSAGE_TBL_TYPE
    ,x_return_status      OUT NOCOPY  VARCHAR2
    ,x_msg_data           OUT NOCOPY  VARCHAR2
    ,x_msg_count          OUT NOCOPY  NUMBER
    )
IS


     L_API_NAME           CONSTANT VARCHAR2(30) := 'contact_create';
     L_API_VERSION_NUMBER CONSTANT NUMBER   := 1.0;
     l_contact_create_ok VARCHAR(10) := 'TRUE';
     l_sso_enabled VARCHAR2(100);
     l_test_user_return_code VARCHAR2(100);
	l_org_id   NUMBER;
	l_party_site_rec         		HZ_PARTY_SITE_V2PUB.party_site_rec_Type;
        l_update_allowed VARCHAR2(1000) := p_update_flag;
        l_api_version_number   NUMBER   ;
        l_init_msg_list        VARCHAR2(1000);
        l_commit               VARCHAR2(1000);
        l_validation_level     NUMBER  ;
	l_contact_details_rec CONTACT_DETAILS_REC_TYPE := p_contact_details_rec;
        l_contact_output_rec CONTACT_OUTPUT_REC_TYPE;
        l_user_name VARCHAR2(1000):=l_contact_details_rec.user_name;
	l_password VARCHAR2(1000):= l_contact_details_rec.password;
        l_email_id VARCHAR2(1000):= l_contact_details_rec.email_rec.email_address;
	l_partner_party_id NUMBER := l_contact_details_rec.partner_party_id;
        l_party_number NUMBER;
        l_partner_user_rec PV_USER_MGMT_PVT.Partner_User_Rec_type;
	l_person_party_id  NUMBER := l_contact_details_rec.person_party_id ;
   	l_rel_party_id     NUMBER ;
   	l_org_party_id     NUMBER;
        l_org_contact_party_id NUMBER;
        l_rel_id NUMBER;
        l_rel_party_number NUMBER;
        l_user_type_key        VARCHAR(1000):=l_contact_details_rec.User_type;
	l_user_type        VARCHAR(1000);
	l_user_id          NUMBER;
        l_user_type_id     NUMBER;
        l_user_reg_id      NUMBER;
        l_approval_id      NUMBER;
        l_enrollment_id    NUMBER;
        l_enrollment_reg_id NUMBER;
	l_exists_user_name VARCHAR2(1000);
        l_principal_name VARCHAR2(1000);
     -- Other OUT parameters returned by the API.
        l_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);
        l_usertype_resp_id NUMBER;
        l_usertype_app_id NUMBER;
        l_last_update_date VARCHAR2(2000);
        l_gen_password VARCHAR2(2000);
        l_version NUMBER;
	l_pass_length NUMBER;
        l_wf_item_type varchar2(200);
	l_LOGIN_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
	l_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
	--x_usertype_reg_id NUMBER;
	l_respKey varchar2(50) := 'JTF_PENDING_APPROVAL';
	l_status  varchar2(10) := 'PENDING';
	l_application_id  number := 690;
	l_usertype_key varchar2(100);
	l_resp_id NUMBER;
	l_app_id NUMBER;
	l_partner_id NUMBER;
        l_mode VARCHAR(50) := 'CREATE';
	l_party_site_id NUMBER;
	l_contact_point_id NUMBER;
	l_party_site_number VARCHAR2(1000);
	l_cust_acct_role_rec HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;
        l_party_rel_rec	HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
        l_org_contact_rec  	HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
        l_location_id NUMBER;
	l_log_msg  LOG_MESSAGE_TBL_TYPE;
	l_log_count NUMBER:=0;
        l_attr_log_msg LOG_MESSAGE_TBL_TYPE;
        l_attr_status VARCHAR2(100);
	l_partner_cust_acct VARCHAR2(100);
	l_contact_cust_acct VARCHAR2(100);
	l_cust_account_role_id NUMBER;
        l_account_rec	      HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;
        l_organization_rec   HZ_PARTY_V2PUB.organization_rec_type;
        l_cust_profile_rec   HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
        l_cust_account_id NUMBER;
        l_cust_account_number VARCHAR2(1000);
        l_cust_party_id NUMBER;
        l_cust_party_number VARCHAR2(1000);
        l_cust_profile_id NUMBER;
        l_account_number VARCHAR2(100);
	l_party_name VARCHAR2(1000);





   CURSOR user_type_id (user_type VARCHAR2) IS
         select usertype_id ,nvl(approval_id,-1) from JTF_UM_USERTYPES_B where usertype_key=user_type;



   CURSOR enrollment_id (user_type VARCHAR2) IS
         select a.subscription_id from    JTF_UM_USERTYPE_SUBSCRIP a,JTF_UM_SUBSCRIPTIONS_B b,JTF_UM_USERTYPES_B c
         where  a.subscription_id=b.subscription_id
         and c.usertype_key=user_type
         and a.usertype_id=c.usertype_id;

   cursor getLUDFromUserReg(l_user_reg_id VARCHAR2) is
	  select to_char (last_update_date, 'mmddyyyyhh24miss')
	  from jtf_um_usertype_reg
	  where usertype_reg_id = to_number (l_user_reg_id);

   CURSOR CHECK_PARTNER(l_party_id VARCHAR2) IS
          select partner_id, party_name from pv_partner_profiles,hz_parties where partner_party_id=l_party_id and party_id=partner_party_id;

   CURSOR USERTYPE_RESP(user_type VARCHAR2) is select FR.RESPONSIBILITY_ID, UT.APPLICATION_ID, FR.VERSION
		FROM JTF_UM_USERTYPE_RESP UT,
		FND_RESPONSIBILITY_VL FR,
		JTF_UM_USERTYPES_B c
		WHERE c.usertype_key=user_type
		and UT.USERTYPE_ID = c.usertype_id
		AND   FR.APPLICATION_ID  = UT.APPLICATION_ID
		AND   FR.RESPONSIBILITY_KEY = UT.RESPONSIBILITY_KEY
		AND   (UT.EFFECTIVE_END_DATE IS NULL OR UT.EFFECTIVE_END_DATE > SYSDATE)
		AND   UT.EFFECTIVE_START_DATE < SYSDATE;

CURSOR USERTYPE_ROLES(usertype_id NUMBER) IS SELECT PRINCIPAL_NAME
		FROM JTF_UM_USERTYPE_ROLE
		WHERE USERTYPE_ID = usertype_id
		AND   (EFFECTIVE_END_DATE IS NULL OR EFFECTIVE_END_DATE > SYSDATE)
		AND   EFFECTIVE_START_DATE < SYSDATE;

CURSOR GET_PARTNER_CUST_ACCT (l_party_id VARCHAR2) IS

               SELECT CUST_ACCOUNT_ID from hz_cust_Accounts where party_id=l_party_id;

CURSOR GET_CONTACT_CUST_ROLE (l_party_id VARCHAR2) IS

               SELECT CUST_ACCOUNT_ROLE_ID from  hz_cust_account_roles where party_id=l_party_id;


CURSOR  CHECK_RELATIONSHIP_EXIST(p_person_party_id NUMBER, p_partner_party_id NUMBER) IS
select hzrp.party_id from hz_org_contacts hzoc, hz_relationships hzrp
where hzoc.party_relationship_id = hzrp.relationship_id and
hzrp.relationship_code='EMPLOYEE_OF' and
hzrp.subject_id=p_person_party_id and
hzrp.object_id=p_partner_party_id
 and hzrp.start_date <= sysdate
 and (hzrp.end_date is null or hzrp.end_date > sysdate);



CURSOR get_party_id_from_ref(orig_system IN VARCHAR2, orig_system_ref IN VARCHAR2, l_party_type IN VARCHAR2) IS
              SELECT
          	  HZ_PARTIES.PARTY_ID
 	      FROM
    		  HZ_ORIG_SYS_REFERENCES,
    		  HZ_PARTIES
    	      WHERE
    		  HZ_ORIG_SYS_REFERENCES.OWNER_TABLE_ID = HZ_PARTIES.PARTY_ID AND
    		  HZ_PARTIES.PARTY_TYPE = l_party_type AND
    		  HZ_ORIG_SYS_REFERENCES.orig_system = orig_system AND
    		  HZ_ORIG_SYS_REFERENCES.orig_system_reference = orig_system_ref AND
    		  HZ_ORIG_SYS_REFERENCES.owner_table_name = 'HZ_PARTIES' AND
                  HZ_PARTIES.STATUS = 'A';



CURSOR get_party_id_all_data(orig_system IN VARCHAR2, orig_system_ref IN VARCHAR2,l_party_id VARCHAR2, l_party_type IN VARCHAR2) IS
              SELECT
          	  HZ_PARTIES.PARTY_ID
 	      FROM
    		  HZ_ORIG_SYS_REFERENCES,
    		  HZ_PARTIES
    	      WHERE
    		  HZ_ORIG_SYS_REFERENCES.OWNER_TABLE_ID = HZ_PARTIES.PARTY_ID AND
    		  HZ_PARTIES.PARTY_TYPE = l_party_type AND
		  HZ_PARTIES.party_id = l_party_id and
    		  HZ_ORIG_SYS_REFERENCES.orig_system = orig_system AND
    		  HZ_ORIG_SYS_REFERENCES.orig_system_reference = orig_system_ref AND
    		  HZ_ORIG_SYS_REFERENCES.owner_table_name = 'HZ_PARTIES' AND
                  HZ_PARTIES.STATUS = 'A';





CURSOR get_party_id_only_sys(orig_system IN VARCHAR2, l_party_id VARCHAR2, l_party_type IN VARCHAR2) IS
              SELECT
          	  HZ_PARTIES.PARTY_ID
 	      FROM
    		  HZ_ORIG_SYS_REFERENCES,
    		  HZ_PARTIES
    	      WHERE
    		  HZ_ORIG_SYS_REFERENCES.OWNER_TABLE_ID = HZ_PARTIES.PARTY_ID AND
    		  HZ_PARTIES.PARTY_TYPE = l_party_type AND
		  HZ_PARTIES.party_id = l_party_id and
    		  HZ_ORIG_SYS_REFERENCES.orig_system = orig_system AND
    		  HZ_ORIG_SYS_REFERENCES.owner_table_name = 'HZ_PARTIES' AND
                  HZ_PARTIES.STATUS = 'A';


CURSOR get_party_id_only_ref( orig_system_ref IN VARCHAR2,l_party_id VARCHAR2, l_party_type IN VARCHAR2) IS
              SELECT
          	  HZ_PARTIES.PARTY_ID
 	      FROM
    		  HZ_ORIG_SYS_REFERENCES,
    		  HZ_PARTIES
    	      WHERE
    		  HZ_ORIG_SYS_REFERENCES.OWNER_TABLE_ID = HZ_PARTIES.PARTY_ID AND
    		  HZ_PARTIES.PARTY_TYPE = l_party_type AND
		  HZ_PARTIES.party_id = l_party_id and
    		  HZ_ORIG_SYS_REFERENCES.orig_system_reference = orig_system_ref AND
    		  HZ_ORIG_SYS_REFERENCES.owner_table_name = 'HZ_PARTIES' AND
                  HZ_PARTIES.STATUS = 'A';





   CURSOR USER_EXISTS_FOR_CONTACT (l_rel_party_id VARCHAR2) IS
          select user_name from fnd_user where customer_id=l_rel_party_id;

   CURSOR USER_EXISTS_FOR_PERSON (l_person_party_id VARCHAR2) IS
          select user_name from fnd_user where person_party_id=l_person_party_id;


BEGIN


SAVEPOINT contact_create_pvt;

-- dbms_output.put_line('Entered the Contact create API');
l_msg_count:=0;
l_msg_data:= null;
l_contact_create_ok := 'TRUE';
x_contact_output_rec.Prtnr_orig_system:=p_contact_details_rec.Prtnr_orig_system;
x_contact_output_rec.Prtnr_orig_system_reference:=p_contact_details_rec.Prtnr_orig_system_reference;
x_contact_output_rec.partner_party_id:=p_contact_details_rec.partner_party_id;
x_contact_output_rec.Cnt_orig_system:=p_contact_details_rec.Cnt_orig_system;
x_contact_output_rec.Cnt_orig_system_reference:=p_contact_details_rec.Cnt_orig_system_reference;
x_contact_output_rec.person_party_id:=p_contact_details_rec.person_party_id;
x_contact_output_rec.return_status:='NOT_PROCESSED';


/***************** CREATE CONTACT DETAILS ***********************************************/


/***************** GET PARTNER PARTY ID from original system ref ********************************/

if l_partner_party_id is null then


   if p_contact_details_rec.Prtnr_orig_system is null OR p_contact_details_rec.Prtnr_orig_system_reference is null then
        l_contact_create_ok:= 'FALSE';
        fnd_message.set_name('PV', 'PV_INVALID_PARTNER_ORG_REF');
        l_log_count:= l_log_count + 1;
        l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
   else
        OPEN get_party_id_from_ref(p_contact_details_rec.Prtnr_orig_system, p_contact_details_rec.Prtnr_orig_system_reference,'ORGANIZATION'  ) ;
        FETCH get_party_id_from_ref INTO l_partner_party_id;
        CLOSE get_party_id_from_ref;
   end if;


elsif l_partner_party_id is not null then

   if p_contact_details_rec.Prtnr_orig_system is not null and p_contact_details_rec.Prtnr_orig_system_reference is not null then
        OPEN get_party_id_all_data(p_contact_details_rec.Prtnr_orig_system, p_contact_details_rec.Prtnr_orig_system_reference ,l_partner_party_id,'ORGANIZATION' ) ;
        FETCH get_party_id_all_data INTO l_partner_party_id;
        CLOSE get_party_id_all_data;

   elsif p_contact_details_rec.Prtnr_orig_system is not null then
        OPEN get_party_id_only_sys(p_contact_details_rec.Prtnr_orig_system, l_partner_party_id ,'ORGANIZATION') ;
        FETCH get_party_id_only_sys INTO l_partner_party_id;
        CLOSE get_party_id_only_sys;

   elsif p_contact_details_rec.Prtnr_orig_system_reference is not null then
        OPEN get_party_id_only_ref(p_contact_details_rec.Prtnr_orig_system_reference, l_partner_party_id,'ORGANIZATION' ) ;
        FETCH get_party_id_only_ref INTO l_partner_party_id;
        CLOSE get_party_id_only_ref;


   end if;



end if;


/****************** End get party id ****************************************************/

-- dbms_output.put_line('Partner Party ID is '|| l_partner_party_id);

/***************** GET PERSON PARTY ID from original system ref ********************************/

if l_person_party_id is null then


   if p_contact_details_rec.Cnt_orig_system is null OR p_contact_details_rec.Cnt_orig_system_reference is null then
        l_contact_create_ok:= 'FALSE';
        fnd_message.set_name('PV', 'PV_INVALID_CONTACT_REF');
        l_log_count:= l_log_count + 1;
        l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
   else
        OPEN get_party_id_from_ref(p_contact_details_rec.Cnt_orig_system, p_contact_details_rec.Cnt_orig_system_reference,'PERSON'  ) ;
        FETCH get_party_id_from_ref INTO l_person_party_id;
        CLOSE get_party_id_from_ref;
   end if;


elsif l_person_party_id is not null then

   if p_contact_details_rec.Cnt_orig_system is not null and p_contact_details_rec.Cnt_orig_system_reference is not null then
        OPEN get_party_id_all_data(p_contact_details_rec.Cnt_orig_system, p_contact_details_rec.Cnt_orig_system_reference ,l_person_party_id,'PERSON' ) ;
        FETCH get_party_id_all_data INTO l_person_party_id;
        CLOSE get_party_id_all_data;

   elsif p_contact_details_rec.Cnt_orig_system is not null then
        OPEN get_party_id_only_sys(p_contact_details_rec.Cnt_orig_system, l_person_party_id ,'PERSON') ;
        FETCH get_party_id_only_sys INTO l_person_party_id;
        CLOSE get_party_id_only_sys;

   elsif p_contact_details_rec.Cnt_orig_system_reference is not null then
        OPEN get_party_id_only_ref(p_contact_details_rec.Cnt_orig_system_reference, l_person_party_id,'PERSON' ) ;
        FETCH get_party_id_only_ref INTO l_person_party_id;
        CLOSE get_party_id_only_ref;


   end if;



end if;

/****************** End get party id ****************************************************/
-- dbms_output.put_line('Person Party ID is '|| l_person_party_id);



if l_partner_party_id is null then
      l_contact_create_ok:= 'FALSE';
      fnd_message.set_name('PV', 'PV_INVALID_PARTNER_ORG_REF');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

END IF;

if l_person_party_id is null then
      l_contact_create_ok:= 'FALSE';
      fnd_message.set_name('PV', 'PV_INVALID_CONTACT_REF');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
END IF;


-- dbms_output.put_line('Check if partner exists');

   OPEN CHECK_PARTNER(l_partner_party_id) ;
   FETCH CHECK_PARTNER INTO l_partner_id,l_party_name;
   CLOSE CHECK_PARTNER;


if l_partner_id is null then
      l_contact_create_ok:= 'FALSE';
      fnd_message.set_name('PV', 'PV_MISSING_PARTNER_ID');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

END IF;

-- dbms_output.put_line('Before check relationship');


   OPEN CHECK_RELATIONSHIP_EXIST(l_person_party_id,l_partner_party_id) ;
   FETCH CHECK_RELATIONSHIP_EXIST INTO l_rel_party_id;
   CLOSE CHECK_RELATIONSHIP_EXIST;

-- dbms_output.put_line('after check relationship' || l_rel_party_id);

if(l_rel_party_id is not NULL ) THEN
       l_mode:='UPDATE';
END IF;


if l_mode='CREATE' then

if p_contact_details_rec.email_rec.email_address is null then
      l_contact_create_ok:= 'FALSE';
      fnd_message.set_name('PV', 'PV_MISSING_EMAIL_ID');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

END IF;


if p_contact_details_rec.business_phone_rec.phone_number is null then
      l_contact_create_ok:= 'FALSE';
      fnd_message.set_name('PV', 'PV_MISSING_PHONE');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

END IF;

end if;

if l_contact_create_ok = 'FALSE' THEN
        x_contact_output_rec.return_status:='ERROR';
	x_log_msg:= l_log_msg;
        RETURN;
END IF;






-- dbms_output.put_line('Mode = ' || l_mode);
-- dbms_output.put_line('l_update_allowed = ' || l_update_allowed);

if l_mode = 'UPDATE' and l_update_allowed =  FND_API.G_FALSE then
	l_contact_create_ok:= 'FALSE';
        fnd_message.set_name('PV', 'PV_CONTACT_EXISTS_ALREADY');
        l_log_count:= l_log_count + 1;
        l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

	x_contact_output_rec.return_status:='ERROR';
	x_log_msg:=l_log_msg;
	RETURN;
end if;

if l_rel_party_id is null then

       l_party_rel_rec.subject_id := l_person_party_ID;
       l_party_rel_rec.subject_type :=  'PERSON';
       l_party_rel_rec.subject_table_name :=  'HZ_PARTIES';

      -- pass organization_party_id as object_id
       l_party_rel_rec.object_id :=  l_partner_party_ID;
       l_party_rel_rec.object_type :=  'ORGANIZATION';
       l_party_rel_rec.object_table_name :=  'HZ_PARTIES';

       l_party_rel_rec.relationship_type :=  'EMPLOYMENT';
       l_party_rel_rec.relationship_code :=  'EMPLOYEE_OF';

       l_party_rel_rec.start_date:=  sysdate;
       l_party_rel_rec.created_by_module := 'PV';
       l_party_rel_rec.application_id    := 691;

       l_org_contact_rec.party_rel_rec  :=  l_party_rel_rec;
       l_org_contact_rec.created_by_module := 'PV';
       l_org_contact_rec.application_id    := 691;


       HZ_PARTY_CONTACT_V2PUB.create_org_contact (
        	p_org_contact_rec => l_org_contact_rec,
        	x_org_contact_id =>  l_org_contact_party_id,
        	x_party_rel_id =>  l_rel_id,
        	x_party_id =>  l_rel_party_id,
        	x_party_number =>  l_rel_party_number,
        	x_return_status =>  l_return_status,
        	x_msg_count =>  l_msg_count,
        	x_msg_data =>  l_msg_data);

     -- dbms_output.put_line('after create org contact' || l_rel_party_id);
     -- dbms_output.put_line('after create org contact status' || l_return_status);




     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';


         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
/*            FOR l_msg_index IN 1..l_msg_count LOOP
		    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
		    -- dbms_output.put_line(fnd_message.get);
		    l_log_count:= l_log_count + 1;
		    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
            END LOOP;
*/

            l_log_count:= l_log_count + 1;
	    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_count));
            l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);


         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_PARTY_CONTACT_V2PUB.create_org_contact');
            l_log_count:= l_log_count + 1;
	    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
         END IF;





      END IF;








/**************CREATE LOCATION ******************************************************/


if ( l_contact_details_rec.location_rec.address1 is not null and l_contact_details_rec.location_rec.country is not null) then

    l_contact_details_rec.location_rec.created_by_module:='PV';
    l_contact_details_rec.location_rec.application_id:=691;

   HZ_LOCATION_V2PUB.create_location (
    p_init_msg_list                    =>FND_API.g_false,
    p_location_rec                     =>l_contact_details_rec.location_rec,
    x_location_id                      =>l_location_id,
    x_return_status                    =>l_return_status,
    x_msg_count                        =>l_msg_count,
    x_msg_data                         =>l_msg_data
   );



     -- dbms_output.put_line('after create location' || l_location_id);
     -- dbms_output.put_line('after create location' || l_return_status);



     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            FOR l_msg_index IN 1..l_msg_count LOOP
		    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
		    -- dbms_output.put_line(fnd_message.get);
		    l_log_count:= l_log_count + 1;
		    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
            END LOOP;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_LOCATION_V2PUB.create_location');
            l_log_count:= l_log_count + 1;
	    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
         END IF;
      END IF;


    l_party_site_rec.party_id:=l_rel_party_id;
    l_party_site_rec.location_id:=l_location_id;
    l_party_site_rec.created_by_module:='PV';
    l_party_site_rec.application_id:=691;
    l_party_site_rec.identifying_address_flag:='Y';
    l_party_site_rec.status:='A';



    HZ_PARTY_SITE_V2PUB.create_party_site (
    p_init_msg_list          =>FND_API.g_false,
    p_party_site_rec         =>l_party_site_rec,
    x_party_site_id          =>l_party_site_id,
    x_party_site_number      =>l_party_site_number,
    x_return_status          =>l_return_status,
    x_msg_count              =>l_msg_count,
    x_msg_data               =>l_msg_data
);


     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            FOR l_msg_index IN 1..l_msg_count LOOP
		    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
		    -- dbms_output.put_line(fnd_message.get);
		    l_log_count:= l_log_count + 1;
		    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
            END LOOP;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_PARTY_SITE_V2PUB.create_party_site');
            l_log_count:= l_log_count + 1;
	    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
         END IF;
      END IF;


     -- dbms_output.put_line('after create party site' || l_party_site_id);
     -- dbms_output.put_line('after create party site' || l_return_status);


END IF; -- address1 and country are passed.

/****************END LOCATION *******************************************************/




/********************CREATE PHONE CONTACT POINT *************************************/






      l_contact_details_rec.phone_contact_point_rec.status := 'A';
      l_contact_details_rec.phone_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_details_rec.phone_contact_point_rec.owner_table_id := l_rel_party_id;
      l_contact_details_rec.phone_contact_point_rec.created_by_module := 'PV';
      l_contact_details_rec.phone_contact_point_rec.application_id := 691;
      l_contact_details_rec.phone_contact_point_rec.primary_flag :='Y';
      l_contact_details_rec.phone_contact_point_rec.contact_point_purpose := 'BUSINESS';


          HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
                       p_contact_point_rec => l_contact_details_rec.phone_contact_point_rec,
                       p_phone_rec => l_contact_details_rec.business_phone_rec,
                       x_contact_point_id => l_contact_point_id,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data  => l_msg_data );




     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            FOR l_msg_index IN 1..l_msg_count LOOP
		    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
--		    -- dbms_output.put_line('Printing first time' || fnd_message.get);
		    l_log_count:= l_log_count + 1;
--		    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
		    l_log_msg(l_log_count):=fnd_message.get;
                    -- dbms_output.put_line('printing log ' || l_log_msg(l_log_count));
            END LOOP;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_CONTACT_POINT_V2PUB.create_phone_contact_point');
            l_log_count:= l_log_count + 1;
	    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
         END IF;
      END IF;

     -- dbms_output.put_line('after create phone' || l_contact_point_id);
     -- dbms_output.put_line('after create phone' || l_return_status);

/*********************END PHONE CONTACT POINT ******************************************/





/*********************CREATE EMAIL CONTACT POINT ***************************************/



      l_contact_details_rec.email_contact_point_rec.status := 'A';
      l_contact_details_rec.email_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_details_rec.email_contact_point_rec.owner_table_id := l_rel_party_id;
      l_contact_details_rec.email_contact_point_rec.created_by_module := 'PV';
      l_contact_details_rec.email_contact_point_rec.application_id := 691;
      l_contact_details_rec.email_contact_point_rec.primary_flag :='Y';
      l_contact_details_rec.email_contact_point_rec.contact_point_type :='EMAIL';
      l_contact_details_rec.email_contact_point_rec.contact_point_purpose :='';


          HZ_CONTACT_POINT_V2PUB.create_email_contact_point (
                       p_contact_point_rec => l_contact_details_rec.email_contact_point_rec,
                       p_email_rec => l_contact_details_rec.email_rec,
                       x_contact_point_id => l_contact_point_id,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data  => l_msg_data );


     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            FOR l_msg_index IN 1..l_msg_count LOOP
		    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
		    -- dbms_output.put_line(fnd_message.get);
		    l_log_count:= l_log_count + 1;
		    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
            END LOOP;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_CONTACT_POINT_V2PUB.create_email_contact_point');
            l_log_count:= l_log_count + 1;
	    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
         END IF;
      END IF;

     -- dbms_output.put_line('after create email' || l_contact_point_id);
     -- dbms_output.put_line('after create email' || l_return_status);

/**********************END EMAIL CONTACT POINT ******************************************/





END IF;   --END OF CREATE MODE FOR RELATIONSHIP


/********************************CREATE CUST Account Role **********************************/



-- dbms_output.put_line('Partner party id before cust account is ' || l_partner_party_id);

   OPEN GET_PARTNER_CUST_ACCT(l_partner_party_id) ;
   FETCH GET_PARTNER_CUST_ACCT INTO l_partner_cust_acct;
   CLOSE GET_PARTNER_CUST_ACCT;




   OPEN GET_CONTACT_CUST_ROLE(l_rel_party_id) ;
   FETCH GET_CONTACT_CUST_ROLE INTO l_contact_cust_acct;
   CLOSE GET_CONTACT_CUST_ROLE;

-- dbms_output.put_line('Partner party cust account' || l_partner_cust_acct);



   OPEN GET_PARTNER_CUST_ACCT(l_partner_id) ;
   FETCH GET_PARTNER_CUST_ACCT INTO l_partner_cust_acct;
   CLOSE GET_PARTNER_CUST_ACCT;


-- dbms_output.put_line('Partner cust account' || l_partner_cust_acct);








if l_partner_cust_acct is null then
    l_account_rec.Created_by_Module := 'PV';
    l_account_rec.application_id := 691;
    l_organization_rec.Created_by_Module := 'PV';
    l_organization_rec.application_id := 691;
    l_cust_profile_rec.Created_by_Module := 'PV';
    l_cust_profile_rec.application_id := 691;
    l_account_rec.account_name := l_party_name;
    l_organization_rec.party_rec.party_id := l_partner_party_id;



-- dbms_output.put_line('Just before the Partner cust account API' );

     HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
      p_init_msg_list                         => FND_API.G_TRUE,
      p_cust_account_rec                      => l_account_rec,
      p_organization_rec                      => l_organization_rec,
      p_customer_profile_rec                  => l_cust_profile_rec,
      p_create_profile_amt                    => FND_API.G_TRUE,
      x_cust_account_id                       => l_partner_cust_acct,
      x_account_number                        => l_account_number,
      x_party_id                              => l_cust_party_id	,
      x_party_number                          => l_cust_party_number,
      x_profile_id                            => l_cust_profile_id,
      x_return_status                         => l_return_status,
      x_msg_count                             => l_msg_count,
      x_msg_data                              => l_msg_data  );



     -- dbms_output.put_line('Partner cust account Return status' || l_return_status);
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            FOR l_msg_index IN 1..l_msg_count LOOP
		    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
		    -- dbms_output.put_line(fnd_message.get);
		    l_log_count:= l_log_count + 1;
		    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
            END LOOP;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_CONTACT_POINT_V2PUB.create_email_contact_point');
            l_log_count:= l_log_count + 1;
	    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
         END IF;
      END IF;





end if;






if l_contact_cust_acct is null and l_partner_cust_acct is not null then

       l_cust_acct_role_rec.party_id:=l_rel_party_id;
       l_cust_acct_role_rec.cust_account_id:= l_partner_cust_acct;
       l_cust_acct_role_rec.role_type:='CONTACT';
       l_cust_acct_role_rec.primary_flag:='N';
       l_cust_acct_role_rec.created_by_module:='PV';



     HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role (
        p_init_msg_list      =>'T',
        p_cust_account_role_rec  => l_cust_acct_role_rec,
        x_cust_account_role_id  =>l_cust_account_role_id,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data  => l_msg_data );


     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            FOR l_msg_index IN 1..l_msg_count LOOP
		    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
		    -- dbms_output.put_line(fnd_message.get);
		    l_log_count:= l_log_count + 1;
		    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
            END LOOP;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role');
            l_log_count:= l_log_count + 1;
	    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
         END IF;
      END IF;


end if ; -- Create contact cust account.

/******************************** END CREATE CUST Account Role **********************************/


/************************************************************* CREATE ATTRIBUTES *****************************************************/


-- dbms_output.put_line('before attributes');

if(l_contact_details_rec.attribute_details_tbl.count > 0 ) then

		PV_CONTACT_USER_BATCH_PUB.upsert_attributes(
		     p_api_version_number  =>1.0
		    ,p_init_msg_list      =>'T'
		    ,p_commit             =>'F'
		    ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
		    ,p_attr_details_tbl   => l_contact_details_rec.attribute_details_tbl
		    ,p_contact_rel_id     => l_rel_party_id
		    ,x_log_msg            => l_attr_log_msg
		    ,x_attribute_creation_status => l_attr_status
		);

end if;


-- dbms_output.put_line('just after attributes ' ||l_attr_status );


     IF (l_attr_status = 'ERROR') THEN
         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';

            FOR l_msg_index IN 1..l_attr_log_msg.LAST LOOP
		    l_log_count:= l_log_count + 1;
		    l_log_msg(l_log_count):=l_attr_log_msg(l_msg_index);
            END LOOP;
      END IF;
-- dbms_output.put_line('after logging attributes');




/************************************************************** END CREATE ATTRIBUTES ***********************************************/















-- dbms_output.put_line('user name not null check ');
if(l_contact_details_rec.user_name is not null) THEN

/**************** CHECK FOR SSO ************************************************************************/
  l_sso_enabled := fnd_profile.value('APPS_SSO_USER_CREATE_UPDATE');
  if l_sso_enabled = 'N' OR l_sso_enabled = 'FTTT' OR l_sso_enabled = 'FFFF'   then
        l_contact_create_ok:= 'FALSE';
	x_contact_output_rec.return_status:='ERROR';
        fnd_message.set_name('PV', 'PV_SSO_CREATE_USER_NOT_ALLOWED');
        l_log_count:= l_log_count + 1;
        l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

  end if;

-- dbms_output.put_line('after sso check ');

/**************** CHECK IF USER EXISTS ALREADY FOR CONTACT ************************************************************************/


   l_exists_user_name:= null;
   OPEN USER_EXISTS_FOR_CONTACT(l_rel_party_id) ;
   FETCH USER_EXISTS_FOR_CONTACT INTO l_exists_user_name;
   CLOSE USER_EXISTS_FOR_CONTACT;

if l_mode = 'UPDATE' and l_update_allowed =  FND_API.G_FALSE then

   if l_exists_user_name is not null then
        l_contact_create_ok:= 'FALSE';
	x_contact_output_rec.return_status:='ERROR';
        fnd_message.set_name('PV', 'PV_CONTACT_USER_EXISTS');
        l_log_count:= l_log_count + 1;
        l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);


   end if;

elsif l_mode ='UPDATE' and l_update_allowed =FND_API.G_TRUE then

     if l_contact_details_rec.user_name <> l_exists_user_name then
        l_contact_create_ok:= 'FALSE';
	x_contact_output_rec.return_status:='ERROR';
        fnd_message.set_name('PV', 'PV_USER_DIFFERENT');
        l_log_count:= l_log_count + 1;
        l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
     end if;
end if;
-- dbms_output.put_line('after user exists for contact check ');

/**************** CHECK IF USER TYPE IS PASSED ************************************************************************/

-- dbms_output.put_line('after user type check ');

   l_user_type:=l_contact_details_rec.user_type;

   if l_user_type is null then
        l_contact_create_ok:= 'FALSE';
	x_contact_output_rec.return_status:='ERROR';

      fnd_message.set_name('PV', 'PV_USER_TYPE_REQUIRED');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
   end if;

-- dbms_output.put_line('after user type check ');


/**********************TEST USER NAME ***********************************************************************************/

-- dbms_output.put_line('Test user name');
if l_update_allowed =  FND_API.G_FALSE OR l_mode='CREATE' then

l_test_user_return_code := FND_USER_PKG.TestUserName(l_contact_details_rec.user_name);
if l_test_user_return_code = 1 then
      l_contact_create_ok:= 'FALSE';
      x_contact_output_rec.return_status:='ERROR';
      fnd_message.set_name('FND','INVALID_USER_NAME');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

elsif  l_test_user_return_code = 2 then
      l_contact_create_ok:= 'FALSE';
      x_contact_output_rec.return_status:='ERROR';
      fnd_message.set_name('FND','FND_USER_EXISTS_IN_FND');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

elsif  l_test_user_return_code = 4 then
      l_contact_create_ok:= 'FALSE';
      x_contact_output_rec.return_status:='ERROR';
      fnd_message.set_name('FND','FND_USER_EXISTS_NO_LINK');
      l_log_count:= l_log_count + 1;
      l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);

 end if;
end if;

/************************END TEST USER NAME *****************************************************************************/






/**************** IF ANYTHING HAS FAILED SO FAR ROLLBACK ************************************************************************/

   if l_contact_create_ok= 'FALSE' then
      x_contact_output_rec.return_status:='ERROR';
      -- dbms_output.put_line('going to rollback ');
      ROLLBACK TO contact_create_pvt;
      x_log_msg:=l_log_msg;
      RETURN;
   end if;


-- dbms_output.put_line('user type =  ' || l_user_type);



if l_exists_user_name is null then
   l_password:= l_contact_details_rec.password;
   PV_CONTACT_USER_BATCH_PUB.user_create (
     p_api_version_number  =>1.0
    ,p_init_msg_list      =>'T'
    ,p_commit             =>'F'
    ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    ,p_user_name => l_contact_details_rec.user_name
    ,p_password => l_password
    ,p_user_type_key =>l_user_type
    ,p_contact_rel_id =>l_rel_party_id
    ,x_return_status =>    l_return_status
    ,x_msg_data      =>    l_msg_data
    ,x_msg_count     =>    l_msg_count
    ) ;

else

    PV_CONTACT_USER_BATCH_PUB.user_update (
	     p_api_version_number  =>1.0
	    ,p_init_msg_list       => FND_API.G_TRUE
	    ,p_commit              => FND_API.G_FALSE
	    ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
	    ,p_user_name =>      l_contact_details_rec.user_name
	    ,p_user_type_key => l_user_type
	    ,p_contact_rel_id =>  l_rel_party_id
	    ,x_return_status => l_return_status
	    ,x_msg_data      => l_msg_data
	    ,x_msg_count     => l_msg_count

	    );

end if;
-- dbms_output.put_line('after user creation ' || l_return_status);


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         l_contact_create_ok := 'FALSE';
         x_contact_output_rec.return_status:='ERROR';
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            FOR l_msg_index IN 1..l_msg_count LOOP
		    fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
		    -- dbms_output.put_line(fnd_message.get);
		    l_log_count:= l_log_count + 1;
		    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
            END LOOP;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_CONTACT_USER_BATCH_PUB.user_create');
            l_log_count:= l_log_count + 1;
	    l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
         END IF;
      END IF;


END IF ; --- USER CREATION ENDS




if l_contact_create_ok= 'FALSE' THEN
rollback to contact_create_pvt;
ELSE
x_contact_rel_id:= l_rel_party_id;
x_return_status:= FND_API.G_RET_STS_SUCCESS;
x_contact_output_rec.contact_rel_party_id:=l_rel_party_id;
x_contact_output_rec.return_status:='SUCCESS';
x_contact_output_rec.user_name:=l_contact_details_rec.user_name;
x_contact_output_rec.password:=l_password;
        fnd_message.set_name('PV', 'PV_CONTACT_USER_SUCCESS');
        l_log_count:= l_log_count + 1;
        l_log_msg(l_log_count):=substrb(fnd_message.get, 1, 1000);
END IF;

x_log_msg:=l_log_msg;
RETURN;

 EXCEPTION


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     l_contact_create_ok := 'FALSE';
     x_contact_output_rec.return_status:='ERROR';
     ROLLBACK TO contact_create_pvt;
     x_log_msg:=l_log_msg;
     RETURN;
   WHEN OTHERS THEN
     l_contact_create_ok:= 'FALSE';
     x_contact_output_rec.return_status:='ERROR';
     ROLLBACK TO contact_create_pvt;
     x_log_msg:=l_log_msg;
     RETURN;
 END contact_create;








PROCEDURE user_create (
     p_api_version_number  IN  NUMBER
    ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
    ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
    ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,p_user_name IN VARCHAR2
    ,p_password IN OUT NOCOPY VARCHAR2
    ,p_user_type_key IN VARCHAR2
    ,p_contact_rel_id IN NUMBER
    ,x_return_status      OUT NOCOPY  VARCHAR2
    ,x_msg_data           OUT NOCOPY  VARCHAR2
    ,x_msg_count          OUT NOCOPY  NUMBER
    ) IS

     L_API_NAME           CONSTANT VARCHAR2(30) := 'user_create';
     L_API_VERSION_NUMBER CONSTANT NUMBER   := 1.0;




        l_api_version_number   NUMBER   ;
        l_init_msg_list        VARCHAR2(1000);
        l_commit               VARCHAR2(1000);
        l_validation_level     NUMBER  ;
        l_password_date        DATE;
        l_user_name VARCHAR2(1000):=p_user_name;
	l_password VARCHAR2(1000):= p_password;
	l_contact_rel_id NUMBER :=p_contact_rel_id;
        l_user_type_key        VARCHAR2(1000):=p_user_type_key;
--        l_user_language VARCHAR2(1000) := p_user_language;

        l_partner_id NUMBER;
	l_partner_group_id NUMBER;
	l_person_first_name VARCHAR2(1000);
	l_approval_id NUMBER;
	l_enrollment_id NUMBER;
	l_enrollment_reg_id NUMBER;
	l_person_last_name VARCHAR2(1000);
	l_org_contact_id NUMBER;
	l_party_name VARCHAR2(1000);
	l_email_address VARCHAR2(1000);




	l_partner_party_id NUMBER;
	l_contact_party_id NUMBER;

        l_partner_user_rec PV_USER_MGMT_PVT.Partner_User_Rec_type;
	l_person_party_id  NUMBER ;
   	l_rel_party_id     NUMBER ;
   	l_org_party_id     NUMBER;
        l_org_contact_party_id NUMBER;
        l_rel_id NUMBER;
        l_rel_party_number NUMBER;

	l_user_id          NUMBER;
        l_user_type_id     NUMBER;
        l_user_reg_id      NUMBER;
        l_principal_name VARCHAR2(1000);
     -- Other OUT parameters returned by the API.
        l_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);
        l_usertype_resp_id NUMBER;
        l_usertype_app_id NUMBER;
        l_last_update_date VARCHAR2(2000);
        l_gen_password VARCHAR2(2000);
        l_version NUMBER;
	l_pass_length NUMBER;

        l_sso_enabled VARCHAR2(100);
	l_respKey varchar2(50) := 'JTF_PENDING_APPROVAL';
	l_status  varchar2(10) := 'PENDING';
	l_application_id  number := 690;
	l_usertype_key varchar2(100);
	l_resp_id NUMBER;
	l_contact_exist_id NUMBER;
	l_app_id NUMBER;

	l_relationship_code VARCHAR2(1000);
	l_party_status VARCHAR2(1000);


        l_party_rel_rec	HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
        l_org_contact_rec  	HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;

   CURSOR user_type_id (user_type VARCHAR2) IS
         select usertype_id ,nvl(approval_id,-1) from JTF_UM_USERTYPES_B where usertype_key=user_type;

   CURSOR enrollment_id (user_type VARCHAR2) IS
         select a.subscription_id from    JTF_UM_USERTYPE_SUBSCRIP a,JTF_UM_SUBSCRIPTIONS_B b,JTF_UM_USERTYPES_B c
         where  a.subscription_id=b.subscription_id
         and c.usertype_key=user_type
         and a.usertype_id=c.usertype_id;

   cursor getLUDFromUserReg(l_user_reg_id VARCHAR2) is
	  select to_char (last_update_date, 'mmddyyyyhh24miss')
	  from jtf_um_usertype_reg
	  where usertype_reg_id = to_number (l_user_reg_id);

   CURSOR CHECK_PARTNER(l_party_id VARCHAR2) IS
          select partner_id from pv_partner_profiles where partner_party_id=l_party_id;




   CURSOR USERTYPE_RESP(user_type VARCHAR2) is select FR.RESPONSIBILITY_ID, UT.APPLICATION_ID, FR.VERSION
		FROM JTF_UM_USERTYPE_RESP UT,
		FND_RESPONSIBILITY_VL FR,
		JTF_UM_USERTYPES_B c
		WHERE c.usertype_key=user_type
		and UT.USERTYPE_ID = c.usertype_id
		AND   FR.APPLICATION_ID  = UT.APPLICATION_ID
		AND   FR.RESPONSIBILITY_KEY = UT.RESPONSIBILITY_KEY
		AND   (UT.EFFECTIVE_END_DATE IS NULL OR UT.EFFECTIVE_END_DATE > SYSDATE)
		AND   UT.EFFECTIVE_START_DATE < SYSDATE;

CURSOR USERTYPE_ROLES(usertype_id NUMBER) IS SELECT PRINCIPAL_NAME
		FROM JTF_UM_USERTYPE_ROLE
		WHERE USERTYPE_ID = usertype_id
		AND   (EFFECTIVE_END_DATE IS NULL OR EFFECTIVE_END_DATE > SYSDATE)
		AND   EFFECTIVE_START_DATE < SYSDATE;


CURSOR get_relationship_code(rel_party_id NUMBER) IS
   select relationship_code from hz_relationships hzr where hzr.party_id=rel_party_id and hzr.directional_flag='F';


CURSOR get_status(rel_party_id NUMBER) IS
   select hzp.status from hz_parties hzp where hzp.party_id=rel_party_id ;


CURSOR get_email_address(rel_party_id NUMBER) IS
   select email_address from hz_parties hzp where hzp.party_id=rel_party_id ;




cursor get_contact_details(rel_party_id NUMBER) IS
   select pvpp.partner_id, pvpp.PARTNER_GROUP_ID , person_hzp.PERSON_FIRST_NAME, person_hzp.person_last_name,
   hzoc.org_contact_id, org_hzp.party_name, rel_hzp.email_address
   from HZ_PARTIES PERSON_HZP, HZ_RELATIONSHIPS HZR, PV_PARTNER_PROFILES pvpp, hz_org_contacts hzoc, HZ_PARTIES ORG_HZP,
   hz_parties REL_HZP
   where HZR.party_id = rel_party_id
   and HZR.directional_flag = 'F'
   and hzr.relationship_code = 'EMPLOYEE_OF'
   and HZR.subject_table_name ='HZ_PARTIES'
   and HZR.object_table_name ='HZ_PARTIES'
   and hzr.start_date <= SYSDATE
   and (hzr.end_date is null or hzr.end_date > SYSDATE)
   and hzr.status = 'A'
   and hzr.subject_id = person_hzp.party_id
   and person_hzp.status = 'A'
   and hzr.object_id = pvpp.partner_party_id
   and pvpp.partner_group_id is not null
   and hzoc.PARTY_RELATIONSHIP_ID = hzr.relationship_id
   and hzr.object_id = org_hzp.party_id and
   rel_hzp.party_id=hzr.party_id;

CURSOR CHECK_CONTACT(rel_party_id VARCHAR2) is
   select hzr.subject_id from hz_parties rel,hz_relationships hzr ,pv_partner_profiles pvpp
   where rel.party_id=rel_party_id and
         hzr.party_id=rel.party_id and
         hzr.relationship_code in ('EMPLOYEE_OF' ) and
	 hzr.object_id=pvpp.partner_party_id;


cursor resp_list(l_usertype_id VARCHAR2) is
 select responsibility_id, application_id
 from fnd_responsibility
 where responsibility_key in
 (select responsibility_key
         from  jtf_um_usertype_resp jtur
         where  jtur.usertype_id = l_usertype_id
         and  (jtur.effective_end_date is null or jtur.effective_end_date >  sysdate)
         union
         select responsibility_key
         from jtf_um_usertype_subscrip jtus, jtf_um_subscription_resp jtsr
         where  jtus.usertype_id = l_usertype_id
         and (jtus.effective_end_date is null or jtus.effective_end_date >  sysdate)
         and jtus.subscription_flag = 'IMPLICIT'
         and jtus.subscription_id = jtsr.subscription_id
         and (jtsr.effective_end_date is null or jtsr.effective_end_date >  sysdate));

cursor role_list(l_usertype_id VARCHAR2)  is
     select principal_name
         from  jtf_um_usertype_role jtur
         where  jtur.usertype_id = l_usertype_id
         and  (jtur.effective_end_date is null or jtur.effective_end_date >  sysdate)
         union
         select jtsr.principal_name
         from jtf_um_usertype_subscrip jtus, jtf_um_subscription_role jtsr
         where  jtus.usertype_id = l_usertype_id
	 and (jtus.effective_end_date is null or jtus.effective_end_date >  sysdate)
         and jtus.subscription_flag = 'IMPLICIT'
         and jtus.subscription_id = jtsr.subscription_id
         and (jtsr.effective_end_date is null or jtsr.effective_end_date >  sysdate);

   CURSOR get_user_id(l_user_name VARCHAR2) is
         select user_id from fnd_user where user_name=l_user_name;


BEGIN

savepoint user_create_pvt;

-- dbms_output.put_line('l_contact_rel_id ' || l_contact_rel_id);




if l_contact_rel_id is null then
          fnd_message.SET_NAME  ('PV', 'PV_CONTACT_ID_INVALID');
          fnd_msg_pub.ADD;
          raise FND_API.G_EXC_ERROR;
END IF;


   OPEN CHECK_CONTACT(l_contact_rel_id) ;
   FETCH CHECK_CONTACT INTO l_contact_party_id;
   CLOSE CHECK_CONTACT;


if l_contact_party_id is null then
      fnd_message.SET_NAME  ('PV', 'PV_CONTACT_ID_INVALID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

END IF;



if l_user_name is null then
      fnd_message.SET_NAME  ('PV', 'PV_USER_NAME_MISSING');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

END IF;

-- dbms_output.put_line('after user name check');



/**************** CHECK FOR SSO ************************************************************************/
  l_sso_enabled := fnd_profile.value('APPS_SSO_USER_CREATE_UPDATE');
  if l_sso_enabled = 'N' OR l_sso_enabled = 'FTTT' OR l_sso_enabled = 'FFFF' then
        fnd_message.set_name('PV', 'PV_SSO_CREATE_USER_NOT_ALLOWED');
        fnd_msg_pub.ADD;
        raise FND_API.G_EXC_ERROR;
  end if;

-- dbms_output.put_line('after sso check ');

/**************** CHECK IF USER EXISTS ALREADY FOR CONTACT ************************************************************************/






   OPEN get_relationship_code(l_contact_rel_id);
   FETCH get_relationship_code INTO l_relationship_code;
   CLOSE get_relationship_code;





if l_relationship_code is null or l_relationship_code <> 'EMPLOYEE_OF' then
      fnd_message.SET_NAME  ('PV', 'PV_NOT_EMPLOYEE_REL');
      fnd_msg_pub.ADD;
   RAISE FND_API.G_EXC_ERROR;
END IF;

-- dbms_output.put_line('After relationship check');




   OPEN get_status(l_contact_rel_id);
   FETCH get_status INTO l_party_status;
   CLOSE get_status;

-- dbms_output.put_line('before party status check');

if l_party_status is null or l_party_status <> 'A' then
      fnd_message.SET_NAME  ('PV', 'PV_CONTACT_NOT_ACTIVE');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;

END IF;


-- dbms_output.put_line('BEFORE email address check');

   OPEN get_email_address(l_contact_rel_id);
   FETCH get_email_address INTO l_email_address;
   CLOSE get_email_address;

-- dbms_output.put_line('After email address check1' || l_email_address);






-- dbms_output.put_line('After email address check2' || l_email_address);

if l_email_address is null or l_email_address='' then
   l_return_status:='E';
   l_msg_count:=1;
   l_msg_data:='PV_EMAIL_ID_NEEDED';
   RAISE FND_API.G_EXC_ERROR;
END IF;


-- dbms_output.put_line('BEFORE get contact details');

   OPEN get_contact_details(l_contact_rel_id);
   FETCH get_contact_details INTO l_partner_id, l_PARTNER_GROUP_ID , l_PERSON_FIRST_NAME, l_person_last_name,    l_org_contact_id, l_party_name, l_email_address;
   CLOSE get_contact_details;











-- dbms_output.put_line('user name not null check ' || l_user_name);
if(l_user_name is not null) THEN




-- dbms_output.put_line('user name IS not null  ');

 l_password_date:=sysdate;
 if(l_password is null OR l_password = '') then

    JTF_UM_PASSWORD_PVT.generate_password (

		 p_api_version_number         =>1.0
		,p_init_msg_list              =>FND_API.g_false
		,p_commit                     =>FND_API.g_false
                , p_validation_level          =>FND_API.G_VALID_LEVEL_FULL
                , x_password                  =>l_gen_password,
                 x_return_status             =>l_return_status,
                 x_msg_count                 =>l_msg_count,
                 x_msg_data                  =>l_msg_data
                 );


      -- dbms_output.put_line ('After API call'|| l_return_status);
      -- dbms_output.put_line('Message count : '||l_msg_count);
      -- dbms_output.put_line('password = :' || l_gen_password);
      l_password := l_gen_password;
      l_password_date := null;
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'JTF_UM_PASSWORD_PVT.generate_password ');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;


ELSE
     l_pass_length:= FND_PROFILE.VALUE('SIGNON_PASSWORD_LENGTH');
     if length(l_password) < l_pass_length THEN
          l_return_status:='E';
          l_msg_count:=1;
          l_msg_data:='Password length should be a minimum of '|| l_pass_length;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

END IF;





FND_USER_PKG.CreateUser(x_user_name => l_user_name,
            x_owner => 'SYSTEM',
			x_unencrypted_password => l_password,
			x_start_date => sysdate,
			x_end_date => null,
			x_password_date => l_password_date,
			x_email_address => l_email_address,
            x_customer_id => l_contact_rel_id
			);

   OPEN get_user_id(l_user_name);
   FETCH get_user_id INTO l_user_id;
   CLOSE get_user_id;

   OPEN user_type_id(l_user_type_key);
   FETCH user_type_id INTO l_user_type_id,l_approval_id;
   CLOSE user_type_id;



	    -- dbms_output.put_line('User type id new is  '||l_user_type_id);
   	    -- dbms_output.put_line('approval id new is  '||l_approval_id);
	    -- dbms_output.put_line('User  id new is  '||l_user_id);
            -- dbms_output.put_line('User  id new is  '||l_user_name);




  l_partner_user_rec.user_id :=l_user_id;
  l_partner_user_rec.person_rel_party_id :=l_contact_rel_id;
  l_partner_user_rec.user_name:=l_user_name;
  l_partner_user_rec.user_type_id :=l_user_type_id;

PV_USER_MGMT_PVT.register_partner_user
(
     p_api_version_number         =>1.0
    ,p_init_msg_list              =>FND_API.g_false
    ,p_commit                     =>FND_API.g_false
    ,p_partner_user_rec           =>l_partner_user_rec
    --,p_isPartial  => FND_API.g_false
    ,x_return_status    => l_return_status   ,
   	x_msg_count    	   => l_msg_count	  ,
   	x_msg_data         => l_msg_data
 );

      -- dbms_output.put_line ('After API call'|| l_return_status);
      -- dbms_output.put_line('Message count : '||l_msg_count);
      -- dbms_output.put_line('In user API msgdata=> '|| l_msg_data);


     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_USER_MGMT_PVT.register_partner_user ');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;


      -- dbms_output.put_line ('After register partner user'|| l_return_status);





  OPEN resp_list(l_user_type_id);
  LOOP
    FETCH resp_list INTO l_resp_id,l_app_id;
    -- dbms_output.put_line(' resp = '|| l_resp_id);  -- recompile succeeded
    EXIT WHEN resp_list%NOTFOUND;



     pv_user_resp_pvt.assign_resp(
               p_api_version_number         => '1.0'
              ,p_init_msg_list              => FND_API.G_FALSE
              ,p_commit                     => FND_API.G_true
              ,p_user_id                    => l_user_id
              ,p_resp_id                    => l_resp_id
              ,p_app_id                     => l_app_id
              ,x_return_status              => l_return_status
              ,x_msg_count                  => l_msg_count
              ,x_msg_data                   => l_msg_data
           );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'pv_user_resp_pvt.assign_resp');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

  END LOOP;  -- invalid program objects
  CLOSE resp_list;
-- dbms_output.put_line('reached after responsibility :' );



  OPEN role_list(l_user_type_id);
  LOOP
    FETCH role_list INTO l_principal_name;
    -- dbms_output.put_line(' resp = '|| l_resp_id);  -- recompile succeeded
    EXIT WHEN role_list%NOTFOUND;



   jtf_auth_bulkload_pkg.assign_role
             ( USER_NAME => l_user_name,
               ROLE_NAME => l_principal_name);



  END LOOP;  -- invalid program objects
  CLOSE role_list;
-- dbms_output.put_line('reached after roles :' );

---  Will remove this once the Register_partner_user start date is fixed.


     fnd_user_pkg.updateUser(
      x_user_name => l_user_name,
      x_owner => null,
      x_start_date => sysdate
     );



END IF ; --- USER CREATION ENDS

x_return_status := FND_API.G_RET_STS_SUCCESS;




 EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO user_create_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data:= l_msg_data;
     x_msg_count:= l_msg_count;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
        hz_utility_v2pub.debug('user_create (-)');
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO user_create_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
        hz_utility_v2pub.debug('user_create (-)');
     END IF;

   WHEN OTHERS THEN
     ROLLBACK TO user_create_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
        hz_utility_v2pub.debug('user_create (-)');
     END IF;



     END user_create;





PROCEDURE user_update (
     p_api_version_number  IN  NUMBER
    ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
    ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
    ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,p_user_name IN VARCHAR2
    ,p_user_type_key IN VARCHAR2
    ,p_contact_rel_id IN NUMBER
    ,x_return_status      OUT NOCOPY  VARCHAR2
    ,x_msg_data           OUT NOCOPY  VARCHAR2
    ,x_msg_count          OUT NOCOPY  NUMBER
    ) IS

     L_API_NAME           CONSTANT VARCHAR2(30) := 'user_update';
     L_API_VERSION_NUMBER CONSTANT NUMBER   := 1.0;




        l_api_version_number   NUMBER   ;
        l_init_msg_list        VARCHAR2(1000);
        l_commit               VARCHAR2(1000);
        l_validation_level     NUMBER  ;

        l_user_name VARCHAR2(1000):=p_user_name;
--	l_password VARCHAR2(1000):= p_password;
	l_contact_rel_id NUMBER :=p_contact_rel_id;
        l_user_type_key        VARCHAR2(1000):=p_user_type_key;
--        l_user_language VARCHAR2(1000) := p_user_language;
        l_sso_enabled VARCHAR2(100);
        l_partner_id NUMBER;
	l_partner_group_id NUMBER;
	l_person_first_name VARCHAR2(1000);
	l_approval_id NUMBER;
	l_enrollment_id NUMBER;
	l_enrollment_reg_id NUMBER;
	l_person_last_name VARCHAR2(1000);
	l_org_contact_id NUMBER;
	l_party_name VARCHAR2(1000);
	l_email_address VARCHAR2(1000);


	l_partner_party_id NUMBER;
	l_contact_party_id NUMBER;

        l_partner_user_rec PV_USER_MGMT_PVT.Partner_User_Rec_type;
	l_person_party_id  NUMBER ;
   	l_rel_party_id     NUMBER ;
   	l_org_party_id     NUMBER;
        l_org_contact_party_id NUMBER;
        l_rel_id NUMBER;
        l_rel_party_number NUMBER;

	l_user_id          NUMBER;
        l_user_type_id     NUMBER;
        l_user_reg_id      NUMBER;
        l_principal_name VARCHAR2(1000);
     -- Other OUT parameters returned by the API.
        l_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);
        l_usertype_resp_id NUMBER;
        l_usertype_app_id NUMBER;
        l_last_update_date VARCHAR2(2000);
        l_gen_password VARCHAR2(2000);
        l_version NUMBER;
	l_pass_length NUMBER;


	l_respKey varchar2(50) := 'JTF_PENDING_APPROVAL';
	l_status  varchar2(10) := 'PENDING';
	l_application_id  number := 690;
	l_usertype_key varchar2(100);
	l_resp_id NUMBER;
	l_contact_exist_id NUMBER;
	l_app_id NUMBER;

	l_relationship_code VARCHAR2(1000);
	l_party_status VARCHAR2(1000);


        l_party_rel_rec	HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
        l_org_contact_rec  	HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;

   CURSOR user_type_id (user_type VARCHAR2) IS
         select usertype_id ,nvl(approval_id,-1) from JTF_UM_USERTYPES_B where usertype_key=user_type;

   CURSOR user_type_reg_id (USERNAME VARCHAR2 , USERTYPE VARCHAR2) IS
         select USERTYPE_REG_ID from jtf_um_usertype_reg reg, fnd_user fu, JTF_UM_USERTYPES_B type  where
	       fu.user_id=reg.user_id and fu.user_name=username and
	       type.usertype_key=USERTYPE and
	       reg.usertype_id=type.usertype_id and
	       reg.user_id=fu.user_id;
   CURSOR get_user_id(l_user_name VARCHAR2) is
         select user_id from fnd_user where user_name=l_user_name;

   CURSOR enrollment_id (user_type VARCHAR2) IS
         select a.subscription_id from    JTF_UM_USERTYPE_SUBSCRIP a,JTF_UM_SUBSCRIPTIONS_B b,JTF_UM_USERTYPES_B c
         where  a.subscription_id=b.subscription_id
         and c.usertype_key=user_type
         and a.usertype_id=c.usertype_id;

   CURSOR get_subscription(userid VARCHAR2, subscriptionid VARCHAR2) IS
        select SUBSCRIPTION_REG_ID from jtf_um_subscription_reg where user_id=userid and subscription_id=subscriptionid;

   cursor getLUDFromUserReg(l_user_reg_id VARCHAR2) is
	  select to_char (last_update_date, 'mmddyyyyhh24miss')
	  from jtf_um_usertype_reg
	  where usertype_reg_id = to_number (l_user_reg_id);

   CURSOR CHECK_PARTNER(l_party_id VARCHAR2) IS
          select partner_id from pv_partner_profiles where partner_party_id=l_party_id;




   CURSOR USERTYPE_RESP(user_type VARCHAR2) is select FR.RESPONSIBILITY_ID, UT.APPLICATION_ID, FR.VERSION
		FROM JTF_UM_USERTYPE_RESP UT,
		FND_RESPONSIBILITY_VL FR,
		JTF_UM_USERTYPES_B c
		WHERE c.usertype_key=user_type
		and UT.USERTYPE_ID = c.usertype_id
		AND   FR.APPLICATION_ID  = UT.APPLICATION_ID
		AND   FR.RESPONSIBILITY_KEY = UT.RESPONSIBILITY_KEY
		AND   (UT.EFFECTIVE_END_DATE IS NULL OR UT.EFFECTIVE_END_DATE > SYSDATE)
		AND   UT.EFFECTIVE_START_DATE < SYSDATE;

CURSOR USERTYPE_ROLES(usertype_id NUMBER) IS SELECT PRINCIPAL_NAME
		FROM JTF_UM_USERTYPE_ROLE
		WHERE USERTYPE_ID = usertype_id
		AND   (EFFECTIVE_END_DATE IS NULL OR EFFECTIVE_END_DATE > SYSDATE)
		AND   EFFECTIVE_START_DATE < SYSDATE;


CURSOR get_relationship_code(rel_party_id NUMBER) IS
   select relationship_code from hz_relationships hzr where hzr.party_id=rel_party_id and hzr.directional_flag='F';


CURSOR get_status(rel_party_id NUMBER) IS
   select hzp.status from hz_parties hzp where hzp.party_id=rel_party_id ;


CURSOR get_email_address(rel_party_id NUMBER) IS
   select email_address from hz_parties hzp where hzp.party_id=rel_party_id ;




cursor get_contact_details(rel_party_id NUMBER) IS
   select pvpp.partner_id, pvpp.PARTNER_GROUP_ID , person_hzp.PERSON_FIRST_NAME, person_hzp.person_last_name,
   hzoc.org_contact_id, org_hzp.party_name, rel_hzp.email_address
   from HZ_PARTIES PERSON_HZP, HZ_RELATIONSHIPS HZR, PV_PARTNER_PROFILES pvpp, hz_org_contacts hzoc, HZ_PARTIES ORG_HZP,
   hz_parties REL_HZP
   where HZR.party_id = rel_party_id
   and HZR.directional_flag = 'F'
   and hzr.relationship_code = 'EMPLOYEE_OF'
   and HZR.subject_table_name ='HZ_PARTIES'
   and HZR.object_table_name ='HZ_PARTIES'
   and hzr.start_date <= SYSDATE
   and (hzr.end_date is null or hzr.end_date > SYSDATE)
   and hzr.status = 'A'
   and hzr.subject_id = person_hzp.party_id
   and person_hzp.status = 'A'
   and hzr.object_id = pvpp.partner_party_id
   and pvpp.partner_group_id is not null
   and hzoc.PARTY_RELATIONSHIP_ID = hzr.relationship_id
   and hzr.object_id = org_hzp.party_id and
   rel_hzp.party_id=hzr.party_id;

CURSOR CHECK_CONTACT(rel_party_id VARCHAR2,l_user_name VARCHAR2) is
   select hzr.subject_id from hz_parties rel,hz_relationships hzr ,pv_partner_profiles pvpp, fnd_user fu
   where rel.party_id=rel_party_id and
         hzr.party_id=rel.party_id and
         hzr.relationship_code in ('EMPLOYEE_OF') and
	 fu.user_name=l_user_name and
	 hzr.party_id=fu.customer_id and
	 hzr.object_id=pvpp.partner_party_id;


cursor resp_list(l_usertype_id VARCHAR2) is
 select responsibility_id, application_id
 from fnd_responsibility
 where responsibility_key in
 (select responsibility_key
         from  jtf_um_usertype_resp jtur
         where  jtur.usertype_id = l_usertype_id
         and  (jtur.effective_end_date is null or jtur.effective_end_date >  sysdate)
         union
         select responsibility_key
         from jtf_um_usertype_subscrip jtus, jtf_um_subscription_resp jtsr
         where  jtus.usertype_id = l_usertype_id
         and (jtus.effective_end_date is null or jtus.effective_end_date >  sysdate)
         and jtus.subscription_flag = 'IMPLICIT'
         and jtus.subscription_id = jtsr.subscription_id
         and (jtsr.effective_end_date is null or jtsr.effective_end_date >  sysdate));

cursor role_list(l_usertype_id VARCHAR2)  is
     select principal_name
         from  jtf_um_usertype_role jtur
         where  jtur.usertype_id = l_usertype_id
         and  (jtur.effective_end_date is null or jtur.effective_end_date >  sysdate)
         union
         select jtsr.principal_name
         from jtf_um_usertype_subscrip jtus, jtf_um_subscription_role jtsr
         where  jtus.usertype_id = l_usertype_id
	 and (jtus.effective_end_date is null or jtus.effective_end_date >  sysdate)
         and jtus.subscription_flag = 'IMPLICIT'
         and jtus.subscription_id = jtsr.subscription_id
         and (jtsr.effective_end_date is null or jtsr.effective_end_date >  sysdate);


BEGIN

savepoint user_update_pvt;

-- dbms_output.put_line('l_contact_rel_id ' || l_contact_rel_id);

if l_contact_rel_id is null then
          fnd_message.SET_NAME  ('PV', 'PV_CONTACT_ID_INVALID');
          fnd_msg_pub.ADD;
          raise FND_API.G_EXC_ERROR;
END IF;


   OPEN CHECK_CONTACT(l_contact_rel_id,l_user_name) ;
   FETCH CHECK_CONTACT INTO l_contact_party_id;
   CLOSE CHECK_CONTACT;


if l_contact_party_id is null then
      fnd_message.SET_NAME  ('PV', 'PV_CONTACT_ID_INVALID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

END IF;



if l_user_name is null then
      fnd_message.SET_NAME  ('PV', 'PV_USER_NAME_MISSING');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

END IF;

-- dbms_output.put_line('after user name check');



/**************** CHECK FOR SSO ************************************************************************/
  l_sso_enabled := fnd_profile.value('APPS_SSO_USER_CREATE_UPDATE');
  if l_sso_enabled = 'N' OR l_sso_enabled = 'FTTT' OR l_sso_enabled = 'FFFF' then
        fnd_message.set_name('PV', 'PV_SSO_CREATE_USER_NOT_ALLOWED');
        fnd_msg_pub.ADD;
        raise FND_API.G_EXC_ERROR;
  end if;

-- dbms_output.put_line('after sso check ');

/**************** CHECK IF USER EXISTS ALREADY FOR CONTACT ************************************************************************/


   OPEN get_relationship_code(l_contact_rel_id);
   FETCH get_relationship_code INTO l_relationship_code;
   CLOSE get_relationship_code;





if l_relationship_code is null or l_relationship_code <> 'EMPLOYEE_OF' then
      fnd_message.SET_NAME  ('PV', 'PV_NOT_EMPLOYEE_REL');
      fnd_msg_pub.ADD;
   RAISE FND_API.G_EXC_ERROR;
END IF;

-- dbms_output.put_line('After relationship check');




   OPEN get_status(l_contact_rel_id);
   FETCH get_status INTO l_party_status;
   CLOSE get_status;

-- dbms_output.put_line('before party status check');

if l_party_status is null or l_party_status <> 'A' then
      fnd_message.SET_NAME  ('PV', 'PV_CONTACT_NOT_ACTIVE');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;

END IF;


-- dbms_output.put_line('BEFORE email address check');

   OPEN get_email_address(l_contact_rel_id);
   FETCH get_email_address INTO l_email_address;
   CLOSE get_email_address;

-- dbms_output.put_line('After email address check1' || l_email_address);






-- dbms_output.put_line('After email address check2' || l_email_address);

if l_email_address is null or l_email_address='' then
   l_return_status:='E';
   l_msg_count:=1;
   l_msg_data:='PV_EMAIL_ID_NEEDED';
   RAISE FND_API.G_EXC_ERROR;
END IF;


-- dbms_output.put_line('BEFORE get contact details');

   OPEN get_contact_details(l_contact_rel_id);
   FETCH get_contact_details INTO l_partner_id, l_PARTNER_GROUP_ID , l_PERSON_FIRST_NAME, l_person_last_name,    l_org_contact_id, l_party_name, l_email_address;
   CLOSE get_contact_details;











-- dbms_output.put_line('user name not null check ' || l_user_name);
if(l_user_name is not null) THEN


OPEN GET_USER_ID(l_user_name);
FETCH GET_USER_ID INTO l_user_id;
CLOSE GET_USER_ID;


OPEN user_type_id(l_user_type_key);
FETCH user_type_id INTO l_user_type_id,l_approval_id;
CLOSE user_type_id;




  l_partner_user_rec.user_id :=l_user_id;
  l_partner_user_rec.person_rel_party_id :=l_contact_rel_id;
  l_partner_user_rec.user_name:=l_user_name;
  l_partner_user_rec.user_type_id :=l_user_type_id;

PV_USER_MGMT_PVT.register_partner_user
(
     p_api_version_number         =>1.0
    ,p_init_msg_list              =>FND_API.g_false
    ,p_commit                     =>FND_API.g_false
    ,p_partner_user_rec           =>l_partner_user_rec
    --,p_isPartial  => FND_API.g_false
    ,x_return_status    => l_return_status   ,
   	x_msg_count    	   => l_msg_count	  ,
   	x_msg_data         => l_msg_data
 );

      -- dbms_output.put_line ('After API call'|| l_return_status);
      -- dbms_output.put_line('Message count : '||l_msg_count);
      -- dbms_output.put_line('In user API msgdata=> '|| l_msg_data);


     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_USER_MGMT_PVT.register_partner_user ');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;


      -- dbms_output.put_line ('After register partner user'|| l_return_status);




 OPEN resp_list(l_user_type_id);
  LOOP
    FETCH resp_list INTO l_resp_id,l_app_id;
    EXIT WHEN resp_list%NOTFOUND;


    -- dbms_output.put_line(' resp = '|| l_resp_id);  -- recompile succeeded
     pv_user_resp_pvt.assign_resp(
               p_api_version_number         => '1.0'
              ,p_init_msg_list              => FND_API.G_FALSE
              ,p_commit                     => FND_API.G_true
              ,p_user_id                    => l_user_id
              ,p_resp_id                    => l_resp_id
              ,p_app_id                     => l_app_id
              ,x_return_status              => l_return_status
              ,x_msg_count                  => l_msg_count
              ,x_msg_data                   => l_msg_data
           );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'pv_user_resp_pvt.assign_resp');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

  END LOOP;  -- invalid program objects
  CLOSE resp_list;
-- dbms_output.put_line('reached after responsibility :' );





 OPEN role_list(l_user_type_id);
  LOOP
    FETCH role_list INTO l_principal_name;
    -- dbms_output.put_line(' resp = '|| l_principal_name);  -- recompile succeeded
    EXIT WHEN role_list%NOTFOUND;



   jtf_auth_bulkload_pkg.assign_role
             ( USER_NAME => l_user_name,
               ROLE_NAME => l_principal_name);



  END LOOP;  -- invalid program objects
  CLOSE role_list;
-- dbms_output.put_line('reached after roles :' );

---  Will remove this once the Register_partner_user start date is fixed.


     fnd_user_pkg.updateUser(
      x_user_name => l_user_name,
      x_owner => null,
      x_start_date => sysdate
     );


END IF ; --- USER CREATION ENDS

x_return_status := FND_API.G_RET_STS_SUCCESS;




 EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO user_update_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data:= l_msg_data;
     x_msg_count:= l_msg_count;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
        hz_utility_v2pub.debug('user_update (-)');
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO user_update_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
        hz_utility_v2pub.debug('user_update (-)');
     END IF;

   WHEN OTHERS THEN
     ROLLBACK TO user_update_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
        hz_utility_v2pub.debug('user_update (-)');
     END IF;



     END user_update;

PROCEDURE Load_Contacts (
     p_api_version_number  IN  NUMBER
    ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
    ,p_mode               IN  VARCHAR2 := 'EVALUATION'
    ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status      OUT NOCOPY  VARCHAR2
    ,x_msg_data           OUT NOCOPY  VARCHAR2
    ,x_msg_count          OUT NOCOPY  NUMBER
    ,p_contact_details_tbl		IN	CONTACT_DETAILS_TBL_TYPE
    ,p_update_if_exists			IN 	VARCHAR2
    ,p_data_block_size			IN	NUMBER
    ,x_contact_output_tbl               OUT NOCOPY    CONTACT_OUTPUT_TBL_TYPE
    ,x_file_name			OUT NOCOPY	VARCHAR2
    )
IS

        L_API_NAME           CONSTANT VARCHAR2(30) := 'Load_Contacts';
        L_API_VERSION_NUMBER CONSTANT NUMBER   := 1.0;
        l_contact_details_rec CONTACT_DETAILS_REC_TYPE ;
        l_commit VARCHAR2(100) := FND_API.G_FALSE;
        l_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);
	l_contact_rel_id NUMBER;
	l_location_id NUMBER;
	l_first_rec NUMBER;
	l_last_rec NUMBER;
	l_current_rec NUMBER;
	l_contact_details_tbl CONTACT_DETAILS_TBL_TYPE := p_contact_details_tbl;
	l_contact_output_tbl  CONTACT_OUTPUT_TBL_TYPE;
        l_contact_output_rec  CONTACT_OUTPUT_REC_TYPE;
	l_update_allowed varchar2(1000);
	l_update_if_exists varchar2(1000) :=p_update_if_exists;
	l_log_msg  LOG_MESSAGE_TBL_TYPE;
        l_file_name                             varchar2(20);
        l_log_dir                               varchar2(100);
        l_out_dir                               varchar2(100);
	l_prof VARCHAR2(100);
	l_commit_size NUMBER := p_data_block_size;
        log_return_status VARCHAR2(1000);



  CURSOR l_get_file_dir IS
    select
        trim(substr(value,0,(instr(value,',') - 1))),
        trim(substr(value,(instr(value,',') + 1)))
    from  v$parameter where name = 'utl_file_dir';

BEGIN

-- dbms_output.put_line ('Entered Load_contacts method' );



if p_mode = 'EXECUTION' then
l_commit:=FND_API.G_TRUE;
else
l_commit:=FND_API.G_FALSE;
end if;




/************** Start of file data ************************************************************/
select to_char(systimestamp,'yyddmmsssss') || '.log'  into l_file_name from dual;

open l_get_file_dir;
fetch l_get_file_dir into l_out_dir, l_log_dir;
close l_get_file_dir;

l_log_file := utl_file.fopen(trim(l_out_dir), l_file_name, 'w');



/************** End of file data ************************************************************/


if l_contact_details_tbl.count = 0 then

         fnd_message.set_name('PV', 'PV_IMP_NO_CONTACT');
         utl_file.put_line(L_LOG_FILE, substrb(fnd_message.get, 1, 1000));
         x_return_status:='S';



/************************************ CLOSING FILE ********************************/
        x_file_name := l_out_dir || '/' || l_file_name;
        -- dbms_output.put_line('output file name  ' || x_file_name);
        utl_file.fclose(L_LOG_FILE);
/**********************************************************************************/

else

/********************** Disable all HZ EVENTS **********************************************/

l_prof:= fnd_profile.value('HZ_EXECUTE_API_CALLOUTS');
if l_prof <> 'N' then
   fnd_profile.put('HZ_EXECUTE_API_CALLOUTS','N');
end if ;

/***********************End disable events**************************************************/

if l_commit_size is null then
  l_commit_size:=50;

end if;
-- dbms_output.put_line ('after setting commit size' );
l_first_rec:=l_contact_details_tbl.FIRST;
-- dbms_output.put_line ('after setting first record' );
-- dbms_output.put_line ('last record is '  || l_contact_details_tbl.LAST);

WHILE l_first_rec <= l_contact_details_tbl.LAST
LOOP
savepoint contacts_batch;
-- dbms_output.put_line ('Entered while loop of contact batch' );


l_last_rec:= l_first_rec + l_commit_size -1;


if l_contact_details_tbl.LAST < l_last_rec then
   l_last_rec := l_contact_details_tbl.LAST;
end if ;

fnd_message.set_name('PV', 'PV_CONTACT_IMPORT_LOG');
utl_file.put_line(L_LOG_FILE, substrb(fnd_message.get, 1, 1000));

  utl_file.put_line(L_LOG_FILE, '-----------------------------------------------------------------------------------------------------'
   || '-----------------------------------------------------------------------------------------------------------------------------------------------');
   -- dbms_output.put_line('just after writing to file');


for l_current_rec in l_first_rec .. l_last_rec
LOOP
savepoint contact_record;
-- dbms_output.put_line ('Entered for loop of contact record' );

   l_contact_details_rec:=p_contact_details_tbl(l_current_rec);



   if l_contact_details_rec.update_if_exists is not null  then
           l_update_allowed :=  l_contact_details_rec.update_if_exists;

   elsif l_update_if_exists is not null then

           l_update_allowed := l_update_if_exists;
   end if ;

   l_log_msg.delete;
   PV_CONTACT_USER_BATCH_PUB.contact_create (
     p_api_version_number  =>1.0
    ,p_init_msg_list      =>'T'
    ,p_commit             =>'F'
    ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    ,p_contact_details_rec => l_contact_details_rec
    ,p_update_flag    => l_update_allowed
    ,x_contact_rel_id => l_contact_rel_id
    ,x_contact_output_rec => l_contact_output_rec
    ,x_log_msg  => l_log_msg
    ,x_return_status  => l_return_status
    ,x_msg_data       => l_msg_data
    ,x_msg_count      => l_msg_count
    ) ;

       x_contact_output_tbl(l_current_rec):=l_contact_output_rec;


      -- dbms_output.put_line('Contact LOG MESSAGE first   ' ||  l_log_msg.FIRST);
      -- dbms_output.put_line('Contact LOG MESSAGE last   ' ||  l_log_msg.LAST);
/*
      for i in l_log_msg.FIRST .. l_log_msg.LAST
        LOOP
              -- dbms_output.put_line('Log -  '||l_log_msg(i));
      END LOOP;

*/
log_return_status:=null;
if l_contact_output_rec.return_status = 'SUCCESS' then
    fnd_message.set_name('PV', 'PV_CONTACT_REC_SUCCESS');
elsif l_contact_output_rec.return_status = 'ERROR' then
    fnd_message.set_name('PV', 'PV_CONTACT_REC_ERROR');
elsif l_contact_output_rec.return_status = 'NOT_PROCESSED' then
    fnd_message.set_name('PV', 'PV_CONTACT_REC_NOT_PROCESSED');
end if;
 log_return_status:=substrb(fnd_message.get, 1, 1000);



   -- dbms_output.put_line('just before writing to file');
   utl_file.put_line(L_LOG_FILE, rpad(nvl(l_contact_details_rec.contact_name,'N/A'),20) || rpad(nvl(l_contact_output_rec.Prtnr_orig_system,'N/A'),20)
     || rpad(nvl(l_contact_output_rec.Prtnr_orig_system_reference,'N/A'),20) || rpad(nvl(l_contact_output_rec.Partner_party_id,0),20)
     || rpad(nvl(l_contact_output_rec.Cnt_orig_system,'N/A'),20) || rpad(nvl(l_contact_output_rec.Cnt_orig_system_reference,'N/A'),20)
     || rpad(nvl(l_contact_output_rec.Person_party_id,0),20) || rpad(nvl(l_contact_output_rec.Contact_rel_party_id,0),20)
     || rpad(nvl(log_return_status,'N/A'),20));
   Write_Error(l_log_msg);
   utl_file.put_line(L_LOG_FILE, '-----------------------------------------------------------------------------------------------------'
   || '-----------------------------------------------------------------------------------------------------------------------------------------------');
   -- dbms_output.put_line('just after writing to file');



END LOOP; -- END FOR LOOP

-- dbms_output.put_line ('Just before commit' );

if l_commit = FND_API.G_TRUE then
    -- dbms_output.put_line ('I am going to commit' );
    Commit;
else
    -- dbms_output.put_line ('I am going to rollback data' );
   rollback to contacts_batch;
end if;

-- dbms_output.put_line ('Just after commit' );



l_first_rec := l_first_rec + l_commit_size;
END LOOP; -- END WHILE LOOP.




/********************** Reset HZ EVENTS **********************************************/

if l_prof <> 'N' then
   fnd_profile.put('HZ_EXECUTE_API_CALLOUTS',l_prof);
end if ;

/***********************End reset events**************************************************/



-- dbms_output.put_line('just before closing file');

/************************************ CLOSING FILE ********************************/
        x_file_name := l_out_dir || '/' || l_file_name;
        -- dbms_output.put_line('output file name  ' || x_file_name);
        utl_file.fclose(L_LOG_FILE);
/**********************************************************************************/
   -- dbms_output.put_line('just after closing file');


x_return_status:='S';



end if;


EXCEPTION
      when utl_file.invalid_path then
         raise_application_error(-20100,'Invalid Path');
      when utl_file.invalid_mode then
         raise_application_error(-20101,'Invalid Mode');
      when utl_file.invalid_operation then
         raise_application_error(-20102,'Invalid Operation');
      when utl_file.invalid_filehandle then
         raise_application_error(-20103,'Invalid FileHandle');
      when utl_file.write_error then
         utl_file.fclose(l_log_file);
         raise_application_error(-20104,'Write Error');
      when utl_file.read_error then
         raise_application_error(-20105,'Read Error');
      when utl_file.internal_error then
         raise_application_error(-20106,'Internal Error');

   WHEN OTHERS THEN


      ROLLBACK;
/*	utl_file.put_line(L_LOG_FILE,SQLERRM);
            FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
              utl_file.put_line(L_LOG_FILE,Substr(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1,1000));
            END LOOP;
        utl_file.fclose(l_log_file);
*/

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

     -- Debug Message
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
        hz_utility_v2pub.debug('Load_contacts (-)');
     END IF;





END Load_Contacts ;



END PV_CONTACT_USER_BATCH_PUB;


/
