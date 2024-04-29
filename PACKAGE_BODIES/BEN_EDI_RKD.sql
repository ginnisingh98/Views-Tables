--------------------------------------------------------
--  DDL for Package Body BEN_EDI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EDI_RKD" as
/* $Header: beedirhi.pkb 120.1 2006/02/28 01:58:38 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:47 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ELIG_DPNT_CVRD_PLIP_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_EXCLD_FLAG_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_ENRL_DET_DT_CD_O in VARCHAR2
,P_PLIP_ID_O in NUMBER
,P_ELIGY_PRFL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_EDI_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_EDI_ATTRIBUTE1_O in VARCHAR2
,P_EDI_ATTRIBUTE2_O in VARCHAR2
,P_EDI_ATTRIBUTE3_O in VARCHAR2
,P_EDI_ATTRIBUTE4_O in VARCHAR2
,P_EDI_ATTRIBUTE5_O in VARCHAR2
,P_EDI_ATTRIBUTE6_O in VARCHAR2
,P_EDI_ATTRIBUTE7_O in VARCHAR2
,P_EDI_ATTRIBUTE8_O in VARCHAR2
,P_EDI_ATTRIBUTE9_O in VARCHAR2
,P_EDI_ATTRIBUTE10_O in VARCHAR2
,P_EDI_ATTRIBUTE11_O in VARCHAR2
,P_EDI_ATTRIBUTE12_O in VARCHAR2
,P_EDI_ATTRIBUTE13_O in VARCHAR2
,P_EDI_ATTRIBUTE14_O in VARCHAR2
,P_EDI_ATTRIBUTE15_O in VARCHAR2
,P_EDI_ATTRIBUTE16_O in VARCHAR2
,P_EDI_ATTRIBUTE17_O in VARCHAR2
,P_EDI_ATTRIBUTE18_O in VARCHAR2
,P_EDI_ATTRIBUTE19_O in VARCHAR2
,P_EDI_ATTRIBUTE20_O in VARCHAR2
,P_EDI_ATTRIBUTE21_O in VARCHAR2
,P_EDI_ATTRIBUTE22_O in VARCHAR2
,P_EDI_ATTRIBUTE23_O in VARCHAR2
,P_EDI_ATTRIBUTE24_O in VARCHAR2
,P_EDI_ATTRIBUTE25_O in VARCHAR2
,P_EDI_ATTRIBUTE26_O in VARCHAR2
,P_EDI_ATTRIBUTE27_O in VARCHAR2
,P_EDI_ATTRIBUTE28_O in VARCHAR2
,P_EDI_ATTRIBUTE29_O in VARCHAR2
,P_EDI_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_edi_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_edi_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_edi_RKD;

/
