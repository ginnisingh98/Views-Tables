--------------------------------------------------------
--  DDL for Package FA_TRANSFER_XIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRANSFER_XIT_PKG" AUTHID CURRENT_USER as
/* $Header: FAXTFRXS.pls 120.5.12010000.2 2009/07/19 11:12:01 glchen ship $ */

/******************************************************************************

  FUNCTION
     fautfr() - FA Utility TransFeR asset

  DESCRIPTION
     This function is a generic transfer function, that transfers a single
     asset's COST, DEPRN RSV, and REVAL RSV from one set of accounts to
     another, for all of an asset's active distribution lines.

     For intercompany transfers, it also inserts the appropriate
     FA_ADJUSTMENTS rows as well, for those distributions that
     have the balancing segment different from the distribution that
     was transferred out of. FA_ADJUSTMENTS rows are inserted for
     the AR_INTERCOMPANY_ACCT and AP_INTERCOMPANY_ACCT code combination
     ids.

     The accounts it transfers to/from are determined by the old
     and new category ids passed in. (In the case of a transfer, these
     two are the same, but in the general case, they may be different, ie
     a reclassification).

     This module assumes that the caller has terminated and inserted into
     the FA_DISTRIBUTION_HISTORY table already with the thid parameter
     passed into the function.

  PARAMETERS
     * X_thid
         The transaction header id for the TRANSFER/UNIT ADJUSTMENT/RECLASS
         TRANSACTION_TYPE_CODE which terminated the distributions.

     * X_asset_id
         The asset_id.

     * X_book
         book type code.

     * X_txn_type_code
         transaction type code, i.e TRANSFER/UNIT ADJUSTMENT/RECLASS.

     * X_period_ctr
         The period counter the transaction is occuring in. This gets
         inserted into FA_ADJUSTMENTS as the
         PERIOD_COUNTER_CREATED/ADJUSTED.

     * X_current_units
         Since we call in CLEAR mode, we don't need to know the old
         number of units for UNIT ADJUSTMENTS, just pass in the new
         number of units for this field.

     * X_today
         date in the format of 'DD-MON-YYYY HH24:MI:SS'

     * X_old_cat_id
         The asset_category_id before the transaction. For TRANSFERS,
         old_cat_id = new_cat_id, but for RECLASSes, these will be
         different. This determines the accounts to transfer to/from.

     * X_new_cat_id
         The new asset_category_id after the transaction.

     * X_asset_type
         The asset type, ie CIP, CAPITALIZED, or EXPENSED. We don't
         insert any FA_ADJUSTMENTS rows for EXPENSED assets.

  RETURNS
     TRUE, on successful transfer
     FALSE, for an error condition

  HISTORY
     04 Mar 1997       L Son          Created

******************************************************************************/


FUNCTION fautfr(X_thid               IN   NUMBER,
                X_asset_id           IN   NUMBER,
                X_book               IN   VARCHAR2,
                X_txn_type_code      IN   VARCHAR2,
                X_period_ctr         IN   NUMBER,
                X_curr_units         IN   NUMBER,
                X_today              IN   DATE,
                X_old_cat_id         IN   NUMBER,
                X_new_cat_id         IN   NUMBER,
                X_asset_type         IN   VARCHAR2,
                X_last_update_date   IN DATE default sysdate,
                X_last_updated_by    IN NUMBER default -1,
                X_last_update_login  IN NUMBER default -1,
		X_init_message_flag  IN VARCHAR2 DEFAULT 'NO', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

         return BOOLEAN;






/*****************************************************************************
  NAME
     fadotfr() - FA DO a TransFeR

  DESCRIPTION
     This function does a transfer for a single asset for a single type
     of account; it both clears out the old amounts using the Insert
     into FA_ADJUSTMENTS function's CLEAR mode, then puts the amounts
     back in using the Insert into FA_ADJUSTMENTS function's ACTIVE mode.

  PARAMETERS
     X_adj_ptr - structure defined in fa_adjust_type_pkg

     X_acctcode - constant value defined in the body of this package.
                  represents each account type for which fa_adjustments rows are
                  inserted (e.g FA_TFR_COST, FA_TFR_DEPRN_RSV etc.)

     X_old_cat_id - category id of terminated distribution

     X_new_cat_id - category id of new distribution

     X_asset_type - asset_type ('CAPITALIZED', 'CIP' etc)

  RETURNS
     TRUE, on successful completion
     FALSE, for an error condition

  HISTORY
     04 Mar 1997     L Son         Created

******************************************************************************/


FUNCTION fadotfr(X_adj_ptr       IN OUT NOCOPY   fa_adjust_type_pkg.fa_adj_row_struct,
                 X_acctcode      IN   NUMBER,
                 X_old_cat_id    IN   NUMBER,
                 X_new_cat_id    IN   NUMBER,
                 X_asset_type    IN   VARCHAR2,
                 X_last_update_date  IN DATE default sysdate,
                 X_last_updated_by   IN NUMBER default -1,
                 X_last_update_login  IN NUMBER default -1,
                 X_mrc_sob_type_code  IN VARCHAR2,
                 X_set_of_books_id    IN NUMBER,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

         return BOOLEAN;







/*****************************************************************************
  NAME
     setacct() - SET the ACCounT information

  DESCRIPTION
     This function sets the account, account_type, debit_credit_flag,
     and adjustment_type fields in the X_adj structure according to
     the acctcode and the select_mode flags.

  PARAMETERS
     X_adj_ptr  - record structure containing info to insert into fa_adjustments
     X_acctcode - constant value representing each account type for which
                  fa_adjustment rows are inserted

     X_select_mode - debit(DR) or credit(CR) is set depending on the mode

     X_cat_id  - category_id
     X_asset_type  - asset_type

  RETURNS
     TRUE, on successful completion
     FALSE, for an error condition

  HISTORY
     04 Mar 1997     L Son         Created

******************************************************************************/

FUNCTION setacct(X_adj_ptr  IN OUT NOCOPY fa_adjust_type_pkg.fa_adj_row_struct,
                 X_acctcode IN NUMBER,
                 X_select_mode IN NUMBER,
                 X_cat_id      IN NUMBER,
                 X_asset_type  IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return BOOLEAN;







/*****************************************************************************

  NAME
     fatsgl() -

  DESCRIPTION
     This function finds all distributions affected by the transfer in the
     order of terminated distribution rows followed by active distribution rows.

     For each fetched terminated distribution, 1) it calls query_balances_int to get
     cost, depreciation reserve, revaluation reserve  2) accumulate total_cost,
     total depreciation reserve, total revaluation reserve  to re-distribute
     to active distribution 3) insert rows into fa_adjustments to clear out the
     amount from the terminated distribution.

     For each fetched active distribution, 1)total cost, total deprn reserve
     and total reval reserve accumulated above will be prorated to each distribution
     based on its units assigned 2) insert rows with prorated amount into fa_adjustments
     3) last distribution will get the remaning pennies leftover from doing rounding.


  PARAMETERS
     X_adj  - record structure containning info for fa_adjusment row
     X_cat_id - category_id
     X_asset_type - asset_type

  RETURNS
     TRUE, on successful completion
     FALSE, for an error condition

  HISTORY
     04 Mar 1997     L Son         Created

******************************************************************************/


FUNCTION fatsgl(X_adj         IN OUT NOCOPY fa_adjust_type_pkg.fa_adj_row_struct,
                X_cat_id      IN  NUMBER,
                X_asset_type  IN  VARCHAR2,
                X_last_update_date  IN DATE default sysdate,
                X_last_updated_by   IN NUMBER default -1,
                X_last_update_login  IN NUMBER default -1,
                X_mrc_sob_type_code  IN VARCHAR2,
                X_set_of_books_id    IN NUMBER,
                p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return BOOLEAN;


/*===========================================================================
 |
 | NAME:         faumvexp() - FA Move Expense
 |
 | DESCRIPTION:  Move catchup expense like amort adj expense
 |               to a new distribution for reclass in period of addition
 |
 | RETURNS:    TRUE, on successful completion
 |             FALSE, on error condition
 |
 |   History
 |        16-Aug-2005           YYOON              Created
 |
============================================================================*/

FUNCTION faumvexp(X_asset_id            NUMBER
                 ,X_book_type_code      VARCHAR2
                 ,X_th_id               NUMBER
                 ,X_to_category_id      NUMBER
                 ,X_exp_moved           OUT NOCOPY BOOLEAN
                 ,X_last_update_date    DATE
                 ,X_last_updated_by     NUMBER
                 ,X_last_update_login   NUMBER
                 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION faucper(X_asset_id NUMBER,
                 X_is_prior_period IN OUT NOCOPY BOOLEAN,
                 X_book VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)         RETURN BOOLEAN;


END FA_TRANSFER_XIT_PKG;

/
