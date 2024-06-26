--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET_POOLS_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET_POOLS_BK5" as
/* $Header: pqbplapi.pkb 115.7 2003/03/03 12:16:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:08 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_REALLOCATION_TXN_A
(P_TRANSACTION_ID in NUMBER
,P_NAME in VARCHAR2
,P_PARENT_FOLDER_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_BUDGET_POOLS_BK5.UPDATE_REALLOCATION_TXN_A', 10);
hr_utility.set_location(' Leaving: PQH_BUDGET_POOLS_BK5.UPDATE_REALLOCATION_TXN_A', 20);
end UPDATE_REALLOCATION_TXN_A;
procedure UPDATE_REALLOCATION_TXN_B
(P_TRANSACTION_ID in NUMBER
,P_NAME in VARCHAR2
,P_PARENT_FOLDER_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_BUDGET_POOLS_BK5.UPDATE_REALLOCATION_TXN_B', 10);
hr_utility.set_location(' Leaving: PQH_BUDGET_POOLS_BK5.UPDATE_REALLOCATION_TXN_B', 20);
end UPDATE_REALLOCATION_TXN_B;
end PQH_BUDGET_POOLS_BK5;

/
