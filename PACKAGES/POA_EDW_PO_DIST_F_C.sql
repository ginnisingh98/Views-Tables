--------------------------------------------------------
--  DDL for Package POA_EDW_PO_DIST_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_PO_DIST_F_C" AUTHID CURRENT_USER AS
/*$Header: poafpdbs.pls 115.4 2002/11/25 21:40:02 sbull ship $*/
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
End POA_EDW_PO_DIST_F_C;

 

/
