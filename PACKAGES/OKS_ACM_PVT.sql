--------------------------------------------------------
--  DDL for Package OKS_ACM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ACM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSACTMS.pls 120.0 2005/05/25 17:36:06 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_ACTION_TIMES_V Record Spec
  TYPE oks_action_times_v_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cov_action_type_id             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,uom_code                       OKS_ACTION_TIMES_V.UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,sun_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,mon_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,tue_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,wed_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,thu_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,fri_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,sat_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_ACTION_TIMES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_ACTION_TIMES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_ACTION_TIMES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_oks_action_times_v_rec           oks_action_times_v_rec_type;
  TYPE oks_action_times_v_tbl_type IS TABLE OF oks_action_times_v_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_ACTION_TIMES Record Spec
  TYPE oks_action_times_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cov_action_type_id             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,uom_code                       OKS_ACTION_TIMES.UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,sun_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,mon_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,tue_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,wed_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,thu_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,fri_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,sat_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_ACTION_TIMES.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_ACTION_TIMES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_ACTION_TIMES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_oks_action_times_rec             oks_action_times_rec_type;
  TYPE oks_action_times_tbl_type IS TABLE OF oks_action_times_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_ACM_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_rec       IN oks_action_times_v_rec_type,
    x_oks_action_times_v_rec       OUT NOCOPY oks_action_times_v_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type,
    x_oks_action_times_v_tbl       OUT NOCOPY oks_action_times_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type,
    x_oks_action_times_v_tbl       OUT NOCOPY oks_action_times_v_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_rec       IN oks_action_times_v_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_rec       IN oks_action_times_v_rec_type,
    x_oks_action_times_v_rec       OUT NOCOPY oks_action_times_v_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type,
    x_oks_action_times_v_tbl       OUT NOCOPY oks_action_times_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type,
    x_oks_action_times_v_tbl       OUT NOCOPY oks_action_times_v_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_rec       IN oks_action_times_v_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_rec       IN oks_action_times_v_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_times_v_tbl       IN oks_action_times_v_tbl_type);



FUNCTION Create_Version(
             p_id         IN NUMBER,
             p_major_version  IN NUMBER) RETURN VARCHAR2;

FUNCTION restore_version(
             p_id               IN NUMBER,
             p_major_version    IN NUMBER) RETURN VARCHAR2;



END OKS_ACM_PVT;

 

/
