--------------------------------------------------------
--  DDL for Package ZX_TEST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TEST_API" AUTHID CURRENT_USER AS
/* $Header: zxitestapispvts.pls 120.15 2006/03/10 02:04:27 appradha ship $ */

/* ======================================================================*
 | 'Table' Data Type Definitions                                         |
 * ======================================================================*/

TYPE NUMBER_tbl_type             IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE DATE_tbl_type               IS TABLE OF DATE           INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_1_tbl_type         IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2_tbl_type         IS TABLE OF VARCHAR2(2)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_15_tbl_type        IS TABLE OF VARCHAR2(15)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_tbl_type        IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_40_tbl_type        IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_50_tbl_type        IS TABLE OF VARCHAR2(50)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_80_tbl_type        IS TABLE OF VARCHAR2(80)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_150_tbl_type       IS TABLE OF VARCHAR2(150)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_240_tbl_type       IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_250_tbl_type       IS TABLE OF VARCHAR2(250)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2000_tbl_type      IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE surr_trx_id_type_tbl_type   IS TABLE OF NUMBER         INDEX BY VARCHAR2(1000);
TYPE surr_trx_line_id_tbl_type   IS TABLE OF NUMBER         INDEX BY VARCHAR2(1000);
TYPE surr_trx_dist_id_tbl_type   IS TABLE OF NUMBER         INDEX BY VARCHAR2(1000);
TYPE user_keys_segments_tbl_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


/* ===========================================================*
 | 'Record' Data Type Definitions                             |
 * ===========================================================*/

 TYPE party_rec_type IS RECORD
  (
   SHIP_TO_PARTY_TYPE            VARCHAR2(30)       ,
   SHIP_FROM_PARTY_TYPE          VARCHAR2(30)       ,
   POA_PARTY_TYPE                VARCHAR2(30)       ,
   POO_PARTY_TYPE                VARCHAR2(30)       ,
   PAYING_PARTY_TYPE             VARCHAR2(30)       ,
   OWN_HQ_PARTY_TYPE             VARCHAR2(30)       ,
   TRAD_HQ_PARTY_TYPE            VARCHAR2(30)       ,
   POI_PARTY_TYPE                VARCHAR2(30)       ,
   POD_PARTY_TYPE                VARCHAR2(30)       ,
   BILL_TO_PARTY_TYPE            VARCHAR2(30)       ,
   BILL_FROM_PARTY_TYPE          VARCHAR2(30)       ,
   TTL_TRNS_PARTY_TYPE           VARCHAR2(30)       ,
   MERCHANT_PARTY_TYPE           VARCHAR2(30)       ,
   THIRD_PARTY_TYPE              VARCHAR2(30)       ,
   SHIP_TO_PTY_SITE_TYPE         VARCHAR2(30)       ,
   SHIP_FROM_PTY_SITE_TYPE       VARCHAR2(30)       ,
   POA_PTY_SITE_TYPE             VARCHAR2(30)       ,
   POO_PTY_SITE_TYPE             VARCHAR2(30)       ,
   PAYING_PTY_SITE_TYPE          VARCHAR2(30)       ,
   OWN_HQ_PTY_SITE_TYPE          VARCHAR2(30)       ,
   TRAD_HQ_PTY_SITE_TYPE         VARCHAR2(30)       ,
   POI_PTY_SITE_TYPE             VARCHAR2(30)       ,
   POD_PTY_SITE_TYPE             VARCHAR2(30)       ,
   BILL_TO_PTY_SITE_TYPE         VARCHAR2(30)       ,
   BILL_FROM_PTY_SITE_TYPE       VARCHAR2(30)       ,
   TTL_TRNS_PTY_SITE_TYPE        VARCHAR2(30)       ,
   PROD_FAMILY_GRP_CODE          VARCHAR2(30));


/* ======================================================================*
 | 'Record of Tables' Data Type Definitions                              |
 * ======================================================================*/

TYPE suite_rec_tbl_type IS RECORD (
   ROW_ID                        NUMBER_tbl_type             ,
   ROW_SUITE                     VARCHAR2_30_tbl_type        ,
   ROW_CASE                      VARCHAR2_30_tbl_type        ,
   ROW_API                       VARCHAR2_80_tbl_type        ,
   ROW_SERVICE                   VARCHAR2_80_tbl_type        ,
   ROW_STRUCTURE                 VARCHAR2_80_tbl_type        ,
   INTERNAL_ORGANIZATION_ID      NUMBER_tbl_type             ,
   INTERNAL_ORG_LOCATION_ID      NUMBER_tbl_type             ,
   FIRST_PARTY_ORG_ID            NUMBER_tbl_type             ,
   APPLICATION_ID                NUMBER_tbl_type             ,
   ENTITY_CODE                   VARCHAR2_30_tbl_type        ,
   EVENT_CLASS_CODE              VARCHAR2_30_tbl_type        ,
   TAX_EVENT_CLASS_CODE          VARCHAR2_30_tbl_type        ,
   DOC_EVENT_STATUS              VARCHAR2_30_tbl_type        ,
   TAX_HOLD_RELEASED_CODE        VARCHAR2_30_tbl_type        ,
   EVENT_TYPE_CODE               VARCHAR2_30_tbl_type        ,
   TRX_ID                        NUMBER_tbl_type             ,
   OVERRIDE_LEVEL                VARCHAR2_30_tbl_type        ,
   TRX_LEVEL_TYPE                VARCHAR2_30_tbl_type        ,
   TRX_LINE_ID                   NUMBER_tbl_type             ,
   TRX_WAYBILL_NUMBER            VARCHAR2_50_tbl_type        ,
   TRX_LINE_DESCRIPTION          VARCHAR2_240_tbl_type       ,
   PRODUCT_DESCRIPTION           VARCHAR2_240_tbl_type       ,
   TAX_LINE_ID                   NUMBER_tbl_type             ,
   APPLIED_FROM_DIST_ID          NUMBER_tbl_type             ,
   FIRST_PTY_ORG_ID              NUMBER_tbl_type             ,
   SUMMARY_TAX_LINE_ID           NUMBER_tbl_type             ,
   INVOICE_PRICE_VARIANCE        NUMBER_tbl_type             ,
   RDNG_SHIP_TO_PTY_TX_PROF_ID   NUMBER_tbl_type             ,
   RDNG_SHIP_FROM_PTY_TX_PROF_ID NUMBER_tbl_type             ,
   RDNG_BILL_TO_PTY_TX_PROF_ID   NUMBER_tbl_type             ,
   RDNG_BILL_FROM_PTY_TX_PROF_ID NUMBER_tbl_type             ,
   RDNG_SHIP_TO_PTY_TX_P_ST_ID   NUMBER_tbl_type             ,
   RDNG_SHIP_FROM_PTY_TX_P_ST_ID NUMBER_tbl_type             ,
   RDNG_BILL_TO_PTY_TX_P_ST_ID   NUMBER_tbl_type             ,
   RDNG_BILL_FROM_PTY_TX_P_ST_ID NUMBER_tbl_type             ,
   LINE_LEVEL_ACTION             VARCHAR2_30_tbl_type        ,
   TAX_CLASSIFICATION_CODE       VARCHAR2_80_tbl_type        ,
   TRX_DATE                      DATE_tbl_type               ,
   TRX_DOC_REVISION              VARCHAR2_150_tbl_type       ,
   LEDGER_ID                     NUMBER_tbl_type             ,
   TAX_RATE_ID                   NUMBER_tbl_type             ,
   TRX_CURRENCY_CODE             VARCHAR2_15_tbl_type        ,
   CURRENCY_CONVERSION_DATE      DATE_tbl_type               ,
   CURRENCY_CONVERSION_RATE      NUMBER_tbl_type             ,
   CURRENCY_CONVERSION_TYPE      VARCHAR2_30_tbl_type        ,
   MINIMUM_ACCOUNTABLE_UNIT      NUMBER_tbl_type             ,
   PRECISION                     NUMBER_tbl_type             ,
   TRX_SHIPPING_DATE             DATE_tbl_type               ,
   TRX_RECEIPT_DATE              DATE_tbl_type               ,
   LEGAL_ENTITY_ID               NUMBER_tbl_type             ,
   REVERSING_APPLN_ID            NUMBER_tbl_type             ,
   ROUNDING_SHIP_TO_PARTY_ID     NUMBER_tbl_type             ,
   ROUNDING_SHIP_FROM_PARTY_ID   NUMBER_tbl_type             ,
   ROUNDING_BILL_TO_PARTY_ID     NUMBER_tbl_type             ,
   ROUNDING_BILL_FROM_PARTY_ID   NUMBER_tbl_type             ,
   RNDG_SHIP_TO_PARTY_SITE_ID    NUMBER_tbl_type             ,
   RNDG_SHIP_FROM_PARTY_SITE_ID  NUMBER_tbl_type             ,
   RNDG_BILL_TO_PARTY_SITE_ID    NUMBER_tbl_type             ,
   RNDG_BILL_FROM_PARTY_SITE_ID  NUMBER_tbl_type             ,
   ESTABLISHMENT_ID              NUMBER_tbl_type             ,
   TAX_EXEMPTION_ID              NUMBER_tbl_type             ,
   REC_NREC_TAX_DIST_ID          NUMBER_tbl_type             ,
   TAX_APPORTIONMENT_LINE_NUMBER NUMBER_tbl_type             ,
   EXEMPTION_RATE                NUMBER_tbl_type             ,
   TOTAL_NREC_TAX_AMT            NUMBER_tbl_type             ,
   TOTAL_REC_TAX_AMT             NUMBER_tbl_type             ,
   REC_TAX_AMT                   NUMBER_tbl_type             ,
   NREC_TAX_AMT                  NUMBER_tbl_type             ,
   MERCHANT_PARTY_DOCUMENT_NUMBER NUMBER_tbl_type            ,
   TRX_LINE_TYPE                 VARCHAR2_30_tbl_type        ,
   TAX_REGISTRATION_NUMBER       VARCHAR2_50_tbl_type        ,
   CTRL_TOTAL_HDR_TX_AMT         NUMBER_tbl_type             ,
   EXEMPT_REASON_CODE            VARCHAR2_30_tbl_type        ,
   TAX_HOLD_CODE                 VARCHAR2_30_tbl_type        ,
   TAX_AMT_FUNCL_CURR            NUMBER_tbl_type             ,
   TOTAL_REC_TAX_AMT_FUNCL_CURR  NUMBER_tbl_type             ,
   TOTAL_NREC_TAX_AMT_FUNCL_CURR NUMBER_tbl_type             ,
   TAXABLE_AMT_FUNCL_CURR        NUMBER_tbl_type             ,
   REC_TAX_AMT_FUNCL_CURR        NUMBER_tbl_type             ,
   NREC_TAX_AMT_FUNCL_CURR       NUMBER_tbl_type             ,
   TRX_LINE_DATE                 DATE_tbl_type               ,
   TRX_BUSINESS_CATEGORY         VARCHAR2_240_tbl_type       ,
   LINE_INTENDED_USE             VARCHAR2_240_tbl_type       ,
   USER_DEFINED_FISC_CLASS       VARCHAR2_30_tbl_type        ,
   TAX_LINE_NUMBER               NUMBER_tbl_type             ,
   TAX_CODE                      VARCHAR2_30_tbl_type        ,
   TAX_INCLUSION_FLAG            VARCHAR2_1_tbl_type         ,
   TAX_AMT_INCLUDED_FLAG         VARCHAR2_1_tbl_type         ,
   SELF_ASSESSED_FLAG            VARCHAR2_1_tbl_type         ,
   QUOTE_FLAG                    VARCHAR2_1_tbl_type         ,
   HISTORICAL_FLAG               VARCHAR2_1_tbl_type         ,
   MANUALLY_ENTERED_FLAG         VARCHAR2_1_tbl_type         ,
   LINE_AMT                      NUMBER_tbl_type             ,
   TRX_LINE_QUANTITY             NUMBER_tbl_type             ,
   UNIT_PRICE                    NUMBER_tbl_type             ,
   EXEMPT_CERTIFICATE_NUMBER     VARCHAR2_30_tbl_type        ,
   EXEMPT_REASON                 VARCHAR2_240_tbl_type       ,
   DEFAULT_TAXATION_COUNTRY      VARCHAR2_2_tbl_type         ,
   CASH_DISCOUNT                 NUMBER_tbl_type             ,
   VOLUME_DISCOUNT               NUMBER_tbl_type             ,
   TRADING_DISCOUNT              NUMBER_tbl_type             ,
   TRANSFER_CHARGE               NUMBER_tbl_type             ,
   TRANSPORTATION_CHARGE         NUMBER_tbl_type             ,
   INSURANCE_CHARGE              NUMBER_tbl_type             ,
   OTHER_CHARGE                  NUMBER_tbl_type             ,
   PRODUCT_ID                    NUMBER_tbl_type             ,
   PRODUCT_FISC_CLASSIFICATION   VARCHAR2_240_tbl_type       ,
   PRODUCT_ORG_ID                NUMBER_tbl_type             ,
   UOM_CODE                      VARCHAR2_30_tbl_type        ,
   PRODUCT_TYPE                  VARCHAR2_30_tbl_type        ,
   PRODUCT_CODE                  VARCHAR2_40_tbl_type        ,
   PRODUCT_CATEGORY              VARCHAR2_240_tbl_type       ,
   TRX_SIC_CODE                  VARCHAR2_150_tbl_type       ,
   FOB_POINT                     VARCHAR2_30_tbl_type        ,
   SHIP_TO_PARTY_ID              NUMBER_tbl_type             ,
   SHIP_FROM_PARTY_ID            NUMBER_tbl_type             ,
   POA_PARTY_ID                  NUMBER_tbl_type             ,
   POO_PARTY_ID                  NUMBER_tbl_type             ,
   BILL_TO_PARTY_ID              NUMBER_tbl_type             ,
   BILL_FROM_PARTY_ID            NUMBER_tbl_type             ,
   MERCHANT_PARTY_ID             NUMBER_tbl_type             ,
   SHIP_TO_PARTY_SITE_ID         NUMBER_tbl_type             ,
   SHIP_TO_SITE_PARTY_TAX_PROF_ID NUMBER_tbl_type             ,
   SHIP_FROM_PARTY_SITE_ID       NUMBER_tbl_type             ,
   POA_PARTY_SITE_ID             NUMBER_tbl_type             ,
   POO_PARTY_SITE_ID             NUMBER_tbl_type             ,
   BILL_TO_PARTY_SITE_ID         NUMBER_tbl_type             ,
   BILL_FROM_PARTY_SITE_ID       NUMBER_tbl_type             ,
   SHIP_TO_LOCATION_ID           NUMBER_tbl_type             ,
   SHIP_FROM_LOCATION_ID         NUMBER_tbl_type             ,
   POA_LOCATION_ID               NUMBER_tbl_type             ,
   POO_LOCATION_ID               NUMBER_tbl_type             ,
   BILL_TO_LOCATION_ID           NUMBER_tbl_type             ,
   BILL_FROM_LOCATION_ID         NUMBER_tbl_type             ,
   ACCOUNT_CCID                  NUMBER_tbl_type             ,
   REVERSING_TAX_LINE_ID         NUMBER_tbl_type             ,
   ACCOUNT_STRING                VARCHAR2_2000_tbl_type      ,
   MERCHANT_PARTY_COUNTRY        VARCHAR2_150_tbl_type       ,
   RECEIVABLES_TRX_TYPE_ID       NUMBER_tbl_type             ,
   REF_DOC_APPLICATION_ID        NUMBER_tbl_type             ,
   REF_DOC_ENTITY_CODE           VARCHAR2_30_tbl_type        ,
   REF_DOC_EVENT_CLASS_CODE      VARCHAR2_30_tbl_type        ,
   REF_DOC_TRX_ID                NUMBER_tbl_type             ,
   REF_DOC_LINE_ID               NUMBER_tbl_type             ,
   REF_DOC_LINE_QUANTITY         NUMBER_tbl_type             ,
   RELATED_DOC_APPLICATION_ID    NUMBER_tbl_type             ,
   RELATED_DOC_ENTITY_CODE       VARCHAR2_30_tbl_type        ,
   RELATED_DOC_EVENT_CLASS_CODE  VARCHAR2_30_tbl_type        ,
   RELATED_DOC_TRX_ID            NUMBER_tbl_type             ,
   RELATED_DOC_NUMBER            VARCHAR2_150_tbl_type       ,
   RELATED_DOC_DATE              DATE_tbl_type               ,
   APPLIED_FROM_APPLICATION_ID   NUMBER_tbl_type             ,
   APPLIED_FROM_ENTITY_CODE      VARCHAR2_30_tbl_type        ,
   APPLIED_FROM_EVENT_CLASS_CODE VARCHAR2_30_tbl_type        ,
   APPLIED_FROM_TRX_ID           NUMBER_tbl_type             ,
   APPLIED_FROM_LINE_ID          NUMBER_tbl_type             ,
   ADJUSTED_DOC_APPLICATION_ID   NUMBER_tbl_type             ,
   ADJUSTED_DOC_ENTITY_CODE      VARCHAR2_30_tbl_type        ,
   ADJUSTED_DOC_EVENT_CLASS_CODE VARCHAR2_30_tbl_type        ,
   ADJUSTED_DOC_TRX_ID           NUMBER_tbl_type             ,
   ADJUSTED_DOC_LINE_ID          NUMBER_tbl_type             ,
   ADJUSTED_DOC_NUMBER           VARCHAR2_150_tbl_type       ,
   ASSESSABLE_VALUE              NUMBER_tbl_type             ,
   ADJUSTED_DOC_DATE             DATE_tbl_type               ,
   APPLIED_TO_APPLICATION_ID     NUMBER_tbl_type             ,
   APPLIED_TO_ENTITY_CODE        VARCHAR2_30_tbl_type        ,
   APPLIED_TO_EVENT_CLASS_CODE   VARCHAR2_30_tbl_type        ,
   APPLIED_TO_TRX_ID             NUMBER_tbl_type             ,
   APPLIED_TO_TRX_LINE_ID        NUMBER_tbl_type             ,
   TRX_LINE_NUMBER               NUMBER_tbl_type             ,
   TRX_NUMBER                    VARCHAR2_150_tbl_type       ,
   TRX_DESCRIPTION               VARCHAR2_240_tbl_type       ,
   TRX_COMMUNICATED_DATE         DATE_tbl_type               ,
   TRX_LINE_GL_DATE              DATE_tbl_type               ,
   BATCH_SOURCE_ID               NUMBER_tbl_type             ,
   BATCH_SOURCE_NAME             VARCHAR2_150_tbl_type       ,
   DOC_SEQ_ID                    NUMBER_tbl_type             ,
   DOC_SEQ_NAME                  VARCHAR2_150_tbl_type       ,
   DOC_SEQ_VALUE                 VARCHAR2_150_tbl_type       ,
   TRX_DUE_DATE                  DATE_tbl_type               ,
   TRX_TYPE_DESCRIPTION          VARCHAR2_240_tbl_type       ,
   VALIDATION_CHECK_FLAG         VARCHAR2_1_tbl_type         ,
   MERCHANT_PARTY_NAME           VARCHAR2_150_tbl_type       ,
   MERCHANT_PARTY_REFERENCE      VARCHAR2_250_tbl_type       ,
   MERCHANT_PARTY_TAXPAYER_ID    VARCHAR2_150_tbl_type       ,
   MERCHANT_PARTY_TAX_REG_NUMBER VARCHAR2_150_tbl_type       ,
   DOCUMENT_SUB_TYPE             VARCHAR2_240_tbl_type       ,
   SUPPLIER_TAX_INVOICE_NUMBER   VARCHAR2_150_tbl_type       ,
   SUPPLIER_TAX_INVOICE_DATE     DATE_tbl_type               ,
   SUPPLIER_EXCHANGE_RATE        NUMBER_tbl_type             ,
   EXCHANGE_RATE_VARIANCE        NUMBER_tbl_type             ,
   BASE_INVOICE_PRICE_VARIANCE   NUMBER_tbl_type             ,
   TAX_INVOICE_DATE              DATE_tbl_type               ,
   TAX_INVOICE_NUMBER            VARCHAR2_150_tbl_type       ,
   SUMMARY_TAX_LINE_NUMBER       NUMBER_tbl_type             ,
   TAX_REGIME_CODE               VARCHAR2_30_tbl_type        ,
   TAX_JURISDICTION_ID           NUMBER_tbl_type             ,
   TAX                           VARCHAR2_30_tbl_type        ,
   TAX_STATUS_CODE               VARCHAR2_150_tbl_type       ,
   RECOVERY_TYPE_CODE            VARCHAR2_30_tbl_type        ,
   RECOVERY_RATE_CODE            VARCHAR2_30_tbl_type        ,
   TAX_RATE_CODE                 VARCHAR2_150_tbl_type       ,
   RECOVERABLE_FLAG              VARCHAR2_1_tbl_type         ,
   FREEZE_FLAG                   VARCHAR2_1_tbl_type         ,
   POSTING_FLAG                  VARCHAR2_1_tbl_type         ,
   TAX_RATE                      NUMBER_tbl_type             ,
   TAX_AMT                       NUMBER_tbl_type             ,
   REC_NREC_TAX_AMT              NUMBER_tbl_type             ,
   TAXABLE_AMT                   NUMBER_tbl_type             ,
   REC_NREC_TAX_AMT_FUNCL_CURR   NUMBER_tbl_type             ,
   REC_NREC_CCID                 NUMBER_tbl_type             ,
   REVERSING_ENTITY_CODE         VARCHAR2_30_tbl_type        ,
   REVERSING_EVNT_CLS_CODE       VARCHAR2_30_tbl_type        ,
   REVERSING_TRX_ID              NUMBER_tbl_type             ,
   REVERSING_TRX_LINE_DIST_ID    NUMBER_tbl_type             ,
   REVERSING_TRX_LEVEL_TYPE      VARCHAR2_30_tbl_type        ,
   REVERSING_TRX_LINE_ID         NUMBER_tbl_type             ,
   REVERSED_APPLN_ID             NUMBER_tbl_type             ,
   REVERSED_ENTITY_CODE          VARCHAR2_30_tbl_type        ,
   REVERSED_EVNT_CLS_CODE        VARCHAR2_30_tbl_type        ,
   REVERSED_TRX_ID               NUMBER_tbl_type             ,
   REVERSED_TRX_LEVEL_TYPE       NUMBER_tbl_type             ,
   REVERSED_TRX_LINE_ID          NUMBER_tbl_type             ,
   REVERSED_TRX_LINE_DIST_ID     NUMBER_tbl_type             ,
   REVERSE_FLAG                  VARCHAR2_1_tbl_type         ,
   CANCEL_FLAG                   VARCHAR2_1_tbl_type         ,
   TRX_LINE_DIST_ID              NUMBER_tbl_type             ,
   REVERSED_TAX_DIST_ID          NUMBER_tbl_type             ,
   DIST_LEVEL_ACTION             VARCHAR2_30_tbl_type        ,
   TRX_LINE_DIST_DATE            DATE_tbl_type               ,
   ITEM_DIST_NUMBER              NUMBER_tbl_type             ,
   DIST_INTENDED_USE             VARCHAR2_240_tbl_type       ,
   TASK_ID                       NUMBER_tbl_type             ,
   AWARD_ID                      NUMBER_tbl_type             ,
   PROJECT_ID                    NUMBER_tbl_type             ,
   EXPENDITURE_TYPE              VARCHAR2_30_tbl_type        ,
   EXPENDITURE_ORGANIZATION_ID   NUMBER_tbl_type             ,
   EXPENDITURE_ITEM_DATE         DATE_tbl_type               ,
   TRX_LINE_DIST_AMT             NUMBER_tbl_type             ,
   TRX_LINE_DIST_QUANTITY        NUMBER_tbl_type             ,
   REF_DOC_DIST_ID               NUMBER_tbl_type             ,
   REF_DOC_CURR_CONV_RATE        NUMBER_tbl_type             ,
   TAX_DIST_ID                   NUMBER_tbl_type             ,
   LINE_AMT_INCLUDES_TAX_FLAG    VARCHAR2_1_tbl_type         ,
   OWN_HQ_PARTY_ID               NUMBER_tbl_type             ,
   TAX_EVENT_TYPE_CODE           VARCHAR2_80_tbl_type        ,
   LINE_CLASS                    VARCHAR2_30_tbl_type        ,
   TRX_ID_LEVEL2                 VARCHAR2_150_tbl_type       ,
   TRX_ID_LEVEL3                 VARCHAR2_150_tbl_type       ,
   TRX_ID_LEVEL4                 VARCHAR2_150_tbl_type       ,
   TRX_ID_LEVEL5                 VARCHAR2_150_tbl_type       ,
   TRX_ID_LEVEL6                 VARCHAR2_150_tbl_type       ,
   PAYING_PARTY_ID               NUMBER_TBL_TYPE             ,
   TRADING_HQ_PARTY_ID           NUMBER_TBL_TYPE             ,
   POI_PARTY_ID                  NUMBER_TBL_TYPE             ,
   POD_PARTY_ID                  NUMBER_TBL_TYPE             ,
   TITLE_TRANSFER_PARTY_ID       NUMBER_TBL_TYPE             ,
   PAYING_PARTY_SITE_ID          NUMBER_TBL_TYPE             ,
   OWN_HQ_PARTY_SITE_ID          NUMBER_TBL_TYPE             ,
   TRADING_HQ_PARTY_SITE_ID      NUMBER_TBL_TYPE             ,
   POI_PARTY_SITE_ID             NUMBER_TBL_TYPE             ,
   POD_PARTY_SITE_ID             NUMBER_TBL_TYPE             ,
   TITLE_TRANSFER_PARTY_SITE_ID  NUMBER_TBL_TYPE             ,
   PAYING_LOCATION_ID            NUMBER_TBL_TYPE             ,
   OWN_HQ_LOCATION_ID            NUMBER_TBL_TYPE             ,
   TRADING_HQ_LOCATION_ID        NUMBER_TBL_TYPE             ,
   POC_LOCATION_ID               NUMBER_TBL_TYPE             ,
   POI_LOCATION_ID               NUMBER_TBL_TYPE             ,
   POD_LOCATION_ID               NUMBER_TBL_TYPE             ,
   TITLE_TRANSFER_LOCATION_ID    NUMBER_TBL_TYPE             ,
   ASSET_FLAG                    VARCHAR2_1_TBL_TYPE         ,
   ASSET_NUMBER                  VARCHAR2_150_TBL_TYPE       ,
   ASSET_ACCUM_DEPRECIATION      NUMBER_TBL_TYPE             ,
   ASSET_TYPE                    VARCHAR2_150_TBL_TYPE       ,
   ASSET_COST                    NUMBER_TBL_TYPE             ,
   SHIP_TO_PARTY_TAX_PROF_ID     NUMBER_TBL_TYPE             ,
   SHIP_FROM_PARTY_TAX_PROF_ID   NUMBER_TBL_TYPE             ,
   POA_PARTY_TAX_PROF_ID         NUMBER_TBL_TYPE             ,
   POO_PARTY_TAX_PROF_ID         NUMBER_TBL_TYPE             ,
   PAYING_PARTY_TAX_PROF_ID      NUMBER_TBL_TYPE             ,
   OWN_HQ_PARTY_TAX_PROF_ID      NUMBER_TBL_TYPE             ,
   TRADING_HQ_PARTY_TAX_PROF_ID  NUMBER_TBL_TYPE             ,
   POI_PARTY_TAX_PROF_ID         NUMBER_TBL_TYPE             ,
   POD_PARTY_TAX_PROF_ID         NUMBER_TBL_TYPE             ,
   BILL_TO_PARTY_TAX_PROF_ID     NUMBER_TBL_TYPE             ,
   BILL_FROM_PARTY_TAX_PROF_ID   NUMBER_TBL_TYPE             ,
   TITLE_TRANS_PARTY_TAX_PROF_ID NUMBER_TBL_TYPE             ,
   SHIP_TO_SITE_TAX_PROF_ID      NUMBER_TBL_TYPE             ,
   SHIP_FROM_SITE_TAX_PROF_ID    NUMBER_TBL_TYPE             ,
   POA_SITE_TAX_PROF_ID          NUMBER_TBL_TYPE             ,
   POO_SITE_TAX_PROF_ID          NUMBER_TBL_TYPE             ,
   PAYING_SITE_TAX_PROF_ID       NUMBER_TBL_TYPE             ,
   OWN_HQ_SITE_TAX_PROF_ID       NUMBER_TBL_TYPE             ,
   TRADING_HQ_SITE_TAX_PROF_ID   NUMBER_TBL_TYPE             ,
   POI_SITE_TAX_PROF_ID          NUMBER_TBL_TYPE             ,
   POD_SITE_TAX_PROF_ID          NUMBER_TBL_TYPE             ,
   BILL_TO_SITE_TAX_PROF_ID      NUMBER_TBL_TYPE             ,
   BILL_FROM_SITE_TAX_PROF_ID    NUMBER_TBL_TYPE             ,
   TITLE_TRANS_SITE_TAX_PROF_ID  NUMBER_TBL_TYPE             ,
   MERCHANT_PARTY_TAX_PROF_ID    NUMBER_TBL_TYPE             ,
   HQ_ESTB_PARTY_TAX_PROF_ID     NUMBER_TBL_TYPE             ,
   CTRL_HDR_TX_APPL_FLAG         VARCHAR2_1_TBL_TYPE         ,
   CTRL_TOTAL_LINE_TX_AMT        NUMBER_TBL_TYPE             ,
   TAX_JURISDICTION_CODE         VARCHAR2_30_TBL_TYPE        ,
   TAX_PROVIDER_ID               NUMBER_TBL_TYPE             ,
   TAX_EXCEPTION_ID              NUMBER_TBL_TYPE             ,
   TAX_LINE_ALLOCATION_FLAG      VARCHAR2_1_TBL_TYPE         ,
   REVERSED_TAX_LINE_ID          NUMBER_TBL_TYPE             ,
   APPLIED_FROM_TAX_DIST_ID      NUMBER_TBL_TYPE             ,
   ADJUSTED_DOC_TAX_DIST_ID      NUMBER_TBL_TYPE             ,
   TRX_LINE_DIST_TAX_AMT         NUMBER_TBL_TYPE             ,
   ADJUSTED_DOC_DIST_ID          NUMBER_TBL_TYPE             ,
   APPLIED_TO_DOC_CURR_CONV_RATE NUMBER_TBL_TYPE             ,
   TAX_VARIANCE_CALC_FLAG        VARCHAR2_1_TBL_TYPE         ,
   PORT_OF_ENTRY_CODE            VARCHAR2_30_TBL_TYPE        ,
   SHIP_THIRD_PTY_ACCT_ID        NUMBER_TBL_TYPE             ,
   BILL_THIRD_PTY_ACCT_ID        NUMBER_TBL_TYPE             ,
   SHIP_THIRD_PTY_ACCT_SITE_ID   NUMBER_TBL_TYPE             ,
   BILL_THIRD_PTY_ACCT_SITE_ID   NUMBER_TBL_TYPE             ,
   BILL_TO_CUST_ACCT_SITE_USE_ID NUMBER_TBL_TYPE             ,
   SHIP_TO_CUST_ACCT_SITE_USE_ID NUMBER_TBL_TYPE             ,
   --BUG 4477978. Added Source Columns
   SOURCE_APPLICATION_ID         NUMBER_TBL_TYPE             ,
   SOURCE_ENTITY_CODE            VARCHAR2_30_TBL_TYPE        ,
   SOURCE_EVENT_CLASS_CODE       VARCHAR2_30_TBL_TYPE        ,
   SOURCE_TRX_ID                 NUMBER_TBL_TYPE             ,
   SOURCE_LINE_ID                NUMBER_TBL_TYPE             ,
   SOURCE_TRX_LEVEL_TYPE         VARCHAR2_30_TBL_TYPE        ,
   SOURCE_TAX_LINE_ID            NUMBER_TBL_TYPE);

 TYPE zx_lines_rec_tbl_type IS RECORD (
   TAX_LINE_ID                   NUMBER_tbl_type,
   INTERNAL_ORGANIZATION_ID      NUMBER_tbl_type,
   APPLICATION_ID                NUMBER_tbl_type,
   ENTITY_CODE                   VARCHAR2_30_tbl_type,
   EVENT_CLASS_CODE              VARCHAR2_30_tbl_type,
   EVENT_TYPE_CODE               VARCHAR2_30_tbl_type,
   LINE_LEVEL_ACTION             VARCHAR2_30_tbl_type,
   DOC_EVENT_STATUS              VARCHAR2_30_tbl_type,
   LINE_EVENT_STATUS             VARCHAR2_30_tbl_type,
   TAX_EVENT_CLASS_CODE          VARCHAR2_30_tbl_type,
   TAX_EVENT_TYPE_CODE           VARCHAR2_30_tbl_type,
   TRX_ID                        NUMBER_tbl_type,
   TRX_LINE_ID                   NUMBER_tbl_type,
   TRX_LEVEL_TYPE                VARCHAR2_30_tbl_type,
   TRX_LINE_NUMBER               NUMBER_tbl_type,
   TAX_LINE_NUMBER               NUMBER_tbl_type,
   CONTENT_OWNER_ID              NUMBER_tbl_type,
   TAX_REGIME_ID                 NUMBER_tbl_type,
   TAX_REGIME_CODE               VARCHAR2_30_tbl_type,
   TAX_ID                        NUMBER_tbl_type,
   TAX                           VARCHAR2_30_tbl_type,
   TAX_STATUS_ID                 NUMBER_tbl_type,
   TAX_STATUS_CODE               VARCHAR2_30_tbl_type,
   TAX_RATE_ID                   NUMBER_tbl_type,
   TAX_RATE_CODE                 VARCHAR2_30_tbl_type,
   TAX_RATE                      NUMBER_tbl_type,
   TAX_APPORTIONMENT_LINE_NUMBER NUMBER_tbl_type,
   TRX_ID_LEVEL2                 NUMBER_tbl_type,
   TRX_ID_LEVEL3                 NUMBER_tbl_type,
   TRX_ID_LEVEL4                 NUMBER_tbl_type,
   TRX_ID_LEVEL5                 NUMBER_tbl_type,
   TRX_ID_LEVEL6                 NUMBER_tbl_type,
   TRX_USER_KEY_LEVEL1           VARCHAR2_150_tbl_type,
   TRX_USER_KEY_LEVEL2           VARCHAR2_150_tbl_type,
   TRX_USER_KEY_LEVEL3           VARCHAR2_150_tbl_type,
   TRX_USER_KEY_LEVEL4           VARCHAR2_150_tbl_type,
   TRX_USER_KEY_LEVEL5           VARCHAR2_150_tbl_type,
   TRX_USER_KEY_LEVEL6           VARCHAR2_150_tbl_type,
   LEDGER_ID                     NUMBER_tbl_type,
   ESTABLISHMENT_ID              NUMBER_tbl_type,
   LEGAL_ENTITY_ID               NUMBER_tbl_type,
   HQ_ESTB_REG_NUMBER            VARCHAR2_30_tbl_type,
   HQ_ESTB_PARTY_TAX_PROF_ID     NUMBER_tbl_type,
   TRX_DOC_REVISION              VARCHAR2_150_tbl_type,
   CURRENCY_CONVERSION_DATE      DATE_tbl_type,
   CURRENCY_CONVERSION_TYPE      VARCHAR2_30_tbl_type,
   CURRENCY_CONVERSION_RATE      NUMBER_tbl_type,
   TAX_CURRENCY_CONVERSION_DATE  DATE_tbl_type,
   TAX_CURRENCY_CONVERSION_TYPE  VARCHAR2_30_tbl_type,
   TAX_CURRENCY_CONVERSION_RATE  NUMBER_tbl_type,
   TRX_CURRENCY_CODE             VARCHAR2_15_tbl_type,
   MINIMUM_ACCOUNTABLE_UNIT      NUMBER_tbl_type,
   PRECISION                     NUMBER_tbl_type,
   TRX_NUMBER                    VARCHAR2_150_tbl_type,
   TRX_DESCRIPTION               VARCHAR2_240_tbl_type,
   DOC_SEQ_ID                    NUMBER_tbl_type,
   DOC_SEQ_NAME                  VARCHAR2_150_tbl_type,
   DOC_SEQ_VALUE                 NUMBER_tbl_type,
   TRX_DATE                      DATE_tbl_type,
   RECEIVABLES_TRX_TYPE_ID       NUMBER_tbl_type,
   TRX_TYPE_DESCRIPTION          VARCHAR2_240_tbl_type,
   TRX_LINE_TYPE                 VARCHAR2_30_tbl_type,
   TRX_DUE_DATE                  DATE_tbl_type,
   TRX_SHIPPING_DATE             DATE_tbl_type,
   TRX_RECEIPT_DATE              DATE_tbl_type,
   TRX_COMMUNICATED_DATE         DATE_tbl_type,
   BATCH_SOURCE_NAME             VARCHAR2_150_tbl_type,
   BATCH_SOURCE_ID               NUMBER_tbl_type,
   TRX_SIC_CODE                  VARCHAR2_150_tbl_type,
   FOB_POINT                     VARCHAR2_30_tbl_type,
   TRX_LINE_DESCRIPTION          VARCHAR2_240_tbl_type,
   TRX_WAYBILL_NUMBER            VARCHAR2_50_tbl_type,
   PRODUCT_ID                    NUMBER_tbl_type,
   PRODUCT_TYPE                  VARCHAR2_30_tbl_type,
   PRODUCT_DESCRIPTION           VARCHAR2_240_tbl_type,
   PRODUCT_ORG_ID                NUMBER_tbl_type,
   PRODUCT_CATEGORY              VARCHAR2_240_tbl_type,
   UOM_CODE                      VARCHAR2_30_tbl_type,
   PRODUCT_CODE                  VARCHAR2_30_tbl_type,
   PRODUCT_FISC_CLASSIFICATION   VARCHAR2_240_tbl_type,
   USER_DEFINED_FISC_CLASS       VARCHAR2_30_tbl_type,
   LINE_INTENDED_USE             VARCHAR2_240_tbl_type,
   UNIT_PRICE                    NUMBER_tbl_type,
   LINE_AMT                      NUMBER_tbl_type,
   TRX_LINE_QUANTITY             NUMBER_tbl_type,
   CASH_DISCOUNT                 NUMBER_tbl_type,
   VOLUME_DISCOUNT               NUMBER_tbl_type,
   TRADING_DISCOUNT              NUMBER_tbl_type,
   TRANSFER_CHARGE               NUMBER_tbl_type,
   TRANSPORTATION_CHARGE         NUMBER_tbl_type,
   INSURANCE_CHARGE              NUMBER_tbl_type,
   OTHER_CHARGE                  NUMBER_tbl_type,
   TAX_BASE_MODIFIER_RATE        NUMBER_tbl_type,
   ASSESSABLE_VALUE              NUMBER_tbl_type,
   ASSET_NUMBER                  VARCHAR2_150_tbl_type,
   ASSET_TYPE                    VARCHAR2_150_tbl_type,
   ASSET_COST                    NUMBER_tbl_type,
   ASSET_FLAG                    VARCHAR2_1_tbl_type,
   ASSET_ACCUM_DEPRECIATION      NUMBER_tbl_type,
   REF_DOC_APPLICATION_ID        NUMBER_tbl_type,
   REF_DOC_ENTITY_CODE           VARCHAR2_30_tbl_type,
   REF_DOC_EVENT_CLASS_CODE      VARCHAR2_30_tbl_type,
   REF_DOC_EVENT_TYPE_CODE       VARCHAR2_30_tbl_type,
   REF_DOC_TRX_ID                NUMBER_tbl_type,
   REF_DOC_LINE_ID               NUMBER_tbl_type,
   REF_DOC_LINE_QUANTITY         NUMBER_tbl_type,
   OTHER_DOC_LINE_AMT            NUMBER_tbl_type,
   OTHER_DOC_LINE_TAX_AMT        NUMBER_tbl_type,
   OTHER_DOC_LINE_TAXABLE_AMT    NUMBER_tbl_type,
   UNROUNDED_TAXABLE_AMT         NUMBER_tbl_type,
   RELATED_DOC_APPLICATION_ID    NUMBER_tbl_type,
   RELATED_DOC_ENTITY_CODE       VARCHAR2_30_tbl_type,
   RELATED_DOC_EVENT_CLASS_CODE  VARCHAR2_30_tbl_type,
   RELATED_DOC_EVENT_TYPE_CODE   VARCHAR2_30_tbl_type,
   RELATED_DOC_TRX_ID            NUMBER_tbl_type,
   RELATED_DOC_NUMBER            VARCHAR2_150_tbl_type,
   RELATED_DOC_DATE              DATE_tbl_type,
   APPLIED_FROM_APPLICATION_ID   NUMBER_tbl_type,
   APPLIED_FROM_EVENT_CLASS_CODE VARCHAR2_30_tbl_type,
   APPLIED_FROM_ENTITY_CODE      VARCHAR2_30_tbl_type,
   APPLIED_FROM_TRX_ID           NUMBER_tbl_type,
   APPLIED_FROM_LINE_ID          NUMBER_tbl_type,
   APPLIED_FROM_TRX_NUMBER       VARCHAR2_150_tbl_type,
   ADJUSTED_DOC_APPLICATION_ID   NUMBER_tbl_type,
   ADJUSTED_DOC_ENTITY_CODE      VARCHAR2_30_tbl_type,
   ADJUSTED_DOC_EVENT_CLASS_CODE VARCHAR2_30_tbl_type,
   ADJUSTED_DOC_TRX_ID           NUMBER_tbl_type,
   ADJUSTED_DOC_LINE_ID          NUMBER_tbl_type,
   ADJUSTED_DOC_NUMBER           VARCHAR2_150_tbl_type,
   ADJUSTED_DOC_DATE             DATE_tbl_type,
   APPLIED_TO_APPLICATION_ID     NUMBER_tbl_type,
   APPLIED_TO_EVENT_CLASS_CODE   VARCHAR2_30_tbl_type,
   APPLIED_TO_ENTITY_CODE        VARCHAR2_30_tbl_type,
   APPLIED_TO_TRX_ID             NUMBER_tbl_type,
   APPLIED_TO_TRX_LINE_ID        NUMBER_tbl_type,
   SUMMARY_TAX_LINE_ID           NUMBER_tbl_type,
   OFFSET_LINK_TO_TAX_LINE_ID    NUMBER_tbl_type,
   OFFSET_FLAG                   VARCHAR2_1_tbl_type,
   PROCESS_FOR_RECOVERY_FLAG     VARCHAR2_1_tbl_type,
   TAX_JURISDICTION_ID           NUMBER_tbl_type,
   TAX_JURISDICTION_CODE         VARCHAR2_240_tbl_type,
   PLACE_OF_SUPPLY               NUMBER_tbl_type,
   PLACE_OF_SUPPLY_TYPE          VARCHAR2_30_tbl_type,
   PLACE_OF_SUPPLY_RESULT_ID     NUMBER_tbl_type,
   TAX_DATE_RULE_ID              NUMBER_tbl_type,
   TAX_DATE                      DATE_tbl_type,
   TAX_DETERMINE_DATE            DATE_tbl_type,
   TAX_POINT_DATE                DATE_tbl_type,
   TRX_LINE_DATE                 DATE_tbl_type,
   TAX_TYPE_CODE                 VARCHAR2_30_tbl_type,
   TAX_CODE                      VARCHAR2_30_tbl_type,
   TAX_REGISTRATION_ID           NUMBER_tbl_type,
   TAX_REGISTRATION_NUMBER       VARCHAR2_50_tbl_type,
   REGISTRATION_PARTY_TYPE       VARCHAR2_30_tbl_type,
   ROUNDING_LEVEL                VARCHAR2_30_tbl_type,
   ROUNDING_RULE                 VARCHAR2_30_tbl_type,
   ROUNDING_LVL_PARTY_TAX_PROF_ID NUMBER_tbl_type,
   ROUNDING_LVL_PARTY_TYPE       VARCHAR2_30_tbl_type,
   COMPOUNDING_TAX_FLAG          VARCHAR2_1_tbl_type,
   TRX_BUSINESS_CATEGORY         VARCHAR2_240_tbl_type,
   ORIG_TAX_STATUS_ID            NUMBER_tbl_type,
   ORIG_TAX_STATUS_CODE          VARCHAR2_30_tbl_type,
   ORIG_TAX_RATE_ID              NUMBER_tbl_type,
   ORIG_TAX_RATE_CODE            VARCHAR2_30_tbl_type,
   ORIG_TAX_RATE                 NUMBER_tbl_type,
   TAX_CURRENCY_CODE             VARCHAR2_15_tbl_type,
   TAX_AMT                       NUMBER_tbl_type,
   TAX_AMT_TAX_CURR              NUMBER_tbl_type,
   TAX_AMT_FUNCL_CURR            NUMBER_tbl_type,
   TAXABLE_AMT                   NUMBER_tbl_type,
   TAXABLE_AMT_TAX_CURR          NUMBER_tbl_type,
   TAXABLE_AMT_FUNCL_CURR        NUMBER_tbl_type,
   ORIG_TAXABLE_AMT              NUMBER_tbl_type,
   ORIG_TAXABLE_AMT_TAX_CURR     NUMBER_tbl_type,
   ORIG_TAXABLE_AMT_FUNCL_CURR   NUMBER_tbl_type,
   CAL_TAX_AMT                   NUMBER_tbl_type,
   CAL_TAX_AMT_TAX_CURR          NUMBER_tbl_type,
   CAL_TAX_AMT_FUNCL_CURR        NUMBER_tbl_type,
   ORIG_TAX_AMT                  NUMBER_tbl_type,
   ORIG_TAX_AMT_TAX_CURR         NUMBER_tbl_type,
   ORIG_TAX_AMT_FUNCL_CURR       NUMBER_tbl_type,
   REC_TAX_AMT                   NUMBER_tbl_type,
   REC_TAX_AMT_TAX_CURR          NUMBER_tbl_type,
   REC_TAX_AMT_FUNCL_CURR        NUMBER_tbl_type,
   NREC_TAX_AMT                  NUMBER_tbl_type,
   NREC_TAX_AMT_TAX_CURR         NUMBER_tbl_type,
   NREC_TAX_AMT_FUNCL_CURR       NUMBER_tbl_type,
   TAX_EXEMPTION_ID              NUMBER_tbl_type,
   EXEMPTION_RATE                NUMBER_tbl_type,
   EXEMPT_RATE_NAME              VARCHAR2_150_tbl_type,
   EXEMPT_RATE_MODIFIER          NUMBER_tbl_type,
   EXEMPT_CERTIFICATE_NUMBER     VARCHAR2_80_tbl_type,
   EXEMPT_REASON                 VARCHAR2_240_tbl_type,
   EXEMPT_REASON_CODE            VARCHAR2_30_tbl_type,
   TAX_EXCEPTION_ID              NUMBER_tbl_type,
   EXCEPTION_RATE                NUMBER_tbl_type,
   EXCEPTION_RATE_NAME           VARCHAR2_150_tbl_type,
   EXCEPTION_RATE_MODIFIER       NUMBER_tbl_type,
   TAX_APPORTIONMENT_FLAG        VARCHAR2_1_tbl_type,
   HISTORICAL_FLAG               VARCHAR2_1_tbl_type,
   DEFAULT_TAXATION_COUNTRY      VARCHAR2_2_tbl_type,
   TAXABLE_BASIS_FORMULA         VARCHAR2_30_tbl_type,
   TAX_CALCULATION_FORMULA       VARCHAR2_30_tbl_type,
   TRX_LINE_GL_DATE              DATE_tbl_type,
   CANCEL_FLAG                   VARCHAR2_1_tbl_type,
   PURGE_FLAG                    VARCHAR2_1_tbl_type,
   DELETE_FLAG                   VARCHAR2_1_tbl_type,
   TAX_AMT_INCLUDED_FLAG         VARCHAR2_1_tbl_type,
   LINE_AMT_INCLUDES_TAX_FLAG    VARCHAR2_1_tbl_type,
   SELF_ASSESSED_FLAG            VARCHAR2_1_tbl_type,
   OVERRIDDEN_FLAG               VARCHAR2_1_tbl_type,
   MANUALLY_ENTERED_FLAG         VARCHAR2_1_tbl_type,
   REPORTING_ONLY_FLAG           VARCHAR2_1_tbl_type,
   FREEZE_UNTIL_OVERRIDDEN_FLAG  VARCHAR2_1_tbl_type,
   COPIED_FROM_REF_DOC_FLAG      VARCHAR2_1_tbl_type,
   RECALC_REQUIRED_FLAG          VARCHAR2_1_tbl_type,
   SETTLEMENT_FLAG               VARCHAR2_1_tbl_type,
   ITEM_DIST_CHANGED_FLAG        VARCHAR2_1_tbl_type,
   ASSOCIATED_CHILD_FROZEN_FLAG  VARCHAR2_1_tbl_type,
   TAX_ONLY_LINE_FLAG            VARCHAR2_1_tbl_type,
   LAST_MANUAL_ENTRY             VARCHAR2_30_tbl_type,
   TAX_PROVIDER_ID               NUMBER_tbl_type,
   RECORD_TYPE                   VARCHAR2_30_tbl_type,
   REPORTING_PERIOD_ID           NUMBER_tbl_type,
   ACCOUNT_CCID                  NUMBER_tbl_type,
   ACCOUNT_STRING                VARCHAR2_2000_tbl_type,
   LEGAL_MESSAGE_APPL_2          NUMBER_tbl_type,
   LEGAL_MESSAGE_STATUS          NUMBER_tbl_type,
   LEGAL_MESSAGE_RATE            NUMBER_tbl_type,
   LEGAL_MESSAGE_BASIS           NUMBER_tbl_type,
   LEGAL_MESSAGE_CALC            NUMBER_tbl_type,
   LEGAL_MESSAGE_THRESHOLD       NUMBER_tbl_type,
   LEGAL_MESSAGE_POS             NUMBER_tbl_type,
   LEGAL_MESSAGE_TRN             NUMBER_tbl_type,
   LEGAL_MESSAGE_EXMPT           NUMBER_tbl_type,
   LEGAL_MESSAGE_EXCPT           NUMBER_tbl_type,
   MERCHANT_PARTY_DOCUMENT_NUMBER VARCHAR2_150_tbl_type,
   MERCHANT_PARTY_TAX_PROF_ID    NUMBER_tbl_type,
   MERCHANT_PARTY_NAME           VARCHAR2_150_tbl_type,
   MERCHANT_PARTY_REFERENCE      VARCHAR2_250_tbl_type,
   MERCHANT_PARTY_TAXPAYER_ID    VARCHAR2_80_tbl_type,
   MERCHANT_PARTY_TAX_REG_NUMBER VARCHAR2_150_tbl_type,
   MERCHANT_PARTY_COUNTRY        VARCHAR2_150_tbl_type,
   SHIP_TO_LOCATION_ID           NUMBER_tbl_type,
   SHIP_FROM_LOCATION_ID         NUMBER_tbl_type,
   POA_LOCATION_ID               NUMBER_tbl_type,
   POO_LOCATION_ID               NUMBER_tbl_type,
   PAYING_LOCATION_ID            NUMBER_tbl_type,
   OWN_HQ_LOCATION_ID            NUMBER_tbl_type,
   TRADING_HQ_LOCATION_ID        NUMBER_tbl_type,
   POC_LOCATION_ID               NUMBER_tbl_type,
   POI_LOCATION_ID               NUMBER_tbl_type,
   POD_LOCATION_ID               NUMBER_tbl_type,
   BILL_TO_LOCATION_ID           NUMBER_tbl_type,
   BILL_FROM_LOCATION_ID         NUMBER_tbl_type,
   TITLE_TRANSFER_LOCATION_ID    NUMBER_tbl_type,
   SHIP_TO_PARTY_TAX_PROF_ID     NUMBER_tbl_type,
   SHIP_FROM_PARTY_TAX_PROF_ID   NUMBER_tbl_type,
   POO_PARTY_TAX_PROF_ID         NUMBER_tbl_type,
   POA_PARTY_TAX_PROF_ID         NUMBER_tbl_type,
   PAYING_PARTY_TAX_PROF_ID      NUMBER_tbl_type,
   OWN_HQ_PARTY_TAX_PROF_ID      NUMBER_tbl_type,
   TRADING_HQ_PARTY_TAX_PROF_ID  NUMBER_tbl_type,
   POI_PARTY_TAX_PROF_ID         NUMBER_tbl_type,
   POD_PARTY_TAX_PROF_ID         NUMBER_tbl_type,
   BILL_TO_PARTY_TAX_PROF_ID     NUMBER_tbl_type,
   BILL_FROM_PARTY_TAX_PROF_ID   NUMBER_tbl_type,
   TITLE_TRANS_PARTY_TAX_PROF_ID NUMBER_tbl_type,
   SHIP_TO_SITE_TAX_PROF_ID      NUMBER_tbl_type,
   SHIP_FROM_SITE_TAX_PROF_ID    NUMBER_tbl_type,
   POO_SITE_TAX_PROF_ID          NUMBER_tbl_type,
   POA_SITE_TAX_PROF_ID          NUMBER_tbl_type,
   PAYING_SITE_TAX_PROF_ID       NUMBER_tbl_type,
   OWN_HQ_SITE_TAX_PROF_ID       NUMBER_tbl_type,
   TRADING_HQ_SITE_TAX_PROF_ID   NUMBER_tbl_type,
   POI_SITE_TAX_PROF_ID          NUMBER_tbl_type,
   POD_SITE_TAX_PROF_ID          NUMBER_tbl_type,
   BILL_TO_SITE_TAX_PROF_ID      NUMBER_tbl_type,
   BILL_FROM_SITE_TAX_PROF_ID    NUMBER_tbl_type,
   TITLE_TRANS_SITE_TAX_PROF_ID  NUMBER_tbl_type,
   TAX_REGIME_TEMPLATE_ID        NUMBER_tbl_type,
   TAX_APPLICABILITY_RESULT_ID   NUMBER_tbl_type,
   DIRECT_RATE_RESULT_ID         NUMBER_tbl_type,
   STATUS_RESULT_ID              NUMBER_tbl_type,
   RATE_RESULT_ID                NUMBER_tbl_type,
   BASIS_RESULT_ID               NUMBER_tbl_type,
   THRESH_RESULT_ID              NUMBER_tbl_type,
   CALC_RESULT_ID                NUMBER_tbl_type,
   TAX_REG_NUM_DET_RESULT_ID     NUMBER_tbl_type,
   EVAL_EXMPT_RESULT_ID          NUMBER_tbl_type,
   EVAL_EXCPT_RESULT_ID          NUMBER_tbl_type,
   DOCUMENT_SUB_TYPE             VARCHAR2_240_tbl_type,
   SUPPLIER_TAX_INVOICE_NUMBER   VARCHAR2_150_tbl_type,
   SUPPLIER_TAX_INVOICE_DATE     DATE_tbl_type,
   SUPPLIER_EXCHANGE_RATE        NUMBER_tbl_type,
   TAX_INVOICE_DATE              DATE_tbl_type,
   TAX_INVOICE_NUMBER            VARCHAR2_150_tbl_type,
   ENFORCE_FROM_NATURAL_ACCT_FLAG VARCHAR2_1_tbl_type,
   TAX_HOLD_CODE                 VARCHAR2_30_tbl_type,
   TAX_HOLD_RELEASED_CODE        VARCHAR2_30_tbl_type,
   INTERNAL_ORG_LOCATION_ID      NUMBER_tbl_type,
   ATTRIBUTE_CATEGORY            VARCHAR2_150_tbl_type,
   ATTRIBUTE1                    VARCHAR2_150_tbl_type,
   ATTRIBUTE2                    VARCHAR2_150_tbl_type,
   ATTRIBUTE3                    VARCHAR2_150_tbl_type,
   ATTRIBUTE4                    VARCHAR2_150_tbl_type,
   ATTRIBUTE5                    VARCHAR2_150_tbl_type,
   ATTRIBUTE6                    VARCHAR2_150_tbl_type,
   ATTRIBUTE7                    VARCHAR2_150_tbl_type,
   ATTRIBUTE8                    VARCHAR2_150_tbl_type,
   ATTRIBUTE9                    VARCHAR2_150_tbl_type,
   ATTRIBUTE10                   VARCHAR2_150_tbl_type,
   ATTRIBUTE11                   VARCHAR2_150_tbl_type,
   ATTRIBUTE12                   VARCHAR2_150_tbl_type,
   ATTRIBUTE13                   VARCHAR2_150_tbl_type,
   ATTRIBUTE14                   VARCHAR2_150_tbl_type,
   ATTRIBUTE15                   VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE_CATEGORY     VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE1             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE2             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE3             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE4             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE5             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE6             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE7             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE8             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE9             VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE10            VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE11            VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE12            VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE13            VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE14            VARCHAR2_150_tbl_type,
   GLOBAL_ATTRIBUTE15            VARCHAR2_150_tbl_type,
   NUMERIC1                      NUMBER_tbl_type,
   NUMERIC2                      NUMBER_tbl_type,
   NUMERIC3                      NUMBER_tbl_type,
   NUMERIC4                      NUMBER_tbl_type,
   NUMERIC5                      NUMBER_tbl_type,
   NUMERIC6                      NUMBER_tbl_type,
   NUMERIC7                      NUMBER_tbl_type,
   NUMERIC8                      NUMBER_tbl_type,
   NUMERIC9                      NUMBER_tbl_type,
   NUMERIC10                     NUMBER_tbl_type,
   CHAR1                         VARCHAR2_150_tbl_type,
   CHAR2                         VARCHAR2_150_tbl_type,
   CHAR3                         VARCHAR2_150_tbl_type,
   CHAR4                         VARCHAR2_150_tbl_type,
   CHAR5                         VARCHAR2_150_tbl_type,
   CHAR6                         VARCHAR2_150_tbl_type,
   CHAR7                         VARCHAR2_150_tbl_type,
   CHAR8                         VARCHAR2_150_tbl_type,
   CHAR9                         VARCHAR2_150_tbl_type,
   CHAR10                        VARCHAR2_150_tbl_type,
   DATE1                         DATE_tbl_type,
   DATE2                         DATE_tbl_type,
   DATE3                         DATE_tbl_type,
   DATE4                         DATE_tbl_type,
   DATE5                         DATE_tbl_type,
   DATE6                         DATE_tbl_type,
   DATE7                         DATE_tbl_type,
   DATE8                         DATE_tbl_type,
   DATE9                         DATE_tbl_type,
   DATE10                        DATE_tbl_type,
   CREATED_BY                    NUMBER_tbl_type,
   CREATION_DATE                 DATE_tbl_type,
   LAST_UPDATED_BY               NUMBER_tbl_type,
   LAST_UPDATE_DATE              DATE_tbl_type,
   LAST_UPDATE_LOGIN             NUMBER_tbl_type,
   SUBSCRIBER_ID                 NUMBER_tbl_type,
   LEGAL_ENTITY_TAX_REG_NUMBER   NUMBER_tbl_type,
   UNROUNDED_TAX_AMT             NUMBER_tbl_type,
   PRD_TOTAL_TAX_AMT             NUMBER_tbl_type,
   PRD_TOTAL_TAX_AMT_TAX_CURR    NUMBER_tbl_type,
   PRD_TOTAL_TAX_AMT_FUNCL_CURR  NUMBER_tbl_type);

  TYPE zx_lines_summary_rec_tbl_type IS RECORD (
   SUMMARY_TAX_LINE_ID           NUMBER_tbl_type,
   INTERNAL_ORGANIZATION_ID      NUMBER_tbl_type,
   APPLICATION_ID                NUMBER_tbl_type,
   ENTITY_CODE                   VARCHAR2_30_tbl_type,
   EVENT_CLASS_CODE              VARCHAR2_30_tbl_type,
   TAX_EVENT_CLASS_CODE          VARCHAR2_30_tbl_type,
   TRX_ID                        NUMBER_tbl_type,
   TRX_LEVEL_TYPE                VARCHAR2_30_tbl_type,
   TRX_NUMBER                    VARCHAR2_150_tbl_type,
   APPLIED_FROM_APPLICATION_ID   NUMBER_tbl_type,
   APPLIED_FROM_EVENT_CLASS_CODE VARCHAR2_30_tbl_type,
   APPLIED_FROM_ENTITY_CODE      VARCHAR2_30_tbl_type,
   APPLIED_FROM_TRX_NUMBER       VARCHAR2_150_tbl_type,
   APPLIED_FROM_TRX_ID           NUMBER_tbl_type,
   ADJUSTED_DOC_APPLICATION_ID   NUMBER_tbl_type,
   ADJUSTED_DOC_ENTITY_CODE      VARCHAR2_30_tbl_type,
   ADJUSTED_DOC_EVENT_CLASS_CODE VARCHAR2_30_tbl_type,
   ADJUSTED_DOC_TRX_ID           NUMBER_tbl_type,
   ADJUSTED_DOC_NUMBER           VARCHAR2_150_tbl_type,
   SUMMARY_TAX_LINE_NUMBER       NUMBER_tbl_type,
   CONTENT_OWNER_ID              NUMBER_tbl_type,
   TAX_REGIME_ID                 NUMBER_tbl_type,
   TAX_REGIME_CODE               VARCHAR2_30_tbl_type,
   TAX_ID                        NUMBER_tbl_type,
   TAX                           VARCHAR2_30_tbl_type,
   TAX_STATUS_ID                 NUMBER_tbl_type,
   TAX_STATUS_CODE               VARCHAR2_30_tbl_type,
   TAX_RATE_ID                   NUMBER_tbl_type,
   TAX_RATE_CODE                 VARCHAR2_30_tbl_type,
   TAX_RATE                      NUMBER_tbl_type,
   TAX_AMT                       NUMBER_tbl_type,
   TAX_AMT_TAX_CURR              NUMBER_tbl_type,
   TAX_AMT_FUNCL_CURR            NUMBER_tbl_type,
   TAX_JURISDICTION_ID           NUMBER_tbl_type,
   TAX_JURISDICTION_CODE         VARCHAR2_240_tbl_type,
   ORIG_TAX_STATUS_ID            NUMBER_tbl_type,
   ORIG_TAX_STATUS_CODE          VARCHAR2_30_tbl_type,
   ORIG_TAX_RATE_ID              NUMBER_tbl_type,
   ORIG_TAX_RATE_CODE            VARCHAR2_30_tbl_type,
   ORIG_TAX_RATE                 NUMBER_tbl_type,
   ORIG_TAX_AMT                  NUMBER_tbl_type,
   ORIG_TAX_AMT_FUNCL_CURR       NUMBER_tbl_type,
   TOTAL_REC_TAX_AMT             NUMBER_tbl_type,
   TOTAL_REC_TAX_AMT_FUNCL_CURR  NUMBER_tbl_type,
   TOTAL_NREC_TAX_AMT            NUMBER_tbl_type,
   TOTAL_NREC_TAX_AMT_FUNCL_CURR NUMBER_tbl_type,
   LEDGER_ID                     NUMBER_tbl_type,
   LEGAL_ENTITY_ID               NUMBER_tbl_type,
   ESTABLISHMENT_ID              NUMBER_tbl_type,
   CURRENCY_CONVERSION_DATE      DATE_tbl_type,
   CURRENCY_CONVERSION_TYPE      VARCHAR2_30_tbl_type,
   CURRENCY_CONVERSION_RATE      NUMBER_tbl_type,
   SUMMARIZATION_TEMPLATE_ID     NUMBER_tbl_type,
   TAXABLE_BASIS_FORMULA         VARCHAR2_30_tbl_type,
   TAX_CALCULATION_FORMULA       VARCHAR2_30_tbl_type,
   HISTORICAL_FLAG               VARCHAR2_1_tbl_type,
   CANCEL_FLAG                   VARCHAR2_1_tbl_type,
   PURGE_FLAG                    VARCHAR2_1_tbl_type,
   DELETE_FLAG                   VARCHAR2_1_tbl_type,
   TAX_AMT_INCLUDED_FLAG         VARCHAR2_1_tbl_type,
   COMPOUNDING_TAX_FLAG          VARCHAR2_1_tbl_type,
   SELF_ASSESSED_FLAG            VARCHAR2_1_tbl_type,
   OVERRIDDEN_FLAG               VARCHAR2_1_tbl_type,
   REPORTING_ONLY_FLAG           VARCHAR2_1_tbl_type,
   ASSOCIATED_CHILD_FROZEN_FLAG  VARCHAR2_1_tbl_type,
   COPIED_FROM_REF_DOC_FLAG      VARCHAR2_1_tbl_type,
   MANUALLY_ENTERED_FLAG         VARCHAR2_1_tbl_type,
   LAST_MANUAL_ENTRY             VARCHAR2_30_tbl_type,
   RECORD_TYPE                   VARCHAR2_30_tbl_type,
   TAX_PROVIDER_ID               NUMBER_tbl_type,
   TAX_ONLY_LINE_FLAG            VARCHAR2_1_tbl_type,
   CREATED_BY                    NUMBER_tbl_type,
   CREATION_DATE                 DATE_tbl_type,
   LAST_UPDATED_BY               NUMBER_tbl_type,
   LAST_UPDATE_DATE              DATE_tbl_type,
   LAST_UPDATE_LOGIN             NUMBER_tbl_type,
   ATTRIBUTE_CATEGORY            VARCHAR2_150_tbl_type,
   ATTRIBUTE1                    VARCHAR2_150_tbl_type,
   ATTRIBUTE2                    VARCHAR2_150_tbl_type,
   ATTRIBUTE3                    VARCHAR2_150_tbl_type,
   ATTRIBUTE4                    VARCHAR2_150_tbl_type,
   ATTRIBUTE5                    VARCHAR2_150_tbl_type,
   ATTRIBUTE6                    VARCHAR2_150_tbl_type,
   ATTRIBUTE7                    VARCHAR2_150_tbl_type,
   ATTRIBUTE8                    VARCHAR2_150_tbl_type,
   ATTRIBUTE9                    VARCHAR2_150_tbl_type,
   ATTRIBUTE10                   VARCHAR2_150_tbl_type,
   ATTRIBUTE11                   VARCHAR2_150_tbl_type,
   ATTRIBUTE12                   VARCHAR2_150_tbl_type,
   ATTRIBUTE13                   VARCHAR2_150_tbl_type,
   ATTRIBUTE14                   VARCHAR2_150_tbl_type,
   ATTRIBUTE15                   VARCHAR2_150_tbl_type,
   SUBSCRIBER_ID                 NUMBER_tbl_type);

  TYPE zx_rec_nrec_dist_rec_tbl_type IS RECORD (
   SUMMARY_TAX_LINE_ID            NUMBER_tbl_type,
   INTERNAL_ORGANIZATION_ID       NUMBER_tbl_type,
   APPLICATION_ID                 NUMBER_tbl_type,
   ENTITY_CODE                    VARCHAR2_30_tbl_type,
   EVENT_CLASS_CODE               VARCHAR2_30_tbl_type,
   EVENT_TYPE_CODE                VARCHAR2_30_tbl_type,
   TAX_EVENT_CLASS_CODE           VARCHAR2_30_tbl_type,
   TRX_ID                         NUMBER_tbl_type,
   TRX_LEVEL_TYPE                 VARCHAR2_30_tbl_type,
   TRX_NUMBER                     VARCHAR2_150_tbl_type,
   TRX_LINE_NUMBER                NUMBER_tbl_type,
   APPLIED_FROM_APPLICATION_ID    NUMBER_tbl_type,
   APPLIED_FROM_EVENT_CLASS_CODE  VARCHAR2_30_tbl_type,
   APPLIED_FROM_ENTITY_CODE       VARCHAR2_30_tbl_type,
   APPLIED_FROM_TRX_NUMBER        VARCHAR2_150_tbl_type,
   APPLIED_FROM_TRX_ID            NUMBER_tbl_type,
   ADJUSTED_DOC_APPLICATION_ID    NUMBER_tbl_type,
   ADJUSTED_DOC_ENTITY_CODE       VARCHAR2_30_tbl_type,
   ADJUSTED_DOC_EVENT_CLASS_CODE  VARCHAR2_30_tbl_type,
   ADJUSTED_DOC_TRX_ID            NUMBER_tbl_type,
   ADJUSTED_DOC_NUMBER            VARCHAR2_150_tbl_type,
   SUMMARY_TAX_LINE_NUMBER        NUMBER_tbl_type,
   CONTENT_OWNER_ID               NUMBER_tbl_type,
   TAX_REGIME_ID                  NUMBER_tbl_type,
   TAX_REGIME_CODE                VARCHAR2_30_tbl_type,
   TAX_ID                         NUMBER_tbl_type,
   TAX_LINE_ID                    NUMBER_tbl_type,
   TAX                            VARCHAR2_30_tbl_type,
   TAX_STATUS_ID                  NUMBER_tbl_type,
   TAX_STATUS_CODE                VARCHAR2_30_tbl_type,
   TAX_RATE_ID                    NUMBER_tbl_type,
   TAX_RATE_CODE                  VARCHAR2_30_tbl_type,
   TAX_RATE                       NUMBER_tbl_type,
   TAX_AMT                        NUMBER_tbl_type,
   TAXABLE_AMT                    NUMBER_tbl_type,
   TAXABLE_AMT_FUNCL_CURR         NUMBER_tbl_type,
   TAX_AMT_TAX_CURR               NUMBER_tbl_type,
   TAX_AMT_FUNCL_CURR             NUMBER_tbl_type,
   TAX_JURISDICTION_ID            NUMBER_tbl_type,
   TAX_JURISDICTION_CODE          VARCHAR2_240_tbl_type,
   ORIG_TAX_STATUS_ID             NUMBER_tbl_type,
   ORIG_TAX_STATUS_CODE           VARCHAR2_30_tbl_type,
   ORIG_TAX_RATE_ID               NUMBER_tbl_type,
   ORIG_TAX_RATE_CODE             VARCHAR2_30_tbl_type,
   ORIG_TAX_RATE                  NUMBER_tbl_type,
   ORIG_TAX_AMT                   NUMBER_tbl_type,
   ORIG_TAX_AMT_FUNCL_CURR        NUMBER_tbl_type,
   TOTAL_REC_TAX_AMT              NUMBER_tbl_type,
   TOTAL_REC_TAX_AMT_FUNCL_CURR   NUMBER_tbl_type,
   TOTAL_NREC_TAX_AMT             NUMBER_tbl_type,
   TOTAL_NREC_TAX_AMT_FUNCL_CURR  NUMBER_tbl_type,
   LEDGER_ID                      NUMBER_tbl_type,
   LEGAL_ENTITY_ID                NUMBER_tbl_type,
   ESTABLISHMENT_ID               NUMBER_tbl_type,
   CURRENCY_CONVERSION_DATE       DATE_tbl_type,
   CURRENCY_CONVERSION_TYPE       VARCHAR2_30_tbl_type,
   CURRENCY_CONVERSION_RATE       NUMBER_tbl_type,
   SUMMARIZATION_TEMPLATE_ID      NUMBER_tbl_type,
   TAXABLE_BASIS_FORMULA          VARCHAR2_30_tbl_type,
   TAX_CALCULATION_FORMULA        VARCHAR2_30_tbl_type,
   HISTORICAL_FLAG                VARCHAR2_1_tbl_type,
   CANCEL_FLAG                    VARCHAR2_1_tbl_type,
   PURGE_FLAG                     VARCHAR2_1_tbl_type,
   DELETE_FLAG                    VARCHAR2_1_tbl_type,
   TAX_AMT_INCLUDED_FLAG          VARCHAR2_1_tbl_type,
   COMPOUNDING_TAX_FLAG           VARCHAR2_1_tbl_type,
   SELF_ASSESSED_FLAG             VARCHAR2_1_tbl_type,
   OVERRIDDEN_FLAG                VARCHAR2_1_tbl_type,
   REPORTING_ONLY_FLAG            VARCHAR2_1_tbl_type,
   ASSOCIATED_CHILD_FROZEN_FLAG   VARCHAR2_1_tbl_type,
   COPIED_FROM_REF_DOC_FLAG       VARCHAR2_1_tbl_type,
   MANUALLY_ENTERED_FLAG          VARCHAR2_1_tbl_type,
   LAST_MANUAL_ENTRY              VARCHAR2_30_tbl_type,
   RECORD_TYPE                    VARCHAR2_30_tbl_type,
   TAX_PROVIDER_ID                NUMBER_tbl_type,
   TAX_ONLY_LINE_FLAG             VARCHAR2_1_tbl_type,
   CREATED_BY                     NUMBER_tbl_type,
   CREATION_DATE                  DATE_tbl_type,
   LAST_UPDATED_BY                NUMBER_tbl_type,
   LAST_UPDATE_DATE               DATE_tbl_type,
   LAST_UPDATE_LOGIN              NUMBER_tbl_type,
   ATTRIBUTE_CATEGORY             VARCHAR2_150_tbl_type,
   ATTRIBUTE1                     VARCHAR2_150_tbl_type,
   ATTRIBUTE2                     VARCHAR2_150_tbl_type,
   ATTRIBUTE3                     VARCHAR2_150_tbl_type,
   ATTRIBUTE4                     VARCHAR2_150_tbl_type,
   ATTRIBUTE5                     VARCHAR2_150_tbl_type,
   ATTRIBUTE6                     VARCHAR2_150_tbl_type,
   ATTRIBUTE7                     VARCHAR2_150_tbl_type,
   ATTRIBUTE8                     VARCHAR2_150_tbl_type,
   ATTRIBUTE9                     VARCHAR2_150_tbl_type,
   ATTRIBUTE10                    VARCHAR2_150_tbl_type,
   ATTRIBUTE11                    VARCHAR2_150_tbl_type,
   ATTRIBUTE12                    VARCHAR2_150_tbl_type,
   ATTRIBUTE13                    VARCHAR2_150_tbl_type,
   ATTRIBUTE14                    VARCHAR2_150_tbl_type,
   ATTRIBUTE15                    VARCHAR2_150_tbl_type,
   SUBSCRIBER_ID                  NUMBER_tbl_type);


  TYPE zx_trx_headers_rec_tbl_type IS RECORD (
   INTERNAL_ORGANIZATION_ID                   NUMBER_tbl_type,
   INTERNAL_ORG_LOCATION_ID                   NUMBER_tbl_type,
   APPLICATION_ID                             NUMBER_tbl_type,
   ENTITY_CODE                                VARCHAR2_30_tbl_type,
   EVENT_CLASS_CODE                           VARCHAR2_30_tbl_type,
   EVENT_TYPE_CODE                            VARCHAR2_30_tbl_type,
   TRX_ID                                     NUMBER_tbl_type,
   HDR_TRX_USER_KEY1                          VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY2                          VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY3                          VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY4                          VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY5                          VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY6                          VARCHAR2_150_tbl_type,
   TRX_DATE                                   DATE_tbl_type,
   TRX_DOC_REVISION                           VARCHAR2_150_tbl_type,
   LEDGER_ID                                  NUMBER_tbl_type,
   TRX_CURRENCY_CODE                          VARCHAR2_15_tbl_type,
   CURRENCY_CONVERSION_DATE                   DATE_tbl_type,
   CURRENCY_CONVERSION_RATE                   NUMBER_tbl_type,
   CURRENCY_CONVERSION_TYPE                   VARCHAR2_30_tbl_type,
   MINIMUM_ACCOUNTABLE_UNIT                   NUMBER_tbl_type,
   PRECISION                                  NUMBER_tbl_type,
   LEGAL_ENTITY_ID                            NUMBER_tbl_type,
   ROUNDING_SHIP_TO_PARTY_ID                  NUMBER_tbl_type,
   ROUNDING_SHIP_FROM_PARTY_ID                NUMBER_tbl_type,
   ROUNDING_BILL_TO_PARTY_ID                  NUMBER_tbl_type,
   ROUNDING_BILL_FROM_PARTY_ID                NUMBER_tbl_type,
   RNDG_SHIP_TO_PARTY_SITE_ID                 NUMBER_tbl_type,
   RNDG_SHIP_FROM_PARTY_SITE_ID               NUMBER_tbl_type,
   RNDG_BILL_TO_PARTY_SITE_ID                 NUMBER_tbl_type,
   RNDG_BILL_FROM_PARTY_SITE_ID               NUMBER_tbl_type,
   ESTABLISHMENT_ID                           NUMBER_tbl_type,
   RECEIVABLES_TRX_TYPE_ID                    NUMBER_tbl_type,
   RELATED_DOC_APPLICATION_ID                 NUMBER_tbl_type,
   RELATED_DOC_ENTITY_CODE                    VARCHAR2_30_tbl_type,
   RELATED_DOC_EVENT_CLASS_CODE               VARCHAR2_30_tbl_type,
   RELATED_DOC_TRX_ID                         NUMBER_tbl_type,
   REL_DOC_HDR_TRX_USER_KEY1                  VARCHAR2_150_tbl_type,
   REL_DOC_HDR_TRX_USER_KEY2                  VARCHAR2_150_tbl_type,
   REL_DOC_HDR_TRX_USER_KEY3                  VARCHAR2_150_tbl_type,
   REL_DOC_HDR_TRX_USER_KEY4                  VARCHAR2_150_tbl_type,
   REL_DOC_HDR_TRX_USER_KEY5                  VARCHAR2_150_tbl_type,
   REL_DOC_HDR_TRX_USER_KEY6                  VARCHAR2_150_tbl_type,
   RELATED_DOC_NUMBER                         VARCHAR2_150_tbl_type,
   RELATED_DOC_DATE                           DATE_tbl_type,
   DEFAULT_TAXATION_COUNTRY                   VARCHAR2_2_tbl_type,
   QUOTE_FLAG                                 VARCHAR2_1_tbl_type,
   VALIDATION_CHECK_FLAG                      VARCHAR2_1_tbl_type,
   CTRL_TOTAL_HDR_TX_AMT                      NUMBER_tbl_type,
   TRX_NUMBER                                 VARCHAR2_150_tbl_type,
   TRX_DESCRIPTION                            VARCHAR2_240_tbl_type,
   TRX_COMMUNICATED_DATE                      DATE_tbl_type,
   BATCH_SOURCE_ID                            NUMBER_tbl_type,
   BATCH_SOURCE_NAME                          VARCHAR2_150_tbl_type,
   DOC_SEQ_ID                                 NUMBER_tbl_type,
   DOC_SEQ_NAME                               VARCHAR2_150_tbl_type,
   DOC_SEQ_VALUE                              VARCHAR2_150_tbl_type,
   TRX_DUE_DATE                               DATE_tbl_type,
   TRX_TYPE_DESCRIPTION                       VARCHAR2_240_tbl_type,
   DOCUMENT_SUB_TYPE                          VARCHAR2_240_tbl_type,
   SUPPLIER_TAX_INVOICE_NUMBER                VARCHAR2_150_tbl_type,
   SUPPLIER_TAX_INVOICE_DATE                  DATE_tbl_type,
   SUPPLIER_EXCHANGE_RATE                     NUMBER_tbl_type,
   TAX_INVOICE_DATE                           DATE_tbl_type,
   TAX_INVOICE_NUMBER                         VARCHAR2_150_tbl_type,
   SUBSCRIBER_ID                              NUMBER_tbl_type,
   TAX_EVENT_CLASS_CODE                       VARCHAR2_30_tbl_type,
   TAX_EVENT_TYPE_CODE                        VARCHAR2_30_tbl_type,
   DOC_EVENT_STATUS                           VARCHAR2_30_tbl_type,
   RDNG_SHIP_TO_PTY_TX_PROF_ID                NUMBER_tbl_type,
   RDNG_SHIP_FROM_PTY_TX_PROF_ID              NUMBER_tbl_type,
   RDNG_BILL_TO_PTY_TX_PROF_ID                NUMBER_tbl_type,
   RDNG_BILL_FROM_PTY_TX_PROF_ID              NUMBER_tbl_type,
   RDNG_SHIP_TO_PTY_TX_P_ST_ID                NUMBER_tbl_type,
   RDNG_SHIP_FROM_PTY_TX_P_ST_ID              NUMBER_tbl_type,
   RDNG_BILL_TO_PTY_TX_P_ST_ID                NUMBER_tbl_type,
   RDNG_BILL_FROM_PTY_TX_P_ST_ID              NUMBER_tbl_type,
   PORT_OF_ENTRY_CODE                         VARCHAR2_30_TBL_TYPE);

TYPE zx_trx_lines_rec_tbl_type IS RECORD(
   APPLICATION_ID                      NUMBER_tbl_type      ,
   ENTITY_CODE                         VARCHAR2_30_tbl_type ,
   EVENT_CLASS_CODE                    VARCHAR2_30_tbl_type ,
   TRX_ID                              NUMBER_tbl_type      ,
   TRX_LEVEL_TYPE                      VARCHAR2_30_tbl_type ,
   TRX_LINE_ID                         NUMBER_tbl_type      ,
   LINE_LEVEL_ACTION                   VARCHAR2_30_tbl_type ,
   TRX_SHIPPING_DATE                   DATE_tbl_type        ,
   TRX_RECEIPT_DATE                    DATE_tbl_type        ,
   TRX_LINE_TYPE                       VARCHAR2_30_tbl_type ,
   TRX_LINE_DATE                       DATE_tbl_type        ,
   TRX_BUSINESS_CATEGORY               VARCHAR2_240_tbl_type ,
   LINE_INTENDED_USE                   VARCHAR2_240_tbl_type ,
   USER_DEFINED_FISC_CLASS             VARCHAR2_30_tbl_type ,
   LINE_AMT                            NUMBER_tbl_type      ,
   TRX_LINE_QUANTITY                   NUMBER_tbl_type      ,
   UNIT_PRICE                          NUMBER_tbl_type      ,
   EXEMPT_CERTIFICATE_NUMBER           VARCHAR2_30_tbl_type ,
   EXEMPT_REASON                       VARCHAR2_240_tbl_type,
   CASH_DISCOUNT                       NUMBER_tbl_type      ,
   VOLUME_DISCOUNT                     NUMBER_tbl_type      ,
   TRADING_DISCOUNT                    NUMBER_tbl_type      ,
   TRANSFER_CHARGE                     NUMBER_tbl_type      ,
   TRANSPORTATION_CHARGE               NUMBER_tbl_type      ,
   INSURANCE_CHARGE                    NUMBER_tbl_type      ,
   OTHER_CHARGE                        NUMBER_tbl_type      ,
   PRODUCT_ID                          NUMBER_tbl_type      ,
   PRODUCT_FISC_CLASSIFICATION         VARCHAR2_240_tbl_type ,
   PRODUCT_ORG_ID                      NUMBER_tbl_type      ,
   UOM_CODE                            VARCHAR2_30_tbl_type ,
   PRODUCT_TYPE                        VARCHAR2_30_tbl_type ,
   PRODUCT_CODE                        VARCHAR2_30_tbl_type ,
   PRODUCT_CATEGORY                    VARCHAR2_240_tbl_type ,
   TRX_SIC_CODE                        VARCHAR2_150_tbl_type,
   FOB_POINT                           VARCHAR2_30_tbl_type ,
   SHIP_TO_PARTY_ID                    NUMBER_tbl_type      ,
   SHIP_FROM_PARTY_ID                  NUMBER_tbl_type      ,
   POA_PARTY_ID                        NUMBER_tbl_type      ,
   POO_PARTY_ID                        NUMBER_tbl_type      ,
   BILL_TO_PARTY_ID                    NUMBER_tbl_type      ,
   BILL_FROM_PARTY_ID                  NUMBER_tbl_type      ,
   MERCHANT_PARTY_ID                   NUMBER_tbl_type      ,
   SHIP_TO_PARTY_SITE_ID               NUMBER_tbl_type      ,
   SHIP_FROM_PARTY_SITE_ID             NUMBER_tbl_type      ,
   POA_PARTY_SITE_ID                   NUMBER_tbl_type      ,
   POO_PARTY_SITE_ID                   NUMBER_tbl_type      ,
   BILL_TO_PARTY_SITE_ID               NUMBER_tbl_type      ,
   BILL_FROM_PARTY_SITE_ID             NUMBER_tbl_type      ,
   SHIP_TO_LOCATION_ID                 NUMBER_tbl_type      ,
   SHIP_FROM_LOCATION_ID               NUMBER_tbl_type      ,
   POA_LOCATION_ID                     NUMBER_tbl_type      ,
   POO_LOCATION_ID                     NUMBER_tbl_type      ,
   BILL_TO_LOCATION_ID                 NUMBER_tbl_type      ,
   BILL_FROM_LOCATION_ID               NUMBER_tbl_type      ,
   ACCOUNT_CCID                        NUMBER_tbl_type      ,
   ACCOUNT_STRING                      VARCHAR2_2000_tbl_type,
   MERCHANT_PARTY_COUNTRY              VARCHAR2_150_tbl_type,
   REF_DOC_APPLICATION_ID              NUMBER_tbl_type      ,
   REF_DOC_ENTITY_CODE                 VARCHAR2_30_tbl_type ,
   REF_DOC_EVENT_CLASS_CODE            VARCHAR2_30_tbl_type ,
   REF_DOC_TRX_ID                      NUMBER_tbl_type      ,
   REF_DOC_HDR_TRX_USER_KEY1           VARCHAR2_150_tbl_type,
   REF_DOC_HDR_TRX_USER_KEY2           VARCHAR2_150_tbl_type,
   REF_DOC_HDR_TRX_USER_KEY3           VARCHAR2_150_tbl_type,
   REF_DOC_HDR_TRX_USER_KEY4           VARCHAR2_150_tbl_type,
   REF_DOC_HDR_TRX_USER_KEY5           VARCHAR2_150_tbl_type,
   REF_DOC_HDR_TRX_USER_KEY6           VARCHAR2_150_tbl_type,
   REF_DOC_LINE_ID                     NUMBER_tbl_type      ,
   REF_DOC_LIN_TRX_USER_KEY1           VARCHAR2_150_tbl_type,
   REF_DOC_LIN_TRX_USER_KEY2           VARCHAR2_150_tbl_type,
   REF_DOC_LIN_TRX_USER_KEY3           VARCHAR2_150_tbl_type,
   REF_DOC_LIN_TRX_USER_KEY4           VARCHAR2_150_tbl_type,
   REF_DOC_LIN_TRX_USER_KEY5           VARCHAR2_150_tbl_type,
   REF_DOC_LIN_TRX_USER_KEY6           VARCHAR2_150_tbl_type,
   REF_DOC_LINE_QUANTITY               NUMBER_tbl_type      ,
   APPLIED_FROM_APPLICATION_ID         NUMBER_tbl_type      ,
   APPLIED_FROM_ENTITY_CODE            VARCHAR2_30_tbl_type ,
   APPLIED_FROM_EVENT_CLASS_CODE       VARCHAR2_30_tbl_type ,
   APPLIED_FROM_TRX_ID                 NUMBER_tbl_type      ,
   APP_FROM_HDR_TRX_USER_KEY1          VARCHAR2_150_tbl_type,
   APP_FROM_HDR_TRX_USER_KEY2          VARCHAR2_150_tbl_type,
   APP_FROM_HDR_TRX_USER_KEY3          VARCHAR2_150_tbl_type,
   APP_FROM_HDR_TRX_USER_KEY4          VARCHAR2_150_tbl_type,
   APP_FROM_HDR_TRX_USER_KEY5          VARCHAR2_150_tbl_type,
   APP_FROM_HDR_TRX_USER_KEY6          VARCHAR2_150_tbl_type,
   APPLIED_FROM_LINE_ID                NUMBER_tbl_type      ,
   APP_FROM_LIN_TRX_USER_KEY1          VARCHAR2_150_tbl_type,
   APP_FROM_LIN_TRX_USER_KEY2          VARCHAR2_150_tbl_type,
   APP_FROM_LIN_TRX_USER_KEY3          VARCHAR2_150_tbl_type,
   APP_FROM_LIN_TRX_USER_KEY4          VARCHAR2_150_tbl_type,
   APP_FROM_LIN_TRX_USER_KEY5          VARCHAR2_150_tbl_type,
   APP_FROM_LIN_TRX_USER_KEY6          VARCHAR2_150_tbl_type,
   ADJUSTED_DOC_APPLICATION_ID         NUMBER_tbl_type      ,
   ADJUSTED_DOC_ENTITY_CODE            VARCHAR2_30_tbl_type ,
   ADJUSTED_DOC_EVENT_CLASS_CODE       VARCHAR2_30_tbl_type ,
   ADJUSTED_DOC_TRX_ID                 NUMBER_tbl_type      ,
   ADJ_DOC_HDR_TRX_USER_KEY1           VARCHAR2_150_tbl_type,
   ADJ_DOC_HDR_TRX_USER_KEY2           VARCHAR2_150_tbl_type,
   ADJ_DOC_HDR_TRX_USER_KEY3           VARCHAR2_150_tbl_type,
   ADJ_DOC_HDR_TRX_USER_KEY4           VARCHAR2_150_tbl_type,
   ADJ_DOC_HDR_TRX_USER_KEY5           VARCHAR2_150_tbl_type,
   ADJ_DOC_HDR_TRX_USER_KEY6           VARCHAR2_150_tbl_type,
   ADJUSTED_DOC_LINE_ID                NUMBER_tbl_type      ,
   ADJ_DOC_LIN_TRX_USER_KEY1           VARCHAR2_150_tbl_type,
   ADJ_DOC_LIN_TRX_USER_KEY2           VARCHAR2_150_tbl_type,
   ADJ_DOC_LIN_TRX_USER_KEY3           VARCHAR2_150_tbl_type,
   ADJ_DOC_LIN_TRX_USER_KEY4           VARCHAR2_150_tbl_type,
   ADJ_DOC_LIN_TRX_USER_KEY5           VARCHAR2_150_tbl_type,
   ADJ_DOC_LIN_TRX_USER_KEY6           VARCHAR2_150_tbl_type,
   ADJUSTED_DOC_NUMBER                 VARCHAR2_150_tbl_type,
   ADJUSTED_DOC_DATE                   DATE_tbl_type        ,
   APPLIED_TO_APPLICATION_ID           NUMBER_tbl_type      ,
   APPLIED_TO_ENTITY_CODE              VARCHAR2_30_tbl_type ,
   APPLIED_TO_EVENT_CLASS_CODE         VARCHAR2_30_tbl_type ,
   APPLIED_TO_TRX_ID                   NUMBER_tbl_type      ,
   APP_TO_HDR_TRX_USER_KEY1            VARCHAR2_150_tbl_type,
   APP_TO_HDR_TRX_USER_KEY2            VARCHAR2_150_tbl_type,
   APP_TO_HDR_TRX_USER_KEY3            VARCHAR2_150_tbl_type,
   APP_TO_HDR_TRX_USER_KEY4            VARCHAR2_150_tbl_type,
   APP_TO_HDR_TRX_USER_KEY5            VARCHAR2_150_tbl_type,
   APP_TO_HDR_TRX_USER_KEY6            VARCHAR2_150_tbl_type,
   APPLIED_TO_TRX_LINE_ID              NUMBER_tbl_type      ,
   APP_TO_LIN_TRX_USER_KEY1            VARCHAR2_150_tbl_type,
   APP_TO_LIN_TRX_USER_KEY2            VARCHAR2_150_tbl_type,
   APP_TO_LIN_TRX_USER_KEY3            VARCHAR2_150_tbl_type,
   APP_TO_LIN_TRX_USER_KEY4            VARCHAR2_150_tbl_type,
   APP_TO_LIN_TRX_USER_KEY5            VARCHAR2_150_tbl_type,
   APP_TO_LIN_TRX_USER_KEY6            VARCHAR2_150_tbl_type,
   TRX_ID_LEVEL2                       NUMBER_tbl_type      ,
   TRX_ID_LEVEL3                       NUMBER_tbl_type      ,
   TRX_ID_LEVEL4                       NUMBER_tbl_type      ,
   TRX_ID_LEVEL5                       NUMBER_tbl_type      ,
   TRX_ID_LEVEL6                       NUMBER_tbl_type      ,
   HDR_TRX_USER_KEY1                   VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY2                   VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY3                   VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY4                   VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY5                   VARCHAR2_150_tbl_type,
   HDR_TRX_USER_KEY6                   VARCHAR2_150_tbl_type,
   LINE_TRX_USER_KEY1                  VARCHAR2_150_tbl_type,
   LINE_TRX_USER_KEY2                  VARCHAR2_150_tbl_type,
   LINE_TRX_USER_KEY3                  VARCHAR2_150_tbl_type,
   LINE_TRX_USER_KEY4                  VARCHAR2_150_tbl_type,
   LINE_TRX_USER_KEY5                  VARCHAR2_150_tbl_type,
   LINE_TRX_USER_KEY6                  VARCHAR2_150_tbl_type,
   TRX_LINE_NUMBER                     NUMBER_tbl_type      ,
   TRX_LINE_DESCRIPTION                VARCHAR2_240_tbl_type,
   PRODUCT_DESCRIPTION                 VARCHAR2_240_tbl_type,
   TRX_WAYBILL_NUMBER                  VARCHAR2_50_tbl_type ,
   TRX_LINE_GL_DATE                    DATE_tbl_type        ,
   MERCHANT_PARTY_NAME                 VARCHAR2_150_tbl_type,
   MERCHANT_PARTY_DOCUMENT_NUMBER      VARCHAR2_150_tbl_type,
   MERCHANT_PARTY_REFERENCE            VARCHAR2_250_tbl_type,
   MERCHANT_PARTY_TAXPAYER_ID          VARCHAR2_150_tbl_type,
   MERCHANT_PARTY_TAX_REG_NUMBER       VARCHAR2_150_tbl_type,
   PAYING_PARTY_ID                     NUMBER_tbl_type      ,
   OWN_HQ_PARTY_ID                     NUMBER_tbl_type      ,
   TRADING_HQ_PARTY_ID                 NUMBER_tbl_type      ,
   POI_PARTY_ID                        NUMBER_tbl_type      ,
   POD_PARTY_ID                        NUMBER_tbl_type      ,
   TITLE_TRANSFER_PARTY_ID             NUMBER_tbl_type      ,
   PAYING_PARTY_SITE_ID                NUMBER_tbl_type      ,
   OWN_HQ_PARTY_SITE_ID                NUMBER_tbl_type      ,
   TRADING_HQ_PARTY_SITE_ID            NUMBER_tbl_type      ,
   POI_PARTY_SITE_ID                   NUMBER_tbl_type      ,
   POD_PARTY_SITE_ID                   NUMBER_tbl_type      ,
   TITLE_TRANSFER_PARTY_SITE_ID        NUMBER_tbl_type      ,
   PAYING_LOCATION_ID                  NUMBER_tbl_type      ,
   OWN_HQ_LOCATION_ID                  NUMBER_tbl_type      ,
   TRADING_HQ_LOCATION_ID              NUMBER_tbl_type      ,
   POC_LOCATION_ID                     NUMBER_tbl_type      ,
   POI_LOCATION_ID                     NUMBER_tbl_type      ,
   POD_LOCATION_ID                     NUMBER_tbl_type      ,
   TITLE_TRANSFER_LOCATION_ID          NUMBER_tbl_type      ,
   ASSESSABLE_VALUE                    NUMBER_tbl_type      ,
   ASSET_FLAG                          VARCHAR2_1_tbl_type  ,
   ASSET_NUMBER                        VARCHAR2_150_tbl_type,
   ASSET_ACCUM_DEPRECIATION            NUMBER_tbl_type      ,
   ASSET_TYPE                          VARCHAR2_150_tbl_type,
   ASSET_COST                          NUMBER_tbl_type      ,
   NUMERIC1                            NUMBER_tbl_type      ,
   NUMERIC2                            NUMBER_tbl_type      ,
   NUMERIC3                            NUMBER_tbl_type      ,
   NUMERIC4                            NUMBER_tbl_type      ,
   NUMERIC5                            NUMBER_tbl_type      ,
   NUMERIC6                            NUMBER_tbl_type      ,
   NUMERIC7                            NUMBER_tbl_type      ,
   NUMERIC8                            NUMBER_tbl_type      ,
   NUMERIC9                            NUMBER_tbl_type      ,
   NUMERIC10                           NUMBER_tbl_type      ,
   CHAR1                               VARCHAR2_150_tbl_type,
   CHAR2                               VARCHAR2_150_tbl_type,
   CHAR3                               VARCHAR2_150_tbl_type,
   CHAR4                               VARCHAR2_150_tbl_type,
   CHAR5                               VARCHAR2_150_tbl_type,
   CHAR6                               VARCHAR2_150_tbl_type,
   CHAR7                               VARCHAR2_150_tbl_type,
   CHAR8                               VARCHAR2_150_tbl_type,
   CHAR9                               VARCHAR2_150_tbl_type,
   CHAR10                              VARCHAR2_150_tbl_type,
   DATE1                               DATE_tbl_type        ,
   DATE2                               DATE_tbl_type        ,
   DATE3                               DATE_tbl_type        ,
   DATE4                               DATE_tbl_type        ,
   DATE5                               DATE_tbl_type        ,
   DATE6                               DATE_tbl_type        ,
   DATE7                               DATE_tbl_type        ,
   DATE8                               DATE_tbl_type        ,
   DATE9                               DATE_tbl_type        ,
   DATE10                              DATE_tbl_type        ,
   SHIP_TO_PARTY_TAX_PROF_ID           NUMBER_tbl_type      ,
   SHIP_FROM_PARTY_TAX_PROF_ID         NUMBER_tbl_type      ,
   POA_PARTY_TAX_PROF_ID               NUMBER_tbl_type      ,
   POO_PARTY_TAX_PROF_ID               NUMBER_tbl_type      ,
   PAYING_PARTY_TAX_PROF_ID            NUMBER_tbl_type      ,
   OWN_HQ_PARTY_TAX_PROF_ID            NUMBER_tbl_type      ,
   TRADING_HQ_PARTY_TAX_PROF_ID        NUMBER_tbl_type      ,
   POI_PARTY_TAX_PROF_ID               NUMBER_tbl_type      ,
   POD_PARTY_TAX_PROF_ID               NUMBER_tbl_type      ,
   BILL_TO_PARTY_TAX_PROF_ID           NUMBER_tbl_type      ,
   BILL_FROM_PARTY_TAX_PROF_ID         NUMBER_tbl_type      ,
   TITLE_TRANS_PARTY_TAX_PROF_ID       NUMBER_tbl_type      ,
   SHIP_TO_SITE_TAX_PROF_ID            NUMBER_tbl_type      ,
   SHIP_FROM_SITE_TAX_PROF_ID          NUMBER_tbl_type      ,
   POA_SITE_TAX_PROF_ID                NUMBER_tbl_type      ,
   POO_SITE_TAX_PROF_ID                NUMBER_tbl_type      ,
   PAYING_SITE_TAX_PROF_ID             NUMBER_tbl_type      ,
   OWN_HQ_SITE_TAX_PROF_ID             NUMBER_tbl_type      ,
   TRADING_HQ_SITE_TAX_PROF_ID         NUMBER_tbl_type      ,
   POI_SITE_TAX_PROF_ID                NUMBER_tbl_type      ,
   POD_SITE_TAX_PROF_ID                NUMBER_tbl_type      ,
   BILL_TO_SITE_TAX_PROF_ID            NUMBER_tbl_type      ,
   BILL_FROM_SITE_TAX_PROF_ID          NUMBER_tbl_type      ,
   TITLE_TRANS_SITE_TAX_PROF_ID        NUMBER_tbl_type      ,
   MERCHANT_PARTY_TAX_PROF_ID          NUMBER_tbl_type      ,
   LINE_AMT_INCLUDES_TAX_FLAG          VARCHAR2_1_tbl_type  ,
   HISTORICAL_FLAG                     VARCHAR2_1_tbl_type  ,
   TAX_CLASSIFICATION_CODE             VARCHAR2_80_tbl_type ,
   CTRL_HDR_TX_APPL_FLAG               VARCHAR2_1_tbl_type  ,
   CTRL_TOTAL_LINE_TX_AMT              NUMBER_tbl_type);

TYPE zx_dist_lines_rec_tbl_type IS RECORD(
   APPLICATION_ID                      NUMBER_tbl_type       ,
   ENTITY_CODE                         VARCHAR2_30_tbl_type  ,
   EVENT_CLASS_CODE                    VARCHAR2_30_tbl_type  ,
   EVENT_TYPE_CODE                     VARCHAR2_30_tbl_type  ,
   TRX_ID                              NUMBER_tbl_type       ,
   HDR_TRX_USER_KEY1                   VARCHAR2_150_tbl_type ,
   HDR_TRX_USER_KEY2                   VARCHAR2_150_tbl_type ,
   HDR_TRX_USER_KEY3                   VARCHAR2_150_tbl_type ,
   HDR_TRX_USER_KEY4                   VARCHAR2_150_tbl_type ,
   HDR_TRX_USER_KEY5                   VARCHAR2_150_tbl_type ,
   HDR_TRX_USER_KEY6                   VARCHAR2_150_tbl_type ,
   TRX_LINE_ID                         NUMBER_tbl_type       ,
   LINE_TRX_USER_KEY1                  VARCHAR2_150_tbl_type ,
   LINE_TRX_USER_KEY2                  VARCHAR2_150_tbl_type ,
   LINE_TRX_USER_KEY3                  VARCHAR2_150_tbl_type ,
   LINE_TRX_USER_KEY4                  VARCHAR2_150_tbl_type ,
   LINE_TRX_USER_KEY5                  VARCHAR2_150_tbl_type ,
   LINE_TRX_USER_KEY6                  VARCHAR2_150_tbl_type ,
   TRX_LEVEL_TYPE                      VARCHAR2_30_tbl_type  ,
   TRX_LINE_DIST_ID                    NUMBER_tbl_type       ,
   DIST_TRX_USER_KEY1                  VARCHAR2_150_tbl_type ,
   DIST_TRX_USER_KEY2                  VARCHAR2_150_tbl_type ,
   DIST_TRX_USER_KEY3                  VARCHAR2_150_tbl_type ,
   DIST_TRX_USER_KEY4                  VARCHAR2_150_tbl_type ,
   DIST_TRX_USER_KEY5                  VARCHAR2_150_tbl_type ,
   DIST_TRX_USER_KEY6                  VARCHAR2_150_tbl_type ,
   DIST_LEVEL_ACTION                   VARCHAR2_30_tbl_type  ,
   TRX_LINE_DIST_DATE                  DATE_tbl_type         ,
   ITEM_DIST_NUMBER                    NUMBER_tbl_type       ,
   DIST_INTENDED_USE                   VARCHAR2_240_tbl_type  ,
   TAX_INCLUSION_FLAG                  VARCHAR2_1_tbl_type   ,
   TAX_CODE                            VARCHAR2_30_tbl_type  ,
   TASK_ID                             NUMBER_tbl_type       ,
   AWARD_ID                            NUMBER_tbl_type       ,
   PROJECT_ID                          NUMBER_tbl_type       ,
   EXPENDITURE_TYPE                    VARCHAR2_30_tbl_type  ,
   EXPENDITURE_ORGANIZATION_ID         NUMBER_tbl_type       ,
   EXPENDITURE_ITEM_DATE               DATE_tbl_type         ,
   TRX_LINE_DIST_AMT                   NUMBER_tbl_type       ,
   TRX_LINE_DIST_QUANTITY              NUMBER_tbl_type       ,
   TRX_LINE_QUANTITY                   NUMBER_tbl_type       ,
   ACCOUNT_CCID                        NUMBER_tbl_type       ,
   ACCOUNT_STRING                      VARCHAR2_2000_tbl_type,
   REF_DOC_APPLICATION_ID              NUMBER_tbl_type    ,
   REF_DOC_ENTITY_CODE                 VARCHAR2_30_tbl_type  ,
   REF_DOC_EVENT_CLASS_CODE            VARCHAR2_30_tbl_type  ,
   REF_DOC_TRX_ID                      NUMBER_tbl_type    ,
   REF_DOC_HDR_TRX_USER_KEY1           VARCHAR2_150_tbl_type ,
   REF_DOC_HDR_TRX_USER_KEY2           VARCHAR2_150_tbl_type ,
   REF_DOC_HDR_TRX_USER_KEY3           VARCHAR2_150_tbl_type ,
   REF_DOC_HDR_TRX_USER_KEY4           VARCHAR2_150_tbl_type ,
   REF_DOC_HDR_TRX_USER_KEY5           VARCHAR2_150_tbl_type ,
   REF_DOC_HDR_TRX_USER_KEY6           VARCHAR2_150_tbl_type ,
   REF_DOC_LINE_ID                     NUMBER_tbl_type    ,
   REF_DOC_LIN_TRX_USER_KEY1           VARCHAR2_150_tbl_type ,
   REF_DOC_LIN_TRX_USER_KEY2           VARCHAR2_150_tbl_type ,
   REF_DOC_LIN_TRX_USER_KEY3           VARCHAR2_150_tbl_type ,
   REF_DOC_LIN_TRX_USER_KEY4           VARCHAR2_150_tbl_type ,
   REF_DOC_LIN_TRX_USER_KEY5           VARCHAR2_150_tbl_type ,
   REF_DOC_LIN_TRX_USER_KEY6           VARCHAR2_150_tbl_type ,
   REF_DOC_DIST_ID                     NUMBER_tbl_type    ,
   REF_DOC_DIST_TRX_USER_KEY1          VARCHAR2_150_tbl_type ,
   REF_DOC_DIST_TRX_USER_KEY2          VARCHAR2_150_tbl_type ,
   REF_DOC_DIST_TRX_USER_KEY3          VARCHAR2_150_tbl_type ,
   REF_DOC_DIST_TRX_USER_KEY4          VARCHAR2_150_tbl_type ,
   REF_DOC_DIST_TRX_USER_KEY5          VARCHAR2_150_tbl_type ,
   REF_DOC_DIST_TRX_USER_KEY6          VARCHAR2_150_tbl_type ,
   REF_DOC_CURR_CONV_RATE              NUMBER_tbl_type    ,
   NUMERIC1                            NUMBER_tbl_type    ,
   NUMERIC2                            NUMBER_tbl_type    ,
   NUMERIC3                            NUMBER_tbl_type    ,
   NUMERIC4                            NUMBER_tbl_type    ,
   NUMERIC5                            NUMBER_tbl_type    ,
   CHAR1                               VARCHAR2_150_tbl_type ,
   CHAR2                               VARCHAR2_150_tbl_type ,
   CHAR3                               VARCHAR2_150_tbl_type ,
   CHAR4                               VARCHAR2_150_tbl_type ,
   CHAR5                               VARCHAR2_150_tbl_type ,
   DATE1                               DATE_tbl_type      ,
   DATE2                               DATE_tbl_type      ,
   DATE3                               DATE_tbl_type      ,
   DATE4                               DATE_tbl_type      ,
   DATE5                               DATE_tbl_type      ,
   TRX_LINE_DIST_TAX_AMT               NUMBER_tbl_type    ,
   HISTORICAL_FLAG                     VARCHAR2_1_tbl_type);


/* ======================================================================*
 | Global Variables                                                      |
 * ======================================================================*/

  g_clean_up_flag            VARCHAR2(1);
  g_log_destination          VARCHAR2(30); --SPOOL,LOGFILE,LOGV
  g_trx_date                 DATE;
  g_adj_doc_date             DATE;
  g_rel_doc_date             DATE;
  g_line_max_size            BINARY_INTEGER;
  g_file                     UTL_FILE.FILE_TYPE;
  g_initial_file_reading_flag VARCHAR2(1);
  g_line_buffer              LONG;
  g_next_line_buffer         LONG;
  g_next_line_return_status  VARCHAR2(2000);
  g_separator                VARCHAR2(1);
  g_start_string             NUMBER;
  g_end_string               NUMBER;
  g_counter                  NUMBER;
  g_position_last_separator  NUMBER;
  g_last_portion_prev_string VARCHAR2(2000);
  g_string_segment           VARCHAR2(2000);
  g_line_segment_string      VARCHAR2(2000);
  g_retrieve_another_segment VARCHAR2(1);
  g_line_segment_counter     NUMBER;
  g_element_in_segment_count NUMBER;
  g_file_curr_line_counter   NUMBER;
  g_current_datafile_section VARCHAR2(80); --Values, INPUT_DATA,OUTPUT_DATA.
  g_api_version              NUMBER;
  g_log_variable             LONG; -- Used to store the log.
  g_header_cache_counter     NUMBER;
  g_line_cache_counter       NUMBER;
  g_dist_cache_counter       NUMBER;


  ----------------------------------
  -- Global Variables of Record Type
  ----------------------------------
  g_party_rec                party_rec_type;
  g_transaction_rec          zx_api_pub.transaction_rec_type;
  g_transaction_line_rec     zx_api_pub.transaction_line_rec_type;
  g_sync_trx_rec             zx_api_pub.sync_trx_rec_type;

  -------------------------------------------------
  -- Global Variables of Table Type
  -------------------------------------------------
  g_surr_trx_id_tbl           surr_trx_id_type_tbl_type;
  g_surr_trx_line_id_tbl      surr_trx_line_id_tbl_type;
  g_surr_trx_dist_id_tbl      surr_trx_dist_id_tbl_type;
  g_suite_rec_tbl             suite_rec_tbl_type;
  g_trx_headers_cache_rec_tbl zx_trx_headers_rec_tbl_type;
  g_trx_lines_cache_rec_tbl   zx_trx_lines_rec_tbl_type;
  g_dist_lines_cache_rec_tbl  zx_dist_lines_rec_tbl_type;
  g_sync_trx_lines_tbl        zx_api_pub.sync_trx_lines_tbl_type%type;


/* =======================================================================*
 | PROCEDURE write_message:  Write output depending of the value given in |
 |                           g_log_destination                            |
 * =======================================================================*/
  PROCEDURE write_message(p_message IN VARCHAR2);

/*===========================================================================*
 | PROCEDURE get_log: Retrieves the log stored in global_variable         |
 *============================================================================*/
  PROCEDURE get_log ( x_log OUT NOCOPY LONG );


/* ======================================================================*
 | PROCEDURE Initialize_file : Open the file for reading.                |
 * ======================================================================*/
  PROCEDURE initialize_file
    (
      p_file_dir             IN  VARCHAR2,
      p_file_name            IN  VARCHAR2,
      x_return_status        OUT NOCOPY VARCHAR2
	);

/* ======================================================================*
 | PROCEDURE close_file : Close the current file for reading.            |
 * ======================================================================*/
  PROCEDURE close_file
    (
	   x_return_status       OUT NOCOPY VARCHAR2
	);

/* ============================================================================*
 | PROCEDURE retrieve_another_segment:Retrieve next segment(1000 chrs)from line|
 * ===========================================================================*/
  PROCEDURE retrieve_another_segment
    (
      x_return_status        OUT NOCOPY VARCHAR2
	);

/* ======================================================================*
 | PROCEDURE read_line : Reads a line from the file and puts it on buffer|
 * ======================================================================*/
  PROCEDURE read_line
    (
      x_line_suite               OUT NOCOPY VARCHAR2,
      x_line_case                OUT NOCOPY VARCHAR2,
      x_line_api                 OUT NOCOPY VARCHAR2,
      x_line_task                OUT NOCOPY VARCHAR2,
      x_line_structure           OUT NOCOPY VARCHAR2,
      x_line_counter             OUT NOCOPY NUMBER,
      x_line_is_end_of_case      OUT NOCOPY VARCHAR2,
      x_current_datafile_section OUT NOCOPY VARCHAR2,
	  x_return_status            OUT NOCOPY VARCHAR2
    ) ;

/* ============================================================================*
 | PROCEDURE get_next_element_in_row : From the line in buffer retrieves next  |
 |                                     element                                 |
 * ===========================================================================*/
  PROCEDURE get_next_element_in_row
    (
      x_element               OUT NOCOPY VARCHAR2 ,
      x_return_status         OUT NOCOPY VARCHAR2
    ) ;

/* ============================================================================*
 | PROCEDURE surrogate_key: Populate the surrogate keys                        |
 * ===========================================================================*/
  PROCEDURE surrogate_key
    (
      p_surrogate_key         IN VARCHAR2,
      x_real_value            OUT NOCOPY NUMBER,
      p_type                  IN VARCHAR2
    );

/* ============================================================================*
 | PROCEDURE check_surrogate_key   : Checks the existence of surrogate key     |
 * ===========================================================================*/
  PROCEDURE check_surrogate_key
    (
      p_key                   IN VARCHAR2,
      x_value                 OUT NOCOPY NUMBER,
      p_type                  IN VARCHAR2
    );

/* ============================================================================*
 | PROCEDURE break_user_key_into_segments:Break in segments string for UserKeys|
 * ===========================================================================*/
  PROCEDURE break_user_key_into_segments
    (
      p_string               IN VARCHAR2,
      p_separator            IN VARCHAR2,
      x_number_of_segments   OUT NOCOPY NUMBER,
      x_user_key_tbl         OUT NOCOPY user_keys_segments_tbl_type
    ) ;

/* ===========================================================================*
 | PROCEDURE get_user_key_id: Retrieve the ID for the User Keys               |
 * ===========================================================================*/
  PROCEDURE get_user_key_id
    (
      p_user_key_string IN VARCHAR2,
      p_user_key_type   IN VARCHAR2,
      x_user_key_id     OUT NOCOPY NUMBER
    ) ;

/* ======================================================================*
 | PROCEDURE put_data_in_party_rec : Put party_rec data in the a record  |
 * ======================================================================*/
  PROCEDURE put_data_in_party_rec
    (
      p_header_row IN NUMBER
    );


/* ============================================================================*
 | PROCEDURE insert_data_trx_headers_gt:Inserts row in ZX_TRANSACTION_HEADERS_GT
 * ===========================================================================*/
  PROCEDURE insert_data_trx_headers_gt
    (
      p_row_id IN NUMBER
    );

/* ============================================================================*
 | PROCEDURE insert_data_trx_lines_gt :Inserts a row in ZX_TRANSACTION_LINES_GT|
 * ===========================================================================*/
  PROCEDURE insert_data_trx_lines_gt
    (
      p_header_row        IN NUMBER,
      p_starting_line_row IN NUMBER,
      p_ending_line_row   IN NUMBER
    );

/* ============================================================================*
 | PROCEDURE insert_data_mrc_gt :Inserts a row in ZX_MRC_GT                   |
 * ===========================================================================*/
  PROCEDURE insert_data_mrc_gt
    (
      p_header_row        IN NUMBER
    );


/* ============================================================================*
 | PROCEDURE insert_transaction_rec : Populate the row in transaction_rec      |
 * ===========================================================================*/
  PROCEDURE insert_transaction_rec
    (
      p_transaction_rec IN OUT NOCOPY zx_api_pub.transaction_rec_type
    );

 /* ============================================================================*
 | PROCEDURE insert_row_transaction_rec : Populate the row in transaction_rec   |
 * ============================================================================*/

  PROCEDURE insert_row_transaction_rec (
              p_transaction_rec IN OUT NOCOPY zx_api_pub.transaction_rec_type,
              p_initial_row     IN NUMBER
              );


/* ============================================================================*
 | PROCEDURE insert_import_sum_tax_lines_gt:Populate the row in transaction_rec|
 * ===========================================================================*/
  PROCEDURE insert_import_sum_tax_lines_gt
      (
      p_starting_row_tax_lines IN NUMBER,
      p_ending_row_tax_lines   IN NUMBER
      );

/* ====================================================================*
 | PROCEDURE insert_trx_tax_link_gt:Insert a row in ZX_TRX_TAX_LINK_GT |
 * ====================================================================*/
  PROCEDURE insert_trx_tax_link_gt
      (
      p_sta_row_imp_tax_link IN NUMBER,
      p_end_row_imp_tax_link   IN NUMBER
      );


/* ===========================================================================*
 | PROCEDURE insert_reverse_trx_lines_gt:Insert row in ZX_REVERSE_TRX_LINES_GT|
 * ===========================================================================*/
  PROCEDURE insert_reverse_trx_lines_gt;

/* ============================================================================*
 | PROCEDURE insert_reverse_dist_lines_gt:Insert row in ZX_REVERSE_TRX_LINES_GT|
 * ===========================================================================*/
  PROCEDURE insert_reverse_dist_lines_gt;

/* ============================================================================*
 | PROCEDURE insert_itm_distributions_gt:Insert row in ZX_ITM_DISTRIBUTIONS_GT |
 * ===========================================================================*/
  PROCEDURE insert_itm_distributions_gt
      (
      p_header_row        IN NUMBER,
      p_sta_row_item_dist IN NUMBER,
      p_end_row_item_dist IN NUMBER
      );

/* ========================================================================*
 | PROCEDURE Insert rows into ZX_TAX_DIST_ID_GT from zx_rec_nrec_dist      |
 * ========================================================================*/
  PROCEDURE insert_rows_tax_dist_id_gt(p_trx_id IN NUMBER);


/* =========================================================================*
 | PROCEDURE insert_sync_trx_rec: Insert the row in the sync trx record     |
 * =========================================================================*/
  PROCEDURE insert_sync_trx_rec
    (
     p_header_row IN NUMBER,
     x_sync_trx_rec OUT NOCOPY zx_api_pub.sync_trx_rec_type
    );

/* =========================================================================*
 | PROCEDURE insert_sync_trx_lines_tbl:Insert a row in sync_trx_lines_tbl   |
 * =========================================================================*/
  PROCEDURE insert_sync_trx_lines_tbl
    (
     p_header_row                  IN NUMBER,
     p_starting_row_sync_trx_lines IN NUMBER,
     p_ending_row_sync_trx_lines   IN NUMBER,
     x_sync_trx_lines_tbl          OUT NOCOPY zx_api_pub.sync_trx_lines_tbl_type%type
    );


/* ===========================================================================*
 | PROCEDURE insert_transaction_line_rec: Populate the transaction_line_rec   |
 * ===========================================================================*/
  PROCEDURE insert_transaction_line_rec
    (
      p_transaction_line_rec IN OUT NOCOPY zx_api_pub.transaction_line_rec_type,
      p_row_trx_line         IN NUMBER
    );

/* ======================================================================*
 | PROCEDURE delete_table :     Initialize a row of record of tables     |
 |                                                                       |
 * ======================================================================*/
  PROCEDURE delete_table ;

/* ======================================================================*
 | PROCEDURE initialize_row :     Initialize a row of record of tables   |
 |                                                                       |
 * ======================================================================*/
  PROCEDURE Initialize_row
    (
      p_record_counter IN NUMBER
    );


/* ======================================================================*
 | PROCEDURE put_line_in_suite_rec_tbl : Read a line from flat file and  |
 |                                      puts it in a record variable     |
 * ======================================================================*/
  PROCEDURE put_line_in_suite_rec_tbl
    (
      x_suite_number   OUT NOCOPY VARCHAR2,
      x_case_number    OUT NOCOPY VARCHAR2,
      x_api_name       OUT NOCOPY VARCHAR2,
      x_api_service    OUT NOCOPY VARCHAR2,
      x_api_structure  OUT NOCOPY VARCHAR2,
      p_header_row     IN NUMBER,
      p_record_counter IN NUMBER
    );


/* ============================================================================*
 | PROCEDURE call_api : Logic to Call the APIs                                 |
 * ===========================================================================*/
  PROCEDURE call_api
    (
      p_api_service     IN VARCHAR,
      p_suite_number    IN VARCHAR,
      p_case_number     IN VARCHAR,
      p_transaction_id  IN NUMBER
    );

/* ============================================================================*
 | PROCEDURE insert_into_gts : Logic to Insert in the Global Temporary Tables  |
 * ===========================================================================*/
  PROCEDURE insert_into_gts
    (
      p_suite_number    IN VARCHAR2,
      p_case_number     IN VARCHAR2,
      p_service         IN VARCHAR2,
      p_structure       IN VARCHAR2,
      p_header_row_id   IN NUMBER,
      p_starting_row_id IN NUMBER,
      p_ending_row_id   IN NUMBER,
      p_prev_trx_id     IN NUMBER
    );


/* ======================================================================*
 | PROCEDURE Get_Tax_Event_Type : Get Tax Event Type                     |
 * ======================================================================*/
  FUNCTION Get_Tax_Event_Type
  (
    p_appln_id          IN NUMBER,
    p_entity_code       IN VARCHAR2,
    p_evnt_cls_code     IN VARCHAR2,
    p_evnt_typ_code     IN VARCHAR2
  ) RETURN VARCHAR2;


 /* ===================================================================*
  | FUNCTION  RETRIEVE_NTH_ELEMENT: Retrieves a element from a string  |
  * ===================================================================*/
 FUNCTION GET_NTH_ELEMENT
  (
    p_element_number   IN NUMBER,
    p_string           IN VARCHAR2,
    p_separator        IN VARCHAR2
  ) RETURN VARCHAR2;


/* =======================================================================*
 | PROCEDURE Populate_Report_Table : Populates the Report Table to display|
 |                                   the results of the Suite.            |
 * =======================================================================*/
  PROCEDURE Populate_Report_Table
   (
     p_suite             IN VARCHAR2,
     p_case              IN VARCHAR2,
     p_service           IN VARCHAR2,
     p_transaction_id    IN NUMBER,
     p_error_flag        IN VARCHAR2,
     p_error_message     IN VARCHAR2
   );

/* ===========================================================================*
 | PROCEDURE populate_trx_header_cache : Caches the Transaction Header Info   |
 |                                       from a row in g_suite_rec_tbl        |
 * ===========================================================================*/
  PROCEDURE populate_trx_header_cache
   (
     p_header_row_id IN NUMBER
   );

/* =======================================================================*
 | PROCEDURE populate_trx_lines_cache : Caches the Transaction Lines Info |
 |                                       from a row in g_suite_rec_tbl    |
 * =======================================================================*/
  PROCEDURE populate_trx_lines_cache
   (
    p_header_row_id IN NUMBER,
    p_line_row_id IN NUMBER
   );

/* ===========================================================================*
 | PROCEDURE populate_dist_lines_cache : Caches the Distribution Lines Info   |
 |                                       from a row in g_suite_rec_tbl        |
 * ===========================================================================*/
  PROCEDURE populate_dist_lines_cache
   (
    p_dist_row_id IN NUMBER
   );

/* ============================================================================*
 | PROCEDURE update_trx_header_cache : Update the Cache Transaction Header Info|
 |                                     from a row in g_suite_rec_tbl           |
 * ===========================================================================*/
  PROCEDURE update_trx_header_cache
   (
     p_header_row_id IN NUMBER
   );

/* =======================================================================*
 | PROCEDURE update_trx_lines_cache : Update the Cache Lines Info         |
 |                                    from a row in g_suite_rec_tbl       |
 * =======================================================================*/
  PROCEDURE update_trx_lines_cache
   (
    p_header_row_id IN NUMBER,
    p_line_row_id IN NUMBER
   );

/* =======================================================================*
 | PROCEDURE update_dist_lines_cache : Update the Cache Dist Lines Info   |
 |                                    from a row in g_suite_rec_tbl       |
 * =======================================================================*/
  PROCEDURE update_dist_lines_cache
   (
    p_dist_row_id IN NUMBER
   );

/* ============================================================================*
 | PROCEDURE merge_with_dist_lines_cache : Merges Dist Lines for current Case  |
 |                                         when RE-DISTRIBUTE. Merges the      |
 |                                         actual given lines plus the lines   |
 |                                         not given but existing in the cache |
 |                                         Lines taken from Cache will be      |
 |                                         marked as NO-ACTION.                |
 * ============================================================================*/

  PROCEDURE merge_with_dist_lines_cache
   (
    p_suite         IN VARCHAR2,
    p_case          IN VARCHAR2
   );

/* =========================================================================*
 | PROCEDURE insert_tax_dist_id_gt :Retrieves TAX_DIST_ID depending on      |
 |                                  what STRUCTURE is being passed when     |
 |                                  calling using service                   |
 |                                  FREEZE_DISTRIBUTIONS                    |
 |                                   The Structures are:                    |
 |                                      STRUCTURE_TAX_LINE_KEY              |
 |                                      STRUCTURE_ITEM_DISTRIBUTION_KEY     |
 |                                      STRUCTURE_TRANSACTION_LINE_KEY      |
 |                                  Also Pupulates ZX_TAX_DIST_ID_GT        |
 * =========================================================================*/
  PROCEDURE insert_tax_dist_id_gt
  (
    p_suite         IN VARCHAR2,
    p_case          IN VARCHAR2,
    p_structure     IN VARCHAR2
   );

/* ============================================================================*
 | PROCEDURE perform_data_caching : Calls all the procedures needed for Caching|
 |                                  depending on the Scenario Executed         |
 * ===========================================================================*/
  PROCEDURE perform_data_caching
    (
      p_suite_number    IN VARCHAR2,
      p_case_number     IN VARCHAR2,
      p_service         IN VARCHAR2,
      p_structure       IN VARCHAR2,
      p_header_row_id   IN NUMBER,
      p_starting_row_id IN NUMBER,
      p_ending_row_id   IN NUMBER,
      p_prev_trx_id     IN NUMBER
    );


/*============================================================================*
 | PROCEDURE get_start_end_rows_structure: Retrieves the initial and ending   |
 |                                    rows of a Structure in g_suite_rec_tbl  |
 *============================================================================*/
  PROCEDURE get_start_end_rows_structure
    (
      p_suite                IN VARCHAR2,
      p_case                 IN VARCHAR2,
      p_structure            IN VARCHAR2,
      x_start_row            OUT NOCOPY NUMBER,
      x_end_row              OUT NOCOPY NUMBER
    );


/*============================================================================*
 | PROCEDURE get_zx_errors_gt: Retrieves the errors stored in ZX_ERRORS_GT    |
 *============================================================================*/
  PROCEDURE get_zx_errors_gt
    (
      x_message            OUT NOCOPY VARCHAR2
    );



/*============================================================================*
 | MAIN PROCEDURE test_api : Main procedure to call the testing of eTax APIs  |
 *============================================================================*/
  PROCEDURE test_api
    (
      p_file            IN VARCHAR2,
      p_directory       IN VARCHAR2,
      x_log             OUT NOCOPY LONG
    );

END ZX_TEST_API;

 

/
