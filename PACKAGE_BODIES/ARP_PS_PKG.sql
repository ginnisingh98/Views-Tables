--------------------------------------------------------
--  DDL for Package Body ARP_PS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PS_PKG" AS
/* $Header: ARCIPSB.pls 120.12 2006/06/30 06:03:00 arnkumar ship $*/

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_TWO_NUMBER_DUMMY   CONSTANT NUMBER(2)   := -99;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

  /*-------------------------------------+
   |  WHO column values from ARP_GLOBAL  |
   +-------------------------------------*/
  pg_request_id                 number;
  pg_program_application_id     number;
  pg_program_id                 number;
  pg_program_update_date        date;
  pg_last_updated_by            number;
  pg_last_update_date           date;
  pg_last_update_login          number;
  pg_set_of_books_id            number;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE dump_debug (p_ps_rec IN ar_payment_schedules%ROWTYPE);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function sets all columns to dummy values                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN OUT:                                                      |
 |                    p_ps_rec - Payment Schedule record                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              BR_AMOUNT_ASSIGNED, RESERVED_TYPE and        |
 |                              RESERVED_VALUE into the table handlers.      |
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns cons_inv_id and  |
 |				cons_inv_id_rev	and		             |
 |				dunning_level_override_date and		     |
 |				exclude_from_dunning_flag and		     |
 |				staged_dunning_level			     |
 | 				into the table handlers.  		     |
 |20-Jun-02     Sahana          Bug2427456 : Added global attribute columns  |
 +===========================================================================*/
PROCEDURE set_to_dummy( p_ps_rec 	IN OUT NOCOPY ar_payment_schedules%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.set_to_dummy' );
    END IF;
     --
    p_ps_rec.acctd_amount_due_remaining := AR_NUMBER_DUMMY;
    p_ps_rec.amount_due_original := AR_NUMBER_DUMMY;
    p_ps_rec.amount_due_remaining := AR_NUMBER_DUMMY;
    p_ps_rec.class := AR_TEXT_DUMMY;
    p_ps_rec.due_date := AR_DATE_DUMMY;
    p_ps_rec.gl_date := AR_DATE_DUMMY;
    p_ps_rec.invoice_currency_code := AR_TEXT_DUMMY;
    p_ps_rec.number_of_due_dates := AR_NUMBER_DUMMY;
    p_ps_rec.status := AR_TEXT_DUMMY;
    p_ps_rec.actual_date_closed := AR_DATE_DUMMY;
    p_ps_rec.adjustment_amount_last := AR_NUMBER_DUMMY;
    p_ps_rec.adjustment_date_last := AR_DATE_DUMMY;
    p_ps_rec.adjustment_gl_date_last := AR_DATE_DUMMY;
    p_ps_rec.adjustment_id_last := AR_NUMBER_DUMMY;
    p_ps_rec.amount_adjusted := AR_NUMBER_DUMMY;
    p_ps_rec.amount_adjusted_pending := AR_NUMBER_DUMMY;
    p_ps_rec.amount_applied := AR_NUMBER_DUMMY;
    p_ps_rec.amount_credited := AR_NUMBER_DUMMY;
    p_ps_rec.amount_in_dispute := AR_NUMBER_DUMMY;
    p_ps_rec.amount_line_items_original := AR_NUMBER_DUMMY;
    p_ps_rec.amount_line_items_remaining := AR_NUMBER_DUMMY;
    p_ps_rec.associated_cash_receipt_id := AR_NUMBER_DUMMY;
    p_ps_rec.call_date_last := AR_DATE_DUMMY;
    p_ps_rec.cash_applied_amount_last := AR_NUMBER_DUMMY;
    p_ps_rec.cash_applied_date_last := AR_DATE_DUMMY;
    p_ps_rec.cash_applied_id_last := AR_NUMBER_DUMMY;
    p_ps_rec.cash_applied_status_last := AR_TEXT_DUMMY;
    p_ps_rec.cash_gl_date_last := AR_DATE_DUMMY;
    p_ps_rec.cash_receipt_amount_last := AR_NUMBER_DUMMY;
    p_ps_rec.cash_receipt_date_last := AR_DATE_DUMMY;
    p_ps_rec.cash_receipt_id := AR_NUMBER_DUMMY;
    p_ps_rec.cash_receipt_id_last := AR_NUMBER_DUMMY;
    p_ps_rec.cash_receipt_status_last := AR_TEXT_DUMMY;
    p_ps_rec.collector_last := AR_NUMBER_DUMMY;
    p_ps_rec.customer_id := AR_NUMBER_DUMMY;
    p_ps_rec.customer_site_use_id := AR_NUMBER_DUMMY;
    p_ps_rec.customer_trx_id := AR_NUMBER_DUMMY;
    p_ps_rec.cust_trx_type_id := AR_NUMBER_DUMMY;
    p_ps_rec.discount_date := AR_DATE_DUMMY;
    p_ps_rec.discount_original := AR_NUMBER_DUMMY;
    p_ps_rec.discount_remaining := AR_NUMBER_DUMMY;
    p_ps_rec.discount_taken_earned := AR_NUMBER_DUMMY;
    p_ps_rec.discount_taken_unearned := AR_NUMBER_DUMMY;
    p_ps_rec.exchange_date := AR_DATE_DUMMY;
    p_ps_rec.exchange_rate := AR_NUMBER_DUMMY;
    p_ps_rec.exchange_rate_type := AR_TEXT_DUMMY;
    p_ps_rec.follow_up_code_last := AR_TEXT_DUMMY;
    p_ps_rec.follow_up_date_last := AR_DATE_DUMMY;
    p_ps_rec.freight_original := AR_NUMBER_DUMMY;
    p_ps_rec.freight_remaining := AR_NUMBER_DUMMY;
    p_ps_rec.gl_date_closed := AR_DATE_DUMMY;
    p_ps_rec.in_collection := AR_FLAG_DUMMY;
    p_ps_rec.promise_amount_last := AR_NUMBER_DUMMY;
    p_ps_rec.promise_date_last := AR_DATE_DUMMY;
    p_ps_rec.receipt_confirmed_flag := AR_FLAG_DUMMY;
    p_ps_rec.receivables_charges_charged := AR_NUMBER_DUMMY;
    p_ps_rec.receivables_charges_remaining := AR_NUMBER_DUMMY;
    p_ps_rec.reversed_cash_receipt_id := AR_NUMBER_DUMMY;
    p_ps_rec.selected_for_receipt_batch_id := AR_NUMBER_DUMMY;
    p_ps_rec.tax_original := AR_NUMBER_DUMMY;
    p_ps_rec.tax_remaining := AR_NUMBER_DUMMY;
    p_ps_rec.terms_sequence_number := AR_NUMBER_DUMMY;
    p_ps_rec.term_id := AR_NUMBER_DUMMY;
    p_ps_rec.trx_date := AR_DATE_DUMMY;
    p_ps_rec.trx_number := AR_TEXT_DUMMY;
    p_ps_rec.attribute_category := AR_TEXT_DUMMY;
    p_ps_rec.attribute1 := AR_TEXT_DUMMY;
    p_ps_rec.attribute2 := AR_TEXT_DUMMY;
    p_ps_rec.attribute3 := AR_TEXT_DUMMY;
    p_ps_rec.attribute4 := AR_TEXT_DUMMY;
    p_ps_rec.attribute5 := AR_TEXT_DUMMY;
    p_ps_rec.attribute6 := AR_TEXT_DUMMY;
    p_ps_rec.attribute7 := AR_TEXT_DUMMY;
    p_ps_rec.attribute8 := AR_TEXT_DUMMY;
    p_ps_rec.attribute9 := AR_TEXT_DUMMY;
    p_ps_rec.attribute10 := AR_TEXT_DUMMY;
    p_ps_rec.attribute11 := AR_TEXT_DUMMY;
    p_ps_rec.attribute12 := AR_TEXT_DUMMY;
    p_ps_rec.attribute13 := AR_TEXT_DUMMY;
    p_ps_rec.attribute14 := AR_TEXT_DUMMY;
    p_ps_rec.attribute15 := AR_TEXT_DUMMY;
    p_ps_rec.dispute_date := AR_DATE_DUMMY;
    p_ps_rec.last_charge_date := AR_DATE_DUMMY;
    p_ps_rec.second_last_charge_date := AR_DATE_DUMMY;
    p_ps_rec.br_amount_assigned := AR_NUMBER_DUMMY;
    p_ps_rec.reserved_type := AR_TEXT_DUMMY;
    p_ps_rec.reserved_value := AR_NUMBER_DUMMY;
    p_ps_rec.cons_inv_id := AR_NUMBER_DUMMY;
    p_ps_rec.cons_inv_id_rev := AR_NUMBER_DUMMY;
    p_ps_rec.dunning_level_override_date := AR_DATE_DUMMY;
    p_ps_rec.exclude_from_dunning_flag := AR_FLAG_DUMMY;
    p_ps_rec.staged_dunning_level := AR_TWO_NUMBER_DUMMY;
/*Bug2427456*/
    p_ps_rec.global_attribute_category := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute1 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute2 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute3 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute4 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute5 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute6 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute7 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute8 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute9 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute10 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute11 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute12 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute13 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute14 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute15 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute16 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute17 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute18 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute19 := AR_TEXT_DUMMY;
    p_ps_rec.global_attribute20 := AR_TEXT_DUMMY;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.set_to_dummy()-' );
    END IF;
    EXCEPTION
      WHEN  OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('dump_debug: ' ||  'EXCEPTION: arp_ps_pkg.set_to_dummy' );
        END IF;
        RAISE;
END set_to_dummy;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row into AR_PAYMENT_SCHEDULES table            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN OUT:                                                      |
 |                    p_ps_rec - Payment Schedule Record structure           |
 |              OUT:                                                         |
 |                    p_ps_id - Payment Schedule Id                          |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 2/4/1996	Harri Kaukovuo	Added debug information dump in case of	     |
 |				exception.				     |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              BR_AMOUNT_ASSIGNED, RESERVED_TYPE and        |
 |                              RESERVED_VALUE into the table handlers.      |
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns cons_inv_id and  |
 |				cons_inv_id_rev	and		             |
 |				dunning_level_override_date and		     |
 |				exclude_from_dunning_flag and		     |
 |				staged_dunning_level			     |
 | 				into the table handlers.  		     |
 | 04-Feb-2001  Debbie Jancis   Modified for MRC Trigger Replacement project |
 |                              added calls to ar_mrc_engine for inserts     |
 |                              to ar_payment_schedules                      |
 |20-Jun-02     Sahana          Bug2427456 : Added global attribute columns  |
 +===========================================================================*/
PROCEDURE insert_p( p_ps_rec 	IN OUT NOCOPY ar_payment_schedules%ROWTYPE,
	p_ps_id OUT NOCOPY ar_payment_schedules.payment_schedule_id%TYPE ) IS
l_ps_id  ar_payment_schedules.payment_schedule_id%TYPE;
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.insert_p()+');
      END IF;

      SELECT ar_payment_schedules_s.nextval
      INTO   l_ps_id
      FROM   dual;

      p_ps_rec.created_by := FND_GLOBAL.user_id;
      p_ps_rec.last_updated_by := FND_GLOBAL.user_id;
      -- p_ps_rec.created_from := 'XXXXXXX';
      --
      INSERT INTO  ar_payment_schedules (
		 payment_schedule_id,
 		 acctd_amount_due_remaining,
 		 amount_due_original,
 		 amount_due_remaining,
 		 class,
 		 created_by,
 		 creation_date,
 		 due_date,
 		 gl_date,
 		 invoice_currency_code,
 		 last_updated_by,
 		 last_update_date,
 		 number_of_due_dates,
 		 status,
 		 actual_date_closed,
 		 adjustment_amount_last,
 		 adjustment_date_last,
 		 adjustment_gl_date_last,
 		 adjustment_id_last,
 		 amount_adjusted,
 		 amount_adjusted_pending,
 		 amount_applied,
 		 amount_credited,
 		 amount_in_dispute,
 		 amount_line_items_original,
 		 amount_line_items_remaining,
 		 associated_cash_receipt_id,
 		 call_date_last,
 		 cash_applied_amount_last,
 		 cash_applied_date_last,
 		 cash_applied_id_last,
 		 cash_applied_status_last,
 		 cash_gl_date_last,
 		 cash_receipt_amount_last,
 		 cash_receipt_date_last,
 		 cash_receipt_id,
 		 cash_receipt_id_last,
 		 cash_receipt_status_last,
 		 collector_last,
 		 customer_id,
 		 customer_site_use_id,
 		 customer_trx_id,
 		 cust_trx_type_id,
 		 discount_date,
 		 discount_original,
 		 discount_remaining,
 		 discount_taken_earned,
 		 discount_taken_unearned,
 		 exchange_date,
 		 exchange_rate,
 		 exchange_rate_type,
 		 follow_up_code_last,
 		 follow_up_date_last,
 		 freight_original,
 		 freight_remaining,
 		 gl_date_closed,
 		 in_collection,
 		 last_update_login,
 		 promise_amount_last,
 		 promise_date_last,
 		 receipt_confirmed_flag,
 		 receivables_charges_charged,
 		 receivables_charges_remaining,
 		 reversed_cash_receipt_id,
 		 selected_for_receipt_batch_id,
 		 tax_original,
 		 tax_remaining,
 		 terms_sequence_number,
 		 term_id,
 		 trx_date,
 		 trx_number,
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
 		 dispute_date,
 		 last_charge_date,
 		 second_last_charge_date,
                 br_amount_assigned,
                 reserved_type,
                 reserved_value,
                 cons_inv_id,
                 cons_inv_id_rev,
                 dunning_level_override_date,
                 exclude_from_dunning_flag,
                 staged_dunning_level,
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
 		 global_attribute20
                 ,org_id)
       VALUES (  l_ps_id,
 		 p_ps_rec.acctd_amount_due_remaining,
 		 p_ps_rec.amount_due_original,
 		 p_ps_rec.amount_due_remaining,
 		 p_ps_rec.class,
 		 arp_standard.profile.user_id,
 		 SYSDATE,
 		 p_ps_rec.due_date,
 		 p_ps_rec.gl_date,
 		 p_ps_rec.invoice_currency_code,
 		 arp_standard.profile.user_id,
 		 SYSDATE,
 		 p_ps_rec.number_of_due_dates,
 		 p_ps_rec.status,
 		 nvl(p_ps_rec.actual_date_closed, to_date('12/31/4712','MM/DD/YYYY')),
 		 p_ps_rec.adjustment_amount_last,
 		 p_ps_rec.adjustment_date_last,
 		 p_ps_rec.adjustment_gl_date_last,
 		 p_ps_rec.adjustment_id_last,
 		 p_ps_rec.amount_adjusted,
 		 p_ps_rec.amount_adjusted_pending,
 		 p_ps_rec.amount_applied,
 		 p_ps_rec.amount_credited,
 		 p_ps_rec.amount_in_dispute,
 		 p_ps_rec.amount_line_items_original,
 		 p_ps_rec.amount_line_items_remaining,
 		 p_ps_rec.associated_cash_receipt_id,
 		 p_ps_rec.call_date_last,
 		 p_ps_rec.cash_applied_amount_last,
 		 p_ps_rec.cash_applied_date_last,
 		 p_ps_rec.cash_applied_id_last,
 		 p_ps_rec.cash_applied_status_last,
 		 p_ps_rec.cash_gl_date_last,
 		 p_ps_rec.cash_receipt_amount_last,
 		 p_ps_rec.cash_receipt_date_last,
 		 p_ps_rec.cash_receipt_id,
 		 p_ps_rec.cash_receipt_id_last,
 		 p_ps_rec.cash_receipt_status_last,
 		 p_ps_rec.collector_last,
 		 p_ps_rec.customer_id,
 		 p_ps_rec.customer_site_use_id,
 		 p_ps_rec.customer_trx_id,
 		 p_ps_rec.cust_trx_type_id,
 		 p_ps_rec.discount_date,
 		 p_ps_rec.discount_original,
 		 p_ps_rec.discount_remaining,
 		 p_ps_rec.discount_taken_earned,
 		 p_ps_rec.discount_taken_unearned,
 		 p_ps_rec.exchange_date,
 		 p_ps_rec.exchange_rate,
 		 p_ps_rec.exchange_rate_type,
 		 p_ps_rec.follow_up_code_last,
 		 p_ps_rec.follow_up_date_last,
 		 p_ps_rec.freight_original,
 		 p_ps_rec.freight_remaining,
 		 nvl(p_ps_rec.gl_date_closed, to_date('12/31/4712','MM/DD/YYYY')),
 		 p_ps_rec.in_collection,
 		 NVL( arp_standard.profile.last_update_login,
		      p_ps_rec.last_update_login ),
 		 p_ps_rec.promise_amount_last,
 		 p_ps_rec.promise_date_last,
 		 p_ps_rec.receipt_confirmed_flag,
 		 p_ps_rec.receivables_charges_charged,
 		 p_ps_rec.receivables_charges_remaining,
 		 p_ps_rec.reversed_cash_receipt_id,
 		 p_ps_rec.selected_for_receipt_batch_id,
 		 p_ps_rec.tax_original,
 		 p_ps_rec.tax_remaining,
 		 p_ps_rec.terms_sequence_number,
 		 p_ps_rec.term_id,
 		 p_ps_rec.trx_date,
 		 p_ps_rec.trx_number,
 		 p_ps_rec.attribute_category,
 		 p_ps_rec.attribute1,
 		 p_ps_rec.attribute2,
 		 p_ps_rec.attribute3,
 		 p_ps_rec.attribute4,
 		 p_ps_rec.attribute5,
 		 p_ps_rec.attribute6,
 		 p_ps_rec.attribute7,
 		 p_ps_rec.attribute8,
 		 p_ps_rec.attribute9,
 		 p_ps_rec.attribute10,
 		 p_ps_rec.attribute11,
 		 p_ps_rec.attribute12,
 		 p_ps_rec.attribute13,
 		 p_ps_rec.attribute14,
 		 p_ps_rec.attribute15,
 		 NVL( arp_standard.profile.request_id, p_ps_rec.request_id ),
 		 NVL( arp_standard.profile.program_application_id,
		      p_ps_rec.program_application_id ),
 		 NVL( arp_standard.profile.program_id, p_ps_rec.program_id ),
 		 DECODE( arp_standard.profile.program_id,
                         NULL, NULL,
                         SYSDATE
                       ),
 		 p_ps_rec.dispute_date,
 		 p_ps_rec.last_charge_date,
 		 p_ps_rec.second_last_charge_date,
                 p_ps_rec.br_amount_assigned,
                 p_ps_rec.reserved_type,
                 p_ps_rec.reserved_value,
                 p_ps_rec.cons_inv_id,
                 p_ps_rec.cons_inv_id_rev,
                 p_ps_rec.dunning_level_override_date,
                 p_ps_rec.exclude_from_dunning_flag,
                 p_ps_rec.staged_dunning_level,
 		 p_ps_rec.global_attribute_category,
 		 p_ps_rec.global_attribute1,
 		 p_ps_rec.global_attribute2,
 		 p_ps_rec.global_attribute3,
 		 p_ps_rec.global_attribute4,
 		 p_ps_rec.global_attribute5,
 		 p_ps_rec.global_attribute6,
 		 p_ps_rec.global_attribute7,
 		 p_ps_rec.global_attribute8,
 		 p_ps_rec.global_attribute9,
 		 p_ps_rec.global_attribute10,
 		 p_ps_rec.global_attribute11,
 		 p_ps_rec.global_attribute12,
 		 p_ps_rec.global_attribute13,
 		 p_ps_rec.global_attribute14,
 		 p_ps_rec.global_attribute15,
 		 p_ps_rec.global_attribute16,
 		 p_ps_rec.global_attribute17,
 		 p_ps_rec.global_attribute18,
 		 p_ps_rec.global_attribute19,
 		 p_ps_rec.global_attribute20
                 ,arp_standard.sysparm.org_id /* SSA changes anuj */
	       );
    p_ps_id := l_ps_id;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' || 'calling mrc engine to process insert to ps');
    END IF;

    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode => 'INSERT',
                        p_table_name => 'AR_PAYMENT_SCHEDULES',
                        p_mode       => 'SINGLE',
                        p_key_value  => p_ps_id);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.insert_p()-');
    END IF;
    EXCEPTION
      WHEN  OTHERS THEN
        dump_debug(p_ps_rec);
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('dump_debug: ' || 'EXCEPTION: arp_ps_pkg.insert_p' );
	END IF;
	RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row into AR_PAYMENT_SCHEDULES table            |
 |    New update_p that does need a PS row to be fetched before upddating    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ps_rec - Payment Schedule record                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 10/05/95                |
 | 2/4/1996	Harri Kaukovuo		Added debug dump in case of error.   |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              BR_AMOUNT_ASSIGNED, RESERVED_TYPE and        |
 |                              RESERVED_VALUE into the table handlers.      |
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns cons_inv_id and  |
 |				cons_inv_id_rev	and		             |
 |				dunning_level_override_date and		     |
 |				exclude_from_dunning_flag and		     |
 |				staged_dunning_level			     |
 | 				into the table handlers.  		     |
 | 04-Feb-2001  Debbie Jancis   Modified for MRC trigger replacement project |
 | 20-Jun-02    Sahana          Bug2427456 : Added global attribute columns  |
 +===========================================================================*/
PROCEDURE update_p( p_ps_rec    IN ar_payment_schedules%ROWTYPE,
                p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE ) IS
/*Adding cursor as part of bug fix 5129946*/
CURSOR get_existing_ps (p_ps_id IN NUMBER) IS
   SELECT payment_schedule_id,
          amount_in_dispute,
          amount_due_remaining,
          dispute_date
   FROM   ar_payment_schedules
   WHERE  payment_schedule_id = p_ps_id;
  l_old_dispute_date        DATE;
  l_new_dispute_date        DATE;
  l_old_dispute_amount      NUMBER;
  l_amount_due_remaining    NUMBER;
  l_ps_id                   NUMBER;
  l_new_dispute_amount      NUMBER;
  l_sysdate                 DATE := SYSDATE;
  l_last_update_login       NUMBER := arp_standard.profile.last_update_login;
  l_user_id                 NUMBER := arp_standard.profile.user_id;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.update_p(1)+' );
    END IF;
    /*Bug 5129946: Calling arp_dispute_history.DisputeHistory*/
    l_ps_id := p_ps_id;
    OPEN get_existing_ps(l_ps_id);
       FETCH get_existing_ps INTO
          l_ps_id,
          l_old_dispute_amount,
          l_amount_due_remaining,
          l_old_dispute_date;
       IF  get_existing_ps%ROWCOUNT>0 THEN
       if(p_ps_rec.amount_due_remaining = AR_NUMBER_DUMMY) THEN
       l_amount_due_remaining := l_amount_due_remaining;
       ELSE
       l_amount_due_remaining := p_ps_rec.amount_due_remaining;
       END IF;
       if(p_ps_rec.amount_in_dispute = AR_NUMBER_DUMMY) THEN
       l_new_dispute_amount := l_old_dispute_amount;
       ELSE
       l_new_dispute_amount := p_ps_rec.amount_in_dispute;
       END IF;
       if(p_ps_rec.dispute_date = AR_DATE_DUMMY) THEN
       l_new_dispute_date := l_old_dispute_date;
       ELSE
       l_new_dispute_date := p_ps_rec.dispute_date;
       END IF;
         if(l_new_dispute_amount <> l_old_dispute_amount)
         OR(l_new_dispute_amount IS NULL AND l_old_dispute_amount IS NOT NULL)
         OR(l_new_dispute_amount IS NOT NULL AND l_old_dispute_amount IS NULL)
         THEN
             arp_dispute_history.DisputeHistory(l_sysdate,
                                               l_old_dispute_date,
                                               l_ps_id,
                                               l_ps_id,
                                               l_amount_due_remaining,
                                               l_new_dispute_amount,
                                               l_old_dispute_amount,
                                               l_user_id,
                                               l_sysdate,
                                               l_user_id,
                                               l_sysdate,
                                               l_last_update_login);
          END IF;
       END IF;--IF  get_existing_ps%ROWCOUNT>0 THEN
   CLOSE get_existing_ps;
    UPDATE ar_payment_schedules SET
 		 acctd_amount_due_remaining =
				DECODE( p_ps_rec.acctd_amount_due_remaining,
                                AR_NUMBER_DUMMY, acctd_amount_due_remaining,
                                p_ps_rec.acctd_amount_due_remaining ),
 		 amount_due_original = DECODE( p_ps_rec.amount_due_original,
                                AR_NUMBER_DUMMY, amount_due_original,
                                p_ps_rec.amount_due_original ),
 		 amount_due_remaining = DECODE( p_ps_rec.amount_due_remaining,
                                AR_NUMBER_DUMMY, amount_due_remaining,
                                p_ps_rec.amount_due_remaining ),
 		 class = DECODE( p_ps_rec.class,
                                AR_TEXT_DUMMY, class,
                                p_ps_rec.class ),
 		 due_date = DECODE( p_ps_rec.due_date,
                                AR_DATE_DUMMY, due_date,
                                p_ps_rec.due_date ),
 		 gl_date = DECODE( p_ps_rec.gl_date,
                                AR_DATE_DUMMY, gl_date,
                                p_ps_rec.gl_date ),
 		 invoice_currency_code = DECODE( p_ps_rec.invoice_currency_code,
                                AR_TEXT_DUMMY, invoice_currency_code,
                                p_ps_rec.invoice_currency_code ),
 		 last_updated_by = pg_last_updated_by,
 		 last_update_date = pg_last_update_date,
 		 number_of_due_dates = DECODE( p_ps_rec.number_of_due_dates,
                                AR_NUMBER_DUMMY, number_of_due_dates,
                                p_ps_rec.number_of_due_dates ),
 		 status = DECODE( p_ps_rec.status,
                                AR_TEXT_DUMMY, status,
                                p_ps_rec.status ),
 		 actual_date_closed = DECODE( p_ps_rec.actual_date_closed,
                                AR_DATE_DUMMY, actual_date_closed,
                                p_ps_rec.actual_date_closed ),
 		 adjustment_amount_last =
				DECODE( p_ps_rec.adjustment_amount_last,
                                AR_NUMBER_DUMMY, adjustment_amount_last,
                                p_ps_rec.adjustment_amount_last ),
 		 adjustment_date_last = DECODE( p_ps_rec.adjustment_date_last,
                                AR_DATE_DUMMY, adjustment_date_last,
                                p_ps_rec.adjustment_date_last ),
 		 adjustment_gl_date_last =
				DECODE( p_ps_rec.adjustment_gl_date_last,
                                AR_DATE_DUMMY, adjustment_gl_date_last,
                                p_ps_rec.adjustment_gl_date_last ),
 		 adjustment_id_last = DECODE( p_ps_rec.adjustment_id_last,
                                AR_NUMBER_DUMMY, adjustment_id_last,
                                p_ps_rec.adjustment_id_last ),
 		 amount_adjusted = DECODE( p_ps_rec.amount_adjusted,
                                AR_NUMBER_DUMMY, amount_adjusted,
                                p_ps_rec.amount_adjusted ),
 		 amount_adjusted_pending =
				DECODE( p_ps_rec.amount_adjusted_pending,
                                AR_NUMBER_DUMMY, amount_adjusted_pending,
                                p_ps_rec.amount_adjusted_pending ),
 		 amount_applied = DECODE( p_ps_rec.amount_applied,
                                AR_NUMBER_DUMMY, amount_applied,
                                p_ps_rec.amount_applied ),
 		 amount_credited = DECODE( p_ps_rec.amount_credited,
                                AR_NUMBER_DUMMY, amount_credited,
                                p_ps_rec.amount_credited ),
 		 amount_in_dispute = DECODE( p_ps_rec.amount_in_dispute,
                                AR_NUMBER_DUMMY, amount_in_dispute,
                                p_ps_rec.amount_in_dispute ),
 		 amount_line_items_original =
				DECODE( p_ps_rec.amount_line_items_original,
                                AR_NUMBER_DUMMY, amount_line_items_original,
                                p_ps_rec.amount_line_items_original ),
 		 amount_line_items_remaining =
				DECODE( p_ps_rec.amount_line_items_remaining,
                                AR_NUMBER_DUMMY, amount_line_items_remaining,
                                p_ps_rec.amount_line_items_remaining ),
 		 associated_cash_receipt_id =
				DECODE( p_ps_rec.associated_cash_receipt_id,
                                AR_NUMBER_DUMMY, associated_cash_receipt_id,
                                p_ps_rec.associated_cash_receipt_id ),
 		 call_date_last = DECODE( p_ps_rec.call_date_last,
                                AR_DATE_DUMMY, call_date_last,
                                p_ps_rec.call_date_last ),
 		 cash_applied_amount_last =
				DECODE( p_ps_rec.cash_applied_amount_last,
                                AR_NUMBER_DUMMY, cash_applied_amount_last,
                                p_ps_rec.cash_applied_amount_last ),
 		 cash_applied_date_last =
				DECODE( p_ps_rec.cash_applied_date_last,
                                AR_DATE_DUMMY, cash_applied_date_last,
                                p_ps_rec.cash_applied_date_last ),
 		 cash_applied_id_last = DECODE( p_ps_rec.cash_applied_id_last,
                                AR_NUMBER_DUMMY, cash_applied_id_last,
                                p_ps_rec.cash_applied_id_last ),
 		 cash_applied_status_last =
				DECODE( p_ps_rec.cash_applied_status_last,
                                AR_TEXT_DUMMY, cash_applied_status_last,
                                p_ps_rec.cash_applied_status_last ),
 		 cash_gl_date_last = DECODE( p_ps_rec.cash_gl_date_last,
                                AR_DATE_DUMMY, cash_gl_date_last,
                                p_ps_rec.cash_gl_date_last ),
 		 cash_receipt_amount_last =
				DECODE( p_ps_rec.cash_receipt_amount_last,
                                AR_NUMBER_DUMMY, cash_receipt_amount_last,
                                p_ps_rec.cash_receipt_amount_last ),
 		 cash_receipt_date_last =
				DECODE( p_ps_rec.cash_receipt_date_last,
                                AR_DATE_DUMMY, cash_receipt_date_last,
                                p_ps_rec.cash_receipt_date_last ),
 		 cash_receipt_id = DECODE( p_ps_rec.cash_receipt_id,
                                AR_NUMBER_DUMMY, cash_receipt_id,
                                p_ps_rec.cash_receipt_id ),
 		 cash_receipt_id_last = DECODE( p_ps_rec.cash_receipt_id_last,
                                AR_NUMBER_DUMMY, cash_receipt_id_last,
                                p_ps_rec.cash_receipt_id_last ),
 		 cash_receipt_status_last =
				DECODE( p_ps_rec.cash_receipt_status_last,
                                AR_TEXT_DUMMY, cash_receipt_status_last,
                                p_ps_rec.cash_receipt_status_last ),
 		 collector_last = DECODE( p_ps_rec.collector_last,
                                AR_NUMBER_DUMMY, collector_last,
                                p_ps_rec.collector_last ),
 		 customer_id = DECODE( p_ps_rec.customer_id,
                                AR_NUMBER_DUMMY, customer_id,
                                p_ps_rec.customer_id ),
 		 customer_site_use_id = DECODE( p_ps_rec.customer_site_use_id,
                                AR_NUMBER_DUMMY, customer_site_use_id,
                                p_ps_rec.customer_site_use_id ),
 		 customer_trx_id = DECODE( p_ps_rec.customer_trx_id,
                                AR_NUMBER_DUMMY, customer_trx_id,
                                p_ps_rec.customer_trx_id ),
 		 cust_trx_type_id = DECODE( p_ps_rec.cust_trx_type_id,
                                AR_NUMBER_DUMMY, cust_trx_type_id,
                                p_ps_rec.cust_trx_type_id ),
 		 discount_date = DECODE( p_ps_rec.discount_date,
                                AR_DATE_DUMMY, discount_date,
                                p_ps_rec.discount_date ),
 		 discount_original = DECODE( p_ps_rec.discount_original,
                                AR_NUMBER_DUMMY, discount_original,
                                p_ps_rec.discount_original ),
 		 discount_remaining = DECODE( p_ps_rec.discount_remaining,
                                AR_NUMBER_DUMMY, discount_remaining,
                                p_ps_rec.discount_remaining ),
 		 discount_taken_earned = DECODE( p_ps_rec.discount_taken_earned,
                                AR_NUMBER_DUMMY, discount_taken_earned,
                                p_ps_rec.discount_taken_earned ),
 		 discount_taken_unearned =
				DECODE( p_ps_rec.discount_taken_unearned,
                                AR_NUMBER_DUMMY, discount_taken_unearned,
                                p_ps_rec.discount_taken_unearned ),
 		 exchange_date = DECODE( p_ps_rec.exchange_date,
                                AR_DATE_DUMMY, exchange_date,
                                p_ps_rec.exchange_date ),
 		 exchange_rate = DECODE( p_ps_rec.exchange_rate,
                                AR_NUMBER_DUMMY, exchange_rate,
                                p_ps_rec.exchange_rate ),
 		 exchange_rate_type = DECODE( p_ps_rec.exchange_rate_type,
                                AR_TEXT_DUMMY, exchange_rate_type,
                                p_ps_rec.exchange_rate_type ),
 		 follow_up_code_last = DECODE( p_ps_rec.follow_up_code_last,
                                AR_TEXT_DUMMY, follow_up_code_last,
                                p_ps_rec.follow_up_code_last ),
 		 follow_up_date_last = DECODE( p_ps_rec.follow_up_date_last,
                                AR_DATE_DUMMY, follow_up_date_last,
                                p_ps_rec.follow_up_date_last ),
 		 freight_original = DECODE( p_ps_rec.freight_original,
                                AR_NUMBER_DUMMY, freight_original,
                                p_ps_rec.freight_original ),
 		 freight_remaining = DECODE( p_ps_rec.freight_remaining,
                                AR_NUMBER_DUMMY, freight_remaining,
                                p_ps_rec.freight_remaining ),
 		 gl_date_closed = DECODE( p_ps_rec.gl_date_closed,
                                AR_DATE_DUMMY, gl_date_closed,
                                p_ps_rec.gl_date_closed ),
 		 in_collection = DECODE( p_ps_rec.in_collection,
                                AR_FLAG_DUMMY, in_collection,
                                p_ps_rec.in_collection ),
 		 last_update_login = pg_last_update_login,
 		 promise_amount_last = DECODE( p_ps_rec.promise_amount_last,
                                AR_NUMBER_DUMMY, promise_amount_last,
                                p_ps_rec.promise_amount_last ),
 		 promise_date_last = DECODE( p_ps_rec.promise_date_last,
                                AR_DATE_DUMMY, promise_date_last,
                                p_ps_rec.promise_date_last ),
 		 receipt_confirmed_flag =
				DECODE( p_ps_rec.receipt_confirmed_flag,
                                AR_FLAG_DUMMY, receipt_confirmed_flag,
                                p_ps_rec.receipt_confirmed_flag ),
 		 receivables_charges_charged =
			DECODE( p_ps_rec.receivables_charges_charged,
                                AR_NUMBER_DUMMY, receivables_charges_charged,
                                p_ps_rec.receivables_charges_charged ),
 		 receivables_charges_remaining =
				DECODE( p_ps_rec.receivables_charges_remaining,
                                AR_NUMBER_DUMMY, receivables_charges_remaining,
                                p_ps_rec.receivables_charges_remaining ),
 		 reversed_cash_receipt_id =
				DECODE( p_ps_rec.reversed_cash_receipt_id,
                                AR_NUMBER_DUMMY, reversed_cash_receipt_id,
                                p_ps_rec.reversed_cash_receipt_id ),
 		 selected_for_receipt_batch_id =
			DECODE(	p_ps_rec.selected_for_receipt_batch_id,
                                AR_NUMBER_DUMMY, selected_for_receipt_batch_id,
                                p_ps_rec.selected_for_receipt_batch_id ),
 		 tax_original = DECODE( p_ps_rec.tax_original,
                                AR_NUMBER_DUMMY, tax_original,
                                p_ps_rec.tax_original ),
 		 tax_remaining = DECODE( p_ps_rec.tax_remaining,
                                AR_NUMBER_DUMMY, tax_remaining,
                                p_ps_rec.tax_remaining ),
 		 terms_sequence_number = DECODE( p_ps_rec.terms_sequence_number,
                                AR_NUMBER_DUMMY, terms_sequence_number,
                                p_ps_rec.terms_sequence_number ),
 		 term_id = DECODE( p_ps_rec.term_id,
                                AR_NUMBER_DUMMY, term_id,
                                p_ps_rec.term_id ),
 		 trx_date = DECODE( p_ps_rec.trx_date,
                                AR_DATE_DUMMY, trx_date,
                                p_ps_rec.trx_date ),
 		 trx_number = DECODE( p_ps_rec.trx_number,
                                AR_TEXT_DUMMY, trx_number,
                                p_ps_rec.trx_number ),
 		 attribute_category = DECODE( p_ps_rec.attribute_category,
                                AR_TEXT_DUMMY, attribute_category,
                                p_ps_rec.attribute_category ),
 		 attribute1 = DECODE( p_ps_rec.attribute1,
                                AR_TEXT_DUMMY, attribute1,
                                p_ps_rec.attribute1 ),
 		 attribute2 = DECODE( p_ps_rec.attribute2,
                                AR_TEXT_DUMMY, attribute2,
                                p_ps_rec.attribute2 ),
 		 attribute3 = DECODE( p_ps_rec.attribute3,
                                AR_TEXT_DUMMY, attribute3,
                                p_ps_rec.attribute3 ),
 		 attribute4 = DECODE( p_ps_rec.attribute4,
                                AR_TEXT_DUMMY, attribute4,
                                p_ps_rec.attribute4 ),
 		 attribute5 = DECODE( p_ps_rec.attribute5,
                                AR_TEXT_DUMMY, attribute5,
                                p_ps_rec.attribute5 ),
 		 attribute6 = DECODE( p_ps_rec.attribute6,
                                AR_TEXT_DUMMY, attribute6,
                                p_ps_rec.attribute6 ),
 		 attribute7 = DECODE( p_ps_rec.attribute7,
                                AR_TEXT_DUMMY, attribute7,
                                p_ps_rec.attribute7 ),
 		 attribute8 = DECODE( p_ps_rec.attribute8,
                                AR_TEXT_DUMMY, attribute8,
                                p_ps_rec.attribute8 ),
 		 attribute9 = DECODE( p_ps_rec.attribute9,
                                AR_TEXT_DUMMY, attribute9,
                                p_ps_rec.attribute9 ),
 		 attribute10 = DECODE( p_ps_rec.attribute10,
                                AR_TEXT_DUMMY, attribute10,
                                p_ps_rec.attribute10 ),
 		 attribute11 = DECODE( p_ps_rec.attribute11,
                                AR_TEXT_DUMMY, attribute11,
                                p_ps_rec.attribute11 ),
 		 attribute12 = DECODE( p_ps_rec.attribute12,
                                AR_TEXT_DUMMY, attribute12,
                                p_ps_rec.attribute12 ),
 		 attribute13 = DECODE( p_ps_rec.attribute13,
                                AR_TEXT_DUMMY, attribute13,
                                p_ps_rec.attribute13 ),
 		 attribute14 = DECODE( p_ps_rec.attribute14,
                                AR_TEXT_DUMMY, attribute14,
                                p_ps_rec.attribute14 ),
 		 attribute15 = DECODE( p_ps_rec.attribute15,
                                AR_TEXT_DUMMY, attribute15,
                                p_ps_rec.attribute15 ),
 		 request_id = pg_request_id,
 		 program_application_id = pg_program_application_id,
 		 program_id = pg_program_id,
 		 program_update_date = pg_program_update_date,
 		 dispute_date = DECODE( p_ps_rec.dispute_date,
                                AR_DATE_DUMMY, dispute_date,
                                p_ps_rec.dispute_date ),
 		 last_charge_date = DECODE( p_ps_rec.last_charge_date,
                                AR_DATE_DUMMY, last_charge_date,
                                p_ps_rec.last_charge_date ),
 		 second_last_charge_date =
				DECODE( p_ps_rec.second_last_charge_date ,
                                AR_DATE_DUMMY, second_last_charge_date,
                                p_ps_rec.second_last_charge_date ),
 		 br_amount_assigned =
				DECODE( p_ps_rec.br_amount_assigned,
                                AR_NUMBER_DUMMY, br_amount_assigned,
                                p_ps_rec.br_amount_assigned ),
 		 reserved_type =
				DECODE( p_ps_rec.reserved_type,
                                AR_TEXT_DUMMY, reserved_type,
                                p_ps_rec.reserved_type ),
 		 reserved_value =
				DECODE( p_ps_rec.reserved_value,
                                AR_NUMBER_DUMMY, reserved_value,
                                p_ps_rec.reserved_value ),
                 cons_inv_id =
                 		DECODE( p_ps_rec.cons_inv_id,
                 		AR_NUMBER_DUMMY, cons_inv_id,
                 		p_ps_rec.cons_inv_id ),
                 cons_inv_id_rev =
                 		DECODE( p_ps_rec.cons_inv_id_rev,
                 		AR_NUMBER_DUMMY, cons_inv_id_rev,
                 		p_ps_rec.cons_inv_id_rev ),
                 dunning_level_override_date =
                 		DECODE( p_ps_rec.dunning_level_override_date,
                 		AR_DATE_DUMMY, dunning_level_override_date,
                 		p_ps_rec.dunning_level_override_date ),
                 exclude_from_dunning_flag =
                 		DECODE( p_ps_rec.exclude_from_dunning_flag ,
                 		AR_FLAG_DUMMY, exclude_from_dunning_flag ,
                 		p_ps_rec.exclude_from_dunning_flag  ),
                 staged_dunning_level =
                 		DECODE( p_ps_rec.staged_dunning_level ,
                 		AR_TWO_NUMBER_DUMMY, staged_dunning_level ,
                 		p_ps_rec.staged_dunning_level ),
 global_attribute_category = DECODE( p_ps_rec.global_attribute_category,
                                AR_TEXT_DUMMY, global_attribute_category,
                                p_ps_rec.global_attribute_category ),
 		 global_attribute1 = DECODE( p_ps_rec.global_attribute1,
                                AR_TEXT_DUMMY, global_attribute1,
                                p_ps_rec.global_attribute1 ),
 		 global_attribute2 = DECODE( p_ps_rec.global_attribute2,
                                AR_TEXT_DUMMY, global_attribute2,
                                p_ps_rec.global_attribute2 ),
 		 global_attribute3 = DECODE( p_ps_rec.global_attribute3,
                                AR_TEXT_DUMMY, global_attribute3,
                                p_ps_rec.global_attribute3 ),
 		 global_attribute4 = DECODE( p_ps_rec.global_attribute4,
                                AR_TEXT_DUMMY, global_attribute4,
                                p_ps_rec.global_attribute4 ),
 		 global_attribute5 = DECODE( p_ps_rec.global_attribute5,
                                AR_TEXT_DUMMY, global_attribute5,
                                p_ps_rec.global_attribute5 ),
 		 global_attribute6 = DECODE( p_ps_rec.global_attribute6,
                                AR_TEXT_DUMMY, global_attribute6,
                                p_ps_rec.global_attribute6 ),
 		 global_attribute7 = DECODE( p_ps_rec.global_attribute7,
                                AR_TEXT_DUMMY, global_attribute7,
                                p_ps_rec.global_attribute7 ),
 		 global_attribute8 = DECODE( p_ps_rec.global_attribute8,
                                AR_TEXT_DUMMY, global_attribute8,
                                p_ps_rec.global_attribute8 ),
 		 global_attribute9 = DECODE( p_ps_rec.global_attribute9,
                                AR_TEXT_DUMMY, global_attribute9,
                                p_ps_rec.global_attribute9 ),
 		 global_attribute10 = DECODE( p_ps_rec.global_attribute10,
                                AR_TEXT_DUMMY, global_attribute10,
                                p_ps_rec.global_attribute10 ),
 		 global_attribute11 = DECODE( p_ps_rec.global_attribute11,
                                AR_TEXT_DUMMY, global_attribute11,
                                p_ps_rec.global_attribute11 ),
 		 global_attribute12 = DECODE( p_ps_rec.global_attribute12,
                                AR_TEXT_DUMMY, global_attribute12,
                                p_ps_rec.global_attribute12 ),
 		 global_attribute13 = DECODE( p_ps_rec.global_attribute13,
                                AR_TEXT_DUMMY, global_attribute13,
                                p_ps_rec.global_attribute13 ),
 		 global_attribute14 = DECODE( p_ps_rec.global_attribute14,
                                AR_TEXT_DUMMY, global_attribute14,
                                p_ps_rec.global_attribute14 ),
 		 global_attribute15 = DECODE( p_ps_rec.global_attribute15,
                                AR_TEXT_DUMMY, global_attribute15,
                                p_ps_rec.global_attribute15 ),
 		 global_attribute16 = DECODE( p_ps_rec.global_attribute16,
                                AR_TEXT_DUMMY, global_attribute16,
                                p_ps_rec.global_attribute16 ),
 		 global_attribute17 = DECODE( p_ps_rec.global_attribute17,
                                AR_TEXT_DUMMY, global_attribute17,
                                p_ps_rec.global_attribute17 ),
 		 global_attribute18 = DECODE( p_ps_rec.global_attribute18,
                                AR_TEXT_DUMMY, global_attribute18,
                                p_ps_rec.global_attribute18 ),
 		 global_attribute19 = DECODE( p_ps_rec.global_attribute19,
                                AR_TEXT_DUMMY, global_attribute19,
                                p_ps_rec.global_attribute19 ),
 		 global_attribute20 = DECODE( p_ps_rec.global_attribute20,
                                AR_TEXT_DUMMY, global_attribute20,
                                p_ps_rec.global_attribute20 )
     WHERE payment_schedule_id = p_ps_rec.payment_schedule_id;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' || 'calling mrc engine to process UPDATE to ps');
    END IF;

    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode => 'UPDATE',
                        p_table_name => 'AR_PAYMENT_SCHEDULES',
                        p_mode       => 'SINGLE',
                        p_key_value  => p_ps_rec.payment_schedule_id);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.update_p(1)-' );
    END IF;

    EXCEPTION
      WHEN  OTHERS THEN
        dump_debug(p_ps_rec);
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('dump_debug: ' ||  'EXCEPTION: arp_ps_pkg.update_p(1)' );
	END IF;
        RAISE;
END;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row into AR_PAYMENT_SCHEDULES table            |
 |    Old update_p that needs a PS row to be fetched before upddating        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ps_rec - Payment Schedule record                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 2/4/1996	Harri Kaukovuo		Added debug dump in case of error.   |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              BR_AMOUNT_ASSIGNED, RESERVED_TYPE and        |
 |                              RESERVED_VALUE into the table handlers.      |
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns cons_inv_id and  |
 |				cons_inv_id_rev	and		             |
 |				dunning_level_override_date and		     |
 |				exclude_from_dunning_flag and		     |
 |				staged_dunning_level			     |
 | 				into the table handlers.  		     |
 | 04-Feb-2001  Debbie Jancis	Modified for MRC trigger replacement         |
 | 20-Jun-02    Sahana          Bug2427456 : Added global attribute columns  |
 +===========================================================================*/
PROCEDURE update_p( p_ps_rec 	IN ar_payment_schedules%ROWTYPE ) IS
/*Adding cursor as part of bug fix 5129946*/
CURSOR get_existing_ps (p_ps_id IN NUMBER) IS
   SELECT payment_schedule_id,
          amount_in_dispute,
          amount_due_remaining,
          dispute_date
   FROM   ar_payment_schedules
   WHERE  payment_schedule_id = p_ps_id;
  l_old_dispute_date        DATE;
  l_new_dispute_date        DATE;
  l_old_dispute_amount      NUMBER;
  l_amount_due_remaining    NUMBER;
  l_ps_id                   NUMBER;
  l_new_dispute_amount      NUMBER;
  l_sysdate                 DATE := SYSDATE;
  l_last_update_login       NUMBER := arp_standard.profile.last_update_login;
  l_user_id                 NUMBER := arp_standard.profile.user_id;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.update_p(2)+');
    END IF;
     --
    /*Bug 5129946: Calling arp_dispute_history.DisputeHistory*/
    l_ps_id := p_ps_rec.payment_schedule_id;
    OPEN get_existing_ps(l_ps_id);
       FETCH get_existing_ps INTO
          l_ps_id,
          l_old_dispute_amount,
          l_amount_due_remaining,
          l_old_dispute_date;
       IF  get_existing_ps%ROWCOUNT>0 THEN
       l_amount_due_remaining := p_ps_rec.amount_due_remaining;
       l_new_dispute_amount := p_ps_rec.amount_in_dispute;
       l_new_dispute_date := p_ps_rec.dispute_date;
         if(l_new_dispute_amount <> l_old_dispute_amount)
         OR(l_new_dispute_amount IS NULL AND l_old_dispute_amount IS NOT NULL)
         OR(l_new_dispute_amount IS NOT NULL AND l_old_dispute_amount IS NULL)
         THEN
arp_dispute_history.DisputeHistory(l_sysdate,
                                               l_old_dispute_date,
                                               l_ps_id,
                                               l_ps_id,
                                               l_amount_due_remaining,
                                               l_new_dispute_amount,
                                               l_old_dispute_amount,
                                               l_user_id,
                                               l_sysdate,
                                               l_user_id,
                                               l_sysdate,
                                               l_last_update_login);
          END IF;
        END IF;--IF  get_existing_ps%ROWCOUNT>0 THEN
   CLOSE get_existing_ps;
    UPDATE ar_payment_schedules SET
 		 acctd_amount_due_remaining =
				p_ps_rec.acctd_amount_due_remaining,
 		 amount_due_original = p_ps_rec.amount_due_original,
 		 amount_due_remaining = p_ps_rec.amount_due_remaining,
 		 class = p_ps_rec.class,
 		 due_date = p_ps_rec.due_date,
 		 gl_date = p_ps_rec.gl_date,
 		 invoice_currency_code = p_ps_rec.invoice_currency_code,
 		 last_updated_by = arp_standard.profile.user_id,
 		 last_update_date = SYSDATE,
 		 number_of_due_dates = p_ps_rec.number_of_due_dates,
 		 status = p_ps_rec.status,
 		 actual_date_closed = p_ps_rec.actual_date_closed,
 		 adjustment_amount_last = p_ps_rec.adjustment_amount_last,
 		 adjustment_date_last = p_ps_rec.adjustment_date_last,
 		 adjustment_gl_date_last = p_ps_rec.adjustment_gl_date_last,
 		 adjustment_id_last = p_ps_rec.adjustment_id_last,
 		 amount_adjusted = p_ps_rec.amount_adjusted,
 		 amount_adjusted_pending = p_ps_rec.amount_adjusted_pending,
 		 amount_applied = p_ps_rec.amount_applied,
 		 amount_credited = p_ps_rec.amount_credited,
 		 amount_in_dispute = p_ps_rec.amount_in_dispute,
 		 amount_line_items_original = p_ps_rec.amount_line_items_original,
 		 amount_line_items_remaining =
					p_ps_rec.amount_line_items_remaining,
 		 associated_cash_receipt_id =
					p_ps_rec.associated_cash_receipt_id,
 		 call_date_last = p_ps_rec.call_date_last,
 		 cash_applied_amount_last = p_ps_rec.cash_applied_amount_last,
 		 cash_applied_date_last = p_ps_rec.cash_applied_date_last,
 		 cash_applied_id_last = p_ps_rec.cash_applied_id_last,
 		 cash_applied_status_last = p_ps_rec.cash_applied_status_last,
 		 cash_gl_date_last = p_ps_rec.cash_gl_date_last,
 		 cash_receipt_amount_last = p_ps_rec.cash_receipt_amount_last,
 		 cash_receipt_date_last = p_ps_rec.cash_receipt_date_last,
 		 cash_receipt_id = p_ps_rec.cash_receipt_id,
 		 cash_receipt_id_last = p_ps_rec.cash_receipt_id_last,
 		 cash_receipt_status_last = p_ps_rec.cash_receipt_status_last,
 		 collector_last = p_ps_rec.collector_last,
 		 customer_id = p_ps_rec.customer_id,
 		 customer_site_use_id = p_ps_rec.customer_site_use_id,
 		 customer_trx_id = p_ps_rec.customer_trx_id,
 		 cust_trx_type_id = p_ps_rec.cust_trx_type_id,
 		 discount_date = p_ps_rec.discount_date,
 		 discount_original = p_ps_rec.discount_original,
 		 discount_remaining = p_ps_rec.discount_remaining,
 		 discount_taken_earned = p_ps_rec.discount_taken_earned,
 		 discount_taken_unearned = p_ps_rec.discount_taken_unearned,
 		 exchange_date = p_ps_rec.exchange_date,
 		 exchange_rate = p_ps_rec.exchange_rate,
 		 exchange_rate_type = p_ps_rec.exchange_rate_type,
 		 follow_up_code_last = p_ps_rec.follow_up_code_last,
 		 follow_up_date_last = p_ps_rec.follow_up_date_last,
 		 freight_original = p_ps_rec.freight_original,
 		 freight_remaining = p_ps_rec.freight_remaining,
 		 gl_date_closed = p_ps_rec.gl_date_closed,
 		 in_collection = p_ps_rec.in_collection,
 		 last_update_login =
			       NVL( arp_standard.profile.last_update_login,
				    p_ps_rec.last_update_login ),
 		 promise_amount_last = p_ps_rec.promise_amount_last,
 		 promise_date_last = p_ps_rec.promise_date_last,
 		 receipt_confirmed_flag = p_ps_rec.receipt_confirmed_flag,
 		 receivables_charges_charged =
					p_ps_rec.receivables_charges_charged,
 		 receivables_charges_remaining =
					p_ps_rec.receivables_charges_remaining,
 		 reversed_cash_receipt_id = p_ps_rec.reversed_cash_receipt_id,
 		 selected_for_receipt_batch_id =
					p_ps_rec.selected_for_receipt_batch_id,
 		 tax_original = p_ps_rec.tax_original,
 		 tax_remaining = p_ps_rec.tax_remaining,
 		 terms_sequence_number = p_ps_rec.terms_sequence_number,
 		 term_id = p_ps_rec.term_id,
 		 trx_date = p_ps_rec.trx_date,
 		 trx_number = p_ps_rec.trx_number,
 		 attribute_category = p_ps_rec.attribute_category,
 		 attribute1 = p_ps_rec.attribute1,
 		 attribute2 = p_ps_rec.attribute2,
 		 attribute3 = p_ps_rec.attribute3,
 		 attribute4 = p_ps_rec.attribute4,
 		 attribute5 = p_ps_rec.attribute5,
 		 attribute6 = p_ps_rec.attribute6,
 		 attribute7 = p_ps_rec.attribute7,
 		 attribute8 = p_ps_rec.attribute8,
 		 attribute9 = p_ps_rec.attribute9,
 		 attribute10 = p_ps_rec.attribute10,
 		 attribute11 = p_ps_rec.attribute11,
 		 attribute12 = p_ps_rec.attribute12,
 		 attribute13 = p_ps_rec.attribute13,
 		 attribute14 = p_ps_rec.attribute14,
 		 attribute15 = p_ps_rec.attribute15,
 		 request_id = NVL( arp_standard.profile.request_id,
				   p_ps_rec.request_id ),
 		 program_application_id =
			NVL( arp_standard.profile.program_application_id,
			     p_ps_rec.program_application_id ),
 		 program_id = NVL( arp_standard.profile.program_id,
				   p_ps_rec.program_id ),
 		 program_update_date = DECODE( arp_standard.profile.program_id,
                                               NULL, NULL,
                                               SYSDATE
                                              ),
 		 dispute_date = p_ps_rec.dispute_date,
 		 last_charge_date = p_ps_rec.last_charge_date,
 		 second_last_charge_date = p_ps_rec.second_last_charge_date,
 		 br_amount_assigned = p_ps_rec.br_amount_assigned,
 		 reserved_type = p_ps_rec.reserved_type,
 		 reserved_value = p_ps_rec.reserved_value,
 		 cons_inv_id = p_ps_rec.cons_inv_id,
 		 cons_inv_id_rev = p_ps_rec.cons_inv_id_rev,
 		 dunning_level_override_date = p_ps_rec.dunning_level_override_date,
 		 exclude_from_dunning_flag = p_ps_rec.exclude_from_dunning_flag,
 		 staged_dunning_level = p_ps_rec.staged_dunning_level ,
 		 global_attribute_category = p_ps_rec.global_attribute_category,
 		 global_attribute1 = p_ps_rec.global_attribute1,
 		 global_attribute2 = p_ps_rec.global_attribute2,
 		 global_attribute3 = p_ps_rec.global_attribute3,
 		 global_attribute4 = p_ps_rec.global_attribute4,
 		 global_attribute5 = p_ps_rec.global_attribute5,
 		 global_attribute6 = p_ps_rec.global_attribute6,
 		 global_attribute7 = p_ps_rec.global_attribute7,
 		 global_attribute8 = p_ps_rec.global_attribute8,
 		 global_attribute9 = p_ps_rec.global_attribute9,
 		 global_attribute10 = p_ps_rec.global_attribute10,
 		 global_attribute11 = p_ps_rec.global_attribute11,
 		 global_attribute12 = p_ps_rec.global_attribute12,
 		 global_attribute13 = p_ps_rec.global_attribute13,
 		 global_attribute14 = p_ps_rec.global_attribute14,
 		 global_attribute15 = p_ps_rec.global_attribute15,
 		 global_attribute16 = p_ps_rec.global_attribute16,
 		 global_attribute17 = p_ps_rec.global_attribute17,
 		 global_attribute18 = p_ps_rec.global_attribute18,
 		 global_attribute19 = p_ps_rec.global_attribute19,
 		 global_attribute20 = p_ps_rec.global_attribute20
    WHERE payment_schedule_id = p_ps_rec.payment_schedule_id;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' || 'calling mrc engine to process UPDATE to ps');
    END IF;

    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode => 'UPDATE',
                        p_table_name => 'AR_PAYMENT_SCHEDULES',
                        p_mode       => 'SINGLE',
                        p_key_value  => p_ps_rec.payment_schedule_id);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.update_p(2)-' );
    END IF;

    EXCEPTION
      WHEN  OTHERS THEN
        dump_debug(p_ps_rec);
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('dump_debug: ' || 'EXCEPTION: arp_ps_pkg.update_p(2)' );
	END IF;
        RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row from AR_PAYMENT_SCHEDULES table            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ps_id - Payment Schedule Id                            |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | Date         Name            Description                                  |
 | ----------   --------------  -------------------------------------------- |
 | 04-Feb-2001  Debbie Jancis	Modified for MRC trigger replacement         |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p(
		p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  '>>>>>>> arp_ps_pkg.delete_p' );
    END IF;
    DELETE FROM ar_payment_schedules
    WHERE payment_schedule_id = p_ps_id;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' || 'calling mrc engine to process DELETE to ps');
    END IF;

    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode => 'DELETE',
                        p_table_name => 'AR_PAYMENT_SCHEDULES',
                        p_mode       => 'SINGLE',
                        p_key_value  => p_ps_id);

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  '<<<<<<< arp_ps_pkg.delete_p' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug('dump_debug: ' ||
			'EXCEPTION: arp_ps_pkg.delete_p' );
	    END IF;
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_id                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes rows from AR_PAYMENT_SCHEDULES table             |
 |    based on the ct_id                                                     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ct_id - Customer Trx Id                                |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by OSTEINME - 08/21/97                     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_f_ct_id(
		p_ct_id IN ra_customer_trx.customer_trx_id%TYPE ) IS
    l_ps_key_value_list gl_ca_utility_pkg.r_key_value_arr;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  '>>>>>>> arp_ps_pkg.delete_f_ct_id' );
    END IF;
    DELETE FROM ar_payment_schedules
    WHERE customer_trx_id = p_ct_id
    RETURNING payment_schedule_id
    BULK COLLECT INTO l_ps_key_value_list;

    /*---------------------------------+
     | Calling central MRC library     |
     | for MRC Integration             |
     +---------------------------------*/

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('dump_debug: ' || 'calling mrc engine for delete of ps');
     END IF;
     ar_mrc_engine.maintain_mrc_data(
                    p_event_mode        => 'DELETE',
                    p_table_name        => 'AR_PAYMENT_SCHEDULES',
                    p_mode              => 'BATCH',
                    p_key_value_list    => l_ps_key_value_list);
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  '<<<<<<< arp_ps_pkg.delete_f_ct_id' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug('dump_debug: ' ||
			'EXCEPTION: arp_ps_pkg.delete_f_ct_id' );
	    END IF;
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function fetches a row from AR_PAYMENT_SCHEDULES table            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ps_id - Payment Schedule Id                            |
 |              OUT:                                                         |
 |                  p_ps_rec - Payment Schedule record structure             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_p( p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
                   p_ps_rec OUT NOCOPY ar_payment_schedules%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  '>>>>>>> arp_ps_pkg.fetch_p' );
    END IF;
    --
    SELECT *
    INTO   p_ps_rec
    FROM   ar_payment_schedules
    WHERE  payment_schedule_id = p_ps_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  '<<<<<<< arp_ps_pkg.fetch_p' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug('dump_debug: ' ||
			'EXCEPTION: arp_ps_pkg.fetch_p' );
	    END IF;
      RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_fk_cr_id                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function fetches a row from AR_PAYMENT_SCHEDULES table            |
 |    using cash receipt id                                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_cr_id -  cash receipt id                               |
 |              OUT:                                                         |
 |                  p_ps_rec - Payment Schedule record structure             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_fk_cr_id( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
                          p_ps_rec OUT NOCOPY ar_payment_schedules%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  '>>>>>>> arp_ps_pkg.fetch_p' );
    END IF;
    --
    SELECT *
    INTO   p_ps_rec
    FROM   ar_payment_schedules
    WHERE  cash_receipt_id = p_cr_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  '<<<<<<< arp_ps_pkg.fetch_p' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug('dump_debug: ' ||
			'EXCEPTION: arp_ps_pkg.fetch_p' );
	    END IF;
      RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function locks a row in AR_PAYMENT_SCHEDULES table                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ps_id - Payment Schedule Id                            |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 |  20-JAN-98  Neeraj Tandon  Added exception WHEN NO_DATA_FOUND and also    |
 |                            added calls to FND_MESSAGE.Set_Name and        |
 |                            APP_EXCEPTION.Raise_Exception in both the      |
 |                            EXCEPTIONS. Bug Fix : 611600                   |
 |  06-FEB-98  Neeraj Tandon  Reverted back the changes made in the last fix.|
 |                            Adding these changes caused Adjustment Form    |
 |                            (ARXTWADJ) to behave indifferently.            |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_p( p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE ) IS
l_ps_id		ar_payment_schedules.payment_schedule_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.lock_p()+' );
    END IF;

    SELECT ps.payment_schedule_id
    INTO   l_ps_id
    FROM  ar_payment_schedules ps
    WHERE ps.payment_schedule_id = p_ps_id
    FOR UPDATE OF PS.STATUS NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.lock_p()-' );
    END IF;
    EXCEPTION

        WHEN  OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_standard.debug('dump_debug: ' ||  'EXCEPTION: arp_ps_pkg.lock_p' );
	  END IF;
          raise;
END;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_payment_schedules rows identified by 	     |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_id 	- identifies the rows to lock	     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUL-96  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type )
          IS

    CURSOR LOCK_C IS
    SELECT        payment_schedule_id
    FROM          ar_payment_schedules
    WHERE         customer_trx_id = p_customer_trx_id
    FOR UPDATE OF payment_schedule_id NOWAIT;


BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('dump_debug: ' || 'arp_ps_pkg.lock_f_ct_id()+');
    END IF;

    OPEN lock_c;
    CLOSE lock_c;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('dump_debug: ' || 'arp_ps_pkg.lock_f_ct_id()-');
    END IF;

    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_util.debug('dump_debug: ' ||  'EXCEPTION: arp_ps_pkg.lock_f_ct_id' );
	    END IF;
            RAISE;  /* Bug-3874863 */
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |	NOWAITLOCK_P
 |                                                                           |
 | DESCRIPTION                                                               |
 |	This function locks a row in AR_PAYMENT_SCHEDULES table.
 |	If the row is already locked, return normal ORA-00054 error to
 |	indicate that row was already locked.
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ps_id - Payment Schedule Id                            |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY
 | 1/26/1996	Harri Kaukovuo		Created
 +===========================================================================*/
PROCEDURE nowaitlock_p(
	p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE ) IS
l_ps_id		ar_payment_schedules.payment_schedule_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.nowaitlock_p()+' );
       arp_standard.debug('dump_debug: ' ||  '-- Locking using payment_schedule_id = '||
	TO_CHAR(p_ps_id));
    END IF;

    /*----Bug 4923947 -----*/
   IF arp_view_constants.get_ps_selected_in_batch = 'Y' THEN

      SELECT ps.payment_schedule_id
      INTO   l_ps_id
      FROM  ar_payment_schedules ps
      WHERE ps.payment_schedule_id = p_ps_id
      FOR UPDATE OF PS.STATUS NOWAIT;

    ELSE

      SELECT ps.payment_schedule_id
      INTO   l_ps_id
      FROM  ar_payment_schedules ps
      WHERE ps.payment_schedule_id = p_ps_id
      AND ps.selected_for_receipt_batch_id IS NULL /* Bug fix 3264536 */
      FOR UPDATE OF PS.STATUS NOWAIT;

    END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.nowaitlock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug('dump_debug: ' ||
			'EXCEPTION: arp_ps_pkg.nowaitlock_p' );
	    END IF;
            RAISE;
END nowaitlock_p;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |      NOWAITLOCK_COMPARE_P
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This function locks a row in AR_PAYMENT_SCHEDULES table.
 |      If the row is already locked, return normal ORA-00054 error to
 |      indicate that row was already locked.
 |	This procedure will check also that amount_due_remaining is
 |	not changed.
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |	 NONE
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_ps_id 		Payment Schedule Id
 |		p_amount_due_remaining	Amount due remaining
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY
 | 5/17/1996    Harri Kaukovuo          Created
 +===========================================================================*/
PROCEDURE nowaitlock_compare_p(
          p_ps_id 			IN NUMBER
	, p_amount_due_remaining	IN NUMBER) IS
l_ps_id        NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.nowaitlock_compare_p()+' );
       arp_standard.debug('p_ps_id:'||to_char(p_ps_id) );
       arp_standard.debug('p_amount_due_remaining:'||to_char(p_amount_due_remaining) );

    END IF;

    SELECT ps.payment_schedule_id
    INTO   l_ps_id
    FROM  ar_payment_schedules ps
    WHERE       ps.payment_schedule_id  = p_ps_id
    AND         ps.amount_due_remaining = decode(ps.class,'PMT',ps.amount_due_remaining,p_amount_due_remaining)
    FOR UPDATE OF PS.amount_due_remaining NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('dump_debug: ' ||  'arp_ps_pkg.nowaitlock_compare_p()-' );
    END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  -- This is the case when row was changed
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
	  APP_EXCEPTION.Raise_Exception;

        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('dump_debug: ' ||
                        'EXCEPTION: arp_ps_pkg.nowaitlock_cmopare_p' );
	       arp_standard.debug('dump_debug: ' ||  '-- payment_schedule_id = '||
	        TO_CHAR(p_ps_id));
	       arp_standard.debug('dump_debug: ' ||  '-- amount_due_remaining = '||
	        TO_CHAR(p_amount_due_remaining));
	    END IF;

            RAISE;
END nowaitlock_compare_p;



PROCEDURE dump_debug (
p_ps_rec        IN ar_payment_schedules%ROWTYPE)
IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug ('dump_debug: ' || '-- DUMP OF PARAMETER VALUES:');
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.acctd_amount_due_remaining = '||
	TO_CHAR(p_ps_rec.acctd_amount_due_remaining));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_due_original = '||
	TO_CHAR(p_ps_rec.amount_due_original));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_due_remaining = '||
	TO_CHAR(p_ps_rec.amount_due_remaining));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.class = '||
	p_ps_rec.class);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.due_date = '||
	TO_CHAR(p_ps_rec.due_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.gl_date = '||
	TO_CHAR(p_ps_rec.gl_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.invoice_currency_code = '||
	p_ps_rec.invoice_currency_code);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.number_of_due_dates = '||
	TO_CHAR(p_ps_rec.number_of_due_dates));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.status = '||
	p_ps_rec.status);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.actual_date_closed = '||
	TO_CHAR(p_ps_rec.actual_date_closed));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.adjustment_amount_last = '||
	TO_CHAR(p_ps_rec.adjustment_amount_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.adjustment_date_last = '||
	TO_CHAR(p_ps_rec.adjustment_date_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.adjustment_gl_date_last = '||
	TO_CHAR(p_ps_rec.adjustment_gl_date_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.adjustment_id_last = '||
	TO_CHAR(p_ps_rec.adjustment_id_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_adjusted = '||
	TO_CHAR(p_ps_rec.amount_adjusted));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_adjusted_pending = '||
	TO_CHAR(p_ps_rec.amount_adjusted_pending));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_applied = '||
	TO_CHAR(p_ps_rec.amount_applied));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_credited = '||
	TO_CHAR(p_ps_rec.amount_credited));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_in_dispute = '||
	TO_CHAR(p_ps_rec.amount_in_dispute));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_line_items_original = '||
	TO_CHAR(p_ps_rec.amount_line_items_original));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.amount_line_items_remaining = '||
	TO_CHAR(p_ps_rec.amount_line_items_remaining));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.associated_cash_receipt_id = '||
	TO_CHAR(p_ps_rec.associated_cash_receipt_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.call_date_last = '||
	TO_CHAR(p_ps_rec.call_date_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_applied_amount_last = '||
	TO_CHAR(p_ps_rec.cash_applied_amount_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_applied_date_last = '||
	TO_CHAR(p_ps_rec.cash_applied_date_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_applied_id_last = '||
	TO_CHAR(p_ps_rec.cash_applied_id_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_applied_status_last = '||
	p_ps_rec.cash_applied_status_last);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_gl_date_last = '||
	TO_CHAR(p_ps_rec.cash_gl_date_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_receipt_amount_last = '||
	TO_CHAR(p_ps_rec.cash_receipt_amount_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_receipt_date_last = '||
	TO_CHAR(p_ps_rec.cash_receipt_date_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_receipt_id = '||
	TO_CHAR(p_ps_rec.cash_receipt_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_receipt_id_last = '||
	TO_CHAR(p_ps_rec.cash_receipt_id_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cash_receipt_status_last = '||
	p_ps_rec.cash_receipt_status_last);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.collector_last = '||
	TO_CHAR(p_ps_rec.collector_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.customer_id = '||
	TO_CHAR(p_ps_rec.customer_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.customer_site_use_id = '||
	TO_CHAR(p_ps_rec.customer_site_use_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.customer_trx_id = '||
	TO_CHAR(p_ps_rec.customer_trx_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cust_trx_type_id = '||
	TO_CHAR(p_ps_rec.cust_trx_type_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.discount_date = '||
	TO_CHAR(p_ps_rec.discount_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.discount_original = '||
	TO_CHAR(p_ps_rec.discount_original));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.discount_remaining = '||
	TO_CHAR(p_ps_rec.discount_remaining));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.discount_taken_earned = '||
	TO_CHAR(p_ps_rec.discount_taken_earned));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.discount_taken_unearned = '||
	TO_CHAR(p_ps_rec.discount_taken_unearned));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.exchange_date = '||
	TO_CHAR(p_ps_rec.exchange_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.exchange_rate = '||
	TO_CHAR(p_ps_rec.exchange_rate));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.exchange_rate_type = '||
	p_ps_rec.exchange_rate_type);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.follow_up_code_last = '||
	p_ps_rec.follow_up_code_last);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.follow_up_date_last = '||
	TO_CHAR(p_ps_rec.follow_up_date_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.freight_original = '||
	TO_CHAR(p_ps_rec.freight_original));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.freight_remaining = '||
	TO_CHAR(p_ps_rec.freight_remaining));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.gl_date_closed = '||
	TO_CHAR(p_ps_rec.gl_date_closed));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.in_collection = '||
	p_ps_rec.in_collection);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.promise_amount_last = '||
	TO_CHAR(p_ps_rec.promise_amount_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.promise_date_last = '||
	TO_CHAR(p_ps_rec.promise_date_last));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.receipt_confirmed_flag = '||
	p_ps_rec.receipt_confirmed_flag);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.receivables_charges_charged = '||
	TO_CHAR(p_ps_rec.receivables_charges_charged));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.receivables_charges_remaining = '||
	TO_CHAR(p_ps_rec.receivables_charges_remaining));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.reversed_cash_receipt_id = '||
	TO_CHAR(p_ps_rec.reversed_cash_receipt_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.selected_for_receipt_batch_id = '||
	TO_CHAR(p_ps_rec.selected_for_receipt_batch_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.tax_original = '||
	TO_CHAR(p_ps_rec.tax_original));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.tax_remaining = '||
	TO_CHAR(p_ps_rec.tax_remaining));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.terms_sequence_number = '||
	TO_CHAR(p_ps_rec.terms_sequence_number));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.term_id = '||
	TO_CHAR(p_ps_rec.term_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.trx_date = '||
	TO_CHAR(p_ps_rec.trx_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.trx_number = '||
	p_ps_rec.trx_number);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute_category = '||
	p_ps_rec.attribute_category);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute1 = '||
	p_ps_rec.attribute1);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute2 = '||
	p_ps_rec.attribute2);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute3 = '||
	p_ps_rec.attribute3);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute4 = '||
	p_ps_rec.attribute4);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute5 = '||
	p_ps_rec.attribute5);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute6 = '||
	p_ps_rec.attribute6);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute7 = '||
	p_ps_rec.attribute7);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute8 = '||
	p_ps_rec.attribute8);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute9 = '||
	p_ps_rec.attribute9);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute10 = '||
	p_ps_rec.attribute10);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute11 = '||
	p_ps_rec.attribute11);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute12 = '||
	p_ps_rec.attribute12);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute13 = '||
	p_ps_rec.attribute13);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute14 = '||
	p_ps_rec.attribute14);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.attribute15 = '||
	p_ps_rec.attribute15);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.dispute_date = '||
	TO_CHAR(p_ps_rec.dispute_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.last_charge_date = '||
	TO_CHAR(p_ps_rec.last_charge_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.second_last_charge_date = '||
	TO_CHAR(p_ps_rec.second_last_charge_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.br_amount_assigned = '||
	TO_CHAR(p_ps_rec.br_amount_assigned));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.reserved_type = '||
	p_ps_rec.reserved_type);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.reserved_value = '||
	TO_CHAR(p_ps_rec.reserved_value));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cons_inv_id = '||
	TO_CHAR(p_ps_rec.cons_inv_id));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.cons_inv_id_rev = '||
	TO_CHAR(p_ps_rec.cons_inv_id_rev));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.dunning_level_override_date = '||
	TO_CHAR(p_ps_rec.dunning_level_override_date));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.exclude_from_dunning_flag = '||
	p_ps_rec.exclude_from_dunning_flag);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.staged_dunning_level = '||
	TO_CHAR(p_ps_rec.staged_dunning_level));
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute_category = '||
	p_ps_rec.global_attribute_category);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute1 = '||
	p_ps_rec.global_attribute1);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute2 = '||
	p_ps_rec.global_attribute2);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute3 = '||
	p_ps_rec.global_attribute3);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute4 = '||
	p_ps_rec.global_attribute4);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute5 = '||
	p_ps_rec.global_attribute5);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute6 = '||
	p_ps_rec.global_attribute6);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute7 = '||
	p_ps_rec.global_attribute7);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute8 = '||
	p_ps_rec.global_attribute8);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute9 = '||
	p_ps_rec.global_attribute9);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute10 = '||
	p_ps_rec.global_attribute10);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute11 = '||
	p_ps_rec.global_attribute11);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute12 = '||
	p_ps_rec.global_attribute12);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute13 = '||
	p_ps_rec.global_attribute13);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute14 = '||
	p_ps_rec.global_attribute14);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute15 = '||
	p_ps_rec.global_attribute15);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute16 = '||
	p_ps_rec.global_attribute16);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute17 = '||
	p_ps_rec.global_attribute17);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute18 = '||
	p_ps_rec.global_attribute18);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute19 = '||
	p_ps_rec.global_attribute19);
       arp_standard.debug ('dump_debug: ' || '-- p_ps_rec.global_attribute20 = '||
	p_ps_rec.global_attribute20);
    END IF;

END dump_debug;

BEGIN
  pg_request_id             :=  arp_global.request_id;
  pg_program_application_id :=  arp_global.program_application_id;
  pg_program_id             :=  arp_global.program_id;
  pg_program_update_date    :=  arp_global.program_update_date;
  pg_last_updated_by        :=  arp_global.last_updated_by;
  pg_last_update_date       :=  arp_global.last_update_date;
  pg_last_update_login      :=  arp_global.last_update_login;
  pg_set_of_books_id        :=  arp_global.set_of_books_id;
END  ARP_PS_PKG;

/
