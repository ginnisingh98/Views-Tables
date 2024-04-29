--------------------------------------------------------
--  DDL for Package IEM_DATASTORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DATASTORE" AUTHID CURRENT_USER as
/* $Header: iemindss.pls 120.2 2007/11/22 06:36:36 sanjrao ship $*/
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | FILENAME: iemindss.pls                                               |
 |                                                                      |
 | PURPOSE                                                              |
 |   Datastore procedure for iem_imt_index intermedia index.  |
 | ARGUMENTS                                                            |
 |  1 - apps user name = apps
 |                                                                      |
 | NOTES                                                                |
 | HISTORY                                                              |
 |   12-02-2003 rtriapth Created.                                          |
 +======================================================================*/

procedure get_imt_data(
  p_rowid IN ROWID, x_clob IN OUT NOCOPY CLOB
);


end iem_datastore;

/

  GRANT EXECUTE ON "APPS"."IEM_DATASTORE" TO "CTXSYS";
