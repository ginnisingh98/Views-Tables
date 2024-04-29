--------------------------------------------------------
--  DDL for Package ARP_PROCESS_CHARGEBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_CHARGEBACK" AUTHID CURRENT_USER AS
/* $Header: ARCECBS.pls 120.6 2005/07/29 10:06:34 mantani ship $*/

FUNCTION revision RETURN VARCHAR2;

PROCEDURE reverse_chargeback(
			p_cb_ct_id IN ra_customer_trx.customer_trx_id%TYPE,
                        p_reversal_gl_date IN DATE,
                        p_reversal_date IN DATE,
                        p_module_name IN VARCHAR2,
                        p_module_version IN VARCHAR2,
                        p_type           IN VARCHAR2 DEFAULT 'TRANSACTION');
--
FUNCTION validate_cb_reversal (
                p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_ass_cr_id IN ar_adjustments.associated_cash_receipt_id%TYPE,
                p_ct_count  IN NUMBER, p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 ) RETURN BOOLEAN;
--
FUNCTION validate_cb_reversal ( p_ct_id IN ra_customer_trx.customer_trx_id%TYPE,
                                p_module_name IN VARCHAR2,
                                p_module_version IN VARCHAR2 ) RETURN BOOLEAN;

procedure create_chargeback(
  p_amount			IN NUMBER
, p_acctd_amount		IN NUMBER
, p_trx_date			IN DATE
, p_gl_id_ar_trade		IN NUMBER
, p_gl_date			IN DATE
, p_attribute_category		IN VARCHAR2
, p_attribute1			IN VARCHAR2
, p_attribute2			IN VARCHAR2
, p_attribute3			IN VARCHAR2
, p_attribute4			IN VARCHAR2
, p_attribute5			IN VARCHAR2
, p_attribute6			IN VARCHAR2
, p_attribute7			IN VARCHAR2
, p_attribute8			IN VARCHAR2
, p_attribute9 			IN VARCHAR2
, p_attribute10 		IN VARCHAR2
, p_attribute11 		IN VARCHAR2
, p_attribute12 		IN VARCHAR2
, p_attribute13 		IN VARCHAR2
, p_attribute14 		IN VARCHAR2
, p_attribute15 		IN VARCHAR2
, p_cust_trx_type_id 		IN NUMBER
, p_set_of_books_id 		IN NUMBER
, p_reason_code 		IN VARCHAR2
, p_comments 			IN VARCHAR2
, p_def_ussgl_trx_code_context	IN VARCHAR2
, p_def_ussgl_transaction_code	IN VARCHAR2
-- For AR_PAYMENT_SCHEDULES
, p_due_date			IN DATE
, p_customer_id			IN NUMBER
, p_cr_trx_number		IN VARCHAR2
, p_cash_receipt_id		IN NUMBER
, p_inv_trx_number		IN VARCHAR2
, p_apply_date			IN DATE
, p_receipt_gl_date		IN DATE
-- We get rest of the TRX info with this ID
, p_app_customer_trx_id		IN NUMBER
, p_app_terms_sequence_number	IN NUMBER
, p_form_name			IN VARCHAR2
, p_out_trx_number		OUT NOCOPY VARCHAR2
, p_out_customer_trx_id		OUT NOCOPY NUMBER
, p_doc_sequence_value		IN OUT NOCOPY NUMBER
, p_doc_sequence_id		IN OUT NOCOPY NUMBER
, p_exchange_rate_type          IN VARCHAR2
, p_exchange_date               IN DATE
, p_exchange_rate               IN NUMBER
, p_currency_code               IN VARCHAR2
, p_remit_to_address_id         IN NUMBER DEFAULT 0
, p_bill_to_site_use_id         IN NUMBER DEFAULT 0
, p_interface_header_context            IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute1         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute2         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute3         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute4         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute5         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute6         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute7         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute8         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute9         IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute10        IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute11        IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute12        IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute13        IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute14        IN VARCHAR2 DEFAULT NULL
, p_interface_header_attribute15        IN VARCHAR2 DEFAULT NULL
, p_internal_notes                      IN VARCHAR2 DEFAULT NULL
, p_customer_reference                  IN VARCHAR2 DEFAULT NULL
, p_legal_entity_id                     IN NUMBER   DEFAULT NULL
);

PROCEDURE update_chargeback (
	  p_customer_trx_id			IN NUMBER
	, p_comments				IN VARCHAR2
	, p_DEFAULT_USSGL_TRX_CODE		IN VARCHAR2
	, p_reason_code				IN VARCHAR2
	, p_ATTRIBUTE_CATEGORY			IN VARCHAR2
	, p_attribute1				IN VARCHAR2
	, p_attribute2				IN VARCHAR2
	, p_attribute3				IN VARCHAR2
	, p_attribute4				IN VARCHAR2
	, p_attribute5				IN VARCHAR2
	, p_attribute6				IN VARCHAR2
	, p_attribute7				IN VARCHAR2
	, p_attribute8				IN VARCHAR2
	, p_attribute9				IN VARCHAR2
	, p_attribute10				IN VARCHAR2
	, p_attribute11				IN VARCHAR2
	, p_attribute12				IN VARCHAR2
	, p_attribute13				IN VARCHAR2
	, p_attribute14				IN VARCHAR2
	, p_attribute15				IN VARCHAR2
);

PROCEDURE delete_chargeback (
	  p_customer_trx_id	IN NUMBER
	, p_apply_date		IN DATE
	, p_gl_date		IN DATE
	, p_module_name		IN VARCHAR2
	, p_module_version	IN VARCHAR2
        , p_type                IN VARCHAR2 DEFAULT 'TRANSACTION');

END ARP_PROCESS_CHARGEBACK;

 

/
