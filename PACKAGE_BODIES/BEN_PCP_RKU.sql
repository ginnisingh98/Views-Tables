--------------------------------------------------------
--  DDL for Package Body BEN_PCP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCP_RKU" as
/* $Header: bepcprhi.pkb 115.13 2002/12/16 12:00:12 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_PL_PCP_ID in NUMBER
,P_PL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PCP_STRT_DT_CD in VARCHAR2
,P_PCP_DSGN_CD in VARCHAR2
,P_PCP_DPNT_DSGN_CD in VARCHAR2
,P_PCP_RPSTRY_FLAG in VARCHAR2
,P_PCP_CAN_KEEP_FLAG in VARCHAR2
,P_PCP_RADIUS in NUMBER
,P_PCP_RADIUS_UOM in VARCHAR2
,P_PCP_RADIUS_WARN_FLAG in VARCHAR2
,P_PCP_NUM_CHGS in NUMBER
,P_PCP_NUM_CHGS_UOM in VARCHAR2
,P_PCP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PCP_ATTRIBUTE1 in VARCHAR2
,P_PCP_ATTRIBUTE2 in VARCHAR2
,P_PCP_ATTRIBUTE3 in VARCHAR2
,P_PCP_ATTRIBUTE4 in VARCHAR2
,P_PCP_ATTRIBUTE5 in VARCHAR2
,P_PCP_ATTRIBUTE6 in VARCHAR2
,P_PCP_ATTRIBUTE7 in VARCHAR2
,P_PCP_ATTRIBUTE8 in VARCHAR2
,P_PCP_ATTRIBUTE9 in VARCHAR2
,P_PCP_ATTRIBUTE10 in VARCHAR2
,P_PCP_ATTRIBUTE11 in VARCHAR2
,P_PCP_ATTRIBUTE12 in VARCHAR2
,P_PCP_ATTRIBUTE13 in VARCHAR2
,P_PCP_ATTRIBUTE14 in VARCHAR2
,P_PCP_ATTRIBUTE15 in VARCHAR2
,P_PCP_ATTRIBUTE16 in VARCHAR2
,P_PCP_ATTRIBUTE17 in VARCHAR2
,P_PCP_ATTRIBUTE18 in VARCHAR2
,P_PCP_ATTRIBUTE19 in VARCHAR2
,P_PCP_ATTRIBUTE20 in VARCHAR2
,P_PCP_ATTRIBUTE21 in VARCHAR2
,P_PCP_ATTRIBUTE22 in VARCHAR2
,P_PCP_ATTRIBUTE23 in VARCHAR2
,P_PCP_ATTRIBUTE24 in VARCHAR2
,P_PCP_ATTRIBUTE25 in VARCHAR2
,P_PCP_ATTRIBUTE26 in VARCHAR2
,P_PCP_ATTRIBUTE27 in VARCHAR2
,P_PCP_ATTRIBUTE28 in VARCHAR2
,P_PCP_ATTRIBUTE29 in VARCHAR2
,P_PCP_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PCP_STRT_DT_CD_O in VARCHAR2
,P_PCP_DSGN_CD_O in VARCHAR2
,P_PCP_DPNT_DSGN_CD_O in VARCHAR2
,P_PCP_RPSTRY_FLAG_O in VARCHAR2
,P_PCP_CAN_KEEP_FLAG_O in VARCHAR2
,P_PCP_RADIUS_O in NUMBER
,P_PCP_RADIUS_UOM_O in VARCHAR2
,P_PCP_RADIUS_WARN_FLAG_O in VARCHAR2
,P_PCP_NUM_CHGS_O in NUMBER
,P_PCP_NUM_CHGS_UOM_O in VARCHAR2
,P_PCP_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PCP_ATTRIBUTE1_O in VARCHAR2
,P_PCP_ATTRIBUTE2_O in VARCHAR2
,P_PCP_ATTRIBUTE3_O in VARCHAR2
,P_PCP_ATTRIBUTE4_O in VARCHAR2
,P_PCP_ATTRIBUTE5_O in VARCHAR2
,P_PCP_ATTRIBUTE6_O in VARCHAR2
,P_PCP_ATTRIBUTE7_O in VARCHAR2
,P_PCP_ATTRIBUTE8_O in VARCHAR2
,P_PCP_ATTRIBUTE9_O in VARCHAR2
,P_PCP_ATTRIBUTE10_O in VARCHAR2
,P_PCP_ATTRIBUTE11_O in VARCHAR2
,P_PCP_ATTRIBUTE12_O in VARCHAR2
,P_PCP_ATTRIBUTE13_O in VARCHAR2
,P_PCP_ATTRIBUTE14_O in VARCHAR2
,P_PCP_ATTRIBUTE15_O in VARCHAR2
,P_PCP_ATTRIBUTE16_O in VARCHAR2
,P_PCP_ATTRIBUTE17_O in VARCHAR2
,P_PCP_ATTRIBUTE18_O in VARCHAR2
,P_PCP_ATTRIBUTE19_O in VARCHAR2
,P_PCP_ATTRIBUTE20_O in VARCHAR2
,P_PCP_ATTRIBUTE21_O in VARCHAR2
,P_PCP_ATTRIBUTE22_O in VARCHAR2
,P_PCP_ATTRIBUTE23_O in VARCHAR2
,P_PCP_ATTRIBUTE24_O in VARCHAR2
,P_PCP_ATTRIBUTE25_O in VARCHAR2
,P_PCP_ATTRIBUTE26_O in VARCHAR2
,P_PCP_ATTRIBUTE27_O in VARCHAR2
,P_PCP_ATTRIBUTE28_O in VARCHAR2
,P_PCP_ATTRIBUTE29_O in VARCHAR2
,P_PCP_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_PCP_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_PCP_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_PCP_RKU;

/