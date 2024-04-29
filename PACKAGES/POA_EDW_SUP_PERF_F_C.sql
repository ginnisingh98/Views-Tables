--------------------------------------------------------
--  DDL for Package POA_EDW_SUP_PERF_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_SUP_PERF_F_C" AUTHID CURRENT_USER AS
/*$Header: poafpsps.pls 120.0 2005/06/01 21:04:11 appldev noship $*/
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
End POA_EDW_SUP_PERF_F_C;

 

/
