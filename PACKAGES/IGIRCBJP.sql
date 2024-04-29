--------------------------------------------------------
--  DDL for Package IGIRCBJP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRCBJP" AUTHID CURRENT_USER AS
-- $Header: igircjps.pls 120.3.12000000.2 2007/10/26 13:11:41 sguduru ship $
--
   TYPE ReportParametersType IS RECORD
    (
        CallingMode               VARCHAR2(15) DEFAULT 'ARC',
        ReqId                     NUMBER(15),
        FuncCurr                  VARCHAR2(15),
        ChkBalance                VARCHAR2(1),
        StartPeriod               VARCHAR2(40),
        EndPeriod                 VARCHAR2(40),
        GlDateFrom                DATE,
        GlDateTo                  DATE,
        SetOfBooksId              NUMBER(15),
        CashSetOfBooksId          NUMBER(15),
        UnallocatedRevCcid        NUMBER(15),
        CreatedBy                 NUMBER(15),
        NxtCashReceiptHistoryId   ar_cash_receipt_history.cash_receipt_history_id%TYPE := 999999999999999,
        NxtReceivableApplicationId  ar_receivable_applications.receivable_application_id%TYPE := 999999999999999,
        NxtMiscCashDistributionId   ar_misc_cash_distributions.misc_cash_distribution_id%TYPE   := 999999999999999,
        NxtAdjustmentId             ar_adjustments.adjustment_id%TYPE
                := 999999999999999,
        NxtCustTrxLineGlDistId      ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%TYPE      := 999999999999999,
        Currency                VARCHAR2(15),
        CMApp                   VARCHAR2(1),
        Adj                     VARCHAR2(1),
        Trade                   VARCHAR2(1),
        Misc                    VARCHAR2(1),
        CCurr                   VARCHAR2(1),
        PostedStatus            VARCHAR2(30),
        PostedDateFrom          DATE,
        PostedDateTo            DATE
        , DetailByAccount       VARCHAR2(1)
        , DetailByCategory      VARCHAR2(1)
        , SummaryByAccount      VARCHAR2(1)
        , SummaryByCategory     VARCHAR2(1)
        , ChartOfAccountsID     NUMBER(15)
        , CompanySegmentFrom    VARCHAR2(30)
        , CompanySegmentTo      VARCHAR2(30)
        , AccountSegmentFrom    VARCHAR2(30)
        , AccountSegmentTo      VARCHAR2(30)
    );
--
    PROCEDURE Report( p_Report IN ReportParametersType );
    PROCEDURE Report
                ( errbuf                OUT NOCOPY     VARCHAR2
                , retcode               OUT NOCOPY     NUMBER
                , p_DetailByAccount             VARCHAR2
                , p_DetailByCategory            VARCHAR2
                , p_SummaryByAccount            VARCHAR2
                , p_SummaryByCategory           VARCHAR2
                , p_SetOfBooksId                NUMBER
                , p_ChartOfAccountsId           NUMBER
                , p_PostedStatus                VARCHAR2
                , p_GlDateFrom                  VARCHAR2
                , p_GlDateTo                    VARCHAR2
                , p_PostedDateFrom              VARCHAR2
                , p_PostedDateTo                VARCHAR2
                , p_Currency                    VARCHAR2
                , p_CMApp                       VARCHAR2
                , p_Adj                         VARCHAR2
                , p_Trade                       VARCHAR2
                , p_Misc                        VARCHAR2
                , p_CCurr                       VARCHAR2
                , p_CompanySegmentFrom          VARCHAR2
                , p_CompanySegmentTo            VARCHAR2
                , p_AccountSegmentFrom          VARCHAR2
                , p_AccountSegmentTo            VARCHAR2
                , p_DebugFlag                   VARCHAR2
                );
--
END;

 

/
