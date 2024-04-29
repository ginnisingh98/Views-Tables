--------------------------------------------------------
--  DDL for Package OKS_BRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BRL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBRLS.pls 120.3 2006/09/11 23:20:42 dneetha noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_BATCH_RULES_V Record Spec
  TYPE oks_batch_rules_v_rec_type IS RECORD (
     batch_id                       NUMBER := OKC_API.G_MISS_NUM
    ,batch_type                     OKS_BATCH_RULES_V.BATCH_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,batch_source                   OKS_BATCH_RULES_V.BATCH_SOURCE%TYPE := OKC_API.G_MISS_CHAR
    ,transaction_date               OKS_BATCH_RULES_V.TRANSACTION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,credit_option                  OKS_BATCH_RULES_V.CREDIT_OPTION%TYPE := OKC_API.G_MISS_CHAR
    ,termination_reason_code        OKS_BATCH_RULES_V.TERMINATION_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,billing_profile_id             NUMBER := OKC_API.G_MISS_NUM
    ,retain_contract_number_flag      OKS_BATCH_RULES_V.RETAIN_CONTRACT_NUMBER_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,contract_modifier              OKS_BATCH_RULES_V.CONTRACT_MODIFIER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_status                OKS_BATCH_RULES_V.CONTRACT_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_notes_flag            OKS_BATCH_RULES_V.TRANSFER_NOTES_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_attachments_flag      OKS_BATCH_RULES_V.TRANSFER_ATTACHMENTS_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,bill_lines_flag                OKS_BATCH_RULES_V.BILL_LINES_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_option_code           OKS_BATCH_RULES_V.TRANSFER_OPTION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,bill_account_id                NUMBER := OKC_API.G_MISS_NUM
    ,ship_account_id                NUMBER := OKC_API.G_MISS_NUM
    ,bill_address_id                NUMBER := OKC_API.G_MISS_NUM
    ,ship_address_id                NUMBER := OKC_API.G_MISS_NUM
    ,bill_contact_id                NUMBER := OKC_API.G_MISS_NUM
    ,new_account_id                 NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_BATCH_RULES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_BATCH_RULES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_oks_batch_rules_v_rec            oks_batch_rules_v_rec_type;
  TYPE oks_batch_rules_v_tbl_type IS TABLE OF oks_batch_rules_v_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_BATCH_RULES Record Spec
  TYPE obtr_rec_type IS RECORD (
     batch_id                       NUMBER := OKC_API.G_MISS_NUM
    ,batch_type                     OKS_BATCH_RULES.BATCH_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,batch_source                   OKS_BATCH_RULES.BATCH_SOURCE%TYPE := OKC_API.G_MISS_CHAR
    ,transaction_date               OKS_BATCH_RULES.TRANSACTION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,credit_option                  OKS_BATCH_RULES.CREDIT_OPTION%TYPE := OKC_API.G_MISS_CHAR
    ,termination_reason_code        OKS_BATCH_RULES.TERMINATION_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,billing_profile_id             NUMBER := OKC_API.G_MISS_NUM
    ,retain_contract_number_flag    OKS_BATCH_RULES.RETAIN_CONTRACT_NUMBER_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,contract_modifier              OKS_BATCH_RULES.CONTRACT_MODIFIER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_status                OKS_BATCH_RULES.CONTRACT_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_notes_flag            OKS_BATCH_RULES.TRANSFER_NOTES_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_attachments_flag      OKS_BATCH_RULES.TRANSFER_ATTACHMENTS_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,bill_lines_flag                OKS_BATCH_RULES.BILL_LINES_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_option_code           OKS_BATCH_RULES.TRANSFER_OPTION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,bill_account_id                NUMBER := OKC_API.G_MISS_NUM
    ,ship_account_id                NUMBER := OKC_API.G_MISS_NUM
    ,bill_address_id                NUMBER := OKC_API.G_MISS_NUM
    ,ship_address_id                NUMBER := OKC_API.G_MISS_NUM
    ,bill_contact_id                NUMBER := OKC_API.G_MISS_NUM
    ,new_account_id                 NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_BATCH_RULES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_BATCH_RULES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_obtr_rec                         obtr_rec_type;
  TYPE obtr_tbl_type IS TABLE OF obtr_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_BRL_PVT';
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
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type,
    x_oks_batch_rules_v_rec        OUT NOCOPY oks_batch_rules_v_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    x_oks_batch_rules_v_tbl        OUT NOCOPY oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    x_oks_batch_rules_v_tbl        OUT NOCOPY oks_batch_rules_v_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type,
    x_oks_batch_rules_v_rec        OUT NOCOPY oks_batch_rules_v_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    x_oks_batch_rules_v_tbl        OUT NOCOPY oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    x_oks_batch_rules_v_tbl        OUT NOCOPY oks_batch_rules_v_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type);
END OKS_BRL_PVT;

 

/
