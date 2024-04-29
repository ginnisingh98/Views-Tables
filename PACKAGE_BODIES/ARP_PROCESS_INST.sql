--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_INST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_INST" AS
/* $Header: ARTEINSB.pls 115.2 2002/11/18 22:36:37 anukumar ship $ */

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
                   ar_receivable_applications.freight_applied%type)
IS
  l_commit_amount   number;
BEGIN

    arp_util.debug('arp_process_inst.update_inst()+');

    arp_maintain_ps.maintain_payment_schedules(
                        'U',
                        p_ct_id,
                        p_prev_ps_id,
                        p_line_credit,
                        p_tax_credit,
                        p_freight_credit,
                        p_chrg_credit,
                        l_commit_amount);

    arp_util.debug('arp_process_inst.update_inst()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_process_inst.update_inst');
    arp_util.debug('p_ct_id            : '||p_ct_id);
    arp_util.debug('p_prev_ct_id       : '||p_prev_ct_id);
    arp_util.debug('p_prev_ps_id       : '||p_prev_ps_id);
    arp_util.debug('p_currency_code    : '||p_currency_code);
    arp_util.debug('p_line_credit      : '||p_line_credit);
    arp_util.debug('p_chrg_credit      : '||p_chrg_credit);
    arp_util.debug('p_tax_credit       : '||p_tax_credit);
    arp_util.debug('p_freight_credit   : '||p_freight_credit);
    RAISE;
END;

END ARP_PROCESS_INST;

/
