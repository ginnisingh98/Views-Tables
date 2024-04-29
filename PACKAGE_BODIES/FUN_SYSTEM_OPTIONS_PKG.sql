--------------------------------------------------------
--  DDL for Package Body FUN_SYSTEM_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_SYSTEM_OPTIONS_PKG" as
/* $Header: funsysutilb.pls 120.7 2004/01/07 00:26:48 aslai noship $  */

/*-----------------------------------------------------
 * FUNCTION get_min_trx_amt
 * ----------------------------------------------------
 *  Get the minimum transaction amount for a
 *  given currency.  Returns T if the minimum
 *  amount can be retrieved.
 * ---------------------------------------------------*/
function get_min_trx_amt(l_min_amt OUT NOCOPY NUMBER,
                         l_min_curr_code OUT NOCOPY VARCHAR2)
return boolean is
l_def_curr VARCHAR2(15);
BEGIN
      SELECT min_trx_amt, min_trx_amt_currency, default_currency
      INTO l_min_amt, l_min_curr_code, l_def_curr
	  FROM FUN_SYSTEM_OPTIONS
	  WHERE system_option_id = 0;
      IF l_min_curr_code IS NULL THEN
          l_min_curr_code := l_def_curr;
      END IF;
      return TRUE;
END;

/*-----------------------------------------------------
 * FUNCTION is_apar_batch
 * ----------------------------------------------------
 * Test whether AP/AR transfer is batched.
 * ---------------------------------------------------*/

function is_apar_batch return boolean
is
l_apar_batch FUN_SYSTEM_OPTIONS.apar_batch_flag%TYPE;
BEGIN
          SELECT   apar_batch_flag INTO l_apar_batch
	  FROM FUN_SYSTEM_OPTIONS
	  WHERE system_option_id = 0;
          IF l_apar_batch  = 'B' THEN
 		  RETURN TRUE ;
	  END IF ;
          return FALSE;
end is_apar_batch;

/*-----------------------------------------------------
 * FUNCTION is_gl_batch
 * ----------------------------------------------------
 * Test whether GL transfer is batched.
 * ---------------------------------------------------*/

function is_gl_batch return boolean
is
  l_gl_batch FUN_SYSTEM_OPTIONS.gl_batch_flag%TYPE;
BEGIN
          SELECT  gl_batch_flag INTO l_gl_batch
	  FROM FUN_SYSTEM_OPTIONS
	  WHERE system_option_id = 0;
          IF l_gl_batch = 'B' THEN
 		 RETURN TRUE ;
	  END IF ;
          return FALSE;
end is_gl_batch;




/*-----------------------------------------------------
 * FUNCTION is_manual_numbering
 * ----------------------------------------------------
 * Test whether numbering is manual.
 * ---------------------------------------------------*/

function is_manual_numbering return boolean
is
l_numbering_type FUN_SYSTEM_OPTIONS.numbering_type%TYPE;
BEGIN
          SELECT  numbering_type INTO l_numbering_type
	  FROM FUN_SYSTEM_OPTIONS
	  WHERE system_option_id = 0;
          IF l_numbering_type  = 'MAN' THEN
 		 RETURN TRUE ;
          END IF;
          return FALSE;
end is_manual_numbering;




/*-----------------------------------------------------
 * FUNCTION get_allow_reject
 * ----------------------------------------------------
 * Test whether the recipients can reject.
 * ---------------------------------------------------*/

function get_allow_reject return boolean
is
  l_allow_reject FUN_SYSTEM_OPTIONS.ALLOW_REJECT_FLAG%TYPE;
BEGIN
          SELECT  ALLOW_REJECT_FLAG  INTO l_allow_reject
	  FROM FUN_SYSTEM_OPTIONS
	  WHERE system_option_id = 0;
          IF l_allow_reject = 'Y' THEN
            RETURN TRUE ;
	  END IF ;
          return FALSE;
end get_allow_reject;




/*-----------------------------------------------------
 * FUNCTION get_default_currency
 * ----------------------------------------------------
 * Get the default currency.
 * Return the currency code.
 * --------------------------------------------------- */

function get_default_currency return varchar2 IS
   l_def_curr FUN_SYSTEM_OPTIONS.default_currency%TYPE DEFAULT null;
BEGIN
          SELECT default_currency  INTO l_def_curr
	  FROM FUN_SYSTEM_OPTIONS
	  WHERE system_option_id = 0;
          RETURN l_def_curr ;
end get_default_currency;




/*-----------------------------------------------------
 * FUNCTION get_exchg_rate_type
 * ----------------------------------------------------
 * Get the default exchange rate type.
 * Return the conversion type.
 * ---------------------------------------------------*/

function get_exchg_rate_type return varchar2
is
  l_rate FUN_SYSTEM_OPTIONS.exchg_rate_type%TYPE DEFAULT null;
BEGIN
          SELECT exchg_rate_type  INTO l_rate
	  FROM FUN_SYSTEM_OPTIONS
	  WHERE system_option_id = 0;
	  RETURN l_rate ;
 end get_exchg_rate_type;



END fun_system_options_pkg;
----------------------------------------------------------------------
--				END OF PACKAGE BODY
----------------------------------------------------------------------


/
