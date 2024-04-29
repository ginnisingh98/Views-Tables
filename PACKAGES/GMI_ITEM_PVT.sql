--------------------------------------------------------
--  DDL for Package GMI_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ITEM_PVT" AUTHID CURRENT_USER AS
-- $Header: GMIVITMS.pls 115.2 99/07/16 04:49:57 porting ship  $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIVITMS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains private procedures relating to Inventory      |
--|     Item creation.                                                      |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     16-FEB-1999  M.Godfrey       Upgrade to R11                         |
--+=========================================================================+
-- API Name  : GMI_ITEM_PVT
-- Type      : Private
-- Function  : This package contains private procedures used to create an
--             inventory item.
-- Pre-reqs  : N/A
-- Parameters: Per function
--
-- Current Vers  : 2.0
--
-- Previous Vers : 1.0
--
-- Initial Vers  : 1.0
-- Notes
--

FUNCTION Insert_ic_item_mst
( p_ic_item_mst_rec  IN ic_item_mst%ROWTYPE
)
RETURN BOOLEAN;

--
FUNCTION Insert_ic_item_cpg
( p_ic_item_cpg_rec  IN ic_item_cpg%ROWTYPE
)
RETURN BOOLEAN;

END GMI_ITEM_PVT;

 

/
