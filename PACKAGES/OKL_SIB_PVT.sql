--------------------------------------------------------
--  DDL for Package OKL_SIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSIBS.pls 120.1 2005/10/30 03:18:04 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_SUBSIDY_POOL_BUDGETS_V Record Spec
  TYPE sibv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,sfwt_flag                      OKL_SUBSIDY_POOL_BUDGETS_V.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,note                           OKL_SUBSIDY_POOL_BUDGETS_V.NOTE%TYPE := OKL_API.G_MISS_CHAR
    ,budget_type_code               OKL_SUBSIDY_POOL_BUDGETS_V.BUDGET_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,effective_from_date            OKL_SUBSIDY_POOL_BUDGETS_V.EFFECTIVE_FROM_DATE%TYPE := OKL_API.G_MISS_DATE
    ,decision_status_code           OKL_SUBSIDY_POOL_BUDGETS_V.DECISION_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,budget_amount                  NUMBER := OKL_API.G_MISS_NUM
    ,subsidy_pool_id                NUMBER := OKL_API.G_MISS_NUM
    ,decision_date                  OKL_SUBSIDY_POOL_BUDGETS_V.DECISION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SUBSIDY_POOL_BUDGETS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUBSIDY_POOL_BUDGETS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUBSIDY_POOL_BUDGETS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_sibv_rec                         sibv_rec_type;
  TYPE sibv_tbl_type IS TABLE OF sibv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_SUBSIDY_POOL_BUDGETS_B Record Spec
  TYPE sib_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,budget_type_code               OKL_SUBSIDY_POOL_BUDGETS_B.BUDGET_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,effective_from_date            OKL_SUBSIDY_POOL_BUDGETS_B.EFFECTIVE_FROM_DATE%TYPE := OKL_API.G_MISS_DATE
    ,decision_status_code           OKL_SUBSIDY_POOL_BUDGETS_B.DECISION_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,budget_amount                  NUMBER := OKL_API.G_MISS_NUM
    ,note                           OKL_SUBSIDY_POOL_BUDGETS_B.NOTE%TYPE := OKL_API.G_MISS_CHAR
    ,subsidy_pool_id                NUMBER := OKL_API.G_MISS_NUM
    ,decision_date                  OKL_SUBSIDY_POOL_BUDGETS_B.DECISION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SUBSIDY_POOL_BUDGETS_B.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUBSIDY_POOL_BUDGETS_B.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUBSIDY_POOL_BUDGETS_B.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_sib_rec                          sib_rec_type;
  TYPE sib_tbl_type IS TABLE OF sib_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_SUBSIDY_POOL_BUDGETS_TL Record Spec
  TYPE OklSubsidyPoolBudgetsTlRecType IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,note                           OKL_SUBSIDY_POOL_BUDGETS_TL.NOTE%TYPE := OKL_API.G_MISS_CHAR
    ,language                       OKL_SUBSIDY_POOL_BUDGETS_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR
    ,source_lang                    OKL_SUBSIDY_POOL_BUDGETS_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_SUBSIDY_POOL_BUDGETS_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SUBSIDY_POOL_BUDGETS_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SUBSIDY_POOL_BUDGETS_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  GMissOklsbsidypolbdgtstlrc              OklSubsidyPoolBudgetsTlRecType;
  TYPE OklSubsidyPoolBudgetsTlTblType IS TABLE OF OklSubsidyPoolBudgetsTlRecType
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SIB_PVT';
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
    p_sibv_rec                     IN sibv_rec_type,
    x_sibv_rec                     OUT NOCOPY sibv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type,
    x_sibv_tbl                     OUT NOCOPY sibv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type,
    x_sibv_tbl                     OUT NOCOPY sibv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_rec                     IN sibv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_rec                     IN sibv_rec_type,
    x_sibv_rec                     OUT NOCOPY sibv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type,
    x_sibv_tbl                     OUT NOCOPY sibv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type,
    x_sibv_tbl                     OUT NOCOPY sibv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_rec                     IN sibv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_rec                     IN sibv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sibv_tbl                     IN sibv_tbl_type);
END OKL_SIB_PVT;

 

/
