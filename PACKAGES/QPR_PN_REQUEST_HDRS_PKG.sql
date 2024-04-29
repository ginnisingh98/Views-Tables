--------------------------------------------------------
--  DDL for Package QPR_PN_REQUEST_HDRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_PN_REQUEST_HDRS_PKG" AUTHID CURRENT_USER as
/* $Header: QPRUPRHS.pls 120.0 2007/12/24 20:04:56 vinnaray noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REQUEST_HEADER_ID in NUMBER,
  X_SOURCE_REF_HDR_LONG_DESC in VARCHAR2,
--  X_ORG_SHORT_DESC in VARCHAR2,
--  X_ORG_LONG_DESC in VARCHAR2,
  X_CUSTOMER_SHORT_DESC in VARCHAR2,
  X_CUSTOMER_LONG_DESC in VARCHAR2,
--  X_CONTRACT_SHORT_DESC in VARCHAR2,
--  X_CONTRACT_LONG_DESC in VARCHAR2,
  X_SALES_REP_SHORT_DESC in VARCHAR2,
  X_SALES_REP_LONG_DESC in VARCHAR2,
  X_SALES_CHANNEL_SHORT_DESC in VARCHAR2,
  X_SALES_CHANNEL_LONG_DESC in VARCHAR2,
  X_FREIGHT_TERMS_SHORT_DESC in VARCHAR2,
  X_FREIGHT_TERMS_LONG_DESC in VARCHAR2,
  X_PAYMENT_TERMS_SHORT_DESC in VARCHAR2,
  X_PAYMENT_TERMS_LONG_DESC in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MEASURE1_NUMBER in NUMBER,
  X_MEASURE2_NUMBER in NUMBER,
  X_MEASURE3_NUMBER in NUMBER,
  X_MEASURE4_NUMBER in NUMBER,
  X_MEASURE5_NUMBER in NUMBER,
  X_MEASURE6_NUMBER in NUMBER,
  X_MEASURE7_NUMBER in NUMBER,
  X_MEASURE8_NUMBER in NUMBER,
  X_MEASURE9_NUMBER in NUMBER,
  X_MEASURE10_NUMBER in NUMBER,
  X_MEASURE1_CHAR in VARCHAR2,
  X_MEASURE2_CHAR in VARCHAR2,
  X_MEASURE3_CHAR in VARCHAR2,
  X_MEASURE4_CHAR in VARCHAR2,
  X_MEASURE5_CHAR in VARCHAR2,
  X_MEASURE6_CHAR in VARCHAR2,
  X_MEASURE7_CHAR in VARCHAR2,
  X_MEASURE8_CHAR in VARCHAR2,
  X_MEASURE9_CHAR in VARCHAR2,
  X_MEASURE10_CHAR in VARCHAR2,
--  X_PROGRAM_LOGIN_ID in NUMBER,
--  X_REQUEST_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_SIMULATION_FLAG in VARCHAR2,
  X_CUSTOMER_SK in VARCHAR2,
  X_SALES_CHANNEL_SK in VARCHAR2,
  X_SALES_REP_SK in VARCHAR2,
  X_PN_INT_HEADER_ID in NUMBER,
  X_SOURCE_ID in NUMBER,
  X_SOURCE_REF_HDR_ID in NUMBER,
  X_CUSTOMER_ID in NUMBER,
--  X_CONTRACT_ID in NUMBER,
  X_SALES_REP_ID in NUMBER,
  X_PAYMENT_TERMS_ID in NUMBER,
  X_INVOICE_TO_PARTY_SITE_ID in NUMBER,
  X_SALES_REP_EMAIL in VARCHAR2,
  X_SALES_CHANNEL_CODE in VARCHAR2,
  X_DEAL_EXPIRY_DATE in DATE,
  X_DEAL_CREATION_DATE in DATE,
  X_INVOICE_TO_PARTY_SITE_ADDRES in VARCHAR2,
--  X_PRIORITY in VARCHAR2,
  X_CURRENCY_SHORT_DESC in VARCHAR2,
  X_CURRENCY_LONG_DESC in VARCHAR2,
  X_SOURCE_SHORT_DESC in VARCHAR2,
  X_SOURCE_LONG_DESC in VARCHAR2,
  X_SOURCE_REF_HDR_SHORT_DESC in VARCHAR2,
  X_REFERENCE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_REQUEST_HEADER_ID in NUMBER,
  X_SOURCE_REF_HDR_LONG_DESC in VARCHAR2,
--  X_ORG_SHORT_DESC in VARCHAR2,
--  X_ORG_LONG_DESC in VARCHAR2,
  X_CUSTOMER_SHORT_DESC in VARCHAR2,
  X_CUSTOMER_LONG_DESC in VARCHAR2,
 -- X_CONTRACT_SHORT_DESC in VARCHAR2,
  --X_CONTRACT_LONG_DESC in VARCHAR2,
  X_SALES_REP_SHORT_DESC in VARCHAR2,
  X_SALES_REP_LONG_DESC in VARCHAR2,
  X_SALES_CHANNEL_SHORT_DESC in VARCHAR2,
  X_SALES_CHANNEL_LONG_DESC in VARCHAR2,
  X_FREIGHT_TERMS_SHORT_DESC in VARCHAR2,
  X_FREIGHT_TERMS_LONG_DESC in VARCHAR2,
  X_PAYMENT_TERMS_SHORT_DESC in VARCHAR2,
  X_PAYMENT_TERMS_LONG_DESC in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MEASURE1_NUMBER in NUMBER,
  X_MEASURE2_NUMBER in NUMBER,
  X_MEASURE3_NUMBER in NUMBER,
  X_MEASURE4_NUMBER in NUMBER,
  X_MEASURE5_NUMBER in NUMBER,
  X_MEASURE6_NUMBER in NUMBER,
  X_MEASURE7_NUMBER in NUMBER,
  X_MEASURE8_NUMBER in NUMBER,
  X_MEASURE9_NUMBER in NUMBER,
  X_MEASURE10_NUMBER in NUMBER,
  X_MEASURE1_CHAR in VARCHAR2,
  X_MEASURE2_CHAR in VARCHAR2,
  X_MEASURE3_CHAR in VARCHAR2,
  X_MEASURE4_CHAR in VARCHAR2,
  X_MEASURE5_CHAR in VARCHAR2,
  X_MEASURE6_CHAR in VARCHAR2,
  X_MEASURE7_CHAR in VARCHAR2,
  X_MEASURE8_CHAR in VARCHAR2,
  X_MEASURE9_CHAR in VARCHAR2,
  X_MEASURE10_CHAR in VARCHAR2,
--  X_PROGRAM_LOGIN_ID in NUMBER,
--  X_REQUEST_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_SIMULATION_FLAG in VARCHAR2,
  X_CUSTOMER_SK in VARCHAR2,
  X_SALES_CHANNEL_SK in VARCHAR2,
  X_SALES_REP_SK in VARCHAR2,
  X_PN_INT_HEADER_ID in NUMBER,
  X_SOURCE_ID in NUMBER,
  X_SOURCE_REF_HDR_ID in NUMBER,
  X_CUSTOMER_ID in NUMBER,
--  X_CONTRACT_ID in NUMBER,
  X_SALES_REP_ID in NUMBER,
  X_PAYMENT_TERMS_ID in NUMBER,
  X_INVOICE_TO_PARTY_SITE_ID in NUMBER,
  X_SALES_REP_EMAIL in VARCHAR2,
  X_SALES_CHANNEL_CODE in VARCHAR2,
  X_DEAL_EXPIRY_DATE in DATE,
  X_DEAL_CREATION_DATE in DATE,
  X_INVOICE_TO_PARTY_SITE_ADDRES in VARCHAR2,
--  X_PRIORITY in VARCHAR2,
  X_CURRENCY_SHORT_DESC in VARCHAR2,
  X_CURRENCY_LONG_DESC in VARCHAR2,
  X_SOURCE_SHORT_DESC in VARCHAR2,
  X_SOURCE_LONG_DESC in VARCHAR2,
  X_SOURCE_REF_HDR_SHORT_DESC in VARCHAR2,
  X_REFERENCE_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_REQUEST_HEADER_ID in NUMBER,
  X_SOURCE_REF_HDR_LONG_DESC in VARCHAR2,
--  X_ORG_SHORT_DESC in VARCHAR2,
--  X_ORG_LONG_DESC in VARCHAR2,
  X_CUSTOMER_SHORT_DESC in VARCHAR2,
  X_CUSTOMER_LONG_DESC in VARCHAR2,
--  X_CONTRACT_SHORT_DESC in VARCHAR2,
--  X_CONTRACT_LONG_DESC in VARCHAR2,
  X_SALES_REP_SHORT_DESC in VARCHAR2,
  X_SALES_REP_LONG_DESC in VARCHAR2,
  X_SALES_CHANNEL_SHORT_DESC in VARCHAR2,
  X_SALES_CHANNEL_LONG_DESC in VARCHAR2,
  X_FREIGHT_TERMS_SHORT_DESC in VARCHAR2,
  X_FREIGHT_TERMS_LONG_DESC in VARCHAR2,
  X_PAYMENT_TERMS_SHORT_DESC in VARCHAR2,
  X_PAYMENT_TERMS_LONG_DESC in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MEASURE1_NUMBER in NUMBER,
  X_MEASURE2_NUMBER in NUMBER,
  X_MEASURE3_NUMBER in NUMBER,
  X_MEASURE4_NUMBER in NUMBER,
  X_MEASURE5_NUMBER in NUMBER,
  X_MEASURE6_NUMBER in NUMBER,
  X_MEASURE7_NUMBER in NUMBER,
  X_MEASURE8_NUMBER in NUMBER,
  X_MEASURE9_NUMBER in NUMBER,
  X_MEASURE10_NUMBER in NUMBER,
  X_MEASURE1_CHAR in VARCHAR2,
  X_MEASURE2_CHAR in VARCHAR2,
  X_MEASURE3_CHAR in VARCHAR2,
  X_MEASURE4_CHAR in VARCHAR2,
  X_MEASURE5_CHAR in VARCHAR2,
  X_MEASURE6_CHAR in VARCHAR2,
  X_MEASURE7_CHAR in VARCHAR2,
  X_MEASURE8_CHAR in VARCHAR2,
  X_MEASURE9_CHAR in VARCHAR2,
  X_MEASURE10_CHAR in VARCHAR2,
--  X_PROGRAM_LOGIN_ID in NUMBER,
--  X_REQUEST_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_SIMULATION_FLAG in VARCHAR2,
  X_CUSTOMER_SK in VARCHAR2,
  X_SALES_CHANNEL_SK in VARCHAR2,
  X_SALES_REP_SK in VARCHAR2,
  X_PN_INT_HEADER_ID in NUMBER,
  X_SOURCE_ID in NUMBER,
  X_SOURCE_REF_HDR_ID in NUMBER,
  X_CUSTOMER_ID in NUMBER,
--  X_CONTRACT_ID in NUMBER,
  X_SALES_REP_ID in NUMBER,
  X_PAYMENT_TERMS_ID in NUMBER,
  X_INVOICE_TO_PARTY_SITE_ID in NUMBER,
  X_SALES_REP_EMAIL in VARCHAR2,
  X_SALES_CHANNEL_CODE in VARCHAR2,
  X_DEAL_EXPIRY_DATE in DATE,
  X_DEAL_CREATION_DATE in DATE,
  X_INVOICE_TO_PARTY_SITE_ADDRES in VARCHAR2,
--  X_PRIORITY in VARCHAR2,
  X_CURRENCY_SHORT_DESC in VARCHAR2,
  X_CURRENCY_LONG_DESC in VARCHAR2,
  X_SOURCE_SHORT_DESC in VARCHAR2,
  X_SOURCE_LONG_DESC in VARCHAR2,
  X_SOURCE_REF_HDR_SHORT_DESC in VARCHAR2,
  X_REFERENCE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_REQUEST_HEADER_ID in NUMBER
);
procedure ADD_LANGUAGE;
end QPR_PN_REQUEST_HDRS_PKG;

/