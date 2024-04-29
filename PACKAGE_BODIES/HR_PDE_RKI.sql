--------------------------------------------------------
--  DDL for Package Body HR_PDE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PDE_RKI" as
/* $Header: hrpderhi.pkb 120.0 2005/09/23 06:44 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PERSON_DEPLYMT_EIT_ID in NUMBER
,P_PERSON_DEPLOYMENT_ID in NUMBER
,P_PERSON_EXTRA_INFO_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_PDE_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HR_PDE_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HR_PDE_RKI;

/