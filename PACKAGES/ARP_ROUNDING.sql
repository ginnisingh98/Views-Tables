--------------------------------------------------------
--  DDL for Package ARP_ROUNDING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ROUNDING" AUTHID CURRENT_USER AS
/* $Header: ARPLCRES.pls 120.3.12010000.2 2008/11/11 14:29:25 dgaurab ship $ */


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   correct_dist_rounding_errors()                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects all rounding errors in the                     |
 |   ra_cust_trx_line_gl_dist table.                                       |
 |                                                                         |
 | REQUIRES                                                                |
 |   P_REQUEST_ID, P_CUSTOMER_TRX_ID or P_CUSTOMER_TRX_LINE_ID             |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   FALSE otherwise.                                                      |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   03-AUG-02   M Raymond     Bug 2497841 - Added parameter p_fix_rec_offset
 |                             to control call to set_rec_offset_flag routine.
 |
 +-------------------------------------------------------------------------*/


FUNCTION correct_dist_rounding_errors
                 ( P_REQUEST_ID                    IN NUMBER,
                   P_CUSTOMER_TRX_ID               IN NUMBER,
                   P_CUSTOMER_TRX_LINE_ID          IN NUMBER,
                   P_ROWS_PROCESSED            IN OUT NOCOPY NUMBER,
                   P_ERROR_MESSAGE                OUT NOCOPY VARCHAR2,
                   P_BASE_PRECISION                IN NUMBER,
                   P_BASE_MIN_ACCOUNTABLE_UNIT     IN VARCHAR2,
                   P_TRX_CLASS_TO_PROCESS          IN VARCHAR2  DEFAULT 'ALL',
                   P_CHECK_RULES_FLAG              IN VARCHAR2  DEFAULT 'N',
                   P_DEBUG_MODE                    IN VARCHAR2,
                   P_TRX_HEADER_LEVEL_ROUNDING         IN VARCHAR2  DEFAULT 'N',
                   P_ACTIVITY_FLAG                 IN VARCHAR2  DEFAULT 'N',
                   P_FIX_REC_OFFSET                IN VARCHAR2 DEFAULT 'Y'
                 ) RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   correct_scredit_rounding_errors()                                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects all rounding errors in the                     |
 |   ra_cust_trx_line_salesreps table.                                     |
 |                                                                         |
 | REQUIRES                                                                |
 |   P_CUSTOMER_TRX_ID							   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   30-AUG-95  Charlie Tomberg       Created                              |
 +-------------------------------------------------------------------------*/

PROCEDURE correct_scredit_rounding_errs( p_customer_trx_id   IN NUMBER,
                                         p_rows_processed   OUT NOCOPY NUMBER
                                       );


/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   set_rec_offset_flag()                                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function attempts to set the rec_offset_flag on UNEARN lines
 |   for the specified transaction.                     |
 |                                                                         |
 | REQUIRES                                                                |
 |   P_CUSTOMER_TRX_ID							   |
 |   P_REQUEST_ID
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   28-AUG-02  Michael Raymond       Created                              |
 |   28-AUG-02  Michael Raymond       Added request_id parameter
 |   27-MAR-08  M Raymond           6782405 - Added p_result parameter
 |                                     -1 = No rows updated
 |                                      0 = No action required
 |                                      1 = Rows updated
 +-------------------------------------------------------------------------*/

PROCEDURE set_rec_offset_flag( p_customer_trx_id IN
                                   ra_customer_trx.customer_trx_id%type,
                               p_request_id IN ra_customer_trx.request_id%type,
                               p_result OUT NOCOPY NUMBER);

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   insert_round_records()                                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function inserts ROUND class rows in gl_dist table when/if
 |    they do not already exist.
 |                                                                         |
 | REQUIRES                                                                |
 |   P_CUSTOMER_TRX_ID							   |
 |   P_REQUEST_ID
 |   P_BASE_PRECISION
 |   P_BASE_MAU
 |   P_TRX_CLASS_TO_PROCESS
 |   P_TRX_HEADER_ROUND_CCID
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   01-OCT-03  Michael Raymond       Made public for bug 2975417/3067588  |
 +-------------------------------------------------------------------------*/
FUNCTION insert_round_records( P_REQUEST_ID IN NUMBER,
                               P_CUSTOMER_TRX_ID       IN NUMBER,
                               P_ROWS_PROCESSED        IN OUT NOCOPY NUMBER,
                               P_ERROR_MESSAGE            OUT NOCOPY VARCHAR2,
                               P_BASE_PRECISION        IN NUMBER,
                               P_BASE_MAU              IN NUMBER,
                               P_TRX_CLASS_TO_PROCESS  IN VARCHAR2,
                               P_TRX_HEADER_ROUND_CCID IN NUMBER)
RETURN NUMBER;


FUNCTION get_line_round_acctd_amount(P_CUSTOMER_TRX_ID   IN NUMBER)
RETURN NUMBER;

/* Bug 3879222 - new function for rounding revenue adjustments */
FUNCTION correct_rev_adj_by_line
RETURN NUMBER;


/************************************************
 FUNCTION get_dist_round_acctd_amount is obsolete
*************************************************/
FUNCTION get_dist_round_acctd_amount(P_CUSTOMER_TRX_ID IN NUMBER)
RETURN NUMBER;

END ARP_ROUNDING;

/
