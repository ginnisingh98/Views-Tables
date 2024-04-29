--------------------------------------------------------
--  DDL for Package Body PER_SLS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SLS_RKI" as
/* $Header: peslsrhi.pkb 115.2 2003/08/07 23:58:22 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_SOLUTION_SET_NAME in VARCHAR2
,P_USER_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_STATUS in VARCHAR2
,P_SOLUTION_SET_IMPL_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_SLS_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_SLS_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_SLS_RKI;

/