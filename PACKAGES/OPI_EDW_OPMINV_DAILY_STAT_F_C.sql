--------------------------------------------------------
--  DDL for Package OPI_EDW_OPMINV_DAILY_STAT_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_OPMINV_DAILY_STAT_F_C" AUTHID CURRENT_USER AS
/*$Header: OPIMPIDS.pls 115.2 2002/11/27 20:08:43 cdaly ship $*/
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN            VARCHAR2,
                  p_to_date     IN            VARCHAR2);
End OPI_EDW_OPMINV_DAILY_STAT_F_C;

 

/
