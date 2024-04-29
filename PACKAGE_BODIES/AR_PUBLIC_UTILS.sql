--------------------------------------------------------
--  DDL for Package Body AR_PUBLIC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_PUBLIC_UTILS" AS
/* $Header: ARXPUTLB.pls 120.5 2005/10/30 04:28:14 appldev noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

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
 |         p_application_type -Valid values APP,UNAPP,ACC,OTHER ACC, ACTIVITY
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
               ) IS

 CURSOR app_rec_cur(c_cash_receipt_id ar_cash_receipts.cash_receipt_id%TYPE) IS
                SELECT *
                FROM   ar_receivable_applications
                WHERE  cash_receipt_id=c_cash_receipt_id
                AND    status = p_application_type
                AND    display='Y';

 l_receipt_header            ar_cash_receipts%ROWTYPE;
 l_payment_server_order_num  ar_cash_receipts.payment_server_order_num%TYPE;
 table_index  NUMBER := 1;

 BEGIN
     arp_util.debug('ar_public_utils.get_payment_info (+)');
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_payment_server_order_num IS NOT NULL THEN

        SELECT cr.*
        INTO   l_receipt_header
        FROM   ar_cash_receipts cr
        WHERE  cr.payment_server_order_num=p_payment_server_order_num
        AND EXISTS  (SELECT status from ar_cash_receipt_history crh
                    WHERE crh.status = 'REMITTED'
                    AND crh.cash_receipt_id=cr.cash_receipt_id);

     END IF;

     IF l_receipt_header.cash_receipt_id IS NOT NULL THEN

        FOR app_rec IN app_rec_cur(l_receipt_header.cash_receipt_id)
        LOOP
            p_app_rec(table_index) := app_rec;
            table_index := table_index+1;

        END LOOP;

     END IF;

     p_receipt_header := l_receipt_header;

     arp_util.debug('ar_public_utils.get_payment_info (-)');

 EXCEPTION
    WHEN no_data_found THEN

      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ar_public_utils.get_payment_info:PSON Does not exist');
      FND_MSG_PUB.Add;

      FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                 p_count  =>  x_msg_count,
                                 p_data   => x_msg_data
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN others THEN
      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ar_public_utils.get_payment_info:'||SQLERRM);
      FND_MSG_PUB.Add;

      FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                 p_count  =>  x_msg_count,
                                 p_data   => x_msg_data
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;

 END;
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
 | 24-Jan-2002           S.Nambiar      Stub version created to return 'N'
 | 21-Feb-2002           S.Nambiar      Removed debug messages for the functions
 |                                      and removed direct reference to table
 |                                      column for function parameter.
 *=======================================================================*/
 FUNCTION Check_Prepay_Payment_Term
               (p_payment_term_id IN NUMBER)
 RETURN VARCHAR2 IS

 l_prepayment_flag VARCHAR2(1) := 'N';

 BEGIN

     SELECT NVL(prepayment_flag,'N')
     INTO   l_prepayment_flag
     FROM   ra_terms
     WHERE  term_id=p_payment_term_id;


     RETURN l_prepayment_flag;
 EXCEPTION
   WHEN others THEN
     RETURN l_prepayment_flag;
 END;
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
 | 24-Jan-2002           S.Nambiar      Stub version created to return 'N'
 | 21-Feb-2002           S.Nambiar      Removed debug messages for the functions
 |                                      and removed direct reference to table
 |                                      column for function parameter.
 *=======================================================================*/
 FUNCTION Check_Prepay_Transaction
                (p_customer_trx_id IN NUMBER)
 RETURN VARCHAR2 IS

 l_prepayment_flag VARCHAR2(1) := 'N';

 BEGIN

     SELECT NVL(prepayment_flag,'N')
     INTO   l_prepayment_flag
     FROM   ra_customer_trx
     WHERE  customer_trx_id=p_customer_trx_id;

     RETURN l_prepayment_flag;
 EXCEPTION
   WHEN others THEN
     RETURN l_prepayment_flag;
 END;

END AR_PUBLIC_UTILS;

/
