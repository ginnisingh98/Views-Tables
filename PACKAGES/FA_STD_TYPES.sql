--------------------------------------------------------
--  DDL for Package FA_STD_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_STD_TYPES" AUTHID CURRENT_USER as
/* $Header: faxstds.pls 120.26.12010000.3 2009/07/24 15:44:36 deemitta ship $ */

  --
  -- Private Inter-Package Types
  --
  -- Following types are used to construct nested record type of table type
  --
  TYPE number_tbl_type IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;

  TYPE date_tbl_type IS TABLE OF DATE
        INDEX BY BINARY_INTEGER;

  TYPE boolean_tbl_type IS TABLE OF BOOLEAN
        INDEX BY BINARY_INTEGER;

  TYPE varchar2_tbl_type IS TABLE OF VARCHAR2(1000)
        INDEX BY BINARY_INTEGER;

-- Global variable holding the accessability against FA_OVERRIDE_TABLE
  deprn_override_trigger_enabled           Boolean:= TRUE;

  --
  -- Standard data types for all summary modules
  --

  --
  --  Usage     : An IN parameter to Depreciation Engine.
  --  Arguments :
  --    adj_cost            : Adjusted Cost
  --    rec_cost            : Recoverable Cost
  --    reval_amo_basis     : Revlauation Amortization
  --    deprn_rsv           : Depreciation Reserve
  --    reval_rsv           : Revaluation Reserve
  --    adj_rate            : Adjusted Rate (Flat Rates)
  --    rate_adj_factor     : Rate Adjustment Factor
  --    capacity            : Production Capacity
  --    adj_capacity        : Adjusted Capacity
  --    ltd_prod            : Life-to-date Production
  --    asset_num           : Asset Number
  --    calendar_type       : Depreciation Calendar
  --    ceil_name           : Ceiling Name
  --    bonus_rule          : Bonus Rule
  --    book                : Book Type Code
  --    method_code         : Depreciation Method Code
  --    asset_id            : Asset ID
  --    jdate_in_service    : DPIS (Julian Date)
  --    prorate_jdate       : Prorate Date (Julian Date)
  --    deprn_start_jdate   : Deprn Start Date (Julian Date)
  --    jdate_retired       : Date Retired (Julian Date)
  --    ret_prorate_jdate   : Retirement Prorate Date (JJulian Date)
  --    life                : Asset Life in Months
  --    y_begin             : Year to Begin calculation
  --    y_end               : Year to End calculation
  --    p_cl_begin          : Period to Begin calculation
  --    p_cl_end            : Period to End calculation
  --    rsv_known_flag      : Reserve (deprn_rsv) is valid
  --    salvage_value       : Salvage Value
  --    pc_life_end         : Period Counter Life Complete
  --    adj_rec_cost        : Adjusted Recoverable Cost
  --    prior_fy_exp        : Total Prior FY Depreciation Expenases
  --    deprn_rounding_flag : Annual Deprn Rounding Flag
  --    ytd_deprn           : YTD Depreciation Expense
  --    capital_adjustmnent : Capital Adjustment balance used for SORP
  --    general_fund        : General Fund balance used for SORP

  TYPE dpr_struct IS RECORD (
        adj_cost                   FA_BOOKS.Adjusted_Cost%TYPE,
        rec_cost                   FA_BOOKS.Recoverable_Cost%TYPE,
        reval_amo_basis            FA_BOOKS.Reval_Amortization_Basis%TYPE,
        deprn_rsv                  FA_DEPRN_SUMMARY.Deprn_Reserve%TYPE,
        reval_rsv                  FA_DEPRN_SUMMARY.Reval_Reserve%TYPE,
        adj_rate                   FA_BOOKS.Adjusted_Rate%TYPE,
        rate_adj_factor            FA_BOOKS.Rate_Adjustment_Factor%TYPE,
        capacity                   FA_BOOKS.Production_Capacity%TYPE,
        adj_capacity               FA_BOOKS.Adjusted_Capacity%TYPE,
        ltd_prod                   FA_DEPRN_SUMMARY.Ltd_Production%TYPE,
        asset_num                  FA_ADDITIONS.Asset_Number%TYPE,
        calendar_type              FA_CALENDAR_TYPES.Calendar_Type%TYPE,
        ceil_name                  FA_BOOKS.Ceiling_Name%TYPE,
        bonus_rule                 FA_BOOKS.Bonus_Rule%TYPE,
        book                       FA_BOOKS.Book_Type_Code%TYPE,
        method_code                FA_BOOKS.Deprn_Method_Code%TYPE,
        asset_id                   FA_BOOKS.Asset_Id%TYPE,
        jdate_in_service           NUMBER,
        prorate_jdate              NUMBER,
        deprn_start_jdate          NUMBER,
        jdate_retired              NUMBER,
        ret_prorate_jdate          NUMBER,
        life                       FA_BOOKS.Life_In_Months%TYPE,
        y_begin                    NUMBER,
        y_end                      NUMBER,
        p_cl_begin                 NUMBER,
        p_cl_end                   NUMBER,
        rsv_known_flag             BOOLEAN,
        salvage_value              FA_BOOKS.Salvage_Value%TYPE,
        pc_life_end                FA_BOOKS.Period_Counter_Life_Complete%TYPE,
        adj_rec_cost               FA_BOOKS.Adjusted_Recoverable_Cost%TYPE,
        prior_fy_exp               FA_DEPRN_SUMMARY.Prior_Fy_Expense%TYPE,
        deprn_rounding_flag        FA_BOOKS.Annual_Deprn_Rounding_Flag%TYPE,
        deprn_override_flag        FA_DEPRN_SUMMARY.Deprn_Override_Flag%TYPE,
        used_by_adjustment         BOOLEAN,
        ytd_deprn                  FA_DEPRN_SUMMARY.Ytd_Deprn%TYPE,
        short_fiscal_year_flag     FA_BOOKS.short_fiscal_year_flag%TYPE,
        conversion_date            FA_BOOKS.conversion_date%TYPE,
        prorate_date               FA_BOOKS.prorate_date%TYPE,
        orig_deprn_start_date      FA_BOOKS.original_deprn_start_date%TYPE,
        old_adj_cost               FA_BOOKS.old_adjusted_cost%TYPE,
        formula_factor             FA_BOOKS.formula_factor%TYPE,
        bonus_deprn_exp            FA_DEPRN_SUMMARY.Bonus_Deprn_Amount%TYPE, -- YYOON
        bonus_ytd_deprn            FA_DEPRN_SUMMARY.Bonus_Ytd_Deprn%TYPE,
        bonus_deprn_rsv            FA_DEPRN_SUMMARY.Bonus_Deprn_Reserve%TYPE,
        prior_fy_bonus_exp         FA_DEPRN_SUMMARY.Prior_FY_Bonus_Expense%TYPE,
        mrc_sob_type_code       VARCHAR2(1),
        set_of_books_id            NUMBER,
        tracking_method            FA_BOOKS.Tracking_Method%TYPE,
        allocate_to_fully_ret_flag FA_BOOKS.Allocate_to_Fully_Ret_Flag%TYPE,
        allocate_to_fully_rsv_flag FA_BOOKS.Allocate_to_Fully_Rsv_Flag%TYPE,
        excess_allocation_option   FA_BOOKS.Excess_Allocation_Option%TYPE,
        depreciation_option        FA_BOOKS.Depreciation_Option%TYPE,
        member_rollup_flag         FA_BOOKS.Member_Rollup_Flag%TYPE,
        eofy_reserve               FA_BOOKS.eofy_reserve%TYPE,
        update_override_status     BOOLEAN,
        over_depreciate_option     FA_BOOKS.Over_Depreciate_Option%TYPE,
        super_group_id             FA_BOOKS.super_group_id%TYPE,
        cost                       FA_BOOKS.cost%TYPE,
        asset_type                 FA_ADDITIONS_B.ASSET_TYPE%TYPE,
        impairment_exp             FA_DEPRN_SUMMARY.IMPAIRMENT_AMOUNT%TYPE,
        ytd_impairment             FA_DEPRN_SUMMARY.YTD_IMPAIRMENT%TYPE,
        impairment_rsv             FA_DEPRN_SUMMARY.impairment_reserve%TYPE,
        calc_catchup               BOOLEAN, -- Bug 5738004
        cost_frac                  NUMBER, -- Bug 5893429
        transaction_type_code      FA_TRANSACTION_HEADERS.Transaction_Type_Code%TYPE, -- Bug:6349882
        capital_adjustment         FA_DEPRN_SUMMARY.capital_adjustment%TYPE, -- Bug 6666666
        general_fund               FA_DEPRN_SUMMARY.general_fund%TYPE,       -- Bug 6666666
        override_period_counter    NUMBER  -- Bug 8211842
        );


  --  Usage     : A OUT parameter from Depreciation Engine.
  --  Arguments :
  --    new_deprn_rsv       : New Deprn Reserve
  --    new_adj_cost        : New Adjusted Cost
  --    new_reval_rsv       : New Revaluation Reserve
  --    new_reval_amo_basis : New Revaluation Amortization Basis
  --    new_adj_capacity    : New Adjusted Capacity
  --    new_ltd_prod        : New Life-To-Date Production
  --    deprn_exp           : Depreciation Expense
  --    reval_exp           : Deprn Expense due to Revaluation
  --    reval_amo           : Revaluation Reserve Amortization
  --    prod                : Units of Production
  --    ann_adj_exp         : Annualized Adjustment to Deprn Expense
  --    ann_adj_reval_exp   : Annualized Adjustment to Deprn Expense due to Reval
  --    ann_adj_reval_amo   : Annualized Adjustment to Revaluation Amortization
  --    bonus_rate_used     : Bonus Rate used
  --    deprn_factor_used   : Deprn Factor used
  --    alternate_deprn_factor_used
  --                        : Alternate Deprn Factor used
  --    full_rsv_flag       : Asset Fully-Reserved flag
  --    life_comp_flag      : Asset Life Complete flag
  --    new_prior_fy_exp    : New Depreciation Expense for all Prior Fiscal Years
  --    new_bonus_deprn_rsv : New Bonus Deprn Reserve
  --    new_ytd_deprn       : New Year to date Depreciation
  --    new_eofy_reserve     : New Eofy Amount
  --
  TYPE dpr_out_struct IS RECORD (
        new_deprn_rsv           FA_DEPRN_DETAIL.Deprn_reserve%TYPE,
        new_adj_cost            FA_BOOKS.Adjusted_Cost%TYPE,
        new_reval_rsv           FA_DEPRN_SUMMARY.Reval_Reserve%TYPE,
        new_reval_amo_basis     FA_BOOKS.Reval_Amortization_Basis%TYPE,
        new_adj_capacity        FA_BOOKS.Adjusted_Capacity%TYPE,
        new_ltd_prod            FA_DEPRN_SUMMARY.Ltd_Production%TYPE,
        deprn_exp               FA_DEPRN_DETAIL.Reval_deprn_expense%TYPE,
        reval_exp               FA_DEPRN_DETAIL.Reval_deprn_expense%TYPE,
        reval_amo               FA_DEPRN_DETAIL.Reval_amortization%TYPE,
        prod                    FA_DISTRIBUTION_HISTORY.Units_Assigned%TYPE,
        ann_adj_exp             FA_DEPRN_DETAIL.Reval_Deprn_Expense%TYPE,
        ann_adj_reval_exp       FA_DEPRN_DETAIL.Ytd_Reval_Deprn_Expense%TYPE,
        ann_adj_reval_amo       FA_DEPRN_DETAIL.Reval_Amortization%TYPE,
        bonus_rate_used         NUMBER,
        deprn_factor_used       NUMBER,
        alternate_deprn_factor_used
                                NUMBER,
        full_rsv_flag           BOOLEAN,
        life_comp_flag          BOOLEAN,
        bonus_deprn_exp         FA_DEPRN_SUMMARY.Bonus_Deprn_Amount%TYPE, -- YYOON
        impairment_exp          FA_DEPRN_SUMMARY.Impairment_Amount%TYPE,
        new_prior_fy_exp        FA_DEPRN_SUMMARY.Prior_Fy_Expense%TYPE,
        new_bonus_deprn_rsv     FA_DEPRN_SUMMARY.Bonus_Deprn_Reserve%TYPE,
        new_prior_fy_bonus_exp  FA_DEPRN_SUMMARY.Prior_FY_Bonus_Expense%TYPE,
        new_impairment_rsv      FA_DEPRN_SUMMARY.impairment_reserve%TYPE,
        deprn_override_flag     FA_DEPRN_SUMMARY.Deprn_Override_Flag%TYPE,
        new_ytd_deprn           FA_DEPRN_SUMMARY.Ytd_Deprn%TYPE,
        new_eofy_reserve        FA_BOOKS.eofy_reserve%TYPE,
        new_capital_adjustment         FA_DEPRN_SUMMARY.capital_adjustment%TYPE, -- Bug 6666666
        new_general_fund               FA_DEPRN_SUMMARY.general_fund%TYPE       -- Bug 6666666
        );
--
-- bonus? necessary? from fa_cde_pkg:if so we need to add to dpr_out_struct.
-- dpr_out.bonus_deprn_amount := bonus_deprn_exp_sum;


  -- Usage     : Used to store depreciaton info for an asset
  -- Arguments : Union of all columns in FA_DEPRN_DETAIL and
  --             FA_DEPRN_SUMMARY tables
  --
  TYPE fa_deprn_row_struct IS RECORD (
        asset_id                NUMBER,
        book                    VARCHAR2(15),
        dist_id                 NUMBER,
        period_ctr              NUMBER,
        adjusted_flag           BOOLEAN,
        deprn_exp               NUMBER,
        reval_deprn_exp         NUMBER,
        reval_amo               NUMBER,
        prod                    NUMBER,
        ytd_deprn               NUMBER,
        ytd_reval_deprn_exp     NUMBER,
        ytd_prod                NUMBER,
        deprn_rsv               NUMBER,
        reval_rsv               NUMBER,
        ltd_prod                NUMBER,
        cost                    NUMBER,
        add_cost_to_clear       NUMBER,
        adj_cost                NUMBER,
        reval_amo_basis         NUMBER,
        bonus_rate              NUMBER,
        deprn_adjust_exp        NUMBER,
        deprn_source_code       VARCHAR2(15),
        prior_fy_exp            NUMBER,
        bonus_deprn_rsv         NUMBER,
        bonus_ytd_deprn         NUMBER,
        bonus_deprn_amount      NUMBER,
        prior_fy_bonus_exp      NUMBER,
        impairment_rsv          NUMBER,
        ytd_impairment          NUMBER,
        impairment_amount       NUMBER,
        deprn_override_flag     VARCHAR2(1),
        asset_type              VARCHAR2(30),
        member_rollup_flag      VARCHAR2(1),
        mrc_sob_type_code       VARCHAR2(1),
        set_of_books_id         NUMBER,
        capital_adjustment NUMBER, -- Bug 6666666
        general_fund NUMBER        -- Bug 6666666
        );

  -- Usage     : To construct fa_deprn_row_struct record type of table
  -- Arguments : Should match the same arguments in fa_deprn_row_struct type
  --
  TYPE table_fa_deprn_row_struct IS RECORD (
        asset_id                number_tbl_type,
        book                    varchar2_tbl_type,
        dist_id                 number_tbl_type,
        period_ctr              number_tbl_type,
        adjusted_flag           boolean_tbl_type,
        deprn_exp               number_tbl_type,
        reval_deprn_exp         number_tbl_type,
        reval_amo               number_tbl_type,
        prod                    number_tbl_type,
        ytd_deprn               number_tbl_type,
        ytd_reval_deprn_exp     number_tbl_type,
        ytd_prod                number_tbl_type,
        deprn_rsv               number_tbl_type,
        reval_rsv               number_tbl_type,
        ltd_prod                number_tbl_type,
        cost                    number_tbl_type,
        add_cost_to_clear       number_tbl_type,
        adj_cost                number_tbl_type,
        reval_amo_basis         number_tbl_type,
        bonus_rate              number_tbl_type,
        deprn_adjust_exp        number_tbl_type,
        deprn_source_code       varchar2_tbl_type,
        prior_fy_exp            number_tbl_type,
        bonus_deprn_rsv         number_tbl_type,
        bonus_ytd_deprn         number_tbl_type,
        bonus_deprn_amount      number_tbl_type,
        prior_fy_bonus_exp      number_tbl_type,
    impairment_rsv          number_tbl_type,
    ytd_impairment          number_tbl_type,
    impairment_amount       number_tbl_type,
    capital_adjustment      number_tbl_type, -- Bug 6666666
    general_fund            number_tbl_type  -- Bug 6666666
  );

  --
  -- Usage    : Stores fraction of fiscal year for periods based on
  --            period start date, period end date and deprn_alloc_code.
  --            It is used by depreciation engine to calcuate deprn rate.
  -- Arguments:
  --    frac        : Fraction of Fiscal Year
  --    start_jdate : Period Start Date (Julian Date)
  --    end_jdate   : period End Date (Julian)
  --
  TYPE fa_cp_struct IS RECORD (
        frac                    NUMBER,
        start_jdate             NUMBER,
        end_jdate               NUMBER);

  TYPE table_fa_cp_struct is TABLE of fa_cp_struct
  INDEX BY BINARY_INTEGER;


  TYPE dpr_arr_rec_type IS RECORD (
        value           number,
        bonus_value     number,
        period_num      number,
        fiscal_year     number);

  TYPE dpr_arr_type is TABLE of dpr_arr_rec_type
        index by binary_integer;

  --  Usage     : Used to store values used in processing financial
  --              changes (Amortized or Expensed) of an asset
  --  Arguments :
  --    asset_id           : Asset ID
  --    category_id        : Asset's Category ID
  --    transaction_id     : Transaction Header ID
  --    jdate_in_svc       : Date Placed in Svc (Julian Date)
  --    period_ctr         : Current Period Counter
  --    dep_flag           : Depreciate Flag: 'YES'=TRUE, 'NO'=FALSE
  --    book               : Book
  --    asset_number       : Asset Number
  --    asset_type         : Asset Type
  --    date_placed_in_svc : Date Placed in Svc, Format: DD-MON-YYYY
  --    prorate_date       : Prorate Date, Format: DD-MON-YYYY
  --    deprn_start_date   : Deprn Start Date, Format: DD-MON-YYYY
  --    ceiling_name       : Ceiling Name
  --    bonus_rule         : Bonus Rule Name
  --    current_time       : Sysdate for Last Update Date
  --                         Format:DD-MON-YYYY HH24:MI:SS
  --    method_code        : Deprn Method Code
  --    cost               : Cost AFTER change
  --    old_cost           : Cost BEFORE change
  --    rec_cost           : Recoverable Cost
  --    adj_cost           : Adjusted Cost
  --    rate_adj_factor    : Rate Adjustment Factor
  --    adj_rate           : Adjusted Rate
  --    units              : Current Units
  --    reval_amo_basis    : Reval Amort Basis
  --    capacity           : Production Capacity
  --    adj_capacity       : Adjusted Capacity
  --    life               : Asset Life in Months
  --    adj_rec_cost       : Adjusted Recoverable Cost
  --    salvage_value      : Salvage Value
  --    deprn_rounding_flag: Annual Deprn Rounding Flag
  --    amortization_start_date :Amortization Start Date(Dated Adjustment)
  --    adj_amount         : Adjustment Amount(Dated Adjustment)
  --

  TYPE fin_info_struct IS RECORD (
        asset_id                NUMBER,
        category_id             NUMBER,
        transaction_id          NUMBER,
        jdate_in_svc            NUMBER,
        period_ctr              NUMBER,
        dep_flag                BOOLEAN,
        book                    VARCHAR2(15),
        asset_number            VARCHAR2(15),
        asset_type              VARCHAR2(11),
        date_placed_in_svc      DATE,
        prorate_date            DATE,
        deprn_start_date        DATE,
        ceiling_name            VARCHAR2(30),
        bonus_rule              VARCHAR2(30),
        current_time            DATE,
        method_code             VARCHAR2(12),
        cost                    NUMBER,
        old_cost                NUMBER,
        rec_cost                NUMBER,
        adj_cost                NUMBER,
        rate_adj_factor         NUMBER,
        adj_rate                NUMBER,
        units                   NUMBER,
        reval_amo_basis         NUMBER,
        capacity                NUMBER,
        adj_capacity            NUMBER,
        life                    NUMBER,
        adj_rec_cost            NUMBER,
        salvage_value           NUMBER,
        deprn_rounding_flag     VARCHAR2(5),
        amortization_start_date DATE,
        adj_amount              NUMBER,
        short_fiscal_year_flag  VARCHAR2(3),
        conversion_date         DATE,
        orig_deprn_start_date   DATE,
        old_adj_cost            NUMBER,
        formula_factor          NUMBER,
        running_mode            NUMBER,
        used_by_revaluation     NUMBER,
        deprn_override_flag     Varchar2(1),
        set_of_books_id         NUMBER);


  --  Usage     : Used by INSERT_DETAIL user_exit to insert row into
  --              FA_DEPRN_DETAIL table
  --  Arguments :
  --
  TYPE dpr_dtl_row_struct IS RECORD (
        book                    VARCHAR2(15),
        asset_id                NUMBER,
        period_counter          NUMBER,
        cost                    NUMBER,
        ytd                     NUMBER,
        deprn_reserve           NUMBER,
/* Bug 525654 Modification */
        deprn_adjustment_amount         NUMBER,
        reval_reserve           NUMBER,
        ytd_reval_dep_exp       NUMBER,
        reval_rsv_flag          BOOLEAN,
        ytd_reval_dep_exp_flag  BOOLEAN,
        bonus_ytd               NUMBER,
        bonus_deprn_reserve     NUMBER,
        bonus_deprn_amount      NUMBER,
        bonus_deprn_adj_amount  NUMBER,
        deprn_amount            NUMBER,
        reval_amortization      NUMBER,
        reval_deprn_expense     NUMBER,
        impairment_amount       NUMBER,
        ytd_impairment          NUMBER,
        impairment_reserve          NUMBER,
        capital_adjustment NUMBER, --Bug 6666666
        general_fund       NUMBER --Bug 6666666
        );
  --
  -- The following data types are used in Depreciation Module
  --

  TYPE fa_dp_global_info IS RECORD (
        undistributed_assets    NUMBER,
        user_Id                 NUMBER,
        login_id                NUMBER,
        request_id              NUMBER,
        total_requests          NUMBER,
        request_number          NUMBER);

  TYPE fa_dp_book_info IS RECORD (
        book                    VARCHAR2(15),
        deprn_calendar          VARCHAR2(15),
        rate_calendar           VARCHAR2(15),
        dist_book               VARCHAR2(15),
        fy_name                 VARCHAR2(30),
        cp_start_date           DATE,
        cp_end_date             DATE,
        last_update_date        DATE,
        ccp_start_date          DATE,
        ccp_end_date            DATE,
        cur_per_ctr             NUMBER,
        cur_per_num             NUMBER,
        cur_fy                  NUMBER,
        pers_per_yr             NUMBER,
        rate_pers_per_yr        NUMBER);

  TYPE dh_adj_type IS RECORD (
        dist_id                 NUMBER,
        ccid                    NUMBER,
        units                   NUMBER,
        active_flag             BOOLEAN,
        deprn                   fa_deprn_row_struct);

  TYPE table_dh_adj_type IS RECORD (
        dist_id                 number_tbl_type,
        ccid                    number_tbl_type,
        units                   number_tbl_type,
        active_flag             boolean_tbl_type,
        deprn                   table_fa_deprn_row_struct,
        num_of_rows             NUMBER);

  TYPE fa_dp_asset_info IS RECORD (
        asset_id                        NUMBER,
        category_id                     NUMBER,
        thid                            NUMBER,
        adj_reqd                        NUMBER,
        cost_change                     BOOLEAN,
        ret_pending                     BOOLEAN,
        fully_ret                       NUMBER,
        fully_rsv                       BOOLEAN,
        active_dists                    BOOLEAN,
        annual_deprn_rounding_flag      VARCHAR2(5),
        life_complete                   BOOLEAN,
        dpr                             dpr_struct,
        dpr_out                         dpr_out_struct,
        summary                         dh_adj_type,
        dists                           table_dh_adj_type);

  TYPE inv_type IS RECORD (
        pay_ccid                NUMBER,
        asset_inv_id            NUMBER,
        cost                    NUMBER,
        cost_inserted           NUMBER);

  TYPE fa_adj_row_struct IS RECORD (
        transaction_header_id           NUMBER,
        asset_invoice_id                NUMBER,
        source_type_code                VARCHAR2(15),
        adjustment_type                 VARCHAR2(15),
        debit_credit_flag               VARCHAR2(2),
        code_combination_id             NUMBER,
        book_type_code                  VARCHAR2(15),
        period_counter_created          NUMBER,
        asset_id                        NUMBER,
        adjustment_amount               NUMBER,
        period_counter_adjusted         NUMBER,
        distribution_id                 NUMBER,
        annualized_adjustment           NUMBER,
        last_update_date                DATE,
        account                         VARCHAR2(25),
        account_type                    VARCHAR2(55),
        current_units                   NUMBER,
        selection_mode                  NUMBER,
        selection_thid                  NUMBER,
        selection_retid                 NUMBER,
        flush_adj_flag                  NUMBER,
        gen_ccid_flag                   NUMBER,
        amount_inserted                 NUMBER,
        units_retired                   NUMBER,
        leveling_flag                   NUMBER);

TYPE txn_hdr_rec IS RECORD (
        transaction_header_id           NUMBER(15),
        book_type_code                  VARCHAR2(15),
        asset_id                        NUMBER(15),
        transaction_type_code           VARCHAR2(20),
        transaction_date_entered        DATE,
        date_effective                  DATE,
        last_update_date                DATE,
        last_updated_by                 NUMBER(15),
        transaction_name                VARCHAR2(30),
        invoice_transaction_id          NUMBER(15),
        source_transaction_header_id    NUMBER(15),
        mass_reference_id               NUMBER(15),
        last_update_login               NUMBER(15),
        transaction_subtype             VARCHAR2(9),
        attribute1                      VARCHAR2(150),
        attribute2                      VARCHAR2(150),
        attribute3                      VARCHAR2(150),
        attribute4                      VARCHAR2(150),
        attribute5                      VARCHAR2(150),
        attribute6                      VARCHAR2(150),
        attribute7                      VARCHAR2(150),
        attribute8                      VARCHAR2(150),
        attribute9                      VARCHAR2(150),
        attribute10                     VARCHAR2(150),
        attribute11                     VARCHAR2(150),
        attribute12                     VARCHAR2(150),
        attribute13                     VARCHAR2(150),
        attribute14                     VARCHAR2(150),
        attribute15                     VARCHAR2(150),
        attribute_category_code         VARCHAR2(30),
        transaction_key                 VARCHAR2(1));

TYPE book_rec IS RECORD (
        book_type_code                  VARCHAR2(15),
        asset_id                        NUMBER(15),
        date_placed_in_service          DATE,
        date_effective                  DATE,
        deprn_start_date                DATE,
        deprn_method_code               VARCHAR2(12),
        life_in_months                  NUMBER(4),
        rate_adjustment_factor          NUMBER,
        adjusted_cost                   NUMBER,
        cost                            NUMBER,
        original_cost                   NUMBER,
        salvage_value                   NUMBER,
        prorate_convention_code         VARCHAR2(10),
        prorate_date                    DATE,
        cost_change_flag                VARCHAR2(3),
        adjustment_required_status      VARCHAR2(4),
        capitalize_flag                 VARCHAR2(3),
        retirement_pending_flag         VARCHAR2(3),
        depreciate_flag                 VARCHAR2(3),
        last_update_date                DATE,
        last_updated_by                 NUMBER(15),
        date_ineffective                DATE,
        transaction_header_id_in        NUMBER(15),
        transaction_header_id_out       NUMBER(15),
        itc_amount_id                   NUMBER(15),
        itc_amount                      NUMBER,
        retirement_id                   NUMBER(15),
        tax_request_id                  NUMBER(15),
        itc_basis                       NUMBER,
        basic_rate                      NUMBER,
        adjusted_rate                   NUMBER,
        bonus_rule                      VARCHAR2(30),
        ceiling_name                    VARCHAR2(30),
        recoverable_cost                NUMBER,
        last_update_login               NUMBER(15),
        adjusted_capacity               NUMBER,
        fully_rsvd_revals_counter       NUMBER(5),
        idled_flag                      VARCHAR2(3),
        period_counter_capitalized      NUMBER(15),
        period_counter_fully_reserved   NUMBER(15),
        period_counter_fully_retired    NUMBER(15),
        production_capacity             NUMBER,
        reval_amortization_basis        NUMBER,
        reval_ceiling                   NUMBER,
        unit_of_measure                 VARCHAR2(25),
        unrevalued_cost                 NUMBER,
        annual_deprn_rounding_flag      VARCHAR2(5),
        percent_salvage_value           NUMBER,
        allowed_deprn_limit             NUMBER,
        allowed_deprn_limit_amount      NUMBER,
        period_counter_life_complete    NUMBER(15),
        adjusted_recoverable_cost       NUMBER,
        annual_rounding_flag            VARCHAR2(5),
        short_fiscal_year_flag          VARCHAR2(3),
        conversion_date                 DATE,
        orig_deprn_start_date           DATE,
        old_adj_cost                    NUMBER,
        formula_factor                  NUMBER,
        rate_source_rule                VARCHAR2(10),
        global_attribute1               VARCHAR2(150),
        global_attribute2               VARCHAR2(150),
        global_attribute3               VARCHAR2(150),
        global_attribute4               VARCHAR2(150),
        global_attribute5               VARCHAR2(150),
        global_attribute6               VARCHAR2(150),
        global_attribute7               VARCHAR2(150),
        global_attribute8               VARCHAR2(150),
        global_attribute9               VARCHAR2(150),
        global_attribute10              VARCHAR2(150),
        global_attribute11              VARCHAR2(150),
        global_attribute12              VARCHAR2(150),
        global_attribute13              VARCHAR2(150),
        global_attribute14              VARCHAR2(150),
        global_attribute15              VARCHAR2(150),
        global_attribute16              VARCHAR2(150),
        global_attribute17              VARCHAR2(150),
        global_attribute18              VARCHAR2(150),
        global_attribute19              VARCHAR2(150),
        global_attribute20              VARCHAR2(150),
        global_attribute_category       VARCHAR2(30));

  -- Depreciable Basis Formula IN Parameters

TYPE fa_deprn_rule_in_struct is RECORD (
        event_type                      VARCHAR2(20),
        asset_id                        NUMBER(15),
        group_asset_id                  NUMBER,
        book_type_code                  VARCHAR2(15),
        asset_type                      VARCHAR2(11),
        depreciate_flag                 VARCHAR2(3),
        method_code                     VARCHAR2(12),
        life_in_months                  NUMBER(4),
        method_id                       NUMBER(15),
        method_type                     VARCHAR2(10),
        calc_basis                      VARCHAR2(4),
        adjustment_amount               NUMBER,
        transaction_flag                VARCHAR2(3),
        cost                            NUMBER,
        salvage_value                   NUMBER,
        recoverable_cost                NUMBER,
        adjusted_recoverable_cost       NUMBER, -- Bug 6704518
        adjusted_cost                   NUMBER,
        current_total_rsv               NUMBER,
        current_rsv                     NUMBER,
        current_total_ytd               NUMBER,
        current_ytd                     NUMBER,
        hyp_basis                       NUMBER,
        hyp_total_rsv                   NUMBER,
        hyp_rsv                         NUMBER,
        hyp_total_ytd                   NUMBER,
        hyp_ytd                         NUMBER,
        old_cost                        NUMBER,
        old_adjusted_cost               NUMBER,
        old_total_adjusted_cost         NUMBER,
        old_raf                         NUMBER,
        old_formula_factor              NUMBER,
        old_reduction_amount            NUMBER,
        -- Added for Group Depreciation
        transaction_header_id           NUMBER(15),
        member_transaction_header_id    NUMBER(15),
        member_transaction_type_code    VARCHAR2(30),
        member_proceeds                 NUMBER,
        transaction_date_entered        DATE,
        amortization_start_date         DATE,
        adj_transaction_header_id       NUMBER(15),
        adj_mem_transaction_header_id   NUMBER(15),
        adj_transaction_date_entered    DATE,
        period_counter                  NUMBER(15),
        fiscal_year                     NUMBER(4),
        period_num                      NUMBER,
        proceeds_of_sale                NUMBER,
        cost_of_removal                 NUMBER,
        nbv_retired                     NUMBER,
        reduction_rate                  NUMBER,
        eofy_reserve                    NUMBER,
        adj_reserve                     NUMBER,
        reserve_retired                 NUMBER,
        recognize_gain_loss             VARCHAR2(30),
        tracking_method                 VARCHAR2(30),
        allocate_to_fully_rsv_flag      VARCHAR2(1),
        allocate_to_fully_ret_flag      VARCHAR2(1),
        excess_allocation_option        VARCHAR2(30),
        depreciation_option             VARCHAR2(30),
        member_rollup_flag              VARCHAR2(30),
        unplanned_amount                NUMBER,
        eofy_recoverable_cost           NUMBER,
        eop_recoverable_cost            NUMBER,
        eofy_salvage_value              NUMBER,
        eop_salvage_value               NUMBER,
        used_by_adjustment              VARCHAR2(30),
        eofy_flag                       VARCHAR2(1),
        apply_reduction_flag            VARCHAR2(1),
        mrc_sob_type_code               VARCHAR2(1),
        set_of_books_id                 NUMBER,
        reduction_amount                NUMBER,
        use_old_adj_cost_flag           VARCHAR2(1),
        polish_rule                     NUMBER,
        deprn_factor                    NUMBER,
        alternate_deprn_factor          NUMBER,
        short_fy_flag                   VARCHAR2(3),
        impairment_reserve              NUMBER,
        use_passed_imp_rsv_flag         VARCHAR2(1),
        allowed_deprn_limit_amount      NUMBER  -- Bug 6786225
        );

  -- Depreciable Basis Formula OUT Parameters

  TYPE fa_deprn_rule_out_struct is RECORD (
        new_adjusted_cost               NUMBER,
        new_total_adjusted_cost         NUMBER,
        new_raf                         NUMBER,
        new_formula_factor              NUMBER,
        new_reduction_amount            NUMBER,
        new_deprn_rounding_flag         VARCHAR2(5) );

  TYPE reval_out_struct is RECORD (
   deprn_rsv_adj                   NUMBER, -- Adjustment to Deprn Reserve
   bonus_deprn_rsv_adj             NUMBER, -- Adjustment to Bonus Deprn Reserve
   impairment_rsv_adj              NUMBER, -- Adjustment to Impairment Reserve
   capital_adjustment_adj          NUMBER, -- Adjustment to the Capital Adjustment -- Bug 6666666
   general_fund_adj                NUMBER, -- Adjustment to the General Fund -- Bug 6666666
   cost_adj                        NUMBER, -- Adjustment to Cost
   reval_rsv_adj                   NUMBER, -- Adjustment to Reval Reserve
   new_life                        NUMBER, -- New Life
   new_adj_cost                    NUMBER, -- New Adjusted Cost
   new_raf                         NUMBER, -- New Rate Adjustment Factor
   new_fully_rsvd_revals_ctr       NUMBER,
   new_rec_cost                    NUMBER, -- New Recoverable Cost
   new_adj_capacity                NUMBER, -- New Adjusted Capacity
   life_notdef                     NUMBER, -- life in months that needs to be
                                   -- defined in FA_METHODS
   pc_fully_res                    NUMBER,
   -- GBertot: Added new member to structure to enable YTD Deprn.
   ytd_deprn_adj                   NUMBER, -- Adjustment to YTD Deprn.
   bonus_ytd_deprn_adj             NUMBER, -- Adjustment to Bonus YTD Deprn.
   ytd_impairment_adj              NUMBER, -- Adjustment to YTD Impairment
   new_formula_factor              NUMBER,
   new_salvage_value               NUMBER,  -- Newly calculated salvage value
   insert_txn_flag                 BOOLEAN);

  -- COMMON CONSTANT
  --
  -- Defines for modes for calling Depreciation Engine faxcde()

  FA_DPR_PROJECT        CONSTANT NUMBER := 1;
  FA_DPR_CLEANUP        CONSTANT NUMBER := 2;
  FA_DPR_NORMAL         CONSTANT NUMBER := 3;
  FA_DPR_RETIRE         CONSTANT NUMBER := 4;
  FA_DPR_CATCHUP        CONSTANT NUMBER := 5; -- Bug 5738004

  -- Constants for Depreciation Rounding Flag in dpr_struct
  FA_DPR_NO_ROUND     CONSTANT VARCHAR2(3) := null;
  FA_DPR_ROUND_ADD    CONSTANT VARCHAR2(3) := 'ADD';
  FA_DPR_ROUND_ADJ    CONSTANT VARCHAR2(3) := 'ADJ';
  FA_DPR_ROUND_RET    CONSTANT VARCHAR2(3) := 'RET';
  FA_DPR_ROUND_REV    CONSTANT VARCHAR2(3) := 'REV';
  FA_DPR_ROUND_TFR    CONSTANT VARCHAR2(3) := 'TFR';
  FA_DPR_ROUND_RES    CONSTANT VARCHAR2(3) := 'RES';
  FA_DPR_ROUND_OVE    CONSTANT VARCHAR2(3) := 'OVE';

  -- Constants for Override Flag
  FA_NO_OVERRIDE      CONSTANT VARCHAR2(1):= 'N';
  FA_OVERRIDE_DPR     CONSTANT VARCHAR2(1):= 'D';
  FA_OVERRIDE_BONUS   CONSTANT VARCHAR2(1):= 'B';
  FA_OVERRIDE_DPR_BONUS   CONSTANT VARCHAR2(1):= 'A';
  FA_OVERRIDE_IMPAIR  CONSTANT VARCHAR2(1):= 'I';
  FA_OVERRIDE_DPR_IMPAIR  CONSTANT VARCHAR2(1):= 'M';
  FA_OVERRIDE_RECURSIVE   CONSTANT VARCHAR2(1):= 'R';
--  FA_OVERRIDE_ERR     CONSTANT VARCHAR2(1):= 'E';

  -- Constants used in Depreciation Module

  FA_DEF_NBV_FRAC       CONSTANT NUMBER := 0.0001;
  FA_DEF_NBV_AMT        CONSTANT NUMBER := 0.10;
  FA_DPR_SMALL_RAF      CONSTANT NUMBER := 0.000000000000000000001;
  FA_ROUND_DECIMAL      CONSTANT NUMBER := 7;

  FA_DPR_ADJ_DEPRN_EXP  CONSTANT NUMBER := 1;
  FA_DPR_ADJ_REVAL_EXP  CONSTANT NUMBER := 2;
  FA_DPR_ADJ_REVAL_AMO  CONSTANT NUMBER := 3;
  FA_DPR_ADJ_DEPRN_RSV  CONSTANT NUMBER := 4;
  FA_DPR_ADJ_REVAL_RSV  CONSTANT NUMBER := 5;
  FA_INTERCO_AP         CONSTANT NUMBER := 6;
  FA_INTERCO_AR         CONSTANT NUMBER := 7;
-- BONUS
-- FA_DPR_ADJ_BONUS_DEPRN_RSV ???????

  -- Defines for Rate Source Rule element values in dpr_struct
  FAD_RSR_CALC    CONSTANT VARCHAR2(10) := 'CALCULATED';
  FAD_RSR_TABLE   CONSTANT VARCHAR2(10) := 'TABLE';
  FAD_RSR_FLAT    CONSTANT VARCHAR2(10) := 'FLAT';
  FAD_RSR_PROD    CONSTANT VARCHAR2(10) := 'PRODUCTION';
  FAD_RSR_FORMULA CONSTANT VARCHAR2(10) := 'FORMULA';

  -- Defines for Deprn Basis Rule element values in dpr_struct
  FAD_DBR_COST    CONSTANT VARCHAR2(10) := 'COST';
  FAD_DBR_NBV     CONSTANT VARCHAR2(10) := 'NBV';

  -- Constants for Deprn Basis Rule Polish Mechanisms
  FAD_DBR_POLISH_NONE   CONSTANT NUMBER := 0;
  FAD_DBR_POLISH_1      CONSTANT NUMBER := 1;
  FAD_DBR_POLISH_2      CONSTANT NUMBER := 2;
  FAD_DBR_POLISH_3      CONSTANT NUMBER := 3;
  FAD_DBR_POLISH_4      CONSTANT NUMBER := 4;
  FAD_DBR_POLISH_5      CONSTANT NUMBER := 5;

  -- Constants for Over Depreciate Option in dpr_struct
  FA_OVER_DEPR_NULL     CONSTANT VARCHAR2(30) := null;
  FA_OVER_DEPR_NO       CONSTANT VARCHAR2(30) := 'NO';
  FA_OVER_DEPR_YES      CONSTANT VARCHAR2(30) := 'YES';
  FA_OVER_DEPR_DEPRN    CONSTANT VARCHAR2(30) := 'DEPRN';

  -- Defines for fatime() modes

  FA_ENTER              CONSTANT NUMBER := 1;
  FA_EXIT               CONSTANT NUMBER := 2;

  -- Defines for modes for inserting adjustment rows in fainaj()
  --
  MAX_ADJ_CACHE_ROWS    CONSTANT NUMBER := 200; /* the maximum number of cache
                                                                entries */
  FA_AJ_ACTIVE          CONSTANT NUMBER := 1;  /* ACTIVE mode value */
  FA_AJ_SINGLE          CONSTANT NUMBER := 2;  /* SINGLE mode value */
  FA_AJ_CLEAR           CONSTANT NUMBER := 3;  /* CLEAR mode value */
  FA_AJ_RETIRE          CONSTANT NUMBER := 4;  /* RETIRE mode value */
  FA_AJ_TRANSFER_SINGLE CONSTANT NUMBER := 5;  /* SINGLE mode for transfer/reclass  */
  FA_AJ_ACTIVE_REVAL    CONSTANT NUMBER := 6;  /* ACTIVE mode for reval./
                                                  Propagated from pro*c version. YYOON */
  FA_AJ_CLEAR_PARTIAL   CONSTANT NUMBER := 7;  /* Mode for affected rows: Enhancement for Bug# 4617352 */
  FA_AJ_ACTIVE_PARTIAL  CONSTANT NUMBER := 8;  /* Mode for affected rows: Enhancement for Bug# 4617352 */


END FA_STD_TYPES;

/
