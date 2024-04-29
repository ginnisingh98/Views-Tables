--------------------------------------------------------
--  DDL for Package OKL_AJL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AJL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAJLS.pls 120.2 2007/08/10 12:00:01 dpsingh ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ajl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    adj_id                         NUMBER := OKC_API.G_MISS_NUM,
    til_id                         NUMBER := OKC_API.G_MISS_NUM,
    tld_id                         NUMBER := OKC_API.G_MISS_NUM,
    psl_id                         NUMBER := OKC_API.G_MISS_NUM,
    code_combination_id            NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          OKL_TXL_ADJSTS_LNS_B.OBJECT_VERSION_NUMBER%TYPE,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    check_approval_limit_yn        OKL_TXL_ADJSTS_LNS_B.CHECK_APPROVAL_LIMIT_YN%TYPE := OKC_API.G_MISS_CHAR,
    receivables_adjustment_id      NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TXL_ADJSTS_LNS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE1%TYPE,
    attribute2                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE2%TYPE,
    attribute3                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE3%TYPE,
    attribute4                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE4%TYPE,
    attribute5                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE5%TYPE,
    attribute6                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE6%TYPE,
    attribute7                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE7%TYPE,
    attribute8                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE8%TYPE,
    attribute9                     OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE9%TYPE,
    attribute10                    OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE10%TYPE,
    attribute11                    OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE11%TYPE,
    attribute12                    OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE12%TYPE,
    attribute13                    OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE13%TYPE,
    attribute14                    OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE14%TYPE,
    attribute15                    OKL_TXL_ADJSTS_LNS_B.ATTRIBUTE15%TYPE,
    created_by                     OKL_TXL_ADJSTS_LNS_B.CREATED_BY%TYPE,
    creation_date                  OKL_TXL_ADJSTS_LNS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                OKL_TXL_ADJSTS_LNS_B.LAST_UPDATED_BY%TYPE,
    last_update_date               OKL_TXL_ADJSTS_LNS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              OKL_TXL_ADJSTS_LNS_B.LAST_UPDATE_LOGIN%TYPE,
     --Bug 6316320 dpsingh start
    khr_id                   NUMBER := OKL_API.G_MISS_NUM,
    sty_id                   NUMBER := OKL_API.G_MISS_NUM,
    kle_id                   NUMBER := OKL_API.G_MISS_NUM
    --Bug 6316320 dpsingh end
    );
  g_miss_ajl_rec                          ajl_rec_type;
  TYPE ajl_tbl_type IS TABLE OF ajl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_txl_adjsts_lns_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_TXL_ADJSTS_LNS_TL.LANGUAGE%TYPE,
    source_lang                    OKL_TXL_ADJSTS_LNS_TL.SOURCE_LANG%TYPE,
    sfwt_flag                      OKL_TXL_ADJSTS_LNS_TL.SFWT_FLAG%TYPE,
    created_by                     OKL_TXL_ADJSTS_LNS_TL.CREATED_BY%TYPE,
    creation_date                  OKL_TXL_ADJSTS_LNS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                OKL_TXL_ADJSTS_LNS_TL.LAST_UPDATED_BY%TYPE,
    last_update_date               OKL_TXL_ADJSTS_LNS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              OKL_TXL_ADJSTS_LNS_TL.LAST_UPDATE_LOGIN%TYPE);
  GMissOklTxlAdjstsLnsTlRec               okl_txl_adjsts_lns_tl_rec_type;
  TYPE okl_txl_adjsts_lns_tl_tbl_type IS TABLE OF okl_txl_adjsts_lns_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE ajlv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          OKL_TXL_ADJSTS_LNS_V.OBJECT_VERSION_NUMBER%TYPE,
    sfwt_flag                      OKL_TXL_ADJSTS_LNS_V.SFWT_FLAG%TYPE,
    adj_id                         NUMBER := OKC_API.G_MISS_NUM,
    til_id                         NUMBER := OKC_API.G_MISS_NUM,
    tld_id                         NUMBER := OKC_API.G_MISS_NUM,
    code_combination_id            NUMBER := OKC_API.G_MISS_NUM,
    psl_id                         NUMBER := OKC_API.G_MISS_NUM,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    check_approval_limit_yn        OKL_TXL_ADJSTS_LNS_V.CHECK_APPROVAL_LIMIT_YN%TYPE := OKC_API.G_MISS_CHAR,
    receivables_adjustment_id      NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE1%TYPE,
    attribute2                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE2%TYPE,
    attribute3                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE3%TYPE,
    attribute4                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE4%TYPE,
    attribute5                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE5%TYPE,
    attribute6                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE6%TYPE,
    attribute7                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE7%TYPE,
    attribute8                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE8%TYPE,
    attribute9                     OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE9%TYPE,
    attribute10                    OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE10%TYPE,
    attribute11                    OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE11%TYPE,
    attribute12                    OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE12%TYPE,
    attribute13                    OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE13%TYPE,
    attribute14                    OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE14%TYPE,
    attribute15                    OKL_TXL_ADJSTS_LNS_V.ATTRIBUTE15%TYPE,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TXL_ADJSTS_LNS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     OKL_TXL_ADJSTS_LNS_V.CREATED_BY%TYPE,
    creation_date                  OKL_TXL_ADJSTS_LNS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                OKL_TXL_ADJSTS_LNS_V.LAST_UPDATED_BY%TYPE,
    last_update_date               OKL_TXL_ADJSTS_LNS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              OKL_TXL_ADJSTS_LNS_V.LAST_UPDATE_LOGIN%TYPE,
     --Bug 6316320 dpsingh start
    khr_id                   NUMBER := OKL_API.G_MISS_NUM,
    sty_id                   NUMBER := OKL_API.G_MISS_NUM,
    kle_id                   NUMBER := OKL_API.G_MISS_NUM
    --Bug 6316320 dpsingh end
    );
  g_miss_ajlv_rec                         ajlv_rec_type;
  TYPE ajlv_tbl_type IS TABLE OF ajlv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AJL_PVT';
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
    p_ajlv_rec                     IN ajlv_rec_type,
    x_ajlv_rec                     OUT NOCOPY ajlv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type,
    x_ajlv_tbl                     OUT NOCOPY ajlv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type,
    x_ajlv_rec                     OUT NOCOPY ajlv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type,
    x_ajlv_tbl                     OUT NOCOPY ajlv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type);

END OKL_AJL_PVT;

/
