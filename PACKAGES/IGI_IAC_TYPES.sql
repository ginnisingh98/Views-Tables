--------------------------------------------------------
--  DDL for Package IGI_IAC_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_TYPES" AUTHID CURRENT_USER AS
-- $Header: igiiatys.pls 120.10.12000000.1 2007/08/01 16:19:39 npandya ship $

/**
-- Constants to hold the value of the revaluation statuses so that it can
-- be shared accross pl/sql routines
**/
gc_preview_status   CONSTANT  igi_iac_revaluations.status%TYPE  :=   'PREVIEW';
gc_previewed_status CONSTANT  igi_iac_revaluations.status%TYPE  :=   'PREVIEWED';
gc_failedpre_status CONSTANT  igi_iac_revaluations.status%TYPE  :=   'FAILED_PRE';
gc_running_status   CONSTANT  igi_iac_revaluations.status%TYPE  :=   'RUNNING';
gc_completed_status CONSTANT  igi_iac_revaluations.status%TYPE  :=   'COMPLETED';
gc_failedrun_status CONSTANT  igi_iac_revaluations.status%TYPE  :=   'FAILED_RUN';
/**
-- Period record contains the full information about the period
**/
TYPE prd_rec IS RECORD (Period_Name VARCHAR2(30) default null,
                        Period_Counter NUMBER    default 0,
                        Period_Num NUMBER        default 0,
                        Fiscal_Year NUMBER       default 0,
                        Period_Start_Date DATE   default null,
                        Period_End_Date DATE     default null
                        );
/**
-- this structure is used to show the proration of the asset amount
-- across ACTIVE distributions
**/

TYPE dist_amt IS RECORD ( distribution_id NUMBER, amount NUMBER,units NUMBER,prorate_factor NUMBER);
TYPE dist_amt_tab IS TABLE of dist_amt INDEX by BINARY_INTEGER;

/**
-- this structure is used show the prorations of the asset amount across
-- ACTIVE and INACTIVE distributions for that year
**/
TYPE prorate_dists IS RECORD ( distribution_id       NUMBER default 0
                             , ytd_prorate_factor    NUMBER default 0
                             , normal_prorate_factor NUMBER default 0
                             , latest_period_counter NUMBER default 0
                             , units_assigned        NUMBER default 0
                             , units_active          NUMBER default 0
                             , active_flag           VARCHAR2(1)
                             );

TYPE prorate_dists_tab IS TABLE of prorate_dists INDEX by BINARY_INTEGER;

SUBTYPE dh_rec IS fa_distribution_history%ROWTYPE ;

SUBTYPE iac_reval_asset_rules IS IGI_IAC_REVAL_ASSET_RULES%ROWTYPE;
SUBTYPE iac_det_balances      IS IGI_IAC_DET_BALANCES%ROWTYPE;

TYPE    dh_tab IS TABLE of dh_rec INDEX BY BINARY_INTEGER ;
/** begin revaluation info **/
 subtype  iac_Reval_input_asset           is igi_iac_asset_balances%rowtype;

   type  iac_reval_mesg_line          is record
    (  line varchar2(100) default null,  message_level number);

   type     iac_reval_control_type   IS RECORD
    (
     revaluation_mode            VARCHAR2(1)   /* Revaluation modes 'P' - Preview */
    ,transaction_type_code       IGI_IAC_TRANSACTION_HEADERS.TRANSACTION_TYPE_CODE%TYPE
    ,transaction_sub_type        IGI_IAC_TRANSACTION_HEADERS.TRANSACTION_SUB_TYPE%TYPE
    ,adjustment_status           IGI_IAC_TRANSACTION_HEADERS.ADJUSTMENT_STATUS%TYPE
    ,validate_business_rules     BOOLEAN     DEFAULT FALSE /* whether the business rules should be validated ? */
    ,first_time_flag             BOOLEAN     DEFAULT FALSE /* whether this routine is called for the first time */
    ,message_level               NUMBER      DEFAULT 0     /*(0- None, 1 -Low, 2-Normal, 3- high)   Message Severity level */
    ,create_acctg_entries        BOOLEAN     DEFAULT FALSE /* create accounting entries at the end of the processing */
    ,crud_allowed                BOOLEAN     DEFAULT FALSE /* create, update, delete allowed ? */
    ,modify_balances             BOOLEAN     DEFAULT FALSE /* Update Balance information at the end of the processing */
    ,commit_flag                 BOOLEAN     DEFAULT FALSE /* commit the changes at the end ? */
    ,print_report                BOOLEAN     DEFAULT FALSE /* Print Revaluation Report */
    ,mixed_scenario              BOOLEAN     DEFAULT FALSE /* Mixed Scenario ? */
    ,show_exceptions             BOOLEAN      DEFAULT FALSE /* Maintain list of failed validations */
    ,calling_program             VARCHAR2(30) DEFAULT NULL  /* how the revaluation is being called */
    );

     type     iac_reval_asset_params   IS RECORD
    (
     asset_id                   fa_additions.asset_id%TYPE    DEFAULT 0
    ,book_type_code             fa_book_controls.book_type_code%TYPE DEFAULT NULL
    ,revaluation_id             igi_iac_revaluations.revaluation_id%TYPE DEFAULT 0
    ,revaluation_rate           igi_iac_reval_asset_rules.revaluation_factor%TYPE DEFAULT 0
    ,revaluation_date           igi_iac_revaluations.revaluation_date%TYPE
    ,period_counter             fa_book_controls.last_period_counter%TYPE  DEFAULT 0
    ,category_id                fa_additions.asset_category_id%TYPE DEFAULT 0
    ,first_set_adjustment_id    igi_iac_adjustments.adjustment_id%TYPE default 0
    ,second_set_adjustment_id   igi_iac_adjustments.adjustment_id%TYPE default 0
    ,prev_ytd_deprn             fa_deprn_summary.ytd_deprn%TYPE default 0
    ,ytd_deprn_mvmt             fa_deprn_summary.ytd_deprn%TYPE default 0
    ,curr_ytd_deprn_first       fa_deprn_summary.ytd_deprn%TYPE default 0
    ,curr_ytd_deprn_next        fa_deprn_summary.ytd_deprn%TYPE default 0
    ,prev_ytd_opacc             fa_deprn_summary.ytd_deprn%TYPE default 0
    ,curr_ytd_opacc_first       fa_deprn_summary.ytd_deprn%TYPE default 0
    ,curr_ytd_opacc_next        fa_deprn_summary.ytd_deprn%TYPE default 0
    );

    type     fa_hist_asset_info   IS RECORD
    (
     cost                               fa_books.cost%TYPE default 0
    ,adjusted_cost                      fa_books.adjusted_cost%TYPE default 0
    ,original_cost                      fa_books.original_cost%TYPE default 0
    ,salvage_value                      fa_books.salvage_value%TYPE default 0
    ,life_in_months                     fa_books.life_in_months%TYPE default 0
    ,rate_adjustment_factor             fa_books.rate_adjustment_factor%TYPE default 0
    ,period_counter_fully_reserved      fa_books.period_counter_fully_reserved%TYPE default 0
    ,adjusted_recoverable_cost          fa_books.adjusted_recoverable_cost%TYPE default 0
    ,recoverable_cost                   fa_books.recoverable_cost%TYPE default 0
    ,date_placed_in_service             fa_books.date_placed_in_service%TYPE default null
    ,deprn_periods_elapsed              number(15) default 0
    ,deprn_periods_current_year         number(15) default 0
    ,deprn_periods_prior_year           number(15) default 0
    ,last_period_counter                fa_book_controls.last_period_counter%TYPE  default 0
    ,gl_posting_allowed_flag            fa_book_controls.gl_posting_allowed_flag%TYPE  default null
    ,ytd_deprn                          fa_deprn_summary.ytd_deprn%TYPE  default 0
    ,deprn_reserve                      fa_deprn_summary.deprn_reserve%TYPE default 0
    ,pys_deprn_reserve                  fa_deprn_summary.deprn_reserve%TYPE default 0
    ,deprn_amount                       fa_deprn_summary.deprn_amount%TYPE default 0
    ,deprn_start_date                   fa_books.deprn_start_date%TYPE default null
    ,depreciate_flag                    fa_books.depreciate_flag%Type default null
    );

    subtype  iac_reval_rate_params     is igi_iac_revaluation_rates%ROWTYPE;


    type     iac_reval_exception_line  IS RECORD
    (
     asset_id                   fa_additions.asset_id%TYPE   DEFAULT 0
    ,book_type_code             fa_book_controls.book_type_code%TYPE  DEFAULT NULL
    ,reason                     varchar2(2000) DEFAULT NULL	-- Bug No. 2647561 (Tpradhan) - Increased the length from 200 to 2000
    );

    TYPE    iac_reval_exceptions           is table of iac_reval_exception_line index by binary_integer;
    subtype iac_reval_exceptions_idx       is binary_integer;

    TYPE    iac_reval_mesg_Table           is table of iac_reval_mesg_line index by binary_integer;
    subtype iac_reval_mesg                 is iac_reval_mesg_table ;
    subtype iac_reval_mesg_idx             is binary_integer ;

    subtype iac_Reval_output_asset         is igi_iac_asset_balances%rowtype;

    subtype iac_reval_output_dists_rec     is igi_iac_det_balances%rowtype;
    TYPE    iac_reval_output_dists         is table of iac_reval_output_dists_rec ;
    subtype iac_reval_output_dists_idx     is binary_integer ;

    type    iac_reval_params               is   record
    (
      reval_control                             iac_reval_control_type
    , reval_asset_params                        iac_reval_asset_params
    , reval_input_asset                         iac_reval_input_asset
    , reval_output_asset                        iac_reval_output_asset
    , reval_output_asset_mvmt                   iac_reval_output_asset
    , reval_prev_rate_info                      iac_reval_rate_params
    , reval_curr_rate_info_first                iac_reval_rate_params
    , reval_curr_rate_info_next                 iac_reval_rate_params
    , reval_asset_rules                         iac_reval_asset_rules
    , reval_asset_exceptions                    iac_reval_exception_line
    , fa_asset_info                             fa_hist_asset_info
    ) ;

--    TYPE iac_reval_params_tab IS TABLE OF iac_reval_params INDEX BY BINARY_INTEGER;
    TYPE iac_reval_control_tab  IS TABLE OF iac_reval_control_type INDEX BY BINARY_INTEGER;
    TYPE iac_reval_asset_params_tab IS TABLE OF iac_reval_asset_params INDEX BY BINARY_INTEGER;
    TYPE iac_reval_asset_tab IS TABLE OF iac_reval_input_asset INDEX BY BINARY_INTEGER;
    TYPE iac_reval_asset_rules_tab IS TABLE OF iac_reval_asset_rules INDEX BY BINARY_INTEGER;
    TYPE iac_reval_rates_tab IS TABLE OF iac_reval_rate_params INDEX BY BINARY_INTEGER;
    TYPE iac_reval_exceptions_tab IS TABLE OF iac_reval_exception_line INDEX BY BINARY_INTEGER;
    TYPE iac_reval_fa_asset_info_tab IS TABLE OF fa_hist_asset_info INDEX BY BINARY_INTEGER;
/** end revaluation info **/

/** begin adjustments  info **/

    type     Iac_adj_hist_asset_info   IS RECORD
    (
     asset_id                   fa_additions.asset_id%TYPE   DEFAULT 0
    ,book_type_code             fa_book_controls.book_type_code%TYPE  DEFAULT NULL
    ,cost                               fa_books.cost%TYPE default 0
    ,adjusted_cost                      fa_books.adjusted_cost%TYPE default 0
    ,original_cost                      fa_books.original_cost%TYPE default 0
    ,salvage_value                      fa_books.salvage_value%TYPE default 0
    ,life_in_months                     fa_books.life_in_months%TYPE default 0
    ,rate_adjustment_factor             fa_books.rate_adjustment_factor%TYPE default 0
    ,period_counter_fully_reserved      fa_books.period_counter_fully_reserved%TYPE default 0
    ,adjusted_recoverable_cost          fa_books.adjusted_recoverable_cost%TYPE default 0
    ,recoverable_cost                   fa_books.recoverable_cost%TYPE default 0
    ,date_placed_in_service             fa_books.date_placed_in_service%TYPE default null
    ,deprn_periods_elapsed              number(15) default 0
    ,deprn_periods_current_year         number(15) default 0
    ,deprn_periods_prior_year           number(15) default 0
    ,last_period_counter                fa_book_controls.last_period_counter%TYPE  default 0
    ,gl_posting_allowed_flag            fa_book_controls.gl_posting_allowed_flag%TYPE  default null
    ,ytd_deprn                          fa_deprn_summary.ytd_deprn%TYPE  default 0
    ,deprn_reserve                      fa_deprn_summary.deprn_reserve%TYPE default 0
    ,pys_deprn_reserve                  fa_deprn_summary.deprn_reserve%TYPE default 0
    ,deprn_amount                       fa_deprn_summary.deprn_amount%TYPE default 0
    ,deprn_start_date                   fa_books.deprn_start_date%TYPE default null
    ,depreciate_flag                    fa_books.depreciate_flag%Type default null
    ,deprn_adjustment_amount            fa_deprn_detail.deprn_adjustment_amount%TYPE  default 0

    );

    type     Iac_adj_hist_dist_info   IS RECORD
    (
     asset_id                           fa_additions.asset_id%TYPE   DEFAULT 0
    ,book_type_code                     fa_book_controls.book_type_code%TYPE  DEFAULT NULL
    ,distribution_id                    fa_deprn_detail.distribution_id%TYPE  default 0
    ,Period_counter                     fa_deprn_detail.Period_counter%TYPE  default 0
    ,deprn_amount                       fa_deprn_detail.deprn_amount%TYPE  default 0
    ,ytd_deprn                          fa_deprn_detail.ytd_deprn%TYPE  default 0
    ,deprn_reserve                      fa_deprn_detail.deprn_reserve%TYPE default 0
    ,deprn_adjustment_amount              fa_deprn_detail.DEPRN_ADJUSTMENT_AMOUNT%TYPE  default 0
    ,deprn_periods_elapsed              number(15) default 0
    ,deprn_periods_current_year         number(15) default 0
    ,deprn_periods_prior_year           number(15) default 0
    ,start_period_counter               fa_book_controls.last_period_counter%TYPE  default 0
    ,last_period_counter                fa_book_controls.last_period_counter%TYPE  default 0
    ,pys_deprn_reserve                  fa_deprn_detail.deprn_reserve%TYPE default 0
    ,current_deprn_reserve              fa_deprn_detail.deprn_reserve%TYPE default 0
    );

     TYPE iac_adj_asset_info_tab IS TABLE OF Iac_adj_hist_asset_info  INDEX BY BINARY_INTEGER;
     TYPE iac_adj_dist_info_tab  IS TABLE OF Iac_adj_hist_dist_info   INDEX BY BINARY_INTEGER;
/** end Adjutsmemts  info **/

END;

 

/
