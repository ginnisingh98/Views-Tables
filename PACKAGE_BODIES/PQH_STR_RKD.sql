--------------------------------------------------------
--  DDL for Package Body PQH_STR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STR_RKD" as
/* $Header: pqstrrhi.pkb 115.10 2004/04/06 05:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:43 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_STAT_SITUATION_RULE_ID in NUMBER
,P_STATUTORY_SITUATION_ID_O in NUMBER
,P_PROCESSING_SEQUENCE_O in NUMBER
,P_TXN_CATEGORY_ATTRIBUTE_ID_O in NUMBER
,P_FROM_VALUE_O in VARCHAR2
,P_TO_VALUE_O in VARCHAR2
,P_ENABLED_FLAG_O in VARCHAR2
,P_REQUIRED_FLAG_O in VARCHAR2
,P_EXCLUDE_FLAG_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_STR_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_STR_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_STR_RKD;

/