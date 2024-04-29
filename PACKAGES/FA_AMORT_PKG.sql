--------------------------------------------------------
--  DDL for Package FA_AMORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_AMORT_PKG" AUTHID CURRENT_USER as
/* $Header: FAAMRT1S.pls 120.2.12010000.2 2009/07/19 12:36:54 glchen ship $ */

/*
 ---------------------------------------------------------------------
 *
 * Name		faxiat
 *
 *
 * Description
 *	This function is an entry point for calling FA_ADJUSTMENTS function
 *      This is called from the EXPENSE and AMORTIZE user exits and calls
 *	the INSERT INTO FA_ADJUSTMENTS function 3 times-for adjustment type
 *	COST, COST CLEARING and DEPRECIATION.
 *
 * Parameters
 *		 X_fin_ptr      FA_STD_TYPES.fin_info_struct
 *	         X_deprn_exp	number
 *		 X_bonus_deprn_exp number
 *		 X_ann_adj	number
 *		 X_ccid		number,
 *		 X_last_update_date  date
 *		 X_updated_by number
 *		 X_update_login number
 *
 * Modifies
 *	        None. Calls FA_INS_ADJUST_PKG.faxinaj 3 times.
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  03/06/97    tpershad	Created
 *--------------------------------------------------------------------
*/

FUNCTION faxiat (X_fin_ptr   FA_STD_TYPES.fin_info_struct,
		 X_deprn_exp  number,
		 X_bonus_deprn_exp number,
		 X_ann_adj_amt  number,
		 X_ccid	   number,
		 X_last_update_date  date default sysdate,
		 X_last_updated_by   number default -1,
		 X_last_update_login number default -1,
                 X_mrc_sob_type_code varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

/*
 ---------------------------------------------------------------------
 *
 * Name		faxraf
 *
 *
 * Description
 *	This function calculates the new rate adjustment factor and the
 *      new adjusted cost.
 *
 * Parameters
 *		 X_fin_info_ptr      	FA_STD_TYPES.fin_info_struct
 *	         X_new_raf		number
 *		 X_adj_cost		number
 *		 X_adj_capacity 	number
 *		 X_new_reval_amo_basis 	number
 *		 X_new_salvage_value	number
 *		 X_reval_deprn_rsv_adj  number
 *
 * Modifies
 *	        X_new_raf,X_new_reval_amo_basis,X_new_salvage_value
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  03/24/97    tpershad	Created
 *--------------------------------------------------------------------
*/

FUNCTION faxraf (X_fin_info_ptr   	in out nocopy FA_STD_TYPES.fin_info_struct,
		 X_new_raf		in out nocopy number,
 		 X_new_adj_cost		in out nocopy number,
 		 X_new_adj_capacity 	in out nocopy number,
 		 X_new_reval_amo_basis 	in out nocopy number,
 		 X_new_salvage_value	in out nocopy number,
 		 X_reval_deprn_rsv_adj  in out nocopy number,
		 X_new_formula_factor	in out nocopy number,
		 X_bonus_deprn_exp	in out nocopy number,
                 X_mrc_sob_type_code    in     varchar2,
                 X_set_of_books_id      in     number,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

/*
 ---------------------------------------------------------------------
 *
 * Name		faxama
 *
 *
 * Description
 *	Calls faxraf to calculate the new raf. This is the main
 *	routine for Amortized user exit function.
 *	This function calls faxraf to calculate the new rate adjustment
 *	factor and the new adjusted cost.
 *
 * Parameters
 *		 X_fin_info_ptr      	FA_STD_TYPES.fin_info_struct
 *	         X_new_raf		number
 *		 X_adj_cost		number
 *		 X_adj_capacity 	number
 *		 X_new_reval_amo_basis 	number
 *		 X_new_salvage_value	number
 *		 X_ccid			number
 *		 X_ins_adjust_flag	boolean  - This is to indicate
 *						   whether to call faxiat
 *						   or not. If called from
 *						   whatif deprn then it is
 *						   FALSE and we do not insert
 *						   rows in fa_adjustments.
 *               X_deprn_exp            number - deprn expense inserted into
 *                                               fa_adjustment
 *
 * Modifies
 *	        X_new_raf,X_new_reval_amo_basis,X_new_salvage_value
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  03/24/97    tpershad	Created
 *--------------------------------------------------------------------
*/

FUNCTION faxama(X_fin_info_ptr   	in out nocopy FA_STD_TYPES.fin_info_struct,
		X_new_raf		in out nocopy number,
 		X_new_adj_cost		in out nocopy number,
 		X_new_adj_capacity 	in out nocopy number,
 		X_new_reval_amo_basis 	in out nocopy number,
 		X_new_salvage_value	in out nocopy number,
		X_new_formula_factor	in out nocopy number,
 		X_ccid		        in  number,
		X_ins_adjust_flag	in boolean,
                X_mrc_sob_type_code     in varchar2,
                X_set_of_books_id       in number,
		X_deprn_exp             out nocopy number,
                X_bonus_deprn_exp       out nocopy number,
		X_last_update_date date default sysdate,
		X_last_updated_by number default -1,
		X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

/*
 ---------------------------------------------------------------------
 *
 * Name         get_reserve
 *
 *
 * Description
 *              This function is called when user tries to do amoritization
 *              and specified amortization start date is eariler than the
 *              addition for those assets that are added with reserve
 *              or added with prior period dpis.
 *              It will return reserve accumulated for up to the period right before the
 *              amortization period.
 *
 * Parameters
 *		X_fin_info_ptr     in out fa_std_types.fin_info_struct,
 *              x_add_txn_id       in number  -- transaction id of addition txn
 *              x_amortize_fy      in integer
 *              x_amortize_per_num in integer
 *              x_pers_per_yr      in integer
 *              x_deprn_rsv        out number -- reserve upto the period prior to amort period
 *              x_bonus_deprn_rsv  out number
 *
 *
 * Modifies
 *              X_deprn_rsv, X_bonus_deprn_rsv
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 * History
 *  06/23/00    lson        Created
 *--------------------------------------------------------------------
*/


FUNCTION get_reserve(X_fin_info_ptr     in out nocopy fa_std_types.fin_info_struct,
                     x_add_txn_id       in number,
                     x_amortize_fy      in integer,
                     x_amortize_per_num in integer,
                     x_pers_per_yr      in integer,
                     x_mrc_sob_type_code in varchar2,
                     x_set_of_books_id  in number,
                     x_deprn_rsv        out nocopy number,
		     x_bonus_deprn_rsv  out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;


/*
 ---------------------------------------------------------------------
 *
 * Name         faxnac
 *
 *
 * Description
 *      Calls faxnac to check if the calculation method of depreciation
 *      is "Strict Calculation Basis".   If so, it will either return the
 *      recoverable cost(for cost based methods), or return the NBV as of
 *      the beginning of the fiscal year
 *
 * Parameters
 *               X_method_code         FA_STD_TYPES.fin_info_struct
 *               X_life                FA_STD_TYPES.fin_info_struct
 *               X_rec_cost            FA_STD_TYPES.dpr_struct
 *               X_prior_fy_exp        FA_STD_TYPES.dprn_out_struct
 *               X_deprn_rsv           null
 *               X_ytd_deprn           null
 *               X_new_adj_cost        new adjusted cost  -- in out
 *
 * Modifies
 *              X_new_adj_cost
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 * History
 *  05/11/00    astakaha        Created
 *--------------------------------------------------------------------
*/

FUNCTION faxnac(X_method_code          in varchar2,
                X_life                 in number,
                X_rec_cost             in number,
                X_prior_fy_exp         in number,
                X_deprn_rsv            in number,
                X_ytd_deprn            in number,
                X_adj_cost             in out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

END FA_AMORT_PKG;

/
