--------------------------------------------------------
--  DDL for Package Body ARP_CR_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CR_HISTORY_PKG" AS
/*$Header: ARRICRHB.pls 120.10.12010000.1 2008/07/24 16:52:13 appldev ship $*/
--
--
--
  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/
--
  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');
--
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
  pg_set_of_books_id            number;
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE set_to_dummy( p_crh_rec    OUT NOCOPY  ar_cash_receipt_history%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.set_to_dummy()+' );
    END IF;
    --
    p_crh_rec.amount := AR_NUMBER_DUMMY;
    p_crh_rec.acctd_amount := AR_NUMBER_DUMMY;
    p_crh_rec.factor_flag := AR_FLAG_DUMMY;
    p_crh_rec.first_posted_record_flag := AR_FLAG_DUMMY;
    p_crh_rec.gl_date := AR_DATE_DUMMY;
    p_crh_rec.postable_flag := AR_FLAG_DUMMY;
    p_crh_rec.status := AR_TEXT_DUMMY;
    p_crh_rec.trx_date := AR_DATE_DUMMY;
    p_crh_rec.acctd_factor_discount_amount := AR_NUMBER_DUMMY;
    p_crh_rec.account_code_combination_id := AR_NUMBER_DUMMY;
    p_crh_rec.bank_charge_account_ccid := AR_NUMBER_DUMMY;
    p_crh_rec.batch_id := AR_NUMBER_DUMMY;
    p_crh_rec.current_record_flag := AR_FLAG_DUMMY;
    p_crh_rec.exchange_date := AR_DATE_DUMMY;
    p_crh_rec.exchange_rate := AR_NUMBER_DUMMY;
    p_crh_rec.exchange_rate_type := AR_TEXT_DUMMY;
    p_crh_rec.factor_discount_amount := AR_NUMBER_DUMMY;
    p_crh_rec.gl_posted_date := AR_DATE_DUMMY;
    p_crh_rec.posting_control_id := AR_NUMBER_DUMMY;
    p_crh_rec.reversal_cash_receipt_hist_id := AR_NUMBER_DUMMY;
    p_crh_rec.reversal_gl_date := AR_DATE_DUMMY;
    p_crh_rec.reversal_gl_posted_date := AR_DATE_DUMMY;
    p_crh_rec.reversal_posting_control_id := AR_NUMBER_DUMMY;
    p_crh_rec.prv_stat_cash_receipt_hist_id := AR_NUMBER_DUMMY;
    p_crh_rec.reversal_created_from := AR_TEXT_DUMMY;
    p_crh_rec.attribute_category := AR_TEXT_DUMMY;
    p_crh_rec.attribute1 := AR_TEXT_DUMMY;
    p_crh_rec.attribute2 := AR_TEXT_DUMMY;
    p_crh_rec.attribute3 := AR_TEXT_DUMMY;
    p_crh_rec.attribute4 := AR_TEXT_DUMMY;
    p_crh_rec.attribute5 := AR_TEXT_DUMMY;
    p_crh_rec.attribute6 := AR_TEXT_DUMMY;
    p_crh_rec.attribute7 := AR_TEXT_DUMMY;
    p_crh_rec.attribute8 := AR_TEXT_DUMMY;
    p_crh_rec.attribute9 := AR_TEXT_DUMMY;
    p_crh_rec.attribute10 := AR_TEXT_DUMMY;
    p_crh_rec.attribute11 := AR_TEXT_DUMMY;
    p_crh_rec.attribute12 := AR_TEXT_DUMMY;
    p_crh_rec.attribute13 := AR_TEXT_DUMMY;
    p_crh_rec.attribute14 := AR_TEXT_DUMMY;
    p_crh_rec.attribute15 := AR_TEXT_DUMMY;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.set_to_dummy()-' );
    END IF;
    --
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_cr_history_pkg.set_to_dummy' );
            END IF;
            RAISE;
END set_to_dummy;
--
-- New update_p procedure
--
PROCEDURE update_p( p_crh_rec    IN  ar_cash_receipt_history%ROWTYPE,
         p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.update_p()+' );
    END IF;
    --
    UPDATE ar_cash_receipt_history SET
 		   amount = DECODE( p_crh_rec.amount,
                                AR_NUMBER_DUMMY, amount,
                                p_crh_rec.amount ),
 		   acctd_amount = DECODE( p_crh_rec.acctd_amount,
                                AR_NUMBER_DUMMY, acctd_amount,
                                p_crh_rec.acctd_amount ),
 		   factor_flag = DECODE( p_crh_rec.factor_flag,
                                AR_FLAG_DUMMY, factor_flag,
                                p_crh_rec.factor_flag ),
 		   first_posted_record_flag =
				DECODE( p_crh_rec.first_posted_record_flag,
                                AR_FLAG_DUMMY, first_posted_record_flag,
                                p_crh_rec.first_posted_record_flag ),
 		   gl_date = DECODE( p_crh_rec.gl_date,
                                AR_DATE_DUMMY, gl_date,
                                p_crh_rec.gl_date ),
 		   postable_flag = DECODE( p_crh_rec.postable_flag,
                                AR_FLAG_DUMMY, postable_flag,
                                p_crh_rec.postable_flag ),
 		   status = DECODE( p_crh_rec.status,
                                AR_TEXT_DUMMY, status,
                                p_crh_rec.status ),
 		   trx_date = DECODE( p_crh_rec.trx_date,
                                AR_DATE_DUMMY, trx_date,
                                p_crh_rec.trx_date ),
 		   acctd_factor_discount_amount =
				DECODE( p_crh_rec.acctd_factor_discount_amount,
                                AR_NUMBER_DUMMY, acctd_factor_discount_amount,
                                p_crh_rec.acctd_factor_discount_amount ),
 		   account_code_combination_id =
				DECODE( p_crh_rec.account_code_combination_id,
                                AR_NUMBER_DUMMY, account_code_combination_id,
                                p_crh_rec.account_code_combination_id ),
 		   bank_charge_account_ccid =
				DECODE( p_crh_rec.bank_charge_account_ccid,
                                AR_NUMBER_DUMMY, bank_charge_account_ccid,
                                p_crh_rec.amount ),
 		   batch_id = DECODE( p_crh_rec.batch_id,
                                AR_NUMBER_DUMMY, batch_id,
                                p_crh_rec.batch_id ),
 		   current_record_flag = DECODE( p_crh_rec.current_record_flag,
                                AR_FLAG_DUMMY, current_record_flag,
                                p_crh_rec.current_record_flag ),
 		   exchange_date = DECODE( p_crh_rec.exchange_date,
                                AR_DATE_DUMMY, exchange_date,
                                p_crh_rec.exchange_date ),
 		   exchange_rate = DECODE( p_crh_rec.exchange_rate,
                                AR_NUMBER_DUMMY, exchange_rate,
                                p_crh_rec.exchange_rate ),
 		   exchange_rate_type = DECODE( p_crh_rec.exchange_rate_type,
                                AR_TEXT_DUMMY, exchange_rate_type,
                                p_crh_rec.exchange_rate_type ),
 		   factor_discount_amount =
				DECODE( p_crh_rec.factor_discount_amount,
                                AR_NUMBER_DUMMY, factor_discount_amount,
                                p_crh_rec.factor_discount_amount ),
 		   gl_posted_date = DECODE( p_crh_rec.gl_posted_date,
                                AR_DATE_DUMMY, gl_posted_date,
                                p_crh_rec.gl_posted_date ),
 		   posting_control_id = DECODE( p_crh_rec.posting_control_id,
                                AR_NUMBER_DUMMY, posting_control_id,
                                p_crh_rec.posting_control_id ),
 		   reversal_cash_receipt_hist_id =
				DECODE( p_crh_rec.reversal_cash_receipt_hist_id,
                                AR_NUMBER_DUMMY, reversal_cash_receipt_hist_id,
                                p_crh_rec.reversal_cash_receipt_hist_id ),
 		   reversal_gl_date = DECODE( p_crh_rec.reversal_gl_date,
                                AR_DATE_DUMMY, reversal_gl_date,
                                p_crh_rec.reversal_gl_date ),
 		   reversal_gl_posted_date =
				DECODE( p_crh_rec.reversal_gl_posted_date,
                                AR_DATE_DUMMY, reversal_gl_posted_date,
                                p_crh_rec.reversal_gl_posted_date ),
 		   reversal_posting_control_id =
				DECODE( p_crh_rec.reversal_posting_control_id,
                                AR_NUMBER_DUMMY, reversal_posting_control_id,
                                p_crh_rec.reversal_posting_control_id ),
 		   request_id = pg_request_id,
 		   program_application_id =
			       pg_program_application_id,
 		   program_id = pg_program_id,
 		   program_update_date =  pg_program_update_date,
 		   last_updated_by = pg_last_updated_by,
 		   last_update_date = pg_last_update_date,
 		   last_update_login = pg_last_update_login,
 		   prv_stat_cash_receipt_hist_id =
				DECODE( p_crh_rec.prv_stat_cash_receipt_hist_id,
                                AR_NUMBER_DUMMY, prv_stat_cash_receipt_hist_id,
                                p_crh_rec.prv_stat_cash_receipt_hist_id ),
 		   reversal_created_from =
				DECODE( p_crh_rec.reversal_created_from,
                                AR_TEXT_DUMMY, reversal_created_from,
                                p_crh_rec.reversal_created_from ),
 		   attribute_category = DECODE( p_crh_rec.attribute_category,
                                AR_TEXT_DUMMY, attribute_category,
                                p_crh_rec.attribute_category ),
 		   attribute1 = DECODE( p_crh_rec.attribute1,
                                AR_TEXT_DUMMY, attribute1,
                                p_crh_rec.attribute1 ),
 		   attribute2 = DECODE( p_crh_rec.attribute2,
                                AR_TEXT_DUMMY, attribute2,
                                p_crh_rec.attribute2 ),
 		   attribute3 = DECODE( p_crh_rec.attribute3,
                                AR_TEXT_DUMMY, attribute3,
                                p_crh_rec.attribute3 ),
 		   attribute4 = DECODE( p_crh_rec.attribute4,
                                AR_TEXT_DUMMY, attribute3,
                                p_crh_rec.attribute4 ),
 		   attribute5 = DECODE( p_crh_rec.attribute5,
                                AR_TEXT_DUMMY, attribute5,
                                p_crh_rec.attribute5 ),
 		   attribute6 = DECODE( p_crh_rec.attribute6,
                                AR_TEXT_DUMMY, attribute2,
                                p_crh_rec.attribute6 ),
 		   attribute7 = DECODE( p_crh_rec.attribute7,
                                AR_TEXT_DUMMY, attribute2,
                                p_crh_rec.attribute7 ),
 		   attribute8 = DECODE( p_crh_rec.attribute8,
                                AR_TEXT_DUMMY, attribute8,
                                p_crh_rec.attribute8 ),
 		   attribute9 = DECODE( p_crh_rec.attribute9,
                                AR_TEXT_DUMMY, attribute9,
                                p_crh_rec.attribute9 ),
 		   attribute10 = DECODE( p_crh_rec.attribute10,
                                AR_TEXT_DUMMY, attribute10,
                                p_crh_rec.attribute10 ),
 		   attribute11 = DECODE( p_crh_rec.attribute11,
                                AR_TEXT_DUMMY, attribute11,
                                p_crh_rec.attribute11 ),
 		   attribute12 = DECODE( p_crh_rec.attribute12,
                                AR_TEXT_DUMMY, attribute12,
                                p_crh_rec.attribute12 ),
 		   attribute13 = DECODE( p_crh_rec.attribute13,
                                AR_TEXT_DUMMY, attribute13,
                                p_crh_rec.attribute13 ),
 		   attribute14 = DECODE( p_crh_rec.attribute14,
                                AR_TEXT_DUMMY, attribute14,
                                p_crh_rec.attribute14 ),
 		   attribute15 = DECODE( p_crh_rec.attribute15,
                                AR_TEXT_DUMMY, attribute15,
                                p_crh_rec.attribute15 )
    WHERE cash_receipt_history_id = p_crh_rec.cash_receipt_history_id;
    --
  /*----------------------------------------------------+
    |  Call central MRC library for the generic update   |
    |  made above.   This is done here rather then in    |
    |  the generic update as the where clause changes    |
    |  and that information is needed for the MRC engine |
    +----------------------------------------------------*/

    ar_mrc_engine.maintain_mrc_data(
                  p_event_mode       => 'UPDATE',
                  p_table_name       => 'AR_CASH_RECEIPT_HISTORY',
                  p_mode             => 'SINGLE',
                  p_key_value        => p_crh_rec.cash_receipt_history_id
                                   );

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.update_p()-' );
    END IF;
    --
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_cr_history_pkg.update_p' );
            END IF;
            RAISE;
END update_p;
--
PROCEDURE insert_p(
	p_crh_rec 	IN ar_cash_receipt_history%ROWTYPE,
	p_crh_id	OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
--
l_crh_id	ar_cash_receipt_history.cash_receipt_history_id%TYPE;
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_p: ' ||  'arp_cr_history_pkg.insert_p()+' );
      END IF;
      --
      SELECT ar_cash_receipt_history_s.nextval
      INTO   l_crh_id
      FROM   dual;
      --
      INSERT INTO  ar_cash_receipt_history (
		   cash_receipt_history_id,
 		   amount,
 		   acctd_amount,
 		   cash_receipt_id,
 		   factor_flag,
 		   first_posted_record_flag,
 		   gl_date,
 		   postable_flag,
 		   status,
 		   trx_date,
 		   acctd_factor_discount_amount,
 		   account_code_combination_id,
 		   bank_charge_account_ccid,
 		   batch_id,
 		   current_record_flag,
 		   exchange_date,
 		   exchange_rate,
 		   exchange_rate_type,
 		   factor_discount_amount,
 		   gl_posted_date,
 		   posting_control_id,
 		   reversal_cash_receipt_hist_id,
 		   reversal_gl_date,
 		   reversal_gl_posted_date,
 		   reversal_posting_control_id,
 		   request_id,
 		   program_application_id,
 		   program_id,
 		   program_update_date,
 		   created_by,
 		   creation_date,
 		   last_updated_by,
 		   last_update_date,
 		   last_update_login,
 		   prv_stat_cash_receipt_hist_id,
 		   created_from,
 		   reversal_created_from,
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
 		   attribute15
                   ,org_id
 		 )
       VALUES (    l_crh_id,
 		   p_crh_rec.amount,
 		   p_crh_rec.acctd_amount,
 		   p_crh_rec.cash_receipt_id,
 		   p_crh_rec.factor_flag,
 		   p_crh_rec.first_posted_record_flag,
 		   p_crh_rec.gl_date,
 		   p_crh_rec.postable_flag,
 		   p_crh_rec.status,
 		   p_crh_rec.trx_date,
 		   p_crh_rec.acctd_factor_discount_amount,
 		   p_crh_rec.account_code_combination_id,
 		   p_crh_rec.bank_charge_account_ccid,
 		   p_crh_rec.batch_id,
 		   p_crh_rec.current_record_flag,
 		   p_crh_rec.exchange_date,
 		   p_crh_rec.exchange_rate,
 		   p_crh_rec.exchange_rate_type,
 		   p_crh_rec.factor_discount_amount,
 		   p_crh_rec.gl_posted_date,
 		   p_crh_rec.posting_control_id,
 		   p_crh_rec.reversal_cash_receipt_hist_id,
 		   p_crh_rec.reversal_gl_date,
 		   p_crh_rec.reversal_gl_posted_date,
 		   p_crh_rec.reversal_posting_control_id,
 		   NVL( arp_standard.profile.request_id, p_crh_rec.request_id ),
 		   NVL( arp_standard.profile.program_application_id,
			p_crh_rec.program_application_id ),
 		   NVL( arp_standard.profile.program_id,
			p_crh_rec.program_id ),
		   DECODE( arp_standard.profile.program_id,
                           NULL, NULL,
                           SYSDATE
                         ),
		   arp_global.last_updated_by, /* FP Bug 5715840 arp_standard.profile.user_id,*/
 		   SYSDATE,
		   arp_global.last_updated_by, /* FP Bug 5715840 arp_standard.profile.user_id,*/
 		   SYSDATE,
		   NVL( arp_global.last_update_login,
                        p_crh_rec.last_update_login ),
 		   p_crh_rec.prv_stat_cash_receipt_hist_id,
 		   p_crh_rec.created_from,
 		   p_crh_rec.reversal_created_from,
 		   p_crh_rec.attribute_category,
 		   p_crh_rec.attribute1,
 		   p_crh_rec.attribute2,
 		   p_crh_rec.attribute3,
 		   p_crh_rec.attribute4,
 		   p_crh_rec.attribute5,
 		   p_crh_rec.attribute6,
 		   p_crh_rec.attribute7,
 		   p_crh_rec.attribute8,
 		   p_crh_rec.attribute9,
 		   p_crh_rec.attribute10,
 		   p_crh_rec.attribute11,
 		   p_crh_rec.attribute12,
 		   p_crh_rec.attribute13,
 		   p_crh_rec.attribute14,
 		   p_crh_rec.attribute15
                  ,arp_standard.sysparm.org_id /* SSA changes anuj */
	       );
    --
   /*-------------------------------------------+
    | Call central MRC library for insertion    |
    | into MRC tables                           |
    +-------------------------------------------*/

   ar_mrc_engine.maintain_mrc_data(
                         p_event_mode         => 'INSERT',
                         p_table_name         => 'AR_CASH_RECEIPT_HISTORY',
                         p_mode               => 'SINGLE',
                         p_key_value          => l_crh_id);

    p_crh_id := l_crh_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_p: ' ||  'arp_cr_history_pkg.insert_p()-' );
    END IF;
    --
    EXCEPTION
	WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug('update_p: ' ||  'EXCEPTION: arp_cr_history_pkg.insert_p' );
	    END IF;
	    RAISE;
END insert_p;
--
-- Old update_p procedure retianed for compatibiltiy sake
--
PROCEDURE update_p( p_crh_rec 	IN ar_cash_receipt_history%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.update_p()+' );
    END IF;
    --
    UPDATE ar_cash_receipt_history SET
 		   amount = p_crh_rec.amount,
 		   acctd_amount = p_crh_rec.acctd_amount,
 		   factor_flag = p_crh_rec.factor_flag,
 		   first_posted_record_flag =
					p_crh_rec.first_posted_record_flag,
 		   gl_date = p_crh_rec.gl_date,
 		   postable_flag = p_crh_rec.postable_flag,
 		   status = p_crh_rec.status,
 		   trx_date = p_crh_rec.trx_date,
 		   acctd_factor_discount_amount =
					p_crh_rec.acctd_factor_discount_amount,
 		   account_code_combination_id =
					p_crh_rec.account_code_combination_id,
 		   bank_charge_account_ccid = p_crh_rec.bank_charge_account_ccid,
 		   batch_id = p_crh_rec.batch_id,
 		   current_record_flag = p_crh_rec.current_record_flag,
 		   exchange_date = p_crh_rec.exchange_date,
 		   exchange_rate = p_crh_rec.exchange_rate,
 		   exchange_rate_type = p_crh_rec.exchange_rate_type,
 		   factor_discount_amount = p_crh_rec.factor_discount_amount,
 		   gl_posted_date = p_crh_rec.gl_posted_date,
 		   posting_control_id = p_crh_rec.posting_control_id,
 		   reversal_cash_receipt_hist_id =
				p_crh_rec.reversal_cash_receipt_hist_id,
 		   reversal_gl_date = p_crh_rec.reversal_gl_date,
 		   reversal_gl_posted_date = p_crh_rec.reversal_gl_posted_date,
 		   reversal_posting_control_id =
					p_crh_rec.reversal_posting_control_id,
 		   request_id = NVL( arp_standard.profile.request_id,
				     p_crh_rec.request_id ),
 		   program_application_id =
			       NVL( arp_standard.profile.program_application_id,
				    p_crh_rec.program_application_id ),
 		   program_id = NVL( arp_standard.profile.program_id,
				     p_crh_rec.program_id ),
 		   program_update_date =
				DECODE( arp_standard.profile.program_id,
                                        NULL, NULL,
                                        SYSDATE
                                      ),
 		   last_updated_by = arp_global.last_updated_by, /* FP Bug 5715840 arp_standard.profile.user_id,*/
 		   last_update_date = SYSDATE,
 		   last_update_login =
				NVL( arp_global.last_update_login,
				     p_crh_rec.last_update_login ),
 		   prv_stat_cash_receipt_hist_id =
					p_crh_rec.prv_stat_cash_receipt_hist_id,
 		   created_from = p_crh_rec.created_from,
 		   reversal_created_from = p_crh_rec.reversal_created_from,
 		   attribute_category = p_crh_rec.attribute_category,
 		   attribute1 = p_crh_rec.attribute1,
 		   attribute2 = p_crh_rec.attribute2,
 		   attribute3 = p_crh_rec.attribute3,
 		   attribute4 = p_crh_rec.attribute4,
 		   attribute5 = p_crh_rec.attribute5,
 		   attribute6 = p_crh_rec.attribute6,
 		   attribute7 = p_crh_rec.attribute7,
 		   attribute8 = p_crh_rec.attribute8,
 		   attribute9 = p_crh_rec.attribute9,
 		   attribute10 = p_crh_rec.attribute10,
 		   attribute11 = p_crh_rec.attribute11,
 		   attribute12 = p_crh_rec.attribute12,
 		   attribute13 = p_crh_rec.attribute13,
 		   attribute14 = p_crh_rec.attribute14,
 		   attribute15 = p_crh_rec.attribute15
    WHERE cash_receipt_history_id = p_crh_rec.cash_receipt_history_id;
    --

 /*----------------------------------------------------+
    |  Call central MRC library for the generic update   |
    |  made above.   This is done here rather then in    |
    |  the generic update as the where clause changes    |
    |  and that information is needed for the MRC engine |
    +----------------------------------------------------*/

    ar_mrc_engine.maintain_mrc_data(
                  p_event_mode       => 'UPDATE',
                  p_table_name       => 'AR_CASH_RECEIPT_HISTORY',
                  p_mode             => 'SINGLE',
                  p_key_value        => p_crh_rec.cash_receipt_history_id
                                   );

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.update_p()-' );
    END IF;
    --
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_cr_history_pkg.update_p' );
            END IF;
            RAISE;
END update_p;
--
PROCEDURE delete_p(
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.delete_p()+' );
    END IF;
    --
    DELETE FROM ar_cash_receipt_history
    WHERE cash_receipt_history_id = p_crh_id;
    --
   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/

    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode => 'DELETE',
                        p_table_name => 'AR_CASH_RECEIPT_HISTORY',
                        p_mode       => 'SINGLE',
                        p_key_value  => p_crh_id);


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.delete_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_cr_history_pkg.delete_p' );
            END IF;
            RAISE;
END delete_p;
--
PROCEDURE delete_p_cr(
        p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE ) IS

	l_rec_hist_key_value_list  gl_ca_utility_pkg.r_key_value_arr;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.delete_p_cr()+' );
    END IF;
    --
    DELETE FROM ar_cash_receipt_history
    WHERE cash_receipt_id = p_cr_id
    RETURNING cash_receipt_history_id
    BULK COLLECT INTO l_rec_hist_key_value_list;

  /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/

    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode      => 'DELETE',
                        p_table_name      => 'AR_CASH_RECEIPT_HISTORY',
                        p_mode            => 'BATCH',
                        p_key_value_list  => l_rec_hist_key_value_list
				);
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.delete_p_cr()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_cr_history_pkg.delete_p_cr' );
            END IF;
            RAISE;
END delete_p_cr;
--
PROCEDURE lock_p(
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
l_crh_id		ar_cash_receipt_history.cash_receipt_history_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_p()+' );
    END IF;
    --
    SELECT cash_receipt_history_id
    INTO   l_crh_id
    FROM  ar_cash_receipt_history
    WHERE cash_receipt_history_id = p_crh_id
    FOR UPDATE OF STATUS;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCPETION: arp_cr_history_pkg.lock_p' );
            END IF;
            RAISE;
END lock_p;
--
PROCEDURE nowaitlock_p(
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
l_crh_id		ar_cash_receipt_history.cash_receipt_history_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_p()+' );
    END IF;
    --
    SELECT cash_receipt_history_id
    INTO   l_crh_id
    FROM  ar_cash_receipt_history
    WHERE cash_receipt_history_id = p_crh_id
    FOR UPDATE OF status NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCPETION: arp_cr_history_pkg.nowaitlock_p' );
            END IF;
            RAISE;
END nowaitlock_p;
--
PROCEDURE fetch_p(
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE,
        p_crh_rec OUT NOCOPY ar_cash_receipt_history%ROWTYPE ) IS
BEGIN
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_crh_rec
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_history_id = p_crh_id;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.fetch_p()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug( 'EXCEPTION: arp_cr_history_pkg.fetch_p' );
              END IF;
              RAISE;
END fetch_p;
--
PROCEDURE fetch_f_crid(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_crh_rec OUT NOCOPY ar_cash_receipt_history%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.fetch_f_crid()+' );
    END IF;
    --
    SELECT *
    INTO   p_crh_rec
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_id = p_cr_id AND
           current_record_flag = 'Y'
    FOR UPDATE OF status;

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.fetch_f_crid()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('fetch_f_crid: ' ||
			'EXCEPTION: arp_cr_history_pkg.fetch_f_crid' );
              END IF;
              RAISE;
END fetch_f_crid;
--
--
PROCEDURE fetch_f_cr_id(
        p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.fetch_f_cr_id()+' );
    END IF;
    --
    SELECT *
    INTO   p_crh_rec
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_id = p_crh_rec.cash_receipt_id AND
           current_record_flag = 'Y';
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.fetch_f_cr_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('fetch_f_cr_id: ' ||
			'EXCEPTION: arp_cr_history_pkg.fetch_f_cr_id' );
              END IF;
              RAISE;
END fetch_f_cr_id;
--
--
PROCEDURE lock_fetch_p(
                   p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_crh_rec
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_history_id = p_crh_rec.cash_receipt_history_id
    FOR UPDATE OF status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_fetch_p()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('lock_fetch_p: ' ||
			'EXCEPTION: arp_cr_history_pkg.lock_fetch_p' );
              END IF;
              RAISE;
END lock_fetch_p;
--
--
PROCEDURE nowaitlock_fetch_p(
                   p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_crh_rec
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_history_id = p_crh_rec.cash_receipt_history_id
    FOR UPDATE OF status NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_fetch_p()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('nowaitlock_fetch_p: ' ||
			'EXCEPTION: arp_cr_history_pkg.nowaitlock_fetch_p' );
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
FROM   ar_cash_receipt_history
WHERE  batch_id = p_batch_id
FOR UPDATE OF status;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_f_batch_id()+' );
    END IF;
    --
    OPEN lock_C;
    CLOSE lock_C;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_f_batch_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
	      IF lock_C%ISOPEN THEN
   	         CLOSE lock_C;
	      END IF;
           --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('lock_f_batch_id: ' ||
			'EXCEPTION: arp_cr_history_pkg.lock_f_batch_id' );
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
FROM   ar_cash_receipt_history
WHERE  batch_id = p_batch_id
FOR UPDATE OF status NOWAIT;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_f_batch_id()+' );
    END IF;
    --
    OPEN lock_C;
    CLOSE lock_C;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_f_batch_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
	      IF lock_C%ISOPEN THEN
   	         CLOSE lock_C;
	      END IF;
           --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('nowaitlock_f_batch_id: ' ||
			'EXCEPTION: arp_cr_history_pkg.nowaitlock_f_batch_id' );
              END IF;
              RAISE;
END nowaitlock_f_batch_id;
--
--
PROCEDURE lock_f_cr_id(
                   p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE ) IS
--
CURSOR lock_C IS
SELECT 'lock'
FROM   ar_cash_receipt_history
WHERE  cash_receipt_id = p_cr_id
FOR UPDATE OF status;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_f_cr_id()+' );
    END IF;
    --
    OPEN lock_C;
    CLOSE lock_C;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_f_cr_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
	      IF lock_C%ISOPEN THEN
   	         CLOSE lock_C;
	      END IF;
              --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('lock_f_cr_id: ' ||
			'EXCEPTION: arp_cr_history_pkg.lock_f_cr_id' );
              END IF;
              RAISE;
END lock_f_cr_id;
--
--
PROCEDURE nowaitlock_f_cr_id(
                   p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE ) IS
--
CURSOR lock_C IS
SELECT 'lock'
FROM   ar_cash_receipt_history
WHERE  cash_receipt_id = p_cr_id
FOR UPDATE OF status NOWAIT;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_f_cr_id()+' );
    END IF;
    --
    OPEN lock_C;
    CLOSE lock_C;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_f_cr_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
	      IF lock_C%ISOPEN THEN
   	         CLOSE lock_C;
	      END IF;
              --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('nowaitlock_f_cr_id: ' ||
			'EXCEPTION: arp_cr_history_pkg.nowaitlock_f_cr_id' );
              END IF;
              RAISE;
END nowaitlock_f_cr_id;
--
PROCEDURE lock_fetch_f_cr_id(
                   p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_fetch_f_cr_id()+' );
    END IF;
    --
    SELECT *
    INTO   p_crh_rec
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_id = p_crh_rec.cash_receipt_id
    AND    current_record_flag = 'Y'
    FOR UPDATE OF status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.lock_fetch_f_cr_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('lock_fetch_f_cr_id: ' ||
			'EXCEPTION: arp_cr_history_pkg.lock_fetch_f_cr_id' );
              END IF;
              RAISE;
END lock_fetch_f_cr_id;
--
--
PROCEDURE nowaitlock_fetch_f_cr_id(
                   p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_fetch_f_cr_id()+' );
    END IF;
    --
    SELECT *
    INTO   p_crh_rec
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_id = p_crh_rec.cash_receipt_id
    AND    current_record_flag = 'Y'
    FOR UPDATE OF status NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_history_pkg.nowaitlock_fetch_f_cr_id()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('nowaitlock_fetch_f_cr_id: ' ||
			'EXCEPTION: arp_cr_history_pkg.nowaitlock_fetch_f_cr_id' );
              END IF;
              RAISE;
END nowaitlock_fetch_f_cr_id;
--
/* Bug fix 2742388 */
PROCEDURE lock_hist_compare_p(
                  p_crh_rec IN ar_cash_receipt_history%ROWTYPE) IS
  l_new_crh_rec   ar_cash_receipt_history%ROWTYPE;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_cr_history_pkg.lock_hist_compare_p()+');
     arp_util.debug(' Cash receipt_id = '||to_char(p_crh_rec.cash_receipt_id));
     arp_util.debug('History_id = '||to_char(p_crh_rec.cash_receipt_history_id));
     arp_util.debug('Amount = '||to_char(p_crh_rec.amount));
     arp_util.debug('Status ='||p_crh_rec.status);
     arp_util.debug('PC IS = '||to_char(p_crh_rec.posting_control_id));
  END IF;
  /*4354354 included nvl(factor_discount_amount,0) in the existing amount condition*/
  SELECT *
  INTO
         l_new_crh_rec
  FROM
         ar_cash_receipt_history crh
  WHERE
         crh.cash_receipt_history_id = p_crh_rec.cash_receipt_history_id
  AND    crh.cash_receipt_id = p_crh_rec.cash_receipt_id
  AND
      NVL((crh.amount+NVL(crh.factor_discount_amount,0)), AR_NUMBER_DUMMY) =
      NVL(
           DECODE(p_crh_rec.amount,
                  AR_NUMBER_DUMMY, (crh.amount+NVL(crh.factor_discount_amount,0)),
                  p_crh_rec.amount),
           AR_NUMBER_DUMMY
          )
AND
      NVL(crh.status , AR_TEXT_DUMMY) =
      NVL(
           DECODE(p_crh_rec.status ,
                AR_TEXT_DUMMY, crh.status,
                                p_crh_rec.status),
           AR_TEXT_DUMMY
          )
AND  NVL(crh.posting_control_id,AR_NUMBER_DUMMY) =
     NVL(
         DECODE(p_crh_rec.posting_control_id,
                AR_NUMBER_DUMMY,crh.posting_control_id,
                p_crh_rec.posting_control_id),
         AR_NUMBER_DUMMY
        )
AND  NVL(crh.current_record_flag,AR_FLAG_DUMMY) = 'Y'
     FOR UPDATE NOWAIT;
     arp_util.debug('arp_cr_history_pkg.lock_hist_compare_p()-');
EXCEPTION
     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: arp_cr_history_pkg.lock_hist_compare_p()');
        END IF;
     RAISE;
END lock_hist_compare_p;
/* End bug fix 2742388 */


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
  pg_set_of_books_id        :=  arp_global.set_of_books_id;
--
END ARP_CR_HISTORY_PKG;

/
