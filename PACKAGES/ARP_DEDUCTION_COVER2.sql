--------------------------------------------------------
--  DDL for Package ARP_DEDUCTION_COVER2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DEDUCTION_COVER2" AUTHID CURRENT_USER AS
/* $Header: ARXDC2VS.pls 120.0 2005/04/05 14:22:03 jbeckett noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE reapply_credit_memo
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure calls entity handlers to unapply and reapply a
 |      credit memo with a revised amount applied.
 |      Typically for an on account credit memo used to settle
 |	more than 1 deduction on the same receipt.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_customer_trx_id    IN    Transaction  being reapplied
 |      p_cash_receipt_id    IN    Receipt to which it is applied
 |      p_amount_applied     IN    New amount applied
 |      p_init_msg_list      IN
 |      x_return_status      OUT NOCOPY
 |      x_msg_count          OUT NOCOPY
 |      x_msg_data           OUT NOCOPY
 |
 | KNOWN ISSUES                                                                  |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 01-APR-2005   jbeckett          Created
 |
 *=======================================================================*/
PROCEDURE reapply_credit_memo(
                p_customer_trx_id IN  NUMBER,
                p_cash_receipt_id IN  NUMBER,
                p_amount_applied  IN  NUMBER,
                p_init_msg_list   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                x_return_status   OUT NOCOPY VARCHAR2,
                x_msg_count       OUT NOCOPY NUMBER,
                x_msg_data        OUT NOCOPY VARCHAR2);

END ARP_DEDUCTION_COVER2;

 

/
