--------------------------------------------------------
--  DDL for Package OKL_IDH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_IDH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSIDHS.pls 120.2 2006/07/11 10:21:11 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_INVESTOR_PAYOUT_SUMMARY_V Record Spec
  TYPE idhv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,lsm_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cash_receipt_id                NUMBER := OKC_API.G_MISS_NUM
    ,ap_invoice_number              NUMBER := OKC_API.G_MISS_NUM
    ,status                         OKL_INVESTOR_PAYOUT_SUMMARY_B.STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,error_message                  OKL_INVESTOR_PAYOUT_SUMMARY_B.ERROR_MESSAGE%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_INVESTOR_PAYOUT_SUMMARY_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_INVESTOR_PAYOUT_SUMMARY_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_INVESTOR_PAYOUT_SUMMARY_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,investor_agreement_id          OKL_INVESTOR_PAYOUT_SUMMARY_B.INVESTOR_AGREEMENT_ID%TYPE := OKC_API.G_MISS_NUM
    ,investor_line_id               OKL_INVESTOR_PAYOUT_SUMMARY_B.INVESTOR_LINE_ID%TYPE := OKC_API.G_MISS_NUM
    ,receivable_application_id      OKL_INVESTOR_PAYOUT_SUMMARY_B.RECEIVABLE_APPLICATION_ID%TYPE := OKC_API.G_MISS_NUM
    );
  G_MISS_idhv_rec                         idhv_rec_type;
  TYPE idhv_tbl_type IS TABLE OF idhv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_INVESTOR_PAYOUT_SUMMARY_B Record Spec
  TYPE idh_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,lsm_id                         NUMBER := OKC_API.G_MISS_NUM
    ,cash_receipt_id                NUMBER := OKC_API.G_MISS_NUM
    ,ap_invoice_number              NUMBER := OKC_API.G_MISS_NUM
    ,status                         OKL_INVESTOR_PAYOUT_SUMMARY_B.STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,error_message                  OKL_INVESTOR_PAYOUT_SUMMARY_B.ERROR_MESSAGE%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_INVESTOR_PAYOUT_SUMMARY_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_INVESTOR_PAYOUT_SUMMARY_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_INVESTOR_PAYOUT_SUMMARY_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_INVESTOR_PAYOUT_SUMMARY_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,investor_agreement_id          OKL_INVESTOR_PAYOUT_SUMMARY_B.INVESTOR_AGREEMENT_ID%TYPE := OKC_API.G_MISS_NUM
    ,investor_line_id               OKL_INVESTOR_PAYOUT_SUMMARY_B.INVESTOR_LINE_ID%TYPE := OKC_API.G_MISS_NUM
    ,receivable_application_id      OKL_INVESTOR_PAYOUT_SUMMARY_B.RECEIVABLE_APPLICATION_ID%TYPE := OKC_API.G_MISS_NUM
    );
  G_MISS_idh_rec                          idh_rec_type;
  TYPE idh_tbl_type IS TABLE OF idh_rec_type
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
  g_no_parent_record            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_IDH_PVT';
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
    p_idhv_rec                     IN idhv_rec_type,
    x_idhv_rec                     OUT NOCOPY idhv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type,
    x_idhv_tbl                     OUT NOCOPY idhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type,
    x_idhv_tbl                     OUT NOCOPY idhv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_rec                     IN idhv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_rec                     IN idhv_rec_type,
    x_idhv_rec                     OUT NOCOPY idhv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type,
    x_idhv_tbl                     OUT NOCOPY idhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type,
    x_idhv_tbl                     OUT NOCOPY idhv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_rec                     IN idhv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_rec                     IN idhv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_idhv_tbl                     IN idhv_tbl_type);
END OKL_IDH_PVT;

/
