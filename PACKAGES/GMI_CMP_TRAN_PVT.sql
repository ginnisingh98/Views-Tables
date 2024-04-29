--------------------------------------------------------
--  DDL for Package GMI_CMP_TRAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_CMP_TRAN_PVT" AUTHID CURRENT_USER AS
-- $Header: GMIVCMPS.pls 115.2 99/07/16 04:49:38 porting ship  $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIVCMPS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains private procedures to post completed          |
--|     inventory transactions.                                             |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--+=========================================================================+
-- API Name  : GMI_CMP_TRAN_PVT
-- Type      : Private
-- Function  : This package contains private procedures used to post
--             completed inventory transactions.
-- Pre-reqs  : N/A
-- Parameters: Per function
--
-- Current Vers  : 1.0
--
-- Previous Vers : N/A
--
-- Initial Vers  : 1.0
-- Notes
--
-- API specific parameters to be presented in SQL RECORD format
TYPE cmp_tran_typ IS RECORD
( item_id        IC_TRAN_CMP.item_id%TYPE
, line_id        IC_TRAN_CMP.line_id%TYPE
, trans_id       IC_TRAN_CMP.trans_id%TYPE
, co_code        IC_TRAN_CMP.co_code%TYPE
, orgn_code      IC_TRAN_CMP.orgn_code%TYPE
, whse_code      IC_TRAN_CMP.whse_code%TYPE
, lot_id         IC_TRAN_CMP.lot_id%TYPE
, location       IC_TRAN_CMP.location%TYPE
, doc_id         IC_TRAN_CMP.doc_id%TYPE
, doc_type       IC_TRAN_CMP.doc_type%TYPE
, doc_line       IC_TRAN_CMP.doc_line%TYPE
, line_type      IC_TRAN_CMP.line_type%TYPE
, reason_code    IC_TRAN_CMP.reason_code%TYPE
, creation_date  IC_TRAN_CMP.creation_date%TYPE
, trans_date     IC_TRAN_CMP.trans_date%TYPE
, trans_qty      IC_TRAN_CMP.trans_qty%TYPE
, trans_qty2     IC_TRAN_CMP.trans_qty2%TYPE
, qc_grade       IC_TRAN_CMP.qc_grade%TYPE
, lot_status     IC_TRAN_CMP.lot_status%TYPE
, trans_stat     IC_TRAN_CMP.trans_stat%TYPE
, trans_um       IC_TRAN_CMP.trans_um%TYPE
, trans_um2      IC_TRAN_CMP.trans_um2%TYPE
, user_id        FND_USER.user_id%TYPE
, gl_posted_ind  IC_TRAN_CMP.gl_posted_ind%TYPE
, event_id       IC_TRAN_CMP.event_id%TYPE
, text_code      IC_TRAN_CMP.text_code%TYPE
);
--
FUNCTION Update_Quantity_Transaction
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--
FUNCTION Update_Movement
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--
FUNCTION Update_Lot_Status
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--
FUNCTION Update_Qc_Grade
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--
FUNCTION Insert_ic_tran_cmp
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--
FUNCTION Update_ic_loct_inv
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--
FUNCTION Insert_ic_loct_inv
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--
FUNCTION Update_ic_summ_inv
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--
FUNCTION Update_ic_loct_inv_Lot_Status
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
FUNCTION Update_ic_summ_inv_Qc_Grade
( p_cmp_tran_rec       IN cmp_tran_typ
)
RETURN BOOLEAN;
--

END GMI_CMP_TRAN_PVT;

 

/
