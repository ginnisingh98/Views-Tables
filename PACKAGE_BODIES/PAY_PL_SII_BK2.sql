--------------------------------------------------------
--  DDL for Package Body PAY_PL_SII_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_SII_BK2" as
/* $Header: pypsdapi.pkb 120.1 2005/12/08 05:09:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:18 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PL_SII_DETAILS_A
(P_EFFECTIVE_DATE in DATE
,P_SII_DETAILS_ID in NUMBER
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_EMP_SOCIAL_SECURITY_INFO in VARCHAR2
,P_OLD_AGE_CONTRIBUTION in VARCHAR2
,P_PENSION_CONTRIBUTION in VARCHAR2
,P_SICKNESS_CONTRIBUTION in VARCHAR2
,P_WORK_INJURY_CONTRIBUTION in VARCHAR2
,P_LABOR_CONTRIBUTION in VARCHAR2
,P_HEALTH_CONTRIBUTION in VARCHAR2
,P_UNEMPLOYMENT_CONTRIBUTION in VARCHAR2
,P_OLD_AGE_CONT_END_REASON in VARCHAR2
,P_PENSION_CONT_END_REASON in VARCHAR2
,P_SICKNESS_CONT_END_REASON in VARCHAR2
,P_WORK_INJURY_CONT_END_REASON in VARCHAR2
,P_LABOR_FUND_CONT_END_REASON in VARCHAR2
,P_HEALTH_CONT_END_REASON in VARCHAR2
,P_UNEMPLOYMENT_CONT_END_REASON in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PAY_PL_SII_BK2.UPDATE_PL_SII_DETAILS_A', 10);
hr_utility.set_location(' Leaving: PAY_PL_SII_BK2.UPDATE_PL_SII_DETAILS_A', 20);
end UPDATE_PL_SII_DETAILS_A;
procedure UPDATE_PL_SII_DETAILS_B
(P_EFFECTIVE_DATE in DATE
,P_SII_DETAILS_ID in NUMBER
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_EMP_SOCIAL_SECURITY_INFO in VARCHAR2
,P_OLD_AGE_CONTRIBUTION in VARCHAR2
,P_PENSION_CONTRIBUTION in VARCHAR2
,P_SICKNESS_CONTRIBUTION in VARCHAR2
,P_WORK_INJURY_CONTRIBUTION in VARCHAR2
,P_LABOR_CONTRIBUTION in VARCHAR2
,P_HEALTH_CONTRIBUTION in VARCHAR2
,P_UNEMPLOYMENT_CONTRIBUTION in VARCHAR2
,P_OLD_AGE_CONT_END_REASON in VARCHAR2
,P_PENSION_CONT_END_REASON in VARCHAR2
,P_SICKNESS_CONT_END_REASON in VARCHAR2
,P_WORK_INJURY_CONT_END_REASON in VARCHAR2
,P_LABOR_FUND_CONT_END_REASON in VARCHAR2
,P_HEALTH_CONT_END_REASON in VARCHAR2
,P_UNEMPLOYMENT_CONT_END_REASON in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_PL_SII_BK2.UPDATE_PL_SII_DETAILS_B', 10);
hr_utility.set_location(' Leaving: PAY_PL_SII_BK2.UPDATE_PL_SII_DETAILS_B', 20);
end UPDATE_PL_SII_DETAILS_B;
end PAY_PL_SII_BK2;

/