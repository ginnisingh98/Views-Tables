--------------------------------------------------------
--  DDL for Package Body PER_CPL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPL_RKI" as
/* $Header: pecplrhi.pkb 115.9 2003/09/09 04:41:39 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:52 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_COMPETENCE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_NAME in VARCHAR2
,P_COMPETENCE_ALIAS in VARCHAR2
,P_BEHAVIOURAL_INDICATOR in VARCHAR2
,P_DESCRIPTION in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_CPL_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_CPL_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_CPL_RKI;

/