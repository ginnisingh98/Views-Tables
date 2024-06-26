--------------------------------------------------------
--  DDL for Package Body PER_PAT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PAT_RKI" as
/* $Header: pepatrhi.pkb 120.2 2005/10/27 07:56 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_ALLOCATED_TASK_ID in NUMBER
,P_ALLOCATED_CHECKLIST_ID in NUMBER
,P_TASK_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_PERFORMER_ORIG_SYSTEM in VARCHAR2
,P_PERFORMER_ORIG_SYS_ID in NUMBER
,P_TASK_OWNER_PERSON_ID in NUMBER
,P_TASK_SEQUENCE in NUMBER
,P_TARGET_START_DATE in DATE
,P_TARGET_END_DATE in DATE
,P_ACTUAL_START_DATE in DATE
,P_ACTUAL_END_DATE in DATE
,P_ACTION_URL in VARCHAR2
,P_MANDATORY_FLAG in VARCHAR2
,P_STATUS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
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
hr_utility.set_location('Entering: PER_PAT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_PAT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_PAT_RKI;

/
