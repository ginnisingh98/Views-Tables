--------------------------------------------------------
--  DDL for Package Body BEN_BNB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNB_RKD" as
/* $Header: bebnbrhi.pkb 120.1 2006/04/02 22:53:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:45 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_BNFTS_BAL_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_BNFTS_BAL_USG_CD_O in VARCHAR2
,P_BNFTS_BAL_DESC_O in VARCHAR2
,P_UOM_O in VARCHAR2
,P_NNMNTRY_UOM_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_BNB_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_BNB_ATTRIBUTE1_O in VARCHAR2
,P_BNB_ATTRIBUTE2_O in VARCHAR2
,P_BNB_ATTRIBUTE3_O in VARCHAR2
,P_BNB_ATTRIBUTE4_O in VARCHAR2
,P_BNB_ATTRIBUTE5_O in VARCHAR2
,P_BNB_ATTRIBUTE6_O in VARCHAR2
,P_BNB_ATTRIBUTE7_O in VARCHAR2
,P_BNB_ATTRIBUTE8_O in VARCHAR2
,P_BNB_ATTRIBUTE9_O in VARCHAR2
,P_BNB_ATTRIBUTE10_O in VARCHAR2
,P_BNB_ATTRIBUTE11_O in VARCHAR2
,P_BNB_ATTRIBUTE12_O in VARCHAR2
,P_BNB_ATTRIBUTE13_O in VARCHAR2
,P_BNB_ATTRIBUTE14_O in VARCHAR2
,P_BNB_ATTRIBUTE15_O in VARCHAR2
,P_BNB_ATTRIBUTE16_O in VARCHAR2
,P_BNB_ATTRIBUTE17_O in VARCHAR2
,P_BNB_ATTRIBUTE18_O in VARCHAR2
,P_BNB_ATTRIBUTE19_O in VARCHAR2
,P_BNB_ATTRIBUTE20_O in VARCHAR2
,P_BNB_ATTRIBUTE21_O in VARCHAR2
,P_BNB_ATTRIBUTE22_O in VARCHAR2
,P_BNB_ATTRIBUTE23_O in VARCHAR2
,P_BNB_ATTRIBUTE24_O in VARCHAR2
,P_BNB_ATTRIBUTE25_O in VARCHAR2
,P_BNB_ATTRIBUTE26_O in VARCHAR2
,P_BNB_ATTRIBUTE27_O in VARCHAR2
,P_BNB_ATTRIBUTE28_O in VARCHAR2
,P_BNB_ATTRIBUTE29_O in VARCHAR2
,P_BNB_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_bnb_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_bnb_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_bnb_RKD;

/