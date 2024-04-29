--------------------------------------------------------
--  DDL for Package Body ZX_AR_POPULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_AR_POPULATE_PKG" AS
/* $Header: zxrirpopulatpvtb.pls 120.41.12010000.25 2010/04/08 09:32:07 bibeura ship $ */


--Populate party info into global variables
      GT_BILLING_TP_NUMBER             ZX_EXTRACT_PKG.BILLING_TP_NUMBER_TBL;
      GT_BILLING_TP_TAX_REG_NUM        ZX_EXTRACT_PKG.BILLING_TP_TAX_REG_NUM_TBL;
      GT_BILLING_SITE_TAX_REG_NUM      ZX_EXTRACT_PKG.BILLING_TP_SITE_TX_REG_NUM_TBL;
      GT_BILLING_TP_TAXPAYER_ID        ZX_EXTRACT_PKG.BILLING_TP_TAXPAYER_ID_TBL;
      GT_BILLING_TP_SITE_NAME_ALT      ZX_EXTRACT_PKG.BILLING_TP_SITE_NAME_ALT_TBL;
      GT_BILLING_TP_NAME               ZX_EXTRACT_PKG.BILLING_TP_NAME_TBL;
      GT_BILLING_TP_NAME_ALT           ZX_EXTRACT_PKG.BILLING_TP_NAME_ALT_TBL;
      GT_BILLING_TP_SIC_CODE           ZX_EXTRACT_PKG.BILLING_TP_SIC_CODE_TBL;
      GT_BILLING_TP_CITY               ZX_EXTRACT_PKG.BILLING_TP_CITY_TBL;
      GT_BILLING_TP_COUNTY             ZX_EXTRACT_PKG.BILLING_TP_COUNTY_TBL;
      GT_BILLING_TP_STATE              ZX_EXTRACT_PKG.BILLING_TP_STATE_TBL;
      GT_BILLING_TP_PROVINCE           ZX_EXTRACT_PKG.BILLING_TP_PROVINCE_TBL;
      GT_BILLING_TP_ADDRESS1           ZX_EXTRACT_PKG.BILLING_TP_ADDRESS1_TBL;
      GT_BILLING_TP_ADDRESS2           ZX_EXTRACT_PKG.BILLING_TP_ADDRESS2_TBL;
      GT_BILLING_TP_ADDRESS3           ZX_EXTRACT_PKG.BILLING_TP_ADDRESS3_TBL;
      GT_BILLING_TP_ADDR_LINES_ALT     ZX_EXTRACT_PKG.BILLING_TP_ADDR_LINES_ALT_TBL;
      GT_BILLING_TP_COUNTRY            ZX_EXTRACT_PKG.BILLING_TP_COUNTRY_TBL;
      GT_BILLING_TP_POSTAL_CODE        ZX_EXTRACT_PKG.BILLING_TP_POSTAL_CODE_TBL;
      GT_BILLING_TP_PARTY_NUMBER       ZX_EXTRACT_PKG.BILLING_TP_PARTY_NUMBER_TBL;
      GT_BILLING_TP_ID                 ZX_EXTRACT_PKG.BILLING_TP_ID_TBL;
      GT_BILLING_TP_SITE_ID            ZX_EXTRACT_PKG.BILLING_TP_SITE_ID_TBL;
      GT_BILLING_TP_ADDRESS_ID         ZX_EXTRACT_PKG.BILLING_TP_ADDRESS_ID_TBL;
  --    GT_SHIPPING_TP_ID                ZX_EXTRACT_PKG.BILLING_TP_ID_TBL;
   --   GT_SHIPPING_TP_SITE_ID           ZX_EXTRACT_PKG.BILLING_TP_SITE_ID_TBL;
    --  GT_SHIPPING_TP_ADDRESS_ID        ZX_EXTRACT_PKG.BILLING_TP_ADDRESS_ID_TBL;
      GT_BILLING_TP_TAX_REP_FLAG       ZX_EXTRACT_PKG.BILLING_TP_TAX_REP_FLAG_TBL;
      GT_BILLING_TP_SITE_NAME          ZX_EXTRACT_PKG.BILLING_TP_SITE_NAME_TBL;
      GT_GDF_RA_ADDRESSES_BILL_ATT9    ZX_EXTRACT_PKG.GDF_RA_ADDRESSES_BILL_ATT9_TBL;
      GT_GDF_PARTY_SITES_BILL_ATT8     ZX_EXTRACT_PKG.GDF_PARTY_SITES_BILL_ATT8_TBL;
      GT_GDF_RA_CUST_BILL_ATT10        ZX_EXTRACT_PKG.GDF_RA_CUST_BILL_ATT10_TBL;
      GT_GDF_RA_CUST_BILL_ATT12        ZX_EXTRACT_PKG.GDF_RA_CUST_BILL_ATT12_TBL;
      GT_GDF_RA_ADDRESSES_BILL_ATT8    ZX_EXTRACT_PKG.GDF_RA_ADDRESSES_BILL_ATT8_TBL;
      GT_TAX_REG_NUM                   ZX_EXTRACT_PKG.HQ_ESTB_REG_NUMBER_TBL;
      GT_HQ_ESTB_REG_NUMBER            ZX_EXTRACT_PKG.HQ_ESTB_REG_NUMBER_TBL;
      GT_DOC_SEQ_ID                    ZX_EXTRACT_PKG.DOC_SEQ_ID_TBL;

      GT_DOC_SEQ_NAME                  ZX_EXTRACT_PKG.DOC_SEQ_NAME_TBL;
    GT_SHIPPING_TP_NUMBER              ZX_EXTRACT_PKG.SHIPPING_TP_NUMBER_TBL;
      GT_SHIPPING_TP_TAX_REG_NUM       ZX_EXTRACT_PKG.SHIPPING_TP_TAX_REG_NUM_TBL;
      GT_SHIPPING_TP_TAXPAYER_ID       ZX_EXTRACT_PKG.SHIPPING_TP_TAXPAYER_ID_TBL;
      GT_SHIPPING_SITE_TAX_REG_NUM     ZX_EXTRACT_PKG.SHIPPING_TP_SITE_TX_RG_NUM_TBL;
   --   GT_SHIPPING_TP_SITE_NAME_ALT      ZX_EXTRACT_PKG.SHIPPING_TP_SITE_NAME_ALT_TBL;
      GT_SHIPPING_TP_NAME              ZX_EXTRACT_PKG.SHIPPING_TP_NAME_TBL;
      GT_SHIPPING_TP_NAME_ALT          ZX_EXTRACT_PKG.SHIPPING_TP_NAME_ALT_TBL;
      GT_SHIPPING_TP_SIC_CODE          ZX_EXTRACT_PKG.SHIPPING_TP_SIC_CODE_TBL;
      GT_SHIPPING_TP_CITY              ZX_EXTRACT_PKG.SHIPPING_TP_CITY_TBL;
      GT_SHIPPING_TP_COUNTY            ZX_EXTRACT_PKG.SHIPPING_TP_COUNTY_TBL;
      GT_SHIPPING_TP_STATE             ZX_EXTRACT_PKG.SHIPPING_TP_STATE_TBL;
      GT_SHIPPING_TP_PROVINCE          ZX_EXTRACT_PKG.SHIPPING_TP_PROVINCE_TBL;
      GT_SHIPPING_TP_ADDRESS1          ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS1_TBL;
      GT_SHIPPING_TP_ADDRESS2          ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS2_TBL;
      GT_SHIPPING_TP_ADDRESS3          ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS3_TBL;
      GT_SHIPPING_TP_ADDR_LINES_ALT    ZX_EXTRACT_PKG.SHIPPING_TP_ADDR_LINES_ALT_TBL;
      GT_SHIPPING_TP_COUNTRY           ZX_EXTRACT_PKG.SHIPPING_TP_COUNTRY_TBL;
      GT_SHIPPING_TP_POSTAL_CODE       ZX_EXTRACT_PKG.SHIPPING_TP_POSTAL_CODE_TBL;
--      GT_SHIPPING_TP_PARTY_NUMBER      ZX_EXTRACT_PKG.SHIPPING_TP_PARTY_NUMBER_TBL;
      GT_SHIPPING_TP_ID                ZX_EXTRACT_PKG.SHIPPING_TP_ID_TBL;
      GT_SHIPPING_TP_SITE_ID           ZX_EXTRACT_PKG.SHIPPING_TP_SITE_ID_TBL;
      GT_SHIPPING_TP_ADDRESS_ID        ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL;
--      GT_SHIPPING_TP_TAX_REP_FLAG      ZX_EXTRACT_PKG.SHIPPING_TP_TAX_REP_FLAG_TBL;
      GT_SHIPPING_TP_SITE_NAME         ZX_EXTRACT_PKG.SHIPPING_TP_SITE_NAME_TBL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT9    ZX_EXTRACT_PKG.GDF_RA_ADDRESSES_SHIP_ATT9_TBL;
      GT_GDF_PARTY_SITES_SHIP_ATT8     ZX_EXTRACT_PKG.GDF_PARTY_SITES_SHIP_ATT8_TBL;
      GT_GDF_RA_CUST_SHIP_ATT10        ZX_EXTRACT_PKG.GDF_RA_CUST_SHIP_ATT10_TBL;
      GT_GDF_RA_CUST_SHIP_ATT12        ZX_EXTRACT_PKG.GDF_RA_CUST_SHIP_ATT12_TBL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT8    ZX_EXTRACT_PKG.GDF_RA_ADDRESSES_SHIP_ATT8_TBL;
      GT_TAX_RATE_VAT_TRX_TYPE_DESC    ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_DESC_TBL;
      GT_TAX_RATE_VAT_TRX_TYPE_MNG     ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_MNG_TBL;
      GT_TAX_RATE_CODE_REG_TYPE_MNG    ZX_EXTRACT_PKG.TAX_RATE_CODE_REG_TYPE_MNG_TBL;
      GT_TRX_CLASS_MNG                 ZX_EXTRACT_PKG.TRX_CLASS_MNG_TBL;
      GT_TAX_EXCEPTION_REASON_MNG      ZX_EXTRACT_PKG.TAX_EXCEPTION_REASON_MNG_TBL;
      GT_TAX_EXEMPT_REASON_MNG         ZX_EXTRACT_PKG.TAX_EXEMPT_REASON_MNG_TBL;
      GT_LEDGER_NAME                   ZX_EXTRACT_PKG.LEDGER_NAME_TBL;
      GT_BANKING_TP_TAXPAYER_ID        ZX_EXTRACT_PKG.BANKING_TP_TAXPAYER_ID_TBL;

      GT_DETAIL_TAX_LINE_ID         ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
      GT_LEDGER_ID                  ZX_EXTRACT_PKG.LEDGER_ID_TBL;
      GT_TRX_ID                     ZX_EXTRACT_PKG.TRX_ID_TBL;
      GT_BANK_ACCOUNT_ID            ZX_EXTRACT_PKG.BANK_ACCOUNT_ID_TBL;
      GT_TRX_TYPE_ID                ZX_EXTRACT_PKG.TRX_TYPE_ID_TBL;
      GT_TRX_CLASS                  ZX_EXTRACT_PKG.TRX_LINE_CLASS_TBL;
      GT_TRX_BATCH_SOURCE_ID        ZX_EXTRACT_PKG.BATCH_SOURCE_ID_TBL;
      GT_TAX_RATE_ID                ZX_EXTRACT_PKG.TAX_RATE_ID_TBL;
      GT_TAX_RATE_VAT_TRX_TYPE_CODE ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_CODE_TBL;
      GT_TAX_RATE_REG_TYPE_CODE     ZX_EXTRACT_PKG.TAX_RATE_REG_TYPE_CODE_TBL;
      GT_TAX_EXEMPTION_ID           ZX_EXTRACT_PKG.TAX_EXEMPTION_ID_TBL;
      GT_TAX_EXCEPTION_ID           ZX_EXTRACT_PKG.TAX_EXCEPTION_ID_TBL;
      GT_TAX_LINE_ID                ZX_EXTRACT_PKG.TAX_LINE_ID_TBL;
      GT_TAX_AMT                    ZX_EXTRACT_PKG.TAX_AMT_TBL;
      GT_TAX_AMT_FUNCL_CURR         ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL;
      GT_TAX_LINE_NUMBER            ZX_EXTRACT_PKG.TAX_LINE_NUMBER_TBL;
      GT_TAXABLE_AMT                ZX_EXTRACT_PKG.TAXABLE_AMT_TBL;
      GT_TAXABLE_AMT_FUNCL_CURR     ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL;
      GT_TRX_LINE_ID                ZX_EXTRACT_PKG.TRX_LINE_ID_TBL;
      GT_TAX_EXCEPTION_REASON_CODE  ZX_EXTRACT_PKG.TAX_EXCEPTION_REASON_CODE_TBL;
      GT_EXEMPT_REASON_CODE         ZX_EXTRACT_PKG.EXEMPT_REASON_CODE_TBL;
      GT_RECONCILIATION_FLAG        ZX_EXTRACT_PKG.RECONCILIATION_FLAG_TBL;
      GT_INTERNAL_ORGANIZATION_ID   ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL;
      GT_TAX_DATE                   ZX_EXTRACT_PKG.TAX_DATE_TBL;
      GT_BR_REF_CUSTOMER_TRX_ID     ZX_EXTRACT_PKG.BR_REF_CUSTOMER_TRX_ID_TBL;
      GT_REVERSE_FLAG               ZX_EXTRACT_PKG.REVERSE_FLAG_TBL;
      GT_AMOUNT_APPLIED             ZX_EXTRACT_PKG.AMOUNT_APPLIED_TBL;
      GT_TAX_RATE                   ZX_EXTRACT_PKG.TAX_RATE_TBL;
      GT_TAX_RATE_CODE              ZX_EXTRACT_PKG.TAX_RATE_CODE_TBL;
      GT_TAX_RATE_CODE_NAME         ZX_EXTRACT_PKG.TAX_RATE_CODE_NAME_TBL;
      GT_TAX_TYPE_CODE              ZX_EXTRACT_PKG.TAX_TYPE_CODE_TBL;
      GT_TRX_DATE                   ZX_EXTRACT_PKG.TRX_DATE_TBL;
      GT_TRX_CURRENCY_CODE          ZX_EXTRACT_PKG.TRX_CURRENCY_CODE_TBL;
      GT_CURRENCY_CONVERSION_RATE   ZX_EXTRACT_PKG.CURRENCY_CONVERSION_RATE_TBL;
      GT_APPLICATION_ID             ZX_EXTRACT_PKG.APPLICATION_ID_TBL;
      GT_DOC_EVENT_STATUS           ZX_EXTRACT_PKG.DOC_EVENT_STATUS_TBL;
      GT_EXTRACT_SOURCE_LEDGER      ZX_EXTRACT_PKG.EXTRACT_SOURCE_LEDGER_TBL;
      GT_FUNCTIONAL_CURRENCY_CODE   ZX_EXTRACT_PKG.FUNCTIONAL_CURRENCY_CODE_TBL;
      GT_MINIMUM_ACCOUNTABLE_UNIT   ZX_EXTRACT_PKG.MINIMUM_ACCOUNTABLE_UNIT_TBL;
      GT_PRECISION                  ZX_EXTRACT_PKG.PRECISION_TBL;
      GT_RECEIPT_CLASS_ID           ZX_EXTRACT_PKG.RECEIPT_CLASS_ID_TBL;
      GT_EXCEPTION_RATE             ZX_EXTRACT_PKG.EXCEPTION_RATE_TBL;
      GT_SHIP_FROM_PARTY_TAX_PROF_ID   ZX_EXTRACT_PKG.SHIP_FROM_PTY_TAX_PROF_ID_TBL;
      GT_SHIP_FROM_SITE_TAX_PROF_ID    ZX_EXTRACT_PKG.SHIP_FROM_SITE_TAX_PROF_ID_TBL;
      GT_SHIP_TO_PARTY_TAX_PROF_ID     ZX_EXTRACT_PKG.SHIP_TO_PARTY_TAX_PROF_ID_TBL;
      GT_SHIP_TO_SITE_TAX_PROF_ID      ZX_EXTRACT_PKG.SHIP_TO_SITE_TAX_PROF_ID_TBL;
      GT_BILL_TO_PARTY_TAX_PROF_ID     ZX_EXTRACT_PKG.BILL_TO_PARTY_TAX_PROF_ID_TBL;
      GT_BILL_TO_SITE_TAX_PROF_ID      ZX_EXTRACT_PKG.BILL_TO_SITE_TAX_PROF_ID_TBL;
      GT_BILL_FROM_PARTY_TAX_PROF_ID   ZX_EXTRACT_PKG.BILL_FROM_PTY_TAX_PROF_ID_TBL;
      GT_BILL_FROM_SITE_TAX_PROF_ID    ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL;
    --  GT_BILLING_TP_ID                 ZX_EXTRACT_PKG.BILLING_TP_ID_TBL;
    --  GT_BILLING_TP_SITE_ID            ZX_EXTRACT_PKG.BILLING_TP_SITE_ID_TBL;
      --GT_BILLING_TP_ADDRESS_ID         ZX_EXTRACT_PKG.BILLING_TP_ADDRESS_ID_TBL;
      GT_BILL_TO_PARTY_ID              ZX_EXTRACT_PKG.BILL_TO_PARTY_ID_TBL;
      GT_BILL_TO_PARTY_SITE_ID         ZX_EXTRACT_PKG.BILL_TO_PARTY_SITE_ID_TBL;
      GT_SHIP_TO_PARTY_ID              ZX_EXTRACT_PKG.SHIP_TO_PARTY_ID_TBL;
      GT_SHIP_TO_PARTY_SITE_ID         ZX_EXTRACT_PKG.SHIP_TO_PARTY_SITE_ID_TBL;
      GT_HISTORICAL_FLAG               ZX_EXTRACT_PKG.HISTORICAL_FLAG_TBL;
      --GT_INTERNAL_ORGANIZATION_ID        ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL;
-- apai      GT_REP_CONTEXT_ID                  ZX_EXTRACT_PKG.REP_CONTEXT_ID_TBL;
G_FUN_CURRENCY_CODE              gl_ledgers.currency_code%TYPE;

--Accounting global variables declaration --
    GT_ACTG_EXT_LINE_ID         ZX_EXTRACT_PKG.ACTG_EXT_LINE_ID_TBL;
    GT_ACTG_EVENT_TYPE_CODE             ZX_EXTRACT_PKG.ACTG_EVENT_TYPE_CODE_TBL;
    GT_ACTG_EVENT_NUMBER                ZX_EXTRACT_PKG.ACTG_EVENT_NUMBER_TBL;
    GT_ACTG_EVENT_STATUS_FLAG           ZX_EXTRACT_PKG.ACTG_EVENT_STATUS_FLAG_TBL;
    GT_ACTG_CATEGORY_CODE               ZX_EXTRACT_PKG.ACTG_CATEGORY_CODE_TBL;
    GT_ACCOUNTING_DATE          ZX_EXTRACT_PKG.ACCOUNTING_DATE_TBL;
    GT_GL_TRANSFER_FLAG         ZX_EXTRACT_PKG.GL_TRANSFER_FLAG_TBL;
    GT_GL_TRANSFER_RUN_ID               ZX_EXTRACT_PKG.GL_TRANSFER_RUN_ID_TBL;
    GT_ACTG_HEADER_DESCRIPTION          ZX_EXTRACT_PKG.ACTG_HEADER_DESCRIPTION_TBL;
    GT_ACTG_LINE_NUM            ZX_EXTRACT_PKG.ACTG_LINE_NUM_TBL;
    GT_ACTG_LINE_TYPE_CODE              ZX_EXTRACT_PKG.ACTG_LINE_TYPE_CODE_TBL;
    GT_ACTG_LINE_DESCRIPTION            ZX_EXTRACT_PKG.ACTG_LINE_DESCRIPTION_TBL;
    GT_ACTG_STAT_AMT            ZX_EXTRACT_PKG.ACTG_STAT_AMT_TBL;
    GT_ACTG_ERROR_CODE          ZX_EXTRACT_PKG.ACTG_ERROR_CODE_TBL;
    GT_GL_TRANSFER_CODE         ZX_EXTRACT_PKG.GL_TRANSFER_CODE_TBL;
    GT_ACTG_DOC_SEQUENCE_ID             ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_ID_TBL;
    GT_ACTG_DOC_SEQUENCE_NAME           ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_NAME_TBL;
    GT_ACTG_DOC_SEQUENCE_VALUE          ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_VALUE_TBL;
    GT_ACTG_PARTY_ID            ZX_EXTRACT_PKG.ACTG_PARTY_ID_TBL;
    GT_ACTG_PARTY_SITE_ID               ZX_EXTRACT_PKG.ACTG_PARTY_SITE_ID_TBL;
    GT_ACTG_PARTY_TYPE          ZX_EXTRACT_PKG.ACTG_PARTY_TYPE_TBL;
    GT_ACTG_EVENT_ID            ZX_EXTRACT_PKG.ACTG_EVENT_ID_TBL;
    GT_ACTG_HEADER_ID           ZX_EXTRACT_PKG.ACTG_HEADER_ID_TBL;
    GT_ACTG_SOURCE_ID           ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL;
    GT_ACTG_SOURCE_TABLE                ZX_EXTRACT_PKG.ACTG_SOURCE_TABLE_TBL;
    GT_ACTG_LINE_CCID           ZX_EXTRACT_PKG.ACTG_LINE_CCID_TBL;
    GT_PERIOD_NAME              ZX_EXTRACT_PKG.PERIOD_NAME_TBL;


    AGT_ACTG_EXT_LINE_ID         ZX_EXTRACT_PKG.ACTG_EXT_LINE_ID_TBL;
    AGT_DETAIL_TAX_LINE_ID         ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
    AGT_ACTG_EVENT_TYPE_CODE             ZX_EXTRACT_PKG.ACTG_EVENT_TYPE_CODE_TBL;
    AGT_ACTG_EVENT_NUMBER                ZX_EXTRACT_PKG.ACTG_EVENT_NUMBER_TBL;
    AGT_ACTG_EVENT_STATUS_FLAG           ZX_EXTRACT_PKG.ACTG_EVENT_STATUS_FLAG_TBL;
    AGT_ACTG_CATEGORY_CODE               ZX_EXTRACT_PKG.ACTG_CATEGORY_CODE_TBL;
    AGT_ACCOUNTING_DATE          ZX_EXTRACT_PKG.ACCOUNTING_DATE_TBL;
    AGT_GL_TRANSFER_FLAG         ZX_EXTRACT_PKG.GL_TRANSFER_FLAG_TBL;
    AGT_GL_TRANSFER_RUN_ID               ZX_EXTRACT_PKG.GL_TRANSFER_RUN_ID_TBL;
    AGT_ACTG_HEADER_DESCRIPTION          ZX_EXTRACT_PKG.ACTG_HEADER_DESCRIPTION_TBL;
    AGT_ACTG_LINE_NUM            ZX_EXTRACT_PKG.ACTG_LINE_NUM_TBL;
    AGT_ACTG_LINE_TYPE_CODE              ZX_EXTRACT_PKG.ACTG_LINE_TYPE_CODE_TBL;
    AGT_ACTG_LINE_DESCRIPTION            ZX_EXTRACT_PKG.ACTG_LINE_DESCRIPTION_TBL;
    AGT_ACTG_STAT_AMT            ZX_EXTRACT_PKG.ACTG_STAT_AMT_TBL;
    AGT_ACTG_ERROR_CODE          ZX_EXTRACT_PKG.ACTG_ERROR_CODE_TBL;
    AGT_GL_TRANSFER_CODE         ZX_EXTRACT_PKG.GL_TRANSFER_CODE_TBL;
    AGT_ACTG_DOC_SEQUENCE_ID             ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_ID_TBL;
    AGT_ACTG_DOC_SEQUENCE_NAME           ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_NAME_TBL;
    AGT_ACTG_DOC_SEQUENCE_VALUE          ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_VALUE_TBL;
    AGT_ACTG_PARTY_ID            ZX_EXTRACT_PKG.ACTG_PARTY_ID_TBL;
    AGT_ACTG_PARTY_SITE_ID               ZX_EXTRACT_PKG.ACTG_PARTY_SITE_ID_TBL;
    AGT_ACTG_PARTY_TYPE          ZX_EXTRACT_PKG.ACTG_PARTY_TYPE_TBL;
    AGT_ACTG_EVENT_ID            ZX_EXTRACT_PKG.ACTG_EVENT_ID_TBL;
    AGT_ACTG_HEADER_ID           ZX_EXTRACT_PKG.ACTG_HEADER_ID_TBL;
    AGT_ACTG_SOURCE_ID           ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL;
    AGT_ACTG_SOURCE_TABLE                ZX_EXTRACT_PKG.ACTG_SOURCE_TABLE_TBL;
    AGT_ACTG_LINE_CCID           ZX_EXTRACT_PKG.ACTG_LINE_CCID_TBL;
    AGT_PERIOD_NAME              ZX_EXTRACT_PKG.PERIOD_NAME_TBL;

    GT_ACCOUNT_FLEXFIELD             ZX_EXTRACT_PKG.ACCOUNT_FLEXFIELD_TBL;
    GT_ACCOUNT_DESCRIPTION           ZX_EXTRACT_PKG.ACCOUNT_DESCRIPTION_TBL;


    --GT_ACTG_SOURCE_ID                ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL;
    GT_AE_HEADER_ID                  ZX_EXTRACT_PKG.ACTG_HEADER_ID_TBL;
    GT_EVENT_ID                      ZX_EXTRACT_PKG.ACTG_EVENT_ID_TBL;
    GT_LINE_CCID                     ZX_EXTRACT_PKG.ACTG_LINE_CCID_TBL;
    GT_TRX_ARAP_BALANCING_SEGMENT    ZX_EXTRACT_PKG.TRX_ARAP_BALANCING_SEG_TBL;
    GT_TRX_ARAP_NATURAL_ACCOUNT      ZX_EXTRACT_PKG.TRX_ARAP_NATURAL_ACCOUNT_TBL;
    GT_TRX_TAXABLE_BAL_SEG           ZX_EXTRACT_PKG.TRX_TAXABLE_BALANCING_SEG_TBL;
    GT_TRX_TAXABLE_BALSEG_DESC       ZX_EXTRACT_PKG.TRX_TAXABLE_BALSEG_DESC_TBL;
    GT_TRX_TAXABLE_NATURAL_ACCOUNT   ZX_EXTRACT_PKG.TRX_TAXABLE_NATURAL_ACCT_TBL;
    GT_TRX_TAX_BALANCING_SEGMENT     ZX_EXTRACT_PKG.TRX_TAX_BALANCING_SEG_TBL;
    GT_TRX_TAX_NATURAL_ACCOUNT       ZX_EXTRACT_PKG.TRX_TAX_NATURAL_ACCOUNT_TBL;
----    GT_TAX_AMT                    ZX_EXTRACT_PKG.TAX_AMT_TBL;
  --  GT_TAX_AMT_FUNCL_CURR         ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL;
--    GT_TAXABLE_AMT                ZX_EXTRACT_PKG.TAXABLE_AMT_TBL;
  --  GT_TAXABLE_AMT_FUNCL_CURR     ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL;
      GT_POSTED_DATE                ZX_EXTRACT_PKG.POSTED_DATE_TBL;
    GT_TRX_CONTROL_ACCFLEXFIELD ZX_EXTRACT_PKG.TRX_CONTROL_ACCT_FLEXFLD_TBL ; --Bug 5510907
    GT_TAX_DETERMINE_DATE  ZX_EXTRACT_PKG.TAX_DETERMINE_DATE_TBL ; --Bug 5622686

TYPE TRX_TAXABLE_ACCOUNT_DESC_tbl  IS TABLE OF
     ZX_REP_ACTG_EXT_T.TRX_TAXABLE_ACCOUNT_DESC%TYPE INDEX BY BINARY_INTEGER;

TYPE TRX_TAXABLE_NATACCT_DESC_tbl  IS TABLE OF
     ZX_REP_ACTG_EXT_T.TRX_TAXABLE_NATACCT_SEG_DESC%TYPE INDEX BY BINARY_INTEGER;

    GT_TRX_TAXABLE_ACCOUNT_DESC    TRX_TAXABLE_ACCOUNT_DESC_tbl ; --Bug 5650415
    GT_TRX_TAXABLE_NATACCT_DESC    TRX_TAXABLE_NATACCT_DESC_tbl ;
    GT_TAX_TYPE_MNG               ZX_EXTRACT_PKG.TAX_TYPE_MNG_TBL;

   -- Accounting---
   G_CREATED_BY                      NUMBER(15);
    G_CREATION_DATE                   DATE;
    G_LAST_UPDATED_BY                 NUMBER(15);
    G_LAST_UPDATE_DATE                DATE;
    G_LAST_UPDATE_LOGIN               NUMBER(15);
    G_PROGRAM_APPLICATION_ID          NUMBER;
    G_PROGRAM_ID                      NUMBER;
    G_PROGRAM_LOGIN_ID                NUMBER;
    g_request_id                      NUMBER;
    g_coa_id                          NUMBER;

  G_RETCODE             NUMBER :=0;

  C_LINES_PER_COMMIT CONSTANT NUMBER := 5000;
  L_MSG                                VARCHAR2(500);
  G_REP_CONTEXT_ID                NUMBER;
 g_current_runtime_level           NUMBER;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_error_buffer                  VARCHAR2(100);

PROCEDURE convert_amounts(P_CURRENCY_CODE        IN VARCHAR2,
                        P_EXCHANGE_RATE         IN NUMBER,
                        P_PRECISION             IN NUMBER,
                        P_MIN_ACCT_UNIT         IN NUMBER,
                        P_INPUT_TAX_AMOUNT      IN NUMBER,
                        P_INPUT_TAXABLE_AMOUNT  IN NUMBER,
                        P_INPUT_EXEMPT_AMOUNT   IN NUMBER,
                        i                       IN binary_integer);



PROCEDURE APP_FUNCTIONAL_AMOUNTS(
  P_TRX_ID                IN NUMBER,
  P_TAX_CODE_ID           IN NUMBER,
  P_CURRENCY_CODE         IN  VARCHAR2,
  P_EXCHANGE_RATE         IN NUMBER,
  P_PRECISION             IN NUMBER,
  P_MIN_ACCT_UNIT         IN   NUMBER,
  P_INPUT_TAX_AMOUNT      IN OUT NOCOPY NUMBER,
  P_INPUT_TAXABLE_AMOUNT  IN OUT NOCOPY NUMBER,
  P_SUMMARY_LEVEL         IN VARCHAR2,
  P_REGISTER_TYPE         IN VARCHAR2,
  i                       IN BINARY_INTEGER);

PROCEDURE get_accounting_info(P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_ACTG_SOURCE_ID           IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                              P_REPORT_NAME           IN VARCHAR2,
                              P_TRX_CLASS             IN VARCHAR2,
                              j                       IN binary_integer);

PROCEDURE get_accounting_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                           --      P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_ACTG_SOURCE_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                                 P_LEDGER_ID             IN NUMBER,
                                 j                       IN binary_integer);

PROCEDURE other_trx_segment_info(P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                   --           P_ENTITY_ID             IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_ACTG_SOURCE_ID         IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                              P_TRX_CLASS             IN VARCHAR2,
                              j                       IN binary_integer);
PROCEDURE other_trx_actg_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                  --               P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_ACTG_SOURCE_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                                 P_LEDGER_ID             IN NUMBER,
                                 j                       IN binary_integer);

PROCEDURE inv_segment_info (P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                   --           P_ENTITY_ID             IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_ACTG_SOURCE_ID           IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                              P_REPORT_NAME           IN VARCHAR2,
                              P_TRX_CLASS             IN VARCHAR2,
                              j                       IN binary_integer);


PROCEDURE inv_actg_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                  --               P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_ACTG_SOURCE_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                                 P_LEDGER_ID             IN NUMBER,
                                 j                       IN binary_integer);


PROCEDURE    insert_actg_info (
           P_COUNT IN BINARY_INTEGER);

PROCEDURE EXTRACT_PARTY_INFO( i IN BINARY_INTEGER);

PROCEDURE initialize_variables (
          p_count   IN         NUMBER);

PROCEDURE populate_meaning(
           P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           i BINARY_INTEGER);

/* Procedure get_tax_rate_info_dist_adj is created to populate the tax_rate_code and tax_rate_code_name
for Adjustments when report is submitted at Distribution level */
PROCEDURE get_tax_rate_info_dist_adj(i IN BINARY_INTEGER);

PROCEDURE populate_tax_reg_num(
           P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           P_ORG_ID       IN zx_lines.internal_organization_id%TYPE ,
           P_TAX_DATE     IN zx_lines.tax_date%TYPE,
           i BINARY_INTEGER);

PROCEDURE UPDATE_REP_DETAIL_T(p_count IN NUMBER);


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   UPDATE_ADDITIONAL_INFO                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure populates additional extract information                |
 |    AR_TAX_EXTRACT_SUB_ITF                                                 |
 |                                                                           |
 |    Called from |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/
PROCEDURE UPDATE_ADDITIONAL_INFO(
          P_TRL_GLOBAL_VARIABLES_REC      IN OUT  NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE)
IS

/*CURSOR detail_t_cur(c_request_id IN NUMBER) IS
SELECT  DETAIL_TAX_LINE_ID,
        LEDGER_ID,
        INTERNAL_ORGANIZATION_ID,
        TRX_ID ,
        TRX_TYPE_ID ,
        TRX_LINE_CLASS,
        TRX_BATCH_SOURCE_ID,
        TAX_RATE_ID ,
        TAX_RATE_VAT_TRX_TYPE_CODE,
        TAX_RATE_REGISTER_TYPE_CODE,
        TAX_EXEMPTION_ID ,
        TAX_EXCEPTION_ID ,
        TAX_LINE_ID ,
        TAX_AMT ,
        TAX_AMT_FUNCL_CURR ,
        TAX_LINE_NUMBER ,
        TAXABLE_AMT ,
        TAXABLE_AMT_FUNCL_CURR ,
        TRX_LINE_ID ,
        TAX_EXCEPTION_REASON_CODE ,
        EXEMPT_REASON_CODE,
        RECONCILIATION_FLAG ,
        INTERNAL_ORGANIZATION_ID,
        BR_REF_CUSTOMER_TRX_ID,
        REVERSE_FLAG,
        AMOUNT_APPLIED,
        TAX_RATE,
        TAX_RATE_CODE,
        TAX_TYPE_CODE,
        TRX_DATE,
        TRX_CURRENCY_CODE,
        CURRENCY_CONVERSION_RATE,
        APPLICATION_ID,
        DOC_EVENT_STATUS,
        EXTRACT_SOURCE_LEDGER ,
        FUNCTIONAL_CURRENCY_CODE,
        MINIMUM_ACCOUNTABLE_UNIT,
        PRECISION,
        RECEIPT_CLASS_ID ,
        EXCEPTION_RATE,
        SHIP_FROM_PARTY_TAX_PROF_ID,
        SHIP_FROM_SITE_TAX_PROF_ID,
        SHIP_TO_PARTY_TAX_PROF_ID  ,
        SHIP_TO_SITE_TAX_PROF_ID  ,
        BILL_TO_PARTY_TAX_PROF_ID,
        BILL_TO_SITE_TAX_PROF_ID,
        BILL_FROM_PARTY_TAX_PROF_ID,
        BILL_FROM_SITE_TAX_PROF_ID,
        BILLING_TRADING_PARTNER_ID,
        BILLING_TP_SITE_ID,
        BILLING_TP_ADDRESS_ID,
        SHIPPING_TRADING_PARTNER_ID,
        SHIPPING_TP_SITE_ID,
        SHIPPING_TP_ADDRESS_ID,
        BILL_TO_PARTY_ID,
        BILL_TO_PARTY_SITE_ID,
        SHIP_TO_PARTY_ID,
        SHIP_TO_PARTY_SITE_ID,
        HISTORICAL_FLAG
   FROM zx_rep_trx_detail_t
  WHERE EXTRACT_SOURCE_LEDGER = 'AR'
    AND request_id = c_request_id;
*/

  CURSOR detail_t_cur(c_request_id IN NUMBER,c_ledger_id NUMBER ) IS --Bug 5509856
  SELECT /*+ leading(zx_dtl,xla_ent,XLA_EVENT) parallel(zx_dtl) */
    DISTINCT ZX_DTL.DETAIL_TAX_LINE_ID,
        ZX_DTL.LEDGER_ID,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.TAX_DATE,
        ZX_DTL.HQ_ESTB_REG_NUMBER,
        ZX_DTL.TRX_ID ,
        ZX_DTL.TRX_TYPE_ID ,
        ZX_DTL.DOC_SEQ_ID,
        ZX_DTL.TRX_LINE_CLASS,
        ZX_DTL.TRX_BATCH_SOURCE_ID,
        ZX_DTL.TAX_RATE_ID ,
        ZX_DTL.TAX_RATE_VAT_TRX_TYPE_CODE,
        ZX_DTL.TAX_RATE_REGISTER_TYPE_CODE,
        ZX_DTL.TAX_EXEMPTION_ID ,
        ZX_DTL.TAX_EXCEPTION_ID ,
        ZX_DTL.TAX_LINE_ID ,
        ZX_DTL.TAX_AMT ,
        nvl(ZX_DTL.TAX_AMT_FUNCL_CURR,ZX_DTL.TAX_AMT) ,
        ZX_DTL.TAX_LINE_NUMBER ,
        ZX_DTL.TAXABLE_AMT ,
        nvl(ZX_DTL.TAXABLE_AMT_FUNCL_CURR,ZX_DTL.TAXABLE_AMT) ,
        ZX_DTL.TRX_LINE_ID ,
        ZX_DTL.TAX_EXCEPTION_REASON_CODE ,
        ZX_DTL.EXEMPT_REASON_CODE,
        ZX_DTL.RECONCILIATION_FLAG ,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.BR_REF_CUSTOMER_TRX_ID,
        ZX_DTL.REVERSE_FLAG,
        ZX_DTL.AMOUNT_APPLIED,
        ZX_DTL.TAX_RATE,
        ZX_DTL.TAX_RATE_CODE,
        ZX_DTL.TAX_RATE_CODE_NAME,
        ZX_DTL.TAX_TYPE_CODE,
       ZX_DTL.TRX_DATE,
        ZX_DTL.TRX_CURRENCY_CODE,
        ZX_DTL.CURRENCY_CONVERSION_RATE,
        ZX_DTL.APPLICATION_ID,
        ZX_DTL.DOC_EVENT_STATUS,
        ZX_DTL.EXTRACT_SOURCE_LEDGER ,
        ZX_DTL.FUNCTIONAL_CURRENCY_CODE,
        ZX_DTL.MINIMUM_ACCOUNTABLE_UNIT,
        ZX_DTL.PRECISION,
        ZX_DTL.RECEIPT_CLASS_ID ,
        ZX_DTL.EXCEPTION_RATE,
        ZX_DTL.SHIP_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.SHIP_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.SHIP_TO_PARTY_TAX_PROF_ID  ,
        ZX_DTL.SHIP_TO_SITE_TAX_PROF_ID  ,
        ZX_DTL.BILL_TO_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_TO_SITE_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.BILLING_TRADING_PARTNER_ID,
        ZX_DTL.BILLING_TP_SITE_ID,
        ZX_DTL.BILLING_TP_ADDRESS_ID,
        ZX_DTL.SHIPPING_TRADING_PARTNER_ID,
        ZX_DTL.SHIPPING_TP_SITE_ID,
        ZX_DTL.SHIPPING_TP_ADDRESS_ID,
        ZX_DTL.BILL_TO_PARTY_ID,
        ZX_DTL.BILL_TO_PARTY_SITE_ID,
        ZX_DTL.SHIP_TO_PARTY_ID,
        ZX_DTL.SHIP_TO_PARTY_SITE_ID,
        ZX_DTL.HISTORICAL_FLAG,
        ZX_DTL.POSTED_DATE,
        xla_event.event_type_code, -- Accounting Columns
        xla_event.event_number,
        xla_event.event_status_code,
        xla_head.je_category_name,
        xla_head.accounting_date,
        xla_head.gl_transfer_status_code,
        xla_head.description,
        xla_line.ae_line_num,
        xla_line.accounting_class_code,
        xla_line.description,
        xla_line.statistical_amount,
        xla_event.process_status_code,
        xla_head.gl_transfer_status_code,
        xla_head.doc_sequence_id,
        xla_head.doc_sequence_value,
        xla_line.party_id,
        xla_line.party_site_id,
        xla_line.party_type_code,
        xla_event.event_id,
        xla_head.ae_header_id,
        xla_line.code_combination_id,
        xla_head.period_name,
        zx_dtl.actg_source_id,
        zx_dtl.bank_account_id,
  ZX_DTL.tax_determine_date--Bug 5622686
 FROM  zx_rep_trx_detail_t zx_dtl,
        xla_transaction_entities xla_ent,
        xla_events     xla_event,
        xla_ae_headers  xla_head,
        xla_ae_lines    xla_line,
        xla_acct_class_assgns  acs,
        xla_assignment_defns_b asd,
        xla_distribution_links xla_dist
 WHERE zx_dtl.request_id = c_request_id
   AND zx_dtl.extract_source_ledger = 'AR'
   AND zx_dtl.account_class   = 'TAX'
   AND zx_dtl.posted_date IS NOT NULL
--   AND zx_dtl.ledger_id          = xla_ent.ledger_id
   AND zx_dtl.trx_id             = xla_ent.source_id_int_1    -- Accounting Joins
   AND xla_ent.entity_code       = 'TRANSACTIONS'   -- Check this condition
   AND xla_ent.application_id    = 222
   AND xla_ent.application_id    = xla_event.application_id
   AND xla_ent.entity_id         = xla_event.entity_id
   AND xla_event.application_id  = xla_head.application_id
   AND xla_event.event_id        = xla_head.event_id
   AND xla_head.ledger_id        = c_ledger_id
   AND xla_head.balance_type_code = 'A'
   AND xla_line.application_id   = xla_head.application_id
   AND xla_line.ae_header_id     = xla_head.ae_header_id
   AND acs.program_code          = 'TAX_REPORTING_LEDGER_SALES'
   AND acs.program_owner_code    = asd.program_owner_code
   AND acs.program_code          = asd.program_code
   AND acs.assignment_owner_code = asd.assignment_owner_code
   AND acs.assignment_code       = asd.assignment_code
   AND asd.enabled_flag          = 'Y'
   AND acs.accounting_class_code = xla_line.accounting_class_code
   AND zx_dtl.tax_line_id        = xla_dist.tax_line_ref_id
   AND zx_dtl.actg_source_id     = xla_dist.source_distribution_id_num_1
   AND xla_line.ae_header_id     = xla_dist.ae_header_id
   AND xla_line.ae_line_num      = xla_dist.ae_line_num
   AND xla_line.application_id   = xla_dist.application_id
 -- can we get header_id as input parameter to the cursor? In that case we can add following join
 --  AND xla_head.ae_header_id = :c_header_id
 --    AND xla_dist.tax_line_ref_id IS NOT NULL
 --    AND xla_dist.accounting_line_code = 'TAX'
UNION
   SELECT /*+ leading(zx_dtl,xla_ent,XLA_EVENT) parallel(zx_dtl) */
    DISTINCT ZX_DTL.DETAIL_TAX_LINE_ID,
        ZX_DTL.LEDGER_ID,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.TAX_DATE,
        ZX_DTL.HQ_ESTB_REG_NUMBER,
        ZX_DTL.TRX_ID ,
        ZX_DTL.TRX_TYPE_ID ,
        ZX_DTL.DOC_SEQ_ID,
        ZX_DTL.TRX_LINE_CLASS,
        ZX_DTL.TRX_BATCH_SOURCE_ID,
        ZX_DTL.TAX_RATE_ID ,
        ZX_DTL.TAX_RATE_VAT_TRX_TYPE_CODE,
        ZX_DTL.TAX_RATE_REGISTER_TYPE_CODE,
        ZX_DTL.TAX_EXEMPTION_ID ,
        ZX_DTL.TAX_EXCEPTION_ID ,
        ZX_DTL.TAX_LINE_ID ,
        ZX_DTL.TAX_AMT ,
        nvl(ZX_DTL.TAX_AMT_FUNCL_CURR,ZX_DTL.TAX_AMT) ,
        ZX_DTL.TAX_LINE_NUMBER ,
        ZX_DTL.TAXABLE_AMT ,
        nvl(ZX_DTL.TAXABLE_AMT_FUNCL_CURR,ZX_DTL.TAXABLE_AMT) ,
        ZX_DTL.TRX_LINE_ID ,
        ZX_DTL.TAX_EXCEPTION_REASON_CODE ,
        ZX_DTL.EXEMPT_REASON_CODE,
        ZX_DTL.RECONCILIATION_FLAG ,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.BR_REF_CUSTOMER_TRX_ID,
        ZX_DTL.REVERSE_FLAG,
        ZX_DTL.AMOUNT_APPLIED,
        ZX_DTL.TAX_RATE,
        ZX_DTL.TAX_RATE_CODE,
        ZX_DTL.TAX_RATE_CODE_NAME,
        ZX_DTL.TAX_TYPE_CODE,
       ZX_DTL.TRX_DATE,
        ZX_DTL.TRX_CURRENCY_CODE,
        ZX_DTL.CURRENCY_CONVERSION_RATE,
        ZX_DTL.APPLICATION_ID,
        ZX_DTL.DOC_EVENT_STATUS,
        ZX_DTL.EXTRACT_SOURCE_LEDGER ,
        ZX_DTL.FUNCTIONAL_CURRENCY_CODE,
        ZX_DTL.MINIMUM_ACCOUNTABLE_UNIT,
        ZX_DTL.PRECISION,
        ZX_DTL.RECEIPT_CLASS_ID ,
        ZX_DTL.EXCEPTION_RATE,
        ZX_DTL.SHIP_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.SHIP_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.SHIP_TO_PARTY_TAX_PROF_ID  ,
        ZX_DTL.SHIP_TO_SITE_TAX_PROF_ID  ,
        ZX_DTL.BILL_TO_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_TO_SITE_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.BILLING_TRADING_PARTNER_ID,
        ZX_DTL.BILLING_TP_SITE_ID,
        ZX_DTL.BILLING_TP_ADDRESS_ID,
        ZX_DTL.SHIPPING_TRADING_PARTNER_ID,
        ZX_DTL.SHIPPING_TP_SITE_ID,
        ZX_DTL.SHIPPING_TP_ADDRESS_ID,
        ZX_DTL.BILL_TO_PARTY_ID,
        ZX_DTL.BILL_TO_PARTY_SITE_ID,
        ZX_DTL.SHIP_TO_PARTY_ID,
        ZX_DTL.SHIP_TO_PARTY_SITE_ID,
        ZX_DTL.HISTORICAL_FLAG,
        ZX_DTL.POSTED_DATE,
        xla_event.event_type_code, -- Accounting Columns
        xla_event.event_number,
        xla_event.event_status_code,
        xla_head.je_category_name,
        xla_head.accounting_date,
        xla_head.gl_transfer_status_code,
        xla_head.description,
        xla_line.ae_line_num,
        xla_line.accounting_class_code,
        xla_line.description,
        xla_line.statistical_amount,
        xla_event.process_status_code,
        xla_head.gl_transfer_status_code,
        xla_head.doc_sequence_id,
        xla_head.doc_sequence_value,
        xla_line.party_id,
        xla_line.party_site_id,
        xla_line.party_type_code,
        xla_event.event_id,
        xla_head.ae_header_id,
        xla_line.code_combination_id,
        xla_head.period_name,
        zx_dtl.actg_source_id,
        zx_dtl.bank_account_id,
        ZX_DTL.tax_determine_date
      FROM  zx_rep_trx_detail_t zx_dtl,
        xla_transaction_entities xla_ent,
        xla_events     xla_event,
        xla_ae_headers  xla_head,
        xla_ae_lines    xla_line,
        xla_acct_class_assgns  acs,
        xla_assignment_defns_b asd,
        xla_distribution_links xla_dist
 WHERE zx_dtl.request_id = c_request_id
   AND zx_dtl.extract_source_ledger = 'AR'
   AND zx_dtl.posted_date IS NOT NULL
   AND zx_dtl.trx_id             = xla_ent.source_id_int_1
   AND xla_ent.entity_code       IN ('RECEIPTS', 'ADJUSTMENTS', 'BILLS_RECEIVABLE')
   AND xla_ent.application_id    = 222
   AND xla_ent.application_id    = xla_event.application_id
   AND xla_ent.entity_id         = xla_event.entity_id
   AND xla_event.application_id  = xla_head.application_id
   AND xla_event.event_id        = xla_head.event_id
   AND xla_head.ledger_id        = c_ledger_id
   AND xla_head.balance_type_code = 'A'
   AND xla_line.application_id   = xla_head.application_id
   AND xla_line.ae_header_id     = xla_head.ae_header_id
   AND acs.program_code          = 'TAX_REPORTING_LEDGER_SALES'
   AND acs.program_owner_code    = asd.program_owner_code
   AND acs.program_code          = asd.program_code
   AND acs.assignment_owner_code = asd.assignment_owner_code
   AND acs.assignment_code       = asd.assignment_code
   AND asd.enabled_flag          = 'Y'
   AND acs.accounting_class_code = xla_line.accounting_class_code
   AND zx_dtl.actg_source_id     = xla_dist.source_distribution_id_num_1
   AND xla_line.ae_header_id     = xla_dist.ae_header_id
   AND xla_line.ae_line_num      = xla_dist.ae_line_num
   AND xla_line.application_id   = xla_dist.application_id
UNION
 SELECT /*+ FULL(zx_dtl) parallel(zx_dtl) */
        ZX_DTL.DETAIL_TAX_LINE_ID,
        ZX_DTL.LEDGER_ID,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.TAX_DATE,
        ZX_DTL.HQ_ESTB_REG_NUMBER,
        ZX_DTL.TRX_ID ,
        ZX_DTL.TRX_TYPE_ID ,
        ZX_DTL.DOC_SEQ_ID,
        ZX_DTL.TRX_LINE_CLASS,
        ZX_DTL.TRX_BATCH_SOURCE_ID,
        ZX_DTL.TAX_RATE_ID ,
        ZX_DTL.TAX_RATE_VAT_TRX_TYPE_CODE,
        ZX_DTL.TAX_RATE_REGISTER_TYPE_CODE,
        ZX_DTL.TAX_EXEMPTION_ID ,
        ZX_DTL.TAX_EXCEPTION_ID ,
        ZX_DTL.TAX_LINE_ID ,
        ZX_DTL.TAX_AMT ,
        nvl(ZX_DTL.TAX_AMT_FUNCL_CURR,ZX_DTL.TAX_AMT) ,
        ZX_DTL.TAX_LINE_NUMBER ,
        ZX_DTL.TAXABLE_AMT ,
        nvl(ZX_DTL.TAXABLE_AMT_FUNCL_CURR,ZX_DTL.TAXABLE_AMT) ,
        ZX_DTL.TRX_LINE_ID ,
        ZX_DTL.TAX_EXCEPTION_REASON_CODE ,
        ZX_DTL.EXEMPT_REASON_CODE,
        ZX_DTL.RECONCILIATION_FLAG ,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.BR_REF_CUSTOMER_TRX_ID,
        ZX_DTL.REVERSE_FLAG,
        ZX_DTL.AMOUNT_APPLIED,
        ZX_DTL.TAX_RATE,
        ZX_DTL.TAX_RATE_CODE,
        ZX_DTL.TAX_RATE_CODE_NAME,
        ZX_DTL.TAX_TYPE_CODE,
       ZX_DTL.TRX_DATE,
        ZX_DTL.TRX_CURRENCY_CODE,
        ZX_DTL.CURRENCY_CONVERSION_RATE,
        ZX_DTL.APPLICATION_ID,
        ZX_DTL.DOC_EVENT_STATUS,
        ZX_DTL.EXTRACT_SOURCE_LEDGER ,
        ZX_DTL.FUNCTIONAL_CURRENCY_CODE,
        ZX_DTL.MINIMUM_ACCOUNTABLE_UNIT,
        ZX_DTL.PRECISION,
        ZX_DTL.RECEIPT_CLASS_ID ,
        ZX_DTL.EXCEPTION_RATE,
        ZX_DTL.SHIP_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.SHIP_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.SHIP_TO_PARTY_TAX_PROF_ID  ,
        ZX_DTL.SHIP_TO_SITE_TAX_PROF_ID  ,
        ZX_DTL.BILL_TO_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_TO_SITE_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.BILLING_TRADING_PARTNER_ID,
        ZX_DTL.BILLING_TP_SITE_ID,
        ZX_DTL.BILLING_TP_ADDRESS_ID,
        ZX_DTL.SHIPPING_TRADING_PARTNER_ID,
        ZX_DTL.SHIPPING_TP_SITE_ID,
        ZX_DTL.SHIPPING_TP_ADDRESS_ID,
        ZX_DTL.BILL_TO_PARTY_ID,
        ZX_DTL.BILL_TO_PARTY_SITE_ID,
        ZX_DTL.SHIP_TO_PARTY_ID,
        ZX_DTL.SHIP_TO_PARTY_SITE_ID,
        ZX_DTL.HISTORICAL_FLAG,
        ZX_DTL.POSTED_DATE,
        TO_CHAR(NULL),    --xla_event.event_type_code, -- Accounting Columns
        TO_NUMBER(NULL),    --xla_event.event_number,
        TO_CHAR(NULL),    --xla_event.event_status_code,
        TO_CHAR(NULL),    --xla_head.je_category_name,
        TO_DATE(NULL),    --xla_head.accounting_date,
        ZX_DTL.POSTED_FLAG,    --xla_head.gl_transfer_status_code,
        TO_CHAR(NULL),    --xla_head.description,
        TO_NUMBER(NULL),    --xla_line.ae_line_num,
        TO_CHAR(NULL),    --xla_line.accounting_class_code,
        TO_CHAR(NULL),    --xla_line.description,
        TO_NUMBER(NULL),    --xla_line.statistical_amount,
        TO_CHAR(NULL),    --xla_event.process_status_code,
        TO_CHAR(NULL),    --xla_head.gl_transfer_status_code,
        TO_NUMBER(NULL),    --xla_head.doc_sequence_id,
        TO_NUMBER(NULL),    --xla_head.doc_sequence_value,
        TO_NUMBER(NULL),    --xla_line.party_id,
        TO_NUMBER(NULL),    --xla_line.party_site_id,
        TO_CHAR(NULL),    --xla_line.party_type_code,
        TO_NUMBER(NULL),    --xla_event.event_id,
        TO_NUMBER(NULL),    --xla_head.ae_header_id,
        TO_NUMBER(NULL),    --xla_line.code_combination_id,
        TO_CHAR(NULL),    --xla_head.period_name,
        ZX_DTL.ACTG_SOURCE_ID,
        zx_dtl.bank_account_id,
  ZX_DTL.tax_determine_date --Bug 5622686
   FROM zx_rep_trx_detail_t zx_dtl
  WHERE zx_dtl.request_id = c_request_id
    AND zx_dtl.extract_source_ledger = 'AR'
    AND zx_dtl.posted_date IS NULL ;
    --OR
          -- (zx_dtl.posted_date IS NOT NULL AND zx_dtl.tax_line_id is NULL));
/* OR
           ( zx_dtl.posted_date IS NOT  NULL
             AND not exists(select 1 from xla_transaction_entities
                     where source_id_int_1 = zx_dtl.trx_id
                       and application_id = 2222))); */
/*Defined new cursor detail_t_cur_trx_line for bug7503539 bibeura */

-- bulk comment
-- the cusror is same as above cursor, but for removing the join
-- AND zx_dtl.actg_source_id = xla_dist.source_distribution_id_num_1
CURSOR detail_t_cur_trx_line(c_request_id IN NUMBER,c_ledger_id NUMBER ) IS
  SELECT /*+ leading(zx_dtl,xla_ent,XLA_EVENT) parallel(zx_dtl) */
    DISTINCT ZX_DTL.DETAIL_TAX_LINE_ID,
        ZX_DTL.LEDGER_ID,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.TAX_DATE,
        ZX_DTL.HQ_ESTB_REG_NUMBER,
        ZX_DTL.TRX_ID ,
        ZX_DTL.TRX_TYPE_ID ,
        ZX_DTL.DOC_SEQ_ID,
        ZX_DTL.TRX_LINE_CLASS,
        ZX_DTL.TRX_BATCH_SOURCE_ID,
        ZX_DTL.TAX_RATE_ID ,
        ZX_DTL.TAX_RATE_VAT_TRX_TYPE_CODE,
        ZX_DTL.TAX_RATE_REGISTER_TYPE_CODE,
        ZX_DTL.TAX_EXEMPTION_ID ,
        ZX_DTL.TAX_EXCEPTION_ID ,
        ZX_DTL.TAX_LINE_ID ,
        ZX_DTL.TAX_AMT ,
        nvl(ZX_DTL.TAX_AMT_FUNCL_CURR,ZX_DTL.TAX_AMT) ,
        ZX_DTL.TAX_LINE_NUMBER ,
        ZX_DTL.TAXABLE_AMT ,
        nvl(ZX_DTL.TAXABLE_AMT_FUNCL_CURR,ZX_DTL.TAXABLE_AMT) ,
        ZX_DTL.TRX_LINE_ID ,
        ZX_DTL.TAX_EXCEPTION_REASON_CODE ,
        ZX_DTL.EXEMPT_REASON_CODE,
        ZX_DTL.RECONCILIATION_FLAG ,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.BR_REF_CUSTOMER_TRX_ID,
        ZX_DTL.REVERSE_FLAG,
        ZX_DTL.AMOUNT_APPLIED,
        ZX_DTL.TAX_RATE,
        ZX_DTL.TAX_RATE_CODE,
        ZX_DTL.TAX_RATE_CODE_NAME,
        ZX_DTL.TAX_TYPE_CODE,
        ZX_DTL.TRX_DATE,
        ZX_DTL.TRX_CURRENCY_CODE,
        ZX_DTL.CURRENCY_CONVERSION_RATE,
        ZX_DTL.APPLICATION_ID,
        ZX_DTL.DOC_EVENT_STATUS,
        ZX_DTL.EXTRACT_SOURCE_LEDGER ,
        ZX_DTL.FUNCTIONAL_CURRENCY_CODE,
        ZX_DTL.MINIMUM_ACCOUNTABLE_UNIT,
        ZX_DTL.PRECISION,
        ZX_DTL.RECEIPT_CLASS_ID ,
        ZX_DTL.EXCEPTION_RATE,
        ZX_DTL.SHIP_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.SHIP_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.SHIP_TO_PARTY_TAX_PROF_ID  ,
        ZX_DTL.SHIP_TO_SITE_TAX_PROF_ID  ,
        ZX_DTL.BILL_TO_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_TO_SITE_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.BILLING_TRADING_PARTNER_ID,
        ZX_DTL.BILLING_TP_SITE_ID,
        ZX_DTL.BILLING_TP_ADDRESS_ID,
        ZX_DTL.SHIPPING_TRADING_PARTNER_ID,
        ZX_DTL.SHIPPING_TP_SITE_ID,
        ZX_DTL.SHIPPING_TP_ADDRESS_ID,
        ZX_DTL.BILL_TO_PARTY_ID,
        ZX_DTL.BILL_TO_PARTY_SITE_ID,
        ZX_DTL.SHIP_TO_PARTY_ID,
        ZX_DTL.SHIP_TO_PARTY_SITE_ID,
        ZX_DTL.HISTORICAL_FLAG,
        ZX_DTL.POSTED_DATE,
        xla_event.event_type_code,
        xla_event.event_number,
        xla_event.event_status_code,
        xla_head.je_category_name,
        xla_head.accounting_date,
        xla_head.gl_transfer_status_code,
        xla_head.description,
        xla_line.ae_line_num,
        xla_line.accounting_class_code,
        xla_line.description,
        xla_line.statistical_amount,
        xla_event.process_status_code,
        xla_head.gl_transfer_status_code,
        xla_head.doc_sequence_id,
        xla_head.doc_sequence_value,
        xla_line.party_id,
        xla_line.party_site_id,
        xla_line.party_type_code,
        xla_event.event_id,
        xla_head.ae_header_id,
        xla_line.code_combination_id,
        xla_head.period_name,
        zx_dtl.actg_source_id,
        zx_dtl.bank_account_id,
        ZX_DTL.tax_determine_date
 FROM  zx_rep_trx_detail_t zx_dtl,
        xla_transaction_entities xla_ent,
        xla_events     xla_event,
        xla_ae_headers  xla_head,
        xla_ae_lines    xla_line,
        xla_acct_class_assgns  acs,
        xla_assignment_defns_b asd,
        xla_distribution_links xla_dist
 WHERE zx_dtl.request_id = c_request_id
   AND zx_dtl.extract_source_ledger = 'AR'
   AND zx_dtl.account_class = 'TAX'
   AND zx_dtl.posted_date IS NOT NULL
--   AND zx_dtl.ledger_id          = xla_ent.ledger_id
   AND zx_dtl.trx_id           =  xla_ent.source_id_int_1
   AND xla_ent.entity_code      = 'TRANSACTIONS'
   AND xla_ent.application_id = 222
   AND xla_ent.application_id    = xla_event.application_id
   AND xla_ent.entity_id         = xla_event.entity_id
   AND xla_event.application_id  = xla_head.application_id
   AND xla_event.event_id       = xla_head.event_id
   AND xla_head.ledger_id        = c_ledger_id
   AND xla_head.balance_type_code = 'A'
   AND xla_line.application_id   = xla_head.application_id
   AND xla_line.ae_header_id     = xla_head.ae_header_id
   AND acs.program_code   = 'TAX_REPORTING_LEDGER_SALES'
   AND acs.program_owner_code    = asd.program_owner_code
   AND acs.program_code          = asd.program_code
   AND acs.assignment_owner_code = asd.assignment_owner_code
   AND acs.assignment_code       = asd.assignment_code
   AND asd.enabled_flag = 'Y'
   AND acs.accounting_class_code = xla_line.accounting_class_code
   AND zx_dtl.tax_line_id = xla_dist.tax_line_ref_id
--    AND zx_dtl.actg_source_id = xla_dist.source_distribution_id_num_1
   AND xla_line.ae_header_id    = xla_dist.ae_header_id
   AND xla_line.ae_line_num     = xla_dist.ae_line_num
   AND xla_line.application_id  = xla_dist.application_id
UNION
 SELECT /*+ FULL(zx_dtl) parallel(zx_dtl) */
        ZX_DTL.DETAIL_TAX_LINE_ID,
        ZX_DTL.LEDGER_ID,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.TAX_DATE,
        ZX_DTL.HQ_ESTB_REG_NUMBER,
        ZX_DTL.TRX_ID ,
        ZX_DTL.TRX_TYPE_ID ,
        ZX_DTL.DOC_SEQ_ID,
        ZX_DTL.TRX_LINE_CLASS,
        ZX_DTL.TRX_BATCH_SOURCE_ID,
        ZX_DTL.TAX_RATE_ID ,
        ZX_DTL.TAX_RATE_VAT_TRX_TYPE_CODE,
        ZX_DTL.TAX_RATE_REGISTER_TYPE_CODE,
        ZX_DTL.TAX_EXEMPTION_ID ,
        ZX_DTL.TAX_EXCEPTION_ID ,
        ZX_DTL.TAX_LINE_ID ,
        ZX_DTL.TAX_AMT ,
        nvl(ZX_DTL.TAX_AMT_FUNCL_CURR,ZX_DTL.TAX_AMT) ,
        ZX_DTL.TAX_LINE_NUMBER ,
        ZX_DTL.TAXABLE_AMT ,
        nvl(ZX_DTL.TAXABLE_AMT_FUNCL_CURR,ZX_DTL.TAXABLE_AMT) ,
        ZX_DTL.TRX_LINE_ID ,
        ZX_DTL.TAX_EXCEPTION_REASON_CODE ,
        ZX_DTL.EXEMPT_REASON_CODE,
        ZX_DTL.RECONCILIATION_FLAG ,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.BR_REF_CUSTOMER_TRX_ID,
        ZX_DTL.REVERSE_FLAG,
        ZX_DTL.AMOUNT_APPLIED,
        ZX_DTL.TAX_RATE,
        ZX_DTL.TAX_RATE_CODE,
        ZX_DTL.TAX_RATE_CODE_NAME,
        ZX_DTL.TAX_TYPE_CODE,
        ZX_DTL.TRX_DATE,
        ZX_DTL.TRX_CURRENCY_CODE,
        ZX_DTL.CURRENCY_CONVERSION_RATE,
        ZX_DTL.APPLICATION_ID,
        ZX_DTL.DOC_EVENT_STATUS,
        ZX_DTL.EXTRACT_SOURCE_LEDGER ,
        ZX_DTL.FUNCTIONAL_CURRENCY_CODE,
        ZX_DTL.MINIMUM_ACCOUNTABLE_UNIT,
        ZX_DTL.PRECISION,
        ZX_DTL.RECEIPT_CLASS_ID ,
        ZX_DTL.EXCEPTION_RATE,
        ZX_DTL.SHIP_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.SHIP_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.SHIP_TO_PARTY_TAX_PROF_ID  ,
        ZX_DTL.SHIP_TO_SITE_TAX_PROF_ID  ,
        ZX_DTL.BILL_TO_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_TO_SITE_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_PARTY_TAX_PROF_ID,
        ZX_DTL.BILL_FROM_SITE_TAX_PROF_ID,
        ZX_DTL.BILLING_TRADING_PARTNER_ID,
        ZX_DTL.BILLING_TP_SITE_ID,
        ZX_DTL.BILLING_TP_ADDRESS_ID,
        ZX_DTL.SHIPPING_TRADING_PARTNER_ID,
        ZX_DTL.SHIPPING_TP_SITE_ID,
        ZX_DTL.SHIPPING_TP_ADDRESS_ID,
        ZX_DTL.BILL_TO_PARTY_ID,
        ZX_DTL.BILL_TO_PARTY_SITE_ID,
        ZX_DTL.SHIP_TO_PARTY_ID,
        ZX_DTL.SHIP_TO_PARTY_SITE_ID,
        ZX_DTL.HISTORICAL_FLAG,
        ZX_DTL.POSTED_DATE,
        TO_CHAR(NULL),    --xla_event.event_type_code, -- Accounting Columns
        TO_NUMBER(NULL),    --xla_event.event_number,
        TO_CHAR(NULL),    --xla_event.event_status_code,
        TO_CHAR(NULL),    --xla_head.je_category_name,
        TO_DATE(NULL),    --xla_head.accounting_date,
        ZX_DTL.POSTED_FLAG,    --xla_head.gl_transfer_status_code,
        TO_CHAR(NULL),    --xla_head.description,
        TO_NUMBER(NULL),    --xla_line.ae_line_num,
        TO_CHAR(NULL),    --xla_line.accounting_class_code,
        TO_CHAR(NULL),    --xla_line.description,
        TO_NUMBER(NULL),    --xla_line.statistical_amount,
        TO_CHAR(NULL),    --xla_event.process_status_code,
        TO_CHAR(NULL),    --xla_head.gl_transfer_status_code,
        TO_NUMBER(NULL),    --xla_head.doc_sequence_id,
        TO_NUMBER(NULL),    --xla_head.doc_sequence_value,
        TO_NUMBER(NULL),    --xla_line.party_id,
        TO_NUMBER(NULL),    --xla_line.party_site_id,
        TO_CHAR(NULL),    --xla_line.party_type_code,
        TO_NUMBER(NULL),    --xla_event.event_id,
        TO_NUMBER(NULL),    --xla_head.ae_header_id,
        TO_NUMBER(NULL),    --xla_line.code_combination_id,
        TO_CHAR(NULL),    --xla_head.period_name,
        ZX_DTL.ACTG_SOURCE_ID,
        zx_dtl.bank_account_id,
        ZX_DTL.tax_determine_date
   FROM zx_rep_trx_detail_t zx_dtl
  WHERE zx_dtl.request_id = c_request_id
    AND zx_dtl.extract_source_ledger = 'AR'
    AND ((zx_dtl.posted_date IS NULL) OR
           (zx_dtl.posted_date IS NOT NULL AND zx_dtl.tax_line_id is NULL));

  L_TRX_CLASS                   VARCHAR2(30);
  L_TAXABLE_AMOUNT              NUMBER;
  L_TAXABLE_ACCOUNTED_AMOUNT    NUMBER;
   l_balancing_segment         VARCHAR2(25);
    l_accounting_segment         VARCHAR2(25);
    l_ledger_id                NUMBER(15);

 -- L_BANKING_TP_NAME             AR_TAX_EXTRACT_SUB_ITF.BANKING_TP_NAME%TYPE;
 -- L_BANKING_TP_TAXPAYER_ID      AR_TAX_EXTRACT_SUB_ITF.BANKING_TP_TAXPAYER_ID%type;
 -- L_MATRIX_REPORT               VARCHAR2(1);

--  L_TRX_APPLIED_TO_TRX_ID       NUMBER;  -- where it is used, AP
--  L_ACCOUNTING_DATE             DATE; -- where is this being used  AP
--  L_TRX_CURRENCY_CODE           VARCHAR2(15);
--  RA_SUB_ITF_TABLE_REC          AR_TAX_EXTRACT_SUB_ITF%ROWTYPE;
  l_count                       NUMBER :=0;
  l_act_nact     ZX_EXTRACT_PKG.ACTG_LINE_TYPE_CODE_TBL;
  j     number;

BEGIN

     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     g_request_id := P_TRL_GLOBAL_VARIABLES_REC.request_id;
     l_ledger_id := P_TRL_GLOBAL_VARIABLES_REC.ledger_id;
     g_coa_id := P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id;

    G_REP_CONTEXT_ID := ZX_EXTRACT_PKG.GET_REP_CONTEXT_ID(P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID,
                                                          P_TRL_GLOBAL_VARIABLES_REC.request_id);
    g_created_by        := fnd_global.user_id;
    g_creation_date     := sysdate;
    g_last_updated_by   := fnd_global.user_id;
    g_last_update_login := fnd_global.login_id;
    g_last_update_date  := sysdate;

    g_program_application_id := fnd_global.prog_appl_id;
    g_program_id             := fnd_global.conc_program_id;
    g_program_login_id       := fnd_global.conc_login_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO.BEGIN',
                                      'ZX_AR_POPULATE_PKG: UPDATE_ADDITIONAL_INFO(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.update_additional_info',
                                    'Request ID : '||to_char(P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.update_additional_info',
                          'Reporting Ledger : '||to_char(p_trl_global_variables_rec.reporting_ledger_id));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.update_additional_info',
                          'Primary Ledger : '||to_char(p_trl_global_variables_rec.ledger_id));
    END IF;

  -- get functional currency code code --
     gl_mc_info.get_ledger_currency(p_trl_global_variables_rec.ledger_id,
                                    G_FUN_CURRENCY_CODE);

    XLA_SECURITY_PKG.set_security_context(p_application_id => 602);

-- Accounting Flex Field Information --
-- Determine which segment is balancing segment  for the given
-- chart of accounts (Set of books)

      l_balancing_segment := fa_rx_flex_pkg.flex_sql(
                                  p_application_id =>101,
                                  p_id_flex_code => 'GL#',
                                  p_id_flex_num => P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id,
                                  p_table_alias => '',
                                  p_mode => 'SELECT',
                                  p_qualifier => 'GL_BALANCING');

      l_accounting_segment := fa_rx_flex_pkg.flex_sql(
                                  p_application_id =>101,
                                  p_id_flex_code => 'GL#',
                                  p_id_flex_num => P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id,
                                  p_table_alias => '',
                                  p_mode => 'SELECT',
                                  p_qualifier => 'GL_ACCOUNT');

--     The above function will return balancing segment in the form CC.SEGMENT1
--     we need to drop CC. to get the actual balancing segment.

       l_balancing_segment := substrb(l_balancing_segment,
                     instrb(l_balancing_segment,'.')+1);

   -- The below DELETE statement is introduced to delete duplicate
   -- records from zx_rep_trx_detail_t for AR discounts that are
   -- caused due to one tax distribution associated with multiple
   -- EDISC lines. TRL dynamic sql query at TRANSACTION level
   -- returing duplicate rows in this case.


     IF (P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION') OR
        (P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_LINE') THEN
        IF P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AR_APPL_TRX_CLASS = 'Y' THEN

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            SELECT count(*) INTO l_count
              FROM zx_rep_trx_detail_t dtl1
             WHERE actg_source_id <>
                   ( SELECT  min(dtl2.ACTG_SOURCE_ID)
                       FROM zx_rep_trx_detail_t dtl2
                      WHERE dtl2.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
                        AND dtl2.trx_id = dtl1.trx_id
                        AND dtl2.tax_line_number = dtl1.tax_line_number
                        AND dtl2.tax_rate_id = dtl1.tax_rate_id
                        and dtl2.TAXABLE_ITEM_SOURCE_ID = dtl1.TAXABLE_ITEM_SOURCE_ID
                        AND dtl2.EVENT_CLASS_CODE = dtl1.EVENT_CLASS_CODE
                        AND dtl2.APPLIED_FROM_EVENT_CLASS_CODE = dtl1.APPLIED_FROM_EVENT_CLASS_CODE
                        AND dtl2.application_id = dtl1.application_id
                      GROUP BY dtl2.request_id,dtl2.trx_id,dtl2.EVENT_CLASS_CODE, dtl2.tax_line_number, dtl2.tax_rate_id
                        HAVING count(distinct dtl2.actg_source_id) >=2
                             )
               AND dtl1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
               AND dtl1.EVENT_CLASS_CODE in ('EDISC','UNEDISC','APP')
               AND dtl1.APPLIED_FROM_EVENT_CLASS_CODE = 'APP'
               AND dtl1.application_id = 222;
          END IF;


--SELECT count(*) into l_count
          DELETE  FROM zx_rep_trx_detail_t dtl1
          WHERE actg_source_id <>( SELECT  min(dtl2.ACTG_SOURCE_ID)
                            FROM zx_rep_trx_detail_t dtl2
                            WHERE dtl2.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
                              AND dtl2.trx_id = dtl1.trx_id
                              AND dtl2.tax_line_number = dtl1.tax_line_number
                              AND dtl2.tax_rate_id = dtl1.tax_rate_id
                             and dtl2.TAXABLE_ITEM_SOURCE_ID = dtl1.TAXABLE_ITEM_SOURCE_ID
                             AND dtl2.EVENT_CLASS_CODE = dtl1.EVENT_CLASS_CODE
                             AND dtl2.APPLIED_FROM_EVENT_CLASS_CODE = dtl1.APPLIED_FROM_EVENT_CLASS_CODE
                             AND dtl2.application_id = dtl1.application_id
                       GROUP BY dtl2.request_id,dtl2.trx_id,dtl2.EVENT_CLASS_CODE, dtl2.tax_line_number, dtl2.tax_rate_id
                             HAVING count(distinct dtl2.actg_source_id) >=2
                           )
         AND dtl1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
        AND dtl1.EVENT_CLASS_CODE in ('EDISC','UNEDISC','APP')
        AND dtl1.APPLIED_FROM_EVENT_CLASS_CODE = 'APP'
        AND dtl1.application_id = 222;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.Before Dist cursor Opened',
             'Delete Duplicate rows for AR Discounts: '||to_char(l_count));
        END IF;
          l_count := 0;

       END IF;   --Include check for discounts --

       IF P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_TRX_TYPE IS NOT NULL THEN
        DELETE  FROM zx_rep_trx_detail_t dtl1
             WHERE trx_line_id <>( SELECT  min(dtl2.trx_line_id)
                                     FROM zx_rep_trx_detail_t dtl2
                                    WHERE dtl2.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
                             AND dtl2.trx_id = dtl1.trx_id
                            and dtl2.TAXABLE_ITEM_SOURCE_ID = dtl1.TAXABLE_ITEM_SOURCE_ID
                            AND dtl2.EVENT_CLASS_CODE = dtl1.EVENT_CLASS_CODE
                            AND dtl2.application_id = dtl1.application_id
                       GROUP BY dtl2.request_id,dtl2.trx_id
                            HAVING count(distinct dtl2.applied_to_trx_line_id) >=2)
             AND dtl1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
             AND dtl1.EVENT_CLASS_CODE ='INVOICE_ADJUSTMENT'
             AND dtl1.application_id = 222;
       END IF;

       IF P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AR_ADJ_TRX_CLASS = 'Y' THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
            SELECT count(*) INTO l_count
              FROM zx_rep_trx_detail_t dtl1
             WHERE trx_line_id <>( SELECT  min(dtl2.trx_line_id)
                                     FROM zx_rep_trx_detail_t dtl2
                           WHERE dtl2.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
                             AND dtl2.trx_id = dtl1.trx_id
                             AND dtl2.tax_line_number = dtl1.tax_line_number
                             AND dtl2.tax_rate_id = dtl1.tax_rate_id
                            and dtl2.TAXABLE_ITEM_SOURCE_ID = dtl1.TAXABLE_ITEM_SOURCE_ID
                            AND dtl2.EVENT_CLASS_CODE = dtl1.EVENT_CLASS_CODE
                          --  AND dtl2.APPLIED_FROM_EVENT_CLASS_CODE = dtl1.APPLIED_FROM_EVENT_CLASS_CODE
                            AND dtl2.application_id = dtl1.application_id
                        --    AND dtl2.ref_cust_trx_line_gl_dist_id <> dtl1.ref_cust_trx_line_gl_dist_id
                       GROUP BY dtl2.request_id,dtl2.trx_id, dtl2.EVENT_CLASS_CODE, dtl2.tax_line_number, dtl2.tax_rate_id
                            HAVING count(distinct dtl2.trx_line_id) >=2)
             AND dtl1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
             AND dtl1.EVENT_CLASS_CODE ='ADJ'
            --AND dtl1.APPLIED_FROM_EVENT_CLASS_CODE = 'ADJ'
             AND dtl1.application_id = 222;
        END IF;
            DELETE  FROM zx_rep_trx_detail_t dtl1
             WHERE trx_line_id <>( SELECT  min(dtl2.trx_line_id)
                                     FROM zx_rep_trx_detail_t dtl2
                                    WHERE dtl2.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
                             AND dtl2.trx_id = dtl1.trx_id
                             AND dtl2.tax_line_number = dtl1.tax_line_number
                             AND dtl2.tax_rate_id = dtl1.tax_rate_id
                            and dtl2.TAXABLE_ITEM_SOURCE_ID = dtl1.TAXABLE_ITEM_SOURCE_ID
                            AND dtl2.EVENT_CLASS_CODE = dtl1.EVENT_CLASS_CODE
                         --   AND dtl2.APPLIED_FROM_EVENT_CLASS_CODE = dtl1.APPLIED_FROM_EVENT_CLASS_CODE
                            AND dtl2.application_id = dtl1.application_id
                        --    AND dtl2.ref_cust_trx_line_gl_dist_id <> dtl1.ref_cust_trx_line_gl_dist_id
                       GROUP BY dtl2.request_id,dtl2.trx_id, dtl2.EVENT_CLASS_CODE, dtl2.tax_line_number, dtl2.tax_rate_id
                            HAVING count(distinct dtl2.trx_line_id) >=2)
             AND dtl1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
             AND dtl1.EVENT_CLASS_CODE ='ADJ'
            --AND dtl1.APPLIED_FROM_EVENT_CLASS_CODE = 'ADJ'
             AND dtl1.application_id = 222;

           IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.Before Dist cursor Opened',
               'Delete Duplicate rows for AR Adjustments : '||to_char(l_count));
           END IF;
           l_count := 0;
        END IF;   -- Include flag check for ADJ --
     END IF;  -- Summary level Check --

     IF (P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION'
        AND P_TRL_GLOBAL_VARIABLES_REC.REPORTING_LEDGER_ID is NULL
        AND P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AR_ADJ_TRX_CLASS in ('TAX ADJUSTMENTS','ADJUSTMENTS')) THEN
        DELETE FROM zx_rep_trx_detail_t dtl1
               WHERE trx_line_id <>( SELECT  min(dtl2.trx_line_id)
                                       FROM zx_rep_trx_detail_t dtl2
                                      WHERE dtl2.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
                                        AND dtl2.trx_id = dtl1.trx_id
                                        AND dtl2.tax_line_number = dtl1.tax_line_number
                                        AND dtl2.tax_rate_id = dtl1.tax_rate_id
                                        and dtl2.TAXABLE_ITEM_SOURCE_ID = dtl1.TAXABLE_ITEM_SOURCE_ID
                                        AND dtl2.EVENT_CLASS_CODE = dtl1.EVENT_CLASS_CODE
                                        AND dtl2.application_id = dtl1.application_id
              GROUP BY dtl2.request_id,dtl2.trx_id, dtl2.EVENT_CLASS_CODE, dtl2.tax_line_number, dtl2.tax_rate_id
                                     HAVING count(distinct dtl2.trx_line_id) >=2)
                         AND dtl1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
                         AND dtl1.EVENT_CLASS_CODE ='ADJ'
                         AND dtl1.application_id = 222;
    END IF;

   IF P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
   OPEN detail_t_cur(P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID,
                     NVL(p_trl_global_variables_rec.reporting_ledger_id,
                            P_TRL_GLOBAL_VARIABLES_REC.ledger_id));
   ELSE
   OPEN detail_t_cur_trx_line(P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID,
                     NVL(p_trl_global_variables_rec.reporting_ledger_id,
                            P_TRL_GLOBAL_VARIABLES_REC.ledger_id));
   END IF;
   LOOP
   IF P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
      FETCH detail_t_cur BULK COLLECT INTO
      GT_DETAIL_TAX_LINE_ID,
      GT_LEDGER_ID,
      GT_INTERNAL_ORGANIZATION_ID,
      GT_TAX_DATE,
      GT_HQ_ESTB_REG_NUMBER,
      GT_TRX_ID,
      GT_TRX_TYPE_ID,
      GT_DOC_SEQ_ID,
      GT_TRX_CLASS,
      GT_TRX_BATCH_SOURCE_ID,
      GT_TAX_RATE_ID,
      GT_TAX_RATE_VAT_TRX_TYPE_CODE,
      GT_TAX_RATE_REG_TYPE_CODE,
      GT_TAX_EXEMPTION_ID,
      GT_TAX_EXCEPTION_ID,
      GT_TAX_LINE_ID,
      GT_TAX_AMT,
      GT_TAX_AMT_FUNCL_CURR,
      GT_TAX_LINE_NUMBER,
      GT_TAXABLE_AMT,
      GT_TAXABLE_AMT_FUNCL_CURR,
      GT_TRX_LINE_ID,
      GT_TAX_EXCEPTION_REASON_CODE,
      GT_EXEMPT_REASON_CODE,
      GT_RECONCILIATION_FLAG,
      GT_INTERNAL_ORGANIZATION_ID,
      GT_BR_REF_CUSTOMER_TRX_ID,
      GT_REVERSE_FLAG,
      GT_AMOUNT_APPLIED,
      GT_TAX_RATE,
      GT_TAX_RATE_CODE,
      GT_TAX_RATE_CODE_NAME,
      GT_TAX_TYPE_CODE,
      GT_TRX_DATE,
      GT_TRX_CURRENCY_CODE,
      GT_CURRENCY_CONVERSION_RATE,
      GT_APPLICATION_ID,
      GT_DOC_EVENT_STATUS,
      GT_EXTRACT_SOURCE_LEDGER,
      GT_FUNCTIONAL_CURRENCY_CODE,
      GT_MINIMUM_ACCOUNTABLE_UNIT,
      GT_PRECISION,
      GT_RECEIPT_CLASS_ID,
      GT_EXCEPTION_RATE,
      GT_SHIP_FROM_PARTY_TAX_PROF_ID,
      GT_SHIP_FROM_SITE_TAX_PROF_ID,
      GT_SHIP_TO_PARTY_TAX_PROF_ID,
      GT_SHIP_TO_SITE_TAX_PROF_ID,
      GT_BILL_TO_PARTY_TAX_PROF_ID,
      GT_BILL_TO_SITE_TAX_PROF_ID,
      GT_BILL_FROM_PARTY_TAX_PROF_ID,
      GT_BILL_FROM_SITE_TAX_PROF_ID,
      GT_BILLING_TP_ID,         --bill_third_pty_acct_id
      GT_BILLING_TP_SITE_ID,    --bill_to_cust_acct_site_use_id
      GT_BILLING_TP_ADDRESS_ID, --bill_third_pty_acct_site_id
      GT_SHIPPING_TP_ID,        --ship_third_pty_acct_id
      GT_SHIPPING_TP_SITE_ID,   --ship_to_cust_acct_site_use_id
      GT_SHIPPING_TP_ADDRESS_ID, --SHIP_THIRD_PTY_ACCT_SITE_ID
      GT_BILL_TO_PARTY_ID,
      GT_BILL_TO_PARTY_SITE_ID,
      GT_SHIP_TO_PARTY_ID,
      GT_SHIP_TO_PARTY_SITE_ID,
      GT_HISTORICAL_FLAG,
      GT_POSTED_DATE,
      gt_actg_event_type_code,
      gt_actg_event_number,
      gt_actg_event_status_flag,
      gt_actg_category_code,
      gt_accounting_date,
      gt_gl_transfer_flag,
      --gt_gl_transfer_run_id,
      gt_actg_header_description,
      gt_actg_line_num,
      gt_actg_line_type_code,
      gt_actg_line_description,
      gt_actg_stat_amt,
      gt_actg_error_code,
      gt_gl_transfer_code,
      gt_actg_doc_sequence_id,
      --  gt_actg_doc_sequence_name,
      gt_actg_doc_sequence_value,
      gt_actg_party_id,
      gt_actg_party_site_id,
      gt_actg_party_type,
      gt_actg_event_id,
      gt_actg_header_id,
     --   gt_actg_source_table,
      gt_actg_line_ccid,
      gt_period_name,
      gt_actg_source_id,
      gt_bank_account_id,
      gt_tax_determine_date
      LIMIT C_LINES_PER_COMMIT;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.Dist cursor Opened',
             'detail_t_cur : ');
     END IF;

  ELSE
  FETCH detail_t_cur_trx_line BULK COLLECT INTO
      GT_DETAIL_TAX_LINE_ID,
      GT_LEDGER_ID,
      GT_INTERNAL_ORGANIZATION_ID,
      GT_TAX_DATE,
      GT_HQ_ESTB_REG_NUMBER,
      GT_TRX_ID,
      GT_TRX_TYPE_ID,
      GT_DOC_SEQ_ID,
      GT_TRX_CLASS,
      GT_TRX_BATCH_SOURCE_ID,
      GT_TAX_RATE_ID,
      GT_TAX_RATE_VAT_TRX_TYPE_CODE,
      GT_TAX_RATE_REG_TYPE_CODE,
      GT_TAX_EXEMPTION_ID,
      GT_TAX_EXCEPTION_ID,
      GT_TAX_LINE_ID,
      GT_TAX_AMT,
      GT_TAX_AMT_FUNCL_CURR,
      GT_TAX_LINE_NUMBER,
      GT_TAXABLE_AMT,
      GT_TAXABLE_AMT_FUNCL_CURR,
      GT_TRX_LINE_ID,
      GT_TAX_EXCEPTION_REASON_CODE,
      GT_EXEMPT_REASON_CODE,
      GT_RECONCILIATION_FLAG,
      GT_INTERNAL_ORGANIZATION_ID,
      GT_BR_REF_CUSTOMER_TRX_ID,
      GT_REVERSE_FLAG,
      GT_AMOUNT_APPLIED,
      GT_TAX_RATE,
      GT_TAX_RATE_CODE,
      GT_TAX_RATE_CODE_NAME,
      GT_TAX_TYPE_CODE,
      GT_TRX_DATE,
      GT_TRX_CURRENCY_CODE,
      GT_CURRENCY_CONVERSION_RATE,
      GT_APPLICATION_ID,
      GT_DOC_EVENT_STATUS,
      GT_EXTRACT_SOURCE_LEDGER,
      GT_FUNCTIONAL_CURRENCY_CODE,
      GT_MINIMUM_ACCOUNTABLE_UNIT,
      GT_PRECISION,
      GT_RECEIPT_CLASS_ID,
      GT_EXCEPTION_RATE,
      GT_SHIP_FROM_PARTY_TAX_PROF_ID,
      GT_SHIP_FROM_SITE_TAX_PROF_ID,
      GT_SHIP_TO_PARTY_TAX_PROF_ID,
      GT_SHIP_TO_SITE_TAX_PROF_ID,
      GT_BILL_TO_PARTY_TAX_PROF_ID,
      GT_BILL_TO_SITE_TAX_PROF_ID,
      GT_BILL_FROM_PARTY_TAX_PROF_ID,
      GT_BILL_FROM_SITE_TAX_PROF_ID,
      GT_BILLING_TP_ID,         --bill_third_pty_acct_id
      GT_BILLING_TP_SITE_ID,    --bill_to_cust_acct_site_use_id
      GT_BILLING_TP_ADDRESS_ID, --bill_third_pty_acct_site_id
      GT_SHIPPING_TP_ID,        --ship_third_pty_acct_id
      GT_SHIPPING_TP_SITE_ID,   --ship_to_cust_acct_site_use_id
      GT_SHIPPING_TP_ADDRESS_ID, --SHIP_THIRD_PTY_ACCT_SITE_ID
      GT_BILL_TO_PARTY_ID,
      GT_BILL_TO_PARTY_SITE_ID,
      GT_SHIP_TO_PARTY_ID,
      GT_SHIP_TO_PARTY_SITE_ID,
      GT_HISTORICAL_FLAG,
      GT_POSTED_DATE,
      gt_actg_event_type_code,
      gt_actg_event_number,
      gt_actg_event_status_flag,
      gt_actg_category_code,
      gt_accounting_date,
      gt_gl_transfer_flag,
      --gt_gl_transfer_run_id,
      gt_actg_header_description,
      gt_actg_line_num,
      gt_actg_line_type_code,
      gt_actg_line_description,
      gt_actg_stat_amt,
      gt_actg_error_code,
      gt_gl_transfer_code,
      gt_actg_doc_sequence_id,
      --  gt_actg_doc_sequence_name,
      gt_actg_doc_sequence_value,
      gt_actg_party_id,
      gt_actg_party_site_id,
      gt_actg_party_type,
      gt_actg_event_id,
      gt_actg_header_id,
     --   gt_actg_source_table,
      gt_actg_line_ccid,
      gt_period_name,
      gt_actg_source_id,
      gt_bank_account_id,
      gt_tax_determine_date
      LIMIT C_LINES_PER_COMMIT;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.Trx / Line cursor Opened',
             'detail_t_cur_trx_line : ');
     END IF;
  END IF;


     l_count := nvl(GT_DETAIL_TAX_LINE_ID.COUNT,0);

    -- Initialize j value for accounting records count --
     j:=0;
     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
             'Row Count After fetch : ' ||to_char(l_count));
     END IF;

     IF l_count >0 THEN
        initialize_variables(l_count);

        G_REP_CONTEXT_ID := ZX_EXTRACT_PKG.GET_REP_CONTEXT_ID(P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID,
                                                                 P_TRL_GLOBAL_VARIABLES_REC.request_id);

      FOR i IN 1..l_count
      LOOP
         L_TRX_CLASS := GT_TRX_CLASS(i);

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
    'Inside Loop : detail tax line id:'||to_char(gt_detail_tax_line_id(i)));
    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
    'i : '||to_char(i)||' L_TRX_CLASS : '||L_TRX_CLASS);
  END IF;

-- bulk comment
-- the below IF clause is redundant as local variables are not used anywhere?
-- retaining for now
         IF P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION'
          OR ( UPPER(L_TRX_CLASS) IN
             ('APP','EDISC','UNEDISC','ADJ','FINCHRG','MISC_CASH_RECEIPT','BR') )
         THEN
         --     Pass the taxable amount columns for rounding
            L_TAXABLE_AMOUNT  :=  GT_TAXABLE_AMT(i);
            L_TAXABLE_ACCOUNTED_AMOUNT := GT_TAXABLE_AMT_FUNCL_CURR(i);
         END IF;

    -- Replacement to populate_inv()

       IF  L_TRX_CLASS IN ('APP','EDISC','UNEDISC','ADJ','FINCHRG','MISC_CASH_RECEIPT','BR')
         THEN
  APP_FUNCTIONAL_AMOUNTS(
                   GT_TRX_ID(i),
                   GT_TAX_RATE_ID(i),
                   GT_TRX_CURRENCY_CODE(i),
                   GT_CURRENCY_CONVERSION_RATE(i),
                   GT_PRECISION(i),
                   GT_MINIMUM_ACCOUNTABLE_UNIT(i),
                   GT_TAX_AMT(i),
                   GT_TAXABLE_AMT(i),
                   P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
                   P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE,
                   i);
       END IF;


  IF (gt_posted_date(i) IS NOT NULL AND
                 P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL  = 'TRANSACTION_DISTRIBUTION' ) THEN

         IF p_trl_global_variables_rec.include_accounting_segments='Y' THEN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
                'get_accounting_info Call:');
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
        'detail tax line id:'||to_char(gt_detail_tax_line_id(i)));
      END IF;

      j:=j+1;
      agt_detail_tax_line_id(j)       :=   gt_detail_tax_line_id(i);
      agt_actg_event_type_code(j)     :=   gt_actg_event_type_code(i);
      agt_actg_event_number(j)        :=   gt_actg_event_number(i);
      agt_actg_event_status_flag(j)   :=   gt_actg_event_status_flag(i);
      agt_actg_category_code(j)       :=   gt_actg_category_code(i);
      agt_accounting_date(j)          :=   gt_accounting_date(i);
      agt_gl_transfer_flag(j)         :=   gt_gl_transfer_flag(i);
      -- agt_gl_transfer_run_id(j)       :=   gt_gl_transfer_run_id(i);
      agt_actg_header_description(j)  :=   gt_actg_header_description(i);
      agt_actg_line_num(j)            :=   gt_actg_line_num(i);
      agt_actg_line_type_code(j)      :=   gt_actg_line_type_code(i);
      agt_actg_line_description(j)    :=   gt_actg_line_description(i);
      agt_actg_stat_amt(j)            :=   gt_actg_stat_amt(i);
      agt_actg_error_code(j)          :=   gt_actg_error_code(i);
      agt_gl_transfer_code(j)         :=   gt_gl_transfer_code(i);
      agt_actg_doc_sequence_id(j)     :=   gt_actg_doc_sequence_id(i);
      --  agt_actg_doc_sequence_name(j) :=   gt_actg_doc_sequence_name(i);
      agt_actg_doc_sequence_value(j)  :=   gt_actg_doc_sequence_value(i);
      agt_actg_party_id(j)            :=   gt_actg_party_id(i);
      agt_actg_party_site_id(j)       :=   gt_actg_party_site_id(i);
      agt_actg_party_type(j)          :=   gt_actg_party_type(i);
      agt_actg_event_id(j)            :=   gt_actg_event_id(i);
      agt_actg_header_id(j)           :=   gt_actg_header_id(i);
      agt_actg_source_id(j)           :=   gt_actg_source_id(i);
      -- agt_actg_source_table(j)      :=   gt_actg_source_table(i);
      agt_actg_line_ccid(j)           :=   gt_actg_line_ccid(i);
      agt_period_name(j)              :=   gt_period_name(i);

      get_accounting_info(GT_TRX_ID(i),
              GT_TRX_LINE_ID(i),
              GT_TAX_LINE_ID(i),
              GT_ACTG_EVENT_ID(i),
              GT_ACTG_HEADER_ID(i),
              GT_ACTG_SOURCE_ID(i),
              l_balancing_segment,
              l_accounting_segment,
              P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
              P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME,
              L_TRX_CLASS,
              j) ;

            END IF;  -- Inlude account segments parameter check --

             IF p_trl_global_variables_rec.reporting_ledger_id IS NOT NULL
             THEN
      get_accounting_amounts(GT_TRX_ID(i),
              GT_TRX_LINE_ID(i),
              GT_TAX_LINE_ID(i),
          --          GT_ENTITY_ID(i),
              GT_ACTG_EVENT_ID(i),
              GT_ACTG_HEADER_ID(i),
              GT_ACTG_SOURCE_ID(i),
              P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
              L_TRX_CLASS,
              p_trl_global_variables_rec.reporting_ledger_id, --l_ledger_id,
              i) ;
             END IF;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
        'inv_actg_amounts call :GT_TAXABLE_AMT, GT_TAXABLE_AMT_FUNCL_CURR'||to_char(GT_TAXABLE_AMT(i))||
        'i='||to_char(i)||' j='||to_char(i)
         ||'-'||to_char(GT_TAXABLE_AMT_FUNCL_CURR(i)));
      END IF;
    --GT_TAXABLE_AMT_FUNCL_CURR(i) := null;
    --GT_TAX_AMT_FUNCL_CURR(i) := null;

  END IF;  -- Posted date check ---


--Check This Code
--          IF UPPER(L_TRX_CLASS) IN ('APP','EDISC','UNEDISC','ADJ','FINCHRG',
 --                                   'MISC_CASH_RECEIPT','BR')
  --            AND  GT_TAX_CODE_ID_TAB(i) IS NULL
   --           AND GT_TAX_OFFSET_TAX_CODE_ID_TAB(i) IS NOT NULL
    --      THEN
--
 --           PG_TAX_CODE_ID_TAB(i) := PG_TAX_OFFSET_TAX_CODE_ID_TAB(i);
--
 --         END If;
    -- Call to populate party information --
            EXTRACT_PARTY_INFO(i);
           populate_meaning(
                  P_TRL_GLOBAL_VARIABLES_REC,
                   i);

           IF (P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION'
                    AND GT_TRX_CLASS(i) = 'ADJ' ) THEN
                         get_tax_rate_info_dist_adj(i);
           END IF;

  -- This api populates first party registration number if the HQ_ESTB_REG_NUMBER is null
  --
           IF GT_HQ_ESTB_REG_NUMBER(i) IS NULL AND
              P_TRL_GLOBAL_VARIABLES_REC.FIRST_PARTY_TAX_REG_NUM IS NULL THEN
              populate_tax_reg_num(
                   P_TRL_GLOBAL_VARIABLES_REC,
                   GT_INTERNAL_ORGANIZATION_ID(i),
                   GT_TAX_DATE(i),
                   i);
           ELSE
              GT_TAX_REG_NUM(i) := GT_HQ_ESTB_REG_NUMBER(i);
           END IF;



      END LOOP; -- end loop of each extract line

    END IF;

     --   Call to update additional information in zx_rep_trx_detail_t table --

          UPDATE_REP_DETAIL_T(l_count);

     --   Call to insert accounting information in zx_rep_actg_ext_t table --

        IF p_trl_global_variables_rec.include_accounting_segments='Y'
           AND NVL(gt_posted_date.count,0) <> 0 THEN
           insert_actg_info(j);
        END IF;

     IF P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
         EXIT WHEN detail_t_cur%NOTFOUND
              OR detail_t_cur%NOTFOUND IS NULL;
     ELSE
         EXIT WHEN detail_t_cur_trx_line%NOTFOUND
              OR detail_t_cur_trx_line%NOTFOUND IS NULL;
     END IF;

   END LOOP;

   IF P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
      CLOSE detail_t_cur;
   ELSE
      CLOSE detail_t_cur_trx_line;
   END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO.END',
                                      'ZX_AR_POPULATE_PKG: UPDATE_ADDITIONAL_INFO(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
                      g_error_buffer);
    END IF;

     P_TRL_GLOBAL_VARIABLES_REC.RETCODE := G_RETCODE;

END UPDATE_ADDITIONAL_INFO;


PROCEDURE APP_FUNCTIONAL_AMOUNTS(
  P_TRX_ID                IN NUMBER,
  P_TAX_CODE_ID           IN NUMBER,
  P_CURRENCY_CODE         IN  VARCHAR2,
  P_EXCHANGE_RATE         IN NUMBER,
  P_PRECISION             IN NUMBER,
  P_MIN_ACCT_UNIT         IN   NUMBER,
  P_INPUT_TAX_AMOUNT        IN  OUT NOCOPY NUMBER,
  P_INPUT_TAXABLE_AMOUNT    IN OUT NOCOPY NUMBER,
  P_SUMMARY_LEVEL                 IN VARCHAR2,
  P_REGISTER_TYPE                 IN VARCHAR2,
  i                       IN binary_integer)
  IS


  CURSOR ROUNDING_AMTS_CURSOR (
           C_TRX_ID IN NUMBER,
           C_REGISTER_TYPE IN VARCHAR2,
           C_TAX_ID IN NUMBER )  IS
    SELECT SUM(NVL(ARDTAX.AMOUNT_CR,0) - NVL(ARDTAX.AMOUNT_DR,0)),
           SUM(NVL(ARDTAX.TAXABLE_ENTERED_CR,0) -
                        NVL(ARDTAX.TAXABLE_ENTERED_DR,0))
    FROM   AR_DISTRIBUTIONS_ALL ARDTAX,
           AR_RECEIVABLE_APPLICATIONS_ALL APP,
           RA_CUSTOMER_TRX_ALL TRXCM
    WHERE  TRXCM.CUSTOMER_TRX_ID = C_TRX_ID
      AND  APP.APPLIED_CUSTOMER_TRX_ID = TRXCM.CUSTOMER_TRX_ID
      AND  APP.RECEIVABLE_APPLICATION_ID = ARDTAX.SOURCE_ID
      AND  ARDTAX.SOURCE_TABLE = 'RA'
      AND  ARDTAX.SOURCE_TYPE = DECODE(C_REGISTER_TYPE,'TAX','TAX',
                   'INTERIM','DEFERRED_TAX',NULL)
      AND  ARDTAX.TAX_CODE_ID = C_TAX_ID
      AND  ARDTAX.SOURCE_TABLE_SECONDARY = 'CT'
      AND  ARDTAX.SOURCE_TYPE_SECONDARY = 'RECONCILE'
    GROUP BY C_TRX_ID, C_TAX_ID ;


  L_CURRENCY_CODE        VARCHAR2(15);
  L_EXCHANGE_RATE        NUMBER;
  L_PRECISION            NUMBER;
  L_MIN_ACCT_UNIT        NUMBER;
  L_TAXABLE_AMOUNT       NUMBER;
  L_TAX_AMOUNT           NUMBER;
  L_EXEMPT_AMOUNT        NUMBER;
  L_TAXABLE_ACCTD_AMT    NUMBER;
  L_TAX_ACCTD_AMT        NUMBER;
  L_ORG_ID               NUMBER;
  L_MATRIX_STATEMENT     VARCHAR2(5000);
  L_CONTROL_ACCOUNT_CCID NUMBER;
  L_SET_OF_BOOKS_ID      NUMBER;
  L_AH_ACCOUNTING_DATE   DATE;
  L_ROUNDING_TAXABLE_AMT NUMBER;
  L_ROUNDING_TAX_AMT     NUMBER;
  l_al_third_party_id    NUMBER;
  l_al_third_party_sub_id NUMBER;
  l_gl_posted_date       DATE;

  L_TRX_CLASS                  VARCHAR2(30);
  L_DIST_ID                    NUMBER;
  L_BAL_SEG_STATEMENT          VARCHAR2(1000);
  L_BR_PARENT_TRX_ID           NUMBER;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.APP_FUNCTIONAL_AMOUNTS.BEGIN',
                                      'ZX_AR_POPULATE_PKG: APP_FUNCTIONAL_AMOUNTS(+)');
    END IF;

--  L_ORG_ID := P_RA_SUB_ITF_TABLE_REC.org_id;
--  L_CONTROL_ACCOUNT_CCID := P_RA_SUB_ITF_TABLE_REC.al_account_ccid;
 -- L_SET_OF_BOOKS_ID := P_RA_SUB_ITF_TABLE_REC.set_of_books_id;
--  L_AH_ACCOUNTING_DATE := P_RA_SUB_ITF_TABLE_REC.accounting_date;
--  L_GL_POSTED_DATE := P_RA_SUB_ITF_TABLE_REC.gl_posted_date;
 -- L_CURRENCY_CODE := P_RA_SUB_ITF_TABLE_REC.currency_code;
--  L_EXCHANGE_RATE := P_RA_SUB_ITF_TABLE_REC.exchange_rate;
--  L_PRECISION := P_RA_SUB_ITF_TABLE_REC.precision;
--  L_TAX_AMOUNT := P_RA_SUB_ITF_TABLE_REC.tax_entered_amount;
 -- L_TAXABLE_AMOUNT := P_RA_SUB_ITF_TABLE_REC.taxable_amount;
--  L_EXEMPT_AMOUNT := P_RA_SUB_ITF_TABLE_REC.exempt_entered_amount;


  --L_TRX_CLASS := P_RA_SUB_ITF_TABLE_REC.TRX_CLASS_CODE;
 -- L_DIST_ID   := P_RA_SUB_ITF_TABLE_REC.ACCTG_DIST_ID;

--  L_AL_THIRD_PARTY_ID     := P_RA_SUB_ITF_TABLE_REC.BILLING_TRADING_PARTNER_ID;
 -- L_AL_THIRD_PARTY_SUB_ID := P_RA_SUB_ITF_TABLE_REC.BILLING_TP_SITE_ID;


  -- get ah_period_name
--  get_acctg_period_name(L_SET_OF_BOOKS_ID,
 --                       L_AH_ACCOUNTING_DATE,
  --                      P_AH_PERIOD_NAME);
--
--  P_TAX_EXTRACT_DECLARER_ID := ARP_TAX_EXTRACT.GET_DECLARER_ID
 --                            ( L_ORG_ID) ;

  IF UPPER(P_SUMMARY_LEVEL) = 'TRANSACTION' THEN

   -- IF P_RECONCILIATION_FLAG = 'Y' THEN --rm input parameter
 --  IF P_RA_SUB_ITF_TABLE_REC.RECONCILIATION_FLAG  = 'Y' THEN
      -- Fetch the reconciliation amounts and add to the tax/taxable amounts
      OPEN  ROUNDING_AMTS_CURSOR (
                    P_TRX_ID,
                    P_REGISTER_TYPE,
                    P_TAX_CODE_ID );

      FETCH ROUNDING_AMTS_CURSOR INTO
                       L_ROUNDING_TAX_AMT, L_ROUNDING_TAXABLE_AMT ;
      CLOSE ROUNDING_AMTS_CURSOR;

      P_INPUT_TAX_AMOUNT := P_INPUT_TAX_AMOUNT + nvl(L_ROUNDING_TAX_AMT,0);
      P_INPUT_TAXABLE_AMOUNT:= P_INPUT_TAXABLE_AMOUNT +
                                    nvl(L_ROUNDING_TAXABLE_AMT,0);

  --  END IF;

    L_TAXABLE_AMOUNT := L_TAXABLE_AMOUNT - nvl(L_EXEMPT_AMOUNT,0);

          convert_amounts( P_CURRENCY_CODE,
                          P_EXCHANGE_RATE,
                          P_PRECISION,
                          P_MIN_ACCT_UNIT,
                          P_INPUT_TAX_AMOUNT,
                          P_INPUT_TAXABLE_AMOUNT,
                          0, i);

  ELSIF  P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN

            convert_amounts(
                            P_CURRENCY_CODE,
                            P_EXCHANGE_RATE,
                            P_PRECISION,
                            P_MIN_ACCT_UNIT,
                            P_INPUT_TAX_AMOUNT,
                            P_INPUT_TAXABLE_AMOUNT,
                            0,i);

  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN

            convert_amounts(
                            P_CURRENCY_CODE,
                            P_EXCHANGE_RATE,
                            P_PRECISION,
                            P_MIN_ACCT_UNIT,
                            P_INPUT_TAX_AMOUNT,
                            P_INPUT_TAXABLE_AMOUNT,
                            0,i);

  END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.APP_FUNCTIONAL_AMOUNTS.END',
                                      'ZX_AR_POPULATE_PKG: APP_FUNCTIONAL_AMOUNTS(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.APP_FUNCTIONAL_AMOUNTS',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;

END APP_FUNCTIONAL_AMOUNTS;



PROCEDURE get_accounting_info (P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                   --           P_ENTITY_ID             IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_ACTG_SOURCE_ID           IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                              P_REPORT_NAME           IN VARCHAR2,
                              P_TRX_CLASS             IN VARCHAR2,
                              j                       IN binary_integer) IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_info.BEGIN',
                                      'ZX_AR_POPULATE_PKG: get_accounting_info(+)' );
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_info',
                                      'j := '||to_char(j));
    END IF;

 IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_info',
          'TRANSACTION DIST LEVEL : p_trx_id - p_event_id - p_ae_header_id- p_trx_line_id'
          ||to_char(p_trx_id)||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)
          ||'-'||to_char(p_trx_line_id));
 END IF;

  IF p_trx_class in ('INVOICE','CREDIT_MEMO','DEBIT_MEMO') THEN
     inv_segment_info (P_TRX_ID,
                       P_TRX_LINE_ID,
                       P_TAX_LINE_ID,
                   --  P_ENTITY_ID,
                       P_EVENT_ID,
                       P_AE_HEADER_ID,
                       P_ACTG_SOURCE_ID,
                       P_BALANCING_SEGMENT,
                       P_ACCOUNTING_SEGMENT,
                       P_SUMMARY_LEVEL,
                       P_REPORT_NAME,
                       P_TRX_CLASS,
                       j);

  ELSIF  p_trx_class IN ('APP','EDISC','UNEDISC','ADJ','FINCHRG',
                       'MISC_CASH_RECEIPT') THEN
     other_trx_segment_info(P_TRX_ID,
                              P_TRX_LINE_ID,
                              P_TAX_LINE_ID,
                   --           P_ENTITY_ID,
                              P_EVENT_ID,
                              P_AE_HEADER_ID,
                              P_ACTG_SOURCE_ID,
                              P_BALANCING_SEGMENT,
                              P_ACCOUNTING_SEGMENT,
                              P_SUMMARY_LEVEL,
                              P_TRX_CLASS,
                              j);
  END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_info.END',
                                      'ZX_AR_POPULATE_PKG: get_accounting_info(-)');
    END IF;

END get_accounting_info;

PROCEDURE get_accounting_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                  --             P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_ACTG_SOURCE_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                                 P_LEDGER_ID             IN NUMBER,
                                 j                       IN binary_integer) IS
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts.BEGIN',
                                      'ZX_AR_POPULATE_PKG: get_accounting_amounts(+)');
    END IF;

   IF p_trx_class in ('INVOICE','CREDIT_MEMO','DEBIT_MEMO') THEN
      inv_actg_amounts(P_TRX_ID,
                       P_TRX_LINE_ID,
                       P_TAX_LINE_ID,
                  --   P_ENTITY_ID,
                       P_EVENT_ID,
                       P_AE_HEADER_ID,
                       P_ACTG_SOURCE_ID,
                       P_SUMMARY_LEVEL,
                       P_TRX_CLASS,
                       P_LEDGER_ID,
                       j);
   IF (g_level_procedure >= g_current_runtime_level ) THEN
  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts',
  'trx_id : '||p_trx_id||' tax_line_id : '||P_TAX_LINE_ID||' j : ' ||j);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts',
               'inv_actg_amounts call :GT_TAXABLE_AMT, GT_TAXABLE_AMT_FUNCL_CURR ::: '||to_char(GT_TAXABLE_AMT(j))
                 ||'-'||to_char(GT_TAXABLE_AMT_FUNCL_CURR(j)));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts',
               'inv_actg_amounts call :GT_TAX_AMT, GT_TAX_AMT_FUNCL_CURR ::: '||to_char(GT_TAX_AMT(j))
                 ||'-'||to_char(GT_TAX_AMT_FUNCL_CURR(j)));
    END IF;

   ELSIF p_trx_class IN ('APP','EDISC','UNEDISC','ADJ','FINCHRG',
                       'MISC_CASH_RECEIPT') THEN
     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts',
                       'p_trx_class: '||to_char(p_trx_class)|| 'so calling other_trx_actg_amounts ' );
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_actg_amounts',
          'p_trx_id - p_event_id - p_ae_header_id- p_actg_source_id- p_ledger_id '
          ||to_char(p_trx_id)||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)
          ||'-'||to_char(p_actg_source_id)||'-'||to_char(p_ledger_id));
     END IF;
     other_trx_actg_amounts(P_TRX_ID,
                            P_TRX_LINE_ID,
                            P_TAX_LINE_ID,
                  --        P_ENTITY_ID,
                            P_EVENT_ID,
                            P_AE_HEADER_ID,
                            P_ACTG_SOURCE_ID,
                            P_SUMMARY_LEVEL,
                            P_TRX_CLASS,
                            P_LEDGER_ID,
                            j);
     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts',
                      'other_trx_actg_amounts: trx_id : '||p_trx_id||' j : ' ||j);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts',
               'other_trx_actg_amounts call :GT_TAXABLE_AMT, GT_TAXABLE_AMT_FUNCL_CURR ::: '||to_char(GT_TAXABLE_AMT(j))
                 ||' - '||to_char(GT_TAXABLE_AMT_FUNCL_CURR(j)));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts',
               'other_trx_actg_amounts call :GT_TAX_AMT, GT_TAX_AMT_FUNCL_CURR ::: '||to_char(GT_TAX_AMT(j))
                 ||' - '||to_char(GT_TAX_AMT_FUNCL_CURR(j)));
    END IF;
  END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.get_accounting_amounts.END',
                                      'ZX_AR_POPULATE_PKG: get_accounting_amounts(-)');
    END IF;


END get_accounting_amounts;

PROCEDURE inv_segment_info (P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                   --           P_ENTITY_ID             IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_ACTG_SOURCE_ID           IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                              P_REPORT_NAME         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                              j                       IN binary_integer) IS
    CURSOR trx_ccid (c_trx_id number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.account_class = 'REV'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                      AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND ael.application_id = lnk.application_id
                     AND ael.accounting_class_code = 'REVENUE'
              AND rownum =1;

    CURSOR trx_line_ccid (c_trx_id number, c_trx_line_id number, c_event_id number, c_ae_header_id NUMBER) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.customer_trx_line_id = c_trx_line_id
                     AND gl_dist.account_class = 'REV'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                      AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND ael.application_id = lnk.application_id
                     AND ael.accounting_class_code = 'REVENUE'
              AND rownum =1;


-- For transavtion distribution level code combination id select in the build SQL
-- The following query can be removed ----

  CURSOR trx_dist_ccid (c_trx_id NUMBER, c_trx_line_id NUMBER, c_event_id NUMBER, c_ae_header_id NUMBER) IS
                  SELECT
                         /*+ leading(gl_dist)*/ ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.customer_trx_line_id = c_trx_line_id
                     AND gl_dist.account_class = 'REV'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                      AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND ael.application_id = lnk.application_id
                     AND ael.accounting_class_code = 'REVENUE'
              AND rownum =1;


    CURSOR tax_ccid (c_trx_id number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.account_class = 'TAX'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND ael.application_id = lnk.application_id
                     AND ael.accounting_class_code <> 'RECEIVABLE'
                     AND rownum =1;

    CURSOR tax_line_ccid (c_trx_id number, c_tax_line_id NUMBER, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.customer_trx_line_id = c_tax_line_id
                     AND gl_dist.account_class = 'TAX'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND ael.application_id = lnk.application_id
                     AND ael.accounting_class_code <> 'RECEIVABLE'
                     AND rownum =1;


-- For transavtion distribution level code combination id select in the build SQL
-- The following query can be removed ----

  --CURSOR tax_dist_ccid (c_trx_id NUMBER, c_tax_line_id NUMBER, c_tax_line_dist_id NUMBER,
   --                                   c_event_id number, c_ae_header_id number) IS
  CURSOR tax_dist_ccid (c_trx_id NUMBER, c_tax_line_dist_id NUMBER,
                                      c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                   --  AND gl_dist.customer_trx_line_id = c_tax_line_id
                     AND gl_dist.cust_trx_line_gl_dist_id = c_tax_line_dist_id
                     AND gl_dist.account_class = 'TAX'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND ael.application_id = lnk.application_id
                     AND ael.accounting_class_code <> 'RECEIVABLE'
                     AND rownum =1;

  L_BAL_SEG_VAL  VARCHAR2(240);
  L_BAL_SEG_DESC VARCHAR2(240);

  L_ACCT_SEG_VAL VARCHAR2(240);
  L_ACCT_SEG_DESC VARCHAR2(240);

  L_SQL_STATEMENT1     VARCHAR2(1000);
 L_SQL_STATEMENT2     VARCHAR2(1000);
 l_ccid number;
 l_tax_dist_ccid number;
 L_TRX_DIST_CCID NUMBER ;
BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info.BEGIN',
                                      'ZX_AR_POPULATE_PKG: inv_segment_info(+)');
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
                                      'j := '||to_char(j));

    END IF;

  GT_TRX_ARAP_BALANCING_SEGMENT(j)    := NULL;
  GT_TRX_ARAP_NATURAL_ACCOUNT(j)      := NULL;
  GT_TRX_TAXABLE_BAL_SEG(j)           := NULL;
  GT_TRX_TAXABLE_BALSEG_DESC(j)       := NULL;
  GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)   := NULL;
  GT_TRX_TAX_BALANCING_SEGMENT(j)     := NULL;
  GT_TRX_TAX_NATURAL_ACCOUNT(j)       := NULL;
    GT_ACCOUNT_FLEXFIELD(j)   :=  NULL;
    GT_ACCOUNT_DESCRIPTION(j)    := NULL;

 GT_TRX_TAXABLE_ACCOUNT_DESC(j) := NULL ;
 GT_TRX_TAXABLE_NATACCT_DESC(j) := NULL ;


  L_BAL_SEG_VAL := '';
  L_ACCT_SEG_VAL := '';
  L_BAL_SEG_DESC := '';
  L_ACCT_SEG_DESC := '';

  L_SQL_STATEMENT1 := ' SELECT '||P_BALANCING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';

  L_SQL_STATEMENT2 := ' SELECT '||P_ACCOUNTING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';


  IF P_SUMMARY_LEVEL = 'TRANSACTION' THEN
      OPEN trx_ccid (p_trx_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_ccid INTO l_ccid;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info.BEGIN',
                                      'ZX_AR_POPULATE_PKG: inv_segment_info(+)');
    END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'TRANSACTION LEVEL : p_trx_id - p_event_id - p_ae_header_id'||to_char(p_trx_id)
               ||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)||'-'||to_char(l_ccid));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT1);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT2);
    END IF;


      EXIT WHEN trx_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(j) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(j)  := GT_TRX_TAXABLE_BAL_SEG(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(j) := GT_TRX_TAXABLE_BAL_SEG(j);
        GT_TRX_ARAP_NATURAL_ACCOUNT(j)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j);
    END LOOP;


      OPEN tax_ccid (p_trx_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(j) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(j)  := GT_TRX_TAX_BALANCING_SEGMENT(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(j)  := GT_TRX_TAX_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;

  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN
      OPEN trx_line_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_line_ccid INTO l_ccid;
      EXIT WHEN trx_line_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(j) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(j)  := GT_TRX_TAXABLE_BAL_SEG(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(j) := GT_TRX_TAXABLE_BAL_SEG(j);
        GT_TRX_ARAP_NATURAL_ACCOUNT(j)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j);
    END LOOP;


      OPEN tax_line_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_line_ccid INTO l_ccid;
      EXIT WHEN tax_line_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(j) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(j)  := GT_TRX_TAX_BALANCING_SEGMENT(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(j)  := GT_TRX_TAX_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;


  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'TRANSACTION DIST LEVEL : p_trx_id - p_event_id - p_ae_header_id- p_trx_line_id'
          ||to_char(p_trx_id)||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)
          ||'-'||to_char(p_trx_line_id)||'-'||to_char(l_ccid));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT1);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT2);
    END IF;

      OPEN trx_dist_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_dist_ccid INTO l_ccid;
      EXIT WHEN trx_dist_ccid%NOTFOUND;
      l_trx_dist_ccid := l_ccid; --Bug 5510907
      IF P_REPORT_NAME = 'ZXJGTAX' THEN
         agt_actg_line_ccid(j) := l_ccid ;
      END IF;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF L_BAL_SEG_VAL IS NOT NULL THEN
           L_BAL_SEG_DESC :=  FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'GL_BALANCING',
                            P_DATA => L_BAL_SEG_VAL);
        END IF;

        IF GT_TRX_TAXABLE_BAL_SEG(j) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(j) := L_BAL_SEG_VAL;
            GT_TRX_TAXABLE_BALSEG_DESC(j) := L_BAL_SEG_DESC;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(j)  := GT_TRX_TAXABLE_BAL_SEG(j)
                                             ||','||L_BAL_SEG_VAL;
                GT_TRX_TAXABLE_BALSEG_DESC(j) := GT_TRX_TAXABLE_BALSEG_DESC(j) || ',' ||L_BAL_SEG_DESC;
            END IF;
        END IF;

--Bug 5650415 : Get the description for the natural Segnemt of the taxable line ccid
        IF L_ACCT_SEG_VAL IS NOT NULL THEN
           L_ACCT_SEG_DESC :=  FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'GL_ACCOUNT',
                            P_DATA => L_ACCT_SEG_VAL);
        END IF;

        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
      GT_TRX_TAXABLE_NATACCT_DESC(j) := L_ACCT_SEG_DESC;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
    GT_TRX_TAXABLE_NATACCT_DESC(j) := GT_TRX_TAXABLE_NATACCT_DESC(j)||','||L_ACCT_SEG_DESC;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(j) := GT_TRX_TAXABLE_BAL_SEG(j);
        GT_TRX_ARAP_NATURAL_ACCOUNT(j)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j);
    END LOOP;

      OPEN tax_dist_ccid (p_trx_id, P_ACTG_SOURCE_ID, p_event_id, p_ae_header_id);
      LOOP
  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'TRANSACTION DIST LEVEL - tax_dist_ccid : p_trx_id - p_event_id - p_ae_header_id- p_tax_line_id'
          ||to_char(p_trx_id)||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)
          ||'-'||to_char(p_tax_line_id)||'-'||to_char(P_ACTG_SOURCE_ID)||'-'||to_char(l_ccid));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT1);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info',
          'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT2);
    END IF;

      FETCH tax_dist_ccid INTO l_ccid;
      EXIT WHEN tax_dist_ccid%NOTFOUND;
        l_tax_dist_ccid := l_ccid;
        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(j) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(j)  := GT_TRX_TAX_BALANCING_SEGMENT(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(j)  := GT_TRX_TAX_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;

   -- populare accounting_flexfield and accounting_description column ---
   ----------------------------------------------------------------------

       IF l_tax_dist_ccid IS NOT NULL THEN

          GT_ACCOUNT_FLEXFIELD(j) := FA_RX_FLEX_PKG.GET_VALUE(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'ALL',
                            P_CCID => l_tax_dist_ccid);

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.INV_SEGMENT_INFO',
                                      'Account Flexfield = '||GT_ACCOUNT_FLEXFIELD(j));
          END IF;

          GT_ACCOUNT_DESCRIPTION(j) := FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'ALL',
                            P_DATA => GT_ACCOUNT_FLEXFIELD(j));

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.INV_SEGMENT_INFO',
                                      'Account Description = '||GT_ACCOUNT_DESCRIPTION(j));
          END IF;

       END IF;

--Bug 5510907 : To get the accounting Flexfield for the Taxable Line

       IF l_trx_dist_ccid IS NOT NULL THEN

          GT_TRX_CONTROL_ACCFLEXFIELD(j) := FA_RX_FLEX_PKG.GET_VALUE(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'ALL',
                            P_CCID => l_trx_dist_ccid);

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.INV_SEGMENT_INFO',
                                      'inv_segment_info : Taxable Line Account Flexfield = '||GT_TRX_CONTROL_ACCFLEXFIELD(j));
          END IF;

--Bug 5650415
          GT_TRX_TAXABLE_ACCOUNT_DESC(j) := FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'ALL',
                            P_DATA => GT_TRX_CONTROL_ACCFLEXFIELD(j));

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.INV_SEGMENT_INFO',
                                      'Account Description for Taxable Line CCID  = '||GT_TRX_TAXABLE_ACCOUNT_DESC(j));
          END IF;

  END IF ;
      ---- End of accounting flexfield population -----------------------

END IF; -- Summary Level
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_segment_info.END',
                                      'ZX_AR_POPULATE_PKG: inv_segment_info(-)');
    END IF;

END inv_segment_info;


PROCEDURE inv_actg_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                  --               P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_ACTG_SOURCE_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                                 P_LEDGER_ID             IN NUMBER,
                                 j                       IN binary_integer) IS
-- Transaction Header Level

   CURSOR taxable_amount_hdr (c_trx_id NUMBER, c_ae_header_id NUMBER, c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)),
               sum(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0))
         FROM ra_cust_trx_line_gl_dist_all gl_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE gl_dist.customer_trx_id = c_trx_id
          AND lnk.application_id = 222
          AND gl_dist.account_class = 'REV'
          AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id       = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id
          AND aeh.application_id = lnk.application_id
          and ael.application_id = aeh.application_id;



   CURSOR tax_amount_hdr (c_trx_id NUMBER, c_ae_header_id NUMBER,  c_event_id NUMBER,c_ledger_id NUMBER) IS
        SELECT sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)),
               sum(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0))
         FROM ra_cust_trx_line_gl_dist_all gl_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE gl_dist.customer_trx_id = c_trx_id
          AND gl_dist.account_class = 'TAX'
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id       = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id;



-- Transaction Line Level

 CURSOR taxable_amount_line (c_trx_id NUMBER,c_trx_line_id NUMBER, c_ae_header_id NUMBER,
                             c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM ra_cust_trx_line_gl_dist_all gl_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE gl_dist.customer_trx_id = c_trx_id
          AND gl_dist.customer_trx_line_id = c_trx_line_id
          AND gl_dist.account_class = 'REV'
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id;



CURSOR tax_amount_line (c_trx_id NUMBER,c_tax_line_id NUMBER, c_ae_header_id NUMBER, c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM ra_cust_trx_line_gl_dist_all gl_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE gl_dist.customer_trx_id = c_trx_id
          AND gl_dist.customer_trx_line_id = c_tax_line_id
          AND gl_dist.account_class = 'TAX'
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id;


-- Transaction Distribution Level



--CURSOR tax_amount_dist ( c_trx_id NUMBER,c_tax_line_id NUMBER, c_tax_dist_id NUMBER, c_ae_header_id NUMBER,
 --                        c_event_id NUMBER, c_ledger_id NUMBER) IS
CURSOR tax_amount_dist ( c_trx_id NUMBER, c_tax_dist_id NUMBER, c_ae_header_id NUMBER,
                         c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)),
               sum(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0))
--sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM ra_cust_trx_line_gl_dist_all gl_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE gl_dist.customer_trx_id = c_trx_id
      --    AND gl_dist.customer_trx_line_id = c_tax_line_id
          AND gl_dist.cust_trx_line_gl_dist_id = c_tax_dist_id
          AND gl_dist.account_class = 'TAX'
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
          AND ael.accounting_class_code = 'TAX'
          AND lnk.ae_header_id   = ael.ae_header_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND lnk.event_id      = c_event_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id;



 CURSOR taxable_amount_dist (c_trx_id NUMBER,c_trx_line_id NUMBER, c_ae_header_id NUMBER,
                      c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)),
               sum(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0))
        --SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM ra_cust_trx_line_gl_dist_all gl_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE gl_dist.customer_trx_id = c_trx_id
          AND gl_dist.customer_trx_line_id = c_trx_line_id
     --     AND gl_dist.account_class = 'REV'
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND ael.accounting_class_code in ('REVENUE','UNEARNED_REVENUE','SUSPENSE','UNBILL')
          AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id       = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id;


BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_actg_amounts.BEGIN',
                                      'ZX_AR_POPULATE_PKG: inv_actg_amounts(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_actg_amounts',
                                      'ZX_AR_POPULATE_PKG: inv_actg_amounts :'|| to_char(p_ledger_id));
    END IF;

   IF p_summary_level = 'TRANSACTION' THEN
      OPEN taxable_amount_hdr(p_trx_id , p_ae_header_id , p_event_id,p_ledger_id );
      FETCH taxable_amount_hdr INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
       --    EXIT WHEN taxable_amount_hdr%NOTFOUND;
       CLOSE taxable_amount_hdr;
   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_actg_amounts',
               'GT_TAXABLE_AMT, GT_TAXABLE_AMT_FUNCL_CURR'||to_char(GT_TAXABLE_AMT(j))
                 ||'-'||to_char(GT_TAXABLE_AMT_FUNCL_CURR(j)));
    END IF;


      OPEN tax_amount_hdr(p_trx_id , p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_hdr INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
--      EXIT WHEN tax_amount_hdr%NOTFOUND;
     CLOSE tax_amount_hdr;
   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_actg_amounts',
               'GT_TAX_AMT, GT_TAX_AMT_FUNCL_CURR'||to_char(GT_TAX_AMT(j))
                 ||'-'||to_char(GT_TAX_AMT_FUNCL_CURR(j)));
    END IF;

  ELSIF p_summary_level = 'TRANSACTION_LINE' THEN
           OPEN taxable_amount_line(p_trx_id ,p_trx_line_id, p_ae_header_id , p_event_id,p_ledger_id);
      FETCH taxable_amount_line INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
  --        EXIT WHEN taxable_amount_line%NOTFOUND;
        CLOSE taxable_amount_line;

      OPEN tax_amount_line(p_trx_id , p_trx_line_id, p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_line INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
--      EXIT WHEN tax_amount_line%NOTFOUND;
      CLOSE tax_amount_line;

  ELSIF p_summary_level = 'TRANSACTION_DISTRIBUTION' THEN

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_actg_amounts',
          'TRANSACTION DIST LEVEL : p_trx_id - p_event_id - p_ae_header_id- p_trx_line_id'
          ||to_char(p_trx_id)||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)
          ||'-'||to_char(p_trx_line_id));
    END IF;

      OPEN taxable_amount_dist(P_TRX_ID ,p_trx_line_id,p_ae_header_id , p_event_id,p_ledger_id);
      FETCH taxable_amount_dist INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
--         EXIT WHEN taxable_amount_dist%NOTFOUND;
        CLOSE taxable_amount_dist;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_actg_amounts',
               'GT_TAXABLE_AMT, GT_TAXABLE_AMT_FUNCL_CURR'||to_char(GT_TAXABLE_AMT(j))
                 ||'-'||to_char(GT_TAXABLE_AMT_FUNCL_CURR(j)));
    END IF;

      --OPEN tax_amount_dist(p_trx_id ,p_tax_line_id,P_ACTG_SOURCE_ID, p_ae_header_id , p_event_id,p_ledger_id);
      OPEN tax_amount_dist(p_trx_id ,P_ACTG_SOURCE_ID, p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_dist INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
 --     EXIT WHEN tax_amount_dist%NOTFOUND;
     CLOSE tax_amount_dist;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_actg_amounts',
               'GT_TAX_AMT, GT_TAX_AMT_FUNCL_CURR'||to_char(GT_TAX_AMT(j))
                 ||'-'||to_char(GT_TAX_AMT_FUNCL_CURR(j)));
    END IF;

 END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.inv_actg_amounts.END',
                                      'ZX_AR_POPULATE_PKG: inv_actg_amounts(-)');
    END IF;

 END inv_actg_amounts;


PROCEDURE other_trx_segment_info(P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                   --           P_ENTITY_ID             IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_ACTG_SOURCE_ID         IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                              P_TRX_CLASS             IN VARCHAR2,
                              j                       IN binary_integer) IS

    CURSOR trx_ccid (c_actg_source_id  number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM  ar_distributions_all dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE dist.line_id  = c_actg_source_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.source_distribution_id_num_1 = dist.line_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
                     AND lnk.application_id = ael.application_id
              AND rownum =1;

   /* CURSOR trx_dist_ccid (c_actg_source_id  number, c_event_id number, c_ae_header_id number) IS
            SELECT  ael.code_combination_id
                    FROM  ar_distributions_all dist,
                          ar_distributions_all taxdist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE taxdist.line_id  = p_actg_source_id
                     AND NVL(dist.source_table,'X') = NVL(taxdist.source_table_secondary,'X')
                     AND dist.tax_link_id = taxdist.tax_link_id
                     AND dist.source_id = taxdist.source_id
                     AND lnk.source_distribution_id_num_1 = dist.line_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
                     AND lnk.application_id = ael.application_id
              AND rownum =1;
    */

    CURSOR trx_dist_ccid_misc (c_trx_line_id  number, c_event_id number, c_ae_header_id number) IS
                  SELECT ael.code_combination_id
                    FROM ar_distributions_all dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE dist.line_id  = c_trx_line_id
                     AND dist.source_table= 'MCD'
                     AND lnk.source_distribution_id_num_1 = dist.line_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
                     AND lnk.application_id = ael.application_id
                     AND rownum =1;

    CURSOR trx_dist_ccid_app (c_trx_line_id  number, c_event_id number, c_ae_header_id number) IS
                  SELECT ael.code_combination_id
                    FROM ar_distributions_all dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE dist.line_id  = c_trx_line_id
                     AND dist.source_table= 'RA'
                     AND lnk.source_distribution_id_num_1 = dist.line_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
                     AND lnk.application_id = ael.application_id
                     AND rownum =1;

    CURSOR trx_dist_ccid_adj (c_trx_line_id  number, c_event_id number, c_ae_header_id number) IS
                  SELECT ael.code_combination_id
                    FROM ar_distributions_all dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE dist.line_id  = c_trx_line_id
                     AND dist.source_table= 'ADJ'
                     AND lnk.source_distribution_id_num_1 = dist.line_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
                     AND lnk.application_id = ael.application_id
                     AND rownum =1;

    CURSOR tax_ccid (c_actg_source_id number, c_event_id number, c_ae_header_id number) IS
            SELECT  ael.code_combination_id
                    FROM  ar_distributions_all dist,
                          ar_distributions_all taxdist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE dist.line_id  = c_actg_source_id
                     AND NVL(dist.source_table,'X') = NVL(taxdist.source_table_secondary,'X')
                     AND dist.tax_link_id = taxdist.tax_link_id
                     AND dist.source_id = taxdist.source_id
                     AND lnk.source_distribution_id_num_1 = taxdist.line_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
                     AND lnk.application_id = ael.application_id
              AND rownum =1;

  CURSOR tax_dist_ccid (c_actg_source_id number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM  ar_distributions_all taxdist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE taxdist.line_id  = c_actg_source_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.source_distribution_id_num_1 = taxdist.line_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
                     AND lnk.application_id = ael.application_id
              AND rownum =1;



  L_BAL_SEG_VAL  VARCHAR2(240);
  L_BAL_SEG_DESC  VARCHAR2(240);
  L_ACCT_SEG_VAL VARCHAR2(240);
  L_SQL_STATEMENT1     VARCHAR2(1000);
 L_SQL_STATEMENT2     VARCHAR2(1000);
 l_ccid number;
 l_tax_dist_ccid number;
 L_TRX_DIST_CCID NUMBER ;
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_segment_info.BEGIN',
                                      'ZX_AR_POPULATE_PKG: other_trx_segment_info(+)');
    END IF;

  GT_TRX_ARAP_BALANCING_SEGMENT(j)    := NULL;
  GT_TRX_ARAP_NATURAL_ACCOUNT(j)      := NULL;
  GT_TRX_TAXABLE_BAL_SEG(j)           := NULL;
  GT_TRX_TAXABLE_BALSEG_DESC(j)       := NULL;
  GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)   := NULL;
  GT_TRX_TAX_BALANCING_SEGMENT(j)     := NULL;
  GT_TRX_TAX_NATURAL_ACCOUNT(j)       := NULL;


  L_BAL_SEG_VAL := '';
  L_BAL_SEG_DESC := '';
  L_ACCT_SEG_VAL := '';

  L_SQL_STATEMENT1 := ' SELECT '||P_BALANCING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';

  L_SQL_STATEMENT2 := ' SELECT '||P_ACCOUNTING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';


  IF P_SUMMARY_LEVEL = 'TRANSACTION' OR P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN

      OPEN trx_ccid (p_actg_source_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_ccid INTO l_ccid;
      EXIT WHEN trx_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(j) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(j)  := GT_TRX_TAXABLE_BAL_SEG(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(j) := GT_TRX_TAXABLE_BAL_SEG(j);
        GT_TRX_ARAP_NATURAL_ACCOUNT(j)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j);
    END LOOP;


      OPEN tax_ccid (p_actg_source_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(j) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(j)  := GT_TRX_TAX_BALANCING_SEGMENT(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(j)  := GT_TRX_TAX_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;
/*
  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN
      OPEN trx_line_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_line_ccid INTO l_ccid;
      EXIT WHEN trx_line_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(j) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(j)  := GT_TRX_TAXABLE_BAL_SEG(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(j) := GT_TRX_TAXABLE_BAL_SEG(j);
        GT_TRX_ARAP_NATURAL_ACCOUNT(j)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j);
    END LOOP;


      OPEN tax_line_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_line_ccid INTO l_ccid;
      EXIT WHEN tax_line_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(j) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(j)  := GT_TRX_TAX_BALANCING_SEGMENT(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(j)  := GT_TRX_TAX_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;
*/

  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_segment_info',
          'TRANSACTION DIST LEVEL : p_trx_id - p_event_id - p_ae_header_id- p_trx_line_id'
          ||to_char(p_trx_id)||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)
          ||'-'||to_char(p_trx_line_id)||'-'||to_char(l_ccid));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_segment_info',
          'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT1);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_segment_info',
          'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT2);
     END IF;

     IF p_event_id IS NOT NULL AND p_ae_header_id IS NOT NULL THEN
        IF  P_TRX_CLASS = 'MISC_CASH_RECEIPT' THEN
            OPEN trx_dist_ccid_misc(p_trx_line_id, p_event_id, p_ae_header_id);
        END IF;
        IF P_TRX_CLASS IN ('APP','EDISC','UNEDISC') THEN
            OPEN trx_dist_ccid_app(p_trx_line_id, p_event_id, p_ae_header_id);
        END IF;
        IF P_TRX_CLASS IN ('ADJ','FINCHRG') THEN
            OPEN trx_dist_ccid_adj(p_trx_line_id, p_event_id, p_ae_header_id);
        END IF;
            LOOP
            IF P_TRX_CLASS = 'MISC_CASH_RECEIPT' THEN
               FETCH trx_dist_ccid_misc INTO l_ccid;
               EXIT WHEN trx_dist_ccid_misc%NOTFOUND;
            END IF;
            IF P_TRX_CLASS IN ('APP','EDISC','UNEDISC') THEN
               FETCH trx_dist_ccid_app INTO l_ccid;
               EXIT WHEN trx_dist_ccid_app%NOTFOUND;
            END IF;
            IF P_TRX_CLASS IN ('ADJ','FINCHRG') THEN
               FETCH trx_dist_ccid_adj INTO l_ccid;
               EXIT WHEN trx_dist_ccid_adj%NOTFOUND;
            END IF;

        l_trx_dist_ccid := l_ccid; --Bug 5510907

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_segment_info',
          'Dist level: l_ccid: L_BAL_SEG_VAL: L_ACCT_SEG_VAL' ||l_ccid
           ||'-'||L_BAL_SEG_VAL||'-'||L_ACCT_SEG_VAL);
        END IF;

        IF L_BAL_SEG_VAL IS NOT NULL THEN
           L_BAL_SEG_DESC :=  FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'GL_BALANCING',
                            P_DATA => L_BAL_SEG_VAL);
        END IF;

        IF GT_TRX_TAXABLE_BAL_SEG(j) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(j) := L_BAL_SEG_VAL;
            GT_TRX_TAXABLE_BALSEG_DESC(j) := L_BAL_SEG_DESC;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(j)  := GT_TRX_TAXABLE_BAL_SEG(j)
                                             ||','||L_BAL_SEG_VAL;
                GT_TRX_TAXABLE_BALSEG_DESC(j) := GT_TRX_TAXABLE_BALSEG_DESC(j) || ',' || L_BAL_SEG_DESC;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(j) := GT_TRX_TAXABLE_BAL_SEG(j);
        GT_TRX_ARAP_NATURAL_ACCOUNT(j)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j);
    END LOOP;
    IF  P_TRX_CLASS = 'MISC_CASH_RECEIPT' THEN
        CLOSE trx_dist_ccid_misc;
    END IF;
    IF  P_TRX_CLASS IN ('APP','EDISC','UNEDISC') THEN
        CLOSE trx_dist_ccid_app;
    END IF;
    IF  P_TRX_CLASS IN ('ADJ','FINCHRG') THEN
        CLOSE trx_dist_ccid_adj;
    END IF;


      OPEN tax_dist_ccid (p_actg_source_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_dist_ccid INTO l_ccid;
      EXIT WHEN tax_dist_ccid%NOTFOUND;
        l_tax_dist_ccid := l_ccid;
        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(j) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(j) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(j)  := GT_TRX_TAX_BALANCING_SEGMENT(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(j)  := GT_TRX_TAX_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

      END LOOP;
   ELSE   -- Adjustments for Tax Reconciliation Report ---

 BEGIN
      SELECT CODE_COMBINATION_ID INTO l_ccid
        FROM AR_DISTRIBUTIONS_ALL
      WHERE LINE_ID = P_ACTG_SOURCE_ID;
          --SOURCE_ID = P_TRX_LINE_ID

       agt_actg_line_ccid(j) := l_ccid;

       l_tax_dist_ccid := l_ccid;
        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_segment_info',
          'Tax Line :  trx id - P_ACTG_SOURCE_ID- ccid :' ||to_char(p_trx_id)
           ||'-'||to_char(P_ACTG_SOURCE_ID)||'-'||to_char(l_ccid)||'-'||L_BAL_SEG_VAL);
    END IF;


        IF L_BAL_SEG_VAL IS NOT NULL THEN
           L_BAL_SEG_DESC :=  FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'GL_BALANCING',
                            P_DATA => L_BAL_SEG_VAL);
        END IF;


        IF GT_TRX_TAX_BALANCING_SEGMENT(j) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(j) := L_BAL_SEG_VAL;
            GT_TRX_TAXABLE_BALSEG_DESC(j) := L_BAL_SEG_DESC;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
              GT_TRX_TAX_BALANCING_SEGMENT(j)  := GT_TRX_TAX_BALANCING_SEGMENT(j)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(j)  := GT_TRX_TAX_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;
      exception
      when no_data_found then
       NULL;
      END;

   /*  IF P_TRX_LINE_ID IS NOT NULL THEN
     BEGIN
     SELECT CODE_COMBINATION_ID INTO l_ccid
        FROM AR_DISTRIBUTIONS_ALL
      WHERE LINE_ID = P_TRX_LINE_ID;
         --SOURCE_ID = P_TRX_ID


         l_trx_dist_ccid := l_ccid; --Bug 5510907

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_segment_info',
          'Taxable line : - trx id - P_ACTG_SOURCE_ID- ccid :' ||to_char(p_trx_id)
           ||'-'||to_char(P_TRX_LINE_ID)||'-'||to_char(l_ccid)||'-'||L_BAL_SEG_VAL);
    END IF;

        IF L_BAL_SEG_VAL IS NOT NULL THEN
           L_BAL_SEG_DESC :=  FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'GL_BALANCING',
                            P_DATA => L_BAL_SEG_VAL);
        END IF;

        IF GT_TRX_TAXABLE_BAL_SEG(j) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(j) := L_BAL_SEG_VAL;
            GT_TRX_TAXABLE_BALSEG_DESC(j) := L_BAL_SEG_DESC;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(j)  := GT_TRX_TAXABLE_BAL_SEG(j)
                                             ||','||L_BAL_SEG_VAL;
                GT_TRX_TAXABLE_BALSEG_DESC(j) := GT_TRX_TAXABLE_BALSEG_DESC(j) || ',' || L_BAL_SEG_DESC;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(j) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(j),L_BAL_SEG_VAL) > 0 THEN
                NULL;
        ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(j) := GT_TRX_TAXABLE_BAL_SEG(j);
        GT_TRX_ARAP_NATURAL_ACCOUNT(j)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(j);
     exception
      when no_data_found then
       NULL;
      END;
      END IF; */
    END IF;

   -- populare accounting_flexfield and accounting_description column ---
   ----------------------------------------------------------------------

       IF l_tax_dist_ccid IS NOT NULL THEN

          GT_ACCOUNT_FLEXFIELD(j) := FA_RX_FLEX_PKG.GET_VALUE(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'ALL',
                            P_CCID => l_tax_dist_ccid);

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.OTHER_TRX_SEGMENT_INFO',
                                      'Account Flexfield = '||GT_ACCOUNT_FLEXFIELD(j));
          END IF;

          GT_ACCOUNT_DESCRIPTION(j) := FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'ALL',
                            P_DATA => GT_ACCOUNT_FLEXFIELD(j));

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.OTHER_TRX_SEGMENT_INFO',
                                      'Account Description = '||GT_ACCOUNT_DESCRIPTION(j));
          END IF;

       END IF;

--Bug 5510907 : To get the accounting Flexfield for the Taxable Line

       IF l_trx_dist_ccid IS NOT NULL THEN

          GT_TRX_CONTROL_ACCFLEXFIELD(j) := FA_RX_FLEX_PKG.GET_VALUE(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => g_coa_id,
                            P_QUALIFIER => 'ALL',
                            P_CCID => l_trx_dist_ccid);

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.other_trx_segment_info',
                                      'other_trx_segment_info : GT_TRX_CONTROL_ACCFLEXFIELD(j) = '||GT_TRX_CONTROL_ACCFLEXFIELD(j));
          END IF;
  END IF ;
      ---- End of accounting flexfield population -----------------------

END IF; -- Summary Level
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_segment_info.END',
                                      'ZX_AR_POPULATE_PKG: other_trx_segment_info(-)');
    END IF;

END other_trx_segment_info;



PROCEDURE other_trx_actg_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                  --               P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_ACTG_SOURCE_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                                 P_LEDGER_ID             IN NUMBER,
                                 j                       IN binary_integer) IS
-- Transaction Header Level
   CURSOR taxable_amount_hdr (c_actg_source_id NUMBER, c_ae_header_id NUMBER,
                               c_event_id NUMBER,c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM ar_distributions_all dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE dist.line_id  = c_actg_source_id
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND lnk.source_distribution_id_num_1 = dist.line_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id;


   CURSOR tax_amount_hdr (c_actg_source_id NUMBER, c_ae_header_id NUMBER,
                            c_event_id NUMBER,c_ledger_id NUMBER) IS
       SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM AR_DISTRIBUTIONS_ALL dist,
              AR_DISTRIBUTIONS_ALL taxdist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE dist.line_id = c_actg_source_id
          AND taxdist.tax_link_id = dist.tax_link_id
          AND NVL(taxdist.source_type_secondary,'X') = NVL(dist.source_type,'X')
          AND taxdist.source_id = dist.source_id
          AND lnk.source_distribution_id_num_1 = taxdist.line_id
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id;


-- Transaction Distribution Level

   CURSOR taxable_amount_dist_misc(c_trx_line_id NUMBER, c_ae_header_id NUMBER, c_event_id NUMBER,c_ledger_id NUMBER) IS
       --SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
       SELECT sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)),
              sum(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0))
         FROM AR_DISTRIBUTIONS_ALL dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE dist.line_id = c_trx_line_id
          AND lnk.source_distribution_id_num_1 = dist.line_id
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id
          and ael.accounting_class_code = 'MISC_CASH';

   CURSOR taxable_amount_dist_app(c_trx_line_id NUMBER, c_ae_header_id NUMBER, c_event_id NUMBER,c_ledger_id NUMBER) IS
       SELECT sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)),
              sum(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0))
         FROM AR_DISTRIBUTIONS_ALL dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE dist.line_id = c_trx_line_id
          AND lnk.source_distribution_id_num_1 = dist.line_id
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id ;
         -- and ael.accounting_class_code = 'EDISC';

   CURSOR taxable_amount_dist_adj(c_trx_line_id NUMBER, c_ae_header_id NUMBER, c_event_id NUMBER,c_ledger_id NUMBER) IS
       SELECT sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)),
              sum(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0))
         FROM AR_DISTRIBUTIONS_ALL dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE dist.line_id = c_trx_line_id
          AND lnk.source_distribution_id_num_1 = dist.line_id
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id
          AND ael.accounting_class_code = 'ADJ';

   CURSOR tax_amount_dist (c_actg_source_id NUMBER, c_ae_header_id NUMBER,
                           c_event_id NUMBER,c_ledger_id NUMBER) IS
        --SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
       SELECT sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)),
              sum(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0))
         FROM ar_distributions_all taxdist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE taxdist.line_id  = c_actg_source_id
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND lnk.source_distribution_id_num_1 = taxdist.line_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id
          AND aeh.ae_header_id   = lnk.ae_header_id
          AND aeh.application_id = lnk.application_id
          AND ael.application_id = aeh.application_id;

BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_actg_amounts.BEGIN',
                                      'ZX_AR_POPULATE_PKG: other_trx_actg_amounts(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_actg_amounts',
          'p_trx_id - p_event_id - p_ae_header_id- p_actg_source_id- p_ledger_id '
          ||to_char(p_trx_id)||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)
          ||'-'||to_char(p_actg_source_id)||'-'||to_char(p_ledger_id));
    END IF;

   IF p_summary_level = 'TRANSACTION' THEN
      OPEN taxable_amount_hdr(p_actg_source_id , p_ae_header_id , p_event_id,p_ledger_id );
      FETCH taxable_amount_hdr INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
       --    EXIT WHEN taxable_amount_hdr%NOTFOUND;
       CLOSE taxable_amount_hdr;

      OPEN tax_amount_hdr(p_actg_source_id , p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_hdr INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
--      EXIT WHEN tax_amount_hdr%NOTFOUND;
     CLOSE tax_amount_hdr;
/*  ELSIF p_summary_level = 'TRANSACTION_LINE' THEN
           OPEN taxable_amount_line(p_trx_id ,p_trx_line_id, p_ae_header_id , p_event_id);
      FETCH taxable_amount_line INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
  --        EXIT WHEN taxable_amount_line%NOTFOUND;
        CLOSE taxable_amount_line;

      OPEN tax_amount_line(p_trx_id , p_trx_line_id, p_ae_header_id , p_event_id);
      FETCH tax_amount_line INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
--      EXIT WHEN tax_amount_line%NOTFOUND;
      CLOSE tax_amount_line;
*/
  ELSIF p_summary_level = 'TRANSACTION_DISTRIBUTION' THEN
      IF P_TRX_CLASS = 'MISC_CASH_RECEIPT' THEN
         OPEN taxable_amount_dist_misc(p_trx_line_id ,p_ae_header_id , p_event_id,p_ledger_id);
         FETCH taxable_amount_dist_misc INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
         CLOSE taxable_amount_dist_misc;
      END IF;
      IF P_TRX_CLASS IN ('APP','EDISC','UNEDISC') THEN
         OPEN taxable_amount_dist_app(p_trx_line_id ,p_ae_header_id , p_event_id,p_ledger_id);
         FETCH taxable_amount_dist_app INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
         CLOSE taxable_amount_dist_app;
      END IF;
      IF P_TRX_CLASS IN ('ADJ','FINCHRG') THEN
         OPEN taxable_amount_dist_adj(p_trx_line_id ,p_ae_header_id , p_event_id,p_ledger_id);
         FETCH taxable_amount_dist_adj INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
         CLOSE taxable_amount_dist_adj;
      END IF;

--         EXIT WHEN taxable_amount_dist%NOTFOUND;
        IF GT_TAXABLE_AMT(j) IS NULL OR GT_TAXABLE_AMT_FUNCL_CURR(j) IS NULL THEN
           IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.other_trx_actg_amounts',
                    'GT_TAXABLE_AMT(j) IS NULL OR GT_TAXABLE_AMT_FUNCL_CURR(j) IS NULL');
           END IF;
        END IF;


      OPEN tax_amount_dist(p_actg_source_id, p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_dist INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
 --     EXIT WHEN tax_amount_dist%NOTFOUND;
     CLOSE tax_amount_dist;
 END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.other_trx_actg_amounts.END',
                                      'ZX_AR_POPULATE_PKG: other_trx_actg_amounts(-)');
    END IF;

 END other_trx_actg_amounts;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   convert_amounts                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure converts tax and taxable amounts into functional amounts|
 |                                                                           |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/


PROCEDURE convert_amounts(P_CURRENCY_CODE        IN VARCHAR2,
                        P_EXCHANGE_RATE         IN NUMBER,
                        P_PRECISION             IN NUMBER,
                        P_MIN_ACCT_UNIT         IN NUMBER,
                        P_INPUT_TAX_AMOUNT      IN NUMBER,
                        P_INPUT_TAXABLE_AMOUNT  IN NUMBER,
                        P_INPUT_EXEMPT_AMOUNT   IN NUMBER,
                        i                       IN BINARY_INTEGER) IS

 l_taxable_amount NUMBER;
 l_TAXABLE_ACCOUNTED_AMOUNT number;
 l_TAX_ACCOUNTED_AMOUNT  number;
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.convert_amounts.BEGIN',
                                      'ZX_AR_POPULATE_PKG: convert_amounts(+)');
    END IF;

    BEGIN
       mo_global.set_policy_context('S',GT_INTERNAL_ORGANIZATION_ID(i));
    EXCEPTION WHEN OTHERS THEN
           g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.convert_amounts-Exception Setting Policy Context ',
                      g_error_buffer);
          END IF;
    END;

/*
        IF P_INPUT_EXEMPT_AMOUNT IS NOT NULL THEN
             P_EXEMPT_ENTERED_AMOUNT := P_INPUT_EXEMPT_AMOUNT;
             P_TAXABLE_EXEMPT_ENTERED_AMT  :=
                     P_INPUT_TAXABLE_AMOUNT + P_INPUT_EXEMPT_AMOUNT;
             l_taxable_amount := P_INPUT_TAXABLE_AMOUNT ;

        ELSE
             P_EXEMPT_ENTERED_AMOUNT := 0;
             P_TAXABLE_EXEMPT_ENTERED_AMT  := P_INPUT_TAXABLE_AMOUNT;
             l_taxable_amount := P_INPUT_TAXABLE_AMOUNT;
        END IF;

        IF P_EXEMPT_ENTERED_AMOUNT IS NOT NULL THEN
                 P_EXEMPT_ACCTD_AMOUNT := arpcurr.FUNCTIONAL_AMOUNT(
                                           P_EXEMPT_ENTERED_AMOUNT,
                                           P_CURRENCY_CODE,
                                           P_EXCHANGE_RATE,
                                           P_PRECISION,
                                           P_MIN_ACCT_UNIT);
        END IF;

        IF P_TAXABLE_EXEMPT_ENTERED_AMT IS NOT NULL THEN
              P_TAXABLE_EXEMPT_ACCTD_AMT := arpcurr.FUNCTIONAL_AMOUNT(
                                           P_TAXABLE_EXEMPT_ENTERED_AMT,
                                           P_CURRENCY_CODE,
                                           P_EXCHANGE_RATE,
                                           P_PRECISION,
                                           P_MIN_ACCT_UNIT);
        END IF;

            P_TAX_ENTERED_AMOUNT := P_INPUT_TAX_AMOUNT;


    P_TAXABLE_AMOUNT := l_taxable_amount;
*/
        IF P_INPUT_TAX_AMOUNT IS NOT NULL THEN
          l_TAX_ACCOUNTED_AMOUNT := arpcurr.FUNCTIONAL_AMOUNT(
                                           P_INPUT_TAX_AMOUNT,
                                           P_CURRENCY_CODE,
                                           P_EXCHANGE_RATE,
                                           P_PRECISION,
                                           P_MIN_ACCT_UNIT);
        END IF;

        IF p_input_taxable_amount IS NOT NULL THEN
          l_TAXABLE_ACCOUNTED_AMOUNT := arpcurr.FUNCTIONAL_AMOUNT(
                                           p_input_taxable_amount,
                                           P_CURRENCY_CODE,
                                           P_EXCHANGE_RATE,
                                           P_PRECISION,
                                           P_MIN_ACCT_UNIT);
        END IF;
         GT_TAX_AMT_FUNCL_CURR(i) := l_TAX_ACCOUNTED_AMOUNT;
         GT_TAXABLE_AMT_FUNCL_CURR(i) := l_TAXABLE_ACCOUNTED_AMOUNT;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.convert_amounts.END',
                                      'ZX_AR_POPULATE_PKG: convert_amounts(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.convert_amounts',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;
END convert_amounts;

PROCEDURE EXTRACT_PARTY_INFO( i IN BINARY_INTEGER) IS

   l_bill_to_party_id          zx_rep_trx_detail_t.BILL_TO_PARTY_ID%TYPE;
   l_bill_to_pty_site_id           zx_rep_trx_detail_t.BILL_TO_PARTY_SITE_ID%TYPE;
   l_bill_to_ptp_id            zx_rep_trx_detail_t.BILL_FROM_PARTY_TAX_PROF_ID%TYPE;
   l_bill_to_stp_id            zx_rep_trx_detail_t.BILL_FROM_SITE_TAX_PROF_ID%TYPE;

   l_ship_to_party_id          zx_rep_trx_detail_t.SHIP_TO_PARTY_ID%TYPE;
   l_ship_to_pty_site_id           zx_rep_trx_detail_t.SHIP_TO_PARTY_SITE_ID%TYPE;
   l_ship_to_ptp_id            zx_rep_trx_detail_t.SHIP_FROM_PARTY_TAX_PROF_ID%TYPE;
   l_ship_to_stp_id            zx_rep_trx_detail_t.SHIP_FROM_SITE_TAX_PROF_ID%TYPE;

      l_bill_to_acct_id          zx_rep_trx_detail_t.BILL_TO_PARTY_ID%TYPE;
   l_bill_to_acct_site_id           zx_rep_trx_detail_t.BILL_TO_PARTY_SITE_ID%TYPE;

   l_ship_to_acct_id          zx_rep_trx_detail_t.SHIP_TO_PARTY_ID%TYPE;
   l_ship_to_acct_site_id           zx_rep_trx_detail_t.SHIP_TO_PARTY_SITE_ID%TYPE;

   l_bill_ship      varchar2(30);

   l_tbl_index_party      BINARY_INTEGER;
   l_tbl_index_bill_site       BINARY_INTEGER;
   l_tbl_index_ship_site       VARCHAR2(50);
   l_tbl_index_cust       BINARY_INTEGER;
--Bug 5622686
        p_parent_ptp_id            zx_party_tax_profile.party_tax_profile_id%TYPE;
        p_site_ptp_id              zx_party_tax_profile.party_tax_profile_id%TYPE;
        p_account_Type_Code        zx_registrations.account_type_code%TYPE;
        p_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE;
        p_tax                      ZX_TAXES_B.TAX%TYPE;
        p_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE;
        p_jurisdiction_code        ZX_JURISDICTIONS_B.TAX_JURISDICTION_CODE%TYPE;
        p_account_id               ZX_REGISTRATIONS.ACCOUNT_ID%TYPE;
        p_account_site_id          ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE;
        p_site_use_id              HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE;
        p_zx_registration_rec     ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC;
        p_ret_record_level       VARCHAR2(100);
        p_return_status          VARCHAR2(100);


CURSOR ledger_cur (c_ledger_id ZX_REP_TRX_DETAIL_T.ledger_id%TYPE) IS
SELECT name
  FROM gl_ledgers
 WHERE ledger_id = c_ledger_id
   AND rownum = 1;

-- If party_id is NOT NULL and Historical flag 'Y' then get the party tax profile ID from zx_party_tax_profile

CURSOR party_reg_num_cur
      (c_party_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_ID%TYPE) IS
SELECT rep_registration_number
  FROM zx_party_tax_profile
 WHERE party_id = c_party_id
   AND party_type_code = 'THIRD_PARTY';

CURSOR party_base_reg_num_cur
      (c_party_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_ID%TYPE) IS
SELECT registration_number
  FROM zx_party_tax_profile ptp,
       zx_registrations reg
 WHERE ptp.party_id = c_party_id
   AND ptp.party_type_code = 'THIRD_PARTY'
   AND reg.party_tax_profile_id = ptp.party_tax_profile_id
ORDER BY default_registration_flag DESC;

CURSOR party_site_reg_cur
       (c_party_site_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_SITE_ID%TYPE) IS
SELECT rep_registration_number
  FROM zx_party_tax_profile
 WHERE party_id = c_party_site_id
   AND party_type_code = 'THIRD_PARTY_SITE';

CURSOR party_site_base_reg_cur
       (c_party_site_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_SITE_ID%TYPE) IS
SELECT registration_number
  FROM zx_party_tax_profile ptp,
       zx_registrations reg
 WHERE ptp.party_id = c_party_site_id
   AND ptp.party_type_code = 'THIRD_PARTY_SITE'
   AND reg.party_tax_profile_id = ptp.party_tax_profile_id
ORDER BY default_registration_flag DESC;

CURSOR party_cur (c_party_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_ID%TYPE) IS
select  SUBSTRB(PARTY.PARTY_NAME,1,240)  ,
        DECODE(PARTY.PARTY_TYPE,
              'ORGANIZATION',
               PARTY.ORGANIZATION_NAME_PHONETIC,
               NULL)                            ,
        DECODE(PARTY.PARTY_TYPE,
              'ORGANIZATION',
               PARTY.SIC_CODE,
               NULL)                            ,
        PARTY.PARTY_NUMBER,
        PARTY.JGZZ_FISCAL_CODE
  FROM HZ_PARTIES    PARTY
  WHERE PARTY.PARTY_ID = c_party_id;

CURSOR party_site_cur ( c_party_site_id  ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_SITE_ID%TYPE) IS
select LOC.CITY,
        LOC.COUNTY,
        LOC.STATE,
        LOC.PROVINCE,
        LOC.ADDRESS1,
        LOC.ADDRESS2,
        LOC.ADDRESS3,
        LOC.ADDRESS_LINES_PHONETIC,
        LOC.COUNTRY,
        LOC.POSTAL_CODE
   FROM HZ_PARTY_SITES                  PARTY_SITE,
        HZ_LOCATIONS                    LOC
  WHERE party_site.party_site_id = c_party_site_id
    AND PARTY_SITE.LOCATION_ID = LOC.LOCATION_ID;

CURSOR cust_acct_cur (c_site_use_id  ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_SITE_ID%TYPE,
                      c_cust_account_id  ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_ID%TYPE,
                      c_ship_bill varchar2) IS
SELECT acct.account_number,
       acct.global_attribute10,
       acct.global_attribute12,
       acct_site.global_attribute8,
       acct_site.global_attribute9,
       site_use.location,
      -- site_use.tax_reference
       acct.party_id,
       acct_site.party_site_id
  FROM hz_cust_accounts acct,
       hz_cust_site_uses_all site_use ,
       hz_cust_acct_sites_all acct_site
 WHERE acct.CUST_ACCOUNT_ID =  acct_site.CUST_ACCOUNT_ID
   and acct_site.CUST_ACCT_SITE_ID = site_use.CUST_ACCT_SITE_ID
   and site_use.site_use_id  = c_site_use_id
  and ACCT.CUST_ACCOUNT_ID   = c_cust_account_id
  and site_use.site_use_code = c_ship_bill;


CURSOR bank_tp_taxpayer_cur (c_bank_account_id ZX_REP_TRX_DETAIL_T.BANK_ACCOUNT_ID%TYPE) IS
SELECT NVL(br_party.jgzz_fiscal_code, ba_party.jgzz_fiscal_code)
  FROM hz_parties br_party,
       hz_parties ba_party,
       ce_bank_branches_v ce_branch,
       ce_bank_accounts ce_accts
 WHERE ce_accts.bank_account_id = c_bank_account_id
   AND ce_accts.bank_branch_id = ce_branch.branch_party_id
   AND ce_branch.branch_party_id = br_party.party_id
   AND ce_branch.bank_party_id = ba_party.party_id;

CURSOR doc_seq_name_cur (c_doc_seq_id ZX_REP_TRX_DETAIL_T.doc_seq_id%TYPE) IS
SELECT name
  FROM fnd_document_sequences
 WHERE doc_sequence_id = c_doc_seq_id;

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO.BEGIN',
                                      'ZX_AR_POPULATE_PKG: EXTRACT_PARTY_INFO(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                                      'gt_historical_flag :' ||gt_historical_flag(i));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                                      'GT_BILL_TO_PARTY_TAX_PROF_ID :' ||to_char(GT_BILL_TO_PARTY_TAX_PROF_ID(i)));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                                      'GT_BILLING_TP_SITE_ID :' ||to_char(GT_BILLING_TP_SITE_ID(i)));
    END IF;


    OPEN ledger_cur(GT_LEDGER_ID(i));
    FETCH ledger_cur into GT_LEDGER_NAME(i);
    CLOSE ledger_cur;


       l_bill_to_acct_site_id := GT_BILLING_TP_SITE_ID(i);
       l_bill_to_acct_id := GT_BILLING_TP_ID(i);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                  'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                  'party_site_id_cur : l_bill_to_site_id '||to_char(l_bill_to_acct_site_id));
      END IF;

       l_bill_ship := 'BILL_TO';


--    IF GT_BILLING_TP_ID(i) IS NOT NULL AND GT_BILLING_TP_ADDRESS_ID(i) IS NOT NULL THEN

     IF l_bill_to_acct_site_id is not null and  l_bill_to_acct_id is not null THEN
        --l_tbl_index_cust  := dbms_utility.get_hash_value(to_char(l_bill_to_acct_site_id)||
         --                                                to_char(l_bill_to_acct_id)|| l_bill_ship, 1,8192);

        l_tbl_index_cust  := to_char(l_bill_to_acct_site_id);
        --|| to_char(l_bill_to_acct_id);
      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
               'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'Before Open cust_acct_cur :'||to_char(l_bill_to_acct_site_id)||'-'||to_char(l_bill_to_acct_id));
      END IF;

        IF g_cust_bill_ar_tbl.EXISTS(l_tbl_index_cust) THEN
           GT_BILLING_TP_NUMBER(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_NUMBER  ;
           GT_GDF_RA_CUST_BILL_ATT10(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT10;
           GT_GDF_RA_CUST_BILL_ATT12(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT12;
           GT_GDF_RA_ADDRESSES_BILL_ATT8(i) :=g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT8;
           GT_GDF_RA_ADDRESSES_BILL_ATT9(i) :=g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT9;
           GT_BILLING_TP_SITE_NAME(i)     := g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_SITE_NAME;
           GT_BILL_TO_PARTY_ID(i)         := g_cust_bill_ar_tbl(l_tbl_index_cust).BILL_TO_PARTY_ID;
           GT_BILL_TO_PARTY_SITE_ID(i)    := g_cust_bill_ar_tbl(l_tbl_index_cust).BILL_TO_PARTY_SITE_ID;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
               'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'If g_cust_bill_ar_tbl.EXISTS :'||GT_BILLING_TP_NUMBER(i));
      END IF;

        ELSE
          OPEN cust_acct_cur (l_bill_to_acct_site_id,
                        l_bill_to_acct_id,
                        l_bill_ship);
          FETCH cust_acct_cur INTO GT_BILLING_TP_NUMBER(i),
                             GT_GDF_RA_CUST_BILL_ATT10(i),
                             GT_GDF_RA_CUST_BILL_ATT12(i),
                             GT_GDF_RA_ADDRESSES_BILL_ATT8(i),
                             GT_GDF_RA_ADDRESSES_BILL_ATT9(i),
                             GT_BILLING_TP_SITE_NAME(i),
                      --       GT_BILLING_SITE_TAX_REG_NUM(i),
                             GT_BILL_TO_PARTY_ID(i),
                             GT_BILL_TO_PARTY_SITE_ID(i);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                   'After fetch of cust_acct_cur'||GT_BILLING_TP_NUMBER(i)||'-'||GT_BILLING_TP_TAX_REG_NUM(i));
      END IF;

           g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_NUMBER := GT_BILLING_TP_NUMBER(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT10 := GT_GDF_RA_CUST_BILL_ATT10(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT12 := GT_GDF_RA_CUST_BILL_ATT12(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT8 := GT_GDF_RA_ADDRESSES_BILL_ATT8(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT9 := GT_GDF_RA_ADDRESSES_BILL_ATT9(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_SITE_NAME := GT_BILLING_TP_SITE_NAME(i);
         --  g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_SITE_TAX_REG_NUM := GT_BILLING_SITE_TAX_REG_NUM(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).BILL_TO_PARTY_ID  := GT_BILL_TO_PARTY_ID(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).BILL_TO_PARTY_SITE_ID  := GT_BILL_TO_PARTY_SITE_ID(i);

             CLOSE cust_acct_cur;
        END IF;
                 l_bill_to_pty_site_id := GT_BILL_TO_PARTY_SITE_ID(i);
                 l_bill_to_party_id := GT_BILL_TO_PARTY_ID(i);

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_cust_bill_ar_tbl ');
        END IF;

       --l_tbl_index_party := dbms_utility.get_hash_value(to_char(l_bill_to_party_id)||
                                                              --  l_bill_ship, 1,8192);
       l_tbl_index_party := to_char(l_bill_to_party_id);

       IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Party : l_tbl_index_party  : '
                        ||to_char(l_tbl_index_party));
        END IF;

       IF g_party_bill_ar_tbl.EXISTS(l_tbl_index_party) THEN
          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Party : exist  : ');
          END IF;

          GT_BILLING_TP_NAME_ALT(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT;
          GT_BILLING_TP_NAME(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME;
          GT_BILLING_TP_SIC_CODE(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE;
          GT_BILLING_TP_NUMBER(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER;
          GT_BILLING_TP_TAXPAYER_ID(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_TAXPAYER_ID;
 --         GT_BILLING_TP_TAX_REG_NUM(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_TAX_REG_NUM;

       ELSE
          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Party : not exist  : '||to_char(l_bill_to_party_id));
          END IF;
          OPEN party_cur (l_bill_to_party_id);
          FETCH party_cur INTO GT_BILLING_TP_NAME(i),
                        GT_BILLING_TP_NAME_ALT(i),
                        GT_BILLING_TP_SIC_CODE(i),
                        GT_BILLING_TP_NUMBER(i),
                  GT_BILLING_TP_TAXPAYER_ID(i);
--  GT_BILLING_TP_TAX_REG_NUM(i);

         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT := GT_BILLING_TP_NAME_ALT(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME := GT_BILLING_TP_NAME(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE := GT_BILLING_TP_SIC_CODE(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER := GT_BILLING_TP_NUMBER(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_TAXPAYER_ID := GT_BILLING_TP_TAXPAYER_ID(i);
  --       g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_TAX_REG_NUM := GT_BILLING_TP_TAX_REG_NUM(i);

       CLOSE party_cur;
       END IF;
       OPEN party_reg_num_cur (l_bill_to_party_id);
       FETCH party_reg_num_cur into GT_BILLING_TP_TAX_REG_NUM(i);
       CLOSE party_reg_num_cur;

       IF GT_BILLING_TP_TAX_REG_NUM(i) IS NULL THEN
          OPEN party_base_reg_num_cur (l_bill_to_party_id);
          FETCH party_base_reg_num_cur into GT_BILLING_TP_TAX_REG_NUM(i);
          CLOSE party_base_reg_num_cur;
       END IF;

       -- Uncommented as Part of 7226438. //Commented as part of Bug 5622686 to include the api call for getting the registratio number
       OPEN party_site_reg_cur(l_bill_to_pty_site_id);
       FETCH party_site_reg_cur INTO GT_BILLING_SITE_TAX_REG_NUM(i);
       CLOSE party_site_reg_cur;

       IF GT_BILLING_SITE_TAX_REG_NUM(i) IS NULL THEN
          OPEN party_site_base_reg_cur(l_bill_to_pty_site_id);
          FETCH party_site_base_reg_cur INTO GT_BILLING_SITE_TAX_REG_NUM(i);
          CLOSE party_site_base_reg_cur;
       END IF;

  IF GT_BILLING_SITE_TAX_REG_NUM(i) IS NULL THEN -- Bug 7226438
  --Bug 5622686
  Begin

       select decode(GT_APPLICATION_ID(i),222,'CUSTOMER',200,'SUPPLIER')
       into p_account_Type_Code
       from dual ;

       p_parent_ptp_id := GT_BILL_TO_PARTY_TAX_PROF_ID(i);
       p_site_ptp_id := GT_BILL_TO_SITE_TAX_PROF_ID(i);
       p_tax_determine_date := gt_tax_determine_date(i);
       p_account_id:= GT_BILLING_TP_ID(i);
       p_account_site_id := GT_BILLING_TP_ADDRESS_ID(i);
       p_site_use_id := GT_BILLING_TP_SITE_ID(i);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'Before call to ZX_TCM_CONTROL_PKG.Get_Tax_Registration api to get the registration number ');
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'trx_id : '||GT_TRX_ID(i));
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_parent_ptp_id : '||p_parent_ptp_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_site_ptp_id : '|| p_site_ptp_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_tax_determine_date : '|| p_tax_determine_date);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_account_id : '|| p_account_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_account_site_id : '|| p_account_site_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_site_use_id : '|| p_site_use_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_account_Type_Code : '|| p_account_Type_Code);
    END IF;

    ZX_TCM_CONTROL_PKG.Get_Tax_Registration(
         p_parent_ptp_id
        , p_site_ptp_id
        , p_account_Type_Code
        , p_tax_determine_date
        , p_tax
        , p_tax_regime_code
        , p_jurisdiction_code
        , p_account_id
        , p_account_site_id
        , p_site_use_id
        , p_zx_registration_rec
        , p_ret_record_level
        , p_return_status );

    if  ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl.exists(p_site_use_id) then
      GT_BILLING_SITE_TAX_REG_NUM(i) := ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_reference;
    else
      GT_BILLING_SITE_TAX_REG_NUM(i) := null ;
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
          'Could not fetch a value for registration number ');
      end if ;
    end if;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
             'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
              'Stauts: '|| p_return_status);
          FND_LOG.STRING(g_level_procedure,
             'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
              'Registration: '||p_zx_registration_rec.registration_number);
          FND_LOG.STRING(g_level_procedure,
             'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
              'Registration from structure : '||GT_BILLING_SITE_TAX_REG_NUM(i));
     END IF ;
  EXCEPTION
  WHEN OTHERS THEN
    NULL ;
  End;
  END IF; -- GT_BILLING_SITE_TAX_REG_NUM IS NULL

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_party_bill_ar_tbl '||g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER);
        END IF;
      -- l_tbl_index_site := dbms_utility.get_hash_value(to_char(l_bill_to_pty_site_id)||
       --                                                         l_bill_ship, 1,8192);

      l_tbl_index_bill_site  := to_char(l_bill_to_pty_site_id);

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Bill : l_tbl_index_bill_site  : '
                        ||to_char(l_tbl_index_bill_site));
        END IF;

       IF g_site_bill_ar_tbl.EXISTS(l_tbl_index_bill_site) THEN

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Bill : exist  : ');
        END IF;
        GT_BILLING_TP_CITY(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_CITY;
        GT_BILLING_TP_COUNTY(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_COUNTY;
        GT_BILLING_TP_STATE(i)  := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_STATE;
        GT_BILLING_TP_PROVINCE(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_PROVINCE;
        GT_BILLING_TP_ADDRESS1(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_ADDRESS1;
        GT_BILLING_TP_ADDRESS2(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_ADDRESS2;
        GT_BILLING_TP_ADDRESS3(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_ADDRESS3;
        GT_BILLING_TP_ADDR_LINES_ALT(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_ADDR_LINES_ALT;
        GT_BILLING_TP_COUNTRY(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_COUNTRY;
        GT_BILLING_TP_POSTAL_CODE(i) := g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_POSTAL_CODE;
     ELSE
        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Bill : not exist  : '||to_char(l_bill_to_pty_site_id));
        END IF;
        OPEN party_site_cur (l_bill_to_pty_site_id);
        FETCH party_site_cur INTO GT_BILLING_TP_CITY(i),
                             GT_BILLING_TP_COUNTY(i),
                             GT_BILLING_TP_STATE(i),
                             GT_BILLING_TP_PROVINCE(i),
                             GT_BILLING_TP_ADDRESS1(i),
                             GT_BILLING_TP_ADDRESS2(i),
                             GT_BILLING_TP_ADDRESS3(i),
                             GT_BILLING_TP_ADDR_LINES_ALT(i),
                             GT_BILLING_TP_COUNTRY(i),
                             GT_BILLING_TP_POSTAL_CODE(i);

       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_CITY := GT_BILLING_TP_CITY(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_COUNTY := GT_BILLING_TP_COUNTY(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_STATE := GT_BILLING_TP_STATE(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_PROVINCE := GT_BILLING_TP_PROVINCE(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_ADDRESS1 := GT_BILLING_TP_ADDRESS1(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_ADDRESS2 := GT_BILLING_TP_ADDRESS2(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_ADDRESS3 := GT_BILLING_TP_ADDRESS3(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_ADDR_LINES_ALT := GT_BILLING_TP_ADDR_LINES_ALT(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_COUNTRY := GT_BILLING_TP_COUNTRY(i);
       g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_POSTAL_CODE := GT_BILLING_TP_POSTAL_CODE(i);
      CLOSE party_site_cur;
      END IF;



       IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                 'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                 'After assign to g_site_bill_ar_tbl '||g_site_bill_ar_tbl(l_tbl_index_bill_site).BILLING_TP_CITY);
        END IF;
    END IF;

         -- Ship to party information ----

       l_ship_to_acct_site_id := GT_SHIPPING_TP_SITE_ID(i);
       l_ship_to_acct_id := GT_SHIPPING_TP_ID(i);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                  'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                  'party_site_id_cur : l_ship_to_site_id '||to_char(l_ship_to_acct_site_id));
      END IF;

       l_bill_ship := 'SHIP_TO';


--    IF GT_SHIPPING_TP_ID(i) IS NOT NULL AND GT_SHIPPING_TP_ADDRESS_ID(i) IS NOT NULL THEN


    IF l_ship_to_acct_site_id is not null and  l_ship_to_acct_id is not null THEN
       --l_tbl_index_cust  := dbms_utility.get_hash_value(to_char(l_ship_to_acct_site_id)||(l_ship_to_acct_id)||
        --                                                        l_bill_ship, 1,8192);

       l_tbl_index_cust  := to_char(l_ship_to_acct_site_id);
       --||(l_ship_to_acct_id);

        IF g_cust_ship_ar_tbl.EXISTS(l_tbl_index_cust) THEN
           GT_SHIPPING_TP_NUMBER(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER  ;
           GT_GDF_RA_CUST_SHIP_ATT10(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT10;
           GT_GDF_RA_CUST_SHIP_ATT12(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT12;
           GT_GDF_RA_ADDRESSES_SHIP_ATT8(i) :=g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT8;
           GT_GDF_RA_ADDRESSES_SHIP_ATT9(i) :=g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT9;
           GT_SHIPPING_TP_SITE_NAME(i)     := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_SITE_NAME;
           GT_SHIP_TO_PARTY_ID(i)         := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIP_TO_PARTY_ID;
           GT_SHIP_TO_PARTY_SITE_ID(i)    := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIP_TO_PARTY_SITE_ID;

--           GT_SHIPPING_SITE_TAX_REG_NUM(i)   := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_SITE_TAX_REG_NUM;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
         'Exists in the cache g_cust_ship_ar_tbl '||g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER);
        END IF;

        ELSE
          OPEN cust_acct_cur (l_ship_to_acct_site_id,
                        l_ship_to_acct_id,
                        l_bill_ship);
          FETCH cust_acct_cur INTO GT_SHIPPING_TP_NUMBER(i),
                             GT_GDF_RA_CUST_SHIP_ATT10(i),
                             GT_GDF_RA_CUST_SHIP_ATT12(i),
                             GT_GDF_RA_ADDRESSES_SHIP_ATT8(i),
                             GT_GDF_RA_ADDRESSES_SHIP_ATT9(i),
                             GT_SHIPPING_TP_SITE_NAME(i),
                             GT_SHIP_TO_PARTY_ID(i),
                             GT_SHIP_TO_PARTY_SITE_ID(i);

           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER := GT_SHIPPING_TP_NUMBER(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT10 := GT_GDF_RA_CUST_SHIP_ATT10(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT12 := GT_GDF_RA_CUST_SHIP_ATT12(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT8 := GT_GDF_RA_ADDRESSES_SHIP_ATT8(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT9 := GT_GDF_RA_ADDRESSES_SHIP_ATT9(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_SITE_NAME := GT_SHIPPING_TP_SITE_NAME(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIP_TO_PARTY_ID  := GT_SHIP_TO_PARTY_ID(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIP_TO_PARTY_SITE_ID  := GT_SHIP_TO_PARTY_SITE_ID(i);

        CLOSE cust_acct_cur;
        END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_cust_ship_ar_tbl '||g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER);
        END IF;

                 l_ship_to_pty_site_id := GT_SHIP_TO_PARTY_SITE_ID(i);
                 l_ship_to_party_id := GT_SHIP_TO_PARTY_ID(i);


       -- l_tbl_index_party  := dbms_utility.get_hash_value(to_char(l_ship_to_party_id)||
                                                               -- l_bill_ship, 1,8192);
       l_tbl_index_party := to_char(l_ship_to_party_id);

       IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Party : l_tbl_index_party  : '
                        ||to_char(l_tbl_index_party));
        END IF;

       IF g_party_ship_ar_tbl.EXISTS(l_tbl_index_party) THEN
          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Party : exist  : ');
          END IF;

          GT_SHIPPING_TP_NAME_ALT(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME_ALT;
          GT_SHIPPING_TP_NAME(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME;
          GT_SHIPPING_TP_SIC_CODE(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_SIC_CODE;
          GT_SHIPPING_TP_NUMBER(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NUMBER;
          GT_SHIPPING_TP_TAXPAYER_ID(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_TAXPAYER_ID;
--          GT_SHIPPING_TP_TAX_REG_NUM(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_TAX_REG_NUM;
       ELSE
          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Party : not exist  : '||to_char(l_ship_to_party_id));
          END IF;
          OPEN party_cur (l_ship_to_party_id);
          FETCH party_cur INTO GT_SHIPPING_TP_NAME(i),
                        GT_SHIPPING_TP_NAME_ALT(i),
                        GT_SHIPPING_TP_SIC_CODE(i),
                        GT_SHIPPING_TP_NUMBER(i),
                  GT_SHIPPING_TP_TAXPAYER_ID(i);

         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME_ALT := GT_SHIPPING_TP_NAME_ALT(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME := GT_SHIPPING_TP_NAME(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_SIC_CODE := GT_SHIPPING_TP_SIC_CODE(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NUMBER := GT_SHIPPING_TP_NUMBER(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_TAXPAYER_ID := GT_SHIPPING_TP_TAXPAYER_ID(i);

       CLOSE party_cur;
       END IF;

       OPEN party_reg_num_cur (l_ship_to_party_id);
       FETCH party_reg_num_cur into GT_SHIPPING_TP_TAX_REG_NUM(i);
       CLOSE party_reg_num_cur;

       IF GT_SHIPPING_TP_TAX_REG_NUM(i) IS NULL THEN
          OPEN party_base_reg_num_cur (l_ship_to_party_id);
          FETCH party_base_reg_num_cur into GT_SHIPPING_TP_TAX_REG_NUM(i);
          CLOSE party_base_reg_num_cur;
       END IF;

       OPEN party_site_reg_cur(l_ship_to_pty_site_id);
       FETCH party_site_reg_cur INTO GT_SHIPPING_SITE_TAX_REG_NUM(i);
       CLOSE party_site_reg_cur;

       IF GT_SHIPPING_SITE_TAX_REG_NUM(i) IS NULL THEN
          OPEN party_site_base_reg_cur(l_ship_to_pty_site_id);
          FETCH party_site_base_reg_cur INTO GT_SHIPPING_SITE_TAX_REG_NUM(i);
          CLOSE party_site_base_reg_cur;
       END IF;

  IF GT_SHIPPING_SITE_TAX_REG_NUM(i) IS NULL THEN -- Bug 7226438
   --Bug 5622686
  Begin

       select decode(GT_APPLICATION_ID(i),222,'CUSTOMER',200,'SUPPLIER')
       into p_account_Type_Code
       from dual ;

       p_parent_ptp_id := GT_SHIP_TO_PARTY_TAX_PROF_ID(i);
       p_site_ptp_id := GT_SHIP_TO_SITE_TAX_PROF_ID(i);
       p_tax_determine_date := gt_tax_determine_date(i);
       p_account_id:= GT_SHIPPING_TP_ID(i);
       p_account_site_id := GT_SHIPPING_TP_ADDRESS_ID(i);
       p_site_use_id := GT_SHIPPING_TP_SITE_ID(i);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
      'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
       'Before call to ZX_TCM_CONTROL_PKG.Get_Tax_Registration api to get the registration number : SHIP_TO');
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'trx_id : '||GT_TRX_ID(i));
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_parent_ptp_id : '||p_parent_ptp_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_site_ptp_id : '|| p_site_ptp_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_tax_determine_date : '|| p_tax_determine_date);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_account_id : '|| p_account_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_account_site_id : '|| p_account_site_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_site_use_id : '|| p_site_use_id);
        FND_LOG.STRING(g_level_procedure,
           'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
            'p_account_Type_Code : '|| p_account_Type_Code);
    END IF;

    ZX_TCM_CONTROL_PKG.Get_Tax_Registration(
         p_parent_ptp_id
        , p_site_ptp_id
        , p_account_Type_Code
        , p_tax_determine_date
        , p_tax
        , p_tax_regime_code
        , p_jurisdiction_code
        , p_account_id
        , p_account_site_id
        , p_site_use_id
        , p_zx_registration_rec
        , p_ret_record_level
        , p_return_status );

  IF  ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl.exists(p_site_use_id) then
      GT_SHIPPING_SITE_TAX_REG_NUM(i) := ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_reference;
  ELSE
      GT_SHIPPING_SITE_TAX_REG_NUM(i) := null ;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
        'Could not fetch a value for registration number ');
      END IF;
       END IF;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
             'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
              'Stauts: '|| p_return_status);
          FND_LOG.STRING(g_level_procedure,
             'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
              'Registration: '||p_zx_registration_rec.registration_number);
          FND_LOG.STRING(g_level_procedure,
             'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
              'Registration from structure : '||GT_SHIPPING_SITE_TAX_REG_NUM(i));
     END IF ;
  EXCEPTION
  WHEN OTHERS THEN
    NULL ;
  END;
  END IF; -- GT_SHIPPING_SITE_TAX_REG_NUM IS NULL

    IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_party_ship_ar_tbl '||g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME);
        END IF;

      --l_tbl_index_site  := dbms_utility.get_hash_value(to_char(l_ship_to_pty_site_id)||
       --                                                         l_bill_ship, 1,8192);
      l_tbl_index_ship_site  := to_char(l_ship_to_pty_site_id);

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Ship : l_tbl_index_ship_site : party site id : acct_site_id : acct_id '
      ||l_tbl_index_ship_site ||'-'||to_char(l_ship_to_pty_site_id)||'-'||to_char(l_ship_to_acct_site_id)||'-'||to_char(l_ship_to_acct_id));
        END IF;
     IF g_site_ship_ar_tbl.EXISTS(l_tbl_index_ship_site) THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Ship : exist  : ');
        END IF;
        GT_SHIPPING_TP_CITY(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_CITY;
        GT_SHIPPING_TP_COUNTY(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_COUNTY;
        GT_SHIPPING_TP_STATE(i)  := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_STATE;
        GT_SHIPPING_TP_PROVINCE(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_PROVINCE;
        GT_SHIPPING_TP_ADDRESS1(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_ADDRESS1;
        GT_SHIPPING_TP_ADDRESS2(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_ADDRESS2;
        GT_SHIPPING_TP_ADDRESS3(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_ADDRESS3;
        GT_SHIPPING_TP_ADDR_LINES_ALT(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_ADDR_LINES_ALT;
        GT_SHIPPING_TP_COUNTRY(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_COUNTRY;
        GT_SHIPPING_TP_POSTAL_CODE(i) := g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_POSTAL_CODE;
     ELSE
        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
            'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO', 'Ship : not exist in Cache : '||to_char(l_ship_to_pty_site_id));
        END IF;
        OPEN party_site_cur (l_ship_to_pty_site_id);
        FETCH party_site_cur INTO GT_SHIPPING_TP_CITY(i),
                             GT_SHIPPING_TP_COUNTY(i),
                             GT_SHIPPING_TP_STATE(i),
                             GT_SHIPPING_TP_PROVINCE(i),
                             GT_SHIPPING_TP_ADDRESS1(i),
                             GT_SHIPPING_TP_ADDRESS2(i),
                             GT_SHIPPING_TP_ADDRESS3(i),
                             GT_SHIPPING_TP_ADDR_LINES_ALT(i),
                             GT_SHIPPING_TP_COUNTRY(i),
                             GT_SHIPPING_TP_POSTAL_CODE(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_CITY := GT_SHIPPING_TP_CITY(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_COUNTY := GT_SHIPPING_TP_COUNTY(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_STATE := GT_SHIPPING_TP_STATE(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_PROVINCE := GT_SHIPPING_TP_PROVINCE(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_ADDRESS1 := GT_SHIPPING_TP_ADDRESS1(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_ADDRESS2 := GT_SHIPPING_TP_ADDRESS2(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_ADDRESS3 := GT_SHIPPING_TP_ADDRESS3(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_ADDR_LINES_ALT := GT_SHIPPING_TP_ADDR_LINES_ALT(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_COUNTRY := GT_SHIPPING_TP_COUNTRY(i);
       g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_POSTAL_CODE := GT_SHIPPING_TP_POSTAL_CODE(i);
      CLOSE party_site_cur;
      END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                   'After assign to g_site_ship_ar_tbl '||g_site_ship_ar_tbl(l_tbl_index_ship_site).SHIPPING_TP_CITY);
        END IF;

    END IF;

    IF GT_TRX_CLASS(i) = 'MISC_CASH_RECEIPT' THEN
       OPEN bank_tp_taxpayer_cur (GT_BANK_ACCOUNT_ID(i));
       FETCH bank_tp_taxpayer_cur INTO GT_BANKING_TP_TAXPAYER_ID(i);
       CLOSE bank_tp_taxpayer_cur;
    END IF;

    IF GT_DOC_SEQ_ID(i) IS NOT NULL THEN
       OPEN doc_seq_name_cur (GT_DOC_SEQ_ID(i));
       FETCH doc_seq_name_cur INTO GT_DOC_SEQ_NAME(i);
       CLOSE doc_seq_name_cur;
    ELSE
       GT_DOC_SEQ_NAME(i) := NULL;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO.END',
                                      'ZX_AR_POPULATE_PKG: EXTRACT_PARTY_INFO(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;


END EXTRACT_PARTY_INFO;

PROCEDURE populate_tax_reg_num(
           P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           P_ORG_ID       IN zx_lines.internal_organization_id%TYPE ,
           P_TAX_DATE     IN zx_lines.tax_date%TYPE,
           i BINARY_INTEGER) IS

CURSOR trn_ptp_id_cur (c_org_id zx_lines.internal_organization_id%TYPE,
                       c_le_id NUMBER,
                       c_tax_date zx_lines.tax_date%TYPE
                       ) IS
SELECT ptp.rep_registration_number
 FROM  xle_tax_associations  rel
      ,zx_party_tax_profile ptp
      ,xle_etb_profiles etb
 WHERE rel.legal_construct_id = etb.establishment_id
 AND   etb.party_id   = ptp.party_id
 AND   ptp.party_type_code = 'LEGAL_ESTABLISHMENT'
 AND   rel.entity_id  =  c_org_id
 AND   rel.legal_parent_id   = c_le_id
--P_TRL_GLOBAL_VARIABLES_REC.legal_entity_id
 AND   rel.LEGAL_CONSTRUCT   = 'ESTABLISHMENT'
 AND   rel.entity_type       = 'OPERATING_UNIT'
 AND   rel.context           =  'TAX_CALCULATION'
 AND   c_tax_date between rel.effective_from and nvl(rel.effective_to,c_tax_date);

BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.populate_tax_reg_num.BEGIN',
                                      'populate_tax_reg_num(+)');
    END IF;
   OPEN trn_ptp_id_cur (p_org_id,
                        P_TRL_GLOBAL_VARIABLES_REC.legal_entity_id,
                        p_tax_date);
   FETCH trn_ptp_id_cur into GT_TAX_REG_NUM(i);
   CLOSE trn_ptp_id_cur;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_tax_reg_num.END',
                                      'populate_tax_reg_num(-)');
    END IF;
END populate_tax_reg_num;

PROCEDURE populate_meaning(
           P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           i BINARY_INTEGER)
IS
   l_description      VARCHAR2(240);
   l_meaning          VARCHAR2(80);

BEGIN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning.BEGIN',
                      'populate_meaning(+) ');
  FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
              'Value of i : '||i);
  FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
              'GT_TRX_ID(i) : '||GT_TRX_ID(i));
     FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
                      'REGISTER_TYPE : '||GT_TAX_RATE_REG_TYPE_CODE(i));
    END IF;


GT_TRX_CLASS_MNG(i) := NULL ;
GT_TAX_RATE_CODE_REG_TYPE_MNG(i) := NULL ;
GT_TAX_EXEMPT_REASON_MNG(i) := NULL ;
GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) := NULL ;
GT_TAX_RATE_VAT_TRX_TYPE_MNG(i) := NULL;
GT_TAX_EXCEPTION_REASON_MNG(i) := NULL ;
GT_TAX_TYPE_MNG(i) := NULL ;

     IF GT_TRX_CLASS(i) IS NOT NULL THEN
        ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_TRL_TAXABLE_TRX_TYPE',
                             GT_TRX_CLASS(i),
                             l_meaning,
                             l_description);
        GT_TRX_CLASS_MNG(i) := l_meaning;
     END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
                      'GT_TRX_CLASS : '||GT_TRX_CLASS(i));
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TRX_CLASS_MNG(i) : '||GT_TRX_CLASS_MNG(i));
    END IF;

     IF  P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE IS NOT NULL THEN
         ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_TRL_REGISTER_TYPE',
                             -- P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE,
                             GT_TAX_RATE_REG_TYPE_CODE(i),
                             l_meaning,
                             l_description);

         GT_TAX_RATE_CODE_REG_TYPE_MNG(i) := l_meaning;
     END IF;

     IF  GT_TAX_RATE_VAT_TRX_TYPE_CODE(i) IS NOT NULL THEN
         ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_JEBE_VAT_TRANS_TYPE',
                              GT_TAX_RATE_VAT_TRX_TYPE_CODE(i),
                             l_meaning,
                             l_description);
         GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) := l_description;
         GT_TAX_RATE_VAT_TRX_TYPE_MNG(i) := l_meaning;
     END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_RATE_CODE_REG_TYPE_MNG(i) : '||GT_TAX_RATE_CODE_REG_TYPE_MNG(i));
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_RATE_VAT_TRX_TYPE_CODE(i) : '||GT_TAX_RATE_VAT_TRX_TYPE_CODE(i));
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) : '||GT_TAX_RATE_VAT_TRX_TYPE_DESC(i));
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_RATE_VAT_TRX_TYPE_MNG(i) : '||GT_TAX_RATE_VAT_TRX_TYPE_MNG(i));
    END IF;

   IF GT_TAX_EXCEPTION_REASON_CODE(i) IS NOT NULL THEN
       ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_EXCEPTION_REASON',
                              GT_TAX_EXCEPTION_REASON_CODE(i),
                             l_meaning,
                             l_description);

        GT_TAX_EXCEPTION_REASON_MNG(i) := l_meaning;
     END IF;


    IF (g_level_unexpected >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_EXCEPTION_REASON_CODE(i) : '||GT_TAX_EXCEPTION_REASON_CODE(i));
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_EXCEPTION_REASON_MNG(i) : '||GT_TAX_EXCEPTION_REASON_MNG(i));
    END IF;

     IF GT_EXEMPT_REASON_CODE(i) IS NOT NULL THEN
        ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_EXEMPTION_REASON',
                              GT_EXEMPT_REASON_CODE(i),
                             l_meaning,
                             l_description);
        GT_TAX_EXEMPT_REASON_MNG(i) := l_meaning;
     END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
                      'GT_EXEMPT_REASON_CODE : '||GT_EXEMPT_REASON_CODE(i));
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_EXEMPT_REASON_MNG(i) : '||GT_TAX_EXEMPT_REASON_MNG(i));
    END IF;

     --Bug 5671767 :Code added to populate tax_type_mng
     IF GT_TAX_TYPE_CODE(i) IS NOT NULL THEN
  BEGIN
    SELECT meaning , description
    INTO l_meaning, l_description
    FROM ar_lookups
    WHERE lookup_code = GT_TAX_TYPE_CODE(i)
    AND lookup_type = 'TAX_TYPE' ;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_TAX_TYPE_CATEGORY',
             GT_TAX_TYPE_CODE(i),
             l_meaning,
             l_description);
  END ;
        GT_TAX_TYPE_MNG(i) := l_meaning;
     END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_TYPE_CODE(i) : '||GT_TAX_TYPE_CODE(i));
     FND_LOG.STRING(g_level_unexpected,
         'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
          'GT_TAX_TYPE_MNG(i) : '||GT_TAX_TYPE_MNG(i));
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning.END',
                      'populate_meaning(-) ');
    END IF;

END populate_meaning;


PROCEDURE get_tax_rate_info_dist_adj(i IN BINARY_INTEGER)

IS
    CURSOR tax_rate_name_cur (c_tax_rate_id ZX_REP_TRX_DETAIL_T.tax_rate_id%TYPE) IS
    SELECT tax_rate_code,tax_rate_name
      FROM zx_rates_vl
     WHERE tax_rate_id = c_tax_rate_id;

BEGIN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning.BEGIN',
                          'get_tax_rate_info_dist_adj(+) ');
          FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
                          'Value of i : '||i);
          FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
                          'GT_TRX_ID(i) : '||GT_TRX_ID(i));
          FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
                          'GT_TAX_RATE_ID(i) : '||GT_TAX_RATE_ID(i));
    END IF;

    OPEN tax_rate_name_cur (GT_TAX_RATE_ID(i));
    FETCH tax_rate_name_cur INTO GT_TAX_RATE_CODE(i), GT_TAX_RATE_CODE_NAME(i);
    CLOSE tax_rate_name_cur;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
                                'GT_TAX_RATE_CODE(i) : '||GT_TAX_RATE_CODE(i));
          FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_AR_POPULATE_PKG.populate_meaning',
                                'GT_TAX_RATE_CODE_NAME(i) : '||GT_TAX_RATE_CODE_NAME(i));
    END IF;
END get_tax_rate_info_dist_adj;


PROCEDURE UPDATE_REP_DETAIL_T(p_count IN NUMBER) IS
i number;
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_REP_DETAIL_T.BEGIN',
                                      'ZX_AR_POPULATE_PKG: UPDATE_REP_DETAIL_T(+)');
    END IF;

FORALL i in 1..p_count
UPDATE /*+ INDEX (ZX_REP_TRX_DETAIL_T ZX_REP_TRX_DETAIL_T_U1)*/
   ZX_REP_TRX_DETAIL_T SET
      REP_CONTEXT_ID                =      G_REP_CONTEXT_ID,
      BILLING_TP_NUMBER             =      GT_BILLING_TP_NUMBER(i),
      BILLING_TP_TAX_REG_NUM        =      GT_BILLING_TP_TAX_REG_NUM(i),
      BILLING_TP_SITE_TAX_REG_NUM   =      GT_BILLING_SITE_TAX_REG_NUM(i),
      BILLING_TP_TAXPAYER_ID        =      GT_BILLING_TP_TAXPAYER_ID(i),
      BILLING_TP_SITE_NAME_ALT      =      GT_BILLING_TP_SITE_NAME_ALT(i),
      BILLING_TP_NAME               =      GT_BILLING_TP_NAME(i),
      BILLING_TP_NAME_ALT           =      GT_BILLING_TP_NAME_ALT(i),
      BILLING_TP_SIC_CODE           =      GT_BILLING_TP_SIC_CODE(i),
      HQ_ESTB_REG_NUMBER            =      GT_TAX_REG_NUM(i),
      BILLING_TP_CITY               =      GT_BILLING_TP_CITY(i),
      BILLING_TP_COUNTY             =      GT_BILLING_TP_COUNTY(i),
      BILLING_TP_STATE              =      GT_BILLING_TP_STATE(i),
      BILLING_TP_PROVINCE           =      GT_BILLING_TP_PROVINCE(i),
      BILLING_TP_ADDRESS1           =      GT_BILLING_TP_ADDRESS1(i),
      BILLING_TP_ADDRESS2           =      GT_BILLING_TP_ADDRESS2(i),
      BILLING_TP_ADDRESS3           =      GT_BILLING_TP_ADDRESS3(i),
      BILLING_TP_ADDRESS_LINES_ALT  =      GT_BILLING_TP_ADDR_LINES_ALT(i),
      BILLING_TP_COUNTRY            =      GT_BILLING_TP_COUNTRY(i),
      BILLING_TP_POSTAL_CODE        =      GT_BILLING_TP_POSTAL_CODE(i),
      BILLING_TP_PARTY_NUMBER       =      GT_BILLING_TP_PARTY_NUMBER(i),
      BILLING_TRADING_PARTNER_ID    =      GT_BILLING_TP_ID(i),
      BILLING_TP_SITE_ID            =      GT_BILLING_TP_SITE_ID(i),
      BILLING_TP_ADDRESS_ID         =      GT_BILLING_TP_ADDRESS_ID(i),
--      BILLING_TP_TAX_REP_FLAG =      GT_BILLING_TP_TAX_REP_FLAG(i),
      BILLING_TP_SITE_NAME          =      GT_BILLING_TP_SITE_NAME(i),
      GDF_RA_ADDRESSES_BILL_ATT9    =      GT_GDF_RA_ADDRESSES_BILL_ATT9(i),
      GDF_PARTY_SITES_BILL_ATT8     =      GT_GDF_PARTY_SITES_BILL_ATT8(i),
      GDF_RA_CUST_BILL_ATT10        =      GT_GDF_RA_CUST_BILL_ATT10(i),
      GDF_RA_CUST_BILL_ATT12        =      GT_GDF_RA_CUST_BILL_ATT12(i),
      GDF_RA_ADDRESSES_BILL_ATT8    =      GT_GDF_RA_ADDRESSES_BILL_ATT8(i),
      SHIPPING_TP_NUMBER            =      GT_SHIPPING_TP_NUMBER(i),
      DOC_SEQ_NAME                  =      GT_DOC_SEQ_NAME(i),
      SHIPPING_TP_TAX_REG_NUM       =      GT_SHIPPING_TP_TAX_REG_NUM(i),
      SHIPPING_TP_SITE_TAX_REG_NUM  =      GT_SHIPPING_SITE_TAX_REG_NUM(i),
      SHIPPING_TP_TAXPAYER_ID       =      GT_SHIPPING_TP_TAXPAYER_ID(i),
--      SHIPPING_TP_SITE_NAME_ALT   =      GT_SHIPPING_TP_SITE_NAME_ALT(i),
      SHIPPING_TP_NAME              =      GT_SHIPPING_TP_NAME(i),
      SHIPPING_TP_NAME_ALT          =      GT_SHIPPING_TP_NAME_ALT(i),
      SHIPPING_TP_SIC_CODE          =      GT_SHIPPING_TP_SIC_CODE(i),
      SHIPPING_TP_CITY              =      GT_SHIPPING_TP_CITY(i),
      SHIPPING_TP_COUNTY            =      GT_SHIPPING_TP_COUNTY(i),
      SHIPPING_TP_STATE             =      GT_SHIPPING_TP_STATE(i),
      SHIPPING_TP_PROVINCE          =      GT_SHIPPING_TP_PROVINCE(i),
      SHIPPING_TP_ADDRESS1          =      GT_SHIPPING_TP_ADDRESS1(i),
      SHIPPING_TP_ADDRESS2          =      GT_SHIPPING_TP_ADDRESS2(i),
      SHIPPING_TP_ADDRESS3          =      GT_SHIPPING_TP_ADDRESS3(i),
--      SHIPPING_TP_ADDR_LINES_ALT  =      GT_SHIPPING_TP_ADDR_LINES_ALT(i),
      SHIPPING_TP_COUNTRY           =      GT_SHIPPING_TP_COUNTRY(i),
      SHIPPING_TP_POSTAL_CODE       =      GT_SHIPPING_TP_POSTAL_CODE(i),
--      SHIPPING_TP_PARTY_NUMBER    =      GT_SHIPPING_TP_PARTY_NUMBER(i),
  --    SHIPPING_TRADING_PARTNER_ID =      GT_SHIPPING_TRADING_PARTNER_ID(i),
      SHIPPING_TP_SITE_ID           =      GT_SHIPPING_TP_SITE_ID(i),
      SHIPPING_TP_ADDRESS_ID        =      GT_SHIPPING_TP_ADDRESS_ID(i),
   --   SHIPPING_TP_TAX_REP_FLAG      =      GT_SHIPPING_TP_TAX_REP_FLAG(i),
      SHIPPING_TP_SITE_NAME         =      GT_SHIPPING_TP_SITE_NAME(i),
      GDF_RA_ADDRESSES_SHIP_ATT9    =      GT_GDF_RA_ADDRESSES_SHIP_ATT9(i),
      GDF_PARTY_SITES_SHIP_ATT8     =      GT_GDF_PARTY_SITES_SHIP_ATT8(i),
      GDF_RA_CUST_SHIP_ATT10        =      GT_GDF_RA_CUST_SHIP_ATT10(i),
      GDF_RA_CUST_SHIP_ATT12        =      GT_GDF_RA_CUST_SHIP_ATT12(i),
      GDF_RA_ADDRESSES_SHIP_ATT8    =      GT_GDF_RA_ADDRESSES_SHIP_ATT8(i),
      TRX_CLASS_MNG                 =      GT_TRX_CLASS_MNG(i),
      TAX_RATE_CODE_REG_TYPE_MNG    =      GT_TAX_RATE_CODE_REG_TYPE_MNG(i),
      TAX_RATE_VAT_TRX_TYPE_DESC    =      GT_TAX_RATE_VAT_TRX_TYPE_DESC(i),
      TAX_RATE_CODE_VAT_TRX_TYPE_MNG =     GT_TAX_RATE_VAT_TRX_TYPE_MNG(i),
      FUNCTIONAL_CURRENCY_CODE      =      G_FUN_CURRENCY_CODE,
      LEDGER_NAME                   =      GT_LEDGER_NAME(i),
      BANKING_TP_TAXPAYER_ID        =      GT_BANKING_TP_TAXPAYER_ID(i),
      TAX_AMT                       =      GT_TAX_AMT(i),
      TAX_AMT_FUNCL_CURR            =      GT_TAX_AMT_FUNCL_CURR(i),
      TAXABLE_AMT                   =      GT_TAXABLE_AMT(i),
      TAXABLE_AMT_FUNCL_CURR        =      GT_TAXABLE_AMT_FUNCL_CURR(i),
      TAX_TYPE_MNG                  =      GT_TAX_TYPE_MNG(i),
      TAX_RATE_CODE                 =      nvl(GT_TAX_RATE_CODE(i), TAX_RATE_CODE),
      TAX_RATE_CODE_NAME            =      nvl(GT_TAX_RATE_CODE_NAME(i), TAX_RATE_CODE_NAME)
   WHERE DETAIL_TAX_LINE_ID = GT_DETAIL_TAX_LINE_ID(i);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_REP_DETAIL_T.END',
                                      'ZX_AR_POPULATE_PKG: UPDATE_REP_DETAIL_T(-)');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.UPDATE_REP_DETAIL_T',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;

END UPDATE_REP_DETAIL_T;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |   insert_actg_info                                                         |
 | DESCRIPTION                                                               |
 |    This procedure inserts payables tax data into ZX_REP_TRX_DETAIL_T table|
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |       11-Jan-2005    Srinivasa Rao Korrapati      Created                 |
 |                                                                           |
 +===========================================================================*/


PROCEDURE insert_actg_info(
           P_COUNT IN BINARY_INTEGER)
IS
    l_count     NUMBER;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.insert_actg_info.BEGIN',
                                      'ZX_AR_ACTG_EXTRACT_PKG: insert_actg_info(+)');
    END IF;

    l_count  := P_COUNT;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.insert_actg_info',
                                      ' Record Count = ' ||to_char(P_COUNT));
    END IF;


    FORALL i IN 1 .. l_count
    INSERT INTO ZX_REP_ACTG_EXT_T(
        actg_ext_line_id,
        detail_tax_line_id,
        actg_event_type_code,
        actg_event_number,
        actg_event_status_flag,
        actg_category_code,
        accounting_date,
        gl_transfer_flag,
      --  gl_transfer_run_id,
        actg_header_description,
        actg_line_num,
        actg_line_type_code,
        actg_line_description,
        actg_stat_amt,
        actg_error_code,
        gl_transfer_code,
        actg_doc_sequence_id,
        --actg_doc_sequence_name,
        actg_doc_sequence_value,
        actg_party_id,
        actg_party_site_id,
        actg_party_type,
        actg_event_id,
        actg_header_id,
        actg_source_id,
        --actg_source_table,
        actg_line_ccid,
        period_name,
        TRX_ARAP_BALANCING_SEGMENT,
        TRX_ARAP_NATURAL_ACCOUNT,
        TRX_TAXABLE_BALANCING_SEGMENT,
        TRX_TAXABLE_BALSEG_DESC,
        TRX_TAXABLE_NATURAL_ACCOUNT,
        TRX_TAX_BALANCING_SEGMENT,
        TRX_TAX_NATURAL_ACCOUNT,
        ACCOUNT_FLEXFIELD,
        ACCOUNT_DESCRIPTION,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        program_application_id,
        program_id,
        program_login_id,
        request_id,
  TRX_CONTROL_ACCOUNT_FLEXFIELD) --Bug 5510907
VALUES (zx_rep_actg_ext_t_s.nextval,
        agt_detail_tax_line_id(i),
        agt_actg_event_type_code(i),
        agt_actg_event_number(i),
        agt_actg_event_status_flag(i),
        agt_actg_category_code(i),
        agt_accounting_date(i),
        agt_gl_transfer_flag(i),
     --   agt_gl_transfer_run_id(i),
        agt_actg_header_description(i),
        agt_actg_line_num(i),
        agt_actg_line_type_code(i),
        agt_actg_line_description(i),
        agt_actg_stat_amt(i),
        agt_actg_error_code(i),
        agt_gl_transfer_code(i),
        agt_actg_doc_sequence_id(i),
      --  agt_actg_doc_sequence_name(i),
        agt_actg_doc_sequence_value(i),
        agt_actg_party_id(i),
        agt_actg_party_site_id(i),
        agt_actg_party_type(i),
        agt_actg_event_id(i),
        agt_actg_header_id(i),
        agt_actg_source_id(i),
       -- agt_actg_source_table(i),
        agt_actg_line_ccid(i),
        agt_period_name(i),
        GT_TRX_ARAP_BALANCING_SEGMENT(i),
        GT_TRX_ARAP_NATURAL_ACCOUNT(i),
        GT_TRX_TAXABLE_BAL_SEG(i),
        GT_TRX_TAXABLE_BALSEG_DESC(i),
        GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),
        GT_TRX_TAX_BALANCING_SEGMENT(i),
        GT_TRX_TAX_NATURAL_ACCOUNT(i),
        GT_ACCOUNT_FLEXFIELD(i),
        GT_ACCOUNT_DESCRIPTION(i),
        g_created_by,
        g_creation_date,
        g_last_updated_by,
        g_last_update_date,
        g_last_update_login,
        g_program_application_id,
        g_program_id,
        g_program_login_id,
        g_request_id,
  GT_TRX_CONTROL_ACCFLEXFIELD(i)); --Bug 5510907

     IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.insert_actg_info',
                      'Number of Tax Lines successfully inserted = '||TO_CHAR(l_count));

        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.insert_actg_info.END',
                                      'ZX_AR_ACTG_EXTRACT_PKG: INIT_GT_VARIABLES(-)');
     END IF;

EXCEPTION
   WHEN OTHERS THEN
        g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
        FND_MSG_PUB.Add;
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.TRL.ZX_AR_POPULATE_PKG.insert_actg_info',
                           g_error_buffer);
        END IF;

         g_retcode := 2;

END insert_actg_info;

PROCEDURE initialize_variables (
          p_count   IN         NUMBER) IS
i number;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.initialize_variables.BEGIN',
                                      'ZX_AR_POPULATE_PKG: initialize_variables(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.initialize_variables',
                                      'p_count : '||to_char(p_count));
    END IF;

  FOR i IN 1.. p_count LOOP
      GT_BILLING_TP_NUMBER(i)          := NULL;
      GT_BILLING_TP_TAX_REG_NUM(i)     := NULL;
      GT_BILLING_TP_TAXPAYER_ID(i)     := NULL;
      GT_BILLING_TP_SITE_NAME_ALT(i)   := NULL;
      GT_BILLING_TP_NAME(i)          := NULL;
      GT_BILLING_TP_NAME_ALT(i)        := NULL;
      GT_BILLING_TP_SIC_CODE(i)        := NULL;
      GT_TAX_REG_NUM(i)                := NULL;
      GT_BILLING_TP_CITY(i)          := NULL;
      GT_BILLING_TP_COUNTY(i)          := NULL;
      GT_BILLING_TP_STATE(i)          := NULL;
      GT_BILLING_TP_PROVINCE(i)        := NULL;
      GT_BILLING_TP_ADDRESS1(i)        := NULL;
      GT_BILLING_TP_ADDRESS2(i)        := NULL;
      GT_BILLING_TP_ADDRESS3(i)        := NULL;
      GT_BILLING_TP_ADDR_LINES_ALT(i)  := NULL;
      GT_BILLING_TP_COUNTRY(i)         := NULL;
      GT_BILLING_TP_POSTAL_CODE(i)     := NULL;
      GT_BILLING_TP_PARTY_NUMBER(i)    := NULL;
    --  GT_BILLING_TP_ID(i)          := NULL;
     -- GT_BILLING_TP_SITE_ID(i)       := NULL;
     -- GT_BILLING_TP_ADDRESS_ID(i)    := NULL;
--    GT_BILLING_TP_TAX_REP_FLAG(i)    := NULL;
      GT_BILLING_TP_SITE_NAME(i)       := NULL;
      GT_GDF_RA_ADDRESSES_BILL_ATT9(i) := NULL;
      GT_GDF_PARTY_SITES_BILL_ATT8(i)  := NULL;
      GT_GDF_RA_CUST_BILL_ATT10(i)     := NULL;
      GT_GDF_RA_CUST_BILL_ATT12(i)     := NULL;
      GT_GDF_RA_ADDRESSES_BILL_ATT8(i) := NULL;
      GT_SHIPPING_TP_NUMBER(i)         := NULL;
      GT_DOC_SEQ_NAME(i)               := NULL;
      GT_SHIPPING_TP_TAX_REG_NUM(i)    := NULL;
      GT_SHIPPING_TP_TAXPAYER_ID(i)    := NULL;
--    GT_SHIPPING_TP_SITE_NAME_ALT(i)  := NULL;
      GT_SHIPPING_TP_NAME(i)          := NULL;
      GT_SHIPPING_TP_NAME_ALT(i)       := NULL;
      GT_SHIPPING_TP_SIC_CODE(i)       := NULL;
      GT_SHIPPING_TP_CITY(i)          := NULL;
      GT_SHIPPING_TP_COUNTY(i)         := NULL;
      GT_SHIPPING_TP_STATE(i)          := NULL;
      GT_SHIPPING_TP_PROVINCE(i)       := NULL;
      GT_SHIPPING_TP_ADDRESS1(i)       := NULL;
      GT_SHIPPING_TP_ADDRESS2(i)       := NULL;
      GT_SHIPPING_TP_ADDRESS3(i)       := NULL;
--    GT_SHIPPING_TP_ADDR_LINES_ALT(i) := NULL;
      GT_SHIPPING_TP_COUNTRY(i)        := NULL;
      GT_SHIPPING_TP_POSTAL_CODE(i)    := NULL;
--    GT_SHIPPING_TP_PARTY_NUMBER(i)   := NULL;
  --  GT_SHIPPING_TRADING_PARTNER_ID(i):= NULL;
    --  GT_SHIPPING_TP_SITE_ID(i)      := NULL;
   --   GT_SHIPPING_TP_ADDRESS_ID(i)   := NULL;
   -- GT_SHIPPING_TP_TAX_REP_FLAG(i)   := NULL;
      GT_SHIPPING_TP_SITE_NAME(i)      := NULL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT9(i) := NULL;
      GT_GDF_PARTY_SITES_SHIP_ATT8(i)  := NULL;
      GT_GDF_RA_CUST_SHIP_ATT10(i)     := NULL;
      GT_GDF_RA_CUST_SHIP_ATT12(i)     := NULL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT8(i) := NULL;
      GT_TRX_CLASS_MNG(i)              := NULL;
      GT_LEDGER_NAME(i)                := NULL;
      GT_BANKING_TP_TAXPAYER_ID(i)     := NULL;
      GT_TAX_RATE_CODE_REG_TYPE_MNG(i) := NULL;
      GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) := NULL;
      GT_TAX_RATE_VAT_TRX_TYPE_MNG(i)  := NULL;
-- New --
      GT_BILLING_TP_NUMBER(i)           := NULL;
      GT_GDF_RA_CUST_BILL_ATT10(i)      := NULL;
      GT_GDF_RA_CUST_BILL_ATT12(i)      := NULL;
      GT_GDF_RA_ADDRESSES_BILL_ATT8(i)  := NULL;
      GT_GDF_RA_ADDRESSES_BILL_ATT9(i)  := NULL;
      GT_BILLING_TP_SITE_NAME(i)        := NULL;
      GT_BILLING_TP_TAX_REG_NUM(i)      := NULL;
      GT_BILLING_SITE_TAX_REG_NUM(i)      := NULL;
      GT_BILLING_TP_NAME(i)             := NULL;
      GT_BILLING_TP_NAME_ALT(i)         := NULL;
      GT_BILLING_TP_SIC_CODE(i)         := NULL;
      GT_BILLING_TP_NUMBER(i)           := NULL;
      GT_BILLING_TP_CITY(i)             := NULL;
      GT_BILLING_TP_COUNTY(i)           := NULL;
      GT_BILLING_TP_STATE(i)            := NULL;
      GT_BILLING_TP_PROVINCE(i)         := NULL;
      GT_BILLING_TP_ADDRESS1(i)         := NULL;
      GT_BILLING_TP_ADDRESS2(i)         := NULL;
      GT_BILLING_TP_ADDRESS3(i)         := NULL;
      GT_BILLING_TP_ADDR_LINES_ALT(i)   := NULL;
      GT_BILLING_TP_COUNTRY(i)          := NULL;
      GT_BILLING_TP_POSTAL_CODE(i)       := NULL;
      GT_SHIPPING_TP_NUMBER(i)           := NULL;
      GT_GDF_RA_CUST_SHIP_ATT10(i)         := NULL;
      GT_GDF_RA_CUST_SHIP_ATT12(i)       := NULL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT8(i)   := NULL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT9(i)    := NULL;
      GT_SHIPPING_TP_SITE_NAME(i)         := NULL;
      GT_SHIPPING_TP_TAX_REG_NUM(i)      := NULL;
      GT_SHIPPING_SITE_TAX_REG_NUM(i)      := NULL;
      GT_SHIPPING_TP_NAME(i)             := NULL;
      GT_SHIPPING_TP_NAME_ALT(i)         := NULL;
      GT_SHIPPING_TP_SIC_CODE(i)         := NULL;
      GT_SHIPPING_TP_NUMBER(i)           := NULL;
      GT_SHIPPING_TP_CITY(i)             := NULL;
      GT_SHIPPING_TP_COUNTY(i)           := NULL;
      GT_SHIPPING_TP_STATE(i)            := NULL;
      GT_SHIPPING_TP_PROVINCE(i)         := NULL;
      GT_SHIPPING_TP_ADDRESS1(i)         := NULL;
      GT_SHIPPING_TP_ADDRESS2(i)         := NULL;
      GT_SHIPPING_TP_ADDRESS3(i)         := NULL;
      GT_SHIPPING_TP_ADDR_LINES_ALT(i)  := NULL;
      GT_SHIPPING_TP_COUNTRY(i)         := NULL;
      GT_SHIPPING_TP_POSTAL_CODE(i)         := NULL;
        gt_actg_ext_line_id(i)         := NULL;
--        gt_detail_tax_line_id(i)     := NULL;
/*        gt_actg_event_type_code(i)     := NULL;
        gt_actg_event_number(i)        := NULL;
        gt_actg_event_status_flag(i)   := NULL;
        gt_actg_category_code(i)       := NULL;
        gt_accounting_date(i)          := NULL;
        gt_gl_transfer_flag(i)         := NULL;
        gt_gl_transfer_run_id(i)       := NULL;
        gt_actg_header_description(i)  := NULL;
        gt_actg_line_num(i)            := NULL;
        gt_actg_line_type_code(i)      := NULL;
        gt_actg_line_description(i)    := NULL;
        gt_actg_stat_amt(i)            := NULL;
        gt_actg_error_code(i)          := NULL;
        gt_gl_transfer_code(i)         := NULL;
        gt_actg_doc_sequence_id(i)     := NULL;
        gt_actg_doc_sequence_name(i)   := NULL;
        gt_actg_doc_sequence_value(i)  := NULL;
        gt_actg_party_id(i)            := NULL;
        gt_actg_party_site_id(i)       := NULL;
        gt_actg_party_type(i)          := NULL;
        gt_actg_event_id(i)            := NULL;
        gt_actg_header_id(i)           := NULL;
        gt_actg_source_id(i)           := NULL;
        gt_actg_source_table(i)        := NULL;
        gt_actg_line_ccid(i)           := NULL;
        gt_period_name(i)              := NULL;
*/
        GT_TRX_ARAP_BALANCING_SEGMENT(i)    := NULL;
       GT_TRX_ARAP_NATURAL_ACCOUNT(i)    := NULL;
      GT_TRX_TAXABLE_BAL_SEG(i)    := NULL;
      GT_TRX_TAXABLE_BALSEG_DESC(i):= NULL;
       GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)    := NULL;
       GT_TRX_TAX_BALANCING_SEGMENT(i)    := NULL;
       GT_TRX_TAX_NATURAL_ACCOUNT(i)    := NULL;
    GT_ACCOUNT_FLEXFIELD(i)   :=  NULL;
    GT_ACCOUNT_DESCRIPTION(i)    := NULL;
     GT_TRX_CONTROL_ACCFLEXFIELD(i) := NULL;
    -- Populate WHO columns --
     GT_TAX_RATE_CODE(i) := NULL ;
     GT_TAX_RATE_CODE_NAME(i) := NULL ;


   END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_POPULATE_PKG.initialize_variables.END',
                                      'ZX_AR_POPULATE_PKG: initialize_variables(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.initialize_variables',
                      g_error_buffer);
    END IF;

END initialize_variables ;

END ZX_AR_POPULATE_PKG;

/
