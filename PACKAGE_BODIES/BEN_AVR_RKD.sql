--------------------------------------------------------
--  DDL for Package Body BEN_AVR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AVR_RKD" as
/* $Header: beavrrhi.pkb 120.0.12010000.2 2008/08/05 14:04:44 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ACTY_VRBL_RT_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ACTY_BASE_RT_ID_O in NUMBER
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_ORDR_NUM_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_AVR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_AVR_ATTRIBUTE1_O in VARCHAR2
,P_AVR_ATTRIBUTE2_O in VARCHAR2
,P_AVR_ATTRIBUTE3_O in VARCHAR2
,P_AVR_ATTRIBUTE4_O in VARCHAR2
,P_AVR_ATTRIBUTE5_O in VARCHAR2
,P_AVR_ATTRIBUTE6_O in VARCHAR2
,P_AVR_ATTRIBUTE7_O in VARCHAR2
,P_AVR_ATTRIBUTE8_O in VARCHAR2
,P_AVR_ATTRIBUTE9_O in VARCHAR2
,P_AVR_ATTRIBUTE10_O in VARCHAR2
,P_AVR_ATTRIBUTE11_O in VARCHAR2
,P_AVR_ATTRIBUTE12_O in VARCHAR2
,P_AVR_ATTRIBUTE13_O in VARCHAR2
,P_AVR_ATTRIBUTE14_O in VARCHAR2
,P_AVR_ATTRIBUTE15_O in VARCHAR2
,P_AVR_ATTRIBUTE16_O in VARCHAR2
,P_AVR_ATTRIBUTE17_O in VARCHAR2
,P_AVR_ATTRIBUTE18_O in VARCHAR2
,P_AVR_ATTRIBUTE19_O in VARCHAR2
,P_AVR_ATTRIBUTE20_O in VARCHAR2
,P_AVR_ATTRIBUTE21_O in VARCHAR2
,P_AVR_ATTRIBUTE22_O in VARCHAR2
,P_AVR_ATTRIBUTE23_O in VARCHAR2
,P_AVR_ATTRIBUTE24_O in VARCHAR2
,P_AVR_ATTRIBUTE25_O in VARCHAR2
,P_AVR_ATTRIBUTE26_O in VARCHAR2
,P_AVR_ATTRIBUTE27_O in VARCHAR2
,P_AVR_ATTRIBUTE28_O in VARCHAR2
,P_AVR_ATTRIBUTE29_O in VARCHAR2
,P_AVR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_avr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_avr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_avr_RKD;

/
