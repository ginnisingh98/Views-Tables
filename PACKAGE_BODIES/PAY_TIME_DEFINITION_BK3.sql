--------------------------------------------------------
--  DDL for Package Body PAY_TIME_DEFINITION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TIME_DEFINITION_BK3" as
/* $Header: pytdfapi.pkb 120.3 2005/09/21 03:56:23 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:27 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_TIME_DEFINITION_A
(P_EFFECTIVE_DATE in DATE
,P_TIME_DEFINITION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_TIME_DEFINITION_BK3.DELETE_TIME_DEFINITION_A', 10);
hr_utility.set_location(' Leaving: PAY_TIME_DEFINITION_BK3.DELETE_TIME_DEFINITION_A', 20);
end DELETE_TIME_DEFINITION_A;
procedure DELETE_TIME_DEFINITION_B
(P_EFFECTIVE_DATE in DATE
,P_TIME_DEFINITION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_TIME_DEFINITION_BK3.DELETE_TIME_DEFINITION_B', 10);
hr_utility.set_location(' Leaving: PAY_TIME_DEFINITION_BK3.DELETE_TIME_DEFINITION_B', 20);
end DELETE_TIME_DEFINITION_B;
end PAY_TIME_DEFINITION_BK3;

/