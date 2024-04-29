--------------------------------------------------------
--  DDL for Package ARP_PROCESS_CREDIT_UPD_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_CREDIT_UPD_COVER" AUTHID CURRENT_USER AS
/* $Header: ARTCCMUS.pls 115.5 2002/11/15 03:30:54 anukumar ship $ */

PROCEDURE update_header_cover(
  p_form_name                   IN varchar2,
  p_form_version                IN number,
  p_customer_trx_id             IN ra_customer_trx.customer_trx_id%type,
  p_trx_number                  IN ra_customer_trx.trx_number%type,
  p_batch_id                    IN ra_batches.batch_id%type,
  p_trx_date                    IN ra_customer_trx.trx_date%type,
  p_gl_date                     IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_complete_flag               IN ra_customer_trx.complete_flag%type,
  p_prev_customer_trx_id        IN ra_customer_trx.customer_trx_id%type,
  p_batch_source_id             IN ra_batch_sources.batch_source_id%type,
  p_cust_trx_type_id            IN ra_cust_trx_types.cust_trx_type_id%type,
  p_currency_code               IN fnd_currencies.currency_code%type,
  p_exchange_date               IN ra_customer_trx.exchange_date%type,
  p_exchange_rate_type          IN ra_customer_trx.exchange_rate_type%type,
  p_exchange_rate               IN ra_customer_trx.exchange_rate%type,
  p_invoicing_rule_id           IN ra_customer_trx.invoicing_rule_id%type,
  p_method_for_rules            IN
                           ra_customer_trx.credit_method_for_rules%type,
  p_split_term_method           IN
                           ra_customer_trx.credit_method_for_installments%type,
  p_initial_customer_trx_id     IN
                           ra_customer_trx.initial_customer_trx_id%type,
  p_primary_salesrep_id         IN ra_customer_trx.primary_salesrep_id%type,
  p_bill_to_customer_id         IN ra_customer_trx.bill_to_customer_id%type,
  p_bill_to_address_id          IN ra_customer_trx.bill_to_address_id%type,
  p_bill_to_site_use_id         IN ra_customer_trx.bill_to_site_use_id%type,
  p_bill_to_contact_id          IN ra_customer_trx.bill_to_contact_id%type,
  p_ship_to_customer_id         IN ra_customer_trx.ship_to_customer_id%type,
  p_ship_to_address_id          IN ra_customer_trx.ship_to_address_id%type,
  p_ship_to_site_use_id         IN ra_customer_trx.ship_to_site_use_id%type,
  p_ship_to_contact_id          IN ra_customer_trx.ship_to_contact_id%type,
  p_receipt_method_id           IN ra_customer_trx.receipt_method_id%type,
  p_paying_customer_id          IN ra_customer_trx.paying_customer_id%type,
  p_paying_site_use_id          IN ra_customer_trx.paying_site_use_id%type,
  p_customer_bank_account_id    IN
                            ra_customer_trx.customer_bank_account_id%type,
  p_printing_option             IN ra_customer_trx.printing_option%type,
  p_printing_last_printed       IN ra_customer_trx.printing_last_printed%type,
  p_printing_pending            IN ra_customer_trx.printing_pending%type,
  p_doc_sequence_value          IN ra_customer_trx.doc_sequence_value%type,
  p_doc_sequence_id             IN ra_customer_trx.doc_sequence_id%type,
  p_reason_code                 IN ra_customer_trx.reason_code%type,
  p_customer_reference          IN ra_customer_trx.customer_reference%type,
  p_customer_reference_date     IN
                           ra_customer_trx.customer_reference_date%type,
  p_internal_notes              IN ra_customer_trx.internal_notes%type,
  p_set_of_books_id             IN ra_customer_trx.set_of_books_id%type,
  p_created_from                IN ra_customer_trx.created_from%type,
  p_old_trx_number              IN ra_customer_trx.old_trx_number%type,
  p_attribute_category          IN ra_customer_trx.attribute_category%type,
  p_attribute1                  IN ra_customer_trx.attribute1%type,
  p_attribute2                  IN ra_customer_trx.attribute2%type,
  p_attribute3                  IN ra_customer_trx.attribute3%type,
  p_attribute4                  IN ra_customer_trx.attribute4%type,
  p_attribute5                  IN ra_customer_trx.attribute5%type,
  p_attribute6                  IN ra_customer_trx.attribute6%type,
  p_attribute7                  IN ra_customer_trx.attribute7%type,
  p_attribute8                  IN ra_customer_trx.attribute8%type,
  p_attribute9                  IN ra_customer_trx.attribute9%type,
  p_attribute10                 IN ra_customer_trx.attribute10%type,
  p_attribute11                 IN ra_customer_trx.attribute11%type,
  p_attribute12                 IN ra_customer_trx.attribute12%type,
  p_attribute13                 IN ra_customer_trx.attribute13%type,
  p_attribute14                 IN ra_customer_trx.attribute14%type,
  p_attribute15                 IN ra_customer_trx.attribute15%type,
  p_interface_header_context    IN
                        ra_customer_trx.interface_header_context%type,
  p_interface_header_attribute1 IN
                        ra_customer_trx.interface_header_attribute1%type,
  p_interface_header_attribute2 IN
                        ra_customer_trx.interface_header_attribute2%type,
  p_interface_header_attribute3 IN
                        ra_customer_trx.interface_header_attribute3%type,
  p_interface_header_attribute4 IN
                        ra_customer_trx.interface_header_attribute4%type,
  p_interface_header_attribute5 IN
                        ra_customer_trx.interface_header_attribute5%type,
  p_interface_header_attribute6 IN
                        ra_customer_trx.interface_header_attribute6%type,
  p_interface_header_attribute7 IN
                        ra_customer_trx.interface_header_attribute7%type,
  p_interface_header_attribute8 IN
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
  p_default_ussgl_trx_code IN
                     ra_customer_trx.default_ussgl_transaction_code%type,
  p_line_percent                IN number,
  p_freight_percent             IN number,
  p_line_amount                 IN ra_customer_trx_lines.extended_amount%type,
  p_freight_amount              IN ra_customer_trx_lines.extended_amount%type,
  p_credit_amount               IN ra_customer_trx_lines.extended_amount%type,
  p_cr_txn_invoicing_rule_id    IN ra_customer_trx.invoicing_rule_id%type,
  p_rederive_credit_info        IN varchar2,
  p_rerun_aa                    IN varchar2,
  p_rerun_cm_module             IN varchar2,
  p_compute_tax                 IN varchar2,
  p_comments                    IN ra_customer_trx.comments%type,
  p_tax_percent             IN OUT NOCOPY number,
  p_tax_amount              IN OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_status                     OUT NOCOPY varchar2);


END arp_process_credit_upd_cover;


 

/
