--------------------------------------------------------
--  DDL for Package OKL_PXL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PXL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPXLS.pls 120.3 2007/12/21 12:59:38 rajnisku noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_EXT_AP_LINE_SOURCES_V Record Spec
  TYPE pxlv_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_EXT_AP_LINE_SOURCES_V.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,kle_id                         NUMBER
    ,sty_id                         NUMBER
    ,asset_number                   OKL_EXT_AP_LINE_SOURCES_V.ASSET_NUMBER%TYPE
    ,contract_line_number           OKL_EXT_AP_LINE_SOURCES_V.CONTRACT_LINE_NUMBER%TYPE
    ,asset_vendor_name              OKL_EXT_AP_LINE_SOURCES_V.ASSET_VENDOR_NAME%TYPE
    ,installed_site_id              NUMBER
    ,fixed_asset_location_name      OKL_EXT_AP_LINE_SOURCES_V.FIXED_ASSET_LOCATION_NAME%TYPE
    ,accounting_template_name       OKL_EXT_AP_LINE_SOURCES_V.ACCOUNTING_TEMPLATE_NAME%TYPE
    ,fee_type_code                  OKL_EXT_AP_LINE_SOURCES_V.FEE_TYPE_CODE%TYPE
    ,memo_flag                      OKL_EXT_AP_LINE_SOURCES_V.MEMO_FLAG%TYPE
    ,contract_line_type             OKL_EXT_AP_LINE_SOURCES_V.CONTRACT_LINE_TYPE%TYPE
    ,line_attribute_category        OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE_CATEGORY%TYPE
    ,line_attribute1                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE1%TYPE
    ,line_attribute2                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE2%TYPE
    ,line_attribute3                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE3%TYPE
    ,line_attribute4                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE4%TYPE
    ,line_attribute5                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE5%TYPE
    ,line_attribute6                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE6%TYPE
    ,line_attribute7                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE7%TYPE
    ,line_attribute8                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE8%TYPE
    ,line_attribute9                OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE9%TYPE
    ,line_attribute10               OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE10%TYPE
    ,line_attribute11               OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE11%TYPE
    ,line_attribute12               OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE12%TYPE
    ,line_attribute13               OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE13%TYPE
    ,line_attribute14               OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE14%TYPE
    ,line_attribute15               OKL_EXT_AP_LINE_SOURCES_V.LINE_ATTRIBUTE15%TYPE
    ,stream_type_code               OKL_EXT_AP_LINE_SOURCES_V.STREAM_TYPE_CODE%TYPE
    ,stream_type_purpose_code       OKL_EXT_AP_LINE_SOURCES_V.STREAM_TYPE_PURPOSE_CODE%TYPE
    ,inventory_org_code             OKL_EXT_AP_LINE_SOURCES_V.INVENTORY_ORG_CODE%TYPE
    ,language                       OKL_EXT_AP_LINE_SOURCES_V.LANGUAGE%TYPE
    ,inventory_org_name             OKL_EXT_AP_LINE_SOURCES_V.INVENTORY_ORG_NAME%TYPE
    ,stream_type_name               OKL_EXT_AP_LINE_SOURCES_V.STREAM_TYPE_NAME%TYPE
    ,trans_line_description         OKL_EXT_AP_LINE_SOURCES_V.TRANS_LINE_DESCRIPTION%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AP_LINE_SOURCES_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AP_LINE_SOURCES_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,asset_category_name            OKL_EXT_AP_LINE_SOURCES_V.ASSET_CATEGORY_NAME%TYPE
    ,inventory_item_name_code       OKL_EXT_AP_LINE_SOURCES_V.INVENTORY_ITEM_NAME_CODE%TYPE
    ,inventory_item_name            OKL_EXT_AP_LINE_SOURCES_V.INVENTORY_ITEM_NAME%TYPE
    ,asset_vendor_id            OKL_EXT_AP_LINE_SOURCES_V.ASSET_VENDOR_ID%TYPE);
  G_MISS_pxlv_rec                         pxlv_rec_type;
  TYPE pxlv_tbl_type IS TABLE OF pxlv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_EXT_AP_LINE_SOURCES_B Record Spec
  TYPE pxl_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_EXT_AP_LINE_SOURCES_B.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,kle_id                         NUMBER
    ,sty_id                         NUMBER
    ,asset_number                   OKL_EXT_AP_LINE_SOURCES_B.ASSET_NUMBER%TYPE
    ,contract_line_number           OKL_EXT_AP_LINE_SOURCES_B.CONTRACT_LINE_NUMBER%TYPE
    ,asset_vendor_name              OKL_EXT_AP_LINE_SOURCES_B.ASSET_VENDOR_NAME%TYPE
    ,installed_site_id              NUMBER
    ,fixed_asset_location_name      OKL_EXT_AP_LINE_SOURCES_B.FIXED_ASSET_LOCATION_NAME%TYPE
    ,accounting_template_name       OKL_EXT_AP_LINE_SOURCES_B.ACCOUNTING_TEMPLATE_NAME%TYPE
    ,fee_type_code                  OKL_EXT_AP_LINE_SOURCES_B.FEE_TYPE_CODE%TYPE
    ,memo_flag                      OKL_EXT_AP_LINE_SOURCES_B.MEMO_FLAG%TYPE
    ,contract_line_type             OKL_EXT_AP_LINE_SOURCES_B.CONTRACT_LINE_TYPE%TYPE
    ,line_attribute_category        OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE_CATEGORY%TYPE
    ,line_attribute1                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE1%TYPE
    ,line_attribute2                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE2%TYPE
    ,line_attribute3                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE3%TYPE
    ,line_attribute4                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE4%TYPE
    ,line_attribute5                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE5%TYPE
    ,line_attribute6                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE6%TYPE
    ,line_attribute7                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE7%TYPE
    ,line_attribute8                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE8%TYPE
    ,line_attribute9                OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE9%TYPE
    ,line_attribute10               OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE10%TYPE
    ,line_attribute11               OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE11%TYPE
    ,line_attribute12               OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE12%TYPE
    ,line_attribute13               OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE13%TYPE
    ,line_attribute14               OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE14%TYPE
    ,line_attribute15               OKL_EXT_AP_LINE_SOURCES_B.LINE_ATTRIBUTE15%TYPE
    ,stream_type_code               OKL_EXT_AP_LINE_SOURCES_B.STREAM_TYPE_CODE%TYPE
    ,stream_type_purpose_code       OKL_EXT_AP_LINE_SOURCES_B.STREAM_TYPE_PURPOSE_CODE%TYPE
    ,inventory_org_code             OKL_EXT_AP_LINE_SOURCES_B.INVENTORY_ORG_CODE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AP_LINE_SOURCES_B.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AP_LINE_SOURCES_B.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,asset_category_name            OKL_EXT_AP_LINE_SOURCES_B.ASSET_CATEGORY_NAME%TYPE
    ,inventory_item_name_code       OKL_EXT_AP_LINE_SOURCES_B.INVENTORY_ITEM_NAME_CODE%TYPE
    ,asset_vendor_id                OKL_EXT_AP_LINE_SOURCES_B.ASSET_VENDOR_ID%TYPE);
  G_MISS_pxl_rec                          pxl_rec_type;
  TYPE pxl_tbl_type IS TABLE OF pxl_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_EXT_AP_LINE_SOURCES_TL Record Spec
  TYPE pxll_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,language                       OKL_EXT_AP_LINE_SOURCES_TL.LANGUAGE%TYPE
    ,source_lang                    OKL_EXT_AP_LINE_SOURCES_TL.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_EXT_AP_LINE_SOURCES_TL.SFWT_FLAG%TYPE
    ,inventory_org_name             OKL_EXT_AP_LINE_SOURCES_TL.INVENTORY_ORG_NAME%TYPE
    ,stream_type_name               OKL_EXT_AP_LINE_SOURCES_TL.STREAM_TYPE_NAME%TYPE
    ,trans_line_description         OKL_EXT_AP_LINE_SOURCES_TL.TRANS_LINE_DESCRIPTION%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_AP_LINE_SOURCES_TL.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_AP_LINE_SOURCES_TL.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,inventory_item_name            OKL_EXT_AP_LINE_SOURCES_TL.INVENTORY_ITEM_NAME%TYPE);
  G_MISS_pxll_rec                         pxll_rec_type;
  TYPE pxll_tbl_type IS TABLE OF pxll_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_PXL_PVT';
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
    p_pxlv_rec                     IN pxlv_rec_type,
    x_pxlv_rec                     OUT NOCOPY pxlv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type,
    x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type,
    x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_rec                     IN pxlv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_rec                     IN pxlv_rec_type,
    x_pxlv_rec                     OUT NOCOPY pxlv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type,
    x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type,
    x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_rec                     IN pxlv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_rec                     IN pxlv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxlv_tbl                     IN pxlv_tbl_type);
  -- Added for Bug# 6268782 : PRASJAIN
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pxl_rec                      IN pxl_rec_type,
    p_pxll_tbl                     IN pxll_tbl_type,
    x_pxl_rec                      OUT NOCOPY pxl_rec_type,
    x_pxll_tbl                     OUT NOCOPY pxll_tbl_type);
END OKL_PXL_PVT;

/
