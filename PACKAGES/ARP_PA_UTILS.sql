--------------------------------------------------------
--  DDL for Package ARP_PA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PA_UTILS" AUTHID CURRENT_USER AS
/* $Header: ARXPAUTS.pls 120.0.12010000.2 2008/11/24 07:59:33 rsamanta ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC Procedure get_line_applied
 |
 | DESCRIPTION
 |       This function returns the total line amount applied and
 |       corresponding exchange rate gain and/or loss as of given date for the
 |       the given invoice.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |       IN
 |         p_customer_trx_id
 |         p_as_of_date
 |       OUT NOCOPY
 |         x_line_applied           - Line applied
 |         x_line_acctd_applied     - Line applied in Functional Currency
 |         x_xchange_gain           - Exchange Gain
 |         x_xchange_loss           - Exchange Loss
 |         x_return_status          - Standard return status
 |         x_msg_data               - Standard msg data
 |         x_msg_count              - Standard msg count
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 22-Jul-2002           Ramakant Alat  Created
 | 22-Aug-2002           MGOWDA         Added MRC logic
 |
 *=======================================================================*/
 TYPE num_arr is TABLE OF NUMBER;
 TYPE r_appl_amt_rec IS RECORD
                  (sob_id                 NUMBER(15),
                   amount_applied         NUMBER,
                   acctd_amount_applied   NUMBER,
                   exchange_loss          NUMBER,
                   exchange_gain          NUMBER,
                      /* Added for FP bug6673099 */
                   line_adjusted          NUMBER,
                   acctd_line_adjusted    NUMBER);
 TYPE r_appl_amt_list IS TABLE OF r_appl_amt_rec
 INDEX by binary_integer;

 PROCEDURE get_line_applied(
               p_application_id IN
                   ar_receivable_applications.applied_customer_trx_id%TYPE,
               p_customer_trx_id IN
                   ar_receivable_applications.applied_customer_trx_id%TYPE,
               p_as_of_date      IN ar_receivable_applications.apply_date%TYPE
                                                DEFAULT sysdate,
               p_process_rsob    IN VARCHAR2 DEFAULT 'N',
               x_applied_amt_list  OUT NOCOPY ARP_PA_UTILS.r_appl_amt_list,
               x_return_status   OUT NOCOPY VARCHAR2,
               x_msg_count       OUT NOCOPY NUMBER,
               x_msg_data        OUT NOCOPY VARCHAR2
               ) ;

END ARP_PA_UTILS;

/
