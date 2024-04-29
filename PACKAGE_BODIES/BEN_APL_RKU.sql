--------------------------------------------------------
--  DDL for Package Body BEN_APL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_APL_RKU" as
/* $Header: beaplrhi.pkb 120.0.12010000.3 2008/08/25 14:06:41 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ACTY_RT_PTD_LMT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ACTY_BASE_RT_ID in NUMBER
,P_PTD_LMT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_APL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_APL_ATTRIBUTE1 in VARCHAR2
,P_APL_ATTRIBUTE2 in VARCHAR2
,P_APL_ATTRIBUTE3 in VARCHAR2
,P_APL_ATTRIBUTE4 in VARCHAR2
,P_APL_ATTRIBUTE5 in VARCHAR2
,P_APL_ATTRIBUTE6 in VARCHAR2
,P_APL_ATTRIBUTE7 in VARCHAR2
,P_APL_ATTRIBUTE8 in VARCHAR2
,P_APL_ATTRIBUTE9 in VARCHAR2
,P_APL_ATTRIBUTE10 in VARCHAR2
,P_APL_ATTRIBUTE11 in VARCHAR2
,P_APL_ATTRIBUTE12 in VARCHAR2
,P_APL_ATTRIBUTE13 in VARCHAR2
,P_APL_ATTRIBUTE14 in VARCHAR2
,P_APL_ATTRIBUTE15 in VARCHAR2
,P_APL_ATTRIBUTE16 in VARCHAR2
,P_APL_ATTRIBUTE17 in VARCHAR2
,P_APL_ATTRIBUTE18 in VARCHAR2
,P_APL_ATTRIBUTE19 in VARCHAR2
,P_APL_ATTRIBUTE20 in VARCHAR2
,P_APL_ATTRIBUTE21 in VARCHAR2
,P_APL_ATTRIBUTE22 in VARCHAR2
,P_APL_ATTRIBUTE23 in VARCHAR2
,P_APL_ATTRIBUTE24 in VARCHAR2
,P_APL_ATTRIBUTE25 in VARCHAR2
,P_APL_ATTRIBUTE26 in VARCHAR2
,P_APL_ATTRIBUTE27 in VARCHAR2
,P_APL_ATTRIBUTE28 in VARCHAR2
,P_APL_ATTRIBUTE29 in VARCHAR2
,P_APL_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ACTY_BASE_RT_ID_O in NUMBER
,P_PTD_LMT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_APL_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_APL_ATTRIBUTE1_O in VARCHAR2
,P_APL_ATTRIBUTE2_O in VARCHAR2
,P_APL_ATTRIBUTE3_O in VARCHAR2
,P_APL_ATTRIBUTE4_O in VARCHAR2
,P_APL_ATTRIBUTE5_O in VARCHAR2
,P_APL_ATTRIBUTE6_O in VARCHAR2
,P_APL_ATTRIBUTE7_O in VARCHAR2
,P_APL_ATTRIBUTE8_O in VARCHAR2
,P_APL_ATTRIBUTE9_O in VARCHAR2
,P_APL_ATTRIBUTE10_O in VARCHAR2
,P_APL_ATTRIBUTE11_O in VARCHAR2
,P_APL_ATTRIBUTE12_O in VARCHAR2
,P_APL_ATTRIBUTE13_O in VARCHAR2
,P_APL_ATTRIBUTE14_O in VARCHAR2
,P_APL_ATTRIBUTE15_O in VARCHAR2
,P_APL_ATTRIBUTE16_O in VARCHAR2
,P_APL_ATTRIBUTE17_O in VARCHAR2
,P_APL_ATTRIBUTE18_O in VARCHAR2
,P_APL_ATTRIBUTE19_O in VARCHAR2
,P_APL_ATTRIBUTE20_O in VARCHAR2
,P_APL_ATTRIBUTE21_O in VARCHAR2
,P_APL_ATTRIBUTE22_O in VARCHAR2
,P_APL_ATTRIBUTE23_O in VARCHAR2
,P_APL_ATTRIBUTE24_O in VARCHAR2
,P_APL_ATTRIBUTE25_O in VARCHAR2
,P_APL_ATTRIBUTE26_O in VARCHAR2
,P_APL_ATTRIBUTE27_O in VARCHAR2
,P_APL_ATTRIBUTE28_O in VARCHAR2
,P_APL_ATTRIBUTE29_O in VARCHAR2
,P_APL_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_APL_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_APL_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_APL_RKU;

/
