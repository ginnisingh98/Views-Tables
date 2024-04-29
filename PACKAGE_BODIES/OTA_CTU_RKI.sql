--------------------------------------------------------
--  DDL for Package Body OTA_CTU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CTU_RKI" as
/* $Header: otcturhi.pkb 120.2.12010000.2 2009/07/24 10:53:50 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:59 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_CATEGORY_USAGE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CATEGORY in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TYPE in VARCHAR2
,P_START_DATE_ACTIVE in DATE
,P_END_DATE_ACTIVE in DATE
,P_PARENT_CAT_USAGE_ID in NUMBER
,P_SYNCHRONOUS_FLAG in VARCHAR2
,P_ONLINE_FLAG in VARCHAR2
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
,P_DATA_SOURCE in VARCHAR2
,P_COMMENTS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_CTU_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: OTA_CTU_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end OTA_CTU_RKI;

/
