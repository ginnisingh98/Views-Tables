--------------------------------------------------------
--  DDL for Package Body BEN_CEP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CEP_RKD" as
/* $Header: beceprhi.pkb 120.0 2005/05/28 01:00:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:59 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PRTN_ELIG_PRFL_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_MNDTRY_FLAG_O in VARCHAR2
,P_PRTN_ELIG_ID_O in NUMBER
,P_ELIGY_PRFL_ID_O in NUMBER
,P_ELIG_PRFL_TYPE_CD_O in VARCHAR2
,P_CEP_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CEP_ATTRIBUTE1_O in VARCHAR2
,P_CEP_ATTRIBUTE2_O in VARCHAR2
,P_CEP_ATTRIBUTE3_O in VARCHAR2
,P_CEP_ATTRIBUTE4_O in VARCHAR2
,P_CEP_ATTRIBUTE5_O in VARCHAR2
,P_CEP_ATTRIBUTE6_O in VARCHAR2
,P_CEP_ATTRIBUTE7_O in VARCHAR2
,P_CEP_ATTRIBUTE8_O in VARCHAR2
,P_CEP_ATTRIBUTE9_O in VARCHAR2
,P_CEP_ATTRIBUTE10_O in VARCHAR2
,P_CEP_ATTRIBUTE11_O in VARCHAR2
,P_CEP_ATTRIBUTE12_O in VARCHAR2
,P_CEP_ATTRIBUTE13_O in VARCHAR2
,P_CEP_ATTRIBUTE14_O in VARCHAR2
,P_CEP_ATTRIBUTE15_O in VARCHAR2
,P_CEP_ATTRIBUTE16_O in VARCHAR2
,P_CEP_ATTRIBUTE17_O in VARCHAR2
,P_CEP_ATTRIBUTE18_O in VARCHAR2
,P_CEP_ATTRIBUTE19_O in VARCHAR2
,P_CEP_ATTRIBUTE20_O in VARCHAR2
,P_CEP_ATTRIBUTE21_O in VARCHAR2
,P_CEP_ATTRIBUTE22_O in VARCHAR2
,P_CEP_ATTRIBUTE23_O in VARCHAR2
,P_CEP_ATTRIBUTE24_O in VARCHAR2
,P_CEP_ATTRIBUTE25_O in VARCHAR2
,P_CEP_ATTRIBUTE26_O in VARCHAR2
,P_CEP_ATTRIBUTE27_O in VARCHAR2
,P_CEP_ATTRIBUTE28_O in VARCHAR2
,P_CEP_ATTRIBUTE29_O in VARCHAR2
,P_CEP_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_COMPUTE_SCORE_FLAG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_cep_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_cep_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_cep_RKD;

/
