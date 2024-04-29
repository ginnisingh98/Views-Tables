--------------------------------------------------------
--  DDL for Package ARP_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ADJUSTMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTIADJS.pls 120.4 2005/10/30 04:27:17 appldev ship $ */


  pg_user_id          number;

PROCEDURE set_to_dummy( p_adj_rec OUT NOCOPY ar_adjustments%rowtype);

PROCEDURE lock_p( p_adjustment_id IN ar_adjustments.adjustment_id%type
                );

PROCEDURE lock_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type );

PROCEDURE lock_f_st_id( p_subsequent_trx_id
                           IN ra_customer_trx.customer_trx_id%type );

PROCEDURE lock_f_ps_id( p_payment_schedule_id
                           IN ar_payment_schedules.payment_schedule_id%type );

PROCEDURE lock_f_ctl_id( p_customer_trx_line_id
                           IN ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE lock_fetch_p( p_adj_rec IN OUT NOCOPY ar_adjustments%rowtype,
                        p_adjustment_id IN
		ar_adjustments.adjustment_id%type);

PROCEDURE lock_compare_p( p_adj_rec IN ar_adjustments%rowtype,
                        p_adjustment_id IN ar_adjustments.adjustment_id%type);

PROCEDURE lock_compare_cover(
                              p_adjustment_id                   IN number,
                              p_amount                          IN number,
                              p_acctd_amount                    IN number,
                              p_apply_date                      IN date,
                              p_gl_date                         IN date,
                              p_gl_posted_date                  IN date,
                              p_set_of_books_id                 IN number,
                              p_code_combination_id             IN number,
                              p_type                            IN varchar2,
                              p_adjustment_type                 IN varchar2,
                              p_status                          IN varchar2,
                              p_line_adjusted                   IN number,
                              p_freight_adjusted                IN number,
                              p_tax_adjusted                    IN number,
                              p_receivables_charges_adj         IN number,
                              p_batch_id                        IN number,
                              p_customer_trx_id                 IN number,
                              p_subsequent_trx_id               IN number,
                              p_customer_trx_line_id            IN number,
                              p_associated_cash_receipt_id      IN number,
                              p_chargeback_customer_trx_id      IN number,
                              p_payment_schedule_id             IN number,
                              p_receivables_trx_id              IN number,
                              p_distribution_set_id             IN number,
                              p_associated_application_id       IN number,
                              p_comments                        IN varchar2,
                              p_automatically_generated         IN varchar2,
                              p_created_from                    IN varchar2,
                              p_reason_code                     IN varchar2,
                              p_postable                        IN varchar2,
                              p_approved_by                     IN number,
                              p_adjustment_number               IN varchar2,
                              p_doc_sequence_value              IN number,
                              p_doc_sequence_id                 IN number,
                              p_ussgl_transaction_code          IN varchar2,
                              p_ussgl_trans_code_context        IN varchar2,
                              p_attribute_category              IN varchar2,
                              p_attribute1                      IN varchar2,
                              p_attribute2                      IN varchar2,
                              p_attribute3                      IN varchar2,
                              p_attribute4                      IN varchar2,
                              p_attribute5                      IN varchar2,
                              p_attribute6                      IN varchar2,
                              p_attribute7                      IN varchar2,
                              p_attribute8                      IN varchar2,
                              p_attribute9                      IN varchar2,
                              p_attribute10                     IN varchar2,
                              p_attribute11                     IN varchar2,
                              p_attribute12                     IN varchar2,
                              p_attribute13                     IN varchar2,
                              p_attribute14                     IN varchar2,
                              p_attribute15                     IN varchar2,
                              p_posting_control_id              IN number,
                              p_last_updated_by                 IN number,
                              p_last_update_date                IN date,
                              p_last_update_login               IN number,
                              p_created_by                      IN number,
                              p_creation_date                   IN date,
                              p_program_application_id          IN number,
                              p_program_id                      IN number,
                              p_program_update_date             IN date,
                              p_request_id                      IN number );

PROCEDURE fetch_p( p_adj_rec         OUT NOCOPY ar_adjustments%rowtype,
                   p_adjustment_id    IN ar_adjustments.adjustment_id%type);

procedure delete_p( p_adjustment_id IN ar_adjustments.adjustment_id%type);

procedure delete_f_ct_id( p_customer_trx_id
                            IN ra_customer_trx.customer_trx_id%type);

procedure delete_f_st_id( p_subsequent_trx_id
                            IN ra_customer_trx.customer_trx_id%type);

procedure delete_f_ps_id( p_payment_schedule_id
                            IN ar_payment_schedules.payment_schedule_id%type);

procedure delete_f_ctl_id( p_customer_trx_line_id
                         IN ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE update_p( p_adj_rec IN ar_adjustments%rowtype,
                    p_adjustment_id  IN  ar_adjustments.adjustment_id%type,
                    p_exchange_rate  IN ar_payment_schedules.exchange_rate%type
                  );

PROCEDURE update_f_ct_id( p_adj_rec IN ar_adjustments%rowtype,
                 p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type,
                 p_exchange_rate  IN ar_payment_schedules.exchange_rate%type);

PROCEDURE update_f_st_id( p_adj_rec IN ar_adjustments%rowtype,
                 p_subsequent_trx_id  IN ra_customer_trx.customer_trx_id%type,
                 p_exchange_rate  IN ar_payment_schedules.exchange_rate%type);

PROCEDURE update_f_ps_id( p_adj_rec              IN ar_adjustments%rowtype,
                          p_payment_schedule_id  IN
                              ar_payment_schedules.payment_schedule_id%type,
                          p_exchange_rate        IN
                              ar_payment_schedules.exchange_rate%type);

PROCEDURE update_f_ctl_id( p_adj_rec IN ar_adjustments%rowtype,
                           p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                           p_exchange_rate         IN
                               ar_payment_schedules.exchange_rate%type);


PROCEDURE insert_p( p_adj_rec            IN  ar_adjustments%rowtype,
                    p_exchange_rate      IN
                      ar_payment_schedules.exchange_rate%type,
                    p_adjustment_number OUT NOCOPY
                      ar_adjustments.adjustment_number%type,
                    p_adjustment_id     OUT NOCOPY  ar_adjustments.adjustment_id%type

                  );

PROCEDURE  merge_adj_recs( p_old_adj_rec    IN  ar_adjustments%rowtype,
                           p_new_adj_rec    IN  ar_adjustments%rowtype,
                           p_out_adj_rec   OUT NOCOPY  ar_adjustments%rowtype );

PROCEDURE display_adj_rec(
            p_adj_rec IN ar_adjustments%rowtype);

PROCEDURE display_adj_p(p_adjustment_id IN ar_adjustments.adjustment_id%type);

FUNCTION get_text_dummy(p_null IN NUMBER DEFAULT null) RETURN varchar2;

END ARP_ADJUSTMENTS_PKG;

 

/
