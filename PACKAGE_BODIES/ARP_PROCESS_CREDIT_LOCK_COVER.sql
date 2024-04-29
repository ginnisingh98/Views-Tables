--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_CREDIT_LOCK_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_CREDIT_LOCK_COVER" AS
/* $Header: ARTCCMLB.pls 115.4 2003/10/10 14:27:35 mraymond ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE lock_header_cover(
  p_form_name                   IN varchar2,
  p_form_version                IN number,
  p_customer_trx_id             IN ra_customer_trx.customer_trx_id%type,
  p_trx_number                  IN ra_customer_trx.trx_number%type,
  p_batch_id                    IN ra_batches.batch_id%type,
  p_trx_date                    IN ra_customer_trx.trx_date%type,
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
                     ra_customer_trx.default_ussgl_transaction_code%type)
IS
  l_cm_header              ra_customer_trx%rowtype;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_cover.lock_header_cover()+');
    END IF;

    arp_ct_pkg.set_to_dummy(l_cm_header);
    --
    --  populate the record with only the required columns
    --
   l_cm_header.batch_id                 := p_batch_id;
   l_cm_header.trx_number               := p_trx_number;
   l_cm_header.trx_date                 := p_trx_date;
   l_cm_header.complete_flag            := p_complete_flag;
   l_cm_header.previous_customer_trx_id := p_prev_customer_trx_id;
   l_cm_header.batch_source_id          := p_batch_source_id;
   l_cm_header.cust_trx_type_id         := p_cust_trx_type_id;
   l_cm_header.invoice_currency_code    := p_currency_code;
   l_cm_header.exchange_date            := p_exchange_date;
   l_cm_header.exchange_rate_type       := p_exchange_rate_type;
   l_cm_header.exchange_rate            := p_exchange_rate;
   l_cm_header.credit_method_for_rules  := p_method_for_rules;
   l_cm_header.credit_method_for_installments := p_split_term_method;
   l_cm_header.initial_customer_trx_id  := p_initial_customer_trx_id;
   l_cm_header.reason_code              := p_reason_code;
   l_cm_header.doc_sequence_value       := p_doc_sequence_value;
   l_cm_header.customer_reference       := p_customer_reference;
   l_cm_header.internal_notes           := p_internal_notes;
   l_cm_header.set_of_books_id          := p_set_of_books_id;
   l_cm_header.created_from             := p_created_from;
   l_cm_header.old_trx_number           := p_old_trx_number;
   l_cm_header.attribute_category       := p_attribute_category;
   l_cm_header.attribute1               := p_attribute1;
   l_cm_header.attribute2               := p_attribute2;
   l_cm_header.attribute3               := p_attribute3;
   l_cm_header.attribute4               := p_attribute4;
   l_cm_header.attribute5               := p_attribute5;
   l_cm_header.attribute6               := p_attribute6;
   l_cm_header.attribute7               := p_attribute7;
   l_cm_header.attribute8               := p_attribute8;
   l_cm_header.attribute9               := p_attribute9;
   l_cm_header.attribute10              := p_attribute10;
   l_cm_header.attribute11              := p_attribute11;
   l_cm_header.attribute12              := p_attribute12;
   l_cm_header.attribute13              := p_attribute13;
   l_cm_header.attribute14              := p_attribute14;
   l_cm_header.attribute15              := p_attribute15;
   l_cm_header.interface_header_context     := p_interface_header_context;
   l_cm_header.interface_header_attribute1  := p_interface_header_attribute1;
   l_cm_header.interface_header_attribute2  := p_interface_header_attribute2;
   l_cm_header.interface_header_attribute3  := p_interface_header_attribute3;
   l_cm_header.interface_header_attribute4  := p_interface_header_attribute4;
   l_cm_header.interface_header_attribute5  := p_interface_header_attribute5;
   l_cm_header.interface_header_attribute6  := p_interface_header_attribute6;
   l_cm_header.interface_header_attribute7  := p_interface_header_attribute7;
   l_cm_header.interface_header_attribute8  := p_interface_header_attribute8;
   l_cm_header.interface_header_attribute9  := p_interface_header_attribute9;
   l_cm_header.interface_header_attribute10 := p_interface_header_attribute10;
   l_cm_header.interface_header_attribute11 := p_interface_header_attribute11;
   l_cm_header.interface_header_attribute12 := p_interface_header_attribute12;
   l_cm_header.interface_header_attribute13 := p_interface_header_attribute13;
   l_cm_header.interface_header_attribute14 := p_interface_header_attribute14;
   l_cm_header.interface_header_attribute15 := p_interface_header_attribute15;
   l_cm_header.default_ussgl_transaction_code :=
                                               p_default_ussgl_trx_code;

    --
    -- call the entity handler
    --
    arp_ct_pkg.lock_compare_p(
             l_cm_header,
             p_customer_trx_id);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_cover.lock_header_cover()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_cover.lock_header_cover');
    END IF;
    RAISE;
END lock_header_cover;


END arp_process_credit_lock_cover;


/
