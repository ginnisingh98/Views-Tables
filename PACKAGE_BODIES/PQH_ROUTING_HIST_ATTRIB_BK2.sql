--------------------------------------------------------
--  DDL for Package Body PQH_ROUTING_HIST_ATTRIB_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROUTING_HIST_ATTRIB_BK2" as
/* $Header: pqrhaapi.pkb 115.2 2002/12/06 18:07:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:36 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ROUTING_HIST_ATTRIB_A
(P_ROUTING_HIST_ATTRIB_ID in NUMBER
,P_ROUTING_HISTORY_ID in NUMBER
,P_ATTRIBUTE_ID in NUMBER
,P_FROM_CHAR in VARCHAR2
,P_FROM_DATE in DATE
,P_FROM_NUMBER in NUMBER
,P_TO_CHAR in VARCHAR2
,P_TO_DATE in DATE
,P_TO_NUMBER in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RANGE_TYPE_CD in VARCHAR2
,P_VALUE_DATE in DATE
,P_VALUE_NUMBER in NUMBER
,P_VALUE_CHAR in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_ROUTING_HIST_ATTRIB_BK2.UPDATE_ROUTING_HIST_ATTRIB_A', 10);
hr_utility.set_location(' Leaving: PQH_ROUTING_HIST_ATTRIB_BK2.UPDATE_ROUTING_HIST_ATTRIB_A', 20);
end UPDATE_ROUTING_HIST_ATTRIB_A;
procedure UPDATE_ROUTING_HIST_ATTRIB_B
(P_ROUTING_HIST_ATTRIB_ID in NUMBER
,P_ROUTING_HISTORY_ID in NUMBER
,P_ATTRIBUTE_ID in NUMBER
,P_FROM_CHAR in VARCHAR2
,P_FROM_DATE in DATE
,P_FROM_NUMBER in NUMBER
,P_TO_CHAR in VARCHAR2
,P_TO_DATE in DATE
,P_TO_NUMBER in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RANGE_TYPE_CD in VARCHAR2
,P_VALUE_DATE in DATE
,P_VALUE_NUMBER in NUMBER
,P_VALUE_CHAR in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_ROUTING_HIST_ATTRIB_BK2.UPDATE_ROUTING_HIST_ATTRIB_B', 10);
hr_utility.set_location(' Leaving: PQH_ROUTING_HIST_ATTRIB_BK2.UPDATE_ROUTING_HIST_ATTRIB_B', 20);
end UPDATE_ROUTING_HIST_ATTRIB_B;
end PQH_ROUTING_HIST_ATTRIB_BK2;

/
