--------------------------------------------------------
--  DDL for Package Body HR_INT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_INT_RKI" as
/* $Header: hrintrhi.pkb 115.0 2004/01/09 01:40:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:04 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_INTEGRATION_ID in NUMBER
,P_INTEGRATION_KEY in VARCHAR2
,P_PARTY_TYPE in VARCHAR2
,P_PARTY_NAME in VARCHAR2
,P_PARTY_SITE_NAME in VARCHAR2
,P_TRANSACTION_TYPE in VARCHAR2
,P_TRANSACTION_SUBTYPE in VARCHAR2
,P_STANDARD_CODE in VARCHAR2
,P_EXT_TRANS_TYPE in VARCHAR2
,P_EXT_TRANS_SUBTYPE in VARCHAR2
,P_TRANS_DIRECTION in VARCHAR2
,P_URL in VARCHAR2
,P_SYNCHED in VARCHAR2
,P_EXT_APPLICATION_ID in NUMBER
,P_APPLICATION_NAME in VARCHAR2
,P_APPLICATION_TYPE in VARCHAR2
,P_APPLICATION_URL in VARCHAR2
,P_LOGOUT_URL in VARCHAR2
,P_USER_FIELD in VARCHAR2
,P_PASSWORD_FIELD in VARCHAR2
,P_AUTHENTICATION_NEEDED in VARCHAR2
,P_FIELD_NAME1 in VARCHAR2
,P_FIELD_VALUE1 in VARCHAR2
,P_FIELD_NAME2 in VARCHAR2
,P_FIELD_VALUE2 in VARCHAR2
,P_FIELD_NAME3 in VARCHAR2
,P_FIELD_VALUE3 in VARCHAR2
,P_FIELD_NAME4 in VARCHAR2
,P_FIELD_VALUE4 in VARCHAR2
,P_FIELD_NAME5 in VARCHAR2
,P_FIELD_VALUE5 in VARCHAR2
,P_FIELD_NAME6 in VARCHAR2
,P_FIELD_VALUE6 in VARCHAR2
,P_FIELD_NAME7 in VARCHAR2
,P_FIELD_VALUE7 in VARCHAR2
,P_FIELD_NAME8 in VARCHAR2
,P_FIELD_VALUE8 in VARCHAR2
,P_FIELD_NAME9 in VARCHAR2
,P_FIELD_VALUE9 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_INT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HR_INT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HR_INT_RKI;

/