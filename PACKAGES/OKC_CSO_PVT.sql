--------------------------------------------------------
--  DDL for Package OKC_CSO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CSO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCSOS.pls 120.0 2005/05/25 19:21:00 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cso_rec_type IS RECORD (
    cro_code                       OKC_CONTACT_SOURCES.CRO_CODE%TYPE := OKC_API.G_MISS_CHAR,
    rle_code                       OKC_CONTACT_SOURCES.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    buy_or_sell                    OKC_CONTACT_SOURCES.BUY_OR_SELL%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKC_CONTACT_SOURCES.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_CONTACT_SOURCES.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    jtot_object_code               OKC_CONTACT_SOURCES.jtot_object_code%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CONTACT_SOURCES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CONTACT_SOURCES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    constrained_yn                 OKC_CONTACT_SOURCES.CONSTRAINED_YN%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    access_level                   OKC_CONTACT_SOURCES.ACCESS_LEVEL%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_cso_rec                          cso_rec_type;
  TYPE cso_tbl_type IS TABLE OF cso_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE csov_rec_type IS RECORD (
    rle_code                       OKC_CONTACT_SOURCES_V.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    cro_code                       OKC_CONTACT_SOURCES_V.CRO_CODE%TYPE := OKC_API.G_MISS_CHAR,
    buy_or_sell                    OKC_CONTACT_SOURCES_V.BUY_OR_SELL%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKC_CONTACT_SOURCES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_CONTACT_SOURCES_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    jtot_object_code               OKC_CONTACT_SOURCES_V.jtot_object_code%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    constrained_yn                 OKC_CONTACT_SOURCES_V.CONSTRAINED_YN%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CONTACT_SOURCES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CONTACT_SOURCES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    access_level                   OKC_CONTACT_SOURCES_V.ACCESS_LEVEL%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_csov_rec                         csov_rec_type;
  TYPE csov_tbl_type IS TABLE OF csov_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CSO_PVT';
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
    p_csov_rec                     IN csov_rec_type,
    x_csov_rec                     OUT NOCOPY csov_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_tbl                     IN csov_tbl_type,
    x_csov_tbl                     OUT NOCOPY csov_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_rec                     IN csov_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_tbl                     IN csov_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_rec                     IN csov_rec_type,
    x_csov_rec                     OUT NOCOPY csov_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_tbl                     IN csov_tbl_type,
    x_csov_tbl                     OUT NOCOPY csov_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_rec                     IN csov_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_tbl                     IN csov_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_rec                     IN csov_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csov_tbl                     IN csov_tbl_type);

END OKC_CSO_PVT;

 

/
