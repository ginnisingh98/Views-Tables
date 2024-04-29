--------------------------------------------------------
--  DDL for Package ARP_DEDUCTION_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DEDUCTION_COVER" AUTHID CURRENT_USER AS
/* $Header: ARXDECVS.pls 120.6 2005/10/30 03:59:33 appldev noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE update_amount_in_dispute
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure calls entity handlers to update the amount_in_dispute
 |      on the given transaction's payment schedule and inserts a note
 |      on the transaction
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_customer_trx_id    IN    Transaction whose dispute amount is changed
 |      p_claim_number       IN    Number of claim
 |      p_amount             IN    Amount of adjustment to dispute amount
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
 | 12-OCT-2001   jbeckett          Created
 |
 *=======================================================================*/
PROCEDURE update_amount_in_dispute(
                p_customer_trx_id IN  NUMBER,
                p_claim_number    IN  VARCHAR2,
                p_amount          IN  NUMBER,
                p_init_msg_list   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                x_return_status   OUT NOCOPY VARCHAR2,
                x_msg_count       OUT NOCOPY NUMBER,
                x_msg_data        OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDURE create_receipt_writeoff
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure calls entity handlers to unapply the claim investigation
 |      application associated with the given claim, then to apply the same to
 |      receipt write off activity
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_claim_id               IN  ID of claim being written off
 |      p_amount                 IN  Amount to be written off
 |      p_init_msg_list          IN  API message stack initialize flag
 |      p_new_claim_id           IN  ID of claim to apply balance to
 |      p_cash_receipt_id        IN  ID of receipt for which claim originally
 |                                   created
 |      p_receivables_trx_id     IN  ID of write off activity
 |      p_ussgl_transaction_code IN  Default value for USSGL trx code flexfield
 |      x_return_status          OUT NOCOPY
 |      x_msg_count              OUT NOCOPY
 |      x_msg_data               OUT NOCOPY
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 12-OCT-2001   jbeckett          Created
 | 04-MAR-2003   jbeckett          Added secondary_application_reference_id,
 |                                 application_ref_num and customer reference
 |                                 Bug 2751910.
 |
 *=======================================================================*/
PROCEDURE create_receipt_writeoff
       (p_claim_id                 IN  NUMBER,
        p_amount                   IN  NUMBER,
        p_new_claim_id             IN  NUMBER DEFAULT NULL,
        p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_cash_receipt_id          IN  NUMBER,
        p_receivables_trx_id       IN  NUMBER,
        p_ussgl_transaction_code   IN  NUMBER DEFAULT NULL,
        p_application_ref_num      IN
                ar_receivable_applications.application_ref_num%TYPE DEFAULT NULL,
        p_secondary_application_ref_id IN
                ar_receivable_applications.secondary_application_ref_id%TYPE DEFAULT NULL,
        p_customer_reference       IN
                ar_receivable_applications.customer_reference%TYPE DEFAULT NULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDURE split_claim_reapplication
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure calls entity handlers to unapply the current application
 |      for a given claim ID and to create a claim investigation
 |      application while bypassing the usual validation on existing claims.
 |      Amount and status are not checked, as in the case of a partial
 |      settlement the requirement is to reapply the balance to the original
 |      claim
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_claim_id               IN  ID of claim
 |      p_amount                 IN  Amount to be applied
 |      p_init_msg_list          IN  API message stack initialize flag
 |      p_cash_receipt_id        IN  ID of receipt for which claim originally
 |                                   created
 |      p_ussgl_transaction_code IN  Default value for USSGL trx code flexfield
 |      x_return_status          OUT NOCOPY
 |      x_msg_count              OUT NOCOPY
 |      x_msg_data               OUT NOCOPY
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 20-MAR-2002   jbeckett          Created
 |
 *=======================================================================*/
PROCEDURE split_claim_reapplication
       (p_claim_id                 IN  NUMBER,
        p_customer_trx_id          IN  NUMBER,
        p_amount                   IN  NUMBER,
        p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_cash_receipt_id          IN  NUMBER,
        p_ussgl_transaction_code   IN  NUMBER DEFAULT NULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC FUNCTION receipt_valid
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This function checks if the passed cash receipt ID is valid
 |      It returns boolean TRUE or FALSE accordingly.
 |      Addition receipt information is passed back if valid.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_cash_receipt_id        IN  ID of cash receipt
 |      x_receipt_number         OUT NOCOPY
 |      x_receipt_date           OUT NOCOPY
 |      x_cr_gl_date             OUT NOCOPY
 |      x_customer_id            OUT NOCOPY
 |      x_currency_code          OUT NOCOPY
 |      x_cr_payment_schedule_id OUT NOCOPY
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 20-MAR-2002   jbeckett          Created
 |
 *=======================================================================*/
FUNCTION receipt_valid
       (p_cash_receipt_id          IN  NUMBER,
        x_receipt_number           OUT NOCOPY VARCHAR2,
        x_receipt_date             OUT NOCOPY DATE,
        x_cr_gl_date               OUT NOCOPY DATE,
        x_customer_id              OUT NOCOPY NUMBER,
	x_currency_code            OUT NOCOPY VARCHAR2,
        x_cr_payment_schedule_id   OUT NOCOPY NUMBER)
RETURN BOOLEAN;

/*========================================================================
 | PUBLIC FUNCTION claim_on_receipt
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This function checks if a current claim investigation application
 |      exists with the passed claim ID
 |      It returns boolean TRUE or FALSE accordingly.
 |      Additional application information is passed back if valid.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_claim_id                IN
 |      p_cash_receipt_id         IN
 |      x_application_id          OUT NOCOPY
 |      x_apply_date              OUT NOCOPY
 |      x_app_gl_date             OUT NOCOPY
 |      x_amount_applied          OUT NOCOPY
 |      x_application_ref_num     OUT NOCOPY
 |      x_application_ref_reason  OUT NOCOPY
 |      x_receivables_trx_id      OUT NOCOPY
 |      x_comments                OUT NOCOPY
 |      x_customer_reference      OUT NOCOPY
 |      x_attribute_rec           OUT NOCOPY
 |      x_global_attribute_rec    OUT NOCOPY
 |	x_claim_applied		  OUT NOCOPY
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 20-MAR-2002   jbeckett          Created
 |
 *=======================================================================*/
FUNCTION claim_on_receipt (
             p_claim_id                IN  NUMBER
           , p_cash_receipt_id         IN  NUMBER
           , p_applied_ps_id           IN  NUMBER
           , x_application_id          OUT NOCOPY NUMBER
           , x_apply_date              OUT NOCOPY DATE
           , x_app_gl_date             OUT NOCOPY DATE
           , x_amount_applied          OUT NOCOPY NUMBER
           , x_trans_to_receipt_rate   OUT NOCOPY NUMBER
           , x_discount_earned         OUT NOCOPY NUMBER
           , x_discount_unearned       OUT NOCOPY NUMBER
           , x_application_ref_num     OUT NOCOPY VARCHAR2
           , x_application_ref_reason  OUT NOCOPY VARCHAR2
	   , x_receivables_trx_id      OUT NOCOPY NUMBER
	   , x_comments                OUT NOCOPY VARCHAR2
	   , x_customer_reference      OUT NOCOPY VARCHAR2
           , x_attribute_rec           OUT NOCOPY AR_Receipt_API_PUB.attribute_rec_type
           , x_global_attribute_rec    OUT NOCOPY AR_Receipt_API_PUB.global_attribute_rec_type
	   , x_claim_applied	       OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*========================================================================
 | PUBLIC FUNCTION claim_valid
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This function checks if the passed claim ID is valid for this receipt
 |      It returns boolean TRUE or FALSE accordingly.
 |      Claim number is passed back if valid.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_claim_id    IN
 |      p_receipt_id  IN
 |      p_curr_code   IN
 |      p_amount      IN
 |      x_claim_num   OUT NOCOPY
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 20-MAR-2002   jbeckett          Created
 |
 *=======================================================================*/
FUNCTION claim_valid (
      p_claim_id    IN  NUMBER,
      p_receipt_id  IN  NUMBER,
      p_curr_code   IN  VARCHAR2,
      p_amount      IN  NUMBER,
      x_claim_num   OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*========================================================================
 | PUBLIC FUNCTION negative_rct_writeoffs_allowed
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This function returns TRUE or FALSE depending on whether
 |      negative receipt writeoffs are allowed. It returns TRUE
 |      post 11.5.10 and FALSE for pre 11.5.10 versions.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 12-JUN-2003   jbeckett          Created
 |
 *=======================================================================*/

FUNCTION negative_rct_writeoffs_allowed
RETURN BOOLEAN;

/*========================================================================
 | PUBLIC PROCEDURE validate_amount_applied
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure checks if the amended amount applied for the invoice
 |	or claim investigation will still leave the receipt positive.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |	p_amount_applied       IN  NUMBER
 |      p_new_amount_applied   IN  NUMBER
 |	p_cash_receipt_id      IN  NUMBER
 |	x_return_status        OUT VARCHAR2
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date         Author          Description of Changes
 | 04-AUG-2004 	jbeckett	bug 3809272 - Created.
 |
 *=======================================================================*/
PROCEDURE validate_amount_applied (
		p_amount_applied       IN  NUMBER,
                p_new_amount_applied   IN  NUMBER,
		p_cash_receipt_id      IN  NUMBER,
                x_return_status        OUT NOCOPY VARCHAR2);

END ARP_DEDUCTION_COVER;

 

/
