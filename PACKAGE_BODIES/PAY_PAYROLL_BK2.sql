--------------------------------------------------------
--  DDL for Package Body PAY_PAYROLL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYROLL_BK2" as
/* $Header: pyprlapi.pkb 120.7 2008/02/05 05:34:12 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:33 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PAYROLL_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_PAYROLL_NAME in VARCHAR2
,P_NUMBER_OF_YEARS in NUMBER
,P_DEFAULT_PAYMENT_METHOD_ID in NUMBER
,P_CONSOLIDATION_SET_ID in NUMBER
,P_COST_ALLOC_KEYFLEX_ID_IN in NUMBER
,P_SUSP_ACCOUNT_KEYFLEX_ID_IN in NUMBER
,P_NEGATIVE_PAY_ALLOWED_FLAG in VARCHAR2
,P_SOFT_CODING_KEYFLEX_ID_IN in NUMBER
,P_COMMENTS in VARCHAR2
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
,P_ARREARS_FLAG in VARCHAR2
,P_MULTI_ASSIGNMENTS_FLAG in VARCHAR2
,P_PRL_INFORMATION1 in VARCHAR2
,P_PRL_INFORMATION2 in VARCHAR2
,P_PRL_INFORMATION3 in VARCHAR2
,P_PRL_INFORMATION4 in VARCHAR2
,P_PRL_INFORMATION5 in VARCHAR2
,P_PRL_INFORMATION6 in VARCHAR2
,P_PRL_INFORMATION7 in VARCHAR2
,P_PRL_INFORMATION8 in VARCHAR2
,P_PRL_INFORMATION9 in VARCHAR2
,P_PRL_INFORMATION10 in VARCHAR2
,P_PRL_INFORMATION11 in VARCHAR2
,P_PRL_INFORMATION12 in VARCHAR2
,P_PRL_INFORMATION13 in VARCHAR2
,P_PRL_INFORMATION14 in VARCHAR2
,P_PRL_INFORMATION15 in VARCHAR2
,P_PRL_INFORMATION16 in VARCHAR2
,P_PRL_INFORMATION17 in VARCHAR2
,P_PRL_INFORMATION18 in VARCHAR2
,P_PRL_INFORMATION19 in VARCHAR2
,P_PRL_INFORMATION20 in VARCHAR2
,P_PRL_INFORMATION21 in VARCHAR2
,P_PRL_INFORMATION22 in VARCHAR2
,P_PRL_INFORMATION23 in VARCHAR2
,P_PRL_INFORMATION24 in VARCHAR2
,P_PRL_INFORMATION25 in VARCHAR2
,P_PRL_INFORMATION26 in VARCHAR2
,P_PRL_INFORMATION27 in VARCHAR2
,P_PRL_INFORMATION28 in VARCHAR2
,P_PRL_INFORMATION29 in VARCHAR2
,P_PRL_INFORMATION30 in VARCHAR2
,P_COST_SEGMENT1 in VARCHAR2
,P_COST_SEGMENT2 in VARCHAR2
,P_COST_SEGMENT3 in VARCHAR2
,P_COST_SEGMENT4 in VARCHAR2
,P_COST_SEGMENT5 in VARCHAR2
,P_COST_SEGMENT6 in VARCHAR2
,P_COST_SEGMENT7 in VARCHAR2
,P_COST_SEGMENT8 in VARCHAR2
,P_COST_SEGMENT9 in VARCHAR2
,P_COST_SEGMENT10 in VARCHAR2
,P_COST_SEGMENT11 in VARCHAR2
,P_COST_SEGMENT12 in VARCHAR2
,P_COST_SEGMENT13 in VARCHAR2
,P_COST_SEGMENT14 in VARCHAR2
,P_COST_SEGMENT15 in VARCHAR2
,P_COST_SEGMENT16 in VARCHAR2
,P_COST_SEGMENT17 in VARCHAR2
,P_COST_SEGMENT18 in VARCHAR2
,P_COST_SEGMENT19 in VARCHAR2
,P_COST_SEGMENT20 in VARCHAR2
,P_COST_SEGMENT21 in VARCHAR2
,P_COST_SEGMENT22 in VARCHAR2
,P_COST_SEGMENT23 in VARCHAR2
,P_COST_SEGMENT24 in VARCHAR2
,P_COST_SEGMENT25 in VARCHAR2
,P_COST_SEGMENT26 in VARCHAR2
,P_COST_SEGMENT27 in VARCHAR2
,P_COST_SEGMENT28 in VARCHAR2
,P_COST_SEGMENT29 in VARCHAR2
,P_COST_SEGMENT30 in VARCHAR2
,P_COST_CONCAT_SEGMENTS_IN in VARCHAR2
,P_SUSP_SEGMENT1 in VARCHAR2
,P_SUSP_SEGMENT2 in VARCHAR2
,P_SUSP_SEGMENT3 in VARCHAR2
,P_SUSP_SEGMENT4 in VARCHAR2
,P_SUSP_SEGMENT5 in VARCHAR2
,P_SUSP_SEGMENT6 in VARCHAR2
,P_SUSP_SEGMENT7 in VARCHAR2
,P_SUSP_SEGMENT8 in VARCHAR2
,P_SUSP_SEGMENT9 in VARCHAR2
,P_SUSP_SEGMENT10 in VARCHAR2
,P_SUSP_SEGMENT11 in VARCHAR2
,P_SUSP_SEGMENT12 in VARCHAR2
,P_SUSP_SEGMENT13 in VARCHAR2
,P_SUSP_SEGMENT14 in VARCHAR2
,P_SUSP_SEGMENT15 in VARCHAR2
,P_SUSP_SEGMENT16 in VARCHAR2
,P_SUSP_SEGMENT17 in VARCHAR2
,P_SUSP_SEGMENT18 in VARCHAR2
,P_SUSP_SEGMENT19 in VARCHAR2
,P_SUSP_SEGMENT20 in VARCHAR2
,P_SUSP_SEGMENT21 in VARCHAR2
,P_SUSP_SEGMENT22 in VARCHAR2
,P_SUSP_SEGMENT23 in VARCHAR2
,P_SUSP_SEGMENT24 in VARCHAR2
,P_SUSP_SEGMENT25 in VARCHAR2
,P_SUSP_SEGMENT26 in VARCHAR2
,P_SUSP_SEGMENT27 in VARCHAR2
,P_SUSP_SEGMENT28 in VARCHAR2
,P_SUSP_SEGMENT29 in VARCHAR2
,P_SUSP_SEGMENT30 in VARCHAR2
,P_SUSP_CONCAT_SEGMENTS_IN in VARCHAR2
,P_SCL_SEGMENT1 in VARCHAR2
,P_SCL_SEGMENT2 in VARCHAR2
,P_SCL_SEGMENT3 in VARCHAR2
,P_SCL_SEGMENT4 in VARCHAR2
,P_SCL_SEGMENT5 in VARCHAR2
,P_SCL_SEGMENT6 in VARCHAR2
,P_SCL_SEGMENT7 in VARCHAR2
,P_SCL_SEGMENT8 in VARCHAR2
,P_SCL_SEGMENT9 in VARCHAR2
,P_SCL_SEGMENT10 in VARCHAR2
,P_SCL_SEGMENT11 in VARCHAR2
,P_SCL_SEGMENT12 in VARCHAR2
,P_SCL_SEGMENT13 in VARCHAR2
,P_SCL_SEGMENT14 in VARCHAR2
,P_SCL_SEGMENT15 in VARCHAR2
,P_SCL_SEGMENT16 in VARCHAR2
,P_SCL_SEGMENT17 in VARCHAR2
,P_SCL_SEGMENT18 in VARCHAR2
,P_SCL_SEGMENT19 in VARCHAR2
,P_SCL_SEGMENT20 in VARCHAR2
,P_SCL_SEGMENT21 in VARCHAR2
,P_SCL_SEGMENT22 in VARCHAR2
,P_SCL_SEGMENT23 in VARCHAR2
,P_SCL_SEGMENT24 in VARCHAR2
,P_SCL_SEGMENT25 in VARCHAR2
,P_SCL_SEGMENT26 in VARCHAR2
,P_SCL_SEGMENT27 in VARCHAR2
,P_SCL_SEGMENT28 in VARCHAR2
,P_SCL_SEGMENT29 in VARCHAR2
,P_SCL_SEGMENT30 in VARCHAR2
,P_SCL_CONCAT_SEGMENTS_IN in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_WORKLOAD_SHIFTING_LEVEL in VARCHAR2
,P_PAYSLIP_VIEW_DATE_OFFSET in NUMBER
,P_PAYROLL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_COMMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_COST_ALLOC_KEYFLEX_ID_OUT in NUMBER
,P_SUSP_ACCOUNT_KEYFLEX_ID_OUT in NUMBER
,P_SOFT_CODING_KEYFLEX_ID_OUT in NUMBER
,P_COST_CONCAT_SEGMENTS_OUT in VARCHAR2
,P_SUSP_CONCAT_SEGMENTS_OUT in VARCHAR2
,P_SCL_CONCAT_SEGMENTS_OUT in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_PAYROLL_BK2.UPDATE_PAYROLL_A', 10);
hr_utility.set_location(' Leaving: PAY_PAYROLL_BK2.UPDATE_PAYROLL_A', 20);
end UPDATE_PAYROLL_A;
procedure UPDATE_PAYROLL_B
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_PAYROLL_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PAYROLL_NAME in VARCHAR2
,P_NUMBER_OF_YEARS in NUMBER
,P_DEFAULT_PAYMENT_METHOD_ID in NUMBER
,P_CONSOLIDATION_SET_ID in NUMBER
,P_COST_ALLOC_KEYFLEX_ID_IN in NUMBER
,P_SUSP_ACCOUNT_KEYFLEX_ID_IN in NUMBER
,P_NEGATIVE_PAY_ALLOWED_FLAG in VARCHAR2
,P_SOFT_CODING_KEYFLEX_ID_IN in NUMBER
,P_COMMENTS in VARCHAR2
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
,P_ARREARS_FLAG in VARCHAR2
,P_MULTI_ASSIGNMENTS_FLAG in VARCHAR2
,P_PRL_INFORMATION1 in VARCHAR2
,P_PRL_INFORMATION2 in VARCHAR2
,P_PRL_INFORMATION3 in VARCHAR2
,P_PRL_INFORMATION4 in VARCHAR2
,P_PRL_INFORMATION5 in VARCHAR2
,P_PRL_INFORMATION6 in VARCHAR2
,P_PRL_INFORMATION7 in VARCHAR2
,P_PRL_INFORMATION8 in VARCHAR2
,P_PRL_INFORMATION9 in VARCHAR2
,P_PRL_INFORMATION10 in VARCHAR2
,P_PRL_INFORMATION11 in VARCHAR2
,P_PRL_INFORMATION12 in VARCHAR2
,P_PRL_INFORMATION13 in VARCHAR2
,P_PRL_INFORMATION14 in VARCHAR2
,P_PRL_INFORMATION15 in VARCHAR2
,P_PRL_INFORMATION16 in VARCHAR2
,P_PRL_INFORMATION17 in VARCHAR2
,P_PRL_INFORMATION18 in VARCHAR2
,P_PRL_INFORMATION19 in VARCHAR2
,P_PRL_INFORMATION20 in VARCHAR2
,P_PRL_INFORMATION21 in VARCHAR2
,P_PRL_INFORMATION22 in VARCHAR2
,P_PRL_INFORMATION23 in VARCHAR2
,P_PRL_INFORMATION24 in VARCHAR2
,P_PRL_INFORMATION25 in VARCHAR2
,P_PRL_INFORMATION26 in VARCHAR2
,P_PRL_INFORMATION27 in VARCHAR2
,P_PRL_INFORMATION28 in VARCHAR2
,P_PRL_INFORMATION29 in VARCHAR2
,P_PRL_INFORMATION30 in VARCHAR2
,P_COST_SEGMENT1 in VARCHAR2
,P_COST_SEGMENT2 in VARCHAR2
,P_COST_SEGMENT3 in VARCHAR2
,P_COST_SEGMENT4 in VARCHAR2
,P_COST_SEGMENT5 in VARCHAR2
,P_COST_SEGMENT6 in VARCHAR2
,P_COST_SEGMENT7 in VARCHAR2
,P_COST_SEGMENT8 in VARCHAR2
,P_COST_SEGMENT9 in VARCHAR2
,P_COST_SEGMENT10 in VARCHAR2
,P_COST_SEGMENT11 in VARCHAR2
,P_COST_SEGMENT12 in VARCHAR2
,P_COST_SEGMENT13 in VARCHAR2
,P_COST_SEGMENT14 in VARCHAR2
,P_COST_SEGMENT15 in VARCHAR2
,P_COST_SEGMENT16 in VARCHAR2
,P_COST_SEGMENT17 in VARCHAR2
,P_COST_SEGMENT18 in VARCHAR2
,P_COST_SEGMENT19 in VARCHAR2
,P_COST_SEGMENT20 in VARCHAR2
,P_COST_SEGMENT21 in VARCHAR2
,P_COST_SEGMENT22 in VARCHAR2
,P_COST_SEGMENT23 in VARCHAR2
,P_COST_SEGMENT24 in VARCHAR2
,P_COST_SEGMENT25 in VARCHAR2
,P_COST_SEGMENT26 in VARCHAR2
,P_COST_SEGMENT27 in VARCHAR2
,P_COST_SEGMENT28 in VARCHAR2
,P_COST_SEGMENT29 in VARCHAR2
,P_COST_SEGMENT30 in VARCHAR2
,P_COST_CONCAT_SEGMENTS_IN in VARCHAR2
,P_SUSP_SEGMENT1 in VARCHAR2
,P_SUSP_SEGMENT2 in VARCHAR2
,P_SUSP_SEGMENT3 in VARCHAR2
,P_SUSP_SEGMENT4 in VARCHAR2
,P_SUSP_SEGMENT5 in VARCHAR2
,P_SUSP_SEGMENT6 in VARCHAR2
,P_SUSP_SEGMENT7 in VARCHAR2
,P_SUSP_SEGMENT8 in VARCHAR2
,P_SUSP_SEGMENT9 in VARCHAR2
,P_SUSP_SEGMENT10 in VARCHAR2
,P_SUSP_SEGMENT11 in VARCHAR2
,P_SUSP_SEGMENT12 in VARCHAR2
,P_SUSP_SEGMENT13 in VARCHAR2
,P_SUSP_SEGMENT14 in VARCHAR2
,P_SUSP_SEGMENT15 in VARCHAR2
,P_SUSP_SEGMENT16 in VARCHAR2
,P_SUSP_SEGMENT17 in VARCHAR2
,P_SUSP_SEGMENT18 in VARCHAR2
,P_SUSP_SEGMENT19 in VARCHAR2
,P_SUSP_SEGMENT20 in VARCHAR2
,P_SUSP_SEGMENT21 in VARCHAR2
,P_SUSP_SEGMENT22 in VARCHAR2
,P_SUSP_SEGMENT23 in VARCHAR2
,P_SUSP_SEGMENT24 in VARCHAR2
,P_SUSP_SEGMENT25 in VARCHAR2
,P_SUSP_SEGMENT26 in VARCHAR2
,P_SUSP_SEGMENT27 in VARCHAR2
,P_SUSP_SEGMENT28 in VARCHAR2
,P_SUSP_SEGMENT29 in VARCHAR2
,P_SUSP_SEGMENT30 in VARCHAR2
,P_SUSP_CONCAT_SEGMENTS_IN in VARCHAR2
,P_SCL_SEGMENT1 in VARCHAR2
,P_SCL_SEGMENT2 in VARCHAR2
,P_SCL_SEGMENT3 in VARCHAR2
,P_SCL_SEGMENT4 in VARCHAR2
,P_SCL_SEGMENT5 in VARCHAR2
,P_SCL_SEGMENT6 in VARCHAR2
,P_SCL_SEGMENT7 in VARCHAR2
,P_SCL_SEGMENT8 in VARCHAR2
,P_SCL_SEGMENT9 in VARCHAR2
,P_SCL_SEGMENT10 in VARCHAR2
,P_SCL_SEGMENT11 in VARCHAR2
,P_SCL_SEGMENT12 in VARCHAR2
,P_SCL_SEGMENT13 in VARCHAR2
,P_SCL_SEGMENT14 in VARCHAR2
,P_SCL_SEGMENT15 in VARCHAR2
,P_SCL_SEGMENT16 in VARCHAR2
,P_SCL_SEGMENT17 in VARCHAR2
,P_SCL_SEGMENT18 in VARCHAR2
,P_SCL_SEGMENT19 in VARCHAR2
,P_SCL_SEGMENT20 in VARCHAR2
,P_SCL_SEGMENT21 in VARCHAR2
,P_SCL_SEGMENT22 in VARCHAR2
,P_SCL_SEGMENT23 in VARCHAR2
,P_SCL_SEGMENT24 in VARCHAR2
,P_SCL_SEGMENT25 in VARCHAR2
,P_SCL_SEGMENT26 in VARCHAR2
,P_SCL_SEGMENT27 in VARCHAR2
,P_SCL_SEGMENT28 in VARCHAR2
,P_SCL_SEGMENT29 in VARCHAR2
,P_SCL_SEGMENT30 in VARCHAR2
,P_SCL_CONCAT_SEGMENTS_IN in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_WORKLOAD_SHIFTING_LEVEL in VARCHAR2
,P_PAYSLIP_VIEW_DATE_OFFSET in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PAY_PAYROLL_BK2.UPDATE_PAYROLL_B', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := PAY_PAY_BUS.RETURN_LEGISLATION_CODE(P_PAYROLL_ID => P_PAYROLL_ID
);
if l_legislation_code = 'GB' then
PAY_GB_PAYROLL_RULES.VALIDATE_UPDATE
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_DATETRACK_MODE => P_DATETRACK_MODE
,P_PAYROLL_ID => P_PAYROLL_ID
,P_PAYROLL_NAME => P_PAYROLL_NAME
,P_SOFT_CODING_KEYFLEX_ID_IN => P_SOFT_CODING_KEYFLEX_ID_IN
);
end if;
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'UPDATE_PAYROLL', 'BP');
hr_utility.set_location(' Leaving: PAY_PAYROLL_BK2.UPDATE_PAYROLL_B', 20);
end UPDATE_PAYROLL_B;
end PAY_PAYROLL_BK2;

/
