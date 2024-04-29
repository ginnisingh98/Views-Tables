--------------------------------------------------------
--  DDL for Package Body BEN_SCHEDD_HRS_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SCHEDD_HRS_RATE_BK2" as
/* $Header: beshrapi.pkb 115.4 2002/12/16 12:02:19 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:56 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_SCHEDD_HRS_RATE_A
(P_SCHEDD_HRS_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_VRBL_RT_PRFL_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_FREQ_CD in VARCHAR2
,P_HRS_NUM in NUMBER
,P_MAX_HRS_NUM in NUMBER
,P_SCHEDD_HRS_RL in NUMBER
,P_DETERMINATION_CD in VARCHAR2
,P_DETERMINATION_RL in NUMBER
,P_ROUNDING_CD in VARCHAR2
,P_ROUNDING_RL in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SHR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_SHR_ATTRIBUTE1 in VARCHAR2
,P_SHR_ATTRIBUTE2 in VARCHAR2
,P_SHR_ATTRIBUTE3 in VARCHAR2
,P_SHR_ATTRIBUTE4 in VARCHAR2
,P_SHR_ATTRIBUTE5 in VARCHAR2
,P_SHR_ATTRIBUTE6 in VARCHAR2
,P_SHR_ATTRIBUTE7 in VARCHAR2
,P_SHR_ATTRIBUTE8 in VARCHAR2
,P_SHR_ATTRIBUTE9 in VARCHAR2
,P_SHR_ATTRIBUTE10 in VARCHAR2
,P_SHR_ATTRIBUTE11 in VARCHAR2
,P_SHR_ATTRIBUTE12 in VARCHAR2
,P_SHR_ATTRIBUTE13 in VARCHAR2
,P_SHR_ATTRIBUTE14 in VARCHAR2
,P_SHR_ATTRIBUTE15 in VARCHAR2
,P_SHR_ATTRIBUTE16 in VARCHAR2
,P_SHR_ATTRIBUTE17 in VARCHAR2
,P_SHR_ATTRIBUTE18 in VARCHAR2
,P_SHR_ATTRIBUTE19 in VARCHAR2
,P_SHR_ATTRIBUTE20 in VARCHAR2
,P_SHR_ATTRIBUTE21 in VARCHAR2
,P_SHR_ATTRIBUTE22 in VARCHAR2
,P_SHR_ATTRIBUTE23 in VARCHAR2
,P_SHR_ATTRIBUTE24 in VARCHAR2
,P_SHR_ATTRIBUTE25 in VARCHAR2
,P_SHR_ATTRIBUTE26 in VARCHAR2
,P_SHR_ATTRIBUTE27 in VARCHAR2
,P_SHR_ATTRIBUTE28 in VARCHAR2
,P_SHR_ATTRIBUTE29 in VARCHAR2
,P_SHR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_SCHEDD_HRS_RATE_BK2.UPDATE_SCHEDD_HRS_RATE_A', 10);
hr_utility.set_location(' Leaving: BEN_SCHEDD_HRS_RATE_BK2.UPDATE_SCHEDD_HRS_RATE_A', 20);
end UPDATE_SCHEDD_HRS_RATE_A;
procedure UPDATE_SCHEDD_HRS_RATE_B
(P_SCHEDD_HRS_RT_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_FREQ_CD in VARCHAR2
,P_HRS_NUM in NUMBER
,P_MAX_HRS_NUM in NUMBER
,P_SCHEDD_HRS_RL in NUMBER
,P_DETERMINATION_CD in VARCHAR2
,P_DETERMINATION_RL in NUMBER
,P_ROUNDING_CD in VARCHAR2
,P_ROUNDING_RL in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SHR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_SHR_ATTRIBUTE1 in VARCHAR2
,P_SHR_ATTRIBUTE2 in VARCHAR2
,P_SHR_ATTRIBUTE3 in VARCHAR2
,P_SHR_ATTRIBUTE4 in VARCHAR2
,P_SHR_ATTRIBUTE5 in VARCHAR2
,P_SHR_ATTRIBUTE6 in VARCHAR2
,P_SHR_ATTRIBUTE7 in VARCHAR2
,P_SHR_ATTRIBUTE8 in VARCHAR2
,P_SHR_ATTRIBUTE9 in VARCHAR2
,P_SHR_ATTRIBUTE10 in VARCHAR2
,P_SHR_ATTRIBUTE11 in VARCHAR2
,P_SHR_ATTRIBUTE12 in VARCHAR2
,P_SHR_ATTRIBUTE13 in VARCHAR2
,P_SHR_ATTRIBUTE14 in VARCHAR2
,P_SHR_ATTRIBUTE15 in VARCHAR2
,P_SHR_ATTRIBUTE16 in VARCHAR2
,P_SHR_ATTRIBUTE17 in VARCHAR2
,P_SHR_ATTRIBUTE18 in VARCHAR2
,P_SHR_ATTRIBUTE19 in VARCHAR2
,P_SHR_ATTRIBUTE20 in VARCHAR2
,P_SHR_ATTRIBUTE21 in VARCHAR2
,P_SHR_ATTRIBUTE22 in VARCHAR2
,P_SHR_ATTRIBUTE23 in VARCHAR2
,P_SHR_ATTRIBUTE24 in VARCHAR2
,P_SHR_ATTRIBUTE25 in VARCHAR2
,P_SHR_ATTRIBUTE26 in VARCHAR2
,P_SHR_ATTRIBUTE27 in VARCHAR2
,P_SHR_ATTRIBUTE28 in VARCHAR2
,P_SHR_ATTRIBUTE29 in VARCHAR2
,P_SHR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_SCHEDD_HRS_RATE_BK2.UPDATE_SCHEDD_HRS_RATE_B', 10);
hr_utility.set_location(' Leaving: BEN_SCHEDD_HRS_RATE_BK2.UPDATE_SCHEDD_HRS_RATE_B', 20);
end UPDATE_SCHEDD_HRS_RATE_B;
end BEN_SCHEDD_HRS_RATE_BK2;

/
