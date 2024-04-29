--------------------------------------------------------
--  DDL for Package OKL_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ADJ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSADJS.pls 120.3 2007/11/12 09:01:15 dcshanmu ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE adj_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    ccw_id                         NUMBER := OKC_API.G_MISS_NUM,
    tcn_id                         NUMBER := OKC_API.G_MISS_NUM,
    adjustment_reason_code         OKL_TRX_AR_ADJSTS_B.ADJUSTMENT_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR,
    apply_date                     OKL_TRX_AR_ADJSTS_B.APPLY_DATE%TYPE := OKC_API.G_MISS_DATE,
    object_version_number          OKL_TRX_AR_ADJSTS_B.OBJECT_VERSION_NUMBER%TYPE,
    gl_date                        OKL_TRX_AR_ADJSTS_B.GL_DATE%TYPE := OKC_API.G_MISS_DATE,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TRX_AR_ADJSTS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_TRX_AR_ADJSTS_B.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE1%TYPE,
    attribute2                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE2%TYPE,
    attribute3                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE3%TYPE,
    attribute4                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE4%TYPE,
    attribute5                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE5%TYPE,
    attribute6                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE6%TYPE,
    attribute7                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE7%TYPE,
    attribute8                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE8%TYPE,
    attribute9                     OKL_TRX_AR_ADJSTS_B.ATTRIBUTE9%TYPE,
    attribute10                    OKL_TRX_AR_ADJSTS_B.ATTRIBUTE10%TYPE,
    attribute11                    OKL_TRX_AR_ADJSTS_B.ATTRIBUTE11%TYPE,
    attribute12                    OKL_TRX_AR_ADJSTS_B.ATTRIBUTE12%TYPE,
    attribute13                    OKL_TRX_AR_ADJSTS_B.ATTRIBUTE13%TYPE,
    attribute14                    OKL_TRX_AR_ADJSTS_B.ATTRIBUTE14%TYPE,
    attribute15                    OKL_TRX_AR_ADJSTS_B.ATTRIBUTE15%TYPE,
    created_by                     OKL_TRX_AR_ADJSTS_B.CREATED_BY%TYPE,
    creation_date                  OKL_TRX_AR_ADJSTS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                OKL_TRX_AR_ADJSTS_B.LAST_UPDATED_BY%TYPE,
    last_update_date               OKL_TRX_AR_ADJSTS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              OKL_TRX_AR_ADJSTS_B.LAST_UPDATE_LOGIN%TYPE,
    trx_status_code                OKL_TRX_AR_ADJSTS_B.TRX_STATUS_CODE%TYPE := OKC_API.G_MISS_CHAR,
     --Bug 6316320 dpsingh start
    try_id                   NUMBER := OKL_API.G_MISS_NUM,
    --Bug 6316320 dpsingh end
     --gkhuntet start 02-Nov-07
    TRANSACTION_DATE              OKL_TRX_AR_INVOICES_B.TRANSACTION_DATE%TYPE := Okl_Api.G_MISS_DATE
     --gkhuntet end 02-Nov-07
    );
  g_miss_adj_rec                          adj_rec_type;
  TYPE adj_tbl_type IS TABLE OF adj_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_trx_ar_adjsts_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_TRX_AR_ADJSTS_TL.LANGUAGE%TYPE,
    source_lang                    OKL_TRX_AR_ADJSTS_TL.SOURCE_LANG%TYPE,
    sfwt_flag                      OKL_TRX_AR_ADJSTS_TL.SFWT_FLAG%TYPE,
    comments                       OKL_TRX_AR_ADJSTS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     OKL_TRX_AR_ADJSTS_TL.CREATED_BY%TYPE,
    creation_date                  OKL_TRX_AR_ADJSTS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                OKL_TRX_AR_ADJSTS_TL.LAST_UPDATED_BY%TYPE,
    last_update_date               OKL_TRX_AR_ADJSTS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              OKL_TRX_AR_ADJSTS_TL.LAST_UPDATE_LOGIN%TYPE);
  GMissOklTrxArAdjstsTlRec                okl_trx_ar_adjsts_tl_rec_type;
  TYPE okl_trx_ar_adjsts_tl_tbl_type IS TABLE OF okl_trx_ar_adjsts_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE adjv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          OKL_TRX_AR_ADJSTS_V.OBJECT_VERSION_NUMBER%TYPE,
    sfwt_flag                      OKL_TRX_AR_ADJSTS_V.SFWT_FLAG%TYPE,
    trx_status_code                OKL_TRX_AR_ADJSTS_V.TRX_STATUS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    ccw_id                         NUMBER := OKC_API.G_MISS_NUM,
    tcn_id                         NUMBER := OKC_API.G_MISS_NUM,
    adjustment_reason_code         OKL_TRX_AR_ADJSTS_V.ADJUSTMENT_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR,
    apply_date                     OKL_TRX_AR_ADJSTS_V.APPLY_DATE%TYPE := OKC_API.G_MISS_DATE,
    gl_date                        OKL_TRX_AR_ADJSTS_V.GL_DATE%TYPE := OKC_API.G_MISS_DATE,
    comments                       OKL_TRX_AR_ADJSTS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_TRX_AR_ADJSTS_V.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE1%TYPE,
    attribute2                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE2%TYPE,
    attribute3                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE3%TYPE,
    attribute4                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE4%TYPE,
    attribute5                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE5%TYPE,
    attribute6                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE6%TYPE,
    attribute7                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE7%TYPE,
    attribute8                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE8%TYPE,
    attribute9                     OKL_TRX_AR_ADJSTS_V.ATTRIBUTE9%TYPE,
    attribute10                    OKL_TRX_AR_ADJSTS_V.ATTRIBUTE10%TYPE,
    attribute11                    OKL_TRX_AR_ADJSTS_V.ATTRIBUTE11%TYPE,
    attribute12                    OKL_TRX_AR_ADJSTS_V.ATTRIBUTE12%TYPE,
    attribute13                    OKL_TRX_AR_ADJSTS_V.ATTRIBUTE13%TYPE,
    attribute14                    OKL_TRX_AR_ADJSTS_V.ATTRIBUTE14%TYPE,
    attribute15                    OKL_TRX_AR_ADJSTS_V.ATTRIBUTE15%TYPE,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TRX_AR_ADJSTS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     OKL_TRX_AR_ADJSTS_V.CREATED_BY%TYPE,
    creation_date                  OKL_TRX_AR_ADJSTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                OKL_TRX_AR_ADJSTS_V.LAST_UPDATED_BY%TYPE,
    last_update_date               OKL_TRX_AR_ADJSTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              OKL_TRX_AR_ADJSTS_V.LAST_UPDATE_LOGIN%TYPE,
    --Bug 6316320 dpsingh start
    try_id                   NUMBER := OKL_API.G_MISS_NUM,
    --Bug 6316320 dpsingh end
       --gkhuntet start 02-Nov-07
    TRANSACTION_DATE              OKL_TRX_AR_INVOICES_B.TRANSACTION_DATE%TYPE := Okl_Api.G_MISS_DATE
     --gkhuntet end 02-Nov-07
    );
  g_miss_adjv_rec                         adjv_rec_type;
  TYPE adjv_tbl_type IS TABLE OF adjv_rec_type
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
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ADJ_PVT';
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
    p_adjv_rec                     IN adjv_rec_type,
    x_adjv_rec                     OUT NOCOPY adjv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type,
    x_adjv_tbl                     OUT NOCOPY adjv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type,
    x_adjv_rec                     OUT NOCOPY adjv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type,
    x_adjv_tbl                     OUT NOCOPY adjv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type);

END OKL_ADJ_PVT;

/