--------------------------------------------------------
--  DDL for Package XDO_CP_DATA_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_CP_DATA_SECURITY_PKG" AUTHID CURRENT_USER AS
----$Header: XDODSCRS.pls 120.1 2007/06/04 18:57:18 bgkim noship $
--+===========================================================================+
--|                    Copyright (c) 2006 Oracle Corporation                  |
--|                      Redwood Shores, California, USA                      |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :                                                               |
--|      XDODSCRS.pls                                                         |
--|                                                                           |
--|  DESCRIPTION:                                                             |
--|      This package is used to get the Concurrent requests based on the     |
--|      data security                                                        |
--|                                                                           |
--|                                                                           |
--|  HISTORY:                                                                 |
--|      05/22/2006     hidekoji          Created                             |
--+===========================================================================+

--==========================================================================
--  FUNCTION NAME:
--
--    get_concurrent_request_ids                 Public
--
--  DESCRIPTION:
--
--      This function gets the concurrent request IDs that can be viewed.
--      and stores them in global temporary table
--
--  PARAMETERS:
--      In:
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--	    05/22/2006     hidekoji             Created
--===========================================================================
FUNCTION get_concurrent_request_ids return VARCHAR2;


END XDO_CP_DATA_SECURITY_PKG;

/
