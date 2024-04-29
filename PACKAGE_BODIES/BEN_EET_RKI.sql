--------------------------------------------------------
--  DDL for Package Body BEN_EET_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EET_RKI" as
/* $Header: beeetrhi.pkb 120.1 2006/02/28 01:37:33 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:52 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ELIG_ENRLD_ANTHR_PTIP_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ENRL_DET_DT_CD in VARCHAR2
,P_ONLY_PLS_SUBJ_COBRA_FLAG in VARCHAR2
,P_PTIP_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EET_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EET_ATTRIBUTE1 in VARCHAR2
,P_EET_ATTRIBUTE2 in VARCHAR2
,P_EET_ATTRIBUTE3 in VARCHAR2
,P_EET_ATTRIBUTE4 in VARCHAR2
,P_EET_ATTRIBUTE5 in VARCHAR2
,P_EET_ATTRIBUTE6 in VARCHAR2
,P_EET_ATTRIBUTE7 in VARCHAR2
,P_EET_ATTRIBUTE8 in VARCHAR2
,P_EET_ATTRIBUTE9 in VARCHAR2
,P_EET_ATTRIBUTE10 in VARCHAR2
,P_EET_ATTRIBUTE11 in VARCHAR2
,P_EET_ATTRIBUTE12 in VARCHAR2
,P_EET_ATTRIBUTE13 in VARCHAR2
,P_EET_ATTRIBUTE14 in VARCHAR2
,P_EET_ATTRIBUTE15 in VARCHAR2
,P_EET_ATTRIBUTE16 in VARCHAR2
,P_EET_ATTRIBUTE17 in VARCHAR2
,P_EET_ATTRIBUTE18 in VARCHAR2
,P_EET_ATTRIBUTE19 in VARCHAR2
,P_EET_ATTRIBUTE20 in VARCHAR2
,P_EET_ATTRIBUTE21 in VARCHAR2
,P_EET_ATTRIBUTE22 in VARCHAR2
,P_EET_ATTRIBUTE23 in VARCHAR2
,P_EET_ATTRIBUTE24 in VARCHAR2
,P_EET_ATTRIBUTE25 in VARCHAR2
,P_EET_ATTRIBUTE26 in VARCHAR2
,P_EET_ATTRIBUTE27 in VARCHAR2
,P_EET_ATTRIBUTE28 in VARCHAR2
,P_EET_ATTRIBUTE29 in VARCHAR2
,P_EET_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_eet_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_eet_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_eet_RKI;

/
