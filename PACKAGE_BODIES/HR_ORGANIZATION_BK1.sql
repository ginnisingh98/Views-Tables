--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION_BK1" as
/* $Header: hrorgapi.pkb 120.10.12010000.8 2009/04/14 09:44:53 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:37:25 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ORG_INFORMATION_A
(P_EFFECTIVE_DATE in DATE
,P_ORGANIZATION_ID in NUMBER
,P_ORG_INFO_TYPE_CODE in VARCHAR2
,P_ORG_INFORMATION1 in VARCHAR2
,P_ORG_INFORMATION2 in VARCHAR2
,P_ORG_INFORMATION3 in VARCHAR2
,P_ORG_INFORMATION4 in VARCHAR2
,P_ORG_INFORMATION5 in VARCHAR2
,P_ORG_INFORMATION6 in VARCHAR2
,P_ORG_INFORMATION7 in VARCHAR2
,P_ORG_INFORMATION8 in VARCHAR2
,P_ORG_INFORMATION9 in VARCHAR2
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
,P_ORG_INFORMATION20 in VARCHAR2
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
,P_ORG_INFORMATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_ORGANIZATION_BK1.CREATE_ORG_INFORMATION_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
hr_organization_be1.CREATE_ORG_INFORMATION_A
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
,P_ORG_INFORMATION11 => P_ORG_INFORMATION11
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
,P_ORG_INFORMATION13 => P_ORG_INFORMATION13
,P_ORG_INFORMATION14 => P_ORG_INFORMATION14
,P_ORG_INFORMATION15 => P_ORG_INFORMATION15
,P_ORG_INFORMATION16 => P_ORG_INFORMATION16
,P_ORG_INFORMATION17 => P_ORG_INFORMATION17
,P_ORG_INFORMATION18 => P_ORG_INFORMATION18
,P_ORG_INFORMATION19 => P_ORG_INFORMATION19
,P_ORG_INFORMATION20 => P_ORG_INFORMATION20
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
,P_ORG_INFORMATION_ID => P_ORG_INFORMATION_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_ORG_INFORMATION', 'AP');
hr_utility.set_location(' Leaving: HR_ORGANIZATION_BK1.CREATE_ORG_INFORMATION_A', 20);
end CREATE_ORG_INFORMATION_A;
procedure CREATE_ORG_INFORMATION_B
(P_EFFECTIVE_DATE in DATE
,P_ORGANIZATION_ID in NUMBER
,P_ORG_INFO_TYPE_CODE in VARCHAR2
,P_ORG_INFORMATION1 in VARCHAR2
,P_ORG_INFORMATION2 in VARCHAR2
,P_ORG_INFORMATION3 in VARCHAR2
,P_ORG_INFORMATION4 in VARCHAR2
,P_ORG_INFORMATION5 in VARCHAR2
,P_ORG_INFORMATION6 in VARCHAR2
,P_ORG_INFORMATION7 in VARCHAR2
,P_ORG_INFORMATION8 in VARCHAR2
,P_ORG_INFORMATION9 in VARCHAR2
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
,P_ORG_INFORMATION20 in VARCHAR2
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
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_ORGANIZATION_BK1.CREATE_ORG_INFORMATION_B', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := HR_ORU_BUS.RETURN_LEGISLATION_CODE(P_ORGANIZATION_ID => P_ORGANIZATION_ID
);
if l_legislation_code = 'AE' then
HR_AE_VALIDATE_PKG.VALIDATE_CREATE_ORG_INF
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
);
elsif l_legislation_code = 'CN' then
PER_CN_ORG_INFO_LEG_HOOK.CHECK_CN_ORG_INFO_TYPE_CREATE
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
,P_ORG_INFORMATION11 => P_ORG_INFORMATION11
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
,P_ORG_INFORMATION13 => P_ORG_INFORMATION13
,P_ORG_INFORMATION14 => P_ORG_INFORMATION14
,P_ORG_INFORMATION15 => P_ORG_INFORMATION15
,P_ORG_INFORMATION16 => P_ORG_INFORMATION16
,P_ORG_INFORMATION17 => P_ORG_INFORMATION17
,P_ORG_INFORMATION18 => P_ORG_INFORMATION18
,P_ORG_INFORMATION19 => P_ORG_INFORMATION19
,P_ORG_INFORMATION20 => P_ORG_INFORMATION20
);
elsif l_legislation_code = 'DE' then
HR_DE_EXTRA_ORG_CHECKS.ORG_INFORMATION_CHECKS
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
);
elsif l_legislation_code = 'DK' then
HR_DK_VALIDATE_PKG.VALIDATE_CREATE_ORG_INF
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
);
elsif l_legislation_code = 'ES' then
PER_ES_ORG_INFO.CREATE_ES_ORG_INFO
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
);
elsif l_legislation_code = 'FI' then
HR_FI_VALIDATE_PKG.VALIDATE_CREATE_ORG_INF
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
);
elsif l_legislation_code = 'FR' then
PE_FR_ADDITIONAL_ORG_RULES.FR_VALIDATE_ORG_INFO_INS
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
,P_ORG_INFORMATION11 => P_ORG_INFORMATION11
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
,P_ORG_INFORMATION13 => P_ORG_INFORMATION13
,P_ORG_INFORMATION14 => P_ORG_INFORMATION14
,P_ORG_INFORMATION15 => P_ORG_INFORMATION15
,P_ORG_INFORMATION16 => P_ORG_INFORMATION16
,P_ORG_INFORMATION17 => P_ORG_INFORMATION17
,P_ORG_INFORMATION18 => P_ORG_INFORMATION18
,P_ORG_INFORMATION19 => P_ORG_INFORMATION19
,P_ORG_INFORMATION20 => P_ORG_INFORMATION20
);
elsif l_legislation_code = 'GB' then
PER_GB_ORG_INFO.CREATE_GB_ORG_INFO
(P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
);
elsif l_legislation_code = 'HU' then
PER_HU_ORG_INFO.CREATE_HU_ORG_INFO
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
);
elsif l_legislation_code = 'IE' then
PER_IE_ORG_INFO.CREATE_IE_ORG_INFO
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
);
elsif l_legislation_code = 'IN' then
PER_IN_ORG_INFO_LEG_HOOK.CHECK_ORG_INFO_CREATE
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
,P_ORG_INFORMATION11 => P_ORG_INFORMATION11
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
,P_ORG_INFORMATION13 => P_ORG_INFORMATION13
,P_ORG_INFORMATION14 => P_ORG_INFORMATION14
,P_ORG_INFORMATION15 => P_ORG_INFORMATION15
,P_ORG_INFORMATION16 => P_ORG_INFORMATION16
,P_ORG_INFORMATION17 => P_ORG_INFORMATION17
,P_ORG_INFORMATION18 => P_ORG_INFORMATION18
,P_ORG_INFORMATION19 => P_ORG_INFORMATION19
,P_ORG_INFORMATION20 => P_ORG_INFORMATION20
);
elsif l_legislation_code = 'KW' then
HR_KW_VALIDATE_PKG.VALIDATE_CREATE_ORG_INF
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
);
elsif l_legislation_code = 'NO' then
HR_NO_VALIDATE_PKG.VALIDATE_CREATE_ORG_INF
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
,P_ORG_INFORMATION11 => P_ORG_INFORMATION11
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
,P_ORG_INFORMATION13 => P_ORG_INFORMATION13
,P_ORG_INFORMATION14 => P_ORG_INFORMATION14
,P_ORG_INFORMATION15 => P_ORG_INFORMATION15
,P_ORG_INFORMATION16 => P_ORG_INFORMATION16
,P_ORG_INFORMATION17 => P_ORG_INFORMATION17
,P_ORG_INFORMATION18 => P_ORG_INFORMATION18
,P_ORG_INFORMATION19 => P_ORG_INFORMATION19
,P_ORG_INFORMATION20 => P_ORG_INFORMATION20
);
elsif l_legislation_code = 'PL' then
PER_PL_ORG_INFO.CREATE_PL_ORG_INFO
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
,P_ORG_INFORMATION11 => P_ORG_INFORMATION11
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
,P_ORG_INFORMATION13 => P_ORG_INFORMATION13
,P_ORG_INFORMATION14 => P_ORG_INFORMATION14
,P_ORG_INFORMATION15 => P_ORG_INFORMATION15
,P_ORG_INFORMATION16 => P_ORG_INFORMATION16
,P_ORG_INFORMATION17 => P_ORG_INFORMATION17
,P_ORG_INFORMATION18 => P_ORG_INFORMATION18
,P_ORG_INFORMATION19 => P_ORG_INFORMATION19
,P_ORG_INFORMATION20 => P_ORG_INFORMATION20
);
elsif l_legislation_code = 'RU' then
PER_RU_ORG_INFO.CREATE_RU_ORG_INFO
(P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
);
elsif l_legislation_code = 'SE' then
HR_SE_VALIDATE_PKG.VALIDATE_CREATE_ORG_INF
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
,P_ORG_INFORMATION11 => P_ORG_INFORMATION11
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
,P_ORG_INFORMATION13 => P_ORG_INFORMATION13
,P_ORG_INFORMATION14 => P_ORG_INFORMATION14
,P_ORG_INFORMATION15 => P_ORG_INFORMATION15
,P_ORG_INFORMATION16 => P_ORG_INFORMATION16
);
elsif l_legislation_code = 'US' then
PER_US_ORG_INFO_LEG_HOOK.INSERT_US_ORG_INFO
(P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
);
elsif l_legislation_code = 'ZA' then
PER_ZA_USER_HOOK_PKG.VALIDATE_ORG_INFO
(P_ORG_INFO_TYPE_CODE => P_ORG_INFO_TYPE_CODE
,P_ORG_INFORMATION1 => P_ORG_INFORMATION1
,P_ORG_INFORMATION2 => P_ORG_INFORMATION2
,P_ORG_INFORMATION3 => P_ORG_INFORMATION3
,P_ORG_INFORMATION4 => P_ORG_INFORMATION4
,P_ORG_INFORMATION5 => P_ORG_INFORMATION5
,P_ORG_INFORMATION6 => P_ORG_INFORMATION6
,P_ORG_INFORMATION7 => P_ORG_INFORMATION7
,P_ORG_INFORMATION8 => P_ORG_INFORMATION8
,P_ORG_INFORMATION9 => P_ORG_INFORMATION9
,P_ORG_INFORMATION10 => P_ORG_INFORMATION10
,P_ORG_INFORMATION11 => P_ORG_INFORMATION11
,P_ORG_INFORMATION12 => P_ORG_INFORMATION12
,P_ORG_INFORMATION13 => P_ORG_INFORMATION13
);
end if;
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_ORG_INFORMATION', 'BP');
hr_utility.set_location(' Leaving: HR_ORGANIZATION_BK1.CREATE_ORG_INFORMATION_B', 20);
end CREATE_ORG_INFORMATION_B;
end HR_ORGANIZATION_BK1;

/