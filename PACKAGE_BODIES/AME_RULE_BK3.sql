--------------------------------------------------------
--  DDL for Package Body AME_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RULE_BK3" as
/* $Header: amrulapi.pkb 120.4 2005/10/21 06:52:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:39 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_AME_RULE_A
(P_RULE_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: AME_RULE_BK3.UPDATE_AME_RULE_A', 10);
hr_utility.set_location(' Leaving: AME_RULE_BK3.UPDATE_AME_RULE_A', 20);
end UPDATE_AME_RULE_A;
procedure UPDATE_AME_RULE_B
(P_RULE_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: AME_RULE_BK3.UPDATE_AME_RULE_B', 10);
hr_utility.set_location(' Leaving: AME_RULE_BK3.UPDATE_AME_RULE_B', 20);
end UPDATE_AME_RULE_B;
end AME_RULE_BK3;

/
