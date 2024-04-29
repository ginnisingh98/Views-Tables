--------------------------------------------------------
--  DDL for Package Body BEN_YRP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_YRP_RKD" as
/* $Header: beyrprhi.pkb 120.0 2005/05/28 12:44:45 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_YR_PERD_ID in NUMBER
,P_PERDS_IN_YR_NUM_O in NUMBER
,P_PERD_TM_UOM_CD_O in VARCHAR2
,P_PERD_TYP_CD_O in VARCHAR2
,P_END_DATE_O in DATE
,P_START_DATE_O in DATE
,P_LMTN_YR_STRT_DT_O in DATE
,P_LMTN_YR_END_DT_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_YRP_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_YRP_ATTRIBUTE1_O in VARCHAR2
,P_YRP_ATTRIBUTE2_O in VARCHAR2
,P_YRP_ATTRIBUTE3_O in VARCHAR2
,P_YRP_ATTRIBUTE4_O in VARCHAR2
,P_YRP_ATTRIBUTE5_O in VARCHAR2
,P_YRP_ATTRIBUTE6_O in VARCHAR2
,P_YRP_ATTRIBUTE7_O in VARCHAR2
,P_YRP_ATTRIBUTE8_O in VARCHAR2
,P_YRP_ATTRIBUTE9_O in VARCHAR2
,P_YRP_ATTRIBUTE10_O in VARCHAR2
,P_YRP_ATTRIBUTE11_O in VARCHAR2
,P_YRP_ATTRIBUTE12_O in VARCHAR2
,P_YRP_ATTRIBUTE13_O in VARCHAR2
,P_YRP_ATTRIBUTE14_O in VARCHAR2
,P_YRP_ATTRIBUTE15_O in VARCHAR2
,P_YRP_ATTRIBUTE16_O in VARCHAR2
,P_YRP_ATTRIBUTE17_O in VARCHAR2
,P_YRP_ATTRIBUTE18_O in VARCHAR2
,P_YRP_ATTRIBUTE19_O in VARCHAR2
,P_YRP_ATTRIBUTE20_O in VARCHAR2
,P_YRP_ATTRIBUTE21_O in VARCHAR2
,P_YRP_ATTRIBUTE22_O in VARCHAR2
,P_YRP_ATTRIBUTE23_O in VARCHAR2
,P_YRP_ATTRIBUTE24_O in VARCHAR2
,P_YRP_ATTRIBUTE25_O in VARCHAR2
,P_YRP_ATTRIBUTE26_O in VARCHAR2
,P_YRP_ATTRIBUTE27_O in VARCHAR2
,P_YRP_ATTRIBUTE28_O in VARCHAR2
,P_YRP_ATTRIBUTE29_O in VARCHAR2
,P_YRP_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_yrp_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_yrp_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_yrp_RKD;

/