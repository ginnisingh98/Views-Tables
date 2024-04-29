--------------------------------------------------------
--  DDL for Package OKL_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PRICING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPIGS.pls 120.9.12010000.2 2009/06/02 10:46:02 racheruv ship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_PRICING_PVT';

  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_FALSE                CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------

  TYPE interim_interest_rec_type IS RECORD (cf_days NUMBER, cf_amount NUMBER, cf_dpp NUMBER);
  TYPE interim_interest_tbl_type IS TABLE OF interim_interest_rec_type INDEX BY BINARY_INTEGER;

  TYPE payment_rec_type IS RECORD (sll_id     NUMBER,
                                   start_date DATE,
                                   periods    NUMBER,
                                   frequency  VARCHAR2(1),
                                   structure  VARCHAR2(1),
                                   arrears_yn VARCHAR2(1),
                                   amount     NUMBER,
                                   stub_days  NUMBER,
                                   stub_amount NUMBER,
                                   rate       NUMBER,
                                   ratio      NUMBER);



  TYPE payment_tbl_type IS TABLE OF payment_rec_type INDEX BY BINARY_INTEGER;

  TYPE cash_flow_rec IS RECORD (cf_days NUMBER,
                                cf_date DATE,
                                cf_amount NUMBER,
                                cf_ratio NUMBER);



  TYPE cash_flow_tbl_type IS TABLE OF cash_flow_rec INDEX BY BINARY_INTEGER;



  PROCEDURE get_quote_amortization(p_khr_id              IN  NUMBER,
                                   p_kle_id              IN  NUMBER,
                                   p_investment          IN  NUMBER,
                                   p_residual_value      IN  NUMBER,
                                   p_start_date          IN  DATE,
                                   p_asset_start_date    IN  DATE,
                                   p_term_duration       IN  NUMBER,
                                   x_principal_tbl       OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_interest_tbl        OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_prin_bal_tbl        OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_termination_tbl     OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_pre_tax_inc_tbl     OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_interim_interest    OUT NOCOPY NUMBER,
                                   x_interim_days        OUT NOCOPY NUMBER,
                                   x_interim_dpp         OUT NOCOPY NUMBER,
                                   x_iir                 OUT NOCOPY NUMBER,
                                   x_booking_yield       OUT NOCOPY NUMBER,
                                   x_return_status       OUT NOCOPY VARCHAR2);

   -- Bug 6748547 : Loan Amortization schedule feature : Begin

  TYPE schedule_rec IS RECORD
  (
     schedule_date        date,
     schedule_principal   number,
     schedule_interest    number,
     schedule_prin_bal    number
  );

  TYPE schedule_table_type IS TABLE OF schedule_rec INDEX BY BINARY_INTEGER;

   -- Bug 6748547 : Loan Amortization schedule feature : End
  -- Added input parameter p_se_id by prasjain for bug 5474827
  PROCEDURE get_loan_amortization (p_khr_id              IN  NUMBER,
                                   p_kle_id              IN  NUMBER,
                                   p_purpose_code        IN  VARCHAR2,
                                   p_investment          IN  NUMBER,
                                   p_residual_value      IN  NUMBER,
                                   p_start_date          IN  DATE,
                                   p_asset_start_date    IN  DATE,
                                   p_term_duration       IN  NUMBER,
                                   p_currency_code       IN  VARCHAR2,  --USED?
                                   p_deal_type           IN  VARCHAR2,  --USED?
                                   p_asset_iir_guess     IN  NUMBER DEFAULT NULL,
                                   p_bkg_yield_guess     IN  NUMBER DEFAULT NULL,
                                   x_principal_tbl       OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_interest_tbl        OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_prin_bal_tbl        OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_termination_tbl     OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_pre_tax_inc_tbl     OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_interim_interest    OUT NOCOPY NUMBER,
                                   x_interim_days        OUT NOCOPY NUMBER,
                                   x_interim_dpp         OUT NOCOPY NUMBER,
                                   x_iir                 OUT NOCOPY NUMBER,
                                   x_booking_yield       OUT NOCOPY NUMBER,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   p_se_id               IN  NUMBER
                                   -- Params added for Prospective Rebooking
                                  ,p_during_rebook_yn    IN  VARCHAR2
                                  ,p_rebook_type         IN  VARCHAR2
                                  ,p_prosp_rebook_flag   IN  VARCHAR2
                                  ,p_rebook_date         IN  DATE
                                  ,p_income_strm_sty_id  IN  NUMBER
  );

  PROCEDURE  compute_iir (p_khr_id          IN  NUMBER,
                          p_start_date      IN  DATE,
                          p_term_duration   IN  NUMBER,
                          p_interim_tbl     IN  interim_interest_tbl_type,
			  p_subsidies_yn    IN  VARCHAR2,
			  p_initial_iir      IN  NUMBER DEFAULT NULL,
                          x_iir             OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2);

  PROCEDURE  compute_irr (p_khr_id          IN  NUMBER,
                          p_start_date      IN  DATE,
                          p_term_duration   IN  NUMBER,
                          p_interim_tbl     IN  interim_interest_tbl_type,
			  p_subsidies_yn    IN  VARCHAR2,
			  -- Added parameter for accepting approximation.
			  p_initial_irr     IN  NUMBER,   -- Added by RGOOTY
                          x_irr             OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2);

  PROCEDURE  get_rate(p_khr_id          IN  NUMBER,
                      p_date            IN  DATE,
                      x_rate            OUT NOCOPY NUMBER,
                      x_return_status   OUT NOCOPY VARCHAR2);

  PROCEDURE  target_pay_down(
                          p_khr_id          IN  NUMBER,
                          p_kle_id          IN  NUMBER,
                          p_ppd_date        IN  DATE,
                          p_ppd_amount      IN  NUMBER,
                          p_iir             IN  NUMBER,
                          x_payment_amount  OUT NOCOPY NUMBER,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2);

  PROCEDURE target_pay_down (
                          p_khr_id          IN  NUMBER,
                          p_ppd_date        IN  DATE,
                          p_ppd_amount      IN  NUMBER,
                          p_pay_start_date  IN  DATE,
                          p_iir             IN  NUMBER,
			  p_term            IN  NUMBER,
			  p_frequency       IN  VARCHAR2,
			  p_arrears_yn      IN  VARCHAR2,
                          x_pay_amount      OUT NOCOPY NUMBER,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2);

   PROCEDURE compute_rates(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          p_khr_id        IN  NUMBER,
                          p_kle_id        IN  NUMBER,
			  p_pay_tbl       IN  OKL_STREAM_GENERATOR_PVT.payment_tbl_type,
			  x_rates         OUT NOCOPY OKL_STREAM_GENERATOR_PVT.rate_rec_type,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2);


   PROCEDURE target_parameter(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          p_khr_id        IN  NUMBER,
                          p_kle_id        IN  NUMBER,
                          p_rate_type     IN  VARCHAR2,
			  p_target_param  IN  VARCHAR2,
			  p_pay_tbl       IN  OKL_STREAM_GENERATOR_PVT.payment_tbl_type,
			  x_pay_tbl       OUT NOCOPY OKL_STREAM_GENERATOR_PVT.payment_tbl_type,
			  x_overall_rate  OUT NOCOPY NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2);


      PROCEDURE get_payment_after_ppd(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_khr_id         IN  NUMBER,
            p_kle_id         IN  NUMBER,
            p_ppd_amt        IN  NUMBER,
            p_rate           IN  NUMBER,
            p_ppd_date       IN  DATE,
            p_pay_level      IN  payment_tbl_type,
            x_pay_level      OUT NOCOPY payment_tbl_type);

   -- Bug 6748547 : Loan Amortization schedule feature : Begin
   PROCEDURE generate_loan_schedules (p_khr_id              IN  NUMBER,
                                      p_investment          IN  NUMBER,
                                      p_start_date          IN  DATE,
                                      x_interest_rate       OUT NOCOPY  NUMBER,
                                      x_schedule_table      OUT NOCOPY  schedule_table_type,
                                      x_return_status       OUT NOCOPY VARCHAR2);

   PROCEDURE print(p_progname IN VARCHAR2,p_message  IN  VARCHAR2);
   -- Bug 6748547 : Loan Amortization schedule feature : End


END OKL_PRICING_PVT;

/
