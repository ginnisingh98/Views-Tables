--------------------------------------------------------
--  DDL for Package ARP_DATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DATES" AUTHID CURRENT_USER AS
/* $Header: ARTUDATS.pls 120.2.12000000.2 2007/02/23 13:04:38 naneja ship $ */


PROCEDURE val_gl_periods_for_rules(
                      p_request_id       IN ra_customer_trx.request_id%type,
		      p_acc_rule_id      IN ra_rules.rule_id%type,
	    	      p_acc_duration     IN
                           ra_customer_trx_lines.accounting_rule_duration%type,
            	      p_rule_start_date  IN
				    ra_customer_trx_lines.rule_start_date%type,
            	      p_sob_id           IN
                                    gl_sets_of_books.set_of_books_id%type );

/*bug 5884520 added parameter for handling invoice api call*/

PROCEDURE derive_gl_trx_dates_from_rules (
                           p_customer_trx_id IN
                               ra_customer_trx.customer_trx_id%type,
			   p_gl_date  IN OUT NOCOPY
			       ra_cust_trx_line_gl_dist.gl_date%type,
			   p_trx_date IN OUT NOCOPY
                               ra_customer_trx.trx_date%type,
		           p_recalculate_tax_flag IN OUT NOCOPY boolean,
                           P_created_from IN  ar_trx_header_gt.created_from%type default NULL,
                           p_defaulted_gl_date_flag IN ar_trx_header_gt.defaulted_gl_date_flag%type default NULL
                                         );

END ARP_DATES;

 

/
