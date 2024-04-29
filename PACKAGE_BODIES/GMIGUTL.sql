--------------------------------------------------------
--  DDL for Package Body GMIGUTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIGUTL" AS
/* $Header: GMIGUTLB.pls 120.2 2006/09/13 15:26:13 jgogna noship $ */

/* +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIGUTLB.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIGUTL                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This Package contains global inventory utility procedures and         |
 |    and variables.                                                        |
 |                                                                          |
 | CONTENTS                                                                 |
 |                                                                          |
 |    Get_Item                                                              |
 |    Get_Lot                                                               |
 |    Get_Warehouse                                                         |
 |    Get_Loct_inv                                                          |
 |    Get_Um                                                                |
 |    Setup                                                                 |
 |    Get_Transfer                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 +==========================================================================+
*/
/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Setup                                                                |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to setup global constants etc                                   |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_user_name VARCHAR2                                                 |
 |                                                                         |
 | RETURNS                                                                 |
 |    Global variables updated                                             |
 |                                                                         |
 | HISTORY                                                                 |
 |    Joe DiIorio 10/23/2001 11.5.1H BUG#1989860 - Removed Intrastat       |
 | profile retrieval.                                                      |
 |    Jalaj Srivastava Bug 2649596                                         |
 |    Modified the check for default user id. Earlier we were              |
 |    checking for the error condition default user id is 0 but            |
 |    0 is a valid user id for user sysadmin.                              |
 |    Tony Cataldo  Bug 2343411                                            |
 |    Added def lot desc profile option                                    |
 |    Joe DiIorio   Bug#2643440 11.5.1J - added nocopy.                    |
 +=========================================================================+
*/
FUNCTION Setup (p_user_name IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN

  DEFAULT_USER := NVL(p_user_name,'OPM');

  API_VERSION := 3.0;

  DEFAULT_LOGIN := TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'));

  GMA_GLOBAL_GRP.Get_who( p_user_name  => DEFAULT_USER
                        , x_user_id    => DEFAULT_USER_ID
                        );

  /* Removed the check for invalid users. Bug 5529003 */
  IF (DEFAULT_USER = 'OPM') THEN
	DEFAULT_USER_ID := -1;
  END IF;


  /*  Get required system constants         */
  SY$CPG_INSTALL  := FND_PROFILE.Value_Specific( name    => 'SY$CPG_INSTALL'
                                               , user_id => DEFAULT_USER_ID
                                               );
  IF (SY$CPG_INSTALL IS NULL)
  THEN
    SY$CPG_INSTALL := '0';
  END IF;

  IC$DEFAULT_LOT  := FND_PROFILE.Value_Specific( name    => 'IC$DEFAULT_LOT'
                                               , user_id => DEFAULT_USER_ID
                                               );
  IF (IC$DEFAULT_LOT IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$DEFAULT_LOT');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Bug 2343411 Set up the profile option for the specfic user for def lot desc */
  IC$DEFAULT_LOT_DESC  := FND_PROFILE.Value_Specific( name    => 'IC$DEFAULT_LOT_DESC'
                                               , user_id => DEFAULT_USER_ID
                                               );
  IF (IC$DEFAULT_LOT_DESC IS NULL)
  THEN
    IC$DEFAULT_LOT_DESC := 2;
  END IF;

  IC$DEFAULT_LOCT  := FND_PROFILE.Value_Specific( name    => 'IC$DEFAULT_LOCT'
                                                , user_id => DEFAULT_USER_ID
                                                );
  IF (IC$DEFAULT_LOCT IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$DEFAULT_LOCT');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IC$API_ALLOW_INACTIVE := FND_PROFILE.Value_Specific( name=> 'IC$API_ALLOW_INACTIVE'
                                               , user_id => DEFAULT_USER_ID
                                               );
  IF (IC$API_ALLOW_INACTIVE IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$API_ALLOW_INACTIVE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IC$ALLOWNEGINV  := FND_PROFILE.Value_Specific( name    => 'IC$ALLOWNEGINV'
                                               , user_id => DEFAULT_USER_ID
                                               );
  IF (IC$ALLOWNEGINV IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$ALLOWNEGINV');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IC$MOVEDIFFSTAT  := FND_PROFILE.Value_Specific( name    => 'IC$MOVEDIFFSTAT'
                                               , user_id => DEFAULT_USER_ID
                                               );
  IF (IC$MOVEDIFFSTAT IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$MOVEDIFFSTAT');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*====================================================================
    Joe DiIorio 10/23/2001 11.5.1H BUG#1989860 - Removed Intrastat.

  SY$INTRASTAT    := FND_PROFILE.Value_Specific( name    => 'SY$INTRASTAT'
                                               , user_id => DEFAULT_USER_ID
                                               );
  IF (SY$INTRASTAT IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','SY$INTRASTAT');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
    ==================================================================*/

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END Setup;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Get_Item                                                             |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to retrieve item master details                                 |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to retrieve all details from ic_item_mst      |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_item_no      IN ic_item_mst.item_no%TYPE - the key to select upon  |
 |    x_ic_item_mst OUT RECORD      - Record containing ic_item_mst        |
 |    x_ic_item_cpg OUT RECORD      - Record containing ic_item_cpg        |
 |                                                                         |
 | HISTORY                                                                 |
 +=========================================================================+
*/
PROCEDURE Get_Item
( p_item_no      IN ic_item_mst.item_no%TYPE
, x_ic_item_mst_row OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg_row OUT NOCOPY ic_item_cpg%ROWTYPE
)
IS
BEGIN

  x_ic_item_mst_row.item_no := p_item_no;

  IF GMIVDBL.ic_item_mst_select(x_ic_item_mst_row, x_ic_item_mst_row)
  THEN
    -- Jatinder - B3158806 Removed the CPG install check.
      x_ic_item_cpg_row.item_id := x_ic_item_mst_row.item_id;
      IF GMIVDBL.ic_item_cpg_select(x_ic_item_cpg_row, x_ic_item_cpg_row) THEN
          RETURN;
      END IF;
      RETURN;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

EXCEPTION
  WHEN OTHERS THEN
    x_ic_item_mst_row.item_no := NULL;

END Get_Item;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Get_Lot                                                              |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to retrieve lot master details                                  |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to retrieve all details from ic_lots_mst      |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_item_id      IN  NUMBER       - Item ID of lot to be retrieved     |
 |    p_lot_no       IN  VARCHAR2(32) - Lot number of lot to be retrieved  |
 |    p_sublot_no    IN  VARCHAR2(32) - Sublot number to be retrieved      |
 |    x_ic_lots_mst  OUT RECORD       - Record containing ic_lots_mst      |
 |    x_ic_lots_cpg  OUT RECORD       - Record containing ic_lots_cpg      |
 |                                                                         |
 | HISTORY                                                                 |
 +=========================================================================+
*/
PROCEDURE Get_Lot
( p_item_id      IN ic_lots_mst.item_id%TYPE
, p_lot_no       IN ic_lots_mst.lot_no%TYPE
, p_sublot_no    IN ic_lots_mst.sublot_no%TYPE
, x_ic_lots_mst_row  OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg_row  OUT NOCOPY ic_lots_cpg%ROWTYPE
)
IS
BEGIN
  x_ic_lots_mst_row.item_id := p_item_id;
  x_ic_lots_mst_row.lot_no := p_lot_no;
  x_ic_lots_mst_row.sublot_no := p_sublot_no;

  IF GMIVDBL.ic_lots_mst_select(x_ic_lots_mst_row, x_ic_lots_mst_row)
  THEN
    /* Jalaj Srivastava - Bug 3158806. Remove CPG_INSTALL check. */
      x_ic_lots_cpg_row.item_id := x_ic_lots_mst_row.item_id;
      x_ic_lots_cpg_row.lot_id  := x_ic_lots_mst_row.lot_id;
      IF GMIVDBL.ic_lots_cpg_select(x_ic_lots_cpg_row, x_ic_lots_cpg_row)
      THEN
        RETURN;
      END IF;
      RETURN;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

EXCEPTION
  WHEN OTHERS THEN
    x_ic_lots_mst_row.lot_id := NULL;
END Get_Lot;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Get_warehouse                                                        |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to retrieve warehouse details                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to retrieve all details from ic_whse_mst      |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_item_no     IN  VARCHAR2(4)  - Warehouse code to be retrieved      |
 |    x_ic_whse_mst OUT RECORD       - Record containing ic_whse_mst       |
 |                                                                         |
 | HISTORY                                                                 |
 +=========================================================================+
*/
PROCEDURE Get_Warehouse
( p_whse_code   IN  ic_whse_mst.whse_code%TYPE
, x_ic_whse_mst_row OUT NOCOPY ic_whse_mst%ROWTYPE
)
IS
BEGIN
  x_ic_whse_mst_row.whse_code := p_whse_code;
  IF GMIVDBL.ic_whse_mst_select(x_ic_whse_mst_row, x_ic_whse_mst_row)
  THEN
    RETURN;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

EXCEPTION
  WHEN OTHERS THEN
    x_ic_whse_mst_row.whse_code := NULL;
END Get_Warehouse;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Get_loct_inv                                                         |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to retrieve location inventory details                          |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to retrieve all details from ic_loct_inv      |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_item_id     IN NUMBER      - Item ID                               |
 |    p_whse_code   IN VARCHAR2(4) - Warehouse code                        |
 |    p_lot_id      IN NUMBER      - Lot ID                                |
 |    p_location    IN VARCHAR2(4) - Location code                         |
 |    x_ic_loct_inv IN RECORD      - Record containing ic_loct_inv details |
 |                                                                         |
 | HISTORY                                                                 |
 +=========================================================================+
*/
PROCEDURE Get_Loct_inv
( p_item_id     IN  ic_loct_inv.item_id%TYPE
, p_whse_code   IN  ic_loct_inv.whse_code%TYPE
, p_lot_id      IN  ic_loct_inv.lot_id%TYPE
, p_location    IN  ic_loct_inv.location%TYPE
, x_ic_loct_inv_row OUT NOCOPY ic_loct_inv%ROWTYPE
)
IS
BEGIN
  x_ic_loct_inv_row.item_id := p_item_id;
  x_ic_loct_inv_row.whse_code := p_whse_code;
  x_ic_loct_inv_row.lot_id := p_lot_id;
  x_ic_loct_inv_row.location := p_location;

  IF GMIVDBL.ic_loct_inv_select(x_ic_loct_inv_row, x_ic_loct_inv_row)
  THEN
    RETURN;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

EXCEPTION
  WHEN OTHERS THEN
    x_ic_loct_inv_row.loct_onhand := NULL;

END Get_Loct_inv;

/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Get_Um                                                               |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to retrieve unit of measure details                             |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to retrieve all details from sy_uoms_mst      |
 |    and sy_uoms_typ                                                      |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_um_code     IN VARCHAR2(4) - Unit of measure code to be retrieved  |
 |    x_sy_uoms_mst OUT RECORD     - Record containing sy_uoms_mst details |
 |    x_sy_uoms_typ OUT RECORD     - Record containing sy_uoms_typ details |
 |    x_error_code  OUT NUMBER     - Error code returned                   |
 |                                                                         |
 | HISTORY                                                                 |
 +=========================================================================+
*/
PROCEDURE Get_Um
( p_um_code     IN  sy_uoms_mst.um_code%TYPE
, x_sy_uoms_mst_row OUT NOCOPY sy_uoms_mst%ROWTYPE
, x_sy_uoms_typ_row OUT NOCOPY sy_uoms_typ%ROWTYPE
)
IS
BEGIN
  x_sy_uoms_mst_row.um_code := p_um_code;
  IF GMIVDBL.sy_uoms_mst_select(x_sy_uoms_mst_row, x_sy_uoms_mst_row)
  THEN
    x_sy_uoms_typ_row.um_type := x_sy_uoms_mst_row.um_type;
    IF GMIVDBL.sy_uoms_typ_select (x_sy_uoms_typ_row, x_sy_uoms_typ_row)
    THEN
      RETURN;
    END IF;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

EXCEPTION
  WHEN OTHERS THEN
    x_sy_uoms_mst_row.um_code := NULL;
END Get_Um;

FUNCTION v_expaction_code
  (  p_action_code  IN qc_actn_mst.action_code%TYPE
   , x_qc_actn_mst_row OUT NOCOPY qc_actn_mst%ROWTYPE
  )
RETURN BOOLEAN
IS
BEGIN
  x_qc_actn_mst_row.action_code := p_action_code;
  IF GMIVDBL.qc_actn_mst_select(x_qc_actn_mst_row, x_qc_actn_mst_row)
  THEN
    IF x_qc_actn_mst_row.delete_mark = 0
    THEN
      RETURN TRUE;
    END IF;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN FALSE;
END v_expaction_code;



FUNCTION v_qc_grade
  (  p_qc_grade         IN qc_grad_mst.qc_grade%TYPE
   , x_qc_grad_mst_row OUT NOCOPY qc_grad_mst%ROWTYPE
  )
RETURN BOOLEAN
IS
BEGIN
  x_qc_grad_mst_row.qc_grade := p_qc_grade;
  IF GMIVDBL.qc_grad_mst_select(x_qc_grad_mst_row, x_qc_grad_mst_row)
  THEN
    IF x_qc_grad_mst_row.delete_mark = 0
    THEN
      RETURN TRUE;
    END IF;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN FALSE;
END v_qc_grade;

FUNCTION v_reason_code
  (  p_reason_code      IN  sy_reas_cds.reason_code%TYPE
   , x_sy_reas_cds_row OUT NOCOPY sy_reas_cds%ROWTYPE
  )
RETURN BOOLEAN
IS
BEGIN
  x_sy_reas_cds_row.reason_code := p_reason_code;
  IF GMIVDBL.sy_reas_cds_select(x_sy_reas_cds_row, x_sy_reas_cds_row)
  THEN
    IF x_sy_reas_cds_row.delete_mark = 0
    THEN
      RETURN TRUE;
    END IF;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN FALSE;
END v_reason_code;

FUNCTION v_ship_vendor
  (  p_vendor_no       IN  po_vend_mst.vendor_no%TYPE
   , x_po_vend_mst_row OUT NOCOPY po_vend_mst%ROWTYPE
  )
RETURN BOOLEAN
IS
BEGIN
  x_po_vend_mst_row.vendor_no := p_vendor_no;
  IF GMIVDBL.po_vend_mst_select(x_po_vend_mst_row, x_po_vend_mst_row)
  THEN
    IF x_po_vend_mst_row.delete_mark = 0
    THEN
      RETURN TRUE;
    END IF;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN FALSE;
END v_ship_vendor;


FUNCTION v_lot_status
  (p_lot_status IN ic_lots_sts.lot_status%TYPE
  ,x_ic_lots_sts_row OUT NOCOPY ic_lots_sts%ROWTYPE
  )
RETURN BOOLEAN
IS
BEGIN
  x_ic_lots_sts_row.lot_status := p_lot_status;
  IF GMIVDBL.ic_lots_sts_select(x_ic_lots_sts_row, x_ic_lots_sts_row)
  THEN
    IF x_ic_lots_sts_row.delete_mark = 0
    THEN
      RETURN TRUE;
    END IF;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN FALSE;
END v_lot_status;

/*
PROCEDURE Get_Transfer
  (  p_orgn_code    IN ic_xfer_mst.orgn_code%TYPE
  ,  p_transfer_no  IN ic_xfer_mst.transfer_no%TYPE
  ,  x_ic_xfer_mst_row  OUT NOCOPY ic_xfer_mst%ROWTYPE
  )
IS
BEGIN
  x_ic_xfer_mst_row.orgn_code := p_orgn_code;
  x_ic_xfer_mst_row.transfer_no := p_transfer_no;

  IF GMIVDBL.ic_xfer_mst_select(x_ic_xfer_mst_row, x_ic_xfer_mst_row)
  THEN
    RETURN;
  END IF;

  RAISE FND_API.G_EXC_ERROR;

EXCEPTION
  WHEN OTHERS THEN
    x_ic_xfer_mst_row.transfer_no := NULL;
END Get_Transfer;

*/

END GMIGUTL;

/
