--------------------------------------------------------
--  DDL for Package OKL_POL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPOLS.pls 120.4 2006/11/20 05:42:30 abhsaxen noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_POOLS_V Record Spec
  TYPE polv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,pot_id                         NUMBER := OKL_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,pool_number                    OKL_POOLS.POOL_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_POOLS.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,short_description              OKL_POOLS.SHORT_DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,currency_code                  OKL_POOLS.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,total_principal_amount         NUMBER := OKL_API.G_MISS_NUM
    ,total_receivable_amount        NUMBER := OKL_API.G_MISS_NUM
    ,securities_credit_rating       OKL_POOLS.SECURITIES_CREDIT_RATING%TYPE := OKL_API.G_MISS_CHAR
    ,date_created                   OKL_POOLS.DATE_CREATED%TYPE := OKL_API.G_MISS_DATE
    ,date_last_updated              OKL_POOLS.DATE_LAST_UPDATED%TYPE := OKL_API.G_MISS_DATE
    ,date_last_reconciled           OKL_POOLS.DATE_LAST_UPDATED%TYPE := OKL_API.G_MISS_DATE
    ,date_total_principal_calc      OKL_POOLS.DATE_LAST_UPDATED%TYPE := OKL_API.G_MISS_DATE
    ,status_code                    OKL_POOLS.STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,display_in_lease_center        OKL_POOLS.DISPLAY_IN_LEASE_CENTER%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_POOLS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_POOLS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_POOLS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_POOLS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_POOLS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_POOLS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_POOLS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_POOLS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_POOLS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_POOLS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_POOLS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_POOLS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_POOLS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_POOLS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_POOLS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_POOLS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_POOLS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_POOLS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_POOLS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    --added by abshaxen for legal entity uptake
    ,legal_entity_id                OKL_POOLS.LEGAL_ENTITY_ID%TYPE :=OKL_API.G_MISS_NUM);
  G_MISS_polv_rec                         polv_rec_type;
  TYPE polv_tbl_type IS TABLE OF polv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_POOLS Record Spec
  TYPE pol_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,pot_id                         NUMBER := OKL_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,pool_number                    OKL_POOLS.POOL_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_POOLS.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,short_description              OKL_POOLS.SHORT_DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,currency_code                  OKL_POOLS.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,total_principal_amount         NUMBER := OKL_API.G_MISS_NUM
    ,total_receivable_amount        NUMBER := OKL_API.G_MISS_NUM
    ,securities_credit_rating       OKL_POOLS.SECURITIES_CREDIT_RATING%TYPE := OKL_API.G_MISS_CHAR
    ,date_created                   OKL_POOLS.DATE_CREATED%TYPE := OKL_API.G_MISS_DATE
    ,date_last_updated              OKL_POOLS.DATE_LAST_UPDATED%TYPE := OKL_API.G_MISS_DATE
    ,status_code                    OKL_POOLS.STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,date_last_reconciled           OKL_POOLS.DATE_LAST_UPDATED%TYPE := OKL_API.G_MISS_DATE
    ,date_total_principal_calc      OKL_POOLS.DATE_LAST_UPDATED%TYPE := OKL_API.G_MISS_DATE
    ,display_in_lease_center        OKL_POOLS.DISPLAY_IN_LEASE_CENTER%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_POOLS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_POOLS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_POOLS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_POOLS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_POOLS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_POOLS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_POOLS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_POOLS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_POOLS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_POOLS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_POOLS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_POOLS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_POOLS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_POOLS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_POOLS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_POOLS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_POOLS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_POOLS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_POOLS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    --added by abshaxen for legal entity uptake
    ,legal_entity_id                OKL_POOLS.LEGAL_ENTITY_ID%TYPE :=OKL_API.G_MISS_NUM);
  G_MISS_pol_rec                          pol_rec_type;
  TYPE pol_tbl_type IS TABLE OF pol_rec_type
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

  -- mvasudev, 11/08/2002
  G_OKC_APP			CONSTANT VARCHAR2(200) := OKL_API.G_APP_NAME;
  G_OKL_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_OKL_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_OKL_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_UNQS			CONSTANT VARCHAR2(200) := 'OKL_POL_NOT_UNIQUE';
  G_AK_REGION_NAME VARCHAR2(17) := 'OKL_LA_POOL_CRUPT';

   -- mvasudev, 12/30/2002
   g_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_POL_PVT';
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
    p_polv_rec                     IN polv_rec_type,
    x_polv_rec                     OUT NOCOPY polv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    x_polv_tbl                     OUT NOCOPY polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    x_polv_tbl                     OUT NOCOPY polv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type,
    x_polv_rec                     OUT NOCOPY polv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    x_polv_tbl                     OUT NOCOPY polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    x_polv_tbl                     OUT NOCOPY polv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type);
END OKL_POL_PVT;

/
