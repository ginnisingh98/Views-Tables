--------------------------------------------------------
--  DDL for Package AR_PUBLIC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_PUBLIC_UTILS" AUTHID CURRENT_USER AS
/* $Header: ARXPUTLS.pls 120.4 2005/10/30 04:28:15 appldev noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

 TYPE application_tbl_type IS TABLE of ar_receivable_applications%ROWTYPE
      INDEX BY BINARY_INTEGER;

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC Procedure get_payment_info
 |
 | DESCRIPTION
 |       This function retunrs the receipt and application details for a
 |       payment server order number passed.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |       IN
 |         p_payment_server_order_num
 |         p_application_type -Valid values APP,UNAPP,ACC,OTHER ACC,ACTIVITY
 |       OUT NOCOPY
 |         p_receipt_header - Receipt Header Rowtype
 |         p_app_rec        - Application Rowtype
 |         x_return_status  - Standard return status
 |         x_msg_data       - Standard msg data
 |         x_msg_count      - Standard msg count
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
 | 22-Jan-2002           S.Nambiar      Created
 | 22-Jan-2002           S.Nambiar      Bug 2195124 - CRM-iPayment needs to get
 |                                      the invoice informations for a payment
 |                                      server order number.
 |
 *=======================================================================*/
 PROCEDURE get_payment_info(
               p_payment_server_order_num IN
                              ar_cash_receipts.payment_server_order_num%TYPE,
               p_application_type IN ar_receivable_applications.status%TYPE DEFAULT 'APP',
               p_receipt_header  OUT NOCOPY ar_cash_receipts%ROWTYPE,
               p_app_rec         OUT NOCOPY application_tbl_type,
               x_return_status   OUT NOCOPY VARCHAR2,
               x_msg_count       OUT NOCOPY NUMBER,
               x_msg_data        OUT NOCOPY VARCHAR2
               );

/*========================================================================
 | PUBLIC Function Check_Prepay_Payment_Term
 |
 | DESCRIPTION
 |       If the passed payment term is a prepayment payment term,this
 |       function returns value 'Y' else 'N'.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |       IN
 |         p_payment_term_id
 |
 |
 | RETURNS
 |       Returns value 'Y' or 'N'.
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |     A stub version of this routine is provided to product team which
 |     access the prepayment_flag from ra_terms view.Stub version always
 |     returns 'N'.
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 22-Jan-2002           S.Nambiar      Created
 | 21-Feb-2002           S.Nambiar      Removed direct reference to table
 |                                      columns and replace with NUMBER.
 |
 *=======================================================================*/
 FUNCTION Check_Prepay_Payment_Term
               (p_payment_term_id IN NUMBER)
 RETURN VARCHAR2;

/*========================================================================
 | PUBLIC Function Check_Prepay_Transaction
 |
 | DESCRIPTION
 |       If the transaction is a prepaid transaction,function returns value 'Y'
 |       else 'N'.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |       IN
 |         p_customer_trx_id
 |
 |
 | RETURNS
 |       Returns value 'Y' or 'N'.
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |     A stub version of this routine is provided to product teams which
 |     access the prepayment_flag from ra_customer_trx view.Stub version
 |     always  returns 'N'.
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 22-Jan-2002           S.Nambiar      Created
 | 21-Feb-2002           S.Nambiar      Removed direct reference to table
 |                                      columns and replace with NUMBER.
 |
 *=======================================================================*/
 FUNCTION Check_Prepay_Transaction
                (p_customer_trx_id IN NUMBER)
 RETURN VARCHAR2;

END AR_PUBLIC_UTILS;

 

/
