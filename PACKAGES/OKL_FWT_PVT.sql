--------------------------------------------------------
--  DDL for Package OKL_FWT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FWT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSFWTS.pls 115.3 2003/10/13 21:22:28 avsingh noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_FRENCH_TAX_V Record Spec
  TYPE fwtv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,sfwt_flag                      OKL_FRENCH_TAX_V.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,code                           OKL_FRENCH_TAX_V.CODE%TYPE := OKL_API.G_MISS_CHAR
    ,name                           OKL_FRENCH_TAX_V.NAME%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_FRENCH_TAX_V.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,start_date                     OKL_FRENCH_TAX_V.START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,end_date                       OKL_FRENCH_TAX_V.END_DATE%TYPE := OKL_API.G_MISS_DATE
    ,enabled_flag                   OKL_FRENCH_TAX_V.ENABLED_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_FRENCH_TAX_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_FRENCH_TAX_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_FRENCH_TAX_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_FRENCH_TAX_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_FRENCH_TAX_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_FRENCH_TAX_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_FRENCH_TAX_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_FRENCH_TAX_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_FRENCH_TAX_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_FRENCH_TAX_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_FRENCH_TAX_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_FRENCH_TAX_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_FRENCH_TAX_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_FRENCH_TAX_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_FRENCH_TAX_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_FRENCH_TAX_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_FRENCH_TAX_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_FRENCH_TAX_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_fwtv_rec                         fwtv_rec_type;
  TYPE fwtv_tbl_type IS TABLE OF fwtv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_FRENCH_TAX_TL Record Spec
  TYPE fwtt_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,language                       OKL_FRENCH_TAX_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR
    ,source_lang                    OKL_FRENCH_TAX_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_FRENCH_TAX_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,name                           OKL_FRENCH_TAX_TL.NAME%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_FRENCH_TAX_TL.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_FRENCH_TAX_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_FRENCH_TAX_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_fwtt_rec                         fwtt_rec_type;
  TYPE fwtt_tbl_type IS TABLE OF fwtt_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_FRENCH_TAX_B Record Spec
  TYPE fwt_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,code                           OKL_FRENCH_TAX_B.CODE%TYPE := OKL_API.G_MISS_CHAR
    ,start_date                     OKL_FRENCH_TAX_B.START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,end_date                       OKL_FRENCH_TAX_B.END_DATE%TYPE := OKL_API.G_MISS_DATE
    ,enabled_flag                   OKL_FRENCH_TAX_B.ENABLED_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_FRENCH_TAX_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_FRENCH_TAX_B.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_FRENCH_TAX_B.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_FRENCH_TAX_B.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_FRENCH_TAX_B.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_FRENCH_TAX_B.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_FRENCH_TAX_B.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_FRENCH_TAX_B.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_FRENCH_TAX_B.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_FRENCH_TAX_B.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_FRENCH_TAX_B.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_FRENCH_TAX_B.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_FRENCH_TAX_B.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_FRENCH_TAX_B.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_FRENCH_TAX_B.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_FRENCH_TAX_B.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_FRENCH_TAX_B.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_FRENCH_TAX_B.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_fwt_rec                          fwt_rec_type;
  TYPE fwt_tbl_type IS TABLE OF fwt_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_FWT_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type,
    x_fwtv_rec                     OUT NOCOPY fwtv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type,
    x_fwtv_rec                     OUT NOCOPY fwtv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    x_fwtv_tbl                     OUT NOCOPY fwtv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_rec                     IN fwtv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fwtv_tbl                     IN fwtv_tbl_type);
END OKL_FWT_PVT;

 

/
