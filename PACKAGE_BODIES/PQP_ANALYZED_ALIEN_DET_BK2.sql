--------------------------------------------------------
--  DDL for Package Body PQP_ANALYZED_ALIEN_DET_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ANALYZED_ALIEN_DET_BK2" as
/* $Header: pqdetapi.pkb 115.7 2003/01/22 00:54:43 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:36:14 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ANALYZED_ALIEN_DET_A
(P_ANALYZED_DATA_DETAILS_ID in NUMBER
,P_ANALYZED_DATA_ID in NUMBER
,P_INCOME_CODE in VARCHAR2
,P_WITHHOLDING_RATE in NUMBER
,P_INCOME_CODE_SUB_TYPE in VARCHAR2
,P_EXEMPTION_CODE in VARCHAR2
,P_MAXIMUM_BENEFIT_AMOUNT in NUMBER
,P_RETRO_LOSE_BEN_AMT_FLAG in VARCHAR2
,P_DATE_BENEFIT_ENDS in DATE
,P_RETRO_LOSE_BEN_DATE_FLAG in VARCHAR2
,P_NRA_EXEMPT_FROM_SS in VARCHAR2
,P_NRA_EXEMPT_FROM_MEDICARE in VARCHAR2
,P_STUDENT_EXEMPT_FROM_SS in VARCHAR2
,P_STUDENT_EXEMPT_FROM_MEDI in VARCHAR2
,P_ADDL_WITHHOLDING_FLAG in VARCHAR2
,P_CONSTANT_ADDL_TAX in NUMBER
,P_ADDL_WITHHOLDING_AMT in NUMBER
,P_ADDL_WTHLDNG_AMT_PERIOD_TYPE in VARCHAR2
,P_PERSONAL_EXEMPTION in NUMBER
,P_ADDL_EXEMPTION_ALLOWED in NUMBER
,P_TREATY_BEN_ALLOWED_FLAG in VARCHAR2
,P_TREATY_BENEFITS_START_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_RETRO_LOSS_NOTIFICATION_SENT in VARCHAR2
,P_CURRENT_ANALYSIS in VARCHAR2
,P_FORECAST_INCOME_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQP_ANALYZED_ALIEN_DET_BK2.UPDATE_ANALYZED_ALIEN_DET_A', 10);
hr_utility.set_location(' Leaving: PQP_ANALYZED_ALIEN_DET_BK2.UPDATE_ANALYZED_ALIEN_DET_A', 20);
end UPDATE_ANALYZED_ALIEN_DET_A;
procedure UPDATE_ANALYZED_ALIEN_DET_B
(P_ANALYZED_DATA_DETAILS_ID in NUMBER
,P_ANALYZED_DATA_ID in NUMBER
,P_INCOME_CODE in VARCHAR2
,P_WITHHOLDING_RATE in NUMBER
,P_INCOME_CODE_SUB_TYPE in VARCHAR2
,P_EXEMPTION_CODE in VARCHAR2
,P_MAXIMUM_BENEFIT_AMOUNT in NUMBER
,P_RETRO_LOSE_BEN_AMT_FLAG in VARCHAR2
,P_DATE_BENEFIT_ENDS in DATE
,P_RETRO_LOSE_BEN_DATE_FLAG in VARCHAR2
,P_NRA_EXEMPT_FROM_SS in VARCHAR2
,P_NRA_EXEMPT_FROM_MEDICARE in VARCHAR2
,P_STUDENT_EXEMPT_FROM_SS in VARCHAR2
,P_STUDENT_EXEMPT_FROM_MEDI in VARCHAR2
,P_ADDL_WITHHOLDING_FLAG in VARCHAR2
,P_CONSTANT_ADDL_TAX in NUMBER
,P_ADDL_WITHHOLDING_AMT in NUMBER
,P_ADDL_WTHLDNG_AMT_PERIOD_TYPE in VARCHAR2
,P_PERSONAL_EXEMPTION in NUMBER
,P_ADDL_EXEMPTION_ALLOWED in NUMBER
,P_TREATY_BEN_ALLOWED_FLAG in VARCHAR2
,P_TREATY_BENEFITS_START_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_RETRO_LOSS_NOTIFICATION_SENT in VARCHAR2
,P_CURRENT_ANALYSIS in VARCHAR2
,P_FORECAST_INCOME_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQP_ANALYZED_ALIEN_DET_BK2.UPDATE_ANALYZED_ALIEN_DET_B', 10);
hr_utility.set_location(' Leaving: PQP_ANALYZED_ALIEN_DET_BK2.UPDATE_ANALYZED_ALIEN_DET_B', 20);
end UPDATE_ANALYZED_ALIEN_DET_B;
end PQP_ANALYZED_ALIEN_DET_BK2;

/
