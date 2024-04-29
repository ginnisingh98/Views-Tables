--------------------------------------------------------
--  DDL for Package Body BEN_CSO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CSO_RKD" as
/* $Header: becsorhi.pkb 115.0 2003/03/17 13:37:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CWB_STOCK_OPTN_DTLS_ID in NUMBER
,P_GRANT_ID_O in NUMBER
,P_GRANT_NUMBER_O in VARCHAR2
,P_GRANT_NAME_O in VARCHAR2
,P_GRANT_TYPE_O in VARCHAR2
,P_GRANT_DATE_O in DATE
,P_GRANT_SHARES_O in NUMBER
,P_GRANT_PRICE_O in NUMBER
,P_VALUE_AT_GRANT_O in NUMBER
,P_CURRENT_SHARE_PRICE_O in NUMBER
,P_CURRENT_SHARES_OUTSTANDING_O in NUMBER
,P_VESTED_SHARES_O in NUMBER
,P_UNVESTED_SHARES_O in NUMBER
,P_EXERCISABLE_SHARES_O in NUMBER
,P_EXERCISED_SHARES_O in NUMBER
,P_CANCELLED_SHARES_O in NUMBER
,P_TRADING_SYMBOL_O in VARCHAR2
,P_EXPIRATION_DATE_O in DATE
,P_REASON_CODE_O in VARCHAR2
,P_CLASS_O in VARCHAR2
,P_MISC_O in VARCHAR2
,P_EMPLOYEE_NUMBER_O in VARCHAR2
,P_PERSON_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PRTT_RT_VAL_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CSO_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CSO_ATTRIBUTE1_O in VARCHAR2
,P_CSO_ATTRIBUTE2_O in VARCHAR2
,P_CSO_ATTRIBUTE3_O in VARCHAR2
,P_CSO_ATTRIBUTE4_O in VARCHAR2
,P_CSO_ATTRIBUTE5_O in VARCHAR2
,P_CSO_ATTRIBUTE6_O in VARCHAR2
,P_CSO_ATTRIBUTE7_O in VARCHAR2
,P_CSO_ATTRIBUTE8_O in VARCHAR2
,P_CSO_ATTRIBUTE9_O in VARCHAR2
,P_CSO_ATTRIBUTE10_O in VARCHAR2
,P_CSO_ATTRIBUTE11_O in VARCHAR2
,P_CSO_ATTRIBUTE12_O in VARCHAR2
,P_CSO_ATTRIBUTE13_O in VARCHAR2
,P_CSO_ATTRIBUTE14_O in VARCHAR2
,P_CSO_ATTRIBUTE15_O in VARCHAR2
,P_CSO_ATTRIBUTE16_O in VARCHAR2
,P_CSO_ATTRIBUTE17_O in VARCHAR2
,P_CSO_ATTRIBUTE18_O in VARCHAR2
,P_CSO_ATTRIBUTE19_O in VARCHAR2
,P_CSO_ATTRIBUTE20_O in VARCHAR2
,P_CSO_ATTRIBUTE21_O in VARCHAR2
,P_CSO_ATTRIBUTE22_O in VARCHAR2
,P_CSO_ATTRIBUTE23_O in VARCHAR2
,P_CSO_ATTRIBUTE24_O in VARCHAR2
,P_CSO_ATTRIBUTE25_O in VARCHAR2
,P_CSO_ATTRIBUTE26_O in VARCHAR2
,P_CSO_ATTRIBUTE27_O in VARCHAR2
,P_CSO_ATTRIBUTE28_O in VARCHAR2
,P_CSO_ATTRIBUTE29_O in VARCHAR2
,P_CSO_ATTRIBUTE30_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_CSO_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: BEN_CSO_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end BEN_CSO_RKD;

/