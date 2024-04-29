--------------------------------------------------------
--  DDL for Package OKL_AM_LEASE_LOAN_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_LEASE_LOAN_TRMNT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLLTS.pls 120.6 2008/02/05 20:05:26 rmunjulu ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_LEASE_LOAN_TRMNT_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_COL_NAME_TOKEN     	 CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  --Bug# 3999921: pagarg +++ T and A ++++
  G_INVALID_VALUE	     CONSTANT VARCHAR2(200)	:= OKL_API.G_INVALID_VALUE;

  -- RMUNJULU 06-MAR-03 Fixed msg constants
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_CODE';


  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------

  G_EXCEPTION_HALT     EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  TYPE term_rec_type IS RECORD (
    p_contract_id              NUMBER         := OKL_API.G_MISS_NUM,
    p_contract_number          VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_contract_modifier        VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_orig_end_date            DATE           := OKL_API.G_MISS_DATE,
    p_contract_version         VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_termination_date         DATE           := OKL_API.G_MISS_DATE,
    p_termination_reason       VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_quote_id                 NUMBER         := OKL_API.G_MISS_NUM,
    p_quote_type               VARCHAR2(2000) := OKL_API.G_MISS_CHAR,
    p_quote_reason             VARCHAR2(2000) := OKL_API.G_MISS_CHAR,
    p_early_termination_yn     VARCHAR2(1)    := OKL_API.G_MISS_CHAR,
    p_control_flag             VARCHAR2(200)  := OKL_API.G_MISS_CHAR,
    p_recycle_flag             VARCHAR2(1)    := OKL_API.G_MISS_CHAR);


  SUBTYPE tcnv_rec_type IS OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  SUBTYPE tcnv_tbl_type IS OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
  --Bug# 3999921: pagarg +++ T and A ++++
  SUBTYPE taiv_rec_type IS okl_trx_ar_invoices_pub.taiv_rec_type;
  SUBTYPE tilv_rec_type IS okl_txl_ar_inv_lns_pub.tilv_rec_type;

  TYPE term_tbl_type IS TABLE OF term_rec_type  INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE validate_contract(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_contract_id                 IN  NUMBER,
           p_control_flag                IN  VARCHAR2,
           x_contract_status             OUT NOCOPY VARCHAR2);

  PROCEDURE lease_loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type);


  PROCEDURE lease_loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_tbl                    IN  term_tbl_type,
           p_tcnv_tbl                    IN  tcnv_tbl_type);

    PROCEDURE process_discount_subsidy(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_call_origin                 IN  VARCHAR2 DEFAULT NULL,
           p_termination_date            IN DATE);

  -- ++++++++++++++++++++  service contract integration begin ++++++++++++++++++
  -- RMUNJULU 3061751 27-AUG-2003
  -- Empty rec types declared, used for defaulting parameters
  G_TERM_REC_EMPTY term_rec_type;
  G_TCNV_REC_EMPTY tcnv_rec_type;

  -- RMUNJULU 3061751 27-AUG-2003 Added function to check if TRUE partial quote
  -- Returns Y if TRUE partial quote(some more assets); else N or NULL
  FUNCTION check_true_partial_quote(
               p_quote_id     IN NUMBER,
               p_contract_id  IN NUMBER) RETURN VARCHAR2;

  -- RMUNJULU 3061751 27-AUG-2003 Added function to check if service integration needed
  -- p_source Value set (TERMINATION, DISPOSE, RETURN)
  FUNCTION check_service_k_int_needed(
               p_term_rec     IN term_rec_type DEFAULT G_TERM_REC_EMPTY,
               p_tcnv_rec     IN tcnv_rec_type DEFAULT G_TCNV_REC_EMPTY,
               p_partial_yn   IN VARCHAR2 DEFAULT NULL,
               p_asset_id     IN NUMBER DEFAULT NULL,
               p_source       IN VARCHAR2) RETURN VARCHAR2;

  -- RMUNJULU 3061751 27-AUG-2003 Added function to do service integration notifications
  -- p_source Value set (TERMINATION, DISPOSE, RETURN)
  -- p_service_integration_needed Value Set ('Y','N')
  PROCEDURE service_k_integration(
               p_term_rec                   IN term_rec_type DEFAULT G_TERM_REC_EMPTY,
               p_transaction_id             IN NUMBER DEFAULT NULL,
               p_transaction_date           IN DATE DEFAULT NULL,
               p_source                     IN VARCHAR2,
               p_service_integration_needed IN VARCHAR2);

  -- RMUNJULU 3061751 22-SEP-2003 Added function to do check billing done
  -- BPD now provides a API to check for billing

  FUNCTION check_billing_done(
               p_contract_id         IN NUMBER DEFAULT NULL,
               p_contract_number     IN VARCHAR2 DEFAULT NULL,
               p_quote_number        IN NUMBER DEFAULT NULL,
               p_trn_date            IN DATE DEFAULT NULL,
               p_rev_rec_method      IN VARCHAR2 DEFAULT NULL, -- rmunjulu 6795295 added
               p_int_cal_basis       IN VARCHAR2 DEFAULT NULL, -- rmunjulu 6795295 added
               p_oks_chr_id          IN NUMBER DEFAULT NULL, -- rmunjulu 6795295 added
               p_sts_code            IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2; -- rmunjulu 6795295 added

  -- +++++++++++++++++++++ service contract integration end   ++++++++++++++++++

  --RMUNJULU 24-SEP-03 3018641 created
  PROCEDURE get_last_run(
                         p_trx_id         IN  NUMBER,
                         x_last_run       OUT NOCOPY NUMBER);

  --RMUNJULU 24-SEP-03 3018641 created
  PROCEDURE get_set_tmg_run(
                         p_trx_id         IN  NUMBER,
                         x_return_status  OUT NOCOPY VARCHAR2);

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

  -- rmunjulu EDAT new procedure which gets the quote eff dates
  -- and sets the global variables g_quote_eff_from_date and g_quote_accept_date
  -- and g_quote_exists
  PROCEDURE get_set_quote_dates(
          p_qte_id              IN NUMBER,
          p_trn_date            IN DATE DEFAULT NULL,
          x_return_status       OUT NOCOPY VARCHAR2);

  g_quote_eff_from_date DATE;
  g_quote_accept_date   DATE;
  g_quote_exists        VARCHAR2(3);
  g_transaction_date    DATE; -- will be used in later development

  -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

  --Bug# 3999921: pagarg +++ T and A +++++++ Start ++++++++++
  PROCEDURE process_adjustments(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status               OUT NOCOPY VARCHAR2,
            x_msg_count                   OUT NOCOPY NUMBER,
            x_msg_data                    OUT NOCOPY VARCHAR2,
            p_term_rec                    IN  term_rec_type,
            p_tcnv_rec                    IN  tcnv_rec_type, -- rmunjulu TNA added since trn_id is needed
            p_call_origin                 IN  VARCHAR2 DEFAULT NULL,
            p_termination_date            IN DATE);
  --Bug# 3999921: pagarg +++ T and A +++++++ End ++++++++++

  -- RMUNJULU LOANS_ENHACEMENT
  -- BPD now provides a API to check for interest calculation
  FUNCTION check_int_calc_done(
               p_contract_id         IN NUMBER,
               p_contract_number     IN VARCHAR2,
               p_quote_number        IN NUMBER DEFAULT NULL,
               p_source              IN VARCHAR2,
               p_trn_date            IN DATE) RETURN VARCHAR2;

  -- rmunjulu LOANS_ENHANCEMENTS refund excess loan payments
  PROCEDURE process_loan_refunds(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type,
           p_call_origin                 IN  VARCHAR2 DEFAULT NULL,
           p_termination_date            IN  DATE);

  -- rmunjulu bug 6736148
  FUNCTION check_stream_billing_done(
               p_contract_id         IN NUMBER DEFAULT NULL,
               p_contract_number     IN VARCHAR2 DEFAULT NULL,
               p_quote_number        IN NUMBER DEFAULT NULL,
               p_trn_date            IN DATE DEFAULT NULL) RETURN VARCHAR2;

END OKL_AM_LEASE_LOAN_TRMNT_PVT;

/
