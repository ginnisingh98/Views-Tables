--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_HEADER_UPDTE_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_HEADER_UPDTE_COVER" AS
/* $Header: ARTEHECB.pls 120.10.12010000.7 2009/10/22 10:19:43 rasarasw ship $ */



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_header_cover                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a record in ra_customer_trx.                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_process_header.update_header                                       |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_form_name                                               |
 |                 p_form_version                                            |
 |                 p_trx_amount                                              |
 |                 p_trx_class                                               |
 |                 p_gl_date                                                 |
 |                 p_term_in_use_flag                                        |
 |                 p_open_rec_flag                                           |
 |                 p_recalc_tax_flag                                         |
 |                 p_rerun_autoacc_flag                                      |
 |                 p_receivable_ccid                                         |
 |                 p_customer_trx_id                                         |
 |                 p_trx_number                                              |
 |                 p_posting_control_id                                      |
 |                 p_ra_post_loop_number                                     |
 |                 p_complete_flag                                           |
 |                 p_initial_customer_trx_id                                 |
 |                 p_initial_customer_trx_line_id                            |
 |                 p_previous_customer_trx_id                                |
 |                 p_related_customer_trx_id                                 |
 |                 p_recurred_from_trx_number                                |
 |                 p_cust_trx_type_id                                        |
 |                 p_batch_id                                                |
 |                 p_batch_source_id                                         |
 |                 p_agreement_id                                            |
 |                 p_trx_date                                                |
 |                 p_bill_to_customer_id                                     |
 |                 p_bill_to_contact_id                                      |
 |                 p_bill_to_site_use_id                                     |
 |                 p_ship_to_customer_id                                     |
 |                 p_ship_to_contact_id                                      |
 |                 p_ship_to_site_use_id                                     |
 |                 p_sold_to_customer_id                                     |
 |                 p_sold_to_site_use_id                                     |
 |                 p_sold_to_contact_id                                      |
 |                 p_customer_reference                                      |
 |                 p_customer_reference_date                                 |
 |                 p_cr_method_for_installments                              |
 |                 p_credit_method_for_rules                                 |
 |                 p_start_date_commitment                                   |
 |                 p_end_date_commitment                                     |
 |                 p_exchange_date                                           |
 |                 p_exchange_rate                                           |
 |                 p_exchange_rate_type                                      |
 |                 p_customer_bank_account_id                                |
 |                 p_finance_charges                                         |
 |                 p_fob_point                                               |
 |                 p_comments                                                |
 |                 p_internal_notes                                          |
 |                 p_invoice_currency_code                                   |
 |                 p_invoicing_rule_id                                       |
 |                 p_last_printed_sequence_num                               |
 |                 p_orig_system_batch_name                                  |
 |                 p_primary_salesrep_id                                     |
 |                 p_printing_count                                          |
 |                 p_printing_last_printed                                   |
 |                 p_printing_option                                         |
 |                 p_printing_original_date                                  |
 |                 p_printing_pending                                        |
 |                 p_purchase_order                                          |
 |                 p_purchase_order_date                                     |
 |                 p_purchase_order_revision                                 |
 |                 p_receipt_method_id                                       |
 |                 p_remit_to_address_id                                     |
 |                 p_shipment_id                                             |
 |                 p_ship_date_actual                                        |
 |                 p_ship_via                                                |
 |                 p_term_due_date                                           |
 |                 p_term_id                                                 |
 |                 p_territory_id                                            |
 |                 p_waybill_number                                          |
 |                 p_status_trx                                              |
 |                 p_reason_code                                             |
 |                 p_doc_sequence_id                                         |
 |                 p_doc_sequence_value                                      |
 |                 p_paying_customer_id                                      |
 |                 p_paying_site_use_id                                      |
 |                 p_related_batch_source_id                                 |
 |                 p_default_tax_exempt_flag                                 |
 |                 p_created_from                                            |
 |                 p_ps_dispute_amount                                       |
 |                 p_ps_dispute_date                                         |
 |                 p_deflt_ussgl_trx_code_context                            |
 |                 p_deflt_ussgl_transaction_code                            |
 |                 p_old_trx_number                                          |
 |                 p_interface_header_context                                |
 |                 p_interface_header_attribute1                             |
 |                 p_interface_header_attribute2                             |
 |                 p_interface_header_attribute3                             |
 |                 p_interface_header_attribute4                             |
 |                 p_interface_header_attribute5                             |
 |                 p_interface_header_attribute6                             |
 |                 p_interface_header_attribute7                             |
 |                 p_interface_header_attribute8                             |
 |                 p_interface_header_attribute9                             |
 |                 p_interface_header_attribute10                            |
 |                 p_interface_header_attribute11                            |
 |                 p_interface_header_attribute12                            |
 |                 p_interface_header_attribute13                            |
 |                 p_interface_header_attribute14                            |
 |                 p_interface_header_attribute15                            |
 |                 p_attribute_category                                      |
 |                 p_attribute1                                              |
 |                 p_attribute2                                              |
 |                 p_attribute3                                              |
 |                 p_attribute4                                              |
 |                 p_attribute5                                              |
 |                 p_attribute6                                              |
 |                 p_attribute7                                              |
 |                 p_attribute8                                              |
 |                 p_attribute9                                              |
 |                 p_attribute10                                             |
 |                 p_attribute11                                             |
 |                 p_attribute12                                             |
 |                 p_attribute13                                             |
 |                 p_attribute14                                             |
 |                 p_attribute15                                             |
 |                 p_commit_customer_trx_line_id                             |
 |                 p_commit_inventory_item_id                                |
 |                 p_commit_memo_line_id                                     |
 |                 p_commit_description                                      |
 |                 p_commit_extended_amount                                  |
 |                 p_commit_interface_line_attr1                             |
 |                 p_commit_interface_line_attr2                             |
 |                 p_commit_interface_line_attr3                             |
 |                 p_commit_interface_line_attr4                             |
 |                 p_commit_interface_line_attr5                             |
 |                 p_commit_interface_line_attr6                             |
 |                 p_commit_interface_line_attr7                             |
 |                 p_commit_interface_line_attr8                             |
 |                 p_commit_interface_line_attr9                             |
 |                 p_commit_interface_line_attr10                            |
 |                 p_commit_interface_line_attr11                            |
 |                 p_commit_interface_line_attr12                            |
 |                 p_commit_interface_line_attr13                            |
 |                 p_commit_interface_line_attr14                            |
 |                 p_commit_interface_line_attr15                            |
 |                 p_commit_interface_line_contxt                            |
 |                 p_commit_attribute_category                               |
 |                 p_commit_attribute1                                       |
 |                 p_commit_attribute2                                       |
 |                 p_commit_attribute3                                       |
 |                 p_commit_attribute4                                       |
 |                 p_commit_attribute5                                       |
 |                 p_commit_attribute6                                       |
 |                 p_commit_attribute7                                       |
 |                 p_commit_attribute8                                       |
 |                 p_commit_attribute9                                       |
 |                 p_commit_attribute10                                      |
 |                 p_commit_attribute11                                      |
 |                 p_commit_attribute12                                      |
 |                 p_commit_attribute13                                      |
 |                 p_commit_attribute14                                      |
 |                 p_commit_attribute15                                      |
 |              OUT:                                                         |
 |                 p_trx_number                                              |
 |                 p_customer_trx_id                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-NOV-95  Martin Johnson      Created                                |
 |     18-May-05  Debbie Sue Jancis   Added Legal Entity Id for LE project   |
 |   28-MAR-2006  Herve Yu            BUG#4897183 call update XLA events     |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE update_header_cover(
  p_form_name                           IN varchar2,
  p_form_version                        IN number,
  p_trx_amount                          IN number,
  p_trx_class                           IN VARCHAR2,
  p_gl_date                             IN DATE,
  p_term_in_use_flag                    IN varchar2,
  p_open_rec_flag                       IN VARCHAR2,
  p_recalc_tax_flag                     IN varchar2,
  p_rerun_autoacc_flag                  IN varchar2,
  p_receivable_ccid                     IN NUMBER,
  p_customer_trx_id                     IN NUMBER,
  p_trx_number                          IN VARCHAR2,
  p_posting_control_id                  IN NUMBER,
  p_ra_post_loop_number                 IN NUMBER,
  p_complete_flag                       IN VARCHAR2,
  p_initial_customer_trx_id             IN NUMBER,
  p_initial_customer_trx_line_id        IN NUMBER,
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
  p_ps_dispute_amount                   IN number,
  p_ps_dispute_date                     IN date,
  p_deflt_ussgl_trx_code_context        IN VARCHAR2,
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
  p_ctl_default_ussgl_trx_code          IN varchar2,
  p_status                             OUT NOCOPY varchar2,
  p_legal_entity_id                     IN NUMBER DEFAULT NULL,
  p_payment_trxn_extension_id           IN NUMBER DEFAULT NULL,
  p_billing_date                        IN DATE   DEFAULT NULL,
  p_ct_reference			IN VARCHAR2 DEFAULT NULL)  IS /* Bug fix 5330712 */

--{BUG#4897183
CURSOR cev IS
SELECT t.trx_date,
       d.gl_date,
       t.org_id,
       d.set_of_books_id,
       t.term_id,
       t.exchange_rate,
       t.exchange_date,
       t.exchange_rate_type,
       t.complete_flag         -- Bug 8936486
  FROM ra_customer_trx t,
       ra_cust_trx_line_gl_dist d
 WHERE t.customer_trx_id = p_customer_trx_id
   AND t.customer_trx_id = d.customer_trx_id
   AND d.account_class   = 'REC' ;

CURSOR c_line (p_trx_id NUMBER) IS
SELECT customer_trx_line_id
FROM   ra_customer_trx_lines_all
WHERE  customer_trx_id = p_trx_id
AND    line_type = 'LINE';

  l_trx_date   DATE;
  l_gl_date    DATE;
  l_org_id     NUMBER;
  l_sob_id     NUMBER;
  l_term_id    NUMBER;
  lf           BOOLEAN;
  x_event_id   NUMBER;
  l_exch_rate  NUMBER;
  l_exch_date  DATE;
  l_exch_type  VARCHAR2(30);
--}

  l_commit_rec          arp_process_commitment.commitment_rec_type;
  l_trx_rec             ra_customer_trx%rowtype;
  l_recalc_tax_flag     boolean;
  l_rerun_autoacc_flag  boolean;
  l_return_status       NUMBER;

  /* Bug 8936486 */
  l_db_complete_flag      VARCHAR2(1);
  l_tax_validation_status VARCHAR2(1);
  l_error_count           NUMBER;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_header_updte_cover.update_header_cover()+');
   END IF;

   arp_ct_pkg.set_to_dummy(l_trx_rec);
   arp_process_commitment.set_to_dummy(l_commit_rec);

   l_trx_rec.customer_trx_id                := p_customer_trx_id;
   l_trx_rec.trx_number                     := p_trx_number;
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
   l_trx_rec.default_ussgl_trx_code_context := p_deflt_ussgl_trx_code_context;
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

   l_trx_rec.legal_entity_id                := p_legal_entity_id;
   /* PAYMENT_UPTAKE */
   l_trx_rec.payment_trxn_extension_id      := p_payment_trxn_extension_id;
   l_trx_rec.billing_date                   := p_billing_date;
   l_trx_rec.ct_reference                   := p_ct_reference; /* Bug fix 5330712 */

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


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'p_customer_trx_id               = ' ||
                  TO_CHAR(p_customer_trx_id ) );
      arp_util.debug(  'p_trx_number                    = ' ||
                  p_trx_number );
      arp_util.debug(  'p_trx_amount                    = ' ||
                  TO_CHAR(p_trx_amount ) );
      arp_util.debug(  'p_open_rec_flag                 = '||
                  p_open_rec_flag);
      arp_util.debug(  'p_term_in_use_flag              = '||
                  p_term_in_use_flag);
      arp_util.debug(  'p_recalc_tax_flag               = '||
                  p_recalc_tax_flag);
      arp_util.debug(  'p_rerun_autoacc_flag            = '||
                  p_rerun_autoacc_flag);
      arp_util.debug(  'p_posting_control_id            = ' ||
                  TO_CHAR(p_posting_control_id ) );
      arp_util.debug(  'p_ra_post_loop_number           = ' ||
                  p_ra_post_loop_number );
      arp_util.debug(  'p_complete_flag                 = ' ||
                  p_complete_flag );
      arp_util.debug(  'p_initial_customer_trx_id       = ' ||
                  TO_CHAR(p_initial_customer_trx_id ) );
      arp_util.debug(  'p_initial_customer_trx_line_id  = ' ||
                  TO_CHAR(p_initial_customer_trx_line_id ) );
      arp_util.debug(  'p_previous_customer_trx_id      = ' ||
                  TO_CHAR(p_previous_customer_trx_id ) );
      arp_util.debug(  'p_related_customer_trx_id       = ' ||
                  TO_CHAR(p_related_customer_trx_id ) );
      arp_util.debug(  'p_recurred_from_trx_number      = ' ||
                  p_recurred_from_trx_number );
      arp_util.debug(  'p_cust_trx_type_id              = ' ||
                  TO_CHAR(p_cust_trx_type_id ) );
      arp_util.debug(  'p_batch_id                      = ' ||
                  TO_CHAR(p_batch_id ) );
      arp_util.debug(  'p_batch_source_id               = ' ||
                  TO_CHAR(p_batch_source_id ) );
      arp_util.debug(  'p_agreement_id                  = ' ||
                  TO_CHAR(p_agreement_id ) );
      arp_util.debug(  'p_trx_date                      = ' ||
                  p_trx_date );
      arp_util.debug(  'p_bill_to_customer_id           = ' ||
                  TO_CHAR(p_bill_to_customer_id ) );
      arp_util.debug(  'p_bill_to_contact_id            = ' ||
                  TO_CHAR(p_bill_to_contact_id ) );
      arp_util.debug(  'p_bill_to_site_use_id           = ' ||
                  TO_CHAR(p_bill_to_site_use_id ) );
      arp_util.debug(  'p_ship_to_customer_id           = ' ||
                  TO_CHAR(p_ship_to_customer_id ) );
      arp_util.debug(  'p_ship_to_contact_id            = ' ||
                  TO_CHAR(p_ship_to_contact_id ) );
      arp_util.debug(  'p_ship_to_site_use_id           = ' ||
                  TO_CHAR(p_ship_to_site_use_id ) );
      arp_util.debug(  'p_sold_to_customer_id           = ' ||
                  TO_CHAR(p_sold_to_customer_id ) );
      arp_util.debug(  'p_sold_to_site_use_id           = ' ||
                  TO_CHAR(p_sold_to_site_use_id ) );
      arp_util.debug(  'p_sold_to_contact_id            = ' ||
                  TO_CHAR(p_sold_to_contact_id ) );
      arp_util.debug(  'p_customer_reference            = ' ||
                  p_customer_reference );
      arp_util.debug(  'p_customer_reference_date       = ' ||
                  p_customer_reference_date );
      arp_util.debug(  'p_cr_method_for_installments    = ' ||
                  p_cr_method_for_installments );
      arp_util.debug(  'p_credit_method_for_rules       = ' ||
                  p_credit_method_for_rules );
      arp_util.debug(  'p_start_date_commitment         = ' ||
                  p_start_date_commitment );
      arp_util.debug(  'p_end_date_commitment           = ' ||
                  p_end_date_commitment );
      arp_util.debug(  'p_exchange_date                 = ' ||
                  p_exchange_date );
      arp_util.debug(  'p_exchange_rate                 = ' ||
                  p_exchange_rate );
      arp_util.debug(  'p_exchange_rate_type            = ' ||
                  p_exchange_rate_type );
      arp_util.debug(  'p_customer_bank_account_id      = ' ||
                  p_customer_bank_account_id );
      arp_util.debug(  'p_finance_charges               = ' ||
                  p_finance_charges );
      arp_util.debug(  'p_fob_point                     = ' ||
                  p_fob_point );
      arp_util.debug(  'p_comments                      = ' ||
                  p_comments );
      arp_util.debug(  'p_internal_notes                = ' ||
                  p_internal_notes );
      arp_util.debug(  'p_invoice_currency_code         = ' ||
                  p_invoice_currency_code );
      arp_util.debug(  'p_invoicing_rule_id             = ' ||
                  TO_CHAR(p_invoicing_rule_id ) );
      arp_util.debug(  'p_last_printed_sequence_num     = ' ||
                  p_last_printed_sequence_num );
      arp_util.debug(  'p_orig_system_batch_name        = ' ||
                  p_orig_system_batch_name );
      arp_util.debug(  'p_primary_salesrep_id           = ' ||
                  TO_CHAR(p_primary_salesrep_id ) );
      arp_util.debug(  'p_printing_count                = ' ||
                  p_printing_count );
      arp_util.debug(  'p_printing_last_printed         = ' ||
                  p_printing_last_printed );
      arp_util.debug(  'p_printing_option               = ' ||
                  p_printing_option );
      arp_util.debug(  'p_printing_original_date        = ' ||
                  p_printing_original_date );
      arp_util.debug(  'p_printing_pending              = ' ||
                  p_printing_pending );
      arp_util.debug(  'p_purchase_order                = ' ||
                  p_purchase_order );
      arp_util.debug(  'p_purchase_order_date           = ' ||
                  p_purchase_order_date );
      arp_util.debug(  'p_purchase_order_revision       = ' ||
                  p_purchase_order_revision );
      arp_util.debug(  'p_receipt_method_id             = ' ||
                  TO_CHAR(p_receipt_method_id ) );
      arp_util.debug(  'p_remit_to_address_id           = ' ||
                  TO_CHAR(p_remit_to_address_id ) );
      arp_util.debug(  'p_shipment_id                   = ' ||
                  TO_CHAR(p_shipment_id ) );
      arp_util.debug(  'p_ship_date_actual              = ' ||
                  p_ship_date_actual );
      arp_util.debug(  'p_ship_via                      = ' ||
                  p_ship_via );
      arp_util.debug(  'p_term_due_date                 = ' ||
                  p_term_due_date );
      arp_util.debug(  'p_term_id                       = ' ||
                  TO_CHAR(p_term_id ) );
      arp_util.debug(  'p_territory_id                  = ' ||
                  p_territory_id );
      arp_util.debug(  'p_waybill_number                = ' ||
                  p_waybill_number );
      arp_util.debug(  'p_status_trx                    = ' ||
                  p_status_trx );
      arp_util.debug(  'p_reason_code                   = ' ||
                  p_reason_code );
      arp_util.debug(  'p_doc_sequence_id               = ' ||
                  p_doc_sequence_id );
      arp_util.debug(  'p_doc_sequence_value            = ' ||
                  p_doc_sequence_value );
      arp_util.debug(  'p_paying_customer_id            = ' ||
                  TO_CHAR(p_paying_customer_id ) );
      arp_util.debug(  'p_paying_site_use_id            = ' ||
                  TO_CHAR(p_paying_site_use_id ) );
      arp_util.debug(  'p_related_batch_source_id       = ' ||
                  p_related_batch_source_id );
      arp_util.debug(  'p_default_tax_exempt_flag       = ' ||
                  p_default_tax_exempt_flag );
      arp_util.debug(  'p_created_from                  = ' ||
                  p_created_from );
      arp_util.debug(  'p_ps_dispute_amount             = ' ||
                  p_ps_dispute_amount );
      arp_util.debug(  'p_ps_dispute_date               = ' ||
                  p_ps_dispute_date );
      arp_util.debug(  'p_deflt_ussgl_trx_code_context  = ' ||
                  p_deflt_ussgl_trx_code_context );
      arp_util.debug(  'p_deflt_ussgl_transaction_code  = ' ||
                  p_deflt_ussgl_transaction_code );
      arp_util.debug(  'p_old_trx_number                = ' ||
                  p_old_trx_number );
      arp_util.debug(  'p_interface_header_context      = ' ||
                  p_interface_header_context );
      arp_util.debug(  'p_interface_header_attribute1   = ' ||
                  p_interface_header_attribute1 );
      arp_util.debug(  'p_interface_header_attribute2   = ' ||
                  p_interface_header_attribute2 );
      arp_util.debug(  'p_interface_header_attribute3   = ' ||
                  p_interface_header_attribute3 );
      arp_util.debug(  'p_interface_header_attribute4   = ' ||
                  p_interface_header_attribute4 );
      arp_util.debug(  'p_interface_header_attribute5   = ' ||
                  p_interface_header_attribute5 );
      arp_util.debug(  'p_interface_header_attribute6   = ' ||
                  p_interface_header_attribute6 );
      arp_util.debug(  'p_interface_header_attribute7   = ' ||
                  p_interface_header_attribute7 );
      arp_util.debug(  'p_interface_header_attribute8   = ' ||
                  p_interface_header_attribute8 );
      arp_util.debug(  'p_interface_header_attribute9   = ' ||
                  p_interface_header_attribute9 );
      arp_util.debug(  'p_interface_header_attribute10  = ' ||
                  p_interface_header_attribute10 );
      arp_util.debug(  'p_interface_header_attribute11  = ' ||
                  p_interface_header_attribute11 );
      arp_util.debug(  'p_interface_header_attribute12  = ' ||
                  p_interface_header_attribute12 );
      arp_util.debug(  'p_interface_header_attribute13  = ' ||
                  p_interface_header_attribute13 );
      arp_util.debug(  'p_interface_header_attribute14  = ' ||
                  p_interface_header_attribute14 );
      arp_util.debug(  'p_interface_header_attribute15  = ' ||
                  p_interface_header_attribute15 );
      arp_util.debug(  'p_attribute_category            = ' ||
                  p_attribute_category );
      arp_util.debug(  'p_attribute1                    = ' ||
                  p_attribute1 );
      arp_util.debug(  'p_attribute2                    = ' ||
                  p_attribute2 );
      arp_util.debug(  'p_attribute3                    = ' ||
                  p_attribute3 );
      arp_util.debug(  'p_attribute4                    = ' ||
                  p_attribute4 );
      arp_util.debug(  'p_attribute5                    = ' ||
                  p_attribute5 );
      arp_util.debug(  'p_attribute6                    = ' ||
                  p_attribute6 );
      arp_util.debug(  'p_attribute7                    = ' ||
                  p_attribute7 );
      arp_util.debug(  'p_attribute8                    = ' ||
                  p_attribute8 );
      arp_util.debug(  'p_attribute9                    = ' ||
                  p_attribute9 );
      arp_util.debug(  'p_attribute10                   = ' ||
                  p_attribute10 );
      arp_util.debug(  'p_attribute11                   = ' ||
                  p_attribute11 );
      arp_util.debug(  'p_attribute12                   = ' ||
                  p_attribute12 );
      arp_util.debug(  'p_attribute13                   = ' ||
                  p_attribute13 );
      arp_util.debug(  'p_attribute14                   = ' ||
                  p_attribute14 );
      arp_util.debug(  'p_attribute15                   = ' ||
                  p_attribute15 );
      arp_util.debug(  'p_commit_customer_trx_line_id   = ' ||
                  TO_CHAR(p_commit_customer_trx_line_id ) );
      arp_util.debug(  'p_commit_inventory_item_id      = ' ||
                  TO_CHAR(p_commit_inventory_item_id ) );
      arp_util.debug(  'p_commit_memo_line_id           = ' ||
                  TO_CHAR(p_commit_memo_line_id      ) );
      arp_util.debug(  'p_commit_description            = ' ||
                  p_commit_description );
      arp_util.debug(  'p_commit_extended_amount        = ' ||
                  p_commit_extended_amount );
      arp_util.debug(  'p_commit_interface_line_attr1   = ' ||
                  p_commit_interface_line_attr1 );
      arp_util.debug(  'p_commit_interface_line_attr2   = ' ||
                  p_commit_interface_line_attr2 );
      arp_util.debug(  'p_commit_interface_line_attr3   = ' ||
                  p_commit_interface_line_attr3 );
      arp_util.debug(  'p_commit_interface_line_attr4   = ' ||
                  p_commit_interface_line_attr4 );
      arp_util.debug(  'p_commit_interface_line_attr5   = ' ||
                  p_commit_interface_line_attr5 );
      arp_util.debug(  'p_commit_interface_line_attr6   = ' ||
                  p_commit_interface_line_attr6 );
      arp_util.debug(  'p_commit_interface_line_attr7   = ' ||
                  p_commit_interface_line_attr7 );
      arp_util.debug(  'p_commit_interface_line_attr8   = ' ||
                  p_commit_interface_line_attr8 );
      arp_util.debug(  'p_commit_interface_line_attr9   = ' ||
                  p_commit_interface_line_attr9 );
      arp_util.debug(  'p_commit_interface_line_attr10  = ' ||
                  p_commit_interface_line_attr10 );
      arp_util.debug(  'p_commit_interface_line_attr11  = ' ||
                  p_commit_interface_line_attr11 );
      arp_util.debug(  'p_commit_interface_line_attr12  = ' ||
                  p_commit_interface_line_attr12 );
      arp_util.debug(  'p_commit_interface_line_attr13  = ' ||
                  p_commit_interface_line_attr13 );
      arp_util.debug(  'p_commit_interface_line_attr14  = ' ||
                  p_commit_interface_line_attr14 );
      arp_util.debug(  'p_commit_interface_line_attr15  = ' ||
                  p_commit_interface_line_attr15 );
      arp_util.debug(  'p_commit_interface_line_contxt  = ' ||
                  p_commit_interface_line_contxt );
      arp_util.debug(  'p_commit_attribute_category     = ' ||
                  p_commit_attribute_category );
      arp_util.debug(  'p_commit_attribute1             = ' ||
                  p_commit_attribute1 );
      arp_util.debug(  'p_commit_attribute2             = ' ||
                  p_commit_attribute2 );
      arp_util.debug(  'p_commit_attribute3             = ' ||
                  p_commit_attribute3 );
      arp_util.debug(  'p_commit_attribute4             = ' ||
                  p_commit_attribute4 );
      arp_util.debug(  'p_commit_attribute5             = ' ||
                  p_commit_attribute5 );
      arp_util.debug(  'p_commit_attribute6             = ' ||
                  p_commit_attribute6 );
      arp_util.debug(  'p_commit_attribute7             = ' ||
                  p_commit_attribute7 );
      arp_util.debug(  'p_commit_attribute8             = ' ||
                  p_commit_attribute8 );
      arp_util.debug(  'p_commit_attribute9             = ' ||
                  p_commit_attribute9 );
      arp_util.debug(  'p_commit_attribute10            = ' ||
                  p_commit_attribute10 );
      arp_util.debug(  'p_commit_attribute11            = ' ||
                  p_commit_attribute11 );
      arp_util.debug(  'p_commit_attribute12            = ' ||
                  p_commit_attribute12 );
      arp_util.debug(  'p_commit_attribute13            = ' ||
                  p_commit_attribute13 );
      arp_util.debug(  'p_commit_attribute14            = ' ||
                  p_commit_attribute14 );
      arp_util.debug(  'p_commit_attribute15            = ' ||
                  p_commit_attribute15 );
      arp_util.debug(  'p_ctl_default_ussgl_trx_code    = ' ||
                  p_ctl_default_ussgl_trx_code );
   END IF;

--{BUG#4897183
-- BUG#8349620
OPEN cev;
FETCH cev INTO l_trx_date, l_gl_date,  l_org_id,  l_sob_id, l_term_id,
               l_exch_rate, l_exch_date, l_exch_type, l_db_complete_flag;
IF cev%FOUND THEN
  lf := TRUE;
ELSE
  lf := FALSE;
END IF;
CLOSE cev;

IF  lf THEN
arp_acct_event_pkg.update_dates_for_trx_event
(p_source_id_int_1    => p_customer_trx_id,
 p_trx_number         => p_trx_number,
 p_legal_entity_id    => p_legal_entity_id,
 p_ledger_id          => l_sob_id,
 p_org_id             => l_org_id,
 p_event_id           => NULL,
 p_valuation_method   => NULL,
 p_entity_type_code   => 'TRANSACTIONS',
 p_event_type_code    => 'INV_CREATE',
 p_curr_event_date    => l_gl_date,
 p_event_date         => p_gl_date,
 p_status             => 'I',
 p_action             => 'UPDATE_EVENT_DATE',
 p_curr_trx_date      => l_trx_date,
 p_transaction_date   => p_trx_date,
 x_event_id           => x_event_id);

arp_util.debug(  'x_event_id    = ' ||x_event_id );
END IF;
--}





 /*-------------------------------------------+
  |  Convert Y/N parameter flags to booleans  |
  +-------------------------------------------*/


   IF (p_recalc_tax_flag = 'Y')
   THEN  l_recalc_tax_flag := TRUE;
   ELSE  l_recalc_tax_flag := FALSE;
   END IF;

   IF (p_rerun_autoacc_flag = 'Y')
   THEN  l_rerun_autoacc_flag := TRUE;
   ELSE  l_rerun_autoacc_flag := FALSE;
   END IF;

   /*  Bug 654051:  added NVL around dispute amount */
   /* Bug No 1311297 : added NVL around dispute amount */
   arp_process_header.update_header(
                                      p_form_name,
                                      p_form_version,
                                      l_trx_rec,
                                      p_customer_trx_id,
                                      NVL(p_trx_amount,0),
                                      p_trx_class,
                                      p_gl_date,
                                      p_initial_customer_trx_line_id,
                                      l_commit_rec,
                                      p_open_rec_flag,
                                      p_term_in_use_flag,
                                      l_recalc_tax_flag,
                                      l_rerun_autoacc_flag,
                                      NVL(p_ps_dispute_amount,0),
                                      p_ps_dispute_date,
                                      p_status);

   /* 5468039 - call etax synchronize routine when gl_dates change */
   /* 5594687 - call line_det_factors if term_id has changed */
   /* 8349620 - Added Call to eTax API update_exchange_rate when
      Exchange details updates.*/
   IF  lf
   THEN
     /* Determine state for etax sync call */

    IF (p_complete_flag = 'Y') AND (NVL(p_exchange_rate, 0) <> NVL(l_exch_rate, 0) OR
                                    NVL(p_exchange_rate_type, '$#') <> NVL(l_exch_type, '$#') OR
				    NOT((p_exchange_date iS NULL AND l_exch_date IS NULL) OR p_exchange_date = l_exch_date)) THEN

        arp_etax_services_pkg.update_exchange_info(
	              p_customer_trx_id      => p_customer_trx_id,
		      p_exchange_rate        => p_exchange_rate,
		      p_exchange_date        => p_exchange_date,
		      p_exchange_rate_type   => p_exchange_rate_type );

    END IF;   -- END IF for p_complete_flag chack

     IF PG_DEBUG in ('Y','C')
     THEN
         arp_util.debug('Header exists (lf = TRUE) ');
         arp_util.debug('   old term_id = ' || l_term_id);
         arp_util.debug('   new term_id = ' || p_term_id);
         arp_util.debug('   old_gl_date = ' || l_gl_date);
         arp_util.debug('   new_gl_date = ' || p_gl_date);
     END IF;

     IF NVL(p_term_id, l_term_id) <> l_term_id
     THEN
        /* execute line_det_factor update (discount amount
           may have changed) */
        IF PG_DEBUG in ('Y','C')
        THEN
           arp_debug.debug('term has changed, execute update of LDF');
        END IF;

        /* loop through the lines and update line det factors
           for each */
        FOR line IN c_line(p_customer_trx_id)
        LOOP
           arp_etax_services_pkg.line_det_factors(line.customer_trx_line_id,
                                                  p_customer_trx_id,
                                                  'UPDATE');
        END LOOP;

        /* Bug 8936486: Start
        When the payment term is changed for a completed
        transaction, ETAX validate_for_tax should be called */

        IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('l_db_complete_flag = '||l_db_complete_flag);
        END IF;

        IF l_db_complete_flag = 'Y' AND p_complete_flag = 'Y' THEN

        arp_etax_services_pkg.validate_for_tax(
                               p_customer_trx_id => p_customer_trx_id,
                               p_error_mode      => 'STANDARD',
                               p_valid_for_tax   => l_tax_validation_status,
                               p_number_of_errors=> l_error_count);

        IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('num of etax validation errors = '||l_error_count);
        END IF;

        END IF;

        /* Bug 8936486: End */

     ELSIF NVL(p_gl_date, l_gl_date) <> l_gl_date
     THEN
        IF PG_DEBUG in ('Y','C')
        THEN
           arp_debug.debug('gl_date has changed, execute synchronize w/lines');
        END IF;
        /* execute synchronize w/ line update */
        arp_etax_util.synchronize_for_doc_seq(p_customer_trx_id,l_return_status,
                                            NULL,
                                            'Y');
        IF l_return_status > 0
        THEN
           arp_util.debug('EXCEPTION:  error calling eBusiness Tax, status = ' ||
                           l_return_status);
           arp_util.debug('Please review the plsql debug log for additional details.');
           p_status := 'SYNCH_DOC_SEQ_ERROR';
        END IF;
     ELSE
        /* execute synchronize w/out line update */
        IF PG_DEBUG in ('Y','C')
        THEN
           arp_debug.debug('execute synchronize for doc seq only');
        END IF;

        arp_etax_util.synchronize_for_doc_seq(p_customer_trx_id,l_return_status);

        IF l_return_status > 0
        THEN
           arp_util.debug('EXCEPTION:  error calling eBusiness Tax, status = ' ||
                           l_return_status);
           arp_util.debug('Please review the plsql debug log for additional details.');
           p_status := 'SYNCH_DOC_SEQ_ERROR';
        END IF;
     END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_header_updte_cover.update_header_cover()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug(
           'exception:  arp_process_header_updte_cover.update_header_cover()');
       END IF;
        RAISE;

END update_header_cover;

END ARP_PROCESS_HEADER_UPDTE_COVER;

/
