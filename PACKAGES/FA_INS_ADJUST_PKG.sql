--------------------------------------------------------
--  DDL for Package FA_INS_ADJUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INS_ADJUST_PKG" AUTHID CURRENT_USER as
/* $Header: FAXIAJ2S.pls 120.3.12010000.2 2009/07/19 14:09:01 glchen ship $ */

  adj_ptr	FA_ADJUST_TYPE_PKG.fa_adj_row_struct;
  dpr_ptr	FA_STD_TYPES.fa_deprn_row_struct;
  H_DPR_ROW     FA_STD_TYPES.fa_deprn_row_struct;
  adj_table     FA_ADJUST_TYPE_PKG.fa_adj_ins_table;
  h_cache_index number:=0;
  h_mrc_sob_type_code varchar2(1);
  h_set_of_books_id   number;

/*
 ---------------------------------------------------------------------
 *
 * Name		fadoflx
 *
 *
 * Description
 *		 This function calls the flex API to generate the CCID
 *		 to insert in FA_ADJUSTMENTS table based on the table
 *		 settings
 *
 * Parameters
 *		book_type_code   in varchar2
 *		account_type	 in varchar2
 *		dist_ccid	 in number
 *		spec_ccid	 in number
 *		account		 in number
 *		calculated_ccid  out number
 *		gen_ccid_flag	 in number
 *		asset_id	 in number
 *		cat_id		 out number
 *		distribution_id  in number
 *		source_type_code in varchar2
 * Modifies
 *	adj_ptr
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  01/27/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION fadoflx (X_book_type_code  in varchar2,
		  X_account_type    in varchar2,
		  X_dist_ccid	    in number,
		  X_spec_ccid	    in number,
		  X_account	    in varchar2,
	  	  X_calculated_ccid out nocopy number,
		  X_gen_ccid_flag   in boolean,
		  X_asset_id 	    in number,
		  X_cat_id	    in out nocopy number,
		  X_distribution_id in number,
		  X_source_type_code in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
   return boolean;
/*
 ---------------------------------------------------------------------
 *
 * Name		factotp
 *
 *
 * Description
 *
 *  This function calculates the total amount to prorate over all the
 *  distributions based on the adjustment type.
 *
 * Parameters
 *   total_amount out number;
 *   adj_ptr and dpr_ptr are already available to this function
 *   as they are defined as globals for the package
 * Modifies
 *	total_amount
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *  Since we don't store COST in FA_DEPRN_SUMMARY, the cost returned
 *  from fauqadd() is 0 +/- any adjustments to COST; for the purposes
 *  of inserting into FA_ADJUSTMENTS, we need to add it the FA_BOOKS.COST
 *  to the total_amount to prorate.

 * History
 *  01/29/97    tpershad	Created
 *--------------------------------------------------------------------
*/
 FUNCTION factotp (total_amount  out nocopy number,
		adjustment_amount in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
 return boolean;
/*
 ---------------------------------------------------------------------
 *
 * Name		facdamt
 *
 *
 * Description
 *		 This function calculates the detail amount to substract
 *		 from a single distribution based on the adjustment type
 *		 The two structures adj_ptr and dpr_ptr are already
 *		 available to this function as they are global to this
 *		 package and hence is not passed as parameters
 *
 * Parameters
 *		adj_dd_amount  out number
 *
 * Modifies
 *	adj_dd_amount
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  01/27/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION facdamt (adj_dd_amount   out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;
/*
 ---------------------------------------------------------------------
 *
 * Name		fagetcc
 *
 *
 * Description
 *		 This function gets the current cost for the asset
 *		 The  structures adj_ptr is already available to
 *		 this function it is defined as global to this
 *		 package and hence is not passed as parameter
 *
 * Parameters
 *		cost  out number
 *
 * Modifies
 *	cost
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  01/29/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION fagetcc(X_cost out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;
/*
 ---------------------------------------------------------------------
 *
 * Name		fainajc
 *
 *
 * Description
 *		 The function inserts one row into FA_ADJUSTMENTS tablei
 *		 with  the values passed in, OR it flushes out the cache
 *	         to the database.
 *		 The adj_ptr and dpr_ptr are defined as global and hence
 *	         are not passed as parameters.
 * Parameters
 *		 X_flush_mode  in boolean
 *	         X_mode	      in boolean
 * Modifies
*	        none. Inserts rows into FA_ADJUSTMENTS table
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  01/30/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION fainajc(X_flush_mode boolean,
	         X_mode       boolean,
		 X_last_update_date date default sysdate,
		 X_last_updated_by  number default -1,
		 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;
/*
 ---------------------------------------------------------------------
 *
 * Name		fadoact
 *
 *
 * Description
 *   This function does all the processing of ACTIVE mode
 *
 * Parameters
 *
 * Modifies
 *	        none.
 * Returns
 *		True on success. Otherwise False.
 *
 * Notes
 *
 * History
 *  01/30/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION fadoact(X_last_update_date date default sysdate,
		 X_last_updated_by  number default -1,
		 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;
/*
 ---------------------------------------------------------------------
 *
 * Name		fadoclr
 *
 *
 * Description
 *	 The adj_ptr is defined as global for this package and hence
 *       not passed as parameters.
 * Parameters
 *	         None
 * Modifies
 *	        None.It calls the function fainajc to insert rows into
 *		FA_ADJUSTMENTS table
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  02/05/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION fadoclr(X_last_update_date date default sysdate,
		 X_last_updated_by  number default -1,
		 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;
/*
 ---------------------------------------------------------------------
 *
 * Name		fadosglf
 *
 *
 * Description
 *	FA DO Single mode, with cache flush
 *	 This function does all processing of SINGLE mode.
 *	 Flushes cache as well.. used for transfers/reclass only.
 * Parameters
 *	         adj_ptr. (Since this is global to the package we need
 *		 not pass it as a parameter.
 * Modifies
 *
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  02/25/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION fadosglf(X_last_update_date date default sysdate,
		 X_last_updated_by  number default -1,
		 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;
/*
 ---------------------------------------------------------------------
 *
 * Name		fadosgl
 *
 *
 * Description
 *	FA DO Single mode
 *	 This function does all processing of SINGLE mode.
 *
 * Parameters
 *	         adj_ptr. (Since this is global to the package we need
 *		 not pass it as a parameter.
 * Modifies
 *
 * Returns
 *		True on success. Otherwise False.
 *
 * Notes
 *
 * History
 *  02/25/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION fadosgl(X_last_update_date date default sysdate,
		 X_last_updated_by  number default -1,
		 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

/*
 ---------------------------------------------------------------------
 *
 * Name		fadoret
 *
 *
 * Description
 *	FA DO Retirement mode
 *	 This function does all processing of RETIRE mode.
 *
 * Parameters
 *	         adj_ptr. (Since this is global to the package we need
 *		 not pass it as a parameter.
 * Modifies
 *
 * Returns
 *		True on success. Otherwise False.
 *
 * Notes
 *
 * History
 *  02/25/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION fadoret(X_last_update_date date default sysdate,
		 X_last_updated_by  number default -1,
		 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

/*
 ---------------------------------------------------------------------
 *
 * Name		faxinaj
 *
 *
 * Description
 *	 This is the driver function for Insert into FA_ADJUSTMENTS
 *	 engine.
 *
 * Parameters
 *	         adj_ptr. (Since this is global to the package we need
 *		 not pass it as a parameter.
 * Modifies
 *
 * Returns
 *		True on success. Otherwise False.
 *
 * Notes
 *
 * History
 *  02/25/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION faxinaj(adj_ptr_passed  in out nocopy FA_ADJUST_TYPE_PKG.fa_adj_row_struct,
		 X_last_update_date date default sysdate,
		 X_last_updated_by  number default -1,
		 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

/*
 ---------------------------------------------------------------------
 *
 * Name		faxinadj
 *
 *
 * Description
 *  This function is the FORMS specific code that gets the parameters
 *  passed in by the form, and makes the call to the Insert Into
 *  FA_ADJUSTMENTS Function.This is not called from any of the
 *  user exits or concurrent programs
 *
 *    This function handles inserts into the FA_ADJUSTMENTS table in
 *    four modes:
 *	1. ACTIVE mode
 *		When run in ACTIVE mode, the function prorates an adjustment
 *		amount over all of the asset's distribution lines. The
 *		adjustment amount can be an adjustment to cost,
 *		revaluation reserve, or depreciation reserve.
 *
 *	2. SINGLE mode
 *		When run in SINGLE mode, the function inserts
 *		the adjustment amount for a single distribution line.
 *      3. CLEAR mode
 *              When run in CLEAR mode, the function inserts the adjustments
 *              rows necessary to reverse out the current Query Fin Info
 *              value for each distribution which is active or terminated
 *              by the selection_thid, but not created by the transaction.
 *
 *      4. RETIRE mode
 *              This user exit shouldn't be called using this mode; it's
 *              for the retirements program. The hooks are here for future
 *              use though.
 * * Parameters
 *	         adj_ptr. (Since this is global to the package we need
 *		 not pass it as a parameter.
 * Modifies
 *
 * Returns
 *		True on success. Otherwise False.
 *
 * Notes
 *
 * History
 *  02/27/97    tpershad	Created
 *--------------------------------------------------------------------
*/
FUNCTION faxinadj (X_transaction_header_id   in number,
		   X_source_type_code        in varchar2,
		   X_adjustment_type         in varchar2,
		   X_debit_credit_flag 	     in varchar2,
		   X_code_combination_id     in number,
		   X_book_type_code 	     in varchar2,
		   X_period_counter_created  in number,
		   X_asset_id		     in number,
		   X_adjustment_amount	     in number,
		   X_period_counter_adjusted in number,
		   X_distribution_id	     in number,
		   X_annualized_adjustment   in number,
		   X_last_update_date	     in date  default sysdate,
		   X_account		     in varchar2,
		   X_account_type	     in varchar2,
		   X_current_units	     in number,
		   X_selection_mode	     in varchar2,
		   X_flush_adj_flag	     in varchar2,
		   X_gen_ccid_flag	     in varchar2,
		   X_leveling_flag	     in varchar2,
		   X_asset_invoice_id	     in number,
		   X_amount_inserted	     out nocopy number,
		   X_last_updated_by  	         number default -1,
		   X_last_update_login           number default -1,
		   X_init_message_flag           varchar2 default 'NO', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;
END FA_INS_ADJUST_PKG;

/
