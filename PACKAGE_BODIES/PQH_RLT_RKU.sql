--------------------------------------------------------
--  DDL for Package Body PQH_RLT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RLT_RKU" as
/* $Header: pqrltrhi.pkb 115.8 2004/02/26 10:32:25 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:37 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ROUTING_LIST_ID in NUMBER
,P_ROUTING_LIST_NAME in VARCHAR2
,P_ENABLE_FLAG in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ROUTING_LIST_NAME_O in VARCHAR2
,P_ENABLE_FLAG_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_RLT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_RLT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_RLT_RKU;

/
