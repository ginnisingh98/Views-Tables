--------------------------------------------------------
--  DDL for Package OKL_PQV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PQV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPQVS.pls 115.5 2002/02/05 12:18:57 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE pqv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    pdq_id                         NUMBER := OKC_API.G_MISS_NUM,
    pdt_id                         NUMBER := OKC_API.G_MISS_NUM,
    qve_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    from_date                      OKL_PDT_PQY_VALS.FROM_DATE%TYPE := OKC_API.G_MISS_DATE,
    to_date                        OKL_PDT_PQY_VALS.TO_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_PDT_PQY_VALS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_PDT_PQY_VALS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_pqv_rec                          pqv_rec_type;
  TYPE pqv_tbl_type IS TABLE OF pqv_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE pqvv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    pdq_id                         NUMBER := OKC_API.G_MISS_NUM,
    pdt_id                         NUMBER := OKC_API.G_MISS_NUM,
    qve_id                         NUMBER := OKC_API.G_MISS_NUM,
    from_date                      OKL_PDT_PQY_VALS_V.FROM_DATE%TYPE := OKC_API.G_MISS_DATE,
    to_date                        OKL_PDT_PQY_VALS_V.TO_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_PDT_PQY_VALS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_PDT_PQY_VALS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_pqvv_rec                         pqvv_rec_type;
  TYPE pqvv_tbl_type IS TABLE OF pqvv_rec_type
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
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TO_DATE_ERROR	CONSTANT VARCHAR2(200) := 'OKL_TO_DATE_ERROR';

  G_TABLE_TOKEN                 CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME'; --- CHG001
  G_UNQS	                CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE'; --- CHG001

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  G_ITEM_NOT_FOUND_ERROR       EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PQV_PVT';
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
    p_pqvv_rec                     IN pqvv_rec_type,
    x_pqvv_rec                     OUT NOCOPY pqvv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_tbl                     IN pqvv_tbl_type,
    x_pqvv_tbl                     OUT NOCOPY pqvv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_rec                     IN pqvv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_tbl                     IN pqvv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_rec                     IN pqvv_rec_type,
    x_pqvv_rec                     OUT NOCOPY pqvv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_tbl                     IN pqvv_tbl_type,
    x_pqvv_tbl                     OUT NOCOPY pqvv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_rec                     IN pqvv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_tbl                     IN pqvv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_rec                     IN pqvv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqvv_tbl                     IN pqvv_tbl_type);

END OKL_PQV_PVT;

 

/
