--------------------------------------------------------
--  DDL for Package Body BEN_PBM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PBM_RKI" as
/* $Header: bepbmrhi.pkb 115.6 2002/12/11 11:17:16 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:06 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PL_R_OIPL_PREM_BY_MO_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_MNL_ADJ_FLAG in VARCHAR2
,P_MO_NUM in NUMBER
,P_YR_NUM in NUMBER
,P_VAL in NUMBER
,P_UOM in VARCHAR2
,P_PRTTS_NUM in NUMBER
,P_ACTL_PREM_ID in NUMBER
,P_COST_ALLOCATION_KEYFLEX_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PBM_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PBM_ATTRIBUTE1 in VARCHAR2
,P_PBM_ATTRIBUTE2 in VARCHAR2
,P_PBM_ATTRIBUTE3 in VARCHAR2
,P_PBM_ATTRIBUTE4 in VARCHAR2
,P_PBM_ATTRIBUTE5 in VARCHAR2
,P_PBM_ATTRIBUTE6 in VARCHAR2
,P_PBM_ATTRIBUTE7 in VARCHAR2
,P_PBM_ATTRIBUTE8 in VARCHAR2
,P_PBM_ATTRIBUTE9 in VARCHAR2
,P_PBM_ATTRIBUTE10 in VARCHAR2
,P_PBM_ATTRIBUTE11 in VARCHAR2
,P_PBM_ATTRIBUTE12 in VARCHAR2
,P_PBM_ATTRIBUTE13 in VARCHAR2
,P_PBM_ATTRIBUTE14 in VARCHAR2
,P_PBM_ATTRIBUTE15 in VARCHAR2
,P_PBM_ATTRIBUTE16 in VARCHAR2
,P_PBM_ATTRIBUTE17 in VARCHAR2
,P_PBM_ATTRIBUTE18 in VARCHAR2
,P_PBM_ATTRIBUTE19 in VARCHAR2
,P_PBM_ATTRIBUTE20 in VARCHAR2
,P_PBM_ATTRIBUTE21 in VARCHAR2
,P_PBM_ATTRIBUTE22 in VARCHAR2
,P_PBM_ATTRIBUTE23 in VARCHAR2
,P_PBM_ATTRIBUTE24 in VARCHAR2
,P_PBM_ATTRIBUTE25 in VARCHAR2
,P_PBM_ATTRIBUTE26 in VARCHAR2
,P_PBM_ATTRIBUTE27 in VARCHAR2
,P_PBM_ATTRIBUTE28 in VARCHAR2
,P_PBM_ATTRIBUTE29 in VARCHAR2
,P_PBM_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_pbm_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_pbm_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_pbm_RKI;

/