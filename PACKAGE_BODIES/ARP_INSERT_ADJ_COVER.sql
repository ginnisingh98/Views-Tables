--------------------------------------------------------
--  DDL for Package Body ARP_INSERT_ADJ_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_INSERT_ADJ_COVER" AS
/* $Header: ARTADJIB.pls 120.2.12010000.2 2008/11/17 13:13:15 pbapna ship $ */

pg_msg_level_debug    binary_integer;

PROCEDURE INSERT_ADJUST_COVER(
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
              ar_adjustments.ussgl_transaction_code_context%type,
           p_override_flag                IN
              varchar2 DEFAULT NULL,
           p_adjustment_number_o OUT NOCOPY
              ar_adjustments.adjustment_number%type,
           p_adjustment_id_o OUT NOCOPY
              ar_adjustments.adjustment_id%type,
           p_app_level IN VARCHAR2 DEFAULT 'TRANSACTION')
IS
      l_adj_rec ar_adjustments%rowtype ;
      l_app_level VARCHAR2(30) := 'TRANSACTION';

BEGIN

      arp_util.debug('arp_process_adjustment.insert_adjust_cover()+',
                      pg_msg_level_debug);

     /*-----------------------------------------+
      |  Populate the dist record group with    |
      |  the values passed in as parameters.    |
      +-----------------------------------------*/

      l_adj_rec.acctd_amount                   := p_acctd_amount;
      l_adj_rec.adjustment_id                  := p_adjustment_id;
      l_adj_rec.adjustment_number              := p_adjustment_number;
      l_adj_rec.adjustment_type                := p_adjustment_type;
      l_adj_rec.amount                         := p_amount;
      l_adj_rec.apply_date                     := p_apply_date;
      l_adj_rec.approved_by                    := p_approved_by;
      l_adj_rec.associated_application_id      := p_associated_application_id;
      l_adj_rec.associated_cash_receipt_id     := p_associated_cash_receipt_id;
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
      l_adj_rec.automatically_generated        := p_automatically_generated;
      l_adj_rec.batch_id                       := p_batch_id;
      l_adj_rec.chargeback_customer_trx_id     := p_chargeback_customer_trx_id;
      l_adj_rec.code_combination_id            := p_code_combination_id;
      l_adj_rec.comments                       := p_comments;
      l_adj_rec.created_by                     := p_created_by;
      l_adj_rec.created_from                   := p_created_from;
      l_adj_rec.creation_date                  := p_creation_date;
      l_adj_rec.customer_trx_id                := p_customer_trx_id;
      l_adj_rec.customer_trx_line_id           := p_customer_trx_line_id;
      l_adj_rec.distribution_set_id            := p_distribution_set_id;
      l_adj_rec.doc_sequence_id                := p_doc_sequence_id;
      l_adj_rec.doc_sequence_value             := p_doc_sequence_value;
      l_adj_rec.freight_adjusted               := p_freight_adjusted;
      l_adj_rec.gl_date                        := p_gl_date;
      l_adj_rec.gl_posted_date                 := p_gl_posted_date;
      l_adj_rec.last_updated_by                := p_last_updated_by;
      l_adj_rec.last_update_date               := p_last_update_date;
      l_adj_rec.last_update_login              := p_last_update_login;
      l_adj_rec.line_adjusted                  := p_line_adjusted;
      l_adj_rec.org_id                         := p_org_id;
      l_adj_rec.payment_schedule_id            := p_payment_schedule_id;
      l_adj_rec.postable                       := p_postable;
      l_adj_rec.posting_control_id             := p_posting_control_id;
      l_adj_rec.program_application_id         := p_program_application_id;
      l_adj_rec.program_id                     := p_program_id;
      l_adj_rec.program_update_date            := p_program_update_date;
      l_adj_rec.reason_code                    := p_reason_code;
      l_adj_rec.receivables_charges_adjusted    := p_receivables_charges_adjusted;
      l_adj_rec.receivables_trx_id             := p_receivables_trx_id;
      l_adj_rec.request_id                     := p_request_id;
      l_adj_rec.set_of_books_id                := p_set_of_books_id;
      l_adj_rec.status                         := p_status;
      l_adj_rec.subsequent_trx_id              := p_subsequent_trx_id;
      l_adj_rec.tax_adjusted                   := p_tax_adjusted;
      l_adj_rec.type                           := p_type;
      l_adj_rec.ussgl_transaction_code         := p_ussgl_transaction_code;
      l_adj_rec.ussgl_transaction_code_context := p_ussgl_transaction_code_conte;

     /*----------------------------------------+
      |  Call the standard dist entity handler |
      +----------------------------------------*/

--Bug 1686556: Passing the parameter p_override_flag also
-- Bug 7031612 LLCA Adjustment UI changes
IF l_adj_rec.customer_trx_line_id IS NOT NULL THEN
   l_app_level := 'LINE';
END IF;
      arp_process_adjustment.insert_adjustment(
                   p_form_name		=>	p_form_name,
                   p_form_version	=>	p_form_version,
                   p_adj_rec		=>	l_adj_rec,
                   p_adjustment_number	=>	p_adjustment_number_o,
                   p_adjustment_id	=>	p_adjustment_id_o,
                   p_override_flag	=>	p_override_flag,
                   p_app_level          =>      l_app_level
                   );

      arp_util.debug('arp_process_adjustment.insert_adj_cover()-',
                      pg_msg_level_debug);


EXCEPTION
  WHEN OTHERS THEN

    arp_util.debug('EXCEPTION:  arp_process_adjustment.insert_adjust_cover()');

    arp_util.debug('------- parameters for insert_adjust_cover() ' ||
                   '---------');

    arp_util.debug('p_form_name                      = ' || p_form_name);
    arp_util.debug('p_form_version                   = ' || p_form_version);
    arp_util.debug('p_acctd_amount                   = '|| p_acctd_amount);
    arp_util.debug('p_adjustment_id                  = '|| p_adjustment_id);
    arp_util.debug('p_adjustment_number              = '|| p_adjustment_number);
    arp_util.debug('p_adjustment_type                = '|| p_adjustment_type);
    arp_util.debug('p_amount                         = '|| p_amount);
    arp_util.debug('p_apply_date                     = '|| p_apply_date);
    arp_util.debug('p_approved_by                    = '|| p_approved_by);
    arp_util.debug('p_associated_application_id      = '|| p_associated_application_id);
    arp_util.debug('p_associated_cash_receipt_id     = '|| p_associated_cash_receipt_id);
    arp_util.debug('p_attribute1                     = '|| p_attribute1);
    arp_util.debug('p_attribute10                    = '|| p_attribute10);
    arp_util.debug('p_attribute11                    = '|| p_attribute11);
    arp_util.debug('p_attribute12                    = '|| p_attribute12);
    arp_util.debug('p_attribute13                    = '|| p_attribute13);
    arp_util.debug('p_attribute14                    = '|| p_attribute14);
    arp_util.debug('p_attribute15                    = '|| p_attribute15);
    arp_util.debug('p_attribute2                     = '|| p_attribute2);
    arp_util.debug('p_attribute3                     = '|| p_attribute3);
    arp_util.debug('p_attribute4                     = '|| p_attribute4);
    arp_util.debug('p_attribute5                     = '|| p_attribute5);
    arp_util.debug('p_attribute6                     = '|| p_attribute6);
    arp_util.debug('p_attribute7                     = '|| p_attribute7);
    arp_util.debug('p_attribute8                     = '|| p_attribute8);
    arp_util.debug('p_attribute9                     = '|| p_attribute9);
    arp_util.debug('p_attribute_category             = '|| p_attribute_category);
    arp_util.debug('p_automatically_generated        = '|| p_automatically_generated);
    arp_util.debug('p_batch_id                       = '|| p_batch_id);
    arp_util.debug('p_chargeback_customer_trx_id     = '|| p_chargeback_customer_trx_id);
    arp_util.debug('p_code_combination_id            = '|| p_code_combination_id);
    arp_util.debug('p_comments                       = '|| p_comments);
    arp_util.debug('p_created_by                     = '|| p_created_by);
    arp_util.debug('p_created_from                   = '|| p_created_from);
    arp_util.debug('p_creation_date                  = '|| p_creation_date);
    arp_util.debug('p_customer_trx_id                = '|| p_customer_trx_id);
    arp_util.debug('p_customer_trx_line_id           = '|| p_customer_trx_line_id);
    arp_util.debug('p_distribution_set_id            = '|| p_distribution_set_id);
    arp_util.debug('p_doc_sequence_id                = '|| p_doc_sequence_id);
    arp_util.debug('p_doc_sequence_value             = '|| p_doc_sequence_value);
    arp_util.debug('p_freight_adjusted               = '|| p_freight_adjusted);
    arp_util.debug('p_gl_date                        = '|| p_gl_date);
    arp_util.debug('p_gl_posted_date                 = '|| p_gl_posted_date);
    arp_util.debug('p_last_updated_by                = '|| p_last_updated_by);
    arp_util.debug('p_last_update_date               = '|| p_last_update_date);
    arp_util.debug('p_last_update_login              = '|| p_last_update_login);
    arp_util.debug('p_line_adjusted                  = '|| p_line_adjusted);
    arp_util.debug('p_org_id                         = '|| p_org_id);
    arp_util.debug('p_payment_schedule_id            = '|| p_payment_schedule_id);
    arp_util.debug('p_postable                       = '|| p_postable);
    arp_util.debug('p_posting_control_id             = '|| p_posting_control_id);
    arp_util.debug('p_program_application_id         = '|| p_program_application_id);
    arp_util.debug('p_program_id                     = '|| p_program_id);
    arp_util.debug('p_program_update_date            = '|| p_program_update_date);
    arp_util.debug('p_reason_code                    = '|| p_reason_code);
    arp_util.debug('p_receivables_charges_adjusted   = '|| p_receivables_charges_adjusted);
    arp_util.debug('p_receivables_trx_id             = '|| p_receivables_trx_id);
    arp_util.debug('p_request_id                     = '|| p_request_id);
    arp_util.debug('p_set_of_books_id                = '|| p_set_of_books_id);
    arp_util.debug('p_status                         = '|| p_status);
    arp_util.debug('p_subsequent_trx_id              = '|| p_subsequent_trx_id);
    arp_util.debug('p_tax_adjusted                   = '|| p_tax_adjusted);
    arp_util.debug('p_type                           = '|| p_type);
    arp_util.debug('p_ussgl_transaction_code         = '|| p_ussgl_transaction_code);
    arp_util.debug('p_ussgl_transaction_code_conte = '|| p_ussgl_transaction_code_conte);
    arp_util.debug('p_app_level = '|| l_app_level);
    RAISE;

END insert_adjust_cover;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

 BEGIN

   pg_msg_level_debug := arp_global.MSG_LEVEL_DEBUG;

END ARP_INSERT_ADJ_COVER;

/
