--------------------------------------------------------
--  DDL for Package FV_ECON_BENF_DISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_ECON_BENF_DISC" AUTHID CURRENT_USER AS
-- $Header: FVXAPCHS.pls 120.3 2006/05/26 06:40:54 kthatava ship $

FUNCTION EBD_CHECK(x_batch_name IN VARCHAR2,
                   x_invoice_id IN NUMBER,
                   x_check_date IN DATE,
                   x_inv_due_date IN DATE,
                   x_discount_amount  IN NUMBER,
                   x_discount_date IN DATE) RETURN CHAR;

PROCEDURE FV_CALCULATE_INTEREST(x_invoice_id IN NUMBER,
                                x_sys_auto_flg IN VARCHAR2,
                                x_auto_calc_int_flg IN VARCHAR2,
                                x_check_date IN DATE,
                                x_payment_num IN NUMBER,
                                x_amount_remaining IN NUMBER,
                                x_discount_taken IN NUMBER,
                                x_discount_available IN NUMBER,
                                x_interest_amount OUT NOCOPY NUMBER);

END FV_ECON_BENF_DISC;

 

/
