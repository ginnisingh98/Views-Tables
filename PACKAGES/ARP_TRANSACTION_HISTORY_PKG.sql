--------------------------------------------------------
--  DDL for Package ARP_TRANSACTION_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRANSACTION_HISTORY_PKG" AUTHID CURRENT_USER AS
/*$Header: ARRITRHS.pls 120.4 2005/08/10 23:14:02 hyu ship $*/

--
-- Public procedures/functions
--
PROCEDURE set_to_dummy( p_trh_rec    OUT NOCOPY  ar_transaction_history%ROWTYPE );
--
PROCEDURE insert_p( p_trh_rec    IN ar_transaction_history%ROWTYPE,
		    p_trh_id     OUT NOCOPY ar_transaction_history.transaction_history_id%TYPE );
--
--
-- New update_p procedure
--
PROCEDURE update_p( p_trh_rec    IN  ar_transaction_history%ROWTYPE,
		    p_trh_id     IN  ar_transaction_history.transaction_history_id%TYPE );

PROCEDURE delete_p(
	p_trh_id IN ar_transaction_history.transaction_history_id%TYPE );

PROCEDURE delete_p(
	p_trx_id IN ra_customer_trx.customer_trx_id%TYPE );
--
PROCEDURE lock_p(
	p_trh_id IN ar_transaction_history.transaction_history_id%TYPE );

PROCEDURE lock_fetch_p(
	p_trh_rec IN OUT NOCOPY ar_transaction_history%ROWTYPE );

--
PROCEDURE nowaitlock_fetch_p(
	p_trh_rec IN OUT NOCOPY ar_transaction_history%ROWTYPE );

--
PROCEDURE nowaitlock_p(
	p_trh_id IN ar_transaction_history.transaction_history_id%TYPE );

--
PROCEDURE fetch_p(
        p_trh_id IN ar_transaction_history.transaction_history_id%TYPE,
        p_trh_rec OUT NOCOPY ar_transaction_history%ROWTYPE );

PROCEDURE fetch_f_trx_id(
        p_trh_rec IN OUT NOCOPY ar_transaction_history%ROWTYPE);

PROCEDURE lock_f_trx_id(
	p_trx_id IN ra_customer_trx.customer_trx_id%TYPE);

--
PROCEDURE nowaitlock_f_trx_id(
	p_trx_id IN ra_customer_trx.customer_trx_id%TYPE);

--
PROCEDURE lock_fetch_f_trx_id(
	p_trh_rec IN OUT NOCOPY ar_transaction_history%ROWTYPE );


--
PROCEDURE nowaitlock_fetch_f_trx_id(
	p_trh_rec IN OUT NOCOPY ar_transaction_history%ROWTYPE );


END ARP_TRANSACTION_HISTORY_PKG;

 

/
