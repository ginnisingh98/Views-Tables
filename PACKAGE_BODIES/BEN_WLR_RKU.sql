--------------------------------------------------------
--  DDL for Package Body BEN_WLR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WLR_RKU" as
/* $Header: bewlrrhi.pkb 120.2.12010000.2 2008/08/05 15:46:54 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_WK_LOC_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_LOCATION_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_WLR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_WLR_ATTRIBUTE1 in VARCHAR2
,P_WLR_ATTRIBUTE2 in VARCHAR2
,P_WLR_ATTRIBUTE3 in VARCHAR2
,P_WLR_ATTRIBUTE4 in VARCHAR2
,P_WLR_ATTRIBUTE5 in VARCHAR2
,P_WLR_ATTRIBUTE6 in VARCHAR2
,P_WLR_ATTRIBUTE7 in VARCHAR2
,P_WLR_ATTRIBUTE8 in VARCHAR2
,P_WLR_ATTRIBUTE9 in VARCHAR2
,P_WLR_ATTRIBUTE10 in VARCHAR2
,P_WLR_ATTRIBUTE11 in VARCHAR2
,P_WLR_ATTRIBUTE12 in VARCHAR2
,P_WLR_ATTRIBUTE13 in VARCHAR2
,P_WLR_ATTRIBUTE14 in VARCHAR2
,P_WLR_ATTRIBUTE15 in VARCHAR2
,P_WLR_ATTRIBUTE16 in VARCHAR2
,P_WLR_ATTRIBUTE17 in VARCHAR2
,P_WLR_ATTRIBUTE18 in VARCHAR2
,P_WLR_ATTRIBUTE19 in VARCHAR2
,P_WLR_ATTRIBUTE20 in VARCHAR2
,P_WLR_ATTRIBUTE21 in VARCHAR2
,P_WLR_ATTRIBUTE22 in VARCHAR2
,P_WLR_ATTRIBUTE23 in VARCHAR2
,P_WLR_ATTRIBUTE24 in VARCHAR2
,P_WLR_ATTRIBUTE25 in VARCHAR2
,P_WLR_ATTRIBUTE26 in VARCHAR2
,P_WLR_ATTRIBUTE27 in VARCHAR2
,P_WLR_ATTRIBUTE28 in VARCHAR2
,P_WLR_ATTRIBUTE29 in VARCHAR2
,P_WLR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_LOCATION_ID_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_WLR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_WLR_ATTRIBUTE1_O in VARCHAR2
,P_WLR_ATTRIBUTE2_O in VARCHAR2
,P_WLR_ATTRIBUTE3_O in VARCHAR2
,P_WLR_ATTRIBUTE4_O in VARCHAR2
,P_WLR_ATTRIBUTE5_O in VARCHAR2
,P_WLR_ATTRIBUTE6_O in VARCHAR2
,P_WLR_ATTRIBUTE7_O in VARCHAR2
,P_WLR_ATTRIBUTE8_O in VARCHAR2
,P_WLR_ATTRIBUTE9_O in VARCHAR2
,P_WLR_ATTRIBUTE10_O in VARCHAR2
,P_WLR_ATTRIBUTE11_O in VARCHAR2
,P_WLR_ATTRIBUTE12_O in VARCHAR2
,P_WLR_ATTRIBUTE13_O in VARCHAR2
,P_WLR_ATTRIBUTE14_O in VARCHAR2
,P_WLR_ATTRIBUTE15_O in VARCHAR2
,P_WLR_ATTRIBUTE16_O in VARCHAR2
,P_WLR_ATTRIBUTE17_O in VARCHAR2
,P_WLR_ATTRIBUTE18_O in VARCHAR2
,P_WLR_ATTRIBUTE19_O in VARCHAR2
,P_WLR_ATTRIBUTE20_O in VARCHAR2
,P_WLR_ATTRIBUTE21_O in VARCHAR2
,P_WLR_ATTRIBUTE22_O in VARCHAR2
,P_WLR_ATTRIBUTE23_O in VARCHAR2
,P_WLR_ATTRIBUTE24_O in VARCHAR2
,P_WLR_ATTRIBUTE25_O in VARCHAR2
,P_WLR_ATTRIBUTE26_O in VARCHAR2
,P_WLR_ATTRIBUTE27_O in VARCHAR2
,P_WLR_ATTRIBUTE28_O in VARCHAR2
,P_WLR_ATTRIBUTE29_O in VARCHAR2
,P_WLR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_wlr_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_wlr_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_wlr_RKU;

/
