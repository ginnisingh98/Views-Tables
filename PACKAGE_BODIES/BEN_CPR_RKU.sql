--------------------------------------------------------
--  DDL for Package Body BEN_CPR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPR_RKU" as
/* $Header: becprrhi.pkb 115.12 2002/12/13 06:21:26 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_POPL_ORG_ROLE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_NAME in VARCHAR2
,P_ORG_ROLE_TYP_CD in VARCHAR2
,P_POPL_ORG_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CPR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CPR_ATTRIBUTE1 in VARCHAR2
,P_CPR_ATTRIBUTE2 in VARCHAR2
,P_CPR_ATTRIBUTE3 in VARCHAR2
,P_CPR_ATTRIBUTE4 in VARCHAR2
,P_CPR_ATTRIBUTE5 in VARCHAR2
,P_CPR_ATTRIBUTE6 in VARCHAR2
,P_CPR_ATTRIBUTE7 in VARCHAR2
,P_CPR_ATTRIBUTE8 in VARCHAR2
,P_CPR_ATTRIBUTE9 in VARCHAR2
,P_CPR_ATTRIBUTE10 in VARCHAR2
,P_CPR_ATTRIBUTE11 in VARCHAR2
,P_CPR_ATTRIBUTE12 in VARCHAR2
,P_CPR_ATTRIBUTE13 in VARCHAR2
,P_CPR_ATTRIBUTE14 in VARCHAR2
,P_CPR_ATTRIBUTE15 in VARCHAR2
,P_CPR_ATTRIBUTE16 in VARCHAR2
,P_CPR_ATTRIBUTE17 in VARCHAR2
,P_CPR_ATTRIBUTE18 in VARCHAR2
,P_CPR_ATTRIBUTE19 in VARCHAR2
,P_CPR_ATTRIBUTE20 in VARCHAR2
,P_CPR_ATTRIBUTE21 in VARCHAR2
,P_CPR_ATTRIBUTE22 in VARCHAR2
,P_CPR_ATTRIBUTE23 in VARCHAR2
,P_CPR_ATTRIBUTE24 in VARCHAR2
,P_CPR_ATTRIBUTE25 in VARCHAR2
,P_CPR_ATTRIBUTE26 in VARCHAR2
,P_CPR_ATTRIBUTE27 in VARCHAR2
,P_CPR_ATTRIBUTE28 in VARCHAR2
,P_CPR_ATTRIBUTE29 in VARCHAR2
,P_CPR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_ORG_ROLE_TYP_CD_O in VARCHAR2
,P_POPL_ORG_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CPR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CPR_ATTRIBUTE1_O in VARCHAR2
,P_CPR_ATTRIBUTE2_O in VARCHAR2
,P_CPR_ATTRIBUTE3_O in VARCHAR2
,P_CPR_ATTRIBUTE4_O in VARCHAR2
,P_CPR_ATTRIBUTE5_O in VARCHAR2
,P_CPR_ATTRIBUTE6_O in VARCHAR2
,P_CPR_ATTRIBUTE7_O in VARCHAR2
,P_CPR_ATTRIBUTE8_O in VARCHAR2
,P_CPR_ATTRIBUTE9_O in VARCHAR2
,P_CPR_ATTRIBUTE10_O in VARCHAR2
,P_CPR_ATTRIBUTE11_O in VARCHAR2
,P_CPR_ATTRIBUTE12_O in VARCHAR2
,P_CPR_ATTRIBUTE13_O in VARCHAR2
,P_CPR_ATTRIBUTE14_O in VARCHAR2
,P_CPR_ATTRIBUTE15_O in VARCHAR2
,P_CPR_ATTRIBUTE16_O in VARCHAR2
,P_CPR_ATTRIBUTE17_O in VARCHAR2
,P_CPR_ATTRIBUTE18_O in VARCHAR2
,P_CPR_ATTRIBUTE19_O in VARCHAR2
,P_CPR_ATTRIBUTE20_O in VARCHAR2
,P_CPR_ATTRIBUTE21_O in VARCHAR2
,P_CPR_ATTRIBUTE22_O in VARCHAR2
,P_CPR_ATTRIBUTE23_O in VARCHAR2
,P_CPR_ATTRIBUTE24_O in VARCHAR2
,P_CPR_ATTRIBUTE25_O in VARCHAR2
,P_CPR_ATTRIBUTE26_O in VARCHAR2
,P_CPR_ATTRIBUTE27_O in VARCHAR2
,P_CPR_ATTRIBUTE28_O in VARCHAR2
,P_CPR_ATTRIBUTE29_O in VARCHAR2
,P_CPR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_cpr_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_cpr_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_cpr_RKU;

/
