--------------------------------------------------------
--  DDL for Package Body BEN_AGE_RATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AGE_RATES_BK2" as
/* $Header: beartapi.pkb 115.5 2002/12/31 23:56:23 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:28 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_AGE_RATES_A
(P_AGE_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_AGE_FCTR_ID in NUMBER
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ART_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ART_ATTRIBUTE1 in VARCHAR2
,P_ART_ATTRIBUTE2 in VARCHAR2
,P_ART_ATTRIBUTE3 in VARCHAR2
,P_ART_ATTRIBUTE4 in VARCHAR2
,P_ART_ATTRIBUTE5 in VARCHAR2
,P_ART_ATTRIBUTE6 in VARCHAR2
,P_ART_ATTRIBUTE7 in VARCHAR2
,P_ART_ATTRIBUTE8 in VARCHAR2
,P_ART_ATTRIBUTE9 in VARCHAR2
,P_ART_ATTRIBUTE10 in VARCHAR2
,P_ART_ATTRIBUTE11 in VARCHAR2
,P_ART_ATTRIBUTE12 in VARCHAR2
,P_ART_ATTRIBUTE13 in VARCHAR2
,P_ART_ATTRIBUTE14 in VARCHAR2
,P_ART_ATTRIBUTE15 in VARCHAR2
,P_ART_ATTRIBUTE16 in VARCHAR2
,P_ART_ATTRIBUTE17 in VARCHAR2
,P_ART_ATTRIBUTE18 in VARCHAR2
,P_ART_ATTRIBUTE19 in VARCHAR2
,P_ART_ATTRIBUTE20 in VARCHAR2
,P_ART_ATTRIBUTE21 in VARCHAR2
,P_ART_ATTRIBUTE22 in VARCHAR2
,P_ART_ATTRIBUTE23 in VARCHAR2
,P_ART_ATTRIBUTE24 in VARCHAR2
,P_ART_ATTRIBUTE25 in VARCHAR2
,P_ART_ATTRIBUTE26 in VARCHAR2
,P_ART_ATTRIBUTE27 in VARCHAR2
,P_ART_ATTRIBUTE28 in VARCHAR2
,P_ART_ATTRIBUTE29 in VARCHAR2
,P_ART_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_AGE_RATES_BK2.UPDATE_AGE_RATES_A', 10);
hr_utility.set_location(' Leaving: BEN_AGE_RATES_BK2.UPDATE_AGE_RATES_A', 20);
end UPDATE_AGE_RATES_A;
procedure UPDATE_AGE_RATES_B
(P_AGE_RT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_AGE_FCTR_ID in NUMBER
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ART_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ART_ATTRIBUTE1 in VARCHAR2
,P_ART_ATTRIBUTE2 in VARCHAR2
,P_ART_ATTRIBUTE3 in VARCHAR2
,P_ART_ATTRIBUTE4 in VARCHAR2
,P_ART_ATTRIBUTE5 in VARCHAR2
,P_ART_ATTRIBUTE6 in VARCHAR2
,P_ART_ATTRIBUTE7 in VARCHAR2
,P_ART_ATTRIBUTE8 in VARCHAR2
,P_ART_ATTRIBUTE9 in VARCHAR2
,P_ART_ATTRIBUTE10 in VARCHAR2
,P_ART_ATTRIBUTE11 in VARCHAR2
,P_ART_ATTRIBUTE12 in VARCHAR2
,P_ART_ATTRIBUTE13 in VARCHAR2
,P_ART_ATTRIBUTE14 in VARCHAR2
,P_ART_ATTRIBUTE15 in VARCHAR2
,P_ART_ATTRIBUTE16 in VARCHAR2
,P_ART_ATTRIBUTE17 in VARCHAR2
,P_ART_ATTRIBUTE18 in VARCHAR2
,P_ART_ATTRIBUTE19 in VARCHAR2
,P_ART_ATTRIBUTE20 in VARCHAR2
,P_ART_ATTRIBUTE21 in VARCHAR2
,P_ART_ATTRIBUTE22 in VARCHAR2
,P_ART_ATTRIBUTE23 in VARCHAR2
,P_ART_ATTRIBUTE24 in VARCHAR2
,P_ART_ATTRIBUTE25 in VARCHAR2
,P_ART_ATTRIBUTE26 in VARCHAR2
,P_ART_ATTRIBUTE27 in VARCHAR2
,P_ART_ATTRIBUTE28 in VARCHAR2
,P_ART_ATTRIBUTE29 in VARCHAR2
,P_ART_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_AGE_RATES_BK2.UPDATE_AGE_RATES_B', 10);
hr_utility.set_location(' Leaving: BEN_AGE_RATES_BK2.UPDATE_AGE_RATES_B', 20);
end UPDATE_AGE_RATES_B;
end BEN_AGE_RATES_BK2;

/