--------------------------------------------------------
--  DDL for Package Body BEN_PAT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PAT_RKI" as
/* $Header: bepatrhi.pkb 120.1 2007/03/28 15:49:02 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_POPL_ACTN_TYP_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ACTN_TYP_DUE_DT_CD in VARCHAR2
,P_ACTN_TYP_DUE_DT_RL in NUMBER
,P_ACTN_TYP_ID in NUMBER
,P_PGM_ID in NUMBER
,P_PL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PAT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PAT_ATTRIBUTE1 in VARCHAR2
,P_PAT_ATTRIBUTE2 in VARCHAR2
,P_PAT_ATTRIBUTE3 in VARCHAR2
,P_PAT_ATTRIBUTE4 in VARCHAR2
,P_PAT_ATTRIBUTE5 in VARCHAR2
,P_PAT_ATTRIBUTE6 in VARCHAR2
,P_PAT_ATTRIBUTE7 in VARCHAR2
,P_PAT_ATTRIBUTE8 in VARCHAR2
,P_PAT_ATTRIBUTE9 in VARCHAR2
,P_PAT_ATTRIBUTE10 in VARCHAR2
,P_PAT_ATTRIBUTE11 in VARCHAR2
,P_PAT_ATTRIBUTE12 in VARCHAR2
,P_PAT_ATTRIBUTE13 in VARCHAR2
,P_PAT_ATTRIBUTE14 in VARCHAR2
,P_PAT_ATTRIBUTE15 in VARCHAR2
,P_PAT_ATTRIBUTE16 in VARCHAR2
,P_PAT_ATTRIBUTE17 in VARCHAR2
,P_PAT_ATTRIBUTE18 in VARCHAR2
,P_PAT_ATTRIBUTE19 in VARCHAR2
,P_PAT_ATTRIBUTE20 in VARCHAR2
,P_PAT_ATTRIBUTE21 in VARCHAR2
,P_PAT_ATTRIBUTE22 in VARCHAR2
,P_PAT_ATTRIBUTE23 in VARCHAR2
,P_PAT_ATTRIBUTE24 in VARCHAR2
,P_PAT_ATTRIBUTE25 in VARCHAR2
,P_PAT_ATTRIBUTE26 in VARCHAR2
,P_PAT_ATTRIBUTE27 in VARCHAR2
,P_PAT_ATTRIBUTE28 in VARCHAR2
,P_PAT_ATTRIBUTE29 in VARCHAR2
,P_PAT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_MANDATORY in VARCHAR2
,P_ONCE_OR_ALWAYS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_pat_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_pat_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_pat_RKI;

/
