--------------------------------------------------------
--  DDL for Package Body BEN_CPO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPO_RKD" as
/* $Header: becporhi.pkb 115.11 2002/12/13 06:20:48 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:15 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_POPL_ORG_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CSTMR_NUM_O in NUMBER
,P_PLCY_R_GRP_O in VARCHAR2
,P_PGM_ID_O in NUMBER
,P_PL_ID_O in NUMBER
,P_ORGANIZATION_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_CPO_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CPO_ATTRIBUTE1_O in VARCHAR2
,P_CPO_ATTRIBUTE2_O in VARCHAR2
,P_CPO_ATTRIBUTE3_O in VARCHAR2
,P_CPO_ATTRIBUTE4_O in VARCHAR2
,P_CPO_ATTRIBUTE5_O in VARCHAR2
,P_CPO_ATTRIBUTE6_O in VARCHAR2
,P_CPO_ATTRIBUTE7_O in VARCHAR2
,P_CPO_ATTRIBUTE8_O in VARCHAR2
,P_CPO_ATTRIBUTE9_O in VARCHAR2
,P_CPO_ATTRIBUTE10_O in VARCHAR2
,P_CPO_ATTRIBUTE11_O in VARCHAR2
,P_CPO_ATTRIBUTE12_O in VARCHAR2
,P_CPO_ATTRIBUTE13_O in VARCHAR2
,P_CPO_ATTRIBUTE14_O in VARCHAR2
,P_CPO_ATTRIBUTE15_O in VARCHAR2
,P_CPO_ATTRIBUTE16_O in VARCHAR2
,P_CPO_ATTRIBUTE17_O in VARCHAR2
,P_CPO_ATTRIBUTE18_O in VARCHAR2
,P_CPO_ATTRIBUTE19_O in VARCHAR2
,P_CPO_ATTRIBUTE20_O in VARCHAR2
,P_CPO_ATTRIBUTE21_O in VARCHAR2
,P_CPO_ATTRIBUTE22_O in VARCHAR2
,P_CPO_ATTRIBUTE23_O in VARCHAR2
,P_CPO_ATTRIBUTE24_O in VARCHAR2
,P_CPO_ATTRIBUTE25_O in VARCHAR2
,P_CPO_ATTRIBUTE26_O in VARCHAR2
,P_CPO_ATTRIBUTE27_O in VARCHAR2
,P_CPO_ATTRIBUTE28_O in VARCHAR2
,P_CPO_ATTRIBUTE29_O in VARCHAR2
,P_CPO_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_cpo_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_cpo_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_cpo_RKD;

/
