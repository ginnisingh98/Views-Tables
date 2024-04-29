--------------------------------------------------------
--  DDL for Package Body HR_KI_HIERARCHIES_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_HIERARCHIES_BK7" as
/* $Header: hrhrcapi.pkb 115.0 2004/01/09 01:13:25 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:04 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_HIERARCHY_NODE_MAP_A
(P_TOPIC_ID in NUMBER
,P_HIERARCHY_ID in NUMBER
,P_USER_INTERFACE_ID in NUMBER
,P_HIERARCHY_NODE_MAP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_KI_HIERARCHIES_BK7.UPDATE_HIERARCHY_NODE_MAP_A', 10);
hr_utility.set_location(' Leaving: HR_KI_HIERARCHIES_BK7.UPDATE_HIERARCHY_NODE_MAP_A', 20);
end UPDATE_HIERARCHY_NODE_MAP_A;
procedure UPDATE_HIERARCHY_NODE_MAP_B
(P_TOPIC_ID in NUMBER
,P_HIERARCHY_ID in NUMBER
,P_USER_INTERFACE_ID in NUMBER
,P_HIERARCHY_NODE_MAP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_KI_HIERARCHIES_BK7.UPDATE_HIERARCHY_NODE_MAP_B', 10);
hr_utility.set_location(' Leaving: HR_KI_HIERARCHIES_BK7.UPDATE_HIERARCHY_NODE_MAP_B', 20);
end UPDATE_HIERARCHY_NODE_MAP_B;
end HR_KI_HIERARCHIES_BK7;

/