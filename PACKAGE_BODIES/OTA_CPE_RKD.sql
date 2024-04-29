--------------------------------------------------------
--  DDL for Package Body OTA_CPE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CPE_RKD" as
/* $Header: otcperhi.pkb 120.3 2005/12/01 15:24 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:07 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CERT_PRD_ENROLLMENT_ID in NUMBER
,P_CERT_ENROLLMENT_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_PERIOD_STATUS_CODE_O in VARCHAR2
,P_COMPLETION_DATE_O in DATE
,P_CERT_PERIOD_START_DATE_O in DATE
,P_CERT_PERIOD_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ATTRIBUTE1_O in VARCHAR2
,P_ATTRIBUTE2_O in VARCHAR2
,P_ATTRIBUTE3_O in VARCHAR2
,P_ATTRIBUTE4_O in VARCHAR2
,P_ATTRIBUTE5_O in VARCHAR2
,P_ATTRIBUTE6_O in VARCHAR2
,P_ATTRIBUTE7_O in VARCHAR2
,P_ATTRIBUTE8_O in VARCHAR2
,P_ATTRIBUTE9_O in VARCHAR2
,P_ATTRIBUTE10_O in VARCHAR2
,P_ATTRIBUTE11_O in VARCHAR2
,P_ATTRIBUTE12_O in VARCHAR2
,P_ATTRIBUTE13_O in VARCHAR2
,P_ATTRIBUTE14_O in VARCHAR2
,P_ATTRIBUTE15_O in VARCHAR2
,P_ATTRIBUTE16_O in VARCHAR2
,P_ATTRIBUTE17_O in VARCHAR2
,P_ATTRIBUTE18_O in VARCHAR2
,P_ATTRIBUTE19_O in VARCHAR2
,P_ATTRIBUTE20_O in VARCHAR2
,P_EXPIRATION_DATE_O in DATE
)is
begin
hr_utility.set_location('Entering: OTA_CPE_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: OTA_CPE_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end OTA_CPE_RKD;

/