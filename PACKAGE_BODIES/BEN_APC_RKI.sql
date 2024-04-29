--------------------------------------------------------
--  DDL for Package Body BEN_APC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_APC_RKI" as
/* $Header: beapcrhi.pkb 120.0.12010000.2 2008/08/05 14:01:46 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ACRS_PTIP_CVG_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_NAME in VARCHAR2
,P_MX_CVG_ALWD_AMT in NUMBER
,P_MN_CVG_ALWD_AMT in NUMBER
,P_PGM_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_APC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_APC_ATTRIBUTE1 in VARCHAR2
,P_APC_ATTRIBUTE2 in VARCHAR2
,P_APC_ATTRIBUTE3 in VARCHAR2
,P_APC_ATTRIBUTE4 in VARCHAR2
,P_APC_ATTRIBUTE5 in VARCHAR2
,P_APC_ATTRIBUTE6 in VARCHAR2
,P_APC_ATTRIBUTE7 in VARCHAR2
,P_APC_ATTRIBUTE8 in VARCHAR2
,P_APC_ATTRIBUTE9 in VARCHAR2
,P_APC_ATTRIBUTE10 in VARCHAR2
,P_APC_ATTRIBUTE11 in VARCHAR2
,P_APC_ATTRIBUTE12 in VARCHAR2
,P_APC_ATTRIBUTE13 in VARCHAR2
,P_APC_ATTRIBUTE14 in VARCHAR2
,P_APC_ATTRIBUTE15 in VARCHAR2
,P_APC_ATTRIBUTE16 in VARCHAR2
,P_APC_ATTRIBUTE17 in VARCHAR2
,P_APC_ATTRIBUTE18 in VARCHAR2
,P_APC_ATTRIBUTE19 in VARCHAR2
,P_APC_ATTRIBUTE20 in VARCHAR2
,P_APC_ATTRIBUTE21 in VARCHAR2
,P_APC_ATTRIBUTE22 in VARCHAR2
,P_APC_ATTRIBUTE23 in VARCHAR2
,P_APC_ATTRIBUTE24 in VARCHAR2
,P_APC_ATTRIBUTE25 in VARCHAR2
,P_APC_ATTRIBUTE26 in VARCHAR2
,P_APC_ATTRIBUTE27 in VARCHAR2
,P_APC_ATTRIBUTE28 in VARCHAR2
,P_APC_ATTRIBUTE29 in VARCHAR2
,P_APC_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_apc_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_apc_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_apc_RKI;

/