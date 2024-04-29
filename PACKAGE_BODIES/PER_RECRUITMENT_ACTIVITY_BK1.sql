--------------------------------------------------------
--  DDL for Package Body PER_RECRUITMENT_ACTIVITY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RECRUITMENT_ACTIVITY_BK1" as
/* $Header: peraaapi.pkb 115.9 2003/11/21 02:04:08 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:06 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_RECRUITMENT_ACTIVITY_A
(P_BUSINESS_GROUP_ID in NUMBER
,P_AUTHORISING_PERSON_ID in NUMBER
,P_RUN_BY_ORGANIZATION_ID in NUMBER
,P_INTERNAL_CONTACT_PERSON_ID in NUMBER
,P_PARENT_RECRUITMENT_ACTIVITY in NUMBER
,P_CURRENCY_CODE in VARCHAR2
,P_DATE_START in DATE
,P_NAME in VARCHAR2
,P_ACTUAL_COST in VARCHAR2
,P_COMMENTS in LONG
,P_CONTACT_TELEPHONE_NUMBER in VARCHAR2
,P_DATE_CLOSING in DATE
,P_DATE_END in DATE
,P_EXTERNAL_CONTACT in VARCHAR2
,P_PLANNED_COST in VARCHAR2
,P_RECRUITING_SITE_ID in NUMBER
,P_RECRUITING_SITE_RESPONSE in VARCHAR2
,P_LAST_POSTED_DATE in DATE
,P_TYPE in VARCHAR2
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
,P_POSTING_CONTENT_ID in NUMBER
,P_STATUS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RECRUITMENT_ACTIVITY_ID in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PER_RECRUITMENT_ACTIVITY_BK1.CREATE_RECRUITMENT_ACTIVITY_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
per_recruitment_activity_be1.CREATE_RECRUITMENT_ACTIVITY_A
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_AUTHORISING_PERSON_ID => P_AUTHORISING_PERSON_ID
,P_RUN_BY_ORGANIZATION_ID => P_RUN_BY_ORGANIZATION_ID
,P_INTERNAL_CONTACT_PERSON_ID => P_INTERNAL_CONTACT_PERSON_ID
,P_PARENT_RECRUITMENT_ACTIVITY => P_PARENT_RECRUITMENT_ACTIVITY
,P_CURRENCY_CODE => P_CURRENCY_CODE
,P_DATE_START => P_DATE_START
,P_NAME => P_NAME
,P_ACTUAL_COST => P_ACTUAL_COST
,P_COMMENTS => P_COMMENTS
,P_CONTACT_TELEPHONE_NUMBER => P_CONTACT_TELEPHONE_NUMBER
,P_DATE_CLOSING => P_DATE_CLOSING
,P_DATE_END => P_DATE_END
,P_EXTERNAL_CONTACT => P_EXTERNAL_CONTACT
,P_PLANNED_COST => P_PLANNED_COST
,P_RECRUITING_SITE_ID => P_RECRUITING_SITE_ID
,P_RECRUITING_SITE_RESPONSE => P_RECRUITING_SITE_RESPONSE
,P_LAST_POSTED_DATE => P_LAST_POSTED_DATE
,P_TYPE => P_TYPE
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
,P_POSTING_CONTENT_ID => P_POSTING_CONTENT_ID
,P_STATUS => P_STATUS
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
,P_RECRUITMENT_ACTIVITY_ID => P_RECRUITMENT_ACTIVITY_ID
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_RECRUITMENT_ACTIVITY', 'AP');
hr_utility.set_location(' Leaving: PER_RECRUITMENT_ACTIVITY_BK1.CREATE_RECRUITMENT_ACTIVITY_A', 20);
end CREATE_RECRUITMENT_ACTIVITY_A;
procedure CREATE_RECRUITMENT_ACTIVITY_B
(P_BUSINESS_GROUP_ID in NUMBER
,P_AUTHORISING_PERSON_ID in NUMBER
,P_RUN_BY_ORGANIZATION_ID in NUMBER
,P_INTERNAL_CONTACT_PERSON_ID in NUMBER
,P_PARENT_RECRUITMENT_ACTIVITY in NUMBER
,P_CURRENCY_CODE in VARCHAR2
,P_DATE_START in DATE
,P_NAME in VARCHAR2
,P_ACTUAL_COST in VARCHAR2
,P_COMMENTS in LONG
,P_CONTACT_TELEPHONE_NUMBER in VARCHAR2
,P_DATE_CLOSING in DATE
,P_DATE_END in DATE
,P_EXTERNAL_CONTACT in VARCHAR2
,P_PLANNED_COST in VARCHAR2
,P_RECRUITING_SITE_ID in NUMBER
,P_RECRUITING_SITE_RESPONSE in VARCHAR2
,P_LAST_POSTED_DATE in DATE
,P_TYPE in VARCHAR2
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
,P_POSTING_CONTENT_ID in NUMBER
,P_STATUS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_RECRUITMENT_ACTIVITY_BK1.CREATE_RECRUITMENT_ACTIVITY_B', 10);
hr_utility.set_location(' Leaving: PER_RECRUITMENT_ACTIVITY_BK1.CREATE_RECRUITMENT_ACTIVITY_B', 20);
end CREATE_RECRUITMENT_ACTIVITY_B;
end PER_RECRUITMENT_ACTIVITY_BK1;

/
