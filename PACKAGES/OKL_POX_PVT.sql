--------------------------------------------------------
--  DDL for Package OKL_POX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPOXS.pls 120.4 2007/12/07 09:05:40 sosharma noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_POOL_TRANSACTIONS_V Record Spec
  TYPE poxv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,pol_id                         NUMBER := OKL_API.G_MISS_NUM
    ,transaction_number             NUMBER := OKL_API.G_MISS_NUM
    ,transaction_date               OKL_POOL_TRANSACTIONS_V.TRANSACTION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,transaction_type               OKL_POOL_TRANSACTIONS_V.TRANSACTION_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,transaction_sub_type           OKL_POOL_TRANSACTIONS_V.TRANSACTION_SUB_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,date_effective                 OKL_POOL_TRANSACTIONS_V.DATE_EFFECTIVE%TYPE := OKL_API.G_MISS_DATE
    ,currency_code                  OKL_POOL_TRANSACTIONS_V.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_type       OKL_POOL_TRANSACTIONS_V.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_date       OKL_POOL_TRANSACTIONS_V.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,currency_conversion_rate       NUMBER := OKL_API.G_MISS_NUM
    ,transaction_reason             OKL_POOL_TRANSACTIONS_V.TRANSACTION_REASON%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_POOL_TRANSACTIONS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_POOL_TRANSACTIONS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_POOL_TRANSACTIONS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_POOL_TRANSACTIONS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_POOL_TRANSACTIONS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_POOL_TRANSACTIONS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_POOL_TRANSACTIONS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_POOL_TRANSACTIONS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_POOL_TRANSACTIONS_V.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_POOL_TRANSACTIONS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_POOL_TRANSACTIONS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    --added by abhsaxen for Legal Entity Uptake
    ,legal_entity_id                OKL_POOL_TRANSACTIONS_V.LEGAL_ENTITY_ID%TYPE := OKL_API.G_MISS_NUM
   -- sosharma 12/03/07 Added for enabling status on transactions
     ,transaction_status            OKL_POOL_TRANSACTIONS.TRANSACTION_STATUS%TYPE := OKL_API.G_MISS_CHAR );
  G_MISS_poxv_rec                         poxv_rec_type;
  TYPE poxv_tbl_type IS TABLE OF poxv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_POOL_TRANSACTIONS Record Spec
  TYPE pox_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,pol_id                         NUMBER := OKL_API.G_MISS_NUM
    ,transaction_number             NUMBER := OKL_API.G_MISS_NUM
    ,transaction_date               OKL_POOL_TRANSACTIONS.TRANSACTION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,transaction_type               OKL_POOL_TRANSACTIONS.TRANSACTION_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,transaction_sub_type           OKL_POOL_TRANSACTIONS.TRANSACTION_SUB_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,transaction_reason             OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE := OKL_API.G_MISS_CHAR
    ,date_effective                 OKL_POOL_TRANSACTIONS.DATE_EFFECTIVE%TYPE := OKL_API.G_MISS_DATE
    ,currency_code                  OKL_POOL_TRANSACTIONS.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_type       OKL_POOL_TRANSACTIONS.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_date       OKL_POOL_TRANSACTIONS.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,currency_conversion_rate       NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_POOL_TRANSACTIONS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_POOL_TRANSACTIONS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_POOL_TRANSACTIONS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_POOL_TRANSACTIONS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_POOL_TRANSACTIONS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_POOL_TRANSACTIONS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_POOL_TRANSACTIONS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_POOL_TRANSACTIONS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_POOL_TRANSACTIONS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_POOL_TRANSACTIONS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_POOL_TRANSACTIONS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_POOL_TRANSACTIONS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_POOL_TRANSACTIONS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_POOL_TRANSACTIONS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_POOL_TRANSACTIONS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_POOL_TRANSACTIONS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_POOL_TRANSACTIONS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_POOL_TRANSACTIONS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_POOL_TRANSACTIONS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    --added by abhsaxen for Legal Entity Uptake
    ,legal_entity_id                OKL_POOL_TRANSACTIONS.LEGAL_ENTITY_ID%TYPE := OKL_API.G_MISS_NUM
    -- sosharma 12/03/07 Added for enabling status on transactions
    ,transaction_status            OKL_POOL_TRANSACTIONS.TRANSACTION_STATUS%TYPE := OKL_API.G_MISS_CHAR );
  G_MISS_pox_rec                          pox_rec_type;
  TYPE pox_tbl_type IS TABLE OF pox_rec_type
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';
  -- mvasudev, 11/08/2002
  G_OKC_APP			CONSTANT VARCHAR2(200) := OKL_API.G_APP_NAME;
  G_OKL_UNQS                        CONSTANT VARCHAR2(200) := 'OKL_POX_NOT_UNIQUE';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_POX_PVT';
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
    p_poxv_rec                     IN poxv_rec_type,
    x_poxv_rec                     OUT NOCOPY poxv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    x_poxv_tbl                     OUT NOCOPY poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    x_poxv_tbl                     OUT NOCOPY poxv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type,
    x_poxv_rec                     OUT NOCOPY poxv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    x_poxv_tbl                     OUT NOCOPY poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    x_poxv_tbl                     OUT NOCOPY poxv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_rec                     IN poxv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_poxv_tbl                     IN poxv_tbl_type);
END OKL_POX_PVT;

/
