--------------------------------------------------------
--  DDL for Package OKL_ITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ITY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSITYS.pls 115.4 2002/06/04 09:47:56 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ity_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    inf_id                         NUMBER := okl_api.G_MISS_NUM,
    group_asset_yn                 OKL_INVOICE_TYPES_B.GROUP_ASSET_YN%TYPE := okl_api.G_MISS_CHAR,
    group_by_contract_yn           OKL_INVOICE_TYPES_B.GROUP_BY_CONTRACT_YN%TYPE := okl_api.G_MISS_CHAR,
    object_version_number          NUMBER := okl_api.G_MISS_NUM,
    attribute_category             OKL_INVOICE_TYPES_B.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR,
    attribute1                     OKL_INVOICE_TYPES_B.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR,
    attribute2                     OKL_INVOICE_TYPES_B.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                     OKL_INVOICE_TYPES_B.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR,
    attribute4                     OKL_INVOICE_TYPES_B.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR,
    attribute5                     OKL_INVOICE_TYPES_B.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                     OKL_INVOICE_TYPES_B.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                     OKL_INVOICE_TYPES_B.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                     OKL_INVOICE_TYPES_B.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                     OKL_INVOICE_TYPES_B.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_INVOICE_TYPES_B.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_INVOICE_TYPES_B.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_INVOICE_TYPES_B.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                    OKL_INVOICE_TYPES_B.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                    OKL_INVOICE_TYPES_B.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_INVOICE_TYPES_B.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_INVOICE_TYPES_B.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_INVOICE_TYPES_B.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  g_miss_ity_rec                          ity_rec_type;
  TYPE ity_tbl_type IS TABLE OF ity_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_invoice_types_tl_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    LANGUAGE                       OKL_INVOICE_TYPES_TL.LANGUAGE%TYPE := okl_api.G_MISS_CHAR,
    source_lang                    OKL_INVOICE_TYPES_TL.SOURCE_LANG%TYPE := okl_api.G_MISS_CHAR,
    sfwt_flag                      OKL_INVOICE_TYPES_TL.SFWT_FLAG%TYPE := okl_api.G_MISS_CHAR,
    name                           OKL_INVOICE_TYPES_TL.NAME%TYPE := okl_api.G_MISS_CHAR,
    description                    OKL_INVOICE_TYPES_TL.DESCRIPTION%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_INVOICE_TYPES_TL.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_INVOICE_TYPES_TL.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  GMissOklInvoiceTypesTlRec               okl_invoice_types_tl_rec_type;
  TYPE okl_invoice_types_tl_tbl_type IS TABLE OF okl_invoice_types_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE ityv_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    object_version_number          NUMBER := okl_api.G_MISS_NUM,
    sfwt_flag                      OKL_INVOICE_TYPES_V.SFWT_FLAG%TYPE := okl_api.G_MISS_CHAR,
    inf_id                         NUMBER := okl_api.G_MISS_NUM,
    name                           OKL_INVOICE_TYPES_V.NAME%TYPE := okl_api.G_MISS_CHAR,
    description                    OKL_INVOICE_TYPES_V.DESCRIPTION%TYPE := okl_api.G_MISS_CHAR,
    group_asset_yn                 OKL_INVOICE_TYPES_V.GROUP_ASSET_YN%TYPE := okl_api.G_MISS_CHAR,
    group_by_contract_yn           OKL_INVOICE_TYPES_V.GROUP_BY_CONTRACT_YN%TYPE := okl_api.G_MISS_CHAR,
    attribute_category             OKL_INVOICE_TYPES_V.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR,
    attribute1                     OKL_INVOICE_TYPES_V.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR,
    attribute2                     OKL_INVOICE_TYPES_V.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                     OKL_INVOICE_TYPES_V.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR,
    attribute4                     OKL_INVOICE_TYPES_V.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR,
    attribute5                     OKL_INVOICE_TYPES_V.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                     OKL_INVOICE_TYPES_V.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                     OKL_INVOICE_TYPES_V.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                     OKL_INVOICE_TYPES_V.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                     OKL_INVOICE_TYPES_V.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_INVOICE_TYPES_V.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_INVOICE_TYPES_V.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_INVOICE_TYPES_V.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                    OKL_INVOICE_TYPES_V.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                    OKL_INVOICE_TYPES_V.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_INVOICE_TYPES_V.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_INVOICE_TYPES_V.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_INVOICE_TYPES_V.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  g_miss_ityv_rec                         ityv_rec_type;
  TYPE ityv_tbl_type IS TABLE OF ityv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := okl_api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := okl_api.G_RECORD_LOGICALLY_DELETED;

  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_CHILD_TABLE_TOKEN;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_NOT_SAME                CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ITY_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  okl_api.G_APP_NAME;

  G_VIEW   CONSTANT   VARCHAR2(30) := 'OKL_XTD_SELL_INVS_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type,
    x_ityv_rec                     OUT NOCOPY ityv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type,
    x_ityv_tbl                     OUT NOCOPY ityv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type,
    x_ityv_rec                     OUT NOCOPY ityv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type,
    x_ityv_tbl                     OUT NOCOPY ityv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_rec                     IN ityv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ityv_tbl                     IN ityv_tbl_type);

END Okl_Ity_Pvt;

 

/
