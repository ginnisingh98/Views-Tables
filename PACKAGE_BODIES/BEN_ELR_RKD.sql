--------------------------------------------------------
--  DDL for Package Body BEN_ELR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELR_RKD" as
/* $Header: beelrrhi.pkb 120.1 2006/03/01 04:42:28 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ELIG_LOA_RSN_PRTE_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ELIGY_PRFL_ID_O in NUMBER
,P_ORDR_NUM_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_ELR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ELR_ATTRIBUTE1_O in VARCHAR2
,P_ELR_ATTRIBUTE2_O in VARCHAR2
,P_ELR_ATTRIBUTE3_O in VARCHAR2
,P_ELR_ATTRIBUTE4_O in VARCHAR2
,P_ELR_ATTRIBUTE5_O in VARCHAR2
,P_ELR_ATTRIBUTE6_O in VARCHAR2
,P_ELR_ATTRIBUTE7_O in VARCHAR2
,P_ELR_ATTRIBUTE8_O in VARCHAR2
,P_ELR_ATTRIBUTE9_O in VARCHAR2
,P_ELR_ATTRIBUTE10_O in VARCHAR2
,P_ELR_ATTRIBUTE11_O in VARCHAR2
,P_ELR_ATTRIBUTE12_O in VARCHAR2
,P_ELR_ATTRIBUTE13_O in VARCHAR2
,P_ELR_ATTRIBUTE14_O in VARCHAR2
,P_ELR_ATTRIBUTE15_O in VARCHAR2
,P_ELR_ATTRIBUTE16_O in VARCHAR2
,P_ELR_ATTRIBUTE17_O in VARCHAR2
,P_ELR_ATTRIBUTE18_O in VARCHAR2
,P_ELR_ATTRIBUTE19_O in VARCHAR2
,P_ELR_ATTRIBUTE20_O in VARCHAR2
,P_ELR_ATTRIBUTE21_O in VARCHAR2
,P_ELR_ATTRIBUTE22_O in VARCHAR2
,P_ELR_ATTRIBUTE23_O in VARCHAR2
,P_ELR_ATTRIBUTE24_O in VARCHAR2
,P_ELR_ATTRIBUTE25_O in VARCHAR2
,P_ELR_ATTRIBUTE26_O in VARCHAR2
,P_ELR_ATTRIBUTE27_O in VARCHAR2
,P_ELR_ATTRIBUTE28_O in VARCHAR2
,P_ELR_ATTRIBUTE29_O in VARCHAR2
,P_ELR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_ABSENCE_ATTENDANCE_TYPE_ID_O in NUMBER
,P_ABS_ATTENDANCE_REASON_ID_O in NUMBER
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_elr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_elr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_elr_RKD;

/
