--------------------------------------------------------
--  DDL for Package ARP_CTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTITLSS.pls 120.6.12010000.1 2008/07/24 16:57:04 appldev ship $ */

PROCEDURE select_summary(p_customer_trx_id       IN      number,
                         p_customer_trx_line_id  IN      number,
                         p_mode                  IN      varchar2,
                         p_amount_total          IN OUT NOCOPY  number,
                         p_amount_total_rtot_db  IN OUT NOCOPY  number,
                         p_percent_total         IN OUT NOCOPY  number,
                         p_percent_total_rtot_db IN OUT NOCOPY  number );

PROCEDURE display_salescredit(  p_cust_trx_line_salesrep_id IN
 		   ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type);

PROCEDURE display_salescredit_rec(  p_srep_rec IN
                                          ra_cust_trx_line_salesreps%rowtype);

PROCEDURE display_salescredit_f_ctl_id(  p_customer_trx_line_id IN
                         ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE set_to_dummy( p_srep_rec OUT NOCOPY ra_cust_trx_line_salesreps%rowtype);

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number;

PROCEDURE lock_p( p_cust_trx_line_salesrep_id
                 IN ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type);

PROCEDURE lock_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type );

PROCEDURE lock_f_ctl_id( p_customer_trx_line_id
                           IN ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE lock_fetch_p( p_srep_rec IN OUT NOCOPY ra_cust_trx_line_salesreps%rowtype,
                        p_cust_trx_line_salesrep_id IN
		ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type);

PROCEDURE lock_compare_p( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                          p_cust_trx_line_salesrep_id IN
                  ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                          p_ignore_who_flag BOOLEAN DEFAULT FALSE);

PROCEDURE fetch_p( p_srep_rec         OUT NOCOPY ra_cust_trx_line_salesreps%rowtype,
                   p_cust_trx_line_salesrep_id IN
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type);

procedure delete_p( p_cust_trx_line_salesrep_id
                IN ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                    p_customer_trx_line_id
                IN ra_customer_trx_lines.customer_trx_line_id%type  );

procedure delete_f_ct_id( p_customer_trx_id
                         IN ra_customer_trx.customer_trx_id%type,
                         p_delete_default_recs_flag IN boolean DEFAULT TRUE);

procedure delete_f_ctl_id( p_customer_trx_line_id
                         IN ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE update_p( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                    p_cust_trx_line_salesrep_id  IN
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type);

PROCEDURE update_f_ct_id( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                   p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type);

PROCEDURE update_f_ctl_id( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                           p_customer_trx_line_id  IN
                             ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE update_f_psr_id( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                           p_prev_cust_trx_line_srep_id
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type);

PROCEDURE update_amounts_f_ctl_id(
                             p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                             p_line_amount           IN
                               ra_customer_trx_lines.extended_amount%type,
                             p_foreign_currency_code IN
                                            fnd_currencies.currency_code%type);

PROCEDURE insert_p(
             p_srep_rec          IN ra_cust_trx_line_salesreps%rowtype,
             p_cust_trx_line_salesrep_id
                  OUT NOCOPY ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type
                  );

PROCEDURE insert_f_ct_ctl_id(
                          p_customer_trx_id IN
                              ra_customer_trx_lines.customer_trx_id%type,
                          p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type
                         );

PROCEDURE insert_f_cm_ct_ctl_id(
                          p_customer_trx_id IN
                              ra_customer_trx.customer_trx_id%type,
                          p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
                          p_currency_code IN fnd_currencies.currency_code%type
                         );
PROCEDURE insert_f_cmn_ct_ctl_id(
                          p_customer_trx_id      IN
                                ra_customer_trx.customer_trx_id%type,
                          p_customer_trx_line_id IN
                               ra_customer_trx_lines.customer_trx_line_id%type
                        );
PROCEDURE merge_srep_recs(
                         p_old_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                         p_new_srep_rec IN
                                          ra_cust_trx_line_salesreps%rowtype,
                         p_out_srep_rec IN OUT NOCOPY
                                          ra_cust_trx_line_salesreps%rowtype);

PROCEDURE erase_foreign_key_references( p_cust_trx_line_salesrep_id IN
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                                        p_customer_trx_id IN
                                          ra_customer_trx.customer_trx_id%type,
                                        p_customer_trx_line_id IN
                    ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE lock_compare_cover(
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id                 IN
                         ra_cust_trx_line_salesreps.customer_trx_id%type,
           p_customer_trx_line_id            IN
                         ra_cust_trx_line_salesreps.customer_trx_line_id%type,
           p_salesrep_id                     IN
                         ra_cust_trx_line_salesreps.salesrep_id%type,
           p_revenue_amount_split            IN
                         ra_cust_trx_line_salesreps.revenue_amount_split%type,
           p_non_revenue_amount_split        IN
                     ra_cust_trx_line_salesreps.non_revenue_amount_split%type,
           p_non_revenue_percent_split       IN
                    ra_cust_trx_line_salesreps.non_revenue_percent_split%type,
           p_revenue_percent_split           IN
                    ra_cust_trx_line_salesreps.revenue_percent_split%type,
           p_prev_cust_trx_line_srep_id      IN
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type,
           p_attribute_category              IN
                    ra_cust_trx_line_salesreps.attribute_category%type,
           p_attribute1                      IN
                    ra_cust_trx_line_salesreps.attribute1%type,
           p_attribute2                      IN
                    ra_cust_trx_line_salesreps.attribute2%type,
           p_attribute3                      IN
                    ra_cust_trx_line_salesreps.attribute3%type,
           p_attribute4                      IN
                    ra_cust_trx_line_salesreps.attribute4%type,
           p_attribute5                      IN
                    ra_cust_trx_line_salesreps.attribute5%type,
           p_attribute6                      IN
                    ra_cust_trx_line_salesreps.attribute6%type,
           p_attribute7                      IN
                    ra_cust_trx_line_salesreps.attribute7%type,
           p_attribute8                      IN
                    ra_cust_trx_line_salesreps.attribute8%type,
           p_attribute9                      IN
                    ra_cust_trx_line_salesreps.attribute9%type,
           p_attribute10                     IN
                    ra_cust_trx_line_salesreps.attribute10%type,
           p_attribute11                     IN
                    ra_cust_trx_line_salesreps.attribute11%type,
           p_attribute12                     IN
                    ra_cust_trx_line_salesreps.attribute12%type,
           p_attribute13                     IN
                    ra_cust_trx_line_salesreps.attribute13%type,
           p_attribute14                     IN
                    ra_cust_trx_line_salesreps.attribute14%type,
           p_attribute15                     IN
                    ra_cust_trx_line_salesreps.attribute15%type,
           p_revenue_salesgroup_id           IN
                         ra_cust_trx_line_salesreps.revenue_salesgroup_id%type DEFAULT null,
           p_non_revenue_salesgroup_id       IN
                         ra_cust_trx_line_salesreps.non_revenue_salesgroup_id%type DEFAULT null);

PROCEDURE init;

END ARP_CTLS_PKG;

/
