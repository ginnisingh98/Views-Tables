--------------------------------------------------------
--  DDL for Package ARP_INSERT_DIST_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_INSERT_DIST_COVER" AUTHID CURRENT_USER AS
/* $Header: ARTLGDIS.pls 115.3 2002/11/15 03:53:19 anukumar ship $ */

PROCEDURE insert_dist_cover(
           p_form_name                      IN varchar2,
           p_form_version                   IN number,
           p_exchange_rate                  IN
             ra_customer_trx.exchange_rate%type,
           p_base_currency_code             IN
             fnd_currencies.currency_code%type,
           p_base_precision                 IN
             fnd_currencies.precision%type,
           p_base_mau                       IN
             fnd_currencies.minimum_accountable_unit%type,
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
           p_acctd_amount                   IN
             ra_cust_trx_line_gl_dist.acctd_amount%type,
           p_gl_date                        IN
             ra_cust_trx_line_gl_dist.gl_date%type,
           p_original_gl_date               IN
             ra_cust_trx_line_gl_dist.original_gl_date%type,
           p_code_combination_id            IN
             ra_cust_trx_line_gl_dist.code_combination_id%type,
           p_concatenated_segments          IN
             ra_cust_trx_line_gl_dist.concatenated_segments%type,
	   p_collected_tax_ccid		    IN
	     ra_cust_trx_line_gl_dist.collected_tax_ccid%type,
	   p_collected_tax_concat_seg	    IN
	     ra_cust_trx_line_gl_dist.collected_tax_concat_seg%type,
           p_comments                       IN
             ra_cust_trx_line_gl_dist.comments%type,
           p_account_set_flag               IN
             ra_cust_trx_line_gl_dist.account_set_flag%type,
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
           p_cust_trx_line_gl_dist_id       OUT NOCOPY
             ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type);

END ARP_INSERT_DIST_COVER;

 

/
