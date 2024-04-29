--------------------------------------------------------
--  DDL for Package Body OTA_CMB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CMB_RKD" as
/* $Header: otcmbrhi.pkb 120.5 2005/08/19 17:58 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:05 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CERTIFICATION_MEMBER_ID in NUMBER
,P_CERTIFICATION_ID_O in NUMBER
,P_OBJECT_ID_O in NUMBER
,P_OBJECT_TYPE_O in VARCHAR2
,P_MEMBER_SEQUENCE_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_START_DATE_ACTIVE_O in DATE
,P_END_DATE_ACTIVE_O in DATE
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
)is
begin
hr_utility.set_location('Entering: OTA_CMB_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: OTA_CMB_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end OTA_CMB_RKD;

/
