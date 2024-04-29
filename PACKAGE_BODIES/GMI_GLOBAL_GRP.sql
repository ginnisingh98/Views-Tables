--------------------------------------------------------
--  DDL for Package Body GMI_GLOBAL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_GLOBAL_GRP" AS
-- $Header: GMIGGBLB.pls 115.5 2002/10/25 18:14:30 jdiiorio gmigapib.pls $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMIGGBLB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMI_GLOBAL_GRP                                                        |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This Package contains global Inventory procedures                     |
--|                                                                          |
--| CONTENTS                                                                 |
--|                                                                          |
--|    Get_Item                                                              |
--|    Get_Lot                                                               |
--|    Get_Warehouse                                                         |
--|    Get_Loct_inv                                                          |
--|    Get_Um                                                                |
--|    Get_Lot_Inv                                                           |
--|                                                                          |
--| HISTORY                                                                  |
--|    01-OCT-1998      M.Godfrey     Created                                |
--|    16-AUG-1999      Liz Enstone   B965832(3) Remove query on             |
--|                     IC_LOTS_CPG                                          |
--|    25-OCT-2002      Joe DiIorio   Bug#2643330 - added nocopy.            |
--+==========================================================================+
-- Body end of comments

-- Proc start of comments
--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Item                                                             |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve item master details                                 |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from ic_item_mst      |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_item_no     IN VARCHAR2(32) - Item number to be retrieved          |
--|    x_ic_item_mst OUT RECORD      - Record containing ic_item_mst        |
--|    x_ic_item_cpg OUT RECORD      - Record containing ic_item_cpg        |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
-- Proc end of comments
PROCEDURE Get_Item
( p_item_no     IN  ic_item_mst.item_no%TYPE
, x_ic_item_mst OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg OUT NOCOPY ic_item_cpg%ROWTYPE
)
IS
CURSOR ic_item_mst_c1 IS
SELECT
  *
FROM
  ic_item_mst
WHERE
    item_no     = p_item_no;

CURSOR ic_item_cpg_c1(v_item_id ic_item_mst.item_id%TYPE) IS
SELECT
  *
FROM
  ic_item_cpg
WHERE
  item_id = v_item_id;

l_ic_item_mst  ic_item_mst%ROWTYPE;

BEGIN

  OPEN ic_item_mst_c1;

  FETCH ic_item_mst_c1 INTO l_ic_item_mst;

  IF (ic_item_mst_c1%NOTFOUND)
  THEN
    x_ic_item_mst.item_id := 0;
  ELSE
    x_ic_item_mst := l_ic_item_mst;
    OPEN  ic_item_cpg_c1(l_ic_item_mst.item_id);
    FETCH ic_item_cpg_c1 INTO x_ic_item_cpg;

    IF (ic_item_cpg_c1%NOTFOUND)
    THEN
      x_ic_item_cpg.ic_matr_days := 0;
      x_ic_item_cpg.ic_hold_days := 0;
    END IF;
    CLOSE ic_item_cpg_c1;
  END IF;

  CLOSE ic_item_mst_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Item;

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Lot                                                              |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve lot master details                                  |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from ic_lots_mst      |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_item_id      IN  NUMBER       - Item ID of lot to be retrieved     |
--|    p_lot_no       IN  VARCHAR2(32) - Lot number of lot to be retrieved  |
--|    p_sublot_no    IN  VARCHAR2(32) - Sublot number to be retrieved      |
--|    x_ic_lots_mst  OUT RECORD       - Record containing ic_lots_mst      |
--|    x_ic_lots_cpg  OUT RECORD       - Record containing ic_lots_cpg      |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
PROCEDURE Get_Lot
( p_item_id      IN ic_lots_mst.item_id%TYPE
, p_lot_no       IN ic_lots_mst.lot_no%TYPE
, p_sublot_no    IN ic_lots_mst.sublot_no%TYPE
, x_ic_lots_mst  OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg  OUT NOCOPY ic_lots_cpg%ROWTYPE
)
IS
CURSOR ic_lots_mst_c1 IS
SELECT
  *
FROM
  ic_lots_mst
WHERE
    lot_no      = p_lot_no
AND ( sublot_no   = p_sublot_no OR
      sublot_no is NULL)
AND item_id     = p_item_id;

CURSOR ic_lots_cpg_c1(v_lot_id ic_lots_mst.lot_id%TYPE) IS
SELECT
  *
FROM
  ic_lots_cpg
WHERE
  lot_id = v_lot_id;

l_ic_lots_mst  ic_lots_mst%ROWTYPE;

BEGIN


  OPEN ic_lots_mst_c1;

  FETCH ic_lots_mst_c1 INTO l_ic_lots_mst;
  IF (ic_lots_mst_c1%NOTFOUND)
  THEN
    x_ic_lots_mst.lot_id := -1;
  ELSE
    x_ic_lots_mst := l_ic_lots_mst;
--B965832(3) Get rid of this select
    --OPEN  ic_lots_cpg_c1(l_ic_lots_mst.lot_id);
    --FETCH ic_lots_cpg_c1 INTO x_ic_lots_cpg;
   --IF (ic_lots_cpg_c1%NOTFOUND)
   --THEN
    -- x_ic_lots_mst.lot_id := -1;
  -- END IF;
  -- CLOSE ic_lots_cpg_c1;
--B965832(3) End
  END IF;

  CLOSE ic_lots_mst_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Lot;

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_warehouse                                                        |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve warehouse details                                   |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from ic_whse_mst      |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_item_no     IN  VARCHAR2(32) - Warehouse code to be retrieved      |
--|    x_ic_whse_mst OUT RECORD       - Record containing ic_whse_mst       |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
PROCEDURE Get_Warehouse
( p_whse_code   IN  ic_whse_mst.whse_code%TYPE
, x_ic_whse_mst OUT NOCOPY ic_whse_mst%ROWTYPE
)
IS
CURSOR ic_whse_mst_c1 IS
SELECT
  *
FROM
  ic_whse_mst
WHERE
    whse_code   = p_whse_code;

BEGIN

  OPEN ic_whse_mst_c1;

  FETCH ic_whse_mst_c1 INTO x_ic_whse_mst;

  IF (ic_whse_mst_c1%NOTFOUND)
  THEN
    x_ic_whse_mst.whse_code := NULL;
  END IF;

  CLOSE ic_whse_mst_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Warehouse;

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_loct_inv                                                         |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve location inventory details                          |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from ic_loct_inv      |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_item_id     IN NUMBER      - Item ID                               |
--|    p_whse_code   IN VARCHAR2(4) - Warehouse code                        |
--|    p_lot_id      IN NUMBER      - Lot ID                                |
--|    p_location    IN VARCHAR2(4) - Location code                         |
--|    p_delete_mark IN NUMBER      - Delete marker (Default 0)             |
--|    x_ic_loct_inv IN RECORD      - Record containing ic_loct_inv details |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
PROCEDURE Get_Loct_inv
( p_item_id     IN  ic_loct_inv.item_id%TYPE
, p_whse_code   IN  ic_loct_inv.whse_code%TYPE
, p_lot_id      IN  ic_loct_inv.lot_id%TYPE
, p_location    IN  ic_loct_inv.location%TYPE
, p_delete_mark IN  ic_loct_inv.delete_mark%TYPE
, x_ic_loct_inv OUT NOCOPY ic_loct_inv%ROWTYPE
)
IS
CURSOR ic_loct_inv_c1 IS
SELECT
  *
FROM
  ic_loct_inv
WHERE
    item_id     = p_item_id
AND whse_code   = p_whse_code
AND lot_id      = p_lot_id
AND location    = p_location
AND delete_mark = p_delete_mark;

BEGIN

  OPEN ic_loct_inv_c1;

  FETCH ic_loct_inv_c1 INTO x_ic_loct_inv;

  IF (ic_loct_inv_c1%NOTFOUND)
  THEN
    x_ic_loct_inv.item_id := 0;
  END IF;

  CLOSE ic_loct_inv_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Loct_inv;

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Um                                                               |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve unit of measure details                             |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from sy_uoms_mst      |
--|    and sy_uoms_typ                                                      |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_um_code     IN VARCHAR2(4) - Unit of measure code to be retrieved  |
--|    x_sy_uoms_mst OUT RECORD     - Record containing sy_uoms_mst details |
--|    x_sy_uoms_typ OUT RECORD     - Record containing sy_uoms_typ details |
--|    x_error_code  OUT NUMBER     - Error code returned                   |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
PROCEDURE Get_Um
( p_um_code     IN  sy_uoms_mst.um_code%TYPE
, x_sy_uoms_mst OUT NOCOPY sy_uoms_mst%ROWTYPE
, x_sy_uoms_typ OUT NOCOPY sy_uoms_typ%ROWTYPE
, x_error_code  OUT NOCOPY NUMBER
)
IS
CURSOR sy_uoms_mst_c1 IS
SELECT
  *
FROM
  sy_uoms_mst
WHERE
    um_code     = p_um_code
AND delete_mark = 0;

CURSOR sy_uoms_typ_c1(v_um_type sy_uoms_typ.um_type%TYPE) IS
SELECT
  *
FROM
  sy_uoms_typ
WHERE
    um_type     = v_um_type
AND delete_mark = 0;

l_sy_uoms_mst sy_uoms_mst%ROWTYPE;

BEGIN

  x_error_code := 0;

  OPEN sy_uoms_mst_c1;

  FETCH sy_uoms_mst_c1 INTO l_sy_uoms_mst;

  IF (sy_uoms_mst_c1%NOTFOUND)
  THEN
    x_error_code := -1;
  ELSE
    x_sy_uoms_mst := l_sy_uoms_mst;
    OPEN sy_uoms_typ_c1(l_sy_uoms_mst.um_type);
    FETCH sy_uoms_typ_c1 INTO x_sy_uoms_typ;

    IF (sy_uoms_typ_c1%NOTFOUND)
    THEN
      x_error_code := -2;
    END IF;
    CLOSE sy_uoms_typ_c1;
  END IF;

  CLOSE sy_uoms_mst_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Um;

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Lot_inv                                                          |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve lot inventory on-hand values                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from ic_lot_inv       |
--|    for a given lot / sublot                                             |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_item_id     IN NUMBER      - Item ID                               |
--|    p_lot_id      IN NUMBER      - Lot ID                                |
--|    p_delete_mark IN NUMBER      - Delete marker (Default 0)             |
--|    x_lot_onhand  OUT NUMBER     - lot on-hand quantity                  |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
PROCEDURE Get_Lot_inv
( p_item_id     IN  ic_loct_inv.item_id%TYPE
, p_lot_id      IN  ic_loct_inv.lot_id%TYPE
, p_delete_mark IN  ic_loct_inv.delete_mark%TYPE
, x_lot_onhand  OUT NOCOPY NUMBER
)
IS
CURSOR ic_lot_inv_c1 IS
SELECT
  SUM(loct_onhand)
FROM
  ic_loct_inv
WHERE
    item_id     = p_item_id
AND lot_id      = p_lot_id
AND delete_mark = p_delete_mark;

BEGIN

  OPEN ic_lot_inv_c1;

  FETCH ic_lot_inv_c1 INTO x_lot_onhand;

  IF (ic_lot_inv_c1%NOTFOUND)
  THEN
    x_lot_onhand :=0;
  END IF;

  CLOSE ic_lot_inv_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Lot_inv;

END GMI_GLOBAL_GRP;

/
