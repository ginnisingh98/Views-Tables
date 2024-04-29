--------------------------------------------------------
--  DDL for Package Body ARP_CR_ICR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CR_ICR_PKG" AS
/* $Header: ARRIICRB.pls 120.8.12010000.2 2009/02/02 16:52:56 mpsingh ship $*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
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
--
  /*---------------------------------------------------------------+
   |  Package global variable to hold the parsed update cursor.    |
   |  This allows the cursors to be reused without being reparsed. |
   +---------------------------------------------------------------*/
--
  pg_cursor1  integer := '';
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
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row into AR_INTERIM_CASH_RECEIPTS              |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                    p_icr_rec - ICR Record structure                       |
 |              OUT:                                                         |
 |                    p_icr_id - ICR Id   of inserted ICR row                |
 |                    p_row_id - Row Id   of inserted ICR row                |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This is an overloaded procedure                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_p( p_row_id  OUT NOCOPY VARCHAR2,
                    p_cr_id  OUT NOCOPY ar_interim_cash_receipts.cash_receipt_id%TYPE,
                    p_icr_rec 	IN ar_interim_cash_receipts%ROWTYPE ) IS
l_cr_id    ar_interim_cash_receipts.cash_receipt_id%TYPE;
l_row_id    VARCHAR2( 20 );
BEGIN
    arp_standard.debug( 'arp_cr_icr_pkg.insert_p()+' );
    --
    arp_cr_icr_pkg.insert_p( p_icr_rec, l_cr_id );
    --
    SELECT ROWID
    INTO   l_row_id
    FROM   ar_interim_cash_receipts
    WHERE  cash_receipt_id = l_cr_id;
    --
    p_cr_id := l_cr_id;
    p_row_id := l_row_id;
    --
    arp_standard.debug( 'arp_cr_icr_pkg.insert_p()-' );
    --
    EXCEPTION
	WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_pkg.insert_p' );
	    RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row into AR_INTERIM_CASH_RECEIPTS              |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                    p_icr_rec - ICR Record structure                       |
 |              OUT:                                                         |
 |                    p_.at_id - ICR Id   of inserted ICR row                |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This is an overloaded procedure                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 | 10/28/98     K.Murphy  Cross Currency Lockbox.                            |
 |                        Added amount_applied and trans_to_receipt_rate     |
 |                        as created columns.                                |
 | 05/01/02     D.Jancis  Enh 2074200:  Added application_notes              |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason.                           |
 +===========================================================================*/
PROCEDURE insert_p( p_icr_rec 	IN ar_interim_cash_receipts%ROWTYPE,
       p_icr_id OUT NOCOPY ar_interim_cash_receipts.cash_receipt_id%TYPE ) IS
l_icr_id    ar_interim_cash_receipts.cash_receipt_id%TYPE;
BEGIN
      arp_standard.debug( '>>>>>>>> arp_cr_icr_pkg.insert_p' );
      --
      SELECT ar_cash_receipts_s.nextval
      INTO   l_icr_id
      FROM   dual;
      --
      INSERT INTO  ar_interim_cash_receipts (
		   cash_receipt_id,
 		   amount,
                   amount_applied,
                   trans_to_receipt_rate,
		   factor_discount_amount,
 		   created_by,
 		   creation_date,
 		   currency_code,
 		   last_updated_by,
 		   last_update_date,
 		   receipt_method_id,
 		   remit_bank_acct_use_id,
 		   batch_id,
 		   comments,
 		   customer_trx_id,
 		   exchange_date,
 		   exchange_rate,
 		   exchange_rate_type,
 		   gl_date,
 		   gl_posted_date,
		   anticipated_clearing_date,
 		   last_update_login,
 		   payment_schedule_id,
 		   pay_from_customer,
 		   program_application_id,
 		   program_id,
 		   program_update_date,
 		   receipt_date,
 		   receipt_number,
 		   request_id,
 		   site_use_id,
 		   special_type,
 		   status,
 		   type,
 		   ussgl_transaction_code,
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
 		   ussgl_transaction_code_context,
 		   customer_bank_account_id,
		   customer_bank_branch_id,
 		   doc_sequence_id,
 		   doc_sequence_value,
                   application_notes,
                   application_ref_type,
                   customer_reference,
                   customer_reason,
                   org_id,
		   automatch_set_id,
		   autoapply_flag
 		 )
       VALUES (
                   l_icr_id,
                   p_icr_rec.amount,
                   p_icr_rec.amount_applied,
                   p_icr_rec.trans_to_receipt_rate,
		   p_icr_rec.factor_discount_amount,
                   arp_global.created_by,
                   arp_global.creation_date,
                   p_icr_rec.currency_code,
                   arp_global.last_updated_by,
                   arp_global.last_update_date,
                   p_icr_rec.receipt_method_id,
                   p_icr_rec.remit_bank_acct_use_id,
                   p_icr_rec.batch_id,
                   p_icr_rec.comments,
                   p_icr_rec.customer_trx_id,
                   p_icr_rec.exchange_date,
                   p_icr_rec.exchange_rate,
                   p_icr_rec.exchange_rate_type,
                   p_icr_rec.gl_date,
                   p_icr_rec.gl_posted_date,
		   p_icr_rec.anticipated_clearing_date,
                   arp_global.last_update_login,
                   p_icr_rec.payment_schedule_id,
                   p_icr_rec.pay_from_customer,
                   arp_global.program_application_id,
                   arp_global.program_id,
                   arp_global.program_update_date,
                   p_icr_rec.receipt_date,
                   p_icr_rec.receipt_number,
                   p_icr_rec.request_id,
                   p_icr_rec.site_use_id,
                   p_icr_rec.special_type,
                   p_icr_rec.status,
                   p_icr_rec.type,
                   p_icr_rec.ussgl_transaction_code,
                   p_icr_rec.attribute_category,
                   p_icr_rec.attribute1,
                   p_icr_rec.attribute2,
                   p_icr_rec.attribute3,
                   p_icr_rec.attribute4,
                   p_icr_rec.attribute5,
                   p_icr_rec.attribute6,
                   p_icr_rec.attribute7,
                   p_icr_rec.attribute8,
                   p_icr_rec.attribute9,
                   p_icr_rec.attribute10,
                   p_icr_rec.attribute11,
                   p_icr_rec.attribute12,
                   p_icr_rec.attribute13,
                   p_icr_rec.attribute14,
                   p_icr_rec.attribute15,
                   p_icr_rec.ussgl_transaction_code_context,
                   p_icr_rec.customer_bank_account_id,
		   p_icr_rec.customer_bank_branch_id,
                   p_icr_rec.doc_sequence_id,
                   p_icr_rec.doc_sequence_value,
                   p_icr_rec.application_notes,
                   p_icr_rec.application_ref_type,
                   p_icr_rec.customer_reference,
                   p_icr_rec.customer_reason,
                   arp_standard.sysparm.org_id,
		   p_icr_rec.automatch_set_id,
		   p_icr_rec.autoapply_flag
                 );
    p_icr_id := l_icr_id;
      --
    arp_standard.debug( '<<<<<<<< arp_cr_icr_pkg.insert_p' );
    EXCEPTION
	WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_pkg.insert_p' );
	    RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    const_icr_update_stmt                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 10/28/98     K.Murphy  Cross Currency Lockbox.                            |
 |                        Added amount_applied and trans_to_receipt_rate     |
 |                        as updated columns.                                |
 | 05/01/02     D.Jancis  Enh 2074220: added application_notes               |
 |                                                                           |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason.                           |
 +===========================================================================*/
--
PROCEDURE construct_icr_update_stmt( update_text OUT NOCOPY varchar2) IS
--
BEGIN
   arp_standard.debug('arp_cr_icr_pkg.construct_icr_update_stmt()+');
--
   update_text :=
 'update ar_interim_cash_receipts
   SET    amount =
               decode(:amount,
                      :ar_number_dummy, amount,
                                        :amount),
          amount_applied =
               decode(:amount_applied,
                      :ar_number_dummy, amount_applied,
                                        :amount_applied),
          trans_to_receipt_rate =
               decode(:trans_to_receipt_rate,
                      :ar_number_dummy, trans_to_receipt_rate,
                                        :trans_to_receipt_rate),
          factor_discount_amount =
               decode(:factor_discount_amount,
                      :ar_number_dummy, factor_discount_amount,
                                        :factor_discount_amount),
          anticipated_clearing_date =
               decode(:anticipated_clearing_date,
                      :ar_date_dummy, anticipated_clearing_date,
                                        :anticipated_clearing_date),
          customer_bank_branch_id =
               decode(:customer_bank_branch_id,
                      :ar_number_dummy, customer_bank_branch_id,
                                        :customer_bank_branch_id),
           currency_code =
               decode(:currency_code,
                      :ar_text_dummy,  currency_code,
                                        :currency_code),
          last_updated_by    = :pg_last_updated_by,
          last_update_date   = :pg_last_update_date,
          receipt_method_id =
               decode(:receipt_method_id,
                      :ar_number_dummy, receipt_method_id,
                                        :receipt_method_id),
          remit_bank_acct_use_id =
               decode(:remit_bank_acct_use_id,
                      :ar_number_dummy, remit_bank_acct_use_id,
                                        :remit_bank_acct_use_id),
          batch_id =
               decode(:batch_id,
                      :ar_number_dummy, batch_id,
                                        :batch_id),
          comments =
               decode(:comments,
                      :ar_text_dummy, comments,
                                        :comments),
           customer_trx_id =
               decode(:customer_trx_id,
                      :ar_number_dummy,  customer_trx_id,
                                        :customer_trx_id),
          exchange_date =
               decode(:exchange_date,
                      :ar_date_dummy, exchange_date,
                                        :exchange_date),
          exchange_rate =
               decode(:exchange_rate,
                      :ar_number_dummy, exchange_rate,
                                        :exchange_rate),
          exchange_rate_type =
               decode(:exchange_rate_type,
                      :ar_text_dummy, exchange_rate_type,
                                        :exchange_rate_type),
          gl_date =
               decode(:gl_date,
                      :ar_date_dummy, gl_date,
                                        :gl_date),
          gl_posted_date =
               decode(:gl_posted_date,
                      :ar_date_dummy, gl_posted_date,
                                        :gl_posted_date),
          last_update_login  = :pg_last_update_login,

          payment_schedule_id =
               decode(:payment_schedule_id,
                      :ar_number_dummy, payment_schedule_id,
                                        :payment_schedule_id),
          pay_from_customer =
               decode(:pay_from_customer,
                      :ar_number_dummy,  pay_from_customer,
                                        :pay_from_customer),
          program_application_id =
                     NVL( :pg_program_application_id,
                           program_application_id),
          program_id =
                     NVL( :pg_program_id,
                           program_id),
          program_update_date =
                     NVL( :pg_program_update_date,
                           program_update_date),
          receipt_date =
               decode(:receipt_date,
                      :ar_date_dummy, receipt_date,
                                        :receipt_date),
          receipt_number =
               decode(:receipt_number,
                      :ar_text_dummy, receipt_number,
                                        :receipt_number),
          request_id =
                     NVL( :pg_request_id,
                           request_id),
          site_use_id =
               decode(:site_use_id,
                      :ar_number_dummy, site_use_id,
                                        :site_use_id),
          special_type =
               decode(:special_type,
                      :ar_text_dummy, special_type,
					:special_type ),
          status =
               decode(:status,
                      :ar_text_dummy, status,
                                        :status),
          type =
               decode(:type,
                      :ar_text_dummy, type,
                                        :type),
          ussgl_transaction_code =
               decode(:ussgl_transaction_code,
                      :ar_text_dummy, ussgl_transaction_code,
                                        :ussgl_transaction_code),
         attribute_category =
               decode(:attribute_category,
                      :ar_text_dummy, attribute_category,
                                        :attribute_category),
          attribute1 =
               decode(:attribute1,
                      :ar_text_dummy,   attribute1,
                                        :attribute1),
          attribute2 =
               decode(:attribute2,
                      :ar_text_dummy,   attribute2,
                                        :attribute2),
          attribute3 =
               decode(:attribute3,
                      :ar_text_dummy,   attribute3,
                                        :attribute3),
          attribute4 =
               decode(:attribute4,
                      :ar_text_dummy,   attribute4,
                                        :attribute4),
          attribute5 =
               decode(:attribute5,
                      :ar_text_dummy,   attribute5,
                                        :attribute5),
          attribute6 =
               decode(:attribute6,
                      :ar_text_dummy,   attribute6,
                                        :attribute6),
          attribute7 =
               decode(:attribute7,
                      :ar_text_dummy,   attribute7,
                                        :attribute7),
          attribute8 =
               decode(:attribute8,
                      :ar_text_dummy,   attribute8,
                                        :attribute8),
          attribute9 =
               decode(:attribute9,
                      :ar_text_dummy,   attribute9,
                                        :attribute9),
          attribute10 =
               decode(:attribute10,
                      :ar_text_dummy,   attribute10,
                                        :attribute10),
          attribute11 =
               decode(:attribute11,
                      :ar_text_dummy,   attribute11,
                                        :attribute11),
          attribute12 =
               decode(:attribute12,
                      :ar_text_dummy,   attribute12,
                                        :attribute12),
          attribute13 =
               decode(:attribute13,
                      :ar_text_dummy,   attribute13,
                                        :attribute13),
          attribute14 =
               decode(:attribute14,
                      :ar_text_dummy,   attribute14,
                                        :attribute14),
          attribute15 =
               decode(:attribute15,
                      :ar_text_dummy,   attribute15,
                                        :attribute15),
          ussgl_transaction_code_context =
               decode(:ussgl_transaction_code_context,
                      :ar_text_dummy, ussgl_transaction_code_context,
                                        :ussgl_transaction_code_context),
          customer_bank_account_id =
               decode(:customer_bank_account_id,
                      :ar_number_dummy, customer_bank_account_id,
                                        :customer_bank_account_id),
          doc_sequence_id =
               decode(:doc_sequence_id,
                      :ar_number_dummy, doc_sequence_id,
                                        :doc_sequence_id),
          doc_sequence_value =
               decode(:doc_sequence_value,
                      :ar_number_dummy, doc_sequence_value,
                                        :doc_sequence_value),
          application_notes =
               decode(:application_notes,
                      :ar_text_dummy, application_notes,
                                       :application_notes) ,

           application_ref_type =
               decode(:application_ref_type,
                      :ar_text_dummy, application_ref_type,
                                       :application_ref_type),
           customer_reference =
               decode(:customer_reference,
                      :ar_text_dummy, customer_reference,
                                       :customer_reference),
           customer_reason =
               decode(:customer_reason,
                      :ar_text_dummy, customer_reason,
                                       :customer_reason),
           automatch_set_id =
               decode(:automatch_set_id,
                      :ar_number_dummy, automatch_set_id,
                                       :automatch_set_id),
           autoapply_flag =
               decode(:autoapply_flag,
                      :ar_flag_dummy, autoapply_flag,
                                       :autoapply_flag)
                                       ';
   --
   arp_standard.debug('arp_cr_icr_pkg.construct_icr_update_stmt()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION: arp_cr_icr_pkg .construct_icr_update_stmt()');
        RAISE;
--
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    bind_icr_variables                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 10/28/98     K.Murphy  Cross Currency Lockbox.                            |
 |                        Added amount_applied and trans_to_receipt_rate     |
 |                        as updated columns.                                |
 | 05/01/02     D.Jancis  ENH 2074220: added application_notes               |
 |                                                                           |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason.                           |
 +===========================================================================*/
--
PROCEDURE bind_icr_variables(p_update_cursor  IN integer,
                              p_icr_rec   IN ar_interim_cash_receipts%rowtype)
IS
--
BEGIN
--
   arp_standard.debug('arp_cr_icr_pkg.bind_icr_variables()+');
--
--
  /*------------------+
   |  Dummy constants |
   +------------------*/
--
   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);
--
   dbms_sql.bind_variable(p_update_cursor, ':ar_flag_dummy',
                          AR_FLAG_DUMMY);
--
   dbms_sql.bind_variable(p_update_cursor, ':ar_number_dummy',
                          AR_NUMBER_DUMMY);
--
   dbms_sql.bind_variable(p_update_cursor, ':ar_date_dummy',
                          AR_DATE_DUMMY);
arp_standard.debug('after duummy');
--
  /*------------------+
   |  WHO variables   |
   +------------------*/
--
   dbms_sql.bind_variable(p_update_cursor, ':pg_request_id',
                          pg_request_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':pg_program_application_id',
                          pg_program_application_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':pg_program_id',
                          pg_program_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':pg_program_update_date',
                          pg_program_update_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':pg_last_updated_by',
                          pg_last_updated_by);
--
   dbms_sql.bind_variable(p_update_cursor, ':pg_last_update_date',
                          pg_last_update_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':pg_last_update_login',
                          pg_last_update_login);
arp_standard.debug('after who');
  /*----------------------------------------------+
   |  Bind variables for all columns in the table |
   +----------------------------------------------*/
--
--
   dbms_sql.bind_variable(p_update_cursor, ':amount',
                          p_icr_rec.amount);
--
   dbms_sql.bind_variable(p_update_cursor, ':amount_applied',
                          p_icr_rec.amount_applied);
--
   dbms_sql.bind_variable(p_update_cursor, ':trans_to_receipt_rate',
                          p_icr_rec.trans_to_receipt_rate);
--
   dbms_sql.bind_variable(p_update_cursor, ':factor_discount_amount',
                          p_icr_rec.factor_discount_amount);
--
   dbms_sql.bind_variable(p_update_cursor, ':anticipated_clearing_date',
                          p_icr_rec.anticipated_clearing_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_bank_branch_id',
                          p_icr_rec.customer_bank_branch_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':currency_code',
                          p_icr_rec.currency_code);
--
   dbms_sql.bind_variable(p_update_cursor, ':receipt_method_id',
                          p_icr_rec.receipt_method_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':remit_bank_acct_use_id',
                          p_icr_rec.remit_bank_acct_use_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':batch_id',
                          p_icr_rec.batch_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':comments',
                          p_icr_rec.comments);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_id',
                          p_icr_rec.customer_trx_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':exchange_date',
                          p_icr_rec.exchange_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate',
                          p_icr_rec.exchange_rate);
--
   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate_type',
                          p_icr_rec.exchange_rate_type);
--
   dbms_sql.bind_variable(p_update_cursor, ':gl_date',
                          p_icr_rec.gl_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':gl_posted_date',
                          p_icr_rec.gl_posted_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':payment_schedule_id',
                          p_icr_rec.payment_schedule_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':pay_from_customer',
                          p_icr_rec.pay_from_customer);
--
   dbms_sql.bind_variable(p_update_cursor, ':receipt_date',
                          p_icr_rec.receipt_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':receipt_number',
                          p_icr_rec.receipt_number);
--
   dbms_sql.bind_variable(p_update_cursor, ':site_use_id',
                          p_icr_rec.site_use_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':special_type',
                          p_icr_rec.special_type);
--
   dbms_sql.bind_variable(p_update_cursor, ':status',
                          p_icr_rec.status);
--
   dbms_sql.bind_variable(p_update_cursor, ':type',
                          p_icr_rec.type);
--
   dbms_sql.bind_variable(p_update_cursor, ':ussgl_transaction_code',
                          p_icr_rec.ussgl_transaction_code);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_icr_rec.attribute_category);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_icr_rec.attribute1);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_icr_rec.attribute2);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_icr_rec.attribute3);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_icr_rec.attribute4);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_icr_rec.attribute5);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_icr_rec.attribute6);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_icr_rec.attribute7);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_icr_rec.attribute8);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_icr_rec.attribute9);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_icr_rec.attribute10);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_icr_rec.attribute11);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_icr_rec.attribute12);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_icr_rec.attribute13);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_icr_rec.attribute14);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_icr_rec.attribute15);
--
   dbms_sql.bind_variable(p_update_cursor, ':ussgl_transaction_code_context',
                          p_icr_rec.ussgl_transaction_code_context);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_bank_account_id',
                          p_icr_rec.customer_bank_account_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':doc_sequence_id',
                          p_icr_rec.doc_sequence_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':doc_sequence_value',
                          p_icr_rec.doc_sequence_value);
--
-- enh 2074220
   dbms_sql.bind_variable(p_update_cursor, ':application_notes',
                          p_icr_rec.application_notes);
--
-- Deductions Enhancement
   dbms_sql.bind_variable(p_update_cursor, ':application_ref_type',
                          p_icr_rec.application_ref_type);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_reference',
                          p_icr_rec.customer_reference);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_reason',
                          p_icr_rec.customer_reason);
--

--
   dbms_sql.bind_variable(p_update_cursor, ':automatch_set_id',
                          p_icr_rec.automatch_set_id);
--

--
   dbms_sql.bind_variable(p_update_cursor, ':autoapply_flag',
                          p_icr_rec.autoapply_flag);
--

   arp_standard.debug('arp_cr_icr_pkg.bind_icr_variables()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_icr_pkg.bind_icr_variables()');
        arp_standard.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));

        RAISE;
--
END;
--
--
--
PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
                         p_where_clause      IN varchar2,
                         p_where1            IN number,
                         p_icr_rec IN ar_interim_cash_receipts%ROWTYPE)
IS
--
   l_count             number;
   l_update_statement  varchar2(20000);
--
BEGIN
   arp_standard.debug('arp_cr_icr_pkg.generic_update()+');
--
  /*--------------------------------------------------------------+
   |  If this update statement has not already been parsed,       |
   |  construct the statement and parse it.                       |
   |  Otherwise, use the already parsed statement and rebind its  |
   |  variables.                                                  |
   +--------------------------------------------------------------*/
--
   if (p_update_cursor is null)
   then
--
         p_update_cursor := dbms_sql.open_cursor;
--
         /*---------------------------------+
          |  Construct the update statement |
          +---------------------------------*/
--
         arp_cr_icr_pkg.construct_icr_update_stmt(l_update_statement);
--
         l_update_statement := l_update_statement || p_where_clause;
--
   arp_standard.debug('after l_update_statement');
         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/
--
         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);
--
    arp_standard.debug('after dbms_sql');

   end if;
--
   arp_cr_icr_pkg.bind_icr_variables(p_update_cursor, p_icr_rec);
--
--
   arp_standard.debug('after .bind_app');
  /*-----------------------------------------+
   |  Bind the variables in the where clause |
   +-----------------------------------------*/
--
   if ( p_where1 is not null )
   then
        dbms_sql.bind_variable(p_update_cursor, ':where_1',
                          p_where1);
   end if;
   arp_standard.debug('after bind_variable ');
--
   l_count := dbms_sql.execute(p_update_cursor);
--
   arp_standard.debug( to_char(l_count) || ' rows updated');
--
--
   /*------------------------------------------------------------+
    |  Raise the NO_DATA_FOUND exception if no rows were updated |
    +------------------------------------------------------------*/
--
   if (l_count = 0)
   then raise NO_DATA_FOUND;
   arp_standard.debug('after l_count = 0');
   end if;
--
--
   arp_standard.debug('arp_cr_icr_pkg.generic_update()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_icr_pkg.generic_update()
');
        arp_standard.debug(l_update_statement);
        arp_standard.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));
        --arp_standard.debug('ERROR MESSAGE: ' ||
         --                  sqlerrm);
        RAISE;
END;
--
--
--
PROCEDURE set_to_dummy( p_icr_rec OUT NOCOPY ar_interim_cash_receipts%rowtype)
IS
--
BEGIN
--
    arp_standard.debug('arp_cr_icr_pkg.set_to_dummy()+');
--
    p_icr_rec.cash_receipt_id                  := AR_NUMBER_DUMMY;
    p_icr_rec.amount                           := AR_NUMBER_DUMMY;
    p_icr_rec.factor_discount_amount	       := AR_NUMBER_DUMMY;
    p_icr_rec.customer_bank_branch_id          := AR_NUMBER_DUMMY;
    p_icr_rec.anticipated_clearing_date	       := AR_DATE_DUMMY;
    p_icr_rec.currency_code                    := AR_TEXT_DUMMY;
    p_icr_rec.receipt_method_id                := AR_NUMBER_DUMMY;
    p_icr_rec.remit_bank_acct_use_id           := AR_NUMBER_DUMMY;
    p_icr_rec.batch_id                         := AR_NUMBER_DUMMY;
    p_icr_rec.comments                         := AR_TEXT_DUMMY;
    p_icr_rec.customer_trx_id                  := AR_NUMBER_DUMMY;
    p_icr_rec.exchange_date                    := AR_DATE_DUMMY;
    p_icr_rec.exchange_rate                    := AR_NUMBER_DUMMY;
    p_icr_rec.exchange_rate_type               := AR_TEXT_DUMMY;
    p_icr_rec.gl_date                          := AR_DATE_DUMMY;
    p_icr_rec.gl_posted_date                   := AR_DATE_DUMMY;
    p_icr_rec.payment_schedule_id              := AR_NUMBER_DUMMY;
    p_icr_rec.pay_from_customer                := AR_NUMBER_DUMMY;
    p_icr_rec.receipt_date                     := AR_DATE_DUMMY;
    p_icr_rec.receipt_number                   := AR_TEXT_DUMMY;
    p_icr_rec.site_use_id                      := AR_NUMBER_DUMMY;
    p_icr_rec.special_type                     := AR_TEXT_DUMMY;
    p_icr_rec.status                           := AR_TEXT_DUMMY;
    p_icr_rec.type                             := AR_TEXT_DUMMY;
    p_icr_rec.ussgl_transaction_code           := AR_TEXT_DUMMY;
    p_icr_rec.attribute_category               := AR_TEXT_DUMMY;
    p_icr_rec.attribute1                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute2                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute3                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute4                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute5                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute6                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute7                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute8                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute9                       := AR_TEXT_DUMMY;
    p_icr_rec.attribute10                      := AR_TEXT_DUMMY;
    p_icr_rec.attribute11                      := AR_TEXT_DUMMY;
    p_icr_rec.attribute12                      := AR_TEXT_DUMMY;
    p_icr_rec.attribute13                      := AR_TEXT_DUMMY;
    p_icr_rec.attribute14                      := AR_TEXT_DUMMY;
    p_icr_rec.attribute15                      := AR_TEXT_DUMMY;
    p_icr_rec.ussgl_transaction_code_context   := AR_TEXT_DUMMY;
    p_icr_rec.customer_bank_account_id         := AR_NUMBER_DUMMY;
    p_icr_rec.doc_sequence_id                  := AR_NUMBER_DUMMY;
    p_icr_rec.doc_sequence_value               := AR_NUMBER_DUMMY;
    p_icr_rec.application_notes                := AR_TEXT_DUMMY;
    p_icr_rec.application_ref_type             := AR_TEXT_DUMMY;
    p_icr_rec.customer_reference               := AR_TEXT_DUMMY;
    p_icr_rec.customer_reason                  := AR_TEXT_DUMMY;
    p_icr_rec.autoapply_flag                   := AR_FLAG_DUMMY;
    p_icr_rec.automatch_set_id                 := AR_NUMBER_DUMMY;
--
    arp_standard.debug('arp_cr_icr_pkg.set_to_dummy()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_icr_pkg.set_to_dummy()');
        RAISE;
--
END;
--
--
--
--
--
PROCEDURE update_p( p_icr_rec IN ar_interim_cash_receipts%ROWTYPE,
                    p_cash_receipt_id IN
                           ar_interim_cash_receipts.cash_receipt_id%TYPE) IS
--
BEGIN
--
   arp_standard.debug('arp_cr_icr_pkg.update_p()+  ');
--
--
   arp_cr_icr_pkg.generic_update( pg_cursor1,
                              ' WHERE cash_receipt_id = :where_1',
                               p_cash_receipt_id,
                               p_icr_rec);
--
   arp_standard.debug('arp_cr_icr_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));
--
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_icr_pkg.update_p()');
        RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row into AR_INTERIM_CASH_RECEIPTS              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_icr_id - ICR Id   to delete a row from ICR table       |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p(
	p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_cr_icr_pkg.delete_p' );
    --
    DELETE FROM ar_interim_cash_receipts
    WHERE cash_receipt_id = p_icr_id;
    --
    arp_standard.debug( '<<<<<<<< arp_cr_icr_pkg.delete_p' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_pkg.delete_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function locks a row in AR_INTERIM_CASH_RECEIPTS                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_icr_id - Icr Id   of row to be locked in ICR           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_p( p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE ) IS
l_icr_id		ar_interim_cash_receipts.cash_receipt_id%TYPE;
BEGIN
    arp_standard.debug( '>>>>>>>> arp_cr_icr_pkg.lock_p' );
    --
    SELECT cash_receipt_id
    INTO   l_icr_id
    FROM  ar_interim_cash_receipts
    WHERE cash_receipt_id = p_icr_id
    FOR UPDATE OF STATUS;
    --
    arp_standard.debug( '<<<<<<<< arp_cr_icr_pkg.lock_p' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_pkg.lock_p' );
            RAISE;
END;
--
PROCEDURE nowaitlock_p( p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE ) IS
l_icr_id		ar_interim_cash_receipts.cash_receipt_id%TYPE;
BEGIN
    arp_standard.debug( '>>>>>>>> arp_cr_icr_pkg.nowaitlock_p' );
    --
    SELECT cash_receipt_id
    INTO   l_icr_id
    FROM  ar_interim_cash_receipts
    WHERE cash_receipt_id = p_icr_id
    FOR UPDATE OF STATUS NOWAIT;
    --
    arp_standard.debug( '<<<<<<<< arp_cr_icr_pkg.nowaitlock_p' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_pkg.nowaitlock_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function fetches a row from AR_INTERIM_CASH_RECEIPTS              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_icr_id - Icr Id   of row to be fetched from ICR        |
 |              OUT:                                                         |
 |                  p_adj_rec - ICR     Record structure                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_p( p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
                   p_icr_rec OUT NOCOPY ar_interim_cash_receipts%ROWTYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_cr_icr_pkg.fetch_p' );
    --
    SELECT *
    INTO   p_icr_rec
    FROM   ar_interim_cash_receipts
    WHERE  cash_receipt_id = p_icr_id;
    --
    arp_standard.debug( '<<<<<<<<< arp_cr_icr_pkg.fetch_p' );
    EXCEPTION
    --
         WHEN OTHERS THEN
	      arp_standard.debug( 'EXCEPTION: arp_cr_icr_pkg.fetch_p' );
              RAISE;
END;
--

PROCEDURE lock_fetch_p( p_icr_rec IN OUT NOCOPY ar_interim_cash_receipts%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_pkg.lock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_icr_rec
    FROM  ar_interim_cash_receipts
    WHERE cash_receipt_id = p_icr_rec.cash_receipt_id
    FOR UPDATE OF STATUS;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_pkg.lock_fetch_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_cr_icr_pkg.lock_fetch_p' );
	    END IF;
            RAISE;
END lock_fetch_p;
--
--
PROCEDURE nowaitlock_fetch_p( p_icr_rec IN OUT NOCOPY ar_interim_cash_receipts%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_pkg.nowaitlock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_icr_rec
    FROM  ar_interim_cash_receipts
    WHERE cash_receipt_id = p_icr_rec.cash_receipt_id
    FOR UPDATE OF STATUS NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_pkg.nowaitlock_fetch_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_cr_icr_pkg.nowaitlock_fetch_p' );
	    END IF;
            RAISE;
END nowaitlock_fetch_p;
--
--
--
--
--
--
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
  pg_set_of_books_id        :=  arp_global.set_of_books_id;
--
--
END  ARP_CR_ICR_PKG;
--

/
