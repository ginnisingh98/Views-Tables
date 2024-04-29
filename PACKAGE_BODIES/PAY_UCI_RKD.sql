--------------------------------------------------------
--  DDL for Package Body PAY_UCI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_UCI_RKD" as
/* $Header: pyucirhi.pkb 115.0 2003/09/23 07:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:58:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_USER_COLUMN_INSTANCE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_USER_ROW_ID_O in NUMBER
,P_USER_COLUMN_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_VALUE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PAY_UCI_RKD.AFTER_DELETE', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
PAY_DYT_USER_COLUMN_INSTA_PKG.AFTER_DELETE
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_DATETRACK_MODE => P_DATETRACK_MODE
,P_VALIDATION_START_DATE => P_VALIDATION_START_DATE
,P_VALIDATION_END_DATE => P_VALIDATION_END_DATE
,P_USER_COLUMN_INSTANCE_ID => P_USER_COLUMN_INSTANCE_ID
,P_EFFECTIVE_START_DATE => P_EFFECTIVE_START_DATE
,P_EFFECTIVE_END_DATE => P_EFFECTIVE_END_DATE
,P_EFFECTIVE_START_DATE_O => P_EFFECTIVE_START_DATE_O
,P_EFFECTIVE_END_DATE_O => P_EFFECTIVE_END_DATE_O
,P_USER_ROW_ID_O => P_USER_ROW_ID_O
,P_USER_COLUMN_ID_O => P_USER_COLUMN_ID_O
,P_BUSINESS_GROUP_ID_O => P_BUSINESS_GROUP_ID_O
,P_LEGISLATION_CODE_O => P_LEGISLATION_CODE_O
,P_VALUE_O => P_VALUE_O
,P_OBJECT_VERSION_NUMBER_O => P_OBJECT_VERSION_NUMBER_O
);
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'PAY_USER_COLUMN_INSTANCES_F', 'AD');
hr_utility.set_location(' Leaving: PAY_UCI_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_UCI_RKD;

/
