--------------------------------------------------------
--  DDL for Package Body PQH_DEF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DEF_RKI" as
/* $Header: pqdefrhi.pkb 115.3 2002/12/12 22:52:53 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_WRKPLC_VLDTN_ID in NUMBER
,P_VALIDATION_NAME in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_EMPLOYMENT_TYPE in VARCHAR2
,P_REMUNERATION_REGULATION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DEF_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_DEF_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_DEF_RKI;

/
