--------------------------------------------------------
--  DDL for Package Body BEN_ECC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECC_RKD" as
/* $Header: beeccrhi.pkb 120.0 2005/05/28 01:49:03 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:40 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ELCTBL_CHC_CTFN_ID in NUMBER
,P_ENRT_CTFN_TYP_CD_O in VARCHAR2
,P_RQD_FLAG_O in VARCHAR2
,P_ELIG_PER_ELCTBL_CHC_ID_O in NUMBER
,P_ENRT_BNFT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ECC_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ECC_ATTRIBUTE1_O in VARCHAR2
,P_ECC_ATTRIBUTE2_O in VARCHAR2
,P_ECC_ATTRIBUTE3_O in VARCHAR2
,P_ECC_ATTRIBUTE4_O in VARCHAR2
,P_ECC_ATTRIBUTE5_O in VARCHAR2
,P_ECC_ATTRIBUTE6_O in VARCHAR2
,P_ECC_ATTRIBUTE7_O in VARCHAR2
,P_ECC_ATTRIBUTE8_O in VARCHAR2
,P_ECC_ATTRIBUTE9_O in VARCHAR2
,P_ECC_ATTRIBUTE10_O in VARCHAR2
,P_ECC_ATTRIBUTE11_O in VARCHAR2
,P_ECC_ATTRIBUTE12_O in VARCHAR2
,P_ECC_ATTRIBUTE13_O in VARCHAR2
,P_ECC_ATTRIBUTE14_O in VARCHAR2
,P_ECC_ATTRIBUTE15_O in VARCHAR2
,P_ECC_ATTRIBUTE16_O in VARCHAR2
,P_ECC_ATTRIBUTE17_O in VARCHAR2
,P_ECC_ATTRIBUTE18_O in VARCHAR2
,P_ECC_ATTRIBUTE19_O in VARCHAR2
,P_ECC_ATTRIBUTE20_O in VARCHAR2
,P_ECC_ATTRIBUTE21_O in VARCHAR2
,P_ECC_ATTRIBUTE22_O in VARCHAR2
,P_ECC_ATTRIBUTE23_O in VARCHAR2
,P_ECC_ATTRIBUTE24_O in VARCHAR2
,P_ECC_ATTRIBUTE25_O in VARCHAR2
,P_ECC_ATTRIBUTE26_O in VARCHAR2
,P_ECC_ATTRIBUTE27_O in VARCHAR2
,P_ECC_ATTRIBUTE28_O in VARCHAR2
,P_ECC_ATTRIBUTE29_O in VARCHAR2
,P_ECC_ATTRIBUTE30_O in VARCHAR2
,P_SUSP_IF_CTFN_NOT_PRVD_FLAG_O in VARCHAR2
,P_CTFN_DETERMINE_CD_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_ecc_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_ecc_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_ecc_RKD;

/