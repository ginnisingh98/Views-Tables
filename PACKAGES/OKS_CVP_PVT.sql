--------------------------------------------------------
--  DDL for Package OKS_CVP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CVP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSCVPS.pls 120.0 2005/05/25 17:45:36 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_COV_TYPES_V Record Spec
  TYPE cvpv_rec_type IS RECORD (
     code                           OKS_COV_TYPES_V.CODE%TYPE := OKC_API.G_MISS_CHAR
    ,meaning                        OKS_COV_TYPES_V.MEANING%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKS_COV_TYPES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,importance_level               NUMBER := OKC_API.G_MISS_NUM
    ,sfwt_flag                      OKS_COV_TYPES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,enabled_flag                   OKS_COV_TYPES_V.ENABLED_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,start_date_active              OKS_COV_TYPES_V.START_DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE
    ,end_date_active                OKS_COV_TYPES_V.END_DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_COV_TYPES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_COV_TYPES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKS_COV_TYPES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKS_COV_TYPES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKS_COV_TYPES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKS_COV_TYPES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKS_COV_TYPES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKS_COV_TYPES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKS_COV_TYPES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKS_COV_TYPES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKS_COV_TYPES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKS_COV_TYPES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKS_COV_TYPES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKS_COV_TYPES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKS_COV_TYPES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKS_COV_TYPES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKS_COV_TYPES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKS_COV_TYPES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  G_MISS_cvpv_rec                         cvpv_rec_type;
  TYPE cvpv_tbl_type IS TABLE OF cvpv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_COV_TYPES_TL Record Spec
  TYPE oks_cov_types_tl_rec_type IS RECORD (
     code                           OKS_COV_TYPES_TL.CODE%TYPE := OKC_API.G_MISS_CHAR
    ,language                       OKS_COV_TYPES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    OKS_COV_TYPES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKS_COV_TYPES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,meaning                        OKS_COV_TYPES_TL.MEANING%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKS_COV_TYPES_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_COV_TYPES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_COV_TYPES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_oks_cov_types_tl_rec             oks_cov_types_tl_rec_type;
  TYPE oks_cov_types_tl_tbl_type IS TABLE OF oks_cov_types_tl_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_COV_TYPES_B Record Spec
  TYPE cvp_rec_type IS RECORD (
     code                           OKS_COV_TYPES_B.CODE%TYPE := OKC_API.G_MISS_CHAR
    ,importance_level               NUMBER := OKC_API.G_MISS_NUM
    ,enabled_flag                   OKS_COV_TYPES_B.ENABLED_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,start_date_active              OKS_COV_TYPES_B.START_DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE
    ,end_date_active                OKS_COV_TYPES_B.END_DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_COV_TYPES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_COV_TYPES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKS_COV_TYPES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKS_COV_TYPES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKS_COV_TYPES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKS_COV_TYPES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKS_COV_TYPES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKS_COV_TYPES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKS_COV_TYPES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKS_COV_TYPES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKS_COV_TYPES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKS_COV_TYPES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKS_COV_TYPES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKS_COV_TYPES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKS_COV_TYPES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKS_COV_TYPES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKS_COV_TYPES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKS_COV_TYPES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  G_MISS_cvp_rec                          cvp_rec_type;
  TYPE cvp_tbl_type IS TABLE OF cvp_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_CVP_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type,
    x_cvpv_rec                     OUT NOCOPY cvpv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    x_cvpv_tbl                     OUT NOCOPY cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    x_cvpv_tbl                     OUT NOCOPY cvpv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type,
    x_cvpv_rec                     OUT NOCOPY cvpv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    x_cvpv_tbl                     OUT NOCOPY cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    x_cvpv_tbl                     OUT NOCOPY cvpv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_rec                     IN cvpv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvpv_tbl                     IN cvpv_tbl_type);
   PROCEDURE MIGRATE_COVERAGE_TYPES(p_api_version                  IN NUMBER,
                                   p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                 OUT NOCOPY VARCHAR2,
                                   x_msg_count                     OUT NOCOPY NUMBER,
                                   x_msg_data                      OUT NOCOPY VARCHAR2);

   PROCEDURE DELETE_COVERAGE_TYPES(p_api_version                  IN NUMBER,
                                   p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                 OUT NOCOPY VARCHAR2,
                                   x_msg_count                     OUT NOCOPY NUMBER,
                                   x_msg_data                      OUT NOCOPY VARCHAR2);
  END OKS_CVP_PVT;

 

/
