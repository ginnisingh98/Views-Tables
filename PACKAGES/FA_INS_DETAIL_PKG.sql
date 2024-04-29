--------------------------------------------------------
--  DDL for Package FA_INS_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INS_DETAIL_PKG" AUTHID CURRENT_USER as
/* $Header: FAXINDDS.pls 120.3.12010000.2 2009/07/19 14:10:28 glchen ship $ */

/* ---------------------------------------------------------------------
 |   Name
 |        faxindd
 |
 |   Description
 |        This function is called from forms to insert a row into fa_deprn_detail
 |
 |   Parameters
 |        book_type_code - mandatory
 |        asset_id       - mandatory
 |
 |        The following parameters are not mandatory. If they are specified, then the
 |        function uses that value to pass into fadpdtl(insert into fa_deprn_detail)
 |        function. If not specified, then values are retrieved from fa_deprn_summary
 |        table or fa_books(only for cost).
 |
 |        cost
 |        deprn_reserve  - accumulated depreciation
 |        reval_reserve  - revaluation reserve
 |        ytd_deprn      - year to date depreciation
 |        ytd_reval_deprn_expense - year to date reval depreciation expense
 |        period_counter
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   Notes
 |        even if period_counter is passed in a value, it is always
 |        retrieved from fa_deprn_summary 'BOOKS' row.
 |
 |   History
 |        24-Jan-1997       LSON                Created
 |        25-Jul-2008       S. Venkataramanan   Bug 6666666
 |
 + -------------------------------------------------------------------- */

FUNCTION faxindd (X_book_type_code           VARCHAR2,
                  X_asset_id                 NUMBER,
                  X_period_counter           NUMBER := NULL,
                  X_cost                     NUMBER := NULL,
                  X_deprn_reserve            NUMBER := NULL,
/* Bug 525654 Modification */
                  X_deprn_adjustment_amount            NUMBER := NULL,
                  X_reval_reserve            NUMBER := NULL,
                  X_ytd                      NUMBER := NULL,
                  X_ytd_reval_dep_exp        NUMBER := NULL,
                  X_bonus_ytd                NUMBER := NULL,
                  X_bonus_deprn_reserve      NUMBER := NULL,
		  X_init_message_flag        VARCHAR2 DEFAULT 'NO',
                  X_bonus_deprn_adj_amount   NUMBER DEFAULT NULL,
                  X_bonus_deprn_amount       NUMBER DEFAULT NULL,
                  X_deprn_amount             NUMBER DEFAULT NULL,
                  X_reval_amortization       NUMBER DEFAULT NULL,
                  X_reval_deprn_expense      NUMBER DEFAULT NULL,
                  X_impairment_amount        NUMBER DEFAULT NULL,
                  X_ytd_impairment           NUMBER DEFAULT NULL,
                  X_impairment_reserve       NUMBER DEFAULT NULL,
                  X_capital_adjustment       NUMBER DEFAULT NULL, -- Bug 6666666
                  X_general_fund             NUMBER DEFAULT NULL, -- Bug 6666666
                  X_b_row                    BOOLEAN DEFAULT TRUE,
                  X_mrc_sob_type_code        VARCHAR2,
                  X_set_of_books_id          NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

         return BOOLEAN;


/* ---------------------------------------------------------------------
 |   Name
 |        fadpdtl
 |
 |   Description
 |        This function accepts book type code, asset_id,period_counter,
 |        cost, year to date depreciation amount,depreciation reserve,
 |        revaluation reserve amount, and year to date revaluation
 |        depreciation expense in a structure X_dpr_dtl as parameters
 |        and insert a row to fa_deprn_detail for each distribution.
 |        Amount distributed for fa_deprn_detail row is prorated based on
 |        units_assigend to that distribution and rounded off based on the
 |        currency of the book. If there is remaining pennies from the rounding
 |        the largest distribution id will get the remaining.
 |
 |   Parameters
 |        X_dpr_dtl   dpr_dtl_row_struct record structure defined in faxstds.pls
 |
 |        X_source_flag   TRUE or FALSE
 |                        TRUE - creates 'B' row
 |                        FALSE - creates 'D' row
 |
 |   Returns
 |        TRUE if successful, FALSE otherwise
 |
 |   History
 |        24-Jan-1997		LSON		Created
 |
 + -------------------------------------------------------------------- */

FUNCTION fadpdtl (X_dpr_dtl     FA_STD_TYPES.DPR_DTL_ROW_STRUCT,
                  X_source_flag BOOLEAN,
                  X_mrc_sob_type_code       VARCHAR2,
                  X_set_of_books_id         NUMBER,
                  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN;


END FA_INS_DETAIL_PKG;

/
