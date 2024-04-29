--------------------------------------------------------
--  DDL for Package OKS_BTL_PRINT_PREVIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BTL_PRINT_PREVIEW_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSBTLPS.pls 120.1 2006/09/19 18:58:35 hvaladip noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE btl_pr_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,btn_id                         NUMBER := OKC_API.G_MISS_NUM
    ,bsl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,bcl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_BTL_PR.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_BTL_PR.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,bill_instance_number           NUMBER := OKC_API.G_MISS_NUM
    ,trx_line_amount                OKS_BTL_PR.TRX_LINE_AMOUNT%TYPE := OKC_API.G_MISS_CHAR
    ,trx_line_tax_amount            NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             OKS_BTL_PR.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKS_BTL_PR.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKS_BTL_PR.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKS_BTL_PR.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKS_BTL_PR.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKS_BTL_PR.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKS_BTL_PR.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKS_BTL_PR.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKS_BTL_PR.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKS_BTL_PR.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKS_BTL_PR.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKS_BTL_PR.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKS_BTL_PR.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKS_BTL_PR.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKS_BTL_PR.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKS_BTL_PR.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_btl_pr_rec                       btl_pr_rec_type;
  TYPE btl_pr_tbl_type IS TABLE OF btl_pr_rec_type
        INDEX BY BINARY_INTEGER;

TYPE ERROR_REC_TYPE IS RECORD (
    msg_data    VARCHAR2(2000),
    msg_count   NUMBER,
    error_type  VARCHAR2(1),
    api_name    VARCHAR2(200),
    api_package VARCHAR2(60),
    idx         NUMBER,
    sqlcode     NUMBER
);
TYPE ERROR_TBL_TYPE IS TABLE OF ERROR_REC_TYPE
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_BTL_PRINT_PREVIEW_PVT';
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
    p_btl_pr_rec                   IN btl_pr_rec_type,
    x_btl_pr_rec                   OUT NOCOPY btl_pr_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                   IN btl_pr_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                   IN btl_pr_tbl_type,
    px_error_tbl                   IN OUT NOCOPY ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                   IN btl_pr_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                   IN btl_pr_rec_type,
    x_btl_pr_rec                   OUT NOCOPY btl_pr_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                   IN btl_pr_tbl_type,
    x_btl_pr_tbl                   OUT NOCOPY btl_pr_tbl_type,
    px_error_tbl                   IN OUT NOCOPY ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                   IN btl_pr_tbl_type,
    x_btl_pr_tbl                   OUT NOCOPY btl_pr_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                   IN btl_pr_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                   IN btl_pr_tbl_type,
    px_error_tbl                   IN OUT NOCOPY ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                   IN btl_pr_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                   IN btl_pr_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                   IN btl_pr_tbl_type,
    px_error_tbl                   IN OUT NOCOPY ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                   IN btl_pr_tbl_type);
END OKS_BTL_PRINT_PREVIEW_PVT;

 

/
