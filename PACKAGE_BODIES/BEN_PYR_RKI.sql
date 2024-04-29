--------------------------------------------------------
--  DDL for Package Body BEN_PYR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PYR_RKI" as
/* $Header: bepyrrhi.pkb 120.2.12010000.2 2008/08/05 15:24:31 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PYRL_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_VRBL_RT_PRFL_ID in NUMBER
,P_PAYROLL_ID in NUMBER
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_PR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PR_ATTRIBUTE1 in VARCHAR2
,P_PR_ATTRIBUTE2 in VARCHAR2
,P_PR_ATTRIBUTE3 in VARCHAR2
,P_PR_ATTRIBUTE4 in VARCHAR2
,P_PR_ATTRIBUTE5 in VARCHAR2
,P_PR_ATTRIBUTE6 in VARCHAR2
,P_PR_ATTRIBUTE7 in VARCHAR2
,P_PR_ATTRIBUTE8 in VARCHAR2
,P_PR_ATTRIBUTE9 in VARCHAR2
,P_PR_ATTRIBUTE10 in VARCHAR2
,P_PR_ATTRIBUTE11 in VARCHAR2
,P_PR_ATTRIBUTE12 in VARCHAR2
,P_PR_ATTRIBUTE13 in VARCHAR2
,P_PR_ATTRIBUTE14 in VARCHAR2
,P_PR_ATTRIBUTE15 in VARCHAR2
,P_PR_ATTRIBUTE16 in VARCHAR2
,P_PR_ATTRIBUTE17 in VARCHAR2
,P_PR_ATTRIBUTE18 in VARCHAR2
,P_PR_ATTRIBUTE19 in VARCHAR2
,P_PR_ATTRIBUTE20 in VARCHAR2
,P_PR_ATTRIBUTE21 in VARCHAR2
,P_PR_ATTRIBUTE22 in VARCHAR2
,P_PR_ATTRIBUTE23 in VARCHAR2
,P_PR_ATTRIBUTE24 in VARCHAR2
,P_PR_ATTRIBUTE25 in VARCHAR2
,P_PR_ATTRIBUTE26 in VARCHAR2
,P_PR_ATTRIBUTE27 in VARCHAR2
,P_PR_ATTRIBUTE28 in VARCHAR2
,P_PR_ATTRIBUTE29 in VARCHAR2
,P_PR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_pyr_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_pyr_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_pyr_RKI;

/