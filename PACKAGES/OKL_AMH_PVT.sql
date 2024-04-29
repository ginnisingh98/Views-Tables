--------------------------------------------------------
--  DDL for Package OKL_AMH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AMH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAMHS.pls 120.4 2006/08/11 07:55:14 pagarg noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE amhv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := okl_api.G_MISS_NUM
    ,hold_period_days               NUMBER := okl_api.G_MISS_NUM
    ,category_id                    NUMBER := okl_api.G_MISS_NUM
    ,book_type_code                 OKL_AMORT_HLD_SETUPS_ALL.BOOK_TYPE_CODE%TYPE := okl_api.G_MISS_CHAR
    ,method_id                      NUMBER := okl_api.G_MISS_NUM
    -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
    ,DEPRN_RATE                     NUMBER := okl_api.G_MISS_NUM
    ,org_id                         NUMBER := okl_api.G_MISS_NUM
    ,created_by                     NUMBER := okl_api.G_MISS_NUM
    ,creation_date                  OKL_AMORT_HLD_SETUPS_ALL.CREATION_DATE%TYPE := okl_api.G_MISS_DATE
    ,last_updated_by                NUMBER := okl_api.G_MISS_NUM
    ,last_update_date               OKL_AMORT_HLD_SETUPS_ALL.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE
    ,last_update_login              NUMBER := okl_api.G_MISS_NUM);
  G_MISS_amhv_rec                         amhv_rec_type;
  TYPE amhv_tbl_type IS TABLE OF amhv_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE amh_rec_type IS RECORD (
     id                             NUMBER := okl_api.G_MISS_NUM
    ,object_version_number          NUMBER := okl_api.G_MISS_NUM
    ,hold_period_days               NUMBER := okl_api.G_MISS_NUM
    ,category_id                    NUMBER := okl_api.G_MISS_NUM
    ,book_type_code                 OKL_AMORT_HOLD_SETUPS.BOOK_TYPE_CODE%TYPE := okl_api.G_MISS_CHAR
    ,method_id                      NUMBER := okl_api.G_MISS_NUM
    -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
    ,deprn_rate                     NUMBER := okl_api.G_MISS_NUM
    ,org_id                         NUMBER := okl_api.G_MISS_NUM
    ,created_by                     NUMBER := okl_api.G_MISS_NUM
    ,creation_date                  OKL_AMORT_HOLD_SETUPS.CREATION_DATE%TYPE := okl_api.G_MISS_DATE
    ,last_updated_by                NUMBER := okl_api.G_MISS_NUM
    ,last_update_date               OKL_AMORT_HOLD_SETUPS.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE
    ,last_update_login              NUMBER := okl_api.G_MISS_NUM);
  G_MISS_amh_rec                          amh_rec_type;
  TYPE amh_tbl_type IS TABLE OF amh_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := okc_api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := okc_api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := okc_api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := okc_api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := okc_api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := okc_api.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := okc_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := okc_api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := okc_api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := okc_api.G_CHILD_TABLE_TOKEN;
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_AMH_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := okc_api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type,
    x_amhv_rec                     OUT NOCOPY amhv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    x_amhv_tbl                     OUT NOCOPY amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    x_amhv_tbl                     OUT NOCOPY amhv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type,
    x_amhv_rec                     OUT NOCOPY amhv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    x_amhv_tbl                     OUT NOCOPY amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    x_amhv_tbl                     OUT NOCOPY amhv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type);
END OKL_AMH_PVT;

/
