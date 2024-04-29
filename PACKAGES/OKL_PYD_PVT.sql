--------------------------------------------------------
--  DDL for Package OKL_PYD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PYD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPYDS.pls 120.3.12010000.2 2009/07/17 23:26:38 sechawla ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_PARTY_PAYMENT_DTLS_V Record Spec
  TYPE ppydv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,cpl_id                         NUMBER := OKL_API.G_MISS_NUM
    ,vendor_id                      NUMBER := OKL_API.G_MISS_NUM
    ,pay_site_id                    NUMBER := OKL_API.G_MISS_NUM
    ,payment_term_id                NUMBER := OKL_API.G_MISS_NUM
    ,payment_method_code            OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,pay_group_code                 OKL_PARTY_PAYMENT_DTLS_V.PAY_GROUP_CODE%TYPE := OKL_API.G_MISS_CHAR
	,payment_hdr_id					OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_HDR_ID%TYPE := OKL_API.G_MISS_NUM
	,payment_start_date				OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_START_DATE%TYPE := OKL_API.G_MISS_DATE
	,payment_frequency				OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR
	,remit_days						OKL_PARTY_PAYMENT_DTLS_V.REMIT_DAYS%TYPE := OKL_API.G_MISS_NUM
	,disbursement_basis				OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
	,disbursement_fixed_amount		OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
	,disbursement_percent			OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_PERCENT%TYPE := OKL_API.G_MISS_NUM
	,processing_fee_basis			OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_BASIS%TYPE := OKL_API.G_MISS_CHAR
	,processing_fee_fixed_amount	OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
	,processing_fee_percent			OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_PERCENT%TYPE := OKL_API.G_MISS_NUM
	--,include_in_yield_flag			OKL_PARTY_PAYMENT_DTLS_V.INCLUDE_IN_YIELD_FLAG%TYPE := OKL_API.G_MISS_CHAR
	--,processing_fee_formula			OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_FORMULA%TYPE := OKL_API.G_MISS_CHAR
	,payment_basis					OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_PARTY_PAYMENT_DTLS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_PARTY_PAYMENT_DTLS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_PARTY_PAYMENT_DTLS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
	,ORIG_CONTRACT_LINE_ID          NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_ppydv_rec                        ppydv_rec_type;
  TYPE ppydv_tbl_type IS TABLE OF ppydv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_PARTY_PAYMENT_DTLS Record Spec
  TYPE ppyd_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,cpl_id                         NUMBER := OKL_API.G_MISS_NUM
    ,vendor_id                      NUMBER := OKL_API.G_MISS_NUM
    ,pay_site_id                    NUMBER := OKL_API.G_MISS_NUM
    ,payment_term_id                NUMBER := OKL_API.G_MISS_NUM
    ,payment_method_code            OKL_PARTY_PAYMENT_DTLS.PAYMENT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,pay_group_code                 OKL_PARTY_PAYMENT_DTLS.PAY_GROUP_CODE%TYPE := OKL_API.G_MISS_CHAR
	,payment_hdr_id					OKL_PARTY_PAYMENT_DTLS.PAYMENT_HDR_ID%TYPE := OKL_API.G_MISS_NUM
	,payment_start_date				OKL_PARTY_PAYMENT_DTLS.PAYMENT_START_DATE%TYPE := OKL_API.G_MISS_DATE
	,payment_frequency				OKL_PARTY_PAYMENT_DTLS.PAYMENT_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR
	,remit_days						OKL_PARTY_PAYMENT_DTLS.REMIT_DAYS%TYPE := OKL_API.G_MISS_NUM
	,disbursement_basis				OKL_PARTY_PAYMENT_DTLS.DISBURSEMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
	,disbursement_fixed_amount		OKL_PARTY_PAYMENT_DTLS.DISBURSEMENT_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
	,disbursement_percent			OKL_PARTY_PAYMENT_DTLS.DISBURSEMENT_PERCENT%TYPE := OKL_API.G_MISS_NUM
	,processing_fee_basis			OKL_PARTY_PAYMENT_DTLS.PROCESSING_FEE_BASIS%TYPE := OKL_API.G_MISS_CHAR
	,processing_fee_fixed_amount	OKL_PARTY_PAYMENT_DTLS.PROCESSING_FEE_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
	,processing_fee_percent			OKL_PARTY_PAYMENT_DTLS.PROCESSING_FEE_PERCENT%TYPE := OKL_API.G_MISS_NUM
	--,include_in_yield_flag			OKL_PARTY_PAYMENT_DTLS.INCLUDE_IN_YIELD_FLAG%TYPE := OKL_API.G_MISS_CHAR
	--,processing_fee_formula			OKL_PARTY_PAYMENT_DTLS.PROCESSING_FEE_FORMULA%TYPE := OKL_API.G_MISS_CHAR
	,payment_basis					OKL_PARTY_PAYMENT_DTLS.PAYMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_PARTY_PAYMENT_DTLS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_PARTY_PAYMENT_DTLS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
	,ORIG_CONTRACT_LINE_ID          NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_ppyd_rec                         ppyd_rec_type;
  TYPE ppyd_tbl_type IS TABLE OF ppyd_rec_type
        INDEX BY BINARY_INTEGER;

 -- OKL_PARTY_PYMT_DTLS_H Record Spec
  TYPE ppydh_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,major_version                  NUMBER := OKL_API.G_MISS_NUM
    ,cpl_id                         NUMBER := OKL_API.G_MISS_NUM
    ,vendor_id                      NUMBER := OKL_API.G_MISS_NUM
    ,pay_site_id                    NUMBER := OKL_API.G_MISS_NUM
    ,payment_term_id                NUMBER := OKL_API.G_MISS_NUM
    ,payment_method_code            OKL_PARTY_PAYMENT_DTLS.PAYMENT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,pay_group_code                 OKL_PARTY_PAYMENT_DTLS.PAY_GROUP_CODE%TYPE := OKL_API.G_MISS_CHAR
	,payment_hdr_id					OKL_PARTY_PAYMENT_DTLS.PAYMENT_HDR_ID%TYPE := OKL_API.G_MISS_NUM
	,payment_start_date				OKL_PARTY_PAYMENT_DTLS.PAYMENT_START_DATE%TYPE := OKL_API.G_MISS_DATE
	,payment_frequency				OKL_PARTY_PAYMENT_DTLS.PAYMENT_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR
	,remit_days						OKL_PARTY_PAYMENT_DTLS.REMIT_DAYS%TYPE := OKL_API.G_MISS_NUM
	,disbursement_basis				OKL_PARTY_PAYMENT_DTLS.DISBURSEMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
	,disbursement_fixed_amount		OKL_PARTY_PAYMENT_DTLS.DISBURSEMENT_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
	,disbursement_percent			OKL_PARTY_PAYMENT_DTLS.DISBURSEMENT_PERCENT%TYPE := OKL_API.G_MISS_NUM
	,processing_fee_basis			OKL_PARTY_PAYMENT_DTLS.PROCESSING_FEE_BASIS%TYPE := OKL_API.G_MISS_CHAR
	,processing_fee_fixed_amount	OKL_PARTY_PAYMENT_DTLS.PROCESSING_FEE_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
	,processing_fee_percent			OKL_PARTY_PAYMENT_DTLS.PROCESSING_FEE_PERCENT%TYPE := OKL_API.G_MISS_NUM
	--,include_in_yield_flag			OKL_PARTY_PAYMENT_DTLS.INCLUDE_IN_YIELD_FLAG%TYPE := OKL_API.G_MISS_CHAR
	--,processing_fee_formula			OKL_PARTY_PAYMENT_DTLS.PROCESSING_FEE_FORMULA%TYPE := OKL_API.G_MISS_CHAR
	,payment_basis					OKL_PARTY_PAYMENT_DTLS.PAYMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_PARTY_PAYMENT_DTLS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_PARTY_PAYMENT_DTLS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_PARTY_PAYMENT_DTLS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
	,ORIG_CONTRACT_LINE_ID          NUMBER := OKL_API.G_MISS_NUM );
  G_MISS_ppydh_rec                         ppydh_rec_type;
  TYPE ppydh_tbl_type IS TABLE OF ppydh_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_PYD_PVT';
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
    p_ppydv_rec                    IN ppydv_rec_type,
    x_ppydv_rec                    OUT NOCOPY ppydv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type,
    x_ppydv_rec                    OUT NOCOPY ppydv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;
END OKL_PYD_PVT;

/
