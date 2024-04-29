--------------------------------------------------------
--  DDL for Package ARP_CASH_RECEIPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CASH_RECEIPTS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARRICRS.pls 120.4 2003/10/29 09:58:24 rkader ship $*/

--
-- Public procedures/functions
--
PROCEDURE set_to_dummy( p_cr_rec OUT NOCOPY ar_cash_receipts%rowtype);
--
-- New update_p
--
PROCEDURE update_p( p_cr_rec    IN ar_cash_receipts%ROWTYPE,
		    p_cr_id     IN ar_cash_receipts.cash_receipt_id%TYPE );
--
-- Old update_p procedure retianed for compatibiltiy sake
--
PROCEDURE update_p( p_cr_rec    IN ar_cash_receipts%ROWTYPE );
PROCEDURE insert_p( p_cr_rec    IN OUT NOCOPY ar_cash_receipts%ROWTYPE );
--
PROCEDURE delete_p( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE );

PROCEDURE lock_p( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE );

PROCEDURE lock_f_batch_id( p_batch_id IN ar_batches.batch_id%TYPE);

PROCEDURE nowaitlock_p( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE );

/* Bug fix 3032059 */
PROCEDURE nowaitlock_version_p(
        p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_rec_version_number IN ar_cash_receipts.rec_version_number%TYPE DEFAULT NULL );

PROCEDURE update_version_number( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE );

PROCEDURE nowaitlock_f_batch_id( p_batch_id IN ar_batches.batch_id%TYPE);

PROCEDURE fetch_p(
                   p_cr_rec IN OUT NOCOPY ar_cash_receipts%ROWTYPE);
PROCEDURE lock_fetch_p(
                   p_cr_rec IN OUT NOCOPY ar_cash_receipts%ROWTYPE);
PROCEDURE nowaitlock_fetch_p(
                   p_cr_rec IN OUT NOCOPY ar_cash_receipts%ROWTYPE);
PROCEDURE lock_compare_p(
		   p_cr_rec IN ar_cash_receipts%ROWTYPE);

END ARP_CASH_RECEIPTS_PKG;

 

/
