--------------------------------------------------------
--  DDL for Package Body BEN_EMP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EMP_RKI" as
/* $Header: beemprhi.pkb 120.0 2005/05/28 02:25:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:06 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ELIG_MRTL_STS_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_MARITAL_STATUS in VARCHAR2
,P_ELIGY_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EMP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EMP_ATTRIBUTE1 in VARCHAR2
,P_EMP_ATTRIBUTE2 in VARCHAR2
,P_EMP_ATTRIBUTE3 in VARCHAR2
,P_EMP_ATTRIBUTE4 in VARCHAR2
,P_EMP_ATTRIBUTE5 in VARCHAR2
,P_EMP_ATTRIBUTE6 in VARCHAR2
,P_EMP_ATTRIBUTE7 in VARCHAR2
,P_EMP_ATTRIBUTE8 in VARCHAR2
,P_EMP_ATTRIBUTE9 in VARCHAR2
,P_EMP_ATTRIBUTE10 in VARCHAR2
,P_EMP_ATTRIBUTE11 in VARCHAR2
,P_EMP_ATTRIBUTE12 in VARCHAR2
,P_EMP_ATTRIBUTE13 in VARCHAR2
,P_EMP_ATTRIBUTE14 in VARCHAR2
,P_EMP_ATTRIBUTE15 in VARCHAR2
,P_EMP_ATTRIBUTE16 in VARCHAR2
,P_EMP_ATTRIBUTE17 in VARCHAR2
,P_EMP_ATTRIBUTE18 in VARCHAR2
,P_EMP_ATTRIBUTE19 in VARCHAR2
,P_EMP_ATTRIBUTE20 in VARCHAR2
,P_EMP_ATTRIBUTE21 in VARCHAR2
,P_EMP_ATTRIBUTE22 in VARCHAR2
,P_EMP_ATTRIBUTE23 in VARCHAR2
,P_EMP_ATTRIBUTE24 in VARCHAR2
,P_EMP_ATTRIBUTE25 in VARCHAR2
,P_EMP_ATTRIBUTE26 in VARCHAR2
,P_EMP_ATTRIBUTE27 in VARCHAR2
,P_EMP_ATTRIBUTE28 in VARCHAR2
,P_EMP_ATTRIBUTE29 in VARCHAR2
,P_EMP_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_emp_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_emp_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_emp_RKI;

/
