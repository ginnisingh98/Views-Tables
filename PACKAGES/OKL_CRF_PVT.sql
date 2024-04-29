--------------------------------------------------------
--  DDL for Package OKL_CRF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CRF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCRFS.pls 120.2 2006/07/11 10:18:06 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_CURE_REFUNDS_V Record Spec
  TYPE crfv_rec_type IS RECORD (
     cure_refund_id                 NUMBER := OKL_API.G_MISS_NUM
    ,refund_number                  OKL_CURE_REFUNDS.REFUND_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,status                         OKL_CURE_REFUNDS.STATUS%TYPE := OKL_API.G_MISS_CHAR
    ,amount                         NUMBER := OKL_API.G_MISS_NUM
    ,balance                        NUMBER := OKL_API.G_MISS_NUM
    ,tap_id                         NUMBER := OKL_API.G_MISS_NUM
    ,tai_id                         NUMBER := OKL_API.G_MISS_NUM
    ,CURE_REFUND_STAGE_ID           NUMBER := OKL_API.G_MISS_NUM
    ,vendor_site_id                 NUMBER := OKL_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,disbursement_amount            NUMBER := OKL_API.G_MISS_NUM
    ,offset_amount                  NUMBER := OKL_API.G_MISS_NUM
    ,offset_contract                NUMBER := OKL_API.G_MISS_NUM
    ,total_refund_due               NUMBER := OKL_API.G_MISS_NUM
    ,refund_date                    OKL_CURE_REFUNDS.REFUND_DATE%TYPE := OKL_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_CURE_REFUNDS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_CURE_REFUNDS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CURE_REFUNDS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CURE_REFUNDS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CURE_REFUNDS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CURE_REFUNDS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CURE_REFUNDS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CURE_REFUNDS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CURE_REFUNDS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CURE_REFUNDS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CURE_REFUNDS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CURE_REFUNDS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CURE_REFUNDS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CURE_REFUNDS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CURE_REFUNDS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CURE_REFUNDS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CURE_REFUNDS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CURE_REFUNDS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CURE_REFUNDS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,cure_refund_header_id          NUMBER := OKL_API.G_MISS_NUM
    ,received_amount                NUMBER := OKL_API.G_MISS_NUM
);
  G_MISS_crfv_rec                         crfv_rec_type;
  TYPE crfv_tbl_type IS TABLE OF crfv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_CURE_REFUNDS Record Spec
  TYPE crf_rec_type IS RECORD (
     cure_refund_id                 NUMBER := OKL_API.G_MISS_NUM
    ,refund_number                  OKL_CURE_REFUNDS.REFUND_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,status                         OKL_CURE_REFUNDS.STATUS%TYPE := OKL_API.G_MISS_CHAR
    ,amount                         NUMBER := OKL_API.G_MISS_NUM
    ,balance                        NUMBER := OKL_API.G_MISS_NUM
    ,tap_id                         NUMBER := OKL_API.G_MISS_NUM
    ,tai_id                         NUMBER := OKL_API.G_MISS_NUM
    ,CURE_REFUND_STAGE_ID           NUMBER := OKL_API.G_MISS_NUM
    ,vendor_site_id                 NUMBER := OKL_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,disbursement_amount            NUMBER := OKL_API.G_MISS_NUM
    ,offset_amount                  NUMBER := OKL_API.G_MISS_NUM
    ,offset_contract                NUMBER := OKL_API.G_MISS_NUM
    ,total_refund_due               NUMBER := OKL_API.G_MISS_NUM
    ,refund_date                    OKL_CURE_REFUNDS.REFUND_DATE%TYPE := OKL_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_CURE_REFUNDS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_CURE_REFUNDS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CURE_REFUNDS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CURE_REFUNDS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CURE_REFUNDS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CURE_REFUNDS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CURE_REFUNDS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CURE_REFUNDS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CURE_REFUNDS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CURE_REFUNDS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CURE_REFUNDS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CURE_REFUNDS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CURE_REFUNDS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CURE_REFUNDS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CURE_REFUNDS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CURE_REFUNDS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CURE_REFUNDS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CURE_REFUNDS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CURE_REFUNDS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,cure_refund_header_id          NUMBER := OKL_API.G_MISS_NUM
    ,received_amount                NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_crf_rec                          crf_rec_type;
  TYPE crf_tbl_type IS TABLE OF crf_rec_type
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CRF_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
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
    p_crfv_rec                     IN crfv_rec_type,
    x_crfv_rec                     OUT NOCOPY crfv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type,
    x_crfv_tbl                     OUT NOCOPY crfv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type,
    x_crfv_tbl                     OUT NOCOPY crfv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_rec                     IN crfv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_rec                     IN crfv_rec_type,
    x_crfv_rec                     OUT NOCOPY crfv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type,
    x_crfv_tbl                     OUT NOCOPY crfv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type,
    x_crfv_tbl                     OUT NOCOPY crfv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_rec                     IN crfv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_rec                     IN crfv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crfv_tbl                     IN crfv_tbl_type);
END OKL_CRF_PVT;

/
