--------------------------------------------------------
--  DDL for Package OKL_STREAM_GENERATOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAM_GENERATOR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSGPS.pls 120.17.12010000.2 2009/08/14 05:23:52 sechawla ship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_STREAM_GENERATOR_PVT';

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

  TYPE cash_flow_rec IS RECORD (cf_date DATE, cf_amount NUMBER, cf_frequency VARCHAR2(1));
  TYPE cash_flow_tbl IS TABLE OF cash_flow_rec INDEX BY BINARY_INTEGER;

  TYPE payment_rec_type IS RECORD (sll_id     NUMBER,
                                   start_date DATE,
                                   periods    NUMBER,
				   frequency  VARCHAR2(1),
				   structure  VARCHAR2(1),
				   arrears_yn VARCHAR2(1),
				   amount     NUMBER,
				   stub_days  NUMBER,
				   stub_amount NUMBER,
				   rate       NUMBER);

  TYPE payment_tbl_type IS TABLE OF payment_rec_type INDEX BY BINARY_INTEGER;

  TYPE rate_rec_type IS RECORD ( PRE_TAX_IRR            NUMBER,
                                 IMPLICIT_INTEREST_RATE NUMBER,
                                 SUB_IMPL_INTEREST_RATE NUMBER,
                                 SUB_PRE_TAX_IRR        NUMBER,
				 SUB_PRE_TAX_YIELD      NUMBER,
				 PRE_TAX_YIELD          NUMBER);

    CURSOR top_svc_csr ( chrId NUMBER, linkId NUMBER ) IS
    select to_char(kle1.id) top_svc_id,
           kle1.amount top_amount,
	   kle.amount link_amount
    from  okl_k_lines_full_v kle,
          okl_k_lines_full_v kle1,
          okc_line_styles_b lse,
          okc_statuses_b sts
    where KLE1.LSE_ID = LSE.ID
      and ((lse.lty_code  = 'SOLD_SERVICE') OR (lse.lty_code = 'FEE'and kle1.fee_type ='PASSTHROUGH')) -- linked fees on passthrus.
      and kle.dnz_chr_id = chrId
      and kle1.dnz_chr_id = kle.dnz_chr_id
      and sts.code = kle1.sts_code
      and kle.id = linkId
      and kle.cle_id = kle1.id
      and sts.ste_code not in ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------
  -- Bug 4590581: Start
  FUNCTION get_months_factor( p_frequency     IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2)
    RETURN NUMBER;

  PROCEDURE add_months_new( p_start_date     IN  DATE,
                            p_months_after   IN  NUMBER,
                            x_date           OUT NOCOPY DATE,
                            x_return_status  OUT NOCOPY VARCHAR2);

 --Added parameter p_recurrence_date by djanaswa for bug 6007644
 -- Added parameter p_arrears_pay_dates_option DJANASWA ER6274342
  PROCEDURE get_sel_date( p_start_date         IN  DATE,
                          p_advance_or_arrears IN  VARCHAR2,
                          p_periods_after      IN  NUMBER,
                          p_months_per_period  IN  NUMBER,
                          x_date               OUT NOCOPY DATE,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          p_recurrence_date    IN  DATE,
                          p_arrears_pay_dates_option IN VARCHAR2 DEFAULT 'LAST_DAY_OF_PERIOD');
    -- Bug 4590581: End

  PROCEDURE get_sty_details (p_sty_id        IN  NUMBER   DEFAULT NULL,
                             p_sty_name      IN  VARCHAR2 DEFAULT NULL,
                             x_sty_id        OUT NOCOPY NUMBER,
                             x_sty_name      OUT NOCOPY VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2);

  FUNCTION get_day_count (p_start_date     IN   DATE,
                          p_end_date        IN   DATE,
                          p_arrears        IN   VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2) RETURN NUMBER;

  PROCEDURE get_stream_header(p_purpose_code   IN  VARCHAR2,
                              p_khr_id         IN  NUMBER,
                              p_kle_id         IN  NUMBER,
                              p_sty_id         IN  NUMBER,
                              x_stmv_rec       OUT NOCOPY okl_stm_pvt.stmv_rec_type,
                              x_return_status  OUT NOCOPY VARCHAR2);

--Added parameter p_recurrence_date by djanaswa for bug 6007644
  PROCEDURE get_stream_elements( p_start_date          IN      DATE,
                                 p_periods             IN      NUMBER,
                                 p_frequency           IN      VARCHAR2,
                                 p_structure           IN      VARCHAR2,
                                 p_advance_or_arrears  IN      VARCHAR2,
                                 p_amount              IN      NUMBER,
                                 p_stub_days           IN      NUMBER,
                                 p_stub_amount         IN      NUMBER,
                                 p_currency_code       IN      VARCHAR2,
                                 p_khr_id              IN      NUMBER,
                                 p_kle_id              IN      NUMBER,
                                 p_purpose_code        IN      VARCHAR2,
                                 x_selv_tbl            OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_pt_tbl              OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2,
                                 p_recurrence_date    IN  DATE);

  -- gboomina Bug 4746189 - Added - Start
--Added parameter p_recurrence_date by djanaswa for bug 6007644
  PROCEDURE get_stream_elements( p_start_date          IN      DATE,
                                 p_periods             IN      NUMBER,
                                 p_frequency           IN      VARCHAR2,
                                 p_structure           IN      VARCHAR2,
                                 p_advance_or_arrears  IN      VARCHAR2,
                                 p_amount              IN      NUMBER,
                                 p_stub_days           IN      NUMBER,
                                 p_stub_amount         IN      NUMBER,
                                 p_currency_code       IN      VARCHAR2,
                                 p_khr_id              IN      NUMBER,
                                 p_kle_id              IN      NUMBER,
                                 p_purpose_code        IN      VARCHAR2,
                                 x_selv_tbl            OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_pt_tbl              OUT NOCOPY okl_sel_pvt.selv_tbl_type,
				 x_pt_pro_fee_tbl      OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2,
                                 p_recurrence_date    IN  DATE);
  -- gboomina Bug 4746189 - Added - End

  PROCEDURE get_accrual_elements (p_start_date          IN         DATE,
                                  p_periods             IN         NUMBER,
                                  p_frequency           IN         VARCHAR2,
                                  p_structure           IN         NUMBER,
                                  p_advance_or_arrears  IN         VARCHAR2,
                                  p_amount              IN         NUMBER,
                                  p_stub_days           IN      NUMBER,
                                  p_stub_amount         IN      NUMBER,
                                  p_currency_code       IN         VARCHAR2,
                                  p_day_convention_month    IN VARCHAR2 DEFAULT '30',
                             			  p_day_convention_year    IN VARCHAR2 DEFAULT '360',
                                  x_selv_tbl            OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                  x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE  generate_cash_flows(
                             p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             p_khr_id        IN  NUMBER,
                      	      p_kle_id        IN  NUMBER,
                     			     p_sty_id        IN  NUMBER,
                     			     p_payment_tbl   IN  payment_tbl_type,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             x_payment_count OUT NOCOPY BINARY_INTEGER);

  -- Added output parameter x_se_id by prasjain for bug 5474827
  PROCEDURE generate_cash_flows( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
                              p_generation_type            IN         VARCHAR2,
                              p_reporting_book_class       IN         VARCHAR2,
                              x_payment_count              OUT NOCOPY BINARY_INTEGER,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2,
			      x_se_id                      OUT NOCOPY NUMBER);

  PROCEDURE generate_streams( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
                              p_compute_rates              IN         VARCHAR2,
                              p_generation_type            IN         VARCHAR2,
                              p_reporting_book_class       IN         VARCHAR2,
                              x_contract_rates             OUT NOCOPY rate_rec_type,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2);

  PROCEDURE generate_streams( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
                              p_compute_irr                IN         VARCHAR2,
                              p_generation_type            IN         VARCHAR2,
                              p_reporting_book_class       IN         VARCHAR2,
                              x_pre_tax_irr                OUT NOCOPY NUMBER,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2);

  PROCEDURE  GEN_VAR_INT_SCHEDULE( p_api_version         IN      NUMBER,
                                   p_init_msg_list       IN      VARCHAR2,
                                   p_khr_id              IN      NUMBER,
                                   p_purpose_code        IN      VARCHAR2,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                                   x_msg_data            OUT NOCOPY VARCHAR2);

   PROCEDURE  create_pv_streams(p_api_version      IN      NUMBER,
                                       p_init_msg_list       IN      VARCHAR2,
                                       p_agreement_id        IN      NUMBER,
                                       p_pool_status         IN      VARCHAR2 DEFAULT 'NEW',
/* sosharma 14-12-2007 , added for passing mode as Pending
for contents added on active pool*/
                                       p_mode                IN      VARCHAR2 DEFAULT NULL,
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2);

   PROCEDURE  create_pv_streams(p_api_version     IN      NUMBER,
                                       p_init_msg_list      IN      VARCHAR2,
                                       p_contract_id        IN      NUMBER,
                                       p_pool_status        IN      VARCHAR2 DEFAULT 'ACTIVE',
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2);


   PROCEDURE  create_disb_streams(p_api_version      IN      NUMBER,
                                       p_init_msg_list       IN      VARCHAR2,
                                       p_agreement_id        IN      NUMBER,
                                       p_pool_status         IN      VARCHAR2 DEFAULT 'NEW',
/* sosharma 14-12-2007 , added for passing mode as Pending
for contents added on active pool*/
                                       p_mode                IN      VARCHAR2 DEFAULT NULL,
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2);

   PROCEDURE  create_disb_streams(p_api_version     IN      NUMBER,
                                       p_init_msg_list      IN      VARCHAR2,
                                       p_contract_id        IN      NUMBER,
                                       p_pool_status        IN      VARCHAR2 DEFAULT 'ACTIVE',
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2);

  PROCEDURE  get_sched_principal_bal( p_api_version         IN      NUMBER,
                                    p_init_msg_list       IN      VARCHAR2,
                                    p_khr_id              IN      NUMBER,
                                    p_kle_id              IN      NUMBER DEFAULT NULL,
                                    p_date                IN      DATE,
                                    x_principal_balance   OUT NOCOPY NUMBER,
                               	    x_accumulated_int     OUT NOCOPY NUMBER,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2);


  PROCEDURE get_next_billing_date( p_api_version            IN NUMBER,
                                   p_init_msg_list          IN VARCHAR2,
                                   p_khr_id                 IN NUMBER,
                                   p_billing_date           IN DATE DEFAULT NULL,
                                   x_next_due_date          OUT NOCOPY DATE,
                                   x_next_period_start_date OUT NOCOPY DATE,
                                   x_next_period_end_date   OUT NOCOPY  DATE,
                                   x_return_status          OUT NOCOPY VARCHAR2,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2);


  PROCEDURE get_present_value(     p_api_version            IN NUMBER,
                                   p_init_msg_list          IN VARCHAR2,
                            				   p_amount_date            IN DATE,
                            				   p_amount                 IN NUMBER,
                            				   p_frequency              IN VARCHAR2 DEFAULT 'M',
                            				   p_rate                   IN NUMBER,
                                   p_pv_date                IN DATE,
                                   p_day_convention_month    IN VARCHAR2 DEFAULT '30',
                            				   p_day_convention_year    IN VARCHAR2 DEFAULT '360',
                               	   x_pv_amount              OUT NOCOPY NUMBER,
                                   x_return_status          OUT NOCOPY VARCHAR2,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2);

  PROCEDURE get_present_value(     p_api_version            IN NUMBER,
                                   p_init_msg_list          IN VARCHAR2,
                              		   p_cash_flow_tbl          IN cash_flow_tbl,
                            				   p_rate                   IN NUMBER,
                                   p_pv_date                IN DATE,
                                   p_day_convention_month    IN VARCHAR2 DEFAULT '30',
                            				   p_day_convention_year    IN VARCHAR2 DEFAULT '360',
                            				   x_pv_amount              OUT NOCOPY NUMBER,
                                   x_return_status          OUT NOCOPY VARCHAR2,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2);

  PROCEDURE generate_quote_streams(
                             p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             p_khr_id        IN  NUMBER,
                      		     p_kle_id        IN  NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2);

  -- gboomina added for Bug 6763287 - Start
  PROCEDURE generate_streams_for_IA( p_api_version    IN NUMBER
                                   , p_init_msg_list  IN VARCHAR2
                                   , p_khr_id         IN NUMBER
                                   , x_return_status  OUT NOCOPY VARCHAR2
                                   , x_msg_count      OUT NOCOPY NUMBER
                                   , x_msg_data       OUT NOCOPY VARCHAR2
                                   );
  -- gboomina added for Bug 6763287 - End


  --sechawla 10-aug-09 : PRB ESG enhancements : added procedure to spec
  -- This will be called from okl_la_stream_pvt.adjust_passthrough_streams
  -- to support PRB for passthru accrual streams
  PROCEDURE prosp_adj_acc_strms(
              p_api_version         IN         NUMBER
             ,p_init_msg_list       IN         VARCHAR2
             ,p_rebook_type         IN         VARCHAR2
             ,p_rebook_date         IN         DATE
             ,p_khr_id              IN         NUMBER
             ,p_deal_type           IN         VARCHAR2
             ,p_currency_code       IN         VARCHAR2
             ,p_start_date          IN         DATE
             ,p_end_date            IN         DATE
             ,p_context             IN         VARCHAR2
             ,p_purpose_code        IN         VARCHAR2
             ,x_return_status       OUT NOCOPY VARCHAR2
             ,x_msg_count           OUT NOCOPY NUMBER
             ,x_msg_data            OUT NOCOPY VARCHAR2);

END OKL_STREAM_GENERATOR_PVT;

/
