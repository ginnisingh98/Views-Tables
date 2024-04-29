--------------------------------------------------------
--  DDL for Package OPI_EDW_COGS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_COGS_F_C" AUTHID CURRENT_USER AS
/*$Header: OPIMCOGS.pls 120.1 2005/06/10 13:30:00 appldev  $*/
   Procedure Push(Errbuf       in out nocopy Varchar2,
                  Retcode       in out nocopy Varchar2,
                  p_from_date   IN  varchar2,
                  p_to_date     IN  varchar2);
   FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER,
		       p_seq_id NUMBER) RETURN NUMBER;
End OPI_EDW_COGS_F_C;

 

/
