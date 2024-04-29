--------------------------------------------------------
--  DDL for Package OKL_TXS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TXS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTXSS.pls 120.5 2007/07/12 22:15:49 rravikir noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TAX_SOURCES_V Record Spec
  TYPE txsv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKL_API.G_MISS_NUM
    ,asset_number                   OKL_TAX_SOURCES.LINE_NAME%TYPE := OKL_API.G_MISS_CHAR
    ,trx_id                         NUMBER := OKL_API.G_MISS_NUM
    ,trx_line_id                    NUMBER := OKL_API.G_MISS_NUM
    ,entity_code                    OKL_TAX_SOURCES.ENTITY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,event_class_code               OKL_TAX_SOURCES.EVENT_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,trx_level_type                 OKL_TAX_SOURCES.TRX_LEVEL_TYPE%TYPE := OKL_API.G_MISS_CHAR
    --,trx_line_type                  OKL_TAX_SOURCES.TRX_LINE_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_entity_code       OKL_TAX_SOURCES.ADJUSTED_DOC_ENTITY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_event_class_code  OKL_TAX_SOURCES.ADJUSTED_DOC_EVENT_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_trx_id            NUMBER := OKL_API.G_MISS_NUM
    ,adjusted_doc_trx_line_id       NUMBER := OKL_API.G_MISS_NUM
    ,adjusted_doc_trx_level_type    OKL_TAX_SOURCES.ADJUSTED_DOC_TRX_LEVEL_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_number            OKL_TAX_SOURCES.ADJUSTED_DOC_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_date              OKL_TAX_SOURCES.ADJUSTED_DOC_DATE%TYPE := OKL_API.G_MISS_DATE
    ,tax_call_type_code             OKL_TAX_SOURCES.TAX_CALL_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,sty_id                         NUMBER := OKL_API.G_MISS_NUM
    ,trx_business_category          OKL_TAX_SOURCES.TRX_BUSINESS_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,tax_line_status_code           OKL_TAX_SOURCES.TAX_LINE_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,sel_id                         NUMBER := OKL_API.G_MISS_NUM
    ,reported_yn                    OKL_TAX_SOURCES.TAX_REPORTING_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_TAX_SOURCES.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_TAX_SOURCES.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_TAX_SOURCES.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_TAX_SOURCES.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_TAX_SOURCES.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_TAX_SOURCES.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_TAX_SOURCES.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_TAX_SOURCES.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_TAX_SOURCES.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_TAX_SOURCES.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_TAX_SOURCES.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_TAX_SOURCES.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_TAX_SOURCES.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_TAX_SOURCES.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_TAX_SOURCES.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_TAX_SOURCES.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_TAX_SOURCES.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_TAX_SOURCES.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_TAX_SOURCES.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    -- modified by eBTax by dcshanmu - modification starts
    ,application_id			NUMBER := OKL_API.G_MISS_NUM
    ,default_taxation_country OKL_TAX_SOURCES.DEFAULT_TAXATION_COUNTRY%TYPE := OKL_API.G_MISS_CHAR
    ,product_category		OKL_TAX_SOURCES.PRODUCT_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,user_defined_fisc_class	OKL_TAX_SOURCES.USER_DEFINED_FISC_CLASS%TYPE := OKL_API.G_MISS_CHAR
    ,line_intended_use		OKL_TAX_SOURCES.LINE_INTENDED_USE%TYPE := OKL_API.G_MISS_CHAR
    ,inventory_item_id		NUMBER := OKL_API.G_MISS_NUM
    ,bill_to_cust_acct_id		NUMBER := OKL_API.G_MISS_NUM
    ,org_id				NUMBER := OKL_API.G_MISS_NUM
    ,legaL_entity_id		NUMBER := OKL_API.G_MISS_NUM
    ,line_amt			NUMBER := OKL_API.G_MISS_NUM
    ,assessable_value		NUMBER := OKL_API.G_MISS_NUM
    ,total_tax			NUMBER := OKL_API.G_MISS_NUM
    ,product_type			OKL_TAX_SOURCES.PRODUCT_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,product_fisc_classification OKL_TAX_SOURCES.PRODUCT_FISC_CLASSIFICATION%TYPE := OKL_API.G_MISS_CHAR
    ,trx_date			OKL_TAX_SOURCES.TRX_DATE%TYPE := OKL_API.G_MISS_DATE
    ,provnl_tax_determination_date	 OKL_TAX_SOURCES.PROVNL_TAX_DETERMINATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,try_id				NUMBER := OKL_API.G_MISS_NUM
    ,ship_to_location_id		NUMBER := OKL_API.G_MISS_NUM
    ,trx_currency_code		OKL_TAX_SOURCES.TRX_CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_type	 OKL_TAX_SOURCES.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_rate	 NUMBER := OKL_API.G_MISS_NUM
    ,currency_conversion_date	 OKL_TAX_SOURCES.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE
    -- modified by eBTax by dcshanmu - modification end
    --modified by asawanka for eBTax start
    ,SHIP_TO_PARTY_SITE_ID	NUMBER := OKL_API.G_MISS_NUM
    ,SHIP_TO_PARTY_ID	NUMBER := OKL_API.G_MISS_NUM
    ,BILL_TO_PARTY_SITE_ID	NUMBER := OKL_API.G_MISS_NUM
    ,BILL_TO_LOCATION_ID	NUMBER := OKL_API.G_MISS_NUM
    ,BILL_TO_PARTY_ID	NUMBER := OKL_API.G_MISS_NUM
    ,ship_to_cust_acct_site_use_id 	NUMBER := OKL_API.G_MISS_NUM
    ,bill_to_cust_acct_site_use_id 	NUMBER := OKL_API.G_MISS_NUM
    ,TAX_CLASSIFICATION_CODE	OKL_TAX_SOURCES.TAX_CLASSIFICATION_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_reporting_flag     OKL_TAX_SOURCES.tax_reporting_flag%TYPE := OKL_API.G_MISS_CHAR
    ,line_name     OKL_TAX_SOURCES.line_name%TYPE := OKL_API.G_MISS_CHAR
    --modified by asawanka for eBTax end
    ,alc_serialized_yn              OKL_TAX_SOURCES.ALC_SERIALIZED_YN%TYPE := OKL_API.G_MISS_CHAR
    ,alc_serialized_total_tax       NUMBER := OKL_API.G_MISS_NUM
    ,alc_serialized_total_line_amt  NUMBER := OKL_API.G_MISS_NUM);

  G_MISS_txsv_rec                         txsv_rec_type;
  TYPE txsv_tbl_type IS TABLE OF txsv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TAX_SOURCES Record Spec
  TYPE txs_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKL_API.G_MISS_NUM
    ,asset_number                   OKL_TAX_SOURCES.LINE_NAME%TYPE := OKL_API.G_MISS_CHAR
    ,trx_id                         NUMBER := OKL_API.G_MISS_NUM
    ,trx_line_id                    NUMBER := OKL_API.G_MISS_NUM
    ,entity_code                    OKL_TAX_SOURCES.ENTITY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,event_class_code               OKL_TAX_SOURCES.EVENT_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,trx_level_type                 OKL_TAX_SOURCES.TRX_LEVEL_TYPE%TYPE := OKL_API.G_MISS_CHAR
    --,trx_line_type                  OKL_TAX_SOURCES.TRX_LINE_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_entity_code       OKL_TAX_SOURCES.ADJUSTED_DOC_ENTITY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_event_class_code  OKL_TAX_SOURCES.ADJUSTED_DOC_EVENT_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_trx_id            NUMBER := OKL_API.G_MISS_NUM
    ,adjusted_doc_trx_line_id       NUMBER := OKL_API.G_MISS_NUM
    ,adjusted_doc_trx_level_type    OKL_TAX_SOURCES.ADJUSTED_DOC_TRX_LEVEL_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_number            OKL_TAX_SOURCES.ADJUSTED_DOC_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,adjusted_doc_date              OKL_TAX_SOURCES.ADJUSTED_DOC_DATE%TYPE := OKL_API.G_MISS_DATE
    ,tax_call_type_code             OKL_TAX_SOURCES.TAX_CALL_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,sty_id                         NUMBER := OKL_API.G_MISS_NUM
    ,trx_business_category          OKL_TAX_SOURCES.TRX_BUSINESS_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,tax_line_status_code           OKL_TAX_SOURCES.TAX_LINE_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,sel_id                         NUMBER := OKL_API.G_MISS_NUM
    ,reported_yn                    OKL_TAX_SOURCES.TAX_REPORTING_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_TAX_SOURCES.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_TAX_SOURCES.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_TAX_SOURCES.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_TAX_SOURCES.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_TAX_SOURCES.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_TAX_SOURCES.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_TAX_SOURCES.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_TAX_SOURCES.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_TAX_SOURCES.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_TAX_SOURCES.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_TAX_SOURCES.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_TAX_SOURCES.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_TAX_SOURCES.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_TAX_SOURCES.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_TAX_SOURCES.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_TAX_SOURCES.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_TAX_SOURCES.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_TAX_SOURCES.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_TAX_SOURCES.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    -- modified by eBTax by dcshanmu - modification starts
    ,application_id			NUMBER := OKL_API.G_MISS_NUM
    ,default_taxation_country OKL_TAX_SOURCES.DEFAULT_TAXATION_COUNTRY%TYPE := OKL_API.G_MISS_CHAR
    ,product_category		OKL_TAX_SOURCES.PRODUCT_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,user_defined_fisc_class	OKL_TAX_SOURCES.USER_DEFINED_FISC_CLASS%TYPE := OKL_API.G_MISS_CHAR
    ,line_intended_use		OKL_TAX_SOURCES.LINE_INTENDED_USE%TYPE := OKL_API.G_MISS_CHAR
    ,inventory_item_id		NUMBER := OKL_API.G_MISS_NUM
    ,bill_to_cust_acct_id		NUMBER := OKL_API.G_MISS_NUM
    ,org_id				NUMBER := OKL_API.G_MISS_NUM
    ,legaL_entity_id		NUMBER := OKL_API.G_MISS_NUM
    ,line_amt			NUMBER := OKL_API.G_MISS_NUM
    ,assessable_value		NUMBER := OKL_API.G_MISS_NUM
    ,total_tax			NUMBER := OKL_API.G_MISS_NUM
    ,product_type			OKL_TAX_SOURCES.PRODUCT_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,product_fisc_classification OKL_TAX_SOURCES.PRODUCT_FISC_CLASSIFICATION%TYPE := OKL_API.G_MISS_CHAR
    ,trx_date			OKL_TAX_SOURCES.TRX_DATE%TYPE := OKL_API.G_MISS_DATE
    ,provnl_tax_determination_date	 OKL_TAX_SOURCES.PROVNL_TAX_DETERMINATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,try_id				NUMBER := OKL_API.G_MISS_NUM
    ,ship_to_location_id		NUMBER := OKL_API.G_MISS_NUM
    ,trx_currency_code		OKL_TAX_SOURCES.TRX_CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_type	 OKL_TAX_SOURCES.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_rate	 NUMBER := OKL_API.G_MISS_NUM
    ,currency_conversion_date	 OKL_TAX_SOURCES.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE
    -- modified by eBTax by dcshanmu - modification end
    --modified by asawanka for eBTax start
    ,SHIP_TO_PARTY_SITE_ID	NUMBER := OKL_API.G_MISS_NUM
    ,SHIP_TO_PARTY_ID	NUMBER := OKL_API.G_MISS_NUM
    ,BILL_TO_PARTY_SITE_ID	NUMBER := OKL_API.G_MISS_NUM
    ,BILL_TO_LOCATION_ID	NUMBER := OKL_API.G_MISS_NUM
    ,BILL_TO_PARTY_ID	NUMBER := OKL_API.G_MISS_NUM
    ,ship_to_cust_acct_site_use_id 	NUMBER := OKL_API.G_MISS_NUM
    ,bill_to_cust_acct_site_use_id 	NUMBER := OKL_API.G_MISS_NUM
    ,TAX_CLASSIFICATION_CODE	OKL_TAX_SOURCES.TAX_CLASSIFICATION_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_reporting_flag     OKL_TAX_SOURCES.tax_reporting_flag%TYPE := OKL_API.G_MISS_CHAR
    ,line_name     OKL_TAX_SOURCES.line_name%TYPE := OKL_API.G_MISS_CHAR
    --modified by asawanka for eBTax end
    ,alc_serialized_yn              OKL_TAX_SOURCES.ALC_SERIALIZED_YN%TYPE := OKL_API.G_MISS_CHAR
    ,alc_serialized_total_tax       NUMBER := OKL_API.G_MISS_NUM
    ,alc_serialized_total_line_amt  NUMBER := OKL_API.G_MISS_NUM);

  G_MISS_txs_rec                          txs_rec_type;
  TYPE txs_tbl_type IS TABLE OF txs_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TXS_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;

    -- SECHAWLA Added
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
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
    p_txsv_rec                     IN txsv_rec_type,
    x_txsv_rec                     OUT NOCOPY txsv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type,
    x_txsv_tbl                     OUT NOCOPY txsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type,
    x_txsv_tbl                     OUT NOCOPY txsv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type,
    x_txsv_rec                     OUT NOCOPY txsv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type,
    x_txsv_tbl                     OUT NOCOPY txsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type,
    x_txsv_tbl                     OUT NOCOPY txsv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_rec                     IN txsv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txsv_tbl                     IN txsv_tbl_type);
END OKL_TXS_PVT;

/
