--------------------------------------------------------
--  DDL for Package Body OTA_TPM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPM_RKD" as
/* $Header: ottpmrhi.pkb 120.1 2005/12/14 15:33:09 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:27 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_TRAINING_PLAN_MEMBER_ID in NUMBER
,P_TRAINING_PLAN_ID_O in NUMBER
,P_ACTIVITY_VERSION_ID_O in NUMBER
,P_ACTIVITY_DEFINITION_ID_O in NUMBER
,P_MEMBER_STATUS_TYPE_ID_O in VARCHAR2
,P_TARGET_COMPLETION_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
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
,P_ATTRIBUTE21_O in VARCHAR2
,P_ATTRIBUTE22_O in VARCHAR2
,P_ATTRIBUTE23_O in VARCHAR2
,P_ATTRIBUTE24_O in VARCHAR2
,P_ATTRIBUTE25_O in VARCHAR2
,P_ATTRIBUTE26_O in VARCHAR2
,P_ATTRIBUTE27_O in VARCHAR2
,P_ATTRIBUTE28_O in VARCHAR2
,P_ATTRIBUTE29_O in VARCHAR2
,P_ATTRIBUTE30_O in VARCHAR2
,P_ASSIGNMENT_ID_O in NUMBER
,P_SOURCE_ID_O in NUMBER
,P_SOURCE_FUNCTION_O in VARCHAR2
,P_CANCELLATION_REASON_O in VARCHAR2
,P_EARLIEST_START_DATE_O in DATE
,P_CREATOR_PERSON_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: OTA_TPM_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: OTA_TPM_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end OTA_TPM_RKD;

/
