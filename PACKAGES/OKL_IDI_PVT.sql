--------------------------------------------------------
--  DDL for Package OKL_IDI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_IDI_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSIDIS.pls 115.5 2002/02/06 11:48:13 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE idi_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    idi_type                       OKL_INDX_INTERFACES.IDI_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    process_flag                   NUMBER := OKC_API.G_MISS_NUM,
    proportion_contributed         NUMBER := OKC_API.G_MISS_NUM,
    index_name                     OKL_INDX_INTERFACES.INDEX_NAME%TYPE := OKC_API.G_MISS_CHAR,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    description                    OKL_INDX_INTERFACES.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    value                          NUMBER := OKC_API.G_MISS_NUM,
    datetime_valid                 OKL_INDX_INTERFACES.DATETIME_VALID%TYPE := OKC_API.G_MISS_DATE,
    datetime_invalid               OKL_INDX_INTERFACES.DATETIME_INVALID%TYPE := OKC_API.G_MISS_DATE,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_INDX_INTERFACES.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_INDX_INTERFACES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_INDX_INTERFACES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_INDX_INTERFACES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_INDX_INTERFACES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_INDX_INTERFACES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_INDX_INTERFACES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_INDX_INTERFACES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_INDX_INTERFACES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_INDX_INTERFACES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_INDX_INTERFACES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_INDX_INTERFACES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_INDX_INTERFACES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_INDX_INTERFACES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_INDX_INTERFACES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_INDX_INTERFACES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_INDX_INTERFACES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INDX_INTERFACES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INDX_INTERFACES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_idi_rec                          idi_rec_type;
  TYPE idi_tbl_type IS TABLE OF idi_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE idiv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    idi_type                       OKL_INDX_INTERFACES_V.IDI_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    process_flag                   NUMBER := OKC_API.G_MISS_NUM,
    proportion_contributed         NUMBER := OKC_API.G_MISS_NUM,
    index_name                     OKL_INDX_INTERFACES_V.INDEX_NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_INDX_INTERFACES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    value                          NUMBER := OKC_API.G_MISS_NUM,
    datetime_valid                 OKL_INDX_INTERFACES_V.DATETIME_VALID%TYPE := OKC_API.G_MISS_DATE,
    datetime_invalid               OKL_INDX_INTERFACES_V.DATETIME_INVALID%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_INDX_INTERFACES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_INDX_INTERFACES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_INDX_INTERFACES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_INDX_INTERFACES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_INDX_INTERFACES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_INDX_INTERFACES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_INDX_INTERFACES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_INDX_INTERFACES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_INDX_INTERFACES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_INDX_INTERFACES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_INDX_INTERFACES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_INDX_INTERFACES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_INDX_INTERFACES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_INDX_INTERFACES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_INDX_INTERFACES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_INDX_INTERFACES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_INDX_INTERFACES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INDX_INTERFACES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INDX_INTERFACES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_idiv_rec                         idiv_rec_type;
  TYPE idiv_tbl_type IS TABLE OF idiv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  -- Added 04/17/2001 Robin Edwin for validate attribute

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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_IDI_PVT';
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
    p_idiv_rec                     IN idiv_rec_type,
    x_idiv_rec                     OUT NOCOPY idiv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type,
    x_idiv_tbl                     OUT NOCOPY idiv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type,
    x_idiv_rec                     OUT NOCOPY idiv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type,
    x_idiv_tbl                     OUT NOCOPY idiv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_rec                     IN idiv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idiv_tbl                     IN idiv_tbl_type);

END OKL_IDI_PVT;

 

/
