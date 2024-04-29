--------------------------------------------------------
--  DDL for Package Body BEN_ABP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABP_RKD" as
/* $Header: beabprhi.pkb 120.0.12010000.3 2008/08/25 13:56:55 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_APLCN_TO_BNFT_POOL_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ACTY_BASE_RT_ID_O in NUMBER
,P_BNFT_PRVDR_POOL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ABP_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ABP_ATTRIBUTE1_O in VARCHAR2
,P_ABP_ATTRIBUTE2_O in VARCHAR2
,P_ABP_ATTRIBUTE3_O in VARCHAR2
,P_ABP_ATTRIBUTE4_O in VARCHAR2
,P_ABP_ATTRIBUTE5_O in VARCHAR2
,P_ABP_ATTRIBUTE6_O in VARCHAR2
,P_ABP_ATTRIBUTE7_O in VARCHAR2
,P_ABP_ATTRIBUTE8_O in VARCHAR2
,P_ABP_ATTRIBUTE9_O in VARCHAR2
,P_ABP_ATTRIBUTE10_O in VARCHAR2
,P_ABP_ATTRIBUTE11_O in VARCHAR2
,P_ABP_ATTRIBUTE12_O in VARCHAR2
,P_ABP_ATTRIBUTE13_O in VARCHAR2
,P_ABP_ATTRIBUTE14_O in VARCHAR2
,P_ABP_ATTRIBUTE15_O in VARCHAR2
,P_ABP_ATTRIBUTE16_O in VARCHAR2
,P_ABP_ATTRIBUTE17_O in VARCHAR2
,P_ABP_ATTRIBUTE18_O in VARCHAR2
,P_ABP_ATTRIBUTE19_O in VARCHAR2
,P_ABP_ATTRIBUTE20_O in VARCHAR2
,P_ABP_ATTRIBUTE21_O in VARCHAR2
,P_ABP_ATTRIBUTE22_O in VARCHAR2
,P_ABP_ATTRIBUTE23_O in VARCHAR2
,P_ABP_ATTRIBUTE24_O in VARCHAR2
,P_ABP_ATTRIBUTE25_O in VARCHAR2
,P_ABP_ATTRIBUTE26_O in VARCHAR2
,P_ABP_ATTRIBUTE27_O in VARCHAR2
,P_ABP_ATTRIBUTE28_O in VARCHAR2
,P_ABP_ATTRIBUTE29_O in VARCHAR2
,P_ABP_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_abp_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_abp_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_abp_RKD;

/
