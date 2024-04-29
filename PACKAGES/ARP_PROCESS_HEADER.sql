--------------------------------------------------------
--  DDL for Package ARP_PROCESS_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_HEADER" AUTHID CURRENT_USER AS
/* $Header: ARTEHEAS.pls 120.5.12010000.1 2008/07/24 16:56:07 appldev ship $ */

PROCEDURE insert_header(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_trx_rec               IN ra_customer_trx%rowtype,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_gl_date               IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_term_in_use_flag      IN varchar2,
  p_commitment_rec        IN arp_process_commitment.commitment_rec_type,
  p_trx_number           OUT NOCOPY ra_customer_trx.trx_number%type,
  p_customer_trx_id      OUT NOCOPY ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id OUT NOCOPY ra_customer_trx_lines.customer_trx_line_id%type,
  p_row_id               OUT NOCOPY rowid,
  p_status               OUT NOCOPY varchar2,
  p_receivable_ccid       IN gl_code_combinations.code_combination_id%type
                             DEFAULT NULL,
  p_run_autoacc_flag      IN varchar2  DEFAULT 'Y',
  p_create_default_sc_flag IN varchar2  DEFAULT 'Y'  );

PROCEDURE update_header(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_trx_rec               IN OUT NOCOPY ra_customer_trx%rowtype,
  p_customer_trx_id       IN ra_customer_trx.customer_trx_id%type,
  p_trx_amount            IN number,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_gl_date               IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_initial_customer_trx_line_id IN
         ra_customer_trx_lines.initial_customer_trx_line_id%type
         default null,
  p_commitment_rec        IN arp_process_commitment.commitment_rec_type,
  p_open_rec_flag         IN ra_cust_trx_types.accounting_affect_flag%type,
  p_term_in_use_flag      IN varchar2,
  p_recalc_tax_flag       IN boolean,
  p_rerun_autoacc_flag    IN boolean,
  p_ps_dispute_amount     IN NUMBER  DEFAULT NULL,
  p_ps_dispute_date       IN DATE    DEFAULT NULL,
  p_status               OUT NOCOPY varchar2);

PROCEDURE delete_header(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_customer_trx_id       IN number,
  p_trx_class             IN varchar2,
  p_status               OUT NOCOPY varchar2 );


PROCEDURE post_commit( p_form_name                    IN varchar2,
                       p_form_version                 IN number,
                       p_customer_trx_id              IN
                                      ra_customer_trx.customer_trx_id%type,
                       p_previous_customer_trx_id     IN
                               ra_customer_trx.previous_customer_trx_id%type,
                       p_complete_flag                IN
                               ra_customer_trx.complete_flag%type,
                       p_trx_open_receivables_flag    IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                       p_prev_open_receivables_flag   IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                       p_creation_sign                IN
                                 ra_cust_trx_types.creation_sign%type,
                       p_allow_overapplication_flag   IN
                             ra_cust_trx_types.allow_overapplication_flag%type,
                       p_natural_application_flag     IN
                          ra_cust_trx_types.natural_application_only_flag%type,
                       p_cash_receipt_id              IN
                          ar_cash_receipts.cash_receipt_id%type DEFAULT NULL
                     );

PROCEDURE update_header_freight_cover(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_customer_trx_id       IN ra_customer_trx.customer_trx_id%type,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_open_rec_flag         IN ra_cust_trx_types.accounting_affect_flag%type,
  p_ship_via              IN ra_customer_trx.ship_via%type,
  p_ship_date_actual      IN ra_customer_trx.ship_date_actual%type,
  p_waybill_number        IN ra_customer_trx.waybill_number%type,
  p_fob_point             IN ra_customer_trx.fob_point%type,
  p_status               OUT NOCOPY varchar2);


PROCEDURE post_query(
                      p_ct_rowid                        IN varchar2,
                      p_customer_trx_id                 IN NUMBER,
                      p_initial_customer_trx_id         IN NUMBER,
                      p_previous_customer_trx_id        IN NUMBER,
                      p_class                           IN varchar2,
                      p_ct_commitment_trx_date         OUT NOCOPY date,
                      p_ct_commitment_number           OUT NOCOPY varchar2,
                      p_gd_commitment_gl_date          OUT NOCOPY date,
                      p_ctl_commit_cust_trx_line_id    OUT NOCOPY number,
                      p_ctl_commitment_amount          OUT NOCOPY number,
                      p_ctl_commitment_text            OUT NOCOPY varchar2,
                      p_ctl_commitment_inv_item_id     OUT NOCOPY number,
                      p_interface_line_context         OUT NOCOPY varchar2,
                      p_interface_line_attribute1      OUT NOCOPY varchar2,
                      p_interface_line_attribute2      OUT NOCOPY varchar2,
                      p_interface_line_attribute3      OUT NOCOPY varchar2,
                      p_interface_line_attribute4      OUT NOCOPY varchar2,
                      p_interface_line_attribute5      OUT NOCOPY varchar2,
                      p_interface_line_attribute6      OUT NOCOPY varchar2,
                      p_interface_line_attribute7      OUT NOCOPY varchar2,
                      p_interface_line_attribute8      OUT NOCOPY varchar2,
                      p_interface_line_attribute9      OUT NOCOPY varchar2,
                      p_interface_line_attribute10     OUT NOCOPY varchar2,
                      p_interface_line_attribute11     OUT NOCOPY varchar2,
                      p_interface_line_attribute12     OUT NOCOPY varchar2,
                      p_interface_line_attribute13     OUT NOCOPY varchar2,
                      p_interface_line_attribute14     OUT NOCOPY varchar2,
                      p_interface_line_attribute15     OUT NOCOPY varchar2,
                      p_attribute_category             OUT NOCOPY varchar2,
                      p_attribute1                     OUT NOCOPY varchar2,
                      p_attribute2                     OUT NOCOPY varchar2,
                      p_attribute3                     OUT NOCOPY varchar2,
                      p_attribute4                     OUT NOCOPY varchar2,
                      p_attribute5                     OUT NOCOPY varchar2,
                      p_attribute6                     OUT NOCOPY varchar2,
                      p_attribute7                     OUT NOCOPY varchar2,
                      p_attribute8                     OUT NOCOPY varchar2,
                      p_attribute9                     OUT NOCOPY varchar2,
                      p_attribute10                    OUT NOCOPY varchar2,
                      p_attribute11                    OUT NOCOPY varchar2,
                      p_attribute12                    OUT NOCOPY varchar2,
                      p_attribute13                    OUT NOCOPY varchar2,
                      p_attribute14                    OUT NOCOPY varchar2,
                      p_attribute15                    OUT NOCOPY varchar2,
                      p_default_ussgl_trx_code         OUT NOCOPY varchar2,
                      p_ct_prev_trx_number             OUT NOCOPY varchar2,
                      p_ct_prev_trx_reference          OUT NOCOPY varchar2,
                      p_ct_prev_inv_currency_code      OUT NOCOPY varchar2,
                      p_ct_prev_trx_date               OUT NOCOPY date,
                      p_ct_prev_bill_to_customer_id    OUT NOCOPY number,
                      p_ct_prev_ship_to_customer_id    OUT NOCOPY number,
                      p_ct_prev_sold_to_customer_id    OUT NOCOPY number,
                      p_ct_prev_paying_customer_id     OUT NOCOPY number,
                      p_ct_prev_bill_to_site_use_id    OUT NOCOPY number,
                      p_ct_prev_ship_to_site_use_id    OUT NOCOPY number,
                      p_ct_prev_paying_site_use_id     OUT NOCOPY number,
                      p_ct_prev_bill_to_contact_id     OUT NOCOPY number,
                      p_ct_prev_ship_to_contact_id     OUT NOCOPY number,
                      p_ct_prev_initial_cust_trx_id    OUT NOCOPY number,
                      p_ct_prev_primary_salesrep_id    OUT NOCOPY number,
                      p_ct_prev_invoicing_rule_id      OUT NOCOPY number,
                      p_gd_prev_gl_date                OUT NOCOPY date,
                      p_prev_trx_original              OUT NOCOPY number,
                      p_prev_trx_balance               OUT NOCOPY number,
                      p_rac_prev_bill_to_cust_name     OUT NOCOPY varchar2,
                      p_rac_prev_bill_to_cust_num      OUT NOCOPY varchar2,
                      p_bs_prev_source_name            OUT NOCOPY varchar2,
                      p_ctt_prev_class                 OUT NOCOPY varchar2,
                      p_ctt_prev_allow_overapp_flag    OUT NOCOPY varchar2,
                      p_ctt_prev_natural_app_only      OUT NOCOPY varchar2,
                      p_ct_prev_open_receivables       OUT NOCOPY varchar2,
                      p_ct_prev_post_to_gl_flag        OUT NOCOPY varchar2,
                      p_al_cm_reason_meaning           OUT NOCOPY varchar2,
                      p_commit_memo_line_id            OUT NOCOPY number,
                      p_commit_memo_line_desc          OUT NOCOPY varchar2
                    );

PROCEDURE init;

END ARP_PROCESS_HEADER;

/
