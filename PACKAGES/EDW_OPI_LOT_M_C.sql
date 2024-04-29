--------------------------------------------------------
--  DDL for Package EDW_OPI_LOT_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_OPI_LOT_M_C" AUTHID CURRENT_USER AS
	/*$Header: OPIPLTDS.pls 120.1 2005/06/07 03:49:45 appldev  $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_OPI_LOTD_LOT_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_OPI_LOT_M_C;

 

/
