--------------------------------------------------------
--  DDL for Package Body BEN_PCT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCT_RKI" as
/* $Header: bepctrhi.pkb 120.0 2005/05/28 10:18:14 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:11 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PL_GD_R_SVC_CTFN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_PL_GD_OR_SVC_ID in NUMBER
,P_PFD_FLAG in VARCHAR2
,P_LACK_CTFN_DENY_RMBMT_FLAG in VARCHAR2
,P_RMBMT_CTFN_TYP_CD in VARCHAR2
,P_LACK_CTFN_DENY_RMBMT_RL in NUMBER
,P_PCT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PCT_ATTRIBUTE1 in VARCHAR2
,P_PCT_ATTRIBUTE2 in VARCHAR2
,P_PCT_ATTRIBUTE3 in VARCHAR2
,P_PCT_ATTRIBUTE4 in VARCHAR2
,P_PCT_ATTRIBUTE5 in VARCHAR2
,P_PCT_ATTRIBUTE6 in VARCHAR2
,P_PCT_ATTRIBUTE7 in VARCHAR2
,P_PCT_ATTRIBUTE8 in VARCHAR2
,P_PCT_ATTRIBUTE9 in VARCHAR2
,P_PCT_ATTRIBUTE10 in VARCHAR2
,P_PCT_ATTRIBUTE11 in VARCHAR2
,P_PCT_ATTRIBUTE12 in VARCHAR2
,P_PCT_ATTRIBUTE13 in VARCHAR2
,P_PCT_ATTRIBUTE14 in VARCHAR2
,P_PCT_ATTRIBUTE15 in VARCHAR2
,P_PCT_ATTRIBUTE16 in VARCHAR2
,P_PCT_ATTRIBUTE17 in VARCHAR2
,P_PCT_ATTRIBUTE18 in VARCHAR2
,P_PCT_ATTRIBUTE19 in VARCHAR2
,P_PCT_ATTRIBUTE20 in VARCHAR2
,P_PCT_ATTRIBUTE21 in VARCHAR2
,P_PCT_ATTRIBUTE22 in VARCHAR2
,P_PCT_ATTRIBUTE23 in VARCHAR2
,P_PCT_ATTRIBUTE24 in VARCHAR2
,P_PCT_ATTRIBUTE25 in VARCHAR2
,P_PCT_ATTRIBUTE26 in VARCHAR2
,P_PCT_ATTRIBUTE27 in VARCHAR2
,P_PCT_ATTRIBUTE28 in VARCHAR2
,P_PCT_ATTRIBUTE29 in VARCHAR2
,P_PCT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_CTFN_RQD_WHEN_RL in NUMBER
,P_RQD_FLAG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_pct_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_pct_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_pct_RKI;

/
