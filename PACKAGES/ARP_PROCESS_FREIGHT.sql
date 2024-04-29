--------------------------------------------------------
--  DDL for Package ARP_PROCESS_FREIGHT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_FREIGHT" AUTHID CURRENT_USER AS
/* $Header: ARTEFRTS.pls 120.3.12010000.1 2008/07/24 16:56:00 appldev ship $ */

PROCEDURE check_frt_line_count(
  p_frt_rec               IN ra_customer_trx_lines%rowtype);

PROCEDURE validate_insert_freight(
  p_frt_rec               IN ra_customer_trx_lines%rowtype);

PROCEDURE validate_update_freight(
  p_frt_rec               IN ra_customer_trx_lines%rowtype);

PROCEDURE validate_delete_freight(
  p_customer_trx_id             IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id        IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_complete_flag               IN ra_customer_trx.complete_flag%type);

PROCEDURE set_flags(
  p_customer_trx_line_id  IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_new_frt_rec           IN ra_customer_trx_lines%rowtype,
  p_new_ccid              IN
                            ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_new_gl_date           IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_amount_changed_flag   OUT NOCOPY boolean,
  p_ccid_changed_flag     OUT NOCOPY boolean,
  p_gl_date_changed_flag  OUT NOCOPY boolean);

PROCEDURE insert_freight(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_frt_rec               IN OUT NOCOPY ra_customer_trx_lines%rowtype,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_gl_date               IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_frt_ccid              IN ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_customer_trx_line_id  OUT NOCOPY ra_customer_trx_lines.customer_trx_line_id%type,
  p_status                OUT NOCOPY varchar2,
  p_run_autoacc_flag      IN varchar2  DEFAULT 'Y');

PROCEDURE update_freight(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_customer_trx_id       IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id  IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_frt_rec               IN OUT NOCOPY ra_customer_trx_lines%rowtype,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_gl_date               IN
                        ra_cust_trx_line_gl_dist.gl_date%type,
  p_frt_ccid              IN
                        ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_complete_flag         IN varchar2,
  p_open_rec_flag         IN varchar2,
  p_status               OUT NOCOPY varchar2);


PROCEDURE delete_freight(
  p_form_name             IN varchar2,
  p_form_version          IN number,
  p_trx_class             IN ra_cust_trx_types.type%type,
  p_complete_flag         IN varchar2,
  p_open_rec_flag         IN varchar2,
  p_customer_trx_id       IN ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id  IN ra_customer_trx_lines.customer_trx_line_id%type);

PROCEDURE init;

END ARP_PROCESS_FREIGHT;

/
