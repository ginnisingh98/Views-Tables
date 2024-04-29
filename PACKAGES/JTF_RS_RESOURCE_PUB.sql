--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsprs.pls 120.0 2005/05/11 08:21:20 appldev ship $ */
/*#
 * Resource create/update/delete API
 * This API contains the procedures to insert, update and delete Resource record.
 * @rep:scope public
 * @rep:product JTF
 * @rep:displayname Resource API
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
 * @rep:businessevent oracle.apps.jtf.jres.resource.create
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.user
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.effectivedate
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.attributes
 * @rep:businessevent oracle.apps.jtf.jres.resource.delete
*/
  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resources.
   Its main procedures are as following:
   Create Resource
   Update Resource
   Calls to these procedures will invoke procedures from jtf_resource_pvt
   to do business validations and to do actual inserts and updates into tables.
   ******************************************************************************************/


   /*G_MISS_LOCATION        MDSYS.SDO_GEOMETRY := mdsys.sdo_geometry(fnd_api.g_miss_num, null, null,

mdsys.sdo_elem_info_array(null),


mdsys.sdo_ordinate_array(null));*/


  /* Procedure to create the resource based on input values passed by calling routines. */

/*#
 * Get workflow role for a given resouurce
 * This function returns the workflow role for a given resource.
 * @param resource_id Resource Id
 * @return Workflow Role
 * @rep:scope internal
 * @rep:displayname Get Workflow Role for a Resource
*/
  Function  get_wf_role ( resource_id in number )
     RETURN  varchar2 ;

/*#
 * Create Resource API
 * This procedure allows the user to create a resource record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_category Category of the Resource
 * @param p_source_id Source identifier of the Resource
 * @param p_address_id Resource address
 * @param p_contact_id Resource contact identifier
 * @param p_managing_emp_id Identifier for the manager of the resource
 * @param p_managing_emp_num Employee number of the resources manager
 * @param p_start_date_active Date on which the resource becomes active. This value can not be NULL, and the start date must be less than the end date.
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param p_time_zone Time zone, this value must be a valid time zone as defined in table HZ_TIMEZONES.
 * @param p_cost_per_hr The salary cost per hour for this resource. This value is used in conjunction with the p_comp_currency_code parameter.
 * @param p_primary_language The resource's primary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_secondary_language The resource's secondary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_support_site_id Value used by the Service applications.
 * @param p_ies_agent_login Value used by Interaction Center applications (if using Oracle Scripting).
 * @param p_server_group_id Value used by Interaction Center applications
 * @param p_interaction_center_name Value used by Interaction Center applications
 * @param p_assigned_to_group_id The group to which this resource is assigned
 * @param p_cost_center The cost center to which this resource is assigned
 * @param p_charge_to_cost_center Cost center to charge against, this may be different than the resource's current cost center.
 * @param p_comp_currency_code Compensation currency type. This value must be a valid currency code as listed in table FND_CURRENCIES.
 * @param p_commissionable_flag Whether this resource is eligible for a commission or not.
 * @param p_hold_reason_code The reason that compensation is being withheld
 * @param p_hold_payment Whether Withhold compensation or not
 * @param p_comp_service_team_id The identifier for the team to which this resource belongs
 * @param p_user_id User Id of the Resource
 * @param p_transaction_number Transaction identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_resource_id Out parameter for Resource Identifier
 * @param x_resource_number Out parameter for Resource Number
 * @rep:scope internal
 * @rep:lifecycle obsolete
 * @rep:displayname Create Resource API
*/
  PROCEDURE  create_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
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
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE   DEFAULT  'Y',
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE   DEFAULT  NULL,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE   DEFAULT  'N',
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE   DEFAULT  NULL,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE   DEFAULT  NULL,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE   DEFAULT  NULL,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   DEFAULT  NULL,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE
   );

  --Create Resource Migration API, used for one-time migration of resource data
  --The API includes RESOURCE_ID as one of its Input Parameters

/*#
 * Create Resource Migration API
 * This procedure used for one-time migration of resource data
 * The API includes RESOURCE_ID as one of its Input Parameters
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource identifier
 * @param p_category Category of the Resource
 * @param p_source_id Source identifier of the Resource
 * @param p_address_id Resource address
 * @param p_contact_id Resource contact identifier
 * @param p_managing_emp_id Identifier for the manager of the resource
 * @param p_managing_emp_num Employee number of the resources manager
 * @param p_start_date_active Date on which the resource becomes active. This value can not be NULL, and the start date must be less than the end date.
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param p_time_zone Time zone, this value must be a valid time zone as defined in table HZ_TIMEZONES.
 * @param p_cost_per_hr The salary cost per hour for this resource. This value is used in conjunction with the p_comp_currency_code parameter.
 * @param p_primary_language The resource's primary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_secondary_language The resource's secondary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_support_site_id Value used by the Service applications.
 * @param p_ies_agent_login Value used by Interaction Center applications (if using Oracle Scripting).
 * @param p_server_group_id Value used by Interaction Center applications
 * @param p_interaction_center_name Value used by Interaction Center applications
 * @param p_assigned_to_group_id The group to which this resource is assigned
 * @param p_cost_center The cost center to which this resource is assigned
 * @param p_charge_to_cost_center Cost center to charge against, this may be different than the resource's current cost center.
 * @param p_comp_currency_code Compensation currency type. This value must be a valid currency code as listed in table FND_CURRENCIES.
 * @param p_commissionable_flag Whether this resource is eligible for a commission or not.
 * @param p_hold_reason_code The reason that compensation is being withheld
 * @param p_hold_payment Whether Withhold compensation or not
 * @param p_comp_service_team_id The identifier for the team to which this resource belongs
 * @param p_user_id User Id of the Resource
 * @param p_transaction_number Transaction identifier
 * @param p_attribute1 Descriptive flexfield Segment 1
 * @param p_attribute2 Descriptive flexfield Segment 2
 * @param p_attribute3 Descriptive flexfield Segment 3
 * @param p_attribute4 Descriptive flexfield Segment 4
 * @param p_attribute5 Descriptive flexfield Segment 5
 * @param p_attribute6 Descriptive flexfield Segment 6
 * @param p_attribute7 Descriptive flexfield Segment 7
 * @param p_attribute8 Descriptive flexfield Segment 8
 * @param p_attribute9 Descriptive flexfield Segment 9
 * @param p_attribute10 Descriptive flexfield Segment 10
 * @param p_attribute11 Descriptive flexfield Segment 11
 * @param p_attribute12 Descriptive flexfield Segment 12
 * @param p_attribute13 Descriptive flexfield Segment 13
 * @param p_attribute14 Descriptive flexfield Segment 14
 * @param p_attribute15 Descriptive flexfield Segment 15
 * @param p_attribute_category Descriptive flexfield structure definition column
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_resource_id Out parameter for Resource Identifier
 * @param x_resource_number Out parameter for Resource Number
 * @rep:scope internal
 * @rep:lifecycle obsolete
 * @rep:displayname Create Resource Migration API
*/
  PROCEDURE  create_resource_migrate
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   					DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   					DEFAULT  FND_API.G_FALSE,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE   	DEFAULT  NULL,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE   	DEFAULT  NULL,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE   	DEFAULT  NULL,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   	DEFAULT  NULL,
   P_MANAGING_EMP_NUM        IN   PER_EMPLOYEES_CURRENT_X.EMPLOYEE_NUM%TYPE   	DEFAULT  NULL,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   	DEFAULT  NULL,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE   	DEFAULT  NULL,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE   	DEFAULT  NULL,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE   DEFAULT  NULL,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE DEFAULT  NULL,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE   	DEFAULT  NULL,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE   	DEFAULT  NULL,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE   	DEFAULT  NULL,
   P_INTERACTION_CENTER_NAME IN   VARCHAR2   					DEFAULT  NULL,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE 	DEFAULT  NULL,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE   		DEFAULT  NULL,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE 	DEFAULT NULL,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE DEFAULT NULL,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE DEFAULT  'Y',
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE   DEFAULT  NULL,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE   	DEFAULT  'N',
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE   	DEFAULT  NULL,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE   		DEFAULT  NULL,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE DEFAULT  NULL,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   				DEFAULT  NULL,
   P_RESOURCE_ID	     IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE  	DEFAULT  NULL,
   P_ATTRIBUTE1              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE1%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE2              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE2%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE3              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE3%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE4              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE4%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE5              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE5%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE6              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE6%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE7              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE7%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE8              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE8%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE9              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE9%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE10             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE10%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE11             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE11%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE12             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE12%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE13             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE13%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE14             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE14%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE15             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE15%TYPE   	DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE DEFAULT  NULL,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE
  );

  --Creating a Global Variable to be used for setting the flag,
  --when the create_resource_migrate gets called

    G_RS_ID_PUB_FLAG		VARCHAR2(1)					:= 'Y';
    G_RESOURCE_ID		JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE		:= NULL;
    G_ATTRIBUTE1                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE1%TYPE   	:= NULL;
    G_ATTRIBUTE2                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE2%TYPE   	:= NULL;
    G_ATTRIBUTE3                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE3%TYPE   	:= NULL;
    G_ATTRIBUTE4                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE4%TYPE   	:= NULL;
    G_ATTRIBUTE5                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE5%TYPE   	:= NULL;
    G_ATTRIBUTE6                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE6%TYPE   	:= NULL;
    G_ATTRIBUTE7                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE7%TYPE   	:= NULL;
    G_ATTRIBUTE8                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE8%TYPE   	:= NULL;
    G_ATTRIBUTE9                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE9%TYPE   	:= NULL;
    G_ATTRIBUTE10               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE10%TYPE  	:= NULL;
    G_ATTRIBUTE11               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE11%TYPE  	:= NULL;
    G_ATTRIBUTE12               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE12%TYPE  	:= NULL;
    G_ATTRIBUTE13               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE13%TYPE  	:= NULL;
    G_ATTRIBUTE14               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE14%TYPE  	:= NULL;
    G_ATTRIBUTE15               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE15%TYPE  	:= NULL;
    G_ATTRIBUTE_CATEGORY        JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE   := NULL;

  /* Procedure to update the resource based on input values passed by calling routines. */

/*#
 * Update Resource API
 * This procedure allows the user to update a resource record
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_resource_number Resource Number
 * @param p_managing_emp_id Identifier for the manager of the resource
 * @param p_start_date_active Date on which the resource becomes active. This value can not be NULL, and the start date must be less than the end date.
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param p_time_zone Time zone, this value must be a valid time zone as defined in table HZ_TIMEZONES.
 * @param p_cost_per_hr The salary cost per hour for this resource. This value is used in conjunction with the p_comp_currency_code parameter.
 * @param p_primary_language The resource's primary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_secondary_language The resource's secondary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_support_site_id Value used by the Service applications.
 * @param p_ies_agent_login Value used by Interaction Center applications (if using Oracle Scripting).
 * @param p_server_group_id Value used by Interaction Center applications
 * @param p_assigned_to_group_id The group to which this resource is assigned
 * @param p_cost_center The cost center to which this resource is assigned
 * @param p_charge_to_cost_center Cost center to charge against, this may be different than the resource's current cost center.
 * @param p_comp_currency_code Compensation currency type. This value must be a valid currency code as listed in table FND_CURRENCIES.
 * @param p_commissionable_flag Whether this resource is eligible for a commission or not.
 * @param p_hold_reason_code The reason that compensation is being withheld
 * @param p_hold_payment Whether Withhold compensation or not
 * @param p_comp_service_team_id The identifier for the team to which this resource belongs
 * @param p_user_id User Id of the Resource
 * @param p_object_version_num The object version number of the resource derives from the jtf_rs_resource_extns table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle obsolete
 * @rep:displayname Update Resource API
*/
  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER         IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE  DEFAULT FND_API.G_MISS_NUM,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE     DEFAULT FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE       DEFAULT FND_API.G_MISS_DATE,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE             DEFAULT FND_API.G_MISS_NUM,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE           DEFAULT FND_API.G_MISS_NUM,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE      DEFAULT FND_API.G_MISS_CHAR,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE    DEFAULT FND_API.G_MISS_CHAR,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE       DEFAULT FND_API.G_MISS_NUM,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE       DEFAULT FND_API.G_MISS_CHAR,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE       DEFAULT FND_API.G_MISS_NUM,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE  DEFAULT FND_API.G_MISS_NUM,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE           DEFAULT FND_API.G_MISS_CHAR,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE   DEFAULT FND_API.G_MISS_CHAR,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE      DEFAULT FND_API.G_MISS_CHAR,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE          DEFAULT FND_API.G_MISS_CHAR,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE  DEFAULT FND_API.G_MISS_NUM,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE               DEFAULT FND_API.G_MISS_NUM,
   --P_LOCATION              IN   MDSYS.SDO_GEOMETRY                               DEFAULT  G_MISS_LOCATION,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  );


 /* Procedure to delete the resource based on input values passed by calling routines. */

/*#
 * Delete Resource API
 * This is the main Resource delete API
 * This procedure allows the user to delete a TBH resource record
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Resource API
 * @rep:businessevent oracle.apps.jtf.jres.resource.delete
*/
  PROCEDURE  delete_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  );


  /* Procedure to create the resource with the resource synchronizing parameters. */
/*#
 * Create Resource API
 * This is the main Resource create API
 * This procedure allows the user to create a resource record with the resource synchronizing parameters
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_category Category of the Resource
 * @param p_source_id Source identifier of the Resource
 * @param p_address_id Resource address
 * @param p_contact_id Resource contact identifier
 * @param p_managing_emp_id Identifier for the manager of the resource
 * @param p_managing_emp_num Employee number of the resources manager
 * @param p_start_date_active Date on which the resource becomes active. This value can not be NULL, and the start date must be less than the end date.
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param p_time_zone Time zone, this value must be a valid time zone as defined in table HZ_TIMEZONES.
 * @param p_cost_per_hr The salary cost per hour for this resource. This value is used in conjunction with the p_comp_currency_code parameter.
 * @param p_primary_language The resource's primary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_secondary_language The resource's secondary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_support_site_id Value used by the Service applications.
 * @param p_ies_agent_login Value used by Interaction Center applications (if using Oracle Scripting).
 * @param p_server_group_id Value used by Interaction Center applications
 * @param p_interaction_center_name Value used by Interaction Center applications
 * @param p_assigned_to_group_id The group to which this resource is assigned
 * @param p_cost_center The cost center to which this resource is assigned
 * @param p_charge_to_cost_center Cost center to charge against, this may be different than the resource's current cost center.
 * @param p_comp_currency_code Compensation currency type. This value must be a valid currency code as listed in table FND_CURRENCIES.
 * @param p_commissionable_flag Whether this resource is eligible for a commission or not.
 * @param p_hold_reason_code The reason that compensation is being withheld
 * @param p_hold_payment Whether Withhold compensation or not
 * @param p_comp_service_team_id The identifier for the team to which this resource belongs
 * @param p_user_id User Id of the Resource
 * @param p_transaction_number Transaction identifier
 * @param p_resource_name Name of the Resource
 * @param p_source_name Name of the source
 * @param p_source_number Source Number
 * @param p_source_job_title Source job title
 * @param p_source_email Source Email
 * @param p_source_phone Source Phone
 * @param p_source_org_id Source Organization Identifier
 * @param p_source_org_name Source Organization Name
 * @param p_source_address1 Source Address 1
 * @param p_source_address2 Source Address 2
 * @param p_source_address3 Source Address 3
 * @param p_source_address4 Source Address 4
 * @param p_source_city Source City
 * @param p_source_postal_code Source postal code
 * @param p_source_state Source state
 * @param p_source_province Source province
 * @param p_source_county Source County
 * @param p_source_country Source Country
 * @param p_source_mgr_id Source manager Identifier
 * @param p_source_mgr_name Source manager Name
 * @param p_source_business_grp_id Source Business Organization Identifier
 * @param p_source_business_grp_name Source Business Organization Name
 * @param p_source_first_name Source First Name
 * @param p_source_last_name Source Last Name
 * @param p_source_middle_name Source Middle Name
 * @param p_source_category Source Category
 * @param p_source_status Source Status
 * @param p_source_office Source Office
 * @param p_source_location Source Location
 * @param p_source_mailstop Source Mailstop
 * @param p_user_name User Name
 * @param p_source_mobile_phone Source Mobile Phone
 * @param p_source_pager Source Pager
 * @param p_attribute1 Descriptive flexfield Segment 1
 * @param p_attribute2 Descriptive flexfield Segment 2
 * @param p_attribute3 Descriptive flexfield Segment 3
 * @param p_attribute4 Descriptive flexfield Segment 4
 * @param p_attribute5 Descriptive flexfield Segment 5
 * @param p_attribute6 Descriptive flexfield Segment 6
 * @param p_attribute7 Descriptive flexfield Segment 7
 * @param p_attribute8 Descriptive flexfield Segment 8
 * @param p_attribute9 Descriptive flexfield Segment 9
 * @param p_attribute10 Descriptive flexfield Segment 10
 * @param p_attribute11 Descriptive flexfield Segment 11
 * @param p_attribute12 Descriptive flexfield Segment 12
 * @param p_attribute13 Descriptive flexfield Segment 13
 * @param p_attribute14 Descriptive flexfield Segment 14
 * @param p_attribute15 Descriptive flexfield Segment 15
 * @param p_attribute_category Descriptive flexfield structure definition column
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_resource_id Out parameter for Resource Identifier
 * @param x_resource_number Out parameter for Resource Number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:displayname Create Resource API
 * @rep:businessevent oracle.apps.jtf.jres.resource.create
*/
  PROCEDURE  create_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE         DEFAULT  NULL,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE        DEFAULT  NULL,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE        DEFAULT  NULL,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   DEFAULT  NULL,
   P_MANAGING_EMP_NUM        IN   PER_EMPLOYEES_CURRENT_X.EMPLOYEE_NUM%TYPE    DEFAULT  NULL,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE         DEFAULT  NULL,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE       DEFAULT  NULL,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE  DEFAULT  NULL,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE DEFAULT  NULL,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE   DEFAULT  NULL,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE   DEFAULT  NULL,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE   DEFAULT  NULL,
   P_INTERACTION_CENTER_NAME IN   VARCHAR2                                     DEFAULT  NULL,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE DEFAULT  NULL,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE       DEFAULT  NULL,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE DEFAULT NULL,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE DEFAULT NULL,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE DEFAULT  'Y',
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE  DEFAULT  NULL,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE      DEFAULT  'N',
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE DEFAULT  NULL,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE           DEFAULT  NULL,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE DEFAULT  NULL,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY                           DEFAULT  NULL,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE  DEFAULT NULL,
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
   P_SOURCE_ADDRESS4         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS4%TYPE   DEFAULT NULL,
   P_SOURCE_CITY             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_CITY%TYPE       DEFAULT NULL,
   P_SOURCE_POSTAL_CODE      IN   JTF_RS_RESOURCE_EXTNS.SOURCE_POSTAL_CODE%TYPE DEFAULT NULL,
   P_SOURCE_STATE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_STATE%TYPE      DEFAULT NULL,
   P_SOURCE_PROVINCE         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PROVINCE%TYPE   DEFAULT NULL,
   P_SOURCE_COUNTY           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTY%TYPE     DEFAULT NULL,
   P_SOURCE_COUNTRY          IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTRY%TYPE    DEFAULT NULL,
   P_SOURCE_MGR_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_ID%TYPE     DEFAULT NULL,
   P_SOURCE_MGR_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_NAME%TYPE   DEFAULT NULL,
   P_SOURCE_BUSINESS_GRP_ID  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_ID%TYPE DEFAULT NULL,
   P_SOURCE_BUSINESS_GRP_NAME IN  JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_NAME%TYPE DEFAULT NULL,
   P_SOURCE_FIRST_NAME       IN   JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE DEFAULT NULL,
   P_SOURCE_LAST_NAME        IN   JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE  DEFAULT NULL,
   P_SOURCE_MIDDLE_NAME      IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE DEFAULT NULL,
   P_SOURCE_CATEGORY         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE   DEFAULT NULL,
   P_SOURCE_STATUS           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE     DEFAULT NULL,
   P_SOURCE_OFFICE           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE     DEFAULT NULL,
   P_SOURCE_LOCATION         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE   DEFAULT NULL,
   P_SOURCE_MAILSTOP         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE   DEFAULT NULL,
   P_USER_NAME               IN   VARCHAR2                                     DEFAULT NULL,
   P_SOURCE_MOBILE_PHONE     IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE DEFAULT NULL,
   P_SOURCE_PAGER            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE      DEFAULT NULL,
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
   );


 /* Procedure to update the resource with the resource synchronizing parameters. */

  /* Procedure to create the resource with the resource synchronizing parameters. */
/*#
 * Update Resource API
 * This is the main Resource update API
 * This procedure allows the user to update a resource record with the resource synchronizing parameters
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_resource_number Resource Number
 * @param p_managing_emp_id Identifier for the manager of the resource
 * @param p_start_date_active Date on which the resource becomes active. This value can not be NULL, and the start date must be less than the end date.
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param p_time_zone Time zone, this value must be a valid time zone as defined in table HZ_TIMEZONES.
 * @param p_cost_per_hr The salary cost per hour for this resource. This value is used in conjunction with the p_comp_currency_code parameter.
 * @param p_primary_language The resource's primary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_secondary_language The resource's secondary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_support_site_id Value used by the Service applications.
 * @param p_ies_agent_login Value used by Interaction Center applications (if using Oracle Scripting).
 * @param p_server_group_id Value used by Interaction Center applications
 * @param p_assigned_to_group_id The group to which this resource is assigned
 * @param p_cost_center The cost center to which this resource is assigned
 * @param p_charge_to_cost_center Cost center to charge against, this may be different than the resource's current cost center.
 * @param p_comp_currency_code Compensation currency type. This value must be a valid currency code as listed in table FND_CURRENCIES.
 * @param p_commissionable_flag Whether this resource is eligible for a commission or not.
 * @param p_hold_reason_code The reason that compensation is being withheld
 * @param p_hold_payment Whether Withhold compensation or not
 * @param p_comp_service_team_id The identifier for the team to which this resource belongs
 * @param p_user_id User Id of the Resource
 * @param p_resource_name Name of the Resource
 * @param p_source_name Name of the source
 * @param p_source_number Source Number
 * @param p_source_job_title Source job title
 * @param p_source_email Source Email
 * @param p_source_phone Source Phone
 * @param p_source_org_id Source Organization Identifier
 * @param p_source_org_name Source Organization Name
 * @param p_source_address1 Source Address 1
 * @param p_source_address2 Source Address 2
 * @param p_source_address3 Source Address 3
 * @param p_source_address4 Source Address 4
 * @param p_source_city Source City
 * @param p_source_postal_code Source postal code
 * @param p_source_state Source state
 * @param p_source_province Source province
 * @param p_source_county Source County
 * @param p_source_country Source Country
 * @param p_source_mgr_id Source manager Identifier
 * @param p_source_mgr_name Source manager Name
 * @param p_source_business_grp_id Source Business Organization Identifier
 * @param p_source_business_grp_name Source Business Organization Name
 * @param p_source_first_name Source First Name
 * @param p_source_last_name Source Last Name
 * @param p_source_middle_name Source Middle Name
 * @param p_source_category Source Category
 * @param p_source_status Source Status
 * @param p_source_office Source Office
 * @param p_source_location Source Location
 * @param p_source_mailstop Source Mailstop
 * @param p_address_id Resource address
 * @param p_object_version_num The object version number of the resource derives from the jtf_rs_resource_extns table.
 * @param p_user_name User Name
 * @param p_source_mobile_phone Source Mobile Phone
 * @param p_source_pager Source Pager
 * @param p_attribute1 Descriptive flexfield Segment 1
 * @param p_attribute2 Descriptive flexfield Segment 2
 * @param p_attribute3 Descriptive flexfield Segment 3
 * @param p_attribute4 Descriptive flexfield Segment 4
 * @param p_attribute5 Descriptive flexfield Segment 5
 * @param p_attribute6 Descriptive flexfield Segment 6
 * @param p_attribute7 Descriptive flexfield Segment 7
 * @param p_attribute8 Descriptive flexfield Segment 8
 * @param p_attribute9 Descriptive flexfield Segment 9
 * @param p_attribute10 Descriptive flexfield Segment 10
 * @param p_attribute11 Descriptive flexfield Segment 11
 * @param p_attribute12 Descriptive flexfield Segment 12
 * @param p_attribute13 Descriptive flexfield Segment 13
 * @param p_attribute14 Descriptive flexfield Segment 14
 * @param p_attribute15 Descriptive flexfield Segment 15
 * @param p_attribute_category Descriptive flexfield structure definition column
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:displayname Update Resource API
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.user
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.effectivedate
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.attributes
*/
  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2                                          DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2                                          DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER         IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   DEFAULT FND_API.G_MISS_NUM,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE      DEFAULT FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE        DEFAULT FND_API.G_MISS_DATE,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE              DEFAULT FND_API.G_MISS_NUM,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE            DEFAULT FND_API.G_MISS_NUM,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE       DEFAULT FND_API.G_MISS_CHAR,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE     DEFAULT FND_API.G_MISS_CHAR,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE        DEFAULT FND_API.G_MISS_NUM,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE        DEFAULT FND_API.G_MISS_NUM,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE   DEFAULT FND_API.G_MISS_NUM,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE            DEFAULT FND_API.G_MISS_CHAR,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE    DEFAULT FND_API.G_MISS_CHAR,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE       DEFAULT FND_API.G_MISS_CHAR,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE           DEFAULT FND_API.G_MISS_CHAR,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE   DEFAULT FND_API.G_MISS_NUM,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE                DEFAULT FND_API.G_MISS_NUM,
   --P_LOCATION              IN   MDSYS.SDO_GEOMETRY                                DEFAULT  G_MISS_LOCATION,
   P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE       DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_NAME             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
   P_SOURCE_NUMBER           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE          DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_JOB_TITLE        IN   JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_TITLE%TYPE       DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_EMAIL            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE           DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_PHONE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PHONE%TYPE           DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ORG_ID           IN   NUMBER                                            DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_ORG_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_NAME%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ADDRESS1         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS1%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ADDRESS2         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS2%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ADDRESS3         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS3%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ADDRESS4         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS4%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_CITY             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_CITY%TYPE            DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_POSTAL_CODE      IN   JTF_RS_RESOURCE_EXTNS.SOURCE_POSTAL_CODE%TYPE     DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_STATE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_STATE%TYPE           DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_PROVINCE         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PROVINCE%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_COUNTY           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTY%TYPE          DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_COUNTRY          IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTRY%TYPE         DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_MGR_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_ID%TYPE          DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_MGR_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_NAME%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_BUSINESS_GRP_ID  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_ID%TYPE DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_BUSINESS_GRP_NAME IN  JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_NAME%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_FIRST_NAME       IN JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE        DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_LAST_NAME        IN JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE         DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_MIDDLE_NAME      IN JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE       DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_CATEGORY         IN JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE          DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_STATUS           IN JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE            DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_OFFICE           IN JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE            DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_LOCATION         IN JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE          DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_MAILSTOP         IN JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE          DEFAULT FND_API.G_MISS_CHAR,
   P_ADDRESS_ID              IN JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE  DEFAULT FND_API.G_MISS_NUM,
   P_OBJECT_VERSION_NUM      IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   P_USER_NAME               IN VARCHAR2                                            DEFAULT FND_API.G_MISS_CHAR,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   P_SOURCE_MOBILE_PHONE     IN JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE      DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_PAGER            IN JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE             DEFAULT FND_API.G_MISS_CHAR,
   P_ATTRIBUTE1              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE1%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE2%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE3%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE4%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE5%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE6%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE7%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE8%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9              IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE9%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE10%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE11%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE12%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE13%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE14%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15             IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE15%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  FND_API.G_MISS_CHAR
  );


END jtf_rs_resource_pub;

 

/
