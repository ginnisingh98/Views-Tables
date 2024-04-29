--------------------------------------------------------
--  DDL for Package INV_MGD_PURGE_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_PURGE_CP" AUTHID CURRENT_USER AS
/* $Header: INVCPURS.pls 120.1 2005/06/21 06:30:18 appldev ship $ */
-- +======================================================================+
-- |             Copyright (c) 2000 Oracle Corporation                    |
-- |                     Redwood Shores, CA, USA                          |
-- |                       All rights reserved.                           |
-- +======================================================================+
-- | FILENAME                                                             |
-- |     INVCPURS.pls                                                     |
-- |                                                                      |
-- | DESCRIPTION                                                          |
-- |    Spec of INV_MGD_PURGE_CP				          |
-- |                                                                      |
-- | HISTORY                                                              |
-- |     08/28/00 vjavli        Created                                   |
-- |     12/11/00 vjavli        signature updated to hierarchy_origin_id   |
-- |     11/14/01 vjavli        updated with Get_Organization_List        |
-- |                            performance enhancement                   |
-- +======================================================================+

-- ===============================================
-- CONSTANTS for concurrent program return values
-- ===============================================
--  Return values for RETCODE parameter (standard for concurrent programs)
RETCODE_SUCCESS				VARCHAR2(10)	:= '0';
RETCODE_WARNING				VARCHAR2(10)	:= '1';
RETCODE_ERROR				VARCHAR2(10)	:= '2';


-- =========================
-- PROCEDURES AND FUNCTIONS
-- =========================

--========================================================================
-- PROCEDURE : Purge                   PUBLIC
-- PARAMETERS: x_retcode               return status
--             x_errbuf                return error messages
--             p_org_hier_origin_id     IN NUMBER  Organization Hierarchy
--                                                Origin Id
--             p_org_hierarchy_id	IN Organization Hierarchy Id
--             p_purge_date		IN Purge Date
--             p_purge_name             IN Purge Name
--             p_request_limit          IN Number of request limit
--
-- COMMENT   : This is a wrapper procedure invokes core transaction purge
--             program repetitively for each organization in the organization
--             hierarchy origin list.  The procedure purges the transactions
--             across organizations
--=========================================================================
PROCEDURE Purge(x_retcode               OUT	NOCOPY VARCHAR2,
		x_errbuff	        OUT	NOCOPY VARCHAR2,
                p_org_hier_origin_id	IN	NUMBER,
   		p_org_hierarchy_id	IN	NUMBER,
		p_purge_date		IN	VARCHAR2,
		p_purge_name		IN	VARCHAR2,
                p_request_limit         IN      NUMBER);

END INV_MGD_PURGE_CP;

 

/
