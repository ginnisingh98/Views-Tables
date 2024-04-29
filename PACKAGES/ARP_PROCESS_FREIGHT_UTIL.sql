--------------------------------------------------------
--  DDL for Package ARP_PROCESS_FREIGHT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_FREIGHT_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARTEFR1S.pls 115.2 2002/11/15 03:40:55 anukumar ship $ */

PROCEDURE default_freight_line(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_line_ctl_id           IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_prev_ct_id            IN ra_customer_trx.customer_trx_id%type,
  p_cust_trx_type_id      IN ra_customer_trx.cust_trx_type_id%type,
  p_primary_salesrep_id   IN ra_customer_trx.cust_trx_type_id%type,
  p_inventory_item_id     IN ra_customer_trx_lines.inventory_item_id%type,
  p_memo_line_id          IN ra_customer_trx_lines.memo_line_id%type,
  p_currency_code         IN fnd_currencies.currency_code%type,
  p_line_prev_ctl_id  IN OUT NOCOPY ra_customer_trx_lines.customer_trx_line_id%type,
  p_prev_ctl_id          OUT NOCOPY ra_customer_trx_lines.customer_trx_line_id%type,
  p_amount               OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_inv_line_number      OUT NOCOPY ra_customer_trx_lines.line_number%type,
  p_inv_frt_ccid         OUT NOCOPY ra_customer_trx_lines.line_number%type,
  p_inv_frt_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_inv_frt_uncr_amount  OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_ccid                 OUT NOCOPY ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_concat_segments      OUT NOCOPY ra_cust_trx_line_gl_dist.concatenated_segments%type,
  p_ussgl_code           OUT NOCOPY ra_customer_trx.default_ussgl_transaction_code%type);


FUNCTION get_freight_type(
  p_customer_trx_id IN ra_customer_trx.customer_trx_id%type)
RETURN varchar2;

PROCEDURE delete_frt_lines(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_complete_flag         IN varchar2,
  p_open_rec_flag         IN varchar2,
  p_customer_trx_id       IN ra_customer_trx.customer_trx_id%type);

PROCEDURE get_default_fob(
          pn_SHIP_TO_SITE_USE_ID                IN NUMBER
        , pn_BILL_TO_SITE_USE_ID                IN NUMBER
        , pn_SHIP_TO_CUSTOMER_ID                IN NUMBER
        , pn_BILL_TO_CUSTOMER_ID                IN NUMBER
        , pc_fob_point                          OUT NOCOPY VARCHAR2
        , pc_fob_point_name                     OUT NOCOPY VARCHAR2);


END ARP_PROCESS_FREIGHT_UTIL;

 

/
