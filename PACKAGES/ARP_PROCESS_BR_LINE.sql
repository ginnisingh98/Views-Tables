--------------------------------------------------------
--  DDL for Package ARP_PROCESS_BR_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_BR_LINE" AUTHID CURRENT_USER AS
/* $Header: ARTEBRLS.pls 120.2 2005/08/10 23:15:16 hyu ship $ */

  SUBTYPE r_sob_list_type      IS gl_mc_info.r_sob_list;
  SUBTYPE r_sob_list_rec_type  IS gl_mc_info.r_sob_rec;

PROCEDURE insert_line(p_line_rec		IN OUT NOCOPY ra_customer_trx_lines%rowtype,
                      p_customer_trx_line_id    OUT NOCOPY    ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE update_line(p_customer_trx_line_id  IN     ra_customer_trx_lines.customer_trx_line_id%type,
                      p_line_rec              IN OUT NOCOPY ra_customer_trx_lines%rowtype);

PROCEDURE delete_line(p_customer_trx_line_id	IN ra_customer_trx_lines.customer_trx_line_id%type,
                      p_customer_trx_id         IN ra_customer_trx.customer_trx_id%type);


END ARP_PROCESS_BR_LINE;

 

/
