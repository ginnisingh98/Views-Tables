--------------------------------------------------------
--  DDL for Package FV_LOCKBOX_FC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_LOCKBOX_FC_PKG" AUTHID CURRENT_USER AS
-- $Header: FVDCLKBS.pls 120.2 2002/11/11 19:59:03 ksriniva noship $

 PROCEDURE main(x_errbuf            OUT NOCOPY varchar2,
                x_retcode           OUT NOCOPY varchar2,
                x_transmission_id IN NUMBER);

 PROCEDURE process_receipt_applications;

 PROCEDURE insert_cash_receipt(v_cust_trx_id IN number,
                               v_pay_sch_id  IN number,
                               v_amount IN number,
                               v_ussgl_tran_code IN varchar2);

 PROCEDURE update_lockbox_temp(v_decrease_dm_amount IN NUMBER);

 PROCEDURE update_interim_table(v_table IN VARCHAR2,
                                v_decrease_appl_amt IN NUMBER,
                                v_upd_customer_trx_id IN NUMBER,
                                v_upd_pay_sch_id IN NUMBER);
END FV_LOCKBOX_FC_PKG;

 

/
