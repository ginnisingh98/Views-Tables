--------------------------------------------------------
--  DDL for Package Body BEN_OTHR_PTIP_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OTHR_PTIP_RT_BK2" as
/* $Header: beoprapi.pkb 115.1 2002/12/13 08:30:36 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:59 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_OTHR_PTIP_RT_A
(P_OTHR_PTIP_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_ONLY_PLS_SUBJ_COBRA_FLAG in VARCHAR2
,P_VRBL_RT_PRFL_ID in NUMBER
,P_PTIP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OPR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_OPR_ATTRIBUTE1 in VARCHAR2
,P_OPR_ATTRIBUTE2 in VARCHAR2
,P_OPR_ATTRIBUTE3 in VARCHAR2
,P_OPR_ATTRIBUTE4 in VARCHAR2
,P_OPR_ATTRIBUTE5 in VARCHAR2
,P_OPR_ATTRIBUTE6 in VARCHAR2
,P_OPR_ATTRIBUTE7 in VARCHAR2
,P_OPR_ATTRIBUTE8 in VARCHAR2
,P_OPR_ATTRIBUTE9 in VARCHAR2
,P_OPR_ATTRIBUTE10 in VARCHAR2
,P_OPR_ATTRIBUTE11 in VARCHAR2
,P_OPR_ATTRIBUTE12 in VARCHAR2
,P_OPR_ATTRIBUTE13 in VARCHAR2
,P_OPR_ATTRIBUTE14 in VARCHAR2
,P_OPR_ATTRIBUTE15 in VARCHAR2
,P_OPR_ATTRIBUTE16 in VARCHAR2
,P_OPR_ATTRIBUTE17 in VARCHAR2
,P_OPR_ATTRIBUTE18 in VARCHAR2
,P_OPR_ATTRIBUTE19 in VARCHAR2
,P_OPR_ATTRIBUTE20 in VARCHAR2
,P_OPR_ATTRIBUTE21 in VARCHAR2
,P_OPR_ATTRIBUTE22 in VARCHAR2
,P_OPR_ATTRIBUTE23 in VARCHAR2
,P_OPR_ATTRIBUTE24 in VARCHAR2
,P_OPR_ATTRIBUTE25 in VARCHAR2
,P_OPR_ATTRIBUTE26 in VARCHAR2
,P_OPR_ATTRIBUTE27 in VARCHAR2
,P_OPR_ATTRIBUTE28 in VARCHAR2
,P_OPR_ATTRIBUTE29 in VARCHAR2
,P_OPR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_OTHR_PTIP_RT_BK2.UPDATE_OTHR_PTIP_RT_A', 10);
hr_utility.set_location(' Leaving: BEN_OTHR_PTIP_RT_BK2.UPDATE_OTHR_PTIP_RT_A', 20);
end UPDATE_OTHR_PTIP_RT_A;
procedure UPDATE_OTHR_PTIP_RT_B
(P_OTHR_PTIP_RT_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_ONLY_PLS_SUBJ_COBRA_FLAG in VARCHAR2
,P_VRBL_RT_PRFL_ID in NUMBER
,P_PTIP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OPR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_OPR_ATTRIBUTE1 in VARCHAR2
,P_OPR_ATTRIBUTE2 in VARCHAR2
,P_OPR_ATTRIBUTE3 in VARCHAR2
,P_OPR_ATTRIBUTE4 in VARCHAR2
,P_OPR_ATTRIBUTE5 in VARCHAR2
,P_OPR_ATTRIBUTE6 in VARCHAR2
,P_OPR_ATTRIBUTE7 in VARCHAR2
,P_OPR_ATTRIBUTE8 in VARCHAR2
,P_OPR_ATTRIBUTE9 in VARCHAR2
,P_OPR_ATTRIBUTE10 in VARCHAR2
,P_OPR_ATTRIBUTE11 in VARCHAR2
,P_OPR_ATTRIBUTE12 in VARCHAR2
,P_OPR_ATTRIBUTE13 in VARCHAR2
,P_OPR_ATTRIBUTE14 in VARCHAR2
,P_OPR_ATTRIBUTE15 in VARCHAR2
,P_OPR_ATTRIBUTE16 in VARCHAR2
,P_OPR_ATTRIBUTE17 in VARCHAR2
,P_OPR_ATTRIBUTE18 in VARCHAR2
,P_OPR_ATTRIBUTE19 in VARCHAR2
,P_OPR_ATTRIBUTE20 in VARCHAR2
,P_OPR_ATTRIBUTE21 in VARCHAR2
,P_OPR_ATTRIBUTE22 in VARCHAR2
,P_OPR_ATTRIBUTE23 in VARCHAR2
,P_OPR_ATTRIBUTE24 in VARCHAR2
,P_OPR_ATTRIBUTE25 in VARCHAR2
,P_OPR_ATTRIBUTE26 in VARCHAR2
,P_OPR_ATTRIBUTE27 in VARCHAR2
,P_OPR_ATTRIBUTE28 in VARCHAR2
,P_OPR_ATTRIBUTE29 in VARCHAR2
,P_OPR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_OTHR_PTIP_RT_BK2.UPDATE_OTHR_PTIP_RT_B', 10);
hr_utility.set_location(' Leaving: BEN_OTHR_PTIP_RT_BK2.UPDATE_OTHR_PTIP_RT_B', 20);
end UPDATE_OTHR_PTIP_RT_B;
end BEN_OTHR_PTIP_RT_BK2;

/
