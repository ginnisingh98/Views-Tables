--------------------------------------------------------
--  DDL for Package Body PER_CTC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTC_RKI" as
/* $Header: pectcrhi.pkb 115.20 2003/02/11 14:24:18 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:58:00 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_CONTRACT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PERSON_ID in NUMBER
,P_REFERENCE in VARCHAR2
,P_TYPE in VARCHAR2
,P_STATUS in VARCHAR2
,P_STATUS_REASON in VARCHAR2
,P_DOC_STATUS in VARCHAR2
,P_DOC_STATUS_CHANGE_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_DURATION in NUMBER
,P_DURATION_UNITS in VARCHAR2
,P_CONTRACTUAL_JOB_TITLE in VARCHAR2
,P_PARTIES in VARCHAR2
,P_START_REASON in VARCHAR2
,P_END_REASON in VARCHAR2
,P_NUMBER_OF_EXTENSIONS in NUMBER
,P_EXTENSION_REASON in VARCHAR2
,P_EXTENSION_PERIOD in NUMBER
,P_EXTENSION_PERIOD_UNITS in VARCHAR2
,P_CTR_INFORMATION_CATEGORY in VARCHAR2
,P_CTR_INFORMATION1 in VARCHAR2
,P_CTR_INFORMATION2 in VARCHAR2
,P_CTR_INFORMATION3 in VARCHAR2
,P_CTR_INFORMATION4 in VARCHAR2
,P_CTR_INFORMATION5 in VARCHAR2
,P_CTR_INFORMATION6 in VARCHAR2
,P_CTR_INFORMATION7 in VARCHAR2
,P_CTR_INFORMATION8 in VARCHAR2
,P_CTR_INFORMATION9 in VARCHAR2
,P_CTR_INFORMATION10 in VARCHAR2
,P_CTR_INFORMATION11 in VARCHAR2
,P_CTR_INFORMATION12 in VARCHAR2
,P_CTR_INFORMATION13 in VARCHAR2
,P_CTR_INFORMATION14 in VARCHAR2
,P_CTR_INFORMATION15 in VARCHAR2
,P_CTR_INFORMATION16 in VARCHAR2
,P_CTR_INFORMATION17 in VARCHAR2
,P_CTR_INFORMATION18 in VARCHAR2
,P_CTR_INFORMATION19 in VARCHAR2
,P_CTR_INFORMATION20 in VARCHAR2
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
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PER_CTC_RKI.AFTER_INSERT', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
PAY_DYT_CONTRACTS_PKG.AFTER_INSERT
(P_CONTRACT_ID => P_CONTRACT_ID
,P_EFFECTIVE_START_DATE => P_EFFECTIVE_START_DATE
,P_EFFECTIVE_END_DATE => P_EFFECTIVE_END_DATE
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
,P_PERSON_ID => P_PERSON_ID
,P_REFERENCE => P_REFERENCE
,P_TYPE => P_TYPE
,P_STATUS => P_STATUS
,P_STATUS_REASON => P_STATUS_REASON
,P_DOC_STATUS => P_DOC_STATUS
,P_DOC_STATUS_CHANGE_DATE => P_DOC_STATUS_CHANGE_DATE
,P_DESCRIPTION => P_DESCRIPTION
,P_DURATION => P_DURATION
,P_DURATION_UNITS => P_DURATION_UNITS
,P_CONTRACTUAL_JOB_TITLE => P_CONTRACTUAL_JOB_TITLE
,P_PARTIES => P_PARTIES
,P_START_REASON => P_START_REASON
,P_END_REASON => P_END_REASON
,P_NUMBER_OF_EXTENSIONS => P_NUMBER_OF_EXTENSIONS
,P_EXTENSION_REASON => P_EXTENSION_REASON
,P_EXTENSION_PERIOD => P_EXTENSION_PERIOD
,P_EXTENSION_PERIOD_UNITS => P_EXTENSION_PERIOD_UNITS
,P_CTR_INFORMATION_CATEGORY => P_CTR_INFORMATION_CATEGORY
,P_CTR_INFORMATION1 => P_CTR_INFORMATION1
,P_CTR_INFORMATION2 => P_CTR_INFORMATION2
,P_CTR_INFORMATION3 => P_CTR_INFORMATION3
,P_CTR_INFORMATION4 => P_CTR_INFORMATION4
,P_CTR_INFORMATION5 => P_CTR_INFORMATION5
,P_CTR_INFORMATION6 => P_CTR_INFORMATION6
,P_CTR_INFORMATION7 => P_CTR_INFORMATION7
,P_CTR_INFORMATION8 => P_CTR_INFORMATION8
,P_CTR_INFORMATION9 => P_CTR_INFORMATION9
,P_CTR_INFORMATION10 => P_CTR_INFORMATION10
,P_CTR_INFORMATION11 => P_CTR_INFORMATION11
,P_CTR_INFORMATION12 => P_CTR_INFORMATION12
,P_CTR_INFORMATION13 => P_CTR_INFORMATION13
,P_CTR_INFORMATION14 => P_CTR_INFORMATION14
,P_CTR_INFORMATION15 => P_CTR_INFORMATION15
,P_CTR_INFORMATION16 => P_CTR_INFORMATION16
,P_CTR_INFORMATION17 => P_CTR_INFORMATION17
,P_CTR_INFORMATION18 => P_CTR_INFORMATION18
,P_CTR_INFORMATION19 => P_CTR_INFORMATION19
,P_CTR_INFORMATION20 => P_CTR_INFORMATION20
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
,P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_VALIDATION_START_DATE => P_VALIDATION_START_DATE
,P_VALIDATION_END_DATE => P_VALIDATION_END_DATE
);
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'PER_CONTRACTS_F', 'AI');
hr_utility.set_location(' Leaving: PER_CTC_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_CTC_RKI;

/