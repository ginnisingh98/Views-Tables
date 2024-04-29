--------------------------------------------------------
--  DDL for Package IEX_REP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_REP_PVT" AUTHID CURRENT_USER AS
/* $Header: iexsreps.pls 120.1 2005/12/21 15:39:53 jypark noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- IEX_REPOS_OBJECTS_V Record Spec
  TYPE repv_rec_type IS RECORD (
     repos_object_id                NUMBER := 9.99E125
    ,repossession_id                NUMBER := 9.99E125
    ,asset_id                       NUMBER := 9.99E125
    ,rna_id                         NUMBER := 9.99E125
    ,rna_site_id                    NUMBER := 9.99E125
    ,art_id                         NUMBER := 9.99E125
    ,active_yn                      IEX_REPOS_OBJECTS_V.ACTIVE_YN%TYPE := chr(0)
    ,object_version_number          NUMBER := 9.99E125
    ,org_id                         NUMBER := 9.99E125
    ,request_id                     NUMBER := 9.99E125
    ,program_application_id         NUMBER := 9.99E125
    ,program_id                     NUMBER := 9.99E125
    ,program_update_date            IEX_REPOS_OBJECTS_V.PROGRAM_UPDATE_DATE%TYPE := TO_DATE('1','j')
    ,attribute_category             IEX_REPOS_OBJECTS_V.ATTRIBUTE_CATEGORY%TYPE := chr(0)
    ,attribute1                     IEX_REPOS_OBJECTS_V.ATTRIBUTE1%TYPE := chr(0)
    ,attribute2                     IEX_REPOS_OBJECTS_V.ATTRIBUTE2%TYPE := chr(0)
    ,attribute3                     IEX_REPOS_OBJECTS_V.ATTRIBUTE3%TYPE := chr(0)
    ,attribute4                     IEX_REPOS_OBJECTS_V.ATTRIBUTE4%TYPE := chr(0)
    ,attribute5                     IEX_REPOS_OBJECTS_V.ATTRIBUTE5%TYPE := chr(0)
    ,attribute6                     IEX_REPOS_OBJECTS_V.ATTRIBUTE6%TYPE := chr(0)
    ,attribute7                     IEX_REPOS_OBJECTS_V.ATTRIBUTE7%TYPE := chr(0)
    ,attribute8                     IEX_REPOS_OBJECTS_V.ATTRIBUTE8%TYPE := chr(0)
    ,attribute9                     IEX_REPOS_OBJECTS_V.ATTRIBUTE9%TYPE := chr(0)
    ,attribute10                    IEX_REPOS_OBJECTS_V.ATTRIBUTE10%TYPE := chr(0)
    ,attribute11                    IEX_REPOS_OBJECTS_V.ATTRIBUTE11%TYPE := chr(0)
    ,attribute12                    IEX_REPOS_OBJECTS_V.ATTRIBUTE12%TYPE := chr(0)
    ,attribute13                    IEX_REPOS_OBJECTS_V.ATTRIBUTE13%TYPE := chr(0)
    ,attribute14                    IEX_REPOS_OBJECTS_V.ATTRIBUTE14%TYPE := chr(0)
    ,attribute15                    IEX_REPOS_OBJECTS_V.ATTRIBUTE15%TYPE := chr(0)
    ,created_by                     NUMBER := 9.99E125
    ,creation_date                  IEX_REPOS_OBJECTS_V.CREATION_DATE%TYPE := TO_DATE('1','j')
    ,last_updated_by                NUMBER := 9.99E125
    ,last_update_date               IEX_REPOS_OBJECTS_V.LAST_UPDATE_DATE%TYPE := TO_DATE('1','j')
    ,last_update_login              NUMBER := 9.99E125
    ,security_group_id              NUMBER := 9.99E125);
  G_MISS_repv_rec                         repv_rec_type;
  TYPE repv_tbl_type IS TABLE OF repv_rec_type
        INDEX BY BINARY_INTEGER;
  -- IEX_REPOS_OBJECTS Record Spec
  TYPE rep_rec_type IS RECORD (
     repos_object_id                NUMBER := 9.99E125
    ,repossession_id                NUMBER := 9.99E125
    ,asset_id                       NUMBER := 9.99E125
    ,rna_id                         NUMBER := 9.99E125
    ,rna_site_id                    NUMBER := 9.99E125
    ,art_id                         NUMBER := 9.99E125
    ,active_yn                      IEX_REPOS_OBJECTS.ACTIVE_YN%TYPE := chr(0)
    ,object_version_number          NUMBER := 9.99E125
    ,org_id                         NUMBER := 9.99E125
    ,request_id                     NUMBER := 9.99E125
    ,program_application_id         NUMBER := 9.99E125
    ,program_id                     NUMBER := 9.99E125
    ,program_update_date            IEX_REPOS_OBJECTS.PROGRAM_UPDATE_DATE%TYPE := TO_DATE('1','j')
    ,attribute_category             IEX_REPOS_OBJECTS.ATTRIBUTE_CATEGORY%TYPE := chr(0)
    ,attribute1                     IEX_REPOS_OBJECTS.ATTRIBUTE1%TYPE := chr(0)
    ,attribute2                     IEX_REPOS_OBJECTS.ATTRIBUTE2%TYPE := chr(0)
    ,attribute3                     IEX_REPOS_OBJECTS.ATTRIBUTE3%TYPE := chr(0)
    ,attribute4                     IEX_REPOS_OBJECTS.ATTRIBUTE4%TYPE := chr(0)
    ,attribute5                     IEX_REPOS_OBJECTS.ATTRIBUTE5%TYPE := chr(0)
    ,attribute6                     IEX_REPOS_OBJECTS.ATTRIBUTE6%TYPE := chr(0)
    ,attribute7                     IEX_REPOS_OBJECTS.ATTRIBUTE7%TYPE := chr(0)
    ,attribute8                     IEX_REPOS_OBJECTS.ATTRIBUTE8%TYPE := chr(0)
    ,attribute9                     IEX_REPOS_OBJECTS.ATTRIBUTE9%TYPE := chr(0)
    ,attribute10                    IEX_REPOS_OBJECTS.ATTRIBUTE10%TYPE := chr(0)
    ,attribute11                    IEX_REPOS_OBJECTS.ATTRIBUTE11%TYPE := chr(0)
    ,attribute12                    IEX_REPOS_OBJECTS.ATTRIBUTE12%TYPE := chr(0)
    ,attribute13                    IEX_REPOS_OBJECTS.ATTRIBUTE13%TYPE := chr(0)
    ,attribute14                    IEX_REPOS_OBJECTS.ATTRIBUTE14%TYPE := chr(0)
    ,attribute15                    IEX_REPOS_OBJECTS.ATTRIBUTE15%TYPE := chr(0)
    ,created_by                     NUMBER := 9.99E125
    ,creation_date                  IEX_REPOS_OBJECTS.CREATION_DATE%TYPE := TO_DATE('1','j')
    ,last_updated_by                NUMBER := 9.99E125
    ,last_update_date               IEX_REPOS_OBJECTS.LAST_UPDATE_DATE%TYPE := TO_DATE('1','j')
    ,last_update_login              NUMBER := 9.99E125);
  G_MISS_rep_rec                          rep_rec_type;
  TYPE rep_tbl_type IS TABLE OF rep_rec_type
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
  G_NO_PARENT_RECORD             CONSTANT VARCHAR2(200) := 'IEX_NO_PARENT_RECORD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'IEX_REP_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := 'IEX';
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
    p_repv_rec                     IN repv_rec_type,
    x_repv_rec                     OUT NOCOPY repv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type,
    x_repv_rec                     OUT NOCOPY repv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type);
END IEX_REP_PVT;

 

/
