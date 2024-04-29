--------------------------------------------------------
--  DDL for Package Body PER_ABS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABS_RKU" as
/* $Header: peabsrhi.pkb 120.17.12010000.9 2010/03/23 06:49:45 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:15 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_ABSENCE_ATTENDANCE_ID in NUMBER
,P_ABSENCE_ATTENDANCE_TYPE_ID in NUMBER
,P_ABS_ATTENDANCE_REASON_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_AUTHORISING_PERSON_ID in NUMBER
,P_REPLACEMENT_PERSON_ID in NUMBER
,P_PERIOD_OF_INCAPACITY_ID in NUMBER
,P_ABSENCE_DAYS in NUMBER
,P_ABSENCE_HOURS in NUMBER
,P_COMMENTS in VARCHAR2
,P_DATE_END in DATE
,P_DATE_NOTIFICATION in DATE
,P_DATE_PROJECTED_END in DATE
,P_DATE_PROJECTED_START in DATE
,P_DATE_START in DATE
,P_OCCURRENCE in NUMBER
,P_SSP1_ISSUED in VARCHAR2
,P_TIME_END in VARCHAR2
,P_TIME_PROJECTED_END in VARCHAR2
,P_TIME_PROJECTED_START in VARCHAR2
,P_TIME_START in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
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
,P_MATERNITY_ID in NUMBER
,P_SICKNESS_START_DATE in DATE
,P_SICKNESS_END_DATE in DATE
,P_PREGNANCY_RELATED_ILLNESS in VARCHAR2
,P_REASON_FOR_NOTIFICATION_DELA in VARCHAR2
,P_ACCEPT_LATE_NOTIFICATION_FLA in VARCHAR2
,P_LINKED_ABSENCE_ID in NUMBER
,P_ABS_INFORMATION_CATEGORY in VARCHAR2
,P_ABS_INFORMATION1 in VARCHAR2
,P_ABS_INFORMATION2 in VARCHAR2
,P_ABS_INFORMATION3 in VARCHAR2
,P_ABS_INFORMATION4 in VARCHAR2
,P_ABS_INFORMATION5 in VARCHAR2
,P_ABS_INFORMATION6 in VARCHAR2
,P_ABS_INFORMATION7 in VARCHAR2
,P_ABS_INFORMATION8 in VARCHAR2
,P_ABS_INFORMATION9 in VARCHAR2
,P_ABS_INFORMATION10 in VARCHAR2
,P_ABS_INFORMATION11 in VARCHAR2
,P_ABS_INFORMATION12 in VARCHAR2
,P_ABS_INFORMATION13 in VARCHAR2
,P_ABS_INFORMATION14 in VARCHAR2
,P_ABS_INFORMATION15 in VARCHAR2
,P_ABS_INFORMATION16 in VARCHAR2
,P_ABS_INFORMATION17 in VARCHAR2
,P_ABS_INFORMATION18 in VARCHAR2
,P_ABS_INFORMATION19 in VARCHAR2
,P_ABS_INFORMATION20 in VARCHAR2
,P_ABS_INFORMATION21 in VARCHAR2
,P_ABS_INFORMATION22 in VARCHAR2
,P_ABS_INFORMATION23 in VARCHAR2
,P_ABS_INFORMATION24 in VARCHAR2
,P_ABS_INFORMATION25 in VARCHAR2
,P_ABS_INFORMATION26 in VARCHAR2
,P_ABS_INFORMATION27 in VARCHAR2
,P_ABS_INFORMATION28 in VARCHAR2
,P_ABS_INFORMATION29 in VARCHAR2
,P_ABS_INFORMATION30 in VARCHAR2
,P_ABSENCE_CASE_ID in NUMBER
,P_BATCH_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ABSENCE_ATTENDANCE_TYPE_ID_O in NUMBER
,P_ABS_ATTENDANCE_REASON_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_AUTHORISING_PERSON_ID_O in NUMBER
,P_REPLACEMENT_PERSON_ID_O in NUMBER
,P_PERIOD_OF_INCAPACITY_ID_O in NUMBER
,P_ABSENCE_DAYS_O in NUMBER
,P_ABSENCE_HOURS_O in NUMBER
,P_COMMENTS_O in VARCHAR2
,P_DATE_END_O in DATE
,P_DATE_NOTIFICATION_O in DATE
,P_DATE_PROJECTED_END_O in DATE
,P_DATE_PROJECTED_START_O in DATE
,P_DATE_START_O in DATE
,P_OCCURRENCE_O in NUMBER
,P_SSP1_ISSUED_O in VARCHAR2
,P_TIME_END_O in VARCHAR2
,P_TIME_PROJECTED_END_O in VARCHAR2
,P_TIME_PROJECTED_START_O in VARCHAR2
,P_TIME_START_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
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
,P_MATERNITY_ID_O in NUMBER
,P_SICKNESS_START_DATE_O in DATE
,P_SICKNESS_END_DATE_O in DATE
,P_PREGNANCY_RELATED_ILLNESS_O in VARCHAR2
,P_REASON_FOR_NOTIFICATION_DE_O in VARCHAR2
,P_ACCEPT_LATE_NOTIFICATION_F_O in VARCHAR2
,P_LINKED_ABSENCE_ID_O in NUMBER
,P_ABS_INFORMATION_CATEGORY_O in VARCHAR2
,P_ABS_INFORMATION1_O in VARCHAR2
,P_ABS_INFORMATION2_O in VARCHAR2
,P_ABS_INFORMATION3_O in VARCHAR2
,P_ABS_INFORMATION4_O in VARCHAR2
,P_ABS_INFORMATION5_O in VARCHAR2
,P_ABS_INFORMATION6_O in VARCHAR2
,P_ABS_INFORMATION7_O in VARCHAR2
,P_ABS_INFORMATION8_O in VARCHAR2
,P_ABS_INFORMATION9_O in VARCHAR2
,P_ABS_INFORMATION10_O in VARCHAR2
,P_ABS_INFORMATION11_O in VARCHAR2
,P_ABS_INFORMATION12_O in VARCHAR2
,P_ABS_INFORMATION13_O in VARCHAR2
,P_ABS_INFORMATION14_O in VARCHAR2
,P_ABS_INFORMATION15_O in VARCHAR2
,P_ABS_INFORMATION16_O in VARCHAR2
,P_ABS_INFORMATION17_O in VARCHAR2
,P_ABS_INFORMATION18_O in VARCHAR2
,P_ABS_INFORMATION19_O in VARCHAR2
,P_ABS_INFORMATION20_O in VARCHAR2
,P_ABS_INFORMATION21_O in VARCHAR2
,P_ABS_INFORMATION22_O in VARCHAR2
,P_ABS_INFORMATION23_O in VARCHAR2
,P_ABS_INFORMATION24_O in VARCHAR2
,P_ABS_INFORMATION25_O in VARCHAR2
,P_ABS_INFORMATION26_O in VARCHAR2
,P_ABS_INFORMATION27_O in VARCHAR2
,P_ABS_INFORMATION28_O in VARCHAR2
,P_ABS_INFORMATION29_O in VARCHAR2
,P_ABS_INFORMATION30_O in VARCHAR2
,P_ABSENCE_CASE_ID_O in NUMBER
,P_BATCH_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_ABS_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_ABS_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_ABS_RKU;

/