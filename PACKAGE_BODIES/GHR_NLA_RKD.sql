--------------------------------------------------------
--  DDL for Package Body GHR_NLA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_NLA_RKD" as
/* $Header: ghnlarhi.pkb 115.4 1999/11/09 22:41:05 generated ship    $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:53:03 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_NOAC_LA_ID in NUMBER
,P_NATURE_OF_ACTION_ID_O in NUMBER
,P_LAC_LOOKUP_CODE_O in VARCHAR2
,P_ENABLED_FLAG_O in VARCHAR2
,P_DATE_FROM_O in DATE
,P_DATE_TO_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_VALID_FIRST_LAC_FLAG_O in VARCHAR2
,P_VALID_SECOND_LAC_FLAG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ghr_nla_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ghr_nla_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ghr_nla_RKD;

/