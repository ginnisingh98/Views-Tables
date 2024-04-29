--------------------------------------------------------
--  DDL for Package Body BEN_DRR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DRR_RKD" as
/* $Header: bedrrrhi.pkb 120.0 2005/05/28 01:40:22 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:32 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_DSGN_RQMT_RLSHP_TYP_ID in NUMBER
,P_RLSHP_TYP_CD_O in VARCHAR2
,P_DSGN_RQMT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DRR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_DRR_ATTRIBUTE1_O in VARCHAR2
,P_DRR_ATTRIBUTE2_O in VARCHAR2
,P_DRR_ATTRIBUTE3_O in VARCHAR2
,P_DRR_ATTRIBUTE4_O in VARCHAR2
,P_DRR_ATTRIBUTE5_O in VARCHAR2
,P_DRR_ATTRIBUTE6_O in VARCHAR2
,P_DRR_ATTRIBUTE7_O in VARCHAR2
,P_DRR_ATTRIBUTE8_O in VARCHAR2
,P_DRR_ATTRIBUTE9_O in VARCHAR2
,P_DRR_ATTRIBUTE10_O in VARCHAR2
,P_DRR_ATTRIBUTE11_O in VARCHAR2
,P_DRR_ATTRIBUTE12_O in VARCHAR2
,P_DRR_ATTRIBUTE13_O in VARCHAR2
,P_DRR_ATTRIBUTE14_O in VARCHAR2
,P_DRR_ATTRIBUTE15_O in VARCHAR2
,P_DRR_ATTRIBUTE16_O in VARCHAR2
,P_DRR_ATTRIBUTE17_O in VARCHAR2
,P_DRR_ATTRIBUTE18_O in VARCHAR2
,P_DRR_ATTRIBUTE19_O in VARCHAR2
,P_DRR_ATTRIBUTE20_O in VARCHAR2
,P_DRR_ATTRIBUTE21_O in VARCHAR2
,P_DRR_ATTRIBUTE22_O in VARCHAR2
,P_DRR_ATTRIBUTE23_O in VARCHAR2
,P_DRR_ATTRIBUTE24_O in VARCHAR2
,P_DRR_ATTRIBUTE25_O in VARCHAR2
,P_DRR_ATTRIBUTE26_O in VARCHAR2
,P_DRR_ATTRIBUTE27_O in VARCHAR2
,P_DRR_ATTRIBUTE28_O in VARCHAR2
,P_DRR_ATTRIBUTE29_O in VARCHAR2
,P_DRR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_drr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_drr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_drr_RKD;

/