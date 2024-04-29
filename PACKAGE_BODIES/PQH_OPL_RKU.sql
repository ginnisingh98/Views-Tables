--------------------------------------------------------
--  DDL for Package Body PQH_OPL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_OPL_RKU" as
/* $Header: pqoplrhi.pkb 115.4 2002/12/03 00:09:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:25 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_OPERATION_ID in NUMBER
,P_OPERATION_NUMBER in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_OPERATION_NUMBER_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_OPL_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_OPL_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_OPL_RKU;

/