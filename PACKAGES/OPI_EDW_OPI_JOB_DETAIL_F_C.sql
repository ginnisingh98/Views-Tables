--------------------------------------------------------
--  DDL for Package OPI_EDW_OPI_JOB_DETAIL_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_OPI_JOB_DETAIL_F_C" AUTHID CURRENT_USER AS
/*$Header: OPIMJDTS.pls 115.4 2004/01/02 19:05:53 bthammin noship $*/
   Procedure Push(Errbuf       in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  varchar2,
                  p_to_date     IN  varchar2);
   FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER,
		       p_seq_id NUMBER) RETURN NUMBER;
End OPI_EDW_OPI_JOB_DETAIL_F_C;

 

/
