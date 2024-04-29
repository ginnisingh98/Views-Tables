--------------------------------------------------------
--  DDL for Package POA_EDW_ALINES_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_ALINES_F_C" AUTHID CURRENT_USER AS
/*$Header: poafpals.pls 120.1 2005/06/13 12:54:47 sriswami noship $*/
   Procedure Push(Errbuf        out NOCOPY Varchar2,
                  Retcode       out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
End POA_EDW_ALINES_F_C;

 

/
