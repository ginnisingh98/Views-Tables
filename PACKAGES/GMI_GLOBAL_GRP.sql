--------------------------------------------------------
--  DDL for Package GMI_GLOBAL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_GLOBAL_GRP" AUTHID CURRENT_USER AS
-- $Header: GMIGGBLS.pls 115.3 2002/10/25 18:14:15 jdiiorio ship $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIGGBLS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains global inventory functions and procedures     |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     17-FEB-1999  M.Godfrey       Upgrade to R11                         |
--|     25-OCT-2002  J. DiIorio      Bug#2643330 - added nocopy             |
--+=========================================================================+
-- API Name  : GMI_GLOBAL_GRP
-- Type      : Group
-- Function  : This package contains inventory global functions and
--             procedures
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
PROCEDURE Get_Item
( p_item_no       IN ic_item_mst.item_no%TYPE
, x_ic_item_mst   OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg   OUT NOCOPY ic_item_cpg%ROWTYPE
);

PROCEDURE Get_Lot
( p_item_id       IN ic_lots_mst.item_id%TYPE
, p_lot_no        IN ic_lots_mst.lot_no%TYPE
, p_sublot_no     IN ic_lots_mst.sublot_no%TYPE
, x_ic_lots_mst   OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg   OUT NOCOPY ic_lots_cpg%ROWTYPE
);

PROCEDURE Get_Warehouse
( p_whse_code     IN ic_whse_mst.whse_code%TYPE
, x_ic_whse_mst   OUT NOCOPY ic_whse_mst%ROWTYPE
);

PROCEDURE Get_Loct_Inv
( p_item_id       IN ic_loct_inv.item_id%TYPE
, p_whse_code     IN ic_loct_inv.whse_code%TYPE
, p_lot_id        IN ic_loct_inv.lot_id%TYPE
, p_location      IN ic_loct_inv.location%TYPE
, p_delete_mark   IN ic_loct_inv.delete_mark%TYPE  DEFAULT 0
, x_ic_loct_inv   OUT NOCOPY ic_loct_inv%ROWTYPE
);

PROCEDURE Get_Um
( p_um_code       IN sy_uoms_mst.um_code%TYPE
, x_sy_uoms_mst   OUT NOCOPY sy_uoms_mst%ROWTYPE
, x_sy_uoms_typ   OUT NOCOPY sy_uoms_typ%ROWTYPE
, x_error_code    OUT NOCOPY NUMBER
);

PROCEDURE Get_Lot_Inv
( p_item_id       IN ic_loct_inv.item_id%TYPE
, p_lot_id        IN ic_loct_inv.lot_id%TYPE
, p_delete_mark   IN ic_loct_inv.delete_mark%TYPE  DEFAULT 0
, x_lot_onhand    OUT NOCOPY NUMBER
);

END GMI_GLOBAL_GRP;

 

/
