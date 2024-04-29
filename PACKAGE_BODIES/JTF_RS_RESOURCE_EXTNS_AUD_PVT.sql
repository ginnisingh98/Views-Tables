--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_EXTNS_AUD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_EXTNS_AUD_PVT" AS
  /* $Header: jtfrsarb.pls 120.0 2005/05/11 08:19:11 appldev ship $ */
-- API Name	: JTF_RESOURCE_EXTNS_AUD_PVT
-- Type		: Private
-- Purpose	: Inserts IN  the JTF_RESOURCE_EXTN_AUD
-- Modification History
-- DATE		 NAME	       PURPOSE
-- 20 Jan 2000    S Choudhury   Created
-- Notes:
--

    g_pkg_name varchar2(30)	 := 'JTF_RESOURCE_EXTN_AUD_PVT';
   /*FOR INSERT  */
   PROCEDURE   INSERT_RESOURCE(
	P_API_VERSION		   IN	NUMBER,
	P_INIT_MSG_LIST		   IN	VARCHAR2,
	P_COMMIT	           IN	VARCHAR2,
        P_RESOURCE_ID              IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
        P_RESOURCE_NUMBER          IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
        P_CATEGORY                 IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
        P_SOURCE_ID                IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
        P_ADDRESS_ID               IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
        P_CONTACT_ID               IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE,
        P_MANAGING_EMP_ID          IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE,
        P_START_DATE_ACTIVE        IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
        P_END_DATE_ACTIVE          IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
        P_TIME_ZONE                IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
        P_COST_PER_HR              IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
        P_PRIMARY_LANGUAGE         IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
        P_SECONDARY_LANGUAGE       IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
        P_SUPPORT_SITE_ID          IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE,
        P_IES_AGENT_LOGIN          IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
        P_SERVER_GROUP_ID          IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
        P_ASSIGNED_TO_GROUP_ID     IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
        P_COST_CENTER              IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
        P_CHARGE_TO_COST_CENTER    IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
        P_COMP_CURRENCY_CODE       IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
        P_COMMISSIONABLE_FLAG      IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
        P_HOLD_REASON_CODE         IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
        P_HOLD_PAYMENT             IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
        P_COMP_SERVICE_TEAM_ID     IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
        --P_LOCATION                 IN   MDSYS.SDO_GEOMETRY,
        P_TRANSACTION_NUMBER       IN   NUMBER,
        P_USER_ID                  IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
        P_OBJECT_VERSION_NUMBER    IN   NUMBER,
        X_RETURN_STATUS            OUT NOCOPY  VARCHAR2,
        X_MSG_COUNT                OUT NOCOPY  NUMBER,
        X_MSG_DATA                 OUT NOCOPY  VARCHAR2  )
    IS
    l_resource_extn_aud_id jtf_rs_resource_extn_aud.resource_audit_id%type;
    l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_RESOURCE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number := 1;
    l_login_id  Number := 1;


    BEGIN

        --Standard Start of API SAVEPOINT
	SAVEPOINT RESOURCE_EXTN_AUDIT;

        x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


      select jtf_rs_resource_extn_aud_s.nextval
     into l_resource_extn_aud_id
     from dual;

    /* CALL TABLE HANDLER */

   JTF_RS_RESOURCE_EXTN_AUD_PKG.INSERT_ROW (
                        X_ROWID                        => l_row_id,
                        x_resource_audit_id            =>  l_resource_extn_aud_id,
                        x_resource_id                  =>  p_resource_id,
                        x_new_category                 =>  p_category,
                        x_old_category                 =>  NULL,
                        x_new_resource_number          =>  P_resource_number  ,
                        x_old_resource_number          =>  NULL,
                        x_new_source_id                => p_source_id,
                        x_old_source_id                => null,
                        x_new_address_id               => p_address_id,
                        x_old_address_id               => null,
                        x_new_contact_id               => p_contact_id,
                        x_old_contact_id               => null,
                        x_new_managing_employee_id     => p_managing_emp_id,
                        x_old_managing_employee_id     => null,
                        x_new_start_date_active        => p_start_date_active,
                        x_old_start_date_active        => null,
                        x_new_end_date_active        => p_end_date_active,
                        x_old_end_date_active        => null,
                        x_new_time_zone                => p_time_zone,
                        x_old_time_zone                => null,
                        x_new_cost_per_hr              => p_cost_per_hr,
                        x_old_cost_per_hr              => null,
                        x_new_primary_language         =>  p_primary_language,
                        x_old_primary_language         => NULL,
                        x_new_secondary_language       => p_secondary_language,
                        x_old_secondary_language       => NULL,
                        x_new_support_site_id          => p_support_site_id,
                        x_old_support_site_id          => NULL,
                        x_new_ies_agent_login          => p_ies_agent_login,
                        x_old_ies_agent_login          => null,
                        x_new_server_group_id          => p_server_group_id,
                        x_old_server_group_id          => null,
                        x_new_assigned_to_group_id     => p_assigned_to_group_id,
                        x_old_assigned_to_group_id     => null,
                        x_new_cost_center              => p_cost_center,
                        x_old_cost_center              => null,
                        x_new_charge_to_cost_center    => p_charge_to_cost_center,
                        x_old_charge_to_cost_center    => null,
                        x_new_compensation_currency_co => p_comp_currency_code,
                        x_old_compensation_currency_co => null,
                        x_new_commissionable_flag      => p_commissionable_flag,
                        x_old_commissionable_flag      => null,
                        x_new_hold_reason_code         => p_hold_reason_code,
                        x_old_hold_reason_code         => null,
                        x_new_hold_payment             => p_hold_payment,
                        x_old_hold_payment             => null,
                        x_new_comp_service_team_id     => p_comp_service_team_id,
                        x_old_comp_service_team_id     => null,
                        x_new_transaction_number       => p_transaction_number,
                        x_old_transaction_number       => null,
                        x_new_object_version_number    => p_object_version_number,
                        x_old_object_version_number    => null,
                        x_new_user_id                  => p_user_id,
                        x_old_user_id                  => null,
                        --x_old_location                 => null,
                       -- x_new_location                 => p_location,
                        X_CREATION_DATE                => l_date,
                        X_CREATED_BY                   => l_user_id,
                        X_LAST_UPDATE_DATE             => l_date,
                        X_LAST_UPDATED_BY              => l_user_id,
                        X_LAST_UPDATE_LOGIN            => l_login_id
                        );




  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


   END INSERT_RESOURCE;


   /*INSERT for Resource Synchronization */
   PROCEDURE   INSERT_RESOURCE(
	P_API_VERSION		   IN	NUMBER,
	P_INIT_MSG_LIST		   IN	VARCHAR2,
	P_COMMIT	           IN	VARCHAR2,
        P_RESOURCE_ID              IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
        P_RESOURCE_NUMBER          IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
        P_CATEGORY                 IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
        P_SOURCE_ID                IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
        P_ADDRESS_ID               IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
        P_CONTACT_ID               IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE,
        P_MANAGING_EMP_ID          IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE,
        P_START_DATE_ACTIVE        IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
        P_END_DATE_ACTIVE          IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
        P_TIME_ZONE                IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
        P_COST_PER_HR              IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
        P_PRIMARY_LANGUAGE         IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
        P_SECONDARY_LANGUAGE       IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
        P_SUPPORT_SITE_ID          IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE,
        P_IES_AGENT_LOGIN          IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
        P_SERVER_GROUP_ID          IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
        P_ASSIGNED_TO_GROUP_ID     IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
        P_COST_CENTER              IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
        P_CHARGE_TO_COST_CENTER    IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
        P_COMP_CURRENCY_CODE       IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
        P_COMMISSIONABLE_FLAG      IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
        P_HOLD_REASON_CODE         IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
        P_HOLD_PAYMENT             IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
        P_COMP_SERVICE_TEAM_ID     IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
        --P_LOCATION                 IN   MDSYS.SDO_GEOMETRY,
        P_TRANSACTION_NUMBER       IN   NUMBER,
        P_USER_ID                  IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
        P_OBJECT_VERSION_NUMBER    IN   NUMBER,
        P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE,
        P_SOURCE_NAME             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
        P_SOURCE_NUMBER           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE,
        P_SOURCE_JOB_TITLE        IN   JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_TITLE%TYPE,
        P_SOURCE_EMAIL            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE,
        P_SOURCE_PHONE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PHONE%TYPE,
        P_SOURCE_ORG_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_ID%TYPE,
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
        P_SOURCE_FIRST_NAME        IN  JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE,
        P_SOURCE_LAST_NAME         IN  JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE,
        P_SOURCE_MIDDLE_NAME       IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE,
        P_SOURCE_CATEGORY          IN  JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE,
        P_SOURCE_STATUS            IN  JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE,
        P_SOURCE_OFFICE            IN  JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE,
        P_SOURCE_LOCATION          IN  JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE,
        P_SOURCE_MAILSTOP          IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE,
        P_USER_NAME                IN  JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE,
        P_PARTY_ID                 IN  JTF_RS_RESOURCE_EXTNS.PERSON_PARTY_ID%TYPE,
        P_SOURCE_JOB_ID            IN  JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_ID%TYPE,
        X_RETURN_STATUS            OUT NOCOPY  VARCHAR2,
        X_MSG_COUNT                OUT NOCOPY  NUMBER,
        X_MSG_DATA                 OUT NOCOPY  VARCHAR2,
        P_SOURCE_MOBILE_PHONE      IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE,
        P_SOURCE_PAGER             IN  JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE)
    IS
    l_resource_extn_aud_id jtf_rs_resource_extn_aud.resource_audit_id%type;
    l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_RESOURCE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number := 1;
    l_login_id  Number := 1;


    BEGIN

        --Standard Start of API SAVEPOINT
	SAVEPOINT RESOURCE_EXTN_AUDIT;

        x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


      select jtf_rs_resource_extn_aud_s.nextval
     into l_resource_extn_aud_id
     from dual;

    /* CALL TABLE HANDLER */

   JTF_RS_RESOURCE_EXTN_AUD_PKG.INSERT_ROW (
                        X_ROWID                        => l_row_id,
                        x_resource_audit_id            =>  l_resource_extn_aud_id,
                        x_resource_id                  =>  p_resource_id,
                        x_new_category                 =>  p_category,
                        x_old_category                 =>  NULL,
                        x_new_resource_number          =>  P_resource_number  ,
                        x_old_resource_number          =>  NULL,
                        x_new_source_id                => p_source_id,
                        x_old_source_id                => null,
                        x_new_address_id               => p_address_id,
                        x_old_address_id               => null,
                        x_new_contact_id               => p_contact_id,
                        x_old_contact_id               => null,
                        x_new_managing_employee_id     => p_managing_emp_id,
                        x_old_managing_employee_id     => null,
                        x_new_start_date_active        => p_start_date_active,
                        x_old_start_date_active        => null,
                        x_new_end_date_active        => p_end_date_active,
                        x_old_end_date_active        => null,
                        x_new_time_zone                => p_time_zone,
                        x_old_time_zone                => null,
                        x_new_cost_per_hr              => p_cost_per_hr,
                        x_old_cost_per_hr              => null,
                        x_new_primary_language         =>  p_primary_language,
                        x_old_primary_language         => NULL,
                        x_new_secondary_language       => p_secondary_language,
                        x_old_secondary_language       => NULL,
                        x_new_support_site_id          => p_support_site_id,
                        x_old_support_site_id          => NULL,
                        x_new_ies_agent_login          => p_ies_agent_login,
                        x_old_ies_agent_login          => null,
                        x_new_server_group_id          => p_server_group_id,
                        x_old_server_group_id          => null,
                        x_new_assigned_to_group_id     => p_assigned_to_group_id,
                        x_old_assigned_to_group_id     => null,
                        x_new_cost_center              => p_cost_center,
                        x_old_cost_center              => null,
                        x_new_charge_to_cost_center    => p_charge_to_cost_center,
                        x_old_charge_to_cost_center    => null,
                        x_new_compensation_currency_co => p_comp_currency_code,
                        x_old_compensation_currency_co => null,
                        x_new_commissionable_flag      => p_commissionable_flag,
                        x_old_commissionable_flag      => null,
                        x_new_hold_reason_code         => p_hold_reason_code,
                        x_old_hold_reason_code         => null,
                        x_new_hold_payment             => p_hold_payment,
                        x_old_hold_payment             => null,
                        x_new_comp_service_team_id     => p_comp_service_team_id,
                        x_old_comp_service_team_id     => null,
                        x_new_transaction_number       => p_transaction_number,
                        x_old_transaction_number       => null,
                        x_new_object_version_number    => p_object_version_number,
                        x_old_object_version_number    => null,
                        x_new_user_id                  => p_user_id,
                        x_old_user_id                  => null,
                        --x_new_location               => p_location,
                        --x_old_location               => null,
 			X_NEW_RESOURCE_NAME            => p_resource_name,
 			X_OLD_RESOURCE_NAME            => null,
 			X_NEW_SOURCE_NAME              => p_source_name,
 			X_OLD_SOURCE_NAME              => null,
 			X_NEW_SOURCE_NUMBER            => p_source_number,
 			X_OLD_SOURCE_NUMBER            => null,
 			X_NEW_SOURCE_JOB_TITLE         => p_source_job_title,
 			X_OLD_SOURCE_JOB_TITLE         => null,
 			X_NEW_SOURCE_EMAIL             => p_source_email,
 			X_OLD_SOURCE_EMAIL             => null,
 			X_NEW_SOURCE_PHONE             => p_source_phone,
 			X_OLD_SOURCE_PHONE             => null,
 			X_NEW_SOURCE_ORG_ID            => p_source_org_id,
 			X_OLD_SOURCE_ORG_ID            => null,
			X_NEW_SOURCE_ORG_NAME          => p_source_org_name,
 			X_OLD_SOURCE_ORG_NAME          => null,
 			X_NEW_SOURCE_ADDRESS1          => p_source_address1,
 			X_OLD_SOURCE_ADDRESS1          => null,
 			X_NEW_SOURCE_ADDRESS2          => p_source_address2,
 			X_OLD_SOURCE_ADDRESS2          => null,
 			X_NEW_SOURCE_ADDRESS3          => p_source_address3,
 			X_OLD_SOURCE_ADDRESS3          => null,
 			X_NEW_SOURCE_ADDRESS4          => p_source_address4,
 			X_OLD_SOURCE_ADDRESS4          => null,
 			X_NEW_SOURCE_CITY              => p_source_city,
 			X_OLD_SOURCE_CITY              => null,
 			X_NEW_SOURCE_POSTAL_CODE       => p_source_postal_code,
 			X_OLD_SOURCE_POSTAL_CODE       => null,
 			X_NEW_SOURCE_STATE             => p_source_state,
 			X_OLD_SOURCE_STATE             => null,
 			X_NEW_SOURCE_PROVINCE          => p_source_province,
 			X_OLD_SOURCE_PROVINCE          => null,
 			X_NEW_SOURCE_COUNTY            => p_source_county,
 			X_OLD_SOURCE_COUNTY            => null,
 			X_NEW_SOURCE_COUNTRY           => p_source_country,
 			X_OLD_SOURCE_COUNTRY           => null,
 			X_NEW_SOURCE_MGR_ID            => p_source_mgr_id,
 			X_OLD_SOURCE_MGR_ID            => null,
 			X_NEW_SOURCE_MGR_NAME          => p_source_mgr_name,
 			X_OLD_SOURCE_MGR_NAME          => null,
 			X_NEW_SOURCE_BUSINESS_GRP_ID   => p_source_business_grp_id,
 			X_OLD_SOURCE_BUSINESS_GRP_ID   => null,
 			X_NEW_SOURCE_BUSINESS_GRP_NAME => p_source_business_grp_name,
 			X_OLD_SOURCE_BUSINESS_GRP_NAME => null,
 			X_NEW_SOURCE_FIRST_NAME        => p_source_first_name,
 			X_OLD_SOURCE_FIRST_NAME        => null,
 			X_NEW_SOURCE_MIDDLE_NAME       => p_source_middle_name,
 			X_OLD_SOURCE_MIDDLE_NAME       => null,
 			X_NEW_SOURCE_LAST_NAME         => p_source_last_name,
 			X_OLD_SOURCE_LAST_NAME         => null,
 			X_NEW_SOURCE_CATEGORY          => p_source_category,
 			X_OLD_SOURCE_CATEGORY          => null,
 			X_NEW_SOURCE_STATUS            => p_source_status,
 			X_OLD_SOURCE_STATUS            => null,
 			X_NEW_SOURCE_OFFICE            => p_source_office,
 			X_OLD_SOURCE_OFFICE            => null,
 			X_NEW_SOURCE_LOCATION          => p_source_location,
 			X_OLD_SOURCE_LOCATION          => null,
 			X_NEW_SOURCE_MAILSTOP          => p_source_mailstop,
 			X_OLD_SOURCE_MAILSTOP          => null,
 			X_NEW_USER_NAME                => p_user_name,
 			X_OLD_USER_NAME                => null,
 			X_NEW_SOURCE_JOB_ID            => p_source_job_id,
 			X_OLD_SOURCE_JOB_ID            => null,
 			X_NEW_PARTY_ID                 => p_party_id,
 			X_OLD_PARTY_ID                 => null,
                        X_CREATION_DATE                => l_date,
                        X_CREATED_BY                   => l_user_id,
                        X_LAST_UPDATE_DATE             => l_date,
                        X_LAST_UPDATED_BY              => l_user_id,
                        X_LAST_UPDATE_LOGIN            => l_login_id,
 			X_NEW_SOURCE_MOBILE_PHONE      => p_source_mobile_phone,
 			X_OLD_SOURCE_MOBILE_PHONE      => null,
 			X_NEW_SOURCE_PAGER             => p_source_pager,
 			X_OLD_SOURCE_PAGER             => null
                        );


  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


   END INSERT_RESOURCE;


   /* FOR UPDATE */
   PROCEDURE   UPDATE_RESOURCE(
	P_API_VERSION		   IN	NUMBER,
	P_INIT_MSG_LIST		   IN	VARCHAR2,
	P_COMMIT	           IN	VARCHAR2,
        P_RESOURCE_ID              IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
        P_RESOURCE_NUMBER          IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
        P_CATEGORY                 IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
        P_SOURCE_ID                IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
        P_ADDRESS_ID               IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
        P_CONTACT_ID               IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE,
        P_MANAGING_EMP_ID          IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE,
        P_START_DATE_ACTIVE        IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
        P_END_DATE_ACTIVE          IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
        P_TIME_ZONE                IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
        P_COST_PER_HR              IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
        P_PRIMARY_LANGUAGE         IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
        P_SECONDARY_LANGUAGE       IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
        P_SUPPORT_SITE_ID          IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE,
        P_IES_AGENT_LOGIN          IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
        P_SERVER_GROUP_ID          IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
        P_ASSIGNED_TO_GROUP_ID     IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
        P_COST_CENTER              IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
        P_CHARGE_TO_COST_CENTER    IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
        P_COMP_CURRENCY_CODE       IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
        P_COMMISSIONABLE_FLAG      IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
        P_HOLD_REASON_CODE         IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
        P_HOLD_PAYMENT             IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
        P_COMP_SERVICE_TEAM_ID     IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
        --P_LOCATION                 IN   MDSYS.SDO_GEOMETRY,
        P_TRANSACTION_NUMBER       IN   NUMBER,
        P_USER_ID                  IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
        P_OBJECT_VERSION_NUMBER    IN   NUMBER,
        X_RETURN_STATUS            OUT NOCOPY  VARCHAR2,
        X_MSG_COUNT                OUT NOCOPY  NUMBER,
        X_MSG_DATA                 OUT NOCOPY  VARCHAR2 )
    IS

    CURSOR rr_old_cur(l_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
        IS
    SELECT   category
             ,resource_number
             ,source_id
             ,address_id
             ,contact_id
             ,managing_employee_id
             ,start_date_active
             ,end_date_active
             ,time_zone
             ,cost_per_hr
             ,primary_language
             ,secondary_language
             ,support_site_id
             ,ies_agent_login
             ,server_group_id
             ,assigned_to_group_id
             ,cost_center
             ,charge_to_cost_center
             ,compensation_currency_code
             ,commissionable_flag
             ,hold_reason_code
             ,hold_payment
             ,comp_service_team_id
             ,transaction_number
             ,object_version_number
             --,location
             , user_id
      FROM  jtf_rs_resource_extns
     WHERE  resource_id = l_resource_id;


     --declare variables
--old value
        l_resource_number               jtf_rs_resource_extns.resource_number%type;
        l_category                      jtf_rs_resource_extns.category%type;
        l_source_id                     jtf_rs_resource_extns.source_id%type  ;
        l_address_id                    jtf_rs_resource_extns.address_id%type  ;
        l_contact_id                    jtf_rs_resource_extns.contact_id%type  ;
        l_managing_emp_id               jtf_rs_resource_extns.managing_employee_id%type   ;
        l_start_date_active             jtf_rs_resource_extns.start_date_active%type;
        l_end_date_active               jtf_rs_resource_extns.end_date_active%type   ;
        l_time_zone                     jtf_rs_resource_extns.time_zone%type   ;
        l_cost_per_hr                   jtf_rs_resource_extns.cost_per_hr%type  ;
        l_primary_language              jtf_rs_resource_extns.primary_language%type   ;
        l_secondary_language            jtf_rs_resource_extns.secondary_language%type   ;
        l_support_site_id               jtf_rs_resource_extns.support_site_id%type   ;
        l_ies_agent_login               jtf_rs_resource_extns.ies_agent_login%type   ;
        l_server_group_id               jtf_rs_resource_extns.server_group_id%type   ;
        l_assigned_to_group_id          jtf_rs_resource_extns.assigned_to_group_id%type   ;
        l_cost_center                   jtf_rs_resource_extns.cost_center%type   ;
        l_charge_to_cost_center         jtf_rs_resource_extns.charge_to_cost_center%type   ;
        l_comp_currency_code            jtf_rs_resource_extns.compensation_currency_code%type   ;
        l_commissionable_flag           jtf_rs_resource_extns.commissionable_flag%type   ;
        l_hold_reason_code              jtf_rs_resource_extns.hold_reason_code%type   ;
        l_hold_payment                  jtf_rs_resource_extns.hold_payment%type  ;
        l_comp_service_team_id          jtf_rs_resource_extns.comp_service_team_id%type   ;
        --l_location                      mdsys.sdo_geometry   ;
        l_transaction_number            number;
        l_user_id_o                     jtf_rs_resource_extns.user_id%type;
        l_object_version_number         number;






--new values
        l_resource_number_n               jtf_rs_resource_extns.resource_number%type;
        l_category_n                      jtf_rs_resource_extns.category%type;
        l_source_id_n                     jtf_rs_resource_extns.source_id%type  ;
        l_address_id_n                    jtf_rs_resource_extns.address_id%type  ;
        l_contact_id_n                    jtf_rs_resource_extns.contact_id%type  ;
        l_managing_emp_id_n               jtf_rs_resource_extns.managing_employee_id%type   ;
        l_start_date_active_n             jtf_rs_resource_extns.start_date_active%type;
        l_end_date_active_n               jtf_rs_resource_extns.end_date_active%type   ;
        l_time_zone_n                     jtf_rs_resource_extns.time_zone%type   ;
        l_cost_per_hr_n                   jtf_rs_resource_extns.cost_per_hr%type  ;
        l_primary_language_n              jtf_rs_resource_extns.primary_language%type   ;
        l_secondary_language_n            jtf_rs_resource_extns.secondary_language%type   ;
        l_support_site_id_n               jtf_rs_resource_extns.support_site_id%type   ;
        l_ies_agent_login_n               jtf_rs_resource_extns.ies_agent_login%type   ;
        l_server_group_id_n               jtf_rs_resource_extns.server_group_id%type   ;
        l_assigned_to_group_id_n          jtf_rs_resource_extns.assigned_to_group_id%type   ;
        l_cost_center_n                   jtf_rs_resource_extns.cost_center%type   ;
        l_charge_to_cost_center_n         jtf_rs_resource_extns.charge_to_cost_center%type   ;
        l_comp_currency_code_n            jtf_rs_resource_extns.compensation_currency_code%type   ;
        l_commissionable_flag_n           jtf_rs_resource_extns.commissionable_flag%type   ;
        l_hold_reason_code_n              jtf_rs_resource_extns.hold_reason_code%type   ;
        l_hold_payment_n                  jtf_rs_resource_extns.hold_payment%type  ;
        l_comp_service_team_id_n          jtf_rs_resource_extns.comp_service_team_id%type   ;
        --l_location_n                      mdsys.sdo_geometry   ;
        l_transaction_number_n            number;
        l_user_id_n                        jtf_rs_resource_extns.user_id%type;
        l_object_version_number_n         number;

    rr_old_rec    rr_old_cur%rowtype;
    l_resource_extn_aud_id jtf_rs_resource_extn_aud.resource_audit_id%type;
    l_row_id        varchar2(24) := null;
    l_dummy         varchar2(10) := 'S';

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number := 1;
    l_login_id  Number := 1;


    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT RESOURCE_EXTN_AUDIT;

    x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


    open rr_old_cur(p_resource_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    if nvl(p_category,fnd_api.g_miss_char)  <> NVL(rr_old_rec.category,fnd_api.g_miss_char)
    then
       l_category :=  rr_old_rec.category;
       l_category_n :=  p_category;
    end if;
    if nvl(p_resource_number,fnd_api.g_miss_char) <> nvl(rr_old_rec.resource_number, fnd_api.g_miss_char)
    then
       l_resource_number :=  rr_old_rec.resource_number;
       l_resource_number_n:=  p_resource_number;
    end if;
    if nvl(p_source_id, -1)   <> nvl(rr_old_rec.source_id, -1)
    then
       l_source_id  :=  rr_old_rec.source_id ;
       l_source_id_n :=  p_source_id ;
    end if;
    if nvl(p_address_id, -1)  <> nvl(rr_old_rec.address_id, -1)
    then
       l_address_id  :=  rr_old_rec.address_id;
       l_address_id_n  :=  p_address_id ;
    end if;
    if nvl(p_contact_id, -1)  <> nvl(rr_old_rec.contact_id , -1)
    then
       l_contact_id  :=  rr_old_rec.contact_id;
       l_contact_id_n  :=  p_contact_id  ;
    end if;
    if nvl(p_managing_emp_id, -1)  <> nvl(rr_old_rec.managing_employee_id , -1)
    then
       l_managing_emp_id  :=  rr_old_rec.managing_employee_id ;
       l_managing_emp_id_n  :=  p_managing_emp_id ;
    end if;
    if p_start_date_active  <> rr_old_rec.start_date_active
    then
       l_start_date_active  :=  rr_old_rec.start_date_active;
       l_start_date_active_n  :=  p_start_date_active ;
    end if;
    if nvl(p_end_date_active,fnd_api.g_miss_date)<> nvl(rr_old_rec.end_date_active,fnd_api.g_miss_date)
    then
       l_end_date_active  :=  rr_old_rec.end_date_active;
       l_end_date_active_n  :=  p_end_date_active ;
    end if;
    if nvl(p_time_zone, -1) <> nvl(rr_old_rec.time_zone, -1)
    then
       l_time_zone :=  rr_old_rec.time_zone;
       l_time_zone_n  :=  p_time_zone ;
    end if;
    if nvl(p_cost_per_hr, -1)  <> nvl(rr_old_rec.cost_per_hr, -1)
    then
       l_cost_per_hr :=  rr_old_rec.cost_per_hr;
       l_cost_per_hr_n  :=  p_cost_per_hr ;
    end if;
    if nvl(p_primary_language, fnd_api.g_miss_char) <> nvl(rr_old_rec.primary_language,fnd_api.g_miss_char)
    then
       l_primary_language :=  rr_old_rec.primary_language;
       l_primary_language_n  :=  p_primary_language;
    end if;
    if nvl(p_secondary_language,fnd_api.g_miss_char)  <> nvl(rr_old_rec.secondary_language, fnd_api.g_miss_char)
    then
       l_secondary_language  :=  rr_old_rec.secondary_language;
       l_secondary_language_n  :=  p_secondary_language;
    end if;
    if nvl(p_support_site_id,fnd_api.g_miss_num)  <> nvl(rr_old_rec.support_site_id,fnd_api.g_miss_num)
    then
       l_support_site_id :=  rr_old_rec.support_site_id;
       l_support_site_id_n  :=  p_support_site_id ;
    end if;
    if nvl(p_ies_agent_login, fnd_api.g_miss_char)<> nvl(rr_old_rec.ies_agent_login, fnd_api.g_miss_char)
    then
       l_ies_agent_login  :=  rr_old_rec.ies_agent_login;
       l_ies_agent_login_n  :=  p_ies_agent_login ;
    end if;
   if nvl(p_server_group_id ,fnd_api.g_miss_num) <> nvl(rr_old_rec.server_group_id, fnd_api.g_miss_num)
    then
       l_server_group_id :=  rr_old_rec.server_group_id;
       l_server_group_id_n  :=  p_server_group_id ;
    end if;
    if nvl(p_server_group_id, -1)  <> nvl(rr_old_rec.server_group_id, -1)
    then
       l_server_group_id :=  rr_old_rec.server_group_id;
       l_server_group_id_n  :=  p_server_group_id ;
    end if;
    if nvl(p_assigned_to_group_id, -1)  <> nvl(rr_old_rec.assigned_to_group_id, -1)
    then
       l_assigned_to_group_id :=  rr_old_rec.assigned_to_group_id;
       l_assigned_to_group_id_n  :=  p_assigned_to_group_id;
    end if;
    if nvl(p_cost_center,fnd_api.g_miss_char)  <> nvl(rr_old_rec.cost_center, fnd_api.g_miss_char)
    then
       l_cost_center  :=  rr_old_rec.cost_center;
       l_cost_center_n  :=  p_cost_center ;
    end if;
    if nvl(p_charge_to_cost_center,fnd_api.g_miss_char) <> nvl(rr_old_rec.charge_to_cost_center, fnd_api.g_miss_char)
    then
       l_charge_to_cost_center :=  rr_old_rec.charge_to_cost_center;
       l_charge_to_cost_center_n  :=  p_charge_to_cost_center ;
    end if;
    if nvl(p_comp_currency_code,fnd_api.g_miss_char) <> nvl(rr_old_rec.compensation_currency_code,fnd_api.g_miss_char)
    then
       l_comp_currency_code :=  rr_old_rec.compensation_currency_code;
       l_comp_currency_code_n  :=  p_comp_currency_code ;
    end if;
    if nvl(p_commissionable_flag,fnd_api.g_miss_char)  <> nvl(rr_old_rec.commissionable_flag , fnd_api.g_miss_char)
    then
       l_commissionable_flag :=  rr_old_rec.commissionable_flag;
       l_commissionable_flag_n  :=  p_commissionable_flag ;
    end if;
    if nvl(p_hold_reason_code,fnd_api.g_miss_char) <> nvl(rr_old_rec.hold_reason_code, fnd_api.g_miss_char)
    then
       l_hold_reason_code :=  rr_old_rec.hold_reason_code;
       l_hold_reason_code_n  :=  p_hold_reason_code ;
    end if;
     if nvl(p_hold_payment,fnd_api.g_miss_char) <> nvl(rr_old_rec.hold_payment, fnd_api.g_miss_char)
    then
       l_hold_payment:=  rr_old_rec.hold_payment;
       l_hold_payment_n  :=  p_hold_payment ;
    end if;
     if nvl(p_comp_service_team_id, -1) <> nvl(rr_old_rec.comp_service_team_id, -1)
    then
       l_comp_service_team_id :=  rr_old_rec.comp_service_team_id;
       l_comp_service_team_id_n  :=  p_comp_service_team_id ;
    end if;

    /*if(p_location.sdo_gtype  <> rr_old_rec.location.sdo_gtype
       OR p_location.sdo_srid  <> rr_old_rec.location.sdo_srid
       OR p_location.sdo_point.x <> rr_old_rec.location.sdo_point.x
       OR p_location.sdo_point.y <> rr_old_rec.location.sdo_point.y
       OR p_location.sdo_point.z <> rr_old_rec.location.sdo_point.z)
    then
       l_location   :=  rr_old_rec.location   ;
       l_location_n  :=  p_location    ;
    end if; */
    if nvl(p_transaction_number, -1)  <> nvl(rr_old_rec.transaction_number, -1)
    then
       l_transaction_number  :=  rr_old_rec.transaction_number;
       l_transaction_number_n  :=  p_transaction_number;
    end if;
    if nvl(p_object_version_number, -1)  <> nvl(rr_old_rec.object_version_number, -1)
    then
       l_object_version_number  :=  rr_old_rec.object_version_number;
       l_object_version_number_n  :=  p_object_version_number;
    end if;
    if nvl(p_user_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.user_id, fnd_api.g_miss_num)
    then
       l_user_id_o  :=  rr_old_rec.user_id;
       l_user_id_n  :=  p_user_id;
    end if;

   select jtf_rs_resource_extn_aud_s.nextval
     into l_resource_extn_aud_id
     from dual;

    /* CALL TABLE HANDLER */
  JTF_RS_RESOURCE_EXTN_AUD_PKG.INSERT_ROW (
                        X_ROWID                        => l_row_id,
                        x_resource_audit_id            =>  l_resource_extn_aud_id,
                        x_resource_id                  =>  p_resource_id,
                        x_new_category                 =>  l_category_n,
                        x_old_category                 =>  l_category,
                        x_new_resource_number          =>  l_resource_number_n  ,
                        x_old_resource_number          => l_resource_number ,
                        x_new_source_id                => l_source_id_n ,
                        x_old_source_id                =>  l_source_id ,
                        x_new_address_id               => l_address_id_n ,
                        x_old_address_id               => l_address_id  ,
                        x_new_contact_id               => l_contact_id_n ,
                        x_old_contact_id               => l_contact_id  ,
                        x_new_managing_employee_id     => l_managing_emp_id_n ,
                        x_old_managing_employee_id     => l_managing_emp_id ,
                        x_new_start_date_active        => l_start_date_active_n ,
                        x_old_start_date_active        => l_start_date_active ,
                        x_new_end_date_active        => l_end_date_active_n ,
                        x_old_end_date_active        => l_end_date_active ,
                        x_new_time_zone                => l_time_zone_n ,
                        x_old_time_zone                => l_time_zone ,
                        x_new_cost_per_hr              => l_cost_per_hr_n ,
                        x_old_cost_per_hr              => l_cost_per_hr ,
                        x_new_primary_language         =>  l_primary_language_n ,
                        x_old_primary_language         =>l_primary_language,
                        x_new_secondary_language       => l_secondary_language_n ,
                        x_old_secondary_language       => l_secondary_language ,
                        x_new_support_site_id          => l_support_site_id_n ,
                        x_old_support_site_id          => l_support_site_id ,
                        x_new_ies_agent_login          => l_ies_agent_login_n ,
                        x_old_ies_agent_login          => l_ies_agent_login ,
                        x_new_server_group_id          => l_server_group_id_n ,
                        x_old_server_group_id          => l_server_group_id ,
                        x_new_assigned_to_group_id     => l_assigned_to_group_id_n ,
                        x_old_assigned_to_group_id     =>l_assigned_to_group_id,
                        x_new_cost_center              => l_cost_center_n ,
                        x_old_cost_center              => l_cost_center ,
                        x_new_charge_to_cost_center    => l_charge_to_cost_center_n ,
                        x_old_charge_to_cost_center    => l_charge_to_cost_center ,
                        x_new_compensation_currency_co => l_comp_currency_code_n ,
                        x_old_compensation_currency_co => l_comp_currency_code ,
                        x_new_commissionable_flag      => l_commissionable_flag_n ,
                        x_old_commissionable_flag      => l_commissionable_flag ,
                        x_new_hold_reason_code         => l_hold_reason_code_n ,
                        x_old_hold_reason_code         => l_hold_reason_code  ,
                        x_new_hold_payment             => l_hold_payment_n ,
                        x_old_hold_payment             => l_hold_payment ,
                        x_new_comp_service_team_id     => l_comp_service_team_id_n ,
                        x_old_comp_service_team_id     => l_comp_service_team_id ,
                        x_new_transaction_number       => l_transaction_number_n ,
                        x_old_transaction_number       => l_transaction_number ,
                        x_new_object_version_number    => l_object_version_number_n ,
                        x_old_object_version_number    => l_object_version_number ,
                        x_new_user_id                  => l_user_id_n,
                        x_old_user_id                  => l_user_id_o,
                        --x_old_location                 => p_location,
                        --x_new_location                 => p_location,
                        X_CREATION_DATE                => l_date,
                        X_CREATED_BY                   => l_user_id,
                        X_LAST_UPDATE_DATE             => l_date,
                        X_LAST_UPDATED_BY              => l_user_id,
                        X_LAST_UPDATE_LOGIN            => l_login_id
                        );




  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


 EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    END UPDATE_RESOURCE;


   /*UPDATE for Resource Synchronization */
   PROCEDURE   UPDATE_RESOURCE(
	P_API_VERSION		   IN	NUMBER,
	P_INIT_MSG_LIST		   IN	VARCHAR2,
	P_COMMIT	           IN	VARCHAR2,
        P_RESOURCE_ID              IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
        P_RESOURCE_NUMBER          IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
        P_CATEGORY                 IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
        P_SOURCE_ID                IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
        P_ADDRESS_ID               IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE,
        P_CONTACT_ID               IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE,
        P_MANAGING_EMP_ID          IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE,
        P_START_DATE_ACTIVE        IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
        P_END_DATE_ACTIVE          IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
        P_TIME_ZONE                IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
        P_COST_PER_HR              IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
        P_PRIMARY_LANGUAGE         IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
        P_SECONDARY_LANGUAGE       IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
        P_SUPPORT_SITE_ID          IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE,
        P_IES_AGENT_LOGIN          IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
        P_SERVER_GROUP_ID          IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
        P_ASSIGNED_TO_GROUP_ID     IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
        P_COST_CENTER              IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
        P_CHARGE_TO_COST_CENTER    IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
        P_COMP_CURRENCY_CODE       IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
        P_COMMISSIONABLE_FLAG      IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
        P_HOLD_REASON_CODE         IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
        P_HOLD_PAYMENT             IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
        P_COMP_SERVICE_TEAM_ID     IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
        --P_LOCATION                 IN   MDSYS.SDO_GEOMETRY,
        P_TRANSACTION_NUMBER       IN   NUMBER,
        P_USER_ID                  IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
        P_OBJECT_VERSION_NUMBER    IN   NUMBER,
        P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE,
        P_SOURCE_NAME             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
        P_SOURCE_NUMBER           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE,
        P_SOURCE_JOB_TITLE        IN   JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_TITLE%TYPE,
        P_SOURCE_EMAIL            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE,
        P_SOURCE_PHONE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PHONE%TYPE,
        P_SOURCE_ORG_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_ID%TYPE,
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
        P_SOURCE_FIRST_NAME        IN  JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE,
        P_SOURCE_LAST_NAME        IN  JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE,
        P_SOURCE_MIDDLE_NAME      IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE,
        P_SOURCE_CATEGORY         IN  JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE,
        P_SOURCE_STATUS           IN  JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE,
        P_SOURCE_OFFICE           IN  JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE,
        P_SOURCE_LOCATION         IN  JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE,
        P_SOURCE_MAILSTOP         IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE,
        P_USER_NAME               IN  JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE,
        P_PARTY_ID                 IN  JTF_RS_RESOURCE_EXTNS.PERSON_PARTY_ID%TYPE,
        P_SOURCE_JOB_ID            IN  JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_ID%TYPE,
        X_RETURN_STATUS            OUT NOCOPY  VARCHAR2,
        X_MSG_COUNT                OUT NOCOPY  NUMBER,
        X_MSG_DATA                 OUT NOCOPY  VARCHAR2,
        P_SOURCE_MOBILE_PHONE      IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE,
        P_SOURCE_PAGER             IN  JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE )
    IS

    CURSOR rr_old_cur(l_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
        IS
    SELECT   category
             ,resource_number
             ,source_id
             ,address_id
             ,contact_id
             ,managing_employee_id
             ,start_date_active
             ,end_date_active
             ,time_zone
             ,cost_per_hr
             ,primary_language
             ,secondary_language
             ,support_site_id
             ,ies_agent_login
             ,server_group_id
             ,assigned_to_group_id
             ,cost_center
             ,charge_to_cost_center
             ,compensation_currency_code
             ,commissionable_flag
             ,hold_reason_code
             ,hold_payment
             ,comp_service_team_id
             ,transaction_number
             ,object_version_number
             --,location
             , user_id
 	     , RESOURCE_NAME
             , SOURCE_NAME
             , SOURCE_NUMBER
             , SOURCE_JOB_TITLE
             , SOURCE_EMAIL
             , SOURCE_PHONE
             , SOURCE_ORG_ID
             , SOURCE_ORG_NAME
             , SOURCE_ADDRESS1
             , SOURCE_ADDRESS2
             , SOURCE_ADDRESS3
             , SOURCE_ADDRESS4
             , SOURCE_CITY
             , SOURCE_POSTAL_CODE
             , SOURCE_STATE
             , SOURCE_PROVINCE
             , SOURCE_COUNTY
             , SOURCE_COUNTRY
             , SOURCE_MGR_ID
             , SOURCE_MGR_NAME
             , SOURCE_BUSINESS_GRP_ID
             , SOURCE_BUSINESS_GRP_NAME
            , SOURCE_FIRST_NAME
            , SOURCE_MIDDLE_NAME
            , SOURCE_LAST_NAME
           , SOURCE_CATEGORY
           , SOURCE_STATUS
           , SOURCE_OFFICE
           , SOURCE_LOCATION
           , SOURCE_MAILSTOP
           , USER_NAME
           , SOURCE_JOB_ID
           , PERSON_PARTY_ID
           , SOURCE_MOBILE_PHONE
           , SOURCE_PAGER
      FROM  jtf_rs_resource_extns_vl
     WHERE  resource_id = l_resource_id;


     --declare variables
--old value
        l_resource_number               jtf_rs_resource_extns.resource_number%type;
        l_category                      jtf_rs_resource_extns.category%type;
        l_source_id                     jtf_rs_resource_extns.source_id%type  ;
        l_address_id                    jtf_rs_resource_extns.address_id%type  ;
        l_contact_id                    jtf_rs_resource_extns.contact_id%type  ;
        l_managing_emp_id               jtf_rs_resource_extns.managing_employee_id%type   ;
        l_start_date_active             jtf_rs_resource_extns.start_date_active%type;
        l_end_date_active               jtf_rs_resource_extns.end_date_active%type   ;
        l_time_zone                     jtf_rs_resource_extns.time_zone%type   ;
        l_cost_per_hr                   jtf_rs_resource_extns.cost_per_hr%type  ;
        l_primary_language              jtf_rs_resource_extns.primary_language%type   ;
        l_secondary_language            jtf_rs_resource_extns.secondary_language%type   ;
        l_support_site_id               jtf_rs_resource_extns.support_site_id%type   ;
        l_ies_agent_login               jtf_rs_resource_extns.ies_agent_login%type   ;
        l_server_group_id               jtf_rs_resource_extns.server_group_id%type   ;
        l_assigned_to_group_id          jtf_rs_resource_extns.assigned_to_group_id%type   ;
        l_cost_center                   jtf_rs_resource_extns.cost_center%type   ;
        l_charge_to_cost_center         jtf_rs_resource_extns.charge_to_cost_center%type   ;
        l_comp_currency_code            jtf_rs_resource_extns.compensation_currency_code%type   ;
        l_commissionable_flag           jtf_rs_resource_extns.commissionable_flag%type   ;
        l_hold_reason_code              jtf_rs_resource_extns.hold_reason_code%type   ;
        l_hold_payment                  jtf_rs_resource_extns.hold_payment%type  ;
        l_comp_service_team_id          jtf_rs_resource_extns.comp_service_team_id%type   ;
        --l_location                      mdsys.sdo_geometry   ;
        l_transaction_number            number;
        l_user_id_o                     jtf_rs_resource_extns.user_id%type;
        l_object_version_number         number;

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
    	l_source_middle_name jtf_rs_resource_extns.source_middle_name%type;
    	l_source_last_name          jtf_rs_resource_extns.source_last_name%type;
    	l_source_category          jtf_rs_resource_extns.source_category%type;
    	l_source_status            jtf_rs_resource_extns.source_status%type;
    	l_source_office            jtf_rs_resource_extns.source_office%type;
    	l_source_location            jtf_rs_resource_extns.source_location%type;
    	l_source_mailstop            jtf_rs_resource_extns.source_mailstop%type;
    	l_source_mobile_phone            jtf_rs_resource_extns.source_mobile_phone%type;
    	l_source_pager            jtf_rs_resource_extns.source_pager%type;
    	l_user_name            jtf_rs_resource_extns.user_name%type;
    	l_source_job_id            jtf_rs_resource_extns.source_job_id%type;
    	l_party_id            jtf_rs_resource_extns.person_party_id%type;


--new values
        l_resource_number_n               jtf_rs_resource_extns.resource_number%type;
        l_category_n                      jtf_rs_resource_extns.category%type;
        l_source_id_n                     jtf_rs_resource_extns.source_id%type  ;
        l_address_id_n                    jtf_rs_resource_extns.address_id%type  ;
        l_contact_id_n                    jtf_rs_resource_extns.contact_id%type  ;
        l_managing_emp_id_n               jtf_rs_resource_extns.managing_employee_id%type   ;
        l_start_date_active_n             jtf_rs_resource_extns.start_date_active%type;
        l_end_date_active_n               jtf_rs_resource_extns.end_date_active%type   ;
        l_time_zone_n                     jtf_rs_resource_extns.time_zone%type   ;
        l_cost_per_hr_n                   jtf_rs_resource_extns.cost_per_hr%type  ;
        l_primary_language_n              jtf_rs_resource_extns.primary_language%type   ;
        l_secondary_language_n            jtf_rs_resource_extns.secondary_language%type   ;
        l_support_site_id_n               jtf_rs_resource_extns.support_site_id%type   ;
        l_ies_agent_login_n               jtf_rs_resource_extns.ies_agent_login%type   ;
        l_server_group_id_n               jtf_rs_resource_extns.server_group_id%type   ;
        l_assigned_to_group_id_n          jtf_rs_resource_extns.assigned_to_group_id%type   ;
        l_cost_center_n                   jtf_rs_resource_extns.cost_center%type   ;
        l_charge_to_cost_center_n         jtf_rs_resource_extns.charge_to_cost_center%type   ;
        l_comp_currency_code_n            jtf_rs_resource_extns.compensation_currency_code%type   ;
        l_commissionable_flag_n           jtf_rs_resource_extns.commissionable_flag%type   ;
        l_hold_reason_code_n              jtf_rs_resource_extns.hold_reason_code%type   ;
        l_hold_payment_n                  jtf_rs_resource_extns.hold_payment%type  ;
        l_comp_service_team_id_n          jtf_rs_resource_extns.comp_service_team_id%type   ;
        --l_location_n                      mdsys.sdo_geometry   ;
        l_transaction_number_n            number;
        l_user_id_n                        jtf_rs_resource_extns.user_id%type;
        l_object_version_number_n         number;

        l_resource_name_n           jtf_rs_resource_extns_tl.resource_name%type;
        l_source_name_n             jtf_rs_resource_extns.source_name%type;
        l_source_number_n           jtf_rs_resource_extns.source_number%type;
        l_source_job_title_n        jtf_rs_resource_extns.source_job_title%type;
        l_source_email_n            jtf_rs_resource_extns.source_email%type;
        l_source_phone_n            jtf_rs_resource_extns.source_phone%type;
        l_source_org_id_n           jtf_rs_resource_extns.source_org_id%type;
        l_source_org_name_n         jtf_rs_resource_extns.source_org_name%type;
        l_source_address1_n         jtf_rs_resource_extns.source_address1%type;
        l_source_address2_n         jtf_rs_resource_extns.source_address2%type;
        l_source_address3_n         jtf_rs_resource_extns.source_address3%type;
        l_source_address4_n         jtf_rs_resource_extns.source_address4%type;
        l_source_city_n             jtf_rs_resource_extns.source_city%type;
        l_source_postal_code_n      jtf_rs_resource_extns.source_postal_code%type;
        l_source_state_n            jtf_rs_resource_extns.source_state%type;
        l_source_province_n         jtf_rs_resource_extns.source_province%type;
        l_source_county_n           jtf_rs_resource_extns.source_county%type;
        l_source_country_n          jtf_rs_resource_extns.source_country%type;
        l_source_mgr_id_n           jtf_rs_resource_extns.source_mgr_id%type;
        l_source_mgr_name_n         jtf_rs_resource_extns.source_mgr_name%type;
        l_source_business_grp_id_n  jtf_rs_resource_extns.source_business_grp_id%type;
        l_source_business_grp_name_n jtf_rs_resource_extns.source_business_grp_name%type;
    	l_source_first_name_n        jtf_rs_resource_extns.source_first_name%type;
    	l_source_middle_name_n jtf_rs_resource_extns.source_middle_name%type;
    	l_source_last_name_n          jtf_rs_resource_extns.source_last_name%type;
    	l_source_category_n          jtf_rs_resource_extns.source_category%type;
    	l_source_status_n            jtf_rs_resource_extns.source_status%type;
    	l_source_office_n            jtf_rs_resource_extns.source_office%type;
    	l_source_location_n            jtf_rs_resource_extns.source_location%type;
    	l_source_mailstop_n            jtf_rs_resource_extns.source_mailstop%type;
    	l_source_mobile_phone_n            jtf_rs_resource_extns.source_mobile_phone%type;
    	l_source_pager_n            jtf_rs_resource_extns.source_pager%type;
    	l_user_name_n            jtf_rs_resource_extns.user_name%type;
    	l_source_job_id_n            jtf_rs_resource_extns.source_job_id%type;
    	l_party_id_n            jtf_rs_resource_extns.person_party_id%type;

    rr_old_rec    rr_old_cur%rowtype;
    l_resource_extn_aud_id jtf_rs_resource_extn_aud.resource_audit_id%type;
    l_row_id        varchar2(24) := null;
    l_dummy         varchar2(10) := 'S';

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';
    l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number := 1;
    l_login_id  Number := 1;


    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT RESOURCE_EXTN_AUDIT;

    x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


    open rr_old_cur(p_resource_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    if nvl(p_category,fnd_api.g_miss_char)  <> NVL(rr_old_rec.category,fnd_api.g_miss_char)
    then
       l_category :=  rr_old_rec.category;
       l_category_n :=  p_category;
    end if;
    if nvl(p_resource_number,fnd_api.g_miss_char) <> nvl(rr_old_rec.resource_number, fnd_api.g_miss_char)
    then
       l_resource_number :=  rr_old_rec.resource_number;
       l_resource_number_n:=  p_resource_number;
    end if;
    if nvl(p_source_id, -1)   <> nvl(rr_old_rec.source_id, -1)
    then
       l_source_id  :=  rr_old_rec.source_id ;
       l_source_id_n :=  p_source_id ;
    end if;
    if nvl(p_address_id, -1)  <> nvl(rr_old_rec.address_id, -1)
    then
       l_address_id  :=  rr_old_rec.address_id;
       l_address_id_n  :=  p_address_id ;
    end if;
    if nvl(p_contact_id, -1)  <> nvl(rr_old_rec.contact_id , -1)
    then
       l_contact_id  :=  rr_old_rec.contact_id;
       l_contact_id_n  :=  p_contact_id  ;
    end if;
    if nvl(p_managing_emp_id, -1)  <> nvl(rr_old_rec.managing_employee_id , -1)
    then
       l_managing_emp_id  :=  rr_old_rec.managing_employee_id ;
       l_managing_emp_id_n  :=  p_managing_emp_id ;
    end if;
    if p_start_date_active  <> rr_old_rec.start_date_active
    then
       l_start_date_active  :=  rr_old_rec.start_date_active;
       l_start_date_active_n  :=  p_start_date_active ;
    end if;
    if nvl(p_end_date_active,fnd_api.g_miss_date)<> nvl(rr_old_rec.end_date_active,fnd_api.g_miss_date)
    then
       l_end_date_active  :=  rr_old_rec.end_date_active;
       l_end_date_active_n  :=  p_end_date_active ;
    end if;
    if nvl(p_time_zone, -1) <> nvl(rr_old_rec.time_zone, -1)
    then
       l_time_zone :=  rr_old_rec.time_zone;
       l_time_zone_n  :=  p_time_zone ;
    end if;
    if nvl(p_cost_per_hr, -1)  <> nvl(rr_old_rec.cost_per_hr, -1)
    then
       l_cost_per_hr :=  rr_old_rec.cost_per_hr;
       l_cost_per_hr_n  :=  p_cost_per_hr ;
    end if;
    if nvl(p_primary_language, fnd_api.g_miss_char) <> nvl(rr_old_rec.primary_language,fnd_api.g_miss_char)
    then
       l_primary_language :=  rr_old_rec.primary_language;
       l_primary_language_n  :=  p_primary_language;
    end if;
    if nvl(p_secondary_language,fnd_api.g_miss_char)  <> nvl(rr_old_rec.secondary_language, fnd_api.g_miss_char)
    then
       l_secondary_language  :=  rr_old_rec.secondary_language;
       l_secondary_language_n  :=  p_secondary_language;
    end if;
    if nvl(p_support_site_id,fnd_api.g_miss_num)  <> nvl(rr_old_rec.support_site_id,fnd_api.g_miss_num)
    then
       l_support_site_id :=  rr_old_rec.support_site_id;
       l_support_site_id_n  :=  p_support_site_id ;
    end if;
    if nvl(p_ies_agent_login, fnd_api.g_miss_char)<> nvl(rr_old_rec.ies_agent_login, fnd_api.g_miss_char)
    then
       l_ies_agent_login  :=  rr_old_rec.ies_agent_login;
       l_ies_agent_login_n  :=  p_ies_agent_login ;
    end if;
   if nvl(p_server_group_id ,fnd_api.g_miss_num) <> nvl(rr_old_rec.server_group_id, fnd_api.g_miss_num)
    then
       l_server_group_id :=  rr_old_rec.server_group_id;
       l_server_group_id_n  :=  p_server_group_id ;
    end if;
    if nvl(p_server_group_id, -1)  <> nvl(rr_old_rec.server_group_id, -1)
    then
       l_server_group_id :=  rr_old_rec.server_group_id;
       l_server_group_id_n  :=  p_server_group_id ;
    end if;
    if nvl(p_assigned_to_group_id, -1)  <> nvl(rr_old_rec.assigned_to_group_id, -1)
    then
       l_assigned_to_group_id :=  rr_old_rec.assigned_to_group_id;
       l_assigned_to_group_id_n  :=  p_assigned_to_group_id;
    end if;
    if nvl(p_cost_center,fnd_api.g_miss_char)  <> nvl(rr_old_rec.cost_center, fnd_api.g_miss_char)
    then
       l_cost_center  :=  rr_old_rec.cost_center;
       l_cost_center_n  :=  p_cost_center ;
    end if;
    if nvl(p_charge_to_cost_center,fnd_api.g_miss_char) <> nvl(rr_old_rec.charge_to_cost_center, fnd_api.g_miss_char)
    then
       l_charge_to_cost_center :=  rr_old_rec.charge_to_cost_center;
       l_charge_to_cost_center_n  :=  p_charge_to_cost_center ;
    end if;
    if nvl(p_comp_currency_code,fnd_api.g_miss_char) <> nvl(rr_old_rec.compensation_currency_code,fnd_api.g_miss_char)
    then
       l_comp_currency_code :=  rr_old_rec.compensation_currency_code;
       l_comp_currency_code_n  :=  p_comp_currency_code ;
    end if;
    if nvl(p_commissionable_flag,fnd_api.g_miss_char)  <> nvl(rr_old_rec.commissionable_flag , fnd_api.g_miss_char)
    then
       l_commissionable_flag :=  rr_old_rec.commissionable_flag;
       l_commissionable_flag_n  :=  p_commissionable_flag ;
    end if;
    if nvl(p_hold_reason_code,fnd_api.g_miss_char) <> nvl(rr_old_rec.hold_reason_code, fnd_api.g_miss_char)
    then
       l_hold_reason_code :=  rr_old_rec.hold_reason_code;
       l_hold_reason_code_n  :=  p_hold_reason_code ;
    end if;
     if nvl(p_hold_payment,fnd_api.g_miss_char) <> nvl(rr_old_rec.hold_payment, fnd_api.g_miss_char)
    then
       l_hold_payment:=  rr_old_rec.hold_payment;
       l_hold_payment_n  :=  p_hold_payment ;
    end if;
     if nvl(p_comp_service_team_id, -1) <> nvl(rr_old_rec.comp_service_team_id, -1)
    then
       l_comp_service_team_id :=  rr_old_rec.comp_service_team_id;
       l_comp_service_team_id_n  :=  p_comp_service_team_id ;
    end if;

    /*if(p_location.sdo_gtype  <> rr_old_rec.location.sdo_gtype
       OR p_location.sdo_srid  <> rr_old_rec.location.sdo_srid
       OR p_location.sdo_point.x <> rr_old_rec.location.sdo_point.x
       OR p_location.sdo_point.y <> rr_old_rec.location.sdo_point.y
       OR p_location.sdo_point.z <> rr_old_rec.location.sdo_point.z)
    then
       l_location   :=  rr_old_rec.location   ;
       l_location_n  :=  p_location    ;
    end if; */
    if nvl(p_transaction_number, -1)  <> nvl(rr_old_rec.transaction_number, -1)
    then
       l_transaction_number  :=  rr_old_rec.transaction_number;
       l_transaction_number_n  :=  p_transaction_number;
    end if;
    if nvl(p_object_version_number, -1)  <> nvl(rr_old_rec.object_version_number, -1)
    then
       l_object_version_number  :=  rr_old_rec.object_version_number;
       l_object_version_number_n  :=  p_object_version_number;
    end if;
    if nvl(p_user_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.user_id, fnd_api.g_miss_num)
    then
       l_user_id_o  :=  rr_old_rec.user_id;
       l_user_id_n  :=  p_user_id;
    end if;

    if nvl(p_resource_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.resource_name, fnd_api.g_miss_char)
    then
       l_resource_name  :=  rr_old_rec.resource_name;
       l_resource_name_n  :=  p_resource_name;
    end if;

    if nvl(p_source_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_name, fnd_api.g_miss_char)
    then
       l_source_name  :=  rr_old_rec.source_name;
       l_source_name_n  :=  p_source_name;
    end if;

    if nvl(p_source_job_title, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_job_title, fnd_api.g_miss_char)
    then
       l_source_job_title  :=  rr_old_rec.source_job_title;
       l_source_job_title_n  :=  p_source_job_title;
    end if;

    if nvl(p_source_email, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_email, fnd_api.g_miss_char)
    then
       l_source_email  :=  rr_old_rec.source_email;
       l_source_email_n  :=  p_source_email;
    end if;

    if nvl(p_source_number, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_number, fnd_api.g_miss_char)
    then
       l_source_number  :=  rr_old_rec.source_number;
       l_source_number_n  :=  p_source_number;
    end if;

    if nvl(p_source_phone, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_phone, fnd_api.g_miss_char)
    then
       l_source_phone  :=  rr_old_rec.source_phone;
       l_source_phone_n  :=  p_source_phone;
    end if;

    if nvl(p_source_org_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.source_org_id, fnd_api.g_miss_num)
    then
       l_source_org_id  :=  rr_old_rec.source_org_id;
       l_source_org_id_n  :=  p_source_org_id;
    end if;

    if nvl(p_source_org_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_org_name, fnd_api.g_miss_char)
    then
       l_source_org_name  :=  rr_old_rec.source_org_name;
       l_source_org_name_n  :=  p_source_org_name;
    end if;

    if nvl(p_source_address1, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_address1, fnd_api.g_miss_char)
    then
       l_source_address1  :=  rr_old_rec.source_address1;
       l_source_address1_n  :=  p_source_address1;
    end if;

    if nvl(p_source_address2, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_address2, fnd_api.g_miss_char)
    then
       l_source_address2  :=  rr_old_rec.source_address2;
       l_source_address2_n  :=  p_source_address2;
    end if;

    if nvl(p_source_address3, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_address3, fnd_api.g_miss_char)
    then
       l_source_address3  :=  rr_old_rec.source_address3;
       l_source_address3_n  :=  p_source_address3;
    end if;

    if nvl(p_source_address4, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_address4, fnd_api.g_miss_char)
    then
       l_source_address4  :=  rr_old_rec.source_address4;
       l_source_address4_n  :=  p_source_address4;
    end if;

    if nvl(p_source_city, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_city, fnd_api.g_miss_char)
    then
       l_source_city  :=  rr_old_rec.source_city;
       l_source_city_n  :=  p_source_city;
    end if;

    if nvl(p_source_postal_code, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_postal_code, fnd_api.g_miss_char)
    then
       l_source_postal_code  :=  rr_old_rec.source_postal_code;
       l_source_postal_code_n  :=  p_source_postal_code;
    end if;

    if nvl(p_source_state, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_state, fnd_api.g_miss_char)
    then
       l_source_state  :=  rr_old_rec.source_state;
       l_source_state_n  :=  p_source_state;
    end if;

    if nvl(p_source_province, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_province, fnd_api.g_miss_char)
    then
       l_source_province  :=  rr_old_rec.source_province;
       l_source_province_n  :=  p_source_province;
    end if;

    if nvl(p_source_county, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_county, fnd_api.g_miss_char)
    then
       l_source_county  :=  rr_old_rec.source_county;
       l_source_county_n  :=  p_source_county;
    end if;

    if nvl(p_source_country, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_country, fnd_api.g_miss_char)
    then
       l_source_country  :=  rr_old_rec.source_country;
       l_source_country_n  :=  p_source_country;
    end if;

    if nvl(p_source_mgr_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.source_mgr_id, fnd_api.g_miss_num)
    then
       l_source_mgr_id  :=  rr_old_rec.source_mgr_id;
       l_source_mgr_id_n  :=  p_source_mgr_id;
    end if;

    if nvl(p_source_mgr_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_mgr_name, fnd_api.g_miss_char)
    then
       l_source_mgr_name  :=  rr_old_rec.source_mgr_name;
       l_source_mgr_name_n  :=  p_source_mgr_name;
    end if;

    if nvl(p_source_business_grp_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.source_business_grp_id, fnd_api.g_miss_num)
    then
       l_source_business_grp_id  :=  rr_old_rec.source_business_grp_id;
       l_source_business_grp_id_n  :=  p_source_business_grp_id;
    end if;

    if nvl(p_source_business_grp_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_business_grp_name, fnd_api.g_miss_char)
    then
       l_source_business_grp_name  :=  rr_old_rec.source_business_grp_name;
       l_source_business_grp_name_n  :=  p_source_business_grp_name;
    end if;

    if nvl(p_source_first_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_first_name, fnd_api.g_miss_char)
    then
       l_source_first_name  :=  rr_old_rec.source_first_name;
       l_source_first_name_n  :=  p_source_first_name;
    end if;

    if nvl(p_source_middle_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_middle_name, fnd_api.g_miss_char)
    then
       l_source_middle_name  :=  rr_old_rec.source_middle_name;
       l_source_middle_name_n  :=  p_source_middle_name;
    end if;

    if nvl(p_source_last_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_last_name, fnd_api.g_miss_char)
    then
       l_source_last_name  :=  rr_old_rec.source_last_name;
       l_source_last_name_n  :=  p_source_last_name;
    end if;

    if nvl(p_source_category, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_category, fnd_api.g_miss_char)
    then
       l_source_category  :=  rr_old_rec.source_category;
       l_source_category_n  :=  p_source_category;
    end if;

    if nvl(p_source_status, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_status, fnd_api.g_miss_char)
    then
       l_source_status  :=  rr_old_rec.source_status;
       l_source_status_n  :=  p_source_status;
    end if;

    if nvl(p_source_office, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_office, fnd_api.g_miss_char)
    then
       l_source_office  :=  rr_old_rec.source_office;
       l_source_office_n  :=  p_source_office;
    end if;

    if nvl(p_source_location, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_location, fnd_api.g_miss_char)
    then
       l_source_location  :=  rr_old_rec.source_location;
       l_source_location_n  :=  p_source_location;
    end if;

    if nvl(p_source_mailstop, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_mailstop, fnd_api.g_miss_char)
    then
       l_source_mailstop  :=  rr_old_rec.source_mailstop;
       l_source_mailstop_n  :=  p_source_mailstop;
    end if;

    if nvl(p_source_mobile_phone, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_mobile_phone, fnd_api.g_miss_char)
    then
       l_source_mobile_phone  :=  rr_old_rec.source_mobile_phone;
       l_source_mobile_phone_n  :=  p_source_mobile_phone;
    end if;

    if nvl(p_source_pager, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_pager, fnd_api.g_miss_char)
    then
       l_source_pager  :=  rr_old_rec.source_pager;
       l_source_pager_n  :=  p_source_pager;
    end if;

    if nvl(p_user_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.user_name, fnd_api.g_miss_char)
    then
       l_user_name  :=  rr_old_rec.user_name;
       l_user_name_n  :=  p_user_name;
    end if;

    if nvl(p_source_job_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.source_job_id, fnd_api.g_miss_num)
    then
       l_source_job_id  :=  rr_old_rec.source_job_id;
       l_source_job_id_n  :=  p_source_job_id;
    end if;

    if nvl(p_party_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.person_party_id, fnd_api.g_miss_num)
    then
       l_party_id  :=  rr_old_rec.person_party_id;
       l_party_id_n  :=  p_party_id;
    end if;




   select jtf_rs_resource_extn_aud_s.nextval
     into l_resource_extn_aud_id
     from dual;

    /* CALL TABLE HANDLER */
  JTF_RS_RESOURCE_EXTN_AUD_PKG.INSERT_ROW (
                        X_ROWID                        => l_row_id,
                        x_resource_audit_id            =>  l_resource_extn_aud_id,
                        x_resource_id                  =>  p_resource_id,
                        x_new_category                 =>  l_category_n,
                        x_old_category                 =>  l_category,
                        x_new_resource_number          =>  l_resource_number_n  ,
                        x_old_resource_number          => l_resource_number ,
                        x_new_source_id                => l_source_id_n ,
                        x_old_source_id                =>  l_source_id ,
                        x_new_address_id               => l_address_id_n ,
                        x_old_address_id               => l_address_id  ,
                        x_new_contact_id               => l_contact_id_n ,
                        x_old_contact_id               => l_contact_id  ,
                        x_new_managing_employee_id     => l_managing_emp_id_n ,
                        x_old_managing_employee_id     => l_managing_emp_id ,
                        x_new_start_date_active        => l_start_date_active_n ,
                        x_old_start_date_active        => l_start_date_active ,
                        x_new_end_date_active        => l_end_date_active_n ,
                        x_old_end_date_active        => l_end_date_active ,
                        x_new_time_zone                => l_time_zone_n ,
                        x_old_time_zone                => l_time_zone ,
                        x_new_cost_per_hr              => l_cost_per_hr_n ,
                        x_old_cost_per_hr              => l_cost_per_hr ,
                        x_new_primary_language         =>  l_primary_language_n ,
                        x_old_primary_language         =>l_primary_language,
                        x_new_secondary_language       => l_secondary_language_n ,
                        x_old_secondary_language       => l_secondary_language ,
                        x_new_support_site_id          => l_support_site_id_n ,
                        x_old_support_site_id          => l_support_site_id ,
                        x_new_ies_agent_login          => l_ies_agent_login_n ,
                        x_old_ies_agent_login          => l_ies_agent_login ,
                        x_new_server_group_id          => l_server_group_id_n ,
                        x_old_server_group_id          => l_server_group_id ,
                        x_new_assigned_to_group_id     => l_assigned_to_group_id_n ,
                        x_old_assigned_to_group_id     =>l_assigned_to_group_id,
                        x_new_cost_center              => l_cost_center_n ,
                        x_old_cost_center              => l_cost_center ,
                        x_new_charge_to_cost_center    => l_charge_to_cost_center_n ,
                        x_old_charge_to_cost_center    => l_charge_to_cost_center ,
                        x_new_compensation_currency_co => l_comp_currency_code_n ,
                        x_old_compensation_currency_co => l_comp_currency_code ,
                        x_new_commissionable_flag      => l_commissionable_flag_n ,
                        x_old_commissionable_flag      => l_commissionable_flag ,
                        x_new_hold_reason_code         => l_hold_reason_code_n ,
                        x_old_hold_reason_code         => l_hold_reason_code  ,
                        x_new_hold_payment             => l_hold_payment_n ,
                        x_old_hold_payment             => l_hold_payment ,
                        x_new_comp_service_team_id     => l_comp_service_team_id_n ,
                        x_old_comp_service_team_id     => l_comp_service_team_id ,
                        x_new_transaction_number       => l_transaction_number_n ,
                        x_old_transaction_number       => l_transaction_number ,
                        x_new_object_version_number    => l_object_version_number_n ,
                        x_old_object_version_number    => l_object_version_number ,
                        x_new_user_id                  => l_user_id_n,
                        x_old_user_id                  => l_user_id_o,
                        --x_old_location               => p_location,
                        --x_new_location               => p_location,
 			X_NEW_RESOURCE_NAME            => l_resource_name_n,
 			X_OLD_RESOURCE_NAME            => l_resource_name,
 			X_NEW_SOURCE_NAME              => l_source_name_n,
 			X_OLD_SOURCE_NAME              => l_source_name,
 			X_NEW_SOURCE_NUMBER            => l_source_number_n,
 			X_OLD_SOURCE_NUMBER            => l_source_number,
 			X_NEW_SOURCE_JOB_TITLE         => l_source_job_title_n,
 			X_OLD_SOURCE_JOB_TITLE         => l_source_job_title,
 			X_NEW_SOURCE_EMAIL             => l_source_email_n,
 			X_OLD_SOURCE_EMAIL             => l_source_email,
 			X_NEW_SOURCE_PHONE             => l_source_phone_n,
 			X_OLD_SOURCE_PHONE             => l_source_phone,
 			X_NEW_SOURCE_ORG_ID            => l_source_org_id_n,
 			X_OLD_SOURCE_ORG_ID            => l_source_org_id,
			X_NEW_SOURCE_ORG_NAME          => l_source_org_name_n,
 			X_OLD_SOURCE_ORG_NAME          => l_source_org_name,
 			X_NEW_SOURCE_ADDRESS1          => l_source_address1_n,
 			X_OLD_SOURCE_ADDRESS1          => l_source_address1,
 			X_NEW_SOURCE_ADDRESS2          => l_source_address2_n,
 			X_OLD_SOURCE_ADDRESS2          => l_source_address2,
 			X_NEW_SOURCE_ADDRESS3          => l_source_address3_n,
 			X_OLD_SOURCE_ADDRESS3          => l_source_address3,
 			X_NEW_SOURCE_ADDRESS4          => l_source_address4_n,
 			X_OLD_SOURCE_ADDRESS4          => l_source_address4,
 			X_NEW_SOURCE_CITY              => l_source_city_n,
 			X_OLD_SOURCE_CITY              => l_source_city,
 			X_NEW_SOURCE_POSTAL_CODE       => l_source_postal_code_n,
 			X_OLD_SOURCE_POSTAL_CODE       => l_source_postal_code,
 			X_NEW_SOURCE_STATE             => l_source_state_n,
 			X_OLD_SOURCE_STATE             => l_source_state,
 			X_NEW_SOURCE_PROVINCE          => l_source_province_n,
 			X_OLD_SOURCE_PROVINCE          => l_source_province,
 			X_NEW_SOURCE_COUNTY            => l_source_county_n,
 			X_OLD_SOURCE_COUNTY            => l_source_county,
 			X_NEW_SOURCE_COUNTRY           => l_source_country_n,
 			X_OLD_SOURCE_COUNTRY           => l_source_country,
 			X_NEW_SOURCE_MGR_ID            => l_source_mgr_id_n,
 			X_OLD_SOURCE_MGR_ID            => l_source_mgr_id,
 			X_NEW_SOURCE_MGR_NAME          => l_source_mgr_name_n,
 			X_OLD_SOURCE_MGR_NAME          => l_source_mgr_name,
 			X_NEW_SOURCE_BUSINESS_GRP_ID   => l_source_business_grp_id_n,
 			X_OLD_SOURCE_BUSINESS_GRP_ID   => l_source_business_grp_id,
 			X_NEW_SOURCE_BUSINESS_GRP_NAME => l_source_business_grp_name_n,
 			X_OLD_SOURCE_BUSINESS_GRP_NAME => l_source_business_grp_name,
 			X_NEW_SOURCE_FIRST_NAME        => l_source_first_name_n,
 			X_OLD_SOURCE_FIRST_NAME        => l_source_first_name,
 			X_NEW_SOURCE_MIDDLE_NAME       => l_source_middle_name_n,
 			X_OLD_SOURCE_MIDDLE_NAME       => l_source_middle_name,
 			X_NEW_SOURCE_LAST_NAME         => l_source_last_name_n,
 			X_OLD_SOURCE_LAST_NAME         => l_source_last_name,
 			X_NEW_SOURCE_CATEGORY          => l_source_category_n,
 			X_OLD_SOURCE_CATEGORY          => l_source_category,
 			X_NEW_SOURCE_STATUS            => l_source_status_n,
 			X_OLD_SOURCE_STATUS            => l_source_status,
 			X_NEW_SOURCE_OFFICE            => l_source_office_n,
 			X_OLD_SOURCE_OFFICE            => l_source_office,
 			X_NEW_SOURCE_LOCATION          => l_source_location_n,
 			X_OLD_SOURCE_LOCATION          => l_source_location,
 			X_NEW_SOURCE_MAILSTOP          => l_source_mailstop_n,
 			X_OLD_SOURCE_MAILSTOP          => l_source_mailstop,
 			X_NEW_USER_NAME                => l_user_name_n,
 			X_OLD_USER_NAME                => l_user_name,
 			X_NEW_SOURCE_JOB_ID            => l_source_job_id_n,
 			X_OLD_SOURCE_JOB_ID            => l_source_job_id,
 			X_NEW_PARTY_ID                 => l_party_id_n,
 			X_OLD_PARTY_ID                 => l_party_id,
                        X_CREATION_DATE                => l_date,
                        X_CREATED_BY                   => l_user_id,
                        X_LAST_UPDATE_DATE             => l_date,
                        X_LAST_UPDATED_BY              => l_user_id,
                        X_LAST_UPDATE_LOGIN            => l_login_id,
 			X_NEW_SOURCE_MOBILE_PHONE      => l_source_mobile_phone_n,
 			X_OLD_SOURCE_MOBILE_PHONE      => l_source_mobile_phone,
 			X_NEW_SOURCE_PAGER             => l_source_pager_n,
 			X_OLD_SOURCE_PAGER             => l_source_pager
                        );


  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


 EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    END UPDATE_RESOURCE;


/* DELETE procedure modified for Resource Synchronization */

    PROCEDURE   DELETE_RESOURCE(
    P_API_VERSION	IN  NUMBER,
    P_INIT_MSG_LIST	IN  VARCHAR2,
    P_COMMIT		IN  VARCHAR2,
    P_RESOURCE_ID       IN  NUMBER,
    X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT         OUT NOCOPY NUMBER,
    X_MSG_DATA          OUT NOCOPY VARCHAR2 )
    IS

    CURSOR rr_old_cur(l_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
        IS
    SELECT   category
             ,resource_number
             ,source_id
             ,address_id
             ,contact_id
             ,managing_employee_id
             ,start_date_active
             ,end_date_active
             ,time_zone
             ,cost_per_hr
             ,primary_language
             ,secondary_language
             ,support_site_id
             ,ies_agent_login
             ,server_group_id
             ,assigned_to_group_id
             ,cost_center
             ,charge_to_cost_center
             ,compensation_currency_code
             ,commissionable_flag
             ,hold_reason_code
             ,hold_payment
             ,comp_service_team_id
             ,transaction_number
             ,object_version_number
            -- ,location
             ,user_id
             , RESOURCE_NAME
             , SOURCE_NAME
             , SOURCE_NUMBER
             , SOURCE_JOB_TITLE
             , SOURCE_EMAIL
             , SOURCE_PHONE
             , SOURCE_ORG_ID
             , SOURCE_ORG_NAME
             , SOURCE_ADDRESS1
             , SOURCE_ADDRESS2
             , SOURCE_ADDRESS3
             , SOURCE_ADDRESS4
             , SOURCE_CITY
             , SOURCE_POSTAL_CODE
             , SOURCE_STATE
             , SOURCE_PROVINCE
             , SOURCE_COUNTY
             , SOURCE_COUNTRY
             , SOURCE_MGR_ID
             , SOURCE_MGR_NAME
             , SOURCE_BUSINESS_GRP_ID
             , SOURCE_BUSINESS_GRP_NAME
            , SOURCE_FIRST_NAME
            , SOURCE_LAST_NAME
             , SOURCE_MIDDLE_NAME
            , SOURCE_CATEGORY
             , SOURCE_STATUS
             , SOURCE_OFFICE
             , SOURCE_LOCATION
             , SOURCE_MAILSTOP
             , USER_NAME
             , SOURCE_MOBILE_PHONE
             , SOURCE_PAGER
      FROM  jtf_rs_resource_extns_vl
     WHERE  resource_id = l_resource_id;

     --declare variables
--old value
        l_resource_number               jtf_rs_resource_extns.resource_number%type;
        l_category                      jtf_rs_resource_extns.category%type;
        l_source_id                     jtf_rs_resource_extns.source_id%type  ;
        l_address_id                    jtf_rs_resource_extns.address_id%type  ;
        l_contact_id                    jtf_rs_resource_extns.contact_id%type  ;
        l_managing_emp_id               jtf_rs_resource_extns.managing_employee_id%type   ;
        l_start_date_active             jtf_rs_resource_extns.start_date_active%type;
        l_end_date_active               jtf_rs_resource_extns.end_date_active%type   ;
        l_time_zone                     jtf_rs_resource_extns.time_zone%type   ;
        l_cost_per_hr                   jtf_rs_resource_extns.cost_per_hr%type  ;
        l_primary_language              jtf_rs_resource_extns.primary_language%type   ;
        l_secondary_language            jtf_rs_resource_extns.secondary_language%type   ;
        l_support_site_id               jtf_rs_resource_extns.support_site_id%type   ;
        l_ies_agent_login               jtf_rs_resource_extns.ies_agent_login%type   ;
        l_server_group_id               jtf_rs_resource_extns.server_group_id%type   ;
        l_assigned_to_group_id          jtf_rs_resource_extns.assigned_to_group_id%type   ;
        l_cost_center                   jtf_rs_resource_extns.cost_center%type   ;
        l_charge_to_cost_center         jtf_rs_resource_extns.charge_to_cost_center%type   ;
        l_comp_currency_code            jtf_rs_resource_extns.compensation_currency_code%type   ;
        l_commissionable_flag           jtf_rs_resource_extns.commissionable_flag%type   ;
        l_hold_reason_code              jtf_rs_resource_extns.hold_reason_code%type   ;
        l_hold_payment                  jtf_rs_resource_extns.hold_payment%type  ;
        l_comp_service_team_id          jtf_rs_resource_extns.comp_service_team_id%type   ;
        --l_location                      mdsys.sdo_geometry   ;
        l_transaction_number            number;
        l_object_version_number         number;
        l_user_id_o                     jtf_rs_resource_extns.user_id%type;

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
    	l_source_first_name        jtf_rs_resource_extns.source_first_name%type  ;
    	l_source_middle_name       jtf_rs_resource_extns.source_middle_name%type ;
    	l_source_last_name         jtf_rs_resource_extns.source_last_name%type  ;
    	l_source_category          jtf_rs_resource_extns.source_category%type  ;
    	l_source_status            jtf_rs_resource_extns.source_status%type ;
    	l_source_office            jtf_rs_resource_extns.source_office%type ;
    	l_source_location          jtf_rs_resource_extns.source_location%type ;
    	l_source_mailstop          jtf_rs_resource_extns.source_mailstop%type ;
    	l_source_mobile_phone      jtf_rs_resource_extns.source_mobile_phone%type ;
    	l_source_pager             jtf_rs_resource_extns.source_pager%type ;
    	l_user_name                jtf_rs_resource_extns.user_name%type ;


rr_old_rec    rr_old_cur%rowtype;
l_resource_extn_aud_id jtf_rs_resource_extn_aud.resource_audit_id%type;
l_row_id        varchar2(24) := null;

--other variables
    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE';
	l_api_version CONSTANT NUMBER	 :=1.0;
    l_date  Date  := sysdate;
    l_user_id  Number := 1;
    l_login_id  Number := 1;


    BEGIN

    --Standard Start of API SAVEPOINT
	SAVEPOINT RESOURCE_EXTN_AUDIT;

     x_return_status := fnd_api.g_ret_sts_success;

	--Standard Call to check  API compatibility
	IF NOT FND_API.Compatible_API_CALL(l_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
	IF FND_API.To_boolean(P_INIT_MSG_LIST)
	THEN
           FND_MSG_PUB.Initialize;
	END IF;

   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


  open rr_old_cur(p_resource_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    l_category :=  rr_old_rec.category;
    l_resource_number :=  rr_old_rec.resource_number;
    l_source_id       :=  rr_old_rec.source_id;
    l_address_id      :=  rr_old_rec.address_id;
    l_contact_id      :=  rr_old_rec.contact_id;
    l_managing_emp_id  :=  rr_old_rec.managing_employee_id;
    l_start_date_active   :=  rr_old_rec.start_date_active;
    l_end_date_active     :=  rr_old_rec.end_date_active;
    l_time_zone  :=  rr_old_rec.time_zone;
    l_cost_per_hr :=  rr_old_rec.cost_per_hr;
    l_primary_language :=  rr_old_rec.primary_language;
    l_secondary_language  :=  rr_old_rec.secondary_language;
    l_support_site_id :=  rr_old_rec.support_site_id;
    l_ies_agent_login      :=  rr_old_rec.ies_agent_login;
    l_server_group_id       :=  rr_old_rec.server_group_id;
    l_assigned_to_group_id   :=  rr_old_rec.assigned_to_group_id;
    l_cost_center            :=  rr_old_rec.cost_center;
    l_charge_to_cost_center  :=  rr_old_rec.charge_to_cost_center;
    l_comp_currency_code     :=  rr_old_rec.compensation_currency_code ;
    l_commissionable_flag    :=  rr_old_rec.commissionable_flag;
    l_hold_reason_code      :=  rr_old_rec.hold_reason_code;
    l_hold_payment          :=  rr_old_rec.hold_payment;
    l_comp_service_team_id   :=  rr_old_rec.comp_service_team_id;
    --l_location              :=  rr_old_rec.location;
    l_transaction_number  :=  rr_old_rec.transaction_number;
    l_object_version_number :=  rr_old_rec.object_version_number;
    l_user_id_o             := rr_old_rec.user_id;
    l_resource_name           := rr_old_rec.resource_name;
    l_source_name             := rr_old_rec.source_name;
    l_source_number           := rr_old_rec.source_number;
    l_source_job_title        := rr_old_rec.source_job_title;
    l_source_email            := rr_old_rec.source_email;
    l_source_phone            := rr_old_rec.source_phone;
    l_source_org_id           := rr_old_rec.source_org_id;
    l_source_org_name         := rr_old_rec.source_org_name;
    l_source_address1         := rr_old_rec.source_address1;
    l_source_address2         := rr_old_rec.source_address2;
    l_source_address3         := rr_old_rec.source_address3;
    l_source_address4         := rr_old_rec.source_address4;
    l_source_city             := rr_old_rec.source_city;
    l_source_postal_code      := rr_old_rec.source_postal_code;
    l_source_state            := rr_old_rec.source_state;
    l_source_province         := rr_old_rec.source_province;
    l_source_county           := rr_old_rec.source_county;
    l_source_country          := rr_old_rec.source_country;
    l_source_mgr_id           := rr_old_rec.source_mgr_id;
    l_source_mgr_name         := rr_old_rec.source_mgr_name;
    l_source_business_grp_id  := rr_old_rec.source_business_grp_id;
    l_source_business_grp_name := rr_old_rec.source_business_grp_name;
    l_source_first_name := rr_old_rec.source_first_name;
    l_source_middle_name := rr_old_rec.source_middle_name;
    l_source_last_name := rr_old_rec.source_last_name;
    l_source_category := rr_old_rec.source_category;
    l_source_status := rr_old_rec.source_status;
    l_source_office := rr_old_rec.source_office;
    l_source_location := rr_old_rec.source_location;
    l_source_mailstop := rr_old_rec.source_mailstop;
    l_source_mobile_phone := rr_old_rec.source_mobile_phone;
    l_source_pager := rr_old_rec.source_pager;
    l_user_name := rr_old_rec.user_name;


   select jtf_rs_resource_extn_aud_s.nextval
     into l_resource_extn_aud_id
     from dual;

   --CALL TABLE HANDLER
   JTF_RS_RESOURCE_EXTN_AUD_PKG.INSERT_ROW (
                      X_ROWID                        => l_row_id,
                        x_resource_audit_id            =>  l_resource_extn_aud_id,
                        x_resource_id                  =>  p_resource_id,
                        x_new_category                 =>  null,
                        x_old_category                 =>  l_category,
                        x_new_resource_number          =>  null,
                        x_old_resource_number          => l_resource_number ,
                        x_new_source_id                =>  null,
                        x_old_source_id                =>  l_source_id,
                        x_new_address_id               =>  null,
                        x_old_address_id               => l_address_id,
                        x_new_contact_id               =>  null,
                        x_old_contact_id               => l_contact_id,
                        x_new_managing_employee_id     =>  null,
                        x_old_managing_employee_id     => l_managing_emp_id,
                        x_new_start_date_active        =>  null,
                        x_old_start_date_active        => l_start_date_active,
                        x_new_end_date_active        =>  null,
                        x_old_end_date_active        => l_end_date_active,
                        x_new_time_zone                =>  null,
                        x_old_time_zone                => l_time_zone,
                        x_new_cost_per_hr              =>  null,
                        x_old_cost_per_hr              => l_cost_per_hr,
                        x_new_primary_language         =>   null,
                        x_old_primary_language         =>l_primary_language,
                        x_new_secondary_language       =>  null,
                        x_old_secondary_language       => l_secondary_language,
                        x_new_support_site_id          =>  null,
                        x_old_support_site_id          => l_support_site_id,
                        x_new_ies_agent_login          =>  null,
                        x_old_ies_agent_login          => l_ies_agent_login,
                        x_new_server_group_id          =>  null,
                        x_old_server_group_id          => l_server_group_id,
                        x_new_assigned_to_group_id     =>  null,
                        x_old_assigned_to_group_id     =>l_assigned_to_group_id,
                        x_new_cost_center              =>  null,
                        x_old_cost_center              => l_cost_center,
                        x_new_charge_to_cost_center    =>  null,
                        x_old_charge_to_cost_center    => l_charge_to_cost_center,
                        x_new_compensation_currency_co =>  null,
                        x_old_compensation_currency_co => l_comp_currency_code,
                        x_new_commissionable_flag      =>  null,
                        x_old_commissionable_flag      => l_commissionable_flag,
                        x_new_hold_reason_code         =>  null,
                        x_old_hold_reason_code         => l_hold_reason_code,
                        x_new_hold_payment             =>  null,
                        x_old_hold_payment             => l_hold_payment,
                        x_new_comp_service_team_id     => null,
                        x_old_comp_service_team_id     => l_comp_service_team_id,
                        x_new_transaction_number       =>  null,
                        x_old_transaction_number       => l_transaction_number,
                        x_new_object_version_number    =>  null,
                        x_old_object_version_number    => l_object_version_number,
                        x_new_user_id                  => null,
                        x_old_user_id                  => l_user_id_o,
                        --x_old_location                 => L_location,
                        --x_new_location                 => null,
 			X_NEW_RESOURCE_NAME            => null,
 			X_OLD_RESOURCE_NAME            => l_resource_name,
 			X_NEW_SOURCE_NAME              => null,
 			X_OLD_SOURCE_NAME              => l_source_name,
 			X_NEW_SOURCE_NUMBER            => null,
 			X_OLD_SOURCE_NUMBER            => l_source_number,
 			X_NEW_SOURCE_JOB_TITLE         => null,
 			X_OLD_SOURCE_JOB_TITLE         => l_source_job_title,
 			X_NEW_SOURCE_EMAIL             => null,
 			X_OLD_SOURCE_EMAIL             => l_source_email,
 			X_NEW_SOURCE_PHONE             => null,
 			X_OLD_SOURCE_PHONE             => l_source_phone,
 			X_NEW_SOURCE_ORG_ID            => null,
 			X_OLD_SOURCE_ORG_ID            => l_source_org_id,
			X_NEW_SOURCE_ORG_NAME          => null,
 			X_OLD_SOURCE_ORG_NAME          => l_source_org_name,
 			X_NEW_SOURCE_ADDRESS1          => null,
 			X_OLD_SOURCE_ADDRESS1          => l_source_address1,
 			X_NEW_SOURCE_ADDRESS2          => null,
 			X_OLD_SOURCE_ADDRESS2          => l_source_address2,
 			X_NEW_SOURCE_ADDRESS3          => null,
 			X_OLD_SOURCE_ADDRESS3          => l_source_address3,
 			X_NEW_SOURCE_ADDRESS4          => null,
 			X_OLD_SOURCE_ADDRESS4          => l_source_address4,
 			X_NEW_SOURCE_CITY              => null,
 			X_OLD_SOURCE_CITY              => l_source_city,
 			X_NEW_SOURCE_POSTAL_CODE       => null,
 			X_OLD_SOURCE_POSTAL_CODE       => l_source_postal_code,
 			X_NEW_SOURCE_STATE             => null,
 			X_OLD_SOURCE_STATE             => l_source_state,
 			X_NEW_SOURCE_PROVINCE          => null,
 			X_OLD_SOURCE_PROVINCE          => l_source_province,
 			X_NEW_SOURCE_COUNTY            => null,
 			X_OLD_SOURCE_COUNTY            => l_source_county,
 			X_NEW_SOURCE_COUNTRY           => null,
 			X_OLD_SOURCE_COUNTRY           => l_source_country,
 			X_NEW_SOURCE_MGR_ID            => null,
 			X_OLD_SOURCE_MGR_ID            => l_source_mgr_id,
 			X_NEW_SOURCE_MGR_NAME          => null,
 			X_OLD_SOURCE_MGR_NAME          => l_source_mgr_name,
 			X_NEW_SOURCE_BUSINESS_GRP_ID   => null,
 			X_OLD_SOURCE_BUSINESS_GRP_ID   => l_source_business_grp_id,
 			X_NEW_SOURCE_BUSINESS_GRP_NAME => null,
 			X_OLD_SOURCE_BUSINESS_GRP_NAME => l_source_business_grp_name,
 			X_NEW_SOURCE_FIRST_NAME => null,
 			X_OLD_SOURCE_FIRST_NAME => l_source_first_name,
 			X_NEW_SOURCE_MIDDLE_NAME => null,
 			X_OLD_SOURCE_MIDDLE_NAME => l_source_middle_name,
 			X_NEW_SOURCE_LAST_NAME => null,
 			X_OLD_SOURCE_LAST_NAME => l_source_last_name,
 			X_NEW_SOURCE_CATEGORY => null,
 			X_OLD_SOURCE_CATEGORY => l_source_category,
 			X_NEW_SOURCE_STATUS => null,
 			X_OLD_SOURCE_STATUS => l_source_status,
 			X_NEW_SOURCE_OFFICE => null,
 			X_OLD_SOURCE_OFFICE => l_source_office,
 			X_NEW_SOURCE_LOCATION => null,
 			X_OLD_SOURCE_LOCATION => l_source_location,
 			X_NEW_SOURCE_MAILSTOP => null,
 			X_OLD_SOURCE_MAILSTOP => l_source_mailstop,
 			X_NEW_USER_NAME => null,
 			X_OLD_USER_NAME => l_user_name,
                        X_CREATION_DATE                => l_date,
                        X_CREATED_BY                   => l_user_id,
                        X_LAST_UPDATE_DATE             => l_date,
                        X_LAST_UPDATED_BY              => l_user_id,
                        X_LAST_UPDATE_LOGIN            => l_login_id,
 			X_NEW_SOURCE_MOBILE_PHONE => null,
 			X_OLD_SOURCE_MOBILE_PHONE => l_source_mobile_phone,
 			X_NEW_SOURCE_PAGER => null,
 			X_OLD_SOURCE_PAGER => l_source_pager
                        );


  IF fnd_api.to_boolean (p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


 EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO resource_extn_audit;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_RES_AUD_AUD_ERR');
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    END DELETE_RESOURCE;
END; -- Package Body JTF_RS_RESOURCE_EXTNS_AUD_PVT

/
