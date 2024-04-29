--------------------------------------------------------
--  DDL for Package Body BEN_EDD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EDD_RKI" as
/* $Header: beeddrhi.pkb 120.0 2005/05/28 01:58:02 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:47 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ELIG_DSBLTY_DGR_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_DEGREE in NUMBER
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_EDD_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EDD_ATTRIBUTE1 in VARCHAR2
,P_EDD_ATTRIBUTE2 in VARCHAR2
,P_EDD_ATTRIBUTE3 in VARCHAR2
,P_EDD_ATTRIBUTE4 in VARCHAR2
,P_EDD_ATTRIBUTE5 in VARCHAR2
,P_EDD_ATTRIBUTE6 in VARCHAR2
,P_EDD_ATTRIBUTE7 in VARCHAR2
,P_EDD_ATTRIBUTE8 in VARCHAR2
,P_EDD_ATTRIBUTE9 in VARCHAR2
,P_EDD_ATTRIBUTE10 in VARCHAR2
,P_EDD_ATTRIBUTE11 in VARCHAR2
,P_EDD_ATTRIBUTE12 in VARCHAR2
,P_EDD_ATTRIBUTE13 in VARCHAR2
,P_EDD_ATTRIBUTE14 in VARCHAR2
,P_EDD_ATTRIBUTE15 in VARCHAR2
,P_EDD_ATTRIBUTE16 in VARCHAR2
,P_EDD_ATTRIBUTE17 in VARCHAR2
,P_EDD_ATTRIBUTE18 in VARCHAR2
,P_EDD_ATTRIBUTE19 in VARCHAR2
,P_EDD_ATTRIBUTE20 in VARCHAR2
,P_EDD_ATTRIBUTE21 in VARCHAR2
,P_EDD_ATTRIBUTE22 in VARCHAR2
,P_EDD_ATTRIBUTE23 in VARCHAR2
,P_EDD_ATTRIBUTE24 in VARCHAR2
,P_EDD_ATTRIBUTE25 in VARCHAR2
,P_EDD_ATTRIBUTE26 in VARCHAR2
,P_EDD_ATTRIBUTE27 in VARCHAR2
,P_EDD_ATTRIBUTE28 in VARCHAR2
,P_EDD_ATTRIBUTE29 in VARCHAR2
,P_EDD_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_edd_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_edd_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_edd_RKI;

/
