--------------------------------------------------------
--  DDL for Package Body PAY_BTL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTL_RKU" as
/* $Header: pybtlrhi.pkb 120.7 2005/11/09 08:16:09 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:27:47 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_SESSION_DATE in DATE
,P_BATCH_LINE_ID in NUMBER
,P_COST_ALLOCATION_KEYFLEX_ID in NUMBER
,P_ELEMENT_TYPE_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_BATCH_LINE_STATUS in VARCHAR2
,P_ASSIGNMENT_NUMBER in VARCHAR2
,P_BATCH_SEQUENCE in NUMBER
,P_CONCATENATED_SEGMENTS in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_ELEMENT_NAME in VARCHAR2
,P_ENTRY_TYPE in VARCHAR2
,P_REASON in VARCHAR2
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
,P_VALUE_1 in VARCHAR2
,P_VALUE_2 in VARCHAR2
,P_VALUE_3 in VARCHAR2
,P_VALUE_4 in VARCHAR2
,P_VALUE_5 in VARCHAR2
,P_VALUE_6 in VARCHAR2
,P_VALUE_7 in VARCHAR2
,P_VALUE_8 in VARCHAR2
,P_VALUE_9 in VARCHAR2
,P_VALUE_10 in VARCHAR2
,P_VALUE_11 in VARCHAR2
,P_VALUE_12 in VARCHAR2
,P_VALUE_13 in VARCHAR2
,P_VALUE_14 in VARCHAR2
,P_VALUE_15 in VARCHAR2
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
,P_ENTRY_INFORMATION_CATEGORY in VARCHAR2
,P_ENTRY_INFORMATION1 in VARCHAR2
,P_ENTRY_INFORMATION2 in VARCHAR2
,P_ENTRY_INFORMATION3 in VARCHAR2
,P_ENTRY_INFORMATION4 in VARCHAR2
,P_ENTRY_INFORMATION5 in VARCHAR2
,P_ENTRY_INFORMATION6 in VARCHAR2
,P_ENTRY_INFORMATION7 in VARCHAR2
,P_ENTRY_INFORMATION8 in VARCHAR2
,P_ENTRY_INFORMATION9 in VARCHAR2
,P_ENTRY_INFORMATION10 in VARCHAR2
,P_ENTRY_INFORMATION11 in VARCHAR2
,P_ENTRY_INFORMATION12 in VARCHAR2
,P_ENTRY_INFORMATION13 in VARCHAR2
,P_ENTRY_INFORMATION14 in VARCHAR2
,P_ENTRY_INFORMATION15 in VARCHAR2
,P_ENTRY_INFORMATION16 in VARCHAR2
,P_ENTRY_INFORMATION17 in VARCHAR2
,P_ENTRY_INFORMATION18 in VARCHAR2
,P_ENTRY_INFORMATION19 in VARCHAR2
,P_ENTRY_INFORMATION20 in VARCHAR2
,P_ENTRY_INFORMATION21 in VARCHAR2
,P_ENTRY_INFORMATION22 in VARCHAR2
,P_ENTRY_INFORMATION23 in VARCHAR2
,P_ENTRY_INFORMATION24 in VARCHAR2
,P_ENTRY_INFORMATION25 in VARCHAR2
,P_ENTRY_INFORMATION26 in VARCHAR2
,P_ENTRY_INFORMATION27 in VARCHAR2
,P_ENTRY_INFORMATION28 in VARCHAR2
,P_ENTRY_INFORMATION29 in VARCHAR2
,P_ENTRY_INFORMATION30 in VARCHAR2
,P_DATE_EARNED in DATE
,P_PERSONAL_PAYMENT_METHOD_ID in NUMBER
,P_SUBPRIORITY in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_COST_ALLOCATION_KEYFLEX_ID_O in NUMBER
,P_ELEMENT_TYPE_ID_O in NUMBER
,P_ASSIGNMENT_ID_O in NUMBER
,P_BATCH_ID_O in NUMBER
,P_BATCH_LINE_STATUS_O in VARCHAR2
,P_ASSIGNMENT_NUMBER_O in VARCHAR2
,P_BATCH_SEQUENCE_O in NUMBER
,P_CONCATENATED_SEGMENTS_O in VARCHAR2
,P_EFFECTIVE_DATE_O in DATE
,P_ELEMENT_NAME_O in VARCHAR2
,P_ENTRY_TYPE_O in VARCHAR2
,P_REASON_O in VARCHAR2
,P_SEGMENT1_O in VARCHAR2
,P_SEGMENT2_O in VARCHAR2
,P_SEGMENT3_O in VARCHAR2
,P_SEGMENT4_O in VARCHAR2
,P_SEGMENT5_O in VARCHAR2
,P_SEGMENT6_O in VARCHAR2
,P_SEGMENT7_O in VARCHAR2
,P_SEGMENT8_O in VARCHAR2
,P_SEGMENT9_O in VARCHAR2
,P_SEGMENT10_O in VARCHAR2
,P_SEGMENT11_O in VARCHAR2
,P_SEGMENT12_O in VARCHAR2
,P_SEGMENT13_O in VARCHAR2
,P_SEGMENT14_O in VARCHAR2
,P_SEGMENT15_O in VARCHAR2
,P_SEGMENT16_O in VARCHAR2
,P_SEGMENT17_O in VARCHAR2
,P_SEGMENT18_O in VARCHAR2
,P_SEGMENT19_O in VARCHAR2
,P_SEGMENT20_O in VARCHAR2
,P_SEGMENT21_O in VARCHAR2
,P_SEGMENT22_O in VARCHAR2
,P_SEGMENT23_O in VARCHAR2
,P_SEGMENT24_O in VARCHAR2
,P_SEGMENT25_O in VARCHAR2
,P_SEGMENT26_O in VARCHAR2
,P_SEGMENT27_O in VARCHAR2
,P_SEGMENT28_O in VARCHAR2
,P_SEGMENT29_O in VARCHAR2
,P_SEGMENT30_O in VARCHAR2
,P_VALUE_1_O in VARCHAR2
,P_VALUE_2_O in VARCHAR2
,P_VALUE_3_O in VARCHAR2
,P_VALUE_4_O in VARCHAR2
,P_VALUE_5_O in VARCHAR2
,P_VALUE_6_O in VARCHAR2
,P_VALUE_7_O in VARCHAR2
,P_VALUE_8_O in VARCHAR2
,P_VALUE_9_O in VARCHAR2
,P_VALUE_10_O in VARCHAR2
,P_VALUE_11_O in VARCHAR2
,P_VALUE_12_O in VARCHAR2
,P_VALUE_13_O in VARCHAR2
,P_VALUE_14_O in VARCHAR2
,P_VALUE_15_O in VARCHAR2
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
,P_ENTRY_INFORMATION_CATEGORY_O in VARCHAR2
,P_ENTRY_INFORMATION1_O in VARCHAR2
,P_ENTRY_INFORMATION2_O in VARCHAR2
,P_ENTRY_INFORMATION3_O in VARCHAR2
,P_ENTRY_INFORMATION4_O in VARCHAR2
,P_ENTRY_INFORMATION5_O in VARCHAR2
,P_ENTRY_INFORMATION6_O in VARCHAR2
,P_ENTRY_INFORMATION7_O in VARCHAR2
,P_ENTRY_INFORMATION8_O in VARCHAR2
,P_ENTRY_INFORMATION9_O in VARCHAR2
,P_ENTRY_INFORMATION10_O in VARCHAR2
,P_ENTRY_INFORMATION11_O in VARCHAR2
,P_ENTRY_INFORMATION12_O in VARCHAR2
,P_ENTRY_INFORMATION13_O in VARCHAR2
,P_ENTRY_INFORMATION14_O in VARCHAR2
,P_ENTRY_INFORMATION15_O in VARCHAR2
,P_ENTRY_INFORMATION16_O in VARCHAR2
,P_ENTRY_INFORMATION17_O in VARCHAR2
,P_ENTRY_INFORMATION18_O in VARCHAR2
,P_ENTRY_INFORMATION19_O in VARCHAR2
,P_ENTRY_INFORMATION20_O in VARCHAR2
,P_ENTRY_INFORMATION21_O in VARCHAR2
,P_ENTRY_INFORMATION22_O in VARCHAR2
,P_ENTRY_INFORMATION23_O in VARCHAR2
,P_ENTRY_INFORMATION24_O in VARCHAR2
,P_ENTRY_INFORMATION25_O in VARCHAR2
,P_ENTRY_INFORMATION26_O in VARCHAR2
,P_ENTRY_INFORMATION27_O in VARCHAR2
,P_ENTRY_INFORMATION28_O in VARCHAR2
,P_ENTRY_INFORMATION29_O in VARCHAR2
,P_ENTRY_INFORMATION30_O in VARCHAR2
,P_DATE_EARNED_O in DATE
,P_PERSONAL_PAYMENT_METHOD_ID_O in NUMBER
,P_SUBPRIORITY_O in NUMBER
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_BTL_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PAY_BTL_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PAY_BTL_RKU;

/