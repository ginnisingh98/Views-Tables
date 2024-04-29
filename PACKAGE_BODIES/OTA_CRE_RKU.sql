--------------------------------------------------------
--  DDL for Package Body OTA_CRE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CRE_RKU" as
/* $Header: otcrerhi.pkb 120.8 2006/02/01 15:02 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_CERT_ENROLLMENT_ID in NUMBER
,P_CERTIFICATION_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_CONTACT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CERTIFICATION_STATUS_CODE in VARCHAR2
,P_COMPLETION_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_UNENROLLMENT_DATE in DATE
,P_EXPIRATION_DATE in DATE
,P_EARLIEST_ENROLL_DATE in DATE
,P_IS_HISTORY_FLAG in VARCHAR2
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
,P_ENROLLMENT_DATE in DATE
,P_CERTIFICATION_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_CONTACT_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CERTIFICATION_STATUS_CODE_O in VARCHAR2
,P_COMPLETION_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_UNENROLLMENT_DATE_O in DATE
,P_EXPIRATION_DATE_O in DATE
,P_EARLIEST_ENROLL_DATE_O in DATE
,P_IS_HISTORY_FLAG_O in VARCHAR2
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
,P_ENROLLMENT_DATE_O in DATE
)is
begin
hr_utility.set_location('Entering: OTA_CRE_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: OTA_CRE_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end OTA_CRE_RKU;

/
