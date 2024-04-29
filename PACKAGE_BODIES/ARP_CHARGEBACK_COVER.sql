--------------------------------------------------------
--  DDL for Package Body ARP_CHARGEBACK_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CHARGEBACK_COVER" AS
/* $Header: ARXCBCVB.pls 120.24 2005/06/22 16:50:34 jbeckett noship $ */
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ARP_CHARGEBACK_COVER';

/*=======================================================================+
 | PROCEDURE                                                             |
 |      create_chargeback                                                |
 |                                                                       |
 | DESCRIPTION                                                           |
 |      Procedure create_chargback  -  Entry point for full              |
 |      chargeback creation                                              |
 | ARGUMENTS  : IN:                                                      |
 |                                                                       |
 |                                                                       |
 |                                                                       |
 |              OUT:                                                     |
 |          IN/ OUT:                                                     |
 |                                                                       |
 | RETURNS    :                                                          |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | KNOWN BUGS                                                            |
 |                                                                       |
 | MODIFICATION HISTORY                                                  |
 |    JBECKETT    03-OCT-01 Created                                      |
 |    JBECKETT    15-OCT-01 Modified to make generic so it handles both  |
 |                          chargebacks against receipts and transactions|
 |    S.Nambiar   18-JUN-02 Bug 2465176 -Added bill_to_site_use_id to    |
 |                          Chargeback_Rec_Type. If bill to location is  |
 |                          not passed, and receipt bill to site use id  |
 |                          is not passed, show error.If passed, validate|
 |                          bill to_site use id.                         |
 |    S.Nambiar   22-JUL-02 Bug 2474471-Corrected the validation logicfor
 |                          bill to site used id
 |    S.Nambiar   20-AUG-02 Bug 2516618 - Bill to site use id should be
 |                          validated with the customer id from invoice,
 |                          if its a invoice related chargeback.
 |    J.Beckett   04-NOV-02 Bug 2654633 - passed bill to site used instead
 |                          of site on receipt for a receipt chargeback.
 |    J.Beckett   15-JAN-03 Bug 2751910 - added internal_notes.
 |    J.Beckett   09-MAR-03 Bug 2751910 - caters for subsequent applications.
 |    J.Beckett   29-APR-04 Bug 3590399 - removed to_date causing data type
 |			    conflict in Trade Management
 |    J.Beckett   25-MAY-05 R12 LE uptake - legal_entity_id passed to handler.
 +=======================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE create_chargeback (
  p_chargeback_rec           IN  arp_chargeback_cover.Chargeback_Rec_Type,
  p_init_msg_list            IN  VARCHAR2,
  x_doc_sequence_id          OUT NOCOPY NUMBER,
  x_doc_sequence_value       OUT NOCOPY ra_customer_trx.doc_sequence_value%TYPE,
  x_trx_number               OUT NOCOPY ra_customer_trx.trx_number%TYPE,
  x_customer_trx_id          OUT NOCOPY NUMBER,
  x_return_status            OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2)

IS
   l_set_of_books_id               NUMBER;
   l_default_code_combination_id   NUMBER;
   l_code_combination_id           NUMBER;
   l_default_cb_due_date           VARCHAR2(30);
   l_application_id                NUMBER;
   l_applied_ps_id                 NUMBER; -- bug 3682568
   l_app_due_date                  DATE;
   l_due_date                      DATE;
   l_apply_date                    DATE;
   l_app_gl_date                   DATE;
   l_amount                        NUMBER;
   l_acctd_amount                  NUMBER;
   l_bal_due_remaining             NUMBER;
   l_app_receivables_trx_id        NUMBER;
   l_app_comments                  ar_receivable_applications.comments%TYPE;
   l_customer_reference            ar_receivable_applications.customer_reference%TYPE;
   l_claim_reason_name             VARCHAR2(80);
   l_application_ref_num           ar_receivable_applications.application_ref_num%TYPE;
   l_application_ref_reason        ar_receivable_applications.application_ref_reason%TYPE;
   l_application_ref_type          ar_receivable_applications.application_ref_type%TYPE;
   l_application_ref_id            NUMBER;
   l_dum_app_ref_type              ar_receivable_applications.application_ref_type%TYPE;
   l_dum_app_ref_id                NUMBER;
   l_dum_app_ref_num               ar_receivable_applications.application_ref_num%TYPE;
   l_dum_sec_app_ref_id            NUMBER;
   l_payment_set_id                NUMBER;
   l_attribute_rec                 AR_Receipt_API_PUB.attribute_rec_type;
   l_global_attribute_rec          AR_Receipt_API_PUB.global_attribute_rec_type;
   l_receipt_number                ar_cash_receipts.receipt_number%TYPE;
   l_receipt_date                  DATE;
   l_trx_date                      DATE;
   l_cr_gl_date                    DATE;
   l_cr_payment_schedule_id        NUMBER;
   l_currency_code                 ar_cash_receipts.currency_code%TYPE;
   l_exchange_rate                 NUMBER;
   l_exchange_rate_type            ar_cash_receipts.exchange_rate_type%TYPE;
   l_exchange_rate_date            DATE;
   l_bill_to_site_use_id           NUMBER;
   l_remit_to_address_id           NUMBER;
   l_cb_exchange_rate              NUMBER;
   l_cb_exchange_rate_type         ar_cash_receipts.exchange_rate_type%TYPE;
   l_cb_exchange_rate_date         DATE;
   l_cb_currency_code              ar_cash_receipts.currency_code%TYPE;
   l_cb_bill_to_site_use_id        NUMBER;
   l_cb_remit_to_address_id        NUMBER;
   l_cb_amount                     NUMBER;
   l_cb_acctd_amount               NUMBER;
   l_deposit_date                  DATE;
   l_customer_id                   NUMBER;
   l_gl_date                       DATE; -- bug 2621114
   l_app_gl_date_prof              VARCHAR2(240); -- bug 2621114
   l_default_gl_date               DATE;
   l_defaulting_rule_used          VARCHAR2(50);
   l_customer_trx_id               NUMBER;
   l_installment                   ar_payment_schedules.terms_sequence_number%TYPE;
   l_new_claim_num                 ar_receivable_applications.application_ref_num%TYPE;
   l_doc_sequence_id               NUMBER := NULL;
   l_doc_sequence_value            ra_customer_trx.doc_sequence_value%TYPE := NULL;
   l_trx_number                    ra_customer_trx.trx_number%TYPE;
   l_new_customer_trx_id           NUMBER;
   l_new_application_id            NUMBER;
   l_new_app_ref_num               ar_receivable_applications.application_ref_num%TYPE;
   l_new_app_ref_id                ar_receivable_applications.application_ref_id%TYPE;
   l_balance                       NUMBER := 0;
   l_functional_curr               VARCHAR2(100);
   l_error_message                 VARCHAR2(2000);
   l_error_count                   NUMBER := 0;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000);
   l_api_name                      CONSTANT VARCHAR2(30)
                                            := 'create_chargeback';
   l_site_required_flag            ar_system_parameters.site_required_flag%TYPE := 'N';
   lp_bill_to_site_use_id          NUMBER; --Stores the bill_to_site_id passed from claim
   l_cb_trx_type 		   ra_cust_trx_types.name%TYPE;
   l_sequence_name		   fnd_document_sequences.name%TYPE;
   l_legal_entity_id               ra_customer_trx.legal_entity_id%TYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_chargeback_cover.create_chargeback()+');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT	Create_Chargeback;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Bug 3022077 - initialize global variables in case SOB or org changed */
  arp_global.init_global;
  arp_standard.init_standard;

 /*---------------------------------------------------------------------+
  | A) Validate and Default parameters                                  |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('create_chargeback: ' || 'PARAMETER VALUES: ');
     arp_standard.debug('create_chargeback: ' || 'amount = '||p_chargeback_rec.amount);
     arp_standard.debug('create_chargeback: ' || 'cust_trx_type_id = '||p_chargeback_rec.cust_trx_type_id);
     arp_standard.debug('create_chargeback: ' || 'code_combination_id = '||p_chargeback_rec.code_combination_id);
     arp_standard.debug('create_chargeback: ' || 'reason_code = '||p_chargeback_rec.reason_code);
     arp_standard.debug('create_chargeback: ' || 'gl_date = '||p_chargeback_rec.gl_date);
     arp_standard.debug('create_chargeback: ' || 'due_date = '||p_chargeback_rec.due_date);
     arp_standard.debug('create_chargeback: ' || 'cash_receipt_id = '||p_chargeback_rec.cash_receipt_id);
     arp_standard.debug('create_chargeback: ' || 'secondary_application_ref_id = '||p_chargeback_rec.secondary_application_ref_id);
     arp_standard.debug('create_chargeback: ' || 'new_second_application_ref_id = '||p_chargeback_rec.new_second_application_ref_id);
     arp_standard.debug('create_chargeback: ' || 'application_ref_type = '||p_chargeback_rec.application_ref_type);
     arp_standard.debug('create_chargeback: ' || 'Bill to site use id Passed = '||p_chargeback_rec.bill_to_site_use_id);
  END IF;

 /*---------------------------------------------------------------------+
  | 1)   Check receipt valid / get receipt details                      |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('create_chargeback: ' || 'Checking cash receipt ...');
  END IF;
  IF (p_chargeback_rec.cash_receipt_id IS NULL)
  THEN
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_NULL');
     FND_MSG_PUB.Add;
     l_error_count := l_error_count + 1;
  ELSE
    BEGIN
      SELECT cr.receipt_number
           , cr.receipt_date
           , crh.gl_date
           , cr.deposit_date
           , cr.pay_from_customer
           , ps.payment_schedule_id
           , cr.currency_code
           , cr.exchange_rate
           , cr.exchange_rate_type
           , cr.exchange_date
           , cr.customer_site_use_id
      INTO   l_receipt_number
           , l_receipt_date
           , l_cr_gl_date
           , l_deposit_date
           , l_customer_id
           , l_cr_payment_schedule_id
           , l_currency_code
           , l_exchange_rate
           , l_exchange_rate_type
           , l_exchange_rate_date
           , l_bill_to_site_use_id
      FROM   ar_cash_receipts cr
           , ar_payment_schedules ps
           , ar_cash_receipt_history crh
      WHERE  cr.cash_receipt_id = crh.cash_receipt_id(+)
      AND    crh.first_posted_record_flag(+) = 'Y'
      AND    cr.cash_receipt_id = ps.cash_receipt_id(+)
      AND    cr.cash_receipt_id = p_chargeback_rec.cash_receipt_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        FND_MESSAGE.SET_NAME('AR','ARTA_ERR_FINDING_CASH_RCPT');
        FND_MESSAGE.SET_TOKEN('CR_ID',p_chargeback_rec.cash_receipt_id);
        FND_MSG_PUB.Add;
        l_error_count := l_error_count + 1;
    END;
  END IF;

 /*---------------------------------------------------------------------+
  | 2)  Get required system parameters                                  |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('create_chargeback: ' || 'Getting system parameters... ');
  END IF;
  SELECT set_of_books_id
       , default_cb_due_date
       , nvl(site_required_flag,'N')
  INTO   l_set_of_books_id
       , l_default_cb_due_date
       , l_site_required_flag
  FROM   ar_system_parameters;


 /*---------------------------------------------------------------------+
  | 4)   Check secondary app ref id valid / get application details     |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('create_chargeback: ' || 'Checking application ...');
  END IF;
  IF (p_chargeback_rec.secondary_application_ref_id IS NULL)
  THEN
     FND_MESSAGE.SET_NAME('AR','AR_RW_NULL_SECOND_APP_REF_ID');
     FND_MSG_PUB.Add;
     l_error_count := l_error_count + 1;
  END IF;

  IF (p_chargeback_rec.application_ref_type IS NULL)
  THEN
     FND_MESSAGE.SET_NAME('AR','AR_RW_NULL_APP_REF_TYPE');
     FND_MSG_PUB.Add;
     l_error_count := l_error_count + 1;
  END IF;

  IF (p_chargeback_rec.secondary_application_ref_id IS NOT NULL AND
      p_chargeback_rec.application_ref_type IS NOT NULL AND
      p_chargeback_rec.cash_receipt_id IS NOT NULL)
  THEN
    BEGIN
      SELECT
             app.receivable_application_id
           , app.applied_payment_schedule_id -- bug 3682568
           , DECODE(SIGN(app.applied_payment_schedule_id),-1,NULL,
                   ps.due_date) due_date -- Bug 3590399: removed to_date
           , app.apply_date
           , app.gl_date
           , app.amount_applied
           , app.acctd_amount_applied_from
           , DECODE(SIGN(app.applied_payment_schedule_id),
                         -1,app.applied_payment_schedule_id,
                            app.applied_customer_trx_id)
           , TO_NUMBER(DECODE(SIGN(app.applied_payment_schedule_id),-1,NULL,
                        ps.terms_sequence_number)) installment
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
             l_application_id
           , l_applied_ps_id -- bug 3682568
           , l_app_due_date
           , l_apply_date
           , l_app_gl_date
           , l_amount
           , l_acctd_amount
           , l_customer_trx_id
           , l_installment
           , l_application_ref_num
           , l_application_ref_reason
           , l_app_receivables_trx_id
           , l_app_comments
           , l_customer_reference
           , l_attribute_rec.attribute_category
           , l_attribute_rec.attribute1
           , l_attribute_rec.attribute2
           , l_attribute_rec.attribute3
           , l_attribute_rec.attribute4
           , l_attribute_rec.attribute5
           , l_attribute_rec.attribute6
           , l_attribute_rec.attribute7
           , l_attribute_rec.attribute8
           , l_attribute_rec.attribute9
           , l_attribute_rec.attribute10
           , l_attribute_rec.attribute11
           , l_attribute_rec.attribute12
           , l_attribute_rec.attribute13
           , l_attribute_rec.attribute14
           , l_attribute_rec.attribute15
           , l_global_attribute_rec.global_attribute_category
           , l_global_attribute_rec.global_attribute1
           , l_global_attribute_rec.global_attribute2
           , l_global_attribute_rec.global_attribute3
           , l_global_attribute_rec.global_attribute4
           , l_global_attribute_rec.global_attribute5
           , l_global_attribute_rec.global_attribute6
           , l_global_attribute_rec.global_attribute7
           , l_global_attribute_rec.global_attribute8
           , l_global_attribute_rec.global_attribute9
           , l_global_attribute_rec.global_attribute10
           , l_global_attribute_rec.global_attribute11
           , l_global_attribute_rec.global_attribute12
           , l_global_attribute_rec.global_attribute13
           , l_global_attribute_rec.global_attribute14
           , l_global_attribute_rec.global_attribute15
           , l_global_attribute_rec.global_attribute16
           , l_global_attribute_rec.global_attribute17
           , l_global_attribute_rec.global_attribute18
           , l_global_attribute_rec.global_attribute19
           , l_global_attribute_rec.global_attribute20
      FROM   ar_payment_schedules ps
           , ar_receivable_applications app
      WHERE  app.applied_payment_schedule_id = ps.payment_schedule_id
      AND    app.secondary_application_ref_id = p_chargeback_rec.secondary_application_ref_id
      AND    app.application_ref_type = p_chargeback_rec.application_ref_type
      AND    app.applied_payment_schedule_id = ps.payment_schedule_id
      AND    app.display = 'Y'
      AND    app.status IN ('APP','OTHER ACC')
      AND    app.cash_receipt_id = p_chargeback_rec.cash_receipt_id
      AND    ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_SEC_APP_REF_ID_NOTFOUND');
        FND_MESSAGE.SET_TOKEN('SECOND_APP_REF_ID',p_chargeback_rec.secondary_application_ref_id);
        FND_MESSAGE.SET_TOKEN
                   ('APP_REF_TYPE',p_chargeback_rec.application_ref_type);
        FND_MSG_PUB.Add;
        l_error_count := l_error_count + 1;
    END;
  END IF;

 /*---------------------------------------------------------------------+
  |If this is an invoice related CB, then take the bill to site id of   |
  |the invoice. There could be posibility the receipt customer and the  |
  |invoice customer is different.                                       |
  +---------------------------------------------------------------------*/
  --Bug 2516618
  IF SIGN(l_customer_trx_id) <> -1 THEN
    BEGIN
      SELECT bill_to_customer_id,
             bill_to_site_use_id,
             trx_date
      INTO   l_customer_id,
             l_bill_to_site_use_id ,
             l_trx_date
      FROM   ra_customer_trx
      WHERE  customer_trx_id=l_customer_trx_id;
    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_INVALID');
        FND_MSG_PUB.Add;
        l_error_count := l_error_count + 1;
    END;
   END IF;

    /*---------------------------------------------------------------------+
     | 3)  Check bill_to_site_use_id exist                                 |
     +---------------------------------------------------------------------*/
     --if bill to site id is not passed,or not entered on the receipt,raise error.

     IF l_bill_to_site_use_id IS NULL THEN
         IF p_chargeback_rec.bill_to_site_use_id IS NULL THEN
           FND_MESSAGE.SET_NAME('AR','AR_CUST_BILL_TO_SITE_REQUIRED');
           FND_MSG_PUB.Add;
           l_error_count := l_error_count + 1;
         ELSE
           l_bill_to_site_use_id := p_chargeback_rec.bill_to_site_use_id;
         END IF;
     END IF;

     /* Bug 2654633 - If bill to site has been passed for a receipt chargeback
        then use it in preference to the receipt site */
     IF (SIGN(l_customer_trx_id) = -1 AND
         p_chargeback_rec.bill_to_site_use_id IS NOT NULL )
     THEN
       l_bill_to_site_use_id := p_chargeback_rec.bill_to_site_use_id;
     END IF;

    /*---------------------------------------------------------------------+
     | 5)  Validate  bill_to_site_use_id passed                            |
     |     we will take the passed bill to site only for non-invoice claim.|
     |     for invoice, take it from the invoice.                          |
     +---------------------------------------------------------------------*/
     IF l_bill_to_site_use_id IS NOT NULL THEN
     BEGIN
       --Bug 2474471- Corrected the validation logic take from customer
       --account.

       SELECT  site_uses.site_use_id
       INTO    l_bill_to_site_use_id
       FROM    hz_cust_acct_sites acct_site,
               hz_party_sites party_site,
               hz_locations loc,
               hz_cust_site_uses site_uses
       WHERE   acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
       AND     acct_site.party_site_id = party_site.party_site_id
       AND     loc.location_id = party_site.location_id
       AND     site_uses.site_use_code in ('BILL_TO','DRAWEE')
       AND     acct_site.cust_account_id = l_customer_id
       AND     site_uses.site_use_id=l_bill_to_site_use_id;

       EXCEPTION
        WHEN no_data_found THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_STE_USE_ID_INVALID');
          FND_MSG_PUB.Add;
          l_error_count := l_error_count + 1;
       END;

     END IF;


 /*---------------------------------------------------------------------+
  | 6)   Check trx type is valid                                        |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('create_chargeback: ' || 'Checking trx type... ');
  END IF;
  IF p_chargeback_rec.cust_trx_type_id IS NULL
  THEN
    FND_MESSAGE.SET_NAME('AR','AR_BR_TRX_TYPE_NULL');
    FND_MSG_PUB.Add;
    l_error_count := l_error_count + 1;
  ELSE
    BEGIN
      SELECT name,
	     gl_id_rec
      INTO   l_cb_trx_type,
	     l_default_code_combination_id
      FROM   ra_cust_trx_types
      WHERE  cust_trx_type_id = p_chargeback_rec.cust_trx_type_id
      AND    type = 'CB'
      AND NVL(status,'A') = 'A'
      AND post_to_gl = 'Y'
      AND accounting_affect_flag = 'Y'
      AND (l_receipt_date BETWEEN start_date AND nvl(end_date+1,l_receipt_date));
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_INVALID_CB_TRX_TYPE');
        FND_MESSAGE.SET_TOKEN('TRX_TYPE_ID',p_chargeback_rec.cust_trx_type_id);
        FND_MSG_PUB.Add;
        l_error_count := l_error_count + 1;
    END;
  END IF;
  IF p_chargeback_rec.code_combination_id IS NULL
  THEN
    l_code_combination_id := l_default_code_combination_id;
  ELSE
    l_code_combination_id := p_chargeback_rec.code_combination_id;
  END IF;
 /*---------------------------------------------------------------------+
  | 7)  If the chargeback is to resolve a non invoice related claim and |
  |     the applied amount differs from the amount to be written off    |
  |     check the new claim is valid                                    |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('create_chargeback: ' || 'Checking new claim... ');
  END IF;
  IF (p_chargeback_rec.application_ref_type = 'CLAIM' AND
      l_customer_trx_id = -4 AND
      l_amount <> p_chargeback_rec.amount)
  THEN
    l_balance := (l_amount - p_chargeback_rec.amount);
    IF p_chargeback_rec.new_second_application_ref_id IS NULL
    THEN
      FND_MESSAGE.set_name('AR','AR_RWAPP_NEW_CLAIM_ID_NULL');
      FND_MSG_PUB.Add;
      l_error_count := l_error_count + 1;
    ELSE
      IF NOT arp_deduction_cover.claim_valid(
            p_claim_id => p_chargeback_rec.new_second_application_ref_id,
	    p_receipt_id => p_chargeback_rec.cash_receipt_id,
	    p_curr_code => l_currency_code,
            p_amount   => l_balance,
            x_claim_num  => l_new_claim_num)
      THEN
        l_error_count := l_error_count + 1;
      END IF;
    END IF;
  END IF;


 /*---------------------------------------------------------------------+
  | 8)  Get GL date if null                                             |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('create_chargeback: ' || 'Validating/defaulting GL date ... ');
  END IF;

  /* Bug 2621114 - get GL date from Profile Option AR: Application GL Date
     Default if null */
  IF p_chargeback_rec.gl_date IS NULL
  THEN
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
    ELSE
      l_gl_date := SYSDATE;
    END IF;
  ELSE
    l_gl_date := p_chargeback_rec.gl_date;
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
  | 9)  Default due date if null                                        |
  +---------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('create_chargeback: ' || 'Defaulting due date... ');
  END IF;

  --
  -- Bug 3404131 - Due date defaulted for receipt chargeback in the same way
  -- as for transaction chargebacks
  --
  IF p_chargeback_rec.due_date IS NULL
  THEN
    IF l_default_cb_due_date = 'DUE_DATE'
    THEN
      l_due_date := l_app_due_date;
    ELSIF l_default_cb_due_date = 'RECEIPT_DATE'
    THEN
      l_due_date := l_receipt_date;
    ELSIF l_default_cb_due_date = 'SYSDATE'
    THEN
      l_due_date := SYSDATE;
    ELSIF l_default_cb_due_date = 'DEPOSIT_DATE'
    THEN
      l_due_date := l_deposit_date;
    ELSE
      l_due_date := SYSDATE;
    END IF;
    IF l_due_date IS NULL
    THEN
      l_due_date := SYSDATE;
    END IF;
  ELSE
    l_due_date := p_chargeback_rec.due_date;
  END IF;


  IF SIGN(l_customer_trx_id) = -1
  THEN
     IF (p_chargeback_rec.due_date IS NOT NULL AND
         p_chargeback_rec.due_date < l_receipt_date)
     THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_DUE_DATE');
        FND_MSG_PUB.Add;
        l_error_count := l_error_count + 1;
     ELSE
       IF l_due_date < l_receipt_date THEN
         l_due_date := l_receipt_date;
       END IF;
     END IF;
    l_cb_exchange_rate := l_exchange_rate;
    l_cb_exchange_rate_type := l_exchange_rate_type;
    l_cb_exchange_rate_date := l_exchange_rate_date;
    l_cb_currency_code := l_currency_code;
    l_cb_bill_to_site_use_id := l_bill_to_site_use_id;
    l_cb_remit_to_address_id :=
      AR_INVOICE_SQL_FUNC_PUB.get_remit_to_given_bill_to(l_bill_to_site_use_id);
  ELSE
    l_cb_exchange_rate := NULL;
    l_cb_exchange_rate_type := NULL;
    l_cb_exchange_rate_date := NULL;
    l_cb_currency_code := NULL;
    l_cb_bill_to_site_use_id := NULL;
    l_cb_remit_to_address_id := NULL;
  END IF;

  /*-------------------------------------------------+
   | R12 LE uptake
   | Validating the legal_entity_id
   +--------------------------------------------------*/
  IF p_chargeback_rec.legal_entity_id IS NOT NULL THEN
    BEGIN
       SELECT legal_entity_id
       INTO   l_legal_entity_id
       FROM   XLE_FIRSTPARTY_INFORMATION_V LE
       WHERE  LE.legal_entity_id = p_chargeback_rec.legal_entity_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
	  FND_MESSAGE.SET_NAME('AR','AR_INVALID_LEGAL_ENTITY');
          FND_MSG_PUB.Add;
          l_error_count := l_error_count + 1;
       WHEN OTHERS THEN
          NULL;
    END;
  END IF;

  IF l_error_count > 0
  THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
 /*---------------------------------------------------------------------+
  | B)  Insert new records                                              |
  +---------------------------------------------------------------------*/

  -- Bug 3682568 lock the receipt or ps before calling the entity handlers
  IF SIGN(l_customer_trx_id) = -1
  THEN
    BEGIN
      arp_cash_receipts_pkg.nowaitlock_p(p_cr_id => p_chargeback_rec.cash_receipt_id);
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR','ARCABP_CANT_UPD_CR');
        FND_MSG_PUB.Add;
        FND_MESSAGE.SET_NAME('AR','AR_TW_FORM_RECORD_CHANGED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END;
  ELSIF l_applied_ps_id IS NOT NULL THEN
    BEGIN
      arp_ps_pkg.nowaitlock_p (p_ps_id => l_applied_ps_id);
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR','AR_TW_FORM_RECORD_CHANGED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END;

  END IF;

  IF SIGN(l_customer_trx_id) <> -1
  THEN
   /*---------------------------------------------------------------------+
    | 1)  Chargeback against a transaction so update amount in dispute    |
    +---------------------------------------------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_chargeback: ' || 'Updating amount in dispute... ');
    END IF;


    arp_deduction_cover.update_amount_in_dispute(
             p_customer_trx_id => l_customer_trx_id,
             p_claim_number    => l_application_ref_num,
             p_amount          => (p_chargeback_rec.amount * -1),
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data);
  END IF;

  /* Bug 3013567 - get the next document sequence if enabled */
  IF (NVL(fnd_profile.value('UNIQUE:SEQ_NUMBERS'),'N') <> 'N')
  THEN

   BEGIN

    l_doc_sequence_value :=
       FND_SEQNUM.GET_NEXT_SEQUENCE(
                appid           => arp_standard.application_id,
                cat_code        => l_cb_trx_type,
                sobid           => arp_global.set_of_books_id,
                met_code        => 'A',
                trx_date        => SYSDATE,
                dbseqnm         => l_sequence_name,
                dbseqid         => l_doc_sequence_id);

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARXCBCVB.create_chargeback: ' || 'doc sequence name = '  || l_sequence_name);
        arp_standard.debug('ARXCBCVB.create_chargeback: ' || 'doc sequence id    = ' || l_doc_sequence_id);
        arp_standard.debug('ARXCBCVB.create_chargeback: ' || 'doc sequence value = ' || l_doc_sequence_value);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
     IF NVL(fnd_profile.value('UNIQUE:SEQ_NUMBERS'),'N') = 'A' THEN
         FND_MESSAGE.set_name ('AR', 'AR_RW_NO_DOC_SEQ' );
         FND_MSG_PUB.Add;
    	 RAISE FND_API.G_EXC_ERROR;
     END IF;
   END;

 ELSE
    l_doc_sequence_value      := NULL;
    l_doc_sequence_id         := NULL;
 END IF;

 /*---------------------------------------------------------------------+
  | 2)  Call chargeback entity handler to create chargeback             |
  +---------------------------------------------------------------------*/
    l_functional_curr := arp_global.functional_currency;

    l_cb_amount :=  (p_chargeback_rec.amount * SIGN(l_customer_trx_id));
    l_cb_acctd_amount :=
                 (ARPCURR.functional_amount( p_chargeback_rec.amount,
                                            l_functional_curr,
                                            l_cb_exchange_rate,
                                            NULL, NULL )
                  * SIGN(l_customer_trx_id));

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_chargeback: ' || 'Creating chargeback ... ');
    END IF;

   -- Enh 4103090: pass the reason code sent by TM or if null, pass
   -- INVALID_CLAIM

    arp_process_chargeback.create_chargeback (
	  p_attribute_category =>
			p_chargeback_rec.attribute_category
	, p_attribute1  => p_chargeback_rec.attribute1
	, p_attribute2  => p_chargeback_rec.attribute2
	, p_attribute3  => p_chargeback_rec.attribute3
	, p_attribute4  => p_chargeback_rec.attribute4
	, p_attribute5  => p_chargeback_rec.attribute5
	, p_attribute6  => p_chargeback_rec.attribute6
	, p_attribute7  => p_chargeback_rec.attribute7
	, p_attribute8  => p_chargeback_rec.attribute8
	, p_attribute9  => p_chargeback_rec.attribute9
	, p_attribute10 => p_chargeback_rec.attribute10
	, p_attribute11 => p_chargeback_rec.attribute11
	, p_attribute12 => p_chargeback_rec.attribute12
	, p_attribute13 => p_chargeback_rec.attribute13
	, p_attribute14 => p_chargeback_rec.attribute14
	, p_attribute15 => p_chargeback_rec.attribute15
	, p_cust_trx_type_id => p_chargeback_rec.CUST_TRX_TYPE_ID
	, p_set_of_books_id => l_set_of_books_id
	, p_reason_code => NVL( p_chargeback_rec.reason_code,
                                'INVALID_CLAIM')  /* TM reason code */
	, p_trx_date => SYSDATE -- BUG 2621114
	, p_comments => p_chargeback_rec.COMMENTS
	, p_def_ussgl_trx_code_context => p_chargeback_rec.DEFAULT_USSGL_TRX_CODE_CONTEXT
	, p_def_ussgl_transaction_code => p_chargeback_rec.DEFAULT_USSGL_TRANSACTION_CODE
	, p_app_customer_trx_id => l_customer_trx_id
        , p_app_terms_sequence_number => l_installment
	, p_due_date 		=> l_due_date
	, p_form_name 		=> 'ARXRWAPP'
	, p_receipt_gl_date 	=> l_cr_gl_date
	, p_apply_date		=> SYSDATE -- bug 2621114
	, p_inv_trx_number	=> NULL
	, p_cash_receipt_id	=> p_chargeback_rec.cash_receipt_id
	, p_cr_trx_number	=> l_receipt_number
	, p_customer_id		=> l_customer_id
	, p_gl_date		=> l_default_gl_date
	, p_gl_id_ar_trade	=> l_code_combination_id
	, p_amount		=> l_cb_amount
	, p_acctd_amount	=> l_cb_acctd_amount
        , p_exchange_rate_type  => l_cb_exchange_rate_type
        , p_exchange_date       => l_cb_exchange_rate_date
        , p_exchange_rate       => l_cb_exchange_rate
        , p_currency_code       => l_cb_currency_code
        , p_remit_to_address_id => l_cb_remit_to_address_id
        , p_bill_to_site_use_id => l_cb_bill_to_site_use_id
	-- IN OUT NOCOPY
	, p_doc_sequence_id => l_doc_sequence_id
	, p_doc_sequence_value => l_doc_sequence_value

	-- OUT NOCOPY
	, p_out_trx_number 	=> l_trx_number
	, p_out_customer_trx_id	=> l_new_customer_trx_id
       --Bug 2444737
        ,p_interface_header_context     => p_chargeback_rec.interface_header_context
        ,p_interface_header_attribute1  => p_chargeback_rec.interface_header_attribute1
        ,p_interface_header_attribute2  => p_chargeback_rec.interface_header_attribute2
        ,p_interface_header_attribute3  => p_chargeback_rec.interface_header_attribute3
        ,p_interface_header_attribute4  => p_chargeback_rec.interface_header_attribute4
        ,p_interface_header_attribute5  => p_chargeback_rec.interface_header_attribute5
        ,p_interface_header_attribute6  => p_chargeback_rec.interface_header_attribute6
        ,p_interface_header_attribute7  => p_chargeback_rec.interface_header_attribute7
        ,p_interface_header_attribute8  => p_chargeback_rec.interface_header_attribute8
        ,p_interface_header_attribute9  => p_chargeback_rec.interface_header_attribute9
        ,p_interface_header_attribute10 => p_chargeback_rec.interface_header_attribute10
        ,p_interface_header_attribute11 => p_chargeback_rec.interface_header_attribute11
        ,p_interface_header_attribute12 => p_chargeback_rec.interface_header_attribute12
        ,p_interface_header_attribute13 => p_chargeback_rec.interface_header_attribute13
        ,p_interface_header_attribute14 => p_chargeback_rec.interface_header_attribute14
        ,p_interface_header_attribute15 => p_chargeback_rec.interface_header_attribute15
-- Bug 2751910
        ,p_internal_notes               => p_chargeback_rec.internal_notes
        ,p_customer_reference           => p_chargeback_rec.customer_reference
        ,p_legal_entity_id              => p_chargeback_rec.legal_entity_id  /* R12 LE uptake */
);
  END IF;

  x_doc_sequence_id := l_doc_sequence_id;
  x_doc_sequence_value := l_doc_sequence_value;
  x_trx_number := l_trx_number;
  x_customer_trx_id := l_new_customer_trx_id;

 /*---------------------------------------------------------------------+
  | 3)  If a receipt chargeback then unapply the claim investigation    |
  +---------------------------------------------------------------------*/
  IF l_customer_trx_id = -4
  THEN
    --
    -- Unapply the application
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_chargeback: ' || 'Unapplying OTHER ACC application ... ');
    END IF;
    arp_process_application.reverse(
          p_ra_id		=> l_application_id
	, p_reversal_gl_date   	=> l_default_gl_date
	, p_reversal_date      	=> TRUNC(SYSDATE)
	, p_module_name		=> 'ARXRWAPP'
	, p_module_version	=> '1.0'
        , p_bal_due_remaining   => l_bal_due_remaining);

   /*---------------------------------------------------------------------+
    | 4)  Apply against dummy activity with PS id -5 using entity handler |
    +---------------------------------------------------------------------*/
    --
    -- We can't use the receipt API here because it can't handle negative
    -- amounts.  For claims, the amount_applied is normally negative
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_chargeback: ' || 'Applying chargeback amount to dummy activity ... ');
    END IF;

    l_application_ref_type  := 'CHARGEBACK';
    l_application_ref_id    :=  l_new_customer_trx_id;
    l_dum_sec_app_ref_id    := NULL;

    -- Bug 3590399: trx date not relevant for non trx-related chargeback
    l_apply_date := GREATEST(SYSDATE, NVL(l_receipt_date,SYSDATE));

    arp_process_application.activity_application (
             p_receipt_ps_id   => l_cr_payment_schedule_id,
             p_application_ps_id => -5,
             p_link_to_customer_trx_id => NULL,
             p_amount_applied  => p_chargeback_rec.amount,
             p_apply_date      => l_apply_date, -- Bug 2621114
             p_gl_date         => l_default_gl_date, -- Bug 2621114
             p_receivables_trx_id => -11,
             p_ussgl_transaction_code => p_chargeback_rec.default_ussgl_transaction_code,
             p_attribute_category=> l_attribute_rec.attribute_category,
             p_attribute1        => l_attribute_rec.attribute1,
             p_attribute2        => l_attribute_rec.attribute2,
             p_attribute3        => l_attribute_rec.attribute3,
             p_attribute4        => l_attribute_rec.attribute4,
             p_attribute5        => l_attribute_rec.attribute5,
             p_attribute6        => l_attribute_rec.attribute6,
             p_attribute7        => l_attribute_rec.attribute7,
             p_attribute8        => l_attribute_rec.attribute8,
             p_attribute9        => l_attribute_rec.attribute9,
             p_attribute10       => l_attribute_rec.attribute10,
             p_attribute11       => l_attribute_rec.attribute11,
             p_attribute12       => l_attribute_rec.attribute12,
             p_attribute13       => l_attribute_rec.attribute13,
             p_attribute14       => l_attribute_rec.attribute14,
             p_attribute15       => l_attribute_rec.attribute15,
             p_global_attribute_category => l_global_attribute_rec.global_attribute_category,
             p_global_attribute1 => l_global_attribute_rec.global_attribute1,
             p_global_attribute2 => l_global_attribute_rec.global_attribute2,
             p_global_attribute3 => l_global_attribute_rec.global_attribute3,
             p_global_attribute4 => l_global_attribute_rec.global_attribute4,
             p_global_attribute5 => l_global_attribute_rec.global_attribute5,
             p_global_attribute6 => l_global_attribute_rec.global_attribute6,
             p_global_attribute7 => l_global_attribute_rec.global_attribute7,
             p_global_attribute8 => l_global_attribute_rec.global_attribute8,
             p_global_attribute9 => l_global_attribute_rec.global_attribute9,
             p_global_attribute10 =>l_global_attribute_rec.global_attribute10,
             p_global_attribute11 =>l_global_attribute_rec.global_attribute11,
             p_global_attribute12 =>l_global_attribute_rec.global_attribute12,
             p_global_attribute13 =>l_global_attribute_rec.global_attribute13,
             p_global_attribute14 =>l_global_attribute_rec.global_attribute14,
             p_global_attribute15 =>l_global_attribute_rec.global_attribute15,
             p_global_attribute16 =>l_global_attribute_rec.global_attribute16,
             p_global_attribute17 =>l_global_attribute_rec.global_attribute17,
             p_global_attribute18 =>l_global_attribute_rec.global_attribute18,
             p_global_attribute19 =>l_global_attribute_rec.global_attribute19,
             p_global_attribute20 =>l_global_attribute_rec.global_attribute20,
             p_module_name         => 'ARXRWAPP',
             p_module_version      => 1.0,
             p_secondary_application_ref_id => l_dum_sec_app_ref_id,
             p_application_ref_type  => l_application_ref_type,
             p_application_ref_id  => l_application_ref_id,
             p_application_ref_num  => l_application_ref_num,
                                             -- *** OUT NOCOPY
             p_out_rec_application_id => l_new_application_id
                                  );

  END IF;

  /*---------------------------------------------------------------------+
   | 5)  For non invoice related deduction, reapply balance to new claim |
   +---------------------------------------------------------------------*/
  IF (p_chargeback_rec.application_ref_type = 'CLAIM' AND
      l_customer_trx_id = -4 AND
      l_amount <> p_chargeback_rec.amount)
  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_chargeback: ' || 'Before Inserting Claim Application (+)');
    END IF;

    /* Bug 2821139 - under no circumstances should AR update claims when
     they are settled from TM */

    arp_process_application.other_account_application (
        -- *** IN
	  p_receipt_ps_id	   => l_cr_payment_schedule_id
	, p_amount_applied	   => l_balance
	, p_apply_date		   => l_apply_date
	, p_gl_date	           => l_default_gl_date -- bug 2621114
        , p_receivables_trx_id     => l_app_receivables_trx_id
        , p_applied_ps_id          => -4    /* Claim Investigation */
	, p_ussgl_transaction_code => p_chargeback_rec.default_ussgl_transaction_code
    , p_application_ref_type       => 'CLAIM'
    , p_application_ref_id         => NULL
    , p_application_ref_num        => l_new_claim_num
    , p_secondary_application_ref_id => p_chargeback_rec.new_second_application_ref_id
    , p_comments                   => l_app_comments
    , p_attribute_category=> l_attribute_rec.attribute_category
    , p_attribute1        => l_attribute_rec.attribute1
    , p_attribute2        => l_attribute_rec.attribute2
    , p_attribute3        => l_attribute_rec.attribute3
    , p_attribute4        => l_attribute_rec.attribute4
    , p_attribute5        => l_attribute_rec.attribute5
    , p_attribute6        => l_attribute_rec.attribute6
    , p_attribute7        => l_attribute_rec.attribute7
    , p_attribute8        => l_attribute_rec.attribute8
    , p_attribute9        => l_attribute_rec.attribute9
    , p_attribute10       => l_attribute_rec.attribute10
    , p_attribute11       => l_attribute_rec.attribute11
    , p_attribute12       => l_attribute_rec.attribute12
    , p_attribute13       => l_attribute_rec.attribute13
    , p_attribute14       => l_attribute_rec.attribute14
    , p_attribute15       => l_attribute_rec.attribute15
    , p_global_attribute_category    => l_global_attribute_rec.global_attribute_category
    , p_global_attribute1 => l_global_attribute_rec.global_attribute1
    , p_global_attribute2 => l_global_attribute_rec.global_attribute2
    , p_global_attribute3 => l_global_attribute_rec.global_attribute3
    , p_global_attribute4 => l_global_attribute_rec.global_attribute4
    , p_global_attribute5 => l_global_attribute_rec.global_attribute5
    , p_global_attribute6 => l_global_attribute_rec.global_attribute6
    , p_global_attribute7 => l_global_attribute_rec.global_attribute7
    , p_global_attribute8 => l_global_attribute_rec.global_attribute8
    , p_global_attribute9 => l_global_attribute_rec.global_attribute9
    , p_global_attribute10 =>l_global_attribute_rec.global_attribute10
    , p_global_attribute11 =>l_global_attribute_rec.global_attribute11
    , p_global_attribute12 =>l_global_attribute_rec.global_attribute12
    , p_global_attribute13 =>l_global_attribute_rec.global_attribute13
    , p_global_attribute14 =>l_global_attribute_rec.global_attribute14
    , p_global_attribute15 =>l_global_attribute_rec.global_attribute15
    , p_global_attribute16 =>l_global_attribute_rec.global_attribute16
    , p_global_attribute17 =>l_global_attribute_rec.global_attribute17
    , p_global_attribute18 =>l_global_attribute_rec.global_attribute18
    , p_global_attribute19 =>l_global_attribute_rec.global_attribute19
    , p_global_attribute20 =>l_global_attribute_rec.global_attribute20
    , p_module_name		=> 'ARXRWAPP'
    , p_module_version 	=> '1.0'
    , p_payment_set_id         => l_payment_set_id
	-- *** OUT NOCOPY
    , x_application_ref_id     => l_new_app_ref_id
    , x_application_ref_num    => l_new_app_ref_num
    , x_return_status          => l_return_status
    , x_msg_count              => l_msg_count
    , x_msg_data               => l_msg_data
    , p_out_rec_application_id => l_new_application_id
    , p_application_ref_reason => l_application_ref_reason
    , p_customer_reference     => l_customer_reference
    , x_claim_reason_name      => l_claim_reason_name
    , p_called_from	       => 'TRADE_MANAGEMENT'
	);
    IF l_return_status = 'E'
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = 'U'
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_chargeback: ' || 'After Inserting Claim Application (-)');
    END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('arp_chargeback_cover.create_chargeback()-');
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Chargeback;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('create_chargeback: ' || 'Unexpected error '||sqlerrm||
                ' at arp_chargeback_cover.create_chargeback()+');
                END IF;
		ROLLBACK TO Create_Chargeback;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_standard.debug('create_chargeback: ' || '20001 error '||
                    ' at arp_chargeback_cover.create_chargeback()+');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_standard.debug('create_chargeback: ' || 'Unexpected error '||sqlerrm||
                    ' at arp_chargeback_cover.create_chargeback()+');
                  END IF;
		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		  IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		  END IF;
		END IF;
	  	ROLLBACK TO Create_Chargeback;
		FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);

END create_chargeback;

END ARP_CHARGEBACK_COVER;

/
