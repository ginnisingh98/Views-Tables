--------------------------------------------------------
--  DDL for Package OKL_AVL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AVL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAVLS.pls 120.2 2006/07/11 10:10:46 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE avl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_AE_TEMPLATES.NAME%TYPE := OKC_API.G_MISS_CHAR,
    set_of_books_id                NUMBER := OKC_API.G_MISS_NUM,
    sty_id                         NUMBER := OKC_API.G_MISS_NUM,
    try_id                         NUMBER := OKC_API.G_MISS_NUM,
    aes_id                         NUMBER := OKC_API.G_MISS_NUM,
    syt_code                       OKL_AE_TEMPLATES.SYT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    fac_code                       OKL_AE_TEMPLATES.FAC_CODE%TYPE := OKC_API.G_MISS_CHAR,
    fma_id                         NUMBER := OKC_API.G_MISS_NUM,
    advance_arrears                OKL_AE_TEMPLATES.ADVANCE_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
    post_to_gl                     OKL_AE_TEMPLATES.POST_TO_GL%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_AE_TEMPLATES.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_AE_TEMPLATES.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    memo_yn                        OKL_AE_TEMPLATES.MEMO_YN%TYPE := OKC_API.G_MISS_CHAR,
    prior_year_yn                  OKL_AE_TEMPLATES.PRIOR_YEAR_YN%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_AE_TEMPLATES.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    factoring_synd_flag            OKL_AE_TEMPLATES.FACTORING_SYND_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    end_date                       OKL_AE_TEMPLATES.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    accrual_yn                     OKL_AE_TEMPLATES.ACCRUAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_AE_TEMPLATES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_AE_TEMPLATES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_AE_TEMPLATES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_AE_TEMPLATES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_AE_TEMPLATES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_AE_TEMPLATES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_AE_TEMPLATES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_AE_TEMPLATES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_AE_TEMPLATES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_AE_TEMPLATES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_AE_TEMPLATES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_AE_TEMPLATES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_AE_TEMPLATES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_AE_TEMPLATES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_AE_TEMPLATES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_AE_TEMPLATES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_AE_TEMPLATES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_AE_TEMPLATES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,

    -- Added by HKPATEL for securitization changes
    inv_code			   OKL_AE_TEMPLATES.INV_CODE%TYPE := OKC_API.G_MISS_CHAR);

  g_miss_avl_rec                          avl_rec_type;
  TYPE avl_tbl_type IS TABLE OF avl_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE avlv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    try_id                         NUMBER := OKC_API.G_MISS_NUM,
    aes_id                         NUMBER := OKC_API.G_MISS_NUM,
    sty_id                         NUMBER := OKC_API.G_MISS_NUM,
    fma_id                         NUMBER := OKC_API.G_MISS_NUM,
    set_of_books_id                NUMBER := OKC_API.G_MISS_NUM,
    fac_code                       OKL_AE_TEMPLATES.FAC_CODE%TYPE := OKC_API.G_MISS_CHAR,
    syt_code                       OKL_AE_TEMPLATES.SYT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    post_to_gl                     OKL_AE_TEMPLATES.POST_TO_GL%TYPE := OKC_API.G_MISS_CHAR,
    advance_arrears                OKL_AE_TEMPLATES.ADVANCE_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
    memo_yn                        OKL_AE_TEMPLATES.MEMO_YN%TYPE := OKC_API.G_MISS_CHAR,
    prior_year_yn                  OKL_AE_TEMPLATES.PRIOR_YEAR_YN%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKL_AE_TEMPLATES.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_AE_TEMPLATES.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_AE_TEMPLATES.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    factoring_synd_flag            OKL_AE_TEMPLATES.FACTORING_SYND_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_AE_TEMPLATES.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKL_AE_TEMPLATES.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    accrual_yn                     OKL_AE_TEMPLATES.ACCRUAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_AE_TEMPLATES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_AE_TEMPLATES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_AE_TEMPLATES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_AE_TEMPLATES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_AE_TEMPLATES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_AE_TEMPLATES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_AE_TEMPLATES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_AE_TEMPLATES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_AE_TEMPLATES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_AE_TEMPLATES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_AE_TEMPLATES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_AE_TEMPLATES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_AE_TEMPLATES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_AE_TEMPLATES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_AE_TEMPLATES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_AE_TEMPLATES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_AE_TEMPLATES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_AE_TEMPLATES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,

     -- Added by HKPATEL for securitization changes
    inv_code			   OKL_AE_TEMPLATES.INV_CODE%TYPE := OKC_API.G_MISS_CHAR);

  g_miss_avlv_rec                         avlv_rec_type;
  TYPE avlv_tbl_type IS TABLE OF avlv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  -- Added 04/27/2001 Robin Edwin for validate attribute

  G_SQLCODE_TOKEN 	CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UNQS	CONSTANT VARCHAR2(200) := 'OKL_UNIQUE_KEY_VALIDATION_FAILED';

  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AVL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type,
    x_avlv_rec                     OUT NOCOPY avlv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type,
    x_avlv_tbl                     OUT NOCOPY avlv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type,
    x_avlv_rec                     OUT NOCOPY avlv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type,
    x_avlv_tbl                     OUT NOCOPY avlv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type);

END OKL_AVL_PVT;

/
