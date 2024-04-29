--------------------------------------------------------
--  DDL for Package OPI_EDW_OPI_JOB_RSRC_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_OPI_JOB_RSRC_F_C" AUTHID CURRENT_USER AS
/*$Header: OPIMJRSS.pls 120.1 2005/06/07 03:29:09 appldev  $*/
   Procedure Push(Errbuf       in OUT NOCOPY Varchar2,
                  Retcode       in OUT NOCOPY Varchar2,
                  p_from_date   IN  varchar2,
                  p_to_date     IN  varchar2);
   FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER,
		       p_seq_id NUMBER) RETURN NUMBER;

   FUNCTION FIND_MISSING_RATE_RECORDS(p_view_id NUMBER) RETURN NUMBER ;

   PROCEDURE DELETE_STG ;

End OPI_EDW_OPI_JOB_RSRC_F_C;

 

/
