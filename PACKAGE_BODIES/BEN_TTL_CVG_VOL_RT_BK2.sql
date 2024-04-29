--------------------------------------------------------
--  DDL for Package Body BEN_TTL_CVG_VOL_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TTL_CVG_VOL_RT_BK2" as
/* $Header: betcvapi.pkb 120.0 2005/05/28 11:54:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:56 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_TTL_CVG_VOL_RT_A
(P_TTL_CVG_VOL_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_NO_MN_CVG_VOL_AMT_APLS_FLAG in VARCHAR2
,P_NO_MX_CVG_VOL_AMT_APLS_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_MN_CVG_VOL_AMT in NUMBER
,P_MX_CVG_VOL_AMT in NUMBER
,P_CVG_VOL_DET_CD in VARCHAR2
,P_CVG_VOL_DET_RL in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_TCV_ATTRIBUTE_CATEGORY in VARCHAR2
,P_TCV_ATTRIBUTE1 in VARCHAR2
,P_TCV_ATTRIBUTE2 in VARCHAR2
,P_TCV_ATTRIBUTE3 in VARCHAR2
,P_TCV_ATTRIBUTE4 in VARCHAR2
,P_TCV_ATTRIBUTE5 in VARCHAR2
,P_TCV_ATTRIBUTE6 in VARCHAR2
,P_TCV_ATTRIBUTE7 in VARCHAR2
,P_TCV_ATTRIBUTE8 in VARCHAR2
,P_TCV_ATTRIBUTE9 in VARCHAR2
,P_TCV_ATTRIBUTE10 in VARCHAR2
,P_TCV_ATTRIBUTE11 in VARCHAR2
,P_TCV_ATTRIBUTE12 in VARCHAR2
,P_TCV_ATTRIBUTE13 in VARCHAR2
,P_TCV_ATTRIBUTE14 in VARCHAR2
,P_TCV_ATTRIBUTE15 in VARCHAR2
,P_TCV_ATTRIBUTE16 in VARCHAR2
,P_TCV_ATTRIBUTE17 in VARCHAR2
,P_TCV_ATTRIBUTE18 in VARCHAR2
,P_TCV_ATTRIBUTE19 in VARCHAR2
,P_TCV_ATTRIBUTE20 in VARCHAR2
,P_TCV_ATTRIBUTE21 in VARCHAR2
,P_TCV_ATTRIBUTE22 in VARCHAR2
,P_TCV_ATTRIBUTE23 in VARCHAR2
,P_TCV_ATTRIBUTE24 in VARCHAR2
,P_TCV_ATTRIBUTE25 in VARCHAR2
,P_TCV_ATTRIBUTE26 in VARCHAR2
,P_TCV_ATTRIBUTE27 in VARCHAR2
,P_TCV_ATTRIBUTE28 in VARCHAR2
,P_TCV_ATTRIBUTE29 in VARCHAR2
,P_TCV_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_TTL_CVG_VOL_RT_BK2.UPDATE_TTL_CVG_VOL_RT_A', 10);
hr_utility.set_location(' Leaving: BEN_TTL_CVG_VOL_RT_BK2.UPDATE_TTL_CVG_VOL_RT_A', 20);
end UPDATE_TTL_CVG_VOL_RT_A;
procedure UPDATE_TTL_CVG_VOL_RT_B
(P_TTL_CVG_VOL_RT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_NO_MN_CVG_VOL_AMT_APLS_FLAG in VARCHAR2
,P_NO_MX_CVG_VOL_AMT_APLS_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_MN_CVG_VOL_AMT in NUMBER
,P_MX_CVG_VOL_AMT in NUMBER
,P_CVG_VOL_DET_CD in VARCHAR2
,P_CVG_VOL_DET_RL in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_TCV_ATTRIBUTE_CATEGORY in VARCHAR2
,P_TCV_ATTRIBUTE1 in VARCHAR2
,P_TCV_ATTRIBUTE2 in VARCHAR2
,P_TCV_ATTRIBUTE3 in VARCHAR2
,P_TCV_ATTRIBUTE4 in VARCHAR2
,P_TCV_ATTRIBUTE5 in VARCHAR2
,P_TCV_ATTRIBUTE6 in VARCHAR2
,P_TCV_ATTRIBUTE7 in VARCHAR2
,P_TCV_ATTRIBUTE8 in VARCHAR2
,P_TCV_ATTRIBUTE9 in VARCHAR2
,P_TCV_ATTRIBUTE10 in VARCHAR2
,P_TCV_ATTRIBUTE11 in VARCHAR2
,P_TCV_ATTRIBUTE12 in VARCHAR2
,P_TCV_ATTRIBUTE13 in VARCHAR2
,P_TCV_ATTRIBUTE14 in VARCHAR2
,P_TCV_ATTRIBUTE15 in VARCHAR2
,P_TCV_ATTRIBUTE16 in VARCHAR2
,P_TCV_ATTRIBUTE17 in VARCHAR2
,P_TCV_ATTRIBUTE18 in VARCHAR2
,P_TCV_ATTRIBUTE19 in VARCHAR2
,P_TCV_ATTRIBUTE20 in VARCHAR2
,P_TCV_ATTRIBUTE21 in VARCHAR2
,P_TCV_ATTRIBUTE22 in VARCHAR2
,P_TCV_ATTRIBUTE23 in VARCHAR2
,P_TCV_ATTRIBUTE24 in VARCHAR2
,P_TCV_ATTRIBUTE25 in VARCHAR2
,P_TCV_ATTRIBUTE26 in VARCHAR2
,P_TCV_ATTRIBUTE27 in VARCHAR2
,P_TCV_ATTRIBUTE28 in VARCHAR2
,P_TCV_ATTRIBUTE29 in VARCHAR2
,P_TCV_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_TTL_CVG_VOL_RT_BK2.UPDATE_TTL_CVG_VOL_RT_B', 10);
hr_utility.set_location(' Leaving: BEN_TTL_CVG_VOL_RT_BK2.UPDATE_TTL_CVG_VOL_RT_B', 20);
end UPDATE_TTL_CVG_VOL_RT_B;
end BEN_TTL_CVG_VOL_RT_BK2;

/