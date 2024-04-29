--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_APPLICATION2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_APPLICATION2" AS
/* $Header: ARCEAP2B.pls 120.12 2006/09/18 12:48:01 balkumar ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 120.12 $';
END revision;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |      update_application                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |	This procedure is used to update an application, e.g. USSGL          |
 |      Transaction Code, Cross Currency Rate etc.  Columns that can be      |
 |      modified without having to reverse the original rows and create      |
 |      new ones.  We simply update the APP row with the new value.          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 | 07/29/1997	Karen Lawrance	Release 11.				     |
 | 				Added trans_to_receipt_rate to update call   |
 |				for cross currency.                          |
 |                              Also included acctd amount applied to and    |
 |                              from as OUT NOCOPY parameters.  These are used to   |
 |                              update the form with accurate values.        |
 | 08/21/1997	Tasman Tang	Added global_attribute_category,	     |
 |				global_attribute[1-20] for global 	     |
 |				descriptive flexfield			     |
 | 05/24/1999   Debbie Jancis   Bug fix 874714                               |
 |                              update_application should not update anything|
 |                              having to do with amount columns because     |
 |                              amount columns affect posting. Also,         |
 |                              apply_date or gl_date                        |
 | 06/06/2001  S.Nambiar        Bug 1815528 - Added claim related parameters |
 | 07/31/2001  jbeckett         Bug 1905659 - For invoice related claim, pass|
 |                              trx info to create_claim                     |
 | 08/03/2001  jbeckett    	Bug 1905659 - Added parameter                |
 |                              p_amount_due_remaining                       |
 | 08/10/2001  S.Nambiar        Migrated chargeback_customer_trx_id to       |
 |                              secondary_application_ref_id
 | 03/15/2002  jbeckett         Added new parameters p_application_ref_reason|
 |                              and p_customer_reference (bug 2254777).      |
 | 05/09/2002  jbeckett         Passes primary_salesrep_id to create_claim   |
 |                              for invoice related deductions               |
 | 02/20/2002  jbeckett         Bug 2751910 - Added p_customer_reason and    |
 |                              p_applied_rec_app_id to update_application   |
 | 10/25/2005  jbeckett         Bug 4565758 - legal_entity_id passed to      |
 |				create_claim.
 +===========================================================================*/

PROCEDURE update_application(
        p_ra_id                        IN  NUMBER,
        p_receipt_ps_id                IN  NUMBER,
        p_invoice_ps_id                IN  NUMBER,
        p_ussgl_transaction_code       IN  VARCHAR2,
        p_application_ref_type IN
                ar_receivable_applications.application_ref_type%TYPE,
        p_application_ref_id IN
                ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN
                ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN
                ar_receivable_applications.secondary_application_ref_id%TYPE,
        p_receivable_trx_id            IN  ar_receivable_applications.receivables_trx_id%TYPE,
        p_attribute_category           IN  VARCHAR2,
        p_attribute1                   IN  VARCHAR2,
        p_attribute2                   IN  VARCHAR2,
        p_attribute3                   IN  VARCHAR2,
        p_attribute4                   IN  VARCHAR2,
        p_attribute5                   IN  VARCHAR2,
        p_attribute6                   IN  VARCHAR2,
        p_attribute7                   IN  VARCHAR2,
        p_attribute8                   IN  VARCHAR2,
        p_attribute9                   IN  VARCHAR2,
        p_attribute10                  IN  VARCHAR2,
        p_attribute11                  IN  VARCHAR2,
        p_attribute12                  IN  VARCHAR2,
        p_attribute13                  IN  VARCHAR2,
        p_attribute14                  IN  VARCHAR2,
        p_attribute15                  IN  VARCHAR2,
        p_global_attribute_category    IN  VARCHAR2,
        p_global_attribute1            IN  VARCHAR2,
        p_global_attribute2            IN  VARCHAR2,
        p_global_attribute3            IN  VARCHAR2,
        p_global_attribute4            IN  VARCHAR2,
        p_global_attribute5            IN  VARCHAR2,
        p_global_attribute6            IN  VARCHAR2,
        p_global_attribute7            IN  VARCHAR2,
        p_global_attribute8            IN  VARCHAR2,
        p_global_attribute9            IN  VARCHAR2,
        p_global_attribute10           IN  VARCHAR2,
        p_global_attribute11           IN  VARCHAR2,
        p_global_attribute12           IN  VARCHAR2,
        p_global_attribute13           IN  VARCHAR2,
        p_global_attribute14           IN  VARCHAR2,
        p_global_attribute15           IN  VARCHAR2,
        p_global_attribute16           IN  VARCHAR2,
        p_global_attribute17           IN  VARCHAR2,
        p_global_attribute18           IN  VARCHAR2,
        p_global_attribute19           IN  VARCHAR2,
        p_global_attribute20           IN  VARCHAR2,
	p_comments		       IN  VARCHAR2,  -- Added for bug 1839744
        p_gl_date                      OUT NOCOPY DATE,
        p_customer_trx_line_id         IN  NUMBER,
        p_module_name                  IN  VARCHAR2,
        p_module_version               IN  VARCHAR2,
        x_application_ref_id           OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
        x_application_ref_num          OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_acctd_amount_applied_to      OUT NOCOPY NUMBER,
        p_acctd_amount_applied_from    OUT NOCOPY NUMBER,
        p_amount_due_remaining         IN  ar_payment_schedules.amount_due_remaining%TYPE,
        p_application_ref_reason       IN  ar_receivable_applications.application_ref_reason%TYPE,
        p_customer_reference           IN  ar_receivable_applications.customer_reference%TYPE,
        p_customer_reason              IN  ar_receivable_applications.customer_reason%TYPE,
        p_applied_rec_app_id           IN  ar_receivable_applications.applied_rec_app_id%TYPE,
        x_claim_reason_name            OUT NOCOPY VARCHAR2) IS

l_rec_ra_rec            ar_receivable_applications%ROWTYPE;
l_currency_code         ar_cash_receipts.currency_code%TYPE;
l_exchange_rate_type    ar_cash_receipts.exchange_rate_type%TYPE;
l_exchange_rate_date    ar_cash_receipts.exchange_date%TYPE;
l_exchange_rate         ar_cash_receipts.exchange_rate%TYPE;
l_customer_id           ar_cash_receipts.pay_from_customer%TYPE;
l_bill_to_site_use_id   ar_cash_receipts.customer_site_use_id%TYPE;
l_ship_to_site_use_id   ar_cash_receipts.customer_site_use_id%TYPE;
l_receipt_number        ar_cash_receipts.receipt_number%TYPE;
l_amount_due_remaining  NUMBER;
l_claim_amount          NUMBER;
l_customer_trx_id       ra_customer_trx.customer_trx_id%TYPE;
l_trx_number            ra_customer_trx.trx_number%TYPE;
l_cust_trx_type_id      ra_cust_trx_types.cust_trx_type_id%TYPE;
l_salesrep_id           ra_customer_trx.primary_salesrep_id%TYPE;
--BUG#2750340
l_xla_ev_rec   arp_xla_events.xla_events_type;
l_legal_entity_id       ar_cash_receipts.legal_entity_id%TYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_process_application.update_application()+');
  END IF;

  IF (p_ra_id IS NULL)
    THEN
      APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.UPDATE_APPLICATION'
        , 'P_RA_ID'
        , 'NULL');

  ELSIF (p_invoice_ps_id IS NULL)
    THEN
      APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.UPDATE_APPLICATION'
        , 'p_invoice_ps_id'
        , 'NULL');

  END IF;

  -- First get the old values
  arp_app_pkg.fetch_p(p_ra_id, l_rec_ra_rec);

  p_acctd_amount_applied_to := l_rec_ra_rec.acctd_amount_applied_to;
  p_acctd_amount_applied_from := l_rec_ra_rec.acctd_amount_applied_from;

  -- The assign the passed values

  -- KML 12/04/1996
  -- Added if restriction, as p_receipt_ps_id will be null for
  -- Credit Memo Applications.

  if p_receipt_ps_id is not null then
     l_rec_ra_rec.payment_schedule_id 	:= p_receipt_ps_id;
  end if;

  l_rec_ra_rec.applied_payment_schedule_id := p_invoice_ps_id;
  l_rec_ra_rec.applied_customer_trx_line_id	:= p_customer_trx_line_id;
  l_rec_ra_rec.ussgl_transaction_code := p_ussgl_transaction_code;
  l_rec_ra_rec.attribute_category := p_attribute_category;
  l_rec_ra_rec.attribute1 := p_attribute1;
  l_rec_ra_rec.attribute2 := p_attribute2;
  l_rec_ra_rec.attribute3 := p_attribute3;
  l_rec_ra_rec.attribute4 := p_attribute4;
  l_rec_ra_rec.attribute5 := p_attribute5;
  l_rec_ra_rec.attribute6 := p_attribute6;
  l_rec_ra_rec.attribute7 := p_attribute7;
  l_rec_ra_rec.attribute8 := p_attribute8;
  l_rec_ra_rec.attribute9 := p_attribute9;
  l_rec_ra_rec.attribute10 := p_attribute10;
  l_rec_ra_rec.attribute11 := p_attribute11;
  l_rec_ra_rec.attribute12 := p_attribute12;
  l_rec_ra_rec.attribute13 := p_attribute13;
  l_rec_ra_rec.attribute14 := p_attribute14;
  l_rec_ra_rec.attribute15 := p_attribute15;
  l_rec_ra_rec.global_attribute_category := p_global_attribute_category;
  l_rec_ra_rec.global_attribute1 := p_global_attribute1;
  l_rec_ra_rec.global_attribute2 := p_global_attribute2;
  l_rec_ra_rec.global_attribute3 := p_global_attribute3;
  l_rec_ra_rec.global_attribute4 := p_global_attribute4;
  l_rec_ra_rec.global_attribute5 := p_global_attribute5;
  l_rec_ra_rec.global_attribute6 := p_global_attribute6;
  l_rec_ra_rec.global_attribute7 := p_global_attribute7;
  l_rec_ra_rec.global_attribute8 := p_global_attribute8;
  l_rec_ra_rec.global_attribute9 := p_global_attribute9;
  l_rec_ra_rec.global_attribute10 := p_global_attribute10;
  l_rec_ra_rec.global_attribute11 := p_global_attribute11;
  l_rec_ra_rec.global_attribute12 := p_global_attribute12;
  l_rec_ra_rec.global_attribute13 := p_global_attribute13;
  l_rec_ra_rec.global_attribute14 := p_global_attribute14;
  l_rec_ra_rec.global_attribute15 := p_global_attribute15;
  l_rec_ra_rec.global_attribute16 := p_global_attribute16;
  l_rec_ra_rec.global_attribute17 := p_global_attribute17;
  l_rec_ra_rec.global_attribute18 := p_global_attribute18;
  l_rec_ra_rec.global_attribute19 := p_global_attribute19;
  l_rec_ra_rec.global_attribute20 := p_global_attribute20;
  l_rec_ra_rec.comments := p_comments;  -- Added for bug 1839744
  l_rec_ra_rec.application_ref_type := p_application_ref_type;
  l_rec_ra_rec.application_ref_num := p_application_ref_num;
  l_rec_ra_rec.application_ref_id := p_application_ref_id;
  l_rec_ra_rec.secondary_application_ref_id := p_secondary_application_ref_id;
  l_rec_ra_rec.application_ref_reason := p_application_ref_reason;
  l_rec_ra_rec.customer_reference := p_customer_reference;
  l_rec_ra_rec.applied_rec_app_id := p_applied_rec_app_id;
  l_rec_ra_rec.customer_reason := p_customer_reason;

  --Bug 4131243 - set the out parameters for application_ref_num/id so
  --they are passed back correctly if claim is not created.
  x_application_ref_num := p_application_ref_num;
  x_application_ref_id := p_secondary_application_ref_id;

  --Bug 1815528 If claim type is CLAIM, then create claim

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'p_application_ref_type = '||p_application_ref_type);
     arp_standard.debug( 'p_application_ref_num = '||nvl(p_application_ref_num,'NULL'));
  END IF;
  IF (p_application_ref_type = 'CLAIM' AND
        p_application_ref_num IS NULL)
  THEN
    IF p_invoice_ps_id = -4
    -- its a non trx related claim, get all details from receipt
    THEN
     --fetch the receipt details
       SELECT  ps.cash_receipt_id
             , cr.currency_code
             , cr.exchange_rate_type
             , cr.exchange_date
             , cr.exchange_rate
             , cr.pay_from_customer
             , cr.customer_site_use_id
             , NULL
             , cr.receipt_number
  	     , cr.legal_entity_id
        INTO   l_rec_ra_rec.cash_receipt_id
             , l_currency_code
	     , l_exchange_rate_type
	     , l_exchange_rate_date
	     , l_exchange_rate
	     , l_customer_id
	     , l_bill_to_site_use_id
             , l_ship_to_site_use_id
             , l_receipt_number
             , l_legal_entity_id
        FROM   ar_payment_schedules 	ps
           , ar_cash_receipts 		cr
	   , ar_cash_receipt_history	crh
           , ar_receipt_methods 	rm
           , ce_bank_acct_uses		ba
           , ar_receipt_method_accounts rma
        WHERE  ps.payment_schedule_id 	= p_receipt_ps_id
        AND    cr.cash_receipt_id 	= ps.cash_receipt_id
        AND    crh.cash_receipt_id	= cr.cash_receipt_id
        AND    crh.current_record_flag	= 'Y'
        AND    rm.receipt_method_id 	= cr.receipt_method_id
        AND    ba.bank_acct_use_id	= cr.remit_bank_acct_use_id
        AND    rma.remit_bank_acct_use_id = ba.bank_acct_use_id
        AND    rma.receipt_method_id 	= rm.receipt_method_id;

      l_customer_trx_id := NULL;
      l_trx_number := NULL;
      l_cust_trx_type_id := NULL;
      l_salesrep_id := NULL;    -- bug 2361331

    ELSE
      -- claim is trx related, fetch invoice details
      SELECT t.invoice_currency_code
             , t.exchange_rate_type
             , t.exchange_date
             , t.exchange_rate
             , t.customer_trx_id
             , t.trx_number
             , t.cust_trx_type_id
             , t.bill_to_customer_id
             , t.bill_to_site_use_id
             , t.ship_to_site_use_id
             , p.amount_due_remaining
             , t.primary_salesrep_id
	     , t.legal_entity_id
        INTO   l_currency_code
	     , l_exchange_rate_type
	     , l_exchange_rate_date
	     , l_exchange_rate
             , l_customer_trx_id
             , l_trx_number
             , l_cust_trx_type_id
	     , l_customer_id
	     , l_bill_to_site_use_id
             , l_ship_to_site_use_id
             , l_amount_due_remaining
             , l_salesrep_id     -- bug 2361331
	     , l_legal_entity_id
        FROM   ra_customer_trx t
             , ar_payment_schedules p
        WHERE  t.customer_trx_id = p.customer_trx_id
        AND    p.payment_schedule_id = p_invoice_ps_id;

        SELECT cr.cash_receipt_id, cr.receipt_number
        INTO   l_rec_ra_rec.cash_receipt_id
             , l_receipt_number
        FROM   ar_cash_receipts cr,
               ar_payment_schedules ps
        WHERE  ps.payment_schedule_id 	= p_receipt_ps_id
        AND    cr.cash_receipt_id 	= ps.cash_receipt_id;
    END IF;

    IF p_invoice_ps_id = -4
    THEN
      l_claim_amount := l_rec_ra_rec.amount_applied;
    ELSIF
      p_amount_due_remaining IS NULL
    THEN
      l_claim_amount := l_amount_due_remaining;
    ELSE
      l_claim_amount := p_amount_due_remaining;
    END IF;

    arp_process_application.create_claim(
              p_amount               => l_claim_amount
            , p_amount_applied       => l_rec_ra_rec.amount_applied
            , p_currency_code        => l_currency_code
            , p_exchange_rate_type   => l_exchange_rate_type
            , p_exchange_rate_date   => l_exchange_rate_date
            , p_exchange_rate        => l_exchange_rate
            , p_customer_trx_id      => l_customer_trx_id
            , p_invoice_ps_id        => p_invoice_ps_id
            , p_cust_trx_type_id     => l_cust_trx_type_id
            , p_trx_number           => l_trx_number
            , p_cust_account_id      => l_customer_id
            , p_bill_to_site_id      => l_bill_to_site_use_id
            , p_ship_to_site_id      => l_ship_to_site_use_id
            , p_salesrep_id          => l_salesrep_id  -- bug 2361331
            , p_customer_ref_date    => NULL
            , p_customer_ref_number  => p_customer_reference
            , p_cash_receipt_id      => l_rec_ra_rec.cash_receipt_id
            , p_receipt_number       => l_receipt_number
            , p_customer_reason      => p_customer_reason
            , p_reason_id            => TO_NUMBER(p_application_ref_reason)
            , p_comments             => l_rec_ra_rec.comments
            , p_apply_date           => l_rec_ra_rec.apply_date --Bug5495310
            , p_attribute_category   => p_attribute_category
            , p_attribute1           => p_attribute1
            , p_attribute2           => p_attribute2
            , p_attribute3           => p_attribute3
            , p_attribute4           => p_attribute4
            , p_attribute5           => p_attribute5
            , p_attribute6           => p_attribute6
            , p_attribute7           => p_attribute7
            , p_attribute8           => p_attribute8
            , p_attribute9           => p_attribute9
            , p_attribute10          => p_attribute10
            , p_attribute11          => p_attribute11
            , p_attribute12          => p_attribute12
            , p_attribute13          => p_attribute13
            , p_attribute14          => p_attribute14
            , p_attribute15          => p_attribute15
            , x_return_status        => x_return_status
            , x_msg_count            => x_msg_count
            , x_msg_data             => x_msg_data
            , x_claim_id             => l_rec_ra_rec.secondary_application_ref_id
            , x_claim_number         => l_rec_ra_rec.application_ref_num
            , x_claim_reason_name    => x_claim_reason_name
	    , p_legal_entity_id      => l_legal_entity_id);

    x_application_ref_id  := l_rec_ra_rec.secondary_application_ref_id;
    x_application_ref_num := l_rec_ra_rec.application_ref_num;

  END IF;

  -- Dump the data into database
  arp_app_pkg.update_p(l_rec_ra_rec);
  p_gl_date := l_rec_ra_rec.gl_date;

  --BUG#2750340
  l_xla_ev_rec.xla_from_doc_id := p_ra_id;
  l_xla_ev_rec.xla_to_doc_id   := p_ra_id;
  l_xla_ev_rec.xla_doc_table   := 'APP';
  l_xla_ev_rec.xla_mode        := 'O';
  l_xla_ev_rec.xla_call        := 'B';
  ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_process_application.update_application()-');
  END IF;

EXCEPTION
  when others then
	 raise;

END update_application;

/*===========================================================================+
 | PROCEDURE
 |      delete_selected_transaction
 |
 | DESCRIPTION
 |	This procedure is used to delete an application that has been
 |      created through the automatic receipt creation process.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  : IN:
 |              p_ra_id                 Id of application to be deleted.
 |              p_app_ps_id             Payment Schedule Id of the applied
 |                                      Transaction.
 |
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 12/06/1996    Karen Lawrance    Created
 | 10/22/1997	 Karen Murphy	   Bug #567872.  Added code to update the
 |				   UNAPP row in receivable applications
 |				   when an APP row is deleted.
   12/04/1997    Karen Murphy      Bug fix #567872.  Added the setting of the
                                   acctd_amount_applied_from for the UNAPP row.
 | 24/03/1998    Vikram Ahluwalia  Plugin calls one delete for the APP record
 |                                 and a combination of delete followed by
 |                                 create for the UNAPP record accounting.
 |                                 Though this appears to be specifically
 |                                 written for Unconfirmed Autoreceipts (APP
 |                                 and UNAPP combination it patched for
 |                                 completeness - notice the confirmed flag
 |                                 check in delete cursor and create call
 +===========================================================================*/
PROCEDURE delete_selected_transaction (
          p_ra_id       IN NUMBER
        , p_app_ps_id   IN NUMBER
                                        ) IS

CURSOR get_app_C(l_app_id NUMBER) IS
       select app.receivable_application_id app_id,
              app.cash_receipt_id           cr_id
       from   ar_receivable_applications app
       where  app.receivable_application_id = l_app_id
       and    nvl(app.confirmed_flag,'Y') = 'Y'   --confirmed records have accounting only
       and exists (select 'x'
                   from  ar_distributions ard
                   where ard.source_table = 'RA'
                   and   ard.source_id    = app.receivable_application_id);

  lr_ps_rec               ar_payment_schedules%ROWTYPE;
  lr_ra_rec               ar_receivable_applications%ROWTYPE;

  ln_amount_applied       	NUMBER;
  ln_acctd_amount_applied_from  NUMBER;
  ln_cash_receipt_id      	NUMBER;
  ln_unapp_ra_id          	NUMBER;
  l_ae_doc_rec                  ae_doc_rec_type;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_process_application.delete_selected_transaction()+');
  END IF;

  -- Check that the Application Id, and the Applied Payment Schedule Id
  -- have been provided.
  IF (p_ra_id IS NULL)
  THEN
    APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.DELETE_AUTOMATIC_APPLICATION'
        , 'P_RA_ID'
        , 'NULL');
  ELSIF (p_app_ps_id IS NULL)
  THEN
    APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.DELETE_AUTOMATIC_APPLICATION'
        , 'P_APP_PS_ID'
        , 'NULL');
  END IF;

  -- Before we delete it, get the cash receipt id and amount applied
  -- for the application.
  select ra.cash_receipt_id,
         ra.amount_applied,
         ra.acctd_amount_applied_from
  into   ln_cash_receipt_id,
         ln_amount_applied,
         ln_acctd_amount_applied_from
  from   ar_receivable_applications ra
  where  ra.receivable_application_id = p_ra_id;

 --
 --Release 11.5 delete child accounting records associated with
 --parent applications for APP
 --
  FOR l_get_app_rec IN get_app_C(p_ra_id) LOOP

      l_ae_doc_rec.document_type           := 'RECEIPT';
      l_ae_doc_rec.document_id             := l_get_app_rec.cr_id;
      l_ae_doc_rec.accounting_entity_level := 'ONE';
      l_ae_doc_rec.source_table            := 'RA';
      l_ae_doc_rec.source_id               := l_get_app_rec.app_id;  --same as p_ra_id
      l_ae_doc_rec.source_id_old           := '';
      l_ae_doc_rec.other_flag              := '';
      arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);

  END LOOP;

  -- Delete Receivable Application record.
  arp_app_pkg.delete_p(p_ra_id);

   /*---------------------------------+
   | Calling central MRC library      |
   | for MRC Integration              |
   +---------------------------------*/

   ar_mrc_engine.maintain_mrc_data(
             p_event_mode        => 'DELETE',
             p_table_name        => 'AR_RECEIVABLE_APPLICATIONS',
             p_mode              => 'SINGLE',
             p_key_value         => p_ra_id);

  --Bug#2750340
  ARP_XLA_EVENTS.delete_event
   ( p_document_id  => p_ra_id,
     p_doc_table    => 'APP');

  --   Populate the Payment Schedule record from ar_payment_schedules,
  --   based on the provided Applied_Payment_Schedule_Id.
  arp_ps_pkg.fetch_p( p_app_ps_id, lr_ps_rec );

  -- Update the Transaction's Payment Schedule, set flag "Selected for
  -- Receipt Batch Id" to null, allowing it to be selected again for
  -- automatic payment.
  lr_ps_rec.selected_for_receipt_batch_id := null;

  arp_ps_pkg.update_p(lr_ps_rec, p_app_ps_id);

  ----------------------------------------------------------------
  -- Now that we have deleted the application and updated the
  -- payment schedule, update the UNAPP row for the cash receipt.
  -- Amount applied needs to be reduced by the amount that was
  -- deleted.
  ----------------------------------------------------------------

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_selected_transaction: ' || 'Getting the Receivable Application Id for the UNAPP row');
  END IF;
  -- Get the receivable application id for the UNAPP row.
  select ra.receivable_application_id
  into   ln_unapp_ra_id
  from   ar_receivable_applications ra
  where  ra.cash_receipt_id = ln_cash_receipt_id
  and    ra.status = 'UNAPP';

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_selected_transaction: ' || 'Fetch the UNAPP row');
  END IF;
  -- Fetch the UNAPP row.
  arp_app_pkg.fetch_p( ln_unapp_ra_id, lr_ra_rec );

  -- Set the amount with the new value.
  lr_ra_rec.amount_applied := lr_ra_rec.amount_applied - ln_amount_applied;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_selected_transaction: ' || 'New UNAPP amount: ' || to_char(lr_ra_rec.amount_applied));
  END IF;

  -- Set the acctd amount with the new value.
  lr_ra_rec.acctd_amount_applied_from :=  lr_ra_rec.acctd_amount_applied_from - ln_acctd_amount_applied_from;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_selected_transaction: ' || 'Update the UNAPP row');
  END IF;
   --
 --Release 11.5 delete child accounting records associated with
 --parent applications UNAPP record as update is a combination
 --of delete for by create
 --
  FOR l_get_app_rec IN get_app_C(lr_ra_rec.receivable_application_id) LOOP

      l_ae_doc_rec.document_type           := 'RECEIPT';
      l_ae_doc_rec.document_id             := l_get_app_rec.cr_id;
      l_ae_doc_rec.accounting_entity_level := 'ONE';
      l_ae_doc_rec.source_table            := 'RA';
      l_ae_doc_rec.source_id               := l_get_app_rec.app_id;
      l_ae_doc_rec.source_id_old           := '';
      l_ae_doc_rec.other_flag              := '';
      arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);

  END LOOP;

  -- Update the UNAPP row.
  arp_app_pkg.update_p(lr_ra_rec);

 --
 --Release 11.5 create accounting associated with UNAPP row
 --This is standalone and not paired with an APP
 --
  IF NVL(lr_ra_rec.confirmed_flag,'Y') = 'Y' THEN
     l_ae_doc_rec.document_type           := 'RECEIPT';
     l_ae_doc_rec.document_id             := lr_ra_rec.cash_receipt_id;
     l_ae_doc_rec.accounting_entity_level := 'ONE';
     l_ae_doc_rec.source_table            := 'RA';
     l_ae_doc_rec.source_id               := lr_ra_rec.receivable_application_id;
     l_ae_doc_rec.source_id_old           := '';
     l_ae_doc_rec.other_flag              := '';
     arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_selected_transaction: ' ||  'arp_process_application.delete_receivable_application()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('delete_selected_transaction: ' || '-- EXCEPTION:');
       arp_standard.debug('delete_selected_transaction: ' || 'Printing procedure parameter values:');
       arp_standard.debug('delete_selected_transaction: ' || '-- p_ra_id = '||TO_CHAR(p_ra_id));
       arp_standard.debug('delete_selected_transaction: ' || '-- p_app_ps_id = '||TO_CHAR(p_app_ps_id));
    END IF;
    app_exception.raise_exception;
END delete_selected_transaction;

END arp_process_application2;

/
