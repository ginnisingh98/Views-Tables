--------------------------------------------------------
--  DDL for Package OKL_CIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CIT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCITS.pls 120.0 2005/11/04 00:51:24 rkuttiya noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_CONVERT_INT_RATE_REQUEST_V Record Spec
  TYPE citv_rec_type IS RECORD (
     trq_id                         NUMBER := OKC_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,parameter_type_code            OKL_CONVERT_INT_RATE_REQUEST_V.PARAMETER_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from_date            OKL_CONVERT_INT_RATE_REQUEST_V.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_to_date              OKL_CONVERT_INT_RATE_REQUEST_V.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,minimum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,maximum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,base_rate                      NUMBER := OKC_API.G_MISS_NUM
    ,interest_index_id              NUMBER := OKC_API.G_MISS_NUM
    ,adder_rate                     NUMBER := OKC_API.G_MISS_NUM
    ,days_in_a_year_code            OKL_CONVERT_INT_RATE_REQUEST_V.DAYS_IN_A_YEAR_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_a_month_code           OKL_CONVERT_INT_RATE_REQUEST_V.DAYS_IN_A_MONTH_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,proposed_effective_date        OKL_CONVERT_INT_RATE_REQUEST_V.PROPOSED_EFFECTIVE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,conversion_date                OKL_CONVERT_INT_RATE_REQUEST_V.CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,variable_rate_yn               OKL_CONVERT_INT_RATE_REQUEST_V.VARIABLE_RATE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,principal_basis_code           OKL_CONVERT_INT_RATE_REQUEST_V.PRINCIPAL_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,interest_basis_code            OKL_CONVERT_INT_RATE_REQUEST_V.INTEREST_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_code                OKL_CONVERT_INT_RATE_REQUEST_V.RATE_DELAY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_frequency           NUMBER := OKC_API.G_MISS_NUM
    ,compound_frequency_code         OKL_CONVERT_INT_RATE_REQUEST_V.COMPOUND_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,calculation_formula_name       OKL_CONVERT_INT_RATE_REQUEST_V.CALCULATION_FORMULA_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,catchup_start_date             OKL_CONVERT_INT_RATE_REQUEST_V.CATCHUP_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,catchup_settlement_code        OKL_CONVERT_INT_RATE_REQUEST_V.CATCHUP_SETTLEMENT_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,catchup_basis_code             OKL_CONVERT_INT_RATE_REQUEST_V.CATCHUP_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_start_date         OKL_CONVERT_INT_RATE_REQUEST_V.RATE_CHANGE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,rate_change_frequency_code     OKL_CONVERT_INT_RATE_REQUEST_V.RATE_CHANGE_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_value              NUMBER := OKC_API.G_MISS_NUM
    ,conversion_option_code         OKL_CONVERT_INT_RATE_REQUEST_V.CONVERSION_OPTION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,next_conversion_date           OKL_CONVERT_INT_RATE_REQUEST_V.NEXT_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,conversion_type_code           OKL_CONVERT_INT_RATE_REQUEST_V.CONVERSION_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_CONVERT_INT_RATE_REQUEST_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_CONVERT_INT_RATE_REQUEST_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_CONVERT_INT_RATE_REQUEST_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_citv_rec                         citv_rec_type;
  TYPE citv_tbl_type IS TABLE OF citv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_CONVERT_INT_RATE_REQUEST Record Spec
  TYPE cit_rec_type IS RECORD (
     trq_id                         NUMBER := OKC_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,parameter_type_code            OKL_CONVERT_INT_RATE_REQUEST.PARAMETER_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from_date            OKL_CONVERT_INT_RATE_REQUEST.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_to_date              OKL_CONVERT_INT_RATE_REQUEST.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,minimum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,maximum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,base_rate                      NUMBER := OKC_API.G_MISS_NUM
    ,interest_index_id              NUMBER := OKC_API.G_MISS_NUM
    ,adder_rate                     NUMBER := OKC_API.G_MISS_NUM
    ,days_in_a_year_code            OKL_CONVERT_INT_RATE_REQUEST.DAYS_IN_A_YEAR_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_a_month_code           OKL_CONVERT_INT_RATE_REQUEST.DAYS_IN_A_MONTH_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,proposed_effective_date        OKL_CONVERT_INT_RATE_REQUEST.PROPOSED_EFFECTIVE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,conversion_date                OKL_CONVERT_INT_RATE_REQUEST.CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,variable_rate_yn               OKL_CONVERT_INT_RATE_REQUEST.VARIABLE_RATE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,principal_basis_code           OKL_CONVERT_INT_RATE_REQUEST.PRINCIPAL_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,interest_basis_code            OKL_CONVERT_INT_RATE_REQUEST.INTEREST_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_code                OKL_CONVERT_INT_RATE_REQUEST.RATE_DELAY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_frequency           NUMBER := OKC_API.G_MISS_NUM
    ,compound_frequency_code         OKL_CONVERT_INT_RATE_REQUEST.COMPOUND_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,calculation_formula_name       OKL_CONVERT_INT_RATE_REQUEST.CALCULATION_FORMULA_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,catchup_start_date             OKL_CONVERT_INT_RATE_REQUEST.CATCHUP_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,catchup_settlement_code        OKL_CONVERT_INT_RATE_REQUEST.CATCHUP_SETTLEMENT_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,catchup_basis_code             OKL_CONVERT_INT_RATE_REQUEST.CATCHUP_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_start_date         OKL_CONVERT_INT_RATE_REQUEST.RATE_CHANGE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,rate_change_frequency_code     OKL_CONVERT_INT_RATE_REQUEST.RATE_CHANGE_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_value              NUMBER := OKC_API.G_MISS_NUM
    ,conversion_option_code         OKL_CONVERT_INT_RATE_REQUEST.CONVERSION_OPTION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,next_conversion_date           OKL_CONVERT_INT_RATE_REQUEST.NEXT_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,conversion_type_code           OKL_CONVERT_INT_RATE_REQUEST.CONVERSION_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_CONVERT_INT_RATE_REQUEST.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_CONVERT_INT_RATE_REQUEST.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_CONVERT_INT_RATE_REQUEST.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_cit_rec                          cit_rec_type;
  TYPE cit_tbl_type IS TABLE OF cit_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CIT_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
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
    p_citv_rec                     IN citv_rec_type,
    x_citv_rec                     OUT NOCOPY citv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    x_citv_tbl                     OUT NOCOPY citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    x_citv_tbl                     OUT NOCOPY citv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type,
    x_citv_rec                     OUT NOCOPY citv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    x_citv_tbl                     OUT NOCOPY citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    x_citv_tbl                     OUT NOCOPY citv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_rec                     IN citv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_citv_tbl                     IN citv_tbl_type);
END OKL_CIT_PVT;


 

/
