--------------------------------------------------------
--  DDL for Package Body HXC_DTL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DTL_RKU" as
/* $Header: hxcdtlrhi.pkb 120.2 2005/09/23 08:07:34 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:57:53 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ALIAS_DEFINITION_ID in NUMBER
,P_ALIAS_DEFINITION_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_PROMPT in VARCHAR2
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_ALIAS_DEFINITION_NAME_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_PROMPT_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HXC_DTL_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: HXC_DTL_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HXC_DTL_RKU;

/
