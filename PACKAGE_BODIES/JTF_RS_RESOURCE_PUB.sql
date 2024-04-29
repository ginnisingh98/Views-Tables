--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_PUB" AS
/* $Header: jtfrsprb.pls 120.5 2006/03/14 17:26:49 nsinghai ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resources.
   Its main procedures are as following:
   Create Resource
   Update Resource
   This package validates the input parameters to these procedures and then
   Calls corresponding  procedures from jtf_rs_resource_pvt to do business
   validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/


  /* Package variables. */

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_RESOURCE_PUB';


  /* Procedure to create the resource based on input values
        passed by calling routines. */
Function  get_wf_role ( resource_id in number )
  RETURN  varchar2 IS

  cursor c1 is select select_id , from_table , where_clause from jtf_objects_vl
  where object_code in ( select object_code from jtf_object_usages
  where object_user_code = 'RESOURCE_WORKFLOW' ) ;

  --Adding this cursor to display the resource name in the message (repuri 03/12/01)
  cursor c_rs_name (l_resource_id IN NUMBER) IS
    SELECT resource_name from jtf_rs_resource_extns_tl
    WHERE resource_id = l_resource_id
    AND language = userenv ('LANG');

  x number :=  0;
  select_statement varchar2(2000) := null ;
  wf_rolename varchar2(60);

  l_resource_name jtf_rs_resource_extns_tl.resource_name%type;
  l_resource_id   jtf_rs_resource_extns.resource_id%TYPE;

  -- variables for dynamic bind to query
  TYPE bind_rec_type IS RECORD (bind_value NUMBER);
  TYPE  bind_tbl_type IS TABLE OF bind_rec_type INDEX BY binary_integer;
  bind_table           bind_tbl_type;

BEGIN

 l_resource_id  := resource_id;

 OPEN c_rs_name (l_resource_id);
 FETCH c_rs_name INTO l_resource_name;
 CLOSE c_rs_name;

 --dbms_output.put_line('Resource Name - '||l_resource_name);

 for i in c1 loop
    if x <> 0 then
        select_statement := select_statement || ' union ' ;
    end if ;
/* BINDVAR_SCAN_IGNORE [1] */
    select_statement := select_statement || ' select '||i.select_id||' from '||i.from_table
	                    ||' where '||i.where_clause ||' and rs.resource_id = :x_resource_id ';
    x := x + 1;
    bind_table(x).bind_value := l_resource_id;

 end loop;

 -- Fix for Bug 4673722 (21-Oct-2005), changed the resource_id to bind variable (for perf).
 -- Done after discussion with Hari regarding number of records to be supported. Since this
 -- method of fetching wf_roles is obsoleted, it will not be enhanced in future regarding
 -- seed data. Currently only 2 rows are seeded in jtf_objects_vl. As a buffer providing
 -- extra 3 bind queries.
 IF (x = 1) THEN
   EXECUTE IMMEDIATE select_statement INTO wf_rolename USING bind_table(1).bind_value;
 ELSIF (x = 2) THEN
   EXECUTE IMMEDIATE select_statement INTO wf_rolename USING bind_table(1).bind_value,
                                                             bind_table(2).bind_value;
 ELSIF (x = 3) THEN
   EXECUTE IMMEDIATE select_statement INTO wf_rolename USING bind_table(1).bind_value,
                                                             bind_table(2).bind_value,
                                                             bind_table(3).bind_value;
 ELSIF (x = 4) THEN
   EXECUTE IMMEDIATE select_statement INTO wf_rolename USING bind_table(1).bind_value,
                                                             bind_table(2).bind_value,
                                                             bind_table(3).bind_value,
                                                             bind_table(4).bind_value;
 ELSIF (x = 5) THEN
   EXECUTE IMMEDIATE select_statement INTO wf_rolename USING bind_table(1).bind_value,
                                                             bind_table(2).bind_value,
                                                             bind_table(3).bind_value,
                                                             bind_table(4).bind_value,
                                                             bind_table(5).bind_value;
 END IF;

 RETURN wf_rolename ;

exception
when no_data_found then
        fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
        fnd_message.set_token('P_RESOURCE_NAME', l_resource_name);
        fnd_msg_pub.add;
        return null ;
when too_many_rows then
        fnd_message.set_name('JTF', 'JTF_RS_MORE_WF_ROLES');
        fnd_message.set_token('P_RESOURCE_NAME', l_resource_name);
        fnd_msg_pub.add;
        return null ;
when others then
        fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_GET_ROLE_ERR');
        fnd_msg_pub.add;
        return null ;
END;


  PROCEDURE  create_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE,
   P_MANAGING_EMP_NUM        IN   PER_EMPLOYEES_CURRENT_X.EMPLOYEE_NUM%TYPE,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
   P_INTERACTION_CENTER_NAME IN   VARCHAR2,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   DEFAULT  NULL,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE';
    l_category                     jtf_rs_resource_extns.category%TYPE;
    l_source_id                    jtf_rs_resource_extns.source_id%TYPE;
    l_address_id                   jtf_rs_resource_extns.address_id%TYPE;
    l_contact_id                   jtf_rs_resource_extns.contact_id%TYPE;
    l_managing_emp_id              jtf_rs_resource_extns.managing_employee_id%TYPE;
    l_managing_emp_num             per_employees_current_x.employee_num%TYPE;
    l_start_date_active            jtf_rs_resource_extns.start_date_active%TYPE;
    l_end_date_active              jtf_rs_resource_extns.end_date_active%TYPE;
    l_time_zone                    jtf_rs_resource_extns.time_zone%TYPE;
    l_cost_per_hr                  jtf_rs_resource_extns.cost_per_hr%TYPE;
    l_primary_language             jtf_rs_resource_extns.primary_language%TYPE;
    l_secondary_language           jtf_rs_resource_extns.secondary_language%TYPE;
    l_support_site_id              jtf_rs_resource_extns.support_site_id%TYPE;
    l_ies_agent_login              jtf_rs_resource_extns.ies_agent_login%TYPE;
    l_server_group_id              jtf_rs_resource_extns.server_group_id%TYPE;
    l_interaction_center_name      VARCHAR2(256);
    l_assigned_to_group_id         jtf_rs_resource_extns.assigned_to_group_id%TYPE;
    l_cost_center                  jtf_rs_resource_extns.cost_center%TYPE;
    l_charge_to_cost_center        jtf_rs_resource_extns.charge_to_cost_center%TYPE;
    l_comp_currency_code           jtf_rs_resource_extns.compensation_currency_code%TYPE;
    l_commissionable_flag          jtf_rs_resource_extns.commissionable_flag%TYPE;
    l_hold_reason_code             jtf_rs_resource_extns.hold_reason_code%TYPE;
    l_hold_payment                 jtf_rs_resource_extns.hold_payment%TYPE;
    l_comp_service_team_id         jtf_rs_resource_extns.comp_service_team_id%TYPE;
    l_user_id                      jtf_rs_resource_extns.user_id%TYPE;
    l_transaction_number           jtf_rs_resource_extns.transaction_number%TYPE;
    --l_location                     MDSYS.SDO_GEOMETRY := p_location;

--added for NOCOPY
    l_managing_emp_id_out          jtf_rs_resource_extns.managing_employee_id%TYPE ;
    l_server_group_id_out          jtf_rs_resource_extns.server_group_id%TYPE ;
    l_comp_service_team_id_out     jtf_rs_resource_extns.comp_service_team_id%TYPE;

    l_check_flag                   VARCHAR2(1);
    l_source_name                   VARCHAR2(2000);
    l_found                        BOOLEAN;


    /* Changed from view to direct table query stripping out unnecessary table joins
       for SQL Rep perf bug 4956627. Query logic taken from view JTF_RS_PARTNERS_VL.
       Nishant Singhai (13-Mar-2006)
    */
    /*
    CURSOR c_validate_partner(
         l_party_id        IN  NUMBER)
    IS
      SELECT 'Y'
      FROM jtf_rs_partners_vl
      WHERE party_id = l_party_id;
    */
    CURSOR c_validate_partner(l_party_id  IN  NUMBER)
    IS
	SELECT 'Y'
	FROM HZ_PARTIES PARTY, HZ_PARTIES PARTY2,
	     HZ_PARTIES PARTY3, HZ_RELATIONSHIPS REL
	WHERE (PARTY.PARTY_TYPE = 'ORGANIZATION' AND PARTY.PARTY_ID = REL.SUBJECT_ID)
	AND REL.RELATIONSHIP_CODE IN ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
	                              'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER',
								  'CUSTOMER_INDIRECTLY_MANAGED_BY')
	AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND REL.DIRECTIONAL_FLAG = 'F'
	AND REL.STATUS = 'A'
	AND PARTY.STATUS = 'A'
	AND PARTY2.STATUS = 'A'
	AND PARTY3.STATUS = 'A'
	AND REL.SUBJECT_ID = PARTY2.PARTY_ID
	AND (PARTY2.PARTY_TYPE = 'PERSON' OR PARTY2.PARTY_TYPE = 'ORGANIZATION')
	AND REL.OBJECT_ID = PARTY3.PARTY_ID
	AND PARTY3.PARTY_TYPE = 'ORGANIZATION'
	AND party.party_id = l_party_id
	UNION ALL
	SELECT 'Y'
	FROM HZ_PARTIES PARTY, HZ_PARTIES PARTY2,
	     HZ_PARTIES PARTY3, HZ_RELATIONSHIPS REL
	WHERE (PARTY.PARTY_TYPE = 'PARTY_RELATIONSHIP' AND PARTY.PARTY_ID = REL.PARTY_ID )
	AND REL.RELATIONSHIP_CODE IN ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
	                              'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER',
								  'CUSTOMER_INDIRECTLY_MANAGED_BY')
	AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND REL.DIRECTIONAL_FLAG = 'F'
	AND REL.STATUS = 'A'
	AND PARTY.STATUS = 'A'
	AND PARTY2.STATUS = 'A'
	AND PARTY3.STATUS = 'A'
	AND REL.SUBJECT_ID = PARTY2.PARTY_ID
	AND (PARTY2.PARTY_TYPE = 'PERSON' OR PARTY2.PARTY_TYPE = 'ORGANIZATION')
	AND REL.OBJECT_ID = PARTY3.PARTY_ID
	AND PARTY3.PARTY_TYPE = 'ORGANIZATION'
	AND party.party_id = l_party_id
	;

    CURSOR c_validate_partner_migr(
         l_party_id        IN  NUMBER)
    IS
         SELECT 'Y',party_name
      FROM jtf_rs_ptnr_migr_vl
         WHERE party_id = l_party_id;

   CURSOR c_validate_partner_address (
         l_party_id		IN  NUMBER,
	 l_party_site_id	IN  NUMBER)
    IS
	SELECT 'Y'
    FROM hz_party_sites
	WHERE party_id 		= l_party_id
	  AND party_site_id 	= l_party_site_id;

    CURSOR c_validate_partner_contact(
         l_party_id        IN  NUMBER,
         l_party_site_id   IN  NUMBER,
         l_contact_id      IN  NUMBER)
    IS
         SELECT 'Y'
      FROM jtf_rs_party_contacts_vl
         WHERE party_id 		= l_party_id
           AND nvl (party_site_id,-99) 	= nvl (l_party_site_id,-99)
           AND contact_id 		= l_contact_id;

   /* -- Direct query from tables. But does not improve performance or shared memory
      -- significantly. So not using it as it will lead to dual maintainence (view + this logic)
      -- Test performed for SQL Rep Bug 4956627

    CURSOR c_validate_partner_contact(
         l_party_id        IN  NUMBER,
         l_party_site_id   IN  NUMBER,
         l_contact_id      IN  NUMBER)
    IS
    SELECT 'Y'
	-- SELECT PARTY.PARTY_ID PARTY_ID , ORG_CONT.PARTY_SITE_ID PARTY_SITE_ID , ORG_CONT.ORG_CONTACT_ID CONTACT_ID ,
	-- ORG_CONT.CONTACT_NUMBER CONTACT_NUMBER , PARTY.PARTY_NAME CONTACT_NAME , CONT_ROLE.PRIMARY_FLAG PRIMARY_FLAG
	FROM HZ_PARTIES PARTY , HZ_RELATIONSHIPS PARTY_REL , HZ_ORG_CONTACTS ORG_CONT ,
  	     HZ_ORG_CONTACT_ROLES CONT_ROLE
	WHERE PARTY.STATUS = 'A'
	AND PARTY.PARTY_TYPE = 'PERSON'
	AND PARTY_REL.RELATIONSHIP_ID = ORG_CONT.PARTY_RELATIONSHIP_ID
	AND ORG_CONT.ORG_CONTACT_ID = CONT_ROLE.ORG_CONTACT_ID (+)
	AND CONT_ROLE.PRIMARY_FLAG (+) = 'Y'
	AND PARTY.PARTY_ID = PARTY_REL.SUBJECT_ID
	AND PARTY_REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.DIRECTIONAL_FLAG = 'F'
	AND PARTY_REL.STATUS = 'A'
	AND party.party_id = l_party_id
	AND ORG_CONT.ORG_CONTACT_ID = l_contact_id
	AND NVL(ORG_CONT.PARTY_SITE_ID,-99) = NVL(l_party_site_id,-99)
	UNION ALL
	SELECT 'Y'
	-- SELECT PARTY5.PARTY_ID PARTY_ID , ORG_CONT.PARTY_SITE_ID PARTY_SITE_ID ,
	-- ORG_CONT.ORG_CONTACT_ID CONTACT_ID , ORG_CONT.CONTACT_NUMBER CONTACT_NUMBER ,
	-- PARTY5.PARTY_NAME CONTACT_NAME , CONT_ROLE.PRIMARY_FLAG PRIMARY_FLAG
	FROM HZ_PARTIES PARTY3 , HZ_PARTIES PARTY4 , HZ_PARTIES PARTY5 , HZ_RELATIONSHIPS PARTY_REL ,
	     HZ_ORG_CONTACTS ORG_CONT , HZ_ORG_CONTACT_ROLES CONT_ROLE
	WHERE PARTY_REL.PARTY_ID = PARTY5.PARTY_ID
	AND PARTY5.PARTY_TYPE = 'PARTY_RELATIONSHIP'
	AND PARTY5.STATUS = 'A'
	AND TRUNC (NVL (PARTY_REL.END_DATE, SYSDATE)) >= TRUNC (SYSDATE)
	AND PARTY_REL.SUBJECT_ID = PARTY3.PARTY_ID
	AND PARTY3.PARTY_TYPE = 'PERSON'
	AND PARTY3.STATUS = 'A'
	AND PARTY_REL.OBJECT_ID = PARTY4.PARTY_ID
	AND PARTY4.PARTY_TYPE = 'ORGANIZATION'
	AND PARTY4.STATUS = 'A'
	AND PARTY_REL.RELATIONSHIP_ID = ORG_CONT.PARTY_RELATIONSHIP_ID
	AND ORG_CONT.ORG_CONTACT_ID = CONT_ROLE.ORG_CONTACT_ID (+)
	AND CONT_ROLE.PRIMARY_FLAG (+) = 'Y'
	AND PARTY_REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.DIRECTIONAL_FLAG = 'F'
	AND PARTY_REL.STATUS = 'A'
	AND party5.party_id = l_party_id
	AND ORG_CONT.ORG_CONTACT_ID = l_contact_id
	AND NVL(ORG_CONT.PARTY_SITE_ID,-99) = NVL(l_party_site_id,-99)
	UNION ALL
	SELECT 'Y'
	-- SELECT PARTY4.PARTY_ID PARTY_ID , ORG_CONT.PARTY_SITE_ID PARTY_SITE_ID ,
	-- ORG_CONT.ORG_CONTACT_ID CONTACT_ID , ORG_CONT.CONTACT_NUMBER CONTACT_NUMBER ,
	-- PARTY3.PARTY_NAME CONTACT_NAME , CONT_ROLE.PRIMARY_FLAG PRIMARY_FLAG
	FROM HZ_PARTIES PARTY3 , HZ_PARTIES PARTY4 , HZ_RELATIONSHIPS PARTY_REL ,
	     HZ_ORG_CONTACTS ORG_CONT , HZ_ORG_CONTACT_ROLES CONT_ROLE
	WHERE PARTY_REL.SUBJECT_ID = PARTY3.PARTY_ID
	AND PARTY3.PARTY_TYPE = 'PERSON'
	AND PARTY3.STATUS = 'A'
	AND PARTY_REL.OBJECT_ID = PARTY4.PARTY_ID
	AND PARTY4.PARTY_TYPE = 'ORGANIZATION'
	AND PARTY4.STATUS = 'A'
	AND PARTY_REL.RELATIONSHIP_ID = ORG_CONT.PARTY_RELATIONSHIP_ID
	AND TRUNC (PARTY_REL.START_DATE) <= TRUNC (SYSDATE)
	AND TRUNC (NVL (PARTY_REL.END_DATE, SYSDATE)) >= TRUNC (SYSDATE)
	AND ORG_CONT.ORG_CONTACT_ID = CONT_ROLE.ORG_CONTACT_ID (+)
	AND CONT_ROLE.PRIMARY_FLAG (+) = 'Y'
	AND PARTY_REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.DIRECTIONAL_FLAG = 'F'
	AND PARTY_REL.STATUS = 'A'
	AND party4.party_id = l_party_id
	AND ORG_CONT.ORG_CONTACT_ID = l_contact_id
	AND NVL(ORG_CONT.PARTY_SITE_ID,-99) = NVL(l_party_site_id,-99)
	;
   */
--



    CURSOR c_validate_party_address(
         l_party_site_id   IN  NUMBER )
    IS
         SELECT 'Y'
      FROM hz_party_sites
         WHERE party_site_id  = l_party_site_id;


    CURSOR c_validate_party_contact(
         l_party_id        IN  NUMBER,
         l_party_site_id   IN  NUMBER,
         l_contact_id      IN  NUMBER)
    IS
         SELECT 'Y'
     /* FROM jtf_rs_party_contacts_vl
         WHERE party_id = l_party_id
           AND nvl(party_site_id, 0) = nvl(l_party_site_id, 0)
           AND contact_id = l_contact_id; */
   -- changed the query the validate party contact id according to bug 2954064 as provided by the PRM team , sudarsana 2nd july 2004
       FROM hz_relationships hzr,
            hz_org_contacts hzoc
      WHERE hzr.party_id =  l_party_id
        AND hzoc.org_contact_id = l_contact_id
        AND hzr.directional_flag = 'F'
        AND hzr.relationship_code = 'EMPLOYEE_OF'
        AND hzr.subject_table_name ='HZ_PARTIES'
        AND hzr.object_table_name ='HZ_PARTIES'
        AND hzr.start_date <= SYSDATE
        AND (hzr.end_date is null or hzr.end_date > SYSDATE)
        AND hzr.status = 'A'
        AND hzoc.PARTY_RELATIONSHIP_ID = hzr.relationship_id;


   /* SQL Rep perf improvement bug 4956627  Nishant Singhai (14-Mar-2006) fixed by
      modifying query logic given in bug # 4052112
      OIC expanded the definition of compensation analyst to include any active user in the
      system regardless of their assignment to a CN responsibility.
   */
    CURSOR c_assigned_to_group_id(
         l_assigned_to_group_id    IN  NUMBER)
    IS
     SELECT u.user_id
       FROM fnd_user u,
            jtf_rs_resource_extns r
      WHERE u.user_id = r.user_id
        AND u.user_id = l_assigned_to_group_id;


    CURSOR c_validate_user_id(
         l_user_id        IN  NUMBER)
    IS
         SELECT 'Y'
      FROM jtf_rs_resource_extns
         WHERE user_id = l_user_id;

  -- Enh 3947611 2-dec-2004 added cursor to check emp existence
  CURSOR  c_emp_exist(p_person_id IN NUMBER)
      IS
  SELECT 'x' value,full_name
   FROM per_all_people_f
  WHERE person_id  = p_person_id;

   r_emp_exist c_emp_exist%rowtype;

  BEGIN

    l_category                := upper(p_category);
    l_source_id               := p_source_id;
    l_address_id              := p_address_id;
    l_contact_id              := p_contact_id;
    l_managing_emp_id         := p_managing_emp_id;
    l_managing_emp_num        := p_managing_emp_num;
    l_start_date_active       := p_start_date_active;
    l_end_date_active         := p_end_date_active;
    l_time_zone               := p_time_zone;
    l_cost_per_hr             := p_cost_per_hr;
    l_primary_language        := p_primary_language;
    l_secondary_language      := p_secondary_language;
    l_support_site_id         := p_support_site_id;
    l_ies_agent_login         := p_ies_agent_login;
    l_server_group_id         := p_server_group_id;
    l_interaction_center_name := p_interaction_center_name;
    l_assigned_to_group_id    := p_assigned_to_group_id;
    l_cost_center             := p_cost_center;
    l_charge_to_cost_center   := p_charge_to_cost_center;
    l_comp_currency_code      := p_comp_currency_code;
    l_commissionable_flag     := p_commissionable_flag;
    l_hold_reason_code        := p_hold_reason_code;
    l_hold_payment            := p_hold_payment;
    l_comp_service_team_id    := p_comp_service_team_id;
    l_user_id                 := p_user_id;
    l_transaction_number      := p_transaction_number;


    SAVEPOINT create_resource_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Create Resource Pub ');



    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;



    /* Validate the Resource Category */

    jtf_resource_utl.validate_resource_category(
      p_category => l_category,
      x_return_status => x_return_status
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /* Validate Source ID */

      jtf_resource_utl.validate_source_id (
         p_category		=> l_category,
         p_source_id		=> l_source_id,
	 p_address_id		=> l_address_id,
         x_return_status	=> x_return_status
      );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /* Validations for category as OTHER and TBH */

    IF l_category IN ('OTHER', 'TBH') THEN

      /* Validate that the source_id, address_id, contact_id and managing_employee_id
            are all NULL */

         IF (l_source_id IS NOT NULL OR l_address_id IS NOT NULL
             OR l_contact_id IS NOT NULL OR l_managing_emp_id IS NOT NULL
                OR l_managing_emp_num IS NOT NULL) THEN

--         dbms_output.put_line('For OTHER category, source_id, address_id, contact_id and managing_emp_id should be all null');

        fnd_message.set_name('JTF', 'JTF_RS_OTHER_IDS_NOT_NULL');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;

    /* Validations for category as PARTNER */

    IF l_category = 'PARTNER' THEN

      /* Validate the source_id */

      IF (l_source_id IS NULL)  THEN
--         dbms_output.put_line('For PARTNER category, source_id should not be null');
        fnd_message.set_name('JTF', 'JTF_RS_PARTNER_IDS_NULL');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      ELSE
         IF G_RS_ID_PUB_FLAG = 'Y' THEN --This flag is checked for migration purpose.
           OPEN c_validate_partner(l_source_id);
           FETCH c_validate_partner INTO l_check_flag;
           IF c_validate_partner%NOTFOUND THEN
--            dbms_output.put_line('Partner does not exist for the passed source_id');
              fnd_message.set_name('JTF', 'JTF_RS_INVALID_PARTNER_IDS');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
	   CLOSE c_validate_partner;
        ELSIF  G_RS_ID_PUB_FLAG = 'N' THEN
           OPEN c_validate_partner_migr(l_source_id);
           FETCH c_validate_partner_migr INTO l_check_flag,l_source_name;
           JTF_RESOURCE_UTL.G_SOURCE_NAME := l_source_name;
           IF c_validate_partner_migr%NOTFOUND THEN
--            dbms_output.put_line('Partner does not exist for the passed source_id');
              fnd_message.set_name('JTF', 'JTF_RS_INVALID_PARTNER_IDS');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
	   CLOSE c_validate_partner_migr;
        END IF;
      END IF;

      /* Validate the address_id if specified */

      IF l_address_id IS NOT NULL THEN
        OPEN c_validate_partner_address(l_source_id, l_address_id);
        FETCH c_validate_partner_address INTO l_check_flag;
        IF c_validate_partner_address%NOTFOUND THEN
--         dbms_output.put_line('Invalid Partner Address Id');
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PARTNER_ADDRESS_ID');
           fnd_message.set_token('P_ADDRESS_ID', l_address_id);
           fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
        CLOSE c_validate_partner_address;
     END IF;


      /* Validate the contact_id if specified */

      IF l_contact_id IS NOT NULL THEN
        OPEN c_validate_partner_contact(l_source_id, l_address_id, l_contact_id);
        FETCH c_validate_partner_contact INTO l_check_flag;
        IF c_validate_partner_contact%NOTFOUND THEN
--         dbms_output.put_line('Invalid Partner Contact Id');
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PARTNER_CONTACT_ID');
           fnd_message.set_token('P_CONTACT_ID', l_contact_id);
           fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
        CLOSE c_validate_partner_contact;
     END IF;

   END IF;

    /* For all other Categories, validate the source_id from jtf_objects */
    /* Enh 3947611 2-dec-2004 : added EMPLOYEE to the exception also.  Import future dated employees
       this had to be an exception else the seed data for object EMPLOYEE if jtf_objects had to be changed. This may have
       some backward compatibility issues for consumers who use JTF_OBJECTS to validate OR list EMPLOYEE
    */
      IF l_category NOT IN ('OTHER' , 'PARTNER' , 'TBH', 'EMPLOYEE') THEN
        IF l_source_id IS NULL THEN
--          dbms_output.put_line('Source Id should not be Null');
            fnd_message.set_name('JTF', 'JTF_RS_SOURCE_ID_NULL');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

        jtf_resource_utl.check_object_existence_migr(

        P_OBJECT_CODE 		=> l_category,
        P_SELECT_ID 		=> l_source_id,
        P_OBJECT_USER_CODE 	=> 'RESOURCE_CATEGORIES',
        P_RS_ID_PUB_FLAG	=> G_RS_ID_PUB_FLAG,
        X_FOUND 		=> l_found,
        X_RETURN_STATUS 	=> x_return_status
        );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	     IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	         RAISE FND_API.G_EXC_ERROR;
         ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      	 END IF;
      END IF;

      IF l_found = FALSE THEN
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_SOURCE_ID');
        fnd_message.set_token('P_SOURCE_ID', l_source_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

     /* Enh 3947611 2-dec-2004:EMPLOYEE VALIDATION has been removed from the above code. so adding validation
        for EMPLOYEE
    */

    if l_category = 'EMPLOYEE' THEN
       -- First check is null check for source id
       IF l_source_id IS NULL THEN
            fnd_message.set_name('JTF', 'JTF_RS_SOURCE_ID_NULL');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

        open c_emp_exist(l_source_id);
        fetch c_emp_exist into r_emp_exist;
        close c_emp_exist;

        if(nvl(r_emp_exist.value , 'y') <> 'x')
        then
           fnd_message.set_name('JTF', 'JTF_RS_INVALID_SOURCE_ID');
           fnd_message.set_token('P_SOURCE_ID', l_source_id);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
        end if;

    END IF; -- end of check l_category = 'EMPLOYEE'

    /* Validations for category as PARTY */

    IF l_category = 'PARTY' THEN

      /* Validate the address_id if specified */

      IF l_address_id IS NOT NULL THEN

        OPEN c_validate_party_address(l_address_id);

        FETCH c_validate_party_address INTO l_check_flag;


        IF c_validate_party_address%NOTFOUND THEN

--          dbms_output.put_line('Invalid Party Address');

          fnd_message.set_name('JTF', 'JTF_RS_INVALID_PARTY_ADDRESS');
          fnd_message.set_token('P_ADDRESS_ID', l_address_id);
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;

        END IF;

        /* Close the cursor */

        CLOSE c_validate_party_address;


      END IF;


      /* Validate the contact_id if specified */

      IF l_contact_id IS NOT NULL THEN

        OPEN c_validate_party_contact(l_source_id, l_address_id, l_contact_id);

        FETCH c_validate_party_contact INTO l_check_flag;


        IF c_validate_party_contact%NOTFOUND THEN

--          dbms_output.put_line('Invalid Party Contact Id');

          fnd_message.set_name('JTF', 'JTF_RS_ERR_PARTY_CONTACT_ID');
          fnd_message.set_token('P_CONTACT_ID', l_contact_id);
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;

        END IF;


        /* Close the cursor */

        CLOSE c_validate_party_contact;

         END IF;

    END IF;



    /* Validations for category as SUPPLIER_CONTACT */

    IF l_category = 'SUPPLIER_CONTACT' THEN

      /* Validate that the address_id and contact_id are NULL */

      -- address_id check (NOT NULL) being removed, to store the address_id of supplier contact
      -- Fix for bug # 3812930
      IF (l_contact_id IS NOT NULL) THEN

--         dbms_output.put_line('For SUPPLIER_CONTACT category, address_id and contact_id should be null');

        fnd_message.set_name('JTF', 'JTF_RS_SC_IDS_NOT_NULL');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;


    /* Validations for category as EMPLOYEE */
/* Removed 'WORKER' from the below code to fix bug # 3455951 */
    IF l_category = 'EMPLOYEE' THEN

      /* Validate that the address_id, contact_id and managing_emp_id are NULL */

      --address_id check (null) being removed, to store the address_id of employee 03/26/01

      IF (l_contact_id IS NOT NULL OR l_managing_emp_id IS NOT NULL OR l_managing_emp_num IS NOT NULL) THEN

--         dbms_output.put_line('For EMPLOYEE category, contact_id should be null');

        fnd_message.set_name('JTF', 'JTF_RS_EMP_IDS_NOT_NULL');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;



    /* Validate the Managing Employee Id if specified */

    jtf_resource_utl.validate_employee_resource(
      p_emp_resource_id => l_managing_emp_id,
      p_emp_resource_number => l_managing_emp_num,
      x_return_status => x_return_status,
      x_emp_resource_id => l_managing_emp_id_out
    );
-- added for NOCOPY
    l_managing_emp_id := l_managing_emp_id_out;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;


    /* Validate that the Start Date Active is specified */

    IF l_start_date_active IS NULL THEN

--       dbms_output.put_line('Start Date Active cannot be null');

      fnd_message.set_name('JTF', 'JTF_RS_START_DATE_NULL');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    END IF;



    /* Validate the Time Zone */

    IF l_time_zone IS NOT NULL THEN

      jtf_resource_utl.validate_time_zone(
        p_time_zone_id => l_time_zone,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
      END IF;

    END IF;



    /* Validate the Primary Language */

    IF l_primary_language IS NOT NULL THEN

      jtf_resource_utl.validate_nls_language(
        p_nls_language => l_primary_language,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
      END IF;

    END IF;



    /* Validate the Secondary Language */

    IF l_secondary_language IS NOT NULL THEN

      jtf_resource_utl.validate_nls_language(
        p_nls_language => l_secondary_language,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
      END IF;

    END IF;



    /* Validate the Support Site */

    IF l_support_site_id IS NOT NULL THEN

      jtf_resource_utl.validate_support_site_id(
        p_support_site_id => l_support_site_id,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
      END IF;

    END IF;



    /* Validate the Server Group. */

    jtf_resource_utl.validate_server_group(
      p_server_group_id => l_server_group_id,
      p_server_group_name => l_interaction_center_name,
      x_return_status => x_return_status,
      x_server_group_id => l_server_group_id_out
    );

-- added for NOCOPY
   l_server_group_id  := l_server_group_id_out;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;


    /* Validate the assigned_to_group_id if specified */

    IF l_assigned_to_group_id IS NOT NULL THEN

      OPEN c_assigned_to_group_id(l_assigned_to_group_id);

      FETCH c_assigned_to_group_id INTO l_assigned_to_group_id;


      IF c_assigned_to_group_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid Assigned To Group Id');

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ASSIGN_TO_GRP_ID');
        fnd_message.set_token('P_ASSIGNED_TO_GROUP_ID', l_assigned_to_group_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

      END IF;


      /* Close the cursor */

      CLOSE c_assigned_to_group_id;

    END IF;



    /* Validate the Comp Currency Code */

    IF l_comp_currency_code IS NOT NULL THEN

      jtf_resource_utl.validate_currency_code(
        p_currency_code => l_comp_currency_code,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
      END IF;

    END IF;


    /* Validate the value of the commisionable flag */

    IF l_commissionable_flag <> 'Y' AND l_commissionable_flag <> 'N' THEN

--       dbms_output.put_line('Commissionable Flag should either be ''Y'' or ''N'' ');

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    END IF;


    /* Validate the value of the Hold Payment flag */

    IF l_hold_payment <> 'Y' AND l_hold_payment <> 'N' THEN

--       dbms_output.put_line('Hold Payment should either be ''Y'' or ''N'' ');

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;

    END IF;



    /* Validate the Hold Reason Code */

    IF l_hold_reason_code IS NOT NULL THEN

      jtf_resource_utl.validate_hold_reason_code(
        p_hold_reason_code => l_hold_reason_code,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
      END IF;

    END IF;


    /* Validate that the user_id should only be specified in case of
          'EMPLOYEE', 'PARTY', 'SUPPLIER_CONTACT' categories */
/* Removed 'WORKER' from the below code to fix bug # 3455951 */
    IF l_category NOT IN ('EMPLOYEE', 'PARTY', 'SUPPLIER_CONTACT') THEN

         IF l_user_id IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_USERID_ERROR');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

         END IF;

    ELSE

      /* Validate the User Id if specified */

      IF l_user_id IS NOT NULL THEN

        jtf_resource_utl.validate_user_id(
          p_user_id => l_user_id,
          p_category => l_category,
          p_source_id => l_source_id,
          x_return_status => x_return_status
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

           IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

        else

        OPEN c_validate_user_id(l_user_id);

        FETCH c_validate_user_id INTO l_check_flag;


        IF c_validate_user_id%FOUND THEN

--          dbms_output.put_line('duplicate user Id');

          fnd_message.set_name('JTF', 'JTF_RS_ERR_DUPLICATE_USER_ID');
          fnd_message.set_token('P_USER_ID', l_user_id);
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;

        END IF;


        /* Close the cursor */

        CLOSE c_validate_user_id;



        END IF;

      END IF;

    END IF;


    /* Validate the Comp Service Team Id if specified */

    IF l_comp_service_team_id IS NOT NULL THEN

      jtf_resource_utl.validate_resource_team(
        p_team_id => l_comp_service_team_id,
        p_team_number => null,
        x_return_status => x_return_status,
        x_team_id => l_comp_service_team_id_out
      );

-- added for NOCOPY
   l_comp_service_team_id := l_comp_service_team_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;

    END IF;


    /* Check the Global Variable for Resource ID, and call the appropriate Private API */

--   dbms_output.put_line ('Before setting the global flag in create_resource');

       IF G_RS_ID_PUB_FLAG = 'Y' THEN

         /* Call the private procedure with the validated parameters. */

--    dbms_output.put_line ('Before call to the private procedure create_resource');

         jtf_rs_resource_pvt.create_resource (
            P_API_VERSION 		=> 1,
            P_INIT_MSG_LIST 		=> fnd_api.g_false,
            P_COMMIT 			=> fnd_api.g_false,
            P_CATEGORY 			=> l_category,
            P_SOURCE_ID 		=> l_source_id,
            P_ADDRESS_ID 		=> l_address_id,
            P_CONTACT_ID 		=> l_contact_id,
            P_MANAGING_EMP_ID 		=> l_managing_emp_id,
            P_START_DATE_ACTIVE 	=> l_start_date_active,
            P_END_DATE_ACTIVE 		=> l_end_date_active,
            P_TIME_ZONE 		=> l_time_zone,
            P_COST_PER_HR 		=> l_cost_per_hr,
            P_PRIMARY_LANGUAGE 		=> l_primary_language,
            P_SECONDARY_LANGUAGE 	=> l_secondary_language,
            P_SUPPORT_SITE_ID 		=> l_support_site_id,
            P_IES_AGENT_LOGIN 		=> l_ies_agent_login,
            P_SERVER_GROUP_ID 		=> l_server_group_id,
            P_ASSIGNED_TO_GROUP_ID 	=> l_assigned_to_group_id,
            P_COST_CENTER 		=> l_cost_center,
            P_CHARGE_TO_COST_CENTER 	=> l_charge_to_cost_center,
            P_COMP_CURRENCY_CODE 	=> l_comp_currency_code,
            P_COMMISSIONABLE_FLAG 	=> l_commissionable_flag,
            P_HOLD_REASON_CODE 		=> l_hold_reason_code,
            P_HOLD_PAYMENT 		=> l_hold_payment,
            P_COMP_SERVICE_TEAM_ID 	=> l_comp_service_team_id,
            P_USER_ID 			=> l_user_id,
            P_TRANSACTION_NUMBER 	=> l_transaction_number,
          --P_LOCATION 			=> l_location,
            X_RETURN_STATUS 		=> x_return_status,
            X_MSG_COUNT 		=> x_msg_count,
            X_MSG_DATA 			=> x_msg_data,
            X_RESOURCE_ID 		=> x_resource_id,
            X_RESOURCE_NUMBER 		=> x_resource_number
         );

    /*     jtf_rs_resource_pvt.create_resource (
            P_API_VERSION 		=> 1,
            P_INIT_MSG_LIST 		=> fnd_api.g_false,
            P_COMMIT 			=> fnd_api.g_false,
            P_CATEGORY 			=> l_category,
            P_SOURCE_ID 		=> l_source_id,
            P_ADDRESS_ID 		=> l_address_id,
            P_CONTACT_ID 		=> l_contact_id,
            P_MANAGING_EMP_ID 		=> l_managing_emp_id,
            P_START_DATE_ACTIVE 	=> l_start_date_active,
            P_END_DATE_ACTIVE 		=> l_end_date_active,
            P_TIME_ZONE 		=> l_time_zone,
            P_COST_PER_HR 		=> l_cost_per_hr,
            P_PRIMARY_LANGUAGE 		=> l_primary_language,
            P_SECONDARY_LANGUAGE 	=> l_secondary_language,
            P_SUPPORT_SITE_ID 		=> l_support_site_id,
            P_IES_AGENT_LOGIN 		=> l_ies_agent_login,
            P_SERVER_GROUP_ID 		=> l_server_group_id,
            P_ASSIGNED_TO_GROUP_ID 	=> l_assigned_to_group_id,
            P_COST_CENTER 		=> l_cost_center,
            P_CHARGE_TO_COST_CENTER 	=> l_charge_to_cost_center,
            P_COMP_CURRENCY_CODE 	=> l_comp_currency_code,
            P_COMMISSIONABLE_FLAG 	=> l_commissionable_flag,
            P_HOLD_REASON_CODE 		=> l_hold_reason_code,
            P_HOLD_PAYMENT 		=> l_hold_payment,
            P_COMP_SERVICE_TEAM_ID 	=> l_comp_service_team_id,
            P_USER_ID 			=> l_user_id,
            P_TRANSACTION_NUMBER 	=> l_transaction_number,
          --P_LOCATION 			=> l_location,
            X_RETURN_STATUS 		=> x_return_status,
            X_MSG_COUNT 		=> x_msg_count,
            X_MSG_DATA 			=> x_msg_data,
            X_RESOURCE_ID 		=> x_resource_id,
            X_RESOURCE_NUMBER 		=> x_resource_number,
            P_RESOURCE_NAME             => JTF_RS_RESOURCE_PUB.G_RESOURCE_NAME ,
            P_SOURCE_NAME               => JTF_RS_RESOURCE_PUB.G_SOURCE_NAME,
            P_SOURCE_NUMBER             => JTF_RS_RESOURCE_PUB.G_SOURCE_NUMBER,
            P_SOURCE_JOB_TITLE          => JTF_RS_RESOURCE_PUB.G_SOURCE_JOB_TITLE,
            P_SOURCE_EMAIL              => JTF_RS_RESOURCE_PUB.G_SOURCE_EMAIL,
            P_SOURCE_PHONE              => JTF_RS_RESOURCE_PUB.G_SOURCE_PHONE,
            P_SOURCE_ORG_ID             => JTF_RS_RESOURCE_PUB.G_SOURCE_ORG_ID,
            P_SOURCE_ORG_NAME           => JTF_RS_RESOURCE_PUB.G_SOURCE_ORG_NAME,
            P_SOURCE_ADDRESS1           => JTF_RS_RESOURCE_PUB.G_SOURCE_ADDRESS1,
            P_SOURCE_ADDRESS2           => JTF_RS_RESOURCE_PUB.G_SOURCE_ADDRESS2,
            P_SOURCE_ADDRESS3           => JTF_RS_RESOURCE_PUB.G_SOURCE_ADDRESS3,
            P_SOURCE_ADDRESS4           => JTF_RS_RESOURCE_PUB.G_SOURCE_ADDRESS4,
            P_SOURCE_CITY               => JTF_RS_RESOURCE_PUB.G_SOURCE_CITY,
            P_SOURCE_POSTAL_CODE        => JTF_RS_RESOURCE_PUB.G_SOURCE_POSTAL_CODE,
            P_SOURCE_STATE              => JTF_RS_RESOURCE_PUB.G_SOURCE_STATE,
            P_SOURCE_PROVINCE           => JTF_RS_RESOURCE_PUB.G_SOURCE_PROVINCE,
            P_SOURCE_COUNTY             => JTF_RS_RESOURCE_PUB.G_SOURCE_COUNTY,
            P_SOURCE_COUNTRY            => JTF_RS_RESOURCE_PUB.G_SOURCE_COUNTRY
         );

*/

         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
            ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

       ELSE

--        dbms_output.put_line ('Before call to the private API create_resource_migrate' );

         /* Call the private procedure for Migration. */

         jtf_rs_resource_pvt.create_resource_migrate (
            P_API_VERSION               => 1,
            P_INIT_MSG_LIST             => fnd_api.g_false,
            P_COMMIT                    => fnd_api.g_false,
            P_CATEGORY                  => l_category,
            P_SOURCE_ID                 => l_source_id,
            P_ADDRESS_ID                => l_address_id,
            P_CONTACT_ID                => l_contact_id,
            P_MANAGING_EMP_ID           => l_managing_emp_id,
            P_START_DATE_ACTIVE         => l_start_date_active,
            P_END_DATE_ACTIVE           => l_end_date_active,
            P_TIME_ZONE                 => l_time_zone,
            P_COST_PER_HR               => l_cost_per_hr,
            P_PRIMARY_LANGUAGE          => l_primary_language,
            P_SECONDARY_LANGUAGE        => l_secondary_language,
            P_SUPPORT_SITE_ID           => l_support_site_id,
            P_IES_AGENT_LOGIN           => l_ies_agent_login,
            P_SERVER_GROUP_ID           => l_server_group_id,
            P_ASSIGNED_TO_GROUP_ID      => l_assigned_to_group_id,
            P_COST_CENTER               => l_cost_center,
            P_CHARGE_TO_COST_CENTER     => l_charge_to_cost_center,
            P_COMP_CURRENCY_CODE        => l_comp_currency_code,
            P_COMMISSIONABLE_FLAG       => l_commissionable_flag,
            P_HOLD_REASON_CODE          => l_hold_reason_code,
            P_HOLD_PAYMENT              => l_hold_payment,
            P_COMP_SERVICE_TEAM_ID      => l_comp_service_team_id,
            P_USER_ID                   => l_user_id,
            P_TRANSACTION_NUMBER        => l_transaction_number,
          --P_LOCATION                  => l_location,
            P_RESOURCE_ID		=> G_RESOURCE_ID,
            P_ATTRIBUTE1		=> G_ATTRIBUTE1,
            P_ATTRIBUTE2                => G_ATTRIBUTE2,
            P_ATTRIBUTE3                => G_ATTRIBUTE3,
            P_ATTRIBUTE4                => G_ATTRIBUTE4,
            P_ATTRIBUTE5                => G_ATTRIBUTE5,
            P_ATTRIBUTE6                => G_ATTRIBUTE6,
            P_ATTRIBUTE7                => G_ATTRIBUTE7,
            P_ATTRIBUTE8                => G_ATTRIBUTE8,
            P_ATTRIBUTE9                => G_ATTRIBUTE9,
            P_ATTRIBUTE10               => G_ATTRIBUTE10,
            P_ATTRIBUTE11               => G_ATTRIBUTE11,
            P_ATTRIBUTE12               => G_ATTRIBUTE12,
            P_ATTRIBUTE13               => G_ATTRIBUTE13,
            P_ATTRIBUTE14               => G_ATTRIBUTE14,
            P_ATTRIBUTE15               => G_ATTRIBUTE15,
            P_ATTRIBUTE_CATEGORY        => G_ATTRIBUTE_CATEGORY,
            X_RETURN_STATUS             => x_return_status,
            X_MSG_COUNT                 => x_msg_count,
            X_MSG_DATA                  => x_msg_data,
            X_RESOURCE_ID               => x_resource_id,
            X_RESOURCE_NUMBER           => x_resource_number
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
--          dbms_output.put_line('Failed status from call to private procedure');
            IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
            ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

      END IF;

    IF fnd_api.to_boolean(p_commit) THEN

         COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION


    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_resource_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_resource_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_resource_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END create_resource;

  PROCEDURE  create_resource_migrate (
   P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE,
   P_MANAGING_EMP_NUM        IN   PER_EMPLOYEES_CURRENT_X.EMPLOYEE_NUM%TYPE,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
   P_INTERACTION_CENTER_NAME IN   VARCHAR2,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY,
   P_RESOURCE_ID	     IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_ATTRIBUTE1              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER	     OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE
  ) IS


    BEGIN

--dbms_output.put_line ('Inside the create_resource_migrate pub body');

     JTF_RESOURCE_UTL.G_SOURCE_NAME := NULL;


     JTF_RS_RESOURCE_PUB.G_RS_ID_PUB_FLAG 	:= 'N';
     JTF_RS_RESOURCE_PUB.G_RESOURCE_ID		:= P_RESOURCE_ID;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE1		:= P_ATTRIBUTE1;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE2           := P_ATTRIBUTE2;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE3           := P_ATTRIBUTE3;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE4           := P_ATTRIBUTE4;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE5           := P_ATTRIBUTE5;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE6           := P_ATTRIBUTE6;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE7           := P_ATTRIBUTE7;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE8           := P_ATTRIBUTE8;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE9           := P_ATTRIBUTE9;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE10          := P_ATTRIBUTE10;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE11          := P_ATTRIBUTE11;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE12          := P_ATTRIBUTE12;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE13          := P_ATTRIBUTE13;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE14          := P_ATTRIBUTE14;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE15          := P_ATTRIBUTE15;
     JTF_RS_RESOURCE_PUB.G_ATTRIBUTE_CATEGORY   := P_ATTRIBUTE_CATEGORY;

--dbms_output.put_line ('After assigning values to the Global variables');

     jtf_rs_resource_pub.create_resource (
        P_API_VERSION             =>  P_API_VERSION,
   	P_INIT_MSG_LIST           =>  P_INIT_MSG_LIST,
   	P_COMMIT                  =>  P_COMMIT,
   	P_CATEGORY                =>  P_CATEGORY,
   	P_SOURCE_ID               =>  P_SOURCE_ID,
   	P_ADDRESS_ID              =>  P_ADDRESS_ID,
   	P_CONTACT_ID              =>  P_CONTACT_ID,
   	P_MANAGING_EMP_ID         =>  P_MANAGING_EMP_ID,
   	P_MANAGING_EMP_NUM        =>  P_MANAGING_EMP_NUM,
   	P_START_DATE_ACTIVE       =>  P_START_DATE_ACTIVE,
   	P_END_DATE_ACTIVE         =>  P_END_DATE_ACTIVE,
   	P_TIME_ZONE               =>  P_TIME_ZONE,
   	P_COST_PER_HR             =>  P_COST_PER_HR,
   	P_SECONDARY_LANGUAGE      =>  P_SECONDARY_LANGUAGE,
   	P_SUPPORT_SITE_ID         =>  P_SUPPORT_SITE_ID,
   	P_IES_AGENT_LOGIN         =>  P_IES_AGENT_LOGIN,
   	P_SERVER_GROUP_ID         =>  P_SERVER_GROUP_ID,
   	P_INTERACTION_CENTER_NAME =>  P_INTERACTION_CENTER_NAME,
   	P_ASSIGNED_TO_GROUP_ID    =>  P_ASSIGNED_TO_GROUP_ID,
   	P_COST_CENTER             =>  P_COST_CENTER,
   	P_CHARGE_TO_COST_CENTER   =>  P_CHARGE_TO_COST_CENTER,
   	P_COMP_CURRENCY_CODE      =>  P_COMP_CURRENCY_CODE,
   	P_COMMISSIONABLE_FLAG     =>  P_COMMISSIONABLE_FLAG,
   	P_HOLD_REASON_CODE        =>  P_HOLD_REASON_CODE,
   	P_HOLD_PAYMENT            =>  P_HOLD_PAYMENT,
   	P_COMP_SERVICE_TEAM_ID    =>  P_COMP_SERVICE_TEAM_ID,
   	P_USER_ID                 =>  P_USER_ID,
   	P_TRANSACTION_NUMBER      =>  P_TRANSACTION_NUMBER,
      --P_LOCATION                =>  P_LOCATION,
   	X_RETURN_STATUS           =>  X_RETURN_STATUS,
   	X_MSG_COUNT               =>  X_MSG_COUNT,
   	X_MSG_DATA                =>  X_MSG_DATA,
   	X_RESOURCE_ID             =>  X_RESOURCE_ID,
   	X_RESOURCE_NUMBER         =>  X_RESOURCE_NUMBER);

--dbms_output.put_line ('After Call to create_resource in the Migr API');

  END create_resource_migrate;

  /* Procedure to update the resource based on input values
        passed by calling routines. */

  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER         IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
  -- P_LOCATION                IN   MDSYS.SDO_GEOMETRY,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';
    l_resource_id                  jtf_rs_resource_extns.resource_id%TYPE;
    l_resource_number              jtf_rs_resource_extns.resource_number%TYPE;
    l_managing_emp_id              jtf_rs_resource_extns.managing_employee_id%TYPE;
    l_start_date_active            jtf_rs_resource_extns.start_date_active%TYPE;
    l_end_date_active              jtf_rs_resource_extns.end_date_active%TYPE;
    l_time_zone                    jtf_rs_resource_extns.time_zone%TYPE;
    l_cost_per_hr                  jtf_rs_resource_extns.cost_per_hr%TYPE;
    l_primary_language             jtf_rs_resource_extns.primary_language%TYPE;
    l_secondary_language           jtf_rs_resource_extns.secondary_language%TYPE;
    l_support_site_id              jtf_rs_resource_extns.support_site_id%TYPE;
    l_ies_agent_login              jtf_rs_resource_extns.ies_agent_login%TYPE;
    l_server_group_id              jtf_rs_resource_extns.server_group_id%TYPE;
    l_assigned_to_group_id         jtf_rs_resource_extns.assigned_to_group_id%TYPE;
    l_cost_center                  jtf_rs_resource_extns.cost_center%TYPE;
    l_charge_to_cost_center        jtf_rs_resource_extns.charge_to_cost_center%TYPE;
    l_comp_currency_code           jtf_rs_resource_extns.compensation_currency_code%TYPE;
    l_commissionable_flag          jtf_rs_resource_extns.commissionable_flag%TYPE;
    l_hold_reason_code             jtf_rs_resource_extns.hold_reason_code%TYPE;
    l_hold_payment                 jtf_rs_resource_extns.hold_payment%TYPE;
    l_comp_service_team_id         jtf_rs_resource_extns.comp_service_team_id%TYPE;
    l_user_id                      jtf_rs_resource_extns.user_id%TYPE;
   -- l_location                     mdsys.sdo_geometry;
    l_object_version_num           jtf_rs_resource_extns.object_version_number%TYPE;

    l_check_resource_id            jtf_rs_resource_extns.resource_id%TYPE;
    l_check_resource_number              jtf_rs_resource_extns.resource_number%TYPE;


    CURSOR c_resource_id(
         l_resource_id    IN  NUMBER)
    IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = l_resource_id;


    CURSOR c_resource_number(
         l_resource_number    IN  VARCHAR2)
    IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE resource_number = l_resource_number;


  BEGIN

    l_resource_id             := p_resource_id;
    l_resource_number         := p_resource_number;
    l_managing_emp_id         := p_managing_emp_id;
    l_start_date_active       := p_start_date_active;
    l_end_date_active         := p_end_date_active;
    l_time_zone               := p_time_zone;
    l_cost_per_hr             := p_cost_per_hr;
    l_primary_language        := p_primary_language;
    l_secondary_language      := p_secondary_language;
    l_support_site_id         := p_support_site_id;
    l_ies_agent_login         := p_ies_agent_login;
    l_server_group_id         := p_server_group_id;
    l_assigned_to_group_id    := p_assigned_to_group_id;
    l_cost_center             := p_cost_center;
    l_charge_to_cost_center   := p_charge_to_cost_center;
    l_comp_currency_code      := p_comp_currency_code;
    l_commissionable_flag     := p_commissionable_flag;
    l_hold_reason_code        := p_hold_reason_code;
    l_hold_payment            := p_hold_payment;
    l_comp_service_team_id    := p_comp_service_team_id;
    l_user_id                 := p_user_id;
    l_object_version_num      := p_object_version_num;


    SAVEPOINT update_resource_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    dbms_output.put_line(' Started Update Resource Pub ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Validate the Resource. */

    IF l_resource_id IS NULL AND l_resource_number is NULL THEN

--      dbms_output.put_line('Resource Id and Resource Number are null');

      fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_NULL');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    END IF;


    IF l_resource_id IS NOT NULL THEN

      OPEN c_resource_id(l_resource_id);

      FETCH c_resource_id INTO l_check_resource_id;

      IF c_resource_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid or Inactive Resource');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE');
        fnd_message.set_token('P_RESOURCE_ID', l_resource_id);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

      CLOSE c_resource_id;

    ELSIF l_resource_number IS NOT NULL THEN

      OPEN c_resource_number(l_resource_number);

      FETCH c_resource_number INTO l_check_resource_number;

      IF c_resource_number%NOTFOUND THEN

--        dbms_output.put_line('Invalid or Inactive Resource');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE_NUMBER');
        fnd_message.set_token('P_RESOURCE_NUMBER', l_resource_number);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

      CLOSE c_resource_number;

    END IF;



    /* Call the private procedure with the validated parameters. */

    jtf_rs_resource_pvt.update_resource
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_RESOURCE_ID => l_resource_id,
     P_MANAGING_EMP_ID => l_managing_emp_id,
     P_START_DATE_ACTIVE => l_start_date_active,
     P_END_DATE_ACTIVE => l_end_date_active,
     P_TIME_ZONE => l_time_zone,
     P_COST_PER_HR => l_cost_per_hr,
     P_PRIMARY_LANGUAGE => l_primary_language,
     P_SECONDARY_LANGUAGE => l_secondary_language,
     P_SUPPORT_SITE_ID => l_support_site_id,
     P_IES_AGENT_LOGIN => l_ies_agent_login,
     P_SERVER_GROUP_ID => l_server_group_id,
     P_ASSIGNED_TO_GROUP_ID => l_assigned_to_group_id,
     P_COST_CENTER => l_cost_center,
     P_CHARGE_TO_COST_CENTER => l_charge_to_cost_center,
     P_COMP_CURRENCY_CODE => l_comp_currency_code,
     P_COMMISSIONABLE_FLAG => l_commissionable_flag,
     P_HOLD_REASON_CODE => l_hold_reason_code,
     P_HOLD_PAYMENT => l_hold_payment,
     P_COMP_SERVICE_TEAM_ID => l_comp_service_team_id,
     P_USER_ID => l_user_id,
     --P_LOCATION => l_location,
     P_OBJECT_VERSION_NUM => l_object_version_num,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
 --added this so that the overloaded procedure for update resource is called
 -- otherwise all source coulmns were being set to null
    P_SOURCE_NAME => fnd_api.g_miss_char
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    END IF;

      /* Return the new value of the object version number */

      p_object_version_num := l_object_version_num;

    IF fnd_api.to_boolean(p_commit) THEN

         COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_resource_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_resource_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_resource_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END update_resource;

  /* Procedure to update the resource with new columns based on input values
        passed by calling routines. */

  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER         IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
  -- P_LOCATION                IN   MDSYS.SDO_GEOMETRY,
   P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE,
   P_SOURCE_NAME             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
   P_SOURCE_NUMBER           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE,
   P_SOURCE_JOB_TITLE        IN   JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_TITLE%TYPE,
   P_SOURCE_EMAIL            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE,
   P_SOURCE_PHONE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PHONE%TYPE,
   P_SOURCE_ORG_ID           IN   NUMBER,
   P_SOURCE_ORG_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_NAME%TYPE,
   P_SOURCE_ADDRESS1         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS1%TYPE,
   P_SOURCE_ADDRESS2         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS2%TYPE,
   P_SOURCE_ADDRESS3         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS3%TYPE,
   P_SOURCE_ADDRESS4         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS4%TYPE,
   P_SOURCE_CITY             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_CITY%TYPE,
   P_SOURCE_POSTAL_CODE      IN   JTF_RS_RESOURCE_EXTNS.SOURCE_POSTAL_CODE%TYPE,
   P_SOURCE_STATE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_STATE%TYPE,
   P_SOURCE_PROVINCE         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PROVINCE%TYPE,
   P_SOURCE_COUNTY           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTY%TYPE,
   P_SOURCE_COUNTRY          IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTRY%TYPE,
   P_SOURCE_MGR_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_ID%TYPE,
   P_SOURCE_MGR_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_NAME%TYPE,
   P_SOURCE_BUSINESS_GRP_ID  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_ID%TYPE,
   P_SOURCE_BUSINESS_GRP_NAME IN  JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_NAME%TYPE,
   P_SOURCE_FIRST_NAME       IN JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE,
   P_SOURCE_LAST_NAME        IN JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE,
   P_SOURCE_MIDDLE_NAME      IN JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE,
   P_SOURCE_CATEGORY         IN JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE,
   P_SOURCE_STATUS           IN JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE,
   P_SOURCE_OFFICE           IN JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE,
   P_SOURCE_LOCATION         IN JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE,
   P_SOURCE_MAILSTOP         IN JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE,
   P_ADDRESS_ID              IN JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
   P_OBJECT_VERSION_NUM      IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   P_USER_NAME               IN VARCHAR2,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   P_SOURCE_MOBILE_PHONE     IN JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE,
   P_SOURCE_PAGER            IN JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE,
   P_ATTRIBUTE1              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';
    l_resource_id                  jtf_rs_resource_extns.resource_id%TYPE;
    l_resource_number              jtf_rs_resource_extns.resource_number%TYPE;
    l_managing_emp_id              jtf_rs_resource_extns.managing_employee_id%TYPE;
    l_start_date_active            jtf_rs_resource_extns.start_date_active%TYPE;
    l_end_date_active              jtf_rs_resource_extns.end_date_active%TYPE;
    l_time_zone                    jtf_rs_resource_extns.time_zone%TYPE;
    l_cost_per_hr                  jtf_rs_resource_extns.cost_per_hr%TYPE;
    l_primary_language             jtf_rs_resource_extns.primary_language%TYPE;
    l_secondary_language           jtf_rs_resource_extns.secondary_language%TYPE;
    l_support_site_id              jtf_rs_resource_extns.support_site_id%TYPE;
    l_ies_agent_login              jtf_rs_resource_extns.ies_agent_login%TYPE;
    l_server_group_id              jtf_rs_resource_extns.server_group_id%TYPE;
    l_assigned_to_group_id         jtf_rs_resource_extns.assigned_to_group_id%TYPE;
    l_cost_center                  jtf_rs_resource_extns.cost_center%TYPE;
    l_charge_to_cost_center        jtf_rs_resource_extns.charge_to_cost_center%TYPE;
    l_comp_currency_code           jtf_rs_resource_extns.compensation_currency_code%TYPE;
    l_commissionable_flag          jtf_rs_resource_extns.commissionable_flag%TYPE;
    l_hold_reason_code             jtf_rs_resource_extns.hold_reason_code%TYPE;
    l_hold_payment                 jtf_rs_resource_extns.hold_payment%TYPE;
    l_comp_service_team_id         jtf_rs_resource_extns.comp_service_team_id%TYPE;
    l_user_id                      jtf_rs_resource_extns.user_id%TYPE;
   -- l_location                     mdsys.sdo_geometry;
    l_object_version_num           jtf_rs_resource_extns.object_version_number%TYPE;
    l_user_name                    jtf_rs_resource_extns.user_name%type;
    l_check_resource_id            jtf_rs_resource_extns.resource_id%TYPE;
    l_check_resource_number              jtf_rs_resource_extns.resource_number%TYPE;


    CURSOR c_resource_id(
         l_resource_id    IN  NUMBER)
    IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = l_resource_id;


    CURSOR c_resource_number(
         l_resource_number    IN  VARCHAR2)
    IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE resource_number = l_resource_number;


  BEGIN

    l_resource_id                   := p_resource_id;
    l_resource_number               := p_resource_number;
    l_managing_emp_id               := p_managing_emp_id;
    l_start_date_active             := p_start_date_active;
    l_end_date_active               := p_end_date_active;
    l_time_zone                     := p_time_zone;
    l_cost_per_hr                   := p_cost_per_hr;
    l_primary_language              := p_primary_language;
    l_secondary_language            := p_secondary_language;
    l_support_site_id               := p_support_site_id;
    l_ies_agent_login               := p_ies_agent_login;
    l_server_group_id               := p_server_group_id;
    l_assigned_to_group_id          := p_assigned_to_group_id;
    l_cost_center                   := p_cost_center;
    l_charge_to_cost_center         := p_charge_to_cost_center;
    l_comp_currency_code            := p_comp_currency_code;
    l_commissionable_flag           := p_commissionable_flag;
    l_hold_reason_code              := p_hold_reason_code;
    l_hold_payment                  := p_hold_payment;
    l_comp_service_team_id          := p_comp_service_team_id;
    l_user_id                       := p_user_id;
   -- l_location                    := p_location;
    l_object_version_num            := p_object_version_num;
    l_user_name                     := p_user_name;


    SAVEPOINT update_resource_pub;

    x_return_status := fnd_api.g_ret_sts_success;

--    dbms_output.put_line(' Started Update Resource Pub ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Validate the Resource. */

    IF l_resource_id IS NULL AND l_resource_number is NULL THEN

--      dbms_output.put_line('Resource Id and Resource Number are null');

      fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_NULL');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    END IF;


    IF l_resource_id IS NOT NULL THEN

      OPEN c_resource_id(l_resource_id);

      FETCH c_resource_id INTO l_check_resource_id;

      IF c_resource_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid or Inactive Resource');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE');
        fnd_message.set_token('P_RESOURCE_ID', l_resource_id);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

      CLOSE c_resource_id;

    ELSIF l_resource_number IS NOT NULL THEN

      OPEN c_resource_number(l_resource_number);

      FETCH c_resource_number INTO l_check_resource_number;

      IF c_resource_number%NOTFOUND THEN

--        dbms_output.put_line('Invalid or Inactive Resource');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE_NUMBER');
        fnd_message.set_token('P_RESOURCE_NUMBER', l_resource_number);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      CLOSE c_resource_number;

    END IF;



    /* Call the private procedure with the validated parameters. */

    jtf_rs_resource_pvt.update_resource
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_RESOURCE_ID => l_resource_id,
     P_MANAGING_EMP_ID => l_managing_emp_id,
     P_START_DATE_ACTIVE => l_start_date_active,
     P_END_DATE_ACTIVE => l_end_date_active,
     P_TIME_ZONE => l_time_zone,
     P_COST_PER_HR => l_cost_per_hr,
     P_PRIMARY_LANGUAGE => l_primary_language,
     P_SECONDARY_LANGUAGE => l_secondary_language,
     P_SUPPORT_SITE_ID => l_support_site_id,
     P_IES_AGENT_LOGIN => l_ies_agent_login,
     P_SERVER_GROUP_ID => l_server_group_id,
     P_ASSIGNED_TO_GROUP_ID => l_assigned_to_group_id,
     P_COST_CENTER => l_cost_center,
     P_CHARGE_TO_COST_CENTER => l_charge_to_cost_center,
     P_COMP_CURRENCY_CODE => l_comp_currency_code,
     P_COMMISSIONABLE_FLAG => l_commissionable_flag,
     P_HOLD_REASON_CODE => l_hold_reason_code,
     P_HOLD_PAYMENT => l_hold_payment,
     P_COMP_SERVICE_TEAM_ID => l_comp_service_team_id,
     P_USER_ID => l_user_id,
     --P_LOCATION => l_location,
     P_ATTRIBUTE1                => p_attribute1,
     P_ATTRIBUTE2                => p_attribute2,
     P_ATTRIBUTE3                => p_attribute3,
     P_ATTRIBUTE4                => p_attribute4,
     P_ATTRIBUTE5                => p_attribute5,
     P_ATTRIBUTE6                => p_attribute6,
     P_ATTRIBUTE7                => p_attribute7,
     P_ATTRIBUTE8                => p_attribute8,
     P_ATTRIBUTE9                => p_attribute9,
     P_ATTRIBUTE10               => p_attribute10,
     P_ATTRIBUTE11               => p_attribute11,
     P_ATTRIBUTE12               => p_attribute12,
     P_ATTRIBUTE13               => p_attribute13,
     P_ATTRIBUTE14               => p_attribute14,
     P_ATTRIBUTE15               => p_attribute15,
     P_ATTRIBUTE_CATEGORY        => p_attribute_category,
     P_OBJECT_VERSION_NUM => l_object_version_num,
     P_RESOURCE_NAME => P_RESOURCE_NAME,
     P_SOURCE_NAME => P_SOURCE_NAME,
     P_SOURCE_NUMBER => P_SOURCE_NUMBER,
     P_SOURCE_JOB_TITLE => P_SOURCE_JOB_TITLE,
     P_SOURCE_EMAIL => P_SOURCE_EMAIL,
     P_SOURCE_PHONE => P_SOURCE_PHONE,
     P_SOURCE_ORG_ID => P_SOURCE_ORG_ID,
     P_SOURCE_ORG_NAME => P_SOURCE_ORG_NAME,
     P_SOURCE_ADDRESS1 => P_SOURCE_ADDRESS1,
     P_SOURCE_ADDRESS2 => P_SOURCE_ADDRESS2,
     P_SOURCE_ADDRESS3 => P_SOURCE_ADDRESS3,
     P_SOURCE_ADDRESS4 => P_SOURCE_ADDRESS4,
     P_SOURCE_CITY => P_SOURCE_CITY,
     P_SOURCE_POSTAL_CODE => P_SOURCE_POSTAL_CODE,
     P_SOURCE_STATE => P_SOURCE_STATE,
     P_SOURCE_PROVINCE => P_SOURCE_PROVINCE,
     P_SOURCE_COUNTY => P_SOURCE_COUNTY,
     P_SOURCE_COUNTRY => P_SOURCE_COUNTRY,
     P_SOURCE_MGR_ID => P_SOURCE_MGR_ID,
     P_SOURCE_MGR_NAME => P_SOURCE_MGR_NAME,
     P_SOURCE_BUSINESS_GRP_ID => P_SOURCE_BUSINESS_GRP_ID,
     P_SOURCE_BUSINESS_GRP_NAME => P_SOURCE_BUSINESS_GRP_NAME,
     P_SOURCE_FIRST_NAME => P_SOURCE_FIRST_NAME,
     P_SOURCE_MIDDLE_NAME => P_SOURCE_MIDDLE_NAME,
     P_SOURCE_LAST_NAME => P_SOURCE_LAST_NAME,
     P_SOURCE_CATEGORY => P_SOURCE_CATEGORY,
     P_SOURCE_STATUS => P_SOURCE_STATUS,
     P_SOURCE_OFFICE => P_SOURCE_OFFICE,
     P_SOURCE_LOCATION => P_SOURCE_LOCATION,
     P_SOURCE_MAILSTOP => P_SOURCE_MAILSTOP,
     P_ADDRESS_ID => P_ADDRESS_ID,
     P_USER_NAME     => P_USER_NAME,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
     P_SOURCE_MOBILE_PHONE => P_SOURCE_MOBILE_PHONE,
     P_SOURCE_PAGER => P_SOURCE_PAGER
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    END IF;



    IF fnd_api.to_boolean(p_commit) THEN

         COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);



  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_resource_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_resource_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_resource_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);


  END update_resource;


   /* Procedure to delete the resource of type TBH */

  PROCEDURE  delete_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE';
    l_resource_id         jtf_rs_resource_extns.resource_id%TYPE;

    CURSOR res_cur(
         l_resource_id    IN  NUMBER)
    IS
      SELECT resource_id,
             category
      FROM jtf_rs_resource_extns
      WHERE resource_id = l_resource_id;

   res_rec   res_cur%rowtype;

  l_bind_id   number;


  BEGIN

    l_resource_id := p_resource_id;

    SAVEPOINT delete_resource_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;


    /* Validate the Resource. */
    IF l_resource_id IS NULL  THEN
      fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_NULL');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;

    END IF;


    IF l_resource_id IS NOT NULL THEN
      OPEN res_cur(l_resource_id);
      FETCH res_cur  INTO res_rec;
      IF res_cur%NOTFOUND THEN
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE');
        fnd_message.set_token('P_RESOURCE_ID', l_resource_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

      END IF;
      IF res_rec.category <> 'TBH'
      THEN
         fnd_message.set_name('JTF', 'JTF_RS_NOT_TBH');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE res_cur;

    END IF;



    /* Call the private procedure with the validated parameters. */
     --call private api for delete
        JTF_RS_RESOURCE_PVT.DELETE_RESOURCE(
                      P_API_VERSION	=> 1.0,
                      P_INIT_MSG_LIST	=> fnd_api.g_false,
                      P_COMMIT => fnd_api.g_false,
                      P_RESOURCE_ID => l_resource_id,
                      X_RETURN_STATUS => x_return_status,
                      X_MSG_COUNT => x_msg_count,
                      X_MSG_DATA => x_msg_data  );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
    END IF;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO delete_resource_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_resource_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_resource_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

 END delete_resource;


    /* Procedure to create the resource with the resource synchronizing parameters. */

  PROCEDURE  create_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE   DEFAULT  NULL,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE   DEFAULT  NULL,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE   DEFAULT  NULL,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   DEFAULT  NULL,
   P_MANAGING_EMP_NUM        IN   PER_EMPLOYEES_CURRENT_X.EMPLOYEE_NUM%TYPE   DEFAULT  NULL,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE   DEFAULT  NULL,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE   DEFAULT  NULL,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE   DEFAULT  NULL,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE   DEFAULT  NULL,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE   DEFAULT  NULL,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE   DEFAULT  NULL,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE   DEFAULT  NULL,
   P_INTERACTION_CENTER_NAME IN   VARCHAR2   DEFAULT  NULL,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE   DEFAULT  NULL,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE   DEFAULT  NULL,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE   DEFAULT NULL,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE   DEFAULT NULL,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE   DEFAULT  NULL,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE   DEFAULT  NULL,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE   DEFAULT  NULL,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE   DEFAULT  NULL,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   DEFAULT  NULL,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE     DEFAULT NULL,
   P_SOURCE_NAME             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
   P_SOURCE_NUMBER           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE     DEFAULT NULL,
   P_SOURCE_JOB_TITLE        IN   JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_TITLE%TYPE  DEFAULT NULL,
   P_SOURCE_EMAIL            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE      DEFAULT NULL,
   P_SOURCE_PHONE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PHONE%TYPE      DEFAULT NULL,
   P_SOURCE_ORG_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_ID%TYPE     DEFAULT NULL,
   P_SOURCE_ORG_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_NAME%TYPE   DEFAULT NULL,
   P_SOURCE_ADDRESS1         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS1%TYPE   DEFAULT NULL,
   P_SOURCE_ADDRESS2         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS2%TYPE   DEFAULT NULL,
   P_SOURCE_ADDRESS3         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS3%TYPE   DEFAULT NULL,
   P_SOURCE_ADDRESS4         IN  JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS4%TYPE    DEFAULT NULL,
   P_SOURCE_CITY             IN  JTF_RS_RESOURCE_EXTNS.SOURCE_CITY%TYPE        DEFAULT NULL,
   P_SOURCE_POSTAL_CODE      IN  JTF_RS_RESOURCE_EXTNS.SOURCE_POSTAL_CODE%TYPE DEFAULT NULL,
   P_SOURCE_STATE            IN  JTF_RS_RESOURCE_EXTNS.SOURCE_STATE%TYPE       DEFAULT NULL,
   P_SOURCE_PROVINCE         IN  JTF_RS_RESOURCE_EXTNS.SOURCE_PROVINCE%TYPE    DEFAULT NULL,
   P_SOURCE_COUNTY           IN  JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTY%TYPE      DEFAULT NULL,
   P_SOURCE_COUNTRY          IN  JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTRY%TYPE     DEFAULT NULL,
   P_SOURCE_MGR_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_ID%type DEFAULT NULL,
   P_SOURCE_MGR_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_NAME%type DEFAULT NULL,
   P_SOURCE_BUSINESS_GRP_ID  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_ID%type DEFAULT NULL,
   P_SOURCE_BUSINESS_GRP_NAME IN  JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_NAME%type DEFAULT NULL,
   P_SOURCE_FIRST_NAME       IN JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE  DEFAULT NULL,
   P_SOURCE_LAST_NAME        IN JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE  DEFAULT NULL,
   P_SOURCE_MIDDLE_NAME      IN JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE  DEFAULT NULL,
   P_SOURCE_CATEGORY         IN JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE  DEFAULT NULL,
   P_SOURCE_STATUS           IN JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE  DEFAULT NULL,
   P_SOURCE_OFFICE           IN JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE  DEFAULT NULL,
   P_SOURCE_LOCATION         IN JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE  DEFAULT NULL,
   P_SOURCE_MAILSTOP         IN JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE  DEFAULT NULL,
   P_USER_NAME               IN VARCHAR2,
   P_SOURCE_MOBILE_PHONE     IN JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE  DEFAULT NULL,
   P_SOURCE_PAGER            IN JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE  DEFAULT NULL,
   P_ATTRIBUTE1              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL
   )
   IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE';

    --duplicated from the create_resource api above
    l_category                     jtf_rs_resource_extns.category%TYPE;
    l_source_id                    jtf_rs_resource_extns.source_id%TYPE;
    l_address_id                   jtf_rs_resource_extns.address_id%TYPE;
    l_contact_id                   jtf_rs_resource_extns.contact_id%TYPE;
    l_managing_emp_id              jtf_rs_resource_extns.managing_employee_id%TYPE;
    l_managing_emp_num             per_employees_current_x.employee_num%TYPE;
    l_start_date_active            jtf_rs_resource_extns.start_date_active%TYPE;
    l_end_date_active              jtf_rs_resource_extns.end_date_active%TYPE;
    l_time_zone                    jtf_rs_resource_extns.time_zone%TYPE;
    l_cost_per_hr                  jtf_rs_resource_extns.cost_per_hr%TYPE;
    l_primary_language             jtf_rs_resource_extns.primary_language%TYPE;
    l_secondary_language           jtf_rs_resource_extns.secondary_language%TYPE;
    l_support_site_id              jtf_rs_resource_extns.support_site_id%TYPE;
    l_ies_agent_login              jtf_rs_resource_extns.ies_agent_login%TYPE;
    l_server_group_id              jtf_rs_resource_extns.server_group_id%TYPE;
    l_interaction_center_name      VARCHAR2(256);
    l_assigned_to_group_id         jtf_rs_resource_extns.assigned_to_group_id%TYPE;
    l_cost_center                  jtf_rs_resource_extns.cost_center%TYPE;
    l_charge_to_cost_center        jtf_rs_resource_extns.charge_to_cost_center%TYPE;
    l_comp_currency_code           jtf_rs_resource_extns.compensation_currency_code%TYPE;
    l_commissionable_flag          jtf_rs_resource_extns.commissionable_flag%TYPE;
    l_hold_reason_code             jtf_rs_resource_extns.hold_reason_code%TYPE;
    l_hold_payment                 jtf_rs_resource_extns.hold_payment%TYPE;
    l_comp_service_team_id         jtf_rs_resource_extns.comp_service_team_id%TYPE;
    l_user_id                      jtf_rs_resource_extns.user_id%TYPE;
    l_transaction_number           jtf_rs_resource_extns.transaction_number%TYPE;
    --l_location                     MDSYS.SDO_GEOMETRY := p_location;

--added for NOCOPY
    l_managing_emp_id_out          jtf_rs_resource_extns.managing_employee_id%TYPE ;
    l_server_group_id_out          jtf_rs_resource_extns.server_group_id%TYPE ;
    l_comp_service_team_id_out     jtf_rs_resource_extns.comp_service_team_id%TYPE;


    l_user_name                    jtf_rs_resource_extns.user_name%type;
    l_check_flag                   VARCHAR2(1);
    l_found                        BOOLEAN;


    /* Changed from view to direct table query stripping out unnecessary table joins
       for SQL Rep perf bug 4956627. Query logic taken from view JTF_RS_PARTNERS_VL.
       Nishant Singhai (13-Mar-2006)
    */
    /*
    CURSOR c_validate_partner(
         l_party_id        IN  NUMBER)
    IS
      SELECT 'Y'
      FROM jtf_rs_partners_vl
      WHERE party_id = l_party_id;
    */
    CURSOR c_validate_partner(l_party_id  IN  NUMBER)
    IS
	SELECT 'Y'
	FROM HZ_PARTIES PARTY, HZ_PARTIES PARTY2,
	     HZ_PARTIES PARTY3, HZ_RELATIONSHIPS REL
	WHERE (PARTY.PARTY_TYPE = 'ORGANIZATION' AND PARTY.PARTY_ID = REL.SUBJECT_ID)
	AND REL.RELATIONSHIP_CODE IN ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
	                              'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER',
								  'CUSTOMER_INDIRECTLY_MANAGED_BY')
	AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND REL.DIRECTIONAL_FLAG = 'F'
	AND REL.STATUS = 'A'
	AND PARTY.STATUS = 'A'
	AND PARTY2.STATUS = 'A'
	AND PARTY3.STATUS = 'A'
	AND REL.SUBJECT_ID = PARTY2.PARTY_ID
	AND (PARTY2.PARTY_TYPE = 'PERSON' OR PARTY2.PARTY_TYPE = 'ORGANIZATION')
	AND REL.OBJECT_ID = PARTY3.PARTY_ID
	AND PARTY3.PARTY_TYPE = 'ORGANIZATION'
	AND party.party_id = l_party_id
	UNION ALL
	SELECT 'Y'
	FROM HZ_PARTIES PARTY, HZ_PARTIES PARTY2,
	     HZ_PARTIES PARTY3, HZ_RELATIONSHIPS REL
	WHERE (PARTY.PARTY_TYPE = 'PARTY_RELATIONSHIP' AND PARTY.PARTY_ID = REL.PARTY_ID )
	AND REL.RELATIONSHIP_CODE IN ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
	                              'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER',
								  'CUSTOMER_INDIRECTLY_MANAGED_BY')
	AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND REL.DIRECTIONAL_FLAG = 'F'
	AND REL.STATUS = 'A'
	AND PARTY.STATUS = 'A'
	AND PARTY2.STATUS = 'A'
	AND PARTY3.STATUS = 'A'
	AND REL.SUBJECT_ID = PARTY2.PARTY_ID
	AND (PARTY2.PARTY_TYPE = 'PERSON' OR PARTY2.PARTY_TYPE = 'ORGANIZATION')
	AND REL.OBJECT_ID = PARTY3.PARTY_ID
	AND PARTY3.PARTY_TYPE = 'ORGANIZATION'
	AND party.party_id = l_party_id
	;

   CURSOR c_validate_partner_address (
         l_party_id		IN  NUMBER,
	 l_party_site_id	IN  NUMBER)
    IS
	SELECT 'Y'
    FROM hz_party_sites
	WHERE party_id 		= l_party_id
	  AND party_site_id 	= l_party_site_id;

    CURSOR c_validate_partner_contact(
         l_party_id        IN  NUMBER,
         l_party_site_id   IN  NUMBER,
         l_contact_id      IN  NUMBER)
    IS
         SELECT 'Y'
      FROM jtf_rs_party_contacts_vl
         WHERE party_id 		= l_party_id
           AND nvl (party_site_id,-99) 	= nvl (l_party_site_id,-99)
           AND contact_id 		= l_contact_id;

   /* -- Direct query from tables. But does not improve performance or shared memory
      -- significantly. So not using it as it will lead to dual maintainence (view + this logic)
      -- Test performed for SQL Rep Bug 4956627

    CURSOR c_validate_partner_contact(
         l_party_id        IN  NUMBER,
         l_party_site_id   IN  NUMBER,
         l_contact_id      IN  NUMBER)
    IS
    SELECT 'Y'
	-- SELECT PARTY.PARTY_ID PARTY_ID , ORG_CONT.PARTY_SITE_ID PARTY_SITE_ID , ORG_CONT.ORG_CONTACT_ID CONTACT_ID ,
	-- ORG_CONT.CONTACT_NUMBER CONTACT_NUMBER , PARTY.PARTY_NAME CONTACT_NAME , CONT_ROLE.PRIMARY_FLAG PRIMARY_FLAG
	FROM HZ_PARTIES PARTY , HZ_RELATIONSHIPS PARTY_REL , HZ_ORG_CONTACTS ORG_CONT ,
  	     HZ_ORG_CONTACT_ROLES CONT_ROLE
	WHERE PARTY.STATUS = 'A'
	AND PARTY.PARTY_TYPE = 'PERSON'
	AND PARTY_REL.RELATIONSHIP_ID = ORG_CONT.PARTY_RELATIONSHIP_ID
	AND ORG_CONT.ORG_CONTACT_ID = CONT_ROLE.ORG_CONTACT_ID (+)
	AND CONT_ROLE.PRIMARY_FLAG (+) = 'Y'
	AND PARTY.PARTY_ID = PARTY_REL.SUBJECT_ID
	AND PARTY_REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.DIRECTIONAL_FLAG = 'F'
	AND PARTY_REL.STATUS = 'A'
	AND party.party_id = l_party_id
	AND ORG_CONT.ORG_CONTACT_ID = l_contact_id
	AND NVL(ORG_CONT.PARTY_SITE_ID,-99) = NVL(l_party_site_id,-99)
	UNION ALL
	SELECT 'Y'
	-- SELECT PARTY5.PARTY_ID PARTY_ID , ORG_CONT.PARTY_SITE_ID PARTY_SITE_ID ,
	-- ORG_CONT.ORG_CONTACT_ID CONTACT_ID , ORG_CONT.CONTACT_NUMBER CONTACT_NUMBER ,
	-- PARTY5.PARTY_NAME CONTACT_NAME , CONT_ROLE.PRIMARY_FLAG PRIMARY_FLAG
	FROM HZ_PARTIES PARTY3 , HZ_PARTIES PARTY4 , HZ_PARTIES PARTY5 , HZ_RELATIONSHIPS PARTY_REL ,
	     HZ_ORG_CONTACTS ORG_CONT , HZ_ORG_CONTACT_ROLES CONT_ROLE
	WHERE PARTY_REL.PARTY_ID = PARTY5.PARTY_ID
	AND PARTY5.PARTY_TYPE = 'PARTY_RELATIONSHIP'
	AND PARTY5.STATUS = 'A'
	AND TRUNC (NVL (PARTY_REL.END_DATE, SYSDATE)) >= TRUNC (SYSDATE)
	AND PARTY_REL.SUBJECT_ID = PARTY3.PARTY_ID
	AND PARTY3.PARTY_TYPE = 'PERSON'
	AND PARTY3.STATUS = 'A'
	AND PARTY_REL.OBJECT_ID = PARTY4.PARTY_ID
	AND PARTY4.PARTY_TYPE = 'ORGANIZATION'
	AND PARTY4.STATUS = 'A'
	AND PARTY_REL.RELATIONSHIP_ID = ORG_CONT.PARTY_RELATIONSHIP_ID
	AND ORG_CONT.ORG_CONTACT_ID = CONT_ROLE.ORG_CONTACT_ID (+)
	AND CONT_ROLE.PRIMARY_FLAG (+) = 'Y'
	AND PARTY_REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.DIRECTIONAL_FLAG = 'F'
	AND PARTY_REL.STATUS = 'A'
	AND party5.party_id = l_party_id
	AND ORG_CONT.ORG_CONTACT_ID = l_contact_id
	AND NVL(ORG_CONT.PARTY_SITE_ID,-99) = NVL(l_party_site_id,-99)
	UNION ALL
	SELECT 'Y'
	-- SELECT PARTY4.PARTY_ID PARTY_ID , ORG_CONT.PARTY_SITE_ID PARTY_SITE_ID ,
	-- ORG_CONT.ORG_CONTACT_ID CONTACT_ID , ORG_CONT.CONTACT_NUMBER CONTACT_NUMBER ,
	-- PARTY3.PARTY_NAME CONTACT_NAME , CONT_ROLE.PRIMARY_FLAG PRIMARY_FLAG
	FROM HZ_PARTIES PARTY3 , HZ_PARTIES PARTY4 , HZ_RELATIONSHIPS PARTY_REL ,
	     HZ_ORG_CONTACTS ORG_CONT , HZ_ORG_CONTACT_ROLES CONT_ROLE
	WHERE PARTY_REL.SUBJECT_ID = PARTY3.PARTY_ID
	AND PARTY3.PARTY_TYPE = 'PERSON'
	AND PARTY3.STATUS = 'A'
	AND PARTY_REL.OBJECT_ID = PARTY4.PARTY_ID
	AND PARTY4.PARTY_TYPE = 'ORGANIZATION'
	AND PARTY4.STATUS = 'A'
	AND PARTY_REL.RELATIONSHIP_ID = ORG_CONT.PARTY_RELATIONSHIP_ID
	AND TRUNC (PARTY_REL.START_DATE) <= TRUNC (SYSDATE)
	AND TRUNC (NVL (PARTY_REL.END_DATE, SYSDATE)) >= TRUNC (SYSDATE)
	AND ORG_CONT.ORG_CONTACT_ID = CONT_ROLE.ORG_CONTACT_ID (+)
	AND CONT_ROLE.PRIMARY_FLAG (+) = 'Y'
	AND PARTY_REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
	AND PARTY_REL.DIRECTIONAL_FLAG = 'F'
	AND PARTY_REL.STATUS = 'A'
	AND party4.party_id = l_party_id
	AND ORG_CONT.ORG_CONTACT_ID = l_contact_id
	AND NVL(ORG_CONT.PARTY_SITE_ID,-99) = NVL(l_party_site_id,-99)
	;
   */

    CURSOR c_validate_party_address(
         l_party_site_id   IN  NUMBER )
    IS
         SELECT 'Y'
      FROM hz_party_sites
         WHERE party_site_id  = l_party_site_id;


    CURSOR c_validate_party_contact(
         l_party_id        IN  NUMBER,
         l_party_site_id   IN  NUMBER,
         l_contact_id      IN  NUMBER)
    IS
         SELECT 'Y'
      /* FROM jtf_rs_party_contacts_vl
         WHERE party_id = l_party_id
           AND nvl(party_site_id, 0) = nvl(l_party_site_id, 0)
           AND contact_id = l_contact_id; */
 -- changed the query the validate party contact id according to bug 2954064 as provided by the PRM team , sudarsana 2nd july 2004
        FROM hz_relationships hzr,
            hz_org_contacts hzoc
      WHERE hzr.party_id =  l_party_id
        AND hzoc.org_contact_id = l_contact_id
        AND hzr.directional_flag = 'F'
        AND hzr.relationship_code = 'EMPLOYEE_OF'
        AND hzr.subject_table_name ='HZ_PARTIES'
        AND hzr.object_table_name ='HZ_PARTIES'
        AND hzr.start_date <= SYSDATE
        AND (hzr.end_date is null or hzr.end_date > SYSDATE)
        AND hzr.status = 'A'
        AND hzoc.PARTY_RELATIONSHIP_ID = hzr.relationship_id;

   /* SQL Rep perf improvement bug 4956627  Nishant Singhai (14-Mar-2006) fixed by
      modifying query logic given in bug # 4052112
      OIC expanded the definition of compensation analyst to include any active user in the
      system regardless of their assignment to a CN responsibility.
   */
    CURSOR c_assigned_to_group_id(
         l_assigned_to_group_id    IN  NUMBER)
    IS
     SELECT u.user_id
       FROM fnd_user u,
            jtf_rs_resource_extns r
      WHERE u.user_id = r.user_id
        AND u.user_id = l_assigned_to_group_id;

    CURSOR c_validate_user_id(
         l_user_id        IN  NUMBER)
    IS
         SELECT 'Y'
      FROM jtf_rs_resource_extns
         WHERE user_id = l_user_id;

 -- Enh 3947611 2-dec-2004 added cursor to check emp existence
  CURSOR  c_emp_exist(p_person_id IN NUMBER)
      IS
  SELECT 'x' value,full_name
   FROM per_all_people_f
  WHERE person_id  = p_person_id;

   r_emp_exist c_emp_exist%rowtype;



  BEGIN

    l_category                      := upper(p_category);
    l_source_id                     := p_source_id;
    l_address_id                    := p_address_id;
    l_contact_id                    := p_contact_id;
    l_managing_emp_id               := p_managing_emp_id;
    l_managing_emp_num              := p_managing_emp_num;
    l_start_date_active             := p_start_date_active;
    l_end_date_active               := p_end_date_active;
    l_time_zone                     := p_time_zone;
    l_cost_per_hr                   := p_cost_per_hr;
    l_primary_language              := p_primary_language;
    l_secondary_language            := p_secondary_language;
    l_support_site_id               := p_support_site_id;
    l_ies_agent_login               := p_ies_agent_login;
    l_server_group_id               := p_server_group_id;
    l_interaction_center_name       := p_interaction_center_name;
    l_assigned_to_group_id          := p_assigned_to_group_id;
    l_cost_center                   := p_cost_center;
    l_charge_to_cost_center         := p_charge_to_cost_center;
    l_comp_currency_code            := p_comp_currency_code;
    l_commissionable_flag           := p_commissionable_flag;
    l_hold_reason_code              := p_hold_reason_code;
    l_hold_payment                  := p_hold_payment;
    l_comp_service_team_id          := p_comp_service_team_id;
    l_user_id                       := p_user_id;
    l_transaction_number            := p_transaction_number;

  --Standard Start of API SAVEPOINT
   SAVEPOINT CREATE_RESOURCE_SP;

   x_return_status := fnd_api.g_ret_sts_success;

    --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

   /* Validate the Resource Category */

    jtf_resource_utl.validate_resource_category(
      p_category => l_category,
      x_return_status => x_return_status
    );


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

       IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF;


    /* Validate Source ID */

      jtf_resource_utl.validate_source_id (
         p_category		=> l_category,
         p_source_id		=> l_source_id,
    	 p_address_id		=> l_address_id,
         x_return_status	=> x_return_status
      );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF;


    /* Validations for category as OTHER and TBH */

    IF l_category IN ('OTHER', 'TBH') THEN

      /* Validate that the source_id, address_id, contact_id and managing_employee_id
            are all NULL */

         IF (l_source_id IS NOT NULL OR l_address_id IS NOT NULL
             OR l_contact_id IS NOT NULL OR l_managing_emp_id IS NOT NULL
                OR l_managing_emp_num IS NOT NULL) THEN

--         dbms_output.put_line('For OTHER category, source_id, address_id, contact_id and managing_emp_id should be all null');

        fnd_message.set_name('JTF', 'JTF_RS_OTHER_IDS_NOT_NULL');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;

    /* Validations for category as PARTNER */

    IF l_category = 'PARTNER' THEN

      /* Validate the source_id */

      IF (l_source_id IS NULL)  THEN
--         dbms_output.put_line('For PARTNER category, source_id should not be null');
        fnd_message.set_name('JTF', 'JTF_RS_PARTNER_IDS_NULL');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

      ELSE
         OPEN c_validate_partner(l_source_id);
         FETCH c_validate_partner INTO l_check_flag;
      	    IF c_validate_partner%NOTFOUND THEN
--             dbms_output.put_line('Partner does not exist for the passed source_id');
               fnd_message.set_name('JTF', 'JTF_RS_INVALID_PARTNER_IDS');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;

            END IF;
	    CLOSE c_validate_partner;
      END IF;

      /* Validate the address_id if specified */

      IF l_address_id IS NOT NULL THEN
        OPEN c_validate_partner_address(l_source_id, l_address_id);
        FETCH c_validate_partner_address INTO l_check_flag;
        IF c_validate_partner_address%NOTFOUND THEN
--         dbms_output.put_line('Invalid Partner Address Id');
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PARTNER_ADDRESS_ID');
           fnd_message.set_token('P_ADDRESS_ID', l_address_id);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;

        END IF;
        CLOSE c_validate_partner_address;
     END IF;


      /* Validate the contact_id if specified */

      IF l_contact_id IS NOT NULL THEN
        OPEN c_validate_partner_contact(l_source_id, l_address_id, l_contact_id);
        FETCH c_validate_partner_contact INTO l_check_flag;
        IF c_validate_partner_contact%NOTFOUND THEN
--         dbms_output.put_line('Invalid Partner Contact Id');
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PARTNER_CONTACT_ID');
           fnd_message.set_token('P_CONTACT_ID', l_contact_id);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;

        END IF;
        CLOSE c_validate_partner_contact;
     END IF;

   END IF;

    /* For all other Categories, validate the source_id from jtf_objects */
    /* Enh 3947611 2-dec-2004 : added EMPLOYEE to the exception also.  Import future dated employees
       this had to be an exception else the seed data for object EMPLOYEE if jtf_objects had to be changed. This may have
       some backward compatibility issues for consumers who use JTF_OBJECTS to validate OR list EMPLOYEE
    */

      IF l_category NOT IN ('OTHER' , 'PARTNER' , 'TBH', 'EMPLOYEE') THEN
         IF l_source_id IS NULL THEN
--          dbms_output.put_line('Source Id should not be Null');
            fnd_message.set_name('JTF', 'JTF_RS_SOURCE_ID_NULL');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;

      END IF;

      jtf_resource_utl.check_object_existence_migr(

        P_OBJECT_CODE 		=> l_category,
        P_SELECT_ID 		=> l_source_id,
        P_OBJECT_USER_CODE 	=> 'RESOURCE_CATEGORIES',
        P_RS_ID_PUB_FLAG	=> G_RS_ID_PUB_FLAG,
        X_FOUND 		=> l_found,
        X_RETURN_STATUS 	=> x_return_status
        );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	  IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

      END IF;


      IF l_found = FALSE THEN

--        dbms_output.put_line('Invalid Source Id');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_SOURCE_ID');
        fnd_message.set_token('P_SOURCE_ID', l_source_id);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Enh 3947611 2-dec-2004:EMPLOYEE VALIDATION has been removed from the above code. so adding validation
        for EMPLOYEE
    */

    if l_category = 'EMPLOYEE' THEN
       -- First check is null check for source id
       IF l_source_id IS NULL THEN
            fnd_message.set_name('JTF', 'JTF_RS_SOURCE_ID_NULL');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;

        open c_emp_exist(l_source_id);
        fetch c_emp_exist into r_emp_exist;
        close c_emp_exist;

        if(nvl(r_emp_exist.value , 'y') <> 'x')
        then
           fnd_message.set_name('JTF', 'JTF_RS_INVALID_SOURCE_ID');
           fnd_message.set_token('P_SOURCE_ID', l_source_id);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
        end if;

    END IF; -- end of check l_category = 'EMPLOYEE'

    /* Validations for category as PARTY */

    IF l_category = 'PARTY' THEN

      /* Validate the address_id if specified */

      IF l_address_id IS NOT NULL THEN

        OPEN c_validate_party_address(l_address_id);

        FETCH c_validate_party_address INTO l_check_flag;


        IF c_validate_party_address%NOTFOUND THEN

--          dbms_output.put_line('Invalid Party Address');

          fnd_message.set_name('JTF', 'JTF_RS_INVALID_PARTY_ADDRESS');
          fnd_message.set_token('P_ADDRESS_ID', l_address_id);
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;


        END IF;

        /* Close the cursor */

        CLOSE c_validate_party_address;


      END IF;


      /* Validate the contact_id if specified */

      IF l_contact_id IS NOT NULL THEN

        OPEN c_validate_party_contact(l_source_id, l_address_id, l_contact_id);

        FETCH c_validate_party_contact INTO l_check_flag;


        IF c_validate_party_contact%NOTFOUND THEN

--          dbms_output.put_line('Invalid Party Contact Id');

          fnd_message.set_name('JTF', 'JTF_RS_ERR_PARTY_CONTACT_ID');
          fnd_message.set_token('P_CONTACT_ID', l_contact_id);
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;

        END IF;


        /* Close the cursor */

        CLOSE c_validate_party_contact;

         END IF;

    END IF;



    /* Validations for category as SUPPLIER_CONTACT */

    IF l_category = 'SUPPLIER_CONTACT' THEN

      /* Validate that the address_id and contact_id are NULL */

      -- address_id check (NOT NULL) being removed, to store the address_id of supplier contact
      -- Fix for bug # 3812930
      IF (l_contact_id IS NOT NULL) THEN

--         dbms_output.put_line('For SUPPLIER_CONTACT category, address_id and contact_id should be null');

        fnd_message.set_name('JTF', 'JTF_RS_SC_IDS_NOT_NULL');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;


    /* Validations for category as EMPLOYEE */

    IF (l_category = 'EMPLOYEE') THEN

      /* Validate that the address_id, contact_id and managing_emp_id are NULL */

      --address_id check (null) being removed, to store the address_id of employee 03/26/01

      IF (l_contact_id IS NOT NULL OR l_managing_emp_id IS NOT NULL OR l_managing_emp_num IS NOT NULL) THEN

--         dbms_output.put_line('For EMPLOYEE category, contact_id should be null');

        fnd_message.set_name('JTF', 'JTF_RS_EMP_IDS_NOT_NULL');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;



    /* Validate the Managing Employee Id if specified */

    jtf_resource_utl.validate_employee_resource(
      p_emp_resource_id => l_managing_emp_id,
      p_emp_resource_number => l_managing_emp_num,
      x_return_status => x_return_status,
      x_emp_resource_id => l_managing_emp_id_out
    );

-- added for NOCOPY
    l_managing_emp_id := l_managing_emp_id_out;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

       IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF;



    /* Validate that the Start Date Active is specified */

    IF l_start_date_active IS NULL THEN

--       dbms_output.put_line('Start Date Active cannot be null');

      fnd_message.set_name('JTF', 'JTF_RS_START_DATE_NULL');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;


    END IF;



    /* Validate the Time Zone */

    IF l_time_zone IS NOT NULL THEN

      jtf_resource_utl.validate_time_zone(
        p_time_zone_id => l_time_zone,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;



    /* Validate the Primary Language */

    IF l_primary_language IS NOT NULL THEN

      jtf_resource_utl.validate_nls_language(
        p_nls_language => l_primary_language,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;



    /* Validate the Secondary Language */

    IF l_secondary_language IS NOT NULL THEN

      jtf_resource_utl.validate_nls_language(
        p_nls_language => l_secondary_language,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;



    /* Validate the Support Site */

    IF l_support_site_id IS NOT NULL THEN

      jtf_resource_utl.validate_support_site_id(
        p_support_site_id => l_support_site_id,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;



    /* Validate the Server Group. */

    jtf_resource_utl.validate_server_group(
      p_server_group_id => l_server_group_id,
      p_server_group_name => l_interaction_center_name,
      x_return_status => x_return_status,
      x_server_group_id => l_server_group_id_out
    );
-- added for NOCOPY
   l_server_group_id := l_server_group_id_out;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;



    /* Validate the assigned_to_group_id if specified */

    IF l_assigned_to_group_id IS NOT NULL THEN

      OPEN c_assigned_to_group_id(l_assigned_to_group_id);

      FETCH c_assigned_to_group_id INTO l_assigned_to_group_id;


      IF c_assigned_to_group_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid Assigned To Group Id');

        fnd_message.set_name('JTF', 'JTF_RS_ERR_ASSIGN_TO_GRP_ID');
        fnd_message.set_token('P_ASSIGNED_TO_GROUP_ID', l_assigned_to_group_id);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;


      /* Close the cursor */

      CLOSE c_assigned_to_group_id;

    END IF;



    /* Validate the Comp Currency Code */

    IF l_comp_currency_code IS NOT NULL THEN

      jtf_resource_utl.validate_currency_code(
        p_currency_code => l_comp_currency_code,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;


    /* Validate the value of the commisionable flag */

    IF l_commissionable_flag <> 'Y' AND l_commissionable_flag <> 'N' THEN

--       dbms_output.put_line('Commissionable Flag should either be ''Y'' or ''N'' ');

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;


    END IF;


    /* Validate the value of the Hold Payment flag */

    IF l_hold_payment <> 'Y' AND l_hold_payment <> 'N' THEN

--       dbms_output.put_line('Hold Payment should either be ''Y'' or ''N'' ');

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;


    END IF;



    /* Validate the Hold Reason Code */

    IF l_hold_reason_code IS NOT NULL THEN

      jtf_resource_utl.validate_hold_reason_code(
        p_hold_reason_code => l_hold_reason_code,
        x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

      END IF;

    END IF;


    /* Validate that the user_id should only be specified in case of
          'EMPLOYEE', 'PARTY', 'SUPPLIER_CONTACT' categories */

    IF l_category NOT IN ('EMPLOYEE', 'PARTY', 'SUPPLIER_CONTACT') THEN

         IF l_user_id IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_USERID_ERROR');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


         END IF;

    ELSE

      /* Validate the User Id if specified */

      IF l_user_id IS NOT NULL THEN

        jtf_resource_utl.validate_user_id(
          p_user_id => l_user_id,
          p_category => l_category,
          p_source_id => l_source_id,
          x_return_status => x_return_status
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

           IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        else

        OPEN c_validate_user_id(l_user_id);

        FETCH c_validate_user_id INTO l_check_flag;


        IF c_validate_user_id%FOUND THEN

--          dbms_output.put_line('duplicate user Id');

          fnd_message.set_name('JTF', 'JTF_RS_ERR_DUPLICATE_USER_ID');
          fnd_message.set_token('P_USER_ID', l_user_id);
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;


        END IF;


        /* Close the cursor */

        CLOSE c_validate_user_id;



        END IF;

      END IF;

    END IF;


    /* Validate the Comp Service Team Id if specified */

    IF l_comp_service_team_id IS NOT NULL THEN

      jtf_resource_utl.validate_resource_team(
        p_team_id => l_comp_service_team_id,
        p_team_number => null,
        x_return_status => x_return_status,
        x_team_id => l_comp_service_team_id_out
      );
-- added for NOCOPY
      l_comp_service_team_id := l_comp_service_team_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;

    END IF;



    /* Check the Global Variable for Resource ID, and call the appropriate Private API */

     IF G_RS_ID_PUB_FLAG = 'Y' THEN

         /* Call the private procedure with the validated parameters. */
        jtf_rs_resource_pvt.create_resource (
            P_API_VERSION 		=> 1,
            P_INIT_MSG_LIST 		=> fnd_api.g_false,
            P_COMMIT 			=> fnd_api.g_false,
            P_CATEGORY 			=> l_category,
            P_SOURCE_ID 		=> l_source_id,
            P_ADDRESS_ID 		=> l_address_id,
            P_CONTACT_ID 		=> l_contact_id,
            P_MANAGING_EMP_ID 		=> l_managing_emp_id,
            P_START_DATE_ACTIVE 	=> l_start_date_active,
            P_END_DATE_ACTIVE 		=> l_end_date_active,
            P_TIME_ZONE 		=> l_time_zone,
            P_COST_PER_HR 		=> l_cost_per_hr,
            P_PRIMARY_LANGUAGE 		=> l_primary_language,
            P_SECONDARY_LANGUAGE 	=> l_secondary_language,
            P_SUPPORT_SITE_ID 		=> l_support_site_id,
            P_IES_AGENT_LOGIN 		=> l_ies_agent_login,
            P_SERVER_GROUP_ID 		=> l_server_group_id,
            P_ASSIGNED_TO_GROUP_ID 	=> l_assigned_to_group_id,
            P_COST_CENTER 		=> l_cost_center,
            P_CHARGE_TO_COST_CENTER 	=> l_charge_to_cost_center,
            P_COMP_CURRENCY_CODE 	=> l_comp_currency_code,
            P_COMMISSIONABLE_FLAG 	=> l_commissionable_flag,
            P_HOLD_REASON_CODE 		=> l_hold_reason_code,
            P_HOLD_PAYMENT 		=> l_hold_payment,
            P_COMP_SERVICE_TEAM_ID 	=> l_comp_service_team_id,
            P_USER_ID 			=> l_user_id,
            P_TRANSACTION_NUMBER 	=> l_transaction_number,
          --P_LOCATION 			=> l_location,
            X_RETURN_STATUS 		=> x_return_status,
            X_MSG_COUNT 		=> x_msg_count,
            X_MSG_DATA 			=> x_msg_data,
            X_RESOURCE_ID 		=> x_resource_id,
            X_RESOURCE_NUMBER 		=> x_resource_number,
            P_ATTRIBUTE1                => p_attribute1,
            P_ATTRIBUTE2                => p_attribute2,
            P_ATTRIBUTE3                => p_attribute3,
            P_ATTRIBUTE4                => p_attribute4,
            P_ATTRIBUTE5                => p_attribute5,
            P_ATTRIBUTE6                => p_attribute6,
            P_ATTRIBUTE7                => p_attribute7,
            P_ATTRIBUTE8                => p_attribute8,
            P_ATTRIBUTE9                => p_attribute9,
            P_ATTRIBUTE10               => p_attribute10,
            P_ATTRIBUTE11               => p_attribute11,
            P_ATTRIBUTE12               => p_attribute12,
            P_ATTRIBUTE13               => p_attribute13,
            P_ATTRIBUTE14               => p_attribute14,
            P_ATTRIBUTE15               => p_attribute15,
            P_ATTRIBUTE_CATEGORY        => p_attribute_category,
            P_RESOURCE_NAME             => P_RESOURCE_NAME ,
            P_SOURCE_NAME               => P_SOURCE_NAME,
            P_SOURCE_NUMBER             => P_SOURCE_NUMBER,
            P_SOURCE_JOB_TITLE          => P_SOURCE_JOB_TITLE,
            P_SOURCE_EMAIL              => P_SOURCE_EMAIL,
            P_SOURCE_PHONE              => P_SOURCE_PHONE,
            P_SOURCE_ORG_ID             => P_SOURCE_ORG_ID,
            P_SOURCE_ORG_NAME           => P_SOURCE_ORG_NAME,
            P_SOURCE_ADDRESS1           => P_SOURCE_ADDRESS1,
            P_SOURCE_ADDRESS2           => P_SOURCE_ADDRESS2,
            P_SOURCE_ADDRESS3           => P_SOURCE_ADDRESS3,
            P_SOURCE_ADDRESS4           => P_SOURCE_ADDRESS4,
            P_SOURCE_CITY               => P_SOURCE_CITY,
            P_SOURCE_POSTAL_CODE        => P_SOURCE_POSTAL_CODE,
            P_SOURCE_STATE              => P_SOURCE_STATE,
            P_SOURCE_PROVINCE           => P_SOURCE_PROVINCE,
            P_SOURCE_COUNTY             => P_SOURCE_COUNTY,
            P_SOURCE_COUNTRY            => P_SOURCE_COUNTRY,
            P_SOURCE_MGR_ID             => P_SOURCE_MGR_ID,
            P_SOURCE_MGR_NAME           => P_SOURCE_MGR_NAME,
            P_SOURCE_BUSINESS_GRP_ID    => P_SOURCE_BUSINESS_GRP_ID,
            P_SOURCE_BUSINESS_GRP_NAME  => P_SOURCE_BUSINESS_GRP_NAME,
            P_SOURCE_FIRST_NAME         => P_SOURCE_FIRST_NAME,
            P_SOURCE_LAST_NAME          => P_SOURCE_LAST_NAME,
            P_SOURCE_MIDDLE_NAME        => P_SOURCE_MIDDLE_NAME,
            P_SOURCE_CATEGORY           => P_SOURCE_CATEGORY,
            P_SOURCE_STATUS             => P_SOURCE_STATUS,
            P_SOURCE_OFFICE             => P_SOURCE_OFFICE,
            P_SOURCE_LOCATION           => P_SOURCE_LOCATION,
            P_SOURCE_MAILSTOP           => P_SOURCE_MAILSTOP,
            P_USER_NAME                 => P_USER_NAME,
            P_SOURCE_MOBILE_PHONE       => P_SOURCE_MOBILE_PHONE,
            P_SOURCE_PAGER              => P_SOURCE_PAGER

         );



         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
            ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

       ELSE

--        dbms_output.put_line ('Before call to the private API create_resource_migrate' );

         /* Call the private procedure for Migration. */

         jtf_rs_resource_pvt.create_resource_migrate (
            P_API_VERSION               => 1,
            P_INIT_MSG_LIST             => fnd_api.g_false,
            P_COMMIT                    => fnd_api.g_false,
            P_CATEGORY                  => l_category,
            P_SOURCE_ID                 => l_source_id,
            P_ADDRESS_ID                => l_address_id,
            P_CONTACT_ID                => l_contact_id,
            P_MANAGING_EMP_ID           => l_managing_emp_id,
            P_START_DATE_ACTIVE         => l_start_date_active,
            P_END_DATE_ACTIVE           => l_end_date_active,
            P_TIME_ZONE                 => l_time_zone,
            P_COST_PER_HR               => l_cost_per_hr,
            P_PRIMARY_LANGUAGE          => l_primary_language,
            P_SECONDARY_LANGUAGE        => l_secondary_language,
            P_SUPPORT_SITE_ID           => l_support_site_id,
            P_IES_AGENT_LOGIN           => l_ies_agent_login,
            P_SERVER_GROUP_ID           => l_server_group_id,
            P_ASSIGNED_TO_GROUP_ID      => l_assigned_to_group_id,
            P_COST_CENTER               => l_cost_center,
            P_CHARGE_TO_COST_CENTER     => l_charge_to_cost_center,
            P_COMP_CURRENCY_CODE        => l_comp_currency_code,
            P_COMMISSIONABLE_FLAG       => l_commissionable_flag,
            P_HOLD_REASON_CODE          => l_hold_reason_code,
            P_HOLD_PAYMENT              => l_hold_payment,
            P_COMP_SERVICE_TEAM_ID      => l_comp_service_team_id,
            P_USER_ID                   => l_user_id,
            P_TRANSACTION_NUMBER        => l_transaction_number,
          --P_LOCATION                  => l_location,
            P_RESOURCE_ID		=> G_RESOURCE_ID,
            P_ATTRIBUTE1		=> G_ATTRIBUTE1,
            P_ATTRIBUTE2                => G_ATTRIBUTE2,
            P_ATTRIBUTE3                => G_ATTRIBUTE3,
            P_ATTRIBUTE4                => G_ATTRIBUTE4,
            P_ATTRIBUTE5                => G_ATTRIBUTE5,
            P_ATTRIBUTE6                => G_ATTRIBUTE6,
            P_ATTRIBUTE7                => G_ATTRIBUTE7,
            P_ATTRIBUTE8                => G_ATTRIBUTE8,
            P_ATTRIBUTE9                => G_ATTRIBUTE9,
            P_ATTRIBUTE10               => G_ATTRIBUTE10,
            P_ATTRIBUTE11               => G_ATTRIBUTE11,
            P_ATTRIBUTE12               => G_ATTRIBUTE12,
            P_ATTRIBUTE13               => G_ATTRIBUTE13,
            P_ATTRIBUTE14               => G_ATTRIBUTE14,
            P_ATTRIBUTE15               => G_ATTRIBUTE15,
            P_ATTRIBUTE_CATEGORY        => G_ATTRIBUTE_CATEGORY,
            X_RETURN_STATUS             => x_return_status,
            X_MSG_COUNT                 => x_msg_count,
            X_MSG_DATA                  => x_msg_data,
            X_RESOURCE_ID               => x_resource_id,
            X_RESOURCE_NUMBER           => x_resource_number
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
--          dbms_output.put_line('Failed status from call to private procedure');
            IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
            ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

      END IF;

  IF (x_return_status <> fnd_api.g_ret_sts_success)
  THEN
    IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;


   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_resource_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_resource_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_resource_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END;
END jtf_rs_resource_pub;

/
