--------------------------------------------------------
--  DDL for Package ARP_PS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCIPSS.pls 115.4 2002/12/17 23:13:12 anukumar ship $*/

PROCEDURE set_to_dummy( p_ps_rec    IN OUT NOCOPY ar_payment_schedules%ROWTYPE );

PROCEDURE insert_p( p_ps_rec    IN OUT NOCOPY ar_payment_schedules%ROWTYPE,
        p_ps_id OUT NOCOPY ar_payment_schedules.payment_schedule_id%TYPE );

PROCEDURE update_p( p_ps_rec    IN ar_payment_schedules%ROWTYPE,
		p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE );
PROCEDURE update_p( p_ps_rec    IN ar_payment_schedules%ROWTYPE );

PROCEDURE delete_p(
                p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE );

PROCEDURE delete_f_ct_id( p_ct_id
                           IN ra_customer_trx.customer_trx_id%type );

PROCEDURE lock_p(
	p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE );

PROCEDURE lock_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type );

PROCEDURE nowaitlock_p(
	p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE );

PROCEDURE nowaitlock_compare_p(
          p_ps_id                       IN NUMBER
        , p_amount_due_remaining        IN NUMBER);

PROCEDURE fetch_p( p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
                   p_ps_rec OUT NOCOPY ar_payment_schedules%ROWTYPE );

PROCEDURE fetch_fk_cr_id( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
                          p_ps_rec OUT NOCOPY ar_payment_schedules%ROWTYPE );
END  ARP_PS_PKG;

 

/
