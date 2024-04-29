--------------------------------------------------------
--  DDL for Package EDW_OPI_PRDL_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_OPI_PRDL_M_C" AUTHID CURRENT_USER AS
	/*$Header: OPIPPLDS.pls 120.1 2005/06/09 16:19:39 appldev  $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_OPI_PRDL_PRDL_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_OPI_PRDL_M_C;

 

/
