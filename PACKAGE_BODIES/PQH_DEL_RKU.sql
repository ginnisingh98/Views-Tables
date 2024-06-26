--------------------------------------------------------
--  DDL for Package Body PQH_DEL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DEL_RKU" as
/* $Header: pqdelrhi.pkb 115.7 2002/12/05 19:31:43 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_DFLT_BUDGET_ELEMENT_ID in NUMBER
,P_DFLT_BUDGET_SET_ID in NUMBER
,P_ELEMENT_TYPE_ID in NUMBER
,P_DFLT_DIST_PERCENTAGE in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DFLT_BUDGET_SET_ID_O in NUMBER
,P_ELEMENT_TYPE_ID_O in NUMBER
,P_DFLT_DIST_PERCENTAGE_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DEL_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_DEL_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_DEL_RKU;

/
