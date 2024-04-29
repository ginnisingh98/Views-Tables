--------------------------------------------------------
--  DDL for Package Body BEN_RCL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RCL_RKI" as
/* $Header: berclrhi.pkb 115.13 2004/06/30 23:53:24 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:48 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_RLTD_PER_CHG_CS_LER_ID in NUMBER
,P_NAME in VARCHAR2
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OLD_VAL in VARCHAR2
,P_NEW_VAL in VARCHAR2
,P_WHATIF_LBL_TXT in VARCHAR2
,P_RULE_OVERRIDES_FLAG in VARCHAR2
,P_SOURCE_COLUMN in VARCHAR2
,P_SOURCE_TABLE in VARCHAR2
,P_RLTD_PER_CHG_CS_LER_RL in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_RCL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_RCL_ATTRIBUTE1 in VARCHAR2
,P_RCL_ATTRIBUTE2 in VARCHAR2
,P_RCL_ATTRIBUTE3 in VARCHAR2
,P_RCL_ATTRIBUTE4 in VARCHAR2
,P_RCL_ATTRIBUTE5 in VARCHAR2
,P_RCL_ATTRIBUTE6 in VARCHAR2
,P_RCL_ATTRIBUTE7 in VARCHAR2
,P_RCL_ATTRIBUTE8 in VARCHAR2
,P_RCL_ATTRIBUTE9 in VARCHAR2
,P_RCL_ATTRIBUTE10 in VARCHAR2
,P_RCL_ATTRIBUTE11 in VARCHAR2
,P_RCL_ATTRIBUTE12 in VARCHAR2
,P_RCL_ATTRIBUTE13 in VARCHAR2
,P_RCL_ATTRIBUTE14 in VARCHAR2
,P_RCL_ATTRIBUTE15 in VARCHAR2
,P_RCL_ATTRIBUTE16 in VARCHAR2
,P_RCL_ATTRIBUTE17 in VARCHAR2
,P_RCL_ATTRIBUTE18 in VARCHAR2
,P_RCL_ATTRIBUTE19 in VARCHAR2
,P_RCL_ATTRIBUTE20 in VARCHAR2
,P_RCL_ATTRIBUTE21 in VARCHAR2
,P_RCL_ATTRIBUTE22 in VARCHAR2
,P_RCL_ATTRIBUTE23 in VARCHAR2
,P_RCL_ATTRIBUTE24 in VARCHAR2
,P_RCL_ATTRIBUTE25 in VARCHAR2
,P_RCL_ATTRIBUTE26 in VARCHAR2
,P_RCL_ATTRIBUTE27 in VARCHAR2
,P_RCL_ATTRIBUTE28 in VARCHAR2
,P_RCL_ATTRIBUTE29 in VARCHAR2
,P_RCL_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_rcl_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_rcl_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_rcl_RKI;

/
