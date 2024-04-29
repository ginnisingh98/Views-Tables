--------------------------------------------------------
--  DDL for Package IEX_ASSIGN_COLL_LEVEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_ASSIGN_COLL_LEVEL_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvacls.pls 120.0.12010000.5 2009/07/31 11:25:05 schekuri ship $ */

/*========================================================================+
 * |               Copyright (c) 2002 Oracle Corporation                  |
 * |                  Redwood Shores, California, USA                     |
 * |                       All rights reserved.                           |
 *
+=========================================================================+
|                                                                         |
| FILENAME:                                                               |
|   iexvacls.pls                                                          |
| DESCRIPTION:                                                            |
|   Private API to create /update hz_party_preferences                    |
| MODIFICATION HISTORY:                                                   |
+========================================================================*/

PROCEDURE MAIN_PROCESS(ERRBUF       OUT NOCOPY Varchar2,
                       RETCODE      OUT NOCOPY Varchar2,
                       p_request_id IN  Number);


END IEX_ASSIGN_COLL_LEVEL_PVT;


/
