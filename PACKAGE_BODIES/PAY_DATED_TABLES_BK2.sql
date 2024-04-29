--------------------------------------------------------
--  DDL for Package Body PAY_DATED_TABLES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DATED_TABLES_BK2" as
/* $Header: pyptaapi.pkb 115.8 2002/12/05 12:35:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:18 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_DATED_TABLE_A
(P_DATED_TABLE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TABLE_NAME in VARCHAR2
,P_APPLICATION_ID in NUMBER
,P_SURROGATE_KEY_NAME in VARCHAR2
,P_START_DATE_NAME in VARCHAR2
,P_END_DATE_NAME in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_DYN_TRIGGER_TYPE in VARCHAR2
,P_DYN_TRIGGER_PACKAGE_NAME in VARCHAR2
,P_DYN_TRIG_PKG_GENERATED in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_DATED_TABLES_BK2.UPDATE_DATED_TABLE_A', 10);
hr_utility.set_location(' Leaving: PAY_DATED_TABLES_BK2.UPDATE_DATED_TABLE_A', 20);
end UPDATE_DATED_TABLE_A;
procedure UPDATE_DATED_TABLE_B
(P_DATED_TABLE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TABLE_NAME in VARCHAR2
,P_APPLICATION_ID in NUMBER
,P_SURROGATE_KEY_NAME in VARCHAR2
,P_START_DATE_NAME in VARCHAR2
,P_END_DATE_NAME in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_DYN_TRIGGER_TYPE in VARCHAR2
,P_DYN_TRIGGER_PACKAGE_NAME in VARCHAR2
,P_DYN_TRIG_PKG_GENERATED in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_DATED_TABLES_BK2.UPDATE_DATED_TABLE_B', 10);
hr_utility.set_location(' Leaving: PAY_DATED_TABLES_BK2.UPDATE_DATED_TABLE_B', 20);
end UPDATE_DATED_TABLE_B;
end PAY_DATED_TABLES_BK2;

/
