--------------------------------------------------------
--  DDL for Package Body BEN_TCV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TCV_RKD" as
/* $Header: betcvrhi.pkb 120.0.12010000.2 2008/08/05 15:32:24 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_TTL_CVG_VOL_RT_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_NO_MN_CVG_VOL_AMT_APLS_FLA_O in VARCHAR2
,P_NO_MX_CVG_VOL_AMT_APLS_FLA_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_MN_CVG_VOL_AMT_O in NUMBER
,P_MX_CVG_VOL_AMT_O in NUMBER
,P_CVG_VOL_DET_CD_O in VARCHAR2
,P_CVG_VOL_DET_RL_O in NUMBER
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_TCV_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_TCV_ATTRIBUTE1_O in VARCHAR2
,P_TCV_ATTRIBUTE2_O in VARCHAR2
,P_TCV_ATTRIBUTE3_O in VARCHAR2
,P_TCV_ATTRIBUTE4_O in VARCHAR2
,P_TCV_ATTRIBUTE5_O in VARCHAR2
,P_TCV_ATTRIBUTE6_O in VARCHAR2
,P_TCV_ATTRIBUTE7_O in VARCHAR2
,P_TCV_ATTRIBUTE8_O in VARCHAR2
,P_TCV_ATTRIBUTE9_O in VARCHAR2
,P_TCV_ATTRIBUTE10_O in VARCHAR2
,P_TCV_ATTRIBUTE11_O in VARCHAR2
,P_TCV_ATTRIBUTE12_O in VARCHAR2
,P_TCV_ATTRIBUTE13_O in VARCHAR2
,P_TCV_ATTRIBUTE14_O in VARCHAR2
,P_TCV_ATTRIBUTE15_O in VARCHAR2
,P_TCV_ATTRIBUTE16_O in VARCHAR2
,P_TCV_ATTRIBUTE17_O in VARCHAR2
,P_TCV_ATTRIBUTE18_O in VARCHAR2
,P_TCV_ATTRIBUTE19_O in VARCHAR2
,P_TCV_ATTRIBUTE20_O in VARCHAR2
,P_TCV_ATTRIBUTE21_O in VARCHAR2
,P_TCV_ATTRIBUTE22_O in VARCHAR2
,P_TCV_ATTRIBUTE23_O in VARCHAR2
,P_TCV_ATTRIBUTE24_O in VARCHAR2
,P_TCV_ATTRIBUTE25_O in VARCHAR2
,P_TCV_ATTRIBUTE26_O in VARCHAR2
,P_TCV_ATTRIBUTE27_O in VARCHAR2
,P_TCV_ATTRIBUTE28_O in VARCHAR2
,P_TCV_ATTRIBUTE29_O in VARCHAR2
,P_TCV_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_tcv_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_tcv_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_tcv_RKD;

/
