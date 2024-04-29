--------------------------------------------------------
--  DDL for Package Body PQH_RTM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RTM_RKU" as
/* $Header: pqrtmrhi.pkb 120.2 2006/01/05 15:29:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:41 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ROLE_TEMPLATE_ID in NUMBER
,P_ROLE_ID in NUMBER
,P_TRANSACTION_CATEGORY_ID in NUMBER
,P_TEMPLATE_ID in NUMBER
,P_ENABLE_FLAG in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_ROLE_ID_O in NUMBER
,P_TRANSACTION_CATEGORY_ID_O in NUMBER
,P_TEMPLATE_ID_O in NUMBER
,P_ENABLE_FLAG_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_RTM_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_RTM_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_RTM_RKU;

/
