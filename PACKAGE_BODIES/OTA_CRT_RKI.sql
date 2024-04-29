--------------------------------------------------------
--  DDL for Package Body OTA_CRT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CRT_RKI" as
/* $Header: otcrtrhi.pkb 120.14 2006/03/17 14:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_CERTIFICATION_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PUBLIC_FLAG in VARCHAR2
,P_INITIAL_COMPLETION_DATE in DATE
,P_INITIAL_COMPLETION_DURATION in NUMBER
,P_INITIAL_COMPL_DURATION_UNITS in VARCHAR2
,P_RENEWAL_DURATION in NUMBER
,P_RENEWAL_DURATION_UNITS in VARCHAR2
,P_NOTIFY_DAYS_BEFORE_EXPIRE in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_START_DATE_ACTIVE in DATE
,P_END_DATE_ACTIVE in DATE
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ATTRIBUTE1 in VARCHAR2
,P_ATTRIBUTE2 in VARCHAR2
,P_ATTRIBUTE3 in VARCHAR2
,P_ATTRIBUTE4 in VARCHAR2
,P_ATTRIBUTE5 in VARCHAR2
,P_ATTRIBUTE6 in VARCHAR2
,P_ATTRIBUTE7 in VARCHAR2
,P_ATTRIBUTE8 in VARCHAR2
,P_ATTRIBUTE9 in VARCHAR2
,P_ATTRIBUTE10 in VARCHAR2
,P_ATTRIBUTE11 in VARCHAR2
,P_ATTRIBUTE12 in VARCHAR2
,P_ATTRIBUTE13 in VARCHAR2
,P_ATTRIBUTE14 in VARCHAR2
,P_ATTRIBUTE15 in VARCHAR2
,P_ATTRIBUTE16 in VARCHAR2
,P_ATTRIBUTE17 in VARCHAR2
,P_ATTRIBUTE18 in VARCHAR2
,P_ATTRIBUTE19 in VARCHAR2
,P_ATTRIBUTE20 in VARCHAR2
,P_VALIDITY_DURATION in NUMBER
,P_VALIDITY_DURATION_UNITS in VARCHAR2
,P_RENEWABLE_FLAG in VARCHAR2
,P_VALIDITY_START_TYPE in VARCHAR2
,P_COMPETENCY_UPDATE_LEVEL in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_CRT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: OTA_CRT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end OTA_CRT_RKI;

/