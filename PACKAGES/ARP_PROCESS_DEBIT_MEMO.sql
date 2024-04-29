--------------------------------------------------------
--  DDL for Package ARP_PROCESS_DEBIT_MEMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_DEBIT_MEMO" AUTHID CURRENT_USER AS
/* $Header: ARTEDBMS.pls 115.1 99/07/17 00:18:41 porting ship $ */

PROCEDURE line_post_insert (
                            p_customer_trx_line_id   IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
                            p_ccid1                  IN
                              gl_code_combinations.code_combination_id%type,
                            p_ccid2                  IN
                              gl_code_combinations.code_combination_id%type,
                            p_amount1                IN
                              ra_cust_trx_line_gl_dist.amount%type,
                            p_amount2                IN
                              ra_cust_trx_line_gl_dist.amount%type );

END ARP_PROCESS_DEBIT_MEMO;

 

/
