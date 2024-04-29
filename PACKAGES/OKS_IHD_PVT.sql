--------------------------------------------------------
--  DDL for Package OKS_IHD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IHD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSIHDS.pls 120.4 2006/09/11 23:23:56 dneetha noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_INST_HIST_DETAILS_V Record Spec
  TYPE ihdv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,ins_id                         NUMBER := OKC_API.G_MISS_NUM
    ,transaction_date               OKS_INST_HIST_DETAILS_V.TRANSACTION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,transaction_type               OKS_INST_HIST_DETAILS_V.TRANSACTION_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,system_id                      NUMBER := OKC_API.G_MISS_NUM
    ,instance_id_new                NUMBER := OKC_API.G_MISS_NUM
    ,instance_qty_old               NUMBER := OKC_API.G_MISS_NUM
    ,instance_qty_new               NUMBER := OKC_API.G_MISS_NUM
    ,instance_amt_old               NUMBER := OKC_API.G_MISS_NUM
    ,instance_amt_new               NUMBER := OKC_API.G_MISS_NUM
    ,old_contract_id                NUMBER := OKC_API.G_MISS_NUM
    ,old_contact_start_date         OKS_INST_HIST_DETAILS_V.OLD_CONTACT_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_contract_end_date          OKS_INST_HIST_DETAILS_V.OLD_CONTRACT_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_contract_id                NUMBER := OKC_API.G_MISS_NUM
    ,new_contact_start_date         OKS_INST_HIST_DETAILS_V.NEW_CONTACT_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_contract_end_date          OKS_INST_HIST_DETAILS_V.NEW_CONTRACT_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_service_line_id            NUMBER := OKC_API.G_MISS_NUM
    ,old_service_start_date         OKS_INST_HIST_DETAILS_V.OLD_SERVICE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_service_end_date           OKS_INST_HIST_DETAILS_V.OLD_SERVICE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_service_line_id            NUMBER := OKC_API.G_MISS_NUM
    ,new_service_start_date         OKS_INST_HIST_DETAILS_V.NEW_SERVICE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_service_end_date           OKS_INST_HIST_DETAILS_V.NEW_SERVICE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_subline_id                 NUMBER := OKC_API.G_MISS_NUM
    ,old_subline_start_date         OKS_INST_HIST_DETAILS_V.OLD_SUBLINE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_subline_end_date           OKS_INST_HIST_DETAILS_V.OLD_SUBLINE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_subline_id                 NUMBER := OKC_API.G_MISS_NUM
    ,new_subline_start_date         OKS_INST_HIST_DETAILS_V.NEW_SUBLINE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_subline_end_date           OKS_INST_HIST_DETAILS_V.NEW_SUBLINE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_customer                   NUMBER := OKC_API.G_MISS_NUM
    ,new_customer                   NUMBER := OKC_API.G_MISS_NUM
    ,old_k_status                   OKS_INST_HIST_DETAILS_V.OLD_K_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,new_k_status                   OKS_INST_HIST_DETAILS_V.NEW_K_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,subline_date_terminated        OKS_INST_HIST_DETAILS_V.SUBLINE_DATE_TERMINATED%TYPE := OKC_API.G_MISS_DATE
    ,transfer_option                OKS_INST_HIST_DETAILS_V.TRANSFER_OPTION%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_INST_HIST_DETAILS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_INST_HIST_DETAILS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,date_cancelled                 OKS_INST_HIST_DETAILS_V.DATE_CANCELLED%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_ihdv_rec                         ihdv_rec_type;
  TYPE ihdv_tbl_type IS TABLE OF ihdv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_INST_HIST_DETAILS Record Spec
  TYPE ihd_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,ins_id                         NUMBER := OKC_API.G_MISS_NUM
    ,transaction_date               OKS_INST_HIST_DETAILS.TRANSACTION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,transaction_type               OKS_INST_HIST_DETAILS.TRANSACTION_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,system_id                      NUMBER := OKC_API.G_MISS_NUM
    ,instance_id_new                NUMBER := OKC_API.G_MISS_NUM
    ,instance_qty_old               NUMBER := OKC_API.G_MISS_NUM
    ,instance_qty_new               NUMBER := OKC_API.G_MISS_NUM
    ,instance_amt_old               NUMBER := OKC_API.G_MISS_NUM
    ,instance_amt_new               NUMBER := OKC_API.G_MISS_NUM
    ,old_contract_id                NUMBER := OKC_API.G_MISS_NUM
    ,old_contact_start_date         OKS_INST_HIST_DETAILS.OLD_CONTACT_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_contract_end_date          OKS_INST_HIST_DETAILS.OLD_CONTRACT_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_contract_id                NUMBER := OKC_API.G_MISS_NUM
    ,new_contact_start_date         OKS_INST_HIST_DETAILS.NEW_CONTACT_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_contract_end_date          OKS_INST_HIST_DETAILS.NEW_CONTRACT_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_service_line_id            NUMBER := OKC_API.G_MISS_NUM
    ,old_service_start_date         OKS_INST_HIST_DETAILS.OLD_SERVICE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_service_end_date           OKS_INST_HIST_DETAILS.OLD_SERVICE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_service_line_id            NUMBER := OKC_API.G_MISS_NUM
    ,new_service_start_date         OKS_INST_HIST_DETAILS.NEW_SERVICE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_service_end_date           OKS_INST_HIST_DETAILS.NEW_SERVICE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_subline_id                 NUMBER := OKC_API.G_MISS_NUM
    ,old_subline_start_date         OKS_INST_HIST_DETAILS.OLD_SUBLINE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_subline_end_date           OKS_INST_HIST_DETAILS.OLD_SUBLINE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_subline_id                 NUMBER := OKC_API.G_MISS_NUM
    ,new_subline_start_date         OKS_INST_HIST_DETAILS.NEW_SUBLINE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,new_subline_end_date           OKS_INST_HIST_DETAILS.NEW_SUBLINE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,old_customer                   NUMBER := OKC_API.G_MISS_NUM
    ,new_customer                   NUMBER := OKC_API.G_MISS_NUM
    ,old_k_status                   OKS_INST_HIST_DETAILS.OLD_K_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,new_k_status                   OKS_INST_HIST_DETAILS.NEW_K_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,subline_date_terminated        OKS_INST_HIST_DETAILS.SUBLINE_DATE_TERMINATED%TYPE := OKC_API.G_MISS_DATE
    ,transfer_option                OKS_INST_HIST_DETAILS.TRANSFER_OPTION%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_INST_HIST_DETAILS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_INST_HIST_DETAILS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,date_cancelled                 OKS_INST_HIST_DETAILS.DATE_CANCELLED%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_ihd_rec                          ihd_rec_type;
  TYPE ihd_tbl_type IS TABLE OF ihd_rec_type
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_IHD_PVT';
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
    p_ihdv_rec                     IN ihdv_rec_type,
    x_ihdv_rec                     OUT NOCOPY ihdv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    x_ihdv_tbl                     OUT NOCOPY ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    x_ihdv_tbl                     OUT NOCOPY ihdv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type,
    x_ihdv_rec                     OUT NOCOPY ihdv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    x_ihdv_tbl                     OUT NOCOPY ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    x_ihdv_tbl                     OUT NOCOPY ihdv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type);
END OKS_IHD_PVT;

 

/
