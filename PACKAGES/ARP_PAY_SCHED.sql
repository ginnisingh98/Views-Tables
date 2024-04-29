--------------------------------------------------------
--  DDL for Package ARP_PAY_SCHED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PAY_SCHED" AUTHID CURRENT_USER AS
/* $Header: ARPLPAYS.pls 115.3 2002/11/15 02:42:34 anukumar ship $ */

PROCEDURE upd_payment_schedules(p_amount_due_remaining         NUMBER,
                                p_acctd_amount_due_remaining   NUMBER,
                                p_exchange_rate                NUMBER,
                                p_exchange_date                DATE,
                                p_exchange_rate_type           VARCHAR2,
                                p_pay_id                       NUMBER,
				p_last_updated_by	       NUMBER,
				p_last_update_date	       DATE,
				p_last_update_login	       NUMBER);

PROCEDURE upd_amt_due_remaining(pay_id                      NUMBER,
                                amt_due_remaining           NUMBER,
                                acctd_amt_due_remaining     NUMBER,
				p_last_updated_by	       NUMBER,
				p_last_update_date	       DATE,
				p_last_update_login	       NUMBER);


PROCEDURE PopulateDatesClosedIfNull( p_GlDateClosed        IN OUT NOCOPY DATE,
				     p_ActualDateClosed    IN OUT NOCOPY DATE );

END ARP_PAY_SCHED;

 

/
