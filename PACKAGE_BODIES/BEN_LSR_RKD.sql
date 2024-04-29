--------------------------------------------------------
--  DDL for Package Body BEN_LSR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LSR_RKD" as
/* $Header: belsrrhi.pkb 115.7 2002/12/16 17:38:48 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:55 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_LOS_RT_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_LOS_FCTR_ID_O in NUMBER
,P_ORDR_NUM_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_LSR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_LSR_ATTRIBUTE1_O in VARCHAR2
,P_LSR_ATTRIBUTE2_O in VARCHAR2
,P_LSR_ATTRIBUTE3_O in VARCHAR2
,P_LSR_ATTRIBUTE4_O in VARCHAR2
,P_LSR_ATTRIBUTE5_O in VARCHAR2
,P_LSR_ATTRIBUTE6_O in VARCHAR2
,P_LSR_ATTRIBUTE7_O in VARCHAR2
,P_LSR_ATTRIBUTE8_O in VARCHAR2
,P_LSR_ATTRIBUTE9_O in VARCHAR2
,P_LSR_ATTRIBUTE10_O in VARCHAR2
,P_LSR_ATTRIBUTE11_O in VARCHAR2
,P_LSR_ATTRIBUTE12_O in VARCHAR2
,P_LSR_ATTRIBUTE13_O in VARCHAR2
,P_LSR_ATTRIBUTE14_O in VARCHAR2
,P_LSR_ATTRIBUTE15_O in VARCHAR2
,P_LSR_ATTRIBUTE16_O in VARCHAR2
,P_LSR_ATTRIBUTE17_O in VARCHAR2
,P_LSR_ATTRIBUTE18_O in VARCHAR2
,P_LSR_ATTRIBUTE19_O in VARCHAR2
,P_LSR_ATTRIBUTE20_O in VARCHAR2
,P_LSR_ATTRIBUTE21_O in VARCHAR2
,P_LSR_ATTRIBUTE22_O in VARCHAR2
,P_LSR_ATTRIBUTE23_O in VARCHAR2
,P_LSR_ATTRIBUTE24_O in VARCHAR2
,P_LSR_ATTRIBUTE25_O in VARCHAR2
,P_LSR_ATTRIBUTE26_O in VARCHAR2
,P_LSR_ATTRIBUTE27_O in VARCHAR2
,P_LSR_ATTRIBUTE28_O in VARCHAR2
,P_LSR_ATTRIBUTE29_O in VARCHAR2
,P_LSR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_lsr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_lsr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_lsr_RKD;

/