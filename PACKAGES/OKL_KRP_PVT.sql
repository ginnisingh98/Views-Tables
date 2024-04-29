--------------------------------------------------------
--  DDL for Package OKL_KRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_KRP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSKRPS.pls 120.3.12010000.2 2008/11/11 23:12:03 cklee ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_K_RATE_PARAMS_V Record Spec
  TYPE krpv_rec_type IS RECORD (
     khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,parameter_type_code            OKL_K_RATE_PARAMS_V.PARAMETER_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from_date            OKL_K_RATE_PARAMS_V.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_to_date              OKL_K_RATE_PARAMS_V.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,interest_index_id              NUMBER := OKC_API.G_MISS_NUM
    ,base_rate                      NUMBER := OKC_API.G_MISS_NUM
    ,interest_start_date            OKL_K_RATE_PARAMS_V.INTEREST_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,adder_rate                     NUMBER := OKC_API.G_MISS_NUM
    ,maximum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,minimum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,principal_basis_code           OKL_K_RATE_PARAMS_V.PRINCIPAL_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_a_month_code           OKL_K_RATE_PARAMS_V.DAYS_IN_A_MONTH_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_a_year_code            OKL_K_RATE_PARAMS_V.DAYS_IN_A_YEAR_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,interest_basis_code            OKL_K_RATE_PARAMS_V.INTEREST_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_code                OKL_K_RATE_PARAMS_V.RATE_DELAY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_frequency           NUMBER := OKC_API.G_MISS_NUM
    ,compounding_frequency_code     OKL_K_RATE_PARAMS_V.COMPOUNDING_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,calculation_formula_id         NUMBER := OKC_API.G_MISS_NUM
    ,catchup_basis_code             OKL_K_RATE_PARAMS_V.CATCHUP_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,catchup_start_date             OKL_K_RATE_PARAMS_V.CATCHUP_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,catchup_settlement_code        OKL_K_RATE_PARAMS_V.CATCHUP_SETTLEMENT_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_start_date         OKL_K_RATE_PARAMS_V.RATE_CHANGE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,rate_change_frequency_code     OKL_K_RATE_PARAMS_V.RATE_CHANGE_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_value              NUMBER := OKC_API.G_MISS_NUM
    ,conversion_option_code         OKL_K_RATE_PARAMS_V.CONVERSION_OPTION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,next_conversion_date           OKL_K_RATE_PARAMS_V.NEXT_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,conversion_type_code           OKL_K_RATE_PARAMS_V.CONVERSION_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,attribute_category             OKL_K_RATE_PARAMS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_K_RATE_PARAMS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_K_RATE_PARAMS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_K_RATE_PARAMS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_K_RATE_PARAMS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_K_RATE_PARAMS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_K_RATE_PARAMS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_K_RATE_PARAMS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_K_RATE_PARAMS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_K_RATE_PARAMS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_K_RATE_PARAMS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_K_RATE_PARAMS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_K_RATE_PARAMS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_K_RATE_PARAMS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_K_RATE_PARAMS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_K_RATE_PARAMS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_K_RATE_PARAMS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_K_RATE_PARAMS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,catchup_frequency_code     OKL_K_RATE_PARAMS_V.CATCHUP_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR);
  G_MISS_krpv_rec                         krpv_rec_type;
  TYPE krpv_tbl_type IS TABLE OF krpv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_K_RATE_PARAMS Record Spec
  TYPE krp_rec_type IS RECORD (
     khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,parameter_type_code            OKL_K_RATE_PARAMS.PARAMETER_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from_date            OKL_K_RATE_PARAMS.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_to_date              OKL_K_RATE_PARAMS.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,interest_index_id              NUMBER := OKC_API.G_MISS_NUM
    ,base_rate                      NUMBER := OKC_API.G_MISS_NUM
    ,interest_start_date            OKL_K_RATE_PARAMS.INTEREST_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,adder_rate                     NUMBER := OKC_API.G_MISS_NUM
    ,maximum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,minimum_rate                   NUMBER := OKC_API.G_MISS_NUM
    ,principal_basis_code           OKL_K_RATE_PARAMS.PRINCIPAL_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_a_month_code           OKL_K_RATE_PARAMS.DAYS_IN_A_MONTH_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,days_in_a_year_code            OKL_K_RATE_PARAMS.DAYS_IN_A_YEAR_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,interest_basis_code            OKL_K_RATE_PARAMS.INTEREST_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_code                OKL_K_RATE_PARAMS.RATE_DELAY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_delay_frequency           NUMBER := OKC_API.G_MISS_NUM
    ,compounding_frequency_code     OKL_K_RATE_PARAMS.COMPOUNDING_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,calculation_formula_id         NUMBER := OKC_API.G_MISS_NUM
    ,catchup_basis_code             OKL_K_RATE_PARAMS.CATCHUP_BASIS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,catchup_start_date             OKL_K_RATE_PARAMS.CATCHUP_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,catchup_settlement_code        OKL_K_RATE_PARAMS.CATCHUP_SETTLEMENT_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_start_date         OKL_K_RATE_PARAMS.RATE_CHANGE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,rate_change_frequency_code     OKL_K_RATE_PARAMS.RATE_CHANGE_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,rate_change_value              NUMBER := OKC_API.G_MISS_NUM
    ,conversion_option_code         OKL_K_RATE_PARAMS.CONVERSION_OPTION_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,next_conversion_date           OKL_K_RATE_PARAMS.NEXT_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,conversion_type_code           OKL_K_RATE_PARAMS.CONVERSION_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,attribute_category             OKL_K_RATE_PARAMS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_K_RATE_PARAMS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_K_RATE_PARAMS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_K_RATE_PARAMS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_K_RATE_PARAMS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_K_RATE_PARAMS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_K_RATE_PARAMS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_K_RATE_PARAMS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_K_RATE_PARAMS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_K_RATE_PARAMS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_K_RATE_PARAMS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_K_RATE_PARAMS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_K_RATE_PARAMS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_K_RATE_PARAMS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_K_RATE_PARAMS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_K_RATE_PARAMS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_K_RATE_PARAMS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_K_RATE_PARAMS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,catchup_frequency_code     OKL_K_RATE_PARAMS_V.CATCHUP_FREQUENCY_CODE%TYPE := OKC_API.G_MISS_CHAR);
  G_MISS_krp_rec                          krp_rec_type;
  TYPE krp_tbl_type IS TABLE OF krp_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
--start:|  11-11-08 cklee 7557667 fixed bug: 7557667        .                        |
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
--end:|  11-11-08 cklee 7557667 fixed bug: 7557667        .                        |
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_KRP_PVT';
  -- Bug 4723341
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
    p_krpv_rec                     IN krpv_rec_type,
    x_krpv_rec                     OUT NOCOPY krpv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    x_krpv_tbl                     OUT NOCOPY krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    x_krpv_tbl                     OUT NOCOPY krpv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type,
    x_krpv_rec                     OUT NOCOPY krpv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    x_krpv_tbl                     OUT NOCOPY krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    x_krpv_tbl                     OUT NOCOPY krpv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN krpv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_deal_type                    IN  VARCHAR2,
    p_rev_rec_method               IN  VARCHAR2,
    p_int_calc_basis               IN  VARCHAR2,
    p_krpv_tbl                     IN krpv_tbl_type,
    p_stack_messages               IN VARCHAR2 DEFAULT 'N',
    p_validate_flag                IN VARCHAR2 DEFAULT 'Y');
END OKL_KRP_PVT;

/
