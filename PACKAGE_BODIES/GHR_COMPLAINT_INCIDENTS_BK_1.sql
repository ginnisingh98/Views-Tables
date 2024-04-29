--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINT_INCIDENTS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINT_INCIDENTS_BK_1" as
/* $Header: ghcinapi.pkb 120.0 2005/10/02 01:57:31 generated $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:52:57 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_COMPL_INCIDENT_A
(P_EFFECTIVE_DATE in DATE
,P_COMPL_CLAIM_ID in NUMBER
,P_INCIDENT_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_DATE_AMENDED in DATE
,P_DATE_ACKNOWLEDGED in DATE
,P_COMPL_INCIDENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_COMPLAINT_INCIDENTS_BK_1.CREATE_COMPL_INCIDENT_A', 10);
hr_utility.set_location(' Leaving: GHR_COMPLAINT_INCIDENTS_BK_1.CREATE_COMPL_INCIDENT_A', 20);
end CREATE_COMPL_INCIDENT_A;
procedure CREATE_COMPL_INCIDENT_B
(P_EFFECTIVE_DATE in DATE
,P_COMPL_CLAIM_ID in NUMBER
,P_INCIDENT_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_DATE_AMENDED in DATE
,P_DATE_ACKNOWLEDGED in DATE
)is
begin
hr_utility.set_location('Entering: GHR_COMPLAINT_INCIDENTS_BK_1.CREATE_COMPL_INCIDENT_B', 10);
hr_utility.set_location(' Leaving: GHR_COMPLAINT_INCIDENTS_BK_1.CREATE_COMPL_INCIDENT_B', 20);
end CREATE_COMPL_INCIDENT_B;
end GHR_COMPLAINT_INCIDENTS_BK_1;

/