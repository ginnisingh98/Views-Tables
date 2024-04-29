--------------------------------------------------------
--  DDL for Package ARP_PROCESS_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_DIST" AUTHID CURRENT_USER AS
/* $Header: ARTELGDS.pls 120.1 2005/07/26 15:46:18 naneja noship $ */


PROCEDURE insert_dist(
           p_form_name         IN varchar2,
           p_form_version      IN number,
           p_dist_rec	       IN ra_cust_trx_line_gl_dist%rowtype,
           p_exchange_rate     IN ra_customer_trx.exchange_rate%type DEFAULT 1,
           p_currency_code     IN fnd_currencies.currency_code%type DEFAULT null,
           p_precision         IN fnd_currencies.precision%type DEFAULT null,
           p_mau               IN fnd_currencies.minimum_accountable_unit%type DEFAULT null,
           p_cust_trx_line_gl_dist_id  OUT NOCOPY
              ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type);

PROCEDURE update_dist(
           p_form_name                 IN varchar2,
           p_form_version              IN number,
           p_backout_flag              IN boolean,
           p_cust_trx_line_gl_dist_id  IN
                    ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
           p_customer_trx_id	       IN ra_customer_trx.customer_trx_id%type,
           p_dist_rec		       IN OUT NOCOPY ra_cust_trx_line_gl_dist%rowtype,
           p_header_gl_date            IN date,
           p_trx_date                  IN date,
           p_invoicing_rule_id         IN
                    ra_customer_trx.invoicing_rule_id%type,
           p_backout_done_flag         OUT NOCOPY boolean,
           p_exchange_rate             IN ra_customer_trx.exchange_rate%type
                                          DEFAULT 1,
           p_currency_code             IN fnd_currencies.currency_code%type
                                          DEFAULT null,
           p_precision                 IN fnd_currencies.precision%type
                                          DEFAULT null,
           p_mau                       IN
                                   fnd_currencies.minimum_accountable_unit%type
                                   DEFAULT null );

PROCEDURE delete_dist(
           p_form_name                 IN varchar2,
           p_form_version              IN number,
           p_cust_trx_line_gl_dist_id  IN
                    ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
           p_customer_trx_id	       IN ra_customer_trx.customer_trx_id%type,
           p_dist_rec		       IN ra_cust_trx_line_gl_dist%rowtype);

END ARP_PROCESS_DIST;

 

/
