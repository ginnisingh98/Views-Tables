--------------------------------------------------------
--  DDL for Package GMI_VALID_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_VALID_GRP" AUTHID CURRENT_USER AS
-- $Header: GMIGVALS.pls 115.2 99/07/16 04:47:39 porting ship  $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIGVALS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains inventory validation functions and            |
--|     procedures.                                                         |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     17-FEB-1999  M.Godfrey       Upgrade to R11                         |
--+=========================================================================+
-- API Name  : GMI_VALID_GRP
-- Type      : Group
-- Function  : This package contains inventory validation functions and
--             procedures
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
FUNCTION Validate_Item_Existance
( p_item_no      IN ic_item_mst.item_no%TYPE
)
RETURN NUMBER;
--
FUNCTION Validate_Dualum_Ind
( p_dualum_ind   IN ic_item_mst.dualum_ind%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Item_Um2
( p_dualum_ind   IN ic_item_mst.dualum_ind%TYPE
, p_item_um2     IN ic_item_mst.item_um2%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Deviation
( p_dualum_ind   IN ic_item_mst.dualum_ind%TYPE
, p_deviation    IN ic_item_mst.deviation_hi%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Lot_Ctl
( p_lot_ctl      IN ic_item_mst.lot_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Lot_Indivisible
( p_lot_ctl         IN ic_item_mst.lot_ctl%TYPE
, p_lot_indivisible IN ic_item_mst.lot_indivisible%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Sublot_Ctl
( p_lot_ctl     IN ic_item_mst.lot_ctl%TYPE
, p_sublot_ctl  IN ic_item_mst.sublot_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Loct_Ctl
( p_loct_ctl    IN ic_item_mst.loct_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Noninv_Ind
( p_noninv_ind  IN ic_item_mst.noninv_ind%TYPE
, p_lot_ctl     IN ic_item_mst.lot_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Match_Type
( p_match_type  IN ic_item_mst.match_type%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Inactive_Ind
( p_inactive_ind IN ic_item_mst.inactive_ind%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Inv_Type
( p_inv_type     IN ic_item_mst.inv_type%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Shelf_Life
( p_shelf_life   IN ic_item_mst.shelf_life%TYPE
, p_grade_ctl    IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Retest_Interval
( p_retest_interval IN ic_item_mst.retest_interval%TYPE
, p_grade_ctl       IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Item_Abccode
( p_item_abccode    IN ic_item_mst.item_abccode%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Gl_Class
( p_gl_class        IN ic_item_mst.gl_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Inv_Class
( p_inv_class       IN ic_item_mst.inv_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Sales_Class
( p_sales_class     IN ic_item_mst.sales_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Ship_Class
( p_ship_class      IN ic_item_mst.ship_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Frt_Class
( p_frt_class       IN ic_item_mst.frt_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Price_Class
( p_price_class     IN ic_item_mst.price_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Storage_Class
( p_storage_class   IN ic_item_mst.storage_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Purch_Class
( p_purch_class     IN ic_item_mst.purch_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Tax_Class
( p_tax_class       IN ic_item_mst.tax_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Customs_Class
( p_customs_class   IN ic_item_mst.customs_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Alloc_Class
( p_alloc_class     IN ic_item_mst.alloc_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Planning_Class
( p_planning_class  IN ic_item_mst.planning_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Itemcost_Class
( p_itemcost_class  IN ic_item_mst.itemcost_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Cost_Mthd_Code
( p_cost_mthd_code  IN ic_item_mst.cost_mthd_code%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Grade_Ctl
( p_grade_ctl       IN ic_item_mst.grade_ctl%TYPE
, p_lot_ctl         IN ic_item_mst.lot_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Status_Ctl
( p_status_ctl      IN ic_item_mst.status_ctl%TYPE
, p_lot_ctl         IN ic_item_mst.lot_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Qc_Grade
( p_qc_grade        IN ic_item_mst.qc_grade%TYPE
, p_grade_ctl       IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Lot_Status
( p_lot_status      IN ic_item_mst.lot_status%TYPE
, p_status_ctl      IN ic_item_mst.status_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Qchold_Res_Code
( p_qchold_res_code IN ic_item_mst.qchold_res_code%TYPE
, p_grade_ctl       IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Expaction_Code
( p_expaction_code  IN ic_item_mst.expaction_code%TYPE
, p_grade_ctl       IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Expaction_Interval
( p_expaction_interval   IN ic_item_mst.expaction_interval%TYPE
, p_grade_ctl            IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Experimental_Ind
( p_experimental_ind     IN ic_item_mst.experimental_ind%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Seq_Dpnd_Class
( p_seq_dpnd_class       IN ic_item_mst.seq_dpnd_class%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Commodity_Code
( p_commodity_code       IN ic_item_mst.commodity_code%TYPE
, p_sy$intrastat         IN VARCHAR2
)
RETURN BOOLEAN;
--
FUNCTION Validate_Ic_Matr_Days
( p_ic_matr_days         IN ic_item_cpg.ic_matr_days%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Ic_Hold_Days
( p_ic_hold_days         IN ic_item_cpg.ic_hold_days%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Strength
( p_strength             IN ic_lots_mst.strength%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Origination_Type
( p_origination_type     IN ic_lots_mst.origination_type%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Shipvendor_No
( p_shipvendor_no        IN po_vend_mst.vendor_no%TYPE
)
RETURN NUMBER;
--
FUNCTION Validate_Lot_No
( p_item_no              IN ic_item_mst.item_no%TYPE
, p_lot_no               IN ic_lots_mst.lot_no%TYPE
, p_sublot_no            IN ic_lots_mst.sublot_no%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Location
( p_item_loct_ctl        IN ic_item_mst.loct_ctl%TYPE
, p_whse_loct_ctl        IN ic_whse_mst.loct_ctl%TYPE
, p_whse_code            IN ic_whse_mst.whse_code%TYPE
, p_location             IN ic_loct_mst.location%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Item_Cnv
( p_item_no              IN ic_item_mst.item_no%TYPE
, p_lot_no               IN ic_lots_mst.lot_no%TYPE
, p_sublot_no            IN ic_lots_mst.sublot_no%TYPE
, p_um_type              IN ic_item_cnv.um_type%TYPE
)
RETURN BOOLEAN;
--
END GMI_VALID_GRP;

 

/
