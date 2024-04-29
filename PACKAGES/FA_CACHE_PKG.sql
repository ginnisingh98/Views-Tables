--------------------------------------------------------
--  DDL for Package FA_CACHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CACHE_PKG" AUTHID CURRENT_USER as
/* $Header: FACACHES.pls 120.9.12010000.5 2009/07/19 12:38:52 glchen ship $ */

-- deprn method global variables
-- added for new alternative flat depreciation adjustment.

g_max_array_size           number := 200;

        -- PRIVATE TYPES
        --

        TYPE fazcff_type is RECORD (
                book_type_code  varchar2(15),
                calendar_type   varchar2(15),
                fiscal_year     number,
                frac            number,
                start_jdate     number,
                end_jdate       number);

        TYPE fazccp_type is RECORD (
                t_calendar      varchar2(30),
                t_fy_name       varchar2(30),
                t_jdate         number,
                period_num      number,
                fiscal_year     number,
                start_jdate     number);

        TYPE fazccl_type is RECORD (
                t_ceiling_name     varchar2(30),
                t_jdate            number,
                t_year             number,
                ceiling            number);

        TYPE fazcbr_type is RECORD (
                t_bonus_rule           varchar2(30),
                t_year                 number,
                bonus_rate             number,
                deprn_factor           number,
                alternate_deprn_factor number);

        -- BUG# 1910033 - added for mrc
        TYPE fazcsob_type is record(
                set_of_books_id   number,
                mrc_sob_type_code varchar2(1));


        TYPE fazctbk_pvt_rec_type IS RECORD
               (corp_book              varchar2(15),
                tax_book               varchar2(15),
                allow_cip_assets_flag  varchar2(3),
                immediate_copy_flag    varchar2(3),
                copy_group_addition_flag varchar2(3)
               );

        TYPE fazcrsob_pvt_rec_type IS RECORD
               (book_type_code       varchar2(15),
                set_of_books_id      number
               );

        TYPE fazcdp_rec_type IS RECORD
               (book_type_code             varchar2(15),
                period_name                varchar2(15),
                period_counter             number,
                fiscal_year                number,
                period_num                 number,
                period_open_date           date,
                period_close_date          date,
                calendar_period_open_date  date,
                calendar_period_close_date date,
                deprn_run                  varchar2(1)
               );

        TYPE fazcsgr_rec_type IS RECORD
               (super_group_id             number,
                book_type_code             varchar2(15),
                start_period_counter       number(15),
                end_period_counter         number(15),
                deprn_method_code          varchar2(15),
                basic_rate                 number,
                adjusted_rate              number,
                percent_salvage_value      number
               );

        TYPE fazcdbr_rec_type is RECORD (
           deprn_basis_rule_id   FA_DEPRN_BASIS_RULES.DEPRN_BASIS_RULE_ID%TYPE,
           rule_name             FA_DEPRN_BASIS_RULES.RULE_NAME%TYPE,
           user_rule_name        FA_DEPRN_BASIS_RULES.USER_RULE_NAME%TYPE,
           last_update_date      FA_DEPRN_BASIS_RULES.LAST_UPDATE_DATE%TYPE,
           last_updated_by       FA_DEPRN_BASIS_RULES.LAST_UPDATED_BY%TYPE,
           created_by            FA_DEPRN_BASIS_RULES.CREATED_BY%TYPE,
           creation_date         FA_DEPRN_BASIS_RULES.CREATION_DATE%TYPE,
           last_update_login     FA_DEPRN_BASIS_RULES.LAST_UPDATE_LOGIN%TYPE,
           rate_source           FA_DEPRN_BASIS_RULES.RATE_SOURCE%TYPE,
           deprn_basis           FA_DEPRN_BASIS_RULES.DEPRN_BASIS%TYPE,
           enabled_flag          FA_DEPRN_BASIS_RULES.ENABLED_FLAG%TYPE,
           program_name          FA_DEPRN_BASIS_RULES.PROGRAM_NAME%TYPE,
           description           FA_DEPRN_BASIS_RULES.DESCRIPTION%TYPE,
           polish_rule           NUMBER
        );

        -- BUG# 1913745 - implementing arrays to recuce db hits

        TYPE fazcbc_type_tab        is table of FA_BOOK_CONTROLS%RowType
                                    index by binary_integer;
        TYPE fazcct_type_tab        is table of FA_CALENDAR_TYPES%RowType
                                    index by binary_integer;
        TYPE fazcff_type_tab        is table of fazcff_type
                                    index by binary_integer;
        TYPE fazccp_type_tab        is table of fazccp_type
                                    index by binary_integer;
        TYPE fazccb_type_tab        is table of FA_CATEGORY_BOOKS%RowType
                                    index by binary_integer;
        TYPE fazccmt_type_tab       is table of FA_METHODS%Rowtype
                                    index by binary_integer;
        TYPE fazccl_type_tab        is table of fazccl_type
                                    index by binary_integer;
        TYPE fazcbr_type_tab        is table of fazcbr_type
                                    index by binary_integer;
        TYPE fazcsob_type_tab       is table of fazcsob_type
                                    index by binary_integer;
        TYPE fazccbd_type_tab       is table of FA_CATEGORY_BOOK_DEFAULTS%rowtype
                                    index by binary_integer;
        TYPE fazcat_type_tab        is table of FA_CATEGORIES%rowtype
                                    index by binary_integer;
        TYPE fazctbk_tbl_type       IS TABLE OF VARCHAR2(15)
                                    INDEX BY BINARY_INTEGER;
        TYPE fazctbk_pvt_tbl_type   IS TABLE OF fazctbk_pvt_rec_type
                                    INDEX BY BINARY_INTEGER;
        TYPE fazcrsob_sob_tbl_type  IS TABLE OF NUMBER
                                    INDEX BY BINARY_INTEGER;
        TYPE fazcrsob_book_tbl_type IS TABLE OF VARCHAR2(15)
                                    INDEX BY BINARY_INTEGER;
        TYPE fazcrsob_pvt_tbl_type  IS TABLE OF fazcrsob_pvt_rec_type
                                    INDEX BY BINARY_INTEGER;
        TYPE fazccvt_type_tab       is table of FA_CONVENTION_TYPES%rowtype
                                    index by binary_integer;
        TYPE fazcfy_type_tab        is table of FA_FISCAL_YEAR%rowtype
                                    index by binary_integer;
        TYPE fazcdp_type_tab        is table of fazcdp_rec_type
                                    index by binary_integer;
        TYPE fazcdbr_type_tab       is table of fazcdbr_rec_type
                                    index by binary_integer;
        TYPE fazcfor_type_tab       is table of FA_FORMULAS%rowtype
                                    index by binary_integer;
        TYPE fazcdrd_type_tab       is table of FA_DEPRN_RULE_DETAILS%rowtype
                                    index by binary_integer;
        TYPE fazcsgr_type_tab       is table of fazcsgr_rec_type
                                    index by binary_integer;

        -- fazcbc variables
        fazcbc_record         FA_BOOK_CONTROLS%RowType;
        fazcbc_table          fazcbc_type_tab;
        fazcbc_index          number;  -- used to store the index of last
                                      -- book's position in array. will
                                      -- be used to delete a member when
                                      -- transaction approval finds it stale

        -- fazcbcs variables
        fazcbcs_record        FA_BOOK_CONTROLS%RowType;
        fazcbcs_table         fazcbc_type_tab;
        fazcbcs_index         number;  -- used to store the index of last
                                      -- book's position in array. will
                                      -- be used to delete a member when
                                      -- transaction approval finds it stale



        -- fazcct variables
        fazcct_record         FA_CALENDAR_TYPES%RowType;
        fazcct_table          fazcct_type_tab;

        -- faxcff variables
        fazcff_record         fazcff_type;
        fazcff_table          fazcff_type_tab;

        -- fazccl variables
        fazccl_record         fazccl_type;
        fazccl_table          fazccl_type_tab;

        -- fazcbr variables
        fazcbr_record         fazcbr_type;
        fazcbr_table          fazcbr_type_tab;

        -- fazccp variables
        fazccp_record         fazccp_type;
        fazccp_table          fazccp_type_tab;

        -- fazccb variables
        fazccb_record         FA_CATEGORY_BOOKS%RowType;
        fazccb_table          fazccb_type_tab;

        -- fazccmt variables
        fazccmt_record        FA_METHODS%RowType;
        fazccmt_table         fazccmt_type_tab;

        -- fazcsob variables (added for mrc)
        fazcsob_record        fazcsob_type;
        fazcsob_table         fazcsob_type_tab;

        -- fazccbd variables
        fazccbd_record        FA_CATEGORY_BOOK_DEFAULTS%RowType;
        fazccbd_table         fazccbd_type_tab;

        -- fazcat variables
        fazcat_record         FA_CATEGORIES%RowType;
        fazcat_table          fazcat_type_tab;

        -- fazsys variables
        fazsys_record         FA_SYSTEM_CONTROLS%RowType;

        -- fazctbk variables
        fazctbk_last_book_used   VARCHAR2(15);
        fazctbk_last_type_used   VARCHAR2(15);
        fazctbk_main_tbl         fazctbk_pvt_tbl_type;
        fazctbk_corp_tbl         fazctbk_tbl_type;
        fazctbk_tax_tbl          fazctbk_tbl_type;

        -- fazcrsob variables
        fazcrsob_last_book_used  VARCHAR2(15);
        fazcrsob_main_tbl        fazcrsob_pvt_tbl_type;
        fazcrsob_book_tbl        fazcrsob_book_tbl_type;
        fazcrsob_sob_tbl         fazcrsob_sob_tbl_type;

        -- fazccvt variables
        fazccvt_record           FA_CONVENTION_TYPES%RowType;
        fazccvt_table            fazccvt_type_tab;

        -- fazcfy variables
        fazcfy_record            FA_FISCAL_YEAR%RowType;
        fazcfy_table             fazcfy_type_tab;

        -- fazcdp variables
        fazcdp_record            fazcdp_rec_type;
        fazcdp_table             fazcdp_type_tab;
        fazcdp_index             number;  -- used to store the index of last
                                          -- period's position in array. will
                                          -- be used to delete a member when
                                          -- transaction approval finds it stale

        -- fazcdbr variables
        fazcdbr_record           fazcdbr_rec_type;
        fazcdbr_table            fazcdbr_type_tab;
        fazcdbr_index            number;

        -- fazcfor variables
        fazcfor_record           fa_formulas%RowType;
        fazcfor_table            fazcfor_type_tab;
        fazcfor_index            number;


        -- fazcdrd variables
        fazcdrd_record           fa_deprn_rule_details%RowType;
        fazcdrd_table            fazcdrd_type_tab;
        fazcdrd_index            number;

        -- fazcdp variables
        fazcsgr_record            fazcsgr_rec_type;
        fazcsgr_table             fazcsgr_type_tab;

        -- fazarel variables

        -- we are defaulting here to a high number to
        -- address the risk of INIT_CALLBACK removal
        -- poses to certain low level routines (such as debug)
        -- where a null value would have the opposite effect
        -- then what is intended

        -- Further more sense INIT_CALLBACK was currently
        -- removed in 12.0, we give will give precidense to
        -- the higher release if this occurs.

        fazarel_release           number := 999999999;


        -- profile variables
        -- we will be caching these profile values as it's simply
        -- to expensive to continously call the fnd_profile code - bmr

        fa_profile_init                boolean   := FALSE;
        fa_crl_enabled                 boolean   ;
        fa_print_debug                 boolean   ;
        fa_debug_file                  varchar2(240) ;
        fa_large_rollback              varchar2(240) ;
        fa_use_threshold               boolean   ;
        fa_gen_expense_account         boolean   ;
        fa_pregen_asset_account        boolean   ;
        fa_pregen_book_account         boolean   ;
        fa_pregen_cat_account          boolean   ;
        fa_mcp_all_cost_adj            boolean   ;
        fa_annual_round                varchar2(240) ;
        fa_deprn_override_enabled      boolean ;
        fa_enabled_deprn_basis_formula boolean ;

        fa_batch_size                  number        ;
        fa_custom_gen_ccid             boolean       ;

--        not frequently used in pl/sql
--        fa_time_diagnostic             varchar2(3)   ;
--        fa_cache_usage                 number        ;
--        fa_num_par_requests            number        ;
--        fa_num_massadd_par_requests    number        ;
--        fa_num_genaccts_par_requests   number        ;
--        fa_security_profile_id         varchar2(240) ;

--        fa_archive_table_size          number      ;
--        fa_ins_swiss_builing           varchar2(3) ;
--        fa_deprn_single                varchar2(3) ;
--        fa_default_dpis_to_inv_date    varchar2(3) ;
--        fa_include_nonrec_tax_massadds varchar2(3) ;
--        FADI_ASSET_CREATION_PRIVS      varchar2()  ;
--        FADI_ASSET_PI_PRIVS            varchar2()  ;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazcbc
 *
 * Description
 *          Cache FA_BOOK_CONTROLS information
 *
 * Parameters
 *          X_book - book type code to get information about
 *
 * Modifies
 *          fazcbc_record - stores book information in this
 *                    structure.
 *          fazcct_last_used - stores book type code most
 *                    recently retrieved.
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazcbc
     (
     X_book in varchar2
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *              fazcbcs
 *
 * Description
 *              Cache FA_BOOK_CONTROLS by SOB information
 *
 * Parameters
 *              X_book - book type code to get information about
 *
 * Modifies
 *              fazcbcs_record - stores book information in this
 *                               structure.
 *              fazcbcs_table  - stores book information in this
 *                               array
 *
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 *              This can be used for transaction bases processing in MRC
 *              namely for retrieving values that may differ between the
 *              primary and reporting books.
 *
 *              Both the gl sob profile and currency_context must be set for
 *              this to retrieve the reporting book info.
 *
 * History
 *   08-08-2001     bridgway      created
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazcbcs
        (
        X_book in varchar2,
        X_set_of_books_id in number,
        p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
        return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *              fazcbc_clr
 *
 * Description
 *              Cache FA_BOOK_CONTROLS clear row function
 *
 * Parameters
 *              X_book - book type code to get information about
 *              not currently used (always deletes lat used row)
 * Modifies
 *              fazcbc_record_array -  remove book info in array
 *              fazcct_record       -  remove book info in record
 *
 * Returns
 *              True on successful removal. Otherwise False.
 *
 * Notes
 *
 * History      08/06/01   bridgway    created
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazcbc_clr
        (
        X_book in varchar2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
        return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazcct
 *
 * Description
 *          Cache FA_CALENDAR_TYPES information
 *
 * Parameters
 *          X_calendar - calendar type to get information about
 *
 * Modifies
 *          fazcct_record - stores calendar information in this
 *                    structure.
 *          fazcct_last_used - stores calendar type     most
 *                    recently retrieved.
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazcct
     (
     X_calendar in varchar2
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazcff
 *
 * Description
 *          Cache fractions of Fiscal Year for Calendar Periods
 *
 * Parameters
 *          X_calendar - calendar type
 *          X_book - book_type_code
 *          X_fy - fiscal_year
 *          X_period_fracs - table to put fractions (OUT)
 *
 * Modifies
 *          X_period_fracs
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazcff
     (
     X_calendar         varchar2,
     X_book             varchar2,
     X_fy               integer,
     X_period_fracs out NOCOPY fa_std_types.table_fa_cp_struct
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazccl
 *
 * Description
 *          Cache FA_CEILINGS information
 *
 * Parameters
 *          X_target_ceiling_name - ceiling name
 *          X_target_year - year_of_life
 *          X_target_jdate - start_date
 *          X_ceiling - ceiling (OUT)
 *
 * Modifies
 *          X_ceiling
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazccl
     (
     X_target_ceiling_name varchar2,
     X_target_jdate        integer,
     X_target_year         integer,
     X_ceiling         out NOCOPY number
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazcbr
 *
 * Description
 *          Cache Bonus Rate
 *
 * Parameters
 *          X_target_bonus_rule - rule
 *          X_target_year - year
 *          X_bonus_rate - bonus_rate (OUT)
 *          X_deprn_factor - deprn_factor (OUT)
 *          X_alternate_deprn_factor - alternate_deprn_factor (OUT)
 *
 * Modifies
 *          X_bonus_rate
 *          X_deprn_factor
 *          X_alternate_deprn_factor
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazcbr
     (
      X_target_bonus_rule                 varchar2,
      X_target_year                       number,
      X_bonus_rate             out NOCOPY number,
      X_deprn_factor           out NOCOPY number,
      X_alternate_deprn_factor out NOCOPY number
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazccp
 *
 * Description
 *          Cache FA_CALENDAR_PERIODS and FA_FISCAL_YEAR information
 *
 * Parameters
 *          X_target_calendar   - target calendar type
 *          X_target_fy_name    - target fiscal year name
 *          X_target_jdate      - target start date
 *          X_period_num  (OUT) - period number
 *          X_fiscal_year (OUT) - fiscal year
 *          X_start_jdate (OUT) - start date
 *
 * Modifies
 *          X_period_num
 *          X_fiscal_year
 *          X_start_jdate
 *          fazccp_record - structure to store cached information
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazccp
     (
     X_target_calendar       varchar2,
     X_target_fy_name        varchar2,
     X_target_jdate          number,
     X_period_num     in out NOCOPY number,
     X_fiscal_year    in out NOCOPY number,
     X_start_jdate    in out NOCOPY number
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*

 --------------------------------------------------------------------------
 *
 * Name
 *          fazccmt
 *
 * Description
 *          Cache Methods
 *
 * Parameters
 *          X_method - method code
 *          X_life - life in months
 *          X_method_id - method id
 *          X_depr_last_year_flag - depreciate in last year flag
 *          X_rate_source_rule - rate source
 *          X_deprn_basis_rule - depreciation basis
 *          X_excl_salvage_val_flag - boolean
 *
 * Modifies
 *          X_method_id
 *          X_depr_last_year_flag
 *          X_rate_source_rule
 *          X_deprn_basis_rule
 *          X_excl_salvage_val_flag
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazccmt
     (
     X_method                    varchar2,
     X_life                      integer
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazccb
 *
 * Description
 *          Cache FA_CATEGORY_BOOKS information
 *
 * Parameters
 *          X_book - book type code to get information about
 *          X_cat_id-category id to get the information about
 * Modifies
 *          fazccb_record    - stores category book information being
 *                             retrieved.
 *          fazccb_last_book - stores book most recently retrieved
 *          fazccb_last_cat  - stores category id most recently retrieved
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazccb
     (
     X_book   in varchar2,
     X_cat_id in number
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              fazcsob
 *
 * Description
 *              Cache GL_SETS_OF_BOOKS information
 *
 * Parameters
 *              X_set_of_books_id - book type code to get information about
 *              X_mrc_sob_type_code (OUT)  - the value for the mrctype flag
 * Modifies
 *              fazcsob_record    - stores book information being retrieved
 *              fazcsob_last_sob  - stores sob id most recently retrieved
 *              fazcsob_table     - stores a list of of all sob's and the
 *                                  sob_type retrieved in the current session
 *
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes        Currently, this is coded only toi return the value for the
 *              column in question.  The Pro*C version could return any
 *              desired column and this could eaisly be modified to do
 *              the same
 *
 * History      07/30/2001    bridgway    created
 *
 *--------------------------------------------------------------------------
 */

FUNCTION fazcsob
     (
     X_set_of_books_id   in  number,
     X_mrc_sob_type_code out NOCOPY varchar
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;



/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazccbd
 *
 * Description
 *          Cache FA_CATEGORY_BOOK_DEFAULTS information
 *
 * Parameters
 *          X_book   - book type code to get information about
 *          X_cat_id - category id to get the information about
 *          X_dpis   - julian dpis to get the information about
 * Modifies
 *          fazccbd_record - stores category book information being retrieved
 *          fazccbd_table  - stores a list of all category book records
 *                           retrieved in the current session
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   08/30/2001   bridgway   created
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazccbd
     (
     X_book    in varchar2,
     X_cat_id  in number,
     X_jdpis   in number
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;



/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazcat
 *
 * Description
 *          Cache FA_CATEGORIES information
 *
 * Parameters
 *          X_cat_id - category id to get the information about
 *
 * Modifies
 *          fazcat_record - stores category being retrieved
 *          fazcat_table -  stores a list of categories previously
 *                          retrieved in the current session
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   10/06/2001   bridgway   created
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazcat
     (
     X_cat_id  in number
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;



/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazsys
 *
 * Description
 *          Cache FA_SYSTEM_CONTROLS information
 *
 * Parameters
 *          NONE
 *
 * Modifies
 *          fazsys_record - stores system control information
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   10/06/2001   bridgway   created
 *
 *--------------------------------------------------------------------------
*/
FUNCTION fazsys ( p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean;


/*
 *--------------------------------------------------------------------------
 *
 * Name
 *          fazctbk
 *
 * Description
 *          Cache FA_TAX_BOOKS information
 *
 *          Used by the new APIs to retrieve the associated tax books
 *          for which we want to do cip-in-tax or autocopy on for a
 *          given transaction
 *
 * Parameters
 *          x_corp_book    (in)  - corporate book for which you wish to
 *                                 retrieve a list of tax books
 *          x_asset_type   (in)  - asset type for which to get associated
 *                                 tax books (CIP or CAPITALIZED)
 *          x_tax_book_tbl (out) - table of tax books for the book / type
 *
 * Modifies
 *          fazctbk_last_book_used   last book for which cache was called
 *          fazctbk_last_type_used   last asset_type for which the cache
 *                                   was called
 *          fazctbk_main_tbl         private table storing all books and
 *                                   reporting sob_ids for which cache
 *                                   has been called
 *          fazctbk_corp_tbl         private table storing list of all
 *                                   corporate books for which cache
 *                                   has been called
 *          fazctbk_tax_tbl          private table storing the last
 *                                   list of tax book for the book in
 *                                   fazctbk_last_book_used
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   11/02/2001   bridgway/yyoon   created
 *
 *--------------------------------------------------------------------------
*/

Function fazctbk
     (
     x_corp_book     in     varchar2,
     x_asset_type    in     varchar2,
     x_tax_book_tbl     out NOCOPY fazctbk_tbl_type
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
return boolean;


/*
 *--------------------------------------------------------------------------
 *
 * Name
 *          fazcrsob
 *
 * Description
 *          Cache REPORTING Set Of Books information
 *
 *          Used by APIs to retrieve a list of all enabled and
 *          converted reporting options (by sob_id)
 *
 *
 * Parameters
 *          x_book_type_code (IN)  - book for which you wish to retrieve
 *                                   a listing of reporting options
 *          x_sob_tbl(OUT)         - table of all enabled and converted
 *                                   sob_ids for this book
 *
 * Modifies
 *          x_sob_tbl (OUT param)
 *          fazcrsob_last_book_used  last for which cache was called
 *          fazcrsob_main_tbl        private table storing all books and
 *                                   reporting sob_ids for which cache
 *                                   has been called
 *          fazcrsob_book_tbl        private table storing list of all books
 *                                   for which cache has been called
 *          fazcrsob_sob_tbl         private table storing the last
 *                                   list of sob_ids for the last_book_used
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   11/02/2001   bridgway/yyoon   created
 *
 *--------------------------------------------------------------------------
*/

Function fazcrsob
     (
     x_book_type_code  in     varchar2,
     x_sob_tbl            out NOCOPY fazcrsob_sob_tbl_type
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;

/*
 *--------------------------------------------------------------------------
 *
 * Name
 *          fazccvt
 *
 * Description
 *          Cache ConVention Types information
 *
 *          Used by APIs to validate and retrieve a convention's info
 *
 *
 * Parameters
 *          x_prorate_convention_code (IN)  - convention which you wish
 *                                            to retrieve info
 *          x_fiscal_year_name (IN)         - fy name for which you wish
 *                                            to retrieve info
 *
 * Modifies
 *          fazccvt_record - stores convention information being retrieved
 *          fazccvt_table  - stores a table of all convention retrieved so far
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   01/13/2002   bridgway   created
 *
 *--------------------------------------------------------------------------
*/

Function fazccvt
     (
     x_prorate_convention_code in  varchar2,
     x_fiscal_year_name        in  varchar2
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 *--------------------------------------------------------------------------
 *
 * Name
 *          fazcfy
 *
 * Description
 *          Cache Fiscal Years information
 *
 *          Used by APIs to validate and retrieve a fiscal years info
 *
 *
 * Parameters
 *          x_fiscal_year_name (IN)         - fy name for which you wish
 *                                            to retrieve info
 *          x_fiscal_year (IN)              - fy for which you wish
 *                                            to retrieve info
 *
 * Modifies
 *          fazcfy_record - stores fy information being retrieved
 *          fazcfy_table  - stores a table of all fy retrieved so far
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   01/13/2002   bridgway   created
 *
 *--------------------------------------------------------------------------
*/

Function fazcfy
     (
     x_fiscal_year_name in varchar2,
     x_fiscal_year      in number
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;

/*
 *--------------------------------------------------------------------------
 *
 * Name
 *          fazcdp
 *
 * Description
 *          Cache Deprn Period information
 *
 *          Used by APIs to validate and retrieve deprn period info
 *
 *
 * Parameters
 *          x_book_type_code (IN) - book for which you wish
 *                                  to retrieve info
 *          x_period_counter (IN) - period counter which you wish
 *                                  to retrieve info
 *          x_effective_date (IN) - date_effective for which you wish
 *                                  to retrieve info
 *
 * Modifies
 *          fazcdp_record - stores period information being retrieved
 *          fazcdp_table  - stores a table of all period retrieved so far
 *          fazcdp_index  - stores index in table of the info retireved
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   01/13/2002   bridgway   created
 *
 *--------------------------------------------------------------------------
*/

Function fazcdp
     (
     x_book_type_code  in  varchar2,
     x_period_counter  in  number   default null,
     x_effective_date  in  date     default null
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 *--------------------------------------------------------------------------
 *
 * Name
 *          fazcdp_clr
 *
 * Description
 *          Cache Deprn Period information Clear Row
 *
 *          Used by APIs to remove a stale row from cache
 *
 *
 * Parameters
 *          x_book_type_code (IN) - not currently used
 *          always deletes last accessed row
 *
 * Modifies
 *          fazcdp_record - stores period information being retrieved
 *          fazcdp_table  - stores a table of all period retrieved so far
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History   01/13/2002   bridgway   created
 *
 *--------------------------------------------------------------------------
*/

Function fazcdp_clr
     (
     x_book in varchar2
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;

Function fazprof return boolean;

/*
 *--------------------------------------------------------------------------
 *
 * Name
 *          fazcsgr
 *
 * Description
 *          Cache Super Group Rule information
 *
 *          Used by APIs to validate and retrieve super group rule info
 *
 *
 * Parameters
 *          x_book_type_code (IN) - book for which you wish
 *                                  to retrieve info
 *          x_period_counter (IN) - period counter which you wish
 *                                  to retrieve info
 *
 * Modifies
 *          fazcsgr_record - stores super group rule information being retrieved
 *          fazcsgr_table  - stores a table of all super group rules retrieved so far
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 *
 *--------------------------------------------------------------------------
*/

Function fazcsgr
     (
     x_super_group_id  in  number,
     x_book_type_code  in  varchar2,
     x_period_counter  in  number   default null
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
     return boolean;


/*
 --------------------------------------------------------------------------
 *
 * Name
 *          fazarel
 *
 * Description
 *          Cache Applications RELease information
 *
 *
 * Modifies
 *          fazarel_release - stores numeric representation of release
 *
 * Returns
 *          True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *
 *--------------------------------------------------------------------------
*/

Function fazarel return boolean;


END FA_CACHE_PKG;

/
