--------------------------------------------------------
--  DDL for Package OKS_KLN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_KLN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSKLNS.pls 120.5.12000000.1 2007/01/16 22:14:16 appldev ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_K_LINES_V Record Spec
  TYPE klnv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,discount_list                  NUMBER := OKC_API.G_MISS_NUM
    ,acct_rule_id                   NUMBER := OKC_API.G_MISS_NUM
    ,payment_type                   OKS_K_LINES_V.PAYMENT_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,cc_no                          OKS_K_LINES_V.CC_NO%TYPE := OKC_API.G_MISS_CHAR
    ,cc_expiry_date                 OKS_K_LINES_V.CC_EXPIRY_DATE%TYPE := OKC_API.G_MISS_DATE
    ,cc_bank_acct_id                NUMBER := OKC_API.G_MISS_NUM
    ,cc_auth_code                   OKS_K_LINES_V.CC_AUTH_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,commitment_id                  NUMBER := OKC_API.G_MISS_NUM
    ,locked_price_list_id           NUMBER := OKC_API.G_MISS_NUM
    ,usage_est_yn                   OKS_K_LINES_V.USAGE_EST_YN%TYPE := OKC_API.G_MISS_CHAR
    ,usage_est_method               OKS_K_LINES_V.USAGE_EST_METHOD%TYPE := OKC_API.G_MISS_CHAR
    ,usage_est_start_date           OKS_K_LINES_V.USAGE_EST_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,termn_method                   OKS_K_LINES_V.TERMN_METHOD%TYPE := OKC_API.G_MISS_CHAR
    ,ubt_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,credit_amount                  NUMBER := OKC_API.G_MISS_NUM
    ,suppressed_credit              NUMBER := OKC_API.G_MISS_NUM
    ,override_amount                NUMBER := OKC_API.G_MISS_NUM
    ,cust_po_number_req_yn          OKS_K_LINES_V.CUST_PO_NUMBER_REQ_YN%TYPE := OKC_API.G_MISS_CHAR
    ,cust_po_number                 OKS_K_LINES_V.CUST_PO_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,grace_duration                 NUMBER := OKC_API.G_MISS_NUM
    ,grace_period                   OKS_K_LINES_V.GRACE_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,inv_print_flag                 OKS_K_LINES_V.INV_PRINT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,price_uom                      OKS_K_LINES_V.PRICE_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,tax_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,tax_inclusive_yn               OKS_K_LINES_V.TAX_INCLUSIVE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,tax_status                     OKS_K_LINES_V.TAX_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,tax_code                       NUMBER := OKC_API.G_MISS_NUM
    ,tax_exemption_id               NUMBER := OKC_API.G_MISS_NUM
    ,ib_trans_type                  OKS_K_LINES_V.IB_TRANS_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,ib_trans_date                  OKS_K_LINES_V.IB_TRANS_DATE%TYPE := OKC_API.G_MISS_DATE
    ,prod_price                     NUMBER := OKC_API.G_MISS_NUM
    ,service_price                  NUMBER := OKC_API.G_MISS_NUM
    ,clvl_list_price                NUMBER := OKC_API.G_MISS_NUM
    ,clvl_quantity                  NUMBER := OKC_API.G_MISS_NUM
    ,clvl_extended_amt              NUMBER := OKC_API.G_MISS_NUM
    ,clvl_uom_code                  OKS_K_LINES_V.CLVL_UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_operand_code            OKS_K_LINES_V.TOPLVL_OPERAND_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_operand_val             NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_quantity                NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_uom_code                OKS_K_LINES_V.TOPLVL_UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_adj_price               NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_price_qty               NUMBER := OKC_API.G_MISS_NUM
    ,averaging_interval             NUMBER := OKC_API.G_MISS_NUM
    ,settlement_interval            OKS_K_LINES_V.SETTLEMENT_INTERVAL%TYPE := OKC_API.G_MISS_CHAR
    ,minimum_quantity               NUMBER := OKC_API.G_MISS_NUM
    ,default_quantity               NUMBER := OKC_API.G_MISS_NUM
    ,amcv_flag                      OKS_K_LINES_V.AMCV_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,fixed_quantity                 NUMBER := OKC_API.G_MISS_NUM
    ,usage_duration                 NUMBER := OKC_API.G_MISS_NUM
    ,usage_period                   OKS_K_LINES_V.USAGE_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,level_yn                       OKS_K_LINES_V.LEVEL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,usage_type                     OKS_K_LINES_V.USAGE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,uom_quantified                 OKS_K_LINES_V.UOM_QUANTIFIED%TYPE := OKC_API.G_MISS_CHAR
    ,base_reading                   NUMBER := OKC_API.G_MISS_NUM
    ,billing_schedule_type          OKS_K_LINES_V.BILLING_SCHEDULE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,full_credit                    OKS_K_LINES_V.FULL_CREDIT%TYPE := OKC_API.G_MISS_CHAR
    ,locked_price_list_line_id      NUMBER := OKC_API.G_MISS_NUM
    ,break_uom                      OKS_K_LINES_V.BREAK_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,prorate                        OKS_K_LINES_V.PRORATE%TYPE := OKC_API.G_MISS_CHAR
    ,coverage_type                  OKS_K_LINES_V.COVERAGE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,exception_cov_id               NUMBER := OKC_API.G_MISS_NUM
    ,limit_uom_quantified           OKS_K_LINES_V.LIMIT_UOM_QUANTIFIED%TYPE := OKC_API.G_MISS_CHAR
    ,discount_amount                NUMBER := OKC_API.G_MISS_NUM
    ,discount_percent               NUMBER := OKC_API.G_MISS_NUM
    ,offset_duration                NUMBER := OKC_API.G_MISS_NUM
    ,offset_period                  OKS_K_LINES_V.OFFSET_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,incident_severity_id           NUMBER := OKC_API.G_MISS_NUM
    ,pdf_id                         NUMBER := OKC_API.G_MISS_NUM
    ,work_thru_yn                   OKS_K_LINES_V.WORK_THRU_YN%TYPE := OKC_API.G_MISS_CHAR
    ,react_active_yn                OKS_K_LINES_V.REACT_ACTIVE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_option                OKS_K_LINES_V.TRANSFER_OPTION%TYPE := OKC_API.G_MISS_CHAR
    ,prod_upgrade_yn                OKS_K_LINES_V.PROD_UPGRADE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,inheritance_type               OKS_K_LINES_V.INHERITANCE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,pm_program_id                  NUMBER := OKC_API.G_MISS_NUM
    ,pm_conf_req_yn                 OKS_K_LINES_V.PM_CONF_REQ_YN%TYPE := OKC_API.G_MISS_CHAR
    ,pm_sch_exists_yn               OKS_K_LINES_V.PM_SCH_EXISTS_YN%TYPE := OKC_API.G_MISS_CHAR
    ,allow_bt_discount              OKS_K_LINES_V.ALLOW_BT_DISCOUNT%TYPE := OKC_API.G_MISS_CHAR
    ,apply_default_timezone         OKS_K_LINES_V.APPLY_DEFAULT_TIMEZONE%TYPE := OKC_API.G_MISS_CHAR
    ,sync_date_install              OKS_K_LINES_V.SYNC_DATE_INSTALL%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKS_K_LINES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,invoice_text                   OKS_K_LINES_V.INVOICE_TEXT%TYPE := OKC_API.G_MISS_CHAR
    ,ib_trx_details                 OKS_K_LINES_V.IB_TRX_DETAILS%TYPE := OKC_API.G_MISS_CHAR
    ,status_text                    OKS_K_LINES_V.STATUS_TEXT%TYPE := OKC_API.G_MISS_CHAR
    ,react_time_name                OKS_K_LINES_V.REACT_TIME_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_K_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_K_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
-- R12 Data Model Changes 4485150 Start
    ,trxn_extension_id              NUMBER := OKC_API.G_MISS_NUM
    ,tax_classification_code        OKS_K_LINES_B.TAX_CLASSIFICATION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,exempt_certificate_number      OKS_K_LINES_B.EXEMPT_CERTIFICATE_NUMBER%TYPE  := OKC_API.G_MISS_CHAR
    ,exempt_reason_code             OKS_K_LINES_B.EXEMPT_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,coverage_id                    NUMBER := OKC_API.G_MISS_NUM
    ,standard_cov_yn                OKS_K_LINES_V.STANDARD_COV_YN%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_K_LINES_V.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_K_LINES_V.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
);
  G_MISS_klnv_rec                         klnv_rec_type;
  TYPE klnv_tbl_type IS TABLE OF klnv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_K_LINES_B Record Spec
  TYPE kln_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,discount_list                  NUMBER := OKC_API.G_MISS_NUM
    ,acct_rule_id                   NUMBER := OKC_API.G_MISS_NUM
    ,payment_type                   OKS_K_LINES_B.PAYMENT_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,cc_no                          OKS_K_LINES_B.CC_NO%TYPE := OKC_API.G_MISS_CHAR
    ,cc_expiry_date                 OKS_K_LINES_B.CC_EXPIRY_DATE%TYPE := OKC_API.G_MISS_DATE
    ,cc_bank_acct_id                NUMBER := OKC_API.G_MISS_NUM
    ,cc_auth_code                   OKS_K_LINES_B.CC_AUTH_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,commitment_id                  NUMBER := OKC_API.G_MISS_NUM
    ,locked_price_list_id           NUMBER := OKC_API.G_MISS_NUM
    ,usage_est_yn                   OKS_K_LINES_B.USAGE_EST_YN%TYPE := OKC_API.G_MISS_CHAR
    ,usage_est_method               OKS_K_LINES_B.USAGE_EST_METHOD%TYPE := OKC_API.G_MISS_CHAR
    ,usage_est_start_date           OKS_K_LINES_B.USAGE_EST_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,termn_method                   OKS_K_LINES_B.TERMN_METHOD%TYPE := OKC_API.G_MISS_CHAR
    ,ubt_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,credit_amount                  NUMBER := OKC_API.G_MISS_NUM
    ,suppressed_credit              NUMBER := OKC_API.G_MISS_NUM
    ,override_amount                NUMBER := OKC_API.G_MISS_NUM
    ,cust_po_number_req_yn          OKS_K_LINES_B.CUST_PO_NUMBER_REQ_YN%TYPE := OKC_API.G_MISS_CHAR
    ,cust_po_number                 OKS_K_LINES_B.CUST_PO_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,grace_duration                 NUMBER := OKC_API.G_MISS_NUM
    ,grace_period                   OKS_K_LINES_B.GRACE_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,inv_print_flag                 OKS_K_LINES_B.INV_PRINT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,price_uom                      OKS_K_LINES_B.PRICE_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,tax_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,tax_inclusive_yn               OKS_K_LINES_B.TAX_INCLUSIVE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,tax_status                     OKS_K_LINES_B.TAX_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,tax_code                       NUMBER := OKC_API.G_MISS_NUM
    ,tax_exemption_id               NUMBER := OKC_API.G_MISS_NUM
    ,ib_trans_type                  OKS_K_LINES_B.IB_TRANS_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,ib_trans_date                  OKS_K_LINES_B.IB_TRANS_DATE%TYPE := OKC_API.G_MISS_DATE
    ,prod_price                     NUMBER := OKC_API.G_MISS_NUM
    ,service_price                  NUMBER := OKC_API.G_MISS_NUM
    ,clvl_list_price                NUMBER := OKC_API.G_MISS_NUM
    ,clvl_quantity                  NUMBER := OKC_API.G_MISS_NUM
    ,clvl_extended_amt              NUMBER := OKC_API.G_MISS_NUM
    ,clvl_uom_code                  OKS_K_LINES_B.CLVL_UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_operand_code            OKS_K_LINES_B.TOPLVL_OPERAND_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_operand_val             NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_quantity                NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_uom_code                OKS_K_LINES_B.TOPLVL_UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_adj_price               NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_price_qty               NUMBER := OKC_API.G_MISS_NUM
    ,averaging_interval             NUMBER := OKC_API.G_MISS_NUM
    ,settlement_interval            OKS_K_LINES_B.SETTLEMENT_INTERVAL%TYPE := OKC_API.G_MISS_CHAR
    ,minimum_quantity               NUMBER := OKC_API.G_MISS_NUM
    ,default_quantity               NUMBER := OKC_API.G_MISS_NUM
    ,amcv_flag                      OKS_K_LINES_B.AMCV_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,fixed_quantity                 NUMBER := OKC_API.G_MISS_NUM
    ,usage_duration                 NUMBER := OKC_API.G_MISS_NUM
    ,usage_period                   OKS_K_LINES_B.USAGE_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,level_yn                       OKS_K_LINES_B.LEVEL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,usage_type                     OKS_K_LINES_B.USAGE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,uom_quantified                 OKS_K_LINES_B.UOM_QUANTIFIED%TYPE := OKC_API.G_MISS_CHAR
    ,base_reading                   NUMBER := OKC_API.G_MISS_NUM
    ,billing_schedule_type          OKS_K_LINES_B.BILLING_SCHEDULE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,full_credit                    OKS_K_LINES_B.FULL_CREDIT%TYPE := OKC_API.G_MISS_CHAR
    ,locked_price_list_line_id      NUMBER := OKC_API.G_MISS_NUM
    ,break_uom                      OKS_K_LINES_B.BREAK_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,prorate                        OKS_K_LINES_B.PRORATE%TYPE := OKC_API.G_MISS_CHAR
    ,coverage_type                  OKS_K_LINES_B.COVERAGE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,exception_cov_id               NUMBER := OKC_API.G_MISS_NUM
    ,limit_uom_quantified           OKS_K_LINES_B.LIMIT_UOM_QUANTIFIED%TYPE := OKC_API.G_MISS_CHAR
    ,discount_amount                NUMBER := OKC_API.G_MISS_NUM
    ,discount_percent               NUMBER := OKC_API.G_MISS_NUM
    ,offset_duration                NUMBER := OKC_API.G_MISS_NUM
    ,offset_period                  OKS_K_LINES_B.OFFSET_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,incident_severity_id           NUMBER := OKC_API.G_MISS_NUM
    ,pdf_id                         NUMBER := OKC_API.G_MISS_NUM
    ,work_thru_yn                   OKS_K_LINES_B.WORK_THRU_YN%TYPE := OKC_API.G_MISS_CHAR
    ,react_active_yn                OKS_K_LINES_B.REACT_ACTIVE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_option                OKS_K_LINES_B.TRANSFER_OPTION%TYPE := OKC_API.G_MISS_CHAR
    ,prod_upgrade_yn                OKS_K_LINES_B.PROD_UPGRADE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,inheritance_type               OKS_K_LINES_B.INHERITANCE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,pm_program_id                  NUMBER := OKC_API.G_MISS_NUM
    ,pm_conf_req_yn                 OKS_K_LINES_B.PM_CONF_REQ_YN%TYPE := OKC_API.G_MISS_CHAR
    ,pm_sch_exists_yn               OKS_K_LINES_B.PM_SCH_EXISTS_YN%TYPE := OKC_API.G_MISS_CHAR
    ,allow_bt_discount              OKS_K_LINES_B.ALLOW_BT_DISCOUNT%TYPE := OKC_API.G_MISS_CHAR
    ,apply_default_timezone         OKS_K_LINES_B.APPLY_DEFAULT_TIMEZONE%TYPE := OKC_API.G_MISS_CHAR
    ,sync_date_install              OKS_K_LINES_B.SYNC_DATE_INSTALL%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_K_LINES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_K_LINES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
-- R12 Data Model Changes 4485150 Start
    ,trxn_extension_id              NUMBER := OKC_API.G_MISS_NUM
    ,tax_classification_code        OKS_K_LINES_B.TAX_CLASSIFICATION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,exempt_certificate_number      OKS_K_LINES_B.EXEMPT_CERTIFICATE_NUMBER%TYPE  := OKC_API.G_MISS_CHAR
    ,exempt_reason_code             OKS_K_LINES_B.EXEMPT_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,coverage_id                    NUMBER := OKC_API.G_MISS_NUM
    ,standard_cov_yn                OKS_K_LINES_B.STANDARD_COV_YN%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_K_LINES_B.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_K_LINES_B.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
);
  G_MISS_kln_rec                          kln_rec_type;
  TYPE kln_tbl_type IS TABLE OF kln_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_K_LINES_TL Record Spec
  TYPE klt_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,language                       OKS_K_LINES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    OKS_K_LINES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKS_K_LINES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,invoice_text                   OKS_K_LINES_TL.INVOICE_TEXT%TYPE := OKC_API.G_MISS_CHAR
    ,ib_trx_details                 OKS_K_LINES_TL.IB_TRX_DETAILS%TYPE := OKC_API.G_MISS_CHAR
    ,status_text                    OKS_K_LINES_TL.STATUS_TEXT%TYPE := OKC_API.G_MISS_CHAR
    ,react_time_name                OKS_K_LINES_TL.REACT_TIME_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_K_LINES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_K_LINES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_klt_rec                          klt_rec_type;
  TYPE klt_tbl_type IS TABLE OF klt_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_KLN_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type,
    x_klnv_rec                     OUT NOCOPY klnv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type,
    x_klnv_rec                     OUT NOCOPY klnv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type);
END OKS_KLN_PVT;

 

/
