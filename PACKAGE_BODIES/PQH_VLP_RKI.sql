--------------------------------------------------------
--  DDL for Package Body PQH_VLP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VLP_RKI" as
/* $Header: pqvlprhi.pkb 115.6 2004/03/31 00:31:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:49 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_VALIDATION_PERIOD_ID in NUMBER
,P_VALIDATION_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_PREVIOUS_EMPLOYER_ID in NUMBER
,P_ASSIGNMENT_CATEGORY in VARCHAR2
,P_NORMAL_HOURS in NUMBER
,P_FREQUENCY in VARCHAR2
,P_PERIOD_YEARS in NUMBER
,P_PERIOD_MONTHS in NUMBER
,P_PERIOD_DAYS in NUMBER
,P_COMMENTS in VARCHAR2
,P_VALIDATION_STATUS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_VLP_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_VLP_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_VLP_RKI;

/
