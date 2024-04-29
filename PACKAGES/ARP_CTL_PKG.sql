--------------------------------------------------------
--  DDL for Package ARP_CTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CTL_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTICTLS.pls 120.6 2005/08/18 15:22:43 jbeckett ship $ */

PROCEDURE set_to_dummy( p_line_rec OUT NOCOPY ra_customer_trx_lines%rowtype);


PROCEDURE fetch_p( p_line_rec         OUT NOCOPY ra_customer_trx_lines%rowtype,
                   p_customer_trx_line_id  IN
                             ra_customer_trx_lines.customer_trx_line_id%type );

PROCEDURE lock_p( p_customer_trx_line_id  IN
                            ra_customer_trx_lines.customer_trx_line_id%type );


PROCEDURE lock_f_ct_id( p_customer_trx_id  IN
                            ra_customer_trx.customer_trx_id%type );

PROCEDURE lock_fetch_p( p_line_rec        IN OUT NOCOPY ra_customer_trx_lines%rowtype,
                        p_customer_trx_line_id IN
                          ra_customer_trx_lines.customer_trx_line_id%type );

PROCEDURE lock_compare_p( p_line_rec          IN ra_customer_trx_lines%rowtype,
                          p_customer_trx_line_id  IN
                            ra_customer_trx_lines.customer_trx_line_id%type,
                          p_ignore_who_flag BOOLEAN DEFAULT FALSE );

procedure delete_p( p_customer_trx_line_id  IN
                          ra_customer_trx_lines.customer_trx_line_id%type);

procedure delete_f_ct_id( p_customer_trx_id  IN
                                ra_customer_trx.customer_trx_id%type);

procedure delete_f_ltctl_id( p_link_to_cust_trx_line_id	IN
                          ra_customer_trx_lines.link_to_cust_trx_line_id%type);

procedure delete_f_ct_ltctl_id_type(
               p_customer_trx_id           IN
                          ra_customer_trx.customer_trx_id%type,
               p_link_to_cust_trx_line_id  IN
                          ra_customer_trx_lines.link_to_cust_trx_line_id%type,
               p_line_type                 IN
                          ra_customer_trx_lines.line_type%type DEFAULT NULL);

PROCEDURE update_p( p_line_rec IN ra_customer_trx_lines%rowtype,
                    p_customer_trx_line_id IN
                           ra_customer_trx_lines.customer_trx_line_id%type,
                    p_currency_code        IN fnd_currencies.currency_code%type
                                              DEFAULT NULL );

PROCEDURE update_f_ct_id( p_line_rec IN ra_customer_trx_lines%rowtype,
                          p_customer_trx_id  IN
                                ra_customer_trx_lines.customer_trx_id%type,
                          p_line_type IN
                            ra_customer_trx_lines.line_type%type default null,
                          p_currency_code IN fnd_currencies.currency_code%type
                                             DEFAULT NULL);

PROCEDURE update_amount_f_ctl_id(
		p_customer_trx_line_id	IN Number,
		p_inclusive_amt		IN Number,
		p_new_extended_amt	OUT NOCOPY Number,
		p_new_unit_selling_price OUT NOCOPY Number,
		p_precision		IN Number,
		p_min_acct_unit		IN Number);

PROCEDURE update_cm_amount_f_ctl_id(
	p_customer_trx_line_id IN Number,
	p_inclusive_amount IN Number,
	p_new_gross_extended_amount OUT NOCOPY Number,
	p_new_gross_unit_selling_price OUT NOCOPY Number,
	p_precision		IN Number,
	p_min_acct_unit		IN Number);


PROCEDURE insert_p(
                    p_line_rec              IN ra_customer_trx_lines%rowtype,
                    p_customer_trx_line_id OUT NOCOPY
                               ra_customer_trx_lines.customer_trx_line_id%type
                  );

PROCEDURE display_line_p(
                          p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type
                        );

PROCEDURE display_line_rec(
                             p_line_rec  IN ra_customer_trx_lines%rowtype
                          );

PROCEDURE display_line_f_lctl_id(  p_link_to_cust_trx_line_id IN
                         ra_customer_trx_lines.link_to_cust_trx_line_id%type);

PROCEDURE display_line_f_ct_id(  p_customer_trx_id IN
                                        ra_customer_trx.customer_trx_id%type );

PROCEDURE merge_line_recs(
                         p_old_line_rec IN ra_customer_trx_lines%rowtype,
                         p_new_line_rec IN
                                          ra_customer_trx_lines%rowtype,
                         p_out_line_rec IN OUT NOCOPY
                                          ra_customer_trx_lines%rowtype);

PROCEDURE insert_line_f_cm_ct_ctl_id(
  p_customer_trx_id         IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id    IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_prev_customer_trx_id    IN ra_customer_trx.customer_trx_id%type,
  p_line_type               IN ra_customer_trx_lines.line_type%type,
  p_line_percent	    IN number,
  p_uncredited_amount       IN ra_customer_trx_lines.extended_amount%type,
  p_credit_amount           IN ra_customer_trx_lines.extended_amount%type,
  p_currency_code           IN fnd_currencies.currency_code%type,
  p_tax_amount              IN ra_customer_trx_lines.extended_amount%type DEFAULT NULL);

PROCEDURE update_line_f_cm_ctl_id(
  p_customer_trx_id         IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id    IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_prev_customer_trx_id    IN ra_customer_trx.customer_trx_id%type,
  p_line_type               IN ra_customer_trx_lines.line_type%type,
  p_uncredited_amount       IN ra_customer_trx_lines.extended_amount%type,
  p_credit_amount           IN ra_customer_trx_lines.extended_amount%type,
  p_currency_code           IN fnd_currencies.currency_code%type);

FUNCTION get_text_dummy(p_null IN NUMBER DEFAULT null) RETURN varchar2;

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number;

END ARP_CTL_PKG;

 

/
