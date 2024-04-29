--------------------------------------------------------
--  DDL for Package OKL_AES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAESS.pls 120.3 2005/10/30 03:43:27 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE aes_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_AE_TMPT_SETS.NAME%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_AE_TMPT_SETS.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_AE_TMPT_SETS.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    end_date                       OKL_AE_TMPT_SETS.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    description                    OKL_AE_TMPT_SETS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_AE_TMPT_SETS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_AE_TMPT_SETS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    gts_id                         NUMBER := OKC_API.G_MISS_NUM);
--added gts_id as a part of ER# 3944429
  g_miss_aes_rec                          aes_rec_type;
  TYPE aes_tbl_type IS TABLE OF aes_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE aesv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_AE_TMPT_SETS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_AE_TMPT_SETS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_AE_TMPT_SETS_V.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_AE_TMPT_SETS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKL_AE_TMPT_SETS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_AE_TMPT_SETS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_AE_TMPT_SETS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    gts_id                         NUMBER := OKC_API.G_MISS_NUM);
--added gts_id as a part of ER# 3944429
  g_miss_aesv_rec                         aesv_rec_type;
  TYPE aesv_tbl_type IS TABLE OF aesv_rec_type
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
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200):='OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';

  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLcode';


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AES_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNQS				CONSTANT VARCHAR2(200) := 'OKL_AES_ELEMENT_NOT_UNIQUE';

  ---------------------------------------------------------------------------

  -----------------  GLOBAL EXCEPTION
  --------------------------------------------------------

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  --------------------------------------------------------------------------------------
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
    p_aesv_rec                     IN aesv_rec_type,
    x_aesv_rec                     OUT NOCOPY aesv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type,
    x_aesv_tbl                     OUT NOCOPY aesv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type,
    x_aesv_rec                     OUT NOCOPY aesv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type,
    x_aesv_tbl                     OUT NOCOPY aesv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type);

END OKL_AES_PVT;

 

/
