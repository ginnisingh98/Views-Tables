--------------------------------------------------------
--  DDL for Package OKL_MAINTAIN_FEE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MAINTAIN_FEE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRFEES.pls 120.13 2006/03/02 23:45:45 smereddy noship $ */

-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME              CONSTANT VARCHAR2(200) := 'OKL_MAINTAIN_FEE_PVT';
G_APP_NAME              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE		CONSTANT VARCHAR2(4)   := '_PVT';
G_FALSE                CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
G_TRUE                 CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;

G_FT_FINANCED		CONSTANT VARCHAR2(200) := 'FINANCED';
G_FT_ABSORBED		CONSTANT VARCHAR2(200) := 'ABSORBED';
G_FT_PASSTHROUGH	CONSTANT VARCHAR2(200) := 'PASSTHROUGH';
G_FT_CAPITALIZED	CONSTANT VARCHAR2(200) := 'CAPITALIZED';
G_FT_INCOME		CONSTANT VARCHAR2(200) := 'INCOME';
G_FT_EXPENSE		CONSTANT VARCHAR2(200) := 'EXPENSE';
G_FT_MISCELLANEOUS	CONSTANT VARCHAR2(200) := 'MISCELLANEOUS';
G_FT_SECDEPOSIT		CONSTANT VARCHAR2(200) := 'SECDEPOSIT';
G_FT_GENERAL		CONSTANT VARCHAR2(200) := 'GENERAL';
G_FT_ROLLOVER		CONSTANT VARCHAR2(200) := 'ROLLOVER';

G_OKL_FEE_PURPOSE_CODE  CONSTANT VARCHAR2(200) := 'SALESTAX';
--G_OKL_FEE_PURPOSE_CODE  CONSTANT VARCHAR2(200) := 'RVI';
G_OKL_FEE_PURPOSE_LOOKUP_TYPE  CONSTANT VARCHAR2(200) := 'OKL_FEE_PURPOSE';

---------------------------------------------------------------------------

TYPE fee_types_rec_type is record
(
     line_id               okc_k_lines_b.id%type,
     dnz_chr_id            okc_k_lines_b.dnz_chr_id%type,
     fee_type              varchar2(250),
     item_id               okc_k_lines_b.id%type,
     item_name             OKL_STRMTYP_SOURCE_V.NAME%type,
     item_id1              OKC_K_ITEMS_V.object1_ID1%type,
     item_id2              OKC_K_ITEMS_V.object1_ID2%type,
     party_id              OKC_K_PARTY_ROLES_V.ID%type,
     party_name            OKX_PARTIES_V.NAME%type,
     party_id1             OKC_K_PARTY_ROLES_V.object1_id1%type,
     party_id2             OKC_K_PARTY_ROLES_V.object1_id2%type,
     effective_from        okc_k_lines_b.start_date%type,
     effective_to          okc_k_lines_b.end_date%type,
     amount                okl_k_lines.amount%type,
     initial_direct_cost   okl_k_lines.initial_direct_cost%type,
     roll_qt               OKL_TRX_QUOTES_B.QUOTE_NUMBER%type,
     qte_id                okl_k_lines.qte_id%type,
     FUNDING_DATE          okl_k_lines.FUNDING_DATE%type,
     FEE_PURPOSE_CODE      okl_k_lines.FEE_PURPOSE_CODE%type,
     --Bug# 4558486
     attribute_category    okl_k_lines.attribute_category%type,
     attribute1            okl_k_lines.attribute1%type,
     attribute2            okl_k_lines.attribute2%type,
     attribute3            okl_k_lines.attribute3%type,
     attribute4            okl_k_lines.attribute4%type,
     attribute5            okl_k_lines.attribute5%type,
     attribute6            okl_k_lines.attribute6%type,
     attribute7            okl_k_lines.attribute7%type,
     attribute8            okl_k_lines.attribute8%type,
     attribute9            okl_k_lines.attribute9%type,
     attribute10           okl_k_lines.attribute10%type,
     attribute11           okl_k_lines.attribute11%type,
     attribute12           okl_k_lines.attribute12%type,
     attribute13           okl_k_lines.attribute13%type,
     attribute14           okl_k_lines.attribute14%type,
     attribute15           okl_k_lines.attribute15%type,
     validate_dff_yn       VARCHAR2(3)
 );
 TYPE fee_types_tbl_type is table of fee_types_rec_type INDEX BY BINARY_INTEGER;

--Murthy Passthru changes Begin.
TYPE passthru_dtl_rec_type IS RECORD (
     b_dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,b_cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,b_ppl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,b_passthru_term                  OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_TERM%TYPE := OKC_API.G_MISS_CHAR
    ,b_passthru_stream_type_id        OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    ,b_passthru_start_date            OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,b_payout_basis                   OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS%TYPE := OKC_API.G_MISS_CHAR
    ,b_payout_basis_formula           OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS_FORMULA%TYPE := OKC_API.G_MISS_CHAR
    ,b_effective_from                 OKL_PARTY_PAYMENT_HDR_V.EFFECTIVE_FROM%TYPE := OKC_API.G_MISS_DATE
    ,b_effective_to                   OKL_PARTY_PAYMENT_HDR_V.EFFECTIVE_TO%TYPE := OKC_API.G_MISS_DATE
    ,b_payment_dtls_id                NUMBER := OKL_API.G_MISS_NUM
    ,b_cpl_id                         NUMBER := OKL_API.G_MISS_NUM
    ,b_vendor_id                      NUMBER := OKL_API.G_MISS_NUM
    ,b_pay_site_id                    NUMBER := OKL_API.G_MISS_NUM
    ,b_payment_term_id                NUMBER := OKL_API.G_MISS_NUM
    ,b_payment_method_code            OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,b_pay_group_code                 OKL_PARTY_PAYMENT_DTLS_V.PAY_GROUP_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,b_payment_hdr_id                 OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_HDR_ID%TYPE := OKL_API.G_MISS_NUM
    ,b_payment_basis                  OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,b_payment_start_date             OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,b_payment_frequency              OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR
    ,b_remit_days                     OKL_PARTY_PAYMENT_DTLS_V.REMIT_DAYS%TYPE := OKL_API.G_MISS_NUM
    ,b_disbursement_basis             OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,b_disbursement_fixed_amount      OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
    ,b_disbursement_percent           OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_PERCENT%TYPE := OKL_API.G_MISS_NUM
    ,b_processing_fee_basis           OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,b_processing_fee_fixed_amount    OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
    ,b_processing_fee_percent         OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_PERCENT%TYPE := OKL_API.G_MISS_NUM
    --,b_processing_fee_formula         OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_FORMULA%TYPE := OKL_API.G_MISS_CHAR
    ,e_dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,e_cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,e_ppl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,e_passthru_term                  OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_TERM%TYPE := OKC_API.G_MISS_CHAR
    ,e_passthru_stream_type_id        OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    ,e_passthru_start_date            OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,e_payout_basis                   OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS%TYPE := OKC_API.G_MISS_CHAR
    ,e_payout_basis_formula           OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS_FORMULA%TYPE := OKC_API.G_MISS_CHAR
    ,e_effective_from                 OKL_PARTY_PAYMENT_HDR_V.EFFECTIVE_FROM%TYPE := OKC_API.G_MISS_DATE
    ,e_effective_to                   OKL_PARTY_PAYMENT_HDR_V.EFFECTIVE_TO%TYPE := OKC_API.G_MISS_DATE
    ,e_payment_dtls_id                NUMBER := OKL_API.G_MISS_NUM
    ,e_cpl_id                         NUMBER := OKL_API.G_MISS_NUM
    ,e_vendor_id                      NUMBER := OKL_API.G_MISS_NUM
    ,e_pay_site_id                    NUMBER := OKL_API.G_MISS_NUM
    ,e_payment_term_id                NUMBER := OKL_API.G_MISS_NUM
    ,e_payment_method_code            OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,e_pay_group_code                 OKL_PARTY_PAYMENT_DTLS_V.PAY_GROUP_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,e_payment_hdr_id                 OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_HDR_ID%TYPE := OKL_API.G_MISS_NUM
    ,e_payment_basis                  OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,e_payment_start_date             OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,e_payment_frequency              OKL_PARTY_PAYMENT_DTLS_V.PAYMENT_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR
    ,e_remit_days                     OKL_PARTY_PAYMENT_DTLS_V.REMIT_DAYS%TYPE := OKL_API.G_MISS_NUM
    ,e_disbursement_basis             OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,e_disbursement_fixed_amount      OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
    ,e_disbursement_percent           OKL_PARTY_PAYMENT_DTLS_V.DISBURSEMENT_PERCENT%TYPE := OKL_API.G_MISS_NUM
    ,e_processing_fee_basis           OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_BASIS%TYPE := OKL_API.G_MISS_CHAR
    ,e_processing_fee_fixed_amount    OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_FIXED_AMOUNT%TYPE := OKL_API.G_MISS_NUM
    ,e_processing_fee_percent         OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_PERCENT%TYPE := OKL_API.G_MISS_NUM
    --,e_processing_fee_formula         OKL_PARTY_PAYMENT_DTLS_V.PROCESSING_FEE_FORMULA%TYPE := OKL_API.G_MISS_CHAR
    );
TYPE passthru_dtl_tbl_type IS TABLE OF passthru_dtl_rec_type INDEX BY BINARY_INTEGER;

TYPE passthru_rec_type IS RECORD (
    base_id                         NUMBER := OKC_API.G_MISS_NUM
    ,evergreen_id                   NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,passthru_start_date            OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,payout_basis                   OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS%TYPE := OKC_API.G_MISS_CHAR
    ,evergreen_eligible_yn          VARCHAR2(1) := OKC_API.G_MISS_CHAR
    ,evergreen_payout_basis         OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS%TYPE := OKC_API.G_MISS_CHAR
    ,evergreen_payout_basis_formula OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS_FORMULA%TYPE := OKC_API.G_MISS_CHAR
    ,passthru_term                  OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_TERM%TYPE := OKC_API.G_MISS_CHAR
    ,base_stream_type_id            OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    ,evg_stream_type_id             OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    --,passthru_stream_type_id        OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    );
TYPE passthru_tbl_type IS TABLE OF passthru_rec_type INDEX BY BINARY_INTEGER;

  TYPE party_rec_type is record (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_K_PARTY_ROLES.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_K_PARTY_ROLES.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_K_PARTY_ROLES.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_K_PARTY_ROLES.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_K_PARTY_ROLES.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_K_PARTY_ROLES.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_K_PARTY_ROLES.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_K_PARTY_ROLES.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_K_PARTY_ROLES.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_K_PARTY_ROLES.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_K_PARTY_ROLES.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_K_PARTY_ROLES.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_K_PARTY_ROLES.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_K_PARTY_ROLES.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_K_PARTY_ROLES.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_K_PARTY_ROLES.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,object1_id1                    OKC_K_PARTY_ROLES_B.object1_id1%type := OKL_API.G_MISS_CHAR
    ,object1_id2                    OKC_K_PARTY_ROLES_B.object1_id2%type := OKL_API.G_MISS_CHAR
    ,jtot_object1_code              OKC_K_PARTY_ROLES_B.jtot_object1_code%type := OKL_API.G_MISS_CHAR
    ,rle_code              	    OKC_K_PARTY_ROLES_B.rle_code%type := OKL_API.G_MISS_CHAR
    ,chr_id              	    OKC_K_PARTY_ROLES_B.chr_id%type := OKL_API.G_MISS_NUM
    ,dnz_chr_id              	    OKC_K_PARTY_ROLES_B.dnz_chr_id%type := OKL_API.G_MISS_NUM
    ,cle_id              	    OKC_K_PARTY_ROLES_B.cle_id%type := OKL_API.G_MISS_NUM
   );

  TYPE party_tab_type is table of party_rec_type INDEX BY BINARY_INTEGER;


  PROCEDURE create_payment_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_passthru_dtl_rec             IN  passthru_dtl_rec_type,
    x_passthru_dtl_rec             OUT NOCOPY passthru_dtl_rec_type);

  PROCEDURE create_payment_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_passthru_rec                 IN  passthru_rec_type,
    x_passthru_rec                 OUT NOCOPY passthru_rec_type);

  PROCEDURE delete_payment_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_passthru_rec                 IN  passthru_rec_type);
--Murthy Passthru changes end.

 PROCEDURE create_fee_type(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type,
            x_fee_types_rec          OUT NOCOPY fee_types_rec_type
 );

 PROCEDURE validate_fee_type(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type,
            x_fee_types_rec          OUT NOCOPY fee_types_rec_type
 );

 PROCEDURE update_fee_type(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type,
            x_fee_types_rec          OUT NOCOPY fee_types_rec_type
 );

 PROCEDURE delete_fee_type(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type
 );

 PROCEDURE create_strmtp_rul(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER
            );

 PROCEDURE update_strmtp_rul(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER,
            p_rgp_id                 IN  NUMBER,
            p_rul_id                 IN  NUMBER
            );

 PROCEDURE process_strmtp_rul(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER,
            p_object1_id1            IN  VARCHAR2
            );

 -------------------------------------------------
  -- Create By Manu 19-Aug-2004
  -- This api will be called by activate_contract
  -- to validate the rollover termination quotes on
  -- the contact before activating the contract
  -- Also called by Re-book Contract API.
  --------------------------------------------------
  PROCEDURE validate_rollover_feeLine(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  OKC_K_HEADERS_B.ID%TYPE,
            p_qte_id          IN  OKL_K_LINES.QTE_ID%TYPE,
            p_for_qa_check    IN  BOOLEAN DEFAULT FALSE);

 -------------------------------------------------
  -- Create By smereddy 30-Aug-2004
  -- This api will be called by activate_contract
  -- to update the creditline limit against the rollover amount
  -- this gets called before activating the contract
  -- Also called by Re-book Contract API.
  --------------------------------------------------
  PROCEDURE rollover_fee(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  NUMBER,
            p_cl_id              IN  NUMBER,
            x_rem_amt            OUT NOCOPY NUMBER
            );


 -------------------------------------------------
  -- Create By smereddy 30-Aug-2004
  -- API called to throw warning message if the rollove amount
  -- exceeds the total available/remaining credit limit amount
  -- Also called by Re-book Contract API.
  --------------------------------------------------
  PROCEDURE rollover_fee(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  NUMBER,
            x_rem_amt            OUT NOCOPY NUMBER);

  PROCEDURE allocate_amount(p_api_version         IN         NUMBER,
                            p_init_msg_list       IN         VARCHAR2 DEFAULT G_FALSE,
                            p_transaction_control IN         VARCHAR2 DEFAULT G_TRUE,
                            p_cle_id              IN         NUMBER,
                            p_chr_id              IN         NUMBER,
                            p_capitalize_yn       IN         VARCHAR2,
                            x_cle_id              OUT NOCOPY NUMBER,
                            x_chr_id              OUT NOCOPY NUMBER,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2);

-- Guru Added this for RVI

 PROCEDURE process_rvi_stream(
            p_api_version            IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_check_box_value        IN VARCHAR2,
            p_fee_types_rec          IN  fee_types_rec_type,
            x_fee_types_rec          OUT NOCOPY fee_types_rec_type);

  PROCEDURE delete_passthru_party(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_cpl_id                       IN  NUMBER
     );

  PROCEDURE create_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                      IN  party_rec_type,
      x_kpl_rec                      OUT NOCOPY party_rec_type
      );

  PROCEDURE update_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                      IN  party_rec_type,
      x_kpl_rec                      OUT NOCOPY party_rec_type
      );

END OKL_MAINTAIN_FEE_PVT;

/
