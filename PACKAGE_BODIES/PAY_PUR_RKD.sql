--------------------------------------------------------
--  DDL for Package Body PAY_PUR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PUR_RKD" as
/* $Header: pypurrhi.pkb 120.1 2005/10/26 23:17 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_USER_ROW_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_DISABLE_RANGE_OVERLAP_CHECK in BOOLEAN
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_USER_TABLE_ID_O in NUMBER
,P_ROW_LOW_RANGE_OR_NAME_O in VARCHAR2
,P_DISPLAY_SEQUENCE_O in NUMBER
,P_ROW_HIGH_RANGE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_PUR_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_PUR_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_PUR_RKD;

/
