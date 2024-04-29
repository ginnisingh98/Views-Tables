--------------------------------------------------------
--  DDL for Package Body PAY_EVQ_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVQ_RKI" as
/* $Header: pyevqrhi.pkb 120.0 2005/05/29 04:49:50 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:27:57 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EVENT_QUALIFIER_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_DATED_TABLE_ID in NUMBER
,P_COLUMN_NAME in VARCHAR2
,P_QUALIFIER_NAME in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_COMPARISON_COLUMN in VARCHAR2
,P_QUALIFIER_DEFINITION in VARCHAR2
,P_QUALIFIER_WHERE_CLAUSE in VARCHAR2
,P_ENTRY_QUALIFICATION in VARCHAR2
,P_ASSIGNMENT_QUALIFICATION in VARCHAR2
,P_MULTI_EVENT_SQL in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_EVQ_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PAY_EVQ_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_EVQ_RKI;

/