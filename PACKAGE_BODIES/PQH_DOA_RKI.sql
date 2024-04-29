--------------------------------------------------------
--  DDL for Package Body PQH_DOA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DOA_RKI" as
/* $Header: pqdoarhi.pkb 115.0 2003/01/06 09:20:29 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_DOCUMENT_ATTRIBUTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_DOCUMENT_ID in NUMBER
,P_ATTRIBUTE_ID in NUMBER
,P_TAG_NAME in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DOA_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_DOA_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_DOA_RKI;

/