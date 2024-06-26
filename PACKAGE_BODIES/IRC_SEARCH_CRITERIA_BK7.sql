--------------------------------------------------------
--  DDL for Package Body IRC_SEARCH_CRITERIA_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SEARCH_CRITERIA_BK7" as
/* $Header: iriscapi.pkb 120.0 2005/07/26 15:10:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:22 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_WORK_CHOICES_A
(P_EFFECTIVE_DATE in DATE
,P_SEARCH_CRITERIA_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_LOCATION in VARCHAR2
,P_DISTANCE_TO_LOCATION in VARCHAR2
,P_GEOCODE_LOCATION in VARCHAR2
,P_GEOCODE_COUNTRY in VARCHAR2
,P_DERIVED_LOCATION in VARCHAR2
,P_LOCATION_ID in NUMBER
,P_LONGITUDE in NUMBER
,P_LATITUDE in NUMBER
,P_EMPLOYEE in VARCHAR2
,P_CONTRACTOR in VARCHAR2
,P_EMPLOYMENT_CATEGORY in VARCHAR2
,P_KEYWORDS in VARCHAR2
,P_TRAVEL_PERCENTAGE in NUMBER
,P_MIN_SALARY in NUMBER
,P_SALARY_CURRENCY in VARCHAR2
,P_SALARY_PERIOD in VARCHAR2
,P_MATCH_COMPETENCE in VARCHAR2
,P_MATCH_QUALIFICATION in VARCHAR2
,P_WORK_AT_HOME in VARCHAR2
,P_JOB_TITLE in VARCHAR2
,P_DEPARTMENT in VARCHAR2
,P_PROFESSIONAL_AREA in VARCHAR2
,P_DESCRIPTION in VARCHAR2
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
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_ISC_INFORMATION_CATEGORY in VARCHAR2
,P_ISC_INFORMATION1 in VARCHAR2
,P_ISC_INFORMATION2 in VARCHAR2
,P_ISC_INFORMATION3 in VARCHAR2
,P_ISC_INFORMATION4 in VARCHAR2
,P_ISC_INFORMATION5 in VARCHAR2
,P_ISC_INFORMATION6 in VARCHAR2
,P_ISC_INFORMATION7 in VARCHAR2
,P_ISC_INFORMATION8 in VARCHAR2
,P_ISC_INFORMATION9 in VARCHAR2
,P_ISC_INFORMATION10 in VARCHAR2
,P_ISC_INFORMATION11 in VARCHAR2
,P_ISC_INFORMATION12 in VARCHAR2
,P_ISC_INFORMATION13 in VARCHAR2
,P_ISC_INFORMATION14 in VARCHAR2
,P_ISC_INFORMATION15 in VARCHAR2
,P_ISC_INFORMATION16 in VARCHAR2
,P_ISC_INFORMATION17 in VARCHAR2
,P_ISC_INFORMATION18 in VARCHAR2
,P_ISC_INFORMATION19 in VARCHAR2
,P_ISC_INFORMATION20 in VARCHAR2
,P_ISC_INFORMATION21 in VARCHAR2
,P_ISC_INFORMATION22 in VARCHAR2
,P_ISC_INFORMATION23 in VARCHAR2
,P_ISC_INFORMATION24 in VARCHAR2
,P_ISC_INFORMATION25 in VARCHAR2
,P_ISC_INFORMATION26 in VARCHAR2
,P_ISC_INFORMATION27 in VARCHAR2
,P_ISC_INFORMATION28 in VARCHAR2
,P_ISC_INFORMATION29 in VARCHAR2
,P_ISC_INFORMATION30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_SEARCH_CRITERIA_BK7.CREATE_WORK_CHOICES_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_search_criteria_be7.CREATE_WORK_CHOICES_A
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_SEARCH_CRITERIA_ID => P_SEARCH_CRITERIA_ID
,P_PERSON_ID => P_PERSON_ID
,P_LOCATION => P_LOCATION
,P_DISTANCE_TO_LOCATION => P_DISTANCE_TO_LOCATION
,P_GEOCODE_LOCATION => P_GEOCODE_LOCATION
,P_GEOCODE_COUNTRY => P_GEOCODE_COUNTRY
,P_DERIVED_LOCATION => P_DERIVED_LOCATION
,P_LOCATION_ID => P_LOCATION_ID
,P_LONGITUDE => P_LONGITUDE
,P_LATITUDE => P_LATITUDE
,P_EMPLOYEE => P_EMPLOYEE
,P_CONTRACTOR => P_CONTRACTOR
,P_EMPLOYMENT_CATEGORY => P_EMPLOYMENT_CATEGORY
,P_KEYWORDS => P_KEYWORDS
,P_TRAVEL_PERCENTAGE => P_TRAVEL_PERCENTAGE
,P_MIN_SALARY => P_MIN_SALARY
,P_SALARY_CURRENCY => P_SALARY_CURRENCY
,P_SALARY_PERIOD => P_SALARY_PERIOD
,P_MATCH_COMPETENCE => P_MATCH_COMPETENCE
,P_MATCH_QUALIFICATION => P_MATCH_QUALIFICATION
,P_WORK_AT_HOME => P_WORK_AT_HOME
,P_JOB_TITLE => P_JOB_TITLE
,P_DEPARTMENT => P_DEPARTMENT
,P_PROFESSIONAL_AREA => P_PROFESSIONAL_AREA
,P_DESCRIPTION => P_DESCRIPTION
,P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY
,P_ATTRIBUTE1 => P_ATTRIBUTE1
,P_ATTRIBUTE2 => P_ATTRIBUTE2
,P_ATTRIBUTE3 => P_ATTRIBUTE3
,P_ATTRIBUTE4 => P_ATTRIBUTE4
,P_ATTRIBUTE5 => P_ATTRIBUTE5
,P_ATTRIBUTE6 => P_ATTRIBUTE6
,P_ATTRIBUTE7 => P_ATTRIBUTE7
,P_ATTRIBUTE8 => P_ATTRIBUTE8
,P_ATTRIBUTE9 => P_ATTRIBUTE9
,P_ATTRIBUTE10 => P_ATTRIBUTE10
,P_ATTRIBUTE11 => P_ATTRIBUTE11
,P_ATTRIBUTE12 => P_ATTRIBUTE12
,P_ATTRIBUTE13 => P_ATTRIBUTE13
,P_ATTRIBUTE14 => P_ATTRIBUTE14
,P_ATTRIBUTE15 => P_ATTRIBUTE15
,P_ATTRIBUTE16 => P_ATTRIBUTE16
,P_ATTRIBUTE17 => P_ATTRIBUTE17
,P_ATTRIBUTE18 => P_ATTRIBUTE18
,P_ATTRIBUTE19 => P_ATTRIBUTE19
,P_ATTRIBUTE20 => P_ATTRIBUTE20
,P_ATTRIBUTE21 => P_ATTRIBUTE21
,P_ATTRIBUTE22 => P_ATTRIBUTE22
,P_ATTRIBUTE23 => P_ATTRIBUTE23
,P_ATTRIBUTE24 => P_ATTRIBUTE24
,P_ATTRIBUTE25 => P_ATTRIBUTE25
,P_ATTRIBUTE26 => P_ATTRIBUTE26
,P_ATTRIBUTE27 => P_ATTRIBUTE27
,P_ATTRIBUTE28 => P_ATTRIBUTE28
,P_ATTRIBUTE29 => P_ATTRIBUTE29
,P_ATTRIBUTE30 => P_ATTRIBUTE30
,P_ISC_INFORMATION_CATEGORY => P_ISC_INFORMATION_CATEGORY
,P_ISC_INFORMATION1 => P_ISC_INFORMATION1
,P_ISC_INFORMATION2 => P_ISC_INFORMATION2
,P_ISC_INFORMATION3 => P_ISC_INFORMATION3
,P_ISC_INFORMATION4 => P_ISC_INFORMATION4
,P_ISC_INFORMATION5 => P_ISC_INFORMATION5
,P_ISC_INFORMATION6 => P_ISC_INFORMATION6
,P_ISC_INFORMATION7 => P_ISC_INFORMATION7
,P_ISC_INFORMATION8 => P_ISC_INFORMATION8
,P_ISC_INFORMATION9 => P_ISC_INFORMATION9
,P_ISC_INFORMATION10 => P_ISC_INFORMATION10
,P_ISC_INFORMATION11 => P_ISC_INFORMATION11
,P_ISC_INFORMATION12 => P_ISC_INFORMATION12
,P_ISC_INFORMATION13 => P_ISC_INFORMATION13
,P_ISC_INFORMATION14 => P_ISC_INFORMATION14
,P_ISC_INFORMATION15 => P_ISC_INFORMATION15
,P_ISC_INFORMATION16 => P_ISC_INFORMATION16
,P_ISC_INFORMATION17 => P_ISC_INFORMATION17
,P_ISC_INFORMATION18 => P_ISC_INFORMATION18
,P_ISC_INFORMATION19 => P_ISC_INFORMATION19
,P_ISC_INFORMATION20 => P_ISC_INFORMATION20
,P_ISC_INFORMATION21 => P_ISC_INFORMATION21
,P_ISC_INFORMATION22 => P_ISC_INFORMATION22
,P_ISC_INFORMATION23 => P_ISC_INFORMATION23
,P_ISC_INFORMATION24 => P_ISC_INFORMATION24
,P_ISC_INFORMATION25 => P_ISC_INFORMATION25
,P_ISC_INFORMATION26 => P_ISC_INFORMATION26
,P_ISC_INFORMATION27 => P_ISC_INFORMATION27
,P_ISC_INFORMATION28 => P_ISC_INFORMATION28
,P_ISC_INFORMATION29 => P_ISC_INFORMATION29
,P_ISC_INFORMATION30 => P_ISC_INFORMATION30
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_WORK_CHOICES', 'AP');
hr_utility.set_location(' Leaving: IRC_SEARCH_CRITERIA_BK7.CREATE_WORK_CHOICES_A', 20);
end CREATE_WORK_CHOICES_A;
procedure CREATE_WORK_CHOICES_B
(P_EFFECTIVE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_LOCATION in VARCHAR2
,P_DISTANCE_TO_LOCATION in VARCHAR2
,P_GEOCODE_LOCATION in VARCHAR2
,P_GEOCODE_COUNTRY in VARCHAR2
,P_DERIVED_LOCATION in VARCHAR2
,P_LOCATION_ID in NUMBER
,P_LONGITUDE in NUMBER
,P_LATITUDE in NUMBER
,P_EMPLOYEE in VARCHAR2
,P_CONTRACTOR in VARCHAR2
,P_EMPLOYMENT_CATEGORY in VARCHAR2
,P_KEYWORDS in VARCHAR2
,P_TRAVEL_PERCENTAGE in NUMBER
,P_MIN_SALARY in NUMBER
,P_SALARY_CURRENCY in VARCHAR2
,P_SALARY_PERIOD in VARCHAR2
,P_MATCH_COMPETENCE in VARCHAR2
,P_MATCH_QUALIFICATION in VARCHAR2
,P_WORK_AT_HOME in VARCHAR2
,P_JOB_TITLE in VARCHAR2
,P_DEPARTMENT in VARCHAR2
,P_PROFESSIONAL_AREA in VARCHAR2
,P_DESCRIPTION in VARCHAR2
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
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_ISC_INFORMATION_CATEGORY in VARCHAR2
,P_ISC_INFORMATION1 in VARCHAR2
,P_ISC_INFORMATION2 in VARCHAR2
,P_ISC_INFORMATION3 in VARCHAR2
,P_ISC_INFORMATION4 in VARCHAR2
,P_ISC_INFORMATION5 in VARCHAR2
,P_ISC_INFORMATION6 in VARCHAR2
,P_ISC_INFORMATION7 in VARCHAR2
,P_ISC_INFORMATION8 in VARCHAR2
,P_ISC_INFORMATION9 in VARCHAR2
,P_ISC_INFORMATION10 in VARCHAR2
,P_ISC_INFORMATION11 in VARCHAR2
,P_ISC_INFORMATION12 in VARCHAR2
,P_ISC_INFORMATION13 in VARCHAR2
,P_ISC_INFORMATION14 in VARCHAR2
,P_ISC_INFORMATION15 in VARCHAR2
,P_ISC_INFORMATION16 in VARCHAR2
,P_ISC_INFORMATION17 in VARCHAR2
,P_ISC_INFORMATION18 in VARCHAR2
,P_ISC_INFORMATION19 in VARCHAR2
,P_ISC_INFORMATION20 in VARCHAR2
,P_ISC_INFORMATION21 in VARCHAR2
,P_ISC_INFORMATION22 in VARCHAR2
,P_ISC_INFORMATION23 in VARCHAR2
,P_ISC_INFORMATION24 in VARCHAR2
,P_ISC_INFORMATION25 in VARCHAR2
,P_ISC_INFORMATION26 in VARCHAR2
,P_ISC_INFORMATION27 in VARCHAR2
,P_ISC_INFORMATION28 in VARCHAR2
,P_ISC_INFORMATION29 in VARCHAR2
,P_ISC_INFORMATION30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: IRC_SEARCH_CRITERIA_BK7.CREATE_WORK_CHOICES_B', 10);
hr_utility.set_location(' Leaving: IRC_SEARCH_CRITERIA_BK7.CREATE_WORK_CHOICES_B', 20);
end CREATE_WORK_CHOICES_B;
end IRC_SEARCH_CRITERIA_BK7;

/
