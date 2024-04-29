--------------------------------------------------------
--  DDL for Package ARP_CASH_BASIS_ACCOUNTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CASH_BASIS_ACCOUNTING" AUTHID CURRENT_USER AS
/* $Header: ARPLCBPS.pls 120.2 2005/07/22 13:26:11 naneja ship $ */

    TYPE PostingParametersType IS RECORD
    (
        PostingControlId          NUMBER(15),
        FuncCurr                  VARCHAR2(15),
        ChkBalance                VARCHAR2(1),
        GlDateFrom                DATE,
        GlDateTo                  DATE,
        SetOfBooksId              NUMBER(15),
        UnallocatedRevCcid        NUMBER(15),
        GlPostedDate              DATE,
        UnpostedPostingControlId  ar_posting_control.posting_control_id%TYPE := -3,
        CreatedBy                 NUMBER(15),
        UserSource                VARCHAR2(25),    -- user_name_struct->source
        UserTrade                 VARCHAR2(25),    -- user_name_struct->misc
        UserMisc                  VARCHAR2(25),    -- user_name_struct->trade
        UserCcurr                 VARCHAR2(25),
        NxtCashReceiptHistoryId     ar_cash_receipt_history.cash_receipt_history_id%TYPE        := 999999999999999,
        NxtReceivableApplicationId  ar_receivable_applications.receivable_application_id%TYPE   := 999999999999999,
        NxtMiscCashDistributionId   ar_misc_cash_distributions.misc_cash_distribution_id%TYPE   := 999999999999999,
        NxtAdjustmentId             ar_adjustments.adjustment_id%TYPE                           := 999999999999999,
        NxtCustTrxLineGlDistId      ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%TYPE      := 999999999999999,
        SummaryFlag               VARCHAR2(1),
-- NLS strings from host app
        NlsPreReceipt             VARCHAR2(240),   -- AR_NLS_GLTP_PRE_RECEIPT
        NlsPostReceipt            VARCHAR2(240),   -- AR_NLS_GLTP_POST_RECEIPT
        NlsPreMiscDist            VARCHAR2(240),   -- AR_NLS_GLTP_PRE_MISC_DIST
        NlsPostMiscDist           VARCHAR2(240),   -- AR_NLS_GLTP_POST_MISC_DIST
        NlsPreTradeApp            VARCHAR2(240),   -- AR_NLS_GLTP_PRE_TRADEAPP
        NlsPostTradeApp           VARCHAR2(240),   -- AR_NLS_GLTP_POST_TRADEAPP
        NlsPreReceiptGl            VARCHAR2(240),   -- AR_NLS_GLTP_PRE_RECEIPTGL
        NlsPostReceiptGl           VARCHAR2(240),   -- AR_NLS_GLTP_POST_RECEIPTGL
        NlsAppOnacc               VARCHAR2(240),   -- AR_NLS_APP_ONACC
        NlsAppOtheracc            VARCHAR2(240),   -- AR_NLS_APP_OTHERACC
        NlsAppUnapp               VARCHAR2(240),   -- AR_NLS_APP_UNAPP
        NlsAppUnid                VARCHAR2(240),   -- AR_NLS_APP_UNID
        NlsAppApplied             VARCHAR2(240),   -- AR_NLS_APP_APPLIED
        NlsAppActivity            VARCHAR2(240),   -- AR_NLS_APP_ACTIVITY
        SetOfBooksType            VARCHAR2(1)      -- sob type
    );
--
    PROCEDURE Post( p_Post IN OUT NOCOPY PostingParametersType );
    PROCEDURE Post( p_PostingControlId          NUMBER,
                    p_FuncCurr                  VARCHAR2,
                    p_ChkBalance                VARCHAR2,
                    p_GlDateFrom                DATE,
                    p_GlDateTo                  DATE,
                    p_SetOfBooksId              NUMBER,
		    p_UnallocatedRevCcid	NUMBER,
                    p_GlPostedDate              DATE,
                    p_CreatedBy                 NUMBER,
                    p_UserSource                VARCHAR2,
                    p_UserTrade                 VARCHAR2,
                    p_UserMisc                  VARCHAR2,
                    p_UserCcurr                 VARCHAR2,
                    p_NxtCashReceiptHistoryId     NUMBER,
                    p_NxtReceivableApplicationId  NUMBER,
                    p_NxtMiscCashDistributionId   NUMBER,
                    p_NxtAdjustmentId             NUMBER,
                    p_NxtCustTrxLineGlDistId      NUMBER,
                    p_SummaryFlag               VARCHAR2,
                    p_NlsPreReceipt             VARCHAR2,
                    p_NlsPostReceipt            VARCHAR2,
                    p_NlsPreMiscDist            VARCHAR2,
                    p_NlsPostMiscDist           VARCHAR2,
                    p_NlsPreTradeApp            VARCHAR2,
                    p_NlsPostTradeApp           VARCHAR2,
                    p_NlsPreReceiptGl            VARCHAR2,
                    p_NlsPostReceiptGl           VARCHAR2,
                    p_NlsAppOnacc               VARCHAR2,
                    p_NlsAppOtheracc            VARCHAR2,
                    p_NlsAppUnapp               VARCHAR2,
                    p_NlsAppUnid                VARCHAR2,
                    p_NlsAppApplied             VARCHAR2,
                    p_NlsAppActivity            VARCHAR2,
                    p_UnpostedPostingControlId  ar_posting_control.posting_control_id%TYPE );
--
END;

 

/
