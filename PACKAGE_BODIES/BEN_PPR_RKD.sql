--------------------------------------------------------
--  DDL for Package Body BEN_PPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPR_RKD" as
/* $Header: bepprrhi.pkb 120.0.12010000.2 2008/08/05 15:17:03 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PRMRY_CARE_PRVDR_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_PRMRY_CARE_PRVDR_TYP_CD_O in VARCHAR2
,P_NAME_O in VARCHAR2
,P_EXT_IDENT_O in VARCHAR2
,P_PRTT_ENRT_RSLT_ID_O in NUMBER
,P_ELIG_CVRD_DPNT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PPR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PPR_ATTRIBUTE1_O in VARCHAR2
,P_PPR_ATTRIBUTE2_O in VARCHAR2
,P_PPR_ATTRIBUTE3_O in VARCHAR2
,P_PPR_ATTRIBUTE4_O in VARCHAR2
,P_PPR_ATTRIBUTE5_O in VARCHAR2
,P_PPR_ATTRIBUTE6_O in VARCHAR2
,P_PPR_ATTRIBUTE7_O in VARCHAR2
,P_PPR_ATTRIBUTE8_O in VARCHAR2
,P_PPR_ATTRIBUTE9_O in VARCHAR2
,P_PPR_ATTRIBUTE10_O in VARCHAR2
,P_PPR_ATTRIBUTE11_O in VARCHAR2
,P_PPR_ATTRIBUTE12_O in VARCHAR2
,P_PPR_ATTRIBUTE13_O in VARCHAR2
,P_PPR_ATTRIBUTE14_O in VARCHAR2
,P_PPR_ATTRIBUTE15_O in VARCHAR2
,P_PPR_ATTRIBUTE16_O in VARCHAR2
,P_PPR_ATTRIBUTE17_O in VARCHAR2
,P_PPR_ATTRIBUTE18_O in VARCHAR2
,P_PPR_ATTRIBUTE19_O in VARCHAR2
,P_PPR_ATTRIBUTE20_O in VARCHAR2
,P_PPR_ATTRIBUTE21_O in VARCHAR2
,P_PPR_ATTRIBUTE22_O in VARCHAR2
,P_PPR_ATTRIBUTE23_O in VARCHAR2
,P_PPR_ATTRIBUTE24_O in VARCHAR2
,P_PPR_ATTRIBUTE25_O in VARCHAR2
,P_PPR_ATTRIBUTE26_O in VARCHAR2
,P_PPR_ATTRIBUTE27_O in VARCHAR2
,P_PPR_ATTRIBUTE28_O in VARCHAR2
,P_PPR_ATTRIBUTE29_O in VARCHAR2
,P_PPR_ATTRIBUTE30_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_PPR_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: BEN_PPR_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end BEN_PPR_RKD;

/
