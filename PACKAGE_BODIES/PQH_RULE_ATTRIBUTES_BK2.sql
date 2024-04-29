--------------------------------------------------------
--  DDL for Package Body PQH_RULE_ATTRIBUTES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RULE_ATTRIBUTES_BK2" as
/* $Header: pqrlaapi.pkb 115.0 2003/01/26 01:52:15 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:36 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_RULE_ATTRIBUTE_A
(P_RULE_ATTRIBUTE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RULE_SET_ID in NUMBER
,P_ATTRIBUTE_CODE in VARCHAR2
,P_OPERATION_CODE in VARCHAR2
,P_ATTRIBUTE_VALUE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_RULE_ATTRIBUTES_BK2.UPDATE_RULE_ATTRIBUTE_A', 10);
hr_utility.set_location(' Leaving: PQH_RULE_ATTRIBUTES_BK2.UPDATE_RULE_ATTRIBUTE_A', 20);
end UPDATE_RULE_ATTRIBUTE_A;
procedure UPDATE_RULE_ATTRIBUTE_B
(P_RULE_ATTRIBUTE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RULE_SET_ID in NUMBER
,P_ATTRIBUTE_CODE in VARCHAR2
,P_OPERATION_CODE in VARCHAR2
,P_ATTRIBUTE_VALUE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_RULE_ATTRIBUTES_BK2.UPDATE_RULE_ATTRIBUTE_B', 10);
hr_utility.set_location(' Leaving: PQH_RULE_ATTRIBUTES_BK2.UPDATE_RULE_ATTRIBUTE_B', 20);
end UPDATE_RULE_ATTRIBUTE_B;
end PQH_RULE_ATTRIBUTES_BK2;

/