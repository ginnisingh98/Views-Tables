--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_SVC_AREA_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_SVC_AREA_PRTE_BK2" as
/* $Header: beesaapi.pkb 120.0 2005/05/28 02:53:41 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:24 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ELIG_SVC_AREA_PRTE_A
(P_ELIG_SVC_AREA_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_SVC_AREA_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ESA_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ESA_ATTRIBUTE1 in VARCHAR2
,P_ESA_ATTRIBUTE2 in VARCHAR2
,P_ESA_ATTRIBUTE3 in VARCHAR2
,P_ESA_ATTRIBUTE4 in VARCHAR2
,P_ESA_ATTRIBUTE5 in VARCHAR2
,P_ESA_ATTRIBUTE6 in VARCHAR2
,P_ESA_ATTRIBUTE7 in VARCHAR2
,P_ESA_ATTRIBUTE8 in VARCHAR2
,P_ESA_ATTRIBUTE9 in VARCHAR2
,P_ESA_ATTRIBUTE10 in VARCHAR2
,P_ESA_ATTRIBUTE11 in VARCHAR2
,P_ESA_ATTRIBUTE12 in VARCHAR2
,P_ESA_ATTRIBUTE13 in VARCHAR2
,P_ESA_ATTRIBUTE14 in VARCHAR2
,P_ESA_ATTRIBUTE15 in VARCHAR2
,P_ESA_ATTRIBUTE16 in VARCHAR2
,P_ESA_ATTRIBUTE17 in VARCHAR2
,P_ESA_ATTRIBUTE18 in VARCHAR2
,P_ESA_ATTRIBUTE19 in VARCHAR2
,P_ESA_ATTRIBUTE20 in VARCHAR2
,P_ESA_ATTRIBUTE21 in VARCHAR2
,P_ESA_ATTRIBUTE22 in VARCHAR2
,P_ESA_ATTRIBUTE23 in VARCHAR2
,P_ESA_ATTRIBUTE24 in VARCHAR2
,P_ESA_ATTRIBUTE25 in VARCHAR2
,P_ESA_ATTRIBUTE26 in VARCHAR2
,P_ESA_ATTRIBUTE27 in VARCHAR2
,P_ESA_ATTRIBUTE28 in VARCHAR2
,P_ESA_ATTRIBUTE29 in VARCHAR2
,P_ESA_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_SVC_AREA_PRTE_BK2.UPDATE_ELIG_SVC_AREA_PRTE_A', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_SVC_AREA_PRTE_BK2.UPDATE_ELIG_SVC_AREA_PRTE_A', 20);
end UPDATE_ELIG_SVC_AREA_PRTE_A;
procedure UPDATE_ELIG_SVC_AREA_PRTE_B
(P_ELIG_SVC_AREA_PRTE_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_SVC_AREA_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ESA_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ESA_ATTRIBUTE1 in VARCHAR2
,P_ESA_ATTRIBUTE2 in VARCHAR2
,P_ESA_ATTRIBUTE3 in VARCHAR2
,P_ESA_ATTRIBUTE4 in VARCHAR2
,P_ESA_ATTRIBUTE5 in VARCHAR2
,P_ESA_ATTRIBUTE6 in VARCHAR2
,P_ESA_ATTRIBUTE7 in VARCHAR2
,P_ESA_ATTRIBUTE8 in VARCHAR2
,P_ESA_ATTRIBUTE9 in VARCHAR2
,P_ESA_ATTRIBUTE10 in VARCHAR2
,P_ESA_ATTRIBUTE11 in VARCHAR2
,P_ESA_ATTRIBUTE12 in VARCHAR2
,P_ESA_ATTRIBUTE13 in VARCHAR2
,P_ESA_ATTRIBUTE14 in VARCHAR2
,P_ESA_ATTRIBUTE15 in VARCHAR2
,P_ESA_ATTRIBUTE16 in VARCHAR2
,P_ESA_ATTRIBUTE17 in VARCHAR2
,P_ESA_ATTRIBUTE18 in VARCHAR2
,P_ESA_ATTRIBUTE19 in VARCHAR2
,P_ESA_ATTRIBUTE20 in VARCHAR2
,P_ESA_ATTRIBUTE21 in VARCHAR2
,P_ESA_ATTRIBUTE22 in VARCHAR2
,P_ESA_ATTRIBUTE23 in VARCHAR2
,P_ESA_ATTRIBUTE24 in VARCHAR2
,P_ESA_ATTRIBUTE25 in VARCHAR2
,P_ESA_ATTRIBUTE26 in VARCHAR2
,P_ESA_ATTRIBUTE27 in VARCHAR2
,P_ESA_ATTRIBUTE28 in VARCHAR2
,P_ESA_ATTRIBUTE29 in VARCHAR2
,P_ESA_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_SVC_AREA_PRTE_BK2.UPDATE_ELIG_SVC_AREA_PRTE_B', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_SVC_AREA_PRTE_BK2.UPDATE_ELIG_SVC_AREA_PRTE_B', 20);
end UPDATE_ELIG_SVC_AREA_PRTE_B;
end BEN_ELIG_SVC_AREA_PRTE_BK2;

/
