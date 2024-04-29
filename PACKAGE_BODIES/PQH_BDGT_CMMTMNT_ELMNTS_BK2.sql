--------------------------------------------------------
--  DDL for Package Body PQH_BDGT_CMMTMNT_ELMNTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDGT_CMMTMNT_ELMNTS_BK2" as
/* $Header: pqbceapi.pkb 115.5 2004/04/28 17:26:35 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:05 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_BDGT_CMMTMNT_ELMNT_A
(P_BDGT_CMMTMNT_ELMNT_ID in NUMBER
,P_BUDGET_ID in NUMBER
,P_ACTUAL_COMMITMENT_TYPE in VARCHAR2
,P_ELEMENT_TYPE_ID in NUMBER
,P_SALARY_BASIS_FLAG in VARCHAR2
,P_ELEMENT_INPUT_VALUE_ID in NUMBER
,P_BALANCE_TYPE_ID in NUMBER
,P_FREQUENCY_INPUT_VALUE_ID in NUMBER
,P_FORMULA_ID in NUMBER
,P_DFLT_ELMNT_FREQUENCY in VARCHAR2
,P_OVERHEAD_PERCENTAGE in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_BDGT_CMMTMNT_ELMNTS_BK2.UPDATE_BDGT_CMMTMNT_ELMNT_A', 10);
hr_utility.set_location(' Leaving: PQH_BDGT_CMMTMNT_ELMNTS_BK2.UPDATE_BDGT_CMMTMNT_ELMNT_A', 20);
end UPDATE_BDGT_CMMTMNT_ELMNT_A;
procedure UPDATE_BDGT_CMMTMNT_ELMNT_B
(P_BDGT_CMMTMNT_ELMNT_ID in NUMBER
,P_BUDGET_ID in NUMBER
,P_ACTUAL_COMMITMENT_TYPE in VARCHAR2
,P_ELEMENT_TYPE_ID in NUMBER
,P_SALARY_BASIS_FLAG in VARCHAR2
,P_ELEMENT_INPUT_VALUE_ID in NUMBER
,P_BALANCE_TYPE_ID in NUMBER
,P_FREQUENCY_INPUT_VALUE_ID in NUMBER
,P_FORMULA_ID in NUMBER
,P_DFLT_ELMNT_FREQUENCY in VARCHAR2
,P_OVERHEAD_PERCENTAGE in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_BDGT_CMMTMNT_ELMNTS_BK2.UPDATE_BDGT_CMMTMNT_ELMNT_B', 10);
hr_utility.set_location(' Leaving: PQH_BDGT_CMMTMNT_ELMNTS_BK2.UPDATE_BDGT_CMMTMNT_ELMNT_B', 20);
end UPDATE_BDGT_CMMTMNT_ELMNT_B;
end PQH_BDGT_CMMTMNT_ELMNTS_BK2;

/
