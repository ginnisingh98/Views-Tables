--------------------------------------------------------
--  DDL for Package ARP_INSERT_ADJ_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_INSERT_ADJ_COVER" AUTHID CURRENT_USER AS
/* $Header: ARTADJIS.pls 120.2 2005/08/29 21:21:21 djancis ship $ */

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
           p_app_level  IN  VARCHAR2 DEFAULT 'TRANSACTION') ;

END ARP_INSERT_ADJ_COVER;

 

/
