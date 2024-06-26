--------------------------------------------------------
--  DDL for Package Body BEN_TTP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TTP_RKI" as
/* $Header: bettprhi.pkb 120.0.12010000.2 2008/08/05 15:32:38 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_TTL_PRTT_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_NO_MN_PRTT_NUM_APLS_FLAG in VARCHAR2
,P_NO_MX_PRTT_NUM_APLS_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_MN_PRTT_NUM in NUMBER
,P_MX_PRTT_NUM in NUMBER
,P_PRTT_DET_CD in VARCHAR2
,P_PRTT_DET_RL in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_TTP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_TTP_ATTRIBUTE1 in VARCHAR2
,P_TTP_ATTRIBUTE2 in VARCHAR2
,P_TTP_ATTRIBUTE3 in VARCHAR2
,P_TTP_ATTRIBUTE4 in VARCHAR2
,P_TTP_ATTRIBUTE5 in VARCHAR2
,P_TTP_ATTRIBUTE6 in VARCHAR2
,P_TTP_ATTRIBUTE7 in VARCHAR2
,P_TTP_ATTRIBUTE8 in VARCHAR2
,P_TTP_ATTRIBUTE9 in VARCHAR2
,P_TTP_ATTRIBUTE10 in VARCHAR2
,P_TTP_ATTRIBUTE11 in VARCHAR2
,P_TTP_ATTRIBUTE12 in VARCHAR2
,P_TTP_ATTRIBUTE13 in VARCHAR2
,P_TTP_ATTRIBUTE14 in VARCHAR2
,P_TTP_ATTRIBUTE15 in VARCHAR2
,P_TTP_ATTRIBUTE16 in VARCHAR2
,P_TTP_ATTRIBUTE17 in VARCHAR2
,P_TTP_ATTRIBUTE18 in VARCHAR2
,P_TTP_ATTRIBUTE19 in VARCHAR2
,P_TTP_ATTRIBUTE20 in VARCHAR2
,P_TTP_ATTRIBUTE21 in VARCHAR2
,P_TTP_ATTRIBUTE22 in VARCHAR2
,P_TTP_ATTRIBUTE23 in VARCHAR2
,P_TTP_ATTRIBUTE24 in VARCHAR2
,P_TTP_ATTRIBUTE25 in VARCHAR2
,P_TTP_ATTRIBUTE26 in VARCHAR2
,P_TTP_ATTRIBUTE27 in VARCHAR2
,P_TTP_ATTRIBUTE28 in VARCHAR2
,P_TTP_ATTRIBUTE29 in VARCHAR2
,P_TTP_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_ttp_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_ttp_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_ttp_RKI;

/
