--------------------------------------------------------
--  DDL for Package LNS_FINANCIALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FINANCIALS" AUTHID CURRENT_USER AS
/* $Header: LNS_FINANCIAL_S.pls 120.11.12010000.9 2010/03/17 14:39:38 scherkas ship $ */

/*========================================================================+
|  Declare PUBLIC Data Types and Variables
+========================================================================*/

/*========================================================================+
|  Interest Rate Rec is for capturing interest rate details
|  Rate Schedule Table is to help handle multi-rate loans
+========================================================================*/
  TYPE INTEREST_RATE_REC IS RECORD(RATE_ID                  NUMBER
                                  ,BEGIN_DATE               DATE
                                  ,END_DATE                 DATE
                                  ,ANNUAL_RATE              NUMBER
                                  ,SPREAD                   NUMBER
                                  ,BEGIN_INSTALLMENT_NUMBER NUMBER
                                  ,END_INSTALLMENT_NUMBER   NUMBER
                                  ,INTEREST_ONLY_FLAG       VARCHAR2(1)
                                  ,PHASE                    VARCHAR2(30)
                                  ,FLOATING_FLAG            VARCHAR2(1));

  TYPE RATE_SCHEDULE_TBL IS TABLE OF INTEREST_RATE_REC INDEX BY BINARY_INTEGER;

/*========================================================================+
|  This is the main record type for amortization
|  The runAmortization procedures will return this information to UI
+========================================================================*/
  TYPE AMORTIZATION_REC IS RECORD(INSTALLMENT_NUMBER   NUMBER
                                 ,DUE_DATE             DATE
                                 ,PERIOD_START_DATE    DATE
                                 ,PERIOD_END_DATE      DATE
                                 ,PRINCIPAL_AMOUNT     NUMBER
                                 ,INTEREST_AMOUNT      NUMBER
                                 ,NORMAL_INT_AMOUNT    NUMBER
                                 ,ADD_PRIN_INT_AMOUNT  NUMBER
                                 ,ADD_INT_INT_AMOUNT   NUMBER
                                 ,PENAL_INT_AMOUNT     NUMBER
                                 ,FEE_AMOUNT           NUMBER
                                 ,OTHER_AMOUNT         NUMBER
                                 ,BEGIN_BALANCE        NUMBER
                                 ,END_BALANCE          NUMBER
                                 ,TOTAL                NUMBER
                                 ,INTEREST_CUMULATIVE  NUMBER
                                 ,PRINCIPAL_CUMULATIVE NUMBER
                                 ,FEES_CUMULATIVE      NUMBER
                                 ,OTHER_CUMULATIVE     NUMBER
                                 ,RATE_ID              NUMBER
                                 ,RATE_UNADJ           NUMBER
                                 ,RATE_CHANGE_FREQ     VARCHAR2(30)
                                 ,SOURCE               VARCHAR2(30)
                                 ,GRAND_TOTAL_FLAG     VARCHAR2(1)
                                 ,UNPAID_PRIN          NUMBER
                                 ,UNPAID_INT           NUMBER
                                 ,INTEREST_RATE        NUMBER
                                 ,FUNDED_AMOUNT        NUMBER
                                 ,NORMAL_INT_DETAILS   VARCHAR2(2000)
                                 ,ADD_PRIN_INT_DETAILS VARCHAR2(2000)
                                 ,ADD_INT_INT_DETAILS  VARCHAR2(2000)
                                 ,PENAL_INT_DETAILS    VARCHAR2(2000)
                                 ,DISBURSEMENT_AMOUNT  NUMBER
                                 ,PERIOD               VARCHAR2(200));

  TYPE AMORTIZATION_TBL IS TABLE OF AMORTIZATION_REC INDEX BY BINARY_INTEGER;

/*========================================================================+
|  This record type will contain all the pertinent properties for a loan
|  includes reamortization , currency, arrears, amounts
|+========================================================================*/
  TYPE LOAN_DETAILS_REC IS RECORD(LOAN_ID                       NUMBER       -- loan id
                                 ,LOAN_TERM                     NUMBER       -- term of the loan
                                 ,LOAN_TERM_PERIOD              VARCHAR2(30) -- term period of the loan
                                 ,AMORTIZED_TERM                NUMBER       -- amotrtized term of the loan
                                 ,AMORTIZED_TERM_PERIOD         VARCHAR2(30) -- amotrtized term period of the loan
                                 ,AMORTIZATION_FREQUENCY        VARCHAR2(30)
                                 ,PAYMENT_FREQUENCY             VARCHAR2(30)
                                 ,FIRST_PAYMENT_DATE            DATE
                                 ,LOAN_START_DATE               DATE
                                 ,REQUESTED_AMOUNT              NUMBER
                                 ,FUNDED_AMOUNT                 NUMBER
                                 ,REMAINING_BALANCE             NUMBER
                                 ,PRINCIPAL_PAID_TO_DATE        NUMBER
                                 ,INTEREST_PAID_TO_DATE         NUMBER
                                 ,FEES_PAID_TO_DATE             NUMBER
                                 ,UNPAID_PRINCIPAL              NUMBER
                                 ,UNPAID_INTEREST               NUMBER
                                 ,UNBILLED_PRINCIPAL            NUMBER
                                 ,BILLED_PRINCIPAL              NUMBER
                                 ,MATURITY_DATE                 DATE
                                 ,NUMBER_INSTALLMENTS           NUMBER       -- based off of TERM + TERM_PERIOD
                                 ,NUM_AMORTIZATION_INTERVALS    NUMBER       -- based off of AMORTIZATION_TERM + AMORTIZATION_TERM_PERIOD
                                 ,REAMORTIZE_OVERPAY            VARCHAR2(1)
                                 ,REAMORTIZE_UNDERPAY           VARCHAR2(1)
                                 ,REAMORTIZE_WITH_INTEREST      VARCHAR2(1)  -- for future use
                                 ,REAMORTIZE_AMOUNT             NUMBER
                                 ,REAMORTIZE_FROM_INSTALLMENT   NUMBER
                                 ,REAMORTIZE_TO_INSTALLMENT     NUMBER       -- for future use
                                 ,LAST_INSTALLMENT_BILLED       NUMBER
                                 ,DAY_COUNT_METHOD              VARCHAR2(30) -- day count methodology
                                 ,PAY_IN_ARREARS                VARCHAR2(1)  -- Y/N for pay in arrears
                                 ,PAY_IN_ARREARS_BOOLEAN        BOOLEAN      -- boolean for pay in arrears
                                 ,CUSTOM_SCHEDULE               VARCHAR2(1)  -- Y/N for custom payment schedule
                                 ,LOAN_STATUS                   VARCHAR2(30) -- loan status
                                 ,LAST_INTEREST_ACCRUAL         DATE         -- last interest accrual date
                                 ,LAST_ACTIVITY                 VARCHAR2(30) -- for future use
                                 ,LAST_ACTIVITY_DATE            DATE         -- last activity date on the loan
                                 ,LOAN_CURRENCY                 VARCHAR2(15) -- loan currency
                                 ,CURRENCY_PRECISION            NUMBER       -- currency precision
                                 ,OPEN_TERM                     NUMBER       -- open term
                                 ,OPEN_TERM_PERIOD              VARCHAR2(30) -- open term period
                                 ,OPEN_PAYMENT_FREQUENCY        VARCHAR2(30) -- payment freq during open phase
                                 ,OPEN_FIRST_PAYMENT_DATE       DATE         -- open phase first pay date
                                 ,OPEN_START_DATE               DATE         -- begin date of open phase
                                 ,OPEN_MATURITY_DATE            DATE         -- maturity date of open phase
                                 ,LOAN_PHASE                    VARCHAR2(30) -- OPEN or TERM for phase of the loan
                                 ,BALLOON_PAYMENT_TYPE          VARCHAR2(30)  -- TERM or AMOUNT
                                 ,BALLOON_PAYMENT_AMOUNT        NUMBER       -- if balloon type = AMOUNT then the actual amount
                                 ,AMORTIZED_AMOUNT              NUMBER       -- amortized amount
                                 ,RATE_TYPE                     VARCHAR2(30) -- fixed or variable
                                 ,OPEN_RATE_CHG_FREQ            VARCHAR2(30) -- how often rate changes during open phase
                                 ,OPEN_INDEX_RATE_ID            NUMBER       -- index_rate_id
                                 ,OPEN_INDEX_DATE               DATE         -- open index date
                                 ,OPEN_CEILING_RATE             NUMBER       -- open ceiling rate
                                 ,OPEN_FLOOR_RATE               NUMBER       -- open floor rate
                                 ,OPEN_FIRST_PERCENT_INCREASE   NUMBER       -- open first percentage increase
                                 ,OPEN_ADJ_PERCENT_INCREASE     NUMBER       -- open percentage increase btwn adjustments
                                 ,OPEN_LIFE_PERCENT_INCREASE    NUMBER       -- open lifetime max adjustment for interest
                                 ,TERM_RATE_CHG_FREQ            VARCHAR2(30) -- how often rate changes during term phase
                                 ,TERM_INDEX_RATE_ID            NUMBER       -- index_rate_id
                                 ,TERM_INDEX_DATE               DATE         -- term index date
                                 ,TERM_CEILING_RATE             NUMBER       -- term ceiling rate
                                 ,TERM_FLOOR_RATE               NUMBER       -- term floor rate
                                 ,TERM_FIRST_PERCENT_INCREASE   NUMBER       -- term first percentage increase
                                 ,TERM_ADJ_PERCENT_INCREASE     NUMBER       -- term percentage increase btwn adjustments
                                 ,TERM_LIFE_PERCENT_INCREASE    NUMBER       -- term lifetime max adjustment for interest
                                 ,OPEN_TO_TERM_FLAG             VARCHAR2(1)
                                 ,OPEN_TO_TERM_EVENT            VARCHAR2(30)
                                 ,MULTIPLE_FUNDING_FLAG         VARCHAR2(1)
                                 ,SECONDARY_STATUS              VARCHAR2(30)
                                 ,OPEN_PROJECTED_INTEREST_RATE  NUMBER  -- open projected interest rate
                                 ,TERM_PROJECTED_INTEREST_RATE  NUMBER  -- term projected interest rate
                                 ,INITIAL_INTEREST_RATE         NUMBER                                       --
                                 ,LAST_INTEREST_RATE            NUMBER                                    --
                                 ,FIRST_RATE_CHANGE_DATE        DATE
                                 ,NEXT_RATE_CHANGE_DATE         DATE
                                 ,CALCULATION_METHOD            VARCHAR2(30)  -- interest calc method: simple, compound
                                 ,INTEREST_COMPOUNDING_FREQ     VARCHAR2(30)
                                 ,PAYMENT_CALC_METHOD           VARCHAR2(30)  -- payment calc method: equal payment, equal principal
                                 ,ORIG_PAY_CALC_METHOD          VARCHAR2(30)
                                 ,PRIN_FIRST_PAY_DATE           DATE    -- principal first payment date; used with PAYMENT_CALC_METHOD=SEPERATE_PRIN_INT
                                 ,PRIN_PAYMENT_FREQUENCY        VARCHAR2(30)  -- principal payment freq; used with PAYMENT_CALC_METHOD=SEPERATE_PRIN_INT
                                 ,PRIN_NUMBER_INSTALLMENTS      NUMBER  -- principal number of installments; used with PAYMENT_CALC_METHOD=SEPERATE_PRIN_INT
                                 ,PRIN_AMORT_INSTALLMENTS       NUMBER  -- principal number of amortized installments; used with PAYMENT_CALC_METHOD=SEPERATE_PRIN_INT
                                 ,PRIN_PAY_IN_ARREARS           VARCHAR2(1)  -- Y/N for principal pay in arrears; used with PAYMENT_CALC_METHOD=SEPERATE_PRIN_INT
                                 ,PRIN_PAY_IN_ARREARS_BOOL      BOOLEAN      -- boolean for principal pay in arrears
                                 ,EXTEND_FROM_INSTALLMENT       NUMBER
                                 ,ORIG_NUMBER_INSTALLMENTS      NUMBER
                                 ,PENAL_INT_RATE                NUMBER
                                 ,PENAL_INT_GRACE_DAYS          NUMBER
                                 ,REAMORTIZE_ON_FUNDING         VARCHAR2(30)
							);

/*========================================================================+
|  this is for the old payoff calculation
+========================================================================*/
  TYPE PAYOFF_REC is RECORD(TOTAL_PRINCIPAL_REMAINING    NUMBER
                           ,UNPAID_PRINCIPAL             NUMBER -- billed but not paid
                           ,UNBILLED_PRINCIPAL           NUMBER -- not billed
                           ,TOTAL_INTEREST_REMAINING     NUMBER
                           ,UNPAID_INTEREST              NUMBER -- billed but not paid
                           ,ADDITIONAL_INTEREST_DUE      NUMBER -- this is the main calculation needs
                           ,TOTAL_FEES_REMAINING         NUMBER
                           ,UNPAID_FEES                  NUMBER -- billed but not paid
                           ,ADDITIONAL_FEES_DUE          NUMBER -- for future
                           ,DUE_DATE                     DATE);

  TYPE PAYOFF_TBL is TABLE OF PAYOFF_REC INDEX BY BINARY_INTEGER;

/*========================================================================+
|  new record type for payoff enhancements
|  tbl type is extensible by "PURPOSE"
+========================================================================*/
  TYPE PAYOFF_REC2 is record(PAYOFF_PURPOSE  VARCHAR2(30)
                            ,BILLED_AMOUNT   NUMBER
                            ,UNBILLED_AMOUNT NUMBER
                            ,TOTAL_AMOUNT    NUMBER );

  TYPE PAYOFF_TBL2 is TABLE OF PAYOFF_REC2 INDEX BY BINARY_INTEGER;

/*========================================================================+
|  used to calculate average daily balance
+========================================================================*/
  TYPE LOAN_ACTIVITY_REC is record(ACTIVITY_DATE     DATE
                                  ,ACTIVITY_AMOUNT   NUMBER
                                  ,ENDING_BALANCE    NUMBER
                                  ,DAYS_AT_BALANCE   NUMBER);

  TYPE LOAN_ACTIVITY_TBL is table of LOAN_ACTIVITY_REC index by binary_integer;

/*========================================================================+
|  types for building payment schedule
+========================================================================*/
  TYPE PAYMENT_SCHEDULE is record(PERIOD_BEGIN_DATE  DATE
                                 ,PERIOD_END_DATE    DATE);

  TYPE PAYMENT_SCHEDULE_TBL is table of PAYMENT_SCHEDULE index by binary_integer;

/*========================================================================+
|  helper types
+========================================================================*/
  TYPE DATE_TBL   IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  type amount_tbl is table of number index by Binary_Integer;
  type vchar_tbl  is table of varchar2(30) index by binary_integer;

/*========================================================================+
|  fees types
+========================================================================*/
  TYPE FEES_REC IS RECORD(FEE_ID            NUMBER
                         ,FEE_NAME          VARCHAR2(50)
                         ,FEE_AMOUNT        NUMBER
                         ,FEE_INSTALLMENT   NUMBER
                         ,FEE_DESCRIPTION   VARCHAR2(250)
                         ,FEE_SCHEDULE_ID   NUMBER
                         ,FEE_WAIVABLE_FLAG VARCHAR2(1)
                         ,WAIVE_AMOUNT      NUMBER
                         ,BILLED_FLAG       VARCHAR2(1)
                         ,ACTIVE_FLAG       VARCHAR2(1));

 TYPE FEES_TBL IS TABLE OF FEES_REC INDEX BY BINARY_INTEGER;

procedure shiftLoan(p_loan_id        in number
                   ,p_init_msg_list  IN VARCHAR2
                   ,p_commit         IN VARCHAR2
                   ,x_return_status  OUT NOCOPY VARCHAR2
                   ,x_msg_count      OUT NOCOPY NUMBER
                   ,x_msg_data       OUT NOCOPY VARCHAR2);

procedure shiftLoanDates(p_loan_id        in number
                        ,p_new_start_date in date
						,p_phase          in varchar2
                        ,x_loan_details   out NOCOPY lns_financials.loan_details_rec
                        ,x_dates_shifted_flag OUT NOCOPY VARCHAR2
                        ,x_return_status  OUT NOCOPY VARCHAR2
                        ,x_msg_count      OUT NOCOPY NUMBER
                        ,x_msg_data       OUT NOCOPY VARCHAR2);

function getAverageDailyBalance(p_loan_id     number
                               ,p_term_id     number
                               ,p_from_date   date
                               ,p_to_date     date
                               ,p_calc_method number) return number;

procedure getWeightedBalance(p_loan_id          in number
                           ,p_from_date        in date
                           ,p_to_date          in date
                           ,p_calc_method      in varchar2
                           ,p_phase            in varchar2
                           ,p_day_count_method in varchar2
                           ,p_adj_amount       in number
                           ,x_wtd_balance      out NOCOPY number
                           ,x_begin_balance    out NOCOPY number
                           ,x_end_balance      out NOCOPY number);
/*
function getWeightedBalance(p_loan_id          number
                           ,p_from_date        date
                           ,p_to_date          date
                           ,p_calc_method      varchar2
													 ,p_phase            varchar2
													 ,p_day_count_method varchar2) return number;
*/
procedure validatePayoff(p_loan_details   in LNS_FINANCIALS.LOAN_DETAILS_REC
                        ,p_payoff_date    in date
                        ,x_return_status  OUT NOCOPY VARCHAR2
                        ,x_msg_count      OUT NOCOPY NUMBER
                        ,x_msg_data       OUT NOCOPY VARCHAR2);

-- payoff calculation
procedure calculatePayoff(p_api_version    IN NUMBER
                         ,p_init_msg_list  IN VARCHAR2
                         ,p_loan_id        in number
                         ,p_payoff_date    in date
                         ,x_payoff_tbl     OUT NOCOPY LNS_FINANCIALS.PAYOFF_TBL2
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_msg_count      OUT NOCOPY NUMBER
                         ,x_msg_data       OUT NOCOPY VARCHAR2);

function getLoanDetails(p_loan_id        in number
                       ,p_based_on_terms in varchar2
											 ,p_phase          in varchar2) return LNS_FINANCIALS.LOAN_DETAILS_REC;

function compoundInterest(p_rate         in number
                         ,p_period_value in number
                         ,p_period_type  in varchar2) return number;

function getAnnualRate(p_loan_Id in number) return number;

function getActiveRate(p_loan_id in number) return number;

function getRemainingBalance(p_loan_id in number) return number;

function getPeriodicRate(p_payment_freq in varchar2
                        ,p_period_start_date in date
                        ,p_period_end_date   in date
                        ,p_annualized_rate   in number
                        ,p_days_count_method in varchar2
                        ,p_target            in varchar2) return number;

function getWeightedRate(p_loan_details in LNS_FINANCIALS.LOAN_DETAILS_REC
                        ,p_start_date in date
                        ,p_end_date   in date
                        ,p_rate_tbl   in LNS_FINANCIALS.RATE_SCHEDULE_TBL) return number;

procedure amortizeEPLoan(p_loan_details       in LNS_FINANCIALS.LOAN_DETAILS_REC
                      ,p_rate_schedule      in LNS_FINANCIALS.RATE_SCHEDULE_TBL
                      ,p_based_on_terms     IN VARCHAR2
                      ,p_installment_number in number
                      ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL);

procedure amortizeLoan(p_loan_details       in LNS_FINANCIALS.LOAN_DETAILS_REC
                      ,p_rate_schedule      in LNS_FINANCIALS.RATE_SCHEDULE_TBL
                      ,p_based_on_terms     IN VARCHAR2
                      ,p_installment_number in number
                      ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL);

procedure amortizeLoan(p_loan_Id            in number
                      ,p_based_on_terms     IN VARCHAR2
                      ,p_installment_number in number
                      ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL);

procedure loanProjection(p_loan_details       in  LNS_FINANCIALS.LOAN_DETAILS_REC
                        ,p_based_on_terms     in  varchar2
                        ,p_rate_schedule      in  LNS_FINANCIALS.RATE_SCHEDULE_TBL
                        ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL);

procedure runOpenProjection(p_init_msg_list  IN VARCHAR2
                           ,p_loan_ID        IN NUMBER
                           ,p_based_on_terms IN VARCHAR2
                           ,x_amort_tbl      OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_TBL
                           ,x_return_status  OUT NOCOPY VARCHAR2
                           ,x_msg_count      OUT NOCOPY NUMBER
                           ,x_msg_data       OUT NOCOPY VARCHAR2);

procedure validateLoan(p_api_version    IN NUMBER
                      ,p_init_msg_list  IN VARCHAR2
                      ,p_loan_ID        IN NUMBER
                      ,x_return_status  OUT NOCOPY VARCHAR2
                      ,x_msg_count      OUT NOCOPY NUMBER
                      ,x_msg_data       OUT NOCOPY VARCHAR2);

procedure runAmortization(p_api_version    IN NUMBER
                         ,p_init_msg_list  IN VARCHAR2
                         ,p_commit         IN VARCHAR2
                         ,p_loan_ID        IN NUMBER
                         ,p_based_on_terms IN VARCHAR2
                         ,x_amort_tbl      OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_TBL
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_msg_count      OUT NOCOPY NUMBER
                         ,x_msg_data       OUT NOCOPY VARCHAR2);

function getRateSchedule(p_loan_id in number
                        ,p_phase   in varchar2) return LNS_FINANCIALS.RATE_SCHEDULE_TBL;

--function getRateSchedule(p_loan_id in number) return LNS_FINANCIALS.RATE_SCHEDULE_TBL;

function getRateDetails(p_installment IN NUMBER
                       ,p_rate_tbl    IN LNS_FINANCIALS.RATE_SCHEDULE_TBL) return LNS_FINANCIALS.INTEREST_RATE_REC;

function getRateDetails(p_date in date
                       ,p_rate_tbl in LNS_FINANCIALS.RATE_SCHEDULE_TBL) return LNS_FINANCIALS.INTEREST_RATE_REC;

function termlyPayment(p_termly_amount     in number
                      ,p_annual_rate       in number
                      ,p_loan_amount       in number
                      ,p_payments_per_year in number
                      ,p_period_type       in varchar2) return number;

procedure getInstallment(p_api_version        IN NUMBER
                        ,p_init_msg_list      IN VARCHAR2
                        ,p_commit             IN VARCHAR2
                        ,p_loan_Id            IN NUMBER
                        ,p_installment_number IN NUMBER
                        ,x_amortization_rec   OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_REC
                        ,x_fees_tbl           OUT NOCOPY LNS_FINANCIALS.FEES_TBL
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER
                        ,x_msg_data           OUT NOCOPY VARCHAR2);

procedure getOpenInstallment(p_init_msg_list      IN VARCHAR2
                            ,p_loan_Id            in number
                            ,p_installment_number in number
                            ,x_amortization_rec   OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_REC
                            ,x_fees_tbl           OUT NOCOPY LNS_FINANCIALS.FEES_TBL
                            ,x_return_status      OUT NOCOPY VARCHAR2
                            ,x_msg_count          OUT NOCOPY NUMBER
                            ,x_msg_data           OUT NOCOPY VARCHAR2);

function getRatesTable(p_index_rate_id           in number
											,p_index_date              in date
											,p_rate_change_frequency   in varchar2
											,p_maturity_date           in date) return LNS_FINANCIALS.RATE_SCHEDULE_TBL;


procedure preProcessInstallment(p_api_version        IN NUMBER
                               ,p_init_msg_list      IN VARCHAR2
                               ,p_commit             IN VARCHAR2
                               ,p_loan_ID            IN NUMBER
                               ,p_installment_number IN NUMBER
                               ,x_amortization_rec   OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_REC
                               ,x_return_status      OUT NOCOPY VARCHAR2
                               ,x_msg_count          OUT NOCOPY NUMBER
                               ,x_msg_data           OUT NOCOPY VARCHAR2);

procedure preProcessOpenInstallment(p_init_msg_list      IN VARCHAR2
                                   ,p_commit             IN VARCHAR2
                                   ,p_loan_ID            IN NUMBER
                                   ,p_installment_number IN NUMBER
                                   ,x_amortization_rec   OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_REC
                                   ,x_return_status      OUT NOCOPY VARCHAR2
                                   ,x_msg_count          OUT NOCOPY NUMBER
                                   ,x_msg_data           OUT NOCOPY VARCHAR2);

function calculateEPPayment(p_loan_amount     in number
                            ,p_num_intervals   in number
                            ,p_ending_balance  in number
                            ,p_pay_in_arrears  in boolean) return number;

function calculatePayment(p_loan_amount     in number
                         ,p_periodic_rate   in number
                         ,p_num_intervals   in number
                         ,p_ending_balance  in number
                         ,p_pay_in_arrears  in boolean) return number;

function calculateInterest(p_amount             in number
                          ,p_periodic_rate      in number
                          ,p_compounding_period in varchar2)  return number;

function calculateInterestRate(p_initial_rate            in number
                              ,p_rate_to_compare         in number
                              ,p_last_period_rate        in number
                              ,p_max_first_adjustment    in number
                              ,p_max_period_adjustment   in number
                              ,p_max_lifetime_adjustment in number
                              ,p_ceiling_rate            in number
                              ,p_floor_rate              in number
                              ,p_installment_number      in number) return number;

procedure      floatingRatePostProcessing(p_loan_id                  IN NUMBER
                                         ,p_init_msg_list            IN VARCHAR2
                                         ,p_commit                   IN VARCHAR2
                                         ,p_installment_number       IN NUMBER
                                         ,p_period_begin_date        IN DATE
                                         ,p_interest_adjustment_freq IN VARCHAR2
                                         ,p_annualized_interest_rate IN NUMBER
                                         ,p_rate_id                  IN OUT NOCOPY NUMBER
                                         ,p_phase                    IN VARCHAR2
                                         ,x_return_status            OUT NOCOPY VARCHAR2
                                         ,x_msg_count                OUT NOCOPY NUMBER
                                         ,x_msg_data                 OUT NOCOPY VARCHAR2);


function getAPR(p_loan_id     in number
               ,p_term_id     in number
               ,p_actual_flag in varchar2) return number;

function frequency2ppy(p_frequency in varchar2) return number;

function getCompoundPeriodicRate(p_compound_freq in varchar2
                        ,p_payment_freq in varchar2
                        ,p_annualized_rate   in number
                        ,p_period_start_date in date
                        ,p_period_end_date   in date
                        ,p_days_count_method in varchar2
                        ,p_target in varchar2) return number;

-- This procedure calculates normal interest
procedure CALC_NORM_INTEREST(p_loan_id               in  number,
                           p_calc_method           in  varchar2,
                           p_period_start_date     in  date,
                           p_period_end_date       in  date,
                           p_interest_rate         in  number,
                           p_day_count_method      in  varchar2,
                           p_payment_freq          in  varchar2,
                           p_compound_freq         in  varchar2,
                           p_adj_amount            in  number,
                           x_norm_interest         out NOCOPY number,
                           x_norm_int_details      out NOCOPY varchar2);

-- This procedure calculates additional and penal interest
procedure CALC_ADD_INTEREST(p_loan_id               in  number,
                           p_calc_method           in  varchar2,
                           p_period_start_date     in  date,
                           p_period_end_date       in  date,
                           p_interest_rate         in  number,
                           p_day_count_method      in  varchar2,
                           p_payment_freq          in  varchar2,
                           p_compound_freq         in  varchar2,
                           p_penal_int_rate        in  number,
                           p_prev_grace_end_date   in  date,
                           p_grace_start_date      in  date,
                           p_grace_end_date        in  date,
                           p_target                in  varchar2,
                           x_add_interest          out NOCOPY number,
                           x_penal_interest        out NOCOPY number,
                           x_add_int_details       out NOCOPY varchar2,
                           x_penal_int_details     out NOCOPY varchar2);

function getFundedAmount(p_loan_id in number, p_date in date, p_based_on_terms varchar2) return number;

END LNS_FINANCIALS;

/
