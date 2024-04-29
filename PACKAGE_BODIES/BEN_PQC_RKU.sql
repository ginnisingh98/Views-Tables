--------------------------------------------------------
--  DDL for Package Body BEN_PQC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PQC_RKU" as
/* $Header: bepqcrhi.pkb 120.0.12010000.2 2008/08/05 15:17:32 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_PRTT_RMT_RQST_CTFN_PRVDD_ID in NUMBER
,P_PRTT_CLM_GD_OR_SVC_TYP_ID in NUMBER
,P_PL_GD_R_SVC_CTFN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_REIMBMT_CTFN_RQD_FLAG in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_PRTT_ENRT_ACTN_ID in NUMBER
,P_REIMBMT_CTFN_RECD_DT in DATE
,P_REIMBMT_CTFN_DND_DT in DATE
,P_REIMBMT_CTFN_TYP_CD in VARCHAR2
,P_PQC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PQC_ATTRIBUTE1 in VARCHAR2
,P_PQC_ATTRIBUTE2 in VARCHAR2
,P_PQC_ATTRIBUTE3 in VARCHAR2
,P_PQC_ATTRIBUTE4 in VARCHAR2
,P_PQC_ATTRIBUTE5 in VARCHAR2
,P_PQC_ATTRIBUTE6 in VARCHAR2
,P_PQC_ATTRIBUTE7 in VARCHAR2
,P_PQC_ATTRIBUTE8 in VARCHAR2
,P_PQC_ATTRIBUTE9 in VARCHAR2
,P_PQC_ATTRIBUTE10 in VARCHAR2
,P_PQC_ATTRIBUTE11 in VARCHAR2
,P_PQC_ATTRIBUTE12 in VARCHAR2
,P_PQC_ATTRIBUTE13 in VARCHAR2
,P_PQC_ATTRIBUTE14 in VARCHAR2
,P_PQC_ATTRIBUTE15 in VARCHAR2
,P_PQC_ATTRIBUTE16 in VARCHAR2
,P_PQC_ATTRIBUTE17 in VARCHAR2
,P_PQC_ATTRIBUTE18 in VARCHAR2
,P_PQC_ATTRIBUTE19 in VARCHAR2
,P_PQC_ATTRIBUTE20 in VARCHAR2
,P_PQC_ATTRIBUTE21 in VARCHAR2
,P_PQC_ATTRIBUTE22 in VARCHAR2
,P_PQC_ATTRIBUTE23 in VARCHAR2
,P_PQC_ATTRIBUTE24 in VARCHAR2
,P_PQC_ATTRIBUTE25 in VARCHAR2
,P_PQC_ATTRIBUTE26 in VARCHAR2
,P_PQC_ATTRIBUTE27 in VARCHAR2
,P_PQC_ATTRIBUTE28 in VARCHAR2
,P_PQC_ATTRIBUTE29 in VARCHAR2
,P_PQC_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PRTT_CLM_GD_OR_SVC_TYP_ID_O in NUMBER
,P_PL_GD_R_SVC_CTFN_ID_O in NUMBER
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_REIMBMT_CTFN_RQD_FLAG_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PRTT_ENRT_ACTN_ID_O in NUMBER
,P_REIMBMT_CTFN_RECD_DT_O in DATE
,P_REIMBMT_CTFN_DND_DT_O in DATE
,P_REIMBMT_CTFN_TYP_CD_O in VARCHAR2
,P_PQC_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PQC_ATTRIBUTE1_O in VARCHAR2
,P_PQC_ATTRIBUTE2_O in VARCHAR2
,P_PQC_ATTRIBUTE3_O in VARCHAR2
,P_PQC_ATTRIBUTE4_O in VARCHAR2
,P_PQC_ATTRIBUTE5_O in VARCHAR2
,P_PQC_ATTRIBUTE6_O in VARCHAR2
,P_PQC_ATTRIBUTE7_O in VARCHAR2
,P_PQC_ATTRIBUTE8_O in VARCHAR2
,P_PQC_ATTRIBUTE9_O in VARCHAR2
,P_PQC_ATTRIBUTE10_O in VARCHAR2
,P_PQC_ATTRIBUTE11_O in VARCHAR2
,P_PQC_ATTRIBUTE12_O in VARCHAR2
,P_PQC_ATTRIBUTE13_O in VARCHAR2
,P_PQC_ATTRIBUTE14_O in VARCHAR2
,P_PQC_ATTRIBUTE15_O in VARCHAR2
,P_PQC_ATTRIBUTE16_O in VARCHAR2
,P_PQC_ATTRIBUTE17_O in VARCHAR2
,P_PQC_ATTRIBUTE18_O in VARCHAR2
,P_PQC_ATTRIBUTE19_O in VARCHAR2
,P_PQC_ATTRIBUTE20_O in VARCHAR2
,P_PQC_ATTRIBUTE21_O in VARCHAR2
,P_PQC_ATTRIBUTE22_O in VARCHAR2
,P_PQC_ATTRIBUTE23_O in VARCHAR2
,P_PQC_ATTRIBUTE24_O in VARCHAR2
,P_PQC_ATTRIBUTE25_O in VARCHAR2
,P_PQC_ATTRIBUTE26_O in VARCHAR2
,P_PQC_ATTRIBUTE27_O in VARCHAR2
,P_PQC_ATTRIBUTE28_O in VARCHAR2
,P_PQC_ATTRIBUTE29_O in VARCHAR2
,P_PQC_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_PQC_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_PQC_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_PQC_RKU;

/