--------------------------------------------------------
--  DDL for Package OKC_LSS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_LSS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSLSSS.pls 120.0 2005/05/26 09:52:44 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  G_UPPERCASE_REQUIRED         CONSTANT   VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLcode';
  G_RETURN_STATUS                         VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  G_RECORD_STATUS                         VARCHAR2(1) := OKC_API.G_MISS_CHAR;
  TYPE lss_rec_type IS RECORD (
    lse_id                         NUMBER := OKC_API.G_MISS_NUM,
    jtot_object_code               OKC_LINE_STYLE_SOURCES.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKC_LINE_STYLE_SOURCES.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_LINE_STYLE_SOURCES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_LINE_STYLE_SOURCES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_LINE_STYLE_SOURCES.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    access_level                   OKC_LINE_STYLE_SOURCES.access_level%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_lss_rec                          lss_rec_type;
  TYPE lss_tbl_type IS TABLE OF lss_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE lssv_rec_type IS RECORD (
    lse_id                         NUMBER := OKC_API.G_MISS_NUM,
    jtot_object_code               OKC_LINE_STYLE_SOURCES_V.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    start_date                     OKC_LINE_STYLE_SOURCES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_LINE_STYLE_SOURCES_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_LINE_STYLE_SOURCES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_LINE_STYLE_SOURCES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    access_level                   OKC_LINE_STYLE_SOURCES_V.access_level%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_lssv_rec                         lssv_rec_type;
  TYPE lssv_tbl_type IS TABLE OF lssv_rec_type
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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_LSS_PVT';
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
    p_lssv_rec                     IN lssv_rec_type,
    x_lssv_rec                     OUT NOCOPY lssv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type,
    x_lssv_tbl                     OUT NOCOPY lssv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type,
    x_lssv_rec                     OUT NOCOPY lssv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type,
    x_lssv_tbl                     OUT NOCOPY lssv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type);

END OKC_LSS_PVT;

 

/
