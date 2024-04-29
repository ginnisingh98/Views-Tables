--------------------------------------------------------
--  DDL for Package Body HR_RATE_VALUE_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RATE_VALUE_BK4" as
/* $Header: pypgrapi.pkb 115.0 2002/06/12 10:20:34 generated ship        $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 02/10/26 00:54:14 (YY/MM/DD HH:MM:SS)
procedure CREATE_ASSIGNMENT_RATE_VALUE_A
(P_EFFECTIVE_DATE in DATE
,P_GRADE_RULE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_RATE_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_RATE_TYPE in VARCHAR2
,P_CURRENCY_CODE in VARCHAR2
,P_VALUE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_RATE_VALUE_BK4.CREATE_ASSIGNMENT_RATE_VALUE_A', 10);
hr_utility.set_location(' Leaving: HR_RATE_VALUE_BK4.CREATE_ASSIGNMENT_RATE_VALUE_A', 20);
end CREATE_ASSIGNMENT_RATE_VALUE_A;
procedure CREATE_ASSIGNMENT_RATE_VALUE_B
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_RATE_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_RATE_TYPE in VARCHAR2
,P_CURRENCY_CODE in VARCHAR2
,P_VALUE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_RATE_VALUE_BK4.CREATE_ASSIGNMENT_RATE_VALUE_B', 10);
hr_utility.set_location(' Leaving: HR_RATE_VALUE_BK4.CREATE_ASSIGNMENT_RATE_VALUE_B', 20);
end CREATE_ASSIGNMENT_RATE_VALUE_B;
end HR_RATE_VALUE_BK4;

/
