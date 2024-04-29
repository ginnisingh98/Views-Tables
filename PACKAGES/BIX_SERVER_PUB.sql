--------------------------------------------------------
--  DDL for Package BIX_SERVER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_SERVER_PUB" AUTHID CURRENT_USER AS
/* $Header: BIXSERSS.pls 115.2 2003/01/10 00:31:14 achanda ship $: */
procedure POPULATE_BIX_SERVER_X(errbuf out nocopy varchar2,
                              retcode out nocopy varchar2);
/* This procedure is created so that it can be called from SQL prompt
   This is exactly same except it doesn't have the output parameter */
procedure POPULATE_BIX_SERVER_X;
END BIX_SERVER_PUB;

 

/
