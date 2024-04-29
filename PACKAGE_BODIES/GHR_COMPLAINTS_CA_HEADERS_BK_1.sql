--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINTS_CA_HEADERS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINTS_CA_HEADERS_BK_1" as
/* $Header: ghcahapi.pkb 120.0 2005/10/02 01:57:09 generated $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:52:54 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_CA_HEADER_A
(P_EFFECTIVE_DATE in DATE
,P_COMPLAINT_ID in NUMBER
,P_CA_SOURCE in VARCHAR2
,P_LAST_COMPLIANCE_REPORT in DATE
,P_COMPLIANCE_CLOSED in DATE
,P_COMPL_DOCKET_NUMBER in VARCHAR2
,P_APPEAL_DOCKET_NUMBER in VARCHAR2
,P_PFE_DOCKET_NUMBER in VARCHAR2
,P_PFE_RECEIVED in DATE
,P_AGENCY_BRIEF_PFE_DUE in DATE
,P_AGENCY_BRIEF_PFE_DATE in DATE
,P_DECISION_PFE_DATE in DATE
,P_DECISION_PFE in VARCHAR2
,P_AGENCY_RECVD_PFE_DECISION in DATE
,P_AGENCY_PFE_BRIEF_FORWD in DATE
,P_AGENCY_NOTIFIED_NONCOM in DATE
,P_COMREP_NONCOM_REQ in VARCHAR2
,P_EEO_OFF_REQ_DATA_FROM_ORG in DATE
,P_ORG_FORWD_DATA_TO_EEO_OFF in DATE
,P_DEC_IMPLEMENTED in DATE
,P_COMPLAINT_REINSTATED in DATE
,P_STAGE_COMPLAINT_REINSTATED in VARCHAR2
,P_COMPL_CA_HEADER_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_COMPLAINTS_CA_HEADERS_BK_1.CREATE_CA_HEADER_A', 10);
hr_utility.set_location(' Leaving: GHR_COMPLAINTS_CA_HEADERS_BK_1.CREATE_CA_HEADER_A', 20);
end CREATE_CA_HEADER_A;
procedure CREATE_CA_HEADER_B
(P_EFFECTIVE_DATE in DATE
,P_COMPLAINT_ID in NUMBER
,P_CA_SOURCE in VARCHAR2
,P_LAST_COMPLIANCE_REPORT in DATE
,P_COMPLIANCE_CLOSED in DATE
,P_COMPL_DOCKET_NUMBER in VARCHAR2
,P_APPEAL_DOCKET_NUMBER in VARCHAR2
,P_PFE_DOCKET_NUMBER in VARCHAR2
,P_PFE_RECEIVED in DATE
,P_AGENCY_BRIEF_PFE_DUE in DATE
,P_AGENCY_BRIEF_PFE_DATE in DATE
,P_DECISION_PFE_DATE in DATE
,P_DECISION_PFE in VARCHAR2
,P_AGENCY_RECVD_PFE_DECISION in DATE
,P_AGENCY_PFE_BRIEF_FORWD in DATE
,P_AGENCY_NOTIFIED_NONCOM in DATE
,P_COMREP_NONCOM_REQ in VARCHAR2
,P_EEO_OFF_REQ_DATA_FROM_ORG in DATE
,P_ORG_FORWD_DATA_TO_EEO_OFF in DATE
,P_DEC_IMPLEMENTED in DATE
,P_COMPLAINT_REINSTATED in DATE
,P_STAGE_COMPLAINT_REINSTATED in VARCHAR2
)is
begin
hr_utility.set_location('Entering: GHR_COMPLAINTS_CA_HEADERS_BK_1.CREATE_CA_HEADER_B', 10);
hr_utility.set_location(' Leaving: GHR_COMPLAINTS_CA_HEADERS_BK_1.CREATE_CA_HEADER_B', 20);
end CREATE_CA_HEADER_B;
end GHR_COMPLAINTS_CA_HEADERS_BK_1;

/
