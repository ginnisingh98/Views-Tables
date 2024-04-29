--------------------------------------------------------
--  DDL for Package ZX_TAX_STR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_STR_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrirsalestxpvts.pls 120.0.12010000.1 2008/11/21 17:43:32 nisinha noship $ */

/* =======================================================================|
 | PROCEDURE initialize
 |
 | DESCRIPTION
 |      Initilize the arrays to hold the segments of range of accounts
 |      given. This will be held by two array during the same session
 |      to do not recalculate them every time the function
 |      get_ccid_inrange_flag is called.
 |
 | PARAMETERS
 |      p_min_gl_flex  IN  VARCHAR2. String containg the min range of
 |                                   accounts given.
 |      p_max_gl_flex  IN  VARCHAR2. String containg the max range of
 |                                   accounts given.
 *========================================================================*/
PROCEDURE initialize(p_min_gl_flex VARCHAR2,
                     p_max_gl_flex VARCHAR2);

/* =========================================================================|
 | FUNCTION get_credit_memo_trx_number
 |
 | DESCRIPTION
 |      Returns the transaction number for the credit memo.
 |
 | PARAMETERS
 |      p_previous_customer_trx_id  IN  Transaction to wich the Credit Memo
 |                                      is refering.
 *=========================================================================*/
FUNCTION get_credit_memo_trx_number(p_previous_customer_trx_id  IN NUMBER )
  RETURN VARCHAR;


/* ==========================================================================
 | FUNCTION get_credit_memo_trx_date
 |
 | DESCRIPTION
 |      Returns the transaction date for the credit memo.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_previous_customer_trx_id  IN  Transaction to wich the Credit Memo
 |                                      is refering.
 *=========================================================================*/
FUNCTION  get_credit_memo_trx_date(p_previous_customer_trx_id  IN NUMBER )
  RETURN DATE;


/* ==========================================================================
 | FUNCTION get_ccid_inrange_flag
 |
 | DESCRIPTION
 |      Returns the transaction date for the credit memo.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_code_combination_id         IN Code Combination Id to identify if
 |                                       it is in the range of the segments
 |                                       given.
 |      p_array_min_gl_flex,
 |      p_array_max_gl_flex           IN Array of segments that define
 |                                       the range to evaluate for the CCID.
 *=========================================================================*/
FUNCTION  get_ccid_inrange_flag(p_code_combination_id       IN NUMBER
                                ) RETURN VARCHAR2;

END ZX_TAX_STR_PKG;

/
