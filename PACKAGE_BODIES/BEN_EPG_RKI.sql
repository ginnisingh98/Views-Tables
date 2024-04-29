--------------------------------------------------------
--  DDL for Package Body BEN_EPG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPG_RKI" as
/* $Header: beepgrhi.pkb 120.1 2006/02/27 00:49:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:15 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ELIG_PPL_GRP_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_PEOPLE_GROUP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EPG_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EPG_ATTRIBUTE1 in VARCHAR2
,P_EPG_ATTRIBUTE2 in VARCHAR2
,P_EPG_ATTRIBUTE3 in VARCHAR2
,P_EPG_ATTRIBUTE4 in VARCHAR2
,P_EPG_ATTRIBUTE5 in VARCHAR2
,P_EPG_ATTRIBUTE6 in VARCHAR2
,P_EPG_ATTRIBUTE7 in VARCHAR2
,P_EPG_ATTRIBUTE8 in VARCHAR2
,P_EPG_ATTRIBUTE9 in VARCHAR2
,P_EPG_ATTRIBUTE10 in VARCHAR2
,P_EPG_ATTRIBUTE11 in VARCHAR2
,P_EPG_ATTRIBUTE12 in VARCHAR2
,P_EPG_ATTRIBUTE13 in VARCHAR2
,P_EPG_ATTRIBUTE14 in VARCHAR2
,P_EPG_ATTRIBUTE15 in VARCHAR2
,P_EPG_ATTRIBUTE16 in VARCHAR2
,P_EPG_ATTRIBUTE17 in VARCHAR2
,P_EPG_ATTRIBUTE18 in VARCHAR2
,P_EPG_ATTRIBUTE19 in VARCHAR2
,P_EPG_ATTRIBUTE20 in VARCHAR2
,P_EPG_ATTRIBUTE21 in VARCHAR2
,P_EPG_ATTRIBUTE22 in VARCHAR2
,P_EPG_ATTRIBUTE23 in VARCHAR2
,P_EPG_ATTRIBUTE24 in VARCHAR2
,P_EPG_ATTRIBUTE25 in VARCHAR2
,P_EPG_ATTRIBUTE26 in VARCHAR2
,P_EPG_ATTRIBUTE27 in VARCHAR2
,P_EPG_ATTRIBUTE28 in VARCHAR2
,P_EPG_ATTRIBUTE29 in VARCHAR2
,P_EPG_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_epg_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_epg_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_epg_RKI;

/