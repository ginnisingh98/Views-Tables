--------------------------------------------------------
--  DDL for Package Body GMI_ITEM_LOT_CONV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_ITEM_LOT_CONV_PVT" AS
--$Header: GMIVILCB.pls 115.2 99/07/16 04:49:43 porting ship  $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMIVILCB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMI_ITEM_LOT_CONV_PVT                                                 |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This package conatains all Utility functions pertaining to Item/Lot   |
--|    Conversion                                                            |
--|                                                                          |
--| CONTENTS                                                                 |
--|    Insert_Ic_Item_Cnv                                                    |
--|                                                                          |
--| HISTORY                                                                  |
--|    25-FEB-1999  M.P.Godfrey    Upgrade to R11                            |
--|                                                                          |
--+==========================================================================+
-- Body end of comments
-- Global variables
G_PKG_NAME  CONSTANT  VARCHAR2(30) := 'GMI_ITEM_LOT_CONV_PVT';
-- Func start of comments
--+==========================================================================+
--| FUNCTION NAME                                                            |
--|    Create_Item                                                           |
--|                                                                          |
--| USAGE                                                                    |
--|    Insert a row into IC_ITEM_CNV                                         |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This procedure creates a new row into IC_ITEM_CNV                     |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_ic_item_cnv_rec IN RECORD - Item Conversion Details                 |
--|                                                                          |
--| RETURNS                                                                  |
--|    TRUE  - If Insert successful                                          |
--|    FALSE - If Insert Fails                                               |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Insert_Ic_Item_Cnv
(  p_ic_item_cnv_rec  IN ic_item_cnv%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN

  INSERT INTO ic_item_cnv
  ( item_id
  , lot_id
  , um_type
  , type_factor
  , creation_date
  , last_update_date
  , created_by
  , last_updated_by
  , trans_cnt
  , delete_mark
  , text_code
  , type_factorrev
  , last_update_login
  )
  VALUES
  ( p_ic_item_cnv_rec.item_id
  , p_ic_item_cnv_rec.lot_id
  , p_ic_item_cnv_rec.um_type
  , p_ic_item_cnv_rec.type_factor
  , p_ic_item_cnv_rec.creation_date
  , p_ic_item_cnv_rec.last_update_date
  , p_ic_item_cnv_rec.created_by
  , p_ic_item_cnv_rec.last_updated_by
  , p_ic_item_cnv_rec.trans_cnt
  , p_ic_item_cnv_rec.delete_mark
  , p_ic_item_cnv_rec.text_code
  , p_ic_item_cnv_rec.type_factorrev
  , p_ic_item_cnv_rec.last_update_login
  );

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                           , 'Insert_Ic_Item_Cnv'
                          );
--  END IF;
    RETURN FALSE;

END Insert_Ic_Item_Cnv;

END GMI_ITEM_LOT_CONV_PVT;

/
