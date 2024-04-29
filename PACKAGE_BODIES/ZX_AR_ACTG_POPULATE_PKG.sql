--------------------------------------------------------
--  DDL for Package Body ZX_AR_ACTG_POPULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_AR_ACTG_POPULATE_PKG" AS
/* $Header: zxriractgpoppvtb.pls 120.6.12010000.2 2008/11/12 12:48:28 spasala ship $ */


--Populate party info into global variables
      GT_BILLING_TP_NUMBER             ZX_EXTRACT_PKG.BILLING_TP_NUMBER_TBL;
      GT_BILLING_TP_TAX_REG_NUM        ZX_EXTRACT_PKG.BILLING_TP_TAX_REG_NUM_TBL;
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
      GT_BILLING_TP_ADDR_LINES_ALT      ZX_EXTRACT_PKG.BILLING_TP_ADDR_LINES_ALT_TBL;
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

    GT_SHIPPING_TP_NUMBER             ZX_EXTRACT_PKG.SHIPPING_TP_NUMBER_TBL;
      GT_SHIPPING_TP_TAX_REG_NUM        ZX_EXTRACT_PKG.SHIPPING_TP_TAX_REG_NUM_TBL;
      GT_SHIPPING_TP_TAXPAYER_ID        ZX_EXTRACT_PKG.SHIPPING_TP_TAXPAYER_ID_TBL;
   --   GT_SHIPPING_TP_SITE_NAME_ALT      ZX_EXTRACT_PKG.SHIPPING_TP_SITE_NAME_ALT_TBL;
      GT_SHIPPING_TP_NAME               ZX_EXTRACT_PKG.SHIPPING_TP_NAME_TBL;
      GT_SHIPPING_TP_NAME_ALT           ZX_EXTRACT_PKG.SHIPPING_TP_NAME_ALT_TBL;
      GT_SHIPPING_TP_SIC_CODE           ZX_EXTRACT_PKG.SHIPPING_TP_SIC_CODE_TBL;
      GT_SHIPPING_TP_CITY               ZX_EXTRACT_PKG.SHIPPING_TP_CITY_TBL;
      GT_SHIPPING_TP_COUNTY             ZX_EXTRACT_PKG.SHIPPING_TP_COUNTY_TBL;
      GT_SHIPPING_TP_STATE              ZX_EXTRACT_PKG.SHIPPING_TP_STATE_TBL;
      GT_SHIPPING_TP_PROVINCE           ZX_EXTRACT_PKG.SHIPPING_TP_PROVINCE_TBL;
      GT_SHIPPING_TP_ADDRESS1           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS1_TBL;
      GT_SHIPPING_TP_ADDRESS2           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS2_TBL;
      GT_SHIPPING_TP_ADDRESS3           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS3_TBL;
      GT_SHIPPING_TP_ADDR_LINES_ALT      ZX_EXTRACT_PKG.SHIPPING_TP_ADDR_LINES_ALT_TBL;
      GT_SHIPPING_TP_COUNTRY            ZX_EXTRACT_PKG.SHIPPING_TP_COUNTRY_TBL;
      GT_SHIPPING_TP_POSTAL_CODE        ZX_EXTRACT_PKG.SHIPPING_TP_POSTAL_CODE_TBL;
--      GT_SHIPPING_TP_PARTY_NUMBER       ZX_EXTRACT_PKG.SHIPPING_TP_PARTY_NUMBER_TBL;
      GT_SHIPPING_TP_ID                 ZX_EXTRACT_PKG.SHIPPING_TP_ID_TBL;
      GT_SHIPPING_TP_SITE_ID            ZX_EXTRACT_PKG.SHIPPING_TP_SITE_ID_TBL;
      GT_SHIPPING_TP_ADDRESS_ID         ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL;
--      GT_SHIPPING_TP_TAX_REP_FLAG       ZX_EXTRACT_PKG.SHIPPING_TP_TAX_REP_FLAG_TBL;
      GT_SHIPPING_TP_SITE_NAME          ZX_EXTRACT_PKG.SHIPPING_TP_SITE_NAME_TBL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT9    ZX_EXTRACT_PKG.GDF_RA_ADDRESSES_SHIP_ATT9_TBL;
      GT_GDF_PARTY_SITES_SHIP_ATT8     ZX_EXTRACT_PKG.GDF_PARTY_SITES_SHIP_ATT8_TBL;
      GT_GDF_RA_CUST_SHIP_ATT10        ZX_EXTRACT_PKG.GDF_RA_CUST_SHIP_ATT10_TBL;
      GT_GDF_RA_CUST_SHIP_ATT12        ZX_EXTRACT_PKG.GDF_RA_CUST_SHIP_ATT12_TBL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT8    ZX_EXTRACT_PKG.GDF_RA_ADDRESSES_SHIP_ATT8_TBL;
      GT_TAX_RATE_VAT_TRX_TYPE_DESC    ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_DESC_TBL;
      GT_TAX_RATE_CODE_REG_TYPE_MNG    ZX_EXTRACT_PKG.TAX_RATE_CODE_REG_TYPE_MNG_TBL;
      GT_TRX_CLASS_MNG                 ZX_EXTRACT_PKG.TRX_CLASS_MNG_TBL;
      GT_TAX_EXCEPTION_REASON_MNG      ZX_EXTRACT_PKG.TAX_EXCEPTION_REASON_MNG_TBL;
      GT_TAX_EXEMPT_REASON_MNG         ZX_EXTRACT_PKG.TAX_EXEMPT_REASON_MNG_TBL;

      GT_DETAIL_TAX_LINE_ID         ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
      GT_LEDGER_ID                  ZX_EXTRACT_PKG.LEDGER_ID_TBL;
      GT_TRX_ID                     ZX_EXTRACT_PKG.TRX_ID_TBL;
      GT_TRX_TYPE_ID                ZX_EXTRACT_PKG.TRX_TYPE_ID_TBL;
      GT_TRX_CLASS                  ZX_EXTRACT_PKG.TRX_LINE_CLASS_TBL;
      GT_TRX_BATCH_SOURCE_ID        ZX_EXTRACT_PKG.BATCH_SOURCE_ID_TBL;
      GT_TAX_RATE_ID                ZX_EXTRACT_PKG.TAX_RATE_ID_TBL;
      GT_TAX_RATE_VAT_TRX_TYPE_CODE ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_CODE_TBL;
      GT_TAX_RATE_REG_TYPE_CODE            ZX_EXTRACT_PKG.TAX_RATE_REG_TYPE_CODE_TBL;
      GT_TAX_EXEMPTION_ID            ZX_EXTRACT_PKG.TAX_EXEMPTION_ID_TBL;
      GT_TAX_EXCEPTION_ID            ZX_EXTRACT_PKG.TAX_EXCEPTION_ID_TBL;
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
      GT_BR_REF_CUSTOMER_TRX_ID     ZX_EXTRACT_PKG.BR_REF_CUSTOMER_TRX_ID_TBL;
      GT_REVERSE_FLAG               ZX_EXTRACT_PKG.REVERSE_FLAG_TBL;
      GT_AMOUNT_APPLIED             ZX_EXTRACT_PKG.AMOUNT_APPLIED_TBL;
      GT_TAX_RATE                   ZX_EXTRACT_PKG.TAX_RATE_TBL;
      GT_TAX_RATE_CODE              ZX_EXTRACT_PKG.TAX_RATE_CODE_TBL;
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
      GT_ACTG_SOURCE_ID                ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL;
      GT_AE_HEADER_ID                  ZX_EXTRACT_PKG.ACTG_HEADER_ID_TBL;
      GT_EVENT_ID                      ZX_EXTRACT_PKG.ACTG_EVENT_ID_TBL;
--      GT_ENTITY_ID                     ZX_EXTRACT_PKG.ACTG_ENTITY_ID_TBL;
      GT_LINE_CCID                     ZX_EXTRACT_PKG.ACTG_LINE_CCID_TBL;
      GT_TRX_ARAP_BALANCING_SEGMENT    ZX_EXTRACT_PKG.TRX_ARAP_BALANCING_SEG_TBL;
      GT_TRX_ARAP_NATURAL_ACCOUNT      ZX_EXTRACT_PKG.TRX_ARAP_NATURAL_ACCOUNT_TBL;
      GT_TRX_TAXABLE_BAL_SEG           ZX_EXTRACT_PKG.TRX_TAXABLE_BALANCING_SEG_TBL;
      GT_TRX_TAXABLE_NATURAL_ACCOUNT   ZX_EXTRACT_PKG.TRX_TAXABLE_NATURAL_ACCT_TBL;
      GT_TRX_TAX_BALANCING_SEGMENT     ZX_EXTRACT_PKG.TRX_TAX_BALANCING_SEG_TBL;
      GT_TRX_TAX_NATURAL_ACCOUNT       ZX_EXTRACT_PKG.TRX_TAX_NATURAL_ACCOUNT_TBL;
      --GT_INTERNAL_ORGANIZATION_ID    ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL;
-- apai       GT_REP_CONTEXT_ID                ZX_EXTRACT_PKG.REP_CONTEXT_ID_TBL;


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
                              P_TRX_CLASS             IN VARCHAR2,
                              i                       IN binary_integer);

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
                                 i                       IN binary_integer);

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
                              i                       IN binary_integer);

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
                                 i                       IN binary_integer);

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
                              P_TRX_CLASS             IN VARCHAR2,
                              i                       IN binary_integer);


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
                                 i                       IN binary_integer);

PROCEDURE EXTRACT_PARTY_INFO( i IN BINARY_INTEGER);

PROCEDURE initialize_variables (
          p_count   IN         NUMBER);

PROCEDURE populate_meaning(
           P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           i BINARY_INTEGER);

PROCEDURE UPDATE_REP_DETAIL_T(p_count IN NUMBER);

PROCEDURE UPDATE_REP_ACTG_T(p_count IN NUMBER);

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
          P_TRL_GLOBAL_VARIABLES_REC      IN OUT  NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
          P_MRC_SOB_TYPE IN VARCHAR2)
IS

CURSOR detail_t_cur(c_request_id IN NUMBER) IS
SELECT  ZX_DTL.DETAIL_TAX_LINE_ID,
        ZX_DTL.LEDGER_ID,
        ZX_DTL.INTERNAL_ORGANIZATION_ID,
        ZX_DTL.TRX_ID ,
        ZX_DTL.TRX_TYPE_ID ,
        ZX_DTL.TRX_LINE_CLASS,
        ZX_DTL.TRX_BATCH_SOURCE_ID,
        ZX_DTL.TAX_RATE_ID ,
        ZX_DTL.TAX_RATE_VAT_TRX_TYPE_CODE,
        ZX_DTL.TAX_RATE_REGISTER_TYPE_CODE,
        ZX_DTL.TAX_EXEMPTION_ID ,
        ZX_DTL.TAX_EXCEPTION_ID ,
        ZX_DTL.TAX_LINE_ID ,
        ZX_DTL.TAX_AMT ,
        ZX_DTL.TAX_AMT_FUNCL_CURR ,
        ZX_DTL.TAX_LINE_NUMBER ,
        ZX_DTL.TAXABLE_AMT ,
        ZX_DTL.TAXABLE_AMT_FUNCL_CURR ,
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
        ZX_ACTG.ACTG_SOURCE_ID,
        ZX_ACTG.ACTG_HEADER_ID,
        ZX_ACTG.ACTG_EVENT_ID,
   --     ZX_ACTG.ACTG_ENTITY_ID,
        ZX_ACTG.ACTG_LINE_CCID
   FROM zx_rep_trx_detail_t zx_dtl,
        zx_rep_actg_ext_t zx_actg
  WHERE EXTRACT_SOURCE_LEDGER = 'AR'
    AND zx_dtl.detail_tax_line_id = zx_actg.detail_tax_line_id
    AND zx_dtl.request_id = c_request_id;

    CURSOR chart_of_acc_id IS
         SELECT  chart_of_accounts_id
         FROM    gl_sets_of_books
         WHERE   set_of_books_id =  P_TRL_GLOBAL_VARIABLES_REC.ledger_id;

  L_TRX_CLASS                   VARCHAR2(30);
  L_TAXABLE_AMOUNT              NUMBER;
  L_TAXABLE_ACCOUNTED_AMOUNT    NUMBER;

 -- L_BANKING_TP_NAME             AR_TAX_EXTRACT_SUB_ITF.BANKING_TP_NAME%TYPE;
 -- L_BANKING_TP_TAXPAYER_ID      AR_TAX_EXTRACT_SUB_ITF.BANKING_TP_TAXPAYER_ID%type;
 -- L_MATRIX_REPORT               VARCHAR2(1);

--  L_TRX_APPLIED_TO_TRX_ID       NUMBER;  -- where it is used, AP
--  L_ACCOUNTING_DATE             DATE; -- where is this being used  AP
--  L_TRX_CURRENCY_CODE           VARCHAR2(15);
--  RA_SUB_ITF_TABLE_REC          AR_TAX_EXTRACT_SUB_ITF%ROWTYPE;
  l_count                       NUMBER;
    l_balancing_segment         VARCHAR2(25);
    l_accounting_segment         VARCHAR2(25);
    l_ledger_id                 NUMBER(15);
BEGIN

     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_ADDITIONAL_INFO.BEGIN',
                                      'ZX_AR_ACTG_POPULATE_PKG: UPDATE_ADDITIONAL_INFO(+)');
    END IF;
    l_ledger_id  := NVL(P_TRL_GLOBAL_VARIABLES_REC.REPORTING_LEDGER_ID, P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID);
 --  L_MATRIX_REPORT := P_MATRIX_REPORT;
   -- l_request_id is global param, assigned value in initialize


-- Accounting Flex Field Information --

      OPEN chart_of_acc_id;
      FETCH chart_of_acc_id
       INTO P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id;

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

   OPEN detail_t_cur(P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID);
   LOOP
      FETCH detail_t_cur BULK COLLECT INTO
      GT_DETAIL_TAX_LINE_ID,
      GT_LEDGER_ID,
      GT_INTERNAL_ORGANIZATION_ID,
      GT_TRX_ID,
      GT_TRX_TYPE_ID,
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
      GT_BILLING_TP_ID,
      GT_BILLING_TP_SITE_ID,
      GT_BILLING_TP_ADDRESS_ID,
      GT_SHIPPING_TP_ID,
      GT_SHIPPING_TP_SITE_ID,
      GT_SHIPPING_TP_ADDRESS_ID,
      GT_BILL_TO_PARTY_ID,
      GT_BILL_TO_PARTY_SITE_ID,
      GT_SHIP_TO_PARTY_ID,
      GT_SHIP_TO_PARTY_SITE_ID,
      GT_HISTORICAL_FLAG,
      GT_ACTG_SOURCE_ID,
      GT_AE_HEADER_ID,
      GT_EVENT_ID,
--      GT_ENTITY_ID,
      GT_LINE_CCID
      LIMIT C_LINES_PER_COMMIT;

     l_count := nvl(GT_DETAIL_TAX_LINE_ID.COUNT,0);

     IF l_count >0 THEN

	   initialize_variables(l_count);
           G_REP_CONTEXT_ID := ZX_EXTRACT_PKG.GET_REP_CONTEXT_ID(P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID,
                                                                 P_TRL_GLOBAL_VARIABLES_REC.request_id);


      FOR i IN 1..l_count
      LOOP

         L_TRX_CLASS := GT_TRX_CLASS(i);

         IF P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION'
          OR ( UPPER(L_TRX_CLASS) IN
             ('APP','EDISC','UNEDISC','ADJ','FINCHRG','MISC_CASH_RECEIPT','BR') )
         THEN
         --     Pass the taxable amount columns for rounding
            L_TAXABLE_AMOUNT  :=  GT_TAXABLE_AMT(i);
            L_TAXABLE_ACCOUNTED_AMOUNT := GT_TAXABLE_AMT_FUNCL_CURR(i);
         END IF;
         /* apai
         GT_REP_CONTEXT_ID(i) := ZX_EXTRACT_PKG.GET_REP_CONTEXT_ID(GT_INTERNAL_ORGANIZATION_ID(i),
                                                                          P_TRL_GLOBAL_VARIABLES_REC.legal_entity_level,
                                                                          P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID,
                                                                          P_TRL_GLOBAL_VARIABLES_REC.request_id);
         */

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
                                      'G_REP_CONTEXT_ID :' ||to_char(G_REP_CONTEXT_ID)||'---'
                                       ||to_char(GT_INTERNAL_ORGANIZATION_ID(i)));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
                                      'GT_TRX_ID :' ||to_char(GT_TRX_ID(i)));
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

         get_accounting_info(GT_TRX_ID(i),
                              GT_TRX_LINE_ID(i),
                              GT_TAX_LINE_ID(i),
                              GT_EVENT_ID(i),
                              GT_AE_HEADER_ID(i),
                              GT_ACTG_SOURCE_ID(i),
                              l_balancing_segment,
                              l_accounting_segment,
                              P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
                              L_TRX_CLASS,
                              i) ;

         get_accounting_amounts(GT_TRX_ID(i),
                              GT_TRX_LINE_ID(i),
                              GT_TAX_LINE_ID(i),
                    --          GT_ENTITY_ID(i),
                              GT_EVENT_ID(i),
                              GT_AE_HEADER_ID(i),
                              GT_ACTG_SOURCE_ID(i),
                              P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
                              L_TRX_CLASS,
                              l_ledger_id,
                              i) ;


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
--
   --       POPULATE_EXT_COM_EXT_COLUMNS( p_index => i );

            EXTRACT_PARTY_INFO(i);

      END LOOP; -- end loop of each extract line

 --     IF G_AR_RETCODE <>2 THEN
  --      UPDATE_AR_SUB_ITF(L_MATRIX_REPORT,P_SUMMARY_LEVEL );
   --   END IF;
--
 --     IF G_AR_RETCODE <>2 THEN
  --      UPDATE_AR_EXTENSION(l_count);
   --   END IF;
   --
    --  IF G_AR_RETCODE <>2 THEN
     --   UPDATE_COM_EXTENSION(l_count);
      --END IF;

   -- ELSE
--
 --     EXIT;

    END IF;
           UPDATE_REP_DETAIL_T(l_count);
           UPDATE_REP_ACTG_T(l_count);

    EXIT WHEN detail_t_cur%NOTFOUND
              OR detail_t_cur%NOTFOUND IS NULL;

   END LOOP;

   CLOSE detail_t_cur;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_ADDITIONAL_INFO.END',
                                      'ZX_AR_ACTG_POPULATE_PKG: UPDATE_ADDITIONAL_INFO(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_ADDITIONAL_INFO',
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
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.APP_FUNCTIONAL_AMOUNTS.BEGIN',
                                      'ZX_AR_ACTG_POPULATE_PKG: APP_FUNCTIONAL_AMOUNTS(+)');
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
                          0, i);  --P_INPUT_EXEMPT_AMOUNT

  ELSIF  P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN

           L_TAXABLE_AMOUNT := L_TAXABLE_AMOUNT - nvl(L_EXEMPT_AMOUNT,0);

            convert_amounts(
                            P_CURRENCY_CODE,
                            P_EXCHANGE_RATE,
                            P_PRECISION,
                            P_MIN_ACCT_UNIT,
                            P_INPUT_TAX_AMOUNT,
                            P_INPUT_TAXABLE_AMOUNT,
                            0,i);  --P_INPUT_EXEMPT_AMOUNT,


  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
 /*
    IF L_EXEMPT_AMOUNT IS NOT NULL THEN
        P_EXEMPT_ENTERED_AMOUNT :=
             arpcurr.CurrRound(L_EXEMPT_AMOUNT,L_CURRENCY_CODE);

       IF P_TAXABLE_AMOUNT IS NOT NULL THEN
           P_TAXABLE_EXEMPT_ENTERED_AMT  :=
             arpcurr.CurrRound((P_TAXABLE_AMOUNT + L_EXEMPT_AMOUNT),
                            L_CURRENCY_CODE);
       END IF;

    ELSE
        P_EXEMPT_ENTERED_AMOUNT := 0;
        P_TAXABLE_EXEMPT_ENTERED_AMT  := P_TAXABLE_AMOUNT;
    END IF;

    IF P_EXEMPT_ENTERED_AMOUNT IS NOT NULL THEN
        P_EXEMPT_ACCTD_AMOUNT :=
                        arpcurr.FUNCTIONAL_AMOUNT(
                                  P_EXEMPT_ENTERED_AMOUNT,
                                  L_CURRENCY_CODE,
                                  L_EXCHANGE_RATE,
                                  L_PRECISION,
                                  L_MIN_ACCT_UNIT);
    END IF;

    IF P_TAXABLE_EXEMPT_ENTERED_AMT IS NOT NULL THEN
        P_TAXABLE_EXEMPT_ACCTD_AMT :=
                        arpcurr.FUNCTIONAL_AMOUNT(
                                  P_TAXABLE_EXEMPT_ENTERED_AMT,
                                  L_CURRENCY_CODE,
                                  L_EXCHANGE_RATE,
                                  L_PRECISION,
                                  L_MIN_ACCT_UNIT);
    END IF;

    --      Round off the amounts to the precision for the functional currency.
    --      Modified the code such that taxable_accounted_amount is rounded
    --      before taxable amount is rounded (BUG3123264).

    IF P_TAXABLE_AMOUNT IS NOT NULL THEN
       P_TAXABLE_ACCOUNTED_AMOUNT :=
            arpcurr.FUNCTIONAL_AMOUNT(P_TAXABLE_AMOUNT,
                                L_CURRENCY_CODE,
                                L_EXCHANGE_RATE,
                                L_PRECISION,
                                L_MIN_ACCT_UNIT);
    END IF;


    IF P_TAXABLE_AMOUNT IS NOT NULL THEN
      P_TAXABLE_AMOUNT :=
         arpcurr.CurrRound(P_TAXABLE_AMOUNT,L_CURRENCY_CODE);
    END IF;
*/
  NULL;

  END IF;  -- P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION'

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.APP_FUNCTIONAL_AMOUNTS.END',
                                      'ZX_AR_ACTG_POPULATE_PKG: APP_FUNCTIONAL_AMOUNTS(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.APP_FUNCTIONAL_AMOUNTS',
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
                              P_TRX_CLASS             IN VARCHAR2,
                              i                       IN binary_integer) IS

BEGIN

  IF p_trx_class in ('INV','CM','DM') THEN
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
                       P_TRX_CLASS,
                       i);

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
                              i);
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
                                 i                       IN binary_integer) IS
BEGIN
   IF p_trx_class in ('INV','CM','DM') THEN
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
                       i);
   ELSIF p_trx_class IN ('APP','EDISC','UNEDISC','ADJ','FINCHRG',
                       'MISC_CASH_RECEIPT') THEN
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
                            i);
  END IF;

END get_accounting_amounts;

/*PROCEDURE inv_segment_info (P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                   --           P_ENTITY_ID             IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_TAX_DIST_ID           IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                              i                       IN binary_integer) IS */
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
                                 P_TRX_CLASS             IN VARCHAR2,
                              i                       IN binary_integer) IS
    CURSOR trx_ccid (c_trx_id number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.account_class = 'LINE'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                      AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
              AND rownum =1;

    CURSOR trx_line_ccid (c_trx_id number, c_trx_line_id number, c_event_id number, c_ae_header_id NUMBER) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.customer_trx_line_id = c_trx_line_id
                     AND gl_dist.account_class = 'LINE'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                      AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
              AND rownum =1;


-- For transavtion distribution level code combination id select in the build SQL
-- The following query can be removed ----

  CURSOR trx_dist_ccid (c_trx_id NUMBER, c_trx_line_id NUMBER, c_event_id NUMBER, c_ae_header_id NUMBER) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.customer_trx_line_id = c_trx_line_id
                     AND gl_dist.account_class = 'LINE'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                      AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
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
              AND rownum =1;


-- For transavtion distribution level code combination id select in the build SQL
-- The following query can be removed ----

  CURSOR tax_dist_ccid (c_trx_id NUMBER, c_tax_line_id NUMBER, c_tax_line_dist_id NUMBER,
                                      c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM ra_cust_trx_line_gl_dist_all gl_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE gl_dist.customer_trx_id = c_trx_id
                     AND gl_dist.customer_trx_line_id = c_tax_line_id
                     AND gl_dist.cust_trx_line_gl_dist_id = c_tax_line_dist_id
                     AND gl_dist.account_class = 'TAX'
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                     AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                      AND lnk.event_id      = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
              AND rownum =1;

  L_BAL_SEG_VAL  VARCHAR2(240);
  L_ACCT_SEG_VAL VARCHAR2(240);
  L_SQL_STATEMENT1     VARCHAR2(1000);
 L_SQL_STATEMENT2     VARCHAR2(1000);
 l_ccid number;
BEGIN

  GT_TRX_ARAP_BALANCING_SEGMENT(i)    := NULL;
  GT_TRX_ARAP_NATURAL_ACCOUNT(i)      := NULL;
  GT_TRX_TAXABLE_BAL_SEG(i)           := NULL;
  GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)   := NULL;
  GT_TRX_TAX_BALANCING_SEGMENT(i)     := NULL;
  GT_TRX_TAX_NATURAL_ACCOUNT(i)       := NULL;


  L_BAL_SEG_VAL := '';
  L_ACCT_SEG_VAL := '';

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
      EXIT WHEN trx_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_ccid (p_trx_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
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

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_line_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_line_ccid INTO l_ccid;
      EXIT WHEN tax_line_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;


  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
      OPEN trx_dist_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_dist_ccid INTO l_ccid;
      EXIT WHEN trx_dist_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_dist_ccid (p_trx_id, p_tax_line_id, P_ACTG_SOURCE_ID, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;
END IF; -- Summary Level
END inv_segment_info;



/*PROCEDURE inv_actg_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                  --               P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_TAX_DIST_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_TRX_CLASS             IN VARCHAR2,
                                 i                       IN binary_integer) IS */
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
                                 i                       IN binary_integer) IS
-- Transaction Header Level

   CURSOR taxable_amount_hdr (c_trx_id NUMBER, c_ae_header_id NUMBER, c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
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
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id;



   CURSOR tax_amount_hdr (c_trx_id NUMBER, c_ae_header_id NUMBER,  c_event_id NUMBER,c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
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
          AND aeh.ledger_id      = c_ledger_id;



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
          AND aeh.ledger_id      = c_ledger_id;



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
          AND aeh.ledger_id      = c_ledger_id;


-- Transaction Distribution Level



CURSOR tax_amount_dist ( c_trx_id NUMBER,c_tax_line_id NUMBER, c_tax_dist_id NUMBER, c_ae_header_id NUMBER,
                         c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM ra_cust_trx_line_gl_dist_all gl_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE gl_dist.customer_trx_id = c_trx_id
          AND gl_dist.customer_trx_line_id = c_tax_line_id
          AND gl_dist.cust_trx_line_gl_dist_id = c_tax_dist_id
          AND gl_dist.account_class = 'TAX'
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
          AND lnk.ae_header_id   = ael.ae_header_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND lnk.event_id      = c_event_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id;



 CURSOR taxable_amount_dist (c_trx_id NUMBER,c_trx_line_id NUMBER, c_ae_header_id NUMBER,
                      c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM ra_cust_trx_line_gl_dist_all gl_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE gl_dist.customer_trx_id = c_trx_id
          AND gl_dist.customer_trx_line_id = c_trx_line_id
          AND gl_dist.account_class = 'LINE'
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id       = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id;




BEGIN

   IF p_summary_level = 'TRANSACTION' THEN
      OPEN taxable_amount_hdr(p_trx_id , p_ae_header_id , p_event_id,p_ledger_id );
      FETCH taxable_amount_hdr INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
       --    EXIT WHEN taxable_amount_hdr%NOTFOUND;
       CLOSE taxable_amount_hdr;

      OPEN tax_amount_hdr(p_trx_id , p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_hdr INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
--      EXIT WHEN tax_amount_hdr%NOTFOUND;
     CLOSE tax_amount_hdr;
  ELSIF p_summary_level = 'TRANSACTION_LINE' THEN
           OPEN taxable_amount_line(p_trx_id ,p_trx_line_id, p_ae_header_id , p_event_id,p_ledger_id);
      FETCH taxable_amount_line INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
  --        EXIT WHEN taxable_amount_line%NOTFOUND;
        CLOSE taxable_amount_line;

      OPEN tax_amount_line(p_trx_id , p_trx_line_id, p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_line INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
--      EXIT WHEN tax_amount_line%NOTFOUND;
      CLOSE tax_amount_line;

  ELSIF p_summary_level = 'TRANSACTION_DISTRIBUTION' THEN
      OPEN taxable_amount_dist(P_ACTG_SOURCE_ID ,p_trx_line_id,p_ae_header_id , p_event_id,p_ledger_id);
      FETCH taxable_amount_dist INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
--         EXIT WHEN taxable_amount_dist%NOTFOUND;
        CLOSE taxable_amount_dist;

      OPEN tax_amount_dist(p_trx_id ,p_tax_line_id,P_ACTG_SOURCE_ID, p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_dist INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
 --     EXIT WHEN tax_amount_dist%NOTFOUND;
     CLOSE tax_amount_dist;
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
                              i                       IN binary_integer) IS

    CURSOR trx_ccid (c_actg_source_id  number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM  ar_distributions_all dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE dist.line_id  = p_actg_source_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.source_distribution_id_num_1 = dist.line_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
              AND rownum =1;

    CURSOR trx_dist_ccid (c_actg_source_id  number, c_event_id number, c_ae_header_id number) IS
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
              AND rownum =1;

    CURSOR tax_ccid (c_actg_source_id number, c_event_id number, c_ae_header_id number) IS
            SELECT  ael.code_combination_id
                    FROM  ar_distributions_all dist,
                          ar_distributions_all taxdist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE dist.line_id  = p_actg_source_id
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
              AND rownum =1;

  CURSOR tax_dist_ccid (c_actg_source_id number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM  ar_distributions_all taxdist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE taxdist.line_id  = p_actg_source_id
                     AND lnk.application_id = 222
                     AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
                     AND lnk.source_distribution_id_num_1 = taxdist.line_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id = c_event_id
                     AND lnk.ae_header_id = c_ae_header_id
              AND rownum =1;



  L_BAL_SEG_VAL  VARCHAR2(240);
  L_ACCT_SEG_VAL VARCHAR2(240);
  L_SQL_STATEMENT1     VARCHAR2(1000);
 L_SQL_STATEMENT2     VARCHAR2(1000);
 l_ccid number;
BEGIN

  GT_TRX_ARAP_BALANCING_SEGMENT(i)    := NULL;
  GT_TRX_ARAP_NATURAL_ACCOUNT(i)      := NULL;
  GT_TRX_TAXABLE_BAL_SEG(i)           := NULL;
  GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)   := NULL;
  GT_TRX_TAX_BALANCING_SEGMENT(i)     := NULL;
  GT_TRX_TAX_NATURAL_ACCOUNT(i)       := NULL;


  L_BAL_SEG_VAL := '';
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

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_ccid (p_actg_source_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
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

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_line_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_line_ccid INTO l_ccid;
      EXIT WHEN tax_line_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;
*/

  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
      OPEN trx_dist_ccid (p_actg_source_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_dist_ccid INTO l_ccid;
      EXIT WHEN trx_dist_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_dist_ccid (p_actg_source_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;
END IF; -- Summary Level
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
                                 i                       IN binary_integer) IS
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
          AND aeh.ledger_id = c_ledger_id;

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
          AND aeh.ledger_id = c_ledger_id;


-- Transaction Distribution Level

   CURSOR taxable_amount_dist (c_actg_source_id NUMBER, c_ae_header_id NUMBER, c_event_id NUMBER,c_ledger_id NUMBER) IS
       SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM AR_DISTRIBUTIONS_ALL dist,
              AR_DISTRIBUTIONS_ALL taxdist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE taxdist.line_id = c_actg_source_id
          AND taxdist.tax_link_id = dist.tax_link_id
          AND NVL(taxdist.source_type_secondary,'X') = NVL(dist.source_type,'X')
          AND taxdist.source_id = dist.source_id
          AND lnk.source_distribution_id_num_1 = dist.line_id
          AND lnk.application_id = 222
          AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id;

   CURSOR tax_amount_dist (c_actg_source_id NUMBER, c_ae_header_id NUMBER,
                           c_event_id NUMBER,c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
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
          AND aeh.ledger_id = c_ledger_id;

BEGIN

   IF p_summary_level = 'TRANSACTION' THEN
      OPEN taxable_amount_hdr(p_actg_source_id , p_ae_header_id , p_event_id,p_ledger_id );
      FETCH taxable_amount_hdr INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
       --    EXIT WHEN taxable_amount_hdr%NOTFOUND;
       CLOSE taxable_amount_hdr;

      OPEN tax_amount_hdr(p_actg_source_id , p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_hdr INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
--      EXIT WHEN tax_amount_hdr%NOTFOUND;
     CLOSE tax_amount_hdr;
/*  ELSIF p_summary_level = 'TRANSACTION_LINE' THEN
           OPEN taxable_amount_line(p_trx_id ,p_trx_line_id, p_ae_header_id , p_event_id);
      FETCH taxable_amount_line INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
  --        EXIT WHEN taxable_amount_line%NOTFOUND;
        CLOSE taxable_amount_line;

      OPEN tax_amount_line(p_trx_id , p_trx_line_id, p_ae_header_id , p_event_id);
      FETCH tax_amount_line INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
--      EXIT WHEN tax_amount_line%NOTFOUND;
      CLOSE tax_amount_line;
*/
  ELSIF p_summary_level = 'TRANSACTION_DISTRIBUTION' THEN
      OPEN taxable_amount_dist(p_actg_source_id ,p_ae_header_id , p_event_id,p_ledger_id);
      FETCH taxable_amount_dist INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
--         EXIT WHEN taxable_amount_dist%NOTFOUND;
        CLOSE taxable_amount_dist;

      OPEN tax_amount_dist(p_actg_source_id, p_ae_header_id , p_event_id,p_ledger_id);
      FETCH tax_amount_dist INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
 --     EXIT WHEN tax_amount_dist%NOTFOUND;
     CLOSE tax_amount_dist;
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
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.convert_amounts.BEGIN',
                                      'ZX_AR_ACTG_POPULATE_PKG: convert_amounts(+)');
    END IF;
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
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.convert_amounts.END',
                                      'ZX_AR_ACTG_POPULATE_PKG: convert_amounts(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.convert_amounts',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;
END convert_amounts;

-- This API populates accounting segment details---
---------------------------------------------------


-- This API populates Accounting Amounts ---
---------------------------------------------------


/*PROCEDURE EXTRACT_PARTY_INFO( i IN BINARY_INTEGER) IS

   l_bill_to_party_id          zx_rep_trx_detail_t.BILL_TO_PARTY_ID%TYPE;
   l_bill_to_site_id           zx_rep_trx_detail_t.BILL_TO_PARTY_SITE_ID%TYPE;
   l_bill_to_ptp_id            zx_rep_trx_detail_t.BILL_FROM_PARTY_TAX_PROF_ID%TYPE;
   l_bill_to_stp_id            zx_rep_trx_detail_t.BILL_FROM_SITE_TAX_PROF_ID%TYPE;

   l_ship_to_party_id          zx_rep_trx_detail_t.SHIP_TO_PARTY_ID%TYPE;
   l_ship_to_site_id           zx_rep_trx_detail_t.SHIP_TO_PARTY_SITE_ID%TYPE;
   l_ship_to_ptp_id            zx_rep_trx_detail_t.SHIP_FROM_PARTY_TAX_PROF_ID%TYPE;
   l_ship_to_stp_id            zx_rep_trx_detail_t.SHIP_FROM_SITE_TAX_PROF_ID%TYPE;

   l_bill_ship      varchar2(30);

   l_tbl_index_party      BINARY_INTEGER;
   l_tbl_index_site       BINARY_INTEGER;
   l_tbl_index_cust       BINARY_INTEGER;

CURSOR party_id_cur
       (c_ptp_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_TAX_PROF_ID%TYPE) IS
SELECT party_id
  FROM zx_party_tax_profile
 WHERE PARTY_TAX_PROFILE_ID = c_ptp_id
   AND party_type_code = 'THIRD_PARTY';

 CURSOR party_site_id_cur
       (c_ptp_site_id ZX_REP_TRX_DETAIL_T.BILL_TO_SITE_TAX_PROF_ID%TYPE) IS
SELECT party_id
  FROM zx_party_tax_profile
 WHERE PARTY_TAX_PROFILE_ID = c_ptp_site_id
   AND party_type_code = 'THIRD_PARTY_SITE';

-- If party_id is NOT NULL and Historical flag 'Y' then get the party tax profile ID from zx_party_tax_profile

  CURSOR party_profile_id_cur
      (c_party_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_ID%TYPE) IS
SELECT party_tax_profile_id
  FROM zx_party_tax_profile
 WHERE party_id = c_party_id
   AND party_type_code = 'THIRD_PARTY';


CURSOR site_profile_id_cur
       (c_party_site_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_SITE_ID%TYPE) IS
SELECT party_tax_profile_id
  FROM zx_party_tax_profile
 WHERE party_id = c_party_site_id
   AND party_type_code = 'THIRD_PARTY_SITE';

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
        PARTY.PARTY_NUMBER
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

CURSOR cust_acct_cur (c_party_site_id  ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_SITE_ID%TYPE,
                      c_party_id  ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_ID%TYPE,
                      c_ship_bill varchar2) IS
SELECT acct.account_number,
       acct.global_attribute10,
       acct.global_attribute12,
       acct_site.global_attribute8,
       acct_site.global_attribute9,
       site_use.location,
       site_use.tax_reference
  FROM hz_cust_accounts acct,
       hz_cust_site_uses_all site_use ,
       hz_cust_acct_sites_all acct_site
 WHERE acct.CUST_ACCOUNT_ID =  acct_site.CUST_ACCOUNT_ID
   and acct_site.CUST_ACCT_SITE_ID = site_use.CUST_ACCT_SITE_ID
   and acct_site.PARTY_SITE_ID  = c_party_site_id
  and ACCT.PARTY_ID   = c_party_id
  and site_use.site_use_code = c_ship_bill;

CURSOR migrated_party_cur (c_cust_acct_id ZX_REP_TRX_DETAIL_T.BILLING_TRADING_PARTNER_ID%TYPE) IS
SELECT party.party_id
  FROM HZ_PARTIES    PARTY,
       hz_cust_accounts acct
 WHERE PARTY.PARTY_ID =  acct.party_id
       And acct.cust_account_id = c_cust_acct_id;


CURSOR migrated_party_site_cur ( c_cust_acct_site_id  ZX_REP_TRX_DETAIL_T.BILLING_TP_ADDRESS_ID%TYPE) IS
SELECT PARTY_SITE.party_site_id
  FROM HZ_PARTY_SITES      PARTY_SITE,
       hz_cust_acct_sites_all   acct_site
 WHERE acct_site.cust_acct_site_id = c_cust_acct_site_id
   AND party_site.party_site_id = acct_site. party_site_id;

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO.BEGIN',
                                      'ZX_AR_ACTG_POPULATE_PKG: EXTRACT_PARTY_INFO(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                                      'gt_historical_flag :' ||gt_historical_flag(i));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                                      'GT_BILL_TO_PARTY_TAX_PROF_ID :' ||to_char(GT_BILL_TO_PARTY_TAX_PROF_ID(i)));
    END IF;

    IF gt_historical_flag(i) IS NULL AND GT_BILL_TO_PARTY_TAX_PROF_ID(i) IS NOT NULL THEN
       OPEN party_id_cur(GT_BILL_TO_PARTY_TAX_PROF_ID(i));
       FETCH party_id_cur INTO l_bill_to_party_id;
       CLOSE party_id_cur;

       OPEN party_site_id_cur(GT_BILL_TO_SITE_TAX_PROF_ID(i));
       FETCH party_site_id_cur INTO l_bill_to_site_id;
       CLOSE party_site_id_cur;

       l_bill_to_ptp_id := GT_BILL_TO_PARTY_TAX_PROF_ID(i);
       l_bill_to_stp_id := GT_BILL_TO_SITE_TAX_PROF_ID(i);

    ELSE
       OPEN migrated_party_cur (GT_BILLING_TP_ID(i));
       FETCH migrated_party_cur INTO GT_BILL_TO_PARTY_ID(i);
       CLOSE migrated_party_cur;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'migrated_party_cur'||to_char(GT_BILL_TO_PARTY_ID(i))||'-'||to_char(GT_BILLING_TP_ID(i)));
      END IF;


       OPEN party_profile_id_cur (GT_BILL_TO_PARTY_ID(i));
       FETCH party_profile_id_cur into l_bill_to_ptp_id;
       CLOSE party_profile_id_cur;

       OPEN migrated_party_site_cur (GT_BILLING_TP_ADDRESS_ID(i));
       FETCH migrated_party_site_cur INTO GT_BILL_TO_PARTY_SITE_ID(i);
       CLOSE migrated_party_site_cur;

       OPEN site_profile_id_cur(GT_BILL_TO_PARTY_SITE_ID(i));
       FETCH site_profile_id_cur INTO l_bill_to_stp_id;
       CLOSE site_profile_id_cur;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'migrated_party_site_cur :'||to_char(GT_BILL_TO_PARTY_SITE_ID(i))||'-'||to_char(GT_BILLING_TP_ADDRESS_ID(i)));
      END IF;

       l_bill_to_party_id := GT_BILL_TO_PARTY_ID(i);
       l_bill_to_site_id := GT_BILL_TO_PARTY_SITE_ID(i);
       l_bill_ship := 'BILL_TO';
    END IF;


--    IF GT_BILLING_TP_ID(i) IS NOT NULL AND GT_BILLING_TP_ADDRESS_ID(i) IS NOT NULL THEN

     IF l_bill_to_site_id is not null and  l_bill_to_party_id is not null THEN
        l_tbl_index_cust  := dbms_utility.get_hash_value(to_char(l_bill_to_site_id)||to_char(l_bill_to_party_id)||
                                                                l_bill_ship, 1,8192);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'Before Open cust_acct_cur :'||to_char(l_bill_to_party_id)||'-'||to_char(l_bill_to_site_id));
      END IF;

        IF g_cust_bill_ar_tbl.EXISTS(l_tbl_index_cust) THEN
           GT_BILLING_TP_NUMBER(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_NUMBER  ;
           GT_GDF_RA_CUST_BILL_ATT10(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT10;
           GT_GDF_RA_CUST_BILL_ATT12(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT12;
           GT_GDF_RA_ADDRESSES_BILL_ATT8(i) :=g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT8;
           GT_GDF_RA_ADDRESSES_BILL_ATT9(i) :=g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT9;
           GT_BILLING_TP_SITE_NAME(i)     := g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_SITE_NAME;
           GT_BILLING_TP_TAX_REG_NUM(i)   := g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_TAX_REG_NUM;
        ELSE
          OPEN cust_acct_cur (l_bill_to_site_id,
                        l_bill_to_party_id,
                        l_bill_ship);
          FETCH cust_acct_cur INTO GT_BILLING_TP_NUMBER(i),
                             GT_GDF_RA_CUST_BILL_ATT10(i),
                             GT_GDF_RA_CUST_BILL_ATT12(i),
                             GT_GDF_RA_ADDRESSES_BILL_ATT8(i),
                             GT_GDF_RA_ADDRESSES_BILL_ATT9(i),
                             GT_BILLING_TP_SITE_NAME(i),
                             GT_BILLING_TP_TAX_REG_NUM(i);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After fetch of cust_acct_cur'||GT_BILLING_TP_NUMBER(i)||'-'||GT_BILLING_TP_TAX_REG_NUM(i));
      END IF;

           g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_NUMBER := GT_BILLING_TP_NUMBER(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT10 := GT_GDF_RA_CUST_BILL_ATT10(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT12 := GT_GDF_RA_CUST_BILL_ATT12(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT8 := GT_GDF_RA_ADDRESSES_BILL_ATT8(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT9 := GT_GDF_RA_ADDRESSES_BILL_ATT9(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_SITE_NAME := GT_BILLING_TP_SITE_NAME(i);
           g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_TAX_REG_NUM := GT_BILLING_TP_TAX_REG_NUM(i);

             CLOSE cust_acct_cur;
        END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_cust_bill_ar_tbl ');
        END IF;

       l_tbl_index_party := dbms_utility.get_hash_value(to_char(l_bill_to_party_id)||
                                                                l_bill_ship, 1,8192);
       IF g_party_bill_ar_tbl.EXISTS(l_tbl_index_party) THEN

          GT_BILLING_TP_NAME_ALT(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT;
          GT_BILLING_TP_NAME(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME;
          GT_BILLING_TP_SIC_CODE(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE;
          GT_BILLING_TP_NUMBER(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER;
       ELSE
          OPEN party_cur (l_bill_to_party_id);
          FETCH party_cur INTO GT_BILLING_TP_NAME(i),
                        GT_BILLING_TP_NAME_ALT(i),
                        GT_BILLING_TP_SIC_CODE(i),
                        GT_BILLING_TP_NUMBER(i);

         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT := GT_BILLING_TP_NAME_ALT(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME := GT_BILLING_TP_NAME(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE := GT_BILLING_TP_SIC_CODE(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER := GT_BILLING_TP_NUMBER(i);
       CLOSE party_cur;
       END IF;



        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_party_bill_ar_tbl '||g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER);
        END IF;
       l_tbl_index_site := dbms_utility.get_hash_value(to_char(l_bill_to_site_id)||
                                                                l_bill_ship, 1,8192);

     IF g_site_bill_ar_tbl.EXISTS(l_tbl_index_site) THEN
        GT_BILLING_TP_CITY(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_CITY;
        GT_BILLING_TP_COUNTY(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_COUNTY;
        GT_BILLING_TP_STATE(i)  := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_STATE;
        GT_BILLING_TP_PROVINCE(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_PROVINCE;
        GT_BILLING_TP_ADDRESS1(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS1;
        GT_BILLING_TP_ADDRESS2(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS2;
        GT_BILLING_TP_ADDRESS3(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS3;
        GT_BILLING_TP_ADDR_LINES_ALT(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDR_LINES_ALT;
        GT_BILLING_TP_COUNTRY(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_COUNTRY;
        GT_BILLING_TP_POSTAL_CODE(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_POSTAL_CODE;
     ELSE
        OPEN party_site_cur (l_bill_to_site_id);
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

       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_CITY := GT_BILLING_TP_CITY(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_COUNTY := GT_BILLING_TP_COUNTY(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_STATE := GT_BILLING_TP_STATE(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_PROVINCE := GT_BILLING_TP_PROVINCE(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS1 := GT_BILLING_TP_ADDRESS1(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS2 := GT_BILLING_TP_ADDRESS2(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS3 := GT_BILLING_TP_ADDRESS3(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDR_LINES_ALT := GT_BILLING_TP_ADDR_LINES_ALT(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_COUNTRY := GT_BILLING_TP_COUNTRY(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_POSTAL_CODE := GT_BILLING_TP_POSTAL_CODE(i);
      CLOSE party_site_cur;
      END IF;



       IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_site_bill_ar_tbl '||g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_CITY);
        END IF;
    END IF;


    IF gt_historical_flag(i) IS NULL AND GT_SHIP_TO_PARTY_TAX_PROF_ID(i) IS NOT NULL THEN
       OPEN party_id_cur(GT_SHIP_TO_PARTY_TAX_PROF_ID(i));
       FETCH party_id_cur INTO l_bill_to_party_id;
       CLOSE party_id_cur;

       OPEN party_site_id_cur(GT_SHIP_TO_SITE_TAX_PROF_ID(i));
       FETCH party_site_id_cur INTO l_bill_to_site_id;
       CLOSE party_site_id_cur;

       l_ship_to_ptp_id := GT_SHIP_TO_PARTY_TAX_PROF_ID(i);
       l_ship_to_stp_id := GT_SHIP_TO_SITE_TAX_PROF_ID(i);

    ELSE


       OPEN migrated_party_cur (GT_SHIPPING_TP_ID(i));
       FETCH migrated_party_cur INTO GT_SHIP_TO_PARTY_ID(i);
       CLOSE migrated_party_cur;

       OPEN migrated_party_site_cur (GT_SHIPPING_TP_ADDRESS_ID(i));
       FETCH migrated_party_site_cur INTO GT_SHIP_TO_PARTY_SITE_ID(i);
       CLOSE migrated_party_site_cur;


       OPEN party_profile_id_cur (GT_SHIP_TO_PARTY_ID(i));
       FETCH party_profile_id_cur into l_bill_to_ptp_id;
       CLOSE party_profile_id_cur;

       OPEN site_profile_id_cur(GT_SHIP_TO_PARTY_SITE_ID(i));
       FETCH site_profile_id_cur INTO l_bill_to_stp_id;
       CLOSE site_profile_id_cur;

       l_ship_to_party_id := GT_SHIP_TO_PARTY_ID(i);
       l_ship_to_site_id := GT_SHIP_TO_PARTY_SITE_ID(i);
       l_bill_ship := 'SHIP_TO';

    END IF;

--    IF GT_SHIPPING_TP_ID(i) IS NOT NULL AND GT_SHIPPING_TP_ADDRESS_ID(i) IS NOT NULL THEN


    IF l_ship_to_site_id is not null and  l_ship_to_party_id is not null THEN
       l_tbl_index_cust  := dbms_utility.get_hash_value(to_char(l_ship_to_site_id)||(l_ship_to_party_id)||
                                                                l_bill_ship, 1,8192);

        IF g_cust_ship_ar_tbl.EXISTS(l_tbl_index_cust) THEN
           GT_SHIPPING_TP_NUMBER(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER  ;
           GT_GDF_RA_CUST_SHIP_ATT10(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT10;
           GT_GDF_RA_CUST_SHIP_ATT12(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT12;
           GT_GDF_RA_ADDRESSES_SHIP_ATT8(i) :=g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT8;
           GT_GDF_RA_ADDRESSES_SHIP_ATT9(i) :=g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT9;
           GT_SHIPPING_TP_SITE_NAME(i)     := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_SITE_NAME;
           GT_SHIPPING_TP_TAX_REG_NUM(i)   := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_TAX_REG_NUM;
        ELSE
          OPEN cust_acct_cur (l_ship_to_site_id,
                        l_ship_to_party_id,
                        l_bill_ship);
          FETCH cust_acct_cur INTO GT_SHIPPING_TP_NUMBER(i),
                             GT_GDF_RA_CUST_SHIP_ATT10(i),
                             GT_GDF_RA_CUST_SHIP_ATT12(i),
                             GT_GDF_RA_ADDRESSES_SHIP_ATT8(i),
                             GT_GDF_RA_ADDRESSES_SHIP_ATT9(i),
                             GT_SHIPPING_TP_SITE_NAME(i),
                             GT_SHIPPING_TP_TAX_REG_NUM(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER := GT_SHIPPING_TP_NUMBER(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT10 := GT_GDF_RA_CUST_SHIP_ATT10(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT12 := GT_GDF_RA_CUST_SHIP_ATT12(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT8 := GT_GDF_RA_ADDRESSES_SHIP_ATT8(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT9 := GT_GDF_RA_ADDRESSES_SHIP_ATT9(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_SITE_NAME := GT_SHIPPING_TP_SITE_NAME(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_TAX_REG_NUM := GT_SHIPPING_TP_TAX_REG_NUM(i);

        CLOSE cust_acct_cur;
        END IF;

        l_tbl_index_party  := dbms_utility.get_hash_value(to_char(l_ship_to_party_id)||
                                                                l_bill_ship, 1,8192);
       IF g_party_ship_ar_tbl.EXISTS(l_tbl_index_party) THEN

          GT_SHIPPING_TP_NAME_ALT(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME_ALT;
          GT_SHIPPING_TP_NAME(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME;
          GT_SHIPPING_TP_SIC_CODE(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_SIC_CODE;
          GT_SHIPPING_TP_NUMBER(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NUMBER;
       ELSE
          OPEN party_cur (l_ship_to_party_id);
          FETCH party_cur INTO GT_SHIPPING_TP_NAME(i),
                        GT_SHIPPING_TP_NAME_ALT(i),
                        GT_SHIPPING_TP_SIC_CODE(i),
                        GT_SHIPPING_TP_NUMBER(i);

         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME_ALT := GT_SHIPPING_TP_NAME_ALT(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME := GT_SHIPPING_TP_NAME(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_SIC_CODE := GT_SHIPPING_TP_SIC_CODE(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NUMBER := GT_SHIPPING_TP_NUMBER(i);
       CLOSE party_cur;
       END IF;

      l_tbl_index_site  := dbms_utility.get_hash_value(to_char(l_ship_to_site_id)||
                                                                l_bill_ship, 1,8192);
     IF g_site_ship_ar_tbl.EXISTS(l_tbl_index_site) THEN
        GT_SHIPPING_TP_CITY(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_CITY;
        GT_SHIPPING_TP_COUNTY(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_COUNTY;
        GT_SHIPPING_TP_STATE(i)  := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_STATE;
        GT_SHIPPING_TP_PROVINCE(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_PROVINCE;
        GT_SHIPPING_TP_ADDRESS1(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS1;
        GT_SHIPPING_TP_ADDRESS2(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS2;
        GT_SHIPPING_TP_ADDRESS3(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS3;
        GT_SHIPPING_TP_ADDR_LINES_ALT(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDR_LINES_ALT;
        GT_SHIPPING_TP_COUNTRY(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_COUNTRY;
        GT_SHIPPING_TP_POSTAL_CODE(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_POSTAL_CODE;
     ELSE
        OPEN party_site_cur (l_ship_to_site_id);
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
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_CITY := GT_SHIPPING_TP_CITY(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_COUNTY := GT_SHIPPING_TP_COUNTY(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_STATE := GT_SHIPPING_TP_STATE(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_PROVINCE := GT_SHIPPING_TP_PROVINCE(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS1 := GT_SHIPPING_TP_ADDRESS1(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS2 := GT_SHIPPING_TP_ADDRESS2(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS3 := GT_SHIPPING_TP_ADDRESS3(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDR_LINES_ALT := GT_SHIPPING_TP_ADDR_LINES_ALT(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_COUNTRY := GT_SHIPPING_TP_COUNTRY(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_POSTAL_CODE := GT_SHIPPING_TP_POSTAL_CODE(i);
      CLOSE party_site_cur;
      END IF;

    END IF;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO.END',
                                      'ZX_AR_ACTG_POPULATE_PKG: EXTRACT_PARTY_INFO(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;


END EXTRACT_PARTY_INFO;
*/


PROCEDURE EXTRACT_PARTY_INFO( i IN BINARY_INTEGER) IS

   l_bill_to_party_id          zx_rep_trx_detail_t.BILL_TO_PARTY_ID%TYPE;
   l_bill_to_site_id           zx_rep_trx_detail_t.BILL_TO_PARTY_SITE_ID%TYPE;
   l_bill_to_ptp_id            zx_rep_trx_detail_t.BILL_FROM_PARTY_TAX_PROF_ID%TYPE;
   l_bill_to_stp_id            zx_rep_trx_detail_t.BILL_FROM_SITE_TAX_PROF_ID%TYPE;

   l_ship_to_party_id          zx_rep_trx_detail_t.SHIP_TO_PARTY_ID%TYPE;
   l_ship_to_site_id           zx_rep_trx_detail_t.SHIP_TO_PARTY_SITE_ID%TYPE;
   l_ship_to_ptp_id            zx_rep_trx_detail_t.SHIP_FROM_PARTY_TAX_PROF_ID%TYPE;
   l_ship_to_stp_id            zx_rep_trx_detail_t.SHIP_FROM_SITE_TAX_PROF_ID%TYPE;

   l_bill_ship      varchar2(30);

   l_tbl_index_party      BINARY_INTEGER;
   l_tbl_index_site       BINARY_INTEGER;
   l_tbl_index_cust       BINARY_INTEGER;

CURSOR party_id_from_ptp_cur
       (c_ptp_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_TAX_PROF_ID%TYPE) IS
SELECT party_id
  FROM zx_party_tax_profile
 WHERE PARTY_TAX_PROFILE_ID = c_ptp_id
   AND party_type_code = 'THIRD_PARTY';

 CURSOR party_site_id_from_ptp_cur
       (c_ptp_site_id ZX_REP_TRX_DETAIL_T.BILL_TO_SITE_TAX_PROF_ID%TYPE) IS
SELECT party_id
  FROM zx_party_tax_profile
 WHERE PARTY_TAX_PROFILE_ID = c_ptp_site_id
   AND party_type_code = 'THIRD_PARTY_SITE';

-- If party_id is NOT NULL and Historical flag 'Y' then get the party tax profile ID from zx_party_tax_profile

  CURSOR party_profile_id_cur
      (c_party_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_ID%TYPE) IS
SELECT party_tax_profile_id
  FROM zx_party_tax_profile
 WHERE party_id = c_party_id
   AND party_type_code = 'THIRD_PARTY';


CURSOR site_profile_id_cur
       (c_party_site_id ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_SITE_ID%TYPE) IS
SELECT party_tax_profile_id
  FROM zx_party_tax_profile
 WHERE party_id = c_party_site_id
   AND party_type_code = 'THIRD_PARTY_SITE';

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
        PARTY.JGZZ_FISCAL_CODE,
        PARTY.TAX_REFERENCE
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

CURSOR cust_acct_cur (c_party_site_id  ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_SITE_ID%TYPE,
                      c_party_id  ZX_REP_TRX_DETAIL_T.BILL_TO_PARTY_ID%TYPE,
                      c_ship_bill varchar2) IS
SELECT acct.account_number,
       acct.global_attribute10,
       acct.global_attribute12,
       acct_site.global_attribute8,
       acct_site.global_attribute9,
       site_use.location,
       site_use.tax_reference
  FROM hz_cust_accounts acct,
       hz_cust_site_uses_all site_use ,
       hz_cust_acct_sites_all acct_site
 WHERE acct.CUST_ACCOUNT_ID =  acct_site.CUST_ACCOUNT_ID
   and acct_site.CUST_ACCT_SITE_ID = site_use.CUST_ACCT_SITE_ID
   and acct_site.PARTY_SITE_ID  = c_party_site_id
  and ACCT.PARTY_ID   = c_party_id
  and site_use.site_use_code = c_ship_bill;

CURSOR party_id_cur (c_cust_acct_id ZX_REP_TRX_DETAIL_T.BILLING_TRADING_PARTNER_ID%TYPE) IS
SELECT acct.party_id
  FROM hz_cust_accounts acct
 WHERE acct.cust_account_id = c_cust_acct_id;

CURSOR party_site_id_cur ( c_cust_site_use_id  ZX_REP_TRX_DETAIL_T.BILLING_TP_SITE_ID%TYPE) IS
SELECT acct_site.party_site_id
  FROM hz_cust_acct_sites_all   acct_site,
       hz_cust_site_uses_all site_use
 WHERE acct_site.cust_acct_site_id = site_use.cust_acct_site_id
   AND site_use.site_use_id  = c_cust_site_use_id;


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

    IF GT_BILL_TO_PARTY_TAX_PROF_ID(i) IS NOT NULL THEN
       OPEN party_id_from_ptp_cur(GT_BILL_TO_PARTY_TAX_PROF_ID(i));
       FETCH party_id_from_ptp_cur INTO l_bill_to_party_id;
       CLOSE party_id_from_ptp_cur;
       l_bill_to_ptp_id := GT_BILL_TO_PARTY_TAX_PROF_ID(i);
    ELSE
       OPEN party_id_cur (GT_BILLING_TP_ID(i));
       FETCH party_id_cur INTO GT_BILL_TO_PARTY_ID(i);
       CLOSE party_id_cur;

       OPEN party_profile_id_cur (GT_BILL_TO_PARTY_ID(i));
       FETCH party_profile_id_cur into GT_BILL_TO_PARTY_TAX_PROF_ID(i);
       CLOSE party_profile_id_cur;
       --l_bill_to_party_id := GT_BILLING_TP_ID(i);
       l_bill_to_party_id := GT_BILL_TO_PARTY_ID(i);
    END IF;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'party_id_cur : l_bill_to_party_id '||to_char(l_bill_to_party_id));
      END IF;

    IF GT_BILL_TO_SITE_TAX_PROF_ID(i) IS NOT NULL THEN
       OPEN party_site_id_from_ptp_cur(GT_BILL_TO_SITE_TAX_PROF_ID(i));
       FETCH party_site_id_from_ptp_cur INTO l_bill_to_site_id;
       CLOSE party_site_id_from_ptp_cur;
       l_bill_to_stp_id := GT_BILL_TO_SITE_TAX_PROF_ID(i);
    ELSE
       OPEN party_site_id_cur (GT_BILLING_TP_SITE_ID(i));
       FETCH party_site_id_cur INTO GT_BILL_TO_PARTY_SITE_ID(i);
       CLOSE party_site_id_cur;

       OPEN site_profile_id_cur(GT_BILL_TO_PARTY_SITE_ID(i));
       FETCH site_profile_id_cur INTO GT_BILL_TO_SITE_TAX_PROF_ID(i);
       CLOSE site_profile_id_cur;
       l_bill_to_site_id := GT_BILL_TO_PARTY_SITE_ID(i);
    END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                  'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                  'party_site_id_cur : l_bill_to_site_id '||to_char(l_bill_to_site_id));
      END IF;

       l_bill_ship := 'BILL_TO';


--    IF GT_BILLING_TP_ID(i) IS NOT NULL AND GT_BILLING_TP_ADDRESS_ID(i) IS NOT NULL THEN

     IF l_bill_to_site_id is not null and  l_bill_to_party_id is not null THEN
        l_tbl_index_cust  := dbms_utility.get_hash_value(to_char(l_bill_to_site_id)||to_char(l_bill_to_party_id)||
                                                                l_bill_ship, 1,8192);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'Before Open cust_acct_cur :'||to_char(l_bill_to_party_id)||'-'||to_char(l_bill_to_site_id));
      END IF;

        IF g_cust_bill_ar_tbl.EXISTS(l_tbl_index_cust) THEN
           GT_BILLING_TP_NUMBER(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_NUMBER  ;
           GT_GDF_RA_CUST_BILL_ATT10(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT10;
           GT_GDF_RA_CUST_BILL_ATT12(i) := g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_BILL_ATT12;
           GT_GDF_RA_ADDRESSES_BILL_ATT8(i) :=g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT8;
           GT_GDF_RA_ADDRESSES_BILL_ATT9(i) :=g_cust_bill_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_BILL_ATT9;
           GT_BILLING_TP_SITE_NAME(i)     := g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_SITE_NAME;
           GT_BILLING_TP_TAX_REG_NUM(i)   := g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_TAX_REG_NUM;
        ELSE
          OPEN cust_acct_cur (l_bill_to_site_id,
                        l_bill_to_party_id,
                        l_bill_ship);
          FETCH cust_acct_cur INTO GT_BILLING_TP_NUMBER(i),
                             GT_GDF_RA_CUST_BILL_ATT10(i),
                             GT_GDF_RA_CUST_BILL_ATT12(i),
                             GT_GDF_RA_ADDRESSES_BILL_ATT8(i),
                             GT_GDF_RA_ADDRESSES_BILL_ATT9(i),
                             GT_BILLING_TP_SITE_NAME(i),
                             GT_BILLING_TP_TAX_REG_NUM(i);

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
           g_cust_bill_ar_tbl(l_tbl_index_cust).BILLING_TP_TAX_REG_NUM := GT_BILLING_TP_TAX_REG_NUM(i);

             CLOSE cust_acct_cur;
        END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_cust_bill_ar_tbl ');
        END IF;

       l_tbl_index_party := dbms_utility.get_hash_value(to_char(l_bill_to_party_id)||
                                                                l_bill_ship, 1,8192);
       IF g_party_bill_ar_tbl.EXISTS(l_tbl_index_party) THEN

          GT_BILLING_TP_NAME_ALT(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT;
          GT_BILLING_TP_NAME(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME;
          GT_BILLING_TP_SIC_CODE(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE;
          GT_BILLING_TP_NUMBER(i) := g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER;
       ELSE
          OPEN party_cur (l_bill_to_party_id);
          FETCH party_cur INTO GT_BILLING_TP_NAME(i),
                        GT_BILLING_TP_NAME_ALT(i),
                        GT_BILLING_TP_SIC_CODE(i),
                        GT_BILLING_TP_NUMBER(i),
                        GT_BILLING_TP_TAXPAYER_ID(i),
                        GT_BILLING_TP_TAX_REG_NUM(i);

         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT := GT_BILLING_TP_NAME_ALT(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NAME := GT_BILLING_TP_NAME(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE := GT_BILLING_TP_SIC_CODE(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER := GT_BILLING_TP_NUMBER(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_TAXPAYER_ID := GT_BILLING_TP_TAXPAYER_ID(i);
         g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_TAX_REG_NUM := GT_BILLING_TP_TAX_REG_NUM(i);

       CLOSE party_cur;
       END IF;



        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_party_bill_ar_tbl '||g_party_bill_ar_tbl(l_tbl_index_party).BILLING_TP_NUMBER);
        END IF;
       l_tbl_index_site := dbms_utility.get_hash_value(to_char(l_bill_to_site_id)||
                                                                l_bill_ship, 1,8192);

     IF g_site_bill_ar_tbl.EXISTS(l_tbl_index_site) THEN
        GT_BILLING_TP_CITY(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_CITY;
        GT_BILLING_TP_COUNTY(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_COUNTY;
        GT_BILLING_TP_STATE(i)  := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_STATE;
        GT_BILLING_TP_PROVINCE(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_PROVINCE;
        GT_BILLING_TP_ADDRESS1(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS1;
        GT_BILLING_TP_ADDRESS2(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS2;
        GT_BILLING_TP_ADDRESS3(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS3;
        GT_BILLING_TP_ADDR_LINES_ALT(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDR_LINES_ALT;
        GT_BILLING_TP_COUNTRY(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_COUNTRY;
        GT_BILLING_TP_POSTAL_CODE(i) := g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_POSTAL_CODE;
     ELSE
        OPEN party_site_cur (l_bill_to_site_id);
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

       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_CITY := GT_BILLING_TP_CITY(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_COUNTY := GT_BILLING_TP_COUNTY(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_STATE := GT_BILLING_TP_STATE(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_PROVINCE := GT_BILLING_TP_PROVINCE(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS1 := GT_BILLING_TP_ADDRESS1(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS2 := GT_BILLING_TP_ADDRESS2(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDRESS3 := GT_BILLING_TP_ADDRESS3(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_ADDR_LINES_ALT := GT_BILLING_TP_ADDR_LINES_ALT(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_COUNTRY := GT_BILLING_TP_COUNTRY(i);
       g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_POSTAL_CODE := GT_BILLING_TP_POSTAL_CODE(i);
      CLOSE party_site_cur;
      END IF;



       IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_site_bill_ar_tbl '||g_site_bill_ar_tbl(l_tbl_index_site).BILLING_TP_CITY);
        END IF;
    END IF;

         -- Ship to party information ----
         ---------------------------------
    IF GT_SHIP_TO_PARTY_TAX_PROF_ID(i) IS NOT NULL THEN
       OPEN party_id_from_ptp_cur(GT_SHIP_TO_PARTY_TAX_PROF_ID(i));
       FETCH party_id_from_ptp_cur INTO l_ship_to_party_id;
       CLOSE party_id_from_ptp_cur;
       l_ship_to_ptp_id := GT_SHIP_TO_PARTY_TAX_PROF_ID(i);
    ELSE
       OPEN party_id_cur (GT_SHIPPING_TP_ID(i));
       FETCH party_id_cur INTO GT_SHIP_TO_PARTY_ID(i);
       CLOSE party_id_cur;

       OPEN party_profile_id_cur (GT_SHIP_TO_PARTY_ID(i));
       FETCH party_profile_id_cur into l_ship_to_ptp_id;
       CLOSE party_profile_id_cur;
       --l_ship_to_party_id := GT_SHIPPING_TP_ID(i);
       l_ship_to_party_id := GT_SHIP_TO_PARTY_ID(i);
    END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'party_id_cur : l_ship_to_party_id '||to_char(l_ship_to_party_id));
      END IF;

    IF GT_SHIP_TO_SITE_TAX_PROF_ID(i) IS NOT NULL THEN
       OPEN party_site_id_from_ptp_cur(GT_SHIP_TO_SITE_TAX_PROF_ID(i));
       FETCH party_site_id_from_ptp_cur INTO l_ship_to_site_id;
       CLOSE party_site_id_from_ptp_cur;
       l_ship_to_stp_id := GT_SHIP_TO_SITE_TAX_PROF_ID(i);
    ELSE
       OPEN party_site_id_cur (GT_SHIPPING_TP_SITE_ID(i));
       FETCH party_site_id_cur INTO GT_SHIP_TO_PARTY_SITE_ID(i);
       CLOSE party_site_id_cur;

       OPEN site_profile_id_cur(GT_SHIP_TO_PARTY_SITE_ID(i));
       FETCH site_profile_id_cur INTO l_ship_to_stp_id;
       CLOSE site_profile_id_cur;
       --l_ship_to_site_id := GT_SHIPPING_TP_SITE_ID(i);
       l_ship_to_site_id := GT_SHIP_TO_PARTY_SITE_ID(i);
    END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                  'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                  'party_site_id_cur : l_ship_to_site_id '||to_char(l_ship_to_site_id));
      END IF;




       l_bill_ship := 'SHIP_TO';


--    IF GT_SHIPPING_TP_ID(i) IS NOT NULL AND GT_SHIPPING_TP_ADDRESS_ID(i) IS NOT NULL THEN


    IF l_ship_to_site_id is not null and  l_ship_to_party_id is not null THEN
       l_tbl_index_cust  := dbms_utility.get_hash_value(to_char(l_ship_to_site_id)||(l_ship_to_party_id)||
                                                                l_bill_ship, 1,8192);

        IF g_cust_ship_ar_tbl.EXISTS(l_tbl_index_cust) THEN
           GT_SHIPPING_TP_NUMBER(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER  ;
           GT_GDF_RA_CUST_SHIP_ATT10(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT10;
           GT_GDF_RA_CUST_SHIP_ATT12(i) := g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT12;
           GT_GDF_RA_ADDRESSES_SHIP_ATT8(i) :=g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT8;
           GT_GDF_RA_ADDRESSES_SHIP_ATT9(i) :=g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT9;
           GT_SHIPPING_TP_SITE_NAME(i)     := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_SITE_NAME;
           GT_SHIPPING_TP_TAX_REG_NUM(i)   := g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_TAX_REG_NUM;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
         'Exists in the cache g_cust_ship_ar_tbl '||g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER);
        END IF;

        ELSE
          OPEN cust_acct_cur (l_ship_to_site_id,
                        l_ship_to_party_id,
                        l_bill_ship);
          FETCH cust_acct_cur INTO GT_SHIPPING_TP_NUMBER(i),
                             GT_GDF_RA_CUST_SHIP_ATT10(i),
                             GT_GDF_RA_CUST_SHIP_ATT12(i),
                             GT_GDF_RA_ADDRESSES_SHIP_ATT8(i),
                             GT_GDF_RA_ADDRESSES_SHIP_ATT9(i),
                             GT_SHIPPING_TP_SITE_NAME(i),
                             GT_SHIPPING_TP_TAX_REG_NUM(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER := GT_SHIPPING_TP_NUMBER(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT10 := GT_GDF_RA_CUST_SHIP_ATT10(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_CUST_SHIP_ATT12 := GT_GDF_RA_CUST_SHIP_ATT12(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT8 := GT_GDF_RA_ADDRESSES_SHIP_ATT8(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).GDF_RA_ADDRESSES_SHIP_ATT9 := GT_GDF_RA_ADDRESSES_SHIP_ATT9(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_SITE_NAME := GT_SHIPPING_TP_SITE_NAME(i);
           g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_TAX_REG_NUM := GT_SHIPPING_TP_TAX_REG_NUM(i);

        CLOSE cust_acct_cur;
        END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_cust_ship_ar_tbl '||g_cust_ship_ar_tbl(l_tbl_index_cust).SHIPPING_TP_NUMBER);
        END IF;

        l_tbl_index_party  := dbms_utility.get_hash_value(to_char(l_ship_to_party_id)||
                                                                l_bill_ship, 1,8192);
       IF g_party_ship_ar_tbl.EXISTS(l_tbl_index_party) THEN

          GT_SHIPPING_TP_NAME_ALT(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME_ALT;
          GT_SHIPPING_TP_NAME(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME;
          GT_SHIPPING_TP_SIC_CODE(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_SIC_CODE;
          GT_SHIPPING_TP_NUMBER(i) := g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NUMBER;
       ELSE
          OPEN party_cur (l_ship_to_party_id);
          FETCH party_cur INTO GT_SHIPPING_TP_NAME(i),
                        GT_SHIPPING_TP_NAME_ALT(i),
                        GT_SHIPPING_TP_SIC_CODE(i),
                        GT_SHIPPING_TP_NUMBER(i),
	GT_SHIPPING_TP_TAXPAYER_ID(i),
 	GT_SHIPPING_TP_TAX_REG_NUM(i);

         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME_ALT := GT_SHIPPING_TP_NAME_ALT(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME := GT_SHIPPING_TP_NAME(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_SIC_CODE := GT_SHIPPING_TP_SIC_CODE(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NUMBER := GT_SHIPPING_TP_NUMBER(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_TAXPAYER_ID := GT_SHIPPING_TP_TAXPAYER_ID(i);
         g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_TAX_REG_NUM := GT_SHIPPING_TP_TAX_REG_NUM(i);

       CLOSE party_cur;
       END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                      'After assign to g_party_ship_ar_tbl '||g_party_ship_ar_tbl(l_tbl_index_party).SHIPPING_TP_NAME);
        END IF;

      l_tbl_index_site  := dbms_utility.get_hash_value(to_char(l_ship_to_site_id)||
                                                                l_bill_ship, 1,8192);
     IF g_site_ship_ar_tbl.EXISTS(l_tbl_index_site) THEN
        GT_SHIPPING_TP_CITY(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_CITY;
        GT_SHIPPING_TP_COUNTY(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_COUNTY;
        GT_SHIPPING_TP_STATE(i)  := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_STATE;
        GT_SHIPPING_TP_PROVINCE(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_PROVINCE;
        GT_SHIPPING_TP_ADDRESS1(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS1;
        GT_SHIPPING_TP_ADDRESS2(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS2;
        GT_SHIPPING_TP_ADDRESS3(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS3;
        GT_SHIPPING_TP_ADDR_LINES_ALT(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDR_LINES_ALT;
        GT_SHIPPING_TP_COUNTRY(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_COUNTRY;
        GT_SHIPPING_TP_POSTAL_CODE(i) := g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_POSTAL_CODE;
     ELSE
        OPEN party_site_cur (l_ship_to_site_id);
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
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_CITY := GT_SHIPPING_TP_CITY(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_COUNTY := GT_SHIPPING_TP_COUNTY(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_STATE := GT_SHIPPING_TP_STATE(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_PROVINCE := GT_SHIPPING_TP_PROVINCE(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS1 := GT_SHIPPING_TP_ADDRESS1(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS2 := GT_SHIPPING_TP_ADDRESS2(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDRESS3 := GT_SHIPPING_TP_ADDRESS3(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_ADDR_LINES_ALT := GT_SHIPPING_TP_ADDR_LINES_ALT(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_COUNTRY := GT_SHIPPING_TP_COUNTRY(i);
       g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_POSTAL_CODE := GT_SHIPPING_TP_POSTAL_CODE(i);
      CLOSE party_site_cur;
      END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                     'ZX.TRL.ZX_AR_POPULATE_PKG.EXTRACT_PARTY_INFO',
                   'After assign to g_site_ship_ar_tbl '||g_site_ship_ar_tbl(l_tbl_index_site).SHIPPING_TP_CITY);
        END IF;

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

PROCEDURE populate_meaning(
           P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           i BINARY_INTEGER)
IS
   l_description      VARCHAR2(240);
   l_meaning          VARCHAR2(80);
BEGIN

     IF GT_TRX_CLASS(i) IS NOT NULL THEN
        ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_TRANSACTION_CLASS_TYPE',
                             GT_TRX_CLASS(i),
                             l_meaning,
                             l_description);
        GT_TRX_CLASS_MNG(i) := l_meaning;
     END IF;

     IF  P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE IS NOT NULL THEN
         ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_REGISTER_TYPE',
                              P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE,
                             l_meaning,
                             l_description);

         GT_TAX_RATE_CODE_REG_TYPE_MNG(i) := l_meaning;
     END IF;

     IF  GT_TAX_RATE_VAT_TRX_TYPE_CODE(i) IS NOT NULL THEN
         ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_VAT_TRANSACTION_TYPE',
                              GT_TAX_RATE_VAT_TRX_TYPE_CODE(i),
                             l_meaning,
                             l_description);
         GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) := l_description;
     END IF;

     IF GT_TAX_EXCEPTION_REASON_CODE(i) IS NOT NULL THEN
        ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_EXCEPTION_REASON',
                              GT_TAX_EXCEPTION_REASON_CODE(i),
                             l_meaning,
                             l_description);

        GT_TAX_EXCEPTION_REASON_MNG(i) := l_meaning;
     END IF;

     IF GT_EXEMPT_REASON_CODE(i) IS NOT NULL THEN
        ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_EXEMPTION_REASON',
                              GT_EXEMPT_REASON_CODE(i),
                             l_meaning,
                             l_description);

        GT_TAX_EXEMPT_REASON_MNG(i) := l_meaning;
     END IF;

END populate_meaning;

PROCEDURE UPDATE_REP_DETAIL_T(p_count IN NUMBER) IS
i number;
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_DETAIL_T.BEGIN',
                                      'ZX_AR_ACTG_POPULATE_PKG: UPDATE_REP_DETAIL_T(+)');
    END IF;

FORALL i in 1..p_count
UPDATE ZX_REP_TRX_DETAIL_T SET
      REP_CONTEXT_ID                =      G_REP_CONTEXT_ID,
      BILLING_TP_NUMBER             =      GT_BILLING_TP_NUMBER(i),
      BILLING_TP_TAX_REG_NUM        =      GT_BILLING_TP_TAX_REG_NUM(i),
      BILLING_TP_TAXPAYER_ID        =      GT_BILLING_TP_TAXPAYER_ID(i),
      BILLING_TP_SITE_NAME_ALT      =      GT_BILLING_TP_SITE_NAME_ALT(i),
      BILLING_TP_NAME               =      GT_BILLING_TP_NAME(i),
      BILLING_TP_NAME_ALT           =      GT_BILLING_TP_NAME_ALT(i),
      BILLING_TP_SIC_CODE           =      GT_BILLING_TP_SIC_CODE(i),
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
      SHIPPING_TP_TAX_REG_NUM       =      GT_SHIPPING_TP_TAX_REG_NUM(i),
      SHIPPING_TP_TAXPAYER_ID       =      GT_SHIPPING_TP_TAXPAYER_ID(i),
--      SHIPPING_TP_SITE_NAME_ALT     =      GT_SHIPPING_TP_SITE_NAME_ALT(i),
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
--      SHIPPING_TP_ADDR_LINES_ALT =      GT_SHIPPING_TP_ADDR_LINES_ALT(i),
      SHIPPING_TP_COUNTRY           =      GT_SHIPPING_TP_COUNTRY(i),
      SHIPPING_TP_POSTAL_CODE       =      GT_SHIPPING_TP_POSTAL_CODE(i),
--      SHIPPING_TP_PARTY_NUMBER      =      GT_SHIPPING_TP_PARTY_NUMBER(i),
  --    SHIPPING_TRADING_PARTNER_ID   =      GT_SHIPPING_TRADING_PARTNER_ID(i),
      SHIPPING_TP_SITE_ID           =      GT_SHIPPING_TP_SITE_ID(i),
      SHIPPING_TP_ADDRESS_ID        =      GT_SHIPPING_TP_ADDRESS_ID(i),
   --   SHIPPING_TP_TAX_REP_FLAG =      GT_SHIPPING_TP_TAX_REP_FLAG(i),
      SHIPPING_TP_SITE_NAME          =      GT_SHIPPING_TP_SITE_NAME(i),
      GDF_RA_ADDRESSES_SHIP_ATT9     =      GT_GDF_RA_ADDRESSES_SHIP_ATT9(i),
      GDF_PARTY_SITES_SHIP_ATT8      =      GT_GDF_PARTY_SITES_SHIP_ATT8(i),
      GDF_RA_CUST_SHIP_ATT10         =      GT_GDF_RA_CUST_SHIP_ATT10(i),
      GDF_RA_CUST_SHIP_ATT12         =      GT_GDF_RA_CUST_SHIP_ATT12(i),
      GDF_RA_ADDRESSES_SHIP_ATT8     =      GT_GDF_RA_ADDRESSES_SHIP_ATT8(i),
      TRX_CLASS_MNG                  =      GT_TRX_CLASS_MNG(i),
      TAX_RATE_CODE_REG_TYPE_MNG     =      GT_TAX_RATE_CODE_REG_TYPE_MNG(i),
      TAX_RATE_VAT_TRX_TYPE_DESC     =      GT_TAX_RATE_VAT_TRX_TYPE_DESC(i),
      TAXABLE_AMT                    =      GT_TAXABLE_AMT(i),
      TAXABLE_AMT_FUNCL_CURR         =      GT_TAXABLE_AMT_FUNCL_CURR(i),
      TAX_AMT                        =      GT_TAX_AMT(i),
      TAX_AMT_FUNCL_CURR             =      GT_TAX_AMT_FUNCL_CURR(i)
   WHERE DETAIL_TAX_LINE_ID = GT_DETAIL_TAX_LINE_ID(i);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_DETAIL_T.END',
                                      'ZX_AR_ACTG_POPULATE_PKG: UPDATE_REP_DETAIL_T(-)');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_DETAIL_T',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;

END UPDATE_REP_DETAIL_T;

PROCEDURE UPDATE_REP_ACTG_T(p_count IN NUMBER) IS
i number;
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_ACTG_T.BEGIN',
                                      'ZX_AR_ACTG_POPULATE_PKG: UPDATE_REP_ACTG_T(+)');
    END IF;

FORALL i in 1..p_count
UPDATE zx_rep_actg_ext_t SET
       TRX_ARAP_BALANCING_SEGMENT    =  GT_TRX_ARAP_BALANCING_SEGMENT(i),
       TRX_ARAP_NATURAL_ACCOUNT      =  GT_TRX_ARAP_NATURAL_ACCOUNT(i),
       TRX_TAXABLE_BALANCING_SEGMENT = GT_TRX_TAXABLE_BAL_SEG(i),
       TRX_TAXABLE_NATURAL_ACCOUNT   =  GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),
       TRX_TAX_BALANCING_SEGMENT     =  GT_TRX_TAX_BALANCING_SEGMENT(i),
       TRX_TAX_NATURAL_ACCOUNT       =  GT_TRX_TAX_NATURAL_ACCOUNT(i)
   WHERE DETAIL_TAX_LINE_ID = GT_DETAIL_TAX_LINE_ID(i);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_ACTG__T.END',
                                      'ZX_AR_ACTG_POPULATE_PKG: UPDATE_REP_ACTG_T(-)');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_ACTG_T',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;

END UPDATE_REP_ACTG_T;

PROCEDURE initialize_variables (
          p_count   IN         NUMBER) IS
i number;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.initialize_variables.BEGIN',
                                      'ZX_AR_ACTG_POPULATE_PKG: initialize_variables(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.initialize_variables',
                                      'p_count : '||to_char(p_count));
    END IF;

  FOR i IN 1.. p_count LOOP
-- apai     GT_REP_CONTEXT_ID(i)          := NULL;
      GT_BILLING_TP_NUMBER(i)          := NULL;
      GT_BILLING_TP_TAX_REG_NUM(i)          := NULL;
      GT_BILLING_TP_TAXPAYER_ID(i)          := NULL;
      GT_BILLING_TP_SITE_NAME_ALT(i)          := NULL;
      GT_BILLING_TP_NAME(i)          := NULL;
      GT_BILLING_TP_NAME_ALT(i)          := NULL;
      GT_BILLING_TP_SIC_CODE(i)          := NULL;
      GT_BILLING_TP_CITY(i)          := NULL;
      GT_BILLING_TP_COUNTY(i)          := NULL;
      GT_BILLING_TP_STATE(i)          := NULL;
      GT_BILLING_TP_PROVINCE(i)          := NULL;
      GT_BILLING_TP_ADDRESS1(i)          := NULL;
      GT_BILLING_TP_ADDRESS2(i)          := NULL;
      GT_BILLING_TP_ADDRESS3(i)          := NULL;
      GT_BILLING_TP_ADDR_LINES_ALT(i)          := NULL;
      GT_BILLING_TP_COUNTRY(i)          := NULL;
      GT_BILLING_TP_POSTAL_CODE(i)          := NULL;
      GT_BILLING_TP_PARTY_NUMBER(i)          := NULL;
    --  GT_BILLING_TP_ID(i)          := NULL;
     -- GT_BILLING_TP_SITE_ID(i)          := NULL;
     -- GT_BILLING_TP_ADDRESS_ID(i)          := NULL;
--    GT_BILLING_TP_TAX_REP_FLAG(i)          := NULL;
      GT_BILLING_TP_SITE_NAME(i)          := NULL;
      GT_GDF_RA_ADDRESSES_BILL_ATT9(i)          := NULL;
      GT_GDF_PARTY_SITES_BILL_ATT8(i)          := NULL;
      GT_GDF_RA_CUST_BILL_ATT10(i)          := NULL;
      GT_GDF_RA_CUST_BILL_ATT12(i)          := NULL;
      GT_GDF_RA_ADDRESSES_BILL_ATT8(i)          := NULL;
      GT_SHIPPING_TP_NUMBER(i)          := NULL;
      GT_SHIPPING_TP_TAX_REG_NUM(i)          := NULL;
      GT_SHIPPING_TP_TAXPAYER_ID(i)          := NULL;
--    GT_SHIPPING_TP_SITE_NAME_ALT(i)          := NULL;
      GT_SHIPPING_TP_NAME(i)          := NULL;
      GT_SHIPPING_TP_NAME_ALT(i)          := NULL;
      GT_SHIPPING_TP_SIC_CODE(i)          := NULL;
      GT_SHIPPING_TP_CITY(i)          := NULL;
      GT_SHIPPING_TP_COUNTY(i)          := NULL;
      GT_SHIPPING_TP_STATE(i)          := NULL;
      GT_SHIPPING_TP_PROVINCE(i)          := NULL;
      GT_SHIPPING_TP_ADDRESS1(i)          := NULL;
      GT_SHIPPING_TP_ADDRESS2(i)          := NULL;
      GT_SHIPPING_TP_ADDRESS3(i)          := NULL;
--    GT_SHIPPING_TP_ADDR_LINES_ALT(i)          := NULL;
      GT_SHIPPING_TP_COUNTRY(i)          := NULL;
      GT_SHIPPING_TP_POSTAL_CODE(i)          := NULL;
--    GT_SHIPPING_TP_PARTY_NUMBER(i)          := NULL;
  --  GT_SHIPPING_TRADING_PARTNER_ID(i)          := NULL;
    --  GT_SHIPPING_TP_SITE_ID(i)          := NULL;
   --   GT_SHIPPING_TP_ADDRESS_ID(i)          := NULL;
   -- GT_SHIPPING_TP_TAX_REP_FLAG(i)          := NULL;
      GT_SHIPPING_TP_SITE_NAME(i)          := NULL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT9(i)          := NULL;
      GT_GDF_PARTY_SITES_SHIP_ATT8(i)          := NULL;
      GT_GDF_RA_CUST_SHIP_ATT10(i)          := NULL;
      GT_GDF_RA_CUST_SHIP_ATT12(i)          := NULL;
      GT_GDF_RA_ADDRESSES_SHIP_ATT8(i)          := NULL;
      GT_TRX_CLASS_MNG(i)          := NULL;
      GT_TAX_RATE_CODE_REG_TYPE_MNG(i)          := NULL;
      GT_TAX_RATE_VAT_TRX_TYPE_DESC(i)          := NULL;
-- New --
GT_BILLING_TP_NUMBER(i)       := NULL;
GT_GDF_RA_CUST_BILL_ATT10(i)  := NULL;
GT_GDF_RA_CUST_BILL_ATT12(i)  := NULL;
GT_GDF_RA_ADDRESSES_BILL_ATT8(i)  := NULL;
GT_GDF_RA_ADDRESSES_BILL_ATT9(i)  := NULL;
GT_BILLING_TP_SITE_NAME(i)        := NULL;
GT_BILLING_TP_TAX_REG_NUM(i)      := NULL;
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

   END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.initialize_variables.END',
                                      'ZX_AR_ACTG_POPULATE_PKG: initialize_variables(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.initialize_variables',
                      g_error_buffer);
    END IF;

END initialize_variables ;

END ZX_AR_ACTG_POPULATE_PKG;

/
