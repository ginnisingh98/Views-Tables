--------------------------------------------------------
--  DDL for Package Body BEN_CSR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CSR_RKU" as
/* $Header: becsrrhi.pkb 115.4 2002/12/16 17:34:51 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:23 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_CSS_RLTD_PER_PER_IN_LER_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ORDR_TO_PRCS_NUM in NUMBER
,P_LER_ID in NUMBER
,P_RSLTG_LER_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CSR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CSR_ATTRIBUTE1 in VARCHAR2
,P_CSR_ATTRIBUTE2 in VARCHAR2
,P_CSR_ATTRIBUTE3 in VARCHAR2
,P_CSR_ATTRIBUTE4 in VARCHAR2
,P_CSR_ATTRIBUTE5 in VARCHAR2
,P_CSR_ATTRIBUTE6 in VARCHAR2
,P_CSR_ATTRIBUTE7 in VARCHAR2
,P_CSR_ATTRIBUTE8 in VARCHAR2
,P_CSR_ATTRIBUTE9 in VARCHAR2
,P_CSR_ATTRIBUTE10 in VARCHAR2
,P_CSR_ATTRIBUTE11 in VARCHAR2
,P_CSR_ATTRIBUTE12 in VARCHAR2
,P_CSR_ATTRIBUTE13 in VARCHAR2
,P_CSR_ATTRIBUTE14 in VARCHAR2
,P_CSR_ATTRIBUTE15 in VARCHAR2
,P_CSR_ATTRIBUTE16 in VARCHAR2
,P_CSR_ATTRIBUTE17 in VARCHAR2
,P_CSR_ATTRIBUTE18 in VARCHAR2
,P_CSR_ATTRIBUTE19 in VARCHAR2
,P_CSR_ATTRIBUTE20 in VARCHAR2
,P_CSR_ATTRIBUTE21 in VARCHAR2
,P_CSR_ATTRIBUTE22 in VARCHAR2
,P_CSR_ATTRIBUTE23 in VARCHAR2
,P_CSR_ATTRIBUTE24 in VARCHAR2
,P_CSR_ATTRIBUTE25 in VARCHAR2
,P_CSR_ATTRIBUTE26 in VARCHAR2
,P_CSR_ATTRIBUTE27 in VARCHAR2
,P_CSR_ATTRIBUTE28 in VARCHAR2
,P_CSR_ATTRIBUTE29 in VARCHAR2
,P_CSR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ORDR_TO_PRCS_NUM_O in NUMBER
,P_LER_ID_O in NUMBER
,P_RSLTG_LER_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CSR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CSR_ATTRIBUTE1_O in VARCHAR2
,P_CSR_ATTRIBUTE2_O in VARCHAR2
,P_CSR_ATTRIBUTE3_O in VARCHAR2
,P_CSR_ATTRIBUTE4_O in VARCHAR2
,P_CSR_ATTRIBUTE5_O in VARCHAR2
,P_CSR_ATTRIBUTE6_O in VARCHAR2
,P_CSR_ATTRIBUTE7_O in VARCHAR2
,P_CSR_ATTRIBUTE8_O in VARCHAR2
,P_CSR_ATTRIBUTE9_O in VARCHAR2
,P_CSR_ATTRIBUTE10_O in VARCHAR2
,P_CSR_ATTRIBUTE11_O in VARCHAR2
,P_CSR_ATTRIBUTE12_O in VARCHAR2
,P_CSR_ATTRIBUTE13_O in VARCHAR2
,P_CSR_ATTRIBUTE14_O in VARCHAR2
,P_CSR_ATTRIBUTE15_O in VARCHAR2
,P_CSR_ATTRIBUTE16_O in VARCHAR2
,P_CSR_ATTRIBUTE17_O in VARCHAR2
,P_CSR_ATTRIBUTE18_O in VARCHAR2
,P_CSR_ATTRIBUTE19_O in VARCHAR2
,P_CSR_ATTRIBUTE20_O in VARCHAR2
,P_CSR_ATTRIBUTE21_O in VARCHAR2
,P_CSR_ATTRIBUTE22_O in VARCHAR2
,P_CSR_ATTRIBUTE23_O in VARCHAR2
,P_CSR_ATTRIBUTE24_O in VARCHAR2
,P_CSR_ATTRIBUTE25_O in VARCHAR2
,P_CSR_ATTRIBUTE26_O in VARCHAR2
,P_CSR_ATTRIBUTE27_O in VARCHAR2
,P_CSR_ATTRIBUTE28_O in VARCHAR2
,P_CSR_ATTRIBUTE29_O in VARCHAR2
,P_CSR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_csr_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_csr_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_csr_RKU;

/
