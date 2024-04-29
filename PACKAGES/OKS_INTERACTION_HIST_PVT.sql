--------------------------------------------------------
--  DDL for Package OKS_INTERACTION_HIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_INTERACTION_HIST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSINTHS.pls 120.0 2005/05/25 18:21:43 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_INTERACTION_HIST_V Record Spec
  TYPE inhv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,contract_number                OKS_INTERACTION_HIST_V.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_number_modifier       OKS_INTERACTION_HIST_V.CONTRACT_NUMBER_MODIFIER%TYPE := OKC_API.G_MISS_CHAR
    ,renewal_status                 OKS_INTERACTION_HIST_V.RENEWAL_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,party_id                       NUMBER := OKC_API.G_MISS_NUM
    ,user_id                        NUMBER := OKC_API.G_MISS_NUM
    ,description                    OKS_INTERACTION_HIST_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,status                         OKS_INTERACTION_HIST_V.STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,task_name                      OKS_INTERACTION_HIST_V.TASK_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,task_result                    OKS_INTERACTION_HIST_V.TASK_RESULT%TYPE := OKC_API.G_MISS_CHAR
    ,creation_date                  OKS_INTERACTION_HIST_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_INTERACTION_HIST_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_inhv_rec                         inhv_rec_type;
  TYPE inhv_tbl_type IS TABLE OF inhv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_INTERACTION_HISTORY Record Spec
  TYPE inh_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,contract_number                OKS_INTERACTION_HISTORY.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_number_modifier       OKS_INTERACTION_HISTORY.CONTRACT_NUMBER_MODIFIER%TYPE := OKC_API.G_MISS_CHAR
    ,renewal_status                 OKS_INTERACTION_HISTORY.RENEWAL_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,party_id                       NUMBER := OKC_API.G_MISS_NUM
    ,user_id                        NUMBER := OKC_API.G_MISS_NUM
    ,description                    OKS_INTERACTION_HISTORY.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,status                         OKS_INTERACTION_HISTORY.STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,task_name                      OKS_INTERACTION_HISTORY.TASK_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,task_result                    OKS_INTERACTION_HISTORY.TASK_RESULT%TYPE := OKC_API.G_MISS_CHAR
    ,creation_date                  OKS_INTERACTION_HISTORY.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_INTERACTION_HISTORY.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_inh_rec                          inh_rec_type;
  TYPE inh_tbl_type IS TABLE OF inh_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_INTERACTION_HIST_PVT';
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
    p_inhv_rec                     IN inhv_rec_type,
    x_inhv_rec                     OUT NOCOPY inhv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type,
    x_inhv_tbl                     OUT NOCOPY inhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type,
    x_inhv_tbl                     OUT NOCOPY inhv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_rec                     IN inhv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_rec                     IN inhv_rec_type,
    x_inhv_rec                     OUT NOCOPY inhv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type,
    x_inhv_tbl                     OUT NOCOPY inhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type,
    x_inhv_tbl                     OUT NOCOPY inhv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_rec                     IN inhv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_rec                     IN inhv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inhv_tbl                     IN inhv_tbl_type);
END OKS_INTERACTION_HIST_PVT;

 

/
