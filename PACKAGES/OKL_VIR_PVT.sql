--------------------------------------------------------
--  DDL for Package OKL_VIR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VIR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSVIRS.pls 120.4 2005/12/19 18:04:43 rseela noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_VAR_INT_PARAMS_V Record Spec
  TYPE virv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,source_table                   OKL_VAR_INT_PARAMS_V.SOURCE_TABLE%TYPE := OKL_API.G_MISS_CHAR
    ,source_id                      NUMBER := OKL_API.G_MISS_NUM
    ,interest_rate                  NUMBER := OKL_API.G_MISS_NUM
    ,interest_calc_start_date       OKL_VAR_INT_PARAMS_V.INTEREST_CALC_START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,interest_calc_end_date         OKL_VAR_INT_PARAMS_V.INTEREST_CALC_END_DATE%TYPE := OKL_API.G_MISS_DATE
    ,calc_method_code               OKL_VAR_INT_PARAMS_V.CALC_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,principal_balance              NUMBER := OKL_API.G_MISS_NUM
    ,valid_yn                       OKL_VAR_INT_PARAMS_V.VALID_YN%TYPE := OKL_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_VAR_INT_PARAMS_V.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_VAR_INT_PARAMS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_VAR_INT_PARAMS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_VAR_INT_PARAMS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_VAR_INT_PARAMS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_VAR_INT_PARAMS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_VAR_INT_PARAMS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_VAR_INT_PARAMS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_VAR_INT_PARAMS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_VAR_INT_PARAMS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_VAR_INT_PARAMS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,interest_amt                   NUMBER := OKL_API.G_MISS_NUM
    ,interest_calc_days             NUMBER := OKL_API.G_MISS_NUM	);
  G_MISS_virv_rec                         virv_rec_type;
  TYPE virv_tbl_type IS TABLE OF virv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_VAR_INT_PARAMS Record Spec
  TYPE vir_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,source_table                   OKL_VAR_INT_PARAMS.SOURCE_TABLE%TYPE := OKL_API.G_MISS_CHAR
    ,source_id                      NUMBER := OKL_API.G_MISS_NUM
    ,interest_rate                  NUMBER := OKL_API.G_MISS_NUM
    ,interest_calc_start_date       OKL_VAR_INT_PARAMS.INTEREST_CALC_START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,interest_calc_end_date         OKL_VAR_INT_PARAMS.INTEREST_CALC_END_DATE%TYPE := OKL_API.G_MISS_DATE
    ,calc_method_code               OKL_VAR_INT_PARAMS.CALC_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,principal_balance              NUMBER := OKL_API.G_MISS_NUM
    ,valid_yn                       OKL_VAR_INT_PARAMS.VALID_YN%TYPE := OKL_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_VAR_INT_PARAMS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_VAR_INT_PARAMS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_VAR_INT_PARAMS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_VAR_INT_PARAMS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_VAR_INT_PARAMS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_VAR_INT_PARAMS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_VAR_INT_PARAMS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_VAR_INT_PARAMS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_VAR_INT_PARAMS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_VAR_INT_PARAMS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_VAR_INT_PARAMS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_VAR_INT_PARAMS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_VAR_INT_PARAMS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_VAR_INT_PARAMS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_VAR_INT_PARAMS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_VAR_INT_PARAMS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_VAR_INT_PARAMS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_VAR_INT_PARAMS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_VAR_INT_PARAMS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,interest_amt                   NUMBER := OKL_API.G_MISS_NUM
    ,interest_calc_days             NUMBER := OKL_API.G_MISS_NUM		);
  G_MISS_vir_rec                          vir_rec_type;
  TYPE vir_tbl_type IS TABLE OF vir_rec_type
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

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_VIR_PVT';
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
    p_virv_rec                     IN virv_rec_type,
    x_virv_rec                     OUT NOCOPY virv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type,
    x_virv_tbl                     OUT NOCOPY virv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type,
    x_virv_tbl                     OUT NOCOPY virv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_rec                     IN virv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_rec                     IN virv_rec_type,
    x_virv_rec                     OUT NOCOPY virv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type,
    x_virv_tbl                     OUT NOCOPY virv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type,
    x_virv_tbl                     OUT NOCOPY virv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_rec                     IN virv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_rec                     IN virv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_virv_tbl                     IN virv_tbl_type);
END OKL_VIR_PVT;

/
