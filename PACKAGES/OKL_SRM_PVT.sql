--------------------------------------------------------
--  DDL for Package OKL_SRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SRM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSRMS.pls 115.1 2002/02/05 12:20:28 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE srm_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    sir_id                         NUMBER := OKC_API.G_MISS_NUM,
    error_code                     OKL_SIF_RET_ERRORS.ERROR_CODE%TYPE := OKC_API.G_MISS_CHAR,
    error_message                  OKL_SIF_RET_ERRORS.ERROR_MESSAGE%TYPE := OKC_API.G_MISS_CHAR,
    tag_name                       OKL_SIF_RET_ERRORS.TAG_NAME%TYPE := OKC_API.G_MISS_CHAR,
    tag_attribute_name             OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    tag_attribute_value            OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_SIF_RET_ERRORS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute01   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_RET_ERRORS.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_RET_ERRORS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_RET_ERRORS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_srm_rec                          srm_rec_type;
  TYPE srm_tbl_type IS TABLE OF srm_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE srmv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    error_code                     OKL_SIF_RET_ERRORS_V.ERROR_CODE%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_SIF_RET_ERRORS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    tag_attribute_name             OKL_SIF_RET_ERRORS_V.TAG_ATTRIBUTE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    tag_name                       OKL_SIF_RET_ERRORS_V.TAG_NAME%TYPE := OKC_API.G_MISS_CHAR,
    sir_id                         NUMBER := OKC_API.G_MISS_NUM,
    error_message                  OKL_SIF_RET_ERRORS_V.ERROR_MESSAGE%TYPE := OKC_API.G_MISS_CHAR,
    tag_attribute_value            OKL_SIF_RET_ERRORS_V.TAG_ATTRIBUTE_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute01   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_RET_ERRORS_V.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_RET_ERRORS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_RET_ERRORS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
    g_miss_srmv_rec                         srmv_rec_type;

  TYPE srmv_tbl_type IS TABLE OF srmv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_OKC_APP			CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SRM_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;


  -- START CHANGE : akjain -- 11/05/2001
  -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM','Unexpected Error'
  G_OKL_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) :='OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_OKL_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_OKL_NO_PARENT_RECORD	    CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  -- END CHANGE : akjain
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------

  /* END CHANGE akjain */


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
    p_srmv_rec                     IN srmv_rec_type,
    x_srmv_rec                     OUT NOCOPY srmv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type,
    x_srmv_tbl                     OUT NOCOPY srmv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type,
    x_srmv_rec                     OUT NOCOPY srmv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type,
    x_srmv_tbl                     OUT NOCOPY srmv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_rec                     IN srmv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srmv_tbl                     IN srmv_tbl_type);

END OKL_SRM_PVT;

 

/
