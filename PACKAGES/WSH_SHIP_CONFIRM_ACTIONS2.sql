--------------------------------------------------------
--  DDL for Package WSH_SHIP_CONFIRM_ACTIONS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIP_CONFIRM_ACTIONS2" AUTHID CURRENT_USER as
/* $Header: WSHDDSPS.pls 120.1.12010000.1 2008/07/29 05:59:43 appldev ship $ */
--
--Function:         part_of_ship_set
--Parameters:       p_source_line_id
--Description:      This function returns a boolean number that indicates
--                  if the order line is part of a ship set

FUNCTION Part_Of_Ship_Set(p_source_line_id number) RETURN BOOLEAN;

--
--Procedure:        Get_Line_Total_Shp_Qty
--Parameters:       p_stop_id
--                  p_source_line_id
--                  x_line_shp_qty
--                  x_return_status
--Description:      This procedure calculates the total shippped quantity
--                  for a order line/source line in a specified delivery

-- OPM KYH 12/SEP/00 - add x_line_shp_qty2 to out params
-- =====================================================
PROCEDURE Get_Line_Total_Shp_Qty(
  p_stop_id in number
, p_source_line_id in number
, x_line_shp_qty out NOCOPY  number
, x_line_shp_qty2 out NOCOPY  number
, x_return_status out NOCOPY  varchar2) ;

--
--Procedure:        Ship_Zero_Quantity
--Parameters:       p_source_line_id
--                  x_return_status
--Description:      This procedure especailly handle the case when we try
--						  to ship zero quantity for a line
--
PROCEDURE Ship_Zero_Quantity(
  p_source_line_id		IN     NUMBER
, x_return_status          OUT NOCOPY  VARCHAR2
);

--
--Procedure:        Backorder
--Parameters:       p_details_id : Table of delivery detail id with zero
--						  shipped quantity and cycle_count_quantity = requested_quantity
--                                   p_bo_qtys = normal quantity to backorder/cycle-count
--                                   p_overpick_qtys = excess overpicked quantity to cancel
--                  for backorder purpose
--                  x_return_status
--Description:      This procedure especailly handle the case when we try
--						  to ship zero quantity for a line
--
-- bug# 6908504 (replenishment project): Added a new parameter p_bo_source .
PROCEDURE Backorder(
  p_detail_ids           IN     WSH_UTIL_CORE.Id_Tab_Type ,
  p_line_ids		 IN	WSH_UTIL_CORE.Id_Tab_Type ,  -- Consolidation of BO Delivery Details project
  p_bo_qtys              IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_req_qtys             IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_qtys2             IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_overpick_qtys        IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_overpick_qtys2       IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_mode              IN     VARCHAR2,
  p_bo_source            IN     VARCHAR2 DEFAULT 'SHIP',
  x_out_rows             OUT NOCOPY     WSH_UTIL_CORE.Id_Tab_Type,
  x_cons_flags           OUT NOCOPY     WSH_UTIL_CORE.Column_Tab_Type,  -- Consolidation of BO Delivery Details project
  x_return_status        OUT NOCOPY     VARCHAR2
);

--
--Procedure:        Check_Exception
--Parameters:       p_detail_id : delivery detail id which is checked
--                  x_exception_exist : out parameter which indicates if
--                  exception exists for the delivery detail
--                  x_severity_present : out parameter which indicates if
--                  maximum severity of exception is either 'H' - High,
--                  'M' - Medium or 'L' - Low
--                  x_return_status
--Description:      This procedure check if exception exists for a detail
--
PROCEDURE check_exception(
  p_delivery_detail_id      IN  NUMBER
, x_exception_exist         OUT NOCOPY  VARCHAR2
, x_severity_present        OUT NOCOPY  VARCHAR2
, x_return_status           OUT NOCOPY  VARCHAR2
);

--
-- Procedure:       Backorder
-- Description:     This is a wrapper of the BackOrder procedure already present in the package.
--		    This is introduced for Consolidation of BO Delivery Details project.
--		    This wrapper avoids the change of the calls made to Backorder api from different apis
--		    (as additional parameter is added to the original backorder api).
--
-- bug# 6908504 (replenishment project): Added a new parameter p_bo_source .
PROCEDURE Backorder(
  p_detail_ids           IN     WSH_UTIL_CORE.Id_Tab_Type ,
  p_bo_qtys              IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_req_qtys             IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_qtys2             IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_overpick_qtys        IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_overpick_qtys2       IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_mode              IN     VARCHAR2,
  p_bo_source            IN     VARCHAR2 DEFAULT 'SHIP',
  x_out_rows             OUT NOCOPY     WSH_UTIL_CORE.Id_Tab_Type,
  x_return_status        OUT NOCOPY     VARCHAR2
);

END WSH_SHIP_CONFIRM_ACTIONS2;

/
