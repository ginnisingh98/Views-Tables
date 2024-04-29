--------------------------------------------------------
--  DDL for Package Body BEN_PET_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PET_RKD" as
/* $Header: bepetrhi.pkb 120.1 2006/03/07 23:43:30 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:21 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_POPL_ENRT_TYP_CYCL_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ENRT_TYP_CYCL_CD_O in VARCHAR2
,P_PL_ID_O in NUMBER
,P_PGM_ID_O in NUMBER
,P_PET_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PET_ATTRIBUTE1_O in VARCHAR2
,P_PET_ATTRIBUTE2_O in VARCHAR2
,P_PET_ATTRIBUTE3_O in VARCHAR2
,P_PET_ATTRIBUTE4_O in VARCHAR2
,P_PET_ATTRIBUTE5_O in VARCHAR2
,P_PET_ATTRIBUTE6_O in VARCHAR2
,P_PET_ATTRIBUTE7_O in VARCHAR2
,P_PET_ATTRIBUTE8_O in VARCHAR2
,P_PET_ATTRIBUTE9_O in VARCHAR2
,P_PET_ATTRIBUTE10_O in VARCHAR2
,P_PET_ATTRIBUTE11_O in VARCHAR2
,P_PET_ATTRIBUTE12_O in VARCHAR2
,P_PET_ATTRIBUTE13_O in VARCHAR2
,P_PET_ATTRIBUTE14_O in VARCHAR2
,P_PET_ATTRIBUTE15_O in VARCHAR2
,P_PET_ATTRIBUTE16_O in VARCHAR2
,P_PET_ATTRIBUTE17_O in VARCHAR2
,P_PET_ATTRIBUTE18_O in VARCHAR2
,P_PET_ATTRIBUTE19_O in VARCHAR2
,P_PET_ATTRIBUTE20_O in VARCHAR2
,P_PET_ATTRIBUTE21_O in VARCHAR2
,P_PET_ATTRIBUTE22_O in VARCHAR2
,P_PET_ATTRIBUTE23_O in VARCHAR2
,P_PET_ATTRIBUTE24_O in VARCHAR2
,P_PET_ATTRIBUTE25_O in VARCHAR2
,P_PET_ATTRIBUTE26_O in VARCHAR2
,P_PET_ATTRIBUTE27_O in VARCHAR2
,P_PET_ATTRIBUTE28_O in VARCHAR2
,P_PET_ATTRIBUTE29_O in VARCHAR2
,P_PET_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_pet_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_pet_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_pet_RKD;

/