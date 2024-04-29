--------------------------------------------------------
--  DDL for Package ARP_PROCESS_INST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_INST" AUTHID CURRENT_USER AS
/* $Header: ARTEINSS.pls 115.1 99/07/17 00:20:18 porting ship $ */

PROCEDURE update_inst(
  p_form_name              IN varchar2,
  p_form_version           IN number,
  p_ct_id                  IN  ra_customer_trx.customer_trx_id%type,
  p_prev_ct_id             IN  ra_customer_trx.customer_trx_id%type,
  p_prev_ps_id             IN  ar_payment_schedules.payment_schedule_id%type,
  p_currency_code          IN  ar_payment_schedules.invoice_currency_code%type,
  p_line_credit            IN
                   ar_payment_schedules.amount_line_items_remaining%type,
  p_chrg_credit            IN
                   ar_payment_schedules.amount_line_items_remaining%type,
  p_tax_credit             IN
                   ar_receivable_applications.tax_applied%type,
  p_freight_credit         IN
                   ar_receivable_applications.freight_applied%type);


END ARP_PROCESS_INST;

 

/
