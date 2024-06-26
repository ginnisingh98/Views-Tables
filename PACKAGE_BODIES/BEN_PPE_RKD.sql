--------------------------------------------------------
--  DDL for Package Body BEN_PPE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPE_RKD" as
/* $Header: bepperhi.pkb 120.0 2005/05/28 10:57:37 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PRTT_PREM_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_STD_PREM_UOM_O in VARCHAR2
,P_STD_PREM_VAL_O in NUMBER
,P_ACTL_PREM_ID_O in NUMBER
,P_PRTT_ENRT_RSLT_ID_O in NUMBER
,P_PER_IN_LER_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PPE_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PPE_ATTRIBUTE1_O in VARCHAR2
,P_PPE_ATTRIBUTE2_O in VARCHAR2
,P_PPE_ATTRIBUTE3_O in VARCHAR2
,P_PPE_ATTRIBUTE4_O in VARCHAR2
,P_PPE_ATTRIBUTE5_O in VARCHAR2
,P_PPE_ATTRIBUTE6_O in VARCHAR2
,P_PPE_ATTRIBUTE7_O in VARCHAR2
,P_PPE_ATTRIBUTE8_O in VARCHAR2
,P_PPE_ATTRIBUTE9_O in VARCHAR2
,P_PPE_ATTRIBUTE10_O in VARCHAR2
,P_PPE_ATTRIBUTE11_O in VARCHAR2
,P_PPE_ATTRIBUTE12_O in VARCHAR2
,P_PPE_ATTRIBUTE13_O in VARCHAR2
,P_PPE_ATTRIBUTE14_O in VARCHAR2
,P_PPE_ATTRIBUTE15_O in VARCHAR2
,P_PPE_ATTRIBUTE16_O in VARCHAR2
,P_PPE_ATTRIBUTE17_O in VARCHAR2
,P_PPE_ATTRIBUTE18_O in VARCHAR2
,P_PPE_ATTRIBUTE19_O in VARCHAR2
,P_PPE_ATTRIBUTE20_O in VARCHAR2
,P_PPE_ATTRIBUTE21_O in VARCHAR2
,P_PPE_ATTRIBUTE22_O in VARCHAR2
,P_PPE_ATTRIBUTE23_O in VARCHAR2
,P_PPE_ATTRIBUTE24_O in VARCHAR2
,P_PPE_ATTRIBUTE25_O in VARCHAR2
,P_PPE_ATTRIBUTE26_O in VARCHAR2
,P_PPE_ATTRIBUTE27_O in VARCHAR2
,P_PPE_ATTRIBUTE28_O in VARCHAR2
,P_PPE_ATTRIBUTE29_O in VARCHAR2
,P_PPE_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
)is
begin
hr_utility.set_location('Entering: ben_ppe_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_ppe_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_ppe_RKD;

/
