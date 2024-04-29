--------------------------------------------------------
--  DDL for Package Body PER_EVT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EVT_RKI" as
/* $Header: peevtrhi.pkb 115.9 2003/06/04 13:23:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:10 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EVENT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LOCATION_ID in NUMBER
,P_INTERNAL_CONTACT_PERSON_ID in NUMBER
,P_ORGANIZATION_RUN_BY_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_DATE_START in DATE
,P_TYPE in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_CONTACT_TELEPHONE_NUMBER in VARCHAR2
,P_DATE_END in DATE
,P_EMP_OR_APL in VARCHAR2
,P_EVENT_OR_INTERVIEW in VARCHAR2
,P_EXTERNAL_CONTACT in VARCHAR2
,P_TIME_END in VARCHAR2
,P_TIME_START in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
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
,P_PARTY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_EVT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_EVT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_EVT_RKI;

/
