--------------------------------------------------------
--  DDL for Package Body GMI_CMP_TRAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_CMP_TRAN_PVT" AS
--$Header: GMIVCMPB.pls 115.4 2000/02/03 04:23:40 pkm ship      $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMIVCMPB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMI_CMP_TRAN_PVT                                                      |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This package contains all utility functions that performs validations |
--|    and insert/update of inventory                                        |
--|                                                                          |
--| CONTENTS                                                                 |
--|    Update_Quantity_Transaction                                           |
--|    Update_Movement                                                       |
--|    Update_Lot_Status                                                     |
--|    Update_Qc_Grade                                                       |
--|    Insert_Ic_Tran_Pnd                                                    |
--|    Update_Ic_Loct_Inv                                                    |
--|    Update_Summ_Inv                                                       |
--|    Update_Ic_Loct_Inv_Lot_Status                                         |
--|    Update_Summ_Inv_Qc_Grade                                              |
--|                                                                          |
--| HISTORY                                                                  |
--|    Liz Enstone 2 Jan 2000 BUg 1159923 Change message name from SY_API_   |
--|                UNABLE_TO_GET_SURROGATE to IC_API_UNABLE....              |
--|                                                                          |
--+==========================================================================+
-- Body end of comments

-- Global variables
G_PKG_NAME     CONSTANT  VARCHAR2(30) := 'GMI_CMP_TRAN_PVT';
IC$DEFAULT_LOT           VARCHAR2(255);
-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Update_Quantity_Transaction                                           |
--|                                                                          |
--|  USAGE                                                                   |
--|    Perform Post-update validation for Inventory Posting                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function controls the update functions associated with the       |
--|    inventory quantities API                                              |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If validation successful                                      |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION update_quantity_transaction
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS
l_cmp_tran_rec cmp_tran_typ;

BEGIN

  -- Move completed transaction record to local
  l_cmp_tran_rec   :=p_cmp_tran_rec;

  -- If trans_id not supplied then get it
  IF (l_cmp_tran_rec.trans_id  = 0)
  THEN
  SELECT gem5_trans_id_s.nextval INTO l_cmp_tran_rec.trans_id FROM dual;
    IF (l_cmp_tran_rec.trans_id <= 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_SURROGATE');
      FND_MESSAGE.SET_TOKEN('SKEY','trans_id');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Perform update according to type of transaction
  IF (l_cmp_tran_rec.doc_type = 'CREI' OR
      l_cmp_tran_rec.doc_type = 'ADJI' OR
      l_cmp_tran_rec.doc_type = 'TRNI')
  THEN
    IF NOT Update_movement(l_cmp_tran_rec)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSIF (l_cmp_tran_rec.doc_type = 'STSI')
  THEN
    IF NOT Update_lot_status(l_cmp_tran_rec)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSIF (l_cmp_tran_rec.doc_type = 'GRDI')
  THEN
    IF NOT Update_QC_grade(l_cmp_tran_rec)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Update_Quantity_Transaction'
                            );
--  END IF;
    RETURN FALSE;

END Update_Quantity_Transaction;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Update_Movement                                                       |
--|                                                                          |
--|  USAGE                                                                   |
--|    Perform Post-update validation for Inventory Posting                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function controls the update functions associated with the       |
--|    inventory movement transactions. This applies to create/adjust        |
--|    and move inventory                                                    |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If validation successful                                      |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Update_Movement
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS
l_cmp_tran_rec   cmp_tran_typ;

BEGIN

  -- Move completed transaction record to local
  l_cmp_tran_rec := p_cmp_tran_rec;

  -- insert row in ic_tran_cmp
  IF NOT insert_ic_tran_cmp(l_cmp_tran_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Update location inventory
  IF NOT Update_ic_loct_inv(l_cmp_tran_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Update inventory summary
  IF NOT Update_ic_summ_inv(l_cmp_tran_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Update_Movement'
                            );
--  END IF;
    RETURN FALSE;

END Update_Movement;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Update_Lot_Status                                                     |
--|                                                                          |
--|  USAGE                                                                   |
--|    Perform Post-update validation for Inventory Posting                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function controls the update functions associated with the       |
--|    change Lot Status transactions                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If validation successful                                      |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION update_lot_status
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS
l_cmp_tran_rec   cmp_tran_typ;

BEGIN

  -- Move completed transaction record to local
  l_cmp_tran_rec := p_cmp_tran_rec;

  -- insert row in ic_tran_cmp
  IF NOT insert_ic_tran_cmp(l_cmp_tran_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Update location inventory
  IF NOT Update_ic_loct_inv_LOT_STATUS(l_cmp_tran_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Update_Lot_Status'
                            );
--  END IF;
    RETURN FALSE;


END Update_Lot_Status;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Update_Qc_Grade                                                       |
--|                                                                          |
--|  USAGE                                                                   |
--|    Perform Post-update validation for Inventory Posting                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function controls the update functions associated with the       |
--|    change QC Grade Transactions                                          |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If validation successful                                      |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Update_Qc_Grade
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS
l_cmp_tran_rec   cmp_tran_typ;

BEGIN

  -- Move completed transaction record to local
  l_cmp_tran_rec := p_cmp_tran_rec;

  -- insert row in ic_tran_cmp
  IF NOT insert_ic_tran_cmp(l_cmp_tran_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Update lots Master for new QC grade
  IF (p_cmp_tran_rec.line_type = 1)
  THEN
    UPDATE ic_lots_mst
    SET
      qc_grade = p_cmp_tran_rec.qc_grade
    , last_updated_by  = p_cmp_tran_rec.user_id
    , last_update_date = SYSDATE
    WHERE
        item_id = p_cmp_tran_rec.item_id
    AND lot_id  = p_cmp_tran_rec.lot_id;
  END IF;

  -- Update summary inventory
  IF NOT Update_ic_summ_inv_QC_GRADE(l_cmp_tran_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Update_Qc_Grade'
                            );
--  END IF;
    RETURN FALSE;

END Update_Qc_Grade;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Insert_Ic_Tran_Cmp                                                    |
--|                                                                          |
--|  USAGE                                                                   |
--|    Inserts a row into ic_tran_cmp                                        |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function inserts a row into ic_tran_cmp                          |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If validation successful                                      |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Insert_Ic_Tran_Cmp
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS

BEGIN

  INSERT INTO ic_tran_cmp
  ( item_id
  , line_id
  , trans_id
  , co_code
  , orgn_code
  , whse_code
  , lot_id
  , location
  , doc_id
  , doc_type
  , doc_line
  , line_type
  , reason_code
  , creation_date
  , trans_date
  , trans_qty
  , trans_qty2
  , qc_grade
  , lot_status
  , trans_stat
  , trans_um
  , trans_um2
  , op_code
  , gl_posted_ind
  , event_id
  , text_code
  , last_update_date
  , created_by
  , last_updated_by
  )
  VALUES
  ( p_cmp_tran_rec.item_id
  , p_cmp_tran_rec.line_id
  , p_cmp_tran_rec.trans_id
  , p_cmp_tran_rec.co_code
  , p_cmp_tran_rec.orgn_code
  , p_cmp_tran_rec.whse_code
  , p_cmp_tran_rec.lot_id
  , p_cmp_tran_rec.location
  , p_cmp_tran_rec.doc_id
  , p_cmp_tran_rec.doc_type
  , p_cmp_tran_rec.doc_line
  , p_cmp_tran_rec.line_type
  , p_cmp_tran_rec.reason_code
  , SYSDATE
  , p_cmp_tran_rec.trans_date
  , p_cmp_tran_rec.trans_qty
  , p_cmp_tran_rec.trans_qty2
  , p_cmp_tran_rec.qc_grade
  , p_cmp_tran_rec.lot_status
  , p_cmp_tran_rec.trans_stat
  , p_cmp_tran_rec.trans_um
  , p_cmp_tran_rec.trans_um2
  , p_cmp_tran_rec.user_id
  , p_cmp_tran_rec.gl_posted_ind
  , p_cmp_tran_rec.event_id
  , p_cmp_tran_rec.text_code
  , SYSDATE
  , p_cmp_tran_rec.user_id
  , p_cmp_tran_rec.user_id

  );

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_tran_cmp'
                            );
--  END IF;
    RETURN FALSE;

END Insert_Ic_Tran_Cmp;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Update_Ic_Loct_Inv                                                    |
--|                                                                          |
--|  USAGE                                                                   |
--|    Update inventory level on ic_loct_inv                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function updates the on-hand inventory on ic_loct_inv            |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If validation successful                                      |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Update_Ic_Loct_Inv
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS

CURSOR location_inv IS
SELECT
  *
FROM
  ic_loct_inv
WHERE
    item_id   = p_cmp_tran_rec.item_id
AND whse_code = p_cmp_tran_rec.whse_code
AND lot_id    = p_cmp_tran_rec.lot_id
AND location  = p_cmp_tran_rec.location
FOR UPDATE;

-- Local variables
l_ic_loct_inv  ic_loct_inv%ROWTYPE;

BEGIN

-- Check if inventory exists at location

  OPEN location_inv;

  FETCH location_inv INTO l_ic_loct_inv;

  IF (location_inv%NOTFOUND)
  THEN
  -- Insert location inventory
    IF NOT Insert_Ic_Loct_Inv(p_cmp_tran_rec)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  CLOSE location_inv;

  UPDATE ic_loct_inv
  SET
    loct_onhand      = loct_onhand + p_cmp_tran_rec.trans_qty
  , loct_onhand2     = loct_onhand2 + p_cmp_tran_rec.trans_qty2
  , last_updated_by  = p_cmp_tran_rec.user_id
  , last_update_date = SYSDATE
  WHERE
      item_id   = p_cmp_tran_rec.item_id
  AND whse_code = p_cmp_tran_rec.whse_code
  AND lot_id    = p_cmp_tran_rec.lot_id
  AND location  = p_cmp_tran_rec.location;

  -- If inventory movment then update lot_status for ic_loct_inv
  IF (p_cmp_tran_rec.doc_type = 'TRNI' AND
      p_cmp_tran_rec.line_type = 1)
  THEN
    UPDATE ic_loct_inv
    SET
      lot_status       = p_cmp_tran_rec.lot_status
    , last_updated_by  = p_cmp_tran_rec.user_id
    , last_update_date = SYSDATE
    WHERE
        item_id   = p_cmp_tran_rec.item_id
    AND whse_code = p_cmp_tran_rec.whse_code
    AND lot_id    = p_cmp_tran_rec.lot_id
    AND location  = p_cmp_tran_rec.location;
  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Update_ic_loct_inv'
                            );
--  END IF;
    RETURN FALSE;

END Update_Ic_Loct_Inv;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Insert_Ic_Loct_Inv                                                    |
--|                                                                          |
--|  USAGE                                                                   |
--|    Insert row into ic_loct_inv                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function creates a new row in ic_loct_inv                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If validation successful                                      |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Insert_Ic_Loct_Inv
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS

BEGIN

  INSERT INTO Ic_Loct_Inv
  ( item_id
  , whse_code
  , lot_id
  , location
  , loct_onhand
  , loct_onhand2
  , lot_status
  , qchold_res_code
  , delete_mark
  , text_code
  , last_updated_by
  , created_by
  , last_update_date
  , creation_date
  , last_update_login
  )
  VALUES
  ( p_cmp_tran_rec.item_id
  , p_cmp_tran_rec.whse_code
  , p_cmp_tran_rec.lot_id
  , p_cmp_tran_rec.location
  , 0
  , NULL
  , p_cmp_tran_rec.lot_status
  , NULL
  , 0
  , p_cmp_tran_rec.text_code
  , p_cmp_tran_rec.user_id
  , p_cmp_tran_rec.user_id
  , SYSDATE
  , SYSDATE
  , TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'))
  );

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_loct_inv'
                            );
--  END IF;
    RETURN FALSE;

END Insert_Ic_Loct_Inv;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Update_Ic_Summ_Inv                                                    |
--|                                                                          |
--|  USAGE                                                                   |
--|    Update inventory balances on ic_summ_inv                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function updates the on-hand inventory balances on ic_summ_inv   |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If validation successful                                      |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Update_Ic_Summ_Inv
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS
-- Cursors
CURSOR lot_status IS
SELECT
  *
FROM
  ic_lots_sts
WHERE
  lot_status = p_cmp_tran_rec.lot_status;

CURSOR summary_inv IS
SELECT
  *
FROM
  ic_summ_inv
WHERE
    item_id   = p_cmp_tran_rec.item_id
AND whse_code = p_cmp_tran_rec.whse_code
AND ( qc_grade  = p_cmp_tran_rec.qc_grade
      OR qc_grade is NULL)
FOR UPDATE;

-- Local variables
l_ic_lots_sts  ic_lots_sts%ROWTYPE;
l_ic_summ_inv  ic_summ_inv%ROWTYPE;
l_qty          NUMBER  := 0;
l_qty2         NUMBER  := 0;
l_prod_qty     NUMBER  := 0;
l_prod_qty2    NUMBER  := 0;
l_order_qty    NUMBER  := 0;
l_order_qty2   NUMBER  := 0;
l_ship_qty     NUMBER  := 0;
l_ship_qty2    NUMBER  := 0;
l_summ_inv_id  ic_summ_inv.summ_inv_id%TYPE  :=0;

BEGIN
  -- Retrieve lot status indicators

  OPEN lot_status;

  FETCH lot_status INTO l_ic_lots_sts;
  IF (lot_status%NOTFOUND)
  THEN
    l_ic_lots_sts.nettable_ind   :=1;
    l_ic_lots_sts.order_proc_ind :=1;
    l_ic_lots_sts.prod_ind       :=1;
    l_ic_lots_sts.shipping_ind   :=1;
  END IF;

  CLOSE lot_status;


  IF (l_ic_lots_sts.nettable_ind  = 1)
  THEN
    l_qty  := p_cmp_tran_rec.trans_qty;
    l_qty2 := p_cmp_tran_rec.trans_qty2;
  END IF;

  IF (l_ic_lots_sts.order_proc_ind  = 1)
  THEN
    l_order_qty  := p_cmp_tran_rec.trans_qty;
    l_order_qty2 := p_cmp_tran_rec.trans_qty2;
  END IF;

  IF (l_ic_lots_sts.prod_ind  = 1)
  THEN
    l_prod_qty   := p_cmp_tran_rec.trans_qty;
    l_prod_qty2  := p_cmp_tran_rec.trans_qty2;
  END IF;

  IF (l_ic_lots_sts.shipping_ind  = 1)
  THEN
    l_ship_qty   := p_cmp_tran_rec.trans_qty;
    l_ship_qty2  := p_cmp_tran_rec.trans_qty2;
  END IF;

  -- Check if inventory summary row exists and if not create it
  OPEN summary_inv;

  FETCH summary_inv INTO l_ic_summ_inv;

  IF (summary_inv%NOTFOUND)
  THEN
    SELECT gem5_summ_inv_id_s.nextval INTO l_summ_inv_id FROM dual;
    IF (l_summ_inv_id <= 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_SURROGATE');
      FND_MESSAGE.SET_TOKEN('SKEY','summ_inv_id');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
    INSERT INTO ic_summ_inv
    ( summ_inv_id
    , item_id
    , whse_code
    , qc_grade
    , onhand_qty
    , onhand_qty2
    , onhand_prod_qty
    , onhand_prod_qty2
    , onhand_order_qty
    , onhand_order_qty2
    , onhand_ship_qty
    , onhand_ship_qty2
    , onpurch_qty
    , onpurch_qty2
    , onprod_qty
    , onprod_qty2
    , committedsales_qty
    , committedsales_qty2
    , committedprod_qty
    , committedprod_qty2
    , intransit_qty
    , intransit_qty2
    , last_updated_by
    , created_by
    , last_update_date
    , creation_date
    , last_update_login
    , program_application_id
    , program_id
    , program_update_date
    , request_id
    )
    VALUES
    ( l_summ_inv_id
    , p_cmp_tran_rec.item_id
    , p_cmp_tran_rec.whse_code
    , p_cmp_tran_rec.qc_grade
    , 0
    , NULL
    , 0
    , NULL
    , 0
    , NULL
    , 0
    , NULL
    , 0
    , NULL
    , 0
    , NULL
    , 0
    , NULL
    , 0
    , NULL
    , 0
    , NULL
    , p_cmp_tran_rec.user_id
    , p_cmp_tran_rec.user_id
    , SYSDATE
    , SYSDATE
    , TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'))
    , NULL
    , NULL
    , NULL
    , NULL
    );
    END IF;
  END IF;

  CLOSE summary_inv;
  UPDATE ic_summ_inv
  SET
    onhand_qty        = onhand_qty        + l_qty
  , onhand_qty2       = onhand_qty2       + l_qty2
  , onhand_prod_qty   = onhand_prod_qty   + l_prod_qty
  , onhand_prod_qty2  = onhand_prod_qty2  + l_prod_qty2
  , onhand_order_qty  = onhand_order_qty  + l_order_qty
  , onhand_order_qty2 = onhand_order_qty2 + l_order_qty2
  , onhand_ship_qty   = onhand_ship_qty   + l_ship_qty
  , onhand_ship_qty2  = onhand_ship_qty2  + l_ship_qty2
  , last_updated_by   = p_cmp_tran_rec.user_id
  , last_update_date  = SYSDATE
  WHERE
      item_id   = p_cmp_tran_rec.item_id
  AND whse_code = p_cmp_tran_rec.whse_code
  AND (qc_grade  = p_cmp_tran_rec.qc_grade
        OR qc_grade is NULL);

  RETURN TRUE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Update_ic_summ_inv'
                            );
--  END IF;
    RETURN FALSE;


END Update_Ic_Summ_Inv;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Update_Ic_Loct_Inv_Lot_Status                                         |
--|                                                                          |
--|  USAGE                                                                   |
--|    Update ic_loct_inv for Lot Status change                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function retrieves the on-hand balances for updating the         |
--|    summary inventory For 'After' transactions, the lost_status is        |
--|    also updated                                                          |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transaction Details              |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If update successful                                          |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Update_Ic_Loct_Inv_Lot_Status
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS
-- Cursors
CURSOR location_inv IS
SELECT
  loct_onhand
, loct_onhand2
FROM
  ic_loct_inv
WHERE
    item_id   = p_cmp_tran_rec.item_id
AND whse_code = p_cmp_tran_rec.whse_code
AND lot_id    = p_cmp_tran_rec.lot_id
AND location  = p_cmp_tran_rec.location;

-- local variables
l_cmp_tran_rec cmp_tran_typ;
l_qty          NUMBER := 0;
l_qty2         NUMBER := 0;

BEGIN

  -- Move completed transaction record to local
  l_cmp_tran_rec := p_cmp_tran_rec;

  -- Get on-hand balances at this location
  OPEN location_inv;

  FETCH location_inv INTO
    l_qty
  , l_qty2;

  IF (location_inv%NOTFOUND)
  THEN
  -- Insert location inventory
    IF NOT Insert_Ic_Loct_Inv(p_cmp_tran_rec)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  CLOSE location_inv;

  -- Update transaction record with quantities
  -- If 'After' transaction then update lot_status
  IF (l_cmp_tran_rec.line_type = -1)
  THEN
    l_cmp_tran_rec.trans_qty  := 0 - l_qty;
    l_cmp_tran_rec.trans_qty2 := 0 - l_qty2;
  ELSE
    l_cmp_tran_rec.trans_qty  := l_qty;
    l_cmp_tran_rec.trans_qty2 := l_qty2;
    UPDATE ic_loct_inv
    SET
      lot_status = l_cmp_tran_rec.lot_status
    , last_updated_by  = p_cmp_tran_rec.user_id
    , last_update_date = SYSDATE
    WHERE
	item_id   = p_cmp_tran_rec.item_id
    AND whse_code = p_cmp_tran_rec.whse_code
    AND lot_id    = p_cmp_tran_rec.lot_id
    AND location  = p_cmp_tran_rec.location;
  END IF;

  -- Update inventory summary
  IF NOT Update_ic_summ_inv(l_cmp_tran_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Update_ic_loct_inv_Lot_Status'
                            );
--  END IF;
    RETURN FALSE;


END Update_Ic_Loct_Inv_Lot_Status;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Update_Ic_Summ_Inv_Qc_Grade                                           |
--|                                                                          |
--|  USAGE                                                                   |
--|    Update ic_summ_inv for QC Grade change                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This function retrieves the on-hand balances for updating the         |
--|    summary inventory                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_cmp_tran_rec IN RECORD - Inventory Transction Details               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If update successful                                          |
--|    FALSE - If error detected                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Update_Ic_Summ_Inv_Qc_Grade
(p_cmp_tran_rec  IN cmp_tran_typ)
RETURN BOOLEAN
IS
-- Cursors
CURSOR location_inv IS
SELECT
  whse_code,
  lot_status
, SUM(loct_onhand)
, SUM(loct_onhand2)
FROM
  ic_loct_inv
WHERE
    item_id  = p_cmp_tran_rec.item_id
AND lot_id   = p_cmp_tran_rec.lot_id
GROUP BY
  whse_code,lot_status
ORDER BY
  whse_code;

-- local variables
l_cmp_tran_rec cmp_tran_typ;
l_whse_code    ic_loct_inv.whse_code%TYPE;
l_lot_status   ic_loct_inv.lot_status%TYPE;
l_qty          NUMBER := 0;
l_qty2         NUMBER := 0;

BEGIN
  -- Move completed transaction record to local
  l_cmp_tran_rec   :=p_cmp_tran_rec;

  -- Get warehouse and on-hand balances
  OPEN location_inv;

  LOOP

    FETCH location_inv INTO
      l_whse_code,
      l_lot_status
    , l_qty, l_qty2;

    EXIT WHEN location_inv%NOTFOUND;

    -- Update transaction record with warehouse and quantities
    l_cmp_tran_rec.whse_code  := l_whse_code;
    l_cmp_tran_rec.lot_status := l_lot_status;
    IF (l_cmp_tran_rec.line_type = -1)
    THEN
      l_cmp_tran_rec.trans_qty  := 0 - l_qty;
      l_cmp_tran_rec.trans_qty2 := 0 - l_qty2;
    ELSE
      l_cmp_tran_rec.trans_qty  := l_qty;
      l_cmp_tran_rec.trans_qty2 := l_qty2;
    END IF;
    -- Update inventory summary
    IF NOT Update_ic_summ_inv(l_cmp_tran_rec)
    THEN
      CLOSE location_inv;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;

  CLOSE location_inv;

  RETURN TRUE;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN
--  IF FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--  THEN
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Update_ic_summ_inv_Qc_Grade'
                            );
--  END IF;
    RETURN FALSE;


END Update_Ic_Summ_Inv_Qc_Grade;

END GMI_CMP_TRAN_PVT;

/
