--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_PVT" AS
  /* $Header: jtfrsvrb.pls 120.3 2006/02/07 18:02:45 baianand ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing resources.
   Its main procedures are as following:
   Create Resource
   Update Resource
   These procedures do the business validations and then call the appropriate
   table handlers to do the actual inserts and updates.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'JTF_RS_RESOURCE_PVT';
PROCEDURE validate_party_address(p_source_id in number,
                                   p_address_id in number,
                                   p_action in varchar2,
                                   p_found   out NOCOPY boolean,
                                   p_return_status out NOCOPY varchar);

PROCEDURE validate_party_address(p_source_id in number,
                                   p_address_id in number,
                                   p_action in varchar2,
                                   p_found   out NOCOPY boolean,
                                   p_return_status out NOCOPY varchar)
IS

cursor address_cur(l_party_id number)
    is
select party_site_id
 from  hz_party_sites
where party_id = l_party_id
 and  identifying_address_flag = 'Y'
 and  status = 'A';

l_party_type VARCHAR2(2000);
l_address_id  NUMBER;
/* Moved the initial assignment of below variable to inside begin */
l_api_name    VARCHAR2(100);
BEGIN

  l_api_name  :=  'VALIDATE_PARTY_ADDRESS';

  p_return_status := fnd_api.g_ret_sts_success;
  p_found := true;
  open address_cur(p_source_id);
  fetch address_cur into l_address_id;
  close address_cur;

  if(nvl(p_address_id, fnd_api.g_miss_num) <> nvl(l_address_id, fnd_api.g_miss_num))
  then
        p_found := false;
   end if;

 EXCEPTION
 WHEN OTHERS
    THEN
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

END;

  /* Procedure to create the resource based on input values passed by calling routines. */

  PROCEDURE  create_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE,
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
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY,
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
   X_RESOURCE_NUMBER         OUT NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE
  ) IS

    l_api_version         	CONSTANT NUMBER := 1.0;
    l_api_name            	CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE';
  /* Moved the initial assignment of below variables to inside begin */
    l_category                  jtf_rs_resource_extns.category%TYPE;
    l_source_id                 jtf_rs_resource_extns.source_id%TYPE;
    l_address_id                jtf_rs_resource_extns.address_id%TYPE;
    l_contact_id                jtf_rs_resource_extns.contact_id%TYPE;
    l_managing_emp_id           jtf_rs_resource_extns.managing_employee_id%TYPE;
    -- added trunc in both dates feb 6 2002
    l_start_date_active         jtf_rs_resource_extns.start_date_active%TYPE;
    l_end_date_active           jtf_rs_resource_extns.end_date_active%TYPE;
    l_time_zone                 jtf_rs_resource_extns.time_zone%TYPE;
    l_cost_per_hr               jtf_rs_resource_extns.cost_per_hr%TYPE;
    l_primary_language          jtf_rs_resource_extns.primary_language%TYPE;
    l_secondary_language        jtf_rs_resource_extns.secondary_language%TYPE;
    l_support_site_id           jtf_rs_resource_extns.support_site_id%TYPE;
    l_ies_agent_login           jtf_rs_resource_extns.ies_agent_login%TYPE;
    l_server_group_id           jtf_rs_resource_extns.server_group_id%TYPE;
    l_assigned_to_group_id      jtf_rs_resource_extns.assigned_to_group_id%TYPE;
    l_cost_center               jtf_rs_resource_extns.cost_center%TYPE;
    l_charge_to_cost_center     jtf_rs_resource_extns.charge_to_cost_center%TYPE;
    l_comp_currency_code        jtf_rs_resource_extns.compensation_currency_code%TYPE;
    l_commissionable_flag       jtf_rs_resource_extns.commissionable_flag%TYPE;
    l_hold_reason_code          jtf_rs_resource_extns.hold_reason_code%TYPE;
    l_hold_payment              jtf_rs_resource_extns.hold_payment%TYPE;
    l_comp_service_team_id      jtf_rs_resource_extns.comp_service_team_id%TYPE;
    l_user_id                   jtf_rs_resource_extns.user_id%TYPE;
    l_transaction_number        jtf_rs_resource_extns.transaction_number%TYPE;
    --l_location                MDSYS.SDO_GEOMETRY 				:= p_location;

    l_check_char                VARCHAR2(1);
    l_check_dup_id		VARCHAR2(1);
    l_rowid                     ROWID;
    l_resource_id               jtf_rs_resource_extns.resource_id%TYPE;
    l_resource_number           jtf_rs_resource_extns.resource_number%TYPE;
    l_bind_data_id              NUMBER;

    CURSOR c_jtf_rs_resource_extns( l_rowid   IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_resource_extns
	 WHERE ROWID = l_rowid;

    CURSOR c_dup_resource_id (l_resource_id IN jtf_rs_resource_extns.resource_id%type) IS
        SELECT 'X'
        FROM jtf_rs_resource_extns
        WHERE resource_id = l_resource_id;

    l_value                      VARCHAR2(100);
    l_address_ret_status         varchar2(10);
    l_address_found              boolean := true;

  BEGIN

    l_category                   := upper(p_category);
    l_source_id                  := p_source_id;
    l_address_id                 := p_address_id;
    l_contact_id                 := p_contact_id;
    l_managing_emp_id            := p_managing_emp_id;
    l_start_date_active          := trunc(p_start_date_active);
    l_end_date_active            := trunc(p_end_date_active);
    l_time_zone                  := p_time_zone;
    l_cost_per_hr                := p_cost_per_hr;
    l_primary_language           := p_primary_language;
    l_secondary_language         := p_secondary_language;
    l_support_site_id            := p_support_site_id;
    l_ies_agent_login            := p_ies_agent_login;
    l_server_group_id            := p_server_group_id;
    l_assigned_to_group_id       := p_assigned_to_group_id;
    l_cost_center                := p_cost_center;
    l_charge_to_cost_center      := p_charge_to_cost_center;
    l_comp_currency_code         := p_comp_currency_code;
    l_commissionable_flag        := p_commissionable_flag;
    l_hold_reason_code           := p_hold_reason_code;
    l_hold_payment               := p_hold_payment;
    l_comp_service_team_id       := p_comp_service_team_id;
    l_user_id                    := p_user_id;
    l_transaction_number         := p_transaction_number;

    SAVEPOINT create_resource_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line(' Started Create Resource Pvt ');



    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_cuhk.create_resource_pre(
        p_category             => l_category,
        p_source_id            => l_source_id,
        p_address_id           => l_address_id,
        p_contact_id           => l_contact_id,
        p_managing_emp_id      => l_managing_emp_id,
        p_start_date_active    => l_start_date_active,
        p_end_date_active      => l_end_date_active,
        p_time_zone            => l_time_zone,
        p_cost_per_hr          => l_cost_per_hr,
        p_primary_language     => l_primary_language,
        p_secondary_language   => l_secondary_language,
        p_support_site_id      => l_support_site_id,
        p_ies_agent_login      => l_ies_agent_login,
        p_server_group_id      => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center          => l_cost_center,
        p_charge_to_cost_center=> l_charge_to_cost_center,
        p_comp_currency_code   => l_comp_currency_code,
        p_commissionable_flag  => l_commissionable_flag,
        p_hold_reason_code     => l_hold_reason_code,
        p_hold_payment         => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id              => l_user_id,
        --p_location           => l_location,
	x_return_status        => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_vuhk.create_resource_pre(
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_iuhk.create_resource_pre(
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;
    END IF;



    /* Validate the Input Dates */

    jtf_resource_utl.validate_input_dates(
      p_start_date_active => l_start_date_active,
      p_end_date_active => l_end_date_active,
      x_return_status => x_return_status
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

      /* Validate for address id in case of PARTNER and PARTY */
   if(p_category IN  ('PARTNER', 'PARTY'))
   then
     if (p_address_id is NOT NULL) then
        validate_party_address(p_source_id => p_source_id,
                            p_address_id => p_address_id,
                            p_action => 'I',
                            p_found  => l_address_found,
                            p_return_status => l_address_ret_status);

        if(l_address_ret_status <> fnd_api.g_ret_sts_success)
        then
	  IF L_ADDRESS_RET_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF L_ADDRESS_RET_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

        end if;

       if not(l_address_found)
       then
          fnd_message.set_name('JTF', 'JTF_RS_NOT_PRIMARY_ADDR');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;

       end if;
     end if;
   end if; -- end of partner address check

   /* This portion of the code was modified to accomodate the calls to Migration API */
   /* Check if the Global Variable Flag for Resource ID is Y or N */

--     dbms_output.put_line ('Before checkin the Global flag in PVT API');

      IF (G_RS_ID_PVT_FLAG = 'Y') OR (G_RS_ID_PVT_FLAG = 'N' AND JTF_RS_RESOURCE_PUB.G_RESOURCE_ID IS NULL) THEN

         /* Get the next value of the Resource_id from the sequence. */

         LOOP
            SELECT jtf_rs_resource_extns_s.nextval
            INTO l_resource_id
            FROM dual;
            --dbms_output.put_line ('After Select - Resource ID ' || l_resource_id);
            OPEN c_dup_resource_id (l_resource_id);
            FETCH c_dup_resource_id INTO l_check_dup_id;
            EXIT WHEN c_dup_resource_id%NOTFOUND;
            CLOSE c_dup_resource_id;
         END LOOP;
         CLOSE c_dup_resource_id;
      ELSE
        l_resource_id 		:= JTF_RS_RESOURCE_PUB.G_RESOURCE_ID;
      END IF;

      /* Get the next value of the Resource_number from the sequence. */

          SELECT jtf_rs_resource_number_s.nextval
          INTO l_resource_number
          FROM dual;

    /* Make a call to the Resource Audit API */

    jtf_rs_resource_extns_aud_pvt.insert_resource
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_RESOURCE_ID => l_resource_id,
     P_RESOURCE_NUMBER => l_resource_number,
     P_CATEGORY => l_category,
     P_SOURCE_ID => l_source_id,
     P_ADDRESS_ID => l_address_id,
     P_CONTACT_ID => l_contact_id,
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
     P_TRANSACTION_NUMBER => l_transaction_number,
     --P_LOCATION => l_location,
     P_OBJECT_VERSION_NUMBER => 1,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
--    dbms_output.put_line('Failed status from call to audit procedure');
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

    /* Insert the row into the table by calling the table handler. */

    jtf_rs_resource_extns_pkg.insert_row(
      x_rowid                      => l_rowid,
      x_resource_id                => l_resource_id,
      x_category                   => l_category,
      x_resource_number            => l_resource_number,
      x_source_id                  => l_source_id,
      x_address_id                 => l_address_id,
      x_contact_id                 => l_contact_id,
      x_managing_employee_id       => l_managing_emp_id,
      x_start_date_active          => l_start_date_active,
      x_end_date_active            => l_end_date_active,
      x_time_zone                  => l_time_zone,
      x_cost_per_hr                => l_cost_per_hr,
      x_primary_language           => l_primary_language,
      x_secondary_language         => l_secondary_language,
      x_support_site_id            => l_support_site_id,
      x_ies_agent_login            => l_ies_agent_login,
      x_server_group_id            => l_server_group_id,
      x_assigned_to_group_id       => l_assigned_to_group_id,
      x_cost_center                => l_cost_center,
      x_charge_to_cost_center      => l_charge_to_cost_center,
      x_compensation_currency_code => l_comp_currency_code,
      x_commissionable_flag        => l_commissionable_flag,
      x_hold_reason_code           => l_hold_reason_code,
      x_hold_payment               => l_hold_payment,
      x_comp_service_team_id       => l_comp_service_team_id,
      x_user_id                    => l_user_id,
      --x_location                 => l_location,
      x_transaction_number         => l_transaction_number,
      x_attribute1                 => p_attribute1,
      x_attribute2                 => p_attribute2,
      x_attribute3                 => p_attribute3,
      x_attribute4                 => p_attribute4,
      x_attribute5                 => p_attribute5,
      x_attribute6                 => p_attribute6,
      x_attribute7                 => p_attribute7,
      x_attribute8                 => p_attribute8,
      x_attribute9                 => p_attribute9,
      x_attribute10                => p_attribute10,
      x_attribute11                => p_attribute11,
      x_attribute12                => p_attribute12,
      x_attribute13                => p_attribute13,
      x_attribute14                => p_attribute14,
      x_attribute15                => p_attribute15,
      x_attribute_category         => p_attribute_category,
      x_creation_date              => SYSDATE,
      x_created_by                 => jtf_resource_utl.created_by,
      x_last_update_date           => SYSDATE,
      x_last_updated_by            => jtf_resource_utl.updated_by,
      x_last_update_login          => jtf_resource_utl.login_id
    );

--    dbms_output.put_line('After Insert Procedure');
    OPEN c_jtf_rs_resource_extns(l_rowid);
    FETCH c_jtf_rs_resource_extns INTO l_check_char;

    IF c_jtf_rs_resource_extns%NOTFOUND THEN
--    dbms_output.put_line('Error in Table Handler');
      IF c_jtf_rs_resource_extns%ISOPEN THEN
        CLOSE c_jtf_rs_resource_extns;
      END IF;

	 fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	 fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;

    ELSE

--	 dbms_output.put_line('Resource Successfully Created');
	 x_resource_id := l_resource_id;
	 x_resource_number := l_resource_number;

    END IF;


    /* Close the cursors */

    IF c_jtf_rs_resource_extns%ISOPEN THEN
      CLOSE c_jtf_rs_resource_extns;
    END IF;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_cuhk.create_resource_post(
        p_resource_id => l_resource_id,
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;


    /* Post Call to the Vertical Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_vuhk.create_resource_post(
        p_resource_id => l_resource_id,
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_iuhk.create_resource_post(
        p_resource_id => l_resource_id,
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
       -- p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_cuhk.ok_to_generate_msg(
	       p_resource_id => l_resource_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'resource_id', l_resource_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'RS_RES',
		p_action_code => 'I',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');


	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

	     IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	     ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;

        END IF;

      END IF;

    END IF;
    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_resource_pvt;
-- The below lines removed as a part of fixing GSCC errors in R12 for jtfrspub.pls
--      IF NOT(jtf_resource_utl.check_access(l_value))
--      THEN
--            IF(l_value = 'XMLGEN')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_XMLGEN_ERR');
--		 FND_MSG_PUB.add;
--            ELSIF(l_value = 'JTF_USR_HKS')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_JUHK_ERR');
--		 FND_MSG_PUB.add;
--            END IF;
--      ELSE
	 fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	 fnd_message.set_token('P_SQLCODE',SQLCODE);
	 fnd_message.set_token('P_SQLERRM',SQLERRM);
	 fnd_message.set_token('P_API_NAME', l_api_name);
	 FND_MSG_PUB.add;
--      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END create_resource;

  /* Create Resource Procedure Overloaded, for Resource Synchronization Purposes */

  PROCEDURE  create_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE,
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
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY,
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
   P_RESOURCE_NAME	     IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE,
   P_SOURCE_NAME	     IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE ,
   P_SOURCE_NUMBER	     IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE,
   P_SOURCE_JOB_TITLE	     IN   JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_TITLE%TYPE,
   P_SOURCE_EMAIL            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE,
   P_SOURCE_PHONE	     IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PHONE%TYPE,
   P_SOURCE_ORG_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_ID%TYPE,
   P_SOURCE_ORG_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_NAME%TYPE,
   P_SOURCE_ADDRESS1	     IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS1%TYPE,
   P_SOURCE_ADDRESS2         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS2%TYPE,
   P_SOURCE_ADDRESS3         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS3%TYPE,
   P_SOURCE_ADDRESS4         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS4%TYPE,
   P_SOURCE_CITY             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_CITY%TYPE,
   P_SOURCE_POSTAL_CODE      IN   JTF_RS_RESOURCE_EXTNS.SOURCE_POSTAL_CODE%TYPE,
   P_SOURCE_STATE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_STATE%TYPE,
   P_SOURCE_PROVINCE         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PROVINCE%TYPE,
   P_SOURCE_COUNTY           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTY%TYPE,
   P_SOURCE_COUNTRY	     IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTRY%TYPE,
   P_SOURCE_MGR_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_ID%type,
   P_SOURCE_MGR_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_NAME%type,
   P_SOURCE_BUSINESS_GRP_ID  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_ID%type,
   P_SOURCE_BUSINESS_GRP_NAME IN  JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_NAME%type,
   P_SOURCE_FIRST_NAME       IN JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE,
   P_SOURCE_LAST_NAME        IN JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE,
   P_SOURCE_MIDDLE_NAME      IN JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE,
   P_SOURCE_CATEGORY         IN JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE,
   P_SOURCE_STATUS           IN JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE,
   P_SOURCE_OFFICE           IN JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE,
   P_SOURCE_LOCATION         IN JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE,
   P_SOURCE_MAILSTOP         IN JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE,
   P_USER_NAME               IN  VARCHAR2,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_SOURCE_MOBILE_PHONE     IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE,
   P_SOURCE_PAGER            IN  JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE
  ) IS

    l_api_version         	   CONSTANT NUMBER 					:= 1.0;
    l_api_name            	   CONSTANT VARCHAR2(30) 				:= 'CREATE_RESOURCE';
  /* Moved the initial assignment of below variables to inside begin */
    l_category                     jtf_rs_resource_extns.category%TYPE;
    l_source_id                    jtf_rs_resource_extns.source_id%TYPE;
    l_address_id                   jtf_rs_resource_extns.address_id%TYPE;
    l_contact_id                   jtf_rs_resource_extns.contact_id%TYPE;
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
    l_transaction_number           jtf_rs_resource_extns.transaction_number%TYPE;
    --l_location                     MDSYS.SDO_GEOMETRY 				:= p_location;

    l_check_char                   VARCHAR2(1);
    l_check_dup_id		   VARCHAR2(1);
    l_rowid                        ROWID;
    l_resource_id                  jtf_rs_resource_extns.resource_id%TYPE;
    l_resource_number              jtf_rs_resource_extns.resource_number%TYPE;
    l_bind_data_id                 NUMBER;

  /* Moved the initial assignment of below variables to inside begin */
    l_resource_name           jtf_rs_resource_extns_tl.resource_name%type;
    l_source_name             jtf_rs_resource_extns.source_name%type;
    l_source_number           jtf_rs_resource_extns.source_number%type;
    l_source_job_title        jtf_rs_resource_extns.source_job_title%type;
    l_source_email            jtf_rs_resource_extns.source_email%type;
    l_source_phone            jtf_rs_resource_extns.source_phone%type;
    l_source_org_id           jtf_rs_resource_extns.source_org_id%type;
    l_source_org_name         jtf_rs_resource_extns.source_org_name%type;
    l_source_address1         jtf_rs_resource_extns.source_address1%type;
    l_source_address2         jtf_rs_resource_extns.source_address2%type;
    l_source_address3         jtf_rs_resource_extns.source_address3%type;
    l_source_address4         jtf_rs_resource_extns.source_address4%type;
    l_source_city             jtf_rs_resource_extns.source_city%type;
    l_source_postal_code      jtf_rs_resource_extns.source_postal_code%type;
    l_source_state            jtf_rs_resource_extns.source_state%type;
    l_source_province         jtf_rs_resource_extns.source_province%type;
    l_source_county           jtf_rs_resource_extns.source_county%type;
    l_source_country          jtf_rs_resource_extns.source_country%type;
    l_source_mgr_id           jtf_rs_resource_extns.source_mgr_id%type;
    l_source_mgr_name         jtf_rs_resource_extns.source_mgr_name%type;
    l_source_business_grp_id  jtf_rs_resource_extns.source_business_grp_id%type;
    l_source_business_grp_name jtf_rs_resource_extns.source_business_grp_name%type;
    l_source_first_name        jtf_rs_resource_extns.source_first_name%type;
    l_source_last_name         jtf_rs_resource_extns.source_last_name%type;
    l_source_middle_name       jtf_rs_resource_extns.source_middle_name%type;
    l_source_category          jtf_rs_resource_extns.source_category%type;
    l_source_status            jtf_rs_resource_extns.source_status%type;
    l_source_office            jtf_rs_resource_extns.source_office%type;
    l_source_location          jtf_rs_resource_extns.source_location%type;
    l_source_mailstop          jtf_rs_resource_extns.source_mailstop%type;
    l_source_mobile_phone      jtf_rs_resource_extns.source_mobile_phone%type;
    l_source_pager             jtf_rs_resource_extns.source_pager%type;
    l_user_name                jtf_rs_resource_extns.user_name%type;
    l_source_job_id            jtf_rs_resource_extns.source_job_id%type;
    l_party_id                 jtf_rs_resource_extns.person_party_id%type;

    l_return_status             VARCHAR2(2000);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    CURSOR c_jtf_rs_resource_extns( l_rowid   IN  ROWID ) IS
	 SELECT 'Y'
	 FROM jtf_rs_resource_extns
	 WHERE ROWID = l_rowid;

    CURSOR c_dup_resource_id (l_resource_id IN jtf_rs_resource_extns.resource_id%type) IS
        SELECT 'X'
        FROM jtf_rs_resource_extns
        WHERE resource_id = l_resource_id;

    CURSOR c_asg(p_person_id IN NUMBER) IS
    SELECT job_id
    FROM   per_all_assignments_f
    WHERE  person_id = p_source_id
    AND    primary_flag = 'Y'
    AND    assignment_type in ('E','C')
    AND    trunc(sysdate) between effective_start_date and effective_end_date;

    CURSOR c_party_id(p_person_id IN NUMBER) IS
    SELECT ppf.party_id
    FROM   per_all_people_f ppf
    WHERE  ppf.person_id = p_person_id
    AND    trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date;

   l_value     VARCHAR2(100);
   l_address_ret_status varchar2(10);
   l_address_found      boolean := true;

  BEGIN

    l_category                     := upper(p_category);
    l_source_id                    := p_source_id;
    l_address_id                   := p_address_id;
    l_contact_id                   := p_contact_id;
    l_managing_emp_id              := p_managing_emp_id;
    l_start_date_active            := trunc(p_start_date_active);
    l_end_date_active              := trunc(p_end_date_active);
    l_time_zone                    := p_time_zone;
    l_cost_per_hr                  := p_cost_per_hr;
    l_primary_language             := p_primary_language;
    l_secondary_language           := p_secondary_language;
    l_support_site_id              := p_support_site_id;
    l_ies_agent_login              := p_ies_agent_login;
    l_server_group_id              := p_server_group_id;
    l_assigned_to_group_id         := p_assigned_to_group_id;
    l_cost_center                  := p_cost_center;
    l_charge_to_cost_center        := p_charge_to_cost_center;
    l_comp_currency_code           := p_comp_currency_code;
    l_commissionable_flag          := p_commissionable_flag;
    l_hold_reason_code             := p_hold_reason_code;
    l_hold_payment                 := p_hold_payment;
    l_comp_service_team_id         := p_comp_service_team_id;
    l_user_id                      := p_user_id;
    l_transaction_number           := p_transaction_number;
    l_resource_name                := p_resource_name;
    l_source_name                  := p_source_name;
    l_source_number                := p_source_number;
    l_source_job_title             := p_source_job_title;
    l_source_email                 := p_source_email;
    l_source_phone                 := p_source_phone;
    l_source_org_id                := p_source_org_id;
    l_source_org_name              := p_source_org_name;
    l_source_address1              := p_source_address1;
    l_source_address2              := p_source_address2;
    l_source_address3              := p_source_address3;
    l_source_address4              := p_source_address4;
    l_source_city                  := p_source_city;
    l_source_postal_code           := p_source_postal_code;
    l_source_state                 := p_source_state;
    l_source_province              := p_source_province;
    l_source_county                := p_source_county;
    l_source_country               := p_source_country;
    l_source_mgr_id                := p_source_mgr_id;
    l_source_mgr_name              := p_source_mgr_name;
    l_source_business_grp_id       := p_source_business_grp_id;
    l_source_business_grp_name     := p_source_business_grp_name;
    l_source_first_name            := p_source_first_name;
    l_source_last_name             := p_source_last_name;
    l_source_middle_name           := p_source_middle_name;
    l_source_category              := p_source_category;
    l_source_status                := p_source_status;
    l_source_office                := p_source_office;
    l_source_location              := p_source_location;
    l_source_mailstop              := p_source_mailstop;
    l_source_mobile_phone          := p_source_mobile_phone;
    l_source_pager                 := p_source_pager;
    l_user_name                    := p_user_name;

    SAVEPOINT create_resource_pvt;
    x_return_status := fnd_api.g_ret_sts_success;
--    DBMS_OUTPUT.put_line(' Started Create Resource Pvt ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF l_category = 'EMPLOYEE' THEN
      OPEN c_asg(l_source_Id);
      FETCH c_asg INTO l_source_job_id;
      CLOSE c_asg;
      OPEN c_party_id(l_source_Id);
      FETCH c_party_id INTO l_party_id;
      CLOSE c_party_id;
    END IF;
    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_cuhk.create_resource_pre(
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_vuhk.create_resource_pre(
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_iuhk.create_resource_pre(
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;



    /* Validate the Input Dates */

    jtf_resource_utl.validate_input_dates(
      p_start_date_active => l_start_date_active,
      p_end_date_active => l_end_date_active,
      x_return_status => x_return_status
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

   /* Validate for address id in case in PARTNER */
   if(p_category IN  ('PARTNER', 'PARTY'))
   then
     if (p_address_id is NOT NULL) then
         validate_party_address(p_source_id => p_source_id,
                            p_address_id => p_address_id,
                            p_action => 'I',
                            p_found  => l_address_found,
                            p_return_status => l_address_ret_status);

        if(l_address_ret_status <> fnd_api.g_ret_sts_success)
        then
	   IF L_ADDRESS_RET_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF L_ADDRESS_RET_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

        end if;

       if not(l_address_found)
       then
          fnd_message.set_name('JTF', 'JTF_RS_NOT_PRIMARY_ADDR');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;

       end if;
     end if;
   end if; -- end of partner address check

   /* This portion of the code was modified to accomodate the calls to Migration API */
   /* Check if the Global Variable Flag for Resource ID is Y or N */

--     dbms_output.put_line ('Before checkin the Global flag in PVT API');

      IF (G_RS_ID_PVT_FLAG = 'Y') OR (G_RS_ID_PVT_FLAG = 'N' AND JTF_RS_RESOURCE_PUB.G_RESOURCE_ID IS NULL) THEN

         /* Get the next value of the Resource_id from the sequence. */

         LOOP
            SELECT jtf_rs_resource_extns_s.nextval
            INTO l_resource_id
            FROM dual;
            --dbms_output.put_line ('After Select - Resource ID ' || l_resource_id);
            OPEN c_dup_resource_id (l_resource_id);
            FETCH c_dup_resource_id INTO l_check_dup_id;
            EXIT WHEN c_dup_resource_id%NOTFOUND;
            CLOSE c_dup_resource_id;
         END LOOP;
         CLOSE c_dup_resource_id;
      ELSE
        l_resource_id 		:= JTF_RS_RESOURCE_PUB.G_RESOURCE_ID;
      END IF;

      /* Get the next value of the Resource_number from the sequence. */

          SELECT jtf_rs_resource_number_s.nextval
          INTO l_resource_number
          FROM dual;

    /* Make a call to the Resource Audit API */

    jtf_rs_resource_extns_aud_pvt.insert_resource
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_RESOURCE_ID => l_resource_id,
     P_RESOURCE_NUMBER => l_resource_number,
     P_CATEGORY => l_category,
     P_SOURCE_ID => l_source_id,
     P_ADDRESS_ID => l_address_id,
     P_CONTACT_ID => l_contact_id,
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
     P_TRANSACTION_NUMBER => l_transaction_number,
     --P_LOCATION => l_location,
     P_OBJECT_VERSION_NUMBER => 1,
     P_RESOURCE_NAME => l_RESOURCE_NAME,
     P_SOURCE_NAME => l_SOURCE_NAME,
     P_SOURCE_NUMBER => l_SOURCE_NUMBER,
     P_SOURCE_JOB_TITLE => l_SOURCE_JOB_TITLE ,
     P_SOURCE_EMAIL => l_SOURCE_EMAIL ,
     P_SOURCE_PHONE => l_SOURCE_PHONE ,
     P_SOURCE_ORG_ID => l_SOURCE_ORG_ID ,
     P_SOURCE_ORG_NAME => l_SOURCE_ORG_NAME ,
     P_SOURCE_ADDRESS1 => l_SOURCE_ADDRESS1 ,
     P_SOURCE_ADDRESS2 => l_SOURCE_ADDRESS2 ,
     P_SOURCE_ADDRESS3 => l_SOURCE_ADDRESS3 ,
     P_SOURCE_ADDRESS4 => l_SOURCE_ADDRESS4 ,
     P_SOURCE_CITY => l_SOURCE_CITY ,
     P_SOURCE_POSTAL_CODE => l_SOURCE_POSTAL_CODE ,
     P_SOURCE_STATE => l_SOURCE_STATE ,
     P_SOURCE_PROVINCE => l_SOURCE_PROVINCE ,
     P_SOURCE_COUNTY => l_SOURCE_COUNTY ,
     P_SOURCE_COUNTRY => l_SOURCE_COUNTRY ,
     P_SOURCE_MGR_ID => l_SOURCE_MGR_ID ,
     P_SOURCE_MGR_NAME => l_SOURCE_MGR_NAME ,
     P_SOURCE_BUSINESS_GRP_ID => l_SOURCE_BUSINESS_GRP_ID ,
     P_SOURCE_BUSINESS_GRP_NAME => l_SOURCE_BUSINESS_GRP_NAME ,
     P_SOURCE_FIRST_NAME => l_source_first_name ,
     P_SOURCE_LAST_NAME => l_source_last_name ,
     P_SOURCE_MIDDLE_NAME => l_source_middle_name ,
     P_SOURCE_CATEGORY => l_source_category ,
     P_SOURCE_STATUS => l_source_status ,
     P_SOURCE_OFFICE => l_source_office ,
     P_SOURCE_LOCATION => l_source_location ,
     P_SOURCE_MAILSTOP => l_source_mailstop ,
     P_SOURCE_JOB_ID => l_source_job_id ,
     P_PARTY_ID => l_party_id ,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data,
     P_SOURCE_MOBILE_PHONE => l_source_mobile_phone ,
     P_SOURCE_PAGER => l_source_pager
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
--    dbms_output.put_line('Failed status from call to audit procedure');
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

    /* Insert the row into the table by calling the table handler. */

    jtf_rs_resource_extns_pkg.insert_row(
      x_rowid 			=> l_rowid,
      x_resource_id 		=> l_resource_id,
      x_category 		=> l_category,
      x_resource_number 	=> l_resource_number,
      x_source_id 		=> l_source_id,
      x_address_id 		=> l_address_id,
      x_contact_id 		=> l_contact_id,
      x_managing_employee_id 	=> l_managing_emp_id,
      x_start_date_active 	=> l_start_date_active,
      x_end_date_active 	=> l_end_date_active,
      x_time_zone 		=> l_time_zone,
      x_cost_per_hr 		=> l_cost_per_hr,
      x_primary_language 	=> l_primary_language,
      x_secondary_language 	=> l_secondary_language,
      x_support_site_id 	=> l_support_site_id,
      x_ies_agent_login 	=> l_ies_agent_login,
      x_server_group_id 	=> l_server_group_id,
      x_assigned_to_group_id 	=> l_assigned_to_group_id,
      x_cost_center 		=> l_cost_center,
      x_charge_to_cost_center 	=> l_charge_to_cost_center,
      x_compensation_currency_code => l_comp_currency_code,
      x_commissionable_flag 	=> l_commissionable_flag,
      x_hold_reason_code 	=> l_hold_reason_code,
      x_hold_payment 		=> l_hold_payment,
      x_comp_service_team_id 	=> l_comp_service_team_id,
      x_user_id 		=> l_user_id,
      --x_location 		=> l_location,
      x_transaction_number 	=> l_transaction_number,
      x_attribute1 		=> p_attribute1,
      x_attribute2 		=> p_attribute2,
      x_attribute3 		=> p_attribute3,
      x_attribute4 		=> p_attribute4,
      x_attribute5 		=> p_attribute5,
      x_attribute6 		=> p_attribute6,
      x_attribute7 		=> p_attribute7,
      x_attribute8 		=> p_attribute8,
      x_attribute9 		=> p_attribute9,
      x_attribute10 		=> p_attribute10,
      x_attribute11 		=> p_attribute11,
      x_attribute12 		=> p_attribute12,
      x_attribute13 		=> p_attribute13,
      x_attribute14 		=> p_attribute14,
      x_attribute15 		=> p_attribute15,
      x_attribute_category 	=> p_attribute_category,
      x_creation_date 		=> SYSDATE,
      x_created_by 		=> jtf_resource_utl.created_by,
      x_last_update_date 	=> SYSDATE,
      x_last_updated_by 	=> jtf_resource_utl.updated_by,
      x_last_update_login 	=> jtf_resource_utl.login_id,
      x_resource_name		=> l_resource_name,
      x_source_name		=> l_source_name,
      x_source_number		=> l_source_number,
      x_source_job_title	=> l_source_job_title,
      x_source_email		=> l_source_email,
      x_source_phone		=> l_source_phone,
      x_source_org_id		=> l_source_org_id,
      x_source_org_name		=> l_source_org_name,
      x_source_address1		=> l_source_address1,
      x_source_address2         => l_source_address2,
      x_source_address3         => l_source_address3,
      x_source_address4         => l_source_address4,
      x_source_city         	=> l_source_city,
      x_source_postal_code      => l_source_postal_code,
      x_source_state         	=> l_source_state,
      x_source_province         => l_source_province,
      x_source_county         	=> l_source_county,
      x_source_country          => l_source_country,
      x_source_mgr_id           => l_source_mgr_id,
      x_source_mgr_name         => l_source_mgr_name,
      x_source_business_grp_id  => l_source_business_grp_id,
      x_source_business_grp_name=> l_source_business_grp_name,
      x_source_first_name       => l_source_first_name,
      x_source_last_name        => l_source_last_name,
      x_source_middle_name      => l_source_middle_name,
      x_source_category         => l_source_category,
      x_source_status           => l_source_status,
      x_source_office           => l_source_office,
      x_source_location         => l_source_location,
      x_source_mailstop         => l_source_mailstop,
      x_source_mobile_phone     => l_source_mobile_phone,
      x_source_pager            => l_source_pager,
      x_source_job_id           => l_source_job_id,
      x_party_id                => l_party_id,
      x_user_name               => l_user_name
    );

--    dbms_output.put_line('After Insert Procedure');
    OPEN c_jtf_rs_resource_extns(l_rowid);
    FETCH c_jtf_rs_resource_extns INTO l_check_char;
    IF c_jtf_rs_resource_extns%NOTFOUND THEN
--	 dbms_output.put_line('Error in Table Handler');
      IF c_jtf_rs_resource_extns%ISOPEN THEN
        CLOSE c_jtf_rs_resource_extns;
      END IF;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
    ELSE
--	 dbms_output.put_line('Resource Successfully Created');
	 x_resource_id := l_resource_id;
	 x_resource_number := l_resource_number;
    END IF;

    /* Close the cursors */

    IF c_jtf_rs_resource_extns%ISOPEN THEN
      CLOSE c_jtf_rs_resource_extns;
    END IF;

    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_cuhk.create_resource_post(
        p_resource_id 		=> l_resource_id,
        p_category 		=> l_category,
        p_source_id 		=> l_source_id,
        p_address_id 		=> l_address_id,
        p_contact_id 		=> l_contact_id,
        p_managing_emp_id 	=> l_managing_emp_id,
        p_start_date_active 	=> l_start_date_active,
        p_end_date_active 	=> l_end_date_active,
        p_time_zone 		=> l_time_zone,
        p_cost_per_hr 		=> l_cost_per_hr,
        p_primary_language 	=> l_primary_language,
        p_secondary_language 	=> l_secondary_language,
        p_support_site_id 	=> l_support_site_id,
        p_ies_agent_login 	=> l_ies_agent_login,
        p_server_group_id 	=> l_server_group_id,
        p_assigned_to_group_id 	=> l_assigned_to_group_id,
        p_cost_center 		=> l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code 	=> l_comp_currency_code,
        p_commissionable_flag 	=> l_commissionable_flag,
        p_hold_reason_code 	=> l_hold_reason_code,
        p_hold_payment 		=> l_hold_payment,
        p_comp_service_team_id 	=> l_comp_service_team_id,
        p_user_id 		=> l_user_id,
        --p_location 		=> l_location,
	   x_return_status 	=> x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	   fnd_msg_pub.add;
	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;
    END IF;

    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_vuhk.create_resource_post(
        p_resource_id => l_resource_id,
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_iuhk.create_resource_post(
        p_resource_id => l_resource_id,
        p_category => l_category,
        p_source_id => l_source_id,
        p_address_id => l_address_id,
        p_contact_id => l_contact_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
       -- p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'CREATE_RESOURCE',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_cuhk.ok_to_generate_msg(
	       p_resource_id => l_resource_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'resource_id', l_resource_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'RS_RES',
		p_action_code => 'I',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');


	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

	     IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	     ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;


        END IF;

      END IF;

    END IF;
    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

/* Calling publish API to raise create resource event. */
/* added by baianand on 11/04/2002 */

    begin
       jtf_rs_wf_events_pub.create_resource
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_resource_id               => l_resource_id
              ,p_resource_name             => l_resource_name
              ,p_category                  => l_category
              ,p_user_id                   => l_user_id
              ,p_start_date_active         => l_start_date_active
              ,p_end_date_active           => l_end_date_active
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

    EXCEPTION when others then
       null;
    end;

/* End of publish API call */


/* Calling work API for insert record into wf_local tables. */
/* added by baianand on 08/12/2002 */

    begin
       jtf_rs_wf_integration_pub.create_resource
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_resource_id               => l_resource_id
              ,p_resource_name             => l_resource_name
              ,p_category                  => l_category
              ,p_user_id                   => l_user_id
              ,p_email_address             => l_source_email
              ,p_start_date_active         => l_start_date_active
              ,p_end_date_active           => l_end_date_active
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

    EXCEPTION when others then
       null;
    end;

/* End of work API call */


  EXCEPTION


    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_resource_pvt;
-- The below lines removed as a part of fixing GSCC errors in R12 for jtfrspub.pls
--      IF NOT(jtf_resource_utl.check_access(l_value))
--      THEN
--            IF(l_value = 'XMLGEN')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_XMLGEN_ERR');
--		 FND_MSG_PUB.add;
--            ELSIF(l_value = 'JTF_USR_HKS')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_JUHK_ERR');
--		 FND_MSG_PUB.add;
--            END IF;
--      ELSE
	fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	fnd_message.set_token('P_SQLCODE',SQLCODE);
	fnd_message.set_token('P_SQLERRM',SQLERRM);
	fnd_message.set_token('P_API_NAME', l_api_name);
	FND_MSG_PUB.add;
--      END IF;
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
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY,
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
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE
   )
   IS

   BEGIN

     G_RS_ID_PVT_FLAG	:= 'N';

     JTF_RS_RESOURCE_PVT.CREATE_RESOURCE (
       	P_API_VERSION             => P_API_VERSION,
   	P_INIT_MSG_LIST           => P_INIT_MSG_LIST,
   	P_COMMIT                  => P_COMMIT,
   	P_CATEGORY                => P_CATEGORY,
   	P_SOURCE_ID               => P_SOURCE_ID,
   	P_ADDRESS_ID              => P_ADDRESS_ID,
   	P_CONTACT_ID              => P_CONTACT_ID,
   	P_MANAGING_EMP_ID         => P_MANAGING_EMP_ID,
   	P_START_DATE_ACTIVE       => P_START_DATE_ACTIVE,
   	P_END_DATE_ACTIVE         => P_END_DATE_ACTIVE,
   	P_TIME_ZONE               => P_TIME_ZONE,
   	P_COST_PER_HR             => P_COST_PER_HR,
   	P_PRIMARY_LANGUAGE        => P_PRIMARY_LANGUAGE,
   	P_SECONDARY_LANGUAGE      => P_SECONDARY_LANGUAGE,
   	P_SUPPORT_SITE_ID         => P_SUPPORT_SITE_ID,
   	P_IES_AGENT_LOGIN         => P_IES_AGENT_LOGIN,
   	P_SERVER_GROUP_ID         => P_SERVER_GROUP_ID,
   	P_ASSIGNED_TO_GROUP_ID    => P_ASSIGNED_TO_GROUP_ID,
   	P_COST_CENTER             => P_COST_CENTER,
   	P_CHARGE_TO_COST_CENTER   => P_CHARGE_TO_COST_CENTER,
   	P_COMP_CURRENCY_CODE      => P_COMP_CURRENCY_CODE,
   	P_COMMISSIONABLE_FLAG     => P_COMMISSIONABLE_FLAG,
   	P_HOLD_REASON_CODE        => P_HOLD_REASON_CODE,
   	P_HOLD_PAYMENT            => P_HOLD_PAYMENT,
   	P_COMP_SERVICE_TEAM_ID    => P_COMP_SERVICE_TEAM_ID,
   	P_USER_ID                 => P_USER_ID,
   	P_TRANSACTION_NUMBER      => P_TRANSACTION_NUMBER,
      --P_LOCATION                => P_LOCATION,
   	P_ATTRIBUTE1              => P_ATTRIBUTE1,
   	P_ATTRIBUTE2              => P_ATTRIBUTE2,
   	P_ATTRIBUTE3              => P_ATTRIBUTE3,
   	P_ATTRIBUTE4              => P_ATTRIBUTE4,
   	P_ATTRIBUTE5              => P_ATTRIBUTE5,
   	P_ATTRIBUTE6              => P_ATTRIBUTE6,
   	P_ATTRIBUTE7              => P_ATTRIBUTE7,
   	P_ATTRIBUTE8              => P_ATTRIBUTE8,
   	P_ATTRIBUTE9              => P_ATTRIBUTE9,
   	P_ATTRIBUTE10             => P_ATTRIBUTE10,
   	P_ATTRIBUTE11             => P_ATTRIBUTE11,
   	P_ATTRIBUTE12             => P_ATTRIBUTE12,
   	P_ATTRIBUTE13             => P_ATTRIBUTE13,
   	P_ATTRIBUTE14             => P_ATTRIBUTE14,
   	P_ATTRIBUTE15             => P_ATTRIBUTE15,
   	P_ATTRIBUTE_CATEGORY      => P_ATTRIBUTE_CATEGORY,
	P_SOURCE_NAME             => JTF_RESOURCE_UTL.G_SOURCE_NAME,
	P_RESOURCE_NAME    => JTF_RESOURCE_UTL.G_SOURCE_NAME,
   	X_RETURN_STATUS           => X_RETURN_STATUS,
   	X_MSG_COUNT               => X_MSG_COUNT,
   	X_MSG_DATA                => X_MSG_DATA,
   	X_RESOURCE_ID             => X_RESOURCE_ID,
   	X_RESOURCE_NUMBER         => X_RESOURCE_NUMBER
     );

  END create_resource_migrate;

  /* Procedure to update the resource based on input values passed by calling routines. */

  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
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
   --P_LOCATION                IN   MDSYS.SDO_GEOMETRY,
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
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';
  /* Moved the initial assignment of below variables to inside begin */
    l_resource_id                  jtf_rs_resource_extns.resource_id%TYPE;
    l_managing_emp_id              jtf_rs_resource_extns.managing_employee_id%TYPE;
    -- added trunc for the dates 6feb2002
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
    --l_location                     mdsys.sdo_geometry := p_location;
    l_object_version_num           jtf_rs_resource_extns.object_version_number%TYPE;

-- added for NOCOPY to handle in JTF_RESOURCE_UTL
    l_managing_emp_id_out          jtf_rs_resource_extns.managing_employee_id%TYPE ;
    l_server_group_id_out              jtf_rs_resource_extns.server_group_id%TYPE ;
    l_comp_service_team_id_out         jtf_rs_resource_extns.comp_service_team_id%TYPE;

    l_max_end_date                 DATE;
    l_min_start_date               DATE;
    l_bind_data_id                 NUMBER;
    l_check_flag                   VARCHAR2(1);



    CURSOR c_resource_update(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT
	   DECODE(p_managing_emp_id, fnd_api.g_miss_num, managing_employee_id, p_managing_emp_id) managing_emp_id,
           -- added trunc on the dates 6feb 2002
	   DECODE(p_start_date_active, fnd_api.g_miss_date, start_date_active, trunc(p_start_date_active)) start_date_active,
	   DECODE(p_end_date_active, fnd_api.g_miss_date, end_date_active, trunc(p_end_date_active)) end_date_active,
	   DECODE(p_time_zone, fnd_api.g_miss_num, time_zone, p_time_zone) time_zone,
	   DECODE(p_cost_per_hr, fnd_api.g_miss_num, cost_per_hr, p_cost_per_hr) cost_per_hr,
	   DECODE(p_primary_language, fnd_api.g_miss_char, primary_language, p_primary_language) primary_language,
	   DECODE(p_secondary_language, fnd_api.g_miss_char, secondary_language, p_secondary_language) secondary_language,
	   DECODE(p_support_site_id, fnd_api.g_miss_num, support_site_id, p_support_site_id) support_site_id,
        DECODE(p_ies_agent_login, fnd_api.g_miss_char, ies_agent_login, p_ies_agent_login) ies_agent_login,
        DECODE(p_server_group_id, fnd_api.g_miss_num, server_group_id, p_server_group_id) server_group_id,
        DECODE(p_assigned_to_group_id, fnd_api.g_miss_num, assigned_to_group_id, p_assigned_to_group_id) assigned_to_group_id,
        DECODE(p_cost_center, fnd_api.g_miss_char, cost_center, p_cost_center) cost_center,
        DECODE(p_charge_to_cost_center, fnd_api.g_miss_char, charge_to_cost_center, p_charge_to_cost_center) charge_to_cost_center,
        DECODE(p_comp_currency_code, fnd_api.g_miss_char, compensation_currency_code, p_comp_currency_code) comp_currency_code,
        DECODE(p_commissionable_flag, fnd_api.g_miss_char, commissionable_flag, p_commissionable_flag) commissionable_flag,
        DECODE(p_hold_reason_code, fnd_api.g_miss_char, hold_reason_code, p_hold_reason_code) hold_reason_code,
        DECODE(p_hold_payment, fnd_api.g_miss_char, hold_payment, p_hold_payment) hold_payment,
        DECODE(p_comp_service_team_id, fnd_api.g_miss_num, comp_service_team_id, p_comp_service_team_id) comp_service_team_id,
        DECODE(p_user_id, fnd_api.g_miss_num, user_id, p_user_id) user_id,
        --DECODE(p_location, jtf_rs_resource_pub.g_miss_location, location, p_location) location,
	   DECODE(p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1) attribute1,
	   DECODE(p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2) attribute2,
	   DECODE(p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3) attribute3,
	   DECODE(p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4) attribute4,
	   DECODE(p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5) attribute5,
	   DECODE(p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6) attribute6,
	   DECODE(p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7) attribute7,
	   DECODE(p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8) attribute8,
	   DECODE(p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9) attribute9,
	   DECODE(p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10) attribute10,
	   DECODE(p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11) attribute11,
	   DECODE(p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12) attribute12,
	   DECODE(p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13) attribute13,
	   DECODE(p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14) attribute14,
	   DECODE(p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15) attribute15,
	   DECODE(p_attribute_category, fnd_api.g_miss_char, attribute_category, p_attribute_category) attribute_category,
	   category,
	   resource_number,
        source_id,
        address_id,
        contact_id,
	   transaction_number
      FROM jtf_rs_resource_extns_vl
	 WHERE resource_id = l_resource_id;

    resource_rec   c_resource_update%ROWTYPE;


    -- Modtfying the below query for bug # 4956644
    -- New query logic is given in bug # 4052112
    -- OIC expanded the definition of compensation analyst to include any active user in the
    -- system regardless of their assignment to a CN responsibility.
    CURSOR c_assigned_to_group_id(
	 l_assigned_to_group_id    IN  NUMBER)
    IS
	 SELECT u.user_id
      FROM fnd_user u,
	   jtf_rs_resource_extns r
	 WHERE u.user_id = r.user_id
	   AND u.user_id = l_assigned_to_group_id;


    CURSOR c_get_resource_info(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT start_date_active
      FROM jtf_rs_resource_extns
	 WHERE resource_id = l_resource_id;


    CURSOR c_related_role_dates_first(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active),
	   max(end_date_active)
      FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_INDIVIDUAL'
	   AND role_resource_id = l_resource_id
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is not null;


    CURSOR c_related_role_dates_sec(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active)
      FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_INDIVIDUAL'
	   AND role_resource_id = l_resource_id
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is null;


    CURSOR c_grp_mbr_role_dates_first(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active),
	   max(jrrr.end_date_active)
      FROM jtf_rs_group_members jrgm,
	   jtf_rs_role_relations jrrr
      WHERE jrgm.group_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_GROUP_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrgm.delete_flag, 'N') <> 'Y'
	   AND jrgm.resource_id = l_resource_id
	   AND jrrr.end_date_active is not null;


    CURSOR c_grp_mbr_role_dates_sec(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active)
      FROM jtf_rs_group_members jrgm,
	   jtf_rs_role_relations jrrr
      WHERE jrgm.group_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_GROUP_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrgm.delete_flag, 'N') <> 'Y'
	   AND jrgm.resource_id = l_resource_id
	   AND jrrr.end_date_active is null;


    CURSOR c_team_mbr_role_dates_first(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active),
	   max(jrrr.end_date_active)
      FROM jtf_rs_team_members jrtm,
	   jtf_rs_role_relations jrrr
      WHERE jrtm.team_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrtm.delete_flag, 'N') <> 'Y'
	   AND jrtm.team_resource_id = l_resource_id
	   AND jrtm.resource_type = 'INDIVIDUAL'
	   AND jrrr.end_date_active is not null;


    CURSOR c_team_mbr_role_dates_sec(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active)
      FROM jtf_rs_team_members jrtm,
	   jtf_rs_role_relations jrrr
      WHERE jrtm.team_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrtm.delete_flag, 'N') <> 'Y'
	   AND jrtm.team_resource_id = l_resource_id
	   AND jrtm.resource_type = 'INDIVIDUAL'
	   AND jrrr.end_date_active is null;


    CURSOR c_salesrep_dates_first(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active),
	   max(end_date_active)
      FROM jtf_rs_salesreps
	 WHERE resource_id = l_resource_id
	   AND end_date_active is not null;


    CURSOR c_salesrep_dates_sec(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active)
      FROM jtf_rs_salesreps
	 WHERE resource_id = l_resource_id
	   AND end_date_active is null;

    CURSOR c_validate_user_id(
         l_resource_id    IN  NUMBER,
         l_user_id        IN  NUMBER)
    IS
         SELECT 'Y'
      FROM jtf_rs_resource_extns
         WHERE user_id = l_user_id
         AND   resource_id <> l_resource_id;

   l_value     VARCHAR2(100);

  l_address_ret_status varchar2(10);
  l_address_found      boolean := true;
  BEGIN

    l_resource_id                  := p_resource_id;
    l_managing_emp_id              := p_managing_emp_id;
    l_start_date_active            := trunc(p_start_date_active);
    l_end_date_active              := trunc(p_end_date_active);
    l_time_zone                    := p_time_zone;
    l_cost_per_hr                  := p_cost_per_hr;
    l_primary_language             := p_primary_language;
    l_secondary_language           := p_secondary_language;
    l_support_site_id              := p_support_site_id;
    l_ies_agent_login              := p_ies_agent_login;
    l_server_group_id              := p_server_group_id;
    l_assigned_to_group_id         := p_assigned_to_group_id;
    l_cost_center                  := p_cost_center;
    l_charge_to_cost_center        := p_charge_to_cost_center;
    l_comp_currency_code           := p_comp_currency_code;
    l_commissionable_flag          := p_commissionable_flag;
    l_hold_reason_code             := p_hold_reason_code;
    l_hold_payment                 := p_hold_payment;
    l_comp_service_team_id         := p_comp_service_team_id;
    l_user_id                      := p_user_id;
    l_object_version_num           := p_object_version_num;

    SAVEPOINT update_resource_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line('Started Update Resource Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;

    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_cuhk.update_resource_pre(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
       -- p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_vuhk.update_resource_pre(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
       -- p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_iuhk.update_resource_pre(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;
    END IF;


    OPEN c_resource_update(l_resource_id);

    FETCH c_resource_update INTO resource_rec;


    IF c_resource_update%NOTFOUND THEN

      IF c_resource_update%ISOPEN THEN

        CLOSE c_resource_update;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE');
	 fnd_message.set_token('P_RESOURCE_ID', l_resource_id);
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;


    END IF;

    /* Validate the Managing Employee Id if specified */

    IF l_managing_emp_id <> fnd_api.g_miss_num THEN

      jtf_resource_utl.validate_employee_resource(
        p_emp_resource_id => l_managing_emp_id,
        p_emp_resource_number => null,
        x_return_status => x_return_status,
        x_emp_resource_id => l_managing_emp_id_out
      );
-- added for NOCOPY
      l_managing_emp_id  := l_managing_emp_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;


    /* Validate the Input Dates */

    IF l_start_date_active <> fnd_api.g_miss_date OR
	  l_end_date_active <> fnd_api.g_miss_date THEN

    -- Code changes to fix bug 4171623. (G_MISS_DATE DOESN'T WORK PROPERLY ON JTF_RS_RESOURCE_PUB).

    -- Changing the values being passed to "validate_input_dates" procedure,
    -- from l_end_date_active to resource_rec.end_date_active (same for start date)
    -- so that it validates the correct dates which its supposed to validate.

      jtf_resource_utl.validate_input_dates(
        p_start_date_active => resource_rec.start_date_active,
        p_end_date_active => resource_rec.end_date_active,
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

    /* Validate that the resource dates cover the role related dates for the
	  resource */

    /* First part of the validation where the role relate end date active
	  is not null */

    OPEN c_related_role_dates_first(l_resource_id);

    FETCH c_related_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        /* Resource Start Date out of range for the role related start dates of the resource */

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_ROLE_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_end_date_active <> FND_API.G_MISS_DATE AND
           l_max_end_date > l_end_date_active AND
           l_end_date_active IS NOT NULL ) THEN

        /* Resource End Date out of range for the role related End dates of the Resource */

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_ROLE_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_role_dates_first%ISOPEN THEN

      CLOSE c_related_role_dates_first;

    END IF;



    /* Second part of the validation where the role relate end date active
	  is null */

    OPEN c_related_role_dates_sec(l_resource_id);

    FETCH c_related_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF  l_start_date_active <> FND_API.G_MISS_DATE AND
          l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_ROLE_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active <> FND_API.G_MISS_DATE AND
         l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_ROLE_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_role_dates_sec%ISOPEN THEN

      CLOSE c_related_role_dates_sec;

    END IF;



    /* Validate that the resource dates cover the group member role related dates for the
	  resource */

    /* First part of the validation where the group member role relate end date active
	  is not null */

    OPEN c_grp_mbr_role_dates_first(l_resource_id);

    FETCH c_grp_mbr_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_GMBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_end_date_active <> FND_API.G_MISS_DATE AND
           l_max_end_date > l_end_date_active AND
           l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_GMBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;


    /* Close the cursor */

    IF c_grp_mbr_role_dates_first%ISOPEN THEN

      CLOSE c_grp_mbr_role_dates_first;

    END IF;



    /* Second part of the validation where the member role relate end date active
	  is null */

    OPEN c_grp_mbr_role_dates_sec(l_resource_id);

    FETCH c_grp_mbr_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_GMBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active <> FND_API.G_MISS_DATE AND
         l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_GMBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_grp_mbr_role_dates_sec%ISOPEN THEN

      CLOSE c_grp_mbr_role_dates_sec;

    END IF;



    /* Validate that the resource dates cover the team member role related dates for the
	  resource, where the team member is a resource */

    /* First part of the validation where the team member role relate end date active
	  is not null */

    OPEN c_team_mbr_role_dates_first(l_resource_id);

    FETCH c_team_mbr_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_TMBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_end_date_active <> FND_API.G_MISS_DATE AND
           l_max_end_date > l_end_date_active AND
           l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_TMBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;



    /* Close the cursor */

    IF c_team_mbr_role_dates_first%ISOPEN THEN

      CLOSE c_team_mbr_role_dates_first;

    END IF;



    /* Second part of the validation where the member role relate end date active
	  is null */

    OPEN c_team_mbr_role_dates_sec(l_resource_id);

    FETCH c_team_mbr_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_TMBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active <> FND_API.G_MISS_DATE AND
         l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_TMBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_team_mbr_role_dates_sec%ISOPEN THEN

      CLOSE c_team_mbr_role_dates_sec;

    END IF;



    /* Validate that the resource dates cover the salesrep related dates for the
	  resource */

    /* First part of the validation where the salesrep end date active
	  is not null */

    OPEN c_salesrep_dates_first(l_resource_id);

    FETCH c_salesrep_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        /* Resource Start Date out of range for the salesrep related start dates of the resource */

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_SRP_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_end_date_active <> FND_API.G_MISS_DATE AND
           l_max_end_date > l_end_date_active AND
           l_end_date_active IS NOT NULL ) THEN

        /* Resource End Date out of range for the salesrep related End dates of the Resource */

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_SRP_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_salesrep_dates_first%ISOPEN THEN

      CLOSE c_salesrep_dates_first;

    END IF;



    /* Second part of the validation where the role relate end date active
	  is null */

    OPEN c_salesrep_dates_sec(l_resource_id);

    FETCH c_salesrep_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_SRP_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active <> FND_API.G_MISS_DATE AND
         l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_SRP_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_salesrep_dates_sec%ISOPEN THEN

      CLOSE c_salesrep_dates_sec;

    END IF;



    /* Validate the Time Zone */

    IF l_time_zone <> fnd_api.g_miss_num THEN

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

    END IF;



    /* Validate the Primary Language */

    IF l_primary_language <> fnd_api.g_miss_char THEN

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

    END IF;



    /* Validate the Secondary Language */

    IF l_secondary_language <> fnd_api.g_miss_char THEN

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

    END IF;



    /* Validate the Support Site */

    IF l_support_site_id <> fnd_api.g_miss_num THEN

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

    END IF;



    /* Validate the Server Group. */

    IF l_server_group_id <> fnd_api.g_miss_num THEN

      jtf_resource_utl.validate_server_group(
        p_server_group_id => l_server_group_id,
        p_server_group_name => null,
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

    END IF;



    /* Validate the assigned_to_group_id if specified */

    IF l_assigned_to_group_id <> fnd_api.g_miss_num THEN

      IF l_assigned_to_group_id IS NOT NULL THEN

        OPEN c_assigned_to_group_id(l_assigned_to_group_id);

        FETCH c_assigned_to_group_id INTO l_assigned_to_group_id;


        IF c_assigned_to_group_id%NOTFOUND THEN

--          dbms_output.put_line('Invalid Assigned To Group Id');

          fnd_message.set_name('JTF', 'JTF_RS_ERR_ASSIGN_TO_GRP_ID');
          fnd_message.set_token('P_ASSIGNED_TO_GROUP_ID', l_assigned_to_group_id);
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;


        END IF;


        /* Close the cursor */

        IF c_assigned_to_group_id%ISOPEN THEN

          CLOSE c_assigned_to_group_id;

        END IF;

      END IF;

    END IF;



    /* Validate the Comp Currency Code */

    IF l_comp_currency_code <> fnd_api.g_miss_char THEN

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

    END IF;



    /* Validate the value of the commisionable flag */

    IF l_commissionable_flag <> fnd_api.g_miss_char THEN

      IF l_commissionable_flag <> 'Y' AND l_commissionable_flag <> 'N' THEN

--	   dbms_output.put_line('Commissionable Flag should either be ''Y'' or ''N'' ');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;



    /* Validate the value of the Hold Payment flag */

    IF l_hold_payment <> fnd_api.g_miss_char THEN

      IF l_hold_payment <> 'Y' AND l_hold_payment <> 'N' THEN

--	   dbms_output.put_line('Hold Payment should either be ''Y'' or ''N'' ');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;



    /* Validate the Hold Reason Code */

    IF l_hold_reason_code <> fnd_api.g_miss_char THEN

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

    END IF;


    /* Validate that the user_id should only be specified in case of
	  'EMPLOYEE', 'PARTY', 'SUPPLIER_CONTACT' categories */

    IF l_user_id <> fnd_api.g_miss_num THEN

/* Removed 'WORKER' from the below code to fix bug # 3455951 */
      IF resource_rec.category NOT IN ('EMPLOYEE', 'PARTY', 'SUPPLIER_CONTACT') AND l_user_id IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_USERID_ERROR');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


	 END IF;

    END IF;


    IF l_user_id <> fnd_api.g_miss_num THEN

      /* Validate the User Id if specified */

      IF l_user_id IS NOT NULL THEN

        jtf_resource_utl.validate_user_id(
          p_user_id => l_user_id,
          p_category => resource_rec.category,
          p_source_id => resource_rec.source_id,
          x_return_status => x_return_status
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

        else

        OPEN c_validate_user_id(l_resource_id,l_user_id);

        FETCH c_validate_user_id INTO l_check_flag
;


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

    IF l_comp_service_team_id <> fnd_api.g_miss_num THEN

      IF l_comp_service_team_id IS NOT NULL THEN

        jtf_resource_utl.validate_resource_team(
          p_team_id => l_comp_service_team_id,
          p_team_number => null,
          x_return_status => x_return_status,
          x_team_id => l_comp_service_team_id_out
        );
-- added for NOCOPY
        l_comp_service_team_id  := l_comp_service_team_id_out;


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


        END IF;

      END IF;

    END IF;


    /* Call the lock row procedure to ensure that the object version number
	  is still valid. */

    BEGIN

      jtf_rs_resource_extns_pkg.lock_row(
        x_resource_id => l_resource_id,
	   x_object_version_number => p_object_version_num
      );

     --dbms_output.put_line ('After Call to Lock Row Procedure');


    EXCEPTION

	 WHEN OTHERS THEN

--	   dbms_output.put_line('Error in Locking the Row');

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	   fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;


    END;

    --dbms_output.put_line ('Before Call to Audit API');


    /* Make a call to the Resource Audit API */

    jtf_rs_resource_extns_aud_pvt.update_resource
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_RESOURCE_ID => l_resource_id,
     P_RESOURCE_NUMBER => resource_rec.resource_number,
     P_CATEGORY => resource_rec.category,
     P_SOURCE_ID => resource_rec.source_id,
	P_ADDRESS_ID => resource_rec.address_id,
	P_CONTACT_ID => resource_rec.contact_id,
	P_MANAGING_EMP_ID => resource_rec.managing_emp_id,
	P_START_DATE_ACTIVE => resource_rec.start_date_active,
	P_END_DATE_ACTIVE => resource_rec.end_date_active,
     P_TIME_ZONE => resource_rec.time_zone,
     P_COST_PER_HR => resource_rec.cost_per_hr,
     P_PRIMARY_LANGUAGE => resource_rec.primary_language,
     P_SECONDARY_LANGUAGE => resource_rec.secondary_language,
     P_SUPPORT_SITE_ID => resource_rec.support_site_id,
     P_IES_AGENT_LOGIN => resource_rec.ies_agent_login,
     P_SERVER_GROUP_ID => resource_rec.server_group_id,
     P_ASSIGNED_TO_GROUP_ID => resource_rec.assigned_to_group_id,
     P_COST_CENTER => resource_rec.cost_center,
     P_CHARGE_TO_COST_CENTER => resource_rec.charge_to_cost_center,
     P_COMP_CURRENCY_CODE => resource_rec.comp_currency_code,
     P_COMMISSIONABLE_FLAG => resource_rec.commissionable_flag,
     P_HOLD_REASON_CODE => resource_rec.hold_reason_code,
     P_HOLD_PAYMENT => resource_rec.hold_payment,
     P_COMP_SERVICE_TEAM_ID => resource_rec.comp_service_team_id,
     P_USER_ID => resource_rec.user_id,
     P_TRANSACTION_NUMBER => resource_rec.transaction_number,
    -- P_LOCATION => resource_rec.location,
	P_OBJECT_VERSION_NUMBER => p_object_version_num + 1,
     X_RETURN_STATUS => x_return_status,
     X_MSG_COUNT => x_msg_count,
     X_MSG_DATA => x_msg_data
    );

    --dbms_output.put_line ('After Call to Audit API');

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to audit procedure');

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


    END IF;


    BEGIN

      /* Increment the object version number */

	 l_object_version_num := p_object_version_num + 1;

    --dbms_output.put_line ('Before Call to Update Row Table Handler ');


      /* Update the row into the table by calling the table handler. */

      jtf_rs_resource_extns_pkg.update_row(
        x_resource_id => l_resource_id,
        x_category => resource_rec.category,
        x_resource_number => resource_rec.resource_number,
        x_source_id => resource_rec.source_id,
        x_address_id => resource_rec.address_id,
        x_contact_id => resource_rec.contact_id,
        x_managing_employee_id => resource_rec.managing_emp_id,
        x_start_date_active => resource_rec.start_date_active,
        x_end_date_active => resource_rec.end_date_active,
        x_time_zone => resource_rec.time_zone,
        x_cost_per_hr => resource_rec.cost_per_hr,
        x_primary_language => resource_rec.primary_language,
        x_secondary_language => resource_rec.secondary_language,
        x_support_site_id => resource_rec.support_site_id,
        x_ies_agent_login => resource_rec.ies_agent_login,
        x_server_group_id => resource_rec.server_group_id,
        x_assigned_to_group_id => resource_rec.assigned_to_group_id,
        x_cost_center => resource_rec.cost_center,
        x_charge_to_cost_center => resource_rec.charge_to_cost_center,
        x_compensation_currency_code => resource_rec.comp_currency_code,
        x_commissionable_flag => resource_rec.commissionable_flag,
        x_hold_reason_code => resource_rec.hold_reason_code,
        x_hold_payment => resource_rec.hold_payment,
        x_comp_service_team_id => resource_rec.comp_service_team_id,
        x_user_id => resource_rec.user_id,
        --x_location => resource_rec.location,
        x_transaction_number => resource_rec.transaction_number,
	   x_object_version_number => l_object_version_num,
        x_attribute1 => resource_rec.attribute1,
        x_attribute2 => resource_rec.attribute2,
        x_attribute3 => resource_rec.attribute3,
        x_attribute4 => resource_rec.attribute4,
        x_attribute5 => resource_rec.attribute5,
        x_attribute6 => resource_rec.attribute6,
        x_attribute7 => resource_rec.attribute7,
        x_attribute8 => resource_rec.attribute8,
        x_attribute9 => resource_rec.attribute9,
        x_attribute10 => resource_rec.attribute10,
        x_attribute11 => resource_rec.attribute11,
        x_attribute12 => resource_rec.attribute12,
        x_attribute13 => resource_rec.attribute13,
        x_attribute14 => resource_rec.attribute14,
        x_attribute15 => resource_rec.attribute15,
        x_attribute_category => resource_rec.attribute_category,
        x_last_update_date => SYSDATE,
        x_last_updated_by => jtf_resource_utl.updated_by,
        x_last_update_login => jtf_resource_utl.login_id
      );

      --dbms_output.put_line ('After Call to Update Row Table Handler ');

      /* Return the new value of the object version number */

      p_object_version_num := l_object_version_num;

    EXCEPTION

	 WHEN NO_DATA_FOUND THEN

--	   dbms_output.put_line('Error in Table Handler');

        IF c_resource_update%ISOPEN THEN

          CLOSE c_resource_update;

        END IF;

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	   fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;


    END;

--    dbms_output.put_line('Resource Successfully Updated');


    /* Close the cursors */

    IF c_resource_update%ISOPEN THEN

      CLOSE c_resource_update;

    END IF;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_cuhk.update_resource_post(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_vuhk.update_resource_post(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_iuhk.update_resource_post(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_cuhk.ok_to_generate_msg(
	       p_resource_id => l_resource_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'resource_id', l_resource_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'RES',
		p_action_code => 'U',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');


	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

	     IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	     ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;


        END IF;

      END IF;

    END IF;
    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_resource_pvt;
-- The below lines removed as a part of fixing GSCC errors in R12 for jtfrspub.pls
--      IF NOT(jtf_resource_utl.check_access(l_value))
--      THEN
--            IF(l_value = 'XMLGEN')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_XMLGEN_ERR');
--		 FND_MSG_PUB.add;
--            ELSIF(l_value = 'JTF_USR_HKS')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_JUHK_ERR');
--		 FND_MSG_PUB.add;
--            END IF;
--      ELSE
	 fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	 fnd_message.set_token('P_SQLCODE',SQLCODE);
	 fnd_message.set_token('P_SQLERRM',SQLERRM);
	 fnd_message.set_token('P_API_NAME', l_api_name);
	 FND_MSG_PUB.add;
--      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);


  END update_resource;

  /* Overloaded Procedure to update the resource for Resource Synchronization */

  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2,
   P_COMMIT                  IN   VARCHAR2,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
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
   --P_LOCATION              IN   MDSYS.SDO_GEOMETRY,
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
   P_SOURCE_MGR_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_ID%type,
   P_SOURCE_MGR_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_NAME%type,
   P_SOURCE_BUSINESS_GRP_ID  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_ID%type,
   P_SOURCE_BUSINESS_GRP_NAME IN  JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_NAME%type,
   P_SOURCE_FIRST_NAME        IN JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE,
   P_SOURCE_LAST_NAME         IN JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE,
   P_SOURCE_MIDDLE_NAME       IN JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE,
   P_SOURCE_CATEGORY          IN JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE,
   P_SOURCE_STATUS            IN JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE,
   P_SOURCE_OFFICE            IN JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE,
   P_SOURCE_LOCATION          IN JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE,
   P_SOURCE_MAILSTOP          IN JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE,
   P_ADDRESS_ID               IN JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
   P_OBJECT_VERSION_NUM       IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   P_USER_NAME                IN  VARCHAR2,
   X_RETURN_STATUS            OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT                OUT NOCOPY  NUMBER,
   X_MSG_DATA                 OUT NOCOPY  VARCHAR2,
   P_SOURCE_MOBILE_PHONE      IN JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE,
   P_SOURCE_PAGER             IN JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';
  /* Moved the initial assignment of below variables to inside begin */
    l_resource_id                  jtf_rs_resource_extns.resource_id%TYPE;
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
    --l_location                     mdsys.sdo_geometry := p_location;
    l_object_version_num           jtf_rs_resource_extns.object_version_number%TYPE;

    l_max_end_date                 DATE;
    l_min_start_date               DATE;
    l_bind_data_id                 NUMBER;
    l_check_flag                   VARCHAR2(1);

  /* Moved the initial assignment of below variables to inside begin */
    l_resource_name           jtf_rs_resource_extns_tl.resource_name%type;
    l_source_name             jtf_rs_resource_extns.source_name%type;
    l_source_number           jtf_rs_resource_extns.source_number%type;
    l_source_job_title        jtf_rs_resource_extns.source_job_title%type;
    l_source_email            jtf_rs_resource_extns.source_email%type;
    l_source_phone            jtf_rs_resource_extns.source_phone%type;
    l_source_org_id           number;
    l_source_org_name         jtf_rs_resource_extns.source_org_name%type;
    l_source_address1         jtf_rs_resource_extns.source_address1%type;
    l_source_address2         jtf_rs_resource_extns.source_address2%type;
    l_source_address3         jtf_rs_resource_extns.source_address3%type;
    l_source_address4         jtf_rs_resource_extns.source_address4%type;
    l_source_city             jtf_rs_resource_extns.source_city%type;
    l_source_postal_code      jtf_rs_resource_extns.source_postal_code%type;
    l_source_state            jtf_rs_resource_extns.source_state%type;
    l_source_province         jtf_rs_resource_extns.source_province%type;
    l_source_county           jtf_rs_resource_extns.source_county%type;
    l_source_country          jtf_rs_resource_extns.source_country%type;
    l_source_mgr_id           jtf_rs_resource_extns.source_mgr_id%type;
    l_source_mgr_name         jtf_rs_resource_extns.source_mgr_name%type;
    l_source_business_grp_id  jtf_rs_resource_extns.source_business_grp_id%type;
    l_source_business_grp_name jtf_rs_resource_extns.source_business_grp_name%type;
    l_source_first_name       jtf_rs_resource_extns.source_first_name%type;
    l_source_last_name        jtf_rs_resource_extns.source_last_name%type;
    l_source_middle_name      jtf_rs_resource_extns.source_middle_name%type;
    l_source_status           jtf_rs_resource_extns.source_status%type;
    l_source_office           jtf_rs_resource_extns.source_office%type;
    l_source_location         jtf_rs_resource_extns.source_location%type;
    l_source_mailstop         jtf_rs_resource_extns.source_mailstop%type;
    l_source_mobile_phone     jtf_rs_resource_extns.source_mobile_phone%type;
    l_source_pager            jtf_rs_resource_extns.source_pager%type;
    l_address_id              jtf_rs_resource_extns.address_id%type;
    l_source_category         jtf_rs_resource_extns.source_category%type;
    l_user_name               jtf_rs_resource_extns.user_name%type;


--added for NOCOPY to handle in JTF_RESOURCE_UTL
    l_managing_emp_id_out          jtf_rs_resource_extns.managing_employee_id%TYPE ;
    l_server_group_id_out              jtf_rs_resource_extns.server_group_id%TYPE ;
    l_comp_service_team_id_out         jtf_rs_resource_extns.comp_service_team_id%TYPE;


    CURSOR c_resource_update(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT
	   DECODE(p_managing_emp_id, fnd_api.g_miss_num, managing_employee_id, p_managing_emp_id) managing_emp_id,
	   DECODE(p_start_date_active, fnd_api.g_miss_date, start_date_active, trunc(p_start_date_active)) start_date_active,
	   DECODE(p_end_date_active, fnd_api.g_miss_date, end_date_active,trunc(p_end_date_active)) end_date_active,
	   DECODE(p_time_zone, fnd_api.g_miss_num, time_zone, p_time_zone) time_zone,
	   DECODE(p_cost_per_hr, fnd_api.g_miss_num, cost_per_hr, p_cost_per_hr) cost_per_hr,
	   DECODE(p_primary_language, fnd_api.g_miss_char, primary_language, p_primary_language) primary_language,
	   DECODE(p_secondary_language, fnd_api.g_miss_char, secondary_language, p_secondary_language) secondary_language,
	   DECODE(p_support_site_id, fnd_api.g_miss_num, support_site_id, p_support_site_id) support_site_id,
        DECODE(p_ies_agent_login, fnd_api.g_miss_char, ies_agent_login, p_ies_agent_login) ies_agent_login,
        DECODE(p_server_group_id, fnd_api.g_miss_num, server_group_id, p_server_group_id) server_group_id,
        DECODE(p_assigned_to_group_id, fnd_api.g_miss_num, assigned_to_group_id, p_assigned_to_group_id) assigned_to_group_id,
        DECODE(p_cost_center, fnd_api.g_miss_char, cost_center, p_cost_center) cost_center,
        DECODE(p_charge_to_cost_center, fnd_api.g_miss_char, charge_to_cost_center, p_charge_to_cost_center) charge_to_cost_center,
        DECODE(p_comp_currency_code, fnd_api.g_miss_char, compensation_currency_code, p_comp_currency_code) comp_currency_code,
        DECODE(p_commissionable_flag, fnd_api.g_miss_char, commissionable_flag, p_commissionable_flag) commissionable_flag,
        DECODE(p_hold_reason_code, fnd_api.g_miss_char, hold_reason_code, p_hold_reason_code) hold_reason_code,
        DECODE(p_hold_payment, fnd_api.g_miss_char, hold_payment, p_hold_payment) hold_payment,
        DECODE(p_comp_service_team_id, fnd_api.g_miss_num, comp_service_team_id, p_comp_service_team_id) comp_service_team_id,
        DECODE(p_user_id, fnd_api.g_miss_num, user_id, p_user_id) user_id,
        --DECODE(p_location, jtf_rs_resource_pub.g_miss_location, location, p_location) location,
	   DECODE(p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1) attribute1,
	   DECODE(p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2) attribute2,
	   DECODE(p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3) attribute3,
	   DECODE(p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4) attribute4,
	   DECODE(p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5) attribute5,
	   DECODE(p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6) attribute6,
	   DECODE(p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7) attribute7,
	   DECODE(p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8) attribute8,
	   DECODE(p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9) attribute9,
	   DECODE(p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10) attribute10,
	   DECODE(p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11) attribute11,
	   DECODE(p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12) attribute12,
	   DECODE(p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13) attribute13,
	   DECODE(p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14) attribute14,
	   DECODE(p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15) attribute15,
	   DECODE(p_attribute_category, fnd_api.g_miss_char, attribute_category, p_attribute_category) attribute_category,
           DECODE(p_resource_name, fnd_api.g_miss_char, resource_name, p_resource_name) resource_name,
           DECODE(p_source_name, fnd_api.g_miss_char, source_name, p_source_name) source_name,
           DECODE(p_source_number, fnd_api.g_miss_char, source_number, p_source_number) source_number,
           DECODE(p_source_job_title, fnd_api.g_miss_char, source_job_title, p_source_job_title) source_job_title,
           DECODE(p_source_email, fnd_api.g_miss_char, source_email, p_source_email) source_email,
           DECODE(p_source_phone, fnd_api.g_miss_char, source_phone, p_source_phone) source_phone,
           DECODE(p_source_org_id, fnd_api.g_miss_num, source_org_id, p_source_org_id) source_org_id,
           DECODE(p_source_org_name, fnd_api.g_miss_char, source_org_name, p_source_org_name) source_org_name,
           DECODE(p_source_address1, fnd_api.g_miss_char, source_address1, p_source_address1) source_address1,
           DECODE(p_source_address2, fnd_api.g_miss_char, source_address2, p_source_address2) source_address2,
           DECODE(p_source_address3, fnd_api.g_miss_char, source_address3, p_source_address3) source_address3,
           DECODE(p_source_address4, fnd_api.g_miss_char, source_address4, p_source_address4) source_address4,
           DECODE(p_source_city, fnd_api.g_miss_char, source_city, p_source_city) source_city,
           DECODE(p_source_postal_code, fnd_api.g_miss_char, source_postal_code, p_source_postal_code) source_postal_code,
           DECODE(p_source_state, fnd_api.g_miss_char, source_state, p_source_state) source_state,
           DECODE(p_source_province, fnd_api.g_miss_char, source_province, p_source_province) source_province,
           DECODE(p_source_county, fnd_api.g_miss_char, source_county, p_source_county) source_county,
           DECODE(p_source_country, fnd_api.g_miss_char, source_country, p_source_country) source_country,
           DECODE(p_source_mgr_id, fnd_api.g_miss_num, source_mgr_id, p_source_mgr_id) source_mgr_id,
           DECODE(p_source_mgr_name, fnd_api.g_miss_char, source_mgr_name, p_source_mgr_name) source_mgr_name,
           DECODE(p_source_business_grp_id, fnd_api.g_miss_num, source_business_grp_id, p_source_business_grp_id) source_business_grp_id,
           DECODE(p_source_business_grp_name, fnd_api.g_miss_char, source_business_grp_name, p_source_business_grp_name) source_business_grp_name,
           DECODE(p_source_first_name, fnd_api.g_miss_char, source_first_name, p_source_first_name) source_first_name,
           DECODE(p_source_middle_name, fnd_api.g_miss_char, source_middle_name, p_source_middle_name) source_middle_name,
           DECODE(p_source_last_name, fnd_api.g_miss_char, source_last_name, p_source_last_name) source_last_name,
           DECODE(p_source_category, fnd_api.g_miss_char, source_category, p_source_category) source_category,
           DECODE(p_source_status, fnd_api.g_miss_char, source_status, p_source_status) source_status,
           DECODE(p_source_office, fnd_api.g_miss_char, source_office, p_source_office) source_office,
           DECODE(p_source_location, fnd_api.g_miss_char, source_location, p_source_location) source_location,
           DECODE(p_source_mailstop, fnd_api.g_miss_char, source_mailstop, p_source_mailstop) source_mailstop,
           DECODE(p_source_mobile_phone, fnd_api.g_miss_char, source_mobile_phone, p_source_mobile_phone) source_mobile_phone,
           DECODE(p_source_pager, fnd_api.g_miss_char, source_pager, p_source_pager) source_pager,
           DECODE(p_address_id, fnd_api.g_miss_num, address_id, p_address_id) address_id,
           DECODE(p_user_name, fnd_api.g_miss_char, user_name, p_user_name) user_name,
           PERSON_PARTY_ID,
           SOURCE_JOB_ID,
	   category,
	   resource_number,
        source_id,
        contact_id,
	transaction_number,
        address_id old_address_id
      FROM jtf_rs_resource_extns_vl
      WHERE resource_id = l_resource_id;

    resource_rec   c_resource_update%ROWTYPE;

    -- Modtfying the below query for bug # 4956644
    -- New query logic is given in bug # 4052112
    -- OIC expanded the definition of compensation analyst to include any active user in the
    -- system regardless of their assignment to a CN responsibility.
    CURSOR c_assigned_to_group_id(
	 l_assigned_to_group_id    IN  NUMBER)
    IS
      SELECT u.user_id
      FROM fnd_user u,
	   jtf_rs_resource_extns r
      WHERE u.user_id = r.user_id
      AND u.user_id = l_assigned_to_group_id;


    CURSOR c_get_resource_info(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT start_date_active
      FROM jtf_rs_resource_extns
	 WHERE resource_id = l_resource_id;


    CURSOR c_related_role_dates_first(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active),
	   max(end_date_active)
      FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_INDIVIDUAL'
	   AND role_resource_id = l_resource_id
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is not null;


    CURSOR c_related_role_dates_sec(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active)
      FROM jtf_rs_role_relations
	 WHERE role_resource_type = 'RS_INDIVIDUAL'
	   AND role_resource_id = l_resource_id
	   AND nvl(delete_flag, 'N') <> 'Y'
	   AND end_date_active is null;


    CURSOR c_grp_mbr_role_dates_first(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active),
	   max(jrrr.end_date_active)
      FROM jtf_rs_group_members jrgm,
	   jtf_rs_role_relations jrrr
      WHERE jrgm.group_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_GROUP_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrgm.delete_flag, 'N') <> 'Y'
	   AND jrgm.resource_id = l_resource_id
	   AND jrrr.end_date_active is not null;


    CURSOR c_grp_mbr_role_dates_sec(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active)
      FROM jtf_rs_group_members jrgm,
	   jtf_rs_role_relations jrrr
      WHERE jrgm.group_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_GROUP_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrgm.delete_flag, 'N') <> 'Y'
	   AND jrgm.resource_id = l_resource_id
	   AND jrrr.end_date_active is null;


    CURSOR c_team_mbr_role_dates_first(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active),
	   max(jrrr.end_date_active)
      FROM jtf_rs_team_members jrtm,
	   jtf_rs_role_relations jrrr
      WHERE jrtm.team_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrtm.delete_flag, 'N') <> 'Y'
	   AND jrtm.team_resource_id = l_resource_id
	   AND jrtm.resource_type = 'INDIVIDUAL'
	   AND jrrr.end_date_active is not null;


    CURSOR c_team_mbr_role_dates_sec(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(jrrr.start_date_active)
      FROM jtf_rs_team_members jrtm,
	   jtf_rs_role_relations jrrr
      WHERE jrtm.team_member_id = jrrr.role_resource_id
	   AND jrrr.role_resource_type = 'RS_TEAM_MEMBER'
	   AND nvl(jrrr.delete_flag, 'N') <> 'Y'
	   AND nvl(jrtm.delete_flag, 'N') <> 'Y'
	   AND jrtm.team_resource_id = l_resource_id
	   AND jrtm.resource_type = 'INDIVIDUAL'
	   AND jrrr.end_date_active is null;


    CURSOR c_salesrep_dates_first(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active),
	   max(end_date_active)
      FROM jtf_rs_salesreps
	 WHERE resource_id = l_resource_id
	   AND end_date_active is not null;


    CURSOR c_salesrep_dates_sec(
	 l_resource_id    IN  NUMBER )
    IS
	 SELECT min(start_date_active)
      FROM jtf_rs_salesreps
	 WHERE resource_id = l_resource_id
	   AND end_date_active is null;

    CURSOR c_validate_user_id(
         l_resource_id    IN  NUMBER,
         l_user_id        IN  NUMBER)
    IS
         SELECT 'Y'
      FROM jtf_rs_resource_extns
         WHERE user_id = l_user_id
         AND   resource_id <> l_resource_id;

   l_value       VARCHAR2(100);
   l_address_ret_status varchar2(10);
   l_address_found      boolean := true;

   l_return_status             VARCHAR2(2000);
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(2000);

   l_resource_rec       jtf_rs_resource_pvt.resource_rec_type;

  BEGIN

    l_resource_id                  := p_resource_id;
    l_managing_emp_id              := p_managing_emp_id;
    l_start_date_active            := trunc(p_start_date_active);
    l_end_date_active              := trunc(p_end_date_active);
    l_time_zone                    := p_time_zone;
    l_cost_per_hr                  := p_cost_per_hr;
    l_primary_language             := p_primary_language;
    l_secondary_language           := p_secondary_language;
    l_support_site_id              := p_support_site_id;
    l_ies_agent_login              := p_ies_agent_login;
    l_server_group_id              := p_server_group_id;
    l_assigned_to_group_id         := p_assigned_to_group_id;
    l_cost_center                  := p_cost_center;
    l_charge_to_cost_center        := p_charge_to_cost_center;
    l_comp_currency_code           := p_comp_currency_code;
    l_commissionable_flag          := p_commissionable_flag;
    l_hold_reason_code             := p_hold_reason_code;
    l_hold_payment                 := p_hold_payment;
    l_comp_service_team_id         := p_comp_service_team_id;
    l_user_id                      := p_user_id;
    l_object_version_num           := p_object_version_num;
    l_resource_name                := p_resource_name;
    l_source_name                  := p_source_name;
    l_source_number                := p_source_number;
    l_source_job_title             := p_source_job_title;
    l_source_email                 := p_source_email;
    l_source_phone                 := p_source_phone;
    l_source_org_id                := p_source_org_id;
    l_source_org_name              := p_source_org_name;
    l_source_address1              := p_source_address1;
    l_source_address2              := p_source_address2;
    l_source_address3              := p_source_address3;
    l_source_address4              := p_source_address4;
    l_source_city                  := p_source_city;
    l_source_postal_code           := p_source_postal_code;
    l_source_state                 := p_source_state;
    l_source_province              := p_source_province;
    l_source_county                := p_source_county;
    l_source_country               := p_source_country;
    l_source_mgr_id                := p_source_mgr_id;
    l_source_mgr_name              := p_source_mgr_name;
    l_source_business_grp_id       := p_source_business_grp_id;
    l_source_business_grp_name     := p_source_business_grp_name;
    l_source_first_name            := p_source_first_name;
    l_source_last_name             := p_source_last_name;
    l_source_middle_name           := p_source_middle_name;
    l_source_status                := p_source_status;
    l_source_office                := p_source_office;
    l_source_location              := p_source_location;
    l_source_mailstop              := p_source_mailstop;
    l_source_mobile_phone          := p_source_mobile_phone;
    l_source_pager                 := p_source_pager;
    l_address_id                   := p_address_id;
    l_source_category              := p_source_category;
    l_user_name                    := p_user_name;

    SAVEPOINT update_resource_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

--    DBMS_OUTPUT.put_line('Started Update Resource Pvt ');


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_cuhk.update_resource_pre(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
       -- p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_vuhk.update_resource_pre(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
       -- p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Pre Vertical User Hook');

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_iuhk.update_resource_pre(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    OPEN c_resource_update(l_resource_id);

    FETCH c_resource_update INTO resource_rec;


    IF c_resource_update%NOTFOUND THEN

      IF c_resource_update%ISOPEN THEN

        CLOSE c_resource_update;

      END IF;

      fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE');
	 fnd_message.set_token('P_RESOURCE_ID', l_resource_id);
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;


    END IF;



    /* Validate the Managing Employee Id if specified */

    IF l_managing_emp_id <> fnd_api.g_miss_num THEN

      jtf_resource_utl.validate_employee_resource(
        p_emp_resource_id => l_managing_emp_id,
        p_emp_resource_number => null,
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

    END IF;



    /* Validate the Input Dates */

    IF l_start_date_active <> fnd_api.g_miss_date OR
	  l_end_date_active <> fnd_api.g_miss_date THEN

    -- Code changes to fix bug 4171623. (G_MISS_DATE DOESN'T WORK PROPERLY ON JTF_RS_RESOURCE_PUB).

    -- Changing the values being passed to "validate_input_dates" procedure,
    -- from l_end_date_active to resource_rec.end_date_active (same for start date)
    -- so that it validates the correct dates which its supposed to validate.

      jtf_resource_utl.validate_input_dates(
        p_start_date_active => resource_rec.start_date_active,
        p_end_date_active => resource_rec.end_date_active,
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


    /* Validate that the resource dates cover the role related dates for the resource */

    /* First part of the validation where the role relate end date active is not null */

    OPEN c_related_role_dates_first(l_resource_id);

    FETCH c_related_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        /* Resource Start Date out of range for the role related start dates of the resource */

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_ROLE_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_end_date_active <> FND_API.G_MISS_DATE AND
           l_max_end_date > l_end_date_active AND
           l_end_date_active IS NOT NULL ) THEN

        /* Resource End Date out of range for the role related End dates of the Resource */

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_ROLE_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_related_role_dates_first%ISOPEN THEN

      CLOSE c_related_role_dates_first;

    END IF;



    /* Second part of the validation where the role relate end date active is null */

    OPEN c_related_role_dates_sec(l_resource_id);

    FETCH c_related_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_ROLE_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active <> FND_API.G_MISS_DATE AND
         l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_ROLE_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;

    /* Close the cursor */

    IF c_related_role_dates_sec%ISOPEN THEN

      CLOSE c_related_role_dates_sec;

    END IF;


    /* Validate that the resource dates cover the group member role related dates for the resource */

    /* First part of the validation where the group member role relate end date active is not null */

    OPEN c_grp_mbr_role_dates_first(l_resource_id);

    FETCH c_grp_mbr_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_GMBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_end_date_active <> FND_API.G_MISS_DATE AND
           l_max_end_date > l_end_date_active AND
           l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_GMBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_grp_mbr_role_dates_first%ISOPEN THEN

      CLOSE c_grp_mbr_role_dates_first;

    END IF;



    /* Second part of the validation where the member role relate end date active is null */

    OPEN c_grp_mbr_role_dates_sec(l_resource_id);

    FETCH c_grp_mbr_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_GMBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active <> FND_API.G_MISS_DATE AND
         l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_GMBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;

    /* Close the cursor */

    IF c_grp_mbr_role_dates_sec%ISOPEN THEN

      CLOSE c_grp_mbr_role_dates_sec;

    END IF;



    /* Validate that the resource dates cover the team member role related dates for the
	  resource, where the team member is a resource */

    /* First part of the validation where the team member role relate end date active
	  is not null */

    OPEN c_team_mbr_role_dates_first(l_resource_id);

    FETCH c_team_mbr_role_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_TMBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF ( l_end_date_active <> FND_API.G_MISS_DATE AND
           l_max_end_date > l_end_date_active AND
           l_end_date_active IS NOT NULL ) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_TMBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_team_mbr_role_dates_first%ISOPEN THEN

      CLOSE c_team_mbr_role_dates_first;

    END IF;


    /* Second part of the validation where the member role relate end date active is null */

    OPEN c_team_mbr_role_dates_sec(l_resource_id);

    FETCH c_team_mbr_role_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_TMBR_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active <> FND_API.G_MISS_DATE AND
         l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_TMBR_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_team_mbr_role_dates_sec%ISOPEN THEN

      CLOSE c_team_mbr_role_dates_sec;

    END IF;



    /* Validate that the resource dates cover the salesrep related dates for the resource */

    /* First part of the validation where the salesrep end date active is not null */

    OPEN c_salesrep_dates_first(l_resource_id);

    FETCH c_salesrep_dates_first INTO l_min_start_date, l_max_end_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        /* Resource Start Date out of range for the salesrep related start dates of the resource */

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_SRP_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

      END IF;

      IF ( l_end_date_active <> FND_API.G_MISS_DATE AND
           l_max_end_date > l_end_date_active AND
           l_end_date_active IS NOT NULL ) THEN

        /* Resource End Date out of range for the salesrep related End dates of the Resource */

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_SRP_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;


    /* Close the cursor */

    IF c_salesrep_dates_first%ISOPEN THEN

      CLOSE c_salesrep_dates_first;

    END IF;



    /* Second part of the validation where the role relate end date active
	  is null */

    OPEN c_salesrep_dates_sec(l_resource_id);

    FETCH c_salesrep_dates_sec INTO l_min_start_date;


    IF l_min_start_date IS NOT NULL THEN

      IF l_start_date_active <> FND_API.G_MISS_DATE AND
         l_min_start_date < l_start_date_active THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_SRP_START_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

      IF l_end_date_active <> FND_API.G_MISS_DATE AND
         l_end_date_active IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_RES_SRP_END_DATE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;

    /* Close the cursor */

    IF c_salesrep_dates_sec%ISOPEN THEN

      CLOSE c_salesrep_dates_sec;

    END IF;



    /* Validate the Time Zone */

    IF l_time_zone <> fnd_api.g_miss_num THEN

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

    END IF;



    /* Validate the Primary Language */

    IF l_primary_language <> fnd_api.g_miss_char THEN

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

    END IF;



    /* Validate the Secondary Language */

    IF l_secondary_language <> fnd_api.g_miss_char THEN

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

    END IF;



    /* Validate the Support Site */

    IF l_support_site_id <> fnd_api.g_miss_num THEN

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

    END IF;



    /* Validate the Server Group. */

    IF l_server_group_id <> fnd_api.g_miss_num THEN

      jtf_resource_utl.validate_server_group(
        p_server_group_id => l_server_group_id,
        p_server_group_name => null,
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

    END IF;



    /* Validate the assigned_to_group_id if specified */

    IF l_assigned_to_group_id <> fnd_api.g_miss_num THEN

      IF l_assigned_to_group_id IS NOT NULL THEN

        OPEN c_assigned_to_group_id(l_assigned_to_group_id);

        FETCH c_assigned_to_group_id INTO l_assigned_to_group_id;


        IF c_assigned_to_group_id%NOTFOUND THEN

--          dbms_output.put_line('Invalid Assigned To Group Id');

          fnd_message.set_name('JTF', 'JTF_RS_ERR_ASSIGN_TO_GRP_ID');
          fnd_message.set_token('P_ASSIGNED_TO_GROUP_ID', l_assigned_to_group_id);
          fnd_msg_pub.add;

          RAISE fnd_api.g_exc_error;


        END IF;


        /* Close the cursor */

        IF c_assigned_to_group_id%ISOPEN THEN

          CLOSE c_assigned_to_group_id;

        END IF;

      END IF;

    END IF;



    /* Validate the Comp Currency Code */

    IF l_comp_currency_code <> fnd_api.g_miss_char THEN

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

    END IF;



    /* Validate the value of the commisionable flag */

    IF l_commissionable_flag <> fnd_api.g_miss_char THEN

      IF l_commissionable_flag <> 'Y' AND l_commissionable_flag <> 'N' THEN

--	   dbms_output.put_line('Commissionable Flag should either be ''Y'' or ''N'' ');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;



    /* Validate the value of the Hold Payment flag */

    IF l_hold_payment <> fnd_api.g_miss_char THEN

      IF l_hold_payment <> 'Y' AND l_hold_payment <> 'N' THEN

--	   dbms_output.put_line('Hold Payment should either be ''Y'' or ''N'' ');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG_VALUE');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


      END IF;

    END IF;



    /* Validate the Hold Reason Code */

    IF l_hold_reason_code <> fnd_api.g_miss_char THEN

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

    END IF;


    /* Validate that the user_id should only be specified in case of
	  'EMPLOYEE', 'PARTY', 'SUPPLIER_CONTACT' categories */

    IF l_user_id <> fnd_api.g_miss_num THEN

      IF resource_rec.category NOT IN ('EMPLOYEE', 'PARTY', 'SUPPLIER_CONTACT') AND l_user_id IS NOT NULL THEN

        fnd_message.set_name('JTF', 'JTF_RS_USERID_ERROR');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;


	 END IF;

    END IF;


    IF l_user_id <> fnd_api.g_miss_num THEN

      /* Validate the User Id if specified */

      IF l_user_id IS NOT NULL THEN

        jtf_resource_utl.validate_user_id(
          p_user_id => l_user_id,
          p_category => resource_rec.category,
          p_source_id => resource_rec.source_id,
          x_return_status => x_return_status
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

	  IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

        else

        OPEN c_validate_user_id(l_resource_id,l_user_id);

        FETCH c_validate_user_id INTO l_check_flag
;


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

    IF l_comp_service_team_id <> fnd_api.g_miss_num THEN

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

    END IF;

     if(resource_rec.category IN  ('PARTNER', 'PARTY'))
     THEN
       if(p_address_id <> fnd_api.g_miss_num)
       then
         if (nvl(p_address_id, fnd_api.g_miss_num) <> nvl(resource_rec.old_address_id, fnd_api.g_miss_num))
         then
             validate_party_address(p_source_id => resource_rec.source_id,
                            p_address_id => resource_rec.address_id,
                            p_action => 'U',
                            p_found  => l_address_found,
                            p_return_status => l_address_ret_status);

          if(l_address_ret_status <> fnd_api.g_ret_sts_success)
          then
	    IF L_ADDRESS_RET_STATUS = FND_API.G_RET_STS_ERROR THEN
		 RAISE FND_API.G_EXC_ERROR;
	    ELSIF L_ADDRESS_RET_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

          end if;

         if not(l_address_found)
         then
            fnd_message.set_name('JTF', 'JTF_RS_NOT_PRIMARY_ADDR');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;

         end if;
        end if; -- end of nvl check
      end if; -- end of f_miss_num check
     END IF;

    /* Call the lock row procedure to ensure that the object version number
	  is still valid. */

    BEGIN

      jtf_rs_resource_extns_pkg.lock_row(
        x_resource_id => l_resource_id,
	   x_object_version_number => p_object_version_num
      );

    EXCEPTION

	 WHEN OTHERS THEN

--	   dbms_output.put_line('Error in Locking the Row');


	   fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	   fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;


    END;


    /* Make a call to the Resource Audit API */

    jtf_rs_resource_extns_aud_pvt.update_resource
    (P_API_VERSION => 1,
     P_INIT_MSG_LIST => fnd_api.g_false,
     P_COMMIT => fnd_api.g_false,
     P_RESOURCE_ID => l_resource_id,
     P_RESOURCE_NUMBER => resource_rec.resource_number,
     P_CATEGORY => resource_rec.category,
     P_SOURCE_ID => resource_rec.source_id,
     P_ADDRESS_ID => resource_rec.address_id,
     P_CONTACT_ID => resource_rec.contact_id,
     P_MANAGING_EMP_ID => resource_rec.managing_emp_id,
     P_START_DATE_ACTIVE => resource_rec.start_date_active,
     P_END_DATE_ACTIVE => resource_rec.end_date_active,
     P_TIME_ZONE => resource_rec.time_zone,
     P_COST_PER_HR => resource_rec.cost_per_hr,
     P_PRIMARY_LANGUAGE => resource_rec.primary_language,
     P_SECONDARY_LANGUAGE => resource_rec.secondary_language,
     P_SUPPORT_SITE_ID => resource_rec.support_site_id,
     P_IES_AGENT_LOGIN => resource_rec.ies_agent_login,
     P_SERVER_GROUP_ID => resource_rec.server_group_id,
     P_ASSIGNED_TO_GROUP_ID => resource_rec.assigned_to_group_id,
     P_COST_CENTER => resource_rec.cost_center,
     P_CHARGE_TO_COST_CENTER => resource_rec.charge_to_cost_center,
     P_COMP_CURRENCY_CODE => resource_rec.comp_currency_code,
     P_COMMISSIONABLE_FLAG => resource_rec.commissionable_flag,
     P_HOLD_REASON_CODE => resource_rec.hold_reason_code,
     P_HOLD_PAYMENT => resource_rec.hold_payment,
     P_COMP_SERVICE_TEAM_ID => resource_rec.comp_service_team_id,
     P_USER_ID => resource_rec.user_id,
     P_TRANSACTION_NUMBER => resource_rec.transaction_number,
    -- P_LOCATION => resource_rec.location,
      P_OBJECT_VERSION_NUMBER => p_object_version_num + 1,
      P_RESOURCE_NAME => resource_rec.RESOURCE_NAME ,
      P_SOURCE_NAME => resource_rec.SOURCE_NAME ,
      P_SOURCE_NUMBER => resource_rec.SOURCE_NUMBER ,
      P_SOURCE_JOB_TITLE  => resource_rec.SOURCE_JOB_TITLE  ,
      P_SOURCE_EMAIL  => resource_rec.SOURCE_EMAIL  ,
      P_SOURCE_PHONE  => resource_rec.SOURCE_PHONE  ,
      P_SOURCE_ORG_ID => resource_rec.SOURCE_ORG_ID ,
      P_SOURCE_ORG_NAME => resource_rec.SOURCE_ORG_NAME ,
      P_SOURCE_ADDRESS1 => resource_rec.SOURCE_ADDRESS1 ,
      P_SOURCE_ADDRESS2 => resource_rec.SOURCE_ADDRESS2 ,
      P_SOURCE_ADDRESS3 => resource_rec.SOURCE_ADDRESS3 ,
      P_SOURCE_ADDRESS4 => resource_rec.SOURCE_ADDRESS4 ,
      P_SOURCE_CITY => resource_rec.SOURCE_CITY ,
      P_SOURCE_POSTAL_CODE  => resource_rec.SOURCE_POSTAL_CODE  ,
      P_SOURCE_STATE  => resource_rec.SOURCE_STATE  ,
      P_SOURCE_PROVINCE => resource_rec.SOURCE_PROVINCE ,
      P_SOURCE_COUNTY => resource_rec.SOURCE_COUNTY ,
      P_SOURCE_COUNTRY  => resource_rec.SOURCE_COUNTRY  ,
      P_SOURCE_MGR_ID => resource_rec.SOURCE_MGR_ID ,
      P_SOURCE_MGR_NAME => resource_rec.SOURCE_MGR_NAME ,
      P_SOURCE_BUSINESS_GRP_ID  => resource_rec.SOURCE_BUSINESS_GRP_ID  ,
      P_SOURCE_BUSINESS_GRP_NAME => resource_rec.SOURCE_BUSINESS_GRP_NAME ,
      P_SOURCE_FIRST_NAME => resource_rec.SOURCE_FIRST_NAME ,
      P_SOURCE_MIDDLE_NAME => resource_rec.SOURCE_MIDDLE_NAME ,
      P_SOURCE_LAST_NAME => resource_rec.SOURCE_LAST_NAME ,
      P_SOURCE_CATEGORY => resource_rec.SOURCE_CATEGORY ,
      P_SOURCE_STATUS => resource_rec.SOURCE_STATUS ,
      P_SOURCE_OFFICE => resource_rec.SOURCE_OFFICE ,
      P_SOURCE_LOCATION => resource_rec.SOURCE_LOCATION ,
      P_SOURCE_MAILSTOP => resource_rec.SOURCE_MAILSTOP ,
      X_RETURN_STATUS => x_return_status,
      X_MSG_COUNT => x_msg_count,
      X_MSG_DATA => x_msg_data,
      P_SOURCE_MOBILE_PHONE => resource_rec.SOURCE_MOBILE_PHONE ,
      P_SOURCE_PAGER => resource_rec.SOURCE_PAGER,
      P_USER_NAME => resource_rec.USER_NAME
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	 dbms_output.put_line('Failed status from call to audit procedure');

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

/* Calling publish API to raise update resource event. */
/* added by baianand on 11/04/2002 */

    begin

       l_resource_rec.resource_id                := l_resource_id;
       l_resource_rec.category                   := resource_rec.category;
       l_resource_rec.user_id                    := resource_rec.user_id;
       l_resource_rec.resource_name              := resource_rec.resource_name;
       l_resource_rec.start_date_active          := resource_rec.start_date_active;
       l_resource_rec.end_date_active            := resource_rec.end_date_active;
       l_resource_rec.time_zone                  := resource_rec.time_zone;
       l_resource_rec.cost_per_hr                := resource_rec.cost_per_hr;
       l_resource_rec.primary_language           := resource_rec.primary_language;
       l_resource_rec.secondary_language         := resource_rec.secondary_language;
       l_resource_rec.ies_agent_login            := resource_rec.ies_agent_login;
       l_resource_rec.server_group_id            := resource_rec.server_group_id;
       l_resource_rec.assigned_to_group_id       := resource_rec.assigned_to_group_id;
       l_resource_rec.cost_center                := resource_rec.cost_center;
       l_resource_rec.charge_to_cost_center      := resource_rec.charge_to_cost_center;
       l_resource_rec.comp_currency_code         := resource_rec.comp_currency_code;
       l_resource_rec.commissionable_flag        := resource_rec.commissionable_flag;
       l_resource_rec.hold_reason_code           := resource_rec.hold_reason_code;
       l_resource_rec.hold_payment               := resource_rec.hold_payment;
       l_resource_rec.comp_service_team_id       := resource_rec.comp_service_team_id;
       l_resource_rec.support_site_id            := resource_rec.support_site_id;

       jtf_rs_wf_events_pub.update_resource
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_resource_rec              => l_resource_rec
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

    EXCEPTION when others then
       null;
    end;

/* End of publish API call */


  /* Calling work API for insert/update record into wf_local tables. */
  /* added by baianand on 08/15/2002 */

      begin
         jtf_rs_wf_integration_pub.update_resource
                (p_api_version               => 1.0
                ,p_init_msg_list             => fnd_api.g_false
                ,p_commit                    => fnd_api.g_false
                ,p_resource_id               => l_resource_id
                ,p_resource_name             => resource_rec.resource_name
                ,p_user_id                   => resource_rec.user_id
                ,p_email_address             => resource_rec.source_email
                ,p_start_date_active         => resource_rec.start_date_active
                ,p_end_date_active           => resource_rec.end_date_active
                ,x_return_status             => l_return_status
                ,x_msg_count                 => l_msg_count
                ,x_msg_data                  => l_msg_data);

      EXCEPTION when others then
         null;
      end;

  /* End of work API call */

    BEGIN

      /* Increment the object version number */

	 l_object_version_num := p_object_version_num + 1;


      /* Update the row into the table by calling the table handler. */

      jtf_rs_resource_extns_pkg.update_row(
        x_resource_id 	 	  => l_resource_id,
        x_category 	 	  => resource_rec.category,
        x_resource_number 	  => resource_rec.resource_number,
        x_source_id 	 	  => resource_rec.source_id,
        x_address_id 	 	  => resource_rec.address_id,
        x_contact_id 	 	  => resource_rec.contact_id,
        x_managing_employee_id 	  => resource_rec.managing_emp_id,
        x_start_date_active 	  => resource_rec.start_date_active,
        x_end_date_active 	  => resource_rec.end_date_active,
        x_time_zone 	 	  => resource_rec.time_zone,
        x_cost_per_hr 	  	  => resource_rec.cost_per_hr,
        x_primary_language 	  => resource_rec.primary_language,
        x_secondary_language 	  => resource_rec.secondary_language,
        x_support_site_id 	  => resource_rec.support_site_id,
        x_ies_agent_login 	  => resource_rec.ies_agent_login,
        x_server_group_id 	  => resource_rec.server_group_id,
        x_assigned_to_group_id 	  => resource_rec.assigned_to_group_id,
        x_cost_center 	 	  => resource_rec.cost_center,
        x_charge_to_cost_center   => resource_rec.charge_to_cost_center,
        x_compensation_currency_code => resource_rec.comp_currency_code,
        x_commissionable_flag 	  => resource_rec.commissionable_flag,
        x_hold_reason_code 	  => resource_rec.hold_reason_code,
        x_hold_payment 	 	  => resource_rec.hold_payment,
        x_comp_service_team_id 	  => resource_rec.comp_service_team_id,
        x_user_id 	 	  => resource_rec.user_id,
        --x_location 	 	  => resource_rec.location,
        x_transaction_number 	  => resource_rec.transaction_number,
	x_object_version_number   => l_object_version_num,
        x_attribute1 	 	  => resource_rec.attribute1,
        x_attribute2 	 	  => resource_rec.attribute2,
        x_attribute3 	 	  => resource_rec.attribute3,
        x_attribute4 	 	  => resource_rec.attribute4,
        x_attribute5 	 	  => resource_rec.attribute5,
        x_attribute6 	 	  => resource_rec.attribute6,
        x_attribute7 	 	  => resource_rec.attribute7,
        x_attribute8 	 	  => resource_rec.attribute8,
        x_attribute9 	 	  => resource_rec.attribute9,
        x_attribute10 	 	  => resource_rec.attribute10,
        x_attribute11 	 	  => resource_rec.attribute11,
        x_attribute12 	 	  => resource_rec.attribute12,
        x_attribute13 	 	  => resource_rec.attribute13,
        x_attribute14 	 	  => resource_rec.attribute14,
        x_attribute15 	 	  => resource_rec.attribute15,
        x_attribute_category 	  => resource_rec.attribute_category,
        x_last_update_date 	  => SYSDATE,
        x_last_updated_by 	  => jtf_resource_utl.updated_by,
        x_last_update_login 	  => jtf_resource_utl.login_id,
        x_resource_name           => resource_rec.resource_name,
        x_source_name             => resource_rec.source_name,
        x_source_number           => resource_rec.source_number,
        x_source_job_title        => resource_rec.source_job_title,
        x_source_email            => resource_rec.source_email,
        x_source_phone            => resource_rec.source_phone,
        x_source_org_id           => resource_rec.source_org_id,
        x_source_org_name         => resource_rec.source_org_name,
        x_source_address1         => resource_rec.source_address1,
        x_source_address2         => resource_rec.source_address2,
        x_source_address3         => resource_rec.source_address3,
        x_source_address4         => resource_rec.source_address4,
        x_source_city             => resource_rec.source_city,
        x_source_postal_code      => resource_rec.source_postal_code,
        x_source_state            => resource_rec.source_state,
        x_source_province         => resource_rec.source_province,
        x_source_county           => resource_rec.source_county,
        x_source_country          => resource_rec.source_country,
        x_source_mgr_id           => resource_rec.source_mgr_id,
        x_source_mgr_name         => resource_rec.source_mgr_name,
        x_source_business_grp_id  => resource_rec.source_business_grp_id,
        x_source_business_grp_name=> resource_rec.source_business_grp_name,
        x_SOURCE_FIRST_NAME       => resource_rec.SOURCE_FIRST_NAME ,
        x_SOURCE_MIDDLE_NAME      => resource_rec.SOURCE_MIDDLE_NAME ,
        x_SOURCE_LAST_NAME        => resource_rec.SOURCE_LAST_NAME ,
        x_SOURCE_CATEGORY         => resource_rec.SOURCE_CATEGORY ,
        x_SOURCE_STATUS           => resource_rec.SOURCE_STATUS ,
        x_SOURCE_OFFICE           => resource_rec.SOURCE_OFFICE ,
        x_SOURCE_LOCATION         => resource_rec.SOURCE_LOCATION ,
        x_SOURCE_MAILSTOP         => resource_rec.SOURCE_MAILSTOP ,
        x_USER_NAME               => resource_rec.USER_NAME ,
        x_SOURCE_JOB_ID           => resource_rec.SOURCE_JOB_ID,
        x_PARTY_ID                => resource_rec.PERSON_PARTY_ID,
        x_SOURCE_MOBILE_PHONE     => resource_rec.SOURCE_MOBILE_PHONE ,
        x_SOURCE_PAGER            => resource_rec.SOURCE_PAGER
      );



      /* Return the new value of the object version number */

      p_object_version_num := l_object_version_num;



    EXCEPTION

	 WHEN NO_DATA_FOUND THEN

--	   dbms_output.put_line('Error in Table Handler');

        IF c_resource_update%ISOPEN THEN

          CLOSE c_resource_update;

        END IF;

	   x_return_status := fnd_api.g_ret_sts_unexp_error;

	   fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
	   fnd_msg_pub.add;

           RAISE fnd_api.g_exc_error;


    END;

--    dbms_output.put_line('Resource Successfully Updated');


    /* Close the cursors */

    IF c_resource_update%ISOPEN THEN

      CLOSE c_resource_update;

    END IF;


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_cuhk.update_resource_post(
	p_resource_id          => l_resource_id,
        p_managing_emp_id      => l_managing_emp_id,
        p_start_date_active    => l_start_date_active,
        p_end_date_active      => l_end_date_active,
        p_time_zone            => l_time_zone,
        p_cost_per_hr          => l_cost_per_hr,
        p_primary_language     => l_primary_language,
        p_secondary_language   => l_secondary_language,
        p_support_site_id      => l_support_site_id,
        p_ies_agent_login      => l_ies_agent_login,
        p_server_group_id      => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center          => l_cost_center,
        p_charge_to_cost_center=> l_charge_to_cost_center,
        p_comp_currency_code   => l_comp_currency_code,
        p_commissionable_flag  => l_commissionable_flag,
        p_hold_reason_code     => l_hold_reason_code,
        p_hold_payment         => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id              => l_user_id,
        --p_location           => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

      END IF;

    END IF;
    END IF;


    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_vuhk.update_resource_post(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Vertical User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_iuhk.update_resource_post(
	   p_resource_id => l_resource_id,
        p_managing_emp_id => l_managing_emp_id,
        p_start_date_active => l_start_date_active,
        p_end_date_active => l_end_date_active,
        p_time_zone => l_time_zone,
        p_cost_per_hr => l_cost_per_hr,
        p_primary_language => l_primary_language,
        p_secondary_language => l_secondary_language,
        p_support_site_id => l_support_site_id,
        p_ies_agent_login => l_ies_agent_login,
        p_server_group_id => l_server_group_id,
        p_assigned_to_group_id => l_assigned_to_group_id,
        p_cost_center => l_cost_center,
        p_charge_to_cost_center => l_charge_to_cost_center,
        p_comp_currency_code => l_comp_currency_code,
        p_commissionable_flag => l_commissionable_flag,
        p_hold_reason_code => l_hold_reason_code,
        p_hold_payment => l_hold_payment,
        p_comp_service_team_id => l_comp_service_team_id,
        p_user_id => l_user_id,
        --p_location => l_location,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	   dbms_output.put_line('Returned Error status from the Post Customer User Hook');


	   fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	   fnd_msg_pub.add;

	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'UPDATE_RESOURCE',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_cuhk.ok_to_generate_msg(
	       p_resource_id => l_resource_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'resource_id', l_resource_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'RES',
		p_action_code => 'U',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');


	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

	     IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	     ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;


        END IF;

      END IF;

    END IF;
    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION


    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_resource_pvt;
-- The below lines removed as a part of fixing GSCC errors in R12 for jtfrspub.pls
--      IF NOT(jtf_resource_utl.check_access(l_value))
--      THEN
--            IF(l_value = 'XMLGEN')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_XMLGEN_ERR');
--		 FND_MSG_PUB.add;
--            ELSIF(l_value = 'JTF_USR_HKS')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_JUHK_ERR');
--		 FND_MSG_PUB.add;
--            END IF;
--      ELSE
	fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	fnd_message.set_token('P_SQLCODE',SQLCODE);
	fnd_message.set_token('P_SQLERRM',SQLERRM);
	fnd_message.set_token('P_API_NAME', l_api_name);
	FND_MSG_PUB.add;
--      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);


  END update_resource;


  /* Procedure to delete  the resource of category = TBH */

  PROCEDURE DELETE_RESOURCE(
    P_API_VERSION	IN  NUMBER,
    P_INIT_MSG_LIST	IN  VARCHAR2,
    P_COMMIT		IN  VARCHAR2,
    P_RESOURCE_ID       IN  NUMBER,
    X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT         OUT NOCOPY NUMBER,
    X_MSG_DATA          OUT NOCOPY VARCHAR2 )
  IS
  CURSOR res_cur(L_RESOURCE_ID     NUMBER)
      IS
  SELECT category
    FROM jtf_rs_resource_extns
   WHERE resource_id = l_resource_id;

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE';
    l_category            JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE ;
  /* Moved the initial assignment of below variable to inside begin */
    L_RESOURCE_ID         JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
    l_bind_data_id                 NUMBER;
    l_value                varchar2(100);

    l_return_status             VARCHAR2(2000);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

  BEGIN

    L_RESOURCE_ID   := p_resource_id;

   SAVEPOINT delete_resource_pvt;

    x_return_status := fnd_api.g_ret_sts_success;


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    IF fnd_api.to_boolean(p_init_msg_list) THEN

      fnd_msg_pub.initialize;

    END IF;


    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'B',
	 'C')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'B',
	 'C')
    THEN

      jtf_rs_resource_cuhk.delete_resource_pre(
	   p_resource_id => l_resource_id,
       	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
	 fnd_msg_pub.add;
	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;

    END IF;
    END IF;


    /* Pre Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'B',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'B',
	 'V')
    THEN

      jtf_rs_resource_vuhk.delete_resource_pre(
	   p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
	 fnd_msg_pub.add;
	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'B',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'B',
	 'I')
    THEN

      jtf_rs_resource_iuhk.delete_resource_pre(
	   p_resource_id => l_resource_id,
      	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
	fnd_msg_pub.add;

	IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


      END IF;

    END IF;
    END IF;


    OPEN res_cur(l_resource_id);
    FETCH res_cur INTO l_category;
    CLOSE res_cur;

    --allow delete only for category of type TBH
    IF (l_category = 'TBH')
    THEN
         /* Make a call to the Resource Audit API */

         jtf_rs_resource_extns_aud_pvt.delete_resource
                    (P_API_VERSION => 1,
                     P_INIT_MSG_LIST => fnd_api.g_false,
                     P_COMMIT => fnd_api.g_false,
                     P_RESOURCE_ID => l_resource_id,
                     X_RETURN_STATUS => x_return_status,
                     X_MSG_COUNT => x_msg_count,
                     X_MSG_DATA => x_msg_data
                    );

         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


         END IF;

       --delete the row from the table
          jtf_rs_resource_extns_pkg.delete_row(
                  x_resource_id => l_resource_id );


    END IF;  --end of category check for TBH


    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'A',
	 'C')
    THEN

      jtf_rs_resource_cuhk.delete_resource_post(
	   p_resource_id => l_resource_id,
       	   x_return_status => x_return_status);
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
	  fnd_msg_pub.add;
	  IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

      END IF;

    END IF;


    /* Post Call to the Vertical Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'A',
	 'V')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'A',
	 'V')
    THEN

      jtf_rs_resource_vuhk.delete_resource_post(
	   p_resource_id => l_resource_id,
       	   x_return_status => x_return_status);
        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
	  fnd_msg_pub.add;
	  IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

      END IF;
    END IF;
    END IF;


    /* Post Call to the Internal Type User Hook */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'A',
	 'I')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'A',
	 'I')
    THEN

      jtf_rs_resource_iuhk.delete_resource_post(
	   p_resource_id => l_resource_id,
	   x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
	  fnd_msg_pub.add;
	  IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
	  ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

      END IF;

    END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_resource_utl.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'M',
	 'M')
    THEN
    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_RESOURCE_PVT',
	 'DELETE_RESOURCE',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_resource_cuhk.ok_to_generate_msg(
	       p_resource_id => l_resource_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'resource_id', l_resource_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'RS',
		p_bus_obj_code => 'RES',
		p_action_code => 'D',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

--	     dbms_output.put_line('Returned Error status from the Message Generation API');


	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

	     IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	     ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;


        END IF;

      END IF;

    END IF;
    END IF;


    IF fnd_api.to_boolean(p_commit) THEN

	 COMMIT WORK;

    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    if (l_category = 'TBH') then

    /* Calling publish API to raise create resource event. */
    /* added by baianand on 11/04/2002 */

       begin
          jtf_rs_wf_events_pub.delete_resource
                 (p_api_version               => 1.0
                 ,p_init_msg_list             => fnd_api.g_false
                 ,p_commit                    => fnd_api.g_false
                 ,p_resource_id               => l_resource_id
                 ,x_return_status             => l_return_status
                 ,x_msg_count                 => l_msg_count
                 ,x_msg_data                  => l_msg_data);

       EXCEPTION when others then
          null;
       end;

    /* End of publish API call */

    /* Calling work API for delete record from wf_local tables. */
    /* added by baianand on 08/13/2002 */

       begin
          jtf_rs_wf_integration_pub.delete_resource
              (p_api_version               => 1.0
              ,p_init_msg_list             => fnd_api.g_false
              ,p_commit                    => fnd_api.g_false
              ,p_resource_id               => l_resource_id
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data);

       EXCEPTION when others then
          null;
       end;
    end if;

    /* End of work API call */

  EXCEPTION


    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO delete_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_resource_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_resource_pvt;
-- The below lines removed as a part of fixing GSCC errors in R12 for jtfrspub.pls
--           IF NOT(jtf_resource_utl.check_access(l_value))
--      THEN
--            IF(l_value = 'XMLGEN')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_XMLGEN_ERR');
--		 FND_MSG_PUB.add;
--            ELSIF(l_value = 'JTF_USR_HKS')
--            THEN
--		 fnd_message.set_name ('JTF', 'JTF_RS_JUHK_ERR');
--		 FND_MSG_PUB.add;
--            END IF;
--      ELSE
	 fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
	 fnd_message.set_token('P_SQLCODE',SQLCODE);
	 fnd_message.set_token('P_SQLERRM',SQLERRM);
	 fnd_message.set_token('P_API_NAME', l_api_name);
	 FND_MSG_PUB.add;
--      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END delete_resource;

END jtf_rs_resource_pvt;

/
