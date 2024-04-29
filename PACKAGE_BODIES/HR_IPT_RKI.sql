--------------------------------------------------------
--  DDL for Package Body HR_IPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IPT_RKI" as
/* $Header: hriptrhi.pkb 115.9 2003/05/06 17:43:05 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:04 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ITEM_PROPERTY_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_DEFAULT_VALUE in VARCHAR2
,P_INFORMATION_PROMPT in VARCHAR2
,P_LABEL in VARCHAR2
,P_PROMPT_TEXT in VARCHAR2
,P_TOOLTIP_TEXT in VARCHAR2
)is
begin
hr_utility.set_location('Entering: hr_ipt_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: hr_ipt_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end hr_ipt_RKI;

/
