--------------------------------------------------------
--  DDL for Package Body PER_ORG_STRUCTURE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORG_STRUCTURE_BK2" as
/* $Header: peorsapi.pkb 120.0 2005/10/22 01:24:14 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:29 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ORG_STRUCTURE_A
(P_VALIDATE in BOOLEAN
,P_EFFECTIVE_DATE in DATE
,P_ORGANIZATION_STRUCTURE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_NAME in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_PRIMARY_STRUCTURE_FLAG in VARCHAR2
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
,P_POSITION_CONTROL_STRUCTURE_F in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_ORG_STRUCTURE_BK2.UPDATE_ORG_STRUCTURE_A', 10);
hr_utility.set_location(' Leaving: PER_ORG_STRUCTURE_BK2.UPDATE_ORG_STRUCTURE_A', 20);
end UPDATE_ORG_STRUCTURE_A;
procedure UPDATE_ORG_STRUCTURE_B
(P_VALIDATE in BOOLEAN
,P_EFFECTIVE_DATE in DATE
,P_NAME in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_PRIMARY_STRUCTURE_FLAG in VARCHAR2
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
,P_ORGANIZATION_STRUCTURE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_POSITION_CONTROL_STRUCTURE_F in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_ORG_STRUCTURE_BK2.UPDATE_ORG_STRUCTURE_B', 10);
hr_utility.set_location(' Leaving: PER_ORG_STRUCTURE_BK2.UPDATE_ORG_STRUCTURE_B', 20);
end UPDATE_ORG_STRUCTURE_B;
end PER_ORG_STRUCTURE_BK2;

/
