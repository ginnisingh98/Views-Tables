--------------------------------------------------------
--  DDL for Package Body HR_ORI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORI_RKU" as
/* $Header: hrorirhi.pkb 120.3.12010000.2 2008/08/06 08:45:57 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:02:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_ORG_INFORMATION_ID in NUMBER
,P_ORG_INFORMATION_CONTEXT in VARCHAR2
,P_ORGANIZATION_ID in NUMBER
,P_ORG_INFORMATION1 in VARCHAR2
,P_ORG_INFORMATION10 in VARCHAR2
,P_ORG_INFORMATION11 in VARCHAR2
,P_ORG_INFORMATION12 in VARCHAR2
,P_ORG_INFORMATION13 in VARCHAR2
,P_ORG_INFORMATION14 in VARCHAR2
,P_ORG_INFORMATION15 in VARCHAR2
,P_ORG_INFORMATION16 in VARCHAR2
,P_ORG_INFORMATION17 in VARCHAR2
,P_ORG_INFORMATION18 in VARCHAR2
,P_ORG_INFORMATION19 in VARCHAR2
,P_ORG_INFORMATION2 in VARCHAR2
,P_ORG_INFORMATION20 in VARCHAR2
,P_ORG_INFORMATION3 in VARCHAR2
,P_ORG_INFORMATION4 in VARCHAR2
,P_ORG_INFORMATION5 in VARCHAR2
,P_ORG_INFORMATION6 in VARCHAR2
,P_ORG_INFORMATION7 in VARCHAR2
,P_ORG_INFORMATION8 in VARCHAR2
,P_ORG_INFORMATION9 in VARCHAR2
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
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ORG_INFORMATION_CONTEXT_O in VARCHAR2
,P_ORGANIZATION_ID_O in NUMBER
,P_ORG_INFORMATION1_O in VARCHAR2
,P_ORG_INFORMATION10_O in VARCHAR2
,P_ORG_INFORMATION11_O in VARCHAR2
,P_ORG_INFORMATION12_O in VARCHAR2
,P_ORG_INFORMATION13_O in VARCHAR2
,P_ORG_INFORMATION14_O in VARCHAR2
,P_ORG_INFORMATION15_O in VARCHAR2
,P_ORG_INFORMATION16_O in VARCHAR2
,P_ORG_INFORMATION17_O in VARCHAR2
,P_ORG_INFORMATION18_O in VARCHAR2
,P_ORG_INFORMATION19_O in VARCHAR2
,P_ORG_INFORMATION2_O in VARCHAR2
,P_ORG_INFORMATION20_O in VARCHAR2
,P_ORG_INFORMATION3_O in VARCHAR2
,P_ORG_INFORMATION4_O in VARCHAR2
,P_ORG_INFORMATION5_O in VARCHAR2
,P_ORG_INFORMATION6_O in VARCHAR2
,P_ORG_INFORMATION7_O in VARCHAR2
,P_ORG_INFORMATION8_O in VARCHAR2
,P_ORG_INFORMATION9_O in VARCHAR2
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
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_ORI_RKU.AFTER_UPDATE', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
-- Note: All legislation hook calls will be executed regardless of the
-- legislation code because the data for this API module is not held within
-- the context of a business_group_id.
PER_FR_ORG_DDF_VALIDATION.VALIDATE_FR_OPM_MAPPING
(P_ORG_INFORMATION_ID => P_ORG_INFORMATION_ID
,P_ORG_INFORMATION_CONTEXT => P_ORG_INFORMATION_CONTEXT
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
);
PER_FR_ORG_DDF_VALIDATION.VALIDATE_FR_CONTRIB_CODES
(P_ORG_INFORMATION_ID => P_ORG_INFORMATION_ID
,P_ORG_INFORMATION_CONTEXT => P_ORG_INFORMATION_CONTEXT
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
);
PAY_JP_EXTRA_BANK_RULES.CHK_SWOT_ACCOUNT_NAME_UPDATE
(P_ORG_INFORMATION_CONTEXT => P_ORG_INFORMATION_CONTEXT
,P_ORG_INFORMATION17 => P_ORG_INFORMATION17
,P_ORG_INFORMATION17_O => P_ORG_INFORMATION17_O
);
PER_KR_EXTRA_ORG_RULES.CHECK_YEA_ENTRY_DATES
(P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION_CONTEXT => P_ORG_INFORMATION_CONTEXT
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
);
PQP_NL_ABP_FUNCTIONS.CHK_DUP_PT_ROW_UPD
(P_ORG_INFORMATION_ID => P_ORG_INFORMATION_ID
,P_ORG_INFORMATION_CONTEXT => P_ORG_INFORMATION_CONTEXT
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION1_O => P_ORG_INFORMATION1_O
,P_ORG_INFORMATION2_O => P_ORG_INFORMATION2_O
,P_ORG_INFORMATION3_O => P_ORG_INFORMATION3_O
,P_ORG_INFORMATION4_O => P_ORG_INFORMATION4_O
,P_ORG_INFORMATION5_O => P_ORG_INFORMATION5_O
,P_ORG_INFORMATION6_O => P_ORG_INFORMATION6_O
);
PAY_US_SQWL_UDF.CHK_FOR_DEFAULT_WP
(P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION_CONTEXT => P_ORG_INFORMATION_CONTEXT
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
);
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'HR_ORGANIZATION_INFORMATION', 'AU');
hr_utility.set_location(' Leaving: HR_ORI_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HR_ORI_RKU;

/