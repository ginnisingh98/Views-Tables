--------------------------------------------------------
--  DDL for Package Body BEN_PAP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PAP_RKI" as
/* $Header: bepaprhi.pkb 120.2 2006/03/31 00:01:01 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:03 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PRTT_ANTHR_PL_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_PL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PAP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PAP_ATTRIBUTE1 in VARCHAR2
,P_PAP_ATTRIBUTE2 in VARCHAR2
,P_PAP_ATTRIBUTE3 in VARCHAR2
,P_PAP_ATTRIBUTE4 in VARCHAR2
,P_PAP_ATTRIBUTE5 in VARCHAR2
,P_PAP_ATTRIBUTE6 in VARCHAR2
,P_PAP_ATTRIBUTE7 in VARCHAR2
,P_PAP_ATTRIBUTE8 in VARCHAR2
,P_PAP_ATTRIBUTE9 in VARCHAR2
,P_PAP_ATTRIBUTE10 in VARCHAR2
,P_PAP_ATTRIBUTE11 in VARCHAR2
,P_PAP_ATTRIBUTE12 in VARCHAR2
,P_PAP_ATTRIBUTE13 in VARCHAR2
,P_PAP_ATTRIBUTE14 in VARCHAR2
,P_PAP_ATTRIBUTE15 in VARCHAR2
,P_PAP_ATTRIBUTE16 in VARCHAR2
,P_PAP_ATTRIBUTE17 in VARCHAR2
,P_PAP_ATTRIBUTE18 in VARCHAR2
,P_PAP_ATTRIBUTE19 in VARCHAR2
,P_PAP_ATTRIBUTE20 in VARCHAR2
,P_PAP_ATTRIBUTE21 in VARCHAR2
,P_PAP_ATTRIBUTE22 in VARCHAR2
,P_PAP_ATTRIBUTE23 in VARCHAR2
,P_PAP_ATTRIBUTE24 in VARCHAR2
,P_PAP_ATTRIBUTE25 in VARCHAR2
,P_PAP_ATTRIBUTE26 in VARCHAR2
,P_PAP_ATTRIBUTE27 in VARCHAR2
,P_PAP_ATTRIBUTE28 in VARCHAR2
,P_PAP_ATTRIBUTE29 in VARCHAR2
,P_PAP_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_PAP_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: BEN_PAP_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end BEN_PAP_RKI;

/
