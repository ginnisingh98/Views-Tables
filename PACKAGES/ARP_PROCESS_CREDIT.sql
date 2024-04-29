--------------------------------------------------------
--  DDL for Package ARP_PROCESS_CREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_CREDIT" AUTHID CURRENT_USER AS
/* $Header: ARTECMRS.pls 120.2.12010000.1 2008/07/24 16:55:40 appldev ship $ */

TYPE credit_lines_type IS TABLE OF
     ra_customer_trx_lines.customer_trx_line_id%type
     INDEX BY BINARY_INTEGER;

pg_num_credit_lines     number;
pg_credit_lines         credit_lines_type;


PROCEDURE insert_header(
  p_form_name                   IN varchar2,
  p_form_version                IN number,
  p_trx_rec                     IN ra_customer_trx%rowtype,
  p_trx_class                   IN ra_cust_trx_types.type%type,
  p_gl_date                     IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_primary_salesrep_id         IN ra_salesreps.salesrep_id%type,
  p_currency_code               IN fnd_currencies.currency_code%type,
  p_prev_customer_trx_id        IN ra_customer_trx.customer_trx_id%type,
  p_line_percent                IN number,
  p_freight_pecent              IN number,
  p_line_amount                 IN ra_customer_trx_lines.extended_amount%type,
  p_freight_amount              IN ra_customer_trx_lines.extended_amount%type,
  p_compute_tax                 IN varchar2,
  p_trx_number                 OUT NOCOPY ra_customer_trx.trx_number%type,
  p_customer_trx_id            OUT NOCOPY ra_customer_trx.customer_trx_id%type,
  p_tax_percent             IN OUT NOCOPY number,
  p_tax_amount              IN OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_status                     OUT NOCOPY varchar2,
  p_submit_cm_dist              IN varchar2 DEFAULT 'N');

PROCEDURE update_header(
  p_form_name                   IN varchar2,
  p_form_version                IN number,
  p_customer_trx_id             IN ra_customer_trx.customer_trx_id%type,
  p_trx_rec                     IN OUT NOCOPY ra_customer_trx%rowtype,
  p_trx_class                   IN ra_cust_trx_types.type%type,
  p_gl_date                     IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_primary_salesrep_id         IN ra_salesreps.salesrep_id%type,
  p_currency_code               IN fnd_currencies.currency_code%type,
  p_prev_customer_trx_id        IN ra_customer_trx.customer_trx_id%type,
  p_line_percent                IN number,
  p_freight_pecent              IN number,
  p_line_amount                 IN ra_customer_trx_lines.extended_amount%type,
  p_freight_amount              IN ra_customer_trx_lines.extended_amount%type,
  p_credit_amount               IN ra_customer_trx_lines.extended_amount%type,
  p_cr_txn_invoicing_rule_id    IN ra_customer_trx.invoicing_rule_id%type,
  p_rederive_credit_info        IN varchar2,
  p_rerun_aa                    IN varchar2,
  p_rerun_cm_module             IN varchar2,
  p_compute_tax                 IN varchar2,
  p_tax_percent             IN OUT NOCOPY number,
  p_tax_amount              IN OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_status                     OUT NOCOPY varchar2);


PROCEDURE insert_line(
  p_form_name                   IN varchar2,
  p_form_version                IN number,
  p_credit_rec                  IN ra_customer_trx_lines%rowtype,
  p_line_amount                 IN ra_customer_trx_lines.extended_amount%type,
  p_freight_amount              IN ra_customer_trx_lines.extended_amount%type,
  p_line_percent                IN number,
  p_freight_percent             IN number,
  p_memo_line_type              IN ar_memo_lines.line_type%type,
  p_gl_date                     IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_currency_code               IN fnd_currencies.currency_code%type,
  p_primary_salesrep_id         IN ra_salesreps.salesrep_id%type,
  p_compute_tax                 IN varchar2,
  p_customer_trx_id             IN ra_customer_trx.customer_trx_id%type,
  p_prev_customer_trx_id        IN ra_customer_trx_lines.customer_trx_id%type,
  p_prev_customer_trx_line_id   IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
  p_tax_percent             IN OUT NOCOPY number,
  p_tax_amount              IN OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_customer_trx_line_id        OUT NOCOPY
                          ra_customer_trx_lines.customer_trx_line_id%type,
  p_status                     OUT NOCOPY varchar2);

PROCEDURE update_line(
  p_form_name                   IN varchar2,
  p_form_version                IN number,
  p_credit_rec                  IN ra_customer_trx_lines%rowtype,
  p_customer_trx_line_id        IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
  p_line_amount                 IN ra_customer_trx_lines.extended_amount%type,
  p_freight_amount              IN ra_customer_trx_lines.extended_amount%type,
  p_line_percent                IN number,
  p_freight_percent             IN number,
  p_memo_line_type              IN ar_memo_lines.line_type%type,
  p_gl_date                     IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_currency_code               IN fnd_currencies.currency_code%type,
  p_primary_salesrep_id         IN ra_salesreps.salesrep_id%type,
  p_exchange_rate               IN ra_customer_trx.exchange_rate%type,
  p_rerun_aa                    IN varchar2,
  p_recalculate_tax             IN varchar2,
  p_compute_tax                 IN varchar2,
  p_customer_trx_id             IN ra_customer_trx.customer_trx_id%type,
  p_prev_customer_trx_id        IN ra_customer_trx_lines.customer_trx_id%type,
  p_prev_customer_trx_line_id   IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
  p_tax_percent             IN OUT NOCOPY number,
  p_tax_amount              IN OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_status                     OUT NOCOPY varchar2);

PROCEDURE freight_post_update(
  p_frt_rec               IN ra_customer_trx_lines%rowtype,
  p_gl_date               IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_frt_ccid              IN
                           ra_cust_trx_line_gl_dist.code_combination_id%type);

PROCEDURE init;

END ARP_PROCESS_CREDIT;

/
