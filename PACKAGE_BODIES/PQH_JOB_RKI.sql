--------------------------------------------------------
--  DDL for Package Body PQH_JOB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_JOB_RKI" as
/* $Header: pqwvjrhi.pkb 115.3 2002/12/05 00:32:22 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:53 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_WRKPLC_VLDTN_JOB_ID in NUMBER
,P_WRKPLC_VLDTN_OP_ID in NUMBER
,P_WRKPLC_JOB_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_JOB_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_JOB_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_JOB_RKI;

/
