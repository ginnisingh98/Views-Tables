--------------------------------------------------------
--  DDL for Package Body IEM_DATASTORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DATASTORE" as
/* $Header: iemindsb.pls 120.2 2007/11/22 06:35:37 sanjrao ship $*/
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | FILENAME: iemindsb.pls                                               |
 |                                                                      |
 | PURPOSE                                                              |
 |   Datastore procedure for iem_imt_index intermedia index.  |
 | ARGUMENTS                                                            |
 |                                                                      |
 | NOTES                                                                |
 |   Usage: start  iemindsb.pls apps                                    |
 |  Arguments:                                                          |
 |     1 - un_apps = apps user name                                     |
 |     2 - CTXSYS = ctxsys user name                                    |
 | HISTORY                                                              |
 |   12-02-2003 rtripath Created.
 +======================================================================*/
procedure get_imt_data(
  p_rowid IN ROWID, x_clob IN OUT NOCOPY CLOB
) is

BEGIN
select message_text into x_clob
from iem_imt_texts
where rowid=p_rowid;
EXCEPTION WHEN OTHERS THEN
	null;
END get_imt_data;
end iem_datastore;

/

  GRANT EXECUTE ON "APPS"."IEM_DATASTORE" TO "CTXSYS";
