--------------------------------------------------------
--  DDL for Package Body PAY_SID_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SID_RKU" as
/* $Header: pysidrhi.pkb 120.1 2005/07/05 06:26:10 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:25 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_PRSI_DETAILS_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_CONTRIBUTION_CLASS in VARCHAR2
,P_OVERRIDDEN_SUBCLASS in VARCHAR2
,P_SOC_BEN_FLAG in VARCHAR2
,P_SOC_BEN_START_DATE in DATE
,P_OVERRIDDEN_INS_WEEKS in NUMBER
,P_NON_STANDARD_INS_WEEKS in NUMBER
,P_EXEMPTION_START_DATE in DATE
,P_EXEMPTION_END_DATE in DATE
,P_CERT_ISSUED_BY in VARCHAR2
,P_DIRECTOR_FLAG in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_COMMUNITY_FLAG in VARCHAR2
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_ASSIGNMENT_ID_O in NUMBER
,P_CONTRIBUTION_CLASS_O in VARCHAR2
,P_OVERRIDDEN_SUBCLASS_O in VARCHAR2
,P_SOC_BEN_FLAG_O in VARCHAR2
,P_SOC_BEN_START_DATE_O in DATE
,P_OVERRIDDEN_INS_WEEKS_O in NUMBER
,P_NON_STANDARD_INS_WEEKS_O in NUMBER
,P_EXEMPTION_START_DATE_O in DATE
,P_EXEMPTION_END_DATE_O in DATE
,P_CERT_ISSUED_BY_O in VARCHAR2
,P_DIRECTOR_FLAG_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_COMMUNITY_FLAG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_SID_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PAY_SID_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PAY_SID_RKU;

/
