--------------------------------------------------------
--  DDL for Package Body HR_ABSENCE_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ABSENCE_TYPE_BK1" as
/* $Header: peabbapi.pkb 120.2.12010000.2 2008/08/06 08:52:03 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:53 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ABSENCE_TYPE_A
(P_LANGUAGE_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_DATE_EFFECTIVE in DATE
,P_DATE_END in DATE
,P_NAME in VARCHAR2
,P_ABSENCE_CATEGORY in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_HOURS_OR_DAYS in VARCHAR2
,P_INC_OR_DEC_FLAG in VARCHAR2
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
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in VARCHAR2
,P_INFORMATION2 in VARCHAR2
,P_INFORMATION3 in VARCHAR2
,P_INFORMATION4 in VARCHAR2
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in VARCHAR2
,P_INFORMATION11 in VARCHAR2
,P_INFORMATION12 in VARCHAR2
,P_INFORMATION13 in VARCHAR2
,P_INFORMATION14 in VARCHAR2
,P_INFORMATION15 in VARCHAR2
,P_INFORMATION16 in VARCHAR2
,P_INFORMATION17 in VARCHAR2
,P_INFORMATION18 in VARCHAR2
,P_INFORMATION19 in VARCHAR2
,P_INFORMATION20 in VARCHAR2
,P_USER_ROLE in VARCHAR2
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
,P_ADVANCE_PAY in VARCHAR2
,P_ABSENCE_OVERLAP_FLAG in VARCHAR2
,P_ABSENCE_ATTENDANCE_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_ABSENCE_TYPE_BK1.CREATE_ABSENCE_TYPE_A', 10);
hr_utility.set_location(' Leaving: HR_ABSENCE_TYPE_BK1.CREATE_ABSENCE_TYPE_A', 20);
end CREATE_ABSENCE_TYPE_A;
procedure CREATE_ABSENCE_TYPE_B
(P_LANGUAGE_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_DATE_EFFECTIVE in DATE
,P_DATE_END in DATE
,P_NAME in VARCHAR2
,P_ABSENCE_CATEGORY in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_HOURS_OR_DAYS in VARCHAR2
,P_INC_OR_DEC_FLAG in VARCHAR2
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
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in VARCHAR2
,P_INFORMATION2 in VARCHAR2
,P_INFORMATION3 in VARCHAR2
,P_INFORMATION4 in VARCHAR2
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in VARCHAR2
,P_INFORMATION11 in VARCHAR2
,P_INFORMATION12 in VARCHAR2
,P_INFORMATION13 in VARCHAR2
,P_INFORMATION14 in VARCHAR2
,P_INFORMATION15 in VARCHAR2
,P_INFORMATION16 in VARCHAR2
,P_INFORMATION17 in VARCHAR2
,P_INFORMATION18 in VARCHAR2
,P_INFORMATION19 in VARCHAR2
,P_INFORMATION20 in VARCHAR2
,P_USER_ROLE in VARCHAR2
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
,P_ADVANCE_PAY in VARCHAR2
,P_ABSENCE_OVERLAP_FLAG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_ABSENCE_TYPE_BK1.CREATE_ABSENCE_TYPE_B', 10);
hr_utility.set_location(' Leaving: HR_ABSENCE_TYPE_BK1.CREATE_ABSENCE_TYPE_B', 20);
end CREATE_ABSENCE_TYPE_B;
end HR_ABSENCE_TYPE_BK1;

/
