--------------------------------------------------------
--  DDL for Package Body PER_REQUISITIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REQUISITIONS_BK1" as
/* $Header: pereqapi.pkb 115.8 2002/12/10 15:37:17 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:09 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_REQUISITION_A
(P_BUSINESS_GROUP_ID in NUMBER
,P_DATE_FROM in DATE
,P_NAME in VARCHAR2
,P_PERSON_ID in NUMBER
,P_COMMENTS in VARCHAR2
,P_DATE_TO in DATE
,P_DESCRIPTION in VARCHAR2
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
,P_REQUISITION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PER_REQUISITIONS_BK1.CREATE_REQUISITION_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
per_requisitions_be1.CREATE_REQUISITION_A
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_DATE_FROM => P_DATE_FROM
,P_NAME => P_NAME
,P_PERSON_ID => P_PERSON_ID
,P_COMMENTS => P_COMMENTS
,P_DATE_TO => P_DATE_TO
,P_DESCRIPTION => P_DESCRIPTION
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
,P_REQUISITION_ID => P_REQUISITION_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_REQUISITION', 'AP');
hr_utility.set_location(' Leaving: PER_REQUISITIONS_BK1.CREATE_REQUISITION_A', 20);
end CREATE_REQUISITION_A;
procedure CREATE_REQUISITION_B
(P_BUSINESS_GROUP_ID in NUMBER
,P_DATE_FROM in DATE
,P_NAME in VARCHAR2
,P_PERSON_ID in NUMBER
,P_COMMENTS in VARCHAR2
,P_DATE_TO in DATE
,P_DESCRIPTION in VARCHAR2
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
hr_utility.set_location('Entering: PER_REQUISITIONS_BK1.CREATE_REQUISITION_B', 10);
hr_utility.set_location(' Leaving: PER_REQUISITIONS_BK1.CREATE_REQUISITION_B', 20);
end CREATE_REQUISITION_B;
end PER_REQUISITIONS_BK1;

/
