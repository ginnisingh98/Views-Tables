--------------------------------------------------------
--  DDL for Package Body PER_BBA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BBA_RKD" as
/* $Header: pebbarhi.pkb 115.8 2002/12/02 13:03:45 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:41 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_BALANCE_AMOUNT_ID in NUMBER
,P_BALANCE_TYPE_ID_O in NUMBER
,P_PROCESSED_ASSIGNMENT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_YTD_AMOUNT_O in NUMBER
,P_FYTD_AMOUNT_O in NUMBER
,P_PTD_AMOUNT_O in NUMBER
,P_MTD_AMOUNT_O in NUMBER
,P_QTD_AMOUNT_O in NUMBER
,P_RUN_AMOUNT_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_BBA_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_BBA_ATTRIBUTE1_O in VARCHAR2
,P_BBA_ATTRIBUTE2_O in VARCHAR2
,P_BBA_ATTRIBUTE3_O in VARCHAR2
,P_BBA_ATTRIBUTE4_O in VARCHAR2
,P_BBA_ATTRIBUTE5_O in VARCHAR2
,P_BBA_ATTRIBUTE6_O in VARCHAR2
,P_BBA_ATTRIBUTE7_O in VARCHAR2
,P_BBA_ATTRIBUTE8_O in VARCHAR2
,P_BBA_ATTRIBUTE9_O in VARCHAR2
,P_BBA_ATTRIBUTE10_O in VARCHAR2
,P_BBA_ATTRIBUTE11_O in VARCHAR2
,P_BBA_ATTRIBUTE12_O in VARCHAR2
,P_BBA_ATTRIBUTE13_O in VARCHAR2
,P_BBA_ATTRIBUTE14_O in VARCHAR2
,P_BBA_ATTRIBUTE15_O in VARCHAR2
,P_BBA_ATTRIBUTE16_O in VARCHAR2
,P_BBA_ATTRIBUTE17_O in VARCHAR2
,P_BBA_ATTRIBUTE18_O in VARCHAR2
,P_BBA_ATTRIBUTE19_O in VARCHAR2
,P_BBA_ATTRIBUTE20_O in VARCHAR2
,P_BBA_ATTRIBUTE21_O in VARCHAR2
,P_BBA_ATTRIBUTE22_O in VARCHAR2
,P_BBA_ATTRIBUTE23_O in VARCHAR2
,P_BBA_ATTRIBUTE24_O in VARCHAR2
,P_BBA_ATTRIBUTE25_O in VARCHAR2
,P_BBA_ATTRIBUTE26_O in VARCHAR2
,P_BBA_ATTRIBUTE27_O in VARCHAR2
,P_BBA_ATTRIBUTE28_O in VARCHAR2
,P_BBA_ATTRIBUTE29_O in VARCHAR2
,P_BBA_ATTRIBUTE30_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_BBA_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_BBA_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_BBA_RKD;

/
