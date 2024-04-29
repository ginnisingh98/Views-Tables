--------------------------------------------------------
--  DDL for Package Body GMI_LOTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_LOTS_PVT" AS
--$Header: GMIVLOTB.pls 115.3 99/10/21 07:50:54 porting ship  $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMIVLOTB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMI_LOTS_PVT                                                          |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This package contains all utility functions that insert/update Lot    |
--|    related tables                                                        |
--|                                                                          |
--| CONTENTS                                                                 |
--|    Insert_Ic_Lots_Mst                                                    |
--|    Insert_Ic_Lots_Cpg                                                    |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
-- Body end of comments
-- Global variables
G_PKG_NAME     CONSTANT  VARCHAR2(30) := 'GMI_LOTS_PVT';
IC$DEFAULT_LOT           VARCHAR2(255);
-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Insert_Ic_Lots_Mst                                                    |
--|                                                                          |
--|  USAGE                                                                   |
--|    Insert a row into ic_lots_mst                                         |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This procedure inserts a row into ic_lots_mst                         |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_ic_lots_mst_rec IN RECORD - Lots Master Details                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If insert successful                                          |
--|    FALSE - If insert fails                                               |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--|  20-OCT-1999 H.Verdding Added Atribute Fields To Insert                  |
--|              B1042722                                                    |
--+==========================================================================+
-- Func end of comments
FUNCTION Insert_Ic_Lots_Mst
(p_ic_lots_mst_rec IN ic_lots_mst%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN

  INSERT INTO ic_lots_mst
  ( item_id
  , lot_no
  , sublot_no
  , lot_id
  , lot_desc
  , qc_grade
  , expaction_code
  , expaction_date
  , lot_created
  , expire_date
  , retest_date
  , strength
  , inactive_ind
  , origination_type
  , shipvend_id
  , vendor_lot_no
  , creation_date
  , last_update_date
  , created_by
  , last_updated_by
  , trans_cnt
  , delete_mark
  , text_code
  , attribute1
  , attribute2
  , attribute3
  , attribute4
  , attribute5
  , attribute6
  , attribute7
  , attribute8
  , attribute9
  , attribute10
  , attribute11
  , attribute12
  , attribute13
  , attribute14
  , attribute15
  , attribute16
  , attribute17
  , attribute18
  , attribute19
  , attribute20
  , attribute21
  , attribute22
  , attribute23
  , attribute24
  , attribute25
  , attribute26
  , attribute27
  , attribute28
  , attribute29
  , attribute30
  , attribute_category
  )
  VALUES
  ( p_ic_lots_mst_rec.item_id
  , p_ic_lots_mst_rec.lot_no
  , p_ic_lots_mst_rec.sublot_no
  , p_ic_lots_mst_rec.lot_id
  , p_ic_lots_mst_rec.lot_desc
  , p_ic_lots_mst_rec.qc_grade
  , p_ic_lots_mst_rec.expaction_code
  , p_ic_lots_mst_rec.expaction_date
  , p_ic_lots_mst_rec.lot_created
  , p_ic_lots_mst_rec.expire_date
  , p_ic_lots_mst_rec.retest_date
  , p_ic_lots_mst_rec.strength
  , p_ic_lots_mst_rec.inactive_ind
  , p_ic_lots_mst_rec.origination_type
  , p_ic_lots_mst_rec.shipvend_id
  , p_ic_lots_mst_rec.vendor_lot_no
  , p_ic_lots_mst_rec.creation_date
  , p_ic_lots_mst_rec.last_update_date
  , p_ic_lots_mst_rec.created_by
  , p_ic_lots_mst_rec.last_updated_by
  , p_ic_lots_mst_rec.trans_cnt
  , p_ic_lots_mst_rec.delete_mark
  , p_ic_lots_mst_rec.text_code
  , p_ic_lots_mst_rec.attribute1
  , p_ic_lots_mst_rec.attribute2
  , p_ic_lots_mst_rec.attribute3
  , p_ic_lots_mst_rec.attribute4
  , p_ic_lots_mst_rec.attribute5
  , p_ic_lots_mst_rec.attribute6
  , p_ic_lots_mst_rec.attribute7
  , p_ic_lots_mst_rec.attribute8
  , p_ic_lots_mst_rec.attribute9
  , p_ic_lots_mst_rec.attribute10
  , p_ic_lots_mst_rec.attribute11
  , p_ic_lots_mst_rec.attribute12
  , p_ic_lots_mst_rec.attribute13
  , p_ic_lots_mst_rec.attribute14
  , p_ic_lots_mst_rec.attribute15
  , p_ic_lots_mst_rec.attribute16
  , p_ic_lots_mst_rec.attribute17
  , p_ic_lots_mst_rec.attribute18
  , p_ic_lots_mst_rec.attribute19
  , p_ic_lots_mst_rec.attribute20
  , p_ic_lots_mst_rec.attribute21
  , p_ic_lots_mst_rec.attribute22
  , p_ic_lots_mst_rec.attribute23
  , p_ic_lots_mst_rec.attribute24
  , p_ic_lots_mst_rec.attribute25
  , p_ic_lots_mst_rec.attribute26
  , p_ic_lots_mst_rec.attribute27
  , p_ic_lots_mst_rec.attribute28
  , p_ic_lots_mst_rec.attribute29
  , p_ic_lots_mst_rec.attribute30
  , p_ic_lots_mst_rec.attribute_category
  );

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_lots_mst'
                            );
--  END IF;
    RETURN FALSE;

END Insert_Ic_Lots_Mst;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Insert_Ic_Lots_Cpg                                                    |
--|                                                                          |
--|  USAGE                                                                   |
--|    Insert a row into ic_lots_cpg                                         |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This procedure inserts a row into ic_lots_cpg                         |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_ic_lots_cpg_rec IN RECORD - CPG Lots Additional Attributes          |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If insert successful                                          |
--|    FALSE - If insert fails                                               |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Insert_Ic_Lots_Cpg
(p_ic_lots_cpg_rec  IN ic_lots_cpg%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN

  INSERT INTO ic_lots_cpg
  ( item_id
  , lot_id
  , ic_matr_date
  , ic_hold_date
  , created_by
  , creation_date
  , last_update_date
  , last_updated_by
  , last_update_login
  )
  VALUES
  ( p_ic_lots_cpg_rec.item_id
  , p_ic_lots_cpg_rec.lot_id
  , p_ic_lots_cpg_rec.ic_matr_date
  , p_ic_lots_cpg_rec.ic_hold_date
  , p_ic_lots_cpg_rec.created_by
  , p_ic_lots_cpg_rec.creation_date
  , p_ic_lots_cpg_rec.last_update_date
  , p_ic_lots_cpg_rec.last_updated_by
  , p_ic_lots_cpg_rec.last_update_login
  );

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_lots_cpg'
                            );
--  END IF;
    RETURN FALSE;

END Insert_Ic_Lots_Cpg;

END GMI_LOTS_PVT;

/
