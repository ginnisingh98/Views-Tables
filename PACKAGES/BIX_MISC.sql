--------------------------------------------------------
--  DDL for Package BIX_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_MISC" AUTHID CURRENT_USER AS
/* $Header: BIXMISCS.pls 115.3 2003/01/10 00:31:25 achanda ship $ */
PROCEDURE BIX_PURGE_INT;
procedure BIX_PURGE_INT(errbuf out nocopy varchar2,
				retcode out nocopy varchar2);
END BIX_MISC;

 

/
