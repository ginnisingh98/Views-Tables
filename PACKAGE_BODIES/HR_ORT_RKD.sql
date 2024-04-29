--------------------------------------------------------
--  DDL for Package Body HR_ORT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORT_RKD" as
/* $Header: hrortrhi.pkb 115.4 2004/06/29 00:31:44 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:12 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ORGANIZATION_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_NAME_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_ORT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: HR_ORT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end HR_ORT_RKD;

/
