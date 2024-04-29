--------------------------------------------------------
--  DDL for Package ARP_CTLGD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CTLGD_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTILGDS.pls 120.4.12010000.2 2009/09/14 11:20:53 rasarasw ship $ */

PROCEDURE set_to_dummy( p_dist_rec OUT NOCOPY ra_cust_trx_line_gl_dist%rowtype);


PROCEDURE lock_p( p_cust_trx_line_gl_dist_id
                 IN ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type);

PROCEDURE lock_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type);

PROCEDURE lock_f_ctl_id( p_customer_trx_line_id
                           IN ra_customer_trx_lines.customer_trx_line_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type);

PROCEDURE lock_f_ctls_id( p_cust_trx_line_salesrep_id
                   IN ra_cust_trx_line_gl_dist.cust_trx_line_salesrep_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type);

PROCEDURE lock_fetch_p( p_dist_rec IN OUT NOCOPY ra_cust_trx_line_gl_dist%rowtype,
                        p_cust_trx_line_gl_dist_id IN
		ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type);

PROCEDURE lock_compare_p( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                          p_cust_trx_line_gl_dist_id IN
                  ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
                          p_ignore_who_flag BOOLEAN DEFAULT FALSE);

PROCEDURE lock_compare_cover(
           p_cust_trx_line_gl_dist_id       IN
             ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
           p_customer_trx_id                IN
             ra_cust_trx_line_gl_dist.customer_trx_id%type,
           p_customer_trx_line_id           IN
             ra_cust_trx_line_gl_dist.customer_trx_line_id %type,
           p_cust_trx_line_salesrep_id      IN
             ra_cust_trx_line_gl_dist.cust_trx_line_salesrep_id%type,
           p_account_class                  IN
             ra_cust_trx_line_gl_dist.account_class%type,
           p_percent                        IN
             ra_cust_trx_line_gl_dist.percent%type,
           p_amount                         IN
             ra_cust_trx_line_gl_dist.amount%type,
           p_gl_date                        IN
             ra_cust_trx_line_gl_dist.gl_date%type,
           p_original_gl_date               IN
             ra_cust_trx_line_gl_dist.original_gl_date%type,
           p_gl_posted_date                 IN
             ra_cust_trx_line_gl_dist.gl_posted_date%type,
           p_code_combination_id            IN
             ra_cust_trx_line_gl_dist.code_combination_id%type,
           p_concatenated_segments          IN
             ra_cust_trx_line_gl_dist.concatenated_segments%type,
           p_collected_tax_ccid             IN
             ra_cust_trx_line_gl_dist.collected_tax_ccid%type,
           p_collected_tax_concat_seg       IN
             ra_cust_trx_line_gl_dist.collected_tax_concat_seg%type,
           p_comments                       IN
             ra_cust_trx_line_gl_dist.comments%type,
           p_account_set_flag               IN
             ra_cust_trx_line_gl_dist.account_set_flag%type,
           p_latest_rec_flag                IN
             ra_cust_trx_line_gl_dist.latest_rec_flag%type,
           p_ussgl_transaction_code         IN
             ra_cust_trx_line_gl_dist.ussgl_transaction_code%type,
           p_ussgl_trx_code_context         IN
             ra_cust_trx_line_gl_dist.ussgl_transaction_code_context%type,
           p_attribute_category             IN
             ra_cust_trx_line_gl_dist.attribute_category%type,
           p_attribute1                     IN
             ra_cust_trx_line_gl_dist.attribute1%type,
           p_attribute2                     IN
             ra_cust_trx_line_gl_dist.attribute2%type,
           p_attribute3                     IN
             ra_cust_trx_line_gl_dist.attribute3%type,
           p_attribute4                     IN
             ra_cust_trx_line_gl_dist.attribute4%type,
           p_attribute5                     IN
             ra_cust_trx_line_gl_dist.attribute5%type,
           p_attribute6                     IN
             ra_cust_trx_line_gl_dist.attribute6%type,
           p_attribute7                     IN
             ra_cust_trx_line_gl_dist.attribute7%type,
           p_attribute8                     IN
             ra_cust_trx_line_gl_dist.attribute8%type,
           p_attribute9                     IN
             ra_cust_trx_line_gl_dist.attribute9%type,
           p_attribute10                    IN
             ra_cust_trx_line_gl_dist.attribute10%type,
           p_attribute11                    IN
             ra_cust_trx_line_gl_dist.attribute11%type,
           p_attribute12                    IN
             ra_cust_trx_line_gl_dist.attribute12%type,
           p_attribute13                    IN
             ra_cust_trx_line_gl_dist.attribute13%type,
           p_attribute14                    IN
             ra_cust_trx_line_gl_dist.attribute14%type,
           p_attribute15                    IN
             ra_cust_trx_line_gl_dist.attribute15%type,
           p_posting_control_id             IN
             ra_cust_trx_line_gl_dist.posting_control_id%type,
           p_ccid_change_flag               IN
             ra_cust_trx_line_gl_dist.ccid_change_flag%type   ); /* Bug 8788491 */

PROCEDURE fetch_p( p_dist_rec         OUT NOCOPY ra_cust_trx_line_gl_dist%rowtype,
                   p_cust_trx_line_gl_dist_id IN
                     ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type);

procedure delete_p( p_cust_trx_line_gl_dist_id
                IN ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type);

procedure delete_f_ct_id( p_customer_trx_id
                         IN ra_customer_trx.customer_trx_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type);

procedure delete_f_ctl_id( p_customer_trx_line_id
                         IN ra_customer_trx_lines.customer_trx_line_id%type,
                        p_account_set_flag
                           IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                        p_account_class
                           IN ra_cust_trx_line_gl_dist.account_class%type);

procedure delete_f_ctls_id( p_cust_trx_line_salesrep_id
                  IN ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                            p_account_set_flag
                             IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                            p_account_class
                               IN ra_cust_trx_line_gl_dist.account_class%type);

PROCEDURE delete_f_ct_ltctl_id_type(
             p_customer_trx_id          IN
                            ra_customer_trx.customer_trx_id%type,
             p_link_to_cust_trx_line_id IN
                            ra_customer_trx_lines.link_to_cust_trx_line_id%type,
             p_line_type                IN
                            ra_customer_trx_lines.line_type%type,
             p_account_set_flag         IN
                            ra_cust_trx_line_gl_dist.account_set_flag%type,
             p_account_class            IN
                            ra_cust_trx_line_gl_dist.account_class%type);

PROCEDURE update_p( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                    p_cust_trx_line_gl_dist_id  IN
                     ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
                    p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                       DEFAULT 1,
                    p_currency_code IN fnd_currencies.currency_code%type
                                       DEFAULT null,
                    p_precision     IN fnd_currencies.precision%type
                                       DEFAULT null,
                    p_mau           IN
                                 fnd_currencies.minimum_accountable_unit%type
                                       DEFAULT null);

PROCEDURE update_f_ct_id( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                    p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type,
                    p_account_set_flag
                         IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                    p_account_class
                         IN ra_cust_trx_line_gl_dist.account_class%type,
                    p_exchange_rate IN ra_customer_trx.exchange_rate%type
     				       DEFAULT 1,
                    p_currency_code IN fnd_currencies.currency_code%type
 				       DEFAULT null,
                    p_precision     IN fnd_currencies.precision%type
                                       DEFAULT null,
                    p_mau           IN
                                 fnd_currencies.minimum_accountable_unit%type
                                       DEFAULT null);

PROCEDURE update_f_ctl_id(
                         p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                         p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                         p_account_set_flag
                             IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                         p_account_class
                              IN ra_cust_trx_line_gl_dist.account_class%type,
                         p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                            DEFAULT 1,
                         p_currency_code IN fnd_currencies.currency_code%type
                                            DEFAULT null,
                         p_precision     IN fnd_currencies.precision%type
                                            DEFAULT null,
                         p_mau           IN
                                 fnd_currencies.minimum_accountable_unit%type
                                            DEFAULT null);

PROCEDURE update_f_ctls_id(
                         p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                         p_cust_trx_line_salesrep_id  IN
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                         p_account_set_flag
                             IN ra_cust_trx_line_gl_dist.account_set_flag%type,
                         p_account_class
                               IN ra_cust_trx_line_gl_dist.account_class%type,
                         p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                            DEFAULT 1,
                         p_currency_code IN fnd_currencies.currency_code%type
                                            DEFAULT null,
                         p_precision     IN fnd_currencies.precision%type
                                            DEFAULT null,
                         p_mau           IN
                                 fnd_currencies.minimum_accountable_unit%type
                                            DEFAULT null);

PROCEDURE update_acctd_amount(p_customer_trx_id IN number,
                              p_base_curr_code IN
                                fnd_currencies.currency_code%type,
                              p_exchange_rate IN
                                ra_customer_trx.exchange_rate%type,
                              p_base_precision IN
                                fnd_currencies.precision%type
                                default null,
                              p_base_min_acc_unit IN
                                fnd_currencies.minimum_accountable_unit%type
                                default null);

PROCEDURE update_amount_f_ctl_id(p_customer_trx_line_id IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                              p_line_amount IN
                                ra_customer_trx_lines.extended_amount%type,
                              p_foreign_currency_code IN
				fnd_currencies.currency_code%type,
                              p_base_curr_code IN
                                fnd_currencies.currency_code%type,
                              p_exchange_rate IN
                                ra_customer_trx.exchange_rate%type,
                              p_base_precision IN
                                fnd_currencies.precision%type
                                default null,
                              p_base_min_acc_unit IN
                                fnd_currencies.minimum_accountable_unit%type
                                default null);

PROCEDURE insert_p(
             p_dist_rec          IN ra_cust_trx_line_gl_dist%rowtype,
             p_cust_trx_line_gl_dist_id
                  OUT NOCOPY ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
             p_exchange_rate IN ra_customer_trx.exchange_rate%type
                                DEFAULT 1,
             p_currency_code IN fnd_currencies.currency_code%type
                                DEFAULT null,
             p_precision     IN fnd_currencies.precision%type
                                DEFAULT null,
             p_mau           IN fnd_currencies.minimum_accountable_unit%type
                                DEFAULT null
                  );

PROCEDURE display_dist_rec( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype);

PROCEDURE display_dist_p(  p_cust_trx_line_gl_dist_id IN
 		   ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type);

PROCEDURE display_dist_f_ctls_id(  p_cust_trx_line_salesrep_id IN
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type);

PROCEDURE display_dist_f_ct_id( p_customer_trx_id IN
                                         ra_customer_trx.customer_trx_id%type);

PROCEDURE display_dist_f_ctl_id( p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE merge_dist_recs(
                         p_old_dist_rec IN ra_cust_trx_line_gl_dist%rowtype,
                         p_new_dist_rec IN
                                          ra_cust_trx_line_gl_dist%rowtype,
                         p_out_dist_rec IN OUT NOCOPY
                                          ra_cust_trx_line_gl_dist%rowtype
                         );

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN NUMBER;

PROCEDURE select_summary(
                         p_customer_trx_id             IN      number,
                         p_customer_trx_line_id        IN      number,
                         p_cust_trx_line_salesrep_id   IN      number,
                         p_mode                        IN      varchar2,
                         p_account_set_flag            IN      varchar2,
                         p_amt_total                   IN OUT NOCOPY  number,
                         p_amt_total_rtot_db           IN OUT NOCOPY  number,
                         p_pct_total                   IN OUT NOCOPY  number,
                         p_pct_total_rtot_db           IN OUT NOCOPY  number,
                         p_pct_rev_total               IN OUT NOCOPY  number,
                         p_pct_rev_total_rtot_db       IN OUT NOCOPY  number,
                         p_pct_offset_total            IN OUT NOCOPY  number,
                         p_pct_offset_total_rtot_db    IN OUT NOCOPY  number,
                         p_pct_suspense_total          IN OUT NOCOPY  number,
                         p_pct_suspense_total_rtot_db  IN OUT NOCOPY  number );

END ARP_CTLGD_PKG;

/
