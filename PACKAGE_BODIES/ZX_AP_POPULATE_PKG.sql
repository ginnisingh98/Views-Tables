--------------------------------------------------------
--  DDL for Package Body ZX_AP_POPULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_AP_POPULATE_PKG" AS
/* $Header: zxrippopulatpvtb.pls 120.35.12010000.31 2010/04/23 08:11:46 bibeura ship $ */
  --Populate variables
  GT_TRX_CLASS_MNG                  ZX_EXTRACT_PKG.TRX_CLASS_MNG_TBL;
  GT_TAX_RATE_CODE_REG_TYPE_MNG     ZX_EXTRACT_PKG.TAX_RATE_CODE_REG_TYPE_MNG_TBL;
  GT_TAX_RATE_REG_TYPE_CODE         ZX_EXTRACT_PKG.TAX_RATE_REG_TYPE_CODE_TBL;
  GT_TAX_RECOVERABLE_FLAG           ZX_EXTRACT_PKG.TAX_RECOVERABLE_FLAG_TBL;
  GT_TRX_QUANTITY_UOM_MNG           ZX_EXTRACT_PKG.TRX_QUANTITY_UOM_MNG_TBL;
  GT_TAXABLE_DISC_AMT               ZX_EXTRACT_PKG.TAXABLE_DISC_AMT_TBL;
  GT_TAXABLE_DISC_AMT_FUNCL_CURR    ZX_EXTRACT_PKG.TAXABLE_DISC_AMT_FUN_CURR_TBL;
  GT_TAX_DISC_AMT                   ZX_EXTRACT_PKG.TAX_DISC_AMT_TBL;
  GT_TAX_DISC_AMT_FUNCL_CURR        ZX_EXTRACT_PKG.TAX_DISC_AMT_FUN_CURR_TBL;
  GT_TAX_RATE_VAT_TRX_TYPE_DESC     ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_DESC_TBL;
  GT_TAX_RATE_VAT_TRX_TYPE_MNG      ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_MNG_TBL;
  GT_BILLING_TP_NAME_ALT            ZX_EXTRACT_PKG.BILLING_TP_NAME_ALT_TBL;
  GT_BILLING_TP_SIC_CODE            ZX_EXTRACT_PKG.BILLING_TP_SIC_CODE_TBL;
  GT_BILLING_TP_CITY                ZX_EXTRACT_PKG.BILLING_TP_CITY_TBL;
  GT_BILLING_TP_COUNTY              ZX_EXTRACT_PKG.BILLING_TP_COUNTY_TBL;
  GT_BILLING_TP_STATE               ZX_EXTRACT_PKG.BILLING_TP_STATE_TBL;
  GT_BILLING_TP_PROVINCE            ZX_EXTRACT_PKG.BILLING_TP_PROVINCE_TBL;
  GT_BILLING_TP_ADDRESS1            ZX_EXTRACT_PKG.BILLING_TP_ADDRESS1_TBL;
  GT_BILLING_TP_ADDRESS2            ZX_EXTRACT_PKG.BILLING_TP_ADDRESS2_TBL;
  GT_BILLING_TP_ADDRESS3            ZX_EXTRACT_PKG.BILLING_TP_ADDRESS3_TBL;
  GT_BILLING_TP_ADDR_LINES_ALT      ZX_EXTRACT_PKG.BILLING_TP_ADDR_LINES_ALT_TBL;
  GT_BILLING_TP_COUNTRY             ZX_EXTRACT_PKG.BILLING_TP_COUNTRY_TBL;
  GT_BILLING_TP_POSTAL_CODE         ZX_EXTRACT_PKG.BILLING_TP_POSTAL_CODE_TBL;
  GT_SHIPPING_TP_CITY               ZX_EXTRACT_PKG.SHIPPING_TP_CITY_TBL;
  GT_SHIPPING_TP_COUNTY             ZX_EXTRACT_PKG.SHIPPING_TP_COUNTY_TBL;
  GT_SHIPPING_TP_STATE              ZX_EXTRACT_PKG.SHIPPING_TP_STATE_TBL;
  GT_SHIPPING_TP_ADDRESS1           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS1_TBL;
  GT_SHIPPING_TP_ADDRESS2           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS2_TBL;
  GT_SHIPPING_TP_ADDRESS3           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS3_TBL;
  GT_SHIPPING_TP_COUNTRY            ZX_EXTRACT_PKG.SHIPPING_TP_COUNTRY_TBL;
  GT_SHIPPING_TP_POSTAL_CODE        ZX_EXTRACT_PKG.SHIPPING_TP_POSTAL_CODE_TBL;
  --GT_BILLING_TRADING_PARTNER_ID     ZX_EXTRACT_PKG.BILLING_TRADING_PARTNER_ID_TBL;
  --GT_BILLING_TP_SITE_ID             ZX_EXTRACT_PKG.BILLING_TP_SITE_ID_TBL;
  GT_BILLING_TP_TAX_REP_FLAG        ZX_EXTRACT_PKG.BILLING_TP_TAX_REP_FLAG_TBL;
  GT_OFFICE_SITE_FLAG               ZX_EXTRACT_PKG.OFFICE_SITE_FLAG_TBL;
  GT_REGISTRATION_STATUS_CODE       ZX_EXTRACT_PKG.REGISTRATION_STATUS_CODE_TBL;
  GT_BILLING_TP_NUMBER              ZX_EXTRACT_PKG.BILLING_TP_NUMBER_TBL;
  GT_BILLING_TP_TAX_REG_NUM         ZX_EXTRACT_PKG.BILLING_TP_TAX_REG_NUM_TBL;
  GT_BILLING_TP_TAXPAYER_ID         ZX_EXTRACT_PKG.BILLING_TP_TAXPAYER_ID_TBL;
  GT_BILLING_TP_SITE_NAME_ALT       ZX_EXTRACT_PKG.BILLING_TP_SITE_NAME_ALT_TBL;
  GT_BILLING_TP_SITE_NAME           ZX_EXTRACT_PKG.BILLING_TP_SITE_NAME_ALT_TBL;
  GT_BILLING_SITE_TAX_REG_NUM       ZX_EXTRACT_PKG.BILLING_TP_SITE_TX_REG_NUM_TBL;

  GT_BILLING_TP_NAME                ZX_EXTRACT_PKG.BILLING_TP_NAME_TBL;
  GT_SHIPPING_TP_NAME_ALT           ZX_EXTRACT_PKG.BILLING_TP_NAME_ALT_TBL;
  GT_SHIPPING_TP_SIC_CODE           ZX_EXTRACT_PKG.BILLING_TP_SIC_CODE_TBL;
  GT_GDF_PO_VENDOR_SITE_ATT17       ZX_EXTRACT_PKG.GDF_PO_VENDOR_SITE_ATT17_TBL;
  GT_LEDGER_ID                      ZX_EXTRACT_PKG.LEDGER_ID_TBL;
  GT_LEDGER_NAME                    ZX_EXTRACT_PKG.LEDGER_NAME_TBL;

  --Gloabl variables to fetch detail cursor
  GT_DETAIL_TAX_LINE_ID             ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
  GT_APPLICATION_ID                 ZX_EXTRACT_PKG.APPLICATION_ID_TBL;
  GT_ENTITY_CODE                    ZX_EXTRACT_PKG.ENTITY_CODE_TBL;
  GT_EVENT_CLASS_CODE               ZX_EXTRACT_PKG.EVENT_CLASS_CODE_TBL;
  GT_TRX_LEVEL_TYPE                 ZX_EXTRACT_PKG.TRX_LEVEL_TYPE_TBL;
  GT_INTERNAL_ORGANIZATION_ID       ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL;
  GT_TAX_DATE                       ZX_EXTRACT_PKG.TAX_DATE_TBL;
  GT_TRX_ID                         ZX_EXTRACT_PKG.TRX_ID_TBL;
  GT_TRX_LINE_ID                    ZX_EXTRACT_PKG.TRX_LINE_ID_TBL;
  GT_TRX_LINE_DIST_ID               ZX_EXTRACT_PKG.TAXABLE_ITEM_SOURCE_ID_TBL;
  GT_TAX_LINE_ID                    ZX_EXTRACT_PKG.TAX_LINE_ID_TBL;
  GT_TRX_LINE_TYPE                  ZX_EXTRACT_PKG.TRX_LINE_TYPE_TBL;
  GT_TRX_LINE_CLASS                 ZX_EXTRACT_PKG.TRX_LINE_CLASS_TBL;
  GT_TAX_RATE_VAT_TRX_TYPE_CODE     ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_CODE_TBL;
  GT_SHIP_TO_PARTY_TAX_PROF_ID      ZX_EXTRACT_PKG.SHIP_TO_PARTY_TAX_PROF_ID_TBL;
  GT_SHIP_FROM_PTY_TAX_PROF_ID      ZX_EXTRACT_PKG.SHIP_FROM_PTY_TAX_PROF_ID_TBL;
  GT_BILL_TO_PARTY_TAX_PROF_ID      ZX_EXTRACT_PKG.BILL_TO_PARTY_TAX_PROF_ID_TBL;
  GT_BILL_FROM_PTY_TAX_PROF_ID      ZX_EXTRACT_PKG.BILL_FROM_PTY_TAX_PROF_ID_TBL;
  GT_SHIP_TO_SITE_TAX_PROF_ID       ZX_EXTRACT_PKG.SHIP_TO_SITE_TAX_PROF_ID_TBL;
  GT_BILL_TO_SITE_TAX_PROF_ID       ZX_EXTRACT_PKG.BILL_TO_SITE_TAX_PROF_ID_TBL;
  GT_SHIP_FROM_SITE_TAX_PROF_ID     ZX_EXTRACT_PKG.SHIP_FROM_SITE_TAX_PROF_ID_TBL;
  GT_BILL_FROM_SITE_TAX_PROF_ID     ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL;
  GT_BILL_FROM_PARTY_ID             ZX_EXTRACT_PKG.BILL_FROM_PARTY_ID_TBL;
  GT_BILL_FROM_PARTY_SITE_ID        ZX_EXTRACT_PKG.BILL_FROM_PARTY_SITE_ID_TBL;
  GT_SHIPPING_TP_ID                 ZX_EXTRACT_PKG.SHIPPING_TP_ID_TBL;
  GT_BILLING_TRADING_PARTNER_ID     ZX_EXTRACT_PKG.BILLING_TRADING_PARTNER_ID_TBL;
  GT_BILLING_TP_SITE_ID             ZX_EXTRACT_PKG.BILLING_TP_SITE_ID_TBL;
  GT_SHIPPING_TP_SITE_ID            ZX_EXTRACT_PKG.SHIPPING_TP_SITE_ID_TBL;
  GT_BILLING_TP_ADDRESS_ID          ZX_EXTRACT_PKG.BILLING_TP_ADDRESS_ID_TBL;
  GT_SHIPPING_TP_ADDRESS_ID         ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL;
  GT_HISTORICAL_FLAG                ZX_EXTRACT_PKG.HISTORICAL_FLAG_TBL;
  GT_POSTED_FLAG                    ZX_EXTRACT_PKG.POSTED_FLAG_TBL;
  GT_TAX_RATE_ID                    ZX_EXTRACT_PKG.TAX_RATE_ID_TBL;
  GT_TAX_REGIME_CODE                ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL;
  GT_TAX_STATUS_CODE                ZX_EXTRACT_PKG.TAX_STATUS_CODE_TBL;
  GT_TAX                            ZX_EXTRACT_PKG.TAX_TBL;

  -- apai GT_REP_CONTEXT_ID                 ZX_EXTRACT_PKG.REP_CONTEXT_ID_TBL;
  G_FUN_CURRENCY_CODE               gl_ledgers.currency_code%TYPE;

  GT_TAX_REG_NUM                    ZX_EXTRACT_PKG.HQ_ESTB_REG_NUMBER_TBL;
  GT_HQ_ESTB_REG_NUMBER             ZX_EXTRACT_PKG.HQ_ESTB_REG_NUMBER_TBL;


--Accounting global variables declaration --
  GT_ACTG_EXT_LINE_ID          ZX_EXTRACT_PKG.ACTG_EXT_LINE_ID_TBL;
  GT_ACTG_EVENT_TYPE_CODE      ZX_EXTRACT_PKG.ACTG_EVENT_TYPE_CODE_TBL;
  GT_ACTG_EVENT_NUMBER         ZX_EXTRACT_PKG.ACTG_EVENT_NUMBER_TBL;
  GT_ACTG_EVENT_STATUS_FLAG    ZX_EXTRACT_PKG.ACTG_EVENT_STATUS_FLAG_TBL;
  GT_ACTG_CATEGORY_CODE        ZX_EXTRACT_PKG.ACTG_CATEGORY_CODE_TBL;
  GT_ACCOUNTING_DATE           ZX_EXTRACT_PKG.ACCOUNTING_DATE_TBL;
  GT_GL_TRANSFER_FLAG          ZX_EXTRACT_PKG.GL_TRANSFER_FLAG_TBL;
  GT_GL_TRANSFER_RUN_ID        ZX_EXTRACT_PKG.GL_TRANSFER_RUN_ID_TBL;
  GT_ACTG_HEADER_DESCRIPTION   ZX_EXTRACT_PKG.ACTG_HEADER_DESCRIPTION_TBL;
  GT_ACTG_LINE_NUM             ZX_EXTRACT_PKG.ACTG_LINE_NUM_TBL;
  GT_ACTG_LINE_TYPE_CODE       ZX_EXTRACT_PKG.ACTG_LINE_TYPE_CODE_TBL;
  GT_ACTG_LINE_DESCRIPTION     ZX_EXTRACT_PKG.ACTG_LINE_DESCRIPTION_TBL;
  GT_ACTG_STAT_AMT             ZX_EXTRACT_PKG.ACTG_STAT_AMT_TBL;
  GT_ACTG_ERROR_CODE           ZX_EXTRACT_PKG.ACTG_ERROR_CODE_TBL;
  GT_GL_TRANSFER_CODE          ZX_EXTRACT_PKG.GL_TRANSFER_CODE_TBL;
  GT_ACTG_DOC_SEQUENCE_ID      ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_ID_TBL;
  GT_ACTG_DOC_SEQUENCE_NAME    ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_NAME_TBL;
  GT_ACTG_DOC_SEQUENCE_VALUE   ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_VALUE_TBL;
  GT_ACTG_PARTY_ID             ZX_EXTRACT_PKG.ACTG_PARTY_ID_TBL;
  GT_ACTG_PARTY_SITE_ID        ZX_EXTRACT_PKG.ACTG_PARTY_SITE_ID_TBL;
  GT_ACTG_PARTY_TYPE           ZX_EXTRACT_PKG.ACTG_PARTY_TYPE_TBL;
  GT_ACTG_EVENT_ID             ZX_EXTRACT_PKG.ACTG_EVENT_ID_TBL;
  GT_ACTG_HEADER_ID            ZX_EXTRACT_PKG.ACTG_HEADER_ID_TBL;
  GT_ACTG_SOURCE_ID            ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL;
  GT_ACTG_SOURCE_TABLE         ZX_EXTRACT_PKG.ACTG_SOURCE_TABLE_TBL;
  GT_ACTG_LINE_CCID            ZX_EXTRACT_PKG.ACTG_LINE_CCID_TBL;
  GT_PERIOD_NAME               ZX_EXTRACT_PKG.PERIOD_NAME_TBL;

   -- GT_ACTG_SOURCE_ID             ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL;
  GT_AE_HEADER_ID              ZX_EXTRACT_PKG.ACTG_HEADER_ID_TBL;
  GT_EVENT_ID                  ZX_EXTRACT_PKG.ACTG_EVENT_ID_TBL;
  GT_LINE_CCID                 ZX_EXTRACT_PKG.ACTG_LINE_CCID_TBL;
  GT_TRX_ARAP_BALANCING_SEGMENT    ZX_EXTRACT_PKG.TRX_ARAP_BALANCING_SEG_TBL;
  GT_TRX_ARAP_NATURAL_ACCOUNT      ZX_EXTRACT_PKG.TRX_ARAP_NATURAL_ACCOUNT_TBL;
  GT_TRX_TAXABLE_BAL_SEG           ZX_EXTRACT_PKG.TRX_TAXABLE_BALANCING_SEG_TBL;
  GT_TRX_TAXABLE_NATURAL_ACCOUNT   ZX_EXTRACT_PKG.TRX_TAXABLE_NATURAL_ACCT_TBL;
  GT_TRX_TAX_BALANCING_SEGMENT     ZX_EXTRACT_PKG.TRX_TAX_BALANCING_SEG_TBL;
  GT_TRX_TAX_NATURAL_ACCOUNT       ZX_EXTRACT_PKG.TRX_TAX_NATURAL_ACCOUNT_TBL;
  GT_TAX_AMT                   ZX_EXTRACT_PKG.TAX_AMT_TBL;
  GT_TAX_AMT_FUNCL_CURR        ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL;
  GT_TAXABLE_AMT               ZX_EXTRACT_PKG.TAXABLE_AMT_TBL;
  GT_TAXABLE_AMT_FUNCL_CURR    ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL;

  AGT_ACTG_EXT_LINE_ID         ZX_EXTRACT_PKG.ACTG_EXT_LINE_ID_TBL;
  AGT_DETAIL_TAX_LINE_ID       ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
  AGT_ACTG_EVENT_TYPE_CODE     ZX_EXTRACT_PKG.ACTG_EVENT_TYPE_CODE_TBL;
  AGT_ACTG_EVENT_NUMBER        ZX_EXTRACT_PKG.ACTG_EVENT_NUMBER_TBL;
  AGT_ACTG_EVENT_STATUS_FLAG   ZX_EXTRACT_PKG.ACTG_EVENT_STATUS_FLAG_TBL;
  AGT_ACTG_CATEGORY_CODE       ZX_EXTRACT_PKG.ACTG_CATEGORY_CODE_TBL;
  AGT_ACCOUNTING_DATE          ZX_EXTRACT_PKG.ACCOUNTING_DATE_TBL;
  AGT_GL_TRANSFER_FLAG         ZX_EXTRACT_PKG.GL_TRANSFER_FLAG_TBL;
  AGT_GL_TRANSFER_RUN_ID       ZX_EXTRACT_PKG.GL_TRANSFER_RUN_ID_TBL;
  AGT_ACTG_HEADER_DESCRIPTION  ZX_EXTRACT_PKG.ACTG_HEADER_DESCRIPTION_TBL;
  AGT_ACTG_LINE_NUM            ZX_EXTRACT_PKG.ACTG_LINE_NUM_TBL;
  AGT_ACTG_LINE_TYPE_CODE      ZX_EXTRACT_PKG.ACTG_LINE_TYPE_CODE_TBL;
  AGT_ACTG_LINE_DESCRIPTION    ZX_EXTRACT_PKG.ACTG_LINE_DESCRIPTION_TBL;
  AGT_ACTG_STAT_AMT            ZX_EXTRACT_PKG.ACTG_STAT_AMT_TBL;
  AGT_ACTG_ERROR_CODE          ZX_EXTRACT_PKG.ACTG_ERROR_CODE_TBL;
  AGT_GL_TRANSFER_CODE         ZX_EXTRACT_PKG.GL_TRANSFER_CODE_TBL;
  AGT_ACTG_DOC_SEQUENCE_ID     ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_ID_TBL;
  AGT_ACTG_DOC_SEQUENCE_NAME   ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_NAME_TBL;
  AGT_ACTG_DOC_SEQUENCE_VALUE  ZX_EXTRACT_PKG.ACTG_DOC_SEQUENCE_VALUE_TBL;
  AGT_ACTG_PARTY_ID            ZX_EXTRACT_PKG.ACTG_PARTY_ID_TBL;
  AGT_ACTG_PARTY_SITE_ID       ZX_EXTRACT_PKG.ACTG_PARTY_SITE_ID_TBL;
  AGT_ACTG_PARTY_TYPE          ZX_EXTRACT_PKG.ACTG_PARTY_TYPE_TBL;
  AGT_ACTG_EVENT_ID            ZX_EXTRACT_PKG.ACTG_EVENT_ID_TBL;
  AGT_ACTG_HEADER_ID           ZX_EXTRACT_PKG.ACTG_HEADER_ID_TBL;
  AGT_ACTG_SOURCE_ID           ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL;
  AGT_ACTG_SOURCE_TABLE        ZX_EXTRACT_PKG.ACTG_SOURCE_TABLE_TBL;
  AGT_ACTG_LINE_CCID           ZX_EXTRACT_PKG.ACTG_LINE_CCID_TBL;
  AGT_PERIOD_NAME              ZX_EXTRACT_PKG.PERIOD_NAME_TBL;
  GT_ACCOUNT_FLEXFIELD         ZX_EXTRACT_PKG.ACCOUNT_FLEXFIELD_TBL;
  GT_ACCOUNT_DESCRIPTION       ZX_EXTRACT_PKG.ACCOUNT_DESCRIPTION_TBL;
  GT_TRX_CONTROL_ACCFLEXFIELD  ZX_EXTRACT_PKG.TRX_CONTROL_ACCT_FLEXFLD_TBL ; --Bug 5510907

TYPE TRX_TAXABLE_ACCOUNT_DESC_tbl  IS TABLE OF
     ZX_REP_ACTG_EXT_T.TRX_TAXABLE_ACCOUNT_DESC%TYPE INDEX BY BINARY_INTEGER;

TYPE TRX_TAXABLE_BALSEG_DESC_tbl  IS TABLE OF
     ZX_REP_ACTG_EXT_T.TRX_TAXABLE_BALSEG_DESC%TYPE INDEX BY BINARY_INTEGER;

TYPE TRX_TAXABLE_NATACCT_DESC_tbl  IS TABLE OF
     ZX_REP_ACTG_EXT_T.TRX_TAXABLE_NATACCT_SEG_DESC%TYPE INDEX BY BINARY_INTEGER;

  GT_TRX_TAXABLE_ACCOUNT_DESC  TRX_TAXABLE_ACCOUNT_DESC_tbl ; --Bug 5650415
  GT_TRX_TAXABLE_BALSEG_DESC   TRX_TAXABLE_BALSEG_DESC_TBL ;
  GT_TRX_TAXABLE_NATACCT_DESC  TRX_TAXABLE_NATACCT_DESC_tbl ;

  GT_TAX_TYPE_MNG              ZX_EXTRACT_PKG.TAX_TYPE_MNG_TBL;
  gt_tax_type_code             zx_extract_pkg.tax_type_code_tbl;

   -- Accounting---

  G_CREATED_BY                 NUMBER(15);
  G_CREATION_DATE              DATE;
  G_LAST_UPDATED_BY            NUMBER(15);
  G_LAST_UPDATE_DATE           DATE;
  G_LAST_UPDATE_LOGIN          NUMBER(15);
  G_PROGRAM_APPLICATION_ID     NUMBER;
  G_PROGRAM_ID                 NUMBER;
  G_PROGRAM_LOGIN_ID           NUMBER;
  g_chart_of_accounts_id       NUMBER;

  g_request_id                 NUMBER;

  C_LINES_PER_COMMIT      constant  number := 5000;

  G_REP_CONTEXT_ID             NUMBER := 0;
  g_retcode                    NUMBER := 0;
  g_current_runtime_level      NUMBER;
  g_level_statement   CONSTANT NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure   CONSTANT NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event       CONSTANT NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected  CONSTANT NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_error_buffer               VARCHAR2(100);

type IPV_PRIORITY_TBL is TABLE OF number
       INDEX BY binary_integer;
  GT_IPV_PRIORITY IPV_PRIORITY_TBL;

  l_balancing_segment          VARCHAR2(25);
  l_accounting_segment         VARCHAR2(25);
  l_ledger_id                  NUMBER(15);

PROCEDURE extract_party_info(i IN BINARY_INTEGER);

PROCEDURE get_accounting_info (
            P_APPLICATION_ID        IN NUMBER,
            P_ENTITY_CODE         IN VARCHAR2,
            P_EVENT_CLASS_CODE    IN VARCHAR2,
            P_TRX_LEVEL_TYPE      IN VARCHAR2,
            P_TRX_ID              IN NUMBER,
            P_TRX_LINE_ID         IN NUMBER,
            P_TRX_LINE_DIST_ID    IN NUMBER,
            P_TAX_LINE_ID         IN NUMBER,
            P_EVENT_ID            IN NUMBER,
            P_AE_HEADER_ID        IN NUMBER,
            P_TAX_DIST_ID         IN NUMBER,
            P_BALANCING_SEGMENT   IN VARCHAR2,
            P_ACCOUNTING_SEGMENT  IN VARCHAR2,
            P_SUMMARY_LEVEL       IN VARCHAR2,
            P_INCLUDE_DISCOUNTS   IN VARCHAR2,
            P_TAX_REC_FLAG        IN VARCHAR2,
            p_tax_regime_code     IN VARCHAR2,
            p_tax                 IN VARCHAR2,
            p_tax_status_code     IN VARCHAR2,
            p_tax_rate_id         IN NUMBER,
            P_ORG_ID              IN NUMBER,
            P_LEDGER_ID           IN NUMBER,
            j                     IN binary_integer);

PROCEDURE get_accounting_amounts (
               P_APPLICATION_ID   IN NUMBER,
               P_ENTITY_CODE      IN VARCHAR2,
               P_EVENT_CLASS_CODE IN VARCHAR2,
               P_TRX_LEVEL_TYPE   IN VARCHAR2,
               P_TRX_ID           IN NUMBER,
               P_TRX_LINE_ID      IN NUMBER,
               P_TAX_LINE_ID      IN NUMBER,
       --      P_ENTITY_ID        IN NUMBER,
               P_EVENT_ID         IN NUMBER,
               P_AE_HEADER_ID     IN NUMBER,
               P_TAX_DIST_ID      IN NUMBER,
               P_SUMMARY_LEVEL    IN VARCHAR2,
               P_REPORT_NAME      IN VARCHAR2,
               P_LEDGER_ID        IN NUMBER,
               j                  IN binary_integer,
               p_ae_line_num      IN NUMBER);

PROCEDURE get_discount_info
                ( j                            IN BINARY_INTEGER,
                 P_TRX_ID                      IN NUMBER,
                 P_TAX_LINE_ID                 IN NUMBER,
                 P_SUMMARY_LEVEL               IN VARCHAR2,
                 P_DIST_ID                     IN NUMBER,
                 P_TRX_LINE_ID                 IN NUMBER,
                 P_TRX_LINE_DIST_ID            IN NUMBER,
                 P_TAX_REC_FLAG                IN VARCHAR2,
                 p_tax_regime_code             IN VARCHAR2,
                 p_tax                         IN VARCHAR2,
                 p_tax_status_code             IN VARCHAR2,
                 p_tax_rate_id                 IN NUMBER,
                 P_LEDGER_ID                   IN NUMBER,
                 P_DISC_DISTRIBUTION_METHOD    IN VARCHAR2,
                 P_LIABILITY_POST_LOOKUP_CODE  IN VARCHAR2
                 );


PROCEDURE populate_meaning(
            P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
            i IN BINARY_INTEGER);

PROCEDURE populate_tax_reg_num(
           P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           P_ORG_ID       IN zx_lines.internal_organization_id%TYPE ,
           P_TAX_DATE     IN zx_lines.tax_date%TYPE,
           i BINARY_INTEGER);


PROCEDURE initialize_variables (
          p_count   IN         NUMBER);

PROCEDURE update_zx_rep_detail_t(
           P_COUNT IN BINARY_INTEGER);

PROCEDURE    insert_actg_info (
           P_COUNT IN BINARY_INTEGER);

PROCEDURE update_additional_info(
          P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE) IS


  l_count number;
  l_balancing_segment varchar2(30);
  l_accounting_segment varchar2(30);
  j number;

  l_disc_inv_less_tax_flag_hdr         VARCHAR2(1);
  l_disc_dist_method_hdr          VARCHAR2(30);
  l_liability_post_lkp_code_hdr        VARCHAR2(30);

CURSOR get_system_info_cur_hdr(c_org_id NUMBER) IS
  SELECT discount_distribution_method,
         disc_is_inv_less_tax_flag,
         liability_post_lookup_code
    FROM ap_system_parameters_all
   WHERE org_id = c_org_id;

CURSOR rep_detail_cursor(c_request_id IN NUMBER
                        ,c_ledger_id  IN NUMBER
                         ) IS
  SELECT DETAIL_TAX_LINE_ID,
         APPLICATION_ID,
         ENTITY_CODE,
         EVENT_CLASS_CODE,
         TRX_LEVEL_TYPE,
         INTERNAL_ORGANIZATION_ID,
         tax_date,
         TAX_RATE_VAT_TRX_TYPE_CODE,
         HQ_ESTB_REG_NUMBER,
         TRX_ID,
         TRX_LINE_ID ,
         TAXABLE_ITEM_SOURCE_ID,
         TAX_LINE_ID ,
         TRX_LINE_TYPE,
         TRX_LINE_CLASS,
         BILL_FROM_PARTY_TAX_PROF_ID,
         BILL_FROM_SITE_TAX_PROF_ID,
         SHIP_TO_SITE_TAX_PROF_ID,
         SHIP_FROM_SITE_TAX_PROF_ID,
         SHIP_TO_PARTY_TAX_PROF_ID,
         SHIP_FROM_PARTY_TAX_PROF_ID,
     --   zx_dtl.BILL_FROM_PARTY_ID,
     --   zx_dtl.BILL_FROM_PARTY_SITE_ID,
         SHIPPING_TP_ADDRESS_ID,    --SHIP_THIRD_PTY_ACCT_SITE_ID
         BILLING_TP_ADDRESS_ID,     --bill_third_pty_acct_site_id
         SHIPPING_TP_SITE_ID,       --ship_to_cust_acct_site_use_id
         BILLING_TP_SITE_ID,        --bill_to_cust_acct_site_use_id
         SHIPPING_TRADING_PARTNER_ID, --ship_third_pty_acct_id
         BILLING_TRADING_PARTNER_ID,  -- bill_third_pty_acct_id
         HISTORICAL_FLAG,
         posted_flag,
         event_type_code, -- Accounting Columns
         event_number,
         event_status_code,
         je_category_name,
         accounting_date,
         gl_transfer_status_flag,
         description_header,
         ae_line_num,
         accounting_class_code,
         description_line,
         statistical_amount,
         process_status_code,
         gl_transfer_status_code,
         doc_sequence_id,
         doc_sequence_value,
         party_id,
         party_site_id,
         party_type_code,
         event_id,
         ae_header_id,
         code_combination_id,
         period_name,
      --  zx_dtl.trx_line_id
         actg_source_id,
         ledger_id,
         tax_recoverable_flag,
         taxable_amt , --Bug 5409170
         0, --tax_amt, --Bug 5409170
         taxable_amt_funcl_curr,
         0, --tax_amt_funcl_curr ,
         tax_regime_code,
         tax,
         tax_status_code,
         tax_rate_id,
         ipv_priority,
         tax_type_code
FROM ( SELECT /*+ leading(zx_dtl,xla_ent,XLA_EVENT) full(zx_dtl) parallel(zx_dtl) */
              zx_dtl.DETAIL_TAX_LINE_ID,
              zx_dtl.APPLICATION_ID,
              zx_dtl.ENTITY_CODE,
              zx_dtl.EVENT_CLASS_CODE,
              zx_dtl.TRX_LEVEL_TYPE,
              zx_dtl.INTERNAL_ORGANIZATION_ID,
              zx_dtl.tax_date,
              ZX_DTL.TAX_RATE_VAT_TRX_TYPE_CODE,
              ZX_DTL.HQ_ESTB_REG_NUMBER,
              zx_dtl.TRX_ID,
              zx_dtl.TRX_LINE_ID ,
              zx_dtl.TAXABLE_ITEM_SOURCE_ID,
              zx_dtl.TAX_LINE_ID ,
              zx_dtl.TRX_LINE_TYPE,
              zx_dtl.TRX_LINE_CLASS,
              zx_dtl.BILL_FROM_PARTY_TAX_PROF_ID,
              zx_dtl.BILL_FROM_SITE_TAX_PROF_ID,
              zx_dtl.SHIP_TO_SITE_TAX_PROF_ID,
              zx_dtl.SHIP_FROM_SITE_TAX_PROF_ID,
              zx_dtl.SHIP_TO_PARTY_TAX_PROF_ID,
              zx_dtl.SHIP_FROM_PARTY_TAX_PROF_ID,
           --   zx_dtl.BILL_FROM_PARTY_ID,
           --   zx_dtl.BILL_FROM_PARTY_SITE_ID,
              zx_dtl.SHIPPING_TP_ADDRESS_ID,    --SHIP_THIRD_PTY_ACCT_SITE_ID
              zx_dtl.BILLING_TP_ADDRESS_ID,     --bill_third_pty_acct_site_id
              zx_dtl.SHIPPING_TP_SITE_ID,       --ship_to_cust_acct_site_use_id
              zx_dtl.BILLING_TP_SITE_ID,        --bill_to_cust_acct_site_use_id
              zx_dtl.SHIPPING_TRADING_PARTNER_ID, --ship_third_pty_acct_id
              zx_dtl.BILLING_TRADING_PARTNER_ID,  -- bill_third_pty_acct_id
              zx_dtl.HISTORICAL_FLAG,
              zx_dtl.posted_flag,
              xla_event.event_type_code, -- Accounting Columns
              xla_event.event_number,
              xla_event.event_status_code,
              xla_head.je_category_name,
              xla_head.accounting_date,
              xla_head.gl_transfer_status_code gl_transfer_status_flag,
              xla_head.description description_header,
              xla_line.ae_line_num,
              xla_line.accounting_class_code,
              xla_line.description description_line,
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
            --  zx_dtl.trx_line_id
              zx_dtl.actg_source_id,
              zx_dtl.ledger_id,
              zx_dtl.tax_recoverable_flag,
              zx_dtl.taxable_amt , --Bug 5409170
              0, --zx_dtl.tax_amt, --Bug 5409170
              nvl(zx_dtl.taxable_amt_funcl_curr,zx_dtl.taxable_amt) taxable_amt_funcl_curr,
              0, --nvl(zx_dtl.tax_amt_funcl_curr,zx_dtl.tax_amt) tax_amt_funcl_curr,
              zx_dtl.tax_regime_code,
              zx_dtl.tax,
              zx_dtl.tax_status_code,
              zx_dtl.tax_rate_id,
              row_number() over ( partition by xla_dist.event_id,
                                               xla_dist.ae_header_id,
                                               xla_dist.ae_line_num,
                                               xla_dist.source_distribution_type,
                                               xla_dist.tax_line_ref_id,
                                               xla_dist.tax_rec_nrec_dist_ref_id
                                  order by xla_dist.event_id,
                                           xla_dist.ae_header_id,
                                           xla_dist.ae_line_num,
                                           xla_dist.source_distribution_type,
                                           xla_dist.tax_line_ref_id,
                                           xla_dist.tax_rec_nrec_dist_ref_id
                                  ) ipv_priority,
              zx_dtl.tax_type_code
       FROM zx_rep_trx_detail_t zx_dtl,
            xla_transaction_entities xla_ent,
            xla_events     xla_event,
            xla_ae_headers  xla_head,
            xla_ae_lines    xla_line,
            xla_acct_class_assgns  acs,
            xla_assignment_defns_b asd,
            xla_distribution_links xla_dist
       WHERE zx_dtl.request_id = c_request_id
         AND zx_dtl.extract_source_ledger = 'AP'
         AND zx_dtl.posted_flag    = 'A'
         AND zx_dtl.trx_id         = nvl(xla_ent.source_id_int_1,-99)    -- Accounting Joins
         AND xla_ent.ledger_id     = zx_dtl.ledger_id
         AND xla_ent.entity_code   = 'AP_INVOICES'   -- Check this condition
         AND xla_ent.entity_id     = xla_event.entity_id
         AND xla_event.event_id    = xla_head.event_id
         AND xla_head.ae_header_id = xla_line.ae_header_id
         AND xla_head.balance_type_code = 'A'
         AND xla_head.ledger_id        = c_ledger_id
         AND acs.program_code          = 'TAX_REP_LEDGER_PROCUREMENT'
         AND acs.program_owner_code    = asd.program_owner_code
         AND acs.program_code          = asd.program_code
         AND acs.assignment_owner_code = asd.assignment_owner_code
         AND acs.assignment_code       = asd.assignment_code
         AND asd.enabled_flag          = 'Y'
         AND acs.accounting_class_code = xla_line.accounting_class_code
         AND zx_dtl.tax_line_id        = xla_dist.tax_line_ref_id
--         AND zx_dtl.actg_source_id     = xla_dist.source_distribution_id_num_1
         AND zx_dtl.actg_source_id     = xla_dist.tax_rec_nrec_dist_ref_id
         AND xla_head.ae_header_id     = xla_dist.ae_header_id
         AND xla_line.ae_header_id     = xla_dist.ae_header_id
         AND xla_line.ae_line_num      = xla_dist.ae_line_num
         AND xla_head.application_id   = xla_ent.application_id
         AND xla_head.application_id   = xla_line.application_id
         AND ((substr(xla_head.event_type_code,1,10) <> 'PREPAYMENT')
               OR
              (substr(xla_head.event_type_code,1,10) = 'PREPAYMENT'
                AND zx_dtl.trx_line_class IN ('PREPAY_APPLICATION', 'PREPAYMENT INVOICES'))
             )
         -- bug 7650289 start
         AND xla_ent.application_id   = 200
         AND xla_event.application_id = xla_ent.application_id
         AND xla_dist.application_id  = xla_line.application_id
         -- bug 7650289 end
     ) ipv
     WHERE ipv.ipv_priority = 1
  UNION ALL
     SELECT  /*+ FULL(zx_dtl) parallel(zx_dtl) */
            zx_dtl.DETAIL_TAX_LINE_ID,
            zx_dtl.APPLICATION_ID,
            zx_dtl.ENTITY_CODE,
            zx_dtl.EVENT_CLASS_CODE,
            zx_dtl.TRX_LEVEL_TYPE,
            zx_dtl.INTERNAL_ORGANIZATION_ID,
            zx_dtl.tax_date,
            ZX_DTL.TAX_RATE_VAT_TRX_TYPE_CODE,
            ZX_DTL.HQ_ESTB_REG_NUMBER,
            zx_dtl.TRX_ID,
            zx_dtl.TRX_LINE_ID ,
            zx_dtl.TAXABLE_ITEM_SOURCE_ID,
            zx_dtl.TAX_LINE_ID ,
            zx_dtl.TRX_LINE_TYPE,
            zx_dtl.TRX_LINE_CLASS,
            zx_dtl.BILL_FROM_PARTY_TAX_PROF_ID,
            zx_dtl.BILL_FROM_SITE_TAX_PROF_ID,
            zx_dtl.SHIP_TO_SITE_TAX_PROF_ID,
            zx_dtl.SHIP_FROM_SITE_TAX_PROF_ID,
            zx_dtl.SHIP_TO_PARTY_TAX_PROF_ID,
            zx_dtl.SHIP_FROM_PARTY_TAX_PROF_ID,
--          zx_dtl.BILL_FROM_PARTY_ID,
--          zx_dtl.BILL_FROM_PARTY_SITE_ID,
            zx_dtl.SHIPPING_TP_ADDRESS_ID,      --SHIP_THIRD_PTY_ACCT_SITE_ID
            zx_dtl.BILLING_TP_ADDRESS_ID,       --bill_third_pty_acct_site_id
            zx_dtl.SHIPPING_TP_SITE_ID,         --ship_to_cust_acct_site_use_id
            zx_dtl.BILLING_TP_SITE_ID,          --bill_to_cust_acct_site_use_id
            zx_dtl.SHIPPING_TRADING_PARTNER_ID, --ship_third_pty_acct_id
            zx_dtl.BILLING_TRADING_PARTNER_ID,  -- bill_third_pty_acct_id
            zx_dtl.HISTORICAL_FLAG,
            zx_dtl.posted_flag,
            TO_CHAR(NULL),    --xla_event.event_type_code, -- Accounting Columns
            TO_NUMBER(NULL),  --xla_event.event_number,
            TO_CHAR(NULL),    --xla_event.event_status_code,
            TO_CHAR(NULL),    --xla_head.je_category_name,
            TO_DATE(NULL),    --xla_head.accounting_date,
            TO_CHAR(NULL),    --xla_head.gl_transfer_status_code,
            TO_CHAR(NULL),    --xla_head.description,
            TO_NUMBER(NULL),  --xla_line.ae_line_num,
            TO_CHAR(NULL),    --xla_line.accounting_class_code,
            TO_CHAR(NULL),    --xla_line.description,
            TO_NUMBER(NULL),  --xla_line.statistical_amount,
            TO_CHAR(NULL),    --xla_event.process_status_code,
            TO_CHAR(NULL),    --xla_head.gl_transfer_status_code,
            TO_NUMBER(NULL),  --xla_head.doc_sequence_id,
            TO_NUMBER(NULL),  --xla_head.doc_sequence_value,
            TO_NUMBER(NULL),  --xla_line.party_id,
            TO_NUMBER(NULL),  --xla_line.party_site_id,
            TO_CHAR(NULL),    --xla_line.party_type_code,
            TO_NUMBER(NULL),  --xla_event.event_id,
            TO_NUMBER(NULL),  --xla_head.ae_header_id,
            TO_NUMBER(NULL),  --xla_line.code_combination_id,
            TO_CHAR(NULL),    --xla_head.period_name,
            TO_NUMBER(NULL),  --zx_dtl.trx_line_id
            zx_dtl.ledger_id,
            zx_dtl.tax_recoverable_flag,
            zx_dtl.TAXABLE_AMT , --Bug 5409170
            0, --zx_dtl.tax_amt ,     --Bug 5409170
            nvl(zx_dtl.taxable_amt_funcl_curr,zx_dtl.TAXABLE_AMT) ,--Bug 5405785
            0, --nvl(zx_dtl.tax_amt_funcl_curr,zx_dtl.tax_amt), --Bug 5405785
            zx_dtl.tax_regime_code,
            zx_dtl.tax,
            zx_dtl.tax_status_code,
            zx_dtl.tax_rate_id,
            to_number(NULL),
            tax_type_code
     FROM  zx_rep_trx_detail_t zx_dtl
     WHERE zx_dtl.request_id = c_request_id
       AND zx_dtl.extract_source_ledger = 'AP'
       AND ( (nvl(zx_dtl.posted_flag,'N')  = 'N')
              OR
             (zx_dtl.posted_flag in ('A', 'Y') AND zx_dtl.tax_line_id IS NULL)
           );

BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    g_request_id := P_TRL_GLOBAL_VARIABLES_REC.request_id;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info.BEGIN',
                                    'update_additional_info(+)');
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                                    'Request ID : '||to_char(P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                          'Reporting Ledger : '||to_char(p_trl_global_variables_rec.reporting_ledger_id));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                          'Primary Ledger : '||to_char(p_trl_global_variables_rec.ledger_id));
    END IF;

    gl_mc_info.get_ledger_currency(p_trl_global_variables_rec.ledger_id, G_FUN_CURRENCY_CODE);

    XLA_SECURITY_PKG.set_security_context(p_application_id => 602); --Bug 5393051
    l_ledger_id := P_TRL_GLOBAL_VARIABLES_REC.ledger_id; --Bug 5393051

    IF p_trl_global_variables_rec.reporting_ledger_id IS NOT NULL
      OR p_trl_global_variables_rec.report_name = 'ZXXTATAT' THEN
       UPDATE zx_rep_trx_detail_t
          SET tax_amt = 0,
              tax_amt_funcl_curr = 0
        Where request_id = p_trl_global_variables_rec.request_id  ;
    END IF;

  OPEN rep_detail_cursor(p_trl_global_variables_rec.request_id,
                         NVL(p_trl_global_variables_rec.reporting_ledger_id,p_trl_global_variables_rec.ledger_id)
                         );
  LOOP
    FETCH rep_detail_cursor BULK COLLECT INTO
        GT_DETAIL_TAX_LINE_ID,
        GT_APPLICATION_ID,
        GT_ENTITY_CODE,
        GT_EVENT_CLASS_CODE,
        GT_TRX_LEVEL_TYPE,
        GT_INTERNAL_ORGANIZATION_ID,
        GT_TAX_DATE,
        GT_TAX_RATE_VAT_TRX_TYPE_CODE,
        GT_HQ_ESTB_REG_NUMBER,
        GT_TRX_ID,
        GT_TRX_LINE_ID,
        GT_TRX_LINE_DIST_ID,
        GT_TAX_LINE_ID,
        GT_TRX_LINE_TYPE,
        GT_TRX_LINE_CLASS,
        GT_BILL_FROM_PTY_TAX_PROF_ID,
        GT_BILL_FROM_SITE_TAX_PROF_ID,
        GT_SHIP_TO_SITE_TAX_PROF_ID,
        GT_SHIP_FROM_SITE_TAX_PROF_ID,
        GT_SHIP_TO_PARTY_TAX_PROF_ID,
        GT_SHIP_FROM_PTY_TAX_PROF_ID,
      --  GT_BILL_FROM_PARTY_ID,
     --   GT_BILL_FROM_PARTY_SITE_ID,
        GT_SHIPPING_TP_ADDRESS_ID,
        GT_BILLING_TP_ADDRESS_ID,
        GT_SHIPPING_TP_SITE_ID,
        GT_BILLING_TP_SITE_ID,
        GT_SHIPPING_TP_ID,
        GT_BILLING_TRADING_PARTNER_ID,
        GT_HISTORICAL_FLAG,
        GT_POSTED_FLAG,
        gt_actg_event_type_code,
        gt_actg_event_number,
        gt_actg_event_status_flag,
        gt_actg_category_code,
        gt_accounting_date,
        gt_gl_transfer_flag,
      --  gt_gl_transfer_run_id,
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
        gt_ledger_id,
        gt_tax_recoverable_flag,
        GT_TAXABLE_AMT, --Bug 5409170
        GT_TAX_AMT, --Bug 5409170
        GT_TAXABLE_AMT_FUNCL_CURR, --Bug 5405785
        GT_TAX_AMT_FUNCL_CURR, --Bug 5405785
        gt_tax_regime_code,
        gt_tax,
        gt_tax_status_code,
        gt_tax_rate_id,
        GT_IPV_PRIORITY,
        GT_TAX_TYPE_CODE
        LIMIT C_LINES_PER_COMMIT;

       l_count := GT_DETAIL_TAX_LINE_ID.count;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                                      'Rows fetched by rep_detail_cursor :'||to_char(l_count));
    END IF;

    j:=0;
    G_REP_CONTEXT_ID := ZX_EXTRACT_PKG.GET_REP_CONTEXT_ID(P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID,
                                                          P_TRL_GLOBAL_VARIABLES_REC.request_id);
    IF l_count > 0 THEN
      initialize_variables(l_count);

      FOR i in 1..l_count
      LOOP

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                          'Populate Cursor Line Number :'||to_char(i));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                          ' GT_BILL_FROM_PTY_TAX_PROF_ID(i) :'||to_char(GT_BILL_FROM_PTY_TAX_PROF_ID(i)));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                   ' GT_BILLING_TRADING_PARTNER_ID(i) :'||to_char(GT_BILLING_TRADING_PARTNER_ID(i)));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
            ' include_accounting_segments :'||p_trl_global_variables_rec.include_accounting_segments);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
            ' gt_posted_flag :'||gt_posted_flag(i));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                          'GT_TAXABLE_AMT(i) :'||to_char(GT_TAXABLE_AMT(i)));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                          'GT_TAX_AMT(i) :'||to_char(GT_TAX_AMT(i)));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                          'GT_IPV_PRIORITY(i) :'||to_char(GT_IPV_PRIORITY(i)));
        END IF;

        -- Intialize discount amount variables --
        GT_TAXABLE_DISC_AMT(i) := NULL ;
        GT_TAXABLE_DISC_AMT_FUNCL_CURR(i)  := NULL;
        GT_TAX_DISC_AMT(i)   := NULL;
        GT_TAX_DISC_AMT_FUNCL_CURR(i)  := NULL;
        -- End of Initialization ----

        extract_party_info(i);
        populate_meaning(P_TRL_GLOBAL_VARIABLES_REC,i);

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

        --Bug 5438409 : Interchange the condition check , first accounted condition should be checked
        --and then include_accounting_segments = 'Y' should bne checked  ..
        IF ( gt_posted_flag(i) IN ('A','Y')
             AND
             P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL  = 'TRANSACTION_DISTRIBUTION' ) THEN
          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                            ' Accounting API calls :');
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                            ' include_accounting_segments :'||p_trl_global_variables_rec.include_accounting_segments);
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                            ' gt_posted_flag :'||gt_posted_flag(i));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                            ' GT_actg_EVENT_ID :'||to_char(GT_actg_EVENT_ID(i)));
          END IF;

          IF p_trl_global_variables_rec.include_accounting_segments='Y' THEN --Bug 5438409
            g_chart_of_accounts_id := p_trl_global_variables_rec.chart_of_accounts_id;
            l_balancing_segment := fa_rx_flex_pkg.flex_sql(
                      p_application_id =>101,
                      p_id_flex_code => 'GL#',
                      p_id_flex_num => g_chart_of_accounts_id,
                      p_table_alias => '',
                      p_mode => 'SELECT',
                      p_qualifier => 'GL_BALANCING');
            l_accounting_segment := fa_rx_flex_pkg.flex_sql(
                      p_application_id =>101,
                      p_id_flex_code => 'GL#',
                      p_id_flex_num => g_chart_of_accounts_id,
                      p_table_alias => '',
                      p_mode => 'SELECT',
                      p_qualifier => 'GL_ACCOUNT');

            j:=j+1;


            agt_detail_tax_line_id(j)       := gt_detail_tax_line_id(i);
            agt_actg_event_type_code(j)     := gt_actg_event_type_code(i);
            agt_actg_event_number(j)        := gt_actg_event_number(i);
            agt_actg_event_status_flag(j)   := gt_actg_event_status_flag(i);
            agt_actg_category_code(j)       := gt_actg_category_code(i);
            agt_accounting_date(j)          := gt_accounting_date(i);
            agt_gl_transfer_flag(j)         := gt_gl_transfer_flag(i);
            -- agt_gl_transfer_run_id(j)      := gt_gl_transfer_run_id(i);
            agt_actg_header_description(j)  := gt_actg_header_description(i);
            agt_actg_line_num(j)            := gt_actg_line_num(i);
            agt_actg_line_type_code(j)      := gt_actg_line_type_code(i);
            agt_actg_line_description(j)    := gt_actg_line_description(i);
            agt_actg_stat_amt(j)            := gt_actg_stat_amt(i);
            agt_actg_error_code(j)          := gt_actg_error_code(i);
            agt_gl_transfer_code(j)         := gt_gl_transfer_code(i);
            agt_actg_doc_sequence_id(j)     := gt_actg_doc_sequence_id(i);
            --  agt_actg_doc_sequence_name(j) := gt_actg_doc_sequence_name(i);
            agt_actg_doc_sequence_value(j)  := gt_actg_doc_sequence_value(i);
            agt_actg_party_id(j)            := gt_actg_party_id(i);
            agt_actg_party_site_id(j)       := gt_actg_party_site_id(i);
            agt_actg_party_type(j)          := gt_actg_party_type(i);
            agt_actg_event_id(j)            := gt_actg_event_id(i);
            agt_actg_header_id(j)           := gt_actg_header_id(i);
            agt_actg_source_id(j)           := gt_actg_source_id(i);
            -- agt_actg_source_table(j)      := gt_actg_source_table(i);
            agt_actg_line_ccid(j)           := gt_actg_line_ccid(i);
            agt_period_name(j)              := gt_period_name(i);

           IF  p_trl_global_variables_rec.report_name <> 'ZXXTATAT' THEN
            get_accounting_info(
                    GT_APPLICATION_ID(i),
                    GT_ENTITY_CODE(i),
                    GT_EVENT_CLASS_CODE(i),
                    GT_TRX_LEVEL_TYPE(i),
                    GT_TRX_ID(i),
                    GT_TRX_LINE_ID(i),
                    GT_TRX_LINE_DIST_ID(i),
                    GT_TAX_LINE_ID(i),
                    GT_actg_EVENT_ID(i),
                    GT_actg_HEADER_ID(i),
                    GT_ACTG_SOURCE_ID(i),
                    l_balancing_segment,
                    l_accounting_segment,
                    P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
                    P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_DISCOUNTS,
                    GT_TAX_RECOVERABLE_FLAG(i),
                    gt_tax_regime_code(i),
                    gt_tax(i),
                    gt_tax_status_code(i),
                    gt_tax_rate_id(i),
                    GT_INTERNAL_ORGANIZATION_ID(i),
                    NVL(p_trl_global_variables_rec.reporting_ledger_id,p_trl_global_variables_rec.ledger_id), --l_ledger_id,
                    j) ;
           END IF;
          END IF ; -- Include accounting segement check -- --Bug 5438409

          IF p_trl_global_variables_rec.reporting_ledger_id IS NOT NULL
             OR
             p_trl_global_variables_rec.report_name = 'ZXXTATAT' THEN

            get_accounting_amounts(
              GT_APPLICATION_ID(i),
              GT_ENTITY_CODE(i),
              GT_EVENT_CLASS_CODE(i),
              GT_TRX_LEVEL_TYPE(i),
              GT_TRX_ID(i),
              GT_TRX_LINE_ID(i),
              GT_TAX_LINE_ID(i),
          --          GT_ENTITY_ID(i),
              GT_actg_EVENT_ID(i),
              GT_actg_HEADER_ID(i),
              GT_ACTG_SOURCE_ID(i),
              P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
              p_trl_global_variables_rec.report_name,
              NVL(p_trl_global_variables_rec.reporting_ledger_id,p_trl_global_variables_rec.ledger_id), --l_ledger_id,
              i,--Need to change this to j if inserting into accouting table
              gt_actg_line_num(i)) ;
          END IF;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',' i : '||to_Char(i)||
                            'Taxable Amt  : '|| to_char(GT_TAXABLE_AMT(i)) ||'TAXABLE_AMT_FUNCL_CURR : '||GT_TAXABLE_AMT_FUNCL_CURR(i));
            FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',' i : '||to_Char(i)||
                            'Tax Amt  : '|| to_char(GT_TAX_AMT(i)) ||'TAX_AMT_FUNCL_CURR : '||GT_TAX_AMT_FUNCL_CURR(i));
          END IF;

        ELSE   -- Discounts API Call --

           -- New code introduced for Header Level Discounts --

          OPEN get_system_info_cur_hdr(GT_INTERNAL_ORGANIZATION_ID(i));
          FETCH get_system_info_cur_hdr
          INTO l_disc_dist_method_hdr,
               l_disc_inv_less_tax_flag_hdr,
               l_liability_post_lkp_code_hdr;
          CLOSE get_system_info_cur_hdr;

          IF NVL(l_disc_inv_less_tax_flag_hdr, 'N') = 'N' AND
             NVL(l_disc_dist_method_hdr, 'SYSTEM') <> 'SYSTEM' THEN

             IF P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_DISCOUNTS = 'Y' THEN
                get_discount_info(i,
                          GT_TRX_ID(i),
                          GT_TAX_LINE_ID(i),
                          P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
                          GT_ACTG_SOURCE_ID(i),
                          GT_TRX_LINE_ID(i),
                          GT_TRX_LINE_DIST_ID(i),
                          GT_TAX_RECOVERABLE_FLAG(i),
                          gt_tax_regime_code(i),
                          gt_tax(i),
                          gt_tax_status_code(i),
                          gt_tax_rate_id(i),
                          NVL(p_trl_global_variables_rec.reporting_ledger_id,p_trl_global_variables_rec.ledger_id),
                          l_disc_dist_method_hdr,
                          l_liability_post_lkp_code_hdr);
            END IF;
          END IF;

        END IF;    -- Posted flag check --

      END LOOP;
    ELSE
      EXIT;
    END IF;

/*      EXIT WHEN rep_detail_cursor%NOTFOUND
            OR rep_detail_cursor%NOTFOUND IS NULL;

   END LOOP;
*/

    update_zx_rep_detail_t(l_count);
    IF p_trl_global_variables_rec.include_accounting_segments='Y' THEN
           insert_actg_info(j);
    END IF;

    EXIT WHEN rep_detail_cursor%NOTFOUND
               OR rep_detail_cursor%NOTFOUND IS NULL;

  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info.END',
                    'update_additional_info(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_POPULATE_PKG.update_additional_info',
                      g_error_buffer);
    END IF;

       P_TRL_GLOBAL_VARIABLES_REC.RETCODE := g_retcode;

END update_additional_info;


PROCEDURE extract_party_info( i IN BINARY_INTEGER) IS

   l_party_id          zx_rep_trx_detail_t.bill_from_party_id%TYPE;
   l_party_site_id     zx_rep_trx_detail_t.bill_from_party_site_id%TYPE;
   l_party_profile_id  zx_rep_trx_detail_t.BILL_FROM_PARTY_TAX_PROF_ID%TYPE;
   l_site_profile_id   zx_rep_trx_detail_t.BILL_FROM_SITE_TAX_PROF_ID%TYPE;
   l_bill_ship_pty_id  zx_rep_trx_detail_t.bill_from_party_id%TYPE;
   l_bill_ship_site_id zx_rep_trx_detail_t.bill_from_party_site_id%TYPE;
   l_tbl_index_party      BINARY_INTEGER;
   l_tbl_index_site       BINARY_INTEGER;

-- If party_id is NULL and Historical flag 'N' then get the party ID from zx_party_tax_profile
CURSOR ledger_cur (c_ledger_id ZX_REP_TRX_DETAIL_T.ledger_id%TYPE) IS
SELECT name
  FROM gl_ledgers
 WHERE ledger_id = c_ledger_id
   AND rownum = 1;

/*  CURSOR party_id_cur
       (c_bill_from_ptp_id zx_rep_trx_detail_t.BILL_FROM_PARTY_TAX_PROF_ID%TYPE) IS
    SELECT party_id
      FROM zx_party_tax_profile
     WHERE PARTY_TAX_PROFILE_ID = c_bill_from_ptp_id
       AND party_type_code = 'THIRD_PARTY';

  CURSOR party_site_id_cur
      (c_bill_from_stp_id zx_rep_trx_detail_t.BILL_FROM_SITE_TAX_PROF_ID%TYPE) IS
    SELECT party_id
      FROM zx_party_tax_profile
     WHERE PARTY_TAX_PROFILE_ID = c_bill_from_stp_id
       AND party_type_code = 'THIRD_PARTY_SITE';
-- If party_id is NOT NULL and Historical flag 'Y' then get the party tax profile ID from zx_party_tax_profile
*/
  CURSOR party_reg_num_cur
      (c_bill_from_party_id zx_rep_trx_detail_t.bill_from_party_id%TYPE) IS
    SELECT rep_registration_number
      FROM zx_party_tax_profile
     WHERE party_id = c_bill_from_party_id
       AND party_type_code = 'THIRD_PARTY';

  CURSOR party_site_reg_num_cur
       (c_bill_from_site_id zx_rep_trx_detail_t.bill_from_party_site_id%TYPE) IS
    SELECT rep_registration_number
      FROM zx_party_tax_profile
     WHERE party_id = c_bill_from_site_id
       AND party_type_code = 'THIRD_PARTY_SITE';

  CURSOR party_cur
       (c_bill_from_party_id zx_rep_trx_detail_t.bill_from_party_id%TYPE) IS
    SELECT SEGMENT1,
        --   VAT_REGISTRATION_NUM,
           NUM_1099||GLOBAL_ATTRIBUTE12,
           VENDOR_NAME,
           VENDOR_NAME_ALT,
           STANDARD_INDUSTRY_CLASS,
           PARTY_ID
     FROM ap_suppliers
    WHERE vendor_id = c_bill_from_party_id;

  CURSOR party_site_cur
       (c_bill_from_site_id zx_rep_trx_detail_t.bill_from_party_site_id%TYPE) IS
    SELECT CITY,
           COUNTY,
           STATE,
           PROVINCE,
           ADDRESS_LINE1,
           ADDRESS_LINE2,
           ADDRESS_LINE3,
           ADDRESS_LINES_ALT,
           COUNTRY,
           ZIP,
      --     VENDOR_ID,
       --    VENDOR_SITE_ID,
        --   TAX_REPORTING_SITE_FLAG,
           GLOBAL_ATTRIBUTE17,
           VENDOR_SITE_CODE_ALT,
           VENDOR_SITE_CODE,
       --    VAT_REGISTRATION_NUM
           PARTY_SITE_ID
     FROM ap_supplier_sites_all
    WHERE vendor_site_id = c_bill_from_site_id;


BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info.BEGIN',
                                      'extract_party_info(+)'||to_char(i));
    END IF;

    OPEN ledger_cur(GT_LEDGER_ID(i));
    FETCH ledger_cur into GT_LEDGER_NAME(i);
    CLOSE ledger_cur;
/*
    --IF NVL(gt_historical_flag(i),'N') = 'N'  AND GT_BILL_FROM_PTY_TAX_PROF_ID(i) IS NOT NULL THEN
    IF GT_BILL_FROM_PTY_TAX_PROF_ID(i) IS NOT NULL THEN
       OPEN party_id_cur(GT_BILL_FROM_PTY_TAX_PROF_ID(i));
       FETCH party_id_cur INTO l_party_id;

       OPEN party_site_id_cur(GT_BILL_FROM_SITE_TAX_PROF_ID(i));
       FETCH party_site_id_cur INTO l_party_site_id;
    ELSE
       l_bill_ship_pty_id := NVL(GT_SHIPPING_TP_ID(i),GT_BILLING_TRADING_PARTNER_ID(i));
       l_bill_ship_site_id := NVL(GT_SHIPPING_TP_ADDRESS_ID(i), GT_BILLING_TP_ADDRESS_ID(i));

       OPEN party_profile_id_cur (l_bill_ship_pty_id);
       FETCH party_profile_id_cur into l_party_profile_id;

       OPEN site_profile_id_cur(l_bill_ship_site_id);
       FETCH site_profile_id_cur INTO l_site_profile_id;

    --   l_party_id := GT_BILL_FROM_PARTY_ID(i);
       l_party_site_id := GT_BILL_FROM_PARTY_SITE_ID(i);

     END IF;
*/
       l_bill_ship_pty_id := NVL(GT_SHIPPING_TP_ID(i),GT_BILLING_TRADING_PARTNER_ID(i));
       l_bill_ship_site_id := NVL(GT_SHIPPING_TP_ADDRESS_ID(i), GT_BILLING_TP_ADDRESS_ID(i));

        IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                      ' l_party_id :'||to_char(l_bill_ship_pty_id)||' '||to_char(l_bill_ship_site_id));
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                    ' GT_DETAIL_TAX_LINE_ID :'||to_char(l_party_id)||' '||to_char(GT_DETAIL_TAX_LINE_ID(i)));
         END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                      ' l_party_id :'||to_char(l_bill_ship_pty_id)||' '||to_char(l_bill_ship_site_id));
         END IF;


     IF l_bill_ship_pty_id IS NOT NULL THEN
        --l_tbl_index_party  := dbms_utility.get_hash_value(to_char(l_bill_ship_pty_id), 1,8192);
        l_tbl_index_party  := to_char(l_bill_ship_pty_id);

        IF g_party_info_ap_tbl.EXISTS(l_tbl_index_party) THEN

           GT_BILLING_TP_NUMBER(i) := g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NUMBER  ;
       --    GT_BILLING_TP_TAX_REG_NUM(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_TAX_REG_NUM;
           GT_BILLING_TP_TAXPAYER_ID(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_TAXPAYER_ID;
           GT_BILLING_TP_NAME(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NAME;
           GT_BILLING_TP_NAME_ALT(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT;
           GT_BILLING_TP_SIC_CODE(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE;
           GT_BILL_FROM_PARTY_ID(i)  := g_party_info_ap_tbl(l_tbl_index_party).BILL_FROM_PARTY_ID;

        ELSE

          OPEN party_cur (l_bill_ship_pty_id);
          FETCH party_cur INTO
                GT_BILLING_TP_NUMBER(i),
             --   GT_BILLING_TP_TAX_REG_NUM(i),
                GT_BILLING_TP_TAXPAYER_ID(i),
                GT_BILLING_TP_NAME(i),
                GT_BILLING_TP_NAME_ALT(i),
                GT_BILLING_TP_SIC_CODE(i),
                GT_BILL_FROM_PARTY_ID(i);
        --        l_party_id;


             g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NUMBER := GT_BILLING_TP_NUMBER(i);
               --g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_TAX_REG_NUM := GT_BILLING_TP_TAX_REG_NUM(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_TAXPAYER_ID := GT_BILLING_TP_TAXPAYER_ID(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NAME := GT_BILLING_TP_NAME(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT := GT_BILLING_TP_NAME_ALT(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE := GT_BILLING_TP_SIC_CODE(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILL_FROM_PARTY_ID := GT_BILL_FROM_PARTY_ID(i);

               IF (g_level_procedure >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                                      ' GT_BILLING_TP_NUMBER(i) :'||GT_BILLING_TP_NUMBER(i));
                  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                                      ' l_party_id : Name :'||to_char(l_party_id)||'-'||GT_BILLING_TP_NAME(i));
               END IF;
          END IF;
               IF (g_level_procedure >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                                      ' GT_BILLING_TP_NUMBER(i) :'||GT_BILLING_TP_NUMBER(i));
                  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                                      ' l_party_id : Name :'||to_char(l_bill_ship_pty_id)||'-'||GT_BILLING_TP_NAME(i));
               END IF;
            l_party_id := GT_BILL_FROM_PARTY_ID(i);
             OPEN party_reg_num_cur (l_party_id);
             FETCH party_reg_num_cur into GT_BILLING_TP_TAX_REG_NUM(i);
     END IF;

     IF l_bill_ship_site_id IS NOT NULL THEN
        --l_tbl_index_site := dbms_utility.get_hash_value(to_char(l_bill_ship_site_id), 1,8192);
        l_tbl_index_site := to_char(l_bill_ship_site_id);

        IF g_party_site_tbl.EXISTS(l_tbl_index_site) THEN

           GT_BILLING_TP_CITY(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_CITY;
           GT_BILLING_TP_COUNTY(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTY;
           GT_BILLING_TP_COUNTY(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTY;
           GT_BILLING_TP_STATE(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_STATE;
           GT_BILLING_TP_PROVINCE(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_PROVINCE;
           GT_BILLING_TP_ADDRESS1(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS1;
           GT_BILLING_TP_ADDRESS2(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS2;
           GT_BILLING_TP_ADDRESS3(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS3;
           GT_BILLING_TP_ADDR_LINES_ALT(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDR_LINES_ALT;
           GT_BILLING_TP_COUNTRY(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTRY;
           GT_BILLING_TP_POSTAL_CODE(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_POSTAL_CODE;
           GT_GDF_PO_VENDOR_SITE_ATT17(i) := g_party_site_tbl(l_tbl_index_site).GDF_PO_VENDOR_SITE_ATT17;
           GT_BILLING_TP_SITE_NAME_ALT(i) :=g_party_site_tbl(l_tbl_index_site).BILLING_TP_SITE_NAME_ALT;
           GT_BILLING_TP_SITE_NAME(i) :=g_party_site_tbl(l_tbl_index_site).BILLING_TP_SITE_NAME;
           GT_BILL_FROM_PARTY_SITE_ID(i)  := g_party_site_tbl(l_tbl_index_site).BILL_FROM_PARTY_SITE_ID;
--           GT_BILLING_SITE_TAX_REG_NUM(i) := g_party_site_tbl(l_tbl_index_site).BILLING_SITE_TAX_REG_NUM;

        ELSE

          OPEN  party_site_cur (l_bill_ship_site_id);
          FETCH party_site_cur INTO
                GT_BILLING_TP_CITY(i),
                GT_BILLING_TP_COUNTY(i),
                GT_BILLING_TP_STATE(i),
                GT_BILLING_TP_PROVINCE(i),
                GT_BILLING_TP_ADDRESS1(i),
                GT_BILLING_TP_ADDRESS2(i),
                GT_BILLING_TP_ADDRESS3(i),
                GT_BILLING_TP_ADDR_LINES_ALT(i),
                GT_BILLING_TP_COUNTRY(i),
                GT_BILLING_TP_POSTAL_CODE(i),
                GT_GDF_PO_VENDOR_SITE_ATT17(i),
                GT_BILLING_TP_SITE_NAME_ALT(i),
                GT_BILLING_TP_SITE_NAME(i),
                GT_BILL_FROM_PARTY_SITE_ID(i);

                --l_party_site_id;
           --      GT_BILLING_SITE_TAX_REG_NUM(i);

           g_party_site_tbl(l_tbl_index_site).BILLING_TP_CITY :=  GT_BILLING_TP_CITY(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTY := GT_BILLING_TP_COUNTY(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTY := GT_BILLING_TP_COUNTY(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_PROVINCE := GT_BILLING_TP_STATE(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_PROVINCE := GT_BILLING_TP_PROVINCE(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS1 := GT_BILLING_TP_ADDRESS1(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS2 := GT_BILLING_TP_ADDRESS2(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS3 := GT_BILLING_TP_ADDRESS3(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDR_LINES_ALT := GT_BILLING_TP_ADDR_LINES_ALT(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTRY := GT_BILLING_TP_COUNTRY(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_POSTAL_CODE := GT_BILLING_TP_POSTAL_CODE(i);
           g_party_site_tbl(l_tbl_index_site).GDF_PO_VENDOR_SITE_ATT17 := GT_GDF_PO_VENDOR_SITE_ATT17(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_SITE_NAME_ALT := GT_BILLING_TP_SITE_NAME_ALT(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_SITE_NAME     := GT_BILLING_TP_SITE_NAME(i);
           g_party_site_tbl(l_tbl_index_site).BILL_FROM_PARTY_SITE_ID := GT_BILL_FROM_PARTY_SITE_ID(i);
--           g_party_site_tbl(l_tbl_index_site).BILLING_SITE_TAX_REG_NUM := GT_BILLING_SITE_TAX_REG_NUM(i);
       END IF;
                 IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                                      ' l_party_site_id :'||to_char(l_party_site_id));
         END IF;
            l_party_site_id := GT_BILL_FROM_PARTY_SITE_ID(i);
       OPEN party_site_reg_num_cur(l_party_site_id);
       FETCH party_site_reg_num_cur INTO GT_BILLING_SITE_TAX_REG_NUM(i);
     END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info.END',
                                      'extract_party_info(-)');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_POPULATE_PKG.extract_party_info',
                      g_error_buffer);
    END IF;
    g_retcode := 2;
END extract_party_info;

-- Begin Accounting procedures --


PROCEDURE get_accounting_info (
            P_APPLICATION_ID        IN NUMBER,
            P_ENTITY_CODE           IN VARCHAR2,
            P_EVENT_CLASS_CODE      IN VARCHAR2,
            P_TRX_LEVEL_TYPE        IN VARCHAR2,
            P_TRX_ID                IN NUMBER,
            P_TRX_LINE_ID           IN NUMBER,
            P_TRX_LINE_DIST_ID      IN NUMBER,
            P_TAX_LINE_ID           IN NUMBER,
 --           P_ENTITY_ID             IN NUMBER,
            P_EVENT_ID              IN NUMBER,
            P_AE_HEADER_ID          IN NUMBER,
            P_TAX_DIST_ID           IN NUMBER,
            P_BALANCING_SEGMENT     IN VARCHAR2,
            P_ACCOUNTING_SEGMENT    IN VARCHAR2,
            P_SUMMARY_LEVEL         IN VARCHAR2,
            P_INCLUDE_DISCOUNTS     IN VARCHAR2,
            P_TAX_REC_FLAG          IN VARCHAR2,
            p_tax_regime_code       IN VARCHAR2,
            p_tax                   IN VARCHAR2,
            p_tax_status_code       IN VARCHAR2,
            p_tax_rate_id           IN NUMBER,
            P_ORG_ID                IN NUMBER,
            P_LEDGER_ID             IN NUMBER,
            j                       IN BINARY_INTEGER) IS

     CURSOR get_system_info_cur(c_org_id NUMBER) IS
     SELECT discount_distribution_method,
            disc_is_inv_less_tax_flag,
            liability_post_lookup_code
       FROM ap_system_parameters_all
      WHERE org_id = c_org_id;

    CURSOR trx_ccid (c_application_id number,
                     c_entity_code varchar2,
                     c_event_class_code varchar2,
                     c_trx_level_type varchar2,
                     c_trx_id number,
                     c_event_id number,
                     c_ae_header_id number) IS
      SELECT
             ael.code_combination_id
        FROM zx_rec_nrec_dist zx_dist,
             xla_distribution_links lnk,
             xla_ae_lines              ael
       WHERE zx_dist.trx_id = c_trx_id
         AND zx_dist.APPLICATION_ID = c_application_id
         AND zx_dist.entity_code = c_entity_code
         AND zx_dist.event_class_Code = c_event_class_code
         AND zx_dist.trx_level_type = c_trx_level_type
         AND lnk.application_id = 200
         AND lnk.source_distribution_type = 'AP_INV_DIST'
--         AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
         AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
         AND lnk.ae_header_id   = ael.ae_header_id
         AND lnk.ae_line_num    = ael.ae_line_num
         AND lnk.event_id       = c_event_id
         AND lnk.ae_header_id   = c_ae_header_id
         AND lnk.application_id = ael.application_id
         AND rownum =1;


    CURSOR trx_line_ccid (c_application_id number,
                          c_entity_code varchar2,
                          c_event_class_code varchar2,
                          c_trx_level_type varchar2,
                          c_trx_id NUMBER,
                          c_trx_line_id NUMBER,
                          c_event_id NUMBER,
                          c_ae_header_id NUMBER) IS
      SELECT
             ael.code_combination_id
        FROM zx_rec_nrec_dist zx_dist,
             xla_distribution_links lnk,
             xla_ae_lines              ael
       WHERE zx_dist.trx_id = c_trx_id
         AND zx_dist.APPLICATION_ID = c_application_id
         AND zx_dist.entity_code = c_entity_code
         AND zx_dist.event_class_Code = c_event_class_code
         AND zx_dist.trx_level_type = c_trx_level_type
         AND zx_dist.trx_line_id = c_trx_line_id
         AND lnk.application_id = 200
         AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
         AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
         AND lnk.ae_header_id   = ael.ae_header_id
         AND lnk.ae_line_num    = ael.ae_line_num
         AND lnk.event_id       = c_event_id
         AND lnk.ae_header_id   = c_ae_header_id
         AND lnk.application_id = ael.application_id
         AND rownum =1;

-- For transavtion distribution level code combination id select in the build SQL
-- The following query can be removed ----

  CURSOR trx_dist_ccid (c_application_id number,
                        c_entity_code varchar2,
                        c_event_class_code varchar2,
                        c_trx_level_type varchar2,
                        c_trx_id NUMBER,
                        c_trx_line_id NUMBER,
                        c_event_id NUMBER,
                        c_ae_header_id NUMBER) IS
    SELECT
           ael.code_combination_id
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_lines            ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
      AND zx_dist.trx_level_type = c_trx_level_type
       AND zx_dist.trx_line_id = c_trx_line_id
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST'
       --AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
       AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
       AND lnk.ae_header_id   = ael.ae_header_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND lnk.event_id       = c_event_id
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.application_id = ael.application_id
       AND ael.accounting_class_code <> 'LIABILITY'
       AND rownum =1;

  CURSOR trx_dist_ccid_tax_event (c_application_id number,
                        c_entity_code varchar2,
                        c_event_class_code varchar2,
                        c_trx_level_type varchar2,
                        c_trx_id NUMBER,
                        c_trx_line_id NUMBER,
                        c_tax_line_dist_id NUMBER,
                        c_event_id NUMBER,
                        c_ae_header_id NUMBER) IS
    SELECT
           ael.code_combination_id
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_lines            ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
      AND zx_dist.trx_level_type = c_trx_level_type
       AND zx_dist.trx_line_id = c_trx_line_id
       AND zx_dist.rec_nrec_tax_dist_id = c_tax_line_dist_id
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST'
       AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
       AND lnk.ae_header_id   = ael.ae_header_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND lnk.application_id = ael.application_id
       AND ael.accounting_class_code not in ('NRTAX','RTAX','LIABILITY')
       AND rownum =1;

  CURSOR tax_ccid (c_application_id number,
                   c_entity_code varchar2,
                   c_event_class_code varchar2,
                   c_trx_level_type varchar2,
                   c_trx_id number,
                   c_event_id number,
                   c_ae_header_id number) IS
    SELECT
           ael.code_combination_id
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_lines              ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
       AND zx_dist.trx_level_type = c_trx_level_type
       AND lnk.application_id = 200
       --AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
       AND lnk.source_distribution_type = 'AP_INV_DIST'
       AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
       AND lnk.ae_header_id   = ael.ae_header_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND lnk.event_id       = c_event_id
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.application_id = ael.application_id
       AND rownum =1;


  CURSOR tax_line_ccid (c_application_id number,
                        c_entity_code varchar2,
                        c_event_class_code varchar2,
                        c_trx_level_type varchar2,
                        c_trx_id number,
                        c_tax_line_id NUMBER,
                        c_event_id number,
                        c_ae_header_id number) IS
    SELECT
           ael.code_combination_id
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_lines              ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
       AND zx_dist.trx_level_type = c_trx_level_type
       AND zx_dist.tax_line_id = c_tax_line_id
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
       AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
       AND lnk.ae_header_id   = ael.ae_header_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND lnk.event_id       = c_event_id
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.application_id = ael.application_id
       AND rownum =1;

-- For transaction distribution level code combination id select in the build SQL
-- The following query can be removed ----

  CURSOR tax_dist_ccid (c_application_id number,
                        c_entity_code varchar2,
                        c_event_class_code varchar2,
                        c_trx_level_type varchar2,
                        c_trx_id NUMBER,
                        c_tax_line_id NUMBER,
                        c_tax_line_dist_id NUMBER,
                        c_event_id number,
                        c_ae_header_id number) IS
    SELECT
            ael.code_combination_id
       FROM zx_rec_nrec_dist zx_dist,
            xla_distribution_links lnk,
            xla_ae_lines              ael
      WHERE zx_dist.trx_id = c_trx_id
        AND zx_dist.APPLICATION_ID = c_application_id
        AND zx_dist.entity_code = c_entity_code
        AND zx_dist.event_class_Code = c_event_class_code
        AND zx_dist.trx_level_type = c_trx_level_type
        AND zx_dist.tax_line_id = c_tax_line_id
        AND zx_dist.REC_NREC_TAX_DIST_ID = c_tax_line_dist_id
        AND lnk.application_id = 200
        AND lnk.source_distribution_type = 'AP_INV_DIST'
        --AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
        AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
        AND lnk.ae_header_id   = ael.ae_header_id
        AND lnk.ae_line_num    = ael.ae_line_num
        AND lnk.event_id       = c_event_id
        AND lnk.ae_header_id   = c_ae_header_id
        AND lnk.application_id = ael.application_id
        AND ael.accounting_class_code <> 'LIABILITY'
        AND rownum =1;



  l_disc_is_inv_less_tax_flag     VARCHAR2(1);
  l_disc_distribution_method      VARCHAR2(30);
  l_liability_post_lookup_code    VARCHAR2(30);

  L_BAL_SEG_VAL                   VARCHAR2(240);
  L_ACCT_SEG_VAL                  VARCHAR2(240);
  L_SQL_STATEMENT1                VARCHAR2(1000);
--  L_SQL_STATEMENT2                VARCHAR2(1000);
  l_ccid number;
  l_tax_dist_ccid number;
  l_trx_dist_ccid number;

  l_balancing_seg_val  varchar2(100);
  l_natural_acct_val  varchar2(100);

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info.BEGIN',
                                        'get_accounting_info(+)');
  END IF;

  GT_TRX_ARAP_BALANCING_SEGMENT(j)    := NULL;
  GT_TRX_ARAP_NATURAL_ACCOUNT(j)      := NULL;
  GT_TRX_TAXABLE_BAL_SEG(j)           := NULL;
  GT_TRX_TAXABLE_NATURAL_ACCOUNT(j)   := NULL;
  GT_TRX_TAX_BALANCING_SEGMENT(j)     := NULL;
  GT_TRX_TAX_NATURAL_ACCOUNT(j)       := NULL;
  GT_ACCOUNT_FLEXFIELD(j)             := NULL;
  GT_ACCOUNT_DESCRIPTION(j)           := NULL;

 GT_TRX_CONTROL_ACCFLEXFIELD(j) := NULL ;
 GT_TRX_TAXABLE_ACCOUNT_DESC(j) := NULL ;
 GT_TRX_TAXABLE_BALSEG_DESC(j) := NULL ;
 GT_TRX_TAXABLE_NATACCT_DESC(j) := NULL ;


  L_BAL_SEG_VAL := '';
  L_ACCT_SEG_VAL := '';

  L_SQL_STATEMENT1 := ' SELECT '||P_BALANCING_SEGMENT ||','||P_ACCOUNTING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';

  OPEN get_system_info_cur(p_org_id);
  FETCH get_system_info_cur
   INTO l_disc_distribution_method,
        l_disc_is_inv_less_tax_flag,
        l_liability_post_lookup_code;
  CLOSE get_system_info_cur;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.get_accounting_info.BEGIN',
                'l_disc_distribution_method  : '||l_disc_distribution_method);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.get_accounting_info.BEGIN',
                'l_disc_is_inv_less_tax_flag  : '||l_disc_is_inv_less_tax_flag);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.get_accounting_info.BEGIN',
                'l_liability_post_lookup_code  : '||l_liability_post_lookup_code);
  END IF;

  IF NVL(l_disc_is_inv_less_tax_flag, 'N') = 'N' AND
     NVL(l_disc_distribution_method, 'SYSTEM') <> 'SYSTEM' THEN

    IF P_INCLUDE_DISCOUNTS = 'Y' THEN
       get_discount_info(j,
                         P_TRX_ID,
                         P_TAX_LINE_ID,
                         P_SUMMARY_LEVEL,
                         P_TAX_DIST_ID,
                         P_TRX_LINE_ID,
                         P_TRX_LINE_DIST_ID,
                         P_TAX_REC_FLAG,
                         p_tax_regime_code,
                         p_tax,
                         p_tax_status_code,
                         p_tax_rate_id,
                         P_LEDGER_ID,
                         l_disc_distribution_method,
                         l_liability_post_lookup_code);
    END IF;
  END IF;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'P_SUMMARY_LEVEL'||P_SUMMARY_LEVEL);
  END IF;

  IF P_SUMMARY_LEVEL = 'TRANSACTION' THEN
    OPEN trx_ccid (p_application_id,
                     p_entity_code,
               p_event_class_code,
               p_trx_level_type,
               p_trx_id,
               p_event_id,
               p_ae_header_id);
    LOOP
      FETCH trx_ccid INTO l_ccid;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
            'TRANSACTION LEVEL : p_trx_id - p_event_id - p_ae_header_id'||to_char(p_trx_id)
                 ||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)||'-'||to_char(l_ccid));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
            'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT1);
      END IF;


          EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL, L_ACCT_SEG_VAL
                                            USING l_ccid;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
            'TRANSACTION LEVEL : p_trx_id - p_event_id - p_ae_header_id'||to_char(p_trx_id)
                 ||'-'||to_char(p_event_id)||'-'||to_char(p_ae_header_id)||'-'||to_char(l_ccid));
      END IF;

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
      EXIT WHEN trx_ccid%NOTFOUND;
    END LOOP;


    OPEN tax_ccid (p_application_id,
                   p_entity_code,
             p_event_class_code,
             p_trx_level_type,
                   p_trx_id,
             p_event_id,
             p_ae_header_id);
    LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

      EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL, L_ACCT_SEG_VAL
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
    OPEN trx_line_ccid (p_application_id,
              p_entity_code,
                   p_event_class_code,
                   p_trx_level_type,
              p_trx_id,
              p_trx_line_id,
              p_event_id,
              p_ae_header_id);
    LOOP
      FETCH trx_line_ccid INTO l_ccid;
      EXIT WHEN trx_line_ccid%NOTFOUND;

      EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL, L_ACCT_SEG_VAL
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


    OPEN tax_line_ccid (p_application_id,
                        p_entity_code,
                        p_event_class_code,
                        p_trx_level_type,
                        p_trx_id,
                        p_tax_line_id,
                        p_event_id,
                        p_ae_header_id);
    LOOP
      FETCH tax_line_ccid INTO l_ccid;
      EXIT WHEN tax_line_ccid%NOTFOUND;

      EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL, L_ACCT_SEG_VAL
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
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'TRANSACTION_DISTRIBUTION LEVEL');
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'trx_dist_ccid cursor :');
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'P_TRX_ID :'||to_char(P_TRX_ID));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'P_TRX_LINE_ID :'||to_char(P_TRX_LINE_ID));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'P_TAX_LINE_ID :'||to_char(P_TAX_LINE_ID));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'P_EVENT_ID :'||to_char(P_EVENT_ID));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'P_AE_HEADER_ID :'||to_char(P_AE_HEADER_ID));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                    'P_TAX_DIST_ID :'||to_char(P_TAX_DIST_ID));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
        'L_SQL_STATEMENT1: ' ||L_SQL_STATEMENT1);

    END IF;
    OPEN trx_dist_ccid (
            p_application_id,
            p_entity_code,
            p_event_class_code,
            p_trx_level_type,
            p_trx_id,
            p_trx_line_id,
            p_event_id,
            p_ae_header_id);

      FETCH trx_dist_ccid INTO l_ccid;

      IF trx_dist_ccid%NOTFOUND OR l_ccid IS NULL THEN
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                  'Cursor trx_dist_ccid Not Found, So open cursor trx_dist_ccid_tax_event');
       END IF;

       OPEN trx_dist_ccid_tax_event (
            p_application_id,
            p_entity_code,
            p_event_class_code,
            p_trx_level_type,
            p_trx_id,
            p_trx_line_id,
            p_tax_dist_id,
            p_event_id,
            p_ae_header_id);

      FETCH trx_dist_ccid_tax_event INTO l_ccid;
      CLOSE trx_dist_ccid_tax_event;
      END IF;

      CLOSE trx_dist_ccid;

      l_trx_dist_ccid := l_ccid ; --Bug 5510907

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'l_trx_dist_ccid :'||l_trx_dist_ccid);
      END IF;

      IF l_trx_dist_ccid IS NOT NULL THEN
          EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL, L_ACCT_SEG_VAL
                                        USING l_ccid;
      END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'L_BAL_SEG_VAL :'||L_BAL_SEG_VAL);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'L_ACCT_SEG_VAL :'||L_ACCT_SEG_VAL);
      END IF;
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
--    END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info.BEGIN',
                                      'tax_dist_ccid cursor :');
    END IF;

    OPEN tax_dist_ccid (p_application_id,
                        p_entity_code,
                        p_event_class_code,
                        p_trx_level_type,
                        p_trx_id,
                        p_tax_line_id,
                        p_tax_dist_id,
                        p_event_id,
                        p_ae_header_id);
    LOOP
      FETCH tax_dist_ccid INTO l_ccid;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'TRANSACTION_DISTRIBUTION LEVEL');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'tax_dist_ccid cursor :');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'P_TRX_ID :'||to_char(P_TRX_ID));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'P_TaX_LINE_ID :'||to_char(P_TAX_LINE_ID));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'P_TAX_dist_ID :'||to_char(P_TAX_DIST_ID));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'P_EVENT_ID :'||to_char(P_EVENT_ID));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'P_AE_HEADER_ID :'||to_char(P_AE_HEADER_ID));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'l_ccid :'||to_char(l_ccid));
      END IF;

      EXIT WHEN tax_dist_ccid%NOTFOUND;

      l_tax_dist_ccid := l_ccid;
      EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL, L_ACCT_SEG_VAL
                                        USING l_ccid;


      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'L_BAL_SEG_VAL :'||L_BAL_SEG_VAL);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info',
                                      'L_ACCT_SEG_VAL :'||L_ACCT_SEG_VAL);
      END IF;

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
                         P_ID_FLEX_NUM => g_chart_of_accounts_id,
                         P_QUALIFIER => 'ALL',
                         P_CCID => l_tax_dist_ccid);

       IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                                   'Account Flexfield = '||GT_ACCOUNT_FLEXFIELD(j));
       END IF;

       GT_ACCOUNT_DESCRIPTION(j) := FA_RX_FLEX_PKG.GET_DESCRIPTION(
                         P_APPLICATION_ID => 101,
                         P_ID_FLEX_CODE => 'GL#',
                         P_ID_FLEX_NUM => g_chart_of_accounts_id,
                         P_QUALIFIER => 'ALL',
                         P_DATA => GT_ACCOUNT_FLEXFIELD(j));

       IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                                   'Account Description = '||GT_ACCOUNT_DESCRIPTION(j));
       END IF;

    END IF;

--Bug 5510907 : To get the accounting Flexfield for the Taxable Line

    IF l_trx_dist_ccid IS NOT NULL THEN

      GT_TRX_CONTROL_ACCFLEXFIELD(j) := FA_RX_FLEX_PKG.GET_VALUE(
                        P_APPLICATION_ID => 101,
                        P_ID_FLEX_CODE => 'GL#',
                        P_ID_FLEX_NUM => g_chart_of_accounts_id,
                        P_QUALIFIER => 'ALL',
                        P_CCID => l_trx_dist_ccid);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                                  'Taxable Line Account Flexfield = '||GT_TRX_CONTROL_ACCFLEXFIELD(j));
      END IF;
--Bug 5650415
      GT_TRX_TAXABLE_ACCOUNT_DESC(j) := FA_RX_FLEX_PKG.GET_DESCRIPTION(
                        P_APPLICATION_ID => 101,
                        P_ID_FLEX_CODE => 'GL#',
                        P_ID_FLEX_NUM => g_chart_of_accounts_id,
                        P_QUALIFIER => 'ALL',
                        P_DATA => GT_TRX_CONTROL_ACCFLEXFIELD(j));

      IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                                  'Account Description for Taxable Line CCID  = '||GT_TRX_TAXABLE_ACCOUNT_DESC(j));
      END IF;

    END IF ;
/* Bug 5650415 : Logic Added to Populate the description for the Natural and balancing Segments Description
for taxable line account */

    IF l_trx_dist_ccid IS NOT NULL THEN

      l_balancing_seg_val := FA_RX_FLEX_PKG.GET_VALUE(
            P_APPLICATION_ID => 101,
            P_ID_FLEX_CODE => 'GL#',
            P_ID_FLEX_NUM => g_chart_of_accounts_id,
            P_QUALIFIER => 'GL_BALANCING',
            P_CCID => l_trx_dist_ccid);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                ' l_balancing_seg_val for TaxableLine = '||l_balancing_seg_val);
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                ' g_chart_of_accounts_id = '||g_chart_of_accounts_id);
      END IF;

      IF ( l_balancing_seg_val IS NOT NULL ) THEN
        GT_TRX_TAXABLE_BALSEG_DESC(j) := FA_RX_FLEX_PKG.GET_DESCRIPTION(
              P_APPLICATION_ID => 101,
              P_ID_FLEX_CODE => 'GL#',
              P_ID_FLEX_NUM => g_chart_of_accounts_id,
              P_QUALIFIER => 'GL_BALANCING',
              P_DATA => l_balancing_seg_val);

        IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                  'Balacing Seg Description for Taxable Line CCID  = '||GT_TRX_TAXABLE_BALSEG_DESC(j));
        END IF;
      END IF ;
    --Populate the Natural Account desccription after fetching its value
      l_natural_acct_val := FA_RX_FLEX_PKG.GET_VALUE(
          P_APPLICATION_ID => 101,
          P_ID_FLEX_CODE => 'GL#',
          P_ID_FLEX_NUM => g_chart_of_accounts_id,
          P_QUALIFIER => 'GL_ACCOUNT',
          P_CCID => l_trx_dist_ccid);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                ' l_balancing_seg_val for TaxableLine = '||l_natural_acct_val);
      END IF;

      IF ( l_balancing_seg_val IS NOT NULL ) THEN
        GT_TRX_TAXABLE_NATACCT_DESC(j) := FA_RX_FLEX_PKG.GET_DESCRIPTION(
              P_APPLICATION_ID => 101,
              P_ID_FLEX_CODE => 'GL#',
              P_ID_FLEX_NUM => g_chart_of_accounts_id,
              P_QUALIFIER => 'GL_ACCOUNT',
              P_DATA => l_natural_acct_val);

        IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.GET_ACCOUNTING_INFO',
                  'Balacing Seg Description for Taxable Line CCID  = '||GT_TRX_TAXABLE_NATACCT_DESC(j));
        END IF;
      END IF ;

    END IF ;

  ---- End of accounting flexfield population -----------------------
  END IF; -- Summary Level

  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_info.END',
                                      'get_accounting_info(-)');
    END IF;

END get_accounting_info;


PROCEDURE get_accounting_amounts (
               P_APPLICATION_ID        IN NUMBER,
               P_ENTITY_CODE           IN VARCHAR2,
               P_EVENT_CLASS_CODE      IN VARCHAR2,
               P_TRX_LEVEL_TYPE        IN VARCHAR2,
               P_TRX_ID                IN NUMBER,
               P_TRX_LINE_ID           IN NUMBER,
               P_TAX_LINE_ID           IN NUMBER,
--               P_ENTITY_ID             IN NUMBER,
               P_EVENT_ID              IN NUMBER,
               P_AE_HEADER_ID          IN NUMBER,
               P_TAX_DIST_ID           IN NUMBER,
               P_SUMMARY_LEVEL         IN VARCHAR2,
               P_REPORT_NAME           IN VARCHAR2,
               P_LEDGER_ID             IN NUMBER,
               j                       IN binary_integer,
               p_ae_line_num           IN NUMBER ) IS
-- Transaction Header Level

   CURSOR taxable_amount_hdr (c_application_id number,
                      c_entity_code varchar2,
                      c_event_class_code varchar2,
                      c_trx_level_type varchar2,
                      c_trx_id NUMBER,
                      c_ae_header_id NUMBER,
                      c_event_id NUMBER,
                      c_ledger_id NUMBER) IS
     SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_headers         aeh,
           xla_ae_lines           ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
       AND zx_dist.trx_level_type = c_trx_level_type
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST' --Bug 5393051
       AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_id
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.event_id = c_event_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND lnk.ae_header_id   = ael.ae_header_id
       AND aeh.ae_header_id   = ael.ae_header_id
       AND aeh.ledger_id = c_ledger_id
       AND aeh.ae_header_id = lnk.ae_header_id
       AND aeh.application_id = lnk.application_id
       AND ael.application_id = aeh.application_id;


   CURSOR tax_amount_hdr (c_application_id number,
                  c_entity_code varchar2,
                  c_event_class_code varchar2,
                  c_trx_level_type varchar2,
                  c_trx_id NUMBER,
                  c_ae_header_id NUMBER,
                  c_event_id NUMBER,
                  c_ledger_id NUMBER) IS
     SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_headers         aeh,
           xla_ae_lines              ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
       AND zx_dist.trx_level_type = c_trx_level_type
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST' --Bug 5393051
       AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.event_id = c_event_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND aeh.ae_header_id   = ael.ae_header_id
       AND aeh.ledger_id = c_ledger_id
       AND aeh.ae_header_id = lnk.ae_header_id
       AND aeh.application_id = lnk.application_id
       AND ael.application_id = aeh.application_id;


-- Transaction Line Level

  CURSOR taxable_amount_line (c_application_id number,
                     c_entity_code varchar2,
                     c_event_class_code varchar2,
                     c_trx_level_type varchar2,
                     c_trx_id NUMBER,
                     c_trx_line_id NUMBER,
                     c_ae_header_id NUMBER,
                     c_event_id NUMBER,
                     c_ledger_id NUMBER) IS
    SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
     FROM zx_rec_nrec_dist zx_dist,
          xla_distribution_links lnk,
          xla_ae_headers         aeh,
          xla_ae_lines              ael
    WHERE zx_dist.trx_id = c_trx_id
      AND zx_dist.APPLICATION_ID = c_application_id
      AND zx_dist.entity_code = c_entity_code
      AND zx_dist.event_class_Code = c_event_class_code
      AND zx_dist.trx_level_type = c_trx_level_type
      AND zx_dist.trx_line_id = c_trx_line_id
      AND lnk.application_id = 200
      AND lnk.source_distribution_type = 'AP_INV_DIST' --Bug 5393051
      AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_id
      AND lnk.ae_header_id   = c_ae_header_id
      AND lnk.event_id       = c_event_id
      AND lnk.ae_line_num    = ael.ae_line_num
      AND aeh.ae_header_id   = ael.ae_header_id
      AND aeh.ledger_id      = c_ledger_id
      AND aeh.ae_header_id = lnk.ae_header_id
      AND aeh.application_id = lnk.application_id
      AND ael.application_id = aeh.application_id;


  CURSOR tax_amount_line (c_application_id number,
                c_entity_code varchar2,
                c_event_class_code varchar2,
                c_trx_level_type varchar2,
                c_trx_id NUMBER,
                c_tax_line_id NUMBER,
                c_ae_header_id NUMBER,
                c_event_id NUMBER,
                c_ledger_id NUMBER) IS
    SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
     FROM zx_rec_nrec_dist zx_dist,
          xla_distribution_links lnk,
          xla_ae_headers         aeh,
          xla_ae_lines              ael
    WHERE zx_dist.trx_id = c_trx_id
      AND zx_dist.APPLICATION_ID = c_application_id
      AND zx_dist.entity_code = c_entity_code
      AND zx_dist.event_class_Code = c_event_class_code
      AND zx_dist.trx_level_type = c_trx_level_type
      AND zx_dist.tax_line_id = c_tax_line_id
      AND lnk.application_id = 200
      AND lnk.source_distribution_type = 'AP_INV_DIST' --Bug 5393051
      AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
      AND lnk.ae_header_id   = c_ae_header_id
      AND lnk.event_id       = c_event_id
      AND lnk.ae_line_num    = ael.ae_line_num
      AND aeh.ae_header_id   = ael.ae_header_id
      AND aeh.ledger_id      = c_ledger_id
      AND aeh.ae_header_id = lnk.ae_header_id
      AND aeh.application_id = lnk.application_id
      AND ael.application_id = aeh.application_id;


-- Transaction Distribution Level



  CURSOR tax_amount_dist (c_application_id number,
                c_entity_code varchar2,
                c_event_class_code varchar2,
                c_trx_level_type varchar2,
                c_trx_id NUMBER,
                c_tax_line_id NUMBER,
                c_tax_dist_id NUMBER,
                c_ae_header_id NUMBER,
                c_event_id NUMBER,
                c_ledger_id NUMBER,
                c_ae_line_num NUMBER ) IS
    SELECT SUM( nvl(lnk.UNROUNDED_ENTERED_DR,0) - (nvl(lnk.UNROUNDED_ENTERED_CR,0) )) ,
               SUM( nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - (nvl(lnk.UNROUNDED_ACCOUNTED_CR,0) ))
    /*SUM( (NVL(lnk.UNROUNDED_ENTERED_CR,0) * -1) - NVL(lnk.UNROUNDED_ENTERED_DR,0)),
               SUM((NVL(lnk.UNROUNDED_ACCOUNTED_CR,0) * -1) - NVL(lnk.UNROUNDED_ACCOUNTED_DR,0))

--sum(nvl(lnk.UNROUNDED_ENTERED_CR,0)) - sum(nvl(lnk.UNROUNDED_ENTERED_DR,0)),
--    sum(nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)) - SUM(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0)) --Bug 5393051
    Nvl(sum(decode(zx_dist.REVERSE_FLAG,'Y',lnk.UNROUNDED_ENTERED_CR * -1,lnk.UNROUNDED_ENTERED_DR)),0),
    Nvl(sum(decode(zx_dist.REVERSE_FLAG,'Y',lnk.UNROUNDED_ACCOUNTED_CR * -1,lnk.UNROUNDED_ACCOUNTED_DR)),0)
    */
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_headers         aeh,
           xla_ae_lines              ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
       AND zx_dist.trx_level_type = c_trx_level_type
       AND zx_dist.tax_line_id = c_tax_line_id
       AND zx_dist.rec_nrec_tax_dist_id = c_tax_dist_id
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST' --Bug 5393051
       AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.event_id       = c_event_id
       AND lnk.ae_line_num = c_ae_line_num
       AND lnk.ae_line_num    = ael.ae_line_num
       AND aeh.ae_header_id   = ael.ae_header_id
       AND aeh.ledger_id      = c_ledger_id
       AND aeh.ae_header_id = lnk.ae_header_id
       AND aeh.application_id = lnk.application_id
       AND ael.application_id = aeh.application_id;


  CURSOR taxable_amount_dist (c_application_id number,
                     c_entity_code varchar2,
                     c_event_class_code varchar2,
                     c_trx_level_type varchar2,
                     c_trx_id NUMBER,
                     c_trx_line_id NUMBER,
                     c_ae_header_id NUMBER,
                     c_event_id NUMBER,
                     c_ledger_id NUMBER,
                     c_tax_dist_id NUMBER
            ) IS
      SELECT SUM(decode(zx_dist.reverse_flag, 'Y',
                (abs(nvl(lnk.UNROUNDED_ENTERED_DR,0) -(nvl(lnk.UNROUNDED_ENTERED_CR,0))) *
                    (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
                (nvl(lnk.UNROUNDED_ENTERED_DR,0) - nvl(lnk.UNROUNDED_ENTERED_CR,0)))),
             SUM(decode(zx_dist.reverse_flag, 'Y',
                (abs(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - (nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)))*
                    (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
                (nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - nvl(lnk.UNROUNDED_ACCOUNTED_CR,0))))
/*    SELECT SUM( abs(nvl(lnk.UNROUNDED_ENTERED_DR,0) - (nvl(lnk.UNROUNDED_ENTERED_CR,0))) *
             (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
           SUM( abs(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - (nvl(lnk.UNROUNDED_ACCOUNTED_CR,0))) *
             (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT))))
*/
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_headers         aeh,
           xla_ae_lines              ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
       AND zx_dist.trx_level_type = c_trx_level_type
       AND zx_dist.trx_line_id  = c_trx_line_id
--      AND zx_dist.trx_line_dist_id  = c_trx_line_dist_id
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST' --Bug 5393051
       AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
       AND zx_dist.rec_nrec_tax_dist_id = c_tax_dist_id --Bug 5393051
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.event_id = c_event_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND aeh.ae_header_id   = ael.ae_header_id
       AND ael.accounting_class_code not in ('NRTAX','RTAX','LIABILITY','EXCHANGE_RATE_VARIANCE')
       AND aeh.ledger_id      = c_ledger_id
       AND aeh.ae_header_id = lnk.ae_header_id
       AND aeh.application_id = lnk.application_id
       AND ael.application_id = aeh.application_id;



  CURSOR taxable_amount_dist_ERV (c_application_id number,
                     c_entity_code varchar2,
                     c_event_class_code varchar2,
                     c_trx_level_type varchar2,
                     c_trx_id NUMBER,
                     c_trx_line_id NUMBER,
                     c_ae_header_id NUMBER,
                     c_event_id NUMBER,
                     c_ledger_id NUMBER,
                     c_tax_dist_id NUMBER
            ) IS
      SELECT SUM( (nvl(lnk.UNROUNDED_ENTERED_DR,0) - nvl(lnk.UNROUNDED_ENTERED_CR,0))),
             SUM( (nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)))
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_headers         aeh,
           xla_ae_lines              ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
       AND zx_dist.trx_level_type = c_trx_level_type
       AND zx_dist.trx_line_id  = c_trx_line_id
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST'
       AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
       AND zx_dist.rec_nrec_tax_dist_id = c_tax_dist_id
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.event_id = c_event_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND aeh.ae_header_id   = ael.ae_header_id
       AND ael.accounting_class_code = 'EXCHANGE_RATE_VARIANCE'
       AND aeh.ledger_id      = c_ledger_id
       AND aeh.ae_header_id = lnk.ae_header_id
       AND aeh.application_id = lnk.application_id
       AND ael.application_id = aeh.application_id;


  CURSOR taxable_amount_dist2 (c_application_id number,
                     c_entity_code varchar2,
                     c_event_class_code varchar2,
                     c_trx_level_type varchar2,
                     c_trx_id NUMBER,
                     c_trx_line_id NUMBER,
                     c_ae_header_id NUMBER,
                     c_event_id NUMBER,
                     c_ledger_id NUMBER,
                     c_tax_dist_id NUMBER
            ) IS
      SELECT SUM(decode(zx_dist.reverse_flag, 'Y',
                (abs(nvl(lnk.UNROUNDED_ENTERED_DR,0) -(nvl(lnk.UNROUNDED_ENTERED_CR,0))) *
                    (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
                (nvl(lnk.UNROUNDED_ENTERED_DR,0) - nvl(lnk.UNROUNDED_ENTERED_CR,0)))),
             SUM(decode(zx_dist.reverse_flag, 'Y',
                (abs(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - (nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)))*
                    (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
                (nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - nvl(lnk.UNROUNDED_ACCOUNTED_CR,0))))
/*    SELECT SUM( abs(nvl(lnk.UNROUNDED_ENTERED_DR,0) - (nvl(lnk.UNROUNDED_ENTERED_CR,0))) *
             (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
           SUM( abs(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - (nvl(lnk.UNROUNDED_ACCOUNTED_CR,0))) *
             (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT))))
*/
      FROM zx_rec_nrec_dist zx_dist,
           xla_distribution_links lnk,
           xla_ae_headers         aeh,
           xla_ae_lines              ael
     WHERE zx_dist.trx_id = c_trx_id
       AND zx_dist.APPLICATION_ID = c_application_id
       AND zx_dist.entity_code = c_entity_code
       AND zx_dist.event_class_Code = c_event_class_code
       AND zx_dist.trx_level_type = c_trx_level_type
       AND zx_dist.trx_line_id  = c_trx_line_id
--      AND zx_dist.trx_line_dist_id  = c_trx_line_dist_id
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST' --Bug 5393051
       AND lnk.alloc_to_dist_id_num_1 = zx_dist.trx_line_dist_id
       AND lnk.alloc_to_dist_id_num_1<>lnk.source_distribution_id_num_1
       AND zx_dist.rec_nrec_tax_dist_id = c_tax_dist_id --Bug 5393051
       AND lnk.ae_header_id   = c_ae_header_id
       AND lnk.event_id = c_event_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND aeh.ae_header_id   = ael.ae_header_id
       AND ael.accounting_class_code not in ('NRTAX','RTAX','LIABILITY')
       AND aeh.ledger_id      = c_ledger_id
       AND aeh.ae_header_id = lnk.ae_header_id
       AND aeh.application_id = lnk.application_id
       AND ael.application_id = aeh.application_id;

  CURSOR taxable_amount_dist1
        (c_application_id number,
         c_entity_code varchar2,
         c_event_class_code varchar2,
         c_trx_level_type varchar2,
         c_trx_id NUMBER,
         c_trx_line_id NUMBER,
         c_ledger_id NUMBER,
         c_tax_dist_id NUMBER
         ) IS
    SELECT SUM(decode(zx_dist.reverse_flag, 'Y',
                (abs(nvl(lnk.UNROUNDED_ENTERED_DR,0) -(nvl(lnk.UNROUNDED_ENTERED_CR,0))) *
                    (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
                (nvl(lnk.UNROUNDED_ENTERED_DR,0) - nvl(lnk.UNROUNDED_ENTERED_CR,0)))),
           SUM(decode(zx_dist.reverse_flag, 'Y',
              (abs(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - (nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)))*
                  (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
              (nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - nvl(lnk.UNROUNDED_ACCOUNTED_CR,0))))
/*    SELECT SUM( abs(nvl(lnk.UNROUNDED_ENTERED_DR,0) - (nvl(lnk.UNROUNDED_ENTERED_CR,0))) *
             (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT)))),
           SUM( abs(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - (nvl(lnk.UNROUNDED_ACCOUNTED_CR,0)))  *
             (decode(sign(zx_dist.TRX_LINE_DIST_AMT),0,1,sign(zx_dist.TRX_LINE_DIST_AMT))))
*/
     FROM zx_rec_nrec_dist zx_dist,
          xla_ae_lines              ael,
          xla_distribution_links lnk
    WHERE zx_dist.trx_id = c_trx_id
      AND zx_dist.APPLICATION_ID = c_application_id
      AND zx_dist.entity_code = c_entity_code
      AND zx_dist.event_class_Code = c_event_class_code
      AND zx_dist.trx_level_type = c_trx_level_type
      AND zx_dist.trx_line_id  = c_trx_line_id
      AND lnk.application_id = 200
      AND lnk.source_distribution_type = 'AP_INV_DIST'
      AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
      /*AND( lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id OR
            lnk.alloc_to_dist_id_num_1 = zx_dist.trx_line_dist_id
            AND lnk.alloc_to_dist_id_num_1<>lnk.source_distribution_id_num_1 )*/
      AND lnk.ae_line_num    = ael.ae_line_num
      AND lnk.ae_header_id   = ael.ae_header_id
      AND ael.application_id = lnk.application_id
      AND zx_dist.rec_nrec_tax_dist_id = c_tax_dist_id
      AND ael.accounting_class_code not in ('NRTAX','RTAX','LIABILITY')
      AND ael.ledger_id = c_ledger_id
      AND ROWNUM = 1;

  CURSOR taxable_amount_dist_no_tax
           ( c_trx_id NUMBER,
             c_trx_line_id NUMBER,
             --c_event_id NUMBER,
             c_ledger_id NUMBER
            ) IS
      SELECT SUM(nvl(lnk.UNROUNDED_ENTERED_DR,0) - nvl(lnk.UNROUNDED_ENTERED_CR,0)),
             SUM(nvl(lnk.UNROUNDED_ACCOUNTED_DR,0) - nvl(lnk.UNROUNDED_ACCOUNTED_CR,0))
      FROM ap_invoice_distributions_all ap_dist,
           xla_distribution_links lnk,
           xla_ae_headers         aeh,
           xla_ae_lines              ael
     WHERE ap_dist.invoice_id = c_trx_id
       AND ap_dist.historical_flag = 'Y'
       AND ap_dist.invoice_line_number  = c_trx_line_id
       AND lnk.application_id = 200
       AND lnk.source_distribution_type = 'AP_INV_DIST'
       AND lnk.source_distribution_id_num_1 = ap_dist.invoice_distribution_id
       AND lnk.event_id = ap_dist.accounting_event_id
       AND lnk.ae_line_num    = ael.ae_line_num
       AND aeh.ae_header_id   = ael.ae_header_id
       AND ael.accounting_class_code not in ('NRTAX','RTAX','LIABILITY')
       AND aeh.ledger_id      = c_ledger_id
       AND aeh.ae_header_id = lnk.ae_header_id
       AND aeh.application_id = lnk.application_id
       AND ael.application_id = aeh.application_id;


   l_erv_entered_amt number;
   l_erv_accounted_amt number;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                                      'get_accounting_amounts(+)');
    END IF;

--Bug 5393051 :
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'p_summary_level : '||p_summary_level);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'p_report_name   : '||p_report_name);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'j : '||to_char(j));
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'p_application_id : '||p_application_id);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_ENTITY_CODE : '||P_ENTITY_CODE);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_EVENT_CLASS_CODE : '||P_EVENT_CLASS_CODE);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_TRX_LEVEL_TYPE : '||P_TRX_LEVEL_TYPE);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_TRX_ID : '||P_TRX_ID);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_TRX_LINE_ID : '||P_TRX_LINE_ID);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_TAX_LINE_ID : '||P_TAX_LINE_ID);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_EVENT_ID : '||P_EVENT_ID);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_AE_HEADER_ID  : '||P_AE_HEADER_ID);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_TAX_DIST_ID  : '||P_TAX_DIST_ID);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'P_LEDGER_ID  : '||P_LEDGER_ID);
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',
                      'p_ae_line_num  : '||p_ae_line_num);

    END IF;

    IF p_summary_level = 'TRANSACTION' THEN
      OPEN taxable_amount_hdr(p_application_id,
                              p_entity_code,
                              p_event_class_code,
                              p_trx_level_type,
                              p_trx_id ,
                              p_ae_header_id ,
                              p_event_id,
                              p_ledger_id);
      FETCH taxable_amount_hdr INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
       --    EXIT WHEN taxable_amount_hdr%NOTFOUND;
       CLOSE taxable_amount_hdr;

      OPEN tax_amount_hdr(p_application_id,
                          p_entity_code,
                          p_event_class_code,
                          p_trx_level_type,
                          p_trx_id ,
                          p_ae_header_id ,
                          p_event_id,
                          p_ledger_id);
      FETCH tax_amount_hdr INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
--      EXIT WHEN tax_amount_hdr%NOTFOUND;
      CLOSE tax_amount_hdr;
    ELSIF p_summary_level = 'TRANSACTION_LINE' THEN
      OPEN taxable_amount_line(p_application_id,
                               p_entity_code,
                               p_event_class_code,
                               p_trx_level_type,
                               p_trx_id ,
                               p_trx_line_id,
                               p_ae_header_id ,
                               p_event_id,
                               p_ledger_id);
      FETCH taxable_amount_line INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
  --        EXIT WHEN taxable_amount_line%NOTFOUND;
        CLOSE taxable_amount_line;

      OPEN tax_amount_line(p_application_id,
                           p_entity_code,
                           p_event_class_code,
                           p_trx_level_type,
                           p_trx_id ,
                           p_trx_line_id,
                           p_ae_header_id ,
                           p_event_id,
                           p_ledger_id);
      FETCH tax_amount_line INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
--      EXIT WHEN tax_amount_line%NOTFOUND;
      CLOSE tax_amount_line;

    ELSIF p_summary_level = 'TRANSACTION_DISTRIBUTION' THEN
      OPEN taxable_amount_dist(p_application_id,
                               p_entity_code,
                               p_event_class_code,
                               p_trx_level_type,
                               p_trx_id ,
                               p_trx_line_id,
                               p_ae_header_id ,
                               p_event_id,
                               p_ledger_id,
                               p_tax_dist_id --Bug 5393051
                               );

      FETCH taxable_amount_dist INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);

         -- Open ERV cursor -- Bug#9410781

      OPEN taxable_amount_dist_ERV(p_application_id,
                               p_entity_code,
                               p_event_class_code,
                               p_trx_level_type,
                               p_trx_id ,
                               p_trx_line_id,
                               p_ae_header_id ,
                               p_event_id,
                               p_ledger_id,
                               p_tax_dist_id --Bug 5393051
                               );

      FETCH taxable_amount_dist_ERV INTO l_erv_entered_amt,l_erv_accounted_amt;

     GT_TAXABLE_AMT(j) := GT_TAXABLE_AMT(j) + l_erv_entered_amt ;
     GT_TAXABLE_AMT_FUNCL_CURR(j) := GT_TAXABLE_AMT_FUNCL_CURR(j) + l_erv_accounted_amt ;

      IF taxable_amount_dist%NOTFOUND OR GT_TAXABLE_AMT(j) IS NULL OR GT_TAXABLE_AMT_FUNCL_CURR(j) IS NULL THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts',
                          'Cursor taxable_amount_dist Not Found, So open cursor taxable_amount_dist1');
        END IF;
          OPEN taxable_amount_dist1 (p_application_id,
                                     p_entity_code,
                                     p_event_class_code,
                                     p_trx_level_type,
                                     p_trx_id ,
                                     p_trx_line_id,
                                     p_ledger_id,
                                     p_tax_dist_id);
          FETCH taxable_amount_dist1 INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);

       IF taxable_amount_dist1%NOTFOUND OR GT_TAXABLE_AMT(j) IS NULL OR GT_TAXABLE_AMT_FUNCL_CURR(j) IS NULL THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts',
                          'Cursor taxable_amount_dist1 Not Found, So open cursor taxable_amount_dist2');
        END IF;

         OPEN taxable_amount_dist2(p_application_id,
                               p_entity_code,
                               p_event_class_code,
                               p_trx_level_type,
                               p_trx_id ,
                               p_trx_line_id,
                               p_ae_header_id ,
                               p_event_id,
                               p_ledger_id,
                               p_tax_dist_id --Bug 5393051
                               );

          FETCH taxable_amount_dist2 INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);

          IF   (p_report_name = 'ZXXTATAT' AND (taxable_amount_dist2%NOTFOUND
                           OR GT_TAXABLE_AMT(j) IS NULL OR GT_TAXABLE_AMT_FUNCL_CURR(j) IS NULL )) THEN
               IF (g_level_procedure >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts',
                              'Cursor taxable_amount_dist2 Not Found, So open cursor taxable_amount_dist_no_tax');
               END IF;
               OPEN taxable_amount_dist_no_tax(p_trx_id,
                                            p_trx_line_id,
                                           -- p_event_id,
                                            p_ledger_id);
               FETCH taxable_amount_dist_no_tax INTO GT_TAXABLE_AMT(j),GT_TAXABLE_AMT_FUNCL_CURR(j);
               CLOSE taxable_amount_dist_no_tax;
          END IF;
          CLOSE taxable_amount_dist2;
      END IF;   -- Dist2 Cursor
          CLOSE taxable_amount_dist1;
      END IF;   -- Dist1 cursor

      CLOSE taxable_amount_dist;
      CLOSE taxable_amount_dist_ERV;

      OPEN tax_amount_dist(p_application_id,
                           p_entity_code,
                           p_event_class_code,
                           p_trx_level_type,
                           p_trx_id,
                           p_tax_line_id,
                           p_tax_dist_id,
                           p_ae_header_id ,
                           p_event_id,
                           p_ledger_id,
                           p_ae_line_num);
      FETCH tax_amount_dist INTO GT_TAX_AMT(j),GT_TAX_AMT_FUNCL_CURR(j);
 --     EXIT WHEN tax_amount_dist%NOTFOUND;
      CLOSE tax_amount_dist;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',' j : '||to_Char(j)||
                      'Taxable Amt  : '|| to_char(GT_TAXABLE_AMT(j)) ||'TAXABLE_AMT_FUNCL_CURR : '||
                      GT_TAXABLE_AMT_FUNCL_CURR(j));
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.BEGIN',' j : '||to_Char(j)||
                      'Tax Amt  : '|| to_char(GT_TAX_AMT(j)) ||'TAX_AMT_FUNCL_CURR : '||
                      GT_TAX_AMT_FUNCL_CURR(j));
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_accounting_amounts.END',
                      'get_accounting_amounts(-)');
    END IF;

  END get_accounting_amounts;


/*PROCEDURE get_discount_info
                ( i                      IN BINARY_INTEGER,
                 P_TRX_ID                       IN    NUMBER,
                 --  P_TAX_ID                       IN    NUMBER,
                 P_SUMMARY_LEVEL                IN    VARCHAR2,
                 P_DIST_ID                      IN    NUMBER,
                 P_TRX_LINE_ID                  IN    NUMBER,
                 P_DISC_DISTRIBUTION_METHOD     IN    VARCHAR2,
                 P_LIABILITY_POST_LOOKUP_CODE   IN    VARCHAR2
                 )
*/
PROCEDURE get_discount_info
                ( j                             IN BINARY_INTEGER,
                 P_TRX_ID                       IN NUMBER,
                 P_TAX_LINE_ID                  IN NUMBER,
                 P_SUMMARY_LEVEL                IN VARCHAR2,
                 P_DIST_ID                      IN NUMBER,
                 P_TRX_LINE_ID                  IN NUMBER,
                 P_TRX_LINE_DIST_ID             IN NUMBER,
                 P_TAX_REC_FLAG                 IN VARCHAR2,
                 p_tax_regime_code              IN VARCHAR2,
                 p_tax                          IN VARCHAR2,
                 p_tax_status_code              IN VARCHAR2,
                 p_tax_rate_id                  IN NUMBER,
                 P_LEDGER_ID                    IN NUMBER,
                 P_DISC_DISTRIBUTION_METHOD     IN VARCHAR2,
                 P_LIABILITY_POST_LOOKUP_CODE   IN VARCHAR2
                 )
IS

-- nipatel - I find lots of issues with this query. The main query only restricts
 -- invoices based on distribution line number. We should have a condition based on
 -- invoice id in the main query. The join to ap_invoices is not necessary since
 -- we already have trx_id as input parameter which can be used to join to
 -- ap_invoice_distributions or ap_invoice_payments. Why do we need the subquery?
 -- it seems to be unncessary if we put the same conditions in the main query.
 -- Need to get this query reviewed by AP team

/***
  CURSOR  taxable_hdr_csr IS
  SELECT sum(aphd.amount), -- discount amount (entered)
         sum(aphd.paid_base_amount) -- discount amount (accounted)
    FROM ap_invoice_distributions_all aid,
       --  ap_invoices_all ai,
         ap_invoice_payments_all aip,
         ap_payment_hist_dists aphd,
         ap_payment_history_all aph
   WHERE aid.invoice_id = p_trx_id -- ai.invoice_id
     AND aid.invoice_id = aip.invoice_id
     AND aid.distribution_line_number
                IN (SELECT distribution_line_number
                      FROM ap_invoice_distributions_all
                     WHERE invoice_id = p_trx_id
                       AND line_type_lookup_code = 'ITEM')
     AND aip.invoice_payment_id = aphd.invoice_payment_id
     AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
     AND aphd.invoice_distribution_id = aid.invoice_distribution_id
     AND nvl(aph.historical_flag, 'N') = 'N'
     AND aph.check_id = aip.check_id
***/
  CURSOR  taxable_hdr_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph,
           zx_rec_nrec_dist zx_dist
     WHERE aid.invoice_id = p_trx_id
       AND aid.invoice_id = aip.invoice_id
       AND zx_dist.recoverable_flag = p_tax_rec_flag
       AND aip.invoice_payment_id = aphd.invoice_payment_id
      --AND aid.line_type_lookup_code  in ('REC_TAX', 'NONREC_TAX')
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
       and aphd.ACCOUNTING_EVENT_ID = aph.ACCOUNTING_EVENT_ID
       and aphd.PAYMENT_HISTORY_ID = aph.PAYMENT_HISTORY_ID
       and zx_dist.trx_id = aid.invoice_id
       and ((zx_dist.trx_line_dist_id = aid.invoice_distribution_id) OR
           ((aid.line_type_lookup_code='IPV') and (zx_dist.trx_line_dist_id = aid.related_id)))
       and zx_dist.application_id = 200
       and zx_dist.tax_regime_code = p_tax_regime_code
       and zx_dist.tax = p_tax
       and zx_dist.tax_status_code = p_tax_status_code
       and zx_dist.tax_rate_id =  p_tax_rate_id
       AND zx_dist.entity_code = 'AP_INVOICES'
       and aph.TRANSACTION_TYPE = 'PAYMENT CREATED'
 UNION

 -- nipatel - I find lots of issues with this query. The main query only restricts
 -- invoices based on distribution line number. We should have a condition based on
 -- invoice id in the main query. The join to ap_invoices is not necessary since
 -- we already have trx_id as input parameter which can be used to join to
 -- ap_invoice_distributions or ap_invoice_payments. Why do we need the subquery?
 -- it seems to be unncessary if we put the same conditions in the main query. Also
 -- there a re no indexes based on  xal.Upg_Tax_Reference_ID2/3 whihc causes FTS
 -- on xla_ae_lines. Need to get this query reviewed by AP team and log a bug
 -- against XLA team for indexes.

  SELECT xal.entered_dr - xal.entered_cr ,
                -- discount entered amount (replace this with new xla colum names)
         xal.accounted_dr -xal.entered_cr
                -- discount entered amount (replace this with new xla colum names)
    FROM ap_invoice_distributions_all aid,
      --   ap_invoices_all ai,
         ap_invoice_payments_all aip,
         ap_payment_history_all aph,
         xla_ae_lines    xal
   WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
     AND aid.invoice_id = aip.invoice_id
     AND aid.distribution_line_number
                IN (SELECT distribution_line_number
                      FROM ap_invoice_distributions_all
                     WHERE invoice_id = p_trx_id
                       AND line_type_lookup_code = 'ITEM')
     AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
     AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
     AND xal.ledger_id = p_ledger_id
     AND xal.accounting_class_code = 'DISCOUNT'
     AND aph.check_id = aip.check_id
     AND nvl(aph.historical_flag, 'N') = 'Y';

 -- nipatel - I find lots of issues with this query. The main query only restricts
 -- invoices based on distribution line number. We should have a condition based on
 -- invoice id in the main query. The join to ap_invoices is not necessary since
 -- we already have trx_id as input parameter which can be used to join to
 -- ap_invoice_distributions or ap_invoice_payments. Why do we need the subquery?
 -- it seems to be unncessary if we put the same conditions in the main query. Also
 -- there a re no indexes based on  xal.Upg_Tax_Reference_ID2/3 whihc causes FTS
 -- on xla_ae_lines. Need to get this query reviewed by AP team and log a bug
 -- against XLA team for indexes.

/***
    CURSOR tax_hdr_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
       --    ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
       AND aid.distribution_line_number
                  IN (SELECT distribution_line_number
                        FROM ap_invoice_distributions_all
                       WHERE invoice_id = p_trx_id
                         AND line_type_lookup_code  in ('REC_TAX', 'NONREC_TAX'))
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
   -- New --
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
       AND aid.tax_recoverable_flag = p_tax_rec_flag
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aid.line_type_lookup_code  in ('REC_TAX', 'NONREC_TAX')
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
       and aphd.ACCOUNTING_EVENT_ID = aph.ACCOUNTING_EVENT_ID
       and aphd.PAYMENT_HISTORY_ID = aph.PAYMENT_HISTORY_ID
       --and aph.TRANSACTION_TYPE = 'PAYMENT CLEARING'
***/
  CURSOR tax_hdr_csr IS
SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph,
           zx_rec_nrec_dist zx_dist
     WHERE aid.invoice_id = p_trx_id
       AND aid.invoice_id = aip.invoice_id
       AND aid.tax_recoverable_flag = p_tax_rec_flag
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aid.line_type_lookup_code  in ('REC_TAX', 'NONREC_TAX')
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
       and aphd.ACCOUNTING_EVENT_ID = aph.ACCOUNTING_EVENT_ID
       and aphd.PAYMENT_HISTORY_ID = aph.PAYMENT_HISTORY_ID
       and zx_dist.trx_id = aid.invoice_id
       and zx_dist.rec_nrec_tax_dist_id = aid.detail_tax_dist_id
       and zx_dist.recoverable_flag = aid.tax_recoverable_flag
       and zx_dist.application_id = 200
       and zx_dist.tax_regime_code = p_tax_regime_code
       and zx_dist.tax = p_tax
       and zx_dist.tax_status_code = p_tax_status_code
       and zx_dist.tax_rate_id =  p_tax_rate_id
       AND zx_dist.entity_code = 'AP_INVOICES'
       and aph.TRANSACTION_TYPE = 'PAYMENT CREATED'
   UNION
    SELECT xal.entered_dr - xal.entered_cr ,
                  -- discount entered amount (replace this with new xla colum names)
           xal.accounted_dr -xal.entered_cr
                  -- discount entered amount (replace this with new xla colum names)
      FROM ap_invoice_distributions_all aid,
          -- ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_history_all aph,
           xla_ae_lines    xal
     WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
       AND aid.distribution_line_number
                  IN (SELECT distribution_line_number
                        FROM ap_invoice_distributions_all
                       WHERE invoice_id = p_trx_id
                         AND line_type_lookup_code = 'TAX')
       AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
       AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
       AND xal.accounting_class_code = 'DISCOUNT'
       AND aph.check_id = aip.check_id
       AND nvl(aph.historical_flag, 'N') = 'Y';


    CURSOR taxable_line_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           -- ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
--       AND aid.distribution_line_number
       AND aid.invoice_distribution_id = p_trx_line_id
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
   UNION
       SELECT xal.entered_dr - xal.entered_cr ,
                     -- discount entered amount (replace this with new xla colum names)
              xal.accounted_dr -xal.entered_cr
                     -- discount entered amount (replace this with new xla colum names)
         FROM ap_invoice_distributions_all aid,
          --    ap_invoices_all ai,
              ap_invoice_payments_all aip,
              ap_payment_history_all aph,
              xla_ae_lines    xal
        WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
          AND aid.invoice_id = aip.invoice_id
--          AND aid.distribution_line_number
          AND aid.invoice_distribution_id = p_trx_line_id
          AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
          AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
          AND xal.accounting_class_code = 'DISCOUNT'
          AND xal.ledger_id = p_ledger_id
          AND aph.check_id = aip.check_id
          AND nvl(aph.historical_flag, 'N') = 'Y';


CURSOR tax_line_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
          --  ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
--      AND aid.distribution_line_number
       AND aid.invoice_distribution_id = p_tax_line_id
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
   UNION
       SELECT xal.entered_dr - xal.entered_cr ,
                     -- discount entered amount (replace this with new xla colum names)
              xal.accounted_dr -xal.entered_cr
                     -- discount entered amount (replace this with new xla colum names)
         FROM ap_invoice_distributions_all aid,
              -- ap_invoices_all ai,
              ap_invoice_payments_all aip,
              ap_payment_history_all aph,
              xla_ae_lines    xal
        WHERE aid.invoice_id = p_trx_id -- ai.invoice_id
          AND aid.invoice_id = aip.invoice_id
--          AND aid.distribution_line_number
          AND aid.invoice_distribution_id = p_tax_line_id
          AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
          AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
          AND xal.ledger_id = p_ledger_id
          AND xal.accounting_class_code = 'DISCOUNT'
          AND aph.check_id = aip.check_id
          AND nvl(aph.historical_flag, 'N') = 'Y';


    CURSOR taxable_dist_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           -- ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph,
           zx_rec_nrec_dist zx_dist
     WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
       and ((zx_dist.trx_line_dist_id = aid.invoice_distribution_id) OR
           ((aid.line_type_lookup_code='IPV') and (zx_dist.trx_line_dist_id = aid.related_id)))
       AND zx_dist.rec_nrec_tax_dist_id = p_dist_id
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
       and aph.TRANSACTION_TYPE = 'PAYMENT CREATED'
   UNION
       SELECT SUM(NVL(xal.entered_dr,0) - NVL(xal.entered_cr,0)) ,
                     -- discount entered amount (replace this with new xla colum names)
              SUM(NVL(xal.accounted_dr,0) - NVL(xal.accounted_cr,0))
                     -- discount entered amount (replace this with new xla colum names)
         FROM ap_invoice_distributions_all aid,
              -- ap_invoices_all ai,
              ap_invoice_payments_all aip,
              ap_payment_history_all aph,
              xla_ae_lines    xal
        WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
          AND aid.invoice_id = aip.invoice_id
          AND aid.invoice_distribution_id = p_trx_line_dist_id
          AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
          AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
          AND xal.accounting_class_code = 'DISCOUNT'
          AND xal.ledger_id = p_ledger_id
          AND aph.check_id = aip.check_id
          AND nvl(aph.historical_flag, 'N') = 'Y';

CURSOR taxable_disc_sys_cur IS
SELECT sum(aphd.amount),
    sum(aphd.paid_base_amount)
   FROM ap_invoice_distributions_all aid,
        ap_invoice_payments_all aip,
        ap_payment_hist_dists aphd,
        ap_payment_history_all aph
  WHERE aid.invoice_id = p_trx_id
    AND aid.invoice_id = aip.invoice_id
    AND aip.invoice_payment_id = aphd.invoice_payment_id
    AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
    AND aphd.invoice_distribution_id = aid.invoice_distribution_id
    AND nvl(aph.historical_flag, 'N') = 'N'
    AND aph.check_id = aip.check_id
    AND aid.line_type_lookup_code not in ('REC_TAX', 'NONREC_TAX');

CURSOR tax_dist_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
          --  ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
--       AND aid.distribution_line_number
       AND aid.detail_tax_dist_id = p_dist_id
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
       AND aphd.ACCOUNTING_EVENT_ID = aph.ACCOUNTING_EVENT_ID
       AND aphd.PAYMENT_HISTORY_ID = aph.PAYMENT_HISTORY_ID
       and aph.TRANSACTION_TYPE = 'PAYMENT CREATED'
   UNION
       SELECT SUM(NVL(xal.entered_dr,0) - NVL(xal.entered_cr,0)) ,
                     -- discount entered amount (replace this with new xla colum names)
              SUM(NVL(xal.accounted_dr,0) - NVL(xal.accounted_cr,0))
                     -- discount entered amount (replace this with new xla colum names)
         FROM ap_invoice_distributions_all aid,
              --  ap_invoices_all ai,
              ap_invoice_payments_all aip,
              ap_payment_history_all aph,
              xla_ae_lines    xal
        WHERE aid.invoice_id = p_trx_id  -- ai.invoice_id
          AND aid.invoice_id = aip.invoice_id
--          AND aid.distribution_line_number
   --       AND aid.invoice_distribution_id = p_tax_line_id
          AND aid.detail_tax_dist_id = p_dist_id
          AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
          AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
          AND xal.ledger_id = p_ledger_id
          AND xal.accounting_class_code = 'DISCOUNT'
          AND aph.check_id = aip.check_id
          AND nvl(aph.historical_flag, 'N') = 'Y';



   l_tax_entered_disc_amt             NUMBER;
   l_tax_acct_disc_amt             NUMBER;
  -- l_tax1_entered_disc_amt             NUMBER;
  -- l_tax1_accounted_disc_amt             NUMBER;
  -- l_tax2_entered_disc_amt            NUMBER;
  -- l_tax2_accounted_disc_amt:= 0;
  -- l_tax3_entered_disc_amt:= 0;
  -- l_tax3_accounted_disc_amt:= 0;
  -- l_tax4_entered_disc_amt:= 0;
  -- l_tax4_accounted_disc_amt:= 0;
   l_0_taxable_entered_disc_amt            NUMBER;
   l_0_taxable_accounted_disc_amt           NUMBER;
   l_taxable_entered_disc_amt           NUMBER;
   l_taxable_acct_disc_amt           NUMBER;
   i                                    BINARY_INTEGER;

 BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info.BEGIN',
                                      'get_discount_info(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info.BEGIN',
                                      'P_DISC_DISTRIBUTION_METHOD :'||P_DISC_DISTRIBUTION_METHOD);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info.BEGIN',
                                   'P_LIABILITY_POST_LOOKUP_CODE : '||P_LIABILITY_POST_LOOKUP_CODE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info.BEGIN',
                                      'P_TRX_ID : '||to_char(P_TRX_ID));
    END IF;
  i          := j;
--P_INDEX_TO_GLOBAL_TABLES;
  --l_tax_type := P_SUB_ITF_REC.tax_code_type_code;

  -- get discount tax amount;


   l_tax_entered_disc_amt:= 0;
   l_tax_acct_disc_amt:= 0;
 --  l_tax1_entered_disc_amt:= 0;
--   l_tax1_accounted_disc_amt:= 0;
 --  l_tax2_entered_disc_amt:= 0;
  -- l_tax2_accounted_disc_amt:= 0;
  -- l_tax3_entered_disc_amt:= 0;
  -- l_tax3_accounted_disc_amt:= 0;
  -- l_tax4_entered_disc_amt:= 0;
  -- l_tax4_accounted_disc_amt:= 0;
 l_0_taxable_entered_disc_amt:= 0;
   l_0_taxable_accounted_disc_amt:= 0;
   l_taxable_entered_disc_amt:= 0;
   l_taxable_acct_disc_amt:= 0;


   IF P_DISC_DISTRIBUTION_METHOD = 'EXPENSE' OR
      P_LIABILITY_POST_LOOKUP_CODE IS NOT NULL  THEN

   IF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN


      OPEN taxable_dist_csr;
--(p_trx_line_id);
         FETCH taxable_dist_csr INTO l_taxable_entered_disc_amt, l_taxable_acct_disc_amt;

         IF taxable_dist_csr%NOTFOUND THEN
    -- Message
                NULL;
         END IF;  -- tax_discount_cur

         IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_taxable_entered_disc_amt : '||to_char(l_taxable_entered_disc_amt));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_taxable_acct_disc_amt : '||to_char(l_taxable_acct_disc_amt));
         END IF;

      CLOSE taxable_dist_csr;

   ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN

           OPEN taxable_line_csr;
--(p_trx_line_id);
          FETCH taxable_line_csr INTO l_taxable_entered_disc_amt, l_taxable_acct_disc_amt;

    IF taxable_line_csr%NOTFOUND THEN
    NULL;
    -- Message
    END IF;  -- tax_discount_cur

    ELSIF P_SUMMARY_LEVEL = 'TRANSACTION' THEN

           OPEN taxable_hdr_csr;
--(p_trx_line_id);
              FETCH taxable_hdr_csr INTO l_taxable_entered_disc_amt, l_taxable_acct_disc_amt;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_taxable_entered_disc_amt : '||to_char(l_taxable_entered_disc_amt));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_taxable_acct_disc_amt : '||to_char(l_taxable_acct_disc_amt));
         END IF;
        IF taxable_hdr_csr%NOTFOUND THEN
        NULL;
    -- Message
        END IF;  -- tax_discount_cur
          CLOSE taxable_hdr_csr;

   END IF; --summary level


--   GT_TAXABLE_ENT_DISC_AMT_TBL(j):=   l_taxable_entered_disc_amt;
--   G_TAXABLE_ACCT_DISC_AMT_TBL(j):= l_taxable_acct_disc_amt;

        GT_TAXABLE_DISC_AMT(j)     :=  l_taxable_entered_disc_amt;
         GT_TAXABLE_DISC_AMT_FUNCL_CURR(j)  := l_taxable_acct_disc_amt;

  ELSE      -- P_DISC_DISTRIBUTION_METHOD = 'TAX' AND P_LIABILITY_POST_LOOKUP_CODE IS NULL
     IF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
      OPEN taxable_dist_csr;
         FETCH taxable_dist_csr INTO l_taxable_entered_disc_amt, l_taxable_acct_disc_amt;
         IF taxable_dist_csr%NOTFOUND THEN
                NULL;
         END IF;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_taxable_entered_disc_amt : '||to_char(l_taxable_entered_disc_amt));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_taxable_acct_disc_amt : '||to_char(l_taxable_acct_disc_amt));
         END IF;
      CLOSE taxable_dist_csr;
     ELSE
     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info', ' Dist method TAX : ');
     END IF;
         OPEN taxable_hdr_csr;
         FETCH  taxable_hdr_csr INTO l_taxable_entered_disc_amt, l_taxable_acct_disc_amt;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_taxable_entered_disc_amt : '||to_char(l_taxable_entered_disc_amt));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_taxable_acct_disc_amt : '||to_char(l_taxable_acct_disc_amt));
         END IF;
         IF taxable_hdr_csr%NOTFOUND THEN
      --      close taxable_disc_cur;
                -- Message
                NULL;
         END IF;  -- taxable_disc_sys_cur
           close taxable_hdr_csr;
       END IF;
       GT_TAXABLE_DISC_AMT(j)     :=  l_taxable_entered_disc_amt;
         GT_TAXABLE_DISC_AMT_FUNCL_CURR(j)  := l_taxable_acct_disc_amt;

  END IF;

  IF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN

    OPEN tax_dist_csr;
--(p_trx_line_id);
    FETCH tax_dist_csr INTO l_tax_entered_disc_amt, l_tax_acct_disc_amt;

    IF tax_dist_csr%NOTFOUND THEN
       -- Message
       NULL;
    END IF;  -- tax_discount_cur

    CLOSE tax_dist_csr;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_tax_entered_disc_amt : '||to_char(l_tax_entered_disc_amt));
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_tax_acct_disc_amt : '||to_char(l_tax_acct_disc_amt));
    END IF;

   ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN

     OPEN tax_line_csr;
--(p_trx_line_id);
     FETCH tax_line_csr INTO l_tax_entered_disc_amt, l_tax_acct_disc_amt;

     IF tax_line_csr%NOTFOUND THEN
       NULL; -- Message
     END IF;  -- tax_discount_cur

   ELSIF P_SUMMARY_LEVEL = 'TRANSACTION' THEN

     OPEN tax_hdr_csr;
--(p_trx_line_id);
     FETCH tax_hdr_csr INTO l_tax_entered_disc_amt, l_tax_acct_disc_amt;

     IF tax_hdr_csr%NOTFOUND THEN
       NULL; -- Message
     END IF;  -- tax_discount_cur
     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_tax_entered_disc_amt : '||to_char(l_tax_entered_disc_amt));
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                   'l_tax_acct_disc_amt : '||to_char(l_tax_acct_disc_amt));
     END IF;

   END IF; --summary level


   GT_TAX_DISC_AMT(j)            := l_tax_entered_disc_amt;
   GT_TAX_DISC_AMT_FUNCL_CURR(j) := l_tax_acct_disc_amt;

 EXCEPTION

  WHEN NO_DATA_FOUND THEN
      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_discount_info- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                      g_error_buffer);
    END IF;

  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_discount_info- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_POPULATE_PKG.get_discount_info',
                      g_error_buffer);
    END IF;

 END get_discount_info;

-- End Accounting procedures --

PROCEDURE update_zx_rep_detail_t(
  P_COUNT IN BINARY_INTEGER)
 IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_zx_rep_detail_t.BEGIN',
                                      'update_zx_rep_detail_t(+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_zx_rep_detail_t',
                                          'Rows Update by update_zx_rep_detail_t :'||to_char(p_count));
    END IF;

  FORALL  i IN 1 .. p_count
      UPDATE /*+ INDEX (ZX_REP_TRX_DETAIL_T ZX_REP_TRX_DETAIL_T_U1)*/ ZX_REP_TRX_DETAIL_T
         SET REP_CONTEXT_ID            =     G_REP_CONTEXT_ID,
             BILLING_TP_NUMBER         =     GT_BILLING_TP_NUMBER(i),
             BILLING_TP_TAX_REG_NUM    =     GT_BILLING_TP_TAX_REG_NUM(i),
             BILLING_TP_TAXPAYER_ID    =     GT_BILLING_TP_TAXPAYER_ID(i),
             BILLING_TP_SITE_NAME_ALT  =     GT_BILLING_TP_SITE_NAME_ALT(i),
             BILLING_TP_SITE_NAME      =     GT_BILLING_TP_SITE_NAME(i),
             BILLING_TP_SITE_TAX_REG_NUM =   GT_BILLING_SITE_TAX_REG_NUM(i),
             HQ_ESTB_REG_NUMBER          =   GT_TAX_REG_NUM(i),
             BILLING_TP_NAME           =     GT_BILLING_TP_NAME(i),
             BILLING_TP_NAME_ALT       =     GT_BILLING_TP_NAME_ALT(i),
             BILLING_TP_SIC_CODE       =     GT_BILLING_TP_SIC_CODE(i),
             BILLING_TP_CITY           =     GT_BILLING_TP_CITY(i),
             BILLING_TP_COUNTY         =     GT_BILLING_TP_COUNTY(i),
             BILLING_TP_STATE          =     GT_BILLING_TP_STATE(i),
             BILLING_TP_PROVINCE       =     GT_BILLING_TP_PROVINCE(i),
             BILLING_TP_ADDRESS1       =     GT_BILLING_TP_ADDRESS1(i),
             BILLING_TP_ADDRESS2       =     GT_BILLING_TP_ADDRESS2(i),
             BILLING_TP_ADDRESS3       =     GT_BILLING_TP_ADDRESS3(i),
             BILLING_TP_ADDRESS_LINES_ALT =  GT_BILLING_TP_ADDR_LINES_ALT(i),
             BILLING_TP_COUNTRY        =     GT_BILLING_TP_COUNTRY(i),
             BILLING_TP_POSTAL_CODE    =     GT_BILLING_TP_POSTAL_CODE(i),
             GDF_PO_VENDOR_SITE_ATT17     =  GT_GDF_PO_VENDOR_SITE_ATT17(i),
             TRX_CLASS_MNG             =     GT_TRX_CLASS_MNG(i),
             TAX_RATE_CODE_REG_TYPE_MNG  =   GT_TAX_RATE_CODE_REG_TYPE_MNG(i),
             TAX_RATE_REGISTER_TYPE_CODE =   GT_TAX_RATE_REG_TYPE_CODE(i),
             TAX_RATE_VAT_TRX_TYPE_DESC  =   GT_TAX_RATE_VAT_TRX_TYPE_DESC(i),
             TAX_RATE_CODE_VAT_TRX_TYPE_MNG =GT_TAX_RATE_VAT_TRX_TYPE_MNG(i),
             FUNCTIONAL_CURRENCY_CODE    =   G_FUN_CURRENCY_CODE,
             LEDGER_NAME                 =   GT_LEDGER_NAME(i),
             TAXABLE_DISC_AMT            =   GT_TAXABLE_DISC_AMT(i),
             TAXABLE_DISC_AMT_FUNCL_CURR =   GT_TAXABLE_DISC_AMT_FUNCL_CURR(i),
             TAX_DISC_AMT                =   GT_TAX_DISC_AMT(i),
             TAX_DISC_AMT_FUNCL_CURR     =   GT_TAX_DISC_AMT_FUNCL_CURR(i),
             TAX_AMT                     =   TAX_AMT + GT_TAX_AMT(i), --Bug 5393051
             TAX_AMT_FUNCL_CURR          =   TAX_AMT_FUNCL_CURR + GT_TAX_AMT_FUNCL_CURR(i), --Bug 5393051
             TAXABLE_AMT                 =   GT_TAXABLE_AMT(i),--Bug 539305
             TAXABLE_AMT_FUNCL_CURR      =   GT_TAXABLE_AMT_FUNCL_CURR(i), --Bug 5393051
             TAX_TYPE_MNG     =   GT_TAX_TYPE_MNG(i)
      WHERE  DETAIL_TAX_LINE_ID = GT_DETAIL_TAX_LINE_ID(i);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.update_zx_rep_detail_t.END',
                                      'update_zx_rep_detail_t(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_POPULATE_PKG.update_zx_rep_detail_t',
                      g_error_buffer);
    END IF;
    g_retcode := 2;

END update_zx_rep_detail_t;



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
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_EXTRACT_PKG.insert_actg_info.BEGIN',
                                      'ZX_AP_ACTG_EXTRACT_PKG: insert_actg_info(+)');
    END IF;

    l_count  := P_COUNT;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_EXTRACT_PKG.insert_actg_info',
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
  TRX_CONTROL_ACCOUNT_FLEXFIELD,
  TRX_TAXABLE_ACCOUNT_DESC,--Bug 5650415
  TRX_TAXABLE_BALSEG_DESC,--Bug 5650415
  TRX_TAXABLE_NATACCT_SEG_DESC, --Bug 5650415
  TRX_TAXABLE_ACCOUNT
  )
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
  GT_TRX_CONTROL_ACCFLEXFIELD(i),
  GT_TRX_TAXABLE_ACCOUNT_DESC(i),--Bug 5650415
  GT_TRX_TAXABLE_BALSEG_DESC(i),--Bug 5650415
  GT_TRX_TAXABLE_NATACCT_DESC(i),  --Bug 5650415
  GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
  );

     IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_EXTRACT_PKG.insert_actg_info',
                      'Number of Tax Lines successfully inserted = '||TO_CHAR(l_count));

        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_EXTRACT_PKG.insert_actg_info.END',
                                      'ZX_AP_ACTG_EXTRACT_PKG: INIT_GT_VARIABLES(-)');
     END IF;

EXCEPTION
   WHEN OTHERS THEN
        g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
        FND_MSG_PUB.Add;
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.TRL.ZX_AP_ACTG_EXTRACT_PKG.insert_actg_info',
                           g_error_buffer);
        END IF;

         g_retcode := 2;

END insert_actg_info;



PROCEDURE initialize_variables (
          p_count   IN         NUMBER) IS
i number;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.initialize_variables.BEGIN',
                                      'initialize_variables(+)');
    END IF;

  FOR i IN 1.. p_count LOOP
      GT_LEDGER_NAME(i)                := NULL;
      GT_BILLING_TP_NUMBER(i)            := NULL;
      GT_BILLING_TP_TAX_REG_NUM(i)       := NULL;
      GT_BILLING_TP_TAXPAYER_ID(i)       := NULL;
      GT_BILLING_TP_SITE_NAME_ALT(i)     := NULL;
      GT_BILLING_TP_SITE_NAME(i)     := NULL;
      GT_BILLING_SITE_TAX_REG_NUM(i)      := NULL;
      GT_TAX_REG_NUM(i)                := NULL;
      GT_BILLING_TP_NAME(i)              := NULL;
      GT_BILLING_TP_NAME_ALT(i)          := NULL;
      GT_BILLING_TP_SIC_CODE(i)          := NULL;
      GT_BILLING_TP_CITY(i)              := NULL;
      GT_BILLING_TP_COUNTY(i)            := NULL;
      GT_BILLING_TP_STATE(i)             := NULL;
      GT_BILLING_TP_PROVINCE(i)          := NULL;
      GT_BILLING_TP_ADDRESS1(i)          := NULL;
      GT_BILLING_TP_ADDRESS2(i)          := NULL;
      GT_BILLING_TP_ADDRESS3(i)          := NULL;
      GT_BILLING_TP_ADDR_LINES_ALT(i)    := NULL;
      GT_BILLING_TP_COUNTRY(i)           := NULL;
      GT_BILLING_TP_POSTAL_CODE(i)       := NULL;
      GT_GDF_PO_VENDOR_SITE_ATT17(i)     := NULL;
      GT_TRX_CLASS_MNG(i)                := NULL;
      GT_TAX_RATE_CODE_REG_TYPE_MNG(i)   := NULL;
      GT_TAX_RATE_REG_TYPE_CODE(i)       := NULL;
      GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) := NULL;
      GT_TAX_RATE_VAT_TRX_TYPE_MNG(i)  := NULL;
      gt_actg_ext_line_id(i)         := NULL;
      GT_TRX_ARAP_BALANCING_SEGMENT(i)    := NULL;
      GT_TRX_ARAP_NATURAL_ACCOUNT(i)    := NULL;
      GT_TRX_TAXABLE_BAL_SEG(i)    := NULL;
      GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)    := NULL;
      GT_TRX_TAX_BALANCING_SEGMENT(i)    := NULL;
      GT_TRX_TAX_NATURAL_ACCOUNT(i)    := NULL;
      GT_ACCOUNT_FLEXFIELD(i)   := NULL;
      GT_ACCOUNT_DESCRIPTION(i) := NULL;
      GT_TRX_CONTROL_ACCFLEXFIELD(i) := NULL ;
      GT_TRX_TAXABLE_ACCOUNT_DESC(i) := NULL ;
      GT_TRX_TAXABLE_BALSEG_DESC(i) := NULL ;
      GT_TRX_TAXABLE_NATACCT_DESC(i) := NULL ;


     END LOOP;
    -- Populate WHO columns --

    g_created_by        := fnd_global.user_id;
    g_creation_date     := sysdate;
    g_last_updated_by   := fnd_global.user_id;
    g_last_update_login := fnd_global.login_id;
    g_last_update_date  := sysdate;

    g_program_application_id := fnd_global.prog_appl_id        ; --program_application_id
    g_program_id            := fnd_global.conc_program_id     ; --program_id
    g_program_login_id      := fnd_global.conc_login_id       ; --program_login_id

/*    GT_SHIPPING_TP_ADDRESS_ID.delete;
    GT_BILLING_TP_ADDRESS_ID.delete;
    GT_SHIPPING_TP_SITE_ID.delete;
    GT_BILLING_TP_SITE_ID.delete;
    GT_SHIPPING_TP_ID.delete;
    GT_BILLING_TRADING_PARTNER_ID.delete;
*/

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.initialize_variables.END',
                                      'initialize_variables(-)');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_POPULATE_PKG.initialize_variables',
                      g_error_buffer);
    END IF;
    g_retcode := 2;

END initialize_variables ;

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
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_tax_reg_num.BEGIN',
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

GT_TRX_CLASS_MNG(i) := NULL ;
GT_TAX_RATE_CODE_REG_TYPE_MNG(i) := NULL ;
GT_TAX_TYPE_MNG(i) := NULL ;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning.BEGIN',
                                      'populate_meaning(+)');
    END IF;

     IF GT_TRX_LINE_CLASS(i) IS NOT NULL THEN
        lookup_desc_meaning('ZX_TRL_TAXABLE_TRX_TYPE',
                             GT_TRX_LINE_CLASS(i),
                             l_meaning,
                             l_description);
        GT_TRX_CLASS_MNG(i) := l_meaning;
     END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                                      'Value of i : '||i);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                                      'GT_TRX_ID(i) : '||GT_TRX_ID(i));
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                                      'GT_TRX_CLASS_MNG(i) : '||GT_TRX_CLASS_MNG(i));
    END IF;

     IF  P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE IS NOT NULL THEN
         lookup_desc_meaning('ZX_TRL_REGISTER_TYPE',
                              P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE,
                             l_meaning,
                             l_description);

         GT_TAX_RATE_CODE_REG_TYPE_MNG(i) := l_meaning;
     END IF;
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                                      'GT_TAX_RATE_CODE_REG_TYPE_MNG(i) : '||GT_TAX_RATE_CODE_REG_TYPE_MNG(i));
    END IF;

     IF  GT_TAX_RATE_VAT_TRX_TYPE_CODE(i) IS NOT NULL THEN
         ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_JEBE_VAT_TRANS_TYPE',
                              GT_TAX_RATE_VAT_TRX_TYPE_CODE(i),
                             l_meaning,
                             l_description);
         GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) := l_description;
         GT_TAX_RATE_VAT_TRX_TYPE_MNG(i) := l_meaning;
     END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                                      'GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) : '||GT_TAX_RATE_VAT_TRX_TYPE_DESC(i));
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                                      'GT_TAX_RATE_VAT_TRX_TYPE_MNG(i) : '||GT_TAX_RATE_VAT_TRX_TYPE_MNG(i));
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                                      'GT_TAX_TYPE_CODE(i) : '||GT_TAX_TYPE_CODE(i));
    END IF;

--Bug 5671767 :Code added to populate tax_type_mng
     IF GT_TAX_TYPE_CODE(i) IS NOT NULL THEN
        ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_TAX_TYPE_CATEGORY',
                             GT_TAX_TYPE_CODE(i),
                             l_meaning,
                             l_description);
        GT_TAX_TYPE_MNG(i) := l_meaning;
     END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                                      'GT_TAX_TYPE_MNG(i) : '||GT_TAX_TYPE_MNG(i));
    END IF;

   IF gt_tax_recoverable_flag(i) = 'Y' THEN
      gt_tax_rate_reg_type_code(i) := 'TAX';
   ELSE
    gt_tax_rate_reg_type_code(i) := 'NON-RECOVERABLE';
   END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning.END',
                                      'populate_meaning(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_meaning- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_POPULATE_PKG.populate_meaning',
                      g_error_buffer);
    END IF;


END populate_meaning;



PROCEDURE lookup_desc_meaning(p_lookup_type IN  VARCHAR2,
                              P_LOOKUP_CODE IN  VARCHAR2,
                              p_meaning     OUT NOCOPY  VARCHAR2,
                              p_description OUT  NOCOPY VARCHAR2) IS

  CURSOR lookup_cur (c_lookup_type VARCHAR2,
                     c_lookup_code VARCHAR2) IS
    SELECT meaning, description
      FROM fnd_lookups
     WHERE lookup_type = c_lookup_type
       AND lookup_code = c_lookup_code;

   l_tbl_index_lookup      BINARY_INTEGER;
BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.lookup_desc_meaning.BEGIN',
                                      'lookup_desc_meaning(+)');
  END IF;

  IF p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.lookup_desc_meaning',
                                        'Lookup Type and Lookup code are not null '||p_lookup_type||'-'||P_LOOKUP_CODE);
    END IF;

    l_tbl_index_lookup  := dbms_utility.get_hash_value(p_lookup_type||p_lookup_code, 1,8192);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.lookup_desc_meaning',
                                        'Meaning Alredy existed in the Cache');
    END IF;

    IF g_lookup_info_tbl.EXISTS(l_tbl_index_lookup) THEN
      p_meaning := g_lookup_info_tbl(l_tbl_index_lookup).lookup_meaning;
      p_description := g_lookup_info_tbl(l_tbl_index_lookup).lookup_description;
    ELSE
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.lookup_desc_meaning',
                                          'Before Open lookup_cur');
      END IF;

      OPEN lookup_cur (p_lookup_type, p_lookup_code);
      FETCH lookup_cur
      INTO p_meaning,
           p_description;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.lookup_desc_meaning',
                                          'p_meaning p_description'||p_meaning||' '||p_description);
      END IF;

      g_lookup_info_tbl(l_tbl_index_lookup).lookup_meaning := p_meaning;
      g_lookup_info_tbl(l_tbl_index_lookup).lookup_description := p_description;
    END IF;
  END IF;

  IF lookup_cur%ISOPEN THEN
    CLOSE lookup_cur;
  END IF;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_POPULATE_PKG.lookup_desc_meaning.END',
                                      'lookup_desc_meaning(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_POPULATE_PKG.lookup_desc_meaning',
                      g_error_buffer);
    END IF;
    g_retcode := 2;

END lookup_desc_meaning;

END ZX_AP_POPULATE_PKG;

/
