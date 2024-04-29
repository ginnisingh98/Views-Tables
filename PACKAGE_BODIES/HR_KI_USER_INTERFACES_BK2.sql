--------------------------------------------------------
--  DDL for Package Body HR_KI_USER_INTERFACES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_USER_INTERFACES_BK2" as
/* $Header: hritfapi.pkb 115.0 2004/01/09 04:56:44 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:05 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_USER_INTERFACE_A
(P_EFFECTIVE_DATE in DATE
,P_TYPE in VARCHAR2
,P_FORM_NAME in VARCHAR2
,P_PAGE_REGION_CODE in VARCHAR2
,P_REGION_CODE in VARCHAR2
,P_USER_INTERFACE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_KI_USER_INTERFACES_BK2.UPDATE_USER_INTERFACE_A', 10);
hr_utility.set_location(' Leaving: HR_KI_USER_INTERFACES_BK2.UPDATE_USER_INTERFACE_A', 20);
end UPDATE_USER_INTERFACE_A;
procedure UPDATE_USER_INTERFACE_B
(P_EFFECTIVE_DATE in DATE
,P_TYPE in VARCHAR2
,P_FORM_NAME in VARCHAR2
,P_PAGE_REGION_CODE in VARCHAR2
,P_REGION_CODE in VARCHAR2
,P_USER_INTERFACE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_KI_USER_INTERFACES_BK2.UPDATE_USER_INTERFACE_B', 10);
hr_utility.set_location(' Leaving: HR_KI_USER_INTERFACES_BK2.UPDATE_USER_INTERFACE_B', 20);
end UPDATE_USER_INTERFACE_B;
end HR_KI_USER_INTERFACES_BK2;

/
