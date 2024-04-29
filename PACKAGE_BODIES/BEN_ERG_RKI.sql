--------------------------------------------------------
--  DDL for Package Body BEN_ERG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ERG_RKI" as
/* $Header: beergrhi.pkb 120.1 2006/02/27 01:55:45 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ELIG_PERF_RTNG_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_EVENT_TYPE in VARCHAR2
,P_PERF_RTNG_CD in VARCHAR2
,P_ERG_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ERG_ATTRIBUTE1 in VARCHAR2
,P_ERG_ATTRIBUTE2 in VARCHAR2
,P_ERG_ATTRIBUTE3 in VARCHAR2
,P_ERG_ATTRIBUTE4 in VARCHAR2
,P_ERG_ATTRIBUTE5 in VARCHAR2
,P_ERG_ATTRIBUTE6 in VARCHAR2
,P_ERG_ATTRIBUTE7 in VARCHAR2
,P_ERG_ATTRIBUTE8 in VARCHAR2
,P_ERG_ATTRIBUTE9 in VARCHAR2
,P_ERG_ATTRIBUTE10 in VARCHAR2
,P_ERG_ATTRIBUTE11 in VARCHAR2
,P_ERG_ATTRIBUTE12 in VARCHAR2
,P_ERG_ATTRIBUTE13 in VARCHAR2
,P_ERG_ATTRIBUTE14 in VARCHAR2
,P_ERG_ATTRIBUTE15 in VARCHAR2
,P_ERG_ATTRIBUTE16 in VARCHAR2
,P_ERG_ATTRIBUTE17 in VARCHAR2
,P_ERG_ATTRIBUTE18 in VARCHAR2
,P_ERG_ATTRIBUTE19 in VARCHAR2
,P_ERG_ATTRIBUTE20 in VARCHAR2
,P_ERG_ATTRIBUTE21 in VARCHAR2
,P_ERG_ATTRIBUTE22 in VARCHAR2
,P_ERG_ATTRIBUTE23 in VARCHAR2
,P_ERG_ATTRIBUTE24 in VARCHAR2
,P_ERG_ATTRIBUTE25 in VARCHAR2
,P_ERG_ATTRIBUTE26 in VARCHAR2
,P_ERG_ATTRIBUTE27 in VARCHAR2
,P_ERG_ATTRIBUTE28 in VARCHAR2
,P_ERG_ATTRIBUTE29 in VARCHAR2
,P_ERG_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ERG_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: BEN_ERG_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end BEN_ERG_RKI;

/