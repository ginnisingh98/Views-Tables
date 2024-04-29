--------------------------------------------------------
--  DDL for Package Body PSP_EXTERNAL_EFFORT_LINES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EXTERNAL_EFFORT_LINES_BK1" as
/* $Header: PSPEEAIB.pls 120.2 2006/02/28 05:27:39 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:01:29 (YYYY/MM/DD HH24:MI:SS)
procedure INSERT_EXTERNAL_EFFORT_LINE_A
(P_EXTERNAL_EFFORT_LINE_ID in NUMBER
,P_BATCH_NAME in VARCHAR2
,P_DISTRIBUTION_DATE in DATE
,P_PERSON_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_CURRENCY_CODE in VARCHAR2
,P_DISTRIBUTION_AMOUNT in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SET_OF_BOOKS_ID in NUMBER
,P_GL_CODE_COMBINATION_ID in NUMBER
,P_PROJECT_ID in NUMBER
,P_TASK_ID in NUMBER
,P_AWARD_ID in NUMBER
,P_EXPENDITURE_ORGANIZATION_ID in NUMBER
,P_EXPENDITURE_TYPE in VARCHAR2
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
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RETURN_STATUS in BOOLEAN
)is
begin
hr_utility.set_location('Entering: PSP_EXTERNAL_EFFORT_LINES_BK1.INSERT_EXTERNAL_EFFORT_LINE_A', 10);
hr_utility.set_location(' Leaving: PSP_EXTERNAL_EFFORT_LINES_BK1.INSERT_EXTERNAL_EFFORT_LINE_A', 20);
end INSERT_EXTERNAL_EFFORT_LINE_A;
procedure INSERT_EXTERNAL_EFFORT_LINE_B
(P_BATCH_NAME in VARCHAR2
,P_DISTRIBUTION_DATE in DATE
,P_PERSON_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_CURRENCY_CODE in VARCHAR2
,P_DISTRIBUTION_AMOUNT in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SET_OF_BOOKS_ID in NUMBER
,P_GL_CODE_COMBINATION_ID in NUMBER
,P_PROJECT_ID in NUMBER
,P_TASK_ID in NUMBER
,P_AWARD_ID in NUMBER
,P_EXPENDITURE_ORGANIZATION_ID in NUMBER
,P_EXPENDITURE_TYPE in VARCHAR2
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
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PSP_EXTERNAL_EFFORT_LINES_BK1.INSERT_EXTERNAL_EFFORT_LINE_B', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
PSP_PEE_EXT.INSERT_EXTERNAL_EFF_LINE_EXT
(P_BATCH_NAME => P_BATCH_NAME
,P_DISTRIBUTION_DATE => P_DISTRIBUTION_DATE
,P_PERSON_ID => P_PERSON_ID
,P_ASSIGNMENT_ID => P_ASSIGNMENT_ID
,P_CURRENCY_CODE => P_CURRENCY_CODE
,P_DISTRIBUTION_AMOUNT => P_DISTRIBUTION_AMOUNT
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_SET_OF_BOOKS_ID => P_SET_OF_BOOKS_ID
,P_GL_CODE_COMBINATION_ID => P_GL_CODE_COMBINATION_ID
,P_PROJECT_ID => P_PROJECT_ID
,P_TASK_ID => P_TASK_ID
,P_AWARD_ID => P_AWARD_ID
,P_EXPENDITURE_ORGANIZATION_ID => P_EXPENDITURE_ORGANIZATION_ID
,P_EXPENDITURE_TYPE => P_EXPENDITURE_TYPE
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
);
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'INSERT_EXTERNAL_EFFORT_LINE', 'BP');
hr_utility.set_location(' Leaving: PSP_EXTERNAL_EFFORT_LINES_BK1.INSERT_EXTERNAL_EFFORT_LINE_B', 20);
end INSERT_EXTERNAL_EFFORT_LINE_B;
end PSP_EXTERNAL_EFFORT_LINES_BK1;

/