--------------------------------------------------------
--  DDL for Package OKL_BTC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BTC_PVT" AUTHID CURRENT_USER AS
/*$Header: OKLSBTCS.pls 120.5 2007/09/06 12:30:48 sosharma noship $*/
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE btc_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    date_entered                   OKL_TRX_CSH_BATCH_B.DATE_ENTERED%TYPE := Okl_Api.G_MISS_DATE,
    date_gl_requested              OKL_TRX_CSH_BATCH_B.DATE_GL_REQUESTED%TYPE := Okl_Api.G_MISS_DATE,
    date_deposit                   OKL_TRX_CSH_BATCH_B.DATE_DEPOSIT%TYPE := Okl_Api.G_MISS_DATE,
    batch_qty                      NUMBER := Okl_Api.G_MISS_NUM,
    batch_total                    NUMBER := Okl_Api.G_MISS_NUM,
    batch_currency                 OKL_TRX_CSH_BATCH_B.BATCH_CURRENCY%TYPE := Okl_Api.G_MISS_CHAR,
    irm_id                         OKL_TRX_CSH_BATCH_B.IRM_ID%TYPE := Okl_Api.G_MISS_NUM,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_TRX_CSH_BATCH_B.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
   org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    attribute_category             OKL_TRX_CSH_BATCH_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_CSH_BATCH_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_CSH_BATCH_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_CSH_BATCH_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_CSH_BATCH_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_CSH_BATCH_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_CSH_BATCH_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_CSH_BATCH_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_CSH_BATCH_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_CSH_BATCH_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
    trx_status_code				   OKL_TRX_CSH_BATCH_B.TRX_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_type       OKL_TRX_CSH_BATCH_B.currency_conversion_type%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_rate       OKL_TRX_CSH_BATCH_B.currency_conversion_rate%TYPE := Okl_Api.G_MISS_NUM,
    currency_conversion_date       OKL_TRX_CSH_BATCH_B.currency_conversion_date%TYPE := Okl_Api.G_MISS_DATE,
    remit_bank_id                  OKL_TRX_CSH_BATCH_B.REMIT_BANK_ID%TYPE := Okl_Api.G_MISS_NUM

 );
  g_miss_btc_rec                          btc_rec_type;
  TYPE btc_tbl_type IS TABLE OF btc_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_trx_csh_batch_tl_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_TRX_CSH_BATCH_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_TRX_CSH_BATCH_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_TRX_CSH_BATCH_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    name                           OKL_TRX_CSH_BATCH_TL.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_TRX_CSH_BATCH_TL.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_CSH_BATCH_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_CSH_BATCH_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklTrxCshBatchTlRec                okl_trx_csh_batch_tl_rec_type;
  TYPE okl_trx_csh_batch_tl_tbl_type IS TABLE OF okl_trx_csh_batch_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE btcv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    sfwt_flag                      OKL_TRX_CSH_BATCH_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    name                           OKL_TRX_CSH_BATCH_V.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    date_entered                   OKL_TRX_CSH_BATCH_V.DATE_ENTERED%TYPE := Okl_Api.G_MISS_DATE,
    date_gl_requested              OKL_TRX_CSH_BATCH_V.DATE_GL_REQUESTED%TYPE := Okl_Api.G_MISS_DATE,
    date_deposit                   OKL_TRX_CSH_BATCH_V.DATE_DEPOSIT%TYPE := Okl_Api.G_MISS_DATE,
    batch_qty                      NUMBER := Okl_Api.G_MISS_NUM,
    batch_total                    NUMBER := Okl_Api.G_MISS_NUM,
    batch_currency                 OKL_TRX_CSH_BATCH_B.BATCH_CURRENCY%TYPE := Okl_Api.G_MISS_CHAR,
    irm_id                         OKL_TRX_CSH_BATCH_B.IRM_ID%TYPE := Okl_Api.G_MISS_NUM,
    description                    OKL_TRX_CSH_BATCH_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category             OKL_TRX_CSH_BATCH_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_CSH_BATCH_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_CSH_BATCH_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_CSH_BATCH_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_CSH_BATCH_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_CSH_BATCH_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_CSH_BATCH_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_CSH_BATCH_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_TRX_CSH_BATCH_V.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_CSH_BATCH_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_CSH_BATCH_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
	trx_status_code				   OKL_TRX_CSH_BATCH_V.TRX_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_type       OKL_TRX_CSH_BATCH_B.currency_conversion_type%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_rate       OKL_TRX_CSH_BATCH_B.currency_conversion_rate%TYPE := Okl_Api.G_MISS_NUM,
    currency_conversion_date       OKL_TRX_CSH_BATCH_B.currency_conversion_date%TYPE := Okl_Api.G_MISS_DATE,
        remit_bank_id                  OKL_TRX_CSH_BATCH_B.REMIT_BANK_ID%TYPE := Okl_Api.G_MISS_NUM
	);

    g_miss_btcv_rec                         btcv_rec_type;
  TYPE btcv_tbl_type IS TABLE OF btcv_rec_type
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
  G_NOT_SAME         CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_BTC_PVT';
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

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_TRX_AR_INVOICES_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

  ---------------------------------------------------------------------------
  -- POST GEN TAPI CODE ENDS HERE 04/17/2001
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
    p_btcv_rec                     IN btcv_rec_type,
    x_btcv_rec                     OUT NOCOPY btcv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type,
    x_btcv_tbl                     OUT NOCOPY btcv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type,
    x_btcv_rec                     OUT NOCOPY btcv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type,
    x_btcv_tbl                     OUT NOCOPY btcv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type);

END Okl_Btc_Pvt;

/
