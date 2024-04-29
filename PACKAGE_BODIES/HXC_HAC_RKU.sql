--------------------------------------------------------
--  DDL for Package Body HXC_HAC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAC_RKU" as
 /* $Header: hxchacrhi.pkb 120.4 2006/06/13 08:42:23 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:57:54 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_APPROVAL_COMP_ID in NUMBER
,P_APPROVAL_STYLE_ID in NUMBER
,P_TIME_RECIPIENT_ID in NUMBER
,P_APPROVAL_MECHANISM in VARCHAR2
,P_APPROVAL_MECHANISM_ID in NUMBER
,P_WF_ITEM_TYPE in VARCHAR2
,P_WF_NAME in VARCHAR2
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_APPROVAL_ORDER in NUMBER
,P_TIME_CATEGORY_ID in NUMBER
,P_PARENT_COMP_ID in NUMBER
,P_PARENT_COMP_OVN in NUMBER
,P_RUN_RECIPIENT_EXTENSIONS in VARCHAR2
,P_APPROVAL_STYLE_ID_O in NUMBER
,P_TIME_RECIPIENT_ID_O in NUMBER
,P_APPROVAL_MECHANISM_O in VARCHAR2
,P_APPROVAL_MECHANISM_ID_O in NUMBER
,P_WF_ITEM_TYPE_O in VARCHAR2
,P_WF_NAME_O in VARCHAR2
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_APPROVAL_ORDER_O in NUMBER
,P_TIME_CATEGORY_ID_O in NUMBER
,P_PARENT_COMP_ID_O in NUMBER
,P_PARENT_COMP_OVN_O in NUMBER
,P_RUN_RECIPIENT_EXTENSIONS_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HXC_HAC_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: HXC_HAC_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HXC_HAC_RKU;

/