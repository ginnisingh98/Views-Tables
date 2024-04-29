--------------------------------------------------------
--  DDL for Package WSH_SC_TRX_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SC_TRX_INTERFACE" AUTHID CURRENT_USER as
/* $Header: WSHSDOIS.pls 115.10 99/07/16 08:21:28 porting ship $ */


--   	WSH_SC_TRX_INTERFACE
-- Purpose
--      Validate and Upload Ship Confirm  Open Interface
-- History
--      20-MAY-96 troveda Created
--

  --
  -- Name
  --   Check_Serial_Number
  -- Purpose
  --   ensure any SN in SN range does not already exist with any one
  --   of the following conditions
  --   1. current status not in (1,3)  (ie  allow 'instore' or
  --      'defined but not used' to permit RMAs that have been returned/reshelved)
  --   2. not yet interfaced to inventory
  --   3. also exists in inventory interface tables: MTL_SN
  --
  -- Arguments
  --   X_Mode : either post-change or commit.
  --    Post-change checking does not include the picking line itself
  --    Commit checking is tighter/more granular by excluding pl_detail_line only
  --
  --   X_Serial_number_control : either N, Y or D
  --    N = No serial checking, procedure returns success
  --    Y = either predefined serial numbers or dynamic at inv receipt.
  --    D = dynamic entry at sales issue
  --
  --
  -- Notes
  --    dynamic sql is built according to x_mode and whether to check for
  --    uniqueness at item level, org level, neither (ie across orgs) or
  --    both (ie for dynamic entry at sales issue).
  PROCEDURE Check_Serial_Number(
                                X_SERIAL_NUMBER_CONTROL_CODE IN VARCHAR2,
                                X_WAREHOUSE_ID		IN NUMBER,
                                X_ITEM_ID		IN NUMBER,
                                X_LINE_ID		IN NUMBER,
                                X_LINE_DETAIL_ID	IN NUMBER,
                                X_SN	 		IN VARCHAR2,
   				X_ERROR_CODE 	 	IN OUT NUMBER);


   function  DUPLICATE_SN_IN_INTERFACE
	     (X_serial_number_control_code in varchar2,
	      X_warehouse_id		   in number,
	      X_item_id                    in number,
	      X_rowid                      in varchar2,
	      X_sn	                   in varchar2) return BOOLEAN;


   procedure UPDATE_SOPLD_ROW
	     (X_picking_line_id            in number,
	      X_picking_line_detail_id     in number,
	      X_requested_quantity         in number,
	      X_shipped_quantity           in number,
	      X_warehouse                  in number,
	      X_sn                         in varchar2,
	      x_lot                        in varchar2,
	      x_revision                   in varchar2,
	      x_subinventory               in varchar2,
	      x_locator_id                 in number,
              x_departure_id               in number,
              x_delivery_id                in number,
              x_container_id               in number,
	      x_context                    in varchar2,
	      x_dpw_assigned_flag	   in varchar2,
	      x_att1  in varchar2, x_att2  in varchar2, x_att3  in varchar2, x_att4  in varchar2,
	      x_att5  in varchar2, x_att6  in varchar2, x_att7  in varchar2, x_att8  in varchar2,
	      x_att9  in varchar2, x_att10 in varchar2, x_att11 in varchar2, x_att12 in varchar2,
	      x_att13 in varchar2, x_att14 in varchar2, x_att15 in varchar2,
	      error_code                   in out varchar2);

-- 905046. Added pick_slip_number as input to INSERT_SOPLD_ROW.

   procedure INSERT_SOPLD_ROW
	     (X_parent_detail_id           in number,
	      new_pld_id	       in out number,
	      X_pick_slip_number           in number,
	      X_requested_quantity         in number,
	      X_shipped_quantity           in number,
	      X_warehouse_id               in number,
	      X_sn                         in varchar2,
	      x_lot                        in varchar2,
	      x_revision                   in varchar2,
	      x_subinventory               in varchar2,
	      x_locator_id                 in number,
              x_departure_id               in number,
              x_delivery_id                in number,
              x_container_id               in number,
	      x_context                    in varchar2,
	      x_att1  in varchar2, x_att2  in varchar2, x_att3  in varchar2, x_att4  in varchar2,
	      x_att5  in varchar2, x_att6  in varchar2, x_att7  in varchar2, x_att8  in varchar2,
	      x_att9  in varchar2, x_att10 in varchar2, x_att11 in varchar2, x_att12 in varchar2,
	      x_att13 in varchar2, x_att14 in varchar2, x_att15 in varchar2);

-- 905046. Added pick_slip_number as input to SPLIT_SOPLD_ROW.

   procedure SPLIT_SOPLD_ROW
	     (X_picking_line_id            in number,
	      X_picking_line_detail_id     in number,
	      X_pick_slip_number           in number,
	      new_pld_id	       in out number,
	      X_shipped_quantity           in number,
	      X_warehouse_id               in number,
	      X_sn                         in varchar2,
	      X_lot_number                 in varchar2,
	      X_revision                   in varchar2,
	      X_sub                        in varchar2,
	      X_loc                        in varchar2,
              x_departure_id               in number,
              x_delivery_id                in number,
              x_container_id               in number,
              X_backorder_flag             in boolean,
	      x_context                    in varchar2,
	      x_att1  in varchar2, x_att2  in varchar2, x_att3  in varchar2, x_att4  in varchar2,
	      x_att5  in varchar2, x_att6  in varchar2, x_att7  in varchar2, x_att8  in varchar2,
	      x_att9  in varchar2, x_att10 in varchar2, x_att11 in varchar2, x_att12 in varchar2,
	      x_att13 in varchar2, x_att14 in varchar2, x_att15 in varchar2,
	      error_code                   in out varchar);

   procedure PROCESS_PICKING_DETAILS_INTER
	     (X_TRANSACTION_ID             in number,
              X_departure_id               in number,
              X_delivery_id                in number,
              X_warehouse_id               in number,
	      X_rowid                      in out varchar2,
	      X_backorder_flag             in boolean ,
	      x_error_code                 in out varchar2);

   procedure PROCESS_FREIGHT_CHARGES_INTER
	     (X_transaction_id             in number,
              X_delivery_id                in number,
	      X_del_currency               in out varchar2,
	      x_rowid                      out char,
	      x_error_code                   in out varchar2);

END WSH_SC_TRX_INTERFACE;

 

/
