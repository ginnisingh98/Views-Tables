--------------------------------------------------------
--  DDL for Package Body BEN_XRC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRC_RKD" as
/* $Header: bexrcrhi.pkb 120.0 2005/05/28 12:37:58 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:14 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EXT_RCD_ID in NUMBER
,P_NAME_O in VARCHAR2
,P_XML_TAG_NAME_O in VARCHAR2
,P_RCD_TYPE_CD_O in VARCHAR2
,P_LOW_LVL_CD_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_XRC_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_XRC_ATTRIBUTE1_O in VARCHAR2
,P_XRC_ATTRIBUTE2_O in VARCHAR2
,P_XRC_ATTRIBUTE3_O in VARCHAR2
,P_XRC_ATTRIBUTE4_O in VARCHAR2
,P_XRC_ATTRIBUTE5_O in VARCHAR2
,P_XRC_ATTRIBUTE6_O in VARCHAR2
,P_XRC_ATTRIBUTE7_O in VARCHAR2
,P_XRC_ATTRIBUTE8_O in VARCHAR2
,P_XRC_ATTRIBUTE9_O in VARCHAR2
,P_XRC_ATTRIBUTE10_O in VARCHAR2
,P_XRC_ATTRIBUTE11_O in VARCHAR2
,P_XRC_ATTRIBUTE12_O in VARCHAR2
,P_XRC_ATTRIBUTE13_O in VARCHAR2
,P_XRC_ATTRIBUTE14_O in VARCHAR2
,P_XRC_ATTRIBUTE15_O in VARCHAR2
,P_XRC_ATTRIBUTE16_O in VARCHAR2
,P_XRC_ATTRIBUTE17_O in VARCHAR2
,P_XRC_ATTRIBUTE18_O in VARCHAR2
,P_XRC_ATTRIBUTE19_O in VARCHAR2
,P_XRC_ATTRIBUTE20_O in VARCHAR2
,P_XRC_ATTRIBUTE21_O in VARCHAR2
,P_XRC_ATTRIBUTE22_O in VARCHAR2
,P_XRC_ATTRIBUTE23_O in VARCHAR2
,P_XRC_ATTRIBUTE24_O in VARCHAR2
,P_XRC_ATTRIBUTE25_O in VARCHAR2
,P_XRC_ATTRIBUTE26_O in VARCHAR2
,P_XRC_ATTRIBUTE27_O in VARCHAR2
,P_XRC_ATTRIBUTE28_O in VARCHAR2
,P_XRC_ATTRIBUTE29_O in VARCHAR2
,P_XRC_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_xrc_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_xrc_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_xrc_RKD;

/
