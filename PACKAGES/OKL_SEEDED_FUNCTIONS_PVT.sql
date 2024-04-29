--------------------------------------------------------
--  DDL for Package OKL_SEEDED_FUNCTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEEDED_FUNCTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSFFS.pls 120.28.12010000.4 2008/11/24 21:23:05 djanaswa ship $ */

---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			            CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		    CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		    CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		        CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE		        CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		        CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		    CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		    CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR		    CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		        CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		        CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UPPERCASE_REQUIRED		    CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_ONE_DOI			            CONSTANT VARCHAR2(200) := 'OKL_ONE_DOI';
  G_INVALID_CONTRACT_LINE     CONSTANT VARCHAR2(200) := 'OKL_INVALID_CONTRACT_LINE';
  G_PURPOSE_TOKEN             CONSTANT VARCHAR2(200) := 'PURPOSE'; --bug 4024785

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_FORMULAFUNCTION_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;


  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  FUNCTION contract_sum_of_rents(

            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION contract_income(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;



  FUNCTION line_residual_value(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION contract_residual_value(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION contract_oec(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION line_oec(
            p_dnz_chr_id IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            p_cle_id          IN  OKC_K_LINES_V.CLE_ID%TYPE DEFAULT Okl_Api.G_MISS_NUM) RETURN NUMBER;

  FUNCTION contract_tradein(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION line_tradein(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION contract_capital_reduction(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION line_capital_reduction(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION line_fees_capitalized(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION contract_fees_capitalized(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION line_service_capitalized(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;


  FUNCTION investor_account_amount(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION contract_capitalized_interest(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

  FUNCTION line_capitalized_interest(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;
---------------------------------------------------------
--Bug# 3143522 avsingh: 11.5.10 Subsidies
--------------------------------------------------------
--1.function to return line discount (asset level subsidies with accounting method 'NET')
  FUNCTION line_discount(
           p_chr_id    IN NUMBER,
           p_line_id   IN NUMBER) RETURN NUMBER;

--2.function to return contract discount (sum of all contract subsidies with method = 'NET')
  FUNCTION contract_discount(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER;

---------------------------------------------------------
--End Bug# 3143522 avsingh: 11.5.10 Subsidies
---------------------------------------------------------
-----------------------------------------------------------------------
--Start Bug# 3036581 : avsingh new formula CONTRACT_AMORTIZED_EXPENSES
-----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    avsingh
    -- Function Name  contract_amortized_expenses
    -- Description:   returns the sum of amount on stream type - Amortized Expense.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_amortized_expenses(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER;
------------------------------------------------------------------
-----------------------------------------------------------------------
--End Bug# 3036581 : avsingh new formula CONTRACT_AMORTIZED_EXPENSES
-----------------------------------------------------------------------
 FUNCTION contract_amount_prefunded(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (contract_amount_prefunded, TRUST);

 FUNCTION contract_total_funded(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (contract_total_funded, TRUST);

 FUNCTION contract_total_debits(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (contract_total_debits, TRUST);

 FUNCTION contract_total_adjustments(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (contract_total_adjustments, TRUST);

------------------------------------------------------------------
 FUNCTION creditline_total_limit(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (creditline_total_limit, TRUST);

 FUNCTION creditline_total_remaining(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (creditline_total_remaining, TRUST);

 FUNCTION creditline_total_new_limit(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (creditline_total_new_limit, TRUST);

 FUNCTION creditline_total_addition(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (creditline_total_addition, TRUST);

 FUNCTION creditline_total_reduction(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (creditline_total_reduction, TRUST);

 --  Commented out - no owner identified.

 /* FUNCTION line_capitalcost(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER,
            p_capred         IN  NUMBER,
            p_capred_per         IN  NUMBER,
            p_trd_amnt         IN  NUMBER)  RETURN NUMBER; */

-------------------------------------------------------------------------

  ---------------------------------------------
  -- Accrual and LP Functions
  ---------------------------------------------


  FUNCTION CONTRACT_DAYS_TO_ACCRUE(p_khr_id IN NUMBER
                             ,p_kle_id IN NUMBER) RETURN NUMBER ;

  FUNCTION CONTRACT_DAYS_IN_YEAR(p_khr_id IN NUMBER
                           ,p_kle_id IN NUMBER) RETURN NUMBER;

  FUNCTION CONTRACT_INTEREST_RATE(p_khr_id IN NUMBER
                            ,p_kle_id IN NUMBER) RETURN NUMBER;

  FUNCTION CONTRACT_PRINCIPAL_BALANCE(p_khr_id IN NUMBER
                                ,p_kle_id IN NUMBER) RETURN NUMBER;

  FUNCTION CONTRACT_UNBILLED_RECEIVABLES(p_khr_id IN NUMBER
                                   ,p_kle_id IN NUMBER) RETURN NUMBER;

  FUNCTION CONTRACT_UNEARNED_REVENUE(p_khr_id IN NUMBER
                               ,p_kle_id IN NUMBER) RETURN NUMBER;

  FUNCTION CONTRACT_UNGUARANTEED_RESIDUAL(p_khr_id IN NUMBER
                                    ,p_kle_id IN NUMBER) RETURN NUMBER;

  FUNCTION CONTRACT_UNACCRUED_SUBSIDY(p_khr_id IN NUMBER
                                     ,p_kle_id IN NUMBER) RETURN NUMBER;

  FUNCTION CONTRACT_TOTAL_ACTUAL_INT(p_khr_id IN NUMBER
                                      ,p_kle_id IN NUMBER) RETURN NUMBER;

  FUNCTION CONTRACT_TOTAL_ACCRUED_INT(p_khr_id IN NUMBER
                                     ,p_kle_id IN NUMBER) RETURN NUMBER;

  ---------------------------------------------
  -- AM Functions
  ---------------------------------------------

  -- MDOKAL 22-Oct-03 Financed Fee's Functions (Bug 3061765)
  FUNCTION contract_fee_amount (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  -- MDOKAL 28-SEP-03 Securitization Functions (Bug 302639)
  FUNCTION investor_rv_factor (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

   -- MDOKAL 28-SEP-03 Securitization Functions (Bug 302639)
  FUNCTION investor_rent_factor (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;


  FUNCTION line_estimated_property_tax (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  FUNCTION contract_remaining_sec_dep (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  FUNCTION contract_estimate_tax (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  FUNCTION line_estimate_tax (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  FUNCTION line_unbilled_streams (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  -- Just a shell for now
  FUNCTION line_unbilled_rent (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  -- Just a shell for now
  FUNCTION line_unearned_income (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  -- Just a shell for now
  FUNCTION line_calculate_fmv (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  -- Just a shell for now
  FUNCTION line_calculate_residual_value (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

-- Added for bug 6326479
  FUNCTION asset_accu_deprn_reserve (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;
  ---------------------------------------------
  -- END of AM Functions
  ---------------------------------------------

  ---------------------------------------------
  -- CS Functions
  ---------------------------------------------

  FUNCTION contract_security_deposit(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;

  FUNCTION contract_residual_amount(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;

  FUNCTION contract_rent_amount(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;

  FUNCTION contract_unearned_income(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;
  FUNCTION contract_depriciation_amount(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;
FUNCTION contract_principal_amount( p_contract_id           IN  NUMBER
                                 ,p_contract_line_id      IN NUMBER) RETURN NUMBER;
--rkraya added
  FUNCTION  unpaid_invoices(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;
  FUNCTION  unapplied_credit_memos(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;

  FUNCTION contract_prin_balance(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;

--
  FUNCTION get_asset_subsidy_amount(
    p_contract_id                 IN  NUMBER,
    p_accounting_method            IN  VARCHAR2 DEFAULT NULL) RETURN NUMBER;


  FUNCTION contract_acc_depreciation(
           p_contract_id           IN  NUMBER
          ,p_contract_line_id      IN NUMBER) RETURN NUMBER;

  FUNCTION pv_of_unbilled_rents(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER;


  ---------------------------------------------
  --End of  CS Functions
  ---------------------------------------------

-----------------------------------------------------------------------
 FUNCTION INS_MONTHLY_PREMIUM(
  p_contract_id                   IN NUMBER
  ,p_contract_line_id             IN NUMBER
  ) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (INS_MONTHLY_PREMIUM, TRUST);


    FUNCTION INS_REFUNDABLE_MONTHS(
  p_contract_id                   IN NUMBER
  ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
  ) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (INS_REFUNDABLE_MONTHS, TRUST);

-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- Functions By pdevaraj -start
-----------------------------------------------------------------------
  FUNCTION contract_net_investment
    (
       p_chr_id     IN NUMBER
      ,p_line_id    IN NUMBER
    )
  RETURN NUMBER;

  FUNCTION contract_cures_in_possession
    (
      p_chr_id     IN NUMBER
    )
  RETURN NUMBER;

  FUNCTION contract_outstanding_amount
    (
      p_chr_id     IN NUMBER,
      p_line_id    IN NUMBER
    )
  RETURN NUMBER;

  FUNCTION contract_full_cure
    (
       p_chr_id     IN NUMBER
    )
  RETURN NUMBER;

  FUNCTION contract_interest_cure
    (
       p_chr_id     IN NUMBER
    )
  RETURN NUMBER;

  FUNCTION get_unrefunded_cures(
     p_contract_id		IN NUMBER,
     x_unrefunded_cures	      OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_cured_status (p_contract_number IN NUMBER)
  RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_cured_status, WNDS,WNPS,RNPS);

-----------------------------------------------------------------------
-- Functions By pdevaraj -end
-----------------------------------------------------------------------

  ---------------------------------------------
  -- Functions for Securitization
  -- mvasudev, 04/02/2003
  ---------------------------------------------
  FUNCTION ASSET_UNDISBURSED_STREAMS(p_dnz_chr_id IN NUMBER -- Lease Contract ID
                                     ,p_kle_id     IN NUMBER -- Lease Contract-Asset ID
                                    )
  RETURN NUMBER;
  ---------------------------------------------
  -- END,Functions for Securitization
  -- mvasudev, 04/02/2003
  ---------------------------------------------

-- 06/04/03 cklee start

 FUNCTION investor_rent_accural_amout(
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (investor_rent_accural_amout, TRUST);

 FUNCTION investor_user_amount_stake(
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (investor_user_amount_stake, TRUST);

 FUNCTION investor_stream_amount(
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (investor_stream_amount, TRUST);

  FUNCTION INVESTORS_PV_AMOUNT(p_chr_id IN NUMBER -- Investor Agreement ID
                              ,p_line_id     IN NUMBER)
  RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (INVESTORS_PV_AMOUNT, TRUST);

-- 06/04/03 cklee end

-- Fixed bug 3120450

 FUNCTION fee_idc_amount(
  p_dnz_chr_id         IN NUMBER
 ,p_kle_id             IN NUMBER
 ) RETURN NUMBER;

-- 09/05/03 jsanju start
--for cure calculation

 FUNCTION contract_delinquent_amt (
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;


 FUNCTION cumulative_vendor_invoice_amt (
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;


 FUNCTION contract_short_fund_amt (
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;


-- 09/05/03 jsanju end

--rkuttiya 15-SEP-2003 -net_gain_loss_Quote
  FUNCTION NET_GAIN_LOSS_QUOTE
   (p_khr_id    IN NUMBER,
    p_kle_id    IN NUMBER)
  RETURN NUMBER;
--end rkuttiya

-- Bug# 3316994 :12-Jan-2004 cklee
 FUNCTION SUBSIDY_AMOUNT(
 p_contract_id                   IN NUMBER   DEFAULT OKL_API.G_MISS_NUM
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER;

 FUNCTION REFUND_SUBSIDY(
 p_contract_id                   IN NUMBER   DEFAULT OKL_API.G_MISS_NUM
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER;
-- Bug# 3316994 :12-Jan-2004 cklee

-- Bug# 3417313

  FUNCTION contract_pretaxinc_book(
                                   p_chr_id IN  NUMBER
                                  ,p_kle_id IN NUMBER
                                  )
  RETURN NUMBER;

-- fixed bug  3625609
 FUNCTION CONTRACT_FINANCED_FEE(
  p_dnz_chr_id         IN NUMBER
 ,p_kle_id             IN NUMBER
 ) RETURN NUMBER;

-- fixed bug  3673439
 FUNCTION CONTRACT_ABSORBED_FEE(
  p_dnz_chr_id         IN NUMBER
 ,p_kle_id             IN NUMBER
 ) RETURN NUMBER;

-- for bug#3819937 cklee
 FUNCTION credit_check(
 p_contract_id                   IN NUMBER -- credit line contract id
 ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
-- for bug#3819937 cklee

--Bug# 3872534: start
  FUNCTION line_asset_cost (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  FUNCTION line_accumulated_deprn (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  FUNCTION contract_asset_cost (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  FUNCTION contract_accumulated_deprn (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;
  --Bug# 3872534: end

  --Bug# 3877032
  FUNCTION contract_financed_amount
           (p_contract_id       IN NUMBER,
            p_contract_line_id  IN NUMBER)
            RETURN NUMBER;
  --Bug# 3877032 End

  --cklee
  FUNCTION rollover_fee
           (p_contract_id       IN NUMBER,
            p_contract_line_id  IN NUMBER  DEFAULT OKL_API.G_MISS_NUM)
            RETURN NUMBER;
  FUNCTION tot_net_transfers
           (p_contract_id       IN NUMBER,
            p_contract_line_id  IN NUMBER  DEFAULT OKL_API.G_MISS_NUM)
            RETURN NUMBER;
  --cklee

  -- rmunjulu 3816891
  FUNCTION line_future_rent (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  -- rmunjulu 3816891
  FUNCTION line_future_income (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;

  -- rmunjulu 3816891
  FUNCTION asset_residual(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER;

  -- rfedane 4058562
  FUNCTION principal_balance_financed (p_contract_id      IN NUMBER,
                                       p_contract_line_id IN NUMBER) RETURN NUMBER;

  -- rfedane 4058562
  FUNCTION principal_balance_rollover (p_contract_id      IN NUMBER,
                                       p_contract_line_id IN NUMBER) RETURN NUMBER;

  -- rfedane 4058562
  FUNCTION principal_balance_fee_line (p_contract_id      IN NUMBER,
                                       p_contract_line_id IN NUMBER) RETURN NUMBER;

  -- rmunjulu 4299668
  FUNCTION asset_net_book_value(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER;

  -- rmunjulu VENDOR_RESIDUAL_SHARE PROJECT
  FUNCTION vendor_residual_share_amount(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER;

  -- rmunjulu LOANS_ENHANCEMENTS
  FUNCTION loan_asset_prin_bal(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER;

  -- rmunjulu LOANS_ENHANCEMENTS
  FUNCTION quote_perdiem_amount(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER;

-- STRAT: cklee - bug#4655437 10/06/2005
 FUNCTION tot_credit_funding_pmt(
 p_contract_id                   IN NUMBER -- credit line contract id
 ,p_contract_line_id             IN NUMBER DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;

 FUNCTION tot_credit_principal_pmt(
 p_contract_id                   IN NUMBER -- credit line contract id
 ,p_contract_line_id             IN NUMBER DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER;
-- END: cklee - bug#4655437 10/06/2005

  -- sjalasut, Rebook Change Control Enhancement START

  -- function that returns the sum of unbilled RENT for all active assets on the rebook copy of the contract
  FUNCTION cont_rbk_unbilled_receivables(p_contract_id okc_k_headers_b.id%TYPE
                                        ,p_contract_line_id okc_k_lines_b.id%TYPE DEFAULT OKL_API.G_MISS_NUM) RETURN NUMBER;

  -- function that returns the sum of pre-tax income that was not accrued for all active assets on the rebook copy of the contract
  FUNCTION cont_rbk_unearned_income(p_contract_id okc_k_headers_b.id%TYPE
                                   ,p_contract_line_id okc_k_lines_b.id%TYPE DEFAULT OKL_API.G_MISS_NUM) RETURN NUMBER;

  -- returns sum of rent not billed for all terminated assets
  FUNCTION cont_tmt_unbilled_receivables(p_contract_id okc_k_headers_b.id%TYPE
                                        ,p_contract_line_id okc_k_lines_b.id%TYPE DEFAULT OKL_API.G_MISS_NUM) RETURN NUMBER;

  -- returns sum of  pre tax income not accrued for all terminated assets
  FUNCTION cont_tmt_unearned_income(p_contract_id okc_k_headers_b.id%TYPE
                                   ,p_contract_line_id okc_k_lines_b.id%TYPE DEFAULT OKL_API.G_MISS_NUM) RETURN NUMBER;

  -- sjalasut, Rebook Change Control Enhancement END
--varangan bug #5036582 start
 FUNCTION contract_unpaid_invoices(
    p_contract_id IN NUMBER,
    p_contract_line_id IN NUMBER)
    RETURN NUMBER;

 FUNCTION contract_unbilled_streams(
    p_contract_id IN NUMBER,
    p_contract_line_id IN NUMBER)
    RETURN NUMBER;
--varangan bug #5036582 end

  --Begin - varangan- bug#5009351
 FUNCTION contract_next_payment_amount(
    p_contract_id IN NUMBER,
    p_contract_line_id IN NUMBER)
    RETURN NUMBER;
--End - varangan- bug#5009351

  -- Added by rravikir -- Bug 5055835
  FUNCTION check_contract_fin_amount(p_contract_id IN NUMBER,
  									 p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2;

  FUNCTION check_fund_amount(p_contract_id IN NUMBER,
  							 p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2;

  FUNCTION check_party_custacct_match(p_contract_id IN NUMBER,
  									  p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2;

  FUNCTION check_vendor_prog_match(p_contract_id IN NUMBER,
  								   p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2;

  FUNCTION check_booking_date(p_contract_id IN NUMBER,
  							  p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2;

  FUNCTION check_funding_date(p_contract_id IN NUMBER,
  							  p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2;
  -- End

   --03-Jan-07 sechawla 6651621
   FUNCTION line_taxable_basis (
	p_khr_id		IN NUMBER,
	p_kle_id     	IN NUMBER)
	RETURN NUMBER;
 --Bug # 6740000 ssdeshpa added Function for calculating the Investor Loan factor Start
 --For added loan contracts into the Pool
 FUNCTION investor_loan_factor (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER;
--Bug # 6740000 ssdeshpa End;
    -- Added by mansrini for ER Bug#6011738
     FUNCTION front_end_financed_amount(p_contract_id IN NUMBER,
                                        p_contract_line_id IN NUMBER DEFAULT
OKL_API.G_MISS_NUM)
       RETURN NUMBER;
     -- End by mansrini

-- added Durga Janaswamy for Contract Line Extract
 FUNCTION total_asset_addon_cost (
        p_contract_id           IN NUMBER,
        p_contract_line_id      IN NUMBER)
        RETURN NUMBER;

-- added Durga Janaswamy for Contract Line Extract
 FUNCTION get_line_subsidy_amount(
    p_contract_id                 IN  NUMBER,
    p_fin_asset_line_id           IN  NUMBER,
    p_accounting_method           IN  VARCHAR2 DEFAULT NULL)
    RETURN NUMBER;

-- added Durga Janaswamy for Contract Line Extract
 FUNCTION get_line_subsidy_ovrd_amount(
    p_contract_id                 IN  NUMBER,
    p_fin_asset_line_id           IN  NUMBER,
    p_accounting_method           IN  VARCHAR2 DEFAULT NULL)
    RETURN NUMBER;

-- added Durga Janaswamy for Contract Line Extract
 FUNCTION line_financed_amount (
    p_contract_id                 IN  NUMBER,
    p_contract_line_id            IN  NUMBER)
    RETURN NUMBER;

 -- SECHAWLA 18-Nov-08 : Added for Contract Line Extract
 FUNCTION Total_Asset_Financed_Fee_Amt(
    p_chr_id           IN  NUMBER,
    p_line_id          IN  NUMBER) RETURN NUMBER;

 -- SECHAWLA 18-Nov-08 : Added for Contract Line Extract
 FUNCTION Total_Asset_Rollover_Fee_Amt(
    p_chr_id           IN  NUMBER,
    p_line_id          IN  NUMBER) RETURN NUMBER;
END Okl_Seeded_Functions_Pvt;

/
