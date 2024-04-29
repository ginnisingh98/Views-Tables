--------------------------------------------------------
--  DDL for Package ARP_CASH_RECEIPT_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CASH_RECEIPT_HISTORY" AUTHID CURRENT_USER AS
/* $Header: ARPLCRHS.pls 120.2 2005/10/30 04:24:28 appldev ship $ */

   FUNCTION GetCurrentId( p_CashReceiptId IN NUMBER ) RETURN NUMBER;
--
    FUNCTION InsertRecord (amount                        NUMBER,
                           acctd_amount                  NUMBER,
                           cash_receipt_id               NUMBER,
                           factor_flag                   VARCHAR2,
                           first_posted_record_flag      VARCHAR2,
                           gl_date                       DATE,
                           postable_flag                 VARCHAR2,
                           status                        VARCHAR2,
                           trx_date                      DATE,
                           acctd_factor_discount_amount  NUMBER,
                           account_code_combination_id   NUMBER,
                           bank_charge_account_ccid      NUMBER,
                           batch_id                      NUMBER,
                           current_record_flag           VARCHAR2,
                           exchange_date                 DATE,
                           exchange_rate                 NUMBER,
                           exchange_rate_type            VARCHAR2,
                           factor_discount_amount        NUMBER,
                           gl_posted_date                DATE,
                           posting_control_id            NUMBER,
                           reversal_cash_rec_hist_id     NUMBER,
                           reversal_gl_date              DATE,
                           reversal_gl_posted_date       DATE,
                           reversal_posting_control_id   NUMBER,
                           request_id                    NUMBER,
                           program_application_id        NUMBER,
                           program_id                    NUMBER,
                           program_update_date           DATE,
                           created_by                    NUMBER,
                           creation_date                 DATE,
                           last_updated_by               NUMBER,
                           last_update_date              DATE,
                           last_update_login             NUMBER,
                           prv_stat_cash_rec_hist_id     NUMBER,
                           created_from                  VARCHAR2,
                           reversal_created_from         VARCHAR2) RETURN NUMBER;
--
    PROCEDURE Reverse(p_reversal_cash_rec_hist_id     NUMBER,
                      p_reversal_gl_date              DATE,
                      p_cash_receipt_history_id       NUMBER,
		      p_last_updated_by	  	      NUMBER,
		      p_last_update_date	      DATE,
	              p_last_update_login             NUMBER);
--
    PROCEDURE UpdateAcctdFactor (cr_id         NUMBER,
                                 acctd_fd_amt  NUMBER);
--
    PROCEDURE UpdateAcctdAmount (cr_id         NUMBER,
                                  acctd_amt     NUMBER);
--
END;

 

/
