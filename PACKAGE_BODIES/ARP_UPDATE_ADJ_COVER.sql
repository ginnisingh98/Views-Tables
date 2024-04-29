--------------------------------------------------------
--  DDL for Package Body ARP_UPDATE_ADJ_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_UPDATE_ADJ_COVER" AS
/* $Header: ARTADJUB.pls 120.4.12010000.1 2008/07/24 16:54:19 appldev ship $ */

pg_msg_level_debug    binary_integer;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE update_adj_cover(
           p_form_name                      IN varchar2,
           p_form_version                   IN number,
           p_acctd_amount                   IN
              ar_adjustments.acctd_amount%type,
           p_adjustment_id                  IN
              ar_adjustments.adjustment_id%type,
           p_adjustment_number              IN
              ar_adjustments.adjustment_number%type,
           p_adjustment_type                IN
              ar_adjustments.adjustment_type%type,
           p_amount                         IN
              ar_adjustments.amount%type,
           p_apply_date                     IN
              ar_adjustments.apply_date%type,
           p_approved_by                    IN
              ar_adjustments.approved_by%type,
           p_associated_application_id      IN
              ar_adjustments.associated_application_id%type,
           p_associated_cash_receipt_id     IN
              ar_adjustments.associated_cash_receipt_id%type,
           p_attribute1                     IN
              ar_adjustments.attribute1%type,
           p_attribute10                    IN
              ar_adjustments.attribute10%type,
           p_attribute11                    IN
              ar_adjustments.attribute11%type,
           p_attribute12                    IN
              ar_adjustments.attribute12%type,
           p_attribute13                    IN
              ar_adjustments.attribute13%type,
           p_attribute14                    IN
              ar_adjustments.attribute14%type,
           p_attribute15                    IN
              ar_adjustments.attribute15%type,
           p_attribute2                     IN
              ar_adjustments.attribute2%type,
           p_attribute3                     IN
              ar_adjustments.attribute3%type,
           p_attribute4                     IN
              ar_adjustments.attribute4%type,
           p_attribute5                     IN
              ar_adjustments.attribute5%type,
           p_attribute6                     IN
              ar_adjustments.attribute6%type,
           p_attribute7                     IN
              ar_adjustments.attribute7%type,
           p_attribute8                     IN
              ar_adjustments.attribute8%type,
           p_attribute9                     IN
              ar_adjustments.attribute9%type,
           p_attribute_category             IN
              ar_adjustments.attribute_category%type,
           p_automatically_generated        IN
              ar_adjustments.automatically_generated%type,
           p_batch_id                       IN
              ar_adjustments.batch_id%type,
           p_chargeback_customer_trx_id     IN
              ar_adjustments.chargeback_customer_trx_id%type,
           p_code_combination_id            IN
              ar_adjustments.code_combination_id%type,
           p_comments                       IN
              ar_adjustments.comments%type,
           p_created_by                     IN
              ar_adjustments.created_by%type,
           p_created_from                   IN
              ar_adjustments.created_from%type,
           p_creation_date                  IN
              ar_adjustments.creation_date%type,
           p_customer_trx_id                IN
              ar_adjustments.customer_trx_id%type,
           p_customer_trx_line_id           IN
              ar_adjustments.customer_trx_line_id%type,
           p_distribution_set_id            IN
              ar_adjustments.distribution_set_id%type,
           p_doc_sequence_id                IN
              ar_adjustments.doc_sequence_id%type,
           p_doc_sequence_value             IN
              ar_adjustments.doc_sequence_value%type,
           p_freight_adjusted               IN
              ar_adjustments.freight_adjusted%type,
           p_gl_date                        IN
              ar_adjustments.gl_date%type,
           p_gl_posted_date                 IN
              ar_adjustments.gl_posted_date%type,
           p_last_updated_by                IN
              ar_adjustments.last_updated_by%type,
           p_last_update_date               IN
              ar_adjustments.last_update_date%type,
           p_last_update_login              IN
              ar_adjustments.last_update_login%type,
           p_line_adjusted                  IN
              ar_adjustments.line_adjusted%type,
           p_org_id                         IN
              ar_adjustments.org_id%type,
           p_payment_schedule_id            IN
              ar_adjustments.payment_schedule_id%type,
           p_postable                       IN
              ar_adjustments.postable%type,
           p_posting_control_id             IN
              ar_adjustments.posting_control_id%type,
           p_program_application_id         IN
              ar_adjustments.program_application_id%type,
           p_program_id                     IN
              ar_adjustments.program_id%type,
           p_program_update_date            IN
              ar_adjustments.program_update_date%type,
           p_reason_code                    IN
              ar_adjustments.reason_code%type,
           p_receivables_charges_adjusted   IN
              ar_adjustments.receivables_charges_adjusted%type,
           p_receivables_trx_id             IN
              ar_adjustments.receivables_trx_id%type,
           p_request_id                     IN
              ar_adjustments.request_id%type,
           p_set_of_books_id                IN
              ar_adjustments.set_of_books_id%type,
           p_status                         IN
              ar_adjustments.status%type,
           p_subsequent_trx_id              IN
              ar_adjustments.subsequent_trx_id%type,
           p_tax_adjusted                   IN
              ar_adjustments.tax_adjusted%type,
           p_type                           IN
              ar_adjustments.type%type,
           p_ussgl_transaction_code         IN
              ar_adjustments.ussgl_transaction_code%type,
           p_ussgl_transaction_code_conte IN
              ar_adjustments.ussgl_transaction_code_context%type)

IS

      l_adj_rec ar_adjustments%rowtype ;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_process_adjustment.update_adj_cover()+',
                      pg_msg_level_debug);
      END IF;

     /*------------------------------------------------+
      |  Populate the adj record group with            |
      |  the values passed in as parameters.           |
      +------------------------------------------------*/

      arp_adjustments_pkg.set_to_dummy(l_adj_rec);

      l_adj_rec.adjustment_id                  := p_adjustment_id;
      l_adj_rec.adjustment_number              := p_adjustment_number;
      l_adj_rec.adjustment_type                := p_adjustment_type;
      l_adj_rec.amount                         := p_amount;
      l_adj_rec.apply_date                     := p_apply_date;
      l_adj_rec.approved_by                    := p_approved_by;
      l_adj_rec.attribute1                     := p_attribute1;
      l_adj_rec.attribute10                    := p_attribute10;
      l_adj_rec.attribute11                    := p_attribute11;
      l_adj_rec.attribute12                    := p_attribute12;
      l_adj_rec.attribute13                    := p_attribute13;
      l_adj_rec.attribute14                    := p_attribute14;
      l_adj_rec.attribute15                    := p_attribute15;
      l_adj_rec.attribute2                     := p_attribute2;
      l_adj_rec.attribute3                     := p_attribute3;
      l_adj_rec.attribute4                     := p_attribute4;
      l_adj_rec.attribute5                     := p_attribute5;
      l_adj_rec.attribute6                     := p_attribute6;
      l_adj_rec.attribute7                     := p_attribute7;
      l_adj_rec.attribute8                     := p_attribute8;
      l_adj_rec.attribute9                     := p_attribute9;
      l_adj_rec.attribute_category             := p_attribute_category;
      l_adj_rec.code_combination_id            := p_code_combination_id;
      l_adj_rec.comments                       := p_comments;
      l_adj_rec.customer_trx_id                := p_customer_trx_id;
      l_adj_rec.customer_trx_line_id           := p_customer_trx_line_id;
      l_adj_rec.doc_sequence_id                := p_doc_sequence_id;
      l_adj_rec.doc_sequence_value             := p_doc_sequence_value;
      l_adj_rec.gl_date                        := p_gl_date;
      l_adj_rec.last_updated_by                := p_last_updated_by;
      l_adj_rec.last_update_date               := p_last_update_date;
      l_adj_rec.payment_schedule_id            := p_payment_schedule_id;
      l_adj_rec.reason_code                    := p_reason_code;
      l_adj_rec.receivables_trx_id             := p_receivables_trx_id;
      l_adj_rec.status                         := p_status;
      l_adj_rec.ussgl_transaction_code         := p_ussgl_transaction_code;
      l_adj_rec.ussgl_transaction_code_context := p_ussgl_transaction_code_conte;
      /* Bug 6378577 */
      l_adj_rec.line_adjusted                  := p_line_adjusted;
      l_adj_rec.receivables_charges_adjusted   := p_receivables_charges_adjusted;
      l_adj_rec.freight_adjusted               := p_freight_adjusted;
      l_adj_rec.tax_adjusted                   := p_tax_adjusted;
     /*-----------------------------------------------+
      |  Call the standard adj entity handler         |
      +-----------------------------------------------*/

      arp_process_adjustment.update_adjustment(
                  p_form_name     => p_form_name,
                  p_form_version  => p_form_version,
                  p_adj_rec       => l_adj_rec,
                  p_adjustment_id => p_adjustment_id);


      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_process_adjustment.update_adj_cover()-',
                     pg_msg_level_debug);
      END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_process_adjustment.update_adj_cover()',
                   pg_msg_level_debug);
       arp_util.debug('------- parameters for update_adj_cover() ' ||
                   '---------',
                   pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_form_name                      = ' || p_form_name, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_form_version                   = ' || p_form_version, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_acctd_amount                   = '|| p_acctd_amount, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_adjustment_id                  = '|| p_adjustment_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_adjustment_number              = '|| p_adjustment_number, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_adjustment_type                = '|| p_adjustment_type, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_amount                         = '|| p_amount, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_apply_date                     = '|| p_apply_date, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_approved_by                    = '|| p_approved_by, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_associated_application_id      = '|| p_associated_application_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_associated_cash_receipt_id     = '|| p_associated_cash_receipt_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute1                     = '|| p_attribute1, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute10                    = '|| p_attribute10, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute11                    = '|| p_attribute11, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute12                    = '|| p_attribute12, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute13                    = '|| p_attribute13, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute14                    = '|| p_attribute14, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute15                    = '|| p_attribute15, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute2                     = '|| p_attribute2, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute3                     = '|| p_attribute3, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute4                     = '|| p_attribute4, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute5                     = '|| p_attribute5, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute6                     = '|| p_attribute6, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute7                     = '|| p_attribute7, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute8                     = '|| p_attribute8, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute9                     = '|| p_attribute9, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_attribute_category             = '|| p_attribute_category, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_automatically_generated        = '|| p_automatically_generated, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_batch_id                       = '|| p_batch_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_chargeback_customer_trx_id     = '|| p_chargeback_customer_trx_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_code_combination_id            = '|| p_code_combination_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_comments                       = '|| p_comments, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_created_by                     = '|| p_created_by, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_created_from                   = '|| p_created_from, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_creation_date                  = '|| p_creation_date, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_customer_trx_id                = '|| p_customer_trx_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_customer_trx_line_id           = '|| p_customer_trx_line_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_distribution_set_id            = '|| p_distribution_set_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_doc_sequence_id                = '|| p_doc_sequence_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_doc_sequence_value             = '|| p_doc_sequence_value, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_freight_adjusted               = '|| p_freight_adjusted, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_gl_date                        = '|| p_gl_date, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_gl_posted_date                 = '|| p_gl_posted_date, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_last_updated_by                = '|| p_last_updated_by, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_last_update_date               = '|| p_last_update_date, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_last_update_login              = '|| p_last_update_login, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_line_adjusted                  = '|| p_line_adjusted, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_org_id                         = '|| p_org_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_payment_schedule_id            = '|| p_payment_schedule_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_postable                       = '|| p_postable, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_posting_control_id             = '|| p_posting_control_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_program_application_id         = '|| p_program_application_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_program_id                     = '|| p_program_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_program_update_date            = '|| p_program_update_date, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_reason_code                    = '|| p_reason_code, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_receivables_charges_adjusted   = '|| p_receivables_charges_adjusted, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_receivables_trx_id             = '|| p_receivables_trx_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_request_id                     = '|| p_request_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_set_of_books_id                = '|| p_set_of_books_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_status                         = '|| p_status, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_subsequent_trx_id              = '|| p_subsequent_trx_id, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_tax_adjusted                   = '|| p_tax_adjusted, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_type                           = '|| p_type, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_ussgl_transaction_code         = '|| p_ussgl_transaction_code, pg_msg_level_debug);
       arp_util.debug('update_adj_cover: ' || 'p_ussgl_transaction_code_conte = '|| p_ussgl_transaction_code_conte, pg_msg_level_debug);
    END IF;




    RAISE;

END update_adj_cover;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

BEGIN

   pg_msg_level_debug := arp_global.MSG_LEVEL_DEBUG;

END ARP_UPDATE_adj_COVER;

/
