--------------------------------------------------------
--  DDL for Package ARP_PROCESS_COMMITMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_COMMITMENT" AUTHID CURRENT_USER AS
/* $Header: ARTECOMS.pls 115.3 2002/11/15 03:39:40 anukumar ship $ */

PROCEDURE header_pre_insert;

TYPE commitment_rec_type IS RECORD
(
  customer_trx_line_id
                     ra_customer_trx_lines.customer_trx_line_id%type,
  inventory_item_id  ra_customer_trx_lines.inventory_item_id%type,
  memo_line_id       ra_customer_trx_lines.memo_line_id%type,
  description        ra_customer_trx_lines.description%type,
  extended_amount    ra_customer_trx_lines.extended_amount%type,
  interface_line_attribute1
                     ra_customer_trx_lines.interface_line_attribute1%type,
  interface_line_attribute2
                     ra_customer_trx_lines.interface_line_attribute2%type,
  interface_line_attribute3
                     ra_customer_trx_lines.interface_line_attribute3%type,
  interface_line_attribute4
                     ra_customer_trx_lines.interface_line_attribute4%type,
  interface_line_attribute5
                     ra_customer_trx_lines.interface_line_attribute5%type,
  interface_line_attribute6
                     ra_customer_trx_lines.interface_line_attribute6%type,
  interface_line_attribute7
                     ra_customer_trx_lines.interface_line_attribute7%type,
  interface_line_attribute8
                     ra_customer_trx_lines.interface_line_attribute8%type,
  interface_line_attribute9
                     ra_customer_trx_lines.interface_line_attribute9%type,
  interface_line_attribute10
                     ra_customer_trx_lines.interface_line_attribute10%type,
  interface_line_attribute11
                     ra_customer_trx_lines.interface_line_attribute11%type,
  interface_line_attribute12
                     ra_customer_trx_lines.interface_line_attribute12%type,
  interface_line_attribute13
                     ra_customer_trx_lines.interface_line_attribute13%type,
  interface_line_attribute14
                     ra_customer_trx_lines.interface_line_attribute14%type,
  interface_line_attribute15
                     ra_customer_trx_lines.interface_line_attribute15%type,
  interface_line_context
                     ra_customer_trx_lines.interface_line_context%type,
  attribute_category
                     ra_customer_trx_lines.attribute_category%type,
  attribute1         ra_customer_trx_lines.attribute1%type,
  attribute2         ra_customer_trx_lines.attribute2%type,
  attribute3         ra_customer_trx_lines.attribute3%type,
  attribute4         ra_customer_trx_lines.attribute4%type,
  attribute5         ra_customer_trx_lines.attribute5%type,
  attribute6         ra_customer_trx_lines.attribute6%type,
  attribute7         ra_customer_trx_lines.attribute7%type,
  attribute8         ra_customer_trx_lines.attribute8%type,
  attribute9         ra_customer_trx_lines.attribute9%type,
  attribute10        ra_customer_trx_lines.attribute10%type,
  attribute11        ra_customer_trx_lines.attribute11%type,
  attribute12        ra_customer_trx_lines.attribute12%type,
  attribute13        ra_customer_trx_lines.attribute13%type,
  attribute14        ra_customer_trx_lines.attribute14%type,
  attribute15        ra_customer_trx_lines.attribute15%type,
  default_ussgl_transaction_code
                ra_customer_trx_lines.default_ussgl_transaction_code%type
);

PROCEDURE header_post_insert ( p_customer_trx_id IN
                                 ra_customer_trx.customer_trx_id%type,
                               p_commitment_rec IN commitment_rec_type,
                               p_primary_salesrep_id IN
                                 ra_customer_trx.primary_salesrep_id%type,
                               p_gl_date IN
                                 ra_cust_trx_line_gl_dist.gl_date%type,
                              p_customer_trx_line_id OUT NOCOPY
                               ra_customer_trx_lines.customer_trx_line_id%type,
                              p_status   OUT NOCOPY varchar2
                             );

PROCEDURE header_pre_update;

PROCEDURE header_post_update( p_commitment_rec        IN commitment_rec_type,
                              p_foreign_currency_code IN
                                fnd_currencies.currency_code%type,
                              p_exchange_rate         IN
                                ra_customer_trx.exchange_rate%type,
                              p_rerun_autoacc_flag    IN boolean );

PROCEDURE header_pre_delete;

PROCEDURE set_to_dummy( p_commitment_rec OUT NOCOPY commitment_rec_type );

END ARP_PROCESS_COMMITMENT;

 

/
