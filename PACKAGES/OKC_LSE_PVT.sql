--------------------------------------------------------
--  DDL for Package OKC_LSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_LSE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSLSES.pls 120.0 2005/05/25 18:47:18 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  G_UPPERCASE_REQUIRED         CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_UNQ			CONSTANT VARCHAR2(200) := 'OKC_VALUE_NOT_UNIQUE';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLcode';
  G_RETURN_STATUS                         VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  G_RECORD_STATUS                         VARCHAR2(1) := OKC_API.G_MISS_CHAR;
  TYPE lse_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    lty_code                       OKC_LINE_STYLES_B.LTY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    priced_yn                      OKC_LINE_STYLES_B.PRICED_YN%TYPE := OKC_API.G_MISS_CHAR,
    recursive_yn                   OKC_LINE_STYLES_B.RECURSIVE_YN%TYPE := OKC_API.G_MISS_CHAR,
    protected_yn                   OKC_LINE_STYLES_B.PROTECTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    lse_parent_id                  NUMBER := OKC_API.G_MISS_NUM,
    application_id                 OKC_LINE_STYLES_B.APPLICATION_ID%TYPE := OKC_API.G_MISS_NUM,
    lse_type                       OKC_LINE_STYLES_B.LSE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_LINE_STYLES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_LINE_STYLES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_LINE_STYLES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_LINE_STYLES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_LINE_STYLES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_LINE_STYLES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_LINE_STYLES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_LINE_STYLES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_LINE_STYLES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_LINE_STYLES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_LINE_STYLES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_LINE_STYLES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_LINE_STYLES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_LINE_STYLES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_LINE_STYLES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_LINE_STYLES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_LINE_STYLES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_LINE_STYLES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    item_to_price_yn               OKC_LINE_STYLES_B.ITEM_TO_PRICE_YN%TYPE := OKC_API.G_MISS_CHAR,
    price_basis_yn                 OKC_LINE_STYLES_B.PRICE_BASIS_YN%TYPE := OKC_API.G_MISS_CHAR,
    access_level                   OKC_LINE_STYLES_B.ACCESS_LEVEL%TYPE := OKC_API.G_MISS_CHAR,
    service_item_yn                OKC_LINE_STYLES_B.SERVICE_ITEM_YN%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_lse_rec                          lse_rec_type;
  TYPE lse_tbl_type IS TABLE OF lse_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okc_line_styles_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_LINE_STYLES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_LINE_STYLES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_LINE_STYLES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_LINE_STYLES_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_LINE_STYLES_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_LINE_STYLES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_LINE_STYLES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okc_line_styles_tl_rec           okc_line_styles_tl_rec_type;
  TYPE okc_line_styles_tl_tbl_type IS TABLE OF okc_line_styles_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE lsev_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    lty_code                       OKC_LINE_STYLES_V.LTY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    priced_yn                      OKC_LINE_STYLES_V.PRICED_YN%TYPE := OKC_API.G_MISS_CHAR,
    recursive_yn                   OKC_LINE_STYLES_V.RECURSIVE_YN%TYPE := OKC_API.G_MISS_CHAR,
    protected_yn                   OKC_LINE_STYLES_V.PROTECTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    lse_parent_id                  NUMBER := OKC_API.G_MISS_NUM,
    application_id                 OKC_LINE_STYLES_V.APPLICATION_ID%TYPE := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_LINE_STYLES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_LINE_STYLES_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_LINE_STYLES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_LINE_STYLES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_LINE_STYLES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_LINE_STYLES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_LINE_STYLES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_LINE_STYLES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_LINE_STYLES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_LINE_STYLES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_LINE_STYLES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_LINE_STYLES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_LINE_STYLES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_LINE_STYLES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_LINE_STYLES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_LINE_STYLES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_LINE_STYLES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_LINE_STYLES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_LINE_STYLES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    lse_type                       OKC_LINE_STYLES_V.LSE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_LINE_STYLES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_LINE_STYLES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    item_to_price_yn               OKC_LINE_STYLES_V.ITEM_TO_PRICE_YN%TYPE := OKC_API.G_MISS_CHAR,
    price_basis_yn                 OKC_LINE_STYLES_V.PRICE_BASIS_YN%TYPE := OKC_API.G_MISS_CHAR,
    access_level                   OKC_LINE_STYLES_V.ACCESS_LEVEL%TYPE := OKC_API.G_MISS_CHAR,
    service_item_yn                OKC_LINE_STYLES_V.SERVICE_ITEM_YN%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_lsev_rec                         lsev_rec_type;
  TYPE lsev_tbl_type IS TABLE OF lsev_rec_type
        INDEX BY BINARY_INTEGER;
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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_LSE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type,
    x_lsev_rec                     OUT NOCOPY lsev_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type,
    x_lsev_tbl                     OUT NOCOPY lsev_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type,
    x_lsev_rec                     OUT NOCOPY lsev_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type,
    x_lsev_tbl                     OUT NOCOPY lsev_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type);

END OKC_LSE_PVT;

 

/
