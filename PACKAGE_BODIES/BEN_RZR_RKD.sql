--------------------------------------------------------
--  DDL for Package Body BEN_RZR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RZR_RKD" as
/* $Header: berzrrhi.pkb 120.0.12010000.1 2008/07/29 13:03:04 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PSTL_ZIP_RNG_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_FROM_VALUE_O in VARCHAR2
,P_TO_VALUE_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_RZR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_RZR_ATTRIBUTE1_O in VARCHAR2
,P_RZR_ATTRIBUTE10_O in VARCHAR2
,P_RZR_ATTRIBUTE11_O in VARCHAR2
,P_RZR_ATTRIBUTE12_O in VARCHAR2
,P_RZR_ATTRIBUTE13_O in VARCHAR2
,P_RZR_ATTRIBUTE14_O in VARCHAR2
,P_RZR_ATTRIBUTE15_O in VARCHAR2
,P_RZR_ATTRIBUTE16_O in VARCHAR2
,P_RZR_ATTRIBUTE17_O in VARCHAR2
,P_RZR_ATTRIBUTE18_O in VARCHAR2
,P_RZR_ATTRIBUTE19_O in VARCHAR2
,P_RZR_ATTRIBUTE2_O in VARCHAR2
,P_RZR_ATTRIBUTE20_O in VARCHAR2
,P_RZR_ATTRIBUTE21_O in VARCHAR2
,P_RZR_ATTRIBUTE22_O in VARCHAR2
,P_RZR_ATTRIBUTE23_O in VARCHAR2
,P_RZR_ATTRIBUTE24_O in VARCHAR2
,P_RZR_ATTRIBUTE25_O in VARCHAR2
,P_RZR_ATTRIBUTE26_O in VARCHAR2
,P_RZR_ATTRIBUTE27_O in VARCHAR2
,P_RZR_ATTRIBUTE28_O in VARCHAR2
,P_RZR_ATTRIBUTE29_O in VARCHAR2
,P_RZR_ATTRIBUTE3_O in VARCHAR2
,P_RZR_ATTRIBUTE30_O in VARCHAR2
,P_RZR_ATTRIBUTE4_O in VARCHAR2
,P_RZR_ATTRIBUTE5_O in VARCHAR2
,P_RZR_ATTRIBUTE6_O in VARCHAR2
,P_RZR_ATTRIBUTE7_O in VARCHAR2
,P_RZR_ATTRIBUTE8_O in VARCHAR2
,P_RZR_ATTRIBUTE9_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_rzr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_rzr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_rzr_RKD;

/