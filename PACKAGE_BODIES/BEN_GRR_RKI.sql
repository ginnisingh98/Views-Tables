--------------------------------------------------------
--  DDL for Package Body BEN_GRR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GRR_RKI" as
/* $Header: begrrrhi.pkb 120.0 2005/05/28 03:09:17 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:34 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_GRADE_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_GRR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_GRR_ATTRIBUTE1 in VARCHAR2
,P_GRR_ATTRIBUTE2 in VARCHAR2
,P_GRR_ATTRIBUTE3 in VARCHAR2
,P_GRR_ATTRIBUTE4 in VARCHAR2
,P_GRR_ATTRIBUTE5 in VARCHAR2
,P_GRR_ATTRIBUTE6 in VARCHAR2
,P_GRR_ATTRIBUTE7 in VARCHAR2
,P_GRR_ATTRIBUTE8 in VARCHAR2
,P_GRR_ATTRIBUTE9 in VARCHAR2
,P_GRR_ATTRIBUTE10 in VARCHAR2
,P_GRR_ATTRIBUTE11 in VARCHAR2
,P_GRR_ATTRIBUTE12 in VARCHAR2
,P_GRR_ATTRIBUTE13 in VARCHAR2
,P_GRR_ATTRIBUTE14 in VARCHAR2
,P_GRR_ATTRIBUTE15 in VARCHAR2
,P_GRR_ATTRIBUTE16 in VARCHAR2
,P_GRR_ATTRIBUTE17 in VARCHAR2
,P_GRR_ATTRIBUTE18 in VARCHAR2
,P_GRR_ATTRIBUTE19 in VARCHAR2
,P_GRR_ATTRIBUTE20 in VARCHAR2
,P_GRR_ATTRIBUTE21 in VARCHAR2
,P_GRR_ATTRIBUTE22 in VARCHAR2
,P_GRR_ATTRIBUTE23 in VARCHAR2
,P_GRR_ATTRIBUTE24 in VARCHAR2
,P_GRR_ATTRIBUTE25 in VARCHAR2
,P_GRR_ATTRIBUTE26 in VARCHAR2
,P_GRR_ATTRIBUTE27 in VARCHAR2
,P_GRR_ATTRIBUTE28 in VARCHAR2
,P_GRR_ATTRIBUTE29 in VARCHAR2
,P_GRR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_grr_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_grr_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_grr_RKI;

/
