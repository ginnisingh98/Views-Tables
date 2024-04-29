--------------------------------------------------------
--  DDL for Package Body ARP_CT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CT_PKG" AS
/* $Header: ARTITRXB.pls 120.18.12010000.5 2010/02/04 13:04:39 npanchak ship $ */

  /*---------------------------------------------------------------+
   |  Package global variables to hold the parsed update cursors.  |
   |  This allows the cursors to be reused without being reparsed. |
   +---------------------------------------------------------------*/

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/
  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

  pg_cursor1  integer := '';

  /*-------------------------------------+
   |  WHO column values from FND_GLOBAL  |
   +-------------------------------------*/

  pg_user_id          number;
  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;


/*==========================================================================+
 | PROCEDURE                                                                |
 |    bind_trx_variables                                                    |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    Binds variables from the record variable to the bind variables        |
 |    in the dynamic SQL update statement.                                  |
 |                                                                          |
 | SCOPE - PRIVATE                                                          |
 |                                                                          |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |    dbms_sql.bind_variable                                                |
 |    arp_util.debug                                                        |
 |                                                                          |
 | ARGUMENTS  : IN:                                                         |
 |                    p_update_cursor  - ID of the update cursor            |
 |                    p_trx_rec        - ra_customer_trx record             |
 |              OUT:                                                        |
 |                    None                                                  |
 |                                                                          |
 | RETURNS    : NONE                                                        |
 |                                                                          |
 | NOTES                                                                    |
 |                                                                          |
 | MODIFICATION HISTORY                                                     |
 | 06-JUN-95   Charlie Tomberg  Created    			            |
 |                                                                          |
 | 20-MAR-2000 J Rautiainen     Added BR project related columns            |
 |                              BR_AMOUNT, BR_UNPAID_FLAG,BR_ON_HOLD_FLAG,  |
 |                              DRAWEE_ID, DRAWEE_CONTACT_ID,               |
 |				DRAWEE_SITE_USE_ID, DRAWEE_BANK_ACCOUNT_ID, |
 |                              REMITTANCE_BANK_ACCOUNT_ID,                 |
 |                              OVERRIDE_REMIT_ACCOUNT_FLAG and             |
 |                              SPECIAL_INSTRUCTIONSinto table handlers     |
 | 24-JUL-2000 J Rautiainen     Added BR project related column             |
 |                              REMITTANCE_BATCH_ID	                    |
 |            								    |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns                 |
 |                              address_verification_code and	            |
 |				approval_code	and		            |
 |				bill_to_address_id and	                    |
 |				edi_processed_flag and			    |
 |				edi_processed_status and		    |
 |				payment_server_order_num and		    |
 |				post_request_id and			    |
 |				request_id and				    |
 |				ship_to_address_id		    	    |
 |				wh_update_date			            |
 | 				into the table handlers.  		    |
 | 20-Jun-2002 Sahana           Bug2427456 : Added global attribute columns |
 +===========================================================================*/


PROCEDURE bind_trx_variables(p_update_cursor IN integer,
                             p_trx_rec       IN ra_customer_trx%rowtype) IS

BEGIN

   arp_util.debug('arp_ct_pkg.bind_trx_variables()+');

  /*------------------+
   |  Dummy constants |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_flag_dummy',
                          AR_FLAG_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_number_dummy',
                          AR_NUMBER_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_date_dummy',
                          AR_DATE_DUMMY);


  /*------------------+
   |  WHO variables   |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':pg_user_id',
                          pg_user_id);

   dbms_sql.bind_variable(p_update_cursor, ':pg_login_id',
                          pg_login_id);

   dbms_sql.bind_variable(p_update_cursor, ':pg_conc_login_id',
                          pg_conc_login_id);


  /*----------------------------------------------+
   |  Bind variables for all columns in the table |
   +----------------------------------------------*/


   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_id',
                          p_trx_rec.customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':trx_number',
                          p_trx_rec.trx_number);

   dbms_sql.bind_variable(p_update_cursor, ':created_by',
                          p_trx_rec.created_by);

   dbms_sql.bind_variable(p_update_cursor, ':creation_date',
                          p_trx_rec.creation_date);

   dbms_sql.bind_variable(p_update_cursor, ':last_updated_by',
                          p_trx_rec.last_updated_by);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_date',
                          p_trx_rec.last_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_login',
                          p_trx_rec.last_update_login);

   dbms_sql.bind_variable(p_update_cursor, ':set_of_books_id',
                          p_trx_rec.set_of_books_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_application_id',
                          p_trx_rec.program_application_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_id',
                          p_trx_rec.program_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_update_date',
                          p_trx_rec.program_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':posting_control_id',
                          p_trx_rec.posting_control_id);

   dbms_sql.bind_variable(p_update_cursor, ':ra_post_loop_number',
                          p_trx_rec.ra_post_loop_number);

   dbms_sql.bind_variable(p_update_cursor, ':complete_flag',
                          p_trx_rec.complete_flag);

   dbms_sql.bind_variable(p_update_cursor, ':initial_customer_trx_id',
                          p_trx_rec.initial_customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':previous_customer_trx_id',
                          p_trx_rec.previous_customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':related_customer_trx_id',
                          p_trx_rec.related_customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':recurred_from_trx_number',
                          p_trx_rec.recurred_from_trx_number);

   dbms_sql.bind_variable(p_update_cursor, ':cust_trx_type_id',
                          p_trx_rec.cust_trx_type_id);

   dbms_sql.bind_variable(p_update_cursor, ':batch_id',
                          p_trx_rec.batch_id);

   dbms_sql.bind_variable(p_update_cursor, ':batch_source_id',
                          p_trx_rec.batch_source_id);

   dbms_sql.bind_variable(p_update_cursor, ':agreement_id',
                          p_trx_rec.agreement_id);

   dbms_sql.bind_variable(p_update_cursor, ':trx_date',
                          p_trx_rec.trx_date);

   dbms_sql.bind_variable(p_update_cursor, ':bill_to_customer_id',
                          p_trx_rec.bill_to_customer_id);

   dbms_sql.bind_variable(p_update_cursor, ':bill_to_contact_id',
                          p_trx_rec.bill_to_contact_id);

   dbms_sql.bind_variable(p_update_cursor, ':bill_to_site_use_id',
                          p_trx_rec.bill_to_site_use_id);

   dbms_sql.bind_variable(p_update_cursor, ':ship_to_customer_id',
                          p_trx_rec.ship_to_customer_id);

   dbms_sql.bind_variable(p_update_cursor, ':ship_to_contact_id',
                          p_trx_rec.ship_to_contact_id);

   dbms_sql.bind_variable(p_update_cursor, ':ship_to_site_use_id',
                          p_trx_rec.ship_to_site_use_id);

   dbms_sql.bind_variable(p_update_cursor, ':sold_to_customer_id',
                          p_trx_rec.sold_to_customer_id);

   dbms_sql.bind_variable(p_update_cursor, ':sold_to_site_use_id',
                          p_trx_rec.sold_to_site_use_id);

   dbms_sql.bind_variable(p_update_cursor, ':sold_to_contact_id',
                          p_trx_rec.sold_to_contact_id);

   dbms_sql.bind_variable(p_update_cursor, ':customer_reference',
                          p_trx_rec.customer_reference);

   dbms_sql.bind_variable(p_update_cursor, ':customer_reference_date',
                          p_trx_rec.customer_reference_date);

   dbms_sql.bind_variable(p_update_cursor, ':credit_method_for_installments',
                          p_trx_rec.credit_method_for_installments);

   dbms_sql.bind_variable(p_update_cursor, ':credit_method_for_rules',
                          p_trx_rec.credit_method_for_rules);

   dbms_sql.bind_variable(p_update_cursor, ':start_date_commitment',
                          p_trx_rec.start_date_commitment);

   dbms_sql.bind_variable(p_update_cursor, ':end_date_commitment',
                          p_trx_rec.end_date_commitment);

   dbms_sql.bind_variable(p_update_cursor, ':exchange_date',
                          p_trx_rec.exchange_date);

   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate',
                          p_trx_rec.exchange_rate);

   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate_type',
                          p_trx_rec.exchange_rate_type);

   dbms_sql.bind_variable(p_update_cursor, ':customer_bank_account_id',
                          p_trx_rec.customer_bank_account_id);

   dbms_sql.bind_variable(p_update_cursor, ':finance_charges',
                          p_trx_rec.finance_charges);

   dbms_sql.bind_variable(p_update_cursor, ':fob_point',
                          p_trx_rec.fob_point);

   dbms_sql.bind_variable(p_update_cursor, ':comments',
                          p_trx_rec.comments);

   dbms_sql.bind_variable(p_update_cursor, ':internal_notes',
                          p_trx_rec.internal_notes);

   dbms_sql.bind_variable(p_update_cursor, ':invoice_currency_code',
                          p_trx_rec.invoice_currency_code);

   dbms_sql.bind_variable(p_update_cursor, ':invoicing_rule_id',
                          p_trx_rec.invoicing_rule_id);

   dbms_sql.bind_variable(p_update_cursor, ':last_printed_sequence_num',
                          p_trx_rec.last_printed_sequence_num);

   dbms_sql.bind_variable(p_update_cursor, ':orig_system_batch_name',
                          p_trx_rec.orig_system_batch_name);

   dbms_sql.bind_variable(p_update_cursor, ':primary_salesrep_id',
                          p_trx_rec.primary_salesrep_id);

   dbms_sql.bind_variable(p_update_cursor, ':printing_count',
                          p_trx_rec.printing_count);

   dbms_sql.bind_variable(p_update_cursor, ':printing_last_printed',
                          p_trx_rec.printing_last_printed);

   dbms_sql.bind_variable(p_update_cursor, ':printing_option',
                          p_trx_rec.printing_option);

   dbms_sql.bind_variable(p_update_cursor, ':printing_original_date',
                          p_trx_rec.printing_original_date);

   dbms_sql.bind_variable(p_update_cursor, ':printing_pending',
                          p_trx_rec.printing_pending);

   dbms_sql.bind_variable(p_update_cursor, ':purchase_order',
                          p_trx_rec.purchase_order);

   dbms_sql.bind_variable(p_update_cursor, ':purchase_order_date',
                          p_trx_rec.purchase_order_date);

   dbms_sql.bind_variable(p_update_cursor, ':purchase_order_revision',
                          p_trx_rec.purchase_order_revision);

   dbms_sql.bind_variable(p_update_cursor, ':receipt_method_id',
                          p_trx_rec.receipt_method_id);

   dbms_sql.bind_variable(p_update_cursor, ':remit_to_address_id',
                          p_trx_rec.remit_to_address_id);

   dbms_sql.bind_variable(p_update_cursor, ':shipment_id',
                          p_trx_rec.shipment_id);

   dbms_sql.bind_variable(p_update_cursor, ':ship_date_actual',
                          p_trx_rec.ship_date_actual);

   dbms_sql.bind_variable(p_update_cursor, ':ship_via',
                          p_trx_rec.ship_via);

   dbms_sql.bind_variable(p_update_cursor, ':term_due_date',
                          p_trx_rec.term_due_date);

   dbms_sql.bind_variable(p_update_cursor, ':term_id',
                          p_trx_rec.term_id);

   dbms_sql.bind_variable(p_update_cursor, ':territory_id',
                          p_trx_rec.territory_id);

   dbms_sql.bind_variable(p_update_cursor, ':waybill_number',
                          p_trx_rec.waybill_number);

   dbms_sql.bind_variable(p_update_cursor, ':status_trx',
                          p_trx_rec.status_trx);

   dbms_sql.bind_variable(p_update_cursor, ':reason_code',
                          p_trx_rec.reason_code);

   dbms_sql.bind_variable(p_update_cursor, ':doc_sequence_id',
                          p_trx_rec.doc_sequence_id);

   dbms_sql.bind_variable(p_update_cursor, ':doc_sequence_value',
                          p_trx_rec.doc_sequence_value);

   dbms_sql.bind_variable(p_update_cursor, ':paying_customer_id',
                          p_trx_rec.paying_customer_id);

   dbms_sql.bind_variable(p_update_cursor, ':paying_site_use_id',
                          p_trx_rec.paying_site_use_id);

   dbms_sql.bind_variable(p_update_cursor, ':related_batch_source_id',
                          p_trx_rec.related_batch_source_id);

   dbms_sql.bind_variable(p_update_cursor, ':default_tax_exempt_flag',
                          p_trx_rec.default_tax_exempt_flag);

   dbms_sql.bind_variable(p_update_cursor, ':created_from',
                          p_trx_rec.created_from);

   dbms_sql.bind_variable(p_update_cursor, ':default_ussgl_trx_code_context',
                          p_trx_rec.default_ussgl_trx_code_context);

   dbms_sql.bind_variable(p_update_cursor, ':default_ussgl_transaction_code',
                          p_trx_rec.default_ussgl_transaction_code);

   dbms_sql.bind_variable(p_update_cursor, ':old_trx_number',
                          p_trx_rec.old_trx_number);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_context',
                          p_trx_rec.interface_header_context);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute1',
                          p_trx_rec.interface_header_attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute2',
                          p_trx_rec.interface_header_attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute3',
                          p_trx_rec.interface_header_attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute4',
                          p_trx_rec.interface_header_attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute5',
                          p_trx_rec.interface_header_attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute6',
                          p_trx_rec.interface_header_attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute7',
                          p_trx_rec.interface_header_attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute8',
                          p_trx_rec.interface_header_attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute9',
                          p_trx_rec.interface_header_attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute10',
                          p_trx_rec.interface_header_attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute11',
                          p_trx_rec.interface_header_attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute12',
                          p_trx_rec.interface_header_attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute13',
                          p_trx_rec.interface_header_attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute14',
                          p_trx_rec.interface_header_attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':interface_header_attribute15',
                          p_trx_rec.interface_header_attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_trx_rec.attribute_category);

   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_trx_rec.attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_trx_rec.attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_trx_rec.attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_trx_rec.attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_trx_rec.attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_trx_rec.attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_trx_rec.attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_trx_rec.attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_trx_rec.attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_trx_rec.attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_trx_rec.attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_trx_rec.attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_trx_rec.attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_trx_rec.attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_trx_rec.attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':br_amount',
                          p_trx_rec.br_amount);

   dbms_sql.bind_variable(p_update_cursor, ':br_unpaid_flag',
                          p_trx_rec.br_unpaid_flag);

   dbms_sql.bind_variable(p_update_cursor, ':br_on_hold_flag',
                          p_trx_rec.br_on_hold_flag);

   dbms_sql.bind_variable(p_update_cursor, ':drawee_id',
                          p_trx_rec.drawee_id);

   dbms_sql.bind_variable(p_update_cursor, ':drawee_contact_id',
                          p_trx_rec.drawee_contact_id);

   dbms_sql.bind_variable(p_update_cursor, ':drawee_site_use_id',
                          p_trx_rec.drawee_site_use_id);

   dbms_sql.bind_variable(p_update_cursor, ':drawee_bank_account_id',
                          p_trx_rec.drawee_bank_account_id);

   dbms_sql.bind_variable(p_update_cursor, ':remittance_bank_account_id',
                          p_trx_rec.remit_bank_acct_use_id);

   dbms_sql.bind_variable(p_update_cursor, ':override_remit_account_flag',
                          p_trx_rec.override_remit_account_flag);

   dbms_sql.bind_variable(p_update_cursor, ':special_instructions',
                          p_trx_rec.special_instructions);

   dbms_sql.bind_variable(p_update_cursor, ':remittance_batch_id',
                          p_trx_rec.remittance_batch_id);

   dbms_sql.bind_variable(p_update_cursor, ':address_verification_code',
                          p_trx_rec.address_verification_code);

   dbms_sql.bind_variable(p_update_cursor, ':approval_code',
                          p_trx_rec.approval_code);

   dbms_sql.bind_variable(p_update_cursor, ':bill_to_address_id',
                          p_trx_rec.bill_to_address_id);

   dbms_sql.bind_variable(p_update_cursor, ':edi_processed_flag',
                          p_trx_rec.edi_processed_flag);

   dbms_sql.bind_variable(p_update_cursor, ':edi_processed_status',
                          p_trx_rec.edi_processed_status);

   dbms_sql.bind_variable(p_update_cursor, ':payment_server_order_num',
                          p_trx_rec.payment_server_order_num);

   dbms_sql.bind_variable(p_update_cursor, ':post_request_id',
                          p_trx_rec.post_request_id);

   dbms_sql.bind_variable(p_update_cursor, ':request_id',
                          p_trx_rec.request_id);

   dbms_sql.bind_variable(p_update_cursor, ':ship_to_address_id',
                          p_trx_rec.ship_to_address_id);

   dbms_sql.bind_variable(p_update_cursor, ':wh_update_date',
                          p_trx_rec.wh_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':legal_entity_id',
                          p_trx_rec.legal_entity_id);
/* PAYMENT_UPTAKE */
   dbms_sql.bind_variable(p_update_cursor, ':payment_trxn_extension_id',
                          p_trx_rec.payment_trxn_extension_id);

   dbms_sql.bind_variable(p_update_cursor, ':billing_date',
                          p_trx_rec.billing_date);
/*Start of Bug2427456*/
   dbms_sql.bind_variable(p_update_cursor, ':global_attribute_category',
                          p_trx_rec.global_attribute_category);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute1',
                          p_trx_rec.global_attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute2',
                          p_trx_rec.global_attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute3',
                          p_trx_rec.global_attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute4',
                          p_trx_rec.global_attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute5',
                          p_trx_rec.global_attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute6',
                          p_trx_rec.global_attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute7',
                          p_trx_rec.global_attribute7);


   dbms_sql.bind_variable(p_update_cursor, ':global_attribute8',
                          p_trx_rec.global_attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute9',
                          p_trx_rec.global_attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute10',
                          p_trx_rec.global_attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute11',
                          p_trx_rec.global_attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute12',
                          p_trx_rec.global_attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute13',
                          p_trx_rec.global_attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute14',
                          p_trx_rec.global_attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute15',
                          p_trx_rec.global_attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute16',
                          p_trx_rec.global_attribute16);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute17',
                          p_trx_rec.global_attribute17);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute18',
                          p_trx_rec.global_attribute18);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute19',
                          p_trx_rec.global_attribute19);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute20',
                          p_trx_rec.global_attribute20);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute21',
                          p_trx_rec.global_attribute21);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute22',
                          p_trx_rec.global_attribute22);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute23',
                          p_trx_rec.global_attribute23);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute24',
                          p_trx_rec.global_attribute24);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute25',
                          p_trx_rec.global_attribute25);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute26',
                          p_trx_rec.global_attribute26);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute27',
                          p_trx_rec.global_attribute27);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute28',
                          p_trx_rec.global_attribute28);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute29',
                          p_trx_rec.global_attribute29);

   dbms_sql.bind_variable(p_update_cursor, ':global_attribute30',
                          p_trx_rec.global_attribute30);

/*End of Bug2427456*/
   arp_util.debug('arp_ct_pkg.bind_trx_variables()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.bind_trx_variables()');
        RAISE;

END;


/*==========================================================================+
 | PROCEDURE                                           		            |
 |    construct_trx_update_stmt 					    |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    Copies the text of the dynamic SQL update statement into the          |
 |    out NOCOPY paramater. The update statement does not contain a where   |
 |    clause since this is the dynamic part that is added later.            |
 |                                                                          |
 | SCOPE - PRIVATE                                                          |
 |                                                                          |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |    arp_util.debug                                                        |
 |                                                                          |
 | ARGUMENTS  : IN:                                                         |
 |                    None.                                                 |
 |              OUT:                                                        |
 |                    update_text  - text of the update statement           |
 |                                                                          |
 | RETURNS    : NONE                                                        |
 |                                                                          |
 | NOTES                                                                    |
 |   This statement only updates columns in the trx record that do not      |
 |   contain the dummy values that indicate that they should not be changed.|
 |                                                                          |
 | MODIFICATION HISTORY                                                     |
 |     06-JUN-95  Charlie Tomberg     Created                               |
 |                                                                          |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns            |
 |                              BR_AMOUNT, BR_UNPAID_FLAG,BR_ON_HOLD_FLAG,  |
 |                              DRAWEE_ID, DRAWEE_CONTACT_ID,               |
 |                              DRAWEE_SITE_USE_ID, DRAWEE_BANK_ACCOUNT_ID, |
 |                              REMITTANCE_BANK_ACCOUNT_ID,   		    |
 |                              OVERRIDE_REMIT_ACCOUNT_FLAG and             |
 |                              SPECIAL_INSTRUCTIONSinto table handlers     |
 | 24-JUL-2000  J Rautiainen    Added BR project related column             |
 |                              REMITTANCE_BATCH_ID		            |
 |            							            |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns                 |
 |                              address_verification_code and	            |
 |				approval_code	and                         |
 |				bill_to_address_id and		            |
 |				edi_processed_flag and		            |
 |				edi_processed_status and		    |
 |				payment_server_order_num and		    |
 |				post_request_id and			    |
 |				request_id and                              |
 |				ship_to_address_id			    |
 |				wh_update_date				    |
 | 				into the table handlers.  		    |
 |                                                                          |
 | 20-Jun-2002  Sahana    Bug2427456 Added global attribute columns         |
 +==========================================================================*/

PROCEDURE construct_trx_update_stmt( update_text OUT NOCOPY varchar2) IS

BEGIN
   arp_util.debug('arp_ct_pkg.construct_trx_update_stmt()+');

   update_text :=
 'UPDATE ra_customer_trx
   SET    customer_trx_id =
               DECODE(:customer_trx_id,
                      :ar_number_dummy, customer_trx_id,
                                        :customer_trx_id),
          trx_number =
               DECODE(:trx_number,
                      :ar_text_dummy, trx_number,
                                      :trx_number),
          created_by =
               DECODE(:created_by,
                      :ar_number_dummy, created_by,
                                        :created_by),
          creation_date =
               DECODE(:creation_date,
                      :ar_date_dummy, creation_date,
                                      :creation_date),
          last_updated_by =
               DECODE(:last_updated_by,
                      :ar_number_dummy, :pg_user_id,
                                        :last_updated_by),
          last_update_date =
               DECODE(:last_update_date,
                      :ar_date_dummy, sysdate,
                                      :last_update_date),
          last_update_login =
               DECODE(:last_update_login,
                      :ar_number_dummy, nvl(:pg_conc_login_id,
                                            :pg_login_id),
                                        :last_update_login),
          set_of_books_id =
               DECODE(:set_of_books_id,
                      :ar_number_dummy, set_of_books_id,
                                        :set_of_books_id),
          program_application_id =
               DECODE(:program_application_id,
                      :ar_number_dummy, program_application_id,
                                        :program_application_id),
          program_id =
               DECODE(:program_id,
                      :ar_number_dummy, program_id,
                                        :program_id),
          program_update_date =
               DECODE(:program_update_date,
                      :ar_date_dummy, program_update_date,
                                      :program_update_date),
          posting_control_id =
               DECODE(:posting_control_id,
                      :ar_number_dummy, posting_control_id,
                                        :posting_control_id),
          ra_post_loop_number =
               DECODE(:ra_post_loop_number,
                      :ar_number_dummy, ra_post_loop_number,
                                        :ra_post_loop_number),
          complete_flag =
               DECODE(:complete_flag,
                      :ar_flag_dummy, complete_flag,
                                      :complete_flag),
          initial_customer_trx_id =
               DECODE(:initial_customer_trx_id,
                      :ar_number_dummy, initial_customer_trx_id,
                                        :initial_customer_trx_id),
          previous_customer_trx_id =
               DECODE(:previous_customer_trx_id,
                      :ar_number_dummy, previous_customer_trx_id,
                                        :previous_customer_trx_id),
          related_customer_trx_id =
               DECODE(:related_customer_trx_id,
                      :ar_number_dummy, related_customer_trx_id,
                                        :related_customer_trx_id),
          recurred_from_trx_number =
               DECODE(:recurred_from_trx_number,
                      :ar_text_dummy, recurred_from_trx_number,
                                      :recurred_from_trx_number),
          cust_trx_type_id =
               DECODE(:cust_trx_type_id,
                      :ar_number_dummy, cust_trx_type_id,
                                        :cust_trx_type_id),
          batch_id =
               DECODE(:batch_id,
                      :ar_number_dummy, batch_id,
                                        :batch_id),
          batch_source_id =
               DECODE(:batch_source_id,
                      :ar_number_dummy, batch_source_id,
                                        :batch_source_id),
          agreement_id =
               DECODE(:agreement_id,
                      :ar_number_dummy, agreement_id,
                                        :agreement_id),
          trx_date =
               DECODE(:trx_date,
                      :ar_date_dummy, trx_date,
                                      :trx_date),
          bill_to_customer_id =
               DECODE(:bill_to_customer_id,
                      :ar_number_dummy, bill_to_customer_id,
                                        :bill_to_customer_id),
          bill_to_contact_id =
               DECODE(:bill_to_contact_id,
                      :ar_number_dummy, bill_to_contact_id,
                                        :bill_to_contact_id),
          bill_to_site_use_id =
               DECODE(:bill_to_site_use_id,
                      :ar_number_dummy, bill_to_site_use_id,
                                        :bill_to_site_use_id),
          ship_to_customer_id =
               DECODE(:ship_to_customer_id,
                      :ar_number_dummy, ship_to_customer_id,
                                        :ship_to_customer_id),
          ship_to_contact_id =
               DECODE(:ship_to_contact_id,
                      :ar_number_dummy, ship_to_contact_id,
                                        :ship_to_contact_id),
          ship_to_site_use_id =
               DECODE(:ship_to_site_use_id,
                      :ar_number_dummy, ship_to_site_use_id,
                                        :ship_to_site_use_id),
          sold_to_customer_id =
               DECODE(:sold_to_customer_id,
                      :ar_number_dummy, sold_to_customer_id,
                                        :sold_to_customer_id),
          sold_to_site_use_id =
               DECODE(:sold_to_site_use_id,
                      :ar_number_dummy, sold_to_site_use_id,
                                        :sold_to_site_use_id),
          sold_to_contact_id =
               DECODE(:sold_to_contact_id,
                      :ar_number_dummy, sold_to_contact_id,
                                        :sold_to_contact_id),
          customer_reference =
               DECODE(:customer_reference,
                      :ar_text_dummy, customer_reference,
                                      :customer_reference),
          customer_reference_date =
               DECODE(:customer_reference_date,
                      :ar_date_dummy, customer_reference_date,
                                      :customer_reference_date),
          credit_method_for_installments =
               DECODE(:credit_method_for_installments,
                      :ar_text_dummy, credit_method_for_installments,
                                      :credit_method_for_installments),
          credit_method_for_rules =
               DECODE(:credit_method_for_rules,
                      :ar_text_dummy, credit_method_for_rules,
                                      :credit_method_for_rules),
          start_date_commitment =
               DECODE(:start_date_commitment,
                      :ar_date_dummy, start_date_commitment,
                                      :start_date_commitment),
          end_date_commitment =
               DECODE(:end_date_commitment,
                      :ar_date_dummy, end_date_commitment,
                                      :end_date_commitment),
          exchange_date =
               DECODE(:exchange_date,
                      :ar_date_dummy, exchange_date,
                                      :exchange_date),
          exchange_rate =
               DECODE(:exchange_rate,
                      :ar_number_dummy, exchange_rate,
                                        :exchange_rate),
          exchange_rate_type =
               DECODE(:exchange_rate_type,
                      :ar_text_dummy, exchange_rate_type,
                                      :exchange_rate_type),
          customer_bank_account_id =
               DECODE(:customer_bank_account_id,
                      :ar_number_dummy, customer_bank_account_id,
                                        :customer_bank_account_id),
          finance_charges =
               DECODE(:finance_charges,
                      :ar_flag_dummy, finance_charges,
                                      :finance_charges),
          fob_point =
               DECODE(:fob_point,
                      :ar_text_dummy, fob_point,
                                      :fob_point),
          comments =
               DECODE(:comments,
                      :ar_text_dummy, comments,
                                      :comments),
          internal_notes =
               DECODE(:internal_notes,
                      :ar_text_dummy, internal_notes,
                                      :internal_notes),
          invoice_currency_code =
               DECODE(:invoice_currency_code,
                      :ar_text_dummy, invoice_currency_code,
                                      :invoice_currency_code),
          invoicing_rule_id =
               DECODE(:invoicing_rule_id,
                      :ar_number_dummy, invoicing_rule_id,
                                        :invoicing_rule_id),
          last_printed_sequence_num =
               DECODE(:last_printed_sequence_num,
                      :ar_number_dummy, last_printed_sequence_num,
                                        :last_printed_sequence_num),
          orig_system_batch_name =
               DECODE(:orig_system_batch_name,
                      :ar_text_dummy, orig_system_batch_name,
                                      :orig_system_batch_name),
          primary_salesrep_id =
               DECODE(:primary_salesrep_id,
                      :ar_number_dummy, primary_salesrep_id,
                                        :primary_salesrep_id),
          printing_count =
               DECODE(:printing_count,
                      :ar_number_dummy, printing_count,
                                        :printing_count),
          printing_last_printed =
               DECODE(:printing_last_printed,
                      :ar_date_dummy, printing_last_printed,
                                      :printing_last_printed),
          printing_option =
               DECODE(:printing_option,
                      :ar_text_dummy, printing_option,
                                      :printing_option),
          printing_original_date =
               DECODE(:printing_original_date,
                      :ar_date_dummy, printing_original_date,
                                      :printing_original_date),
          printing_pending =
               DECODE(:printing_option,
                        printing_option, printing_pending,
                              DECODE(:printing_option,
                                     ''PRI'', ''Y'',
                                     ''NOT'', ''N'',
                                              DECODE(:printing_pending,
                                                     :ar_flag_dummy,
                                                       printing_pending,
                                                       :printing_pending)
                                     )
                     ),
          purchase_order =
               DECODE(:purchase_order,
                      :ar_text_dummy, purchase_order,
                                      :purchase_order),
          purchase_order_date =
               DECODE(:purchase_order_date,
                      :ar_date_dummy, purchase_order_date,
                                      :purchase_order_date),
          purchase_order_revision =
               DECODE(:purchase_order_revision,
                      :ar_text_dummy, purchase_order_revision,
                                      :purchase_order_revision),
          receipt_method_id =
               DECODE(:receipt_method_id,
                      :ar_number_dummy, receipt_method_id,
                                        :receipt_method_id),
          remit_to_address_id =
               DECODE(:remit_to_address_id,
                      :ar_number_dummy, remit_to_address_id,
                                        :remit_to_address_id),
          shipment_id =
               DECODE(:shipment_id,
                      :ar_number_dummy, shipment_id,
                                        :shipment_id),
          ship_date_actual =
               DECODE(:ship_date_actual,
                      :ar_date_dummy, ship_date_actual,
                                      :ship_date_actual),
          ship_via =
               DECODE(:ship_via,
                      :ar_text_dummy, ship_via,
                                      :ship_via),
          term_due_date =
               DECODE(:term_due_date,
                      :ar_date_dummy, term_due_date,
                                      :term_due_date),
          term_id =
               DECODE(:term_id,
                      :ar_number_dummy, term_id,
                                        :term_id),
          territory_id =
               DECODE(:territory_id,
                      :ar_number_dummy, territory_id,
                                        :territory_id),
          waybill_number =
               DECODE(:waybill_number,
                      :ar_text_dummy, waybill_number,
                                      :waybill_number),
          status_trx =
               DECODE(:status_trx,
                      :ar_text_dummy, status_trx,
                                      :status_trx),
          reason_code =
               DECODE(:reason_code,
                      :ar_text_dummy, reason_code,
                                      :reason_code),
          doc_sequence_id =
               DECODE(:doc_sequence_id,
                      :ar_number_dummy, doc_sequence_id,
                                        :doc_sequence_id),
          doc_sequence_value =
               DECODE(:doc_sequence_value,
                      :ar_number_dummy, doc_sequence_value,
                                        :doc_sequence_value),
          paying_customer_id =
               DECODE(:paying_customer_id,
                      :ar_number_dummy, paying_customer_id,
                                        :paying_customer_id),
          paying_site_use_id =
               DECODE(:paying_site_use_id,
                      :ar_number_dummy, paying_site_use_id,
                                        :paying_site_use_id),
          related_batch_source_id =
               DECODE(:related_batch_source_id,
                      :ar_number_dummy, related_batch_source_id,
                                        :related_batch_source_id),
          default_tax_exempt_flag =
               DECODE(:default_tax_exempt_flag,
                      :ar_flag_dummy, default_tax_exempt_flag,
                                      :default_tax_exempt_flag),
          created_from =
               DECODE(:created_from,
                      :ar_text_dummy, created_from,
                                      :created_from),
          default_ussgl_trx_code_context =
               DECODE(:default_ussgl_trx_code_context,
                      :ar_text_dummy, default_ussgl_trx_code_context,
                                      :default_ussgl_trx_code_context),
          default_ussgl_transaction_code =
               DECODE(:default_ussgl_transaction_code,
                      :ar_text_dummy, default_ussgl_transaction_code,
                                      :default_ussgl_transaction_code),
          old_trx_number =
               DECODE(:old_trx_number,
                      :ar_text_dummy, old_trx_number,
                                      :old_trx_number),
          interface_header_context =
               DECODE(:interface_header_context,
                      :ar_text_dummy, interface_header_context,
                                      :interface_header_context),
          interface_header_attribute1 =
               DECODE(:interface_header_attribute1,
                      :ar_text_dummy, interface_header_attribute1,
                                      :interface_header_attribute1),
          interface_header_attribute2 =
               DECODE(:interface_header_attribute2,
                      :ar_text_dummy, interface_header_attribute2,
                                      :interface_header_attribute2),
          interface_header_attribute3 =
               DECODE(:interface_header_attribute3,
                      :ar_text_dummy, interface_header_attribute3,
                                      :interface_header_attribute3),
          interface_header_attribute4 =
               DECODE(:interface_header_attribute4,
                      :ar_text_dummy, interface_header_attribute4,
                                      :interface_header_attribute4),
          interface_header_attribute5 =
               DECODE(:interface_header_attribute5,
                      :ar_text_dummy, interface_header_attribute5,
                                      :interface_header_attribute5),
          interface_header_attribute6 =
               DECODE(:interface_header_attribute6,
                      :ar_text_dummy, interface_header_attribute6,
                                      :interface_header_attribute6),
          interface_header_attribute7 =
               DECODE(:interface_header_attribute7,
                      :ar_text_dummy, interface_header_attribute7,
                                      :interface_header_attribute7),
          interface_header_attribute8 =
               DECODE(:interface_header_attribute8,
                      :ar_text_dummy, interface_header_attribute8,
                                      :interface_header_attribute8),
          interface_header_attribute9 =
               DECODE(:interface_header_attribute9,
                      :ar_text_dummy, interface_header_attribute9,
                                      :interface_header_attribute9),
          interface_header_attribute10 =
               DECODE(:interface_header_attribute10,
                      :ar_text_dummy, interface_header_attribute10,
                                      :interface_header_attribute10),
          interface_header_attribute11 =
               DECODE(:interface_header_attribute11,
                      :ar_text_dummy, interface_header_attribute11,
                                      :interface_header_attribute11),
          interface_header_attribute12 =
               DECODE(:interface_header_attribute12,
                      :ar_text_dummy, interface_header_attribute12,
                                      :interface_header_attribute12),
          interface_header_attribute13 =
               DECODE(:interface_header_attribute13,
                      :ar_text_dummy, interface_header_attribute13,
                                      :interface_header_attribute13),
          interface_header_attribute14 =
               DECODE(:interface_header_attribute14,
                      :ar_text_dummy, interface_header_attribute14,
                                      :interface_header_attribute14),
          interface_header_attribute15 =
               DECODE(:interface_header_attribute15,
                      :ar_text_dummy, interface_header_attribute15,
                                      :interface_header_attribute15),
          attribute_category =
               DECODE(:attribute_category,
                      :ar_text_dummy, attribute_category,
                                      :attribute_category),
          attribute1 =
               DECODE(:attribute1,
                      :ar_text_dummy, attribute1,
                                      :attribute1),
          attribute2 =
               DECODE(:attribute2,
                      :ar_text_dummy, attribute2,
                                      :attribute2),
          attribute3 =
               DECODE(:attribute3,
                      :ar_text_dummy, attribute3,
                                      :attribute3),
          attribute4 =
               DECODE(:attribute4,
                      :ar_text_dummy, attribute4,
                                      :attribute4),
          attribute5 =
               DECODE(:attribute5,
                      :ar_text_dummy, attribute5,
                                      :attribute5),
          attribute6 =
               DECODE(:attribute6,
                      :ar_text_dummy, attribute6,
                                      :attribute6),
          attribute7 =
               DECODE(:attribute7,
                      :ar_text_dummy, attribute7,
                                      :attribute7),
          attribute8 =
               DECODE(:attribute8,
                      :ar_text_dummy, attribute8,
                                      :attribute8),
          attribute9 =
               DECODE(:attribute9,
                      :ar_text_dummy, attribute9,
                                      :attribute9),
          attribute10 =
               DECODE(:attribute10,
                      :ar_text_dummy, attribute10,
                                      :attribute10),
          attribute11 =
               DECODE(:attribute11,
                      :ar_text_dummy, attribute11,
                                      :attribute11),
          attribute12 =
               DECODE(:attribute12,
                      :ar_text_dummy, attribute12,
                                      :attribute12),
          attribute13 =
               DECODE(:attribute13,
                      :ar_text_dummy, attribute13,
                                      :attribute13),
          attribute14 =
               DECODE(:attribute14,
                      :ar_text_dummy, attribute14,
                                      :attribute14),
          attribute15 =
               DECODE(:attribute15,
                      :ar_text_dummy, attribute15,
                                      :attribute15),
          br_amount =
               DECODE(:br_amount,
                      :ar_number_dummy, br_amount,
                                        :br_amount),
          br_unpaid_flag =
               DECODE(:br_unpaid_flag,
                      :ar_flag_dummy, br_unpaid_flag,
                                      :br_unpaid_flag),
          br_on_hold_flag =
               DECODE(:br_on_hold_flag,
                      :ar_flag_dummy, br_on_hold_flag,
                                      :br_on_hold_flag),
          drawee_id =
               DECODE(:drawee_id,
                      :ar_number_dummy, drawee_id,
                                        :drawee_id),
          drawee_contact_id =
               DECODE(:drawee_contact_id,
                      :ar_number_dummy, drawee_contact_id,
                                        :drawee_contact_id),
          drawee_site_use_id =
               DECODE(:drawee_site_use_id,
                      :ar_number_dummy, drawee_site_use_id,
                                        :drawee_site_use_id),
          drawee_bank_account_id =
               DECODE(:drawee_bank_account_id,
                      :ar_number_dummy, drawee_bank_account_id,
                                        :drawee_bank_account_id),
          remit_bank_acct_use_id =
               DECODE(:remittance_bank_account_id,
                      :ar_number_dummy, remit_bank_acct_use_id,
                                        :remittance_bank_account_id),
          override_remit_account_flag =
               DECODE(:override_remit_account_flag,
                      :ar_flag_dummy, override_remit_account_flag,
                                      :override_remit_account_flag),
          special_instructions =
               DECODE(:special_instructions,
                      :ar_text_dummy, special_instructions,
                                      :special_instructions),
          remittance_batch_id =
               DECODE(:remittance_batch_id,
                      :ar_number_dummy, remittance_batch_id,
                                        :remittance_batch_id) ,
          address_verification_code =
               DECODE(:address_verification_code,
                      :ar_text_dummy,  address_verification_code,
                                      :address_verification_code),
          approval_code =
               DECODE(:approval_code,
                      :ar_text_dummy, approval_code,
                                      :approval_code),
           bill_to_address_id =
               DECODE(:bill_to_address_id,
                      :ar_number_dummy, bill_to_address_id,
                                      :bill_to_address_id),
           edi_processed_flag =
               DECODE(:edi_processed_flag,
                      :ar_flag_dummy, edi_processed_flag,
                                        :edi_processed_flag),
          edi_processed_status =
               DECODE(:edi_processed_status,
                      :ar_text_dummy, edi_processed_status,
                                        :edi_processed_status),
          payment_server_order_num =
               DECODE(:payment_server_order_num,
                      :ar_text_dummy, payment_server_order_num,
                                        :payment_server_order_num),
          post_request_id =
               DECODE(:post_request_id,
                      :ar_number_dummy, post_request_id,
                                      :post_request_id),
          request_id =
               DECODE(:request_id,
                      :ar_number_dummy, request_id,
                                      :request_id),
          ship_to_address_id =
               DECODE(:ship_to_address_id,
                      :ar_number_dummy, ship_to_address_id,
                                      :ship_to_address_id),
         wh_update_date =
               DECODE(:wh_update_date,
                      :ar_date_dummy,wh_update_date,
                                        :wh_update_date),
         legal_entity_id =
               DECODE(:legal_entity_id,
                      :ar_number_dummy, legal_entity_id,
                                      :legal_entity_id) ,
/* PAYMENT_UPTAKE */
         payment_trxn_extension_id =
               DECODE(:payment_trxn_extension_id,
                      :ar_number_dummy, payment_trxn_extension_id,
                                      :payment_trxn_extension_id),
         billing_date =
               DECODE(:billing_date,
                       :ar_date_dummy, billing_date,
                                      :billing_date)';

   arp_util.debug('arp_ct_pkg.construct_trx_update_stmt()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.construct_trx_update_stmt()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_global_attr_stmt                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Copies the text of the dynamic SQL update statement for the            |
 |    global_attribute_category and global_attributes(1-30) into the         |
 |    out NOCOPY paramater. The update statement contains a where clause            |
 |    since this is the dynamic part that is added later.                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    update_text  - text of the update statement	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     22-JUN-02  skoukunt            Created for Bug2427456                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE construct_global_attr_stmt( update_text OUT NOCOPY varchar2) IS
BEGIN
   arp_util.debug('arp_ct_pkg.construct_global_attr_stmt()+');
   update_text := '
         ,global_attribute_category =
               DECODE(:global_attribute_category,
                      :ar_text_dummy, global_attribute_category,
                                      :global_attribute_category),
          global_attribute1 =
               DECODE(:global_attribute1,
                      :ar_text_dummy, global_attribute1,
                                      :global_attribute1),
          global_attribute2 =
               DECODE(:global_attribute2,
                      :ar_text_dummy, global_attribute2,
                                      :global_attribute2),
          global_attribute3 =
               DECODE(:global_attribute3,
                      :ar_text_dummy, global_attribute3,
                                      :global_attribute3),
          global_attribute4 =
               DECODE(:global_attribute4,
                      :ar_text_dummy, global_attribute4,
                                      :global_attribute4),
          global_attribute5 =
               DECODE(:global_attribute5,
                      :ar_text_dummy, global_attribute5,
                                      :global_attribute5),
          global_attribute6 =
               DECODE(:global_attribute6,
                      :ar_text_dummy, global_attribute6,
                                      :global_attribute6),
          global_attribute7 =
               DECODE(:global_attribute7,
                      :ar_text_dummy, global_attribute7,
                                      :global_attribute7),
          global_attribute8 =
               DECODE(:global_attribute8,
                      :ar_text_dummy, global_attribute8,
                                      :global_attribute8),
          global_attribute9 =
               DECODE(:global_attribute9,
                      :ar_text_dummy, global_attribute9,
                                      :global_attribute9),
          global_attribute10 =
               DECODE(:global_attribute10,
                      :ar_text_dummy, global_attribute10,
                                      :global_attribute10),
          global_attribute11 =
               DECODE(:global_attribute11,
                      :ar_text_dummy, global_attribute11,
                                      :global_attribute11),
          global_attribute12 =
               DECODE(:global_attribute12,
                      :ar_text_dummy, global_attribute12,
                                      :global_attribute12),
          global_attribute13 =
               DECODE(:global_attribute13,
                      :ar_text_dummy, global_attribute13,
                                      :global_attribute13),
          global_attribute14 =
               DECODE(:global_attribute14,
                      :ar_text_dummy, global_attribute14,
                                      :global_attribute14),
          global_attribute15 =
               DECODE(:global_attribute15,
                      :ar_text_dummy, global_attribute15,
                                      :global_attribute15),
          global_attribute16 =
               DECODE(:global_attribute16,
                      :ar_text_dummy, global_attribute16,
                                      :global_attribute16),
          global_attribute17 =
               DECODE(:global_attribute17,
                      :ar_text_dummy, global_attribute17,
                                      :global_attribute17),
          global_attribute18 =
               DECODE(:global_attribute18,
                      :ar_text_dummy, global_attribute18,
                                      :global_attribute18),
          global_attribute19 =
               DECODE(:global_attribute19,
                      :ar_text_dummy, global_attribute19,
                                      :global_attribute19),
          global_attribute20 =
               DECODE(:global_attribute20,
                      :ar_text_dummy, global_attribute20,
                                      :global_attribute20),
          global_attribute21 =
               DECODE(:global_attribute21,
                      :ar_text_dummy, global_attribute21,
                                      :global_attribute21),
          global_attribute22 =
               DECODE(:global_attribute22,
                      :ar_text_dummy, global_attribute22,
                                      :global_attribute22),
          global_attribute23 =
               DECODE(:global_attribute23,
                      :ar_text_dummy, global_attribute23,
                                      :global_attribute23),
          global_attribute24 =
               DECODE(:global_attribute24,
                      :ar_text_dummy, global_attribute24,
                                      :global_attribute24),
          global_attribute25 =
               DECODE(:global_attribute25,
                      :ar_text_dummy, global_attribute25,
                                      :global_attribute25),
          global_attribute26 =
               DECODE(:global_attribute26,
                      :ar_text_dummy, global_attribute26,
                                      :global_attribute26),
          global_attribute27 =
               DECODE(:global_attribute27,
                      :ar_text_dummy, global_attribute27,
                                      :global_attribute27),
          global_attribute28 =
               DECODE(:global_attribute28,
                      :ar_text_dummy, global_attribute28,
                                      :global_attribute28),
          global_attribute29 =
               DECODE(:global_attribute29,
                      :ar_text_dummy, global_attribute29,
                                      :global_attribute29),
          global_attribute30 =
               DECODE(:global_attribute30,
                      :ar_text_dummy, global_attribute30,
                                      :global_attribute30)';

   arp_util.debug('arp_ct_pkg.construct_global_attr_stmt()-');
EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.construct_global_attr_stmt()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    generic_update                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure Updates records in ra_customer_trx identified by the    |
 |    where clause that is passed in as a parameter. Only those columns in   |
 |    the trx record parameter that do not contain the special dummy values  |
 |    are updated.                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    dbms_sql.open_cursor 						     |
 |    dbms_sql.parse							     |
 |    dbms_sql.execute							     |
 |    dbms_sql.close_cursor						     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_update_cursor  - identifies the cursor to use 	     |
 |                    p_where_clause   - identifies which rows to update     |
 | 		      p_where1         - value to bind into where clause     |
 |		      p_trx_rec        - contains the new trx values         |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |     08-NOV-01  Debbie Jancis	      Added calls to MRC engine for          |
 |                                    RA_CUSTOMER_TRX processing             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
			 p_where_clause      IN varchar2,
			 p_where1            IN number,
                         p_trx_rec           IN ra_customer_trx%rowtype) IS

   l_count             number;
   l_update_statement_1  varchar2(30000);
   l_update_statement_2  varchar2(30000);
   l_update_statement  long;
   ctrx_array   dbms_sql.number_table;

BEGIN
   arp_util.debug('arp_ct_pkg.generic_update()+');

  /*--------------------------------------------------------------+
   |  If this update statement has not already been parsed, 	  |
   |  construct the statement and parse it.			  |
   |  Otherwise, use the already parsed statement and rebind its  |
   |  variables.						  |
   +--------------------------------------------------------------*/

   IF (p_update_cursor is null)
   THEN

         p_update_cursor := dbms_sql.open_cursor;

         /*---------------------------------+
          |  Construct the update statement |
          +---------------------------------*/

         arp_ct_pkg.construct_trx_update_stmt(l_update_statement_1);
         arp_ct_pkg.construct_global_attr_stmt(l_update_statement_2);

         l_update_statement := l_update_statement_1 || l_update_statement_2;

         l_update_statement := l_update_statement || p_where_clause;

         /*---------------------------------------+
          | add on mrc variables for bulk collect |
          +---------------------------------------*/

         l_update_statement := l_update_statement ||
             ' RETURNING customer_trx_id INTO :ctrx_key_value ';

         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/

         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);

   END IF;

   arp_ct_pkg.bind_trx_variables(p_update_cursor, p_trx_rec);

  /*----------------------------+
   | Bind output variable       |
   +----------------------------*/

   dbms_sql.bind_array(p_update_cursor, ':ctrx_key_value',
                        ctrx_array);

  /*-----------------------------------------+
   |  Bind the variables in the where clause |
   +-----------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':where_1',
                          p_where1);

   l_count := dbms_sql.execute(p_update_cursor);

   arp_util.debug( to_char(l_count) || ' rows updated');

   /*------------------------------------------+
    | get RETURNING COLUMN into OUT NOCOPY bind array |
    +------------------------------------------*/

    dbms_sql.variable_value( p_update_cursor, ':ctrx_key_value', ctrx_array);


   /*------------------------------------------------------------+
    |  Raise the NO_DATA_FOUND exception if no rows were updated |
    +------------------------------------------------------------*/

   IF  (l_count = 0)
   THEN RAISE NO_DATA_FOUND;
   END IF;

--{BUG4301323
--   FOR I in ctrx_array.FIRST..ctrx_array.LAST LOOP
       /*------------------------------------------------+
        | call mrc engine to update RA_MC_CUSTOMER_TRX   |
        +------------------------------------------------*/
--       ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode       => 'UPDATE',
--                        p_table_name       => 'RA_CUSTOMER_TRX',
--                        p_mode             => 'SINGLE',
--                        p_key_value        => ctrx_array(I));
--   END LOOP;



   arp_util.debug('arp_ct_pkg.generic_update()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.generic_update()');
        arp_util.debug(l_update_statement);
        arp_util.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                         	     |
 |    set_to_dummy						     	     |
 |                                                                     	     |
 | DESCRIPTION                                                         	     |
 |    This procedure initializes all columns in the parameter trx record     |
 |    to the appropriate dummy value for its datatype.			     |
 |    									     |
 |    The dummy values are defined in the following package level constants: |
 |	AR_TEXT_DUMMY 							     |
 |	AR_FLAG_DUMMY							     |
 |	AR_NUMBER_DUMMY							     |
 |	AR_DATE_DUMMY							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    p_trx_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              BR_AMOUNT, BR_UNPAID_FLAG,BR_ON_HOLD_FLAG,   |
 |                              DRAWEE_ID, DRAWEE_CONTACT_ID,                |
 |                              DRAWEE_SITE_USE_ID,DRAWEE_BANK_ACCOUNT_ID,   |
 |                              REMITTANCE_BANK_ACCOUNT_ID,		     |
 |                              OVERRIDE_REMIT_ACCOUNT_FLAG and              |
 |                              SPECIAL_INSTRUCTIONSinto table handlers      |
 | 24-JUL-2000  J Rautiainen    Added BR project related column              |
 |                              REMITTANCE_BATCH_ID		             |
 |            								     |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns                  |
 |                              address_verification_code and	             |
 |				approval_code	and                          |
 |				bill_to_address_id and			     |
 |				edi_processed_flag and			     |
 |				edi_processed_status and		     |
 |				payment_server_order_num and		     |
 |				post_request_id and			     |
 |				request_id and				     |
 |				ship_to_address_id			     |
 |				wh_update_date				     |
 | 				into the table handlers.  	             |
 | 20-Jun-2002 Sahana           Bug2427456 : Added Global Attribute Columns  |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_trx_rec OUT NOCOPY ra_customer_trx%rowtype) IS

BEGIN

    arp_util.debug('arp_ct_pkg.set_to_dummy()+');

    p_trx_rec.customer_trx_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.trx_number := 			AR_TEXT_DUMMY;
    p_trx_rec.created_by := 			AR_NUMBER_DUMMY;
    p_trx_rec.creation_date := 			AR_DATE_DUMMY;
    p_trx_rec.last_updated_by := 		AR_NUMBER_DUMMY;
    p_trx_rec.last_update_date := 		AR_DATE_DUMMY;
    p_trx_rec.last_update_login := 		AR_NUMBER_DUMMY;
    p_trx_rec.set_of_books_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.program_application_id := 	AR_NUMBER_DUMMY;
    p_trx_rec.program_id := 			AR_NUMBER_DUMMY;
    p_trx_rec.program_update_date := 		AR_DATE_DUMMY;
    p_trx_rec.posting_control_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.ra_post_loop_number :=	 	AR_NUMBER_DUMMY;
    p_trx_rec.complete_flag :=	 		AR_FLAG_DUMMY;
    p_trx_rec.initial_customer_trx_id := 	AR_NUMBER_DUMMY;
    p_trx_rec.previous_customer_trx_id := 	AR_NUMBER_DUMMY;
    p_trx_rec.related_customer_trx_id := 	AR_NUMBER_DUMMY;
    p_trx_rec.recurred_from_trx_number :=	AR_TEXT_DUMMY;
    p_trx_rec.cust_trx_type_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.batch_id := 			AR_NUMBER_DUMMY;
    p_trx_rec.batch_source_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.agreement_id := 			AR_NUMBER_DUMMY;
    p_trx_rec.trx_date := 			AR_DATE_DUMMY;
    p_trx_rec.bill_to_customer_id :=		AR_NUMBER_DUMMY;
    p_trx_rec.bill_to_contact_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.bill_to_site_use_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.ship_to_customer_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.ship_to_contact_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.ship_to_site_use_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.sold_to_customer_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.sold_to_site_use_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.sold_to_contact_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.customer_reference := 		AR_TEXT_DUMMY;
    p_trx_rec.customer_reference_date := 	AR_DATE_DUMMY;
    p_trx_rec.credit_method_for_installments := AR_TEXT_DUMMY;
    p_trx_rec.credit_method_for_rules := 	AR_TEXT_DUMMY;
    p_trx_rec.start_date_commitment := 		AR_DATE_DUMMY;
    p_trx_rec.end_date_commitment := 		AR_DATE_DUMMY;
    p_trx_rec.exchange_date := 			AR_DATE_DUMMY;
    p_trx_rec.exchange_rate := 			AR_NUMBER_DUMMY;
    p_trx_rec.exchange_rate_type := 		AR_TEXT_DUMMY;
    p_trx_rec.customer_bank_account_id := 	AR_NUMBER_DUMMY;
    p_trx_rec.finance_charges := 		AR_FLAG_DUMMY;
    p_trx_rec.fob_point := 			AR_TEXT_DUMMY;
    p_trx_rec.comments :=	 		AR_TEXT_DUMMY;
    p_trx_rec.internal_notes := 		AR_TEXT_DUMMY;
    p_trx_rec.invoice_currency_code := 		AR_TEXT_DUMMY;
    p_trx_rec.invoicing_rule_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.last_printed_sequence_num := 	AR_NUMBER_DUMMY;
    p_trx_rec.orig_system_batch_name := 	AR_TEXT_DUMMY;
    p_trx_rec.primary_salesrep_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.printing_count := 		AR_NUMBER_DUMMY;
    p_trx_rec.printing_last_printed := 		AR_DATE_DUMMY;
    p_trx_rec.printing_option := 		AR_TEXT_DUMMY;
    p_trx_rec.printing_original_date := 	AR_DATE_DUMMY;
    p_trx_rec.printing_pending := 		AR_FLAG_DUMMY;
    p_trx_rec.purchase_order := 		AR_TEXT_DUMMY;
    p_trx_rec.purchase_order_date := 		AR_DATE_DUMMY;
    p_trx_rec.purchase_order_revision := 	AR_TEXT_DUMMY;
    p_trx_rec.receipt_method_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.remit_to_address_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.shipment_id := 			AR_NUMBER_DUMMY;
    p_trx_rec.ship_date_actual := 		AR_DATE_DUMMY;
    p_trx_rec.ship_via := 			AR_TEXT_DUMMY;
    p_trx_rec.term_due_date := 			AR_DATE_DUMMY;
    p_trx_rec.term_id := 			AR_NUMBER_DUMMY;
    p_trx_rec.territory_id := 			AR_NUMBER_DUMMY;
    p_trx_rec.waybill_number := 		AR_TEXT_DUMMY;
    p_trx_rec.status_trx := 			AR_TEXT_DUMMY;
    p_trx_rec.reason_code := 			AR_TEXT_DUMMY;
    p_trx_rec.doc_sequence_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.doc_sequence_value := 		AR_NUMBER_DUMMY;
    p_trx_rec.paying_customer_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.paying_site_use_id := 		AR_NUMBER_DUMMY;
    p_trx_rec.related_batch_source_id := 	AR_NUMBER_DUMMY;
    p_trx_rec.default_tax_exempt_flag := 	AR_FLAG_DUMMY;
    p_trx_rec.created_from := 			AR_TEXT_DUMMY;
    p_trx_rec.default_ussgl_trx_code_context := AR_TEXT_DUMMY;
    p_trx_rec.default_ussgl_transaction_code := AR_TEXT_DUMMY;
    p_trx_rec.old_trx_number :=                 AR_TEXT_DUMMY;
    p_trx_rec.interface_header_context := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute1 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute2 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute3 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute4 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute5 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute6 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute7 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute8 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute9 := 	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute10 :=	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute11 :=	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute12 :=	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute13 :=	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute14 :=	AR_TEXT_DUMMY;
    p_trx_rec.interface_header_attribute15 :=	AR_TEXT_DUMMY;
    p_trx_rec.attribute_category := 		AR_TEXT_DUMMY;
    p_trx_rec.attribute1 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute2 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute3 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute4 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute5 :=	 		AR_TEXT_DUMMY;
    p_trx_rec.attribute6 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute7 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute8 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute9 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute10 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute11 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute12 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute13 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute14 := 			AR_TEXT_DUMMY;
    p_trx_rec.attribute15 := 			AR_TEXT_DUMMY;

    p_trx_rec.br_amount                      := AR_NUMBER_DUMMY;
    p_trx_rec.br_unpaid_flag                 := AR_FLAG_DUMMY;
    p_trx_rec.br_on_hold_flag                := AR_FLAG_DUMMY;
    p_trx_rec.drawee_id                      := AR_NUMBER_DUMMY;
    p_trx_rec.drawee_contact_id              := AR_NUMBER_DUMMY;
    p_trx_rec.drawee_site_use_id             := AR_NUMBER_DUMMY;
    p_trx_rec.drawee_bank_account_id         := AR_NUMBER_DUMMY;
    p_trx_rec.remit_bank_acct_use_id         := AR_NUMBER_DUMMY;
    p_trx_rec.override_remit_account_flag    := AR_FLAG_DUMMY;
    p_trx_rec.special_instructions           := AR_TEXT_DUMMY;
    p_trx_rec.remittance_batch_id            := AR_NUMBER_DUMMY;
    p_trx_rec.address_verification_code      := AR_TEXT_DUMMY;
    p_trx_rec.approval_code                  := AR_TEXT_DUMMY;
    p_trx_rec.bill_to_address_id             := AR_NUMBER_DUMMY;
    p_trx_rec.edi_processed_flag             := AR_FLAG_DUMMY;
    p_trx_rec.edi_processed_status           := AR_TEXT_DUMMY;
    p_trx_rec.payment_server_order_num       := AR_TEXT_DUMMY;
    p_trx_rec.post_request_id		     := AR_NUMBER_DUMMY;
    p_trx_rec.request_id		     := AR_NUMBER_DUMMY;
    p_trx_rec.ship_to_address_id             := AR_NUMBER_DUMMY;
    p_trx_rec.wh_update_date           	     := AR_DATE_DUMMY;

    p_trx_rec.global_attribute_category :=      AR_TEXT_DUMMY;
    p_trx_rec.global_attribute1 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute2 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute3 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute4 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute5 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute6 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute7 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute8 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute9 :=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute10 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute11 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute12 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute13 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute14 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute15 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute16 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute17 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute18 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute19 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute20 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute21 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute22 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute23 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute24 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute25 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute26:=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute27:=              AR_TEXT_DUMMY;
    p_trx_rec.global_attribute28 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute29 :=             AR_TEXT_DUMMY;
    p_trx_rec.global_attribute30 :=             AR_TEXT_DUMMY;

    p_trx_rec.legal_entity_id :=                AR_NUMBER_DUMMY;
    /* PAYMENT_UPTAKE */
    p_trx_rec.payment_trxn_extension_id :=      AR_NUMBER_DUMMY;
    p_trx_rec.billing_date :=                   AR_DATE_DUMMY;

    arp_util.debug('arp_ct_pkg.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.set_to_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_customer_trx row identified by the 	     |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the row to lock	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type )
          IS

    l_customer_trx_id  ra_customer_trx.customer_trx_id%type;

BEGIN
    arp_util.debug('arp_ct_pkg.lock_p()+');


    SELECT customer_trx_id
    INTO   l_customer_trx_id
    FROM   ra_customer_trx
    WHERE  customer_trx_id = p_customer_trx_id
    FOR UPDATE OF customer_trx_id NOWAIT;

    arp_util.debug('arp_ct_pkg.lock_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_ct_pkg.lock_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_customer_trx row identified by the 	     |
 |    p_ra_customer_trx parameter and populates the p_trx_rec parameter with |
 |    the row that was locked.						     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the row to lock	     |
 |              OUT:                                                         |
 |                    p_trx_rec	- contains the locked row		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_trx_rec         IN OUT NOCOPY ra_customer_trx%rowtype,
                        p_customer_trx_id IN
                                     ra_customer_trx.customer_trx_id%type ) IS

BEGIN
    arp_util.debug('arp_ct_pkg.lock_fetch_p()+');

    SELECT        *
    INTO          p_trx_rec
    FROM          ra_customer_trx
    WHERE         customer_trx_id = p_customer_trx_id
    FOR UPDATE OF customer_trx_id NOWAIT;

    arp_util.debug('arp_ct_pkg.lock_fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_ct_pkg.lock_fetch_p' );
            RAISE;
END;

/*============================================================================+
 | PROCEDURE                                                                  |
 |    lock_compare_p							      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure locks the ra_customer_trx row identified by the 	      |
 |    p_customer_trx_id parameter only if no columns in that row have 	      |
 |    changed from when they were first selected in the form.		      |
 |                                                                            |
 | SCOPE - PUBLIC                                                             |
 |                                                                            |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    arp_util.debug                                                          |
 |                                                                            |
 | ARGUMENTS  : IN:                                                           |
 |                    p_customer_trx_id	- identifies the row to lock	      |
 | 		      p_trx_rec    	- trx record for comparison	      |
 |              OUT:                                                          |
 |                    None						      |
 |                                                                            |
 | RETURNS    : NONE                                                          |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 | 07-JUN-95    Charlie Tomberg Created                                       |
 | 29-JUN-95    Charlie Tomberg Modified to use select for update             |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns              |
 |                              BR_AMOUNT, BR_UNPAID_FLAG,BR_ON_HOLD_FLAG,    |
 |                              DRAWEE_ID, DRAWEE_CONTACT_ID,                 |
 |                              DRAWEE_SITE_USE_ID   		              |
 |                              DRAWEE_BANK_ACCOUNT_ID,                       |
 |                              REMITTANCE_BANK_ACCOUNT_ID,		      |
 |                              OVERRIDE_REMIT_ACCOUNT_FLAG and               |
 |                              SPECIAL_INSTRUCTIONSinto table handlers       |
 | 24-JUL-2000  J Rautiainen    Added BR project related column               |
 |                              REMITTANCE_BATCH_ID		              |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns                   |
 |                              address_verification_code and	              |
 |				approval_code	and			      |
 |				bill_to_address_id and			      |
 |				edi_processed_flag and			      |
 |				edi_processed_status and		      |
 |				payment_server_order_num and		      |
 |				post_request_id and			      |
 |				request_id and				      |
 |				ship_to_address_id			      |
 |				wh_update_date				      |
 | 				into the table handlers.  		      |
 |                                                                            |
 | 20-Jun-2002  Sahana          Bug2427456: Added global attribute columns    |
 | 18-May-2005  Debbie Jancis   Added Legal entity Id for LE project          |
 | 09-Aug-2005  Surendra Rajan  Added payment_trxn_extension_id               |
 +============================================================================*/

PROCEDURE lock_compare_p( p_trx_rec          IN ra_customer_trx%rowtype,
                          p_customer_trx_id  IN
                                     ra_customer_trx.customer_trx_id%type) IS

    l_new_trx_rec  ra_customer_trx%rowtype;

BEGIN
    arp_util.debug('arp_ct_pkg.lock_compare_p()+');

    SELECT   *
    INTO     l_new_trx_rec
    FROM     ra_customer_trx trx
    WHERE    trx.customer_trx_id = p_customer_trx_id
    AND
       (
           NVL(trx.trx_number, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.trx_number,
                        AR_TEXT_DUMMY, trx.trx_number,
                                       p_trx_rec.trx_number),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.customer_trx_id,
                        AR_NUMBER_DUMMY, trx.customer_trx_id,
                                       p_trx_rec.customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.created_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.created_by,
                        AR_NUMBER_DUMMY, trx.created_by,
                                       p_trx_rec.created_by),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(trx.creation_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.creation_date),
                        AR_DATE_DUMMY, TRUNC(trx.creation_date),
                                       TRUNC(p_trx_rec.creation_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.last_updated_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.last_updated_by,
                        AR_NUMBER_DUMMY, trx.last_updated_by,
                                       p_trx_rec.last_updated_by),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(trx.last_update_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.last_update_date),
                        AR_DATE_DUMMY, TRUNC(trx.last_update_date),
                                       TRUNC(p_trx_rec.last_update_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.last_update_login, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.last_update_login,
                        AR_NUMBER_DUMMY, trx.last_update_login,
                                       p_trx_rec.last_update_login),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.set_of_books_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.set_of_books_id,
                        AR_NUMBER_DUMMY, trx.set_of_books_id,
                                       p_trx_rec.set_of_books_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.program_application_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.program_application_id,
                        AR_NUMBER_DUMMY, trx.program_application_id,
                                       p_trx_rec.program_application_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.program_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.program_id,
                        AR_NUMBER_DUMMY, trx.program_id,
                                       p_trx_rec.program_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(trx.program_update_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.program_update_date),
                        AR_DATE_DUMMY, TRUNC(trx.program_update_date),
                                       TRUNC(p_trx_rec.program_update_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.posting_control_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.posting_control_id,
                        AR_NUMBER_DUMMY, trx.posting_control_id,
                                       p_trx_rec.posting_control_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.ra_post_loop_number, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.ra_post_loop_number,
                        AR_NUMBER_DUMMY, trx.ra_post_loop_number,
                                       p_trx_rec.ra_post_loop_number),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.complete_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.complete_flag,
                        AR_FLAG_DUMMY, trx.complete_flag,
                                       p_trx_rec.complete_flag),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(trx.initial_customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.initial_customer_trx_id,
                        AR_NUMBER_DUMMY, trx.initial_customer_trx_id,
                                       p_trx_rec.initial_customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.previous_customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.previous_customer_trx_id,
                        AR_NUMBER_DUMMY, trx.previous_customer_trx_id,
                                       p_trx_rec.previous_customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.related_customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.related_customer_trx_id,
                        AR_NUMBER_DUMMY, trx.related_customer_trx_id,
                                       p_trx_rec.related_customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.recurred_from_trx_number, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.recurred_from_trx_number,
                        AR_TEXT_DUMMY, trx.recurred_from_trx_number,
                                       p_trx_rec.recurred_from_trx_number),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.cust_trx_type_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.cust_trx_type_id,
                        AR_NUMBER_DUMMY, trx.cust_trx_type_id,
                                       p_trx_rec.cust_trx_type_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.batch_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.batch_id,
                        AR_NUMBER_DUMMY, trx.batch_id,
                                       p_trx_rec.batch_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.batch_source_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.batch_source_id,
                        AR_NUMBER_DUMMY, trx.batch_source_id,
                                       p_trx_rec.batch_source_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.agreement_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.agreement_id,
                        AR_NUMBER_DUMMY, trx.agreement_id,
                                       p_trx_rec.agreement_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(trx.trx_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.trx_date),
                        AR_DATE_DUMMY, TRUNC(trx.trx_date),
                                       TRUNC(p_trx_rec.trx_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.bill_to_customer_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.bill_to_customer_id,
                        AR_NUMBER_DUMMY, trx.bill_to_customer_id,
                                       p_trx_rec.bill_to_customer_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.bill_to_contact_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.bill_to_contact_id,
                        AR_NUMBER_DUMMY, trx.bill_to_contact_id,
                                       p_trx_rec.bill_to_contact_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.bill_to_site_use_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.bill_to_site_use_id,
                        AR_NUMBER_DUMMY, trx.bill_to_site_use_id,
                                       p_trx_rec.bill_to_site_use_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.ship_to_customer_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.ship_to_customer_id,
                        AR_NUMBER_DUMMY, trx.ship_to_customer_id,
                                       p_trx_rec.ship_to_customer_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.ship_to_contact_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.ship_to_contact_id,
                        AR_NUMBER_DUMMY, trx.ship_to_contact_id,
                                       p_trx_rec.ship_to_contact_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.ship_to_site_use_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.ship_to_site_use_id,
                        AR_NUMBER_DUMMY, trx.ship_to_site_use_id,
                                       p_trx_rec.ship_to_site_use_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.sold_to_customer_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.sold_to_customer_id,
                        AR_NUMBER_DUMMY, trx.sold_to_customer_id,
                                       p_trx_rec.sold_to_customer_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.sold_to_site_use_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.sold_to_site_use_id,
                        AR_NUMBER_DUMMY, trx.sold_to_site_use_id,
                                       p_trx_rec.sold_to_site_use_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.sold_to_contact_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.sold_to_contact_id,
                        AR_NUMBER_DUMMY, trx.sold_to_contact_id,
                                       p_trx_rec.sold_to_contact_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.customer_reference, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.customer_reference,
                        AR_TEXT_DUMMY, trx.customer_reference,
                                       p_trx_rec.customer_reference),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(TRUNC(trx.customer_reference_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.customer_reference_date),
                        AR_DATE_DUMMY, TRUNC(trx.customer_reference_date),
                                     TRUNC(p_trx_rec.customer_reference_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.credit_method_for_installments, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.credit_method_for_installments,
                        AR_TEXT_DUMMY, trx.credit_method_for_installments,
                                     p_trx_rec.credit_method_for_installments),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.credit_method_for_rules, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.credit_method_for_rules,
                        AR_TEXT_DUMMY, trx.credit_method_for_rules,
                                       p_trx_rec.credit_method_for_rules),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(TRUNC(trx.start_date_commitment), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.start_date_commitment),
                        AR_DATE_DUMMY, TRUNC(trx.start_date_commitment),
                                       TRUNC(p_trx_rec.start_date_commitment)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(TRUNC(trx.end_date_commitment), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.end_date_commitment),
                        AR_DATE_DUMMY, TRUNC(trx.end_date_commitment),
                                       TRUNC(p_trx_rec.end_date_commitment)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(TRUNC(trx.exchange_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.exchange_date),
                        AR_DATE_DUMMY, TRUNC(trx.exchange_date),
                                       TRUNC(p_trx_rec.exchange_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.exchange_rate, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.exchange_rate,
                        AR_NUMBER_DUMMY, trx.exchange_rate,
                                       p_trx_rec.exchange_rate),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.exchange_rate_type, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.exchange_rate_type,
                        AR_TEXT_DUMMY, trx.exchange_rate_type,
                                       p_trx_rec.exchange_rate_type),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.customer_bank_account_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.customer_bank_account_id,
                        AR_NUMBER_DUMMY, trx.customer_bank_account_id,
                                       p_trx_rec.customer_bank_account_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.finance_charges, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.finance_charges,
                        AR_FLAG_DUMMY, trx.finance_charges,
                                       p_trx_rec.finance_charges),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(trx.fob_point, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.fob_point,
                        AR_TEXT_DUMMY, trx.fob_point,
                                       p_trx_rec.fob_point),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.comments, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.comments,
                        AR_TEXT_DUMMY, trx.comments,
                                       p_trx_rec.comments),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.internal_notes, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.internal_notes,
                        AR_TEXT_DUMMY, trx.internal_notes,
                                       p_trx_rec.internal_notes),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.invoice_currency_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.invoice_currency_code,
                        AR_TEXT_DUMMY, trx.invoice_currency_code,
                                       p_trx_rec.invoice_currency_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.invoicing_rule_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.invoicing_rule_id,
                        AR_NUMBER_DUMMY, trx.invoicing_rule_id,
                                       p_trx_rec.invoicing_rule_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.last_printed_sequence_num, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.last_printed_sequence_num,
                        AR_NUMBER_DUMMY, trx.last_printed_sequence_num,
                                       p_trx_rec.last_printed_sequence_num),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.orig_system_batch_name, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.orig_system_batch_name,
                        AR_TEXT_DUMMY, trx.orig_system_batch_name,
                                       p_trx_rec.orig_system_batch_name),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.primary_salesrep_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.primary_salesrep_id,
                        AR_NUMBER_DUMMY, trx.primary_salesrep_id,
                                       p_trx_rec.primary_salesrep_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.printing_count, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.printing_count,
                        AR_NUMBER_DUMMY, trx.printing_count,
                                       p_trx_rec.printing_count),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(trx.printing_last_printed), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.printing_last_printed),
                        AR_DATE_DUMMY, TRUNC(trx.printing_last_printed),
                                       TRUNC(p_trx_rec.printing_last_printed)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.printing_option, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.printing_option,
                        AR_TEXT_DUMMY, trx.printing_option,
                                       p_trx_rec.printing_option),
                 AR_TEXT_DUMMY
              )
       )
     AND
       (
           NVL(TRUNC(trx.printing_original_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.printing_original_date),
                        AR_DATE_DUMMY, TRUNC(trx.printing_original_date),
                                       TRUNC(p_trx_rec.printing_original_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.printing_pending, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.printing_pending,
                        AR_FLAG_DUMMY, trx.printing_pending,
                                       p_trx_rec.printing_pending),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(trx.purchase_order, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.purchase_order,
                        AR_TEXT_DUMMY, trx.purchase_order,
                                       p_trx_rec.purchase_order),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(TRUNC(trx.purchase_order_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.purchase_order_date),
                        AR_DATE_DUMMY, TRUNC(trx.purchase_order_date),
                                       TRUNC(p_trx_rec.purchase_order_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.purchase_order_revision, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.purchase_order_revision,
                        AR_TEXT_DUMMY, trx.purchase_order_revision,
                                       p_trx_rec.purchase_order_revision),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.receipt_method_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.receipt_method_id,
                        AR_NUMBER_DUMMY, trx.receipt_method_id,
                                       p_trx_rec.receipt_method_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.remit_to_address_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.remit_to_address_id,
                        AR_NUMBER_DUMMY, trx.remit_to_address_id,
                                       p_trx_rec.remit_to_address_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.shipment_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.shipment_id,
                        AR_NUMBER_DUMMY, trx.shipment_id,
                                       p_trx_rec.shipment_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(trx.ship_date_actual), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.ship_date_actual),
                        AR_DATE_DUMMY, TRUNC(trx.ship_date_actual),
                                       TRUNC(p_trx_rec.ship_date_actual)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.ship_via, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.ship_via,
                        AR_TEXT_DUMMY, trx.ship_via,
                                       p_trx_rec.ship_via),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(TRUNC(trx.term_due_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_trx_rec.term_due_date),
                        AR_DATE_DUMMY, TRUNC(trx.term_due_date),
                                       TRUNC(p_trx_rec.term_due_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.term_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.term_id,
                        AR_NUMBER_DUMMY, trx.term_id,
                                       p_trx_rec.term_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.territory_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.territory_id,
                        AR_NUMBER_DUMMY, trx.territory_id,
                                       p_trx_rec.territory_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.waybill_number, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.waybill_number,
                        AR_TEXT_DUMMY, trx.waybill_number,
                                       p_trx_rec.waybill_number),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.status_trx, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.status_trx,
                        AR_TEXT_DUMMY, trx.status_trx,
                                       p_trx_rec.status_trx),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.reason_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.reason_code,
                        AR_TEXT_DUMMY, trx.reason_code,
                                       p_trx_rec.reason_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.doc_sequence_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.doc_sequence_id,
                        AR_NUMBER_DUMMY, trx.doc_sequence_id,
                                       p_trx_rec.doc_sequence_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.doc_sequence_value, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.doc_sequence_value,
                        AR_NUMBER_DUMMY, trx.doc_sequence_value,
                                       p_trx_rec.doc_sequence_value),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.paying_customer_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.paying_customer_id,
                        AR_NUMBER_DUMMY, trx.paying_customer_id,
                                       p_trx_rec.paying_customer_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.paying_site_use_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.paying_site_use_id,
                        AR_NUMBER_DUMMY, trx.paying_site_use_id,
                                       p_trx_rec.paying_site_use_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.related_batch_source_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.related_batch_source_id,
                        AR_NUMBER_DUMMY, trx.related_batch_source_id,
                                       p_trx_rec.related_batch_source_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.default_tax_exempt_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.default_tax_exempt_flag,
                        AR_FLAG_DUMMY, trx.default_tax_exempt_flag,
                                       p_trx_rec.default_tax_exempt_flag),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(trx.created_from, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.created_from,
                        AR_TEXT_DUMMY, trx.created_from,
                                       p_trx_rec.created_from),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.default_ussgl_trx_code_context, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.default_ussgl_trx_code_context,
                        AR_TEXT_DUMMY, trx.default_ussgl_trx_code_context,
                                     p_trx_rec.default_ussgl_trx_code_context),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.default_ussgl_transaction_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.default_ussgl_transaction_code,
                        AR_TEXT_DUMMY, trx.default_ussgl_transaction_code,
                                     p_trx_rec.default_ussgl_transaction_code),
                 AR_TEXT_DUMMY
              )
	AND
           NVL(trx.old_trx_number, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.old_trx_number,
                        AR_TEXT_DUMMY, trx.old_trx_number,
                                       p_trx_rec.old_trx_number),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_context, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_context,
                        AR_TEXT_DUMMY, trx.interface_header_context,
                                       p_trx_rec.interface_header_context),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute1,
                        AR_TEXT_DUMMY, trx.interface_header_attribute1,
                                       p_trx_rec.interface_header_attribute1),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute2,
                        AR_TEXT_DUMMY, trx.interface_header_attribute2,
                                       p_trx_rec.interface_header_attribute2),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute3,
                        AR_TEXT_DUMMY, trx.interface_header_attribute3,
                                       p_trx_rec.interface_header_attribute3),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute4,
                        AR_TEXT_DUMMY, trx.interface_header_attribute4,
                                       p_trx_rec.interface_header_attribute4),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute5,
                        AR_TEXT_DUMMY, trx.interface_header_attribute5,
                                       p_trx_rec.interface_header_attribute5),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute6,
                        AR_TEXT_DUMMY, trx.interface_header_attribute6,
                                       p_trx_rec.interface_header_attribute6),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute7,
                        AR_TEXT_DUMMY, trx.interface_header_attribute7,
                                       p_trx_rec.interface_header_attribute7),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute8,
                        AR_TEXT_DUMMY, trx.interface_header_attribute8,
                                       p_trx_rec.interface_header_attribute8),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute9,
                        AR_TEXT_DUMMY, trx.interface_header_attribute9,
                                       p_trx_rec.interface_header_attribute9),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute10,
                        AR_TEXT_DUMMY, trx.interface_header_attribute10,
                                       p_trx_rec.interface_header_attribute10),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute11,
                        AR_TEXT_DUMMY, trx.interface_header_attribute11,
                                       p_trx_rec.interface_header_attribute11),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute12,
                        AR_TEXT_DUMMY, trx.interface_header_attribute12,
                                       p_trx_rec.interface_header_attribute12),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute13,
                        AR_TEXT_DUMMY, trx.interface_header_attribute13,
                                       p_trx_rec.interface_header_attribute13),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute14,
                        AR_TEXT_DUMMY, trx.interface_header_attribute14,
                                       p_trx_rec.interface_header_attribute14),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.interface_header_attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.interface_header_attribute15,
                        AR_TEXT_DUMMY, trx.interface_header_attribute15,
                                       p_trx_rec.interface_header_attribute15),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute_category, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute_category,
                        AR_TEXT_DUMMY, trx.attribute_category,
                                       p_trx_rec.attribute_category),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute1,
                        AR_TEXT_DUMMY, trx.attribute1,
                                       p_trx_rec.attribute1),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute2,
                        AR_TEXT_DUMMY, trx.attribute2,
                                       p_trx_rec.attribute2),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute3,
                        AR_TEXT_DUMMY, trx.attribute3,
                                       p_trx_rec.attribute3),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute4,
                        AR_TEXT_DUMMY, trx.attribute4,
                                       p_trx_rec.attribute4),
                 AR_TEXT_DUMMY
              )
       )
     AND
       (
           NVL(trx.attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute5,
                        AR_TEXT_DUMMY, trx.attribute5,
                                       p_trx_rec.attribute5),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute6,
                        AR_TEXT_DUMMY, trx.attribute6,
                                       p_trx_rec.attribute6),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute7,
                        AR_TEXT_DUMMY, trx.attribute7,
                                       p_trx_rec.attribute7),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute8,
                        AR_TEXT_DUMMY, trx.attribute8,
                                       p_trx_rec.attribute8),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute9,
                        AR_TEXT_DUMMY, trx.attribute9,
                                       p_trx_rec.attribute9),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute10,
                        AR_TEXT_DUMMY, trx.attribute10,
                                       p_trx_rec.attribute10),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute11,
                        AR_TEXT_DUMMY, trx.attribute11,
                                       p_trx_rec.attribute11),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute12,
                        AR_TEXT_DUMMY, trx.attribute12,
                                       p_trx_rec.attribute12),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute13,
                        AR_TEXT_DUMMY, trx.attribute13,
                                       p_trx_rec.attribute13),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute14,
                        AR_TEXT_DUMMY, trx.attribute14,
                                       p_trx_rec.attribute14),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.attribute15,
                        AR_TEXT_DUMMY, trx.attribute15,
                                       p_trx_rec.attribute15),
                 AR_TEXT_DUMMY
              )

         AND
           NVL(trx.br_amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.br_amount,
                        AR_NUMBER_DUMMY, trx.br_amount,
                                         p_trx_rec.br_amount),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.br_unpaid_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.br_unpaid_flag,
                        AR_FLAG_DUMMY, trx.br_unpaid_flag,
                                         p_trx_rec.br_unpaid_flag),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(trx.br_on_hold_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.br_on_hold_flag,
                        AR_FLAG_DUMMY, trx.br_on_hold_flag,
                                         p_trx_rec.br_on_hold_flag),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(trx.drawee_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.drawee_id,
                        AR_NUMBER_DUMMY, trx.drawee_id,
                                         p_trx_rec.drawee_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.drawee_contact_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.drawee_contact_id,
                        AR_NUMBER_DUMMY, trx.drawee_contact_id,
                                         p_trx_rec.drawee_contact_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.drawee_site_use_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.drawee_site_use_id,
                        AR_NUMBER_DUMMY, trx.drawee_site_use_id,
                                         p_trx_rec.drawee_site_use_id),
                 AR_NUMBER_DUMMY
              )
/*Bug7313869, Removed the check for drawee_bank_account_id*/
         AND
           NVL(trx.remit_bank_acct_use_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.remit_bank_acct_use_id,
                        AR_NUMBER_DUMMY, trx.remit_bank_acct_use_id,
                                         p_trx_rec.remit_bank_acct_use_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.override_remit_account_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.override_remit_account_flag,
                        AR_FLAG_DUMMY, trx.override_remit_account_flag,
                                         p_trx_rec.override_remit_account_flag),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(trx.special_instructions, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.special_instructions,
                        AR_TEXT_DUMMY, trx.special_instructions,
                                         p_trx_rec.special_instructions),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.remittance_batch_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.remittance_batch_id,
                        AR_NUMBER_DUMMY, trx.remittance_batch_id,
                                         p_trx_rec.remittance_batch_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.address_verification_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.address_verification_code,
                        AR_TEXT_DUMMY, trx.address_verification_code,
                                         p_trx_rec.address_verification_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.approval_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.approval_code,
                        AR_TEXT_DUMMY, trx.approval_code,
                                         p_trx_rec.approval_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.bill_to_address_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.bill_to_address_id,
                        AR_NUMBER_DUMMY, trx.bill_to_address_id,
                                         p_trx_rec.bill_to_address_id),
                 AR_NUMBER_DUMMY
              )
          AND
           NVL(trx.edi_processed_flag, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.edi_processed_flag,
                        AR_FLAG_DUMMY, trx.edi_processed_flag,
                                         p_trx_rec.edi_processed_flag),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(trx.edi_processed_status, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.edi_processed_status,
                        AR_TEXT_DUMMY, trx.edi_processed_status,
                                         p_trx_rec.edi_processed_status),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.payment_server_order_num, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.payment_server_order_num,
                        AR_TEXT_DUMMY, trx.payment_server_order_num,
                                         p_trx_rec.payment_server_order_num),
                 AR_TEXT_DUMMY
              )
          AND
           NVL(trx.post_request_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.post_request_id,
                        AR_NUMBER_DUMMY, trx.post_request_id,
                                         p_trx_rec.post_request_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.request_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.request_id,
                        AR_NUMBER_DUMMY, trx.request_id,
                                         p_trx_rec.request_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.ship_to_address_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.ship_to_address_id,
                        AR_NUMBER_DUMMY, trx.ship_to_address_id,
                                         p_trx_rec.ship_to_address_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(trx.wh_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.wh_update_date,
                        AR_DATE_DUMMY, trx.wh_update_date,
                                         p_trx_rec.wh_update_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(trx.global_attribute_category, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute_category,
                        AR_TEXT_DUMMY, trx.global_attribute_category,
                                       p_trx_rec.global_attribute_category),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute1,
                        AR_TEXT_DUMMY, trx.global_attribute1,
                                       p_trx_rec.global_attribute1),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute2,
                        AR_TEXT_DUMMY, trx.global_attribute2,
                                       p_trx_rec.global_attribute2),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute3,
                        AR_TEXT_DUMMY, trx.global_attribute3,
                                       p_trx_rec.global_attribute3),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute4,
                        AR_TEXT_DUMMY, trx.global_attribute4,
                                       p_trx_rec.global_attribute4),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute5,
                        AR_TEXT_DUMMY, trx.global_attribute5,
                                       p_trx_rec.global_attribute5),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute6,
                        AR_TEXT_DUMMY, trx.global_attribute6,
                                       p_trx_rec.global_attribute6),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute7,
                        AR_TEXT_DUMMY, trx.global_attribute7,
                                       p_trx_rec.global_attribute7),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute8,
                        AR_TEXT_DUMMY, trx.global_attribute8,
                                       p_trx_rec.global_attribute8),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute9,
                        AR_TEXT_DUMMY, trx.global_attribute9,
                                       p_trx_rec.global_attribute9),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute10,
                        AR_TEXT_DUMMY, trx.global_attribute10,
                                       p_trx_rec.global_attribute10),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute11,
                        AR_TEXT_DUMMY, trx.global_attribute11,
                                       p_trx_rec.global_attribute11),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute12,
                        AR_TEXT_DUMMY, trx.global_attribute12,
                                       p_trx_rec.global_attribute12),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute13,
                        AR_TEXT_DUMMY, trx.global_attribute13,
                                       p_trx_rec.global_attribute13),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute14,
                        AR_TEXT_DUMMY, trx.global_attribute14,
                                       p_trx_rec.global_attribute14),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute15,
                        AR_TEXT_DUMMY, trx.global_attribute15,
                                       p_trx_rec.global_attribute15),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute16, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute16,
                        AR_TEXT_DUMMY, trx.global_attribute16,
                                       p_trx_rec.global_attribute16),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute17, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute17,
                        AR_TEXT_DUMMY, trx.global_attribute17,
                                       p_trx_rec.global_attribute17),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute18, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute18,
                        AR_TEXT_DUMMY, trx.global_attribute18,
                                       p_trx_rec.global_attribute18),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute19, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute19,
                        AR_TEXT_DUMMY, trx.global_attribute19,
                                       p_trx_rec.global_attribute19),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute20, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute20,
                        AR_TEXT_DUMMY, trx.global_attribute20,
                                       p_trx_rec.global_attribute20),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute21, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute21,
                        AR_TEXT_DUMMY, trx.global_attribute21,
                                       p_trx_rec.global_attribute21),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute22, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute22,
                        AR_TEXT_DUMMY, trx.global_attribute22,
                                       p_trx_rec.global_attribute22),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute23, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute23,
                        AR_TEXT_DUMMY, trx.global_attribute23,
                                       p_trx_rec.global_attribute23),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute24, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute24,
                        AR_TEXT_DUMMY, trx.global_attribute24,
                                       p_trx_rec.global_attribute24),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute25, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute25,
                        AR_TEXT_DUMMY, trx.global_attribute25,
                                       p_trx_rec.global_attribute25),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute26, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute26,
                        AR_TEXT_DUMMY, trx.global_attribute26,
                                       p_trx_rec.global_attribute26),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute27, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute27,
                        AR_TEXT_DUMMY, trx.global_attribute27,
                                       p_trx_rec.global_attribute27),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute28, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute28,
                        AR_TEXT_DUMMY, trx.global_attribute28,
                                       p_trx_rec.global_attribute28),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute29, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute29,
                        AR_TEXT_DUMMY, trx.global_attribute29,
                                       p_trx_rec.global_attribute29),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.global_attribute30, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.global_attribute30,
                        AR_TEXT_DUMMY, trx.global_attribute30,
                                       p_trx_rec.global_attribute30),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(trx.legal_entity_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.legal_entity_id,
                        AR_NUMBER_DUMMY, trx.legal_entity_id,
                                       p_trx_rec.legal_entity_id),
                 AR_NUMBER_DUMMY
              )
      )
        AND
           NVL(trx.payment_trxn_extension_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.payment_trxn_extension_id,
                        AR_NUMBER_DUMMY, trx.payment_trxn_extension_id,
                                       p_trx_rec.payment_trxn_extension_id),
                 AR_NUMBER_DUMMY
              )  /* PAYMENT_UPAKE */
        AND
           NVL(trx.billing_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_trx_rec.billing_date,
                        AR_DATE_DUMMY, trx.billing_date,
                                       p_trx_rec.billing_date),
                 AR_DATE_DUMMY
              )

    FOR UPDATE OF customer_trx_id NOWAIT;

    arp_util.debug('arp_ct_pkg.lock_compare_p()-');

    EXCEPTION
        WHEN  NO_DATA_FOUND THEN
                arp_util.debug(
                       'EXCEPTION: arp_ct_pkg.lock_compare_p NO_DATA_FOUND' );

                arp_util.debug('');
                arp_util.debug('============= Old Record =============');
                display_header_p(p_customer_trx_id);
                arp_util.debug('');
                arp_util.debug('============= New Record =============');
                display_header_rec(p_trx_rec);

                FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                APP_EXCEPTION.Raise_Exception;
        WHEN  OTHERS THEN
                arp_util.debug( 'EXCEPTION: arp_ct_pkg.lock_compare_p' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ra_customer_trx into a 	     |
 |    variable specified as a parameter based on the table's primary key,    |
 |    customer_trx_id. 							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the record to fetch     |
 |              OUT:                                                         |
 |                    p_trx_rec	- contains the fetched record	     	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_trx_rec         OUT NOCOPY ra_customer_trx%rowtype,
                   p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type )
          IS

BEGIN
    arp_util.debug('arp_ct_pkg.fetch_p()+');

    SELECT *
    INTO   p_trx_rec
    FROM   ra_customer_trx
    WHERE  customer_trx_id = p_customer_trx_id;

    arp_util.debug('arp_ct_pkg.fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_ct_pkg.fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_customeR_trx row identified by the 	     |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the row to delete	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |     08-NOV-01  Debbie Jancis       Added calls to MRC engine for          |
 |                                    RA_CUSTOMER_TRX processing             |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type)
       IS


BEGIN


   arp_util.debug('arp_ct_pkg.delete_p()+');

   DELETE FROM ra_customer_trx
   WHERE       customer_trx_id = p_customer_trx_id;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
--{BUG4301323
--    ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode => 'DELETE',
--                        p_table_name => 'RA_CUSTOMER_TRX',
--                        p_mode       => 'SINGLE',
--                        p_key_value  => p_customer_trx_id);
--}
    --
   arp_util.debug('arp_ct_pkg.delete_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.delete_p()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_customer_trx row identified by the       |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the row to update	     |
 |                    p_trx_rec       - contains the new column values       |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_trx_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_trx_rec IN ra_customer_trx%rowtype,
                    p_customer_trx_id  IN
                                ra_customer_trx.customer_trx_id%type) IS

--2528261 begin
l_ct_reference   varchar2(150);
--2528261 end
BEGIN

   arp_util.debug('arp_ct_pkg.update_p()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_ct_pkg.generic_update(  pg_cursor1,
			       ' WHERE customer_trx_id = :where_1',
                               p_customer_trx_id,
                               p_trx_rec);

   arp_util.debug('arp_ct_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));
--2528261 begin
     begin
        SELECT DECODE(DEFAULT_REFERENCE,
                      '1',  p_trx_rec.interface_header_attribute1,
                      '2',  p_trx_rec.interface_header_attribute2,
                      '3',  p_trx_rec.interface_header_attribute3,
                      '4',  p_trx_rec.interface_header_attribute4,
                      '5',  p_trx_rec.interface_header_attribute5,
                      '6',  p_trx_rec.interface_header_attribute6,
                      '7',  p_trx_rec.interface_header_attribute7,
                      '8',  p_trx_rec.interface_header_attribute8,
                      '9',  p_trx_rec.interface_header_attribute9,
                      '10', p_trx_rec.interface_header_attribute10,
                      '11', p_trx_rec.interface_header_attribute11,
                      '12', p_trx_rec.interface_header_attribute12,
                      '13', p_trx_rec.interface_header_attribute13,
                      '14', p_trx_rec.interface_header_attribute14,
                      '15', p_trx_rec.interface_header_attribute15,
                      NULL, p_trx_rec.ct_reference,
                      NULL ) /* Bug fix 5330712 */
        INTO   l_ct_reference
        FROM   ra_batch_sources
        WHERE batch_source_id = p_trx_rec.batch_source_id;
      exception
         when no_data_found then
              l_ct_reference:=null;
         when others then
              l_ct_reference:=null;
      end;
      if l_ct_reference is not null then
       update ra_customer_trx
        set ct_reference =l_ct_reference
       where customer_trx_id = p_trx_rec.customer_trx_id;
      end if;

--2528261 end



EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.update_p()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p_print					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_customer_trx row identified by the       |
 |    p_customer_trx_id parameter.  It calls update_p, then
 |    arp_etax_util.global_document_update.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the row to update	     |
 |                    p_trx_rec       - contains the new column values       |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_trx_rec are        |
 |     changed and this function is called.  This function is
 |     specifically intended for use by outside products that are
 |     updating the ra_customer_trx.print-related fields to
 |     indicate a 'print' event.
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JAN-06  M Raymond           Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p_print( p_trx_rec IN ra_customer_trx%rowtype,
                          p_customer_trx_id  IN
                                   ra_customer_trx.customer_trx_id%type) IS
BEGIN
   /* Call update_p to carry out the actual update */
   update_p(p_trx_rec, p_customer_trx_id);

   /* Call GDU to notify etax of the print event */
   arp_etax_util.global_document_update(p_customer_trx_id,
                                        null,
                                        'PRINT');
EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.update_p_print()');
        RAISE;
END;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ra_customer_trx that contains the    |
 |    column values specified in the p_trx_rec parameter. 		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_global.set_of_books_id					     |
 |                                                                           |
 | ARGUMENTS  :  IN:                                                         |
 |                    p_trx_rec            - contains the new column values  |
 |              OUT:                                                         |
 |                    p_trx_number         - transaction number of new row   |
 |                    p_customer_trx_id    - unique ID of the new row        |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 06-JUN-95    Charlie Tomberg Created                                      |
 | 12-JUL-95    Martin Johnson  Added OUT NOCOPY parameter p_trx_number.            |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              BR_AMOUNT, BR_UNPAID_FLAG,BR_ON_HOLD_FLAG,   |
 |                              DRAWEE_ID, DRAWEE_CONTACT_ID,                |
 |                              DRAWEE_SITE_USE_ID   		             |
 |                              DRAWEE_BANK_ACCOUNT_ID,                      |
 |                              REMITTANCE_BANK_ACCOUNT_ID,		     |
 |                              OVERRIDE_REMIT_ACCOUNT_FLAG and              |
 |                              SPECIAL_INSTRUCTIONSinto table handlers      |
 | 24-JUL-2000  J Rautiainen    Added BR project related column              |
 |                              REMITTANCE_BATCH_ID		             |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns                  |
 |                              address_verification_code and	             |
 |				approval_code	and			     |
 |				bill_to_address_id and			     |
 |				edi_processed_flag and			     |
 |				edi_processed_status and		     |
 |				payment_server_order_num and		     |
 |				post_request_id and			     |
 |				request_id and				     |
 |				ship_to_address_id			     |
 |				wh_update_date				     |
 | 				into the table handlers.  		     |
 | 6-Jul-2001 yreddy            Bug1738914 - Added 'Copy doc num to          |
 |                              Trx Number'                                  |
 |                              functionality for chargebacks.               |
 | 08-NOV-01  Debbie Jancis     Added calls to MRC engine for                |
 |                              RA_CUSTOMER_TRX processing                   |
 |                                                                           |
 | 20-Jun-02  Sahana            Bug2427456: Added global attribute columns   |
 | 18-May-05  Debbie Jancis     Added Legal Entity ID for LE project         |
 +===========================================================================*/

PROCEDURE insert_p(
                    p_trx_rec          IN ra_customer_trx%rowtype,
                    p_trx_number      OUT NOCOPY ra_customer_trx.trx_number%type,
                    p_customer_trx_id OUT NOCOPY ra_customer_trx.customer_trx_id%type
                  ) IS


    l_customer_trx_id  ra_customer_trx.customer_trx_id%type;
    l_org_id           integer;
    l_org_str          varchar2(30);
    l_trx_num_cursor   integer;
    l_dummy            integer;
    l_trx_number       ra_customer_trx.trx_number%type;
    l_trx_str          VARCHAR2(1000);
    l_copy_doc_number_flag    varchar2(1):='N';             --Bug1738914
    l_old_trx_number   ra_customer_trx.old_trx_number%type; --Bug1738914
    l_ct_reference      varchar2(150);
    l_legal_entity_id   number;

BEGIN

    arp_util.debug('arp_ct_pkg.insert_p()+');

    arp_util.debug('CM trx number   :' || p_trx_number );
    --p_trx_number := '';

    p_customer_trx_id := '';

    /*---------------------------------------------------------------*
     | validate that the transaction and document numbers are unique |
     *---------------------------------------------------------------*/

     arp_trx_validate.validate_trx_number( p_trx_rec.batch_source_id,
                                           p_trx_rec.trx_number,
                                           p_trx_rec.customer_trx_id);

     arp_trx_validate.validate_doc_number( p_trx_rec.cust_trx_type_id,
                                           p_trx_rec.doc_sequence_value,
                                           p_trx_rec.customer_trx_id);


    /*---------------------------*
     | Get the unique identifier |
     *---------------------------*/

        SELECT RA_CUSTOMER_TRX_S.NEXTVAL
        INTO   l_customer_trx_id
        FROM   DUAL;

    /*----------------------------*
     | Get the transaction number |
     *----------------------------*/

     IF (p_trx_rec.trx_number is null)
     THEN
          SELECT MIN(org_id)
          INTO   l_org_id
          FROM   ar_system_parameters;

          IF (l_org_id IS NOT NULL) THEN
              l_org_str := '_'||to_char(l_org_id);
          ELSE
              l_org_str := NULL;
          END IF;

    -- Bug 1185665 : change dbms_sql to use native dynamic sql

    /* Bug 1738914 : Selecting copy_doc_number_flag. Chargebacks are always
     numbered automatically , so this piece of code gets executed all the time */

       l_trx_str :=  'select ra_trx_number_' ||
                               REPLACE(p_trx_rec.batch_source_id, '-', 'N') ||
                          l_org_str||
                          '_s.nextval trx_number,copy_doc_number_flag ' ||
                          'from ra_batch_sources ' ||
                          'where batch_source_id = ' ||
                               p_trx_rec.batch_source_id ||
                         ' and auto_trx_numbering_flag = ''Y''';

            EXECUTE IMMEDIATE l_trx_str
                INTO l_trx_number,l_copy_doc_number_flag;

/*
          l_trx_num_cursor := dbms_sql.open_cursor;

          dbms_sql.parse(l_trx_num_cursor,
                          'select ra_trx_number_' ||
                               REPLACE(p_trx_rec.batch_source_id, '-', 'N') ||
                          l_org_str||
                          '_s.nextval trx_number ' ||
                          'from ra_batch_sources ' ||
                          'where batch_source_id = ' ||
                               p_trx_rec.batch_source_id ||
                         ' and auto_trx_numbering_flag = ''Y''',
                         dbms_sql.v7);

          dbms_sql.define_column(l_trx_num_cursor, 1, l_trx_number, 20);

          l_dummy := dbms_sql.execute_and_fetch(l_trx_num_cursor, TRUE);

          dbms_sql.column_value(l_trx_num_cursor, 1, l_trx_number);

          dbms_sql.close_cursor(l_trx_num_cursor);
*/
     ELSE
          l_trx_number := p_trx_rec.trx_number;
     END IF;

    /*-----------------------------------------------------------------------*
     | Bug 1738914: When the 'Copy doc Num to Trx Number' checkbox is ticked |
     | for the 'Chargeback' source ( batch_source_id = 12 ) , the document   |
     | number will be copied to the trx_number .As the chargeback is saved   |
     | as completed,the copy logic is added here .                           |
     *-----------------------------------------------------------------------*/

     l_old_trx_number := p_trx_rec.old_trx_number;

     IF ( p_trx_rec.batch_source_id = 12  AND
       Nvl(l_copy_doc_number_flag,'N') = 'Y' AND
       p_trx_rec.doc_sequence_value IS NOT NULL ) THEN
            l_old_trx_number := l_trx_number;
            l_trx_number := p_trx_rec.doc_sequence_value;
     END IF;
--2528261 begin
     begin
        SELECT DECODE(DEFAULT_REFERENCE,
                      '1',  p_trx_rec.interface_header_attribute1,
                      '2',  p_trx_rec.interface_header_attribute2,
                      '3',  p_trx_rec.interface_header_attribute3,
                      '4',  p_trx_rec.interface_header_attribute4,
                      '5',  p_trx_rec.interface_header_attribute5,
                      '6',  p_trx_rec.interface_header_attribute6,
                      '7',  p_trx_rec.interface_header_attribute7,
                      '8',  p_trx_rec.interface_header_attribute8,
                      '9',  p_trx_rec.interface_header_attribute9,
                      '10', p_trx_rec.interface_header_attribute10,
                      '11', p_trx_rec.interface_header_attribute11,
                      '12', p_trx_rec.interface_header_attribute12,
                      '13', p_trx_rec.interface_header_attribute13,
                      '14', p_trx_rec.interface_header_attribute14,
                      '15', p_trx_rec.interface_header_attribute15,
                      NULL,p_trx_rec.ct_reference, /* Bug fix 5330712*/
                      NULL )
        INTO   l_ct_reference
        FROM   ra_batch_sources
        WHERE batch_source_id = p_trx_rec.batch_source_id;
      exception
         when no_data_found then
              l_ct_reference:=null;
         when others then
              l_ct_reference:=null;
      end;

    /*-------------------*
     | Insert the record |
     *-------------------*/

   INSERT INTO ra_customer_trx
               (
                 customer_trx_id,
                 trx_number,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 set_of_books_id,
                 program_application_id,
                 program_id,
                 program_update_date,
                 posting_control_id,
                 ra_post_loop_number,
                 complete_flag,
                 initial_customer_trx_id,
                 previous_customer_trx_id,
                 related_customer_trx_id,
                 recurred_from_trx_number,
                 cust_trx_type_id,
                 batch_id,
                 batch_source_id,
                 agreement_id,
                 trx_date,
                 bill_to_customer_id,
                 bill_to_contact_id,
                 bill_to_site_use_id,
                 ship_to_customer_id,
                 ship_to_contact_id,
                 ship_to_site_use_id,
                 sold_to_customer_id,
                 sold_to_site_use_id,
                 sold_to_contact_id,
                 customer_reference,
                 customer_reference_date,
                 credit_method_for_installments,
                 credit_method_for_rules,
                 start_date_commitment,
                 end_date_commitment,
                 exchange_date,
                 exchange_rate,
                 exchange_rate_type,
                 customer_bank_account_id,
                 finance_charges,
                 fob_point,
                 comments,
                 internal_notes,
                 invoice_currency_code,
                 invoicing_rule_id,
                 last_printed_sequence_num,
                 orig_system_batch_name,
                 primary_salesrep_id,
                 printing_count,
                 printing_last_printed,
                 printing_option,
                 printing_original_date,
                 printing_pending,
                 purchase_order,
                 purchase_order_date,
                 purchase_order_revision,
                 receipt_method_id,
                 remit_to_address_id,
                 shipment_id,
                 ship_date_actual,
                 ship_via,
                 term_due_date,
                 term_id,
                 territory_id,
                 waybill_number,
                 status_trx,
                 reason_code,
                 doc_sequence_id,
                 doc_sequence_value,
                 paying_customer_id,
                 paying_site_use_id,
                 related_batch_source_id,
                 default_tax_exempt_flag,
                 created_from,
                 default_ussgl_trx_code_context,
                 default_ussgl_transaction_code,
                 old_trx_number,
                 interface_header_context,
                 interface_header_attribute1,
                 interface_header_attribute2,
                 interface_header_attribute3,
                 interface_header_attribute4,
                 interface_header_attribute5,
                 interface_header_attribute6,
                 interface_header_attribute7,
                 interface_header_attribute8,
                 interface_header_attribute9,
                 interface_header_attribute10,
                 interface_header_attribute11,
                 interface_header_attribute12,
                 interface_header_attribute13,
                 interface_header_attribute14,
                 interface_header_attribute15,
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
                 br_amount,
                 br_unpaid_flag,
                 br_on_hold_flag,
                 drawee_id,
                 drawee_contact_id,
                 drawee_site_use_id,
                 drawee_bank_account_id,
                 remit_bank_acct_use_id,
                 override_remit_account_flag,
                 special_instructions,
                 remittance_batch_id,
                 address_verification_code,
                 approval_code,
                 bill_to_address_id,
                 edi_processed_flag,
                 edi_processed_status,
                 payment_server_order_num,
                 post_request_id,
                 request_id,
                 ship_to_address_id,
                 wh_update_date,
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
                 global_attribute21,
                 global_attribute22,
                 global_attribute23,
                 global_attribute24,
                 global_attribute25,
                 global_attribute26,
                 global_attribute27,
                 global_attribute28,
                 global_attribute29,
                 global_attribute30
                 ,ct_reference
                 ,org_id
                 ,legal_entity_id -- LE
                 ,payment_trxn_extension_id   /* PAYMENT_UPTAKE */
                 ,billing_date
               )
         VALUES
               (
                 l_customer_trx_id,
                 l_trx_number,
                 pg_user_id,			/* created_by */
                 sysdate, 			/* creation_date */
                 pg_user_id,			/* last_updated_by */
                 sysdate,			/* last_update_date */
                 nvl(pg_conc_login_id,
                     pg_login_id),		/* last_update_login */
                 arp_global.set_of_books_id,	/* set_of_books_id */
                 pg_prog_appl_id,		/* program_application_id */
                 pg_conc_program_id,		/* program_id */
                 sysdate,			/* program_update_date */
                 p_trx_rec.posting_control_id,
                 p_trx_rec.ra_post_loop_number,
                 p_trx_rec.complete_flag,
                 p_trx_rec.initial_customer_trx_id,
                 p_trx_rec.previous_customer_trx_id,
                 p_trx_rec.related_customer_trx_id,
                 p_trx_rec.recurred_from_trx_number,
                 p_trx_rec.cust_trx_type_id,
                 p_trx_rec.batch_id,
                 p_trx_rec.batch_source_id,
                 p_trx_rec.agreement_id,
                 p_trx_rec.trx_date,
                 p_trx_rec.bill_to_customer_id,
                 p_trx_rec.bill_to_contact_id,
                 p_trx_rec.bill_to_site_use_id,
                 p_trx_rec.ship_to_customer_id,
                 p_trx_rec.ship_to_contact_id,
                 p_trx_rec.ship_to_site_use_id,
                 p_trx_rec.sold_to_customer_id,
                 p_trx_rec.sold_to_site_use_id,
                 p_trx_rec.sold_to_contact_id,
                 p_trx_rec.customer_reference,
                 p_trx_rec.customer_reference_date,
                 p_trx_rec.credit_method_for_installments,
                 p_trx_rec.credit_method_for_rules,
                 p_trx_rec.start_date_commitment,
                 p_trx_rec.end_date_commitment,
                 p_trx_rec.exchange_date,
                 p_trx_rec.exchange_rate,
                 p_trx_rec.exchange_rate_type,
                 p_trx_rec.customer_bank_account_id,
                 p_trx_rec.finance_charges,
                 p_trx_rec.fob_point,
                 p_trx_rec.comments,
                 p_trx_rec.internal_notes,
                 p_trx_rec.invoice_currency_code,
                 p_trx_rec.invoicing_rule_id,
                 p_trx_rec.last_printed_sequence_num,
                 p_trx_rec.orig_system_batch_name,
                 p_trx_rec.primary_salesrep_id,
                 p_trx_rec.printing_count,
                 p_trx_rec.printing_last_printed,
                 p_trx_rec.printing_option,
                 p_trx_rec.printing_original_date,
                 decode(p_trx_rec.printing_option,
                        'PRI', 'Y',
                        'NOT', 'N',
                               p_trx_rec.printing_pending),
                 p_trx_rec.purchase_order,
                 p_trx_rec.purchase_order_date,
                 p_trx_rec.purchase_order_revision,
                 p_trx_rec.receipt_method_id,
                 p_trx_rec.remit_to_address_id,
                 p_trx_rec.shipment_id,
                 p_trx_rec.ship_date_actual,
                 p_trx_rec.ship_via,
                 p_trx_rec.term_due_date,
                 p_trx_rec.term_id,
                 p_trx_rec.territory_id,
                 p_trx_rec.waybill_number,
                 p_trx_rec.status_trx,
                 p_trx_rec.reason_code,
                 p_trx_rec.doc_sequence_id,
                 p_trx_rec.doc_sequence_value,
                 p_trx_rec.paying_customer_id,
                 p_trx_rec.paying_site_use_id,
                 p_trx_rec.related_batch_source_id,
                 p_trx_rec.default_tax_exempt_flag,
                 p_trx_rec.created_from,
                 p_trx_rec.default_ussgl_trx_code_context,
                 p_trx_rec.default_ussgl_transaction_code,
                 l_old_trx_number,                         --Bug1738914
                 p_trx_rec.interface_header_context,
                 p_trx_rec.interface_header_attribute1,
                 p_trx_rec.interface_header_attribute2,
                 p_trx_rec.interface_header_attribute3,
                 p_trx_rec.interface_header_attribute4,
                 p_trx_rec.interface_header_attribute5,
                 p_trx_rec.interface_header_attribute6,
                 p_trx_rec.interface_header_attribute7,
                 p_trx_rec.interface_header_attribute8,
                 p_trx_rec.interface_header_attribute9,
                 p_trx_rec.interface_header_attribute10,
                 p_trx_rec.interface_header_attribute11,
                 p_trx_rec.interface_header_attribute12,
                 p_trx_rec.interface_header_attribute13,
                 p_trx_rec.interface_header_attribute14,
                 p_trx_rec.interface_header_attribute15,
                 p_trx_rec.attribute_category,
                 p_trx_rec.attribute1,
                 p_trx_rec.attribute2,
                 p_trx_rec.attribute3,
                 p_trx_rec.attribute4,
                 p_trx_rec.attribute5,
                 p_trx_rec.attribute6,
                 p_trx_rec.attribute7,
                 p_trx_rec.attribute8,
                 p_trx_rec.attribute9,
                 p_trx_rec.attribute10,
                 p_trx_rec.attribute11,
                 p_trx_rec.attribute12,
                 p_trx_rec.attribute13,
                 p_trx_rec.attribute14,
                 p_trx_rec.attribute15,
                 p_trx_rec.br_amount,
                 p_trx_rec.br_unpaid_flag,
                 p_trx_rec.br_on_hold_flag,
                 p_trx_rec.drawee_id,
                 p_trx_rec.drawee_contact_id,
                 p_trx_rec.drawee_site_use_id,
                 p_trx_rec.drawee_bank_account_id,
                 p_trx_rec.remit_bank_acct_use_id,
                 p_trx_rec.override_remit_account_flag,
                 p_trx_rec.special_instructions,
                 p_trx_rec.remittance_batch_id,
                 p_trx_rec.address_verification_code,
                 p_trx_rec.approval_code,
                 p_trx_rec.bill_to_address_id,
                 p_trx_rec.edi_processed_flag,
                 p_trx_rec.edi_processed_status,
                 p_trx_rec.payment_server_order_num,
                 p_trx_rec.post_request_id,
                 p_trx_rec.request_id,
                 p_trx_rec.ship_to_address_id,
                 p_trx_rec.wh_update_date,
                 p_trx_rec.global_attribute_category,
                 p_trx_rec.global_attribute1,
                 p_trx_rec.global_attribute2,
                 p_trx_rec.global_attribute3,
                 p_trx_rec.global_attribute4,
                 p_trx_rec.global_attribute5,
                 p_trx_rec.global_attribute6,
                 p_trx_rec.global_attribute7,
                 p_trx_rec.global_attribute8,
                 p_trx_rec.global_attribute9,
                 p_trx_rec.global_attribute10,
                 p_trx_rec.global_attribute11,
                 p_trx_rec.global_attribute12,
                 p_trx_rec.global_attribute13,
                 p_trx_rec.global_attribute14,
                 p_trx_rec.global_attribute15,
                 p_trx_rec.global_attribute16,
                 p_trx_rec.global_attribute17,
                 p_trx_rec.global_attribute18,
                 p_trx_rec.global_attribute19,
                 p_trx_rec.global_attribute20,
                 p_trx_rec.global_attribute21,
                 p_trx_rec.global_attribute22,
                 p_trx_rec.global_attribute23,
                 p_trx_rec.global_attribute24,
                 p_trx_rec.global_attribute25,
                 p_trx_rec.global_attribute26,
                 p_trx_rec.global_attribute27,
                 p_trx_rec.global_attribute28,
                 p_trx_rec.global_attribute29,
                 p_trx_rec.global_attribute30,
                 l_ct_reference,
                 arp_standard.sysparm.org_id, /* SSA changes anuj */
                 p_trx_rec.legal_entity_id, --LE
                 p_trx_rec.payment_trxn_extension_id, /* PAYMENT_UPTAKE  */
                 p_trx_rec.billing_date
               );

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
--{BUG4301323
--    ar_mrc_engine.maintain_mrc_data(
--             p_event_mode        => 'INSERT',
--             p_table_name        => 'RA_CUSTOMER_TRX',
--             p_mode              => 'SINGLE',
--             p_key_value         => l_customer_trx_id);
--}

   p_trx_number := l_trx_number;
   p_customer_trx_id := l_customer_trx_id;

   arp_util.debug('arp_ct_pkg.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.insert_p()');
	RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_header_p                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and            |
 |    last_update_date.                                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_customer_trx_id                                   |
 |              OUT:                                                         |
 |          IN/ OUT:							     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_header_p(
            p_customer_trx_id IN ra_customer_trx.customer_trx_id%type) IS

   l_trx_rec ra_customer_trx%rowtype;

BEGIN

   arp_util.debug('arp_ct_pkg.display_header_p()+');

   arp_ct_pkg.fetch_p(l_trx_rec, p_customer_trx_id);

   arp_ct_pkg.display_header_rec(l_trx_rec);

   arp_util.debug('arp_ct_pkg.display_header_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.display_header_p()');
        RAISE;

END;

/*==========================================================================+
 | PROCEDURE                                                                |
 |    display_header_rec                                                    |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    Displays the values of all columns except creation_date and           |
 |    last_update_date.                                                     |
 |                                                                          |
 | SCOPE - PRIVATE                                                          |
 |                                                                          |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |    arp_util.debug                                                        |
 |                                                                          |
 | ARGUMENTS  : IN:                                                         |
 |                       p_customer_trx_id                                  |
 |              OUT:                                                        |
 |          IN/ OUT:							    |
 |                                                                          |
 | RETURNS    : NONE                                                        |
 |                                                                          |
 | NOTES                                                                    |
 |                                                                          |
 | MODIFICATION HISTORY                                                     |
 | 19-JUL-95  Martin Johnson    Created                                     |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns            |
 |                              BR_AMOUNT, BR_UNPAID_FLAG,BR_ON_HOLD_FLAG,  |
 |                              DRAWEE_ID, DRAWEE_CONTACT_ID,               |
 |                              DRAWEE_SITE_USE_ID,DRAWEE_BANK_ACCOUNT_ID,  |
 |                              REMITTANCE_BANK_ACCOUNT_ID,		    |
 |                              OVERRIDE_REMIT_ACCOUNT_FLAG and             |
 |                              SPECIAL_INSTRUCTIONSinto table handlers     |
 | 24-JUL-2000  J Rautiainen    Added BR project related column             |
 |                              REMITTANCE_BATCH_ID		            |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns                 |
 |                              address_verification_code and	            |
 |				approval_code	and			    |
 |				bill_to_address_id and		            |
 |				edi_processed_flag and			    |
 |				edi_processed_status and		    |
 |				payment_server_order_num and		    |
 |				post_request_id and			    |
 |				request_id and				    |
 |				ship_to_address_id			    |
 |				wh_update_date				    |
 | 				into the table handlers.                    |
 +==========================================================================*/

PROCEDURE display_header_rec ( p_trx_rec IN ra_customer_trx%rowtype ) IS

BEGIN

   arp_util.debug('arp_ct_pkg.display_header_rec()+');

   arp_util.debug('************ Dump of ra_customer_trx record ************');
   arp_util.debug('customer_trx_id: '	     || p_trx_rec.customer_trx_id);
   arp_util.debug('trx_number: '	     || p_trx_rec.trx_number);
   arp_util.debug('created_by: '	     || p_trx_rec.created_by);
   arp_util.debug('last_updated_by: '        || p_trx_rec.last_updated_by);
   arp_util.debug('last_update_login: '      || p_trx_rec.last_update_login);
   arp_util.debug('set_of_books_id: '        || p_trx_rec.set_of_books_id);
   arp_util.debug('program_application_id: ' ||
                                p_trx_rec.program_application_id);
   arp_util.debug('program_id: '             || p_trx_rec.program_id);
   arp_util.debug('program_update_date: '    || p_trx_rec.program_update_date);
   arp_util.debug('posting_control_id: '     || p_trx_rec.posting_control_id);
   arp_util.debug('ra_post_loop_number: '    || p_trx_rec.ra_post_loop_number);
   arp_util.debug('complete_flag: '          || p_trx_rec.complete_flag);
   arp_util.debug('initial_customer_trx_id: '||
                                p_trx_rec.initial_customer_trx_id);
   arp_util.debug('previous_customer_trx_id: ' ||
                                p_trx_rec.previous_customer_trx_id);
   arp_util.debug('related_customer_trx_id: '||
                                p_trx_rec.related_customer_trx_id);
   arp_util.debug('recurred_from_trx_number: ' ||
                                p_trx_rec.recurred_from_trx_number);
   arp_util.debug('cust_trx_type_id: '       || p_trx_rec.cust_trx_type_id);
   arp_util.debug('batch_id: '               || p_trx_rec.batch_id);
   arp_util.debug('batch_source_id: '        || p_trx_rec.batch_source_id);
   arp_util.debug('agreement_id: '           || p_trx_rec.agreement_id);
   arp_util.debug('trx_date: '               || p_trx_rec.trx_date);
   arp_util.debug('bill_to_customer_id: '    || p_trx_rec.bill_to_customer_id);
   arp_util.debug('bill_to_contact_id: '     || p_trx_rec.bill_to_contact_id);
   arp_util.debug('bill_to_site_use_id: '    || p_trx_rec.bill_to_site_use_id);
   arp_util.debug('ship_to_customer_id: '    || p_trx_rec.ship_to_customer_id);
   arp_util.debug('ship_to_contact_id: '     || p_trx_rec.ship_to_contact_id);
   arp_util.debug('ship_to_site_use_id: '    || p_trx_rec.ship_to_site_use_id);
   arp_util.debug('sold_to_customer_id: '    || p_trx_rec.sold_to_customer_id);
   arp_util.debug('sold_to_site_use_id: '    || p_trx_rec.sold_to_site_use_id);
   arp_util.debug('sold_to_contact_id: '     || p_trx_rec.sold_to_contact_id);
   arp_util.debug('customer_reference: '     || p_trx_rec.customer_reference);
   arp_util.debug('customer_reference_date: '||
                                 p_trx_rec.customer_reference_date);
   arp_util.debug('credit_method_for_installments: ' ||
                                 p_trx_rec.credit_method_for_installments);
   arp_util.debug('credit_method_for_rules: ' ||
                                 p_trx_rec.credit_method_for_rules);
   arp_util.debug('start_date_commitment: '  ||
                                 p_trx_rec.start_date_commitment);
   arp_util.debug('end_date_commitment: '    ||
                                 p_trx_rec.end_date_commitment);
   arp_util.debug('exchange_date: '          || p_trx_rec.exchange_date);
   arp_util.debug('exchange_rate: '          || p_trx_rec.exchange_rate);
   arp_util.debug('exchange_rate_type: '     || p_trx_rec.exchange_rate_type);
   arp_util.debug('customer_bank_account_id: '||
                                 p_trx_rec.customer_bank_account_id);
   arp_util.debug('finance_charges: '        || p_trx_rec.finance_charges);
   arp_util.debug('fob_point: '              || p_trx_rec.fob_point);
   arp_util.debug('comments: '               || p_trx_rec.comments);
   arp_util.debug('internal_notes: '         || p_trx_rec.internal_notes);
   arp_util.debug('invoice_currency_code: '  ||
                                p_trx_rec.invoice_currency_code);
   arp_util.debug('invoicing_rule_id: '      || p_trx_rec.invoicing_rule_id);
   arp_util.debug('last_printed_sequence_num: ' ||
                                p_trx_rec.last_printed_sequence_num);
   arp_util.debug('orig_system_batch_name: ' ||
                                p_trx_rec.orig_system_batch_name);
   arp_util.debug('primary_salesrep_id: '    ||
                                p_trx_rec.primary_salesrep_id);
   arp_util.debug('printing_count: '         || p_trx_rec.printing_count);
   arp_util.debug('printing_last_printed: '  ||
                                p_trx_rec.printing_last_printed);
   arp_util.debug('printing_option: '        || p_trx_rec.printing_option);
   arp_util.debug('printing_original_date: ' ||
                                p_trx_rec.printing_original_date);
   arp_util.debug('printing_pending: '       || p_trx_rec.printing_pending);
   arp_util.debug('purchase_order: '         || p_trx_rec.purchase_order);
   arp_util.debug('purchase_order_date: '    || p_trx_rec.purchase_order_date);
   arp_util.debug('purchase_order_revision: ' ||
                                p_trx_rec.purchase_order_revision);
   arp_util.debug('receipt_method_id: '      || p_trx_rec.receipt_method_id);
   arp_util.debug('remit_to_address_id: '    || p_trx_rec.remit_to_address_id);
   arp_util.debug('shipment_id: '            || p_trx_rec.shipment_id);
   arp_util.debug('ship_date_actual: '       || p_trx_rec.ship_date_actual);
   arp_util.debug('ship_via: '               || p_trx_rec.ship_via);
   arp_util.debug('term_due_date: '          || p_trx_rec.term_due_date);
   arp_util.debug('term_id: '                || p_trx_rec.term_id);
   arp_util.debug('territory_id: '           || p_trx_rec.territory_id);
   arp_util.debug('waybill_number: '         || p_trx_rec.waybill_number);
   arp_util.debug('status_trx: '             || p_trx_rec.status_trx);
   arp_util.debug('reason_code: '            || p_trx_rec.reason_code);
   arp_util.debug('doc_sequence_id: '        || p_trx_rec.doc_sequence_id);
   arp_util.debug('doc_sequence_value: '     || p_trx_rec.doc_sequence_value);
   arp_util.debug('paying_customer_id: '     || p_trx_rec.paying_customer_id);
   arp_util.debug('paying_site_use_id: '     || p_trx_rec.paying_site_use_id);
   arp_util.debug('related_batch_source_id: '||
                                p_trx_rec.related_batch_source_id);
   arp_util.debug('default_tax_exempt_flag: '||
                                p_trx_rec.default_tax_exempt_flag);
   arp_util.debug('created_from: '           || p_trx_rec.created_from);
   arp_util.debug('default_ussgl_trx_code_context: ' ||
                                p_trx_rec.default_ussgl_trx_code_context);
   arp_util.debug('default_ussgl_transaction_code: ' ||
                                p_trx_rec.default_ussgl_transaction_code);
   arp_util.debug('old_trx_number: '         || p_trx_rec.old_trx_number);
   arp_util.debug('interface_header_context: ' ||
                                p_trx_rec.interface_header_context);
   arp_util.debug('interface_header_attribute1: ' ||
                                p_trx_rec.interface_header_attribute1);
   arp_util.debug('interface_header_attribute2: ' ||
                                p_trx_rec.interface_header_attribute2);
   arp_util.debug('interface_header_attribute3: ' ||
                                p_trx_rec.interface_header_attribute3);
   arp_util.debug('interface_header_attribute4: ' ||
                                p_trx_rec.interface_header_attribute4);
   arp_util.debug('interface_header_attribute5: ' ||
                                p_trx_rec.interface_header_attribute5);
   arp_util.debug('interface_header_attribute6: ' ||
                                p_trx_rec.interface_header_attribute6);
   arp_util.debug('interface_header_attribute7: ' ||
                                p_trx_rec.interface_header_attribute7);
   arp_util.debug('interface_header_attribute8: ' ||
                                p_trx_rec.interface_header_attribute8);
   arp_util.debug('interface_header_attribute9: ' ||
                                p_trx_rec.interface_header_attribute9);
   arp_util.debug('interface_header_attribute10: '||
                                p_trx_rec.interface_header_attribute10);
   arp_util.debug('interface_header_attribute11: '||
                                p_trx_rec.interface_header_attribute11);
   arp_util.debug('interface_header_attribute12: '||
                                p_trx_rec.interface_header_attribute12);
   arp_util.debug('interface_header_attribute13: '||
                                p_trx_rec.interface_header_attribute13);
   arp_util.debug('interface_header_attribute14: '||
                                p_trx_rec.interface_header_attribute14);
   arp_util.debug('interface_header_attribute15: '||
                                p_trx_rec.interface_header_attribute15);
   arp_util.debug('attribute_category: '   || p_trx_rec.attribute_category);
   arp_util.debug('attribute1: '           || p_trx_rec.attribute1);
   arp_util.debug('attribute2: '           || p_trx_rec.attribute2);
   arp_util.debug('attribute3: '           || p_trx_rec.attribute3);
   arp_util.debug('attribute4: '           || p_trx_rec.attribute4);
   arp_util.debug('attribute5: '           || p_trx_rec.attribute5);
   arp_util.debug('attribute6: '           || p_trx_rec.attribute6);
   arp_util.debug('attribute7: '           || p_trx_rec.attribute7);
   arp_util.debug('attribute8: '           || p_trx_rec.attribute8);
   arp_util.debug('attribute9: '           || p_trx_rec.attribute9);
   arp_util.debug('attribute10: '          || p_trx_rec.attribute10);
   arp_util.debug('attribute11: '          || p_trx_rec.attribute11);
   arp_util.debug('attribute12: '          || p_trx_rec.attribute12);
   arp_util.debug('attribute13: '          || p_trx_rec.attribute13);
   arp_util.debug('attribute14: '          || p_trx_rec.attribute14);
   arp_util.debug('attribute15: '          || p_trx_rec.attribute15);
   arp_util.debug('br_amount: '            || p_trx_rec.br_amount);
   arp_util.debug('br_unpaid_flag: '       || p_trx_rec.br_unpaid_flag);
   arp_util.debug('br_on_hold_flag: '      || p_trx_rec.br_on_hold_flag);
   arp_util.debug('drawee_id: '            || p_trx_rec.drawee_id);
   arp_util.debug('drawee_contact_id: '    || p_trx_rec.drawee_contact_id);
   arp_util.debug('drawee_site_use_id: '   || p_trx_rec.drawee_site_use_id);
   arp_util.debug('drawee_bank_account_id: '      || p_trx_rec.drawee_bank_account_id);
   arp_util.debug('remit_bank_acct_use_id: '  || p_trx_rec.remit_bank_acct_use_id);
   arp_util.debug('override_remit_account_flag: ' || p_trx_rec.override_remit_account_flag);
   arp_util.debug('special_instructions: '   	  || p_trx_rec.special_instructions);
   arp_util.debug('remittance_batch_id: '  	  || p_trx_rec.remittance_batch_id);
   arp_util.debug('address_verification_code: '     || p_trx_rec.address_verification_code);
   arp_util.debug('approval_code: '      	    || p_trx_rec.approval_code);
   arp_util.debug('bill_to_address_id: '            || p_trx_rec.bill_to_address_id);
   arp_util.debug('edi_processed_flag: '    	    || p_trx_rec.edi_processed_flag);
   arp_util.debug('edi_processed_status: '   	    || p_trx_rec.edi_processed_status);
   arp_util.debug('payment_server_order_num: '      || p_trx_rec.payment_server_order_num);
   arp_util.debug('post_request_id: '  	   	    || p_trx_rec.post_request_id);
   arp_util.debug('request_id: ' 	   	    || p_trx_rec.request_id);
   arp_util.debug('ship_to_address_id: '   	    || p_trx_rec.ship_to_address_id);
   arp_util.debug('wh_update_date: '  	   	    || p_trx_rec.wh_update_date);

   arp_util.debug('global_attribute_category: '   || p_trx_rec.global_attribute_category);
   arp_util.debug('global_attribute1: '           || p_trx_rec.global_attribute1);
   arp_util.debug('global_attribute2: '           || p_trx_rec.global_attribute2);
   arp_util.debug('global_attribute3: '           || p_trx_rec.global_attribute3);
   arp_util.debug('global_attribute4: '           || p_trx_rec.global_attribute4);
   arp_util.debug('global_attribute5: '           || p_trx_rec.global_attribute5);
   arp_util.debug('global_attribute6: '           || p_trx_rec.global_attribute6);
   arp_util.debug('global_attribute7: '           || p_trx_rec.global_attribute7);
   arp_util.debug('global_attribute8: '           || p_trx_rec.global_attribute8);
   arp_util.debug('global_attribute9: '           || p_trx_rec.global_attribute9);
   arp_util.debug('global_attribute10: '          || p_trx_rec.global_attribute10);
   arp_util.debug('global_attribute11: '          || p_trx_rec.global_attribute11);
   arp_util.debug('global_attribute12: '          || p_trx_rec.global_attribute12);
   arp_util.debug('global_attribute13: '          || p_trx_rec.global_attribute13);
   arp_util.debug('global_attribute14: '          || p_trx_rec.global_attribute14);
   arp_util.debug('global_attribute15: '          || p_trx_rec.global_attribute15);
   arp_util.debug('global_attribute16: '           || p_trx_rec.global_attribute16);
   arp_util.debug('global_attribute17: '           || p_trx_rec.global_attribute17);
   arp_util.debug('global_attribute18: '           || p_trx_rec.global_attribute18);
   arp_util.debug('global_attribute19: '           || p_trx_rec.global_attribute19);
   arp_util.debug('global_attribute20: '          || p_trx_rec.global_attribute20);
   arp_util.debug('global_attribute21: '          || p_trx_rec.global_attribute21);
   arp_util.debug('global_attribute22: '          || p_trx_rec.global_attribute22);
   arp_util.debug('global_attribute23: '          || p_trx_rec.global_attribute23);
   arp_util.debug('global_attribute24: '          || p_trx_rec.global_attribute24);
   arp_util.debug('global_attribute25: '          || p_trx_rec.global_attribute25);
   arp_util.debug('global_attribute26: '           || p_trx_rec.global_attribute26);
   arp_util.debug('global_attribute27: '           || p_trx_rec.global_attribute27);
   arp_util.debug('global_attribute28: '           || p_trx_rec.global_attribute28);
   arp_util.debug('global_attribute29: '           || p_trx_rec.global_attribute29);
   arp_util.debug('global_attribute30: '          || p_trx_rec.global_attribute30);

   arp_util.debug('legal_entity_id: ' || to_char(p_trx_rec.legal_entity_id));
   arp_util.debug('payment_trxn_extension_id: ' || to_char(p_trx_rec.payment_trxn_extension_id));
   arp_util.debug('billing_date: '                || p_trx_rec.billing_date);

   arp_util.debug('************* End ra_customer_trx record *************');

   arp_util.debug('arp_ct_pkg.display_header_rec()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION: arp_ct_pkg.display_header_rec()');
   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_frt_cover                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a transaction header record and          |
 |    locks the transaction header.                                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_ship_via                                             |
 |                    p_ship_date_actual                                     |
 |                    p_waybill_number                                       |
 |                    p_fob_point                                            |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     15-OCT-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_compare_frt_cover(
             p_customer_trx_id   IN ra_customer_trx.customer_trx_id%type,
             p_ship_via          IN ra_customer_trx.ship_via%type,
             p_ship_date_actual  IN ra_customer_trx.ship_date_actual%type,
             p_waybill_number    IN ra_customer_trx.waybill_number%type,
             p_fob_point         IN ra_customer_trx.fob_point%type)
IS
  l_trx_rec    ra_customer_trx%rowtype;
BEGIN
      arp_util.debug('arp_ct_pkg.lock_compare_frt_cover()+');

     /*------------------------------------------------+
      |  Populate the header record with the values    |
      |  passed in as parameters.                      |
      +------------------------------------------------*/

      arp_ct_pkg.set_to_dummy(l_trx_rec);

      l_trx_rec.customer_trx_id  := p_customer_trx_id;
      l_trx_rec.ship_via         := p_ship_via;
      l_trx_rec.ship_date_actual := p_ship_date_actual;
      l_trx_rec.waybill_number   := p_waybill_number;
      l_trx_rec.fob_point        := p_fob_point;

     /*-----------------------------------------+
      |  Call the standard header table handler |
      +-----------------------------------------*/
arp_util.debug('calling lock compare p with p_customer_trx_id = ' || to_char(p_customer_trx_id));

      lock_compare_p( l_trx_rec, p_customer_trx_id);

      arp_util.debug('arp_ct_pkg.lock_compare_frt_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_ct_pkg.lock_compare_frt_cover()');

    arp_util.debug('----- parameters for lock_compare_frt_cover() ' ||
                   '-----');
    arp_util.debug('p_customer_trx_id      = ' || p_customer_trx_id );
    arp_util.debug('p_ship_via             = ' || p_ship_via );
    arp_util.debug('p_ship_date_actual     = ' || p_ship_date_actual );
    arp_util.debug('p_waybill_number       = ' || p_waybill_number );
    arp_util.debug('p_fob_point            = ' || p_fob_point );

    RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_cover                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a transaction header record and          |
 |    locks the transaction header.                                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_id					     |
 |                  p_trx_number					     |
 |                  p_posting_control_id				     |
 |                  p_ra_post_loop_number				     |
 |                  p_complete_flag					     |
 |                  p_initial_customer_trx_id				     |
 |                  p_previous_customer_trx_id				     |
 |                  p_related_customer_trx_id				     |
 |                  p_recurred_from_trx_number				     |
 |                  p_cust_trx_type_id					     |
 |                  p_batch_id						     |
 |                  p_batch_source_id					     |
 |                  p_agreement_id					     |
 |                  p_trx_date						     |
 |                  p_bill_to_customer_id				     |
 |                  p_bill_to_contact_id				     |
 |                  p_bill_to_site_use_id				     |
 |                  p_ship_to_customer_id				     |
 |                  p_ship_to_contact_id				     |
 |                  p_ship_to_site_use_id				     |
 |                  p_sold_to_customer_id				     |
 |                  p_sold_to_site_use_id				     |
 |                  p_sold_to_contact_id				     |
 |                  p_customer_reference				     |
 |                  p_customer_reference_date				     |
 |                  p_cr_method_for_installments			     |
 |                  p_credit_method_for_rules				     |
 |                  p_start_date_commitment				     |
 |                  p_end_date_commitment				     |
 |                  p_exchange_date					     |
 |                  p_exchange_rate					     |
 |                  p_exchange_rate_type				     |
 |                  p_customer_bank_account_id				     |
 |                  p_finance_charges					     |
 |                  p_fob_point						     |
 |                  p_comments						     |
 |                  p_internal_notes					     |
 |                  p_invoice_currency_code				     |
 |                  p_invoicing_rule_id					     |
 |                  p_last_printed_sequence_num				     |
 |                  p_orig_system_batch_name				     |
 |                  p_primary_salesrep_id				     |
 |                  p_printing_count					     |
 |                  p_printing_last_printed				     |
 |                  p_printing_option					     |
 |                  p_printing_original_date				     |
 |                  p_printing_pending					     |
 |                  p_purchase_order					     |
 |                  p_purchase_order_date				     |
 |                  p_purchase_order_revision				     |
 |                  p_receipt_method_id					     |
 |                  p_remit_to_address_id				     |
 |                  p_shipment_id					     |
 |                  p_ship_date_actual					     |
 |                  p_ship_via						     |
 |                  p_term_due_date					     |
 |                  p_term_id						     |
 |                  p_territory_id					     |
 |                  p_waybill_number					     |
 |                  p_status_trx					     |
 |                  p_reason_code					     |
 |                  p_doc_sequence_id					     |
 |                  p_doc_sequence_value				     |
 |                  p_paying_customer_id				     |
 |                  p_paying_site_use_id				     |
 |                  p_related_batch_source_id				     |
 |                  p_default_tax_exempt_flag				     |
 |                  p_created_from					     |
 |                  p_deflt_ussgl_trx_code_context			     |
 |                  p_deflt_ussgl_transaction_code			     |
 |                  p_old_trx_number                                         |
 |                  p_interface_header_context				     |
 |                  p_interface_header_attribute1			     |
 |                  p_interface_header_attribute2			     |
 |                  p_interface_header_attribute3			     |
 |                  p_interface_header_attribute4			     |
 |                  p_interface_header_attribute5			     |
 |                  p_interface_header_attribute6			     |
 |                  p_interface_header_attribute7			     |
 |                  p_interface_header_attribute8			     |
 |                  p_interface_header_attribute9			     |
 |                  p_interface_header_attribute10			     |
 |                  p_interface_header_attribute11			     |
 |                  p_interface_header_attribute12			     |
 |                  p_interface_header_attribute13			     |
 |                  p_interface_header_attribute14			     |
 |                  p_interface_header_attribute15			     |
 |                  p_attribute_category				     |
 |                  p_attribute1					     |
 |                  p_attribute2					     |
 |                  p_attribute3					     |
 |                  p_attribute4					     |
 |                  p_attribute5					     |
 |                  p_attribute6					     |
 |                  p_attribute7					     |
 |                  p_attribute8					     |
 |                  p_attribute9					     |
 |                  p_attribute10					     |
 |                  p_attribute11					     |
 |                  p_attribute12					     |
 |                  p_attribute13					     |
 |                  p_attribute14					     |
 |                  p_attribute15					     |
 |                                                                           |
 |              OUT:                                                         |
 |                  None                                                     |
 |          IN/ OUT:                                                         |
 |                  None                                                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-NOV-95  Charlie Tomberg  Created                                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_cover(
  p_customer_trx_id   IN ra_customer_trx.customer_trx_id%type,
  p_trx_number                IN ra_customer_trx.trx_number%type,
  p_posting_control_id        IN ra_customer_trx.posting_control_id%type,
  p_ra_post_loop_number       IN ra_customer_trx.ra_post_loop_number%type,
  p_complete_flag             IN ra_customer_trx.complete_flag%type,
  p_initial_customer_trx_id   IN ra_customer_trx.initial_customer_trx_id%type,
  p_previous_customer_trx_id  IN ra_customer_trx.previous_customer_trx_id%type,
  p_related_customer_trx_id   IN ra_customer_trx.related_customer_trx_id%type,
  p_recurred_from_trx_number  IN ra_customer_trx.recurred_from_trx_number%type,
  p_cust_trx_type_id          IN ra_customer_trx.cust_trx_type_id%type,
  p_batch_id                  IN ra_customer_trx.batch_id%type,
  p_batch_source_id           IN ra_customer_trx.batch_source_id%type,
  p_agreement_id              IN ra_customer_trx.agreement_id%type,
  p_trx_date                  IN ra_customer_trx.trx_date%type,
  p_bill_to_customer_id       IN ra_customer_trx.bill_to_customer_id%type,
  p_bill_to_contact_id        IN ra_customer_trx.bill_to_contact_id%type,
  p_bill_to_site_use_id       IN ra_customer_trx.bill_to_site_use_id%type,
  p_ship_to_customer_id       IN ra_customer_trx.ship_to_customer_id%type,
  p_ship_to_contact_id        IN ra_customer_trx.ship_to_contact_id%type,
  p_ship_to_site_use_id       IN ra_customer_trx.ship_to_site_use_id%type,
  p_sold_to_customer_id       IN ra_customer_trx.sold_to_customer_id%type,
  p_sold_to_site_use_id       IN ra_customer_trx.sold_to_site_use_id%type,
  p_sold_to_contact_id        IN ra_customer_trx.sold_to_contact_id%type,
  p_customer_reference        IN ra_customer_trx.customer_reference%type,
  p_customer_reference_date   IN ra_customer_trx.customer_reference_date%type,
  p_cr_method_for_installments IN
                          ra_customer_trx.credit_method_for_installments%type,
  p_credit_method_for_rules   IN ra_customer_trx.credit_method_for_rules%type,
  p_start_date_commitment     IN ra_customer_trx.start_date_commitment%type,
  p_end_date_commitment       IN ra_customer_trx.end_date_commitment%type,
  p_exchange_date             IN ra_customer_trx.exchange_date%type,
  p_exchange_rate             IN ra_customer_trx.exchange_rate%type,
  p_exchange_rate_type        IN ra_customer_trx.exchange_rate_type%type,
  p_customer_bank_account_id  IN ra_customer_trx.customer_bank_account_id%type,
  p_finance_charges           IN ra_customer_trx.finance_charges%type,
  p_fob_point                 IN ra_customer_trx.fob_point%type,
  p_comments                  IN ra_customer_trx.comments%type,
  p_internal_notes            IN ra_customer_trx.internal_notes%type,
  p_invoice_currency_code     IN ra_customer_trx.invoice_currency_code%type,
  p_invoicing_rule_id         IN ra_customer_trx.invoicing_rule_id%type,
  p_last_printed_sequence_num IN
                                ra_customer_trx.last_printed_sequence_num%type,
  p_orig_system_batch_name    IN ra_customer_trx.orig_system_batch_name%type,
  p_primary_salesrep_id       IN ra_customer_trx.primary_salesrep_id%type,
  p_printing_count            IN ra_customer_trx.printing_count%type,
  p_printing_last_printed     IN ra_customer_trx.printing_last_printed%type,
  p_printing_option           IN ra_customer_trx.printing_option%type,
  p_printing_original_date    IN ra_customer_trx.printing_original_date%type,
  p_printing_pending          IN ra_customer_trx.printing_pending%type,
  p_purchase_order            IN ra_customer_trx.purchase_order%type,
  p_purchase_order_date       IN ra_customer_trx.purchase_order_date%type,
  p_purchase_order_revision   IN ra_customer_trx.purchase_order_revision%type,
  p_receipt_method_id         IN ra_customer_trx.receipt_method_id%type,
  p_remit_to_address_id       IN ra_customer_trx.remit_to_address_id%type,
  p_shipment_id               IN ra_customer_trx.shipment_id%type,
  p_ship_date_actual          IN ra_customer_trx.ship_date_actual%type,
  p_ship_via                  IN ra_customer_trx.ship_via%type,
  p_term_due_date             IN ra_customer_trx.term_due_date%type,
  p_term_id                   IN ra_customer_trx.term_id%type,
  p_territory_id              IN ra_customer_trx.territory_id%type,
  p_waybill_number            IN ra_customer_trx.waybill_number%type,
  p_status_trx                IN ra_customer_trx.status_trx%type,
  p_reason_code               IN ra_customer_trx.reason_code%type,
  p_doc_sequence_id           IN ra_customer_trx.doc_sequence_id%type,
  p_doc_sequence_value        IN ra_customer_trx.doc_sequence_value%type,
  p_paying_customer_id        IN ra_customer_trx.paying_customer_id%type,
  p_paying_site_use_id        IN ra_customer_trx.paying_site_use_id%type,
  p_related_batch_source_id   IN ra_customer_trx.related_batch_source_id%type,
  p_default_tax_exempt_flag   IN ra_customer_trx.default_tax_exempt_flag%type,
  p_created_from              IN ra_customer_trx.created_from%type,
  p_deflt_ussgl_trx_code_context  IN
                           ra_customer_trx.default_ussgl_trx_code_context%type,
  p_deflt_ussgl_transaction_code  IN
                           ra_customer_trx.default_ussgl_transaction_code%type,
  p_old_trx_number            IN ra_customer_trx.old_trx_number%type,
  p_interface_header_context        IN
                           ra_customer_trx.interface_header_context%type,
  p_interface_header_attribute1     IN
                           ra_customer_trx.interface_header_attribute1%type,
  p_interface_header_attribute2     IN
                           ra_customer_trx.interface_header_attribute2%type,
  p_interface_header_attribute3     IN
                           ra_customer_trx.interface_header_attribute3%type,
  p_interface_header_attribute4     IN
                           ra_customer_trx.interface_header_attribute4%type,
  p_interface_header_attribute5     IN
                           ra_customer_trx.interface_header_attribute5%type,
  p_interface_header_attribute6     IN
                           ra_customer_trx.interface_header_attribute6%type,
  p_interface_header_attribute7     IN
                           ra_customer_trx.interface_header_attribute7%type,
  p_interface_header_attribute8     IN
                           ra_customer_trx.interface_header_attribute8%type,
  p_interface_header_attribute9     IN
                           ra_customer_trx.interface_header_attribute9%type,
  p_interface_header_attribute10    IN
                            ra_customer_trx.interface_header_attribute10%type,
  p_interface_header_attribute11    IN
                            ra_customer_trx.interface_header_attribute11%type,
  p_interface_header_attribute12    IN
                            ra_customer_trx.interface_header_attribute12%type,
  p_interface_header_attribute13    IN
                            ra_customer_trx.interface_header_attribute13%type,
  p_interface_header_attribute14    IN
                            ra_customer_trx.interface_header_attribute14%type,
  p_interface_header_attribute15    IN
                            ra_customer_trx.interface_header_attribute15%type,
  p_attribute_category              IN ra_customer_trx.attribute_category%type,
  p_attribute1                      IN ra_customer_trx.attribute1%type,
  p_attribute2                      IN ra_customer_trx.attribute2%type,
  p_attribute3                      IN ra_customer_trx.attribute3%type,
  p_attribute4                      IN ra_customer_trx.attribute4%type,
  p_attribute5                      IN ra_customer_trx.attribute5%type,
  p_attribute6                      IN ra_customer_trx.attribute6%type,
  p_attribute7                      IN ra_customer_trx.attribute7%type,
  p_attribute8                      IN ra_customer_trx.attribute8%type,
  p_attribute9                      IN ra_customer_trx.attribute9%type,
  p_attribute10                     IN ra_customer_trx.attribute10%type,
  p_attribute11                     IN ra_customer_trx.attribute11%type,
  p_attribute12                     IN ra_customer_trx.attribute12%type,
  p_attribute13                     IN ra_customer_trx.attribute13%type,
  p_attribute14                     IN ra_customer_trx.attribute14%type,
  p_attribute15                     IN ra_customer_trx.attribute15%type,
  p_legal_entity_id                 IN ra_customer_trx.legal_entity_id%type,
  p_payment_trxn_extension_id       IN ra_customer_trx.payment_trxn_extension_id%type,
  p_billing_date                    IN ra_customer_trx.billing_date%type)


IS

  l_trx_rec    ra_customer_trx%rowtype;

BEGIN
   arp_util.debug('arp_ct_pkg.lock_compare_cover()+');

  /*------------------------------------------------+
   |  Populate the header record with the values    |
   |  passed in as parameters.                      |
   +------------------------------------------------*/

   arp_ct_pkg.set_to_dummy(l_trx_rec);

   l_trx_rec.customer_trx_id                := p_customer_trx_id;
   l_trx_rec.trx_number                     := p_trx_number;

   --
   -- commented out NOCOPY posting_control_id, ra_post_loop_number so as to
   -- reduce the no of columns in the view
   --
   -- l_trx_rec.posting_control_id             := p_posting_control_id;
   -- l_trx_rec.ra_post_loop_number            := p_ra_post_loop_number;

   l_trx_rec.complete_flag                  := p_complete_flag;
   l_trx_rec.initial_customer_trx_id        := p_initial_customer_trx_id;
   l_trx_rec.previous_customer_trx_id       := p_previous_customer_trx_id;
   l_trx_rec.related_customer_trx_id        := p_related_customer_trx_id;
   l_trx_rec.recurred_from_trx_number       := p_recurred_from_trx_number;
   l_trx_rec.cust_trx_type_id               := p_cust_trx_type_id;
   l_trx_rec.batch_id                       := p_batch_id;
   l_trx_rec.batch_source_id                := p_batch_source_id;
   l_trx_rec.agreement_id                   := p_agreement_id;
   l_trx_rec.trx_date                       := p_trx_date;
   l_trx_rec.bill_to_customer_id            := p_bill_to_customer_id;
   l_trx_rec.bill_to_contact_id             := p_bill_to_contact_id;
   l_trx_rec.bill_to_site_use_id            := p_bill_to_site_use_id;
   l_trx_rec.ship_to_customer_id            := p_ship_to_customer_id;
   l_trx_rec.ship_to_contact_id             := p_ship_to_contact_id;
   l_trx_rec.ship_to_site_use_id            := p_ship_to_site_use_id;
   l_trx_rec.sold_to_customer_id            := p_sold_to_customer_id;
   l_trx_rec.sold_to_site_use_id            := p_sold_to_site_use_id;
   l_trx_rec.sold_to_contact_id             := p_sold_to_contact_id;
   l_trx_rec.customer_reference             := p_customer_reference;
   l_trx_rec.customer_reference_date        := p_customer_reference_date;
   l_trx_rec.credit_method_for_installments := p_cr_method_for_installments;
   l_trx_rec.credit_method_for_rules        := p_credit_method_for_rules;
   l_trx_rec.start_date_commitment          := p_start_date_commitment;
   l_trx_rec.end_date_commitment            := p_end_date_commitment;
   l_trx_rec.exchange_date                  := p_exchange_date;
   l_trx_rec.exchange_rate                  := p_exchange_rate;
   l_trx_rec.exchange_rate_type             := p_exchange_rate_type;
   l_trx_rec.customer_bank_account_id       := p_customer_bank_account_id;
   l_trx_rec.finance_charges                := p_finance_charges;
   l_trx_rec.fob_point                      := p_fob_point;
   l_trx_rec.comments                       := p_comments;
   l_trx_rec.internal_notes                 := p_internal_notes;
   l_trx_rec.invoice_currency_code          := p_invoice_currency_code;
   l_trx_rec.invoicing_rule_id              := p_invoicing_rule_id;
   l_trx_rec.last_printed_sequence_num      := p_last_printed_sequence_num;
   l_trx_rec.orig_system_batch_name         := p_orig_system_batch_name;
   l_trx_rec.primary_salesrep_id            := p_primary_salesrep_id;
   l_trx_rec.printing_count                 := p_printing_count;
   l_trx_rec.printing_last_printed          := p_printing_last_printed;
   l_trx_rec.printing_option                := p_printing_option;
   l_trx_rec.printing_original_date         := p_printing_original_date;
   -- l_trx_rec.printing_pending               := p_printing_pending;
   l_trx_rec.purchase_order                 := p_purchase_order;
   l_trx_rec.purchase_order_date            := p_purchase_order_date;
   l_trx_rec.purchase_order_revision        := p_purchase_order_revision;
   l_trx_rec.receipt_method_id              := p_receipt_method_id;
   l_trx_rec.remit_to_address_id            := p_remit_to_address_id;
   l_trx_rec.shipment_id                    := p_shipment_id;
   l_trx_rec.ship_date_actual               := p_ship_date_actual;
   l_trx_rec.ship_via                       := p_ship_via;
   l_trx_rec.term_id                        := p_term_id;
   l_trx_rec.territory_id                   := p_territory_id;
   l_trx_rec.waybill_number                 := p_waybill_number;
   l_trx_rec.status_trx                     := p_status_trx;
   l_trx_rec.reason_code                    := p_reason_code;
   l_trx_rec.doc_sequence_id                := p_doc_sequence_id;
   l_trx_rec.doc_sequence_value             := p_doc_sequence_value;
   l_trx_rec.paying_customer_id             := p_paying_customer_id;
   l_trx_rec.paying_site_use_id             := p_paying_site_use_id;
   l_trx_rec.related_batch_source_id        := p_related_batch_source_id;
   l_trx_rec.default_tax_exempt_flag        := p_default_tax_exempt_flag;
   l_trx_rec.created_from                   := p_created_from;
   l_trx_rec.default_ussgl_trx_code_context := p_deflt_ussgl_trx_code_context;
   l_trx_rec.default_ussgl_transaction_code := p_deflt_ussgl_transaction_code;
   l_trx_rec.old_trx_number                 := p_old_trx_number;
   l_trx_rec.interface_header_context       := p_interface_header_context;
   l_trx_rec.interface_header_attribute1    := p_interface_header_attribute1;
   l_trx_rec.interface_header_attribute2    := p_interface_header_attribute2;
   l_trx_rec.interface_header_attribute3    := p_interface_header_attribute3;
   l_trx_rec.interface_header_attribute4    := p_interface_header_attribute4;
   l_trx_rec.interface_header_attribute5    := p_interface_header_attribute5;
   l_trx_rec.interface_header_attribute6    := p_interface_header_attribute6;
   l_trx_rec.interface_header_attribute7    := p_interface_header_attribute7;
   l_trx_rec.interface_header_attribute8    := p_interface_header_attribute8;
   l_trx_rec.interface_header_attribute9    := p_interface_header_attribute9;
   l_trx_rec.interface_header_attribute10   := p_interface_header_attribute10;
   l_trx_rec.interface_header_attribute11   := p_interface_header_attribute11;
   l_trx_rec.interface_header_attribute12   := p_interface_header_attribute12;
   l_trx_rec.interface_header_attribute13   := p_interface_header_attribute13;
   l_trx_rec.interface_header_attribute14   := p_interface_header_attribute14;
   l_trx_rec.interface_header_attribute15   := p_interface_header_attribute15;
   l_trx_rec.attribute_category             := p_attribute_category;
   l_trx_rec.attribute1                     := p_attribute1;
   l_trx_rec.attribute2                     := p_attribute2;
   l_trx_rec.attribute3                     := p_attribute3;
   l_trx_rec.attribute4                     := p_attribute4;
   l_trx_rec.attribute5                     := p_attribute5;
   l_trx_rec.attribute6                     := p_attribute6;
   l_trx_rec.attribute7                     := p_attribute7;
   l_trx_rec.attribute8                     := p_attribute8;
   l_trx_rec.attribute9                     := p_attribute9;
   l_trx_rec.attribute10                    := p_attribute10;
   l_trx_rec.attribute11                    := p_attribute11;
   l_trx_rec.attribute12                    := p_attribute12;
   l_trx_rec.attribute13                    := p_attribute13;
   l_trx_rec.attribute14                    := p_attribute14;
   l_trx_rec.attribute15                    := p_attribute15;
   l_trx_rec.legal_entity_id                := p_legal_entity_id;
   /* PAYMENT_UPTAKE */
   l_trx_rec.payment_trxn_extension_id      := p_payment_trxn_extension_id;
   l_trx_rec.billing_date                   := p_billing_date;

  /*-----------------------------------------+
   |  Call the standard header table handler |
   +-----------------------------------------*/

   lock_compare_p( l_trx_rec, p_customer_trx_id);

   arp_util.debug('arp_ct_pkg.lock_compare_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_ct_pkg.lock_compare_cover()');

    arp_util.debug('----- parameters for lock_compare_cover() ' ||
                   '-----');
    arp_util.debug('p_customer_trx_id			= ' ||
                   TO_CHAR(p_customer_trx_id));
    arp_util.debug('p_trx_number			= ' ||
                   p_trx_number);
    arp_util.debug('p_posting_control_id		= ' ||
                   TO_CHAR(p_posting_control_id));
    arp_util.debug('p_ra_post_loop_number		= ' ||
                   p_ra_post_loop_number);
    arp_util.debug('p_complete_flag			= ' ||
                   p_complete_flag);
    arp_util.debug('p_initial_customer_trx_id		= ' ||
                   TO_CHAR(p_initial_customer_trx_id));
    arp_util.debug('p_previous_customer_trx_id		= ' ||
                   TO_CHAR(p_previous_customer_trx_id));
    arp_util.debug('p_related_customer_trx_id		= ' ||
                   TO_CHAR(p_related_customer_trx_id));
    arp_util.debug('p_recurred_from_trx_number		= ' ||
                   p_recurred_from_trx_number);
    arp_util.debug('p_cust_trx_type_id			= ' ||
                   TO_CHAR(p_cust_trx_type_id));
    arp_util.debug('p_batch_id				= ' ||
                   TO_CHAR(p_batch_id));
    arp_util.debug('p_batch_source_id			= ' ||
                   TO_CHAR(p_batch_source_id));
    arp_util.debug('p_agreement_id			= ' ||
                   TO_CHAR(p_agreement_id));
    arp_util.debug('p_trx_date				= ' ||
                   p_trx_date);
    arp_util.debug('p_bill_to_customer_id		= ' ||
                   TO_CHAR(p_bill_to_customer_id));
    arp_util.debug('p_bill_to_contact_id		= ' ||
                   TO_CHAR(p_bill_to_contact_id));
    arp_util.debug('p_bill_to_site_use_id		= ' ||
                   TO_CHAR(p_bill_to_site_use_id));
    arp_util.debug('p_ship_to_customer_id		= ' ||
                   TO_CHAR(p_ship_to_customer_id));
    arp_util.debug('p_ship_to_contact_id		= ' ||
                   TO_CHAR(p_ship_to_contact_id));
    arp_util.debug('p_ship_to_site_use_id		= ' ||
                   TO_CHAR(p_ship_to_site_use_id));
    arp_util.debug('p_sold_to_customer_id		= ' ||
                   TO_CHAR(p_sold_to_customer_id));
    arp_util.debug('p_sold_to_site_use_id		= ' ||
                   TO_CHAR(p_sold_to_site_use_id));
    arp_util.debug('p_sold_to_contact_id		= ' ||
                   TO_CHAR(p_sold_to_contact_id));
    arp_util.debug('p_customer_reference		= ' ||
                   p_customer_reference);
    arp_util.debug('p_customer_reference_date		= ' ||
                   p_customer_reference_date);
    arp_util.debug('p_cr_method_for_installments	= ' ||
                   p_cr_method_for_installments);
    arp_util.debug('p_credit_method_for_rules		= ' ||
                   p_credit_method_for_rules);
    arp_util.debug('p_start_date_commitment		= ' ||
                   p_start_date_commitment);
    arp_util.debug('p_end_date_commitment		= ' ||
                   p_end_date_commitment);
    arp_util.debug('p_exchange_date			= ' ||
                   p_exchange_date);
    arp_util.debug('p_exchange_rate			= ' ||
                   p_exchange_rate);
    arp_util.debug('p_exchange_rate_type		= ' ||
                   p_exchange_rate_type);
    arp_util.debug('p_customer_bank_account_id		= ' ||
                   TO_CHAR(p_customer_bank_account_id));
    arp_util.debug('p_finance_charges			= ' ||
                   p_finance_charges);
    arp_util.debug('p_fob_point				= ' ||
                   p_fob_point);
    arp_util.debug('p_comments				= ' ||
                   p_comments);
    arp_util.debug('p_internal_notes			= ' ||
                   p_internal_notes);
    arp_util.debug('p_invoice_currency_code		= ' ||
                   p_invoice_currency_code);
    arp_util.debug('p_invoicing_rule_id			= ' ||
                   TO_CHAR(p_invoicing_rule_id));
    arp_util.debug('p_last_printed_sequence_num		= ' ||
                   p_last_printed_sequence_num);
    arp_util.debug('p_orig_system_batch_name		= ' ||
                   p_orig_system_batch_name);
    arp_util.debug('p_primary_salesrep_id		= ' ||
                   TO_CHAR(p_primary_salesrep_id));
    arp_util.debug('p_printing_count			= ' ||
                   p_printing_count);
    arp_util.debug('p_printing_last_printed		= ' ||
                   p_printing_last_printed);
    arp_util.debug('p_printing_option			= ' ||
                   p_printing_option);
    arp_util.debug('p_printing_original_date		= ' ||
                   p_printing_original_date);
    arp_util.debug('p_printing_pending			= ' ||
                   p_printing_pending);
    arp_util.debug('p_purchase_order			= ' ||
                   p_purchase_order);
    arp_util.debug('p_purchase_order_date		= ' ||
                   p_purchase_order_date);
    arp_util.debug('p_purchase_order_revision		= ' ||
                   p_purchase_order_revision);
    arp_util.debug('p_receipt_method_id			= ' ||
                   TO_CHAR(p_receipt_method_id));
    arp_util.debug('p_remit_to_address_id		= ' ||
                   TO_CHAR(p_remit_to_address_id));
    arp_util.debug('p_shipment_id			= ' ||
                   TO_CHAR(p_shipment_id));
    arp_util.debug('p_ship_date_actual			= ' ||
                   p_ship_date_actual);
    arp_util.debug('p_ship_via				= ' ||
                   p_ship_via);
    arp_util.debug('p_term_due_date			= ' ||
                   p_term_due_date);
    arp_util.debug('p_term_id				= ' ||
                   TO_CHAR(p_term_id));
    arp_util.debug('p_territory_id			= ' ||
                   TO_CHAR(p_territory_id));
    arp_util.debug('p_waybill_number			= ' ||
                   p_waybill_number);
    arp_util.debug('p_status_trx			= ' ||
                   p_status_trx);
    arp_util.debug('p_reason_code			= ' ||
                   p_reason_code);
    arp_util.debug('p_doc_sequence_id			= ' ||
                   TO_CHAR(p_doc_sequence_id));
    arp_util.debug('p_doc_sequence_value		= ' ||
                   p_doc_sequence_value);
    arp_util.debug('p_paying_customer_id		= ' ||
                   TO_CHAR(p_paying_customer_id));
    arp_util.debug('p_paying_site_use_id		= ' ||
                   TO_CHAR(p_paying_site_use_id));
    arp_util.debug('p_related_batch_source_id		= ' ||
                   TO_CHAR(p_related_batch_source_id));
    arp_util.debug('p_default_tax_exempt_flag		= ' ||
                   p_default_tax_exempt_flag);
    arp_util.debug('p_created_from			= ' ||
                   p_created_from);
    arp_util.debug('p_deflt_ussgl_trx_code_context	= ' ||
                   p_deflt_ussgl_trx_code_context);
    arp_util.debug('p_deflt_ussgl_transaction_code	= ' ||
                   p_deflt_ussgl_transaction_code);
    arp_util.debug('p_old_trx_number                    = ' ||
                   p_old_trx_number);
    arp_util.debug('p_interface_header_context		= ' ||
                   p_interface_header_context);
    arp_util.debug('p_interface_header_attribute1	= ' ||
                   p_interface_header_attribute1);
    arp_util.debug('p_interface_header_attribute2	= ' ||
                   p_interface_header_attribute2);
    arp_util.debug('p_interface_header_attribute3	= ' ||
                   p_interface_header_attribute3);
    arp_util.debug('p_interface_header_attribute4	= ' ||
                   p_interface_header_attribute4);
    arp_util.debug('p_interface_header_attribute5	= ' ||
                   p_interface_header_attribute5);
    arp_util.debug('p_interface_header_attribute6	= ' ||
                   p_interface_header_attribute6);
    arp_util.debug('p_interface_header_attribute7	= ' ||
                  p_interface_header_attribute7);
    arp_util.debug('p_interface_header_attribute8	= ' ||
                   p_interface_header_attribute8);
    arp_util.debug('p_interface_header_attribute9	= ' ||
                   p_interface_header_attribute9);
    arp_util.debug('p_interface_header_attribute10	= ' ||
                   p_interface_header_attribute10);
    arp_util.debug('p_interface_header_attribute11	= ' ||
                   p_interface_header_attribute11);
    arp_util.debug('p_interface_header_attribute12	= ' ||
                   p_interface_header_attribute12);
    arp_util.debug('p_interface_header_attribute13	= ' ||
                   p_interface_header_attribute13);
    arp_util.debug('p_interface_header_attribute14	= ' ||
                   p_interface_header_attribute14);
    arp_util.debug('p_interface_header_attribute15	= ' ||
                   p_interface_header_attribute15);
    arp_util.debug('p_attribute_category		= ' ||
                   p_attribute_category);
    arp_util.debug('p_attribute1			= ' ||
                   p_attribute1);
    arp_util.debug('p_attribute2			= ' ||
                   p_attribute2);
    arp_util.debug('p_attribute3			= ' ||
                   p_attribute3);
    arp_util.debug('p_attribute4			= ' ||
                   p_attribute4);
    arp_util.debug('p_attribute5			= ' ||
                   p_attribute5);
    arp_util.debug('p_attribute6			= ' ||
                   p_attribute6);
    arp_util.debug('p_attribute7			= ' ||
                   p_attribute7);
    arp_util.debug('p_attribute8			= ' ||
                   p_attribute8);
    arp_util.debug('p_attribute9			= ' ||
                   p_attribute9);
    arp_util.debug('p_attribute10			= ' ||
                   p_attribute10);
    arp_util.debug('p_attribute11			= ' ||
                   p_attribute11);
    arp_util.debug('p_attribute12			= ' ||
                   p_attribute12);
    arp_util.debug('p_attribute13			= ' ||
                   p_attribute13);
    arp_util.debug('p_attribute14			= ' ||
                   p_attribute14);
    arp_util.debug('p_attribute15			= ' ||
                   p_attribute15);

    RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_text_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns the value of the AR_TEXT_DUMMY constant.        |
 |    									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : value of AR_TEXT_DUMMY                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     18-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_text_dummy(p_null IN NUMBER DEFAULT null) RETURN varchar2 IS

BEGIN

    arp_util.debug('arp_ct_pkg.get_text_dummy()+');

    arp_util.debug('arp_ct_pkg.get_text_dummy()-');

    return(AR_TEXT_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.get_text_dummy()');
        RAISE;

END;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_flag_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns the value of the AR_FLAG_DUMMY constant.        |
 |    									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : value of AR_FLAG_DUMMY                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_flag_dummy(p_null IN NUMBER DEFAULT null) RETURN varchar2 IS

BEGIN

    arp_util.debug('arp_ct_pkg.get_flag_dummy()+');

    arp_util.debug('arp_ct_pkg.get_flag_dummy()-');

    return(AR_FLAG_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.get_flag_dummy()');
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_number_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns the value of the AR_NUMBER DUMMY constant.      |
 |    									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : value of AR_NUMBER_DUMMY                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number IS

BEGIN

    arp_util.debug('arp_ct_pkg.get_number_dummy()+');

    arp_util.debug('arp_ct_pkg.get_number_dummy()-');

    return(AR_NUMBER_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.get_number_dummy()');
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_date_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns the value of the AR_DATE_DUMMY constant.        |
 |    									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : value of AR_DATE_DUMMY                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_date_dummy(p_null IN NUMBER DEFAULT null) RETURN date IS

BEGIN

    arp_util.debug('arp_ct_pkg.get_date_dummy()+');

    arp_util.debug('arp_ct_pkg.get_date_dummy()-');

    return(AR_DATE_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.get_date_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_tax				          		     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_customer_trx row identified by the       |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the row to update	     |
 |                    p_trx_rec       - contains the new column values       |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_trx_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     20-DEC-96  Vikas Mahajan     Created                                  |
 |     13-AUG-97  Govind Jayanth    New parameter to check enforcement of tax|
 |                                  from Natural Account. If TRUE, call the  |
 |                                  new 'get_default_tax_code()' to default  |
 |                                  tax code from GL natural account.        |
 |     21-AUG-02 B Chatterjee       Bug2503883 Changed the nvl value of      |
 |                                  autotax to 'N'                           |
 |     07-FEB-07 M Raymond       5594741 - Updated parameters on
 |                                  get_default_tax_classification to
 |                                  correctly differentiate between org
 |                                  and warehouse_id
 +===========================================================================*/


PROCEDURE update_tax( p_ship_to_site_use_id IN ra_customer_trx.ship_to_site_use_id%type,
		      p_bill_to_site_use_id IN ra_customer_trx.bill_to_site_use_id%type,
		      p_trx_date IN ra_customer_trx.trx_date%type,
		      p_cust_trx_type_id IN ra_customer_trx.cust_trx_type_id%type,
                      p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type,
                      P_TAX_AFFECT_FLAG in varchar2,
                      p_enforce_nat_acc_flag IN BOOLEAN) IS

CURSOR  update_header_lines IS
        SELECT customer_trx_line_id,
               inventory_item_id,
               memo_line_id,
               warehouse_id
        FROM   ra_customer_trx_lines
        WHERE  customer_trx_id = p_customer_trx_id
        AND    line_type = 'LINE';--3872371

l_tax_code            VARCHAR2(50);
l_vat_tax_id          NUMBER ;
l_organization_id     NUMBER ;
l_warehouse_id        NUMBER;
l_sob_id              NUMBER;
l_customer_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%type;
l_inventory_item_id     ra_customer_trx_lines.inventory_item_id%type;
l_autotax              ra_customer_trx_lines.autotax%type;
l_amt_incl_tax_flag        ar_vat_tax.amount_includes_tax_flag%type;
l_amt_incl_tax_override    ar_vat_tax.amount_includes_tax_override%type;
/* bug fix : 1070949 */
l_tax_calculation_flag    varchar2(1);

l_event_class_code   VARCHAR2(80);   /* Etax */
l_event_type_code    VARCHAR2(80);   /* Etax */
l_success BOOLEAN;

BEGIN

   arp_util.debug('arp_ct_pkg.update_tax()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

  /*------------------------------------------------+
   |  Call Tax API to get the value of vat_tax_id   |
   +------------------------------------------------*/

   l_warehouse_id := oe_profile.value('SO_ORGANIZATION_ID');
   l_organization_id := arp_global.sysparam.org_id;
   l_sob_id          := arp_global.set_of_books_id;

   arp_util.debug('default warehouse_id  ' || to_char(l_warehouse_id));
   arp_util.debug('ship_to_site_use_id   ' || to_char(p_ship_to_site_use_id ));
   arp_util.debug('bill_to_site_use_id   ' || to_char(p_bill_to_site_use_id ));
   arp_util.debug('organization_id       ' || to_char(l_organization_id));
   arp_util.debug('set_of_books_id       ' || to_char(arp_global.set_of_books_id ));
   arp_util.debug('trx_date              ' || to_char(p_trx_date ));
   arp_util.debug('p_affect_tax_flag     ' || p_tax_affect_flag);
   l_autotax := 'Y';

/* bug fix : 1070949 */
   BEGIN
      SELECT tax_calculation_flag
      INTO l_tax_calculation_flag
      FROM RA_CUST_TRX_TYPES
      WHERE cust_trx_type_id = p_cust_trx_type_id ;
   EXCEPTION
      WHEN OTHERS THEN
          arp_util.debug('arp_ct_pkd.update_tax - exception for select');
   END;

   l_success := arp_etax_util.get_event_information(
                      p_customer_trx_id => p_customer_trx_id,
                      p_action => 'UPDATE',
                      p_event_class_code => l_event_class_code,
                      p_event_type_code => l_event_type_code);


   IF (p_enforce_nat_acc_flag)
   THEN
	   /*
            * Enforce tax code from GL natural account for all lines
            * including those with manually updated tax codes.
            */

	   For line in update_header_lines
	   LOOP
	     BEGIN

                /*------------------------------------------------+
                 | ETax:  get the event_class_code and then call  |
                 | get_default_tax_classification to get the      |
                 | tax code                                       |
                 +------------------------------------------------*/


                   arp_etax_util.get_default_tax_classification(
                           p_ship_to_site_use_id => p_ship_to_site_use_id,
                           p_bill_to_site_use_id => p_bill_to_site_use_id,
                           p_inv_item_id         => line.inventory_item_id,
                           p_org_id              => l_organization_id,
                           p_warehouse_id        =>
                               NVL(line.warehouse_id, l_warehouse_id),
                           p_sob_id              => l_sob_id,
                           p_trx_date            => p_trx_date,
                           p_trx_type_id         => p_cust_trx_type_id,
                           p_cust_trx_id         => p_customer_trx_id,
                           p_cust_trx_line_id    => line.customer_trx_line_id,
                           p_customer_id =>  NULL,
                           p_memo_line_id        => line.memo_line_id,
                           p_entity_code         => 'RA_CUSTOMER_TRX',
                           p_event_class_code    => l_event_class_code,
                           p_function_short_name => 'GL_ACCT_FIXUP',
                           p_tax_classification_code => l_tax_code );

		 arp_util.debug('line.inventory_item_id  ' ||
                                to_char(line.inventory_item_id ));
                 arp_util.debug('line.warehouse_id ' ||
                                to_char(line.warehouse_id));
		 arp_util.debug('returned tax_code/classification:  ' || l_tax_code);

	      EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		   l_autotax    := 'Y';
                   l_tax_code := NULL;
	      END;

	      IF l_tax_code IS NOT NULL
	      THEN
		---  UPDATE RA_CUSTOMER_TRX_LINES with  new
                ---  tax_code and autotax='Y'
		 update ra_customer_trx_lines
                 set tax_classification_code = l_tax_code,
		     autotax    = l_autotax
                 where customer_trx_line_id = line.customer_trx_line_id;
	      END IF;
	   END LOOP;
   ELSE
   	  /* Existing logic */
	   For line in update_header_lines
	   LOOP
	     BEGIN
		/*------------------------------------------------+
		 |  Call Tax API to get the value of vat_tax_id   |
		 +------------------------------------------------*/

               IF (l_tax_calculation_flag = 'Y') THEN
                   arp_etax_util.get_default_tax_classification(
                           p_ship_to_site_use_id => p_ship_to_site_use_id,
                           p_bill_to_site_use_id => p_bill_to_site_use_id,
                           p_inv_item_id         => line.inventory_item_id,
                           p_org_id              => l_organization_id,
                           p_sob_id              => l_sob_id,
                           p_warehouse_id        =>
                             NVL(line.warehouse_id, l_warehouse_id),
                           p_trx_date            => p_trx_date,
                           p_trx_type_id         => p_cust_trx_type_id,
                           p_cust_trx_id         => p_customer_trx_id,
                           p_cust_trx_line_id    => line.customer_trx_line_id,
                           p_customer_id         =>  NULL,
                           p_memo_line_id        => line.memo_line_id,
                           p_entity_code         => 'RA_CUSTOMER_TRX',
                           p_event_class_code    => l_event_class_code,
                           p_function_short_name => 'ACCT_DIST',
                           p_tax_classification_code => l_tax_code );
               ELSE
                   l_tax_code := NULL;
                   l_autotax    := 'Y';
               END IF;

		 arp_util.debug('line.inventory_item_id  ' ||
                                to_char(line.inventory_item_id ));
                 arp_util.debug('line.warehouse_id       ' ||
                                to_char(line.warehouse_id));
		 arp_util.debug('returned tax_code/classif:  ' || l_tax_code);

	      EXCEPTION
	      WHEN NO_DATA_FOUND THEN
                  l_tax_code := NULL;
		  l_autotax    := 'Y';
	      END;

		 update ra_customer_trx_lines
                   set tax_classification_code = l_tax_code,
		       autotax    = l_autotax
		 where customer_trx_line_id = line.customer_trx_line_id;

	   END LOOP;
   END IF;
   arp_util.debug('arp_ct_pkg.update_tax()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ct_pkg.update_tax()');
        RAISE;
END ;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_cover      (Overloaded)                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a transaction header record and          |
 |    locks the transaction header.                                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_id				      	     |
 |                  p_trx_number					      	     |
 |                  p_posting_control_id				     		     |
 |                  p_ra_post_loop_number				     		     |
 |                  p_complete_flag					     		     |
 |                  p_initial_customer_trx_id			     		     |
 |                  p_previous_customer_trx_id			     		     |
 |                  p_related_customer_trx_id			     		     |
 |                  p_recurred_from_trx_number			     		     |
 |                  p_cust_trx_type_id				     		     |
 |                  p_batch_id					     		     |
 |                  p_batch_source_id	     			     		     |
 |                  p_agreement_id					     		     |
 |                  p_trx_date					     		     |
 |                  p_bill_to_customer_id				     |
 |                  p_bill_to_contact_id				     |
 |                  p_bill_to_site_use_id				     |
 |                  p_ship_to_customer_id				     |
 |                  p_ship_to_contact_id				     |
 |                  p_ship_to_site_use_id				     |
 |                  p_sold_to_customer_id				     |
 |                  p_sold_to_site_use_id				     |
 |                  p_sold_to_contact_id				     |
 |                  p_customer_reference				     |
 |                  p_customer_reference_date				     |
 |                  p_cr_method_for_installments			     |
 |                  p_credit_method_for_rules				     |
 |                  p_start_date_commitment				     |
 |                  p_end_date_commitment				     |
 |                  p_exchange_date					     |
 |                  p_exchange_rate					     |
 |                  p_exchange_rate_type				     |
 |                  p_customer_bank_account_id				     |
 |                  p_finance_charges					     |
 |                  p_fob_point						     |
 |                  p_comments						     |
 |                  p_internal_notes					     |
 |                  p_invoice_currency_code				     |
 |                  p_invoicing_rule_id					     |
 |                  p_last_printed_sequence_num				     |
 |                  p_orig_system_batch_name				     |
 |                  p_primary_salesrep_id				     |
 |                  p_printing_count					     |
 |                  p_printing_last_printed				     |
 |                  p_printing_option					     |
 |                  p_printing_original_date				     |
 |                  p_printing_pending					     |
 |                  p_purchase_order					     |
 |                  p_purchase_order_date				     |
 |                  p_purchase_order_revision				     |
 |                  p_receipt_method_id					     |
 |                  p_remit_to_address_id				     |
 |                  p_shipment_id					     |
 |                  p_ship_date_actual					     |
 |                  p_ship_via						     |
 |                  p_term_due_date					     |
 |                  p_term_id						     |
 |                  p_territory_id					     |
 |                  p_waybill_number					     |
 |                  p_status_trx					     |
 |                  p_reason_code					     |
 |                  p_doc_sequence_id					     |
 |                  p_doc_sequence_value				     |
 |                  p_paying_customer_id				     |
 |                  p_paying_site_use_id				     |
 |                  p_related_batch_source_id				     |
 |                  p_default_tax_exempt_flag				     |
 |                  p_created_from					     |
 |                  p_deflt_ussgl_trx_code_context			     |
 |                  p_deflt_ussgl_transaction_code			     |
 |                  p_old_trx_number                                         |
 |                  p_interface_header_context				     |
 |                  p_interface_header_attribute1			     |
 |                  p_interface_header_attribute2			     |
 |                  p_interface_header_attribute3			     |
 |                  p_interface_header_attribute4			     |
 |                  p_interface_header_attribute5			     |
 |                  p_interface_header_attribute6			     |
 |                  p_interface_header_attribute7			     |
 |                  p_interface_header_attribute8			     |
 |                  p_interface_header_attribute9			     |
 |                  p_interface_header_attribute10			     |
 |                  p_interface_header_attribute11			     |
 |                  p_interface_header_attribute12			     |
 |                  p_interface_header_attribute13			     |
 |                  p_interface_header_attribute14			     |
 |                  p_interface_header_attribute15			     |
 |                  p_attribute_category				           |
 |                  p_attribute1					           |
 |                  p_attribute2					           |
 |                  p_attribute3					           |
 |                  p_attribute4					           |
 |                  p_attribute5					           |
 |                  p_attribute6					           |
 |                  p_attribute7					           |
 |                  p_attribute8					           |
 |                  p_attribute9					           |
 |                  p_attribute10					           |
 |                  p_attribute11					           |
 |                  p_attribute12					           |
 |                  p_attribute13					           |
 |                  p_attribute14					           |
 |                  p_attribute15					           |
 |                  p_global_attribute_category				           |
 |                  p_global_attribute1					           |
 |                  p_global_attribute2					           |
 |                  p_global_attribute3					           |
 |                  p_global_attribute4					           |
 |                  p_global_attribute5					           |
 |                  p_global_attribute6					           |
 |                  p_global_attribute7					           |
 |                  p_global_attribute8					           |
 |                  p_global_attribute9					           |
 |                  p_global_attribute10					           |
 |                  p_global_attribute11					           |
 |                  p_global_attribute12					           |
 |                  p_global_attribute13					           |
 |                  p_global_attribute14					           |
 |                  p_global_attribute15					           |
 |                  p_global_attribute16					           |
 |                  p_global_attribute17					           |
 |                  p_global_attribute18					           |
 |                  p_global_attribute19					           |
 |                  p_global_attribute20					           |
 |                  p_global_attribute21					           |
 |                  p_global_attribute22					           |
 |                  p_global_attribute23					           |
 |                  p_global_attribute24					           |
 |                  p_global_attribute25					           |
 |                  p_global_attribute26					           |
 |                  p_global_attribute27					           |
 |                  p_global_attribute28					           |
 |                  p_global_attribute29					           |
 |                  p_global_attribute30					           |
 |                                                                           |
 |              OUT:                                                         |
 |                  None                                                     |
 |          IN/ OUT:                                                         |
 |                  None                                                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     20-Jun-2002  Sahana      Created for Bug2427456. Overloaded version.  |
 |                              Global parameters are also passed.           |
 +===========================================================================*/

PROCEDURE lock_compare_cover(
  p_customer_trx_id   IN ra_customer_trx.customer_trx_id%type,
  p_trx_number                IN ra_customer_trx.trx_number%type,
  p_posting_control_id        IN ra_customer_trx.posting_control_id%type,
  p_ra_post_loop_number       IN ra_customer_trx.ra_post_loop_number%type,
  p_complete_flag             IN ra_customer_trx.complete_flag%type,
  p_initial_customer_trx_id   IN ra_customer_trx.initial_customer_trx_id%type,
  p_previous_customer_trx_id  IN ra_customer_trx.previous_customer_trx_id%type,
  p_related_customer_trx_id   IN ra_customer_trx.related_customer_trx_id%type,
  p_recurred_from_trx_number  IN ra_customer_trx.recurred_from_trx_number%type,
  p_cust_trx_type_id          IN ra_customer_trx.cust_trx_type_id%type,
  p_batch_id                  IN ra_customer_trx.batch_id%type,
  p_batch_source_id           IN ra_customer_trx.batch_source_id%type,
  p_agreement_id              IN ra_customer_trx.agreement_id%type,
  p_trx_date                  IN ra_customer_trx.trx_date%type,
  p_bill_to_customer_id       IN ra_customer_trx.bill_to_customer_id%type,
  p_bill_to_contact_id        IN ra_customer_trx.bill_to_contact_id%type,
  p_bill_to_site_use_id       IN ra_customer_trx.bill_to_site_use_id%type,
  p_ship_to_customer_id       IN ra_customer_trx.ship_to_customer_id%type,
  p_ship_to_contact_id        IN ra_customer_trx.ship_to_contact_id%type,
  p_ship_to_site_use_id       IN ra_customer_trx.ship_to_site_use_id%type,
  p_sold_to_customer_id       IN ra_customer_trx.sold_to_customer_id%type,
  p_sold_to_site_use_id       IN ra_customer_trx.sold_to_site_use_id%type,
  p_sold_to_contact_id        IN ra_customer_trx.sold_to_contact_id%type,
  p_customer_reference        IN ra_customer_trx.customer_reference%type,
  p_customer_reference_date   IN ra_customer_trx.customer_reference_date%type,
  p_cr_method_for_installments IN
                          ra_customer_trx.credit_method_for_installments%type,
  p_credit_method_for_rules   IN ra_customer_trx.credit_method_for_rules%type,
  p_start_date_commitment     IN ra_customer_trx.start_date_commitment%type,
  p_end_date_commitment       IN ra_customer_trx.end_date_commitment%type,
  p_exchange_date             IN ra_customer_trx.exchange_date%type,
  p_exchange_rate             IN ra_customer_trx.exchange_rate%type,
  p_exchange_rate_type        IN ra_customer_trx.exchange_rate_type%type,
  p_customer_bank_account_id  IN ra_customer_trx.customer_bank_account_id%type,
  p_finance_charges           IN ra_customer_trx.finance_charges%type,
  p_fob_point                 IN ra_customer_trx.fob_point%type,
  p_comments                  IN ra_customer_trx.comments%type,
  p_internal_notes            IN ra_customer_trx.internal_notes%type,
  p_invoice_currency_code     IN ra_customer_trx.invoice_currency_code%type,
  p_invoicing_rule_id         IN ra_customer_trx.invoicing_rule_id%type,
  p_last_printed_sequence_num IN
                                ra_customer_trx.last_printed_sequence_num%type,
  p_orig_system_batch_name    IN ra_customer_trx.orig_system_batch_name%type,
  p_primary_salesrep_id       IN ra_customer_trx.primary_salesrep_id%type,
  p_printing_count            IN ra_customer_trx.printing_count%type,
  p_printing_last_printed     IN ra_customer_trx.printing_last_printed%type,
  p_printing_option           IN ra_customer_trx.printing_option%type,
  p_printing_original_date    IN ra_customer_trx.printing_original_date%type,
  p_printing_pending          IN ra_customer_trx.printing_pending%type,
  p_purchase_order            IN ra_customer_trx.purchase_order%type,
  p_purchase_order_date       IN ra_customer_trx.purchase_order_date%type,
  p_purchase_order_revision   IN ra_customer_trx.purchase_order_revision%type,
  p_receipt_method_id         IN ra_customer_trx.receipt_method_id%type,
  p_remit_to_address_id       IN ra_customer_trx.remit_to_address_id%type,
  p_shipment_id               IN ra_customer_trx.shipment_id%type,
  p_ship_date_actual          IN ra_customer_trx.ship_date_actual%type,
  p_ship_via                  IN ra_customer_trx.ship_via%type,
  p_term_due_date             IN ra_customer_trx.term_due_date%type,
  p_term_id                   IN ra_customer_trx.term_id%type,
  p_territory_id              IN ra_customer_trx.territory_id%type,
  p_waybill_number            IN ra_customer_trx.waybill_number%type,
  p_status_trx                IN ra_customer_trx.status_trx%type,
  p_reason_code               IN ra_customer_trx.reason_code%type,
  p_doc_sequence_id           IN ra_customer_trx.doc_sequence_id%type,
  p_doc_sequence_value        IN ra_customer_trx.doc_sequence_value%type,
  p_paying_customer_id        IN ra_customer_trx.paying_customer_id%type,
  p_paying_site_use_id        IN ra_customer_trx.paying_site_use_id%type,
  p_related_batch_source_id   IN ra_customer_trx.related_batch_source_id%type,
  p_default_tax_exempt_flag   IN ra_customer_trx.default_tax_exempt_flag%type,
  p_created_from              IN ra_customer_trx.created_from%type,
  p_deflt_ussgl_trx_code_context  IN
                           ra_customer_trx.default_ussgl_trx_code_context%type,
  p_deflt_ussgl_transaction_code  IN
                           ra_customer_trx.default_ussgl_transaction_code%type,
  p_old_trx_number            IN ra_customer_trx.old_trx_number%type,
  p_interface_header_context        IN
                           ra_customer_trx.interface_header_context%type,
  p_interface_header_attribute1     IN
                           ra_customer_trx.interface_header_attribute1%type,
  p_interface_header_attribute2     IN
                           ra_customer_trx.interface_header_attribute2%type,
  p_interface_header_attribute3     IN
                           ra_customer_trx.interface_header_attribute3%type,
  p_interface_header_attribute4     IN
                           ra_customer_trx.interface_header_attribute4%type,
  p_interface_header_attribute5     IN
                           ra_customer_trx.interface_header_attribute5%type,
  p_interface_header_attribute6     IN
                           ra_customer_trx.interface_header_attribute6%type,
  p_interface_header_attribute7     IN
                           ra_customer_trx.interface_header_attribute7%type,
  p_interface_header_attribute8     IN
                           ra_customer_trx.interface_header_attribute8%type,
  p_interface_header_attribute9     IN
                           ra_customer_trx.interface_header_attribute9%type,
  p_interface_header_attribute10    IN
                            ra_customer_trx.interface_header_attribute10%type,
  p_interface_header_attribute11    IN
                            ra_customer_trx.interface_header_attribute11%type,
  p_interface_header_attribute12    IN
                            ra_customer_trx.interface_header_attribute12%type,
  p_interface_header_attribute13    IN
                            ra_customer_trx.interface_header_attribute13%type,
  p_interface_header_attribute14    IN
                            ra_customer_trx.interface_header_attribute14%type,
  p_interface_header_attribute15    IN
                            ra_customer_trx.interface_header_attribute15%type,
  p_attribute_category              IN ra_customer_trx.attribute_category%type,
  p_attribute1                      IN ra_customer_trx.attribute1%type,
  p_attribute2                      IN ra_customer_trx.attribute2%type,
  p_attribute3                      IN ra_customer_trx.attribute3%type,
  p_attribute4                      IN ra_customer_trx.attribute4%type,
  p_attribute5                      IN ra_customer_trx.attribute5%type,
  p_attribute6                      IN ra_customer_trx.attribute6%type,
  p_attribute7                      IN ra_customer_trx.attribute7%type,
  p_attribute8                      IN ra_customer_trx.attribute8%type,
  p_attribute9                      IN ra_customer_trx.attribute9%type,
  p_attribute10                     IN ra_customer_trx.attribute10%type,
  p_attribute11                     IN ra_customer_trx.attribute11%type,
  p_attribute12                     IN ra_customer_trx.attribute12%type,
  p_attribute13                     IN ra_customer_trx.attribute13%type,
  p_attribute14                     IN ra_customer_trx.attribute14%type,
  p_attribute15                     IN ra_customer_trx.attribute15%type,
  p_global_attribute_category              IN ra_customer_trx.global_attribute_category%type,
  p_global_attribute1                      IN ra_customer_trx.global_attribute1%type,
  p_global_attribute2                      IN ra_customer_trx.global_attribute2%type,
  p_global_attribute3                      IN ra_customer_trx.global_attribute3%type,
  p_global_attribute4                      IN ra_customer_trx.global_attribute4%type,
  p_global_attribute5                      IN ra_customer_trx.global_attribute5%type,
  p_global_attribute6                      IN ra_customer_trx.global_attribute6%type,
  p_global_attribute7                      IN ra_customer_trx.global_attribute7%type,
  p_global_attribute8                      IN ra_customer_trx.global_attribute8%type,
  p_global_attribute9                      IN ra_customer_trx.global_attribute9%type,
  p_global_attribute10                     IN ra_customer_trx.global_attribute10%type,
  p_global_attribute11                     IN ra_customer_trx.global_attribute11%type,
  p_global_attribute12                     IN ra_customer_trx.global_attribute12%type,
  p_global_attribute13                     IN ra_customer_trx.global_attribute13%type,
  p_global_attribute14                     IN ra_customer_trx.global_attribute14%type,
  p_global_attribute15                     IN ra_customer_trx.global_attribute15%type,
  p_global_attribute16                     IN ra_customer_trx.global_attribute16%type,
  p_global_attribute17                     IN ra_customer_trx.global_attribute17%type,
  p_global_attribute18                     IN ra_customer_trx.global_attribute18%type,
  p_global_attribute19                     IN ra_customer_trx.global_attribute19%type,
  p_global_attribute20                     IN ra_customer_trx.global_attribute20%type,
  p_global_attribute21                     IN ra_customer_trx.global_attribute21%type,
  p_global_attribute22                     IN ra_customer_trx.global_attribute22%type,
  p_global_attribute23                     IN ra_customer_trx.global_attribute23%type,
  p_global_attribute24                     IN ra_customer_trx.global_attribute24%type,
  p_global_attribute25                     IN ra_customer_trx.global_attribute25%type,
  p_global_attribute26                     IN ra_customer_trx.global_attribute26%type,
  p_global_attribute27                     IN ra_customer_trx.global_attribute27%type,
  p_global_attribute28                     IN ra_customer_trx.global_attribute28%type,
  p_global_attribute29                     IN ra_customer_trx.global_attribute29%type,
  p_global_attribute30                     IN ra_customer_trx.global_attribute30%type,
  p_legal_entity_id                        IN ra_customer_trx.legal_entity_id%type,
  p_payment_trxn_extension_id              IN ra_customer_trx.payment_trxn_extension_id%type,
  p_billing_date                           IN ra_customer_trx.billing_date%type)


IS

  l_trx_rec    ra_customer_trx%rowtype;

BEGIN
   arp_util.debug('arp_ct_pkg.lock_compare_cover()+');

  /*------------------------------------------------+
   |  Populate the header record with the values    |
   |  passed in as parameters.                      |
   +------------------------------------------------*/

   arp_ct_pkg.set_to_dummy(l_trx_rec);

   l_trx_rec.customer_trx_id                := p_customer_trx_id;
   l_trx_rec.trx_number                     := p_trx_number;

   --
   -- commented out NOCOPY posting_control_id, ra_post_loop_number so as to
   -- reduce the no of columns in the view
   --
   -- l_trx_rec.posting_control_id             := p_posting_control_id;
   -- l_trx_rec.ra_post_loop_number            := p_ra_post_loop_number;

   l_trx_rec.complete_flag                  := p_complete_flag;
   l_trx_rec.initial_customer_trx_id        := p_initial_customer_trx_id;
   l_trx_rec.previous_customer_trx_id       := p_previous_customer_trx_id;
   l_trx_rec.related_customer_trx_id        := p_related_customer_trx_id;
   l_trx_rec.recurred_from_trx_number       := p_recurred_from_trx_number;
   l_trx_rec.cust_trx_type_id               := p_cust_trx_type_id;
   l_trx_rec.batch_id                       := p_batch_id;
   l_trx_rec.batch_source_id                := p_batch_source_id;
   l_trx_rec.agreement_id                   := p_agreement_id;
   l_trx_rec.trx_date                       := p_trx_date;
   l_trx_rec.bill_to_customer_id            := p_bill_to_customer_id;
   l_trx_rec.bill_to_contact_id             := p_bill_to_contact_id;
   l_trx_rec.bill_to_site_use_id            := p_bill_to_site_use_id;
   l_trx_rec.ship_to_customer_id            := p_ship_to_customer_id;
   l_trx_rec.ship_to_contact_id             := p_ship_to_contact_id;
   l_trx_rec.ship_to_site_use_id            := p_ship_to_site_use_id;
   l_trx_rec.sold_to_customer_id            := p_sold_to_customer_id;
   l_trx_rec.sold_to_site_use_id            := p_sold_to_site_use_id;
   l_trx_rec.sold_to_contact_id             := p_sold_to_contact_id;
   l_trx_rec.customer_reference             := p_customer_reference;
   l_trx_rec.customer_reference_date        := p_customer_reference_date;
   l_trx_rec.credit_method_for_installments := p_cr_method_for_installments;
   l_trx_rec.credit_method_for_rules        := p_credit_method_for_rules;
   l_trx_rec.start_date_commitment          := p_start_date_commitment;
   l_trx_rec.end_date_commitment            := p_end_date_commitment;
   l_trx_rec.exchange_date                  := p_exchange_date;
   l_trx_rec.exchange_rate                  := p_exchange_rate;
   l_trx_rec.exchange_rate_type             := p_exchange_rate_type;
   l_trx_rec.customer_bank_account_id       := p_customer_bank_account_id;
   l_trx_rec.finance_charges                := p_finance_charges;
   l_trx_rec.fob_point                      := p_fob_point;
   l_trx_rec.comments                       := p_comments;
   l_trx_rec.internal_notes                 := p_internal_notes;
   l_trx_rec.invoice_currency_code          := p_invoice_currency_code;
   l_trx_rec.invoicing_rule_id              := p_invoicing_rule_id;
   l_trx_rec.last_printed_sequence_num      := p_last_printed_sequence_num;
   l_trx_rec.orig_system_batch_name         := p_orig_system_batch_name;
   l_trx_rec.primary_salesrep_id            := p_primary_salesrep_id;
   l_trx_rec.printing_count                 := p_printing_count;
   l_trx_rec.printing_last_printed          := p_printing_last_printed;
   l_trx_rec.printing_option                := p_printing_option;
   l_trx_rec.printing_original_date         := p_printing_original_date;
   -- l_trx_rec.printing_pending               := p_printing_pending;
   l_trx_rec.purchase_order                 := p_purchase_order;
   l_trx_rec.purchase_order_date            := p_purchase_order_date;
   l_trx_rec.purchase_order_revision        := p_purchase_order_revision;
   l_trx_rec.receipt_method_id              := p_receipt_method_id;
   l_trx_rec.remit_to_address_id            := p_remit_to_address_id;
   l_trx_rec.shipment_id                    := p_shipment_id;
   l_trx_rec.ship_date_actual               := p_ship_date_actual;
   l_trx_rec.ship_via                       := p_ship_via;
   l_trx_rec.term_id                        := p_term_id;
   l_trx_rec.territory_id                   := p_territory_id;
   l_trx_rec.waybill_number                 := p_waybill_number;
   l_trx_rec.status_trx                     := p_status_trx;
   l_trx_rec.reason_code                    := p_reason_code;
   l_trx_rec.doc_sequence_id                := p_doc_sequence_id;
   l_trx_rec.doc_sequence_value             := p_doc_sequence_value;
   l_trx_rec.paying_customer_id             := p_paying_customer_id;
   l_trx_rec.paying_site_use_id             := p_paying_site_use_id;
   l_trx_rec.related_batch_source_id        := p_related_batch_source_id;
   l_trx_rec.default_tax_exempt_flag        := p_default_tax_exempt_flag;
   l_trx_rec.created_from                   := p_created_from;
   l_trx_rec.default_ussgl_trx_code_context := p_deflt_ussgl_trx_code_context;
   l_trx_rec.default_ussgl_transaction_code := p_deflt_ussgl_transaction_code;
   l_trx_rec.old_trx_number                 := p_old_trx_number;
   l_trx_rec.interface_header_context       := p_interface_header_context;
   l_trx_rec.interface_header_attribute1    := p_interface_header_attribute1;
   l_trx_rec.interface_header_attribute2    := p_interface_header_attribute2;
   l_trx_rec.interface_header_attribute3    := p_interface_header_attribute3;
   l_trx_rec.interface_header_attribute4    := p_interface_header_attribute4;
   l_trx_rec.interface_header_attribute5    := p_interface_header_attribute5;
   l_trx_rec.interface_header_attribute6    := p_interface_header_attribute6;
   l_trx_rec.interface_header_attribute7    := p_interface_header_attribute7;
   l_trx_rec.interface_header_attribute8    := p_interface_header_attribute8;
   l_trx_rec.interface_header_attribute9    := p_interface_header_attribute9;
   l_trx_rec.interface_header_attribute10   := p_interface_header_attribute10;
   l_trx_rec.interface_header_attribute11   := p_interface_header_attribute11;
   l_trx_rec.interface_header_attribute12   := p_interface_header_attribute12;
   l_trx_rec.interface_header_attribute13   := p_interface_header_attribute13;
   l_trx_rec.interface_header_attribute14   := p_interface_header_attribute14;
   l_trx_rec.interface_header_attribute15   := p_interface_header_attribute15;
   l_trx_rec.attribute_category             := p_attribute_category;
   l_trx_rec.attribute1                     := p_attribute1;
   l_trx_rec.attribute2                     := p_attribute2;
   l_trx_rec.attribute3                     := p_attribute3;
   l_trx_rec.attribute4                     := p_attribute4;
   l_trx_rec.attribute5                     := p_attribute5;
   l_trx_rec.attribute6                     := p_attribute6;
   l_trx_rec.attribute7                     := p_attribute7;
   l_trx_rec.attribute8                     := p_attribute8;
   l_trx_rec.attribute9                     := p_attribute9;
   l_trx_rec.attribute10                    := p_attribute10;
   l_trx_rec.attribute11                    := p_attribute11;
   l_trx_rec.attribute12                    := p_attribute12;
   l_trx_rec.attribute13                    := p_attribute13;
   l_trx_rec.attribute14                    := p_attribute14;
   l_trx_rec.attribute15                    := p_attribute15;
   l_trx_rec.global_attribute_category             := p_global_attribute_category;
   l_trx_rec.global_attribute1                     := p_global_attribute1;
   l_trx_rec.global_attribute2                     := p_global_attribute2;
   l_trx_rec.global_attribute3                     := p_global_attribute3;
   l_trx_rec.global_attribute4                     := p_global_attribute4;
   l_trx_rec.global_attribute5                     := p_global_attribute5;
   l_trx_rec.global_attribute6                     := p_global_attribute6;
   l_trx_rec.global_attribute7                     := p_global_attribute7;
   l_trx_rec.global_attribute8                     := p_global_attribute8;
   l_trx_rec.global_attribute9                     := p_global_attribute9;
   l_trx_rec.global_attribute10                    := p_global_attribute10;
   l_trx_rec.global_attribute11                    := p_global_attribute11;
   l_trx_rec.global_attribute12                    := p_global_attribute12;
   l_trx_rec.global_attribute13                    := p_global_attribute13;
   l_trx_rec.global_attribute14                    := p_global_attribute14;
   l_trx_rec.global_attribute15                    := p_global_attribute15;
   l_trx_rec.global_attribute16                    := p_global_attribute16;
   l_trx_rec.global_attribute17                    := p_global_attribute17;
   l_trx_rec.global_attribute18                    := p_global_attribute18;
   l_trx_rec.global_attribute19                    := p_global_attribute19;
   l_trx_rec.global_attribute20                    := p_global_attribute20;
   l_trx_rec.global_attribute21                    := p_global_attribute21;
   l_trx_rec.global_attribute22                    := p_global_attribute22;
   l_trx_rec.global_attribute23                    := p_global_attribute23;
   l_trx_rec.global_attribute24                    := p_global_attribute24;
   l_trx_rec.global_attribute25                    := p_global_attribute25;
   l_trx_rec.global_attribute26                    := p_global_attribute26;
   l_trx_rec.global_attribute27                    := p_global_attribute27;
   l_trx_rec.global_attribute28                    := p_global_attribute28;
   l_trx_rec.global_attribute29                    := p_global_attribute29;
   l_trx_rec.global_attribute30                    := p_global_attribute30;
   l_trx_rec.legal_entity_id                       := p_legal_entity_id;
   /* PAYMENT_UPTAKE */
   l_trx_rec.payment_trxn_extension_id             := p_payment_trxn_extension_id;
   l_trx_rec.billing_date                          := p_billing_date;


  /*-----------------------------------------+
   |  Call the standard header table handler |
   +-----------------------------------------*/

   lock_compare_p( l_trx_rec, p_customer_trx_id);

   arp_util.debug('arp_ct_pkg.lock_compare_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_ct_pkg.lock_compare_cover()');

    arp_util.debug('----- parameters for lock_compare_cover() ' ||
                   '-----');
    arp_util.debug('p_customer_trx_id			= ' ||
                   TO_CHAR(p_customer_trx_id));
    arp_util.debug('p_trx_number			= ' ||
                   p_trx_number);
    arp_util.debug('p_posting_control_id		= ' ||
                   TO_CHAR(p_posting_control_id));
    arp_util.debug('p_ra_post_loop_number		= ' ||
                   p_ra_post_loop_number);
    arp_util.debug('p_complete_flag			= ' ||
                   p_complete_flag);
    arp_util.debug('p_initial_customer_trx_id		= ' ||
                   TO_CHAR(p_initial_customer_trx_id));
    arp_util.debug('p_previous_customer_trx_id		= ' ||
                   TO_CHAR(p_previous_customer_trx_id));
    arp_util.debug('p_related_customer_trx_id		= ' ||
                   TO_CHAR(p_related_customer_trx_id));
    arp_util.debug('p_recurred_from_trx_number		= ' ||
                   p_recurred_from_trx_number);
    arp_util.debug('p_cust_trx_type_id			= ' ||
                   TO_CHAR(p_cust_trx_type_id));
    arp_util.debug('p_batch_id				= ' ||
                   TO_CHAR(p_batch_id));
    arp_util.debug('p_batch_source_id			= ' ||
                   TO_CHAR(p_batch_source_id));
    arp_util.debug('p_agreement_id			= ' ||
                   TO_CHAR(p_agreement_id));
    arp_util.debug('p_trx_date				= ' ||
                   p_trx_date);
    arp_util.debug('p_bill_to_customer_id		= ' ||
                   TO_CHAR(p_bill_to_customer_id));
    arp_util.debug('p_bill_to_contact_id		= ' ||
                   TO_CHAR(p_bill_to_contact_id));
    arp_util.debug('p_bill_to_site_use_id		= ' ||
                   TO_CHAR(p_bill_to_site_use_id));
    arp_util.debug('p_ship_to_customer_id		= ' ||
                   TO_CHAR(p_ship_to_customer_id));
    arp_util.debug('p_ship_to_contact_id		= ' ||
                   TO_CHAR(p_ship_to_contact_id));
    arp_util.debug('p_ship_to_site_use_id		= ' ||
                   TO_CHAR(p_ship_to_site_use_id));
    arp_util.debug('p_sold_to_customer_id		= ' ||
                   TO_CHAR(p_sold_to_customer_id));
    arp_util.debug('p_sold_to_site_use_id		= ' ||
                   TO_CHAR(p_sold_to_site_use_id));
    arp_util.debug('p_sold_to_contact_id		= ' ||
                   TO_CHAR(p_sold_to_contact_id));
    arp_util.debug('p_customer_reference		= ' ||
                   p_customer_reference);
    arp_util.debug('p_customer_reference_date		= ' ||
                   p_customer_reference_date);
    arp_util.debug('p_cr_method_for_installments	= ' ||
                   p_cr_method_for_installments);
    arp_util.debug('p_credit_method_for_rules		= ' ||
                   p_credit_method_for_rules);
    arp_util.debug('p_start_date_commitment		= ' ||
                   p_start_date_commitment);
    arp_util.debug('p_end_date_commitment		= ' ||
                   p_end_date_commitment);
    arp_util.debug('p_exchange_date			= ' ||
                   p_exchange_date);
    arp_util.debug('p_exchange_rate			= ' ||
                   p_exchange_rate);
    arp_util.debug('p_exchange_rate_type		= ' ||
                   p_exchange_rate_type);
    arp_util.debug('p_customer_bank_account_id		= ' ||
                   TO_CHAR(p_customer_bank_account_id));
    arp_util.debug('p_finance_charges			= ' ||
                   p_finance_charges);
    arp_util.debug('p_fob_point				= ' ||
                   p_fob_point);
    arp_util.debug('p_comments				= ' ||
                   p_comments);
    arp_util.debug('p_internal_notes			= ' ||
                   p_internal_notes);
    arp_util.debug('p_invoice_currency_code		= ' ||
                   p_invoice_currency_code);
    arp_util.debug('p_invoicing_rule_id			= ' ||
                   TO_CHAR(p_invoicing_rule_id));
    arp_util.debug('p_last_printed_sequence_num		= ' ||
                   p_last_printed_sequence_num);
    arp_util.debug('p_orig_system_batch_name		= ' ||
                   p_orig_system_batch_name);
    arp_util.debug('p_primary_salesrep_id		= ' ||
                   TO_CHAR(p_primary_salesrep_id));
    arp_util.debug('p_printing_count			= ' ||
                   p_printing_count);
    arp_util.debug('p_printing_last_printed		= ' ||
                   p_printing_last_printed);
    arp_util.debug('p_printing_option			= ' ||
                   p_printing_option);
    arp_util.debug('p_printing_original_date		= ' ||
                   p_printing_original_date);
    arp_util.debug('p_printing_pending			= ' ||
                   p_printing_pending);
    arp_util.debug('p_purchase_order			= ' ||
                   p_purchase_order);
    arp_util.debug('p_purchase_order_date		= ' ||
                   p_purchase_order_date);
    arp_util.debug('p_purchase_order_revision		= ' ||
                   p_purchase_order_revision);
    arp_util.debug('p_receipt_method_id			= ' ||
                   TO_CHAR(p_receipt_method_id));
    arp_util.debug('p_remit_to_address_id		= ' ||
                   TO_CHAR(p_remit_to_address_id));
    arp_util.debug('p_shipment_id			= ' ||
                   TO_CHAR(p_shipment_id));
    arp_util.debug('p_ship_date_actual			= ' ||
                   p_ship_date_actual);
    arp_util.debug('p_ship_via				= ' ||
                   p_ship_via);
    arp_util.debug('p_term_due_date			= ' ||
                   p_term_due_date);
    arp_util.debug('p_term_id				= ' ||
                   TO_CHAR(p_term_id));
    arp_util.debug('p_territory_id			= ' ||
                   TO_CHAR(p_territory_id));
    arp_util.debug('p_waybill_number			= ' ||
                   p_waybill_number);
    arp_util.debug('p_status_trx			= ' ||
                   p_status_trx);
    arp_util.debug('p_reason_code			= ' ||
                   p_reason_code);
    arp_util.debug('p_doc_sequence_id			= ' ||
                   TO_CHAR(p_doc_sequence_id));
    arp_util.debug('p_doc_sequence_value		= ' ||
                   p_doc_sequence_value);
    arp_util.debug('p_paying_customer_id		= ' ||
                   TO_CHAR(p_paying_customer_id));
    arp_util.debug('p_paying_site_use_id		= ' ||
                   TO_CHAR(p_paying_site_use_id));
    arp_util.debug('p_related_batch_source_id		= ' ||
                   TO_CHAR(p_related_batch_source_id));
    arp_util.debug('p_default_tax_exempt_flag		= ' ||
                   p_default_tax_exempt_flag);
    arp_util.debug('p_created_from			= ' ||
                   p_created_from);
    arp_util.debug('p_deflt_ussgl_trx_code_context	= ' ||
                   p_deflt_ussgl_trx_code_context);
    arp_util.debug('p_deflt_ussgl_transaction_code	= ' ||
                   p_deflt_ussgl_transaction_code);
    arp_util.debug('p_old_trx_number                    = ' ||
                   p_old_trx_number);
    arp_util.debug('p_interface_header_context		= ' ||
                   p_interface_header_context);
    arp_util.debug('p_interface_header_attribute1	= ' ||
                   p_interface_header_attribute1);
    arp_util.debug('p_interface_header_attribute2	= ' ||
                   p_interface_header_attribute2);
    arp_util.debug('p_interface_header_attribute3	= ' ||
                   p_interface_header_attribute3);
    arp_util.debug('p_interface_header_attribute4	= ' ||
                   p_interface_header_attribute4);
    arp_util.debug('p_interface_header_attribute5	= ' ||
                   p_interface_header_attribute5);
    arp_util.debug('p_interface_header_attribute6	= ' ||
                   p_interface_header_attribute6);
    arp_util.debug('p_interface_header_attribute7	= ' ||
                  p_interface_header_attribute7);
    arp_util.debug('p_interface_header_attribute8	= ' ||
                   p_interface_header_attribute8);
    arp_util.debug('p_interface_header_attribute9	= ' ||
                   p_interface_header_attribute9);
    arp_util.debug('p_interface_header_attribute10	= ' ||
                   p_interface_header_attribute10);
    arp_util.debug('p_interface_header_attribute11	= ' ||
                   p_interface_header_attribute11);
    arp_util.debug('p_interface_header_attribute12	= ' ||
                   p_interface_header_attribute12);
    arp_util.debug('p_interface_header_attribute13	= ' ||
                   p_interface_header_attribute13);
    arp_util.debug('p_interface_header_attribute14	= ' ||
                   p_interface_header_attribute14);
    arp_util.debug('p_interface_header_attribute15	= ' ||
                   p_interface_header_attribute15);
    arp_util.debug('p_attribute_category		= ' ||
                   p_attribute_category);
    arp_util.debug('p_attribute1			= ' ||
                   p_attribute1);
    arp_util.debug('p_attribute2			= ' ||
                   p_attribute2);
    arp_util.debug('p_attribute3			= ' ||
                   p_attribute3);
    arp_util.debug('p_attribute4			= ' ||
                   p_attribute4);
    arp_util.debug('p_attribute5			= ' ||
                   p_attribute5);
    arp_util.debug('p_attribute6			= ' ||
                   p_attribute6);
    arp_util.debug('p_attribute7			= ' ||
                   p_attribute7);
    arp_util.debug('p_attribute8			= ' ||
                   p_attribute8);
    arp_util.debug('p_attribute9			= ' ||
                   p_attribute9);
    arp_util.debug('p_attribute10			= ' ||
                   p_attribute10);
    arp_util.debug('p_attribute11			= ' ||
                   p_attribute11);
    arp_util.debug('p_attribute12			= ' ||
                   p_attribute12);
    arp_util.debug('p_attribute13			= ' ||
                   p_attribute13);
    arp_util.debug('p_attribute14			= ' ||
                   p_attribute14);
    arp_util.debug('p_attribute15			= ' ||
                   p_attribute15);

    RAISE;

END;

  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/

BEGIN

  pg_user_id          := fnd_global.user_id;
  pg_conc_login_id    := fnd_global.conc_login_id;
  pg_login_id         := fnd_global.login_id;
  pg_prog_appl_id     := fnd_global.prog_appl_id;
  pg_conc_program_id  := fnd_global.conc_program_id;


END ARP_CT_PKG;

/
