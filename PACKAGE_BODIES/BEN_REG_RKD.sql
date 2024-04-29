--------------------------------------------------------
--  DDL for Package Body BEN_REG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REG_RKD" as
/* $Header: beregrhi.pkb 120.0.12010000.4 2008/08/05 15:26:02 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_REGN_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_ORGANIZATION_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_STTRY_CITN_NAME_O in VARCHAR2
,P_REG_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_REG_ATTRIBUTE1_O in VARCHAR2
,P_REG_ATTRIBUTE2_O in VARCHAR2
,P_REG_ATTRIBUTE3_O in VARCHAR2
,P_REG_ATTRIBUTE4_O in VARCHAR2
,P_REG_ATTRIBUTE5_O in VARCHAR2
,P_REG_ATTRIBUTE6_O in VARCHAR2
,P_REG_ATTRIBUTE7_O in VARCHAR2
,P_REG_ATTRIBUTE8_O in VARCHAR2
,P_REG_ATTRIBUTE9_O in VARCHAR2
,P_REG_ATTRIBUTE10_O in VARCHAR2
,P_REG_ATTRIBUTE11_O in VARCHAR2
,P_REG_ATTRIBUTE12_O in VARCHAR2
,P_REG_ATTRIBUTE13_O in VARCHAR2
,P_REG_ATTRIBUTE14_O in VARCHAR2
,P_REG_ATTRIBUTE15_O in VARCHAR2
,P_REG_ATTRIBUTE16_O in VARCHAR2
,P_REG_ATTRIBUTE17_O in VARCHAR2
,P_REG_ATTRIBUTE18_O in VARCHAR2
,P_REG_ATTRIBUTE19_O in VARCHAR2
,P_REG_ATTRIBUTE20_O in VARCHAR2
,P_REG_ATTRIBUTE21_O in VARCHAR2
,P_REG_ATTRIBUTE22_O in VARCHAR2
,P_REG_ATTRIBUTE23_O in VARCHAR2
,P_REG_ATTRIBUTE24_O in VARCHAR2
,P_REG_ATTRIBUTE25_O in VARCHAR2
,P_REG_ATTRIBUTE26_O in VARCHAR2
,P_REG_ATTRIBUTE27_O in VARCHAR2
,P_REG_ATTRIBUTE28_O in VARCHAR2
,P_REG_ATTRIBUTE29_O in VARCHAR2
,P_REG_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_reg_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_reg_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_reg_RKD;

/