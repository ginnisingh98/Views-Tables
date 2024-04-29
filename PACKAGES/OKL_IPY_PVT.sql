--------------------------------------------------------
--  DDL for Package OKL_IPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_IPY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSIPYS.pls 120.2 2006/11/22 18:22:03 asahoo noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_INS_POLICIES_V Record Spec
  TYPE ipyv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,ipy_type                       OKL_INS_POLICIES_V.IPY_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKL_INS_POLICIES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,endorsement                    OKL_INS_POLICIES_V.ENDORSEMENT%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_INS_POLICIES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,cancellation_comment           OKL_INS_POLICIES_V.CANCELLATION_COMMENT%TYPE := OKC_API.G_MISS_CHAR
    ,comments                       OKL_INS_POLICIES_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR
    ,name_of_insured                OKL_INS_POLICIES_V.NAME_OF_INSURED%TYPE := OKC_API.G_MISS_CHAR
    ,policy_number                  OKL_INS_POLICIES_V.POLICY_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,calculated_premium             NUMBER := OKC_API.G_MISS_NUM
    ,premium                        NUMBER := OKC_API.G_MISS_NUM
    ,covered_amount                 NUMBER := OKC_API.G_MISS_NUM
    ,deductible                     NUMBER := OKC_API.G_MISS_NUM
    ,adjustment                     NUMBER := OKC_API.G_MISS_NUM
    ,payment_frequency              OKL_INS_POLICIES_V.PAYMENT_FREQUENCY%TYPE := OKC_API.G_MISS_CHAR
    ,crx_code                       OKL_INS_POLICIES_V.CRX_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,ipf_code                       OKL_INS_POLICIES_V.IPF_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,iss_code                       OKL_INS_POLICIES_V.ISS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,ipe_code                       OKL_INS_POLICIES_V.IPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,date_to                        OKL_INS_POLICIES_V.DATE_TO%TYPE := OKC_API.G_MISS_DATE
    ,date_from                      OKL_INS_POLICIES_V.DATE_FROM%TYPE := OKC_API.G_MISS_DATE
    ,date_quoted                    OKL_INS_POLICIES_V.DATE_QUOTED%TYPE := OKC_API.G_MISS_DATE
    ,date_proof_provided            OKL_INS_POLICIES_V.DATE_PROOF_PROVIDED%TYPE := OKC_API.G_MISS_DATE
    ,date_proof_required            OKL_INS_POLICIES_V.DATE_PROOF_REQUIRED%TYPE := OKC_API.G_MISS_DATE
    ,cancellation_date              OKL_INS_POLICIES_V.CANCELLATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,date_quote_expiry              OKL_INS_POLICIES_V.DATE_QUOTE_EXPIRY%TYPE := OKC_API.G_MISS_DATE
    ,activation_date                OKL_INS_POLICIES_V.ACTIVATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,quote_yn                       OKL_INS_POLICIES_V.QUOTE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,on_file_yn                     OKL_INS_POLICIES_V.ON_FILE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,private_label_yn               OKL_INS_POLICIES_V.PRIVATE_LABEL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,agent_yn                       OKL_INS_POLICIES_V.AGENT_YN%TYPE := OKC_API.G_MISS_CHAR
    ,lessor_insured_yn              OKL_INS_POLICIES_V.LESSOR_INSURED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,lessor_payee_yn                OKL_INS_POLICIES_V.LESSOR_PAYEE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,ipt_id                         NUMBER := OKC_API.G_MISS_NUM
    ,ipy_id                         NUMBER := OKC_API.G_MISS_NUM
    ,int_id                         NUMBER := OKC_API.G_MISS_NUM
    ,isu_id                         NUMBER := OKC_API.G_MISS_NUM
    ,insurance_factor               OKL_INS_POLICIES_V.INSURANCE_FACTOR%TYPE := OKC_API.G_MISS_CHAR
    ,factor_code                    OKL_INS_POLICIES_V.FACTOR_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,factor_value                   NUMBER := OKC_API.G_MISS_NUM
    ,agency_number                  OKL_INS_POLICIES_V.AGENCY_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,agency_site_id                 NUMBER := OKC_API.G_MISS_NUM
    ,sales_rep_id                   NUMBER := OKC_API.G_MISS_NUM
    ,agent_site_id                  NUMBER := OKC_API.G_MISS_NUM
    ,adjusted_by_id                 NUMBER := OKC_API.G_MISS_NUM
    ,territory_code                 OKL_INS_POLICIES_V.TERRITORY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,attribute_category             OKL_INS_POLICIES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_INS_POLICIES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_INS_POLICIES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_INS_POLICIES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_INS_POLICIES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_INS_POLICIES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_INS_POLICIES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_INS_POLICIES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_INS_POLICIES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_INS_POLICIES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_INS_POLICIES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_INS_POLICIES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_INS_POLICIES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_INS_POLICIES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_INS_POLICIES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_INS_POLICIES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_INS_POLICIES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_INS_POLICIES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_INS_POLICIES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
    ,lease_application_id           NUMBER := OKC_API.G_MISS_NUM
-- Legal Entity Uptake
    ,legal_entity_id                OKL_INS_POLICIES_V.LEGAL_ENTITY_ID%TYPE := OKC_API.G_MISS_NUM);
  G_MISS_ipyv_rec                         ipyv_rec_type;
  TYPE ipyv_tbl_type IS TABLE OF ipyv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_INS_POLICIES_B Record Spec
  TYPE ipy_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,ipy_type                       OKL_INS_POLICIES_B.IPY_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,name_of_insured                OKL_INS_POLICIES_B.NAME_OF_INSURED%TYPE := OKC_API.G_MISS_CHAR
    ,policy_number                  OKL_INS_POLICIES_B.POLICY_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,insurance_factor               OKL_INS_POLICIES_B.INSURANCE_FACTOR%TYPE := OKC_API.G_MISS_CHAR
    ,factor_code                     OKL_INS_POLICIES_B.FACTOR_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,calculated_premium             NUMBER := OKC_API.G_MISS_NUM
    ,premium                        NUMBER := OKC_API.G_MISS_NUM
    ,covered_amount                 NUMBER := OKC_API.G_MISS_NUM
    ,deductible                     NUMBER := OKC_API.G_MISS_NUM
    ,adjustment                     NUMBER := OKC_API.G_MISS_NUM
    ,payment_frequency              OKL_INS_POLICIES_B.PAYMENT_FREQUENCY%TYPE := OKC_API.G_MISS_CHAR
    ,crx_code                       OKL_INS_POLICIES_B.CRX_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,ipf_code                       OKL_INS_POLICIES_B.IPF_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,iss_code                       OKL_INS_POLICIES_B.ISS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,ipe_code                       OKL_INS_POLICIES_B.IPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,date_to                        OKL_INS_POLICIES_B.DATE_TO%TYPE := OKC_API.G_MISS_DATE
    ,date_from                      OKL_INS_POLICIES_B.DATE_FROM%TYPE := OKC_API.G_MISS_DATE
    ,date_quoted                    OKL_INS_POLICIES_B.DATE_QUOTED%TYPE := OKC_API.G_MISS_DATE
    ,date_proof_provided            OKL_INS_POLICIES_B.DATE_PROOF_PROVIDED%TYPE := OKC_API.G_MISS_DATE
    ,date_proof_required            OKL_INS_POLICIES_B.DATE_PROOF_REQUIRED%TYPE := OKC_API.G_MISS_DATE
    ,cancellation_date              OKL_INS_POLICIES_B.CANCELLATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,date_quote_expiry              OKL_INS_POLICIES_B.DATE_QUOTE_EXPIRY%TYPE := OKC_API.G_MISS_DATE
    ,activation_date                OKL_INS_POLICIES_B.ACTIVATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,quote_yn                       OKL_INS_POLICIES_B.QUOTE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,on_file_yn                     OKL_INS_POLICIES_B.ON_FILE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,private_label_yn               OKL_INS_POLICIES_B.PRIVATE_LABEL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,agent_yn                       OKL_INS_POLICIES_B.AGENT_YN%TYPE := OKC_API.G_MISS_CHAR
    ,lessor_insured_yn              OKL_INS_POLICIES_B.LESSOR_INSURED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,lessor_payee_yn                OKL_INS_POLICIES_B.LESSOR_PAYEE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,ipt_id                         NUMBER := OKC_API.G_MISS_NUM
    ,ipy_id                         NUMBER := OKC_API.G_MISS_NUM
    ,int_id                         NUMBER := OKC_API.G_MISS_NUM
    ,isu_id                         NUMBER := OKC_API.G_MISS_NUM
    ,factor_value                   NUMBER := OKC_API.G_MISS_NUM
    ,agency_number                  OKL_INS_POLICIES_B.AGENCY_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,agency_site_id                 NUMBER := OKC_API.G_MISS_NUM
    ,sales_rep_id                   NUMBER := OKC_API.G_MISS_NUM
    ,agent_site_id                  NUMBER := OKC_API.G_MISS_NUM
    ,adjusted_by_id                 NUMBER := OKC_API.G_MISS_NUM
    ,territory_code                 OKL_INS_POLICIES_B.TERRITORY_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,attribute_category             OKL_INS_POLICIES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_INS_POLICIES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_INS_POLICIES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_INS_POLICIES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_INS_POLICIES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_INS_POLICIES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_INS_POLICIES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_INS_POLICIES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_INS_POLICIES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_INS_POLICIES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_INS_POLICIES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_INS_POLICIES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_INS_POLICIES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_INS_POLICIES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_INS_POLICIES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_INS_POLICIES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_INS_POLICIES_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_INS_POLICIES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_INS_POLICIES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
    ,lease_application_id           NUMBER := OKC_API.G_MISS_NUM
-- Legal Entity Uptake
    ,legal_entity_id                OKL_INS_POLICIES_B.LEGAL_ENTITY_ID%TYPE := OKC_API.G_MISS_NUM);
  G_MISS_ipy_rec                          ipy_rec_type;
  TYPE ipy_tbl_type IS TABLE OF ipy_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_INS_POLICIES_TL Record Spec
  TYPE okl_ins_policies_tl_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,language                       OKL_INS_POLICIES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    OKL_INS_POLICIES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_INS_POLICIES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKL_INS_POLICIES_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,endorsement                    OKL_INS_POLICIES_TL.ENDORSEMENT%TYPE := OKC_API.G_MISS_CHAR
    ,comments                       OKL_INS_POLICIES_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR
    ,cancellation_comment           OKL_INS_POLICIES_TL.CANCELLATION_COMMENT%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_INS_POLICIES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_INS_POLICIES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_okl_ins_policies_tl_rec          okl_ins_policies_tl_rec_type;
  TYPE okl_ins_policies_tl_tbl_type IS TABLE OF okl_ins_policies_tl_rec_type
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_NO_PARENT_RECORD 			CONSTANT	VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_FND_LOOKUP_PAYMENT_FREQ 		CONSTANT	VARCHAR2(30) := 'OKL_INS_PAYMENT_FREQUENCY' ;
  G_FND_LOOKUP_INS_POLICY_TYPE 		CONSTANT	VARCHAR2(30) := 'OKL_INSURANCE_POLICY_TYPE' ;
  G_FND_LOOKUP_INS_CANCEL_REASON 	CONSTANT	VARCHAR2(30) := 'OKL_INS_CANCEL_REASON' ;
  G_FND_LOOKUP_INS_STATUS 		CONSTANT	VARCHAR2(30) := 'OKL_INSURANCE_STATUS' ;
  G_FND_LOOKUP_POLICY_TYPE 		CONSTANT	VARCHAR2(30) := 'OKL_INSURANCE_TYPE' ;
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_IPY_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := 'OKL';
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_rec                     IN ipyv_rec_type,
    x_ipyv_rec                     OUT NOCOPY ipyv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type,
    x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type,
    x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_rec                     IN ipyv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_rec                     IN ipyv_rec_type,
    x_ipyv_rec                     OUT NOCOPY ipyv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type,
    x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type,
    x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_rec                     IN ipyv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_rec                     IN ipyv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ipyv_tbl                     IN ipyv_tbl_type);
END OKL_IPY_PVT;

/
