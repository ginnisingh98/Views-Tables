--------------------------------------------------------
--  DDL for Package OKL_TBC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TBC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTBCS.pls 120.6 2007/03/12 10:23:08 asawanka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TBC_DEFINITIONS_V Record Spec
  TYPE tbcv_rec_type IS RECORD (

     result_code                    OKL_TAX_ATTR_DEFINITIONS.RESULT_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,purchase_option_code           OKL_TAX_ATTR_DEFINITIONS.PURCHASE_OPTION_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,pdt_id                         NUMBER := OKL_API.G_MISS_NUM
    ,try_id                         NUMBER := OKL_API.G_MISS_NUM
    ,sty_id                         NUMBER := OKL_API.G_MISS_NUM
    ,int_disclosed_code             OKL_TAX_ATTR_DEFINITIONS.INT_DISCLOSED_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,title_trnsfr_code              OKL_TAX_ATTR_DEFINITIONS.TITLE_TRNSFR_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,sale_lease_back_code           OKL_TAX_ATTR_DEFINITIONS.SALE_LEASE_BACK_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,lease_purchased_code           OKL_TAX_ATTR_DEFINITIONS.LEASE_PURCHASED_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,equip_usage_code               OKL_TAX_ATTR_DEFINITIONS.EQUIP_USAGE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,vendor_site_id                 NUMBER := OKL_API.G_MISS_NUM
    ,age_of_equip_from              NUMBER := OKL_API.G_MISS_NUM
    ,age_of_equip_to                NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_TAX_ATTR_DEFINITIONS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_TAX_ATTR_DEFINITIONS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    -- modified by dcshanmu for eBTax project - modification start
    ,tax_attribute_def_id           NUMBER := OKL_API.G_MISS_NUM
    ,result_type_code               OKL_TAX_ATTR_DEFINITIONS.RESULT_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,book_class_code                OKL_TAX_ATTR_DEFINITIONS.BOOK_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,date_effective_from            OKL_TAX_ATTR_DEFINITIONS.DATE_EFFECTIVE_FROM%TYPE := OKL_API.G_MISS_DATE
    ,date_effective_to              OKL_TAX_ATTR_DEFINITIONS.DATE_EFFECTIVE_TO%TYPE := OKL_API.G_MISS_DATE
    ,tax_country_code               OKL_TAX_ATTR_DEFINITIONS.TAX_COUNTRY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,term_quote_type_code           OKL_TAX_ATTR_DEFINITIONS.TERM_QUOTE_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,term_quote_reason_code         OKL_TAX_ATTR_DEFINITIONS.TERM_QUOTE_REASON_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,expire_flag                    OKL_TAX_ATTR_DEFINITIONS.EXPIRE_FLAG%TYPE := OKL_API.G_MISS_CHAR);
    -- modified by dcshanmu for eBTax project - modification end
  G_MISS_tbcv_rec                         tbcv_rec_type;
  TYPE tbcv_tbl_type IS TABLE OF tbcv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TBC_DEFINITIONS_B Record Spec
  TYPE tbc_rec_type IS RECORD (

     result_code                       OKL_TAX_ATTR_DEFINITIONS.RESULT_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,purchase_option_code           OKL_TAX_ATTR_DEFINITIONS.PURCHASE_OPTION_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,pdt_id                         NUMBER := OKL_API.G_MISS_NUM
    ,try_id                         NUMBER := OKL_API.G_MISS_NUM
    ,sty_id                         NUMBER := OKL_API.G_MISS_NUM
    ,int_disclosed_code             OKL_TAX_ATTR_DEFINITIONS.INT_DISCLOSED_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,title_trnsfr_code              OKL_TAX_ATTR_DEFINITIONS.TITLE_TRNSFR_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,sale_lease_back_code           OKL_TAX_ATTR_DEFINITIONS.SALE_LEASE_BACK_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,lease_purchased_code           OKL_TAX_ATTR_DEFINITIONS.LEASE_PURCHASED_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,equip_usage_code               OKL_TAX_ATTR_DEFINITIONS.EQUIP_USAGE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,vendor_site_id                 NUMBER := OKL_API.G_MISS_NUM
    ,age_of_equip_from              NUMBER := OKL_API.G_MISS_NUM
    ,age_of_equip_to                NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_TAX_ATTR_DEFINITIONS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_TAX_ATTR_DEFINITIONS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_TAX_ATTR_DEFINITIONS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    -- modified by dcshanmu for eBTax project - modification start
    ,tax_attribute_def_id           NUMBER := OKL_API.G_MISS_NUM
    ,result_type_code               OKL_TAX_ATTR_DEFINITIONS.RESULT_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,book_class_code                OKL_TAX_ATTR_DEFINITIONS.BOOK_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,date_effective_from            OKL_TAX_ATTR_DEFINITIONS.DATE_EFFECTIVE_FROM%TYPE := OKL_API.G_MISS_DATE
    ,date_effective_to              OKL_TAX_ATTR_DEFINITIONS.DATE_EFFECTIVE_TO%TYPE := OKL_API.G_MISS_DATE
    ,tax_country_code               OKL_TAX_ATTR_DEFINITIONS.TAX_COUNTRY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,term_quote_type_code           OKL_TAX_ATTR_DEFINITIONS.TERM_QUOTE_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,term_quote_reason_code         OKL_TAX_ATTR_DEFINITIONS.TERM_QUOTE_REASON_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,expire_flag                    OKL_TAX_ATTR_DEFINITIONS.EXPIRE_FLAG%TYPE := OKL_API.G_MISS_CHAR);
    -- modified by dcshanmu for eBTax project - modification end
  G_MISS_tbc_rec                          tbc_rec_type;
  TYPE tbc_tbl_type IS TABLE OF tbc_rec_type
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

  -- SECHAWLA Added
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TBC_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type,
    x_tbcv_rec                     OUT NOCOPY tbcv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type,
    x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type,
    x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type,
    x_tbcv_rec                     OUT NOCOPY tbcv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type,
    x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type,
    x_tbcv_tbl                     OUT NOCOPY tbcv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_rec                     IN tbcv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbcv_tbl                     IN tbcv_tbl_type);
END OKL_TBC_PVT;

/
