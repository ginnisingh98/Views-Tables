--------------------------------------------------------
--  DDL for Package Body BEN_LNC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LNC_RKD" as
/* $Header: belncrhi.pkb 115.7 2002/12/13 06:19:21 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:46 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_LER_ENRT_CTFN_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_RQD_FLAG_O in VARCHAR2
,P_ENRT_CTFN_TYP_CD_O in VARCHAR2
,P_CTFN_RQD_WHEN_RL_O in NUMBER
,P_LER_RQRS_ENRT_CTFN_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LNC_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_LNC_ATTRIBUTE1_O in VARCHAR2
,P_LNC_ATTRIBUTE2_O in VARCHAR2
,P_LNC_ATTRIBUTE3_O in VARCHAR2
,P_LNC_ATTRIBUTE4_O in VARCHAR2
,P_LNC_ATTRIBUTE5_O in VARCHAR2
,P_LNC_ATTRIBUTE6_O in VARCHAR2
,P_LNC_ATTRIBUTE7_O in VARCHAR2
,P_LNC_ATTRIBUTE8_O in VARCHAR2
,P_LNC_ATTRIBUTE9_O in VARCHAR2
,P_LNC_ATTRIBUTE10_O in VARCHAR2
,P_LNC_ATTRIBUTE11_O in VARCHAR2
,P_LNC_ATTRIBUTE12_O in VARCHAR2
,P_LNC_ATTRIBUTE13_O in VARCHAR2
,P_LNC_ATTRIBUTE14_O in VARCHAR2
,P_LNC_ATTRIBUTE15_O in VARCHAR2
,P_LNC_ATTRIBUTE16_O in VARCHAR2
,P_LNC_ATTRIBUTE17_O in VARCHAR2
,P_LNC_ATTRIBUTE18_O in VARCHAR2
,P_LNC_ATTRIBUTE19_O in VARCHAR2
,P_LNC_ATTRIBUTE20_O in VARCHAR2
,P_LNC_ATTRIBUTE21_O in VARCHAR2
,P_LNC_ATTRIBUTE22_O in VARCHAR2
,P_LNC_ATTRIBUTE23_O in VARCHAR2
,P_LNC_ATTRIBUTE24_O in VARCHAR2
,P_LNC_ATTRIBUTE25_O in VARCHAR2
,P_LNC_ATTRIBUTE26_O in VARCHAR2
,P_LNC_ATTRIBUTE27_O in VARCHAR2
,P_LNC_ATTRIBUTE28_O in VARCHAR2
,P_LNC_ATTRIBUTE29_O in VARCHAR2
,P_LNC_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_lnc_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_lnc_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_lnc_RKD;

/
