--------------------------------------------------------
--  DDL for Package Body PER_PJO_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJO_RKI" as
/* $Header: pepjorhi.pkb 120.0.12010000.2 2008/08/06 09:28:19 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:55 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_PREVIOUS_JOB_ID in NUMBER
,P_PREVIOUS_EMPLOYER_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_PERIOD_YEARS in NUMBER
,P_PERIOD_DAYS in NUMBER
,P_JOB_NAME in VARCHAR2
,P_EMPLOYMENT_CATEGORY in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_PJO_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PJO_ATTRIBUTE1 in VARCHAR2
,P_PJO_ATTRIBUTE2 in VARCHAR2
,P_PJO_ATTRIBUTE3 in VARCHAR2
,P_PJO_ATTRIBUTE4 in VARCHAR2
,P_PJO_ATTRIBUTE5 in VARCHAR2
,P_PJO_ATTRIBUTE6 in VARCHAR2
,P_PJO_ATTRIBUTE7 in VARCHAR2
,P_PJO_ATTRIBUTE8 in VARCHAR2
,P_PJO_ATTRIBUTE9 in VARCHAR2
,P_PJO_ATTRIBUTE10 in VARCHAR2
,P_PJO_ATTRIBUTE11 in VARCHAR2
,P_PJO_ATTRIBUTE12 in VARCHAR2
,P_PJO_ATTRIBUTE13 in VARCHAR2
,P_PJO_ATTRIBUTE14 in VARCHAR2
,P_PJO_ATTRIBUTE15 in VARCHAR2
,P_PJO_ATTRIBUTE16 in VARCHAR2
,P_PJO_ATTRIBUTE17 in VARCHAR2
,P_PJO_ATTRIBUTE18 in VARCHAR2
,P_PJO_ATTRIBUTE19 in VARCHAR2
,P_PJO_ATTRIBUTE20 in VARCHAR2
,P_PJO_ATTRIBUTE21 in VARCHAR2
,P_PJO_ATTRIBUTE22 in VARCHAR2
,P_PJO_ATTRIBUTE23 in VARCHAR2
,P_PJO_ATTRIBUTE24 in VARCHAR2
,P_PJO_ATTRIBUTE25 in VARCHAR2
,P_PJO_ATTRIBUTE26 in VARCHAR2
,P_PJO_ATTRIBUTE27 in VARCHAR2
,P_PJO_ATTRIBUTE28 in VARCHAR2
,P_PJO_ATTRIBUTE29 in VARCHAR2
,P_PJO_ATTRIBUTE30 in VARCHAR2
,P_PJO_INFORMATION_CATEGORY in VARCHAR2
,P_PJO_INFORMATION1 in VARCHAR2
,P_PJO_INFORMATION2 in VARCHAR2
,P_PJO_INFORMATION3 in VARCHAR2
,P_PJO_INFORMATION4 in VARCHAR2
,P_PJO_INFORMATION5 in VARCHAR2
,P_PJO_INFORMATION6 in VARCHAR2
,P_PJO_INFORMATION7 in VARCHAR2
,P_PJO_INFORMATION8 in VARCHAR2
,P_PJO_INFORMATION9 in VARCHAR2
,P_PJO_INFORMATION10 in VARCHAR2
,P_PJO_INFORMATION11 in VARCHAR2
,P_PJO_INFORMATION12 in VARCHAR2
,P_PJO_INFORMATION13 in VARCHAR2
,P_PJO_INFORMATION14 in VARCHAR2
,P_PJO_INFORMATION15 in VARCHAR2
,P_PJO_INFORMATION16 in VARCHAR2
,P_PJO_INFORMATION17 in VARCHAR2
,P_PJO_INFORMATION18 in VARCHAR2
,P_PJO_INFORMATION19 in VARCHAR2
,P_PJO_INFORMATION20 in VARCHAR2
,P_PJO_INFORMATION21 in VARCHAR2
,P_PJO_INFORMATION22 in VARCHAR2
,P_PJO_INFORMATION23 in VARCHAR2
,P_PJO_INFORMATION24 in VARCHAR2
,P_PJO_INFORMATION25 in VARCHAR2
,P_PJO_INFORMATION26 in VARCHAR2
,P_PJO_INFORMATION27 in VARCHAR2
,P_PJO_INFORMATION28 in VARCHAR2
,P_PJO_INFORMATION29 in VARCHAR2
,P_PJO_INFORMATION30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ALL_ASSIGNMENTS in VARCHAR2
,P_PERIOD_MONTHS in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_PJO_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_PJO_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_PJO_RKI;

/