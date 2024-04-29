--------------------------------------------------------
--  DDL for Package GMI_ALLOCATE_INVENTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ALLOCATE_INVENTORY_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVALIS.pls 115.6 2003/04/06 23:28:47 nchekuri ship $
 +=========================================================================+
 |                Copyright (c) 1998 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVALIS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private procedures controling auto-allocation |
 |     of OPM inventory against a particular oreder/shipment line.         |
 |                                                                         |
 | HISTORY                                                                 |
 |     15-DEC-1999  K.Y.Hunt                                               |
 +=========================================================================+
  API Name  : GMI_ALLOCATE_INVENTORY_PVT
  Type      : Private
  Function  : This package contains private procedures controling auto-
              allocation of OPM inventory against order/shipment lines.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/

PROCEDURE ALLOCATE_LINE
( p_allocation_rec     IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
, p_ic_item_mst        IN  ic_item_mst%ROWTYPE
, p_ic_whse_mst        IN  ic_whse_mst%ROWTYPE
, p_op_alot_prm        IN  op_alot_prm%ROWTYPE
, p_batch_id	       IN  NUMBER DEFAULT NULL
, x_allocated_qty1     OUT NOCOPY NUMBER
, x_allocated_qty2     OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE BALANCE_DEFAULT_LOT
( p_default_qty1       IN  NUMBER
, p_default_qty2       IN  NUMBER
, p_allocation_rec     IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
, p_ic_item_mst        IN  ic_item_mst%ROWTYPE
, p_ic_whse_mst        IN  ic_whse_mst%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

FUNCTION CHECK_EXISTING_ALLOCATIONS
( p_doc_id        IN ic_tran_pnd.doc_id%TYPE
, p_line_id       IN ic_tran_pnd.line_id%TYPE
, p_lot_ctl       IN ic_item_mst.lot_ctl%TYPE
, p_item_loct_ctl IN ic_item_mst.loct_ctl%TYPE
, p_whse_loct_ctl IN ic_whse_mst.loct_ctl%TYPE
)
RETURN BOOLEAN;

FUNCTION UNSTAGED_ALLOCATIONS_EXIST
( p_doc_id        IN ic_tran_pnd.doc_id%TYPE
, p_line_id       IN ic_tran_pnd.line_id%TYPE
)
RETURN BOOLEAN;

END GMI_ALLOCATE_INVENTORY_PVT;

 

/
