--------------------------------------------------------
--  DDL for Package Body PQP_FXT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_FXT_RKD" as
/* $Header: pqfxtrhi.pkb 120.0 2006/04/26 23:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:36:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_FLXDU_XML_TAG_ID in NUMBER
,P_FLXDU_COLUMN_ID_O in NUMBER
,P_FLXDU_XML_TAG_NAME_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQP_FXT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQP_FXT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQP_FXT_RKD;

/
