--------------------------------------------------------
--  DDL for Package OKL_PARTY_PAYMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PARTY_PAYMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPPMS.pls 120.0 2005/11/30 17:17:51 stmathew noship $ */

subtype pph_rec_type is okl_ldb_pvt.pph_rec_type;
subtype pph_tbl_type is okl_ldb_pvt.pph_tbl_type;
subtype pphv_rec_type is okl_ldb_pvt.pphv_rec_type;
subtype pphv_tbl_type is okl_ldb_pvt.pphv_tbl_type;
subtype ppyd_rec_type is okl_pyd_pvt.ppyd_rec_type;
subtype ppyd_tbl_type is okl_pyd_pvt.ppyd_tbl_type;
subtype ppydv_rec_type is okl_pyd_pvt.ppydv_rec_type;
subtype ppydv_tbl_type is okl_pyd_pvt.ppydv_tbl_type;
subtype cplv_rec_type IS OKL_OKC_MIGRATION_PVT.cplv_rec_type;

-- Record type for a denormalized passthru parameter information
TYPE passthru_param_rec_type IS RECORD (
     dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,ppl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,passthru_term                  OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_TERM%TYPE := OKC_API.G_MISS_CHAR
    ,passthru_stream_type_id        OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    ,passthru_start_date            OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,payout_basis                   OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS%TYPE := OKC_API.G_MISS_CHAR
    ,payout_basis_formula           OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS_FORMULA%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from                 OKL_PARTY_PAYMENT_HDR_V.EFFECTIVE_FROM%TYPE := OKC_API.G_MISS_DATE
    ,effective_to                   OKL_PARTY_PAYMENT_HDR_V.EFFECTIVE_TO%TYPE := OKC_API.G_MISS_DATE
    ,payment_dtls_id                NUMBER := OKL_API.G_MISS_NUM
    ,cpl_id                         NUMBER := OKL_API.G_MISS_NUM
    ,vendor_id                      NUMBER := OKL_API.G_MISS_NUM
    ,pay_site_id                    NUMBER := OKL_API.G_MISS_NUM
    ,payment_term_id                NUMBER := OKL_API.G_MISS_NUM
    ,payment_method_code            OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,pay_group_code                 OKL_PARTY_PAYMENT_DTLS_V.PAY_GROUP_CODE%TYPE := OKL_API.G_MISS_CHAR
	,payment_hdr_id					OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_HDR_ID%TYPE := OKL_API.G_MISS_NUM
	,payment_basis					OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,payment_start_date				OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_START_DATE%TYPE := OKL_API.G_MISS_DATE
	,payment_frequency				OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR
	,remit_days						OKL_PARTY_PAYMENT_DTLS_V.REMIT_DAYS%TYPE := OKL_API.G_MISS_NUM
	,disbursement_basis				OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
	,disbursement_fixed_amount		OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
	,disbursement_percent			OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_PERCENT%TYPE := OKL_API.G_MISS_NUM
	,processing_fee_basis			OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_BASIS%TYPE := OKL_API.G_MISS_CHAR
	,processing_fee_fixed_amount	OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
	,processing_fee_percent			OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_PERCENT%TYPE := OKL_API.G_MISS_NUM
	--,processing_fee_formula			OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_FORMULA%TYPE := OKL_API.G_MISS_CHAR
	--,include_in_yield_flag			OKL_PARTY_PAYMENT_DTLS_V.INCLUDE_IN_YIELD_FLAG%TYPE := OKL_API.G_MISS_CHAR
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
    );
  G_MISS_passthru_param_rec         passthru_param_rec_type;
  TYPE passthru_param_tbl_type IS TABLE OF passthru_param_rec_type
       INDEX BY BINARY_INTEGER;

  TYPE evg_cle_rec_type IS RECORD (
     cle_id                      NUMBER := OKC_API.G_MISS_NUM
    ,cpl_id                      NUMBER := OKC_API.G_MISS_NUM
	,cle_start_date              OKC_K_LINES_B.START_DATE%TYPE := OKL_API.G_MISS_DATE);
  TYPE evg_cle_tbl_type IS TABLE OF evg_cle_rec_type INDEX BY BINARY_INTEGER;
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_PARTY_PAYMENTS_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE                     CONSTANT VARCHAR2(4) := '_PVT';

  ---------------------------------------------------------------------------
  -- Validations and Others
  ---------------------------------------------------------------------------
  PROCEDURE validate_passthru_qa (
  					 p_api_version  	   IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER
                     );
  PROCEDURE get_passthru_parameters (
  					 p_api_version         IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER,
                     p_cle_id              IN   NUMBER,
                     p_vendor_id           IN   NUMBER,
    				 x_passthru_param_tbl  OUT NOCOPY passthru_param_tbl_type
                     );
  ---------------------------------------------------------------------------
  -- Procedures and Functions for the header
  ---------------------------------------------------------------------------
  PROCEDURE create_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type,
    x_pphv_rec                     OUT NOCOPY pphv_rec_type);

  PROCEDURE create_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    x_pphv_tbl                     OUT NOCOPY pphv_tbl_type);

  PROCEDURE lock_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type);

  PROCEDURE lock_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type);

  PROCEDURE update_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type,
    x_pphv_rec                     OUT NOCOPY pphv_rec_type);

  PROCEDURE update_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    x_pphv_tbl                     OUT NOCOPY pphv_tbl_type);

  PROCEDURE delete_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type);

  PROCEDURE delete_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type);

  PROCEDURE validate_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type);

  PROCEDURE validate_party_payment_hdr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type);


  ---------------------------------------------------------------------------
  -- Procedures and Functions for the details
  ---------------------------------------------------------------------------

  PROCEDURE create_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type,
    x_ppydv_rec                    OUT NOCOPY ppydv_rec_type);

  PROCEDURE create_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type);

  PROCEDURE lock_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type);

  PROCEDURE lock_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type);

  PROCEDURE update_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                    IN ppydv_rec_type,
    x_ppydv_rec                    OUT NOCOPY ppydv_rec_type);

  PROCEDURE update_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type,
    x_ppydv_tbl                    OUT NOCOPY ppydv_tbl_type);

  PROCEDURE delete_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                     IN ppydv_rec_type);

  PROCEDURE delete_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type);

  PROCEDURE validate_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_rec                     IN ppydv_rec_type);

  PROCEDURE validate_party_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ppydv_tbl                    IN ppydv_tbl_type);

  PROCEDURE create_evgrn_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
	p_vendor_id					   IN NUMBER,
	x_cle_tbl					   OUT NOCOPY evg_cle_tbl_type);

  PROCEDURE create_evgrn_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
	p_vendor_id					   IN NUMBER,
	x_cpl_id					   OUT NOCOPY NUMBER);



END OKL_PARTY_PAYMENTS_PVT;

 

/
