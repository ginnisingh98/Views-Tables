--------------------------------------------------------
--  DDL for Package Body PER_SSM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSM_RKU" as
/* $Header: pessmrhi.pkb 120.0 2005/05/31 21:50:48 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:25 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_OBJECT_VERSION_NUMBER in NUMBER
,P_SALARY_SURVEY_MAPPING_ID in NUMBER
,P_LOCATION_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_COMPANY_ORGANIZATION_ID in NUMBER
,P_COMPANY_AGE_CODE in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ATTRIBUTE1 in VARCHAR2
,P_ATTRIBUTE2 in VARCHAR2
,P_ATTRIBUTE3 in VARCHAR2
,P_ATTRIBUTE4 in VARCHAR2
,P_ATTRIBUTE5 in VARCHAR2
,P_ATTRIBUTE6 in VARCHAR2
,P_ATTRIBUTE7 in VARCHAR2
,P_ATTRIBUTE8 in VARCHAR2
,P_ATTRIBUTE9 in VARCHAR2
,P_ATTRIBUTE10 in VARCHAR2
,P_ATTRIBUTE11 in VARCHAR2
,P_ATTRIBUTE12 in VARCHAR2
,P_ATTRIBUTE13 in VARCHAR2
,P_ATTRIBUTE14 in VARCHAR2
,P_ATTRIBUTE15 in VARCHAR2
,P_ATTRIBUTE16 in VARCHAR2
,P_ATTRIBUTE17 in VARCHAR2
,P_ATTRIBUTE18 in VARCHAR2
,P_ATTRIBUTE19 in VARCHAR2
,P_ATTRIBUTE20 in VARCHAR2
,P_PARENT_ID_O in NUMBER
,P_PARENT_TABLE_NAME_O in VARCHAR2
,P_SALARY_SURVEY_LINE_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LOCATION_ID_O in NUMBER
,P_GRADE_ID_O in NUMBER
,P_COMPANY_ORGANIZATION_ID_O in NUMBER
,P_COMPANY_AGE_CODE_O in VARCHAR2
,P_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ATTRIBUTE1_O in VARCHAR2
,P_ATTRIBUTE2_O in VARCHAR2
,P_ATTRIBUTE3_O in VARCHAR2
,P_ATTRIBUTE4_O in VARCHAR2
,P_ATTRIBUTE5_O in VARCHAR2
,P_ATTRIBUTE6_O in VARCHAR2
,P_ATTRIBUTE7_O in VARCHAR2
,P_ATTRIBUTE8_O in VARCHAR2
,P_ATTRIBUTE9_O in VARCHAR2
,P_ATTRIBUTE10_O in VARCHAR2
,P_ATTRIBUTE11_O in VARCHAR2
,P_ATTRIBUTE12_O in VARCHAR2
,P_ATTRIBUTE13_O in VARCHAR2
,P_ATTRIBUTE14_O in VARCHAR2
,P_ATTRIBUTE15_O in VARCHAR2
,P_ATTRIBUTE16_O in VARCHAR2
,P_ATTRIBUTE17_O in VARCHAR2
,P_ATTRIBUTE18_O in VARCHAR2
,P_ATTRIBUTE19_O in VARCHAR2
,P_ATTRIBUTE20_O in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PER_SSM_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_SSM_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_SSM_RKU;

/