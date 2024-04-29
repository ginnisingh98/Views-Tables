--------------------------------------------------------
--  DDL for Package Body PQH_BGT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BGT_RKU" as
/* $Header: pqbgtrhi.pkb 120.1 2005/09/21 03:11:10 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:07 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
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
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_START_ORGANIZATION_ID_O in NUMBER
,P_ORG_STRUCTURE_VERSION_ID_O in NUMBER
,P_BUDGETED_ENTITY_CD_O in VARCHAR2
,P_BUDGET_STYLE_CD_O in VARCHAR2
,P_BUDGET_NAME_O in VARCHAR2
,P_PERIOD_SET_NAME_O in VARCHAR2
,P_BUDGET_START_DATE_O in DATE
,P_BUDGET_END_DATE_O in DATE
,P_GL_BUDGET_NAME_O in VARCHAR2
,P_PSB_BUDGET_FLAG_O in VARCHAR2
,P_TRANSFER_TO_GL_FLAG_O in VARCHAR2
,P_TRANSFER_TO_GRANTS_FLAG_O in VARCHAR2
,P_STATUS_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_BUDGET_UNIT1_ID_O in NUMBER
,P_BUDGET_UNIT2_ID_O in NUMBER
,P_BUDGET_UNIT3_ID_O in NUMBER
,P_GL_SET_OF_BOOKS_ID_O in NUMBER
,P_BUDGET_UNIT1_AGGREGATE_O in VARCHAR2
,P_BUDGET_UNIT2_AGGREGATE_O in VARCHAR2
,P_BUDGET_UNIT3_AGGREGATE_O in VARCHAR2
,P_POSITION_CONTROL_FLAG_O in VARCHAR2
,P_VALID_GRADE_REQD_FLAG_O in VARCHAR2
,P_CURRENCY_CODE_O in VARCHAR2
,P_DFLT_BUDGET_SET_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_BGT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_BGT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_BGT_RKU;

/
