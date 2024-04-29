--------------------------------------------------------
--  DDL for Package Body ARP_LOCKBOX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_LOCKBOX_PKG" AS
/* $Header: ARLBPIMB.pls 115.8 2003/10/10 14:24:51 mraymond ship $ */
--
/* Bugfix 2284014 */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE lock_trans_data(
		p_row_id   			IN VARCHAR2,
		p_transmission_record_id	IN NUMBER,
                p_lockbox_number                IN VARCHAR2,
                p_batch_name                    IN VARCHAR2,
                p_item_number                   IN VARCHAR2,
                p_check_number                  IN VARCHAR2,
                p_overflow_sequence             IN NUMBER,
                p_record_type                   IN VARCHAR2,
                p_comments                      IN VARCHAR2,
                p_origination                   IN VARCHAR2,
                p_destination_account           IN VARCHAR2,
                p_deposit_date                  IN DATE,
                p_gl_date                       IN DATE,
                p_deposit_time                  IN VARCHAR2,
                p_currency_code                 IN VARCHAR2,
                p_exchange_rate_type            IN VARCHAR2,
                p_exchange_rate                 IN NUMBER,
                p_transmission_record_count     IN NUMBER,
                p_transmission_amount           IN NUMBER,
                p_lockbox_batch_count           IN NUMBER,
                p_lockbox_amount                IN NUMBER,
                p_lockbox_record_count          IN NUMBER,
                p_batch_record_count            IN NUMBER,
                p_batch_amount                  IN NUMBER,
                p_transferred_receipt_count     IN NUMBER,
                p_transferred_receipt_amount    IN NUMBER,
                p_overflow_indicator            IN VARCHAR2,
                p_receipt_date                  IN DATE,
                p_receipt_method                IN VARCHAR2,
                p_receipt_method_id             IN NUMBER,
                p_remittance_amount             IN NUMBER,
                p_customer_number               IN VARCHAR2,
                p_customer_id                   IN NUMBER,
                p_bill_to_location              IN VARCHAR2,
                p_customer_site_use_id          IN NUMBER,
                p_transit_routing_number        IN VARCHAR2,
                p_account                       IN VARCHAR2,
                p_customer_bank_account_id      IN NUMBER,
                p_amount_applied1               IN NUMBER,
                p_invoice1                      IN VARCHAR2,
                p_invoice1_installment          IN NUMBER,
                p_invoice1_status               IN VARCHAR2,
                p_amount_applied2               IN NUMBER,
                p_invoice2                      IN VARCHAR2,
                p_invoice2_installment          IN NUMBER,
                p_invoice2_status               IN VARCHAR2,
                p_amount_applied3               IN NUMBER,
                p_invoice3                      IN VARCHAR2,
                p_invoice3_installment          IN NUMBER,
                p_invoice3_status               IN VARCHAR2,
                p_amount_applied4               IN NUMBER,
                p_invoice4                      IN VARCHAR2,
                p_invoice4_installment          IN NUMBER,
                p_invoice4_status               IN VARCHAR2,
                p_amount_applied5               IN NUMBER,
                p_invoice5                      IN VARCHAR2,
                p_invoice5_installment          IN NUMBER,
                p_invoice5_status               IN VARCHAR2,
                p_amount_applied6               IN NUMBER,
                p_invoice6                      IN VARCHAR2,
                p_invoice6_installment          IN NUMBER,
                p_invoice6_status               IN VARCHAR2,
                p_amount_applied7               IN NUMBER,
                p_invoice7                      IN VARCHAR2,
                p_invoice7_installment          IN NUMBER,
                p_invoice7_status               IN VARCHAR2,
                p_amount_applied8               IN NUMBER,
                p_invoice8                      IN VARCHAR2,
                p_invoice8_installment          IN NUMBER,
                p_invoice8_status               IN VARCHAR2,
                p_attribute1                    IN VARCHAR2,
                p_attribute2                    IN VARCHAR2,
                p_attribute3                    IN VARCHAR2,
                p_attribute4                    IN VARCHAR2,
                p_attribute5                    IN VARCHAR2,
                p_attribute6                    IN VARCHAR2,
                p_attribute7                    IN VARCHAR2,
                p_attribute8                    IN VARCHAR2,
                p_attribute9                    IN VARCHAR2,
                p_attribute10                   IN VARCHAR2,
                p_attribute11                   IN VARCHAR2,
                p_attribute12                   IN VARCHAR2,
                p_attribute13                   IN VARCHAR2,
                p_attribute14                   IN VARCHAR2,
                p_attribute15                   IN VARCHAR2,
                p_status                        IN VARCHAR2,
                p_matching1_date                IN DATE,
                p_matching2_date                IN DATE,
                p_matching3_date                IN DATE,
                p_matching4_date                IN DATE,
                p_matching5_date                IN DATE,
                p_matching6_date                IN DATE,
                p_matching7_date                IN DATE,
                p_matching8_date                IN DATE,
                p_amount_applied_from1          IN NUMBER,
                p_trans_to_receipt_rate1        IN NUMBER,
                p_invoice_currency_code1        IN VARCHAR2,
                p_amount_applied_from2          IN NUMBER,
                p_trans_to_receipt_rate2        IN NUMBER,
                p_invoice_currency_code2        IN VARCHAR2,
                p_amount_applied_from3          IN NUMBER,
                p_trans_to_receipt_rate3        IN NUMBER,
                p_invoice_currency_code3        IN VARCHAR2,
                p_amount_applied_from4          IN NUMBER,
                p_trans_to_receipt_rate4        IN NUMBER,
                p_invoice_currency_code4        IN VARCHAR2,
                p_amount_applied_from5          IN NUMBER,
                p_trans_to_receipt_rate5        IN NUMBER,
                p_invoice_currency_code5        IN VARCHAR2,
                p_amount_applied_from6          IN NUMBER,
                p_trans_to_receipt_rate6        IN NUMBER,
                p_invoice_currency_code6        IN VARCHAR2,
                p_amount_applied_from7          IN NUMBER,
                p_trans_to_receipt_rate7        IN NUMBER,
                p_invoice_currency_code7        IN VARCHAR2,
                p_amount_applied_from8          IN NUMBER,
                p_trans_to_receipt_rate8        IN NUMBER,
                p_invoice_currency_code8        IN VARCHAR2,
                p_ussgl_transaction_code        IN VARCHAR2,
                p_ussgl_transaction_code1       IN VARCHAR2,
                p_ussgl_transaction_code2       IN VARCHAR2,
                p_ussgl_transaction_code3       IN VARCHAR2,
                p_ussgl_transaction_code4       IN VARCHAR2,
                p_ussgl_transaction_code5       IN VARCHAR2,
                p_ussgl_transaction_code6       IN VARCHAR2,
                p_ussgl_transaction_code7       IN VARCHAR2,
                p_ussgl_transaction_code8       IN VARCHAR2
 ) IS
    CURSOR C IS
    SELECT *
    FROM  ar_payments_interface
    WHERE rowid = p_row_id
    FOR UPDATE of transmission_record_id NOWAIT;

    Recinfo C%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_lockbox_pkg.lock_trans_data()+' );
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
	   ((Recinfo.transmission_record_id  = p_transmission_record_id)
                OR  (   (Recinfo.transmission_record_id IS NULL)
                    AND (p_transmission_record_id IS NULL)))
	AND ((Recinfo.lockbox_number  = p_lockbox_number)
                OR  (   (Recinfo.lockbox_number IS NULL)
                    AND (p_lockbox_number IS NULL)))
        AND ((Recinfo.batch_name  = p_batch_name)
                OR  (   (Recinfo.batch_name IS NULL)
                    AND (p_batch_name IS NULL)))
        AND ((Recinfo.item_number  = p_item_number)
                OR  (   (Recinfo.item_number IS NULL)
                    AND (p_item_number IS NULL)))
        AND ((Recinfo.check_number  = p_check_number)
                OR  (   (Recinfo.check_number IS NULL)
                    AND (p_check_number IS NULL)))
        AND ((Recinfo.overflow_sequence  = p_overflow_sequence)
                OR  (   (Recinfo.overflow_sequence IS NULL)
                    AND (p_overflow_sequence IS NULL)))
        AND (Recinfo.record_type  = p_record_type)
        AND ((Recinfo.comments  = p_comments)
                OR  (   (Recinfo.comments IS NULL)
                    AND (p_comments IS NULL)))
        AND ((Recinfo.origination  = p_origination)
                OR  (   (Recinfo.origination IS NULL)
                    AND (p_origination IS NULL)))
        AND ((Recinfo.destination_account  = p_destination_account)
                OR  (   (Recinfo.destination_account IS NULL)
                    AND (p_destination_account IS NULL)))
        AND ((Recinfo.deposit_date  = p_deposit_date)
                OR  (   (Recinfo.deposit_date IS NULL)
                    AND (p_deposit_date IS NULL)))
        AND ((Recinfo.gl_date  = p_gl_date)
                OR  (   (Recinfo.gl_date IS NULL)
                    AND (p_gl_date IS NULL)))
        AND ((Recinfo.deposit_time  = p_deposit_time)
                OR  (   (Recinfo.deposit_time IS NULL)
                    AND (p_deposit_time IS NULL)))
        AND ((Recinfo.currency_code  = p_currency_code)
                OR  (   (Recinfo.currency_code IS NULL)
                    AND (p_currency_code IS NULL)))
        AND ((Recinfo.exchange_rate_type  = p_exchange_rate_type)
                OR  (   (Recinfo.exchange_rate_type IS NULL)
                    AND (p_exchange_rate_type IS NULL)))
        AND ((Recinfo.exchange_rate  = p_exchange_rate)
                OR  (   (Recinfo.exchange_rate IS NULL)
                    AND (p_exchange_rate IS NULL)))
        AND ((Recinfo.transmission_record_count  = p_transmission_record_count)
                OR  (   (Recinfo.transmission_record_count IS NULL)
                    AND (p_transmission_record_count IS NULL)))
        AND ((Recinfo.transmission_amount  = p_transmission_amount)
                OR  (   (Recinfo.transmission_amount IS NULL)
                    AND (p_transmission_amount IS NULL)))
        AND ((Recinfo.lockbox_batch_count  = p_lockbox_batch_count)
                OR  (   (Recinfo.lockbox_batch_count IS NULL)
                    AND (p_lockbox_batch_count IS NULL)))
        AND ((Recinfo.lockbox_amount  = p_lockbox_amount)
                OR  (   (Recinfo.lockbox_amount IS NULL)
                    AND (p_lockbox_amount IS NULL)))
        AND ((Recinfo.lockbox_record_count  = p_lockbox_record_count)
                OR  (   (Recinfo.lockbox_record_count IS NULL)
                    AND (p_lockbox_record_count IS NULL)))
        AND ((Recinfo.batch_record_count  = p_batch_record_count)
                OR  (   (Recinfo.batch_record_count IS NULL)
                    AND (p_batch_record_count IS NULL)))
        AND ((Recinfo.batch_amount  = p_batch_amount)
                OR  (   (Recinfo.batch_amount IS NULL)
                    AND (p_batch_amount IS NULL)))
        AND ((Recinfo.transferred_receipt_count  = p_transferred_receipt_count)
                OR  (   (Recinfo.transferred_receipt_count IS NULL)
                    AND (p_transferred_receipt_count IS NULL)))
        AND ((Recinfo.transferred_receipt_amount  = p_transferred_receipt_amount)
                OR  (   (Recinfo.transferred_receipt_amount IS NULL)
                    AND (p_transferred_receipt_amount IS NULL)))
        AND ((Recinfo.overflow_indicator  = p_overflow_indicator)
                OR  (   (Recinfo.overflow_indicator IS NULL)
                    AND (p_overflow_indicator IS NULL)))
        AND ((Recinfo.receipt_date  = p_receipt_date)
                OR  (   (Recinfo.receipt_date IS NULL)
                    AND (p_receipt_date IS NULL)))
        AND ((Recinfo.receipt_method  = p_receipt_method)
                OR  (   (Recinfo.receipt_method IS NULL)
                    AND (p_receipt_method IS NULL)))
        AND ((Recinfo.receipt_method_id  = p_receipt_method_id)
                OR  (   (Recinfo.receipt_method_id IS NULL)
                    AND (p_receipt_method_id IS NULL)))
        AND ((Recinfo.remittance_amount  = p_remittance_amount)
                OR  (   (Recinfo.remittance_amount IS NULL)
                    AND (p_remittance_amount IS NULL)))
        AND ((Recinfo.customer_number  = p_customer_number)
                OR  (   (Recinfo.customer_number IS NULL)
                    AND (p_customer_number IS NULL)))
        AND ((Recinfo.customer_id  = p_customer_id)
                OR  (   (Recinfo.customer_id IS NULL)
                    AND (p_customer_id IS NULL)))
        AND ((Recinfo.bill_to_location  = p_bill_to_location)
                OR  (   (Recinfo.bill_to_location IS NULL)
                    AND (p_bill_to_location IS NULL)))
        AND ((Recinfo.customer_site_use_id  = p_customer_site_use_id)
                OR  (   (Recinfo.customer_site_use_id IS NULL)
                    AND (p_customer_site_use_id IS NULL)))
        AND ((Recinfo.transit_routing_number  = p_transit_routing_number)
                OR  (   (Recinfo.transit_routing_number IS NULL)
                    AND (p_transit_routing_number IS NULL)))
        AND ((Recinfo.account  = p_account)
                OR  (   (Recinfo.account IS NULL)
                    AND (p_account IS NULL)))
        /* Bugfix 2750412 */
	AND ((Recinfo.customer_bank_account_id  = p_customer_bank_account_id)
                OR  (   (Recinfo.customer_bank_account_id IS NULL)
                    AND (p_customer_bank_account_id IS NULL)))
        AND ((Recinfo.amount_applied1  = p_amount_applied1)
                OR  (   (Recinfo.amount_applied1 IS NULL)
                    AND (p_amount_applied1 IS NULL)))
        AND ((Recinfo.invoice1  = p_invoice1)
                OR  (   (Recinfo.invoice1 IS NULL)
                    AND (p_invoice1 IS NULL)))
        AND ((Recinfo.invoice1_installment  = p_invoice1_installment)
                OR  (   (Recinfo.invoice1_installment IS NULL)
                    AND (p_invoice1_installment IS NULL)))
        AND ((Recinfo.invoice1_status  = p_invoice1_status)
                OR  (   (Recinfo.invoice1_status IS NULL)
                    AND (p_invoice1_status IS NULL)))
        AND ((Recinfo.amount_applied2  = p_amount_applied2)
                OR  (   (Recinfo.amount_applied2 IS NULL)
                    AND (p_amount_applied2 IS NULL)))
        AND ((Recinfo.invoice2  = p_invoice2)
                OR  (   (Recinfo.invoice2 IS NULL)
                    AND (p_invoice2 IS NULL)))
        AND ((Recinfo.invoice2_installment  = p_invoice2_installment)
                OR  (   (Recinfo.invoice2_installment IS NULL)
                    AND (p_invoice2_installment IS NULL)))
        AND ((Recinfo.invoice2_status  = p_invoice2_status)
                OR  (   (Recinfo.invoice2_status IS NULL)
                    AND (p_invoice2_status IS NULL)))
        AND ((Recinfo.amount_applied3  = p_amount_applied3)
                OR  (   (Recinfo.amount_applied3 IS NULL)
                    AND (p_amount_applied3 IS NULL)))
        AND ((Recinfo.invoice3  = p_invoice3)
                OR  (   (Recinfo.invoice3 IS NULL)
                    AND (p_invoice3 IS NULL)))
        AND ((Recinfo.invoice3_installment  = p_invoice3_installment)
                OR  (   (Recinfo.invoice3_installment IS NULL)
                    AND (p_invoice3_installment IS NULL)))
        AND ((Recinfo.invoice3_status  = p_invoice3_status)
                OR  (   (Recinfo.invoice3_status IS NULL)
                    AND (p_invoice3_status IS NULL)))
        AND ((Recinfo.amount_applied4  = p_amount_applied4)
                OR  (   (Recinfo.amount_applied4 IS NULL)
                    AND (p_amount_applied4 IS NULL)))
        AND ((Recinfo.invoice4  = p_invoice4)
                OR  (   (Recinfo.invoice4 IS NULL)
                    AND (p_invoice4 IS NULL)))
        AND ((Recinfo.invoice4_installment  = p_invoice4_installment)
                OR  (   (Recinfo.invoice4_installment IS NULL)
                    AND (p_invoice4_installment IS NULL)))
        AND ((Recinfo.invoice4_status  = p_invoice4_status)
                OR  (   (Recinfo.invoice4_status IS NULL)
                    AND (p_invoice4_status IS NULL)))
        AND ((Recinfo.amount_applied5  = p_amount_applied5)
                OR  (   (Recinfo.amount_applied5 IS NULL)
                    AND (p_amount_applied5 IS NULL)))
        AND ((Recinfo.invoice5  = p_invoice5)
                OR  (   (Recinfo.invoice5 IS NULL)
                    AND (p_invoice5 IS NULL)))
        AND ((Recinfo.invoice5_installment  = p_invoice5_installment)
                OR  (   (Recinfo.invoice5_installment IS NULL)
                    AND (p_invoice5_installment IS NULL)))
        AND ((Recinfo.invoice5_status  = p_invoice5_status)
                OR  (   (Recinfo.invoice5_status IS NULL)
                    AND (p_invoice5_status IS NULL)))
        AND ((Recinfo.amount_applied6  = p_amount_applied6)
                OR  (   (Recinfo.amount_applied6 IS NULL)
                    AND (p_amount_applied6 IS NULL)))
        AND ((Recinfo.invoice6  = p_invoice6)
                OR  (   (Recinfo.invoice6 IS NULL)
                    AND (p_invoice6 IS NULL)))
        AND ((Recinfo.invoice6_installment  = p_invoice6_installment)
                OR  (   (Recinfo.invoice6_installment IS NULL)
                    AND (p_invoice6_installment IS NULL)))
        AND ((Recinfo.invoice6_status  = p_invoice6_status)
                OR  (   (Recinfo.invoice6_status IS NULL)
                    AND (p_invoice6_status IS NULL)))
        AND ((Recinfo.amount_applied7  = p_amount_applied7)
                OR  (   (Recinfo.amount_applied7 IS NULL)
                    AND (p_amount_applied7 IS NULL)))
        AND ((Recinfo.invoice7  = p_invoice7)
                OR  (   (Recinfo.invoice7 IS NULL)
                    AND (p_invoice7 IS NULL)))
        AND ((Recinfo.invoice7_installment  = p_invoice7_installment)
                OR  (   (Recinfo.invoice7_installment IS NULL)
                    AND (p_invoice7_installment IS NULL)))
        AND ((Recinfo.invoice7_status  = p_invoice7_status)
                OR  (   (Recinfo.invoice7_status IS NULL)
                    AND (p_invoice7_status IS NULL)))
        AND ((Recinfo.amount_applied8  = p_amount_applied8)
                OR  (   (Recinfo.amount_applied8 IS NULL)
                    AND (p_amount_applied8 IS NULL)))
        AND ((Recinfo.invoice8  = p_invoice8)
                OR  (   (Recinfo.invoice8 IS NULL)
                    AND (p_invoice8 IS NULL)))
        AND ((Recinfo.invoice8_installment  = p_invoice8_installment)
                OR  (   (Recinfo.invoice8_installment IS NULL)
                    AND (p_invoice8_installment IS NULL)))
        AND ((Recinfo.invoice8_status  = p_invoice8_status)
                OR  (   (Recinfo.invoice8_status IS NULL)
                    AND (p_invoice8_status IS NULL)))
        AND ((Recinfo.attribute1  = p_attribute1)
                OR  (   (Recinfo.attribute1 IS NULL)
                    AND (p_attribute1 IS NULL)))
        AND ((Recinfo.attribute2  = p_attribute2)
                OR  (   (Recinfo.attribute2 IS NULL)
                    AND (p_attribute2 IS NULL)))
        AND ((Recinfo.attribute3  = p_attribute3)
                OR  (   (Recinfo.attribute3 IS NULL)
                    AND (p_attribute3 IS NULL)))
        AND ((Recinfo.attribute4  = p_attribute4)
                OR  (   (Recinfo.attribute4 IS NULL)
                    AND (p_attribute4 IS NULL)))
        AND ((Recinfo.attribute5  = p_attribute5)
                OR  (   (Recinfo.attribute5 IS NULL)
                    AND (p_attribute5 IS NULL)))
        AND ((Recinfo.attribute6  = p_attribute6)
                OR  (   (Recinfo.attribute6 IS NULL)
                    AND (p_attribute6 IS NULL)))
        AND ((Recinfo.attribute7  = p_attribute7)
                OR  (   (Recinfo.attribute7 IS NULL)
                    AND (p_attribute7 IS NULL)))
        AND ((Recinfo.attribute8  = p_attribute8)
                OR  (   (Recinfo.attribute8 IS NULL)
                    AND (p_attribute8 IS NULL)))
        AND ((Recinfo.attribute9  = p_attribute9)
                OR  (   (Recinfo.attribute9 IS NULL)
                    AND (p_attribute9 IS NULL)))
        AND ((Recinfo.attribute10  = p_attribute10)
                OR  (   (Recinfo.attribute10 IS NULL)
                    AND (p_attribute10 IS NULL)))
        AND ((Recinfo.attribute11  = p_attribute11)
                OR  (   (Recinfo.attribute11 IS NULL)
                    AND (p_attribute11 IS NULL)))
        AND ((Recinfo.attribute12  = p_attribute12)
                OR  (   (Recinfo.attribute12 IS NULL)
                    AND (p_attribute12 IS NULL)))
        AND ((Recinfo.attribute13  = p_attribute13)
                OR  (   (Recinfo.attribute13 IS NULL)
                    AND (p_attribute13 IS NULL)))
        AND ((Recinfo.attribute14  = p_attribute14)
                OR  (   (Recinfo.attribute14 IS NULL)
                    AND (p_attribute14 IS NULL)))
        AND ((Recinfo.attribute15  = p_attribute15)
                OR  (   (Recinfo.attribute15 IS NULL)
                    AND (p_attribute15 IS NULL)))
        AND ((Recinfo.status  = p_status)
                OR  (   (Recinfo.status IS NULL)
                    AND (p_status IS NULL)))
        AND ((Recinfo.matching1_date  = p_matching1_date)
                OR  (   (Recinfo.matching1_date IS NULL)
                    AND (p_matching1_date IS NULL)))
        AND ((Recinfo.matching2_date  = p_matching2_date)
                OR  (   (Recinfo.matching2_date IS NULL)
                    AND (p_matching2_date IS NULL)))
        AND ((Recinfo.matching3_date  = p_matching3_date)
                OR  (   (Recinfo.matching3_date IS NULL)
                    AND (p_matching3_date IS NULL)))
        AND ((Recinfo.matching4_date  = p_matching4_date)
                OR  (   (Recinfo.matching4_date IS NULL)
                    AND (p_matching4_date IS NULL)))
        AND ((Recinfo.matching5_date  = p_matching5_date)
                OR  (   (Recinfo.matching5_date IS NULL)
                    AND (p_matching5_date IS NULL)))
        AND ((Recinfo.matching6_date  = p_matching6_date)
                OR  (   (Recinfo.matching6_date IS NULL)
                    AND (p_matching6_date IS NULL)))
        AND ((Recinfo.matching7_date  = p_matching7_date)
                OR  (   (Recinfo.matching7_date IS NULL)
                    AND (p_matching7_date IS NULL)))
        AND ((Recinfo.matching8_date  = p_matching8_date)
                OR  (   (Recinfo.matching8_date IS NULL)
                    AND (p_matching8_date IS NULL)))
        AND ((Recinfo.amount_applied_from1  = p_amount_applied_from1)
                OR  (   (Recinfo.amount_applied_from1 IS NULL)
                    AND (p_amount_applied_from1 IS NULL)))
        AND ((Recinfo.trans_to_receipt_rate1  = p_trans_to_receipt_rate1)
                OR  (   (Recinfo.trans_to_receipt_rate1 IS NULL)
                    AND (p_trans_to_receipt_rate1 IS NULL)))
        AND ((Recinfo.invoice_currency_code1  = p_invoice_currency_code1)
                OR  (   (Recinfo.invoice_currency_code1 IS NULL)
                    AND (p_invoice_currency_code1 IS NULL)))
        AND ((Recinfo.amount_applied_from2  = p_amount_applied_from2)
                OR  (   (Recinfo.amount_applied_from2 IS NULL)
                    AND (p_amount_applied_from2 IS NULL)))
        AND ((Recinfo.trans_to_receipt_rate2  = p_trans_to_receipt_rate2)
                OR  (   (Recinfo.trans_to_receipt_rate2 IS NULL)
                    AND (p_trans_to_receipt_rate2 IS NULL)))
        AND ((Recinfo.invoice_currency_code2  = p_invoice_currency_code2)
                OR  (   (Recinfo.invoice_currency_code2 IS NULL)
                    AND (p_invoice_currency_code2 IS NULL)))
        AND ((Recinfo.amount_applied_from3  = p_amount_applied_from3)
                OR  (   (Recinfo.amount_applied_from3 IS NULL)
                    AND (p_amount_applied_from3 IS NULL)))
        AND ((Recinfo.trans_to_receipt_rate3  = p_trans_to_receipt_rate3)
                OR  (   (Recinfo.trans_to_receipt_rate3 IS NULL)
                    AND (p_trans_to_receipt_rate3 IS NULL)))
        AND ((Recinfo.invoice_currency_code3  = p_invoice_currency_code3)
                OR  (   (Recinfo.invoice_currency_code3 IS NULL)
                    AND (p_invoice_currency_code3 IS NULL)))
        AND ((Recinfo.amount_applied_from4  = p_amount_applied_from4)
                OR  (   (Recinfo.amount_applied_from4 IS NULL)
                    AND (p_amount_applied_from4 IS NULL)))
        AND ((Recinfo.trans_to_receipt_rate4  = p_trans_to_receipt_rate4)
                OR  (   (Recinfo.trans_to_receipt_rate4 IS NULL)
                    AND (p_trans_to_receipt_rate4 IS NULL)))
        AND ((Recinfo.invoice_currency_code4  = p_invoice_currency_code4)
                OR  (   (Recinfo.invoice_currency_code4 IS NULL)
                    AND (p_invoice_currency_code4 IS NULL)))
        AND ((Recinfo.amount_applied_from5  = p_amount_applied_from5)
                OR  (   (Recinfo.amount_applied_from5 IS NULL)
                    AND (p_amount_applied_from5 IS NULL)))
        AND ((Recinfo.trans_to_receipt_rate5  = p_trans_to_receipt_rate5)
                OR  (   (Recinfo.trans_to_receipt_rate5 IS NULL)
                    AND (p_trans_to_receipt_rate5 IS NULL)))
        AND ((Recinfo.invoice_currency_code5  = p_invoice_currency_code5)
                OR  (   (Recinfo.invoice_currency_code5 IS NULL)
                    AND (p_invoice_currency_code5 IS NULL)))
        AND ((Recinfo.amount_applied_from6  = p_amount_applied_from6)
                OR  (   (Recinfo.amount_applied_from6 IS NULL)
                    AND (p_amount_applied_from6 IS NULL)))
        AND ((Recinfo.trans_to_receipt_rate6  = p_trans_to_receipt_rate6)
                OR  (   (Recinfo.trans_to_receipt_rate6 IS NULL)
                    AND (p_trans_to_receipt_rate6 IS NULL)))
        AND ((Recinfo.invoice_currency_code6  = p_invoice_currency_code6)
                OR  (   (Recinfo.invoice_currency_code6 IS NULL)
                    AND (p_invoice_currency_code6 IS NULL)))
        AND ((Recinfo.amount_applied_from7  = p_amount_applied_from7)
                OR  (   (Recinfo.amount_applied_from7 IS NULL)
                    AND (p_amount_applied_from7 IS NULL)))
        AND ((Recinfo.trans_to_receipt_rate7  = p_trans_to_receipt_rate7)
                OR  (   (Recinfo.trans_to_receipt_rate7 IS NULL)
                    AND (p_trans_to_receipt_rate7 IS NULL)))
        AND ((Recinfo.invoice_currency_code7  = p_invoice_currency_code7)
                OR  (   (Recinfo.invoice_currency_code7 IS NULL)
                    AND (p_invoice_currency_code7 IS NULL)))
        AND ((Recinfo.amount_applied_from8  = p_amount_applied_from8)
                OR  (   (Recinfo.amount_applied_from8 IS NULL)
                    AND (p_amount_applied_from8 IS NULL)))
        AND ((Recinfo.trans_to_receipt_rate8  = p_trans_to_receipt_rate8)
                OR  (   (Recinfo.trans_to_receipt_rate8 IS NULL)
                    AND (p_trans_to_receipt_rate8 IS NULL)))
        AND ((Recinfo.invoice_currency_code8  = p_invoice_currency_code8)
                OR  (   (Recinfo.invoice_currency_code8 IS NULL)
                    AND (p_invoice_currency_code8 IS NULL)))
        AND ((Recinfo.ussgl_transaction_code  = p_ussgl_transaction_code)
                OR  (   (Recinfo.ussgl_transaction_code IS NULL)
                    AND (p_ussgl_transaction_code IS NULL)))
        AND ((Recinfo.ussgl_transaction_code1  = p_ussgl_transaction_code1)
                OR  (   (Recinfo.ussgl_transaction_code1 IS NULL)
                    AND (p_ussgl_transaction_code1 IS NULL)))
        AND ((Recinfo.ussgl_transaction_code2  = p_ussgl_transaction_code2)
                OR  (   (Recinfo.ussgl_transaction_code2 IS NULL)
                    AND (p_ussgl_transaction_code2 IS NULL)))
        AND ((Recinfo.ussgl_transaction_code3  = p_ussgl_transaction_code3)
                OR  (   (Recinfo.ussgl_transaction_code3 IS NULL)
                    AND (p_ussgl_transaction_code3 IS NULL)))
        AND ((Recinfo.ussgl_transaction_code4  = p_ussgl_transaction_code4)
                OR  (   (Recinfo.ussgl_transaction_code4 IS NULL)
                    AND (p_ussgl_transaction_code4 IS NULL)))
        AND ((Recinfo.ussgl_transaction_code5  = p_ussgl_transaction_code5)
                OR  (   (Recinfo.ussgl_transaction_code5 IS NULL)
                    AND (p_ussgl_transaction_code5 IS NULL)))
        AND ((Recinfo.ussgl_transaction_code6  = p_ussgl_transaction_code6)
                OR  (   (Recinfo.ussgl_transaction_code6 IS NULL)
                    AND (p_ussgl_transaction_code6 IS NULL)))
        AND ((Recinfo.ussgl_transaction_code7  = p_ussgl_transaction_code7)
                OR  (   (Recinfo.ussgl_transaction_code7 IS NULL)
                    AND (p_ussgl_transaction_code7 IS NULL)))
        AND ((Recinfo.ussgl_transaction_code8  = p_ussgl_transaction_code8)
                OR  (   (Recinfo.ussgl_transaction_code8 IS NULL)
                    AND (p_ussgl_transaction_code8 IS NULL)))
    ) then
        return;
    else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
    end if;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_lockbox_pkg.lock_trans_data()-' );
    END IF;
EXCEPTION
    WHEN  OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug( 'EXCEPTION: arp_lockbox_pkg.lock_trans_data' );
       END IF;
       RAISE;
END lock_trans_data;

--
PROCEDURE update_trans_data(
		p_transmission_record_id	IN NUMBER,
		p_lockbox_number		IN VARCHAR2,
		p_batch_name			IN VARCHAR2,
		p_item_number			IN VARCHAR2,
		p_check_number			IN VARCHAR2,
		p_overflow_sequence		IN NUMBER,
		p_record_type			IN VARCHAR2,
		p_comments			IN VARCHAR2,
		p_origination			IN VARCHAR2,
		p_destination_account		IN VARCHAR2,
		p_deposit_date			IN DATE,
		p_gl_date			IN DATE,
		p_deposit_time			IN VARCHAR2,
		p_currency_code			IN VARCHAR2,
		p_exchange_rate_type		IN VARCHAR2,
		p_exchange_rate			IN NUMBER,
		p_transmission_record_count	IN NUMBER,
		p_transmission_amount		IN NUMBER,
		p_lockbox_batch_count		IN NUMBER,
		p_lockbox_amount		IN NUMBER,
		p_lockbox_record_count		IN NUMBER,
		p_batch_record_count		IN NUMBER,
		p_batch_amount			IN NUMBER,
		p_transferred_receipt_count	IN NUMBER,
		p_transferred_receipt_amount	IN NUMBER,
		p_overflow_indicator		IN VARCHAR2,
		p_receipt_date			IN DATE,
		p_receipt_method		IN VARCHAR2,
		p_receipt_method_id		IN NUMBER,
		p_remittance_amount		IN NUMBER,
		p_customer_number		IN VARCHAR2,
		p_customer_id			IN NUMBER,
		p_bill_to_location		IN VARCHAR2,
		p_customer_site_use_id		IN NUMBER,
		p_transit_routing_number	IN VARCHAR2,
		p_account			IN VARCHAR2,
		p_customer_bank_account_id	IN NUMBER,
		p_amount_applied1		IN NUMBER,
		p_invoice1			IN VARCHAR2,
		p_invoice1_installment		IN NUMBER,
		p_invoice1_status		IN VARCHAR2,
		p_amount_applied2		IN NUMBER,
		p_invoice2			IN VARCHAR2,
		p_invoice2_installment		IN NUMBER,
		p_invoice2_status		IN VARCHAR2,
		p_amount_applied3		IN NUMBER,
		p_invoice3			IN VARCHAR2,
		p_invoice3_installment		IN NUMBER,
		p_invoice3_status		IN VARCHAR2,
		p_amount_applied4		IN NUMBER,
		p_invoice4			IN VARCHAR2,
		p_invoice4_installment		IN NUMBER,
		p_invoice4_status		IN VARCHAR2,
		p_amount_applied5		IN NUMBER,
		p_invoice5			IN VARCHAR2,
		p_invoice5_installment		IN NUMBER,
		p_invoice5_status		IN VARCHAR2,
		p_amount_applied6		IN NUMBER,
		p_invoice6			IN VARCHAR2,
		p_invoice6_installment		IN NUMBER,
		p_invoice6_status		IN VARCHAR2,
		p_amount_applied7		IN NUMBER,
		p_invoice7			IN VARCHAR2,
		p_invoice7_installment		IN NUMBER,
		p_invoice7_status		IN VARCHAR2,
		p_amount_applied8		IN NUMBER,
		p_invoice8			IN VARCHAR2,
		p_invoice8_installment		IN NUMBER,
		p_invoice8_status		IN VARCHAR2,
		p_attribute1			IN VARCHAR2,
		p_attribute2			IN VARCHAR2,
		p_attribute3			IN VARCHAR2,
		p_attribute4			IN VARCHAR2,
		p_attribute5			IN VARCHAR2,
		p_attribute6			IN VARCHAR2,
		p_attribute7			IN VARCHAR2,
		p_attribute8			IN VARCHAR2,
		p_attribute9			IN VARCHAR2,
		p_attribute10			IN VARCHAR2,
		p_attribute11			IN VARCHAR2,
		p_attribute12			IN VARCHAR2,
		p_attribute13			IN VARCHAR2,
		p_attribute14			IN VARCHAR2,
		p_attribute15			IN VARCHAR2,
                p_status                        IN VARCHAR2,
                p_matching1_date		IN DATE,
                p_matching2_date		IN DATE,
                p_matching3_date		IN DATE,
                p_matching4_date		IN DATE,
                p_matching5_date		IN DATE,
                p_matching6_date		IN DATE,
                p_matching7_date		IN DATE,
                p_matching8_date		IN DATE,
		p_amount_applied_from1		IN NUMBER,
		p_trans_to_receipt_rate1	IN NUMBER,
		p_invoice_currency_code1	IN VARCHAR2,
		p_amount_applied_from2		IN NUMBER,
		p_trans_to_receipt_rate2	IN NUMBER,
		p_invoice_currency_code2	IN VARCHAR2,
		p_amount_applied_from3		IN NUMBER,
		p_trans_to_receipt_rate3	IN NUMBER,
		p_invoice_currency_code3	IN VARCHAR2,
		p_amount_applied_from4		IN NUMBER,
		p_trans_to_receipt_rate4	IN NUMBER,
		p_invoice_currency_code4	IN VARCHAR2,
		p_amount_applied_from5		IN NUMBER,
		p_trans_to_receipt_rate5	IN NUMBER,
		p_invoice_currency_code5	IN VARCHAR2,
		p_amount_applied_from6		IN NUMBER,
		p_trans_to_receipt_rate6	IN NUMBER,
		p_invoice_currency_code6	IN VARCHAR2,
		p_amount_applied_from7		IN NUMBER,
		p_trans_to_receipt_rate7	IN NUMBER,
		p_invoice_currency_code7	IN VARCHAR2,
		p_amount_applied_from8		IN NUMBER,
		p_trans_to_receipt_rate8	IN NUMBER,
		p_invoice_currency_code8	IN VARCHAR2,
                p_ussgl_transaction_code        IN VARCHAR2,
                p_ussgl_transaction_code1       IN VARCHAR2,
                p_ussgl_transaction_code2       IN VARCHAR2,
                p_ussgl_transaction_code3       IN VARCHAR2,
                p_ussgl_transaction_code4       IN VARCHAR2,
                p_ussgl_transaction_code5       IN VARCHAR2,
                p_ussgl_transaction_code6       IN VARCHAR2,
                p_ussgl_transaction_code7       IN VARCHAR2,
                p_ussgl_transaction_code8       IN VARCHAR2
  ) IS

l_dummy	NUMBER;
l_break_point	VARCHAR2(30);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_lockbox_pkg.update_trans_data()+');
   END IF;
   --
/*  Bugfix 2284014. Commented the foll. code that earlier
locked the record
   l_break_point := 'lock record';
   SELECT transmission_record_id
   INTO   l_dummy
   FROM   ar_payments_interface
   WHERE  transmission_record_id = p_transmission_record_id
   FOR UPDATE NOWAIT;               */
   --
   l_break_point := 'update record';
   UPDATE ar_payments_interface
      SET lockbox_number = p_lockbox_number,
          batch_name = p_batch_name,
          item_number = p_item_number,
	  check_number = p_check_number,
          overflow_sequence = p_overflow_sequence,
          record_type = p_record_type,
          comments = p_comments,
          origination = p_origination,
          destination_account = p_destination_account,
          deposit_date = p_deposit_date,
          gl_date = p_gl_date,
          deposit_time = p_deposit_time,
          currency_code = p_currency_code,
          exchange_rate_type = p_exchange_rate_type,
          exchange_rate = p_exchange_rate,
          transmission_record_count = p_transmission_record_count,
          transmission_amount = p_transmission_amount,
          lockbox_batch_count = p_lockbox_batch_count,
          lockbox_amount = p_lockbox_amount,
          lockbox_record_count = p_lockbox_record_count,
          batch_record_count = p_batch_record_count,
          batch_amount = p_batch_amount,
          transferred_receipt_count = p_transferred_receipt_count,
          transferred_receipt_amount = p_transferred_receipt_amount,
          overflow_indicator = p_overflow_indicator,
          receipt_date = p_receipt_date,
          receipt_method = p_receipt_method,
          receipt_method_id = p_receipt_method_id,
          remittance_amount = p_remittance_amount,
          customer_number = p_customer_number,
          customer_id = p_customer_id,
          bill_to_location = p_bill_to_location,
          customer_site_use_id = p_customer_site_use_id,
          transit_routing_number = p_transit_routing_number,
          account = p_account,
          customer_bank_account_id = p_customer_bank_account_id,
          amount_applied1 = p_amount_applied1,
          invoice1 = p_invoice1,
          invoice1_installment = p_invoice1_installment,
          invoice1_status = p_invoice1_status,
          amount_applied2 = p_amount_applied2,
          invoice2 = p_invoice2,
          invoice2_installment = p_invoice2_installment,
          invoice2_status = p_invoice2_status,
          amount_applied3 = p_amount_applied3,
          invoice3 = p_invoice3,
          invoice3_installment = p_invoice3_installment,
          invoice3_status = p_invoice3_status,
          amount_applied4 = p_amount_applied4,
          invoice4 = p_invoice4,
          invoice4_installment = p_invoice4_installment,
          invoice4_status = p_invoice4_status,
          amount_applied5 = p_amount_applied5,
          invoice5 = p_invoice5,
          invoice5_installment = p_invoice5_installment,
          invoice5_status = p_invoice5_status,
          amount_applied6 = p_amount_applied6,
          invoice6 = p_invoice6,
          invoice6_installment = p_invoice6_installment,
          invoice6_status = p_invoice6_status,
          amount_applied7 = p_amount_applied7,
          invoice7 = p_invoice7,
          invoice7_installment = p_invoice7_installment,
          invoice7_status = p_invoice7_status,
          amount_applied8 = p_amount_applied8,
          invoice8 = p_invoice8,
          invoice8_installment = p_invoice8_installment,
          invoice8_status = p_invoice8_status,
          attribute1 = p_attribute1,
          attribute2 = p_attribute2,
          attribute3 = p_attribute3,
          attribute4 = p_attribute4,
          attribute5 = p_attribute5,
          attribute6 = p_attribute6,
          attribute7 = p_attribute7,
          attribute8 = p_attribute8,
          attribute9 = p_attribute9,
          attribute10 = p_attribute10,
          attribute11 = p_attribute11,
          attribute12 = p_attribute12,
          attribute13 = p_attribute13,
          attribute14 = p_attribute14,
          attribute15 = p_attribute15,
          status = p_status,
          matching1_date = p_matching1_date,
          matching2_date = p_matching2_date,
          matching3_date = p_matching3_date,
          matching4_date = p_matching4_date,
          matching5_date = p_matching5_date,
          matching6_date = p_matching6_date,
          matching7_date = p_matching7_date,
          matching8_date = p_matching8_date,
          amount_applied_from1 = p_amount_applied_from1,
          trans_to_receipt_rate1 = p_trans_to_receipt_rate1,
          invoice_currency_code1 = p_invoice_currency_code1,
          amount_applied_from2 = p_amount_applied_from2,
          trans_to_receipt_rate2 = p_trans_to_receipt_rate2,
          invoice_currency_code2= p_invoice_currency_code2,
          amount_applied_from3 = p_amount_applied_from3,
          trans_to_receipt_rate3 = p_trans_to_receipt_rate3,
          invoice_currency_code3= p_invoice_currency_code3,
          amount_applied_from4 = p_amount_applied_from4,
          trans_to_receipt_rate4 = p_trans_to_receipt_rate4,
          invoice_currency_code4= p_invoice_currency_code4,
          amount_applied_from5 = p_amount_applied_from5,
          trans_to_receipt_rate5 = p_trans_to_receipt_rate5,
          invoice_currency_code5= p_invoice_currency_code5,
          amount_applied_from6 = p_amount_applied_from6,
          trans_to_receipt_rate6 = p_trans_to_receipt_rate6,
          invoice_currency_code6= p_invoice_currency_code6,
          amount_applied_from7 = p_amount_applied_from7,
          trans_to_receipt_rate7 = p_trans_to_receipt_rate7,
          invoice_currency_code7= p_invoice_currency_code7,
          amount_applied_from8 = p_amount_applied_from8,
          trans_to_receipt_rate8 = p_trans_to_receipt_rate8,
          invoice_currency_code8= p_invoice_currency_code8,
          ussgl_transaction_code = p_ussgl_transaction_code,
          ussgl_transaction_code1 = p_ussgl_transaction_code1,
          ussgl_transaction_code2 = p_ussgl_transaction_code2,
          ussgl_transaction_code3 = p_ussgl_transaction_code3,
          ussgl_transaction_code4 = p_ussgl_transaction_code4,
          ussgl_transaction_code5 = p_ussgl_transaction_code5,
          ussgl_transaction_code6 = p_ussgl_transaction_code6,
          ussgl_transaction_code7 = p_ussgl_transaction_code7,
          ussgl_transaction_code8 = p_ussgl_transaction_code8
    WHERE transmission_record_id = p_transmission_record_id;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_lockbox_pkg.update_trans_data()-');
   END IF;
   --
   EXCEPTION
      WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('update_trans_data: ' ||
              'EXCEPTION: arp_lockbox_pkg.update_trans_data when '||
               l_break_point);
           END IF;
END update_trans_data;
--
--
--
PROCEDURE delete_trans_data(
		p_transmission_record_id	IN NUMBER ) IS
l_dummy	NUMBER;
l_break_point	VARCHAR2(30);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_lockbox_pkg.delete_trans_data()+');
   END IF;
   --
/*  Bugfix 2284014. Commented the foll. code that earlier
locked the record
   l_break_point := 'lock record';
   SELECT transmission_record_id
   INTO   l_dummy
   FROM   ar_payments_interface
   WHERE  transmission_record_id = p_transmission_record_id
   FOR UPDATE NOWAIT;        */
   --
   l_break_point := 'delete record';
   DELETE ar_payments_interface
   WHERE  transmission_record_id = p_transmission_record_id;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_lockbox_pkg.delete_trans_data()-');
   END IF;
   --
   EXCEPTION
      WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('delete_trans_data: ' ||
              'EXCEPTION: arp_lockbox_pkg.delete_trans_data when '||
               l_break_point);
           END IF;
END delete_trans_data;
--
--
--
FUNCTION get_batch_name(p_transmission_id number,
                        p_lockbox_number varchar2,
                        p_item_num number)
 RETURN varchar2 IS
  l_batch_name ar_payments_interface.batch_name%type;
BEGIN
  if (p_transmission_id is NULL) THEN
    return NULL;
  end if;
--
  if (p_lockbox_number is NOT NULL) THEN
    begin
      SELECT distinct(batch_name)
      INTO   l_batch_name
      FROM   ar_payments_interface
      WHERE  lockbox_number = p_lockbox_number
      AND    transmission_id = p_transmission_id
      AND    batch_name is NOT NULL;
      if (l_batch_name is NOT NULL) THEN
       return l_batch_name;
      end if;
    exception
        when no_data_found then NULL;
        when too_many_rows then return NULL;
        when others then raise;
    end;
  end if;
--
  if (p_item_num is NOT NULL) THEN
    begin
      SELECT distinct(batch_name)
      INTO   l_batch_name
      FROM   ar_payments_interface
      WHERE  item_number = p_item_num
      AND    transmission_id = p_transmission_id
      AND    batch_name is NOT NULL;
      if (l_batch_name is NOT NULL) THEN
       return l_batch_name;
      end if;
    exception
        when no_data_found then NULL;
        when too_many_rows then return NULL;
        when others then raise;
    end;
  end if;
--
-- if the execution has reached here, it means that it could not find the batch name.
-- retun null.
--
  return NULL;
--
END get_batch_name;
--
--
FUNCTION get_lb_num(p_transmission_id number,
                    p_batch_name varchar2,
                    p_item_num number)
  RETURN VARCHAR2 IS
  l_lockbox_number ar_payments_interface.lockbox_number%type;
BEGIN
  if (p_transmission_id is NULL) THEN
    return NULL;
  end if;
--
  if (p_batch_name is NOT NULL) THEN
    begin
      SELECT distinct(lockbox_number)
      INTO   l_lockbox_number
      FROM   ar_payments_interface
      WHERE  batch_name = p_batch_name
      AND    transmission_id = p_transmission_id
      AND    lockbox_number is NOT NULL;
      if (l_lockbox_number is NOT NULL) THEN
       return l_lockbox_number;
      end if;
    exception
        when no_data_found then NULL;
        when too_many_rows then return NULL;
        when others then raise;
    end;
  end if;
--
  if (p_item_num is NOT NULL) THEN
    begin
      SELECT distinct(lockbox_number)
      INTO   l_lockbox_number
      FROM   ar_payments_interface
      WHERE  item_number = p_item_num
      AND    transmission_id = p_transmission_id
      AND    lockbox_number is NOT NULL;
      if (l_lockbox_number is NOT NULL) THEN
       return l_lockbox_number;
      end if;
    exception
        when no_data_found then NULL;
        when too_many_rows then return NULL;
        when others then raise;
    end;
  end if;
--
-- if the execution has reached here, it means that it could not find the LB num
-- retun null.
--
  return NULL;
--
END get_lb_num;
--
END ARP_LOCKBOX_PKG;

/
