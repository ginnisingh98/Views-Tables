--------------------------------------------------------
--  DDL for Package OKL_SIX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSIXS.pls 120.1 2005/10/30 03:18:09 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TRX_SUBSIDY_POOLS_V Record Spec
  TYPE sixv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,trx_type_code                  OKL_TRX_SUBSIDY_POOLS_V.TRX_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,source_type_code               OKL_TRX_SUBSIDY_POOLS_V.SOURCE_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,source_object_id               NUMBER := OKC_API.G_MISS_NUM
    ,subsidy_pool_id                NUMBER := OKC_API.G_MISS_NUM
    ,dnz_asset_number               OKL_TRX_SUBSIDY_POOLS_V.DNZ_ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,vendor_id                      NUMBER := OKC_API.G_MISS_NUM
    ,source_trx_date                OKL_TRX_SUBSIDY_POOLS_V.SOURCE_TRX_DATE%TYPE := OKC_API.G_MISS_DATE
    ,trx_date                       OKL_TRX_SUBSIDY_POOLS_V.TRX_DATE%TYPE := OKC_API.G_MISS_DATE
    ,subsidy_id                     NUMBER := OKC_API.G_MISS_NUM
    ,trx_reason_code                OKL_TRX_SUBSIDY_POOLS_V.TRX_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,trx_currency_code              OKL_TRX_SUBSIDY_POOLS_V.TRX_CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,trx_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,subsidy_pool_currency_code     OKL_TRX_SUBSIDY_POOLS_V.SUBSIDY_POOL_CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,subsidy_pool_amount            NUMBER := OKC_API.G_MISS_NUM
    ,conversion_rate                NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_TRX_SUBSIDY_POOLS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_TRX_SUBSIDY_POOLS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_TRX_SUBSIDY_POOLS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_sixv_rec                         sixv_rec_type;
  TYPE sixv_tbl_type IS TABLE OF sixv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TRX_SUBSIDY_POOLS Record Spec
  TYPE okl_trx_subsidy_pools_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,trx_type_code                  OKL_TRX_SUBSIDY_POOLS.TRX_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,source_type_code               OKL_TRX_SUBSIDY_POOLS.SOURCE_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,source_object_id               NUMBER := OKC_API.G_MISS_NUM
    ,subsidy_pool_id                NUMBER := OKC_API.G_MISS_NUM
    ,dnz_asset_number               OKL_TRX_SUBSIDY_POOLS.DNZ_ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,vendor_id                      NUMBER := OKC_API.G_MISS_NUM
    ,source_trx_date                OKL_TRX_SUBSIDY_POOLS.SOURCE_TRX_DATE%TYPE := OKC_API.G_MISS_DATE
    ,trx_date                       OKL_TRX_SUBSIDY_POOLS.TRX_DATE%TYPE := OKC_API.G_MISS_DATE
    ,subsidy_id                     NUMBER := OKC_API.G_MISS_NUM
    ,trx_reason_code                OKL_TRX_SUBSIDY_POOLS.TRX_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,trx_currency_code              OKL_TRX_SUBSIDY_POOLS.TRX_CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,trx_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,subsidy_pool_currency_code     OKL_TRX_SUBSIDY_POOLS.SUBSIDY_POOL_CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,subsidy_pool_amount            NUMBER := OKC_API.G_MISS_NUM
    ,conversion_rate                NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_TRX_SUBSIDY_POOLS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_TRX_SUBSIDY_POOLS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_TRX_SUBSIDY_POOLS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOklTrxSubsidyPoolsRec              okl_trx_subsidy_pools_rec_type;
  TYPE okl_trx_subsidy_pools_tbl_type IS TABLE OF okl_trx_subsidy_pools_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SIX_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type,
    x_sixv_rec                     OUT NOCOPY sixv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    x_sixv_tbl                     OUT NOCOPY sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    x_sixv_tbl                     OUT NOCOPY sixv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type,
    x_sixv_rec                     OUT NOCOPY sixv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    x_sixv_tbl                     OUT NOCOPY sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    x_sixv_tbl                     OUT NOCOPY sixv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_rec                     IN sixv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sixv_tbl                     IN sixv_tbl_type);
END OKL_SIX_PVT;

 

/
