--------------------------------------------------------
--  DDL for Package Body PQP_ANALYZED_ALIEN_DATA_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ANALYZED_ALIEN_DATA_BK2" as
/* $Header: pqaadapi.pkb 115.4 2003/01/22 00:53:34 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:36:12 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ANALYZED_ALIEN_DATA_A
(P_ANALYZED_DATA_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_DATA_SOURCE in VARCHAR2
,P_TAX_YEAR in NUMBER
,P_CURRENT_RESIDENCY_STATUS in VARCHAR2
,P_NRA_TO_RA_DATE in DATE
,P_TARGET_DEPARTURE_DATE in DATE
,P_TAX_RESIDENCE_COUNTRY_CODE in VARCHAR2
,P_TREATY_INFO_UPDATE_DATE in DATE
,P_NUMBER_OF_DAYS_IN_USA in NUMBER
,P_WITHLDG_ALLOW_ELIGIBLE_FLAG in VARCHAR2
,P_RA_EFFECTIVE_DATE in DATE
,P_RECORD_SOURCE in VARCHAR2
,P_VISA_TYPE in VARCHAR2
,P_J_SUB_TYPE in VARCHAR2
,P_PRIMARY_ACTIVITY in VARCHAR2
,P_NON_US_COUNTRY_CODE in VARCHAR2
,P_CITIZENSHIP_COUNTRY_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATE_8233_SIGNED in DATE
,P_DATE_W4_SIGNED in DATE
)is
begin
hr_utility.set_location('Entering: PQP_ANALYZED_ALIEN_DATA_BK2.UPDATE_ANALYZED_ALIEN_DATA_A', 10);
hr_utility.set_location(' Leaving: PQP_ANALYZED_ALIEN_DATA_BK2.UPDATE_ANALYZED_ALIEN_DATA_A', 20);
end UPDATE_ANALYZED_ALIEN_DATA_A;
procedure UPDATE_ANALYZED_ALIEN_DATA_B
(P_ANALYZED_DATA_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_DATA_SOURCE in VARCHAR2
,P_TAX_YEAR in NUMBER
,P_CURRENT_RESIDENCY_STATUS in VARCHAR2
,P_NRA_TO_RA_DATE in DATE
,P_TARGET_DEPARTURE_DATE in DATE
,P_TAX_RESIDENCE_COUNTRY_CODE in VARCHAR2
,P_TREATY_INFO_UPDATE_DATE in DATE
,P_NUMBER_OF_DAYS_IN_USA in NUMBER
,P_WITHLDG_ALLOW_ELIGIBLE_FLAG in VARCHAR2
,P_RA_EFFECTIVE_DATE in DATE
,P_RECORD_SOURCE in VARCHAR2
,P_VISA_TYPE in VARCHAR2
,P_J_SUB_TYPE in VARCHAR2
,P_PRIMARY_ACTIVITY in VARCHAR2
,P_NON_US_COUNTRY_CODE in VARCHAR2
,P_CITIZENSHIP_COUNTRY_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATE_8233_SIGNED in DATE
,P_DATE_W4_SIGNED in DATE
)is
begin
hr_utility.set_location('Entering: PQP_ANALYZED_ALIEN_DATA_BK2.UPDATE_ANALYZED_ALIEN_DATA_B', 10);
hr_utility.set_location(' Leaving: PQP_ANALYZED_ALIEN_DATA_BK2.UPDATE_ANALYZED_ALIEN_DATA_B', 20);
end UPDATE_ANALYZED_ALIEN_DATA_B;
end PQP_ANALYZED_ALIEN_DATA_BK2;

/
