--------------------------------------------------------
--  DDL for Package ARP_PROCESS_HEADER_INSRT_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_HEADER_INSRT_COVER" AUTHID CURRENT_USER AS
/* $Header: ARTEHCIS.pls 120.5 2006/07/26 10:53:11 rkader ship $ */


PROCEDURE insert_header_cover(
  p_form_name                           IN varchar2,
  p_form_version                        IN number,
  p_trx_class                           IN VARCHAR2,
  p_gl_date                             IN DATE,
  p_term_in_use_flag                    IN varchar2,
  p_receivable_ccid                     IN NUMBER,
  p_customer_trx_id                     IN NUMBER,
  p_trx_number                          IN VARCHAR2,
  p_posting_control_id                  IN NUMBER,
  p_complete_flag                       IN VARCHAR2,
  p_initial_customer_trx_id             IN NUMBER,
  p_previous_customer_trx_id            IN NUMBER,
  p_related_customer_trx_id             IN NUMBER,
  p_recurred_from_trx_number            IN VARCHAR2,
  p_cust_trx_type_id                    IN NUMBER,
  p_batch_id                            IN NUMBER,
  p_batch_source_id                     IN NUMBER,
  p_agreement_id                        IN NUMBER,
  p_trx_date                            IN DATE,
  p_bill_to_customer_id                 IN NUMBER,
  p_bill_to_contact_id                  IN NUMBER,
  p_bill_to_site_use_id                 IN NUMBER,
  p_ship_to_customer_id                 IN NUMBER,
  p_ship_to_contact_id                  IN NUMBER,
  p_ship_to_site_use_id                 IN NUMBER,
  p_sold_to_customer_id                 IN NUMBER,
  p_sold_to_site_use_id                 IN NUMBER,
  p_sold_to_contact_id                  IN NUMBER,
  p_customer_reference                  IN VARCHAR2,
  p_customer_reference_date             IN DATE,
  p_cr_method_for_installments          IN VARCHAR2,
  p_credit_method_for_rules             IN VARCHAR2,
  p_start_date_commitment               IN DATE,
  p_end_date_commitment                 IN DATE,
  p_exchange_date                       IN DATE,
  p_exchange_rate                       IN NUMBER,
  p_exchange_rate_type                  IN VARCHAR2,
  p_customer_bank_account_id            IN NUMBER,
  p_finance_charges                     IN VARCHAR2,
  p_fob_point                           IN VARCHAR2,
  p_comments                            IN VARCHAR2,
  p_internal_notes                      IN VARCHAR2,
  p_invoice_currency_code               IN VARCHAR2,
  p_invoicing_rule_id                   IN NUMBER,
  p_last_printed_sequence_num           IN NUMBER,
  p_orig_system_batch_name              IN VARCHAR2,
  p_primary_salesrep_id                 IN NUMBER,
  p_printing_count                      IN NUMBER,
  p_printing_last_printed               IN DATE,
  p_printing_option                     IN VARCHAR2,
  p_printing_original_date              IN DATE,
  p_printing_pending                    IN VARCHAR2,
  p_purchase_order                      IN VARCHAR2,
  p_purchase_order_date                 IN DATE,
  p_purchase_order_revision             IN VARCHAR2,
  p_receipt_method_id                   IN NUMBER,
  p_remit_to_address_id                 IN NUMBER,
  p_shipment_id                         IN NUMBER,
  p_ship_date_actual                    IN DATE,
  p_ship_via                            IN VARCHAR2,
  p_term_due_date                       IN DATE,
  p_term_id                             IN NUMBER,
  p_territory_id                        IN NUMBER,
  p_waybill_number                      IN VARCHAR2,
  p_status_trx                          IN VARCHAR2,
  p_reason_code                         IN VARCHAR2,
  p_doc_sequence_id                     IN NUMBER,
  p_doc_sequence_value                  IN NUMBER,
  p_paying_customer_id                  IN NUMBER,
  p_paying_site_use_id                  IN NUMBER,
  p_related_batch_source_id             IN NUMBER,
  p_default_tax_exempt_flag             IN VARCHAR2,
  p_created_from                        IN VARCHAR2,
  p_deflt_ussgl_transaction_code        IN VARCHAR2,
  p_old_trx_number                      IN VARCHAR2,
  p_interface_header_context            IN VARCHAR2,
  p_interface_header_attribute1         IN VARCHAR2,
  p_interface_header_attribute2         IN VARCHAR2,
  p_interface_header_attribute3         IN VARCHAR2,
  p_interface_header_attribute4         IN VARCHAR2,
  p_interface_header_attribute5         IN VARCHAR2,
  p_interface_header_attribute6         IN VARCHAR2,
  p_interface_header_attribute7         IN VARCHAR2,
  p_interface_header_attribute8         IN VARCHAR2,
  p_interface_header_attribute9         IN VARCHAR2,
  p_interface_header_attribute10        IN VARCHAR2,
  p_interface_header_attribute11        IN VARCHAR2,
  p_interface_header_attribute12        IN VARCHAR2,
  p_interface_header_attribute13        IN VARCHAR2,
  p_interface_header_attribute14        IN VARCHAR2,
  p_interface_header_attribute15        IN VARCHAR2,
  p_attribute_category                  IN VARCHAR2,
  p_attribute1                          IN VARCHAR2,
  p_attribute2                          IN VARCHAR2,
  p_attribute3                          IN VARCHAR2,
  p_attribute4                          IN VARCHAR2,
  p_attribute5                          IN VARCHAR2,
  p_attribute6                          IN VARCHAR2,
  p_attribute7                          IN VARCHAR2,
  p_attribute8                          IN VARCHAR2,
  p_attribute9                          IN VARCHAR2,
  p_attribute10                         IN VARCHAR2,
  p_attribute11                         IN VARCHAR2,
  p_attribute12                         IN VARCHAR2,
  p_attribute13                         IN VARCHAR2,
  p_attribute14                         IN VARCHAR2,
  p_attribute15                         IN VARCHAR2,
  p_commit_customer_trx_line_id         IN NUMBER,
  p_commit_inventory_item_id            IN NUMBER,
  p_commit_memo_line_id	    		IN NUMBER,
  p_commit_description                  IN VARCHAR2,
  p_commit_extended_amount              IN NUMBER,
  p_commit_interface_line_attr1         IN VARCHAR2,
  p_commit_interface_line_attr2         IN VARCHAR2,
  p_commit_interface_line_attr3         IN VARCHAR2,
  p_commit_interface_line_attr4         IN VARCHAR2,
  p_commit_interface_line_attr5         IN VARCHAR2,
  p_commit_interface_line_attr6         IN VARCHAR2,
  p_commit_interface_line_attr7         IN VARCHAR2,
  p_commit_interface_line_attr8         IN VARCHAR2,
  p_commit_interface_line_attr9         IN VARCHAR2,
  p_commit_interface_line_attr10        IN VARCHAR2,
  p_commit_interface_line_attr11        IN VARCHAR2,
  p_commit_interface_line_attr12        IN VARCHAR2,
  p_commit_interface_line_attr13        IN VARCHAR2,
  p_commit_interface_line_attr14        IN VARCHAR2,
  p_commit_interface_line_attr15        IN VARCHAR2,
  p_commit_interface_line_contxt        IN VARCHAR2,
  p_commit_attribute_category           IN VARCHAR2,
  p_commit_attribute1                   IN VARCHAR2,
  p_commit_attribute2                   IN VARCHAR2,
  p_commit_attribute3                   IN VARCHAR2,
  p_commit_attribute4                   IN VARCHAR2,
  p_commit_attribute5                   IN VARCHAR2,
  p_commit_attribute6                   IN VARCHAR2,
  p_commit_attribute7                   IN VARCHAR2,
  p_commit_attribute8                   IN VARCHAR2,
  p_commit_attribute9                   IN VARCHAR2,
  p_commit_attribute10                  IN VARCHAR2,
  p_commit_attribute11                  IN VARCHAR2,
  p_commit_attribute12                  IN VARCHAR2,
  p_commit_attribute13                  IN VARCHAR2,
  p_commit_attribute14                  IN VARCHAR2,
  p_commit_attribute15                  IN VARCHAR2,
  p_ctl_default_ussgl_trx_code          IN VARCHAR2,
  p_new_trx_number                      OUT NOCOPY VARCHAR2,
  p_new_customer_trx_id                 OUT NOCOPY NUMBER,
  p_new_customer_trx_line_id            OUT NOCOPY NUMBER,
  p_new_row_id                          OUT NOCOPY varchar2,
  p_status                              OUT NOCOPY varchar2,
  p_legal_entity_id                     IN  NUMBER default NULL,
  p_payment_trxn_extension_id           IN  NUMBER default NULL,   /* PAYMENT_UPTAKE */
  p_billing_date                        IN  DATE   default NULL, /* R12:BFB */
  p_ct_reference                        IN  VARCHAR2 default NULL); /* Bug fix 5220712 */


END ARP_PROCESS_HEADER_INSRT_COVER;

 

/