--------------------------------------------------------
--  DDL for Package OKS_PML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_PML_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSPMLS.pls 120.1 2005/07/15 09:25:16 parkumar noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_PM_STREAM_LEVELS_V Record Spec
  TYPE pmlv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,activity_line_id               NUMBER := OKC_API.G_MISS_NUM
    ,sequence_number                NUMBER := OKC_API.G_MISS_NUM
    ,number_of_occurences           NUMBER := OKC_API.G_MISS_NUM
    ,start_date                     OKS_PM_STREAM_LEVELS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,end_date                       OKS_PM_STREAM_LEVELS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,frequency                      NUMBER := OKC_API.G_MISS_NUM
    ,frequency_uom                  OKS_PM_STREAM_LEVELS_V.FREQUENCY_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,offset_duration                NUMBER := OKC_API.G_MISS_NUM
    ,offset_uom                     OKS_PM_STREAM_LEVELS_V.OFFSET_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,autoschedule_yn                OKS_PM_STREAM_LEVELS_V.AUTOSCHEDULE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_PM_STREAM_LEVELS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_PM_STREAM_LEVELS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_PM_STREAM_LEVELS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
-- R12 Data Model Changes 4485150 Start
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_PM_STREAM_LEVELS_V.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_PM_STREAM_LEVELS_V.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
);
  G_MISS_pmlv_rec                         pmlv_rec_type;
  TYPE pmlv_tbl_type IS TABLE OF pmlv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_PM_STREAM_LEVELS Record Spec
  TYPE pml_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,activity_line_id               NUMBER := OKC_API.G_MISS_NUM
    ,sequence_number                NUMBER := OKC_API.G_MISS_NUM
    ,number_of_occurences           NUMBER := OKC_API.G_MISS_NUM
    ,start_date                     OKS_PM_STREAM_LEVELS.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,end_date                       OKS_PM_STREAM_LEVELS.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,frequency                      NUMBER := OKC_API.G_MISS_NUM
    ,frequency_uom                  OKS_PM_STREAM_LEVELS.FREQUENCY_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,offset_duration                NUMBER := OKC_API.G_MISS_NUM
    ,offset_uom                     OKS_PM_STREAM_LEVELS.OFFSET_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,autoschedule_yn                OKS_PM_STREAM_LEVELS.AUTOSCHEDULE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_PM_STREAM_LEVELS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_PM_STREAM_LEVELS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_PM_STREAM_LEVELS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
-- R12 Data Model Changes 4485150 Start
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_PM_STREAM_LEVELS.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_PM_STREAM_LEVELS.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
);
  G_MISS_pml_rec                          pml_rec_type;
  TYPE pml_tbl_type IS TABLE OF pml_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_PML_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
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
    p_pmlv_rec                     IN pmlv_rec_type,
    x_pmlv_rec                     OUT NOCOPY pmlv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    x_pmlv_tbl                     OUT NOCOPY pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    x_pmlv_tbl                     OUT NOCOPY pmlv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type,
    x_pmlv_rec                     OUT NOCOPY pmlv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    x_pmlv_tbl                     OUT NOCOPY pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    x_pmlv_tbl                     OUT NOCOPY pmlv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type);
  FUNCTION Create_Version(
             p_id         IN NUMBER,
             p_major_version  IN NUMBER) RETURN VARCHAR2;

   FUNCTION restore_version(
             p_id               IN NUMBER,
             p_major_version    IN NUMBER) RETURN VARCHAR2;


END OKS_PML_PVT;

 

/
