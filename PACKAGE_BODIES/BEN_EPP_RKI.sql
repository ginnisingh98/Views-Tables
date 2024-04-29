--------------------------------------------------------
--  DDL for Package Body BEN_EPP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPP_RKI" as
/* $Header: beepprhi.pkb 120.1 2006/03/01 05:36:51 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ELIG_PRTT_ANTHR_PL_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_PL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EPP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EPP_ATTRIBUTE1 in VARCHAR2
,P_EPP_ATTRIBUTE2 in VARCHAR2
,P_EPP_ATTRIBUTE3 in VARCHAR2
,P_EPP_ATTRIBUTE4 in VARCHAR2
,P_EPP_ATTRIBUTE5 in VARCHAR2
,P_EPP_ATTRIBUTE6 in VARCHAR2
,P_EPP_ATTRIBUTE7 in VARCHAR2
,P_EPP_ATTRIBUTE8 in VARCHAR2
,P_EPP_ATTRIBUTE9 in VARCHAR2
,P_EPP_ATTRIBUTE10 in VARCHAR2
,P_EPP_ATTRIBUTE11 in VARCHAR2
,P_EPP_ATTRIBUTE12 in VARCHAR2
,P_EPP_ATTRIBUTE13 in VARCHAR2
,P_EPP_ATTRIBUTE14 in VARCHAR2
,P_EPP_ATTRIBUTE15 in VARCHAR2
,P_EPP_ATTRIBUTE16 in VARCHAR2
,P_EPP_ATTRIBUTE17 in VARCHAR2
,P_EPP_ATTRIBUTE18 in VARCHAR2
,P_EPP_ATTRIBUTE19 in VARCHAR2
,P_EPP_ATTRIBUTE20 in VARCHAR2
,P_EPP_ATTRIBUTE21 in VARCHAR2
,P_EPP_ATTRIBUTE22 in VARCHAR2
,P_EPP_ATTRIBUTE23 in VARCHAR2
,P_EPP_ATTRIBUTE24 in VARCHAR2
,P_EPP_ATTRIBUTE25 in VARCHAR2
,P_EPP_ATTRIBUTE26 in VARCHAR2
,P_EPP_ATTRIBUTE27 in VARCHAR2
,P_EPP_ATTRIBUTE28 in VARCHAR2
,P_EPP_ATTRIBUTE29 in VARCHAR2
,P_EPP_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_epp_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_epp_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_epp_RKI;

/