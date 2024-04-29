--------------------------------------------------------
--  DDL for Package Body PER_ENV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ENV_RKI" as
/* $Header: peenvrhi.pkb 120.1 2005/08/04 03:23:12 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:07 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_CAL_ENTRY_VALUE_ID in NUMBER
,P_CALENDAR_ENTRY_ID in NUMBER
,P_HIERARCHY_NODE_ID in NUMBER
,P_VALUE in VARCHAR2
,P_ORG_STRUCTURE_ELEMENT_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_OVERRIDE_NAME in VARCHAR2
,P_OVERRIDE_TYPE in VARCHAR2
,P_PARENT_ENTRY_VALUE_ID in NUMBER
,P_USAGE_FLAG in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_ENV_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_ENV_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_ENV_RKI;

/
