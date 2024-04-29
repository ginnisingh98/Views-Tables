--------------------------------------------------------
--  DDL for Package Body PER_PAR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PAR_RKU" as
/* $Header: peparrhi.pkb 120.1 2007/06/20 07:48:26 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:55 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_PARTICIPANT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_QUESTIONNAIRE_TEMPLATE_ID in NUMBER
,P_PARTICIPATION_IN_TABLE in VARCHAR2
,P_PARTICIPATION_IN_COLUMN in VARCHAR2
,P_PARTICIPATION_IN_ID in NUMBER
,P_PARTICIPATION_STATUS in VARCHAR2
,P_PARTICIPATION_TYPE in VARCHAR2
,P_LAST_NOTIFIED_DATE in DATE
,P_DATE_COMPLETED in DATE
,P_COMMENTS in VARCHAR2
,P_PERSON_ID in NUMBER
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
,P_PARTICIPANT_USAGE_STATUS in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_QUESTIONNAIRE_TEMPLATE_ID_O in NUMBER
,P_PARTICIPATION_IN_TABLE_O in VARCHAR2
,P_PARTICIPATION_IN_COLUMN_O in VARCHAR2
,P_PARTICIPATION_IN_ID_O in NUMBER
,P_PARTICIPATION_STATUS_O in VARCHAR2
,P_PARTICIPATION_TYPE_O in VARCHAR2
,P_LAST_NOTIFIED_DATE_O in DATE
,P_DATE_COMPLETED_O in DATE
,P_COMMENTS_O in VARCHAR2
,P_PERSON_ID_O in NUMBER
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
,P_PARTICIPANT_USAGE_STATUS_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_PAR_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_PAR_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_PAR_RKU;

/