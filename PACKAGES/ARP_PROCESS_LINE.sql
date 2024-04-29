--------------------------------------------------------
--  DDL for Package ARP_PROCESS_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_LINE" AUTHID CURRENT_USER AS
/* $Header: ARTECTLS.pls 120.1 2002/11/15 03:40:10 anukumar ship $ */

PROCEDURE insert_line(
               p_form_name              IN varchar2,
               p_form_version           IN number,
               p_line_rec		IN OUT NOCOPY ra_customer_trx_lines%rowtype,
               p_memo_line_type         IN ar_memo_lines.line_type%type,
               p_customer_trx_line_id  OUT NOCOPY
                               ra_customer_trx_lines.customer_trx_line_id%type,
               p_trx_class              IN ra_cust_trx_types.type%type
                                           DEFAULT NULL,
               p_ccid1                  IN
                                 gl_code_combinations.code_combination_id%type
                                 DEFAULT NULL,
               p_ccid2                  IN
                                 gl_code_combinations.code_combination_id%type
                                 DEFAULT NULL,
               p_amount1                IN ra_cust_trx_line_gl_dist.amount%type
                                           DEFAULT NULL,
               p_amount2                IN ra_cust_trx_line_gl_dist.amount%type
                                           DEFAULT NULL,
               p_rule_start_date        OUT NOCOPY
                                 ra_customer_trx_lines.rule_start_date%type,
               p_accounting_rule_duration OUT NOCOPY
                         ra_customer_trx_lines.accounting_rule_duration%type,
               p_gl_date                IN OUT NOCOPY
                         ra_cust_trx_line_gl_dist.gl_date%type,
               p_trx_date               IN OUT NOCOPY
                         ra_customer_trx.trx_date%type,
	       p_header_currency_code   IN
				ra_customer_trx.invoice_currency_code%type
				DEFAULT NULL,
	       p_header_exchange_rate	IN
				ra_customer_trx.exchange_rate%type
				DEFAULT NULL,
               p_status                 OUT NOCOPY varchar2,
               p_run_autoacc_flag       IN varchar2  DEFAULT 'Y',
               p_run_tax_flag           IN varchar2  DEFAULT 'Y',
               p_create_salescredits_flag IN VARCHAR2 DEFAULT 'Y'   );

PROCEDURE update_line(
                p_form_name	        IN varchar2,
                p_form_version          IN number,
                p_customer_trx_line_id  IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
                p_line_rec	        IN OUT NOCOPY ra_customer_trx_lines%rowtype,
                p_foreign_currency_code IN fnd_currencies.currency_code%type,
		p_exchange_rate         IN ra_customer_trx.exchange_rate%type,
                p_recalculate_tax_flag  IN boolean,
                p_rerun_autoacc_flag    IN boolean,
                p_rule_start_date       OUT NOCOPY
                                 ra_customer_trx_lines.rule_start_date%type,
                p_accounting_rule_duration OUT NOCOPY
                         ra_customer_trx_lines.accounting_rule_duration%type,
                p_gl_date                IN OUT NOCOPY
                         ra_cust_trx_line_gl_dist.gl_date%type,
                p_trx_date               IN OUT NOCOPY
                         ra_customer_trx.trx_date%type,
                p_status                 OUT NOCOPY varchar2 );

PROCEDURE delete_line(p_form_name		IN varchar2,
                       p_form_version		IN number,
                       p_customer_trx_line_id	IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                       p_complete_flag   IN ra_customer_trx.complete_flag%type,
		       p_recalculate_tax_flag  	IN boolean,
                       p_trx_amount         	IN number,
                       p_exchange_rate  IN ra_customer_trx.exchange_rate%type,
		       p_header_currency_code IN fnd_currencies.currency_code%type,
	 	       p_gl_date  IN OUT NOCOPY ra_cust_trx_line_gl_dist.gl_date%type,
	 	       p_trx_date IN OUT NOCOPY ra_customer_trx.trx_date%type,
                       p_line_rec    IN ra_customer_trx_lines%rowtype,
                       p_status OUT NOCOPY varchar2 );

PROCEDURE make_incomplete( p_customer_trx_id  IN
                             ra_customer_trx.customer_trx_id%type );

END ARP_PROCESS_LINE;

 

/
