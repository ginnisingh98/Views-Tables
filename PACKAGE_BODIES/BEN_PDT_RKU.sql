--------------------------------------------------------
--  DDL for Package Body BEN_PDT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDT_RKU" as
/* $Header: bepdtrhi.pkb 115.0 2003/10/30 09:33 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_PYMT_CHECK_DET_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CHECK_NUM in VARCHAR2
,P_PYMT_DT in DATE
,P_PYMT_AMT in NUMBER
,P_PDT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PDT_ATTRIBUTE1 in VARCHAR2
,P_PDT_ATTRIBUTE2 in VARCHAR2
,P_PDT_ATTRIBUTE3 in VARCHAR2
,P_PDT_ATTRIBUTE4 in VARCHAR2
,P_PDT_ATTRIBUTE5 in VARCHAR2
,P_PDT_ATTRIBUTE6 in VARCHAR2
,P_PDT_ATTRIBUTE7 in VARCHAR2
,P_PDT_ATTRIBUTE8 in VARCHAR2
,P_PDT_ATTRIBUTE9 in VARCHAR2
,P_PDT_ATTRIBUTE10 in VARCHAR2
,P_PDT_ATTRIBUTE11 in VARCHAR2
,P_PDT_ATTRIBUTE12 in VARCHAR2
,P_PDT_ATTRIBUTE13 in VARCHAR2
,P_PDT_ATTRIBUTE14 in VARCHAR2
,P_PDT_ATTRIBUTE15 in VARCHAR2
,P_PDT_ATTRIBUTE16 in VARCHAR2
,P_PDT_ATTRIBUTE17 in VARCHAR2
,P_PDT_ATTRIBUTE18 in VARCHAR2
,P_PDT_ATTRIBUTE19 in VARCHAR2
,P_PDT_ATTRIBUTE20 in VARCHAR2
,P_PDT_ATTRIBUTE21 in VARCHAR2
,P_PDT_ATTRIBUTE22 in VARCHAR2
,P_PDT_ATTRIBUTE23 in VARCHAR2
,P_PDT_ATTRIBUTE24 in VARCHAR2
,P_PDT_ATTRIBUTE25 in VARCHAR2
,P_PDT_ATTRIBUTE26 in VARCHAR2
,P_PDT_ATTRIBUTE27 in VARCHAR2
,P_PDT_ATTRIBUTE28 in VARCHAR2
,P_PDT_ATTRIBUTE29 in VARCHAR2
,P_PDT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PERSON_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CHECK_NUM_O in VARCHAR2
,P_PYMT_DT_O in DATE
,P_PYMT_AMT_O in NUMBER
,P_PDT_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PDT_ATTRIBUTE1_O in VARCHAR2
,P_PDT_ATTRIBUTE2_O in VARCHAR2
,P_PDT_ATTRIBUTE3_O in VARCHAR2
,P_PDT_ATTRIBUTE4_O in VARCHAR2
,P_PDT_ATTRIBUTE5_O in VARCHAR2
,P_PDT_ATTRIBUTE6_O in VARCHAR2
,P_PDT_ATTRIBUTE7_O in VARCHAR2
,P_PDT_ATTRIBUTE8_O in VARCHAR2
,P_PDT_ATTRIBUTE9_O in VARCHAR2
,P_PDT_ATTRIBUTE10_O in VARCHAR2
,P_PDT_ATTRIBUTE11_O in VARCHAR2
,P_PDT_ATTRIBUTE12_O in VARCHAR2
,P_PDT_ATTRIBUTE13_O in VARCHAR2
,P_PDT_ATTRIBUTE14_O in VARCHAR2
,P_PDT_ATTRIBUTE15_O in VARCHAR2
,P_PDT_ATTRIBUTE16_O in VARCHAR2
,P_PDT_ATTRIBUTE17_O in VARCHAR2
,P_PDT_ATTRIBUTE18_O in VARCHAR2
,P_PDT_ATTRIBUTE19_O in VARCHAR2
,P_PDT_ATTRIBUTE20_O in VARCHAR2
,P_PDT_ATTRIBUTE21_O in VARCHAR2
,P_PDT_ATTRIBUTE22_O in VARCHAR2
,P_PDT_ATTRIBUTE23_O in VARCHAR2
,P_PDT_ATTRIBUTE24_O in VARCHAR2
,P_PDT_ATTRIBUTE25_O in VARCHAR2
,P_PDT_ATTRIBUTE26_O in VARCHAR2
,P_PDT_ATTRIBUTE27_O in VARCHAR2
,P_PDT_ATTRIBUTE28_O in VARCHAR2
,P_PDT_ATTRIBUTE29_O in VARCHAR2
,P_PDT_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_PDT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_PDT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_PDT_RKU;

/