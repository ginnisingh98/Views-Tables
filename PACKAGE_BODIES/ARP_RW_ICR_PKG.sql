--------------------------------------------------------
--  DDL for Package Body ARP_RW_ICR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RW_ICR_PKG" AS
/* $Header: ARERICRB.pls 120.7.12010000.3 2009/02/02 16:46:38 mpsingh ship $ */
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE validate_args_insert_row(
            p_row_id  IN VARCHAR2,
            p_cr_id  IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_receipt_date IN ar_interim_cash_receipts.receipt_date%TYPE,
            p_gl_date IN ar_interim_cash_receipts.gl_date%TYPE,
            p_batch_id IN ar_interim_cash_receipts.batch_id%TYPE,
            p_pay_from_customer IN
                 ar_interim_cash_receipts.pay_from_customer%TYPE,
            p_site_use_id IN
                 ar_interim_cash_receipts.site_use_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                          ar_payment_schedules.payment_schedule_id%TYPE,
            p_currency_code IN ar_interim_cash_receipts.currency_code%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
            p_receipt_method_id IN
                 ar_interim_cash_receipts.receipt_method_id%TYPE,
            p_remittance_bank_account_id IN
                 ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE );
--
PROCEDURE validate_args_update_row(
            p_row_id   IN VARCHAR2,
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_batch_id IN ar_interim_cash_receipts.batch_id%TYPE,
            p_pay_from_customer IN
                 ar_interim_cash_receipts.pay_from_customer%TYPE,
            p_site_use_id IN
                 ar_interim_cash_receipts.site_use_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                          ar_payment_schedules.payment_schedule_id%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
            p_receipt_method_id IN
                 ar_interim_cash_receipts.receipt_method_id%TYPE,
            p_remittance_bank_account_id IN
                 ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE );
--
PROCEDURE validate_special_type(
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_pay_from_customer IN
                 ar_interim_cash_receipts.pay_from_customer%TYPE,
            p_site_use_id IN
                 ar_interim_cash_receipts.site_use_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                          ar_payment_schedules.payment_schedule_id%TYPE );
--
PROCEDURE val_args_applied_amount_total(
                 p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE );
PROCEDURE val_args_check_unique_receipt(
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE );
--
PROCEDURE update_bank_account_uses(
            p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
            p_bank_account_id IN ar_batches.remit_bank_acct_use_id%TYPE );
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_row   -  Update a row in the AR_ICR     table after checking for|
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row in AR_ICR     table after checking for     |
 |    uniqueness for items of the receipt                                    |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id - Row ID                                         |
 |                 p_cr_id  - Cash receipt Id                                |
 |                 p_receipt_number - Receipt Number                         |
 |                 p_gl_date - GL Date                                       |
 |                 p_customer_id - Customer ID                               |
 |                 p_receipt_amount - Receipt Amount                         |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This procedure calls the check_unique_receipt procedure           |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee	     	     |
 |                                                                           |
 | 10-21-96	OSTEINME	Added new parameters p_factor_discount_amount|
 |				and p_customer_bank_account_id for Japan     |
 |				project.				     |
 |				Also added new parameter		     |
 |				p_anticipated_clearing_date for bug 371373   |
 | 10-28-96	OSTEINME	added new parameter customer_bank_branch_id  |
 | 08-25-97     KLAWRANC	Bug fix #462056.                             |
 |                       Uncommented out NOCOPY call to update_bank_uses.    |
 |                              Changed call to pass                         |
 |                              p_customer_bank_account_id.                  |
 | 10-28-98     K.Murphy  Cross Currency Lockbox.  Added amount_applied      |
 |                        and trans_to_receipt_rate as parameters and updated|
 |                        columns.                                           |
 | 12-24-98     D.Jancis        Bug 750400: Added GL_DATE as it was not      |
 |                              being passed in thus not getting updated     |
 | 05-01-02	D.Jancis	Enh 2074220: added application notes         |
 |                              procedures.                                  |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason to update and insert       |
 |                                procedures.                                |
 +===========================================================================*/

-- Bug fix: 597519  	12/18/97
-- Problem: rate information is not being passed to server on commit
-- Changes: passing parameters exchange date, exchange rate and
--          exchange rate type to PROCEDURE update_row
--

PROCEDURE update_row(
            p_row_id   IN VARCHAR2,
            p_cr_id   IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
            p_amount_applied IN
                       ar_interim_cash_receipts.amount_applied%TYPE,
            p_trans_to_receipt_rate IN
                       ar_interim_cash_receipts.trans_to_receipt_rate%TYPE,
	    p_factor_discount_amount IN
			ar_interim_cash_receipts.factor_discount_amount%TYPE,
            p_receipt_method_id IN
                   ar_interim_cash_receipts.receipt_method_id%TYPE,
            p_remittance_bank_account_id IN
                   ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE,
            p_batch_id IN ar_interim_cash_receipts.batch_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_pay_from_customer IN
                   ar_interim_cash_receipts.pay_from_customer%TYPE,
	    p_customer_bank_account_id IN
		   ar_interim_cash_receipts.customer_bank_account_id%TYPE,
	    p_customer_bank_branch_id IN
		   ar_interim_cash_receipts.customer_bank_branch_id%TYPE,
            p_site_use_id IN ar_interim_cash_receipts.site_use_id%TYPE,
            p_ussgl_transaction_code IN
                   ar_interim_cash_receipts.ussgl_transaction_code%TYPE,
            p_doc_sequence_id IN ar_interim_cash_receipts.doc_sequence_id%TYPE,
            p_doc_sequence_value IN
                           ar_interim_cash_receipts.doc_sequence_value%TYPE,
	    p_anticipated_clearing_date IN
		   ar_interim_cash_receipts.anticipated_clearing_date%TYPE,
            p_attribute_category IN
                           ar_interim_cash_receipts.attribute_category%TYPE,
            p_attribute1 IN ar_interim_cash_receipts.attribute1%TYPE,
            p_attribute2 IN ar_interim_cash_receipts.attribute2%TYPE,
            p_attribute3 IN ar_interim_cash_receipts.attribute3%TYPE,
            p_attribute4 IN ar_interim_cash_receipts.attribute4%TYPE,
            p_attribute5 IN ar_interim_cash_receipts.attribute5%TYPE,
            p_attribute6 IN ar_interim_cash_receipts.attribute6%TYPE,
            p_attribute7 IN ar_interim_cash_receipts.attribute7%TYPE,
            p_attribute8 IN ar_interim_cash_receipts.attribute8%TYPE,
            p_attribute9 IN ar_interim_cash_receipts.attribute9%TYPE,
            p_attribute10 IN ar_interim_cash_receipts.attribute10%TYPE,
            p_attribute11 IN ar_interim_cash_receipts.attribute11%TYPE,
            p_attribute12 IN ar_interim_cash_receipts.attribute12%TYPE,
            p_attribute13 IN ar_interim_cash_receipts.attribute13%TYPE,
            p_attribute14 IN ar_interim_cash_receipts.attribute14%TYPE,
            p_attribute15 IN ar_interim_cash_receipts.attribute15%TYPE,
-- Bug fix: 597519  	12/18/97
            p_exchange_date IN ar_interim_cash_receipts.exchange_date%TYPE,
            p_exchange_rate IN ar_interim_cash_receipts.exchange_rate%TYPE,
            p_exchange_rate_type IN
                   ar_interim_cash_receipts.exchange_rate_type%TYPE,
-- Bug fix: 750400      12/24/98
            p_gl_date  IN ar_interim_cash_receipts.gl_date%TYPE,
-- enh 2074220
            p_application_notes IN
                     ar_interim_cash_receipts.application_notes%TYPE,
            p_application_ref_type IN
                     ar_interim_cash_receipts.application_ref_type%TYPE,
            p_customer_reference IN
                     ar_interim_cash_receipts.customer_reference%TYPE,
            p_customer_reason IN ar_interim_cash_receipts.customer_reason%TYPE,
	    p_automatch_set_id IN ar_interim_cash_receipts.automatch_set_id%TYPE,
            p_autoapply_flag IN ar_interim_cash_receipts.autoapply_flag%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
--
l_icr_rec   ar_interim_cash_receipts%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_pkg.update_row()+' );
       arp_util.debug(  'Special Type      : '||p_special_type );
       arp_util.debug(  'Receipt Id        : '||p_cr_id );
       arp_util.debug(  'Row Id            : '||p_row_id );
       arp_util.debug(  'Receipt Number    : '||p_receipt_number );
       arp_util.debug(  'Received Amount   : '||TO_CHAR( p_receipt_amount ) );
       arp_util.debug(  'Amount Applied    : '||TO_CHAR( p_amount_applied ) );
       arp_util.debug(  'Cross Currency Rate: '||TO_CHAR( p_trans_to_receipt_rate) );
       arp_util.debug(  'Bank Charges      : '||TO_CHAR( p_factor_discount_amount ) );
    END IF;
    arp_util.debug( 'Receipt Amount   : ' ||TO_CHAR( p_receipt_amount +
					p_factor_discount_amount) );
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'Method Id         : '||p_receipt_method_id );
       arp_util.debug(  'Bank Account Use Id : '||p_remittance_bank_account_id );
       arp_util.debug(  'Receipt Amount    : '||p_receipt_amount );
       arp_util.debug(  'Batch Id          : '||p_batch_id );
       arp_util.debug(  'Pay From Customer : '||p_pay_from_customer );
       arp_util.debug(  'Cust. Bank Acct. ID: ' || p_customer_bank_account_id );
       arp_util.debug(  'Cust. Bank Branch ID: ' || p_customer_bank_branch_id);
       arp_util.debug(  'Site Use ID       : '||p_site_use_id );
       arp_util.debug(  'Anticipated Clearing Date: ' || p_anticipated_clearing_date);
       arp_util.debug(  'Automatch set id       : '|| p_automatch_set_id );
       arp_util.debug(  'Autoapply flag: ' || p_autoapply_flag);
    END IF;
    --
    arp_cr_icr_pkg.set_to_dummy( l_icr_rec );
    --
    -- Populate ICR record structure
    --
    l_icr_rec.cash_receipt_id := p_cr_id;
    l_icr_rec.amount := p_receipt_amount;
    l_icr_rec.amount_applied := p_amount_applied;
    l_icr_rec.trans_to_receipt_rate := p_trans_to_receipt_rate;
    l_icr_rec.factor_discount_amount := p_factor_discount_amount;
    l_icr_rec.receipt_method_id := p_receipt_method_id;
    l_icr_rec.remit_bank_acct_use_id := p_remittance_bank_account_id;
    l_icr_rec.batch_id := p_batch_id;
    l_icr_rec.customer_trx_id := p_customer_trx_id;
    l_icr_rec.payment_schedule_id := p_payment_schedule_id;
-- Bug fix: 597519 	12/18/97
    l_icr_rec.exchange_date := p_exchange_date;
    l_icr_rec.exchange_rate := p_exchange_rate;
    l_icr_rec.exchange_rate_type := p_exchange_rate_type;
-- Bug fix: 750400      12/24/98
    l_icr_rec.gl_date := p_gl_date;
--
    l_icr_rec.pay_from_customer := p_pay_from_customer;
    l_icr_rec.customer_bank_account_id := p_customer_bank_account_id;
    l_icr_rec.customer_bank_branch_id := p_customer_bank_branch_id;
    l_icr_rec.receipt_number := p_receipt_number;
    l_icr_rec.site_use_id := p_site_use_id;
    l_icr_rec.special_type := p_special_type;
    l_icr_rec.anticipated_clearing_date := p_anticipated_clearing_date;
    --
    l_icr_rec.status := 'UNAPP';
    l_icr_rec.type := 'CASH';
    --
    l_icr_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_icr_rec.attribute_category := p_attribute_category;
    l_icr_rec.attribute1 := p_attribute1;
    l_icr_rec.attribute2 := p_attribute2;
    l_icr_rec.attribute3 := p_attribute3;
    l_icr_rec.attribute4 := p_attribute4;
    l_icr_rec.attribute5 := p_attribute5;
    l_icr_rec.attribute6 := p_attribute6;
    l_icr_rec.attribute7 := p_attribute7;
    l_icr_rec.attribute8 := p_attribute8;
    l_icr_rec.attribute9 := p_attribute9;
    l_icr_rec.attribute10 := p_attribute10;
    l_icr_rec.attribute11 := p_attribute11;
    l_icr_rec.attribute12 := p_attribute12;
    l_icr_rec.attribute13 := p_attribute13;
    l_icr_rec.attribute14 := p_attribute14;
    l_icr_rec.attribute15 := p_attribute15;
    l_icr_rec.doc_sequence_id := p_doc_sequence_id;
    l_icr_rec.doc_sequence_value := p_doc_sequence_value;
    l_icr_rec.application_notes := p_application_notes;
--  Bug 2707190 additions
    l_icr_rec.application_ref_type := p_application_ref_type;
    l_icr_rec.customer_reference := p_customer_reference;
    l_icr_rec.customer_reason := p_customer_reason;
    l_icr_rec.automatch_set_id := p_automatch_set_id;
    l_icr_rec.autoapply_flag := p_autoapply_flag;
    --
    -- Validate arguments
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_update_row( p_row_id, l_icr_rec.cash_receipt_id,
				   l_icr_rec.special_type,
                                   l_icr_rec.receipt_number,
                                   l_icr_rec.batch_id,
                                   l_icr_rec.pay_from_customer,
                                   l_icr_rec.site_use_id,
 				   l_icr_rec.customer_trx_id,
 				   l_icr_rec.payment_schedule_id,
                                   l_icr_rec.amount,
                                   l_icr_rec.receipt_method_id,
                                   l_icr_rec.remit_bank_acct_use_id );
    END IF;
    --
    -- Call Check Unique Batch Name procedure
    --
    arp_rw_icr_pkg.check_unique_receipt( p_row_id, l_icr_rec.cash_receipt_id,
                                         l_icr_rec.special_type,
                                         l_icr_rec.receipt_number,
                                         l_icr_rec.pay_from_customer,
                                         l_icr_rec.amount,
					 l_icr_rec.factor_discount_amount,
                                         NULL, NULL );
    --
    -- Call update table handler
    --
    arp_cr_icr_pkg.update_p( l_icr_rec, l_icr_rec.cash_receipt_id );
    --
    -- Update batch table to set status
    --
    IF ( p_batch_id IS NOT NULL ) THEN
        arp_rw_batches_check_pkg.update_batch_status( p_batch_id );
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_pkg.update_row()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(  'EXCEPTION: arp_rw_icr_pkg.update_row' );
             END IF;
             RAISE;
END update_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_update_row                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to update_row   procedure                    |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_receipt_number - Receipt Number                         |
 |                 p_gl_date - GL Date                                       |
 |                 p_customer_id - Customer ID                               |
 |                 p_receipt_amount - Receipt Amount                         |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 08/08/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_update_row(
            p_row_id   IN VARCHAR2,
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_batch_id IN ar_interim_cash_receipts.batch_id%TYPE,
            p_pay_from_customer IN
                 ar_interim_cash_receipts.pay_from_customer%TYPE,
            p_site_use_id IN
                 ar_interim_cash_receipts.site_use_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                          ar_payment_schedules.payment_schedule_id%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
            p_receipt_method_id IN
                 ar_interim_cash_receipts.receipt_method_id%TYPE,
            p_remittance_bank_account_id IN
                 ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_pkg.validate_args_update_row()+' );
    END IF;
    --
    IF ( p_row_id IS NULL OR p_cr_id IS NULL OR
         p_receipt_number IS NULL OR p_receipt_amount IS NULL OR
         p_batch_id IS NULL OR p_remittance_bank_account_id IS NULL OR
         p_receipt_method_id IS NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    validate_special_type( p_special_type, p_pay_from_customer,
                           p_site_use_id, p_customer_trx_id,
			   p_payment_schedule_id );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_pkg.validate_args_update_row()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
		     'EXCEPTION: arp_rw_icr_pkg.validate_args_update_row' );
              END IF;
              RAISE;
END validate_args_update_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_row   -  Inserts a row into the QRC_ICR table after checking for|
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function Inserts a row into the QRC_ICR table after checking for  |
 |    uniqueness for items such of the receipt number                        |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_receipt_number - Receipt Number                         |
 |                 p_gl_date - GL Date                                       |
 |                 p_customer_id - Customer ID                               |
 |                 p_receipt_amount - Receipt Amount                         |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                 p_row_id - Row ID                                         |
 |                 p_cr_id  - Cash receipt Id                                |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This procedure calls the check_unique_receipt procedure           |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee	     	     |
 | 10-21-96	OSTEINME	Added new parameters p_factor_discount_amount|
 |				and p_customer_bank_account_id for Japan     |
 |				project.				     |
 |				Also added new parameter		     |
 |				p_anticipated_clearing_date for bug 371373   |
 | 10-28-96	OSTEINME	added parameter customer_bank_branch_id	     |
 | 10-28-98     K.Murphy  Cross Currency Lockbox.  Added amount_applied      |
 |                        and trans_to_receipt_rate as parameters and created|
 |                        columns.                                           |
 | 05-01-02     D.Jancis   	Enh 2074220: added application notes         |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason to update and insert       |
 |                                procedures.                                |
 +===========================================================================*/
PROCEDURE insert_row(
            p_row_id   IN OUT NOCOPY VARCHAR2,
            p_cr_id   IN OUT NOCOPY ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_currency_code IN ar_interim_cash_receipts.currency_code%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
            p_amount_applied IN
                       ar_interim_cash_receipts.amount_applied%TYPE,
            p_trans_to_receipt_rate IN
                       ar_interim_cash_receipts.trans_to_receipt_rate%TYPE,
	    p_factor_discount_amount
		IN ar_interim_cash_receipts.factor_discount_amount%TYPE,
            p_receipt_method_id IN
                   ar_interim_cash_receipts.receipt_method_id%TYPE,
            p_remittance_bank_account_id IN
                   ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE,
            p_batch_id IN ar_interim_cash_receipts.batch_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_exchange_date IN ar_interim_cash_receipts.exchange_date%TYPE,
            p_exchange_rate IN ar_interim_cash_receipts.exchange_rate%TYPE,
            p_exchange_rate_type IN
                   ar_interim_cash_receipts.exchange_rate_type%TYPE,
            p_gl_date IN ar_interim_cash_receipts.gl_date%TYPE,
	    p_anticipated_clearing_date IN
		   ar_interim_cash_receipts.anticipated_clearing_date%TYPE,
            p_pay_from_customer IN
                   ar_interim_cash_receipts.pay_from_customer%TYPE,
	    p_customer_bank_account_id IN
		   ar_interim_cash_receipts.customer_bank_account_id%TYPE,
	    p_customer_bank_branch_id IN
		   ar_interim_cash_receipts.customer_bank_branch_id%TYPE,
            p_receipt_date IN ar_interim_cash_receipts.receipt_date%TYPE,
            p_site_use_id IN ar_interim_cash_receipts.site_use_id%TYPE,
            p_ussgl_transaction_code IN
                   ar_interim_cash_receipts.ussgl_transaction_code%TYPE,
            p_doc_sequence_id IN ar_interim_cash_receipts.doc_sequence_id%TYPE,
            p_doc_sequence_value IN
                           ar_interim_cash_receipts.doc_sequence_value%TYPE,
            p_attribute_category IN
                           ar_interim_cash_receipts.attribute_category%TYPE,
            p_attribute1 IN ar_interim_cash_receipts.attribute1%TYPE,
            p_attribute2 IN ar_interim_cash_receipts.attribute2%TYPE,
            p_attribute3 IN ar_interim_cash_receipts.attribute3%TYPE,
            p_attribute4 IN ar_interim_cash_receipts.attribute4%TYPE,
            p_attribute5 IN ar_interim_cash_receipts.attribute5%TYPE,
            p_attribute6 IN ar_interim_cash_receipts.attribute6%TYPE,
            p_attribute7 IN ar_interim_cash_receipts.attribute7%TYPE,
            p_attribute8 IN ar_interim_cash_receipts.attribute8%TYPE,
            p_attribute9 IN ar_interim_cash_receipts.attribute9%TYPE,
            p_attribute10 IN ar_interim_cash_receipts.attribute10%TYPE,
            p_attribute11 IN ar_interim_cash_receipts.attribute11%TYPE,
            p_attribute12 IN ar_interim_cash_receipts.attribute12%TYPE,
            p_attribute13 IN ar_interim_cash_receipts.attribute13%TYPE,
            p_attribute14 IN ar_interim_cash_receipts.attribute14%TYPE,
            p_attribute15 IN ar_interim_cash_receipts.attribute15%TYPE,
            p_application_notes IN
                  ar_interim_cash_receipts.application_notes%TYPE,
            p_application_ref_type IN
                     ar_interim_cash_receipts.application_ref_type%TYPE,
            p_customer_reference IN
                     ar_interim_cash_receipts.customer_reference%TYPE,
            p_customer_reason IN ar_interim_cash_receipts.customer_reason%TYPE,
	    p_automatch_set_id IN ar_interim_cash_receipts.automatch_set_id%TYPE,
            p_autoapply_flag IN ar_interim_cash_receipts.autoapply_flag%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
--
l_row_id    VARCHAR2(30);
l_cr_id     ar_interim_cash_receipts.cash_receipt_id%TYPE;
l_icr_rec   ar_interim_cash_receipts%ROWTYPE;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_pkg.insert_row()+' );
       arp_util.debug(  'Special Type      : '||p_special_type );
       arp_util.debug(  'Receipt Number    : '||p_receipt_number );
       arp_util.debug(  'Receipt Date      : '||TO_CHAR( p_receipt_date ) );
       arp_util.debug(  'GL Date           : '||TO_CHAR( p_gl_date ) );
       arp_util.debug(  'Received Amount   : '||TO_CHAR( p_receipt_amount ) );
       arp_util.debug(  'Amount Applied    : '||TO_CHAR( p_amount_applied ) );
       arp_util.debug(  'Cross Currency Rate: '||TO_CHAR( p_trans_to_receipt_rate) );
       arp_util.debug(  'Bank Charges      : '||TO_CHAR( p_factor_discount_amount ));
       arp_util.debug(  'currency_code     : '||p_currency_code );
       arp_util.debug(  'Method Id         : '||p_receipt_method_id );
       arp_util.debug(  'Bank Account Id   : '||p_remittance_bank_account_id );
       arp_util.debug(  'Receipt Amount    : '||p_receipt_amount );
       arp_util.debug(  'Batch Id          : '||p_batch_id );
       arp_util.debug(  'Pay From Customer : '||p_pay_from_customer );
       arp_util.debug(  'Cust Bank Acct ID : '||p_customer_bank_account_id );
       arp_util.debug(  'Cust Bank Branch ID : '||p_customer_bank_branch_id );
       arp_util.debug(  'Site Use ID       : '||p_site_use_id );
       arp_util.debug(  'Automatch set id       : '|| p_automatch_set_id );
       arp_util.debug(  'Autoapply flag: ' || p_autoapply_flag);
    END IF;
    --
    l_icr_rec.amount := p_receipt_amount;
    l_icr_rec.amount_applied := p_amount_applied;
    l_icr_rec.trans_to_receipt_rate := p_trans_to_receipt_rate;
    l_icr_rec.factor_discount_amount := p_factor_discount_amount;
    l_icr_rec.currency_code := p_currency_code;
    l_icr_rec.receipt_method_id := p_receipt_method_id;
    l_icr_rec.remit_bank_acct_use_id := p_remittance_bank_account_id;
    l_icr_rec.batch_id := p_batch_id;
    l_icr_rec.customer_trx_id := p_customer_trx_id;
    l_icr_rec.exchange_date := p_exchange_date;
    l_icr_rec.exchange_rate := p_exchange_rate;
    l_icr_rec.exchange_rate_type := p_exchange_rate_type;
    l_icr_rec.gl_date := p_gl_date;
    l_icr_rec.payment_schedule_id := p_payment_schedule_id;
    l_icr_rec.pay_from_customer := p_pay_from_customer;
    l_icr_rec.customer_bank_account_id := p_customer_bank_account_id;
    l_icr_rec.customer_bank_branch_id := p_customer_bank_branch_id;
    l_icr_rec.receipt_date := p_receipt_date;
    l_icr_rec.anticipated_clearing_date := p_anticipated_clearing_date;
    l_icr_rec.receipt_number := p_receipt_number;
    l_icr_rec.site_use_id := p_site_use_id;
    l_icr_rec.special_type := p_special_type;
    --
    l_icr_rec.status := 'UNAPP';
    l_icr_rec.type := 'CASH';
    --
    l_icr_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_icr_rec.attribute_category := p_attribute_category;
    l_icr_rec.attribute1 := p_attribute1;
    l_icr_rec.attribute2 := p_attribute2;
    l_icr_rec.attribute3 := p_attribute3;
    l_icr_rec.attribute4 := p_attribute4;
    l_icr_rec.attribute5 := p_attribute5;
    l_icr_rec.attribute6 := p_attribute6;
    l_icr_rec.attribute7 := p_attribute7;
    l_icr_rec.attribute8 := p_attribute8;
    l_icr_rec.attribute9 := p_attribute9;
    l_icr_rec.attribute10 := p_attribute10;
    l_icr_rec.attribute11 := p_attribute11;
    l_icr_rec.attribute12 := p_attribute12;
    l_icr_rec.attribute13 := p_attribute13;
    l_icr_rec.attribute14 := p_attribute14;
    l_icr_rec.attribute15 := p_attribute15;
    l_icr_rec.doc_sequence_id := p_doc_sequence_id;
    l_icr_rec.doc_sequence_value := p_doc_sequence_value;

    --
    --  enh 2074220
    --
    l_icr_rec.application_notes := p_application_notes;

    --
    --  Bug 2707190 Deductions Enhancement
    --

    l_icr_rec.application_ref_type := p_application_ref_type;
    l_icr_rec.customer_reference := p_customer_reference;
    l_icr_rec.customer_reason := p_customer_reason;
    l_icr_rec.automatch_set_id := p_automatch_set_id;
    l_icr_rec.autoapply_flag := p_autoapply_flag;

    --
    -- Validate arguments
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_insert_row( p_row_id, p_cr_id,
                                   l_icr_rec.special_type,
                                   l_icr_rec.receipt_number,
                                   l_icr_rec.receipt_date,
                                   l_icr_rec.gl_date,
                                   l_icr_rec.batch_id,
                                   l_icr_rec.pay_from_customer,
                                   l_icr_rec.site_use_id,
 				   l_icr_rec.customer_trx_id,
 				   l_icr_rec.payment_schedule_id,
                                   l_icr_rec.currency_code,
                                   l_icr_rec.amount,
                                   l_icr_rec.receipt_method_id,
                                   l_icr_rec.remit_bank_acct_use_id );
    END IF;
    --
    --
    -- Call Check Unique Batch Name procedure
    --
    arp_rw_icr_pkg.check_unique_receipt( l_row_id, l_cr_id,
                                         l_icr_rec.special_type,
                                         l_icr_rec.receipt_number,
                                         l_icr_rec.pay_from_customer,
				         l_icr_rec.amount,
					 l_icr_rec.factor_discount_amount,
                                         NULL, NULL );
    --
    -- Check for valid GL date
    --
    arp_util.validate_gl_date( l_icr_rec.gl_date, NULL,
                               NULL );


    -- Do the actual Insertion
    --
    arp_cr_icr_pkg.insert_p( l_row_id, l_cr_id, l_icr_rec );
    --
    p_row_id := l_row_id;
    p_cr_id := l_cr_id;

    --
    -- Update batch table to set status
    --

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'Batch ID is     : '|| l_icr_rec.batch_id );
    END IF;

    arp_rw_batches_check_pkg.update_batch_status( l_icr_rec.batch_id );


    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(  'arp_rw_icr_pkg.insert_row()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(  'EXCEPTION: arp_rw_icr_pkg.insert_row' );
             END IF;
             RAISE;
END insert_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_insert_row                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to insert_row   procedure                    |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_receipt_number - Receipt Number                         |
 |                 p_gl_date - GL Date                                       |
 |                 p_pay_from_customer - Customer ID                         |
 |                 p_receipt_amount - Receipt Amount                         |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 08/08/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_insert_row(
            p_row_id  IN VARCHAR2,
            p_cr_id  IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
	    p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
	    p_receipt_date IN ar_interim_cash_receipts.receipt_date%TYPE,
	    p_gl_date IN ar_interim_cash_receipts.gl_date%TYPE,
	    p_batch_id IN ar_interim_cash_receipts.batch_id%TYPE,
            p_pay_from_customer IN
                 ar_interim_cash_receipts.pay_from_customer%TYPE,
            p_site_use_id IN
                 ar_interim_cash_receipts.site_use_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                          ar_payment_schedules.payment_schedule_id%TYPE,
            p_currency_code IN ar_interim_cash_receipts.currency_code%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
            p_receipt_method_id IN
                 ar_interim_cash_receipts.receipt_method_id%TYPE,
            p_remittance_bank_account_id IN
                 ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.validate_args_insert_row()+' );
    END IF;
    --
    IF ( p_row_id IS NOT NULL OR p_cr_id IS NOT NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF ( p_receipt_date IS NULL OR p_gl_date IS NULL OR
         p_receipt_number IS NULL OR p_receipt_amount IS NULL OR
         p_batch_id IS NULL OR p_currency_code IS NULL OR
         p_remittance_bank_account_id IS NULL OR
         p_receipt_method_id IS NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    validate_special_type( p_special_type, p_pay_from_customer,
                           p_site_use_id, p_customer_trx_id,
			   p_payment_schedule_id );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.validate_args_insert_row()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
		     'EXCEPTION: arp_rw_icr_pkg.validate_args_insert_row' );
              END IF;
              RAISE;
END validate_args_insert_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_special_type                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate special type and related fields                               |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_special_type - Type of the receipt                      |
 |                 pay_from_custmer - Customer Id                            |
 |                 Site_use_id - Billing lication Id                         |
 |                 Customer_trx_id - Transaction Id                          |
 |                 Payment_schedule_id - PS ID                               |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 08/08/95		     |
 |                        Modified by Shintaro Okuda - 07/23/97              |
 |                          Bug fix for 510395:                              |
 |                          Evaluation of site_required_flag is added        |
 |                          in p_site_use_id validation.                     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_special_type(
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_pay_from_customer IN
                 ar_interim_cash_receipts.pay_from_customer%TYPE,
            p_site_use_id IN
                 ar_interim_cash_receipts.site_use_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                          ar_payment_schedules.payment_schedule_id%TYPE ) IS
BEGIN
    --
    -- If no special type entered, then transaction details should exist
    --
    IF ( p_special_type IS NULL ) THEN
        IF (  p_customer_trx_id IS NULL OR p_pay_from_customer IS NULL OR
           p_site_use_id IS NULL OR p_payment_schedule_id IS NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    ELSIF ( p_special_type = 'UNIDENTIFIED' ) THEN
        IF ( p_pay_from_customer IS NOT NULL OR p_site_use_id IS NOT NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    ELSE
        IF ( p_pay_from_customer IS NULL OR
             (arp_global.sysparam.site_required_flag = 'Y' AND
              p_site_use_id IS NULL )) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    END IF;
END validate_special_type;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_applied_amount_total - Get the total of applied amounts from       |
 |                               ICR_LINES                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Get the total of applied amounts if the special type of the Quick     |
 |     Receipt is 'MULTIPLE'                                                 |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_cr_id - Interim Cash reveipt ID                         |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                 p_applied_amount_total - Output applied amount total      |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  07/12/95 - Created by Ganesh Vaidee	     	     |
 | 10/14/1998	K.Murphy	Cross Currency Lockbox.                      |
 |                              Modified selection of the total applied      |
 |				amount.  This needs to consider the amount   |
 |				applied from which will hold the amount in   |
 |				receipt currency for cross currency apps.    |
 +===========================================================================*/
PROCEDURE get_applied_amount_total(
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_applied_amount_total OUT NOCOPY ar_interim_cash_receipts.amount%TYPE,
            p_applied_count_total OUT NOCOPY NUMBER,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.get_applied_amount_total()+' );
       arp_util.debug('get_applied_amount_total: ' ||  'Icr Id            : '||p_cr_id );
    END IF;
    --
    -- Validate args.
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         val_args_applied_amount_total( p_cr_id );
    END IF;
    --
    SELECT sum(nvl(amount_applied_from, nvl(payment_amount,0))), count(*)
    INTO   p_applied_amount_total,
           p_applied_count_total
    FROM   ar_interim_cash_receipt_lines
    WHERE  cash_receipt_id = p_cr_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.get_applied_amount_total()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('get_applied_amount_total: ' ||
                 'EXCEPTION: arp_rw_icr_pkg.get_applied_amount_total' );
             END IF;
             RAISE;
END get_applied_amount_total;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_args_applied_amount_total                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to get_applied_amount_total procedure        |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_cr_id - ICR_ID                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 08/08/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE val_args_applied_amount_total(
               p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.val_args_applied_amount_total()+' );
    END IF;
    --
    IF ( p_cr_id is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.val_args_applied_amount_total()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('val_args_applied_amount_total: ' ||
		   'EXCEPTION: arp_rw_icr_pkg.val_args_applied_amount_total' );
              END IF;
              RAISE;
END val_args_applied_amount_total;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |       check_unique_receipt - Check that the entered receipt is unique     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |       Check that the entered receipt is unique     			     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_cr_id - Cash receipt Id                                 |
 |                 p_receipt_number - Receipt Number                         |
 |                 p_customer_id - Customer ID                               |
 |                 p_receipt_amount - Receipt Amount                         |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee	     	     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE check_unique_receipt(
	    p_row_id IN VARCHAR2,
	    p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
	    p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
	    p_factor_discount_amount
		IN ar_interim_cash_receipts.factor_discount_amount%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
l_count     NUMBER := 0;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.check_unique_receipt()+' );
       arp_util.debug(  'Row Id            : '||p_row_id );
       arp_util.debug(  'Icr Id            : '||p_cr_id );
       arp_util.debug(  'Receipt Number    : '||p_receipt_number );
       arp_util.debug(  'Customer ID       : '||p_customer_id );
       arp_util.debug(  'Receipt Amount    : '||p_receipt_amount );
    END IF;
    --
    -- Validate args. Note: Cash Receipt Id can be null
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         val_args_check_unique_receipt( p_special_type,
                                        p_receipt_number, p_customer_id,
                                        p_receipt_amount );
    END IF;
    --
    -- Check ICR table to see if the receipt exists
    --
    SELECT COUNT(*)
    INTO   l_count
    FROM   ar_interim_cash_receipts icr
    WHERE     (     p_row_id IS NULL
              OR  icr.rowid <> p_row_id )
    AND    ( p_cr_id IS NULL
             OR  icr.cash_receipt_id <> p_cr_id  )
    AND    icr.receipt_number = p_receipt_number
    AND    icr.pay_from_customer = p_customer_id
    AND    icr.amount = p_receipt_amount
    AND    icr.factor_discount_amount = p_factor_discount_amount;
    --
    IF ( l_count <> 0 ) THEN
        FND_MESSAGE.set_name( 'AR', 'AR_DUP_PYMNT' );
        APP_EXCEPTION.raise_exception;
    END IF;
    l_count := 0;
    --
    -- Check Cash Receipts table to see if the receipt exists
    --
    SELECT COUNT(*)
    INTO   l_count
    FROM   ar_cash_receipts cr
    WHERE  (    p_cr_id IS NULL
             OR cr.cash_receipt_id <> p_cr_id  )
    AND    cr.receipt_number = p_receipt_number
    AND    cr.pay_from_customer = p_customer_id
    AND    cr.amount = p_receipt_amount+p_factor_discount_amount
    AND    cr.reversal_category IS NULL;
    IF ( l_count <> 0 ) THEN
        FND_MESSAGE.set_name( 'AR', 'AR_DUP_PYMNT' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.check_unique_receipt()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
		   'EXCEPTION: arp_rw_icr_pkg.check_unique_receipt' );
              END IF;
        RAISE;
END  check_unique_receipt;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_args_check_unique_receipt                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to check_unique_receipt procedure            |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_receipt_number - Receipt Number                         |
 |                 p_customer_id - Customer ID                               |
 |                 p_receipt_amount - Receipt Amount                         |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 08/08/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE val_args_check_unique_receipt(
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
	    p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.val_args_check_unique_receipt()+' );
    END IF;
    --
    --
    -- Note: Special type can be NULL
    --
    IF ( p_receipt_number is NULL OR p_receipt_amount IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF( ( p_special_type <> 'UNIDENTIFIED' ) AND
        ( p_customer_id IS NULL ) ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.val_args_check_unique_receipt()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('val_args_check_unique_receipt: ' ||
                   'EXCEPTION: arp_rw_icr_pkg.val_args_check_unique_receipt' );
              END IF;
              RAISE;
END val_args_check_unique_receipt;
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |       lines_exists -    - Check if lines exist for the given Cash Receipt |
 |                           ID.                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |       Check if rows exists in ICR table for the given cash receipt id
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_cr_id - Cash receipt Id                                 |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |                                                                           |
 | RETURNS    : BOOLEAN - True If lines exists, else false
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  08/09/95 - Created by Ganesh Vaidee	     	     |
 |                                                                           |
 +===========================================================================*/
FUNCTION lines_exists(
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) RETURN BOOLEAN IS
l_count   NUMBER;
BEGIN
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.lines_exists()+' );
    END IF;
    --
    -- Do argument validation, Note: No separate procedure used
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
        IF ( p_cr_id is NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    END IF;
    --
    SELECT count(*)
    INTO   l_count
    FROM   ar_interim_cash_receipt_lines icr
    WHERE  icr.cash_receipt_id = p_cr_id;
    --
    IF ( l_count = 0 ) THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.lines_exists()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('lines_exists: ' ||
                          'EXCEPTION: arp_rw_icr_pkg.lines_exists' );
              END IF;
              RAISE;
END lines_exists;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_no_lines_exists- Check if lines exist for the given Cash Receipt |
 |                           ID.                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |       Check if rows exists in ICR table for the given cash receipt id
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_cr_id - Cash receipt Id                                 |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |                                                                           |
 | RETURNS    : NONE
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  08/09/95 - Created by Ganesh Vaidee	     	     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE check_no_lines_exists (
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.check_no_lines_exists()-' );
    END IF;
    --
    -- Do argument validation, Note: No separate procedure used
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
        IF ( p_cr_id is NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    END IF;
    --
    IF ( arp_rw_icr_pkg.lines_exists( p_cr_id, NULL, NULL ) = TRUE ) THEN
        FND_MESSAGE.set_name( 'AR', 'AR_UPDNA_APP_TYPE' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.check_no_lines_exists()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('check_no_lines_exists: ' ||
                          'EXCEPTION: arp_rw_icr_pkg.check_no_lines_exists' );
              END IF;
              RAISE;
END check_no_lines_exists;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |       update_bank_account_uses - Update ap_bank_account_uses table        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |        Update ap_bank_account_uses table with passed in customer_id       |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_customer_id - customer id                               |
 |                 p_bank_account_id - bank_account Id                       |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This procedure will be called by update_row procedure             |
 |                                                                           |
 | MODIFICATION HISTORY -  08/09/95 - Created by Ganesh Vaidee	     	     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_bank_account_uses(
            p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
            p_bank_account_id IN ar_batches.remit_bank_acct_use_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.update_bank_account_uses()+' );
       arp_util.debug('update_bank_account_uses: ' ||  'Customer ID       : '||p_customer_id );
       arp_util.debug('update_bank_account_uses: ' ||  'Bank Account Id   : '||p_bank_account_id );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.update_bank_account_uses()-' );
    END IF;
    --
END update_bank_account_uses;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_row   -  Deletes a row from the QRC_ICR table		     |
 |  									     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row from AR_INTERIM_CASH_RECEIPTS.	     |
 |   									     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_cr_id - Cash Receipt ID                                 |
 |                 p_row_id - Row Id                                         |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee               |
 | 10-21-96	OSTEINME	updated comments			     |
 +===========================================================================*/
PROCEDURE delete_row(
            p_row_id   IN VARCHAR2,
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.delete_row()+' );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
        IF ( p_cr_id is NULL OR p_row_id IS NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    END IF;
    --
    -- Call delete table handler, first delete all lines
    --
    arp_cr_icr_lines_pkg.delete_fk( p_cr_id );
    arp_cr_icr_pkg.delete_p( p_cr_id );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_pkg.delete_row()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('delete_row: ' ||
                   'EXCEPTION: arp_rw_icr_pkg.delete_row' );
              END IF;
        RAISE;
END delete_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_row     -  Lock a row in the AR_ICR     table                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES - This procedure calls the check_unique_receipt procedure           |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee               |
 |                                                                           |
 | 10-21-96	OSTEINME	Added new parameters p_factor_discount_amount|
 |				and p_customer_bank_account_id for Japan     |
 |				project.				     |
 |				Also added new parameter		     |
 |				p_anticipated_clearing_date for bug 371373   |
 | 10-28-96	OSTEINME	added new parameter customer_bank_branch_id  |
 +===========================================================================*/
PROCEDURE lock_row(
            p_row_id   VARCHAR2,
            p_cr_id   ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number ar_interim_cash_receipts.receipt_number%TYPE,
	    p_currency_code ar_interim_cash_receipts.currency_code%TYPE,
            p_receipt_amount ar_interim_cash_receipts.amount%TYPE,
	    p_factor_discount_amount IN
		ar_interim_cash_receipts.factor_discount_amount%TYPE,
            p_receipt_method_id
                   ar_interim_cash_receipts.receipt_method_id%TYPE,
            p_remittance_bank_account_id
                   ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE,
            p_batch_id ar_interim_cash_receipts.batch_id%TYPE,
            p_customer_trx_id ar_interim_cash_receipts.customer_trx_id%TYPE,
	    p_payment_schedule_id
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_exchange_date ar_interim_cash_receipts.exchange_date%TYPE,
            p_exchange_rate ar_interim_cash_receipts.exchange_rate%TYPE,
            p_exchange_rate_type
                   ar_interim_cash_receipts.exchange_rate_type%TYPE,
            p_gl_date IN
		   ar_interim_cash_receipts.gl_date%TYPE,
	    p_anticipated_clearing_date IN
		   ar_interim_cash_receipts.anticipated_clearing_date%TYPE,
            p_pay_from_customer
                   ar_interim_cash_receipts.pay_from_customer%TYPE,
	    p_customer_bank_account_id IN
		   ar_interim_cash_receipts.customer_bank_account_id%TYPE,
	    p_customer_bank_branch_id IN
		   ar_interim_cash_receipts.customer_bank_branch_id%TYPE,
            p_receipt_date ar_interim_cash_receipts.receipt_date%TYPE,
            p_site_use_id ar_interim_cash_receipts.site_use_id%TYPE,
            p_ussgl_transaction_code
                   ar_interim_cash_receipts.ussgl_transaction_code%TYPE,
            p_doc_sequence_id ar_interim_cash_receipts.doc_sequence_id%TYPE,
            p_doc_sequence_value
                           ar_interim_cash_receipts.doc_sequence_value%TYPE,
            p_attribute_category
                           ar_interim_cash_receipts.attribute_category%TYPE,
            p_attribute1 ar_interim_cash_receipts.attribute1%TYPE,
            p_attribute2 ar_interim_cash_receipts.attribute2%TYPE,
            p_attribute3 ar_interim_cash_receipts.attribute3%TYPE,
            p_attribute4 ar_interim_cash_receipts.attribute4%TYPE,
            p_attribute5 ar_interim_cash_receipts.attribute5%TYPE,
            p_attribute6 ar_interim_cash_receipts.attribute6%TYPE,
            p_attribute7 ar_interim_cash_receipts.attribute7%TYPE,
            p_attribute8 ar_interim_cash_receipts.attribute8%TYPE,
            p_attribute9 ar_interim_cash_receipts.attribute9%TYPE,
            p_attribute10 ar_interim_cash_receipts.attribute10%TYPE,
            p_attribute11 ar_interim_cash_receipts.attribute11%TYPE,
            p_attribute12 ar_interim_cash_receipts.attribute12%TYPE,
            p_attribute13 ar_interim_cash_receipts.attribute13%TYPE,
            p_attribute14 ar_interim_cash_receipts.attribute14%TYPE,
            p_attribute15 ar_interim_cash_receipts.attribute15%TYPE
          ) IS
    CURSOR C IS
	SELECT *
	FROM ar_interim_cash_receipts
	WHERE rowid = p_row_id
	FOR UPDATE of CASH_RECEIPT_ID NOWAIT;
    Recinfo C%ROWTYPE;
--
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('lock_row: ' ||  'Made it to lock row' );
    END IF;

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
	CLOSE C;
	FND_MESSAGE.Set_Name( 'FND', 'FORM_RECORD_DELETED');
	APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if(
		(Recinfo.cash_receipt_id = p_cr_id )
	    AND	(   (NVL(Recinfo.special_type, 'SINGLE') = p_special_type)
		OR  ( 	(Recinfo.special_type IS NULL)
		    AND	(p_special_type IS NULL)))
	    AND	(   (Recinfo.receipt_number = p_receipt_number)
		OR  ( 	(Recinfo.receipt_number IS NULL)
		    AND	(p_receipt_number IS NULL)))
	    AND	(Recinfo.currency_code = p_currency_code)
	    AND	(Recinfo.amount = p_receipt_amount)
	    AND	(Recinfo.receipt_method_id = p_receipt_method_id)
	    AND	(Recinfo.remit_bank_acct_use_id = p_remittance_bank_account_id)
	    AND	(   (Recinfo.batch_id = p_batch_id)
		OR  ( 	(Recinfo.batch_id IS NULL)
		    AND	(p_batch_id IS NULL)))
	    AND	(   (Recinfo.customer_trx_id = p_customer_trx_id)
		OR  ( 	(Recinfo.customer_trx_id IS NULL)
		    AND	(p_customer_trx_id IS NULL)))
	    AND	(   (Recinfo.payment_schedule_id = p_payment_schedule_id)
		OR  ( 	(Recinfo.payment_schedule_id IS NULL)
		    AND	(p_payment_schedule_id IS NULL)))
	    AND	(   (Recinfo.exchange_date = p_exchange_date)
		OR  ( 	(Recinfo.exchange_date IS NULL)
		    AND	(p_exchange_date IS NULL)))
	    AND	(   (Recinfo.exchange_rate = p_exchange_rate)
		OR  ( 	(Recinfo.exchange_rate IS NULL)
		    AND	(p_exchange_rate IS NULL)))
	    AND	(   (Recinfo.exchange_rate_type = p_exchange_rate_type)
		OR  ( 	(Recinfo.exchange_rate_type IS NULL)
		    AND	(p_exchange_rate_type IS NULL)))
	    AND	(Recinfo.gl_date = p_gl_date)
	    AND	(   (Recinfo.pay_from_customer = p_pay_from_customer)
		OR  ( 	(Recinfo.pay_from_customer IS NULL)
		    AND	(p_pay_from_customer IS NULL)))
	    AND	(   (Recinfo.receipt_date = p_receipt_date)
		OR  ( 	(Recinfo.receipt_date IS NULL)
		    AND	(p_receipt_date IS NULL)))
	    AND	(   (Recinfo.site_use_id = p_site_use_id)
		OR  ( 	(Recinfo.site_use_id IS NULL)
		    AND	(p_site_use_id IS NULL)))
	    AND	(   (Recinfo.ussgl_transaction_code = p_ussgl_transaction_code)
		OR  ( 	(Recinfo.ussgl_transaction_code IS NULL)
		    AND	(p_ussgl_transaction_code IS NULL)))
	    AND	(   (Recinfo.doc_sequence_id = p_doc_sequence_id)
		OR  ( 	(Recinfo.doc_sequence_id IS NULL)
		    AND	(p_doc_sequence_id IS NULL)))
	    AND	(   (Recinfo.doc_sequence_value = p_doc_sequence_value)
		OR  ( 	(Recinfo.doc_sequence_value IS NULL)
		    AND	(p_doc_sequence_value IS NULL)))
	    AND	(   (Recinfo.attribute_category = p_attribute_category)
		OR  ( 	(Recinfo.attribute_category IS NULL)
		    AND	(p_attribute_category IS NULL)))
	    AND	(   (Recinfo.attribute1 = p_attribute1)
		OR  ( 	(Recinfo.attribute1 IS NULL)
		    AND	(p_attribute1 IS NULL)))
	    AND	(   (Recinfo.attribute2 = p_attribute2)
		OR  ( 	(Recinfo.attribute2 IS NULL)
		    AND	(p_attribute2 IS NULL)))
	    AND	(   (Recinfo.attribute3 = p_attribute3)
		OR  ( 	(Recinfo.attribute3 IS NULL)
		    AND	(p_attribute3 IS NULL)))
	    AND	(   (Recinfo.attribute4 = p_attribute4)
		OR  ( 	(Recinfo.attribute4 IS NULL)
		    AND	(p_attribute4 IS NULL)))
	    AND	(   (Recinfo.attribute5 = p_attribute5)
		OR  ( 	(Recinfo.attribute5 IS NULL)
		    AND	(p_attribute5 IS NULL)))
	    AND	(   (Recinfo.attribute6 = p_attribute6)
		OR  ( 	(Recinfo.attribute6 IS NULL)
		    AND	(p_attribute6 IS NULL)))
	    AND	(   (Recinfo.attribute7 = p_attribute7)
		OR  ( 	(Recinfo.attribute7 IS NULL)
		    AND	(p_attribute7 IS NULL)))
	    AND	(   (Recinfo.attribute8 = p_attribute8)
		OR  ( 	(Recinfo.attribute8 IS NULL)
		    AND	(p_attribute8 IS NULL)))
	    AND	(   (Recinfo.attribute9 = p_attribute9)
		OR  ( 	(Recinfo.attribute9 IS NULL)
		    AND	(p_attribute9 IS NULL)))
	    AND	(   (Recinfo.attribute10 = p_attribute10)
		OR  ( 	(Recinfo.attribute10 IS NULL)
		    AND	(p_attribute10 IS NULL)))
	    AND	(   (Recinfo.attribute11 = p_attribute11)
		OR  ( 	(Recinfo.attribute11 IS NULL)
		    AND	(p_attribute11 IS NULL)))
	    AND	(   (Recinfo.attribute12 = p_attribute12)
		OR  ( 	(Recinfo.attribute12 IS NULL)
		    AND	(p_attribute12 IS NULL)))
	    AND	(   (Recinfo.attribute13 = p_attribute13)
		OR  ( 	(Recinfo.attribute13 IS NULL)
		    AND	(p_attribute13 IS NULL)))
	    AND	(   (Recinfo.attribute14 = p_attribute14)
		OR  ( 	(Recinfo.attribute14 IS NULL)
		    AND	(p_attribute14 IS NULL)))
	    AND	(   (Recinfo.attribute15 = p_attribute15)
		OR  ( 	(Recinfo.attribute15 IS NULL)
		    AND	(p_attribute15 IS NULL)))
	    AND	(   (Recinfo.factor_discount_amount
					= p_factor_discount_amount)
		OR  ( 	(Recinfo.factor_discount_amount IS NULL)
		    AND	(p_factor_discount_amount IS NULL)))
	    AND	(   (Recinfo.customer_bank_account_id =
					p_customer_bank_account_id)
		OR  ( 	(Recinfo.customer_bank_account_id IS NULL)
		    AND	(p_customer_bank_account_id IS NULL)))
	    AND	(   (Recinfo.customer_bank_branch_id =
					p_customer_bank_branch_id)
		OR  ( 	(Recinfo.customer_bank_branch_id IS NULL)
		    AND	(p_customer_bank_branch_id IS NULL)))
	    AND	(   (Recinfo.anticipated_clearing_date =
					p_anticipated_clearing_date)
		OR  ( 	(Recinfo.anticipated_clearing_date IS NULL)
		    AND	(p_anticipated_clearing_date IS NULL)))
    ) then
        return;
    else
	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
 	APP_EXCEPTION.Raise_Exception;
    end if;
END lock_row;
--
END ARP_RW_ICR_PKG;

/
