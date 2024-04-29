--------------------------------------------------------
--  DDL for Package Body ARP_CR_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CR_BATCHES_PKG" AS
/* $Header: ARRIBATB.pls 120.8.12010000.2 2008/11/11 08:52:03 spdixit ship $*/

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
--
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row into AR_BATCHES table                      |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                    p_bat_rec - Batches Record structure                   |
 |              OUT:                                                         |
 |                    p_bat_id - Batch Id of inserted AR_BATCHES row         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - Overloaded procedure                                              |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE insert_p( p_bat_rec    IN ar_batches%ROWTYPE,
        p_row_id OUT NOCOPY VARCHAR2,
        p_bat_id OUT NOCOPY ar_batches.batch_id%TYPE ) IS
l_bat_id  ar_batches.batch_id%TYPE;
l_row_id  VARCHAR2( 20 );
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug( 'arp_cr_batches_pkg.insert_p()+' );
      END IF;
      --
      ARP_CR_BATCHES_PKG.insert_p( p_bat_rec, l_bat_id );
      --
      SELECT rowid
      INTO   l_row_id
      FROM   ar_batches
      WHERE  batch_id = l_bat_id;
      --
      p_bat_id := l_bat_id;
      p_row_id := l_row_id;
      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug( 'arp_cr_batches_pkg.insert_p()-' );
      END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_cr_batches_pkg.insert_p' );
            END IF;
            RAISE;
END insert_p;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row into AR_BATCHES table                      |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                    p_bat_rec - Batches Record structure                   |
 |              OUT:                                                         |
 |                    p_bat_id - Batch Id of inserted AR_BATCHES row         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - Overloaded procedure                                              |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              WITH_RECOURSE_FLAG, AUTO_PRINT_PROGRAM_ID and|
 |                              AUTO_TRANS_PROGRAM_ID into table handlers.   |
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added column 	             |
 |				purged_children_flag 			     |
 | 				into the table handlers.  		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_p( p_bat_rec 	IN ar_batches%ROWTYPE,
       p_bat_id OUT NOCOPY ar_batches.batch_id%TYPE ) IS
l_bat_id    ar_batches.batch_id%TYPE;

BEGIN
      arp_standard.debug( '>>>>>>>> arp_cr_batches_pkg.insert_p' );
      --
      SELECT ar_batches_s.nextval
      INTO   l_bat_id
      FROM   dual;
      --
      INSERT INTO  ar_batches (
		   batch_id,
 		   batch_applied_status,
 		   batch_date,
 		   batch_source_id,
 		   created_by,
 		   creation_date,
 		   currency_code,
 		   last_updated_by,
 		   last_update_date,
 		   name,
 		   set_of_books_id,
 		   type,
 		   closed_date,
 		   comments,
 		   control_amount,
 		   control_count,
 		   deposit_date,
 		   exchange_date,
 		   exchange_rate,
 		   exchange_rate_type,
 		   gl_date,
 		   last_update_login,
 		   lockbox_batch_name,
 		   lockbox_id,
 		   media_reference,
 		   operation_request_id,
 		   receipt_class_id,
 		   receipt_method_id,
 		   remit_method_code,
 		   remit_bank_acct_use_id,
 		   remittance_bank_branch_id,
 		   status,
 		   transmission_request_id,
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
 		   request_id ,
 		   program_application_id,
 		   program_id,
 		   program_update_date,
 		   transmission_id,
 		   bank_deposit_number,
                   with_recourse_flag,
                   auto_print_program_id,
                   auto_trans_program_id,
                   purged_children_flag
                  ,org_id
 		 )
       VALUES (    l_bat_id,
 		   p_bat_rec.batch_applied_status,
 		   p_bat_rec.batch_date,
 		   p_bat_rec.batch_source_id,
 		   arp_global.created_by,
 		   arp_global.creation_date,
 		   p_bat_rec.currency_code,
 		   arp_global.last_updated_by,
 		   arp_global.last_update_date,
 		   p_bat_rec.name,
 		   arp_global.set_of_books_id,
 		   p_bat_rec.type,
 		   p_bat_rec.closed_date,
 		   p_bat_rec.comments,
 		   p_bat_rec.control_amount,
 		   p_bat_rec.control_count,
 		   p_bat_rec.deposit_date,
 		   p_bat_rec.exchange_date,
 		   p_bat_rec.exchange_rate,
 		   p_bat_rec.exchange_rate_type,
 		   p_bat_rec.gl_date,
 		   arp_global.last_update_login,
 		   p_bat_rec.lockbox_batch_name,
 		   p_bat_rec.lockbox_id,
 		   p_bat_rec.media_reference,
 		   p_bat_rec.operation_request_id,
 		   p_bat_rec.receipt_class_id,
 		   p_bat_rec.receipt_method_id,
 		   p_bat_rec.remit_method_code,
 		   p_bat_rec.remit_bank_acct_use_id,
 		   p_bat_rec.remittance_bank_branch_id,
 		   p_bat_rec.status,
 		   p_bat_rec.transmission_request_id,
 		   p_bat_rec.attribute_category,
 		   p_bat_rec.attribute1,
 		   p_bat_rec.attribute2,
 		   p_bat_rec.attribute3,
 		   p_bat_rec.attribute4,
 		   p_bat_rec.attribute5,
 		   p_bat_rec.attribute6,
 		   p_bat_rec.attribute7,
 		   p_bat_rec.attribute8,
 		   p_bat_rec.attribute9,
 		   p_bat_rec.attribute10,
 		   p_bat_rec.attribute11,
 		   p_bat_rec.attribute12,
 		   p_bat_rec.attribute13,
 		   p_bat_rec.attribute14,
 		   p_bat_rec.attribute15,
 		   arp_global.request_id,
 		   arp_global.program_application_id,
 		   arp_global.program_id,
                   arp_global.program_update_date,
 		   p_bat_rec.transmission_id,
 		   p_bat_rec.bank_deposit_number,
                   p_bat_rec.with_recourse_flag,
                   p_bat_rec.auto_print_program_id,
                   p_bat_rec.auto_trans_program_id,
                   p_bat_rec.purged_children_flag
                  ,arp_standard.sysparm.org_id /* SSA changes anuj */
	       );
    p_bat_id := l_bat_id;

                /*---------------------------------+
                |  Calling central MRC library     |
                |  for MRC integration             |
                +----------------------------------*/
--{BUG4301323
--                ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode        => 'INSERT',
--                        p_table_name        => 'AR_BATCHES',
--                        p_mode              => 'SINGLE',
--                        p_key_value         => l_bat_id);
--}
      --
    arp_standard.debug( '<<<<<<<< arp_cr_batches_pkg.insert_p' );
    EXCEPTION
	WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_batches_pkg.insert_p' );
	    RAISE;
END;
--
--
PROCEDURE construct_bat_update_stmt( update_text OUT NOCOPY varchar2) IS
--
BEGIN
   arp_standard.debug('arp_cr_batches_pkg.construct_bat_update_stmt()+');
--
   update_text :=
 'update ar_batches
   SET    batch_applied_status =
               decode(:batch_applied_status,
                      :ar_text_dummy, batch_applied_status,
                                        :batch_applied_status),
          batch_date =
               decode(:batch_date,
                      :ar_date_dummy, batch_date,
                                        :batch_date),
          batch_source_id =
               decode(:batch_source_id,
                      :ar_number_dummy, batch_source_id,
                                        :batch_source_id),
           currency_code =
               decode(:currency_code,
                      :ar_text_dummy,  currency_code,
                                        :currency_code),
          last_updated_by    = :pg_last_updated_by,
          last_update_date   = :pg_last_update_date,
          name =
               decode(:name,
                      :ar_text_dummy, name,
                                        :name),
          set_of_books_id = :pg_set_of_books_id,
          type =
               decode(:type,
                      :ar_text_dummy, type,
                                        :type),
          closed_date =
               decode(:closed_date,
                      :ar_date_dummy, closed_date,
                                        :closed_date),
          comments =
               decode(:comments,
                      :ar_text_dummy, comments,
                                        :comments),
          control_amount =
               decode(:control_amount,
                      :ar_number_dummy, control_amount,
                                        :control_amount),
           control_count =
               decode(:control_count,
                      :ar_number_dummy,  control_count,
                                        :control_count),
          deposit_date =
               decode(:deposit_date,
                      :ar_date_dummy, deposit_date,
                                        :deposit_date),
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
          last_update_login  = :pg_last_update_login,

          lockbox_batch_name =
               decode(:lockbox_batch_name,
                      :ar_text_dummy, lockbox_batch_name,
                                        :lockbox_batch_name),
           lockbox_id =
               decode(:lockbox_id,
                      :ar_number_dummy,  lockbox_id,
                                        :lockbox_id),
          media_reference =
               decode(:media_reference,
                      :ar_text_dummy, media_reference,
                                        :media_reference),
          operation_request_id =
               decode(:operation_request_id,
                      :ar_number_dummy, operation_request_id,
                                        :operation_request_id),
          receipt_class_id =
               decode(:receipt_class_id,
                      :ar_number_dummy, receipt_class_id,
                                        :receipt_class_id),
          receipt_method_id =
               decode(:receipt_method_id,
                      :ar_number_dummy, receipt_method_id,
                                        :receipt_method_id),
          remit_method_code =
               decode(:remit_method_code,
                      :ar_text_dummy, remit_method_code,
                                        :remit_method_code),
          remit_bank_acct_use_id =
               decode(:remit_bank_acct_use_id,
                      :ar_number_dummy,  remit_bank_acct_use_id,
                                        :remit_bank_acct_use_id),
          remittance_bank_branch_id =
               decode(:remittance_bank_branch_id,
                      :ar_number_dummy, remittance_bank_branch_id,
                                        :remittance_bank_branch_id),
          status =
               decode(:status,
                      :ar_text_dummy, status,
                                        :status),
          transmission_request_id =
               decode(:transmission_request_id,
                      :ar_number_dummy, transmission_request_id,
                                        :transmission_request_id),
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
          transmission_id =
               decode(:transmission_id,
                      :ar_number_dummy, transmission_id,
                                        :transmission_id),
          bank_deposit_number =
               decode(:bank_deposit_number,
                      :ar_text_dummy, bank_deposit_number,
                                      :bank_deposit_number),
          with_recourse_flag  =
               decode(:with_recourse_flag,
                      :ar_flag_dummy, with_recourse_flag,
                                      :with_recourse_flag),
          auto_print_program_id  =
               decode(:auto_print_program_id,
                      :ar_number_dummy, auto_print_program_id,
                                        :auto_print_program_id),
          auto_trans_program_id  =
               decode(:auto_trans_program_id,
                      :ar_number_dummy, auto_trans_program_id,
                                        :auto_trans_program_id),
          purged_children_flag  =
               decode(:purged_children_flag,
                      :ar_flag_dummy, purged_children_flag,
                                        :purged_children_flag) ';


   arp_standard.debug('arp_cr_batches_pkg.construct_bat_update_stmt()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION: arp_cr_batches_pkg .construct_bat_update_stmt()');
        RAISE;
--
END;
--
--
--
PROCEDURE bind_bat_variables(p_update_cursor  IN integer,
                              p_bat_rec   IN ar_batches%rowtype)
IS
--
BEGIN
--
   arp_standard.debug('arp_cr_batches_pkg.bind_bat_variables()+');
--
--
  /*------------------+
   |  Dummy constants |
   +------------------*/
--
   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);
   /* 31-MAY-2000 J Rautiainen BR Implementation
    * The flag bind variable was commented out. Comments were removed since
    * BR changes require this flag */
   dbms_sql.bind_variable(p_update_cursor, ':ar_flag_dummy',
                          AR_FLAG_DUMMY);

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
   dbms_sql.bind_variable(p_update_cursor, ':pg_set_of_books_id',
                          arp_global.set_of_books_id);
arp_standard.debug('after who');
  /*----------------------------------------------+
   |  Bind variables for all columns in the table |
   +----------------------------------------------*/
--
--
   dbms_sql.bind_variable(p_update_cursor, ':batch_applied_status',
                          p_bat_rec.batch_applied_status);
--
   dbms_sql.bind_variable(p_update_cursor, ':batch_date',
                          p_bat_rec.batch_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':batch_source_id',
                          p_bat_rec.batch_source_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':currency_code',
                          p_bat_rec.currency_code);
--
   dbms_sql.bind_variable(p_update_cursor, ':name',
                          p_bat_rec.name);
--
   dbms_sql.bind_variable(p_update_cursor, ':type',
                          p_bat_rec.type);
--
   dbms_sql.bind_variable(p_update_cursor, ':closed_date',
                          p_bat_rec.closed_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':comments',
                          p_bat_rec.comments);
--
   dbms_sql.bind_variable(p_update_cursor, ':control_amount',
                          p_bat_rec.control_amount);
--
   dbms_sql.bind_variable(p_update_cursor, ':control_count',
                          p_bat_rec.control_count);
--
   dbms_sql.bind_variable(p_update_cursor, ':deposit_date',
                          p_bat_rec.deposit_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':exchange_date',
                          p_bat_rec.exchange_date);
--
   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate',
                          p_bat_rec.exchange_rate);
--
   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate_type',
                          p_bat_rec.exchange_rate_type);
--
   dbms_sql.bind_variable(p_update_cursor, ':gl_date',
                          p_bat_rec.gl_date);
--
--
   dbms_sql.bind_variable(p_update_cursor, ':lockbox_batch_name',
                          p_bat_rec.lockbox_batch_name);
--
   dbms_sql.bind_variable(p_update_cursor, ':lockbox_id',
                          p_bat_rec.lockbox_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':media_reference',
                          p_bat_rec.media_reference);
--
   dbms_sql.bind_variable(p_update_cursor, ':operation_request_id',
                          p_bat_rec.operation_request_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':receipt_class_id',
                          p_bat_rec.receipt_class_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':receipt_method_id',
                          p_bat_rec.receipt_method_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':remit_method_code',
                          p_bat_rec.remit_method_code);
--
   dbms_sql.bind_variable(p_update_cursor, ':remit_bank_acct_use_id',
                          p_bat_rec.remit_bank_acct_use_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':remittance_bank_branch_id',
                          p_bat_rec.remittance_bank_branch_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':status',
                          p_bat_rec.status);
   dbms_sql.bind_variable(p_update_cursor, ':transmission_request_id',
                          p_bat_rec.transmission_request_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_bat_rec.attribute_category);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_bat_rec.attribute1);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_bat_rec.attribute2);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_bat_rec.attribute3);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_bat_rec.attribute4);
--
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_bat_rec.attribute5);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_bat_rec.attribute6);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_bat_rec.attribute7);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_bat_rec.attribute8);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_bat_rec.attribute9);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_bat_rec.attribute10);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_bat_rec.attribute11);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_bat_rec.attribute12);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_bat_rec.attribute13);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_bat_rec.attribute14);
--
   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_bat_rec.attribute15);
--
   dbms_sql.bind_variable(p_update_cursor, ':transmission_id',
                          p_bat_rec.transmission_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':bank_deposit_number',
                          p_bat_rec.bank_deposit_number);
--
   dbms_sql.bind_variable(p_update_cursor, ':with_recourse_flag',
                          p_bat_rec.with_recourse_flag);
--
   dbms_sql.bind_variable(p_update_cursor, ':auto_print_program_id',
                          p_bat_rec.auto_print_program_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':auto_trans_program_id',
                          p_bat_rec.auto_trans_program_id);
--
   dbms_sql.bind_variable(p_update_cursor, ':purged_children_flag',
                          p_bat_rec.purged_children_flag);
--
   arp_standard.debug('arp_cr_batches_pkg.bind_bat_variables()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_batches_pkg.bind_bat_variables()');
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
                         p_bat_rec IN ar_batches%ROWTYPE)
IS
--
   l_count             number;
   l_update_statement  varchar2(20000);
   ar_batch_array   dbms_sql.number_table;

--
BEGIN
   arp_standard.debug('arp_cr_batches_pkg.generic_update()+');
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
         arp_cr_batches_pkg.construct_bat_update_stmt(l_update_statement);
--
         l_update_statement := l_update_statement || p_where_clause;

	 /*  add on mrc variables for bulk collect */
         l_update_statement := l_update_statement ||
             ' RETURNING batch_id INTO :ar_batch_key_value ';

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
   arp_cr_batches_pkg.bind_bat_variables(p_update_cursor, p_bat_rec);
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
           /*---------------------------+
            | Bind output variable      |
            +---------------------------*/
           dbms_sql.bind_array(p_update_cursor,':ar_batch_key_value',
                               ar_batch_array);

   l_count := dbms_sql.execute(p_update_cursor);
--
   arp_standard.debug( to_char(l_count) || ' rows updated');
--
   /*------------------------------------------+
    | get RETURNING COLUMN into OUT NOCOPY bind array |
    +------------------------------------------*/

    dbms_sql.variable_value( p_update_cursor, ':ar_batch_key_value',
                             ar_batch_array);

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
--{BUG#4301323
--   arp_standard.debug('before loop for MRC processing...');
--	FOR I in ar_batch_array.FIRST .. ar_batch_array.LAST LOOP
       /*---------------------------------------------+
        | call mrc engine to update AR_MC_BATCHES     |
        +---------------------------------------------*/
--       arp_standard.debug('before calling maintain_mrc ');
--       arp_standard.debug('batch array('||to_char(I) || ') = ' || to_char(ar_batch_array(I)));

--       ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode       => 'UPDATE',
--                        p_table_name       => 'AR_BATCHES',
--                        p_mode             => 'SINGLE',
--                        p_key_value        => ar_batch_array(I));
--        END LOOP;
--}
--
   arp_standard.debug('arp_cr_batches_pkg.generic_update()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_batches_pkg.generic_update()
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
PROCEDURE set_to_dummy( p_bat_rec OUT NOCOPY ar_batches%rowtype)
IS
--
BEGIN
--
    arp_standard.debug('arp_cr_batches_pkg.set_to_dummy()+');
--
    p_bat_rec.batch_applied_status             := AR_TEXT_DUMMY;
    p_bat_rec.batch_date                       := AR_DATE_DUMMY;
    p_bat_rec.batch_source_id                  := AR_NUMBER_DUMMY;
    p_bat_rec.currency_code                    := AR_TEXT_DUMMY;
    p_bat_rec.name                             := AR_TEXT_DUMMY;
    p_bat_rec.type                             := AR_TEXT_DUMMY;
    p_bat_rec.closed_date                      := AR_DATE_DUMMY;
    p_bat_rec.comments                         := AR_TEXT_DUMMY;
    p_bat_rec.control_amount                   := AR_NUMBER_DUMMY;
    p_bat_rec.control_count                    := AR_NUMBER_DUMMY;
    p_bat_rec.deposit_date                     := AR_DATE_DUMMY;
    p_bat_rec.exchange_date                    := AR_DATE_DUMMY;
    p_bat_rec.exchange_rate                    := AR_NUMBER_DUMMY;
    p_bat_rec.exchange_rate_type               := AR_TEXT_DUMMY;
    p_bat_rec.gl_date                          := AR_DATE_DUMMY;
    p_bat_rec.lockbox_batch_name               := AR_TEXT_DUMMY;
    p_bat_rec.lockbox_id                       := AR_NUMBER_DUMMY;
    p_bat_rec.media_reference                  := AR_TEXT_DUMMY;
    p_bat_rec.operation_request_id             := AR_NUMBER_DUMMY;
    p_bat_rec.receipt_class_id                 := AR_NUMBER_DUMMY;
    p_bat_rec.receipt_method_id                := AR_NUMBER_DUMMY;
    p_bat_rec.remit_method_code                := AR_TEXT_DUMMY;
    p_bat_rec.remit_bank_acct_use_id           := AR_NUMBER_DUMMY;
    p_bat_rec.remittance_bank_branch_id        := AR_NUMBER_DUMMY;
    p_bat_rec.status                           := AR_TEXT_DUMMY;
    p_bat_rec.transmission_request_id          := AR_NUMBER_DUMMY;
    p_bat_rec.attribute_category               := AR_TEXT_DUMMY;
    p_bat_rec.attribute1                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute2                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute3                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute4                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute5                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute6                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute7                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute8                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute9                       := AR_TEXT_DUMMY;
    p_bat_rec.attribute10                      := AR_TEXT_DUMMY;
    p_bat_rec.attribute11                      := AR_TEXT_DUMMY;
    p_bat_rec.attribute12                      := AR_TEXT_DUMMY;
    p_bat_rec.attribute13                      := AR_TEXT_DUMMY;
    p_bat_rec.attribute14                      := AR_TEXT_DUMMY;
    p_bat_rec.attribute15                      := AR_TEXT_DUMMY;
    p_bat_rec.transmission_id                  := AR_NUMBER_DUMMY;
    p_bat_rec.bank_deposit_number              := AR_TEXT_DUMMY;
    p_bat_rec.with_recourse_flag               := AR_FLAG_DUMMY;
    p_bat_rec.auto_print_program_id            := AR_NUMBER_DUMMY;
    p_bat_rec.auto_trans_program_id            := AR_NUMBER_DUMMY;
    p_bat_rec.purged_children_flag	       := AR_FLAG_DUMMY;
--

    arp_standard.debug('arp_cr_batches_pkg.set_to_dummy()-');
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_batches_pkg.set_to_dummy()');
        RAISE;
--
END;
--
--
--
--
--
PROCEDURE update_p( p_bat_rec IN ar_batches%ROWTYPE,
                    p_batch_id IN
                           ar_batches.batch_id%TYPE) IS
--
BEGIN
--
   arp_standard.debug('arp_cr_batches_pkg.update_p()+  ');
--
--
   arp_cr_batches_pkg.generic_update( pg_cursor1,
                              ' WHERE batch_id = :where_1',
                               p_batch_id,
                               p_bat_rec);
--
   arp_standard.debug('arp_cr_batches_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));
--
--
EXCEPTION
    WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  arp_cr_batches_pkg.update_p()');
        RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row into AR_BATCHES table                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_adj_rec - Batches Record structure                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES - Overloaded procedure                                              |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_p( p_bat_rec 	IN ar_batches%ROWTYPE ) IS
BEGIN
    arp_standard.debug( ' arp_cr_batches_pkg.update_p()+ ' );
    --
   update_p( p_bat_rec, p_bat_rec.batch_id );
   --
    arp_standard.debug( 'arp_cr_batches_pkg.update_p()- ' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_batches_pkg.update_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row into AR_BATCHES table                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_bat_id - Batch id to delete a row from AR_BATCHES      |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p(
	p_bat_id IN ar_batches.batch_id%TYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_cr_batches_pkg.delete_p' );
    --
    DELETE FROM ar_batches
    WHERE batch_id = p_bat_id;

 	/*---------------------------------+
    	| Calling central MRC library     |
    	| for MRC Integration             |
    	+---------------------------------*/
--{BUG4301323
--    	ar_mrc_engine.maintain_mrc_data(
--                 p_event_mode        => 'DELETE',
--                 p_table_name        => 'AR_BATCHES',
--                 p_mode              => 'SINGLE',
--                 p_key_value         => p_bat_id);
--}
    --
    arp_standard.debug( '<<<<<<<< arp_cr_batches_pkg.delete_p' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_batches_pkg.delete_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function locks a row in AR_BATCHES table                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_p(
        p_row_id        VARCHAR2,
        p_set_of_books_id  ar_batches.set_of_books_id%TYPE,
        p_batch_id  ar_batches.batch_id%TYPE,
        p_batch_applied_status  ar_batches.batch_applied_status%TYPE,
        p_batch_date  ar_batches.batch_date%TYPE,
        p_batch_source_id  ar_batches.batch_source_id%TYPE,
        p_comments  ar_batches.comments%TYPE,
        p_control_amount  ar_batches.control_amount%TYPE,
        p_control_count  ar_batches.control_count%TYPE,
        p_exchange_date  ar_batches.exchange_date%TYPE,
        p_exchange_rate  ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type  ar_batches.exchange_rate_type%TYPE,
        p_lockbox_batch_name  ar_batches.lockbox_batch_name%TYPE,
        p_media_reference  ar_batches.media_reference%TYPE,
        p_operation_request_id  ar_batches.operation_request_id%TYPE,
        p_receipt_class_id  ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id  ar_batches.receipt_method_id%TYPE,
        p_remit_method_code  ar_batches.remit_method_code%TYPE,
        p_remittance_bank_account_id  ar_batches.remit_bank_acct_use_id%type,
        p_remittance_bank_branch_id  ar_batches.remittance_bank_branch_id%TYPE,
        p_attribute_category  ar_batches.attribute_category%TYPE,
        p_attribute1  ar_batches.attribute1%TYPE,
        p_attribute2  ar_batches.attribute2%TYPE,
        p_attribute3  ar_batches.attribute3%TYPE,
        p_attribute4  ar_batches.attribute4%TYPE,
        p_attribute5  ar_batches.attribute5%TYPE,
        p_attribute6  ar_batches.attribute6%TYPE,
        p_attribute7  ar_batches.attribute7%TYPE,
        p_attribute8  ar_batches.attribute8%TYPE,
        p_attribute9  ar_batches.attribute9%TYPE,
        p_attribute10  ar_batches.attribute10%TYPE,
        p_attribute11  ar_batches.attribute11%TYPE,
        p_attribute12  ar_batches.attribute12%TYPE,
        p_attribute13  ar_batches.attribute13%TYPE,
        p_attribute14  ar_batches.attribute14%TYPE,
        p_attribute15  ar_batches.attribute15%TYPE,
        p_request_id  ar_batches.request_id%TYPE,
        p_transmission_id  ar_batches.transmission_id%TYPE,
        p_bank_deposit_number  ar_batches.bank_deposit_number%TYPE ) IS
    CURSOR C IS
	SELECT *
	FROM ar_batches
	WHERE rowid = p_row_id
	FOR UPDATE of BATCH_ID NOWAIT;
    Recinfo C%ROWTYPE;
--
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
	CLOSE C;
	FND_MESSAGE.Set_Name( 'FND', 'FORM_RECORD_DELETED' );
	APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if(
		(Recinfo.set_of_books_id = p_set_of_books_id )
	    AND (Recinfo.batch_id = p_batch_id )
	    AND (Recinfo.batch_applied_status = p_batch_applied_status )
	    AND (Recinfo.batch_date = p_batch_date )
	    AND (Recinfo.batch_source_id = p_batch_source_id )
	    AND (   (Recinfo.comments = p_comments )
	        OR  (    (Recinfo.comments IS NULL )
		    AND  (p_comments IS NULL )))
            /*

	    AND (   (Recinfo.control_count = p_control_count )
	        OR  (    (Recinfo.control_count IS NULL )
		    AND  (p_control_count IS NULL )))

	    AND (   (Recinfo.control_amount = p_control_amount )
	        OR  (    (Recinfo.control_amount IS NULL )
		    AND  (p_control_amount IS NULL )))
            */
	    AND (   (Recinfo.exchange_date = p_exchange_date )
	        OR  (    (Recinfo.exchange_date IS NULL )
		    AND  (p_exchange_date IS NULL )))
	    AND (   (Recinfo.exchange_rate = p_exchange_rate )
	        OR  (    (Recinfo.exchange_rate IS NULL )
		    AND  (p_exchange_rate IS NULL )))
	    AND (   (Recinfo.exchange_rate_type = p_exchange_rate_type )
	        OR  (    (Recinfo.exchange_rate_type IS NULL )
		    AND  (p_exchange_rate_type IS NULL )))
	    AND (   (Recinfo.lockbox_batch_name = p_lockbox_batch_name )
	        OR  (    (Recinfo.lockbox_batch_name IS NULL )
		    AND  (p_lockbox_batch_name IS NULL )))
	    AND (   (Recinfo.media_reference = p_media_reference )
	        OR  (    (Recinfo.media_reference IS NULL )
		    AND  (p_media_reference IS NULL )))
	    AND (   (Recinfo.operation_request_id = p_operation_request_id )
	        OR  (    (Recinfo.operation_request_id IS NULL )
		    AND  (p_operation_request_id IS NULL )))
	    AND (   (Recinfo.receipt_class_id = p_receipt_class_id )
	        OR  (    (Recinfo.receipt_class_id IS NULL )
		    AND  (p_receipt_class_id IS NULL )))
	    AND (   (Recinfo.receipt_method_id = p_receipt_method_id )
	        OR  (    (Recinfo.receipt_method_id IS NULL )
		    AND  (p_receipt_method_id IS NULL )))
	    AND (   (Recinfo.remit_method_code = p_remit_method_code )
	        OR  (    (Recinfo.remit_method_code IS NULL )
		    AND  (p_remit_method_code IS NULL )))
	    AND (   (Recinfo.remit_bank_acct_use_id = p_remittance_bank_account_id )
	        OR  (    (Recinfo.remit_bank_acct_use_id IS NULL )
		    AND  (p_remittance_bank_account_id IS NULL )))
	    AND (   (Recinfo.transmission_id = p_transmission_id )
	        OR  (    (Recinfo.transmission_id IS NULL )
		    AND  (p_transmission_id IS NULL )))
	    AND (   (Recinfo.request_id = p_request_id )
	        OR  (    (Recinfo.request_id IS NULL )
		    AND  (p_request_id IS NULL )))
	    AND (   (Recinfo.bank_deposit_number = p_bank_deposit_number )
	        OR  (    (Recinfo.bank_deposit_number IS NULL )
		    AND  (p_bank_deposit_number IS NULL )))
	    AND (   (Recinfo.attribute_category = p_attribute_category )
	        OR  (    (Recinfo.attribute_category IS NULL )
		    AND  (p_attribute_category IS NULL )))
	    AND (   (Recinfo.attribute1 = p_attribute1 )
	        OR  (    (Recinfo.attribute1 IS NULL )
		    AND  (p_attribute1 IS NULL )))
	    AND (   (Recinfo.attribute2 = p_attribute2 )
	        OR  (    (Recinfo.attribute2 IS NULL )
		    AND  (p_attribute2 IS NULL )))
	    AND (   (Recinfo.attribute3 = p_attribute3 )
	        OR  (    (Recinfo.attribute3 IS NULL )
		    AND  (p_attribute3 IS NULL )))
	    AND (   (Recinfo.attribute4 = p_attribute4 )
	        OR  (    (Recinfo.attribute4 IS NULL )
		    AND  (p_attribute4 IS NULL )))
	    AND (   (Recinfo.attribute5 = p_attribute5 )
	        OR  (    (Recinfo.attribute5 IS NULL )
		    AND  (p_attribute5 IS NULL )))
	    AND (   (Recinfo.attribute6 = p_attribute6 )
	        OR  (    (Recinfo.attribute6 IS NULL )
		    AND  (p_attribute6 IS NULL )))
	    AND (   (Recinfo.attribute7 = p_attribute7 )
	        OR  (    (Recinfo.attribute7 IS NULL )
		    AND  (p_attribute7 IS NULL )))
	    AND (   (Recinfo.attribute8 = p_attribute8 )
	        OR  (    (Recinfo.attribute8 IS NULL )
		    AND  (p_attribute8 IS NULL )))
	    AND (   (Recinfo.attribute9 = p_attribute9 )
	        OR  (    (Recinfo.attribute9 IS NULL )
		    AND  (p_attribute9 IS NULL )))
	    AND (   (Recinfo.attribute10 = p_attribute10 )
	        OR  (    (Recinfo.attribute10 IS NULL )
		    AND  (p_attribute10 IS NULL )))
	    AND (   (Recinfo.attribute11 = p_attribute11 )
	        OR  (    (Recinfo.attribute11 IS NULL )
		    AND  (p_attribute11 IS NULL )))
	    AND (   (Recinfo.attribute12 = p_attribute12 )
	        OR  (    (Recinfo.attribute12 IS NULL )
		    AND  (p_attribute12 IS NULL )))
	    AND (   (Recinfo.attribute13 = p_attribute13 )
	        OR  (    (Recinfo.attribute13 IS NULL )
		    AND  (p_attribute13 IS NULL )))
	    AND (   (Recinfo.attribute14 = p_attribute14 )
	        OR  (    (Recinfo.attribute14 IS NULL )
		    AND  (p_attribute14 IS NULL )))
	    AND (   (Recinfo.attribute15 = p_attribute15 )
	        OR  (    (Recinfo.attribute15 IS NULL )
		    AND  (p_attribute15 IS NULL )))
    ) then
        return;
    else
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('lock_p: ' || 'set_of_books_id:      ' || recinfo.set_of_books_id || ' -- ' || p_set_of_books_id);
	   arp_standard.debug('lock_p: ' || 'batch_id:             ' || recinfo.batch_id || ' -- ' || p_batch_id);
	   arp_standard.debug('lock_p: ' || 'batch_applied_status: ' || recinfo.batch_applied_status || ' -- ' ||
										p_batch_applied_status);
	   arp_standard.debug('lock_p: ' || 'batch_date:           ' || recinfo.batch_date || ' -- ' || p_batch_date);
	   arp_standard.debug('lock_p: ' || 'batch_source_id:      ' || recinfo.batch_source_id || ' -- ' || p_batch_source_id);
	   arp_standard.debug('lock_p: ' || 'comments:             ' || recinfo.comments || ' -- ' || p_comments);
	   arp_standard.debug('lock_p: ' || 'control_count:        ' || recinfo.control_count || ' -- ' || p_control_count);
	   arp_standard.debug('lock_p: ' || 'exchange_date:        ' || recinfo.exchange_date || ' -- ' || p_exchange_date);
	   arp_standard.debug('lock_p: ' || 'exchange_rate:        ' || recinfo.exchange_rate || ' -- ' || p_exchange_rate);
	   arp_standard.debug('lock_p: ' || 'exchange_Rate_type:   ' || recinfo.exchange_Rate_type||' -- '||p_exchange_Rate_type);
	   arp_standard.debug('lock_p: ' || 'lockbox_batch_name:   ' || recinfo.lockbox_batch_name||' -- '||p_lockbox_batch_name);
	   arp_standard.debug('lock_p: ' || 'media_reference:      ' || recinfo.media_reference || ' -- ' || p_media_reference);
	   arp_standard.debug('lock_p: ' || 'operation_request_id: ' || recinfo.operation_request_id || ' -- ' ||
										p_operation_request_id);
	   arp_standard.debug('lock_p: ' || 'receipt_class_id:     ' || recinfo.receipt_class_id || ' -- ' || p_receipt_class_id);
	   arp_standard.debug('lock_p: ' || 'receipt_method_id:    ' || recinfo.receipt_method_id || ' -- ' || p_receipt_method_id);
	   arp_standard.debug('lock_p: ' || 'remit_method_code:    ' || recinfo.remit_method_code || ' -- ' || p_remit_method_code);
	   arp_standard.debug('lock_p: ' || 'remit_bank_acct_use_id:   ' || recinfo.remit_bank_acct_use_id || ' -- ' ||
										p_remittance_bank_account_id);
	   arp_standard.debug('lock_p: ' || 'transmission_id:      ' || recinfo.transmission_id || ' -- ' || p_transmission_id);
	   arp_standard.debug('lock_p: ' || 'request_id:           ' || recinfo.request_id || ' -- ' || p_request_id);
	   arp_standard.debug('lock_p: ' || 'bank_deposit_number:  ' || recinfo.bank_deposit_number||' -- '||p_bank_deposit_number);
	   arp_standard.debug('lock_p: ' || 'attribute_category:   ' || recinfo.attribute_category||' -- '||p_attribute_category);
	   arp_standard.debug('lock_p: ' || 'attribute1:           ' || recinfo.attribute1  || ' -- ' || p_attribute1);
	   arp_standard.debug('lock_p: ' || 'attribute2:           ' || recinfo.attribute2  || ' -- ' || p_attribute2);
	   arp_standard.debug('lock_p: ' || 'attribute3:           ' || recinfo.attribute3  || ' -- ' || p_attribute3);
	   arp_standard.debug('lock_p: ' || 'attribute4:           ' || recinfo.attribute4  || ' -- ' || p_attribute4);
	   arp_standard.debug('lock_p: ' || 'attribute5:           ' || recinfo.attribute5  || ' -- ' || p_attribute5);
	   arp_standard.debug('lock_p: ' || 'attribute6:           ' || recinfo.attribute6  || ' -- ' || p_attribute6);
	   arp_standard.debug('lock_p: ' || 'attribute7:           ' || recinfo.attribute7  || ' -- ' || p_attribute7);
	   arp_standard.debug('lock_p: ' || 'attribute8:           ' || recinfo.attribute8  || ' -- ' || p_attribute8);
	   arp_standard.debug('lock_p: ' || 'attribute9:           ' || recinfo.attribute9  || ' -- ' || p_attribute9);
	   arp_standard.debug('lock_p: ' || 'attribute10:          ' || recinfo.attribute10 || ' -- ' || p_attribute10);
	   arp_standard.debug('lock_p: ' || 'attribute11:          ' || recinfo.attribute11 || ' -- ' || p_attribute11);
	   arp_standard.debug('lock_p: ' || 'attribute12:          ' || recinfo.attribute12 || ' -- ' || p_attribute12);
	   arp_standard.debug('lock_p: ' || 'attribute13:          ' || recinfo.attribute13 || ' -- ' || p_attribute13);
	   arp_standard.debug('lock_p: ' || 'attribute14:          ' || recinfo.attribute14 || ' -- ' || p_attribute14);
	   arp_standard.debug('lock_p: ' || 'attribute15:          ' || recinfo.attribute15 || ' -- ' || p_attribute15);
	END IF;

        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
    end if;
END lock_p;
--
PROCEDURE nowaitlock_p( p_bat_id IN ar_batches.batch_id%TYPE ) IS
l_bat_id		ar_batches.batch_id%TYPE;
BEGIN
    arp_standard.debug( '>>>>>>>> arp_cr_batches_pkg.nowaitlock_p' );
    --
    SELECT batch_id
    INTO   l_bat_id
    FROM  ar_batches
    WHERE batch_id = p_bat_id
    FOR UPDATE OF STATUS NOWAIT;
    --
    arp_standard.debug( '<<<<<<<< arp_cr_batches_pkg.nowaitlock_p' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_cr_batches_pkg.nowaitlock_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function fetches a row from AR_BATCHES table                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_bat_id - Batch Id of row to be fetched from AR_BATCHES |
 |              OUT:                                                         |
 |                  p_adj_rec - Batches Record structure                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_p( p_batch_id IN ar_batches.batch_id%TYPE,
                   p_batch_rec OUT NOCOPY ar_batches%ROWTYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_cr_batches_pkg.fetch_p' );
    --
    SELECT *
    INTO   p_batch_rec
    FROM   ar_batches
    WHERE  batch_id = p_batch_id;
    --
    arp_standard.debug( '<<<<<<<<< arp_cr_batches_pkg.fetch_p' );
    EXCEPTION
    --
         WHEN OTHERS THEN
	      arp_standard.debug( 'EXCEPTION: arp_cr_batches_pkg.fetch_p' );
              RAISE;
END;
--
PROCEDURE lock_fetch_p( p_batch_rec IN OUT NOCOPY ar_batches%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_batches_pkg.lock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_batch_rec
    FROM  ar_batches
    WHERE batch_id = p_batch_rec.batch_id
    FOR UPDATE OF STATUS;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_batches_pkg.lock_fetch_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_cr_batches_pkg.lock_fetch_p' );
	    END IF;
            RAISE;
END lock_fetch_p;
--
--
PROCEDURE nowaitlock_fetch_p( p_batch_rec IN OUT NOCOPY ar_batches%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_batches_pkg.nowaitlock_fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_batch_rec
    FROM  ar_batches
    WHERE batch_id = p_batch_rec.batch_id
    FOR UPDATE OF STATUS NOWAIT;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_cr_batches_pkg.nowaitlock_fetch_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_cr_batches_pkg.nowaitlock_fetch_p' );
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
END  ARP_CR_BATCHES_PKG;
--

/
