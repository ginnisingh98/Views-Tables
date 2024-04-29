--------------------------------------------------------
--  DDL for Package Body BEN_VRBL_MATCHING_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VRBL_MATCHING_RATE_BK2" as
/* $Header: bevmrapi.pkb 120.0 2005/05/28 12:05:20 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:59 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_VRBL_MATCHING_RATE_A
(P_VRBL_MTCHG_RT_ID in NUMBER
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_NO_MX_PCT_OF_PY_NUM_FLAG in VARCHAR2
,P_TO_PCT_VAL in NUMBER
,P_NO_MX_AMT_OF_PY_NUM_FLAG in VARCHAR2
,P_MX_PCT_OF_PY_NUM in NUMBER
,P_NO_MX_MTCH_AMT_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_PCT_VAL in NUMBER
,P_MX_MTCH_AMT in NUMBER
,P_MX_AMT_OF_PY_NUM in NUMBER
,P_MN_MTCH_AMT in NUMBER
,P_MTCHG_RT_CALC_RL in NUMBER
,P_CNTNU_MTCH_AFTR_MAX_RL_FLAG in VARCHAR2
,P_FROM_PCT_VAL in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_VMR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VMR_ATTRIBUTE1 in VARCHAR2
,P_VMR_ATTRIBUTE2 in VARCHAR2
,P_VMR_ATTRIBUTE3 in VARCHAR2
,P_VMR_ATTRIBUTE4 in VARCHAR2
,P_VMR_ATTRIBUTE5 in VARCHAR2
,P_VMR_ATTRIBUTE6 in VARCHAR2
,P_VMR_ATTRIBUTE7 in VARCHAR2
,P_VMR_ATTRIBUTE8 in VARCHAR2
,P_VMR_ATTRIBUTE9 in VARCHAR2
,P_VMR_ATTRIBUTE10 in VARCHAR2
,P_VMR_ATTRIBUTE11 in VARCHAR2
,P_VMR_ATTRIBUTE12 in VARCHAR2
,P_VMR_ATTRIBUTE13 in VARCHAR2
,P_VMR_ATTRIBUTE14 in VARCHAR2
,P_VMR_ATTRIBUTE15 in VARCHAR2
,P_VMR_ATTRIBUTE16 in VARCHAR2
,P_VMR_ATTRIBUTE17 in VARCHAR2
,P_VMR_ATTRIBUTE18 in VARCHAR2
,P_VMR_ATTRIBUTE19 in VARCHAR2
,P_VMR_ATTRIBUTE20 in VARCHAR2
,P_VMR_ATTRIBUTE21 in VARCHAR2
,P_VMR_ATTRIBUTE22 in VARCHAR2
,P_VMR_ATTRIBUTE23 in VARCHAR2
,P_VMR_ATTRIBUTE24 in VARCHAR2
,P_VMR_ATTRIBUTE25 in VARCHAR2
,P_VMR_ATTRIBUTE26 in VARCHAR2
,P_VMR_ATTRIBUTE27 in VARCHAR2
,P_VMR_ATTRIBUTE28 in VARCHAR2
,P_VMR_ATTRIBUTE29 in VARCHAR2
,P_VMR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_VRBL_MATCHING_RATE_BK2.UPDATE_VRBL_MATCHING_RATE_A', 10);
hr_utility.set_location(' Leaving: BEN_VRBL_MATCHING_RATE_BK2.UPDATE_VRBL_MATCHING_RATE_A', 20);
end UPDATE_VRBL_MATCHING_RATE_A;
procedure UPDATE_VRBL_MATCHING_RATE_B
(P_VRBL_MTCHG_RT_ID in NUMBER
,P_NO_MX_PCT_OF_PY_NUM_FLAG in VARCHAR2
,P_TO_PCT_VAL in NUMBER
,P_NO_MX_AMT_OF_PY_NUM_FLAG in VARCHAR2
,P_MX_PCT_OF_PY_NUM in NUMBER
,P_NO_MX_MTCH_AMT_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_PCT_VAL in NUMBER
,P_MX_MTCH_AMT in NUMBER
,P_MX_AMT_OF_PY_NUM in NUMBER
,P_MN_MTCH_AMT in NUMBER
,P_MTCHG_RT_CALC_RL in NUMBER
,P_CNTNU_MTCH_AFTR_MAX_RL_FLAG in VARCHAR2
,P_FROM_PCT_VAL in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_VMR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VMR_ATTRIBUTE1 in VARCHAR2
,P_VMR_ATTRIBUTE2 in VARCHAR2
,P_VMR_ATTRIBUTE3 in VARCHAR2
,P_VMR_ATTRIBUTE4 in VARCHAR2
,P_VMR_ATTRIBUTE5 in VARCHAR2
,P_VMR_ATTRIBUTE6 in VARCHAR2
,P_VMR_ATTRIBUTE7 in VARCHAR2
,P_VMR_ATTRIBUTE8 in VARCHAR2
,P_VMR_ATTRIBUTE9 in VARCHAR2
,P_VMR_ATTRIBUTE10 in VARCHAR2
,P_VMR_ATTRIBUTE11 in VARCHAR2
,P_VMR_ATTRIBUTE12 in VARCHAR2
,P_VMR_ATTRIBUTE13 in VARCHAR2
,P_VMR_ATTRIBUTE14 in VARCHAR2
,P_VMR_ATTRIBUTE15 in VARCHAR2
,P_VMR_ATTRIBUTE16 in VARCHAR2
,P_VMR_ATTRIBUTE17 in VARCHAR2
,P_VMR_ATTRIBUTE18 in VARCHAR2
,P_VMR_ATTRIBUTE19 in VARCHAR2
,P_VMR_ATTRIBUTE20 in VARCHAR2
,P_VMR_ATTRIBUTE21 in VARCHAR2
,P_VMR_ATTRIBUTE22 in VARCHAR2
,P_VMR_ATTRIBUTE23 in VARCHAR2
,P_VMR_ATTRIBUTE24 in VARCHAR2
,P_VMR_ATTRIBUTE25 in VARCHAR2
,P_VMR_ATTRIBUTE26 in VARCHAR2
,P_VMR_ATTRIBUTE27 in VARCHAR2
,P_VMR_ATTRIBUTE28 in VARCHAR2
,P_VMR_ATTRIBUTE29 in VARCHAR2
,P_VMR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_VRBL_MATCHING_RATE_BK2.UPDATE_VRBL_MATCHING_RATE_B', 10);
hr_utility.set_location(' Leaving: BEN_VRBL_MATCHING_RATE_BK2.UPDATE_VRBL_MATCHING_RATE_B', 20);
end UPDATE_VRBL_MATCHING_RATE_B;
end BEN_VRBL_MATCHING_RATE_BK2;

/
