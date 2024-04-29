--------------------------------------------------------
--  DDL for Package Body ARP_PAY_SCHED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PAY_SCHED" AS
/* $Header: ARPLPAYB.pls 120.4 2005/04/14 23:13:10 hyu ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE upd_payment_schedules(p_amount_due_remaining         NUMBER,
                                p_acctd_amount_due_remaining   NUMBER,
                                p_exchange_rate                NUMBER,
                                p_exchange_date                DATE,
                                p_exchange_rate_type           VARCHAR2,
                                p_pay_id                       NUMBER,
				p_last_updated_by	       NUMBER,
				p_last_update_date	       DATE,
				p_last_update_login	       NUMBER) IS
BEGIN

    UPDATE AR_PAYMENT_SCHEDULES
    SET AMOUNT_DUE_REMAINING = p_amount_due_remaining,
        ACCTD_AMOUNT_DUE_REMAINING = p_acctd_amount_due_remaining,
        EXCHANGE_RATE = p_exchange_rate,
        EXCHANGE_DATE = p_exchange_date,
        EXCHANGE_RATE_TYPE = p_exchange_rate_type,
	LAST_UPDATED_BY = p_last_updated_by,
	LAST_UPDATE_DATE = p_last_update_date,
	LAST_UPDATE_LOGIN = p_last_update_login
    WHERE PAYMENT_SCHEDULE_ID = p_pay_id;

    /* need to call ar_mrc_engine to update AR_MC_PAYMENT_SCHEDULES */
--{BUG4301323
--    ar_mrc_engine.maintain_mrc_data(
--                p_event_mode       => 'UPDATE',
--                p_table_name       => 'AR_PAYMENT_SCHEDULES',
--                p_mode             => 'SINGLE',
--                p_key_value        => p_pay_id);
--}

END upd_payment_schedules;

PROCEDURE upd_amt_due_remaining(pay_id                      NUMBER,
                                amt_due_remaining           NUMBER,
                                acctd_amt_due_remaining     NUMBER,
				p_last_updated_by	       NUMBER,
				p_last_update_date	       DATE,
				p_last_update_login	       NUMBER) IS
BEGIN

    UPDATE AR_PAYMENT_SCHEDULES
    SET AMOUNT_DUE_REMAINING = amt_due_remaining,
        ACCTD_AMOUNT_DUE_REMAINING = acctd_amt_due_remaining,
	LAST_UPDATED_BY = p_last_updated_by,
	LAST_UPDATE_DATE = p_last_update_date,
	LAST_UPDATE_LOGIN = p_last_update_login
    WHERE PAYMENT_SCHEDULE_ID = pay_id;

    /* need to call ar_mrc_engine to update AR_MC_PAYMENT_SCHEDULES */
--{BUG4301323
--    ar_mrc_engine.maintain_mrc_data(
--                p_event_mode       => 'UPDATE',
--                p_table_name       => 'AR_PAYMENT_SCHEDULES',
--                p_mode             => 'SINGLE',
--                p_key_value        => pay_id);
--}

END upd_amt_due_remaining;

--
    PROCEDURE PopulateDatesClosedIfNull( p_GlDateClosed      IN OUT NOCOPY DATE,
					 p_ActualDateClosed  IN OUT NOCOPY DATE ) IS
    BEGIN
        IF p_GlDateClosed IS NULL
        THEN
            p_GlDateClosed := to_date('12/31/4712','MM/DD/YYYY');
        END IF;
        IF p_ActualDateClosed IS NULL
        THEN
            p_ActualDateClosed := to_date('12/31/4712','MM/DD/YYYY');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_pay_sched.PopulateDatesClosedIfNull');
            RAISE;
    END;
--

END ARP_PAY_SCHED;

/
