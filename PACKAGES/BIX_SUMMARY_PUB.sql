--------------------------------------------------------
--  DDL for Package BIX_SUMMARY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_SUMMARY_PUB" AUTHID CURRENT_USER AS
/* $Header: BIXSUMPS.pls 115.1 2003/01/10 00:31:07 achanda ship $: */
procedure POPULATE_BIX_SUM_X(errbuf out nocopy varchar2,
                              retcode out nocopy varchar2);
/* This procedure is created so that it can be called from SQL prompt
   This is exactly same except it doesn't have the output parameter */
procedure POPULATE_BIX_SUM_X;
END BIX_SUMMARY_PUB;

 

/
