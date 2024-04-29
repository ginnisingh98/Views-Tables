--------------------------------------------------------
--  DDL for Package OKL_TAA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTAAS.pls 120.1 2005/10/30 04:02:46 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TAA_REQUEST_DETAILS_V Record Spec
  TYPE taav_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,tcn_id                         NUMBER := OKC_API.G_MISS_NUM
    ,new_contract_number            OKL_TAA_REQUEST_DETAILS_V.NEW_CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,bill_to_site_id                NUMBER := OKC_API.G_MISS_NUM
    ,cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM
    ,bank_acct_id                   NUMBER := OKC_API.G_MISS_NUM
    ,invoice_format_id              NUMBER := OKC_API.G_MISS_NUM
    ,payment_mthd_id                NUMBER := OKC_API.G_MISS_NUM
    ,mla_id                         NUMBER := OKC_API.G_MISS_NUM
    ,credit_line_id                 NUMBER := OKC_API.G_MISS_NUM
    ,insurance_yn                   OKL_TAA_REQUEST_DETAILS_V.INSURANCE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,lease_policy_yn                OKL_TAA_REQUEST_DETAILS_V.LEASE_POLICY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,ipy_type                       OKL_TAA_REQUEST_DETAILS_V.IPY_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,policy_number                  OKL_TAA_REQUEST_DETAILS_V.POLICY_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,covered_amt                    NUMBER := OKC_API.G_MISS_NUM
    ,deductible_amt                 NUMBER := OKC_API.G_MISS_NUM
    ,effective_to_date              OKL_TAA_REQUEST_DETAILS_V.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_from_date            OKL_TAA_REQUEST_DETAILS_V.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,proof_provided_date            OKL_TAA_REQUEST_DETAILS_V.PROOF_PROVIDED_DATE%TYPE := OKC_API.G_MISS_DATE
    ,proof_required_date            OKL_TAA_REQUEST_DETAILS_V.PROOF_REQUIRED_DATE%TYPE := OKC_API.G_MISS_DATE
    ,lessor_insured_yn              OKL_TAA_REQUEST_DETAILS_V.LESSOR_INSURED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,lessor_payee_yn                OKL_TAA_REQUEST_DETAILS_V.LESSOR_PAYEE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,int_id                         NUMBER := OKC_API.G_MISS_NUM
    ,isu_id                         NUMBER := OKC_API.G_MISS_NUM
    ,agency_site_id                 NUMBER := OKC_API.G_MISS_NUM
    ,agent_site_id                  NUMBER := OKC_API.G_MISS_NUM
    ,territory_code                 OKL_TAA_REQUEST_DETAILS_V.TERRITORY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,attribute_category             OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_TAA_REQUEST_DETAILS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_TAA_REQUEST_DETAILS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_TAA_REQUEST_DETAILS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_taav_rec                         taav_rec_type;
  TYPE taav_tbl_type IS TABLE OF taav_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TAA_REQUEST_DETAILS_B Record Spec
  TYPE taa_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,tcn_id                         NUMBER := OKC_API.G_MISS_NUM
    ,new_contract_number            OKL_TAA_REQUEST_DETAILS_B.NEW_CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,bill_to_site_id                NUMBER := OKC_API.G_MISS_NUM
    ,cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM
    ,bank_acct_id                   NUMBER := OKC_API.G_MISS_NUM
    ,invoice_format_id              NUMBER := OKC_API.G_MISS_NUM
    ,payment_mthd_id                NUMBER := OKC_API.G_MISS_NUM
    ,mla_id                         NUMBER := OKC_API.G_MISS_NUM
    ,credit_line_id                 NUMBER := OKC_API.G_MISS_NUM
    ,insurance_yn                   OKL_TAA_REQUEST_DETAILS_B.INSURANCE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,lease_policy_yn                OKL_TAA_REQUEST_DETAILS_B.LEASE_POLICY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,ipy_type                       OKL_TAA_REQUEST_DETAILS_B.IPY_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,policy_number                  OKL_TAA_REQUEST_DETAILS_B.POLICY_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,covered_amt                    NUMBER := OKC_API.G_MISS_NUM
    ,deductible_amt                 NUMBER := OKC_API.G_MISS_NUM
    ,effective_to_date              OKL_TAA_REQUEST_DETAILS_B.EFFECTIVE_TO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_from_date            OKL_TAA_REQUEST_DETAILS_B.EFFECTIVE_FROM_DATE%TYPE := OKC_API.G_MISS_DATE
    ,proof_provided_date            OKL_TAA_REQUEST_DETAILS_B.PROOF_PROVIDED_DATE%TYPE := OKC_API.G_MISS_DATE
    ,proof_required_date            OKL_TAA_REQUEST_DETAILS_B.PROOF_REQUIRED_DATE%TYPE := OKC_API.G_MISS_DATE
    ,lessor_insured_yn              OKL_TAA_REQUEST_DETAILS_B.LESSOR_INSURED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,lessor_payee_yn                OKL_TAA_REQUEST_DETAILS_B.LESSOR_PAYEE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,int_id                         NUMBER := OKC_API.G_MISS_NUM
    ,isu_id                         NUMBER := OKC_API.G_MISS_NUM
    ,agency_site_id                 NUMBER := OKC_API.G_MISS_NUM
    ,agent_site_id                  NUMBER := OKC_API.G_MISS_NUM
    ,territory_code                 OKL_TAA_REQUEST_DETAILS_B.TERRITORY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,attribute_category             OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_TAA_REQUEST_DETAILS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_TAA_REQUEST_DETAILS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_TAA_REQUEST_DETAILS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_taa_rec                          taa_rec_type;
  TYPE taa_tbl_type IS TABLE OF taa_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TAA_PVT';
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
    p_taav_rec                     IN taav_rec_type,
    x_taav_rec                     OUT NOCOPY taav_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    x_taav_tbl                     OUT NOCOPY taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    x_taav_tbl                     OUT NOCOPY taav_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type,
    x_taav_rec                     OUT NOCOPY taav_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    x_taav_tbl                     OUT NOCOPY taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    x_taav_tbl                     OUT NOCOPY taav_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_rec                     IN taav_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taav_tbl                     IN taav_tbl_type);
END OKL_TAA_PVT;

 

/
