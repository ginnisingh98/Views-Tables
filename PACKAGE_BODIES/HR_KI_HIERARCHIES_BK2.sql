--------------------------------------------------------
--  DDL for Package Body HR_KI_HIERARCHIES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_HIERARCHIES_BK2" as
/* $Header: hrhrcapi.pkb 115.0 2004/01/09 01:13:25 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:03 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_HIERARCHY_NODE_A
(P_LANGUAGE_CODE in VARCHAR2
,P_PARENT_HIERARCHY_ID in NUMBER
,P_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_HIERARCHY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_KI_HIERARCHIES_BK2.UPDATE_HIERARCHY_NODE_A', 10);
hr_utility.set_location(' Leaving: HR_KI_HIERARCHIES_BK2.UPDATE_HIERARCHY_NODE_A', 20);
end UPDATE_HIERARCHY_NODE_A;
procedure UPDATE_HIERARCHY_NODE_B
(P_LANGUAGE_CODE in VARCHAR2
,P_PARENT_HIERARCHY_ID in NUMBER
,P_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_HIERARCHY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_KI_HIERARCHIES_BK2.UPDATE_HIERARCHY_NODE_B', 10);
hr_utility.set_location(' Leaving: HR_KI_HIERARCHIES_BK2.UPDATE_HIERARCHY_NODE_B', 20);
end UPDATE_HIERARCHY_NODE_B;
end HR_KI_HIERARCHIES_BK2;

/
