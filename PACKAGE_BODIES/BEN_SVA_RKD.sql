--------------------------------------------------------
--  DDL for Package Body BEN_SVA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SVA_RKD" as
/* $Header: besvarhi.pkb 120.0.12010000.2 2008/08/05 15:27:56 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_SVC_AREA_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_ORG_UNIT_PRDCT_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_SVA_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_SVA_ATTRIBUTE1_O in VARCHAR2
,P_SVA_ATTRIBUTE2_O in VARCHAR2
,P_SVA_ATTRIBUTE3_O in VARCHAR2
,P_SVA_ATTRIBUTE4_O in VARCHAR2
,P_SVA_ATTRIBUTE5_O in VARCHAR2
,P_SVA_ATTRIBUTE6_O in VARCHAR2
,P_SVA_ATTRIBUTE7_O in VARCHAR2
,P_SVA_ATTRIBUTE8_O in VARCHAR2
,P_SVA_ATTRIBUTE9_O in VARCHAR2
,P_SVA_ATTRIBUTE10_O in VARCHAR2
,P_SVA_ATTRIBUTE11_O in VARCHAR2
,P_SVA_ATTRIBUTE12_O in VARCHAR2
,P_SVA_ATTRIBUTE13_O in VARCHAR2
,P_SVA_ATTRIBUTE14_O in VARCHAR2
,P_SVA_ATTRIBUTE15_O in VARCHAR2
,P_SVA_ATTRIBUTE16_O in VARCHAR2
,P_SVA_ATTRIBUTE17_O in VARCHAR2
,P_SVA_ATTRIBUTE18_O in VARCHAR2
,P_SVA_ATTRIBUTE19_O in VARCHAR2
,P_SVA_ATTRIBUTE20_O in VARCHAR2
,P_SVA_ATTRIBUTE21_O in VARCHAR2
,P_SVA_ATTRIBUTE22_O in VARCHAR2
,P_SVA_ATTRIBUTE23_O in VARCHAR2
,P_SVA_ATTRIBUTE24_O in VARCHAR2
,P_SVA_ATTRIBUTE25_O in VARCHAR2
,P_SVA_ATTRIBUTE26_O in VARCHAR2
,P_SVA_ATTRIBUTE27_O in VARCHAR2
,P_SVA_ATTRIBUTE28_O in VARCHAR2
,P_SVA_ATTRIBUTE29_O in VARCHAR2
,P_SVA_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_sva_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_sva_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_sva_RKD;

/
