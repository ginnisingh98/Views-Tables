--------------------------------------------------------
--  DDL for Package Body PER_DISABILITY_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DISABILITY_API_BK2" as
/* $Header: pedisapi.pkb 120.0 2005/10/02 02:14:49 generated $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:02:24 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_DISABILITY_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_DISABILITY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CATEGORY in VARCHAR2
,P_STATUS in VARCHAR2
,P_QUOTA_FTE in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_REGISTRATION_ID in VARCHAR2
,P_REGISTRATION_DATE in DATE
,P_REGISTRATION_EXP_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_DEGREE in NUMBER
,P_REASON in VARCHAR2
,P_WORK_RESTRICTION in VARCHAR2
,P_INCIDENT_ID in NUMBER
,P_PRE_REGISTRATION_JOB in VARCHAR2
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
,P_DIS_INFORMATION_CATEGORY in VARCHAR2
,P_DIS_INFORMATION1 in VARCHAR2
,P_DIS_INFORMATION2 in VARCHAR2
,P_DIS_INFORMATION3 in VARCHAR2
,P_DIS_INFORMATION4 in VARCHAR2
,P_DIS_INFORMATION5 in VARCHAR2
,P_DIS_INFORMATION6 in VARCHAR2
,P_DIS_INFORMATION7 in VARCHAR2
,P_DIS_INFORMATION8 in VARCHAR2
,P_DIS_INFORMATION9 in VARCHAR2
,P_DIS_INFORMATION10 in VARCHAR2
,P_DIS_INFORMATION11 in VARCHAR2
,P_DIS_INFORMATION12 in VARCHAR2
,P_DIS_INFORMATION13 in VARCHAR2
,P_DIS_INFORMATION14 in VARCHAR2
,P_DIS_INFORMATION15 in VARCHAR2
,P_DIS_INFORMATION16 in VARCHAR2
,P_DIS_INFORMATION17 in VARCHAR2
,P_DIS_INFORMATION18 in VARCHAR2
,P_DIS_INFORMATION19 in VARCHAR2
,P_DIS_INFORMATION20 in VARCHAR2
,P_DIS_INFORMATION21 in VARCHAR2
,P_DIS_INFORMATION22 in VARCHAR2
,P_DIS_INFORMATION23 in VARCHAR2
,P_DIS_INFORMATION24 in VARCHAR2
,P_DIS_INFORMATION25 in VARCHAR2
,P_DIS_INFORMATION26 in VARCHAR2
,P_DIS_INFORMATION27 in VARCHAR2
,P_DIS_INFORMATION28 in VARCHAR2
,P_DIS_INFORMATION29 in VARCHAR2
,P_DIS_INFORMATION30 in VARCHAR2
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PER_DISABILITY_API_BK2.UPDATE_DISABILITY_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := PER_DIS_BUS.RETURN_LEGISLATION_CODE(P_DISABILITY_ID => P_DISABILITY_ID
);
if l_legislation_code = 'HU' then
PER_HU_DISABILITY.UPDATE_HU_DISABILITY
(P_CATEGORY => P_CATEGORY
,P_DEGREE => P_DEGREE
);
elsif l_legislation_code = 'IN' then
PER_IN_DISABILITY_LEG_HOOK.EMP_DISABILITY_UPDATE
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_DISABILITY_ID => P_DISABILITY_ID
,P_CATEGORY => P_CATEGORY
,P_STATUS => P_STATUS
,P_DEGREE => P_DEGREE
,P_DIS_INFORMATION1 => P_DIS_INFORMATION1
);
elsif l_legislation_code = 'MX' then
PER_MX_VALIDATE_ID.VALIDATE_REGN_ID
(P_DISABILITY_ID => P_DISABILITY_ID
,P_REGISTRATION_ID => P_REGISTRATION_ID
);
end if;
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'UPDATE_DISABILITY', 'AP');
hr_utility.set_location(' Leaving: PER_DISABILITY_API_BK2.UPDATE_DISABILITY_A', 20);
end UPDATE_DISABILITY_A;
procedure UPDATE_DISABILITY_B
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_DISABILITY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CATEGORY in VARCHAR2
,P_STATUS in VARCHAR2
,P_QUOTA_FTE in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_REGISTRATION_ID in VARCHAR2
,P_REGISTRATION_DATE in DATE
,P_REGISTRATION_EXP_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_DEGREE in NUMBER
,P_REASON in VARCHAR2
,P_WORK_RESTRICTION in VARCHAR2
,P_INCIDENT_ID in NUMBER
,P_PRE_REGISTRATION_JOB in VARCHAR2
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
,P_DIS_INFORMATION_CATEGORY in VARCHAR2
,P_DIS_INFORMATION1 in VARCHAR2
,P_DIS_INFORMATION2 in VARCHAR2
,P_DIS_INFORMATION3 in VARCHAR2
,P_DIS_INFORMATION4 in VARCHAR2
,P_DIS_INFORMATION5 in VARCHAR2
,P_DIS_INFORMATION6 in VARCHAR2
,P_DIS_INFORMATION7 in VARCHAR2
,P_DIS_INFORMATION8 in VARCHAR2
,P_DIS_INFORMATION9 in VARCHAR2
,P_DIS_INFORMATION10 in VARCHAR2
,P_DIS_INFORMATION11 in VARCHAR2
,P_DIS_INFORMATION12 in VARCHAR2
,P_DIS_INFORMATION13 in VARCHAR2
,P_DIS_INFORMATION14 in VARCHAR2
,P_DIS_INFORMATION15 in VARCHAR2
,P_DIS_INFORMATION16 in VARCHAR2
,P_DIS_INFORMATION17 in VARCHAR2
,P_DIS_INFORMATION18 in VARCHAR2
,P_DIS_INFORMATION19 in VARCHAR2
,P_DIS_INFORMATION20 in VARCHAR2
,P_DIS_INFORMATION21 in VARCHAR2
,P_DIS_INFORMATION22 in VARCHAR2
,P_DIS_INFORMATION23 in VARCHAR2
,P_DIS_INFORMATION24 in VARCHAR2
,P_DIS_INFORMATION25 in VARCHAR2
,P_DIS_INFORMATION26 in VARCHAR2
,P_DIS_INFORMATION27 in VARCHAR2
,P_DIS_INFORMATION28 in VARCHAR2
,P_DIS_INFORMATION29 in VARCHAR2
,P_DIS_INFORMATION30 in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PER_DISABILITY_API_BK2.UPDATE_DISABILITY_B', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := PER_DIS_BUS.RETURN_LEGISLATION_CODE(P_DISABILITY_ID => P_DISABILITY_ID
);
if l_legislation_code = 'AE' then
HR_AE_VALIDATE_PKG.UPDATE_DISABILITY_VALIDATE
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_DISABILITY_ID => P_DISABILITY_ID
,P_CATEGORY => P_CATEGORY
,P_DEGREE => P_DEGREE
,P_DIS_INFORMATION_CATEGORY => P_DIS_INFORMATION_CATEGORY
,P_DIS_INFORMATION1 => P_DIS_INFORMATION1
,P_DIS_INFORMATION2 => P_DIS_INFORMATION2
);
elsif l_legislation_code = 'ES' then
PER_ES_DISABILITY.UPDATE_ES_DISABILITY
(P_CATEGORY => P_CATEGORY
,P_DEGREE => P_DEGREE
);
elsif l_legislation_code = 'GB' then
PER_GB_DISABILITY.VALIDATE_UPDATE_DISABILITY
(P_CATEGORY => P_CATEGORY
,P_DISABILITY_ID => P_DISABILITY_ID
,P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
);
elsif l_legislation_code = 'KW' then
HR_KW_VALIDATE_PKG.DISABILITY_VALIDATE
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_CATEGORY => P_CATEGORY
,P_DEGREE => P_DEGREE
,P_DIS_INFORMATION_CATEGORY => P_DIS_INFORMATION_CATEGORY
,P_DIS_INFORMATION1 => P_DIS_INFORMATION1
,P_DIS_INFORMATION2 => P_DIS_INFORMATION2
);
elsif l_legislation_code = 'PL' then
PER_PL_DISABILITY.UPDATE_PL_DISABILITY
(P_REASON => P_REASON
);
end if;
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'UPDATE_DISABILITY', 'BP');
hr_utility.set_location(' Leaving: PER_DISABILITY_API_BK2.UPDATE_DISABILITY_B', 20);
end UPDATE_DISABILITY_B;
end PER_DISABILITY_API_BK2;

/