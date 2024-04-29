--------------------------------------------------------
--  DDL for Package Body PER_ESA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ESA_RKI" as
/* $Header: peesarhi.pkb 120.0.12010000.3 2008/08/06 09:08:49 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:54 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ATTENDANCE_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_ESTABLISHMENT_ID in NUMBER
,P_ESTABLISHMENT in VARCHAR2
,P_ATTENDED_START_DATE in DATE
,P_ATTENDED_END_DATE in DATE
,P_FULL_TIME in VARCHAR2
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
,P_BUSINESS_GROUP_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_PARTY_ID in NUMBER
,P_ADDRESS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_ESA_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_ESA_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_ESA_RKI;

/