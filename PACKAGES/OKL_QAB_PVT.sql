--------------------------------------------------------
--  DDL for Package OKL_QAB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QAB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSQABS.pls 120.3 2006/07/11 10:26:00 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TXD_QTE_ANTCPT_BILL_V Record Spec
  TYPE qabv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,qte_id                         NUMBER := OKC_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,sty_id                         NUMBER := OKC_API.G_MISS_NUM
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,sel_date                       OKL_TXD_QTE_ANTCPT_BILL.SEL_DATE%TYPE := OKC_API.G_MISS_DATE -- rmunjulu EDAT ADDED
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_TXD_QTE_ANTCPT_BILL.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_TXD_QTE_ANTCPT_BILL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_TXD_QTE_ANTCPT_BILL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,currency_code                  OKL_TXD_QTE_ANTCPT_BILL.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,currency_conversion_code       OKL_TXD_QTE_ANTCPT_BILL.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,currency_conversion_type       OKL_TXD_QTE_ANTCPT_BILL.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,currency_conversion_rate       NUMBER := OKC_API.G_MISS_NUM
    ,currency_conversion_date       OKL_TXD_QTE_ANTCPT_BILL.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_qabv_rec                         qabv_rec_type;
  TYPE qabv_tbl_type IS TABLE OF qabv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TXD_QTE_ANTCPT_BILL Record Spec
  TYPE qab_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,qte_id                         NUMBER := OKC_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,sty_id                         NUMBER := OKC_API.G_MISS_NUM
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,sel_date                       OKL_TXD_QTE_ANTCPT_BILL.SEL_DATE%TYPE := OKC_API.G_MISS_DATE -- rmunjulu EDAT ADDED
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_TXD_QTE_ANTCPT_BILL.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_TXD_QTE_ANTCPT_BILL.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_TXD_QTE_ANTCPT_BILL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_TXD_QTE_ANTCPT_BILL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,currency_code                  OKL_TXD_QTE_ANTCPT_BILL.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,currency_conversion_code       OKL_TXD_QTE_ANTCPT_BILL.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,currency_conversion_type       OKL_TXD_QTE_ANTCPT_BILL.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,currency_conversion_rate       NUMBER := OKC_API.G_MISS_NUM
    ,currency_conversion_date       OKL_TXD_QTE_ANTCPT_BILL.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  G_MISS_qab_rec                          qab_rec_type;
  TYPE qab_tbl_type IS TABLE OF qab_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE; -- rmunjulu changed to okl
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE; -- rmunjulu changed to okl
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  -- rmunjulu added
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_QAB_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME; -- rmunjulu Changed APP Name
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
    p_qabv_rec                     IN qabv_rec_type,
    x_qabv_rec                     OUT NOCOPY qabv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    x_qabv_tbl                     OUT NOCOPY qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    x_qabv_tbl                     OUT NOCOPY qabv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type,
    x_qabv_rec                     OUT NOCOPY qabv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    x_qabv_tbl                     OUT NOCOPY qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    x_qabv_tbl                     OUT NOCOPY qabv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_rec                     IN qabv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qabv_tbl                     IN qabv_tbl_type);
END OKL_QAB_PVT;

/
