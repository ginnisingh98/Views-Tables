--------------------------------------------------------
--  DDL for Package Body BEN_PIL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_RKU" as
/* $Header: bepilrhi.pkb 120.3 2006/09/26 10:56:35 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:28 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_PER_IN_LER_ID in NUMBER
,P_PER_IN_LER_STAT_CD in VARCHAR2
,P_PRVS_STAT_CD in VARCHAR2
,P_LF_EVT_OCRD_DT in DATE
,P_TRGR_TABLE_PK_ID in NUMBER
,P_PROCD_DT in DATE
,P_STRTD_DT in DATE
,P_VOIDD_DT in DATE
,P_BCKT_DT in DATE
,P_CLSD_DT in DATE
,P_NTFN_DT in DATE
,P_PTNL_LER_FOR_PER_ID in NUMBER
,P_BCKT_PER_IN_LER_ID in NUMBER
,P_LER_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_WS_MGR_ID in NUMBER
,P_GROUP_PL_ID in NUMBER
,P_MGR_OVRID_PERSON_ID in NUMBER
,P_MGR_OVRID_DT in DATE
,P_PIL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PIL_ATTRIBUTE1 in VARCHAR2
,P_PIL_ATTRIBUTE2 in VARCHAR2
,P_PIL_ATTRIBUTE3 in VARCHAR2
,P_PIL_ATTRIBUTE4 in VARCHAR2
,P_PIL_ATTRIBUTE5 in VARCHAR2
,P_PIL_ATTRIBUTE6 in VARCHAR2
,P_PIL_ATTRIBUTE7 in VARCHAR2
,P_PIL_ATTRIBUTE8 in VARCHAR2
,P_PIL_ATTRIBUTE9 in VARCHAR2
,P_PIL_ATTRIBUTE10 in VARCHAR2
,P_PIL_ATTRIBUTE11 in VARCHAR2
,P_PIL_ATTRIBUTE12 in VARCHAR2
,P_PIL_ATTRIBUTE13 in VARCHAR2
,P_PIL_ATTRIBUTE14 in VARCHAR2
,P_PIL_ATTRIBUTE15 in VARCHAR2
,P_PIL_ATTRIBUTE16 in VARCHAR2
,P_PIL_ATTRIBUTE17 in VARCHAR2
,P_PIL_ATTRIBUTE18 in VARCHAR2
,P_PIL_ATTRIBUTE19 in VARCHAR2
,P_PIL_ATTRIBUTE20 in VARCHAR2
,P_PIL_ATTRIBUTE21 in VARCHAR2
,P_PIL_ATTRIBUTE22 in VARCHAR2
,P_PIL_ATTRIBUTE23 in VARCHAR2
,P_PIL_ATTRIBUTE24 in VARCHAR2
,P_PIL_ATTRIBUTE25 in VARCHAR2
,P_PIL_ATTRIBUTE26 in VARCHAR2
,P_PIL_ATTRIBUTE27 in VARCHAR2
,P_PIL_ATTRIBUTE28 in VARCHAR2
,P_PIL_ATTRIBUTE29 in VARCHAR2
,P_PIL_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_PER_IN_LER_STAT_CD_O in VARCHAR2
,P_PRVS_STAT_CD_O in VARCHAR2
,P_LF_EVT_OCRD_DT_O in DATE
,P_TRGR_TABLE_PK_ID_O in NUMBER
,P_PROCD_DT_O in DATE
,P_STRTD_DT_O in DATE
,P_VOIDD_DT_O in DATE
,P_BCKT_DT_O in DATE
,P_CLSD_DT_O in DATE
,P_NTFN_DT_O in DATE
,P_PTNL_LER_FOR_PER_ID_O in NUMBER
,P_BCKT_PER_IN_LER_ID_O in NUMBER
,P_LER_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ASSIGNMENT_ID_O in NUMBER
,P_WS_MGR_ID_O in NUMBER
,P_GROUP_PL_ID_O in NUMBER
,P_MGR_OVRID_PERSON_ID_O in NUMBER
,P_MGR_OVRID_DT_O in DATE
,P_PIL_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PIL_ATTRIBUTE1_O in VARCHAR2
,P_PIL_ATTRIBUTE2_O in VARCHAR2
,P_PIL_ATTRIBUTE3_O in VARCHAR2
,P_PIL_ATTRIBUTE4_O in VARCHAR2
,P_PIL_ATTRIBUTE5_O in VARCHAR2
,P_PIL_ATTRIBUTE6_O in VARCHAR2
,P_PIL_ATTRIBUTE7_O in VARCHAR2
,P_PIL_ATTRIBUTE8_O in VARCHAR2
,P_PIL_ATTRIBUTE9_O in VARCHAR2
,P_PIL_ATTRIBUTE10_O in VARCHAR2
,P_PIL_ATTRIBUTE11_O in VARCHAR2
,P_PIL_ATTRIBUTE12_O in VARCHAR2
,P_PIL_ATTRIBUTE13_O in VARCHAR2
,P_PIL_ATTRIBUTE14_O in VARCHAR2
,P_PIL_ATTRIBUTE15_O in VARCHAR2
,P_PIL_ATTRIBUTE16_O in VARCHAR2
,P_PIL_ATTRIBUTE17_O in VARCHAR2
,P_PIL_ATTRIBUTE18_O in VARCHAR2
,P_PIL_ATTRIBUTE19_O in VARCHAR2
,P_PIL_ATTRIBUTE20_O in VARCHAR2
,P_PIL_ATTRIBUTE21_O in VARCHAR2
,P_PIL_ATTRIBUTE22_O in VARCHAR2
,P_PIL_ATTRIBUTE23_O in VARCHAR2
,P_PIL_ATTRIBUTE24_O in VARCHAR2
,P_PIL_ATTRIBUTE25_O in VARCHAR2
,P_PIL_ATTRIBUTE26_O in VARCHAR2
,P_PIL_ATTRIBUTE27_O in VARCHAR2
,P_PIL_ATTRIBUTE28_O in VARCHAR2
,P_PIL_ATTRIBUTE29_O in VARCHAR2
,P_PIL_ATTRIBUTE30_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_pil_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_pil_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_pil_RKU;

/