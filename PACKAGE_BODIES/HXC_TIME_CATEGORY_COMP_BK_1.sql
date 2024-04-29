--------------------------------------------------------
--  DDL for Package Body HXC_TIME_CATEGORY_COMP_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_CATEGORY_COMP_BK_1" as
/* $Header: hxctccapi.pkb 120.0 2005/05/29 05:55:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:58:04 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_TIME_CATEGORY_COMP_A
(P_TIME_CATEGORY_COMP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TIME_CATEGORY_ID in NUMBER
,P_REF_TIME_CATEGORY_ID in NUMBER
,P_COMPONENT_TYPE_ID in NUMBER
,P_FLEX_VALUE_SET_ID in NUMBER
,P_VALUE_ID in VARCHAR2
,P_IS_NULL in VARCHAR2
,P_EQUAL_TO in VARCHAR2
,P_TYPE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HXC_TIME_CATEGORY_COMP_BK_1.CREATE_TIME_CATEGORY_COMP_A', 10);
hr_utility.set_location(' Leaving: HXC_TIME_CATEGORY_COMP_BK_1.CREATE_TIME_CATEGORY_COMP_A', 20);
end CREATE_TIME_CATEGORY_COMP_A;
procedure CREATE_TIME_CATEGORY_COMP_B
(P_TIME_CATEGORY_COMP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TIME_CATEGORY_ID in NUMBER
,P_REF_TIME_CATEGORY_ID in NUMBER
,P_COMPONENT_TYPE_ID in NUMBER
,P_FLEX_VALUE_SET_ID in NUMBER
,P_VALUE_ID in VARCHAR2
,P_IS_NULL in VARCHAR2
,P_EQUAL_TO in VARCHAR2
,P_TYPE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HXC_TIME_CATEGORY_COMP_BK_1.CREATE_TIME_CATEGORY_COMP_B', 10);
hr_utility.set_location(' Leaving: HXC_TIME_CATEGORY_COMP_BK_1.CREATE_TIME_CATEGORY_COMP_B', 20);
end CREATE_TIME_CATEGORY_COMP_B;
end HXC_TIME_CATEGORY_COMP_BK_1;

/