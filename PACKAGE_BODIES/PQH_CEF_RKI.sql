--------------------------------------------------------
--  DDL for Package Body PQH_CEF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CEF_RKI" as
/* $Header: pqcefrhi.pkb 120.2 2005/10/12 20:18:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:10 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_COPY_ENTITY_FUNCTION_ID in NUMBER
,P_TABLE_ROUTE_ID in NUMBER
,P_FUNCTION_TYPE_CD in VARCHAR2
,P_PRE_COPY_FUNCTION_NAME in VARCHAR2
,P_COPY_FUNCTION_NAME in VARCHAR2
,P_POST_COPY_FUNCTION_NAME in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CONTEXT in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_CEF_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_CEF_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_CEF_RKI;

/
