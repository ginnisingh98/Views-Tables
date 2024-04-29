--------------------------------------------------------
--  DDL for Package ARP_TRANS_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRANS_FLEX" AUTHID CURRENT_USER AS
/* $Header: ARTUFLXS.pls 115.2 2002/11/15 04:04:38 anukumar ship $ */

FUNCTION unique_trans_flex(
  p_ctl_id                    IN
                    ra_customer_trx_lines.customer_trx_line_id%type,
  p_interface_line_context    IN
                    ra_customer_trx_lines.interface_line_context%type,
  p_interface_line_attribute1 IN
                    ra_customer_trx_lines.interface_line_attribute1%type,
  p_interface_line_attribute2 IN
                    ra_customer_trx_lines.interface_line_attribute2%type,
  p_interface_line_attribute3 IN
                    ra_customer_trx_lines.interface_line_attribute3%type,
  p_interface_line_attribute4 IN
                    ra_customer_trx_lines.interface_line_attribute4%type,
  p_interface_line_attribute5 IN
                    ra_customer_trx_lines.interface_line_attribute5%type,
  p_interface_line_attribute6 IN
                    ra_customer_trx_lines.interface_line_attribute6%type,
  p_interface_line_attribute7 IN
                    ra_customer_trx_lines.interface_line_attribute7%type,
  p_interface_line_attribute8 IN
                    ra_customer_trx_lines.interface_line_attribute8%type,
  p_interface_line_attribute9 IN
                    ra_customer_trx_lines.interface_line_attribute9%type,
  p_interface_line_attribute10 IN
                    ra_customer_trx_lines.interface_line_attribute10%type,
  p_interface_line_attribute11 IN
                    ra_customer_trx_lines.interface_line_attribute11%type,
  p_interface_line_attribute12 IN
                    ra_customer_trx_lines.interface_line_attribute12%type,
  p_interface_line_attribute13 IN
                    ra_customer_trx_lines.interface_line_attribute13%type,
  p_interface_line_attribute14 IN
                    ra_customer_trx_lines.interface_line_attribute14%type,
  p_interface_line_attribute15 IN
                    ra_customer_trx_lines.interface_line_attribute15%type)
RETURN boolean;


FUNCTION unique_trans_flex(
  p_ctl_id                    IN
                    ra_customer_trx_lines.customer_trx_line_id%type,
  p_interface_line_context    IN
                    ra_customer_trx_lines.interface_line_context%type,
  p_interface_line_attribute1 IN
                    ra_customer_trx_lines.interface_line_attribute1%type,
  p_interface_line_attribute2 IN
                    ra_customer_trx_lines.interface_line_attribute2%type,
  p_interface_line_attribute3 IN
                    ra_customer_trx_lines.interface_line_attribute3%type,
  p_interface_line_attribute4 IN
                    ra_customer_trx_lines.interface_line_attribute4%type,
  p_interface_line_attribute5 IN
                    ra_customer_trx_lines.interface_line_attribute5%type,
  p_interface_line_attribute6 IN
                    ra_customer_trx_lines.interface_line_attribute6%type,
  p_interface_line_attribute7 IN
                    ra_customer_trx_lines.interface_line_attribute7%type,
  p_interface_line_attribute8 IN
                    ra_customer_trx_lines.interface_line_attribute8%type,
  p_interface_line_attribute9 IN
                    ra_customer_trx_lines.interface_line_attribute9%type,
  p_interface_line_attribute10 IN
                    ra_customer_trx_lines.interface_line_attribute10%type,
  p_interface_line_attribute11 IN
                    ra_customer_trx_lines.interface_line_attribute11%type,
  p_interface_line_attribute12 IN
                    ra_customer_trx_lines.interface_line_attribute12%type,
  p_interface_line_attribute13 IN
                    ra_customer_trx_lines.interface_line_attribute13%type,
  p_interface_line_attribute14 IN
                    ra_customer_trx_lines.interface_line_attribute14%type,
  p_interface_line_attribute15 IN
                    ra_customer_trx_lines.interface_line_attribute15%type,
  p_customer_trx_id            OUT NOCOPY ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id       OUT NOCOPY
                    ra_customer_trx_lines.customer_trx_line_id%type)
RETURN BOOLEAN;

PROCEDURE print_cache_contents;

END;

 

/
