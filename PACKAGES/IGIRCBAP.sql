--------------------------------------------------------
--  DDL for Package IGIRCBAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRCBAP" AUTHID CURRENT_USER AS
-- $Header: igircaps.pls 115.6 2002/11/18 14:25:11 panaraya ship $

    TYPE PostingParametersType IS RECORD
    (
        PostingControlId          NUMBER(15),
        FuncCurr                  VARCHAR2(15),
        ChkBalance                VARCHAR2(1),
        GlDateFrom                DATE,
        GlDateTo                  DATE,
        SetOfBooksId              NUMBER(15),
        CashSetOfBooksId          NUMBER(15),
        UnallocatedRevCcid        NUMBER(15),
        GlPostedDate              DATE,
        UnpostedPostingControlId  ar_posting_control.posting_control_id%TYPE := -3,
    ReqId             NUMBER(15),      -- Concurrent Request ID
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
        NlsAppUnapp               VARCHAR2(240),   -- AR_NLS_APP_UNAPP
        NlsAppUnid                VARCHAR2(240),   -- AR_NLS_APP_UNID
        NlsAppApplied             VARCHAR2(240)    -- AR_NLS_APP_APPLIED
    );
--
   PROCEDURE Post
                ( p_PostingControlId    IN  NUMBER
        , p_GlDateFrom      IN  DATE
        , p_GlDateTo        IN  DATE
        , p_GlPostedDate    IN  DATE
        , p_CreatedBy       IN  NUMBER
        , p_SummaryFlag     IN  VARCHAR2
        , p_SetOfBooksId    OUT NOCOPY NUMBER
        , p_CashSetOfBooksId    OUT NOCOPY NUMBER
        , p_user_je_source_name OUT NOCOPY Varchar2
        , p_ra_id       OUT NOCOPY NUMBER
        , p_crh_id      OUT NOCOPY NUMBER
        , p_mcd_id      OUT NOCOPY NUMBER
        , p_balanceflag     OUT NOCOPY VARCHAR2
        );
--
    PROCEDURE SubmitJournalImport
        ( p_posting_control_id           IN   NUMBER
        , p_start_date                   IN   DATE
        , p_post_thru_date               IN   DATE
        );
END;

 

/
