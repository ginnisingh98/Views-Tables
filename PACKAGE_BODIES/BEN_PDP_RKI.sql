--------------------------------------------------------
--  DDL for Package Body BEN_PDP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDP_RKI" as
/* $Header: bepdprhi.pkb 120.10 2006/01/05 23:23:11 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ELIG_CVRD_DPNT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_PRTT_ENRT_RSLT_ID in NUMBER
,P_DPNT_PERSON_ID in NUMBER
,P_CVG_STRT_DT in DATE
,P_CVG_THRU_DT in DATE
,P_CVG_PNDG_FLAG in VARCHAR2
,P_PDP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PDP_ATTRIBUTE1 in VARCHAR2
,P_PDP_ATTRIBUTE2 in VARCHAR2
,P_PDP_ATTRIBUTE3 in VARCHAR2
,P_PDP_ATTRIBUTE4 in VARCHAR2
,P_PDP_ATTRIBUTE5 in VARCHAR2
,P_PDP_ATTRIBUTE6 in VARCHAR2
,P_PDP_ATTRIBUTE7 in VARCHAR2
,P_PDP_ATTRIBUTE8 in VARCHAR2
,P_PDP_ATTRIBUTE9 in VARCHAR2
,P_PDP_ATTRIBUTE10 in VARCHAR2
,P_PDP_ATTRIBUTE11 in VARCHAR2
,P_PDP_ATTRIBUTE12 in VARCHAR2
,P_PDP_ATTRIBUTE13 in VARCHAR2
,P_PDP_ATTRIBUTE14 in VARCHAR2
,P_PDP_ATTRIBUTE15 in VARCHAR2
,P_PDP_ATTRIBUTE16 in VARCHAR2
,P_PDP_ATTRIBUTE17 in VARCHAR2
,P_PDP_ATTRIBUTE18 in VARCHAR2
,P_PDP_ATTRIBUTE19 in VARCHAR2
,P_PDP_ATTRIBUTE20 in VARCHAR2
,P_PDP_ATTRIBUTE21 in VARCHAR2
,P_PDP_ATTRIBUTE22 in VARCHAR2
,P_PDP_ATTRIBUTE23 in VARCHAR2
,P_PDP_ATTRIBUTE24 in VARCHAR2
,P_PDP_ATTRIBUTE25 in VARCHAR2
,P_PDP_ATTRIBUTE26 in VARCHAR2
,P_PDP_ATTRIBUTE27 in VARCHAR2
,P_PDP_ATTRIBUTE28 in VARCHAR2
,P_PDP_ATTRIBUTE29 in VARCHAR2
,P_PDP_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_OVRDN_FLAG in VARCHAR2
,P_PER_IN_LER_ID in NUMBER
,P_OVRDN_THRU_DT in DATE
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_pdp_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_pdp_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_pdp_RKI;

/
