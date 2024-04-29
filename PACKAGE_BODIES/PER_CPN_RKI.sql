--------------------------------------------------------
--  DDL for Package Body PER_CPN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPN_RKI" as
/* $Header: pecpnrhi.pkb 120.0 2005/05/31 07:14:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:57:04 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_COMPETENCE_ID in NUMBER
,P_NAME in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_DATE_FROM in DATE
,P_DATE_TO in DATE
,P_BEHAVIOURAL_INDICATOR in VARCHAR2
,P_CERTIFICATION_REQUIRED in VARCHAR2
,P_EVALUATION_METHOD in VARCHAR2
,P_RENEWAL_PERIOD_FREQUENCY in NUMBER
,P_RENEWAL_PERIOD_UNITS in VARCHAR2
,P_MIN_LEVEL in NUMBER
,P_MAX_LEVEL in NUMBER
,P_RATING_SCALE_ID in NUMBER
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
,P_COMPETENCE_ALIAS in VARCHAR2
,P_COMPETENCE_DEFINITION_ID in NUMBER
,P_COMPETENCE_CLUSTER in VARCHAR2
,P_UNIT_STANDARD_ID in VARCHAR2
,P_CREDIT_TYPE in VARCHAR2
,P_CREDITS in NUMBER
,P_LEVEL_TYPE in VARCHAR2
,P_LEVEL_NUMBER in NUMBER
,P_FIELD in VARCHAR2
,P_SUB_FIELD in VARCHAR2
,P_PROVIDER in VARCHAR2
,P_QA_ORGANIZATION in VARCHAR2
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
)is
begin
hr_utility.set_location('Entering: PER_CPN_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_CPN_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_CPN_RKI;

/