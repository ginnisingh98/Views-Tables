--------------------------------------------------------
--  DDL for Package Body PER_BPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPR_RKD" as
/* $Header: pebprrhi.pkb 115.6 2002/12/02 14:33:23 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:43 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PAYROLL_RUN_ID in NUMBER
,P_PAYROLL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PAYROLL_IDENTIFIER_O in VARCHAR2
,P_PERIOD_START_DATE_O in DATE
,P_PERIOD_END_DATE_O in DATE
,P_PROCESSING_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_BPR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_BPR_ATTRIBUTE1_O in VARCHAR2
,P_BPR_ATTRIBUTE2_O in VARCHAR2
,P_BPR_ATTRIBUTE3_O in VARCHAR2
,P_BPR_ATTRIBUTE4_O in VARCHAR2
,P_BPR_ATTRIBUTE5_O in VARCHAR2
,P_BPR_ATTRIBUTE6_O in VARCHAR2
,P_BPR_ATTRIBUTE7_O in VARCHAR2
,P_BPR_ATTRIBUTE8_O in VARCHAR2
,P_BPR_ATTRIBUTE9_O in VARCHAR2
,P_BPR_ATTRIBUTE10_O in VARCHAR2
,P_BPR_ATTRIBUTE11_O in VARCHAR2
,P_BPR_ATTRIBUTE12_O in VARCHAR2
,P_BPR_ATTRIBUTE13_O in VARCHAR2
,P_BPR_ATTRIBUTE14_O in VARCHAR2
,P_BPR_ATTRIBUTE15_O in VARCHAR2
,P_BPR_ATTRIBUTE16_O in VARCHAR2
,P_BPR_ATTRIBUTE17_O in VARCHAR2
,P_BPR_ATTRIBUTE18_O in VARCHAR2
,P_BPR_ATTRIBUTE19_O in VARCHAR2
,P_BPR_ATTRIBUTE20_O in VARCHAR2
,P_BPR_ATTRIBUTE21_O in VARCHAR2
,P_BPR_ATTRIBUTE22_O in VARCHAR2
,P_BPR_ATTRIBUTE23_O in VARCHAR2
,P_BPR_ATTRIBUTE24_O in VARCHAR2
,P_BPR_ATTRIBUTE25_O in VARCHAR2
,P_BPR_ATTRIBUTE26_O in VARCHAR2
,P_BPR_ATTRIBUTE27_O in VARCHAR2
,P_BPR_ATTRIBUTE28_O in VARCHAR2
,P_BPR_ATTRIBUTE29_O in VARCHAR2
,P_BPR_ATTRIBUTE30_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_BPR_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_BPR_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_BPR_RKD;

/
