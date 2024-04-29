--------------------------------------------------------
--  DDL for Package PN_RXI_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_RXI_REP" AUTHID CURRENT_USER as
  -- $Header: PNRXPRGS.pls 115.3 2002/11/15 21:13:44 stripath ship $

  PROCEDURE purge (
    errbuf                  out NOCOPY varchar2,
    retcode                 out NOCOPY varchar2   ,
    p_report_name           in         varchar2   ,
    p_date_from             in         varchar2   ,
    p_date_to               in         varchar2 );

-------------------------------
-- End of Package
-------------------------------
END PN_RXI_REP;

 

/
