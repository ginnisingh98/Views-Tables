--------------------------------------------------------
--  DDL for Package Body HR_CAGR_ENTITLEMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_ENTITLEMENT_BK3" as
/* $Header: pepceapi.pkb 120.1 2006/10/18 09:05:55 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:55 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_CAGR_ENTITLEMENT_A
(P_EFFECTIVE_DATE in DATE
,P_CAGR_ENTITLEMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_CAGR_ENTITLEMENT_BK3.DELETE_CAGR_ENTITLEMENT_A', 10);
hr_utility.set_location(' Leaving: HR_CAGR_ENTITLEMENT_BK3.DELETE_CAGR_ENTITLEMENT_A', 20);
end DELETE_CAGR_ENTITLEMENT_A;
procedure DELETE_CAGR_ENTITLEMENT_B
(P_EFFECTIVE_DATE in DATE
,P_CAGR_ENTITLEMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_CAGR_ENTITLEMENT_BK3.DELETE_CAGR_ENTITLEMENT_B', 10);
hr_utility.set_location(' Leaving: HR_CAGR_ENTITLEMENT_BK3.DELETE_CAGR_ENTITLEMENT_B', 20);
end DELETE_CAGR_ENTITLEMENT_B;
end HR_CAGR_ENTITLEMENT_BK3;

/