--------------------------------------------------------
--  DDL for Package Body PQH_DEF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DEF_RKD" as
/* $Header: pqdefrhi.pkb 115.3 2002/12/12 22:52:53 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_WRKPLC_VLDTN_ID in NUMBER
,P_VALIDATION_NAME_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_EMPLOYMENT_TYPE_O in VARCHAR2
,P_REMUNERATION_REGULATION_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DEF_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_DEF_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_DEF_RKD;

/