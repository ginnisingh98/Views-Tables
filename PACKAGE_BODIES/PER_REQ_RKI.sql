--------------------------------------------------------
--  DDL for Package Body PER_REQ_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REQ_RKI" as
/* $Header: pereqrhi.pkb 120.0.12000000.2 2007/07/10 05:22:20 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2008/10/18 16:43:43 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_REQUISITION_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_DATE_FROM in DATE
,P_NAME in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_DATE_TO in DATE
,P_DESCRIPTION in VARCHAR2
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
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_REQ_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_REQ_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_REQ_RKI;

/
