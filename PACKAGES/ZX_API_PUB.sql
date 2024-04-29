--------------------------------------------------------
--  DDL for Package ZX_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_API_PUB" AUTHID CURRENT_USER AS
/* $Header: zxifpubsrvcspubs.pls 120.135.12010000.3 2010/11/24 14:26:49 ssanka ship $ */

/* ======================================================================*
 | Global Variables                                                      |
 * ======================================================================*/

  G_PUB_SRVC            VARCHAR2(80);
  G_DATA_TRANSFER_MODE  VARCHAR2(30);
  G_EXTERNAL_API_CALL   VARCHAR2(1);
  G_PUB_CALLING_SRVC    VARCHAR2(80);

/* ======================================================================*
 | Data Type Definitions                                                 |
 * ======================================================================*/

TYPE NUMBER_tbl_type is TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

TYPE DATE_tbl_type is TABLE OF DATE
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_1_tbl_type is TABLE OF VARCHAR2(1)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_2_tbl_type is TABLE OF VARCHAR2(2)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_30_tbl_type is TABLE OF VARCHAR2(30)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_50_tbl_type is TABLE OF VARCHAR2(50)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_80_tbl_type is TABLE OF VARCHAR2(80)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_150_tbl_type is TABLE OF VARCHAR2(150)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_240_tbl_type is TABLE OF VARCHAR2(240)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_250_tbl_type is TABLE OF VARCHAR2(250)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_2000_tbl_type is TABLE OF VARCHAR2(2000)
INDEX BY BINARY_INTEGER;

TYPE transaction_line_rec_type IS RECORD
  (INTERNAL_ORGANIZATION_ID             NUMBER
  ,APPLICATION_ID                       NUMBER
  ,ENTITY_CODE                          VARCHAR2(30)
  ,EVENT_CLASS_CODE                     VARCHAR2(30)
  ,EVENT_TYPE_CODE                      VARCHAR2(30)
  ,TRX_ID                               NUMBER
  ,HDR_TRX_USER_KEY1                    VARCHAR2(150)
  ,HDR_TRX_USER_KEY2                    VARCHAR2(150)
  ,HDR_TRX_USER_KEY3                    VARCHAR2(150)
  ,HDR_TRX_USER_KEY4                    VARCHAR2(150)
  ,HDR_TRX_USER_KEY5                    VARCHAR2(150)
  ,HDR_TRX_USER_KEY6                    VARCHAR2(150)
  ,TRX_LEVEL_TYPE                       VARCHAR2(30)
  ,TRX_LINE_ID                          NUMBER
  ,LINE_TRX_USER_KEY1                   VARCHAR2(150)
  ,LINE_TRX_USER_KEY2                   VARCHAR2(150)
  ,LINE_TRX_USER_KEY3                   VARCHAR2(150)
  ,LINE_TRX_USER_KEY4                   VARCHAR2(150)
  ,LINE_TRX_USER_KEY5                   VARCHAR2(150)
  ,LINE_TRX_USER_KEY6                   VARCHAR2(150)
  ,FIRST_PTY_ORG_ID                     NUMBER(15)
  ,TAX_EVENT_CLASS_CODE                 VARCHAR2(30)
  ,TAX_EVENT_TYPE_CODE                  VARCHAR2(30)
  ,DOC_EVENT_STATUS                     VARCHAR2(30)
  );

TYPE transaction_rec_type IS RECORD
    (APPLICATION_ID                     NUMBER,
     ENTITY_CODE                        VARCHAR2(30),
     EVENT_CLASS_CODE                   VARCHAR2(30),
     EVENT_TYPE_CODE                    VARCHAR2(30),
     TRX_ID                             NUMBER,
     INTERNAL_ORGANIZATION_ID           NUMBER,
     HDR_TRX_USER_KEY1                  VARCHAR2(150),
     HDR_TRX_USER_KEY2                  VARCHAR2(150),
     HDR_TRX_USER_KEY3                  VARCHAR2(150),
     HDR_TRX_USER_KEY4                  VARCHAR2(150),
     HDR_TRX_USER_KEY5                  VARCHAR2(150),
     HDR_TRX_USER_KEY6                  VARCHAR2(150),
     FIRST_PTY_ORG_ID                   NUMBER(15),
     TAX_EVENT_CLASS_CODE               VARCHAR2(30),
     TAX_EVENT_TYPE_CODE                VARCHAR2(30),
     DOC_EVENT_STATUS                   VARCHAR2(30),
     APPLICATION_DOC_STATUS             VARCHAR2(30)
    );

TYPE transaction_header_rec_type IS RECORD
    (INTERNAL_ORGANIZATION_ID           NUMBER_tbl_type,
     LEGAL_ENTITY_ID                    NUMBER_tbl_type,
     LEDGER_ID                          NUMBER_tbl_type,
     APPLICATION_ID                     NUMBER_tbl_type,
     ENTITY_CODE                        VARCHAR2_30_tbl_type,
     EVENT_CLASS_CODE                   VARCHAR2_30_tbl_type,
     EVENT_TYPE_CODE                    VARCHAR2_30_tbl_type,
     CTRL_TOTAL_HDR_TX_AMT              VARCHAR2_30_tbl_type,
     TRX_ID                             NUMBER_tbl_type,
     HDR_TRX_USER_KEY1                  VARCHAR2_150_tbl_type,
     HDR_TRX_USER_KEY2                  VARCHAR2_150_tbl_type,
     HDR_TRX_USER_KEY3                  VARCHAR2_150_tbl_type,
     HDR_TRX_USER_KEY4                  VARCHAR2_150_tbl_type,
     HDR_TRX_USER_KEY5                  VARCHAR2_150_tbl_type,
     HDR_TRX_USER_KEY6                  VARCHAR2_150_tbl_type,
     TRX_DATE                           DATE_tbl_type,
     REL_DOC_DATE                       DATE_tbl_type,
     PROVNL_TAX_DETERMINATION_DATE      DATE_tbl_type,
     TRX_CURRENCY_CODE                  VARCHAR2_30_tbl_type,
     PRECISION                          NUMBER_tbl_type,
     CURRENCY_CONVERSION_TYPE           VARCHAR2_30_tbl_type,
     CURRENCY_CONVERSION_RATE           NUMBER_tbl_type,
     CURRENCY_CONVERSION_DATE           DATE_tbl_type,
     ROUNDING_SHIP_TO_PARTY_ID          NUMBER_tbl_type,
     ROUNDING_SHIP_FROM_PARTY_ID        NUMBER_tbl_type,
     ROUNDING_BILL_TO_PARTY_ID          NUMBER_tbl_type,
     ROUNDING_BILL_FROM_PARTY_ID        NUMBER_tbl_type,
     RNDG_SHIP_TO_PARTY_SITE_ID         NUMBER_tbl_type,
     RNDG_SHIP_FROM_PARTY_SITE_ID       NUMBER_tbl_type,
     RNDG_BILL_TO_PARTY_SITE_ID         NUMBER_tbl_type,
     RNDG_BILL_FROM_PARTY_SITE_ID       NUMBER_tbl_type,
     QUOTE_FLAG                         VARCHAR2_1_tbl_type,
     ESTABLISHMENT_ID                   NUMBER_tbl_type,
     ICX_SESSION_ID                     NUMBER_tbl_type
    );

TYPE event_class_rec_type IS RECORD
    (INTERNAL_ORGANIZATION_ID           NUMBER,
     LEGAL_ENTITY_ID                    NUMBER,
     LEDGER_ID                          NUMBER,
     FIRST_PTY_ORG_ID                   NUMBER(15),
     APPLICATION_ID                     NUMBER,
     CTRL_TOTAL_HDR_TX_AMT              NUMBER,
     CTRL_TOTAL_LINE_TX_AMT_FLG         VARCHAR2(1),
     ENTITY_CODE                        VARCHAR2(30),
     EVENT_CLASS_CODE                   VARCHAR2(30),
     EVENT_CLASS_MAPPING_ID             NUMBER,
     REFERENCE_APPLICATION_ID           NUMBER,
     EVENT_TYPE_CODE                    VARCHAR2(30),
     TRX_ID                             NUMBER,
     HDR_TRX_USER_KEY1                  VARCHAR2(150),
     HDR_TRX_USER_KEY2                  VARCHAR2(150),
     HDR_TRX_USER_KEY3                  VARCHAR2(150),
     HDR_TRX_USER_KEY4                  VARCHAR2(150),
     HDR_TRX_USER_KEY5                  VARCHAR2(150),
     HDR_TRX_USER_KEY6                  VARCHAR2(150),
     TRX_DATE                           DATE,
     REL_DOC_DATE                       DATE,
     PROVNL_TAX_DETERMINATION_DATE      DATE,
     TRX_CURRENCY_CODE                  VARCHAR2(30),
     CURRENCY_CONVERSION_TYPE           VARCHAR2(30),
     CURRENCY_CONVERSION_RATE           NUMBER,
     CURRENCY_CONVERSION_DATE           DATE,
     PRECISION                          NUMBER,
     ROUNDING_SHIP_TO_PARTY_ID          NUMBER,
     ROUNDING_SHIP_FROM_PARTY_ID        NUMBER,
     ROUNDING_BILL_TO_PARTY_ID          NUMBER,
     ROUNDING_BILL_FROM_PARTY_ID        NUMBER,
     RNDG_SHIP_TO_PARTY_SITE_ID         NUMBER,
     RNDG_SHIP_FROM_PARTY_SITE_ID       NUMBER,
     RNDG_BILL_TO_PARTY_SITE_ID         NUMBER,
     RNDG_BILL_FROM_PARTY_SITE_ID       NUMBER,
     TAX_EVENT_CLASS_CODE               VARCHAR2(30),
     TAX_EVENT_TYPE_CODE                VARCHAR2(30),
     DOC_STATUS_CODE                    VARCHAR2(30),
     DET_FACTOR_TEMPL_CODE	        VARCHAR2(30),
     DEFAULT_ROUNDING_LEVEL_CODE        VARCHAR2(30),
     ROUNDING_LEVEL_HIER_1_CODE	        VARCHAR2(30),
     ROUNDING_LEVEL_HIER_2_CODE	        VARCHAR2(30),
     ROUNDING_LEVEL_HIER_3_CODE	    	VARCHAR2(30),
     ROUNDING_LEVEL_HIER_4_CODE      	VARCHAR2(30),
     RDNG_SHIP_TO_PTY_TX_PROF_ID        NUMBER,
     RDNG_SHIP_FROM_PTY_TX_PROF_ID      NUMBER,
     RDNG_BILL_TO_PTY_TX_PROF_ID        NUMBER,
     RDNG_BILL_FROM_PTY_TX_PROF_ID      NUMBER,
     RDNG_SHIP_TO_PTY_TX_P_ST_ID        NUMBER,
     RDNG_SHIP_FROM_PTY_TX_P_ST_ID      NUMBER,
     RDNG_BILL_TO_PTY_TX_P_ST_ID        NUMBER,
     RDNG_BILL_FROM_PTY_TX_P_ST_ID      NUMBER,
     ALLOW_MANUAL_LIN_RECALC_FLAG       VARCHAR2(1),
     ALLOW_MANUAL_LINES_FLAG	    	VARCHAR2(1),
     ALLOW_OVERRIDE_FLAG	        VARCHAR2(1),
     ENFORCE_TAX_FROM_ACCT_FLAG	        VARCHAR2(1),
     PERF_ADDNL_APPL_FOR_IMPRT_FLAG     VARCHAR2(1),
     ALLOW_OFFSET_TAX_CALC_FLAG         VARCHAR2(1),
     ALLOW_OFFSET_TAX_CODE_FLAG         VARCHAR2(1),
     SELF_ASSESS_TAX_LINES_FLAG         VARCHAR2(1),
     TAX_RECOVERY_FLAG                  VARCHAR2(1),
     ALLOW_CANCEL_TAX_LINES_FLAG        VARCHAR2(1),
     ALLOW_MAN_TAX_ONLY_LINES_FLAG      VARCHAR2(1),
     TAX_VARIANCE_CALC_FLAG             VARCHAR2(1),
     RECORD_FLAG                        VARCHAR2(1),
     QUOTE_FLAG                         VARCHAR2(1),
     NORMAL_SIGN_FLAG                   VARCHAR2(1),
     OVERRIDE_LEVEL                     VARCHAR2(30),
     OFFSET_TAX_BASIS_CODE              VARCHAR2(30),
     TAX_TOLERANCE                      NUMBER,
     TAX_TOL_AMT_RANGE                  NUMBER,
     ENABLE_MRC_FLAG                    VARCHAR2(1),
     TAX_REPORTING_FLAG                 VARCHAR2(1),
     ENTER_OVRD_INCL_TAX_LINES_FLAG     VARCHAR2(1),
     CTRL_EFF_OVRD_CALC_LINES_FLAG      VARCHAR2(1),
     SUMMARIZATION_FLAG                 VARCHAR2(1),
     RETAIN_SUMM_TAX_LINE_ID_FLAG       VARCHAR2(1),
     RECORD_FOR_PARTNERS_FLAG           VARCHAR2(1),
     MANUAL_LINES_FOR_PARTNER_FLAG      VARCHAR2(1),
     MAN_TAX_ONLY_LIN_FOR_PTNR_FLAG     VARCHAR2(1),
     ALWAYS_USE_EBTAX_FOR_CALC_FLAG     VARCHAR2(1),
     EVENT_ID                           NUMBER(15),
     TAX_METHOD_CODE                    VARCHAR2(30),
     INCLUSIVE_TAX_USED_FLAG            VARCHAR2(1),
     TAX_USE_CUSTOMER_EXEMPT_FLAG       VARCHAR2(1),
     TAX_USE_PRODUCT_EXEMPT_FLAG        VARCHAR2(1),
     TAX_USE_LOC_EXC_RATE_FLAG          VARCHAR2(1),
     TAX_ALLOW_COMPOUND_FLAG            VARCHAR2(1),
     USE_TAX_CLASSIFICATION_FLAG        VARCHAR2(1),
     ENFORCE_TAX_FROM_REF_DOC_FLAG      VARCHAR2(1),
     PROCESS_FOR_APPLICABILITY_FLAG     VARCHAR2(1),
     ALLOW_TAX_ROUNDING_OVRD_FLAG       VARCHAR2(1),
     HOME_COUNTRY_DEFAULT_FLAG          VARCHAR2(1),
     PROD_FAMILY_GRP_CODE               VARCHAR2(30),
     ESTABLISHMENT_ID                   NUMBER(15),
     EXMPTN_PTY_BASIS_HIER_1_CODE       VARCHAR2(30),
     EXMPTN_PTY_BASIS_HIER_2_CODE       VARCHAR2(30),
     ALLOW_EXEMPTIONS_FLAG              VARCHAR2(1),
     SUP_CUST_ACCT_TYPE                 VARCHAR2(30),
     TAX_CALCULATION_DONE_FLAG          VARCHAR2(1),
     INTGRTN_DET_FACTORS_UI_FLAG        VARCHAR2(1),
     DISPLAY_TAX_CLASSIF_FLAG           VARCHAR2(1),
     ICX_SESSION_ID                     NUMBER(15),
     HEADER_LEVEL_CURRENCY_FLAG         VARCHAR2(1),
     SOURCE_EVENT_CLASS_MAPPING_ID      NUMBER(15),
     SOURCE_TAX_EVENT_CLASS_CODE        VARCHAR2(30),
     ASC_INTRCMP_TX_EVNT_CLS_CODE       VARCHAR2(30),
     INTRCMP_TX_EVNT_CLS_CODE           VARCHAR2(30),
     INTRCMP_SRC_APPLN_ID               NUMBER,
     INTRCMP_SRC_ENTITY_CODE            VARCHAR2(30),
     INTRCMP_SRC_EVNT_CLS_CODE          VARCHAR2(30),
     DEF_INTRCMP_TRX_BIZ_CATEGORY       VARCHAR2(240),
     SOURCE_PROCESS_FOR_APPL_FLAG       VARCHAR2(1),
     TEMPLATE_USAGE_CODE                VARCHAR2(30)
    );

TYPE sync_trx_rec_type IS RECORD
 (APPLICATION_ID	                NUMBER,
  ENTITY_CODE	                        VARCHAR2(30),
  EVENT_CLASS_CODE	                VARCHAR2(30),
  EVENT_TYPE_CODE                       VARCHAR2(30),
  TRX_ID	                        NUMBER,
  TRX_NUMBER	                        VARCHAR2(150),
  TRX_DESCRIPTION	                VARCHAR2(240),
  TRX_COMMUNICATED_DATE	                DATE,
  BATCH_SOURCE_ID	                NUMBER,
  BATCH_SOURCE_NAME	                VARCHAR2(150),
  DOC_SEQ_ID	                        NUMBER,
  DOC_SEQ_NAME	                        VARCHAR2(150),
  DOC_SEQ_VALUE	                        VARCHAR2(240),
  TRX_DUE_DATE	                        DATE,
  TRX_TYPE_DESCRIPTION	                VARCHAR2(240),
  SUPPLIER_TAX_INVOICE_NUMBER	        VARCHAR2(150),
  SUPPLIER_TAX_INVOICE_DATE	        DATE,
  SUPPLIER_EXCHANGE_RATE	        NUMBER,
  TAX_INVOICE_DATE	                DATE,
  TAX_INVOICE_NUMBER	                VARCHAR2(150),
  PORT_OF_ENTRY_CODE	                VARCHAR2(30),
  APPLICATION_DOC_STATUS            VARCHAR2(30)
  );

TYPE sync_trx_lines_rec_type IS RECORD
 (APPLICATION_ID	                NUMBER_tbl_type,
  ENTITY_CODE	                        VARCHAR2_30_tbl_type,
  EVENT_CLASS_CODE	                VARCHAR2_30_tbl_type,
  TRX_ID	                        NUMBER_tbl_type,
  TRX_LEVEL_TYPE	                VARCHAR2_30_tbl_type,
  TRX_LINE_ID	                        NUMBER_tbl_type,
  TRX_WAYBILL_NUMBER	                VARCHAR2_50_tbl_type,
  TRX_LINE_DESCRIPTION	                VARCHAR2_240_tbl_type,
  PRODUCT_DESCRIPTION	                VARCHAR2_240_tbl_type,
  TRX_LINE_GL_DATE	                DATE_tbl_TYPE,
  MERCHANT_PARTY_NAME	                VARCHAR2_150_tbl_type,
  MERCHANT_PARTY_DOCUMENT_NUMBER        VARCHAR2_150_tbl_type,
  MERCHANT_PARTY_REFERENCE	        VARCHAR2_250_tbl_type,
  MERCHANT_PARTY_TAXPAYER_ID	        VARCHAR2_150_tbl_type,
  MERCHANT_PARTY_TAX_REG_NUMBER	        VARCHAR2_150_tbl_type,
  ASSET_NUMBER                       	VARCHAR2_150_tbl_type
  );
  sync_trx_lines_tbl_type   sync_trx_lines_rec_type;

 TYPE distccid_det_facts_rec_type  IS RECORD
 (GL_DATE	                       DATE,
  TAX_RATE_ID	                       NUMBER,
  REC_RATE_ID	                       NUMBER,
  SELF_ASSESSED_FLAG	               VARCHAR2(1),
  RECOVERABLE_FLAG	               VARCHAR2(1),
  TAX_JURISDICTION_ID	               NUMBER,
  TAX_REGIME_ID	                       NUMBER,
  TAX_ID 	                       NUMBER,
  INTERNAL_ORGANIZATION_ID	       NUMBER,
  REC_NREC_CCID	                       NUMBER,
  TAX_LIAB_CCID	                       NUMBER,
  TAX_STATUS_ID                        NUMBER,
  REVENUE_EXPENSE_CCID                 NUMBER,
  REC_NREC_TAX_DIST_ID                 NUMBER,
  LEDGER_ID 			       NUMBER,
  ACCOUNT_SOURCE_TAX_RATE_ID	       NUMBER
 );

TYPE header_det_factors_rec_type IS RECORD
    (INTERNAL_ORGANIZATION_ID           NUMBER,
     APPLICATION_ID                     NUMBER,
     ENTITY_CODE                        VARCHAR2(30),
     EVENT_CLASS_CODE                   VARCHAR2(30),
     EVENT_TYPE_CODE                    VARCHAR2(30),
     INTERNAL_ORG_LOCATION_ID           NUMBER,
     LEGAL_ENTITY_ID                    NUMBER,
     LEDGER_ID                          NUMBER,
     TRX_ID                             NUMBER,
     TRX_DATE                           DATE,
     TRX_DOC_REVISION                   VARCHAR2(150),
     TRX_CURRENCY_CODE                  VARCHAR2(30),
     CURRENCY_CONVERSION_TYPE           VARCHAR2(30),
     CURRENCY_CONVERSION_RATE           NUMBER,
     CURRENCY_CONVERSION_DATE           DATE,
     MINIMUM_ACCOUNTABLE_UNIT	        NUMBER,
     PRECISION                          NUMBER,
     ROUNDING_SHIP_TO_PARTY_ID          NUMBER,
     ROUNDING_SHIP_FROM_PARTY_ID        NUMBER,
     ROUNDING_BILL_TO_PARTY_ID          NUMBER,
     ROUNDING_BILL_FROM_PARTY_ID        NUMBER,
     RNDG_SHIP_TO_PARTY_SITE_ID         NUMBER,
     RNDG_SHIP_FROM_PARTY_SITE_ID       NUMBER,
     RNDG_BILL_TO_PARTY_SITE_ID         NUMBER,
     RNDG_BILL_FROM_PARTY_SITE_ID       NUMBER,
     QUOTE_FLAG                         VARCHAR2(1),
     ESTABLISHMENT_ID                   NUMBER,
     RECEIVABLES_TRX_TYPE_ID	        NUMBER,
     RELATED_DOC_APPLICATION_ID	        NUMBER ,
     RELATED_DOC_ENTITY_CODE	        VARCHAR2(30) ,
     RELATED_DOC_EVENT_CLASS_CODE       VARCHAR2(30) ,
     RELATED_DOC_TRX_ID	                NUMBER,
     RELATED_DOC_NUMBER	                VARCHAR2(150),
     RELATED_DOC_DATE                   DATE,
     DEFAULT_TAXATION_COUNTRY	        VARCHAR2(2),
     CTRL_TOTAL_HDR_TX_AMT	        NUMBER,
     TRX_NUMBER	                        VARCHAR2(150),
     TRX_DESCRIPTION	                VARCHAR2(240),
     TRX_COMMUNICATED_DATE	        DATE,
     BATCH_SOURCE_ID	                NUMBER,
     BATCH_SOURCE_NAME	                VARCHAR2(150),
     DOC_SEQ_ID	                        NUMBER,
     DOC_SEQ_NAME	                VARCHAR2(150),
     DOC_SEQ_VALUE	                VARCHAR2(240),
     TRX_DUE_DATE	                DATE,
     TRX_TYPE_DESCRIPTION	        VARCHAR2(240),
     DOCUMENT_SUB_TYPE	                VARCHAR2(240) ,
     SUPPLIER_TAX_INVOICE_NUMBER	VARCHAR2(150),
     SUPPLIER_TAX_INVOICE_DATE	        DATE,
     SUPPLIER_EXCHANGE_RATE	        NUMBER,
     TAX_INVOICE_DATE	                DATE,
     TAX_INVOICE_NUMBER	                VARCHAR2(150),
     FIRST_PTY_ORG_ID	                NUMBER,
     TAX_EVENT_CLASS_CODE	        VARCHAR2(30),
     TAX_EVENT_TYPE_CODE	        VARCHAR2(30),
     DOC_EVENT_STATUS	                VARCHAR2(30),
     RDNG_SHIP_TO_PTY_TX_PROF_ID	NUMBER,
     RDNG_SHIP_FROM_PTY_TX_PROF_ID	NUMBER,
     RDNG_BILL_TO_PTY_TX_PROF_ID	NUMBER,
     RDNG_BILL_FROM_PTY_TX_PROF_ID	NUMBER,
     RDNG_SHIP_TO_PTY_TX_P_ST_ID	NUMBER,
     RDNG_SHIP_FROM_PTY_TX_P_ST_ID	NUMBER,
     RDNG_BILL_TO_PTY_TX_P_ST_ID	NUMBER,
     RDNG_BILL_FROM_PTY_TX_P_ST_ID	NUMBER,
     PORT_OF_ENTRY_CODE                 VARCHAR2(30),
     TAX_REPORTING_FLAG                 VARCHAR2(1),
     PROVNL_TAX_DETERMINATION_DATE      DATE,
     SHIP_THIRD_PTY_ACCT_ID             NUMBER,
     BILL_THIRD_PTY_ACCT_ID             NUMBER,
     SHIP_THIRD_PTY_ACCT_SITE_ID        NUMBER,
     BILL_THIRD_PTY_ACCT_SITE_ID        NUMBER,
     SHIP_TO_CUST_ACCT_SITE_USE_ID      NUMBER,
     BILL_TO_CUST_ACCT_SITE_USE_ID      NUMBER,
     TRX_BATCH_ID                       NUMBER,
     APPLIED_TO_TRX_NUMBER              VARCHAR2(20),
     APPLICATION_DOC_STATUS             VARCHAR2(30),
     SHIP_TO_PARTY_ID                   NUMBER,
     SHIP_FROM_PARTY_ID                 NUMBER,
     POA_PARTY_ID                       NUMBER,
     POO_PARTY_ID                       NUMBER,
     BILL_TO_PARTY_ID                   NUMBER,
     BILL_FROM_PARTY_ID                 NUMBER,
     MERCHANT_PARTY_ID                  NUMBER,
     SHIP_TO_PARTY_SITE_ID              NUMBER,
     SHIP_FROM_PARTY_SITE_ID            NUMBER,
     POA_PARTY_SITE_ID                  NUMBER,
     POO_PARTY_SITE_ID                  NUMBER,
     BILL_TO_PARTY_SITE_ID              NUMBER,
     BILL_FROM_PARTY_SITE_ID            NUMBER,
     SHIP_TO_LOCATION_ID                NUMBER,
     SHIP_FROM_LOCATION_ID              NUMBER,
     POA_LOCATION_ID                    NUMBER,
     POO_LOCATION_ID                    NUMBER,
     BILL_TO_LOCATION_ID                NUMBER,
     BILL_FROM_LOCATION_ID              NUMBER,
     PAYING_PARTY_ID                    NUMBER,
     OWN_HQ_PARTY_ID                    NUMBER,
     TRADING_HQ_PARTY_ID                NUMBER,
     POI_PARTY_ID                       NUMBER,
     POD_PARTY_ID                       NUMBER,
     TITLE_TRANSFER_PARTY_ID            NUMBER,
     PAYING_PARTY_SITE_ID               NUMBER,
     OWN_HQ_PARTY_SITE_ID               NUMBER,
     TRADING_HQ_PARTY_SITE_ID           NUMBER,
     POI_PARTY_SITE_ID                  NUMBER,
     POD_PARTY_SITE_ID                  NUMBER,
     TITLE_TRANSFER_PARTY_SITE_ID       NUMBER,
     PAYING_LOCATION_ID                 NUMBER,
     OWN_HQ_LOCATION_ID                 NUMBER,
     TRADING_HQ_LOCATION_ID             NUMBER,
     POC_LOCATION_ID                    NUMBER,
     POI_LOCATION_ID                    NUMBER,
     POD_LOCATION_ID                    NUMBER,
     TITLE_TRANSFER_LOCATION_ID         NUMBER,
     SHIP_TO_PARTY_TAX_PROF_ID          NUMBER,
     SHIP_FROM_PARTY_TAX_PROF_ID        NUMBER,
     POA_PARTY_TAX_PROF_ID              NUMBER,
     POO_PARTY_TAX_PROF_ID              NUMBER,
     PAYING_PARTY_TAX_PROF_ID           NUMBER,
     OWN_HQ_PARTY_TAX_PROF_ID           NUMBER,
     TRADING_HQ_PARTY_TAX_PROF_ID       NUMBER,
     POI_PARTY_TAX_PROF_ID              NUMBER,
     POD_PARTY_TAX_PROF_ID              NUMBER,
     BILL_TO_PARTY_TAX_PROF_ID          NUMBER,
     BILL_FROM_PARTY_TAX_PROF_ID        NUMBER,
     TITLE_TRANS_PARTY_TAX_PROF_ID      NUMBER,
     SHIP_TO_SITE_TAX_PROF_ID           NUMBER,
     SHIP_FROM_SITE_TAX_PROF_ID         NUMBER,
     POA_SITE_TAX_PROF_ID               NUMBER,
     POO_SITE_TAX_PROF_ID               NUMBER,
     PAYING_SITE_TAX_PROF_ID            NUMBER,
     OWN_HQ_SITE_TAX_PROF_ID            NUMBER,
     TRADING_HQ_SITE_TAX_PROF_ID        NUMBER,
     POI_SITE_TAX_PROF_ID               NUMBER,
     POD_SITE_TAX_PROF_ID               NUMBER,
     BILL_TO_SITE_TAX_PROF_ID           NUMBER,
     BILL_FROM_SITE_TAX_PROF_ID         NUMBER,
     TITLE_TRANS_SITE_TAX_PROF_ID       NUMBER,
     MERCHANT_PARTY_TAX_PROF_ID         NUMBER,
     HQ_ESTB_PARTY_TAX_PROF_ID          NUMBER
    );



/*Bug 2867448 - To be commented out until reolution on product integration extensible parameters
TYPE ext_param_rec_type IS RECORD
    (APPLICATION_ID                    NUMBER,
     ENTITY_CODE                       VARCHAR2(80),
     EVENT_CLASS_CODE                  VARCHAR2(80),
     TRX_ID      	               NUMBER,
     HDR_TRX_USER_KEY1                 VARCHAR2(150),
     HDR_TRX_USER_KEY2                 VARCHAR2(150),
     HDR_TRX_USER_KEY3                 VARCHAR2(150),
     HDR_TRX_USER_KEY4                 VARCHAR2(150),
     HDR_TRX_USER_KEY5                 VARCHAR2(150),
     HDR_TRX_USER_KEY6                 VARCHAR2(150),
     LINE_TRX_USER_KEY1                VARCHAR2(150),
     LINE_TRX_USER_KEY2                VARCHAR2(150),
     LINE_TRX_USER_KEY3                VARCHAR2(150),
     LINE_TRX_USER_KEY4                VARCHAR2(150),
     LINE_TRX_USER_KEY5                VARCHAR2(150),
     LINE_TRX_USER_KEY6                VARCHAR2(150),
     TRX_LINE_ID      	               NUMBER,
     TRX_LINE_DIST_ID  	               NUMBER,
     NUMERIC1    	               NUMBER,
     NUMERIC2    	               NUMBER,
     NUMERIC3    	               NUMBER,
     NUMERIC4    	               NUMBER,
     NUMERIC5    	               NUMBER,
     NUMERIC6    	               NUMBER,
     NUMERIC7    	               NUMBER,
     NUMERIC8    	               NUMBER,
     NUMERIC9    	               NUMBER,
     NUMERIC10   	               NUMBER,
     CHAR1       	               VARCHAR2(150),
     CHAR2       	               VARCHAR2(150),
     CHAR3                   	       VARCHAR2(150),
     CHAR4       	               VARCHAR2(150),
     CHAR5       	               VARCHAR2(150),
     CHAR6       	               VARCHAR2(150),
     CHAR7       	               VARCHAR2(150),
     CHAR8       	               VARCHAR2(150),
     CHAR9       	               VARCHAR2(150),
     CHAR10      	               VARCHAR2(150),
     DATE1       	               DATE,
     DATE2       	               DATE,
     DATE3       	               DATE,
     DATE4       	               DATE,
     DATE5       	               DATE,
     DATE6       	               DATE,
     DATE7       	               DATE,
     DATE8       	               DATE,
     DATE9                             DATE,
     DATE10      	               DATE
    );

TYPE ext_param_tbl_type IS TABLE OF ext_param_rec_type
INDEX BY BINARY_INTEGER;
*/

TYPE context_info_rec_type IS RECORD (
  APPLICATION_ID          	    NUMBER,
  ENTITY_CODE             	    VARCHAR2(30),
  EVENT_CLASS_CODE        	    VARCHAR2(30),
  TRX_ID           	            NUMBER,
  TRX_LINE_ID                       NUMBER ,
  TRX_LEVEL_TYPE                    VARCHAR2(30),
  SUMMARY_TAX_LINE_NUMBER           NUMBER ,
  TAX_LINE_ID                       NUMBER,
  TRX_LINE_DIST_ID                  NUMBER
  );

--Bug 3581953 - Create record of tables to facilitate bulk inserts
TYPE errors_rec_type is RECORD (
  APPLICATION_ID          	    NUMBER_tbl_type,
  ENTITY_CODE             	    VARCHAR2_30_tbl_type,
  EVENT_CLASS_CODE        	    VARCHAR2_30_tbl_type,
  TRX_ID           	            NUMBER_tbl_type,
  TRX_LINE_ID                       NUMBER_tbl_type,
  SUMMARY_TAX_LINE_NUMBER           NUMBER_tbl_type,
  TAX_LINE_ID                       NUMBER_tbl_type,
  TRX_LEVEL_TYPE                    VARCHAR2_30_tbl_type,
  TRX_LINE_DIST_ID                  NUMBER_tbl_type,
  MESSAGE_TEXT                      VARCHAR2_2000_tbl_type
  );
 errors_tbl  errors_rec_type;

TYPE pa_item_info_rec_type IS RECORD(
  APPLICATION_ID                ZX_REC_NREC_DIST.application_id%TYPE,
  ENTITY_CODE                   ZX_REC_NREC_DIST.entity_code%TYPE,
  EVENT_CLASS_CODE              ZX_REC_NREC_DIST.entity_code%TYPE,
  TRX_ID                        ZX_REC_NREC_DIST.trx_id%TYPE,
  TRX_LINE_ID                   ZX_REC_NREC_DIST.trx_line_id%TYPE,
  TRX_LEVEL_TYPE                ZX_REC_NREC_DIST.trx_level_type%TYPE,
  ITEM_EXPENSE_DIST_ID          ZX_REC_NREC_DIST.trx_line_dist_id %TYPE,
  NEW_ACCOUNT_CCID              ZX_REC_NREC_DIST.account_ccid%TYPE,
  NEW_ACCOUNT_STRING            ZX_REC_NREC_DIST.account_string%TYPE,
  NEW_PROJECT_ID                ZX_REC_NREC_DIST.project_id %TYPE,
  NEW_TASK_ID                   ZX_REC_NREC_DIST.task_id%TYPE,
  RECOVERABILITY_AFFECTED       BOOLEAN
  );
TYPE pa_item_info_tbl_type is table of pa_item_info_rec_type
INDEX BY BINARY_INTEGER;

TYPE det_fact_defaulting_rec_type is RECORD (
  APPLICATION_ID	        NUMBER,
  ENTITY_CODE                   VARCHAR2(30),
  EVENT_CLASS_CODE	        VARCHAR2(30),
  ORG_ID	                NUMBER,
  ITEM_ID	                NUMBER,
  ITEM_ORG_ID                   NUMBER,
  COUNTRY_CODE	                VARCHAR2(2),
  EFFECTIVE_DATE	        DATE,
  TRX_ID                        NUMBER,
  TRX_LINE_ID                   NUMBER,
  TRX_LEVEL_TYPE                NUMBER,
  TRX_DATE                      DATE,
  LEDGER_ID                     NUMBER,
  SHIP_FROM_PARTY_ID            NUMBER,
  SHIP_TO_PARTY_ID              NUMBER,
  BILL_TO_PARTY_ID              NUMBER,
  SHIP_FROM_PTY_SITE_ID         NUMBER,
  SHIP_TO_LOCATION_ID           NUMBER,
  SHIP_TO_ACCT_SITE_USE_ID      NUMBER,
  BILL_TO_ACCT_SITE_USE_ID      NUMBER,
  ACCOUNT_CCID                  NUMBER,
  ACCOUNT_STRING                VARCHAR2(2000),
  TRX_TYPE_ID                   NUMBER,
  SHIP_THIRD_PTY_ACCT_ID        NUMBER,
  BILL_THIRD_PTY_ACCT_ID        NUMBER,
  DEFAULTING_ATTRIBUTE1         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE2         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE3         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE4         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE5         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE6         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE7         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE8         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE9         VARCHAR2(150),
  DEFAULTING_ATTRIBUTE10        VARCHAR2(150),
  REF_DOC_APPLICATION_ID        NUMBER,
  REF_DOC_ENTITY_CODE           VARCHAR2(30),
  REF_DOC_EVENT_CLASS_CODE      VARCHAR2(30),
  REF_DOC_TRX_ID                NUMBER,
  REF_DOC_LINE_ID               NUMBER,
  REF_DOC_TRX_LEVEL_TYPE        VARCHAR2(30),
  LEGAL_ENTITY_ID               NUMBER,
  SOURCE_EVENT_CLASS_CODE       VARCHAR2(30)
 );


TYPE def_tax_cls_code_info_rec_type IS RECORD (
  APPLICATION_ID                 NUMBER,
  ENTITY_CODE                    VARCHAR2(30),
  EVENT_CLASS_CODE               VARCHAR2(30),
  INTERNAL_ORGANIZATION_ID	 NUMBER,
  TRX_ID                         NUMBER,
  TRX_LINE_ID                    NUMBER,
  TRX_LEVEL_TYPE                 VARCHAR2(30),
  LEDGER_ID                      NUMBER(15),
  TRX_DATE                       DATE,
  REF_DOC_APPLICATION_ID         NUMBER,
  REF_DOC_ENTITY_CODE            VARCHAR2(30),
  REF_DOC_EVENT_CLASS_CODE       VARCHAR2(30),
  REF_DOC_TRX_ID                 NUMBER,
  REF_DOC_LINE_ID                NUMBER,
  REF_DOC_TRX_LEVEL_TYPE         VARCHAR2(30),
  ACCOUNT_CCID                   NUMBER,
  ACCOUNT_STRING                 VARCHAR2(2000),
  PRODUCT_ID                     NUMBER,
  PRODUCT_ORG_ID                 NUMBER,
  RECEIVABLES_TRX_TYPE_ID        NUMBER,
  SHIP_THIRD_PTY_ACCT_ID         NUMBER,
  BILL_THIRD_PTY_ACCT_ID         NUMBER,
  SHIP_THIRD_PTY_ACCT_SITE_ID    NUMBER,
  BILL_THIRD_PTY_ACCT_SITE_ID    NUMBER,
  SHIP_TO_CUST_ACCT_SITE_USE_ID  NUMBER,
  BILL_TO_CUST_ACCT_SITE_USE_ID  NUMBER,
  SHIP_TO_LOCATION_ID            NUMBER,
  DEFAULTING_ATTRIBUTE1          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE2          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE3          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE4          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE5          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE6          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE7          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE8          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE9          VARCHAR2(150),
  DEFAULTING_ATTRIBUTE10         VARCHAR2(150),
  TAX_USER_OVERRIDE_FLAG         VARCHAR2(1),
  OVERRIDDEN_TAX_CLS_CODE        VARCHAR2(30),
  LEGAL_ENTITY_ID                NUMBER,
  INPUT_TAX_CLASSIFICATION_CODE  VARCHAR2(50),
  OUTPUT_TAX_CLASSIFICATION_CODE VARCHAR2(50),
  X_TAX_CLASSIFICATION_CODE      VARCHAR2(50),
  X_ALLOW_TAX_CODE_OVERRIDE_FLAG VARCHAR2(1)
  );

TYPE hold_codes_tbl_type IS TABLE OF varchar2(80)
INDEX BY BINARY_INTEGER;

TYPE validation_status_tbl_type IS TABLE OF varchar2(80)
INDEX BY BINARY_INTEGER;

TYPE tax_dist_id_tbl_type IS TABLE OF zx_rec_nrec_dist.REC_NREC_TAX_DIST_ID%type
INDEX BY BINARY_INTEGER;

/* =======================================================================*
 | PROCEDURE  set_tax_security_context :  Sets the security context based |
 |                                        on OU and LE of transaction     |
 * =======================================================================*/

       PROCEDURE set_tax_security_context
       (
          p_api_version           IN         NUMBER,
          p_init_msg_list         IN         VARCHAR2,
          p_commit                IN         VARCHAR2,
          p_validation_level      IN         NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2,
          x_msg_count             OUT NOCOPY NUMBER ,
          x_msg_data              OUT NOCOPY VARCHAR2,
          p_internal_org_id       IN         NUMBER,
          p_legal_entity_id       IN         NUMBER,
          p_transaction_date      IN         DATE,
          p_related_doc_date      IN         DATE,
          p_adjusted_doc_date     IN         DATE,
          x_effective_date        OUT NOCOPY DATE
       );


/* =======================================================================*
 | Overloaded PROCEDURE  set_tax_security_context: for Lease Management   |
 | Also includes setting the date based on provnl_tax_determination_date  |
 * =======================================================================*/

       PROCEDURE set_tax_security_context
       (
          p_api_version           IN         NUMBER,
          p_init_msg_list         IN         VARCHAR2,
          p_commit                IN         VARCHAR2,
          p_validation_level      IN         NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2,
          x_msg_count             OUT NOCOPY NUMBER,
          x_msg_data              OUT NOCOPY VARCHAR2,
          p_internal_org_id       IN         NUMBER,
          p_legal_entity_id       IN         NUMBER,
          p_transaction_date      IN         DATE,
          p_related_doc_date      IN         DATE,
          p_adjusted_doc_date     IN         DATE,
          p_provnl_tax_det_date   IN         DATE,
          x_effective_date        OUT NOCOPY DATE
       );

/* ======================================================================*
 | PROCEDURE calculate_tax : Calculates and records tax info             |
 | This API accepts information in both pl/sql as well as GTT            |
 | This API also supports processing for multiple event classes          |
 | GTT involved : ZX_TRANSACTION_HEADERS_GT, ZX_TRANSACTION_LINES_GT     |
 * ======================================================================*/

        PROCEDURE calculate_tax
        (
           p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2
    	);


 /*======================================================================*
 | PROCEDURE calculate_tax : Calculates and records tax info             |
 | This API accepts information in both pl/sql as well as GTT            |
 | This API also supports processing for multiple event classes          |
 | PL/sql tables: trx_line_dist_tbl   , transaction_rec                  |
 * ======================================================================*/
        PROCEDURE calculate_tax
        (
           p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2 ,
           x_msg_count             OUT NOCOPY NUMBER ,
           x_msg_data              OUT NOCOPY VARCHAR2,
           p_transaction_rec       IN         transaction_rec_type,
           p_quote_flag            IN         VARCHAR2,
           p_data_transfer_mode    IN         VARCHAR2,
	   x_doc_level_recalc_flag OUT NOCOPY VARCHAR2
    	);

/* ======================================================================*
 | PROCEDURE import_document_with_tax : Imports document with tax        |
 | This API also supports processing for multiple event classes          |
 | GTT involved : ZX_TRANSACTION_HEADERS_GT, ZX_TRANSACTION_LINES_GT ,   |
 |                ZX_IMPORT_TAX_LINES_GT and ZX_TRX_TAX_LINK_GT          |
 * ======================================================================*/

        PROCEDURE import_document_with_tax
        (
	   p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2
    	);


/* ======================================================================*
 | PROCEDURE synchronize_tax_repository : Updates tax repository         |
 | GTT involved :  ZX_TRX_HEADERS_GT and ZX_SYNC_TRX_LINES_GT            |
 * ======================================================================*/

        PROCEDURE synchronize_tax_repository
        (
           p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           p_sync_trx_rec          IN         sync_trx_rec_type,
           p_sync_trx_lines_tbl    IN         sync_trx_lines_tbl_type%type
       );

/* ======================================================================*
 | PROCEDURE override_tax : Overrides tax lines                          |
 * ======================================================================*/

        PROCEDURE override_tax
        (
           p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           p_transaction_rec       IN         transaction_rec_type,
           p_override_level        IN         VARCHAR2,
           p_event_id              IN         NUMBER
        );


/* ======================================================================*
 | PROCEDURE global_document_update :                                    |
 * ======================================================================*/

        PROCEDURE global_document_update
        (
           p_api_version           IN               NUMBER,
           p_init_msg_list         IN               VARCHAR2,
           p_commit                IN               VARCHAR2,
           p_validation_level      IN               NUMBER,
           x_return_status         OUT    NOCOPY    VARCHAR2,
           x_msg_count             OUT    NOCOPY    NUMBER,
           x_msg_data              OUT    NOCOPY    VARCHAR2,
           p_transaction_rec       IN OUT NOCOPY    transaction_rec_type
    	);


/* ======================================================================*
 | Overloaded PROCEDURE global_document_update for release holds         |
 * ======================================================================*/

        PROCEDURE global_document_update
        (
    	   p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT    NOCOPY VARCHAR2,
           x_msg_count             OUT    NOCOPY NUMBER,
           x_msg_data              OUT    NOCOPY VARCHAR2,
           p_transaction_rec       IN OUT NOCOPY transaction_rec_type,
           p_validation_status     IN            ZX_API_PUB.validation_status_tbl_type
         );


/* ======================================================================*
 | PROCEDURE mark_tax_lines_deleted :                                    |
 * ======================================================================*/

        PROCEDURE mark_tax_lines_deleted
        (
    	   p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT    NOCOPY VARCHAR2,
           x_msg_count             OUT    NOCOPY NUMBER,
           x_msg_data              OUT    NOCOPY VARCHAR2,
           p_transaction_line_rec  IN OUT NOCOPY transaction_line_rec_type
    	);


/* ======================================================================*
 | PROCEDURE reverse_document : Reverses the base document               |
 | GTT involved : ZX_REV_TRX_HEADERS_GT, ZX_REVERSE_TRX_LINES_GT         |
 * ======================================================================*/
        PROCEDURE reverse_document
        (
          p_api_version            IN         NUMBER,
          p_init_msg_list          IN         VARCHAR2,
          p_commit                 IN         VARCHAR2,
          p_validation_level       IN         NUMBER,
          x_return_status          OUT NOCOPY VARCHAR2,
          x_msg_count              OUT NOCOPY NUMBER ,
          x_msg_data               OUT NOCOPY VARCHAR2
        );

/* ================================================================================*
 | PROCEDURE Reverse_document_distribution: Reverses the base reversing event class|
 | GTT involved : ZX_REV_TRX_HEADERS_GT, ZX_REVERSE_TRX_LINES_GT                   |
 * ================================================================================*/

        PROCEDURE reverse_document_distribution
        (
	   p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2
        );



/* ======================================================================*
 | PROCEDURE Reverse_distributions : Reverses the base distribution      |
 | GTT involved : ZX_REVERSE_DIST_GT                                     |
 * ======================================================================*/

        PROCEDURE reverse_distributions
        (
	   p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2
        );


/* =======================================================================*
 | PROCEDURE  determine_recovery : Calculate the distribution of tax amounts
 | into recoverable and/or non-recoverable tax amounts.                   |
 | This API also supports processing for multiple event classes           |
 | GTT involved : ZX_TRANSACTION_HEADERS_GT, ZX_ITM_DISTRIBUTIONS_GT      |
 * =======================================================================*/

        PROCEDURE determine_recovery
        (
	   p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2
        );


/* =======================================================================*
 | PROCEDURE  override_recovery :Overrides the tax recovery rate code     |
 |                                                                        |
 * =======================================================================*/

        PROCEDURE override_recovery
        (
	   p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT    NOCOPY VARCHAR2,
           x_msg_count             OUT    NOCOPY NUMBER,
           x_msg_data              OUT    NOCOPY VARCHAR2,
           p_transaction_rec       IN OUT NOCOPY transaction_rec_type
        );

 /* =======================================================================*
 | PROCEDURE  freeze_tax_distributions :                                  |
 * =======================================================================*/

        PROCEDURE freeze_tax_distributions
        (
          p_api_version           IN             NUMBER,
          p_init_msg_list         IN             VARCHAR2,
          p_commit                IN             VARCHAR2,
          p_validation_level      IN             NUMBER,
          x_return_status         OUT    NOCOPY  VARCHAR2,
          x_msg_count             OUT    NOCOPY  NUMBER,
          x_msg_data              OUT    NOCOPY  VARCHAR2,
          p_transaction_rec       IN OUT NOCOPY  transaction_rec_type
        );

/* ======================================================================*
 | PROCEDURE get_tax_distribution_ccids : Products call this API if they |
 |                                        need to determine the code     |
 |                                        combination identifiers for    |
 |                                        tax liability and tax recovery/|
 |                                        nonrecovery accounts           |
 * ======================================================================*/

        PROCEDURE get_tax_distribution_ccids
        (
            p_api_version            IN            NUMBER,
            p_init_msg_list          IN            VARCHAR2,
            p_commit                 IN            VARCHAR2,
            p_validation_level       IN            NUMBER,
            x_return_status          OUT    NOCOPY VARCHAR2,
            x_msg_count              OUT    NOCOPY NUMBER,
            x_msg_data               OUT    NOCOPY VARCHAR2,
            p_dist_ccid_rec          IN OUT NOCOPY distccid_det_facts_rec_type
    	);


/* ===================================================================================*
 | PROCEDURE Update_tax_dist_gl_date : Updates gl date of a list of Tax Distributions |
 | GTT involved : ZX_TAX_DIST_ID_GT                                                   |
 * ====================================================================================*/

        PROCEDURE update_tax_dist_gl_date
        (
	   p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           p_gl_date               IN         DATE
    	);

 /* =====================================================================*
 | PROCEDURE Update_exchange_rate : Updates Exchange Rate                |
 | This is the GTT version                                               |
 | There exists only pl/sql version of API                               |
 ========================================================================*/

        PROCEDURE update_exchange_rate
        (
           p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           p_transaction_rec       IN         transaction_rec_type,
           p_curr_conv_rate        IN         NUMBER,
           p_curr_conv_date        IN         DATE,
           p_curr_conv_type        IN         VARCHAR2
        );

/* =======================================================================*
 | PROCEDURE  validate_document_for_tax for Receivables Autoinvoice       |
 |            and recurring invoice.                                      |
 |            Bug 5518807                                                 |
 * =======================================================================*/

        PROCEDURE validate_document_for_tax
        (
           p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2 ,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT    NOCOPY VARCHAR2 ,
           x_msg_count             OUT    NOCOPY NUMBER ,
           x_msg_data              OUT    NOCOPY VARCHAR2
        );

/* =======================================================================*
 | PROCEDURE  validate_document_for_tax :                                 |
 * =======================================================================*/

        PROCEDURE validate_document_for_tax
        (
           p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT    NOCOPY VARCHAR2,
           x_msg_count             OUT    NOCOPY NUMBER,
           x_msg_data              OUT    NOCOPY VARCHAR2,
           p_transaction_rec       IN OUT NOCOPY transaction_rec_type,
           x_validation_status     OUT    NOCOPY VARCHAR2,
           x_hold_codes_tbl        OUT    NOCOPY zx_api_pub.hold_codes_tbl_type
    	);


/* =======================================================================*
 | PROCEDURE  validate_and_default_tax_attr :                             |
 | This api supports multiple document processing                         |
 * =======================================================================*/

       PROCEDURE validate_and_default_tax_attr
       (
            p_api_version           IN         NUMBER,
            p_init_msg_list         IN         VARCHAR2,
            p_commit                IN         VARCHAR2,
            p_validation_level      IN         NUMBER,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2
       );


/* ============================================================================*
 | PROCEDURE get_default_tax_line_attribs : default the tax status and tax rate|
 |                                       based on the tax regime and tax       |
 * ===========================================================================*/

        PROCEDURE get_default_tax_line_attribs
        (
           p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           p_tax_regime_code       IN         VARCHAR2,
           p_tax                   IN         VARCHAR2,
           p_effective_date        IN         DATE,
           x_tax_status_code       OUT NOCOPY VARCHAR2,
           x_tax_rate_code         OUT NOCOPY VARCHAR2
        ) ;

/* ================================================================================*
 | PROCEDURE  get_default_tax_det_attribs : default the fiscal classification values|
 * ===============================================================================*/

        PROCEDURE get_default_tax_det_attribs
        (
            p_api_version           IN         NUMBER,
            p_init_msg_list         IN         VARCHAR2,
            p_commit                IN         VARCHAR2,
            p_validation_level      IN         NUMBER,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_application_id	    IN	       NUMBER,
            p_entity_code           IN         VARCHAR2,
            p_event_class_code	    IN	       VARCHAR2,
            p_org_id	            IN	       NUMBER,
            p_item_id	            IN	       NUMBER,
            p_country_code          IN	       VARCHAR2,
            p_effective_date	    IN	       DATE,
            x_trx_biz_category	    OUT	NOCOPY VARCHAR2,
            x_intended_use	    OUT	NOCOPY VARCHAR2,
            x_prod_category	    OUT	NOCOPY VARCHAR2,
            x_prod_fisc_class_code  OUT	NOCOPY VARCHAR2,
            x_product_type          OUT	NOCOPY VARCHAR2
        ) ;

/* ================================================================================*
 | PROCEDURE  get_default_tax_det_attribs : default the fiscal classification values|
 * ===============================================================================*/

        PROCEDURE get_default_tax_det_attribs
        (
            p_api_version             IN         NUMBER,
            p_init_msg_list           IN         VARCHAR2,
            p_commit                  IN         VARCHAR2,
            p_validation_level        IN         NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_application_id	      IN	 NUMBER,
            p_entity_code             IN         VARCHAR2,
            p_event_class_code	      IN	 VARCHAR2,
            p_org_id	              IN	 NUMBER,
            p_item_id	              IN	 NUMBER,
            p_country_code            IN	 VARCHAR2,
            p_effective_date	      IN	 DATE,
            p_source_event_class_code IN	 VARCHAR2,
            x_trx_biz_category	      OUT NOCOPY VARCHAR2,
            x_intended_use	      OUT NOCOPY VARCHAR2,
            x_prod_category	      OUT NOCOPY VARCHAR2,
            x_prod_fisc_class_code    OUT NOCOPY VARCHAR2,
            x_product_type            OUT NOCOPY VARCHAR2,
            p_inventory_org_id         IN NUMBER DEFAULT NULL
        ) ;

/* =============================================================================*
 | PROCEDURE  Discard_tax_only_lines : Called when the whole document containing|
 |                                     tax only lines is cancelled              |
 * =============================================================================*/

        PROCEDURE discard_tax_only_lines
        (
    	   p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           p_transaction_rec       IN         transaction_rec_type
        );


/* =======================================================================*
 | FUNCTION  determine_effective_date :                                   |
 |                                                                        |
 * =======================================================================*/

        FUNCTION determine_effective_date
        (
           p_transaction_date      IN  DATE,
           p_related_doc_date      IN  DATE,
           p_adjusted_doc_date     IN  DATE
        ) RETURN DATE;



/* ==========================================================================*
 | PROCEDURE  rollback_for_tax :  Communicate to the Tax Partners to rollback|
 |                                transactions in their system               |
 * =========================================================================*/

       PROCEDURE rollback_for_tax
       (
           p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2
       );

/* ========================================================================*
 | PROCEDURE  commit_for_tax :  Communicate to the Tax Partners to commit  |
 |                              transactions in their system               |
 * =======================================================================*/

       PROCEDURE commit_for_tax
       (
           p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2
       );


/* =======================================================================*
 | PROCEDURE  add_msg : Adds the message to the fnd message stack or      |
 |                      local plsql table to be dumped later into the     |
 |                      validation errors GT.
 * =======================================================================*/

       PROCEDURE add_msg
       (
         p_context_info_rec IN context_info_rec_type
       );

/* =======================================================================*
 | PROCEDURE  dump_msg : Dumps the messages into validation errors GT     |
 * =======================================================================*/

       PROCEDURE dump_msg;


/* =================================================================================*
 | Overloaded Procedure  get_default_tax_det_attribs- for products that do not call |
 | ARP_TAX.get_default_tax_classification                                           |
 | Default the following product fiscal                                             |
 | classification based on the relevant default taxation country, application event |
 | class, inventory organization and inventory item values:                         |
 |             *	trx_business_category                                       |
 |             *	primary_intended_use                                        |
 |             *	product_fisc_classificatio                                  |
 |             *	product_category                                            |
 | Also default the tax classification code                                         |
 * ================================================================================*/

      PROCEDURE get_default_tax_det_attribs
       (
         p_api_version                   IN         NUMBER,
         p_init_msg_list                 IN         VARCHAR2,
         p_commit                        IN         VARCHAR2,
         p_validation_level              IN         NUMBER,
         x_return_status                 OUT NOCOPY VARCHAR2,
         x_msg_count                     OUT NOCOPY NUMBER,
         x_msg_data                      OUT NOCOPY VARCHAR2,
         p_defaulting_rec_type           IN         det_fact_defaulting_rec_type,
         x_trx_biz_category	         OUT NOCOPY VARCHAR2,
         x_intended_use	                 OUT NOCOPY VARCHAR2,
         x_prod_category	         OUT NOCOPY VARCHAR2,
         x_prod_fisc_class_code          OUT NOCOPY VARCHAR2,
         x_product_type                  OUT NOCOPY VARCHAR2,
         x_tax_classification_code       OUT NOCOPY VARCHAR2
        );

/* =======================================================================*
 | Function  Get_Default_Tax_Reg : Returns the Default Registration Number|
 |                                 for a Given Party                      |
 * =======================================================================*/
       FUNCTION get_default_tax_reg
	   (
        p_api_version       IN         NUMBER,
        p_init_msg_list     IN         VARCHAR2,
        p_commit            IN         VARCHAR2,
        p_validation_level  IN         NUMBER,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2,
        p_party_id          IN         ZX_PARTY_TAX_PROFILE.party_id%type,
        p_party_type        IN         ZX_PARTY_TAX_PROFILE.party_type_code%type,
        p_effective_date    IN         ZX_REGISTRATIONS.effective_from%type
       ) RETURN Varchar2;
 /* ========================================================================*
 | PROCEDURE  insert_line_det_factors : This procedure should be called by |
 | products when creating a document or inserting a new transaction line   |
 | for existing document. This line will be flagged to be picked up by the |
 | tax calculation process                                                 |
 * =======================================================================*/

       PROCEDURE insert_line_det_factors
       (
         p_api_version        IN         NUMBER,
         p_init_msg_list      IN         VARCHAR2,
         p_commit             IN         VARCHAR2,
         p_validation_level   IN         NUMBER,
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_count          OUT NOCOPY NUMBER,
         x_msg_data           OUT NOCOPY VARCHAR2,
         p_duplicate_line_rec IN         transaction_line_rec_type
       );

 /* ============================================================================*
 | PROCEDURE  insert_line_det_factors : This overloaded procedure will be called|
 | by iProcurement to insert all the transaction lines with defaulted tax       |
 | determining attributes into zx_lines_det_factors after complying with the    |
 | validation process.All lines thus inserted will be flagged to be picked up by|
 | the tax calculation process                                                  |
 * ============================================================================*/

       PROCEDURE insert_line_det_factors
       (
         p_api_version        IN         NUMBER,
         p_init_msg_list      IN         VARCHAR2,
         p_commit             IN         VARCHAR2,
         p_validation_level   IN         NUMBER,
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_count          OUT NOCOPY NUMBER,
         x_msg_data           OUT NOCOPY VARCHAR2
       );

/* ========================================================================*
 | PROCEDURE  update_line_det_factors : This procedure should be called by |
 | products when updating any of the line attributes on the transaction    |
 | so that the tax repository is also in sync with the line level updates  |
 | This line will be flagged to be picked up by the tax calculation process|
 * =======================================================================*/

       PROCEDURE update_line_det_factors
       (
         p_api_version        IN         NUMBER,
         p_init_msg_list      IN         VARCHAR2,
         p_commit             IN         VARCHAR2,
         p_validation_level   IN         NUMBER,
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_count          OUT NOCOPY NUMBER,
         x_msg_data           OUT NOCOPY VARCHAR2
       );


/* ========================================================================*
 | PROCEDURE  update_det_factors_hdr: This procedure should be called by   |
 | products when updating any of the header attributes on the transaction  |
 | so that the tax repository is also in sync with the header level updates|
 | and also so that the document is picked up for tax calculation later    |
 * =======================================================================*/

       PROCEDURE update_det_factors_hdr
       (
         p_api_version         IN         NUMBER,
         p_init_msg_list       IN         VARCHAR2,
         p_commit              IN         VARCHAR2,
         p_validation_level    IN         NUMBER,
         x_return_status       OUT NOCOPY VARCHAR2,
         x_msg_count           OUT NOCOPY NUMBER,
         x_msg_data            OUT NOCOPY VARCHAR2,
         p_hdr_det_factors_rec IN         header_det_factors_rec_type
       );


/* ============================================================================*
 | PROCEDURE  copy_insert_line_det_factors : This procedure will be called      |
 | by iProcurement to insert all the transaction lines into zx_lines_det_factors|
 | after copying the tax determining attributes from the source document        |
 | informaiton passed in. All lines thus inserted will be flagged to be picked  |
 | up by the tax calculation process                                            |
 * ============================================================================*/

       PROCEDURE copy_insert_line_det_factors
       (
         p_api_version        IN         NUMBER,
         p_init_msg_list      IN         VARCHAR2,
         p_commit             IN         VARCHAR2,
         p_validation_level   IN         NUMBER,
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_count          OUT NOCOPY NUMBER,
         x_msg_data           OUT NOCOPY VARCHAR2
       );


/* ============================================================================*
 | PROCEDURE  is_recoverability_affected : This procedure will determine       |
 | whether some accounting related information can be modified on the item     |
 | distribution from tax point of view.                                        |
 * ============================================================================*/
       PROCEDURE is_recoverability_affected
       (
         p_api_version        IN             NUMBER,
         p_init_msg_list      IN             VARCHAR2,
         p_commit             IN             VARCHAR2,
         p_validation_level   IN             NUMBER,
         x_return_status      OUT     NOCOPY VARCHAR2,
         x_msg_count          OUT     NOCOPY NUMBER,
         x_msg_data           OUT     NOCOPY VARCHAR2,
         p_pa_item_info_tbl   IN  OUT NOCOPY pa_item_info_tbl_type
       );

/* ======================================================================*
 | PROCEDURE delete_tax_line_and_distributions:                          |
 * ======================================================================*/

        PROCEDURE del_tax_line_and_distributions
        (
    	   p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT    NOCOPY VARCHAR2,
           x_msg_count             OUT    NOCOPY NUMBER,
           x_msg_data              OUT    NOCOPY VARCHAR2,
           p_transaction_line_rec  IN OUT NOCOPY transaction_line_rec_type
    	);
/* ======================================================================*
 | PROCEDURE delete_tax_distributions:                                   |
 * ======================================================================*/

        PROCEDURE delete_tax_distributions
        (
    	   p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT    NOCOPY VARCHAR2,
           x_msg_count             OUT    NOCOPY NUMBER,
           x_msg_data              OUT    NOCOPY VARCHAR2,
           p_transaction_line_rec  IN OUT NOCOPY transaction_line_rec_type
    	);

/* ======================================================================*
 | PROCEDURE get_default_tax_det_attribs: overloaded version for PO      |
 * ======================================================================*/

        PROCEDURE get_default_tax_det_attribs
        (
    	   p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT NOCOPY    VARCHAR2,
           x_msg_count             OUT NOCOPY    NUMBER ,
           x_msg_data              OUT NOCOPY    VARCHAR2
    	);


/* ======================================================================*
 | PROCEDURE redefault_intended_use: Redefault intended use              |
 * ======================================================================*/

        PROCEDURE redefault_intended_use
        (
    	   p_api_version          IN            NUMBER,
           p_init_msg_list        IN            VARCHAR2,
           p_commit               IN            VARCHAR2,
           p_validation_level     IN            NUMBER,
           x_return_status        OUT NOCOPY    VARCHAR2,
           x_msg_count            OUT NOCOPY    NUMBER ,
           x_msg_data             OUT NOCOPY    VARCHAR2,
           p_application_id       IN            NUMBER,
           p_entity_code          IN            VARCHAR2,
           p_event_class_code     IN            VARCHAR2,
           p_internal_org_id      IN            NUMBER,
           p_country_code         IN            VARCHAR2,
           p_item_id              IN            NUMBER,
           p_item_org_id          IN            NUMBER,
           x_intended_use         OUT NOCOPY    VARCHAR2
        );

/* ======================================================================*
 | PROCEDURE redefault_prod_fisc_class_code: Redefault product fiscal    |
 |                                           classification              |
 * ======================================================================*/
       PROCEDURE redefault_prod_fisc_class_code
       (
    	   p_api_version          IN            NUMBER,
           p_init_msg_list        IN            VARCHAR2,
           p_commit               IN            VARCHAR2,
           p_validation_level     IN            NUMBER,
           x_return_status        OUT NOCOPY    VARCHAR2,
           x_msg_count            OUT NOCOPY    NUMBER ,
           x_msg_data             OUT NOCOPY    VARCHAR2,
           p_application_id       IN            NUMBER,
           p_entity_code          IN            VARCHAR2,
           p_event_class_code     IN            VARCHAR2,
           p_internal_org_id      IN            NUMBER,
           p_country_code         IN            VARCHAR2,
           p_item_id              IN            NUMBER,
           p_item_org_id          IN            NUMBER,
           x_prod_fisc_class_code OUT NOCOPY    VARCHAR2
       );

/* ======================================================================*
 | PROCEDURE redefault_assessable_value: Redefault assessable value      |
 * ======================================================================*/

       PROCEDURE redefault_assessable_value
       (
    	   p_api_version          IN            NUMBER,
           p_init_msg_list        IN            VARCHAR2,
           p_commit               IN            VARCHAR2,
           p_validation_level     IN            NUMBER,
           x_return_status        OUT NOCOPY    VARCHAR2,
           x_msg_count            OUT NOCOPY    NUMBER ,
           x_msg_data             OUT NOCOPY    VARCHAR2,
           p_application_id       IN            NUMBER,
           p_entity_code          IN            VARCHAR2,
           p_event_class_code     IN            VARCHAR2,
           p_internal_org_id      IN            NUMBER,
           p_trx_id               IN            NUMBER,
           p_trx_line_id          IN            NUMBER,
           p_trx_level_type       IN            VARCHAR2,
           p_item_id              IN            NUMBER,
           p_item_org_id          IN            NUMBER,
           p_line_amt             IN            NUMBER,
           x_assessable_value     OUT NOCOPY    NUMBER
       );

/* ======================================================================*
 | PROCEDURE redefault_product_type: Redefault product type              |
 * ======================================================================*/

       PROCEDURE redefault_product_type
       (
    	   p_api_version          IN            NUMBER,
           p_init_msg_list        IN            VARCHAR2,
           p_commit               IN            VARCHAR2,
           p_validation_level     IN            NUMBER,
           x_return_status        OUT NOCOPY    VARCHAR2,
           x_msg_count            OUT NOCOPY    NUMBER ,
           x_msg_data             OUT NOCOPY    VARCHAR2,
           p_application_id       IN            NUMBER,
           p_entity_code          IN            VARCHAR2,
           p_event_class_code     IN            VARCHAR2,
           p_country_code         IN            VARCHAR2,
           p_item_id              IN            NUMBER,
           p_org_id               IN            NUMBER,
           x_product_type         OUT NOCOPY    VARCHAR2
       );

/* ======================================================================*
 | PROCEDURE get_default_tax_classification: Default tax classification  |
 * ======================================================================*/
       PROCEDURE redef_tax_classification_code
       (
    	   p_api_version                  IN               NUMBER,
           p_init_msg_list                IN               VARCHAR2,
           p_commit                       IN               VARCHAR2,
           p_validation_level             IN               NUMBER,
           x_msg_count                    OUT    NOCOPY    NUMBER ,
           x_msg_data                     OUT    NOCOPY    VARCHAR2,
           x_return_status                OUT    NOCOPY    VARCHAR2,
    	   p_redef_tax_cls_code_info_rec  IN OUT NOCOPY    def_tax_cls_code_info_rec_type
       );


/* =========================================================================*
 | PROCEDURE purge_tax_repository: Purges the transaction lines and tax data|
 * ========================================================================*/
       PROCEDURE purge_tax_repository
       (
    	   p_api_version                  IN               NUMBER,
           p_init_msg_list                IN               VARCHAR2,
           p_commit                       IN               VARCHAR2,
           p_validation_level             IN               NUMBER,
           x_msg_count                    OUT    NOCOPY    NUMBER ,
           x_msg_data                     OUT    NOCOPY    VARCHAR2,
           x_return_status                OUT    NOCOPY    VARCHAR2
       );

/* ======================================================================*
 | API TO GET  LE FOR AP IMPORT TRANSACTIONS                             |
 * ======================================================================*/
       FUNCTION get_le_from_tax_registration
       (
          p_api_version       IN         NUMBER,
          p_init_msg_list     IN         VARCHAR2,
          p_commit            IN         VARCHAR2,
          p_validation_level  IN         NUMBER,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2,
          p_registration_num  IN         ZX_REGISTRATIONS.Registration_Number%type,
          p_effective_date    IN         ZX_REGISTRATIONS.effective_from%type,
          p_country           IN         ZX_PARTY_TAX_PROFILE.Country_code%type
       ) RETURN Number;

/* ===================================================================================*
 | PROCEDURE Update_posting_flag : Updates posting flag of a list of Tax Distributions |
 |                                 from the product passed in PL/SQL table             |
 * ====================================================================================*/

        PROCEDURE update_posting_flag
        (
	   p_api_version           IN         NUMBER,
           p_init_msg_list         IN         VARCHAR2,
           p_commit                IN         VARCHAR2,
           p_validation_level      IN         NUMBER,
           x_return_status         OUT NOCOPY VARCHAR2,
           x_msg_count             OUT NOCOPY NUMBER,
           x_msg_data              OUT NOCOPY VARCHAR2,
           p_tax_dist_id_tbl       IN  tax_dist_id_tbl_type
    	);

/* ===================================================================================*
 | PROCEDURE unapply_applied_cm : Null out the adjusted doc information on both        |
 | zx_lines and zx_lines_det_factors                                                   |
 * ====================================================================================*/

  PROCEDURE unapply_applied_cm
   ( p_api_version           IN            NUMBER,
     p_init_msg_list         IN            VARCHAR2,
     p_commit                IN            VARCHAR2,
     p_validation_level      IN            NUMBER,
     p_trx_id                IN            NUMBER,
     x_return_status         OUT NOCOPY    VARCHAR2,
     x_msg_count             OUT NOCOPY    NUMBER,
     x_msg_data              OUT NOCOPY    VARCHAR2
    );

END ZX_API_PUB;


/
