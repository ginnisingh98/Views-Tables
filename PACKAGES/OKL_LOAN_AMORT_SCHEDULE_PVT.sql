--------------------------------------------------------
--  DDL for Package OKL_LOAN_AMORT_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LOAN_AMORT_SCHEDULE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLASS.pls 120.3 2008/02/09 00:11:48 sechawla noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LOAN_AMORT_SCHEDULE_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 G_REPORT_TYPE_SUMMARY  CONSTANT VARCHAR2(30) := 'SUMMARY';
 G_REPORT_TYPE_DETAIL   CONSTANT VARCHAR2(30) := 'DETAIL';

 G_RRM_ACTUAL               CONSTANT VARCHAR2(30) := 'ACTUAL';
 G_RRM_STREAMS              CONSTANT VARCHAR2(30) := 'STREAMS';
 G_RRM_ESTIMATED_AND_BILLED CONSTANT VARCHAR2(30) := 'ESTIMATED_AND_BILLED';

 G_ICB_FIXED                CONSTANT VARCHAR2(30) := 'FIXED';
 G_ICB_FLOAT                CONSTANT VARCHAR2(30) := 'FLOAT';
 G_ICB_REAMORT              CONSTANT VARCHAR2(30) := 'REAMORT';
 G_ICB_CATCHUP_CLEANUP      CONSTANT VARCHAR2(30) := 'CATCHUP/CLEANUP';

 G_BILLED                   CONSTANT VARCHAR2(30) := 'B';
 G_RECEIVED                 CONSTANT VARCHAR2(30) := 'R';
 G_PROJECTED                CONSTANT VARCHAR2(30) := 'P';
 G_REBOOK                   CONSTANT VARCHAR2(30) := 'RBK';
 G_PPD                      CONSTANT VARCHAR2(30) := 'PPD';

 ------------------------------------------------------------------------------
 -- Record Type
 ------------------------------------------------------------------------------

  TYPE amort_sched_rec_type IS RECORD (
    start_date         DATE,
    end_date           DATE,
    loan_payment       NUMBER,
    principal          NUMBER,
    interest           NUMBER,
    principal_balance  NUMBER,
    payment_type       VARCHAR2(30)
  );

  TYPE amort_sched_tbl_type is table of amort_sched_rec_type INDEX BY BINARY_INTEGER;

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

  -- Start of comments
  --
  -- API name       : load_ln_actual_dtl
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Detail report
  --                  based on all receipts that have been processed by the Daily
  --                  Interest Program and projected payments for the remaining
  --                  loan term for the input contract. This schedule applies
  --                  to Loans with Revenue Recognition - ACTUAL
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_actual_dtl(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_proj_interest_rate         OUT NOCOPY NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);

  -- Start of comments
  -- API name       : load_ln_actual_summ
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Summary report
  --                  based on all receipts that have been processed by the Daily
  --                  Interest Program and projected payments for the remaining
  --                  loan term for the input contract. This schedule applies
  --                  to Loans with Revenue Recognition - ACTUAL
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_actual_summ(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_proj_interest_rate         OUT NOCOPY NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);

 -- Start of comments
  --
  -- API name       : load_ln_streams_dtl
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Detail report- both past and projected,
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested
  --                  This schedule applies to Loans with Interest Calculation Basis = FIXED' or 'REAMORT' and
  --                  Revenue Recognition - STREAMS
  --
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  --
  -- Version        : 1.0
  -- History        : sechawla created.
  -- End of comments

  PROCEDURE load_ln_streams_dtl(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);

  -- Start of comments
  -- API name       : load_ln_streams_summ
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Summary report- both past and projected,
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested
  --                  This schedule applies to Loans with Interest Calculation Basis = FIXED' or 'REAMORT' and
  --                  Revenue Recognition - STREAMS
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : sechawla created.
  -- End of comments

  PROCEDURE load_ln_streams_summ(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);


  -- Start of comments
  --
  -- API name       : load_ln_float_eb_dtl
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Detail report
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested.
  --                  This schedule applies to Loans with Interest Calculation Basis - FLOAT and
  --                  Revenue Recognition - ESTIMATED_AND_BILLED
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_float_eb_dtl(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);

  -- Start of comments
  --
  -- API name       : load_ln_float_eb_summ
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Summary report
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested.
  --                  This schedule applies to Loans with Interest Calculation Basis - FLOAT and
  --                  Revenue Recognition - ESTIMATED_AND_BILLED
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_float_eb_summ(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);

  -- Start of comments
  --
  -- API name       : load_ln_cc_strm_dtl
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Detail report
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested.
  --                  This schedule applies to Loans with Interest Calculation Basis -
  --                  CATCHUP/CLEANUP and Revenue Recognition - STREAMS
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_cc_strm_dtl(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);

  -- Start of comments
  --
  -- API name       : load_ln_cc_strm_summ
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Summary report
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested.
  --                  This schedule applies to Loans with Interest Calculation Basis -
  --                  CATCHUP/CLEANUP and Revenue Recognition - STREAMS
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_cc_strm_summ(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);

  -- Start of comments
  -- API name       : load_loan_amort_schedule
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule
  --                  for the input contract based on its Loan Product
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_loan_amort_schedule(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      p_report_type                IN  VARCHAR2,
      x_proj_interest_rate         OUT NOCOPY NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type);

END OKL_LOAN_AMORT_SCHEDULE_PVT;

/
