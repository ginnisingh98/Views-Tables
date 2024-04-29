--------------------------------------------------------
--  DDL for Package Body HR_FMP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FMP_RKU" as
/* $Header: hrfmprhi.pkb 115.5 2003/10/30 07:11:27 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_FORM_PROPERTY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_APPLICATION_ID in NUMBER
,P_FORM_ID in NUMBER
,P_FORM_TEMPLATE_ID in NUMBER
,P_HELP_TARGET in VARCHAR2
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
,P_INFORMATION21 in VARCHAR2
,P_INFORMATION22 in VARCHAR2
,P_INFORMATION23 in VARCHAR2
,P_INFORMATION24 in VARCHAR2
,P_INFORMATION25 in VARCHAR2
,P_INFORMATION26 in VARCHAR2
,P_INFORMATION27 in VARCHAR2
,P_INFORMATION28 in VARCHAR2
,P_INFORMATION29 in VARCHAR2
,P_INFORMATION30 in VARCHAR2
,P_APPLICATION_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_FORM_ID_O in NUMBER
,P_FORM_TEMPLATE_ID_O in NUMBER
,P_HELP_TARGET_O in VARCHAR2
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
)is
begin
hr_utility.set_location('Entering: hr_fmp_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: hr_fmp_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end hr_fmp_RKU;

/
