--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION_BK7" as
/* $Header: hrorgapi.pkb 120.10.12010000.8 2009/04/14 09:44:53 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:19 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_COMPANY_COST_CENTER_A
(P_EFFECTIVE_DATE in DATE
,P_ORGANIZATION_ID in NUMBER
,P_COMPANY_VALUESET_ID in NUMBER
,P_COMPANY in VARCHAR2
,P_COSTCENTER_VALUESET_ID in NUMBER
,P_COSTCENTER in VARCHAR2
,P_ORI_ORG_INFORMATION_ID in NUMBER
,P_ORI_OBJECT_VERSION_NUMBER in NUMBER
,P_ORG_INFORMATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_ORGANIZATION_BK7.CREATE_COMPANY_COST_CENTER_A', 10);
hr_utility.set_location(' Leaving: HR_ORGANIZATION_BK7.CREATE_COMPANY_COST_CENTER_A', 20);
end CREATE_COMPANY_COST_CENTER_A;
procedure CREATE_COMPANY_COST_CENTER_B
(P_EFFECTIVE_DATE in DATE
,P_ORGANIZATION_ID in NUMBER
,P_COMPANY_VALUESET_ID in NUMBER
,P_COMPANY in VARCHAR2
,P_COSTCENTER_VALUESET_ID in NUMBER
,P_COSTCENTER in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_ORGANIZATION_BK7.CREATE_COMPANY_COST_CENTER_B', 10);
hr_utility.set_location(' Leaving: HR_ORGANIZATION_BK7.CREATE_COMPANY_COST_CENTER_B', 20);
end CREATE_COMPANY_COST_CENTER_B;
end HR_ORGANIZATION_BK7;

/