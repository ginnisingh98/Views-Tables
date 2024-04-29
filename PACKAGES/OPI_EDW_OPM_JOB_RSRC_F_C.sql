--------------------------------------------------------
--  DDL for Package OPI_EDW_OPM_JOB_RSRC_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_OPM_JOB_RSRC_F_C" AUTHID CURRENT_USER AS
/*$Header: OPIMOJRS.pls 120.0 2005/05/24 18:10:08 appldev noship $*/
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN            VARCHAR2,
                  p_to_date     IN            VARCHAR2);
End OPI_EDW_OPM_JOB_RSRC_F_C;

 

/
