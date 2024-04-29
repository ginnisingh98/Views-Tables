--------------------------------------------------------
--  DDL for Package Body BEN_XCR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCR_RKD" as
/* $Header: bexcrrhi.pkb 120.0 2005/05/28 12:25:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:08 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EXT_CRIT_PRFL_ID in NUMBER
,P_NAME_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_XCR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_XCR_ATTRIBUTE1_O in VARCHAR2
,P_XCR_ATTRIBUTE2_O in VARCHAR2
,P_XCR_ATTRIBUTE3_O in VARCHAR2
,P_XCR_ATTRIBUTE4_O in VARCHAR2
,P_XCR_ATTRIBUTE5_O in VARCHAR2
,P_XCR_ATTRIBUTE6_O in VARCHAR2
,P_XCR_ATTRIBUTE7_O in VARCHAR2
,P_XCR_ATTRIBUTE8_O in VARCHAR2
,P_XCR_ATTRIBUTE9_O in VARCHAR2
,P_XCR_ATTRIBUTE10_O in VARCHAR2
,P_XCR_ATTRIBUTE11_O in VARCHAR2
,P_XCR_ATTRIBUTE12_O in VARCHAR2
,P_XCR_ATTRIBUTE13_O in VARCHAR2
,P_XCR_ATTRIBUTE14_O in VARCHAR2
,P_XCR_ATTRIBUTE15_O in VARCHAR2
,P_XCR_ATTRIBUTE16_O in VARCHAR2
,P_XCR_ATTRIBUTE17_O in VARCHAR2
,P_XCR_ATTRIBUTE18_O in VARCHAR2
,P_XCR_ATTRIBUTE19_O in VARCHAR2
,P_XCR_ATTRIBUTE20_O in VARCHAR2
,P_XCR_ATTRIBUTE21_O in VARCHAR2
,P_XCR_ATTRIBUTE22_O in VARCHAR2
,P_XCR_ATTRIBUTE23_O in VARCHAR2
,P_XCR_ATTRIBUTE24_O in VARCHAR2
,P_XCR_ATTRIBUTE25_O in VARCHAR2
,P_XCR_ATTRIBUTE26_O in VARCHAR2
,P_XCR_ATTRIBUTE27_O in VARCHAR2
,P_XCR_ATTRIBUTE28_O in VARCHAR2
,P_XCR_ATTRIBUTE29_O in VARCHAR2
,P_XCR_ATTRIBUTE30_O in VARCHAR2
,P_EXT_GLOBAL_FLAG_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_xcr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_xcr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_xcr_RKD;

/
