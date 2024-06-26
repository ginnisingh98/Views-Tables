--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_DATA_GROUPS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_DATA_GROUPS_BK2" as
/* $Header: hrtdgapi.pkb 115.4 2004/06/21 09:20:50 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:20 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_TEMPLATE_DATA_GROUP_A
(P_EFFECTIVE_DATE in DATE
,P_FORM_DATA_GROUP_ID in NUMBER
,P_FORM_TEMPLATE_ID in NUMBER
,P_TEMPLATE_DATA_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_TEMPLATE_DATA_GROUPS_BK2.CREATE_TEMPLATE_DATA_GROUP_A', 10);
hr_utility.set_location(' Leaving: HR_TEMPLATE_DATA_GROUPS_BK2.CREATE_TEMPLATE_DATA_GROUP_A', 20);
end CREATE_TEMPLATE_DATA_GROUP_A;
procedure CREATE_TEMPLATE_DATA_GROUP_B
(P_EFFECTIVE_DATE in DATE
,P_FORM_DATA_GROUP_ID in NUMBER
,P_FORM_TEMPLATE_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_TEMPLATE_DATA_GROUPS_BK2.CREATE_TEMPLATE_DATA_GROUP_B', 10);
hr_utility.set_location(' Leaving: HR_TEMPLATE_DATA_GROUPS_BK2.CREATE_TEMPLATE_DATA_GROUP_B', 20);
end CREATE_TEMPLATE_DATA_GROUP_B;
end HR_TEMPLATE_DATA_GROUPS_BK2;

/
