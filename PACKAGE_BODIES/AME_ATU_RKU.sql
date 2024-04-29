--------------------------------------------------------
--  DDL for Package Body AME_ATU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATU_RKU" as
/* $Header: amaturhi.pkb 120.6 2006/02/15 04:04 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:32 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_ATTRIBUTE_ID in NUMBER
,P_APPLICATION_ID in NUMBER
,P_QUERY_STRING in VARCHAR2
,P_USE_COUNT in NUMBER
,P_USER_EDITABLE in VARCHAR2
,P_IS_STATIC in VARCHAR2
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_SECURITY_GROUP_ID in NUMBER
,P_VALUE_SET_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_QUERY_STRING_O in VARCHAR2
,P_USE_COUNT_O in NUMBER
,P_USER_EDITABLE_O in VARCHAR2
,P_IS_STATIC_O in VARCHAR2
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_SECURITY_GROUP_ID_O in NUMBER
,P_VALUE_SET_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: AME_ATU_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: AME_ATU_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end AME_ATU_RKU;

/
