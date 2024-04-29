--------------------------------------------------------
--  DDL for Package ZX_GLOBAL_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_GLOBAL_STRUCTURES_PKG" AUTHID CURRENT_USER AS
/* $Header: zxifgblparampkgs.pls 120.89.12010000.13 2011/01/18 12:03:19 snoothi ship $ */

/* ======================================================================*
 | Global Structure Data Types                                           |
 * ======================================================================*/

TYPE NUMBER_tbl_type            IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE DATE_tbl_type              IS TABLE OF DATE           INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_1_tbl_type        IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2_tbl_type        IS TABLE OF VARCHAR2(2)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_15_tbl_type       IS TABLE OF VARCHAR2(15)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_20_tbl_type       IS TABLE OF VARCHAR2(20)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_tbl_type       IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_40_tbl_type       IS TABLE OF VARCHAR2(40)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_50_tbl_type       IS TABLE OF VARCHAR2(50)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_80_tbl_type       IS TABLE OF VARCHAR2(80)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_150_tbl_type      IS TABLE OF VARCHAR2(150)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_240_tbl_type      IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_250_tbl_type      IS TABLE OF VARCHAR2(250)  INDEX BY BINARY_INTEGER;
--Bug 10384862 starts
TYPE VARCHAR2_300_tbl_type      IS TABLE OF VARCHAR2(300)  INDEX BY BINARY_INTEGER;
--Bug 10384862 ends
TYPE VARCHAR2_360_tbl_type      IS TABLE OF VARCHAR2(360)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2000_tbl_type     IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

 -- The following record structure is used to cache information in zx_evnt_cls_mappings
 -- The information in the structure is valid throughout the session.
TYPE ZX_EVENT_CLASS_RECTYPE is RECORD
(EVENT_CLASS_CODE               zx_evnt_cls_mappings.EVENT_CLASS_CODE%type,
 APPLICATION_ID                 zx_evnt_cls_mappings.APPLICATION_ID%type,
 ENTITY_CODE                    zx_evnt_cls_mappings.ENTITY_CODE%type,
 TAX_EVENT_CLASS_CODE           zx_evnt_cls_mappings.TAX_EVENT_CLASS_CODE%type,
 RECORD_FLAG                    zx_evnt_cls_mappings.RECORD_FLAG%type,
 DET_FACTOR_TEMPL_CODE          zx_evnt_cls_mappings.DET_FACTOR_TEMPL_CODE%type,
 DEFAULT_ROUNDING_LEVEL_CODE    zx_evnt_cls_mappings.DEFAULT_ROUNDING_LEVEL_CODE%type,
 ROUNDING_LEVEL_HIER_1_CODE     zx_evnt_cls_mappings.ROUNDING_LEVEL_HIER_1_CODE%type,
 ROUNDING_LEVEL_HIER_2_CODE     zx_evnt_cls_mappings.ROUNDING_LEVEL_HIER_2_CODE%type,
 ROUNDING_LEVEL_HIER_3_CODE     zx_evnt_cls_mappings.ROUNDING_LEVEL_HIER_3_CODE%type,
 ROUNDING_LEVEL_HIER_4_CODE     zx_evnt_cls_mappings.ROUNDING_LEVEL_HIER_4_CODE%type,
 ALLOW_MANUAL_LIN_RECALC_FLAG   zx_evnt_cls_mappings.ALLOW_MANUAL_LIN_RECALC_FLAG%type,
 ALLOW_OVERRIDE_FLAG            zx_evnt_cls_mappings.ALLOW_OVERRIDE_FLAG%type,
 ALLOW_MANUAL_LINES_FLAG        zx_evnt_cls_mappings.ALLOW_MANUAL_LINES_FLAG%type,
 PERF_ADDNL_APPL_FOR_IMPRT_FLAG zx_evnt_cls_mappings.PERF_ADDNL_APPL_FOR_IMPRT_FLAG%type,
 SHIP_TO_PARTY_TYPE             zx_evnt_cls_mappings.SHIP_TO_PARTY_TYPE%type,
 SHIP_FROM_PARTY_TYPE           zx_evnt_cls_mappings.SHIP_FROM_PARTY_TYPE%type,
 POA_PARTY_TYPE                 zx_evnt_cls_mappings.POA_PARTY_TYPE%type,
 POO_PARTY_TYPE                 zx_evnt_cls_mappings.POO_PARTY_TYPE%type,
 PAYING_PARTY_TYPE              zx_evnt_cls_mappings.PAYING_PARTY_TYPE%type,
 OWN_HQ_PARTY_TYPE              zx_evnt_cls_mappings.OWN_HQ_PARTY_TYPE%type,
 TRAD_HQ_PARTY_TYPE             zx_evnt_cls_mappings.TRAD_HQ_PARTY_TYPE%type,
 POI_PARTY_TYPE                 zx_evnt_cls_mappings.POI_PARTY_TYPE%type,
 POD_PARTY_TYPE                 zx_evnt_cls_mappings.POD_PARTY_TYPE%type,
 BILL_TO_PARTY_TYPE             zx_evnt_cls_mappings.BILL_TO_PARTY_TYPE%type,
 BILL_FROM_PARTY_TYPE           zx_evnt_cls_mappings.BILL_FROM_PARTY_TYPE%type,
 TTL_TRNS_PARTY_TYPE            zx_evnt_cls_mappings.TTL_TRNS_PARTY_TYPE%type,
 MERCHANT_PARTY_TYPE            zx_evnt_cls_mappings.MERCHANT_PARTY_TYPE%type,
 SHIP_TO_PTY_SITE_TYPE          zx_evnt_cls_mappings.SHIP_TO_PTY_SITE_TYPE%type,
 SHIP_FROM_PTY_SITE_TYPE        zx_evnt_cls_mappings.SHIP_FROM_PTY_SITE_TYPE%type,
 POA_PTY_SITE_TYPE              zx_evnt_cls_mappings.POA_PTY_SITE_TYPE%type,
 POO_PTY_SITE_TYPE              zx_evnt_cls_mappings.POO_PTY_SITE_TYPE%type,
 PAYING_PTY_SITE_TYPE           zx_evnt_cls_mappings.PAYING_PTY_SITE_TYPE%type,
 OWN_HQ_PTY_SITE_TYPE           zx_evnt_cls_mappings.OWN_HQ_PTY_SITE_TYPE%type,
 TRAD_HQ_PTY_SITE_TYPE          zx_evnt_cls_mappings.TRAD_HQ_PTY_SITE_TYPE%type,
 POI_PTY_SITE_TYPE              zx_evnt_cls_mappings.POI_PTY_SITE_TYPE%type,
 POD_PTY_SITE_TYPE              zx_evnt_cls_mappings.POD_PTY_SITE_TYPE%type,
 BILL_TO_PTY_SITE_TYPE          zx_evnt_cls_mappings.BILL_TO_PTY_SITE_TYPE%type,
 BILL_FROM_PTY_SITE_TYPE        zx_evnt_cls_mappings.BILL_FROM_PTY_SITE_TYPE%type,
 TTL_TRNS_PTY_SITE_TYPE         zx_evnt_cls_mappings.TTL_TRNS_PTY_SITE_TYPE%type,
 ENFORCE_TAX_FROM_ACCT_FLAG     zx_evnt_cls_mappings.ENFORCE_TAX_FROM_ACCT_FLAG%type,
 OFFSET_TAX_BASIS_CODE          zx_evnt_cls_mappings.OFFSET_TAX_BASIS_CODE%type,
 REFERENCE_APPLICATION_ID       zx_evnt_cls_mappings.REFERENCE_APPLICATION_ID%type,
 PROD_FAMILY_GRP_CODE           zx_evnt_cls_mappings.PROD_FAMILY_GRP_CODE%type,
 ALLOW_OFFSET_TAX_CALC_FLAG     zx_evnt_cls_mappings.ALLOW_OFFSET_TAX_CALC_FLAG%type,
 SELF_ASSESS_TAX_LINES_FLAG     zx_evnt_cls_mappings.SELF_ASSESS_TAX_LINES_FLAG%type,
 TAX_RECOVERY_FLAG              zx_evnt_cls_mappings.TAX_RECOVERY_FLAG%type,
 ALLOW_CANCEL_TAX_LINES_FLAG    zx_evnt_cls_mappings.ALLOW_CANCEL_TAX_LINES_FLAG%type,
 ALLOW_MAN_TAX_ONLY_LINES_FLAG  zx_evnt_cls_mappings.ALLOW_MAN_TAX_ONLY_LINES_FLAG%type,
 TAX_VARIANCE_CALC_FLAG         zx_evnt_cls_mappings.TAX_VARIANCE_CALC_FLAG%type,
 TAX_REPORTING_FLAG             zx_evnt_cls_mappings.TAX_REPORTING_FLAG%type,
 ENTER_OVRD_INCL_TAX_LINES_FLAG zx_evnt_cls_mappings.ENTER_OVRD_INCL_TAX_LINES_FLAG%type,
 CTRL_EFF_OVRD_CALC_LINES_FLAG  zx_evnt_cls_mappings.CTRL_EFF_OVRD_CALC_LINES_FLAG%type,
 SUMMARIZATION_FLAG             zx_evnt_cls_mappings.SUMMARIZATION_FLAG%type,
 RETAIN_SUMM_TAX_LINE_ID_FLAG   zx_evnt_cls_mappings.RETAIN_SUMM_TAX_LINE_ID_FLAG%type,
 RECORD_FOR_PARTNERS_FLAG       zx_evnt_cls_mappings.RECORD_FOR_PARTNERS_FLAG%type,
 MANUAL_LINES_FOR_PARTNER_FLAG  zx_evnt_cls_mappings.MANUAL_LINES_FOR_PARTNER_FLAG%type,
 MAN_TAX_ONLY_LIN_FOR_PTNR_FLAG zx_evnt_cls_mappings.MAN_TAX_ONLY_LIN_FOR_PTNR_FLAG%type,
 ALWAYS_USE_EBTAX_FOR_CALC_FLAG zx_evnt_cls_mappings.ALWAYS_USE_EBTAX_FOR_CALC_FLAG%type,
 PROCESSING_PRECEDENCE          zx_evnt_cls_mappings.PROCESSING_PRECEDENCE%type,
 EVENT_CLASS_MAPPING_ID         zx_evnt_cls_mappings.EVENT_CLASS_MAPPING_ID%type,
 ENFORCE_TAX_FROM_REF_DOC_FLAG  zx_evnt_cls_mappings.ENFORCE_TAX_FROM_REF_DOC_FLAG%type,
 PROCESS_FOR_APPLICABILITY_FLAG zx_evnt_cls_mappings.PROCESS_FOR_APPLICABILITY_FLAG%type,
 SUP_CUST_ACCT_TYPE_CODE        zx_evnt_cls_mappings.SUP_CUST_ACCT_TYPE_CODE%type,
 DISPLAY_TAX_CLASSIF_FLAG       zx_evnt_cls_mappings.DISPLAY_TAX_CLASSIF_FLAG%type,
 INTGRTN_DET_FACTORS_UI_FLAG    zx_evnt_cls_mappings.INTGRTN_DET_FACTORS_UI_FLAG%type,
 INTRCMP_TX_EVNT_CLS_CODE       zx_evnt_cls_mappings.INTRCMP_TX_EVNT_CLS_CODE%type,
 INTRCMP_SRC_ENTITY_CODE        zx_evnt_cls_mappings.INTRCMP_SRC_ENTITY_CODE%type,
 INTRCMP_SRC_EVNT_CLS_CODE      zx_evnt_cls_mappings.INTRCMP_SRC_EVNT_CLS_CODE%type,
 INTRCMP_SRC_APPLN_ID           zx_evnt_cls_mappings.INTRCMP_SRC_APPLN_ID%type,
 ALLOW_EXEMPTIONS_FLAG          zx_evnt_cls_mappings.ALLOW_EXEMPTIONS_FLAG%TYPE,
 ENABLE_MRC_FLAG		zx_evnt_cls_mappings.ENABLE_MRC_FLAG%TYPE);

 TYPE ZX_EVENT_CLASS_REC_TBLTYPE is TABLE of ZX_EVENT_CLASS_RECTYPE
 index by binary_integer;

 -- The following record structure is used to cache information in zx_evnt_typ_mappings
 -- The information in the structure is valid throughout the session.

 TYPE EVNT_TYP_MAP_RECTYPE is RECORD
 (EVENT_CLASS_MAPPING_ID  zx_evnt_typ_mappings.EVENT_CLASS_MAPPING_ID%type,
 EVENT_TYPE_MAPPING_ID   zx_evnt_typ_mappings.EVENT_TYPE_MAPPING_ID%type,
 EVENT_CLASS_CODE        zx_evnt_typ_mappings.EVENT_CLASS_CODE%type,
 EVENT_TYPE_CODE         zx_evnt_typ_mappings.EVENT_TYPE_CODE%type,
 APPLICATION_ID          zx_evnt_typ_mappings.APPLICATION_ID%type,
 ENTITY_CODE             zx_evnt_typ_mappings.ENTITY_CODE%type,
 TAX_EVENT_CLASS_CODE    zx_evnt_typ_mappings.TAX_EVENT_CLASS_CODE%type,
 TAX_EVENT_TYPE_CODE     zx_evnt_typ_mappings.TAX_EVENT_TYPE_CODE%type,
 ENABLED_FLAG            zx_evnt_typ_mappings.ENABLED_FLAG%type);

 TYPE  EVNT_TYP_MAP_TBLTYPE is table of  EVNT_TYP_MAP_RECTYPE
 index by BINARY_INTEGER;


 TYPE TAX_EVENT_CLS_INFO_RECTYPE is RECORD
 (TAX_EVENT_CLASS_CODE          ZX_EVENT_CLASSES_B.TAX_EVENT_CLASS_CODE%type,
  NORMAL_SIGN_FLAG              ZX_EVENT_CLASSES_B.NORMAL_SIGN_FLAG%type,
  ASC_INTRCMP_TX_EVNT_CLS_CODE  ZX_EVENT_CLASSES_B.ASC_INTRCMP_TX_EVNT_CLS_CODE%type);

 TYPE TAX_EVENT_CLS_INFO_TBLTYPE is TABLE of TAX_EVENT_CLS_INFO_RECTYPE
  index by VARCHAR2(30);

TYPE trx_line_dist_rec_type IS RECORD
(
INTERNAL_ORGANIZATION_ID             NUMBER_tbl_type        ,
APPLICATION_ID                       NUMBER_tbl_type        ,
ENTITY_CODE                          VARCHAR2_30_tbl_type   ,
EVENT_CLASS_CODE                     VARCHAR2_30_tbl_type   ,
EVENT_TYPE_CODE                      VARCHAR2_30_tbl_type   ,
TRX_ID                               NUMBER_tbl_type        ,
TRX_LEVEL_TYPE                       VARCHAR2_30_tbl_type   ,
TRX_LINE_ID                          NUMBER_tbl_type        ,
LINE_LEVEL_ACTION                    VARCHAR2_30_tbl_type   ,
LINE_CLASS                           VARCHAR2_30_tbl_type   ,
TRX_DATE                             DATE_tbl_type          ,
TRX_DOC_REVISION                     VARCHAR2_150_tbl_type  ,
LEDGER_ID                            NUMBER_tbl_type        ,
TRX_CURRENCY_CODE                    VARCHAR2_15_tbl_type   ,
CURRENCY_CONVERSION_DATE             DATE_tbl_type          ,
CURRENCY_CONVERSION_RATE             NUMBER_tbl_type        ,
CURRENCY_CONVERSION_TYPE             VARCHAR2_30_tbl_type   ,
MINIMUM_ACCOUNTABLE_UNIT             NUMBER_tbl_type        ,
PRECISION                            NUMBER_tbl_type        ,
TRX_LINE_CURRENCY_CODE               VARCHAR2_15_tbl_type   ,
TRX_LINE_CURRENCY_CONV_DATE          DATE_tbl_type          ,
TRX_LINE_CURRENCY_CONV_RATE          NUMBER_tbl_type        ,
TRX_LINE_CURRENCY_CONV_TYPE          VARCHAR2_30_tbl_type   ,
TRX_LINE_MAU                         NUMBER_tbl_type        ,
TRX_LINE_PRECISION                   NUMBER_tbl_type        ,
TRX_SHIPPING_DATE                    DATE_tbl_type          ,
TRX_RECEIPT_DATE                     DATE_tbl_type          ,
LEGAL_ENTITY_ID                      NUMBER_tbl_type        ,
ROUNDING_SHIP_TO_PARTY_ID            NUMBER_tbl_type        ,
ROUNDING_SHIP_FROM_PARTY_ID          NUMBER_tbl_type        ,
ROUNDING_BILL_TO_PARTY_ID            NUMBER_tbl_type        ,
ROUNDING_BILL_FROM_PARTY_ID          NUMBER_tbl_type        ,
RNDG_SHIP_TO_PARTY_SITE_ID           NUMBER_tbl_type        ,
RNDG_SHIP_FROM_PARTY_SITE_ID         NUMBER_tbl_type        ,
RNDG_BILL_TO_PARTY_SITE_ID           NUMBER_tbl_type        ,
RNDG_BILL_FROM_PARTY_SITE_ID         NUMBER_tbl_type        ,
ESTABLISHMENT_ID                     NUMBER_tbl_type        ,
TRX_LINE_TYPE                        VARCHAR2_30_tbl_type   ,
TRX_LINE_DATE                        DATE_tbl_type          ,
TRX_BUSINESS_CATEGORY                VARCHAR2_240_tbl_type  ,
LINE_INTENDED_USE                    VARCHAR2_240_tbl_type  ,
USER_DEFINED_FISC_CLASS              VARCHAR2_30_tbl_type   ,
LINE_AMT                             NUMBER_tbl_type        ,
TRX_LINE_QUANTITY                    NUMBER_tbl_type        ,
UNIT_PRICE                           NUMBER_tbl_type        ,
EXEMPT_CERTIFICATE_NUMBER            VARCHAR2_80_tbl_type   ,
EXEMPT_REASON                        VARCHAR2_240_tbl_type  ,
CASH_DISCOUNT                        NUMBER_tbl_type        ,
VOLUME_DISCOUNT                      NUMBER_tbl_type        ,
TRADING_DISCOUNT                     NUMBER_tbl_type        ,
TRANSFER_CHARGE                      NUMBER_tbl_type        ,
TRANSPORTATION_CHARGE                NUMBER_tbl_type        ,
INSURANCE_CHARGE                     NUMBER_tbl_type        ,
OTHER_CHARGE                         NUMBER_tbl_type        ,
PRODUCT_ID                           NUMBER_tbl_type        ,
PRODUCT_FISC_CLASSIFICATION          VARCHAR2_240_tbl_type  ,
PRODUCT_ORG_ID                       NUMBER_tbl_type        ,
UOM_CODE                             VARCHAR2_30_tbl_type   ,
PRODUCT_TYPE                         VARCHAR2_240_tbl_type  ,
--Bug 10384862 starts
PRODUCT_CODE                         VARCHAR2_300_tbl_type  ,
--Bug 10384862 ends
PRODUCT_CATEGORY                     VARCHAR2_240_tbl_type  ,
TRX_SIC_CODE                         VARCHAR2_150_tbl_type  ,
FOB_POINT                            VARCHAR2_30_tbl_type   ,
SHIP_TO_PARTY_ID                     NUMBER_tbl_type        ,
SHIP_FROM_PARTY_ID                   NUMBER_tbl_type        ,
POA_PARTY_ID                         NUMBER_tbl_type        ,
POO_PARTY_ID                         NUMBER_tbl_type        ,
BILL_TO_PARTY_ID                     NUMBER_tbl_type        ,
BILL_FROM_PARTY_ID                   NUMBER_tbl_type        ,
MERCHANT_PARTY_ID                    NUMBER_tbl_type        ,
SHIP_TO_PARTY_SITE_ID                NUMBER_tbl_type        ,
SHIP_FROM_PARTY_SITE_ID              NUMBER_tbl_type        ,
POA_PARTY_SITE_ID                    NUMBER_tbl_type        ,
POO_PARTY_SITE_ID                    NUMBER_tbl_type        ,
BILL_TO_PARTY_SITE_ID                NUMBER_tbl_type        ,
BILL_FROM_PARTY_SITE_ID              NUMBER_tbl_type        ,
SHIP_TO_LOCATION_ID                  NUMBER_tbl_type        ,
SHIP_FROM_LOCATION_ID                NUMBER_tbl_type        ,
POA_LOCATION_ID                      NUMBER_tbl_type        ,
POO_LOCATION_ID                      NUMBER_tbl_type        ,
BILL_TO_LOCATION_ID                  NUMBER_tbl_type        ,
BILL_FROM_LOCATION_ID                NUMBER_tbl_type        ,
ACCOUNT_CCID                         NUMBER_tbl_type        ,
ACCOUNT_STRING                       VARCHAR2_2000_tbl_type ,
MERCHANT_PARTY_COUNTRY               VARCHAR2_150_tbl_type  ,
RECEIVABLES_TRX_TYPE_ID              NUMBER_tbl_type        ,
REF_DOC_APPLICATION_ID               NUMBER_tbl_type        ,
REF_DOC_ENTITY_CODE                  VARCHAR2_30_tbl_type   ,
REF_DOC_EVENT_CLASS_CODE             VARCHAR2_30_tbl_type   ,
REF_DOC_TRX_ID                       NUMBER_tbl_type        ,
REF_DOC_HDR_TRX_USER_KEY1            VARCHAR2_150_tbl_type  ,
REF_DOC_HDR_TRX_USER_KEY2            VARCHAR2_150_tbl_type  ,
REF_DOC_HDR_TRX_USER_KEY3            VARCHAR2_150_tbl_type  ,
REF_DOC_HDR_TRX_USER_KEY4            VARCHAR2_150_tbl_type  ,
REF_DOC_HDR_TRX_USER_KEY5            VARCHAR2_150_tbl_type  ,
REF_DOC_HDR_TRX_USER_KEY6            VARCHAR2_150_tbl_type  ,
REF_DOC_LINE_ID                      NUMBER_tbl_type        ,
REF_DOC_LIN_TRX_USER_KEY1            VARCHAR2_150_tbl_type  ,
REF_DOC_LIN_TRX_USER_KEY2            VARCHAR2_150_tbl_type  ,
REF_DOC_LIN_TRX_USER_KEY3            VARCHAR2_150_tbl_type  ,
REF_DOC_LIN_TRX_USER_KEY4            VARCHAR2_150_tbl_type  ,
REF_DOC_LIN_TRX_USER_KEY5            VARCHAR2_150_tbl_type  ,
REF_DOC_LIN_TRX_USER_KEY6            VARCHAR2_150_tbl_type  ,
REF_DOC_LINE_QUANTITY                NUMBER_tbl_type        ,
RELATED_DOC_APPLICATION_ID           NUMBER_tbl_type        ,
RELATED_DOC_ENTITY_CODE              VARCHAR2_30_tbl_type   ,
RELATED_DOC_EVENT_CLASS_CODE         VARCHAR2_30_tbl_type   ,
RELATED_DOC_TRX_ID                   NUMBER_tbl_type        ,
REL_DOC_HDR_TRX_USER_KEY1            VARCHAR2_150_tbl_type  ,
REL_DOC_HDR_TRX_USER_KEY2            VARCHAR2_150_tbl_type  ,
REL_DOC_HDR_TRX_USER_KEY3            VARCHAR2_150_tbl_type  ,
REL_DOC_HDR_TRX_USER_KEY4            VARCHAR2_150_tbl_type  ,
REL_DOC_HDR_TRX_USER_KEY5            VARCHAR2_150_tbl_type  ,
REL_DOC_HDR_TRX_USER_KEY6            VARCHAR2_150_tbl_type  ,
RELATED_DOC_NUMBER                   VARCHAR2_150_tbl_type  ,
RELATED_DOC_DATE                     DATE_tbl_type          ,
APPLIED_FROM_APPLICATION_ID          NUMBER_tbl_type        ,
APPLIED_FROM_ENTITY_CODE             VARCHAR2_30_tbl_type   ,
APPLIED_FROM_EVENT_CLASS_CODE        VARCHAR2_30_tbl_type   ,
APPLIED_FROM_TRX_ID                  NUMBER_tbl_type        ,
APP_FROM_HDR_TRX_USER_KEY1           VARCHAR2_150_tbl_type  ,
APP_FROM_HDR_TRX_USER_KEY2           VARCHAR2_150_tbl_type  ,
APP_FROM_HDR_TRX_USER_KEY3           VARCHAR2_150_tbl_type  ,
APP_FROM_HDR_TRX_USER_KEY4           VARCHAR2_150_tbl_type  ,
APP_FROM_HDR_TRX_USER_KEY5           VARCHAR2_150_tbl_type  ,
APP_FROM_HDR_TRX_USER_KEY6           VARCHAR2_150_tbl_type  ,
APPLIED_FROM_LINE_ID                 NUMBER_tbl_type        ,
APPLIED_FROM_TRX_NUMBER              VARCHAR2_150_tbl_type  ,
APP_FROM_LIN_TRX_USER_KEY1           VARCHAR2_150_tbl_type  ,
APP_FROM_LIN_TRX_USER_KEY2           VARCHAR2_150_tbl_type  ,
APP_FROM_LIN_TRX_USER_KEY3           VARCHAR2_150_tbl_type  ,
APP_FROM_LIN_TRX_USER_KEY4           VARCHAR2_150_tbl_type  ,
APP_FROM_LIN_TRX_USER_KEY5           VARCHAR2_150_tbl_type  ,
APP_FROM_LIN_TRX_USER_KEY6           VARCHAR2_150_tbl_type  ,
ADJUSTED_DOC_APPLICATION_ID          NUMBER_tbl_type        ,
ADJUSTED_DOC_ENTITY_CODE             VARCHAR2_30_tbl_type   ,
ADJUSTED_DOC_EVENT_CLASS_CODE        VARCHAR2_30_tbl_type   ,
ADJUSTED_DOC_TRX_ID                  NUMBER_tbl_type        ,
ADJ_DOC_HDR_TRX_USER_KEY1            VARCHAR2_150_tbl_type  ,
ADJ_DOC_HDR_TRX_USER_KEY2            VARCHAR2_150_tbl_type  ,
ADJ_DOC_HDR_TRX_USER_KEY3            VARCHAR2_150_tbl_type  ,
ADJ_DOC_HDR_TRX_USER_KEY4            VARCHAR2_150_tbl_type  ,
ADJ_DOC_HDR_TRX_USER_KEY5            VARCHAR2_150_tbl_type  ,
ADJ_DOC_HDR_TRX_USER_KEY6            VARCHAR2_150_tbl_type  ,
ADJUSTED_DOC_LINE_ID                 NUMBER_tbl_type        ,
ADJ_DOC_LIN_TRX_USER_KEY1            VARCHAR2_150_tbl_type  ,
ADJ_DOC_LIN_TRX_USER_KEY2            VARCHAR2_150_tbl_type  ,
ADJ_DOC_LIN_TRX_USER_KEY3            VARCHAR2_150_tbl_type  ,
ADJ_DOC_LIN_TRX_USER_KEY4            VARCHAR2_150_tbl_type  ,
ADJ_DOC_LIN_TRX_USER_KEY5            VARCHAR2_150_tbl_type  ,
ADJ_DOC_LIN_TRX_USER_KEY6            VARCHAR2_150_tbl_type  ,
ADJUSTED_DOC_NUMBER                  VARCHAR2_150_tbl_type  ,
ADJUSTED_DOC_DATE                    DATE_tbl_type          ,
APPLIED_TO_APPLICATION_ID            NUMBER_tbl_type        ,
APPLIED_TO_ENTITY_CODE               VARCHAR2_30_tbl_type   ,
APPLIED_TO_EVENT_CLASS_CODE          VARCHAR2_30_tbl_type   ,
APPLIED_TO_TRX_ID                    NUMBER_tbl_type        ,
APP_TO_HDR_TRX_USER_KEY1             VARCHAR2_150_tbl_type  ,
APP_TO_HDR_TRX_USER_KEY2             VARCHAR2_150_tbl_type  ,
APP_TO_HDR_TRX_USER_KEY3             VARCHAR2_150_tbl_type  ,
APP_TO_HDR_TRX_USER_KEY4             VARCHAR2_150_tbl_type  ,
APP_TO_HDR_TRX_USER_KEY5             VARCHAR2_150_tbl_type  ,
APP_TO_HDR_TRX_USER_KEY6             VARCHAR2_150_tbl_type  ,
APPLIED_TO_TRX_LINE_ID               NUMBER_tbl_type        ,
APP_TO_LIN_TRX_USER_KEY1             VARCHAR2_150_tbl_type  ,
APP_TO_LIN_TRX_USER_KEY2             VARCHAR2_150_tbl_type  ,
APP_TO_LIN_TRX_USER_KEY3             VARCHAR2_150_tbl_type  ,
APP_TO_LIN_TRX_USER_KEY4             VARCHAR2_150_tbl_type  ,
APP_TO_LIN_TRX_USER_KEY5             VARCHAR2_150_tbl_type  ,
APP_TO_LIN_TRX_USER_KEY6             VARCHAR2_150_tbl_type  ,
TRX_ID_LEVEL2                        NUMBER_tbl_type        ,
TRX_ID_LEVEL3                        NUMBER_tbl_type        ,
TRX_ID_LEVEL4                        NUMBER_tbl_type        ,
TRX_ID_LEVEL5                        NUMBER_tbl_type        ,
TRX_ID_LEVEL6                        NUMBER_tbl_type        ,
HDR_TRX_USER_KEY1                    VARCHAR2_150_tbl_type  ,
HDR_TRX_USER_KEY2                    VARCHAR2_150_tbl_type  ,
HDR_TRX_USER_KEY3                    VARCHAR2_150_tbl_type  ,
HDR_TRX_USER_KEY4                    VARCHAR2_150_tbl_type  ,
HDR_TRX_USER_KEY5                    VARCHAR2_150_tbl_type  ,
HDR_TRX_USER_KEY6                    VARCHAR2_150_tbl_type  ,
LINE_TRX_USER_KEY1                   VARCHAR2_150_tbl_type  ,
LINE_TRX_USER_KEY2                   VARCHAR2_150_tbl_type  ,
LINE_TRX_USER_KEY3                   VARCHAR2_150_tbl_type  ,
LINE_TRX_USER_KEY4                   VARCHAR2_150_tbl_type  ,
LINE_TRX_USER_KEY5                   VARCHAR2_150_tbl_type  ,
LINE_TRX_USER_KEY6                   VARCHAR2_150_tbl_type  ,
TRX_NUMBER                           VARCHAR2_150_tbl_type  ,
TRX_DESCRIPTION                      VARCHAR2_240_tbl_type  ,
TRX_LINE_NUMBER                      NUMBER_tbl_type        ,
TRX_LINE_DESCRIPTION                 VARCHAR2_240_tbl_type  ,
PRODUCT_DESCRIPTION                  VARCHAR2_240_tbl_type  ,
TRX_WAYBILL_NUMBER                   VARCHAR2_50_tbl_type   ,
TRX_COMMUNICATED_DATE                DATE_tbl_type          ,
TRX_LINE_GL_DATE                     DATE_tbl_type          ,
BATCH_SOURCE_ID                      NUMBER_tbl_type        ,
BATCH_SOURCE_NAME                    VARCHAR2_150_tbl_type  ,
DOC_SEQ_ID                           NUMBER_tbl_type        ,
DOC_SEQ_NAME                         VARCHAR2_150_tbl_type  ,
DOC_SEQ_VALUE                        VARCHAR2_240_tbl_type  ,
TRX_DUE_DATE                         DATE_tbl_type          ,
TRX_TYPE_DESCRIPTION                 VARCHAR2_240_tbl_type  ,
MERCHANT_PARTY_NAME                  VARCHAR2_150_tbl_type  ,
MERCHANT_PARTY_DOCUMENT_NUMBER       VARCHAR2_150_tbl_type  ,
MERCHANT_PARTY_REFERENCE             VARCHAR2_250_tbl_type  ,
MERCHANT_PARTY_TAXPAYER_ID           VARCHAR2_150_tbl_type  ,
MERCHANT_PARTY_TAX_REG_NUMBER        VARCHAR2_150_tbl_type  ,
PAYING_PARTY_ID                      NUMBER_tbl_type        ,
OWN_HQ_PARTY_ID                      NUMBER_tbl_type        ,
TRADING_HQ_PARTY_ID                  NUMBER_tbl_type        ,
POI_PARTY_ID                         NUMBER_tbl_type        ,
POD_PARTY_ID                         NUMBER_tbl_type        ,
TITLE_TRANSFER_PARTY_ID              NUMBER_tbl_type        ,
PAYING_PARTY_SITE_ID                 NUMBER_tbl_type        ,
OWN_HQ_PARTY_SITE_ID                 NUMBER_tbl_type        ,
TRADING_HQ_PARTY_SITE_ID             NUMBER_tbl_type        ,
POI_PARTY_SITE_ID                    NUMBER_tbl_type        ,
POD_PARTY_SITE_ID                    NUMBER_tbl_type        ,
TITLE_TRANSFER_PARTY_SITE_ID         NUMBER_tbl_type        ,
PAYING_LOCATION_ID                   NUMBER_tbl_type        ,
OWN_HQ_LOCATION_ID                   NUMBER_tbl_type        ,
TRADING_HQ_LOCATION_ID               NUMBER_tbl_type        ,
POC_LOCATION_ID                      NUMBER_tbl_type        ,
POI_LOCATION_ID                      NUMBER_tbl_type        ,
POD_LOCATION_ID                      NUMBER_tbl_type        ,
TITLE_TRANSFER_LOCATION_ID           NUMBER_tbl_type        ,
ASSESSABLE_VALUE                     NUMBER_tbl_type        ,
ASSET_FLAG                           VARCHAR2_1_tbl_type    ,
ASSET_NUMBER                         VARCHAR2_150_tbl_type  ,
ASSET_ACCUM_DEPRECIATION             NUMBER_tbl_type        ,
ASSET_TYPE                           VARCHAR2_150_tbl_type  ,
ASSET_COST                           NUMBER_tbl_type        ,
NUMERIC1                             NUMBER_tbl_type        ,
NUMERIC2                             NUMBER_tbl_type        ,
NUMERIC3                             NUMBER_tbl_type        ,
NUMERIC4                             NUMBER_tbl_type        ,
NUMERIC5                             NUMBER_tbl_type        ,
NUMERIC6                             NUMBER_tbl_type        ,
NUMERIC7                             NUMBER_tbl_type        ,
NUMERIC8                             NUMBER_tbl_type        ,
NUMERIC9                             NUMBER_tbl_type        ,
NUMERIC10                            NUMBER_tbl_type        ,
CHAR1                                VARCHAR2_150_tbl_type  ,
CHAR2                                VARCHAR2_150_tbl_type  ,
CHAR3                                VARCHAR2_150_tbl_type  ,
CHAR4                                VARCHAR2_150_tbl_type  ,
CHAR5                                VARCHAR2_150_tbl_type  ,
CHAR6                                VARCHAR2_150_tbl_type  ,
CHAR7                                VARCHAR2_150_tbl_type  ,
CHAR8                                VARCHAR2_150_tbl_type  ,
CHAR9                                VARCHAR2_150_tbl_type  ,
CHAR10                               VARCHAR2_150_tbl_type  ,
DATE1                                DATE_tbl_type          ,
DATE2                                DATE_tbl_type          ,
DATE3                                DATE_tbl_type          ,
DATE4                                DATE_tbl_type          ,
DATE5                                DATE_tbl_type          ,
DATE6                                DATE_tbl_type          ,
DATE7                                DATE_tbl_type          ,
DATE8                                DATE_tbl_type          ,
DATE9                                DATE_tbl_type          ,
DATE10                               DATE_tbl_type          ,
FIRST_PTY_ORG_ID                     NUMBER_tbl_type        ,
TAX_EVENT_CLASS_CODE                 VARCHAR2_30_tbl_type   ,
TAX_EVENT_TYPE_CODE                  VARCHAR2_30_tbl_type   ,
DOC_EVENT_STATUS                     VARCHAR2_30_tbl_type   ,
RDNG_SHIP_TO_PTY_TX_PROF_ID          NUMBER_tbl_type        ,
RDNG_SHIP_FROM_PTY_TX_PROF_ID        NUMBER_tbl_type        ,
RDNG_BILL_TO_PTY_TX_PROF_ID          NUMBER_tbl_type        ,
RDNG_BILL_FROM_PTY_TX_PROF_ID        NUMBER_tbl_type        ,
RDNG_SHIP_TO_PTY_TX_P_ST_ID          NUMBER_tbl_type        ,
RDNG_SHIP_FROM_PTY_TX_P_ST_ID        NUMBER_tbl_type        ,
RDNG_BILL_TO_PTY_TX_P_ST_ID          NUMBER_tbl_type        ,
RDNG_BILL_FROM_PTY_TX_P_ST_ID        NUMBER_tbl_type        ,
SHIP_TO_PARTY_TAX_PROF_ID            NUMBER_tbl_type        ,
SHIP_FROM_PARTY_TAX_PROF_ID          NUMBER_tbl_type        ,
POA_PARTY_TAX_PROF_ID                NUMBER_tbl_type        ,
POO_PARTY_TAX_PROF_ID                NUMBER_tbl_type        ,
PAYING_PARTY_TAX_PROF_ID             NUMBER_tbl_type        ,
OWN_HQ_PARTY_TAX_PROF_ID             NUMBER_tbl_type        ,
TRADING_HQ_PARTY_TAX_PROF_ID         NUMBER_tbl_type        ,
POI_PARTY_TAX_PROF_ID                NUMBER_tbl_type        ,
POD_PARTY_TAX_PROF_ID                NUMBER_tbl_type        ,
BILL_TO_PARTY_TAX_PROF_ID            NUMBER_tbl_type        ,
BILL_FROM_PARTY_TAX_PROF_ID          NUMBER_tbl_type        ,
TITLE_TRANS_PARTY_TAX_PROF_ID        NUMBER_tbl_type        ,
SHIP_TO_SITE_TAX_PROF_ID             NUMBER_tbl_type        ,
SHIP_FROM_SITE_TAX_PROF_ID           NUMBER_tbl_type        ,
POA_SITE_TAX_PROF_ID                 NUMBER_tbl_type        ,
POO_SITE_TAX_PROF_ID                 NUMBER_tbl_type        ,
PAYING_SITE_TAX_PROF_ID              NUMBER_tbl_type        ,
OWN_HQ_SITE_TAX_PROF_ID              NUMBER_tbl_type        ,
TRADING_HQ_SITE_TAX_PROF_ID          NUMBER_tbl_type        ,
POI_SITE_TAX_PROF_ID                 NUMBER_tbl_type        ,
POD_SITE_TAX_PROF_ID                 NUMBER_tbl_type        ,
BILL_TO_SITE_TAX_PROF_ID             NUMBER_tbl_type        ,
BILL_FROM_SITE_TAX_PROF_ID           NUMBER_tbl_type        ,
TITLE_TRANS_SITE_TAX_PROF_ID         NUMBER_tbl_type        ,
MERCHANT_PARTY_TAX_PROF_ID           NUMBER_tbl_type        ,
HQ_ESTB_PARTY_TAX_PROF_ID            NUMBER_tbl_type        ,
DOCUMENT_SUB_TYPE                    VARCHAR2_240_tbl_type  ,
SUPPLIER_TAX_INVOICE_NUMBER          VARCHAR2_150_tbl_type  ,
SUPPLIER_TAX_INVOICE_DATE            DATE_tbl_type          ,
SUPPLIER_EXCHANGE_RATE               NUMBER_tbl_type        ,
TAX_INVOICE_DATE                     DATE_tbl_type          ,
TAX_INVOICE_NUMBER                   VARCHAR2_150_tbl_type  ,
LINE_AMT_INCLUDES_TAX_FLAG           VARCHAR2_1_tbl_type    ,
QUOTE_FLAG                           VARCHAR2_1_tbl_type    ,
DEFAULT_TAXATION_COUNTRY             VARCHAR2_2_tbl_type    ,
HISTORICAL_FLAG                      VARCHAR2_1_tbl_type    ,
INTERNAL_ORG_LOCATION_ID             NUMBER_tbl_type        ,
CTRL_HDR_TX_APPL_FLAG                VARCHAR2_1_tbl_type    ,
CTRL_TOTAL_HDR_TX_AMT                NUMBER_tbl_type        ,
CTRL_TOTAL_LINE_TX_AMT               NUMBER_tbl_type        ,
DIST_LEVEL_ACTION                    VARCHAR2_30_tbl_type   ,
APPLIED_FROM_TAX_DIST_ID             NUMBER_tbl_type        ,
ADJUSTED_DOC_TAX_DIST_ID             NUMBER_tbl_type        ,
TASK_ID                              NUMBER_tbl_type        ,
AWARD_ID                             NUMBER_tbl_type        ,
PROJECT_ID                           NUMBER_tbl_type        ,
EXPENDITURE_TYPE                     VARCHAR2_30_tbl_type   ,
EXPENDITURE_ORGANIZATION_ID          NUMBER_tbl_type        ,
EXPENDITURE_ITEM_DATE                DATE_tbl_type          ,
TRX_LINE_DIST_AMT                    NUMBER_tbl_type        ,
TRX_LINE_DIST_QUANTITY               NUMBER_tbl_type        ,
REF_DOC_CURR_CONV_RATE               NUMBER_tbl_type        ,
ITEM_DIST_NUMBER                     NUMBER_tbl_type        ,
REF_DOC_DIST_ID                      NUMBER_tbl_type        ,
TRX_LINE_DIST_TAX_AMT                NUMBER_tbl_type        ,
TRX_LINE_DIST_ID                     NUMBER_tbl_type        ,
DIST_TRX_USER_KEY1                   VARCHAR2_150_tbl_type  ,
DIST_TRX_USER_KEY2                   VARCHAR2_150_tbl_type  ,
DIST_TRX_USER_KEY3                   VARCHAR2_150_tbl_type  ,
DIST_TRX_USER_KEY4                   VARCHAR2_150_tbl_type  ,
DIST_TRX_USER_KEY5                   VARCHAR2_150_tbl_type  ,
DIST_TRX_USER_KEY6                   VARCHAR2_150_tbl_type  ,
APPLIED_FROM_DIST_ID                 NUMBER_tbl_type        ,
APP_FROM_DST_TRX_USER_KEY1           VARCHAR2_150_tbl_type  ,
APP_FROM_DST_TRX_USER_KEY2           VARCHAR2_150_tbl_type  ,
APP_FROM_DST_TRX_USER_KEY3           VARCHAR2_150_tbl_type  ,
APP_FROM_DST_TRX_USER_KEY4           VARCHAR2_150_tbl_type  ,
APP_FROM_DST_TRX_USER_KEY5           VARCHAR2_150_tbl_type  ,
APP_FROM_DST_TRX_USER_KEY6           VARCHAR2_150_tbl_type  ,
ADJUSTED_DOC_DIST_ID                 NUMBER_tbl_type        ,
ADJ_DOC_DST_TRX_USER_KEY1            VARCHAR2_150_tbl_type  ,
ADJ_DOC_DST_TRX_USER_KEY2            VARCHAR2_150_tbl_type  ,
ADJ_DOC_DST_TRX_USER_KEY3            VARCHAR2_150_tbl_type  ,
ADJ_DOC_DST_TRX_USER_KEY4            VARCHAR2_150_tbl_type  ,
ADJ_DOC_DST_TRX_USER_KEY5            VARCHAR2_150_tbl_type  ,
ADJ_DOC_DST_TRX_USER_KEY6            VARCHAR2_150_tbl_type  ,
INPUT_TAX_CLASSIFICATION_CODE        VARCHAR2_30_tbl_type   ,
OUTPUT_TAX_CLASSIFICATION_CODE       VARCHAR2_50_tbl_type   ,
PORT_OF_ENTRY_CODE                   VARCHAR2_30_tbl_type   ,
TAX_REPORTING_FLAG                   VARCHAR2_1_tbl_type    ,
TAX_AMT_INCLUDED_FLAG                VARCHAR2_1_tbl_type    ,
COMPOUNDING_TAX_FLAG                 VARCHAR2_1_tbl_type    ,
SHIP_THIRD_PTY_ACCT_SITE_ID          NUMBER_tbl_type        ,
BILL_THIRD_PTY_ACCT_SITE_ID          NUMBER_tbl_type        ,
SHIP_TO_CUST_ACCT_SITE_USE_ID        NUMBER_tbl_type        ,
BILL_TO_CUST_ACCT_SITE_USE_ID        NUMBER_tbl_type        ,
PROVNL_TAX_DETERMINATION_DATE        DATE_tbl_type          ,
SHIP_THIRD_PTY_ACCT_ID               NUMBER_tbl_type        ,
BILL_THIRD_PTY_ACCT_ID               NUMBER_tbl_type        ,
SOURCE_APPLICATION_ID                NUMBER_tbl_type        ,
SOURCE_ENTITY_CODE                   VARCHAR2_30_tbl_type   ,
SOURCE_EVENT_CLASS_CODE              VARCHAR2_30_tbl_type   ,
SOURCE_TRX_ID                        NUMBER_tbl_type        ,
SOURCE_LINE_ID                       NUMBER_tbl_type        ,
SOURCE_TRX_LEVEL_TYPE                VARCHAR2_30_tbl_type   ,
INSERT_UPDATE_FLAG                   VARCHAR2_1_tbl_type    ,
APPLIED_TO_TRX_NUMBER                VARCHAR2_150_tbl_type  ,
START_EXPENSE_DATE                   DATE_tbl_type          ,
TRX_BATCH_ID                         NUMBER_tbl_type        ,
RECORD_TYPE_CODE                     VARCHAR2_30_tbl_type   ,
REF_DOC_TRX_LEVEL_TYPE               VARCHAR2_30_tbl_type   ,
APPLIED_FROM_TRX_LEVEL_TYPE          VARCHAR2_30_tbl_type   ,
APPLIED_TO_TRX_LEVEL_TYPE            VARCHAR2_30_tbl_type   ,
ADJUSTED_DOC_TRX_LEVEL_TYPE          VARCHAR2_30_tbl_type   ,
DEFAULTING_ATTRIBUTE1                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE2                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE3                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE4                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE5                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE6                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE7                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE8                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE9                VARCHAR2_150_tbl_type  ,
DEFAULTING_ATTRIBUTE10               VARCHAR2_150_tbl_type  ,
TAX_PROCESSING_COMPLETED_FLAG        VARCHAR2_1_tbl_type    ,
APPLICATION_DOC_STATUS               VARCHAR2_30_tbl_type   ,
OVERRIDING_RECOVERY_RATE             NUMBER_tbl_type        ,
TAX_CALCULATION_DONE_FLAG            VARCHAR2_1_tbl_type    ,
SOURCE_TAX_LINE_ID                   NUMBER_tbl_type        ,
REVERSED_APPLN_ID                    NUMBER_tbl_type        ,
REVERSED_ENTITY_CODE                 VARCHAR2_30_tbl_type   ,
REVERSED_EVNT_CLS_CODE               VARCHAR2_30_tbl_type   ,
REVERSED_TRX_ID                      NUMBER_tbl_type        ,
REVERSED_TRX_LEVEL_TYPE              VARCHAR2_30_tbl_type   ,
REVERSED_TRX_LINE_ID                 NUMBER_tbl_type        ,
EXEMPTION_CONTROL_FLAG               VARCHAR2_1_tbl_type    ,
EXEMPT_REASON_CODE                   VARCHAR2_30_tbl_type   ,
INTERFACE_ENTITY_CODE                VARCHAR2_30_tbl_type   ,
INTERFACE_LINE_ID                    NUMBER_tbl_type        ,
HISTORICAL_TAX_CODE_ID               NUMBER_tbl_type        ,
USER_UPD_DET_FACTORS_FLAG            VARCHAR2_1_tbl_type    ,
ICX_SESSION_ID                       NUMBER_tbl_type        ,
HDR_SHIP_THIRD_PTY_ACCT_ST_ID        NUMBER_tbl_type        ,
HDR_BILL_THIRD_PTY_ACCT_ST_ID        NUMBER_tbl_type        ,
HDR_SHIP_TO_CST_ACCT_ST_USE_ID       NUMBER_tbl_type        ,
HDR_BILL_TO_CST_ACCT_ST_USE_ID       NUMBER_tbl_type        ,
HDR_SHIP_THIRD_PTY_ACCT_ID           NUMBER_tbl_type        ,
HDR_BILL_THIRD_PTY_ACCT_ID           NUMBER_tbl_type        ,
HDR_RECEIVABLES_TRX_TYPE_ID          NUMBER_tbl_type        ,
GLOBAL_ATTRIBUTE1                    VARCHAR2_150_tbl_type  ,
GLOBAL_ATTRIBUTE_CATEGORY            VARCHAR2_150_tbl_type  ,
TOTAL_INC_TAX_AMT                    NUMBER_tbl_type
);

TYPE tax_regime_rec_type IS RECORD (
TAX_REGIME_PRECEDENCE       NUMBER,
TAX_REGIME_ID               NUMBER,
TAX_PROVIDER_ID             NUMBER,
PARENT_REGIME_ID            NUMBER,
TAX_REGIME_CODE             VARCHAR2(80),
PARENT_REGIME_CODE          VARCHAR2(80),
COUNTRY_CODE                VARCHAR2(80),
GEOGRAPHY_TYPE              VARCHAR2(80),
GEOGRAPHY_ID                NUMBER,
EFFECTIVE_FROM              DATE,
EFFECTIVE_TO                DATE,
PARTNER_PROCESSING_FLAG     VARCHAR2(1),
SYNC_WITH_PROVIDER_FLAG     VARCHAR2(1),
COUNTRY_OR_GROUP_CODE       ZX_REGIMES_B.COUNTRY_OR_GROUP_CODE%type
);

 TYPE tax_regime_tbl_type IS TABLE OF tax_regime_rec_type
 INDEX BY BINARY_INTEGER;

 -- Tax Partner specific global structure ----------
 -- The following structure is introduced for Tax Partner Processing
 -- Partner processing logic needs the list of tax regimes for every
 -- transaction as a starting point. Since the tax_regimes_tbl structure
 -- will be initialized for every transaction we copy that information into
 -- the structure below so that this information is available to partner
 -- API which will be called in the end in bulk.

 TYPE ptnr_tax_regime_rec_type is RECORD (
   application_id                 zx_lines_det_factors.application_id%TYPE,
   event_class_code               zx_lines_det_factors.event_class_code%TYPE,
   entity_code                    zx_lines_det_factors.entity_code%TYPE,
   trx_id                         zx_lines_det_factors.trx_id%TYPE,
   event_id                       zx_lines_det_factors.event_id%TYPE,
   event_class_mapping_id         zx_lines_det_factors.event_class_mapping_id%TYPE,
   event_type_code                zx_lines_det_factors.event_type_code%TYPE,
   tax_event_class_code            zx_lines_det_factors.tax_event_class_code%TYPE,
   tax_event_type_code            zx_lines_det_factors.tax_event_type_code%TYPE,
   doc_status_code                VARCHAR2(30),
   record_flag                    zx_evnt_cls_mappings.record_flag%TYPE,
   quote_flag                     zx_trx_headers_gt.quote_flag%TYPE,
   record_for_partners_flag       zx_evnt_cls_mappings.record_for_partners_flag%TYPE,
   prod_family_grp_code           zx_evnt_cls_mappings.prod_family_grp_code%TYPE,
   first_pty_org_id               zx_lines_det_factors.first_pty_org_id%TYPE,
   internal_organization_id       zx_lines_det_factors.internal_organization_id%TYPE,
   legal_entity_id                zx_lines_det_factors.legal_entity_id%TYPE,
   ledger_id                      zx_lines_det_factors.ledger_id%TYPE,
   establishment_id               zx_lines_det_factors.establishment_id%TYPE,
   currency_conversion_type       zx_lines_det_factors.currency_conversion_type%TYPE,
   process_for_applicability_flag VARCHAR2(1),
   perf_addnl_appl_for_imprt_flag VARCHAR2(1),
   ptnr_srvc_subscr_flag          VARCHAR2(1),
   effective_date                 DATE,
   tax_regime_tbl                 tax_regime_tbl_type
 );

 TYPE ptnr_tax_regime_tbl_type IS TABLE OF ptnr_tax_regime_rec_type
  INDEX BY BINARY_INTEGER;

  ptnr_tax_regime_tbl    ptnr_tax_regime_tbl_type;

--------------------------------------------------------


 TYPE Regime_relation_rec_type is RECORD(
 PARENT_REGIME_CODE   ZX_REGIME_RELATIONS.PARENT_REGIME_CODE%type,
 PARENT_REG_LEVEL     ZX_REGIME_RELATIONS.PARENT_REG_LEVEL%type,
 REGIME_CODE          ZX_REGIME_RELATIONS.REGIME_CODE%type);

 TYPE Regime_relation_tbl_type IS TABLE of Regime_relation_rec_type index by BINARY_INTEGER;

 REGIME_RELATION_TBL Regime_relation_tbl_type;

 TYPE  territory_tbl_type is table of FND_TERRITORIES.TERRITORY_CODE%TYPE
 INDEX by BINARY_INTEGER;

 G_TERRITORY_TBL territory_tbl_type;


 TYPE detail_tax_regime_rec_type IS RECORD (
 TRX_LINE_INDEX             BINARY_INTEGER,
 TAX_REGIME_PRECEDENCE      NUMBER,
 TAX_REGIME_ID              NUMBER
 );

 TYPE detail_tax_regime_tbl_type IS TABLE OF detail_tax_regime_rec_type
 INDEX BY BINARY_INTEGER;

 TYPE regimes_usages_rec_type is RECORD(
 TAX_REGIME_ID  	    NUMBER,
 TAX_REGIME_CODE	    ZX_REGIMES_B.tax_Regime_code%TYPE,
 FIRST_PTY_ORG_ID	    NUMBER,
 REGIME_USAGE_ID	    NUMBER);

 TYPE REGIMES_USAGES_TBL_TYPE is TABLE of regimes_usages_rec_type index by BINARY_INTEGER;
 -- This structure is indexed by hash value of tax_regime_code and first party_org_id.
 G_REGIMES_USAGES_TBL REGIMES_USAGES_TBL_TYPE;


 TYPE trx_line_app_regime_rec_type IS RECORD (
 EVENT_CLASS_CODE           VARCHAR2_30_tbl_type,
 APPLICATION_ID             NUMBER_tbl_type,
 ENTITY_CODE                VARCHAR2_30_tbl_type,
 TRX_ID                     NUMBER_tbl_type,
 TRX_LINE_ID                NUMBER_tbl_type,
 TRX_LEVEL_TYPE             VARCHAR2_30_tbl_type,
 TAX_REGIME_CODE            VARCHAR2_30_tbl_type,
 TAX_REGIME_ID              NUMBER_tbl_type,
 TAX_PROVIDER_ID            NUMBER_tbl_type,
 ALLOW_TAX_CALCULATION_FLAG VARCHAR2_1_tbl_type
 );

 TYPE location_info_rec_type IS RECORD (
 EVENT_CLASS_MAPPING_ID     NUMBER_tbl_type,
 TRX_ID                     NUMBER_tbl_type,
 TRX_LINE_ID                NUMBER_tbl_type,
 TRX_LEVEL_TYPE             VARCHAR2_30_tbl_type,
 LOCATION_TYPE              VARCHAR2_30_tbl_type,
 LOCATION_TABLE_NAME        VARCHAR2_30_tbl_type,
 LOCATION_ID                NUMBER_tbl_type,
 GEOGRAPHY_TYPE             VARCHAR2_30_tbl_type,
 GEOGRAPHY_VALUE            VARCHAR2_360_tbl_type,
 GEOGRAPHY_ID               NUMBER_tbl_type
 );

/* Bug fix 4222298 */
 TYPE location_hash_tbl_type IS TABLE OF number index by binary_integer;

TYPE fc_country_def_val_rec_type is RECORD (
COUNTRY_CODE                VARCHAR2(2),
FC_TYPE                     VARCHAR2(30),
FC_DEFAULT_VALUE            VARCHAr2(240)
);

fc_country_def_val_rec fc_country_def_val_rec_type;

Type fc_country_def_val_tbl_type is table of fc_country_def_val_rec_type index by binary_integer;

TYPE item_product_type_val_rec_type is RECORD (
ORG_ID             ZX_PRODUCT_OPTIONS_ALL.ORG_ID%TYPE,
FC_ITEM_ID         MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
FC_TYPE            VARCHAR2(30),
FC_DEFAULT_VALUE   VARCHAR2(240)
);

TYPE item_product_type_val_tbl_type is table of item_product_type_val_rec_type index by binary_integer;

-- the structure below is used to cache geography types info
-- This structure is referenced in jurisdictions API (get_zone)

  TYPE geography_type_info_rec_type is record
    (ZONE_TYPE            hz_geographies.geography_type%TYPE,  --bug8251315
     GEOGRAPHY_TYPE     	hz_geography_types_b.geography_type%TYPE,
     GEOGRAPHY_USE      	hz_geography_types_b.GEOGRAPHY_USE%TYPE,
     LIMITED_BY_GEOGRAPHY_ID    hz_geography_types_b.LIMITED_BY_GEOGRAPHY_ID%TYPE);

  TYPE geography_type_info_tbl_type is table of geography_type_info_rec_type index by BINARY_INTEGER;


-- the structure below is used in jurisdictions API to get geography types and uses for a given tax
-- and this structure is valid for the whole session. This structure is referenced in jurisdictions API

    TYPE geography_use_info_rec_type is record
    (
    TAX_ID               zx_taxes_b.tax_id%type,
    GEOGRAPHY_TYPE_NUM   number,
    GEOGRAPHY_TYPE       hz_geography_types_b.geography_type%type,
    GEOGRAPHY_USE        hz_geography_types_b.geography_use%TYPE);

    TYPE geography_use_info_tbl_type is table of geography_use_info_rec_type index by binary_integer;

    -- caching fix done for bug#8551677

    TYPE condition_info_rec_type is record
    (

    condition_group_id       ZX_CONDITION_GROUPS_B.condition_group_id%TYPE,
    condition_group_code     ZX_CONDITION_GROUPS_B.condition_group_code%TYPE,
    more_than10              ZX_CONDITION_GROUPS_B.More_Than_Max_Cond_Flag%TYPE,
    det_factor_class1        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq1   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type1               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code1         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator1                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value1           ZX_CONDITIONS.numeric_value%TYPE,
    date_value1              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value1          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low1               ZX_CONDITIONS.value_low%TYPE,
    value_high1              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code1      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class2        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq2   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type2               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code2         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator2                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value2           ZX_CONDITIONS.numeric_value%TYPE,
    date_value2              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value2          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low2               ZX_CONDITIONS.value_low%TYPE,
    value_high2              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code2      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class3        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq3   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type3               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code3         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator3                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value3           ZX_CONDITIONS.numeric_value%TYPE,
    date_value3              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value3          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low3               ZX_CONDITIONS.value_low%TYPE,
    value_high3              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code3      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class4        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq4   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type4               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code4         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator4                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value4           ZX_CONDITIONS.numeric_value%TYPE,
    date_value4              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value4          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low4               ZX_CONDITIONS.value_low%TYPE,
    value_high4              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code4      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class5        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq5   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type5               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code5         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator5                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value5           ZX_CONDITIONS.numeric_value%TYPE,
    date_value5              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value5          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low5               ZX_CONDITIONS.value_low%TYPE,
    value_high5              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code5      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class6        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq6   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type6               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code6         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator6                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value6           ZX_CONDITIONS.numeric_value%TYPE,
    date_value6              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value6          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low6               ZX_CONDITIONS.value_low%TYPE,
    value_high6              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code6      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class7        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq7   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type7               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code7         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator7                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value7           ZX_CONDITIONS.numeric_value%TYPE,
    date_value7              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value7          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low7               ZX_CONDITIONS.value_low%TYPE,
    value_high7              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code7      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class8        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq8   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type8               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code8         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator8                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value8           ZX_CONDITIONS.numeric_value%TYPE,
    date_value8              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value8          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low8               ZX_CONDITIONS.value_low%TYPE,
    value_high8              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code8      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class9        ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq9   ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type9               ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code9         ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator9                ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value9           ZX_CONDITIONS.numeric_value%TYPE,
    date_value9              ZX_CONDITIONS.date_value%TYPE,
    alphanum_value9          ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low9               ZX_CONDITIONS.value_low%TYPE,
    value_high9              ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code9      ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    det_factor_class10       ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE,
    determining_factor_cq10  ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE,
    data_type10              ZX_CONDITIONS.Data_Type_Code%TYPE,
    det_factor_code10        ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE,
    operator10               ZX_CONDITIONS.Operator_Code%TYPE,
    numeric_value10          ZX_CONDITIONS.numeric_value%TYPE,
    date_value10             ZX_CONDITIONS.date_value%TYPE,
    alphanum_value10         ZX_CONDITIONS.alphanumeric_value%TYPE,
    value_low10              ZX_CONDITIONS.value_low%TYPE,
    value_high10             ZX_CONDITIONS.value_high%TYPE,
    tax_parameter_code10     ZX_PARAMETERS_B.tax_parameter_code%TYPE,
    chart_of_accounts_id     ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
    sob_id                   ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
    result_id                ZX_PROCESS_RESULTS.result_id%TYPE,
    constraint_id            ZX_CONDITION_GROUPS_B.constraint_id%TYPE
    );

    TYPE condition_info_tbl_type is table of condition_info_rec_type index by binary_integer;

    TYPE rule_info_rec_type is record
    (

    tax_rule_id              ZX_RULES_B.tax_rule_id%TYPE,
    det_factor_templ_code    ZX_CONDITION_GROUPS_B.det_factor_templ_code%TYPE,
    tax_status_code          ZX_PROCESS_RESULTS.tax_status_code%TYPE,
    condition_info_rec_tbl   condition_info_tbl_type
    );

    TYPE rule_info_tbl_type is table of rule_info_rec_type index by varchar2(100);

    g_rule_info_tbl     rule_info_tbl_type;

    -- the structure below is used in jurisdictions get_zone API to get geo name
    -- reference for a given location_id and this structure is value for the whole session.

    TYPE geo_name_references_rec_type is record
    (
    LOCATION_ID   hz_geo_name_references.location_id%TYPE,
    REF_COUNT     NUMBER
    );

    TYPE geo_name_references_tbl_type is table of geo_name_references_rec_type index by binary_integer;

-- The strucure below is used to cache location information for a location
-- The structure is valid throughout the session. This structure is referenced in jurisdictions API
-- This structure is indexed by location_id

    TYPE rec_nrec_ccid_rec_type is record
    (
     interim_tax_ccid zx_accounts.interim_tax_ccid%type,
     tax_account_ccid zx_accounts.tax_account_ccid%type,
     non_rec_account_ccid zx_accounts.non_rec_account_ccid%type);

    TYPE rec_nrec_ccid_tbl_type is table of rec_nrec_ccid_rec_type index by
VARCHAR2(100);
    rec_nrec_ccid_tbl rec_nrec_ccid_tbl_type;

    TYPE loc_info_rec_type is record
    (
    LOCATION_ID 	 hz_locations.location_id%type,
    LOCATION_TABLE_NAME  VARCHAR2(30),
    COUNTRY_CODE         hz_locations.country%type);

    TYPE loc_info_tbl_type is table of loc_info_rec_type index by VARCHAR2(50);
    Loc_info_tbl loc_info_tbl_type;

    TYPE tax_calc_flag_tbl_type is table of VARCHAR2(10) index by VARCHAR2(10);

     tax_calc_flag_tbl tax_calc_flag_tbl_type;

-- The strucure below is used to cache geography id and geography type information for a location
-- The structure is valid throughout the session. This structure is referenced in jurisdictions API
-- This structure is indexed by a hash value of  to_char(location_id) + geography_type

    TYPE loc_geography_info_rec_type is record
    (
    LOCATION_ID      hz_locations.location_id%type,
    GEOGRAPHY_TYPE   hz_geographies.geography_type%type,
    GEOGRAPHY_ID     hz_geographies.geography_id%type,
    GEOGRAPHY_CODE   hz_geographies.geography_code%type,
    GEOGRAPHY_NAME   hz_geographies.geography_name%type,
    GEOGRAPHY_USE    hz_geographies.geography_use%type);

    type loc_geography_info_tbl_type is table of loc_geography_info_rec_type index by binary_integer;
    Loc_geography_info_tbl loc_geography_info_tbl_type;

-- The structure below is used to cache party type info. This structure is indexed by hash value of
-- party_type_code and is being referenced by jurisdictions API.

   TYPE ZX_PARTY_TYPES_INFO_REC is record(
    PARTY_TYPE_CODE                 zx_party_types.PARTY_TYPE_CODE%type,
    PARTY_SOURCE_TABLE              zx_party_types.PARTY_SOURCE_TABLE%type,
    PARTY_SOURCE_COLUMN             zx_party_types.PARTY_SOURCE_COLUMN%type,
    APPLICABLE_TO_EVNT_CLS_FLAG     zx_party_types.APPLICABLE_TO_EVNT_CLS_FLAG%type,
    PARTY_SITE_TYPE                 zx_party_types.PARTY_SITE_TYPE%type,
    LOCATION_SOURCE_TABLE           zx_party_types.LOCATION_SOURCE_TABLE%type,
    LOCATION_SOURCE_COLUMN          zx_party_types.LOCATION_SOURCE_COLUMN%type);


   TYPE ZX_PARTY_TYPES_CACHE_TBLTYPE is table of ZX_PARTY_TYPES_INFO_REC index by binary_integer;

   ZX_PARTY_TYPES_CACHE ZX_PARTY_TYPES_CACHE_TBLTYPE;


Type intended_use_tbl_info_rectype is RECORD
(owner_table_code zx_fc_types_b.owner_table_code%type,
 owner_id_num     zx_fc_types_b.owner_id_num%type);


 Type zx_product_options_rec_type is record(
          APPLICATION_ID               zx_product_options_all.APPLICATION_ID%type,
          ORG_ID                       zx_product_options_all.ORG_ID%type,
          TAX_METHOD_CODE              zx_product_options_all.TAX_METHOD_CODE%type,
          DEF_OPTION_HIER_1_CODE       zx_product_options_all.DEF_OPTION_HIER_1_CODE%type,
          DEF_OPTION_HIER_2_CODE       zx_product_options_all.DEF_OPTION_HIER_2_CODE%type,
          DEF_OPTION_HIER_3_CODE       zx_product_options_all.DEF_OPTION_HIER_3_CODE%type,
          DEF_OPTION_HIER_4_CODE       zx_product_options_all.DEF_OPTION_HIER_4_CODE%type,
          DEF_OPTION_HIER_5_CODE       zx_product_options_all.DEF_OPTION_HIER_5_CODE%type,
          DEF_OPTION_HIER_6_CODE       zx_product_options_all.DEF_OPTION_HIER_6_CODE%type,
          DEF_OPTION_HIER_7_CODE       zx_product_options_all.DEF_OPTION_HIER_7_CODE%type,
          TAX_CLASSIFICATION_CODE      zx_product_options_all.TAX_CLASSIFICATION_CODE%type,
          INCLUSIVE_TAX_USED_FLAG      zx_product_options_all.INCLUSIVE_TAX_USED_FLAG%type,
          TAX_USE_CUSTOMER_EXEMPT_FLAG zx_product_options_all.TAX_USE_CUSTOMER_EXEMPT_FLAG%type,
          TAX_USE_PRODUCT_EXEMPT_FLAG  zx_product_options_all.TAX_USE_PRODUCT_EXEMPT_FLAG%type,
          TAX_USE_LOC_EXC_RATE_FLAG    zx_product_options_all.TAX_USE_LOC_EXC_RATE_FLAG%type,
          TAX_ALLOW_COMPOUND_FLAG      zx_product_options_all.TAX_ALLOW_COMPOUND_FLAG%type,
          USE_TAX_CLASSIFICATION_FLAG  zx_product_options_all.USE_TAX_CLASSIFICATION_FLAG%type,
          ALLOW_TAX_ROUNDING_OVRD_FLAG zx_product_options_all.ALLOW_TAX_ROUNDING_OVRD_FLAG%type,
          HOME_COUNTRY_DEFAULT_FLAG    zx_product_options_all.HOME_COUNTRY_DEFAULT_FLAG%type,
          TAX_ROUNDING_RULE            zx_product_options_all.TAX_ROUNDING_RULE%type,
          TAX_PRECISION                zx_product_options_all.TAX_PRECISION%type,
          TAX_MINIMUM_ACCOUNTABLE_UNIT zx_product_options_all.TAX_MINIMUM_ACCOUNTABLE_UNIT%type,
          TAX_CURRENCY_CODE            zx_product_options_all.TAX_CURRENCY_CODE%type);

type zx_product_options_tbl_type is table of zx_product_options_rec_type index by binary_integer;

--    This strucure is used to store information whether a template contains parameters
--    that are not passed by a specific Product Event Class. In that case, the template
--    will not be valid for that particular event class. This structure is used in Rule engine
TYPE  template_valid_info_rec is record(
       DET_FACTOR_TEMPL_CODE  ZX_DET_FACTOR_TEMPL_B.DET_FACTOR_TEMPL_CODE%TYPE,
       EVENT_CLASS_MAPPING_ID ZX_EVNT_CLS_MAPPINGS.EVENT_CLASS_MAPPING_ID%TYPE,
       VALID                  BOOLEAN);
TYPE   template_valid_info_tbl_type is table of template_valid_info_rec index by BINARY_INTEGER;

g_template_valid_info_tbl  template_valid_info_tbl_type;

-- This structure caches the tax information assoicated with hz_cust_site_use table
-- it is referenced in zxccontrolb.pls/zxdiroundtaxpkgb.pls. The information in this structure is valid
-- throughout the session
Type cust_site_use_info_rec_type is RECORD
     (SITE_USE_ID         	hz_cust_site_uses_all.site_use_id%TYPE,
      TAX_REFERENCE  		hz_cust_site_uses_all.tax_reference%TYPE,
      TAX_CODE       		hz_cust_site_uses_all.tax_code%TYPE,
      TAX_ROUNDING_RULE 	hz_cust_site_uses_all.tax_rounding_rule%TYPE,
      TAX_HEADER_LEVEL_FLAG 	hz_cust_site_uses_all.tax_header_level_flag%TYPE,
      TAX_CLASSIFICATION 	hz_cust_site_uses_all.Tax_Classification%TYPE);

TYPE cust_site_use_info_tbl_type is TABLE of cust_site_use_info_rec_type index by BINARY_INTEGER;

-- This structure caches the tax information assoicated with hz_cust_accounts table
-- it is referenced in zxccontrolb.pls/zxdiroundtaxpkgb.pls. The information in this structure is valid
-- throughout the session

TYPE cust_acct_info_rec_type is RECORD
     (CUST_ACCOUNT_ID   	hz_cust_accounts.cust_account_id%TYPE,
      TAX_CODE       		hz_cust_accounts.tax_code%TYPE,
      TAX_ROUNDING_RULE 	hz_cust_accounts.tax_rounding_rule%TYPE,
      TAX_HEADER_LEVEL_FLAG 	hz_cust_accounts.tax_header_level_flag%TYPE);

TYPE cust_acct_info_tbl_type is TABLE of  cust_acct_info_rec_type index by BINARY_INTEGER;

-- This structure caches the tax information assoicated with ap_supplier_sites table
-- it is referenced in zxccontrolb.pls/zxdiroundtaxpkgb.pls. The information in this structure is valid
-- throughout the session

TYPE supp_site_info_rec_type is RECORD
    (VENDOR_ID          ap_suppliers.vendor_id%TYPE,
     VENDOR_SITE_ID    	ap_supplier_sites.vendor_site_id%type,
     TAX_ROUNDING_RULE 	VARCHAR2(10),
     TAX_ROUNDING_LEVEL VARCHAR2(10),
     Auto_Tax_Calc_Flag VARCHAR2(1),
     VAT_CODE	        ap_suppliers.VAT_Code%TYPE,
     VAT_REGISTRATION_NUM ap_suppliers.VAT_Registration_Num%TYPE,
     AMOUNT_INCLUDES_TAX_FLAG  ap_suppliers.amount_includes_tax_flag%TYPE);

TYPE supp_site_info_tbl_type is TABLE of supp_site_info_rec_type  index by BINARY_INTEGER;

-- This structures caches the Registration information associated with ZX_REGISTRATIONS table
-- This table is referenced in  zxccontrolb.pls and is indexed by combination of
-- party_tax_profile_id, tax_regime_code, Tax and Jurisdiction. The value fetched
-- using the key should be  be checked for the tax Jurisdiction code
-- and effectivity.  The information in this structure is valid
-- throughout the session

TYPE registration_info_tbl_type is table of ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC
index by BINARY_INTEGER;

-- This structure caches the party_tax_profile related information and is valid
-- throughout the session. This structure is indexed by party_tax_profile_id and
-- is referenced in various APIs that need to access party tax profile information
-- Also referenced in zxccontrolb.pls/zxdiroundtaxpkgb.pls

TYPE PARTY_TAX_PROF_INFO_REC_TYPE is record
( PARTY_TAX_PROFILE_ID		        zx_party_tax_profile.PARTY_TAX_PROFILE_ID%TYPE,
  PARTY_ID                              zx_party_tax_profile.PARTY_ID%TYPE,
  PARTY_TYPE_CODE                       zx_party_tax_profile.PARTY_TYPE_CODE%TYPE,
  SUPPLIER_FLAG                         zx_party_tax_profile.SUPPLIER_FLAG%TYPE,
  CUSTOMER_FLAG                         zx_party_tax_profile.CUSTOMER_FLAG%TYPE,
  SITE_FLAG                             zx_party_tax_profile.SITE_FLAG%TYPE,
  PROCESS_FOR_APPLICABILITY_FLAG        zx_party_tax_profile.PROCESS_FOR_APPLICABILITY_FLAG%TYPE,
  ROUNDING_LEVEL_CODE                   zx_party_tax_profile.ROUNDING_LEVEL_CODE%TYPE,
  WITHHOLDING_START_DATE                zx_party_tax_profile.WITHHOLDING_START_DATE%TYPE,
  ALLOW_AWT_FLAG                        zx_party_tax_profile.ALLOW_AWT_FLAG%TYPE,
  USE_LE_AS_SUBSCRIBER_FLAG             zx_party_tax_profile.USE_LE_AS_SUBSCRIBER_FLAG%TYPE,
  LEGAL_ESTABLISHMENT_FLAG              zx_party_tax_profile.LEGAL_ESTABLISHMENT_FLAG%TYPE,
  FIRST_PARTY_LE_FLAG                   zx_party_tax_profile.FIRST_PARTY_LE_FLAG%TYPE,
  REPORTING_AUTHORITY_FLAG              zx_party_tax_profile.REPORTING_AUTHORITY_FLAG%TYPE,
  COLLECTING_AUTHORITY_FLAG             zx_party_tax_profile.COLLECTING_AUTHORITY_FLAG%TYPE,
  PROVIDER_TYPE_CODE                    zx_party_tax_profile.PROVIDER_TYPE_CODE%TYPE,
  CREATE_AWT_DISTS_TYPE_CODE            zx_party_tax_profile.CREATE_AWT_DISTS_TYPE_CODE%TYPE,
  CREATE_AWT_INVOICES_TYPE_CODE         zx_party_tax_profile.CREATE_AWT_INVOICES_TYPE_CODE%TYPE,
  ALLOW_OFFSET_TAX_FLAG                 zx_party_tax_profile.ALLOW_OFFSET_TAX_FLAG%TYPE,
  EFFECTIVE_FROM_USE_LE                 zx_party_tax_profile.EFFECTIVE_FROM_USE_LE%TYPE,
  REP_REGISTRATION_NUMBER               zx_party_tax_profile.REP_REGISTRATION_NUMBER%TYPE,
  ROUNDING_RULE_CODE                    zx_party_tax_profile.ROUNDING_RULE_CODE%TYPE);


TYPE  PARTY_TAX_PROF_INFO_TBL_TYPE is  table of PARTY_TAX_PROF_INFO_REC_TYPE
      index by BINARY_INTEGER;

-- The following record structure is used to retrieve the party_tax_profile_id
-- given the party_id and party_type_code. This structure is indexed by a hash
-- value of party_type_code||party_id

TYPE PARTY_TAX_PROF_ID_INFO_REC is record
 (pARTY_ID  		zx_party_tax_profile.PARTY_ID%TYPE,
  pARTY_TYPE_CODE 	zx_party_tax_profile.PARTY_TYPE_CODE%TYPE,
  pARTY_TAX_PROFILE_ID 	zx_party_tax_profile.PARTY_TAX_PROFILE_ID%TYPE);

TYPE PARTY_TAX_PROF_ID_INFO_TBLTYPE is table of PARTY_TAX_PROF_ID_INFO_REC
     index by BINARY_INTEGER;


-- The follwing structure caches the Tax Classification Code information along with
-- matching records in zx_rates_b. This structure is useful in batch processing when
-- the backward compatible 11i approach (STCC regime determination template) is used.
-- This structure should be valid throughout the batch process.

TYPE TAX_CLASSIF_INFO_RECTYPE is record
(TAX_CLASSIFICATION_CODE   zx_id_tcc_mapping_all.tax_classification_code%type,
 SOURCE_TABLE              VARCHAR2(15),
 TAX_REGIME_CODE           zx_rates_b.tax_regime_code%type,
 TAX                       zx_rates_b.tax%type,
 TAX_STATUS_CODE           zx_rates_b.tax_status_code%type,
 TAX_RATE_CODE             zx_rates_b.tax_rate_Code%type,
 TAX_CLASS                 zx_rates_b.tax_class%type,
 EFFECTIVE_FROM       	   date,
 EFFECTIVE_TO              date,
 ENABLED_FLAG              VARCHAR2(1),
 CONTENT_OWNER_ID          NUMBER);

 TYPE TAX_CLASSIF_INFO_TBLTYPE is table of TAX_CLASSIF_INFO_RECTYPE
 index by BINARY_INTEGER;

-- The following record type/table is used to cache the values of account string
-- for a given CCID so that if the CCID is same on two transactions/lines the
-- ccid to string conversion is done only once. the information in this structure is
-- valid throughout the session.

TYPE CCID_ACCT_STRING_INFO_RECTYPE is record
(CCID        		NUMBER,
 ACCOUNT_STRING 	VARCHAR2(2000),
 CHART_OF_ACCOUNTS_ID   NUMBER);

 TYPE CCID_ACCT_STRING_INFO_TBLTYPE is table of CCID_ACCT_STRING_INFO_RECTYPE
 index by binary_integer;

-- Adding a global record structure to be used for Partner Tax Calculation.
-- Exemption information on the partner calculated tax lines
-- will be populated based on thid record structure.

TYPE PTNR_EXEMPTION_REC_TYPE IS RECORD(
   trx_id                     NUMBER,
   trx_line_id                NUMBER,
   tax                        VARCHAR2(30),
   tax_regime_code            VARCHAR2(30),
   tax_provider_id            NUMBER,
   tax_exemption_id           NUMBER(15),
   st_exempt_reason_code   VARCHAR2(30),
   co_exempt_reason_code   VARCHAR2(30),
   ci_exempt_reason_code   VARCHAR2(30),
   di_exempt_reason_code   VARCHAR2(30),
   st_exempt_reason        VARCHAR2(240),
   co_exempt_reason        VARCHAR2(240),
   ci_exempt_reason        VARCHAR2(240),
   di_exempt_reason        VARCHAR2(240),
   exempt_certificate_number  VARCHAR2(80)
);

TYPE PTNR_EXEMPTION_TBL_TYPE IS TABLE OF PTNR_EXEMPTION_REC_TYPE
INDEX BY VARCHAR2(4000);
ptnr_exemption_tbl            PTNR_EXEMPTION_TBL_TYPE;

--bug#8251315
TYPE hz_zone_rec_type is record
    (
    location_id             NUMBER,
    location_type           VARCHAR2(30),
    zone_id                 NUMBER,
    zone_type               VARCHAR2(30),
    zone_name               VARCHAR2(360),
    zone_code               VARCHAR2(30),
    trx_date                DATE,
    indx_value              VARCHAR2(4000),
    value                   NUMBER
    );

TYPE hz_zone_tbl_type is table of hz_zone_rec_type index by varchar2(4000);
g_hz_zone_tbl       hz_zone_tbl_type;

 -- Latin Tax specific global structure ----------
 -- The following structure is introduced for Latin Tax Processing

 TYPE lte_trx_rec_type is RECORD (
   application_id                 zx_lines_det_factors.application_id%TYPE,
   event_class_code               zx_lines_det_factors.event_class_code%TYPE,
   entity_code                    zx_lines_det_factors.entity_code%TYPE,
   trx_id                         zx_lines_det_factors.trx_id%TYPE,
   event_id                       zx_lines_det_factors.event_id%TYPE,
   event_class_mapping_id         zx_lines_det_factors.event_class_mapping_id%TYPE,
   event_type_code                zx_lines_det_factors.event_type_code%TYPE,
   tax_event_class_code           zx_lines_det_factors.tax_event_class_code%TYPE,
   tax_event_type_code            zx_lines_det_factors.tax_event_type_code%TYPE,
   doc_status_code                VARCHAR2(30),
   record_flag                    zx_evnt_cls_mappings.record_flag%TYPE,
   quote_flag                     zx_trx_headers_gt.quote_flag%TYPE,
   record_for_partners_flag       zx_evnt_cls_mappings.record_for_partners_flag%TYPE,
   prod_family_grp_code           zx_evnt_cls_mappings.prod_family_grp_code%TYPE,
   first_pty_org_id               zx_lines_det_factors.first_pty_org_id%TYPE,
   internal_organization_id       zx_lines_det_factors.internal_organization_id%TYPE,
   legal_entity_id                zx_lines_det_factors.legal_entity_id%TYPE,
   ledger_id                      zx_lines_det_factors.ledger_id%TYPE,
   establishment_id               zx_lines_det_factors.establishment_id%TYPE,
   currency_conversion_type       zx_lines_det_factors.currency_conversion_type%TYPE,
   process_for_applicability_flag VARCHAR2(1),
   perf_addnl_appl_for_imprt_flag VARCHAR2(1),
   effective_date                 DATE
 );

 TYPE lte_trx_tbl_type IS TABLE OF lte_trx_rec_type
  INDEX BY BINARY_INTEGER;

  lte_trx_tbl    lte_trx_tbl_type;

--------------------------------------------------------


/* ===========================================================*
 | Global Structure Variables                                 |
 * ==========================================================*/

  trx_line_dist_tbl              trx_line_dist_rec_type;
  detail_tax_regime_tbl          detail_tax_regime_tbl_type;
  tax_regime_tbl                 tax_regime_tbl_type;
  trx_line_app_regime_tbl        trx_line_app_regime_rec_type;
  location_info_tbl              location_info_rec_type;
  tax_classif_info_tbl           tax_classif_info_tbltype;
/* bug fix 4222298 */
  location_hash_tbl              location_hash_tbl_type;
  FC_COUNTRY_DEF_VAL_TBL         fc_country_def_val_tbl_type;
  ITEM_PRODUCT_TYPE_VAL_TBL      item_product_type_val_tbl_type;
  g_event_class_rec              zx_api_pub.event_class_rec_type;
  g_intended_use_owner_tbl_info  intended_use_tbl_info_rectype;
  g_zx_proudct_options_tbl       zx_product_options_tbl_type;
  g_cust_site_use_info_tbl       cust_site_use_info_tbl_type;
  g_cust_acct_info_tbl           cust_acct_info_tbl_type;
  g_geography_type_info_tbl	 geography_type_info_tbl_type;
  g_registration_info_tbl        registration_info_tbl_type;
  g_party_tax_prof_info_tbl	 party_tax_prof_info_tbl_type;
  g_supp_site_info_tbl           supp_site_info_tbl_type;
  g_ccid_acct_string_info_tbl    ccid_acct_string_info_tbltype;
  g_party_tax_prof_id_info_tbl   party_tax_prof_id_info_tbltype;
  g_zx_event_class_rec_tbl       zx_event_class_rec_tbltype;
  g_zx_evnt_typ_map_tbl          evnt_typ_map_tbltype;
  g_zx_evnt_cls_typs_tbl         VARCHAR2_30_tbl_type;
  g_zx_tax_evnt_cls_tbl          tax_event_cls_info_tbltype;

/* ===========================================================*
 | Global Variables                                           |
 * ==========================================================*/
  g_credit_memo_exists_flg       VARCHAR2(1);
  g_ptnr_srvc_subscr_flag	 VARCHAR2(1);
  g_update_event_process_flag    VARCHAR2(1);
  g_bulk_process_flag           VARCHAR2(1);
  g_inventory_installed_flag    VARCHAR2(1);

/* ==========================================================*
 | Public procedures                                         |
 * =================+=======================================*/

  PROCEDURE init_tax_regime_tbl ;
  PROCEDURE init_detail_tax_regime_tbl;
  PROCEDURE init_trx_line_dist_tbl(l_trx_line_index IN  NUMBER);
  PROCEDURE init_trx_line_app_regime_tbl;
  PROCEDURE init_trx_headers_gt;
  PROCEDURE init_trx_lines_gt;
  PROCEDURE delete_trx_line_dist_tbl;
  PROCEDURE get_product_options_info(p_application_id IN NUMBER,
                                     p_org_id         IN NUMBER,
                                     x_product_options_rec OUT NOCOPY zx_product_options_rec_type,
                                     x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE get_regimes_usages_info(p_tax_regime_code IN 	VARCHAR2,
                                   p_first_pty_org_id IN 	NUMBER,
                                   x_regime_usage_id  OUT NOCOPY NUMBER,
                                   x_return_status    OUT NOCOPY VARCHAR2);

  -- overloadded API for bug 8969799
  --
  PROCEDURE get_product_options_info(
    p_application_id         IN            NUMBER,
    p_org_id                 IN            NUMBER,
    p_event_class_mapping_id IN            zx_lines_det_factors.EVENT_CLASS_MAPPING_ID%TYPE,
    x_product_options_rec       OUT NOCOPY zx_product_options_rec_type,
    x_return_status             OUT NOCOPY VARCHAR2);

END ZX_GLOBAL_STRUCTURES_PKG;

/
