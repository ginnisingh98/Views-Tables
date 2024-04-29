--------------------------------------------------------
--  DDL for Package Body HR_ELECTIONS_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ELECTIONS_API_BK1" as
/* $Header: peelcapi.pkb 120.0 2005/10/02 02:15:24 generated $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:04 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ELECTION_INFORMATION_A
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_ELECTION_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_REP_BODY_ID in NUMBER
,P_PREVIOUS_ELECTION_DATE in DATE
,P_NEXT_ELECTION_DATE in DATE
,P_RESULT_PUBLISH_DATE in DATE
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
,P_ELECTION_INFO_CATEGORY in VARCHAR2
,P_ELECTION_INFORMATION1 in VARCHAR2
,P_ELECTION_INFORMATION2 in VARCHAR2
,P_ELECTION_INFORMATION3 in VARCHAR2
,P_ELECTION_INFORMATION4 in VARCHAR2
,P_ELECTION_INFORMATION5 in VARCHAR2
,P_ELECTION_INFORMATION6 in VARCHAR2
,P_ELECTION_INFORMATION7 in VARCHAR2
,P_ELECTION_INFORMATION8 in VARCHAR2
,P_ELECTION_INFORMATION9 in VARCHAR2
,P_ELECTION_INFORMATION10 in VARCHAR2
,P_ELECTION_INFORMATION11 in VARCHAR2
,P_ELECTION_INFORMATION12 in VARCHAR2
,P_ELECTION_INFORMATION13 in VARCHAR2
,P_ELECTION_INFORMATION14 in VARCHAR2
,P_ELECTION_INFORMATION15 in VARCHAR2
,P_ELECTION_INFORMATION16 in VARCHAR2
,P_ELECTION_INFORMATION17 in VARCHAR2
,P_ELECTION_INFORMATION18 in VARCHAR2
,P_ELECTION_INFORMATION19 in VARCHAR2
,P_ELECTION_INFORMATION20 in VARCHAR2
,P_ELECTION_INFORMATION21 in VARCHAR2
,P_ELECTION_INFORMATION22 in VARCHAR2
,P_ELECTION_INFORMATION23 in VARCHAR2
,P_ELECTION_INFORMATION24 in VARCHAR2
,P_ELECTION_INFORMATION25 in VARCHAR2
,P_ELECTION_INFORMATION26 in VARCHAR2
,P_ELECTION_INFORMATION27 in VARCHAR2
,P_ELECTION_INFORMATION28 in VARCHAR2
,P_ELECTION_INFORMATION29 in VARCHAR2
,P_ELECTION_INFORMATION30 in VARCHAR2
,P_ELECTION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_ELECTIONS_API_BK1.CREATE_ELECTION_INFORMATION_A', 10);
hr_utility.set_location(' Leaving: HR_ELECTIONS_API_BK1.CREATE_ELECTION_INFORMATION_A', 20);
end CREATE_ELECTION_INFORMATION_A;
procedure CREATE_ELECTION_INFORMATION_B
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_ELECTION_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_REP_BODY_ID in NUMBER
,P_PREVIOUS_ELECTION_DATE in DATE
,P_NEXT_ELECTION_DATE in DATE
,P_RESULT_PUBLISH_DATE in DATE
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
,P_ELECTION_INFO_CATEGORY in VARCHAR2
,P_ELECTION_INFORMATION1 in VARCHAR2
,P_ELECTION_INFORMATION2 in VARCHAR2
,P_ELECTION_INFORMATION3 in VARCHAR2
,P_ELECTION_INFORMATION4 in VARCHAR2
,P_ELECTION_INFORMATION5 in VARCHAR2
,P_ELECTION_INFORMATION6 in VARCHAR2
,P_ELECTION_INFORMATION7 in VARCHAR2
,P_ELECTION_INFORMATION8 in VARCHAR2
,P_ELECTION_INFORMATION9 in VARCHAR2
,P_ELECTION_INFORMATION10 in VARCHAR2
,P_ELECTION_INFORMATION11 in VARCHAR2
,P_ELECTION_INFORMATION12 in VARCHAR2
,P_ELECTION_INFORMATION13 in VARCHAR2
,P_ELECTION_INFORMATION14 in VARCHAR2
,P_ELECTION_INFORMATION15 in VARCHAR2
,P_ELECTION_INFORMATION16 in VARCHAR2
,P_ELECTION_INFORMATION17 in VARCHAR2
,P_ELECTION_INFORMATION18 in VARCHAR2
,P_ELECTION_INFORMATION19 in VARCHAR2
,P_ELECTION_INFORMATION20 in VARCHAR2
,P_ELECTION_INFORMATION21 in VARCHAR2
,P_ELECTION_INFORMATION22 in VARCHAR2
,P_ELECTION_INFORMATION23 in VARCHAR2
,P_ELECTION_INFORMATION24 in VARCHAR2
,P_ELECTION_INFORMATION25 in VARCHAR2
,P_ELECTION_INFORMATION26 in VARCHAR2
,P_ELECTION_INFORMATION27 in VARCHAR2
,P_ELECTION_INFORMATION28 in VARCHAR2
,P_ELECTION_INFORMATION29 in VARCHAR2
,P_ELECTION_INFORMATION30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_ELECTIONS_API_BK1.CREATE_ELECTION_INFORMATION_B', 10);
hr_utility.set_location(' Leaving: HR_ELECTIONS_API_BK1.CREATE_ELECTION_INFORMATION_B', 20);
end CREATE_ELECTION_INFORMATION_B;
end HR_ELECTIONS_API_BK1;

/
