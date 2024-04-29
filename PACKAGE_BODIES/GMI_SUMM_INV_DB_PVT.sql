--------------------------------------------------------
--  DDL for Package Body GMI_SUMM_INV_DB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_SUMM_INV_DB_PVT" AS
/*  $Header: GMIVSUMB.pls 115.8 2002/04/10 09:14:43 pkm ship      $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVSUMB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For DML Actions           |
 |     For IC_SUMM_INV                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     07-MAR-2001  Jalaj Srivastava
 |                  Bug 1662876
 |     08-JAN-2002  Joe DiIorio 11.5.1I BUG#2043337
 |     Make all qty 2 fields get added with zero when null.
 +=========================================================================+
  API Name  : GMI_SUMM_INV_DB_PVT
  Type      : Public
  Function  : This package contains private procedures used to create
              IC_SUMM_INV transactions
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes


  Body end of comments
*/
/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_SUMM_INV_DB_PVT';
/*  Api start of comments */

FUNCTION UPDATE_IC_SUMM_INV
(
 p_summ_inv IN IC_SUMM_INV%ROWTYPE
)
RETURN BOOLEAN
IS

err_num       NUMBER;
err_msg       VARCHAR2(100);

BEGIN

IF ( p_summ_inv.qc_grade is NULL) THEN

--Jalaj Srivastava Bug 1662876
--nvl is required with qty2 since for pending txns qty2 is null
UPDATE IC_SUMM_INV
SET
    onhand_qty           = onhand_qty + p_summ_inv.onhand_qty,
    onhand_qty2          = onhand_qty2 + NVL(p_summ_inv.onhand_qty2,0),
    onhand_prod_qty      = onhand_prod_qty +  p_summ_inv.onhand_prod_qty,
    onhand_prod_qty2     = NVL(onhand_prod_qty2,0) +
                           NVL(p_summ_inv.onhand_prod_qty2,0),
    onhand_order_qty     = onhand_order_qty +  p_summ_inv.onhand_order_qty,
    onhand_order_qty2    = NVL(onhand_order_qty2,0) +
                           NVL(p_summ_inv.onhand_order_qty2,0),
    onhand_ship_qty      = onhand_ship_qty +  p_summ_inv.onhand_ship_qty,
    onhand_ship_qty2     = NVL(onhand_ship_qty2,0) +
                           NVL(p_summ_inv.onhand_ship_qty2,0),
    onpurch_qty          = onpurch_qty +  p_summ_inv.onpurch_qty,
    onpurch_qty2         = NVL(onpurch_qty2,0) +
                           NVL(p_summ_inv.onpurch_qty2,0),
    onprod_qty           = onprod_qty +  p_summ_inv.onprod_qty,
    onprod_qty2          = NVL(onprod_qty2,0) +
                           NVL(p_summ_inv.onprod_qty2,0),
    committedsales_qty   = committedsales_qty + p_summ_inv.committedsales_qty,
    committedsales_qty2  = NVL(committedsales_qty2,0) +
                           NVL(p_summ_inv.committedsales_qty2,0),
    committedprod_qty    = committedprod_qty +  p_summ_inv.committedprod_qty,
    committedprod_qty2   = NVL(committedprod_qty2,0) +
                           NVL(p_summ_inv.committedprod_qty2,0),
    intransit_qty        = intransit_qty +  p_summ_inv.intransit_qty,
    intransit_qty2       = NVL(intransit_qty2,0) +
                           NVL(p_summ_inv.intransit_qty2,0),
    last_updated_by      = p_summ_inv.last_updated_by,
    created_by           = p_summ_inv.created_by,
    last_update_date     = p_summ_inv.last_update_date,
    creation_date        = p_summ_inv.creation_date
WHERE item_id   = p_summ_inv.item_id
AND  whse_code = p_summ_inv.whse_code
AND  qc_grade  IS NULL;

ELSE

UPDATE IC_SUMM_INV
SET
    onhand_qty           = onhand_qty + p_summ_inv.onhand_qty,
    onhand_qty2          = onhand_qty2 +  NVL(p_summ_inv.onhand_qty2,0),
    onhand_prod_qty      = onhand_prod_qty +  p_summ_inv.onhand_prod_qty,
    onhand_prod_qty2     = NVL(onhand_prod_qty2,0) +
                           NVL(p_summ_inv.onhand_prod_qty2,0),
    onhand_order_qty     = onhand_order_qty +  p_summ_inv.onhand_order_qty,
    onhand_order_qty2    = NVL(onhand_order_qty2,0) +
                           NVL(p_summ_inv.onhand_order_qty2,0),
    onhand_ship_qty      = onhand_ship_qty +  p_summ_inv.onhand_ship_qty,
    onhand_ship_qty2     = NVL(onhand_ship_qty2,0) +
                           NVL(p_summ_inv.onhand_ship_qty2,0),
    onpurch_qty          = onpurch_qty +  p_summ_inv.onpurch_qty,
    onpurch_qty2         = NVL(onpurch_qty2,0) +
                           NVL(p_summ_inv.onpurch_qty2,0),
    onprod_qty           = onprod_qty +  p_summ_inv.onprod_qty,
    onprod_qty2          = NVL(onprod_qty2,0) +
                           NVL(p_summ_inv.onprod_qty2,0),
    committedsales_qty   = committedsales_qty + p_summ_inv.committedsales_qty,
    committedsales_qty2  = NVL(committedsales_qty2,0) +
                           NVL(p_summ_inv.committedsales_qty2,0),
    committedprod_qty    = committedprod_qty +  p_summ_inv.committedprod_qty,
    committedprod_qty2   = NVL(committedprod_qty2,0) +
                           NVL(p_summ_inv.committedprod_qty2,0),
    intransit_qty        = intransit_qty +  p_summ_inv.intransit_qty,
    intransit_qty2       = NVL(intransit_qty2,0) +
                           NVL(p_summ_inv.intransit_qty2,0),
    last_updated_by      = p_summ_inv.last_updated_by,
    created_by           = p_summ_inv.created_by,
    last_update_date     = p_summ_inv.last_update_date,
    creation_date        = p_summ_inv.creation_date
WHERE item_id   = p_summ_inv.item_id
AND  whse_code  = p_summ_inv.whse_code
AND  qc_grade   = p_summ_inv.qc_grade;

END IF;

IF SQL%ROWCOUNT =0 THEN
  RETURN FALSE;
END IF;

RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
    WHEN OTHERS THEN
/*     err_num :=SQLCODE; */
 /*    err_msg :=SUBSTR(SQLERRM,1 ,100);*/
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'update_ic_summ_inv'
                            );
    RETURN FALSE;

END UPDATE_IC_SUMM_INV;

FUNCTION INSERT_IC_SUMM_INV
(
 p_summ_inv IN IC_SUMM_INV%ROWTYPE
)
RETURN BOOLEAN
IS
err_num NUMBER;
err_msg VARCHAR2(100);
l_summ_inv_id NUMBER;

BEGIN

/*  GET Sequence Number For SUMM_INV_ID*/

    SELECT GEM5_SUMM_INV_ID_S.nextval
    INTO   l_summ_inv_id
    FROM   dual;


INSERT INTO IC_SUMM_INV
(
 summ_inv_id,
 item_id,
 whse_code,
 qc_grade,
 onhand_qty,
 onhand_qty2,
 onhand_prod_qty,
 onhand_prod_qty2,
 onhand_order_qty,
 onhand_order_qty2,
 onhand_ship_qty,
 onhand_ship_qty2,
 onpurch_qty,
 onpurch_qty2,
 onprod_qty,
 onprod_qty2,
 committedsales_qty,
 committedsales_qty2,
 committedprod_qty,
 committedprod_qty2,
 intransit_qty,
 intransit_qty2,
 last_updated_by,
 created_by,
 last_update_date,
 creation_date
)
VALUES
(
 l_summ_inv_id,
 p_summ_inv.item_id,
 p_summ_inv.whse_code,
 p_summ_inv.qc_grade,
 p_summ_inv.onhand_qty,
 nvl(p_summ_inv.onhand_qty2,0),
 p_summ_inv.onhand_prod_qty,
 nvl(p_summ_inv.onhand_prod_qty2,0),
 p_summ_inv.onhand_order_qty,
 nvl(p_summ_inv.onhand_order_qty2,0),
 p_summ_inv.onhand_ship_qty,
 nvl(p_summ_inv.onhand_ship_qty2,0),
 p_summ_inv.onpurch_qty,
 nvl(p_summ_inv.onpurch_qty2,0),
 p_summ_inv.onprod_qty,
 nvl(p_summ_inv.onprod_qty2,0),
 p_summ_inv.committedsales_qty,
 nvl(p_summ_inv.committedsales_qty2,0),
 p_summ_inv.committedprod_qty,
 nvl(p_summ_inv.committedprod_qty2,0),
 p_summ_inv.intransit_qty,
 nvl(p_summ_inv.intransit_qty2,0),
 p_summ_inv.last_updated_by,
 p_summ_inv.created_by,
 p_summ_inv.last_update_date,
 p_summ_inv.creation_date
);

RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
/*     err_num :=SQLCODE;*/
/*     err_msg :=SUBSTR(SQLERRM,1 ,100);*/
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_summ_inv'
                            );
    RETURN FALSE;


END INSERT_IC_SUMM_INV;

FUNCTION GET_LOT_ATTRIBUTES
(
p_lot_status IN  VARCHAR2,
x_lots_sts   OUT IC_LOTS_STS%ROWTYPE
)
RETURN BOOLEAN
IS
/*  err_num NUMBER;*/
/*  err_msg VARCHAR2(100);*/

CURSOR Get_Lot_status(v_lot_status IN VARCHAR2)
IS
SELECT *
FROM   IC_LOTS_STS
WHERE  UPPER(lot_status) = UPPER(v_lot_status)
AND    DELETE_MARK <> 1;


BEGIN

   OPEN get_lot_status(p_lot_status);
   FETCH get_lot_status into x_lots_sts;

   IF (get_lot_status%NOTFOUND) THEN
	 RAISE NO_DATA_FOUND;
   END IF;


RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

    WHEN OTHERS THEN
 /*    err_num :=SQLCODE;*/
 /*    err_msg :=SUBSTR(SQLERRM,1 ,100);*/
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_summ_inv'
                            );
    RETURN FALSE;

END GET_LOT_ATTRIBUTES;


END GMI_SUMM_INV_DB_PVT;

/
