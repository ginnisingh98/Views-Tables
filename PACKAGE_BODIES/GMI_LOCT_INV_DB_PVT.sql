--------------------------------------------------------
--  DDL for Package Body GMI_LOCT_INV_DB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_LOCT_INV_DB_PVT" AS
/*  $Header: GMIVLOCB.pls 115.9 2003/03/27 20:31:22 adeshmuk ship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVLOCB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For DML Actions           |
 |     For IC_LOCT_INV                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     27-DEC-2001  J. DiIorio Bug#2117575  11.5.1I                        |
 |     Changed trni logic to update status when diff stat = 2.  A          |
 |     standard move with this doc type may cause a status update.         |
 |     Jalaj Srivastava Bug 2483644                                        |
 |     Removed code for bug 2117575 as it is already taken care            |
 |     of in GMIVQTY.validate_inventory_posting.                           |
 |     18-MAR-2003 James Bernard BUG#2847679                               |
 |     Code is added to update ic_loct_inv.last_update_date with           |
 |     SYSDATE and ic_loct_inv.last_updated_by the user who is currently   |
 |     doing the adjust immediate.                                         |
 +=========================================================================+
  API Name  : GMI_LOCT_INV_DB_PVT
  Type      : Public
  Function  : This package contains private procedures used to create
              IC_SUMM_INV transactions
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/
/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_LOCT_INV_DB_PVT';

FUNCTION UPDATE_IC_LOCT_INV
(
   p_loct_inv       IN IC_LOCT_INV%ROWTYPE,
   p_status_updated IN NUMBER,
   p_qty_updated    IN NUMBER
)
RETURN BOOLEAN
IS

err_num NUMBER;
err_msg VARCHAR2(100);
bad_insert EXCEPTION;
bad_params EXCEPTION;

BEGIN

IF ( p_qty_updated =1) THEN
   /* *************************************************
      Jalaj Srivastava Bug 2483644
      Below fix is not required here since, this
      scenario is already taken care of in
      GMIVQTY.validate_inventory_posting
      ************************************************* */
   /*================================================
      27-DEC-2001  J. DiIorio Bug#2117575  11.5.1I                        |
     ==============================================*/
     /*================================================
      21-MAR-2003  James Bernard Bug#2847679
      Modified the update statement to update last_update_date with SYSDATE
      and last_updated_by with the user_id if the current user doing adjust immediate.
     ==============================================*/

     UPDATE ic_loct_inv
     SET
          loct_onhand      = loct_onhand  + p_loct_inv.loct_onhand,
	  loct_onhand2     = loct_onhand2 + p_loct_inv.loct_onhand2,
	  last_update_date = SYSDATE,
	  last_updated_by  = p_loct_inv.last_updated_by
     WHERE
	  item_id        = p_loct_inv.item_id   and
	  lot_id         = p_loct_inv.lot_id    and
	  whse_code      = p_loct_inv.whse_code and
   	  location       = p_loct_inv.location;

ELSIF (p_status_updated = 1) THEN

     /*================================================
      21-MAR-2003  James Bernard Bug#2847679
      Modified the update statement to update last_update_date with SYSDATE
      and last_updated_by with the user_id if the current user doing adjust immediate.
     ==============================================*/

   UPDATE ic_loct_inv
   SET
          lot_status       = p_loct_inv.lot_status,
          last_update_date = SYSDATE,
          last_updated_by  = p_loct_inv.last_updated_by
   WHERE
	  item_id        = p_loct_inv.item_id   and
	  lot_id         = p_loct_inv.lot_id    and
	  whse_code      = p_loct_inv.whse_code and
   	  location       = p_loct_inv.location;

ELSE
   RAISE bad_params;
END IF;

IF SQL%ROWCOUNT = 0
THEN
  /*  There was nothing to update so we must insert a row */

  IF INSERT_IC_LOCT_INV(p_loct_inv)
  THEN
    NULL;
  ELSE
    RAISE bad_insert;
  END IF;
END IF;

RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
    WHEN OTHERS THEN
    err_num :=SQLCODE;
    err_msg :=SUBSTR(SQLERRM,1 ,100);
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'update_ic_LOCT_inv'
                            );
    RETURN FALSE;

END UPDATE_IC_LOCT_INV;

FUNCTION INSERT_IC_LOCT_INV
(
 p_LOCT_inv IN IC_LOCT_INV%ROWTYPE
)
RETURN BOOLEAN
IS
err_num NUMBER;
err_msg VARCHAR2(100);

BEGIN

INSERT INTO IC_LOCT_INV
(
 item_id,
 whse_code,
 lot_id,
 location,
 loct_onhand,
 loct_onhand2,
 lot_status,
 qchold_res_code,
 delete_mark,
 text_code,
 created_by,
 creation_date,
 last_update_date,
 last_updated_by
)
VALUES
(
 p_loct_inv.item_id,
 p_loct_inv.whse_code,
 p_loct_inv.lot_id,
 p_loct_inv.location,
 p_loct_inv.loct_onhand,
 p_loct_inv.loct_onhand2,
 p_loct_inv.lot_status,
 p_loct_inv.qchold_res_code,
 p_loct_inv.delete_mark,
 p_loct_inv.text_code,
 p_loct_inv.created_by,
 p_loct_inv.creation_date,
 p_LOCT_inv.last_update_date,
 p_LOCT_inv.last_updated_by
);

RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
    err_num :=SQLCODE;
    err_msg :=SUBSTR(SQLERRM,1 ,100);
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_LOCT_inv'
                            );
  RETURN FALSE;

END INSERT_IC_LOCT_INV;

END GMI_LOCT_INV_DB_PVT;

/
