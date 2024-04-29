--------------------------------------------------------
--  DDL for Package OKL_CHD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CHD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCHDS.pls 115.4 2003/04/19 20:21:32 pdevaraj noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_CURE_REFUND_HEADERS_V Record Spec
  TYPE chdv_rec_type IS RECORD (
     cure_refund_header_id          NUMBER := OKL_API.G_MISS_NUM
    ,refund_header_number           OKL_CURE_REFUND_HEADERS_V.REFUND_HEADER_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,refund_type                    OKL_CURE_REFUND_HEADERS_V.REFUND_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,refund_due_date                OKL_CURE_REFUND_HEADERS_V.REFUND_DUE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,currency_code                  OKL_CURE_REFUND_HEADERS_V.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,total_refund_due               NUMBER := OKL_API.G_MISS_NUM
    ,disbursement_amount            NUMBER := OKL_API.G_MISS_NUM
    ,RECEIVED_AMOUNT                NUMBER := OKL_API.G_MISS_NUM
    ,OFFSET_AMOUNT                  NUMBER := OKL_API.G_MISS_NUM
    ,NEGOTIATED_AMOUNT              NUMBER := OKL_API.G_MISS_NUM
    ,vendor_site_id                 NUMBER := OKL_API.G_MISS_NUM
    ,refund_status                  OKL_CURE_REFUND_HEADERS_V.REFUND_STATUS%TYPE := OKL_API.G_MISS_CHAR
    ,payment_method                 OKL_CURE_REFUND_HEADERS_V.PAYMENT_METHOD%TYPE := OKL_API.G_MISS_CHAR
    ,payment_term_id                NUMBER := OKL_API.G_MISS_NUM
    ,sfwt_flag                      OKL_CURE_REFUND_HEADERS_V.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_CURE_REFUND_HEADERS_V.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,vendor_cure_due                NUMBER := OKL_API.G_MISS_NUM
    ,vendor_site_cure_due           NUMBER := OKL_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_CURE_REFUND_HEADERS_V.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CURE_REFUND_HEADERS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CURE_REFUND_HEADERS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CURE_REFUND_HEADERS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_chdv_rec                         chdv_rec_type;
  TYPE chdv_tbl_type IS TABLE OF chdv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_CURE_REFUND_HEADERS_B Record Spec
  TYPE chd_rec_type IS RECORD (
     cure_refund_header_id          NUMBER := OKL_API.G_MISS_NUM
    ,refund_header_number           OKL_CURE_REFUND_HEADERS_B.REFUND_HEADER_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,refund_type                    OKL_CURE_REFUND_HEADERS_B.REFUND_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,refund_due_date                OKL_CURE_REFUND_HEADERS_B.REFUND_DUE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,currency_code                  OKL_CURE_REFUND_HEADERS_B.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,total_refund_due               NUMBER := OKL_API.G_MISS_NUM
    ,disbursement_amount            NUMBER := OKL_API.G_MISS_NUM
    ,RECEIVED_AMOUNT                NUMBER := OKL_API.G_MISS_NUM
    ,OFFSET_AMOUNT                  NUMBER := OKL_API.G_MISS_NUM
    ,NEGOTIATED_AMOUNT              NUMBER := OKL_API.G_MISS_NUM
    ,vendor_site_id                 NUMBER := OKL_API.G_MISS_NUM
    ,refund_status                  OKL_CURE_REFUND_HEADERS_B.REFUND_STATUS%TYPE := OKL_API.G_MISS_CHAR
    ,payment_method                 OKL_CURE_REFUND_HEADERS_B.PAYMENT_METHOD%TYPE := OKL_API.G_MISS_CHAR
    ,payment_term_id                NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,vendor_cure_due                NUMBER := OKL_API.G_MISS_NUM
    ,vendor_site_cure_due           NUMBER := OKL_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_CURE_REFUND_HEADERS_B.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CURE_REFUND_HEADERS_B.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CURE_REFUND_HEADERS_B.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CURE_REFUND_HEADERS_B.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_chd_rec                          chd_rec_type;
  TYPE chd_tbl_type IS TABLE OF chd_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_CURE_REFUND_HEADERS_TL Record Spec
  TYPE OklCureRefundHeadersTlRecType IS RECORD (
     cure_refund_header_id          NUMBER := OKL_API.G_MISS_NUM
    ,language                       OKL_CURE_REFUND_HEADERS_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR
    ,source_lang                    OKL_CURE_REFUND_HEADERS_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_CURE_REFUND_HEADERS_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_CURE_REFUND_HEADERS_TL.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CURE_REFUND_HEADERS_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CURE_REFUND_HEADERS_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  GMissOklCureRefundHeadersTlRec          OklCureRefundHeadersTlRecType;
  TYPE OklCureRefundHeadersTlTblType IS TABLE OF OklCureRefundHeadersTlRecType
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CHD_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type,
    x_chdv_rec                     OUT NOCOPY chdv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    x_chdv_tbl                     OUT NOCOPY chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    x_chdv_tbl                     OUT NOCOPY chdv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type,
    x_chdv_rec                     OUT NOCOPY chdv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    x_chdv_tbl                     OUT NOCOPY chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    x_chdv_tbl                     OUT NOCOPY chdv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type);
END OKL_CHD_PVT;

 

/
