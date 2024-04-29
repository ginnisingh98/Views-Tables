--------------------------------------------------------
--  DDL for Package Body PQH_BUDGETS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGETS_BK2" as
/* $Header: pqbgtapi.pkb 120.1 2005/11/18 11:06:21 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:07 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_BUDGET_A
(P_BUDGET_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_START_ORGANIZATION_ID in NUMBER
,P_ORG_STRUCTURE_VERSION_ID in NUMBER
,P_BUDGETED_ENTITY_CD in VARCHAR2
,P_BUDGET_STYLE_CD in VARCHAR2
,P_BUDGET_NAME in VARCHAR2
,P_PERIOD_SET_NAME in VARCHAR2
,P_BUDGET_START_DATE in DATE
,P_BUDGET_END_DATE in DATE
,P_GL_BUDGET_NAME in VARCHAR2
,P_PSB_BUDGET_FLAG in VARCHAR2
,P_TRANSFER_TO_GL_FLAG in VARCHAR2
,P_TRANSFER_TO_GRANTS_FLAG in VARCHAR2
,P_STATUS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUDGET_UNIT1_ID in NUMBER
,P_BUDGET_UNIT2_ID in NUMBER
,P_BUDGET_UNIT3_ID in NUMBER
,P_GL_SET_OF_BOOKS_ID in NUMBER
,P_BUDGET_UNIT1_AGGREGATE in VARCHAR2
,P_BUDGET_UNIT2_AGGREGATE in VARCHAR2
,P_BUDGET_UNIT3_AGGREGATE in VARCHAR2
,P_POSITION_CONTROL_FLAG in VARCHAR2
,P_VALID_GRADE_REQD_FLAG in VARCHAR2
,P_CURRENCY_CODE in VARCHAR2
,P_DFLT_BUDGET_SET_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_BUDGETS_BK2.UPDATE_BUDGET_A', 10);
hr_utility.set_location(' Leaving: PQH_BUDGETS_BK2.UPDATE_BUDGET_A', 20);
end UPDATE_BUDGET_A;
procedure UPDATE_BUDGET_B
(P_BUDGET_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_START_ORGANIZATION_ID in NUMBER
,P_ORG_STRUCTURE_VERSION_ID in NUMBER
,P_BUDGETED_ENTITY_CD in VARCHAR2
,P_BUDGET_STYLE_CD in VARCHAR2
,P_BUDGET_NAME in VARCHAR2
,P_PERIOD_SET_NAME in VARCHAR2
,P_BUDGET_START_DATE in DATE
,P_BUDGET_END_DATE in DATE
,P_GL_BUDGET_NAME in VARCHAR2
,P_PSB_BUDGET_FLAG in VARCHAR2
,P_TRANSFER_TO_GL_FLAG in VARCHAR2
,P_TRANSFER_TO_GRANTS_FLAG in VARCHAR2
,P_STATUS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUDGET_UNIT1_ID in NUMBER
,P_BUDGET_UNIT2_ID in NUMBER
,P_BUDGET_UNIT3_ID in NUMBER
,P_GL_SET_OF_BOOKS_ID in NUMBER
,P_BUDGET_UNIT1_AGGREGATE in VARCHAR2
,P_BUDGET_UNIT2_AGGREGATE in VARCHAR2
,P_BUDGET_UNIT3_AGGREGATE in VARCHAR2
,P_POSITION_CONTROL_FLAG in VARCHAR2
,P_VALID_GRADE_REQD_FLAG in VARCHAR2
,P_CURRENCY_CODE in VARCHAR2
,P_DFLT_BUDGET_SET_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_BUDGETS_BK2.UPDATE_BUDGET_B', 10);
hr_utility.set_location(' Leaving: PQH_BUDGETS_BK2.UPDATE_BUDGET_B', 20);
end UPDATE_BUDGET_B;
end PQH_BUDGETS_BK2;

/
