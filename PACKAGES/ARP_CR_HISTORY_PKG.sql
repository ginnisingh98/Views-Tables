--------------------------------------------------------
--  DDL for Package ARP_CR_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CR_HISTORY_PKG" AUTHID CURRENT_USER AS
/*$Header: ARRICRHS.pls 120.4 2003/02/21 12:11:10 rkader ship $*/

--
-- Public procedures/functions
--
PROCEDURE set_to_dummy( p_crh_rec    OUT NOCOPY  ar_cash_receipt_history%ROWTYPE );
--
PROCEDURE insert_p( p_crh_rec    IN ar_cash_receipt_history%ROWTYPE,
		    p_crh_id     OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE );
--
--
-- New update_p procedure
--
PROCEDURE update_p( p_crh_rec    IN  ar_cash_receipt_history%ROWTYPE,
		    p_crh_id     IN  ar_cash_receipt_history.cash_receipt_history_id%TYPE );
--
-- Old update_p procedure retianed for compatibiltiy sake
--
PROCEDURE update_p( p_crh_rec    IN  ar_cash_receipt_history%ROWTYPE );
--
PROCEDURE delete_p(
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE );

PROCEDURE delete_p_cr(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE );
--
PROCEDURE lock_p(
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE );

--
PROCEDURE lock_f_batch_id(
	p_batch_id IN ar_batches.batch_id%TYPE);

--
PROCEDURE nowaitlock_f_batch_id(
	p_batch_id IN ar_batches.batch_id%TYPE);

--
PROCEDURE lock_fetch_p(
	p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE );

--
PROCEDURE nowaitlock_fetch_p(
	p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE );

--
PROCEDURE nowaitlock_p(
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE );

--
PROCEDURE fetch_p(
        p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE,
        p_crh_rec OUT NOCOPY ar_cash_receipt_history%ROWTYPE );

PROCEDURE fetch_f_crid(
        p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_crh_rec OUT NOCOPY ar_cash_receipt_history%ROWTYPE);

PROCEDURE fetch_f_cr_id(
        p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE);

PROCEDURE lock_f_cr_id(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE);

--
PROCEDURE nowaitlock_f_cr_id(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE);

--
PROCEDURE lock_fetch_f_cr_id(
	p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE );


--
PROCEDURE nowaitlock_fetch_f_cr_id(
	p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE );

PROCEDURE lock_hist_compare_p(
                  p_crh_rec IN ar_cash_receipt_history%ROWTYPE); /* Bug fix 2742388 */

--
END ARP_CR_HISTORY_PKG;

 

/
