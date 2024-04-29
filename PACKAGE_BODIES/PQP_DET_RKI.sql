--------------------------------------------------------
--  DDL for Package Body PQP_DET_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_DET_RKI" as
/* $Header: pqdetrhi.pkb 115.8 2003/02/17 22:14:03 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:01:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
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
hr_utility.set_location('Entering: PQP_DET_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQP_DET_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQP_DET_RKI;

/