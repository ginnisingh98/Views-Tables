--------------------------------------------------------
--  DDL for Package Body HR_DOCUMENT_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DOCUMENT_TYPES_BK3" as
/* $Header: hrdtyapi.pkb 120.0 2005/05/30 23:53:41 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:52 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_DOCUMENT_TYPE_A
(P_DOCUMENT_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_DOCUMENT_TYPES_BK3.DELETE_DOCUMENT_TYPE_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
hr_document_types_be3.DELETE_DOCUMENT_TYPE_A
(P_DOCUMENT_TYPE_ID => P_DOCUMENT_TYPE_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'DELETE_DOCUMENT_TYPE', 'AP');
hr_utility.set_location(' Leaving: HR_DOCUMENT_TYPES_BK3.DELETE_DOCUMENT_TYPE_A', 20);
end DELETE_DOCUMENT_TYPE_A;
procedure DELETE_DOCUMENT_TYPE_B
(P_DOCUMENT_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_DOCUMENT_TYPES_BK3.DELETE_DOCUMENT_TYPE_B', 10);
hr_utility.set_location(' Leaving: HR_DOCUMENT_TYPES_BK3.DELETE_DOCUMENT_TYPE_B', 20);
end DELETE_DOCUMENT_TYPE_B;
end HR_DOCUMENT_TYPES_BK3;

/
