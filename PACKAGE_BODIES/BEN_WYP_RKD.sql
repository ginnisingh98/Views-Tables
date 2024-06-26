--------------------------------------------------------
--  DDL for Package Body BEN_WYP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WYP_RKD" as
/* $Header: bewyprhi.pkb 115.12 2003/01/01 00:03:22 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:06 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_WTHN_YR_PERD_ID in NUMBER
,P_STRT_DAY_O in NUMBER
,P_END_DAY_O in NUMBER
,P_STRT_MO_O in NUMBER
,P_END_MO_O in NUMBER
,P_TM_UOM_O in VARCHAR2
,P_YR_PERD_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_WYP_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_WYP_ATTRIBUTE1_O in VARCHAR2
,P_WYP_ATTRIBUTE2_O in VARCHAR2
,P_WYP_ATTRIBUTE3_O in VARCHAR2
,P_WYP_ATTRIBUTE4_O in VARCHAR2
,P_WYP_ATTRIBUTE5_O in VARCHAR2
,P_WYP_ATTRIBUTE6_O in VARCHAR2
,P_WYP_ATTRIBUTE7_O in VARCHAR2
,P_WYP_ATTRIBUTE8_O in VARCHAR2
,P_WYP_ATTRIBUTE9_O in VARCHAR2
,P_WYP_ATTRIBUTE10_O in VARCHAR2
,P_WYP_ATTRIBUTE11_O in VARCHAR2
,P_WYP_ATTRIBUTE12_O in VARCHAR2
,P_WYP_ATTRIBUTE13_O in VARCHAR2
,P_WYP_ATTRIBUTE14_O in VARCHAR2
,P_WYP_ATTRIBUTE15_O in VARCHAR2
,P_WYP_ATTRIBUTE16_O in VARCHAR2
,P_WYP_ATTRIBUTE17_O in VARCHAR2
,P_WYP_ATTRIBUTE18_O in VARCHAR2
,P_WYP_ATTRIBUTE19_O in VARCHAR2
,P_WYP_ATTRIBUTE20_O in VARCHAR2
,P_WYP_ATTRIBUTE21_O in VARCHAR2
,P_WYP_ATTRIBUTE22_O in VARCHAR2
,P_WYP_ATTRIBUTE23_O in VARCHAR2
,P_WYP_ATTRIBUTE24_O in VARCHAR2
,P_WYP_ATTRIBUTE25_O in VARCHAR2
,P_WYP_ATTRIBUTE26_O in VARCHAR2
,P_WYP_ATTRIBUTE27_O in VARCHAR2
,P_WYP_ATTRIBUTE28_O in VARCHAR2
,P_WYP_ATTRIBUTE29_O in VARCHAR2
,P_WYP_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_wyp_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_wyp_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_wyp_RKD;

/
