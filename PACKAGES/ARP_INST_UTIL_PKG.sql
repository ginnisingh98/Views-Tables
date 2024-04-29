--------------------------------------------------------
--  DDL for Package ARP_INST_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_INST_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTUINSS.pls 115.2 2002/11/15 04:04:59 anukumar ship $ */

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
  p_freight_credited_db   OUT NOCOPY  ar_receivable_applications.freight_applied%type);

END ARP_INST_UTIL_PKG;

 

/
