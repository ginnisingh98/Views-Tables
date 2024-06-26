--------------------------------------------------------
--  DDL for Package Body PQH_TCD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCD_RKU" as
/* $Header: pqtcdrhi.pkb 115.0 2003/05/11 13:05:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:46 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_DOCUMENT_ID in NUMBER
,P_TRANSACTION_CATEGORY_ID in NUMBER
,P_TYPE_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TYPE_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_TCD_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_TCD_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_TCD_RKU;

/
