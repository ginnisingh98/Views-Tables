--------------------------------------------------------
--  DDL for Package ARP_CTL_PRIVATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CTL_PRIVATE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTCTL2S.pls 115.1 99/07/17 00:14:08 porting ship $ */

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

END ARP_CTL_PRIVATE_PKG;

 

/
