--------------------------------------------------------
--  DDL for Package Body BEN_LNR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LNR_RKI" as
/* $Header: belnrrhi.pkb 115.7 2002/12/13 06:18:52 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:46 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_LER_CHG_PL_NIP_RL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_FORMULA_ID in NUMBER
,P_ORDR_TO_APLY_NUM in NUMBER
,P_LER_CHG_PL_NIP_ENRT_ID in NUMBER
,P_LNR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_LNR_ATTRIBUTE1 in VARCHAR2
,P_LNR_ATTRIBUTE2 in VARCHAR2
,P_LNR_ATTRIBUTE3 in VARCHAR2
,P_LNR_ATTRIBUTE4 in VARCHAR2
,P_LNR_ATTRIBUTE5 in VARCHAR2
,P_LNR_ATTRIBUTE6 in VARCHAR2
,P_LNR_ATTRIBUTE7 in VARCHAR2
,P_LNR_ATTRIBUTE8 in VARCHAR2
,P_LNR_ATTRIBUTE9 in VARCHAR2
,P_LNR_ATTRIBUTE10 in VARCHAR2
,P_LNR_ATTRIBUTE11 in VARCHAR2
,P_LNR_ATTRIBUTE12 in VARCHAR2
,P_LNR_ATTRIBUTE13 in VARCHAR2
,P_LNR_ATTRIBUTE14 in VARCHAR2
,P_LNR_ATTRIBUTE15 in VARCHAR2
,P_LNR_ATTRIBUTE16 in VARCHAR2
,P_LNR_ATTRIBUTE17 in VARCHAR2
,P_LNR_ATTRIBUTE18 in VARCHAR2
,P_LNR_ATTRIBUTE19 in VARCHAR2
,P_LNR_ATTRIBUTE20 in VARCHAR2
,P_LNR_ATTRIBUTE21 in VARCHAR2
,P_LNR_ATTRIBUTE22 in VARCHAR2
,P_LNR_ATTRIBUTE23 in VARCHAR2
,P_LNR_ATTRIBUTE24 in VARCHAR2
,P_LNR_ATTRIBUTE25 in VARCHAR2
,P_LNR_ATTRIBUTE26 in VARCHAR2
,P_LNR_ATTRIBUTE27 in VARCHAR2
,P_LNR_ATTRIBUTE28 in VARCHAR2
,P_LNR_ATTRIBUTE29 in VARCHAR2
,P_LNR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_lnr_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_lnr_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_lnr_RKI;

/