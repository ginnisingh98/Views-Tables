--------------------------------------------------------
--  DDL for Package Body BEN_EGD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGD_RKU" as
/* $Header: beegdrhi.pkb 120.0.12000000.1 2007/01/19 04:50:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/10/10 13:32:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ELIG_DPNT_ID in NUMBER
,P_CREATE_DT in DATE
,P_ELIG_STRT_DT in DATE
,P_ELIG_THRU_DT in DATE
,P_OVRDN_FLAG in VARCHAR2
,P_OVRDN_THRU_DT in DATE
,P_INELG_RSN_CD in VARCHAR2
,P_DPNT_INELIG_FLAG in VARCHAR2
,P_ELIG_PER_ELCTBL_CHC_ID in NUMBER
,P_PER_IN_LER_ID in NUMBER
,P_ELIG_PER_ID in NUMBER
,P_ELIG_PER_OPT_ID in NUMBER
,P_ELIG_CVRD_DPNT_ID in NUMBER
,P_DPNT_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EGD_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EGD_ATTRIBUTE1 in VARCHAR2
,P_EGD_ATTRIBUTE2 in VARCHAR2
,P_EGD_ATTRIBUTE3 in VARCHAR2
,P_EGD_ATTRIBUTE4 in VARCHAR2
,P_EGD_ATTRIBUTE5 in VARCHAR2
,P_EGD_ATTRIBUTE6 in VARCHAR2
,P_EGD_ATTRIBUTE7 in VARCHAR2
,P_EGD_ATTRIBUTE8 in VARCHAR2
,P_EGD_ATTRIBUTE9 in VARCHAR2
,P_EGD_ATTRIBUTE10 in VARCHAR2
,P_EGD_ATTRIBUTE11 in VARCHAR2
,P_EGD_ATTRIBUTE12 in VARCHAR2
,P_EGD_ATTRIBUTE13 in VARCHAR2
,P_EGD_ATTRIBUTE14 in VARCHAR2
,P_EGD_ATTRIBUTE15 in VARCHAR2
,P_EGD_ATTRIBUTE16 in VARCHAR2
,P_EGD_ATTRIBUTE17 in VARCHAR2
,P_EGD_ATTRIBUTE18 in VARCHAR2
,P_EGD_ATTRIBUTE19 in VARCHAR2
,P_EGD_ATTRIBUTE20 in VARCHAR2
,P_EGD_ATTRIBUTE21 in VARCHAR2
,P_EGD_ATTRIBUTE22 in VARCHAR2
,P_EGD_ATTRIBUTE23 in VARCHAR2
,P_EGD_ATTRIBUTE24 in VARCHAR2
,P_EGD_ATTRIBUTE25 in VARCHAR2
,P_EGD_ATTRIBUTE26 in VARCHAR2
,P_EGD_ATTRIBUTE27 in VARCHAR2
,P_EGD_ATTRIBUTE28 in VARCHAR2
,P_EGD_ATTRIBUTE29 in VARCHAR2
,P_EGD_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_CREATE_DT_O in DATE
,P_ELIG_STRT_DT_O in DATE
,P_ELIG_THRU_DT_O in DATE
,P_OVRDN_FLAG_O in VARCHAR2
,P_OVRDN_THRU_DT_O in DATE
,P_INELG_RSN_CD_O in VARCHAR2
,P_DPNT_INELIG_FLAG_O in VARCHAR2
,P_ELIG_PER_ELCTBL_CHC_ID_O in NUMBER
,P_PER_IN_LER_ID_O in NUMBER
,P_ELIG_PER_ID_O in NUMBER
,P_ELIG_PER_OPT_ID_O in NUMBER
,P_ELIG_CVRD_DPNT_ID_O in NUMBER
,P_DPNT_PERSON_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_EGD_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_EGD_ATTRIBUTE1_O in VARCHAR2
,P_EGD_ATTRIBUTE2_O in VARCHAR2
,P_EGD_ATTRIBUTE3_O in VARCHAR2
,P_EGD_ATTRIBUTE4_O in VARCHAR2
,P_EGD_ATTRIBUTE5_O in VARCHAR2
,P_EGD_ATTRIBUTE6_O in VARCHAR2
,P_EGD_ATTRIBUTE7_O in VARCHAR2
,P_EGD_ATTRIBUTE8_O in VARCHAR2
,P_EGD_ATTRIBUTE9_O in VARCHAR2
,P_EGD_ATTRIBUTE10_O in VARCHAR2
,P_EGD_ATTRIBUTE11_O in VARCHAR2
,P_EGD_ATTRIBUTE12_O in VARCHAR2
,P_EGD_ATTRIBUTE13_O in VARCHAR2
,P_EGD_ATTRIBUTE14_O in VARCHAR2
,P_EGD_ATTRIBUTE15_O in VARCHAR2
,P_EGD_ATTRIBUTE16_O in VARCHAR2
,P_EGD_ATTRIBUTE17_O in VARCHAR2
,P_EGD_ATTRIBUTE18_O in VARCHAR2
,P_EGD_ATTRIBUTE19_O in VARCHAR2
,P_EGD_ATTRIBUTE20_O in VARCHAR2
,P_EGD_ATTRIBUTE21_O in VARCHAR2
,P_EGD_ATTRIBUTE22_O in VARCHAR2
,P_EGD_ATTRIBUTE23_O in VARCHAR2
,P_EGD_ATTRIBUTE24_O in VARCHAR2
,P_EGD_ATTRIBUTE25_O in VARCHAR2
,P_EGD_ATTRIBUTE26_O in VARCHAR2
,P_EGD_ATTRIBUTE27_O in VARCHAR2
,P_EGD_ATTRIBUTE28_O in VARCHAR2
,P_EGD_ATTRIBUTE29_O in VARCHAR2
,P_EGD_ATTRIBUTE30_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_egd_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_egd_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_egd_RKU;

/