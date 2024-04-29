--------------------------------------------------------
--  DDL for Package GMI_ITEM_LOT_CONV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ITEM_LOT_CONV_PVT" AUTHID CURRENT_USER AS
-- $Header: GMIVILCS.pls 115.2 99/07/16 04:49:48 porting ship  $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIVILCS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains private procedures relating to Item / Lot     |
--|     unit of measure conversion.                                         |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     25-FEB-1999  M.Godfrey       Updated to R11                         |
--+=========================================================================+
-- API Name  : GMI_ITEM_LOT_CONV_PVT
-- Type      : Private
-- Function  : This package contains private procedures used to create an
--             item / lot unit of measure conversion.
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
FUNCTION Insert_ic_item_cnv
( p_ic_item_cnv_rec  IN ic_item_cnv%ROWTYPE
)
RETURN BOOLEAN;


END GMI_ITEM_LOT_CONV_PVT;

 

/
