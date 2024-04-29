--------------------------------------------------------
--  DDL for Package OKL_PFL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PFL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPFLS.pls 115.7 2002/12/20 00:06:15 gkadarka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_PRTFL_LINES_V Record Spec
  TYPE pflv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,sfwt_flag                      OKL_PRTFL_LINES_V.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,budget_amount                  NUMBER := OKL_API.G_MISS_NUM
    ,date_strategy_executed         OKL_PRTFL_LINES_V.DATE_STRATEGY_EXECUTED%TYPE := OKL_API.G_MISS_DATE
    ,date_strategy_execution_due    OKL_PRTFL_LINES_V.DATE_STRATEGY_EXECUTION_DUE%TYPE := OKL_API.G_MISS_DATE
    ,date_budget_amount_last_review OKL_PRTFL_LINES_V.DATE_BUDGET_AMOUNT_LAST_REVIEW%TYPE := OKL_API.G_MISS_DATE
    ,trx_status_code                OKL_PRTFL_LINES_V.TRX_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,asset_track_strategy_code      OKL_PRTFL_LINES_V.ASSET_TRACK_STRATEGY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,pfc_id                         NUMBER := OKL_API.G_MISS_NUM
    ,tmb_id                         NUMBER := OKL_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKL_API.G_MISS_NUM
    ,fma_id                         NUMBER := OKL_API.G_MISS_NUM
    ,comments                       OKL_PRTFL_LINES_V.COMMENTS%TYPE := OKL_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_PRTFL_LINES_V.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_PRTFL_LINES_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_PRTFL_LINES_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_PRTFL_LINES_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_PRTFL_LINES_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_PRTFL_LINES_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_PRTFL_LINES_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_PRTFL_LINES_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_PRTFL_LINES_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_PRTFL_LINES_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_PRTFL_LINES_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_PRTFL_LINES_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_PRTFL_LINES_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_PRTFL_LINES_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_PRTFL_LINES_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_PRTFL_LINES_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_PRTFL_LINES_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_PRTFL_LINES_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_PRTFL_LINES_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_PRTFL_LINES_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_PRTFL_LINES_V.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_PRTFL_LINES_V.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_PRTFL_LINES_V.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_PRTFL_LINES_V.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  -- RABHUPAT - 2667636 - End
  G_MISS_pflv_rec                         pflv_rec_type;
  TYPE pflv_tbl_type IS TABLE OF pflv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_PRTFL_LINES_B Record Spec
  TYPE pfl_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,budget_amount                  NUMBER := OKL_API.G_MISS_NUM
    ,date_strategy_executed         OKL_PRTFL_LINES_B.DATE_STRATEGY_EXECUTED%TYPE := OKL_API.G_MISS_DATE
    ,date_strategy_execution_due    OKL_PRTFL_LINES_B.DATE_STRATEGY_EXECUTION_DUE%TYPE := OKL_API.G_MISS_DATE
    ,date_budget_amount_last_review OKL_PRTFL_LINES_B.DATE_BUDGET_AMOUNT_LAST_REVIEW%TYPE := OKL_API.G_MISS_DATE
    ,trx_status_code                OKL_PRTFL_LINES_B.TRX_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,asset_track_strategy_code      OKL_PRTFL_LINES_B.ASSET_TRACK_STRATEGY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,pfc_id                         NUMBER := OKL_API.G_MISS_NUM
    ,tmb_id                         NUMBER := OKL_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKL_API.G_MISS_NUM
    ,fma_id                         NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_PRTFL_LINES_B.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_PRTFL_LINES_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_PRTFL_LINES_B.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_PRTFL_LINES_B.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_PRTFL_LINES_B.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_PRTFL_LINES_B.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_PRTFL_LINES_B.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_PRTFL_LINES_B.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_PRTFL_LINES_B.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_PRTFL_LINES_B.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_PRTFL_LINES_B.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_PRTFL_LINES_B.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_PRTFL_LINES_B.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_PRTFL_LINES_B.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_PRTFL_LINES_B.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_PRTFL_LINES_B.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_PRTFL_LINES_B.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_PRTFL_LINES_B.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_PRTFL_LINES_B.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_PRTFL_LINES_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_PRTFL_LINES_B.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_PRTFL_LINES_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_PRTFL_LINES_B.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_PRTFL_LINES_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  --RABHUPAT - 2667636 - End
  G_MISS_pfl_rec                          pfl_rec_type;
  TYPE pfl_tbl_type IS TABLE OF pfl_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_PRTFL_LINES_TL Record Spec
  TYPE okl_prtfl_lines_tl_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,language                       OKL_PRTFL_LINES_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR
    ,source_lang                    OKL_PRTFL_LINES_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_PRTFL_LINES_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,comments                       OKL_PRTFL_LINES_TL.COMMENTS%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_PRTFL_LINES_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_PRTFL_LINES_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_okl_prtfl_lines_tl_rec           okl_prtfl_lines_tl_rec_type;
  TYPE okl_prtfl_lines_tl_tbl_type IS TABLE OF okl_prtfl_lines_tl_rec_type
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

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_PFL_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
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
    p_pflv_rec                     IN pflv_rec_type,
    x_pflv_rec                     OUT NOCOPY pflv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    x_pflv_tbl                     OUT NOCOPY pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    x_pflv_tbl                     OUT NOCOPY pflv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type,
    x_pflv_rec                     OUT NOCOPY pflv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    x_pflv_tbl                     OUT NOCOPY pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    x_pflv_tbl                     OUT NOCOPY pflv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_rec                     IN pflv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pflv_tbl                     IN pflv_tbl_type);
END OKL_PFL_PVT;

 

/
