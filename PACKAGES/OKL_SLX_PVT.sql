--------------------------------------------------------
--  DDL for Package OKL_SLX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SLX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSLXS.pls 115.1 2002/02/06 20:35:37 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE slxv_rec_type IS RECORD (
     id                             NUMBER := Okc_Api.G_MISS_NUM
    ,lpo_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,sty_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,object_version_number          NUMBER := Okc_Api.G_MISS_NUM
    ,late_policy_exempt_yn          OKL_STRM_TYPE_EXEMPT_V.LATE_POLICY_EXEMPT_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute_category             OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute1                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute2                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute3                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute4                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute5                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute6                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute7                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute8                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute9                     OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute10                    OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute11                    OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute12                    OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute13                    OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute14                    OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute15                    OKL_STRM_TYPE_EXEMPT_V.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR
    ,created_by                     NUMBER := Okc_Api.G_MISS_NUM
    ,creation_date                  OKL_STRM_TYPE_EXEMPT_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_updated_by                NUMBER := Okc_Api.G_MISS_NUM
    ,last_update_date               OKL_STRM_TYPE_EXEMPT_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  G_MISS_slxv_rec                         slxv_rec_type;
  TYPE slxv_tbl_type IS TABLE OF slxv_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE slx_rec_type IS RECORD (
     id                             NUMBER := Okc_Api.G_MISS_NUM
    ,lpo_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,sty_id                         NUMBER := Okc_Api.G_MISS_NUM
    ,object_version_number          NUMBER := Okc_Api.G_MISS_NUM
    ,late_policy_exempt_yn          OKL_STRM_TYPE_EXEMPT.LATE_POLICY_EXEMPT_YN%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute_category             OKL_STRM_TYPE_EXEMPT.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute1                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute2                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute3                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute4                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute5                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute6                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute7                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute8                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute9                     OKL_STRM_TYPE_EXEMPT.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute10                    OKL_STRM_TYPE_EXEMPT.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute11                    OKL_STRM_TYPE_EXEMPT.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute12                    OKL_STRM_TYPE_EXEMPT.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute13                    OKL_STRM_TYPE_EXEMPT.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute14                    OKL_STRM_TYPE_EXEMPT.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR
    ,attribute15                    OKL_STRM_TYPE_EXEMPT.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR
    ,created_by                     NUMBER := Okc_Api.G_MISS_NUM
    ,creation_date                  OKL_STRM_TYPE_EXEMPT.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_updated_by                NUMBER := Okc_Api.G_MISS_NUM
    ,last_update_date               OKL_STRM_TYPE_EXEMPT.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE
    ,last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  G_MISS_slx_rec                          slx_rec_type;
  TYPE slx_tbl_type IS TABLE OF slx_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SLX_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := Okc_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type,
    x_slxv_rec                     OUT NOCOPY slxv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type,
    x_slxv_tbl                     OUT NOCOPY slxv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type);
   PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type,
    x_slxv_rec                     OUT NOCOPY slxv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type,
    x_slxv_tbl                     OUT NOCOPY slxv_tbl_type);
 PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type);
END Okl_Slx_Pvt;

 

/
