--------------------------------------------------------
--  DDL for Package Body PQH_DFS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DFS_RKI" as
/* $Header: pqdfsrhi.pkb 115.11 2003/04/02 20:02:02 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_DFLT_FUND_SRC_ID in NUMBER
,P_DFLT_BUDGET_ELEMENT_ID in NUMBER
,P_DFLT_DIST_PERCENTAGE in NUMBER
,P_PROJECT_ID in NUMBER
,P_AWARD_ID in NUMBER
,P_TASK_ID in NUMBER
,P_EXPENDITURE_TYPE in VARCHAR2
,P_ORGANIZATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_COST_ALLOCATION_KEYFLEX_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DFS_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_DFS_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_DFS_RKI;

/