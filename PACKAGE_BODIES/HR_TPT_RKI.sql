--------------------------------------------------------
--  DDL for Package Body HR_TPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TPT_RKI" as
/* $Header: hrtptrhi.pkb 115.4 2002/12/03 13:09:29 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:24 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_TAB_PAGE_PROPERTY_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_LABEL in VARCHAR2
)is
begin
hr_utility.set_location('Entering: hr_tpt_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: hr_tpt_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end hr_tpt_RKI;

/
