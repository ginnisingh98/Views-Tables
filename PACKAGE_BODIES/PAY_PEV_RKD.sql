--------------------------------------------------------
--  DDL for Package Body PAY_PEV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEV_RKD" as
/* $Header: pypperhi.pkb 120.1.12010000.1 2008/07/27 23:25:17 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:33 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PROCESS_EVENT_ID in NUMBER
,P_ASSIGNMENT_ID_O in NUMBER
,P_EFFECTIVE_DATE_O in DATE
,P_CHANGE_TYPE_O in VARCHAR2
,P_STATUS_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_EVENT_UPDATE_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ORG_PROCESS_EVENT_GROUP_ID_O in NUMBER
,P_SURROGATE_KEY_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CALCULATION_DATE_O in DATE
,P_RETROACTIVE_STATUS_O in VARCHAR2
,P_NOTED_VALUE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_PEV_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_PEV_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_PEV_RKD;

/
