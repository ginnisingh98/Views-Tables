--------------------------------------------------------
--  DDL for Package Body PAY_PTA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PTA_RKD" as
/* $Header: pyptarhi.pkb 120.0 2005/05/29 07:56:20 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_DATED_TABLE_ID in NUMBER
,P_TABLE_NAME_O in VARCHAR2
,P_APPLICATION_ID_O in NUMBER
,P_SURROGATE_KEY_NAME_O in VARCHAR2
,P_START_DATE_NAME_O in VARCHAR2
,P_END_DATE_NAME_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_DYN_TRIGGER_TYPE_O in VARCHAR2
,P_DYN_TRIGGER_PACKAGE_NAME_O in VARCHAR2
,P_DYN_TRIG_PKG_GENERATED_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_PTA_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_PTA_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_PTA_RKD;

/