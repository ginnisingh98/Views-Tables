--------------------------------------------------------
--  DDL for Package Body PER_BBT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BBT_RKD" as
/* $Header: pebbtrhi.pkb 115.7 2002/12/02 13:20:16 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:41 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_BALANCE_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DISPLAYED_NAME_O in VARCHAR2
,P_INTERNAL_NAME_O in VARCHAR2
,P_UOM_O in VARCHAR2
,P_CURRENCY_O in VARCHAR2
,P_CATEGORY_O in VARCHAR2
,P_DATE_FROM_O in DATE
,P_DATE_TO_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_BBT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_BBT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_BBT_RKD;

/