--------------------------------------------------------
--  DDL for Package Body AME_ATTRIBUTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATTRIBUTE_BK1" as
/* $Header: amatrapi.pkb 120.1.12010000.3 2019/09/11 13:22:23 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2023/07/12 17:42:17 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_AME_ATTRIBUTE_A
(P_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_ATTRIBUTE_TYPE in VARCHAR2
,P_ITEM_CLASS_ID in NUMBER
,P_APPROVER_TYPE_ID in NUMBER
,P_ATTRIBUTE_ID in NUMBER
,P_ATR_OBJECT_VERSION_NUMBER in NUMBER
,P_ATR_START_DATE in DATE
,P_ATR_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: AME_ATTRIBUTE_BK1.CREATE_AME_ATTRIBUTE_A', 10);
hr_utility.set_location(' Leaving: AME_ATTRIBUTE_BK1.CREATE_AME_ATTRIBUTE_A', 20);
end CREATE_AME_ATTRIBUTE_A;
procedure CREATE_AME_ATTRIBUTE_B
(P_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_ATTRIBUTE_TYPE in VARCHAR2
,P_ITEM_CLASS_ID in NUMBER
,P_APPROVER_TYPE_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: AME_ATTRIBUTE_BK1.CREATE_AME_ATTRIBUTE_B', 10);
hr_utility.set_location(' Leaving: AME_ATTRIBUTE_BK1.CREATE_AME_ATTRIBUTE_B', 20);
end CREATE_AME_ATTRIBUTE_B;
end AME_ATTRIBUTE_BK1;

/