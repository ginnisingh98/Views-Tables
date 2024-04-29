--------------------------------------------------------
--  DDL for Package Body HR_DTY_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DTY_RKI" as
/* $Header: hrdtyrhi.pkb 120.0 2005/05/30 23:54:56 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:30:54 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_DOCUMENT_TYPE_ID in NUMBER
,P_CATEGORY_CODE in VARCHAR2
,P_SUB_CATEGORY_CODE in VARCHAR2
,P_ACTIVE_INACTIVE_FLAG in VARCHAR2
,P_MULTIPLE_OCCURENCES_FLAG in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_AUTHORIZATION_REQUIRED in VARCHAR2
,P_WARNING_PERIOD in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_DTY_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HR_DTY_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HR_DTY_RKI;

/