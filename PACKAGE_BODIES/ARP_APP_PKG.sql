--------------------------------------------------------
--  DDL for Package Body ARP_APP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_APP_PKG" AS
/* $Header: ARCIAPPB.pls 120.12.12010000.4 2010/06/16 21:50:03 rravikir ship $*/

/*===========================================================================+
 | FUNCTION 								     |
 |    revision        							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the revision number of this package.             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | RETURNS    : Revision number of this package                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      6/25/1996       Harri Kaukovuo  Created                              |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 120.12.12010000.4 $';
END revision;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row into AR_RECEIVABLE_APPLICATIONS table      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ra_rec - receivable applications record structure    |
 |              IN/OUT:                                                      |
 |                    p_ra_id - receivable application id of inserted row    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 07/11/1997	K.Lawrance	Release 11.                                  |
 |				Removed obsolete columns from insert         |
 |                              statement: on_account_customer,              |
 |                              receivables_trx_id, reversal_gl_date_context.|
 |                              Added new cross currency columns to insert   |
 |          			statement: amount_applied_from,              |
 |                              trans_to_receipt_rate.                       |
 | 08/21/1997	Tasman Tang	Added global_attribute_category and	     |
 |				global_attribute[1-20] to insert statement   |
 |				for global descriptive flexfield	     |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related column              |
 |                              LINK_TO_TRX_HIST_ID and                      |
 |                              LINK_TO_CUSTOMER_TRX_ID into table handlers. |
 |                              also re-introduced receivables_trx_id        |
 |									     |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns tax_code and     |
 |				unedisc_tax_acct_rule		             |
 | 				into the table handlers.  		     |
 |                                                                           |
 | 10-NOV-2000 Y Rakotonirainy	Bug 1243304 : Added column 		     |
 |				edisc_tax_acct_rule		             |
 | 				into the table handlers.  		     |
 | 15-Sep-2001 S.Nambiar        Aded a new column payment_set_id for prepayment|
 | 13-MAR-2002 J.Beckett        Added new columns application_ref_reason and |
 |                              customer_reference (bug 2254777)             |
 | 06-FEB-2003 J.Beckett        Bug 2751910 - Added customer_reason and      |
 |                              applied_rec_app_id                           |
 | 07-DEC-2006 MRAYMOND      5677984 - changed p_ra_id from IN to IN/OUT
 +===========================================================================*/
PROCEDURE insert_p(
    p_ra_rec 	IN ar_receivable_applications%ROWTYPE
  , p_ra_id  	IN OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE ) IS
l_ra_id ar_receivable_applications.receivable_application_id%TYPE;
BEGIN
      arp_standard.debug( 'arp_app_pkg.insert_p()+' );
      arp_standard.debug('    p_ra_id = ' || p_ra_id);
      IF p_ra_id IS NULL
      THEN
         SELECT ar_receivable_applications_s.nextval
         INTO   l_ra_id
         FROM   dual;
         arp_standard.debug('  assigned l_ra_id = ' || l_ra_id);
      ELSE
         l_ra_id := p_ra_id;
      END IF;

      INSERT INTO  ar_receivable_applications (
		  receivable_application_id,
 		  acctd_amount_applied_from,
 		  amount_applied,
                  amount_applied_from,
 		  trans_to_receipt_rate,
 		  application_rule,
 		  application_type,
 		  apply_date,
 		  code_combination_id,
 		  created_by,
 		  creation_date,
 		  display,
 		  gl_date,
 		  last_updated_by,
 		  last_update_date,
 		  payment_schedule_id,
 		  set_of_books_id,
 		  status,
 		  acctd_amount_applied_to,
 		  acctd_earned_discount_taken,
 		  acctd_unearned_discount_taken,
 		  applied_customer_trx_id,
 		  applied_customer_trx_line_id,
 		  applied_payment_schedule_id,
 		  cash_receipt_id,
 		  comments,
 		  confirmed_flag,
 		  customer_trx_id,
 		  days_late,
 		  earned_discount_taken,
 		  freight_applied,
 		  gl_posted_date,
 		  last_update_login,
 		  line_applied,
 		  postable,
 		  posting_control_id,
 		  program_application_id,
 		  program_id,
 		  program_update_date,
 		  receivables_charges_applied,
 		  request_id,
 		  tax_applied,
 		  unearned_discount_taken,
 		  unearned_discount_ccid,
 		  earned_discount_ccid,
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
 		  ussgl_transaction_code_context,
 		  reversal_gl_date,
 		  cash_receipt_history_id,
                  line_ediscounted,
                  line_uediscounted,
                  tax_ediscounted,
                  tax_uediscounted,
                  freight_ediscounted,
                  freight_uediscounted,
                  charges_ediscounted,
                  charges_uediscounted,
                  rule_set_id,
                  link_to_trx_hist_id,
                  link_to_customer_trx_id,
                  receivables_trx_id,
                  tax_code,
                  unedisc_tax_acct_rule,
                  edisc_tax_acct_rule,
                  secondary_application_ref_id,
                  secondary_application_ref_type,
                  secondary_application_ref_num,
                  application_ref_type,
                  application_ref_id,
                  application_ref_num,
                  payment_set_id,
                  application_ref_reason,
                  customer_reference,
                  customer_reason,
                  applied_rec_app_id
                  ,org_id
                  ,upgrade_method
                  ,include_in_accumulation	-- Bug 6924942
 		 )
       VALUES (   l_ra_id,
 		  p_ra_rec.acctd_amount_applied_from,
 		  p_ra_rec.amount_applied,
                  p_ra_rec.amount_applied_from,
 		  p_ra_rec.trans_to_receipt_rate,
 		  p_ra_rec.application_rule,
 		  p_ra_rec.application_type,
 		  p_ra_rec.apply_date,
 		  p_ra_rec.code_combination_id,
 		  arp_standard.profile.user_id,
 		  SYSDATE,
 		  p_ra_rec.display,
 		  TRUNC(p_ra_rec.gl_date),
 		  arp_standard.profile.user_id,
 		  SYSDATE,
 		  p_ra_rec.payment_schedule_id,
 		  arp_global.set_of_books_id,
 		  p_ra_rec.status,
 		  p_ra_rec.acctd_amount_applied_to,
 		  p_ra_rec.acctd_earned_discount_taken,
 		  p_ra_rec.acctd_unearned_discount_taken,
 		  p_ra_rec.applied_customer_trx_id,
 		  p_ra_rec.applied_customer_trx_line_id,
 		  p_ra_rec.applied_payment_schedule_id,
 		  p_ra_rec.cash_receipt_id,
 		  p_ra_rec.comments,
 		  p_ra_rec.confirmed_flag,
 		  p_ra_rec.customer_trx_id,
 		  p_ra_rec.days_late,
 		  p_ra_rec.earned_discount_taken,
 		  p_ra_rec.freight_applied,
 		  p_ra_rec.gl_posted_date,
 		  NVL( arp_standard.profile.last_update_login,
		       p_ra_rec.last_update_login ),
 		  p_ra_rec.line_applied,
 		  p_ra_rec.postable,
 		  p_ra_rec.posting_control_id,
 		  NVL( arp_standard.profile.program_application_id,
		       p_ra_rec.program_application_id ),
 		  NVL(
		decode(arp_standard.profile.program_id
			,-1,p_ra_rec.program_id)
			,p_ra_rec.program_id),
 		  DECODE( arp_standard.profile.program_id,
                           NULL, NULL, SYSDATE ),
 		  p_ra_rec.receivables_charges_applied,
 		  NVL( arp_standard.profile.request_id, p_ra_rec.request_id ),
 		  p_ra_rec.tax_applied,
 		  p_ra_rec.unearned_discount_taken,
 		  p_ra_rec.unearned_discount_ccid,
 		  p_ra_rec.earned_discount_ccid,
 		  p_ra_rec.ussgl_transaction_code,
 		  p_ra_rec.attribute_category,
 		  p_ra_rec.attribute1,
 		  p_ra_rec.attribute2,
 		  p_ra_rec.attribute3,
 		  p_ra_rec.attribute4,
 		  p_ra_rec.attribute5,
 		  p_ra_rec.attribute6,
 		  p_ra_rec.attribute7,
 		  p_ra_rec.attribute8,
 		  p_ra_rec.attribute9,
 		  p_ra_rec.attribute10,
 		  p_ra_rec.attribute11,
 		  p_ra_rec.attribute12,
 		  p_ra_rec.attribute13,
 		  p_ra_rec.attribute14,
 		  p_ra_rec.attribute15,
                  p_ra_rec.global_attribute_category,
                  p_ra_rec.global_attribute1,
                  p_ra_rec.global_attribute2,
                  p_ra_rec.global_attribute3,
                  p_ra_rec.global_attribute4,
                  p_ra_rec.global_attribute5,
                  p_ra_rec.global_attribute6,
                  p_ra_rec.global_attribute7,
                  p_ra_rec.global_attribute8,
                  p_ra_rec.global_attribute9,
                  p_ra_rec.global_attribute10,
                  p_ra_rec.global_attribute11,
                  p_ra_rec.global_attribute12,
                  p_ra_rec.global_attribute13,
                  p_ra_rec.global_attribute14,
                  p_ra_rec.global_attribute15,
                  p_ra_rec.global_attribute16,
                  p_ra_rec.global_attribute17,
                  p_ra_rec.global_attribute18,
                  p_ra_rec.global_attribute19,
                  p_ra_rec.global_attribute20,
 		  p_ra_rec.ussgl_transaction_code_context,
 		  p_ra_rec.reversal_gl_date,
 		  p_ra_rec.cash_receipt_history_id,
                  p_ra_rec.line_ediscounted,
                  p_ra_rec.line_uediscounted,
                  p_ra_rec.tax_ediscounted,
                  p_ra_rec.tax_uediscounted,
                  p_ra_rec.freight_ediscounted,
                  p_ra_rec.freight_uediscounted,
                  p_ra_rec.charges_ediscounted,
                  p_ra_rec.charges_uediscounted,
                  p_ra_rec.rule_set_id,
                  p_ra_rec.link_to_trx_hist_id,
                  p_ra_rec.link_to_customer_trx_id,
                  p_ra_rec.receivables_trx_id,
                  p_ra_rec.tax_code,
                  p_ra_rec.unedisc_tax_acct_rule,
                  p_ra_rec.edisc_tax_acct_rule,
                  p_ra_rec.secondary_application_ref_id,
                  p_ra_rec.secondary_application_ref_type,
                  p_ra_rec.secondary_application_ref_num,
                  p_ra_rec.application_ref_type,
                  p_ra_rec.application_ref_id,
                  p_ra_rec.application_ref_num,
                  p_ra_rec.payment_set_id,
                  p_ra_rec.application_ref_reason,
                  p_ra_rec.customer_reference,
                  p_ra_rec.customer_reason,
                  p_ra_rec.applied_rec_app_id
                  ,arp_standard.sysparm.org_id /* SSA changes anuj */
                  ,'R12'
                  ,p_ra_rec.include_in_accumulation		-- Bug 6924942
	       );
    p_ra_id := l_ra_id;

    arp_standard.debug( 'arp_app_pkg.insert_p()-' );
    EXCEPTION
	WHEN  OTHERS THEN
	    arp_standard.debug(
			'EXCEPTION: arp_app_pkg.insert_p' );
arp_standard.debug('SYSDATE = ' || SYSDATE);
arp_standard.debug('arp_standard.profile.user_id = ' || TO_CHAR(arp_standard.profile.user_id));
arp_standard.debug('last_update_login = ' ||  NVL(TO_CHAR(NVL( arp_standard.profile.last_update_login,
		       p_ra_rec.last_update_login) ), '<NULL>'));
arp_standard.debug('---------------------------');
arp_standard.debug('ra_id = 			' || l_ra_id);
arp_standard.debug('last_updated_by		' || to_char(arp_standard.profile.user_id));
arp_standard.debug('last_update_date		' || SYSDATE);
arp_standard.debug('created_by			' || to_char(arp_standard.profile.user_id));
arp_standard.debug('amount_applied		' || to_char(p_ra_rec.amount_applied));
arp_standard.debug('amount_applied_from		' || to_char(p_ra_rec.amount_applied_from));
arp_standard.debug('trans_to_receipt_rate	' || to_char(p_ra_rec.trans_to_receipt_rate));
arp_standard.debug('gl_date			' || p_ra_rec.gl_date);
arp_standard.debug('ccid			' || to_char(arp_global.set_of_books_id));
arp_standard.debug('display			' || p_ra_rec.display);
arp_standard.debug('apply_Date			' || p_ra_rec.apply_date);
arp_standard.debug('application_type		' || p_ra_rec.application_type);
arp_standard.debug('status			' || p_ra_rec.status);
arp_standard.debug('payment_schedule_id		' || to_char(p_ra_rec.payment_schedule_id));
arp_standard.debug('application_rule		' || p_ra_rec.application_rule);
arp_standard.debug('posting_control_id		' || to_char(p_ra_rec.posting_control_id));
arp_standard.debug('acctd_amount_applied_from   ' || to_char(p_ra_rec.acctd_amount_applied_from));
arp_standard.debug('p_ra_rec.line_ediscounted='||to_char(p_ra_rec.line_ediscounted));
arp_standard.debug('p_ra_rec.line_uediscounted='||to_char(p_ra_rec.line_uediscounted));
arp_standard.debug('p_ra_rec.tax_ediscounted='||to_char(p_ra_rec.tax_ediscounted));
arp_standard.debug('p_ra_rec.tax_uediscounted='||to_char(p_ra_rec.tax_uediscounted));
arp_standard.debug('p_ra_rec.freight_ediscounted='||to_char(p_ra_rec.freight_ediscounted));
arp_standard.debug('p_ra_rec.freight_uediscounted='||to_char(p_ra_rec.freight_uediscounted));
arp_standard.debug('p_ra_rec.charges_ediscounted='||to_char(p_ra_rec.charges_ediscounted));
arp_standard.debug('p_ra_rec.charges_uediscounted='||to_char(p_ra_rec.charges_uediscounted));
arp_standard.debug('p_ra_rec.rule_set_id='||to_char(p_ra_rec.rule_set_id));
arp_standard.debug('tax_code=' || p_ra_rec.tax_code);
arp_standard.debug('unedisc_tax_acct_rule=' || p_ra_rec.unedisc_tax_acct_rule);
arp_standard.debug('edisc_tax_acct_rule=' || p_ra_rec.edisc_tax_acct_rule);
arp_standard.debug('application_ref_type='||p_ra_rec.application_ref_type);
arp_standard.debug('application_ref_id='||p_ra_rec.application_ref_id);
arp_standard.debug('application_ref_num='||p_ra_rec.application_ref_num);
arp_standard.debug('secondary_application_ref_id='||to_char(p_ra_rec.secondary_application_ref_id));
arp_standard.debug('secondary_application_ref_num='||p_ra_rec.secondary_application_ref_num);
arp_standard.debug('secondary_application_ref_type='||p_ra_rec.secondary_application_ref_type);
arp_standard.debug('payment_set_id='||to_char(p_ra_rec.payment_set_id));
arp_standard.debug('application_ref_reason='||p_ra_rec.application_ref_reason);
arp_standard.debug('customer_reference='||p_ra_rec.customer_reference);
arp_standard.debug('customer_reason='||p_ra_rec.customer_reason);
arp_standard.debug('applied_rec_app_id='||to_char(p_ra_rec.applied_rec_app_id));



	    RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row into AR_RECEIVABLE_APPLICATIONS table      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ra_rec - Receivable applications strcuture           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 4/25/1995 	Ganesh Vaidee	Created                                      |
 | 6/25/1996 	Harri Kaukovuo	Added the values of columns to be returned   |
 |				in case of exception.                        |
 | 07/11/1997	K.Lawrance	Release 11.                                  |
 |				Removed obsolete columns from update         |
 |                              statement: on_account_customer,              |
 |                              receivables_trx_id, reversal_gl_date_context.|
 |                              Added new cross currency columns to update   |
 |          			statement: amount_applied_from,              |
 |                              trans_to_receipt_rate.                       |
 | 08/21/1997	Tasman Tang	Added global_attribute_category and 	     |
 |				global_attribute[1-20] to update statement   |
 |				for global descriptive flexfield	     |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related column              |
 |                              LINK_TO_TRX_HIST_ID and                      |
 |                              LINK_TO_CUSTOMER_TRX_ID into table handlers. |
 |                              also re-introduced receivables_trx_id        |
 |									     |
 | 31-OCT-2000 Y Rakotonirainy	Bug 1243304 : Added columns tax_code and     |
 |				unedisc_tax_acct_rule		             |
 | 				into the table handlers.  		     |
 |                                                                           |
 | 10-NOV-2000 Y Rakotonirainy	Bug 1243304 : Added column 		     |
 |				edisc_tax_acct_rule		             |
 | 				into the table handlers.  		     |
 | 07-Jun-2001 S.Nambiar        Bug 1815528 Aded a new claim related columns |
 |                              for update routine
 | 15-Sep-2001 S.Nambiar        Aded a new column payment_set_id for prepayment|
 | 13-MAR-2002 J.Beckett        Added new columns application_ref_reason and |
 |                              customer_reference (bug 2254777)             |
 | 06-FEB-2003 J.Beckett        Bug 2751910 - Added customer_reason and      |
 |                              applied_rec_app_id                           |
 +===========================================================================*/
PROCEDURE update_p( p_ra_rec 	IN ar_receivable_applications%ROWTYPE ) IS
lc_dump VARCHAR2(30000);

BEGIN
    arp_standard.debug( 'arp_app_pkg.update_p()+' );

    UPDATE ar_receivable_applications ra SET
 		  acctd_amount_applied_from =
					p_ra_rec.acctd_amount_applied_from,
 		  amount_applied = p_ra_rec.amount_applied,
 		  amount_applied_from = p_ra_rec.amount_applied_from,
		  trans_to_receipt_rate = p_ra_rec.trans_to_receipt_rate,
 		  application_rule = p_ra_rec.application_rule,
 		  application_type = p_ra_rec.application_type,
 		  apply_date = p_ra_rec.apply_date,
 		  code_combination_id = p_ra_rec.code_combination_id,
 		  display = p_ra_rec.display,
 		  gl_date = p_ra_rec.gl_date,
 		  last_updated_by = arp_standard.profile.user_id,
 		  last_update_date = SYSDATE,
 		  payment_schedule_id = p_ra_rec.payment_schedule_id,
 		  set_of_books_id = p_ra_rec.set_of_books_id,
 		  status = p_ra_rec.status,
 		  acctd_amount_applied_to = p_ra_rec.acctd_amount_applied_to,
 		  acctd_earned_discount_taken =
					p_ra_rec.acctd_earned_discount_taken,
 		  acctd_unearned_discount_taken =
					p_ra_rec.acctd_unearned_discount_taken,
 		  applied_customer_trx_id = p_ra_rec.applied_customer_trx_id,
 		  applied_customer_trx_line_id =
					p_ra_rec.applied_customer_trx_line_id,
 		  applied_payment_schedule_id =
					p_ra_rec.applied_payment_schedule_id,
 		  cash_receipt_id = p_ra_rec.cash_receipt_id,
 		  comments = p_ra_rec.comments,
 		  confirmed_flag = p_ra_rec.confirmed_flag,
 		  customer_trx_id = p_ra_rec.customer_trx_id,
 		  days_late = p_ra_rec.days_late,
 		  earned_discount_taken = p_ra_rec.earned_discount_taken,
 		  freight_applied = p_ra_rec.freight_applied,
 		  gl_posted_date = p_ra_rec.gl_posted_date,
 		  last_update_login =
				NVL( arp_standard.profile.last_update_login,
				     p_ra_rec.last_update_login ),
 		  line_applied = p_ra_rec.line_applied,
 		  postable = p_ra_rec.postable,
 		  posting_control_id = p_ra_rec.posting_control_id,
 		  program_application_id =
			       NVL( arp_standard.profile.program_application_id,
			            p_ra_rec.program_application_id ),
 		  program_id = NVL( arp_standard.profile.program_id,
				    p_ra_rec.program_id ),
 		  program_update_date = DECODE( arp_standard.profile.program_id,
                                                NULL, NULL,
						SYSDATE
				    	      ),
 		  receivables_charges_applied =
				p_ra_rec.receivables_charges_applied,
 		  request_id = NVL( arp_standard.profile.request_id,
				    p_ra_rec.request_id ),
 		  tax_applied = p_ra_rec.tax_applied,
 		  unearned_discount_taken = p_ra_rec.unearned_discount_taken,
 		  unearned_discount_ccid = p_ra_rec.unearned_discount_ccid,
 		  earned_discount_ccid = p_ra_rec.earned_discount_ccid,
 		  ussgl_transaction_code = p_ra_rec.ussgl_transaction_code,
 		  attribute_category = p_ra_rec.attribute_category,
 		  attribute1 = p_ra_rec.attribute1,
 		  attribute2 = p_ra_rec.attribute2,
 		  attribute3 = p_ra_rec.attribute3,
 		  attribute4 = p_ra_rec.attribute4,
 		  attribute5 = p_ra_rec.attribute5,
 		  attribute6 = p_ra_rec.attribute6,
 		  attribute7 = p_ra_rec.attribute7,
 		  attribute8 = p_ra_rec.attribute8,
 		  attribute9 = p_ra_rec.attribute9,
 		  attribute10 = p_ra_rec.attribute10,
 		  attribute11 = p_ra_rec.attribute11,
 		  attribute12 = p_ra_rec.attribute12,
 		  attribute13 = p_ra_rec.attribute13,
 		  attribute14 = p_ra_rec.attribute14,
 		  attribute15 = p_ra_rec.attribute15,
                  global_attribute_category = p_ra_rec.global_attribute_category,
                  global_attribute1 = p_ra_rec.global_attribute1,
                  global_attribute2 = p_ra_rec.global_attribute2,
                  global_attribute3 = p_ra_rec.global_attribute3,
                  global_attribute4 = p_ra_rec.global_attribute4,
                  global_attribute5 = p_ra_rec.global_attribute5,
                  global_attribute6 = p_ra_rec.global_attribute6,
                  global_attribute7 = p_ra_rec.global_attribute7,
                  global_attribute8 = p_ra_rec.global_attribute8,
                  global_attribute9 = p_ra_rec.global_attribute9,
                  global_attribute10 = p_ra_rec.global_attribute10,
                  global_attribute11 = p_ra_rec.global_attribute11,
                  global_attribute12 = p_ra_rec.global_attribute12,
                  global_attribute13 = p_ra_rec.global_attribute13,
                  global_attribute14 = p_ra_rec.global_attribute14,
                  global_attribute15 = p_ra_rec.global_attribute15,
                  global_attribute16 = p_ra_rec.global_attribute16,
                  global_attribute17 = p_ra_rec.global_attribute17,
                  global_attribute18 = p_ra_rec.global_attribute18,
                  global_attribute19 = p_ra_rec.global_attribute19,
                  global_attribute20 = p_ra_rec.global_attribute20,
 		  ussgl_transaction_code_context =
				p_ra_rec.ussgl_transaction_code_context,
 		  reversal_gl_date = p_ra_rec.reversal_gl_date,
 		  cash_receipt_history_id = p_ra_rec.cash_receipt_history_id,
                  line_ediscounted = p_ra_rec.line_ediscounted,
                  line_uediscounted = p_ra_rec.line_uediscounted,
                  tax_ediscounted = p_ra_rec.tax_ediscounted,
                  tax_uediscounted = p_ra_rec.tax_uediscounted,
                  freight_ediscounted = p_ra_rec.freight_ediscounted,
                  freight_uediscounted = p_ra_rec.freight_uediscounted,
                  charges_ediscounted = p_ra_rec.charges_ediscounted,
                  charges_uediscounted = p_ra_rec.charges_uediscounted,
                  rule_set_id = p_ra_rec.rule_set_id,
                  link_to_trx_hist_id = p_ra_rec.link_to_trx_hist_id,
                  link_to_customer_trx_id = p_ra_rec.link_to_customer_trx_id,
                  receivables_trx_id = p_ra_rec.receivables_trx_id,
                  tax_code = p_ra_rec.tax_code,
                  unedisc_tax_acct_rule = p_ra_rec.unedisc_tax_acct_rule,
                  edisc_tax_acct_rule = p_ra_rec.edisc_tax_acct_rule,
           --Bug 1815528 Claim related columns added
                  application_ref_type  = p_ra_rec.application_ref_type,
                  application_ref_id    = p_ra_rec.application_ref_id,
                  application_ref_num   = p_ra_rec.application_ref_num,
                  secondary_application_ref_id  = p_ra_rec.secondary_application_ref_id,
                  secondary_application_ref_type = p_ra_rec.secondary_application_ref_type,
                  secondary_application_ref_num  = p_ra_rec.secondary_application_ref_num,
            --Added for prepayment
                  payment_set_id                = p_ra_rec.payment_set_id,
                  application_ref_reason = p_ra_rec.application_ref_reason,
                  customer_reference     = p_ra_rec.customer_reference,
                  customer_reason        = p_ra_rec.customer_reason,
                  applied_rec_app_id     = p_ra_rec.applied_rec_app_id
    WHERE ra.receivable_application_id = p_ra_rec.receivable_application_id;

    arp_standard.debug('arp_app_pkg.update_p()-' );

    EXCEPTION
        WHEN  OTHERS THEN
          arp_standard.debug( 'EXCEPTION: arp_app_pkg.update_p' );

          -- Dump all parameter values and return them to error stack
          -- for debugging purposes.
          lc_dump := 'DUMP of procedure parameter values:'
|| 'p_ra_rec.acctd_amount_applied_from='||
		to_char(p_ra_rec.acctd_amount_applied_from)||
','||'p_ra_rec.amount_applied'||to_char(p_ra_rec.amount_applied)||
','||'p_ra_rec.amount_applied_from'||to_char(p_ra_rec.amount_applied_from)||
','||'p_ra_rec.trans_to_receipt_rate'||to_char(p_ra_rec.trans_to_receipt_rate)||
','||' p_ra_rec.application_rule'||p_ra_rec.application_rule||
','||' p_ra_rec.application_type'||p_ra_rec.application_type||
','||' p_ra_rec.apply_date'||TO_CHAR( p_ra_rec.apply_date)||
','||' p_ra_rec.code_combination_id'||TO_CHAR( p_ra_rec.code_combination_id)||
','||' p_ra_rec.display'||p_ra_rec.display||
','||' p_ra_rec.gl_date'||TO_CHAR( p_ra_rec.gl_date)||
','||' arp_standard.profile.user_id'||TO_CHAR( arp_standard.profile.user_id)||
','||' SYSDATE='||TO_CHAR( SYSDATE)||
','||' p_ra_rec.payment_schedule_id='||TO_CHAR( p_ra_rec.payment_schedule_id)||
','||' p_ra_rec.set_of_books_id='||TO_CHAR( p_ra_rec.set_of_books_id)||
','||' p_ra_rec.status='||p_ra_rec.status||
','||' p_ra_rec.acctd_amount_applied_to='||TO_CHAR( p_ra_rec.acctd_amount_applied_to)||
','||' p_ra_rec.acctd_earned_discount_taken='||TO_CHAR( p_ra_rec.acctd_earned_discount_taken)||
','||' p_ra_rec.acctd_unearned_discount_taken='||TO_CHAR( p_ra_rec.acctd_unearned_discount_taken)||
','||' p_ra_rec.applied_customer_trx_id='||TO_CHAR( p_ra_rec.applied_customer_trx_id)||
','||' p_ra_rec.applied_customer_trx_line_id='||TO_CHAR( p_ra_rec.applied_customer_trx_line_id)||
','||'p_ra_rec.applied_payment_schedule_id='||TO_CHAR(p_ra_rec.applied_payment_schedule_id)||
','||' p_ra_rec.cash_receipt_id='||TO_CHAR( p_ra_rec.cash_receipt_id)||
','||' p_ra_rec.comments='||p_ra_rec.comments||
','||' p_ra_rec.confirmed_flag='||p_ra_rec.confirmed_flag||
','||' p_ra_rec.customer_trx_id='||TO_CHAR( p_ra_rec.customer_trx_id)||
','||' p_ra_rec.days_late='||TO_CHAR( p_ra_rec.days_late)||
','||' p_ra_rec.earned_discount_taken='||TO_CHAR( p_ra_rec.earned_discount_taken)||
','||' p_ra_rec.freight_applied='||TO_CHAR( p_ra_rec.freight_applied)||
','||' p_ra_rec.gl_posted_date='||TO_CHAR( p_ra_rec.gl_posted_date)||
','||' p_ra_rec.line_applied='||TO_CHAR( p_ra_rec.line_applied)||
','||' p_ra_rec.postable='||p_ra_rec.postable||
','||' p_ra_rec.posting_control_id='||TO_CHAR( p_ra_rec.posting_control_id)||
','||' p_ra_rec.receivables_charges_applied='||TO_CHAR( p_ra_rec.receivables_charges_applied)||
','||' p_ra_rec.tax_applied='||TO_CHAR( p_ra_rec.tax_applied)||
','||' p_ra_rec.unearned_discount_taken='||TO_CHAR( p_ra_rec.unearned_discount_taken)||
','||' p_ra_rec.unearned_discount_ccid='||TO_CHAR( p_ra_rec.unearned_discount_ccid)||
','||' p_ra_rec.earned_discount_ccid='||TO_CHAR( p_ra_rec.earned_discount_ccid)||
','||' p_ra_rec.ussgl_transaction_code='||p_ra_rec.ussgl_transaction_code||
','||' p_ra_rec.attribute_category='||p_ra_rec.attribute_category||
','||' p_ra_rec.attribute1='||p_ra_rec.attribute1||
','||' p_ra_rec.attribute2='||p_ra_rec.attribute2||
','||' p_ra_rec.attribute3='||p_ra_rec.attribute3||
','||' p_ra_rec.attribute4='||p_ra_rec.attribute4||
','||' p_ra_rec.attribute5='||p_ra_rec.attribute5||
','||' p_ra_rec.attribute6='||p_ra_rec.attribute6||
','||' p_ra_rec.attribute7='||p_ra_rec.attribute7||
','||' p_ra_rec.attribute8='||p_ra_rec.attribute8||
','||' p_ra_rec.attribute9='||p_ra_rec.attribute9||
','||' p_ra_rec.attribute10='||p_ra_rec.attribute10||
','||' p_ra_rec.attribute11='||p_ra_rec.attribute11||
','||' p_ra_rec.attribute12='||p_ra_rec.attribute12||
','||' p_ra_rec.attribute13='||p_ra_rec.attribute13||
','||' p_ra_rec.attribute14='||p_ra_rec.attribute14||
','||' p_ra_rec.attribute15='||p_ra_rec.attribute15||
','||' p_ra_rec.global_attribute_category='||p_ra_rec.global_attribute_category||
','||' p_ra_rec.global_attribute1='||p_ra_rec.global_attribute1||
','||' p_ra_rec.global_attribute2='||p_ra_rec.global_attribute2||
','||' p_ra_rec.global_attribute3='||p_ra_rec.global_attribute3||
','||' p_ra_rec.global_attribute4='||p_ra_rec.global_attribute4||
','||' p_ra_rec.global_attribute5='||p_ra_rec.global_attribute5||
','||' p_ra_rec.global_attribute6='||p_ra_rec.global_attribute6||
','||' p_ra_rec.global_attribute7='||p_ra_rec.global_attribute7||
','||' p_ra_rec.global_attribute8='||p_ra_rec.global_attribute8||
','||' p_ra_rec.global_attribute9='||p_ra_rec.global_attribute9||
','||' p_ra_rec.global_attribute10='||p_ra_rec.global_attribute10||
','||' p_ra_rec.global_attribute11='||p_ra_rec.global_attribute11||
','||' p_ra_rec.global_attribute12='||p_ra_rec.global_attribute12||
','||' p_ra_rec.global_attribute13='||p_ra_rec.global_attribute13||
','||' p_ra_rec.global_attribute14='||p_ra_rec.global_attribute14||
','||' p_ra_rec.global_attribute15='||p_ra_rec.global_attribute15||
','||' p_ra_rec.global_attribute16='||p_ra_rec.global_attribute16||
','||' p_ra_rec.global_attribute17='||p_ra_rec.global_attribute17||
','||' p_ra_rec.global_attribute18='||p_ra_rec.global_attribute18||
','||' p_ra_rec.global_attribute19='||p_ra_rec.global_attribute19||
','||' p_ra_rec.global_attribute20='||p_ra_rec.global_attribute20||
','||' p_ra_rec.ussgl_transaction_code_context='||p_ra_rec.ussgl_transaction_code_context||
','||' p_ra_rec.reversal_gl_date='||TO_CHAR( p_ra_rec.reversal_gl_date)||
','||' p_ra_rec.line_ediscounted='||to_char(p_ra_rec.line_ediscounted)||
','||' p_ra_rec.line_uediscounted='||to_char(p_ra_rec.line_uediscounted)||
','||' p_ra_rec.tax_ediscounted='||to_char(p_ra_rec.tax_ediscounted)||
','||' p_ra_rec.tax_uediscounted='||to_char(p_ra_rec.tax_uediscounted)||
','||' p_ra_rec.freight_ediscounted='||to_char(p_ra_rec.freight_ediscounted)||
','||' p_ra_rec.freight_uediscounted='||to_char(p_ra_rec.freight_uediscounted)||
','||' p_ra_rec.charges_ediscounted='||to_char(p_ra_rec.charges_ediscounted)||
','||' p_ra_rec.charges_uediscounted='||to_char(p_ra_rec.charges_uediscounted)||
','||' p_ra_rec.rule_set_id='||to_char(p_ra_rec.rule_set_id)||
','||' p_ra_rec.cash_receipt_history_id='||TO_CHAR( p_ra_rec.cash_receipt_history_id)||
','||' p_ra_rec.tax_code='||p_ra_rec.tax_code||
','||' p_ra_rec.unedisc_tax_acct_rule='||p_ra_rec.unedisc_tax_acct_rule||
','||' p_ra_rec.edisc_tax_acct_rule='||p_ra_rec.edisc_tax_acct_rule||
','||' application_ref_type='||p_ra_rec.application_ref_type||
','||' application_ref_id='||p_ra_rec.application_ref_id||
','||' application_ref_num='||p_ra_rec.application_ref_num||
','||' secondary_application_ref_id='||to_char(p_ra_rec.secondary_application_ref_id)||
','||' secondary_application_ref_type='||p_ra_rec.secondary_application_ref_type||
','||' secondary_application_ref_num='||p_ra_rec.secondary_application_ref_num||
','||' payment_set_id='||to_char(p_ra_rec.payment_set_id)||
','||' application_ref_reason ='||p_ra_rec.application_ref_reason||
','||' customer_reference='||p_ra_rec.customer_reference||
','||' customer_reason='||p_ra_rec.customer_reason||
','||' applied_rec_app_id='||to_char(p_ra_rec.applied_rec_app_id);

       FND_MESSAGE.set_name ('AR','GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',lc_dump);
       APP_EXCEPTION.raise_exception;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row from AR_RECEIVABLE_APPLICATIONS table      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ra_id - receivable applications id of row to be deleted|
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 |  09/09/02  M Ryzhikova       Modified for MRC trigger elimination proj    |
 |                              added call to ar_mrc_engine for processing   |
 |                              delete from ar_receivable_applications       |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p(
      p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE ) IS
BEGIN
    arp_standard.debug( 'arp_app_pkg.delete_p()+' );

    DELETE FROM ar_receivable_applications ra
    WHERE ra.receivable_application_id = p_ra_id;

                 /*----------------------------------------------------+
                 | Calling central MRC library for MRC Integration.    |
                 | Do not need a call for insert or delete             |
                 +-----------------------------------------------------*/
--{BUG4301323
--                ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode        => 'DELETE',
--                        p_table_name        => 'AR_RECEIVABLE_APPLICATIONS',
--                        p_mode              => 'SINGLE',
--                        p_key_value         => p_ra_id);
--}

    arp_standard.debug( 'arp_app_pkg.delete_p()-' );
    EXCEPTION
        WHEN  OTHERS THEN
            arp_standard.debug(
			'EXCEPTION: arp_app_pkg.delete_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_id                                                         |
 | DESCRIPTION                                                               |
 |    This function deletes a row from AR_RECEIVABLE_APPLICATIONS table      |
 |    for a Credit Memo taking custoemr_trx_id as parameter                  |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_customer_trx_id - customertrx_id of row to be              |
 |              deleted                                                      |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Veena Rao - 07/24/02                    |
 |                                                                           |
 | 16-Sep-02   Debbie Jancis		Modified for MRC trigger replacement |
 | 					added calls to mrc engine for        |
 |                                      processing deletes from ar rec apps  |
 +===========================================================================*/
-- bugfix 2217253
PROCEDURE delete_f_ct_id(
      p_customer_trx_id IN ar_receivable_applications.customer_trx_id%TYPE ) IS
CURSOR c_ra_rec IS select receivable_application_id
                        from ar_receivable_applications
                        where customer_trx_id  = p_customer_trx_id;

 l_ar_dist_key_value_list   gl_ca_utility_pkg.r_key_value_arr;

BEGIN
    arp_standard.debug( 'arp_app_pkg.delete_f_ct_id()+' );
    FOR i IN c_ra_rec LOOP

       DELETE FROM ar_receivable_applications ra
       WHERE ra.receivable_application_id = i.receivable_application_id;

       /*---------------------------------+
        | Calling central MRC library     |
        | for MRC Integration             |
        +---------------------------------*/
--{BUG#4301323
--        ar_mrc_engine.maintain_mrc_data(
--                 p_event_mode        => 'DELETE',
--                 p_table_name        => 'AR_RECEIVABLE_APPLICATIONS',
--                 p_mode              => 'SINGLE',
--                 p_key_value         => i.receivable_application_id);
--}
       DELETE FROM ar_distributions
       WHERE  source_table = 'RA'
         AND  source_type = 'REC'
         AND source_id = i.receivable_application_id
              RETURNING line_id
       BULK COLLECT INTO l_ar_dist_key_value_list;

       /*---------------------------------+
        | Calling central MRC library     |
        | for MRC Integration             |
        +---------------------------------*/
--{BUG4301323
--        ar_mrc_engine.maintain_mrc_data(
--                 p_event_mode        => 'DELETE',
--                 p_table_name        => 'AR_DISTRIBUTIONS',
--                 p_mode              => 'BATCH',
--                 p_key_value_list    => l_ar_dist_key_value_list);
--}
    END LOOP;
    arp_standard.debug( 'arp_app_pkg.delete_f_ct_id()-' );
    EXCEPTION
        WHEN  OTHERS THEN
            NULL;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function locks a row in AR_RECEIVABLE_APPLICATIONS table          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ra_id - Receivable applications id of row to be locked |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_p(
     p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE ) IS
l_ra_id		ar_receivable_applications.receivable_application_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_app_pkg.lock_p()+');
    END IF;

    SELECT ra.receivable_application_id
    INTO   l_ra_id
    FROM  ar_receivable_applications ra
    WHERE ra.receivable_application_id = p_ra_id
    FOR UPDATE OF STATUS NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_app_pkg.lock_p()-');
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_app_pkg.lock_p' );
            END IF;
            RAISE;
END lock_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 | 	NOWAITLOCK_P							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |	This function locks a row in AR_RECEIVABLE_APPLICATIONS table.       |
 |	If row is already locked procedure will return error code ORA-0054   |
 |	(normal NOWAIT error code if already locked).                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ra_id - Receivable applications id of row to be locked |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY							     |
 | 1/26/1996	Harri Kaukovuo		Created                              |
 +===========================================================================*/
PROCEDURE nowaitlock_p(
     p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE ) IS
l_ra_id		ar_receivable_applications.receivable_application_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_app_pkg.nowaitlock_p()+');
    END IF;

    SELECT ra.receivable_application_id
    INTO   l_ra_id
    FROM  ar_receivable_applications ra
    WHERE ra.receivable_application_id = p_ra_id
    FOR UPDATE OF STATUS NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_app_pkg.nowaitlock_p()-');
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_app_pkg.nowaitlock_p' );
            END IF;
            RAISE;
END nowaitlock_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function fetches a row from AR_RECEIVABLE_APPLICATIONS table      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_ra_id - Receivable applications id of row to be fetched|
 |              OUT:                                                         |
 |                  p_ra_rec - Receivable applications record structure      |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_p(
        p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE,
        p_ra_rec OUT NOCOPY ar_receivable_applications%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_app_pkg.fetch_p()+' );
    END IF;

    SELECT *
    INTO   p_ra_rec
    FROM   ar_receivable_applications
    WHERE  receivable_application_id = p_ra_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_app_pkg.fetch_p()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('fetch_p: ' ||  'EXCEPTION: arp_app_pkg error' );
              END IF;
              RAISE;

END fetch_p;

END  ARP_APP_PKG;


/
