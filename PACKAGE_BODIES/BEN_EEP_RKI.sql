--------------------------------------------------------
--  DDL for Package Body BEN_EEP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EEP_RKI" as
/* $Header: beeeprhi.pkb 120.1 2006/02/28 01:41:15 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:52 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ELIG_ENRLD_ANTHR_PL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ENRL_DET_DT_CD in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_PL_ID in NUMBER
,P_EEP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EEP_ATTRIBUTE1 in VARCHAR2
,P_EEP_ATTRIBUTE2 in VARCHAR2
,P_EEP_ATTRIBUTE3 in VARCHAR2
,P_EEP_ATTRIBUTE4 in VARCHAR2
,P_EEP_ATTRIBUTE5 in VARCHAR2
,P_EEP_ATTRIBUTE6 in VARCHAR2
,P_EEP_ATTRIBUTE7 in VARCHAR2
,P_EEP_ATTRIBUTE8 in VARCHAR2
,P_EEP_ATTRIBUTE9 in VARCHAR2
,P_EEP_ATTRIBUTE10 in VARCHAR2
,P_EEP_ATTRIBUTE11 in VARCHAR2
,P_EEP_ATTRIBUTE12 in VARCHAR2
,P_EEP_ATTRIBUTE13 in VARCHAR2
,P_EEP_ATTRIBUTE14 in VARCHAR2
,P_EEP_ATTRIBUTE15 in VARCHAR2
,P_EEP_ATTRIBUTE16 in VARCHAR2
,P_EEP_ATTRIBUTE17 in VARCHAR2
,P_EEP_ATTRIBUTE18 in VARCHAR2
,P_EEP_ATTRIBUTE19 in VARCHAR2
,P_EEP_ATTRIBUTE20 in VARCHAR2
,P_EEP_ATTRIBUTE21 in VARCHAR2
,P_EEP_ATTRIBUTE22 in VARCHAR2
,P_EEP_ATTRIBUTE23 in VARCHAR2
,P_EEP_ATTRIBUTE24 in VARCHAR2
,P_EEP_ATTRIBUTE25 in VARCHAR2
,P_EEP_ATTRIBUTE26 in VARCHAR2
,P_EEP_ATTRIBUTE27 in VARCHAR2
,P_EEP_ATTRIBUTE28 in VARCHAR2
,P_EEP_ATTRIBUTE29 in VARCHAR2
,P_EEP_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_eep_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_eep_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_eep_RKI;

/
