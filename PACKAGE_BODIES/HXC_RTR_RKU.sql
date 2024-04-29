--------------------------------------------------------
--  DDL for Package Body HXC_RTR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RTR_RKU" as
/* $Header: hxcrtrrhi.pkb 120.2 2005/09/23 08:54:01 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:58:03 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_RETRIEVAL_RULE_ID in NUMBER
,P_RETRIEVAL_PROCESS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_NAME in VARCHAR2
,P_RETRIEVAL_PROCESS_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_NAME_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HXC_RTR_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: HXC_RTR_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HXC_RTR_RKU;

/