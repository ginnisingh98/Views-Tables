--------------------------------------------------------
--  DDL for Package FUN_SYSTEM_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_SYSTEM_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: funsysutils.pls 120.6 2004/01/07 00:26:10 aslai noship $*/

/*-----------------------------------------------------
 * FUNCTION get_min_trx_amt
 * ----------------------------------------------------
 *  Get the minimum transaction amount and
 *  the corresponding currency.  Returns F if
 *  the minimum amount is not defined.
 * ---------------------------------------------------*/
function get_min_trx_amt(l_min_amt OUT NOCOPY NUMBER,
                         l_min_curr_code OUT NOCOPY VARCHAR2)
return boolean;

/*-----------------------------------------------------
 * FUNCTION is_apar_batch

 * ----------------------------------------------------
 * Test whether AP/AR transfer is batched.
 * ---------------------------------------------------*/

function is_apar_batch return boolean;

 /*-----------------------------------------------------
 * FUNCTION is_gl_batch
 * ----------------------------------------------------
 * Test whether GL transfer is batched.
 * ---------------------------------------------------*/

 function is_gl_batch return boolean;


/*-----------------------------------------------------
 * FUNCTION is_manual_numbering

 * ----------------------------------------------------
 * Test whether numbering options is manual
 * ---------------------------------------------------*/

function is_manual_numbering  return boolean;

/*-----------------------------------------------------
 * FUNCTION get_allow_reject
 * ----------------------------------------------------
 * Test whether the recipients can reject.
 * ---------------------------------------------------*/

function get_allow_reject return boolean;

 /*-----------------------------------------------------
 * FUNCTION get_default_currency
 * ----------------------------------------------------
 * Get the default currency.
 * Return the currency code.
 * ---------------------------------------------------*/

function get_default_currency return varchar2;

/*-----------------------------------------------------
 * FUNCTION get_exchg_rate_type
 * ----------------------------------------------------
 * Get the default exchange rate type.
 * Return the conversion type.
 * ---------------------------------------------------*/
function get_exchg_rate_type return varchar2;


END fun_system_options_pkg;

 

/
