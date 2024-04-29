--------------------------------------------------------
--  DDL for Package Body PQH_COPY_ENTITY_PREFS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COPY_ENTITY_PREFS_BK1" as
/* $Header: pqcepapi.pkb 115.3 2002/12/05 19:31:15 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:12 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_COPY_ENTITY_PREF_A
(P_COPY_ENTITY_PREF_ID in NUMBER
,P_TABLE_ROUTE_ID in NUMBER
,P_COPY_ENTITY_TXN_ID in NUMBER
,P_SELECT_FLAG in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_COPY_ENTITY_PREFS_BK1.CREATE_COPY_ENTITY_PREF_A', 10);
hr_utility.set_location(' Leaving: PQH_COPY_ENTITY_PREFS_BK1.CREATE_COPY_ENTITY_PREF_A', 20);
end CREATE_COPY_ENTITY_PREF_A;
procedure CREATE_COPY_ENTITY_PREF_B
(P_TABLE_ROUTE_ID in NUMBER
,P_COPY_ENTITY_TXN_ID in NUMBER
,P_SELECT_FLAG in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_COPY_ENTITY_PREFS_BK1.CREATE_COPY_ENTITY_PREF_B', 10);
hr_utility.set_location(' Leaving: PQH_COPY_ENTITY_PREFS_BK1.CREATE_COPY_ENTITY_PREF_B', 20);
end CREATE_COPY_ENTITY_PREF_B;
end PQH_COPY_ENTITY_PREFS_BK1;

/