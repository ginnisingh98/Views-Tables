--------------------------------------------------------
--  DDL for Package Body HR_SECURITY_ORGANIZATION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SECURITY_ORGANIZATION_BK2" as
/* $Header: pepsoapi.pkb 115.1 2002/12/11 12:15:36 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:56 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_SECURITY_ORGANIZATION_A
(P_ORGANIZATION_ID in NUMBER
,P_SECURITY_PROFILE_ID in NUMBER
,P_ENTRY_TYPE in VARCHAR2
,P_SECURITY_ORGANIZATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_SECURITY_ORGANIZATION_BK2.UPDATE_SECURITY_ORGANIZATION_A', 10);
hr_utility.set_location(' Leaving: HR_SECURITY_ORGANIZATION_BK2.UPDATE_SECURITY_ORGANIZATION_A', 20);
end UPDATE_SECURITY_ORGANIZATION_A;
procedure UPDATE_SECURITY_ORGANIZATION_B
(P_ORGANIZATION_ID in NUMBER
,P_SECURITY_PROFILE_ID in NUMBER
,P_ENTRY_TYPE in VARCHAR2
,P_SECURITY_ORGANIZATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_SECURITY_ORGANIZATION_BK2.UPDATE_SECURITY_ORGANIZATION_B', 10);
hr_utility.set_location(' Leaving: HR_SECURITY_ORGANIZATION_BK2.UPDATE_SECURITY_ORGANIZATION_B', 20);
end UPDATE_SECURITY_ORGANIZATION_B;
end HR_SECURITY_ORGANIZATION_BK2;

/
