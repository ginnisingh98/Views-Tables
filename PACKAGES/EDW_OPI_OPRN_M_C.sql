--------------------------------------------------------
--  DDL for Package EDW_OPI_OPRN_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_OPI_OPRN_M_C" AUTHID CURRENT_USER AS
	/*$Header: OPIOPRDS.pls 120.2 2005/06/16 03:51:56 appldev  $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_EDW_OPI_OPRN_OPRN_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_OPI_OPRN_OPRC_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_OPI_OPRN_M_C;

 

/
