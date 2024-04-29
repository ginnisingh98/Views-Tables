--------------------------------------------------------
--  DDL for Package Body PER_BF_BALANCE_TYPES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BF_BALANCE_TYPES_BK2" as
/* $Header: pebbtapi.pkb 115.6 2002/11/29 15:28:12 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:41 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_BALANCE_TYPE_A
(P_BALANCE_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_DISPLAYED_NAME in VARCHAR2
,P_INTERNAL_NAME in VARCHAR2
,P_UOM in VARCHAR2
,P_CURRENCY in VARCHAR2
,P_CATEGORY in VARCHAR2
,P_DATE_FROM in DATE
,P_DATE_TO in DATE
,P_EFFECTIVE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_BF_BALANCE_TYPES_BK2.UPDATE_BALANCE_TYPE_A', 10);
hr_utility.set_location(' Leaving: PER_BF_BALANCE_TYPES_BK2.UPDATE_BALANCE_TYPE_A', 20);
end UPDATE_BALANCE_TYPE_A;
procedure UPDATE_BALANCE_TYPE_B
(P_BALANCE_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_DISPLAYED_NAME in VARCHAR2
,P_INTERNAL_NAME in VARCHAR2
,P_UOM in VARCHAR2
,P_CURRENCY in VARCHAR2
,P_CATEGORY in VARCHAR2
,P_DATE_FROM in DATE
,P_DATE_TO in DATE
,P_EFFECTIVE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_BF_BALANCE_TYPES_BK2.UPDATE_BALANCE_TYPE_B', 10);
hr_utility.set_location(' Leaving: PER_BF_BALANCE_TYPES_BK2.UPDATE_BALANCE_TYPE_B', 20);
end UPDATE_BALANCE_TYPE_B;
end PER_BF_BALANCE_TYPES_BK2;

/