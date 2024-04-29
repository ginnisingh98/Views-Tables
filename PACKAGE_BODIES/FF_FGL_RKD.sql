--------------------------------------------------------
--  DDL for Package Body FF_FGL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FGL_RKD" as
/* $Header: fffglrhi.pkb 120.0.12000000.1 2007/03/20 11:52:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:57:11 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_GLOBAL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_DATA_TYPE_O in VARCHAR2
,P_GLOBAL_NAME_O in VARCHAR2
,P_GLOBAL_DESCRIPTION_O in VARCHAR2
,P_GLOBAL_VALUE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: FF_FGL_RKD.AFTER_DELETE', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
PAY_DYT_GLOBALS_PKG.AFTER_DELETE
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_DATETRACK_MODE => P_DATETRACK_MODE
,P_VALIDATION_START_DATE => P_VALIDATION_START_DATE
,P_VALIDATION_END_DATE => P_VALIDATION_END_DATE
,P_GLOBAL_ID => P_GLOBAL_ID
,P_EFFECTIVE_START_DATE => P_EFFECTIVE_START_DATE
,P_EFFECTIVE_END_DATE => P_EFFECTIVE_END_DATE
,P_EFFECTIVE_START_DATE_O => P_EFFECTIVE_START_DATE_O
,P_EFFECTIVE_END_DATE_O => P_EFFECTIVE_END_DATE_O
,P_BUSINESS_GROUP_ID_O => P_BUSINESS_GROUP_ID_O
,P_LEGISLATION_CODE_O => P_LEGISLATION_CODE_O
,P_DATA_TYPE_O => P_DATA_TYPE_O
,P_GLOBAL_NAME_O => P_GLOBAL_NAME_O
,P_GLOBAL_DESCRIPTION_O => P_GLOBAL_DESCRIPTION_O
,P_GLOBAL_VALUE_O => P_GLOBAL_VALUE_O
,P_OBJECT_VERSION_NUMBER_O => P_OBJECT_VERSION_NUMBER_O
);
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'FF_GLOBALS_F', 'AD');
hr_utility.set_location(' Leaving: FF_FGL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end FF_FGL_RKD;

/