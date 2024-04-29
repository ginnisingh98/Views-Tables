--------------------------------------------------------
--  DDL for Package GMI_LOTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_LOTS_PVT" AUTHID CURRENT_USER AS
-- $Header: GMIVLOTS.pls 115.2 99/07/16 04:50:05 porting ship  $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIVLOTS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains private procedures relating to Lot creation.  |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     18-FEB-1999  M.Godfrey       Upgrade to R11                         |
--+=========================================================================+
-- API Name  : GMI_LOTS_PVT
-- Type      : Private
-- Function  : This package contains private procedures used to create an
--             item lot/sublot.
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
FUNCTION Insert_ic_lots_mst
( p_ic_lots_mst_rec  IN ic_lots_mst%ROWTYPE
)
RETURN BOOLEAN;

--
FUNCTION Insert_ic_lots_cpg
( p_ic_lots_cpg_rec  IN ic_lots_cpg%ROWTYPE
)
RETURN BOOLEAN;

END GMI_LOTS_PVT;

 

/
