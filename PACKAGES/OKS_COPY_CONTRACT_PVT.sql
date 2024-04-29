--------------------------------------------------------
--  DDL for Package OKS_COPY_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COPY_CONTRACT_PVT" AUTHID CURRENT_USER AS
/*$Header: OKSCOPYS.pls 120.35.12010000.2 2008/10/22 12:49:31 ssreekum ship $*/


    SUBTYPE chrv_rec_type IS		OKC_CONTRACT_PUB.chrv_rec_type;
    SUBTYPE chrv_tbl_type IS		OKC_CONTRACT_PUB.chrv_tbl_type;
    SUBTYPE clev_rec_type IS		OKC_CONTRACT_PUB.clev_rec_type;
    SUBTYPE clev_tbl_type IS		OKC_CONTRACT_PUB.clev_tbl_type;
    SUBTYPE cacv_rec_type IS		OKC_CONTRACT_PUB.cacv_rec_type;
    SUBTYPE cacv_tbl_type IS		OKC_CONTRACT_PUB.cacv_tbl_type;
    SUBTYPE cpsv_rec_type IS 		OKC_CONTRACT_PUB.cpsv_rec_type;
    SUBTYPE cpsv_tbl_type IS 		OKC_CONTRACT_PUB.cpsv_tbl_type;
    SUBTYPE catv_rec_type IS 		OKC_K_ARTICLE_PUB.catv_rec_type;
    SUBTYPE catv_tbl_type IS 		OKC_K_ARTICLE_PUB.catv_tbl_type;
    SUBTYPE atnv_rec_type IS 		OKC_K_ARTICLE_PUB.atnv_rec_type;
    SUBTYPE atnv_tbl_type IS 		OKC_K_ARTICLE_PUB.atnv_tbl_type;
    SUBTYPE cnhv_rec_type IS 		OKC_CONDITIONS_PUB.cnhv_rec_type;
    SUBTYPE cnhv_tbl_type IS 		OKC_CONDITIONS_PUB.cnhv_tbl_type;
    SUBTYPE cnlv_rec_type IS 		OKC_CONDITIONS_PUB.cnlv_rec_type;
    SUBTYPE cnlv_tbl_type IS 		OKC_CONDITIONS_PUB.cnlv_tbl_type;
    SUBTYPE cimv_rec_type IS 		OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    SUBTYPE cimv_tbl_type IS 		OKC_CONTRACT_ITEM_PUB.cimv_tbl_type;
    SUBTYPE cplv_rec_type IS 		OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    SUBTYPE cplv_tbl_type IS 		OKC_CONTRACT_PARTY_PUB.cplv_tbl_type;
    SUBTYPE cgcv_rec_type IS 		OKC_CONTRACT_GROUP_PUB.cgcv_rec_type;
    SUBTYPE cgcv_tbl_type IS 		OKC_CONTRACT_GROUP_PUB.cgcv_tbl_type;
    SUBTYPE ctcv_rec_type IS 		OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;
    SUBTYPE ctcv_tbl_type IS 		OKC_CONTRACT_PARTY_PUB.ctcv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQ';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKS';
  G_APP_ID			CONSTANT NUMBER	       := 515;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_COPY_CONTRACT_PVT';
  G_BULK_FETCH_LIMIT NUMBER := 1000;
  HexFormatStr VARCHAR2(100) := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

  ---------------------------------------------------------------------------
/*
  TYPE 	api_components_rec IS RECORD(id             NUMBER,
                                         to_k	        NUMBER,
                                         component_type VARCHAR2(30),
                                         attribute1     VARCHAR2(100));
  TYPE	api_components_tbl IS TABLE OF api_components_rec
  INDEX	BY BINARY_INTEGER;

  TYPE 	api_lines_rec IS RECORD(id             NUMBER,
                                    to_k           NUMBER,
                                    to_line        NUMBER,
							 lse_id         NUMBER,
                                    line_exists_yn VARCHAR2(1),
				    line_exp_yn VARCHAR2(1));  --Bug 3990643
  TYPE	api_lines_tbl IS TABLE OF api_lines_rec
  INDEX	BY BINARY_INTEGER;
*/

  TYPE published_line_ids_rec IS RECORD(old_line_id NUMBER
				       ,new_line_id NUMBER);

  TYPE published_line_ids_tbl IS TABLE OF published_line_ids_rec
  INDEX BY BINARY_INTEGER;

  SUBTYPE       api_components_tbl IS OKC_COPY_CONTRACT_PVT.api_components_tbl;
  SUBTYPE       api_lines_tbl      IS OKC_COPY_CONTRACT_PVT.api_lines_tbl;


  ------------------------------Data Types added for 12.0 Copy--------------------------

 --------Table Datatypes for Common Columns--------
 TYPE NumTabType                IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE FlagTabType               IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
 TYPE YNTabType                 IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
 TYPE DateTabType               IS TABLE OF DATE INDEX BY BINARY_INTEGER;
 TYPE OrigSystemRef1TabType     IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE OrigSystemSourceCodeTabType IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE UpgOrigSystemRefTabType   IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;
 TYPE LanguageTabType           IS TABLE OF VARCHAR2(12) INDEX BY BINARY_INTEGER;
 TYPE AttributeCategoryTabType  IS TABLE OF VARCHAR2(90) INDEX BY BINARY_INTEGER;
 TYPE AttributeTabType          IS TABLE OF VARCHAR2(450) INDEX BY BINARY_INTEGER;
 TYPE Object1ID1TabType         IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;
 TYPE Object1ID2TabType         IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
 TYPE JTOTObject1CodeTabType    IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE CognomenTabType		IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;
 TYPE Varchar2_30_TabType	IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE Varchar2_40_TabType	IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;
 TYPE Varchar2_90_TabType	IS TABLE OF VARCHAR2(90) INDEX BY BINARY_INTEGER;
 TYPE Varchar2_240_TabType	IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
 TYPE Varchar2_450_TabType	IS TABLE OF VARCHAR2(450) INDEX BY BINARY_INTEGER;
 TYPE Varchar2_2000_TabType	IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


  TYPE ApiLinesRecTabType IS RECORD(
    IDTab   NumTabType
   ,ToKTab  NumTabType
   ,ToLineTab NumTabType
   ,LineExistsYNTab	FlagTabType
   ,LineExpYNTab	FlagTabType
  );

  ApiLinesRecTab  ApiLinesRecTabType;

 --------Table datatypes for OKC_K_LINES_B columns------------
 TYPE OkcB_LineNumberTabType            IS TABLE OF OKC_K_LINES_B.LINE_NUMBER%TYPE;
 TYPE OkcB_DisplaySequenceTabType       IS TABLE OF OKC_K_LINES_B.DISPLAY_SEQUENCE%TYPE;
 TYPE OkcB_StsCodeTabType               IS TABLE OF OKC_K_LINES_B.STS_CODE%TYPE;
 TYPE OkcB_TrnCodeTabType               IS TABLE OF OKC_K_LINES_B.TRN_CODE%TYPE;
 TYPE OkcB_LseIDTabType                 IS TABLE OF OKC_K_LINES_B.LSE_ID%TYPE;
 TYPE OkcB_ObjVersionNumTabType         IS TABLE OF OKC_K_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
 TYPE OkcB_DpasRatingTabType            IS TABLE OF OKC_K_LINES_B.DPAS_RATING%TYPE;
 TYPE OkcB_TemplateUsedTabType  IS TABLE OF OKC_K_LINES_B.TEMPLATE_USED%TYPE;
 TYPE OkcB_PriceTypeTabType             IS TABLE OF OKC_K_LINES_B.PRICE_TYPE%TYPE;
 TYPE OkcB_CurrencyCodeTabType  IS TABLE OF OKC_K_LINES_B.CURRENCY_CODE%TYPE;
 TYPE OkcB_ConfigItemTypeTabType        IS TABLE OF OKC_K_LINES_B.CONFIG_ITEM_TYPE%TYPE;
 TYPE OkcB_PhPricingTypeTabType IS TABLE OF OKC_K_LINES_B.PH_PRICING_TYPE%TYPE;
 TYPE OkcB_PhPriceBreakBasisTabType     IS TABLE OF OKC_K_LINES_B.PH_PRICE_BREAK_BASIS%TYPE;
 TYPE OkcB_LineRenewTypeCodeTabType     IS TABLE OF OKC_K_LINES_B.LINE_RENEWAL_TYPE_CODE%TYPE;
 TYPE OkcB_TermCancelSourceTabType      IS TABLE OF OKC_K_LINES_B.TERM_CANCEL_SOURCE%TYPE;

 ------Table datatypes for OKS_K_LINES_B columns---------------
 TYPE OksB_LimitUOMQuantifyTabType      IS TABLE OF OKS_K_LINES_B.LIMIT_UOM_QUANTIFIED%TYPE;
 TYPE OksB_OffsetPeriodTabType          IS TABLE OF OKS_K_LINES_B.OFFSET_PERIOD%TYPE;
 TYPE OksB_TransferOptionTabType        IS TABLE OF OKS_K_LINES_B.TRANSFER_OPTION%TYPE;
 TYPE OksB_InheritanceTypeTabType       IS TABLE OF OKS_K_LINES_B.INHERITANCE_TYPE%TYPE;
 TYPE OksB_PaymentTypeTabType           IS TABLE OF OKS_K_LINES_B.PAYMENT_TYPE%TYPE;
 TYPE OksB_CCNOTabType                  IS TABLE OF OKS_K_LINES_B.CC_NO%TYPE;
 TYPE OksB_CCAuthCodeTabType            IS TABLE OF OKS_K_LINES_B.CC_AUTH_CODE%TYPE;
 TYPE OksB_UsageEstMethodTabType        IS TABLE OF OKS_K_LINES_B.USAGE_EST_METHOD%TYPE;
 TYPE OksB_TermnMethodTabType           IS TABLE OF OKS_K_LINES_B.TERMN_METHOD%TYPE;
 TYPE OksB_CustPONumberTabType          IS TABLE OF OKS_K_LINES_B.CUST_PO_NUMBER%TYPE;
 TYPE OksB_GracePeriodTabType           IS TABLE OF OKS_K_LINES_B.GRACE_PERIOD%TYPE;
 TYPE OksB_PriceUOMTabType              IS TABLE OF OKS_K_LINES_B.PRICE_UOM%TYPE;
 TYPE OksB_TaxStatusTabType             IS TABLE OF OKS_K_LINES_B.TAX_STATUS%TYPE;
 TYPE OksB_IBTransTypeTabType           IS TABLE OF OKS_K_LINES_B.IB_TRANS_TYPE%TYPE;
 TYPE OksB_ClvlUOMCodeTabType           IS TABLE OF OKS_K_LINES_B.CLVL_UOM_CODE%TYPE;
 TYPE OksB_TopLVLOperandCodeTabType     IS TABLE OF OKS_K_LINES_B.TOPLVL_OPERAND_CODE%TYPE;
 TYPE OksB_TOPLVLUOMCodeTabType         IS TABLE OF OKS_K_LINES_B.TOPLVL_UOM_CODE%TYPE;
 TYPE OksB_SettlemntIntervalTabType     IS TABLE OF OKS_K_LINES_B.SETTLEMENT_INTERVAL%TYPE;
 TYPE OksB_UsagePeriodTabType           IS TABLE OF OKS_K_LINES_B.USAGE_PERIOD%TYPE;
 TYPE OksB_UsageTypeTabType             IS TABLE OF OKS_K_LINES_B.USAGE_TYPE%TYPE;
 TYPE OksB_UOMQuantifiedTabType         IS TABLE OF OKS_K_LINES_B.UOM_QUANTIFIED%TYPE;
 TYPE OksB_BillScheduleTypeTabType      IS TABLE OF OKS_K_LINES_B.BILLING_SCHEDULE_TYPE%TYPE;
 TYPE OksB_FullCreditTabType            IS TABLE OF OKS_K_LINES_B.FULL_CREDIT%TYPE;
 TYPE OksB_BreakUOMTabType              IS TABLE OF OKS_K_LINES_B.BREAK_UOM%TYPE;
 TYPE OksB_ProrateTabType               IS TABLE OF OKS_K_LINES_B.PRORATE%TYPE;
 TYPE OksB_CoverageTypeTabType          IS TABLE OF OKS_K_LINES_B.COVERAGE_TYPE%TYPE;
 TYPE OksB_TaxClassfnCodeTabType        IS TABLE OF OKS_K_LINES_B.TAX_CLASSIFICATION_CODE%TYPE;
 TYPE OksB_ExemptCertNumTabType         IS TABLE OF OKS_K_LINES_B.EXEMPT_CERTIFICATE_NUMBER%TYPE;
 TYPE OksB_ExemptReasonCodeTabType      IS TABLE OF OKS_K_LINES_B.EXEMPT_REASON_CODE%TYPE;

 ---Table datatypes for OKC_K_ITEMS columns--------------------
 TYPE OkcI_UOMCodeTabType               IS TABLE OF OKC_K_ITEMS.UOM_CODE%TYPE;
 TYPE OkcI_ExceptionYNTabType           IS TABLE OF OKC_K_ITEMS.EXCEPTION_YN%TYPE;
 TYPE OkcI_PricedItemYNTabType  IS TABLE OF OKC_K_ITEMS.PRICED_ITEM_YN%TYPE;

 -----------Start of Record of Tables Data Type for columns in OKC_K_LINES_B,OKS_K_LINES_B,OKC_K_ITEMS------------
 TYPE OKCOKSLinesRecTabType IS RECORD
 (
 -----------Start of Record Members for OKC_K_LINES_B columns------------
  OkcB_OldOKCLineID             NumTabType
 ,OkcB_NewOKCLineID       NumTabType
 ,OkcB_LINE_NUMBER              OkcB_LineNumberTabType
 ,OkcB_NewChrID         NumTabType
 ,OkcB_CLE_ID           NumTabType
 ,OkcB_NewDnzChrID      NumTabType
 ,OkcB_DISPLAY_SEQUENCE         OkcB_DisplaySequenceTabType
 ,OkcB_STS_CODE                 OkcB_StsCodeTabType
 ,OkcB_TRN_CODE          OkcB_TrnCodeTabType
 ,OkcB_LSE_ID           NumTabType
 ,OkcB_EXCEPTION_YN     YNTabType
 ,OkcB_OBJECT_VERSION_NUMBER    NumTabType
 ,OkcB_HIDDEN_IND               YNTabType
 ,OkcB_PRICE_NEGOTIATED         NumTabType
 ,OkcB_PRICE_LEVEL_IND  YNTabType
 ,OkcB_PRICE_UNIT               NumTabType
 ,OkcB_PRICE_UNIT_PERCENT NumTabType
 ,OkcB_INVOICE_LINE_LEVEL_IND   YNTabType
 ,OkcB_DPAS_RATING              OkcB_DpasRatingTabType
 ,OkcB_TEMPLATE_USED    OkcB_TemplateUsedTabType
 ,OkcB_PRICE_TYPE               OkcB_PriceTypeTabType
 ,OkcB_CURRENCY_CODE    OkcB_CurrencyCodeTabType
 ,OkcB_DATE_TERMINATED   DateTabType
 ,OkcB_START_DATE               DateTabType
 ,OkcB_END_DATE         DateTabType
 ,OkcB_ATTRIBUTE_CATEGORY AttributeCategoryTabType
 ,OkcB_ATTRIBUTE1               AttributeTabType
 ,OkcB_ATTRIBUTE2               AttributeTabType
 ,OkcB_ATTRIBUTE3               AttributeTabType
 ,OkcB_ATTRIBUTE4               AttributeTabType
 ,OkcB_ATTRIBUTE5               AttributeTabType
 ,OkcB_ATTRIBUTE6               AttributeTabType
 ,OkcB_ATTRIBUTE7               AttributeTabType
 ,OkcB_ATTRIBUTE8               AttributeTabType
 ,OkcB_ATTRIBUTE9               AttributeTabType
 ,OkcB_ATTRIBUTE10              AttributeTabType
 ,OkcB_ATTRIBUTE11              AttributeTabType
 ,OkcB_ATTRIBUTE12              AttributeTabType
 ,OkcB_ATTRIBUTE13              AttributeTabType
 ,OkcB_ATTRIBUTE14              AttributeTabType
 ,OkcB_ATTRIBUTE15              AttributeTabType
 ,OkcB_SECURITY_GROUP_ID                NumTabType
 ,OkcB_PRICE_NEGOTIATED_RENEWED         NumTabType
 ,OkcB_CURRENCY_CODE_RENEWED            OkcB_CurrencyCodeTabType
 ,OkcB_UPG_ORIG_SYSTEM_REF              UpgOrigSystemRefTabType
 ,OkcB_UPG_ORIG_SYSTEM_REF_ID           NumTabType
 ,OkcB_DATE_RENEWED                     DateTabType
 ,OkcB_ORIG_SYSTEM_ID1          NumTabType
 ,OkcB_ORIG_SYSTEM_REFERENCE1   OrigSystemRef1TabType
 ,OkcB_ORIG_SYSTEM_SOURCE_CODE  OrigSystemSourceCodeTabType
 ,OkcB_PROGRAM_APPLICATION_ID           NumTabType
 ,OkcB_PROGRAM_ID                               NumTabType
 ,OkcB_PROGRAM_UPDATE_DATE              DateTabType
 ,OkcB_REQUEST_ID                               NumTabType
 ,OkcB_PRICE_LIST_ID                    NumTabType
 ,OkcB_PRICE_LIST_LINE_ID               NumTabType
 ,OkcB_LINE_LIST_PRICE                  NumTabType
 ,OkcB_ITEM_TO_PRICE_YN                 YNTabType
 ,OkcB_PRICING_DATE                     DateTabType
 ,OkcB_PRICE_BASIS_YN                   YNTabType
 ,OkcB_CONFIG_HEADER_ID                 NumTabType
 ,OkcB_CONFIG_REVISION_NUMBER           NumTabType
 ,OkcB_CONFIG_COMPLETE_YN               YNTabType
 ,OkcB_CONFIG_VALID_YN                  YNTabType
 ,OkcB_CONFIG_TOP_MODEL_LINE_ID NumTabType
 ,OkcB_CONFIG_ITEM_TYPE                 OkcB_ConfigItemTypeTabType
 ,OkcB_CONFIG_ITEM_ID                   NumTabType
 ,OkcB_SERVICE_ITEM_YN                  YNTabType
 ,OkcB_PH_PRICING_TYPE                  OkcB_PhPricingTypeTabType
 ,OkcB_PH_PRICE_BREAK_BASIS             OkcB_PhPriceBreakBasisTabType
 ,OkcB_PH_MIN_QTY                               NumTabType
 ,OkcB_PH_MIN_AMT                               NumTabType
 ,OkcB_PH_QP_REFERENCE_ID               NumTabType
 ,OkcB_PH_VALUE                         NumTabType
 ,OkcB_PH_ENFORCE_PRICE_LIST_YN FlagTabType
 ,OkcB_PH_ADJUSTMENT                    NumTabType
 ,OkcB_PH_INTEGRATED_WITH_QP            FlagTabType
 ,OkcB_CUST_ACCT_ID                     NumTabType
 ,OkcB_BILL_TO_SITE_USE_ID              NumTabType
 ,OkcB_INV_RULE_ID                              NumTabType
 ,OkcB_LINE_RENEWAL_TYPE_CODE           OkcB_LineRenewTypeCodeTabType
 ,OkcB_SHIP_TO_SITE_USE_ID              NumTabType
 ,OkcB_PAYMENT_TERM_ID                  NumTabType
 ,OkcB_DATE_CANCELLED                   DateTabType
 ,OkcB_TERM_CANCEL_SOURCE               OkcB_TermCancelSourceTabType
 ,OkcB_ANNUALIZED_FACTOR                NumTabType
 ,OkcB_PAYMENT_INSTRUCTION_TYPE         YNTabType
 ,OkcB_CANCELLED_AMOUNT			NumTabType
 ,OkcB_LINE_CANCELLED_FLAG		FlagTabType
 ,OkcB_LINE_TERMINATED_FLAG		FlagTabType
 -----------------End of record members for OKC_K_LINES_B columns
 -----------------Start of record members for OKS_K_LINES_B columns
 ,OksB_OldOksLineID  NumTabType
 ,OksB_NewOksLineID     NumTabType
 ,OksB_CLE_ID           NumTabType
 ,OksB_NewDnzChrID              NumTabType
 ,OksB_DISCOUNT_LIST    NumTabType
 ,OksB_ACCT_RULE_ID     NumTabType
 ,OksB_PAYMENT_TYPE     OksB_PaymentTypeTabType
 ,OksB_CC_NO                    OksB_CCNOTabType
 ,OksB_CC_EXPIRY_DATE   DateTabType
 ,OksB_CC_BANK_ACCT_ID  NumTabType
 ,OksB_CC_AUTH_CODE     OksB_CCAuthCodeTabType
 ,OksB_COMMITMENT_ID    NumTabType
 ,OksB_LOCKED_PRICE_LIST_ID     NumTabType
 ,OksB_USAGE_EST_YN     FlagTabType
 ,OksB_USAGE_EST_METHOD OksB_UsageEstMethodTabType
 ,OksB_USAGE_EST_START_DATE     DateTabType
 ,OksB_TERMN_METHOD     OksB_TermnMethodTabType
 ,OksB_UBT_AMOUNT               NumTabType
 ,OksB_CREDIT_AMOUNT    NumTabType
 ,OksB_SUPPRESSED_CREDIT NumTabType
 ,OksB_OVERRIDE_AMOUNT  NumTabType
 ,OksB_CUST_PO_NUMBER_REQ_YN    FlagTabType
 ,OksB_CUST_PO_NUMBER   OksB_CustPONumberTabType
 ,OksB_GRACE_DURATION   NumTabType
 ,OksB_GRACE_PERIOD     OksB_GracePeriodTabType
 ,OksB_INV_PRINT_FLAG   FlagTabType
 ,OksB_PRICE_UOM                OksB_PriceUOMTabType
 ,OksB_TAX_AMOUNT               NumTabType
 ,OksB_TAX_INCLUSIVE_YN FlagTabType
 ,OksB_TAX_STATUS               OksB_TaxStatusTabType
 ,OksB_TAX_CODE         NumTabType
 ,OksB_TAX_EXEMPTION_ID NumTabType
 ,OksB_IB_TRANS_TYPE    OksB_IBTransTypeTabType
 ,OksB_IB_TRANS_DATE    DateTabType
 ,OksB_PROD_PRICE               NumTabType
 ,OksB_SERVICE_PRICE    NumTabType
 ,OksB_CLVL_LIST_PRICE  NumTabType
 ,OksB_CLVL_QUANTITY    NumTabType
 ,OksB_CLVL_EXTENDED_AMT        NumTabType
 ,OksB_CLVL_UOM_CODE    OksB_ClvlUOMCodeTabType
 ,OksB_TOPLVL_OPERAND_CODE OksB_TopLVLOperandCodeTabType
 ,OksB_TOPLVL_OPERAND_VAL NumTabType
 ,OksB_TOPLVL_QUANTITY   NumTabType
 ,OksB_TOPLVL_UOM_CODE  OksB_TopLVLUOMCodeTabType
 ,OksB_TOPLVL_ADJ_PRICE NumTabType
 ,OksB_TOPLVL_PRICE_QTY NumTabType
 ,OksB_AVERAGING_INTERVAL       NumTabType
 ,OksB_SETTLEMENT_INTERVAL      OksB_SettlemntIntervalTabType
 ,OksB_MINIMUM_QUANTITY         NumTabType
 ,OksB_DEFAULT_QUANTITY         NumTabType
 ,OksB_AMCV_FLAG                        FlagTabType
 ,OksB_FIXED_QUANTITY           NumTabType
 ,OksB_USAGE_DURATION           NumTabType
 ,OksB_USAGE_PERIOD             OksB_UsagePeriodTabType
 ,OksB_LEVEL_YN                 FlagTabType
 ,OksB_USAGE_TYPE                       OksB_UsageTypeTabType
 ,OksB_UOM_QUANTIFIED           OksB_UOMQuantifiedTabType
 ,OksB_BASE_READING             NumTabType
 ,OksB_BILLING_SCHEDULE_TYPE    OksB_BillScheduleTypeTabType
 ,OksB_FULL_CREDIT              OksB_FullCreditTabType
 ,OksB_LOCKED_PRICE_LIST_LINE_ID NumTabType
 ,OksB_BREAK_UOM                OksB_BreakUOMTabType
 ,OksB_PRORATE                  OksB_ProrateTabType
 ,OksB_COVERAGE_TYPE            OksB_CoverageTypeTabType
 ,OksB_EXCEPTION_COV_ID         NumTabType
 ,OksB_LIMIT_UOM_QUANTIFIED     OksB_LimitUOMQuantifyTabType
 ,OksB_DISCOUNT_AMOUNT          NumTabType
 ,OksB_DISCOUNT_PERCENT         NumTabType
 ,OksB_OFFSET_DURATION          NumTabType
 ,OksB_OFFSET_PERIOD            OksB_OffsetPeriodTabType
 ,OksB_INCIDENT_SEVERITY_ID     NumTabType
 ,OksB_PDF_ID                   NumTabType
 ,OksB_WORK_THRU_YN             FlagTabType
 ,OksB_REACT_ACTIVE_YN          FlagTabType
 ,OksB_TRANSFER_OPTION          OksB_TransferOptionTabType
 ,OksB_PROD_UPGRADE_YN          FlagTabType
 ,OksB_INHERITANCE_TYPE         OksB_InheritanceTypeTabType
 ,OksB_PM_PROGRAM_ID            NumTabType
 ,OksB_PM_CONF_REQ_YN           FlagTabType
 ,OksB_PM_SCH_EXISTS_YN         FlagTabType
 ,OksB_ALLOW_BT_DISCOUNT        FlagTabType
 ,OksB_APPLY_DEFAULT_TIMEZONE   FlagTabType
 ,OksB_SYNC_DATE_INSTALL        FlagTabType
 ,OksB_OBJECT_VERSION_NUMBER    NumTabType
 ,OksB_SECURITY_GROUP_ID        NumTabType
 ,OksB_REQUEST_ID               NumTabType
 ,OksB_ORIG_SYSTEM_ID1          NumTabType
 ,OksB_ORIG_SYSTEM_REFERENCE1   OrigSystemRef1TabType
 ,OksB_ORIG_SYSTEM_SOURCE_CODE OrigSystemSourceCodeTabType
 ,OksB_TRXN_EXTENSION_ID        NumTabType
 ,OksB_TAX_CLASSIFICATION_CODE  OksB_TaxClassfnCodeTabType
 ,OksB_EXEMPT_CERTIFICATE_NUMBER OksB_ExemptCertNumTabType
 ,OksB_EXEMPT_REASON_CODE       OksB_ExemptReasonCodeTabType
 ,OksB_COVERAGE_ID              NumTabType
 ,OksB_STANDARD_COV_YN          FlagTabType
 -----------------End of record members for OKS_K_LINES_B columns
 -----------------Start of record members for OKC_K_ITEMS columns
 ,OkcI_OldOkcItemID             NumTabType
 ,OkcI_NewOkcItemID             NumTabType
 ,OkcI_CLE_ID                   NumTabType
 ,OkcI_NewDnzChrID                      NumTabType
 ,OkcI_NewChrID                 NumTabType
 ,OkcI_OBJECT1_ID1              Object1ID1TabType
 ,OkcI_OBJECT1_ID2              Object1ID2TabType
 ,OkcI_JTOT_OBJECT1_CODE        JTOTObject1CodeTabType
 ,OkcI_UOM_CODE                 OkcI_UOMCodeTabType
 ,OkcI_EXCEPTION_YN             OkcI_ExceptionYNTabType
 ,OkcI_NUMBER_OF_ITEMS          NumTabType
 ,OkcI_PRICED_ITEM_YN           OkcI_PricedItemYNTabType
 ,OkcI_OBJECT_VERSION_NUMBER    NumTabType
 ,OkcI_SECURITY_GROUP_ID                NumTabType
 ,OkcI_UPG_ORIG_SYSTEM_REF      UpgOrigSystemRefTabType
 ,OkcI_UPG_ORIG_SYSTEM_REF_ID   NumTabType
 ,Okc_PROGRAM_APPLICATION_ID   NumTabType
 ,OkcI_PROGRAM_ID                    NumTabType
 ,OkcI_PROGRAM_UPDATE_DATE           DateTabType
 ,OkcI_REQUEST_ID                    NumTabType
 );
--------End of Record of Tables datatype for columns in OKC_K_LINES_B,OKS_K_LINES_B,OKC_K_ITEMS-----------------------
 OKCOKSLinesRecTab OKCOKSLinesRecTabType;

  --------Table datatypes for OKC_K_LINES_TL columns------------
 TYPE OkcTL_NameTabType            IS TABLE OF OKC_K_LINES_TL.NAME%TYPE;
 TYPE OkcTL_CommentsTabType        IS TABLE OF OKC_K_LINES_TL.COMMENTS%TYPE;
 TYPE OkcTL_ItemDescTabType        IS TABLE OF OKC_K_LINES_TL.ITEM_DESCRIPTION%TYPE;
 TYPE OkcTL_Block23TxtTabType      IS TABLE OF OKC_K_LINES_TL.BLOCK23TEXT%TYPE;
 TYPE OkcTL_OkeBoeDescTabType      IS TABLE OF OKC_K_LINES_TL.OKE_BOE_DESCRIPTION%TYPE;

 --------Record of Tables datatype for OKC_K_LINES_TL------------
 TYPE OKCLinesTLRecTabType IS RECORD
 (
  OkcTL_OldID           NumTabType
 ,OkcTL_NewID           NumTabType
 ,OkcTL_LANGUAGE        LanguageTabType
 ,OkcTL_SOURCE_LANG     LanguageTabType
 ,OkcTL_SFWT_FLAG       YNTabType
 ,OkcTL_NAME            OkcTL_NameTabType
 ,OkcTL_COMMENTS        OkcTL_CommentsTabType
 ,OkcTL_ITEM_DESCRIPTION OkcTL_ItemDescTabType
 ,OkcTL_BLOCK23TEXT      OkcTL_Block23TxtTabType
 ,OkcTL_SECURITY_GROUP_ID NumTabType
 ,OkcTL_OKE_BOE_DESCRIPTION OkcTL_OkeBoeDescTabType
 ,OkcTL_COGNOMEN        CognomenTabType
 );

 --------End of Record of Tables datatype for OKC_K_LINES_TL
 OKCLinesTLRecTab       OKCLinesTLRecTabType;

 ------Table datatypes for OKC_K_PARTY_ROLES_B columns------------
 TYPE OkcPRB_RLECodeTabType     	IS TABLE OF OKC_K_PARTY_ROLES_B.RLE_CODE%TYPE;
 TYPE OkcPRB_CodeTabType		IS TABLE OF OKC_K_PARTY_ROLES_B.CODE%TYPE;
 TYPE OkcPRB_FacilityTabType		IS TABLE OF OKC_K_PARTY_ROLES_B.FACILITY%TYPE;
 TYPE OkcPRB_MinorGrpLkupCodeTabType 	IS TABLE OF OKC_K_PARTY_ROLES_B.MINORITY_GROUP_LOOKUP_CODE%TYPE;

 ------Record of Tables datatype for OKC_K_PARTY_ROLES_B----------
 TYPE OkcPRBRecTabType IS RECORD
 (OkcPRB_OldID				NumTabType
 ,OkcPRB_NewID				NumTabType
 ,OkcPRB_NewChrID			NumTabType
 ,OkcPRB_NewCleID			NumTabType
 ,OkcPRB_NewDnzChrID			NumTabType
 ,OkcPRB_RLE_CODE			OkcPRB_RLECodeTabType
 ,OkcPRB_OBJECT1_ID1			Object1ID1TabType
 ,OkcPRB_OBJECT1_ID2			Object1ID2TabType
 ,OkcPRB_JTOT_OBJECT1_CODE		JTOTObject1CodeTabType
 ,OkcPRB_OBJECT_VERSION_NUMBER		NumTabType
 ,OkcPRB_CODE				OkcPRB_CodeTabType
 ,OkcPRB_FACILITY			OkcPRB_FacilityTabType
 ,OkcPRB_MINOR_GROUP_LOOKUP_CODE        OkcPRB_MinorGrpLkupCodeTabType
 ,OkcPRB_SMALL_BUSINESS_FLAG		YNTabType
 ,OkcPRB_WOMEN_OWNED_FLAG		YNTabType
 ,OkcPRB_ATTRIBUTE_CATEGORY		AttributeCategoryTabType
 ,OkcPRB_ATTRIBUTE1			AttributeTabType
 ,OkcPRB_ATTRIBUTE2			AttributeTabType
 ,OkcPRB_ATTRIBUTE3			AttributeTabType
 ,OkcPRB_ATTRIBUTE4			AttributeTabType
 ,OkcPRB_ATTRIBUTE5			AttributeTabType
 ,OkcPRB_ATTRIBUTE6			AttributeTabType
 ,OkcPRB_ATTRIBUTE7			AttributeTabType
 ,OkcPRB_ATTRIBUTE8			AttributeTabType
 ,OkcPRB_ATTRIBUTE9			AttributeTabType
 ,OkcPRB_ATTRIBUTE10			AttributeTabType
 ,OkcPRB_ATTRIBUTE11			AttributeTabType
 ,OkcPRB_ATTRIBUTE12			AttributeTabType
 ,OkcPRB_ATTRIBUTE13			AttributeTabType
 ,OkcPRB_ATTRIBUTE14			AttributeTabType
 ,OkcPRB_ATTRIBUTE15			AttributeTabType
 ,OkcPRB_SECURITY_GROUP_ID		NumTabType
 ,OkcPRB_CPL_ID				NumTabType
 ,OkcPRB_PRIMARY_YN			FlagTabType
 ,OkcPRB_BILL_TO_SITE_USE_ID		NumTabType
 ,OkcPRB_CUST_ACCT_ID			NumTabType
 ,OkcPRB_ORIG_SYSTEM_ID1		NumTabType
 ,OkcPRB_ORIG_SYSTEM_REFERENCE1		OrigSystemRef1TabType
 ,OkcPRB_ORIG_SYSTEM_SOURCE_CODE	OrigSystemSourceCodeTabType
 );

 OkcPRBRecTab OkcPRBRecTabType;
 ------End of Record of Tables datatype for OKC_K_PARTY_ROLES_B---

 ------Table datatypes for OKC_K_PARTY_ROLES_TL------------------
 TYPE OkcPRTL_AliasTabType		IS TABLE OF OKC_K_PARTY_ROLES_TL.ALIAS%TYPE;

 ------Record of tables datatype for OKC_K_PARTY_ROLES_TL----------
 TYPE OkcPRTLRecTabType IS RECORD
 (OkcPRTL_OldID			NumTabType
 ,OkcPRTL_NewID			NumTabType
 ,OkcPRTL_LANGUAGE		LanguageTabType
 ,OkcPRTL_SOURCE_LANG		LanguageTabType
 ,OkcPRTL_SFWT_FLAG		YNTabType
 ,OkcPRTL_COGNOMEN		CognomenTabType
 ,OkcPRTL_ALIAS			OkcPRTL_AliasTabType
 ,OkcPRTL_SECURITY_GROUP_ID	NumTabType
 );

 OkcPRTLRecTab OkcPRTLRecTabType;
--------------------------------------------------------------------

 -----Table datatypes for OKC_CONTACTS-----------------------------
 TYPE OkcC_CroCodeTabType		IS TABLE OF OKC_CONTACTS.CRO_CODE%TYPE;
 TYPE OkcC_ResourceClassTabType		IS TABLE OF OKC_CONTACTS.RESOURCE_CLASS%TYPE;

 -----Record of tables datatype for OKC_CONTACTS------------------
 TYPE OkcCRecTabType IS RECORD
 (OkcC_OldID		NumTabType
 ,OkcC_NewID		NumTabType
 ,OkcC_NewCplID		NumTabType
 ,OkcC_CRO_CODE		OkcC_CroCodeTabType
 ,OkcC_NewDnzChrID	NumTabType
 ,OkcC_OBJECT1_ID1	Object1ID1TabType
 ,OkcC_OBJECT1_ID2	Object1ID2TabType
 ,OkcC_JTOT_OBJECT1_CODE JTOTObject1CodeTabType
 ,OkcC_OBJECT_VERSION_NUMBER NumTabType
 ,OkcC_CONTACT_SEQUENCE	NumTabType
 ,OkcC_ATTRIBUTE_CATEGORY	AttributeCategoryTabType
 ,OkcC_ATTRIBUTE1		AttributeTabType
 ,OkcC_ATTRIBUTE2		AttributeTabType
 ,OkcC_ATTRIBUTE3		AttributeTabType
 ,OkcC_ATTRIBUTE4		AttributeTabType
 ,OkcC_ATTRIBUTE5		AttributeTabType
 ,OkcC_ATTRIBUTE6		AttributeTabType
 ,OkcC_ATTRIBUTE7		AttributeTabType
 ,OkcC_ATTRIBUTE8		AttributeTabType
 ,OkcC_ATTRIBUTE9		AttributeTabType
 ,OkcC_ATTRIBUTE10		AttributeTabType
 ,OkcC_ATTRIBUTE11		AttributeTabType
 ,OkcC_ATTRIBUTE12		AttributeTabType
 ,OkcC_ATTRIBUTE13		AttributeTabType
 ,OkcC_ATTRIBUTE14		AttributeTabType
 ,OkcC_ATTRIBUTE15		AttributeTabType
 ,OkcC_SECURITY_GROUP_ID	NumTabType
 ,OkcC_START_DATE		DateTabType
 ,OkcC_END_DATE			DateTabType
 ,OkcC_PRIMARY_YN		FlagTabType
 ,OkcC_RESOURCE_CLASS		OkcC_ResourceClassTabType
 ,OkcC_SALES_GROUP_ID		NumTabType
 );

 OkcCRecTab OkcCRecTabType;
 ------------------------------------------------------------------

 ------Table Datatypes for OKC_PRICE_ATT_VALUES------------------
 TYPE OkcPAV_FlexTitleTabType	IS TABLE OF OKC_PRICE_ATT_VALUES.FLEX_TITLE%TYPE;
 TYPE OkcPAV_PricingContextTabType	IS TABLE OF OKC_PRICE_ATT_VALUES.PRICING_CONTEXT%TYPE;
 TYPE OkcPAV_PricingAttributeTabType	IS TABLE OF OKC_PRICE_ATT_VALUES.PRICING_ATTRIBUTE1%TYPE;
 TYPE OkcPAV_QualifierContextTabType	IS TABLE OF OKC_PRICE_ATT_VALUES.QUALIFIER_CONTEXT%TYPE;
 TYPE OkcPAV_QualifAttributeTabType	IS TABLE OF OKC_PRICE_ATT_VALUES.QUALIFIER_ATTRIBUTE1%TYPE;


 ------Record of tables datatype for OKC_PRICE_ATT_VALUES-------------
 TYPE OkcPAVRecTabType IS RECORD
 (
   OkcPAV_OldID			NumTabType
  ,OkcPAV_NewID			NumTabType
  ,OkcPAV_FLEX_TITLE		OkcPAV_FlexTitleTabType
  ,OkcPAV_PRICING_CONTEXT	OkcPAV_PricingContextTabType
  ,OkcPAV_PRICING_ATTRIBUTE1	OkcPAV_PricingAttributeTabType
  ,OkcPAV_NewChrID		NumTabType
  ,OkcPAV_PRICING_ATTRIBUTE2	OkcPAV_PricingAttributeTabType
  ,OkcPAV_NewCleID		NumTabType
  ,OkcPAV_PRICING_ATTRIBUTE3	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE4	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE5	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE6	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE7	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE8	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE9	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE10	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE11	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE12	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE13	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE14	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE15	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE16	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE17	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE18	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE19	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE20	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE21	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE22	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE23	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE24	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE25	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE26	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE27	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE28	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE29	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE30	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE31	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE32	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE33	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE34	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE35	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE36	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE37	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE38	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE39	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE40	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE41	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE42	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE43	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE44	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE45	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE46	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE47	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE48	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE49	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE50	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE51	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE52	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE53	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE54	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE55	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE56	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE57	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE58	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE59	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE60	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE61	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE62	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE63	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE64	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE65	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE66	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE67	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE68	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE69	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE70	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE71	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE72	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE73	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE74	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE75	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE76	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE77	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE78	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE79	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE80	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE81	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE82	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE83	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE84	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE85	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE86	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE87	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE88	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE89	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE90	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE91	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE92	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE93	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE94	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE95	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE96	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE97	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE98	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE99	OkcPAV_PricingAttributeTabType
  ,OkcPAV_PRICING_ATTRIBUTE100	OkcPAV_PricingAttributeTabType
  ,OkcPAV_QUALIFIER_CONTEXT	OkcPAV_QualifierContextTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE1	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE2	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE3	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE4	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE5	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE6	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE7	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE8	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE9	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE10	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE11	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE12	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE13	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE14	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE15	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE16	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE17	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE18	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE19	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE20	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE21	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE22	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE23	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE24	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE25	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE26	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE27	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE28	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE29	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE30	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE31	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE32	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE33	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE34	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE35	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE36	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE37	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE38	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE39	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE40	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE41	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE42	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE43	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE44	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE45	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE46	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE47	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE48	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE49	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE50	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE51	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE52	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE53	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE54	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE55	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE56	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE57	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE58	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE59	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE60	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE61	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE62	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE63	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE64	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE65	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE66	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE67	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE68	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE69	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE70	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE71	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE72	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE73	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE74	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE75	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE76	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE77	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE78	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE79	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE80	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE81	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE82	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE83	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE84	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE85	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE86	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE87	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE88	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE89	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE90	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE91	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE92	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE93	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE94	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE95	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE96	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE97	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE98	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE99	OkcPAV_QualifAttributeTabType
  ,OkcPAV_QUALIFIER_ATTRIBUTE100	OkcPAV_QualifAttributeTabType
  ,OkcPAV_SECURITY_GROUP_ID	NumTabType
  ,OkcPAV_PROGRAM_APPLICATION_ID	NumTabType
  ,OkcPAV_PROGRAM_ID		NumTabType
  ,OkcPAV_PROGRAM_UPDATE_DATE	DateTabType
  ,OkcPAV_REQUEST_ID		NumTabType
  ,OkcPAV_OBJECT_VERSION_NUMBER	NumTabType
  );

   OkcPAVRecTab OkcPAVRecTabType;

 --------------------------------------------------------------------

 ---Table datatypes for OKC_PRICE_ADJUSTMENTS columns-----------------
  TYPE OkcPA_AttributeTabType		IS TABLE OF OKC_PRICE_ADJUSTMENTS.ATTRIBUTE1%TYPE;
  TYPE OkcPA_ListLineNoTabType		IS TABLE OF OKC_PRICE_ADJUSTMENTS.LIST_LINE_NO%TYPE;

 ---Record of Tables datatype for OKC_PRICE_ADJUSTMENTS---------------
 TYPE OkcPARecTabType IS RECORD
 (
   OkcPA_OldID		NumTabType
  ,OkcPA_NewID		NumTabType
  ,OkcPA_PAT_ID		NumTabType
  ,OkcPA_NewChrID	NumTabType
  ,OkcPA_NewCleID	NumTabType
  ,OkcPA_BSL_ID		NumTabType
  ,OkcPA_BCL_ID		NumTabType
  ,OkcPA_MODIFIED_FROM	NumTabType
  ,OkcPA_MODIFIED_TO	NumTabType
  ,OkcPA_MODIF_MECHNSM_TYPE_CODE Varchar2_90_TabType
  ,OkcPA_OPERAND	NumTabType
  ,OkcPA_ARITHMETIC_OPERATOR	Varchar2_90_TabType
  ,OkcPA_AUTOMATIC_FLAG		YNTabType
  ,OkcPA_UPDATE_ALLOWED		YNTabType
  ,OkcPA_UPDATED_FLAG		YNTabType
  ,OkcPA_APPLIED_FLAG		YNTabType
  ,OkcPA_ON_INVOICE_FLAG	YNTabType
  ,OkcPA_PRICING_PHASE_ID	NumTabType
  ,OkcPA_CONTEXT	 	Varchar2_90_TabType
  ,OkcPA_ATTRIBUTE1		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE2		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE3		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE4		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE5		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE6		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE7		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE8		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE9		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE10		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE11		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE12		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE13		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE14		OkcPA_AttributeTabType
  ,OkcPA_ATTRIBUTE15		OkcPA_AttributeTabType
  ,OkcPA_SECURITY_GROUP_ID      NumTabType
  ,OkcPA_PROGRAM_APPLICATION_ID	NumTabType
  ,OkcPA_PROGRAM_ID		NumTabType
  ,OkcPA_PROGRAM_UPDATE_DATE	DateTabType
  ,OkcPA_REQUEST_ID		NumTabType
  ,OkcPA_OBJECT_VERSION_NUMBER	NumTabType
  ,OkcPA_LIST_HEADER_ID		NumTabType
  ,OkcPA_LIST_LINE_ID		NumTabType
  ,OkcPA_LIST_LINE_TYPE_CODE	Varchar2_90_TabType
  ,OkcPA_CHANGE_REASON_CODE	Varchar2_90_TabType
  ,OkcPA_CHANGE_REASON_TEXT	Varchar2_2000_TabType
  ,OkcPA_ESTIMATED_FLAG		YNTabType
  ,OkcPA_ADJUSTED_AMOUNT	NumTabType
  ,OkcPA_CHARGE_TYPE_CODE	Varchar2_90_TabType
  ,OkcPA_CHARGE_SUBTYPE_CODE	Varchar2_90_TabType
  ,OkcPA_RANGE_BREAK_QUANTITY	NumTabType
  ,OkcPA_ACCRUAL_CONVERSION_RATE	NumTabType
  ,OkcPA_PRICING_GROUP_SEQUENCE		NumTabType
  ,OkcPA_ACCRUAL_FLAG			YNTabType
  ,OkcPA_LIST_LINE_NO			OKCPA_ListLineNoTabType
  ,OkcPA_SOURCE_SYSTEM_CODE		Varchar2_90_TabType
  ,OkcPA_BENEFIT_QTY			NumTabType
  ,OkcPA_BENEFIT_UOM_CODE		YNTabType
  ,OkcPA_EXPIRATION_DATE		DateTabType
  ,OkcPA_MODIFIER_LEVEL_CODE		Varchar2_90_TabType
  ,OkcPA_PRICE_BREAK_TYPE_CODE		Varchar2_90_TabType
  ,OkcPA_SUBSTITUTION_ATTRIBUTE		Varchar2_90_TabType
  ,OkcPA_PRORATION_TYPE_CODE		Varchar2_90_TabType
  ,OkcPA_INCLUDE_ON_RETURNS_FLAG	YNTabType
  ,OkcPA_REBATE_TRXN_TYPE_CODE  	Varchar2_30_TabType
  );

  OkcPARecTab OkcPARecTabType;
 --------------------------------------------------------


 ---Record of tables datatype for OKS_K_LINES_TL--------------
 TYPE OksTLRecTabType IS RECORD(
   OksTL_OldID			NumTabType
  ,OksTL_NewID			NumTabType
  ,OksTL_LANGUAGE		LanguageTabType
  ,OksTL_SOURCE_LANG		LanguageTabType
  ,OksTL_SFWT_FLAG		YNTabType
  ,OksTL_INVOICE_TEXT		Varchar2_2000_TabType
  ,OksTL_IB_TRX_DETAILS		Varchar2_2000_TabType
  ,OksTL_STATUS_TEXT		Varchar2_450_TabType
  ,OksTL_REACT_TIME_NAME 	Varchar2_450_TabType
  ,OksTL_SECURITY_GROUP_ID 	NumTabType
 );

 OksTLRecTab OksTLRecTabType;
 -------------------------------------------------------------

 -----Table datatypes for OKS_REV_DISTRIBUTIONS columns--------
 TYPE OksRD_AccountClassTabType IS TABLE OF OKS_REV_DISTRIBUTIONS.ACCOUNT_CLASS%TYPE;

 -----Record of Tables datatype for OKS_REV_DISTRIBUTIONS-----------
 TYPE OksRDRecTabType IS RECORD (
   OksRD_OldID 	NumTabType
  ,OksRD_NewID	NumTabType
  ,OksRD_NewChrID	NumTabType
  ,OksRD_NewCleID	NumTabType
  ,OksRD_ACCOUNT_CLASS	OksRD_AccountClassTabType
  ,OksRD_CODE_COMBINATION_ID	NumTabType
  ,OksRD_PERCENT		NumTabType
  ,OksRD_OBJECT_VERSION_NUMBER	NumTabType
  ,OksRD_SECURITY_GROUP_ID	NumTabType
 );

 OksRDRecTab OksRDRecTabType;
 -------------------------------------------------------------------

 -----Table datatypes for OKS_QUALIFIERS columns--------------------
 TYPE OksQ_QualifDataTypeTabType IS TABLE OF OKS_QUALIFIERS.QUALIFIER_DATATYPE%TYPE;

 -------------------------------------------------------------------

 -----Record of tables datatype for OKS_QUALIFIERS-----------------
 TYPE OksQRecTabType IS RECORD (
   OksQ_OldQualifierID		NumTabType
  ,OksQ_NewQualifierID		NumTabType
  ,OksQ_REQUEST_ID		NumTabType
  ,OksQ_PROGRAM_APPLICATION_ID		NumTabType
  ,OksQ_PROGRAM_ID		NumTabType
  ,OksQ_PROGRAM_UPDATE_DATE	DateTabType
  ,OksQ_QUALIFIER_GROUPING_NO	NumTabType
  ,OksQ_QUALIFIER_CONTEXT	Varchar2_30_TabType
  ,OksQ_QUALIFIER_ATTRIBUTE	Varchar2_30_TabType
  ,OksQ_QUALIFIER_ATTR_VALUE	Varchar2_240_TabType
  ,OksQ_COMPARISON_OPERATOR_CODE Varchar2_30_TabType
  ,OksQ_EXCLUDER_FLAG		YNTabType
  ,OksQ_QUALIFIER_RULE_ID	NumTabType
  ,OksQ_START_DATE_ACTIVE	DateTabType
  ,OksQ_END_DATE_ACTIVE		DateTabType
  ,OksQ_CREATED_FROM_RULE_ID	NumTabType
  ,OksQ_QUALIFIER_PRECEDENCE	NumTabType
  ,OksQ_NewListHeaderID		NumTabType
  ,OksQ_NewListLineID		NumTabType
  ,OksQ_QUALIFIER_DATATYPE	OksQ_QualifDataTypeTabType
  ,OksQ_QUALIFIER_ATTR_VALUE_TO Varchar2_240_TabType
  ,OksQ_CONTEXT			Varchar2_30_TabType
  ,OksQ_ATTRIBUTE1		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE2		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE3		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE4		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE5		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE6		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE7		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE8		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE9		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE10		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE11		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE12		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE13		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE14		Varchar2_240_TabType
  ,OksQ_ATTRIBUTE15		Varchar2_240_TabType
  ,OksQ_ACTIVE_FLAG		YNTabType
  ,OksQ_LIST_TYPE_CODE		Varchar2_30_TabType
  ,OksQ_QUAL_ATTRVALUE_FROM_NUM	NumTabType
  ,OksQ_QUAL_ATTRVALUE_TO_NUM	NumTabType
  ,OksQ_SECURITY_GROUP_ID	NumTabType
 );

 OksQRecTab OksQRecTabType;

  -----Record of tables datatype for OKS_COVERAGE_TIMEZONES-----------------
 TYPE OksCTZRecTabType IS RECORD (
   OksCTZ_OldID 	NumTabType
  ,OksCTZ_NewID 	NumTabType
  ,OksCTZ_NewCleID	NumTabType
  ,OksCTZ_DEFAULT_YN	FlagTabType
  ,OksCTZ_TIMEZONE_ID	NumTabType
  ,OksCTZ_NewDnzChrID	NumTabType
  ,OksCTZ_SECURITY_GROUP_ID	NumTabType
  ,OksCTZ_PROGRAM_APPLICATION_ID	NumTabType
  ,OksCTZ_PROGRAM_ID			NumTabType
  ,OksCTZ_PROGRAM_UPDATE_DATE		DateTabType
  ,OksCTZ_REQUEST_ID			NumTabType
  ,OksCTZ_OBJECT_VERSION_NUMBER		NumTabType
  ,OksCTZ_ORIG_SYSTEM_ID1		NumTabType
  ,OksCTZ_ORIG_SYSTEM_SOURCE_CODE	Varchar2_30_TabType
  ,OksCTZ_ORIG_SYSTEM_REFERENCE1	Varchar2_30_TabType
 );

 OksCTZRecTab	OksCTZRecTabType;

------Record of tables datatype for OKS_COVERAGE_TIMES
 TYPE OksCTRecTabType IS RECORD (
   	 OksCT_OldID	NumTabType
   	,OksCT_NewID	NumTabType
	,OksCT_NewDnzChrID	NumTabType
	,OksCT_NewCovTzeLineID	NumTabType
	,OksCT_START_HOUR	NumTabType
	,OksCT_START_MINUTE	NumTabType
	,OksCT_END_HOUR		NumTabType
	,OksCT_END_MINUTE	NumTabType
	,OksCT_MONDAY_YN	FlagTabType
	,OksCT_TUESDAY_YN	FlagTabType
	,OksCT_WEDNESDAY_YN	FlagTabType
	,OksCT_THURSDAY_YN	FlagTabType
	,OksCT_FRIDAY_YN	FlagTabType
	,OksCT_SATURDAY_YN	FlagTabType
	,OksCT_SUNDAY_YN	FlagTabType
	,OksCT_SECURITY_GROUP_ID	NumTabType
	,OksCT_PROGRAM_APPLICATION_ID	NumTabType
	,OksCT_OBJECT_VERSION_NUMBER	NumTabType
	,OksCT_PROGRAM_ID	NumTabType
	,OksCT_PROGRAM_UPDATE_DATE	DateTabType
	,OksCT_REQUEST_ID	NumTabType
 );
 OksCTRecTab 	OksCTRecTabType;

-----Record of tables datatype for OKS_PM_ACTIVITIES------
 TYPE OksPMARecTabType IS RECORD (
   	OksPMA_OldID		NumTabType
  	,OksPMA_NewID		NumTabType
  	,OksPMA_NewCleID	NumTabType
	,OksPMA_NewDnzChrID	NumTabType
	,OksPMA_ACTIVITY_ID	NumTabType
	,OksPMA_SELECT_YN	FlagTabType
	,OksPMA_CONF_REQ_YN	FlagTabType
	,OksPMA_SCH_EXISTS_YN	FlagTabType
	,OksPMA_PROGRAM_APPLICATION_ID	NumTabType
	,OksPMA_PROGRAM_ID		NumTabType
	,OksPMA_PROGRAM_UPDATE_DATE	DateTabType
	,OksPMA_OBJECT_VERSION_NUMBER	NumTabType
	,OksPMA_SECURITY_GROUP_ID	NumTabType
	,OksPMA_REQUEST_ID		NumTabType
	,OksPMA_ORIG_SYSTEM_ID1		NumTabType
	,OksPMA_ORIG_SYSTEM_SOURCE_CODE	Varchar2_30_TabType
	,OksPMA_ORIG_SYSTEM_REFERENCE1	Varchar2_30_TabType
 );

 OksPMARecTab OksPMARecTabType;

----Record of tables datatype for OKS_PM_STREAM_LEVELS----
 TYPE OksPMSLRecTabType IS RECORD (
  OksPMSL_OldID		NumTabType
 ,OksPMSL_NewID		NumTabType
 ,OksPMSL_NewCleID	NumTabType
 ,OksPMSL_NewDnzChrID	NumTabType
 ,OksPMSL_NewActivityLineID	NumTabType
 ,OksPMSL_SEQUENCE_NUMBER	NumTabType
 ,OksPMSL_NUMBER_OF_OCCURENCES	NumTabType
 ,OksPMSL_START_DATE	DateTabType
 ,OksPMSL_END_DATE	DateTabType
 ,OksPMSL_FREQUENCY	NumTabType
 ,OksPMSL_FREQUENCY_UOM	YNTabType
 ,OksPMSL_OFFSET_DURATION	NumTabType
 ,OksPMSL_OFFSET_UOM		YNTabType
 ,OksPMSL_AUTOSCHEDULE_YN	FlagTabType
 ,OksPMSL_PROGRAM_APPLICATION_ID	NumTabType
 ,OksPMSL_PROGRAM_ID		NumTabType
 ,OksPMSL_PROGRAM_UPDATE_DATE	DateTabType
 ,OksPMSL_OBJECT_VERSION_NUMBER	NumTabType
 ,OksPMSL_SECURITY_GROUP_ID	NumTabType
 ,OksPMSL_REQUEST_ID		NumTabType
 ,OksPMSL_ORIG_SYSTEM_ID1	NumTabType
 ,OksPMSL_ORIG_SYS_SOURCE_CODE	Varchar2_30_TabType
 ,OksPMSL_ORIG_SYS_REFERENCE1	Varchar2_30_TabType
 );

 OksPMSLRecTab OksPMSLRecTabType;

-----Record of tables datatype for OKS_PM_SCHEDULES
 TYPE OksPMSCHRecTabType IS RECORD (
   	 OksPMSCH_OldID	NumTabType
  	,OksPMSCH_NewID	NumTabType
  	,OksPMSCH_RULE_ID	NumTabType
	,OksPMSCH_OBJECT_VERSION_NUMBER	NumTabType
	,OksPMSCH_NewDnzChrID	NumTabType
	,OksPMSCH_NewCleID	NumTabType
	,OksPMSCH_SCH_SEQUENCE	NumTabType
	,OksPMSCH_SCHEDULE_DATE	DateTabType
	,OksPMSCH_SCHEDULE_DATE_FROM	DateTabType
	,OksPMSCH_SCHEDULE_DATE_TO	DateTabType
	,OksPMSCH_PMA_RULE_ID		NumTabType
	,OksPMSCH_PMP_RULE_ID		NumTabType
	,OksPMSCH_NewActivityLineID		NumTabType
	,OksPMSCH_NewStreamLineID		NumTabType
	,OksPMSCH_SECURITY_GROUP_ID		NumTabType
	,OksPMSCH_PROG_APPLICATION_ID		NumTabType
	,OksPMSCH_PROGRAM_ID		NumTabType
	,OksPMSCH_PROGRAM_UPDATE_DATE		DateTabType
	,OksPMSCH_REQUEST_ID		NumTabType
 );

 OksPMSCHRecTab OksPMSCHRecTabType;

 -----Record of tables datatype for OKS_ACTION_TIME_TYPES-------
 TYPE OksATTRecTabType IS RECORD (
   	OksATT_OldID	NumTabType
  	,OksATT_NewID	NumTabType
  	,OksATT_NewCleID	NumTabType
	,OksATT_NewDnzChrID	NumTabType
	,OksATT_ACTION_TYPE_CODE	Varchar2_30_TabType
	,OksATT_SECURITY_GROUP_ID	NumTabType
	,OksATT_PROGRAM_APPLICATION_ID	NumTabType
	,OksATT_PROGRAM_ID	NumTabType
	,OksATT_PROGRAM_UPDATE_DATE	DateTabType
	,OksATT_REQUEST_ID	NumTabType
	,OksATT_OBJECT_VERSION_NUMBER	NumTabType
	,OksATT_ORIG_SYSTEM_ID1	NumTabType
	,OksATT_ORIG_SYSTEM_SOURCE_CODE	Varchar2_30_TabType
	,OksATT_ORIG_SYSTEM_REFERENCE1	Varchar2_30_TabType
    );
  OksATTRecTab OksATTRecTabType;

 ------Record of tables datatype for OKS_ACTION_TIMES------
 TYPE OksATRecTabType IS RECORD (
     	OksAT_OldID	NumTabType
    	,OksAT_NewID	NumTabType
	,OksAT_NewCovActionTypeID	NumTabType
	,OksAT_NewCleID	NumTabType
	,OksAT_NewDnzChrID	NumTabType
	,OksAT_UOM_CODE	Varchar2_30_TabType
	,OksAT_SUN_DURATION	NumTabType
	,OksAT_MON_DURATION	NumTabType
	,OksAT_TUE_DURATION	NumTabType
	,OksAT_WED_DURATION	NumTabType
	,OksAT_THU_DURATION	NumTabType
	,OksAT_FRI_DURATION	NumTabType
	,OksAT_SAT_DURATION	NumTabType
	,OksAT_SECURITY_GROUP_ID	NumTabType
	,OksAT_PROGRAM_APPLICATION_ID	NumTabType
	,OksAT_PROGRAM_ID	NumTabType
	,OksAT_PROGRAM_UPDATE_DATE	DateTabType
	,OksAT_REQUEST_ID	NumTabType
	,OksAT_OBJECT_VERSION_NUMBER	NumTabType
  );
 OksATRecTab	OksATRecTabType;

 -----Record of tables datatype for OKS_STREAM_LEVELS_B----
  TYPE OksSLRecTabType IS RECORD (
         OksSL_OldID NumTabType
  	,OksSL_NewID	NumTabType
	,OksSL_NewChrId	NumTabType
	,OksSL_NewCleID	NumTabType
	,OksSL_NewDnzChrID	NumTabType
	,OksSL_SEQUENCE_NO	NumTabType
	,OksSL_UOM_CODE		YNTabType
	,OksSL_START_DATE	DateTabType
	,OksSL_END_DATE		DateTabType
	,OksSL_LEVEL_PERIODS	NumTabType
	,OksSL_UOM_PER_PERIOD	NumTabType
	,OksSL_ADVANCE_PERIODS	NumTabType
	,OksSL_LEVEL_AMOUNT	NumTabType
	,OksSL_INVOICE_OFFSET_DAYS	NumTabType
	,OksSL_INTERFACE_OFFSET_DAYS	NumTabType
	,OksSL_COMMENTS		Varchar2_2000_TabType
	,OksSL_DUE_ARR_YN	FlagTabType
	,OksSL_AMOUNT		NumTabType
	,OksSL_LINES_DETAILED_YN 	FlagTabType
	,OksSL_OBJECT_VERSION_NUMBER	NumTabType
	,OksSL_SECURITY_GROUP_ID	NumTabType
	,OksSL_REQUEST_ID	NumTabType
	,OksSL_ORIG_SYSTEM_ID1	NumTabType
	,OksSL_ORIG_SYSTEM_SOURCE_CODE	Varchar2_30_TabType
	,OksSL_ORIG_SYSTEM_REFERENCE1	Varchar2_30_TabType
  	);
 OksSLRecTab OksSLRecTabType;

 ----Record of tables datatype for OKS_LEVEL_ELEMENTS------
  TYPE OksLERecTabType IS RECORD (
   	OksLE_OldID	NumTabType
  	,OksLE_NewID	NumTabType
  	,OksLE_SEQUENCE_NUMBER NumTabType
	,OksLE_DATE_START DateTabType
	,OksLE_AMOUNT	NumTabType
	,OksLE_DATE_RECEIVABLE_GL	DateTabType
	,OksLE_DATE_REVENUE_RULE_START	DateTabType
	,OksLE_DATE_TRANSACTION	DateTabType
	,OksLE_DATE_DUE	DateTabType
	,OksLE_DATE_PRINT	DateTabType
	,OksLE_DATE_TO_INTERFACE	DateTabType
	,OksLE_DATE_COMPLETED	DateTabType
	,OksLE_OBJECT_VERSION_NUMBER	NumTabType
	,OksLE_NewRulID	NumTabType
	,OksLE_SECURITY_GROUP_ID	NumTabType
	,OksLE_NewCleID	NumTabType
	,OksLE_NewDnzChrID	NumTabType
	,OksLE_NewParentCleID	NumTabType
	,OksLE_DATE_END		DateTabType
  );
 OksLERecTab	OksLERecTabType;

 -----Record of tables datatype for OKS_K_SALES_CREDITS---------
  TYPE OksSCRecTabType IS RECORD (
	OksSC_OldID	NumTabType
       ,OksSC_NewID	NumTabType
	,OksSC_PERCENT  NumTabType
	,OksSC_NewChrID	NumTabType
	,OksSC_NewCleId	NumTabType
	,OksSC_CTC_ID	NumTabType
	,OksSC_SALES_CREDIT_TYPE_ID1	Varchar2_40_TabType
	,OksSC_SALES_CREDIT_TYPE_ID2	Varchar2_40_TabType
	,OksSC_OBJECT_VERSION_NUMBER	NumTabType
	,OksSC_SECURITY_GROUP_ID	NumTabType
	,OksSC_SALES_GROUP_ID	NumTabType
  );
 OksSCRecTab OksSCRecTabType;

 -----Record of tables datatype for OKS_BILLRATE_SCHEDULES-----
  TYPE OksBSCHRecTabType IS RECORD (
   	 OksBSCH_OldID	NumTabType
       	,OksBSCH_NewID	NumTabType
	,OksBSCH_NewCleId NumTabType
	,OksBSCH_NewBTCleID	NumTabType
	,OksBSCH_NewDnzChrID	NumTabType
	,OksBSCH_START_HOUR	NumTabType
	,OksBSCH_START_MINUTE	NumTabType
	,OksBSCH_END_HOUR	NumTabType
	,OksBSCH_END_MINUTE	NumTabType
	,OksBSCH_MONDAY_FLAG	FlagTabType
	,OksBSCH_TUESDAY_FLAG	FlagTabType
	,OksBSCH_WEDNESDAY_FLAG	FlagTabType
	,OksBSCH_THURSDAY_FLAG	FlagTabType
	,OksBSCH_FRIDAY_FLAG	FlagTabType
	,OksBSCH_SATURDAY_FLAG	FlagTabType
	,OksBSCH_SUNDAY_FLAG	FlagTabType
	,OksBSCH_OBJECT1_ID1	Object1ID1TabType
	,OksBSCH_OBJECT1_ID2	Object1ID2TabType
	,OksBSCH_JTOT_OBJECT1_CODE	JTOTObject1CodeTabType
	,OksBSCH_BILL_RATE_CODE	Varchar2_40_TabType
	,OksBSCH_FLAT_RATE	NumTabType
	,OksBSCH_UOM		YNTabType
	,OksBSCH_HOLIDAY_YN	FlagTabType
	,OksBSCH_PCT_OVER_LIST_PRICE	NumTabType
	,OksBSCH_PRGRM_APPLICATION_ID	NumTabType
	,OksBSCH_PROGRAM_ID	NumTabType
	,OksBSCH_PROGRAM_UPDATE_DATE	DateTabType
	,OksBSCH_REQUEST_ID		NumTabType
	,OksBSCH_SECURITY_GROUP_ID		NumTabType
	,OksBSCH_OBJECT_VERSION_NUMBER		NumTabType
  );
 OksBSCHRecTab OksBSCHRecTabType;

 ------Record of tables datatype for OKC_OPERATION_LINES-------------
 TYPE OkcOLRecTabType IS RECORD (
   	 OkcOLID		NumTabType
	,OkcOLSELECT_YN		YNTabType
	,OkcOLPROCESS_FLAG	FlagTabType
	,OkcOLOIE_ID		NumTabType
	,OkcOLSUBJECT_CHR_ID	NumTabType
	,OkcOLOBJECT_CHR_ID	NumTabType
	,OkcOLSUBJECT_CLE_ID	NumTabType
	,OkcOLOBJECT_CLE_ID	NumTabType
	,OkcOLOBJECT_VERSION_NUMBER	NumTabType
	,OkcOLREQUEST_ID		NumTabType
	,OkcOLPROGRAM_APPLICATION_ID	NumTabType
	,OkcOLPROGRAM_ID		NumTabType
	,OkcOLPROGRAM_UPDATE_DATE 	DateTabType
	,OkcOLSECURITY_GROUP_ID		NumTabType
	,OkcOLMESSAGE_CODE		Varchar2_30_TabType
	,OkcOLPARENT_OLE_ID		NumTabType
	,OkcOLACTIVE_YN			YNTabType
  );
 OkcOLRecTab OkcOLRecTabType;


 FUNCTION is_copy_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;

 PROCEDURE copy_components(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id	          	   IN NUMBER,
    p_contract_number		        IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2 DEFAULT 'N',
    p_components_tbl			   IN api_components_tbl,
    p_lines_tbl				   IN api_lines_tbl,
    p_change_status_YN                IN VARCHAR2 DEFAULT 'Y',--Added for Update_Service requirement(Bug 4747648)
                                                           --If 'Y', status of new line is default status
                                                           --If 'N', status from Source Line is retained
    p_return_new_top_line_ID_YN    IN VARCHAR2 DEFAULT 'N', --Added for Update_Service requirement(Bug 4747648)
                                                           --If 'Y' then the new line IDs of the copied top lines need to be
                                                           --published
    x_to_chr_id                       OUT NOCOPY NUMBER,
    p_published_line_ids_tbl       OUT  NOCOPY published_line_ids_tbl --Added for Update Service requirement(Bug 4747648)
								      --This table will be populated if p_return_new_top_line_ID_YN = 'Y'
,p_include_cancelled_lines       IN VARCHAR2 DEFAULT 'Y',
    p_include_terminated_lines     IN VARCHAR2 DEFAULT 'Y'); /*modified for copy enhancement*/


 PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit        			   IN VARCHAR2 DEFAULT 'F',
    p_chr_id                       IN NUMBER,
    p_contract_number		     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    x_to_chr_id                       OUT NOCOPY NUMBER,
    p_include_cancelled_lines       IN  VARCHAR2 DEFAULT 'Y',
    p_include_terminated_lines      IN  VARCHAR2 DEFAULT 'Y');

 PROCEDURE copy_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_contract_number		   IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    x_to_chr_id                       OUT NOCOPY NUMBER);

/******Header Level events no longer supported****
  PROCEDURE copy_events(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnh_id                  	   IN NUMBER,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_template_yn		   IN VARCHAR2,
    x_cnh_id		           OUT NOCOPY NUMBER);
****************************************************/

---------------------------------Start New code for 12.0---------------------------------

/*======================================================================================
--Copy_Lines: This procedure copies all lines and its details for a given Contract Header
              This pricedure is used in COPY_CONTRACT API.
		    Parameters:
		    		P_From_Chr_ID: Header ID of the Source Contract
				P_To_Chr_ID  : Header ID of the Target Contract
				P_Renew_Ref_YN : Parameter to indicate if this routine is being called in
							  the context of Contract Renewal or regular Copy. Valid
							  values are 'Y' and 'N'
=======================================================================================*/
 PROCEDURE copy_lines(
       p_api_version      IN NUMBER
	 ,p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	 ,x_return_status    OUT NOCOPY VARCHAR2
	 ,x_msg_count        OUT NOCOPY NUMBER
	 ,x_msg_data         OUT NOCOPY VARCHAR2
	 ,P_From_Chr_ID      IN NUMBER
	 ,P_To_Chr_ID		 IN NUMBER
	 ,P_Renew_Ref_YN	 IN VARCHAR2
	 ,p_include_cancelled_lines       IN VARCHAR2 DEFAULT 'Y'
    ,p_include_terminated_lines     IN VARCHAR2 DEFAULT 'Y'); /*modified for copy enhancement*/


/*======================================================================================
--Copy_Lines: This procedure copies all lines that are selected by the user for Copy in the Copy UI
              and their details. This pricedure is used in COPY_COMPONENTS API.
		    Parameters:
		    		P_From_Chr_ID: Header ID of the Source Contract
				P_To_Chr_ID  : Header ID of the Target Contract
				P_Target_Contract_New_YN: Flag to indicate if the Target Contract was just created as part of Copy
									 or was already present and only lines were copied to an existing target
									 contract. Value for this parameter will be 'Y' if source contract is being
									 copied to a new contract, 'N' if the copy is happening into an existing
									 contract.
									 This parameter would be initialized in this API to 'N' and
									 get set to 'Y' immediately after the call to Copy_Contract_Header.

									 This parameter would be used in copy of:
									    Price Attribute Values
									    Price Adjustments
									    Sales Credits
									    Billing Schedules.

									 If value is 'N' these entities would be copied only for Lines
									 else they would be copied for both Header and Lines.
=========================================================================================*/
 PROCEDURE copy_line_components(
       p_api_version      IN NUMBER
	 ,p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	 ,x_return_status    OUT NOCOPY VARCHAR2
	 ,x_msg_count        OUT NOCOPY NUMBER
	 ,x_msg_data         OUT NOCOPY VARCHAR2
	 ,P_From_Chr_ID      IN NUMBER
	 ,P_To_Chr_ID		 IN NUMBER
	 ,P_Target_Contract_New_YN IN VARCHAR2
	 ,P_Lines_Tbl 		 IN api_lines_tbl
         ,p_change_status_YN                IN VARCHAR2 --Added for Update_Service requirement(Bug 4747648)
                                                           --If 'Y', status of new line is default status
                                                           --If 'N', status from Source Line is retained
         ,p_return_new_top_line_ID_YN    IN VARCHAR2 --Added for Update_Service requirement(Bug 4747648)
                                                           --If 'Y' then the new line IDs of the copied top lines need to be
                                                           --published
,p_include_cancelled_lines       IN VARCHAR2 DEFAULT 'Y'
    ,p_include_terminated_lines     IN VARCHAR2 DEFAULT 'Y'); /*modified for copy enhancement*/

/*=======================================================================
 Returns 'Y' if the Contract has a Partial Period Setup else returns 'N'
========================================================================*/

Function ContractPPSetupEXISTS(P_Chr_ID IN NUMBER) RETURN VARCHAR2;

/*=========================================================================
 This procedure is being exposed so that it can be invoked from OKC_COPY_CONTRACT_PVT.update_template_Contract
 to support partial period uptake
==========================================================================*/

Procedure create_bsch_using_PPSetup(P_To_Chr_ID                IN NUMBER
                                   ,P_From_Chr_ID              IN NUMBER
                                   ,P_Partial_Copy_YN       IN VARCHAR2
				   ,P_Target_Contract_New_YN IN VARCHAR2 DEFAULT 'Y'
                                   ,p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                                   ,x_return_status         OUT NOCOPY VARCHAR2
                                   ,x_msg_count             OUT NOCOPY NUMBER
                                   ,x_msg_data              OUT NOCOPY VARCHAR2);

/***--Procedure moved to package OKS_UTIL_PUB
Procedure create_transaction_extension(P_Api_Version IN NUMBER
                                      ,P_Init_Msg_List IN VARCHAR2
                                      ,P_Header_ID IN NUMBER
                                      ,P_Line_ID IN NUMBER
                                      ,P_Source_Trx_Ext_ID IN NUMBER
                                      ,P_Cust_Acct_ID IN NUMBER
                                      ,P_Bill_To_Site_Use_ID IN NUMBER
                                      ,x_entity_id OUT NOCOPY NUMBER
                                      ,x_msg_data OUT NOCOPY VARCHAR2
                                      ,x_msg_count OUT NOCOPY NUMBER
                                      ,x_return_status OUT NOCOPY VARCHAR2);
****/

--npalepu added on 18-may-2006 for bug # 5211482
-------------------------------------------------------------------------------
-- Procedure:           chk_line_effectivity
-- Purpose:             This procedure checks the effectivity dates of source
--                      contract line and target contract line
-- In Parameters:       p_new_cle_id        Target contract line id
-- Out Parameters:      x_return_status     standard return status
--                      x_flag              yes no flag
-----------------------------------------------------------------------------

 PROCEDURE chk_line_effectivity(p_new_cle_id          IN NUMBER,
                                x_flag                OUT NOCOPY VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2
                               );
--end npalepu

END OKS_COPY_CONTRACT_PVT;

/
