--------------------------------------------------------
--  DDL for Package Body PQH_WFS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WFS_RKI" as
/* $Header: pqwfsrhi.pkb 115.7 2003/04/02 20:02:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:52 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_WORKSHEET_FUND_SRC_ID in NUMBER
,P_WORKSHEET_BDGT_ELMNT_ID in NUMBER
,P_DISTRIBUTION_PERCENTAGE in NUMBER
,P_COST_ALLOCATION_KEYFLEX_ID in NUMBER
,P_PROJECT_ID in NUMBER
,P_AWARD_ID in NUMBER
,P_TASK_ID in NUMBER
,P_EXPENDITURE_TYPE in VARCHAR2
,P_ORGANIZATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_WFS_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_WFS_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_WFS_RKI;

/