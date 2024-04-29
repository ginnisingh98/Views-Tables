--------------------------------------------------------
--  DDL for Package Body BEN_DOT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DOT_RKU" as
/* $Header: bedotrhi.pkb 120.2 2006/03/30 23:59:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:32 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_DPNT_OTHR_PTIP_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_PTIP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_DOT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_DOT_ATTRIBUTE1 in VARCHAR2
,P_DOT_ATTRIBUTE2 in VARCHAR2
,P_DOT_ATTRIBUTE3 in VARCHAR2
,P_DOT_ATTRIBUTE4 in VARCHAR2
,P_DOT_ATTRIBUTE5 in VARCHAR2
,P_DOT_ATTRIBUTE6 in VARCHAR2
,P_DOT_ATTRIBUTE7 in VARCHAR2
,P_DOT_ATTRIBUTE8 in VARCHAR2
,P_DOT_ATTRIBUTE9 in VARCHAR2
,P_DOT_ATTRIBUTE10 in VARCHAR2
,P_DOT_ATTRIBUTE11 in VARCHAR2
,P_DOT_ATTRIBUTE12 in VARCHAR2
,P_DOT_ATTRIBUTE13 in VARCHAR2
,P_DOT_ATTRIBUTE14 in VARCHAR2
,P_DOT_ATTRIBUTE15 in VARCHAR2
,P_DOT_ATTRIBUTE16 in VARCHAR2
,P_DOT_ATTRIBUTE17 in VARCHAR2
,P_DOT_ATTRIBUTE18 in VARCHAR2
,P_DOT_ATTRIBUTE19 in VARCHAR2
,P_DOT_ATTRIBUTE20 in VARCHAR2
,P_DOT_ATTRIBUTE21 in VARCHAR2
,P_DOT_ATTRIBUTE22 in VARCHAR2
,P_DOT_ATTRIBUTE23 in VARCHAR2
,P_DOT_ATTRIBUTE24 in VARCHAR2
,P_DOT_ATTRIBUTE25 in VARCHAR2
,P_DOT_ATTRIBUTE26 in VARCHAR2
,P_DOT_ATTRIBUTE27 in VARCHAR2
,P_DOT_ATTRIBUTE28 in VARCHAR2
,P_DOT_ATTRIBUTE29 in VARCHAR2
,P_DOT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_EXCLD_FLAG_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_PTIP_ID_O in NUMBER
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DOT_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_DOT_ATTRIBUTE1_O in VARCHAR2
,P_DOT_ATTRIBUTE2_O in VARCHAR2
,P_DOT_ATTRIBUTE3_O in VARCHAR2
,P_DOT_ATTRIBUTE4_O in VARCHAR2
,P_DOT_ATTRIBUTE5_O in VARCHAR2
,P_DOT_ATTRIBUTE6_O in VARCHAR2
,P_DOT_ATTRIBUTE7_O in VARCHAR2
,P_DOT_ATTRIBUTE8_O in VARCHAR2
,P_DOT_ATTRIBUTE9_O in VARCHAR2
,P_DOT_ATTRIBUTE10_O in VARCHAR2
,P_DOT_ATTRIBUTE11_O in VARCHAR2
,P_DOT_ATTRIBUTE12_O in VARCHAR2
,P_DOT_ATTRIBUTE13_O in VARCHAR2
,P_DOT_ATTRIBUTE14_O in VARCHAR2
,P_DOT_ATTRIBUTE15_O in VARCHAR2
,P_DOT_ATTRIBUTE16_O in VARCHAR2
,P_DOT_ATTRIBUTE17_O in VARCHAR2
,P_DOT_ATTRIBUTE18_O in VARCHAR2
,P_DOT_ATTRIBUTE19_O in VARCHAR2
,P_DOT_ATTRIBUTE20_O in VARCHAR2
,P_DOT_ATTRIBUTE21_O in VARCHAR2
,P_DOT_ATTRIBUTE22_O in VARCHAR2
,P_DOT_ATTRIBUTE23_O in VARCHAR2
,P_DOT_ATTRIBUTE24_O in VARCHAR2
,P_DOT_ATTRIBUTE25_O in VARCHAR2
,P_DOT_ATTRIBUTE26_O in VARCHAR2
,P_DOT_ATTRIBUTE27_O in VARCHAR2
,P_DOT_ATTRIBUTE28_O in VARCHAR2
,P_DOT_ATTRIBUTE29_O in VARCHAR2
,P_DOT_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_DOT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_DOT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_DOT_RKU;

/