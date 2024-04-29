--------------------------------------------------------
--  DDL for Package Body ARP_DEDUCTION_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DEDUCTION_COVER" AS
/* $Header: ARXDECVB.pls 120.26.12010000.3 2008/10/20 13:25:38 spdixit ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
  G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ARP_DEDUCTION_COVER';


/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/


/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/

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
 |      p_init_msg_list      IN    API message stack initialize flag
 |      x_return_status      OUT NOCOPY
 |      x_msg_count          OUT NOCOPY
 |      x_msg_data           OUT NOCOPY
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 12-OCT-2001   jbeckett          Created
 |
 *=======================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE update_amount_in_dispute(
                p_customer_trx_id IN  NUMBER,
                p_claim_number    IN  VARCHAR2,
                p_amount          IN  NUMBER,
                p_init_msg_list   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                x_return_status   OUT NOCOPY VARCHAR2,
                x_msg_count       OUT NOCOPY NUMBER,
                x_msg_data        OUT NOCOPY VARCHAR2)
IS

   l_ps_rec                     ar_payment_schedules%ROWTYPE;
   l_payment_schedule_id        NUMBER;
   l_amount_in_dispute          NUMBER;
   l_amount_in_dispute_new      NUMBER;
   l_note_text                  VARCHAR2(2000);
   l_note_id                    NUMBER;
   l_error_count                NUMBER := 0;
   l_api_name                   CONSTANT VARCHAR2(30)
                                            := 'update_amount_in_dispute';
   l_claim_id                   NUMBER;
   l_active_claim_flag          ar_payment_schedules.active_claim_flag%TYPE;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_DEDUCTION_COVER.update_amount_in_dispute()+');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT	Update_amount_In_Dispute;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_amount_in_dispute: ' || ' p_customer_trx_id :' || p_customer_trx_id);
       arp_standard.debug('update_amount_in_dispute: ' || ' p_claim_number :' || p_claim_number);
       arp_standard.debug('update_amount_in_dispute: ' || ' p_amount :' || p_amount);
    END IF;
 /*---------------------------------------------------------------------+
  | 1) Retrieve the invoice payment schedule id from the application    |
  +---------------------------------------------------------------------*/

    BEGIN
      SELECT applied_payment_schedule_id
           , secondary_application_ref_id
      INTO   l_payment_schedule_id
           , l_claim_id
      FROM   ar_receivable_applications
      WHERE  applied_customer_trx_id = p_customer_trx_id
      AND    application_ref_num = p_claim_number
      AND    application_ref_type = 'CLAIM'
      AND    display = 'Y'
      AND    ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR','ARTA_PAYMENT_SCHEDULE_NO_FOUND');
        FND_MSG_PUB.Add;
        l_error_count := l_error_count + 1;
    END;

 /*---------------------------------------------------------------------+
  | 2) Update payment schedule record                      |
  +---------------------------------------------------------------------*/

    IF (l_payment_schedule_id > 0) THEN
       IF (ARPT_SQL_FUNC_UTIL.get_claim_amount(l_claim_id) = 0) THEN
         l_active_claim_flag := 'N';
       ELSE
         l_active_claim_flag := 'Y';
       END IF;
    END IF;

   IF l_error_count > 0
   THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSE
     arp_ps_pkg.set_to_dummy(p_ps_rec => l_ps_rec);
     SELECT amount_in_dispute
     INTO   l_amount_in_dispute
     FROM   ar_payment_schedules
     WHERE  payment_schedule_id = l_payment_schedule_id;

     l_ps_rec.payment_schedule_id := l_payment_schedule_id;
     l_amount_in_dispute_new := l_amount_in_dispute + p_amount;
     l_ps_rec.amount_in_dispute := l_amount_in_dispute_new;
     l_ps_rec.dispute_date := SYSDATE;
     l_ps_rec.active_claim_flag := l_active_claim_flag;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('update_amount_in_dispute: ' || 'New amount in dispute = '||l_ps_rec.amount_in_dispute);
        arp_standard.debug('update_amount_in_dispute: ' || 'New dispute date = '||l_ps_rec.dispute_date);
     END IF;

     arp_ps_pkg.update_p
       (p_ps_rec => l_ps_rec,
        p_ps_id  => l_payment_schedule_id);

   /*---------------------------------------------------------------------+
    | 2) Enter a note on the transaction                                  |
    +---------------------------------------------------------------------*/
     FND_MESSAGE.set_name('AR','AR_RW_TRX_CLAIM_SETTLE_NOTE');
     FND_MESSAGE.set_token('CLAIM_NUM',p_claim_number);
     FND_MESSAGE.set_token('AMOUNT',p_amount);
     l_note_text := FND_MESSAGE.get;

     arp_cmreq_wf.InsertTrxNotes
                 (x_customer_call_id          =>  NULL,
                  x_customer_call_topic_id    =>  NULL,
                  x_action_id                 =>  NULL,
                  x_customer_trx_id           =>  p_customer_trx_id,
                  x_note_type                 =>  'MAINTAIN',
                  x_text                      =>  l_note_text,
                  x_note_id                   =>  l_note_id);
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_DEDUCTION_COVER.update_amount_in_dispute()-');
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_Amount_In_Dispute;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('update_amount_in_dispute: ' || 'Unexpected error '||sqlerrm||
                ' at arp_deduction_cover.update_amount_in_dispute()+');
                END IF;
                ROLLBACK TO Update_Amount_In_Dispute;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('update_amount_in_dispute: ' || '20001 error '||
                    ' at arp_deduction_cover.update_amount_in_dispute()+');
                  END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR ;
               ELSE
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('update_amount_in_dispute: ' || 'Unexpected error '||sqlerrm||
                   ' at arp_deduction_cover.update_amount_in_dispute()+');
                 END IF;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                 IF    FND_MSG_PUB.Check_Msg_Level
                       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                 THEN
                       FND_MSG_PUB.Add_Exc_Msg
                       (       G_PKG_NAME          ,
                               l_api_name
                       );
                 END IF;
               END IF;
               ROLLBACK TO Update_Amount_In_Dispute;
               FND_MSG_PUB.Count_And_Get
                          (p_encoded => FND_API.G_FALSE,
                           p_count   => x_msg_count,
                           p_data    => x_msg_data);

END update_amount_in_dispute;

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
 |      p_new_claim_id           IN  ID of claim to apply balance to
 |      p_init_msg_list          IN  API message stack initialize flag
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
 | 09-MAY-2002   jbeckett          Bug 2353144 - Replaced calls to entity
 |                                 handlers with calls to receipt API
 | 08-OCT-2002   jbeckett          Bug 2615618 - GL date defaulted according to
 |                                 profile option AR_APPLICATION_GL_DATE_DEFAULT
 |                                 and apply_date allowed to default instead of
 |                                 using receipt date and original apply date.
 | 04-MAR-2003   jbeckett          Added secondary_application_reference_id,
 |                                 application_ref_num and customer reference
 |                                 Bug 2751910.
 *=======================================================================*/
PROCEDURE create_receipt_writeoff
       (p_claim_id                 IN  NUMBER,
        p_amount                   IN  NUMBER,
        p_new_claim_id             IN  NUMBER,
        p_init_msg_list            IN  VARCHAR2,
        p_cash_receipt_id          IN  NUMBER,
        p_receivables_trx_id       IN  NUMBER,
        p_ussgl_transaction_code   IN  NUMBER,
        p_application_ref_num      IN
                ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN
                ar_receivable_applications.secondary_application_ref_id%TYPE,
        p_customer_reference       IN
                ar_receivable_applications.customer_reference%TYPE,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2)
IS

   l_set_of_books_id               NUMBER;
   l_application_id                NUMBER;
   l_apply_date                    DATE;
   l_app_gl_date                   DATE;
   l_amount                        NUMBER;
   l_bal_due_remaining             NUMBER;
   l_receivable_application_id     NUMBER;
   l_application_ref_id            NUMBER := NULL;
   l_application_ref_num           ar_receivable_applications.application_ref_num%TYPE := NULL;
   l_secondary_application_ref_id  ar_receivable_applications.secondary_application_ref_id%TYPE := NULL;
   l_application_ref_reason        ar_receivable_applications.application_ref_reason%TYPE;
   l_dum_app_ref_type              ar_receivable_applications.application_ref_type%TYPE;
   l_dum_app_ref_id                NUMBER;
   l_dum_app_ref_num               ar_receivable_applications.application_ref_num%TYPE;
   l_dum_sec_app_ref_id            NUMBER;
   l_payment_set_id                NUMBER;
   l_claim_receivables_trx_id      NUMBER;
   l_comments                      ar_receivable_applications.comments%TYPE;
   l_customer_reference            ar_receivable_applications.customer_reference%TYPE;
   l_attribute_rec                 AR_Receipt_API_PUB.attribute_rec_type;
   l_global_attribute_rec          AR_Receipt_API_PUB.global_attribute_rec_type;
   l_balance                       NUMBER := 0;
   l_receipt_number                ar_cash_receipts.receipt_number%TYPE;
   l_receipt_date                  DATE;
   l_currency_code                 ar_cash_receipts.currency_code%TYPE;
   l_trx_currency_code             ar_payment_schedules.invoice_currency_code%TYPE;
   l_cr_gl_date                    DATE;
   l_cr_payment_schedule_id        NUMBER;
   l_customer_id                   NUMBER;
   l_default_gl_date               DATE;
   l_defaulting_rule_used          VARCHAR2(50);
   l_new_application_id            NUMBER;
   l_receivables_trx_id            NUMBER;
   l_trans_to_receipt_rate         NUMBER;
   l_discount_earned               NUMBER;
   l_discount_unearned             NUMBER;
   l_new_claim_num                 ar_receivable_applications.application_ref_num%TYPE;
   l_return_status                 VARCHAR2(1);
   l_api_name                      CONSTANT VARCHAR2(30)
                                            := 'create_receipt_writeoff';
   l_error_message                 VARCHAR2(2000);
   l_error_count                   NUMBER := 0;
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000);
   l_new_claim_id                  NUMBER;
   l_app_gl_date_prof              VARCHAR2(240); -- bug 2615618
   l_gl_date                       DATE;          -- bug 2615618
   l_claim_applied                 VARCHAR2(1);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.create_receipt_writeoff()+');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT	Create_Receipt_Writeoff;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Bug 3022077 - initialize global variables */
  arp_global.init_global;
  arp_standard.init_standard;

 /*---------------------------------------------------------------------+
  | 1) Check that a valid writeoff activity has been passed             |
  +---------------------------------------------------------------------*/
  IF (p_receivables_trx_id IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('AR','AR_WR_INVALID_ACTIVITY_ID');
    FND_MSG_PUB.Add;
    l_error_count := l_error_count + 1;
  ELSE
    BEGIN
      SELECT receivables_trx_id
      INTO   l_receivables_trx_id
      FROM   ar_receivables_trx
      WHERE  receivables_trx_id = p_receivables_trx_id
      AND    NVL(status,'A') = 'A'
      AND    TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE))
                                AND NVL(end_date_active,trunc(SYSDATE))
      AND    type = 'WRITEOFF';
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        FND_MESSAGE.SET_NAME('AR','AR_WR_INVALID_ACTIVITY_ID');
        FND_MSG_PUB.Add;
        l_error_count := l_error_count + 1;
    END;
  END IF;

 /*---------------------------------------------------------------------+
  | 2) Check that a valid receipt has been passed                       |
  +---------------------------------------------------------------------*/
  IF NOT receipt_valid
       (p_cash_receipt_id          =>  p_cash_receipt_id,
        x_receipt_number           =>  l_receipt_number,
        x_receipt_date             =>  l_receipt_date,
        x_cr_gl_date               =>  l_cr_gl_date,
        x_customer_id              =>  l_customer_id,
	x_currency_code            =>  l_currency_code,
        x_cr_payment_schedule_id   =>  l_cr_payment_schedule_id)
  THEN
    l_error_count := l_error_count + 1;
  END IF;

 /*---------------------------------------------------------------------+
  | 3) Check that a valid claim has been passed                         |
  +---------------------------------------------------------------------*/
  IF NOT claim_on_receipt (
             p_claim_id                =>  p_claim_id
           , p_cash_receipt_id         =>  p_cash_receipt_id
           , p_applied_ps_id           =>  -4
           , x_application_id          =>  l_application_id
           , x_apply_date              =>  l_apply_date
           , x_app_gl_date             =>  l_app_gl_date
           , x_amount_applied          =>  l_amount
           , x_trans_to_receipt_rate   =>  l_trans_to_receipt_rate
           , x_discount_earned         =>  l_discount_earned
           , x_discount_unearned       =>  l_discount_unearned
           , x_application_ref_num     =>  l_dum_app_ref_num
           , x_application_ref_reason  =>  l_application_ref_reason
	   , x_receivables_trx_id      =>  l_claim_receivables_trx_id
	   , x_comments                =>  l_comments
	   , x_customer_reference      =>  l_customer_reference
           , x_attribute_rec           =>  l_attribute_rec
           , x_global_attribute_rec    =>  l_global_attribute_rec
	   , x_claim_applied	       =>  l_claim_applied)
  THEN
     l_error_count := l_error_count + 1;
  END IF;

 /*---------------------------------------------------------------------+
  | 4) Check that a valid new claim has been passed if partial writeoff |
  +---------------------------------------------------------------------*/
  IF (l_amount <> p_amount)
  THEN
    l_balance := (l_amount - p_amount);
    IF p_new_claim_id IS NULL
    THEN
      FND_MESSAGE.set_name('AR','AR_RWAPP_NEW_CLAIM_ID_NULL');
      FND_MSG_PUB.Add;
      l_error_count := l_error_count + 1;
    ELSE
      IF NOT claim_valid(
            p_claim_id => p_new_claim_id,
	    p_receipt_id => p_cash_receipt_id,
	    p_curr_code => l_currency_code,
            p_amount   => l_balance,
            x_claim_num  => l_new_claim_num)
      THEN
        l_error_count := l_error_count + 1;
      END IF;
    END IF;
  END IF;

 /*---------------------------------------------------------------------+
  | 5) Validate and default the GL date (bug 2615618)
  +---------------------------------------------------------------------*/
  l_gl_date := NULL;
  l_app_gl_date_prof :=
     NVL(fnd_profile.value('AR_APPLICATION_GL_DATE_DEFAULT'),'INV_REC_DT');
  IF (l_app_gl_date_prof = 'INV_REC_DT') THEN
    IF l_cr_gl_date >  l_app_gl_date THEN
      l_gl_date := l_cr_gl_date;
    END IF;
  ELSIF (l_app_gl_date_prof = 'INV_REC_SYS_DT') THEN
    IF l_cr_gl_date > SYSDATE THEN
      l_gl_date := l_cr_gl_date;
    ELSE
      l_gl_date := SYSDATE;
    END IF;
  END IF;
  IF (arp_util.validate_and_default_gl_date(
                l_gl_date,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                NULL,
		l_set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE)
  THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
    FND_MSG_PUB.Add;
    l_error_count := l_error_count + 1;
  END IF;

 /*---------------------------------------------------------------------+
  | 6) Raise error if validation errors found                           |
  +---------------------------------------------------------------------*/
  IF (l_error_count > 0)
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 /*---------------------------------------------------------------------+
  | 7) Unapply the claim investigation application                      |
  +---------------------------------------------------------------------*/
  /* Bug 2821139 - under no circumstances should AR update claims when
     they are settled from TM */

  IF l_claim_applied = 'Y' THEN
    AR_Receipt_API_PUB.unapply_other_account    (
      p_api_version                  =>  1.0,
      p_init_msg_list                =>  FND_API.G_FALSE,
      x_return_status                =>  l_return_status,
      x_msg_count                    =>  l_msg_count,
      x_msg_data                     =>  l_msg_data,
      p_receivable_application_id    =>  l_application_id,
      p_cash_receipt_id              =>  p_cash_receipt_id,
      p_cancel_claim_flag            => 'N',
      p_called_from		     =>  'TRADE_MANAGEMENT');
  END IF;

 /*---------------------------------------------------------------------+
  | 8) Apply any remaining balance to new claim                         |
  +---------------------------------------------------------------------*/
  IF l_balance <> 0
  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_receipt_writeoff: ' || 'Before Inserting Claim Application (+)');
    END IF;
    l_new_claim_id := p_new_claim_id;
  /* Bug 2821139 - under no circumstances should AR update claims when
     they are settled from TM */

    ar_receipt_api_pub.apply_other_account    (
      p_api_version                  =>  1.0,
      p_init_msg_list                =>  FND_API.G_FALSE,
      x_return_status                =>  l_return_status,
      x_msg_count                    =>  l_msg_count,
      x_msg_data                     =>  l_msg_data,
      p_receivable_application_id    =>  l_receivable_application_id,
      p_cash_receipt_id              =>  p_cash_receipt_id,
      p_amount_applied               =>  l_balance,
      p_receivables_trx_id           =>  l_claim_receivables_trx_id,
      p_apply_date		     =>  l_apply_date,
      p_apply_gl_date	             =>  l_default_gl_date,  -- bug 2615618
      p_applied_payment_schedule_id  =>  -4,
      p_ussgl_transaction_code       =>  p_ussgl_transaction_code,
      p_application_ref_type         =>  'CLAIM',
      p_application_ref_id           =>  l_application_ref_id,
      p_application_ref_num          =>  l_new_claim_num,
      p_secondary_application_ref_id =>  l_new_claim_id,
      p_attribute_rec                =>  l_attribute_rec,
      p_global_attribute_rec         =>  l_global_attribute_rec,
      p_comments                     =>  l_comments,
      p_application_ref_reason       =>  l_application_ref_reason,
      p_customer_reference           =>  l_customer_reference,
      p_called_from		     =>  'TRADE_MANAGEMENT');

    IF l_return_status = 'E'
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = 'U'
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_receipt_writeoff: ' || 'After Inserting Claim Application (-)');
    END IF;
  END IF;

 /*---------------------------------------------------------------------+
  | 9) Apply to writeoff application using Receipt API                  |
  +---------------------------------------------------------------------*/

  l_application_ref_num := p_application_ref_num;
  l_secondary_application_ref_id := p_secondary_application_ref_id;

  AR_Receipt_API_PUB.Activity_Application (
      p_api_version                  =>  1.0,
      x_return_status                =>  l_return_status,
      x_msg_count                    =>  l_msg_count,
      x_msg_data                     =>  l_msg_data,
      p_cash_receipt_id              =>  p_cash_receipt_id,
      p_amount_applied               =>  p_amount,
      p_applied_payment_schedule_id  =>  -3,
      p_receivables_trx_id           =>  l_receivables_trx_id,
      p_apply_date                   =>  NULL, -- bug 2615618
      p_apply_gl_date                =>  l_default_gl_date,  -- bug 2615618
      p_ussgl_transaction_code       =>  p_ussgl_transaction_code,
      p_attribute_rec                =>  l_attribute_rec,
      p_global_attribute_rec         =>  l_global_attribute_rec,
      p_application_ref_type         =>  l_dum_app_ref_type,
      p_application_ref_id           =>  l_dum_app_ref_id,
      p_application_ref_num          =>  l_application_ref_num,
      p_secondary_application_ref_id =>  l_secondary_application_ref_id,
      p_receivable_application_id    =>  l_new_application_id,
      p_customer_reference           =>  p_customer_reference,
      p_val_writeoff_limits_flag     => 'N'
      );

  IF l_return_status = 'E'
  THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = 'U'
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.create_receipt_writeoff()-');
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Create_Receipt_Writeoff;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('create_receipt_writeoff: ' || 'Unexpected error '||sqlerrm||
                ' at arp_deduction_cover.create_receipt_writeoff()+');
                END IF;
                ROLLBACK TO Create_Receipt_Writeoff;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('create_receipt_writeoff: ' || '20001 error '||
                    ' at arp_deduction_cover.create_receipt_writeoff()+');
                  END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR ;
               ELSE
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('create_receipt_writeoff: ' || 'Unexpected error '||sqlerrm||
                   ' at arp_deduction_cover.create_receipt_writeoff()+');
                 END IF;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                 IF    FND_MSG_PUB.Check_Msg_Level
                       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                 THEN
                       FND_MSG_PUB.Add_Exc_Msg
                       (       G_PKG_NAME          ,
                               l_api_name
                       );
                 END IF;
               END IF;
               ROLLBACK TO Create_Receipt_Writeoff;
               FND_MSG_PUB.Count_And_Get
                          (p_encoded => FND_API.G_FALSE,
                           p_count   => x_msg_count,
                           p_data    => x_msg_data);
END create_receipt_writeoff;

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
 |      p_customer_trx_id        IN  Invoice ID (if invoice related)
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
 | 08-APR-2002   jbeckett          Bug 2279399 - split_claim_reapplication
 |                                 should not reapply an amount of zero.
 | 09-MAY-2002   jbeckett          Bug 2353144 - Replaced calls to entity
 |                                 handlers with calls to receipt API
 | 20-MAY-2002   jbeckett          Bug 2381009 - amended to process installments
 |                                 correctly.
 | 30-AUG-2002   jbeckett          Bug 2535663 - pass sum of earned and unearned
 |                                 discounts to ar_receipt_api_pub.apply.
 | 12-SEP-2002   S.Nambiar         Bug 2560486 - split_claim_reapplication should
 |                                 not pass apply date or apply gl date. Let it default
 |                                 based on the profile option.
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
        x_msg_data                 OUT NOCOPY VARCHAR2)
IS
   l_set_of_books_id               NUMBER;
   l_application_id                NUMBER;
   l_applied_ps_id                 NUMBER;
   l_apply_date                    DATE;
   l_app_gl_date                   DATE;
   l_amount                        NUMBER;
   l_bal_due_remaining             NUMBER;
   l_application_ref_id            NUMBER := NULL;
   l_application_ref_num           ar_receivable_applications.application_ref_num%TYPE := NULL;
   l_application_ref_reason        ar_receivable_applications.application_ref_reason%TYPE;
   l_dum_app_ref_type              ar_receivable_applications.application_ref_type%TYPE;
   l_dum_app_ref_id                NUMBER;
   l_dum_app_ref_num               ar_receivable_applications.application_ref_num%TYPE;
   l_dum_sec_app_ref_id            NUMBER;
   l_payment_set_id                NUMBER;
   l_claim_receivables_trx_id      NUMBER;
   l_comments                      ar_receivable_applications.comments%TYPE;
   l_customer_reference            ar_receivable_applications.customer_reference%TYPE;
   l_attribute_rec                 AR_Receipt_API_PUB.attribute_rec_type;
   l_global_attribute_rec          AR_Receipt_API_PUB.global_attribute_rec_type;
   l_balance                       NUMBER := 0;
   l_receipt_number                ar_cash_receipts.receipt_number%TYPE;
   l_receipt_date                  DATE;
   l_currency_code                 ar_cash_receipts.currency_code%TYPE;
   l_trx_currency_code             ar_payment_schedules.invoice_currency_code%TYPE;
   l_installment                   ar_payment_schedules.terms_sequence_number%TYPE;
   l_cr_gl_date                    DATE;
   l_cr_payment_schedule_id        NUMBER;
   l_customer_id                   NUMBER;
   l_default_gl_date               DATE;
   l_defaulting_rule_used          VARCHAR2(50);
   l_new_application_id            NUMBER;
   l_receivable_application_id     NUMBER;
   l_receivables_trx_id            NUMBER;
   l_trans_to_receipt_rate         NUMBER;
   l_discount                      NUMBER;  -- Bug 2535663
   l_discount_earned               NUMBER;
   l_discount_unearned             NUMBER;
   l_applied_amount_from           NUMBER;
   l_applied_amt_from_old          NUMBER; /* Bug fix 5291088*/
   l_new_claim_num                 ar_receivable_applications.application_ref_num%TYPE;
   l_return_status                 VARCHAR2(1);
   l_amount_status                 VARCHAR2(1); -- Bug 3809272
   l_api_name                      CONSTANT VARCHAR2(30)
                                            := 'split_claim_reapplication';
   l_error_message                 VARCHAR2(2000);
   l_error_count                   NUMBER := 0;
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000);
   l_claim_id                      NUMBER;
   l_claim_applied                 VARCHAR2(1);

   /* Bug 7479983: Cursor is used to identify the applications associated to the claim on the receipt */

   CURSOR get_app_ids(p_cash_rcpt_id in  NUMBER, p_ctx_id in NUMBER) IS
	select receivable_application_id from ar_receivable_applications_all
               	where cash_receipt_id = p_cash_rcpt_id
                and applied_customer_trx_id = p_ctx_id
                and status = 'APP'
		and reversal_gl_date IS NULL
        order by amount_applied desc;

   CURSOR applied_amount( cv_cash_receipt_id  IN NUMBER
                        , cv_customer_trx_id  IN NUMBER
                        , cv_claim_id    IN NUMBER ) IS
    SELECT sum(rec.amount_applied) amt_applied,
	   sum(rec.earned_discount_taken) earned_discount_taken,
	   sum(rec.unearned_discount_taken) unearned_discount_taken
    FROM ar_receivable_applications rec
    ,    ar_payment_schedules pay
    WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
    AND rec.cash_receipt_id = cv_cash_receipt_id
    AND pay.customer_trx_id = cv_customer_trx_id
    AND rec.application_ref_type = 'CLAIM'
    AND rec.display = 'Y'
    AND rec.secondary_application_ref_id = cv_claim_id;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.split_claim_reapplication()+');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT	split_claim_reapplication;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Bug 3022077 - initialize global variables */
  arp_global.init_global;
  arp_standard.init_standard;

 /*---------------------------------------------------------------------+
  | 1) Check that a valid receipt has been passed                       |
  +---------------------------------------------------------------------*/
  IF NOT receipt_valid
       (p_cash_receipt_id          =>  p_cash_receipt_id,
        x_receipt_number           =>  l_receipt_number,
        x_receipt_date             =>  l_receipt_date,
        x_cr_gl_date               =>  l_cr_gl_date,
        x_customer_id              =>  l_customer_id,
	x_currency_code            =>  l_currency_code,
        x_cr_payment_schedule_id   =>  l_cr_payment_schedule_id)
  THEN
    l_error_count := l_error_count + 1;
  END IF;

 /*---------------------------------------------------------------------+
  | 2) Check that a valid claim has been passed                         |
  +---------------------------------------------------------------------*/
  BEGIN
    IF p_customer_trx_id IS NOT NULL
    THEN
      /* Bug 2381009 - allow for more than 1 payment schedule on invoice */
      SELECT ps.payment_schedule_id
           , ps.invoice_currency_code
           , ps.terms_sequence_number
      INTO   l_applied_ps_id
           , l_trx_currency_code
           , l_installment
      FROM   ar_payment_schedules ps,
             ar_receivable_applications ra
      WHERE  ps.payment_schedule_id = ra.applied_payment_schedule_id
      AND    ra.application_ref_type = 'CLAIM'
      AND    ra.secondary_application_ref_id = p_claim_id
      AND    ra.cash_receipt_id =  p_cash_receipt_id
      AND    ra.status = 'APP'
      AND    ps.customer_trx_id = p_customer_trx_id
      AND    ROWNUM = 1;
    ELSE
      l_applied_ps_id := -4;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR','ARTA_PAYMENT_SCHEDULE_NO_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END;
  IF NOT claim_on_receipt (
             p_claim_id                =>  p_claim_id
           , p_cash_receipt_id         =>  p_cash_receipt_id
           , p_applied_ps_id           =>  l_applied_ps_id
           , x_application_id          =>  l_application_id
           , x_apply_date              =>  l_apply_date
           , x_app_gl_date             =>  l_app_gl_date
           , x_amount_applied          =>  l_amount
           , x_trans_to_receipt_rate   =>  l_trans_to_receipt_rate
           , x_discount_earned         =>  l_discount_earned
           , x_discount_unearned       =>  l_discount_unearned
           , x_application_ref_num     =>  l_application_ref_num
           , x_application_ref_reason  =>  l_application_ref_reason
	   , x_receivables_trx_id      =>  l_claim_receivables_trx_id
	   , x_comments                =>  l_comments
	   , x_customer_reference      =>  l_customer_reference
           , x_attribute_rec           =>  l_attribute_rec
           , x_global_attribute_rec    =>  l_global_attribute_rec
	   , x_claim_applied	       =>  l_claim_applied)
  THEN
     l_error_count := l_error_count + 1;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('p_cash_receipt_id: ' || p_cash_receipt_id);
     arp_standard.debug('p_customer_trx_id: ' || p_customer_trx_id);
     arp_standard.debug('p_claim_id: ' || p_claim_id);
  END IF;

  OPEN applied_amount( p_cash_receipt_id, p_customer_trx_id, p_claim_id );
  FETCH applied_amount INTO l_amount, l_discount_earned, l_discount_unearned;
  CLOSE applied_amount;

  l_applied_amount_from := p_amount * l_trans_to_receipt_rate;
  l_applied_amt_from_old:= arpcurr.currround(l_amount * nvl(l_trans_to_receipt_rate,1),l_currency_code) ; /* Bug fix 5291088 */
  l_discount := nvl(l_discount_earned,0) + nvl(l_discount_unearned,0); -- Bug 2535663

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('l_applied_amount_from: ' || l_applied_amount_from);
     arp_standard.debug('l_applied_amt_from_old: ' || l_applied_amt_from_old);
     arp_standard.debug('l_discount_earned: ' || l_discount_earned);
     arp_standard.debug('l_discount_unearned: ' || l_discount_unearned);
  END IF;
 -- Bug 3809272
 /*---------------------------------------------------------------------+
  | 2b) Check that the receipt will not go negative
  +---------------------------------------------------------------------*/
  /* Bug fix 5291088 : The amounts that should be compared to be passed in receipt currency */
  validate_amount_applied(	p_amount_applied       =>  l_applied_amt_from_old,
                		p_new_amount_applied   =>  nvl(arpcurr.currround(l_applied_amount_from,l_currency_code),p_amount),
				p_cash_receipt_id      =>  p_cash_receipt_id,
                		x_return_status        => l_amount_status);
  IF l_amount_status <> FND_API.G_RET_STS_SUCCESS THEN
     l_error_count := l_error_count + 1;
  END IF;

 /*---------------------------------------------------------------------+
  | 3) Raise error if validation errors found                           |
  +---------------------------------------------------------------------*/
  IF (l_error_count > 0)
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 /*---------------------------------------------------------------------+
  | 4) Unapply the application                                          |
  +---------------------------------------------------------------------*/
  /* Bug 2384340 - to prevent adjustments and chargebacks being reversed the
     associated_cash_receipt_id on these records temporarily has its sign
     switched */
  IF (p_amount <> 0 AND l_claim_applied = 'Y')
  THEN
    UPDATE ar_adjustments
    SET    associated_cash_receipt_id = associated_cash_receipt_id * -1
    WHERE  associated_cash_receipt_id = p_cash_receipt_id
    AND    payment_schedule_id = l_applied_ps_id;
  END IF;

  IF (arp_util.validate_and_default_gl_date(
                l_app_gl_date,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                NULL,
		l_set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE)
  THEN
    NULL;
  END IF;

  /* Bug 2821139 - under no circumstances should AR update claims when
     they are settled from TM */

  IF l_claim_applied = 'Y' THEN
    IF p_customer_trx_id IS NOT NULL
    THEN
      FOR rec_app_id IN get_app_ids(p_cash_receipt_id, p_customer_trx_id) LOOP
      	AR_Receipt_API_PUB.Unapply(
      		p_api_version                  =>  1.0,
      		p_init_msg_list                =>  FND_API.G_FALSE,
      		x_return_status                =>  l_return_status,
      		x_msg_count                    =>  l_msg_count,
      		x_msg_data                     =>  l_msg_data,
      		p_called_from	      	       =>  'TRADE_MANAGEMENT',
      		p_cancel_claim_flag            =>  'N',
		p_receivable_application_id    =>  rec_app_id.receivable_application_id);
      END LOOP;
    ELSE
      AR_Receipt_API_PUB.unapply_other_account    (
      p_api_version                  =>  1.0,
      p_init_msg_list                =>  FND_API.G_FALSE,
      x_return_status                =>  l_return_status,
      x_msg_count                    =>  l_msg_count,
      x_msg_data                     =>  l_msg_data,
      p_receivable_application_id    =>  l_application_id,
      p_cash_receipt_id              =>  p_cash_receipt_id,
      p_cancel_claim_flag            => 'N',
      p_called_from		     => 'TRADE_MANAGEMENT');
    END IF;
  END IF;

  IF l_return_status = 'E'
  THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = 'U'
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Bug 2384340 - reinstating adjustments and chargebacks associated with
     this receipt/payment schedule */
  IF p_amount <> 0
  THEN
    UPDATE ar_adjustments
    SET    associated_cash_receipt_id = associated_cash_receipt_id * -1
    WHERE  associated_cash_receipt_id = p_cash_receipt_id * -1
    AND    payment_schedule_id = l_applied_ps_id;
  END IF;
 /*---------------------------------------------------------------------+
  | 5) Apply new amount using original claim                            |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('split_claim_reapplication: ' || 'Before Inserting Claim Application (+)');
  END IF;
  /* Bug 2279399 - do not apply if amount is zero */
  IF p_amount <> 0
  THEN
    /* Bug 2821139 - under no circumstances should AR update claims when
       they are settled from TM */
    l_claim_id := p_claim_id;
    IF p_customer_trx_id IS NOT NULL
    THEN
      ar_receipt_api_pub.apply     (
      p_api_version                  =>  1.0,
      p_init_msg_list                =>  FND_API.G_FALSE,
      x_return_status                =>  l_return_status,
      x_msg_count                    =>  l_msg_count,
      x_msg_data                     =>  l_msg_data,
      p_cash_receipt_id              =>  p_cash_receipt_id,
      p_customer_trx_id              =>  p_customer_trx_id,
      p_installment                  =>  l_installment,
      p_amount_applied               =>  p_amount,
      p_amount_applied_from          =>  l_applied_amount_from,
      p_trans_to_receipt_rate        =>  l_trans_to_receipt_rate ,
      p_discount                     =>  l_discount, -- Bug 2535663
      p_apply_date                   =>  l_apply_date, -- Bug 2783541
      p_apply_gl_date                =>  NULL,--Bug 2560486
      p_called_from		     =>  'TRADE_MANAGEMENT',
      p_attribute_rec                =>  l_attribute_rec,
      p_global_attribute_rec         =>  l_global_attribute_rec,
      p_comments                     =>  l_comments,
      p_application_ref_type         =>  'CLAIM',
      p_application_ref_num          =>  l_application_ref_num,
      p_secondary_application_ref_id =>  l_claim_id,
      p_application_ref_reason       =>  l_application_ref_reason,
      p_customer_reference           =>  l_customer_reference);
    ELSE
      ar_receipt_api_pub.apply_other_account    (
      p_api_version                  =>  1.0,
      p_init_msg_list                =>  FND_API.G_FALSE,
      x_return_status                =>  l_return_status,
      x_msg_count                    =>  l_msg_count,
      x_msg_data                     =>  l_msg_data,
      p_receivable_application_id    =>  l_receivable_application_id,
      p_cash_receipt_id              =>  p_cash_receipt_id,
      p_amount_applied               =>  p_amount,
      p_receivables_trx_id           =>  l_claim_receivables_trx_id,
      p_apply_date		     =>  l_apply_date,  --Bug 2783541
      p_apply_gl_date	             =>  NULL,--Bug 2560486
      p_applied_payment_schedule_id  =>  -4,
      p_application_ref_type         =>  'CLAIM',
      p_application_ref_id           =>  l_application_ref_id,
      p_application_ref_num          =>  l_application_ref_num,
      p_secondary_application_ref_id =>  l_claim_id,
      p_attribute_rec                =>  l_attribute_rec,
      p_global_attribute_rec         =>  l_global_attribute_rec,
      p_comments                     =>  l_comments,
      p_application_ref_reason       =>  l_application_ref_reason,
      p_customer_reference           =>  l_customer_reference,
      p_called_from		     =>  'TRADE_MANAGEMENT');
    END IF;

    IF (p_customer_trx_id IS NOT NULL AND
        ARPT_SQL_FUNC_UTIL.get_claim_amount(l_claim_id) = 0)
    THEN
         BEGIN
           UPDATE ar_payment_schedules
           SET    active_claim_flag = 'N'
           WHERE  payment_schedule_id = l_applied_ps_id;
         EXCEPTION
           WHEN others then
           IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('split_claim_reapplication: ' || 'ERROR occured updating payment schedule: '||sqlerrm);
           END IF;

           l_return_status := 'U';
         END;
    END IF;

    IF l_return_status = 'E'
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = 'U'
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('split_claim_reapplication: ' || 'After Inserting Claim Application (-)');
     arp_standard.debug('ARP_DEDUCTION_COVER.split_claim_reapplication()-');
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO split_claim_reapplication;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('split_claim_reapplication: ' || 'Unexpected error '||sqlerrm||
                ' at arp_deduction_cover.split_claim_reapplication()+');
                END IF;
                ROLLBACK TO split_claim_reapplication;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('split_claim_reapplication: ' || '20001 error '||
                    ' at arp_deduction_cover.split_claim_reapplication()+');
                  END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR ;
               ELSE
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('split_claim_reapplication: ' || 'Unexpected error '||sqlerrm||
                   ' at arp_deduction_cover.split_claim_reapplication()+');
                 END IF;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                 IF    FND_MSG_PUB.Check_Msg_Level
                       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                 THEN
                       FND_MSG_PUB.Add_Exc_Msg
                       (       G_PKG_NAME          ,
                               l_api_name
                       );
                 END IF;
               END IF;
               ROLLBACK TO split_claim_reapplication;
               FND_MSG_PUB.Count_And_Get
                          (p_encoded => FND_API.G_FALSE,
                           p_count   => x_msg_count,
                           p_data    => x_msg_data);
END split_claim_reapplication;

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
RETURN BOOLEAN
IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.receipt_valid()+');
  END IF;

  x_receipt_number           := NULL;
  x_receipt_date             := NULL;
  x_cr_gl_date               := NULL;
  x_customer_id              := NULL;
  x_currency_code            := NULL;
  x_cr_payment_schedule_id   := NULL;
  IF (p_cash_receipt_id IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_NULL');
    FND_MSG_PUB.Add;
    RETURN FALSE;
  ELSE
    SELECT   cr.receipt_number
           , cr.receipt_date
           , crh.gl_date
           , cr.pay_from_customer
	   , cr.currency_code
           , ps.payment_schedule_id
      INTO   x_receipt_number
           , x_receipt_date
           , x_cr_gl_date
           , x_customer_id
	   , x_currency_code
           , x_cr_payment_schedule_id
      FROM   ar_cash_receipts cr
           , ar_payment_schedules ps
           , ar_cash_receipt_history crh
      WHERE  cr.cash_receipt_id = crh.cash_receipt_id(+)
      AND    crh.first_posted_record_flag(+) = 'Y'
      AND    cr.cash_receipt_id = ps.cash_receipt_id(+)
      AND    cr.cash_receipt_id = p_cash_receipt_id;
  END IF;
  RETURN TRUE;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.receipt_valid()-');
  END IF;

EXCEPTION
  WHEN OTHERS
      THEN
        FND_MESSAGE.SET_NAME('AR','ARTA_ERR_FINDING_CASH_RCPT');
        FND_MESSAGE.SET_TOKEN('CR_ID',p_cash_receipt_id);
        FND_MSG_PUB.Add;
        RETURN FALSE;
END receipt_valid;

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
 |      p_applied_ps_id           IN
 |      x_application_id          OUT NOCOPY
 |      x_apply_date              OUT NOCOPY
 |      x_app_gl_date             OUT NOCOPY
 |      x_amount_applied          OUT NOCOPY
 |      x_trans_to_receipt_rate   OUT NOCOPY
 |      x_discount_earned         OUT NOCOPY
 |      x_discount_unearned       OUT NOCOPY
 |      x_application_ref_num     OUT NOCOPY
 |      x_application_ref_reason  OUT NOCOPY
 |      x_receivables_trx_id      OUT NOCOPY
 |      x_comments                OUT NOCOPY
 |      x_customer_reference      OUT NOCOPY
 |      x_attribute_rec           OUT NOCOPY
 |      x_global_attribute_rec    OUT NOCOPY
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 20-MAR-2002   jbeckett          Created
 | 15-APR-2002   jbeckett          Check for invoice related claims also
 | 06-AUG-2004   JBECKETT	   Bug 3643551:Disabled use of index on
 |				   applied_ps_id in favour of cash_receipt_id
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
	   , x_claim_applied           OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.claim_on_receipt()+');
  END IF;

  IF (p_claim_id IS NULL)
  THEN
     FND_MESSAGE.SET_NAME('AR','AR_RWAPP_NULL_CLAIM_ID');
     FND_MSG_PUB.Add;
     RETURN FALSE;
  ELSIF (p_cash_receipt_id IS NOT NULL)
  THEN
    BEGIN
    -- Bug 3643661 - prevent index on applied_payment_schedule_id being used
      SELECT
             app.receivable_application_id
           , app.apply_date
           , app.gl_date
           , app.amount_applied
           , app.trans_to_receipt_rate
           , app.earned_discount_taken
           , app.unearned_discount_taken
           , app.application_ref_num
           , app.application_ref_reason
	   , app.receivables_trx_id
	   , app.comments
           , app.customer_reference
           , app.attribute_category
           , app.attribute1
           , app.attribute2
           , app.attribute3
           , app.attribute4
           , app.attribute5
           , app.attribute6
           , app.attribute7
           , app.attribute8
           , app.attribute9
           , app.attribute10
           , app.attribute11
           , app.attribute12
           , app.attribute13
           , app.attribute14
           , app.attribute15
           , app.global_attribute_category
           , app.global_attribute1
           , app.global_attribute2
           , app.global_attribute3
           , app.global_attribute4
           , app.global_attribute5
           , app.global_attribute6
           , app.global_attribute7
           , app.global_attribute8
           , app.global_attribute9
           , app.global_attribute10
           , app.global_attribute11
           , app.global_attribute12
           , app.global_attribute13
           , app.global_attribute14
           , app.global_attribute15
           , app.global_attribute16
           , app.global_attribute17
           , app.global_attribute18
           , app.global_attribute19
           , app.global_attribute20
      INTO
             x_application_id
           , x_apply_date
           , x_app_gl_date
           , x_amount_applied
           , x_trans_to_receipt_rate
           , x_discount_earned
           , x_discount_unearned
           , x_application_ref_num
           , x_application_ref_reason
	   , x_receivables_trx_id
	   , x_comments
	   , x_customer_reference
           , x_attribute_rec.attribute_category
           , x_attribute_rec.attribute1
           , x_attribute_rec.attribute2
           , x_attribute_rec.attribute3
           , x_attribute_rec.attribute4
           , x_attribute_rec.attribute5
           , x_attribute_rec.attribute6
           , x_attribute_rec.attribute7
           , x_attribute_rec.attribute8
           , x_attribute_rec.attribute9
           , x_attribute_rec.attribute10
           , x_attribute_rec.attribute11
           , x_attribute_rec.attribute12
           , x_attribute_rec.attribute13
           , x_attribute_rec.attribute14
           , x_attribute_rec.attribute15
           , x_global_attribute_rec.global_attribute_category
           , x_global_attribute_rec.global_attribute1
           , x_global_attribute_rec.global_attribute2
           , x_global_attribute_rec.global_attribute3
           , x_global_attribute_rec.global_attribute4
           , x_global_attribute_rec.global_attribute5
           , x_global_attribute_rec.global_attribute6
           , x_global_attribute_rec.global_attribute7
           , x_global_attribute_rec.global_attribute8
           , x_global_attribute_rec.global_attribute9
           , x_global_attribute_rec.global_attribute10
           , x_global_attribute_rec.global_attribute11
           , x_global_attribute_rec.global_attribute12
           , x_global_attribute_rec.global_attribute13
           , x_global_attribute_rec.global_attribute14
           , x_global_attribute_rec.global_attribute15
           , x_global_attribute_rec.global_attribute16
           , x_global_attribute_rec.global_attribute17
           , x_global_attribute_rec.global_attribute18
           , x_global_attribute_rec.global_attribute19
           , x_global_attribute_rec.global_attribute20
      FROM   ar_receivable_applications app
      WHERE  app.secondary_application_ref_id = p_claim_id
      AND    app.applied_payment_schedule_id + 0 = p_applied_ps_id
      AND    app.application_ref_type = 'CLAIM'
      AND    app.display = 'Y'
      AND    app.status = DECODE(p_applied_ps_id,-4,'OTHER ACC','APP')
      AND    app.cash_receipt_id = p_cash_receipt_id
      AND    ROWNUM = 1;
      x_claim_applied := 'Y';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      x_claim_applied := 'N';
      SELECT
             app.receivable_application_id
           , app.apply_date
           , app.gl_date
           , app.amount_applied
           , app.trans_to_receipt_rate
           , app.earned_discount_taken
           , app.unearned_discount_taken
           , app.application_ref_num
           , app.application_ref_reason
	   , app.receivables_trx_id
	   , app.comments
           , app.customer_reference
           , app.attribute_category
           , app.attribute1
           , app.attribute2
           , app.attribute3
           , app.attribute4
           , app.attribute5
           , app.attribute6
           , app.attribute7
           , app.attribute8
           , app.attribute9
           , app.attribute10
           , app.attribute11
           , app.attribute12
           , app.attribute13
           , app.attribute14
           , app.attribute15
           , app.global_attribute_category
           , app.global_attribute1
           , app.global_attribute2
           , app.global_attribute3
           , app.global_attribute4
           , app.global_attribute5
           , app.global_attribute6
           , app.global_attribute7
           , app.global_attribute8
           , app.global_attribute9
           , app.global_attribute10
           , app.global_attribute11
           , app.global_attribute12
           , app.global_attribute13
           , app.global_attribute14
           , app.global_attribute15
           , app.global_attribute16
           , app.global_attribute17
           , app.global_attribute18
           , app.global_attribute19
           , app.global_attribute20
      INTO
             x_application_id
           , x_apply_date
           , x_app_gl_date
           , x_amount_applied
           , x_trans_to_receipt_rate
           , x_discount_earned
           , x_discount_unearned
           , x_application_ref_num
           , x_application_ref_reason
	   , x_receivables_trx_id
	   , x_comments
	   , x_customer_reference
           , x_attribute_rec.attribute_category
           , x_attribute_rec.attribute1
           , x_attribute_rec.attribute2
           , x_attribute_rec.attribute3
           , x_attribute_rec.attribute4
           , x_attribute_rec.attribute5
           , x_attribute_rec.attribute6
           , x_attribute_rec.attribute7
           , x_attribute_rec.attribute8
           , x_attribute_rec.attribute9
           , x_attribute_rec.attribute10
           , x_attribute_rec.attribute11
           , x_attribute_rec.attribute12
           , x_attribute_rec.attribute13
           , x_attribute_rec.attribute14
           , x_attribute_rec.attribute15
           , x_global_attribute_rec.global_attribute_category
           , x_global_attribute_rec.global_attribute1
           , x_global_attribute_rec.global_attribute2
           , x_global_attribute_rec.global_attribute3
           , x_global_attribute_rec.global_attribute4
           , x_global_attribute_rec.global_attribute5
           , x_global_attribute_rec.global_attribute6
           , x_global_attribute_rec.global_attribute7
           , x_global_attribute_rec.global_attribute8
           , x_global_attribute_rec.global_attribute9
           , x_global_attribute_rec.global_attribute10
           , x_global_attribute_rec.global_attribute11
           , x_global_attribute_rec.global_attribute12
           , x_global_attribute_rec.global_attribute13
           , x_global_attribute_rec.global_attribute14
           , x_global_attribute_rec.global_attribute15
           , x_global_attribute_rec.global_attribute16
           , x_global_attribute_rec.global_attribute17
           , x_global_attribute_rec.global_attribute18
           , x_global_attribute_rec.global_attribute19
           , x_global_attribute_rec.global_attribute20
      FROM   ar_receivable_applications app
      WHERE  app.secondary_application_ref_id = p_claim_id
      AND    app.applied_payment_schedule_id + 0 = p_applied_ps_id
      AND    app.application_ref_type = 'CLAIM'
      AND    app.status = DECODE(p_applied_ps_id,-4,'OTHER ACC','APP')
      AND    app.cash_receipt_id = p_cash_receipt_id
      AND    ROWNUM = 1;
    END;

    RETURN TRUE;
  ELSE
    FND_MESSAGE.SET_NAME('AR','AR_RW_INVALID_CLAIM_ID');
    FND_MSG_PUB.Add;
    RETURN FALSE;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.claim_on_receipt()-');
  END IF;

EXCEPTION
    WHEN OTHERS
      THEN
        FND_MESSAGE.SET_NAME('AR','AR_RWAPP_CLAIM_ID_NOTFOUND');
        FND_MESSAGE.SET_TOKEN('CLAIM_ID',p_claim_id);
        FND_MSG_PUB.Add;
        RETURN FALSE;
END claim_on_receipt;

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
 | 20-MAR-2002   jbeckett          Removed checks for amount and status
 |
 *=======================================================================*/
FUNCTION claim_valid (
      p_claim_id    IN  NUMBER,
      p_receipt_id  IN  NUMBER,
      p_curr_code   IN  VARCHAR2,
      p_amount      IN  NUMBER,
      x_claim_num   OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
  l_query              VARCHAR2(2000);
  l_api_name           CONSTANT VARCHAR2(30) := 'claim_valid';
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.claim_valid()+');
  END IF;
  --
  -- The sql to check for the existence of the claim in iClaim is dynamic
  -- to avoid package compilation problems if iClaim is not installed
  --
  x_claim_num := NULL;
  /* Bug 2270842 - amount and status should not be validated as the original
     claim will be reallocated in the event of a split */
  IF arp_global.tm_installed_flag = 'Y'
  THEN
    l_query := ' select claim_number '||
               ' from ozf_ar_deductions_v '||
               ' where claim_id = :claim_id '||
               ' and receipt_id = :receipt_id '||
               ' and currency_code = :currency_code ';
    BEGIN
      EXECUTE IMMEDIATE l_query
      INTO    x_claim_num
      USING   p_claim_id,
              p_receipt_id,
    	      p_curr_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name('AR','AR_RW_INVALID_CLAIM_ID');
        FND_MESSAGE.set_token('CLAIM_ID',p_claim_id);
        FND_MSG_PUB.Add;
        RETURN FALSE;
    END;
    RETURN TRUE;
  ELSE
    FND_MESSAGE.set_name('AR','AR_RW_ICLAIM_NOT_INSTALLED');
    FND_MSG_PUB.Add;
    RETURN FALSE;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.claim_valid()-');
  END IF;
EXCEPTION
    WHEN OTHERS THEN
               IF (SQLCODE = -20001)
               THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('claim_valid: ' || '20001 error '||
                    ' at arp_deduction_cover.claim_valid()+');
                 END IF;
               ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_standard.debug('claim_valid: ' || 'Unexpected error '||sqlerrm||
                   ' at arp_deduction_cover.claim_valid()+');
                  END IF;
                 IF    FND_MSG_PUB.Check_Msg_Level
                       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                 THEN
                       FND_MSG_PUB.Add_Exc_Msg
                       (       G_PKG_NAME          ,
                               l_api_name
                       );
                 END IF;
               END IF;
END claim_valid;

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
RETURN BOOLEAN
IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.negative_rct_writeoffs_allowed()+');
  END IF;
  RETURN TRUE;
END ;

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
                x_return_status        OUT NOCOPY VARCHAR2)
IS
  l_unapplied_total	NUMBER;
  l_new_unapplied_total	NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.validate_amount_applied()+');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT SUM(NVL(ra.amount_applied,0))
  INTO   l_unapplied_total
  FROM   ar_receivable_applications ra
  WHERE  ra.cash_receipt_id = p_cash_receipt_id
  AND    ra.status = 'UNAPP'
  AND    NVL(ra.confirmed_flag,'Y') = 'Y';

  l_new_unapplied_total := (l_unapplied_total + p_amount_applied - p_new_amount_applied);

  /* Bug fix 5291088 : Added additional debug messages */
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('p_cash_receipt_id = '||p_cash_receipt_id);
     arp_standard.debug('p_amount_applied = '||p_amount_applied);
     arp_standard.debug('p_new_amount_applied = '||p_new_amount_applied);
     arp_standard.debug('l_unapplied_total = '||l_unapplied_total);
     arp_standard.debug('l_new_unapplied_total = '||l_new_unapplied_total);
  END IF;

  IF l_new_unapplied_total < 0 THEN
    FND_MESSAGE.set_name('AR','AR_RW_CLAIM_SETTLMT_NEG_RCT');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER.validate_amount_applied()-');
  END IF;

  EXCEPTION WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ARXDECVB.pls:Validate_amount_applied' ||SQLERRM);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END validate_amount_applied;

END ARP_DEDUCTION_COVER;

/
