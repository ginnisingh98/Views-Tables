--------------------------------------------------------
--  DDL for Package Body BEN_LNR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LNR_RKD" as
/* $Header: belnrrhi.pkb 115.7 2002/12/13 06:18:52 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:46 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_LER_CHG_PL_NIP_RL_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_FORMULA_ID_O in NUMBER
,P_ORDR_TO_APLY_NUM_O in NUMBER
,P_LER_CHG_PL_NIP_ENRT_ID_O in NUMBER
,P_LNR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_LNR_ATTRIBUTE1_O in VARCHAR2
,P_LNR_ATTRIBUTE2_O in VARCHAR2
,P_LNR_ATTRIBUTE3_O in VARCHAR2
,P_LNR_ATTRIBUTE4_O in VARCHAR2
,P_LNR_ATTRIBUTE5_O in VARCHAR2
,P_LNR_ATTRIBUTE6_O in VARCHAR2
,P_LNR_ATTRIBUTE7_O in VARCHAR2
,P_LNR_ATTRIBUTE8_O in VARCHAR2
,P_LNR_ATTRIBUTE9_O in VARCHAR2
,P_LNR_ATTRIBUTE10_O in VARCHAR2
,P_LNR_ATTRIBUTE11_O in VARCHAR2
,P_LNR_ATTRIBUTE12_O in VARCHAR2
,P_LNR_ATTRIBUTE13_O in VARCHAR2
,P_LNR_ATTRIBUTE14_O in VARCHAR2
,P_LNR_ATTRIBUTE15_O in VARCHAR2
,P_LNR_ATTRIBUTE16_O in VARCHAR2
,P_LNR_ATTRIBUTE17_O in VARCHAR2
,P_LNR_ATTRIBUTE18_O in VARCHAR2
,P_LNR_ATTRIBUTE19_O in VARCHAR2
,P_LNR_ATTRIBUTE20_O in VARCHAR2
,P_LNR_ATTRIBUTE21_O in VARCHAR2
,P_LNR_ATTRIBUTE22_O in VARCHAR2
,P_LNR_ATTRIBUTE23_O in VARCHAR2
,P_LNR_ATTRIBUTE24_O in VARCHAR2
,P_LNR_ATTRIBUTE25_O in VARCHAR2
,P_LNR_ATTRIBUTE26_O in VARCHAR2
,P_LNR_ATTRIBUTE27_O in VARCHAR2
,P_LNR_ATTRIBUTE28_O in VARCHAR2
,P_LNR_ATTRIBUTE29_O in VARCHAR2
,P_LNR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_lnr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_lnr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_lnr_RKD;

/