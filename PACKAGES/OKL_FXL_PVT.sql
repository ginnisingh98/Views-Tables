--------------------------------------------------------
--  DDL for Package OKL_FXL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FXL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSFXLS.pls 120.3 2007/12/21 12:58:43 rajnisku noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_EXT_FA_LINE_SOURCES_V Record Spec
  TYPE fxlv_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_EXT_FA_LINE_SOURCES_V.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,fa_transaction_id              NUMBER
    ,asset_id                       NUMBER
    ,kle_id                         NUMBER
    ,asset_number                   OKL_EXT_FA_LINE_SOURCES_V.ASSET_NUMBER%TYPE
    ,contract_line_number           OKL_EXT_FA_LINE_SOURCES_V.CONTRACT_LINE_NUMBER%TYPE
    ,asset_book_type_name           OKL_EXT_FA_LINE_SOURCES_V.ASSET_BOOK_TYPE_NAME%TYPE
    ,asset_vendor_name              OKL_EXT_FA_LINE_SOURCES_V.ASSET_VENDOR_NAME%TYPE
    ,installed_site_id              NUMBER
    ,line_attribute_category        OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE_CATEGORY%TYPE
    ,line_attribute1                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE1%TYPE
    ,line_attribute2                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE2%TYPE
    ,line_attribute3                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE3%TYPE
    ,line_attribute4                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE4%TYPE
    ,line_attribute5                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE5%TYPE
    ,line_attribute6                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE6%TYPE
    ,line_attribute7                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE7%TYPE
    ,line_attribute8                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE8%TYPE
    ,line_attribute9                OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE9%TYPE
    ,line_attribute10               OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE10%TYPE
    ,line_attribute11               OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE11%TYPE
    ,line_attribute12               OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE12%TYPE
    ,line_attribute13               OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE13%TYPE
    ,line_attribute14               OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE14%TYPE
    ,line_attribute15               OKL_EXT_FA_LINE_SOURCES_V.LINE_ATTRIBUTE15%TYPE
    ,language                       OKL_EXT_FA_LINE_SOURCES_V.LANGUAGE%TYPE
    ,inventory_org_name             OKL_EXT_FA_LINE_SOURCES_V.INVENTORY_ORG_NAME%TYPE
    ,trans_line_description         OKL_EXT_FA_LINE_SOURCES_V.TRANS_LINE_DESCRIPTION%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_FA_LINE_SOURCES_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_FA_LINE_SOURCES_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,inventory_org_code             OKL_EXT_FA_LINE_SOURCES_V.INVENTORY_ORG_CODE%TYPE
    ,asset_book_type_code           OKL_EXT_FA_LINE_SOURCES_V.asset_book_type_code%TYPE
    ,period_counter                 NUMBER
    ,asset_vendor_id           OKL_EXT_FA_LINE_SOURCES_V.ASSET_VENDOR_ID%TYPE
    );

  G_MISS_fxlv_rec                         fxlv_rec_type;
  TYPE fxlv_tbl_type IS TABLE OF fxlv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_EXT_FA_LINE_SOURCES_B Record Spec
  TYPE fxl_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,header_extension_id            NUMBER
    ,source_id                      NUMBER
    ,source_table                   OKL_EXT_FA_LINE_SOURCES_B.SOURCE_TABLE%TYPE
    ,object_version_number          NUMBER
    ,fa_transaction_id              NUMBER
    ,asset_id                       NUMBER
    ,kle_id                         NUMBER
    ,asset_number                   OKL_EXT_FA_LINE_SOURCES_B.ASSET_NUMBER%TYPE
    ,contract_line_number           OKL_EXT_FA_LINE_SOURCES_B.CONTRACT_LINE_NUMBER%TYPE
    ,asset_book_type_name           OKL_EXT_FA_LINE_SOURCES_B.ASSET_BOOK_TYPE_NAME%TYPE
    ,asset_vendor_name              OKL_EXT_FA_LINE_SOURCES_B.ASSET_VENDOR_NAME%TYPE
    ,installed_site_id              NUMBER
    ,line_attribute_category        OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE_CATEGORY%TYPE
    ,line_attribute1                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE1%TYPE
    ,line_attribute2                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE2%TYPE
    ,line_attribute3                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE3%TYPE
    ,line_attribute4                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE4%TYPE
    ,line_attribute5                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE5%TYPE
    ,line_attribute6                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE6%TYPE
    ,line_attribute7                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE7%TYPE
    ,line_attribute8                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE8%TYPE
    ,line_attribute9                OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE9%TYPE
    ,line_attribute10               OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE10%TYPE
    ,line_attribute11               OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE11%TYPE
    ,line_attribute12               OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE12%TYPE
    ,line_attribute13               OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE13%TYPE
    ,line_attribute14               OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE14%TYPE
    ,line_attribute15               OKL_EXT_FA_LINE_SOURCES_B.LINE_ATTRIBUTE15%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_FA_LINE_SOURCES_B.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_FA_LINE_SOURCES_B.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,inventory_org_code             OKL_EXT_FA_LINE_SOURCES_B.INVENTORY_ORG_CODE%TYPE
    ,asset_book_type_code           OKL_EXT_FA_LINE_SOURCES_B.asset_book_type_code%TYPE
    ,period_counter                 NUMBER
     ,asset_vendor_id           OKL_EXT_FA_LINE_SOURCES_B.ASSET_VENDOR_ID%TYPE);
  G_MISS_fxl_rec                          fxl_rec_type;
  TYPE fxl_tbl_type IS TABLE OF fxl_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_EXT_FA_LINE_SOURCES_TL Record Spec
  TYPE fxll_rec_type IS RECORD (
     line_extension_id              NUMBER
    ,language                       OKL_EXT_FA_LINE_SOURCES_TL.LANGUAGE%TYPE
    ,source_lang                    OKL_EXT_FA_LINE_SOURCES_TL.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_EXT_FA_LINE_SOURCES_TL.SFWT_FLAG%TYPE
    ,inventory_org_name             OKL_EXT_FA_LINE_SOURCES_TL.INVENTORY_ORG_NAME%TYPE
    ,trans_line_description         OKL_EXT_FA_LINE_SOURCES_TL.TRANS_LINE_DESCRIPTION%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_EXT_FA_LINE_SOURCES_TL.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_EXT_FA_LINE_SOURCES_TL.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_fxll_rec                         fxll_rec_type;
  TYPE fxll_tbl_type IS TABLE OF fxll_rec_type
        INDEX BY BINARY_INTEGER;
  -- Start : PRASJAIN : Bug# 6268782
  TYPE fxl_tbl_rec_type IS RECORD(
         fxl_rec      okl_fxl_pvt.fxl_rec_type
        ,fxll_tbl     okl_fxl_pvt.fxll_tbl_type
  );
  TYPE fxl_tbl_tbl_type IS TABLE OF fxl_tbl_rec_type
    INDEX BY BINARY_INTEGER;
  -- End : PRASJAIN : Bug# 6268782
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_FXL_PVT';
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
    p_fxlv_rec                     IN fxlv_rec_type,
    x_fxlv_rec                     OUT NOCOPY fxlv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type,
    x_fxlv_rec                     OUT NOCOPY fxlv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type);
  -- Added : Bug# 6268782 : PRASJAIN
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxl_rec                      IN fxl_rec_type,
    p_fxll_tbl                     IN fxll_tbl_type,
    x_fxl_rec                      OUT NOCOPY fxl_rec_type,
    x_fxll_tbl                     OUT NOCOPY fxll_tbl_type);
END OKL_FXL_PVT;

/
