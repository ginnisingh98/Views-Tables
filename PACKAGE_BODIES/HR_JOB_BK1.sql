--------------------------------------------------------
--  DDL for Package Body HR_JOB_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JOB_BK1" as
/* $Header: pejobapi.pkb 120.0.12010000.1 2008/07/28 04:55:26 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:55 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_JOB_A
(P_BUSINESS_GROUP_ID in NUMBER
,P_DATE_FROM in DATE
,P_COMMENTS in VARCHAR2
,P_DATE_TO in DATE
,P_APPROVAL_AUTHORITY in NUMBER
,P_BENCHMARK_JOB_FLAG in VARCHAR2
,P_BENCHMARK_JOB_ID in NUMBER
,P_EMP_RIGHTS_FLAG in VARCHAR2
,P_JOB_GROUP_ID in NUMBER
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
,P_JOB_INFORMATION_CATEGORY in VARCHAR2
,P_JOB_INFORMATION1 in VARCHAR2
,P_JOB_INFORMATION2 in VARCHAR2
,P_JOB_INFORMATION3 in VARCHAR2
,P_JOB_INFORMATION4 in VARCHAR2
,P_JOB_INFORMATION5 in VARCHAR2
,P_JOB_INFORMATION6 in VARCHAR2
,P_JOB_INFORMATION7 in VARCHAR2
,P_JOB_INFORMATION8 in VARCHAR2
,P_JOB_INFORMATION9 in VARCHAR2
,P_JOB_INFORMATION10 in VARCHAR2
,P_JOB_INFORMATION11 in VARCHAR2
,P_JOB_INFORMATION12 in VARCHAR2
,P_JOB_INFORMATION13 in VARCHAR2
,P_JOB_INFORMATION14 in VARCHAR2
,P_JOB_INFORMATION15 in VARCHAR2
,P_JOB_INFORMATION16 in VARCHAR2
,P_JOB_INFORMATION17 in VARCHAR2
,P_JOB_INFORMATION18 in VARCHAR2
,P_JOB_INFORMATION19 in VARCHAR2
,P_JOB_INFORMATION20 in VARCHAR2
,P_SEGMENT1 in VARCHAR2
,P_SEGMENT2 in VARCHAR2
,P_SEGMENT3 in VARCHAR2
,P_SEGMENT4 in VARCHAR2
,P_SEGMENT5 in VARCHAR2
,P_SEGMENT6 in VARCHAR2
,P_SEGMENT7 in VARCHAR2
,P_SEGMENT8 in VARCHAR2
,P_SEGMENT9 in VARCHAR2
,P_SEGMENT10 in VARCHAR2
,P_SEGMENT11 in VARCHAR2
,P_SEGMENT12 in VARCHAR2
,P_SEGMENT13 in VARCHAR2
,P_SEGMENT14 in VARCHAR2
,P_SEGMENT15 in VARCHAR2
,P_SEGMENT16 in VARCHAR2
,P_SEGMENT17 in VARCHAR2
,P_SEGMENT18 in VARCHAR2
,P_SEGMENT19 in VARCHAR2
,P_SEGMENT20 in VARCHAR2
,P_SEGMENT21 in VARCHAR2
,P_SEGMENT22 in VARCHAR2
,P_SEGMENT23 in VARCHAR2
,P_SEGMENT24 in VARCHAR2
,P_SEGMENT25 in VARCHAR2
,P_SEGMENT26 in VARCHAR2
,P_SEGMENT27 in VARCHAR2
,P_SEGMENT28 in VARCHAR2
,P_SEGMENT29 in VARCHAR2
,P_SEGMENT30 in VARCHAR2
,P_CONCAT_SEGMENTS in VARCHAR2
,P_JOB_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_JOB_DEFINITION_ID in NUMBER
,P_NAME in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_JOB_BK1.CREATE_JOB_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
hr_job_be1.CREATE_JOB_A
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_DATE_FROM => P_DATE_FROM
,P_COMMENTS => P_COMMENTS
,P_DATE_TO => P_DATE_TO
,P_APPROVAL_AUTHORITY => P_APPROVAL_AUTHORITY
,P_BENCHMARK_JOB_FLAG => P_BENCHMARK_JOB_FLAG
,P_BENCHMARK_JOB_ID => P_BENCHMARK_JOB_ID
,P_EMP_RIGHTS_FLAG => P_EMP_RIGHTS_FLAG
,P_JOB_GROUP_ID => P_JOB_GROUP_ID
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
,P_JOB_INFORMATION_CATEGORY => P_JOB_INFORMATION_CATEGORY
,P_JOB_INFORMATION1 => P_JOB_INFORMATION1
,P_JOB_INFORMATION2 => P_JOB_INFORMATION2
,P_JOB_INFORMATION3 => P_JOB_INFORMATION3
,P_JOB_INFORMATION4 => P_JOB_INFORMATION4
,P_JOB_INFORMATION5 => P_JOB_INFORMATION5
,P_JOB_INFORMATION6 => P_JOB_INFORMATION6
,P_JOB_INFORMATION7 => P_JOB_INFORMATION7
,P_JOB_INFORMATION8 => P_JOB_INFORMATION8
,P_JOB_INFORMATION9 => P_JOB_INFORMATION9
,P_JOB_INFORMATION10 => P_JOB_INFORMATION10
,P_JOB_INFORMATION11 => P_JOB_INFORMATION11
,P_JOB_INFORMATION12 => P_JOB_INFORMATION12
,P_JOB_INFORMATION13 => P_JOB_INFORMATION13
,P_JOB_INFORMATION14 => P_JOB_INFORMATION14
,P_JOB_INFORMATION15 => P_JOB_INFORMATION15
,P_JOB_INFORMATION16 => P_JOB_INFORMATION16
,P_JOB_INFORMATION17 => P_JOB_INFORMATION17
,P_JOB_INFORMATION18 => P_JOB_INFORMATION18
,P_JOB_INFORMATION19 => P_JOB_INFORMATION19
,P_JOB_INFORMATION20 => P_JOB_INFORMATION20
,P_SEGMENT1 => P_SEGMENT1
,P_SEGMENT2 => P_SEGMENT2
,P_SEGMENT3 => P_SEGMENT3
,P_SEGMENT4 => P_SEGMENT4
,P_SEGMENT5 => P_SEGMENT5
,P_SEGMENT6 => P_SEGMENT6
,P_SEGMENT7 => P_SEGMENT7
,P_SEGMENT8 => P_SEGMENT8
,P_SEGMENT9 => P_SEGMENT9
,P_SEGMENT10 => P_SEGMENT10
,P_SEGMENT11 => P_SEGMENT11
,P_SEGMENT12 => P_SEGMENT12
,P_SEGMENT13 => P_SEGMENT13
,P_SEGMENT14 => P_SEGMENT14
,P_SEGMENT15 => P_SEGMENT15
,P_SEGMENT16 => P_SEGMENT16
,P_SEGMENT17 => P_SEGMENT17
,P_SEGMENT18 => P_SEGMENT18
,P_SEGMENT19 => P_SEGMENT19
,P_SEGMENT20 => P_SEGMENT20
,P_SEGMENT21 => P_SEGMENT21
,P_SEGMENT22 => P_SEGMENT22
,P_SEGMENT23 => P_SEGMENT23
,P_SEGMENT24 => P_SEGMENT24
,P_SEGMENT25 => P_SEGMENT25
,P_SEGMENT26 => P_SEGMENT26
,P_SEGMENT27 => P_SEGMENT27
,P_SEGMENT28 => P_SEGMENT28
,P_SEGMENT29 => P_SEGMENT29
,P_SEGMENT30 => P_SEGMENT30
,P_CONCAT_SEGMENTS => P_CONCAT_SEGMENTS
,P_JOB_ID => P_JOB_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
,P_JOB_DEFINITION_ID => P_JOB_DEFINITION_ID
,P_NAME => P_NAME
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_JOB', 'AP');
hr_utility.set_location(' Leaving: HR_JOB_BK1.CREATE_JOB_A', 20);
end CREATE_JOB_A;
procedure CREATE_JOB_B
(P_BUSINESS_GROUP_ID in NUMBER
,P_DATE_FROM in DATE
,P_COMMENTS in VARCHAR2
,P_DATE_TO in DATE
,P_APPROVAL_AUTHORITY in NUMBER
,P_BENCHMARK_JOB_FLAG in VARCHAR2
,P_BENCHMARK_JOB_ID in NUMBER
,P_EMP_RIGHTS_FLAG in VARCHAR2
,P_JOB_GROUP_ID in NUMBER
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
,P_JOB_INFORMATION_CATEGORY in VARCHAR2
,P_JOB_INFORMATION1 in VARCHAR2
,P_JOB_INFORMATION2 in VARCHAR2
,P_JOB_INFORMATION3 in VARCHAR2
,P_JOB_INFORMATION4 in VARCHAR2
,P_JOB_INFORMATION5 in VARCHAR2
,P_JOB_INFORMATION6 in VARCHAR2
,P_JOB_INFORMATION7 in VARCHAR2
,P_JOB_INFORMATION8 in VARCHAR2
,P_JOB_INFORMATION9 in VARCHAR2
,P_JOB_INFORMATION10 in VARCHAR2
,P_JOB_INFORMATION11 in VARCHAR2
,P_JOB_INFORMATION12 in VARCHAR2
,P_JOB_INFORMATION13 in VARCHAR2
,P_JOB_INFORMATION14 in VARCHAR2
,P_JOB_INFORMATION15 in VARCHAR2
,P_JOB_INFORMATION16 in VARCHAR2
,P_JOB_INFORMATION17 in VARCHAR2
,P_JOB_INFORMATION18 in VARCHAR2
,P_JOB_INFORMATION19 in VARCHAR2
,P_JOB_INFORMATION20 in VARCHAR2
,P_SEGMENT1 in VARCHAR2
,P_SEGMENT2 in VARCHAR2
,P_SEGMENT3 in VARCHAR2
,P_SEGMENT4 in VARCHAR2
,P_SEGMENT5 in VARCHAR2
,P_SEGMENT6 in VARCHAR2
,P_SEGMENT7 in VARCHAR2
,P_SEGMENT8 in VARCHAR2
,P_SEGMENT9 in VARCHAR2
,P_SEGMENT10 in VARCHAR2
,P_SEGMENT11 in VARCHAR2
,P_SEGMENT12 in VARCHAR2
,P_SEGMENT13 in VARCHAR2
,P_SEGMENT14 in VARCHAR2
,P_SEGMENT15 in VARCHAR2
,P_SEGMENT16 in VARCHAR2
,P_SEGMENT17 in VARCHAR2
,P_SEGMENT18 in VARCHAR2
,P_SEGMENT19 in VARCHAR2
,P_SEGMENT20 in VARCHAR2
,P_SEGMENT21 in VARCHAR2
,P_SEGMENT22 in VARCHAR2
,P_SEGMENT23 in VARCHAR2
,P_SEGMENT24 in VARCHAR2
,P_SEGMENT25 in VARCHAR2
,P_SEGMENT26 in VARCHAR2
,P_SEGMENT27 in VARCHAR2
,P_SEGMENT28 in VARCHAR2
,P_SEGMENT29 in VARCHAR2
,P_SEGMENT30 in VARCHAR2
,P_CONCAT_SEGMENTS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_JOB_BK1.CREATE_JOB_B', 10);
hr_utility.set_location(' Leaving: HR_JOB_BK1.CREATE_JOB_B', 20);
end CREATE_JOB_B;
end HR_JOB_BK1;

/