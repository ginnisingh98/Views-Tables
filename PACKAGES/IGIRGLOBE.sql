--------------------------------------------------------
--  DDL for Package IGIRGLOBE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRGLOBE" AUTHID CURRENT_USER AS
-- $Header: igirglbs.pls 120.5.12010000.2 2008/08/04 13:06:16 sasukuma ship $

    FUNCTION Get_functional_currency RETURN VARCHAR2;
    FUNCTION Get_functional_sob_name Return VARCHAR2;
    PROCEDURE PopulateSystemOptions ;
    PROCEDURE PopulateRPIFlexforCurrSOb;
--    PROCEDURE PopulateCustProfileClasses ;
    PROCEDURE PopulateRPIFlex
                           ( pp_header_txn_context in varchar2 default 'PERIODICS'
                            , pp_header_txn_id1     in varchar2 default 'Standing Charge Id'
                            , pp_header_txn_id2     in varchar2 default 'Generate Sequence'
                            , pp_line_txn_context   in varchar2 default 'PERIODICS'
                            , pp_line_txn_id1       in varchar2 default 'Standing Charge Id'
                            , pp_line_txn_id2       in varchar2 default 'Generate Sequence'
                            , pp_line_txn_id3       in varchar2 default 'Standing charge line number'
                            , pp_line_txn_id4       in varchar2 default 'Price Break Number'
                            , pp_language_code      in varchar2 default  'US'
                            ) ;
    PROCEDURE PopulateExtendedData (
                       errbuf      out NOCOPY  varchar2
                      ,retcode     out NOCOPY  number
                      ,pp_source   in   varchar2
                      ,pp_commit   in   boolean default true
                    );
END;

/
