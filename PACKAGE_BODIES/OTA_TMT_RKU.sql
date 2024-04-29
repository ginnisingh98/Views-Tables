--------------------------------------------------------
--  DDL for Package Body OTA_TMT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TMT_RKU" as
/* $Header: ottmtrhi.pkb 115.6 2002/11/26 17:09:48 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:26 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_TP_MEASUREMENT_TYPE_ID in NUMBER
,P_TP_MEASUREMENT_CODE in VARCHAR2
,P_UNIT in VARCHAR2
,P_REPORTING_SEQUENCE in NUMBER
,P_BUDGET_LEVEL in VARCHAR2
,P_COST_LEVEL in VARCHAR2
,P_MANY_BUDGET_VALUES_FLAG in VARCHAR2
,P_ITEM_TYPE_USAGE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
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
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_TP_MEASUREMENT_CODE_O in VARCHAR2
,P_UNIT_O in VARCHAR2
,P_REPORTING_SEQUENCE_O in NUMBER
,P_BUDGET_LEVEL_O in VARCHAR2
,P_COST_LEVEL_O in VARCHAR2
,P_MANY_BUDGET_VALUES_FLAG_O in VARCHAR2
,P_ITEM_TYPE_USAGE_ID_O in NUMBER
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
)is
begin
hr_utility.set_location('Entering: OTA_TMT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: OTA_TMT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end OTA_TMT_RKU;

/
