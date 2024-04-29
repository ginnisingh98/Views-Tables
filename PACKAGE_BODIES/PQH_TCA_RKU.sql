--------------------------------------------------------
--  DDL for Package Body PQH_TCA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCA_RKU" as
/* $Header: pqtcarhi.pkb 120.2 2005/10/12 20:19:48 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:44 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_TXN_CATEGORY_ATTRIBUTE_ID in NUMBER
,P_ATTRIBUTE_ID in NUMBER
,P_TRANSACTION_CATEGORY_ID in NUMBER
,P_VALUE_SET_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TRANSACTION_TABLE_ROUTE_ID in NUMBER
,P_FORM_COLUMN_NAME in VARCHAR2
,P_IDENTIFIER_FLAG in VARCHAR2
,P_LIST_IDENTIFYING_FLAG in VARCHAR2
,P_MEMBER_IDENTIFYING_FLAG in VARCHAR2
,P_REFRESH_FLAG in VARCHAR2
,P_SELECT_FLAG in VARCHAR2
,P_VALUE_STYLE_CD in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_ATTRIBUTE_ID_O in NUMBER
,P_TRANSACTION_CATEGORY_ID_O in NUMBER
,P_VALUE_SET_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_TRANSACTION_TABLE_ROUTE_ID_O in NUMBER
,P_FORM_COLUMN_NAME_O in VARCHAR2
,P_IDENTIFIER_FLAG_O in VARCHAR2
,P_LIST_IDENTIFYING_FLAG_O in VARCHAR2
,P_MEMBER_IDENTIFYING_FLAG_O in VARCHAR2
,P_REFRESH_FLAG_O in VARCHAR2
,P_SELECT_FLAG_O in VARCHAR2
,P_VALUE_STYLE_CD_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_TCA_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_TCA_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_TCA_RKU;

/
