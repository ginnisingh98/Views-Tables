--------------------------------------------------------
--  DDL for Package Body BEN_ENT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENT_RKI" as
/* $Header: beentrhi.pkb 120.2 2006/03/31 00:04:59 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:10 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ENRLD_ANTHR_PTIP_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ENRL_DET_DT_CD in VARCHAR2
,P_ONLY_PLS_SUBJ_COBRA_FLAG in VARCHAR2
,P_PTIP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ENT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ENT_ATTRIBUTE1 in VARCHAR2
,P_ENT_ATTRIBUTE2 in VARCHAR2
,P_ENT_ATTRIBUTE3 in VARCHAR2
,P_ENT_ATTRIBUTE4 in VARCHAR2
,P_ENT_ATTRIBUTE5 in VARCHAR2
,P_ENT_ATTRIBUTE6 in VARCHAR2
,P_ENT_ATTRIBUTE7 in VARCHAR2
,P_ENT_ATTRIBUTE8 in VARCHAR2
,P_ENT_ATTRIBUTE9 in VARCHAR2
,P_ENT_ATTRIBUTE10 in VARCHAR2
,P_ENT_ATTRIBUTE11 in VARCHAR2
,P_ENT_ATTRIBUTE12 in VARCHAR2
,P_ENT_ATTRIBUTE13 in VARCHAR2
,P_ENT_ATTRIBUTE14 in VARCHAR2
,P_ENT_ATTRIBUTE15 in VARCHAR2
,P_ENT_ATTRIBUTE16 in VARCHAR2
,P_ENT_ATTRIBUTE17 in VARCHAR2
,P_ENT_ATTRIBUTE18 in VARCHAR2
,P_ENT_ATTRIBUTE19 in VARCHAR2
,P_ENT_ATTRIBUTE20 in VARCHAR2
,P_ENT_ATTRIBUTE21 in VARCHAR2
,P_ENT_ATTRIBUTE22 in VARCHAR2
,P_ENT_ATTRIBUTE23 in VARCHAR2
,P_ENT_ATTRIBUTE24 in VARCHAR2
,P_ENT_ATTRIBUTE25 in VARCHAR2
,P_ENT_ATTRIBUTE26 in VARCHAR2
,P_ENT_ATTRIBUTE27 in VARCHAR2
,P_ENT_ATTRIBUTE28 in VARCHAR2
,P_ENT_ATTRIBUTE29 in VARCHAR2
,P_ENT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_ENT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: BEN_ENT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end BEN_ENT_RKI;

/
