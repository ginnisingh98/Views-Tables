--------------------------------------------------------
--  DDL for Package Body IRC_IID_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IID_RKD" as
/* $Header: iriidrhi.pkb 120.3.12010000.2 2008/11/06 13:49:47 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_INTERVIEW_DETAILS_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_STATUS_O in VARCHAR2
,P_FEEDBACK_O in VARCHAR2
,P_NOTES_O in VARCHAR2
,P_NOTES_TO_CANDIDATE_O in VARCHAR2
,P_CATEGORY_O in VARCHAR2
,P_RESULT_O in VARCHAR2
,P_IID_INFORMATION_CATEGORY_O in VARCHAR2
,P_IID_INFORMATION1_O in VARCHAR2
,P_IID_INFORMATION2_O in VARCHAR2
,P_IID_INFORMATION3_O in VARCHAR2
,P_IID_INFORMATION4_O in VARCHAR2
,P_IID_INFORMATION5_O in VARCHAR2
,P_IID_INFORMATION6_O in VARCHAR2
,P_IID_INFORMATION7_O in VARCHAR2
,P_IID_INFORMATION8_O in VARCHAR2
,P_IID_INFORMATION9_O in VARCHAR2
,P_IID_INFORMATION10_O in VARCHAR2
,P_IID_INFORMATION11_O in VARCHAR2
,P_IID_INFORMATION12_O in VARCHAR2
,P_IID_INFORMATION13_O in VARCHAR2
,P_IID_INFORMATION14_O in VARCHAR2
,P_IID_INFORMATION15_O in VARCHAR2
,P_IID_INFORMATION16_O in VARCHAR2
,P_IID_INFORMATION17_O in VARCHAR2
,P_IID_INFORMATION18_O in VARCHAR2
,P_IID_INFORMATION19_O in VARCHAR2
,P_IID_INFORMATION20_O in VARCHAR2
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_EVENT_ID_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_IID_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: IRC_IID_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end IRC_IID_RKD;

/