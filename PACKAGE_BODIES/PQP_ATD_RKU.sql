--------------------------------------------------------
--  DDL for Package Body PQP_ATD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ATD_RKU" as
/* $Header: pqatdrhi.pkb 115.10 2003/02/17 22:13:56 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:01:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ALIEN_TRANSACTION_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_DATA_SOURCE_TYPE in VARCHAR2
,P_TAX_YEAR in NUMBER
,P_INCOME_CODE in VARCHAR2
,P_WITHHOLDING_RATE in NUMBER
,P_INCOME_CODE_SUB_TYPE in VARCHAR2
,P_EXEMPTION_CODE in VARCHAR2
,P_MAXIMUM_BENEFIT_AMOUNT in NUMBER
,P_RETRO_LOSE_BEN_AMT_FLAG in VARCHAR2
,P_DATE_BENEFIT_ENDS in DATE
,P_RETRO_LOSE_BEN_DATE_FLAG in VARCHAR2
,P_CURRENT_RESIDENCY_STATUS in VARCHAR2
,P_NRA_TO_RA_DATE in DATE
,P_TARGET_DEPARTURE_DATE in DATE
,P_TAX_RESIDENCE_COUNTRY_CODE in VARCHAR2
,P_TREATY_INFO_UPDATE_DATE in DATE
,P_NRA_EXEMPT_FROM_FICA in VARCHAR2
,P_STUDENT_EXEMPT_FROM_FICA in VARCHAR2
,P_ADDL_WITHHOLDING_FLAG in VARCHAR2
,P_ADDL_WITHHOLDING_AMT in NUMBER
,P_ADDL_WTHLDNG_AMT_PERIOD_TYPE in VARCHAR2
,P_PERSONAL_EXEMPTION in NUMBER
,P_ADDL_EXEMPTION_ALLOWED in NUMBER
,P_NUMBER_OF_DAYS_IN_USA in NUMBER
,P_WTHLDG_ALLOW_ELIGIBLE_FLAG in VARCHAR2
,P_TREATY_BEN_ALLOWED_FLAG in VARCHAR2
,P_TREATY_BENEFITS_START_DATE in DATE
,P_RA_EFFECTIVE_DATE in DATE
,P_STATE_CODE in VARCHAR2
,P_STATE_HONORS_TREATY_FLAG in VARCHAR2
,P_YTD_PAYMENTS in NUMBER
,P_YTD_W2_PAYMENTS in NUMBER
,P_YTD_W2_WITHHOLDING in NUMBER
,P_YTD_WITHHOLDING_ALLOWANCE in NUMBER
,P_YTD_TREATY_PAYMENTS in NUMBER
,P_YTD_TREATY_WITHHELD_AMT in NUMBER
,P_RECORD_SOURCE in VARCHAR2
,P_VISA_TYPE in VARCHAR2
,P_J_SUB_TYPE in VARCHAR2
,P_PRIMARY_ACTIVITY in VARCHAR2
,P_NON_US_COUNTRY_CODE in VARCHAR2
,P_CITIZENSHIP_COUNTRY_CODE in VARCHAR2
,P_CONSTANT_ADDL_TAX in NUMBER
,P_DATE_8233_SIGNED in DATE
,P_DATE_W4_SIGNED in DATE
,P_ERROR_INDICATOR in VARCHAR2
,P_PREV_ER_TREATY_BENEFIT_AMT in NUMBER
,P_ERROR_TEXT in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_CURRENT_ANALYSIS in VARCHAR2
,P_FORECAST_INCOME_CODE in VARCHAR2
,P_PERSON_ID_O in NUMBER
,P_DATA_SOURCE_TYPE_O in VARCHAR2
,P_TAX_YEAR_O in NUMBER
,P_INCOME_CODE_O in VARCHAR2
,P_WITHHOLDING_RATE_O in NUMBER
,P_INCOME_CODE_SUB_TYPE_O in VARCHAR2
,P_EXEMPTION_CODE_O in VARCHAR2
,P_MAXIMUM_BENEFIT_AMOUNT_O in NUMBER
,P_RETRO_LOSE_BEN_AMT_FLAG_O in VARCHAR2
,P_DATE_BENEFIT_ENDS_O in DATE
,P_RETRO_LOSE_BEN_DATE_FLAG_O in VARCHAR2
,P_CURRENT_RESIDENCY_STATUS_O in VARCHAR2
,P_NRA_TO_RA_DATE_O in DATE
,P_TARGET_DEPARTURE_DATE_O in DATE
,P_TAX_RESIDENCE_COUNTRY_CODE_O in VARCHAR2
,P_TREATY_INFO_UPDATE_DATE_O in DATE
,P_NRA_EXEMPT_FROM_FICA_O in VARCHAR2
,P_STUDENT_EXEMPT_FROM_FICA_O in VARCHAR2
,P_ADDL_WITHHOLDING_FLAG_O in VARCHAR2
,P_ADDL_WITHHOLDING_AMT_O in NUMBER
,P_ADDL_WTHLDNG_AMT_PERIOD_TY_O in VARCHAR2
,P_PERSONAL_EXEMPTION_O in NUMBER
,P_ADDL_EXEMPTION_ALLOWED_O in NUMBER
,P_NUMBER_OF_DAYS_IN_USA_O in NUMBER
,P_WTHLDG_ALLOW_ELIGIBLE_FLAG_O in VARCHAR2
,P_TREATY_BEN_ALLOWED_FLAG_O in VARCHAR2
,P_TREATY_BENEFITS_START_DATE_O in DATE
,P_RA_EFFECTIVE_DATE_O in DATE
,P_STATE_CODE_O in VARCHAR2
,P_STATE_HONORS_TREATY_FLAG_O in VARCHAR2
,P_YTD_PAYMENTS_O in NUMBER
,P_YTD_W2_PAYMENTS_O in NUMBER
,P_YTD_W2_WITHHOLDING_O in NUMBER
,P_YTD_WITHHOLDING_ALLOWANCE_O in NUMBER
,P_YTD_TREATY_PAYMENTS_O in NUMBER
,P_YTD_TREATY_WITHHELD_AMT_O in NUMBER
,P_RECORD_SOURCE_O in VARCHAR2
,P_VISA_TYPE_O in VARCHAR2
,P_J_SUB_TYPE_O in VARCHAR2
,P_PRIMARY_ACTIVITY_O in VARCHAR2
,P_NON_US_COUNTRY_CODE_O in VARCHAR2
,P_CITIZENSHIP_COUNTRY_CODE_O in VARCHAR2
,P_CONSTANT_ADDL_TAX_O in NUMBER
,P_DATE_8233_SIGNED_O in DATE
,P_DATE_W4_SIGNED_O in DATE
,P_ERROR_INDICATOR_O in VARCHAR2
,P_PREV_ER_TREATY_BENEFIT_AMT_O in NUMBER
,P_ERROR_TEXT_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CURRENT_ANALYSIS_O in VARCHAR2
,P_FORECAST_INCOME_CODE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQP_ATD_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQP_ATD_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQP_ATD_RKU;

/