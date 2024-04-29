--------------------------------------------------------
--  DDL for Package AR_IDEP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_IDEP_UTILS" AUTHID CURRENT_USER AS
/* $Header: ARDEPUTS.pls 120.3 2005/08/12 13:01:11 rsinthre noship $ */



/*========================================================================
 | PUBLIC function get_course_description
 |
 | DESCRIPTION
 |      function which returns the description of a course which is an item in
 |      an invoice against a deposit.
 |      Wrapper function on OTA_UTILITY.GET_DESCRIPTION
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   pn_deposit_id   Deposit Identifier
 |
 | RETURNS
 |   Original owners email address
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author                 Description of Changes
 | 20-Jun-2001           Krishnakumar Menon      Created
 *=======================================================================*/

FUNCTION get_course_description(pn_line_id   IN  Number,
                                pv_uom       IN  Varchar2) RETURN VARCHAR2;


/*========================================================================
 | PUBLIC function get_reserved_commitment_amt
 |
 | DESCRIPTION
 |      function which returns the reserved amount for a given commitment/deposit.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_customer_trx_id      The deposit identifier
 |
 | RETURNS
 |   The reserved amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author                 Description of Changes
 | 13-Dec-2001           Krishnakumar Menon      Created
 *=======================================================================*/
FUNCTION get_reserved_commitment_amt (p_customer_trx_id in NUMBER) RETURN NUMBER;



/*========================================================================
 | PUBLIC function get_applied_commitment_amt
 |
 | DESCRIPTION
 |      function which returns the applied amount for a given commitment/deposit.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_customer_trx_id      The deposit identifier
 |
 | RETURNS
 |   The applied amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author       Description of Changes
 | 02-May-2002           krmenon      Created
 *=======================================================================*/
FUNCTION get_applied_commitment_amt (p_customer_trx_id in NUMBER) RETURN NUMBER;

END AR_IDEP_UTILS;

 

/
