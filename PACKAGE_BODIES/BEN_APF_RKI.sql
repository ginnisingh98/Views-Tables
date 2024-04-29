--------------------------------------------------------
--  DDL for Package Body BEN_APF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_APF_RKI" as
/* $Header: beapfrhi.pkb 120.0.12010000.3 2008/08/05 14:02:20 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ACTY_RT_PYMT_SCHED_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_PYMT_SCHED_RL in NUMBER
,P_ACTY_BASE_RT_ID in NUMBER
,P_PYMT_SCHED_CD in VARCHAR2
,P_APF_ATTRIBUTE_CATEGORY in VARCHAR2
,P_APF_ATTRIBUTE1 in VARCHAR2
,P_APF_ATTRIBUTE2 in VARCHAR2
,P_APF_ATTRIBUTE3 in VARCHAR2
,P_APF_ATTRIBUTE4 in VARCHAR2
,P_APF_ATTRIBUTE5 in VARCHAR2
,P_APF_ATTRIBUTE6 in VARCHAR2
,P_APF_ATTRIBUTE7 in VARCHAR2
,P_APF_ATTRIBUTE8 in VARCHAR2
,P_APF_ATTRIBUTE9 in VARCHAR2
,P_APF_ATTRIBUTE10 in VARCHAR2
,P_APF_ATTRIBUTE11 in VARCHAR2
,P_APF_ATTRIBUTE12 in VARCHAR2
,P_APF_ATTRIBUTE13 in VARCHAR2
,P_APF_ATTRIBUTE14 in VARCHAR2
,P_APF_ATTRIBUTE15 in VARCHAR2
,P_APF_ATTRIBUTE16 in VARCHAR2
,P_APF_ATTRIBUTE17 in VARCHAR2
,P_APF_ATTRIBUTE18 in VARCHAR2
,P_APF_ATTRIBUTE19 in VARCHAR2
,P_APF_ATTRIBUTE20 in VARCHAR2
,P_APF_ATTRIBUTE21 in VARCHAR2
,P_APF_ATTRIBUTE22 in VARCHAR2
,P_APF_ATTRIBUTE23 in VARCHAR2
,P_APF_ATTRIBUTE24 in VARCHAR2
,P_APF_ATTRIBUTE25 in VARCHAR2
,P_APF_ATTRIBUTE26 in VARCHAR2
,P_APF_ATTRIBUTE27 in VARCHAR2
,P_APF_ATTRIBUTE28 in VARCHAR2
,P_APF_ATTRIBUTE29 in VARCHAR2
,P_APF_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_apf_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_apf_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_apf_RKI;

/