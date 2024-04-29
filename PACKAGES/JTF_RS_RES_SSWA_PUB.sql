--------------------------------------------------------
--  DDL for Package JTF_RS_RES_SSWA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RES_SSWA_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrssrs.pls 120.0 2005/05/11 08:22:00 appldev ship $ */
/*#
 * Employee Resource create/update API
 * This API contains the procedures to insert and update Employee Resource record.
 * This procedure will insert/update Employee records in HR,
 * insert/update Employee Resources JTF Resources and
 * insert FND User Record if the User name is not null.
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Employee Resource API
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
*/

  /*****************************************************************************************
   ******************************************************************************************/

  /* Procedure to create the Employee Resource
	based on input values passed by calling routines. */
/*#
 * Create Employee Resource API
 * This procedure will insert Employee records in HR,
 * insert Employee Resources JTF Resources and
 * insert FND User Record if the User name is not null.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_source_first_name Source First Name
 * @param p_source_last_name Source Last Name
 * @param p_source_middle_name Source Middle Name
 * @param p_employee_number Employee Number
 * @param p_source_sex Source Sex
 * @param p_source_title Source title
 * @param p_source_job_id Source job Identifier
 * @param p_source_email Source Email
 * @param p_source_start_date Start date of the Employee
 * @param p_source_end_date End date of the Employee
 * @param p_user_name User Name
 * @param p_source_address_id Source Address Identifier
 * @param p_source_office Source Office
 * @param p_source_mailstop Source Mailstop
 * @param p_source_location Source Location
 * @param p_source_phone Source Phone
 * @param p_salesrep_number Salesperson Number
 * @param p_sales_credit_type_id Sales Credit Identifier
 * @param p_source_mgr_id Source manager Identifier
 * @param p_called_from Where this procedure is called
 * @param p_user_password Password of the User
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_resource_id Out parameter for resource Identifier
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Create Employee Resource API
*/
  PROCEDURE create_emp_resource
 (P_API_VERSION           IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SOURCE_FIRST_NAME    IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_LAST_NAME     IN   VARCHAR2,
   P_SOURCE_MIDDLE_NAME   IN   VARCHAR2   DEFAULT NULL,
   P_EMPLOYEE_NUMBER      IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_SEX           IN   VARCHAR2,
   P_SOURCE_TITLE         IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_JOB_ID        IN   NUMBER  DEFAULT NULL,
   P_SOURCE_EMAIL         IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_START_DATE    IN   DATE,
   P_SOURCE_END_DATE      IN   DATE   DEFAULT NULL,
   P_USER_NAME            IN   VARCHAR2,
   P_SOURCE_ADDRESS_ID    IN   NUMBER   DEFAULT NULL,
   P_SOURCE_OFFICE        IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_MAILSTOP      IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_LOCATION      IN   VARCHAR2   DEFAULT NULL,
   P_SOURCE_PHONE         IN   VARCHAR2   DEFAULT NULL,
   P_SALESREP_NUMBER      IN   VARCHAR2,
   P_SALES_CREDIT_TYPE_ID IN   NUMBER,
   P_SOURCE_MGR_ID        IN   NUMBER   DEFAULT NULL,
   X_RESOURCE_ID          OUT NOCOPY  NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   P_CALLED_FROM          IN   VARCHAR2   DEFAULT NULL,
   P_USER_PASSWORD        IN OUT NOCOPY VARCHAR2
  );


  /* Procedure to create the resource group and the members
	based on input values passed by calling routines. */

/*#
 * Update Employee Resource API
 * This procedure will update Employee records in HR and update Employee Resources JTF Resources
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_resource_number Resource Number
 * @param p_resource_name Resource Name
 * @param p_source_name Source Name
 * @param p_address_id Address Identifier
 * @param p_source_office Source Office
 * @param p_source_mailstop Source Mailstop
 * @param p_source_location Source Location
 * @param p_source_phone Source Phone
 * @param p_source_email Source Email
 * @param p_object_version_number The object version number of the resource derives from the jtf_rs_resource_extns table.
 * @param p_approved Approval required or not
 * @param p_source_job_id Source job Identifier
 * @param p_source_job_title Source job Title
 * @param p_salesrep_number Salesperson Number
 * @param p_sales_credit_type_id Sales Credit Identifier
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param p_user_id User Identifier
 * @param p_user_name User Name
 * @param p_mgr_resource_id Resource Identifier for the manager of the resource
 * @param p_org_id Organization Identifier
 * @param p_time_zone Time zone, this value must be a valid time zone as defined in table HZ_TIMEZONES.
 * @param p_cost_per_hr The salary cost per hour for this resource. This value is used in conjunction with the p_comp_currency_code parameter.
 * @param p_primary_language The resource's primary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_secondary_language The resource's secondary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_support_site_id Value used by the Service applications.
 * @param p_source_mobile_phone Source Mobile Phone
 * @param p_source_pager Source Pager
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Update Employee Resource API
*/
  PROCEDURE update_resource
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   NUMBER,
   P_RESOURCE_NUMBER      IN   VARCHAR2,
   P_RESOURCE_NAME        IN   VARCHAR2  ,
   P_SOURCE_NAME          IN   VARCHAR2  ,
   P_ADDRESS_ID           IN   VARCHAR2  ,
   P_SOURCE_OFFICE        IN   VARCHAR2  ,
   P_SOURCE_MAILSTOP      IN   VARCHAR2  ,
   P_SOURCE_LOCATION      IN   VARCHAR2  ,
   P_SOURCE_PHONE         IN   VARCHAR2  ,
   P_SOURCE_EMAIL         IN   VARCHAR2  ,
   P_OBJECT_VERSION_NUMBER IN  NUMBER,
   P_APPROVED             IN   VARCHAR2 DEFAULT 'N',
   P_SOURCE_JOB_ID        IN   NUMBER  DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_JOB_TITLE     IN   VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
   P_SALESREP_NUMBER      IN   VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
   P_SALES_CREDIT_TYPE_ID IN   NUMBER  DEFAULT FND_API.G_MISS_NUM,
   P_END_DATE_ACTIVE      IN   DATE    DEFAULT FND_API.G_MISS_DATE,
   P_USER_ID              IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
   P_USER_NAME            IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
   P_MGR_RESOURCE_ID      IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
   P_ORG_ID               IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   P_TIME_ZONE            IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
   P_COST_PER_HR          IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
   P_PRIMARY_LANGUAGE     IN   VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
   P_SECONDARY_LANGUAGE   IN   VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
   P_SUPPORT_SITE_ID      IN   NUMBER   DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_MOBILE_PHONE  IN   VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_PAGER         IN   VARCHAR2   DEFAULT FND_API.G_MISS_CHAR
  ) ;

END jtf_rs_res_sswa_pub;

 

/
