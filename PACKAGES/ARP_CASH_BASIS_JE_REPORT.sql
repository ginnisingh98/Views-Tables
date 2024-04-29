--------------------------------------------------------
--  DDL for Package ARP_CASH_BASIS_JE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CASH_BASIS_JE_REPORT" AUTHID CURRENT_USER AS
/* $Header: ARPLCBJS.pls 120.2 2005/10/30 04:24:20 appldev ship $ */


    TYPE ReportParametersType IS RECORD
    (
        ReqId                     NUMBER(15),
        ChkBalance                VARCHAR2(1),
        GlDateFrom                DATE,
        GlDateTo                  DATE,
        SetOfBooksId              NUMBER(15),
        UnallocatedRevCcid        NUMBER(15),
        CreatedBy                 NUMBER(15),
        NxtCashReceiptHistoryId     ar_cash_receipt_history.cash_receipt_history_id%TYPE        := 999999999999999,
        NxtReceivableApplicationId  ar_receivable_applications.receivable_application_id%TYPE   := 999999999999999,
        NxtMiscCashDistributionId   ar_misc_cash_distributions.misc_cash_distribution_id%TYPE   := 999999999999999,
        NxtAdjustmentId             ar_adjustments.adjustment_id%TYPE                           := 999999999999999,
        NxtCustTrxLineGlDistId      ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%TYPE      := 999999999999999,
	Currency		VARCHAR2(15),
	Inv			VARCHAR2(1),
	DM			VARCHAR2(1),
	CB			VARCHAR2(1),
	CM			VARCHAR2(1),
	CMApp			VARCHAR2(1),
	Adj			VARCHAR2(1),
	Trade			VARCHAR2(1),
	Misc			VARCHAR2(1),
        Ccurr                   VARCHAR2(1),
	PostedStatus		VARCHAR2(30),
	PostedDateFrom		DATE,
	PostedDateTo		DATE
    );
--
    PROCEDURE Report( p_Report IN ReportParametersType );
    PROCEDURE Report( p_ReqId                   NUMBER,
                    p_ChkBalance                VARCHAR2,
                    p_GlDateFrom                DATE,
                    p_GlDateTo                  DATE,
                    p_SetOfBooksId              NUMBER,
		    p_UnallocatedRevCcid	NUMBER,
                    p_CreatedBy                 NUMBER,
                    p_NxtCashReceiptHistoryId     NUMBER,
                    p_NxtReceivableApplicationId  NUMBER,
                    p_NxtMiscCashDistributionId   NUMBER,
                    p_NxtAdjustmentId             NUMBER,
                    p_NxtCustTrxLineGlDistId      NUMBER,
		    p_Currency			VARCHAR2,
		    p_Inv			VARCHAR2,
		    p_DM			VARCHAR2,
		    p_CB			VARCHAR2,
		    p_CM			VARCHAR2,
		    p_CMApp			VARCHAR2,
		    p_Adj			VARCHAR2,
		    p_Trade			VARCHAR2,
		    p_Misc			VARCHAR2,
                    p_Ccurr                     VARCHAR2,
		    p_PostedStatus		VARCHAR2,
		    p_PostedDateFrom		DATE,
		    p_PostedDateTo		DATE );
--
END;

 

/
