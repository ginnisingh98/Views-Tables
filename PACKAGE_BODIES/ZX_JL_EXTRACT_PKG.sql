--------------------------------------------------------
--  DDL for Package Body ZX_JL_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_JL_EXTRACT_PKG" AS
/* $Header: zxriextrajlppvtb.pls 120.38.12010000.15 2010/04/12 22:14:02 skorrapa ship $ */


-----------------------------------------
--Private Type

-----------------------------------------
--

TYPE GDF_RA_CUST_TRX_ATT19_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT19%TYPE INDEX BY BINARY_INTEGER;

TYPE DOCUMENT_SUB_TYPE_MNG_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.DOCUMENT_SUB_TYPE_MNG%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC1_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC1%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC2_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC2%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC3_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC3%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC4_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC4%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC5_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC5%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC6_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC6%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC7_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC7%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC8_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC8%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC9_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC9%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC10_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC10%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC11_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC11%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC12_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC12%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC13_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC13%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC14_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC14%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC15_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC15%TYPE INDEX BY BINARY_INTEGER;

TYPE NUMERIC16_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.NUMERIC1%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE1_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE2_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE3_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE3%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE4_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE5_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE6_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE7_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE7%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE8_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE8%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE9_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE9%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE10_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE10%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE11_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE11%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE12_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE12%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE13_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE13%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE14_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE14%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE15_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE15%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE16_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE16%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE17_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE17%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE18_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE18%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE19_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE19%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE20_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE20%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE21_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE21%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE22_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE22%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE23_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE23%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE25_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE23%TYPE INDEX BY BINARY_INTEGER;

TYPE GDF_RA_BATCH_SOURCES_ATT7_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT7%TYPE INDEX BY BINARY_INTEGER;

TYPE GDF_AP_INV_ATT11_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.GDF_AP_INVOICES_ATT11%TYPE INDEX BY BINARY_INTEGER;

TYPE GDF_AP_INV_ATT12_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.GDF_AP_INVOICES_ATT12%TYPE INDEX BY BINARY_INTEGER;
-----------------------------------------
--Private Methods Declarations
-----------------------------------------
l_err_msg               VARCHAR2(120);

PROCEDURE initialize_variables (
          p_count   IN         NUMBER);

PROCEDURE GET_VAT_AMOUNT
(
P_VAT_TAX                      IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                   IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                  IN            VARCHAR2,
P_REQUEST_ID                   IN            NUMBER,
P_TRX_ID_TBL                   IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TRX_LINE_ID                  IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_DETAIL_TAX_LINE_ID           IN            ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
P_TAX_RATE_TBL                 IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL        IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_VAT_AMT_TBL                  OUT  NOCOPY   NUMERIC9_TBL
);

PROCEDURE GET_TAXABLE_AMOUNT
(
P_VAT_TAX                    IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
P_REQUEST_ID                 IN            NUMBER,
P_DETAIL_TAX_LINE_ID         IN            ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
P_TRX_LINE_ID                IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_TRX_LINE_DIST_ID           IN            ZX_EXTRACT_PKG.TAXABLE_ITEM_SOURCE_ID_TBL,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL      IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_TAXABLE_AMT_TBL            OUT  NOCOPY   NUMERIC10_TBL
);

PROCEDURE GET_NON_TAXABLE_AMOUNT
(
P_NON_TAXAB_TAX              IN            VARCHAR2 DEFAULT NULL,
P_VAT_TAX                    IN            VARCHAR2 DEFAULT NULL,
P_VAT_ADDIT_TAX              IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERCEP_TAX             IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_DETAIL_TAX_LINE_ID           IN            ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
P_TRX_LINE_ID           IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
X_NON_TAXABLE_AMT_TBL        OUT  NOCOPY   NUMERIC8_TBL
);

PROCEDURE GET_VAT_EXEMPT_AMOUNT
(
P_VAT_TAX                    IN            VARCHAR2 DEFAULT NULL,
P_VAT_ADDIT_TAX              IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERCEP_TAX             IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
P_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_DETAIL_TAX_LINE_ID         IN            ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
P_TRX_LINE_ID_TBL            IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL      IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_VAT_EXEMPT_AMT_TBL         OUT  NOCOPY   NUMERIC2_TBL
);

PROCEDURE GET_VAT_ADDITIONAL_AMOUNT
(
P_VAT_ADDIT_TAX              IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_ID_TBL            IN            ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
X_VAT_ADDITIONAL_AMT_TBL     OUT  NOCOPY   NUMERIC7_TBL
);

PROCEDURE GET_NOT_REGISTERED_TAX_AMOUNT
(
P_REPORT_NAME                IN            VARCHAR2 DEFAULT NULL,
P_VAT_ADDIT_TAX              IN            VARCHAR2 DEFAULT NULL,
P_VAT_NOT_CATEG_TAX          IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
P_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL      IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_NOT_REG_TAX_AMT_TBL        OUT  NOCOPY   NUMERIC1_TBL
);

PROCEDURE GET_VAT_PERCEPTION_AMOUNT
(
P_VAT_PERC_TAX_TYPE_FROM     IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERC_TAX_TYPE_TO       IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERC_TAX               IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TRX_LINE_ID_TBL            IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
X_VAT_PERCEPTION_AMT_TBL     OUT  NOCOPY   NUMERIC3_TBL
);

PROCEDURE GET_OTHER_FED_PERC_AMOUNT
(
P_FED_PERC_TAX_TYPE_FROM     IN            VARCHAR2 DEFAULT NULL,
P_FED_PERC_TAX_TYPE_TO       IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERC_TAX               IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
X_OTHER_FED_PERC_AMT_TBL     OUT  NOCOPY   NUMERIC7_TBL
);


PROCEDURE GET_PROVINCIAL_PERC_AMOUNT
(
P_PROV_TAX_TYPE_FROM         IN            VARCHAR2 DEFAULT NULL,
P_PROV_TAX_TYPE_TO           IN            VARCHAR2 DEFAULT NULL,
P_PROV_TAX_REGIME            IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_ID_TBL            IN            ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
X_PROVINCIAL_PERC_AMT_TBL    OUT  NOCOPY   NUMERIC4_TBL
);

PROCEDURE GET_MUNICIPAL_PERC_AMOUNT
(
P_MUN_TAX_TYPE_FROM          IN            VARCHAR2 DEFAULT NULL,
P_MUN_TAX_TYPE_TO            IN            VARCHAR2 DEFAULT NULL,
P_MUN_TAX_REGIME             IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_ID_TBL            IN            ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
X_MUNICIPAL_PERC_AMT_TBL     OUT  NOCOPY   NUMERIC5_TBL
);

PROCEDURE GET_EXCISE_TAX_AMOUNT
(
P_EXC_TAX_TYPE_FROM          IN            VARCHAR2 DEFAULT NULL,
P_EXC_TAX_TYPE_TO            IN            VARCHAR2 DEFAULT NULL,
P_EXC_TAX_REGIME             IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
X_EXCISE_AMT_TBL             OUT NOCOPY    NUMERIC6_TBL
);

PROCEDURE GET_OTHER_TAX_AMOUNT
(
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL      IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_OTHER_TAX_AMT_TBL          OUT  NOCOPY   NUMERIC7_TBL
);

PROCEDURE GET_COUNTED_SUM_DOC
(
P_REPORT_NAME             IN          VARCHAR2,
P_REQUEST_ID              IN          NUMBER,
P_DOCUMENT_SUB_TYPE_TBL   IN          ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_CL_NUM_OF_DOC_TBL       OUT NOCOPY  NUMERIC3_TBL,
X_CL_TOTAL_EXEMPT_TBL     OUT NOCOPY  NUMERIC4_TBL,
X_CL_TOTAL_EFFECTIVE_TBL  OUT NOCOPY  NUMERIC5_TBL,
X_CL_TOTAL_VAT_TAX_TBL    OUT NOCOPY  NUMERIC6_TBL,
X_CL_TOTAL_OTHER_TAX_TBL  OUT NOCOPY  NUMERIC11_TBL
);

PROCEDURE GET_CUSTOMER_CONDITION_CODE
(
P_VAT_PERCEP_TAX              IN         VARCHAR2,
P_TRX_ID_TBL                  IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_INTERNAL_ORG_ID_TBL	      IN         ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
P_REQUEST_ID                  IN         NUMBER,
X_CUST_CONDITION_CODE_TBL     OUT NOCOPY ATTRIBUTE7_TBL
);

PROCEDURE GET_VAT_REG_STAT_CODE
(
P_VAT_TAX                     IN         VARCHAR2,
P_TRX_ID_TBL                  IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_INTERNAL_ORG_ID_TBL 	      IN         ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
P_REQUEST_ID                  IN         NUMBER,
X_VAT_REG_STAT_CODE_TBL       OUT NOCOPY ATTRIBUTE8_TBL
);

FUNCTION GET_TAX_AUTHORITY_CODE
 (
 P_VAT_TAX            IN  ZX_REP_TRX_DETAIL_T.TAX%TYPE,
 P_ORG_ID             IN  NUMBER
 )
return ZX_REP_TRX_JX_EXT_T.ATTRIBUTE10%TYPE;

PROCEDURE GET_FISCAL_PRINTER
(
P_TRX_ID_TBL                  IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL            IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_BILL_FROM_SITE_PROF_ID_TBL IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_SITE_ID_TBL          IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
X_FISCAL_PRINTER_TBL             OUT NOCOPY ATTRIBUTE20_TBL
);

PROCEDURE GET_FISCAL_PRINTER_AR
(
P_TRX_ID_TBL            IN  ZX_EXTRACT_PKG.TRX_ID_TBL,
P_BATCH_SOURCE_ID_TBL   IN  ZX_EXTRACT_PKG.BATCH_SOURCE_ID_TBL,
X_FISCAL_PRINTER_TBL    OUT NOCOPY GDF_RA_BATCH_SOURCES_ATT7_TBL
);

PROCEDURE GET_CAI_NUM
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REPORT_NAME                 IN          VARCHAR2,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_BILL_FROM_SITE_PROF_ID_TBL  IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_SITE_ID_TBL       IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
P_INTERNAL_ORG_ID             IN ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
X_CAI_NUMBER_TBL              OUT NOCOPY ATTRIBUTE19_TBL,
X_CAI_DUE_DATE_TBL            OUT NOCOPY ATTRIBUTE23_TBL
);

PROCEDURE GET_CAI_NUM_AR
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REPORT_NAME                 IN          VARCHAR2,
X_CAI_NUMBER_TBL              OUT NOCOPY ATTRIBUTE19_TBL,
X_CAI_DUE_DATE_TBL            OUT NOCOPY ATTRIBUTE23_TBL
);

PROCEDURE GET_TAX_AUTH_CATEG
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_TAX_RATE_ID_TBL             IN ZX_EXTRACT_PKG.tax_rate_id_tbl,
X_TAX_AUTH_CATEG_TBL          OUT NOCOPY ATTRIBUTE10_TBL
) ;
PROCEDURE PROV_JURISDICTION_CODE
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_TAX_RATE_ID_TBL             IN ZX_EXTRACT_PKG.tax_rate_id_tbl,
X_PROV_JURIS_CODE_TBL          OUT NOCOPY ATTRIBUTE1_TBL
) ;
PROCEDURE MUN_JURISDICTION_CODE
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_TAX_RATE_ID_TBL             IN ZX_EXTRACT_PKG.tax_rate_id_tbl,
X_MUN_JURIS_CODE_TBL          OUT NOCOPY ATTRIBUTE3_TBL
) ;

PROCEDURE GET_TAXPAYERID_TYPE
(
P_TRX_ID_TBL                   IN ZX_EXTRACT_PKG.TRX_ID_TBL,
--P_TAX_REGIME_CODE_TBL        IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
--P_BILL_FROM_SITE_PROF_ID_TBL IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_TP_ID_TBL          IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
X_TAXPAYERID_TYPE_TBL          OUT NOCOPY ATTRIBUTE21_TBL,
X_REG_STATUS_CODE_TBL          OUT NOCOPY ATTRIBUTE22_TBL
);

PROCEDURE GET_DGI_TAX_REGIME_CODE
(
P_VAT_PERCEP_TAX              IN         VARCHAR2,
P_TRX_ID_TBL                  IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TRX_LINE_ID_TBL             IN         ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_INTERNAL_ORG_ID_TBL         IN         ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
P_REQUEST_ID                  IN         NUMBER,
X_DGI_TAX_REGIME_CODE_TBL     OUT NOCOPY ATTRIBUTE25_TBL
);

PROCEDURE GET_DGI_CODE
 (
  P_TRX_NUMBER_TBL        IN         ZX_EXTRACT_PKG.TRX_NUMBER_TBL,
  P_TRX_CATEGORY_TBL      IN         ZX_EXTRACT_PKG.TRX_TYPE_ID_TBL,
  P_ORG_ID_TBL            IN ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
  X_DGI_CODE_TBL          OUT NOCOPY ATTRIBUTE11_TBL
 );
PROCEDURE GET_DGI_DOC_TYPE
(
P_TRX_ID_TBL            IN          ZX_EXTRACT_PKG.TRX_ID_TBL,
X_DGI_DOC_TYPE_TBL      OUT NOCOPY  ATTRIBUTE1_TBL,
X_GDF_AP_INV_ATT11_TBL  OUT NOCOPY  GDF_AP_INV_ATT11_TBL,
X_GDF_AP_INV_ATT12_TBL  OUT NOCOPY  GDF_AP_INV_ATT12_TBL
);

PROCEDURE DGI_TRX_CODE
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_TAX_RATE_ID_TBL             IN ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
X_DGI_TRX_CODE_TBL            OUT NOCOPY ATTRIBUTE4_TBL
);

PROCEDURE UPDATE_DGI_CURR_CODE
(
P_REQUEST_ID IN NUMBER
);

PROCEDURE GET_LOOKUP_INFO
 (
 P_DOCUMENT_SUB_TYPE_TBL              IN          ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
 X_JLCL_AP_DOC_TYPE_MEANING_TBL       OUT NOCOPY  DOCUMENT_SUB_TYPE_MNG_TBL,
 X_ORDER_BY_DOC_TYPE_TBL              OUT NOCOPY  ATTRIBUTE14_TBL
 );

PROCEDURE GET_REC_COUNT
(
P_VAT_TAX            IN          ZX_REP_TRX_DETAIL_T.TAX%TYPE,
P_TAX_REGIME         IN          ZX_REP_TRX_DETAIL_T.TAX_REGIME_CODE%TYPE,
P_TRX_ID_TBL         IN          ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REQUEST_ID         IN          NUMBER,
X_REC_COUNT_TBL      OUT NOCOPY  NUMERIC11_TBL
);

PROCEDURE GET_VAT_NONVAT_RATE_COUNT
(
P_VAT_TAX            IN          ZX_REP_TRX_DETAIL_T.TAX%TYPE,
P_VAT_NON_TAX        IN          ZX_REP_TRX_DETAIL_T.TAX%TYPE,
P_TAX_REGIME         IN          ZX_REP_TRX_DETAIL_T.TAX_REGIME_CODE%TYPE,
P_TRX_ID_TBL         IN          ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REQUEST_ID         IN          NUMBER,
X_RATE_COUNT_TBL     OUT NOCOPY  NUMERIC13_TBL
);

PROCEDURE GET_TOTAL_DOCUMENT_AMOUNT
(
P_TRX_ID_TBL                IN          ZX_EXTRACT_PKG.TRX_ID_TBL,
P_EXCHANGE_RATE_TBL         IN          ZX_EXTRACT_PKG.CURRENCY_CONVERSION_RATE_TBL,
P_REPORT_NAME               IN          VARCHAR2,
X_TOTAL_DOC_AMT_TBL         OUT NOCOPY  NUMERIC12_TBL
);

PROCEDURE GET_TOTAL_DOC_TAXABLE_AMOUNT
(
P_TRX_ID_TBL               IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REQUEST_ID               IN         NUMBER,
X_TOTAL_DOC_TAXAB_AMT_TBL  OUT NOCOPY NUMERIC8_TBL
);

-- Declare global varibles for FND log messages

   g_current_runtime_level           NUMBER;
   g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
   g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
   g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
   g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
   g_error_buffer                    VARCHAR2(100);


-- Public APIs

PROCEDURE FILTER_JL_AP_TAX_LINES
IS
BEGIN

null;

END FILTER_JL_AP_TAX_LINES;

PROCEDURE FILTER_JL_AR_TAX_LINES
   (P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
   ) IS
BEGIN

	g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES.BEGIN',
				      'ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES(+)');
	END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES',
		      'P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME : '||P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES',
		      'P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX : '||P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX );
	END IF;

  IF P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'JLARTPFF' THEN

    DELETE from ZX_REP_TRX_DETAIL_T DET
       WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
        AND  DET.TAX <> P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX;
 /*   DELETE from ZX_REP_TRX_DETAIL_T DET
       WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID and
             NOT EXISTS
             (SELECT 1
              FROM   jl_zz_ar_tx_categ_all   catg,
                     jl_zz_ar_tx_att_cls_all attcls,
                     jl_zz_ar_tx_att_val_all val
              WHERE  attcls.tax_attribute_value = val.tax_attribute_value
                AND  attcls.tax_category_id     = val.tax_category_id
                AND  attcls.tax_attribute_name  = val.tax_attribute_name
                AND  val.tax_attribute_type   = 'TRANSACTION_ATTRIBUTE'
       -- nipatel we should add join to attcls.TAX_ATTRIBUTE_TYPE, attcls.TAX_ATTR_CLASS_TYPE,
       -- attcls.TAX_ATTR_CLASS_CODE for proper use of index
                AND  attcls.tax_category_id     = catg.tax_category_id
                AND  catg.org_id = det.internal_organization_id
                AND  catg.org_id = attcls.org_id
                AND  catg.org_id = val.org_id
                AND  attcls.tax_attr_class_code = det.TRX_BUSINESS_CATEGORY
                AND  det.tax = P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX);
*/
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;
  END IF;

	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES.BEGIN',
				      'ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES(-)');
	END IF;


END FILTER_JL_AR_TAX_LINES;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   POPULATE_JL_AP                                                          |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure extract tax amount for various tax types                |
 |    from zx_rep_trx_jx_ext_t table to meet the requirement in            |
 |    the flat file                                                          |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                              |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  P_MUN_TAX_TYPE_FROM         IN   VARCHAR2 Optional        |
 |                 P_MUN_TAX_TYPE_TO           IN   VARCHAR2 Optional        |
 |                 P_PROV_TAX_TYPE_FROM        IN   VARCHAR2 Optional        |
 |                 P_PROV_TAX_TYPE_TO          IN   VARCHAR2 Optional        |
 |                 P_EXC_TAX_TYPE_FROM         IN   VARCHAR2 Optional        |
 |                 P_EXC_TAX_TYPE_TO           IN   VARCHAR2 Optional        |
 |                 P_NON_TAXAB_TAX_TYPE        IN   VARCHAR2 Optional        |
 |                 P_VAT_PERC_TAX_TYPE_FROM    IN   VARCHAR2 Optional        |
 |                 P_VAT_PERC_TAX_TYPE_TO      IN   VARCHAR2 Optional        |
 |                 P_VAT_TAX_TYPE              IN   VARCHAR2 Optional        |
 |                 P_REPORT_NAME               IN   VARCHAR2 Required        |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |     17-Feb-04  Hidekoji          Modified Parameters                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE POPULATE_JL_AP(
          P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
          )
IS

P_REQUEST_ID                    NUMBER;
P_REPORT_NAME                   VARCHAR2(30);
P_TRANSACTION_LETTER_FROM       VARCHAR2(30);
P_TRANSACTION_LETTER_TO         VARCHAR2(30);
P_EXCLUDING_TRX_LETTER          VARCHAR2(30);
P_MUN_TAX_TYPE_FROM             VARCHAR2(30);
P_MUN_TAX_TYPE_TO               VARCHAR2(30);
P_PROV_TAX_TYPE_FROM            VARCHAR2(30);
P_PROV_TAX_TYPE_TO              VARCHAR2(30);
P_EXC_TAX_TYPE_FROM             VARCHAR2(30);
P_EXC_TAX_TYPE_TO               VARCHAR2(30);
P_NON_TAXAB_TAX_TYPE            VARCHAR2(30);
P_VAT_PERC_TAX                  VARCHAR2(30);
P_VAT_PERC_TAX_TYPE_FROM        VARCHAR2(30);
P_VAT_PERC_TAX_TYPE_TO          VARCHAR2(30);
P_FED_PERC_TAX_TYPE_FROM        VARCHAR2(30);
P_FED_PERC_TAX_TYPE_TO          VARCHAR2(30);
P_VAT_TAX_TYPE                  VARCHAR2(30);
P_TAX_TYPE_CODE_LOW                  VARCHAR2(30);
P_TAX_TYPE_CODE_HIGH                  VARCHAR2(30);
P_TAX_TYPE_CODE                  VARCHAR2(30);
P_VAT_ADDIT_TAX_TYPE            VARCHAR2(30);

l_err_msg                       VARCHAR2(120);

l_internal_org_id_tbl           ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL;
l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_trx_line_id_tbl               ZX_EXTRACT_PKG.TRX_LINE_ID_TBL;
l_trx_line_dist_id_tbl          ZX_EXTRACT_PKG.TAXABLE_ITEM_SOURCE_ID_TBL;
l_trx_id_tbl                    ZX_EXTRACT_PKG.TRX_ID_TBL;
l_tax_rate_tbl                  ZX_EXTRACT_PKG.TAX_RATE_TBL;
l_tax_rate_id_tbl               ZX_EXTRACT_PKG.TAX_RATE_ID_TBL;
l_document_sub_type_tbl         ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL;
l_exchange_rate_tbl             ZX_EXTRACT_PKG.CURRENCY_CONVERSION_RATE_TBL;
l_trx_currency_code_tbl         ZX_EXTRACT_PKG.TRX_CURRENCY_CODE_TBL;
l_vat_exempt_amt_tbl            NUMERIC2_TBL;
l_vat_perc_amt_tbl              NUMERIC3_TBL;
l_other_fed_perc_amt_tbl        NUMERIC7_TBL;
l_prov_perc_amt_tbl             NUMERIC4_TBL;
l_munic_perc_amt_tbl            NUMERIC5_TBL;
l_excise_amt_tbl                NUMERIC6_TBL;
l_non_taxable_amt_tbl           NUMERIC8_TBL;
l_other_tax_amt_tbl             NUMERIC7_TBL;
l_vat_amt_tbl                   NUMERIC9_TBL;
l_dgi_doc_type_tbl              ATTRIBUTE1_TBL;
l_tax_auth_categ_tbl            ATTRIBUTE10_TBL;
l_gdf_ap_inv_att11_tbl          GDF_AP_INV_ATT11_TBL;
l_gdf_ap_inv_att12_tbl          GDF_AP_INV_ATT12_TBL;
l_dgi_trx_code_tbl              ATTRIBUTE4_TBL;
l_taxable_amt_tbl               NUMERIC10_TBL;
l_total_doc_amt_tbl             NUMERIC12_TBL;
l_total_doc_taxab_amt_tbl       NUMERIC8_TBL;

l_cl_num_of_doc_tbl             NUMERIC3_TBL;
l_cl_total_exempt_tbl           NUMERIC4_TBL;
l_cl_total_effective_tbl        NUMERIC5_TBL;
l_cl_total_vat_tax_tbl          NUMERIC6_TBL;
l_cl_total_other_tax_tbl        NUMERIC11_TBL;

l_order_by_doc_type_tbl         ATTRIBUTE14_TBL;
l_cai_number_tbl                ATTRIBUTE19_TBL;
l_cai_due_date_tbl              ATTRIBUTE23_TBL;
l_fiscal_printer_tbl            ATTRIBUTE20_TBL;
l_taxpayerid_type_tbl           ATTRIBUTE21_TBL;
l_reg_status_code_tbl           ATTRIBUTE22_TBL;
l_jlcl_ap_doc_type_mng_tbl      DOCUMENT_SUB_TYPE_MNG_TBL;

l_tax_regime_code_tbl           ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL;
l_bill_from_site_prof_id_tbl      ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL;
--l_shipping_tp_address_id_tbl          ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL;
--l_billing_tp_address_id_tbl           ZX_EXTRACT_PKG.BILLING_TP_ADDRESS_ID_TBL;
l_bill_from_site_id_tbl     ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL;
l_bill_from_tp_id_tbl        ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL;

BEGIN

 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP.BEGIN',
                                      'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP(+)');
  END IF;


 P_REQUEST_ID              :=  P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;
 P_REPORT_NAME             :=  P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME;
 P_TRANSACTION_LETTER_FROM :=  P_TRL_GLOBAL_VARIABLES_REC.TRX_LETTER_LOW;
 P_TRANSACTION_LETTER_TO   :=  P_TRL_GLOBAL_VARIABLES_REC.TRX_LETTER_HIGH;
 P_EXCLUDING_TRX_LETTER    :=  P_TRL_GLOBAL_VARIABLES_REC.EXCLUDING_TRX_LETTER;
 P_MUN_TAX_TYPE_FROM       :=  P_TRL_GLOBAL_VARIABLES_REC.MUNICIPAL_TAX_TYPE_CODE_LOW;
 P_MUN_TAX_TYPE_TO         :=  P_TRL_GLOBAL_VARIABLES_REC.MUNICIPAL_TAX_TYPE_CODE_HIGH;
 P_PROV_TAX_TYPE_FROM      :=  P_TRL_GLOBAL_VARIABLES_REC.PROV_TAX_TYPE_CODE_LOW;
 P_PROV_TAX_TYPE_TO        :=  P_TRL_GLOBAL_VARIABLES_REC.PROV_TAX_TYPE_CODE_HIGH;
 P_EXC_TAX_TYPE_FROM       :=  P_TRL_GLOBAL_VARIABLES_REC.EXCISE_TAX_TYPE_CODE_LOW;
 P_EXC_TAX_TYPE_TO         :=  P_TRL_GLOBAL_VARIABLES_REC.EXCISE_TAX_TYPE_CODE_HIGH;
 P_NON_TAXAB_TAX_TYPE      :=  P_TRL_GLOBAL_VARIABLES_REC.NON_TAXABLE_TAX_TYPE_CODE;
 P_VAT_PERC_TAX_TYPE_FROM  :=  P_TRL_GLOBAL_VARIABLES_REC.PER_TAX_TYPE_CODE_LOW;
 P_VAT_PERC_TAX_TYPE_TO    :=  P_TRL_GLOBAL_VARIABLES_REC.PER_TAX_TYPE_CODE_HIGH;
 P_VAT_PERC_TAX            :=  P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX;
 P_FED_PERC_TAX_TYPE_FROM  :=  P_TRL_GLOBAL_VARIABLES_REC.FED_PER_TAX_TYPE_CODE_LOW;
 P_FED_PERC_TAX_TYPE_TO    :=  P_TRL_GLOBAL_VARIABLES_REC.FED_PER_TAX_TYPE_CODE_HIGH;
 P_TAX_TYPE_CODE_LOW       :=  P_TRL_GLOBAL_VARIABLES_REC.TAX_TYPE_CODE_LOW;
 P_TAX_TYPE_CODE_HIGH      :=  P_TRL_GLOBAL_VARIABLES_REC.TAX_TYPE_CODE_HIGH;
 P_VAT_TAX_TYPE            :=  P_TRL_GLOBAL_VARIABLES_REC.VAT_TAX_TYPE_CODE;
 P_VAT_ADDIT_TAX_TYPE      :=  P_TRL_GLOBAL_VARIABLES_REC.VAT_ADDITIONAL_TAX;

--added debug messages

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP','P_REPORT_NAME : '||P_REPORT_NAME);
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_TRANSACTION_LETTER_FROM :'|| P_TRANSACTION_LETTER_FROM);
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_TRANSACTION_LETTER_TO   :'|| P_TRANSACTION_LETTER_TO  );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_EXCLUDING_TRX_LETTER    :'|| P_EXCLUDING_TRX_LETTER   );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_MUN_TAX_TYPE_FROM       :'|| P_MUN_TAX_TYPE_FROM      );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_MUN_TAX_TYPE_TO         :'|| P_MUN_TAX_TYPE_TO        );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_PROV_TAX_TYPE_FROM      :'|| P_PROV_TAX_TYPE_FROM     );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_PROV_TAX_TYPE_TO        :'|| P_PROV_TAX_TYPE_TO       );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_EXC_TAX_TYPE_FROM       :'|| P_EXC_TAX_TYPE_FROM      );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_EXC_TAX_TYPE_TO         :'|| P_EXC_TAX_TYPE_TO        );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_NON_TAXAB_TAX_TYPE      :'|| P_NON_TAXAB_TAX_TYPE     );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_VAT_PERC_TAX_TYPE_FROM  :'|| P_VAT_PERC_TAX_TYPE_FROM );
FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_VAT_PERC_TAX_TYPE_TO    :'|| P_VAT_PERC_TAX_TYPE_TO   );
         FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_VAT_PERC_TAX    :'|| P_VAT_PERC_TAX);
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_FED_PERC_TAX_TYPE_FROM  :'|| P_FED_PERC_TAX_TYPE_FROM );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_FED_PERC_TAX_TYPE_TO    :'|| P_FED_PERC_TAX_TYPE_TO   );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_TAX_TYPE_CODE_LOW       :'|| P_TAX_TYPE_CODE_LOW      );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_TAX_TYPE_CODE_HIGH      :'|| P_TAX_TYPE_CODE_HIGH     );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_VAT_TAX_TYPE            :'|| P_VAT_TAX_TYPE           );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',' P_VAT_ADDIT_TAX_TYPE  :'|| P_VAT_ADDIT_TAX_TYPE );
    END IF;

 IF P_REPORT_NAME = 'JLARPCFF' THEN


    BEGIN

         -- ------------------------------------------------ --
         -- Get filtered tax lines                           --
         -- in this case, you need to group the lines by trx --
         -- ------------------------------------------------ --
  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
                                      'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP : Filter '||P_REPORT_NAME);
  END IF;

         P_TAX_TYPE_CODE := NVL(P_TAX_TYPE_CODE_LOW,P_TAX_TYPE_CODE_HIGH);

                    SELECT min(itf.detail_tax_line_id),
                           itf.trx_id,
                           null,
                           null
         BULK COLLECT INTO l_detail_tax_line_id_tbl,
                           l_trx_id_tbl,
                           l_tax_rate_tbl,
                           l_document_sub_type_tbl
                      FROM zx_rep_trx_detail_t itf,
                           ap_invoices apinv
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = apinv.invoice_id
                       AND itf.tax_type_code = P_TAX_TYPE_CODE
                       AND apinv.global_attribute12 >= P_TRANSACTION_LETTER_FROM
                       AND apinv.global_attribute12 <= P_TRANSACTION_LETTER_TO
                  GROUP BY itf.trx_id;

 IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
               'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP : Bulk Collect Filtered rows '||to_char(l_trx_id_tbl.count));
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
               'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP : '||P_VAT_TAX_TYPE||P_TRANSACTION_LETTER_FROM||P_TRANSACTION_LETTER_TO);
  END IF;


	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_VAT_AMOUNT ');
	END IF;

         -- Get Vat Amount --

         GET_VAT_AMOUNT(P_TAX_TYPE_CODE,
                        NULL,
                        P_REPORT_NAME,
                        P_REQUEST_ID,
                        l_trx_id_tbl,
                        l_trx_line_id_tbl,
                        l_detail_tax_line_id_tbl,
                        l_tax_rate_tbl,
                        l_document_sub_type_tbl,
                        l_vat_amt_tbl);

         GET_DGI_DOC_TYPE(l_trx_id_tbl,
                          l_dgi_doc_type_tbl,
                          l_gdf_ap_inv_att11_tbl,
                          l_gdf_ap_inv_att12_tbl
                          );


         -- Insert lines into JX EXT Table with Calculated amount --

         FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                detail_tax_line_id,
                                                numeric9,
                                                gdf_ap_invoices_att13,
                                                created_by,
                                                creation_date,
                                                last_updated_by,
                                                last_update_date,
                                                last_update_login)
                                        VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                l_detail_tax_line_id_tbl(i),
                                                l_vat_amt_tbl(i),
                                                l_dgi_doc_type_tbl(i),
                                                fnd_global.user_id,
                                                sysdate,
                                                fnd_global.user_id,
                                                sysdate,
                                                fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

                -- Delete Unwanted lines from Detail ITF

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;


    EXCEPTION
       WHEN OTHERS THEN
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
		'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
	END IF;

    END;


 ELSIF P_REPORT_NAME = 'ZXARPVBR' THEN

       BEGIN

       -- ------------------------------------------------ --
       -- Get filtered tax lines                           --
       -- in this case, you need to group the lines by trx --
       -- ------------------------------------------------ --

                       SELECT itf.detail_tax_line_id,
                              itf.trx_line_id,
                              itf.trx_id,
                              itf.tax_rate,
                              null
            BULK COLLECT INTO l_detail_tax_line_id_tbl,
                              l_trx_line_id_tbl,
                              l_trx_id_tbl,
                              l_tax_rate_tbl,
                              l_document_sub_type_tbl
                         FROM zx_rep_trx_detail_t itf,
                              ap_invoices_all apinv --Bug 5415028
                        WHERE itf.request_id = P_REQUEST_ID
                          AND itf.tax_type_code = P_VAT_TAX_TYPE
                      -- OR itf.tax_rate = 0)
--itf.tax_type_code = 'Exempt')
                          AND itf.trx_id = apinv.invoice_id
                          AND apinv.global_attribute12 <>  NVL(P_EXCLUDING_TRX_LETTER,'$') --Bug 5415028
                          AND nvl(itf.reverse_flag,'N') <> 'Y'
                          ORDER by itf.trx_id, itf.trx_line_id, itf.tax_rate,
                                 itf.detail_tax_line_id;
                  --   GROUP BY itf.tax_rate,
                        --      itf.trx_line_id,
                         --     itf.trx_id;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_DOC_TYPE',
					      'Before Call to GET_DGI_DOC_TYPE');
	END IF;
         GET_DGI_DOC_TYPE(l_trx_id_tbl,
                          l_dgi_doc_type_tbl,
                          l_gdf_ap_inv_att11_tbl,
                          l_gdf_ap_inv_att12_tbl
                          );

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_VAT_AMOUNT');
	END IF;

       -- Get Vat amount
       GET_VAT_AMOUNT(P_VAT_TAX_TYPE,
                      NULL,
                      P_REPORT_NAME,
                      P_REQUEST_ID,
                      l_trx_id_tbl,
                      l_trx_line_id_tbl,
                      l_detail_tax_line_id_tbl,
                      l_tax_rate_tbl,
                      l_document_sub_type_tbl,
                      l_vat_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_TAXABLE_AMOUNT');
	END IF;

       -- Get Taxable Amount
       GET_TAXABLE_AMOUNT(P_VAT_TAX_TYPE,
                          NULL,
                          P_REPORT_NAME,
                          P_REQUEST_ID,
                          l_detail_tax_line_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_line_dist_id_tbl,
                          l_trx_id_tbl,
                          l_tax_rate_tbl,
                          l_document_sub_type_tbl,
                          l_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_NON_TAXABLE_AMOUNT');
	END IF;
       -- Get Non Taxable Amount
       GET_NON_TAXABLE_AMOUNT(P_NON_TAXAB_TAX_TYPE,
                              P_VAT_TAX_TYPE,
                              P_VAT_ADDIT_TAX_TYPE,
                              null, --P_VAT_PERCEP_TAX_TYPE,
                              P_REPORT_NAME,
                              p_REQUEST_ID,
                              l_trx_id_tbl,
                              l_detail_tax_line_id_tbl,
                              l_trx_line_id_tbl,
                              l_tax_rate_tbl,
                              l_non_taxable_amt_tbl);


	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_VAT_EXEMPT_AMOUNT');
	END IF;

       -- Get Vat Exempt Amount
       GET_VAT_EXEMPT_AMOUNT(P_VAT_TAX_TYPE,
                             P_VAT_ADDIT_TAX_TYPE,
                             NULL, --P_VAT_PERCEP_TAX_TYPE,
                             P_REPORT_NAME,
                             NULL, -- P_TAX_REGIME
                             P_REQUEST_ID,
                             l_trx_id_tbl,
                             l_detail_tax_line_id_tbl,
                             l_trx_line_id_tbl,
                             l_tax_rate_tbl,
                             l_document_sub_type_tbl,
                             l_vat_exempt_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_VAT_PERCEPTION_AMOUNT');
	END IF;

       -- Get Vat Perception Amount
       GET_VAT_PERCEPTION_AMOUNT(P_VAT_PERC_TAX_TYPE_FROM,
                                 P_VAT_PERC_TAX_TYPE_TO,
                                 P_VAT_PERC_TAX,
                                 NULL, -- P_TAX_REGIME
                                 P_REPORT_NAME,
                                 p_REQUEST_ID,
                                 l_trx_id_tbl,
                                 l_trx_line_id_tbl,
                                 l_tax_rate_tbl,
                                 l_vat_perc_amt_tbl);

         -- Insert lines into JX EXT Table with Calculated amount --

         FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                detail_tax_line_id,
                                                numeric9,
                                                numeric10,
                                                numeric8,
                                                numeric2,
                                                numeric3,
                                                numeric12,
                                                gdf_ap_invoices_att11,
                                                gdf_ap_invoices_att12,
                                                created_by,
	                                        creation_date,
                                                last_updated_by,
                                                last_update_date,
                                                last_update_login,
                                                request_id)
                                        VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                l_detail_tax_line_id_tbl(i),
                                                l_vat_amt_tbl(i),
                                                l_taxable_amt_tbl(i),
                                                l_non_taxable_amt_tbl(i),
                                                l_vat_exempt_amt_tbl(i),
                                                l_vat_perc_amt_tbl(i),
                                                nvl(l_non_taxable_amt_tbl(i),0)+nvl(l_vat_perc_amt_tbl(i),0)
                                                   +nvl(l_taxable_amt_tbl(i),0)+nvl(l_vat_amt_tbl(i),0)
                                                   +nvl(l_vat_exempt_amt_tbl(i),0), --Bug 5415028
                                                l_gdf_ap_inv_att11_tbl(i),
                                                l_gdf_ap_inv_att12_tbl(i),
                                                fnd_global.user_id,
                                                sysdate,
                                                fnd_global.user_id,
                                                sysdate,
                                                fnd_global.login_id,
                                                p_request_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

                -- Delete Unwanted lines from Detail ITF


  DELETE FROM zx_rep_trx_jx_ext_t
  WHERE detail_tax_line_id not in ( SELECT min(itf.detail_tax_line_id)
                                    FROM zx_rep_trx_detail_t itf,
                                         ap_invoices_all apinv
                                   WHERE itf.request_id = P_REQUEST_ID
                                     AND itf.tax_type_code = P_VAT_TAX_TYPE
                                     AND itf.trx_id = apinv.invoice_id
                                     AND apinv.global_attribute12 <> NVL(P_EXCLUDING_TRX_LETTER,'$') --Bug 5415028
                                     AND nvl(itf.reverse_flag,'N') <> 'Y'
                                   GROUP BY itf.tax_rate,
                                            itf.trx_line_id,
                                            itf.trx_id);

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JL_AP',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;

    EXCEPTION


       WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
			'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;

    END;


 ELSIF P_REPORT_NAME = 'JLARPPFF' THEN

       BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
                                      'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP : Filter '||P_REPORT_NAME);
  END IF;
       -- ------------------------------------------------ --
       -- Get filtered tax lines                           --
       -- ------------------------------------------------ --

                       SELECT detail_tax_line_id,
                              trx_line_id,
                              trx_id,
                              currency_conversion_rate,
                             -- trx_currency_code,
                              tax_rate,
                              tax_rate_id,
                              document_sub_type,
                              tax_regime_code,
                              bill_from_site_tax_prof_id,
                            --  shipping_tp_address_id,
                             -- billing_tp_address_id
                              bill_from_site_id,
                              bill_from_party_id,
                              internal_organization_id
            BULK COLLECT INTO l_detail_tax_line_id_tbl,
                                l_trx_line_id_tbl,
                              l_trx_id_tbl,
                              l_exchange_rate_tbl,
                              --l_trx_currency_code_tbl,
                              l_tax_rate_tbl,
                              l_tax_rate_id_tbl,
                              l_document_sub_type_tbl,
                              l_tax_regime_code_tbl,
                              l_bill_from_site_prof_id_tbl,
                              l_bill_from_site_id_tbl,
                              l_bill_from_tp_id_tbl,
                              l_internal_org_id_tbl
                         FROM
                             ( SELECT min(itf1.detail_tax_line_id) detail_tax_line_id,
                                      itf1.trx_line_id,
                                      itf1.trx_id,
                                      null currency_conversion_rate,
                               --       itf1.trx_currency_code,
                                      itf1.tax_rate,
                                       itf1.tax_rate_id,
                                      null document_sub_type,
                                      itf1.tax_regime_code,
                                      itf1.bill_from_site_tax_prof_id,
                                   NVL(itf1.shipping_tp_address_id,
                                       itf1.billing_tp_address_id) bill_from_site_id,
                                   NVL(itf1.billing_trading_partner_id,
                                       itf1.shipping_trading_partner_id) bill_from_party_id,
                                       itf1.internal_organization_id
                                 FROM zx_rep_trx_detail_t itf1,
                                      ap_invoices apinv
                                WHERE itf1.request_id = P_REQUEST_ID
                                  AND apinv.invoice_id = itf1.trx_id
                              --    AND itf1.posted_flag = 'Y'
                                  AND itf1.tax_type_code = P_VAT_TAX_TYPE
                                  AND apinv.global_attribute12 <> NVL(p_excluding_trx_letter, '$')
                             GROUP BY itf1.trx_id,
                                      itf1.trx_line_id,
                                      itf1.tax_rate,
                                      itf1.tax_rate_id,
                                --      itf1.trx_currency_code,
                                      itf1.tax_regime_code,
                                      itf1.bill_from_site_tax_prof_id,
                                      itf1.shipping_tp_address_id,
                                      itf1.billing_tp_address_id,
                                      itf1.billing_trading_partner_id,
                                       itf1.internal_organization_id,
                                      itf1.shipping_trading_partner_id)
                               UNION
                             ( SELECT min(itf1.detail_tax_line_id) detail_tax_line_id,
                                      itf1.trx_line_id,
                                      itf1.trx_id,
                                      null currency_conversion_rate,
                                 --     itf1.trx_currency_code,
                                      itf1.tax_rate,
                                      itf1.tax_rate_id,
                                      null document_sub_type,
                                      itf1.tax_regime_code,
                                      itf1.bill_from_site_tax_prof_id,
                                   NVL(itf1.shipping_tp_address_id,
                                       itf1.billing_tp_address_id) bill_from_site_id,
                                   NVL(itf1.billing_trading_partner_id,
                                       itf1.shipping_trading_partner_id) bill_from_party_id,
                                       itf1.internal_organization_id
                                 FROM zx_rep_trx_detail_t itf1,
                                      ap_invoices apinv
                                WHERE itf1.request_id = P_REQUEST_ID
                                  AND apinv.invoice_id = itf1.trx_id
                              --    AND itf1.posted_flag = 'Y'
                                  AND itf1.tax_type_code = 'Exempt'
                                  AND apinv.global_attribute12 <> NVL(p_excluding_trx_letter, '$')
                             GROUP BY itf1.trx_id,
                                      itf1.trx_line_id,
                                      itf1.tax_rate,
                                      itf1.tax_rate_id,
                                  --    itf1.trx_currency_code,
                                      itf1.tax_regime_code,
                                      itf1.bill_from_site_tax_prof_id,
                                      itf1.shipping_tp_address_id,
                                      itf1.billing_tp_address_id,
                                      itf1.billing_trading_partner_id,
                                       itf1.internal_organization_id,
                                      itf1.shipping_trading_partner_id)
                                 UNION
                             ( SELECT min(itf1.detail_tax_line_id) detail_tax_line_id,
                                      itf1.trx_line_id,
                                      itf1.trx_id,
                                      null currency_conversion_rate,
                                 --     itf1.trx_currency_code,
                                      NULL tax_rate,
                                      itf1.tax_rate_id,
                                      --null tax_rate_id,
                                      null document_sub_type,
                                      itf1.tax_regime_code,
                                      itf1.bill_from_site_tax_prof_id,
                                   NVL(itf1.shipping_tp_address_id,
                                       itf1.billing_tp_address_id) bill_from_site_id,
                                   NVL(itf1.billing_trading_partner_id,
                                       itf1.shipping_trading_partner_id) bill_from_party_id,
                                       itf1.internal_organization_id
                                 FROM zx_rep_trx_detail_t itf1,
                                      ap_invoices apinv
                                WHERE itf1.request_id = P_REQUEST_ID
                                  AND apinv.invoice_id = itf1.trx_id
                              --    AND itf1.posted_flag = 'Y'
                                  AND itf1.tax_type_code = P_NON_TAXAB_TAX_TYPE
                                  AND apinv.global_attribute12 <> NVL(p_excluding_trx_letter, '$')
                             GROUP BY itf1.trx_id,
                                      itf1.trx_line_id,
                                     -- itf1.tax_rate,
                                      itf1.tax_rate_id,
                                  --    itf1.trx_currency_code,
                                      itf1.tax_regime_code,
                                      itf1.bill_from_site_tax_prof_id,
                                      itf1.shipping_tp_address_id,
                                      itf1.billing_tp_address_id,
                                      itf1.billing_trading_partner_id,
                                      itf1.internal_organization_id,
                                      itf1.shipping_trading_partner_id);
                               /* UNION
                               SELECT min(itf2.detail_tax_line_id) detail_tax_line_id,
                                      itf2.trx_id,
                                      null currency_conversion_rate,
                                      null tax_rate,
                                      null tax_rate_id,
                                      null document_sub_type
                                 FROM zx_rep_trx_detail_t itf2,
                                      ap_invoices apinv2
                                WHERE itf2.request_id = P_REQUEST_ID
                                  AND apinv2.invoice_id = itf2.trx_id
                                  AND itf2.tax_type_code = P_NON_TAXAB_TAX_TYPE
                                GROUP BY itf2.trx_id
                              );*/

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
               'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP : Bulk Collect Filtered rows '||to_char(l_trx_id_tbl.count));
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
               'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP : '||P_VAT_TAX_TYPE);
  END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_VAT_AMOUNT');
	END IF;

         --GET_DGI_DOC_TYPE(l_trx_id_tbl,
          --                l_dgi_doc_type_tbl);

         GET_DGI_DOC_TYPE(l_trx_id_tbl,
                          l_dgi_doc_type_tbl,
                          l_gdf_ap_inv_att11_tbl,
                          l_gdf_ap_inv_att12_tbl
                          );
         DGI_TRX_CODE ( l_trx_id_tbl,
                        l_tax_regime_code_tbl,
                        l_tax_rate_id_tbl,
                        l_dgi_trx_code_tbl);


         GET_TAXPAYERID_TYPE(l_trx_id_tbl,
                            -- l_tax_regime_code_tbl,
                            -- l_bill_from_site_prof_id_tbl,
                             l_bill_from_tp_id_tbl,
                             l_taxpayerid_type_tbl,
                             l_reg_status_code_tbl);

            -- get CAI Number
             GET_CAI_NUM
                  ( l_trx_id_tbl,
                    p_report_name,
                    l_tax_regime_code_tbl,
                    l_bill_from_site_prof_id_tbl,
                    l_bill_from_site_id_tbl,
                    l_internal_org_id_tbl,
                    l_cai_number_tbl,
                    l_cai_due_date_tbl);

            -- get Fiscal Printer
             GET_FISCAL_PRINTER
                  ( l_trx_id_tbl,
                    l_tax_regime_code_tbl,
                    l_bill_from_site_prof_id_tbl,
                    l_bill_from_site_id_tbl,
                    l_fiscal_printer_tbl);


            -- Get Vat Amount
            GET_VAT_AMOUNT(P_VAT_TAX_TYPE,
                           NULL,
                           P_REPORT_NAME,
                           P_REQUEST_ID,
                           l_trx_id_tbl,
                        l_trx_line_id_tbl,
                           l_detail_tax_line_id_tbl,
                           l_tax_rate_tbl,
                           l_document_sub_type_tbl,
                           l_vat_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_TAXABLE_AMOUNT');
	END IF;

            -- Get Taxable Amount
            GET_TAXABLE_AMOUNT(P_VAT_TAX_TYPE,
                               NULL,
                               P_REPORT_NAME,
                               P_REQUEST_ID,
                          l_detail_tax_line_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_line_dist_id_tbl,
                               l_trx_id_tbl,
                               l_tax_rate_tbl,
                               l_document_sub_type_tbl,
                               l_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_NON_TAXABLE_AMOUNT');
	END IF;
            -- Get Non Taxable Amount
            GET_NON_TAXABLE_AMOUNT(P_NON_TAXAB_TAX_TYPE,
                                   P_VAT_TAX_TYPE,
                                   P_VAT_ADDIT_TAX_TYPE,
                                   NULL, --P_VAT_PERCEP_TAX_TYPE,
                                   P_REPORT_NAME,
                                   p_REQUEST_ID,
                                   l_trx_id_tbl,
                              l_detail_tax_line_id_tbl,
                              l_trx_line_id_tbl,
                                   l_tax_rate_tbl,
                                   l_non_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_VAT_EXEMPT_AMOUNT');
	END IF;
	    -- Get Vat Exempt Amount
            GET_VAT_EXEMPT_AMOUNT(P_VAT_TAX_TYPE,
                                  NULL, -- P_VAT_ADDIT_TAX
                                  NULL, -- P_VAT_PERCEP_TAX
                                  P_REPORT_NAME,
                                  NULL, -- P_TAX_REGIME
                                  P_REQUEST_ID,
                                  l_trx_id_tbl,
                                  l_detail_tax_line_id_tbl,
                                  l_trx_line_id_tbl,
                                  l_tax_rate_tbl,
                                  l_document_sub_type_tbl,
                                  l_vat_exempt_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_VAT_PERCEPTION_AMOUNT');
	END IF;
	    -- Get Vat Perception Amount
            GET_VAT_PERCEPTION_AMOUNT(P_VAT_PERC_TAX_TYPE_FROM,
                                      P_VAT_PERC_TAX_TYPE_TO,
                                      NULL, -- P_VAT_PERC_TAX,
                                      NULL, -- P_TAX_REGIME,
                                      P_REPORT_NAME,
                                      P_REQUEST_ID,
                                      l_trx_id_tbl,
                                 l_trx_line_id_tbl,
                                      l_tax_rate_tbl,
                                      l_vat_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_OTHER_FED_PERC_AMOUNT');
	END IF;
	    -- Get Other Federal Perception Amount
            GET_OTHER_FED_PERC_AMOUNT(P_FED_PERC_TAX_TYPE_FROM,
                                      P_FED_PERC_TAX_TYPE_TO,
                                      NULL, -- P_VAT_PERC_TAX,
                                      NULL, -- P_TAX_REGIME,
                                      P_REPORT_NAME,
                                      P_REQUEST_ID,
                                      l_trx_id_tbl,
                                      l_tax_rate_tbl,
                                      l_other_fed_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_PROVINCIAL_PERC_AMOUNT');
	END IF;
	    -- Get Provincial Amount
            GET_PROVINCIAL_PERC_AMOUNT(P_PROV_TAX_TYPE_FROM,
                                       P_PROV_TAX_TYPE_TO,
                                       NULL, -- P_PROV_TAX_REGIME
                                       P_REPORT_NAME,
                                       P_REQUEST_ID,
                                       l_trx_id_tbl,
                                       l_tax_rate_id_tbl,
                                       l_prov_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_MUNICIPAL_PERC_AMOUNT');
	END IF;
	    -- Get Municipal Perception Amount
            GET_MUNICIPAL_PERC_AMOUNT(P_MUN_TAX_TYPE_FROM,
                                      P_MUN_TAX_TYPE_TO,
                                      NULL, -- P_MUN_TAX_REGIME
                                      P_REPORT_NAME,
                                      P_REQUEST_ID,
                                      l_trx_id_tbl,
                                      l_tax_rate_id_tbl,
                                      l_munic_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_EXCISE_TAX_AMOUNT');
	END IF;
	    -- Get Excise Tax Amount
            GET_EXCISE_TAX_AMOUNT(P_EXC_TAX_TYPE_FROM,
                                  P_EXC_TAX_TYPE_TO,
                                  NULL, --P_EXC_TAX_REGIME,
                                  P_REPORT_NAME,
                                  P_REQUEST_ID,
                                  l_trx_id_tbl,
                                  l_excise_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before Call to GET_TOTAL_DOCUMENT_AMOUNT');
	END IF;
	     -- Get Total Document Amount
             GET_TOTAL_DOCUMENT_AMOUNT(l_trx_id_tbl,
                                       l_exchange_rate_tbl,
                                       P_REPORT_NAME,
                                       l_total_doc_amt_tbl);

            -- Insert lines into JX EXT Table with Calculated amount --

            FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                   INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                   detail_tax_line_id,
                                                   numeric9,
                                                   numeric10,
                                                   numeric8,
                                                   numeric2,
                                                   numeric3,
                                                   numeric7,
                                                   numeric4,
                                                   numeric5,
                                                   numeric6,
                                                   numeric12,
                                                   attribute4,
                                                   attribute19,
                                                  attribute23,
                                                   attribute20,
                                                   gdf_ap_invoices_att13,
                                                   attribute21,
                                                   attribute22,
                                                   created_by,
                                                   creation_date,
                                                   last_updated_by,
                                                   last_update_date,
                                                   last_update_login,
                                                   request_id)
                                           VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                   l_detail_tax_line_id_tbl(i),
                                                   l_vat_amt_tbl(i),
                                                   l_taxable_amt_tbl(i),
                                                   l_non_taxable_amt_tbl(i),
                                                   l_vat_exempt_amt_tbl(i),
                                                   l_vat_perc_amt_tbl(i),
                                                   l_other_fed_perc_amt_tbl(i),
                                                   l_prov_perc_amt_tbl(i),
                                                   l_munic_perc_amt_tbl(i),
                                                   l_excise_amt_tbl(i),
                                                   l_total_doc_amt_tbl(i),
                                                   l_dgi_trx_code_tbl(i),
                                                   l_cai_number_tbl(i),
                                                   l_cai_due_date_tbl(i),
                                                   l_fiscal_printer_tbl(i),
                                                   l_dgi_doc_type_tbl(i),
                                                   l_taxpayerid_type_tbl(i),
                                                   l_reg_status_code_tbl(i),
                                                   fnd_global.user_id,
                                                   sysdate,
                                                   fnd_global.user_id,
                                                   sysdate,
                                                   fnd_global.login_id,
                                                   p_request_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

                -- Delete Unwanted lines from Detail ITF

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

               UPDATE_DGI_CURR_CODE(p_request_id);


       EXCEPTION
	WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
			'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
       END;

 ELSIF P_REPORT_NAME = 'ZXCLPPLR' THEN

       BEGIN

       -- ------------------------------------------------ --
       -- Get filtered tax lines                           --
       -- in this case, you need to group the lines by trx --
       -- ------------------------------------------------ --
--Changes done for the Bug 5413860 :

                        SELECT min(itf1.detail_tax_line_id),
                                      itf1.trx_line_id,
                                      itf1.taxable_item_source_id,
                               trx_id,
                               tax_rate_id tax_rate,
                               document_sub_type
             BULK COLLECT INTO l_detail_tax_line_id_tbl,
                               l_trx_line_id_tbl,
                               l_trx_line_dist_id_tbl,
                               l_trx_id_tbl,
                               l_tax_rate_tbl,
                               l_document_sub_type_tbl
                          FROM zx_rep_trx_detail_t itf1 ,
                               zx_fc_codes_denorm_b fc
                         WHERE itf1.request_id = P_REQUEST_ID
                           AND itf1.cancel_flag = 'N'
--                           AND itf1.posted_flag = 'Y' --Bug 5413860
                           AND ( itf1.reverse_flag IS NULL OR itf1.reverse_flag <>'Y')
                           AND itf1.document_sub_type  = fc.concat_classif_code
                           AND fc.classification_type_code = 'DOCUMENT_SUBTYPE'
                           AND (instr(upper(itf1.document_sub_type),'_FEE',1) = 0)
                           AND (instr(upper(itf1.document_sub_type),'_INTERNAL',1) = 0)
                      GROUP BY trx_id,
                               itf1.trx_line_id,
                               itf1.taxable_item_source_id,
                               tax_rate_id ,
                               document_sub_type;


                    /*    SELECT min(itf1.detail_tax_line_id),
                               trx_id,
                               null tax_rate,
                               document_sub_type
            BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                               l_trx_id_tbl,
                               l_tax_rate_tbl,
                               l_document_sub_type_tbl
                         FROM  zx_rep_trx_detail_t itf1
                        WHERE  itf1.request_id = P_REQUEST_ID
                          AND  itf1.cancel_flag = 'N'
                          AND  itf1.posted_flag = 'Y'
                          AND  ( itf1.reverse_flag IS NULL OR itf1.reverse_flag <>'Y')
                          AND  itf1.document_sub_type IN ( 'DOCUMENT TYPE.JL_CL_FOREIGN_INVOICE',
                                                           'DOCUMENT TYPE.JL_CL_DOMESTIC_INVOICE',
                                                           'DOCUMENT TYPE.JL_CL_CREDIT_MEMO',
                                                           'DOCUMENT TYPE.JL_CL_DEBIT_MEMO')
                     GROUP BY itf1.trx_id,document_sub_type;
              */
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;
	  --Bug 5058043
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before call to GET_LOOKUP_INFO ');
	  END IF;
           -- Get Lookup Info
           GET_LOOKUP_INFO(l_document_sub_type_tbl,
                           l_jlcl_ap_doc_type_mng_tbl,
                           l_order_by_doc_type_tbl);


	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before call to GET_LOOKUP_INFO ');
	  END IF;
           -- Get Counted sum doc
           GET_COUNTED_SUM_DOC(P_REPORT_NAME,
                               P_REQUEST_ID,
                               l_document_sub_type_tbl,
                               l_cl_num_of_doc_tbl,
                               l_cl_total_exempt_tbl,
                               l_cl_total_effective_tbl,
                               l_cl_total_vat_tax_tbl,
                               l_cl_total_other_tax_tbl);

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before call to GET_VAT_AMOUNT ');
	  END IF;
           -- Get Vat Amount
           GET_VAT_AMOUNT(P_VAT_TAX_TYPE,
                          NULL,
                          P_REPORT_NAME,
                          P_REQUEST_ID,
                          l_trx_id_tbl,
                        l_trx_line_id_tbl,
                          l_detail_tax_line_id_tbl,
                          l_tax_rate_tbl,
                          l_document_sub_type_tbl,
                          l_vat_amt_tbl);

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before call to GET_TAXABLE_AMOUNT ');
	  END IF;
          -- Get Taxable Amount
          GET_TAXABLE_AMOUNT(P_VAT_TAX_TYPE,
                             NULL,
                             P_REPORT_NAME,
                             P_REQUEST_ID,
                          l_detail_tax_line_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_line_dist_id_tbl,
                             l_trx_id_tbl,
                             l_tax_rate_tbl,
                             l_document_sub_type_tbl,
                             l_taxable_amt_tbl);

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before call to GET_VAT_EXEMPT_AMOUNT ');
	  END IF;
	  -- Get Vat Exempt Amount
          GET_VAT_EXEMPT_AMOUNT(P_VAT_TAX_TYPE,
                                NULL, -- P_VAT_ADDIT_TAX
                                NULL, -- P_VAT_PERCEP_TAX
                                P_REPORT_NAME,
                                NULL, -- P_TAX_REGIME
                                P_REQUEST_ID,
                                l_trx_id_tbl,
                                l_detail_tax_line_id_tbl,
                                l_trx_line_id_tbl,
                                l_tax_rate_tbl,
                                l_document_sub_type_tbl,
                                l_vat_exempt_amt_tbl);

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before call to GET_OTHER_TAX_AMOUNT ');
	  END IF;
	  -- Get Other Tax Amount
          GET_OTHER_TAX_AMOUNT(P_REPORT_NAME,
                               p_REQUEST_ID,
                               l_trx_id_tbl,
                               l_tax_rate_tbl,
                               l_document_sub_type_tbl,
                               l_other_tax_amt_tbl);

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before call to GET_TOTAL_DOC_TAXABLE_AMOUNT ');
	  END IF;
	  -- Get Total Doc taxable Amount
          GET_TOTAL_DOC_TAXABLE_AMOUNT(l_trx_id_tbl,
                                       P_REQUEST_ID,
                                       l_total_doc_taxab_amt_tbl);

            -- Insert lines into JX EXT Table with Calculated amount --

            FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                   INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                   detail_tax_line_id,
                                                   numeric9,--l_vat_amt_tbl
                                                   numeric10,--l_taxable_amt_tbl
                                                   numeric2,--l_vat_exempt_amt_tbl
                                                   numeric7,--l_other_tax_amt_tbl
                                                   numeric3,--l_cl_num_of_doc_tbl
                                                   numeric4,--l_cl_total_exempt_tbl
                                                   numeric5,--l_cl_total_effective_tbl
                                                   numeric6,--l_cl_total_vat_tax_tbl
                                                   numeric11,--l_cl_total_other_tax_tbl
                                                   numeric1,--total doc amt
                                                   numeric8,--l_total_doc_taxab_amt_tbl
                                                   attribute14,--l_order_by_doc_type_tbl
                                                   document_sub_type_mng,
                                                   created_by,
                                                   creation_date,
                                                   last_updated_by,
                                                   last_update_date,
                                                   last_update_login)
                                           VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                   l_detail_tax_line_id_tbl(i),
                	                                   l_vat_amt_tbl(i),
                                                   l_taxable_amt_tbl(i),
                                                   l_vat_exempt_amt_tbl(i),
                                                   l_other_tax_amt_tbl(i),
                                                   l_cl_num_of_doc_tbl(i),
                                                   l_cl_total_exempt_tbl(i),
                                                   l_cl_total_effective_tbl(i),
                                                   l_cl_total_vat_tax_tbl(i),
                                                   l_cl_total_other_tax_tbl(i),
                                                  NVL(l_vat_exempt_amt_tbl(i),0)+NVL(l_taxable_amt_tbl(i),0)+NVL(l_vat_amt_tbl(i),0)+NVL(l_other_tax_amt_tbl(i),0),
--                                                   l_total_doc_taxab_amt_tbl(i),
						  nvl(l_cl_total_exempt_tbl(i),0)+nvl(l_cl_total_effective_tbl(i),0)+nvl(l_cl_total_vat_tax_tbl(i),0)+nvl(l_cl_total_other_tax_tbl(i),0),
                                                   l_order_by_doc_type_tbl(i),
                                                   l_jlcl_ap_doc_type_mng_tbl(i),
                                                   fnd_global.user_id,
                                                   sysdate,
                                                   fnd_global.user_id,
                                                   sysdate,
                                                   fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
		-- Delete Unwanted lines from Detail ITF


	      DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);


	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;

       EXCEPTION

            WHEN OTHERS THEN
                    l_err_msg := substrb(SQLERRM,1,120);
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP.END',
                                      'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP:'||p_report_name || '.'||l_err_msg);
            END IF;

       END;

      ELSIF P_REPORT_NAME = 'JLARPPTF' THEN

              DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND (NVL(itf.reverse_flag,'N') = 'Y'
                       OR itf.tax_type_code <> NVL(p_trl_global_variables_rec.per_tax_type_code_high,
                                        p_trl_global_variables_rec.per_tax_type_code_low));
                   /*AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_actg_ext_t actg
                                     WHERE actg.detail_tax_line_id = itf.detail_tax_line_id
                                       AND actg.accounting_date between p_trl_global_variables_rec.gl_date_low
                                             AND p_trl_global_variables_rec.gl_date_high)*/

             DELETE from zx_rep_actg_ext_t actg
                WHERE actg.request_id = p_request_id
                  AND NOT EXISTS ( SELECT 1 FROM zx_rep_trx_detail_t itf
                                    WHERE actg.detail_tax_line_id = itf.detail_tax_line_id);

                      SELECT detail_tax_line_id,
                              trx_line_id,
                              trx_id,
                              tax_rate,
                              tax_rate_id,
                              tax_regime_code
            BULK COLLECT INTO l_detail_tax_line_id_tbl,
                                l_trx_line_id_tbl,
                              l_trx_id_tbl,
                              l_tax_rate_tbl,
                              l_tax_rate_id_tbl,
                              l_tax_regime_code_tbl
                         FROM zx_rep_trx_detail_t
                        WHERE request_id = p_request_id;


       GET_TAX_AUTH_CATEG(
             l_trx_id_tbl,
             l_tax_regime_code_tbl,
             l_tax_rate_id_tbl,
             l_tax_auth_categ_tbl);

        -- Insert lines into JX EXT Table with Calculated amount --

         FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                detail_tax_line_id,
                                                attribute10,
                                                created_by,
                                                creation_date,
                                                last_updated_by,
                                                last_update_date,
                                                last_update_login)
                                        VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                l_detail_tax_line_id_tbl(i),
                                                l_tax_auth_categ_tbl(i),
                                                fnd_global.user_id,
                                                sysdate,
                                                fnd_global.user_id,
                                                sysdate,
                                                fnd_global.login_id);

        IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
                                              'After insertion into zx_rep_trx_jx_ext_t ');
        END IF;

      END IF;  -- End of P_REPORT_NAME = ..

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP.END',
                                      'ZX_JL_EXTRACT_PKG.POPULATE_JL_AP(-)');
  END IF;


 END populate_jl_ap;

/*======================================================================================+
 | PROCEDURE                                                                            |
 |   POPULATER_AR_TAX_AMOUNT                                                            |
 |   Type       : Private                                                               |
 |   Pre-req    : None                                                                  |
 |   Function   :                                                                       |
 |    This procedure extract tax amount for various tax categories                      |
 |    from zx_rep_trx_jx_ext_t table to meet the requirement in                         |
 |    the flat file                                                                     |
 |                                                                                      |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                                         |
 |                                                                                      |
 |   Parameters :                                                                       |
 |   IN         :  P_MUN_TAX_REGIME              IN   VARCHAR2 Opt                      |
 |                                                                                      |
 |   MODIFICATION HISTORY                                                               |
 |     07-Nov-03  Hidetaka Kojima   created                                             |
 |     17-Feb-04  Hidekoji          Modified parameters                                 |
 |                                                                                      |
 +======================================================================================*/


PROCEDURE POPULATE_JL_AR(
          P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
          )
IS

P_TAX_REGIME                    VARCHAR2(30);
P_MUN_TAX_REGIME                VARCHAR2(30);
P_PROV_TAX_REGIME               VARCHAR2(30);
P_EXC_TAX                       VARCHAR2(30);
P_VAT_ADDIT_TAX                 VARCHAR2(30);
P_VAT_NON_TAXAB_TAX             VARCHAR2(30);
P_VAT_NOT_CATEG_TAX             VARCHAR2(30);
P_VAT_PERC_TAX                  VARCHAR2(30);
P_VAT_TAX                       VARCHAR2(30);
P_TRX_LETTER_FROM               VARCHAR2(30);
P_TRX_LETTER_TO                 VARCHAR2(30);
P_REPORT_NAME                   VARCHAR2(30);
P_REQUEST_ID                    NUMBER;

l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_trx_line_id_tbl               ZX_EXTRACT_PKG.TRX_LINE_ID_TBL;
l_trx_line_dist_id_tbl          ZX_EXTRACT_PKG.TAXABLE_ITEM_SOURCE_ID_TBL;
l_trx_id_tbl                    ZX_EXTRACT_PKG.TRX_ID_TBL;
l_batch_source_id_tbl           ZX_EXTRACT_PKG.BATCH_SOURCE_ID_TBL;
l_internal_org_id_tbl           ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL;
l_trx_number_tbl                ZX_EXTRACT_PKG.TRX_NUMBER_TBL;
l_trx_type_id_tbl               ZX_EXTRACT_PKG.TRX_TYPE_ID_TBL;
l_tax_rate_tbl                  ZX_EXTRACT_PKG.TAX_RATE_TBL;
l_tax_rate_id_tbl               ZX_EXTRACT_PKG.TAX_RATE_ID_TBL;
l_document_sub_type_tbl         ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL;
l_exchange_rate_tbl             ZX_EXTRACT_PKG.CURRENCY_CONVERSION_RATE_TBL;

l_not_reg_tax_amt_tbl           NUMERIC1_TBL;
l_vat_exempt_amt_tbl            NUMERIC2_TBL;
l_vat_perc_amt_tbl              NUMERIC3_TBL;
l_prov_perc_amt_tbl             NUMERIC4_TBL;
l_munic_perc_amt_tbl            NUMERIC5_TBL;
l_excise_amt_tbl                NUMERIC6_TBL;
l_other_tax_amt_tbl             NUMERIC7_TBL;
l_non_taxable_amt_tbl           NUMERIC8_TBL;
l_vat_amt_tbl                   NUMERIC9_TBL;
l_taxable_amt_tbl               NUMERIC10_TBL;
l_vat_additional_amt_tbl        NUMERIC7_TBL;
l_total_doc_amt_tbl             NUMERIC12_TBL;
l_rec_count_tbl                 NUMERIC11_TBL;
l_rate_count_tbl                NUMERIC13_TBL;

l_tax_authority_code            ZX_REP_TRX_JX_EXT_T.ATTRIBUTE10%TYPE;
l_dgi_code_tbl                  ATTRIBUTE11_TBL;
l_cust_condition_code_tbl       ATTRIBUTE7_TBL;
l_dgi_tax_regime_code_tbl       ATTRIBUTE25_TBL;
l_vat_reg_stat_code_tbl         ATTRIBUTE8_TBL;
l_prov_juris_code_tbl           ATTRIBUTE1_TBL;
l_mun_juris_code_tbl            ATTRIBUTE3_TBL;
l_fiscal_printer_tbl            GDF_RA_BATCH_SOURCES_ATT7_TBL;
l_cai_number_tbl                ATTRIBUTE19_TBL;
l_cai_due_date_tbl              ATTRIBUTE23_TBL;
l_dgi_trx_code_tbl              ATTRIBUTE4_TBL;
l_count                         NUMBER;
l_tax_regime_code_tbl           ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL;

l_tax_catg_desc zx_rep_trx_jx_ext_t.attribute1%type; --bug 5251425
l_extended_amt_tbl NUMERIC10_TBL; --Bug 5396444
BEGIN

 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR.BEGIN',
                                      'ZX_JL_EXTRACT_PKG.POPULATE_JL_AR(+)');
  END IF;

 -- Get necessary parameters from TRL Global Variables

 P_TAX_REGIME        := P_TRL_GLOBAL_VARIABLES_REC.TAX_REGIME_CODE;
 P_MUN_TAX_REGIME    := P_TRL_GLOBAL_VARIABLES_REC.MUNICIPAL_TAX;
 P_PROV_TAX_REGIME   := P_TRL_GLOBAL_VARIABLES_REC.PROVINCIAL_TAX;
 P_EXC_TAX           := P_TRL_GLOBAL_VARIABLES_REC.EXCISE_TAX;
 P_VAT_ADDIT_TAX     := P_TRL_GLOBAL_VARIABLES_REC.VAT_ADDITIONAL_TAX;
 P_VAT_NON_TAXAB_TAX := P_TRL_GLOBAL_VARIABLES_REC.VAT_NON_TAXABLE_TAX;
 P_VAT_NOT_CATEG_TAX := P_TRL_GLOBAL_VARIABLES_REC.VAT_NOT_TAX;
 P_VAT_PERC_TAX      := P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX;
 P_VAT_TAX           := P_TRL_GLOBAL_VARIABLES_REC.VAT_TAX;
 P_VAT_NON_TAXAB_TAX := P_TRL_GLOBAL_VARIABLES_REC.VAT_NON_TAXABLE_TAX;
 P_TRX_LETTER_FROM   := P_TRL_GLOBAL_VARIABLES_REC.TRX_LETTER_LOW;
 P_TRX_LETTER_TO     := P_TRL_GLOBAL_VARIABLES_REC.TRX_LETTER_HIGH;
 P_REPORT_NAME       := P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME;
 P_REQUEST_ID        := P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_TAX_REGIME        :'||P_TAX_REGIME       );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_MUN_TAX_REGIME    :'||P_MUN_TAX_REGIME   );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_PROV_TAX_REGIME   :'||P_PROV_TAX_REGIME  );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_EXC_TAX           :'||P_EXC_TAX          );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_VAT_ADDIT_TAX     :'||P_VAT_ADDIT_TAX    );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_VAT_NON_TAXAB_TAX :'||P_VAT_NON_TAXAB_TAX);
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_VAT_NOT_CATEG_TAX :'||P_VAT_NOT_CATEG_TAX);
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_VAT_PERC_TAX      :'||P_VAT_PERC_TAX     );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_VAT_TAX           :'||P_VAT_TAX          );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_VAT_NON_TAXAB_TAX :'||P_VAT_NON_TAXAB_TAX);
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_TRX_LETTER_FROM   :'||P_TRX_LETTER_FROM  );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_TRX_LETTER_TO     :'||P_TRX_LETTER_TO    );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_REPORT_NAME       :'||P_REPORT_NAME      );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR','P_REQUEST_ID        :'||P_REQUEST_ID       );
    END IF;




 IF P_REPORT_NAME = 'JLZZTCFF' THEN

    BEGIN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                      'JLZZTCFF : Filter ');
      END IF;

/*
                    SELECT  min(detail_tax_line_id) detail_tax_line_id,
                            trx_id,
                            internal_organization_id,
                            null tax_rate,
                            null document_sub_type
         BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                            l_trx_id_tbl,
                            l_internal_org_id_tbl,
                            l_tax_rate_tbl,
                            l_document_sub_type_tbl
                      FROM  zx_rep_trx_detail_t itf,
                            ra_customer_trx_all   rcta
                     WHERE  itf.request_id = P_REQUEST_ID
                       AND  rcta.customer_trx_id = itf.trx_id
                       AND  itf.extract_source_ledger = 'AR'
                       AND  itf.trx_line_class = 'CREDIT_MEMO'
                       AND  rcta.global_attribute19 is NULL
                       AND  substr(itf.trx_number,1,1) BETWEEN P_TRX_LETTER_FROM AND P_TRX_LETTER_TO
                       AND  nvl(itf.tax_type_code, 'VAT') = 'VAT'
                  GROUP BY  itf.internal_organization_id, itf.trx_id;
*/
                    SELECT  min(detail_tax_line_id) detail_tax_line_id,
                            trx_id,
                            trx_number,
                            internal_organization_id,
                            null tax_rate,
                            null document_sub_type
         BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                            l_trx_id_tbl,
                            l_trx_number_tbl,
                            l_internal_org_id_tbl,
                            l_tax_rate_tbl,
                            l_document_sub_type_tbl
                      FROM  zx_rep_trx_detail_t itf
                     WHERE  itf.request_id = P_REQUEST_ID
                       AND  itf.extract_source_ledger = 'AR'
                       AND  itf.trx_line_class = 'CREDIT_MEMO'
                       AND  NVL(itf.application_doc_status,'$')<>'VD'
                       AND  substr(itf.trx_number,1,1) BETWEEN P_TRX_LETTER_FROM AND P_TRX_LETTER_TO
                       AND  nvl(itf.tax_type_code, 'VAT') = 'VAT'
                  GROUP BY  itf.internal_organization_id, itf.trx_id,
                             itf.trx_number  ;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

           GET_DGI_CODE(l_trx_number_tbl,
                          l_trx_type_id_tbl,
                          l_internal_org_id_tbl,
                          l_dgi_code_tbl);


	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_AMOUNT ');
	END IF;
         -- Get Vat Amount
         GET_VAT_AMOUNT(P_VAT_TAX,
                        P_TAX_REGIME,
                        P_REPORT_NAME,
                        P_REQUEST_ID,
                        l_trx_id_tbl,
                        l_trx_line_id_tbl,
                        l_detail_tax_line_id_tbl,
                        l_tax_rate_tbl,
                        l_document_sub_type_tbl,
                        l_vat_amt_tbl);

         -- Insert lines into JX EXT Table with Calculated amount --

         FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                  detail_tax_line_id,
                                                  numeric9,
                                                  attribute11,
                                                  created_by,
                                                  creation_date,
                                                  last_updated_by,
                                                  last_update_date,
                                                  last_update_login,
                                                  request_id)
                                          VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                  l_detail_tax_line_id_tbl(i),
                                                  l_vat_amt_tbl(i),
                                                  l_dgi_code_tbl(i),
                                                  fnd_global.user_id,
                                                  sysdate,
                                                  fnd_global.user_id,
                                                  sysdate,
                                                  fnd_global.login_id,
                                                  p_request_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
                -- Delete Unwanted lines from Detail ITF

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                      'JLZZTCFF : Call End ');
      END IF;

       EXCEPTION
            WHEN OTHERS THEN
               l_err_msg := substrb(SQLERRM,1,120);
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLZZTCFF : Exception '||p_report_name || '.'||l_err_msg);
            END IF;

       END;


 ELSIF P_REPORT_NAME = 'JLARTPFF' THEN

       BEGIN
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                      'JLARTPFF : Filter ');
            END IF;
 -- DELETE from ZX_REP_TRX_DETAIL_T DET
  --     WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
   --         AND det.TAX <> P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX;

                        SELECT  detail_tax_line_id,
                                itf1.trx_line_id,
                                trx_id,
                                internal_organization_id,
                                tax_rate,
                                document_sub_type,
                                currency_conversion_rate
             BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                                l_trx_line_id_tbl,
                                l_trx_id_tbl,
                                l_internal_org_id_tbl,
                                l_tax_rate_tbl,
                                l_document_sub_type_tbl,
                                l_exchange_rate_tbl
                          FROM  zx_rep_trx_detail_t itf1
                              --  ra_customer_trx rct
                         WHERE  itf1.request_id = P_REQUEST_ID
                          -- AND  rct.customer_trx_id = itf1.trx_id
                           AND  itf1.trx_line_class in ('INVOICE','DEBIT_MEMO','CREDIT_MEMO')
                           AND  NVL(itf1.application_doc_status,'$') <>'VD'
                           AND itf1.tax  =P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX
                          ORDER BY itf1.trx_id, itf1.trx_line_id;
                           --AND  rct.global_attribute19 is null
                           --AND  itf1.doc_event_status = 'FROZEN_FOR_TAX';

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TAXABLE_AMOUNT ');
	END IF;
             -- Get Taxable Amount
             GET_TAXABLE_AMOUNT(P_VAT_TAX,
                                P_TAX_REGIME,
                                P_REPORT_NAME,
                                P_REQUEST_ID,
                          l_detail_tax_line_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_line_dist_id_tbl,
                                l_trx_id_tbl,
                                l_tax_rate_tbl,
                                l_document_sub_type_tbl,
                                l_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_PERCEPTION_AMOUNT ');
	END IF;
             -- Get Vat Perception Amount
             GET_VAT_PERCEPTION_AMOUNT(null, -- P_VAT_PERC_TAX_TYPE_FROM,
                                       null, --P_VAT_PERC_TAX_TYPE_TO,
                                       P_VAT_PERC_TAX,
                                       P_TAX_REGIME,
                                       P_REPORT_NAME,
                                       P_REQUEST_ID,
                                       l_trx_id_tbl,
                                       l_trx_line_id_tbl,
                                       l_tax_rate_tbl,
                                       l_vat_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TOTAL_DOCUMENT_AMOUNT ');
	END IF;
             -- Get Total Document Amount
             GET_TOTAL_DOCUMENT_AMOUNT(l_trx_id_tbl,
                                       l_exchange_rate_tbl,
                                       P_REPORT_NAME,
                                       l_total_doc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TAX_AUTHORITY_CODE ');
	END IF;
	     -- Get Tax Authority Code
             l_tax_authority_code := GET_TAX_AUTHORITY_CODE(P_VAT_PERC_TAX,
                                                            l_internal_org_id_tbl(1));

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_DGI_TAX_REGIME_CODE ');
	END IF;

             GET_DGI_TAX_REGIME_CODE (P_VAT_PERC_TAX,
                                      l_trx_id_tbl ,
                                      l_trx_line_id_tbl ,
                                      l_internal_org_id_tbl,
                                      P_REQUEST_ID,
                                      l_dgi_tax_regime_code_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_CUSTOMER_CONDITION_CODE ');
	END IF;
	     -- Get Customer Condition Code
             GET_CUSTOMER_CONDITION_CODE(P_VAT_PERC_TAX,
                                         l_trx_id_tbl,
                                         l_internal_org_id_tbl,
                                         P_REQUEST_ID,
                                         l_cust_condition_code_tbl);

             -- Insert lines into JX EXT Table with Calculated amount --

             FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                    INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                    detail_tax_line_id,
                                                    numeric9,
                                                    numeric3,
                                                    numeric12,
                                                    attribute10,
                                                    attribute7,
                                                    attribute25,
                                                    request_id,
                                                    created_by,
                                                    creation_date,
                                                    last_updated_by,
                                                    last_update_date,
                                                    last_update_login)
                                            VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                    l_detail_tax_line_id_tbl(i),
                                                    l_taxable_amt_tbl(i),
                                                    l_vat_perc_amt_tbl(i),
                                                    l_total_doc_amt_tbl(i),
                                                    l_tax_authority_code,
                                                    l_cust_condition_code_tbl(i),
                                                    l_dgi_tax_regime_code_tbl(i),
                                                    p_request_id,
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
		-- Delete Unwanted lines from Detail ITF

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                      'JLARTPFF : Call End ');
      END IF;


       EXCEPTION

            WHEN OTHERS THEN
               l_err_msg := substrb(SQLERRM,1,120);
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTPFF : Exception '||p_report_name || '.'||l_err_msg);
            END IF;
       END;

 ELSIF P_REPORT_NAME = 'ZXZZTVSR' THEN

       BEGIN
          IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                      'ZXZZTVSR : Filter ');
          END IF;

                        SELECT detail_tax_line_id,
                                trx_line_id,
                               trx_id,
                               internal_organization_id,
                               trx_number,
                               nvl(currency_conversion_rate,1),
                               trx_type_id,
                               tax_rate,
                               tax_rate_id,
                               document_sub_type
            BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                               l_trx_line_id_tbl,
                               l_trx_id_tbl,
                               l_internal_org_id_tbl,
                               l_trx_number_tbl,
                               l_exchange_rate_tbl,
                               l_trx_type_id_tbl,
                               l_tax_rate_tbl,
                               l_tax_rate_id_tbl,
                               l_document_sub_type_tbl
                         FROM
                              (
                                SELECT detail_tax_line_id,
                                       trx_line_id,
                                       trx_id,
                                       internal_organization_id,
                                       trx_number,
                                       currency_conversion_rate,
                                       trx_type_id,
                                       tax_rate,
                                       tax_rate_id,
                                       document_sub_type
                                  FROM
                                  (SELECT min(itf1.detail_tax_line_id) detail_tax_line_id,
                                        itf1.trx_line_id,
                                        itf1.trx_id   trx_id,
                                        itf1.internal_organization_id internal_organization_id,
                                        itf1.trx_number trx_number,
                                        itf1.currency_conversion_rate,
                                        itf1.trx_type_id,
                                        itf1.tax_rate tax_rate,
                                        itf1.tax_rate_id,
                                        null document_sub_type
                                   FROM zx_rep_trx_detail_t itf1
                                  WHERE itf1.request_id = P_REQUEST_ID
                                    AND itf1.tax = p_vat_tax
                                    AND nvl(itf1.tax_type_code,'VAT') = 'VAT'
                                    AND itf1.tax_rate <> 0
                               GROUP BY itf1.internal_organization_id,
                                        itf1.trx_line_id,
                                        itf1.trx_id,
                                        itf1.trx_number,
                                        itf1.currency_conversion_rate,
                                        itf1.trx_type_id,
                                        itf1.tax_rate,
                                        itf1.tax_rate_id
                                  UNION
                                 SELECT itf2.detail_tax_line_id,
                                        itf2.trx_line_id,
                                        itf2.trx_id   trx_id,
                                        itf2.internal_organization_id internal_organization_id,
                                        itf2.trx_number trx_number,
                                        itf2.currency_conversion_rate,
                                        itf2.trx_type_id,
                                        0 tax_rate,
                                        itf2.tax_rate_id,
                                        null document_sub_type
                                   FROM zx_rep_trx_detail_t itf2
                                  WHERE itf2.request_id = P_REQUEST_ID
                                    AND NVL(itf2.tax_type_code, 'VAT') = 'VAT'
                                    AND nvl(itf2.TAX_RATE,0) = 0
                                    AND itf2.tax = p_vat_tax
                                    AND not exists (SELECT 1
                                                      FROM zx_rep_trx_detail_t itf3
                                                     WHERE itf3.request_id = P_REQUEST_ID
                                                       AND itf2.trx_id = itf3.trx_id
                                                       AND NVL(itf3.tax_type_code, 'VAT') = 'VAT'
                                                       AND nvl(itf3.tax_rate,0) <>  0
                                                       AND itf3.tax = p_vat_tax)
                                    /*AND rownum = 1 for GSI Bug# 7170003*/

                                  UNION
		--Query 3 : To pick once row per trx which have non-VAT taxes
                                 SELECT itf4.detail_tax_line_id,
                                        itf4.trx_line_id,
                                        itf4.trx_id   trx_id,
                                        itf4.internal_organization_id internal_organization_id,
                                        itf4.trx_number trx_number,
                                        itf4.currency_conversion_rate,
                                        itf4.trx_type_id,
                                        itf4.tax_rate,
                                        itf4.tax_rate_id,
                                        null document_sub_type
                                   FROM zx_rep_trx_detail_t itf4
                                  WHERE itf4.request_id = P_REQUEST_ID
                                  AND not exists ( SELECT 1
                                                     FROM zx_rep_trx_detail_t itf5
                                                    WHERE itf5.request_id = P_REQUEST_ID
                                                      AND itf5.trx_id = itf4.trx_id
                                                      AND itf5.tax = p_vat_tax )
                                  AND itf4.ROWID = ( SELECT Min(itf6.ROWID)
                                                      FROM zx_rep_trx_detail_t itf6
                                                      WHERE itf4.trx_id = itf6.trx_id
                                                      AND itf6.request_id =  P_REQUEST_ID )
                               )order by trx_id , trx_line_id
                              );

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_AMOUNT ');
	END IF;
             -- Get Vat Amount
             GET_VAT_AMOUNT(P_VAT_TAX,
                            P_TAX_REGIME,
                            P_REPORT_NAME,
                            P_REQUEST_ID,
                            l_trx_id_tbl,
                        l_trx_line_id_tbl,
                            l_detail_tax_line_id_tbl,
                            l_tax_rate_tbl,
                            l_document_sub_type_tbl,
                            l_vat_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TAXABLE_AMOUNT ');
	END IF;
	     -- Get Taxable Amount
             GET_TAXABLE_AMOUNT(P_VAT_TAX,
                                P_TAX_REGIME,
                                P_REPORT_NAME,
                                P_REQUEST_ID,
                          l_detail_tax_line_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_line_dist_id_tbl,
                                l_trx_id_tbl,
                                l_tax_rate_tbl,
                                l_document_sub_type_tbl,
                                l_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_NON_TAXABLE_AMOUNT ');
	END IF;
             -- Get Non Taxable Amount
             GET_NON_TAXABLE_AMOUNT(P_VAT_NON_TAXAB_TAX,
                                    P_VAT_TAX,
                                    P_VAT_ADDIT_TAX,
                                    P_VAT_PERC_TAX,
                                    P_REPORT_NAME,
                                    P_REQUEST_ID,
                                    l_trx_id_tbl,
                              l_detail_tax_line_id_tbl,
                              l_trx_line_id_tbl,
                                    l_tax_rate_tbl,
                                    l_non_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_ADDITIONAL_AMOUNT ');
	END IF;
             -- Get Vat Additional Amount
             GET_VAT_ADDITIONAL_AMOUNT(P_VAT_ADDIT_TAX,
                                       P_REPORT_NAME,
                                       P_REQUEST_ID,
                                       l_trx_id_tbl,
                                       l_tax_rate_id_tbl,
                                       l_vat_additional_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_EXEMPT_AMOUNT ');
	END IF;
             -- Get Vat Exempt Amount
             GET_VAT_EXEMPT_AMOUNT(P_VAT_TAX,
                                   P_VAT_ADDIT_TAX,
                                   P_VAT_PERC_TAX,
                                   P_REPORT_NAME,
                                   P_TAX_REGIME,
                                   P_REQUEST_ID,
                                   l_trx_id_tbl,
                                   l_detail_tax_line_id_tbl,
                                   l_trx_line_id_tbl,
                                   l_tax_rate_tbl,
                                   l_document_sub_type_tbl,
                                   l_vat_exempt_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_PERCEPTION_AMOUNT ');
	END IF;
             -- Get Vat Perception Amount
             GET_VAT_PERCEPTION_AMOUNT(null, -- P_VAT_PERC_TAX_TYPE_FROM,
                                       null, -- P_VAT_PERC_TAX_TYPE_TO,
                                       P_VAT_PERC_TAX,
                                       P_TAX_REGIME,
                                       P_REPORT_NAME,
                                       P_REQUEST_ID,
                                       l_trx_id_tbl,
                                 l_trx_line_id_tbl,
                                       l_tax_rate_tbl,
                                       l_vat_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TOTAL_DOCUMENT_AMOUNT ');
	END IF;
             -- Get Total Document Amount
             GET_TOTAL_DOCUMENT_AMOUNT(l_trx_id_tbl,
                                       l_exchange_rate_tbl,
                                       P_REPORT_NAME,
                                       l_total_doc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_DGI_CODE ');
	END IF;
             -- Get DGI Code
             GET_DGI_CODE(l_trx_number_tbl,
                          l_trx_type_id_tbl,
                          l_internal_org_id_tbl,
                          l_dgi_code_tbl);

             -- Insert lines into JX EXT Table with Calculated amount --

             FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                    INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                    detail_tax_line_id,
                                                    numeric9,
                                                    numeric10,
                                                    numeric8,
                                                    numeric7,
                                                    numeric2,
                                                    numeric3,
                                                    numeric12,
                                                    attribute11,
                                                    created_by,
                                                    creation_date,
                                                    last_updated_by,
                                                    last_update_date,
                                                    last_update_login)
                                            VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                    l_detail_tax_line_id_tbl(i),
                                                    l_vat_amt_tbl(i),
                                                    l_taxable_amt_tbl(i),
                                                    l_non_taxable_amt_tbl(i),
                                                    l_vat_additional_amt_tbl(i),
                                                    l_vat_exempt_amt_tbl(i),
                                                    l_vat_perc_amt_tbl(i),
                                                    l_total_doc_amt_tbl(i),
                                                    l_dgi_code_tbl(i),
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
		-- Delete Unwanted lines from Detail ITF

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                      'ZXZZTVSR : Call End ');
      END IF;

       EXCEPTION

            WHEN OTHERS THEN
               l_err_msg := substrb(SQLERRM,1,120);
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'ZXZZTVSR : Exception '||p_report_name || '.'||l_err_msg);
            END IF;
       END;

 ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN

       BEGIN

          IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTSFF : Filter ');
          END IF;

          IF P_REPORT_NAME = 'JLARTSFF' THEN

                        SELECT  detail_tax_line_id,
                                trx_id,
                                trx_line_id,
                                trx_batch_source_id,
                                internal_organization_id,
                                trx_number,
                                currency_conversion_rate,
                                trx_type_id,
                                tax_rate,
                                tax_rate_id,
                                document_sub_type ,
                                tax_regime_code
             BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                                l_trx_id_tbl,
                                l_trx_line_id_tbl,
                                l_batch_source_id_tbl,
                                l_internal_org_id_tbl,
                                l_trx_number_tbl,
                                l_exchange_rate_tbl,
                                l_trx_type_id_tbl,
                                l_tax_rate_tbl,
                                l_tax_rate_id_tbl,
                                l_document_sub_type_tbl,
                                l_tax_regime_code_tbl
                          FROM (
                                SELECT  detail_tax_line_id,
                                        trx_id,
                                        trx_line_id,
                                        trx_batch_source_id,
                                        internal_organization_id,
                                        trx_number,
                                        currency_conversion_rate,
                                        trx_type_id,
                                        tax_rate,
                                        tax_rate_id,
                                        document_sub_type ,
                                        tax_regime_code
                                FROM
                                (SELECT min(dtl.detail_tax_line_id) detail_tax_line_id,
                                        dtl.trx_id,
                                        dtl.trx_line_id,
                                        dtl.trx_batch_source_id,
                                        dtl.internal_organization_id,
                                        dtl.trx_number,
                                        dtl.currency_conversion_rate,
                                        dtl.trx_type_id,
                                        dtl.tax_rate,
                                        dtl.tax_rate_id,
                                        null  document_sub_type,
                                        dtl.tax_regime_code
                                   FROM zx_rep_trx_detail_t dtl,
                                        ar_vat_tax_all vat
                                  WHERE dtl.request_id = P_REQUEST_ID
                                    AND nvl(vat.tax_type,'VAT') = 'VAT'
                                    AND dtl.tax_rate_id = vat.vat_tax_id
                          --       AND dtl.doc_event_status = 'FROZEN_FOR_TAX'
                                    AND dtl.tax_regime_code = p_tax_regime
                                    AND dtl.tax = P_VAT_TAX
                               GROUP BY dtl.internal_organization_id,
                                        dtl.trx_id,
                                        dtl.trx_line_id,
                                        dtl.trx_batch_source_id,
                                        dtl.trx_number,
                                        dtl.currency_conversion_rate,
                                        dtl.trx_type_id, dtl.tax_rate,
                                        dtl.tax_rate_id,
                                        dtl.tax_regime_code
                               /*UNION
                                 SELECT min(itf2.detail_tax_line_id) detail_tax_line_id,
                                        trx_id,
                                        trx_line_id,
                                        internal_organization_id,
                                        trx_number,
                                        currency_conversion_rate,
                                        trx_type_id,
                                        null tax_rate,
                                        null document_sub_type
                                   FROM zx_rep_trx_detail_t itf2
                                  WHERE itf2.request_id = P_REQUEST_ID
                                    AND nvl(itf2.tax_type_code,'VAT') = 'VAT'
                               GROUP BY itf2.internal_organization_id,
                                        itf2.trx_id, trx_line_id, trx_number, currency_conversion_rate,trx_type_id */
                               UNION
                                 SELECT min(itf3.detail_tax_line_id) detail_tax_line_id,
                                        itf3.trx_id,
                                        itf3.trx_line_id,
                                        itf3.trx_batch_source_id,
                                        itf3.internal_organization_id,
                                        itf3.trx_number,
                                        itf3.currency_conversion_rate,
                                        itf3.trx_type_id,
                                        null tax_rate,
                                        itf3.tax_rate_id,
                                        null document_sub_type,
                                        itf3.tax_regime_code
                                   FROM zx_rep_trx_detail_t itf3
                                  WHERE itf3.request_id = P_REQUEST_ID
                                    AND itf3.tax = P_VAT_NON_TAXAB_TAX
                                    AND itf3.tax_rate = 0
                               GROUP BY itf3.internal_organization_id,
                                        itf3.trx_id, itf3.trx_line_id,itf3.trx_batch_source_id,
                                        itf3.trx_number,
                                        itf3.currency_conversion_rate,
                                        itf3.trx_type_id,
                                        itf3.tax_rate_id,
                                        itf3.tax_regime_code
                                        )
                               order by trx_id, trx_line_id
                               );

 IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                      'Row Count : '||to_char(l_detail_tax_line_id_tbl.count));
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                      'p_tax_regime - P_VAT_TAX  : '||p_tax_regime||'-'||P_VAT_TAX);
  END IF;


       ELSIF P_REPORT_NAME = 'JLARTDFF' THEN

          IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTDFF : Filter ');
          END IF;

                         SELECT min(detail_tax_line_id),
                                trx_line_id,
                                trx_id,
                                internal_organization_id,
                                trx_number,
                                trx_type_id,
                                to_number(null) tax_rate,
                                to_number(null) tax_rate_id,
                                to_char(null) document_sub_type
             BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                                l_trx_line_id_tbl,
                                l_trx_id_tbl,
                                l_internal_org_id_tbl,
                                l_trx_number_tbl,
                                l_trx_type_id_tbl,
                                l_tax_rate_tbl,
                                l_tax_rate_id_tbl,
                                l_document_sub_type_tbl
                           FROM zx_rep_trx_detail_t
                          WHERE request_id = P_REQUEST_ID
                            AND nvl(tax_type_code,'VAT') = 'VAT'
                            AND doc_event_status = 'FROZEN_FOR_TAX'
                            AND tax_regime_code = p_tax_regime
                            AND tax in (P_VAT_TAX,P_VAT_NON_TAXAB_TAX)
                       GROUP BY internal_organization_id,
                                trx_line_id,
                                trx_id,
                                trx_number,
                                trx_type_id
                       ORDER BY trx_id, trx_line_id;

       END IF;

          l_count := l_detail_tax_line_id_tbl.count;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;


FOR i in 1..l_count
LOOP
--Initialize Variables --
l_vat_amt_tbl(i) := NULL;
l_taxable_amt_tbl(i) := NULL;
l_non_taxable_amt_tbl(i) := NULL;
l_vat_exempt_amt_tbl(i) := NULL;
l_vat_perc_amt_tbl(i) := NULL;
l_not_reg_tax_amt_tbl(i) := NULL;
l_prov_perc_amt_tbl(i) := NULL;
l_munic_perc_amt_tbl(i) := NULL;
l_excise_amt_tbl(i) := NULL;
l_total_doc_amt_tbl(i) := NULL;
l_rec_count_tbl(i) := NULL;
l_rate_count_tbl(i) := NULL;
l_dgi_code_tbl(i) := NULL;
l_dgi_trx_code_tbl(i) := NULL;
l_vat_reg_stat_code_tbl(i) := NULL;
l_fiscal_printer_tbl(i) := NULL;
l_cai_number_tbl(i) := NULL;
l_cai_due_date_tbl(i) := NULL;
END LOOP;
-- End of Initialize --

  	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_AMOUNT ');
	END IF;
  --        initialize_variables(l_count);
            -- Get Vat Amount
             GET_VAT_AMOUNT(P_VAT_TAX,
                            P_TAX_REGIME,
                            P_REPORT_NAME,
                            P_REQUEST_ID,
                            l_trx_id_tbl,
                        l_trx_line_id_tbl,
                            l_detail_tax_line_id_tbl,
                            l_tax_rate_tbl,
                            l_document_sub_type_tbl,
                            l_vat_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TAXABLE_AMOUNT ');
	END IF;

             -- Get Taxable Amount
             GET_TAXABLE_AMOUNT(P_VAT_TAX,
                                P_TAX_REGIME,
                                P_REPORT_NAME,
                                P_REQUEST_ID,
                          l_detail_tax_line_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_line_dist_id_tbl,
                                l_trx_id_tbl,
                                l_tax_rate_tbl,
                                l_document_sub_type_tbl,
                                l_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_NON_TAXABLE_AMOUNT ');
	END IF;


	     -- Get Non Taxable Amount
             GET_NON_TAXABLE_AMOUNT(P_VAT_NON_TAXAB_TAX,
                                    P_VAT_TAX,
                                    P_VAT_ADDIT_TAX,
                                    P_VAT_PERC_TAX,
                                    P_REPORT_NAME,
                                    P_REQUEST_ID,
                                    l_trx_id_tbl,
                              l_detail_tax_line_id_tbl,
                              l_trx_line_id_tbl,
                                    l_tax_rate_tbl,
                                    l_non_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_EXEMPT_AMOUNT ');
	END IF;
             -- Get Vat Exempt Amount
             GET_VAT_EXEMPT_AMOUNT(P_VAT_TAX,
                                   P_VAT_ADDIT_TAX,
                                   P_VAT_PERC_TAX,
                                   P_REPORT_NAME,
                                   P_TAX_REGIME,
                                   P_REQUEST_ID,
                                   l_trx_id_tbl,
                                   l_detail_tax_line_id_tbl,
                                   l_trx_line_id_tbl,
                                   l_tax_rate_tbl,
                                   l_document_sub_type_tbl,
                                   l_vat_exempt_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_PERCEPTION_AMOUNT ');
	END IF;
             -- Get Vat Perception Amount
             GET_VAT_PERCEPTION_AMOUNT(null, -- P_VAT_PERC_TAX_TYPE_FROM,
                                       null, --P_VAT_PERC_TAX_TYPE_TO,
                                       P_VAT_PERC_TAX,
                                       P_TAX_REGIME,
                                       P_REPORT_NAME,
                                       P_REQUEST_ID,
                                       l_trx_id_tbl,
                                 l_trx_line_id_tbl,
                                       l_tax_rate_tbl,
                                       l_vat_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_NOT_REGISTERED_TAX_AMOUNT ');
	END IF;
	     -- Get Not Registered Amount
             GET_NOT_REGISTERED_TAX_AMOUNT(P_REPORT_NAME,
                                           P_VAT_ADDIT_TAX,
                                           P_VAT_NOT_CATEG_TAX,
                                           P_TAX_REGIME,
                                           P_REQUEST_ID,
                                           l_trx_id_tbl,
                                           l_tax_rate_tbl,
                                           l_document_sub_type_tbl,
                                           l_not_reg_tax_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_PROVINCIAL_PERC_AMOUNT ');
	END IF;
             -- Get Provincial Perception Amount
             GET_PROVINCIAL_PERC_AMOUNT(null, -- P_PROV_TAX_TYPE_FROM,
                                        null, -- P_PROV_TAX_TYPE_TO,
                                        P_PROV_TAX_REGIME,
                                        P_REPORT_NAME,
                                        P_REQUEST_ID,
                                        l_trx_id_tbl,
                                        l_tax_rate_id_tbl,
                                        l_prov_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_MUNICIPAL_PERC_AMOUNT ');
	END IF;
             -- Get Municipal Perception Amount
             GET_MUNICIPAL_PERC_AMOUNT(null, -- P_MUN_TAX_TYPE_FROM,
                                       null, -- P_MUN_TAX_TYPE_TO,
                                       P_MUN_TAX_REGIME,
                                       P_REPORT_NAME,
                                       P_REQUEST_ID,
                                       l_trx_id_tbl,
                                       l_tax_rate_id_tbl,
                                       l_munic_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_EXCISE_TAX_AMOUNT ');
	END IF;
             -- Get Excise Tax Amount
             GET_EXCISE_TAX_AMOUNT(null, --P_EXC_TAX_TYPE_FROM,
                                   null, --P_EXC_TAX_TYPE_TO,
                                   P_EXC_TAX,
                                   P_REPORT_NAME,
                                   P_REQUEST_ID,
                                   l_trx_id_tbl,
                                   l_excise_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TOTAL_DOCUMENT_AMOUNT ');
	END IF;
             -- Get Total Document Amount
             GET_TOTAL_DOCUMENT_AMOUNT(l_trx_id_tbl,
                                       l_exchange_rate_tbl,
                                       P_REPORT_NAME,
                                       l_total_doc_amt_tbl);

     	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_DGI_CODE ');
	END IF;
             -- Get DGI Code
             GET_DGI_CODE(l_trx_number_tbl,
                          l_trx_type_id_tbl,
                          l_internal_org_id_tbl,
                          l_dgi_code_tbl);

     	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_REG_STAT_CODE ');
	END IF;
             -- Get Vat Reg Stat Code
             GET_VAT_REG_STAT_CODE(P_VAT_TAX,
                                   l_trx_id_tbl,
                                   l_internal_org_id_tbl,
                                   P_REQUEST_ID,
                                   l_vat_reg_stat_code_tbl);


     	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to DGI_TRX_CODE ');
	END IF;
             -- Get DGI Trx code
            DGI_TRX_CODE ( l_trx_id_tbl,
                        l_tax_regime_code_tbl,
                        l_tax_rate_id_tbl,
                        l_dgi_trx_code_tbl);


             -- Fiscal Printer --
       IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER_AR',
                                              'Before call to GET_FISCAL_PRINTER_AR ');
        END IF;

             -- Fiscal Printer --
             GET_FISCAL_PRINTER_AR(l_trx_id_tbl,
                                   l_batch_source_id_tbl,
                                   l_fiscal_printer_tbl);

       IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
                                              'Before call to GET_CAI_NUM ');
        END IF;
             GET_CAI_NUM_AR
                  ( l_trx_id_tbl,
                    p_report_name,
                    l_cai_number_tbl,
                    l_cai_due_date_tbl);

     	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_REC_COUNT ');
	END IF;
             -- Get counted record
             GET_REC_COUNT(P_VAT_TAX,
                           P_TAX_REGIME,
                           l_trx_id_tbl,
                           P_REQUEST_ID,
                           l_rec_count_tbl);

     	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_NONVAT_RATE_COUNT ');
	END IF;
             -- Get Counted VAT or NOVAT Tax Rate
             GET_VAT_NONVAT_RATE_COUNT  (P_VAT_TAX,
                                         P_VAT_NON_TAXAB_TAX,
                                         P_TAX_REGIME,
                                         l_trx_id_tbl,
                                         P_REQUEST_ID,
                                         l_rate_count_tbl);

             -- Insert lines into JX EXT Table with Calculated amount --

             FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                    INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                    detail_tax_line_id,
                                                    numeric9,
                                                    numeric10,
                                                    numeric8,
                                                   -- numeric7,
                                                    numeric2,
                                                    numeric3,
                                                    numeric1,
                                                    numeric4,
                                                    numeric5,
                                                    numeric6,
                                                    numeric12,
                                                    numeric11,
                                                    numeric13,
                                                    attribute11,
                                                    attribute4,
                                                    attribute8,
                                                    gdf_ra_batch_sources_att7,
                                                    attribute19,
                                                    attribute23,
                                                    created_by,
                                                    creation_date,
                                                    last_updated_by,
                                                    last_update_date,
                                                    last_update_login,
                                                    request_id)
                                            VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                    l_detail_tax_line_id_tbl(i),
                                                    l_vat_amt_tbl(i),
                                                    l_taxable_amt_tbl(i),
                                                    l_non_taxable_amt_tbl(i),
                                                  --  l_vat_additional_amt_tbl(i),
                                                    l_vat_exempt_amt_tbl(i),
                                                    l_vat_perc_amt_tbl(i),
                                                    l_not_reg_tax_amt_tbl(i),
                                                    l_prov_perc_amt_tbl(i),
                                                    l_munic_perc_amt_tbl(i),
                                                    l_excise_amt_tbl(i),
                                                    l_total_doc_amt_tbl(i),
                                                    l_rec_count_tbl(i),
                                                    l_rate_count_tbl(i),
                                                    l_dgi_code_tbl(i),
                                                    l_dgi_trx_code_tbl(i),
                                                    l_vat_reg_stat_code_tbl(i),
                                                    l_fiscal_printer_tbl(i),
                                                    l_cai_number_tbl(i),
                                                    l_cai_due_date_tbl(i),
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.login_id,
                                                    p_request_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
		-- Delete Unwanted lines from Detail ITF

/*                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);
*/

              UPDATE_DGI_CURR_CODE(p_request_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;

          IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTDFF and  JLARTSFF : Call End ');
          END IF;


       EXCEPTION
            WHEN OTHERS THEN
              l_err_msg := substrb(SQLERRM,1,120);
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTDFF and JLARTSFF : Exception '||p_report_name || '.'||l_err_msg);
            END IF;
       END;

 ELSIF P_REPORT_NAME = 'JLARTOFF' THEN

       BEGIN

          IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTOFF : Filter ');
          END IF;

                         SELECT detail_tax_line_id,
                                trx_id,
                                internal_organization_id,
                                trx_number,
                                trx_type_id,
                                tax_rate,
                                tax_rate_id,
                                tax_regime_code,
                                document_sub_type
             BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                                l_trx_id_tbl,
                                l_internal_org_id_tbl,
                                l_trx_number_tbl,
                                l_trx_type_id_tbl,
                                l_tax_rate_tbl,
                                l_tax_rate_id_tbl,
                                l_tax_regime_code_tbl,
                                l_document_sub_type_tbl
                          FROM  zx_rep_trx_detail_t itf1,
                                jl_zz_ar_tx_categ categ
                         WHERE  itf1.request_id = P_REQUEST_ID
                        --   AND  itf1.tax_regime_code
                             AND itf1.tax = categ.tax_category
                             AND categ.tax_regime in (P_PROV_TAX_REGIME,
                                                         P_MUN_TAX_REGIME);


         IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTOFF : Bulk collect '||to_char(l_trx_id_tbl.count));
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTOFF : Bulk collect '||to_char(l_trx_id_tbl.count));
          END IF;

             -- Get Provincial Perception Amount
             GET_PROVINCIAL_PERC_AMOUNT(null, -- P_PROV_TAX_TYPE_FROM
                                        null, -- P_PROV_TAX_TYPE_TO
                                        P_PROV_TAX_REGIME,
                                        P_REPORT_NAME,
                                        P_REQUEST_ID,
                                        l_trx_id_tbl,
                                        l_tax_rate_id_tbl,
                                        l_prov_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_MUNICIPAL_PERC_AMOUNT ');
	END IF;
             -- Get Municipal Perception Amount
             GET_MUNICIPAL_PERC_AMOUNT(null, -- P_MUN_TAX_TYPE_FROM
                                       null, --  P_MUN_TAX_TYPE_TO
                                       P_MUN_TAX_REGIME,
                                       P_REPORT_NAME,
                                       p_REQUEST_ID,
                                       l_trx_id_tbl,
                                       l_tax_rate_id_tbl,
                                       l_munic_perc_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_DGI_CODE ');
	END IF;
             -- Get DGI Code
             GET_DGI_CODE(l_trx_number_tbl,
                          l_trx_type_id_tbl,
                          l_internal_org_id_tbl,
                          l_dgi_code_tbl);

         PROV_JURISDICTION_CODE(
                     l_trx_id_tbl,
                     l_tax_regime_code_tbl,
                     l_tax_rate_id_tbl,
                     l_prov_juris_code_tbl);


         MUN_JURISDICTION_CODE(
                     l_trx_id_tbl,
                     l_tax_regime_code_tbl,
                     l_tax_rate_id_tbl,
                     l_mun_juris_code_tbl);

      -- Important --
      -- Need to add two more APIs to populate turnover jurisdiction code and municipal jurisdiction code.
      -- The gdf attributes 5 and 6 are migrated from ar_vat_tax table to reporting types and codes.
      -- The related reporting types are :AR_TURN_OVER_JUR_CODE and AR_MUNICIPAL_JUR
      -- This report shows these details and the attributes are already identified and used in the
      -- report. These attributes need to populate.
      --
             -- Insert lines into JX EXT Table with Calculated amount --

             FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                    INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                    detail_tax_line_id,
                                                    numeric4,
                                                    numeric5,
                                                    attribute11,
                                                    attribute1,
                                                    attribute3,
                                                    created_by,
                                                    creation_date,
                                                    last_updated_by,
                                                    last_update_date,
                                                    last_update_login,
                                                    request_id)
                                            VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                    l_detail_tax_line_id_tbl(i),
                                                    l_prov_perc_amt_tbl(i),
                                                    l_munic_perc_amt_tbl(i),
                                                    l_dgi_code_tbl(i),
                                                    l_prov_juris_code_tbl(i),
                                                    l_mun_juris_code_tbl(i),
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.login_id,
                                                    p_request_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
		-- Delete Unwanted lines from Detail ITF

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;

          IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTOFF : Call End ');
          END IF;


       EXCEPTION

            WHEN OTHERS THEN
              l_err_msg := substrb(SQLERRM,1,120);
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTOFF : Exception '||p_report_name || '.'||l_err_msg);
            END IF;
       END;

 ELSIF P_REPORT_NAME = 'ZXCLRSLL' THEN

       BEGIN
          IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'ZXCLRSLL : Filter ');
          END IF;

                         SELECT min(itf.detail_tax_line_id),
                                itf.trx_line_id,
                                itf.trx_id,
                                itf.internal_organization_id,
                                itf.trx_number,
                                itf.tax_rate_id,
                                itf.DOC_SEQ_NAME document_sub_type
             BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                                l_trx_line_id_tbl,
                                l_trx_id_tbl,
                                l_internal_org_id_tbl,
                                l_trx_number_tbl,
                                l_tax_rate_tbl,
                                l_document_sub_type_tbl
                          FROM  zx_rep_trx_detail_t itf,
                                zx_rates_b rates,
--                                zx_report_codes_assoc repc,
--                                zx_reporting_types_b  reptypes,--Bug 5438742
                                ra_customer_trx_all   ratrx,
                                ra_cust_trx_types_all types
                         WHERE  itf.request_id = P_REQUEST_ID
                           AND  itf.trx_id = ratrx.customer_trx_id
                           AND  itf.tax_rate_id = rates.tax_rate_id
                           AND  ratrx.cust_trx_type_id = types.cust_trx_type_id
--                           AND  repc.entity_id = rates.tax_rate_id
--                           AND  repc.entity_code = 'ZX_RATES'
                           AND  itf.extract_source_ledger = 'AR'
                           AND  itf.trx_line_class IN ('INVOICE', 'CREDIT_MEMO', 'DEBIT_MEMO')
                           AND (types.global_attribute7 = 'Y'
                                OR  (types.global_attribute7 = 'N' AND types.global_attribute6 = 'Y' ))
--                           AND repc.reporting_code_char_value is NOT NULL
                      GROUP BY itf.trx_id,
                                itf.trx_line_id,
                                itf.internal_organization_id,
                                itf.trx_number,
                                itf.tax_rate_id,
				                        itf.DOC_SEQ_NAME
                      ORDER BY  itf.trx_id, itf.trx_line_id;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_AMOUNT ');
	END IF;

             -- Get Vat Amount
             GET_VAT_AMOUNT(P_VAT_TAX,
                            P_TAX_REGIME,
                            P_REPORT_NAME,
                            P_REQUEST_ID,
                            l_trx_id_tbl,
                            l_trx_line_id_tbl,
                            l_detail_tax_line_id_tbl,
                            l_tax_rate_tbl,
                            l_document_sub_type_tbl,
                            l_vat_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TAXABLE_AMOUNT ');
	END IF;
             -- Get Taxable Amount
             GET_TAXABLE_AMOUNT(P_VAT_TAX,
                                P_TAX_REGIME,
                                P_REPORT_NAME,
                                P_REQUEST_ID,
                          l_detail_tax_line_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_line_dist_id_tbl,
                                l_trx_id_tbl,
                                l_tax_rate_tbl,
                                l_document_sub_type_tbl,
                                l_taxable_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_EXEMPT_AMOUNT ');
	END IF;
             -- Get Vat Exempt Amount
             GET_VAT_EXEMPT_AMOUNT(P_VAT_TAX,
                                   P_VAT_ADDIT_TAX,
                                   P_VAT_PERC_TAX,
                                   P_REPORT_NAME,
                                   P_TAX_REGIME,
                                   P_REQUEST_ID,
                                   l_trx_id_tbl,
                                   l_detail_tax_line_id_tbl,
                                   l_trx_line_id_tbl,
                                   l_tax_rate_tbl,
                                   l_document_sub_type_tbl,
                                   l_vat_exempt_amt_tbl);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_OTHER_TAX_AMOUNT ');
	END IF;
             -- Get Vat Exempt Amount
             GET_OTHER_TAX_AMOUNT(P_REPORT_NAME,
                                  P_REQUEST_ID,
                                  l_trx_id_tbl,
                                  l_tax_rate_tbl,
                                  l_document_sub_type_tbl,
                                  l_other_tax_amt_tbl);

           -- Get Counted sum doc
	   --Bug 5438742 : Required if TRL has to fetch the document type level totals
          /* GET_COUNTED_SUM_DOC(P_REPORT_NAME,
                               P_REQUEST_ID,
                               l_document_sub_type_tbl,
                               l_cl_num_of_doc_tbl,
                               l_cl_total_exempt_tbl,
                               l_cl_total_taxable_tbl,
                               l_cl_total_vat_tax_tbl,
                               l_cl_total_other_tax_tbl);*/

             -- Insert lines into JX EXT Table with Calculated amount --

             FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

                    INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                    detail_tax_line_id,
                                                    numeric9,
                                                    numeric10,
                                                    numeric2,
                                                    numeric7,
                                                    created_by,
                                                    creation_date,
                                                    last_updated_by,
                                                    last_update_date,
                                                    last_update_login)
                                            VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                    l_detail_tax_line_id_tbl(i),
                                                    l_vat_amt_tbl(i),
                                                    l_taxable_amt_tbl(i),
                                                    l_vat_exempt_amt_tbl(i),
                                                    l_other_tax_amt_tbl(i),
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.user_id,
                                                    sysdate,
                                                    fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
                -- Delete Unwanted lines from Detail ITF

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JL_AP',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR.END',
                                      'ZX_JL_EXTRACT_PKG.POPULATE_JL_AR(-)');
  END IF;

       EXCEPTION
            WHEN OTHERS THEN

              l_err_msg := substrb(SQLERRM,1,120);
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'ZXCLRSLL : Exception '||p_report_name || '.'||l_err_msg);
            END IF;
       END;

 ELSIF P_REPORT_NAME = 'ZXCOARSB' THEN --Bug 5396444

       BEGIN
                -- ------------------------------------------------------
                -- Get all the tax lines and determine the extended amount
                -- and total document amount
                ----------------------------------------------------------

                       SELECT detail_tax_line_id,
                              trx_line_id,
                              trx_id,
                              nvl(currency_conversion_rate,1),
                              tax_rate,
                              tax_rate_id,
                              document_sub_type
            BULK COLLECT INTO l_detail_tax_line_id_tbl,
                              l_trx_line_id_tbl,
                              l_trx_id_tbl,
                              l_exchange_rate_tbl,
                              l_tax_rate_tbl,
                              l_tax_rate_id_tbl,
                              l_document_sub_type_tbl
                         FROM zx_rep_trx_detail_t dtl,	--Bug 5396444
			                        ra_cust_trx_types_all tt
                        WHERE dtl.request_id = P_REQUEST_ID
                        AND dtl.internal_organization_id = tt.org_id
			                  AND dtl.trx_type_id = tt.cust_trx_type_id
			                  AND tt.accounting_affect_flag = 'Y'
                        ORDER BY trx_id, trx_line_id;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'Before call to GET_TOTAL_DOCUMENT_AMOUNT ');
	END IF;

	GET_TOTAL_DOCUMENT_AMOUNT(l_trx_id_tbl,
		       l_exchange_rate_tbl,
		       P_REPORT_NAME,
		       l_total_doc_amt_tbl);

--Bug 5396444 : Added logic for Extended Amount(ext.numeric12) and VAT Amount(ext.numeric9)
-- Get Extended Amount

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_TAXABLE_AMOUNT ');
	END IF;

	GET_TAXABLE_AMOUNT(null,
		  NULL,
		  P_REPORT_NAME,
		  P_REQUEST_ID,
                          l_detail_tax_line_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_line_dist_id_tbl,
		  l_trx_id_tbl,
		  l_tax_rate_tbl ,
		  l_document_sub_type_tbl,
		  l_extended_amt_tbl);

--Get Vat Amount

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'Before call to GET_VAT_AMOUNT ');
	END IF;

       GET_VAT_AMOUNT(NULL ,
                      NULL,
                      P_REPORT_NAME,
                      P_REQUEST_ID,
                      l_trx_id_tbl,
                      l_trx_line_id_tbl,
                      l_detail_tax_line_id_tbl,
                      l_tax_rate_tbl,
                      l_document_sub_type_tbl,
                      l_vat_amt_tbl);


           FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last
                   INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                                   detail_tax_line_id,
                                                   numeric15,--total doc amt
						   numeric12,--extended amt
						   numeric9,--vat amt
                                                   created_by,
                                                   creation_date,
                                                   last_updated_by,
                                                   last_update_date,
                                                   last_update_login)
                                           VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                                   l_detail_tax_line_id_tbl(i),
                                                   (l_total_doc_amt_tbl(i) + l_vat_amt_tbl(i)) * l_exchange_rate_tbl(i), --Bug 5396444
						   l_extended_amt_tbl(i) * l_exchange_rate_tbl(i),--Bug 5396444
						   l_vat_amt_tbl(i) * l_exchange_rate_tbl(i),--Bug 5396444
                                                   fnd_global.user_id,
                                                   sysdate,
                                                   fnd_global.user_id,
                                                   sysdate,
                                                   fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

                -- Delete Unwanted lines from Detail ITF

                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;
       EXCEPTION
            WHEN OTHERS THEN
	    	IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AP',
			'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;

       END;

    ELSIF P_REPORT_NAME = 'ZXCOARSW' THEN --Bug 5251425
    -- Populate zx_rep_trx_jx_ext_t.attribute1 to get the C_TAX_CATEGORY_DESC for the report

		BEGIN
			 SELECT jtc.description
			 INTO l_tax_catg_desc
			 FROM   JL_ZZ_AR_TX_CATEGRY jtc
			 WHERE jtc.tax_category = P_TRL_GLOBAL_VARIABLES_REC.VAT_TAX;
		EXCEPTION
		WHEN OTHERS THEN
		    l_tax_catg_desc := null;
		    l_err_msg := substrb(SQLERRM,1,120);
		    IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					       'ZXCOARSW : Exception '||p_report_name || '.'||l_err_msg);
			FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
								       'Assigned tax_category_desc to null');
		    END IF;
		END ;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'P_TRL_GLOBAL_VARIABLES_REC.VAT_TAX : '||P_TRL_GLOBAL_VARIABLES_REC.VAT_TAX );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'l_tax_catg_desc : '||l_tax_catg_desc );
	END IF;

		       INSERT INTO zx_rep_trx_jx_ext_t
                           (detail_tax_line_ext_id,
                            detail_tax_line_id,
                            attribute1,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            last_update_login)
                    (SELECT zx_rep_trx_jx_ext_t_s.nextval,
                            dtl.detail_tax_line_id,
			    l_tax_catg_desc,
                            dtl.created_by,
                            dtl.creation_date,
                            dtl.last_updated_by,
                            dtl.last_update_date,
                            dtl.last_update_login
			    FROM zx_rep_trx_detail_t dtl
			    WHERE dtl.request_id = p_request_id
			    );

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

      END IF;  -- End of P_REPORT_NAME = ..

 END populate_jl_ar;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_VAT_AMOUNT                                                               |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract VAT Tax Amount for the given report name             |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                  |
 |                 P_TAX_REGIME                IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL Req |
 |      P_DETAIL_TAX_LINE_ID    IN   ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL      |
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL              Opt |
 |                                                                                |
 |    OUT        : X_VAT_AMT_TBL            OUT  NUMERIC9_TBL   |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     07-Nov-03  Hidetaka Kojima   created                                       |
 |     17-Feb-04  Hidekoji          Modified Parameters                           |
 |                                                                                |
 +================================================================================*/


  PROCEDURE GET_VAT_AMOUNT
(
P_VAT_TAX                      IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                   IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                  IN            VARCHAR2,
P_REQUEST_ID                   IN            NUMBER,
P_TRX_ID_TBL                   IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TRX_LINE_ID                  IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_DETAIL_TAX_LINE_ID           IN            ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
P_TAX_RATE_TBL                 IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL        IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_VAT_AMT_TBL                  OUT  NOCOPY   NUMERIC9_TBL

) IS

 l_err_msg                     VARCHAR2(120);
 l_trx_counter                 NUMBER;
 l_vat_amt_tbl                 NUMERIC9_TBL;
 l_gdf_ra_cust_trx_att19_tbl   GDF_RA_CUST_TRX_ATT19_TBL;


BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount.BEGIN',
                                      'ZX_JL_EXTRACT_PKG.get_vat_amount(+)');
   END IF;


     -- ------------------------------------------------------------------------------------------ --
     -- Case1: If report is ZXARPVBR                                                               --
     --        In this case, you cannot use cache as the lines are filtered by Trx ID and tax rate --
     -- ------------------------------------------------------------------------------------------ --

        IF substr(P_REPORT_NAME,1,2) = 'ZX' THEN
        FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

            BEGIN
              IF P_REPORT_NAME = 'ZXARPVBR' THEN
                  SELECT SUM(NVL(itf.tax_amt_funcl_curr,itf.tax_amt))
                    INTO l_vat_amt_tbl(p_trx_id_tbl(i))
                    FROM zx_rep_trx_detail_t itf
                   WHERE itf.request_id = p_request_id
                     AND itf.trx_id = p_trx_id_tbl(i)
                     AND itf.trx_line_id = P_TRX_LINE_ID(i)
                     --AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                     AND itf.tax_rate = p_tax_rate_tbl(i)
                     AND itf.tax_type_code = p_vat_tax;

             ELSIF P_REPORT_NAME = 'ZXCLPPLR' THEN

			IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
			' Document_Sub_Type : '||P_DOCUMENT_SUB_TYPE_TBL(i) );
			END IF;

			IF P_DOCUMENT_SUB_TYPE_TBL(i) = 'JL_CL_CREDIT_MEMO' THEN

				SELECT SUM(nvl(itf.tax_amt_funcl_curr,nvl(itf.tax_amt,0)))
				INTO l_vat_amt_tbl(p_trx_id_tbl(i))
				FROM zx_rep_trx_detail_t itf
				WHERE itf.request_id  = p_request_id
				AND itf.trx_id = p_trx_id_tbl(i)
                                AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
				AND (itf.reverse_flag IS NULL OR itf.reverse_flag <> 'Y')
				AND itf.tax_type_code = 'VAT'
				AND itf.tax_rate <> 0;
                   ELSE
				SELECT SUM(nvl(itf.tax_amt_funcl_curr,nvl(itf.tax_amt,0)))
				INTO l_vat_amt_tbl(p_trx_id_tbl(i))
				FROM zx_rep_trx_detail_t itf
				WHERE itf.request_id = p_request_id
				AND itf.trx_id = p_trx_id_tbl(i)
                                AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
				AND itf.tax_type_code = 'VAT';

			END IF;
                    ELSIF P_REPORT_NAME = 'ZXZZTVSR' THEN

                           SELECT sum(nvl(itf.tax_amt_funcl_curr, itf.tax_amt))
                             INTO l_vat_amt_tbl(p_trx_id_tbl(i))
                             FROM zx_rep_trx_detail_t itf
                            WHERE itf.request_id = p_request_id
                              AND itf.trx_id = p_trx_id_tbl(i)
                              AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                              AND itf.tax_regime_code = nvl(p_tax_regime,itf.tax_regime_code)--Bug 5374021
                              AND itf.tax = p_vat_tax
                              AND nvl(itf.tax_type_code, 'VAT') = 'VAT'
                              AND nvl(itf.tax_rate,0) <> 0 ;
    ELSIF P_REPORT_NAME = 'ZXCLRSLL' THEN

    		IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
			NULL;
		ELSE
			l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := '0';
		END IF;

		IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' AND
                     l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) THEN
		BEGIN

			SELECT decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
			INTO l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
			FROM ra_customer_trx_all
			WHERE customer_trx_id = p_trx_id_tbl(i);

			EXCEPTION
			WHEN OTHERS THEN
				l_err_msg := substrb(SQLERRM,1,120);
				IF (g_level_procedure >= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount.BEGIN',
				'ZX_JL_EXTRACT_PKG.get_vat_amount.'|| P_REPORT_NAME ||':'||l_err_msg);
				END IF;

				END;
			  END IF;

                           IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                              -- OPEN ISSUE --
			      --Bug 5438742 : Added VAT Amt logic for the Bug
			      	SELECT SUM(nvl(itf.tax_amt_funcl_curr,nvl(itf.tax_amt,0)))
				INTO l_vat_amt_tbl(p_trx_id_tbl(i))
				FROM zx_rep_trx_detail_t itf
				WHERE itf.request_id  = p_request_id
				AND itf.trx_id = p_trx_id_tbl(i)
                                AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
				AND itf.tax_type_code = 'VAT'
				AND itf.tax_rate <> 0;

                           ELSE

                               l_vat_amt_tbl(p_trx_id_tbl(i)) := 0;

                           END IF;
                ELSIF P_REPORT_NAME = 'ZXCOARSB' THEN --Bug 5396444 : Vat Amt
				SELECT sum(nvl(itf.tax_amt,0))
				INTO l_vat_amt_tbl(p_trx_id_tbl(i))
				FROM zx_rep_trx_detail_t itf
				WHERE itf.request_id = p_request_id
                                AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
				AND itf.trx_id = p_trx_id_tbl(i);


            END IF;

           IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
                           ' Vat Amt for Report Name  : '||p_report_name ||' trx_id : '
            ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_AMT_TBL(i))||' Dtl ID'||to_char(p_detail_tax_line_id(i)));
            END IF;


                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         X_VAT_AMT_TBL(i) := 0;
                         IF (g_level_statement >= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
                            'No Data Found  : Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i)||' tax_rate : '||p_tax_rate_tbl(i));
                         END IF;

                    WHEN OTHERS THEN
                         l_err_msg := substrb(SQLERRM,1,120);
                         IF (g_level_statement >= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
                           'Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i)||' tax_rate : '||p_tax_rate_tbl(i)||': '||l_err_msg);
                         END IF;

            END;
                    X_VAT_AMT_TBL(i) := l_vat_amt_tbl(p_trx_id_tbl(i));
        END LOOP;

     -- ------------------------------------------------------------------------------------------ --
     -- Case2: If report is NOT ZXARPVBR                                                           --
     --        In this case, you can use cache as the lines are filtered by Trx ID and tax rate    --
     -- ------------------------------------------------------------------------------------------ --

     ELSE

		BEGIN

		SELECT count(distinct trx_id)
		INTO l_trx_counter
		FROM zx_rep_trx_detail_t
		WHERE request_id = p_request_id;

		IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		' l_trx_counter : '||l_trx_counter );
		END IF;

		EXCEPTION

		WHEN OTHERS THEN
		   l_err_msg := substrb(SQLERRM,1,120);
		   IF (g_level_statement >= g_current_runtime_level ) THEN
		       FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount.BEGIN',
				      'ZX_JL_EXTRACT_PKG.get_vat_amount.'|| P_REPORT_NAME ||':'||l_err_msg);
		   END IF;
		END;


		IF (g_level_procedure >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
			      'Get VAT Amount For LOOP :'||to_char(p_trx_id_tbl.last));
		END IF;


         FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP


		IF (g_level_procedure >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
			      'Get VAT Amount For LOOP :'||to_char(i));
		END IF;

	/*	IF l_vat_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
		NULL;
		ELSE
		l_vat_amt_tbl(p_trx_id_tbl(i)) := null;
		END IF; */

		--l_vat_amt_tbl(p_trx_id_tbl(i)) := null;
		l_vat_amt_tbl(p_trx_id_tbl(i)) := 0;

		IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
			NULL;
		ELSE
			l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := '0';
		END IF;

	--	IF l_vat_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

		BEGIN

			IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
				      'Get VAT Amount SQL :'||to_char(l_vat_amt_tbl(p_trx_id_tbl(i))));
			END IF;

                     -- ---------------------------------------------- --
                     --       For AP Reports except ZXARPVBR          --
                     -- ---------------------------------------------- --

                     IF P_REPORT_NAME = 'JLARPCFF' THEN

			--SELECT SUM(nvl(itf.tax_amt_funcl_curr,0))
			SELECT SUM(nvl(itf.tax_amt,0))
			INTO l_vat_amt_tbl(p_trx_id_tbl(i))
			FROM zx_rep_trx_detail_t itf
			WHERE itf.request_id = p_request_id
			AND itf.trx_id = p_trx_id_tbl(i)
      AND nvl(itf.reverse_flag,'N') <> 'Y'
			AND itf.tax_type_code = p_vat_tax;

			IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
			'Get VAT Amount SQL : JLARPCFF:'||to_char(l_vat_amt_tbl(p_trx_id_tbl(i))));
			END IF;


                     ELSIF P_REPORT_NAME = 'JLARPPFF' THEN

			IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
			'Get VAT Amount SQL : JLARPPFF:'||to_char(l_vat_amt_tbl(p_trx_id_tbl(i))));
			END IF;

			SELECT sum(itf.tax_amt)
			INTO l_vat_amt_tbl(p_trx_id_tbl(i))
			FROM zx_rep_trx_detail_t itf
			WHERE itf.request_id = p_request_id
			AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
		--	AND itf.posted_flag    =  'Y'
			AND itf.tax_type_code = p_vat_tax;


			IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
			'Get VAT Amount SQL : JLARPPFF: After SQL'||to_char(l_vat_amt_tbl(p_trx_id_tbl(i))));
			END IF;

                     -- ---------------------------------------------- --
                     --               For AR Reports                   --
                     -- ---------------------------------------------- --

                     ELSIF P_REPORT_NAME = 'JLZZTCFF' THEN

                           SELECT sum(nvl(itf.tax_amt,0))
                             INTO l_vat_amt_tbl(p_trx_id_tbl(i))
                             FROM zx_rep_trx_detail_t itf
                            WHERE itf.request_id = p_request_id
                              AND itf.trx_id = p_trx_id_tbl(i)
                              AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                              AND itf.tax_regime_code = p_tax_regime
                              AND itf.tax = p_vat_tax
                              AND nvl(itf.tax_type_code, 'VAT') = 'VAT';



                     ELSIF P_REPORT_NAME = 'JLARTSFF' THEN

				IF (g_level_procedure >= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
				      'Get VAT Amount : JLARTSFF:');
				END IF;


				IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
				null;

					IF (g_level_procedure >= g_current_runtime_level ) THEN
					FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
					      'Get VAT Amount : l_gdf_ra_cust_trx_att19_tbl not null:');
					END IF;

				ELSE
					l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := null;

					IF (g_level_procedure >= g_current_runtime_level ) THEN
					FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
					'Get VAT Amount : l_gdf_ra_cust_trx_att19_tbl null:');
					END IF;

                                END IF;

                           IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' AND
                               l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) OR
                              l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) IS NULL THEN

--                           IF  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) IS NULL  THEN
				BEGIN
					IF (g_level_procedure >= g_current_runtime_level ) THEN
					FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
					      'Get VAT Amount SQL begin : JLARTSFF:');
					END IF;

					SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
					INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
					FROM  ra_customer_trx_all
					WHERE  customer_trx_id = p_trx_id_tbl(i);

					IF (g_level_procedure >= g_current_runtime_level ) THEN
						FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
						'Get VAT Amount SQL end: JLARTSFF:');
					END IF;


			EXCEPTION
			WHEN OTHERS THEN
				l_err_msg := substrb(SQLERRM,1,120);
				IF (g_level_procedure >= g_current_runtime_level ) THEN
				   FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount.BEGIN',
						'ZX_JL_EXTRACT_PKG.get_vat_amount.'|| P_REPORT_NAME ||':'||l_err_msg);
				END IF;

				END;

	                    END IF;

                          IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                             SELECT sum(nvl(itf.tax_amt_funcl_curr, itf.tax_amt))
                               INTO l_vat_amt_tbl(p_trx_id_tbl(i))
                               FROM zx_rep_trx_detail_t itf,
                                    ar_vat_tax_all vat
                              WHERE itf.request_id = p_request_id
                                AND itf.trx_id = p_trx_id_tbl(i)
                                AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                                AND itf.tax_regime_code = p_tax_regime
                                AND itf.tax = p_vat_tax
                                AND nvl(vat.tax_type,'VAT') = 'VAT'
                                AND itf.tax_rate = p_tax_rate_tbl(i)
                                AND itf.tax_rate_id = vat.vat_tax_id;


			    IF (g_level_procedure >= g_current_runtime_level ) THEN
			    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
					      'VAT Amount : '||to_char(l_vat_amt_tbl(p_trx_id_tbl(i))));
			    END IF;


                          ELSE

                               l_vat_amt_tbl(p_trx_id_tbl(i)) := 0;

                          END IF;

                     ELSIF P_REPORT_NAME = 'JLARTDFF' THEN

                           IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' and
                                l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) THEN

				BEGIN

					SELECT decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
					INTO l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
					FROM ra_customer_trx
					WHERE customer_trx_id = p_trx_id_tbl(i);

				EXCEPTION
				WHEN OTHERS THEN
					l_err_msg := substrb(SQLERRM,1,120);
					IF (g_level_procedure >= g_current_runtime_level ) THEN
					FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount.BEGIN',
					'ZX_JL_EXTRACT_PKG.get_vat_amount.'|| P_REPORT_NAME ||':'||l_err_msg);
					END IF;
				END;

                          END IF;

                           IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                              SELECT sum(nvl(itf.tax_amt,0))
                                INTO l_vat_amt_tbl(p_trx_id_tbl(i))
                                FROM zx_rep_trx_detail_t itf
                               WHERE itf.request_id = p_request_id
                                 AND itf.trx_id = p_trx_id_tbl(i)
                           --      AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                                 AND itf.tax_regime_code = p_tax_regime
                                 AND itf.tax = p_vat_tax
                                 AND nvl(itf.tax_type_code, 'VAT') = 'VAT'
                                 AND nvl(itf.tax_rate,0) <> 0;

                           ELSE

                                l_vat_amt_tbl(p_trx_id_tbl(i)) := 0;

                           END IF;


                     END IF;  -- Match IF P_REPORT_NAME = ...

                     X_VAT_AMT_TBL(i) := nvl(l_vat_amt_tbl(p_trx_id_tbl(i)),0);
			IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount',
			'Get VAT Amount SQL : JLARPPFF: End of Report check'||to_char(l_vat_amt_tbl(p_trx_id_tbl(i))));
			END IF;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      IF (g_level_procedure >= g_current_runtime_level ) THEN
                         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount.BEGIN',
                                'ZX_JL_EXTRACT_PKG.get_vat_amount.'|| P_REPORT_NAME ||':'||l_err_msg);
                      END IF;
                             l_vat_amt_tbl(p_trx_id_tbl(i)) := 0;
                             X_VAT_AMT_TBL(i) := l_vat_amt_tbl(p_trx_id_tbl(i));
                             NULL;

                        WHEN OTHERS THEN
                                  l_err_msg := substrb(SQLERRM,1,120);
                               IF (g_level_procedure >= g_current_runtime_level ) THEN
                                  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount.BEGIN',
                                      'ZX_JL_EXTRACT_PKG.get_vat_amount.'|| P_REPORT_NAME ||':'||l_err_msg);
                               END IF;

                END;
       --      ELSE -- if l_vat_amt_tbl is not null

                 -- X_VAT_AMT_TBL(i) := l_vat_amt_tbl(p_trx_id_tbl(i));
                  --X_VAT_AMT_TBL(i) := 0;

        --     END IF;

	    IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		' Vat Amt for Report Name  : '||p_report_name ||' trx_id : '
                     ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_AMT_TBL(i)));
	    END IF;

       END LOOP;
     END IF; -- Two characters Report Name check--

   IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_amount.BEGIN',
                      'ZX_JL_EXTRACT_PKG.get_vat_amount(-)');
   END IF;
END GET_VAT_AMOUNT;


/*===============================================================================+
 | PROCEDURE                                                                     |
 |   GET_TAXABLE_AMOUNT                                                          |
 |   Type       : Private                                                        |
 |   Pre-req    : None                                                           |
 |   Function   :                                                                |
 |    This procedure extract VAT Tax Amount for the given report name            |
 |                                                                               |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                |
 |                                                                               |
 |   Parameters :                                                                |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                 |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                 |
 |                 P_REQUEST_ID                IN   NUMBER   Req                 |
 |    P_detail_tax_line_id_tbl    IN   ZX_EXTRACT_PKG.detail_tax_line_id_tbl     |
 |             P_trx_line_id_tbl  IN ZX_EXTRACT_PKG.P_trx_line_id_tbl            |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL Req|
 |                 P_TRX_RATE_TBL              IN   ZX_EXTRACT_PKG.RATE_TBL   Opt|
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_     |
 |                                                  SUB_TYPE_TBL              Opt|
 |                                                                               |
 |    OUT                                                                        |
 |                 X_TAXABLE_AMT_TBL        OUT  NUMERIC10_TBL                   |
 |                                                                               |
 |   MODIFICATION HISTORY                                                        |
 |     29-Oct-04  Hidetaka Kojima   created                                      |
 |                                                                               |
 +===============================================================================*/


PROCEDURE GET_TAXABLE_AMOUNT
(
P_VAT_TAX                    IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
P_REQUEST_ID                 IN            NUMBER,
P_DETAIL_TAX_LINE_ID         IN            ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
P_TRX_LINE_ID                IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_TRX_LINE_DIST_ID           IN            ZX_EXTRACT_PKG.TAXABLE_ITEM_SOURCE_ID_TBL,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL      IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_TAXABLE_AMT_TBL            OUT  NOCOPY   NUMERIC10_TBL

) IS

 l_common_sql_string         VARCHAR2(1000);
 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;
 l_taxable_amt_tbl           NUMERIC10_TBL;
 k                           NUMBER;
--INTEGER;

BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount.BEGIN',
                                      'ZX_JL_EXTRACT_PKG.get_taxable_amount(+)');
   END IF;

     -- ------------------------------------------------------------------------------------------ --
     -- Case1: If report is ZXARPVBR                                                               --
     --        In this case, you cannot use cache as the lines are filtered by Trx ID and tax rate --
     -- ------------------------------------------------------------------------------------------ --


       IF P_REPORT_NAME = 'ZXARPVBR' THEN
          k:=0;
          FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
          BEGIN

          IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
              'ZXARPVBR   : For Loop ' );
          END IF;
          IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
              'p_trx_id_tbl : p_trx_line_id:'||to_char(p_trx_id_tbl(i))||' '||to_char(p_trx_line_id(i)));
          END IF;
              --   k:= to_number(to_char(p_trx_id_tbl(i))||to_char(p_trx_line_id(i)));

            IF i = 1 THEN
               k:=1;
            ELSE
               IF (p_trx_id_tbl(i) <> p_trx_id_tbl(i-1)) OR
                  (p_trx_line_id(i) <> p_trx_line_id(i-1)) OR
                  (p_trx_id_tbl(i) = p_trx_id_tbl(i-1) AND
                   p_trx_line_id(i) = p_trx_line_id(i-1) AND
                   p_tax_rate_tbl(i) <> p_tax_rate_tbl(i-1) AND
                   NVL(l_taxable_amt_tbl(k),0) = 0 )  THEN
                   k:=k+1;
               END IF;
           END IF;

          IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                      'K Value : '||to_char(k));
          END IF;

             IF l_taxable_amt_tbl.EXISTS(k) THEN
                null;
              IF (g_level_procedure >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                      'taxable_amt_tbl.EXISTS : '||to_char(k));
              END IF;
             ELSE
                     l_taxable_amt_tbl(k) := null;
              IF (g_level_procedure >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                      'taxable_amt_tbl(k) null : '||to_char(k));
              END IF;
             END IF;

          IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                      'l_taxable_amt_tbl(k) : '||to_char(l_taxable_amt_tbl(k)));
          END IF;

             IF l_taxable_amt_tbl(k) is NULL THEN
              BEGIN
                 SELECT SUM(NVL(itf.taxable_amt_funcl_curr,itf.taxable_amt))
                   INTO l_taxable_amt_tbl(k)
                   FROM zx_rep_trx_detail_t itf
                  WHERE itf.request_id = p_request_id
                    AND itf.trx_id = p_trx_id_tbl(i)
                    AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                    AND itf.trx_line_id = p_trx_line_id(i)
                    AND itf.tax_type_code = p_vat_tax
                    AND itf.tax_rate = p_tax_rate_tbl(i)
                    AND itf.tax_rate <> 0;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN

                        X_TAXABLE_AMT_TBL(i) := 0;
                         IF (g_level_statement >= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                            'No Data Found  : Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i));
                         END IF;

                    WHEN OTHERS THEN
                         IF (g_level_statement >= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                           'Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i)||': '||substr(sqlerrm,1,120));
                         END IF;
                   END;
                     X_TAXABLE_AMT_TBL(i):=l_taxable_amt_tbl(k);
               ELSE
                     X_TAXABLE_AMT_TBL(i):=0;
               END IF;

            END;
        END LOOP;

     -- ------------------------------------------------------------------------------------------ --
     -- Case2: If report is ZXZZTVSR                                                               --
     --        In this case, you cannot use cache as the lines are filtered by Trx ID and tax rate --
     -- ------------------------------------------------------------------------------------------ --

     ELSIF P_REPORT_NAME = 'ZXZZTVSR' THEN
           k:=0;
           FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
           BEGIN

      	    IF ( g_level_statement>= g_current_runtime_level ) THEN
            		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
            		' p_detail_tax_line_id : '||p_detail_tax_line_id(i));
            		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
            		' p_trx_id_tbl : '||p_trx_id_tbl(i));
            		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
            		' p_trx_line_id : '||p_trx_line_id(i));
            		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
            		' p_tax_rate_tbl : '||p_tax_rate_tbl(i));
      	    END IF ;

            IF i = 1 THEN
               k:=1;
            ELSIF (p_trx_line_id(i) <> p_trx_line_id(i-1)) THEN
                   k:=k+1;
            END IF;
     	     IF l_taxable_amt_tbl.EXISTS(k) THEN
    		      null;
    	     ELSE
    		     l_taxable_amt_tbl(k) := null;
    	     END IF;

           IF l_taxable_amt_tbl(k) is NULL THEN
               BEGIN
                     SELECT SUM(nvl(itf.taxable_amt_funcl_curr,itf.taxable_amt))
                       INTO l_taxable_amt_tbl(k)
                       FROM zx_rep_trx_detail_t itf
                      WHERE itf.request_id = p_request_id
                        AND itf.trx_id  = p_trx_id_tbl(i)
                        AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                        AND itf.trx_line_id = p_trx_line_id(i)
	                      and itf.tax_rate <> 0
                        AND itf.tax_rate = p_tax_rate_tbl(i);

               EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         X_TAXABLE_AMT_TBL(i) := 0;
                         IF (g_level_statement >= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                            'No Data Found  : Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i));
                         END IF;
                    WHEN OTHERS THEN
                     IF (g_level_statement >= g_current_runtime_level ) THEN
                         FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                       'Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i)||': '||substr(sqlerrm,1,120));
                     END IF;
               END;
               X_TAXABLE_AMT_TBL(i):=l_taxable_amt_tbl(k);
           ELSE
               X_TAXABLE_AMT_TBL(i):=0;
           END IF;

           END;

    	     IF ( g_level_statement>= g_current_runtime_level ) THEN
        		 FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        		  ' Taxable Amt for Report Name  : '||p_report_name ||' trx_id : '
                           ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_TAXABLE_AMT_TBL(i)));
    	     END IF;

           END LOOP;
          ELSIF P_REPORT_NAME = 'ZXCLPPLR' THEN
               k:=0;
                FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
                BEGIN

                IF ( g_level_statement>= g_current_runtime_level ) THEN
	                	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		                         ' p_detail_tax_line_id : '||p_detail_tax_line_id(i));
	                 	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	                           ' p_trx_id_tbl : '||p_trx_id_tbl(i));
	        	        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		                         ' p_trx_line_id : '||p_trx_line_id(i));
		                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		                         ' p_trx_line_dist_id : '||p_trx_line_dist_id(i));
		                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		                         ' p_tax_rate_tbl : '||p_tax_rate_tbl(i));
	              END IF ;
                 -- k:= to_number(to_char(p_trx_id_tbl(i))||to_char(p_trx_line_id(i)));
		  IF i = 1 THEN
                     k:=1;
                  ELSE
                     IF (p_trx_id_tbl(i) <> p_trx_id_tbl(i-1)) OR
                             (p_trx_line_id(i) <> p_trx_line_id(i-1)) OR
                                 (p_trx_line_dist_id(i) <> p_trx_line_dist_id(i-1)) THEN
                        k:=k+1;
                     END IF;
                  END IF;

                  IF l_taxable_amt_tbl.EXISTS(k) THEN
                     null;
                  ELSE
                     l_taxable_amt_tbl(k) := null;
                  END IF;

             IF l_taxable_amt_tbl(k) is NULL THEN
              BEGIN
                 IF ( g_level_statement>= g_current_runtime_level ) THEN
		     FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
			' Document Sub Type : '||P_DOCUMENT_SUB_TYPE_TBL(i) );
		 END IF;
                     IF P_DOCUMENT_SUB_TYPE_TBL(i) = 'JL_CL_CREDIT_MEMO' THEN
                        SELECT SUM(nvl(itf.taxable_amt_funcl_curr,nvl(itf.taxable_amt,0)))
                          INTO l_taxable_amt_tbl(k)
                          FROM zx_rep_trx_detail_t itf
                         WHERE itf.request_id  = p_request_id
                           AND itf.trx_id  = p_trx_id_tbl(i)
                           AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                           AND itf.trx_line_id = p_trx_line_id(i)
                           AND (itf.reverse_flag IS NULL OR itf.reverse_flag <> 'Y')
			                     AND itf.tax_rate_id = P_TAX_RATE_TBL(i)  --Bug 5413860
                           AND itf.tax_rate <> 0;
                      ELSE
                        SELECT SUM(nvl(itf.taxable_amt_funcl_curr,nvl(itf.taxable_amt,0)))
                          INTO l_taxable_amt_tbl(k)
                          FROM zx_rep_trx_detail_t itf
                         WHERE itf.request_id = p_request_id
                           AND itf.trx_id = p_trx_id_tbl(i)
                           AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                           AND itf.trx_line_id = p_trx_line_id(i)
			                     AND itf.tax_rate_id = P_TAX_RATE_TBL(i) --Bug 5413860
                           AND itf.tax_rate <> 0;

                 IF ( g_level_statement>= g_current_runtime_level ) THEN
		     FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		     ' get taxable_amount() :l_taxable_amt_tbl: '||to_char(l_taxable_amt_tbl(k)));
		 END IF;

                      END IF;
                   END;
                     X_TAXABLE_AMT_TBL(i):=l_taxable_amt_tbl(k);
               ELSE
                     X_TAXABLE_AMT_TBL(i):=0;
               END IF;
            END;
            IF ( g_level_statement>= g_current_runtime_level ) THEN
		                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		                     ' Taxable Amt for Report Name  : '||p_report_name ||' trx_id : '
                           ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_TAXABLE_AMT_TBL(i)));
	          END IF;
        END LOOP;

   ELSIF P_REPORT_NAME = 'ZXCOARSB' THEN --Bug 5396444 : Logic to get the extended amount
            k:=0;
            FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
            BEGIN
              IF i = 1 THEN
                 k:=1;
              ELSIF (p_trx_line_id(i) <> p_trx_line_id(i-1)) THEN
                     k:=k+1;
              END IF;
              IF l_taxable_amt_tbl.EXISTS(k) THEN
                null;
              ELSE
               l_taxable_amt_tbl(k) := null;
              END IF;

              IF l_taxable_amt_tbl(k) is NULL THEN
                BEGIN
         	      SELECT (SUM(DECODE(ctl.line_type,'LINE', NVL(ctl.extended_amount,0),0))
  				            + SUM(DECODE(ctl.line_type,'FREIGHT',NVL(ctl.extended_amount,0),0))
  		                + SUM(DECODE(ctl.line_type,'CHARGE',NVL(ctl.extended_amount,0),0)))
  			         INTO l_taxable_amt_tbl(k)
  			         FROM ra_customer_trx_lines_all  ctl
                WHERE ctl.customer_trx_line_id = p_trx_line_id(i)
  			          AND ctl.customer_trx_id = p_trx_id_tbl(i);
                END;
                X_TAXABLE_AMT_TBL(i):=l_taxable_amt_tbl(k);
              ELSE
                X_TAXABLE_AMT_TBL(i):=0;
              END IF;
            END;
            END LOOP;
    ELSIF P_REPORT_NAME = 'ZXCLRSLL' THEN
            k:=0;
            FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
            BEGIN
              IF i = 1 THEN
                 k:=1;
              ELSIF (p_trx_line_id(i) <> p_trx_line_id(i-1)) THEN
                     k:=k+1;
              END IF;
              IF l_taxable_amt_tbl.EXISTS(k) THEN
                null;
              ELSE
               l_taxable_amt_tbl(k) := null;
              END IF;

              IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(k) THEN
                  NULL;
              ELSE
                 l_gdf_ra_cust_trx_att19_tbl(k) := '0';
              END IF;

              IF l_taxable_amt_tbl(k) is NULL THEN
              BEGIN
  			           IF ( l_gdf_ra_cust_trx_att19_tbl(k) <> 'IS_NULL'
                    AND l_gdf_ra_cust_trx_att19_tbl(k) <> 'NOT_NULL' ) THEN

                      BEGIN
  		                SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
  			                INTO  l_gdf_ra_cust_trx_att19_tbl(k)
  			                FROM  ra_customer_trx_all
  			               WHERE  customer_trx_id = p_trx_id_tbl(i);

                		   IF (g_level_statement >= g_current_runtime_level ) THEN
                		      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                			   'Inside Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i)||': '
                                             ||' ga9 : '||l_gdf_ra_cust_trx_att19_tbl(k));
                	     END IF;

  		                EXCEPTION	WHEN OTHERS THEN
                				IF (g_level_statement >= g_current_runtime_level ) THEN
                			      	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                				     'Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '
                                                     ||p_trx_id_tbl(i)||': '||substr(sqlerrm,1,120));
                				END IF;
  			              END;
     		          END IF;

              		IF l_gdf_ra_cust_trx_att19_tbl(k) = 'IS_NULL' THEN
                              SELECT SUM(nvl(itf.taxable_amt_funcl_curr,nvl(itf.taxable_amt,0)))
                                INTO l_taxable_amt_tbl(k)
                                FROM zx_rep_trx_detail_t itf
                               WHERE itf.request_id = p_request_id
                                 AND itf.trx_id = p_trx_id_tbl(i)
                                 AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                                 AND itf.trx_line_id = p_trx_line_id(i)
                				         AND itf.tax_rate_id = P_TAX_RATE_TBL(i)
                                AND itf.tax_rate <> 0;
                   ELSE
                             l_taxable_amt_tbl(k) := 0;
                   END IF;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      l_taxable_amt_tbl(k) := 0;
                      X_TAXABLE_AMT_TBL(i) := l_taxable_amt_tbl(k);
                      NULL;
                      IF (g_level_statement >= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                        'No Data Found  : Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i));
                      END IF;

                 WHEN OTHERS THEN
                         IF (g_level_statement >= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                           'Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i)||': '||substr(sqlerrm,1,120));
                         END IF;

              END;
              X_TAXABLE_AMT_TBL(i):=l_taxable_amt_tbl(k);
           ELSE
              X_TAXABLE_AMT_TBL(i):=0;
           END IF;
        END;

  	    IF ( g_level_statement>= g_current_runtime_level ) THEN
        		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        		' Taxable Amt for Report Name  : '||p_report_name ||' trx_id : '
                           ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_TAXABLE_AMT_TBL(i)));
  	    END IF;
        END LOOP;


     -- ------------------------------------------------------------------------------------------ --
     -- Case3: If report is NOT ZXARPVBR or NOT ZXZZTVSR                                                           --
     --        In this case, you can use cache as the lines are filtered by Trx ID and tax rate    --
     -- ------------------------------------------------------------------------------------------ --

   ELSE
       BEGIN
          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

  	     IF ( g_level_statement>= g_current_runtime_level ) THEN
		  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		  ' l_trx_counter : '||l_trx_counter );
	      END IF;
         EXCEPTION
            WHEN OTHERS THEN
                  l_err_msg := substrb(SQLERRM,1,120);
			IF ( g_level_statement>= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount ',
				      'ZX_JL_EXTRACT_PKG.get_taxable_amount.'|| P_REPORT_NAME ||':'||l_err_msg);
      		END IF;
         END;


         FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
           BEGIN

            IF P_REPORT_NAME = 'JLARPPFF' THEN
	               IF i = 1 THEN
                    k:=1;
                 ELSIF (p_trx_id_tbl(i) <> p_trx_id_tbl(i-1)) OR
                      (p_trx_line_id(i) <> p_trx_line_id(i-1)) THEN
                       k:=k+1;
                 END IF;

                 IF l_taxable_amt_tbl.EXISTS(k) THEN
                    null;
                 ELSE
                    l_taxable_amt_tbl(k) := null;
                 END IF;

            ELSE
	               IF i = 1 THEN
                    k:=1;
                 ELSIF (p_trx_line_id(i) <> p_trx_line_id(i-1)) THEN
                       k:=k+1;
                 END IF;
                 IF l_taxable_amt_tbl.EXISTS(k) THEN
                    null;
                 ELSE
                    l_taxable_amt_tbl(k) := null;
                 END IF;

                 IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                    NULL;
                 ELSE
                   l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := '0';
                 END IF;
            END IF;

             IF l_taxable_amt_tbl(k) is NULL THEN
                BEGIN
                     IF P_REPORT_NAME = 'JLARPPFF' THEN
              			    IF ( g_level_statement>= g_current_runtime_level ) THEN
              				    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount ',
              			      'get_taxable : '|| to_char(k)||' '||to_char(p_trx_id_tbl(i))||' '||to_char(p_tax_rate_tbl(i)));
                    		END IF;
                        SELECT abs(nvl(SUM(itf.taxable_amt),0))
                          INTO l_taxable_amt_tbl(k)
                          FROM zx_rep_trx_detail_t itf
                         WHERE itf.request_id = p_request_id
                           AND itf.trx_id = p_trx_id_tbl(i)
                           AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                           AND itf.trx_line_id = p_trx_line_id(i)
                           AND itf.tax_type_code = p_vat_tax
                           AND itf.tax_rate = p_tax_rate_tbl(i)
                           AND itf.tax_rate <> 0;

                    -- ---------------------------------------------- --
                    --               For AR Reports                   --
                    -- ---------------------------------------------- --

                    ELSIF P_REPORT_NAME = 'JLARTPFF' THEN

                          SELECT ABS(SUM(itf.taxable_amt_funcl_curr))
                            INTO l_taxable_amt_tbl(k)
                            FROM zx_rep_trx_detail_t itf
                           WHERE itf.request_id = p_request_id
                             AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                             AND itf.trx_line_id = p_trx_line_id(i)
                             AND itf.trx_id = p_trx_id_tbl(i);

                    ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN

                          IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' AND
                               l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) OR
                               l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) IS NULL  THEN

                              BEGIN
                                SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                                  INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                                  FROM  ra_customer_trx_all
                                 WHERE  customer_trx_id = p_trx_id_tbl(i);

                              EXCEPTION
                                 WHEN OTHERS THEN
                        			     IF (g_level_statement >= g_current_runtime_level ) THEN
                        				FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                        				'Report Name : '||P_REPORT_NAME ||'i : '||i||' trx_id : '||p_trx_id_tbl(i)||': '
                                                        ||substr(sqlerrm,1,120));
                        			     END IF;
                               END;
                          END IF;

                          IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN
                    			  IF (g_level_procedure >= g_current_runtime_level ) THEN
                    			     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                    						      'Trx ID : '||to_char(p_trx_id_tbl(i)));
                    			     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                    						      'p_tax_rate_tbl : '||to_char(p_tax_rate_tbl(i)));
                    			     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                    						      'p_tax_regime : '||p_tax_regime);
                    			     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                    						      'p_vat_tax : '||p_vat_tax);
                    			   END IF;

                             SELECT  NVL(sum(nvl(itf.taxable_amt_funcl_curr,itf.taxable_amt)),0)
                               INTO  l_taxable_amt_tbl(k)
                               FROM  zx_rep_trx_detail_t itf
                              WHERE  itf.request_id = p_request_id
                                AND  itf.trx_id  = p_trx_id_tbl(i)
                                 AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                                 AND itf.trx_line_id = p_trx_line_id(i)
                                AND  itf.tax_regime_code = p_tax_regime
                                AND  itf.tax = p_vat_tax
                                AND  itf.tax_rate = p_tax_rate_tbl(i)
                                AND  nvl(itf.tax_rate,0) <> 0;

                            IF (g_level_procedure >= g_current_runtime_level ) THEN
                               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                                      'Trx ID After query  : '||to_char(l_taxable_amt_tbl(k)));
                            END IF;
                          ELSE
                              l_taxable_amt_tbl(k) := 0;
                          END IF;
                    END IF;
                  EXCEPTION
                  when others then
                    IF (g_level_procedure >= g_current_runtime_level ) THEN
                       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount',
                              'Trx ID Exemption  : '||to_char(p_trx_id_tbl(i)));
                    END IF;
                    l_taxable_amt_tbl(k) := 0;
                 END;
              X_TAXABLE_AMT_TBL(i) := l_taxable_amt_tbl(k);
         ELSE -- if l_vat_amt_tbl is not null
              X_TAXABLE_AMT_TBL(i) := 0;
         END IF;

  	    IF ( g_level_statement>= g_current_runtime_level ) THEN
      		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
      		' Taxable Amt for Report Name  : '||p_report_name ||' trx_id : '
                         ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_TAXABLE_AMT_TBL(i)));
  	    END IF;
        END;
       END LOOP;

     END IF;
     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_taxable_amount.BEGIN',
                                        'ZX_JL_EXTRACT_PKG.get_taxable_amount(-)');
     END IF;
END GET_TAXABLE_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_NON_TAXABLE_AMOUNT                                                       |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract VAT Tax Amount for the given report name             |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_NON_TAXABLE_AMT_TBL    OUT  NUMERIC8_TBL   |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


PROCEDURE GET_NON_TAXABLE_AMOUNT
(
P_NON_TAXAB_TAX              IN            VARCHAR2 DEFAULT NULL,
P_VAT_TAX                    IN            VARCHAR2 DEFAULT NULL,
P_VAT_ADDIT_TAX              IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERCEP_TAX             IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_DETAIL_TAX_LINE_ID         IN            ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
P_TRX_LINE_ID                IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
X_NON_TAXABLE_AMT_TBL        OUT  NOCOPY   NUMERIC8_TBL
) IS

 l_err_msg                     VARCHAR2(120);
 l_trx_counter                 NUMBER;
 l_gdf_ra_cust_trx_att19_tbl   GDF_RA_CUST_TRX_ATT19_TBL;
 l_non_taxable_amt_tbl         NUMERIC8_TBL;
 k NUMBER;

BEGIN

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_non_taxable_amount.BEGIN',
                                      'ZX_JL_EXTRACT_PKG.get_non_taxable_amount(+)');
   END IF;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' l_trx_counter : '||l_trx_counter );
    END IF;

     EXCEPTION

          WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.get_non_taxable_amount',
			'Error Message  : '||substrb(SQLERRM,1,120) );
		END IF;

     END;

     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
        IF P_REPORT_NAME in ('ZXARPVBR','JLARPPFF','ZXZZTVSR') THEN
           IF i = 1 THEN
               k:=1;
            ELSE
               IF (p_trx_id_tbl(i) <> p_trx_id_tbl(i-1)) OR
                             (p_trx_line_id(i) <> p_trx_line_id(i-1)) THEN
                   k:=k+1;
               END IF;
           END IF;
            IF l_non_taxable_amt_tbl.EXISTS(k) THEN
               null;
            ELSE
               l_non_taxable_amt_tbl(k) := null;
            END IF;
        ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN
          k:=p_trx_id_tbl(i);
          IF l_non_taxable_amt_tbl.EXISTS(k) THEN
             null;
          ELSE
             l_non_taxable_amt_tbl(k) := null;
          END IF;
          IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(k) THEN
             null;
          ELSE
             l_gdf_ra_cust_trx_att19_tbl(k) := null;
          END IF;
        END IF;

         IF l_non_taxable_amt_tbl(k) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME in ('ZXARPVBR','JLARPPFF') THEN

                     SELECT SUM(NVL(itf.taxable_amt_funcl_curr,itf.taxable_amt))
                       INTO l_non_taxable_amt_tbl(k)
                       FROM zx_rep_trx_detail_t itf
                      WHERE itf.request_id = p_request_id
                        AND itf.trx_id = p_trx_id_tbl(i)
                        AND itf.trx_line_id = p_trx_line_id(i)
                        AND itf.tax_type_code = p_non_taxab_tax;

                 -- ---------------------------------------------- --
                 --               For AR Reports                   --
                 -- ---------------------------------------------- --

                 ELSIF P_REPORT_NAME = 'ZXZZTVSR' THEN

                       SELECT SUM(itf.taxable_amt_funcl_curr)
                         INTO l_non_taxable_amt_tbl(k)
                         FROM zx_rep_trx_detail_t itf
                        WHERE itf.request_id = p_request_id
                          AND itf.trx_id = p_trx_line_id(i)
                          AND itf.tax NOT IN (p_vat_tax, p_vat_addit_tax,p_vat_percep_tax);

                 ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN

                       IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' and
                            l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) OR
                            (l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) is NULL ) THEN

                          BEGIN

                              SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                                INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                                FROM  ra_customer_trx
                               WHERE  customer_trx_id = p_trx_id_tbl(i);

                          EXCEPTION
                             WHEN OTHERS THEN
                  			     IF ( g_level_statement>= g_current_runtime_level ) THEN
                  				     FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.GET_NON_TAXABLE_AMOUNT',
                  					   'Error Message  : '||substrb(SQLERRM,1,120) );
                  				  END IF;
                          END;

                       END IF;

                       IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                          SELECT  sum(nvl(itf.tax_amt ,0))
                            INTO  l_non_taxable_amt_tbl(p_trx_id_tbl(i))
                            FROM  zx_rep_trx_detail_t itf
                           WHERE  itf.request_id = p_request_id
                             AND  itf.trx_id = p_trx_id_tbl(i)
                             AND  nvl(itf.tax_type_code, 'VAT') = 'VAT'
                             AND  itf.tax = p_non_taxab_tax;

                       ELSE
                          l_non_taxable_amt_tbl(k) := 0;
                       END IF;
                 END IF; -- IF P_REPORT_NAME = ..

                 X_NON_TAXABLE_AMT_TBL(i) := NVL(l_non_taxable_amt_tbl(k),0);

            EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_non_taxable_amt_tbl(k) := 0;
                         X_NON_TAXABLE_AMT_TBL(i) := l_non_taxable_amt_tbl(k);
                         NULL;

                    WHEN OTHERS THEN
			IF ( g_level_statement>= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.GET_NON_TAXABLE_AMOUNT',
				'Error Message  : '||substrb(SQLERRM,1,120) );
			END IF;
            END;

         ELSE -- if l_non_taxable_amt_tbl is not null

              X_NON_TAXABLE_AMT_TBL(i) := nvl(l_non_taxable_amt_tbl(k),0);

         END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' Non Taxable Amt for Report Name  : '||p_report_name ||' trx_id : '||to_char(k)||' is : '||to_char(X_NON_TAXABLE_AMT_TBL(i)));
    END IF;

   END LOOP;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_non_taxable_amount.END',
                                      'ZX_JL_EXTRACT_PKG.get_non_taxable_amount(-)');
   END IF;

END GET_NON_TAXABLE_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_VAT_ADDITIONAL_AMOUNT                                                        |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract VAT Exempt Amount for the given report name          |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_ADDIT_TAX             IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                 P_TAX_RATE_ID_TBL           IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL               Opt|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_VAT_ADDITIONAL_AMT_TBL OUT  NUMERIC11_TBL  |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


  PROCEDURE GET_VAT_ADDITIONAL_AMOUNT
(
P_VAT_ADDIT_TAX              IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_ID_TBL            IN            ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
X_VAT_ADDITIONAL_AMT_TBL     OUT  NOCOPY   NUMERIC7_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_vat_additional_amt_tbl    NUMERIC7_TBL;


BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_ADDITIONAL_AMOUNT.BEGIN',
                                      'ZX_JL_EXTRACT_PKG.GET_VAT_ADDITIONAL_AMOUNT(+)');
   END IF;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

	    IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		' l_trx_counter : '|| l_trx_counter );
	    END IF;

     EXCEPTION

          WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_additional_amount',
			'ZX_JL_EXTRACT_PKG.get_vat_additional_amount : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;

     END;

     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

         IF l_vat_additional_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
                l_vat_additional_amt_tbl(p_trx_id_tbl(i)) := null;
         END IF;

         IF l_vat_additional_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

    IF ( g_level_statement>= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_additional_amount',
               'ZX_JL_EXTRACT_PKG.get_vat_additional_amount : '||p_report_name
                 ||' : '||to_char(l_vat_additional_amt_tbl(p_trx_id_tbl(i))));
      END IF;


            BEGIN

                 IF P_REPORT_NAME IN ('ZXZZTVSR','JLARTSFF') THEN

                    SELECT SUM(NVL(itf.tax_amt_funcl_curr,itf.tax_amt))
                      INTO l_vat_additional_amt_tbl(p_trx_id_tbl(i))
                      FROM zx_rep_trx_detail_t itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                     --  AND itf.tax_rate_id = p_tax_rate_id_tbl(i)
                       ANd itf.tax = p_vat_addit_tax;

      IF ( g_level_statement>= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_additional_amount',
               'ZX_JL_EXTRACT_PKG.get_vat_additional_amount : '||p_report_name
                 ||' : '||to_char(l_vat_additional_amt_tbl(p_trx_id_tbl(i))));
      END IF;


                 END IF;

                 X_VAT_ADDITIONAL_AMT_TBL(i) := l_vat_additional_amt_tbl(p_trx_id_tbl(i));

            EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_vat_additional_amt_tbl(p_trx_id_tbl(i)) := 0;
                         X_VAT_ADDITIONAL_AMT_TBL(i) := l_vat_additional_amt_tbl(p_trx_id_tbl(i));
                         NULL;

                    WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_additional_amount',
			'ZX_JL_EXTRACT_PKG.get_vat_additional_amount : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;

            END;

         ELSE -- if l_vat_iaddtional_amt_tbl is not null

 --          X_VAT_ADDITIONAL_AMT_TBL(i) := l_vat_additional_amt_tbl(p_trx_id_tbl(i));
              X_VAT_ADDITIONAL_AMT_TBL(i) := 0;
         END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' Vat Additional Amt for Report Name  : '||p_report_name ||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_ADDITIONAL_AMT_TBL(i)));
    END IF;

   END LOOP;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_additional_amount',
		'jl.plsql.ZX_JL_EXTRACT_PKG.get_vat_additional_amount(-)');
   END IF;

END GET_VAT_ADDITIONAL_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_VAT_EXEMPT_AMOUNT                                                        |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract VAT Exempt Amount for the given report name          |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL               Opt|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_VAT_EXEMPT_AMT_TBL    OUT  NUMERIC14_TBL   |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


  PROCEDURE GET_VAT_EXEMPT_AMOUNT
(
P_VAT_TAX                    IN            VARCHAR2 DEFAULT NULL,
P_VAT_ADDIT_TAX              IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERCEP_TAX             IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_DETAIL_TAX_LINE_ID           IN            ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
P_TRX_LINE_ID_TBL            IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL      IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_VAT_EXEMPT_AMT_TBL         OUT  NOCOPY   NUMERIC2_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_vat_exempt_amt_tbl        NUMERIC2_TBL;
 l_vat_0_amt_tbl             NUMERIC2_TBL;
 l_no_vat_amt_tbl            NUMERIC2_TBL;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;
 k NUMBER;
BEGIN

 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	  --Bug 5058043
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT.BEGIN',
	     'GET_VAT_EXEMPT_AMOUNT(+)');
	  END IF ;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' GET_VAT_EXEMPT_AMOUNT : l_trx_counter : '|| l_trx_counter );
    END IF;

     EXCEPTION

          WHEN OTHERS THEN
              l_err_msg := substrb(SQLERRM,1,120);
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
	     'ZX_JL_EXTRACT_PKG.get_vat_exempt_amount.'||p_report_name || '.'||l_err_msg);

          END IF;

     END;

     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

        IF P_REPORT_NAME in ('ZXARPVBR','JLARPPFF') THEN
           IF i = 1 THEN
               k:=1;
           ELSE
               IF (p_trx_id_tbl(i) <> p_trx_id_tbl(i-1)) OR
                             (p_trx_line_id_tbl(i) <> p_trx_line_id_tbl(i-1))
                              OR (p_tax_rate_tbl(i) <> p_tax_rate_tbl(i-1)) THEN
                   k:=k+1;
               END IF;
           END IF;

            IF l_vat_exempt_amt_tbl.EXISTS(k) THEN
               null;
            ELSE
               l_vat_exempt_amt_tbl(k) := null;
            END IF;
        ELSE
           IF i = 1 THEN
               k:=1;
           ELSIF (p_trx_line_id_tbl(i) <> p_trx_line_id_tbl(i-1)) THEN
                   k:=k+1;
           END IF;

          IF l_vat_exempt_amt_tbl.EXISTS(k) THEN
             null;
          ELSE
             l_vat_exempt_amt_tbl(k) := null;
          END IF;
        END IF;

        IF l_vat_exempt_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
          null;
        ELSE
           l_vat_exempt_amt_tbl(p_trx_id_tbl(i)) := null;
        END IF;
        IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
        	NULL;
        ELSE
        	l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := '0';
        END IF;

         --IF l_vat_exempt_amt_tbl(p_trx_id_tbl(i)) is NULL THEN
         IF l_vat_exempt_amt_tbl(k) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME in ('ZXARPVBR','JLARPPFF') THEN
                   BEGIN
                   IF (g_level_procedure >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                       'ZX_JL_EXTRACT_PKG.get_vat_exempt_amount : Call for '||p_report_name );

                   END IF;

                    SELECT SUM(NVL(itf.taxable_amt_funcl_curr,itf.taxable_amt))
                      INTO l_vat_exempt_amt_tbl(p_trx_id_tbl(i))
                      FROM ZX_REP_TRX_DETAIL_T itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.trx_line_id = p_trx_line_id_tbl(i)
                       AND itf.detail_tax_line_id = P_DETAIL_TAX_LINE_ID(i)
                      -- AND itf.tax_type_code = 'Exempt'
                       AND itf.tax_type_code = P_VAT_TAX
                       AND itf.tax_rate = 0;

                   IF (g_level_procedure >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                       'ZX_JL_EXTRACT_PKG.get_vat_exempt_amount : Exempt Amt '
                          ||to_char(l_vat_exempt_amt_tbl(p_trx_id_tbl(i))) );
                   END IF;

                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         l_vat_exempt_amt_tbl(k) := 0;
                         X_VAT_EXEMPT_AMT_TBL(i) := l_vat_exempt_amt_tbl(k);
                      IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_exempt_amount',
                        'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
                      END IF;
                         NULL;

                    WHEN OTHERS THEN
                      IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_exempt_amount',
                        'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
                      END IF;

                    END;
                 ELSIF P_REPORT_NAME = 'ZXCLPPLR' THEN


                       IF P_DOCUMENT_SUB_TYPE_TBL(i) = 'DOCUMENT TYPE.JL_CL_CREDIT_MEMO' THEN
                          IF ( g_level_statement>= g_current_runtime_level ) THEN
                               FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_exempt_amount',
                                              'GET_VAT_EXEMPT_AMOUNT:ZXCLPPLR:Inside IF : ' );
                          END IF;

                          SELECT SUM(nvl(itf.taxable_amt_funcl_curr,nvl(itf.taxable_amt,0)))
                            INTO l_vat_exempt_amt_tbl(p_trx_id_tbl(i))
                            FROM zx_rep_trx_detail_t itf
                           WHERE itf.request_id  = p_request_id
                             AND itf.trx_id = p_trx_id_tbl(i)
                             AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                             AND (itf.reverse_flag IS NULL OR itf.reverse_flag <> 'Y')
                             AND itf.tax_rate = 0;

                       ELSE
                          IF ( g_level_statement>= g_current_runtime_level ) THEN
                               FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_exempt_amount',
                                              'GET_VAT_EXEMPT_AMOUNT:ZXCLPPLR:Inside ELSE : ' );
                          END IF;

                          SELECT SUM(nvl(itf.taxable_amt_funcl_curr,nvl(itf.taxable_amt,0)))
                            INTO l_vat_exempt_amt_tbl(p_trx_id_tbl(i))
                            FROM zx_rep_trx_detail_t itf
                           WHERE itf.request_id = p_request_id
                             AND itf.trx_id = p_trx_id_tbl(i)
                             AND itf.detail_tax_line_id = p_detail_tax_line_id(i)
                             AND itf.tax_rate = 0;

                       END IF;

                 -- ---------------------------------------------- --
                 --               For AR Reports                   --
                 -- ---------------------------------------------- --

                 ELSIF P_REPORT_NAME = 'ZXZZTVSR' THEN

                       IF ( g_level_statement>= g_current_runtime_level ) THEN
                          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
                          'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' test : ');
                       END IF;
                       IF l_vat_0_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                          null;
                       ELSE
                            l_vat_0_amt_tbl(p_trx_id_tbl(i)) := null;
                       END IF;

		                   IF ( g_level_statement>= g_current_runtime_level ) THEN
                          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
                          'l_vat_0_amt_tbl : '||to_char(l_vat_0_amt_tbl(p_trx_id_tbl(i)))||' : i-'||to_char(i));
                          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
                          'Trx ID : '||to_char(p_trx_id_tbl(i)));
                       END IF;

                       IF l_vat_0_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

                          SELECT sum(nvl(itf.taxable_amt_funcl_curr,itf.taxable_amt))
                            INTO l_vat_0_amt_tbl(p_trx_id_tbl(i))
                            FROM zx_rep_trx_detail_t itf
                           WHERE itf.request_id = p_request_id
                             AND itf.trx_id = p_trx_id_tbl(i)
                             AND nvl(itf.tax_type_code,'VAT') = 'VAT'
                             AND itf.tax_rate = 0
                             AND itf.tax IN (p_vat_tax,p_vat_addit_tax,p_vat_percep_tax);

                         IF ( g_level_statement>= g_current_runtime_level ) THEN
                            FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
                            'l_vat_0_amt_tbl : '||to_char(l_vat_0_amt_tbl(p_trx_id_tbl(i))));
                         END IF;
                       END IF;

                       IF l_no_vat_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                          null;
                       ELSE
                            l_no_vat_amt_tbl(p_trx_id_tbl(i)) := null;
                       END IF;

                       IF l_no_vat_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

                          SELECT sum(nvl(itf.taxable_amt_funcl_curr,0))
                            INTO l_no_vat_amt_tbl(p_trx_id_tbl(i))
                            FROM zx_rep_trx_detail_t itf
                           WHERE itf.request_id = p_request_id
                             AND itf.trx_id = p_trx_id_tbl(i)
			                       AND itf.tax_rate = 0
                             AND ( itf.tax_regime_code  <> p_tax_regime OR itf.tax <> p_vat_tax )
                             AND nvl(itf.tax_type_code,'VAT') = 'VAT';

                           IF ( g_level_statement>= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
                              'l_no_vat_amt_tbl : '||to_char(l_no_vat_amt_tbl(p_trx_id_tbl(i))));
                           END IF;
                       END IF;

		                   IF l_vat_exempt_amt_tbl(p_trx_id_tbl(i)) IS NULL THEN
                         l_vat_exempt_amt_tbl(p_trx_id_tbl(i)) :=  nvl(l_vat_0_amt_tbl(p_trx_id_tbl(i)),0) +
                                                                   nvl(l_no_vat_amt_tbl(p_trx_id_tbl(i)),0);
  		                   IF ( g_level_statement>= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
                             'l_vat_exempt_amt_tbl : one '||to_char(l_vat_exempt_amt_tbl(p_trx_id_tbl(i))));
                         END IF;
		                   ELSE
                         l_vat_exempt_amt_tbl(p_trx_id_tbl(i)) := 0;
                         IF ( g_level_statement>= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
                             'l_vat_exempt_amt_tbl : two '||to_char(l_vat_exempt_amt_tbl(p_trx_id_tbl(i))));
                         END IF;
                       END IF;

                       IF ( g_level_statement>= g_current_runtime_level ) THEN
                          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
                          'l_vat_exempt_amt_tbl : '||to_char(l_vat_exempt_amt_tbl(p_trx_id_tbl(i))));
                       END IF;

                 ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN

                  IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' AND
                     l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) OR
                     l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) IS NULL  THEN

                          BEGIN
			IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' test : ');
			END IF;

                              SELECT decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                                INTO l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                                FROM ra_customer_trx
                               WHERE customer_trx_id = p_trx_id_tbl(i);

                          EXCEPTION
                            WHEN OTHERS THEN
			IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
			END IF;

                          END;

                       END IF;

                       IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN
			IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' test 1 : ');
			END IF;

                          SELECT NVL(sum(nvl(itf.taxable_amt_funcl_curr,0)),0)
                            INTO l_vat_exempt_amt_tbl(p_trx_id_tbl(i))
                            --INTO l_vat_exempt_amt_tbl(k)
                            FROM zx_rep_trx_detail_t itf
                           WHERE itf.request_id = p_request_id
                             AND itf.trx_id = p_trx_id_tbl(i)
                             AND itf.trx_line_id = p_trx_line_id_tbl(i)  -- new join
                             AND nvl(itf.tax_type_code,'VAT') = 'VAT'
                             AND itf.tax_rate = 0
                             AND itf.tax = p_vat_tax;

                       ELSE

                          l_vat_exempt_amt_tbl(p_trx_id_tbl(i)) := 0;
                          --l_vat_exempt_amt_tbl(k) := 0;

                       END IF;

                 ELSIF P_REPORT_NAME = 'ZXCLRSLL' THEN

                       IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                          null;
                       ELSE
                              l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := null;
                       END IF;

			IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL'
                        AND l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) THEN
                          BEGIN

                              SELECT decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                                INTO l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                                FROM ra_customer_trx_all
                               WHERE customer_trx_id = p_trx_id_tbl(i);

                          EXCEPTION

                       WHEN OTHERS THEN
		         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := null;
			IF ( g_level_statement>= g_current_runtime_level ) THEN
		           FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_additional_amount',
			'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
			END IF;
                       END;
                     END IF;

                       IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                         SELECT Nvl( Sum( Decode(itf.tax_rate,0,
                                                  coalesce(itf.taxable_amt_funcl_curr,itf.taxable_amt,0),
                                                  (nvl(itf.EXEMPT_RATE_MODIFIER,0) * coalesce(itf.taxable_amt_funcl_curr,itf.taxable_amt,0))
                                                 )
                                          ),0)
                          INTO l_vat_exempt_amt_tbl(p_trx_id_tbl(i))
                          FROM zx_rep_trx_detail_t itf
                  				WHERE itf.request_id = p_request_id
                  				AND itf.trx_id = p_trx_id_tbl(i);

                       ELSE

                          l_vat_exempt_amt_tbl(p_trx_id_tbl(i)) := 0;

                       END IF;

                 END IF; -- IF P_REPORT_NAME ...

                 l_vat_exempt_amt_tbl(k) := l_vat_exempt_amt_tbl(p_trx_id_tbl(i));
                 X_VAT_EXEMPT_AMT_TBL(i) := l_vat_exempt_amt_tbl(k);

            EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_vat_exempt_amt_tbl(p_trx_id_tbl(i)) := 0;
                         l_vat_exempt_amt_tbl(k) :=l_vat_exempt_amt_tbl(p_trx_id_tbl(i));
                      --   X_VAT_EXEMPT_AMT_TBL(i) := l_vat_exempt_amt_tbl(p_trx_id_tbl(i));
                         X_VAT_EXEMPT_AMT_TBL(i) := l_vat_exempt_amt_tbl(k);
	              IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_exempt_amount',
			'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		      END IF;
                         NULL;

                    WHEN OTHERS THEN
		      IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_exempt_amount',
			'ZX_JL_EXTRACT_PKG.GET_VAT_EXEMPT_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		      END IF;
                END;

         ELSE -- if l_vat_exempt_amt_tbl is not null

         --     X_VAT_EXEMPT_AMT_TBL(i) := l_vat_exempt_amt_tbl(p_trx_id_tbl(i));
                X_VAT_EXEMPT_AMT_TBL(i) := 0;


         END IF;

        IF ( g_level_statement>= g_current_runtime_level ) THEN
        	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        	' Vat Exempt Amt for Report Name  : '||p_report_name ||' trx_id : '
                   ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_EXEMPT_AMT_TBL(i)));
        END IF;

   END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.get_vat_exempt_amount.END',
                                      'ZX_JL_EXTRACT_PKG.get_vat_exempt_amount(-)');
   END IF;

END GET_VAT_EXEMPT_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_VAT_PERCEPTION_AMOUNT                                                    |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract VAT Perception Amount for the given report name      |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL               Opt|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_VAT_PERCEPTION_AMT_TBL OUT  NUMERIC3_TBL   |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


PROCEDURE GET_VAT_PERCEPTION_AMOUNT
(
P_VAT_PERC_TAX_TYPE_FROM     IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERC_TAX_TYPE_TO       IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERC_TAX               IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TRX_LINE_ID_TBL            IN            ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
X_VAT_PERCEPTION_AMT_TBL     OUT  NOCOPY   NUMERIC3_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_vat_perc_amt_tbl          NUMERIC3_TBL;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;
 k         NUMBER;
BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT.END',
                                      'ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT(+)');
   END IF;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' GET_VAT_PERCEPTION_AMOUNT : l_trx_counter : '|| l_trx_counter );
    END IF;

     EXCEPTION
        WHEN OTHERS THEN
 	IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT',
		'ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
	END IF;
     END;


       IF P_REPORT_NAME  = 'JLARTPFF' THEN
       BEGIN
       k:=0;
       FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
          IF i = 1 THEN
            k:=1;
          ELSIF (p_trx_line_id_tbl(i) <> p_trx_line_id_tbl(i-1)) THEN
               k:=k+1;
          END IF;

         IF l_vat_perc_amt_tbl.EXISTS(k) THEN
            null;
         ELSE
             l_vat_perc_amt_tbl(k) := null;
         END IF;

         IF l_vat_perc_amt_tbl(k) is NULL THEN

                    SELECT  sum(nvl(itf.tax_amt_funcl_curr,0))
                      INTO  l_vat_perc_amt_tbl(k)
                      FROM  zx_rep_trx_detail_t itf
                     WHERE  itf.request_id = p_request_id
                       AND  itf.trx_id = p_trx_id_tbl(i)
                       AND  itf.trx_line_id = p_trx_line_id_tbl(i)
                       AND  itf.tax_regime_code = nvl(p_tax_regime,itf.tax_regime_code)--Bug 5374021
                       AND  itf.tax = p_vat_perc_tax
                       AND  nvl(itf.tax_type_code, 'VAT') = 'VAT';

             X_VAT_PERCEPTION_AMT_TBL(i) := l_vat_perc_amt_tbl(k);

             IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
                ' Vat Perception Amt for Report Name  : '||p_report_name
                ||' trx_id : '||to_char(p_trx_id_tbl(i))||' Trx Line ID '
                  ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_PERCEPTION_AMT_TBL(i)));
             END IF;
         /* EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  l_vat_perc_amt_tbl(p_trx_line_id_tbl(i)) := 0;
                  X_VAT_PERCEPTION_AMT_TBL(i) := l_vat_perc_amt_tbl(p_trx_line_id_tbl(i));
                  NULL;
             WHEN OTHERS THEN
                IF ( g_level_statement>= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT',
                'ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
                END IF;
*/
         ELSE
             X_VAT_PERCEPTION_AMT_TBL(i) := 0;
         END IF;

         IF ( g_level_statement>= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
            ' Vat Perception Amt for Report Name  : '||p_report_name
            ||' trx_id : '||to_char(p_trx_id_tbl(i))||' Trx Line ID '
              ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_PERCEPTION_AMT_TBL(i)));
         END IF;

     END LOOP;
     END;
     ELSE -- Reports where trx line id is not required --

     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP



     -- Added for GSI bug#6615621 ---
           IF i = 1 THEN
               k:=1;
            ELSE
               IF (p_trx_id_tbl(i) <> p_trx_id_tbl(i-1)) THEN
                   k:=k+1;
               END IF;
           END IF;



         IF l_vat_perc_amt_tbl.EXISTS(k) THEN
            null;
         ELSE
             l_vat_perc_amt_tbl(k) := null;
         END IF;



        IF l_vat_perc_amt_tbl(k) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME =  'ZXARPVBR' THEN

           IF ( g_level_statement>= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
                 ' Vat Perception Amt for Report Name  : '||p_report_name
                 ||' trx_id : '||to_char(p_trx_id_tbl(i))||' Trx Line ID '
                 ||to_char(p_trx_id_tbl(i))||' P_VAT_PERC_TAX : '||P_VAT_PERC_TAX);
           END IF;

                    SELECT SUM(nvl(itf.tax_amt_funcl_curr,itf.tax_amt))
                      INTO l_vat_perc_amt_tbl(k)
                      FROM zx_rep_trx_detail_t itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.tax_type_code = P_VAT_PERC_TAX;

                 ELSIF P_REPORT_NAME =  'JLARPPFF' THEN

                    SELECT nvl(SUM(itf.tax_amt),0)
                      INTO l_vat_perc_amt_tbl(k)
                      FROM zx_rep_trx_detail_t itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.tax_type_code >= P_VAT_PERC_TAX_TYPE_FROM
                       AND itf.tax_type_code <= NVL(P_VAT_PERC_TAX_TYPE_TO, P_VAT_PERC_TAX_TYPE_FROM);

                 ELSIF P_REPORT_NAME in ('ZXZZTVSR') THEN

                    SELECT  sum(nvl(itf.tax_amt_funcl_curr,itf.tax_amt))
                      INTO  l_vat_perc_amt_tbl(k)
                      FROM  zx_rep_trx_detail_t itf
                     WHERE  itf.request_id = p_request_id
                       AND  itf.trx_id = p_trx_id_tbl(i)
                       AND  itf.tax_regime_code = nvl(p_tax_regime,itf.tax_regime_code)--Bug 5374021
                       AND  itf.tax = p_vat_perc_tax
                       AND  nvl(itf.tax_type_code, 'VAT') = 'VAT';

                 ELSIF P_REPORT_NAME IN ('JLARTDFF','JLARTSFF') THEN

                    IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(k) THEN
                       null;
                    ELSE
                         l_gdf_ra_cust_trx_att19_tbl(k) := null;
                    END IF;

                    IF ( l_gdf_ra_cust_trx_att19_tbl(k) <> 'IS_NULL' and
                         l_gdf_ra_cust_trx_att19_tbl(k) <> 'NOT_NULL' ) THEN

                    BEGIN

                            SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                              INTO  l_gdf_ra_cust_trx_att19_tbl(k)
                              FROM  ra_customer_trx
                             WHERE  customer_trx_id = p_trx_id_tbl(i);

                    EXCEPTION
                    WHEN OTHERS THEN
		     IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT',
		       'ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
	             END IF;
                     END;

                    END IF;

                          IF ( l_gdf_ra_cust_trx_att19_tbl(k) <> 'IS_NULL' AND
                               l_gdf_ra_cust_trx_att19_tbl(k) <> 'NOT_NULL' ) OR
                              l_gdf_ra_cust_trx_att19_tbl(k) IS NULL THEN

		     IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT',
		       'l_gdf_ra_cust_trx_att19_tbl : '||l_gdf_ra_cust_trx_att19_tbl(k) );
	             END IF;
--                    IF l_gdf_ra_cust_trx_att19_tbl(k) = 'IS_NULL' THEN

                       SELECT  sum(nvl(itf.tax_amt_funcl_curr,0))
                         INTO  l_vat_perc_amt_tbl(k)
                         FROM  zx_rep_trx_detail_t itf
                        WHERE  itf.request_id = p_request_id
                          AND  itf.trx_id = p_trx_id_tbl(i)
                          AND  itf.tax_regime_code = p_tax_regime
                          AND  itf.tax = p_vat_perc_tax
                          AND  nvl(itf.tax_type_code, 'VAT') = 'VAT';

                    ELSE
                          l_vat_perc_amt_tbl(k) := 0;

                    END IF;

                 END IF; -- IF P_REPORT_NAME ...

                        X_VAT_PERCEPTION_AMT_TBL(i) := l_vat_perc_amt_tbl(k);

           EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_vat_perc_amt_tbl(k) := 0;
                         X_VAT_PERCEPTION_AMT_TBL(i) := l_vat_perc_amt_tbl(k);
                         NULL;

                    WHEN OTHERS THEN
			IF ( g_level_statement>= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT',
				'ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
			END IF;
            END;

         ELSE -- if l_vat_perception_amt_tbl is not null

      --        X_VAT_PERCEPTION_AMT_TBL(i) := l_vat_perc_amt_tbl(k);
              X_VAT_PERCEPTION_AMT_TBL(i) := 0;

         END IF;


       -- GSI BUG ---

        /* IF l_vat_perc_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME in ('ZXARPVBR','JLARPPFF') THEN


                    SELECT nvl(SUM(itf.tax_amt),0)
                      INTO l_vat_perc_amt_tbl(p_trx_id_tbl(i))
                      FROM zx_rep_trx_detail_t itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.tax_type_code >= P_VAT_PERC_TAX_TYPE_FROM
                       AND itf.tax_type_code <= NVL(P_VAT_PERC_TAX_TYPE_TO, P_VAT_PERC_TAX_TYPE_FROM);

                 ELSIF P_REPORT_NAME in ('ZXZZTVSR') THEN

                    SELECT  sum(nvl(itf.tax_amt_funcl_curr,0))
                      INTO  l_vat_perc_amt_tbl(p_trx_id_tbl(i))
                      FROM  zx_rep_trx_detail_t itf
                     WHERE  itf.request_id = p_request_id
                       AND  itf.trx_id = p_trx_id_tbl(i)
                       AND  itf.tax_regime_code = nvl(p_tax_regime,itf.tax_regime_code)--Bug 5374021
                       AND  itf.tax = p_vat_perc_tax
                       AND  nvl(itf.tax_type_code, 'VAT') = 'VAT';

                 ELSIF P_REPORT_NAME IN ('JLARTDFF','JLARTSFF') THEN

                    IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                       null;
                    ELSE
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := null;
                    END IF;

                    IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' and
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) THEN

                    BEGIN

                            SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                              INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                              FROM  ra_customer_trx
                             WHERE  customer_trx_id = p_trx_id_tbl(i);

                    EXCEPTION
                    WHEN OTHERS THEN
		     IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT',
		       'ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
	             END IF;
                     END;

                    END IF;

                          IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' AND
                               l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) OR
                              l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) IS NULL THEN

		     IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT',
		       'l_gdf_ra_cust_trx_att19_tbl : '||l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) );
	             END IF;
--                    IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                       SELECT  sum(nvl(itf.tax_amt_funcl_curr,0))
                         INTO  l_vat_perc_amt_tbl(p_trx_id_tbl(i))
                         FROM  zx_rep_trx_detail_t itf
                        WHERE  itf.request_id = p_request_id
                          AND  itf.trx_id = p_trx_id_tbl(i)
                          AND  itf.tax_regime_code = p_tax_regime
                          AND  itf.tax = p_vat_perc_tax
                          AND  nvl(itf.tax_type_code, 'VAT') = 'VAT';

                    ELSE
                          l_vat_perc_amt_tbl(p_trx_id_tbl(i)) := 0;

                    END IF;

                 END IF; -- IF P_REPORT_NAME ...

                        X_VAT_PERCEPTION_AMT_TBL(i) := l_vat_perc_amt_tbl(p_trx_id_tbl(i));

           EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_vat_perc_amt_tbl(p_trx_id_tbl(i)) := 0;
                         X_VAT_PERCEPTION_AMT_TBL(i) := l_vat_perc_amt_tbl(p_trx_id_tbl(i));
                         NULL;

                    WHEN OTHERS THEN
			IF ( g_level_statement>= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT',
				'ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
			END IF;
            END;

         ELSE -- if l_vat_perception_amt_tbl is not null

      --        X_VAT_PERCEPTION_AMT_TBL(i) := l_vat_perc_amt_tbl(p_trx_id_tbl(i));
              X_VAT_PERCEPTION_AMT_TBL(i) := 0;

         END IF;
  */

        IF ( g_level_statement>= g_current_runtime_level ) THEN
        	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        	' Vat Perception Amt for Report Name  : '||p_report_name
               ||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_PERCEPTION_AMT_TBL(i)));
        END IF;

     END LOOP;
   END IF; -- Trx line ID check
       IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT.END',
                                      'ZX_JL_EXTRACT_PKG.GET_VAT_PERCEPTION_AMOUNT(-)');
   END IF;

END GET_VAT_PERCEPTION_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_OTHER_FED_PERC_AMOUNT                                                    |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract Other Federal Perception Amount for the given        |
 |     report name                                                                |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                 |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL               Opt|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_OTHER_FED_PERC_AMT_TBL OUT  NUMERIC7_TBL                     |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     14-May-05  Srinivasa Rao Korrapati Created                                 |
 |                                                                                |
 +================================================================================*/


PROCEDURE GET_OTHER_FED_PERC_AMOUNT
(
P_FED_PERC_TAX_TYPE_FROM     IN            VARCHAR2 DEFAULT NULL,
P_FED_PERC_TAX_TYPE_TO       IN            VARCHAR2 DEFAULT NULL,
P_VAT_PERC_TAX               IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
X_OTHER_FED_PERC_AMT_TBL     OUT  NOCOPY   NUMERIC7_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_other_fed_perc_amt_tbl          NUMERIC3_TBL;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;

BEGIN
NULL ;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_OTHER_FED_PERC_AMOUNT.BEGIN',
                                      'ZX_JL_EXTRACT_PKG.GET_OTHER_FED_PERC_AMOUNT(+)');
   END IF;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

	    IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		' GET_OTHER_FED_PERC_AMOUNT : l_trx_counter : '|| l_trx_counter );
	    END IF;

     EXCEPTION

          WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_OTHER_FED_PERC_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_OTHER_FED_PERC_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
     END;


     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

         IF l_other_fed_perc_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
             l_other_fed_perc_amt_tbl(p_trx_id_tbl(i)) := null;
         END IF;



         IF l_other_fed_perc_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME = 'JLARPPFF' THEN


                    SELECT NVL(SUM(itf.tax_amt),0)
                      INTO l_other_fed_perc_amt_tbl(p_trx_id_tbl(i))
                      FROM zx_rep_trx_detail_t itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.tax_type_code >= P_FED_PERC_TAX_TYPE_FROM
                       AND itf.tax_type_code <= NVL(P_FED_PERC_TAX_TYPE_TO, P_FED_PERC_TAX_TYPE_FROM);


                 END IF; -- IF P_REPORT_NAME ...

                        X_OTHER_FED_PERC_AMT_TBL(i) := l_other_fed_perc_amt_tbl(p_trx_id_tbl(i));


           EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_other_fed_perc_amt_tbl(p_trx_id_tbl(i)) := 0;
                         X_OTHER_FED_PERC_AMT_TBL(i) := l_other_fed_perc_amt_tbl(p_trx_id_tbl(i));
                         NULL;

                    WHEN OTHERS THEN
			IF ( g_level_statement>= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_OTHER_FED_PERC_AMOUNT',
				'ZX_JL_EXTRACT_PKG.GET_OTHER_FED_PERC_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
			END IF;
            END;

         ELSE -- if l_vat_perception_amt_tbl is not null

              X_OTHER_FED_PERC_AMT_TBL(i) := 0;
--              X_OTHER_FED_PERC_AMT_TBL(i) := l_other_fed_perc_amt_tbl(p_trx_id_tbl(i));

         END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' Other Fed perc amt for Report Name  : '||p_report_name ||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_OTHER_FED_PERC_AMT_TBL(i)));
    END IF;

     END LOOP;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_OTHER_FED_PERC_AMOUNT.END',
                                      'ZX_JL_EXTRACT_PKG.GET_OTHER_FED_PERC_AMOUNT(-)');
   END IF;

END GET_OTHER_FED_PERC_AMOUNT;

/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_OTHER_TAX_AMOUNT                                                         |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract Other Tax Amount for the given report name           |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL               Opt|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_OTHER_TAX_AMT_TBL      OUT  NUMERIC7_TBL   |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


PROCEDURE GET_OTHER_TAX_AMOUNT
(
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL      IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_OTHER_TAX_AMT_TBL          OUT  NOCOPY   NUMERIC7_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_other_tax_amt_tbl         NUMERIC7_TBL;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;

BEGIN

 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	  --Bug 5058043
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'GET_OTHER_TAX_AMOUNT(+) ');
	  END IF;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' GET_OTHER_TAX_AMOUNT : l_trx_counter : '|| l_trx_counter );
    END IF;

     EXCEPTION
          WHEN OTHERS THEN
              l_err_msg := substrb(SQLERRM,1,120);
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'ZX_JL_EXTRACT_PKG.get_other_tax_amount.'||p_report_name || '.'||l_err_msg);
	  END IF;

     END;

     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

         IF l_other_tax_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
             l_other_tax_amt_tbl(p_trx_id_tbl(i)) := null;
         END IF;

	IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
		NULL;
	ELSE
		l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := '0';
	END IF;

         IF l_other_tax_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME = 'ZXCLPPLR' THEN

                    IF P_DOCUMENT_SUB_TYPE_TBL(i) = 'DOCUMENT TYPE.JLCLPPLR' THEN

                       SELECT  SUM(nvl(itf.tax_amt_funcl_curr,nvl(itf.tax_amt,0)))
                         INTO  l_other_tax_amt_tbl(p_trx_id_tbl(i))
                         FROM  zx_rep_trx_detail_t itf
                        WHERE  itf.request_id  = P_REQUEST_ID
                          AND  itf.trx_id = p_trx_id_tbl(i)
                          AND  itf.tax_type_code <> 'VAT'
                          AND  (itf.reverse_flag IS NULL OR itf.reverse_flag <> 'Y');

                    ELSE

                        SELECT  SUM(nvl(itf.tax_amt_funcl_curr,nvl(itf.tax_amt,0)))
                          INTO  l_other_tax_amt_tbl(p_trx_id_tbl(i))
                          FROM  zx_rep_trx_detail_t itf
                         WHERE  itf.request_id = p_request_id
                           AND  itf.trx_id = p_trx_id_tbl(i)
                           AND  itf.tax_type_code <> 'VAT';

                    END IF;

                 -- ---------------------------------------------- --
                 --               For AR Reports                   --
                 -- ---------------------------------------------- --

                 ELSIF P_REPORT_NAME = 'ZXCLRSLL' THEN

   		 IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' and l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) THEN
                         BEGIN
                              SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                                INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                                FROM  ra_customer_trx_all
                               WHERE  customer_trx_id = p_trx_id_tbl(i);

                         EXCEPTION

                                  WHEN OTHERS THEN
					IF ( g_level_statement>= g_current_runtime_level ) THEN
						FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_OTHER_TAX_AMOUNT',
						'ZX_JL_EXTRACT_PKG.GET_OTHER_TAX_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
					END IF;
                                  END;

                         END IF;

                         IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                            null;
                            -- OPEN ISSUE --
			    --Bug 5438742
				SELECT  SUM(nvl(itf.tax_amt_funcl_curr,nvl(itf.tax_amt,0)))
				INTO  l_other_tax_amt_tbl(p_trx_id_tbl(i))
				FROM  zx_rep_trx_detail_t itf
				WHERE  itf.request_id  = P_REQUEST_ID
				AND  itf.trx_id = p_trx_id_tbl(i)
				AND  itf.tax_type_code <> 'VAT' ;
--				AND  (itf.reverse_flag IS NULL OR itf.reverse_flag <> 'Y');

                         ELSE

                            l_other_tax_amt_tbl(p_trx_id_tbl(i)) := 0;

                         END IF;

                 END IF;

                        X_OTHER_TAX_AMT_TBL(i) := l_other_tax_amt_tbl(p_trx_id_tbl(i));

            EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_other_tax_amt_tbl(p_trx_id_tbl(i)) := 0;
                         X_OTHER_TAX_AMT_TBL(i) := l_other_tax_amt_tbl(p_trx_id_tbl(i));
                         NULL;

                    WHEN OTHERS THEN
                            l_err_msg := substrb(SQLERRM,1,120);
			  IF (g_level_procedure >= g_current_runtime_level ) THEN
			     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
							      'ZX_JL_EXTRACT_PKG.get_other_tax_amount:'||P_REPORT_NAME||'.'||l_err_msg);
			  END IF;
            END;

         ELSE -- if l_other_tax_amt_tbl is not null

--              X_OTHER_TAX_AMT_TBL(i) := l_other_tax_amt_tbl(p_trx_id_tbl(i));
              X_OTHER_TAX_AMT_TBL(i) := 0;

         END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' Other Tax Amt for Report Name  : '||p_report_name ||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_OTHER_TAX_AMT_TBL(i)));
    END IF;

   END LOOP;

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
					      'GET_OTHER_TAX_AMOUNT(-) ');
	  END IF;

END GET_OTHER_TAX_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_NOT_REGISTERED_TAX_AMOUNT                                                |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract not registered Tax Amount for the given report name  |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL               Opt|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_OTHER_TAX_AMT_TBL      OUT  NUMERIC3_TBL   |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


  PROCEDURE GET_NOT_REGISTERED_TAX_AMOUNT
(
P_REPORT_NAME                IN            VARCHAR2,
P_VAT_ADDIT_TAX              IN            VARCHAR2 DEFAULT NULL,
P_VAT_NOT_CATEG_TAX          IN            VARCHAR2 DEFAULT NULL,
P_TAX_REGIME                 IN            VARCHAR2 DEFAULT NULL,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_TBL               IN            ZX_EXTRACT_PKG.TAX_RATE_TBL,
P_DOCUMENT_SUB_TYPE_TBL      IN            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_NOT_REG_TAX_AMT_TBL     OUT  NOCOPY   NUMERIC1_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;

 l_vat_addit_tax_amt_tbl     NUMERIC1_TBL;
 l_not_categ_tax_amt_tbl     NUMERIC1_TBL;
 l_not_tax_amt_tbl           NUMERIC1_TBL;
 l_not_reg_tax_amt_tbl       NUMERIC1_TBL;
 l_other_tax_amt_tbl         NUMERIC1_TBL;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;


BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT.BEGIN',
                                      'GET_NOT_REGISTERED_TAX_AMOUNT(+)');
   END IF;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' GET_NOT_REGISTERED_TAX_AMOUNT : l_trx_counter : '|| l_trx_counter );
    END IF;
     EXCEPTION
       WHEN OTHERS THEN
         IF ( g_level_statement>= g_current_runtime_level ) THEN
	    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
	     'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
	 END IF;
     END;

     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
         IF l_not_reg_tax_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
            l_not_reg_tax_amt_tbl(p_trx_id_tbl(i)) := NULL;
            l_vat_addit_tax_amt_tbl(p_trx_id_tbl(i)) := NULL;
            l_not_categ_tax_amt_tbl(p_trx_id_tbl(i)) := NULL;
         END IF;

         IF l_not_reg_tax_amt_tbl(p_trx_id_tbl(i)) is NULL THEN
            BEGIN
               IF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN
                  IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                     null;
                  ELSE
                     l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := null;
                  END IF;

                 IF (l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' AND
                      l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) OR
                       l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) IS NULL THEN

                      BEGIN
           IF ( g_level_statement>= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
                   'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT : att19-0 '
                   ||p_report_name ||' : '||l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)));
                END IF;

                         SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                           INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                           FROM  ra_customer_trx_all
                          WHERE  customer_trx_id = p_trx_id_tbl(i);

                       EXCEPTION
                         WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
	           FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
		   'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT : '
                   ||p_report_name ||' : '||substrb(SQLERRM,1,120) );
	        END IF;
            END;
        END IF;

             IF ( g_level_statement>= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
                   'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT : att19 '
                   ||p_report_name ||' : '||l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)));
                END IF;


        IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN
           IF l_vat_addit_tax_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

                IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
                   'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT SQL-1: '||p_tax_regime||p_vat_addit_tax);
                END IF;

              SELECT  sum(nvl(itf.tax_amt,0))
                INTO  l_vat_addit_tax_amt_tbl(p_trx_id_tbl(i))
                FROM  zx_rep_trx_detail_t itf
               WHERE  itf.request_id = p_request_id
                 AND  itf.trx_id = p_trx_id_tbl(i)
                 AND  itf.tax_regime_code = p_tax_regime
                 AND  itf.tax = p_vat_addit_tax
                 AND  nvl(itf.tax_type_code, 'VAT') = 'VAT';


                IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
                   'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT SQL-1: '||to_char(l_vat_addit_tax_amt_tbl(p_trx_id_tbl(i))));
                END IF;

            END IF;

           -- IF l_not_categ_tax_amt_tbl(p_trx_id_tbl(i)) is NULL THEN
            BEGIN
               SELECT  sum(nvl(itf.tax_amt,0))
                 INTO  l_not_categ_tax_amt_tbl(p_trx_id_tbl(i))
                 FROM  zx_rep_trx_detail_t itf
                WHERE  itf.request_id = p_request_id
                  AND  itf.trx_id = p_trx_id_tbl(i)
                  AND  itf.tax_regime_code = p_tax_regime
                  AND  itf.tax = p_vat_not_categ_tax
                  AND  nvl(itf.tax_type_code, 'VAT') = 'VAT';
       EXCEPTION
        WHEN OTHERS THEN
          IF ( g_level_statement>= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
                'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT : p_vat_not_categ_tax '
                 ||' : '||substrb(SQLERRM,1,120) );
          END IF;

        END;
            --END IF;

            IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
                   'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT SQL-1: '||to_char(l_not_categ_tax_amt_tbl(p_trx_id_tbl(i))));
                END IF;


            l_not_reg_tax_amt_tbl(p_trx_id_tbl(i)) := nvl(l_vat_addit_tax_amt_tbl(p_trx_id_tbl(i)),0) +
                                                      nvl(l_not_categ_tax_amt_tbl(p_trx_id_tbl(i)),0);
         ELSE
           l_not_reg_tax_amt_tbl(p_trx_id_tbl(i)) := 0;
         END IF;
       END IF;

             X_NOT_REG_TAX_AMT_TBL(i) := l_not_reg_tax_amt_tbl(p_trx_id_tbl(i));
             IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
                   'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT : '||p_report_name ||' : '
                        ||to_char( X_NOT_REG_TAX_AMT_TBL(i)));
             END IF;

       EXCEPTION
        WHEN NO_DATA_FOUND THEN
              l_other_tax_amt_tbl(p_trx_id_tbl(i)) := 0;
              X_NOT_REG_TAX_AMT_TBL(i) := l_not_tax_amt_tbl(p_trx_id_tbl(i));
              NULL;

        WHEN OTHERS THEN
	  IF ( g_level_statement>= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT',
        	'ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT : '||p_report_name
                 ||' : '||substrb(SQLERRM,1,120) );
	  END IF;
       END;

         ELSE -- if l_not_reg_tax_amt_tbl is not null

--              X_NOT_REG_TAX_AMT_TBL(i) := l_not_reg_tax_amt_tbl(p_trx_id_tbl(i));
              X_NOT_REG_TAX_AMT_TBL(i) := 0;

         END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' Non Registered Tax Amt. for Report Name  : '||p_report_name ||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_NOT_REG_TAX_AMT_TBL(i)));
    END IF;

   END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_NOT_REGISTERED_TAX_AMOUNT.END',
                                      'GET_NOT_REGISTERED_TAX_AMOUNT(-)');
   END IF;

END GET_NOT_REGISTERED_TAX_AMOUNT;



/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_PROVINCIAL_PERC_AMOUNT                                                   |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract Provincial Perception Amount for a given report name |
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_PROV_TAX_TYPE_FROM        IN   VARCHAR2 Opt                  |
 |                 P_PROV_TAX_TYPE_TO          IN   VARCHAR2 Opt
 |                 P_PROV_TAX_REGIME           IN   VARCHAR2 Opt
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_PROVINCIAL_PERC_AMT_TBLOUT  NUMERIC4_TBL   |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


  PROCEDURE GET_PROVINCIAL_PERC_AMOUNT
(
P_PROV_TAX_TYPE_FROM         IN            VARCHAR2 DEFAULT NULL,
P_PROV_TAX_TYPE_TO           IN            VARCHAR2 DEFAULT NULL,
P_PROV_TAX_REGIME            IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_ID_TBL            IN            ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
X_PROVINCIAL_PERC_AMT_TBL    OUT  NOCOPY   NUMERIC4_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_count                NUMBER;
 l_provincial_perc_amt_tbl   NUMERIC4_TBL;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT',
                                       'get_provincial_perc_amount(+) ');
          END IF;


     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

          l_count := p_trx_id_tbl.count;


       IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT',
                                       'Count : '||to_char(l_count));
          END IF;


     EXCEPTION

          WHEN OTHERS THEN
              l_err_msg := substrb(SQLERRM,1,120);
        IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT',
                                       'get_provincial_perc_amount : EXCEPTION '||l_err_msg);
          END IF;

     END;

       l_count := p_trx_id_tbl.count;
     --FOR i in 11..nvl(p_trx_id_tbl.last,0) LOOP
     FOR i in 1..l_count LOOP
        IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT',
                                       'get_provincial_perc_amount : For Loop ');
          END IF;

         IF l_provincial_perc_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
              l_provincial_perc_amt_tbl(p_trx_id_tbl(i)) := null;
         END IF;

         IF l_provincial_perc_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME = 'JLARPPFF' THEN


                    SELECT NVL(SUM(itf.tax_amt),0)
                      INTO l_provincial_perc_amt_tbl(p_trx_id_tbl(i))
                      FROM zx_rep_trx_detail_t itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.tax_type_code >= P_PROV_TAX_TYPE_FROM
                       AND itf.tax_type_code <= P_PROV_TAX_TYPE_TO;

                 -- ---------------------------------------------- --
                 --               For AR Reports                   --
                 -- ---------------------------------------------- --

                 ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF')  THEN

                    IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' and
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) THEN

                       BEGIN
                            SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                              INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                              FROM  ra_customer_trx
                             WHERE  customer_trx_id = p_trx_id_tbl(i);

                       EXCEPTION
                         WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
		    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT',
		    'ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
                END;

                END IF;

                    IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                       SELECT  sum(nvl(itf.tax_amt,0))
                         INTO  l_provincial_perc_amt_tbl(p_trx_id_tbl(i))
                         FROM  zx_rep_trx_detail_t itf
                        WHERE  itf.request_id = p_request_id
                          AND  itf.trx_id = p_trx_id_tbl(i)
                          AND  itf.tax_regime_code = p_prov_tax_regime
                          AND  nvl(itf.tax_type_code,'VAT') = 'VAT';

                    ELSE

                         l_provincial_perc_amt_tbl(p_trx_id_tbl(i)) := 0;

                    END IF;

                 ELSIF P_REPORT_NAME = 'JLARTOFF' THEN

                  IF (g_level_procedure >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT',
                             'JLARTOFF:get_provincial_perc_amount ');
                  END IF;

                       SELECT  sum(nvl(itf.tax_amt,0))
                         INTO  l_provincial_perc_amt_tbl(p_trx_id_tbl(i))
                         FROM  zx_rep_trx_detail_t itf,
                               jl_zz_ar_tx_categ categ
                        WHERE  itf.request_id = p_request_id
                          AND  itf.trx_id = p_trx_id_tbl(i)
                        --  AND  itf.tax_regime_code = p_prov_tax_regime
                          AND  nvl(itf.tax_type_code,'VAT') = 'VAT'
                          AND  itf.tax_rate_id = p_tax_rate_id_tbl(i)
                          AND categ.tax_category = itf.tax
                          AND categ.tax_regime = p_prov_tax_regime
                          AND categ.org_id = itf.internal_organization_id;

                  IF (g_level_procedure >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTOFF: SQL Call in get_provincial_perc_amount '
                                 ||to_char(l_provincial_perc_amt_tbl(p_trx_id_tbl(i))));
                  END IF;

                 END IF;

                        X_PROVINCIAL_PERC_AMT_TBL(i) := l_provincial_perc_amt_tbl(p_trx_id_tbl(i));

            EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_provincial_perc_amt_tbl(p_trx_id_tbl(i)) := 0;
                         X_PROVINCIAL_PERC_AMT_TBL(i) := l_provincial_perc_amt_tbl(p_trx_id_tbl(i));
                         NULL;

                    WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
		    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT',
		    'ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
            END;

         ELSE -- if l_provincial_perc_amt_tbl is not null

--              X_PROVINCIAL_PERC_AMT_TBL(i) := l_provincial_perc_amt_tbl(p_trx_id_tbl(i));
              X_PROVINCIAL_PERC_AMT_TBL(i) := 0;

         END IF;
         IF ( g_level_statement>= g_current_runtime_level ) THEN
        	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        	' PROVINCIAL_PERC_AMOUNT for Report Name  : '||p_report_name ||' trx_id : '
               ||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_PROVINCIAL_PERC_AMT_TBL(i)));
         END IF;

   END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_PROVINCIAL_PERC_AMOUNT.END',
                                      'GET_PROVINCIAL_PERC_AMOUNT(-)');
      END IF;

END GET_PROVINCIAL_PERC_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_MUNICIPAL_PERC_AMOUNT                                                    |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract Municipal Perception Amount for the given report name|
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_MUN_TAX_TYPE_FROM         IN   VARCHAR2 Opt                  |
 |                 P_MUN_TAX_TYPE_TO           IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_MUNICIPAL_PERC_AMT_TBL OUT NUMERIC5_TBL    |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


  PROCEDURE GET_MUNICIPAL_PERC_AMOUNT
(
P_MUN_TAX_TYPE_FROM          IN            VARCHAR2 DEFAULT NULL,
P_MUN_TAX_TYPE_TO            IN            VARCHAR2 DEFAULT NULL,
P_MUN_TAX_REGIME             IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_RATE_ID_TBL            IN            ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
X_MUNICIPAL_PERC_AMT_TBL     OUT  NOCOPY   NUMERIC5_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_municipal_perc_amt_tbl    NUMERIC5_TBL;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT.BEGIN',
                                      'GET_MUNICIPAL_PERC_AMOUNT(+)');
   END IF;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' GET_MUNICIPAL_PERC_AMOUNT : l_trx_counter : '|| l_trx_counter );
    END IF;

     EXCEPTION

          WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;

     END;


     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

         IF l_municipal_perc_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
             l_municipal_perc_amt_tbl(p_trx_id_tbl(i)) := null;
         END IF;

         IF l_municipal_perc_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME = 'JLARPPFF' THEN

                    SELECT nvl(SUM(itf.tax_amt),0)
                      INTO l_municipal_perc_amt_tbl(p_trx_id_tbl(i))
                      FROM zx_rep_trx_detail_t itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.tax_type_code >= P_MUN_TAX_TYPE_FROM
                       AND itf.tax_type_code <= P_MUN_TAX_TYPE_TO;

                 ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN

                    IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                       null;
                    ELSE
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := null;
                    END IF;

                    IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' and
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) THEN

                       BEGIN
                            SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                              INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                              FROM  ra_customer_trx
                             WHERE  customer_trx_id = p_trx_id_tbl(i);

                       EXCEPTION
                                WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
                       END;

                    END IF;

                    IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                       SELECT  sum(nvl(itf.tax_amt,0))
                         INTO  l_municipal_perc_amt_tbl(p_trx_id_tbl(i))
                         FROM  zx_rep_trx_detail_t itf
                        WHERE  itf.request_id = p_request_id
                          AND  itf.trx_id = p_trx_id_tbl(i)
                          AND  itf.tax_regime_code = p_mun_tax_regime
                          AND  nvl(itf.tax_type_code,'VAT') = 'VAT';

                    ELSE

                         l_municipal_perc_amt_tbl(p_trx_id_tbl(i)) := 0;

                    END IF;

                 ELSIF P_REPORT_NAME = 'JLARTOFF' THEN

        IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT',
                                       'JLARTOFF:get_muncipal_perc_amount ');
          END IF;
                l_municipal_perc_amt_tbl(p_trx_id_tbl(i)):= NULL;

                       SELECT  sum(nvl(itf.tax_amt,0))
                         INTO  l_municipal_perc_amt_tbl(p_trx_id_tbl(i))
                         FROM  zx_rep_trx_detail_t itf,
                               jl_zz_ar_tx_categ categ
                        WHERE  itf.request_id = p_request_id
                          AND  itf.trx_id = p_trx_id_tbl(i)
                        --  AND  itf.tax_regime_code = p_mun_tax_regime
                          AND  nvl(itf.tax_type_code,'VAT') = 'VAT'
                          AND  itf.tax_rate_id = p_tax_rate_id_tbl(i)
                          AND categ.tax_category = itf.tax
                          AND categ.tax_regime = p_mun_tax_regime
                          AND categ.org_id = itf.internal_organization_id;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.POPULATE_JL_AR',
                                       'JLARTOFF: SQL Call in get_muncipal_perc_amount '
                                 ||to_char(l_municipal_perc_amt_tbl(p_trx_id_tbl(i))));
          END IF;


                 END IF;


/*                       SELECT  sum(nvl(itf.tax_amt,0))
                         INTO  l_municipal_perc_amt_tbl(p_trx_id_tbl(i))
                         FROM  zx_rep_trx_detail_t itf
                        WHERE  itf.request_id = p_request_id
                          AND  itf.trx_id = p_trx_id_tbl(i)
                          AND  itf.tax_regime_code = p_mun_tax_regime
                          AND  nvl(itf.tax_type_code,'VAT') = 'VAT'
                          AND  itf.tax_rate_id = p_tax_rate_id_tbl(i);

                 END IF; -- IF P_REPORT_NAME = ..*/

                        X_MUNICIPAL_PERC_AMT_TBL(i) := NVL(l_municipal_perc_amt_tbl(p_trx_id_tbl(i)),0);

                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         l_municipal_perc_amt_tbl(p_trx_id_tbl(i)) := 0;
                         X_MUNICIPAL_PERC_AMT_TBL(i) := l_municipal_perc_amt_tbl(p_trx_id_tbl(i));
                         NULL;

                    WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
		       FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT',
		      'ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
            END;

         ELSE -- if l_municipal_perc_amt_tbl is not null

              X_MUNICIPAL_PERC_AMT_TBL(i) := 0;
--              X_MUNICIPAL_PERC_AMT_TBL(i) := l_municipal_perc_amt_tbl(p_trx_id_tbl(i));

         END IF;

         IF ( g_level_statement>= g_current_runtime_level ) THEN
        	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        	' X_MUNICIPAL_PERC_AMT_TBL for Report Name  : '||p_report_name
                ||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_MUNICIPAL_PERC_AMT_TBL(i)));
         END IF;

      END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_MUNICIPAL_PERC_AMOUNT.END',
                                      'GET_MUNICIPAL_PERC_AMOUNT(-)');
       END IF;

END GET_MUNICIPAL_PERC_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_EXCISE_TAX_AMOUNT                                                        |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract Municipal Perception Amount for the given report name|
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_VAT_TAX_TYPE              IN   VARCHAR2 Opt                  |
 |                 P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_TRX_ID_TBL                IN   ZX_EXTRACT_PKG.TRX_ID_TBL  Req|
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL               Opt|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_EXCISE_TAX_AMT_TBL     OUT NUMERIC5_TBL    |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/


PROCEDURE GET_EXCISE_TAX_AMOUNT
(
P_EXC_TAX_TYPE_FROM          IN            VARCHAR2 DEFAULT NULL,
P_EXC_TAX_TYPE_TO            IN            VARCHAR2 DEFAULT NULL,
P_EXC_TAX_REGIME             IN            VARCHAR2 DEFAULT NULL,
P_REPORT_NAME                IN            VARCHAR2,
p_REQUEST_ID                 IN            NUMBER,
P_TRX_ID_TBL                 IN            ZX_EXTRACT_PKG.TRX_ID_TBL,
X_EXCISE_AMT_TBL             OUT NOCOPY    NUMERIC6_TBL
) IS

 l_err_msg                   VARCHAR2(120);
 l_trx_counter               NUMBER;
 l_excise_amt_tbl            NUMERIC6_TBL;
 l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT.BEGIN',
                                      'GET_EXCISE_TAX_AMOUNT(+)');
   END IF;

     BEGIN

          SELECT count(distinct trx_id)
            INTO l_trx_counter
            FROM zx_rep_trx_detail_t
           WHERE request_id = p_request_id;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' GET_EXCISE_TAX_AMOUNT : l_trx_counter : '|| l_trx_counter );
    END IF;

     EXCEPTION

          WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;

     END;

     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

         IF l_excise_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
             l_excise_amt_tbl(p_trx_id_tbl(i)) := null;
         END IF;

         IF l_excise_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

            BEGIN

                 IF P_REPORT_NAME = 'JLARPPFF' THEN

                    SELECT nvl(SUM(itf.tax_amt),0)
                      INTO l_excise_amt_tbl(p_trx_id_tbl(i))
                      FROM zx_rep_trx_detail_t itf
                     WHERE itf.request_id = p_request_id
                       AND itf.trx_id = p_trx_id_tbl(i)
                       AND itf.tax_type_code >= P_EXC_TAX_TYPE_FROM
                       AND itf.tax_type_code <= P_EXC_TAX_TYPE_TO;

                 ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN

                    IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                       null;
                    ELSE
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := null;
                    END IF;

                    --IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' and
                     --    l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) THEN

                    IF  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) IS NULL THEN
                       BEGIN
                            SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                              INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                              FROM  ra_customer_trx
                             WHERE  customer_trx_id = p_trx_id_tbl(i);

 		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT',
			'l_gdf_ra_cust_trx_att19_tbl : '||l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) );
		END IF;

                       EXCEPTION
                                WHEN OTHERS THEN

 		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
                       END;

                    END IF;

                    IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                       SELECT  sum(nvl(itf.tax_amt,0))
                         INTO  l_excise_amt_tbl(p_trx_id_tbl(i))
                         FROM  zx_rep_trx_detail_t itf
                        WHERE  itf.request_id = p_request_id
                          AND  itf.trx_id = p_trx_id_tbl(i)
                          --AND  itf.tax_regime_code = p_exc_tax_regime
                          AND  itf.tax = p_exc_tax_regime
                          AND  nvl(itf.tax_type_code,'VAT') = 'VAT';

                    ELSE

                         l_excise_amt_tbl(p_trx_id_tbl(i)) := 0;

                    END IF;


                 END IF;

                        X_EXCISE_AMT_TBL(i) := l_excise_amt_tbl(p_trx_id_tbl(i));

            EXCEPTION

                    WHEN NO_DATA_FOUND THEN

                         l_excise_amt_tbl(p_trx_id_tbl(i)) := 0;
                         X_EXCISE_AMT_TBL(i) := l_excise_amt_tbl(p_trx_id_tbl(i));
                         NULL;

                    WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT',
			'ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT : '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
            END;

         ELSE -- if l_excise_tax_amt_tbl is not null

              X_EXCISE_AMT_TBL(i) := 0;
--              X_EXCISE_AMT_TBL(i) := l_excise_amt_tbl(p_trx_id_tbl(i));

         END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' X_EXCISE_AMT_TBL for Report Name  : '||p_report_name ||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_EXCISE_AMT_TBL(i)));
    END IF;

   END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_EXCISE_TAX_AMOUNT.END',
                                      'GET_EXCISE_TAX_AMOUNT(-)');
   END IF;

END GET_EXCISE_TAX_AMOUNT;


/*================================================================================+
 | PROCEDURE                                                                      |
 |   GET_COUNTED_SUM_DOC                                                          |
 |   Type       : Private                                                         |
 |   Pre-req    : None                                                            |
 |   Function   :                                                                 |
 |    This procedure extract Municipal Perception Amount for the given report name|
 |                                                                                |
 |   Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                                    |
 |                                                                                |
 |   Parameters :                                                                 |
 |   IN         :  P_REPORT_NAME               IN   VARCHAR2 Req                  |
 |                 P_REQUEST_ID                IN   NUMBER   Req                  |
 |                 P_DOCUMENT_SUB_TYPE_TBL     IN   ZX_EXTRACT_PKG.DOCUMENT_      |
 |                                                  SUB_TYPE_TBL               Opt|
 |                                                                                |
 |    OUT                                                                         |
 |                 X_CL_NUM_OF_DOC_TBL     OUT NUMERIC5_TBL    |
 |                                                                                |
 |                                                                                |
 |   MODIFICATION HISTORY                                                         |
 |     29-Oct-04  Hidetaka Kojima   created                                       |
 |                                                                                |
 +================================================================================*/

PROCEDURE GET_COUNTED_SUM_DOC
(
P_REPORT_NAME             IN          VARCHAR2,
P_REQUEST_ID              IN          NUMBER,
P_DOCUMENT_SUB_TYPE_TBL   IN          ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
X_CL_NUM_OF_DOC_TBL       OUT NOCOPY  NUMERIC3_TBL,
X_CL_TOTAL_EXEMPT_TBL     OUT NOCOPY  NUMERIC4_TBL,
X_CL_TOTAL_EFFECTIVE_TBL  OUT NOCOPY  NUMERIC5_TBL,
X_CL_TOTAL_VAT_TAX_TBL    OUT NOCOPY  NUMERIC6_TBL,
X_CL_TOTAL_OTHER_TAX_TBL  OUT NOCOPY  NUMERIC11_TBL

)IS

BEGIN
 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	  --Bug 5058043
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_COUNTED_SUM_DOC',
					      'GET_COUNTED_SUM_DOC(+)');
	  END IF;

     IF P_REPORT_NAME = 'ZXCLPPLR' then

        FOR i in 1..nvl(p_document_sub_type_tbl.last,0) LOOP

            begin
		SELECT  COUNT(DISTINCT DET.TRX_NUMBER),
	               /* SUM(DECODE(DET.TAX_RATE,0,
						coalesce(DET.TAXABLE_AMT_FUNCL_CURR,DET.TAXABLE_AMT,0),
						0)),
	                SUM(DECODE(DET.TAX_RATE,0,
						0,
						coalesce(DET.TAXABLE_AMT_FUNCL_CURR,DET.TAXABLE_AMT,0))),*/
	                SUM(DECODE(DET.TAX_TYPE_CODE,'VAT',
						     coalesce(DET.TAX_AMT_FUNCL_CURR,DET.TAX_AMT,0),
						     0)),
	                SUM(DECODE(DET.TAX_TYPE_CODE,'VAT',
						       0,
						       coalesce(DET.TAX_AMT_FUNCL_CURR,DET.TAX_AMT,0)))
                  INTO  X_CL_NUM_OF_DOC_TBL(i),
--                        X_CL_TOTAL_EXEMPT_TBL(i),
--                        X_CL_TOTAL_EFFECTIVE_TBL(i),
                        X_CL_TOTAL_VAT_TAX_TBL(i),
                        X_CL_TOTAL_OTHER_TAX_TBL(i)
                 FROM   ZX_REP_TRX_DETAIL_T DET
                WHERE   DET.REQUEST_ID = P_REQUEST_ID
                  AND   DET.DOCUMENT_SUB_TYPE = P_DOCUMENT_SUB_TYPE_TBL(i)
             GROUP BY   DET.DOCUMENT_SUB_TYPE;
	     EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		X_CL_NUM_OF_DOC_TBL(i) := null;
		X_CL_TOTAL_VAT_TAX_TBL(i) := null;
		X_CL_TOTAL_OTHER_TAX_TBL(i) := NULL ;
	     END ;

--Added for the Bug 5413860
	BEGIN
               SELECT   SUM(DECODE(DET.TAX_RATE,0,
						coalesce(DET.TAXABLE_AMT_FUNCL_CURR,DET.TAXABLE_AMT,0),
						0)),
	                SUM(DECODE(DET.TAX_RATE,0,
						0,
						coalesce(DET.TAXABLE_AMT_FUNCL_CURR,DET.TAXABLE_AMT,0)))
                  INTO
                        X_CL_TOTAL_EXEMPT_TBL(i),
                        X_CL_TOTAL_EFFECTIVE_TBL(i)
                 FROM   ZX_REP_TRX_DETAIL_T DET
                WHERE   DET.REQUEST_ID = P_REQUEST_ID
                  AND   DET.DOCUMENT_SUB_TYPE = P_DOCUMENT_SUB_TYPE_TBL(i)
		  AND det.ROWID = ( SELECT min(det1.rowid) FROM zx_rep_trx_detail_t det1
					WHERE det1.trx_id = det.trx_id
					AND det1.request_id = P_REQUEST_ID
					AND nvl(det1.trx_line_id,1) = nvl(det.trx_line_id,1) )--check if trx_line_id should be populated at TRANSACTION Level
             GROUP BY   DET.DOCUMENT_SUB_TYPE;
--		X_CL_TOTAL_EXEMPT_TBL(i) := null;
--		X_CL_TOTAL_EFFECTIVE_TBL(i) := null;

	  IF (g_level_statement >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_COUNTED_SUM_DOC',
	      'i : '||i||'X_CL_TOTAL_EXEMPT_TBL : '||X_CL_TOTAL_EXEMPT_TBL(i)||'X_CL_TOTAL_EFFECTIVE_TBL : '||X_CL_TOTAL_EFFECTIVE_TBL(i) );
	  END IF;

	     EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		X_CL_TOTAL_EXEMPT_TBL(i) := null;
		X_CL_TOTAL_EFFECTIVE_TBL(i) := null;

	     END ;

        END LOOP;

      END IF;

--Bug 5438742
	IF P_REPORT_NAME = 'ZXCLRSLL' then

	FOR i in 1..nvl(p_document_sub_type_tbl.last,0) LOOP

		begin
			SELECT  COUNT(DISTINCT DET.TRX_NUMBER),
			SUM(DECODE(DET.TAX_TYPE_CODE,'VAT',
				coalesce(DET.TAX_AMT_FUNCL_CURR,DET.TAX_AMT,0),
				0)),
			SUM(DECODE(DET.TAX_TYPE_CODE,'VAT',
			0,
			coalesce(DET.TAX_AMT_FUNCL_CURR,DET.TAX_AMT,0)))
			INTO  X_CL_NUM_OF_DOC_TBL(i),
			X_CL_TOTAL_VAT_TAX_TBL(i),
			X_CL_TOTAL_OTHER_TAX_TBL(i)
			FROM   ZX_REP_TRX_DETAIL_T DET
			WHERE   DET.REQUEST_ID = P_REQUEST_ID
			AND   DET.doc_seq_name = P_DOCUMENT_SUB_TYPE_TBL(i)
			GROUP BY   DET.DOCUMENT_SUB_TYPE;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			X_CL_NUM_OF_DOC_TBL(i) := null;
			X_CL_TOTAL_VAT_TAX_TBL(i) := null;
			X_CL_TOTAL_OTHER_TAX_TBL(i) := NULL ;
		END ;

		BEGIN
			SELECT
				SUM(DECODE(DET.TAX_RATE,0,
				0,
				coalesce(DET.TAXABLE_AMT_FUNCL_CURR,DET.TAXABLE_AMT,0)))
			INTO
				X_CL_TOTAL_EFFECTIVE_TBL(i)
			FROM   ZX_REP_TRX_DETAIL_T DET
			WHERE   DET.REQUEST_ID = P_REQUEST_ID
				AND   DET.DOC_SEQ_NAME = P_DOCUMENT_SUB_TYPE_TBL(i)
				AND det.ROWID = ( SELECT min(det1.rowid) FROM zx_rep_trx_detail_t det1
				WHERE det1.trx_id = det.trx_id
				AND det1.request_id = P_REQUEST_ID
				AND nvl(det1.trx_line_id,1) = nvl(det.trx_line_id,1) )--check if trx_line_id should be populated at TRANSACTION Level
			GROUP BY   DET.DOCUMENT_SUB_TYPE;

		IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_COUNTED_SUM_DOC',
		'i : '||i||'X_CL_TOTAL_EXEMPT_TBL : '||X_CL_TOTAL_EXEMPT_TBL(i)||'X_CL_TOTAL_EFFECTIVE_TBL : '||X_CL_TOTAL_EFFECTIVE_TBL(i) );
		END IF;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
		X_CL_TOTAL_EXEMPT_TBL(i) := null;
		X_CL_TOTAL_EFFECTIVE_TBL(i) := null;

		END ;

	END LOOP;

	END IF;
	  --Bug 5058043
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_COUNTED_SUM_DOC',
					      'GET_COUNTED_SUM_DOC(-)');
	  END IF;

END GET_COUNTED_SUM_DOC;


/*=====================================================================================+
 | PROCEDURE                                                                           |
 |   GET_LOOKUP_INFO                                                                   |
 |   Type       : Private                                                              |
 |   Pre-req    : None                                                                 |
 |   Function   :                                                                      |
 |    This procedure fetched Lookup Code and Meaning from FND_LOOKUPS table            |
 |    using P_DOCUMENT_SUB_TYPE_TBL and returns fetched values.                        |
 |                                                                                     |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE                                              |
 |                                                                                     |
 |   Parameters :                                                                      |
 |   IN         :  P_DOCUMENT_SUB_TYPE_TBL     IN  ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL|
 |                 X_JLCL_AP_DOC_TYPE_MEANING  OUT VARCHAR2                            |
 |                 X_ORDER_BY_DOC_TYPE         OUT VARCHAR2                            |
 |                                                                                     |
 |   MODIFICATION HISTORY                                                              |
 |     07-Nov-03  Hidetaka Kojima   created                                            |
 |                                                                                     |
 |                                                                                     |
 +=====================================================================================*/

 PROCEDURE GET_LOOKUP_INFO
 (
 P_DOCUMENT_SUB_TYPE_TBL              IN          ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL,
 X_JLCL_AP_DOC_TYPE_MEANING_TBL       OUT NOCOPY  DOCUMENT_SUB_TYPE_MNG_TBL,
 X_ORDER_BY_DOC_TYPE_TBL              OUT NOCOPY  ATTRIBUTE14_TBL
 )

 IS

 BEGIN

 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  --Bug 5058043
  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_LOOKUP_INFO',
				      'GET_LOOKUP_INFO(+)');
  END IF;

   FOR i in 1..nvl(p_document_sub_type_tbl.last,0) LOOP

	IF (g_level_statement >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_LOOKUP_INFO',
			      'i : '||i||'P_DOCUMENT_SUB_TYPE_TBL(i) : '||P_DOCUMENT_SUB_TYPE_TBL(i));
	END IF;

       BEGIN

            SELECT
                  fl.meaning,
                  DECODE(fl.lookup_code, 'JL_CL_DOMESTIC_INVOICE','1',
                                         'JL_CL_FOREIGN_INVOICE','2',
                                         'JL_CL_DEBIT_MEMO','3',
                                         'JL_CL_CREDIT_MEMO','4',
                                                             '5')
             INTO
                  x_jlcl_ap_doc_type_meaning_tbl(i),
                  x_order_by_doc_type_tbl(i)
             FROM
                  fnd_lookups fl
            WHERE
                  fl.lookup_type = 'JLCL_AP_DOCUMENT_TYPE'
              AND
                  fl.lookup_code = substr(P_DOCUMENT_SUB_TYPE_TBL(i),15); --Bug 5413860

       EXCEPTION

            WHEN NO_DATA_FOUND THEN

                 x_jlcl_ap_doc_type_meaning_tbl(i) := Null;
                 x_order_by_doc_type_tbl(i) := Null;
                 null;

            WHEN OTHERS THEN

                 l_err_msg := substrb(SQLERRM,1,120);
			  --Bug 5058043
		  IF (g_level_procedure >= g_current_runtime_level ) THEN
		     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_LOOKUP_INFO',
						      'EXCEPTION raised in ' ||'GET_LOOKUP_INFO: ' ||SQLCODE ||':'||l_err_msg);
		  END IF;

       END;

   END LOOP;
		   --Bug 5058043
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_LOOKUP_INFO',
					      'GET_LOOKUP_INFO(-)');
	  END IF;

 END GET_LOOKUP_INFO;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   GET_TAX_AUTHORITY_CODE                                                  |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This function returns the Tax Authority Code                           |
 |    from jl_zz_ar_tx_categ table to  meet the requirement in the flat file |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                              |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  p_vat_tax IN                                              |
 |                              ZX_REP_TRX_DETAIL_T.TAX%TYPE     Required  |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


FUNCTION GET_TAX_AUTHORITY_CODE
(
P_VAT_TAX            IN  ZX_REP_TRX_DETAIL_T.TAX%TYPE,
P_ORG_ID             IN  NUMBER
)
return ZX_REP_TRX_JX_EXT_T.ATTRIBUTE10%TYPE IS

  l_tax_authority_code        ZX_REP_TRX_JX_EXT_T.ATTRIBUTE10%TYPE;
  l_err_msg                   VARCHAR2(120);

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAX_AUTHORITY_CODE.BEGIN',
                                      'GET_TAX_AUTHORITY_CODE(+)');
   END IF;

      SELECT  tax_authority_code
        INTO  l_tax_authority_code
        FROM  jl_zz_ar_tx_categ
       WHERE  tax_category = p_vat_tax
         AND  org_id = p_org_id;


	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAX_AUTHORITY_CODE',
					      'l_tax_authority_code : '||l_tax_authority_code);
	END IF;

       IF (g_level_procedure >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAX_AUTHORITY_CODE.END',
                                      'GET_TAX_AUTHORITY_CODE(-)');
   END IF;

      RETURN l_tax_authority_code;

 EXCEPTION

     WHEN NO_DATA_FOUND THEN

     RETURN  null;

     WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAX_AUTHORITY_CODE',
			'ZX_JL_EXTRACT_PKG.GET_TAX_AUTHORITY_CODE : '||substrb(SQLERRM,1,120) );
		END IF;

END get_tax_authority_code;


/*=================================================================================+
 | PROCEDURE                                                                        |
 |   GET_DGI_CODE                                                                  |
 |   Type       : Private                                                          |
 |   Pre-req    : None                                                             |
 |   Function   :                                                                  |
 |    This function returns the DGI Code                                           |
 |    from jl_ar_ap_trx_dgi table to meet the requirement in the flat file         |
 |                                                                                 |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                                    |
 |                                                                                 |
 |   Parameters :                                                                  |
 |   IN         :  P_TRX_NUMBER_TBL    IN ZX_EXTRACT_PKG.TRX_NUMBER_TBL   Required |                       |
 |                 P_TRX_TYPE_ID_TBL   IN ZX_EXTRACT_PKG.TRX_TYPE_ID_TBL  Required |
 |                                                                                 |
 |   MODIFICATION HISTORY                                                          |
 |     07-Nov-03  Hidetaka Kojima   created                                        |
 |                                                                                 |
 |                                                                                 |
 +=================================================================================*/

 PROCEDURE GET_DGI_CODE
 (
  P_TRX_NUMBER_TBL        IN         ZX_EXTRACT_PKG.TRX_NUMBER_TBL,
  P_TRX_CATEGORY_TBL      IN         ZX_EXTRACT_PKG.TRX_TYPE_ID_TBL,
  P_ORG_ID_TBL            IN ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
  X_DGI_CODE_TBL          OUT NOCOPY ATTRIBUTE11_TBL
 )
IS

     l_err_msg         VARCHAR2(120);

BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_CODE.BEGIN',
                                      'GET_DGI_CODE(+)');
   END IF;

 FOR i in 1..p_trx_number_tbl.last LOOP

     BEGIN

          SELECT  dgi_code
            INTO  x_dgi_code_tbl(i)
            FROM  jl_ar_ap_trx_dgi_codes dgi,
                  ra_cust_trx_types_all rctt
           WHERE  trx_letter = substr(p_trx_number_tbl(i),1,1)
             AND  rctt.cust_trx_type_id = P_TRX_CATEGORY_TBL(i)
             AND  rctt.org_id = p_org_id_tbl(i)
             AND  trx_category = rctt.type;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' GET_DGI_CODE : i : ');
    END IF;

     EXCEPTION

           WHEN NO_DATA_FOUND THEN
                x_dgi_code_tbl(i) := Null;
     IF ( g_level_statement>= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        ' GET_DGI_CODE : i : ');
    END IF;



           WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_CODE',
			'ZX_JL_EXTRACT_PKG.GET_DGI_CODE : '||substrb(SQLERRM,1,120) );
		END IF;
     END;

 END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_CODE.END',
                                      'GET_DGI_CODE(-)');
   END IF;

END get_dgi_code;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   GET_CUSTOMER_CONDITION_CODE                                             |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This function returns the customer's tax condition code                |
 |    from jl_zz_ar_tx_val table to meet the requirement in the flat file    |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                              |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  p_use_site_prof IN VARCHAR2  Required                     |
 |                 p_tax_category_id IN NUMBER Required                      |
 |                 p_contributor_class IN VHARCHAR2 Required                 |
 |                 p_address_id IN  NUMBER       Required                    |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE GET_CUSTOMER_CONDITION_CODE
(
P_VAT_PERCEP_TAX              IN         VARCHAR2,
P_TRX_ID_TBL                  IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_INTERNAL_ORG_ID_TBL	      IN         ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
P_REQUEST_ID                  IN         NUMBER,
X_CUST_CONDITION_CODE_TBL     OUT NOCOPY ATTRIBUTE7_TBL
)
is

l_cust_condition_code_tbl     ATTRIBUTE7_TBL;
l_counted_trx_number          NUMBER;
l_address_id                  NUMBER;
l_contributor_class           VARCHAR2(150);
l_use_site_prof               VARCHAR2(150);
l_err_msg                     VARCHAR2(120);

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                                      'GET_CUSTOMER_CONDITION_CODE(+)');
   END IF;

      BEGIN

           SELECT count(distinct trx_id)
             INTO l_counted_trx_number
             FROM zx_rep_trx_detail_t
            WHERE request_id = p_request_id;

      EXCEPTION

           WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
			'ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE : '||substrb(SQLERRM,1,120) );
		END IF;

      END;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                                      'l_counted_trx_number :'||to_char(l_counted_trx_number));
   END IF;

      FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

          IF l_cust_condition_code_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             null;
          ELSE
              l_cust_condition_code_tbl(p_trx_id_tbl(i)) := null;
          END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                                      'l_cust_condition_code_tbl :');
   END IF;


          IF l_cust_condition_code_tbl(p_trx_id_tbl(i)) is null THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                                      'l_cust_condition_code_tbl 1 :');
   END IF;


             BEGIN

                  SELECT add1.cust_acct_site_id,
                         add1.global_attribute8,
                         NVL(add1.global_attribute9,'N')
                    INTO l_address_id,
                         l_contributor_class,
                         l_use_site_prof
                    FROM ra_customer_trx_all  trx,
                         hz_cust_accounts cust,
                         hz_cust_acct_sites_all add1,
                         hz_cust_site_uses_all  site
                   WHERE trx.customer_trx_id = p_trx_id_tbl(i)
                     AND cust.cust_account_id = nvl(trx.ship_to_customer_id,trx.bill_to_customer_id)
                     AND cust.cust_account_id = add1.cust_account_id
                     AND site.cust_acct_site_id = add1.cust_acct_site_id
                     AND site.site_use_id = nvl(trx.bill_to_site_use_id, ship_to_site_use_id);
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                                      'l_use_site_prof :'||l_use_site_prof);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                                      'l_contributor_class :'||l_contributor_class);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                                      'l_address_id :'||to_char(l_address_id));
   END IF;


                   IF l_use_site_prof = 'Y' THEN

                      SELECT VAL.TAX_ATTR_VALUE_CODE
                        INTO l_cust_condition_code_tbl(p_trx_id_tbl(i))
                        FROM JL_ZZ_AR_TX_CUS_CLS_ALL cust,
                             JL_ZZ_AR_TX_CATEG_ALL categ,
                             JL_ZZ_AR_TX_ATT_VAL_ALL  val
                       WHERE CUST.TAX_ATTRIBUTE_VALUE = VAL.TAX_ATTRIBUTE_VALUE and
                             CUST.TAX_CATEGORY_ID = VAL.TAX_CATEGORY_ID and
                             CUST.TAX_CATEGORY_ID = CATEG.TAX_CATEGORY_ID and
                             CUST.TAX_ATTRIBUTE_NAME = VAL.TAX_ATTRIBUTE_NAME and
                             VAL.TAX_ATTRIBUTE_TYPE = 'CONTRIBUTOR_ATTRIBUTE' and
                             CATEG.TAX_CATEGORY = P_VAT_PERCEP_TAX and
                             CUST.TAX_ATTR_CLASS_CODE = l_contributor_class and
                             CUST.ADDRESS_ID = L_ADDRESS_ID AND
                             CUST.ORG_ID = CATEG.ORG_ID AND
                             CATEG.ORG_ID = VAL.ORG_ID AND
                             VAL.ORG_ID = P_INTERNAL_ORG_ID_TBL(I);
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                   'l_cust_condition_code_tbl Value 1 :'||to_char(l_cust_condition_code_tbl(p_trx_id_tbl(i))));
   END IF;


                   ELSIF l_use_site_prof <> 'Y' THEN

                         SELECT VAL.TAX_ATTR_VALUE_CODE
                           INTO l_cust_condition_code_tbl(p_trx_id_tbl(i))
                           FROM JL_ZZ_AR_TX_ATT_CLS_ALL cust,
                                JL_ZZ_AR_TX_CATEG_ALL categ,
                                JL_ZZ_AR_TX_ATT_VAL val
                          WHERE CUST.TAX_ATTRIBUTE_VALUE = VAL.TAX_ATTRIBUTE_VALUE and
                                CUST.TAX_CATEGORY_ID = VAL.TAX_CATEGORY_ID and
                                CUST.TAX_CATEGORY_ID = CATEG.TAX_CATEGORY_ID and
                                CUST.TAX_ATTRIBUTE_NAME = VAL.TAX_ATTRIBUTE_NAME and
                                VAL.TAX_ATTRIBUTE_TYPE = 'CUSTOMER_ATTRIBUTE' and
                                CATEG.TAX_CATEGORY = P_VAT_PERCEP_TAX and
                                CUST.TAX_ATTR_CLASS_TYPE = 'CONTRIBUTOR_CLASS' and
                                CUST.TAX_ATTR_CLASS_CODE = L_CONTRIBUTOR_CLASS AND
                                CUST.ORG_ID = CATEG.ORG_ID AND
                                CATEG.ORG_ID = VAL.ORG_ID AND
                                VAL.ORG_ID = P_INTERNAL_ORG_ID_TBL(I);
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.BEGIN',
                                      'l_cust_condition_code_tbl Value 2 :'||to_char(l_cust_condition_code_tbl(p_trx_id_tbl(i))));
   END IF;
                  END IF;

                  X_CUST_CONDITION_CODE_TBL(i) := l_cust_condition_code_tbl(p_trx_id_tbl(i));

             EXCEPTION

               WHEN NO_DATA_FOUND THEN
                   X_CUST_CONDITION_CODE_TBL(i) :=NULL;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
			'ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE : '||substrb(SQLERRM,1,120) );
		END IF;
               WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
			'ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE : '||substrb(SQLERRM,1,120) );
		END IF;

             END;

          ELSE

               X_CUST_CONDITION_CODE_TBL(i) := l_cust_condition_code_tbl(p_trx_id_tbl(i));

          END IF;
    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' X_CUST_CONDITION_CODE_TBL (i) for : '||' i: '||i||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_CUST_CONDITION_CODE_TBL(i)));
    END IF;

     END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE.END',
                                      'GET_CUSTOMER_CONDITION_CODE(-)');
   END IF;

END get_customer_condition_code;


PROCEDURE GET_DGI_TAX_REGIME_CODE
(
P_VAT_PERCEP_TAX              IN         VARCHAR2,
P_TRX_ID_TBL                  IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TRX_LINE_ID_TBL             IN         ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
P_INTERNAL_ORG_ID_TBL	      IN         ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
P_REQUEST_ID                  IN         NUMBER,
X_DGI_TAX_REGIME_CODE_TBL     OUT NOCOPY ATTRIBUTE25_TBL
)
IS

l_dgi_tax_regime_code_tbl     ATTRIBUTE25_TBL;
l_counted_trx_number          NUMBER;
l_err_msg                     VARCHAR2(120);
k                             NUMBER;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_TAX_REGIME_CODE.BEGIN',
                                    'GET_DGI_TAX_REGIME_CODE(+)');
  END IF;

  BEGIN
       SELECT count(distinct trx_id)
         INTO l_counted_trx_number
         FROM zx_rep_trx_detail_t
        WHERE request_id = p_request_id;
  EXCEPTION
       WHEN OTHERS THEN
      	IF ( g_level_statement>= g_current_runtime_level ) THEN
      		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
      		'ZX_JL_EXTRACT_PKG.GET_DGI_TAX_REGIME_CODE : '||substrb(SQLERRM,1,120) );
      	END IF;
  END;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_TAX_REGIME_CODE',
                                  'l_counted_trx_number :'||to_char(l_counted_trx_number));
  END IF;
        k:=0;
        FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
          IF i = 1 THEN
            k:=1;
          ELSIF (p_trx_line_id_tbl(i) <> p_trx_line_id_tbl(i-1)) THEN
               k:=k+1;
          END IF;
          IF l_dgi_tax_regime_code_tbl.EXISTS(k) THEN
            null;
          ELSE
            l_dgi_tax_regime_code_tbl(k) := null;
          END IF;

          IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_TAX_REGIME_CODE',
                         'p_trx_id_tbl, p_trx_line_id_tbl :'||to_char(p_trx_id_tbl(i))||' '||to_char(p_trx_line_id_tbl(i)));
          END IF;
           IF l_dgi_tax_regime_code_tbl(k) IS NULL THEN
              BEGIN
               SELECT   val.tax_attr_value_code
                 INTO   l_dgi_tax_regime_code_tbl(k)
                 FROM   zx_lines lines,
                        jl_zz_ar_tx_categ_all     catg,
                        jl_zz_ar_tx_att_cls_all attcls,
                        jl_zz_ar_tx_att_val_all val
                 WHERE  catg.tax_category  = P_VAT_PERCEP_TAX
                 ANd   catg.tax_category  = lines.tax
                 AND    attcls.tax_attribute_value = val.tax_attribute_value
                 AND    attcls.tax_category_id     = val.tax_category_id
                 AND    attcls.tax_attribute_name  = val.tax_attribute_name
                 AND    val.tax_attribute_type   = 'TRANSACTION_ATTRIBUTE'
                 AND    attcls.tax_category_id     = catg.tax_category_id
                 AND    attcls.tax_attr_class_code = lines.global_attribute3
                 AND    lines.trx_id = p_trx_id_tbl(i)
                 AND    lines.trx_line_id = p_trx_line_id_tbl(i)
                 AND    attcls.ORG_ID = CATG.ORG_ID
                 AND    CATG.ORG_ID = VAL.ORG_ID
                 AND    lines.internal_organization_id = val.org_id
                 AND    VAL.ORG_ID = P_INTERNAL_ORG_ID_TBL(i);

                 IF (g_level_procedure >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CUSTOMER_CONDITION_CODE',
                   'l_dgi_tax_regime_code :'||l_dgi_tax_regime_code_tbl(k));
                 END IF;

                  X_DGI_TAX_REGIME_CODE_TBL(i) := l_dgi_tax_regime_code_tbl(k);

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   X_DGI_TAX_REGIME_CODE_TBL(i) :=NULL;
                		IF (g_level_statement>= g_current_runtime_level ) THEN
                		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
                			'ZX_JL_EXTRACT_PKG.GET_DGI_TAX_REGIME_CODE : '||substrb(SQLERRM,1,120) );
                		END IF;
               WHEN OTHERS THEN
                		IF ( g_level_statement>= g_current_runtime_level ) THEN
                			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
                			'ZX_JL_EXTRACT_PKG.GET_DGI_TAX_REGIME_CODE : '||substrb(SQLERRM,1,120) );
                		END IF;
             END;
          ELSE
             X_DGI_TAX_REGIME_CODE_TBL(i) := l_dgi_tax_regime_code_tbl(k);
          END IF;
     END LOOP;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_TAX_REGIME_CODE.END',
                                    'GET_DGI_TAX_REGIME_CODE(-)');
     END IF;

END GET_DGI_TAX_REGIME_CODE;

/*===========================================================================+
 | PROCEDURE                                                                  |
 |   GET_VAT_REG_STAT_CODE                                                   |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This function returns the Customer VAT Registration Status Code        |
 |    from fnd_lookups, jl_zz_ar_tx_cus_cls and jl_zz_ar_tx_categry table to |
 |    meet the requirement in the flat file                                  |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                              |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  p_use_site_prof    IN VARCHAR2  Required                  |
 |                 p_class_code       IN VARCHAR2  Required                  |
 |                 p_address_id       IN NUMBER    Required                  |
 |                 p_tax_category_id  IN NUMBER    Required                  |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE GET_VAT_REG_STAT_CODE
(
P_VAT_TAX                     IN         VARCHAR2,
P_TRX_ID_TBL                  IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_INTERNAL_ORG_ID_TBL 	      IN         ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
P_REQUEST_ID                  IN         NUMBER,
X_VAT_REG_STAT_CODE_TBL       OUT NOCOPY ATTRIBUTE8_TBL
)
IS

l_vat_reg_stat_code_tbl       ATTRIBUTE8_TBL;
l_counted_trx_number          NUMBER;
l_address_id                  NUMBER;
l_class_code                  VARCHAR2(150);
l_use_site_prof               VARCHAR2(150);
l_err_msg                     VARCHAR2(120);

 BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_REG_STAT_CODE.BEGIN',
                                      'GET_VAT_REG_STAT_CODE(+)');
   END IF;

      BEGIN

           SELECT count(distinct trx_id)
             INTO l_counted_trx_number
             FROM zx_rep_trx_detail_t
            WHERE request_id = p_request_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_REG_STAT_CODE.BEGIN',
             'GET_VAT_REG_STAT_CODE : transaction count '||to_char(l_counted_trx_number));
   END IF;

      EXCEPTION

           WHEN OTHERS THEN
  		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
			'ZX_JL_EXTRACT_PKG.GET_VAT_REG_STAT_CODE : '||substrb(SQLERRM,1,120) );
		END IF;

      END;


      FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
IF ( g_level_statement>= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        ' For Loop 0 : X_VAT_REG_STAT_CODE_TBL for i: ');
    END IF;


          IF l_vat_reg_stat_code_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             null;
          ELSE
               l_vat_reg_stat_code_tbl(p_trx_id_tbl(i)) := null;
          END IF;

   IF ( g_level_statement>= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        ' For Loop1 : X_VAT_REG_STAT_CODE_TBL for i: ');
    END IF;

          IF l_vat_reg_stat_code_tbl(p_trx_id_tbl(i)) is null THEN

             BEGIN
   IF ( g_level_statement>= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        'For Loop 1-1: l_use_site_prof : '||l_use_site_prof);
    END IF;

                  SELECT add1.cust_acct_site_id,
                         add1.global_attribute8,
                         NVL(add1.global_attribute9,'N')
                    INTO l_address_id,
                         l_class_code,
                         l_use_site_prof
                    FROM ra_customer_trx_all  trx,
                         hz_cust_accounts cust,
                         hz_cust_acct_sites_all add1,
                         hz_cust_site_uses_all  site
                   WHERE trx.customer_trx_id = p_trx_id_tbl(i)
                     AND cust.cust_account_id = NVL(trx.ship_to_customer_id,trx.bill_to_customer_id)
                     AND cust.cust_account_id = add1.cust_account_id
                     AND site.cust_acct_site_id = add1.cust_acct_site_id
                     AND site.site_use_id = NVL(trx.bill_to_site_use_id, ship_to_site_use_id);

   IF ( g_level_statement>= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        'For Loop 2: l_use_site_prof : '||l_use_site_prof);
    END IF;

                   IF l_use_site_prof = 'Y' THEN

                      SELECT  lkp.meaning
                        INTO  l_vat_reg_stat_code_tbl(p_trx_id_tbl(i))
                        FROM  jl_zz_ar_tx_cus_cls_all cls,
                              jl_zz_ar_tx_categ_all catg,
                              fnd_lookups   lkp
                       WHERE  cls.tax_attr_class_code = l_class_code
                         AND  cls.tax_attribute_name =  'VAT CONT STATUS'
                         AND  cls.tax_category_id = catg.tax_category_id
                         AND  cls.address_id  = l_address_id
                         AND  lkp.lookup_type = 'JLZZ_AR_TX_ATTR_VALUE'
                         AND  lkp.lookup_code = cls.tax_attribute_value
                         AND  cls.enabled_flag = 'Y'
                         AND  cls.org_id = catg.org_id
                         AND  cls.org_id = p_internal_org_id_tbl(i)
                         AND  catg.tax_category = p_vat_tax;

                   ELSE

                      SELECT  lkp.meaning
                        INTO  l_vat_reg_stat_code_tbl(p_trx_id_tbl(i))
                        FROM  jl_zz_ar_tx_att_cls_all cls,
                              jl_zz_ar_tx_categ_all catg,
                              fnd_lookups   lkp
                       WHERE  cls.tax_attr_class_type = 'CONTRIBUTOR_CLASS'
                         AND  cls.tax_attr_class_code =  l_class_code
                         AND  cls.tax_attribute_name  = 'VAT CONT STATUS'
                         AND  lkp.lookup_type = 'JLZZ_AR_TX_ATTR_VALUE'
                         AND  lkp.lookup_code = cls.tax_attribute_value
                         AND  cls.tax_attribute_type = 'CONTRIBUTOR_ATTRIBUTE'
                         AND  cls.enabled_flag = 'Y'
                         AND  cls.tax_category_id  = catg.tax_category_id
                         AND  catg.tax_category = p_vat_tax
                         AND  cls.org_id = catg.org_id
                         AND  cls.org_id = p_internal_org_id_tbl(i);

                   END IF;


                   X_VAT_REG_STAT_CODE_TBL(i) := l_vat_reg_stat_code_tbl(p_trx_id_tbl(i));
  IF ( g_level_statement>= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
        'For Loop 3: X_VAT_REG_STAT_CODE_TBL for i: '||i||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_REG_STAT_CODE_TBL(i)));
    END IF;


             EXCEPTION

                  WHEN NO_DATA_FOUND THEN
                     IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
                        'ZX_JL_EXTRACT_PKG.GET_VAT_REG_STAT_CODE : No data Found ');
                     END IF;
                   X_VAT_REG_STAT_CODE_TBL(i) := NULL;

                  WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
			'ZX_JL_EXTRACT_PKG.GET_VAT_REG_STAT_CODE : '||substrb(SQLERRM,1,120) );
		END IF;

             END;

          ELSE

                   X_VAT_REG_STAT_CODE_TBL(i) := l_vat_reg_stat_code_tbl(p_trx_id_tbl(i));

          END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' X_VAT_REG_STAT_CODE_TBL for i: '||i||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_VAT_REG_STAT_CODE_TBL(i)));
    END IF;

      END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_REG_STAT_CODE.END',
                                      'GET_VAT_REG_STAT_CODE(-)');
   END IF;

END get_vat_reg_stat_code;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GET_REC_COUNT                                                           |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This function returns the Tax Authority Code                           |
 |    from jl_zz_ar_tx_categ table to  meet the requirement in the flat file |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                              |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  p_vat_tax IN                                              |
 |                              ZX_REP_TRX_DETAIL_T.TAX%TYPE     Required  |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE GET_REC_COUNT
(
P_VAT_TAX            IN          ZX_REP_TRX_DETAIL_T.TAX%TYPE,
P_TAX_REGIME         IN          ZX_REP_TRX_DETAIL_T.TAX_REGIME_CODE%TYPE,
P_TRX_ID_TBL         IN          ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REQUEST_ID         IN          NUMBER,
X_REC_COUNT_TBL      OUT NOCOPY  NUMERIC11_TBL
)
IS

l_rec_count_tbl                  NUMERIC11_TBL;

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_REC_COUNT.BEGIN',
                                      'GET_REC_COUNT(+)');
   END IF;

      FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

          IF l_rec_count_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             null;
          ELSE
              l_rec_count_tbl(p_trx_id_tbl(i)) := null;
          END IF;

          IF l_rec_count_tbl(p_trx_id_tbl(i)) is null THEN

             BEGIN

                  SELECT count(distinct tax_rate)
                    INTO l_rec_count_tbl(p_trx_id_tbl(i))
                    FROM zx_rep_trx_detail_t
                   WHERE request_id = p_request_id
                     AND trx_id = p_trx_id_tbl(i)
                     AND tax_regime_code = p_tax_regime
                     AND tax = p_vat_tax;

                  X_REC_COUNT_TBL(i) := l_rec_count_tbl(p_trx_id_tbl(i));

             EXCEPTION

                  WHEN OTHERS THEN

                       l_rec_count_tbl(p_trx_id_tbl(i)) := 0;
                       X_REC_COUNT_TBL(i) := l_rec_count_tbl(p_trx_id_tbl(i));
                       null;
             END;


          ELSE

              X_REC_COUNT_TBL(i) := l_rec_count_tbl(p_trx_id_tbl(i));

          END IF;

      END LOOP;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_REC_COUNT.END',
                                      'GET_REC_COUNT(-)');
   END IF;

END get_rec_count;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GET_DGI_DOC_TYPE                                                        |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This function returns the DGI document type                            |
 |    from ap_invoices_all table to  meet the requirement in the flat file   |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AP                           |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  P_TRX_ID_TBL IN ZX_EXTRACT_PKG.TRX_ID_TBL                 |
 |                                                                           |
 +==========================================================================*/
PROCEDURE GET_DGI_DOC_TYPE
(
P_TRX_ID_TBL            IN          ZX_EXTRACT_PKG.TRX_ID_TBL,
X_DGI_DOC_TYPE_TBL      OUT NOCOPY  ATTRIBUTE1_TBL,
X_GDF_AP_INV_ATT11_TBL  OUT NOCOPY  GDF_AP_INV_ATT11_TBL,
X_GDF_AP_INV_ATT12_TBL  OUT NOCOPY  GDF_AP_INV_ATT12_TBL
)
IS

l_dgi_doc_type_tbl       ATTRIBUTE1_TBL;
l_gdf_ap_inv_att11_tbl   GDF_AP_INV_ATT11_TBL;
l_gdf_ap_inv_att12_tbl   GDF_AP_INV_ATT12_TBL;

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_DOC_TYPE.BEGIN',
                                      'GET_DGI_DOC_TYP(+)');
   END IF;

      FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

          IF l_dgi_doc_type_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             null;
          ELSE
              l_dgi_doc_type_tbl(p_trx_id_tbl(i)) := null;
          END IF;

          IF l_dgi_doc_type_tbl(p_trx_id_tbl(i)) is null THEN

             BEGIN

                  SELECT global_attribute11,
                         global_attribute12,
                         global_attribute13
                    INTO l_gdf_ap_inv_att11_tbl(p_trx_id_tbl(i)),
                         l_gdf_ap_inv_att12_tbl(p_trx_id_tbl(i)),
                         l_dgi_doc_type_tbl(p_trx_id_tbl(i))
                    FROM ap_invoices_all
                   WHERE invoice_id = p_trx_id_tbl(i);

                  X_GDF_AP_INV_ATT11_TBL(i)  := l_gdf_ap_inv_att11_tbl(p_trx_id_tbl(i));
                  X_GDF_AP_INV_ATT12_TBL(i)  := l_gdf_ap_inv_att12_tbl(p_trx_id_tbl(i));
                  X_DGI_DOC_TYPE_TBL(i) := l_dgi_doc_type_tbl(p_trx_id_tbl(i));

             EXCEPTION
                  WHEN OTHERS THEN
                    l_dgi_doc_type_tbl(p_trx_id_tbl(i)) := '0';
                    l_gdf_ap_inv_att11_tbl(p_trx_id_tbl(i)) := NULL;
                    l_gdf_ap_inv_att11_tbl(p_trx_id_tbl(i)) := NULL;
                    X_GDF_AP_INV_ATT11_TBL(i)  := l_gdf_ap_inv_att11_tbl(p_trx_id_tbl(i));
                    X_GDF_AP_INV_ATT12_TBL(i)  := l_gdf_ap_inv_att12_tbl(p_trx_id_tbl(i));
                    X_DGI_DOC_TYPE_TBL(i) := l_dgi_doc_type_tbl(p_trx_id_tbl(i));
                    NULL;
             END;


          ELSE

                    X_GDF_AP_INV_ATT11_TBL(i)  := l_gdf_ap_inv_att11_tbl(p_trx_id_tbl(i));
                    X_GDF_AP_INV_ATT12_TBL(i)  := l_gdf_ap_inv_att12_tbl(p_trx_id_tbl(i));
                    X_DGI_DOC_TYPE_TBL(i) := l_dgi_doc_type_tbl(p_trx_id_tbl(i));

          END IF;

      END LOOP;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_DGI_DOC_TYPE.END',
                                      'GET_DGI_DOC_TYPE(-)');
   END IF;

END GET_DGI_DOC_TYPE;


PROCEDURE UPDATE_DGI_CURR_CODE
(
P_REQUEST_ID IN NUMBER
)
 IS
 BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.UPDATE_DGI_CURR_CODE.END',
                                      'UPDATE_DGI_CURR_CODE(+)');
   END IF;

    UPDATE zx_rep_trx_detail_t dtl
        SET gdf_fnd_currencies_att1= (SELECT global_attribute1
                                        FROM fnd_currencies
                                       WHERE currency_code = dtl.trx_currency_code)
    WHERE request_id = p_request_id;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.UPDATE_DGI_CURR_CODE.END',
                                      'UPDATE_DGI_CURR_CODE(-)');
   END IF;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GET_VAT_NONVAT_RATE_COUNT                                                           |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This function returns the Tax Authority Code                           |
 |    from jl_zz_ar_tx_categ table to  meet the requirement in the flat file |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                              |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  p_vat_tax IN                                              |
 |                              ZX_REP_TRX_DETAIL_T.TAX%TYPE     Required  |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE GET_VAT_NONVAT_RATE_COUNT
(
P_VAT_TAX            IN          ZX_REP_TRX_DETAIL_T.TAX%TYPE,
P_VAT_NON_TAX        IN          ZX_REP_TRX_DETAIL_T.TAX%TYPE,
P_TAX_REGIME         IN          ZX_REP_TRX_DETAIL_T.TAX_REGIME_CODE%TYPE,
P_TRX_ID_TBL         IN          ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REQUEST_ID         IN          NUMBER,
X_RATE_COUNT_TBL     OUT NOCOPY  NUMERIC13_TBL
)
IS

l_rate_count_tbl                 NUMERIC13_TBL;

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_NONVAT_RATE_COUNT.BEGIN',
                                      'GET_VAT_NONVAT_RATE_COUNT(+)');
   END IF;

      FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP

          IF l_rate_count_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             null;
          ELSE
              l_rate_count_tbl(p_trx_id_tbl(i)) := null;
          END IF;

          IF l_rate_count_tbl(p_trx_id_tbl(i)) is null THEN

             BEGIN

                  SELECT count(distinct t1.tax_rate)
                    INTO l_rate_count_tbl(p_trx_id_tbl(i))
                    FROM zx_rep_trx_detail_t t1
                   WHERE t1.request_id = p_request_id
                     AND t1.trx_id = p_trx_id_tbl(i)
                     AND NVL(t1.TAX_TYPE_CODE, 'VAT') = 'VAT'
                     AND tax_regime_code = p_tax_regime
                     AND tax in (p_vat_tax, p_vat_non_tax)
                     AND EXISTS ( SELECT 1
                                    FROM zx_rep_trx_detail_t t2
                                   WHERE t2.request_id = p_request_id
                                     AND t2.trx_id = t1.trx_id
                                     AND t2.tax_rate = 0
                                     AND t2.tax_regime_code = p_tax_regime
                                     AND t2.tax = p_vat_non_tax);

                  X_RATE_COUNT_TBL(i) := l_rate_count_tbl(p_trx_id_tbl(i));

             EXCEPTION

                  WHEN OTHERS THEN

                       l_rate_count_tbl(p_trx_id_tbl(i)) := 1;
                       X_RATE_COUNT_TBL(i) := l_rate_count_tbl(p_trx_id_tbl(i));
                       null;
             END;


          ELSE

              X_RATE_COUNT_TBL(i) := l_rate_count_tbl(p_trx_id_tbl(i));

          END IF;

      END LOOP;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_VAT_NONVAT_RATE_COUNT.END',
                                      'GET_VAT_NONVAT_RATE_COUNT(-)');
   END IF;

END get_vat_nonvat_rate_count;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GET_TOTAL_DOCUMENT_AMOUNT                                               |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This function returns the Tax Authority Code                           |
 |    from jl_zz_ar_tx_categ table to  meet the requirement in the flat file |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                              |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  p_trx_id_tbl IN  ZX_EXTRACT_PKG.TRX_ID_TBL    Required    |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE GET_TOTAL_DOCUMENT_AMOUNT
(
P_TRX_ID_TBL                IN          ZX_EXTRACT_PKG.TRX_ID_TBL,
P_EXCHANGE_RATE_TBL         IN          ZX_EXTRACT_PKG.CURRENCY_CONVERSION_RATE_TBL,
P_REPORT_NAME               IN          VARCHAR2,
X_TOTAL_DOC_AMT_TBL         OUT NOCOPY  NUMERIC12_TBL
)
IS

l_total_doc_amt_tbl         NUMERIC12_TBL;
l_gdf_ra_cust_trx_att19_tbl GDF_RA_CUST_TRX_ATT19_TBL;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT.BEGIN',
                                      'GET_TOTAL_DOCUMENT_AMOUNT(+)');
   END IF;



     FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
--Bug 5396444
   IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT',
                                      'i :'||i);
     FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT',
                                      'trx_id :'||P_TRX_ID_TBL(i));
     FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT',
                                      'P_EXCHANGE_RATE_TBL :'||P_EXCHANGE_RATE_TBL(i));
   END IF;

         IF l_total_doc_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
             l_total_doc_amt_tbl(p_trx_id_tbl(i)) := NULL;
         END IF;

         IF l_total_doc_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

            IF P_REPORT_NAME = 'JLARTPFF' THEN

               SELECT abs(sum(nvl(extended_amount,0) * nvl(p_exchange_rate_tbl(i),1)))
                 INTO l_total_doc_amt_tbl(p_trx_id_tbl(i))
	         FROM ra_customer_trx_lines
                WHERE customer_trx_id = p_trx_id_tbl(i);

            ELSIF P_REPORT_NAME = 'ZXCOARSB' THEN -- : Total Doc Amt.

	       SELECT (SUM(DECODE(ctl.line_type,'LINE', NVL(ctl.extended_amount,0),0))
                          + SUM(DECODE(ctl.line_type,'FREIGHT',NVL(ctl.extended_amount,0),0))
                          + SUM(DECODE(ctl.line_type,'CHARGE',NVL(ctl.extended_amount,0),0)))-- *  p_exchange_rate_tbl(i)
                 INTO l_total_doc_amt_tbl(p_trx_id_tbl(i))
                 FROM ra_customer_trx_lines_all ctl --Bug 5396444
                WHERE ctl.customer_trx_id = p_trx_id_tbl(i);

            ELSIF P_REPORT_NAME = 'ZXZZTVSR' THEN

              SELECT (nvl(SUM(NVL(L.GROSS_EXTENDED_AMOUNT, nvl(L.EXTENDED_AMOUNT,0))),0) * p_exchange_rate_tbl(i))
                INTO  l_total_doc_amt_tbl(p_trx_id_tbl(i))
                FROM  RA_CUSTOMER_TRX_LINES L
               WHERE  L.CUSTOMER_TRX_ID = p_trx_id_tbl(i);

            ELSIF P_REPORT_NAME in ('JLARTSFF','JLARTDFF') THEN

                 IF ( g_level_statement>= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
               'ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT : att19 '||P_REPORT_NAME);
                 END IF;


                    IF l_gdf_ra_cust_trx_att19_tbl.EXISTS(p_trx_id_tbl(i)) THEN
                       null;
                    ELSE
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) := null;
                    END IF;

                    IF ( l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'IS_NULL' and
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) <> 'NOT_NULL' ) OR
                         l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) IS NULL THEN

                        BEGIN

                                  SELECT  decode(global_attribute19,NULL,'IS_NULL','NOT_NULL')
                                    INTO  l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i))
                                    FROM  ra_customer_trx_all
                                   WHERE  customer_trx_id = p_trx_id_tbl(i);

                 IF ( g_level_statement>= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
                   'ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT : att19 '||l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)));
                 END IF;

                    EXCEPTION
                       WHEN OTHERS THEN
		         IF ( g_level_statement>= g_current_runtime_level ) THEN
		            FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
		            'ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT : '||substrb(SQLERRM,1,120) );
			 END IF;
                    END;

                    END IF;

                    IF l_gdf_ra_cust_trx_att19_tbl(p_trx_id_tbl(i)) = 'IS_NULL' THEN

                       IF P_REPORT_NAME= 'JLARTDFF' THEN

                          SELECT nvl(SUM(abs(NVL(GROSS_EXTENDED_AMOUNT, nvl(EXTENDED_AMOUNT,0)))),0)
                            INTO l_total_doc_amt_tbl(p_trx_id_tbl(i))
	                    FROM ra_customer_trx_lines
                           WHERE customer_trx_id = p_trx_id_tbl(i);

                       ELSIF P_REPORT_NAME = 'JLARTSFF' THEN

                 IF ( g_level_statement>= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
                'ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT : exchange rate : '||to_char(p_exchange_rate_tbl(i)));
                 END IF;

                            SELECT (nvl(SUM(NVL(L.GROSS_EXTENDED_AMOUNT, nvl(L.EXTENDED_AMOUNT,0))),0)
                                    * nvl(p_exchange_rate_tbl(i),1))
                              INTO   l_total_doc_amt_tbl(p_trx_id_tbl(i))
                              FROM   RA_CUSTOMER_TRX_LINES L
                             WHERE  L.CUSTOMER_TRX_ID = p_trx_id_tbl(i);
                       END IF;

                   ELSE
                          l_total_doc_amt_tbl(p_trx_id_tbl(i)) := 0;
                   END IF;

            ELSIF P_REPORT_NAME = 'JLARPPFF' THEN

                     SELECT abs(nvl(SUM(NVL(aid.base_amount, aid.amount)),0))
                       INTO l_total_doc_amt_tbl(p_trx_id_tbl(i))
                       FROM ap_invoice_distributions aid
                      WHERE aid.invoice_id = p_trx_id_tbl(i)
                        AND aid.line_type_lookup_code <> 'AWT';
            END IF;

            X_TOTAL_DOC_AMT_TBL(i) := l_total_doc_amt_tbl(p_trx_id_tbl(i));

         ELSE

        --    X_TOTAL_DOC_AMT_TBL(i) := l_total_doc_amt_tbl(p_trx_id_tbl(i));
            X_TOTAL_DOC_AMT_TBL(i) := 0;

         END IF;


   IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' X_TOTAL_DOC_AMT_TBL for Report Name  : '||p_report_name ||' i: '||i||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_TOTAL_DOC_AMT_TBL(i)));
    END IF;

     END LOOP;
   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TOTAL_DOCUMENT_AMOUNT.END',
                                      'GET_TOTAL_DOCUMENT_AMOUNT(-)');
   END IF;

END GET_TOTAL_DOCUMENT_AMOUNT;



PROCEDURE DGI_TRX_CODE
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_TAX_RATE_ID_TBL             IN ZX_EXTRACT_PKG.tax_rate_id_tbl,
X_DGI_TRX_CODE_TBL            OUT NOCOPY ATTRIBUTE4_TBL
) IS


  l_dgi_trx_code_tbl        ATTRIBUTE4_TBL;
  l_err_msg                   VARCHAR2(120);



BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE.BEGIN',
                                      'DGI_TRX_CODE(+)');
    END IF;

     FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP

         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TAX_RATE_ID_TBL: '||to_char(P_TAX_RATE_ID_TBL(i)));
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TAX_REGIME_CODE_TBL : '||P_TAX_REGIME_CODE_TBL(i));
         END IF;

         IF l_dgi_trx_code_tbl.EXISTS(p_tax_rate_id_tbl(i)) THEN
             NULL;
          ELSE
              l_dgi_trx_code_tbl(p_tax_rate_id_tbl(i)) := null;
          END IF;

          IF l_dgi_trx_code_tbl(p_tax_rate_id_tbl(i)) IS NULL THEN
             BEGIN
               SELECT rep_ass.reporting_code_char_value
                 INTO l_dgi_trx_code_tbl(p_tax_rate_id_tbl(i))
                 FROM zx_reporting_types_b rep_type,
                      zx_report_codes_assoc rep_ass
                WHERE rep_type.reporting_type_code = 'AR_DGI_TRX_CODE'
                  AND rep_ass.reporting_type_id = rep_type.reporting_type_id
                  AND rep_ass.entity_code = 'ZX_RATES'
                  AND rep_ass.entity_id =P_TAX_RATE_ID_TBL(i)
                  AND rep_type.tax_regime_code =P_TAX_REGIME_CODE_TBL(i);


             EXCEPTION
              WHEN NO_DATA_FOUND THEN
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                       'NO_DATA_FOUND : '||to_char(i));
       END IF;
                X_DGI_TRX_CODE_TBL(i) := NULL;
                --X_DGI_TRX_CODE_TBL(i) := 'T';
            END;

            IF l_dgi_trx_code_tbl(p_tax_rate_id_tbl(i)) IS NULL THEN
               X_DGI_TRX_CODE_TBL(i) := NULL;
               --X_DGI_TRX_CODE_TBL(i) := 'T';
            ELSE
               X_DGI_TRX_CODE_TBL(i) := l_dgi_trx_code_tbl(p_tax_rate_id_tbl(i));
            END IF;
       ELSE
               X_DGI_TRX_CODE_TBL(i) := l_dgi_trx_code_tbl(p_tax_rate_id_tbl(i));
       END IF;
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                       'l_dgi_trx_code_tbl : '||to_char(i) ||':'|| X_DGI_TRX_CODE_TBL(i));
       END IF;
     END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE.END',
                                      'DGI_TRX_CODE(-)');
       END IF;


 EXCEPTION
     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                        'ZX_JL_EXTRACT_PKG.DGI_TRX_CODE : '||substrb(SQLERRM,1,120) );
                END IF;

     WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
			'ZX_JL_EXTRACT_PKG.DGI_TRX_CODE : '||substrb(SQLERRM,1,120) );
		END IF;

END DGI_TRX_CODE;


PROCEDURE GET_TAX_AUTH_CATEG
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_TAX_RATE_ID_TBL             IN ZX_EXTRACT_PKG.tax_rate_id_tbl,
X_TAX_AUTH_CATEG_TBL          OUT NOCOPY ATTRIBUTE10_TBL
) IS


  l_tax_auth_categ_tbl        ATTRIBUTE10_TBL;
  l_err_msg                   VARCHAR2(120);



BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAX_AUTH_CATEG.BEGIN',
                                      'GET_TAX_AUTH_CATEG(+)');
    END IF;

     FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP

         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TAX_RATE_ID_TBL: '||to_char(P_TAX_RATE_ID_TBL(i)));
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TAX_REGIME_CODE_TBL : '||P_TAX_REGIME_CODE_TBL(i));
         END IF;

         IF l_tax_auth_categ_tbl.EXISTS(p_tax_rate_id_tbl(i)) THEN
             NULL;
          ELSE
              l_tax_auth_categ_tbl(p_tax_rate_id_tbl(i)) := null;
          END IF;

          IF l_tax_auth_categ_tbl(p_tax_rate_id_tbl(i)) IS NULL THEN
          BEGIN
             SELECT rep_ass.reporting_code_char_value
               INTO l_tax_auth_categ_tbl(p_tax_rate_id_tbl(i))
               FROM zx_reporting_types_b rep_type,
                    zx_report_codes_assoc rep_ass
              WHERE rep_type.reporting_type_code = 'AR_TAX_AUTHORITY_CATEG'
                AND rep_ass.reporting_type_id = rep_type.reporting_type_id
                AND rep_ass.entity_code = 'ZX_RATES'
                AND rep_ass.entity_id =P_TAX_RATE_ID_TBL(i)
                AND rep_type.tax_regime_code =P_TAX_REGIME_CODE_TBL(i);


           EXCEPTION
            WHEN NO_DATA_FOUND THEN
              X_TAX_AUTH_CATEG_TBL(i) := NULL;

         END;

          IF l_tax_auth_categ_tbl(p_tax_rate_id_tbl(i)) IS NULL THEN
           X_TAX_AUTH_CATEG_TBL(i) := NULL;
          ELSE
           X_TAX_AUTH_CATEG_TBL(i) := l_tax_auth_categ_tbl(p_tax_rate_id_tbl(i));
          END IF;
       END IF;
     END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAX_AUTH_CATEG.END',
                                      'GET_TAX_AUTH_CATEG(-)');
       END IF;


 EXCEPTION
     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAX_AUTH_CATEG',
                      'ZX_JL_EXTRACT_PKG.GET_TAX_AUTH_CATEG : '||substrb(SQLERRM,1,120) );
                END IF;

     WHEN OTHERS THEN
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAX_AUTH_CATEG',
		'ZX_JL_EXTRACT_PKG.GET_TAX_AUTH_CATEG : '||substrb(SQLERRM,1,120) );
	END IF;

END GET_TAX_AUTH_CATEG;


PROCEDURE PROV_JURISDICTION_CODE
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_TAX_RATE_ID_TBL             IN ZX_EXTRACT_PKG.tax_rate_id_tbl,
X_PROV_JURIS_CODE_TBL          OUT NOCOPY ATTRIBUTE1_TBL
) IS

  l_prov_juris_code_tbl       ATTRIBUTE1_TBL;
  l_err_msg                   VARCHAR2(120);



BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.PROV_JURISDICTION_CODE.BEGIN',
                                      'PROV_JURISDICTION_CODE(+)');
    END IF;

     FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP

         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TAX_RATE_ID_TBL: '||to_char(P_TAX_RATE_ID_TBL(i)));
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TAX_REGIME_CODE_TBL : '||P_TAX_REGIME_CODE_TBL(i));
         END IF;

         IF l_prov_juris_code_tbl.EXISTS(p_tax_rate_id_tbl(i)) THEN
           X_PROV_JURIS_CODE_TBL(i) := l_prov_juris_code_tbl(p_tax_rate_id_tbl(i));
           IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TRX_ID_TBL: Not NULL '||to_char(P_TRX_ID_TBL(i))||'-'||to_char(i));
         END IF;
         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'X_PROV_JURIS_CODE_TBL: '||l_prov_juris_code_tbl(p_tax_rate_id_tbl(i)));
         END IF;

             NULL;
          ELSE
              l_prov_juris_code_tbl(p_tax_rate_id_tbl(i)) := null;
           IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TRX_ID_TBL: NULL assign '||to_char(P_TRX_ID_TBL(i))||'-'||to_char(i));
         END IF;
          END IF;

          IF l_prov_juris_code_tbl(p_tax_rate_id_tbl(i)) IS NULL THEN
          BEGIN
           /*  SELECT rep_ass.reporting_code_char_value
               INTO l_prov_juris_code_tbl(p_tax_rate_id_tbl(i))
               FROM zx_reporting_types_b rep_type,
                    zx_report_codes_assoc rep_ass
              WHERE rep_type.reporting_type_code = 'AR_TURN_OVER_JUR_CODE'
                AND rep_ass.reporting_type_id = rep_type.reporting_type_id
                AND rep_ass.entity_code = 'ZX_RATES'
                AND rep_ass.entity_id =P_TAX_RATE_ID_TBL(i)
                AND rep_type.tax_regime_code =P_TAX_REGIME_CODE_TBL(i);

         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'X_PROV_JURIS_CODE_TBL: '||l_prov_juris_code_tbl(p_tax_rate_id_tbl(i)));
         END IF;

           EXCEPTION
            WHEN NO_DATA_FOUND THEN
              X_PROV_JURIS_CODE_TBL(i) := NULL; */
              SELECT global_attribute5
                INTO l_prov_juris_code_tbl(p_tax_rate_id_tbl(i))
                FROM ar_vat_tax_all
               WHERE VAT_TAX_ID = P_TAX_RATE_ID_TBL(i);

              X_PROV_JURIS_CODE_TBL(i) := l_prov_juris_code_tbl(p_tax_rate_id_tbl(i));

         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'X_PROV_JURIS_CODE_TBL: '||X_PROV_JURIS_CODE_TBL(i));
         END IF;

         END;

         -- IF l_prov_juris_code_tbl(p_tax_rate_id_tbl(i)) IS NULL THEN
          -- X_PROV_JURIS_CODE_TBL(i) := NULL;
      -- ELSE
           X_PROV_JURIS_CODE_TBL(i) := l_prov_juris_code_tbl(p_tax_rate_id_tbl(i));
       END IF;
       --END IF;
     END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.PROV_JURISDICTION_CODE.END',
                                      'PROV_JURISDICTION_CODE(-)');
       END IF;


 EXCEPTION
     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.PROV_JURISDICTION_CODE',
                      'ZX_JL_EXTRACT_PKG.PROV_JURISDICTION_CODE : '||substrb(SQLERRM,1,120) );
                END IF;

     WHEN OTHERS THEN
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.PROV_JURISDICTION_CODE',
		'ZX_JL_EXTRACT_PKG.PROV_JURISDICTION_CODE : '||substrb(SQLERRM,1,120) );
	END IF;

END PROV_JURISDICTION_CODE;


PROCEDURE MUN_JURISDICTION_CODE
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_TAX_RATE_ID_TBL             IN ZX_EXTRACT_PKG.tax_rate_id_tbl,
X_MUN_JURIS_CODE_TBL          OUT NOCOPY ATTRIBUTE3_TBL
) IS


  l_mun_juris_code_tbl       ATTRIBUTE3_TBL;
  l_err_msg                   VARCHAR2(120);



BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE.BEGIN',
                                      'MUN_JURISDICTION_CODE(+)');
    END IF;

     FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP

         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TAX_RATE_ID_TBL: '||to_char(P_TAX_RATE_ID_TBL(i)));
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.DGI_TRX_CODE',
                                 'P_TAX_REGIME_CODE_TBL : '||P_TAX_REGIME_CODE_TBL(i));
         END IF;

         IF l_mun_juris_code_tbl.EXISTS(p_tax_rate_id_tbl(i)) THEN
           X_MUN_JURIS_CODE_TBL(i) := l_mun_juris_code_tbl(p_tax_rate_id_tbl(i));
             NULL;
          ELSE
              l_mun_juris_code_tbl(p_tax_rate_id_tbl(i)) := null;
          END IF;

          IF l_mun_juris_code_tbl(p_tax_rate_id_tbl(i)) IS NULL THEN
          BEGIN
          /*   SELECT rep_ass.reporting_code_char_value
               INTO l_mun_juris_code_tbl(p_tax_rate_id_tbl(i))
               FROM zx_reporting_types_b rep_type,
                    zx_report_codes_assoc rep_ass
              WHERE rep_type.reporting_type_code = 'AR_MUNICIPAL_JUR'
                AND rep_ass.reporting_type_id = rep_type.reporting_type_id
                AND rep_ass.entity_code = 'ZX_RATES'
                AND rep_ass.entity_id =P_TAX_RATE_ID_TBL(i)
                AND rep_type.tax_regime_code =P_TAX_REGIME_CODE_TBL(i);


         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE',
                                 'Reporting Types : X_MUN_JURIS_CODE_TBL: '||l_mun_juris_code_tbl(p_tax_rate_id_tbl(i)));
         END IF;

           EXCEPTION
            WHEN NO_DATA_FOUND THEN
              X_MUN_JURIS_CODE_TBL(i) := NULL; */

              SELECT global_attribute6
                INTO l_mun_juris_code_tbl(p_tax_rate_id_tbl(i))
                FROM ar_vat_tax_all
               WHERE VAT_TAX_ID = P_TAX_RATE_ID_TBL(i);

         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE',
                                 'Exception : X_MUN_JURIS_CODE_TBL: '||l_mun_juris_code_tbl(p_tax_rate_id_tbl(i)));
         END IF;
           X_MUN_JURIS_CODE_TBL(i) := l_mun_juris_code_tbl(p_tax_rate_id_tbl(i));

         END;

        --  IF l_mun_juris_code_tbl(p_tax_rate_id_tbl(i)) IS NULL THEN
         --  X_MUN_JURIS_CODE_TBL(i) := NULL;
         -- ELSE
           X_MUN_JURIS_CODE_TBL(i) := l_mun_juris_code_tbl(p_tax_rate_id_tbl(i));
          END IF;
         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE',
                                 'X_MUN_JURIS_CODE_TBL: '||X_MUN_JURIS_CODE_TBL(i));
         END IF;

       --END IF;
     END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE.END',
                                      'MUN_JURISDICTION_CODE(-)');
       END IF;


 EXCEPTION
     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE',
                      'ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE : '||substrb(SQLERRM,1,120) );
                END IF;

     WHEN OTHERS THEN
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE',
		'ZX_JL_EXTRACT_PKG.MUN_JURISDICTION_CODE : '||substrb(SQLERRM,1,120) );
	END IF;

END MUN_JURISDICTION_CODE;

/*
PROCEDURE GET_CAI_NUM
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REPORT_NAME                 IN          VARCHAR2,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_BILL_FROM_SITE_PROF_ID_TBL  IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_SITE_ID_TBL       IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
X_CAI_NUMBER_TBL              OUT NOCOPY ATTRIBUTE19_TBL,
X_CAI_DUE_DATE_TBL            OUT NOCOPY ATTRIBUTE23_TBL
) IS


  l_cai_num_tbl        ATTRIBUTE19_TBL;
  l_cai_due_date_tbl        ATTRIBUTE23_TBL;
  l_rep_cai_num_tbl        ATTRIBUTE19_TBL;
  l_err_msg                   VARCHAR2(120);


PROCEDURE GET_CAI_NUM
PROCEDURE GET_CAI_NUM
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REPORT_NAME                 IN          VARCHAR2,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_BILL_FROM_SITE_PROF_ID_TBL  IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_SITE_ID_TBL       IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
X_CAI_NUMBER_TBL              OUT NOCOPY ATTRIBUTE19_TBL,
X_CAI_DUE_DATE_TBL            OUT NOCOPY ATTRIBUTE23_TBL
) IS


  l_cai_num_tbl        ATTRIBUTE19_TBL;
  l_cai_due_date_tbl        ATTRIBUTE23_TBL;
  l_rep_cai_num_tbl        ATTRIBUTE19_TBL;
  l_err_msg                   VARCHAR2(120);


PROCEDURE GET_CAI_NUM
PROCEDURE GET_CAI_NUM
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REPORT_NAME                 IN          VARCHAR2,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_BILL_FROM_SITE_PROF_ID_TBL  IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_SITE_ID_TBL       IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
X_CAI_NUMBER_TBL              OUT NOCOPY ATTRIBUTE19_TBL,
X_CAI_DUE_DATE_TBL            OUT NOCOPY ATTRIBUTE23_TBL
) IS


  l_cai_num_tbl        ATTRIBUTE19_TBL;
  l_cai_due_date_tbl        ATTRIBUTE23_TBL;
  l_rep_cai_num_tbl        ATTRIBUTE19_TBL;
  l_err_msg                   VARCHAR2(120);
*/

PROCEDURE GET_CAI_NUM
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REPORT_NAME                 IN          VARCHAR2,
P_TAX_REGIME_CODE_TBL         IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_BILL_FROM_SITE_PROF_ID_TBL  IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_SITE_ID_TBL       IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
P_INTERNAL_ORG_ID             IN ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL,
X_CAI_NUMBER_TBL              OUT NOCOPY ATTRIBUTE19_TBL,
X_CAI_DUE_DATE_TBL            OUT NOCOPY ATTRIBUTE23_TBL
) IS


  l_cai_num_tbl        ATTRIBUTE19_TBL;
  l_cai_due_date_tbl        ATTRIBUTE23_TBL;
  l_rep_cai_num_tbl        ATTRIBUTE19_TBL;
  l_err_msg                   VARCHAR2(120);



BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM.BEGIN',
                                      'GET_CAI_NUM(+)');
    END IF;

     IF P_REPORT_NAME = 'JLARPPFF' THEN
     FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP

     /*    IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
                                 'P_BILL_FROM_SITE_ID_TBL : '||to_char(P_BILL_FROM_SITE_ID_TBL(i)));
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
                                 'P_BILL_FROM_SITE_PROF_ID_TBL : '||to_char(P_BILL_FROM_SITE_PROF_ID_TBL(i)));
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
                                 'P_TAX_REGIME_CODE_TBL : '||P_TAX_REGIME_CODE_TBL(i));
         END IF; */

         IF l_cai_num_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             NULL;
          ELSE
              l_cai_due_date_tbl(p_trx_id_tbl(i)) := NULL;
              l_cai_num_tbl(p_trx_id_tbl(i)) := null;
          END IF;

          IF l_cai_num_tbl(p_trx_id_tbl(i)) is null THEN
          BEGIN
         IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
                                 'P_BILL_FROM_SITE_ID_TBL : '||to_char(P_BILL_FROM_SITE_ID_TBL(i)));
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
                                 'P_BILL_FROM_SITE_PROF_ID_TBL : '||to_char(P_BILL_FROM_SITE_PROF_ID_TBL(i)));
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
                                 'P_TAX_REGIME_CODE_TBL : '||P_TAX_REGIME_CODE_TBL(i));
         END IF;
           SELECT rep_ass.reporting_code_char_value
             INTO l_cai_num_tbl(p_trx_id_tbl(i))
             FROM zx_reporting_types_b rep_type,
                  zx_report_codes_assoc rep_ass
            WHERE rep_type.reporting_type_code = 'CAI NUMBER'
              AND rep_ass.reporting_type_id = rep_type.reporting_type_id
              AND rep_ass.entity_code = 'ZX_PARTY_TAX_PROFILE'
              AND rep_ass.entity_id = P_BILL_FROM_SITE_PROF_ID_TBL(i)
              AND rep_type.tax_regime_code = P_TAX_REGIME_CODE_TBL(i);

           X_CAI_NUMBER_TBL(i) := nvl(l_cai_num_tbl(p_trx_id_tbl(i)),0);
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
         -- BEGIN
	   IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
	        'l_cai_num : '||l_cai_num_tbl(p_trx_id_tbl(i))||'-'||l_cai_due_date_tbl(p_trx_id_tbl(i)));
           END IF;
           X_CAI_NUMBER_TBL(i) := NULL;
        --   IF l_rep_cai_num_tbl(p_trx_id_tbl(i)) IS NULL THEN
              SELECT nvl(global_attribute19,0),nvl(global_attribute20,' ')
                INTO l_cai_num_tbl(p_trx_id_tbl(i)),
                     l_cai_due_date_tbl(p_trx_id_tbl(i))
                FROM ap_invoices_all
               WHERE invoice_id = P_TRX_ID_TBL(i)
                 AND org_id = P_INTERNAL_ORG_ID(i);
         --  END IF;

           X_CAI_NUMBER_TBL(i) := nvl(l_cai_num_tbl(p_trx_id_tbl(i)),0);
           X_CAI_DUE_DATE_TBL(i) := nvl(l_cai_due_date_tbl(p_trx_id_tbl(i)),' ');
	   IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
	        'l_cai_num : '||l_cai_num_tbl(p_trx_id_tbl(i))||'-'||l_cai_due_date_tbl(p_trx_id_tbl(i)));
           END IF;
          -- END;

   END;
    ELSE
	   IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
					      'Else : l_cai_num : '||l_cai_num_tbl(p_trx_id_tbl(i)));
           END IF;
           X_CAI_NUMBER_TBL(i) := l_cai_num_tbl(p_trx_id_tbl(i));
           X_CAI_DUE_DATE_TBL(i) := l_cai_due_date_tbl(p_trx_id_tbl(i));
/*
          IF l_cai_num_tbl(p_trx_id_tbl(i)) IS NULL THEN
           X_CAI_NUMBER_TBL(i) := NULL;
           X_CAI_DUE_DATE_TBL(i) := NULL;
          ELSE
           X_CAI_NUMBER_TBL(i) := l_cai_num_tbl(p_trx_id_tbl(i));
           X_CAI_DUE_DATE_TBL(i) := l_cai_due_date_tbl(p_trx_id_tbl(i));
          END IF; */
       END IF;
     END LOOP;
     ENd IF;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM.END',
                                      'GET_CAI_NUM(-)');
       END IF;


 EXCEPTION
     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
                        'ZX_JL_EXTRACT_PKG.GET_CAI_NUM : '||substrb(SQLERRM,1,120) );
                END IF;

       --    X_CAI_NUMBER_TBL(i) := NULL;

     WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM',
			'ZX_JL_EXTRACT_PKG.GET_CAI_NUM : '||substrb(SQLERRM,1,120) );
		END IF;

END GET_CAI_NUM;

PROCEDURE GET_CAI_NUM_AR
(
P_TRX_ID_TBL                  IN ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REPORT_NAME                 IN          VARCHAR2,
X_CAI_NUMBER_TBL              OUT NOCOPY ATTRIBUTE19_TBL,
X_CAI_DUE_DATE_TBL            OUT NOCOPY ATTRIBUTE23_TBL
) IS


  l_cai_num_tbl        ATTRIBUTE19_TBL;
  l_cai_due_date_tbl        ATTRIBUTE23_TBL;
  l_rep_cai_num_tbl        ATTRIBUTE19_TBL;
  l_err_msg                   VARCHAR2(120);



BEGIN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM_AR.BEGIN',
                                      'GET_CAI_NUM_AR(+)');
    END IF;

    IF P_REPORT_NAME IN ('JLARTSFF','JLARTDFF') THEN -- Report Name Check

     FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP
      IF l_cai_num_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             NULL;
      ELSE
         l_cai_num_tbl(p_trx_id_tbl(i)) := null;
      END IF;

      IF l_cai_num_tbl(p_trx_id_tbl(i)) is null THEN
         BEGIN
           SELECT global_attribute17,global_attribute18
             INTO l_cai_num_tbl(p_trx_id_tbl(i)),
                  l_cai_due_date_tbl(p_trx_id_tbl(i))
             FROM ra_customer_trx
            WHERE customer_trx_id = p_trx_id_tbl(i);

          EXCEPTION
           WHEN NO_DATA_FOUND THEN
           X_CAI_NUMBER_TBL(i) := NULL;
           X_CAI_DUE_DATE_TBL(i) := NULL;
         END;

          IF l_cai_num_tbl(p_trx_id_tbl(i)) IS NULL THEN
           X_CAI_NUMBER_TBL(i) := NULL;
           X_CAI_DUE_DATE_TBL(i) := NULL;
          ELSE
           X_CAI_NUMBER_TBL(i) := l_cai_num_tbl(p_trx_id_tbl(i));
           X_CAI_DUE_DATE_TBL(i) := l_cai_due_date_tbl(p_trx_id_tbl(i));
          END IF;
          ELSE
                 X_CAI_NUMBER_TBL(i) := l_cai_num_tbl(p_trx_id_tbl(i));
                 X_CAI_DUE_DATE_TBL(i) := l_cai_due_date_tbl(p_trx_id_tbl(i));

        END IF;
          END LOOP;
     END IF;
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM_AR.END',
                                      'GET_CAI_NUM_AR(-)');
       END IF;


 EXCEPTION
     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM_AR',
                        'ZX_JL_EXTRACT_PKG.GET_CAI_NUM_AR : '||substrb(SQLERRM,1,120) );
                END IF;

       --    X_CAI_NUMBER_TBL(i) := NULL;

     WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_CAI_NUM_AR',
			'ZX_JL_EXTRACT_PKG.GET_CAI_NUM_AR : '||substrb(SQLERRM,1,120) );
		END IF;

END GET_CAI_NUM_AR;


PROCEDURE GET_FISCAL_PRINTER
(
P_TRX_ID_TBL                  IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_TAX_REGIME_CODE_TBL            IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
P_BILL_FROM_SITE_PROF_ID_TBL IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_SITE_ID_TBL          IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
X_FISCAL_PRINTER_TBL             OUT NOCOPY ATTRIBUTE20_TBL
) IS

  l_fiscal_printer_tbl            ATTRIBUTE20_TBL;
  l_rep_fiscal_printer_tbl        ATTRIBUTE20_TBL;
  l_err_msg                       VARCHAR2(120);

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER.BEGIN',
                                      'GET_FISCAL_PRINTER(+)');
   END IF;


    FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP

        IF l_fiscal_printer_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             null;
          ELSE
              l_fiscal_printer_tbl(p_trx_id_tbl(i)) := null;
          END IF;

          IF l_fiscal_printer_tbl(p_trx_id_tbl(i)) is null THEN
          BEGIN
            SELECT rep_ass.reporting_code_char_value
              INTO l_rep_fiscal_printer_tbl(i)
              FROM zx_reporting_types_b rep_type,
                   zx_report_codes_assoc rep_ass
             WHERE rep_type.reporting_type_code = 'FISCAL PRINTER'
               AND rep_ass.reporting_type_id = rep_type.reporting_type_id
               AND rep_ass.entity_code = 'ZX_PARTY_TAX_PROFILE'
               AND rep_ass.entity_id = P_BILL_FROM_SITE_PROF_ID_TBL(i)
               AND rep_type.tax_regime_code = P_TAX_REGIME_CODE_TBL(i);

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
            X_FISCAL_PRINTER_TBL(i):=NULL;
	    IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER',
					      'EXCEPTION : '||P_BILL_FROM_SITE_ID_TBL(i));
	    END IF;
     --       IF l_rep_fiscal_printer_tbl IS NULL  THEN
               SELECT global_attribute18
                 INTO l_fiscal_printer_tbl(i)
                 FROM ap_supplier_sites_all
               WHERE vendor_site_id = P_BILL_FROM_SITE_ID_TBL(i);
      --      END IF;
	    IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER',
					      'l_fiscal_printer : '||l_fiscal_printer_tbl(i));
	    END IF;
            X_FISCAL_PRINTER_TBL(i):=l_fiscal_printer_tbl(i);

           END;

          IF l_fiscal_printer_tbl(i) IS NULL THEN
             X_FISCAL_PRINTER_TBL(i):= NULL;
          ELSE
             X_FISCAL_PRINTER_TBL(i):=l_fiscal_printer_tbl(i);
          END IF;

       END IF;
     END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER.END',
                                      'GET_FISCAL_PRINTER(-)');
       END IF;

 EXCEPTION

     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER',
                        'ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER : '||substrb(SQLERRM,1,120) );
                END IF;
            -- X_FISCAL_PRINTER_TBL(i) :=  NULL;

     WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER',
			'ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER : '||substrb(SQLERRM,1,120) );
		END IF;

END GET_FISCAL_PRINTER;


PROCEDURE GET_TAXPAYERID_TYPE
(
P_TRX_ID_TBL                   IN ZX_EXTRACT_PKG.TRX_ID_TBL,
--P_TAX_REGIME_CODE_TBL        IN ZX_EXTRACT_PKG.TAX_REGIME_CODE_TBL,
--P_BILL_FROM_SITE_PROF_ID_TBL IN ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL,
P_BILL_FROM_TP_ID_TBL          IN ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS_ID_TBL,
X_TAXPAYERID_TYPE_TBL          OUT NOCOPY ATTRIBUTE21_TBL,
X_REG_STATUS_CODE_TBL          OUT NOCOPY ATTRIBUTE22_TBL
) IS

  l_taxpayerid_type_tbl            ATTRIBUTE21_TBL;
  l_reg_status_code_tbl            ATTRIBUTE22_TBL;
--  l_rep_fiscal_printer_tbl        ATTRIBUTE20_TBL;
  l_err_msg                       VARCHAR2(120);

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAXPAYERID_TYPE.BEGIN',
                                      'GET_TAXPAYERID_TYPE(+)');
   END IF;


    FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP

          IF l_taxpayerid_type_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             null;
          ELSE
              l_taxpayerid_type_tbl(p_trx_id_tbl(i)) := null;
              l_reg_status_code_tbl(p_trx_id_tbl(i)) := null;
          END IF;

          IF l_taxpayerid_type_tbl(p_trx_id_tbl(i)) is null THEN
          BEGIN
               SELECT global_attribute10, global_attribute1
                 INTO l_taxpayerid_type_tbl(p_trx_id_tbl(i)),
                      l_reg_status_code_tbl(p_trx_id_tbl(i))
                 FROM ap_suppliers
               WHERE vendor_id = P_BILL_FROM_TP_ID_TBL(i);

/*	    IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAXPAYERID_TYPE',
			'l_taxpayerid_type_tbl : '||l_taxpayerid_type_tbl(p_trx_id_tbl(i)));
	    END IF; */
            X_TAXPAYERID_TYPE_TBL(i):=l_taxpayerid_type_tbl(p_trx_id_tbl(i));
             X_REG_STATUS_CODE_TBL(i) := l_reg_status_code_tbl(p_trx_id_tbl(i));

           END;
          -- END IF;
          IF l_taxpayerid_type_tbl(p_trx_id_tbl(i)) IS NULL THEN
             X_TAXPAYERID_TYPE_TBL(i):= NULL;
             X_REG_STATUS_CODE_TBL(i) := NULL;
          ELSE
	    IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAXPAYERID_TYPE',
			'l_taxpayerid_type_tbl : '||to_char(i)||'-'||l_taxpayerid_type_tbl(p_trx_id_tbl(i)));
	    END IF;
             X_TAXPAYERID_TYPE_TBL(i):=l_taxpayerid_type_tbl(p_trx_id_tbl(i));
             X_REG_STATUS_CODE_TBL(i) := l_reg_status_code_tbl(p_trx_id_tbl(i));
          END IF;
       ELSE
             X_TAXPAYERID_TYPE_TBL(i):=l_taxpayerid_type_tbl(p_trx_id_tbl(i));
             X_REG_STATUS_CODE_TBL(i) := l_reg_status_code_tbl(p_trx_id_tbl(i));
       END IF;
     END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAXPAYERID_TYPE.END',
                                      'GET_TAXPAYERID_TYPE(-)');
       END IF;

 EXCEPTION

     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAXPAYERID_TYPE',
                        'ZX_JL_EXTRACT_PKG.GET_TAXPAYERID_TYPE : '||substrb(SQLERRM,1,120) );
                END IF;
            -- X_FISCAL_PRINTER_TBL(i) :=  NULL;

     WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TAXPAYERID_TYPE',
			'ZX_JL_EXTRACT_PKG.GET_TAXPAYERID_TYPE : '||substrb(SQLERRM,1,120) );
		END IF;

END GET_TAXPAYERID_TYPE;

PROCEDURE GET_FISCAL_PRINTER_AR
(
P_TRX_ID_TBL            IN  ZX_EXTRACT_PKG.TRX_ID_TBL,
P_BATCH_SOURCE_ID_TBL   IN  ZX_EXTRACT_PKG.BATCH_SOURCE_ID_TBL,
X_FISCAL_PRINTER_TBL    OUT NOCOPY GDF_RA_BATCH_SOURCES_ATT7_TBL
) IS

  l_fiscal_printer_tbl            GDF_RA_BATCH_SOURCES_ATT7_TBL;
  l_err_msg                       VARCHAR2(120);

BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER_AR.BEGIN',
                                      'GET_FISCAL_PRINTER_AR(+)');
   END IF;


    FOR i in 1..nvl(P_TRX_ID_TBL.last,0) LOOP

        IF l_fiscal_printer_tbl.EXISTS(p_trx_id_tbl(i)) THEN
             null;
          ELSE
              l_fiscal_printer_tbl(p_trx_id_tbl(i)) := null;
          END IF;

          IF l_fiscal_printer_tbl(p_trx_id_tbl(i)) is null THEN
          BEGIN
               SELECT global_attribute7
                 INTO l_fiscal_printer_tbl(i)
                 FROM ra_batch_sources_all
               WHERE batch_source_id = P_BATCH_SOURCE_ID_TBL(i);

	    IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER_AR',
					      'l_fiscal_printer : '||l_fiscal_printer_tbl(i));
	    END IF;
            X_FISCAL_PRINTER_TBL(i):=l_fiscal_printer_tbl(i);

           END;

      --   IF l_fiscal_printer_tbl(i) IS NULL THEN
       --      X_FISCAL_PRINTER_TBL(i):= NULL;
        --  ELSE
         --    X_FISCAL_PRINTER_TBL(i):=l_fiscal_printer_tbl(i);
          --END IF;

       END IF;
     END LOOP;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER_AR.END',
                                      'GET_FISCAL_PRINTER_AR(-)');
       END IF;

 EXCEPTION

     WHEN NO_DATA_FOUND THEN
               IF ( g_level_statement>= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER',
                        'ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER_AR : '||substrb(SQLERRM,1,120) );
                END IF;

     WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER',
			'ZX_JL_EXTRACT_PKG.GET_FISCAL_PRINTER : '||substrb(SQLERRM,1,120) );
		END IF;

END GET_FISCAL_PRINTER_AR;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GET_TOTAL_DOC_TAXABLE_AMOUNT                                            |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This function returns the Tax Authority Code                           |
 |    from jl_zz_ar_tx_categ table to  meet the requirement in the flat file |
 |                                                                           |
 |    Called from ZX_JL_EXTRACT_PKG.POPULATE_JL_AR                              |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  p_trx_id_tbl IN     ZX_EXTRACT_PKG.TRX_ID_TBL     Required|
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE GET_TOTAL_DOC_TAXABLE_AMOUNT
(
P_TRX_ID_TBL               IN         ZX_EXTRACT_PKG.TRX_ID_TBL,
P_REQUEST_ID               IN         NUMBER,
X_TOTAL_DOC_TAXAB_AMT_TBL  OUT NOCOPY NUMERIC8_TBL
)
IS

l_err_msg                  VARCHAR2(120);
l_total_doc_taxab_amt_tbl  NUMERIC8_TBL;

BEGIN

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TOTAL_DOC_TAXABLE_AMOUNT',
					      'GET_TOTAL_DOC_TAXABLE_AMOUNT(+) ');
	  END IF;

  FOR i in 1..nvl(p_trx_id_tbl.last,0) LOOP
      IF l_total_doc_taxab_amt_tbl.EXISTS(p_trx_id_tbl(i)) THEN
         NULL;
      ELSE
           l_total_doc_taxab_amt_tbl(p_trx_id_tbl(i)) := null;
      END IF;

      IF l_total_doc_taxab_amt_tbl(p_trx_id_tbl(i)) is NULL THEN

         BEGIN

             SELECT SUM(DECODE(DET.TAX_RATE,0,
					    0,
					    coalesce(DET.TAXABLE_AMT_FUNCL_CURR,DET.TAXABLE_AMT,0)))
               INTO l_total_doc_taxab_amt_tbl(p_trx_id_tbl(i))
               FROM ZX_REP_TRX_DETAIL_T DET
              WHERE REQUEST_ID = P_REQUEST_ID
                AND TRX_ID = p_trx_id_tbl(i);

              X_TOTAL_DOC_TAXAB_AMT_TBL(i) := l_total_doc_taxab_amt_tbl(p_trx_id_tbl(i));

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  l_total_doc_taxab_amt_tbl(p_trx_id_tbl(i)) := 0;
                  X_TOTAL_DOC_TAXAB_AMT_TBL(i) := l_total_doc_taxab_amt_tbl(p_trx_id_tbl(i));
                  null;
             WHEN OTHERS THEN
                  l_err_msg := substrb(SQLERRM,1,120);
		IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TOTAL_DOC_TAXABLE_AMOUNT',
			'EXCEPTION raised in ' ||'GET_TOTAL_DOC_TAXABLE_AMOUNT: ' ||SQLCODE ||':'||l_err_msg);
		END IF;

         END;

      ELSE

          X_TOTAL_DOC_TAXAB_AMT_TBL(i) := l_total_doc_taxab_amt_tbl(p_trx_id_tbl(i));

      END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JL_EXTRACT_PKG',
	' X_TOTAL_DOC_TAXAB_AMT_TBL for i: '||i||' trx_id : '||to_char(p_trx_id_tbl(i))||' is : '||to_char(X_TOTAL_DOC_TAXAB_AMT_TBL(i)));
    END IF;

   END LOOP;
	  IF (g_level_procedure >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JL_EXTRACT_PKG.GET_TOTAL_DOC_TAXABLE_AMOUNT',
					      'GET_TOTAL_DOC_TAXABLE_AMOUNT(-) ');
	  END IF;

END GET_TOTAL_DOC_TAXABLE_AMOUNT;


     PROCEDURE initialize_variables (
                      p_count   IN         NUMBER) IS
            i number;
     BEGIN
/*
              FOR i IN 1.. p_count LOOP
            l_detail_tax_line_id_tbl(i)  := NULL;
            l_trx_id_tbl(i)      := NULL;
            l_trx_number_tbl(i)      := NULL;
            l_trx_type_id_tbl(i)      := NULL;
            l_tax_rate_tbl(i)      := NULL;
            l_tax_rate_id_tbl(i)      := NULL;
            l_document_sub_type_tbl(i)      := NULL;
            l_exchange_rate_tbl(i)      := NULL;

            l_not_reg_tax_amt_tbl(i)      := NULL;
            l_vat_exempt_amt_tbl(i)      := NULL;
            l_vat_perc_amt_tbl(i)      := NULL;
            l_prov_perc_amt_tbl(i)      := NULL;
            l_munic_perc_amt_tbl(i)      := NULL;
            l_excise_amt_tbl(i)      := NULL;
            l_other_tax_amt_tbl(i)      := NULL;
            l_non_taxable_amt_tbl(i)      := NULL;
            l_vat_amt_tbl(i)      := NULL;
            l_taxable_amt_tbl(i)      := NULL;
            l_vat_additional_amt_tbl(i)      := NULL;
            l_total_doc_amt_tbl(i)      := NULL;
            l_rec_count_tbl(i)      := NULL;
            l_rate_count_tbl(i)      := NULL;

            l_tax_authority_code := NULL;
            l_dgi_code_tbl(i)      := NULL;
            l_cust_condition_code_tbl(i)      := NULL;
            l_vat_reg_stat_code_tbl(i)      := NULL;

        END LOOP;
    */
NULL;

     END initialize_variables ;


END ZX_JL_EXTRACT_PKG;

/
