--------------------------------------------------------
--  DDL for Package Body BEN_CRT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRT_RKU" as
/* $Header: becrtrhi.pkb 115.11 2004/06/22 07:52:16 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_CRT_ORDR_ID in NUMBER
,P_CRT_ORDR_TYP_CD in VARCHAR2
,P_APLS_PERD_ENDG_DT in DATE
,P_APLS_PERD_STRTG_DT in DATE
,P_CRT_IDENT in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_DETD_QLFD_ORDR_DT in DATE
,P_ISSUE_DT in DATE
,P_QDRO_AMT in NUMBER
,P_QDRO_DSTR_MTHD_CD in VARCHAR2
,P_QDRO_PCT in NUMBER
,P_RCVD_DT in DATE
,P_UOM in VARCHAR2
,P_CRT_ISSNG in VARCHAR2
,P_PL_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CRT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CRT_ATTRIBUTE1 in VARCHAR2
,P_CRT_ATTRIBUTE2 in VARCHAR2
,P_CRT_ATTRIBUTE3 in VARCHAR2
,P_CRT_ATTRIBUTE4 in VARCHAR2
,P_CRT_ATTRIBUTE5 in VARCHAR2
,P_CRT_ATTRIBUTE6 in VARCHAR2
,P_CRT_ATTRIBUTE7 in VARCHAR2
,P_CRT_ATTRIBUTE8 in VARCHAR2
,P_CRT_ATTRIBUTE9 in VARCHAR2
,P_CRT_ATTRIBUTE10 in VARCHAR2
,P_CRT_ATTRIBUTE11 in VARCHAR2
,P_CRT_ATTRIBUTE12 in VARCHAR2
,P_CRT_ATTRIBUTE13 in VARCHAR2
,P_CRT_ATTRIBUTE14 in VARCHAR2
,P_CRT_ATTRIBUTE15 in VARCHAR2
,P_CRT_ATTRIBUTE16 in VARCHAR2
,P_CRT_ATTRIBUTE17 in VARCHAR2
,P_CRT_ATTRIBUTE18 in VARCHAR2
,P_CRT_ATTRIBUTE19 in VARCHAR2
,P_CRT_ATTRIBUTE20 in VARCHAR2
,P_CRT_ATTRIBUTE21 in VARCHAR2
,P_CRT_ATTRIBUTE22 in VARCHAR2
,P_CRT_ATTRIBUTE23 in VARCHAR2
,P_CRT_ATTRIBUTE24 in VARCHAR2
,P_CRT_ATTRIBUTE25 in VARCHAR2
,P_CRT_ATTRIBUTE26 in VARCHAR2
,P_CRT_ATTRIBUTE27 in VARCHAR2
,P_CRT_ATTRIBUTE28 in VARCHAR2
,P_CRT_ATTRIBUTE29 in VARCHAR2
,P_CRT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_QDRO_NUM_PYMT_VAL in NUMBER
,P_QDRO_PER_PERD_CD in VARCHAR2
,P_PL_TYP_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_CRT_ORDR_TYP_CD_O in VARCHAR2
,P_APLS_PERD_ENDG_DT_O in DATE
,P_APLS_PERD_STRTG_DT_O in DATE
,P_CRT_IDENT_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_DETD_QLFD_ORDR_DT_O in DATE
,P_ISSUE_DT_O in DATE
,P_QDRO_AMT_O in NUMBER
,P_QDRO_DSTR_MTHD_CD_O in VARCHAR2
,P_QDRO_PCT_O in NUMBER
,P_RCVD_DT_O in DATE
,P_UOM_O in VARCHAR2
,P_CRT_ISSNG_O in VARCHAR2
,P_PL_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CRT_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CRT_ATTRIBUTE1_O in VARCHAR2
,P_CRT_ATTRIBUTE2_O in VARCHAR2
,P_CRT_ATTRIBUTE3_O in VARCHAR2
,P_CRT_ATTRIBUTE4_O in VARCHAR2
,P_CRT_ATTRIBUTE5_O in VARCHAR2
,P_CRT_ATTRIBUTE6_O in VARCHAR2
,P_CRT_ATTRIBUTE7_O in VARCHAR2
,P_CRT_ATTRIBUTE8_O in VARCHAR2
,P_CRT_ATTRIBUTE9_O in VARCHAR2
,P_CRT_ATTRIBUTE10_O in VARCHAR2
,P_CRT_ATTRIBUTE11_O in VARCHAR2
,P_CRT_ATTRIBUTE12_O in VARCHAR2
,P_CRT_ATTRIBUTE13_O in VARCHAR2
,P_CRT_ATTRIBUTE14_O in VARCHAR2
,P_CRT_ATTRIBUTE15_O in VARCHAR2
,P_CRT_ATTRIBUTE16_O in VARCHAR2
,P_CRT_ATTRIBUTE17_O in VARCHAR2
,P_CRT_ATTRIBUTE18_O in VARCHAR2
,P_CRT_ATTRIBUTE19_O in VARCHAR2
,P_CRT_ATTRIBUTE20_O in VARCHAR2
,P_CRT_ATTRIBUTE21_O in VARCHAR2
,P_CRT_ATTRIBUTE22_O in VARCHAR2
,P_CRT_ATTRIBUTE23_O in VARCHAR2
,P_CRT_ATTRIBUTE24_O in VARCHAR2
,P_CRT_ATTRIBUTE25_O in VARCHAR2
,P_CRT_ATTRIBUTE26_O in VARCHAR2
,P_CRT_ATTRIBUTE27_O in VARCHAR2
,P_CRT_ATTRIBUTE28_O in VARCHAR2
,P_CRT_ATTRIBUTE29_O in VARCHAR2
,P_CRT_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_QDRO_NUM_PYMT_VAL_O in NUMBER
,P_QDRO_PER_PERD_CD_O in VARCHAR2
,P_PL_TYP_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_crt_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_crt_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_crt_RKU;

/
