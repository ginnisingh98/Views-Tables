--------------------------------------------------------
--  DDL for Package Body FF_FFP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FFP_RKI" as
/* $Header: ffffprhi.pkb 120.0 2005/05/27 23:24 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:51:50 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_FUNCTION_ID in NUMBER
,P_SEQUENCE_NUMBER in NUMBER
,P_CLASS in VARCHAR2
,P_CONTINUING_PARAMETER in VARCHAR2
,P_DATA_TYPE in VARCHAR2
,P_NAME in VARCHAR2
,P_OPTIONAL in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: FF_FFP_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: FF_FFP_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end FF_FFP_RKI;

/