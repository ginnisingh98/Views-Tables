--------------------------------------------------------
--  DDL for Package Body HR_ITP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITP_RKD" as
/* $Header: hritprhi.pkb 115.11 2003/12/03 07:01:45 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ITEM_PROPERTY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_FORM_ITEM_ID_O in NUMBER
,P_TEMPLATE_ITEM_ID_O in NUMBER
,P_TEMPLATE_ITEM_CONTEXT_ID_O in NUMBER
,P_ALIGNMENT_O in NUMBER
,P_BEVEL_O in NUMBER
,P_CASE_RESTRICTION_O in NUMBER
,P_ENABLED_O in NUMBER
,P_FORMAT_MASK_O in VARCHAR2
,P_HEIGHT_O in NUMBER
,P_INFORMATION_FORMULA_ID_O in NUMBER
,P_INFORMATION_PARAM_ITEM_ID1_O in NUMBER
,P_INFORMATION_PARAM_ITEM_ID2_O in NUMBER
,P_INFORMATION_PARAM_ITEM_ID3_O in NUMBER
,P_INFORMATION_PARAM_ITEM_ID4_O in NUMBER
,P_INFORMATION_PARAM_ITEM_ID5_O in NUMBER
,P_INSERT_ALLOWED_O in NUMBER
,P_PROMPT_ALIGNMENT_OFFSET_O in NUMBER
,P_PROMPT_DISPLAY_STYLE_O in NUMBER
,P_PROMPT_EDGE_O in NUMBER
,P_PROMPT_EDGE_ALIGNMENT_O in NUMBER
,P_PROMPT_EDGE_OFFSET_O in NUMBER
,P_PROMPT_TEXT_ALIGNMENT_O in NUMBER
,P_QUERY_ALLOWED_O in NUMBER
,P_REQUIRED_O in NUMBER
,P_UPDATE_ALLOWED_O in NUMBER
,P_VALIDATION_FORMULA_ID_O in NUMBER
,P_VALIDATION_PARAM_ITEM_ID1_O in NUMBER
,P_VALIDATION_PARAM_ITEM_ID2_O in NUMBER
,P_VALIDATION_PARAM_ITEM_ID3_O in NUMBER
,P_VALIDATION_PARAM_ITEM_ID4_O in NUMBER
,P_VALIDATION_PARAM_ITEM_ID5_O in NUMBER
,P_VISIBLE_O in NUMBER
,P_WIDTH_O in NUMBER
,P_X_POSITION_O in NUMBER
,P_Y_POSITION_O in NUMBER
,P_INFORMATION_CATEGORY_O in VARCHAR2
,P_INFORMATION1_O in VARCHAR2
,P_INFORMATION2_O in VARCHAR2
,P_INFORMATION3_O in VARCHAR2
,P_INFORMATION4_O in VARCHAR2
,P_INFORMATION5_O in VARCHAR2
,P_INFORMATION6_O in VARCHAR2
,P_INFORMATION7_O in VARCHAR2
,P_INFORMATION8_O in VARCHAR2
,P_INFORMATION9_O in VARCHAR2
,P_INFORMATION10_O in VARCHAR2
,P_INFORMATION11_O in VARCHAR2
,P_INFORMATION12_O in VARCHAR2
,P_INFORMATION13_O in VARCHAR2
,P_INFORMATION14_O in VARCHAR2
,P_INFORMATION15_O in VARCHAR2
,P_INFORMATION16_O in VARCHAR2
,P_INFORMATION17_O in VARCHAR2
,P_INFORMATION18_O in VARCHAR2
,P_INFORMATION19_O in VARCHAR2
,P_INFORMATION20_O in VARCHAR2
,P_INFORMATION21_O in VARCHAR2
,P_INFORMATION22_O in VARCHAR2
,P_INFORMATION23_O in VARCHAR2
,P_INFORMATION24_O in VARCHAR2
,P_INFORMATION25_O in VARCHAR2
,P_INFORMATION26_O in VARCHAR2
,P_INFORMATION27_O in VARCHAR2
,P_INFORMATION28_O in VARCHAR2
,P_INFORMATION29_O in VARCHAR2
,P_INFORMATION30_O in VARCHAR2
,P_NEXT_NAVIGATION_ITEM_ID_O in NUMBER
,P_PREV_NAVIGATION_ITEM_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: hr_itp_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: hr_itp_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end hr_itp_RKD;

/