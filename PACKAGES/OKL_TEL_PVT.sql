--------------------------------------------------------
--  DDL for Package OKL_TEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TEL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTELS.pls 120.5 2007/12/21 13:01:41 rajnisku noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TXL_EXTENSION_V Record Spec
  TYPE telv_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,teh_id                         NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_TXL_EXTENSION_V.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,language                       OKL_TXL_EXTENSION_V.LANGUAGE%TYPE
    ,contract_line_number           OKL_TXL_EXTENSION_V.CONTRACT_LINE_NUMBER%TYPE
    ,fee_type_code                  OKL_TXL_EXTENSION_V.FEE_TYPE_CODE%TYPE
    ,asset_number                   OKL_TXL_EXTENSION_V.ASSET_NUMBER%TYPE
    ,asset_category_name            OKL_TXL_EXTENSION_V.ASSET_CATEGORY_NAME%TYPE
    ,asset_vendor_name              OKL_TXL_EXTENSION_V.ASSET_VENDOR_NAME%TYPE
    ,asset_manufacturer_name        OKL_TXL_EXTENSION_V.ASSET_MANUFACTURER_NAME%TYPE
    ,asset_year_manufactured        OKL_TXL_EXTENSION_V.ASSET_YEAR_MANUFACTURED%TYPE
    ,asset_model_number             OKL_TXL_EXTENSION_V.ASSET_MODEL_NUMBER%TYPE
    ,asset_delivered_date           OKL_TXL_EXTENSION_V.ASSET_DELIVERED_DATE%TYPE
    ,installed_site_id              NUMBER
    ,fixed_asset_location_name      OKL_TXL_EXTENSION_V.FIXED_ASSET_LOCATION_NAME%TYPE
    ,contingency_code               OKL_TXL_EXTENSION_V.CONTINGENCY_CODE%TYPE
    ,subsidy_name                   OKL_TXL_EXTENSION_V.SUBSIDY_NAME%TYPE
    ,subsidy_party_name             OKL_TXL_EXTENSION_V.SUBSIDY_PARTY_NAME%TYPE
    ,memo_flag                      OKL_TXL_EXTENSION_V.MEMO_FLAG%TYPE
    ,recievables_trx_type_name      OKL_TXL_EXTENSION_V.RECIEVABLES_TRX_TYPE_NAME%TYPE
    ,contract_line_type             OKL_TXL_EXTENSION_V.CONTRACT_LINE_TYPE%TYPE
    ,pay_supplier_site_name         OKL_TXL_EXTENSION_V.PAY_SUPPLIER_SITE_NAME%TYPE
    ,aging_bucket_name              OKL_TXL_EXTENSION_V.AGING_BUCKET_NAME%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_TXL_EXTENSION_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_TXL_EXTENSION_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,inventory_item_name            OKL_TXL_EXTENSION_V.INVENTORY_ITEM_NAME%TYPE
    ,inventory_org_name             OKL_TXL_EXTENSION_V.INVENTORY_ORG_NAME%TYPE
    ,inventory_item_name_code       OKL_TXL_EXTENSION_V.INVENTORY_ITEM_NAME_CODE%TYPE
    ,inventory_org_code             OKL_TXL_EXTENSION_V.INVENTORY_ORG_CODE%TYPE
    ,vendor_site_id             OKL_TXL_EXTENSION_V.VENDOR_SITE_ID%TYPE
    ,subsidy_vendor_id          OKL_TXL_EXTENSION_V.SUBSIDY_VENDOR_ID%TYPE
    ,asset_vendor_id          OKL_TXL_EXTENSION_V.ASSET_VENDOR_ID%TYPE);
  G_MISS_telv_rec                         telv_rec_type;
  TYPE telv_tbl_type IS TABLE OF telv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TXL_EXTENSION_TL Record Spec
  TYPE tell_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,language                       OKL_TXL_EXTENSION_TL.LANGUAGE%TYPE
    ,source_lang                    OKL_TXL_EXTENSION_TL.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_TXL_EXTENSION_TL.SFWT_FLAG%TYPE
    ,inventory_item_name            OKL_TXL_EXTENSION_TL.INVENTORY_ITEM_NAME%TYPE
    ,inventory_org_name             OKL_TXL_EXTENSION_TL.INVENTORY_ORG_NAME%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_TXL_EXTENSION_TL.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_TXL_EXTENSION_TL.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_tell_rec                         tell_rec_type;
  TYPE tell_tbl_type IS TABLE OF tell_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TXL_EXTENSION_B Record Spec
  TYPE tel_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_TXL_EXTENSION_B.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,contract_line_number           OKL_TXL_EXTENSION_B.CONTRACT_LINE_NUMBER%TYPE
    ,fee_type_code                  OKL_TXL_EXTENSION_B.FEE_TYPE_CODE%TYPE
    ,asset_number                   OKL_TXL_EXTENSION_B.ASSET_NUMBER%TYPE
    ,asset_category_name            OKL_TXL_EXTENSION_B.ASSET_CATEGORY_NAME%TYPE
    ,asset_vendor_name              OKL_TXL_EXTENSION_B.ASSET_VENDOR_NAME%TYPE
    ,asset_manufacturer_name        OKL_TXL_EXTENSION_B.ASSET_MANUFACTURER_NAME%TYPE
    ,asset_year_manufactured        OKL_TXL_EXTENSION_B.ASSET_YEAR_MANUFACTURED%TYPE
    ,asset_model_number             OKL_TXL_EXTENSION_B.ASSET_MODEL_NUMBER%TYPE
    ,asset_delivered_date           OKL_TXL_EXTENSION_B.ASSET_DELIVERED_DATE%TYPE
    ,installed_site_id              NUMBER
    ,fixed_asset_location_name      OKL_TXL_EXTENSION_B.FIXED_ASSET_LOCATION_NAME%TYPE
    ,contingency_code               OKL_TXL_EXTENSION_B.CONTINGENCY_CODE%TYPE
    ,subsidy_name                   OKL_TXL_EXTENSION_B.SUBSIDY_NAME%TYPE
    ,subsidy_party_name             OKL_TXL_EXTENSION_B.SUBSIDY_PARTY_NAME%TYPE
    ,memo_flag                      OKL_TXL_EXTENSION_B.MEMO_FLAG%TYPE
    ,recievables_trx_type_name      OKL_TXL_EXTENSION_B.RECIEVABLES_TRX_TYPE_NAME%TYPE
    ,aging_bucket_name              OKL_TXL_EXTENSION_B.AGING_BUCKET_NAME%TYPE
    ,contract_line_type             OKL_TXL_EXTENSION_B.CONTRACT_LINE_TYPE%TYPE
    ,pay_supplier_site_name         OKL_TXL_EXTENSION_B.PAY_SUPPLIER_SITE_NAME%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_TXL_EXTENSION_B.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_TXL_EXTENSION_B.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,teh_id                         NUMBER
    ,inventory_item_name_code       OKL_TXL_EXTENSION_B.INVENTORY_ITEM_NAME_CODE%TYPE
    ,inventory_org_code             OKL_TXL_EXTENSION_B.INVENTORY_ORG_CODE%TYPE
    ,vendor_site_id                 OKL_TXL_EXTENSION_B.VENDOR_SITE_ID%TYPE
   , subsidy_vendor_id              OKL_TXL_EXTENSION_B.SUBSIDY_VENDOR_ID%TYPE
   ,asset_vendor_id                 OKL_TXL_EXTENSION_B.ASSET_VENDOR_ID%TYPE);
  G_MISS_tel_rec                          tel_rec_type;
  TYPE tel_tbl_type IS TABLE OF tel_rec_type
        INDEX BY BINARY_INTEGER;
  -- Start : PRASJAIN : Bug# 6268782
  TYPE tel_tbl_rec_type IS RECORD(
         tel_rec      okl_tel_pvt.tel_rec_type
        ,tell_tbl     okl_tel_pvt.tell_tbl_type
  );
  TYPE tel_tbl_tbl_type IS TABLE OF tel_tbl_rec_type
    INDEX BY BINARY_INTEGER;
  -- End : PRASJAIN : Bug# 6268782
  TYPE txl_tbl_type  IS TABLE OF OKL_TXL_EXTENSION_B%ROWTYPE;
  TYPE txll_tbl_type IS TABLE OF OKL_TXL_EXTENSION_TL%ROWTYPE;
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TEL_PVT';
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
    p_telv_rec                     IN telv_rec_type,
    x_telv_rec                     OUT NOCOPY telv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    x_telv_tbl                     OUT NOCOPY telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    x_telv_tbl                     OUT NOCOPY telv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type,
    x_telv_rec                     OUT NOCOPY telv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    x_telv_tbl                     OUT NOCOPY telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    x_telv_tbl                     OUT NOCOPY telv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_rec                     IN telv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_telv_tbl                     IN telv_tbl_type);
  -- Added : PRASJAIN : Bug# 6268782
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tel_rec                      IN tel_rec_type,
    p_tell_tbl                     IN tell_tbl_type,
    x_tel_rec                      OUT NOCOPY tel_rec_type,
    x_tell_tbl                     OUT NOCOPY tell_tbl_type);
END OKL_TEL_PVT;

/
