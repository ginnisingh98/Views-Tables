--------------------------------------------------------
--  DDL for Package Body PER_PSO_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSO_RKI" as
/* $Header: pepsorhi.pkb 115.1 2002/12/04 16:50:05 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:02 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ORGANIZATION_ID in NUMBER
,P_SECURITY_PROFILE_ID in NUMBER
,P_ENTRY_TYPE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_SECURITY_ORGANIZATION_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_PSO_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_PSO_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_PSO_RKI;

/