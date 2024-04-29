--------------------------------------------------------
--  DDL for Package Body PSP_EFF_REPORT_APPROVALS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EFF_REPORT_APPROVALS_BK3" as
/* $Header: PSPEAAIB.pls 120.3 2006/03/26 01:09:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:01:29 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_EFF_REPORT_APPROVALS_A
(P_EFFORT_REPORT_APPROVAL_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RETURN_STATUS in BOOLEAN
)is
begin
hr_utility.set_location('Entering: PSP_EFF_REPORT_APPROVALS_BK3.DELETE_EFF_REPORT_APPROVALS_A', 10);
hr_utility.set_location(' Leaving: PSP_EFF_REPORT_APPROVALS_BK3.DELETE_EFF_REPORT_APPROVALS_A', 20);
end DELETE_EFF_REPORT_APPROVALS_A;
procedure DELETE_EFF_REPORT_APPROVALS_B
(P_EFFORT_REPORT_APPROVAL_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PSP_EFF_REPORT_APPROVALS_BK3.DELETE_EFF_REPORT_APPROVALS_B', 10);
hr_utility.set_location(' Leaving: PSP_EFF_REPORT_APPROVALS_BK3.DELETE_EFF_REPORT_APPROVALS_B', 20);
end DELETE_EFF_REPORT_APPROVALS_B;
end PSP_EFF_REPORT_APPROVALS_BK3;

/