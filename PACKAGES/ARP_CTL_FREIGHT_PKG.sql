--------------------------------------------------------
--  DDL for Package ARP_CTL_FREIGHT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CTL_FREIGHT_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTCTLFS.pls 115.2 2002/11/15 03:31:40 anukumar ship $ */

PROCEDURE select_summary_freight(
  p_customer_trx_id        IN  number,
  p_amount_total          OUT NOCOPY  number,
  p_amount_total_rtot_db  OUT NOCOPY  number);

PROCEDURE lock_compare_frt_cover(
  p_customer_trx_line_id     IN
                   ra_customer_trx_lines.customer_trx_line_id%type,
  p_customer_trx_id          IN
                   ra_customer_trx_lines.customer_trx_id%type,
  p_link_to_cust_trx_line_id IN
                   ra_customer_trx_lines.link_to_cust_trx_line_id%type,
  p_previous_customer_trx_id IN
                   ra_customer_trx_lines.previous_customer_trx_id%type,
  p_previous_cust_trx_line_id IN
               ra_customer_trx_lines.previous_customer_trx_line_id%type,
  p_line_number              IN ra_customer_trx_lines.line_number%type,
  p_line_type                     IN ra_customer_trx_lines.line_type%type,
  p_extended_amount               IN ra_customer_trx_lines.extended_amount%type,
  p_attribute_category            IN
                        ra_customer_trx_lines.attribute_category%type,
  p_attribute1                    IN ra_customer_trx_lines.attribute1%type,
  p_attribute2                    IN ra_customer_trx_lines.attribute2%type,
  p_attribute3                    IN ra_customer_trx_lines.attribute3%type,
  p_attribute4                    IN ra_customer_trx_lines.attribute4%type,
  p_attribute5                    IN ra_customer_trx_lines.attribute5%type,
  p_attribute6                    IN ra_customer_trx_lines.attribute6%type,
  p_attribute7                    IN ra_customer_trx_lines.attribute7%type,
  p_attribute8                    IN ra_customer_trx_lines.attribute8%type,
  p_attribute9                    IN ra_customer_trx_lines.attribute9%type,
  p_attribute10                   IN ra_customer_trx_lines.attribute10%type,
  p_attribute11                   IN ra_customer_trx_lines.attribute11%type,
  p_attribute12                   IN ra_customer_trx_lines.attribute12%type,
  p_attribute13                   IN ra_customer_trx_lines.attribute13%type,
  p_attribute14                   IN ra_customer_trx_lines.attribute14%type,
  p_attribute15                   IN ra_customer_trx_lines.attribute15%type,
  p_interface_line_context        IN
                        ra_customer_trx_lines.interface_line_context%type,
  p_interface_line_attribute1     IN
                        ra_customer_trx_lines.interface_line_attribute1%type,
  p_interface_line_attribute2     IN
                        ra_customer_trx_lines.interface_line_attribute2%type,
  p_interface_line_attribute3     IN
                        ra_customer_trx_lines.interface_line_attribute3%type,
  p_interface_line_attribute4     IN
                        ra_customer_trx_lines.interface_line_attribute4%type,
  p_interface_line_attribute5     IN
                        ra_customer_trx_lines.interface_line_attribute5%type,
  p_interface_line_attribute6     IN
                        ra_customer_trx_lines.interface_line_attribute6%type,
  p_interface_line_attribute7     IN
                        ra_customer_trx_lines.interface_line_attribute7%type,
  p_interface_line_attribute8     IN
                        ra_customer_trx_lines.interface_line_attribute8%type,
  p_interface_line_attribute9     IN
                        ra_customer_trx_lines.interface_line_attribute9%type,
  p_interface_line_attribute10    IN
                        ra_customer_trx_lines.interface_line_attribute10%type,
  p_interface_line_attribute11    IN
                        ra_customer_trx_lines.interface_line_attribute11%type,
  p_interface_line_attribute12    IN
                        ra_customer_trx_lines.interface_line_attribute12%type,
  p_interface_line_attribute13    IN
                        ra_customer_trx_lines.interface_line_attribute13%type,
  p_interface_line_attribute14    IN
                        ra_customer_trx_lines.interface_line_attribute14%type,
  p_interface_line_attribute15    IN
                        ra_customer_trx_lines.interface_line_attribute15%type,
  p_default_ussgl_code_context IN
                     ra_customer_trx_lines.default_ussgl_trx_code_context%type,
  p_default_ussgl_trx_code IN
                     ra_customer_trx_lines.default_ussgl_transaction_code%type);

END ARP_CTL_FREIGHT_PKG;

 

/
