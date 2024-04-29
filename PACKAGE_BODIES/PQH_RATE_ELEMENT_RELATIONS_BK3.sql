--------------------------------------------------------
--  DDL for Package Body PQH_RATE_ELEMENT_RELATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RATE_ELEMENT_RELATIONS_BK3" as
/* $Header: pqrerapi.pkb 120.0 2005/10/06 14:53:06 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:34 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_RATE_ELEMENT_RELATION_A
(P_EFFECTIVE_DATE in DATE
,P_RATE_ELEMENT_RELATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_RATE_ELEMENT_RELATIONS_BK3.DELETE_RATE_ELEMENT_RELATION_A', 10);
hr_utility.set_location(' Leaving: PQH_RATE_ELEMENT_RELATIONS_BK3.DELETE_RATE_ELEMENT_RELATION_A', 20);
end DELETE_RATE_ELEMENT_RELATION_A;
procedure DELETE_RATE_ELEMENT_RELATION_B
(P_EFFECTIVE_DATE in DATE
,P_RATE_ELEMENT_RELATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_RATE_ELEMENT_RELATIONS_BK3.DELETE_RATE_ELEMENT_RELATION_B', 10);
hr_utility.set_location(' Leaving: PQH_RATE_ELEMENT_RELATIONS_BK3.DELETE_RATE_ELEMENT_RELATION_B', 20);
end DELETE_RATE_ELEMENT_RELATION_B;
end PQH_RATE_ELEMENT_RELATIONS_BK3;

/