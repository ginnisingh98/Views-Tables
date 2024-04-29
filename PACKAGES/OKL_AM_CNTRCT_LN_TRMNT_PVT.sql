--------------------------------------------------------
--  DDL for Package OKL_AM_CNTRCT_LN_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CNTRCT_LN_TRMNT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCLTS.pls 120.2 2005/10/30 03:39:05 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME         CONSTANT VARCHAR2(200) := 'OKL_AM_CNTRCT_LN_TRMNT_PVT';
  G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';

  -- RMUNJULU 03-MAR-03 2830997 Changed SQLerrm to ERROR_MESSAGE
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';

  -- RMUNJULU 03-MAR-03 2830997 Changed SQLcode to ERROR_CODE
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';

  G_REQUIRED_VALUE   CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	 CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN   CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_YES              CONSTANT VARCHAR2(1)   := 'Y';
  G_NO               CONSTANT VARCHAR2(1)   := 'N';
  G_API_VERSION		 CONSTANT NUMBER		    := 1;

  -- RMUNJULU Changed FND_API to OKL_API for GSCC
  G_MISS_CHAR        CONSTANT VARCHAR2(1)   := OKL_API.G_MISS_CHAR;
  G_MISS_NUM         CONSTANT NUMBER        := OKL_API.G_MISS_NUM;
  G_MISS_DATE        CONSTANT DATE          := OKL_API.G_MISS_DATE;

  G_TRUE             CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_FALSE            CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;


  G_NO_MATCHING_RECORD CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_FIN_LINE_LTY_CODE  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_SER_LINE_LTY_CODE  OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'SOLD_SERVICE';
  G_SRL_LINE_LTY_CODE  OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'LINK_SERV_ASSET';
  G_FEE_LINE_LTY_CODE  OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'FEE';
  G_FEL_LINE_LTY_CODE  OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'LINK_FEE_ASSET';
  G_USG_LINE_LTY_CODE  OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'USAGE';
  G_USL_LINE_LTY_CODE  OKC_LINE_STYLES_B.LTY_CODE%TYPE := 'LINK_USAGE_ASSET';
  G_LEASE_SCS_CODE     OKC_K_HEADERS_V.SCS_CODE%TYPE   := 'LEASE';
  G_LOAN_SCS_CODE      OKC_K_HEADERS_V.SCS_CODE%TYPE   := 'LOAN';
  G_TLS_TYPE           OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';


  -- RMUNJULU -- 04-DEC-02 Bug # 2484327
  -- Added these constants for better performance
  G_RET_STS_SUCCESS       CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR         CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  G_APP_NAME_1            CONSTANT VARCHAR2(200) := OKC_API.G_APP_NAME;



  -- RMUNJULU -- 04-DEC-02 Bug # 2484327
  -- Taken these out from package body to spec
  G_AM_ERR_TRMT_ASSET      VARCHAR2(200) := 'OKL_AM_ERR_TRMT_ASSET';
  G_AM_ERR_TRMT_ASSET_LN   VARCHAR2(200) := 'OKL_AM_ERR_TRMT_ASSET_LN';
  G_AM_ERR_TRMT_TOP_LN     VARCHAR2(200) := 'OKL_AM_ERR_TRMT_TOP_LN';
  G_AM_ERR_UPD_AMT         VARCHAR2(200) := 'OKL_AM_ERR_UPD_AMT';
  G_AM_ERR_UPD_PAY_AMT     VARCHAR2(200) := 'OKL_AM_ERR_UPD_PAY_AMT';
  G_AM_ASSET_TRMT          VARCHAR2(200) := 'OKL_AM_ASSET_TRMT';
  G_AM_SERVICE_TRMT        VARCHAR2(200) := 'OKL_AM_SERVICE_TRMT';
  G_AM_FEE_TRMT            VARCHAR2(200) := 'OKL_AM_FEE_TRMT';
  G_AM_USAGE_TRMT          VARCHAR2(200) := 'OKL_AM_USAGE_TRMT';

  -- RMUNJULU -- 04-DEC-02 Bug # 2484327
  -- Added
  G_AM_K_STATUS_UPD        VARCHAR2(200) := 'OKL_AM_K_STATUS_UPD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION     EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION     EXCEPTION;


  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE term_rec_type  IS OKL_AM_LEASE_LOAN_TRMNT_PUB.term_rec_type;
  SUBTYPE tcnv_rec_type  IS OKL_AM_LEASE_LOAN_TRMNT_PUB.tcnv_rec_type;
  SUBTYPE stmv_tbl_type  IS OKL_STREAMS_PUB.stmv_tbl_type;


  -- RMUNJULU -- Bug # 2484327 16-DEC-02 Added columns to rec type
  TYPE klev_rec_type IS RECORD (
           p_kle_id         NUMBER,
           p_asset_quantity NUMBER,
           p_asset_name     VARCHAR2(2000),
           p_quote_quantity NUMBER,
           p_tql_id         NUMBER,
           p_split_kle_id   NUMBER,
           p_split_kle_name VARCHAR2(150)); -- RMUNJULU 2757312 Added


  TYPE klev_tbl_type IS TABLE OF klev_rec_type INDEX BY BINARY_INTEGER;


  TYPE g_cle_amt_rec IS RECORD (
           cle_id      NUMBER := G_MISS_NUM,
           amount      NUMBER := G_MISS_NUM);


  TYPE g_cle_amt_tbl IS TABLE OF g_cle_amt_rec INDEX BY BINARY_INTEGER;


  -- RMUNJULU -- 04-DEC-02 Bug # 2484327
  -- Taken these out from package body to spec
  TYPE g_msg_rec IS RECORD (
               msg_token1        VARCHAR2(200),
               msg_token1_value  VARCHAR2(200),
               msg_token2        VARCHAR2(200),
               msg_token2_value  VARCHAR2(200),
               msg_desc          FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE);

  TYPE g_msg_tbl IS TABLE OF g_msg_rec INDEX BY BINARY_INTEGER;



  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  PROCEDURE set_database_values(
                  px_term_rec        IN OUT NOCOPY term_rec_type);


  PROCEDURE set_info_messages(
                  p_term_rec         IN term_rec_type);


  PROCEDURE set_overall_status(
                  p_return_status    IN VARCHAR2,
                  px_overall_status  IN OUT NOCOPY VARCHAR2);


  PROCEDURE initialize_transaction (
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_control_flag     IN  VARCHAR2,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type,
                  x_return_status    OUT NOCOPY VARCHAR2);


  PROCEDURE set_transaction_rec(
                  p_return_status    IN VARCHAR2 DEFAULT G_MISS_CHAR,
                  p_overall_status   IN VARCHAR2 DEFAULT G_MISS_CHAR,
                  p_tmt_flag         IN VARCHAR2 DEFAULT G_MISS_CHAR,
                  p_tsu_code         IN VARCHAR2 DEFAULT G_MISS_CHAR,
                  p_ret_val          IN VARCHAR2 DEFAULT G_MISS_CHAR,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type);


  PROCEDURE process_transaction(
                  p_id               IN NUMBER,
                  p_term_rec         IN term_rec_type,
                  p_tcnv_rec         IN tcnv_rec_type,
                  p_trn_mode         IN VARCHAR2,
                  x_id               OUT NOCOPY NUMBER,
                  x_return_status    OUT NOCOPY VARCHAR2);


  PROCEDURE get_lines(
                  p_term_rec         IN  term_rec_type,
                  x_klev_tbl         OUT NOCOPY klev_tbl_type,
                  x_return_status    OUT NOCOPY VARCHAR2);


  PROCEDURE validate_contract_and_lines(
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  x_return_status    OUT NOCOPY VARCHAR2);


  PROCEDURE split_asset(
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  p_trn_already_set  IN  VARCHAR2,
                  px_overall_status  IN OUT NOCOPY VARCHAR2,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type,
                  x_klev_tbl         OUT NOCOPY  klev_tbl_type,
                  x_return_status    OUT NOCOPY VARCHAR2);



  PROCEDURE close_streams(
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  p_trn_already_set  IN  VARCHAR2,
                  px_overall_status  IN OUT NOCOPY VARCHAR2,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type,
                  x_return_status    OUT NOCOPY VARCHAR2);


  PROCEDURE accounting_entries(
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  p_trn_already_set  IN  VARCHAR2,
                  px_overall_status  IN OUT NOCOPY VARCHAR2,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type,
                  x_return_status    OUT NOCOPY VARCHAR2);


  PROCEDURE dispose_assets(
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  p_trn_already_set  IN  VARCHAR2,
                  px_overall_status  IN OUT NOCOPY VARCHAR2,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type,
                  x_return_status    OUT NOCOPY VARCHAR2);


  PROCEDURE amortize_assets(
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  p_trn_already_set  IN  VARCHAR2,
                  px_overall_status  IN OUT NOCOPY VARCHAR2,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type,
                  x_return_status    OUT NOCOPY VARCHAR2);


  PROCEDURE return_assets(
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  p_trn_already_set  IN  VARCHAR2,
                  px_overall_status  IN OUT NOCOPY VARCHAR2,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type,
                  x_return_status    OUT NOCOPY VARCHAR2);


  -- RMUNJULU 03-JAN-03 2683876 Added close balances
  PROCEDURE close_balances(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_tcnv_rec         IN  tcnv_rec_type,
                  px_msg_tbl         IN OUT NOCOPY g_msg_tbl);


  PROCEDURE mass_rebook(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2 DEFAULT G_FALSE,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  p_term_rec         IN  term_rec_type,
                  p_tcnv_rec         IN  tcnv_rec_type,
                  p_sys_date         IN  DATE, -- rmunjulu EDAT
                  x_mrbk_success     OUT NOCOPY VARCHAR2); -- RMUNJULU CONTRACT BLOCKING ADDED



  PROCEDURE cancel_activate_insurance(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2 DEFAULT G_FALSE,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type);


  -- RMUNJULU -- 20-DEC-02 2484327
  -- Added this proc,used to cancel all insurances when all lines terminated
  PROCEDURE cancel_insurance(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type);


  -- RMUNJULU 09-JAN-03  2743604
  -- Added this proc,used to reverse loss provisions when all lines terminated
  PROCEDURE reverse_loss_provisions(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  px_msg_tbl         IN OUT NOCOPY g_msg_tbl);


  -- RMUNJULU -- 04-DEC-02 Bug # 2484327
  -- Added p_trn_reason_code and x_msg_tbl parameters
  -- BAKUCHIB 28-MAR-03 2877278 Added new parameter
  PROCEDURE update_lines(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2 DEFAULT G_FALSE,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  p_status           IN  VARCHAR2,
                  p_trn_reason_code  IN  VARCHAR2,
                  x_klev_tbl         OUT NOCOPY klev_tbl_type, -- BAKUCHIB 28-MAR-03 2877278 Added
                  x_msg_tbl          OUT NOCOPY g_msg_tbl);


  -- RMUNJULU -- 04-DEC-02 Bug # 2484327
  -- Added the specification to this new procedure which will be used to
  -- terminate contract if all lines terminated
  PROCEDURE update_contract(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_status           IN  VARCHAR2,
                  p_trn_reason_code  IN  VARCHAR2,
                  px_msg_tbl         IN OUT NOCOPY g_msg_tbl);


  PROCEDURE terminate_lines(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2 DEFAULT G_FALSE,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  px_overall_status  IN OUT NOCOPY VARCHAR2,
                  p_trn_already_set  IN  VARCHAR2, -- RMUNJULU CONTRACT BLOCKING
                  p_term_rec         IN  term_rec_type,
                  p_sys_date         IN  DATE,
                  p_klev_tbl         IN  klev_tbl_type,
                  p_status           IN  VARCHAR2,
                  px_tcnv_rec        IN OUT NOCOPY tcnv_rec_type);



  PROCEDURE asset_level_termination(
                  p_api_version      IN  NUMBER,
                  p_init_msg_list    IN  VARCHAR2 DEFAULT G_FALSE,
                  p_term_rec         IN  term_rec_type,
                  p_tcnv_rec         IN  tcnv_rec_type,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  x_return_status    OUT NOCOPY VARCHAR2);



END OKL_AM_CNTRCT_LN_TRMNT_PVT;

 

/
