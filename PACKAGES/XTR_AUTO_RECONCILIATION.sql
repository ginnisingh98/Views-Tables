--------------------------------------------------------
--  DDL for Package XTR_AUTO_RECONCILIATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_AUTO_RECONCILIATION" AUTHID CURRENT_USER AS
/*$Header: xtrarecs.pls 120.1.12010000.2 2009/11/04 19:59:20 srsampat ship $   */


-- CONTEXT: CALL = XTR_AUTO_RECONCILIATION.Auto_Reconciliation
--
--    GLOBAL variables
--
G_verification_method	VARCHAR2(30);
--G_pass_code		VARCHAR2(2);
G_import_reference	NUMBER;
G_currency		VARCHAR2(15);
G_account_number        VARCHAR2(20);

--
--    Pass in Parameter
--
G_import_reference_from NUMBER;
G_import_reference_to   NUMBER;
G_acct_num		VARCHAR2(20);
G_source		VARCHAR2(20);
G_value_date_from	VARCHAR2(30);
G_value_date_to		VARCHAR2(30);
G_incl_rtm		VARCHAR2(1);
date_from 		DATE;
date_to 		DATE;

--
-- Procedure
--
PROCEDURE  P_RECONCILE(
	 	P_VERIFICATION_METHOD varchar2,
 	 	P_PASS_CODE IN OUT NOCOPY varchar2,
 	 	P_IMPORT_REFERENCE NUMBER,
	 	P_CURRENCY varchar2,
 	 	P_CGU$SYSDATE date,
 	 	P_ACCOUNT_NUMBER VARCHAR2,
	 	P_RECORD_IN_PROCESS IN OUT NOCOPY number,
	 	P_PARTY_NAME IN OUT NOCOPY varchar2,
	 	P_SERIAL_REFERENCE IN OUT NOCOPY varchar2,
	 	P_DEBIT_AMOUNT IN OUT NOCOPY number,
	 	P_CREDIT_AMOUNT IN OUT NOCOPY NUMBER,
	 	P_RECONCILED_YN  IN OUT NOCOPY varchar2,
	 	P_MIN_REC_NOS  IN OUT NOCOPY number,
	 	P_MAX_REC_NOS  IN OUT NOCOPY number,
	 	P_REC_NOS     IN OUT NOCOPY number,
	 	P_tot_recon IN OUT NOCOPY number,
		 P_INCL_RTM IN varchar2);


PROCEDURE RECALC_DT_DETAILS (p_deal_no               NUMBER,
                                   p_deal_date       DATE,
                                   p_company         VARCHAR2,
                                   p_subtype         VARCHAR2,
                                   p_product         VARCHAR2,
                                   p_portfolio       VARCHAR2,
                                   p_ccy             VARCHAR2,
                                   p_maturity        DATE,
                                   p_settle_acct     VARCHAR2,
                                   p_cparty          VARCHAR2,
                                   p_client          VARCHAR2,
                                   p_cparty_acct     VARCHAR2,
                                   p_dealer          VARCHAR2,
                                   p_least_inserted  VARCHAR2,
                                   p_ref_date        DATE,
                                   p_trans_no        NUMBER,
                                   p_rec_ref         NUMBER,
                                   p_rec_pass        VARCHAR2,
                                   p_limit_code      VARCHAR2 );

PROCEDURE RECALC_ROLL_DETAILS(p_deal_no		NUMBER,
			      p_subtype		VARCHAR2,
			      p_start_date	DATE,
			      p_ccy		VARCHAR2,
			      p_trans_no	NUMBER,
			      p_rec_ref		NUMBER,
			      p_rec_pass	VARCHAR2);

PROCEDURE AUTO_RECONCILIATION  (errbuf       OUT NOCOPY    VARCHAR2,
                                retcode      OUT NOCOPY    NUMBER,
                                p_source	    VARCHAR2,
                                p_acct_num	    VARCHAR2,
                                p_value_date_from   VARCHAR2,
				p_value_date_to	    VARCHAR2,
                                p_import_reference_from NUMBER,
                                p_import_reference_to   NUMBER,
				p_incl_rtm	    VARCHAR2 );
PROCEDURE REVERSE_ROLL_TRANS_RTMM (P_VERIFICATION_METHOD 	varchar2,
			     p_min_rec_nos		NUMBER,
			     p_max_rec_nos		NUMBER,
			     p_calling_method		VARCHAR2 ,p_val_date DATE);

PROCEDURE UPDATE_ROLL_TRANS_RTMM (P_VERIFICATION_METHOD 	varchar2,
			     p_min_rec_nos		NUMBER,
			     p_max_rec_nos		NUMBER,
			     p_calling_method		VARCHAR2 ,p_val_date DATE);

PROCEDURE UPDATE_ROLL_TRANS (P_VERIFICATION_METHOD 	varchar2,
			     p_min_rec_nos		NUMBER,
			     p_max_rec_nos		NUMBER,
			     p_calling_method		VARCHAR2 );


END XTR_AUTO_RECONCILIATION;

/
