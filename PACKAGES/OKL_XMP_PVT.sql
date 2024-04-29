--------------------------------------------------------
--  DDL for Package OKL_XMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XMP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSXMPS.pls 120.0 2007/01/04 11:21:05 udhenuko noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_XMLP_PARAMS Record Spec
  TYPE xmp_rec_type IS RECORD (
     id                             NUMBER
    ,batch_id                       NUMBER
    ,param_name                     OKL_XMLP_PARAMS.PARAM_NAME%TYPE
    ,object_version_number          NUMBER
    ,param_type_code                OKL_XMLP_PARAMS.PARAM_TYPE_CODE%TYPE
    ,param_value                    OKL_XMLP_PARAMS.PARAM_VALUE%TYPE
    ,attribute_category             OKL_XMLP_PARAMS.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_XMLP_PARAMS.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_XMLP_PARAMS.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_XMLP_PARAMS.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_XMLP_PARAMS.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_XMLP_PARAMS.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_XMLP_PARAMS.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_XMLP_PARAMS.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_XMLP_PARAMS.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_XMLP_PARAMS.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_XMLP_PARAMS.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_XMLP_PARAMS.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_XMLP_PARAMS.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_XMLP_PARAMS.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_XMLP_PARAMS.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_XMLP_PARAMS.ATTRIBUTE15%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_XMLP_PARAMS.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_XMLP_PARAMS.LAST_UPDATE_DATE%TYPE
    ,last_update_login              OKL_XMLP_PARAMS.LAST_UPDATE_LOGIN%TYPE);
  G_MISS_xmp_rec                          xmp_rec_type;
  TYPE xmp_tbl_type IS TABLE OF xmp_rec_type
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
  G_RET_STS_ERROR                CONSTANT VARCHAR2(200) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR          CONSTANT VARCHAR2(200) := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_DB_ERROR                     CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_COL_ERROR                    CONSTANT VARCHAR2(30)  := 'OKL_COL_ERROR';
  G_OVN_ERROR                    CONSTANT VARCHAR2(30)  := 'OKL_OVN_ERROR';
  G_OVN_ERROR2                   CONSTANT VARCHAR2(30)  := 'OKL_OVN_ERROR2';
  G_OVN_ERROR3                   CONSTANT VARCHAR2(30)  := 'OKL_OVN_ERROR3';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_XMP_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type,
    x_xmp_rec                      OUT NOCOPY xmp_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    x_xmp_tbl                      OUT NOCOPY xmp_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type,
    x_xmp_rec                      OUT NOCOPY xmp_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    x_xmp_tbl                      OUT NOCOPY xmp_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    x_xmp_tbl                      OUT NOCOPY xmp_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type);
END OKL_XMP_PVT;

/
