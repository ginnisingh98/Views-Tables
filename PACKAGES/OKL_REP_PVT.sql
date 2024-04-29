--------------------------------------------------------
--  DDL for Package OKL_REP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSREPS.pls 120.0 2007/12/10 17:40:55 dcshanmu noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_REPORTS_V Record Spec
  TYPE repv_rec_type IS RECORD (
     report_id                      NUMBER
    ,name                           OKL_REPORTS_V.NAME%TYPE
    ,chart_of_accounts_id           OKL_REPORTS_V.CHART_OF_ACCOUNTS_ID%TYPE
    ,book_classification_code       OKL_REPORTS_V.BOOK_CLASSIFICATION_CODE%TYPE
    ,ledger_id                      OKL_REPORTS_V.LEDGER_ID%TYPE
    ,report_category_code           OKL_REPORTS_V.REPORT_CATEGORY_CODE%TYPE
    ,report_type_code               OKL_REPORTS_V.REPORT_TYPE_CODE%TYPE
    ,activity_code                  OKL_REPORTS_V.ACTIVITY_CODE%TYPE
    ,status_code                    OKL_REPORTS_V.STATUS_CODE%TYPE
    ,description                    OKL_REPORTS_V.DESCRIPTION%TYPE
    ,effective_from_date            OKL_REPORTS_V.EFFECTIVE_FROM_DATE%TYPE
    ,effective_to_date              OKL_REPORTS_V.EFFECTIVE_TO_DATE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_REPORTS_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_REPORTS_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER
    ,language                       OKL_REPORTS_V.LANGUAGE%TYPE
    ,source_lang                    OKL_REPORTS_V.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_REPORTS_V.SFWT_FLAG%TYPE);
  G_MISS_repv_rec                         repv_rec_type;
  TYPE repv_tbl_type IS TABLE OF repv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_REPORTS_B Record Spec
  TYPE rep_rec_type IS RECORD (
     report_id                      NUMBER
    ,name                           OKL_REPORTS_B.NAME%TYPE
    ,chart_of_accounts_id           OKL_REPORTS_B.CHART_OF_ACCOUNTS_ID%TYPE
    ,book_classification_code       OKL_REPORTS_B.BOOK_CLASSIFICATION_CODE%TYPE
    ,ledger_id                      NUMBER
    ,report_category_code           OKL_REPORTS_B.REPORT_CATEGORY_CODE%TYPE
    ,report_type_code               OKL_REPORTS_B.REPORT_TYPE_CODE%TYPE
    ,effective_from_date            OKL_REPORTS_B.EFFECTIVE_FROM_DATE%TYPE
    ,activity_code                  OKL_REPORTS_B.ACTIVITY_CODE%TYPE
    ,status_code                    OKL_REPORTS_B.STATUS_CODE%TYPE
    ,effective_to_date              OKL_REPORTS_B.EFFECTIVE_TO_DATE%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_REPORTS_B.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_REPORTS_B.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_rep_rec                          rep_rec_type;
  TYPE rep_tbl_type IS TABLE OF rep_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_REPORTS_TL Record Spec
  TYPE okl_reports_tl_rec_type IS RECORD (
     report_id                      NUMBER
    ,language                       OKL_REPORTS_TL.LANGUAGE%TYPE
    ,source_lang                    OKL_REPORTS_TL.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_REPORTS_TL.SFWT_FLAG%TYPE
    ,name                           OKL_REPORTS_TL.NAME%TYPE
    ,description                    OKL_REPORTS_TL.DESCRIPTION%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_REPORTS_TL.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_REPORTS_TL.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_okl_reports_tl_rec               okl_reports_tl_rec_type;
  TYPE okl_reports_tl_tbl_type IS TABLE OF okl_reports_tl_rec_type
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_COL_ERROR            CONSTANT VARCHAR2(30)  := 'OKL_COL_ERROR';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_REP_PVT';
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
    p_repv_rec                     IN repv_rec_type,
    x_repv_rec                     OUT NOCOPY repv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type,
    x_repv_rec                     OUT NOCOPY repv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type);
END OKL_REP_PVT;

/
