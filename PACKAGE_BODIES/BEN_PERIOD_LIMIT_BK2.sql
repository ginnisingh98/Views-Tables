--------------------------------------------------------
--  DDL for Package Body BEN_PERIOD_LIMIT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERIOD_LIMIT_BK2" as
/* $Header: bepdlapi.pkb 120.0 2005/05/28 10:26:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:15 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PERIOD_LIMIT_A
(P_PTD_LMT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_NAME in VARCHAR2
,P_MX_COMP_TO_CNSDR in NUMBER
,P_MX_VAL in NUMBER
,P_MX_PCT_VAL in NUMBER
,P_PTD_LMT_CALC_RL in NUMBER
,P_LMT_DET_CD in VARCHAR2
,P_COMP_LVL_FCTR_ID in NUMBER
,P_BALANCE_TYPE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PDL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PDL_ATTRIBUTE1 in VARCHAR2
,P_PDL_ATTRIBUTE2 in VARCHAR2
,P_PDL_ATTRIBUTE3 in VARCHAR2
,P_PDL_ATTRIBUTE4 in VARCHAR2
,P_PDL_ATTRIBUTE5 in VARCHAR2
,P_PDL_ATTRIBUTE6 in VARCHAR2
,P_PDL_ATTRIBUTE7 in VARCHAR2
,P_PDL_ATTRIBUTE8 in VARCHAR2
,P_PDL_ATTRIBUTE9 in VARCHAR2
,P_PDL_ATTRIBUTE10 in VARCHAR2
,P_PDL_ATTRIBUTE11 in VARCHAR2
,P_PDL_ATTRIBUTE12 in VARCHAR2
,P_PDL_ATTRIBUTE13 in VARCHAR2
,P_PDL_ATTRIBUTE14 in VARCHAR2
,P_PDL_ATTRIBUTE15 in VARCHAR2
,P_PDL_ATTRIBUTE16 in VARCHAR2
,P_PDL_ATTRIBUTE17 in VARCHAR2
,P_PDL_ATTRIBUTE18 in VARCHAR2
,P_PDL_ATTRIBUTE19 in VARCHAR2
,P_PDL_ATTRIBUTE20 in VARCHAR2
,P_PDL_ATTRIBUTE21 in VARCHAR2
,P_PDL_ATTRIBUTE22 in VARCHAR2
,P_PDL_ATTRIBUTE23 in VARCHAR2
,P_PDL_ATTRIBUTE24 in VARCHAR2
,P_PDL_ATTRIBUTE25 in VARCHAR2
,P_PDL_ATTRIBUTE26 in VARCHAR2
,P_PDL_ATTRIBUTE27 in VARCHAR2
,P_PDL_ATTRIBUTE28 in VARCHAR2
,P_PDL_ATTRIBUTE29 in VARCHAR2
,P_PDL_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PERIOD_LIMIT_BK2.UPDATE_PERIOD_LIMIT_A', 10);
hr_utility.set_location(' Leaving: BEN_PERIOD_LIMIT_BK2.UPDATE_PERIOD_LIMIT_A', 20);
end UPDATE_PERIOD_LIMIT_A;
procedure UPDATE_PERIOD_LIMIT_B
(P_PTD_LMT_ID in NUMBER
,P_NAME in VARCHAR2
,P_MX_COMP_TO_CNSDR in NUMBER
,P_MX_VAL in NUMBER
,P_MX_PCT_VAL in NUMBER
,P_PTD_LMT_CALC_RL in NUMBER
,P_LMT_DET_CD in VARCHAR2
,P_COMP_LVL_FCTR_ID in NUMBER
,P_BALANCE_TYPE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PDL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PDL_ATTRIBUTE1 in VARCHAR2
,P_PDL_ATTRIBUTE2 in VARCHAR2
,P_PDL_ATTRIBUTE3 in VARCHAR2
,P_PDL_ATTRIBUTE4 in VARCHAR2
,P_PDL_ATTRIBUTE5 in VARCHAR2
,P_PDL_ATTRIBUTE6 in VARCHAR2
,P_PDL_ATTRIBUTE7 in VARCHAR2
,P_PDL_ATTRIBUTE8 in VARCHAR2
,P_PDL_ATTRIBUTE9 in VARCHAR2
,P_PDL_ATTRIBUTE10 in VARCHAR2
,P_PDL_ATTRIBUTE11 in VARCHAR2
,P_PDL_ATTRIBUTE12 in VARCHAR2
,P_PDL_ATTRIBUTE13 in VARCHAR2
,P_PDL_ATTRIBUTE14 in VARCHAR2
,P_PDL_ATTRIBUTE15 in VARCHAR2
,P_PDL_ATTRIBUTE16 in VARCHAR2
,P_PDL_ATTRIBUTE17 in VARCHAR2
,P_PDL_ATTRIBUTE18 in VARCHAR2
,P_PDL_ATTRIBUTE19 in VARCHAR2
,P_PDL_ATTRIBUTE20 in VARCHAR2
,P_PDL_ATTRIBUTE21 in VARCHAR2
,P_PDL_ATTRIBUTE22 in VARCHAR2
,P_PDL_ATTRIBUTE23 in VARCHAR2
,P_PDL_ATTRIBUTE24 in VARCHAR2
,P_PDL_ATTRIBUTE25 in VARCHAR2
,P_PDL_ATTRIBUTE26 in VARCHAR2
,P_PDL_ATTRIBUTE27 in VARCHAR2
,P_PDL_ATTRIBUTE28 in VARCHAR2
,P_PDL_ATTRIBUTE29 in VARCHAR2
,P_PDL_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PERIOD_LIMIT_BK2.UPDATE_PERIOD_LIMIT_B', 10);
hr_utility.set_location(' Leaving: BEN_PERIOD_LIMIT_BK2.UPDATE_PERIOD_LIMIT_B', 20);
end UPDATE_PERIOD_LIMIT_B;
end BEN_PERIOD_LIMIT_BK2;

/