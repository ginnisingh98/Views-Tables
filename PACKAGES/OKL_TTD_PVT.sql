--------------------------------------------------------
--  DDL for Package OKL_TTD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TTD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTTDS.pls 120.4 2007/01/15 11:15:20 dcshanmu noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TAX_TRX_DETAILS_V Record Spec
  TYPE ttdv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,txs_id                         NUMBER := OKL_API.G_MISS_NUM
    ,tax_determine_date         OKL_TAX_TRX_DETAILS.TAX_DETERMINE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,tax_rate_id                    NUMBER := OKL_API.G_MISS_NUM
    ,tax_rate_code                  OKL_TAX_TRX_DETAILS.TAX_RATE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,taxable_amt                 NUMBER := OKL_API.G_MISS_NUM
    ,tax_exemption_id               NUMBER := OKL_API.G_MISS_NUM
    ,tax_rate                       NUMBER := OKL_API.G_MISS_NUM
    ,tax_amt                     NUMBER := OKL_API.G_MISS_NUM
    ,billed_yn                      OKL_TAX_TRX_DETAILS.BILLED_YN%TYPE := OKL_API.G_MISS_CHAR
    ,tax_call_type_code             OKL_TAX_TRX_DETAILS.TAX_CALL_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_TAX_TRX_DETAILS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_TAX_TRX_DETAILS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_TAX_TRX_DETAILS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_TAX_TRX_DETAILS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_TAX_TRX_DETAILS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_TAX_TRX_DETAILS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_TAX_TRX_DETAILS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_TAX_TRX_DETAILS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_TAX_TRX_DETAILS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_TAX_TRX_DETAILS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_TAX_TRX_DETAILS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_TAX_TRX_DETAILS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_TAX_TRX_DETAILS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_TAX_TRX_DETAILS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_TAX_TRX_DETAILS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_TAX_TRX_DETAILS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_TAX_TRX_DETAILS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_TAX_TRX_DETAILS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_TAX_TRX_DETAILS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    -- Modified by dcshanmu for eBTax - modification starts
    ,tax_date			 OKL_TAX_TRX_DETAILS.TAX_DATE%TYPE := OKL_API.G_MISS_DATE
    ,line_amt			 NUMBER := OKL_API.G_MISS_NUM
    ,internal_organization_id	 NUMBER := OKL_API.G_MISS_NUM
    ,application_id			 NUMBER := OKL_API.G_MISS_NUM
    ,entity_code			 OKL_TAX_TRX_DETAILS.ENTITY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,event_class_code		 OKL_TAX_TRX_DETAILS.EVENT_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,event_type_code		 OKL_TAX_TRX_DETAILS.EVENT_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,trx_id				 NUMBER :=OKL_API.G_MISS_CHAR
    ,trx_line_id			 NUMBER := OKL_API.G_MISS_CHAR
    ,trx_level_type		 OKL_TAX_TRX_DETAILS.TRX_LEVEL_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,trx_line_number		 NUMBER := OKL_API.G_MISS_NUM
    ,tax_line_number		 NUMBER := OKL_API.G_MISS_NUM
    ,tax_regime_id		 NUMBER := OKL_API.G_MISS_NUM
    ,tax_regime_code		 OKL_TAX_TRX_DETAILS.TAX_REGIME_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_id				 NUMBER := OKL_API.G_MISS_NUM
    ,tax				 OKL_TAX_TRX_DETAILS.TAX%TYPE := OKL_API.G_MISS_CHAR
    ,tax_status_id			 NUMBER := OKL_API.G_MISS_NUM
    ,tax_status_code		 OKL_TAX_TRX_DETAILS.TAX_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_apportionment_line_number NUMBER := OKL_API.G_MISS_NUM
    ,legal_entity_id		 NUMBER := OKL_API.G_MISS_NUM
    ,trx_number			 OKL_TAX_TRX_DETAILS.TRX_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,trx_date			 OKL_TAX_TRX_DETAILS.TRX_DATE%TYPE := OKL_API.G_MISS_DATE
    ,tax_jurisdiction_id		 NUMBER := OKL_API.G_MISS_NUM
    ,tax_jurisdiction_code	 OKL_TAX_TRX_DETAILS.TAX_JURISDICTION_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_type_code		 OKL_TAX_TRX_DETAILS.TAX_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_currency_code		 OKL_TAX_TRX_DETAILS.TAX_CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,taxable_amt_tax_curr	 NUMBER := OKL_API.G_MISS_NUM
    ,trx_currency_code		 OKL_TAX_TRX_DETAILS.TRX_CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,minimum_accountable_unit NUMBER := OKL_API.G_MISS_NUM
    ,precision			 NUMBER := OKL_API.G_MISS_NUM
    ,currency_conversion_type	  OKL_TAX_TRX_DETAILS.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_rate	  NUMBER := OKL_API.G_MISS_NUM
    ,currency_conversion_date  OKL_TAX_TRX_DETAILS.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE);
    -- Modified by dcshanmu for eBTax - modification end
  GMissOklTaxTrxDetailsVRec               ttdv_rec_type;
  TYPE ttdv_tbl_type IS TABLE OF ttdv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TAX_TRX_DETAILS Record Spec
  TYPE ttd_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,txs_id                         NUMBER := OKL_API.G_MISS_NUM
    ,tax_determine_date         OKL_TAX_TRX_DETAILS.TAX_DETERMINE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,tax_rate_id                    NUMBER := OKL_API.G_MISS_NUM
    ,tax_rate_code                  OKL_TAX_TRX_DETAILS.TAX_RATE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,taxable_amt                 NUMBER := OKL_API.G_MISS_NUM
    ,tax_exemption_id               NUMBER := OKL_API.G_MISS_NUM
    ,tax_rate                       NUMBER := OKL_API.G_MISS_NUM
    ,tax_amt                     NUMBER := OKL_API.G_MISS_NUM
    ,billed_yn                      OKL_TAX_TRX_DETAILS.BILLED_YN%TYPE := OKL_API.G_MISS_CHAR
    ,tax_call_type_code             OKL_TAX_TRX_DETAILS.TAX_CALL_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_TAX_TRX_DETAILS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_TAX_TRX_DETAILS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_TAX_TRX_DETAILS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_TAX_TRX_DETAILS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_TAX_TRX_DETAILS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_TAX_TRX_DETAILS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_TAX_TRX_DETAILS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_TAX_TRX_DETAILS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_TAX_TRX_DETAILS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_TAX_TRX_DETAILS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_TAX_TRX_DETAILS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_TAX_TRX_DETAILS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_TAX_TRX_DETAILS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_TAX_TRX_DETAILS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_TAX_TRX_DETAILS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_TAX_TRX_DETAILS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_TAX_TRX_DETAILS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_TAX_TRX_DETAILS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_TAX_TRX_DETAILS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    -- Modified by dcshanmu for eBTax - modification starts
    ,tax_date			 OKL_TAX_TRX_DETAILS.TAX_DATE%TYPE := OKL_API.G_MISS_DATE
    ,line_amt			 NUMBER := OKL_API.G_MISS_NUM
    ,internal_organization_id	 NUMBER := OKL_API.G_MISS_NUM
    ,application_id			 NUMBER := OKL_API.G_MISS_NUM
    ,entity_code			 OKL_TAX_TRX_DETAILS.ENTITY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,event_class_code		 OKL_TAX_TRX_DETAILS.EVENT_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,event_type_code		 OKL_TAX_TRX_DETAILS.EVENT_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,trx_id				 NUMBER :=OKL_API.G_MISS_CHAR
    ,trx_line_id			 NUMBER := OKL_API.G_MISS_CHAR
    ,trx_level_type		 OKL_TAX_TRX_DETAILS.TRX_LEVEL_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,trx_line_number		 NUMBER := OKL_API.G_MISS_NUM
    ,tax_line_number		 NUMBER := OKL_API.G_MISS_NUM
    ,tax_regime_id		 NUMBER := OKL_API.G_MISS_NUM
    ,tax_regime_code		 OKL_TAX_TRX_DETAILS.TAX_REGIME_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_id				 NUMBER := OKL_API.G_MISS_NUM
    ,tax				 OKL_TAX_TRX_DETAILS.TAX%TYPE := OKL_API.G_MISS_CHAR
    ,tax_status_id			 NUMBER := OKL_API.G_MISS_NUM
    ,tax_status_code		 OKL_TAX_TRX_DETAILS.TAX_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_apportionment_line_number NUMBER := OKL_API.G_MISS_NUM
    ,legal_entity_id		 NUMBER := OKL_API.G_MISS_NUM
    ,trx_number			 OKL_TAX_TRX_DETAILS.TRX_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,trx_date			 OKL_TAX_TRX_DETAILS.TRX_DATE%TYPE := OKL_API.G_MISS_DATE
    ,tax_jurisdiction_id		 NUMBER := OKL_API.G_MISS_NUM
    ,tax_jurisdiction_code	 OKL_TAX_TRX_DETAILS.TAX_JURISDICTION_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_type_code		 OKL_TAX_TRX_DETAILS.TAX_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,tax_currency_code		 OKL_TAX_TRX_DETAILS.TAX_CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,taxable_amt_tax_curr	 NUMBER := OKL_API.G_MISS_NUM
    ,trx_currency_code		 OKL_TAX_TRX_DETAILS.TRX_CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,minimum_accountable_unit NUMBER := OKL_API.G_MISS_NUM
    ,precision			 NUMBER := OKL_API.G_MISS_NUM
    ,currency_conversion_type	  OKL_TAX_TRX_DETAILS.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_rate	  NUMBER := OKL_API.G_MISS_NUM
    ,currency_conversion_date  OKL_TAX_TRX_DETAILS.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE);
    -- Modified by dcshanmu for eBTax - modification end
  G_MISS_ttd_rec                          ttd_rec_type;
  TYPE ttd_tbl_type IS TABLE OF ttd_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TTD_PVT';
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
    p_ttdv_rec                     IN ttdv_rec_type,
    x_ttdv_rec                     OUT NOCOPY ttdv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl                     IN ttdv_tbl_type,
    x_ttdv_tbl                     OUT NOCOPY ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl                     IN ttdv_tbl_type,
    x_ttdv_tbl                     OUT NOCOPY ttdv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec                    IN  ttdv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    IN ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl                     IN ttdv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec    				   IN ttdv_rec_type,
    x_ttdv_rec    				   OUT NOCOPY ttdv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type,
    x_ttdv_tbl    				   OUT NOCOPY ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type,
    x_ttdv_tbl    				   OUT NOCOPY ttdv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec    				   IN ttdv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_rec    				   IN ttdv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ttdv_tbl    				   IN ttdv_tbl_type);
END OKL_TTD_PVT;

/
