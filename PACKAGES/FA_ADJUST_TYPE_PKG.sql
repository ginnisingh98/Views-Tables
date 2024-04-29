--------------------------------------------------------
--  DDL for Package FA_ADJUST_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ADJUST_TYPE_PKG" AUTHID CURRENT_USER as
/* $Header: FAXINAJS.pls 120.4.12010000.2 2009/07/19 14:09:30 glchen ship $ */

 TYPE  fa_adj_row_struct is RECORD (
	transaction_header_id	 FA_ADJUSTMENTS.transaction_header_id%TYPE,
	asset_invoice_id	 FA_ADJUSTMENTS.asset_invoice_id%TYPE,
	source_type_code	 FA_ADJUSTMENTS.source_type_code%TYPE,
	adjustment_type 	 FA_ADJUSTMENTS.adjustment_type%TYPE,
	debit_credit_flag	 FA_ADJUSTMENTS.debit_credit_flag%TYPE,
	code_combination_id 	 FA_ADJUSTMENTS.code_combination_id%TYPE,
	book_type_code		 FA_ADJUSTMENTS.book_type_code%TYPE,
	period_counter_created	 FA_ADJUSTMENTS.period_counter_created%TYPE,
	asset_id		 FA_ADJUSTMENTS.asset_id%TYPE,
        adjustment_amount	 FA_ADJUSTMENTS.adjustment_amount%TYPE,
	period_counter_adjusted	 FA_ADJUSTMENTS.period_counter_adjusted%TYPE,
	distribution_id	 	 FA_ADJUSTMENTS.distribution_id%TYPE,
	annualized_adjustment 	 FA_ADJUSTMENTS.annualized_adjustment%TYPE,
	last_update_date 	 FA_ADJUSTMENTS.last_update_date%TYPE,
	account 	         varchar2(2000),
	account_type 	         varchar2(55),
	current_units		 number,
	selection_mode		 number,
	selection_thid		 number,
	selection_retid		 number,
	flush_adj_flag		 boolean,
	gen_ccid_flag		 boolean,
	amount_inserted		 FA_ADJUSTMENTS.adjustment_amount%TYPE,
	units_retired		 number,
	leveling_flag		 boolean,
        deprn_override_flag      FA_DEPRN_SUMMARY.deprn_override_flag%TYPE,
        mrc_sob_type_code        varchar2(1),
        set_of_books_id          number,
-- Added for Track Member feature
        track_member_flag        FA_ADJUSTMENTS.track_member_flag%TYPE,
        adjustment_line_id       number,
        source_dest_code         varchar2(15),
        source_line_id           number);

/* This record type is declared for the table type below which is used to
   cache records meant for inserting into fa_adjustments.
*/
TYPE  fa_adj_ins_struct is RECORD (
	transaction_header_id	 FA_ADJUSTMENTS.transaction_header_id%TYPE,
	asset_invoice_id	 FA_ADJUSTMENTS.asset_invoice_id%TYPE,
	source_type_code	 FA_ADJUSTMENTS.source_type_code%TYPE,
	adjustment_type 	 FA_ADJUSTMENTS.adjustment_type%TYPE,
	debit_credit_flag	 FA_ADJUSTMENTS.debit_credit_flag%TYPE,
	code_combination_id 	 FA_ADJUSTMENTS.code_combination_id%TYPE,
	book_type_code		 FA_ADJUSTMENTS.book_type_code%TYPE,
	period_counter_created	 FA_ADJUSTMENTS.period_counter_created%TYPE,
	asset_id		 FA_ADJUSTMENTS.asset_id%TYPE,
        adjustment_amount	 FA_ADJUSTMENTS.adjustment_amount%TYPE,
	period_counter_adjusted	 FA_ADJUSTMENTS.period_counter_adjusted%TYPE,
	distribution_id	 	 FA_ADJUSTMENTS.distribution_id%TYPE,
	annualized_adjustment 	 FA_ADJUSTMENTS.annualized_adjustment%TYPE,
	last_update_date 	 FA_ADJUSTMENTS.last_update_date%TYPE,
        deprn_override_flag      FA_DEPRN_SUMMARY.deprn_override_flag%TYPE,
-- Added for Track Member features
        track_member_flag        FA_ADJUSTMENTS.track_member_flag%TYPE,
        adjustment_line_id       number,
        source_dest_code         varchar2(15),
        source_line_id           number,
        set_of_books_id          number);

TYPE fa_adj_ins_table is TABLE of fa_adj_ins_struct
INDEX BY BINARY_INTEGER;

 MAX_ADJ_CACHE_ROWS	CONSTANT NUMBER := 200;  /* The maximum number of cache
						    entries		*/
 FA_AJ_ACTIVE		CONSTANT NUMBER := 1;    /* ACTIVE mode value  */
 FA_AJ_SINGLE		CONSTANT NUMBER := 2;	 /* SINGLE mode value  */
 FA_AJ_CLEAR		CONSTANT NUMBER := 3;    /* CLEAR mode value   */
 FA_AJ_RETIRE		CONSTANT NUMBER := 4;    /* RETIRE mode value  */
 FA_AJ_TRANSFER_SINGLE  CONSTANT NUMBER := 5;    /* SINGLE mode for transfer/
						    reclass   */
 FA_AJ_ACTIVE_REVAL     CONSTANT NUMBER := 6;    /* ACTIVE mode for reval./
                                                    Propagated from pro*c version. YYOON */
 FA_AJ_CLEAR_PARTIAL    CONSTANT NUMBER := 7;    /* Mode for affected rows: Enhancement for Bug# 4617352 */
 FA_AJ_ACTIVE_PARTIAL   CONSTANT NUMBER := 8;    /* Mode for affected rows: Enhancement for Bug# 4617352 */

END FA_ADJUST_TYPE_PKG;

/
