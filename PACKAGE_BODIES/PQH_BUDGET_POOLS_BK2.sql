--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET_POOLS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET_POOLS_BK2" as
/* $Header: pqbplapi.pkb 115.7 2003/03/03 12:16:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:08 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_REALLOCATION_FOLDER_A
(P_FOLDER_ID in NUMBER
,P_NAME in VARCHAR2
,P_BUDGET_VERSION_ID in NUMBER
,P_BUDGET_UNIT_ID in NUMBER
,P_ENTITY_TYPE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_APPROVAL_STATUS in VARCHAR2
,P_WF_TRANSACTION_CATEGORY_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_BUDGET_POOLS_BK2.UPDATE_REALLOCATION_FOLDER_A', 10);
hr_utility.set_location(' Leaving: PQH_BUDGET_POOLS_BK2.UPDATE_REALLOCATION_FOLDER_A', 20);
end UPDATE_REALLOCATION_FOLDER_A;
procedure UPDATE_REALLOCATION_FOLDER_B
(P_FOLDER_ID in NUMBER
,P_NAME in VARCHAR2
,P_BUDGET_VERSION_ID in NUMBER
,P_BUDGET_UNIT_ID in NUMBER
,P_ENTITY_TYPE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_APPROVAL_STATUS in VARCHAR2
,P_WF_TRANSACTION_CATEGORY_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_BUDGET_POOLS_BK2.UPDATE_REALLOCATION_FOLDER_B', 10);
hr_utility.set_location(' Leaving: PQH_BUDGET_POOLS_BK2.UPDATE_REALLOCATION_FOLDER_B', 20);
end UPDATE_REALLOCATION_FOLDER_B;
end PQH_BUDGET_POOLS_BK2;

/
