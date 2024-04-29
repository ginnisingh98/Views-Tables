--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDDEF_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDDEF_BK2" as
/* $Header: pqdefapi.pkb 115.1 2002/12/09 22:40:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:19 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_VLDTN_DEFN_A
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_VALIDATION_NAME in VARCHAR2
,P_EMPLOYMENT_TYPE in VARCHAR2
,P_REMUNERATION_REGULATION in VARCHAR2
,P_WRKPLC_VLDTN_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DE_VLDDEF_BK2.UPDATE_VLDTN_DEFN_A', 10);
hr_utility.set_location(' Leaving: PQH_DE_VLDDEF_BK2.UPDATE_VLDTN_DEFN_A', 20);
end UPDATE_VLDTN_DEFN_A;
procedure UPDATE_VLDTN_DEFN_B
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_VALIDATION_NAME in VARCHAR2
,P_EMPLOYMENT_TYPE in VARCHAR2
,P_REMUNERATION_REGULATION in VARCHAR2
,P_WRKPLC_VLDTN_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DE_VLDDEF_BK2.UPDATE_VLDTN_DEFN_B', 10);
hr_utility.set_location(' Leaving: PQH_DE_VLDDEF_BK2.UPDATE_VLDTN_DEFN_B', 20);
end UPDATE_VLDTN_DEFN_B;
end PQH_DE_VLDDEF_BK2;

/
