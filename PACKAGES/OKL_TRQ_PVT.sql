--------------------------------------------------------
--  DDL for Package OKL_TRQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRQ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTRQS.pls 120.5 2006/11/16 07:10:08 dkagrawa noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TRX_REQUESTS_V Record Spec
  TYPE trqv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object1_id1                    OKL_TRX_REQUESTS.OBJECT1_ID1%TYPE := OKL_API.G_MISS_CHAR
    ,object1_id2                    OKL_TRX_REQUESTS.OBJECT1_ID2%TYPE := OKL_API.G_MISS_CHAR
    ,jtot_object1_code              OKL_TRX_REQUESTS.JTOT_OBJECT1_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,dnz_khr_id                     NUMBER := OKL_API.G_MISS_NUM
    ,request_type_code              OKL_TRX_REQUESTS.REQUEST_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,apply_to_code                  OKL_TRX_REQUESTS.APPLY_TO_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,start_date                     OKL_TRX_REQUESTS.START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,end_date                       OKL_TRX_REQUESTS.END_DATE%TYPE := OKL_API.G_MISS_DATE
    ,term_duration                  NUMBER := OKL_API.G_MISS_NUM
    ,AMOUNT                    	    NUMBER := OKL_API.G_MISS_NUM
    ,currency_code                  OKL_TRX_REQUESTS.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,subsidy_yn                     OKL_TRX_REQUESTS.SUBSIDY_YN%TYPE := OKL_API.G_MISS_CHAR
    ,cash_applied_yn                OKL_TRX_REQUESTS.CASH_APPLIED_YN%TYPE := OKL_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_TRX_REQUESTS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_TRX_REQUESTS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_TRX_REQUESTS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_TRX_REQUESTS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_TRX_REQUESTS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_TRX_REQUESTS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_TRX_REQUESTS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_TRX_REQUESTS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_TRX_REQUESTS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_TRX_REQUESTS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_TRX_REQUESTS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_TRX_REQUESTS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_TRX_REQUESTS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_TRX_REQUESTS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_TRX_REQUESTS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_TRX_REQUESTS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_TRX_REQUESTS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_TRX_REQUESTS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_TRX_REQUESTS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,minimum_rate                   NUMBER := OKL_API.G_MISS_NUM
    ,maximum_rate                   NUMBER := OKL_API.G_MISS_NUM
    ,tolerance                      NUMBER := OKL_API.G_MISS_NUM
    ,adjustment_frequency_code      OKL_TRX_REQUESTS.ADJUSTMENT_FREQUENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,base_rate                      NUMBER := OKL_API.G_MISS_NUM
    ,index_name                     OKL_TRX_REQUESTS.INDEX_NAME%TYPE := OKL_API.G_MISS_CHAR
    ,variable_method_code           OKL_TRX_REQUESTS.VARIABLE_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,adder                          NUMBER := OKL_API.G_MISS_NUM
    ,days_in_year                   OKL_TRX_REQUESTS.DAYS_IN_YEAR%TYPE := OKL_API.G_MISS_CHAR
    ,days_in_month                  OKL_TRX_REQUESTS.DAYS_IN_MONTH%TYPE := OKL_API.G_MISS_CHAR
    ,interest_method_code           OKL_TRX_REQUESTS.INTEREST_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,interest_start_date            OKL_TRX_REQUESTS.INTEREST_START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,method_of_calculation_code     OKL_TRX_REQUESTS.METHOD_OF_CALCULATION_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,request_number                 OKL_TRX_REQUESTS.REQUEST_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,date_of_conversion             OKL_TRX_REQUESTS.DATE_OF_CONVERSION%TYPE := OKL_API.G_MISS_DATE
    ,variable_rate_yn               OKL_TRX_REQUESTS.VARIABLE_RATE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,request_status_code            OKL_TRX_REQUESTS.REQUEST_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,yield                          NUMBER := OKL_API.G_MISS_NUM
    ,residual                       NUMBER := OKL_API.G_MISS_NUM
    ,comments                       OKL_TRX_REQUESTS.COMMENTS%TYPE := OKL_API.G_MISS_CHAR
    ,payment_frequency_code         OKL_TRX_REQUESTS.PAYMENT_FREQUENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,restructure_date               OKL_TRX_REQUESTS.RESTRUCTURE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,past_due_yn                    OKL_TRX_REQUESTS.PAST_DUE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,request_reason_code            OKL_TRX_REQUESTS.REQUEST_REASON_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,parent_khr_id                  NUMBER := OKL_API.G_MISS_NUM
    ,yield_type            	    OKL_TRX_REQUESTS.YIELD_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,payment_amount            	    NUMBER := OKL_API.G_MISS_NUM
    ,payment_date            	    OKL_TRX_REQUESTS.PAYMENT_DATE%TYPE := OKL_API.G_MISS_DATE
    ,paydown_type            	    OKL_TRX_REQUESTS.PAYDOWN_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_type  	    OKL_TRX_REQUESTS.currency_conversion_type%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_rate 	    NUMBER := OKL_API.G_MISS_NUM
    ,currency_conversion_date       OKL_TRX_REQUESTS.currency_conversion_date%TYPE := OKL_API.G_MISS_DATE
    ,lsm_id		 	    NUMBER := OKL_API.G_MISS_NUM
    ,receipt_id 	    	    NUMBER := OKL_API.G_MISS_NUM
    ,tcn_id 	            	    NUMBER := OKL_API.G_MISS_NUM
    ,try_id                         NUMBER := OKL_API.G_MISS_NUM
    ,cur_principal_balance          NUMBER := OKL_API.G_MISS_NUM
    ,cur_accum_interest             NUMBER := OKL_API.G_MISS_NUM
    ,legal_entity_id                OKL_TRX_REQUESTS.LEGAL_ENTITY_ID%TYPE := OKL_API.G_MISS_NUM);

  G_MISS_trqv_rec                         trqv_rec_type;

  TYPE trqv_tbl_type IS TABLE OF trqv_rec_type
        INDEX BY BINARY_INTEGER;

  -- OKL_TRX_REQUESTS Record Spec
  TYPE trq_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object1_id1                    OKL_TRX_REQUESTS.OBJECT1_ID1%TYPE := OKL_API.G_MISS_CHAR
    ,object1_id2                    OKL_TRX_REQUESTS.OBJECT1_ID2%TYPE := OKL_API.G_MISS_CHAR
    ,jtot_object1_code              OKL_TRX_REQUESTS.JTOT_OBJECT1_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,dnz_khr_id                     NUMBER := OKL_API.G_MISS_NUM
    ,request_type_code              OKL_TRX_REQUESTS.REQUEST_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,apply_to_code                  OKL_TRX_REQUESTS.APPLY_TO_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,start_date                     OKL_TRX_REQUESTS.START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,end_date                       OKL_TRX_REQUESTS.END_DATE%TYPE := OKL_API.G_MISS_DATE
    ,term_duration                  NUMBER := OKL_API.G_MISS_NUM
    ,AMOUNT                    NUMBER := OKL_API.G_MISS_NUM
    ,currency_code                  OKL_TRX_REQUESTS.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,subsidy_yn                     OKL_TRX_REQUESTS.SUBSIDY_YN%TYPE := OKL_API.G_MISS_CHAR
    ,cash_applied_yn                OKL_TRX_REQUESTS.CASH_APPLIED_YN%TYPE := OKL_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_TRX_REQUESTS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_TRX_REQUESTS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_TRX_REQUESTS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_TRX_REQUESTS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_TRX_REQUESTS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_TRX_REQUESTS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_TRX_REQUESTS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_TRX_REQUESTS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_TRX_REQUESTS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_TRX_REQUESTS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_TRX_REQUESTS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_TRX_REQUESTS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_TRX_REQUESTS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_TRX_REQUESTS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_TRX_REQUESTS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_TRX_REQUESTS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_TRX_REQUESTS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_TRX_REQUESTS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_TRX_REQUESTS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,minimum_rate                   NUMBER := OKL_API.G_MISS_NUM
    ,maximum_rate                   NUMBER := OKL_API.G_MISS_NUM
    ,tolerance                      NUMBER := OKL_API.G_MISS_NUM
    ,adjustment_frequency_code      OKL_TRX_REQUESTS.ADJUSTMENT_FREQUENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,base_rate                      NUMBER := OKL_API.G_MISS_NUM
    ,index_name                     OKL_TRX_REQUESTS.INDEX_NAME%TYPE := OKL_API.G_MISS_CHAR
    ,variable_method_code           OKL_TRX_REQUESTS.VARIABLE_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,adder                          NUMBER := OKL_API.G_MISS_NUM
    ,days_in_year                   OKL_TRX_REQUESTS.DAYS_IN_YEAR%TYPE := OKL_API.G_MISS_CHAR
    ,days_in_month                  OKL_TRX_REQUESTS.DAYS_IN_MONTH%TYPE := OKL_API.G_MISS_CHAR
    ,interest_method_code           OKL_TRX_REQUESTS.INTEREST_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,interest_start_date            OKL_TRX_REQUESTS.INTEREST_START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,method_of_calculation_code     OKL_TRX_REQUESTS.METHOD_OF_CALCULATION_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,request_number                 OKL_TRX_REQUESTS.REQUEST_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,date_of_conversion             OKL_TRX_REQUESTS.DATE_OF_CONVERSION%TYPE := OKL_API.G_MISS_DATE
    ,variable_rate_yn               OKL_TRX_REQUESTS.VARIABLE_RATE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,request_status_code            OKL_TRX_REQUESTS.REQUEST_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,yield                          NUMBER := OKL_API.G_MISS_NUM
    ,residual                       NUMBER := OKL_API.G_MISS_NUM
    ,comments                       OKL_TRX_REQUESTS.COMMENTS%TYPE := OKL_API.G_MISS_CHAR
    ,payment_frequency_code         OKL_TRX_REQUESTS.PAYMENT_FREQUENCY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,restructure_date               OKL_TRX_REQUESTS.RESTRUCTURE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,past_due_yn                    OKL_TRX_REQUESTS.PAST_DUE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,request_reason_code            OKL_TRX_REQUESTS.REQUEST_REASON_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,parent_khr_id                  NUMBER := OKL_API.G_MISS_NUM
    ,yield_type            	    OKL_TRX_REQUESTS.YIELD_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,payment_amount            	    NUMBER := OKL_API.G_MISS_NUM
    ,payment_date            	    OKL_TRX_REQUESTS.PAYMENT_DATE%TYPE := OKL_API.G_MISS_DATE
    ,paydown_type            	    OKL_TRX_REQUESTS.PAYDOWN_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_type       OKL_TRX_REQUESTS.currency_conversion_type%TYPE := OKL_API.G_MISS_CHAR
    ,currency_conversion_rate       NUMBER := OKL_API.G_MISS_NUM
    ,currency_conversion_date       OKL_TRX_REQUESTS.currency_conversion_date%TYPE := OKL_API.G_MISS_DATE
    ,lsm_id		 	    NUMBER := OKL_API.G_MISS_NUM
    ,receipt_id 	    	    NUMBER := OKL_API.G_MISS_NUM
    ,tcn_id 	            	    NUMBER := OKL_API.G_MISS_NUM
    ,try_id                         NUMBER := OKL_API.G_MISS_NUM
    ,cur_principal_balance          NUMBER := OKL_API.G_MISS_NUM
    ,cur_accum_interest             NUMBER := OKL_API.G_MISS_NUM
    ,legal_entity_id                OKL_TRX_REQUESTS.LEGAL_ENTITY_ID%TYPE := OKL_API.G_MISS_NUM);

  G_MISS_trq_rec                          trq_rec_type;
  TYPE trq_tbl_type IS TABLE OF trq_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TRQ_PVT';
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
    p_trqv_rec                     IN trqv_rec_type,
    x_trqv_rec                     OUT NOCOPY trqv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    x_trqv_tbl                     OUT NOCOPY trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    x_trqv_tbl                     OUT NOCOPY trqv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type,
    x_trqv_rec                     OUT NOCOPY trqv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    x_trqv_tbl                     OUT NOCOPY trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    x_trqv_tbl                     OUT NOCOPY trqv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_rec                     IN trqv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_trqv_tbl                     IN trqv_tbl_type);
END OKL_TRQ_PVT;

/
