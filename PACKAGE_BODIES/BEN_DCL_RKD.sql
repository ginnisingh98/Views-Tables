--------------------------------------------------------
--  DDL for Package Body BEN_DCL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DCL_RKD" as
/* $Header: bedclrhi.pkb 120.2 2006/03/30 23:57:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:27 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_DPNT_CVRD_OTHR_PL_RT_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ORDR_NUM_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_CVG_DET_DT_CD_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_PL_ID_O in NUMBER
,P_DCL_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_DCL_ATTRIBUTE1_O in VARCHAR2
,P_DCL_ATTRIBUTE2_O in VARCHAR2
,P_DCL_ATTRIBUTE3_O in VARCHAR2
,P_DCL_ATTRIBUTE4_O in VARCHAR2
,P_DCL_ATTRIBUTE5_O in VARCHAR2
,P_DCL_ATTRIBUTE6_O in VARCHAR2
,P_DCL_ATTRIBUTE7_O in VARCHAR2
,P_DCL_ATTRIBUTE8_O in VARCHAR2
,P_DCL_ATTRIBUTE9_O in VARCHAR2
,P_DCL_ATTRIBUTE10_O in VARCHAR2
,P_DCL_ATTRIBUTE11_O in VARCHAR2
,P_DCL_ATTRIBUTE12_O in VARCHAR2
,P_DCL_ATTRIBUTE13_O in VARCHAR2
,P_DCL_ATTRIBUTE14_O in VARCHAR2
,P_DCL_ATTRIBUTE15_O in VARCHAR2
,P_DCL_ATTRIBUTE16_O in VARCHAR2
,P_DCL_ATTRIBUTE17_O in VARCHAR2
,P_DCL_ATTRIBUTE18_O in VARCHAR2
,P_DCL_ATTRIBUTE19_O in VARCHAR2
,P_DCL_ATTRIBUTE20_O in VARCHAR2
,P_DCL_ATTRIBUTE21_O in VARCHAR2
,P_DCL_ATTRIBUTE22_O in VARCHAR2
,P_DCL_ATTRIBUTE23_O in VARCHAR2
,P_DCL_ATTRIBUTE24_O in VARCHAR2
,P_DCL_ATTRIBUTE25_O in VARCHAR2
,P_DCL_ATTRIBUTE26_O in VARCHAR2
,P_DCL_ATTRIBUTE27_O in VARCHAR2
,P_DCL_ATTRIBUTE28_O in VARCHAR2
,P_DCL_ATTRIBUTE29_O in VARCHAR2
,P_DCL_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_DCL_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: BEN_DCL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end BEN_DCL_RKD;

/