--------------------------------------------------------
--  DDL for Package OKC_CGC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CGC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCGCS.pls 120.0 2005/05/25 22:41:02 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cgc_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cgp_parent_id                  NUMBER := OKC_API.G_MISS_NUM,
    included_cgp_id                NUMBER := OKC_API.G_MISS_NUM,
    included_chr_id                NUMBER := OKC_API.G_MISS_NUM,
    scs_code                       OKC_K_GRPINGS.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_GRPINGS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_GRPINGS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_cgc_rec                          cgc_rec_type;
  TYPE cgc_tbl_type IS TABLE OF cgc_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE cgcv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    cgp_parent_id                  NUMBER := OKC_API.G_MISS_NUM,
    included_chr_id                NUMBER := OKC_API.G_MISS_NUM,
    included_cgp_id                NUMBER := OKC_API.G_MISS_NUM,
    scs_code                       OKC_K_GRPINGS_V.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_GRPINGS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_GRPINGS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_cgcv_rec                         cgcv_rec_type;
  TYPE cgcv_tbl_type IS TABLE OF cgcv_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE qry_k_rec IS RECORD (
    id                             NUMBER,
    contract_number                VARCHAR2(255));
  TYPE qry_k_tbl IS TABLE OF qry_k_rec
	   INDEX BY BINARY_INTEGER;
  TYPE QueryKCursor IS REF CURSOR;
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
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_VIEW_NAME			CONSTANT VARCHAR2(200) := 'OKC_K_GRPINGS_V';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CGC_PVT';
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
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type);

  PROCEDURE insert_row_upg(x_return_status OUT NOCOPY VARCHAR2, p_cgcv_tbl IN cgcv_tbl_type);

  PROCEDURE Set_Search_String(
	 p_srch_str      IN         VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE Get_Queried_Contracts(
	 p_cgp_parent_id IN  NUMBER,
	 x_qry_k_tbl     OUT NOCOPY qry_k_tbl,
      x_return_status OUT NOCOPY VARCHAR2);

END OKC_CGC_PVT;

 

/
