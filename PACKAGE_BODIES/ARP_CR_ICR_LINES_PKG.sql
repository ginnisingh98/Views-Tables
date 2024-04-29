--------------------------------------------------------
--  DDL for Package Body ARP_CR_ICR_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CR_ICR_LINES_PKG" AS
/* $Header: ARRIICLB.pls 120.9 2006/05/24 12:55:42 shveeram ship $*/

--
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/
--
  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
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
 |    This function inserts a row into AR_ICR_LINES                          |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                    p_icr_lines_rec - ICR Record structure                 |
 |              OUT:                                                         |
 |                    p_icr_line_id - ICR Id   of inserted ICR row           |
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
                    p_cr_line_id  OUT NOCOPY
                        ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
                    p_icr_lines_rec  IN
                        ar_interim_cash_receipt_lines%ROWTYPE ) IS
l_cr_line_id    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE;
l_row_id    VARCHAR2( 20 );
BEGIN
    arp_standard.debug( 'arp_cr_icr_lines_pkg.insert_p()+' );
    --
    arp_cr_icr_lines_pkg.insert_p( p_icr_lines_rec,
	                           p_icr_lines_rec.cash_receipt_id,
                                   l_cr_line_id );
    --
    SELECT ROWID
    INTO   l_row_id
    FROM   ar_interim_cash_receipt_lines
    WHERE  cash_receipt_line_id = l_cr_line_id
    AND    cash_receipt_id = p_icr_lines_rec.cash_receipt_id;
    --
    p_cr_line_id := l_cr_line_id;
    p_row_id := l_row_id;
    --
    arp_standard.debug( 'arp_cr_icr_lines_pkg.insert_p()-' );
    --
    EXCEPTION
	WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.insert_p' );
	    RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row into AR_ICR_LINES                          |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                    p_icr_lines_rec - ICR Record structure                 |
 |              OUT:                                                         |
 |                    p_.at_id - ICR Id   of inserted ICR row                |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This is an overloaded procedure                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 | 08/12/97     KTANG     Add global attribute columns for global            |
 |                        descriptive flexfield                              |
 | 10/06/98     K.Murphy  Cross Currency Lockbox.                            |
 |                        Added amount_applied_from and trans_to_receipt_rate|
 |                        as created columns.                                |
 |                                                                           |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason.                           |
 | 01-20-03   K.Dhaliwal          Bug 2707190 Added applied_rec_app_id to    |
 |                                set_to_dummy                               |
 +===========================================================================*/
PROCEDURE insert_p(
         p_icr_lines_rec  IN ar_interim_cash_receipt_lines%ROWTYPE,
         p_cr_id   IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
         p_icr_line_id OUT NOCOPY
                  ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE ) IS
l_cr_line_id    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE;
l_org_id        ar_interim_cash_receipt_lines.org_id%TYPE;
BEGIN
      arp_standard.debug( ' arp_cr_icr_lines_pkg.insert_p()+' );
      /* Adding the following line to populate the org_id as per the bug:5244971*/
      l_org_id := arp_standard.sysparm.org_id;
      --
      /* Changing the following query to remove the org id as per the bug:5244971*/
      SELECT NVL(MAX(cash_receipt_line_id),0) + 1
      INTO   l_cr_line_id
      FROM ar_interim_cash_receipt_lines
      WHERE cash_receipt_id = p_cr_id;
      --
      INSERT INTO  ar_interim_cash_receipt_lines (
		   cash_receipt_line_id,
		   cash_receipt_id,
 		   last_updated_by,
 		   last_update_date,
 		   last_update_login,
 		   created_by,
 		   creation_date,
 		   payment_amount,
                   amount_applied_from,
                   trans_to_receipt_rate,
 		   payment_schedule_id,
 		   customer_trx_id,
 		   customer_trx_line_id,
 		   batch_id,
 		   sold_to_customer,
 		   discount_taken,
 		   due_date,
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
                   request_id,
                   program_application_id,
                   program_update_date,
 		   ussgl_transaction_code,
 		   ussgl_transaction_code_context,
 		   application_ref_type,
 		   customer_reference,
 		   customer_reason,
 		   applied_rec_app_id,
                   org_id
 		 )
       VALUES (
		   l_cr_line_id,
		   p_icr_lines_rec.cash_receipt_id,
 		   arp_global.last_updated_by,
 		   arp_global.last_update_date,
 		   arp_global.last_update_login,
 		   arp_global.created_by,
 		   arp_global.creation_date,
 		   p_icr_lines_rec.payment_amount,
                   p_icr_lines_rec.amount_applied_from,
                   p_icr_lines_rec.trans_to_receipt_rate,
 		   p_icr_lines_rec.payment_schedule_id,
 		   p_icr_lines_rec.customer_trx_id,
 		   p_icr_lines_rec.customer_trx_line_id,
 		   p_icr_lines_rec.batch_id,
 		   p_icr_lines_rec.sold_to_customer,
 		   p_icr_lines_rec.discount_taken,
 		   p_icr_lines_rec.due_date,
                   p_icr_lines_rec.attribute_category,
                   p_icr_lines_rec.attribute1,
                   p_icr_lines_rec.attribute2,
                   p_icr_lines_rec.attribute3,
                   p_icr_lines_rec.attribute4,
                   p_icr_lines_rec.attribute5,
                   p_icr_lines_rec.attribute6,
                   p_icr_lines_rec.attribute7,
                   p_icr_lines_rec.attribute8,
                   p_icr_lines_rec.attribute9,
                   p_icr_lines_rec.attribute10,
                   p_icr_lines_rec.attribute11,
                   p_icr_lines_rec.attribute12,
                   p_icr_lines_rec.attribute13,
                   p_icr_lines_rec.attribute14,
                   p_icr_lines_rec.attribute15,
                   p_icr_lines_rec.global_attribute_category,
                   p_icr_lines_rec.global_attribute1,
                   p_icr_lines_rec.global_attribute2,
                   p_icr_lines_rec.global_attribute3,
                   p_icr_lines_rec.global_attribute4,
                   p_icr_lines_rec.global_attribute5,
                   p_icr_lines_rec.global_attribute6,
                   p_icr_lines_rec.global_attribute7,
                   p_icr_lines_rec.global_attribute8,
                   p_icr_lines_rec.global_attribute9,
                   p_icr_lines_rec.global_attribute10,
                   p_icr_lines_rec.global_attribute11,
                   p_icr_lines_rec.global_attribute12,
                   p_icr_lines_rec.global_attribute13,
                   p_icr_lines_rec.global_attribute14,
                   p_icr_lines_rec.global_attribute15,
                   p_icr_lines_rec.global_attribute16,
                   p_icr_lines_rec.global_attribute17,
                   p_icr_lines_rec.global_attribute18,
                   p_icr_lines_rec.global_attribute19,
                   p_icr_lines_rec.global_attribute20,
                   arp_global.request_id,
                   arp_global.program_application_id,
                   arp_global.program_update_date,
 		   p_icr_lines_rec.ussgl_transaction_code,
 		   p_icr_lines_rec.ussgl_transaction_code_context,
 		   p_icr_lines_rec.application_ref_type,
 		   p_icr_lines_rec.customer_reference,
 		   p_icr_lines_rec.customer_reason,
 		   p_icr_lines_rec.applied_rec_app_id,
                   l_org_id
 		 );
    p_icr_line_id := l_cr_line_id;
      --
    arp_standard.debug( 'arp_cr_icr_lines_pkg.insert_p()-' );
    EXCEPTION
	WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.insert_p' );
	    RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    const_icr_lines_update_stmt                                            |
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
 | 10/06/98     K.Murphy  Cross Currency Lockbox.                            |
 |                        Added amount_applied_from and trans_to_receipt_rate|
 |                        as updated columns.                                |
 |                                                                           |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason.                           |
 | 01-20-03   K.Dhaliwal          Bug 2707190 Added applied_rec_app_id to    |
 |                                set_to_dummy                               |
 +===========================================================================*/

PROCEDURE const_icr_lines_update_stmt( update_text OUT NOCOPY varchar2) IS
--
BEGIN
   arp_standard.debug('arp_cr_icr_lines_pkg.const_icr_lines_update_stmt()+');
--
   update_text :=
 'update ar_interim_cash_receipt_lines
   SET    payment_amount =
               decode(:payment_amount,
                      :ar_number_dummy, payment_amount,
                                        :payment_amount),
          amount_applied_from =
               decode(:amount_applied_from,
                      :ar_number_dummy, amount_applied_from,
                                        :amount_applied_from),
          trans_to_receipt_rate =
               decode(:trans_to_receipt_rate,
                      :ar_number_dummy, trans_to_receipt_rate,
                                        :trans_to_receipt_rate),
          last_updated_by    = :pg_last_updated_by,
          last_update_date   = :pg_last_update_date,
          last_update_login   = :pg_last_update_login,
          payment_schedule_id =
               decode(:payment_schedule_id,
                      :ar_number_dummy, payment_schedule_id,
                                        :payment_schedule_id),
          customer_trx_id =
               decode(:customer_trx_id,
                      :ar_number_dummy, customer_trx_id,
                                        :customer_trx_id),
          customer_trx_line_id =
               decode(:customer_trx_line_id,
                      :ar_number_dummy, customer_trx_line_id,
                                        :customer_trx_line_id),
          batch_id =
               decode(:batch_id,
                      :ar_number_dummy, batch_id,
                                        :batch_id),
          sold_to_customer =
               decode(:sold_to_customer,
                      :ar_number_dummy, sold_to_customer,
                                        :sold_to_customer),
          discount_taken =
               decode(:discount_taken,
                      :ar_number_dummy,  discount_taken,
                                        :discount_taken),
          due_date =
               decode(:due_date,
                      :ar_date_dummy, due_date,
                                        :due_date),
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
          global_attribute_category =
               decode(:global_attribute_category,
                      :ar_text_dummy,   global_attribute_category,
                                        :global_attribute_category),
          global_attribute1 =
               decode(:global_attribute1,
                      :ar_text_dummy,   global_attribute1,
                                        :global_attribute1),

          global_attribute2 =
               decode(:global_attribute2,
                      :ar_text_dummy,   global_attribute2,
                                        :global_attribute2),
          global_attribute3 =
               decode(:global_attribute3,
                      :ar_text_dummy,   global_attribute3,
                                        :global_attribute3),

          global_attribute4 =
               decode(:global_attribute4,
                      :ar_text_dummy,   global_attribute4,
                                        :global_attribute4),
          global_attribute5 =
               decode(:global_attribute5,
                      :ar_text_dummy,   global_attribute5,
                                        :global_attribute5),

          global_attribute6 =
               decode(:global_attribute6,
                      :ar_text_dummy,   global_attribute6,
                                        :global_attribute6),
          global_attribute7 =
               decode(:global_attribute7,
                      :ar_text_dummy,   global_attribute7,
                                        :global_attribute7),

          global_attribute8 =
               decode(:global_attribute8,
                      :ar_text_dummy,   global_attribute8,
                                        :global_attribute8),
          global_attribute9 =
               decode(:global_attribute9,
                      :ar_text_dummy,   global_attribute9,
                                        :global_attribute9),

          global_attribute10 =
               decode(:global_attribute10,
                      :ar_text_dummy,   global_attribute10,
                                        :global_attribute10),
          global_attribute11 =
               decode(:global_attribute11,
                      :ar_text_dummy,   global_attribute11,
                                        :global_attribute11),

          global_attribute12 =
               decode(:global_attribute12,
                      :ar_text_dummy,   global_attribute12,
                                        :global_attribute12),
          global_attribute13 =
               decode(:global_attribute13,
                      :ar_text_dummy,   global_attribute13,
                                        :global_attribute13),

          global_attribute14 =
               decode(:global_attribute14,
                      :ar_text_dummy,   global_attribute14,
                                        :global_attribute14),
          global_attribute15 =
               decode(:global_attribute15,
                      :ar_text_dummy,   global_attribute15,
                                        :global_attribute15),

          global_attribute16 =
               decode(:global_attribute16,
                      :ar_text_dummy,   global_attribute16,
                                        :global_attribute16),
          global_attribute17 =
               decode(:global_attribute17,
                      :ar_text_dummy,   global_attribute17,
                                        :global_attribute17),

          global_attribute18 =
               decode(:global_attribute18,
                      :ar_text_dummy,   global_attribute18,
                                        :global_attribute18),
          global_attribute19 =
               decode(:global_attribute19,
                      :ar_text_dummy,   global_attribute19,
                                        :global_attribute19),

          global_attribute20 =
               decode(:global_attribute20,
                      :ar_text_dummy,   global_attribute20,
                                        :global_attribute20),

          request_id =
                     NVL( :pg_request_id,
                           request_id),
          program_application_id =
                     NVL( :pg_program_application_id,
                           program_application_id),
          program_id =
                     NVL( :pg_program_id,
                           program_id),
          program_update_date =
                     NVL( :pg_program_update_date,
                           program_update_date),
          ussgl_transaction_code_context =
               decode(:ussgl_transaction_code_context,
                      :ar_text_dummy, ussgl_transaction_code_context,
                                        :ussgl_transaction_code_context),
          ussgl_transaction_code=
               decode(:ussgl_transaction_code,
                      :ar_text_dummy, ussgl_transaction_code,
                                        :ussgl_transaction_code),
           application_ref_type=
               decode(:application_ref_type,
                      :ar_text_dummy, application_ref_type,
                                        :application_ref_type),
           customer_reference=
               decode(:customer_reference,
                      :ar_text_dummy, customer_reference,
                                        :customer_reference),
           customer_reason=
               decode(:customer_reason,
                      :ar_text_dummy, customer_reason,
                                        :customer_reason),
            applied_rec_app_id=
               decode(:applied_rec_app_id,
                      :ar_number_dummy, applied_rec_app_id,
                                        :applied_rec_app_id)';
   --
   arp_standard.debug('arp_cr_icr_lines_pkg.const_icr_lines_update_stmt()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION: arp_cr_icr_lines_pkg .const_icr_lines_update_stmt()');
        RAISE;
--
END;
--
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    bind_icr_lines_variables                                               |
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
 | 10/06/98     K.Murphy  Cross Currency Lockbox.                            |
 |                        Added amount_applied_from and trans_to_receipt_rate|
 |                        as updated columns.                                |
 |                                                                           |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason.                           |
 | 01-20-03   K.Dhaliwal          Bug 2707190 Added applied_rec_app_id to    |
 |                                set_to_dummy                               |
 +===========================================================================*/
--
--
PROCEDURE bind_icr_lines_variables(
                p_update_cursor  IN integer,
                p_icr_lines_rec   IN ar_interim_cash_receipt_lines%rowtype ) IS
--
BEGIN
--
   arp_standard.debug('arp_cr_icr_lines_pkg.bind_icr_lines_variables()+');
--
--
  /*------------------+
   |  Dummy constants |
   +------------------*/
--
   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);
--
--   dbms_sql.bind_variable(p_update_cursor, ':ar_flag_dummy',
--                          AR_FLAG_DUMMY);
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
   dbms_sql.bind_variable(p_update_cursor, ':payment_amount',
                          p_icr_lines_rec.payment_amount);
--
   dbms_sql.bind_variable(p_update_cursor, ':amount_applied_from',
                          p_icr_lines_rec.amount_applied_from);
--
   dbms_sql.bind_variable(p_update_cursor, ':trans_to_receipt_rate',
                          p_icr_lines_rec.trans_to_receipt_rate);
--
   dbms_sql.bind_variable(p_update_cursor, ':payment_schedule_id',
                          p_icr_lines_rec.payment_schedule_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_id',
                          p_icr_lines_rec.customer_trx_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_line_id',
                          p_icr_lines_rec.customer_trx_line_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':batch_id',
                          p_icr_lines_rec.batch_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':sold_to_customer',
                          p_icr_lines_rec.sold_to_customer);
--
   dbms_sql.bind_variable(p_update_cursor, ':discount_taken',
                          p_icr_lines_rec.discount_taken);
--
   dbms_sql.bind_variable(p_update_cursor, ':due_date',
                          p_icr_lines_rec.due_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_icr_lines_rec.attribute_category);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_icr_lines_rec.attribute1);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_icr_lines_rec.attribute2);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_icr_lines_rec.attribute3);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_icr_lines_rec.attribute4);
--
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_icr_lines_rec.attribute5);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_icr_lines_rec.attribute6);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_icr_lines_rec.attribute7);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_icr_lines_rec.attribute8);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_icr_lines_rec.attribute9);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_icr_lines_rec.attribute10);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_icr_lines_rec.attribute11);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_icr_lines_rec.attribute12);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_icr_lines_rec.attribute13);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_icr_lines_rec.attribute14);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_icr_lines_rec.attribute15);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute_category',
                          p_icr_lines_rec.global_attribute_category);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute1',
                          p_icr_lines_rec.global_attribute1);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute2',
                          p_icr_lines_rec.global_attribute2);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute3',
                          p_icr_lines_rec.global_attribute3);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute4',
                          p_icr_lines_rec.global_attribute4);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute5',
                          p_icr_lines_rec.global_attribute5);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute6',
                          p_icr_lines_rec.global_attribute6);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute7',
                          p_icr_lines_rec.global_attribute7);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute8',
                          p_icr_lines_rec.global_attribute8);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute9',
                          p_icr_lines_rec.global_attribute9);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute10',
                          p_icr_lines_rec.global_attribute10);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute11',
                          p_icr_lines_rec.global_attribute11);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute12',
                          p_icr_lines_rec.global_attribute12);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute13',
                          p_icr_lines_rec.global_attribute13);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute14',
                          p_icr_lines_rec.global_attribute14);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute15',
                          p_icr_lines_rec.global_attribute15);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute16',
                          p_icr_lines_rec.global_attribute16);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute17',
                          p_icr_lines_rec.global_attribute17);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute18',
                          p_icr_lines_rec.global_attribute18);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute19',
                          p_icr_lines_rec.global_attribute19);
--
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute20',
                          p_icr_lines_rec.global_attribute20);
--
   dbms_sql.bind_variable(p_update_cursor, ':ussgl_transaction_code',
                          p_icr_lines_rec.ussgl_transaction_code);
--
   dbms_sql.bind_variable(p_update_cursor, ':ussgl_transaction_code_context',
                          p_icr_lines_rec.ussgl_transaction_code_context);
--
   dbms_sql.bind_variable(p_update_cursor, ':application_ref_type',
                          p_icr_lines_rec.application_ref_type);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_reference',
                          p_icr_lines_rec.customer_reference);
--
   dbms_sql.bind_variable(p_update_cursor, ':customer_reason',
                          p_icr_lines_rec.customer_reason);
--
   dbms_sql.bind_variable(p_update_cursor, ':applied_rec_app_id',
                          p_icr_lines_rec.applied_rec_app_id);
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_icr_lines_pkg.bind_icr_lines_variables()');
        arp_standard.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));

        RAISE;
--
END;
--
--
--
--  Bug 744228:  added additonal where clause and p_where2 parameter.
--      746872:  added additonal where3 clause
PROCEDURE generic_update(
                  p_update_cursor IN OUT NOCOPY integer,
                  p_where_clause      IN varchar2,
                  p_where1            IN number,
                  p_where2            IN number,
                  p_where3            IN number,
                  p_icr_lines_rec IN ar_interim_cash_receipt_lines%ROWTYPE)
IS
--
   l_count             number;
   l_update_statement  varchar2(20000);
--
BEGIN
   arp_standard.debug('arp_cr_icr_lines_pkg.generic_update()+');
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
         arp_cr_icr_lines_pkg.const_icr_lines_update_stmt(l_update_statement);
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
   arp_cr_icr_lines_pkg.bind_icr_lines_variables(p_update_cursor, p_icr_lines_rec);
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

-- Bug 744228:  bind additional where variable.
   if ( p_where2 is not null )
   then
        dbms_sql.bind_variable(p_update_cursor, ':where_2',
                          p_where2);
   end if;

-- Bug 746872:  bind additional where variable.
   if ( p_where3 is not null )
   then
        dbms_sql.bind_variable(p_update_cursor, ':where_3',
                          p_where3);
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
   arp_standard.debug('arp_cr_icr_lines_pkg.generic_update()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_icr_lines_pkg.generic_update()
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
PROCEDURE set_to_dummy( p_icr_lines_rec OUT NOCOPY
                        ar_interim_cash_receipt_lines%rowtype) IS
--
BEGIN
--
    arp_standard.debug('arp_cr_icr_lines_pkg.set_to_dummy()+');
--
    p_icr_lines_rec.cash_receipt_line_id    := AR_NUMBER_DUMMY;
    p_icr_lines_rec.cash_receipt_id    	    := AR_NUMBER_DUMMY;
    p_icr_lines_rec.payment_amount          := AR_NUMBER_DUMMY;
    p_icr_lines_rec.payment_schedule_id     := AR_NUMBER_DUMMY;
    p_icr_lines_rec.customer_trx_id         := AR_NUMBER_DUMMY;
    p_icr_lines_rec.customer_trx_line_id    := AR_NUMBER_DUMMY;
    p_icr_lines_rec.batch_id                := AR_NUMBER_DUMMY;
    p_icr_lines_rec.sold_to_customer        := AR_NUMBER_DUMMY;
    p_icr_lines_rec.discount_taken          := AR_NUMBER_DUMMY;
    p_icr_lines_rec.due_date                := AR_DATE_DUMMY;
    p_icr_lines_rec.attribute_category      := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute1              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute2              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute3              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute4              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute5              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute6              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute7              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute8              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute9              := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute10             := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute11             := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute12             := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute13             := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute14             := AR_TEXT_DUMMY;
    p_icr_lines_rec.attribute15             := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute_category      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute1       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute2       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute3       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute4       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute5       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute6       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute7       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute8       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute9       := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute10      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute11      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute12      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute13      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute14      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute15      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute16      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute17      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute18      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute19      := AR_TEXT_DUMMY;
    p_icr_lines_rec.global_attribute20      := AR_TEXT_DUMMY;
    p_icr_lines_rec.ussgl_transaction_code  := AR_TEXT_DUMMY;
    p_icr_lines_rec.ussgl_transaction_code_context   := AR_TEXT_DUMMY;
    p_icr_lines_rec.application_ref_type    := AR_TEXT_DUMMY;
    p_icr_lines_rec.customer_reference      := AR_TEXT_DUMMY;
    p_icr_lines_rec.customer_reason         := AR_TEXT_DUMMY;
    p_icr_lines_rec.applied_rec_app_id      := AR_NUMBER_DUMMY;

--
    arp_standard.debug('arp_cr_icr_lines_pkg.set_to_dummy()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_icr_lines_pkg.set_to_dummy()');
        RAISE;
--
END;
--
--
--
--
--
PROCEDURE update_p(
          p_icr_lines_rec IN ar_interim_cash_receipt_lines%ROWTYPE,
          p_cash_receipt_line_id IN
                   ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
          p_batch_id IN
                   ar_interim_cash_receipt_lines.batch_id%TYPE,
          p_cash_receipt_id  IN
                   ar_interim_cash_receipt_lines.cash_receipt_id%TYPE) IS
--
BEGIN
--
   arp_standard.debug('arp_cr_icr_lines_pkg.update_p()+  ');
--
--
-- Bug 744228:  added 2nd where clause and additional parameter of p_batch_id
--     746872:  added 3nd where clause and additional parameter of cash_receipt
--              id.
   arp_cr_icr_lines_pkg.generic_update( pg_cursor1,
                              ' WHERE cash_receipt_line_id = :where_1 and
                                batch_id = :where_2 and
                                cash_receipt_id = :where_3',
                               p_cash_receipt_line_id,
                               p_batch_id,
                               p_cash_receipt_id,
                               p_icr_lines_rec);
--
   arp_standard.debug('arp_cr_icr_lines_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));
--
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_icr_lines_pkg.update_p()');
        RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row into AR_ICR_LINES                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_icr_line_id - ICR Id   to delete a row from ICR table       |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p(
        p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
	p_icr_line_id IN
                   ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE ) IS
BEGIN
    arp_standard.debug( 'arp_cr_icr_lines_pkg.delete_p()+' );
    --
    DELETE FROM ar_interim_cash_receipt_lines
    WHERE cash_receipt_id = p_icr_id
    AND   cash_receipt_line_id = p_icr_line_id;
    --
    arp_standard.debug( 'arp_cr_icr_lines_pkg.delete_p()-' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.delete_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_fk                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row into AR_ICR_LINES using cach receipt id    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_icr_id - ICR id                                        |
 |									     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 04/23/1998 G.Wang   Bug #653643.  Was previously deleting from the cash   |
 |                     receipt table instead of the lines table.             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE delete_fk(
        p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_lines_pkg.delete_fk()+' );
    END IF;
    --
    DELETE FROM ar_interim_cash_receipt_lines
    WHERE cash_receipt_id = p_icr_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_lines_pkg.delete_fk()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.delete_fk' );
            END IF;
            RAISE;
END delete_fk;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function locks a row in AR_ICR_LINES                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_icr_line_id - Icr Id   of row to be locked in ICR      |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 25-Jun-1999  J.Gazmen-Dabir  Bug 911369, modified update as STATUS        |
 |                              column does not exist in table.              |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_p(
          p_icr_line_id IN
                   ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE ) IS
--
l_cr_line_id       ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE;
BEGIN
    arp_standard.debug( 'arp_cr_icr_lines_pkg.lock_p()+' );
    --
    SELECT cash_receipt_line_id
    INTO   l_cr_line_id
    FROM  ar_interim_cash_receipt_lines
    WHERE cash_receipt_line_id = p_icr_line_id
    FOR UPDATE OF PAYMENT_AMOUNT;
    --
    arp_standard.debug( 'arp_cr_icr_lines_pkg.lock_p()-' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.lock_p' );
            RAISE;
END;
--
PROCEDURE nowaitlock_p(
         p_icr_line_id IN
                 ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE ) IS
l_cr_line_id	 ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE;
BEGIN
    arp_standard.debug( 'arp_cr_icr_lines_pkg.nowaitlock_p()+' );
    --
    SELECT cash_receipt_line_id
    INTO   l_cr_line_id
    FROM  ar_interim_cash_receipt_lines
    WHERE cash_receipt_line_id = p_icr_line_id
    FOR UPDATE OF PAYMENT_AMOUNT NOWAIT;
    --
    arp_standard.debug( 'arp_cr_icr_lines_pkg.nowaitlock_p()-' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.nowaitlock_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function fetches a row from AR_ICR_LINES                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_icr_line_id - Icr Id   of row to be fetched from ICR   |
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
PROCEDURE fetch_p(
               p_icr_line_id IN
                   ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
               p_icr_lines_rec OUT NOCOPY
                   ar_interim_cash_receipt_lines%ROWTYPE ) IS
BEGIN
    arp_standard.debug( 'arp_cr_icr_lines_pkg.fetch_p()+' );
    --
    SELECT *
    INTO   p_icr_lines_rec
    FROM   ar_interim_cash_receipt_lines
    WHERE  cash_receipt_line_id = p_icr_line_id;
    --
    arp_standard.debug( 'arp_cr_icr_lines_pkg.fetch_p()-' );
    EXCEPTION
    --
         WHEN OTHERS THEN
	      arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.fetch_p' );
              RAISE;
END;
--
PROCEDURE lock_fetch_p( p_icr_lines_rec IN OUT NOCOPY
                                  ar_interim_cash_receipt_lines%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_lines_pkg.lock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_icr_lines_rec
    FROM  ar_interim_cash_receipt_lines
    WHERE cash_receipt_line_id = p_icr_lines_rec.cash_receipt_line_id
    FOR UPDATE OF PAYMENT_AMOUNT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_lines_pkg.lock_fetch_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.lock_fetch_p' );
	    END IF;
            RAISE;
END lock_fetch_p;
--
--
PROCEDURE nowaitlock_fetch_p( p_icr_lines_rec IN OUT NOCOPY
                                  ar_interim_cash_receipt_lines%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_lines_pkg.nowaitlock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_icr_lines_rec
    FROM  ar_interim_cash_receipt_lines
    WHERE cash_receipt_line_id = p_icr_lines_rec.cash_receipt_line_id
    FOR UPDATE OF PAYMENT_AMOUNT NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_icr_lines_pkg.nowaitlock_fetch_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_cr_icr_lines_pkg.nowaitlock_fetch_p' );
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
END  ARP_CR_ICR_LINES_PKG;
--

/
