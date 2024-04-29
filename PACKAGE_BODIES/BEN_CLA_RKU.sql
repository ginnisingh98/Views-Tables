--------------------------------------------------------
--  DDL for Package Body BEN_CLA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLA_RKU" as
/* $Header: beclarhi.pkb 120.0 2005/05/28 01:03:20 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_CMBN_AGE_LOS_FCTR_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LOS_FCTR_ID in NUMBER
,P_AGE_FCTR_ID in NUMBER
,P_CMBND_MIN_VAL in NUMBER
,P_CMBND_MAX_VAL in NUMBER
,P_ORDR_NUM in NUMBER
,P_CLA_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CLA_ATTRIBUTE1 in VARCHAR2
,P_CLA_ATTRIBUTE2 in VARCHAR2
,P_CLA_ATTRIBUTE3 in VARCHAR2
,P_CLA_ATTRIBUTE4 in VARCHAR2
,P_CLA_ATTRIBUTE5 in VARCHAR2
,P_CLA_ATTRIBUTE6 in VARCHAR2
,P_CLA_ATTRIBUTE7 in VARCHAR2
,P_CLA_ATTRIBUTE8 in VARCHAR2
,P_CLA_ATTRIBUTE9 in VARCHAR2
,P_CLA_ATTRIBUTE10 in VARCHAR2
,P_CLA_ATTRIBUTE11 in VARCHAR2
,P_CLA_ATTRIBUTE12 in VARCHAR2
,P_CLA_ATTRIBUTE13 in VARCHAR2
,P_CLA_ATTRIBUTE14 in VARCHAR2
,P_CLA_ATTRIBUTE15 in VARCHAR2
,P_CLA_ATTRIBUTE16 in VARCHAR2
,P_CLA_ATTRIBUTE17 in VARCHAR2
,P_CLA_ATTRIBUTE18 in VARCHAR2
,P_CLA_ATTRIBUTE19 in VARCHAR2
,P_CLA_ATTRIBUTE20 in VARCHAR2
,P_CLA_ATTRIBUTE21 in VARCHAR2
,P_CLA_ATTRIBUTE22 in VARCHAR2
,P_CLA_ATTRIBUTE23 in VARCHAR2
,P_CLA_ATTRIBUTE24 in VARCHAR2
,P_CLA_ATTRIBUTE25 in VARCHAR2
,P_CLA_ATTRIBUTE26 in VARCHAR2
,P_CLA_ATTRIBUTE27 in VARCHAR2
,P_CLA_ATTRIBUTE28 in VARCHAR2
,P_CLA_ATTRIBUTE29 in VARCHAR2
,P_CLA_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_NAME in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LOS_FCTR_ID_O in NUMBER
,P_AGE_FCTR_ID_O in NUMBER
,P_CMBND_MIN_VAL_O in NUMBER
,P_CMBND_MAX_VAL_O in NUMBER
,P_ORDR_NUM_O in NUMBER
,P_CLA_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CLA_ATTRIBUTE1_O in VARCHAR2
,P_CLA_ATTRIBUTE2_O in VARCHAR2
,P_CLA_ATTRIBUTE3_O in VARCHAR2
,P_CLA_ATTRIBUTE4_O in VARCHAR2
,P_CLA_ATTRIBUTE5_O in VARCHAR2
,P_CLA_ATTRIBUTE6_O in VARCHAR2
,P_CLA_ATTRIBUTE7_O in VARCHAR2
,P_CLA_ATTRIBUTE8_O in VARCHAR2
,P_CLA_ATTRIBUTE9_O in VARCHAR2
,P_CLA_ATTRIBUTE10_O in VARCHAR2
,P_CLA_ATTRIBUTE11_O in VARCHAR2
,P_CLA_ATTRIBUTE12_O in VARCHAR2
,P_CLA_ATTRIBUTE13_O in VARCHAR2
,P_CLA_ATTRIBUTE14_O in VARCHAR2
,P_CLA_ATTRIBUTE15_O in VARCHAR2
,P_CLA_ATTRIBUTE16_O in VARCHAR2
,P_CLA_ATTRIBUTE17_O in VARCHAR2
,P_CLA_ATTRIBUTE18_O in VARCHAR2
,P_CLA_ATTRIBUTE19_O in VARCHAR2
,P_CLA_ATTRIBUTE20_O in VARCHAR2
,P_CLA_ATTRIBUTE21_O in VARCHAR2
,P_CLA_ATTRIBUTE22_O in VARCHAR2
,P_CLA_ATTRIBUTE23_O in VARCHAR2
,P_CLA_ATTRIBUTE24_O in VARCHAR2
,P_CLA_ATTRIBUTE25_O in VARCHAR2
,P_CLA_ATTRIBUTE26_O in VARCHAR2
,P_CLA_ATTRIBUTE27_O in VARCHAR2
,P_CLA_ATTRIBUTE28_O in VARCHAR2
,P_CLA_ATTRIBUTE29_O in VARCHAR2
,P_CLA_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_NAME_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_cla_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_cla_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_cla_RKU;

/
