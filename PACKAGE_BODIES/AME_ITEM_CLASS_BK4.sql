--------------------------------------------------------
--  DDL for Package Body AME_ITEM_CLASS_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITEM_CLASS_BK4" as
/* $Header: amitcapi.pkb 120.1 2005/12/08 21:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:37 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_AME_ITEM_CLASS_USAGE_A
(P_ITEM_ID_QUERY in VARCHAR2
,P_ITEM_CLASS_ORDER_NUMBER in NUMBER
,P_ITEM_CLASS_PAR_MODE in VARCHAR2
,P_ITEM_CLASS_SUBLIST_MODE in VARCHAR2
,P_APPLICATION_ID in NUMBER
,P_ITEM_CLASS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: AME_ITEM_CLASS_BK4.CREATE_AME_ITEM_CLASS_USAGE_A', 10);
hr_utility.set_location(' Leaving: AME_ITEM_CLASS_BK4.CREATE_AME_ITEM_CLASS_USAGE_A', 20);
end CREATE_AME_ITEM_CLASS_USAGE_A;
procedure CREATE_AME_ITEM_CLASS_USAGE_B
(P_ITEM_ID_QUERY in VARCHAR2
,P_ITEM_CLASS_ORDER_NUMBER in NUMBER
,P_ITEM_CLASS_PAR_MODE in VARCHAR2
,P_ITEM_CLASS_SUBLIST_MODE in VARCHAR2
,P_APPLICATION_ID in NUMBER
,P_ITEM_CLASS_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: AME_ITEM_CLASS_BK4.CREATE_AME_ITEM_CLASS_USAGE_B', 10);
hr_utility.set_location(' Leaving: AME_ITEM_CLASS_BK4.CREATE_AME_ITEM_CLASS_USAGE_B', 20);
end CREATE_AME_ITEM_CLASS_USAGE_B;
end AME_ITEM_CLASS_BK4;

/
