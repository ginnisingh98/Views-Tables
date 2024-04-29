--------------------------------------------------------
--  DDL for Package Body PAY_IE_PRSI_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PRSI_BK1" as
/* $Header: pysidapi.pkb 115.2 2002/12/06 14:46:25 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:25 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_IE_PRSI_DETAILS_A
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
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
,P_COMMUNITY_FLAG in VARCHAR2
,P_PRSI_DETAILS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PAY_IE_PRSI_BK1.CREATE_IE_PRSI_DETAILS_A', 10);
hr_utility.set_location(' Leaving: PAY_IE_PRSI_BK1.CREATE_IE_PRSI_DETAILS_A', 20);
end CREATE_IE_PRSI_DETAILS_A;
procedure CREATE_IE_PRSI_DETAILS_B
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
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
,P_COMMUNITY_FLAG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_IE_PRSI_BK1.CREATE_IE_PRSI_DETAILS_B', 10);
hr_utility.set_location(' Leaving: PAY_IE_PRSI_BK1.CREATE_IE_PRSI_DETAILS_B', 20);
end CREATE_IE_PRSI_DETAILS_B;
end PAY_IE_PRSI_BK1;

/