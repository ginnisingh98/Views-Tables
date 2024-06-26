--------------------------------------------------------
--  DDL for Package Body PQH_DE_OPERATION_GROUPS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_OPERATION_GROUPS_BK2" as
/* $Header: pqopgapi.pkb 115.1 2002/12/03 00:09:04 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:24 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_OPERATION_GROUPS_A
(P_EFFECTIVE_DATE in DATE
,P_OPERATION_GROUP_CODE in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_OPERATION_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DE_OPERATION_GROUPS_BK2.UPDATE_OPERATION_GROUPS_A', 10);
hr_utility.set_location(' Leaving: PQH_DE_OPERATION_GROUPS_BK2.UPDATE_OPERATION_GROUPS_A', 20);
end UPDATE_OPERATION_GROUPS_A;
procedure UPDATE_OPERATION_GROUPS_B
(P_EFFECTIVE_DATE in DATE
,P_OPERATION_GROUP_CODE in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_OPERATION_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DE_OPERATION_GROUPS_BK2.UPDATE_OPERATION_GROUPS_B', 10);
hr_utility.set_location(' Leaving: PQH_DE_OPERATION_GROUPS_BK2.UPDATE_OPERATION_GROUPS_B', 20);
end UPDATE_OPERATION_GROUPS_B;
end PQH_DE_OPERATION_GROUPS_BK2;

/
