--------------------------------------------------------
--  DDL for Package Body BEN_PCG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCG_RKD" as
/* $Header: bepcgrhi.pkb 115.8 2002/12/16 11:58:08 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PRTT_CLM_GD_OR_SVC_TYP_ID in NUMBER
,P_PRTT_REIMBMT_RQST_ID_O in NUMBER
,P_GD_OR_SVC_TYP_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PCG_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PCG_ATTRIBUTE1_O in VARCHAR2
,P_PCG_ATTRIBUTE2_O in VARCHAR2
,P_PCG_ATTRIBUTE3_O in VARCHAR2
,P_PCG_ATTRIBUTE4_O in VARCHAR2
,P_PCG_ATTRIBUTE5_O in VARCHAR2
,P_PCG_ATTRIBUTE6_O in VARCHAR2
,P_PCG_ATTRIBUTE7_O in VARCHAR2
,P_PCG_ATTRIBUTE8_O in VARCHAR2
,P_PCG_ATTRIBUTE9_O in VARCHAR2
,P_PCG_ATTRIBUTE10_O in VARCHAR2
,P_PCG_ATTRIBUTE11_O in VARCHAR2
,P_PCG_ATTRIBUTE12_O in VARCHAR2
,P_PCG_ATTRIBUTE13_O in VARCHAR2
,P_PCG_ATTRIBUTE14_O in VARCHAR2
,P_PCG_ATTRIBUTE15_O in VARCHAR2
,P_PCG_ATTRIBUTE16_O in VARCHAR2
,P_PCG_ATTRIBUTE17_O in VARCHAR2
,P_PCG_ATTRIBUTE18_O in VARCHAR2
,P_PCG_ATTRIBUTE19_O in VARCHAR2
,P_PCG_ATTRIBUTE20_O in VARCHAR2
,P_PCG_ATTRIBUTE21_O in VARCHAR2
,P_PCG_ATTRIBUTE22_O in VARCHAR2
,P_PCG_ATTRIBUTE23_O in VARCHAR2
,P_PCG_ATTRIBUTE24_O in VARCHAR2
,P_PCG_ATTRIBUTE25_O in VARCHAR2
,P_PCG_ATTRIBUTE26_O in VARCHAR2
,P_PCG_ATTRIBUTE27_O in VARCHAR2
,P_PCG_ATTRIBUTE28_O in VARCHAR2
,P_PCG_ATTRIBUTE29_O in VARCHAR2
,P_PCG_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_PL_GD_OR_SVC_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_pcg_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_pcg_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_pcg_RKD;

/