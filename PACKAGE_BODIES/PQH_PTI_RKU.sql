--------------------------------------------------------
--  DDL for Package Body PQH_PTI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTI_RKU" as
/* $Header: pqptirhi.pkb 120.2 2005/10/12 20:18:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:28 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_INFORMATION_TYPE in VARCHAR2
,P_ACTIVE_INACTIVE_FLAG in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_MULTIPLE_OCCURENCES_FLAG in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_ACTIVE_INACTIVE_FLAG_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_MULTIPLE_OCCURENCES_FLAG_O in VARCHAR2
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_PTI_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_PTI_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_PTI_RKU;

/