--------------------------------------------------------
--  DDL for Package Body BEN_PEN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEN_RKU" as
/* $Header: bepenrhi.pkb 120.21.12010000.2 2008/08/05 15:11:10 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_PRTT_ENRT_RSLT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_OIPL_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_PGM_ID in NUMBER
,P_PL_ID in NUMBER
,P_RPLCS_SSPNDD_RSLT_ID in NUMBER
,P_PTIP_ID in NUMBER
,P_PL_TYP_ID in NUMBER
,P_LER_ID in NUMBER
,P_SSPNDD_FLAG in VARCHAR2
,P_PRTT_IS_CVRD_FLAG in VARCHAR2
,P_BNFT_AMT in NUMBER
,P_UOM in VARCHAR2
,P_ORGNL_ENRT_DT in DATE
,P_ENRT_MTHD_CD in VARCHAR2
,P_NO_LNGR_ELIG_FLAG in VARCHAR2
,P_ENRT_OVRIDN_FLAG in VARCHAR2
,P_ENRT_OVRID_RSN_CD in VARCHAR2
,P_ERLST_DEENRT_DT in DATE
,P_ENRT_CVG_STRT_DT in DATE
,P_ENRT_CVG_THRU_DT in DATE
,P_ENRT_OVRID_THRU_DT in DATE
,P_PL_ORDR_NUM in NUMBER
,P_PLIP_ORDR_NUM in NUMBER
,P_PTIP_ORDR_NUM in NUMBER
,P_OIPL_ORDR_NUM in NUMBER
,P_PEN_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PEN_ATTRIBUTE1 in VARCHAR2
,P_PEN_ATTRIBUTE2 in VARCHAR2
,P_PEN_ATTRIBUTE3 in VARCHAR2
,P_PEN_ATTRIBUTE4 in VARCHAR2
,P_PEN_ATTRIBUTE5 in VARCHAR2
,P_PEN_ATTRIBUTE6 in VARCHAR2
,P_PEN_ATTRIBUTE7 in VARCHAR2
,P_PEN_ATTRIBUTE8 in VARCHAR2
,P_PEN_ATTRIBUTE9 in VARCHAR2
,P_PEN_ATTRIBUTE10 in VARCHAR2
,P_PEN_ATTRIBUTE11 in VARCHAR2
,P_PEN_ATTRIBUTE12 in VARCHAR2
,P_PEN_ATTRIBUTE13 in VARCHAR2
,P_PEN_ATTRIBUTE14 in VARCHAR2
,P_PEN_ATTRIBUTE15 in VARCHAR2
,P_PEN_ATTRIBUTE16 in VARCHAR2
,P_PEN_ATTRIBUTE17 in VARCHAR2
,P_PEN_ATTRIBUTE18 in VARCHAR2
,P_PEN_ATTRIBUTE19 in VARCHAR2
,P_PEN_ATTRIBUTE20 in VARCHAR2
,P_PEN_ATTRIBUTE21 in VARCHAR2
,P_PEN_ATTRIBUTE22 in VARCHAR2
,P_PEN_ATTRIBUTE23 in VARCHAR2
,P_PEN_ATTRIBUTE24 in VARCHAR2
,P_PEN_ATTRIBUTE25 in VARCHAR2
,P_PEN_ATTRIBUTE26 in VARCHAR2
,P_PEN_ATTRIBUTE27 in VARCHAR2
,P_PEN_ATTRIBUTE28 in VARCHAR2
,P_PEN_ATTRIBUTE29 in VARCHAR2
,P_PEN_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PER_IN_LER_ID in NUMBER
,P_BNFT_TYP_CD in VARCHAR2
,P_BNFT_ORDR_NUM in NUMBER
,P_PRTT_ENRT_RSLT_STAT_CD in VARCHAR2
,P_BNFT_NNMNTRY_UOM in VARCHAR2
,P_COMP_LVL_CD in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OIPL_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_ASSIGNMENT_ID_O in NUMBER
,P_PGM_ID_O in NUMBER
,P_PL_ID_O in NUMBER
,P_RPLCS_SSPNDD_RSLT_ID_O in NUMBER
,P_PTIP_ID_O in NUMBER
,P_PL_TYP_ID_O in NUMBER
,P_LER_ID_O in NUMBER
,P_SSPNDD_FLAG_O in VARCHAR2
,P_PRTT_IS_CVRD_FLAG_O in VARCHAR2
,P_BNFT_AMT_O in NUMBER
,P_UOM_O in VARCHAR2
,P_ORGNL_ENRT_DT_O in DATE
,P_ENRT_MTHD_CD_O in VARCHAR2
,P_NO_LNGR_ELIG_FLAG_O in VARCHAR2
,P_ENRT_OVRIDN_FLAG_O in VARCHAR2
,P_ENRT_OVRID_RSN_CD_O in VARCHAR2
,P_ERLST_DEENRT_DT_O in DATE
,P_ENRT_CVG_STRT_DT_O in DATE
,P_ENRT_CVG_THRU_DT_O in DATE
,P_ENRT_OVRID_THRU_DT_O in DATE
,P_PL_ORDR_NUM_O in NUMBER
,P_PLIP_ORDR_NUM_O in NUMBER
,P_PTIP_ORDR_NUM_O in NUMBER
,P_OIPL_ORDR_NUM_O in NUMBER
,P_PEN_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PEN_ATTRIBUTE1_O in VARCHAR2
,P_PEN_ATTRIBUTE2_O in VARCHAR2
,P_PEN_ATTRIBUTE3_O in VARCHAR2
,P_PEN_ATTRIBUTE4_O in VARCHAR2
,P_PEN_ATTRIBUTE5_O in VARCHAR2
,P_PEN_ATTRIBUTE6_O in VARCHAR2
,P_PEN_ATTRIBUTE7_O in VARCHAR2
,P_PEN_ATTRIBUTE8_O in VARCHAR2
,P_PEN_ATTRIBUTE9_O in VARCHAR2
,P_PEN_ATTRIBUTE10_O in VARCHAR2
,P_PEN_ATTRIBUTE11_O in VARCHAR2
,P_PEN_ATTRIBUTE12_O in VARCHAR2
,P_PEN_ATTRIBUTE13_O in VARCHAR2
,P_PEN_ATTRIBUTE14_O in VARCHAR2
,P_PEN_ATTRIBUTE15_O in VARCHAR2
,P_PEN_ATTRIBUTE16_O in VARCHAR2
,P_PEN_ATTRIBUTE17_O in VARCHAR2
,P_PEN_ATTRIBUTE18_O in VARCHAR2
,P_PEN_ATTRIBUTE19_O in VARCHAR2
,P_PEN_ATTRIBUTE20_O in VARCHAR2
,P_PEN_ATTRIBUTE21_O in VARCHAR2
,P_PEN_ATTRIBUTE22_O in VARCHAR2
,P_PEN_ATTRIBUTE23_O in VARCHAR2
,P_PEN_ATTRIBUTE24_O in VARCHAR2
,P_PEN_ATTRIBUTE25_O in VARCHAR2
,P_PEN_ATTRIBUTE26_O in VARCHAR2
,P_PEN_ATTRIBUTE27_O in VARCHAR2
,P_PEN_ATTRIBUTE28_O in VARCHAR2
,P_PEN_ATTRIBUTE29_O in VARCHAR2
,P_PEN_ATTRIBUTE30_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_PER_IN_LER_ID_O in NUMBER
,P_BNFT_TYP_CD_O in VARCHAR2
,P_BNFT_ORDR_NUM_O in NUMBER
,P_PRTT_ENRT_RSLT_STAT_CD_O in VARCHAR2
,P_BNFT_NNMNTRY_UOM_O in VARCHAR2
,P_COMP_LVL_CD_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PEN_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_PEN_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_PEN_RKU;

/