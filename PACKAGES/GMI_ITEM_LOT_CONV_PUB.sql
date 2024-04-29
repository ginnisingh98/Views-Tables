--------------------------------------------------------
--  DDL for Package GMI_ITEM_LOT_CONV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ITEM_LOT_CONV_PUB" AUTHID CURRENT_USER AS
-- $Header: GMIPILCS.pls 115.3 2002/10/25 18:33:39 jdiiorio gmigapib.pls $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIPILCS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains public procedures relating to Item / Lot      |
--|     unit of measure conversion.                                         |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     25-FEB-1999  M.Godfrey       Upgrade to R11                         |
--|     25-OCT-2002  J. DiIorio      Bug#2643440 - added nocopy.            |
--+=========================================================================+
-- API Name  : GMI_ITEM_LOT_CONV_PUB
-- Type      : Public
-- Function  : This package contains public procedures used to create an
--             item / lot unit of measure conversion.
-- Pre-reqs  : N/A
-- Parameters: Per function
--
-- Current Vers  : 2.0
--
-- Previous Vers : 2.0
--
-- Initial Vers  : 1.0
-- Notes
--

-- API specific parameters to be presented in PL/SQL RECORD format
TYPE item_cnv_rec_typ IS RECORD
( item_no               IC_ITEM_MST.item_no%TYPE
, lot_no                IC_LOTS_MST.lot_no%TYPE       DEFAULT NULL
, sublot_no             IC_LOTS_MST.sublot_no%TYPE    DEFAULT NULL
, from_uom              SY_UOMS_MST.um_code%TYPE
, to_uom                SY_UOMS_MST.um_code%TYPE
, type_factor           IC_ITEM_CNV.type_factor%TYPE
, user_name             FND_USER.user_name%TYPE       DEFAULT 'OPM'
);
--
PROCEDURE Create_Item_Lot_UOM_Conv
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2           DEFAULT FND_API.G_FALSE
, p_commit             IN VARCHAR2           DEFAULT FND_API.G_FALSE
, p_validation_level   IN VARCHAR2           DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_item_cnv_rec       IN  item_cnv_rec_typ
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);
--

END GMI_ITEM_LOT_CONV_PUB;

 

/
