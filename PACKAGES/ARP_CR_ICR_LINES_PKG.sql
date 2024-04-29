--------------------------------------------------------
--  DDL for Package ARP_CR_ICR_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CR_ICR_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARRIICLS.pls 115.6 2002/12/17 23:14:54 anukumar ship $*/
PROCEDURE set_to_dummy( p_icr_lines_rec OUT NOCOPY
                              ar_interim_cash_receipt_lines%rowtype);
--
PROCEDURE insert_p(
            p_row_id  OUT NOCOPY VARCHAR2,
            p_cr_line_id  OUT NOCOPY
                        ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_icr_lines_rec  IN ar_interim_cash_receipt_lines%ROWTYPE );
PROCEDURE insert_p(
             p_icr_lines_rec  IN ar_interim_cash_receipt_lines%ROWTYPE,
             p_cr_id   IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
             p_icr_line_id OUT NOCOPY
                    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE );
--
PROCEDURE update_p(
            p_icr_lines_rec IN ar_interim_cash_receipt_lines%ROWTYPE,
            p_cash_receipt_line_id IN
                     ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_batch_id IN
                     ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_cash_receipt_id IN
                     ar_interim_cash_receipt_lines.cash_receipt_id%TYPE
);
--
PROCEDURE delete_p(
        p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
        p_icr_line_id IN
                   ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE );
PROCEDURE delete_fk(
        p_icr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE );
--
PROCEDURE lock_p( p_icr_line_id IN
                    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE );
--
PROCEDURE nowaitlock_p( p_icr_line_id IN
                    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE );
--
PROCEDURE fetch_p(
           p_icr_line_id IN
                   ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
           p_icr_lines_rec OUT NOCOPY ar_interim_cash_receipt_lines%ROWTYPE );
--
PROCEDURE lock_fetch_p( p_icr_lines_rec IN OUT NOCOPY
                                  ar_interim_cash_receipt_lines%ROWTYPE );
--
PROCEDURE nowaitlock_fetch_p( p_icr_lines_rec IN OUT NOCOPY
                                  ar_interim_cash_receipt_lines%ROWTYPE );

END  ARP_CR_ICR_LINES_PKG;
--

 

/
