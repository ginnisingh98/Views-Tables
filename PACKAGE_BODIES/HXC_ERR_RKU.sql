--------------------------------------------------------
--  DDL for Package Body HXC_ERR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ERR_RKU" as
/* $Header: hxcerrrhi.pkb 120.2 2005/09/23 08:08:12 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:57:39 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ERROR_ID in NUMBER
,P_TRANSACTION_DETAIL_ID in NUMBER
,P_TIME_BUILDING_BLOCK_ID in NUMBER
,P_TIME_BUILDING_BLOCK_OVN in NUMBER
,P_TIME_ATTRIBUTE_ID in NUMBER
,P_TIME_ATTRIBUTE_OVN in NUMBER
,P_MESSAGE_NAME in VARCHAR2
,P_MESSAGE_LEVEL in VARCHAR2
,P_MESSAGE_FIELD in VARCHAR2
,P_MESSAGE_TOKENS in VARCHAR2
,P_APPLICATION_SHORT_NAME in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TRANSACTION_DETAIL_ID_O in NUMBER
,P_TIME_BUILDING_BLOCK_ID_O in NUMBER
,P_TIME_BUILDING_BLOCK_OVN_O in NUMBER
,P_TIME_ATTRIBUTE_ID_O in NUMBER
,P_TIME_ATTRIBUTE_OVN_O in NUMBER
,P_MESSAGE_NAME_O in VARCHAR2
,P_MESSAGE_LEVEL_O in VARCHAR2
,P_MESSAGE_FIELD_O in VARCHAR2
,P_MESSAGE_TOKENS_O in VARCHAR2
,P_APPLICATION_SHORT_NAME_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_ERR_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: HXC_ERR_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HXC_ERR_RKU;

/