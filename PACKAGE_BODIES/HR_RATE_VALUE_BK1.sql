--------------------------------------------------------
--  DDL for Package Body HR_RATE_VALUE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RATE_VALUE_BK1" as
/* $Header: pypgrapi.pkb 120.0 2005/10/02 02:32:48 generated $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:08 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_RATE_VALUE_A
(P_EFFECTIVE_DATE in DATE
,P_GRADE_RULE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_RATE_ID in NUMBER
,P_GRADE_OR_SPINAL_POINT_ID in NUMBER
,P_RATE_TYPE in VARCHAR2
,P_CURRENCY_CODE in VARCHAR2
,P_MAXIMUM in VARCHAR2
,P_MID_VALUE in VARCHAR2
,P_MINIMUM in VARCHAR2
,P_SEQUENCE in NUMBER
,P_VALUE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_RATE_VALUE_BK1.CREATE_RATE_VALUE_A', 10);
hr_utility.set_location(' Leaving: HR_RATE_VALUE_BK1.CREATE_RATE_VALUE_A', 20);
end CREATE_RATE_VALUE_A;
procedure CREATE_RATE_VALUE_B
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_RATE_ID in NUMBER
,P_GRADE_OR_SPINAL_POINT_ID in NUMBER
,P_RATE_TYPE in VARCHAR2
,P_CURRENCY_CODE in VARCHAR2
,P_MAXIMUM in VARCHAR2
,P_MID_VALUE in VARCHAR2
,P_MINIMUM in VARCHAR2
,P_SEQUENCE in NUMBER
,P_VALUE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_RATE_VALUE_BK1.CREATE_RATE_VALUE_B', 10);
hr_utility.set_location(' Leaving: HR_RATE_VALUE_BK1.CREATE_RATE_VALUE_B', 20);
end CREATE_RATE_VALUE_B;
end HR_RATE_VALUE_BK1;

/
