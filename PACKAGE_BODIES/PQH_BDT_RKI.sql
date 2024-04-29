--------------------------------------------------------
--  DDL for Package Body PQH_BDT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDT_RKI" as
/* $Header: pqbdtrhi.pkb 120.0 2005/05/29 01:28:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:06 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_BUDGET_DETAIL_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_JOB_ID in NUMBER
,P_POSITION_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_BUDGET_VERSION_ID in NUMBER
,P_BUDGET_UNIT1_PERCENT in NUMBER
,P_BUDGET_UNIT1_VALUE_TYPE_CD in VARCHAR2
,P_BUDGET_UNIT1_VALUE in NUMBER
,P_BUDGET_UNIT1_AVAILABLE in NUMBER
,P_BUDGET_UNIT2_PERCENT in NUMBER
,P_BUDGET_UNIT2_VALUE_TYPE_CD in VARCHAR2
,P_BUDGET_UNIT2_VALUE in NUMBER
,P_BUDGET_UNIT2_AVAILABLE in NUMBER
,P_BUDGET_UNIT3_PERCENT in NUMBER
,P_BUDGET_UNIT3_VALUE_TYPE_CD in VARCHAR2
,P_BUDGET_UNIT3_VALUE in NUMBER
,P_BUDGET_UNIT3_AVAILABLE in NUMBER
,P_GL_STATUS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_BDT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_BDT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_BDT_RKI;

/