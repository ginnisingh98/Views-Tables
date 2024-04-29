--------------------------------------------------------
--  DDL for Package Body GHR_COMPL_AGENCY_COSTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPL_AGENCY_COSTS_BK2" as
/* $Header: ghcstapi.pkb 120.0 2005/05/29 03:05:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:52:59 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_AGENCY_COSTS_A
(P_EFFECTIVE_DATE in DATE
,P_COMPLAINT_ID in NUMBER
,P_PHASE in VARCHAR2
,P_STAGE in VARCHAR2
,P_CATEGORY in VARCHAR2
,P_AMOUNT in NUMBER
,P_COST_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_COMPL_AGENCY_COST_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_COMPL_AGENCY_COSTS_BK2.UPDATE_AGENCY_COSTS_A', 10);
hr_utility.set_location(' Leaving: GHR_COMPL_AGENCY_COSTS_BK2.UPDATE_AGENCY_COSTS_A', 20);
end UPDATE_AGENCY_COSTS_A;
procedure UPDATE_AGENCY_COSTS_B
(P_EFFECTIVE_DATE in DATE
,P_COMPLAINT_ID in NUMBER
,P_PHASE in VARCHAR2
,P_STAGE in VARCHAR2
,P_CATEGORY in VARCHAR2
,P_AMOUNT in NUMBER
,P_COST_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_COMPL_AGENCY_COST_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_COMPL_AGENCY_COSTS_BK2.UPDATE_AGENCY_COSTS_B', 10);
hr_utility.set_location(' Leaving: GHR_COMPL_AGENCY_COSTS_BK2.UPDATE_AGENCY_COSTS_B', 20);
end UPDATE_AGENCY_COSTS_B;
end GHR_COMPL_AGENCY_COSTS_BK2;

/
