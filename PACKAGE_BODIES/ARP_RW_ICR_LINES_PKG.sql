--------------------------------------------------------
--  DDL for Package Body ARP_RW_ICR_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RW_ICR_LINES_PKG" AS
/* $Header: ARERICLB.pls 115.9 2003/10/13 14:17:30 mraymond ship $ */
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE validate_args_insert_row(
            p_row_id IN VARCHAR2,
            p_icr_line_id IN
                        ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_cash_receipt_id IN
                        ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id IN
                   ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id IN ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer IN
                   ar_interim_cash_receipt_lines.sold_to_customer%TYPE );
--
PROCEDURE validate_args_update_row(
            p_row_id IN VARCHAR2,
            p_icr_line_id IN
                        ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id IN
                   ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id IN ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer IN
                   ar_interim_cash_receipt_lines.sold_to_customer%TYPE );
--
PROCEDURE validate_args_delete_row(
            p_row_id IN VARCHAR2,
            p_icr_line_id IN
                 ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE );
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_row   -  Update a row in the AR_ICR     table after checking for|
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row in AR_ICR     table after checking for     |
 |    uniqueness for items such of the receipt                               |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id - Row ID                                         |
 |                 p_cr_line_id  - Cash receipt line Id                      |
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
 | 08-12-97     KTANG        add global attributes in parameter list         |
 |                           for global descriptive flexfield                |
 | 10/12/98     DJANCIS   Added batch_id to call to update_p as it will be   |
 |                        needed to uniquely identify a row in interim       |
 |                        cash receipts lines.                               |
 | 10-06-98     K.Murphy  Cross Currency Lockbox.  Added amount_applied_from |
 |                        and trans_to_receipt_rate as parameters and updated|
 |                        columns.                                           |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason to update and insert       |
 |                                procedures.                                |
 | 01-20-03   K.Dhaliwal          Bug 2707190 Added Applied_Rec_App_ID       |
 +===========================================================================*/
PROCEDURE update_row(
            p_row_id   IN VARCHAR2,
            p_icr_line_id   IN
                    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_cr_id   IN
                    ar_interim_cash_receipt_lines.cash_receipt_id%TYPE,
            p_payment_amount IN
                       ar_interim_cash_receipt_lines.payment_amount%TYPE,
            p_amount_applied_from IN
                       ar_interim_cash_receipt_lines.amount_applied_from%TYPE,
            p_trans_to_receipt_rate IN
                       ar_interim_cash_receipt_lines.trans_to_receipt_rate%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id IN
                   ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id IN ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer IN
                   ar_interim_cash_receipt_lines.sold_to_customer%TYPE,
            p_discount_taken IN
                   ar_interim_cash_receipt_lines.discount_taken%TYPE,
            p_due_date IN ar_interim_cash_receipt_lines.due_date%TYPE,
            p_ussgl_transaction_code IN
                   ar_interim_cash_receipt_lines.ussgl_transaction_code%TYPE,
            p_attribute_category IN
                        ar_interim_cash_receipt_lines.attribute_category%TYPE,
            p_attribute1 IN ar_interim_cash_receipt_lines.attribute1%TYPE,
            p_attribute2 IN ar_interim_cash_receipt_lines.attribute2%TYPE,
            p_attribute3 IN ar_interim_cash_receipt_lines.attribute3%TYPE,
            p_attribute4 IN ar_interim_cash_receipt_lines.attribute4%TYPE,
            p_attribute5 IN ar_interim_cash_receipt_lines.attribute5%TYPE,
            p_attribute6 IN ar_interim_cash_receipt_lines.attribute6%TYPE,
            p_attribute7 IN ar_interim_cash_receipt_lines.attribute7%TYPE,
            p_attribute8 IN ar_interim_cash_receipt_lines.attribute8%TYPE,
            p_attribute9 IN ar_interim_cash_receipt_lines.attribute9%TYPE,
            p_attribute10 IN ar_interim_cash_receipt_lines.attribute10%TYPE,
            p_attribute11 IN ar_interim_cash_receipt_lines.attribute11%TYPE,
            p_attribute12 IN ar_interim_cash_receipt_lines.attribute12%TYPE,
            p_attribute13 IN ar_interim_cash_receipt_lines.attribute13%TYPE,
            p_attribute14 IN ar_interim_cash_receipt_lines.attribute14%TYPE,
            p_attribute15 IN ar_interim_cash_receipt_lines.attribute15%TYPE,
            p_global_attribute_category IN
                ar_interim_cash_receipt_lines.global_attribute_category%TYPE,
            p_global_attribute1 IN
                ar_interim_cash_receipt_lines.global_attribute1%TYPE,
            p_global_attribute2 IN
                ar_interim_cash_receipt_lines.global_attribute2%TYPE,
            p_global_attribute3 IN
                ar_interim_cash_receipt_lines.global_attribute3%TYPE,
            p_global_attribute4 IN
                ar_interim_cash_receipt_lines.global_attribute4%TYPE,
            p_global_attribute5 IN
                ar_interim_cash_receipt_lines.global_attribute5%TYPE,
            p_global_attribute6 IN
                ar_interim_cash_receipt_lines.global_attribute6%TYPE,
            p_global_attribute7 IN
                ar_interim_cash_receipt_lines.global_attribute7%TYPE,
            p_global_attribute8 IN
                ar_interim_cash_receipt_lines.global_attribute8%TYPE,
            p_global_attribute9 IN
                ar_interim_cash_receipt_lines.global_attribute9%TYPE,
            p_global_attribute10 IN
                ar_interim_cash_receipt_lines.global_attribute10%TYPE,
            p_global_attribute11 IN
                ar_interim_cash_receipt_lines.global_attribute11%TYPE,
            p_global_attribute12 IN
                ar_interim_cash_receipt_lines.global_attribute12%TYPE,
            p_global_attribute13 IN
                ar_interim_cash_receipt_lines.global_attribute13%TYPE,
            p_global_attribute14 IN
                ar_interim_cash_receipt_lines.global_attribute14%TYPE,
            p_global_attribute15 IN
                ar_interim_cash_receipt_lines.global_attribute15%TYPE,
            p_global_attribute16 IN
                ar_interim_cash_receipt_lines.global_attribute16%TYPE,
            p_global_attribute17 IN
                ar_interim_cash_receipt_lines.global_attribute17%TYPE,
            p_global_attribute18 IN
                ar_interim_cash_receipt_lines.global_attribute18%TYPE,
            p_global_attribute19 IN
                ar_interim_cash_receipt_lines.global_attribute19%TYPE,
            p_global_attribute20 IN
                ar_interim_cash_receipt_lines.global_attribute20%TYPE,
            p_application_ref_type IN
                ar_interim_cash_receipt_lines.application_ref_type%TYPE,
            p_customer_reference IN
                ar_interim_cash_receipt_lines.customer_reference%TYPE,
            p_customer_reason IN
                ar_interim_cash_receipt_lines.customer_reason%TYPE,
            p_applied_rec_app_id IN
                ar_interim_cash_receipt_lines.applied_rec_app_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
--
l_icr_lines_rec   ar_interim_cash_receipt_lines%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_rw_icr_line_pkg.update_row()+' );
       arp_util.debug('Row Id            : '||p_row_id );
       arp_util.debug('Line Id           : '||p_icr_line_id );
       arp_util.debug('Payment Sch. ID   : '||p_payment_schedule_id );
       arp_util.debug('Customer Trx. Id  : '||p_customer_trx_id );
       arp_util.debug('Batch Id          : '||p_batch_id );
       arp_util.debug('Sold To Customer  : '||p_sold_to_customer );
       arp_util.debug('Batch Id          : '||p_batch_id );
       arp_util.debug('Payment Amount    : '||p_payment_amount );
       arp_util.debug('Amount Applied From: '||p_amount_applied_from );
       arp_util.debug('Trans to Receipt Rate: '||p_trans_to_receipt_rate );
       arp_util.debug('Discount Taken    : '||p_discount_taken );
       arp_util.debug('Due Date          : '||TO_CHAR( p_due_date ) );
    END IF;
    --
    arp_cr_icr_lines_pkg.set_to_dummy( l_icr_lines_rec );
    --
    -- Populate ICR record structure
    --
    l_icr_lines_rec.cash_receipt_line_id := p_icr_line_id;
    l_icr_lines_rec.cash_receipt_id := p_cr_id;
    l_icr_lines_rec.payment_amount := p_payment_amount;
    l_icr_lines_rec.amount_applied_from := p_amount_applied_from;
    l_icr_lines_rec.trans_to_receipt_rate := p_trans_to_receipt_rate;
    l_icr_lines_rec.payment_schedule_id := p_payment_schedule_id;
    l_icr_lines_rec.customer_trx_id := p_customer_trx_id;
    l_icr_lines_rec.batch_id := p_batch_id;
    l_icr_lines_rec.sold_to_customer := p_sold_to_customer;
    l_icr_lines_rec.discount_taken := p_discount_taken;
    l_icr_lines_rec.due_date := p_due_date;
    l_icr_lines_rec.attribute_category := p_attribute_category;
    l_icr_lines_rec.attribute1 := p_attribute1;
    l_icr_lines_rec.attribute2 := p_attribute2;
    l_icr_lines_rec.attribute3 := p_attribute3;
    l_icr_lines_rec.attribute4 := p_attribute4;
    l_icr_lines_rec.attribute5 := p_attribute5;
    l_icr_lines_rec.attribute6 := p_attribute6;
    l_icr_lines_rec.attribute7 := p_attribute7;
    l_icr_lines_rec.attribute8 := p_attribute8;
    l_icr_lines_rec.attribute9 := p_attribute9;
    l_icr_lines_rec.attribute10 := p_attribute10;
    l_icr_lines_rec.attribute11 := p_attribute11;
    l_icr_lines_rec.attribute12 := p_attribute12;
    l_icr_lines_rec.attribute13 := p_attribute13;
    l_icr_lines_rec.attribute14 := p_attribute14;
    l_icr_lines_rec.attribute15 := p_attribute15;
    l_icr_lines_rec.global_attribute_category := p_global_attribute_category;
    l_icr_lines_rec.global_attribute1 := p_global_attribute1;
    l_icr_lines_rec.global_attribute2 := p_global_attribute2;
    l_icr_lines_rec.global_attribute3 := p_global_attribute3;
    l_icr_lines_rec.global_attribute4 := p_global_attribute4;
    l_icr_lines_rec.global_attribute5 := p_global_attribute5;
    l_icr_lines_rec.global_attribute6 := p_global_attribute6;
    l_icr_lines_rec.global_attribute7 := p_global_attribute7;
    l_icr_lines_rec.global_attribute8 := p_global_attribute8;
    l_icr_lines_rec.global_attribute9 := p_global_attribute9;
    l_icr_lines_rec.global_attribute10 := p_global_attribute10;
    l_icr_lines_rec.global_attribute11 := p_global_attribute11;
    l_icr_lines_rec.global_attribute12 := p_global_attribute12;
    l_icr_lines_rec.global_attribute13 := p_global_attribute13;
    l_icr_lines_rec.global_attribute14 := p_global_attribute14;
    l_icr_lines_rec.global_attribute15 := p_global_attribute15;
    l_icr_lines_rec.global_attribute16 := p_global_attribute16;
    l_icr_lines_rec.global_attribute17 := p_global_attribute17;
    l_icr_lines_rec.global_attribute18 := p_global_attribute18;
    l_icr_lines_rec.global_attribute19 := p_global_attribute19;
    l_icr_lines_rec.global_attribute20 := p_global_attribute20;
    l_icr_lines_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_icr_lines_rec.application_ref_type := p_application_ref_type;
    l_icr_lines_rec.customer_reference := p_customer_reference;
    l_icr_lines_rec.customer_reason := p_customer_reason;
    l_icr_lines_rec.applied_rec_app_id := p_applied_rec_app_id;

    --
    -- Validate arguments
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         arp_rw_icr_lines_pkg.validate_args_update_row( p_row_id,
                                   l_icr_lines_rec.cash_receipt_line_id,
                                   l_icr_lines_rec.payment_schedule_id,
                                   l_icr_lines_rec.customer_trx_id,
                                   l_icr_lines_rec.batch_id,
                                   l_icr_lines_rec.sold_to_customer );
    END IF;
    --
    -- Bug 744228: added batch_id to update_p call.
    --     746872  added cash_receipt_id.
    arp_cr_icr_lines_pkg.update_p( l_icr_lines_rec,
                             l_icr_lines_rec.cash_receipt_line_id,
                             l_icr_lines_rec.batch_id,
                             l_icr_lines_rec.cash_receipt_id  );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_rw_icr_line_pkg.update_row()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('EXCEPTION: arp_rw_icr_line_pkg.update_row' );
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
 |                   p_row_id,						     |
 |                   p_icr_line_id            		                     |
 |                   p_payment_schedule_id,                                  |
 |                   p_customer_trx_id,                                      |
 |                   p_batch_id,                                             |
 |                   p_sold_to_customer                                      |
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
            p_row_id IN VARCHAR2,
            p_icr_line_id IN
                        ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id IN
                   ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id IN ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer IN
                   ar_interim_cash_receipt_lines.sold_to_customer%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_rw_icr_line_pkg.validate_args_update_row()+' );
    END IF;
    --
    IF ( p_row_id IS NULL OR p_icr_line_id IS NULL OR
         p_payment_schedule_id IS NULL OR
         p_customer_trx_id IS NULL OR
         p_batch_id IS NULL OR p_sold_to_customer IS NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_rw_icr_line_pkg.validate_args_update_row()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
		 arp_util.debug('EXCEPTION: arp_rw_icr_line_pkg.validate_args_update_row' );
              END IF;
              RAISE;
END validate_args_update_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_row   -  Inserts a row into the ICR_LINES table after checking  |
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function Inserts a row into the ICR_LINES table after checking for|
 |    uniqueness for items such of the receipt number                        |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                 p_row_id - Row ID                                         |
 |                 p_icr_line_id- cash receipt line ID                       |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee	     	     |
 | 08-12-97     KTANG        add global attributes in parameter list         |
 |                           for global descriptive flexfield                |
 | 10-06-98     K.Murphy  Cross Currency Lockbox.  Added amount_applied_from |
 |                        and trans_to_receipt_rate as parameters and created|
 |                        columns.                                           |
 | 12-24-02   K.Dhaliwal          Bug 2707190 Added                          |
 |                                application_ref_type,customer_reference and|
 |                                customer_reason to update and insert       |
 |                                procedures.                                |
 | 01-20-03   K.Dhaliwal          Bug 2707190 Added Applied_Rec_App_ID       |
 +===========================================================================*/
PROCEDURE insert_row(
            p_row_id   IN OUT NOCOPY VARCHAR2,
            p_icr_line_id   IN OUT NOCOPY
                      ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_cr_id    IN ar_interim_cash_receipt_lines.cash_receipt_id%TYPE,
            p_payment_amount IN
                       ar_interim_cash_receipt_lines.payment_amount%TYPE,
            p_amount_applied_from IN
                       ar_interim_cash_receipt_lines.amount_applied_from%TYPE,
            p_trans_to_receipt_rate IN
                       ar_interim_cash_receipt_lines.trans_to_receipt_rate%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id IN
                   ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id IN ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer IN
                   ar_interim_cash_receipt_lines.sold_to_customer%TYPE,
            p_discount_taken IN
                   ar_interim_cash_receipt_lines.discount_taken%TYPE,
            p_due_date IN ar_interim_cash_receipt_lines.due_date%TYPE,
            p_ussgl_transaction_code IN
                   ar_interim_cash_receipt_lines.ussgl_transaction_code%TYPE,
            p_attribute_category IN
                      ar_interim_cash_receipt_lines.attribute_category%TYPE,
            p_attribute1 IN ar_interim_cash_receipt_lines.attribute1%TYPE,
            p_attribute2 IN ar_interim_cash_receipt_lines.attribute2%TYPE,
            p_attribute3 IN ar_interim_cash_receipt_lines.attribute3%TYPE,
            p_attribute4 IN ar_interim_cash_receipt_lines.attribute4%TYPE,
            p_attribute5 IN ar_interim_cash_receipt_lines.attribute5%TYPE,
            p_attribute6 IN ar_interim_cash_receipt_lines.attribute6%TYPE,
            p_attribute7 IN ar_interim_cash_receipt_lines.attribute7%TYPE,
            p_attribute8 IN ar_interim_cash_receipt_lines.attribute8%TYPE,
            p_attribute9 IN ar_interim_cash_receipt_lines.attribute9%TYPE,
            p_attribute10 IN ar_interim_cash_receipt_lines.attribute10%TYPE,
            p_attribute11 IN ar_interim_cash_receipt_lines.attribute11%TYPE,
            p_attribute12 IN ar_interim_cash_receipt_lines.attribute12%TYPE,
            p_attribute13 IN ar_interim_cash_receipt_lines.attribute13%TYPE,
            p_attribute14 IN ar_interim_cash_receipt_lines.attribute14%TYPE,
            p_attribute15 IN ar_interim_cash_receipt_lines.attribute15%TYPE,
            p_global_attribute_category IN
                ar_interim_cash_receipt_lines.global_attribute_category%TYPE,
            p_global_attribute1 IN
                ar_interim_cash_receipt_lines.global_attribute1%TYPE,
            p_global_attribute2 IN
                ar_interim_cash_receipt_lines.global_attribute2%TYPE,
            p_global_attribute3 IN
                ar_interim_cash_receipt_lines.global_attribute3%TYPE,
            p_global_attribute4 IN
                ar_interim_cash_receipt_lines.global_attribute4%TYPE,
            p_global_attribute5 IN
                ar_interim_cash_receipt_lines.global_attribute5%TYPE,
            p_global_attribute6 IN
                ar_interim_cash_receipt_lines.global_attribute6%TYPE,
            p_global_attribute7 IN
                ar_interim_cash_receipt_lines.global_attribute7%TYPE,
            p_global_attribute8 IN
                ar_interim_cash_receipt_lines.global_attribute8%TYPE,
            p_global_attribute9 IN
                ar_interim_cash_receipt_lines.global_attribute9%TYPE,
            p_global_attribute10 IN
                ar_interim_cash_receipt_lines.global_attribute10%TYPE,
            p_global_attribute11 IN
                ar_interim_cash_receipt_lines.global_attribute11%TYPE,
            p_global_attribute12 IN
                ar_interim_cash_receipt_lines.global_attribute12%TYPE,
            p_global_attribute13 IN
                ar_interim_cash_receipt_lines.global_attribute13%TYPE,
            p_global_attribute14 IN
                ar_interim_cash_receipt_lines.global_attribute14%TYPE,
            p_global_attribute15 IN
                ar_interim_cash_receipt_lines.global_attribute15%TYPE,
            p_global_attribute16 IN
                ar_interim_cash_receipt_lines.global_attribute16%TYPE,
            p_global_attribute17 IN
                ar_interim_cash_receipt_lines.global_attribute17%TYPE,
            p_global_attribute18 IN
                ar_interim_cash_receipt_lines.global_attribute18%TYPE,
            p_global_attribute19 IN
                ar_interim_cash_receipt_lines.global_attribute19%TYPE,
            p_global_attribute20 IN
                ar_interim_cash_receipt_lines.global_attribute20%TYPE,
            p_application_ref_type IN
                ar_interim_cash_receipt_lines.application_ref_type%TYPE,
            p_customer_reference IN
                ar_interim_cash_receipt_lines.customer_reference%TYPE,
            p_customer_reason IN
                ar_interim_cash_receipt_lines.customer_reason%TYPE,
            p_applied_rec_app_id IN
                ar_interim_cash_receipt_lines.applied_rec_app_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
--
l_row_id         VARCHAR2(30);
l_icr_line_id     ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE;
l_icr_lines_rec   ar_interim_cash_receipt_lines%ROWTYPE;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_rw_icr_line_pkg.insert_row()+' );
       arp_util.debug('Row  Id           : '||p_row_id );
       arp_util.debug('Line Id           : '||p_icr_line_id );
       arp_util.debug('Receipt Id        : '||p_cr_id );
       arp_util.debug('Payment Sch. ID   : '||p_payment_schedule_id );
       arp_util.debug('Customer Trx. Id  : '||p_customer_trx_id );
       arp_util.debug('Batch Id          : '||p_batch_id );
       arp_util.debug('Sold To Customer  : '||p_sold_to_customer );
       arp_util.debug('Batch Id          : '||p_batch_id );
       arp_util.debug('Payment Amount    : '||p_payment_amount );
       arp_util.debug('Amount Applied From: '||p_amount_applied_from );
       arp_util.debug('Trans to Receipt Rate: '||p_trans_to_receipt_rate );
       arp_util.debug('Discount Taken    : '||p_discount_taken );
       arp_util.debug('Due Date          : '||TO_CHAR( p_due_date ) );
    END IF;
    --
    l_icr_lines_rec.cash_receipt_id := p_cr_id;
    l_icr_lines_rec.payment_amount := p_payment_amount;
    l_icr_lines_rec.amount_applied_from := p_amount_applied_from;
    l_icr_lines_rec.trans_to_receipt_rate := p_trans_to_receipt_rate;
    l_icr_lines_rec.payment_schedule_id := p_payment_schedule_id;
    l_icr_lines_rec.customer_trx_id := p_customer_trx_id;
    l_icr_lines_rec.batch_id := p_batch_id;
    l_icr_lines_rec.sold_to_customer := p_sold_to_customer;
    l_icr_lines_rec.discount_taken := p_discount_taken;
    l_icr_lines_rec.due_date := p_due_date;
    l_icr_lines_rec.attribute_category := p_attribute_category;
    l_icr_lines_rec.attribute1 := p_attribute1;
    l_icr_lines_rec.attribute2 := p_attribute2;
    l_icr_lines_rec.attribute3 := p_attribute3;
    l_icr_lines_rec.attribute4 := p_attribute4;
    l_icr_lines_rec.attribute5 := p_attribute5;
    l_icr_lines_rec.attribute6 := p_attribute6;
    l_icr_lines_rec.attribute7 := p_attribute7;
    l_icr_lines_rec.attribute8 := p_attribute8;
    l_icr_lines_rec.attribute9 := p_attribute9;
    l_icr_lines_rec.attribute10 := p_attribute10;
    l_icr_lines_rec.attribute11 := p_attribute11;
    l_icr_lines_rec.attribute12 := p_attribute12;
    l_icr_lines_rec.attribute13 := p_attribute13;
    l_icr_lines_rec.attribute14 := p_attribute14;
    l_icr_lines_rec.attribute15 := p_attribute15;
    l_icr_lines_rec.global_attribute_category := p_global_attribute_category;
    l_icr_lines_rec.global_attribute1 := p_global_attribute1;
    l_icr_lines_rec.global_attribute2 := p_global_attribute2;
    l_icr_lines_rec.global_attribute3 := p_global_attribute3;
    l_icr_lines_rec.global_attribute4 := p_global_attribute4;
    l_icr_lines_rec.global_attribute5 := p_global_attribute5;
    l_icr_lines_rec.global_attribute6 := p_global_attribute6;
    l_icr_lines_rec.global_attribute7 := p_global_attribute7;
    l_icr_lines_rec.global_attribute8 := p_global_attribute8;
    l_icr_lines_rec.global_attribute9 := p_global_attribute9;
    l_icr_lines_rec.global_attribute10 := p_global_attribute10;
    l_icr_lines_rec.global_attribute11 := p_global_attribute11;
    l_icr_lines_rec.global_attribute12 := p_global_attribute12;
    l_icr_lines_rec.global_attribute13 := p_global_attribute13;
    l_icr_lines_rec.global_attribute14 := p_global_attribute14;
    l_icr_lines_rec.global_attribute15 := p_global_attribute15;
    l_icr_lines_rec.global_attribute16 := p_global_attribute16;
    l_icr_lines_rec.global_attribute17 := p_global_attribute17;
    l_icr_lines_rec.global_attribute18 := p_global_attribute18;
    l_icr_lines_rec.global_attribute19 := p_global_attribute19;
    l_icr_lines_rec.global_attribute20 := p_global_attribute20;
    l_icr_lines_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_icr_lines_rec.application_ref_type := p_application_ref_type;
    l_icr_lines_rec.customer_reference := p_customer_reference;
    l_icr_lines_rec.customer_reason := p_customer_reason;
    l_icr_lines_rec.applied_rec_app_id := p_applied_rec_app_id;
    --
    -- Validate arguments
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
        arp_rw_icr_lines_pkg.validate_args_insert_row( p_row_id,
                                  p_icr_line_id,
                                  l_icr_lines_rec.cash_receipt_id,
                                  l_icr_lines_rec.payment_schedule_id,
                                  l_icr_lines_rec.customer_trx_id,
                                  l_icr_lines_rec.batch_id,
                                  l_icr_lines_rec.sold_to_customer );
    END IF;
    --
    -- Do the actual Insertion
    --
    arp_cr_icr_lines_pkg.insert_p( l_row_id, l_icr_line_id, l_icr_lines_rec );
    --
    p_row_id := l_row_id;
    p_icr_line_id := l_icr_line_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_rw_icr_line_pkg.insert_row()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('EXCEPTION: arp_rw_icr_line_pkg.insert_row' );
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
 |                 p_row_id - Row Id                                         |
 |                 p_icr_line_id - ICR Line ID                               |
 |                 p_cash_receipt_id - ICR ID                                |
 |                 p_payment_schedule_id - Payment schedules Id              |
 |                 p_customer_trx_id - Customer Trx Id                       |
 |                 p_batch_id - Batch id of the interim cash receipt         |
 |                 p_sold_to_customer - Sold to customer ID from the invoice |
 |		   			side				     |
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
            p_row_id IN VARCHAR2,
            p_icr_line_id IN
                        ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_cash_receipt_id IN
                        ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id IN
                   ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id IN ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer IN
                   ar_interim_cash_receipt_lines.sold_to_customer%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_lines_pkg.validate_args_insert_row()+' );
    END IF;
    --
    IF ( p_row_id IS NOT NULL OR p_icr_line_id IS NOT NULL  ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF ( p_cash_receipt_id IS NULL OR p_payment_schedule_id IS NULL OR
         p_customer_trx_id IS NULL OR p_batch_id IS NULL OR
         p_sold_to_customer IS NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_line_pkg.validate_args_insert_row()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
	        arp_util.debug('EXCEPTION: arp_rw_icr_line_pkg.validate_args_insert_row' );
              END IF;
              RAISE;
END validate_args_insert_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_row   -  Deletes a row from the QRC_ICR_LINES table             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row from the QRC_ICR_LINES                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                 p_row_id - Row ID                                         |
 |                 p_icr_line_id- cash receipt line ID                       |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee               |
 +===========================================================================*/
PROCEDURE delete_row(
            p_row_id   IN VARCHAR2,
            p_icr_id   IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_icr_line_id   IN
                    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_line_pkg.delete_row()+' );
       arp_util.debug('Row  Id           : '||p_row_id );
       arp_util.debug('Line Id           : '||p_icr_line_id );
    END IF;
    --
    -- Validate arguments
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
        arp_rw_icr_lines_pkg.validate_args_delete_row( p_row_id,
						       p_icr_line_id );
    END IF;
    --
    arp_cr_icr_lines_pkg.delete_p( p_icr_id, p_icr_line_id );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_line_pkg.delete_row()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug( 'EXCEPTION: arp_rw_icr_line_pkg.delete_row' );
              END IF;
              RAISE;
END delete_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_delete_row                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to delete_row   procedure                    |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id - Row Id                                         |
 |                 p_icr_line_id - ICR line ID                               |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 08/08/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_delete_row(
            p_row_id IN VARCHAR2,
            p_icr_line_id IN
                 ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_lines_pkg.validate_args_delete_row()+' );
    END IF;
    --
    IF ( p_row_id IS NULL OR p_icr_line_id IS NULL  ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_icr_line_pkg.validate_args_delete_row()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
		 arp_util.debug('EXCEPTION: arp_rw_icr_line_pkg.validate_args_delete_row' );
              END IF;
              RAISE;
END validate_args_delete_row;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_row     -  Lock    a row into the ICR_LINES table after checking  |
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function locks   a row into the ICR_LINES table after checking for|
 |    uniqueness for items such of the receipt number                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  08/08/95 - Created by Ganesh Vaidee               |
 | 08-12-97     KTANG        add global attributes in parameter list         |
 |                           for global descriptive flexfield                |
 +===========================================================================*/
PROCEDURE lock_row(
            p_row_id   VARCHAR2,
            p_icr_id
              ar_interim_cash_receipt_lines.cash_receipt_id%TYPE,
            p_icr_line_id
              ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_payment_amount
              ar_interim_cash_receipt_lines.payment_amount%TYPE,
            p_payment_schedule_id
              ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id
              ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer
              ar_interim_cash_receipt_lines.sold_to_customer%TYPE,
            p_discount_taken
              ar_interim_cash_receipt_lines.discount_taken%TYPE,
            p_due_date ar_interim_cash_receipt_lines.due_date%TYPE,
            p_ussgl_transaction_code
              ar_interim_cash_receipt_lines.ussgl_transaction_code%TYPE,
            p_attribute_category
              ar_interim_cash_receipt_lines.attribute_category%TYPE,
            p_attribute1 ar_interim_cash_receipt_lines.attribute1%TYPE,
            p_attribute2 ar_interim_cash_receipt_lines.attribute2%TYPE,
            p_attribute3 ar_interim_cash_receipt_lines.attribute3%TYPE,
            p_attribute4 ar_interim_cash_receipt_lines.attribute4%TYPE,
            p_attribute5 ar_interim_cash_receipt_lines.attribute5%TYPE,
            p_attribute6 ar_interim_cash_receipt_lines.attribute6%TYPE,
            p_attribute7 ar_interim_cash_receipt_lines.attribute7%TYPE,
            p_attribute8 ar_interim_cash_receipt_lines.attribute8%TYPE,
            p_attribute9 ar_interim_cash_receipt_lines.attribute9%TYPE,
            p_attribute10 ar_interim_cash_receipt_lines.attribute10%TYPE,
            p_attribute11 ar_interim_cash_receipt_lines.attribute11%TYPE,
            p_attribute12 ar_interim_cash_receipt_lines.attribute12%TYPE,
            p_attribute13 ar_interim_cash_receipt_lines.attribute13%TYPE,
            p_attribute14 ar_interim_cash_receipt_lines.attribute14%TYPE,
            p_attribute15 ar_interim_cash_receipt_lines.attribute15%TYPE,
            p_global_attribute_category IN
                ar_interim_cash_receipt_lines.global_attribute_category%TYPE,
            p_global_attribute1 IN
                ar_interim_cash_receipt_lines.global_attribute1%TYPE,
            p_global_attribute2 IN
                ar_interim_cash_receipt_lines.global_attribute2%TYPE,
            p_global_attribute3 IN
                ar_interim_cash_receipt_lines.global_attribute3%TYPE,
            p_global_attribute4 IN
                ar_interim_cash_receipt_lines.global_attribute4%TYPE,
            p_global_attribute5 IN
                ar_interim_cash_receipt_lines.global_attribute5%TYPE,
            p_global_attribute6 IN
                ar_interim_cash_receipt_lines.global_attribute6%TYPE,
            p_global_attribute7 IN
                ar_interim_cash_receipt_lines.global_attribute7%TYPE,
            p_global_attribute8 IN
                ar_interim_cash_receipt_lines.global_attribute8%TYPE,
            p_global_attribute9 IN
                ar_interim_cash_receipt_lines.global_attribute9%TYPE,
            p_global_attribute10 IN
                ar_interim_cash_receipt_lines.global_attribute10%TYPE,
            p_global_attribute11 IN
                ar_interim_cash_receipt_lines.global_attribute11%TYPE,
            p_global_attribute12 IN
                ar_interim_cash_receipt_lines.global_attribute12%TYPE,
            p_global_attribute13 IN
                ar_interim_cash_receipt_lines.global_attribute13%TYPE,
            p_global_attribute14 IN
                ar_interim_cash_receipt_lines.global_attribute14%TYPE,
            p_global_attribute15 IN
                ar_interim_cash_receipt_lines.global_attribute15%TYPE,
            p_global_attribute16 IN
                ar_interim_cash_receipt_lines.global_attribute16%TYPE,
            p_global_attribute17 IN
                ar_interim_cash_receipt_lines.global_attribute17%TYPE,
            p_global_attribute18 IN
                ar_interim_cash_receipt_lines.global_attribute18%TYPE,
            p_global_attribute19 IN
                ar_interim_cash_receipt_lines.global_attribute19%TYPE,
            p_global_attribute20 IN
                ar_interim_cash_receipt_lines.global_attribute20%TYPE ) IS
    CURSOR C IS
	SELECT *
	FROM ar_interim_cash_receipt_lines
	WHERE rowid = p_row_id
	FOR UPDATE of CASH_RECEIPT_ID NOWAIT;
    Recinfo C%ROWTYPE;
--
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
	CLOSE C;
	FND_MESSAGE.Set_Name(  'FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if(
                (Recinfo.cash_receipt_id = p_icr_id )
	    AND (Recinfo.cash_receipt_line_id = p_icr_line_id)
	    AND (   (Recinfo.payment_amount = p_payment_amount)
                OR  (   (Recinfo.payment_amount IS NULL)
                    AND (p_payment_amount IS NULL)))
	    AND (Recinfo.payment_schedule_id = p_payment_schedule_id)
	    AND (   (Recinfo.customer_trx_id = p_customer_trx_id)
                OR  (   (Recinfo.customer_trx_id IS NULL)
                    AND (p_customer_trx_id IS NULL)))
	    AND (   (Recinfo.batch_id = p_batch_id)
                OR  (   (Recinfo.batch_id IS NULL)
                    AND (p_batch_id IS NULL)))
	    AND (   (Recinfo.sold_to_customer = p_sold_to_customer)
                OR  (   (Recinfo.sold_to_customer IS NULL)
                    AND (p_sold_to_customer IS NULL)))
	    AND (   (Recinfo.discount_taken = p_discount_taken)
                OR  (   (Recinfo.discount_taken IS NULL)
                    AND (p_discount_taken IS NULL)))
	    AND (   (Recinfo.due_date = p_due_date)
                OR  (   (Recinfo.due_date IS NULL)
                    AND (p_due_date IS NULL)))
	    AND (   (Recinfo.ussgl_transaction_code = p_ussgl_transaction_code)
                OR  (   (Recinfo.ussgl_transaction_code IS NULL)
                    AND (p_ussgl_transaction_code IS NULL)))
	    AND (   (Recinfo.attribute_category = p_attribute_category)
                OR  (   (Recinfo.attribute_category IS NULL)
                    AND (p_attribute_category IS NULL)))
            AND (   (Recinfo.attribute1 = p_attribute1)
                OR  (   (Recinfo.attribute1 IS NULL)
                    AND (p_attribute1 IS NULL)))
            AND (   (Recinfo.attribute2 = p_attribute2)
                OR  (   (Recinfo.attribute2 IS NULL)
                    AND (p_attribute2 IS NULL)))
            AND (   (Recinfo.attribute3 = p_attribute3)
                OR  (   (Recinfo.attribute3 IS NULL)
                    AND (p_attribute3 IS NULL)))
            AND (   (Recinfo.attribute4 = p_attribute4)
                OR  (   (Recinfo.attribute4 IS NULL)
                    AND (p_attribute4 IS NULL)))
            AND (   (Recinfo.attribute5 = p_attribute5)
                OR  (   (Recinfo.attribute5 IS NULL)
                    AND (p_attribute5 IS NULL)))
            AND (   (Recinfo.attribute6 = p_attribute6)
                OR  (   (Recinfo.attribute6 IS NULL)
                    AND (p_attribute6 IS NULL)))
            AND (   (Recinfo.attribute7 = p_attribute7)
                OR  (   (Recinfo.attribute7 IS NULL)
                    AND (p_attribute7 IS NULL)))
            AND (   (Recinfo.attribute8 = p_attribute8)
                OR  (   (Recinfo.attribute8 IS NULL)
                    AND (p_attribute8 IS NULL)))
            AND (   (Recinfo.attribute9 = p_attribute9)
                OR  (   (Recinfo.attribute9 IS NULL)
                    AND (p_attribute9 IS NULL)))
            AND (   (Recinfo.attribute10 = p_attribute10)
                OR  (   (Recinfo.attribute10 IS NULL)
                    AND (p_attribute10 IS NULL)))
            AND (   (Recinfo.attribute11 = p_attribute11)
                OR  (   (Recinfo.attribute11 IS NULL)
                    AND (p_attribute11 IS NULL)))
            AND (   (Recinfo.attribute12 = p_attribute12)
                OR  (   (Recinfo.attribute12 IS NULL)
                    AND (p_attribute12 IS NULL)))
            AND (   (Recinfo.attribute13 = p_attribute13)
                OR  (   (Recinfo.attribute13 IS NULL)
                    AND (p_attribute13 IS NULL)))
            AND (   (Recinfo.attribute14 = p_attribute14)
                OR  (   (Recinfo.attribute14 IS NULL)
                    AND (p_attribute14 IS NULL)))
            AND (   (Recinfo.attribute15 = p_attribute15)
                OR  (   (Recinfo.attribute15 IS NULL)
                    AND (p_attribute15 IS NULL)))
            AND (   (Recinfo.global_attribute_category =
			 p_global_attribute_category)
                OR  (   (Recinfo.global_attribute_category IS NULL)
                    AND (p_global_attribute_category IS NULL)))
            AND (   (Recinfo.global_attribute1 = p_global_attribute1)
                OR  (   (Recinfo.global_attribute1 IS NULL)
                    AND (p_global_attribute1 IS NULL)))
            AND (   (Recinfo.global_attribute2 = p_global_attribute2)
                OR  (   (Recinfo.global_attribute2 IS NULL)
                    AND (p_global_attribute2 IS NULL)))
            AND (   (Recinfo.global_attribute3 = p_global_attribute3)
                OR  (   (Recinfo.global_attribute3 IS NULL)
                    AND (p_global_attribute3 IS NULL)))
            AND (   (Recinfo.global_attribute4 = p_global_attribute4)
                OR  (   (Recinfo.global_attribute4 IS NULL)
                    AND (p_global_attribute4 IS NULL)))
            AND (   (Recinfo.global_attribute5 = p_global_attribute5)
                OR  (   (Recinfo.global_attribute5 IS NULL)
                    AND (p_global_attribute5 IS NULL)))
            AND (   (Recinfo.global_attribute6 = p_global_attribute6)
                OR  (   (Recinfo.global_attribute6 IS NULL)
                    AND (p_global_attribute6 IS NULL)))
            AND (   (Recinfo.global_attribute7 = p_global_attribute7)
                OR  (   (Recinfo.global_attribute7 IS NULL)
                    AND (p_global_attribute7 IS NULL)))
            AND (   (Recinfo.global_attribute8 = p_global_attribute8)
                OR  (   (Recinfo.global_attribute8 IS NULL)
                    AND (p_global_attribute8 IS NULL)))
            AND (   (Recinfo.global_attribute9 = p_global_attribute9)
                OR  (   (Recinfo.global_attribute9 IS NULL)
                    AND (p_global_attribute9 IS NULL)))
            AND (   (Recinfo.global_attribute10 = p_global_attribute10)
                OR  (   (Recinfo.global_attribute10 IS NULL)
                    AND (p_global_attribute10 IS NULL)))
            AND (   (Recinfo.global_attribute11 = p_global_attribute11)
                OR  (   (Recinfo.global_attribute11 IS NULL)
                    AND (p_global_attribute11 IS NULL)))
            AND (   (Recinfo.global_attribute12 = p_global_attribute12)
                OR  (   (Recinfo.global_attribute12 IS NULL)
                    AND (p_global_attribute12 IS NULL)))
            AND (   (Recinfo.global_attribute13 = p_global_attribute13)
                OR  (   (Recinfo.global_attribute13 IS NULL)
                    AND (p_global_attribute13 IS NULL)))
            AND (   (Recinfo.global_attribute14 = p_global_attribute14)
                OR  (   (Recinfo.global_attribute14 IS NULL)
                    AND (p_global_attribute14 IS NULL)))
            AND (   (Recinfo.global_attribute15 = p_global_attribute15)
                OR  (   (Recinfo.global_attribute15 IS NULL)
                    AND (p_global_attribute15 IS NULL)))
            AND (   (Recinfo.global_attribute16 = p_global_attribute16)
                OR  (   (Recinfo.global_attribute16 IS NULL)
                    AND (p_global_attribute16 IS NULL)))
            AND (   (Recinfo.global_attribute17 = p_global_attribute17)
                OR  (   (Recinfo.global_attribute17 IS NULL)
                    AND (p_global_attribute17 IS NULL)))
            AND (   (Recinfo.global_attribute18 = p_global_attribute18)
                OR  (   (Recinfo.global_attribute18 IS NULL)
                    AND (p_global_attribute18 IS NULL)))
            AND (   (Recinfo.global_attribute19 = p_global_attribute19)
                OR  (   (Recinfo.global_attribute19 IS NULL)
                    AND (p_global_attribute19 IS NULL)))
            AND (   (Recinfo.global_attribute20 = p_global_attribute20)
                OR  (   (Recinfo.global_attribute20 IS NULL)
                    AND (p_global_attribute20 IS NULL)))
    ) then
        return;
    else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
    end if;
END lock_row;
--
END ARP_RW_ICR_LINES_PKG;

/
