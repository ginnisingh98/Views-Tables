--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_BK10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_BK10" as
/* $Header: peasgapi.pkb 115.0 2002/06/10 07:14:33 generated ship      $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 02/10/26 00:55:13 (YY/MM/DD HH:MM:SS)
procedure UPDATE_CWK_ASG_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_ASSIGNMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ASSIGNMENT_CATEGORY in VARCHAR2
,P_ASSIGNMENT_NUMBER in VARCHAR2
,P_CHANGE_REASON in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_DEFAULT_CODE_COMB_ID in NUMBER
,P_ESTABLISHMENT_ID in NUMBER
,P_FREQUENCY in VARCHAR2
,P_INTERNAL_ADDRESS_LINE in VARCHAR2
,P_LABOUR_UNION_MEMBER_FLAG in VARCHAR2
,P_MANAGER_FLAG in VARCHAR2
,P_NORMAL_HOURS in NUMBER
,P_PROJECT_TITLE in VARCHAR2
,P_SET_OF_BOOKS_ID in NUMBER
,P_SOURCE_TYPE in VARCHAR2
,P_SUPERVISOR_ID in NUMBER
,P_TIME_NORMAL_FINISH in VARCHAR2
,P_TIME_NORMAL_START in VARCHAR2
,P_TITLE in VARCHAR2
,P_VENDOR_ASSIGNMENT_NUMBER in VARCHAR2
,P_VENDOR_EMPLOYEE_NUMBER in VARCHAR2
,P_VENDOR_ID in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
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
,P_ORG_NOW_NO_MANAGER_WARNING in BOOLEAN
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_COMMENT_ID in NUMBER
,P_NO_MANAGERS_WARNING in BOOLEAN
,P_OTHER_MANAGER_WARNING in BOOLEAN
,P_SOFT_CODING_KEYFLEX_ID in NUMBER
,P_CONCATENATED_SEGMENTS in VARCHAR2
,P_HOURLY_SALARIED_WARNING in BOOLEAN
)is
begin
hr_utility.set_location('Entering: HR_ASSIGNMENT_BK10.UPDATE_CWK_ASG_A', 10);
hr_utility.set_location(' Leaving: HR_ASSIGNMENT_BK10.UPDATE_CWK_ASG_A', 20);
end UPDATE_CWK_ASG_A;
procedure UPDATE_CWK_ASG_B
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_ASSIGNMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ASSIGNMENT_CATEGORY in VARCHAR2
,P_ASSIGNMENT_NUMBER in VARCHAR2
,P_CHANGE_REASON in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_DEFAULT_CODE_COMB_ID in NUMBER
,P_ESTABLISHMENT_ID in NUMBER
,P_FREQUENCY in VARCHAR2
,P_INTERNAL_ADDRESS_LINE in VARCHAR2
,P_LABOUR_UNION_MEMBER_FLAG in VARCHAR2
,P_MANAGER_FLAG in VARCHAR2
,P_NORMAL_HOURS in NUMBER
,P_PROJECT_TITLE in VARCHAR2
,P_SET_OF_BOOKS_ID in NUMBER
,P_SOURCE_TYPE in VARCHAR2
,P_SUPERVISOR_ID in NUMBER
,P_TIME_NORMAL_FINISH in VARCHAR2
,P_TIME_NORMAL_START in VARCHAR2
,P_TITLE in VARCHAR2
,P_VENDOR_ASSIGNMENT_NUMBER in VARCHAR2
,P_VENDOR_EMPLOYEE_NUMBER in VARCHAR2
,P_VENDOR_ID in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
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
)is
begin
hr_utility.set_location('Entering: HR_ASSIGNMENT_BK10.UPDATE_CWK_ASG_B', 10);
hr_utility.set_location(' Leaving: HR_ASSIGNMENT_BK10.UPDATE_CWK_ASG_B', 20);
end UPDATE_CWK_ASG_B;
end HR_ASSIGNMENT_BK10;

/
