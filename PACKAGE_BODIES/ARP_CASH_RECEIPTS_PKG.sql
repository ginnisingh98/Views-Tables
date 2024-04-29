--------------------------------------------------------
--  DDL for Package Body ARP_CASH_RECEIPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CASH_RECEIPTS_PKG" AS
/* $Header: ARRICRB.pls 120.14.12010000.5 2009/03/20 06:03:25 mpsingh ship $*/
--
--
--
  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/
--
  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(1) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');
  /*-------------------------------------+
   |  WHO column values from ARP_GLOBAL  |
   +-------------------------------------*/
--
  pg_request_id                 number;
  pg_program_application_id     number;
  pg_program_id                 number;
  pg_program_update_date        date;
  pg_last_updated_by            number;
  pg_last_update_date           date;
  pg_last_update_login          number;
--  pg_set_of_books_id            number;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE set_to_dummy( p_cr_rec 	OUT NOCOPY ar_cash_receipts%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.set_to_dummy()+' );
    END IF;
    --
 		   p_cr_rec.amount := AR_NUMBER_DUMMY;
 		   p_cr_rec.currency_code := AR_TEXT_DUMMY;
 		   p_cr_rec.receipt_method_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.set_of_books_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.comments := AR_TEXT_DUMMY;
 		   p_cr_rec.confirmed_flag := AR_FLAG_DUMMY;
 		   p_cr_rec.customer_bank_account_id := AR_NUMBER_DUMMY;
		   p_cr_rec.customer_bank_branch_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.customer_site_use_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.deposit_date := AR_DATE_DUMMY;
 		   p_cr_rec.distribution_set_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.exchange_date := AR_DATE_DUMMY;
 		   p_cr_rec.exchange_rate := AR_NUMBER_DUMMY;
 		   p_cr_rec.exchange_rate_type := AR_TEXT_DUMMY;
 		   p_cr_rec.misc_payment_source := AR_TEXT_DUMMY;
 		   p_cr_rec.pay_from_customer := AR_NUMBER_DUMMY;
 		   p_cr_rec.receipt_date := AR_DATE_DUMMY;
 		   p_cr_rec.receipt_number := AR_TEXT_DUMMY;
 		   p_cr_rec.receivables_trx_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.remit_bank_acct_use_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.reversal_category := AR_TEXT_DUMMY;
 		   p_cr_rec.reversal_comments := AR_TEXT_DUMMY;
 		   p_cr_rec.reversal_date := AR_DATE_DUMMY;
 		   p_cr_rec.selected_for_factoring_flag := AR_FLAG_DUMMY;
 		   p_cr_rec.selected_remittance_batch_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.status := AR_TEXT_DUMMY;
 		   p_cr_rec.type := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute_category := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute1 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute2 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute3 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute4 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute5 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute6 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute7 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute8 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute9 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute10 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute11 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute12 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute13 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute14 := AR_TEXT_DUMMY;
 		   p_cr_rec.attribute15 := AR_TEXT_DUMMY;
 		   p_cr_rec.factor_discount_amount := AR_NUMBER_DUMMY;
 		   p_cr_rec.ussgl_transaction_code := AR_TEXT_DUMMY;
 		   p_cr_rec.ussgl_transaction_code_context := AR_TEXT_DUMMY;
 		   p_cr_rec.reversal_reason_code := AR_TEXT_DUMMY;
 		   p_cr_rec.doc_sequence_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.doc_sequence_value := AR_NUMBER_DUMMY;
 		   p_cr_rec.vat_tax_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.reference_type := AR_TEXT_DUMMY;
 		   p_cr_rec.reference_id := AR_NUMBER_DUMMY;
 		   p_cr_rec.customer_receipt_reference := AR_TEXT_DUMMY;
                   p_cr_rec.override_remit_account_flag := AR_FLAG_DUMMY;
		   p_cr_rec.anticipated_clearing_date := AR_DATE_DUMMY;
 		   p_cr_rec.global_attribute_category := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute1 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute2 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute3 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute4 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute5 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute6 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute7 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute8 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute9 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute10 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute11 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute12 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute13 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute14 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute15 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute16 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute17 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute18 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute19 := AR_TEXT_DUMMY;
 		   p_cr_rec.global_attribute20 := AR_TEXT_DUMMY;
    --
    --             Notes Receivable additional information
    --
                   p_cr_rec.issuer_name           := AR_TEXT_DUMMY;
                   p_cr_rec.issue_date            := AR_DATE_DUMMY;
                   p_cr_rec.issuer_bank_branch_id := AR_NUMBER_DUMMY;

                   -- ARTA Changes
                   p_cr_rec.postmark_date      := AR_DATE_DUMMY;

                   -- OSTEINME 3/12/01: need to set credit card fields to
                   -- dummy values (bug 1683007)
		   /* Bug 7427809 Obsoleted  this column in R12
                   p_cr_rec.payment_server_order_num := AR_TEXT_DUMMY; */
                   p_cr_rec.approval_code := AR_TEXT_DUMMY;

                   -- enhancement 2074220
                   p_cr_rec.application_notes := AR_TEXT_DUMMY;

                   /* Bug fix 3226723 */
                   p_cr_rec.rec_version_number := AR_NUMBER_DUMMY;

                   p_cr_rec.legal_entity_id := AR_NUMBER_DUMMY;   /* LE */

                   p_cr_rec.payment_trxn_extension_id := AR_NUMBER_DUMMY; /* bichatte payment uptake project */
                   p_cr_rec.automatch_set_id := AR_NUMBER_DUMMY;  /* ER Automatch Application */
		   p_cr_rec.autoapply_flag   := AR_FLAG_DUMMY;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.set_to_dummy_p()-' );
    END IF;
    --
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'EXCEPTION: arp_cash_receipts_pkg.set_to_dummy' );
            END IF;
            RAISE;
END set_to_dummy;
--
PROCEDURE insert_p(
	p_cr_rec IN OUT NOCOPY ar_cash_receipts%ROWTYPE ) IS

l_cr_id	ar_cash_receipts.cash_receipt_id%TYPE;
l_cr_key_value_list  gl_ca_utility_pkg.r_key_value_arr;
l_rec_version_number ar_cash_receipts.rec_version_number%TYPE  := 1 ; /* Bug fix 3226723 */
--begin LE
  l_legal_entity_id   number;
--end LE

BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug( 'arp_cash_receipts_pkg.insert_p()+' );
      END IF;
      --
      SELECT ar_cash_receipts_s.nextval
      INTO   l_cr_id
      FROM   dual;
      --

      INSERT INTO  ar_cash_receipts (
		    cash_receipt_id,
 		    amount,
 		    currency_code,
 		    receipt_method_id,
 		    set_of_books_id,
 		    comments,
 		    confirmed_flag,
 		    customer_bank_account_id,
		    customer_bank_branch_id,
 		    customer_site_use_id,
 		    deposit_date,
 		    distribution_set_id,
 		    exchange_date,
 		    exchange_rate,
 		    exchange_rate_type,
 		    misc_payment_source,
 		    pay_from_customer,
 		    receipt_date,
 		    receipt_number,
 		    receivables_trx_id,
 		    remit_bank_acct_use_id,
 		    reversal_category,
 		    reversal_comments,
 		    reversal_date,
 		    selected_for_factoring_flag,
 		    selected_remittance_batch_id,
 		    status,
 		    type,
 		    attribute_category,
 		    attribute1,
 		    attribute2,
 		    attribute3,
 		    attribute4,
 		    attribute5,
 		    attribute6,
 		    attribute7,
 		    attribute8,
 		    attribute9,
 		    attribute10,
 		    attribute11,
 		    attribute12,
 		    attribute13,
 		    attribute14,
 		    attribute15,
 		    request_id,
 		    program_application_id,
 		    program_id,
 		    program_update_date,
 		    created_by,
 		    creation_date,
 		    last_updated_by,
 		    last_update_date,
 		    last_update_login,
 		    factor_discount_amount,
 		    ussgl_transaction_code,
 		    ussgl_transaction_code_context,
 		    reversal_reason_code,
 		    doc_sequence_id,
 		    doc_sequence_value,
 		    vat_tax_id,
 		    reference_type,
 		    reference_id,
 		    customer_receipt_reference,
		    override_remit_account_flag,
		    anticipated_clearing_date,
 		    global_attribute_category,
 		    global_attribute1,
 		    global_attribute2,
 		    global_attribute3,
 		    global_attribute4,
 		    global_attribute5,
 		    global_attribute6,
 		    global_attribute7,
 		    global_attribute8,
 		    global_attribute9,
 		    global_attribute10,
 		    global_attribute11,
 		    global_attribute12,
 		    global_attribute13,
 		    global_attribute14,
 		    global_attribute15,
 		    global_attribute16,
 		    global_attribute17,
 		    global_attribute18,
 		    global_attribute19,
 		    global_attribute20,
		    issuer_name,
		    issue_date,
		    issuer_bank_branch_id,
		    tax_rate,
                    postmark_date, -- ARTA Changes
		    /* Bug 7427809 Obsoleted  this column in R12
                    payment_server_order_num, --apandit Bug 1820063 */
                    approval_code,
                    application_notes -- djancis 2074220
                    ,org_id
                    ,legal_entity_id
                    ,payment_trxn_extension_id -- bichatte payment uptake project
                    ,rec_version_number /* Bug fix 3226723 */
		    ,automatch_set_id
		    ,autoapply_flag
 		 )
       VALUES (    l_cr_id,
 		   p_cr_rec.amount,
 		   p_cr_rec.currency_code,
 		   p_cr_rec.receipt_method_id,
 		   arp_global.set_of_books_id,
 		   p_cr_rec.comments,
 		   p_cr_rec.confirmed_flag,
 		   p_cr_rec.customer_bank_account_id,
		   p_cr_rec.customer_bank_branch_id,
 		   p_cr_rec.customer_site_use_id,
 		   p_cr_rec.deposit_date,
 		   p_cr_rec.distribution_set_id,
 		   p_cr_rec.exchange_date,
 		   p_cr_rec.exchange_rate,
 		   p_cr_rec.exchange_rate_type,
 		   p_cr_rec.misc_payment_source,
 		   p_cr_rec.pay_from_customer,
 		   p_cr_rec.receipt_date,
 		   p_cr_rec.receipt_number,
 		   p_cr_rec.receivables_trx_id,
 		   p_cr_rec.remit_bank_acct_use_id,
 		   p_cr_rec.reversal_category,
 		   p_cr_rec.reversal_comments,
 		   p_cr_rec.reversal_date,
 		   p_cr_rec.selected_for_factoring_flag,
 		   p_cr_rec.selected_remittance_batch_id,
 		   p_cr_rec.status,
 		   p_cr_rec.type,
 		   p_cr_rec.attribute_category,
 		   p_cr_rec.attribute1,
 		   p_cr_rec.attribute2,
 		   p_cr_rec.attribute3,
 		   p_cr_rec.attribute4,
 		   p_cr_rec.attribute5,
 		   p_cr_rec.attribute6,
 		   p_cr_rec.attribute7,
 		   p_cr_rec.attribute8,
 		   p_cr_rec.attribute9,
 		   p_cr_rec.attribute10,
 		   p_cr_rec.attribute11,
 		   p_cr_rec.attribute12,
 		   p_cr_rec.attribute13,
 		   p_cr_rec.attribute14,
 		   p_cr_rec.attribute15,
 		   pg_request_id,
 		   pg_program_application_id,
 		   pg_program_id,
 		   DECODE( pg_program_id,
                   NULL, NULL,
                   SYSDATE),
 		   arp_global.last_updated_by, /* FP Bug 5715840 pg_last_updated_by,*/
 		   SYSDATE,
 		   arp_global.last_updated_by, /* FP Bug 5715840 pg_last_updated_by,*/
 		   SYSDATE,
 		   arp_global.last_update_login, /* FP Bug 5715840 pg_last_update_login,*/
 		   p_cr_rec.factor_discount_amount,
 		   p_cr_rec.ussgl_transaction_code,
 		   p_cr_rec.ussgl_transaction_code_context,
 		   p_cr_rec.reversal_reason_code,
 		   p_cr_rec.doc_sequence_id,
 		   p_cr_rec.doc_sequence_value,
 		   p_cr_rec.vat_tax_id,
 		   p_cr_rec.reference_type,
 		   p_cr_rec.reference_id,
 		   p_cr_rec.customer_receipt_reference,
		   p_cr_rec.override_remit_account_flag,
		   p_cr_rec.anticipated_clearing_date,
 		   p_cr_rec.global_attribute_category,
 		   p_cr_rec.global_attribute1,
 		   p_cr_rec.global_attribute2,
 		   p_cr_rec.global_attribute3,
 		   p_cr_rec.global_attribute4,
 		   p_cr_rec.global_attribute5,
 		   p_cr_rec.global_attribute6,
 		   p_cr_rec.global_attribute7,
 		   p_cr_rec.global_attribute8,
 		   p_cr_rec.global_attribute9,
 		   p_cr_rec.global_attribute10,
 		   p_cr_rec.global_attribute11,
 		   p_cr_rec.global_attribute12,
 		   p_cr_rec.global_attribute13,
 		   p_cr_rec.global_attribute14,
 		   p_cr_rec.global_attribute15,
 		   p_cr_rec.global_attribute16,
 		   p_cr_rec.global_attribute17,
 		   p_cr_rec.global_attribute18,
 		   p_cr_rec.global_attribute19,
 		   p_cr_rec.global_attribute20,
		   p_cr_rec.issuer_name,
		   p_cr_rec.issue_date,
		   p_cr_rec.issuer_bank_branch_id,
		   p_cr_rec.tax_rate,
                   p_cr_rec.postmark_date,
		   /* Bug 7427809 Obsoleted  this column in R12
                   p_cr_rec.payment_server_order_num, --apandit Bug 1820063. */
                   p_cr_rec.approval_code,
                   p_cr_rec.application_notes, -- djancis 2074220
                   arp_standard.sysparm.org_id, /* SSA changes */
                   p_cr_rec.legal_entity_id, /* LE */
                   p_cr_rec.payment_trxn_extension_id, /* bichatte payment uptake */
                   l_rec_version_number,  /* Bug fix 3226723 */
		   p_cr_rec.automatch_set_id,
		   p_cr_rec.autoapply_flag
	       );
    p_cr_rec.cash_receipt_id := l_cr_id;

    /*-----------------------------------+
     | Calling Central MRC library for   |
     | MRC integration.                  |
     +-----------------------------------*/

     ar_mrc_engine.maintain_mrc_data(
                     p_event_mode    => 'INSERT',
                     p_table_name    => 'AR_CASH_RECEIPTS',
                     p_mode          => 'SINGLE',
                     p_key_value     => l_cr_id);

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.insert_p()-' );
    END IF;
    --
    EXCEPTION
	WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_util.debug( 'EXCEPTION: arp_cash_receipts_pkg.insert_p' );
	    END IF;
	    RAISE;
END insert_p;
--
PROCEDURE update_p( p_cr_rec    IN ar_cash_receipts%ROWTYPE,
                    p_cr_id     IN ar_cash_receipts.cash_receipt_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.update_p()+' );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('update_p: ' || 'before call to update ar_cash_receipts');
    END IF;
    UPDATE ar_cash_receipts SET
	amount =  DECODE( p_cr_rec.amount,
                          AR_NUMBER_DUMMY, amount,
                          p_cr_rec.amount ),
 	currency_code = DECODE( p_cr_rec.currency_code,
                          AR_TEXT_DUMMY, currency_code,
                          p_cr_rec.currency_code ),
 	receipt_method_id = DECODE( p_cr_rec.receipt_method_id,
                          AR_NUMBER_DUMMY, receipt_method_id,
                          p_cr_rec.receipt_method_id ),
 	set_of_books_id = DECODE( p_cr_rec.set_of_books_id,
                          AR_NUMBER_DUMMY, set_of_books_id,
			  -- pg_set_of_books_id ),
                          arp_global.set_of_books_id ),-- FP Bug 5964025
 	comments = DECODE( p_cr_rec.comments,
                          AR_TEXT_DUMMY, comments,
                          p_cr_rec.comments ),
 	confirmed_flag = DECODE( p_cr_rec.confirmed_flag,
                          AR_FLAG_DUMMY, confirmed_flag,
                          p_cr_rec.confirmed_flag ),
 	customer_bank_account_id = DECODE( p_cr_rec.customer_bank_account_id,
                          AR_NUMBER_DUMMY, customer_bank_account_id,
                          p_cr_rec.customer_bank_account_id ),
 	customer_bank_branch_id = DECODE( p_cr_rec.customer_bank_branch_id,
                          AR_NUMBER_DUMMY, customer_bank_branch_id,
                          p_cr_rec.customer_bank_branch_id ),
 	customer_site_use_id = DECODE( p_cr_rec.customer_site_use_id,
                          AR_NUMBER_DUMMY, customer_site_use_id,
                          p_cr_rec.customer_site_use_id ),
 	deposit_date = DECODE( p_cr_rec.deposit_date,
                          AR_DATE_DUMMY, deposit_date,
                          p_cr_rec.deposit_date ),
 	distribution_set_id = DECODE( p_cr_rec.distribution_set_id,
                          AR_NUMBER_DUMMY, distribution_set_id,
                          p_cr_rec.distribution_set_id ),
 	exchange_date = DECODE( p_cr_rec.exchange_date,
                          AR_DATE_DUMMY, exchange_date,
                          p_cr_rec.exchange_date ),
 	exchange_rate = DECODE( p_cr_rec.exchange_rate,
                          AR_NUMBER_DUMMY, exchange_rate,
                          p_cr_rec.exchange_rate ),
 	exchange_rate_type = DECODE( p_cr_rec.exchange_rate_type,
                          AR_TEXT_DUMMY, exchange_rate_type,
                          p_cr_rec.exchange_rate_type ),
 	misc_payment_source = DECODE( p_cr_rec.misc_payment_source,
                          AR_TEXT_DUMMY, misc_payment_source,
                          p_cr_rec.misc_payment_source ),
 	pay_from_customer = DECODE( p_cr_rec.pay_from_customer,
                          AR_NUMBER_DUMMY, pay_from_customer,
                          p_cr_rec.pay_from_customer ),
 	receipt_date = DECODE( p_cr_rec.receipt_date,
                          AR_DATE_DUMMY, receipt_date,
                          p_cr_rec.receipt_date ),
 	receipt_number = DECODE( p_cr_rec.receipt_number,
                          AR_TEXT_DUMMY, receipt_number,
                          p_cr_rec.receipt_number ),
 	receivables_trx_id = DECODE( p_cr_rec.receivables_trx_id,
                          AR_NUMBER_DUMMY, receivables_trx_id,
                          p_cr_rec.receivables_trx_id ),
 	remit_bank_acct_use_id =
		DECODE( p_cr_rec.remit_bank_acct_use_id,
                          AR_NUMBER_DUMMY, remit_bank_acct_use_id,
                          p_cr_rec.remit_bank_acct_use_id ),
 	reversal_category = DECODE( p_cr_rec.reversal_category,
                          AR_TEXT_DUMMY, reversal_category,
                          p_cr_rec.reversal_category ),
 	reversal_comments = DECODE( p_cr_rec.reversal_comments,
                          AR_TEXT_DUMMY, reversal_comments,
                          p_cr_rec.reversal_comments ),
 	reversal_date = DECODE( p_cr_rec.reversal_date,
                          AR_DATE_DUMMY, reversal_date,
                          p_cr_rec.reversal_date ),
 	selected_for_factoring_flag =
			DECODE( p_cr_rec.selected_for_factoring_flag,
                          AR_FLAG_DUMMY, selected_for_factoring_flag,
                          p_cr_rec.selected_for_factoring_flag ),
 	selected_remittance_batch_id =
			DECODE( p_cr_rec.selected_remittance_batch_id,
                          AR_NUMBER_DUMMY, selected_remittance_batch_id,
                          p_cr_rec.selected_remittance_batch_id ),
 	status = DECODE( p_cr_rec.status,
                          AR_TEXT_DUMMY, status,
                          p_cr_rec.status ),
 	type = DECODE( p_cr_rec.type,
                          AR_TEXT_DUMMY, type,
                          p_cr_rec.type ),
 	attribute_category = DECODE( p_cr_rec.attribute_category,
                          AR_TEXT_DUMMY, attribute_category,
                          p_cr_rec.attribute_category ),
 	attribute1 = DECODE( p_cr_rec.attribute1,
                          AR_TEXT_DUMMY, attribute1,
                          p_cr_rec.attribute1 ),
 	attribute2 = DECODE( p_cr_rec.attribute2,
                          AR_TEXT_DUMMY, attribute2,
                          p_cr_rec.attribute2 ),
 	attribute3 = DECODE( p_cr_rec.attribute3,
                          AR_TEXT_DUMMY, attribute3,
                          p_cr_rec.attribute3 ),
 	attribute4 = DECODE( p_cr_rec.attribute4,
                          AR_TEXT_DUMMY, attribute4,
                          p_cr_rec.attribute4 ),
 	attribute5 = DECODE( p_cr_rec.attribute5,
                          AR_TEXT_DUMMY, attribute5,
                          p_cr_rec.attribute5 ),
 	attribute6 = DECODE( p_cr_rec.attribute6,
                          AR_TEXT_DUMMY, attribute6,
                          p_cr_rec.attribute6 ),
 	attribute7 = DECODE( p_cr_rec.attribute7,
                          AR_TEXT_DUMMY, attribute7,
                          p_cr_rec.attribute7 ),
 	attribute8 = DECODE( p_cr_rec.attribute8,
                          AR_TEXT_DUMMY, attribute8,
                          p_cr_rec.attribute8 ),
 	attribute9 = DECODE( p_cr_rec.attribute9,
                          AR_TEXT_DUMMY, attribute9,
                          p_cr_rec.attribute9 ),
 	attribute10 = DECODE( p_cr_rec.attribute10,
                          AR_TEXT_DUMMY, attribute10,
                          p_cr_rec.attribute10 ),
 	attribute11 = DECODE( p_cr_rec.attribute11,
                          AR_TEXT_DUMMY, attribute11,
                          p_cr_rec.attribute11 ),
 	attribute12 = DECODE( p_cr_rec.attribute12,
                          AR_TEXT_DUMMY, attribute12,
                          p_cr_rec.attribute12 ),
 	attribute13 = DECODE( p_cr_rec.attribute13,
                          AR_TEXT_DUMMY, attribute13,
                          p_cr_rec.attribute13 ),
 	attribute14 = DECODE( p_cr_rec.attribute14,
                          AR_TEXT_DUMMY, attribute14,
                          p_cr_rec.attribute14 ),
 	attribute15 = DECODE( p_cr_rec.attribute15,
                          AR_TEXT_DUMMY, attribute15,
                          p_cr_rec.attribute15 ),
 	request_id             = pg_request_id,
 	program_application_id = pg_program_application_id,
 	program_id             = pg_program_id,
 	program_update_date    = DECODE( pg_program_id,
                                 NULL, NULL,
                                 SYSDATE),
 	last_updated_by        = arp_global.last_updated_by, /* FP Bug 5715840 pg_last_updated_by, */
 	last_update_date       = SYSDATE,
 	last_update_login      = arp_global.last_update_login, /* FP Bug 5715840 pg_last_update_login, */
 	factor_discount_amount =  DECODE( p_cr_rec.factor_discount_amount,
                          AR_NUMBER_DUMMY, factor_discount_amount,
                          p_cr_rec.factor_discount_amount ),
 	ussgl_transaction_code = DECODE( p_cr_rec.ussgl_transaction_code,
                          AR_TEXT_DUMMY, ussgl_transaction_code,
                          p_cr_rec.ussgl_transaction_code ),
 	ussgl_transaction_code_context =
 			  DECODE( p_cr_rec.ussgl_transaction_code_context,
                          AR_TEXT_DUMMY, ussgl_transaction_code_context,
                          p_cr_rec.ussgl_transaction_code_context ),
 	reversal_reason_code = DECODE( p_cr_rec.reversal_reason_code,
                          AR_TEXT_DUMMY, reversal_reason_code,
                          p_cr_rec.reversal_reason_code ),
 	doc_sequence_id = DECODE( p_cr_rec.doc_sequence_id,
                          AR_NUMBER_DUMMY, doc_sequence_id,
                          p_cr_rec.doc_sequence_id ),
 	doc_sequence_value = DECODE( p_cr_rec.doc_sequence_value,
                          AR_NUMBER_DUMMY, doc_sequence_value,
                          p_cr_rec.doc_sequence_value ),
 	vat_tax_id = DECODE( p_cr_rec.vat_tax_id,
                          AR_NUMBER_DUMMY, vat_tax_id,
                          p_cr_rec.vat_tax_id ),
 	reference_type = DECODE( p_cr_rec.reference_type,
                          AR_TEXT_DUMMY, reference_type,
                          p_cr_rec.reference_type ),
 	reference_id = DECODE( p_cr_rec.reference_id,
                          AR_NUMBER_DUMMY, reference_id,
                          p_cr_rec.reference_id ),
 	customer_receipt_reference =
			DECODE( p_cr_rec.customer_receipt_reference,
                          AR_TEXT_DUMMY, customer_receipt_reference,
                          p_cr_rec.customer_receipt_reference ),
        override_remit_account_flag =
			DECODE( p_cr_rec.override_remit_account_flag,
                          AR_FLAG_DUMMY, override_remit_account_flag,
                          p_cr_rec.override_remit_account_flag ),
        anticipated_clearing_date =
			DECODE( p_cr_rec.anticipated_clearing_date,
                          AR_DATE_DUMMY, anticipated_clearing_date,
                          p_cr_rec.anticipated_clearing_date ),
 	global_attribute_category = DECODE( p_cr_rec.global_attribute_category,
                          AR_TEXT_DUMMY, global_attribute_category,
                          p_cr_rec.global_attribute_category ),
 	global_attribute1 = DECODE( p_cr_rec.global_attribute1,
                          AR_TEXT_DUMMY, global_attribute1,
                          p_cr_rec.global_attribute1 ),
 	global_attribute2 = DECODE( p_cr_rec.global_attribute2,
                          AR_TEXT_DUMMY, global_attribute2,
                          p_cr_rec.global_attribute2 ),
 	global_attribute3 = DECODE( p_cr_rec.global_attribute3,
                          AR_TEXT_DUMMY, global_attribute3,
                          p_cr_rec.global_attribute3 ),
 	global_attribute4 = DECODE( p_cr_rec.global_attribute4,
                          AR_TEXT_DUMMY, global_attribute4,
                          p_cr_rec.global_attribute4 ),
 	global_attribute5 = DECODE( p_cr_rec.global_attribute5,
                          AR_TEXT_DUMMY, global_attribute5,
                          p_cr_rec.global_attribute5 ),
 	global_attribute6 = DECODE( p_cr_rec.global_attribute6,
                          AR_TEXT_DUMMY, global_attribute6,
                          p_cr_rec.global_attribute6 ),
 	global_attribute7 = DECODE( p_cr_rec.global_attribute7,
                          AR_TEXT_DUMMY, global_attribute7,
                          p_cr_rec.global_attribute7 ),
 	global_attribute8 = DECODE( p_cr_rec.global_attribute8,
                          AR_TEXT_DUMMY, global_attribute8,
                          p_cr_rec.global_attribute8 ),
 	global_attribute9 = DECODE( p_cr_rec.global_attribute9,
                          AR_TEXT_DUMMY, global_attribute9,
                          p_cr_rec.global_attribute9 ),
 	global_attribute10 = DECODE( p_cr_rec.global_attribute10,
                          AR_TEXT_DUMMY, global_attribute10,
                          p_cr_rec.global_attribute10 ),
 	global_attribute11 = DECODE( p_cr_rec.global_attribute11,
                          AR_TEXT_DUMMY, global_attribute11,
                          p_cr_rec.global_attribute11 ),
 	global_attribute12 = DECODE( p_cr_rec.global_attribute12,
                          AR_TEXT_DUMMY, global_attribute12,
                          p_cr_rec.global_attribute12 ),
 	global_attribute13 = DECODE( p_cr_rec.global_attribute13,
                          AR_TEXT_DUMMY, global_attribute13,
                          p_cr_rec.global_attribute13 ),
 	global_attribute14 = DECODE( p_cr_rec.global_attribute14,
                          AR_TEXT_DUMMY, global_attribute14,
                          p_cr_rec.global_attribute14 ),
 	global_attribute15 = DECODE( p_cr_rec.global_attribute15,
                          AR_TEXT_DUMMY, global_attribute15,
                          p_cr_rec.global_attribute15 ),
 	global_attribute16 = DECODE( p_cr_rec.global_attribute16,
                          AR_TEXT_DUMMY, global_attribute16,
                          p_cr_rec.global_attribute16 ),
 	global_attribute17 = DECODE( p_cr_rec.global_attribute17,
                          AR_TEXT_DUMMY, global_attribute17,
                          p_cr_rec.global_attribute17 ),
 	global_attribute18 = DECODE( p_cr_rec.global_attribute18,
                          AR_TEXT_DUMMY, global_attribute18,
                          p_cr_rec.global_attribute18 ),
 	global_attribute19 = DECODE( p_cr_rec.global_attribute19,
                          AR_TEXT_DUMMY, global_attribute19,
                          p_cr_rec.global_attribute19 ),
 	global_attribute20 = DECODE( p_cr_rec.global_attribute20,
                          AR_TEXT_DUMMY, global_attribute20,
                          p_cr_rec.global_attribute20 ),
        issuer_name        = DECODE (p_cr_rec.issuer_name,
                          AR_TEXT_DUMMY, issuer_name,
                          p_cr_rec.issuer_name),
        issue_date         = DECODE (p_cr_rec.issue_date,
                          AR_DATE_DUMMY, issue_date,
                          p_cr_rec.issue_date),
        issuer_bank_branch_id = DECODE (p_cr_rec.issuer_bank_branch_id,
                          AR_NUMBER_DUMMY, issuer_bank_branch_id,
                          p_cr_rec.issuer_bank_branch_id),
	/* Bug 7427809 Obsoleted  this column in R12
        payment_server_order_num = DECODE (p_cr_rec.payment_server_order_num,
                          AR_TEXT_DUMMY, payment_server_order_num,
                          p_cr_rec.payment_server_order_num), */
        approval_code      = DECODE (p_cr_rec.approval_code,
                          AR_TEXT_DUMMY, approval_code,
                          p_cr_rec.approval_code),
        tax_rate           = DECODE (p_cr_rec.tax_rate,
                          AR_NUMBER_DUMMY, tax_rate,
                          p_cr_rec.tax_rate),
        -- ARTA Changes
        postmark_date   = DECODE( p_cr_rec.postmark_date, AR_DATE_DUMMY,
                          postmark_date,p_cr_rec.postmark_date),
        -- enhancement 2074220
        application_notes = DECODE(p_cr_rec.application_notes,
                                   AR_TEXT_DUMMY, application_notes,
                                   p_cr_rec.application_notes),
        rec_version_number = nvl(rec_version_number,1)+1,  /* Bug fix 3226723*/
        legal_entity_id  = DECODE (p_cr_rec.legal_entity_id,
                                   AR_NUMBER_DUMMY, legal_entity_id,
                                   p_cr_rec.legal_entity_id),  /* LE */
        payment_trxn_extension_id  = DECODE (p_cr_rec.payment_trxn_extension_id,
                                   AR_NUMBER_DUMMY, payment_trxn_extension_id,
                                   p_cr_rec.payment_trxn_extension_id),  /* bichatte payment uptake*/
        work_item_status_code = DECODE(work_item_status_code,
                                        null, work_item_status_code,
                                        DECODE (p_cr_rec.status,
                                        'APP', 'CLOSED',
                                        'REV', 'CLOSED',
                                        'NSF', 'CLOSED',
                                        'STOP', 'CLOSED',
                                        'CC_CHARGEBACK_REV', 'CLOSED',
                                        'UNAPP', decode(status , 'APP', 'NEW', work_item_status_code),
                                        work_item_status_code)),
        automatch_set_id  = DECODE (p_cr_rec.automatch_set_id,
                                   AR_NUMBER_DUMMY, automatch_set_id,
                                   p_cr_rec.automatch_set_id),
        autoapply_flag  = DECODE (p_cr_rec.autoapply_flag,
                                   AR_FLAG_DUMMY, autoapply_flag,
                                   p_cr_rec.autoapply_flag)
    WHERE
          cash_receipt_id = p_cr_id; -- OSTEINME 3/12/01 bug 1683007

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('update_p: ' || 'after updating cash_receipts');
        arp_util.debug('update_p: ' || 'exchange_rate = ' || to_char(p_cr_rec.exchange_rate));
        arp_util.debug('update_p: ' || 'exchange date = ' || to_char(p_cr_rec.exchange_date));
     END IF;
--

     /*-----------------------------------+
     | Calling Central MRC library for   |
     | MRC integration.                  |
     +-----------------------------------*/

     ar_mrc_engine.maintain_mrc_data(
                     p_event_mode    => 'UPDATE',
                     p_table_name    => 'AR_CASH_RECEIPTS',
                     p_mode          => 'SINGLE',
                     p_key_value     => p_cr_id);

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.update_p()-' );
    END IF;
    --
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'EXCEPTION: arp_cash_receipts_pkg.update_p' );
            END IF;
            RAISE;
END update_p;
---------------------------------------------------------------------------------
--  Caroline M Clyde              October 22, 1997
--  Log 454787
--
--  Removed the UPDATE statement from this procedure.  It now calls the new
--  update_p to physically do the update.
---------------------------------------------------------------------------------
PROCEDURE update_p( p_cr_rec 	IN ar_cash_receipts%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.update_p()+' );
    END IF;
    --
    arp_cash_receipts_pkg.update_p (p_cr_rec,
                                    p_cr_rec.cash_receipt_id);
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.update_p()-' );
    END IF;
    --
END update_p;
--
PROCEDURE delete_p(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.delete_p()+' );
    END IF;
    --
    DELETE FROM ar_cash_receipts
    WHERE cash_receipt_id = p_cr_id;

     /*-----------------------------------+
     | Calling Central MRC library for   |
     | MRC integration.                  |
     +-----------------------------------*/

     ar_mrc_engine.maintain_mrc_data(
                     p_event_mode    => 'DELETE',
                     p_table_name    => 'AR_CASH_RECEIPTS',
                     p_mode          => 'SINGLE',
                     p_key_value     => p_cr_id);

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.delete_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'Exception: arp_cash_receipts_pkg.delete_p' );
            END IF;
            RAISE;
END delete_p;
--
PROCEDURE lock_p(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE ) IS
l_cr_id		ar_cash_receipts.cash_receipt_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.lock_p()+' );
    END IF;
    --
    SELECT cash_receipt_id
    INTO   l_cr_id
    FROM  ar_cash_receipts
    WHERE cash_receipt_id = p_cr_id
    FOR UPDATE OF STATUS;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.lock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'EXCEPTION: arp_cash_receipts_pkg.lock_p' );
            END IF;
            RAISE;
END lock_p;
--
--
PROCEDURE nowaitlock_p(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE ) IS
l_cr_id		ar_cash_receipts.cash_receipt_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.nowaitlock_p()+' );
    END IF;
    --
    SELECT cash_receipt_id
    INTO   l_cr_id
    FROM  ar_cash_receipts
    WHERE cash_receipt_id = p_cr_id
    FOR UPDATE OF STATUS NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.nowaitlock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'EXCEPTION: arp_cash_receipts_pkg.nowaitlock_p' );
            END IF;
            RAISE;
END nowaitlock_p;
--
/* Bug fix 3226723
   Locking procedure with additional parameter rec_version_number added */
PROCEDURE nowaitlock_version_p(
        p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_rec_version_number IN ar_cash_receipts.rec_version_number%TYPE DEFAULT NULL ) IS
l_cr_id         ar_cash_receipts.cash_receipt_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.nowaitlock_version_p()+' );
       arp_util.debug('Cash receipt_id = '||to_char(p_cr_id));
       arp_util.debug('receipt version number = '||to_char(p_rec_version_number));
    END IF;
    --

    SELECT cash_receipt_id
    INTO   l_cr_id
    FROM  ar_cash_receipts
    WHERE cash_receipt_id = p_cr_id
      AND (
           rec_version_number = p_rec_version_number
           OR
            (rec_version_number is NULL
             AND p_rec_version_number = 1)
          )
    FOR UPDATE OF REC_VERSION_NUMBER NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.nowaitlock_version_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'EXCEPTION: arp_cash_receipts_pkg.nowaitlock_version_p()' );
            END IF;
            RAISE;
END nowaitlock_version_p;

PROCEDURE update_version_number(p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.update_version_number()+' );
   END IF;

   update ar_cash_receipts
    set rec_version_number = nvl(rec_version_number,1)+1
   where cash_receipt_id = p_cr_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.update_version_number()-');
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'EXCEPTION: arp_cash_receipts_pkg.update_version_number()' );
            END IF;
            RAISE;
END update_version_number;

/* End bug fix 3226723 */
PROCEDURE fetch_p(
                   p_cr_rec IN OUT NOCOPY ar_cash_receipts%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_cr_rec
    FROM   ar_cash_receipts
    WHERE  cash_receipt_id = p_cr_rec.cash_receipt_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.fetch_p()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('fetch_p: ' ||
			'EXCEPTION: arp_cash_receipts_pkg.fetch error' );
              END IF;
              RAISE;
END fetch_p;
--
--
PROCEDURE lock_fetch_p(
                   p_cr_rec IN OUT NOCOPY ar_cash_receipts%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.lock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_cr_rec
    FROM   ar_cash_receipts
    WHERE  cash_receipt_id = p_cr_rec.cash_receipt_id
    FOR UPDATE OF status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.lock_fetch_p()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('lock_fetch_p: ' ||
			'EXCEPTION: arp_cash_receipts_pkg.lock_fetch_p' );
              END IF;
              RAISE;
END lock_fetch_p;
--
--
PROCEDURE nowaitlock_fetch_p(
                   p_cr_rec IN OUT NOCOPY ar_cash_receipts%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.nowaitlock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_cr_rec
    FROM   ar_cash_receipts
    WHERE  cash_receipt_id = p_cr_rec.cash_receipt_id
    FOR UPDATE OF status NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.nowaitlock_fetch_p()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('nowaitlock_fetch_p: ' ||
			'EXCEPTION: arp_cash_receipts_pkg.nowaitlock_fetch_p' );
              END IF;
              RAISE;
END nowaitlock_fetch_p;
--
--
PROCEDURE lock_f_batch_id(
                   p_batch_id IN ar_batches.batch_id%TYPE ) IS
--
CURSOR lock_C IS
SELECT 'lock'
FROM   ar_cash_receipts cr,
       ar_cash_receipt_history crh
WHERE  cr.cash_receipt_id = crh.cash_receipt_id
AND    crh.batch_id = p_batch_id
FOR UPDATE OF cr.status;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.lock_f_batch_id()+' );
    END IF;
    --
    OPEN lock_C;
    CLOSE lock_C;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.lock_f_batch_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
	      IF lock_C%ISOPEN THEN
   	         CLOSE lock_C;
	      END IF;
           --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('lock_f_batch_id: ' ||
			'EXCEPTION: arp_cash_receipts_pkg.lock_f_batch_id' );
              END IF;
              RAISE;
END lock_f_batch_id;
--
--
PROCEDURE nowaitlock_f_batch_id(
                   p_batch_id IN ar_batches.batch_id%TYPE ) IS
--
CURSOR lock_C IS
SELECT 'lock'
FROM   ar_cash_receipts cr,
       ar_cash_receipt_history crh
WHERE  cr.cash_receipt_id = crh.cash_receipt_id
AND    crh.batch_id = p_batch_id
FOR UPDATE OF cr.status NOWAIT;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.nowaitlock_f_batch_id()+' );
    END IF;
    --
    OPEN lock_C;
    CLOSE lock_C;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_cash_receipts_pkg.nowaitlock_f_batch_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
	      IF lock_C%ISOPEN THEN
   	         CLOSE lock_C;
	      END IF;
           --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('nowaitlock_f_batch_id: ' ||
			'EXCEPTION: arp_cash_receipts_pkg.nowaitlock_f_batch_id' );
              END IF;
              RAISE;
END nowaitlock_f_batch_id;
--
--
PROCEDURE lock_compare_p( p_cr_rec IN ar_cash_receipts%ROWTYPE ) IS

  l_new_cr_rec    ar_cash_receipts%ROWTYPE;
  l_exchange_date DATE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_cash_receipts_pkg.lock_compare_p()+');
  END IF;

/* For testing only:

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('lock_compare_p: ' || 'Exchange date: ' ||
 	TO_CHAR(p_cr_rec.exchange_date, 'DD-MON-YYYY HH24-MM-SS'));
  END IF;

  SELECT exchange_date
  INTO l_exchange_date
  FROM ar_cash_receipts cr
  WHERE cr.cash_receipt_id = p_cr_rec.cash_receipt_id
  AND  TO_CHAR(cr.exchange_date,'DD-MON-RR') =
	TO_CHAR(p_cr_rec.exchange_date,'DD-MON-RR');

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('lock_compare_p: ' || 'Exchange date in DB: ' ||
 	TO_CHAR(l_exchange_date, 'DD-MON-YYYY HH24-MM-SS'));
  END IF;

*/

  SELECT *
  INTO
         l_new_cr_rec
  FROM
         ar_cash_receipts cr
  WHERE
         cr.cash_receipt_id = p_cr_rec.cash_receipt_id
  AND
      NVL(cr.amount, AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.amount,
		  AR_NUMBER_DUMMY, cr.amount,
		  p_cr_rec.amount),
	   AR_NUMBER_DUMMY
	  )
  AND
      NVL(cr.set_of_books_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.set_of_books_id,
		  AR_NUMBER_DUMMY, cr.set_of_books_id,
		  p_cr_rec.set_of_books_id),
	   AR_NUMBER_DUMMY
	  )
  AND
      NVL(cr.currency_code , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.currency_code,
		AR_TEXT_DUMMY, cr.currency_code,
				p_cr_rec.currency_code),
	   AR_TEXT_DUMMY
	  )
  AND
      NVL(cr.receivables_trx_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.receivables_trx_id,
		AR_NUMBER_DUMMY, cr.receivables_trx_id,
				p_cr_rec.receivables_trx_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.pay_from_customer , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.pay_from_customer ,
		AR_NUMBER_DUMMY, cr.pay_from_customer,
				p_cr_rec.pay_from_customer),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.status , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.status ,
		AR_TEXT_DUMMY, cr.status,
				p_cr_rec.status),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.type , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.type ,
		AR_TEXT_DUMMY, cr.type,
				p_cr_rec.type),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.receipt_number , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.receipt_number ,
		AR_TEXT_DUMMY, cr.receipt_number,
				p_cr_rec.receipt_number),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.receipt_date , AR_DATE_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.receipt_date ,
		AR_DATE_DUMMY, cr.receipt_date,
				p_cr_rec.receipt_date),
	   AR_DATE_DUMMY
	  )
AND
      NVL(cr.misc_payment_source , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.misc_payment_source ,
		AR_TEXT_DUMMY, cr.misc_payment_source,
				p_cr_rec.misc_payment_source),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.comments , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.comments ,
		AR_TEXT_DUMMY, cr.comments,
				p_cr_rec.comments),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.distribution_set_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.distribution_set_id ,
		AR_NUMBER_DUMMY, cr.distribution_set_id,
				p_cr_rec.distribution_set_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.reversal_date , AR_DATE_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.reversal_date ,
		AR_DATE_DUMMY, cr.reversal_date,
				p_cr_rec.reversal_date),
	   AR_DATE_DUMMY
	  )
AND
      NVL(cr.reversal_category , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.reversal_category ,
		AR_TEXT_DUMMY, cr.reversal_category,
				p_cr_rec.reversal_category),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.reversal_reason_code , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.reversal_reason_code ,
		AR_TEXT_DUMMY, cr.reversal_reason_code,
				p_cr_rec.reversal_reason_code),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.reversal_comments , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.reversal_comments ,
		AR_TEXT_DUMMY, cr.reversal_comments,
				p_cr_rec.reversal_comments),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.exchange_rate_type , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.exchange_rate_type ,
		AR_TEXT_DUMMY, cr.exchange_rate_type,
				p_cr_rec.exchange_rate_type),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.exchange_rate , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.exchange_rate ,
		AR_NUMBER_DUMMY, cr.exchange_rate,
				p_cr_rec.exchange_rate),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.exchange_date , AR_DATE_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.exchange_date ,
		AR_DATE_DUMMY, cr.exchange_date,
				p_cr_rec.exchange_date),
	   AR_DATE_DUMMY
	  )
AND
      NVL(cr.attribute_category , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute_category ,
		AR_TEXT_DUMMY, cr.attribute_category,
				p_cr_rec.attribute_category),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute1 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute1 ,
		AR_TEXT_DUMMY, cr.attribute1,
				p_cr_rec.attribute1),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute2 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute2 ,
		AR_TEXT_DUMMY, cr.attribute2,
				p_cr_rec.attribute2),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute3 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute3 ,
		AR_TEXT_DUMMY, cr.attribute3,
				p_cr_rec.attribute3),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute4 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute4 ,
		AR_TEXT_DUMMY, cr.attribute4,
				p_cr_rec.attribute4),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute5 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute5 ,
		AR_TEXT_DUMMY, cr.attribute5,
				p_cr_rec.attribute5),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute6 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute6 ,
		AR_TEXT_DUMMY, cr.attribute6,
				p_cr_rec.attribute6),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute7 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute7 ,
		AR_TEXT_DUMMY, cr.attribute7,
				p_cr_rec.attribute7),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute8 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute8 ,
		AR_TEXT_DUMMY, cr.attribute8,
				p_cr_rec.attribute8),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute9 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute9 ,
		AR_TEXT_DUMMY, cr.attribute9,
				p_cr_rec.attribute9),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute10 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute10 ,
		AR_TEXT_DUMMY, cr.attribute10,
				p_cr_rec.attribute10),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute11 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute11 ,
		AR_TEXT_DUMMY, cr.attribute11,
				p_cr_rec.attribute11),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute12 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute12 ,
		AR_TEXT_DUMMY, cr.attribute12,
				p_cr_rec.attribute12),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute13 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute13 ,
		AR_TEXT_DUMMY, cr.attribute13,
				p_cr_rec.attribute13),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute14 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute14 ,
		AR_TEXT_DUMMY, cr.attribute14,
				p_cr_rec.attribute14),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.attribute15 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.attribute15 ,
		AR_TEXT_DUMMY, cr.attribute15,
				p_cr_rec.attribute15),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.receipt_method_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.receipt_method_id ,
		AR_NUMBER_DUMMY, cr.receipt_method_id,
				p_cr_rec.receipt_method_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.confirmed_flag , AR_FLAG_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.confirmed_flag ,
		AR_FLAG_DUMMY, cr.confirmed_flag,
				p_cr_rec.confirmed_flag),
	   AR_FLAG_DUMMY
	  )
AND
      NVL(cr.customer_bank_account_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.customer_bank_account_id ,
		AR_NUMBER_DUMMY, cr.customer_bank_account_id,
				p_cr_rec.customer_bank_account_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.customer_bank_branch_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.customer_bank_branch_id ,
		AR_NUMBER_DUMMY, cr.customer_bank_branch_id,
				p_cr_rec.customer_bank_branch_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.customer_site_use_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.customer_site_use_id ,
		AR_NUMBER_DUMMY, cr.customer_site_use_id,
				p_cr_rec.customer_site_use_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.deposit_date , AR_DATE_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.deposit_date ,
		AR_DATE_DUMMY, cr.deposit_date,
				p_cr_rec.deposit_date),
	   AR_DATE_DUMMY
	  )
AND
      NVL(cr.remit_bank_acct_use_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.remit_bank_acct_use_id ,
		AR_NUMBER_DUMMY, cr.remit_bank_acct_use_id,
				p_cr_rec.remit_bank_acct_use_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.selected_for_factoring_flag , AR_FLAG_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.selected_for_factoring_flag ,
		AR_FLAG_DUMMY, cr.selected_for_factoring_flag,
				p_cr_rec.selected_for_factoring_flag),
	   AR_FLAG_DUMMY
	  )
AND
      NVL(cr.selected_remittance_batch_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.selected_remittance_batch_id ,
		AR_NUMBER_DUMMY, cr.selected_remittance_batch_id,
				p_cr_rec.selected_remittance_batch_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.factor_discount_amount , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.factor_discount_amount ,
		AR_NUMBER_DUMMY, cr.factor_discount_amount,
				p_cr_rec.factor_discount_amount),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.ussgl_transaction_code , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.ussgl_transaction_code ,
		AR_TEXT_DUMMY, cr.ussgl_transaction_code,
				p_cr_rec.ussgl_transaction_code),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.ussgl_transaction_code_context , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.ussgl_transaction_code_context ,
		AR_TEXT_DUMMY, cr.ussgl_transaction_code_context,
				p_cr_rec.ussgl_transaction_code_context),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.doc_sequence_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.doc_sequence_id ,
		AR_NUMBER_DUMMY, cr.doc_sequence_id,
				p_cr_rec.doc_sequence_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.doc_sequence_value , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.doc_sequence_value ,
		AR_NUMBER_DUMMY, cr.doc_sequence_value,
				p_cr_rec.doc_sequence_value),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.vat_tax_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.vat_tax_id ,
		AR_NUMBER_DUMMY, cr.vat_tax_id,
				p_cr_rec.vat_tax_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.reference_type , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.reference_type ,
		AR_TEXT_DUMMY, cr.reference_type,
				p_cr_rec.reference_type),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.reference_id , AR_NUMBER_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.reference_id ,
		AR_NUMBER_DUMMY, cr.reference_id,
				p_cr_rec.reference_id),
	   AR_NUMBER_DUMMY
	  )
AND
      NVL(cr.customer_receipt_reference , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.customer_receipt_reference ,
		AR_TEXT_DUMMY, cr.customer_receipt_reference,
				p_cr_rec.customer_receipt_reference),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.override_remit_account_flag , 'Y') =
      NVL(
	   DECODE(p_cr_rec.override_remit_account_flag ,
		AR_FLAG_DUMMY, NVL(cr.override_remit_account_flag, 'Y'),
				p_cr_rec.override_remit_account_flag),
	   AR_FLAG_DUMMY
	  )
AND
      NVL(cr.anticipated_clearing_date , AR_DATE_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.anticipated_clearing_date ,
		AR_DATE_DUMMY, cr.anticipated_clearing_date,
				p_cr_rec.anticipated_clearing_date),
	   AR_DATE_DUMMY
	  )
AND
      NVL(cr.global_attribute_category , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute_category ,
		AR_TEXT_DUMMY, cr.global_attribute_category,
				p_cr_rec.global_attribute_category),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute1 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute1 ,
		AR_TEXT_DUMMY, cr.global_attribute1,
				p_cr_rec.global_attribute1),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute2 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute2 ,
		AR_TEXT_DUMMY, cr.global_attribute2,
				p_cr_rec.global_attribute2),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute3 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute3 ,
		AR_TEXT_DUMMY, cr.global_attribute3,
				p_cr_rec.global_attribute3),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute4 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute4 ,
		AR_TEXT_DUMMY, cr.global_attribute4,
				p_cr_rec.global_attribute4),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute5 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute5 ,
		AR_TEXT_DUMMY, cr.global_attribute5,
				p_cr_rec.global_attribute5),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute6 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute6 ,
		AR_TEXT_DUMMY, cr.global_attribute6,
				p_cr_rec.global_attribute6),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute7 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute7 ,
		AR_TEXT_DUMMY, cr.global_attribute7,
				p_cr_rec.global_attribute7),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute8 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute8 ,
		AR_TEXT_DUMMY, cr.global_attribute8,
				p_cr_rec.global_attribute8),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute9 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute9 ,
		AR_TEXT_DUMMY, cr.global_attribute9,
				p_cr_rec.global_attribute9),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute10 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute10 ,
		AR_TEXT_DUMMY, cr.global_attribute10,
				p_cr_rec.global_attribute10),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute11 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute11 ,
		AR_TEXT_DUMMY, cr.global_attribute11,
				p_cr_rec.global_attribute11),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute12 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute12 ,
		AR_TEXT_DUMMY, cr.global_attribute12,
				p_cr_rec.global_attribute12),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute13 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute13 ,
		AR_TEXT_DUMMY, cr.global_attribute13,
				p_cr_rec.global_attribute13),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute14 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute14 ,
		AR_TEXT_DUMMY, cr.global_attribute14,
				p_cr_rec.global_attribute14),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute15 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute15 ,
		AR_TEXT_DUMMY, cr.global_attribute15,
				p_cr_rec.global_attribute15),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute16 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute16 ,
		AR_TEXT_DUMMY, cr.global_attribute16,
				p_cr_rec.global_attribute16),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute17 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute17 ,
		AR_TEXT_DUMMY, cr.global_attribute17,
				p_cr_rec.global_attribute17),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute18 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute18 ,
		AR_TEXT_DUMMY, cr.global_attribute18,
				p_cr_rec.global_attribute18),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute19 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute19 ,
		AR_TEXT_DUMMY, cr.global_attribute19,
				p_cr_rec.global_attribute19),
	   AR_TEXT_DUMMY
	  )
AND
      NVL(cr.global_attribute20 , AR_TEXT_DUMMY) =
      NVL(
	   DECODE(p_cr_rec.global_attribute20 ,
		AR_TEXT_DUMMY, cr.global_attribute20,
				p_cr_rec.global_attribute20),
	   AR_TEXT_DUMMY
	  )
AND   NVL (cr.issuer_name, AR_TEXT_DUMMY) =
      NVL (DECODE (p_cr_rec.issuer_name,
                   AR_TEXT_DUMMY, cr.issuer_name,
                                  p_cr_rec.issuer_name),
          AR_TEXT_DUMMY)
AND   NVL (cr.issue_date, AR_DATE_DUMMY) =
      NVL (DECODE (p_cr_rec.issue_date,
                   AR_DATE_DUMMY, cr.issue_date,
                                  p_cr_rec.issue_date),
          AR_DATE_DUMMY)
AND   NVL (cr.issuer_bank_branch_id, AR_NUMBER_DUMMY) =
      NVL (DECODE (p_cr_rec.issuer_bank_branch_id,
                   AR_NUMBER_DUMMY, cr.issuer_bank_branch_id,
                                    p_cr_rec.issuer_bank_branch_id),
          AR_NUMBER_DUMMY)
/* Bug 7427809 Obsoleted  this column in R12
AND   NVL (cr.payment_server_order_num, AR_TEXT_DUMMY) =
      NVL (DECODE (p_cr_rec.payment_server_order_num,
                   AR_TEXT_DUMMY, cr.payment_server_order_num,
                   p_cr_rec.payment_server_order_num),
           AR_TEXT_DUMMY)			*/
AND   NVL (cr.approval_code, AR_TEXT_DUMMY) =
      NVL (DECODE (p_cr_rec.approval_code,
                   AR_TEXT_DUMMY, cr.approval_code,
                   p_cr_rec.approval_code),
           AR_TEXT_DUMMY)
-- ARTA Changes
AND
      NVL(cr.postmark_date , AR_DATE_DUMMY) =
      NVL(DECODE(p_cr_rec.postmark_date,
                 AR_DATE_DUMMY, cr.postmark_date,
                 p_cr_rec.postmark_date),
           AR_DATE_DUMMY)
AND
--   enhancement 2074220
     NVL(cr.application_notes, AR_TEXT_DUMMY) =
       NVL(DECODE(p_cr_rec.application_notes,
                  AR_TEXT_DUMMY, cr.application_notes,
                  p_cr_rec.application_notes),
           AR_TEXT_DUMMY)
     /* Bug fix 3226723 */
AND
     (NVL(cr.rec_version_number,AR_NUMBER_DUMMY) =
       NVL(DECODE(p_cr_rec.rec_version_number,
                 AR_NUMBER_DUMMY,cr.rec_version_number,
                  p_cr_rec.rec_version_number),
           AR_NUMBER_DUMMY)
      OR
      (cr.rec_version_number is NULL
       AND p_cr_rec.rec_version_number = 1)
     )
/* Legal entity project */
AND
      NVL(cr.legal_entity_id , AR_NUMBER_DUMMY) =
      NVL(
           DECODE(p_cr_rec.legal_entity_id,
                AR_NUMBER_DUMMY, cr.legal_entity_id,
                                p_cr_rec.legal_entity_id),
           AR_NUMBER_DUMMY
          )
/* bichatte payment uptake */
AND
      NVL(cr.payment_trxn_extension_id , AR_NUMBER_DUMMY) =
      NVL(
           DECODE(p_cr_rec.payment_trxn_extension_id,
                AR_NUMBER_DUMMY, cr.payment_trxn_extension_id,
                                p_cr_rec.payment_trxn_extension_id),
           AR_NUMBER_DUMMY
          )
/* ER Automatch Application */
AND
      NVL(cr.automatch_set_id , AR_NUMBER_DUMMY) =
      NVL(
           DECODE(p_cr_rec.automatch_set_id,
                AR_NUMBER_DUMMY, cr.automatch_set_id,
                                p_cr_rec.automatch_set_id),
           AR_NUMBER_DUMMY
          )
AND
      NVL(cr.autoapply_flag , AR_FLAG_DUMMY) =
      NVL(
           DECODE(p_cr_rec.autoapply_flag,
                AR_FLAG_DUMMY, cr.autoapply_flag,
                                p_cr_rec.autoapply_flag),
           AR_FLAG_DUMMY
          )
  FOR UPDATE NOWAIT;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_cash_receipts_pkg.lock_compare_p()-');
  END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: arp_cash_receipts_pkg.lock_compare_p()');
        END IF;
     RAISE;

END lock_compare_p;


--
  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/
--
BEGIN
--
  pg_request_id             :=  arp_global.request_id;
  pg_program_application_id :=  arp_global.program_application_id;
  pg_program_id             :=  arp_global.program_id;
  pg_program_update_date    :=  arp_global.program_update_date;
  pg_last_updated_by        :=  arp_global.last_updated_by;
  pg_last_update_date       :=  arp_global.last_update_date;
  pg_last_update_login      :=  arp_global.last_update_login;
--  pg_set_of_books_id        :=  arp_global.set_of_books_id;
--
--
END ARP_CASH_RECEIPTS_PKG;

/
