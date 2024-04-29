--------------------------------------------------------
--  DDL for Package Body PER_COT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_COT_RKI" as
/* $Header: pecotrhi.pkb 115.0 2004/03/17 10:57 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:52 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_OUTCOME_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_NAME in VARCHAR2
,P_ASSESSMENT_CRITERIA in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_COT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_COT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_COT_RKI;

/
