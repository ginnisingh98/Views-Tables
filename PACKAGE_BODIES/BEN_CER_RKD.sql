--------------------------------------------------------
--  DDL for Package Body BEN_CER_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CER_RKD" as
/* $Header: becerrhi.pkb 120.0 2005/05/28 01:00:50 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:00 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PRTN_ELIGY_RL_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PRTN_ELIG_ID_O in NUMBER
,P_FORMULA_ID_O in NUMBER
,P_DRVBL_FCTR_APLS_FLAG_O in VARCHAR2
,P_MNDTRY_FLAG_O in VARCHAR2
,P_ORDR_TO_APLY_NUM_O in NUMBER
,P_CER_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CER_ATTRIBUTE1_O in VARCHAR2
,P_CER_ATTRIBUTE2_O in VARCHAR2
,P_CER_ATTRIBUTE3_O in VARCHAR2
,P_CER_ATTRIBUTE4_O in VARCHAR2
,P_CER_ATTRIBUTE5_O in VARCHAR2
,P_CER_ATTRIBUTE6_O in VARCHAR2
,P_CER_ATTRIBUTE7_O in VARCHAR2
,P_CER_ATTRIBUTE8_O in VARCHAR2
,P_CER_ATTRIBUTE9_O in VARCHAR2
,P_CER_ATTRIBUTE10_O in VARCHAR2
,P_CER_ATTRIBUTE11_O in VARCHAR2
,P_CER_ATTRIBUTE12_O in VARCHAR2
,P_CER_ATTRIBUTE13_O in VARCHAR2
,P_CER_ATTRIBUTE14_O in VARCHAR2
,P_CER_ATTRIBUTE15_O in VARCHAR2
,P_CER_ATTRIBUTE16_O in VARCHAR2
,P_CER_ATTRIBUTE17_O in VARCHAR2
,P_CER_ATTRIBUTE18_O in VARCHAR2
,P_CER_ATTRIBUTE19_O in VARCHAR2
,P_CER_ATTRIBUTE20_O in VARCHAR2
,P_CER_ATTRIBUTE21_O in VARCHAR2
,P_CER_ATTRIBUTE22_O in VARCHAR2
,P_CER_ATTRIBUTE23_O in VARCHAR2
,P_CER_ATTRIBUTE24_O in VARCHAR2
,P_CER_ATTRIBUTE25_O in VARCHAR2
,P_CER_ATTRIBUTE26_O in VARCHAR2
,P_CER_ATTRIBUTE27_O in VARCHAR2
,P_CER_ATTRIBUTE28_O in VARCHAR2
,P_CER_ATTRIBUTE29_O in VARCHAR2
,P_CER_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_cer_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_cer_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_cer_RKD;

/