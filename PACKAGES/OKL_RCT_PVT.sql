--------------------------------------------------------
--  DDL for Package OKL_RCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RCT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSRCTS.pls 120.4 2007/08/30 09:02:46 asawanka ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE rct_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    currency_code                  OKL_TRX_CSH_RECEIPT_B.CURRENCY_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    exchange_rate_type             OKL_TRX_CSH_RECEIPT_B.EXCHANGE_RATE_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    exchange_rate_date             OKL_TRX_CSH_RECEIPT_B.EXCHANGE_RATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    exchange_rate                  OKL_TRX_CSH_RECEIPT_B.EXCHANGE_RATE%TYPE := Okl_Api.G_MISS_NUM,
    btc_id                         NUMBER := Okl_Api.G_MISS_NUM,
    iba_id                         NUMBER := Okl_Api.G_MISS_NUM,
    gl_date                        DATE   := Okl_Api.G_MISS_DATE,
    ile_id                         NUMBER := Okl_Api.G_MISS_NUM,
    irm_id                         NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    check_number                   OKL_TRX_CSH_RECEIPT_B.CHECK_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    date_effective                 OKL_TRX_CSH_RECEIPT_B.DATE_EFFECTIVE%TYPE := Okl_Api.G_MISS_DATE,
    rcpt_status_code               OKL_TRX_CSH_RECEIPT_B.RCPT_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_TRX_CSH_RECEIPT_B.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    attribute_category             OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_CSH_RECEIPT_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_CSH_RECEIPT_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_CSH_RECEIPT_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
-- New column receipt type added.
    receipt_type                   OKL_TRX_CSH_RECEIPT_B.RECEIPT_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    cash_receipt_id		OKL_TRX_CSH_RECEIPT_B.CASH_RECEIPT_ID%TYPE := Okl_Api.G_MISS_NUM,
    fully_applied_flag		OKL_TRX_CSH_RECEIPT_B.FULLY_APPLIED_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    expired_flag			OKL_TRX_CSH_RECEIPT_B.EXPIRED_FLAG%TYPE := Okl_Api.G_MISS_CHAR);
  g_miss_rct_rec                          rct_rec_type;
  TYPE rct_tbl_type IS TABLE OF rct_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklTrxCshReceiptTlRecType IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_TRX_CSH_RECEIPT_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_TRX_CSH_RECEIPT_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_TRX_CSH_RECEIPT_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_TRX_CSH_RECEIPT_TL.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_CSH_RECEIPT_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_CSH_RECEIPT_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklTrxCshReceiptTlRec              OklTrxCshReceiptTlRecType;
  TYPE OklTrxCshReceiptTlTblType IS TABLE OF OklTrxCshReceiptTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE rctv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    sfwt_flag                      OKL_TRX_CSH_RECEIPT_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    btc_id                         NUMBER := Okl_Api.G_MISS_NUM,
    iba_id                         NUMBER := Okl_Api.G_MISS_NUM,
    gl_date                        DATE   := Okl_Api.G_MISS_DATE,
    ile_id                         NUMBER := Okl_Api.G_MISS_NUM,
    irm_id                         NUMBER := Okl_Api.G_MISS_NUM,
    check_number                   OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    currency_code                  OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    exchange_rate_type             OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    exchange_rate_date             OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    exchange_rate                  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE := Okl_Api.G_MISS_NUM,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    date_effective                 OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE := Okl_Api.G_MISS_DATE,
    rcpt_status_code               OKL_TRX_CSH_RECEIPT_V.RCPT_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_TRX_CSH_RECEIPT_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category             OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_CSH_RECEIPT_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_TRX_CSH_RECEIPT_V.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_CSH_RECEIPT_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_CSH_RECEIPT_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
-- New column receipt type added.
    receipt_type                   OKL_TRX_CSH_RECEIPT_V.RECEIPT_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    cash_receipt_id		OKL_TRX_CSH_RECEIPT_B.CASH_RECEIPT_ID%TYPE := Okl_Api.G_MISS_NUM,
    fully_applied_flag		OKL_TRX_CSH_RECEIPT_B.FULLY_APPLIED_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    expired_flag			OKL_TRX_CSH_RECEIPT_B.EXPIRED_FLAG%TYPE := Okl_Api.G_MISS_CHAR);
  g_miss_rctv_rec                         rctv_rec_type;
  TYPE rctv_tbl_type IS TABLE OF rctv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_RCT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- ADDED AFTER TAPI 04/17/2001
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGES
  ---------------------------------------------------------------------------
  G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_USER_MESSAGE               CONSTANT   VARCHAR2(200) := 'OKL_CONTRACTS_INVALID_VALUE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_TRX_AR_INVOICES_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

  ---------------------------------------------------------------------------
  -- POST TAPI GENERATION CODE ENDS HERE.
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type,
    x_rctv_rec                     OUT NOCOPY rctv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type,
    x_rctv_tbl                     OUT NOCOPY rctv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type,
    x_rctv_rec                     OUT NOCOPY rctv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type,
    x_rctv_tbl                     OUT NOCOPY rctv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type);

END Okl_Rct_Pvt;

/
