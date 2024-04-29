--------------------------------------------------------
--  DDL for Package GMIGUTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIGUTL" AUTHID CURRENT_USER AS
/* $Header: GMIGUTLS.pls 115.8 2002/11/11 21:07:25 jdiiorio ship $
 +==========================================================================+
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
 | HISTORY                                                                  |
 |    Joe DiIorio 10/23/2001 11.5.1H BUG#1989860                            |
 | Removed SY$INTRASTAT.                                                    |
 |    Tony Cataldo 11/07/2002/2002 11.5.1J Bug #2343411                     |
 | Added IC$DEFAULT_LOT_DESC                                                |
 |    Joe DiIorio 11/11/2002 11.5.1J BUG#2643440 - added nocopy.            |
 +==========================================================================+
*/
DEFAULT_USER      fnd_user.user_name%TYPE;
API_VERSION       NUMBER;
DEFAULT_USER_ID   fnd_user.user_id%TYPE;
DEFAULT_LOGIN     NUMBER;
IC$DEFAULT_LOT    VARCHAR2(32);
IC$DEFAULT_LOT_DESC  NUMBER;  -- Bug 2343411
IC$DEFAULT_LOCT   VARCHAR2(32);
IC$ALLOWNEGINV    VARCHAR2(32);
IC$API_ALLOW_INACTIVE VARCHAR2(32);
IC$MOVEDIFFSTAT   VARCHAR2(32);
SY$CPG_INSTALL    VARCHAR2(32);
DB_ERRNUM         NUMBER;
DB_ERRMSG         VARCHAR2(2000);

FUNCTION Setup (p_user_name VARCHAR2) RETURN BOOLEAN;

FUNCTION v_expaction_code
  (  p_action_code      IN qc_actn_mst.action_code%TYPE
   , x_qc_actn_mst_row OUT NOCOPY qc_actn_mst%ROWTYPE
  )
RETURN BOOLEAN;

FUNCTION v_qc_grade
  (  p_qc_grade         IN qc_grad_mst.qc_grade%TYPE
   , x_qc_grad_mst_row OUT NOCOPY qc_grad_mst%ROWTYPE
  )
RETURN BOOLEAN;

FUNCTION v_reason_code
  (  p_reason_code      IN sy_reas_cds.reason_code%TYPE
   , x_sy_reas_cds_row OUT NOCOPY sy_reas_cds%ROWTYPE
  )
RETURN BOOLEAN;

FUNCTION v_ship_vendor
  (  p_vendor_no       IN po_vend_mst.vendor_no%TYPE
   , x_po_vend_mst_row OUT NOCOPY po_vend_mst%ROWTYPE
  )
RETURN BOOLEAN;

PROCEDURE Get_Item
( p_item_no      IN ic_item_mst.item_no%TYPE
, x_ic_item_mst_row OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg_row OUT NOCOPY ic_item_cpg%ROWTYPE
);

PROCEDURE Get_Lot
( p_item_id      IN ic_lots_mst.item_id%TYPE
, p_lot_no       IN ic_lots_mst.lot_no%TYPE
, p_sublot_no    IN ic_lots_mst.sublot_no%TYPE
, x_ic_lots_mst_row  OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg_row  OUT NOCOPY ic_lots_cpg%ROWTYPE
);

PROCEDURE Get_Warehouse
( p_whse_code   IN  ic_whse_mst.whse_code%TYPE
, x_ic_whse_mst_row OUT NOCOPY ic_whse_mst%ROWTYPE
);

PROCEDURE Get_Loct_inv
( p_item_id     IN  ic_loct_inv.item_id%TYPE
, p_whse_code   IN  ic_loct_inv.whse_code%TYPE
, p_lot_id      IN  ic_loct_inv.lot_id%TYPE
, p_location    IN  ic_loct_inv.location%TYPE
, x_ic_loct_inv_row OUT NOCOPY ic_loct_inv%ROWTYPE
);

PROCEDURE Get_Um
( p_um_code     IN  sy_uoms_mst.um_code%TYPE
, x_sy_uoms_mst_row OUT NOCOPY sy_uoms_mst%ROWTYPE
, x_sy_uoms_typ_row OUT NOCOPY sy_uoms_typ%ROWTYPE
);

/*
PROCEDURE Get_Transfer
( p_orgn_code   IN  ic_xfer_mst.orgn_code%TYPE
, p_transfer_no IN  ic_xfer_mst.transfer_no%TYPE
, x_ic_xfer_mst_row OUT NOCOPY ic_xfer_mst%ROWTYPE
);

*/

FUNCTION v_Lot_status
( p_lot_status  IN ic_lots_sts.lot_status%TYPE
, x_ic_lots_sts_row OUT NOCOPY ic_lots_sts%ROWTYPE
)
RETURN BOOLEAN;

END GMIGUTL;

 

/
