--------------------------------------------------------
--  DDL for Package Body PQH_ATTRIBUTE_RANGES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATTRIBUTE_RANGES_BK3" as
/* $Header: pqrngapi.pkb 115.8 2002/12/06 18:08:24 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:39 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ATTRIBUTE_RANGE_A
(P_ATTRIBUTE_RANGE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_ATTRIBUTE_RANGES_BK3.DELETE_ATTRIBUTE_RANGE_A', 10);
hr_utility.set_location(' Leaving: PQH_ATTRIBUTE_RANGES_BK3.DELETE_ATTRIBUTE_RANGE_A', 20);
end DELETE_ATTRIBUTE_RANGE_A;
procedure DELETE_ATTRIBUTE_RANGE_B
(P_ATTRIBUTE_RANGE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_ATTRIBUTE_RANGES_BK3.DELETE_ATTRIBUTE_RANGE_B', 10);
hr_utility.set_location(' Leaving: PQH_ATTRIBUTE_RANGES_BK3.DELETE_ATTRIBUTE_RANGE_B', 20);
end DELETE_ATTRIBUTE_RANGE_B;
end PQH_ATTRIBUTE_RANGES_BK3;

/