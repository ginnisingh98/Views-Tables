--------------------------------------------------------
--  DDL for Package Body PQH_BGM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BGM_RKU" as
/* $Header: pqbgmrhi.pkb 115.3 2002/12/05 16:33:25 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:07 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_BUDGET_GL_FLEX_MAP_ID in NUMBER
,P_BUDGET_ID in NUMBER
,P_GL_ACCOUNT_SEGMENT in VARCHAR2
,P_PAYROLL_COST_SEGMENT in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUDGET_ID_O in NUMBER
,P_GL_ACCOUNT_SEGMENT_O in VARCHAR2
,P_PAYROLL_COST_SEGMENT_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_BGM_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_BGM_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_BGM_RKU;

/