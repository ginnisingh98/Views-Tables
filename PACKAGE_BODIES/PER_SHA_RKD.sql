--------------------------------------------------------
--  DDL for Package Body PER_SHA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHA_RKD" as
/* $Header: pesharhi.pkb 115.6 2002/12/06 16:54:11 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:15 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_STD_HOLIDAY_ABSENCES_ID in NUMBER
,P_DATE_NOT_TAKEN_O in DATE
,P_PERSON_ID_O in NUMBER
,P_STANDARD_HOLIDAY_ID_O in NUMBER
,P_ACTUAL_DATE_TAKEN_O in DATE
,P_REASON_O in VARCHAR2
,P_EXPIRED_O in VARCHAR2
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
begin
hr_utility.set_location('Entering: PER_SHA_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_SHA_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_SHA_RKD;

/
