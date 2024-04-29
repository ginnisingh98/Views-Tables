--------------------------------------------------------
--  DDL for Package Body HR_FIT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FIT_RKI" as
/* $Header: hrfitrhi.pkb 115.4 2003/05/06 11:07:14 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:30:57 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_FORM_ITEM_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_USER_ITEM_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
)is
begin
hr_utility.set_location('Entering: hr_fit_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: hr_fit_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end hr_fit_RKI;

/
