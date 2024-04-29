--------------------------------------------------------
--  DDL for Package Body PQH_BEL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BEL_RKU" as
/* $Header: pqbelrhi.pkb 115.6 2002/12/05 16:33:15 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:06 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_BUDGET_ELEMENT_ID in NUMBER
,P_BUDGET_SET_ID in NUMBER
,P_ELEMENT_TYPE_ID in NUMBER
,P_DISTRIBUTION_PERCENTAGE in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUDGET_SET_ID_O in NUMBER
,P_ELEMENT_TYPE_ID_O in NUMBER
,P_DISTRIBUTION_PERCENTAGE_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_BEL_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_BEL_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_BEL_RKU;

/
