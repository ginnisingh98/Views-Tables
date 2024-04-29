--------------------------------------------------------
--  DDL for Package OKL_IPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_IPT_PVT" AUTHID CURRENT_USER AS
   /* $Header: OKLSIPTS.pls 115.10 2003/01/28 01:46:52 smoduga noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ipt_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    isu_id                         NUMBER := OKC_API.G_MISS_NUM,
    ipd_id                         NUMBER := OKC_API.G_MISS_NUM,
    ipt_type                       OKL_INS_PRODUCTS_B.IPT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    policy_symbol                  OKL_INS_PRODUCTS_B.POLICY_SYMBOL%TYPE := OKC_API.G_MISS_CHAR,
    factor_code                  OKL_INS_PRODUCTS_B.FACTOR_CODE%TYPE := OKC_API.G_MISS_CHAR,
    factor_max                     NUMBER := OKC_API.G_MISS_NUM,
    factor_min                     NUMBER := OKC_API.G_MISS_NUM,
    coverage_min                   NUMBER := OKC_API.G_MISS_NUM,
    coverage_max                   NUMBER := OKC_API.G_MISS_NUM,
    deal_months_min                NUMBER := OKC_API.G_MISS_NUM,
    deal_months_max                NUMBER := OKC_API.G_MISS_NUM,
    date_from                      OKL_INS_PRODUCTS_B.DATE_FROM%TYPE := OKC_API.G_MISS_DATE,
    date_to                        OKL_INS_PRODUCTS_B.DATE_TO%TYPE := OKC_API.G_MISS_DATE,
    factor_amount_yn               OKL_INS_PRODUCTS_B.FACTOR_AMOUNT_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_INS_PRODUCTS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_INS_PRODUCTS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_INS_PRODUCTS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_INS_PRODUCTS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_INS_PRODUCTS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_INS_PRODUCTS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_INS_PRODUCTS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_INS_PRODUCTS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_INS_PRODUCTS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_INS_PRODUCTS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_INS_PRODUCTS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_INS_PRODUCTS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_INS_PRODUCTS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_INS_PRODUCTS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_INS_PRODUCTS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_INS_PRODUCTS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INS_PRODUCTS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INS_PRODUCTS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_ipt_rec                          ipt_rec_type;
  TYPE ipt_tbl_type IS TABLE OF ipt_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_ins_products_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_INS_PRODUCTS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_INS_PRODUCTS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_INS_PRODUCTS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKL_INS_PRODUCTS_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    factor_name                    OKL_INS_PRODUCTS_TL.FACTOR_NAME%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INS_PRODUCTS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INS_PRODUCTS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okl_ins_products_tl_rec          okl_ins_products_tl_rec_type;
  TYPE okl_ins_products_tl_tbl_type IS TABLE OF okl_ins_products_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE iptv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_INS_PRODUCTS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    isu_id                         NUMBER := OKC_API.G_MISS_NUM,
    ipd_id                         NUMBER := OKC_API.G_MISS_NUM,
    policy_symbol                  OKL_INS_PRODUCTS_V.POLICY_SYMBOL%TYPE := OKC_API.G_MISS_CHAR,
    ipt_type                       OKL_INS_PRODUCTS_V.IPT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKL_INS_PRODUCTS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    factor_max                     NUMBER := OKC_API.G_MISS_NUM,
    date_from                      OKL_INS_PRODUCTS_V.DATE_FROM%TYPE := OKC_API.G_MISS_DATE,
    factor_min                     NUMBER := OKC_API.G_MISS_NUM,
    date_to                        OKL_INS_PRODUCTS_V.DATE_TO%TYPE := OKC_API.G_MISS_DATE,
    factor_name                    OKL_INS_PRODUCTS_V.FACTOR_NAME%TYPE := OKC_API.G_MISS_CHAR,
    factor_code                    OKL_INS_PRODUCTS_V.FACTOR_CODE%TYPE := OKC_API.G_MISS_CHAR,
    coverage_min                   NUMBER := OKC_API.G_MISS_NUM,
    coverage_max                   NUMBER := OKC_API.G_MISS_NUM,
    deal_months_min                NUMBER := OKC_API.G_MISS_NUM,
    deal_months_max                NUMBER := OKC_API.G_MISS_NUM,
    factor_amount_yn               OKL_INS_PRODUCTS_V.FACTOR_AMOUNT_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_INS_PRODUCTS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_INS_PRODUCTS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_INS_PRODUCTS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_INS_PRODUCTS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_INS_PRODUCTS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_INS_PRODUCTS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_INS_PRODUCTS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_INS_PRODUCTS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_INS_PRODUCTS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_INS_PRODUCTS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_INS_PRODUCTS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_INS_PRODUCTS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_INS_PRODUCTS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_INS_PRODUCTS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_INS_PRODUCTS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_INS_PRODUCTS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INS_PRODUCTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INS_PRODUCTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_iptv_rec                         iptv_rec_type;
  TYPE iptv_tbl_type IS TABLE OF iptv_rec_type
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
  -- Added by Sridhar
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_DATE_RANGE_ERROR 		CONSTANT VARCHAR2(200) := 'OKC_DATE_RANGE_ERROR';
  G_UNEXPECTED_ERROR 		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_IPT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
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
    p_iptv_rec                     IN iptv_rec_type,
    x_iptv_rec                     OUT NOCOPY iptv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_tbl                     IN iptv_tbl_type,
    x_iptv_tbl                     OUT NOCOPY iptv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_rec                     IN iptv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_tbl                     IN iptv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_rec                     IN iptv_rec_type,
    x_iptv_rec                     OUT NOCOPY iptv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_tbl                     IN iptv_tbl_type,
    x_iptv_tbl                     OUT NOCOPY iptv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_rec                     IN iptv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_tbl                     IN iptv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_rec                     IN iptv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iptv_tbl                     IN iptv_tbl_type);
END OKL_IPT_PVT;

 

/
