--------------------------------------------------------
--  DDL for Package OKC_SCR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SCR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRSCRS.pls 120.0 2005/05/25 19:14:02 appldev noship $  */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE scr_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    percent                        NUMBER := OKC_API.G_MISS_NUM,

    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,

    cle_id                         NUMBER := OKC_API.G_MISS_NUM,

    --ctc_id                         NUMBER := OKC_API.G_MISS_NUM,
    --replaced by SALESREP_ID1, SALESREP_ID2
    SALESREP_ID1                   OKC_K_SALES_CREDITS.SALESREP_ID1%TYPE := OKC_API.G_MISS_CHAR,
    SALESREP_ID2                   OKC_K_SALES_CREDITS.SALESREP_ID2%TYPE := OKC_API.G_MISS_CHAR,

    sales_credit_type_id1          OKC_K_SALES_CREDITS.SALES_CREDIT_TYPE_ID1%TYPE := OKC_API.G_MISS_CHAR,
    sales_credit_type_id2          OKC_K_SALES_CREDITS.SALES_CREDIT_TYPE_ID2%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_SALES_CREDITS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_SALES_CREDITS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);
  g_miss_scr_rec                          scr_rec_type;
  TYPE scr_tbl_type IS TABLE OF scr_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE scrv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    percent                        NUMBER := OKC_API.G_MISS_NUM,

    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,

    cle_id                         NUMBER := OKC_API.G_MISS_NUM,

    --ctc_id                         NUMBER := OKC_API.G_MISS_NUM,
    --replaced by SALESREP_ID1, SALESREP_ID2
    SALESREP_ID1                   OKC_K_SALES_CREDITS.SALESREP_ID1%TYPE := OKC_API.G_MISS_CHAR,
    SALESREP_ID2                   OKC_K_SALES_CREDITS.SALESREP_ID2%TYPE := OKC_API.G_MISS_CHAR,

    sales_credit_type_id1          OKC_K_SALES_CREDITS.SALES_CREDIT_TYPE_ID1%TYPE := OKC_API.G_MISS_CHAR,
    sales_credit_type_id2          OKC_K_SALES_CREDITS.SALES_CREDIT_TYPE_ID2%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_SALES_CREDITS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_SALES_CREDITS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_Miss_SCRV_REC               scrv_rec_type;
  TYPE scrv_tbl_type IS TABLE OF scrv_rec_type
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
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKC_SALES_CREDITS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME		CONSTANT VARCHAR2(200) := 'OKC_SCR_PVT';
  ---G_APP_NAME		CONSTANT VARCHAR2(3)   :=  OKO_DATATYPES.G_APP_NAME;
  G_APP_NAME		CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
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
    p_scrv_rec    IN scrv_rec_type,
    x_scrv_rec    OUT NOCOPY scrv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type,
    x_scrv_tbl    OUT NOCOPY scrv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type,
    x_scrv_rec    OUT NOCOPY scrv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type,
    x_scrv_tbl    OUT NOCOPY scrv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type);


  FUNCTION create_version(
    p_chr_id                                    IN NUMBER,
    p_major_version                             IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id                                    IN NUMBER,
    p_major_version                             IN NUMBER) RETURN VARCHAR2;

END OKC_SCR_PVT;

 

/
