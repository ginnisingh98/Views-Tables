--------------------------------------------------------
--  DDL for Package Body PER_ENT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ENT_RKD" as
/* $Header: peentrhi.pkb 120.2 2005/06/16 08:27:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:05 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CALENDAR_ENTRY_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_NAME_O in VARCHAR2
,P_TYPE_O in VARCHAR2
,P_START_DATE_O in DATE
,P_START_HOUR_O in VARCHAR2
,P_START_MIN_O in VARCHAR2
,P_END_DATE_O in DATE
,P_END_HOUR_O in VARCHAR2
,P_END_MIN_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_HIERARCHY_ID_O in NUMBER
,P_VALUE_SET_ID_O in NUMBER
,P_ORGANIZATION_STRUCTURE_ID_O in NUMBER
,P_ORG_STRUCTURE_VERSION_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_ENT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_ENT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_ENT_RKD;

/