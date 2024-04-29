--------------------------------------------------------
--  DDL for Package CS_KB_R_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_R_CTX_PKG" AUTHID DEFINER as
/* $Header: cskrctxs.pls 120.0 2005/06/01 13:15:19 appldev noship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | FILENAME: cskrctxs.pls                                               |
 |                                                                      |
 | PURPOSE                                                              |
 |   Datastore procedure for cs_forum_messages_tl_n4 intermedia index.  |
 | ARGUMENTS                                                            |
 |                                                                      |
 | NOTES                                                                |
 |   Usage: start                                                       |
 | HISTORY                                                              |
 |   05-Mar-2003 klou Created.                                          |
 +======================================================================*/

procedure Get_Forum_Composite_Cols(
  p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB
);


end cs_kb_r_ctx_pkg;

/

  GRANT EXECUTE ON "APPS"."CS_KB_R_CTX_PKG" TO "CTXSYS";
