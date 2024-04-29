--------------------------------------------------------
--  DDL for Package Body PER_HIERARCHY_VERSIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HIERARCHY_VERSIONS_BK3" as
/* $Header: pepgvapi.pkb 115.5 2003/05/16 12:19:55 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:43 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_HIERARCHY_VERSIONS_A
(P_HIERARCHY_VERSION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PER_HIERARCHY_VERSIONS_BK3.DELETE_HIERARCHY_VERSIONS_A', 10);
hr_utility.set_location(' Leaving: PER_HIERARCHY_VERSIONS_BK3.DELETE_HIERARCHY_VERSIONS_A', 20);
end DELETE_HIERARCHY_VERSIONS_A;
procedure DELETE_HIERARCHY_VERSIONS_B
(P_HIERARCHY_VERSION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PER_HIERARCHY_VERSIONS_BK3.DELETE_HIERARCHY_VERSIONS_B', 10);
hr_utility.set_location(' Leaving: PER_HIERARCHY_VERSIONS_BK3.DELETE_HIERARCHY_VERSIONS_B', 20);
end DELETE_HIERARCHY_VERSIONS_B;
end PER_HIERARCHY_VERSIONS_BK3;

/
