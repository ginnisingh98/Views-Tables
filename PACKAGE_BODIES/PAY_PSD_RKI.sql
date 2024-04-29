--------------------------------------------------------
--  DDL for Package Body PAY_PSD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PSD_RKI" as
/* $Header: pypsdrhi.pkb 120.1 2005/12/08 05:08 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_SII_DETAILS_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_PER_OR_ASG_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CONTRACT_CATEGORY in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
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
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_LOGIN_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_REQUEST_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_PSD_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PAY_PSD_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_PSD_RKI;

/