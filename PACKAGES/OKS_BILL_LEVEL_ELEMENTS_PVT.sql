--------------------------------------------------------
--  DDL for Package OKS_BILL_LEVEL_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILL_LEVEL_ELEMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBLES.pls 120.1 2006/09/19 18:59:51 hvaladip noship $ */
  ---------------------------------------------------------------------------

  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_LEVEL_ELEMENTS_V Record Spec
  TYPE letv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,parent_cle_id                  NUMBER := OKC_API.G_MISS_NUM
    ,sequence_number                OKS_LEVEL_ELEMENTS_V.SEQUENCE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,date_start                     OKS_LEVEL_ELEMENTS_V.DATE_START%TYPE := OKC_API.G_MISS_DATE
    ,date_end                       OKS_LEVEL_ELEMENTS_V.DATE_END%TYPE := OKC_API.G_MISS_DATE
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,date_revenue_rule_start        OKS_LEVEL_ELEMENTS_V.DATE_REVENUE_RULE_START%TYPE := OKC_API.G_MISS_DATE
    ,date_receivable_gl             OKS_LEVEL_ELEMENTS_V.DATE_RECEIVABLE_GL%TYPE := OKC_API.G_MISS_DATE
    ,date_transaction               OKS_LEVEL_ELEMENTS_V.DATE_TRANSACTION%TYPE := OKC_API.G_MISS_DATE
    ,date_due                       OKS_LEVEL_ELEMENTS_V.DATE_DUE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,date_print                     OKS_LEVEL_ELEMENTS_V.DATE_PRINT%TYPE := OKC_API.G_MISS_DATE
    ,date_to_interface              OKS_LEVEL_ELEMENTS_V.DATE_TO_INTERFACE%TYPE := OKC_API.G_MISS_DATE
    ,date_completed                 OKS_LEVEL_ELEMENTS_V.DATE_COMPLETED%TYPE := OKC_API.G_MISS_DATE
    ,rul_id                         NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_LEVEL_ELEMENTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_LEVEL_ELEMENTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_letv_rec                         letv_rec_type;
  TYPE letv_tbl_type IS TABLE OF letv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_LEVEL_ELEMENTS Record Spec
  TYPE let_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,parent_cle_id                  NUMBER := OKC_API.G_MISS_NUM
    ,sequence_number                OKS_LEVEL_ELEMENTS.SEQUENCE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,date_start                     OKS_LEVEL_ELEMENTS.DATE_START%TYPE := OKC_API.G_MISS_DATE
    ,date_end                       OKS_LEVEL_ELEMENTS.DATE_END%TYPE := OKC_API.G_MISS_DATE
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,date_receivable_gl             OKS_LEVEL_ELEMENTS.DATE_RECEIVABLE_GL%TYPE := OKC_API.G_MISS_DATE
    ,date_revenue_rule_start        OKS_LEVEL_ELEMENTS.DATE_REVENUE_RULE_START%TYPE := OKC_API.G_MISS_DATE
    ,date_transaction               OKS_LEVEL_ELEMENTS.DATE_TRANSACTION%TYPE := OKC_API.G_MISS_DATE
    ,date_due                       OKS_LEVEL_ELEMENTS.DATE_DUE%TYPE := OKC_API.G_MISS_DATE
    ,date_print                     OKS_LEVEL_ELEMENTS.DATE_PRINT%TYPE := OKC_API.G_MISS_DATE
    ,date_to_interface              OKS_LEVEL_ELEMENTS.DATE_TO_INTERFACE%TYPE := OKC_API.G_MISS_DATE
    ,date_completed                 OKS_LEVEL_ELEMENTS.DATE_COMPLETED%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,rul_id                         NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_LEVEL_ELEMENTS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_LEVEL_ELEMENTS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_let_rec                          let_rec_type;
  TYPE let_tbl_type IS TABLE OF let_rec_type
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_level_PVT';
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
    p_letv_rec                     IN letv_rec_type,
    x_letv_rec                     OUT NOCOPY letv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    x_letv_tbl                     OUT NOCOPY letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    x_letv_tbl                     OUT NOCOPY letv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type,
    x_letv_rec                     OUT NOCOPY letv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    x_letv_tbl                     OUT NOCOPY letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    x_letv_tbl                     OUT NOCOPY letv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type);
END OKS_BILL_LEVEL_ELEMENTS_PVT ;


 

/
