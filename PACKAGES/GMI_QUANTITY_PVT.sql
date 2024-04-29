--------------------------------------------------------
--  DDL for Package GMI_QUANTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_QUANTITY_PVT" AUTHID CURRENT_USER AS
-- $Header: GMIVQTYS.pls 115.2 99/07/16 04:50:14 porting ship  $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIVQTYS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains private procedures relating to inventory      |
--|     quantity API transactions                                           |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     25-FEB-1999  M.Godfrey       Upgrade to R11                         |
--+=========================================================================+
-- API Name  : GMI_QUANTITY_PVT
-- Type      : Private
-- Function  : This package contains private procedures used to create
--             inventory quantity transactions.
-- Pre-reqs  : N/A
-- Parameters: Per function
--
-- Current Vers  : 2.0
--
-- Previous Vers : 1.0
--
-- Initial Vers  : 1.0
-- Notes
--

PROCEDURE Validate_Inventory_Posting
( p_trans_rec          IN GMI_QUANTITY_PUB.trans_rec_typ
, x_item_id            OUT ic_item_mst.item_id%TYPE
, x_lot_id             OUT ic_lots_mst.lot_id%TYPE
, x_old_lot_status     OUT ic_lots_sts.lot_status%TYPE
, x_old_qc_grade       OUT qc_grad_mst.qc_grade%TYPE
, x_return_status      OUT VARCHAR2
, x_msg_count          OUT NUMBER
, x_msg_data           OUT VARCHAR2
, x_trans_rec          OUT GMI_QUANTITY_PUB.trans_rec_typ
);
--

FUNCTION Insert_ic_jrnl_mst
( p_ic_jrnl_mst_rec  IN ic_jrnl_mst%ROWTYPE
)
RETURN BOOLEAN;

--
FUNCTION Insert_ic_adjs_jnl
( p_ic_adjs_jnl_rec  IN ic_adjs_jnl%ROWTYPE
)
RETURN BOOLEAN;

--
FUNCTION Check_unposted_jnl_lot_status
( p_item_id      IN ic_item_mst.item_id%TYPE
, p_lot_id       IN ic_lots_mst.lot_id%TYPE
, p_whse_code    IN ic_whse_mst.whse_code%TYPE
, p_location     IN ic_loct_mst.location%TYPE
, p_lot_status   IN ic_lots_sts.lot_status%TYPE
)
RETURN BOOLEAN;

--
FUNCTION Check_unposted_jnl_qc_grade
( p_item_id      IN ic_item_mst.item_id%TYPE
, p_lot_id       IN ic_lots_mst.lot_id%TYPE
, p_qc_grade     IN qc_grad_mst.qc_grade%TYPE
)
RETURN BOOLEAN;

END GMI_QUANTITY_PVT;

 

/
