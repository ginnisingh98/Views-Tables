--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION_BK3" as
/* $Header: hrorgapi.pkb 120.10.12010000.8 2009/04/14 09:44:53 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:18 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ORGANIZATION_A
(P_EFFECTIVE_DATE in DATE
,P_LANGUAGE_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_DATE_FROM in DATE
,P_NAME in VARCHAR2
,P_LOCATION_ID in NUMBER
,P_DATE_TO in DATE
,P_INTERNAL_EXTERNAL_FLAG in VARCHAR2
,P_INTERNAL_ADDRESS_LINE in VARCHAR2
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
,P_ORGANIZATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DUPLICATE_ORG_WARNING in BOOLEAN
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_ORGANIZATION_BK3.CREATE_ORGANIZATION_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
hr_organization_be3.CREATE_ORGANIZATION_A
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_LANGUAGE_CODE => P_LANGUAGE_CODE
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_DATE_FROM => P_DATE_FROM
,P_NAME => P_NAME
,P_LOCATION_ID => P_LOCATION_ID
,P_DATE_TO => P_DATE_TO
,P_INTERNAL_EXTERNAL_FLAG => P_INTERNAL_EXTERNAL_FLAG
,P_INTERNAL_ADDRESS_LINE => P_INTERNAL_ADDRESS_LINE
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
,P_ATTRIBUTE21 => P_ATTRIBUTE21
,P_ATTRIBUTE22 => P_ATTRIBUTE22
,P_ATTRIBUTE23 => P_ATTRIBUTE23
,P_ATTRIBUTE24 => P_ATTRIBUTE24
,P_ATTRIBUTE25 => P_ATTRIBUTE25
,P_ATTRIBUTE26 => P_ATTRIBUTE26
,P_ATTRIBUTE27 => P_ATTRIBUTE27
,P_ATTRIBUTE28 => P_ATTRIBUTE28
,P_ATTRIBUTE29 => P_ATTRIBUTE29
,P_ATTRIBUTE30 => P_ATTRIBUTE30
,P_ORGANIZATION_ID => P_ORGANIZATION_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
,P_DUPLICATE_ORG_WARNING => P_DUPLICATE_ORG_WARNING
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_ORGANIZATION', 'AP');
hr_utility.set_location(' Leaving: HR_ORGANIZATION_BK3.CREATE_ORGANIZATION_A', 20);
end CREATE_ORGANIZATION_A;
procedure CREATE_ORGANIZATION_B
(P_EFFECTIVE_DATE in DATE
,P_LANGUAGE_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_DATE_FROM in DATE
,P_NAME in VARCHAR2
,P_LOCATION_ID in NUMBER
,P_DATE_TO in DATE
,P_INTERNAL_EXTERNAL_FLAG in VARCHAR2
,P_INTERNAL_ADDRESS_LINE in VARCHAR2
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
)is
begin
hr_utility.set_location('Entering: HR_ORGANIZATION_BK3.CREATE_ORGANIZATION_B', 10);
hr_utility.set_location(' Leaving: HR_ORGANIZATION_BK3.CREATE_ORGANIZATION_B', 20);
end CREATE_ORGANIZATION_B;
end HR_ORGANIZATION_BK3;

/