--------------------------------------------------------
--  DDL for Package GMF_LOT_COSTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_LOT_COSTING_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMFPLCRS.pls 120.3.12010000.2 2009/12/24 16:40:29 rpatangy ship $ */
--****************************************************************************************************
--*                                                                                                  *
--* Oracle Process Manufacturing                                                                     *
--* ============================                                                                     *
--*                                                                                                  *
--* Package GMF_LOT_COSTING_PUB                                                                      *
--* ---------------------------                                                                      *
--* This package contains a publically callable procedure ROLLUP_LOT_COSTS together with several     *
--* utility procedures that are called by it. For individual procedures' descriptions, see the       *
--* description in front of each one.                                                                *
--*                                                                                                  *
--* Author: Paul J Schofield, OPM Development EMEA                                                   *
--* Date:   September 2003                                                                           *
--*                                                                                                  *
--* HISTORY                                                                                          *
--* =======                                                                                          *
--* 12-Sep-2003     PJS     Removed p_debug_level parameter in favour of the GMF_CONC_DEBUG profile  *
--*                         option. Also created the audit trail in table GMF_LOT_COST_AUDIT and     *
--*                         removed all code that supported the GMF_RESOURCE_LOT_COST_TXNS table.    *
--*                                                                                                  *
--* 30-Nov-2003    umoogala Now passing co_code to main routines ROLLUP_LOT_COSTS and removed        *
--*		 	    calendar_code and user params. Using co_code where ever cldr was used.   *
--*		 	    Also, using cm_mthd_mst.default_lot_cost_mthd for non-lot controlled items*
--*                                                                                                  *
--* 05-Dec-2003    umoogala Enabling process for trail runs. Added flag p_final_run_flag to args list*
--*                                                                                                  *
--* 08-Mar-2004    PJS      Resequenced parameters for bug 3476427                                   *
--*                                                                                                  *
--* 24-Feb-2005 - Dinesh Vadivel - Bug 4176690 - Added p_final_run_date parameter
--****************************************************************************************************

  /*PROCEDURE rollup_lot_costs
  ( errbuf            OUT NOCOPY VARCHAR2
  , retcode           OUT NOCOPY VARCHAR2
  , p_co_code	       IN VARCHAR2
  , p_cost_method_code IN VARCHAR2
  , p_final_run_flag   IN VARCHAR2	-- umoogala 03-Dec-2003
  , p_cost_class       IN VARCHAR2
  , p_item_no          IN VARCHAR2
  , p_lot_no           IN VARCHAR2
  , p_sublot_no        IN VARCHAR2
  , p_final_run_date IN VARCHAR2
  );

  /*
 /* INVCONV sukarna Reddy June 2005 */


 PROCEDURE rollup_lot_costs
( errbuf            OUT NOCOPY VARCHAR2
, retcode           OUT NOCOPY VARCHAR2
, p_le_id   	       IN NUMBER
, p_cost_type_id     IN NUMBER
, p_final_run_flag   IN VARCHAR2
, p_structure_id     IN NUMBER /* dummy field value is passed from SRS but not used in the program*/
, p_category_id     IN NUMBER
, p_orgn_id          IN NUMBER
, p_item_id        IN NUMBER
, p_lot_no           IN VARCHAR2
, p_final_run_date IN VARCHAR2
);

  -- umoogala
  FUNCTION is_item_lot_costed
  ( p_orgn_id IN NUMBER,
    p_item_id  IN NUMBER
  )
  RETURN NUMBER;

  FUNCTION is_item_lot_costed1
  ( p_orgn_id IN NUMBER,
    p_item_id  IN NUMBER
  )
  RETURN NUMBER;

END GMF_LOT_COSTING_PUB;

/
