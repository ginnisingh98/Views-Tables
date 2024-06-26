--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_PREM_BY_MO_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_PREM_BY_MO_BK1" as
/* $Header: beprmapi.pkb 115.3 2002/12/16 07:24:14 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:36 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_PRTT_PREM_BY_MO_A
(P_PRTT_PREM_BY_MO_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_MNL_ADJ_FLAG in VARCHAR2
,P_MO_NUM in NUMBER
,P_YR_NUM in NUMBER
,P_ANTCPD_PRTT_CNTR_UOM in VARCHAR2
,P_ANTCPD_PRTT_CNTR_VAL in NUMBER
,P_VAL in NUMBER
,P_CR_VAL in NUMBER
,P_CR_MNL_ADJ_FLAG in VARCHAR2
,P_ALCTD_VAL_FLAG in VARCHAR2
,P_UOM in VARCHAR2
,P_PRTT_PREM_ID in NUMBER
,P_COST_ALLOCATION_KEYFLEX_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PRM_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PRM_ATTRIBUTE1 in VARCHAR2
,P_PRM_ATTRIBUTE2 in VARCHAR2
,P_PRM_ATTRIBUTE3 in VARCHAR2
,P_PRM_ATTRIBUTE4 in VARCHAR2
,P_PRM_ATTRIBUTE5 in VARCHAR2
,P_PRM_ATTRIBUTE6 in VARCHAR2
,P_PRM_ATTRIBUTE7 in VARCHAR2
,P_PRM_ATTRIBUTE8 in VARCHAR2
,P_PRM_ATTRIBUTE9 in VARCHAR2
,P_PRM_ATTRIBUTE10 in VARCHAR2
,P_PRM_ATTRIBUTE11 in VARCHAR2
,P_PRM_ATTRIBUTE12 in VARCHAR2
,P_PRM_ATTRIBUTE13 in VARCHAR2
,P_PRM_ATTRIBUTE14 in VARCHAR2
,P_PRM_ATTRIBUTE15 in VARCHAR2
,P_PRM_ATTRIBUTE16 in VARCHAR2
,P_PRM_ATTRIBUTE17 in VARCHAR2
,P_PRM_ATTRIBUTE18 in VARCHAR2
,P_PRM_ATTRIBUTE19 in VARCHAR2
,P_PRM_ATTRIBUTE20 in VARCHAR2
,P_PRM_ATTRIBUTE21 in VARCHAR2
,P_PRM_ATTRIBUTE22 in VARCHAR2
,P_PRM_ATTRIBUTE23 in VARCHAR2
,P_PRM_ATTRIBUTE24 in VARCHAR2
,P_PRM_ATTRIBUTE25 in VARCHAR2
,P_PRM_ATTRIBUTE26 in VARCHAR2
,P_PRM_ATTRIBUTE27 in VARCHAR2
,P_PRM_ATTRIBUTE28 in VARCHAR2
,P_PRM_ATTRIBUTE29 in VARCHAR2
,P_PRM_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_PRTT_PREM_BY_MO_BK1.CREATE_PRTT_PREM_BY_MO_A', 10);
hr_utility.set_location(' Leaving: BEN_PRTT_PREM_BY_MO_BK1.CREATE_PRTT_PREM_BY_MO_A', 20);
end CREATE_PRTT_PREM_BY_MO_A;
procedure CREATE_PRTT_PREM_BY_MO_B
(P_MNL_ADJ_FLAG in VARCHAR2
,P_MO_NUM in NUMBER
,P_YR_NUM in NUMBER
,P_ANTCPD_PRTT_CNTR_UOM in VARCHAR2
,P_ANTCPD_PRTT_CNTR_VAL in NUMBER
,P_VAL in NUMBER
,P_CR_VAL in NUMBER
,P_CR_MNL_ADJ_FLAG in VARCHAR2
,P_ALCTD_VAL_FLAG in VARCHAR2
,P_UOM in VARCHAR2
,P_PRTT_PREM_ID in NUMBER
,P_COST_ALLOCATION_KEYFLEX_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PRM_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PRM_ATTRIBUTE1 in VARCHAR2
,P_PRM_ATTRIBUTE2 in VARCHAR2
,P_PRM_ATTRIBUTE3 in VARCHAR2
,P_PRM_ATTRIBUTE4 in VARCHAR2
,P_PRM_ATTRIBUTE5 in VARCHAR2
,P_PRM_ATTRIBUTE6 in VARCHAR2
,P_PRM_ATTRIBUTE7 in VARCHAR2
,P_PRM_ATTRIBUTE8 in VARCHAR2
,P_PRM_ATTRIBUTE9 in VARCHAR2
,P_PRM_ATTRIBUTE10 in VARCHAR2
,P_PRM_ATTRIBUTE11 in VARCHAR2
,P_PRM_ATTRIBUTE12 in VARCHAR2
,P_PRM_ATTRIBUTE13 in VARCHAR2
,P_PRM_ATTRIBUTE14 in VARCHAR2
,P_PRM_ATTRIBUTE15 in VARCHAR2
,P_PRM_ATTRIBUTE16 in VARCHAR2
,P_PRM_ATTRIBUTE17 in VARCHAR2
,P_PRM_ATTRIBUTE18 in VARCHAR2
,P_PRM_ATTRIBUTE19 in VARCHAR2
,P_PRM_ATTRIBUTE20 in VARCHAR2
,P_PRM_ATTRIBUTE21 in VARCHAR2
,P_PRM_ATTRIBUTE22 in VARCHAR2
,P_PRM_ATTRIBUTE23 in VARCHAR2
,P_PRM_ATTRIBUTE24 in VARCHAR2
,P_PRM_ATTRIBUTE25 in VARCHAR2
,P_PRM_ATTRIBUTE26 in VARCHAR2
,P_PRM_ATTRIBUTE27 in VARCHAR2
,P_PRM_ATTRIBUTE28 in VARCHAR2
,P_PRM_ATTRIBUTE29 in VARCHAR2
,P_PRM_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_PRTT_PREM_BY_MO_BK1.CREATE_PRTT_PREM_BY_MO_B', 10);
hr_utility.set_location(' Leaving: BEN_PRTT_PREM_BY_MO_BK1.CREATE_PRTT_PREM_BY_MO_B', 20);
end CREATE_PRTT_PREM_BY_MO_B;
end BEN_PRTT_PREM_BY_MO_BK1;

/
