--------------------------------------------------------
--  DDL for Package Body PQP_GDS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GDS_RKI" as
/* $Header: pqgdsrhi.pkb 120.0 2005/10/28 07:32 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:58:59 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_GAP_DURATION_SUMMARY_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_GAP_ABSENCE_PLAN_ID in NUMBER
,P_SUMMARY_TYPE in VARCHAR2
,P_GAP_LEVEL in VARCHAR2
,P_DURATION_IN_DAYS in NUMBER
,P_DURATION_IN_HOURS in NUMBER
,P_DATE_START in DATE
,P_DATE_END in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PQP_GDS_RKI.AFTER_INSERT', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
PAY_DYT_DURATION_SUMMARY_PKG.AFTER_INSERT
(P_GAP_DURATION_SUMMARY_ID => P_GAP_DURATION_SUMMARY_ID
,P_ASSIGNMENT_ID => P_ASSIGNMENT_ID
,P_GAP_ABSENCE_PLAN_ID => P_GAP_ABSENCE_PLAN_ID
,P_SUMMARY_TYPE => P_SUMMARY_TYPE
,P_GAP_LEVEL => P_GAP_LEVEL
,P_DURATION_IN_DAYS => P_DURATION_IN_DAYS
,P_DURATION_IN_HOURS => P_DURATION_IN_HOURS
,P_DATE_START => P_DATE_START
,P_DATE_END => P_DATE_END
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'PQP_GAP_DURATION_SUMMARY', 'AI');
hr_utility.set_location(' Leaving: PQP_GDS_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQP_GDS_RKI;

/