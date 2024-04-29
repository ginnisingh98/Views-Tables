--------------------------------------------------------
--  DDL for Package OKL_PXH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PXH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPXHS.pls 120.3 2007/12/27 14:23:29 zrehman noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_EXT_AP_HEADER_SOURCES_V Record Spec
  TYPE pxhv_rec_type IS RECORD (
     header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_EXT_AP_HEADER_SOURCES_V.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,khr_id                         NUMBER
    ,try_id                         NUMBER
    ,trans_number                   OKL_EXT_AP_HEADER_SOURCES_V.TRANS_NUMBER%TYPE
    ,contract_number                OKL_EXT_AP_HEADER_SOURCES_V.CONTRACT_NUMBER%TYPE
    ,customer_name                  OKL_EXT_AP_HEADER_SOURCES_V.CUSTOMER_NAME%TYPE
    ,cust_account_number            OKL_EXT_AP_HEADER_SOURCES_V.CUST_ACCOUNT_NUMBER%TYPE
    ,product_name                   OKL_EXT_AP_HEADER_SOURCES_V.PRODUCT_NAME%TYPE
    ,book_classification_code       OKL_EXT_AP_HEADER_SOURCES_V.BOOK_CLASSIFICATION_CODE%TYPE
    ,tax_owner_code                 OKL_EXT_AP_HEADER_SOURCES_V.TAX_OWNER_CODE%TYPE
    ,int_calc_method_code           OKL_EXT_AP_HEADER_SOURCES_V.INT_CALC_METHOD_CODE%TYPE
    ,rev_rec_method_code            OKL_EXT_AP_HEADER_SOURCES_V.REV_REC_METHOD_CODE%TYPE
    ,scs_code                       OKL_EXT_AP_HEADER_SOURCES_V.SCS_CODE%TYPE
    ,converted_number               OKL_EXT_AP_HEADER_SOURCES_V.CONVERTED_NUMBER%TYPE
    ,contract_effective_from        OKL_EXT_AP_HEADER_SOURCES_V.CONTRACT_EFFECTIVE_FROM%TYPE
    ,contract_currency_code         OKL_EXT_AP_HEADER_SOURCES_V.CONTRACT_CURRENCY_CODE%TYPE
    ,sales_rep_name                 OKL_EXT_AP_HEADER_SOURCES_V.SALES_REP_NAME%TYPE
    ,po_order_number                OKL_EXT_AP_HEADER_SOURCES_V.PO_ORDER_NUMBER%TYPE
    ,vendor_program_number          OKL_EXT_AP_HEADER_SOURCES_V.VENDOR_PROGRAM_NUMBER%TYPE
    ,assignable_flag                OKL_EXT_AP_HEADER_SOURCES_V.ASSIGNABLE_FLAG%TYPE
    ,converted_account_flag         OKL_EXT_AP_HEADER_SOURCES_V.CONVERTED_ACCOUNT_FLAG%TYPE
    ,accrual_override_flag          OKL_EXT_AP_HEADER_SOURCES_V.ACCRUAL_OVERRIDE_FLAG%TYPE
    ,khr_attribute_category         OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE_CATEGORY%TYPE
    ,khr_attribute1                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE1%TYPE
    ,khr_attribute2                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE2%TYPE
    ,khr_attribute3                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE3%TYPE
    ,khr_attribute4                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE4%TYPE
    ,khr_attribute5                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE5%TYPE
    ,khr_attribute6                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE6%TYPE
    ,khr_attribute7                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE7%TYPE
    ,khr_attribute8                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE8%TYPE
    ,khr_attribute9                 OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE9%TYPE
    ,khr_attribute10                OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE10%TYPE
    ,khr_attribute11                OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE11%TYPE
    ,khr_attribute12                OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE12%TYPE
    ,khr_attribute13                OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE13%TYPE
    ,khr_attribute14                OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE14%TYPE
    ,khr_attribute15                OKL_EXT_AP_HEADER_SOURCES_V.KHR_ATTRIBUTE15%TYPE
    ,cust_attribute_category        OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE_CATEGORY%TYPE
    ,cust_attribute1                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE1%TYPE
    ,cust_attribute2                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE2%TYPE
    ,cust_attribute3                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE3%TYPE
    ,cust_attribute4                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE4%TYPE
    ,cust_attribute5                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE5%TYPE
    ,cust_attribute6                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE6%TYPE
    ,cust_attribute7                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE7%TYPE
    ,cust_attribute8                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE8%TYPE
    ,cust_attribute9                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE9%TYPE
    ,cust_attribute10               OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE10%TYPE
    ,cust_attribute11               OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE11%TYPE
    ,cust_attribute12               OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE12%TYPE
    ,cust_attribute13               OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE13%TYPE
    ,cust_attribute14               OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE14%TYPE
    ,cust_attribute15               OKL_EXT_AP_HEADER_SOURCES_V.CUST_ATTRIBUTE15%TYPE
    ,rent_ia_contract_number        OKL_EXT_AP_HEADER_SOURCES_V.RENT_IA_CONTRACT_NUMBER%TYPE
    ,rent_ia_product_name           OKL_EXT_AP_HEADER_SOURCES_V.RENT_IA_PRODUCT_NAME%TYPE
    ,rent_ia_accounting_code        OKL_EXT_AP_HEADER_SOURCES_V.RENT_IA_ACCOUNTING_CODE%TYPE
    ,res_ia_contract_number         OKL_EXT_AP_HEADER_SOURCES_V.RES_IA_CONTRACT_NUMBER%TYPE
    ,res_ia_product_name            OKL_EXT_AP_HEADER_SOURCES_V.RES_IA_PRODUCT_NAME%TYPE
    ,res_ia_accounting_code         OKL_EXT_AP_HEADER_SOURCES_V.RES_IA_ACCOUNTING_CODE%TYPE
    ,inv_agrmnt_number              OKL_EXT_AP_HEADER_SOURCES_V.INV_AGRMNT_NUMBER%TYPE
    ,inv_agrmnt_effective_from      OKL_EXT_AP_HEADER_SOURCES_V.INV_AGRMNT_EFFECTIVE_FROM%TYPE
    ,inv_agrmnt_product_name        OKL_EXT_AP_HEADER_SOURCES_V.INV_AGRMNT_PRODUCT_NAME%TYPE
    ,inv_agrmnt_currency_code       OKL_EXT_AP_HEADER_SOURCES_V.INV_AGRMNT_CURRENCY_CODE%TYPE
    ,inv_agrmnt_synd_code           OKL_EXT_AP_HEADER_SOURCES_V.INV_AGRMNT_SYND_CODE%TYPE
    ,inv_agrmnt_pool_number         OKL_EXT_AP_HEADER_SOURCES_V.INV_AGRMNT_POOL_NUMBER%TYPE
    ,contract_status_code           OKL_EXT_AP_HEADER_SOURCES_V.CONTRACT_STATUS_CODE%TYPE
    ,inv_agrmnt_status_code         OKL_EXT_AP_HEADER_SOURCES_V.INV_AGRMNT_STATUS_CODE%TYPE
    ,trx_type_class_code            OKL_EXT_AP_HEADER_SOURCES_V.TRX_TYPE_CLASS_CODE%TYPE
    ,language                       OKL_EXT_AP_HEADER_SOURCES_V.LANGUAGE%TYPE
    ,contract_status                OKL_EXT_AP_HEADER_SOURCES_V.CONTRACT_STATUS%TYPE
    ,inv_agrmnt_status              OKL_EXT_AP_HEADER_SOURCES_V.INV_AGRMNT_STATUS%TYPE
    ,transaction_type_name          OKL_EXT_AP_HEADER_SOURCES_V.TRANSACTION_TYPE_NAME%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AP_HEADER_SOURCES_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AP_HEADER_SOURCES_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
-- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
    ,party_id                       OKL_EXT_AP_HEADER_SOURCES_V.PARTY_ID%TYPE
    ,cust_account_id                OKL_EXT_AP_HEADER_SOURCES_V.CUST_ACCOUNT_ID%TYPE
-- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
    );
  G_MISS_pxhv_rec                         pxhv_rec_type;
  TYPE pxhv_tbl_type IS TABLE OF pxhv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_EXT_AP_HEADER_SOURCES_B Record Spec
  TYPE pxh_rec_type IS RECORD (
     header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_EXT_AP_HEADER_SOURCES_B.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,khr_id                         NUMBER
    ,try_id                         NUMBER
    ,trans_number                   OKL_EXT_AP_HEADER_SOURCES_B.TRANS_NUMBER%TYPE
    ,contract_number                OKL_EXT_AP_HEADER_SOURCES_B.CONTRACT_NUMBER%TYPE
    ,customer_name                  OKL_EXT_AP_HEADER_SOURCES_B.CUSTOMER_NAME%TYPE
    ,cust_account_number            OKL_EXT_AP_HEADER_SOURCES_B.CUST_ACCOUNT_NUMBER%TYPE
    ,product_name                   OKL_EXT_AP_HEADER_SOURCES_B.PRODUCT_NAME%TYPE
    ,book_classification_code       OKL_EXT_AP_HEADER_SOURCES_B.BOOK_CLASSIFICATION_CODE%TYPE
    ,tax_owner_code                 OKL_EXT_AP_HEADER_SOURCES_B.TAX_OWNER_CODE%TYPE
    ,int_calc_method_code           OKL_EXT_AP_HEADER_SOURCES_B.INT_CALC_METHOD_CODE%TYPE
    ,rev_rec_method_code            OKL_EXT_AP_HEADER_SOURCES_B.REV_REC_METHOD_CODE%TYPE
    ,scs_code                       OKL_EXT_AP_HEADER_SOURCES_B.SCS_CODE%TYPE
    ,converted_number               OKL_EXT_AP_HEADER_SOURCES_B.CONVERTED_NUMBER%TYPE
    ,contract_effective_from        OKL_EXT_AP_HEADER_SOURCES_B.CONTRACT_EFFECTIVE_FROM%TYPE
    ,contract_currency_code         OKL_EXT_AP_HEADER_SOURCES_B.CONTRACT_CURRENCY_CODE%TYPE
    ,sales_rep_name                 OKL_EXT_AP_HEADER_SOURCES_B.SALES_REP_NAME%TYPE
    ,po_order_number                OKL_EXT_AP_HEADER_SOURCES_B.PO_ORDER_NUMBER%TYPE
    ,vendor_program_number          OKL_EXT_AP_HEADER_SOURCES_B.VENDOR_PROGRAM_NUMBER%TYPE
    ,assignable_flag                OKL_EXT_AP_HEADER_SOURCES_B.ASSIGNABLE_FLAG%TYPE
    ,converted_account_flag         OKL_EXT_AP_HEADER_SOURCES_B.CONVERTED_ACCOUNT_FLAG%TYPE
    ,accrual_override_flag          OKL_EXT_AP_HEADER_SOURCES_B.ACCRUAL_OVERRIDE_FLAG%TYPE
    ,khr_attribute_category         OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE_CATEGORY%TYPE
    ,khr_attribute1                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE1%TYPE
    ,khr_attribute2                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE2%TYPE
    ,khr_attribute3                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE3%TYPE
    ,khr_attribute4                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE4%TYPE
    ,khr_attribute5                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE5%TYPE
    ,khr_attribute6                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE6%TYPE
    ,khr_attribute7                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE7%TYPE
    ,khr_attribute8                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE8%TYPE
    ,khr_attribute9                 OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE9%TYPE
    ,khr_attribute10                OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE10%TYPE
    ,khr_attribute11                OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE11%TYPE
    ,khr_attribute12                OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE12%TYPE
    ,khr_attribute13                OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE13%TYPE
    ,khr_attribute14                OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE14%TYPE
    ,khr_attribute15                OKL_EXT_AP_HEADER_SOURCES_B.KHR_ATTRIBUTE15%TYPE
    ,cust_attribute_category        OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE_CATEGORY%TYPE
    ,cust_attribute1                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE1%TYPE
    ,cust_attribute2                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE2%TYPE
    ,cust_attribute3                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE3%TYPE
    ,cust_attribute4                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE4%TYPE
    ,cust_attribute5                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE5%TYPE
    ,cust_attribute6                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE6%TYPE
    ,cust_attribute7                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE7%TYPE
    ,cust_attribute8                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE8%TYPE
    ,cust_attribute9                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE9%TYPE
    ,cust_attribute10               OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE10%TYPE
    ,cust_attribute11               OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE11%TYPE
    ,cust_attribute12               OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE12%TYPE
    ,cust_attribute13               OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE13%TYPE
    ,cust_attribute14               OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE14%TYPE
    ,cust_attribute15               OKL_EXT_AP_HEADER_SOURCES_B.CUST_ATTRIBUTE15%TYPE
    ,rent_ia_contract_number        OKL_EXT_AP_HEADER_SOURCES_B.RENT_IA_CONTRACT_NUMBER%TYPE
    ,rent_ia_product_name           OKL_EXT_AP_HEADER_SOURCES_B.RENT_IA_PRODUCT_NAME%TYPE
    ,rent_ia_accounting_code        OKL_EXT_AP_HEADER_SOURCES_B.RENT_IA_ACCOUNTING_CODE%TYPE
    ,res_ia_contract_number         OKL_EXT_AP_HEADER_SOURCES_B.RES_IA_CONTRACT_NUMBER%TYPE
    ,res_ia_product_name            OKL_EXT_AP_HEADER_SOURCES_B.RES_IA_PRODUCT_NAME%TYPE
    ,res_ia_accounting_code         OKL_EXT_AP_HEADER_SOURCES_B.RES_IA_ACCOUNTING_CODE%TYPE
    ,inv_agrmnt_number              OKL_EXT_AP_HEADER_SOURCES_B.INV_AGRMNT_NUMBER%TYPE
    ,inv_agrmnt_effective_from      OKL_EXT_AP_HEADER_SOURCES_B.INV_AGRMNT_EFFECTIVE_FROM%TYPE
    ,inv_agrmnt_product_name        OKL_EXT_AP_HEADER_SOURCES_B.INV_AGRMNT_PRODUCT_NAME%TYPE
    ,inv_agrmnt_currency_code       OKL_EXT_AP_HEADER_SOURCES_B.INV_AGRMNT_CURRENCY_CODE%TYPE
    ,inv_agrmnt_synd_code           OKL_EXT_AP_HEADER_SOURCES_B.INV_AGRMNT_SYND_CODE%TYPE
    ,inv_agrmnt_pool_number         OKL_EXT_AP_HEADER_SOURCES_B.INV_AGRMNT_POOL_NUMBER%TYPE
    ,contract_status_code           OKL_EXT_AP_HEADER_SOURCES_B.CONTRACT_STATUS_CODE%TYPE
    ,inv_agrmnt_status_code         OKL_EXT_AP_HEADER_SOURCES_B.INV_AGRMNT_STATUS_CODE%TYPE
    ,trx_type_class_code            OKL_EXT_AP_HEADER_SOURCES_B.TRX_TYPE_CLASS_CODE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AP_HEADER_SOURCES_B.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AP_HEADER_SOURCES_B.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
-- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
    ,party_id                       OKL_EXT_AP_HEADER_SOURCES_B.PARTY_ID%TYPE
    ,cust_account_id                OKL_EXT_AP_HEADER_SOURCES_B.CUST_ACCOUNT_ID%TYPE
-- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
    );
  G_MISS_pxh_rec                          pxh_rec_type;
  TYPE pxh_tbl_type IS TABLE OF pxh_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_EXT_AP_HEADER_SOURCES_TL Record Spec
  TYPE pxhl_rec_type IS RECORD (
     header_extension_id            NUMBER
    ,language                       OKL_EXT_AP_HEADER_SOURCES_TL.LANGUAGE%TYPE
    ,source_lang                    OKL_EXT_AP_HEADER_SOURCES_TL.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_EXT_AP_HEADER_SOURCES_TL.SFWT_FLAG%TYPE
    ,contract_status                OKL_EXT_AP_HEADER_SOURCES_TL.CONTRACT_STATUS%TYPE
    ,inv_agrmnt_status              OKL_EXT_AP_HEADER_SOURCES_TL.INV_AGRMNT_STATUS%TYPE
    ,transaction_type_name          OKL_EXT_AP_HEADER_SOURCES_TL.TRANSACTION_TYPE_NAME%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AP_HEADER_SOURCES_TL.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AP_HEADER_SOURCES_TL.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_pxhl_rec                         pxhl_rec_type;
  TYPE pxhl_tbl_type IS TABLE OF pxhl_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_PXH_PVT';
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
    p_pxhv_rec                     IN pxhv_rec_type,
    x_pxhv_rec                     OUT NOCOPY pxhv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type,
    x_pxhv_tbl                     OUT NOCOPY pxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type,
    x_pxhv_tbl                     OUT NOCOPY pxhv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_rec                     IN pxhv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_rec                     IN pxhv_rec_type,
    x_pxhv_rec                     OUT NOCOPY pxhv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type,
    x_pxhv_tbl                     OUT NOCOPY pxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type,
    x_pxhv_tbl                     OUT NOCOPY pxhv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_rec                     IN pxhv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_rec                     IN pxhv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxhv_tbl                     IN pxhv_tbl_type);
  -- Added for Bug# 6268782 : PRASJAIN
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxh_rec                      IN pxh_rec_type,
    p_pxhl_tbl                     IN pxhl_tbl_type,
    x_pxh_rec                      OUT NOCOPY pxh_rec_type,
    x_pxhl_tbl                     OUT NOCOPY pxhl_tbl_type);
END OKL_PXH_PVT;

/
