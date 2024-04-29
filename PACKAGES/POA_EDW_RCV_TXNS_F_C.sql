--------------------------------------------------------
--  DDL for Package POA_EDW_RCV_TXNS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_RCV_TXNS_F_C" AUTHID CURRENT_USER AS
/*$Header: poafprts.pls 115.5 2003/12/12 10:51:29 bthammin ship $*/
   Procedure Push(Errbuf        out NOCOPY Varchar2,
                  Retcode       out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
End POA_EDW_RCV_TXNS_F_C;

 

/
