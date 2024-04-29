--------------------------------------------------------
--  DDL for Package Body BEN_PEA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEA_RKI" as
/* $Header: bepearhi.pkb 120.2 2005/08/09 06:07:35 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PRTT_ENRT_ACTN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_CMPLTD_DT in DATE
,P_DUE_DT in DATE
,P_RQD_FLAG in VARCHAR2
,P_PRTT_ENRT_RSLT_ID in NUMBER
,P_PER_IN_LER_ID in NUMBER
,P_ACTN_TYP_ID in NUMBER
,P_ELIG_CVRD_DPNT_ID in NUMBER
,P_PL_BNF_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PEA_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PEA_ATTRIBUTE1 in VARCHAR2
,P_PEA_ATTRIBUTE2 in VARCHAR2
,P_PEA_ATTRIBUTE3 in VARCHAR2
,P_PEA_ATTRIBUTE4 in VARCHAR2
,P_PEA_ATTRIBUTE5 in VARCHAR2
,P_PEA_ATTRIBUTE6 in VARCHAR2
,P_PEA_ATTRIBUTE7 in VARCHAR2
,P_PEA_ATTRIBUTE8 in VARCHAR2
,P_PEA_ATTRIBUTE9 in VARCHAR2
,P_PEA_ATTRIBUTE10 in VARCHAR2
,P_PEA_ATTRIBUTE11 in VARCHAR2
,P_PEA_ATTRIBUTE12 in VARCHAR2
,P_PEA_ATTRIBUTE13 in VARCHAR2
,P_PEA_ATTRIBUTE14 in VARCHAR2
,P_PEA_ATTRIBUTE15 in VARCHAR2
,P_PEA_ATTRIBUTE16 in VARCHAR2
,P_PEA_ATTRIBUTE17 in VARCHAR2
,P_PEA_ATTRIBUTE18 in VARCHAR2
,P_PEA_ATTRIBUTE19 in VARCHAR2
,P_PEA_ATTRIBUTE20 in VARCHAR2
,P_PEA_ATTRIBUTE21 in VARCHAR2
,P_PEA_ATTRIBUTE22 in VARCHAR2
,P_PEA_ATTRIBUTE23 in VARCHAR2
,P_PEA_ATTRIBUTE24 in VARCHAR2
,P_PEA_ATTRIBUTE25 in VARCHAR2
,P_PEA_ATTRIBUTE26 in VARCHAR2
,P_PEA_ATTRIBUTE27 in VARCHAR2
,P_PEA_ATTRIBUTE28 in VARCHAR2
,P_PEA_ATTRIBUTE29 in VARCHAR2
,P_PEA_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_pea_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_pea_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_pea_RKI;

/