--------------------------------------------------------
--  DDL for Package Body PAY_ISB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ISB_RKI" as
/* $Header: pyisbrhi.pkb 115.3 2002/12/16 17:48:15 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:00 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_SOCIAL_BENEFIT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_ABSENCE_START_DATE in DATE
,P_ABSENCE_END_DATE in DATE
,P_BENEFIT_AMOUNT in NUMBER
,P_BENEFIT_TYPE in VARCHAR2
,P_CALCULATION_OPTION in VARCHAR2
,P_REDUCED_TAX_CREDIT in NUMBER
,P_REDUCED_STANDARD_CUTOFF in NUMBER
,P_INCIDENT_ID in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in VARCHAR2
,P_PROGRAM_UPDATE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PAY_ISB_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PAY_ISB_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_ISB_RKI;

/
