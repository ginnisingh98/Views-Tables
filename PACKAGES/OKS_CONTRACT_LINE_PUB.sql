--------------------------------------------------------
--  DDL for Package OKS_CONTRACT_LINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CONTRACT_LINE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPKLNS.pls 120.1 2005/07/15 09:22:59 parkumar noship $ */
  -- OKS_K_LINES_HV Record Spec
  TYPE klnhv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,major_version                  NUMBER := OKC_API.G_MISS_NUM
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
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_klnhv_rec                         klnhv_rec_type;
  TYPE klnhv_tbl_type IS TABLE OF klnhv_rec_type
        INDEX BY BINARY_INTEGER;

  subtype klnv_rec_type is oks_kln_pvt.klnv_rec_type;
  subtype klnv_tbl_type is oks_kln_pvt.klnv_tbl_type;
  subtype klt_tbl_type  is OKS_KLN_PVT.klt_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_LINE_PUB';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(20)  := OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(20)  := OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(20)  := OKC_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_FALSE                CONSTANT VARCHAR2(10)  := OKC_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(10)  := OKC_API.G_TRUE;
  ---------------------------------------------------------------------------

  PROCEDURE add_language;
  PROCEDURE create_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type,
    x_klnv_rec                     OUT NOCOPY klnv_rec_type,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE create_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE create_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE lock_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type);
  PROCEDURE lock_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type);
  PROCEDURE update_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type,
    x_klnv_rec                     OUT NOCOPY klnv_rec_type,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE update_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE update_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    x_klnv_tbl                     OUT NOCOPY klnv_tbl_type,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE delete_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type);
  PROCEDURE delete_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type);
  PROCEDURE validate_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_rec                     IN klnv_rec_type);
  PROCEDURE validate_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klnv_tbl                     IN klnv_tbl_type);


  PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,
                           p_klnv_tbl      IN klnv_tbl_type);

  PROCEDURE CREATE_LINE_VERSION_UPG(x_return_status OUT NOCOPY VARCHAR2,
                             p_klnhv_tbl IN klnhv_tbl_type);

END oks_contract_line_pub;


 

/
