--------------------------------------------------------
--  DDL for Package Body OTA_CTU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CTU_RKD" as
/* $Header: otcturhi.pkb 120.2.12010000.2 2009/07/24 10:53:50 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:58 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CATEGORY_USAGE_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CATEGORY_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_TYPE_O in VARCHAR2
,P_START_DATE_ACTIVE_O in DATE
,P_END_DATE_ACTIVE_O in DATE
,P_PARENT_CAT_USAGE_ID_O in NUMBER
,P_SYNCHRONOUS_FLAG_O in VARCHAR2
,P_ONLINE_FLAG_O in VARCHAR2
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
,P_DATA_SOURCE_O in VARCHAR2
,P_COMMENTS_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_CTU_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: OTA_CTU_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end OTA_CTU_RKD;

/
