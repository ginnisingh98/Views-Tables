--------------------------------------------------------
--  DDL for Package Body BEN_ENRLD_ANTHR_PLIP_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRLD_ANTHR_PLIP_RT_BK2" as
/* $Header: beearapi.pkb 115.1 2002/12/16 09:36:17 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:37 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ENRLD_ANTHR_PLIP_RT_A
(P_ENRLD_ANTHR_PLIP_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_ENRL_DET_DT_CD in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_PLIP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EAR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EAR_ATTRIBUTE1 in VARCHAR2
,P_EAR_ATTRIBUTE2 in VARCHAR2
,P_EAR_ATTRIBUTE3 in VARCHAR2
,P_EAR_ATTRIBUTE4 in VARCHAR2
,P_EAR_ATTRIBUTE5 in VARCHAR2
,P_EAR_ATTRIBUTE6 in VARCHAR2
,P_EAR_ATTRIBUTE7 in VARCHAR2
,P_EAR_ATTRIBUTE8 in VARCHAR2
,P_EAR_ATTRIBUTE9 in VARCHAR2
,P_EAR_ATTRIBUTE10 in VARCHAR2
,P_EAR_ATTRIBUTE11 in VARCHAR2
,P_EAR_ATTRIBUTE12 in VARCHAR2
,P_EAR_ATTRIBUTE13 in VARCHAR2
,P_EAR_ATTRIBUTE14 in VARCHAR2
,P_EAR_ATTRIBUTE15 in VARCHAR2
,P_EAR_ATTRIBUTE16 in VARCHAR2
,P_EAR_ATTRIBUTE17 in VARCHAR2
,P_EAR_ATTRIBUTE18 in VARCHAR2
,P_EAR_ATTRIBUTE19 in VARCHAR2
,P_EAR_ATTRIBUTE20 in VARCHAR2
,P_EAR_ATTRIBUTE21 in VARCHAR2
,P_EAR_ATTRIBUTE22 in VARCHAR2
,P_EAR_ATTRIBUTE23 in VARCHAR2
,P_EAR_ATTRIBUTE24 in VARCHAR2
,P_EAR_ATTRIBUTE25 in VARCHAR2
,P_EAR_ATTRIBUTE26 in VARCHAR2
,P_EAR_ATTRIBUTE27 in VARCHAR2
,P_EAR_ATTRIBUTE28 in VARCHAR2
,P_EAR_ATTRIBUTE29 in VARCHAR2
,P_EAR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ENRLD_ANTHR_PLIP_RT_BK2.UPDATE_ENRLD_ANTHR_PLIP_RT_A', 10);
hr_utility.set_location(' Leaving: BEN_ENRLD_ANTHR_PLIP_RT_BK2.UPDATE_ENRLD_ANTHR_PLIP_RT_A', 20);
end UPDATE_ENRLD_ANTHR_PLIP_RT_A;
procedure UPDATE_ENRLD_ANTHR_PLIP_RT_B
(P_ENRLD_ANTHR_PLIP_RT_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ENRL_DET_DT_CD in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_PLIP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EAR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EAR_ATTRIBUTE1 in VARCHAR2
,P_EAR_ATTRIBUTE2 in VARCHAR2
,P_EAR_ATTRIBUTE3 in VARCHAR2
,P_EAR_ATTRIBUTE4 in VARCHAR2
,P_EAR_ATTRIBUTE5 in VARCHAR2
,P_EAR_ATTRIBUTE6 in VARCHAR2
,P_EAR_ATTRIBUTE7 in VARCHAR2
,P_EAR_ATTRIBUTE8 in VARCHAR2
,P_EAR_ATTRIBUTE9 in VARCHAR2
,P_EAR_ATTRIBUTE10 in VARCHAR2
,P_EAR_ATTRIBUTE11 in VARCHAR2
,P_EAR_ATTRIBUTE12 in VARCHAR2
,P_EAR_ATTRIBUTE13 in VARCHAR2
,P_EAR_ATTRIBUTE14 in VARCHAR2
,P_EAR_ATTRIBUTE15 in VARCHAR2
,P_EAR_ATTRIBUTE16 in VARCHAR2
,P_EAR_ATTRIBUTE17 in VARCHAR2
,P_EAR_ATTRIBUTE18 in VARCHAR2
,P_EAR_ATTRIBUTE19 in VARCHAR2
,P_EAR_ATTRIBUTE20 in VARCHAR2
,P_EAR_ATTRIBUTE21 in VARCHAR2
,P_EAR_ATTRIBUTE22 in VARCHAR2
,P_EAR_ATTRIBUTE23 in VARCHAR2
,P_EAR_ATTRIBUTE24 in VARCHAR2
,P_EAR_ATTRIBUTE25 in VARCHAR2
,P_EAR_ATTRIBUTE26 in VARCHAR2
,P_EAR_ATTRIBUTE27 in VARCHAR2
,P_EAR_ATTRIBUTE28 in VARCHAR2
,P_EAR_ATTRIBUTE29 in VARCHAR2
,P_EAR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ENRLD_ANTHR_PLIP_RT_BK2.UPDATE_ENRLD_ANTHR_PLIP_RT_B', 10);
hr_utility.set_location(' Leaving: BEN_ENRLD_ANTHR_PLIP_RT_BK2.UPDATE_ENRLD_ANTHR_PLIP_RT_B', 20);
end UPDATE_ENRLD_ANTHR_PLIP_RT_B;
end BEN_ENRLD_ANTHR_PLIP_RT_BK2;

/