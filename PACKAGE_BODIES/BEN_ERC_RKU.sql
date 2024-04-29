--------------------------------------------------------
--  DDL for Package Body BEN_ERC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ERC_RKU" as
/* $Header: beercrhi.pkb 115.2 2002/12/11 11:16:15 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:23 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ENRT_RT_CTFN_ID in NUMBER
,P_ENRT_CTFN_TYP_CD in VARCHAR2
,P_RQD_FLAG in VARCHAR2
,P_ENRT_RT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ERC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ERC_ATTRIBUTE1 in VARCHAR2
,P_ERC_ATTRIBUTE2 in VARCHAR2
,P_ERC_ATTRIBUTE3 in VARCHAR2
,P_ERC_ATTRIBUTE4 in VARCHAR2
,P_ERC_ATTRIBUTE5 in VARCHAR2
,P_ERC_ATTRIBUTE6 in VARCHAR2
,P_ERC_ATTRIBUTE7 in VARCHAR2
,P_ERC_ATTRIBUTE8 in VARCHAR2
,P_ERC_ATTRIBUTE9 in VARCHAR2
,P_ERC_ATTRIBUTE10 in VARCHAR2
,P_ERC_ATTRIBUTE11 in VARCHAR2
,P_ERC_ATTRIBUTE12 in VARCHAR2
,P_ERC_ATTRIBUTE13 in VARCHAR2
,P_ERC_ATTRIBUTE14 in VARCHAR2
,P_ERC_ATTRIBUTE15 in VARCHAR2
,P_ERC_ATTRIBUTE16 in VARCHAR2
,P_ERC_ATTRIBUTE17 in VARCHAR2
,P_ERC_ATTRIBUTE18 in VARCHAR2
,P_ERC_ATTRIBUTE19 in VARCHAR2
,P_ERC_ATTRIBUTE20 in VARCHAR2
,P_ERC_ATTRIBUTE21 in VARCHAR2
,P_ERC_ATTRIBUTE22 in VARCHAR2
,P_ERC_ATTRIBUTE23 in VARCHAR2
,P_ERC_ATTRIBUTE24 in VARCHAR2
,P_ERC_ATTRIBUTE25 in VARCHAR2
,P_ERC_ATTRIBUTE26 in VARCHAR2
,P_ERC_ATTRIBUTE27 in VARCHAR2
,P_ERC_ATTRIBUTE28 in VARCHAR2
,P_ERC_ATTRIBUTE29 in VARCHAR2
,P_ERC_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_ENRT_CTFN_TYP_CD_O in VARCHAR2
,P_RQD_FLAG_O in VARCHAR2
,P_ENRT_RT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ERC_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ERC_ATTRIBUTE1_O in VARCHAR2
,P_ERC_ATTRIBUTE2_O in VARCHAR2
,P_ERC_ATTRIBUTE3_O in VARCHAR2
,P_ERC_ATTRIBUTE4_O in VARCHAR2
,P_ERC_ATTRIBUTE5_O in VARCHAR2
,P_ERC_ATTRIBUTE6_O in VARCHAR2
,P_ERC_ATTRIBUTE7_O in VARCHAR2
,P_ERC_ATTRIBUTE8_O in VARCHAR2
,P_ERC_ATTRIBUTE9_O in VARCHAR2
,P_ERC_ATTRIBUTE10_O in VARCHAR2
,P_ERC_ATTRIBUTE11_O in VARCHAR2
,P_ERC_ATTRIBUTE12_O in VARCHAR2
,P_ERC_ATTRIBUTE13_O in VARCHAR2
,P_ERC_ATTRIBUTE14_O in VARCHAR2
,P_ERC_ATTRIBUTE15_O in VARCHAR2
,P_ERC_ATTRIBUTE16_O in VARCHAR2
,P_ERC_ATTRIBUTE17_O in VARCHAR2
,P_ERC_ATTRIBUTE18_O in VARCHAR2
,P_ERC_ATTRIBUTE19_O in VARCHAR2
,P_ERC_ATTRIBUTE20_O in VARCHAR2
,P_ERC_ATTRIBUTE21_O in VARCHAR2
,P_ERC_ATTRIBUTE22_O in VARCHAR2
,P_ERC_ATTRIBUTE23_O in VARCHAR2
,P_ERC_ATTRIBUTE24_O in VARCHAR2
,P_ERC_ATTRIBUTE25_O in VARCHAR2
,P_ERC_ATTRIBUTE26_O in VARCHAR2
,P_ERC_ATTRIBUTE27_O in VARCHAR2
,P_ERC_ATTRIBUTE28_O in VARCHAR2
,P_ERC_ATTRIBUTE29_O in VARCHAR2
,P_ERC_ATTRIBUTE30_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ERC_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_ERC_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_ERC_RKU;

/