--------------------------------------------------------
--  DDL for Package Body PER_ROL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ROL_RKD" as
/* $Header: perolrhi.pkb 120.0 2005/05/31 18:34:51 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:10 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ROLE_ID in NUMBER
,P_JOB_ID_O in NUMBER
,P_JOB_GROUP_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_ORGANIZATION_ID_O in NUMBER
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_CONFIDENTIAL_DATE_O in DATE
,P_EMP_RIGHTS_FLAG_O in VARCHAR2
,P_END_OF_RIGHTS_DATE_O in DATE
,P_PRIMARY_CONTACT_FLAG_O in VARCHAR2
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
,P_ROLE_INFORMATION_CATEGORY_O in VARCHAR2
,P_ROLE_INFORMATION1_O in VARCHAR2
,P_ROLE_INFORMATION2_O in VARCHAR2
,P_ROLE_INFORMATION3_O in VARCHAR2
,P_ROLE_INFORMATION4_O in VARCHAR2
,P_ROLE_INFORMATION5_O in VARCHAR2
,P_ROLE_INFORMATION6_O in VARCHAR2
,P_ROLE_INFORMATION7_O in VARCHAR2
,P_ROLE_INFORMATION8_O in VARCHAR2
,P_ROLE_INFORMATION9_O in VARCHAR2
,P_ROLE_INFORMATION10_O in VARCHAR2
,P_ROLE_INFORMATION11_O in VARCHAR2
,P_ROLE_INFORMATION12_O in VARCHAR2
,P_ROLE_INFORMATION13_O in VARCHAR2
,P_ROLE_INFORMATION14_O in VARCHAR2
,P_ROLE_INFORMATION15_O in VARCHAR2
,P_ROLE_INFORMATION16_O in VARCHAR2
,P_ROLE_INFORMATION17_O in VARCHAR2
,P_ROLE_INFORMATION18_O in VARCHAR2
,P_ROLE_INFORMATION19_O in VARCHAR2
,P_ROLE_INFORMATION20_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_ROL_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_ROL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_ROL_RKD;

/
