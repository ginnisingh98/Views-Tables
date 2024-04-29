--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_EXTN_AUD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_EXTN_AUD_PKG" AUTHID CURRENT_USER as
/* $Header: jtfrstas.pls 120.0 2005/05/11 08:22:05 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RESOURCE_AUDIT_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_NEW_CATEGORY in VARCHAR2,
  X_OLD_CATEGORY in VARCHAR2,
  X_NEW_RESOURCE_NUMBER in VARCHAR2,
  X_OLD_RESOURCE_NUMBER in VARCHAR2,
  X_NEW_SOURCE_ID in NUMBER,
  X_OLD_SOURCE_ID in NUMBER,
  X_NEW_ADDRESS_ID in NUMBER,
  X_OLD_ADDRESS_ID in NUMBER,
  X_NEW_CONTACT_ID in NUMBER,
  X_OLD_CONTACT_ID in NUMBER,
  X_NEW_MANAGING_EMPLOYEE_ID in NUMBER,
  X_OLD_MANAGING_EMPLOYEE_ID in NUMBER,
  X_OLD_START_DATE_ACTIVE in DATE,
  X_NEW_START_DATE_ACTIVE in DATE,
  X_OLD_END_DATE_ACTIVE in DATE,
  X_NEW_END_DATE_ACTIVE in DATE,
  X_NEW_TIME_ZONE in NUMBER,
  X_OLD_TIME_ZONE in NUMBER,
  X_NEW_COST_PER_HR in NUMBER,
  X_OLD_COST_PER_HR in NUMBER,
  X_NEW_PRIMARY_LANGUAGE in VARCHAR2,
  X_OLD_PRIMARY_LANGUAGE in VARCHAR2,
  X_NEW_SECONDARY_LANGUAGE in VARCHAR2,
  X_OLD_SECONDARY_LANGUAGE in VARCHAR2,
  X_NEW_SUPPORT_SITE_ID in NUMBER,
  X_OLD_SUPPORT_SITE_ID in NUMBER,
  X_NEW_IES_AGENT_LOGIN in VARCHAR2,
  X_OLD_IES_AGENT_LOGIN in VARCHAR2,
  X_NEW_SERVER_GROUP_ID in NUMBER,
  X_OLD_SERVER_GROUP_ID in NUMBER,
  X_NEW_ASSIGNED_TO_GROUP_ID in NUMBER,
  X_OLD_ASSIGNED_TO_GROUP_ID in NUMBER,
  X_NEW_COST_CENTER in VARCHAR2,
  X_OLD_COST_CENTER in VARCHAR2,
  X_NEW_CHARGE_TO_COST_CENTER in VARCHAR2,
  X_OLD_CHARGE_TO_COST_CENTER in VARCHAR2,
  X_NEW_COMPENSATION_CURRENCY_CO in VARCHAR2,
  X_OLD_COMPENSATION_CURRENCY_CO in VARCHAR2,
  X_NEW_COMMISSIONABLE_FLAG in VARCHAR2,
  X_OLD_COMMISSIONABLE_FLAG in VARCHAR2,
  X_NEW_HOLD_REASON_CODE in VARCHAR2,
  X_OLD_HOLD_REASON_CODE in VARCHAR2,
  X_NEW_HOLD_PAYMENT in VARCHAR2,
  X_OLD_HOLD_PAYMENT in VARCHAR2,
  X_NEW_COMP_SERVICE_TEAM_ID in NUMBER,
  X_OLD_COMP_SERVICE_TEAM_ID in NUMBER,
  X_NEW_TRANSACTION_NUMBER in NUMBER,
  X_OLD_TRANSACTION_NUMBER in NUMBER,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER,
  X_NEW_USER_ID in NUMBER,
  X_OLD_USER_ID in NUMBER,
  --X_OLD_LOCATION in MDSYS.SDO_GEOMETRY,
  --X_NEW_LOCATION in MDSYS.SDO_GEOMETRY,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_NEW_RESOURCE_NAME   in  VARCHAR2   DEFAULT NULL,
  X_OLD_RESOURCE_NAME   in  VARCHAR2   DEFAULT NULL,
  X_NEW_SOURCE_NAME in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_NAME in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_NUMBER   in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_NUMBER   in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_JOB_TITLE  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_JOB_TITLE  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_EMAIL  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_EMAIL  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_PHONE  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_PHONE  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ORG_ID in   NUMBER DEFAULT NULL,
  X_OLD_SOURCE_ORG_ID in   NUMBER DEFAULT NULL,
  X_NEW_SOURCE_ORG_NAME  in VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ORG_NAME  in VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS1  in    VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS1  in    VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS2  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS2  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS3  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS3  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS4  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS4  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_CITY     in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_CITY     in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_POSTAL_CODE  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_POSTAL_CODE  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_STATE       in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_STATE       in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_PROVINCE     in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_PROVINCE     in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_COUNTY      in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_COUNTY      in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_COUNTRY     in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_COUNTRY     in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MGR_ID       in  NUMBER DEFAULT NULL,
  X_OLD_SOURCE_MGR_ID       in  NUMBER DEFAULT NULL,
  X_NEW_SOURCE_MGR_NAME       in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_MGR_NAME       in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_BUSINESS_GRP_ID       in  NUMBER DEFAULT NULL,
  X_OLD_SOURCE_BUSINESS_GRP_ID       in  NUMBER DEFAULT NULL,
  X_NEW_SOURCE_BUSINESS_GRP_NAME     in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_BUSINESS_GRP_NAME     in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_FIRST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_FIRST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MIDDLE_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MIDDLE_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_LAST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_LAST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_CATEGORY      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_CATEGORY      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_STATUS      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_STATUS      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_OFFICE      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_OFFICE      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_LOCATION      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_LOCATION      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MAILSTOP      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MAILSTOP      in   VARCHAR2  DEFAULT NULL,
  X_NEW_USER_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_USER_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_JOB_ID      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_JOB_ID      in   VARCHAR2  DEFAULT NULL,
  X_NEW_PARTY_ID      in   VARCHAR2  DEFAULT NULL,
  X_OLD_PARTY_ID      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MOBILE_PHONE      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MOBILE_PHONE      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_PAGER      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_PAGER      in   VARCHAR2  DEFAULT NULL
  );
procedure LOCK_ROW (
  X_RESOURCE_AUDIT_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_NEW_CATEGORY in VARCHAR2,
  X_OLD_CATEGORY in VARCHAR2,
  X_NEW_RESOURCE_NUMBER in VARCHAR2,
  X_OLD_RESOURCE_NUMBER in VARCHAR2,
  X_NEW_SOURCE_ID in NUMBER,
  X_OLD_SOURCE_ID in NUMBER,
  X_NEW_ADDRESS_ID in NUMBER,
  X_OLD_ADDRESS_ID in NUMBER,
  X_NEW_CONTACT_ID in NUMBER,
  X_OLD_CONTACT_ID in NUMBER,
  X_NEW_MANAGING_EMPLOYEE_ID in NUMBER,
  X_OLD_MANAGING_EMPLOYEE_ID in NUMBER,
  X_OLD_START_DATE_ACTIVE in DATE,
  X_NEW_START_DATE_ACTIVE in DATE,
  X_OLD_END_DATE_ACTIVE in DATE,
  X_NEW_END_DATE_ACTIVE in DATE,
  X_NEW_TIME_ZONE in NUMBER,
  X_OLD_TIME_ZONE in NUMBER,
  X_NEW_COST_PER_HR in NUMBER,
  X_OLD_COST_PER_HR in NUMBER,
  X_NEW_PRIMARY_LANGUAGE in VARCHAR2,
  X_OLD_PRIMARY_LANGUAGE in VARCHAR2,
  X_NEW_SECONDARY_LANGUAGE in VARCHAR2,
  X_OLD_SECONDARY_LANGUAGE in VARCHAR2,
  X_NEW_SUPPORT_SITE_ID in NUMBER,
  X_OLD_SUPPORT_SITE_ID in NUMBER,
  X_NEW_IES_AGENT_LOGIN in VARCHAR2,
  X_OLD_IES_AGENT_LOGIN in VARCHAR2,
  X_NEW_SERVER_GROUP_ID in NUMBER,
  X_OLD_SERVER_GROUP_ID in NUMBER,
  X_NEW_ASSIGNED_TO_GROUP_ID in NUMBER,
  X_OLD_ASSIGNED_TO_GROUP_ID in NUMBER,
  X_NEW_COST_CENTER in VARCHAR2,
  X_OLD_COST_CENTER in VARCHAR2,
  X_NEW_CHARGE_TO_COST_CENTER in VARCHAR2,
  X_OLD_CHARGE_TO_COST_CENTER in VARCHAR2,
  X_NEW_COMPENSATION_CURRENCY_CO in VARCHAR2,
  X_OLD_COMPENSATION_CURRENCY_CO in VARCHAR2,
  X_NEW_COMMISSIONABLE_FLAG in VARCHAR2,
  X_OLD_COMMISSIONABLE_FLAG in VARCHAR2,
  X_NEW_HOLD_REASON_CODE in VARCHAR2,
  X_OLD_HOLD_REASON_CODE in VARCHAR2,
  X_NEW_HOLD_PAYMENT in VARCHAR2,
  X_OLD_HOLD_PAYMENT in VARCHAR2,
  X_NEW_COMP_SERVICE_TEAM_ID in NUMBER,
  X_OLD_COMP_SERVICE_TEAM_ID in NUMBER,
  X_NEW_TRANSACTION_NUMBER in NUMBER,
  X_OLD_TRANSACTION_NUMBER in NUMBER,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER,
  X_NEW_USER_ID in NUMBER,
  X_OLD_USER_ID in NUMBER,
  --X_OLD_LOCATION in MDSYS.SDO_GEOMETRY,
  --X_NEW_LOCATION in MDSYS.SDO_GEOMETRY
  X_NEW_RESOURCE_NAME   in  VARCHAR2   DEFAULT NULL,
  X_OLD_RESOURCE_NAME   in  VARCHAR2   DEFAULT NULL,
  X_NEW_SOURCE_NAME in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_NAME in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_NUMBER   in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_NUMBER   in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_JOB_TITLE  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_JOB_TITLE  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_EMAIL  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_EMAIL  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_PHONE  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_PHONE  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ORG_ID in   NUMBER DEFAULT NULL,
  X_OLD_SOURCE_ORG_ID in   NUMBER DEFAULT NULL,
  X_NEW_SOURCE_ORG_NAME  in VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ORG_NAME  in VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS1  in    VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS1  in    VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS2  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS2  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS3  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS3  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS4  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS4  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_CITY     in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_CITY     in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_POSTAL_CODE  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_POSTAL_CODE  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_STATE       in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_STATE       in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_PROVINCE     in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_PROVINCE     in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_COUNTY      in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_COUNTY      in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_COUNTRY     in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_COUNTRY     in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MGR_ID       in  NUMBER DEFAULT NULL,
  X_OLD_SOURCE_MGR_ID       in  NUMBER DEFAULT NULL,
  X_NEW_SOURCE_MGR_NAME       in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_MGR_NAME       in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_BUSINESS_GRP_ID       in  NUMBER DEFAULT NULL,
  X_OLD_SOURCE_BUSINESS_GRP_ID       in  NUMBER DEFAULT NULL,
  X_NEW_SOURCE_BUSINESS_GRP_NAME     in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_BUSINESS_GRP_NAME     in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_FIRST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_FIRST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MIDDLE_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MIDDLE_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_LAST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_LAST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_CATEGORY      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_CATEGORY      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_STATUS      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_STATUS      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_OFFICE      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_OFFICE      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_LOCATION      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_LOCATION      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MAILSTOP      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MAILSTOP      in   VARCHAR2  DEFAULT NULL,
  X_NEW_USER_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_USER_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_JOB_ID      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_JOB_ID      in   VARCHAR2  DEFAULT NULL,
  X_NEW_PARTY_ID      in   VARCHAR2  DEFAULT NULL,
  X_OLD_PARTY_ID      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MOBILE_PHONE      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MOBILE_PHONE      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_PAGER      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_PAGER      in   VARCHAR2  DEFAULT NULL
);
procedure UPDATE_ROW (
  X_RESOURCE_AUDIT_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_NEW_CATEGORY in VARCHAR2,
  X_OLD_CATEGORY in VARCHAR2,
  X_NEW_RESOURCE_NUMBER in VARCHAR2,
  X_OLD_RESOURCE_NUMBER in VARCHAR2,
  X_NEW_SOURCE_ID in NUMBER,
  X_OLD_SOURCE_ID in NUMBER,
  X_NEW_ADDRESS_ID in NUMBER,
  X_OLD_ADDRESS_ID in NUMBER,
  X_NEW_CONTACT_ID in NUMBER,
  X_OLD_CONTACT_ID in NUMBER,
  X_NEW_MANAGING_EMPLOYEE_ID in NUMBER,
  X_OLD_MANAGING_EMPLOYEE_ID in NUMBER,
  X_OLD_START_DATE_ACTIVE in DATE,
  X_NEW_START_DATE_ACTIVE in DATE,
  X_OLD_END_DATE_ACTIVE in DATE,
  X_NEW_END_DATE_ACTIVE in DATE,
  X_NEW_TIME_ZONE in NUMBER,
  X_OLD_TIME_ZONE in NUMBER,
  X_NEW_COST_PER_HR in NUMBER,
  X_OLD_COST_PER_HR in NUMBER,
  X_NEW_PRIMARY_LANGUAGE in VARCHAR2,
  X_OLD_PRIMARY_LANGUAGE in VARCHAR2,
  X_NEW_SECONDARY_LANGUAGE in VARCHAR2,
  X_OLD_SECONDARY_LANGUAGE in VARCHAR2,
  X_NEW_SUPPORT_SITE_ID in NUMBER,
  X_OLD_SUPPORT_SITE_ID in NUMBER,
  X_NEW_IES_AGENT_LOGIN in VARCHAR2,
  X_OLD_IES_AGENT_LOGIN in VARCHAR2,
  X_NEW_SERVER_GROUP_ID in NUMBER,
  X_OLD_SERVER_GROUP_ID in NUMBER,
  X_NEW_ASSIGNED_TO_GROUP_ID in NUMBER,
  X_OLD_ASSIGNED_TO_GROUP_ID in NUMBER,
  X_NEW_COST_CENTER in VARCHAR2,
  X_OLD_COST_CENTER in VARCHAR2,
  X_NEW_CHARGE_TO_COST_CENTER in VARCHAR2,
  X_OLD_CHARGE_TO_COST_CENTER in VARCHAR2,
  X_NEW_COMPENSATION_CURRENCY_CO in VARCHAR2,
  X_OLD_COMPENSATION_CURRENCY_CO in VARCHAR2,
  X_NEW_COMMISSIONABLE_FLAG in VARCHAR2,
  X_OLD_COMMISSIONABLE_FLAG in VARCHAR2,
  X_NEW_HOLD_REASON_CODE in VARCHAR2,
  X_OLD_HOLD_REASON_CODE in VARCHAR2,
  X_NEW_HOLD_PAYMENT in VARCHAR2,
  X_OLD_HOLD_PAYMENT in VARCHAR2,
  X_NEW_COMP_SERVICE_TEAM_ID in NUMBER,
  X_OLD_COMP_SERVICE_TEAM_ID in NUMBER,
  X_NEW_TRANSACTION_NUMBER in NUMBER,
  X_OLD_TRANSACTION_NUMBER in NUMBER,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER,
  X_NEW_USER_ID in NUMBER,
  X_OLD_USER_ID in NUMBER,
  --X_OLD_LOCATION in MDSYS.SDO_GEOMETRY,
 -- X_NEW_LOCATION in MDSYS.SDO_GEOMETRY,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_NEW_RESOURCE_NAME   in  VARCHAR2   DEFAULT NULL,
  X_OLD_RESOURCE_NAME   in  VARCHAR2   DEFAULT NULL,
  X_NEW_SOURCE_NAME in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_NAME in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_NUMBER   in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_NUMBER   in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_JOB_TITLE  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_JOB_TITLE  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_EMAIL  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_EMAIL  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_PHONE  in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_PHONE  in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ORG_ID in   NUMBER DEFAULT NULL,
  X_OLD_SOURCE_ORG_ID in   NUMBER DEFAULT NULL,
  X_NEW_SOURCE_ORG_NAME  in VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ORG_NAME  in VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS1  in    VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS1  in    VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS2  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS2  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS3  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS3  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_ADDRESS4  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_ADDRESS4  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_CITY     in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_CITY     in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_POSTAL_CODE  in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_POSTAL_CODE  in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_STATE       in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_STATE       in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_PROVINCE     in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_PROVINCE     in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_COUNTY      in   VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_COUNTY      in   VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_COUNTRY     in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_COUNTRY     in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MGR_ID       in  NUMBER DEFAULT NULL,
  X_OLD_SOURCE_MGR_ID       in  NUMBER DEFAULT NULL,
  X_NEW_SOURCE_MGR_NAME       in  VARCHAR2 DEFAULT NULL,
  X_OLD_SOURCE_MGR_NAME       in  VARCHAR2 DEFAULT NULL,
  X_NEW_SOURCE_BUSINESS_GRP_ID       in  NUMBER DEFAULT NULL,
  X_OLD_SOURCE_BUSINESS_GRP_ID       in  NUMBER DEFAULT NULL,
  X_NEW_SOURCE_BUSINESS_GRP_NAME     in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_BUSINESS_GRP_NAME     in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_FIRST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_FIRST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MIDDLE_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MIDDLE_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_LAST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_LAST_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_CATEGORY      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_CATEGORY      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_STATUS      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_STATUS      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_OFFICE      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_OFFICE      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_LOCATION      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_LOCATION      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MAILSTOP      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MAILSTOP      in   VARCHAR2  DEFAULT NULL,
  X_NEW_USER_NAME      in   VARCHAR2  DEFAULT NULL,
  X_OLD_USER_NAME      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_JOB_ID      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_JOB_ID      in   VARCHAR2  DEFAULT NULL,
  X_NEW_PARTY_ID      in   VARCHAR2  DEFAULT NULL,
  X_OLD_PARTY_ID      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_MOBILE_PHONE      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_MOBILE_PHONE      in   VARCHAR2  DEFAULT NULL,
  X_NEW_SOURCE_PAGER      in   VARCHAR2  DEFAULT NULL,
  X_OLD_SOURCE_PAGER      in   VARCHAR2  DEFAULT NULL
);
procedure DELETE_ROW (
  X_RESOURCE_AUDIT_ID in NUMBER
);
end JTF_RS_RESOURCE_EXTN_AUD_PKG;

 

/