--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_HEADER_INSRT_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_HEADER_INSRT_COVER" AS
/* $Header: ARTEHCIB.pls 120.7 2006/07/26 10:53:48 rkader ship $ */


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_header_cover                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ra_customer_trx.                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_process_header.insert_header                                       |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_trx_class                                            |
 |                    p_gl_date                                              |
 |                    p_term_in_use_flag                                     |
 |                    p_receivable_ccid                                      |
 |                    p_customer_trx_id                                      |
 |                    p_trx_number                                           |
 |                    p_posting_control_id                                   |
 |                    p_complete_flag                                        |
 |                    p_initial_customer_trx_id                              |
 |                    p_previous_customer_trx_id                             |
 |                    p_related_customer_trx_id                              |
 |                    p_recurred_from_trx_number                             |
 |                    p_cust_trx_type_id                                     |
 |                    p_batch_id                                             |
 |                    p_batch_source_id                                      |
 |                    p_agreement_id                                         |
 |                    p_trx_date                                             |
 |                    p_bill_to_customer_id                                  |
 |                    p_bill_to_contact_id                                   |
 |                    p_bill_to_site_use_id                                  |
 |                    p_ship_to_customer_id                                  |
 |                    p_ship_to_contact_id                                   |
 |                    p_ship_to_site_use_id                                  |
 |                    p_sold_to_customer_id                                  |
 |                    p_sold_to_site_use_id                                  |
 |                    p_sold_to_contact_id                                   |
 |                    p_customer_reference                                   |
 |                    p_customer_reference_date                              |
 |                    p_cr_method_for_installments                           |
 |                    p_credit_method_for_rules                              |
 |                    p_start_date_commitment                                |
 |                    p_end_date_commitment                                  |
 |                    p_exchange_date                                        |
 |                    p_exchange_rate                                        |
 |                    p_exchange_rate_type                                   |
 |                    p_customer_bank_account_id                             |
 |                    p_finance_charges                                      |
 |                    p_fob_point                                            |
 |                    p_comments                                             |
 |                    p_internal_notes                                       |
 |                    p_invoice_currency_code                                |
 |                    p_invoicing_rule_id                                    |
 |                    p_last_printed_sequence_num                            |
 |                    p_orig_system_batch_name                               |
 |                    p_primary_salesrep_id                                  |
 |                    p_printing_count                                       |
 |                    p_printing_last_printed                                |
 |                    p_printing_option                                      |
 |                    p_printing_original_date                               |
 |                    p_printing_pending                                     |
 |                    p_purchase_order                                       |
 |                    p_purchase_order_date                                  |
 |                    p_purchase_order_revision                              |
 |                    p_receipt_method_id                                    |
 |                    p_remit_to_address_id                                  |
 |                    p_shipment_id                                          |
 |                    p_ship_date_actual                                     |
 |                    p_ship_via                                             |
 |                    p_term_due_date                                        |
 |                    p_term_id                                              |
 |                    p_territory_id                                         |
 |                    p_waybill_number                                       |
 |                    p_status_trx                                           |
 |                    p_reason_code                                          |
 |                    p_doc_sequence_id                                      |
 |                    p_doc_sequence_value                                   |
 |                    p_paying_customer_id                                   |
 |                    p_paying_site_use_id                                   |
 |                    p_related_batch_source_id                              |
 |                    p_default_tax_exempt_flag                              |
 |                    p_created_from                                         |
 |                    p_deflt_ussgl_transaction_code                         |
 |                    p_old_trx_number                                       |
 |                    p_interface_header_context                             |
 |                    p_interface_header_attribute1                          |
 |                    p_interface_header_attribute2                          |
 |                    p_interface_header_attribute3                          |
 |                    p_interface_header_attribute4                          |
 |                    p_interface_header_attribute5                          |
 |                    p_interface_header_attribute6                          |
 |                    p_interface_header_attribute7                          |
 |                    p_interface_header_attribute8                          |
 |                    p_interface_header_attribute9                          |
 |                    p_interface_header_attribute10                         |
 |                    p_interface_header_attribute11                         |
 |                    p_interface_header_attribute12                         |
 |                    p_interface_header_attribute13                         |
 |                    p_interface_header_attribute14                         |
 |                    p_interface_header_attribute15                         |
 |                    p_attribute_category                                   |
 |                    p_attribute1                                           |
 |                    p_attribute2                                           |
 |                    p_attribute3                                           |
 |                    p_attribute4                                           |
 |                    p_attribute5                                           |
 |                    p_attribute6                                           |
 |                    p_attribute7                                           |
 |                    p_attribute8                                           |
 |                    p_attribute9                                           |
 |                    p_attribute10                                          |
 |                    p_attribute11                                          |
 |                    p_attribute12                                          |
 |                    p_attribute13                                          |
 |                    p_attribute14                                          |
 |                    p_attribute15                                          |
 |                    p_commit_customer_trx_line_id                          |
 |                    p_commit_inventory_item_id                             |
 |                    p_commit_memo_line_id                                  |
 |                    p_commit_description                                   |
 |                    p_commit_extended_amount                               |
 |                    p_commit_interface_line_attr1                          |
 |                    p_commit_interface_line_attr2                          |
 |                    p_commit_interface_line_attr3                          |
 |                    p_commit_interface_line_attr4                          |
 |                    p_commit_interface_line_attr5                          |
 |                    p_commit_interface_line_attr6                          |
 |                    p_commit_interface_line_attr7                          |
 |                    p_commit_interface_line_attr8                          |
 |                    p_commit_interface_line_attr9                          |
 |                    p_commit_interface_line_attr10                         |
 |                    p_commit_interface_line_attr11                         |
 |                    p_commit_interface_line_attr12                         |
 |                    p_commit_interface_line_attr13                         |
 |                    p_commit_interface_line_attr14                         |
 |                    p_commit_interface_line_attr15                         |
 |                    p_commit_interface_line_contxt                         |
 |                    p_commit_attribute_category                            |
 |                    p_commit_attribute1                                    |
 |                    p_commit_attribute2                                    |
 |                    p_commit_attribute3                                    |
 |                    p_commit_attribute4                                    |
 |                    p_commit_attribute5                                    |
 |                    p_commit_attribute6                                    |
 |                    p_commit_attribute7                                    |
 |                    p_commit_attribute8                                    |
 |                    p_commit_attribute9                                    |
 |                    p_commit_attribute10                                   |
 |                    p_commit_attribute11                                   |
 |                    p_commit_attribute12                                   |
 |                    p_commit_attribute13                                   |
 |                    p_commit_attribute14                                   |
 |                    p_commit_attribute15                                   |
 |                    p_ctl_default_ussgl_trx_code                           |
 |                    p_ct_reference                                         |
 |              OUT:                                                         |
 |                    p_new_trx_number                                       |
 |                    p_new_customer_trx_id                                  |
 |                    p_new_customer_trx_line_id                             |
 |                    p_new_row_id                                           |
 |                    p_status                                               |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-NOV-95  Charlie Tomberg      Created                               |
 |     18-May-05  Debbie Jancis        Modified to include Legal Entity Id   |
 |     07-Aug-05  Surendra Rajan       Added Payment_trxn_extension_id       |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

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
  p_commit_memo_line_id			IN NUMBER,
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
  p_new_trx_number                     OUT NOCOPY VARCHAR2,
  p_new_customer_trx_id                OUT NOCOPY NUMBER,
  p_new_customer_trx_line_id           OUT NOCOPY NUMBER,
  p_new_row_id                         OUT NOCOPY varchar2,
  p_status                             OUT NOCOPY varchar2,
  p_legal_entity_id                     IN NUMBER DEFAULT NULL,
  p_payment_trxn_extension_id           IN NUMBER DEFAULT NULL, /* PAYMENT_UPTAKE */
  p_billing_date                        IN DATE   DEFAULT NULL, /* R12:BFB */
  p_ct_reference                        IN VARCHAR2   DEFAULT NULL) /* Bug fix 5330712 */
                 IS

  l_commit_rec   arp_process_commitment.commitment_rec_type;
  l_trx_rec      ra_customer_trx%rowtype;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_header_insrt_cover.insert_header_cover()+');
   END IF;

   l_trx_rec.customer_trx_id                := p_customer_trx_id;
   l_trx_rec.trx_number                     := p_trx_number;
   l_trx_rec.posting_control_id             := p_posting_control_id;
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
   l_trx_rec.printing_pending               := p_printing_pending;
   l_trx_rec.purchase_order                 := p_purchase_order;
   l_trx_rec.purchase_order_date            := p_purchase_order_date;
   l_trx_rec.purchase_order_revision        := p_purchase_order_revision;
   l_trx_rec.receipt_method_id              := p_receipt_method_id;
   l_trx_rec.remit_to_address_id            := p_remit_to_address_id;
   l_trx_rec.shipment_id                    := p_shipment_id;
   l_trx_rec.ship_date_actual               := p_ship_date_actual;
   l_trx_rec.ship_via                       := p_ship_via;
   l_trx_rec.term_due_date                  := p_term_due_date;
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

   l_commit_rec.customer_trx_line_id        := p_commit_customer_trx_line_id;
   l_commit_rec.inventory_item_id           := p_commit_inventory_item_id;
   l_commit_rec.memo_line_id		    := p_commit_memo_line_id;
   l_commit_rec.description                 := p_commit_description;
   l_commit_rec.extended_amount             := p_commit_extended_amount;
   l_commit_rec.interface_line_attribute1   := p_commit_interface_line_attr1;
   l_commit_rec.interface_line_attribute2   := p_commit_interface_line_attr2;
   l_commit_rec.interface_line_attribute3   := p_commit_interface_line_attr3;
   l_commit_rec.interface_line_attribute4   := p_commit_interface_line_attr4;
   l_commit_rec.interface_line_attribute5   := p_commit_interface_line_attr5;
   l_commit_rec.interface_line_attribute6   := p_commit_interface_line_attr6;
   l_commit_rec.interface_line_attribute7   := p_commit_interface_line_attr7;
   l_commit_rec.interface_line_attribute8   := p_commit_interface_line_attr8;
   l_commit_rec.interface_line_attribute9   := p_commit_interface_line_attr9;
   l_commit_rec.interface_line_attribute10  := p_commit_interface_line_attr10;
   l_commit_rec.interface_line_attribute11  := p_commit_interface_line_attr11;
   l_commit_rec.interface_line_attribute12  := p_commit_interface_line_attr12;
   l_commit_rec.interface_line_attribute13  := p_commit_interface_line_attr13;
   l_commit_rec.interface_line_attribute14  := p_commit_interface_line_attr14;
   l_commit_rec.interface_line_attribute15  := p_commit_interface_line_attr15;
   l_commit_rec.interface_line_context      := p_commit_interface_line_contxt;
   l_commit_rec.attribute_category          := p_commit_attribute_category;
   l_commit_rec.attribute1                  := p_commit_attribute1;
   l_commit_rec.attribute2                  := p_commit_attribute2;
   l_commit_rec.attribute3                  := p_commit_attribute3;
   l_commit_rec.attribute4                  := p_commit_attribute4;
   l_commit_rec.attribute5                  := p_commit_attribute5;
   l_commit_rec.attribute6                  := p_commit_attribute6;
   l_commit_rec.attribute7                  := p_commit_attribute7;
   l_commit_rec.attribute8                  := p_commit_attribute8;
   l_commit_rec.attribute9                  := p_commit_attribute9;
   l_commit_rec.attribute10                 := p_commit_attribute10;
   l_commit_rec.attribute11                 := p_commit_attribute11;
   l_commit_rec.attribute12                 := p_commit_attribute12;
   l_commit_rec.attribute13                 := p_commit_attribute13;
   l_commit_rec.attribute14                 := p_commit_attribute14;
   l_commit_rec.attribute15                 := p_commit_attribute15;
   l_commit_rec.default_ussgl_transaction_code := p_ctl_default_ussgl_trx_code;

   /*  Legal Entity Project */
   l_trx_rec.legal_entity_id                := p_legal_entity_id;
   /* PAYMENT_UPTAKE */
   l_trx_rec.payment_trxn_extension_id      := p_payment_trxn_extension_id;
   l_trx_rec.billing_date                   := p_billing_date;  /* R12:BFB */
   l_trx_rec.ct_reference		    := p_ct_reference; /* bug fix 5330712 */

/*
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('insert_header_cover: ' || 'p_customer_trx_id               = ' ||
                  TO_CHAR(p_customer_trx_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_trx_number                    = ' ||
                  p_trx_number );
      arp_util.debug('insert_header_cover: ' || 'p_posting_control_id            = ' ||
                  TO_CHAR(p_posting_control_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_complete_flag                 = ' ||
                  p_complete_flag );
      arp_util.debug('insert_header_cover: ' || 'p_initial_customer_trx_id       = ' ||
                  TO_CHAR(p_initial_customer_trx_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_previous_customer_trx_id      = ' ||
                  TO_CHAR(p_previous_customer_trx_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_related_customer_trx_id       = ' ||
                  TO_CHAR(p_related_customer_trx_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_recurred_from_trx_number      = ' ||
                  p_recurred_from_trx_number );
      arp_util.debug('insert_header_cover: ' || 'p_cust_trx_type_id              = ' ||
                  TO_CHAR(p_cust_trx_type_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_batch_id                      = ' ||
                  TO_CHAR(p_batch_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_batch_source_id               = ' ||
                  TO_CHAR(p_batch_source_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_agreement_id                  = ' ||
                  TO_CHAR(p_agreement_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_trx_date                      = ' ||
                  p_trx_date );
      arp_util.debug('insert_header_cover: ' || 'p_bill_to_customer_id           = ' ||
                  TO_CHAR(p_bill_to_customer_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_bill_to_contact_id            = ' ||
                  TO_CHAR(p_bill_to_contact_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_bill_to_site_use_id           = ' ||
                  TO_CHAR(p_bill_to_site_use_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_ship_to_customer_id           = ' ||
                  TO_CHAR(p_ship_to_customer_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_ship_to_contact_id            = ' ||
                  TO_CHAR(p_ship_to_contact_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_ship_to_site_use_id           = ' ||
                  TO_CHAR(p_ship_to_site_use_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_sold_to_customer_id           = ' ||
                  TO_CHAR(p_sold_to_customer_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_sold_to_site_use_id           = ' ||
                  TO_CHAR(p_sold_to_site_use_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_sold_to_contact_id            = ' ||
                  TO_CHAR(p_sold_to_contact_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_customer_reference            = ' ||
                  p_customer_reference );
      arp_util.debug('insert_header_cover: ' || 'p_customer_reference_date       = ' ||
                  p_customer_reference_date );
      arp_util.debug('insert_header_cover: ' || 'p_cr_method_for_installments    = ' ||
                  p_cr_method_for_installments );
      arp_util.debug('insert_header_cover: ' || 'p_credit_method_for_rules       = ' ||
                  p_credit_method_for_rules );
      arp_util.debug('insert_header_cover: ' || 'p_start_date_commitment         = ' ||
                  p_start_date_commitment );
      arp_util.debug('insert_header_cover: ' || 'p_end_date_commitment           = ' ||
                  p_end_date_commitment );
      arp_util.debug('insert_header_cover: ' || 'p_exchange_date                 = ' ||
                  p_exchange_date );
      arp_util.debug('insert_header_cover: ' || 'p_exchange_rate                 = ' ||
                  p_exchange_rate );
      arp_util.debug('insert_header_cover: ' || 'p_exchange_rate_type            = ' ||
                  p_exchange_rate_type );
      arp_util.debug('insert_header_cover: ' || 'p_customer_bank_account_id      = ' ||
                  p_customer_bank_account_id );
      arp_util.debug('insert_header_cover: ' || 'p_finance_charges               = ' ||
                  p_finance_charges );
      arp_util.debug('insert_header_cover: ' || 'p_fob_point                     = ' ||
                  p_fob_point );
      arp_util.debug('insert_header_cover: ' || 'p_comments                      = ' ||
                  p_comments );
      arp_util.debug('insert_header_cover: ' || 'p_internal_notes                = ' ||
                  p_internal_notes );
      arp_util.debug('insert_header_cover: ' || 'p_invoice_currency_code         = ' ||
                  p_invoice_currency_code );
      arp_util.debug('insert_header_cover: ' || 'p_invoicing_rule_id             = ' ||
                  TO_CHAR(p_invoicing_rule_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_last_printed_sequence_num     = ' ||
                  p_last_printed_sequence_num );
      arp_util.debug('insert_header_cover: ' || 'p_orig_system_batch_name        = ' ||
                  p_orig_system_batch_name );
      arp_util.debug('insert_header_cover: ' || 'p_primary_salesrep_id           = ' ||
                  TO_CHAR(p_primary_salesrep_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_printing_count                = ' ||
                  p_printing_count );
      arp_util.debug('insert_header_cover: ' || 'p_printing_last_printed         = ' ||
                  p_printing_last_printed );
      arp_util.debug('insert_header_cover: ' || 'p_printing_option               = ' ||
                  p_printing_option );
      arp_util.debug('insert_header_cover: ' || 'p_printing_original_date        = ' ||
                  p_printing_original_date );
      arp_util.debug('insert_header_cover: ' || 'p_printing_pending              = ' ||
                  p_printing_pending );
      arp_util.debug('insert_header_cover: ' || 'p_purchase_order                = ' ||
                  p_purchase_order );
      arp_util.debug('insert_header_cover: ' || 'p_purchase_order_date           = ' ||
                  p_purchase_order_date );
      arp_util.debug('insert_header_cover: ' || 'p_purchase_order_revision       = ' ||
                  p_purchase_order_revision );
      arp_util.debug('insert_header_cover: ' || 'p_receipt_method_id             = ' ||
                  TO_CHAR(p_receipt_method_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_remit_to_address_id           = ' ||
                  TO_CHAR(p_remit_to_address_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_shipment_id                   = ' ||
                  TO_CHAR(p_shipment_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_ship_date_actual              = ' ||
                  p_ship_date_actual );
      arp_util.debug('insert_header_cover: ' || 'p_ship_via                      = ' ||
                  p_ship_via );
      arp_util.debug('insert_header_cover: ' || 'p_term_due_date                 = ' ||
                  p_term_due_date );
      arp_util.debug('insert_header_cover: ' || 'p_term_id                       = ' ||
                  TO_CHAR(p_term_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_territory_id                  = ' ||
                  p_territory_id );
      arp_util.debug('insert_header_cover: ' || 'p_waybill_number                = ' ||
                  p_waybill_number );
      arp_util.debug('insert_header_cover: ' || 'p_status_trx                    = ' ||
                  p_status_trx );
      arp_util.debug('insert_header_cover: ' || 'p_reason_code                   = ' ||
                  p_reason_code );
      arp_util.debug('insert_header_cover: ' || 'p_doc_sequence_id               = ' ||
                  p_doc_sequence_id );
      arp_util.debug('insert_header_cover: ' || 'p_doc_sequence_value            = ' ||
                  p_doc_sequence_value );
      arp_util.debug('insert_header_cover: ' || 'p_paying_customer_id            = ' ||
                  TO_CHAR(p_paying_customer_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_paying_site_use_id            = ' ||
                  TO_CHAR(p_paying_site_use_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_related_batch_source_id       = ' ||
                  p_related_batch_source_id );
      arp_util.debug('insert_header_cover: ' || 'p_default_tax_exempt_flag       = ' ||
                  p_default_tax_exempt_flag );
      arp_util.debug('insert_header_cover: ' || 'p_created_from                  = ' ||
                  p_created_from );
      arp_util.debug('insert_header_cover: ' || 'p_deflt_ussgl_transaction_code  = ' ||
                  p_deflt_ussgl_transaction_code );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_context      = ' ||
                  p_interface_header_context );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute1   = ' ||
                  p_interface_header_attribute1 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute2   = ' ||
                  p_interface_header_attribute2 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute3   = ' ||
                  p_interface_header_attribute3 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute4   = ' ||
                  p_interface_header_attribute4 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute5   = ' ||
                  p_interface_header_attribute5 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute6   = ' ||
                  p_interface_header_attribute6 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute7   = ' ||
                  p_interface_header_attribute7 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute8   = ' ||
                  p_interface_header_attribute8 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute9   = ' ||
                  p_interface_header_attribute9 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute10  = ' ||
                  p_interface_header_attribute10 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute11  = ' ||
                  p_interface_header_attribute11 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute12  = ' ||
                  p_interface_header_attribute12 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute13  = ' ||
                  p_interface_header_attribute13 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute14  = ' ||
                  p_interface_header_attribute14 );
      arp_util.debug('insert_header_cover: ' || 'p_interface_header_attribute15  = ' ||
                  p_interface_header_attribute15 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute_category            = ' ||
                  p_attribute_category );
      arp_util.debug('insert_header_cover: ' || 'p_attribute1                    = ' ||
                  p_attribute1 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute2                    = ' ||
                  p_attribute2 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute3                    = ' ||
                  p_attribute3 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute4                    = ' ||
                  p_attribute4 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute5                    = ' ||
                  p_attribute5 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute6                    = ' ||
                  p_attribute6 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute7                    = ' ||
                  p_attribute7 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute8                    = ' ||
                  p_attribute8 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute9                    = ' ||
                  p_attribute9 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute10                   = ' ||
                  p_attribute10 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute11                   = ' ||
                  p_attribute11 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute12                   = ' ||
                  p_attribute12 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute13                   = ' ||
                  p_attribute13 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute14                   = ' ||
                  p_attribute14 );
      arp_util.debug('insert_header_cover: ' || 'p_attribute15                   = ' ||
                  p_attribute15 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_customer_trx_line_id   = ' ||
                  TO_CHAR(p_commit_customer_trx_line_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_commit_inventory_item_id      = ' ||
                  TO_CHAR(p_commit_inventory_item_id ) );
      arp_util.debug('insert_header_cover: ' || 'p_commit_memo_line_id           = ' ||
                  TO_CHAR(p_commit_memo_line_id      ) );
      arp_util.debug('insert_header_cover: ' || 'p_commit_description            = ' ||
                  p_commit_description );
      arp_util.debug('insert_header_cover: ' || 'p_commit_extended_amount        = ' ||
                  p_commit_extended_amount );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr1   = ' ||
                  p_commit_interface_line_attr1 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr2   = ' ||
                  p_commit_interface_line_attr2 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr3   = ' ||
                  p_commit_interface_line_attr3 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr4   = ' ||
                  p_commit_interface_line_attr4 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr5   = ' ||
                  p_commit_interface_line_attr5 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr6   = ' ||
                  p_commit_interface_line_attr6 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr7   = ' ||
                  p_commit_interface_line_attr7 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr8   = ' ||
                  p_commit_interface_line_attr8 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr9   = ' ||
                  p_commit_interface_line_attr9 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr10  = ' ||
                  p_commit_interface_line_attr10 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr11  = ' ||
                  p_commit_interface_line_attr11 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr12  = ' ||
                  p_commit_interface_line_attr12 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr13  = ' ||
                  p_commit_interface_line_attr13 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr14  = ' ||
                  p_commit_interface_line_attr14 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_attr15  = ' ||
                  p_commit_interface_line_attr15 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_interface_line_contxt  = ' ||
                  p_commit_interface_line_contxt );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute_category     = ' ||
                  p_commit_attribute_category );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute1             = ' ||
                  p_commit_attribute1 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute2             = ' ||
                  p_commit_attribute2 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute3             = ' ||
                  p_commit_attribute3 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute4             = ' ||
                  p_commit_attribute4 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute5             = ' ||
                  p_commit_attribute5 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute6             = ' ||
                  p_commit_attribute6 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute7             = ' ||
                  p_commit_attribute7 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute8             = ' ||
                  p_commit_attribute8 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute9             = ' ||
                  p_commit_attribute9 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute10            = ' ||
                  p_commit_attribute10 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute11            = ' ||
                  p_commit_attribute11 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute12            = ' ||
                  p_commit_attribute12 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute13            = ' ||
                  p_commit_attribute13 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute14            = ' ||
                  p_commit_attribute14 );
      arp_util.debug('insert_header_cover: ' || 'p_commit_attribute15            = ' ||
                  p_commit_attribute15 );
      arp_util.debug('insert_header_cover: ' || 'p_ctl_default_ussgl_trx_code    = ' ||
                  p_ctl_default_ussgl_trx_code );
      arp_util.debug('insert_header_cover: ' || 'p_old_trx_number                = ' ||
                  p_old_trx_number );
   END IF;
*/

   arp_process_header.insert_header(
                                      p_form_name,
                                      p_form_version,
                                      l_trx_rec,
                                      p_trx_class,
                                      p_gl_date,
                                      p_term_in_use_flag,
                                      l_commit_rec,
                                      p_new_trx_number,
                                      p_new_customer_trx_id,
                                      p_new_customer_trx_line_id,
                                      p_new_row_id,
                                      p_status,
                                      p_receivable_ccid);


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_header_insrt_cover.insert_header_cover()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('insert_header_cover: ' ||
          'EXCEPTION:  arp_process_header_insrt_cover.insert_header_cover()');
        END IF;
        RAISE;

END insert_header_cover;


END ARP_PROCESS_HEADER_INSRT_COVER;

/
