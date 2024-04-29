--------------------------------------------------------
--  DDL for Package ARP_CR_ICR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CR_ICR_PKG" AUTHID CURRENT_USER AS
/* $Header: ARRIICRS.pls 115.4 2002/12/17 23:15:18 anukumar ship $*/
PROCEDURE set_to_dummy( p_icr_rec OUT NOCOPY ar_interim_cash_receipts%rowtype);
PROCEDURE insert_p( p_row_id  OUT NOCOPY VARCHAR2,
                    p_cr_id  OUT NOCOPY ar_interim_cash_receipts.cash_receipt_id%TYPE,
                    p_icr_rec   IN ar_interim_cash_receipts%ROWTYPE );
PROCEDURE insert_p( p_icr_rec    IN ar_interim_cash_receipts%ROWTYPE,
        p_icr_id OUT NOCOPY ar_interim_cash_receipts.cash_receipt_id%TYPE );

--
PROCEDURE update_p( p_icr_rec IN ar_interim_cash_receipts%ROWTYPE,
                    p_cash_receipt_id IN
                           ar_interim_cash_receipts.cash_receipt_id%TYPE);
--
PROCEDURE delete_p(
	p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE );

PROCEDURE lock_p(
	p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE );

PROCEDURE nowaitlock_p(
	p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE );

PROCEDURE fetch_p( p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
                   p_icr_rec OUT NOCOPY ar_interim_cash_receipts%ROWTYPE );
--
PROCEDURE lock_fetch_p(
                   p_icr_rec IN OUT NOCOPY ar_interim_cash_receipts%ROWTYPE );

PROCEDURE nowaitlock_fetch_p(
                   p_icr_rec IN OUT NOCOPY ar_interim_cash_receipts%ROWTYPE );

END  ARP_CR_ICR_PKG;
--

 

/
