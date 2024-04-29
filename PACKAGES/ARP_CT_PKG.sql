--------------------------------------------------------
--  DDL for Package ARP_CT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CT_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTITRXS.pls 120.8 2006/01/24 22:34:48 mraymond ship $ */

PROCEDURE set_to_dummy( p_trx_rec OUT NOCOPY ra_customer_trx%rowtype);

PROCEDURE lock_p( p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type );

PROCEDURE lock_fetch_p( p_trx_rec         IN OUT NOCOPY ra_customer_trx%rowtype,
                        p_customer_trx_id IN
                                     ra_customer_trx.customer_trx_id%type );

PROCEDURE lock_compare_p( p_trx_rec          IN ra_customer_trx%rowtype,
                          p_customer_trx_id  IN
                                     ra_customer_trx.customer_trx_id%type);

PROCEDURE fetch_p( p_trx_rec         OUT NOCOPY ra_customer_trx%rowtype,
                   p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type);

procedure delete_p( p_customer_trx_id IN ra_customer_trx.customer_trx_id%type);

PROCEDURE update_p( p_trx_rec IN ra_customer_trx%rowtype,
                    p_customer_trx_id  IN
                                ra_customer_trx.customer_trx_id%type);

PROCEDURE update_p_print( p_trx_rec IN ra_customer_trx%rowtype,
                          p_customer_trx_id  IN
                                ra_customer_trx.customer_trx_id%type);

PROCEDURE update_tax( p_ship_to_site_use_id IN ra_customer_trx.ship_to_site_use_id%type,
		      p_bill_to_site_use_id IN ra_customer_trx.bill_to_site_use_id%type,
		      p_trx_date IN ra_customer_trx.trx_date%type,
		      p_cust_trx_type_id IN ra_customer_trx.cust_trx_type_id%type,
                      p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type,
                      P_TAX_AFFECT_FLAG in varchar2,
                      p_enforce_nat_acc_flag IN BOOLEAN);

PROCEDURE insert_p(
                    p_trx_rec          IN ra_customer_trx%rowtype,
                    p_trx_number      OUT NOCOPY ra_customer_trx.trx_number%type,
                    p_customer_trx_id OUT NOCOPY ra_customer_trx.customer_trx_id%type
                  );

PROCEDURE display_header_p(
            p_customer_trx_id IN ra_customer_trx.customer_trx_id%type);

PROCEDURE display_header_rec ( p_trx_rec IN ra_customer_trx%rowtype );

PROCEDURE lock_compare_frt_cover(
             p_customer_trx_id   IN ra_customer_trx.customer_trx_id%type,
             p_ship_via          IN ra_customer_trx.ship_via%type,
             p_ship_date_actual  IN ra_customer_trx.ship_date_actual%type,
             p_waybill_number    IN ra_customer_trx.waybill_number%type,
             p_fob_point         IN ra_customer_trx.fob_point%type);

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
  p_payment_trxn_extension_id      IN ra_customer_trx.payment_trxn_extension_id%type,
  p_billing_date                    IN ra_customer_trx.billing_date%type);


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
  p_billing_date                           IN ra_customer_trx.billing_date%type);



FUNCTION get_text_dummy(p_null IN NUMBER DEFAULT null) RETURN varchar2;

FUNCTION get_flag_dummy(p_null IN NUMBER DEFAULT null) RETURN varchar2;

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number;

FUNCTION get_date_dummy(p_null IN NUMBER DEFAULT null) RETURN date;


END ARP_CT_PKG;

 

/
