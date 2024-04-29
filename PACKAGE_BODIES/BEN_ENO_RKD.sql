--------------------------------------------------------
--  DDL for Package Body BEN_ENO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENO_RKD" as
/* $Header: beenorhi.pkb 115.4 2002/12/16 07:02:25 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:08 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ELIG_NO_OTHR_CVG_PRTE_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_COORD_BEN_NO_CVG_FLAG_O in VARCHAR2
,P_ELIGY_PRFL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ENO_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ENO_ATTRIBUTE1_O in VARCHAR2
,P_ENO_ATTRIBUTE2_O in VARCHAR2
,P_ENO_ATTRIBUTE3_O in VARCHAR2
,P_ENO_ATTRIBUTE4_O in VARCHAR2
,P_ENO_ATTRIBUTE5_O in VARCHAR2
,P_ENO_ATTRIBUTE6_O in VARCHAR2
,P_ENO_ATTRIBUTE7_O in VARCHAR2
,P_ENO_ATTRIBUTE8_O in VARCHAR2
,P_ENO_ATTRIBUTE9_O in VARCHAR2
,P_ENO_ATTRIBUTE10_O in VARCHAR2
,P_ENO_ATTRIBUTE11_O in VARCHAR2
,P_ENO_ATTRIBUTE12_O in VARCHAR2
,P_ENO_ATTRIBUTE13_O in VARCHAR2
,P_ENO_ATTRIBUTE14_O in VARCHAR2
,P_ENO_ATTRIBUTE15_O in VARCHAR2
,P_ENO_ATTRIBUTE16_O in VARCHAR2
,P_ENO_ATTRIBUTE17_O in VARCHAR2
,P_ENO_ATTRIBUTE18_O in VARCHAR2
,P_ENO_ATTRIBUTE19_O in VARCHAR2
,P_ENO_ATTRIBUTE20_O in VARCHAR2
,P_ENO_ATTRIBUTE21_O in VARCHAR2
,P_ENO_ATTRIBUTE22_O in VARCHAR2
,P_ENO_ATTRIBUTE23_O in VARCHAR2
,P_ENO_ATTRIBUTE24_O in VARCHAR2
,P_ENO_ATTRIBUTE25_O in VARCHAR2
,P_ENO_ATTRIBUTE26_O in VARCHAR2
,P_ENO_ATTRIBUTE27_O in VARCHAR2
,P_ENO_ATTRIBUTE28_O in VARCHAR2
,P_ENO_ATTRIBUTE29_O in VARCHAR2
,P_ENO_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_eno_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_eno_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_eno_RKD;

/