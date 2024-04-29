--------------------------------------------------------
--  DDL for Package Body ARP_PROC_RECEIPTS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROC_RECEIPTS2" AS
/* $Header: ARRERG2B.pls 120.16.12010000.6 2010/06/19 07:58:33 vpusulur ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/* ---------------------- Public functions -------------------------------- */


FUNCTION revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.16.12010000.6 $';

END revision;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_cash_receipt                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Function inserts a cash receipt into the database.  This entity 	     |
 |    handler is called from the Receipts Gateway form and creates records   |
 |    in the following tables:						     |
 |       AR_CASH_RECEIPTS						     |
 |       AR_CASH_RECEIPT_HISTORY					     |
 |	 AR_DISTRIBUTIONS						     |
 |       AR_RECEIVABLE_APPLICATIONS					     |
 |       AR_PAYMENT_SCHEDULES						     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    08-SEP-95	 OSTEINME	created					     |
 |    01-NOV-96  OSTEINME	added parameter anticipated_clearing_date    |
 |				for CashBook enhancement (float support)     |
 |    				Added parameters for Japan enhancements:     |
 |				  - customer_bank_branch_id		     |
 |				as well as logic to handle these properly    |
 |    04-NOV-96	 OSTEINME	changed call to get_ra_ccid to take new      |
 |				parameters.  Also changed procedure name     |
 |				to get_ccids to better reflect purpose of    |
 |				of procedure.			             |
 |    30-DEC-96	 OSTEINME	added global flexfield parameters            |
 |    04-DEC-97  KLAWRANC       Bug #590256.  Modified calls to              |
 |                              calc_acctd_amount.  Now passes NULL for the  |
 |                              currency code parameter, therefore the acctd |
 |                              amount will be calculated based on the       |
 |                              functional currency.                         |
 |    21-MAY-98  KTANG		For all calls to calc_acctd_amount which     |
 |                              calculates header accounted amounts, if the  |
 |                              exchange_rate_type is not user, call         |
 |                              gl_currency_api.convert_amount instead. This |
 |                              is for triangulation.                        |
 |    29-JUL-98  K.Murphy       Bug #667450.  Modified calculation of the    |
 |                              accounted factor discount amount.            |
 |                                                                           |
 |  14-APR-2000 Jani Rautiainen Added parameter p_called_from. This is needed|
 |                              inthe logic to decide whether first UNAPP row|
 |                              is postable or not. In BR scenario when an   |
 |                              Activity Application of Short Term Debt is   |
 |                              created the UNAPP rows are not postable.     |
 |                              This is an user requirement for BR.          |
 |                              The parameter is defaulted to NULL so no     |
 |                              impact for the existing functionality.       |
 |                              Also added logic to prevent accounting       |
 |                              creation if the row is not postable.         |
 |  01-May-2002 Debbie Jancis   Modified for Enhancement 2074220. Added      |
 |                              application_notes.                           |
 |  05-May-2005 Debbie Jancis   Added Legal Entity Id for LE R12 project     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE insert_cash_receipt(
	p_currency_code		IN VARCHAR2,
	p_amount		IN NUMBER,
	p_pay_from_customer	IN NUMBER,
	p_receipt_number	IN VARCHAR2,
	p_receipt_date		IN DATE,
	p_gl_date		IN DATE,
	p_maturity_date		IN DATE,
	p_comments		IN VARCHAR2,
	p_exchange_rate_type	IN VARCHAR2,
	p_exchange_rate		IN NUMBER,
	p_exchange_date		IN DATE,
	p_batch_id		IN NUMBER,
	p_attribute_category	IN VARCHAR2,
	p_attribute1		IN VARCHAR2,
	p_attribute2		IN VARCHAR2,
	p_attribute3		IN VARCHAR2,
	p_attribute4		IN VARCHAR2,
	p_attribute5		IN VARCHAR2,
	p_attribute6		IN VARCHAR2,
	p_attribute7		IN VARCHAR2,
	p_attribute8		IN VARCHAR2,
	p_attribute9		IN VARCHAR2,
	p_attribute10		IN VARCHAR2,
	p_attribute11		IN VARCHAR2,
	p_attribute12		IN VARCHAR2,
	p_attribute13		IN VARCHAR2,
	p_attribute14		IN VARCHAR2,
	p_attribute15		IN VARCHAR2,
	p_override_remit_account_flag IN VARCHAR2,
	p_remittance_bank_account_id  IN NUMBER,
        p_customer_bank_account_id    IN NUMBER,
	p_customer_site_use_id	      IN NUMBER,
	p_customer_receipt_reference  IN VARCHAR2,
	p_factor_discount_amount      IN NUMBER,
	p_deposit_date		      IN DATE,
	p_receipt_method_id	      IN NUMBER,
	p_doc_sequence_value	      IN NUMBER,
	p_doc_sequence_id	      IN NUMBER,
	p_ussgl_transaction_code      IN VARCHAR2,
	p_vat_tax_id		      IN NUMBER,
	p_anticipated_clearing_date   IN DATE,
        p_customer_bank_branch_id     IN NUMBER,
 -- ARTA Changes
        p_postmark_date               IN DATE,
--
-- ******* Global Flexfield parameters *******
--
	p_global_attribute1		IN VARCHAR2,
	p_global_attribute2		IN VARCHAR2,
	p_global_attribute3		IN VARCHAR2,
	p_global_attribute4		IN VARCHAR2,
	p_global_attribute5		IN VARCHAR2,
	p_global_attribute6		IN VARCHAR2,
	p_global_attribute7		IN VARCHAR2,
	p_global_attribute8		IN VARCHAR2,
	p_global_attribute9		IN VARCHAR2,
	p_global_attribute10		IN VARCHAR2,
	p_global_attribute11		IN VARCHAR2,
	p_global_attribute12		IN VARCHAR2,
	p_global_attribute13		IN VARCHAR2,
	p_global_attribute14		IN VARCHAR2,
	p_global_attribute15		IN VARCHAR2,
	p_global_attribute16		IN VARCHAR2,
	p_global_attribute17		IN VARCHAR2,
	p_global_attribute18		IN VARCHAR2,
	p_global_attribute19		IN VARCHAR2,
	p_global_attribute20		IN VARCHAR2,
	p_global_attribute_category	IN VARCHAR2,
--
--      ***  Notes Receivable Additional Information
--
        p_issuer_name			IN VARCHAR2,
        p_issue_date			IN DATE,
	p_issuer_bank_branch_id		IN NUMBER,
--
--      *** enhancement 2074220 ***
        p_application_notes             IN VARCHAR2,
--
	p_cr_id			        OUT NOCOPY NUMBER,
	p_ps_id			        OUT NOCOPY NUMBER,
	p_row_id		        OUT NOCOPY VARCHAR2,
--
	p_form_name		        IN varchar2,
	p_form_version		        IN varchar2,
	p_called_from                   IN VARCHAR2 DEFAULT NULL, /* BR */
        p_le_id                         IN NUMBER DEFAULT NULL, /* LE */
	p_payment_trxn_extension_id    IN NUMBER  DEFAULT NULL, /* payment uptake */
        p_automatch_set_id             IN NUMBER  DEFAULT NULL, /* ER Automatch Application */
        p_autoapply_flag               IN VARCHAR2  DEFAULT NULL

		) IS
l_cr_rec	ar_cash_receipts%ROWTYPE;
l_crh_rec	ar_cash_receipt_history%ROWTYPE;
l_cr_id		ar_cash_receipts.cash_receipt_id%TYPE;
l_ps_id		ar_payment_schedules.payment_schedule_id%TYPE;
l_ccid		ar_cash_receipt_history.account_code_combination_id%TYPE;
l_ra_ccid	ar_receivable_applications.code_combination_id%TYPE;
l_ra_unid_ccid	ar_receivable_applications.code_combination_id%TYPE;
l_ra_unapp_ccid	ar_receivable_applications.code_combination_id%TYPE;
l_source_type	ar_distributions.source_type%TYPE;
l_override_dummy
		ar_receipt_method_accounts.override_remit_account_flag%TYPE;
l_creation_status ar_cash_receipt_history.status%TYPE;
l_status	ar_cash_receipts.status%TYPE;
l_crh_amount 		ar_cash_receipt_history.amount%TYPE;
l_cr_acctd_amount	ar_payment_schedules.acctd_amount_due_remaining%TYPE;
l_crh_acctd_amount  	ar_cash_receipt_history.amount%TYPE;
l_acctd_factor_discount_amount ar_cash_receipt_history.acctd_factor_discount_amount%TYPE;
l_bank_charges_ccid	ar_cash_receipt_history.bank_charge_account_ccid%TYPE;
l_application_rule  	ar_receivable_applications.application_rule%TYPE;
l_called_from_api       varchar2(1);

l_dummy		NUMBER;
l_id_dummy	NUMBER;
l_ra_id         ar_receivable_applications.receivable_application_id%TYPE;
l_ae_doc_rec    ae_doc_rec_type;

BEGIN


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.insert_cash_receipt()+');
  END IF;

  -- determine creation state (approved, confirmed, remitted, cleared)
  -- of receipt based on payment method, as well as code combination
  -- id.

  arp_cr_util.get_creation_info(p_receipt_method_id,
				p_remittance_bank_account_id,
	      			l_creation_status,
				l_source_type,
				l_ccid,
				l_override_dummy);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('insert_cash_receipt: ' || 'Creation status = ' || l_creation_status);
     arp_standard.debug('insert_cash_receipt: ' || 'Source Type     = ' || l_source_type);
     arp_standard.debug('insert_cash_receipt: ' || 'ccid            = ' || l_ccid);
  END IF;

  -- create ar_cash_receipt record:

  -- first determine if receipt is unidentified or unapplied

  IF (p_pay_from_customer IS NULL) THEN
    l_status := 'UNID';
  ELSE
    l_status := 'UNAPP';
  END IF;

  -- determine receivable application ccid:

  arp_proc_rct_util.get_ccids(
		p_receipt_method_id,
		p_remittance_bank_account_id,
		l_ra_unid_ccid,
		l_ra_unapp_ccid,
		l_id_dummy,
		l_id_dummy,
		l_id_dummy,
		l_bank_charges_ccid,
		l_id_dummy,
		l_id_dummy,
		l_id_dummy,
		l_id_dummy);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('insert_cash_receipt: ' || 'status	      = ' || l_status);
     arp_standard.debug('insert_cash_receipt: ' || 'l_ra_unid_ccid	      = ' || l_ra_unid_ccid);
     arp_standard.debug('insert_cash_receipt: ' || 'l_ra_unapp_ccid	      = ' || l_ra_unapp_ccid);
     arp_standard.debug('insert_cash_receipt: ' || 'l_bank_charges_ccid      = ' || l_bank_charges_ccid);
  END IF;

  l_cr_rec.amount 		:= p_amount;
  l_cr_rec.currency_code	:= p_currency_code;
  l_cr_rec.pay_from_customer	:= p_pay_from_customer;
  l_cr_rec.status 		:= l_status;
  l_cr_rec.type 		:= 'CASH';
  l_cr_rec.receipt_number	:= p_receipt_number;
  l_cr_rec.receipt_date		:= p_receipt_date;
  l_cr_rec.comments 		:= p_comments;
  l_cr_rec.exchange_rate_type	:= p_exchange_rate_type;
  l_cr_rec.exchange_rate	:= p_exchange_rate;
  l_cr_rec.exchange_date	:= p_exchange_date;
  l_cr_rec.attribute_category	:= p_attribute_category;
  l_cr_rec.attribute1 		:= p_attribute1;
  l_cr_rec.attribute2 		:= p_attribute2;
  l_cr_rec.attribute3 		:= p_attribute3;
  l_cr_rec.attribute4 		:= p_attribute4;
  l_cr_rec.attribute5 		:= p_attribute5;
  l_cr_rec.attribute6 		:= p_attribute6;
  l_cr_rec.attribute7 		:= p_attribute7;
  l_cr_rec.attribute8 		:= p_attribute8;
  l_cr_rec.attribute9 		:= p_attribute9;
  l_cr_rec.attribute10 		:= p_attribute10;
  l_cr_rec.attribute11 		:= p_attribute11;
  l_cr_rec.attribute12 		:= p_attribute12;
  l_cr_rec.attribute13 		:= p_attribute13;
  l_cr_rec.attribute14 		:= p_attribute14;
  l_cr_rec.attribute15 		:= p_attribute15;
  l_cr_rec.override_remit_account_flag := p_override_remit_account_flag;
  l_cr_rec.remit_bank_acct_use_id	:= p_remittance_bank_account_id;
  l_cr_rec.confirmed_flag	:= 'Y';
  l_cr_rec.customer_bank_account_id     := p_customer_bank_account_id;
  l_cr_rec.customer_site_use_id	:= p_customer_site_use_id;
  l_cr_rec.deposit_date		:= p_deposit_date;
  l_cr_rec.receipt_method_id	:= p_receipt_method_id;
  l_cr_rec.doc_sequence_value	:= p_doc_sequence_value;
  l_cr_rec.doc_sequence_id	:= p_doc_sequence_id;
  l_cr_rec.ussgl_transaction_code := p_ussgl_transaction_code;
  l_cr_rec.factor_discount_amount := 0;
  l_cr_rec.customer_receipt_reference := p_customer_receipt_reference;
  l_cr_rec.vat_tax_id	:= p_vat_tax_id;
  l_cr_rec.anticipated_clearing_date := p_anticipated_clearing_date;
  l_cr_rec.customer_bank_branch_id := p_customer_bank_branch_id;

  l_cr_rec.global_attribute1	:= p_global_attribute1;
  l_cr_rec.global_attribute2	:= p_global_attribute2;
  l_cr_rec.global_attribute3	:= p_global_attribute3;
  l_cr_rec.global_attribute4	:= p_global_attribute4;
  l_cr_rec.global_attribute5	:= p_global_attribute5;
  l_cr_rec.global_attribute6	:= p_global_attribute6;
  l_cr_rec.global_attribute7	:= p_global_attribute7;
  l_cr_rec.global_attribute8	:= p_global_attribute8;
  l_cr_rec.global_attribute9	:= p_global_attribute9;
  l_cr_rec.global_attribute10	:= p_global_attribute10;
  l_cr_rec.global_attribute11	:= p_global_attribute11;
  l_cr_rec.global_attribute12	:= p_global_attribute12;
  l_cr_rec.global_attribute13	:= p_global_attribute13;
  l_cr_rec.global_attribute14	:= p_global_attribute14;
  l_cr_rec.global_attribute15	:= p_global_attribute15;
  l_cr_rec.global_attribute16	:= p_global_attribute16;
  l_cr_rec.global_attribute17	:= p_global_attribute17;
  l_cr_rec.global_attribute18	:= p_global_attribute18;
  l_cr_rec.global_attribute19	:= p_global_attribute19;
  l_cr_rec.global_attribute20	:= p_global_attribute20;
  l_cr_rec.global_attribute_category	:= p_global_attribute_category;

--
--  Notes Receivable Additional Information
--

  l_cr_rec.issuer_name           := p_issuer_name;
  l_cr_rec.issue_date            := p_issue_date;
  l_cr_rec.issuer_bank_branch_id := p_issuer_bank_branch_id;

-- ARTA Changes
  l_cr_rec.postmark_date        := p_postmark_date;

  -- enhancment 2074220
  l_cr_rec.application_notes    := p_application_notes;

  --  Legal Entity project
  l_cr_rec.legal_entity_id      := p_le_id;

  l_cr_rec.payment_trxn_extension_id	:= p_payment_trxn_extension_id; /* bichatte payment uptake */
  l_cr_rec.automatch_set_id             := p_automatch_set_id; /* ER Automatch Application */
  l_cr_rec.autoapply_flag               := p_autoapply_flag;
  arp_cash_receipts_pkg.insert_p(l_cr_rec);

  -- determine the amount for the cash receipt history record:
  --
  -- crh.amount := cr.amount - p_factor_discount_amount

  l_crh_amount := l_cr_rec.amount - NVL(p_factor_discount_amount,0);

  -- determine accounted amount for history record:
  -- Changes for triangulation: If exchange rate type is not user, call
  -- GL API to calculate accounted amount
  IF (p_exchange_rate_type = 'User') THEN
    arp_util.calc_acctd_amount( NULL,
				NULL,
				NULL,
				l_cr_rec.exchange_rate,
				'+',
				l_crh_amount,
				l_crh_acctd_amount,
				0,
				l_dummy,
				l_dummy,
				l_dummy);
  ELSE
    l_crh_acctd_amount := gl_currency_api.convert_amount(
				arp_global.set_of_books_id,
				l_cr_rec.currency_code,
				l_cr_rec.exchange_date,
				l_cr_rec.exchange_rate_type,
				l_crh_amount);
  END IF;

  -- Need to work out NOCOPY acctd factor discount amount value.
  --
  -- The correct definition for the acctd factor discount amount is:
  --
  -- acctd factor discount amount := acctd cr amount -
  --                                 acctd crh amount
  --
  -- Firstly, need to calculate the acctd cr amount.  If the rate type
  -- is not "User", call the GL API to get the triangulated value.

  IF (p_exchange_rate_type = 'User') THEN

    arp_util.calc_acctd_amount( NULL,
                                NULL,
                                NULL,
                                l_cr_rec.exchange_rate,
                                '+',
                                l_cr_rec.amount,
                                l_cr_acctd_amount,
                                0,
                                l_dummy,
                                l_dummy,
                                l_dummy);

  ELSE

    l_cr_acctd_amount := gl_currency_api.convert_amount(
				arp_global.set_of_books_id,
                                l_cr_rec.currency_code,
                                l_cr_rec.exchange_date,
                                l_cr_rec.exchange_rate_type,
                                l_cr_rec.amount);
  END IF;

  -- Now calculate the acctd fda amount.  Note that for the
  -- cases where the rate type is not "User", this is
  -- calculated using all triangulated values, i.e. both
  -- l_cr_acctd_amount and l_crh_acctd_amount are
  -- triangulated values.

  l_acctd_factor_discount_amount := l_cr_acctd_amount -
                                      l_crh_acctd_amount;

  -- create related cash receipt history record

  arp_proc_rct_util.insert_crh_rec(
			l_cr_rec,
			l_crh_amount,
			l_crh_acctd_amount,
			p_factor_discount_amount,
			l_acctd_factor_discount_amount,
			p_gl_date,
			l_creation_status,
			p_batch_id,
			l_ccid,
			l_bank_charges_ccid,
			l_crh_rec,
			p_called_from);


  -- create related payment schedule record

  arp_proc_rct_util.insert_ps_rec_cash(
			l_cr_rec,
			p_gl_date,
			nvl(p_maturity_date, p_deposit_date),
			l_cr_acctd_amount,
			l_ps_id);

   --apandit
   --Bug 2641517 : Raise the Receipt Creation  business event.
   -- Bug 4147586, Raising BE always.
     AR_BUS_EVENT_COVER.Raise_Rcpt_Creation_Event(l_ps_id);


  -- create related receivable applications record

  IF (l_cr_rec.status = 'UNID') THEN
    l_application_rule		:= '60.1';
    l_ra_ccid			:= l_ra_unid_ccid;
  ELSE
    l_application_rule		:= '60.2';
    l_ra_ccid			:= l_ra_unapp_ccid;
  END IF;

  arp_proc_rct_util.insert_ra_rec_cash(
			l_cr_rec.cash_receipt_id,
			l_cr_rec.amount,
			l_cr_rec.receipt_date,
			l_cr_rec.status,
			l_cr_acctd_amount,
			p_gl_date,
			l_ra_ccid,
			l_ps_id,
			l_application_rule,
                        '',
                        l_ra_id,
                        p_called_from); -- jrautiai BR project

  /* 14-APR-2000
   * In this BR specific situation the first UNAPP row created is not POSTABLE so no accounting created.
   * See procedure description for more information */


  IF nvl(p_called_from,'NONE') NOT IN ('BR_FACTORED_WITH_RECOURSE', 'AUTORECAPI') THEN --
    --
    --Release 11.5 VAT changes, create UNID receivable application accounting
    --in ar_distributions
    --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := l_cr_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_id;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';

    arp_acct_main.Create_Acct_Entry(p_ae_doc_rec => l_ae_doc_rec ,
				    p_called_from  => p_called_from);

  END IF;

  -- create distributions record(s)

IF nvl(p_called_from,'NONE') <> 'AUTORECAPI' THEN  -- bichatte autorecapi changes
  arp_proc_rct_util.insert_dist_rec(
			l_crh_rec.amount,
			l_crh_acctd_amount,
			l_crh_rec.cash_receipt_history_id,
			l_source_type,
			l_ccid,
			p_called_from);
END IF;  -- bichatte autorecapi

  IF (NVL(p_factor_discount_amount,0) > 0 ) THEN

    -- if bank charges exist, create distribution record
    -- for them:

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('insert_cash_receipt: ' || 'Before creating distribution for bank charges:');
       arp_standard.debug('insert_cash_receipt: ' || 'p_factor_discount_amount = ' ||
			to_char(p_factor_discount_amount));
       arp_standard.debug('insert_cash_receipt: ' || 'l_acctd_factor_discount_amount = ' ||
			to_char(l_acctd_factor_discount_amount));
       arp_standard.debug('insert_cash_receipt: ' || 'l_crh_rec.cash_receipt_history_id = ' ||
			to_char(l_crh_rec.cash_receipt_history_id));
       arp_standard.debug('insert_cash_receipt: ' || 'l_bank_charges_ccid = ' ||
			to_char(l_bank_charges_ccid));
    END IF;

    arp_proc_rct_util.insert_dist_rec(
			p_factor_discount_amount,
			l_acctd_factor_discount_amount,
			l_crh_rec.cash_receipt_history_id,
			'BANK_CHARGES',
			l_bank_charges_ccid,
			p_called_from);
  END IF;

  /* Bug 4910860: Check if the journals are balanced */
  IF p_form_name = 'RAPI' THEN
     l_called_from_api := 'Y';
  ELSE
     l_called_from_api := 'N';
  END IF;

  /*Bug 5017553 check for balance if the call is not from BR*/
  IF NVL(p_called_from,'NONE') not in ('BR_REMITTED','BR_FACTORED_WITH_RECOURSE','BR_FACTORED_WITHOUT_RECOURSE', 'AUTORECAPI','AUTORECAPI2') THEN
    arp_balance_check.Check_Recp_Balance(l_cr_rec.cash_receipt_id,NULL,l_called_from_api);
  END IF;

  -- copy cash_receipt_id into return variable:

  p_cr_id := l_cr_rec.cash_receipt_id;
  p_ps_id := l_ps_id;

  -- update batch status

  IF (p_batch_id IS NOT NULL) THEN
    arp_rw_batches_check_pkg.update_batch_status(
		p_batch_id);
  END IF;

  -- get the ROWID out NOCOPY parameter:

  SELECT rowid
  INTO   p_row_id
  FROM   ar_cash_receipts
  WHERE  cash_receipt_id = l_cr_rec.cash_receipt_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.insert_cash_receipt()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Exception in insert_cash_receipt');
      END IF;
      RAISE;

END insert_cash_receipt;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    remit_cash_receipt                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This entity handler is created for remitting a confirmed receipt.	     |
 |    Review this routine if you are planing to use it for anyother purpose  |
 |       AR_CASH_RECEIPT_HISTORY					     |
 |	 AR_DISTRIBUTIONS						     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    19-Mar-02	 S.Nambiar	created					     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE remit_cash_receipt(
	p_cash_receipt_id		IN NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2
        ) IS

l_cr_rec	ar_cash_receipts%ROWTYPE;
l_crh_rec	ar_cash_receipt_history%ROWTYPE;
l_new_crh_rec	ar_cash_receipt_history%ROWTYPE;

l_cr_id		     ar_cash_receipts.cash_receipt_id%TYPE;
l_prev_crh_id	     ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_new_crh_id	     ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_confirmation_ccid  ar_cash_receipt_history.account_code_combination_id%TYPE;
l_remittance_ccid  ar_cash_receipt_history.account_code_combination_id%TYPE;

l_ra_ccid	ar_receivable_applications.code_combination_id%TYPE;
l_ra_unid_ccid	ar_receivable_applications.code_combination_id%TYPE;
l_ra_unapp_ccid	ar_receivable_applications.code_combination_id%TYPE;

l_crh_amount 		ar_cash_receipt_history.amount%TYPE;
l_cr_acctd_amount	ar_payment_schedules.acctd_amount_due_remaining%TYPE;
l_crh_acctd_amount  	ar_cash_receipt_history.amount%TYPE;
l_bank_charges_ccid	ar_cash_receipt_history.bank_charge_account_ccid%TYPE;

l_dummy		NUMBER;
l_id_dummy	NUMBER;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('arp_process_receipts.remit_cash_receipt()+');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_cr_rec.cash_receipt_id := p_cash_receipt_id;

  --fetch cash receipt record
    arp_cash_receipts_pkg.fetch_p(l_cr_rec);

  --fetch cash receipt history record
    arp_cr_history_pkg.fetch_f_crid(l_cr_rec.cash_receipt_id, l_crh_rec );

    IF l_crh_rec.status <> 'CONFIRMED' then
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('remit_cash_receipt: ' || 'This receipt is in '||l_crh_rec.status||
                          ' status. Does not require Remittance ');
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
    END IF;

    l_prev_crh_id := l_crh_rec.cash_receipt_history_id;
    l_new_crh_rec := l_crh_rec;
    l_new_crh_rec.current_record_flag := 'Y';
    l_new_crh_rec.first_posted_record_flag := 'N';
    l_new_crh_rec.status := 'REMITTED';

   --Insert a new cash receipt history record
    arp_cr_history_pkg.insert_p(l_new_crh_rec,l_new_crh_id );

    l_crh_rec.reversal_cash_receipt_hist_id := l_new_crh_id;
    l_crh_rec.reversal_created_from := 'PREPAY';
    l_crh_rec.current_record_flag := null;

  --Update the previous cash receipt history record
    arp_cr_history_pkg.update_p(l_crh_rec,l_prev_crh_id );

  --Get the ccids
    arp_proc_rct_util.get_ccids(
		l_cr_rec.receipt_method_id,
		l_cr_rec.remit_bank_acct_use_id,
		l_ra_unid_ccid,
		l_ra_unapp_ccid,
		l_id_dummy,
		l_id_dummy,
		l_id_dummy,
		l_bank_charges_ccid,
		l_id_dummy,
		l_confirmation_ccid,
		l_remittance_ccid,
		l_id_dummy);

  --create distributions record(s)
  --Debit remittance
    arp_proc_rct_util.insert_dist_rec(
			l_new_crh_rec.amount,
			l_new_crh_rec.acctd_amount,
			l_new_crh_id,
			'REMITTANCE',
                        l_remittance_ccid);

  --Credit confirmation
    arp_proc_rct_util.insert_dist_rec(
			(l_new_crh_rec.amount * -1),
			(l_new_crh_rec.acctd_amount * -1),
			l_new_crh_id,
			'CONFIRMATION',
                        l_confirmation_ccid);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('arp_process_receipts.remit_cash_receipt()-');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Exception in remit_cash_receipt '||SQLERRM);
      END IF;
      RAISE;

END remit_cash_receipt;

END ARP_PROC_RECEIPTS2;

/
