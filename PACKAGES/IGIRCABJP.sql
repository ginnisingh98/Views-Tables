--------------------------------------------------------
--  DDL for Package IGIRCABJP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRCABJP" AUTHID CURRENT_USER AS
-- $Header: igircajs.pls 120.2.12000000.3 2007/11/08 17:21:20 sguduru ship $

    SUBTYPE ReportParametersType IS  IGIRCBJP.ReportParametersType;
--
    PROCEDURE Report( p_Report IN ReportParametersType );

    PROCEDURE ReportOutput
        ( p_Report IN ReportParametersType
        ) ;

    PROCEDURE ReportCBR
                ( errbuf                OUT NOCOPY     VARCHAR2
                , retcode               OUT NOCOPY     NUMBER
                , p_DataAccessSetId             NUMBER
                , p_SetOfBooksId                NUMBER
                , p_CashSetOfBooksId            NUMBER   -- CBR AR change
                , p_ChartOfAccountsId           NUMBER
                , p_PostedStatus                VARCHAR2
                , p_PeriodFrom                  VARCHAR2
                , p_PeriodTo                    VARCHAR2
                , p_AccountSegmentFrom          VARCHAR2
                , p_AccountSegmentTo            VARCHAR2
                ) ;

END;

 

/
