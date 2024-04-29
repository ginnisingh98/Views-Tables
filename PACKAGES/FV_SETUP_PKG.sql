--------------------------------------------------------
--  DDL for Package FV_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_SETUP_PKG" AUTHID CURRENT_USER as
-- $Header: FVFCATTS.pls 120.3.12010000.4 2010/01/29 11:37:08 yanasing ship $
Procedure FACTS_ATTRIBUTES (errbuf OUT NOCOPY varchar2,
		            retcode OUT NOCOPY varchar2,
		            p_yes_no in varchar2);
 Procedure FUNDS_AVAILABLE (errbuf OUT NOCOPY varchar2,
                            retcode OUT NOCOPY varchar2);
 Procedure USSGL_LOAD (errbuf OUT NOCOPY varchar2,
                       retcode OUT NOCOPY varchar2);
 Procedure LOAD_FUND_TRANSMISSION_FORMATS (errbuf OUT NOCOPY varchar2,
                                           retcode OUT NOCOPY varchar2);
 Procedure CFS_TABLE_SETUP (errbuf OUT NOCOPY varchar2,
                            retcode OUT NOCOPY varchar2);
 Procedure LOAD_SF133_SETUP_DATA (errbuf OUT NOCOPY varchar2,
		                  retcode OUT NOCOPY varchar2,p_delete_133_setup IN   VARCHAR2);
 PROCEDURE load_rx_reports (errbuf OUT NOCOPY varchar2,
                            retcode OUT NOCOPY varchar2) ;
 PROCEDURE load_reimb_act_definitions (errbuf OUT NOCOPY varchar2,
                            retcode OUT NOCOPY varchar2) ;
 Procedure LOAD_SBR_SETUP_DATA (errbuf OUT NOCOPY varchar2,
		           retcode OUT NOCOPY varchar2,
                           p_delete_sbr_setup IN VARCHAR2);
End;

/
