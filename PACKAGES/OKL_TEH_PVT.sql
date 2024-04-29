--------------------------------------------------------
--  DDL for Package OKL_TEH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TEH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTEHS.pls 120.6 2007/12/21 12:50:10 rajnisku noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TRX_EXTENSION_V Record Spec
  TYPE tehv_rec_type IS RECORD (
     header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_TRX_EXTENSION_V.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,language                       OKL_TRX_EXTENSION_V.LANGUAGE%TYPE
    ,contract_number                OKL_TRX_EXTENSION_V.CONTRACT_NUMBER%TYPE
    ,inv_agrmnt_number              OKL_TRX_EXTENSION_V.INV_AGRMNT_NUMBER%TYPE
    ,contract_currency_code         OKL_TRX_EXTENSION_V.CONTRACT_CURRENCY_CODE%TYPE
    ,inv_agrmnt_currency_code       OKL_TRX_EXTENSION_V.INV_AGRMNT_CURRENCY_CODE%TYPE
    ,contract_effective_from        OKL_TRX_EXTENSION_V.CONTRACT_EFFECTIVE_FROM%TYPE
    ,inv_agrmnt_effective_from      OKL_TRX_EXTENSION_V.INV_AGRMNT_EFFECTIVE_FROM%TYPE
    ,customer_name                  OKL_TRX_EXTENSION_V.CUSTOMER_NAME%TYPE
    ,sales_rep_name                 OKL_TRX_EXTENSION_V.SALES_REP_NAME%TYPE
    ,customer_account_number        OKL_TRX_EXTENSION_V.CUSTOMER_ACCOUNT_NUMBER%TYPE
    ,bill_to_address_num            NUMBER
    ,int_calc_method_code           OKL_TRX_EXTENSION_V.INT_CALC_METHOD_CODE%TYPE
    ,rev_rec_method_code            OKL_TRX_EXTENSION_V.REV_REC_METHOD_CODE%TYPE
    ,converted_number               OKL_TRX_EXTENSION_V.CONVERTED_NUMBER%TYPE
    ,assignable_flag                OKL_TRX_EXTENSION_V.ASSIGNABLE_FLAG%TYPE
    ,credit_line_number             OKL_TRX_EXTENSION_V.CREDIT_LINE_NUMBER%TYPE
    ,master_lease_number            OKL_TRX_EXTENSION_V.MASTER_LEASE_NUMBER%TYPE
    ,po_order_number                OKL_TRX_EXTENSION_V.PO_ORDER_NUMBER%TYPE
    ,vendor_program_number          OKL_TRX_EXTENSION_V.VENDOR_PROGRAM_NUMBER%TYPE
    ,ins_policy_type_code           OKL_TRX_EXTENSION_V.INS_POLICY_TYPE_CODE%TYPE
    ,ins_policy_number              OKL_TRX_EXTENSION_V.INS_POLICY_NUMBER%TYPE
    ,term_quote_accept_date         OKL_TRX_EXTENSION_V.TERM_QUOTE_ACCEPT_DATE%TYPE
    ,term_quote_num                 NUMBER
    ,term_quote_type_code           OKL_TRX_EXTENSION_V.TERM_QUOTE_TYPE_CODE%TYPE
    ,converted_account_flag         OKL_TRX_EXTENSION_V.CONVERTED_ACCOUNT_FLAG%TYPE
    ,accrual_override_flag          OKL_TRX_EXTENSION_V.ACCRUAL_OVERRIDE_FLAG%TYPE
    ,cust_attribute_category        OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE_CATEGORY%TYPE
    ,cust_attribute1                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE1%TYPE
    ,cust_attribute2                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE2%TYPE
    ,cust_attribute3                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE3%TYPE
    ,cust_attribute4                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE4%TYPE
    ,cust_attribute5                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE5%TYPE
    ,cust_attribute6                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE6%TYPE
    ,cust_attribute7                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE7%TYPE
    ,cust_attribute8                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE8%TYPE
    ,cust_attribute9                OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE9%TYPE
    ,cust_attribute10               OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE10%TYPE
    ,cust_attribute11               OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE11%TYPE
    ,cust_attribute12               OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE12%TYPE
    ,cust_attribute13               OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE13%TYPE
    ,cust_attribute14               OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE14%TYPE
    ,cust_attribute15               OKL_TRX_EXTENSION_V.CUST_ATTRIBUTE15%TYPE
    ,rent_ia_contract_number        OKL_TRX_EXTENSION_V.RENT_IA_CONTRACT_NUMBER%TYPE
    ,res_ia_contract_number         OKL_TRX_EXTENSION_V.RES_IA_CONTRACT_NUMBER%TYPE
    ,inv_agrmnt_pool_number         OKL_TRX_EXTENSION_V.INV_AGRMNT_POOL_NUMBER%TYPE
    ,rent_ia_product_name           OKL_TRX_EXTENSION_V.RENT_IA_PRODUCT_NAME%TYPE
    ,res_ia_product_name            OKL_TRX_EXTENSION_V.RES_IA_PRODUCT_NAME%TYPE
    ,rent_ia_accounting_code        OKL_TRX_EXTENSION_V.RENT_IA_ACCOUNTING_CODE%TYPE
    ,res_ia_accounting_code         OKL_TRX_EXTENSION_V.RES_IA_ACCOUNTING_CODE%TYPE
    ,inv_agrmnt_synd_code           OKL_TRX_EXTENSION_V.INV_AGRMNT_SYND_CODE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_TRX_EXTENSION_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_TRX_EXTENSION_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,contract_status                OKL_TRX_EXTENSION_V.CONTRACT_STATUS%TYPE
    ,inv_agrmnt_status              OKL_TRX_EXTENSION_V.INV_AGRMNT_STATUS%TYPE
    ,chr_operating_unit_name        OKL_TRX_EXTENSION_V.CHR_OPERATING_UNIT_NAME%TYPE
    ,transaction_type_name          OKL_TRX_EXTENSION_V.TRANSACTION_TYPE_NAME%TYPE
    ,contract_status_code           OKL_TRX_EXTENSION_V.CONTRACT_STATUS_CODE%TYPE
    ,inv_agrmnt_status_code         OKL_TRX_EXTENSION_V.INV_AGRMNT_STATUS_CODE%TYPE
    ,trx_type_class_code            OKL_TRX_EXTENSION_V.TRX_TYPE_CLASS_CODE%TYPE
    ,chr_operating_unit_code        OKL_TRX_EXTENSION_V.CHR_OPERATING_UNIT_CODE%TYPE
    ,party_id                       OKL_TRX_EXTENSION_V.PARTY_ID%TYPE
    ,cust_account_id                   OKL_TRX_EXTENSION_V.CUST_ACCOUNT_ID%TYPE
    ,cust_site_use_id               OKL_TRX_EXTENSION_V.CUST_SITE_USE_ID%TYPE );
  G_MISS_tehv_rec                         tehv_rec_type;
  TYPE tehv_tbl_type IS TABLE OF tehv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TRX_EXTENSION_B Record Spec
  TYPE teh_rec_type IS RECORD (
     header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_TRX_EXTENSION_B.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,contract_number                OKL_TRX_EXTENSION_B.CONTRACT_NUMBER%TYPE
    ,inv_agrmnt_number              OKL_TRX_EXTENSION_B.INV_AGRMNT_NUMBER%TYPE
    ,contract_currency_code         OKL_TRX_EXTENSION_B.CONTRACT_CURRENCY_CODE%TYPE
    ,inv_agrmnt_currency_code       OKL_TRX_EXTENSION_B.INV_AGRMNT_CURRENCY_CODE%TYPE
    ,contract_effective_from        OKL_TRX_EXTENSION_B.CONTRACT_EFFECTIVE_FROM%TYPE
    ,inv_agrmnt_effective_from      OKL_TRX_EXTENSION_B.INV_AGRMNT_EFFECTIVE_FROM%TYPE
    ,customer_name                  OKL_TRX_EXTENSION_B.CUSTOMER_NAME%TYPE
    ,sales_rep_name                 OKL_TRX_EXTENSION_B.SALES_REP_NAME%TYPE
    ,customer_account_number        OKL_TRX_EXTENSION_B.CUSTOMER_ACCOUNT_NUMBER%TYPE
    ,bill_to_address_num            NUMBER
    ,int_calc_method_code           OKL_TRX_EXTENSION_B.INT_CALC_METHOD_CODE%TYPE
    ,rev_rec_method_code            OKL_TRX_EXTENSION_B.REV_REC_METHOD_CODE%TYPE
    ,converted_number               OKL_TRX_EXTENSION_B.CONVERTED_NUMBER%TYPE
    ,assignable_flag                OKL_TRX_EXTENSION_B.ASSIGNABLE_FLAG%TYPE
    ,credit_line_number             OKL_TRX_EXTENSION_B.CREDIT_LINE_NUMBER%TYPE
    ,master_lease_number            OKL_TRX_EXTENSION_B.MASTER_LEASE_NUMBER%TYPE
    ,po_order_number                OKL_TRX_EXTENSION_B.PO_ORDER_NUMBER%TYPE
    ,vendor_program_number          OKL_TRX_EXTENSION_B.VENDOR_PROGRAM_NUMBER%TYPE
    ,ins_policy_type_code           OKL_TRX_EXTENSION_B.INS_POLICY_TYPE_CODE%TYPE
    ,ins_policy_number              OKL_TRX_EXTENSION_B.INS_POLICY_NUMBER%TYPE
    ,term_quote_accept_date         OKL_TRX_EXTENSION_B.TERM_QUOTE_ACCEPT_DATE%TYPE
    ,term_quote_num                 NUMBER
    ,term_quote_type_code           OKL_TRX_EXTENSION_B.TERM_QUOTE_TYPE_CODE%TYPE
    ,converted_account_flag         OKL_TRX_EXTENSION_B.CONVERTED_ACCOUNT_FLAG%TYPE
    ,accrual_override_flag          OKL_TRX_EXTENSION_B.ACCRUAL_OVERRIDE_FLAG%TYPE
    ,cust_attribute_category        OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE_CATEGORY%TYPE
    ,cust_attribute1                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE1%TYPE
    ,cust_attribute2                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE2%TYPE
    ,cust_attribute3                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE3%TYPE
    ,cust_attribute4                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE4%TYPE
    ,cust_attribute5                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE5%TYPE
    ,cust_attribute6                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE6%TYPE
    ,cust_attribute7                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE7%TYPE
    ,cust_attribute8                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE8%TYPE
    ,cust_attribute9                OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE9%TYPE
    ,cust_attribute10               OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE10%TYPE
    ,cust_attribute11               OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE11%TYPE
    ,cust_attribute12               OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE12%TYPE
    ,cust_attribute13               OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE13%TYPE
    ,cust_attribute14               OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE14%TYPE
    ,cust_attribute15               OKL_TRX_EXTENSION_B.CUST_ATTRIBUTE15%TYPE
    ,rent_ia_contract_number        OKL_TRX_EXTENSION_B.RENT_IA_CONTRACT_NUMBER%TYPE
    ,res_ia_contract_number         OKL_TRX_EXTENSION_B.RES_IA_CONTRACT_NUMBER%TYPE
    ,inv_agrmnt_pool_number         OKL_TRX_EXTENSION_B.INV_AGRMNT_POOL_NUMBER%TYPE
    ,rent_ia_product_name           OKL_TRX_EXTENSION_B.RENT_IA_PRODUCT_NAME%TYPE
    ,res_ia_product_name            OKL_TRX_EXTENSION_B.RES_IA_PRODUCT_NAME%TYPE
    ,rent_ia_accounting_code        OKL_TRX_EXTENSION_B.RENT_IA_ACCOUNTING_CODE%TYPE
    ,res_ia_accounting_code         OKL_TRX_EXTENSION_B.RES_IA_ACCOUNTING_CODE%TYPE
    ,inv_agrmnt_synd_code           OKL_TRX_EXTENSION_B.INV_AGRMNT_SYND_CODE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_TRX_EXTENSION_B.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_TRX_EXTENSION_B.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,contract_status_code           OKL_TRX_EXTENSION_B.CONTRACT_STATUS_CODE%TYPE
    ,inv_agrmnt_status_code         OKL_TRX_EXTENSION_B.INV_AGRMNT_STATUS_CODE%TYPE
    ,trx_type_class_code            OKL_TRX_EXTENSION_B.TRX_TYPE_CLASS_CODE%TYPE
    ,chr_operating_unit_code        OKL_TRX_EXTENSION_B.CHR_OPERATING_UNIT_CODE%TYPE
    ,party_id                       OKL_TRX_EXTENSION_V.PARTY_ID%TYPE
    ,cust_account_id                   OKL_TRX_EXTENSION_V.CUST_ACCOUNT_ID%TYPE
    ,cust_site_use_id               OKL_TRX_EXTENSION_V.CUST_SITE_USE_ID%TYPE );
  G_MISS_teh_rec                          teh_rec_type;
  TYPE teh_tbl_type IS TABLE OF teh_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TRX_EXTENSION_TL Record Spec
  TYPE tehl_rec_type IS RECORD (
     header_extension_id            NUMBER
    ,language                       OKL_TRX_EXTENSION_TL.LANGUAGE%TYPE
    ,source_lang                    OKL_TRX_EXTENSION_TL.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_TRX_EXTENSION_TL.SFWT_FLAG%TYPE
    ,contract_status                OKL_TRX_EXTENSION_TL.CONTRACT_STATUS%TYPE
    ,inv_agrmnt_status              OKL_TRX_EXTENSION_TL.INV_AGRMNT_STATUS%TYPE
    ,chr_operating_unit_name        OKL_TRX_EXTENSION_TL.CHR_OPERATING_UNIT_NAME%TYPE
    ,transaction_type_name          OKL_TRX_EXTENSION_TL.TRANSACTION_TYPE_NAME%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_TRX_EXTENSION_TL.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_TRX_EXTENSION_TL.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_tehl_rec                         tehl_rec_type;
  TYPE tehl_tbl_type IS TABLE OF tehl_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TEH_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_rec                     IN tehv_rec_type,
    x_tehv_rec                     OUT NOCOPY tehv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type,
    x_tehv_tbl                     OUT NOCOPY tehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type,
    x_tehv_tbl                     OUT NOCOPY tehv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_rec                     IN tehv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_rec                     IN tehv_rec_type,
    x_tehv_rec                     OUT NOCOPY tehv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type,
    x_tehv_tbl                     OUT NOCOPY tehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type,
    x_tehv_tbl                     OUT NOCOPY tehv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_rec                     IN tehv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_rec                     IN tehv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tehv_tbl                     IN tehv_tbl_type);
  -- Added : PRASJAIN : Bug# 6268782
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_teh_rec                      IN teh_rec_type,
    p_tehl_tbl                     IN tehl_tbl_type,
    x_teh_rec                      OUT NOCOPY teh_rec_type,
    x_tehl_tbl                     OUT NOCOPY tehl_tbl_type);
END OKL_TEH_PVT;

/
