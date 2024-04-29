--------------------------------------------------------
--  DDL for Package Body ARP_INST_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_INST_UTIL_PKG" AS
/* $Header: ARTUINSB.pls 115.3 2002/11/18 22:56:39 anukumar ship $ */

PROCEDURE select_inst_summary(
  p_ct_id                  IN  ra_customer_trx.customer_trx_id%type,
  p_prev_ct_id             IN  ra_customer_trx.customer_trx_id%type,
  p_mode                   IN  varchar2,
  p_line_remaining        OUT NOCOPY
                   ar_payment_schedules.amount_line_items_remaining%type,
  p_line_remaining_db     OUT NOCOPY
                   ar_payment_schedules.amount_line_items_remaining%type,
  p_tax_remaining         OUT NOCOPY  ar_payment_schedules.tax_remaining%type,
  p_tax_remaining_db      OUT NOCOPY  ar_payment_schedules.tax_remaining%type,
  p_freight_remaining     OUT NOCOPY  ar_payment_schedules.freight_remaining%type,
  p_freight_remaining_db  OUT NOCOPY ar_payment_schedules.freight_remaining%type,
  p_line_credited         OUT NOCOPY  ar_receivable_applications.line_applied%type,
  p_line_credited_db      OUT NOCOPY  ar_receivable_applications.line_applied%type,
  p_charges_credited      OUT NOCOPY  ar_receivable_applications.line_applied%type,
  p_charges_credited_db   OUT NOCOPY  ar_receivable_applications.line_applied%type,
  p_tax_credited          OUT NOCOPY  ar_receivable_applications.tax_applied%type,
  p_tax_credited_db       OUT NOCOPY  ar_receivable_applications.tax_applied%type,
  p_freight_credited      OUT NOCOPY  ar_receivable_applications.freight_applied%type,
  p_freight_credited_db   OUT NOCOPY  ar_receivable_applications.freight_applied%type)
IS
BEGIN
    arp_util.debug('arp_inst_util_pkg.select_inst_summary()+');

    IF (p_mode IN ('ALL',
                   'CRTRX',
                   'CRTRX_LINE', 'CRTRX_TAX', 'CRTRX_FREIGHT'))
    THEN
        SELECT nvl(sum(prv_ps.amount_line_items_remaining), 0),
               nvl(sum(prv_ps.tax_remaining), 0),
               nvl(sum(prv_ps.freight_remaining), 0),
               nvl(sum(prv_ps.amount_line_items_remaining), 0),
               nvl(sum(prv_ps.tax_remaining), 0),
               nvl(sum(prv_ps.freight_remaining), 0)
        INTO   p_line_remaining,
               p_tax_remaining,
               p_freight_remaining,
               p_line_remaining_db,
               p_tax_remaining_db,
               p_freight_remaining_db
        FROM   ar_payment_schedules prv_ps
        WHERE  prv_ps.customer_trx_id = p_prev_ct_id;

    END IF;

    IF (p_mode IN ('ALL',
                   'CM',
                   'CM_LINE', 'CM_TAX', 'CM_FREIGHT'))
    THEN

        SELECT nvl(sum(ra.line_applied), 0) * -1,
               nvl(sum(ra.receivables_charges_applied), 0) * -1,
               nvl(sum(ra.tax_applied), 0) * -1,
               nvl(sum(ra.freight_applied), 0) * -1,
               nvl(sum(ra.line_applied), 0) * -1,
               nvl(sum(ra.receivables_charges_applied), 0) * -1,
               nvl(sum(ra.tax_applied), 0) * -1,
               nvl(sum(ra.freight_applied), 0) * -1
        INTO   p_line_credited,
               p_charges_credited,
               p_tax_credited,
               p_freight_credited,
               p_line_credited_db,
               p_charges_credited_db,
               p_tax_credited_db,
               p_freight_credited_db
        FROM   ar_receivable_applications ra
        WHERE  customer_trx_id = p_ct_id
        AND    applied_customer_trx_id = p_prev_ct_id;

    END IF;

    arp_util.debug('arp_inst_util_pkg.select_inst_summary()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: arp_inst_util_pkg.select_inst_summary');
    arp_util.debug('p_ct_id      : '|| p_ct_id);
    arp_util.debug('p_prev_ct_id : '|| p_prev_ct_id);
    arp_util.debug('p_mode       : '|| p_mode);

    RAISE;
END;

END ARP_INST_UTIL_PKG;

/
