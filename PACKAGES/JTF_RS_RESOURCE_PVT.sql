--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_PVT" AUTHID CURRENT_USER AS
  /* $Header: jtfrsvrs.pls 120.0 2005/05/11 08:23:15 appldev ship $ */

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource groups.
   Its main procedures are as following:
   Create Resource
   Update Resource
   Calls to these procedures will invoke calls to table handlers which
   do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

TYPE Resource_Rec_type IS RECORD
              (RESOURCE_ID              JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
               CATEGORY                 JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
               RESOURCE_NAME	        JTF_RS_RESOURCE_EXTNS_VL.RESOURCE_NAME%TYPE,
               USER_ID			JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE,
               START_DATE_ACTIVE	JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
               END_DATE_ACTIVE		JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE,
               TIME_ZONE                JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE,
               COST_PER_HR              JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE,
               PRIMARY_LANGUAGE         JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE,
               SECONDARY_LANGUAGE       JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE,
               IES_AGENT_LOGIN          JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE,
               SERVER_GROUP_ID          JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE,
               ASSIGNED_TO_GROUP_ID     JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE,
               COST_CENTER              JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE,
               CHARGE_TO_COST_CENTER    JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE,
               COMP_CURRENCY_CODE       JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE,
               COMMISSIONABLE_FLAG      JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE,
               HOLD_REASON_CODE         JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE,
               HOLD_PAYMENT             JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE,
               COMP_SERVICE_TEAM_ID     JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE,
               SUPPORT_SITE_ID          JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE
              );


  /* Procedure to create the resource based on input values
	passed by calling routines. */

  PROCEDURE  create_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE   DEFAULT  NULL,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE   DEFAULT  NULL,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE   DEFAULT  NULL,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   DEFAULT  NULL,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE   DEFAULT  NULL,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE   DEFAULT  NULL,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE   DEFAULT  NULL,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE   DEFAULT  NULL,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE   DEFAULT  NULL,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE   DEFAULT  NULL,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE   DEFAULT  NULL,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE   DEFAULT  NULL,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE   DEFAULT  NULL,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE   DEFAULT  NULL,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE   DEFAULT  NULL,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE   DEFAULT  'Y',
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE   DEFAULT  NULL,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE   DEFAULT  'N',
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE   DEFAULT  NULL,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE   DEFAULT  NULL,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE   DEFAULT  NULL,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   DEFAULT  NULL,
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
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE
   );

  /* Procedure to create the resource with the resource synchronizing parameters. */

  PROCEDURE  create_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE   DEFAULT  NULL,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE   DEFAULT  NULL,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE   DEFAULT  NULL,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   DEFAULT  NULL,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE   DEFAULT  NULL,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE   DEFAULT  NULL,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE   DEFAULT  NULL,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE   DEFAULT  NULL,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE   DEFAULT  NULL,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE   DEFAULT  NULL,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE   DEFAULT  NULL,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE   DEFAULT  NULL,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE   DEFAULT  NULL,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE   DEFAULT  NULL,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE   DEFAULT  NULL,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE   DEFAULT  'Y',
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE   DEFAULT  NULL,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE   DEFAULT  'N',
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE   DEFAULT  NULL,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE   DEFAULT  NULL,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE   DEFAULT  NULL,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   DEFAULT  NULL,
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
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE DEFAULT NULL,
   P_SOURCE_NAME             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
   P_SOURCE_NUMBER           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE DEFAULT NULL,
   P_SOURCE_JOB_TITLE        IN   JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_TITLE%TYPE DEFAULT NULL,
   P_SOURCE_EMAIL            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE DEFAULT NULL,
   P_SOURCE_PHONE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PHONE%TYPE DEFAULT NULL,
   P_SOURCE_ORG_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_ID%TYPE DEFAULT NULL,
   P_SOURCE_ORG_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_NAME%TYPE DEFAULT NULL,
   P_SOURCE_ADDRESS1         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS1%TYPE DEFAULT NULL,
   P_SOURCE_ADDRESS2         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS2%TYPE DEFAULT NULL,
   P_SOURCE_ADDRESS3         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS3%TYPE DEFAULT NULL,
   P_SOURCE_ADDRESS4         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS4%TYPE DEFAULT NULL,
   P_SOURCE_CITY             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_CITY%TYPE DEFAULT NULL,
   P_SOURCE_POSTAL_CODE      IN   JTF_RS_RESOURCE_EXTNS.SOURCE_POSTAL_CODE%TYPE DEFAULT NULL,
   P_SOURCE_STATE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_STATE%TYPE DEFAULT NULL,
   P_SOURCE_PROVINCE         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PROVINCE%TYPE DEFAULT NULL,
   P_SOURCE_COUNTY           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTY%TYPE DEFAULT NULL,
   P_SOURCE_COUNTRY          IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTRY%TYPE DEFAULT NULL,
   P_SOURCE_MGR_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_ID%TYPE DEFAULT NULL,
   P_SOURCE_MGR_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_NAME%TYPE DEFAULT NULL,
   P_SOURCE_BUSINESS_GRP_ID  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_ID%TYPE DEFAULT NULL,
   P_SOURCE_BUSINESS_GRP_NAME IN  JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_NAME%TYPE  DEFAULT NULL,
   P_SOURCE_FIRST_NAME        IN  JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE  DEFAULT NULL,
   P_SOURCE_LAST_NAME         IN  JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE  DEFAULT NULL,
   P_SOURCE_MIDDLE_NAME       IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE  DEFAULT NULL,
   P_SOURCE_CATEGORY          IN  JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE  DEFAULT NULL,
   P_SOURCE_STATUS            IN  JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE  DEFAULT NULL,
   P_SOURCE_OFFICE            IN  JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE  DEFAULT NULL,
   P_SOURCE_LOCATION          IN  JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE  DEFAULT NULL,
   P_SOURCE_MAILSTOP          IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE  DEFAULT NULL,
   P_USER_NAME                IN  VARCHAR2 DEFAULT NULL,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_SOURCE_MOBILE_PHONE      IN  JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE  DEFAULT NULL,
   P_SOURCE_PAGER             IN  JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE  DEFAULT NULL
   );


  --Creating a Global Variable to be used for setting the flag,
  --when the create_resource_migrate gets called

    G_RS_ID_PVT_FLAG		VARCHAR2(1)	:= 'Y';

  --Create Resource Migration API, used for one-time migration of resource data
  --The API includes RESOURCE_ID as one of its Input Parameters

  PROCEDURE  create_resource_migrate (
   P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   					DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   					DEFAULT  FND_API.G_FALSE,
   P_CATEGORY                IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
   P_SOURCE_ID               IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE   	DEFAULT  NULL,
   P_ADDRESS_ID              IN   JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE   	DEFAULT  NULL,
   P_CONTACT_ID              IN   JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE   	DEFAULT  NULL,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   	DEFAULT  NULL,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   	DEFAULT  NULL,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE   	DEFAULT  NULL,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE   	DEFAULT  NULL,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE 	DEFAULT  NULL,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE   	DEFAULT  NULL,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE   	DEFAULT  NULL,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE   	DEFAULT  NULL,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE   	DEFAULT  NULL,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE   	DEFAULT  NULL,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE   	DEFAULT  NULL,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE   	DEFAULT  NULL,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE DEFAULT  NULL,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE   	DEFAULT  'Y',
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE   DEFAULT  NULL,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE   	DEFAULT  'N',
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE 	DEFAULT  NULL,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE   		DEFAULT  NULL,
   P_TRANSACTION_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE DEFAULT  NULL,
 --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   				DEFAULT  NULL,
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
   P_RESOURCE_ID	     IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE 	DEFAULT  NULL,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   X_RESOURCE_ID             OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   X_RESOURCE_NUMBER         OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE
   );

  /* Procedure to update the resource based on input values passed by calling routines. */

  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   DEFAULT  JTF_RS_RESOURCE_PUB.G_MISS_LOCATION,
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
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  );


  /* Procedure to create the resource with the resource synchronizing parameters. */

  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_MANAGING_EMP_ID         IN   JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_START_DATE_ACTIVE       IN   JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE         IN   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_TIME_ZONE               IN   JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_COST_PER_HR             IN   JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_PRIMARY_LANGUAGE        IN   JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_SECONDARY_LANGUAGE      IN   JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_SUPPORT_SITE_ID         IN   JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_IES_AGENT_LOGIN         IN   JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_SERVER_GROUP_ID         IN   JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_ASSIGNED_TO_GROUP_ID    IN   JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_COST_CENTER             IN   JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_CHARGE_TO_COST_CENTER   IN   JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_COMP_CURRENCY_CODE      IN   JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_COMMISSIONABLE_FLAG     IN   JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_HOLD_REASON_CODE        IN   JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_HOLD_PAYMENT            IN   JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_COMP_SERVICE_TEAM_ID    IN   JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_USER_ID                 IN   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   --P_LOCATION                IN   MDSYS.SDO_GEOMETRY   DEFAULT  JTF_RS_RESOURCE_PUB.G_MISS_LOCATION,
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
   P_ATTRIBUTE_CATEGORY      IN   JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_RESOURCE_NAME           IN   JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_NAME             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
   P_SOURCE_NUMBER           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_NUMBER%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_JOB_TITLE        IN   JTF_RS_RESOURCE_EXTNS.SOURCE_JOB_TITLE%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_EMAIL            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_PHONE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PHONE%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ORG_ID           IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_ORG_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ORG_NAME%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ADDRESS1         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS1%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ADDRESS2         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS2%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ADDRESS3         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS3%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_ADDRESS4         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_ADDRESS4%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_CITY             IN   JTF_RS_RESOURCE_EXTNS.SOURCE_CITY%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_POSTAL_CODE      IN   JTF_RS_RESOURCE_EXTNS.SOURCE_POSTAL_CODE%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_STATE            IN   JTF_RS_RESOURCE_EXTNS.SOURCE_STATE%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_PROVINCE         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_PROVINCE%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_COUNTY           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTY%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_COUNTRY          IN   JTF_RS_RESOURCE_EXTNS.SOURCE_COUNTRY%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_MGR_ID           IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_ID%TYPE DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_MGR_NAME         IN   JTF_RS_RESOURCE_EXTNS.SOURCE_MGR_NAME%TYPE DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_BUSINESS_GRP_ID  IN   JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_ID%TYPE DEFAULT FND_API.G_MISS_NUM,
   P_SOURCE_BUSINESS_GRP_NAME IN  JTF_RS_RESOURCE_EXTNS.SOURCE_BUSINESS_GRP_NAME%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_FIRST_NAME       IN JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_LAST_NAME        IN JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_MIDDLE_NAME      IN JTF_RS_RESOURCE_EXTNS.SOURCE_MIDDLE_NAME%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_CATEGORY         IN JTF_RS_RESOURCE_EXTNS.SOURCE_CATEGORY%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_STATUS           IN JTF_RS_RESOURCE_EXTNS.SOURCE_STATUS%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_OFFICE           IN JTF_RS_RESOURCE_EXTNS.SOURCE_OFFICE%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_LOCATION         IN JTF_RS_RESOURCE_EXTNS.SOURCE_LOCATION%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_MAILSTOP         IN JTF_RS_RESOURCE_EXTNS.SOURCE_MAILSTOP%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_ADDRESS_ID              IN JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE  DEFAULT FND_API.G_MISS_NUM,
   P_OBJECT_VERSION_NUM      IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   P_USER_NAME               IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2,
   P_SOURCE_MOBILE_PHONE     IN JTF_RS_RESOURCE_EXTNS.SOURCE_MOBILE_PHONE%TYPE  DEFAULT FND_API.G_MISS_CHAR,
   P_SOURCE_PAGER            IN JTF_RS_RESOURCE_EXTNS.SOURCE_PAGER%TYPE  DEFAULT FND_API.G_MISS_CHAR
  );


  /* Procedure to delete  the resource of category = TBH */

  PROCEDURE DELETE_RESOURCE(
    P_API_VERSION	IN  NUMBER,
    P_INIT_MSG_LIST	IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_COMMIT		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_RESOURCE_ID       IN  NUMBER,
    X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT         OUT NOCOPY NUMBER,
    X_MSG_DATA          OUT NOCOPY VARCHAR2 );

END jtf_rs_resource_pvt;

 

/
