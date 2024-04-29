--------------------------------------------------------
--  DDL for Package FA_GCCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GCCID_PKG" AUTHID CURRENT_USER as
/* $Header: FAFBGCS.pls 120.3.12010000.2 2009/07/19 14:43:47 glchen ship $tpershad ship */

 global_concat_segs  varchar2(2000);
 fafb_accts  FA_FLEX_TYPE.fafb_acct_tab_type;


  -- BUG# 2215671: this should only be set from FAPOST
  -- where the book and period remain constant.  To cache this
  -- for normal transactions (even mass would require some more
  -- work, since transactions could occur accross multiple
  -- books in any given session (format = DD/MM/YYYY)

  G_validation_date   varchar2(10);

/*
 --------------------------------------------------------------------------
 *
 * Name		fafbgcc
 *
 *
 * Description
 *		 It constructs the flex function name by calling
 *		 search_functions and then calls the Flex builder
 *		 FAFLEXB.fafb_call_flex
 * Notes
 *
 * Parameters
 * 	book_type_code	varchar2
 *  	fn_trx_code     in varchar2 Financial trx code. This is
 *		        used to generate the function name
 *			which is passed to flex builder
 *  	dist_ccid       in number  - distribution ccid.
 *  	acct_segval     in varchar2 - Seg value for acct segment
 *      rtn_ccid        out number - Generated ccid
 *
 * Modifies
 *
 * Returns
 *		True on successful retrieval. Otherwise False.
 *
 * History
 *
 *------------------------------------------------------------------
*/
FUNCTION fafbgcc (X_book_type_code in fa_book_controls.book_type_code%type,
		  X_fn_trx_code    in varchar2,
		  X_dist_ccid	 in number,
		  X_acct_segval	 in varchar2,
		  X_account_ccid in number,
		  X_distribution_id in number,
	          X_rtn_ccid       out nocopy number,
                  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type
default null)
  return boolean;



/*
 --------------------------------------------------------------------------
 *
 * Name		fafbgcc_proc
 *
 *
 * Description
 *		 This procedure is used for calling from C functions
 *		 Calling func fafbgcc from C program was causing some
 *		 problems so this procedure was created to call
 *		 from C program as a workaround only.This proc just
 *	         calls fafbgcc and does nothing. In future we can
 *               remove this and then change the C program to call
 *		 the func fafbgcc directly
 * Notes
 *
 * Parameters
 *
 * Modifies
 *
 * Returns
 *		none
 *
 * History
 *
 *------------------------------------------------------------------
*/

PROCEDURE fafbgcc_proc
		  (X_book_type_code in fa_book_controls.book_type_code%type,
                  X_fn_trx_code  in varchar2,
                  X_dist_ccid    in integer,
                  X_acct_segval  in varchar2,
                  X_account_ccid in integer,
                  X_distribution_id in integer,
                  X_rtn_ccid        out nocopy number,
		  X_concat_segs	    out nocopy varchar2,
		  X_return_value    out nocopy integer);

-----------------------------------------------------------------------------
/*
 --------------------------------------------------------------------------
 *
 * Name         get_ccid
 *
 *
 * Description
 *               This function is called from fafbgcc and fafbgcc_proc
 *               This function checks to see if ccid exists in
 *               fa_distribution_accounts and also checks if ccid is
 *               valid.
 * Notes
 *
 * Parameters
 *
 * Modifies
 *
 * Returns
 *              X_rtn_ccid, X_ccid_found
 *
 * History
 *
 *------------------------------------------------------------------
*/

FUNCTION get_ccid (X_book_type_code     IN      VARCHAR2,
                   X_distribution_id    IN      NUMBER,
                   X_fn_trx_code        IN      VARCHAR2,
                   X_validation_date    IN      DATE,
		   X_ccid_found	 OUT NOCOPY     BOOLEAN,
                   X_rtn_ccid           OUT NOCOPY     NUMBER
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null)
         RETURN BOOLEAN;

/*
 --------------------------------------------------------------------------
 *
 * Name         fafbgcc_proc_msg
 *
 *
 * Description
 *               This procedure is called directly from fafbgcc (Pro*C)
 *               It retrieves the PL/SQL message stack (and count)
 *               into the variables for display in concurrent logs.
 *
 * Notes
 *
 * Parameters
 *
 * Modifies
 *
 * Returns
 *              X_mesg_count, X_mesg_string
 *
 * History
 *              created    bridgway  05/02/01
 *
 *------------------------------------------------------------------
 *
 */


PROCEDURE fafbgcc_proc_msg(X_mesg_count   IN OUT NOCOPY number,
                           X_mesg_string  IN OUT NOCOPY VARCHAR2);

END FA_GCCID_PKG;

/
