--------------------------------------------------------
--  DDL for Package OKL_RXL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RXL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSRXLS.pls 120.4 2007/12/27 14:25:31 zrehman noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_EXT_AR_LINE_SOURCES_V Record Spec
  TYPE rxlv_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_EXT_AR_LINE_SOURCES_V.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,kle_id                         NUMBER
    ,sty_id                         NUMBER
    ,asset_number                   OKL_EXT_AR_LINE_SOURCES_V.ASSET_NUMBER%TYPE
    ,contract_line_number           OKL_EXT_AR_LINE_SOURCES_V.CONTRACT_LINE_NUMBER%TYPE
    ,asset_vendor_name              OKL_EXT_AR_LINE_SOURCES_V.ASSET_VENDOR_NAME%TYPE
    ,installed_site_id              NUMBER
    ,fixed_asset_location_name      OKL_EXT_AR_LINE_SOURCES_V.FIXED_ASSET_LOCATION_NAME%TYPE
    ,subsidy_name                   OKL_EXT_AR_LINE_SOURCES_V.SUBSIDY_NAME%TYPE
    ,accounting_template_name       OKL_EXT_AR_LINE_SOURCES_V.ACCOUNTING_TEMPLATE_NAME%TYPE
    ,subsidy_party_name             OKL_EXT_AR_LINE_SOURCES_V.SUBSIDY_PARTY_NAME%TYPE
    ,contingency_code               OKL_EXT_AR_LINE_SOURCES_V.CONTINGENCY_CODE%TYPE
    ,fee_type_code                  OKL_EXT_AR_LINE_SOURCES_V.FEE_TYPE_CODE%TYPE
    ,memo_flag                      OKL_EXT_AR_LINE_SOURCES_V.MEMO_FLAG%TYPE
    ,contract_line_type             OKL_EXT_AR_LINE_SOURCES_V.CONTRACT_LINE_TYPE%TYPE
    ,line_attribute_category        OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE_CATEGORY%TYPE
    ,line_attribute1                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE1%TYPE
    ,line_attribute2                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE2%TYPE
    ,line_attribute3                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE3%TYPE
    ,line_attribute4                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE4%TYPE
    ,line_attribute5                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE5%TYPE
    ,line_attribute6                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE6%TYPE
    ,line_attribute7                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE7%TYPE
    ,line_attribute8                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE8%TYPE
    ,line_attribute9                OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE9%TYPE
    ,line_attribute10               OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE10%TYPE
    ,line_attribute11               OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE11%TYPE
    ,line_attribute12               OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE12%TYPE
    ,line_attribute13               OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE13%TYPE
    ,line_attribute14               OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE14%TYPE
    ,line_attribute15               OKL_EXT_AR_LINE_SOURCES_V.LINE_ATTRIBUTE15%TYPE
    ,stream_type_code               OKL_EXT_AR_LINE_SOURCES_V.STREAM_TYPE_CODE%TYPE
    ,stream_type_purpose_code       OKL_EXT_AR_LINE_SOURCES_V.STREAM_TYPE_PURPOSE_CODE%TYPE
    ,inventory_org_code             OKL_EXT_AR_LINE_SOURCES_V.INVENTORY_ORG_CODE%TYPE
    ,language                       OKL_EXT_AR_LINE_SOURCES_V.LANGUAGE%TYPE
    ,inventory_org_name             OKL_EXT_AR_LINE_SOURCES_V.INVENTORY_ORG_NAME%TYPE
    ,stream_type_name               OKL_EXT_AR_LINE_SOURCES_V.STREAM_TYPE_NAME%TYPE
    ,trans_line_description         OKL_EXT_AR_LINE_SOURCES_V.TRANS_LINE_DESCRIPTION%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AR_LINE_SOURCES_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AR_LINE_SOURCES_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    --Start : PRASJAIN : Bug#6334150
    ,asset_category_name            OKL_EXT_AR_LINE_SOURCES_V.ASSET_CATEGORY_NAME%TYPE
    ,inventory_item_name_code       OKL_EXT_AR_LINE_SOURCES_V.INVENTORY_ITEM_NAME_CODE%TYPE
    ,inventory_item_name            OKL_EXT_AR_LINE_SOURCES_V.INVENTORY_ITEM_NAME%TYPE
    ,asset_vendor_id                OKL_EXT_AR_LINE_SOURCES_V.ASSET_VENDOR_ID%TYPE
    ,subsidy_vendor_id              OKL_EXT_AR_LINE_SOURCES_V.SUBSIDY_VENDOR_ID%TYPE);
    --End : PRASJAIN : Bug#6334150
  G_MISS_rxlv_rec                         rxlv_rec_type;
  TYPE rxlv_tbl_type IS TABLE OF rxlv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_EXT_AR_LINE_SOURCES_TL Record Spec
  TYPE rxll_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,language                       OKL_EXT_AR_LINE_SOURCES_TL.LANGUAGE%TYPE
    ,source_lang                    OKL_EXT_AR_LINE_SOURCES_TL.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_EXT_AR_LINE_SOURCES_TL.SFWT_FLAG%TYPE
    ,inventory_org_name             OKL_EXT_AR_LINE_SOURCES_TL.INVENTORY_ORG_NAME%TYPE
    ,stream_type_name               OKL_EXT_AR_LINE_SOURCES_TL.STREAM_TYPE_NAME%TYPE
    ,trans_line_description         OKL_EXT_AR_LINE_SOURCES_TL.TRANS_LINE_DESCRIPTION%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AR_LINE_SOURCES_TL.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AR_LINE_SOURCES_TL.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    --Start : PRASJAIN : Bug#6334150
    ,inventory_item_name            OKL_EXT_AR_LINE_SOURCES_TL.INVENTORY_ITEM_NAME%TYPE
     ,asset_vendor_id           OKL_EXT_AR_LINE_SOURCES_V.ASSET_VENDOR_ID%TYPE
    ,subsidy_vendor_id            OKL_EXT_AR_LINE_SOURCES_V.SUBSIDY_VENDOR_ID%TYPE);
    --End : PRASJAIN : Bug#6334150
  G_MISS_rxll_rec                         rxll_rec_type;
  TYPE rxll_tbl_type IS TABLE OF rxll_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_EXT_AR_LINE_SOURCES_B Record Spec
  TYPE rxl_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_EXT_AR_LINE_SOURCES_B.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,kle_id                         NUMBER
    ,sty_id                         NUMBER
    ,asset_number                   OKL_EXT_AR_LINE_SOURCES_B.ASSET_NUMBER%TYPE
    ,contract_line_number           OKL_EXT_AR_LINE_SOURCES_B.CONTRACT_LINE_NUMBER%TYPE
    ,asset_vendor_name              OKL_EXT_AR_LINE_SOURCES_B.ASSET_VENDOR_NAME%TYPE
    ,installed_site_id              NUMBER
    ,fixed_asset_location_name      OKL_EXT_AR_LINE_SOURCES_B.FIXED_ASSET_LOCATION_NAME%TYPE
    ,subsidy_name                   OKL_EXT_AR_LINE_SOURCES_B.SUBSIDY_NAME%TYPE
    ,accounting_template_name       OKL_EXT_AR_LINE_SOURCES_B.ACCOUNTING_TEMPLATE_NAME%TYPE
    ,subsidy_party_name             OKL_EXT_AR_LINE_SOURCES_B.SUBSIDY_PARTY_NAME%TYPE
    ,contingency_code               OKL_EXT_AR_LINE_SOURCES_B.CONTINGENCY_CODE%TYPE
    ,fee_type_code                  OKL_EXT_AR_LINE_SOURCES_B.FEE_TYPE_CODE%TYPE
    ,memo_flag                      OKL_EXT_AR_LINE_SOURCES_B.MEMO_FLAG%TYPE
    ,contract_line_type             OKL_EXT_AR_LINE_SOURCES_B.CONTRACT_LINE_TYPE%TYPE
    ,line_attribute_category        OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE_CATEGORY%TYPE
    ,line_attribute1                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE1%TYPE
    ,line_attribute2                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE2%TYPE
    ,line_attribute3                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE3%TYPE
    ,line_attribute4                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE4%TYPE
    ,line_attribute5                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE5%TYPE
    ,line_attribute6                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE6%TYPE
    ,line_attribute7                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE7%TYPE
    ,line_attribute8                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE8%TYPE
    ,line_attribute9                OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE9%TYPE
    ,line_attribute10               OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE10%TYPE
    ,line_attribute11               OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE11%TYPE
    ,line_attribute12               OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE12%TYPE
    ,line_attribute13               OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE13%TYPE
    ,line_attribute14               OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE14%TYPE
    ,line_attribute15               OKL_EXT_AR_LINE_SOURCES_B.LINE_ATTRIBUTE15%TYPE
    ,stream_type_code               OKL_EXT_AR_LINE_SOURCES_B.STREAM_TYPE_CODE%TYPE
    ,stream_type_purpose_code       OKL_EXT_AR_LINE_SOURCES_B.STREAM_TYPE_PURPOSE_CODE%TYPE
    ,inventory_org_code             OKL_EXT_AR_LINE_SOURCES_B.INVENTORY_ORG_CODE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AR_LINE_SOURCES_B.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AR_LINE_SOURCES_B.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    --Start : PRASJAIN : Bug#6334150
    ,asset_category_name            OKL_EXT_AR_LINE_SOURCES_V.ASSET_CATEGORY_NAME%TYPE
    ,inventory_item_name_code       OKL_EXT_AR_LINE_SOURCES_V.INVENTORY_ITEM_NAME_CODE%TYPE
    --End : PRASJAIN : Bug#6334150
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
    ,asset_vendor_id                OKL_EXT_AR_LINE_SOURCES_B.ASSET_VENDOR_ID%TYPE
    ,subsidy_vendor_id              OKL_EXT_AR_LINE_SOURCES_B.SUBSIDY_VENDOR_ID%TYPE);
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end

  G_MISS_rxl_rec                          rxl_rec_type;
  TYPE rxl_tbl_type IS TABLE OF rxl_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_RXL_PVT';
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
    p_rxlv_rec                     IN rxlv_rec_type,
    x_rxlv_rec                     OUT NOCOPY rxlv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type,
    x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type,
    x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_rec                     IN rxlv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_rec                     IN rxlv_rec_type,
    x_rxlv_rec                     OUT NOCOPY rxlv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type,
    x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type,
    x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_rec                     IN rxlv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_rec                     IN rxlv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxlv_tbl                     IN rxlv_tbl_type);
  -- Added for Bug# 6268782 : PRASJAIN
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rxl_rec                      IN rxl_rec_type,
    p_rxll_tbl                     IN rxll_tbl_type,
    x_rxl_rec                      OUT NOCOPY rxl_rec_type,
    x_rxll_tbl                     OUT NOCOPY rxll_tbl_type);
END OKL_RXL_PVT;

/
