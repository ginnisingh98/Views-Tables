--------------------------------------------------------
--  DDL for Package Body PQH_RATE_FACTOR_ON_ELMNTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RATE_FACTOR_ON_ELMNTS_BK1" as
/* $Header: pqrfeapi.pkb 120.0 2005/10/06 14:53:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:34 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_RATE_FACTOR_ON_ELMNT_A
(P_EFFECTIVE_DATE in DATE
,P_RATE_FACTOR_ON_ELMNT_ID in NUMBER
,P_CRITERIA_RATE_ELEMENT_ID in NUMBER
,P_CRITERIA_RATE_FACTOR_ID in NUMBER
,P_RATE_FACTOR_VAL_RECORD_TBL in VARCHAR2
,P_RATE_FACTOR_VAL_RECORD_COL in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_RATE_FACTOR_ON_ELMNTS_BK1.CREATE_RATE_FACTOR_ON_ELMNT_A', 10);
hr_utility.set_location(' Leaving: PQH_RATE_FACTOR_ON_ELMNTS_BK1.CREATE_RATE_FACTOR_ON_ELMNT_A', 20);
end CREATE_RATE_FACTOR_ON_ELMNT_A;
procedure CREATE_RATE_FACTOR_ON_ELMNT_B
(P_EFFECTIVE_DATE in DATE
,P_CRITERIA_RATE_ELEMENT_ID in NUMBER
,P_CRITERIA_RATE_FACTOR_ID in NUMBER
,P_RATE_FACTOR_VAL_RECORD_TBL in VARCHAR2
,P_RATE_FACTOR_VAL_RECORD_COL in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_RATE_FACTOR_ON_ELMNTS_BK1.CREATE_RATE_FACTOR_ON_ELMNT_B', 10);
hr_utility.set_location(' Leaving: PQH_RATE_FACTOR_ON_ELMNTS_BK1.CREATE_RATE_FACTOR_ON_ELMNT_B', 20);
end CREATE_RATE_FACTOR_ON_ELMNT_B;
end PQH_RATE_FACTOR_ON_ELMNTS_BK1;

/
