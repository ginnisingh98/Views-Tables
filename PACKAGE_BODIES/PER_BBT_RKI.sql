--------------------------------------------------------
--  DDL for Package Body PER_BBT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BBT_RKI" as
/* $Header: pebbtrhi.pkb 115.7 2002/12/02 13:20:16 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:41 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_BALANCE_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_DISPLAYED_NAME in VARCHAR2
,P_INTERNAL_NAME in VARCHAR2
,P_UOM in VARCHAR2
,P_CURRENCY in VARCHAR2
,P_CATEGORY in VARCHAR2
,P_DATE_FROM in DATE
,P_DATE_TO in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_BBT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_BBT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_BBT_RKI;

/
