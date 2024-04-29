--------------------------------------------------------
--  DDL for Package AR_OM_PREPAY_REFUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_OM_PREPAY_REFUND_PVT" AUTHID CURRENT_USER AS
/* $Header: AROMRFNS.pls 120.2 2005/10/30 03:55:48 appldev noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
    temp_variable1 VARCHAR2(10);

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/
    temp_exception EXCEPTION;


/*========================================================================
 | PUBLIC Procedure refund_prepayment_wrapper
 |
 | DESCRIPTION
 |       This wrapper is same as ar_prepayments except this accepts 1 additional parameter
 |       p_bank_account_id  : This paramter along with p_receipt_method_id
 |       if having a value populate the global  variables in
 |       AR_PREPAYMENTS.Refund_Prepayment
 |      ------------------------------------------------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
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
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 14-AUG-2003           Jyoti Pandey   Created
 |
 *=======================================================================*/
 PROCEDURE Refund_Prepayment_Wrapper(
    -- Standard API parameters.
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_prepay_application_id      OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_number_of_refund_receipts  OUT NOCOPY NUMBER,
    -------Multiple prepayments projecti Additional parameter for credit card
    -------refunds to be populated as global variables
      p_bank_account_id   IN NUMBER,
      p_receipt_method_id IN NUMBER,

      p_receipt_number             IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_cash_receipt_id            IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receivable_application_id  IN  ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL,
      p_receivables_trx_id         IN ar_receivable_applications.receivables_trx_id%TYPE DEFAULT NULL,
      p_refund_amount              IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_refund_date                IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_refund_gl_date             IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code     IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_attribute_rec              IN ar_receipt_api_pub.attribute_rec_type
                                      DEFAULT ar_receipt_api_pub.attribute_rec_const,
    -- ******* Global Flexfield parameters *******
      p_global_attribute_rec       IN ar_receipt_api_pub.global_attribute_rec_type
                                      DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments                   IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
      p_payment_set_id             IN NUMBER DEFAULT NULL
    ) ;


END AR_OM_PREPAY_REFUND_PVT;

 

/
