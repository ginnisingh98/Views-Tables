--------------------------------------------------------
--  DDL for Package Body HR_NL_ABSENCE_ACTION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_ABSENCE_ACTION_BK1" as
/* $Header: penaaapi.pkb 115.8 2004/04/19 08:13:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:24 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ABSENCE_ACTION_A
(P_ABSENCE_ATTENDANCE_ID in NUMBER
,P_ABSENCE_ACTION_ID in NUMBER
,P_EXPECTED_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_ACTUAL_START_DATE in DATE
,P_ACTUAL_END_DATE in DATE
,P_HOLDER in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_DOCUMENT_FILE_NAME in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ENABLED in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_NL_ABSENCE_ACTION_BK1.CREATE_ABSENCE_ACTION_A', 10);
hr_utility.set_location(' Leaving: HR_NL_ABSENCE_ACTION_BK1.CREATE_ABSENCE_ACTION_A', 20);
end CREATE_ABSENCE_ACTION_A;
procedure CREATE_ABSENCE_ACTION_B
(P_ABSENCE_ATTENDANCE_ID in NUMBER
,P_EXPECTED_DATE in DATE
,P_DESCRIPTION in VARCHAR2
,P_ACTUAL_START_DATE in DATE
,P_ACTUAL_END_DATE in DATE
,P_HOLDER in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_DOCUMENT_FILE_NAME in VARCHAR2
,P_ENABLED in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_NL_ABSENCE_ACTION_BK1.CREATE_ABSENCE_ACTION_B', 10);
hr_utility.set_location(' Leaving: HR_NL_ABSENCE_ACTION_BK1.CREATE_ABSENCE_ACTION_B', 20);
end CREATE_ABSENCE_ACTION_B;
end HR_NL_ABSENCE_ACTION_BK1;

/