--------------------------------------------------------
--  DDL for Package ARP_PROCESS_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_INVOICE" AUTHID CURRENT_USER AS
/* $Header: ARTEINVS.pls 115.2 2002/11/15 03:43:32 anukumar ship $ */

PROCEDURE header_post_insert (p_primary_salesrep_id IN
                                ra_customer_trx.primary_salesrep_id%type,
                              p_customer_trx_id IN
                                ra_customer_trx.customer_trx_id%type,
                              p_create_default_sc_flag IN varchar2 DEFAULT 'Y'
                             );

PROCEDURE tax_post_update;

PROCEDURE freight_post_update (
                        p_frt_rec IN ra_customer_trx_lines%rowtype,
                        p_gl_date IN
                           ra_cust_trx_line_gl_dist.gl_date%type,
                        p_frt_ccid IN
                           ra_cust_trx_line_gl_dist.code_combination_id%type,
                        p_status   OUT NOCOPY varchar2);


END ARP_PROCESS_INVOICE;

 

/
