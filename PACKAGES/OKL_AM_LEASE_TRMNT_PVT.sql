--------------------------------------------------------
--  DDL for Package OKL_AM_LEASE_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_LEASE_TRMNT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLTNS.pls 120.7 2008/04/15 22:09:41 rmunjulu ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME         CONSTANT VARCHAR2(200) := 'OKL_AM_LEASE_TRMNT_PVT';
  G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';

  -- RMUNJULU 05-MAR-03 Fixed msg constant
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_APP_NAME_1       CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_REQUIRED_VALUE   CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	   CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN   CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_YES              CONSTANT VARCHAR2(1)   := 'Y';
  G_NO               CONSTANT VARCHAR2(1)   := 'N';

  -- RMUNJULU 05-MAR-03 added constant
  G_TMT_RECYCLE_YN   VARCHAR2(1);

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION     EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  SUBTYPE term_rec_type          IS OKL_AM_LEASE_LOAN_TRMNT_PUB.term_rec_type;
  SUBTYPE tcnv_rec_type          IS OKL_AM_LEASE_LOAN_TRMNT_PUB.tcnv_rec_type;
  SUBTYPE stmv_tbl_type          IS OKL_STREAMS_PUB.stmv_tbl_type;
  SUBTYPE adjv_rec_type          IS OKL_TRX_AR_ADJSTS_PUB.adjv_rec_type;
  SUBTYPE ajlv_tbl_type          IS OKL_TXL_ADJSTS_LNS_PUB.ajlv_tbl_type;
  SUBTYPE chrv_rec_type          IS OKC_CONTRACT_PUB.chrv_rec_type;
  SUBTYPE clev_tbl_type          IS OKC_CONTRACT_PUB.clev_tbl_type;


  TYPE klev_rec_type IS RECORD (
           p_kle_id                      NUMBER         := OKL_API.G_MISS_NUM,
           p_asset_name                  VARCHAR2(2000) := OKL_API.G_MISS_CHAR);

  TYPE klev_tbl_type IS TABLE OF klev_rec_type INDEX BY BINARY_INTEGER;

  empty_klev_tbl klev_tbl_type;
  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE set_database_values(
           px_term_rec                   IN OUT NOCOPY term_rec_type);

  PROCEDURE set_info_messages(
           p_term_rec                    IN term_rec_type);

  PROCEDURE get_contract_lines(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           x_klev_tbl                    OUT NOCOPY klev_tbl_type);

  PROCEDURE set_overall_status(
           p_return_status               IN VARCHAR2,
           px_overall_status             IN OUT NOCOPY VARCHAR2);

  PROCEDURE set_transaction_rec(
           p_return_status               IN VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
           p_overall_status              IN VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
           p_tmt_flag                    IN VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
           p_tsu_code                    IN VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
           p_ret_val                     IN VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type);

  PROCEDURE initialize_transaction (
           px_tcnv_rec                   IN  OUT NOCOPY tcnv_rec_type,
           p_term_rec                    IN  term_rec_type,
           p_sys_date                    IN  DATE,
           p_control_flag                IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
 	   -- akrangan bug 5354501 fix start
 	   x_msg_count                   OUT NOCOPY NUMBER,
 	   x_msg_data                    OUT NOCOPY VARCHAR2);
 	   -- akrangan bug 5354501 fix end
  PROCEDURE validate_lease(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_sys_date                    IN  DATE,
           p_term_rec                    IN  term_rec_type);

  PROCEDURE process_accounting_entries(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           p_sys_date                    IN DATE,
           p_klev_tbl                    IN klev_tbl_type, -- pagarg 4190887 Added
           p_trn_already_set             IN VARCHAR2,
		   p_source                      IN VARCHAR2 DEFAULT NULL); -- rmunjulu Bug 4141991

  PROCEDURE process_asset_dispose(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           p_sys_date                    IN DATE DEFAULT SYSDATE, -- rmunjulu EDAT
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           p_klev_tbl                    IN  klev_tbl_type,
           p_trn_already_set             IN  VARCHAR2,
		   p_auto_invoice_yn             IN  VARCHAR2 DEFAULT NULL ); -- rmunjulu BUYOUT_PROCESS

  PROCEDURE process_cancel_insurance(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           p_sys_date                    IN  DATE,
           p_trn_already_set             IN  VARCHAR2);

  PROCEDURE process_close_balances(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           x_adjv_rec                    OUT NOCOPY adjv_rec_type,
           x_ajlv_tbl                    OUT NOCOPY ajlv_tbl_type,
           p_sys_date                    IN  DATE,
           p_trn_already_set             IN  VARCHAR2,
		   p_auto_invoice_yn             IN VARCHAR2 DEFAULT NULL, -- rmunjulu BUYOUT_PROCESS
           p_klev_tbl                    IN klev_tbl_type DEFAULT empty_klev_tbl); -- rmunjulu BUYOUT_PROCESS

  PROCEDURE process_close_streams(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           x_stmv_tbl                    OUT NOCOPY stmv_tbl_type,
           p_sys_date                    IN  DATE,
           p_trn_already_set             IN  VARCHAR2);

  PROCEDURE process_transaction(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_id                          IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type,
           x_id                          OUT NOCOPY NUMBER,
           p_trn_mode                    IN  VARCHAR2);

  PROCEDURE process_amortize_and_return(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           p_sys_date                    IN DATE,
           p_klev_tbl                    IN klev_tbl_type,
           p_trn_already_set             IN  VARCHAR2);

  PROCEDURE update_k_hdr_and_lines(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_status                      IN  VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_klev_tbl                    IN  klev_tbl_type,
           p_trn_reason_code             IN  VARCHAR2,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           x_chrv_rec                    OUT NOCOPY chrv_rec_type,
           x_clev_tbl                    OUT NOCOPY clev_tbl_type,
           p_sys_date                    IN  DATE);

  PROCEDURE lease_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type);

  -- RMUNJULU 04-MAR-04 3485854 New Function
  FUNCTION check_k_evergreen_ear(
                       p_khr_id          IN NUMBER,
                       p_tcn_id          IN NUMBER,
                       x_return_status   OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  -- RMUNJULU 04-MAR-04 3485854 New Procedure
  PROCEDURE process_amortize(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           p_sys_date                    IN DATE,
           p_trn_already_set             IN VARCHAR2 DEFAULT NULL,
           p_call_origin                 IN VARCHAR2 DEFAULT NULL);

  -- rmunjulu bug 6853566 Declare this variable and use it in Delink
  l_emty_tbl OKL_AM_CNTRCT_LN_TRMNT_PVT.klev_tbl_type;

  -- rmunjulu bug 6853566 Delare delink so that it can be used from partial termination.
  PROCEDURE delink_contract_from_asset(
                       p_api_version      IN  NUMBER,
                       x_msg_count        OUT  NOCOPY NUMBER,
                       x_msg_data         OUT  NOCOPY VARCHAR2,
                       p_full_term_yn     IN VARCHAR2 DEFAULT NULL,
                       p_khr_id           IN NUMBER,
                       p_klev_tbl         IN OKL_AM_CNTRCT_LN_TRMNT_PVT.klev_tbl_type DEFAULT l_emty_tbl,
                       p_sts_code         IN VARCHAR2 DEFAULT NULL,
                       p_quote_accpt_date IN DATE,
                       p_quote_eff_date   IN DATE,
                       x_return_status    OUT NOCOPY VARCHAR2);

END OKL_AM_LEASE_TRMNT_PVT;

/
