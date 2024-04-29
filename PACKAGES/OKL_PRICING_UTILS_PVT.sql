--------------------------------------------------------
--  DDL for Package OKL_PRICING_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PRICING_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPIUS.pls 120.8.12010000.3 2009/06/04 04:50:26 rgooty ship $ */

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_PRICING_UTILS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_INVALID_VALUE        CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN       CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_API_TYPE             CONSTANT VARCHAR2(4)    := '_PVT';
  G_FALSE                CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  -- Constants representing the Quick Quote Financial Adjustments
  G_DOWNPAYMENT_TYPE  CONSTANT VARCHAR2(30) := 'DOWN_PAYMENT';
  G_SUBSIDY_TYPE      CONSTANT VARCHAR2(30) := 'SUBSIDY';
  G_TRADEIN_TYPE      CONSTANT VARCHAR2(30) := 'TRADEIN';
  G_ITEMCATEGORY_TYPE CONSTANT VARCHAR2(30) := 'ITEM_CATEGORY';
  -- Constants representing the Quick Quote Fees and Services Details
  G_QQ_FEE_EXPENSE       CONSTANT VARCHAR2(30) := 'FEE_EXPENSE';
  G_QQ_FEE_PAYMENT       CONSTANT VARCHAR2(30) := 'FEE_PAYMENT';
  G_QQ_INSURANCE         CONSTANT VARCHAR2(30) := 'INSURANCE';
  G_QQ_SERVICE           CONSTANT VARCHAR2(30) := 'SERVICE';
  G_QQ_TAX              CONSTANT VARCHAR2(30) := 'TAX';
  -- Constants representing the possible Basis types for Quick Quotes
  G_QQ_ASSET_COST_BASIS  CONSTANT VARCHAR2(30) := 'ASSET_COST';
  G_QQ_RENT_BASIS        CONSTANT VARCHAR2(30) := 'RENT';
  G_FIXED_BASIS       CONSTANT VARCHAR2(30)    := 'FIXED';
  G_QQ_SRT_RATE_TYPE     CONSTANT VARCHAR2(30) := 'INDEX_RATE';
  -- Constants representing the various source types for Cash flows
  G_CF_SOURCE_QQ         CONSTANT VARCHAR2(30) := 'OKL_QUICK_QUOTES_B';
  G_CF_SOURCE_LQ         CONSTANT VARCHAR2(30) := 'OKL_LEASE_QUOTES_B';
  G_CF_SOURCE_LQ_ASS     CONSTANT VARCHAR2(30) := 'OKL_ASSETS_B';
  G_CF_SOURCE_LQ_FEE     CONSTANT VARCHAR2(30) := 'OKL_FEES_B';
  -----------------------------------------------------------------------------
  -- Global Data Structures Declaration
  -----------------------------------------------------------------------------
  TYPE interim_interest_rec_type IS RECORD (cf_days NUMBER, cf_amount NUMBER, cf_dpp NUMBER);
  TYPE interim_interest_tbl_type IS TABLE OF interim_interest_rec_type
    INDEX BY BINARY_INTEGER;

  -- Record to store the Header level information
  TYPE so_hdr_rec_type IS RECORD
  (
    so_type                  VARCHAR2(30), -- Quick Quote/Standard Quote ...
    id                       NUMBER       ,
    reference_number         VARCHAR2(150),
    expected_start_date      DATE         ,
    currency_code            VARCHAR2(15) ,
    term                     NUMBER       ,
    sales_territory_id       NUMBER       ,
    end_of_term_option_id    NUMBER       ,
    pricing_method           VARCHAR2(30),
    structured_pricing       VARCHAR2(30),
    line_level_pricing       VARCHAR2(30),
    lease_rate_factor        NUMBER,
    rate_card_id             NUMBER,
    rate_template_id         NUMBER,
    target_rate_type         VARCHAR2(30),
    target_rate              NUMBER,
    target_amount            NUMBER,
    target_frequency         VARCHAR2(30),
    target_arrears           VARCHAR2(3),
    target_periods           NUMBER
  );
  TYPE subsidy_basis_tbl_type IS TABLE OF VARCHAR2(30)
    INDEX BY BINARY_INTEGER;
  TYPE subsidy_value_tbl_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  -- Record to store the Down Payment, Subsidy, Trade in, Item Category Costs .. Amounts
  -- Note: As per the FDD, QQ can have more than one subsidy financial adjustment defined !
  TYPE so_amt_details_rec_type IS RECORD
  (
    down_payment_amount      NUMBER,
    subsidy_amount           NUMBER,
    tradein_amount           NUMBER,
    down_payment_basis       VARCHAR2(30),
    down_payment_value       NUMBER,
    tradein_basis            VARCHAR2(30),
    tradein_value            NUMBER,
    subsidy_basis_tbl        subsidy_basis_tbl_type,
    subsidy_value_tbl        subsidy_value_tbl_type
  );

  -- Record to store the Item Category Cost and the Residual Value
  TYPE so_asset_details_rec_type IS RECORD
  (
    asset_cost                NUMBER,
    end_of_term_amount        NUMBER,
    basis                     VARCHAR2(30),
    value                     NUMBER,
    percentage_of_total_cost  NUMBER
  );
  -- Table representing the Item Category Details entered by user for the Quick Quote
  TYPE so_asset_details_tbl_type IS TABLE OF so_asset_details_rec_type
    INDEX BY BINARY_INTEGER;

  -- Record representing the Cash Flow
  TYPE so_cash_flows_rec_type IS RECORD
  (
    caf_id                     NUMBER,
    khr_id                     NUMBER,
    qte_id                     NUMBER,
    cfo_id                     NUMBER,
    sts_code                   VARCHAR2(30),
    sty_id                     NUMBER,
    cft_code                   VARCHAR2(30),
    due_arrears_yn             VARCHAR2(3),
    start_date                 DATE,
    number_of_advance_periods  NUMBER
  );

  -- Record representing cash flow level object
  TYPE so_cash_flow_details_rec_type IS RECORD
  (
    cfl_id                  NUMBER,
    caf_id                  NUMBER,
    fqy_code                VARCHAR2(30),
    rate                    NUMBER,
    stub_days               NUMBER,
    stub_amount             NUMBER,
    number_of_periods       NUMBER,
    amount                  NUMBER,
    start_date              DATE,
    is_stub                 VARCHAR2(1) DEFAULT 'N',
    locked_amt              VARCHAR2(1) DEFAULT 'N',
    ratio                   NUMBER
  );
  -- Cash Flow Levels Table
  TYPE so_cash_flow_details_tbl_type IS TABLE OF so_cash_flow_details_rec_type
    INDEX BY BINARY_INTEGER;

  -- Record structure representing the Financial Adjustments like
  --  Expenses, Fee Payments, Services
  TYPE item_cat_cf_rec_type IS RECORD
  (
    line_id                 NUMBER,
    item_category_id        NUMBER,
    financed_amount         NUMBER,
    subsidy                 NUMBER,
    down_payment            NUMBER,
    trade_in                NUMBER,
    eot_amount              NUMBER,
    cash_flow_rec           so_cash_flows_rec_type,
    cash_flow_level_tbl     so_cash_flow_details_tbl_type
  );
  -- Table representing the various financial adjustment line types
  -- along with the Cash flow and Cash flow details table
  TYPE item_cat_cf_tbl_type IS TABLE OF item_cat_cf_rec_type
    INDEX BY BINARY_INTEGER;

  -- Record structure representing the Financial Adjustments like
  --  Expenses, Fee Payments, Services
  TYPE so_fee_srv_rec_type IS RECORD
  (
    type                    VARCHAR2(30),
    basis                   VARCHAR2(30),
    value                   NUMBER,
    amount                  NUMBER,
    cash_flow_rec           so_cash_flows_rec_type,
    cash_flow_level_tbl     so_cash_flow_details_tbl_type
  );
  -- Table representing the various financial adjustment line types
  -- along with the Cash flow and Cash flow details table
  TYPE so_fee_srv_tbl_type IS TABLE OF so_fee_srv_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE cash_inflows_rec_type IS RECORD
  (
    line_number                  NUMBER,
    cf_amount                    NUMBER,
    cf_date                      DATE,
    cf_purpose                   VARCHAR2(10),
    cf_dpp                       NUMBER,
    cf_ppy                       NUMBER,
    cf_days                      NUMBER,
    cf_rate                      NUMBER,       -- Can be used as cf_iir
    cf_miss_pay                  VARCHAR2(30),
    is_stub                      VARCHAR2(1),  -- Stub Flag
    is_arrears                   VARCHAR2(1),  -- Arrears Flag
    cf_period_start_end_date     DATE,         -- Can be useful in compute_irr
    locked_amt                   VARCHAR2(1) DEFAULT 'N', -- Useful in compute_irr TR pricing
    cf_ratio                     NUMBER
  );
  TYPE cash_inflows_tbl_type IS TABLE OF cash_inflows_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE pricing_parameter_rec_type IS RECORD
  (
    line_type               VARCHAR2(256),
    line_start_date         DATE,  -- Start date of the corresponding line ..
    line_end_date           DATE,  -- End date of the corresponding line ..
    payment_type            VARCHAR2(256),
    financed_amount         NUMBER,
    trade_in                NUMBER,
    down_payment            NUMBER,
    subsidy                 NUMBER,
    residual_inflows        cash_inflows_tbl_type,
    cash_inflows            cash_inflows_tbl_type,
    cap_fee_amount          NUMBER,
    cfo_id                  NUMBER,  -- Quote Streams ER: 7440199
    link_asset_id           NUMBER   -- Quote Streams ER: 7440199
  );

  TYPE pricing_parameter_tbl_type IS TABLE OF pricing_parameter_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE pricing_results_rec_type IS RECORD
  (
    line_type               VARCHAR2(256),
    line_id                  NUMBER,
    item_category_id        NUMBER,
    financed_amount         NUMBER,
    trade_in                NUMBER,
    down_payment            NUMBER,
    subsidy                 NUMBER,
    cash_flow_rec           so_cash_flows_rec_type,
    cash_flow_level_tbl     so_cash_flow_details_tbl_type
  );
  TYPE pricing_results_tbl_type IS TABLE OF pricing_results_rec_type
    INDEX BY BINARY_INTEGER;

  -- Lease Rate Factors Header n Version Details Record
  TYPE lrs_details_rec_type IS RECORD (
    header_id                      NUMBER,
    version_id                     NUMBER,
    name                           okl_ls_rt_fctr_sets_v.name%type,
    lrs_type_code                  okl_ls_rt_fctr_sets_v.lrs_type_code%type,
    frq_code                       okl_ls_rt_fctr_sets_v.frq_code%type,
    currency_code                  okl_ls_rt_fctr_sets_v.currency_code%type,
    sts_code                       okl_fe_rate_set_versions_v.sts_code%type,
    effective_from_date            okl_fe_rate_set_versions_v.effective_from_date%type,
    effective_to_date              okl_fe_rate_set_versions_v.effective_to_date%type,
    arrears_yn                     okl_fe_rate_set_versions_v.arrears_yn%type,
    end_of_term_ver_id             NUMBER,
    std_rate_tmpl_ver_id           NUMBER,
    adj_mat_version_id             NUMBER,
    version_number                 okl_fe_rate_set_versions_v.version_number%type,
    lrs_version_rate               NUMBER,
    rate_tolerance                 NUMBER,
    residual_tolerance             NUMBER,
    deferred_pmts                  NUMBER,
    advance_pmts                   NUMBER);

  -- Lease Rate Factors Record Type
  TYPE lrs_factor_rec_type IS RECORD (
    factor_id                     NUMBER,
    term_in_months                NUMBER,
    residual_value_percent        NUMBER );

  -- Lease Rate Factor Levels Record Type
  TYPE lrs_levels_rec_type IS RECORD (
    sequence_number               NUMBER, -- order by seq_num ascending
    periods                       NUMBER,
    lease_rate_factor             NUMBER);

  TYPE lrs_levels_tbl_type IS TABLE OF lrs_levels_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE srt_details_rec_type IS RECORD (
    srt_header_id                NUMBER,
    srt_version_id               NUMBER,
    template_name                OKL_FE_STD_RT_TMP_V.TEMPLATE_NAME%TYPE,
    currency_code                OKL_FE_STD_RT_TMP_V.CURRENCY_CODE%TYPE,
    version_number               OKL_FE_STD_RT_TMP_VERS.VERSION_NUMBER%TYPE,
    effective_from_date          OKL_FE_STD_RT_TMP_VERS.EFFECTIVE_FROM_DATE%TYPE,
    effective_to_date            OKL_FE_STD_RT_TMP_VERS.EFFECTIVE_TO_DATE%TYPE,
    sts_code                     OKL_FE_STD_RT_TMP_VERS.STS_CODE%TYPE,
    pricing_engine_code          OKL_FE_STD_RT_TMP_V.PRICING_ENGINE_CODE%TYPE,
    rate_type_code               OKL_FE_STD_RT_TMP_V.RATE_TYPE_CODE%TYPE,
    srt_rate                     NUMBER,
    index_id                     NUMBER,
    spread                       NUMBER,
    day_convention_code          OKL_FE_STD_RT_TMP_VERS.DAY_CONVENTION_CODE%TYPE,
    frequency_code               OKL_FE_STD_RT_TMP_V.FREQUENCY_CODE%TYPE,
    adj_mat_version_id           NUMBER,
    min_adj_rate                 OKL_FE_STD_RT_TMP_VERS.MIN_ADJ_RATE%TYPE,
    max_adj_rate                 OKL_FE_STD_RT_TMP_VERS.MAX_ADJ_RATE%TYPE);

  TYPE adj_mat_cat_rec  IS RECORD (
    target_eff_from       date,
    term                  number,
    territory             varchar2(240),
    deal_size             number,
    customer_credit_class varchar2(240)
  );


  -- Record representing the Yields
  TYPE yields_rec IS RECORD (
    pre_tax_irr                 NUMBER,
    after_tax_irr               NUMBER,
    bk_yield                    NUMBER,
    iir                         NUMBER,
    pre_tax_irr_flag            VARCHAR2(1) DEFAULT 'N',
    after_tax_irr_flag          VARCHAR2(1) DEFAULT 'N',
    bk_yield_flag               VARCHAR2(1) DEFAULT 'N',
    iir_flag                    VARCHAR2(1) DEFAULT 'N'
  );

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_so_hdr
  -- Description          : Wrapper API to fetch the Header level information
  -- Business Rules       :
  -- Parameters           :
  --       p_so_id      - Id of Qucik Quote/Standard Quote
  --       p_so_type    - QQ for Quick Quote/ SQ for Lease Quotes
  -- Version              : 1.0
  -- History              : rgooty 15-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE  get_so_hdr(
              p_api_version       IN  NUMBER,
              p_init_msg_list     IN  VARCHAR2,
              x_return_status     OUT NOCOPY VARCHAR2,
              x_msg_count         OUT NOCOPY NUMBER,
              x_msg_data          OUT NOCOPY VARCHAR2,
              p_so_id             IN  NUMBER,
              p_so_type           IN  VARCHAR2,
              x_so_hdr_rec        OUT NOCOPY so_hdr_rec_type);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_qq_fin_adjustments
  -- Description          : API to fetch the Financial Adjustments Information like
  --                        Down Payment, Subsidy, Trade in, Item Category Amount
  -- Business Rules       :
  -- Parameters           : p_qq_id - Id of the Quick Quote
  -- Version              : 1.0
  -- History              : rgooty 15-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE  get_qq_fin_adj_details(
              p_api_version          IN  NUMBER,
              p_init_msg_list        IN  VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2,
              x_msg_count            OUT NOCOPY NUMBER,
              x_msg_data             OUT NOCOPY VARCHAR2,
              p_qq_id                IN  NUMBER,
              p_pricing_method       IN  VARCHAR2,
              p_item_category_amount IN  NUMBER,
              x_all_amounts_rec      OUT NOCOPY so_amt_details_rec_type);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_qq_sgt_day_convention
  -- Description          : API to fetch the day convention from the SGT assosiated
  -- Business Rules       :
  -- Parameters           : p_qq_id - Id of the Quick Quote
  -- Version              : 1.0
  -- History              : rgooty 15-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_qq_sgt_day_convention(
                p_api_version       IN  NUMBER,
                p_init_msg_list     IN  VARCHAR2,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_qq_id                IN NUMBER,
                x_days_in_month        OUT NOCOPY VARCHAR2,
                x_days_in_year         OUT NOCOPY VARCHAR2);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_qq_cash_flows
  -- Description          : API to fetch the Cash Flows, Cash Flow during
  --                         Structured Pricing !
  -- Business Rules       :
  -- Parameters           : p_qq_id - Id of the Quick Quote
  -- Version              : 1.0
  -- History              : rgooty 8-June-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE  get_qq_cash_flows(
              p_api_version          IN  NUMBER,
              p_init_msg_list        IN  VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2,
              x_msg_count            OUT NOCOPY NUMBER,
              x_msg_data             OUT NOCOPY VARCHAR2,
              p_cf_source_type       IN  VARCHAR2,
              p_qq_id                IN  NUMBER,
              x_days_in_month        OUT NOCOPY VARCHAR2,
              x_days_in_year         OUT NOCOPY VARCHAR2,
              x_cash_flow_rec        OUT NOCOPY so_cash_flows_rec_type,
              x_cash_flow_det_tbl    OUT NOCOPY so_cash_flow_details_tbl_type);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_qq_cash_flows
  -- Description          : API to fetch/build the Cash Flows, Cash Flow Levels
  --                         during Structured Pricing/LRS/SRT !
  -- Business Rules       :
  -- Parameters           : p_qq_id - Id of the Quick Quote
  -- Version              : 1.0
  -- History              : rgooty 8-June-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_qq_cash_flows(
             p_api_version          IN            NUMBER,
             p_init_msg_list        IN            VARCHAR2,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_msg_count               OUT NOCOPY NUMBER,
             x_msg_data                OUT NOCOPY VARCHAR2,
             p_qq_hdr_rec           IN            so_hdr_rec_type,
             p_eot_percentage       IN            NUMBER,
             p_oec                  IN            NUMBER,
             x_days_in_month           OUT NOCOPY VARCHAR2,
             x_days_in_year            OUT NOCOPY VARCHAR2,
             x_cash_flow_rec           OUT NOCOPY so_cash_flows_rec_type,
             x_cash_flow_det_tbl       OUT NOCOPY so_cash_flow_details_tbl_type);

 --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : gen_so_cash_inflows_strms
  -- Description          : API to generate Cash inflows based on the Cash Flows
  --                         inputted.
  -- Business Rules       :
  -- Parameters           : p_qq_id - Id of the Quick Quote
  -- Version              : 1.0
  -- History              : rgooty 15-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE  gen_so_cf_strms(
              p_api_version            IN              NUMBER,
              p_init_msg_list          IN              VARCHAR2,
              x_return_status          OUT NOCOPY      VARCHAR2,
              x_msg_count              OUT NOCOPY      NUMBER,
              x_msg_data               OUT NOCOPY      VARCHAR2,
              p_cash_flow_rec          IN              so_cash_flows_rec_type,
              p_cf_details_tbl         IN              so_cash_flow_details_tbl_type,
              x_cash_inflow_strms_tbl  OUT NOCOPY      cash_inflows_tbl_type);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_day_count
  -- Description          : Counts the number of days between start and end Dates.
  -- Business Rules       : Based on a profile, the months are treated either normal
  --                        or 30 days month.
  -- Parameters           : p_start_date - Start Date
  --                        p_end_date   - End Date
  --                        p_arrears    - Arrears/Advance Flag
  -- Version              : 1.0
  -- History              : rgooty 15-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  FUNCTION GET_DAY_COUNT(
          p_days_in_month     IN      VARCHAR2,
          p_days_in_year      IN      VARCHAR2,
          p_start_date        IN      DATE,
          p_end_date          IN      DATE,
          p_arrears           IN      VARCHAR2,
          x_return_status     OUT     NOCOPY VARCHAR2)
      RETURN NUMBER;

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_day_convention
  -- Description          : Get the day convention either from OKL_K_RATE_PARAMS or
  --                          reach the SGT and fetch the day conventions
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE  get_day_convention(
               p_id              IN          NUMBER,   -- ID of the contract/quote
               p_source          IN          VARCHAR2, -- 'ESG'/'ISG' are acceptable values
               x_days_in_month   OUT NOCOPY  VARCHAR2,
               x_days_in_year    OUT NOCOPY  VARCHAR2,
               x_return_status   OUT NOCOPY  VARCHAR2);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : compute_irr
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 15-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE compute_irr(
              p_api_version             IN              NUMBER,
              p_init_msg_list           IN              VARCHAR2,
              x_return_status           OUT NOCOPY      VARCHAR2,
              x_msg_count               OUT NOCOPY      NUMBER,
              x_msg_data                OUT NOCOPY      VARCHAR2,
              p_start_date              IN              DATE,
              p_day_count_method        IN              VARCHAR2,
              p_currency_code           IN              VARCHAR2,
              p_pricing_method          IN              VARCHAR2,
              p_initial_guess           IN              NUMBER,
              px_pricing_parameter_tbl  IN  OUT NOCOPY  pricing_parameter_tbl_type,
              px_irr                    IN  OUT NOCOPY  NUMBER,
              x_payment                 OUT     NOCOPY  NUMBER);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : compute_iir
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 15-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE compute_iir(
              p_api_version             IN             NUMBER,
              p_init_msg_list           IN             VARCHAR2,
              x_return_status           OUT     NOCOPY VARCHAR2,
              x_msg_count               OUT     NOCOPY NUMBER,
              x_msg_data                OUT     NOCOPY VARCHAR2,
              p_start_date              IN             DATE,
              p_day_count_method        IN             VARCHAR2,
              p_pricing_method          IN             VARCHAR2,
              p_initial_guess           IN             NUMBER,
              px_pricing_parameter_rec  IN  OUT NOCOPY pricing_parameter_rec_type,
              px_iir                    IN  OUT NOCOPY NUMBER,
              x_payment                 OUT     NOCOPY NUMBER);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : compute_iir
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 18-FEB-2006 Created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE compute_iir_sfp(
              p_api_version             IN             NUMBER,
              p_init_msg_list           IN             VARCHAR2,
              x_return_status           OUT     NOCOPY VARCHAR2,
              x_msg_count               OUT     NOCOPY NUMBER,
              x_msg_data                OUT     NOCOPY VARCHAR2,
              p_start_date              IN             DATE,
              p_day_count_method        IN             VARCHAR2,
              p_pricing_method          IN             VARCHAR2,
              p_initial_guess           IN             NUMBER,
              px_pricing_parameter_rec  IN  OUT NOCOPY pricing_parameter_rec_type,
              px_iir                    IN  OUT NOCOPY NUMBER,
              x_closing_balance         OUT     NOCOPY NUMBER,
              x_residual_percent        OUT     NOCOPY NUMBER,
              x_residual_int_factor     OUT     NOCOPY NUMBER);
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_lease_rate_factors
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 6-June-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_lease_rate_factors(
              p_api_version            IN              NUMBER,
              p_init_msg_list          IN              VARCHAR2,
              x_return_status          OUT NOCOPY      VARCHAR2,
              x_msg_count              OUT NOCOPY      NUMBER,
              x_msg_data               OUT NOCOPY      VARCHAR2,
              p_lrt_id                 IN              NUMBER, -- Assuming LRS Version ID
              p_start_date             IN              DATE,
              p_term_in_months         IN              NUMBER,
              p_eot_percentage         IN              NUMBER,
              x_lrs_details            OUT NOCOPY      lrs_details_rec_type,
              x_lrs_factor             OUT NOCOPY      lrs_factor_rec_type,
              x_lrs_levels             OUT NOCOPY      lrs_levels_tbl_type);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_standard_rates
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 6-June-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_standard_rates(
              p_api_version            IN              NUMBER,
              p_init_msg_list          IN              VARCHAR2,
              x_return_status          OUT NOCOPY      VARCHAR2,
              x_msg_count              OUT NOCOPY      NUMBER,
              x_msg_data               OUT NOCOPY      VARCHAR2,
              p_srt_id                 IN              NUMBER,  -- Version ID
              p_start_date             IN              DATE,
              x_srt_details            OUT NOCOPY      srt_details_rec_type);


  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : compute_bk_yield
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 20-June-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE compute_bk_yield(
              p_api_version            IN              NUMBER,
              p_init_msg_list          IN              VARCHAR2,
              x_return_status          OUT NOCOPY      VARCHAR2,
              x_msg_count              OUT NOCOPY      NUMBER,
              x_msg_data               OUT NOCOPY      VARCHAR2,
              p_start_date              IN             DATE,
              p_day_count_method        IN             VARCHAR2,
              p_pricing_method          IN             VARCHAR2,
              p_initial_guess           IN             NUMBER,
              p_term                    IN             NUMBER,
              px_pricing_parameter_rec  IN  OUT NOCOPY pricing_parameter_rec_type,
              x_bk_yield                IN  OUT NOCOPY NUMBER,
              x_termination_tbl             OUT NOCOPY cash_inflows_tbl_type,
              x_pre_tax_inc_tbl             OUT NOCOPY cash_inflows_tbl_type
              -- Parameters for Prospective Rebooking
             ,p_prosp_rebook_flag      IN              VARCHAR2
             ,p_rebook_date            IN              DATE
             ,p_orig_income_streams    IN              cash_inflows_tbl_type
              );

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : price_quick_quote
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 6-June-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE price_quick_quote(
             p_api_version              IN              NUMBER,
             p_init_msg_list            IN              VARCHAR2,
             x_return_status            OUT      NOCOPY VARCHAR2,
             x_msg_count                OUT      NOCOPY NUMBER,
             x_msg_data                 OUT      NOCOPY VARCHAR2,
             p_qq_id                    IN              NUMBER,
             x_yileds_rec               OUT      NOCOPY yields_rec,
             x_subsidized_yileds_rec    OUT      NOCOPY yields_rec,
             x_pricing_results_tbl      OUT      NOCOPY pricing_results_tbl_type);
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_days_per_annum
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 6-June-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  FUNCTION get_days_per_annum(
             p_day_convention   IN            VARCHAR2,
             p_start_date       IN            DATE,
             p_cash_inflow_date IN            DATE,
             x_return_status      OUT NOCOPY VARCHAR2 )
    RETURN NUMBER;

 --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_qq_asset_oec
  -- Description          : Calculates the OEC
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 26-July-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_qq_asset_oec (
              p_api_version          IN  NUMBER,
              p_init_msg_list        IN  VARCHAR2,
              x_return_status        OUT NOCOPY VARCHAR2,
              x_msg_count            OUT NOCOPY NUMBER,
              x_msg_data             OUT NOCOPY VARCHAR2,
              p_asset_cost           IN  NUMBER,
              p_fin_adj_det_rec      IN  so_amt_details_rec_type,
              x_oec                  OUT NOCOPY NUMBER);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_lq_cash_flows
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 3-Aug-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_lq_cash_flows(
             p_api_version          IN            NUMBER,
             p_init_msg_list        IN            VARCHAR2,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_msg_count               OUT NOCOPY NUMBER,
             x_msg_data                OUT NOCOPY VARCHAR2,
             p_id                   IN            NUMBER,
             p_lq_srt_id            IN            NUMBER,
             p_cf_source            IN            VARCHAR2,
             p_adj_mat_cat_rec      IN            adj_mat_cat_rec,
             p_pricing_method       IN            VARCHAR2,
             x_days_in_month           OUT NOCOPY VARCHAR2,
             x_days_in_year            OUT NOCOPY VARCHAR2,
             x_cash_flow_rec           OUT NOCOPY so_cash_flows_rec_type,
             x_cash_flow_det_tbl       OUT NOCOPY so_cash_flow_details_tbl_type);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : distribute_fin_amount_lq
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 13-Aug-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  FUNCTION is_asset_overriding( p_qte_id                IN NUMBER,
                                p_ast_id                IN NUMBER,
                                p_lq_line_level_pricing IN VARCHAR2,
                                p_lq_srt_id             IN NUMBER,
                                p_ast_srt_id            IN NUMBER,
                                p_lq_struct_pricing     IN VARCHAR2,
                                p_ast_struct_pricing    IN VARCHAR2,
                                p_lq_arrears_yn         IN VARCHAR2,
                                p_ast_arrears_yn        IN VARCHAR2,
                                x_return_status         OUT NOCOPY VARCHAR2)
   RETURN BOOLEAN;

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : distribute_fin_amount_lq
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 13-Aug-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE distribute_fin_amount_lq(
             p_api_version          IN            NUMBER,
             p_init_msg_list        IN            VARCHAR2,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_msg_count               OUT NOCOPY NUMBER,
             x_msg_data                OUT NOCOPY VARCHAR2,
             p_lq_id                   IN         NUMBER,
             p_tot_fin_amount          IN         NUMBER);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : Price_Standard_Quote
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : ssiruvol 22-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
 PROCEDURE price_standard_quote_asset(
              x_return_status             OUT NOCOPY  VARCHAR2,
              x_msg_count                 OUT NOCOPY  NUMBER,
              x_msg_data                  OUT NOCOPY  VARCHAR2,
              p_api_version            IN             NUMBER,
              p_init_msg_list          IN             VARCHAR2,
              p_qte_id                 IN             NUMBER,
              p_ast_id                 IN             NUMBER,
              p_price_at_lq_level      IN             BOOLEAN,
              p_target_rate            IN             NUMBER,
              p_line_type              IN             VARCHAR2,
              x_pricing_parameter_rec  IN  OUT NOCOPY pricing_parameter_rec_type);
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : Price_Standard_Quote
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : ssiruvol 22-May-2005 - created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE price_standard_quote(x_return_status                  OUT NOCOPY  VARCHAR2,
                                 x_msg_count                      OUT NOCOPY  NUMBER,
                                 x_msg_data                       OUT NOCOPY  VARCHAR2,
                                 p_api_version                 IN             NUMBER,
                                 p_init_msg_list               IN             VARCHAR2,
                                 p_qte_id                      IN             NUMBER);

  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_day_count_method
  -- Description          :
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : rgooty 20-Feb-2009 - Published in the Spec
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_day_count_method(
      p_days_in_month    IN VARCHAR2,
      p_days_in_year     IN VARCHAR2,
      x_day_count_method OUT NOCOPY  VARCHAR2,
      x_return_status    OUT NOCOPY  VARCHAR2 );
END OKL_PRICING_UTILS_PVT;

/
