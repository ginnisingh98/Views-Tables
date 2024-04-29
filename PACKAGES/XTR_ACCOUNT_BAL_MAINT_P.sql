--------------------------------------------------------
--  DDL for Package XTR_ACCOUNT_BAL_MAINT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_ACCOUNT_BAL_MAINT_P" AUTHID CURRENT_USER as
/* $Header: xtraccts.pls 120.4 2005/07/29 09:10:06 badiredd ship $ */
-----------------------------------------------
PROCEDURE upload_accts_program(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER);
PROCEDURE UPLOAD_ACCTS;
-----------------------------------------------
PROCEDURE MAINTAIN_SETOFFS(
		p_party_code IN VARCHAR2,
                p_cashpool_id IN CE_CASHPOOLS.CASHPOOL_ID%TYPE,
		p_conc_acct_id IN CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
               	p_calc_date IN DATE);
-----------------------------------------------
PROCEDURE UPDATE_BANK_ACCTS(p_account_number IN VARCHAR2,
                            p_currency       IN VARCHAR2,
                            p_bank_code      IN VARCHAR2,
                            p_portfolio      IN VARCHAR2,
                            p_pty_cross_ref  IN VARCHAR2,
                            p_party_code     IN VARCHAR2,
                            p_recalc_date    IN DATE,
                            p_accum_int_cfwd IN OUT NOCOPY NUMBER,
                            p_overwrite      IN VARCHAR2 DEFAULT NULL);
-----------------------------------------------
PROCEDURE FIND_INT_RATE(l_acct     		IN VARCHAR2,
                        l_balance		IN NUMBER,
                        l_party_code	IN VARCHAR2,
                        l_bank_code 	IN VARCHAR2,
                        l_currency		IN VARCHAR2,
                        l_balance_date	IN DATE,
                        l_int_rate 		IN OUT NOCOPY NUMBER);
-----------------------------------------------
end XTR_ACCOUNT_BAL_MAINT_P;

 

/
