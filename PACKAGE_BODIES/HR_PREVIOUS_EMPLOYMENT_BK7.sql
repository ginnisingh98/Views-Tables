--------------------------------------------------------
--  DDL for Package Body HR_PREVIOUS_EMPLOYMENT_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PREVIOUS_EMPLOYMENT_BK7" as
/* $Header: pepemapi.pkb 120.0.12010000.2 2008/08/06 09:21:29 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:58 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_PREVIOUS_JOB_USAGE_A
(P_ASSIGNMENT_ID in NUMBER
,P_PREVIOUS_EMPLOYER_ID in NUMBER
,P_PREVIOUS_JOB_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_PERIOD_YEARS in NUMBER
,P_PERIOD_MONTHS in NUMBER
,P_PERIOD_DAYS in NUMBER
,P_PJU_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PJU_ATTRIBUTE1 in VARCHAR2
,P_PJU_ATTRIBUTE2 in VARCHAR2
,P_PJU_ATTRIBUTE3 in VARCHAR2
,P_PJU_ATTRIBUTE4 in VARCHAR2
,P_PJU_ATTRIBUTE5 in VARCHAR2
,P_PJU_ATTRIBUTE6 in VARCHAR2
,P_PJU_ATTRIBUTE7 in VARCHAR2
,P_PJU_ATTRIBUTE8 in VARCHAR2
,P_PJU_ATTRIBUTE9 in VARCHAR2
,P_PJU_ATTRIBUTE10 in VARCHAR2
,P_PJU_ATTRIBUTE11 in VARCHAR2
,P_PJU_ATTRIBUTE12 in VARCHAR2
,P_PJU_ATTRIBUTE13 in VARCHAR2
,P_PJU_ATTRIBUTE14 in VARCHAR2
,P_PJU_ATTRIBUTE15 in VARCHAR2
,P_PJU_ATTRIBUTE16 in VARCHAR2
,P_PJU_ATTRIBUTE17 in VARCHAR2
,P_PJU_ATTRIBUTE18 in VARCHAR2
,P_PJU_ATTRIBUTE19 in VARCHAR2
,P_PJU_ATTRIBUTE20 in VARCHAR2
,P_PJU_INFORMATION_CATEGORY in VARCHAR2
,P_PJU_INFORMATION1 in VARCHAR2
,P_PJU_INFORMATION2 in VARCHAR2
,P_PJU_INFORMATION3 in VARCHAR2
,P_PJU_INFORMATION4 in VARCHAR2
,P_PJU_INFORMATION5 in VARCHAR2
,P_PJU_INFORMATION6 in VARCHAR2
,P_PJU_INFORMATION7 in VARCHAR2
,P_PJU_INFORMATION8 in VARCHAR2
,P_PJU_INFORMATION9 in VARCHAR2
,P_PJU_INFORMATION10 in VARCHAR2
,P_PJU_INFORMATION11 in VARCHAR2
,P_PJU_INFORMATION12 in VARCHAR2
,P_PJU_INFORMATION13 in VARCHAR2
,P_PJU_INFORMATION14 in VARCHAR2
,P_PJU_INFORMATION15 in VARCHAR2
,P_PJU_INFORMATION16 in VARCHAR2
,P_PJU_INFORMATION17 in VARCHAR2
,P_PJU_INFORMATION18 in VARCHAR2
,P_PJU_INFORMATION19 in VARCHAR2
,P_PJU_INFORMATION20 in VARCHAR2
,P_PREVIOUS_JOB_USAGE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_PREVIOUS_EMPLOYMENT_BK7.CREATE_PREVIOUS_JOB_USAGE_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
hr_previous_employment_be7.CREATE_PREVIOUS_JOB_USAGE_A
(P_ASSIGNMENT_ID => P_ASSIGNMENT_ID
,P_PREVIOUS_EMPLOYER_ID => P_PREVIOUS_EMPLOYER_ID
,P_PREVIOUS_JOB_ID => P_PREVIOUS_JOB_ID
,P_START_DATE => P_START_DATE
,P_END_DATE => P_END_DATE
,P_PERIOD_YEARS => P_PERIOD_YEARS
,P_PERIOD_MONTHS => P_PERIOD_MONTHS
,P_PERIOD_DAYS => P_PERIOD_DAYS
,P_PJU_ATTRIBUTE_CATEGORY => P_PJU_ATTRIBUTE_CATEGORY
,P_PJU_ATTRIBUTE1 => P_PJU_ATTRIBUTE1
,P_PJU_ATTRIBUTE2 => P_PJU_ATTRIBUTE2
,P_PJU_ATTRIBUTE3 => P_PJU_ATTRIBUTE3
,P_PJU_ATTRIBUTE4 => P_PJU_ATTRIBUTE4
,P_PJU_ATTRIBUTE5 => P_PJU_ATTRIBUTE5
,P_PJU_ATTRIBUTE6 => P_PJU_ATTRIBUTE6
,P_PJU_ATTRIBUTE7 => P_PJU_ATTRIBUTE7
,P_PJU_ATTRIBUTE8 => P_PJU_ATTRIBUTE8
,P_PJU_ATTRIBUTE9 => P_PJU_ATTRIBUTE9
,P_PJU_ATTRIBUTE10 => P_PJU_ATTRIBUTE10
,P_PJU_ATTRIBUTE11 => P_PJU_ATTRIBUTE11
,P_PJU_ATTRIBUTE12 => P_PJU_ATTRIBUTE12
,P_PJU_ATTRIBUTE13 => P_PJU_ATTRIBUTE13
,P_PJU_ATTRIBUTE14 => P_PJU_ATTRIBUTE14
,P_PJU_ATTRIBUTE15 => P_PJU_ATTRIBUTE15
,P_PJU_ATTRIBUTE16 => P_PJU_ATTRIBUTE16
,P_PJU_ATTRIBUTE17 => P_PJU_ATTRIBUTE17
,P_PJU_ATTRIBUTE18 => P_PJU_ATTRIBUTE18
,P_PJU_ATTRIBUTE19 => P_PJU_ATTRIBUTE19
,P_PJU_ATTRIBUTE20 => P_PJU_ATTRIBUTE20
,P_PJU_INFORMATION_CATEGORY => P_PJU_INFORMATION_CATEGORY
,P_PJU_INFORMATION1 => P_PJU_INFORMATION1
,P_PJU_INFORMATION2 => P_PJU_INFORMATION2
,P_PJU_INFORMATION3 => P_PJU_INFORMATION3
,P_PJU_INFORMATION4 => P_PJU_INFORMATION4
,P_PJU_INFORMATION5 => P_PJU_INFORMATION5
,P_PJU_INFORMATION6 => P_PJU_INFORMATION6
,P_PJU_INFORMATION7 => P_PJU_INFORMATION7
,P_PJU_INFORMATION8 => P_PJU_INFORMATION8
,P_PJU_INFORMATION9 => P_PJU_INFORMATION9
,P_PJU_INFORMATION10 => P_PJU_INFORMATION10
,P_PJU_INFORMATION11 => P_PJU_INFORMATION11
,P_PJU_INFORMATION12 => P_PJU_INFORMATION12
,P_PJU_INFORMATION13 => P_PJU_INFORMATION13
,P_PJU_INFORMATION14 => P_PJU_INFORMATION14
,P_PJU_INFORMATION15 => P_PJU_INFORMATION15
,P_PJU_INFORMATION16 => P_PJU_INFORMATION16
,P_PJU_INFORMATION17 => P_PJU_INFORMATION17
,P_PJU_INFORMATION18 => P_PJU_INFORMATION18
,P_PJU_INFORMATION19 => P_PJU_INFORMATION19
,P_PJU_INFORMATION20 => P_PJU_INFORMATION20
,P_PREVIOUS_JOB_USAGE_ID => P_PREVIOUS_JOB_USAGE_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_PREVIOUS_JOB_USAGE', 'AP');
hr_utility.set_location(' Leaving: HR_PREVIOUS_EMPLOYMENT_BK7.CREATE_PREVIOUS_JOB_USAGE_A', 20);
end CREATE_PREVIOUS_JOB_USAGE_A;
procedure CREATE_PREVIOUS_JOB_USAGE_B
(P_ASSIGNMENT_ID in NUMBER
,P_PREVIOUS_EMPLOYER_ID in NUMBER
,P_PREVIOUS_JOB_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_PERIOD_YEARS in NUMBER
,P_PERIOD_MONTHS in NUMBER
,P_PERIOD_DAYS in NUMBER
,P_PJU_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PJU_ATTRIBUTE1 in VARCHAR2
,P_PJU_ATTRIBUTE2 in VARCHAR2
,P_PJU_ATTRIBUTE3 in VARCHAR2
,P_PJU_ATTRIBUTE4 in VARCHAR2
,P_PJU_ATTRIBUTE5 in VARCHAR2
,P_PJU_ATTRIBUTE6 in VARCHAR2
,P_PJU_ATTRIBUTE7 in VARCHAR2
,P_PJU_ATTRIBUTE8 in VARCHAR2
,P_PJU_ATTRIBUTE9 in VARCHAR2
,P_PJU_ATTRIBUTE10 in VARCHAR2
,P_PJU_ATTRIBUTE11 in VARCHAR2
,P_PJU_ATTRIBUTE12 in VARCHAR2
,P_PJU_ATTRIBUTE13 in VARCHAR2
,P_PJU_ATTRIBUTE14 in VARCHAR2
,P_PJU_ATTRIBUTE15 in VARCHAR2
,P_PJU_ATTRIBUTE16 in VARCHAR2
,P_PJU_ATTRIBUTE17 in VARCHAR2
,P_PJU_ATTRIBUTE18 in VARCHAR2
,P_PJU_ATTRIBUTE19 in VARCHAR2
,P_PJU_ATTRIBUTE20 in VARCHAR2
,P_PJU_INFORMATION_CATEGORY in VARCHAR2
,P_PJU_INFORMATION1 in VARCHAR2
,P_PJU_INFORMATION2 in VARCHAR2
,P_PJU_INFORMATION3 in VARCHAR2
,P_PJU_INFORMATION4 in VARCHAR2
,P_PJU_INFORMATION5 in VARCHAR2
,P_PJU_INFORMATION6 in VARCHAR2
,P_PJU_INFORMATION7 in VARCHAR2
,P_PJU_INFORMATION8 in VARCHAR2
,P_PJU_INFORMATION9 in VARCHAR2
,P_PJU_INFORMATION10 in VARCHAR2
,P_PJU_INFORMATION11 in VARCHAR2
,P_PJU_INFORMATION12 in VARCHAR2
,P_PJU_INFORMATION13 in VARCHAR2
,P_PJU_INFORMATION14 in VARCHAR2
,P_PJU_INFORMATION15 in VARCHAR2
,P_PJU_INFORMATION16 in VARCHAR2
,P_PJU_INFORMATION17 in VARCHAR2
,P_PJU_INFORMATION18 in VARCHAR2
,P_PJU_INFORMATION19 in VARCHAR2
,P_PJU_INFORMATION20 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_PREVIOUS_EMPLOYMENT_BK7.CREATE_PREVIOUS_JOB_USAGE_B', 10);
hr_utility.set_location(' Leaving: HR_PREVIOUS_EMPLOYMENT_BK7.CREATE_PREVIOUS_JOB_USAGE_B', 20);
end CREATE_PREVIOUS_JOB_USAGE_B;
end HR_PREVIOUS_EMPLOYMENT_BK7;

/
