--------------------------------------------------------
--  DDL for Package OKL_LOSS_PROV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LOSS_PROV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLPVS.pls 120.7 2006/07/11 09:50:42 dkagrawa noship $ */

  -- Bug 4110239. sty_id is not supported from 11.5.10+ version
  -- Removing sty_id parameter as API is not published
  TYPE glpv_rec_type IS RECORD (
    product_id                    OKL_TRX_CONTRACTS.PDT_ID%TYPE,
    --sty_id                        OKL_STRM_TYPE_V.ID%TYPE,
    bucket_id                     OKX_AGING_BUCKETS_V.AGING_BUCKET_ID%TYPE,
    entry_date                    DATE,
    tax_deductible_local          OKL_TRX_CONTRACTS.TAX_DEDUCTIBLE_LOCAL%TYPE,
    tax_deductible_corporate      OKL_TRX_CONTRACTS.TAX_DEDUCTIBLE_CORPORATE%TYPE,
	description                   OKL_TRX_CONTRACTS.DESCRIPTION%TYPE);


  TYPE slpv_rec_type IS RECORD (
    khr_id                        OKL_K_HEADERS.ID%TYPE,
    sty_id                        OKL_STRM_TYPE_V.ID%TYPE,
    amount                        OKL_TRX_CONTRACTS.AMOUNT%TYPE,
    description                   OKL_TRX_CONTRACTS.DESCRIPTION%TYPE,
    reverse_flag                  VARCHAR2(1),
    tax_deductible_local          OKL_TRX_CONTRACTS.TAX_DEDUCTIBLE_LOCAL%TYPE,
    tax_deductible_corporate      OKL_TRX_CONTRACTS.TAX_DEDUCTIBLE_CORPORATE%TYPE,
    provision_date                OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE);


  TYPE bktv_rec_type IS RECORD (
    aging_bucket_line_id   OKX_AGING_BUCKETS_V.aging_bucket_line_id%TYPE
   ,bkt_id                 OKL_BUCKETS_V.ID%TYPE
   ,loss_rate              OKL_BUCKETS_V.LOSS_RATE%TYPE
   ,bucket_name            OKX_AGING_BUCKETS_V.bucket_name%TYPE
   ,days_start             OKX_AGING_BUCKETS_V.days_start%TYPE
   ,days_to                OKX_AGING_BUCKETS_V.days_to%TYPE
   ,loss_amount            OKL_TXL_CNTRCT_LNS.amount%TYPE);

  TYPE bucket_tbl_type IS TABLE OF bktv_rec_type INDEX BY BINARY_INTEGER;
  TYPE slpv_tbl_type IS TABLE OF slpv_rec_type INDEX BY BINARY_INTEGER;


 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME                CONSTANT VARCHAR2(2000) := 'OKL_LOSS_PROV_PVT';
 G_APP_NAME                CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_NO_DATA_FOUND           CONSTANT VARCHAR2(2000) := 'OKL_NOT_FOUND';
 G_COL_NAME_TOKEN          CONSTANT  VARCHAR2(2000) := OKL_API.G_COL_NAME_TOKEN;
 G_UNEXPECTED_ERROR        CONSTANT  VARCHAR2(2000) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN           CONSTANT  VARCHAR2(2000) := 'SQLerrm';
 G_SQLCODE_TOKEN           CONSTANT  VARCHAR2(2000) := 'SQLcode';
 G_REQUIRED_VALUE          CONSTANT  VARCHAR2(2000) := 'OKL_REQUIRED_VALUE';
 G_NO_MATCHING_RECORD      CONSTANT  VARCHAR2(2000) := 'OKL_LLA_NO_MATCHING_RECORD';
 G_CONTRACT_NUMBER_TOKEN   CONSTANT VARCHAR2(2000) := 'CONTRACT_NUMBER';
 G_INVALID_VALUE           CONSTANT  VARCHAR2(2000) := 'OKL_CONTRACTS_INVALID_VALUE';
 G_STREAM_NAME_TOKEN       CONSTANT VARCHAR2(2000) := 'STREAM_NAME';
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 -- Global Exception
 G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  -- this function is used to calculate total reserve amt for a contract
  FUNCTION calculate_cntrct_rsrv_amt (
        p_cntrct_id       IN  NUMBER) RETURN NUMBER;

  -- this function is used to calculate capital balance for a contract and deal type
  FUNCTION calculate_capital_balance(p_cntrct_id IN  NUMBER
                                ,p_deal_type IN VARCHAR2) RETURN NUMBER;

  -- this function submits the general loss concurrent program
  FUNCTION SUBMIT_GENERAL_LOSS(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_glpv_rec IN glpv_rec_type
 ) RETURN NUMBER;


   -- this procedure is used create a transaction for specific loss provision
  PROCEDURE SPECIFIC_LOSS_PROVISION (
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_slpv_rec             IN slpv_rec_type);

  -- this program is used create a transaction for general loss provision
  -- Bug 4110239. p_sty_id is not supported from 11.5.10+ version
  -- Removing p_sty_id parameter as API is not published.
  PROCEDURE GENERAL_LOSS_PROVISION ( errbuf OUT NOCOPY VARCHAR2
                                    ,retcode OUT NOCOPY NUMBER
                                    ,p_product_id IN  VARCHAR2
									--,p_sty_id IN  VARCHAR2
									,p_bucket_id IN  VARCHAR2
									,p_entry_date IN  VARCHAR2
									,p_tax_deductible_local IN  VARCHAR2
									,p_tax_deductible_corporate IN VARCHAR2
									,p_description IN VARCHAR2);

End OKL_LOSS_PROV_PVT;

/
