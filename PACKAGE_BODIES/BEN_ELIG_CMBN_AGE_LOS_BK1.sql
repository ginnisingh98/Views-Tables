--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_CMBN_AGE_LOS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_CMBN_AGE_LOS_BK1" as
/* $Header: beecpapi.pkb 120.0 2005/05/28 01:51:10 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:42 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ELIG_CMBN_AGE_LOS_A
(P_ELIG_CMBN_AGE_LOS_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_CMBN_AGE_LOS_FCTR_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_MNDTRY_FLAG in VARCHAR2
,P_ECP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ECP_ATTRIBUTE1 in VARCHAR2
,P_ECP_ATTRIBUTE2 in VARCHAR2
,P_ECP_ATTRIBUTE3 in VARCHAR2
,P_ECP_ATTRIBUTE4 in VARCHAR2
,P_ECP_ATTRIBUTE5 in VARCHAR2
,P_ECP_ATTRIBUTE6 in VARCHAR2
,P_ECP_ATTRIBUTE7 in VARCHAR2
,P_ECP_ATTRIBUTE8 in VARCHAR2
,P_ECP_ATTRIBUTE9 in VARCHAR2
,P_ECP_ATTRIBUTE10 in VARCHAR2
,P_ECP_ATTRIBUTE11 in VARCHAR2
,P_ECP_ATTRIBUTE12 in VARCHAR2
,P_ECP_ATTRIBUTE13 in VARCHAR2
,P_ECP_ATTRIBUTE14 in VARCHAR2
,P_ECP_ATTRIBUTE15 in VARCHAR2
,P_ECP_ATTRIBUTE16 in VARCHAR2
,P_ECP_ATTRIBUTE17 in VARCHAR2
,P_ECP_ATTRIBUTE18 in VARCHAR2
,P_ECP_ATTRIBUTE19 in VARCHAR2
,P_ECP_ATTRIBUTE20 in VARCHAR2
,P_ECP_ATTRIBUTE21 in VARCHAR2
,P_ECP_ATTRIBUTE22 in VARCHAR2
,P_ECP_ATTRIBUTE23 in VARCHAR2
,P_ECP_ATTRIBUTE24 in VARCHAR2
,P_ECP_ATTRIBUTE25 in VARCHAR2
,P_ECP_ATTRIBUTE26 in VARCHAR2
,P_ECP_ATTRIBUTE27 in VARCHAR2
,P_ECP_ATTRIBUTE28 in VARCHAR2
,P_ECP_ATTRIBUTE29 in VARCHAR2
,P_ECP_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_CMBN_AGE_LOS_BK1.CREATE_ELIG_CMBN_AGE_LOS_A', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_CMBN_AGE_LOS_BK1.CREATE_ELIG_CMBN_AGE_LOS_A', 20);
end CREATE_ELIG_CMBN_AGE_LOS_A;
procedure CREATE_ELIG_CMBN_AGE_LOS_B
(P_BUSINESS_GROUP_ID in NUMBER
,P_CMBN_AGE_LOS_FCTR_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_MNDTRY_FLAG in VARCHAR2
,P_ECP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ECP_ATTRIBUTE1 in VARCHAR2
,P_ECP_ATTRIBUTE2 in VARCHAR2
,P_ECP_ATTRIBUTE3 in VARCHAR2
,P_ECP_ATTRIBUTE4 in VARCHAR2
,P_ECP_ATTRIBUTE5 in VARCHAR2
,P_ECP_ATTRIBUTE6 in VARCHAR2
,P_ECP_ATTRIBUTE7 in VARCHAR2
,P_ECP_ATTRIBUTE8 in VARCHAR2
,P_ECP_ATTRIBUTE9 in VARCHAR2
,P_ECP_ATTRIBUTE10 in VARCHAR2
,P_ECP_ATTRIBUTE11 in VARCHAR2
,P_ECP_ATTRIBUTE12 in VARCHAR2
,P_ECP_ATTRIBUTE13 in VARCHAR2
,P_ECP_ATTRIBUTE14 in VARCHAR2
,P_ECP_ATTRIBUTE15 in VARCHAR2
,P_ECP_ATTRIBUTE16 in VARCHAR2
,P_ECP_ATTRIBUTE17 in VARCHAR2
,P_ECP_ATTRIBUTE18 in VARCHAR2
,P_ECP_ATTRIBUTE19 in VARCHAR2
,P_ECP_ATTRIBUTE20 in VARCHAR2
,P_ECP_ATTRIBUTE21 in VARCHAR2
,P_ECP_ATTRIBUTE22 in VARCHAR2
,P_ECP_ATTRIBUTE23 in VARCHAR2
,P_ECP_ATTRIBUTE24 in VARCHAR2
,P_ECP_ATTRIBUTE25 in VARCHAR2
,P_ECP_ATTRIBUTE26 in VARCHAR2
,P_ECP_ATTRIBUTE27 in VARCHAR2
,P_ECP_ATTRIBUTE28 in VARCHAR2
,P_ECP_ATTRIBUTE29 in VARCHAR2
,P_ECP_ATTRIBUTE30 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_CMBN_AGE_LOS_BK1.CREATE_ELIG_CMBN_AGE_LOS_B', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_CMBN_AGE_LOS_BK1.CREATE_ELIG_CMBN_AGE_LOS_B', 20);
end CREATE_ELIG_CMBN_AGE_LOS_B;
end BEN_ELIG_CMBN_AGE_LOS_BK1;

/