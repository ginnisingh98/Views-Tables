--------------------------------------------------------
--  DDL for Package Body BEN_PTP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTP_RKD" as
/* $Header: beptprhi.pkb 120.1 2005/06/02 03:22:51 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:44 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PL_TYP_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_MX_ENRL_ALWD_NUM_O in NUMBER
,P_MN_ENRL_RQD_NUM_O in NUMBER
,P_PL_TYP_STAT_CD_O in VARCHAR2
,P_OPT_TYP_CD_O in VARCHAR2
,P_OPT_DSPLY_FMT_CD_O in VARCHAR2
,P_COMP_TYP_CD_O in VARCHAR2
,P_IVR_IDENT_O in VARCHAR2
,P_NO_MX_ENRL_NUM_DFND_FLAG_O in VARCHAR2
,P_NO_MN_ENRL_NUM_DFND_FLAG_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PTP_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PTP_ATTRIBUTE1_O in VARCHAR2
,P_PTP_ATTRIBUTE2_O in VARCHAR2
,P_PTP_ATTRIBUTE3_O in VARCHAR2
,P_PTP_ATTRIBUTE4_O in VARCHAR2
,P_PTP_ATTRIBUTE5_O in VARCHAR2
,P_PTP_ATTRIBUTE6_O in VARCHAR2
,P_PTP_ATTRIBUTE7_O in VARCHAR2
,P_PTP_ATTRIBUTE8_O in VARCHAR2
,P_PTP_ATTRIBUTE9_O in VARCHAR2
,P_PTP_ATTRIBUTE10_O in VARCHAR2
,P_PTP_ATTRIBUTE11_O in VARCHAR2
,P_PTP_ATTRIBUTE12_O in VARCHAR2
,P_PTP_ATTRIBUTE13_O in VARCHAR2
,P_PTP_ATTRIBUTE14_O in VARCHAR2
,P_PTP_ATTRIBUTE15_O in VARCHAR2
,P_PTP_ATTRIBUTE16_O in VARCHAR2
,P_PTP_ATTRIBUTE17_O in VARCHAR2
,P_PTP_ATTRIBUTE18_O in VARCHAR2
,P_PTP_ATTRIBUTE19_O in VARCHAR2
,P_PTP_ATTRIBUTE20_O in VARCHAR2
,P_PTP_ATTRIBUTE21_O in VARCHAR2
,P_PTP_ATTRIBUTE22_O in VARCHAR2
,P_PTP_ATTRIBUTE23_O in VARCHAR2
,P_PTP_ATTRIBUTE24_O in VARCHAR2
,P_PTP_ATTRIBUTE25_O in VARCHAR2
,P_PTP_ATTRIBUTE26_O in VARCHAR2
,P_PTP_ATTRIBUTE27_O in VARCHAR2
,P_PTP_ATTRIBUTE28_O in VARCHAR2
,P_PTP_ATTRIBUTE29_O in VARCHAR2
,P_PTP_ATTRIBUTE30_O in VARCHAR2
,P_SHORT_NAME_O in VARCHAR2
,P_SHORT_CODE_O in VARCHAR2
,P_LEGISLATION_CODE_O in VARCHAR2
,P_LEGISLATION_SUBGROUP_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_PTP_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: BEN_PTP_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end BEN_PTP_RKD;

/
