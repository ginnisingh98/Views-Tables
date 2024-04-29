--------------------------------------------------------
--  DDL for Package ARP_LOCKBOX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_LOCKBOX_PKG" AUTHID CURRENT_USER AS
/* $Header: ARLBPIMS.pls 120.2 2005/10/30 04:23:51 appldev ship $ */
--
/* Bugfix 2284014 */
PROCEDURE lock_trans_data(
                p_row_id                        IN VARCHAR2,
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
 );
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
		p_status			IN VARCHAR2,
                p_matching1_date		IN DATE,
                p_matching2_date		IN DATE,
                p_matching3_date		IN DATE,
                p_matching4_date		IN DATE,
                p_matching5_date		IN DATE,
                p_matching6_date		IN DATE,
                p_matching7_date		IN DATE,
                p_matching8_date		IN DATE,
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
 );
--
PROCEDURE delete_trans_data(
		p_transmission_record_id	IN NUMBER );
--
FUNCTION get_lb_num(p_transmission_id number,
                    p_batch_name varchar2,
                    p_item_num number)
  RETURN VARCHAR2;
--
FUNCTION get_batch_name(p_transmission_id number,
                        p_lockbox_number varchar2,
                        p_item_num number)
  RETURN VARCHAR2;
--
END ARP_LOCKBOX_PKG;

 

/