--------------------------------------------------------
--  DDL for Package Body HR_TIS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIS_RKU" as
/* $Header: hrtisrhi.pkb 120.3 2008/02/25 13:24:06 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:53 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_TOPIC_INTEGRATIONS_ID in NUMBER
,P_TOPIC_ID in NUMBER
,P_INTEGRATION_ID in NUMBER
,P_PARAM_NAME1 in VARCHAR2
,P_PARAM_VALUE1 in VARCHAR2
,P_PARAM_NAME2 in VARCHAR2
,P_PARAM_VALUE2 in VARCHAR2
,P_PARAM_NAME3 in VARCHAR2
,P_PARAM_VALUE3 in VARCHAR2
,P_PARAM_NAME4 in VARCHAR2
,P_PARAM_VALUE4 in VARCHAR2
,P_PARAM_NAME5 in VARCHAR2
,P_PARAM_VALUE5 in VARCHAR2
,P_PARAM_NAME6 in VARCHAR2
,P_PARAM_VALUE6 in VARCHAR2
,P_PARAM_NAME7 in VARCHAR2
,P_PARAM_VALUE7 in VARCHAR2
,P_PARAM_NAME8 in VARCHAR2
,P_PARAM_VALUE8 in VARCHAR2
,P_PARAM_NAME9 in VARCHAR2
,P_PARAM_VALUE9 in VARCHAR2
,P_PARAM_NAME10 in VARCHAR2
,P_PARAM_VALUE10 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TOPIC_ID_O in NUMBER
,P_INTEGRATION_ID_O in NUMBER
,P_PARAM_NAME1_O in VARCHAR2
,P_PARAM_VALUE1_O in VARCHAR2
,P_PARAM_NAME2_O in VARCHAR2
,P_PARAM_VALUE2_O in VARCHAR2
,P_PARAM_NAME3_O in VARCHAR2
,P_PARAM_VALUE3_O in VARCHAR2
,P_PARAM_NAME4_O in VARCHAR2
,P_PARAM_VALUE4_O in VARCHAR2
,P_PARAM_NAME5_O in VARCHAR2
,P_PARAM_VALUE5_O in VARCHAR2
,P_PARAM_NAME6_O in VARCHAR2
,P_PARAM_VALUE6_O in VARCHAR2
,P_PARAM_NAME7_O in VARCHAR2
,P_PARAM_VALUE7_O in VARCHAR2
,P_PARAM_NAME8_O in VARCHAR2
,P_PARAM_VALUE8_O in VARCHAR2
,P_PARAM_NAME9_O in VARCHAR2
,P_PARAM_VALUE9_O in VARCHAR2
,P_PARAM_NAME10_O in VARCHAR2
,P_PARAM_VALUE10_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_TIS_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: HR_TIS_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HR_TIS_RKU;

/