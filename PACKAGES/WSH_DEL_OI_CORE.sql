--------------------------------------------------------
--  DDL for Package WSH_DEL_OI_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DEL_OI_CORE" AUTHID CURRENT_USER AS
/* $Header: WSHSDVAS.pls 115.5 99/07/16 08:21:53 porting ship $ */


-- WSH_DEL_OI_CORE
-- Purpose
--      Core Validation Routines for Open Interface
-- History
--      20-MAY-96 troveda Created
--

suppress_print	boolean := TRUE;

PROCEDURE GET_ORDER_INFO
          (X_picking_header_id      in  number,
           X_Order_currency         in out varchar2,
           X_Order_category         in out varchar2);

FUNCTION  PICKSLIP_CLOSED
          (X_PICKING_HEADER_ID IN NUMBER) return BOOLEAN ;

PROCEDURE GET_ITEM_CONTROL_CODES
	  (X_warehouse_id               in number,
	   X_item_id                    in number,
           X_order_category             in varchar2,
	   X_subinv_restricted_flag     in out varchar2,
	   X_revision_control_flag      in out varchar2,
	   X_lot_control_flag           in out varchar2,
	   X_serial_number_control_flag in out varchar2,
	   error_code                   in out varchar2);

FUNCTION  VALID_SUBINVENTORY
	  (X_warehouse_id 	        in number,
	   X_item_id 		        in number,
	   X_subinventory               in varchar2,
           X_subinv_restricted_flag     in varchar2) return BOOLEAN;

FUNCTION  DEFAULT_SUBINVENTORY
	  (X_warehouse_id               in number,
	   X_item_id 	                in number) return VARCHAR2;

PROCEDURE GET_LOCATOR_CONTROLS
	  (X_warehouse_id               in number,
	   X_item_id 	                in number,
	   X_subinventory               in varchar2,
           X_location_control_flag      in out varchar2,
           X_location_restricted_flag   in out varchar2,
	   error_code                   in out varchar2);

FUNCTION  VALID_LOT_NUMBER
	  (X_warehouse_id               in number,
	   X_item_id 	                in number,
	   X_subinventory               in varchar2,
           X_lot_number                 in varchar2) return BOOLEAN;

FUNCTION VALID_REVISION
	 (X_warehouse_id                in number,
	  X_item_id 	                in number,
          X_revision                    in varchar2) return BOOLEAN;

FUNCTION  VALID_LOCATOR_ID
 	 (X_warehouse_id                in number,
	  X_item_id 	                in number,
          X_subinventory                in varchar2,
          X_location_restricted_flag    in varchar2,
          X_locator_id                  in number) return BOOLEAN;

FUNCTION DEFAULT_LOCATOR
	(X_warehouse_id                 in number,
	 X_item_id 	                in number,
         X_subinventory                 in varchar2,
         X_location_restricted_flag     in varchar2) return NUMBER;

FUNCTION VALID_SERIAL_NUMBER
	(X_warehouse_id                 in number,
	 X_item_id 	                in number,
         X_subinventory                 in varchar2,
         X_revision                     in varchar2,
         X_lot_number                   in varchar2,
         X_locator_id                   in number,
         X_serial_number                in varchar2,
         X_location_restricted_flag     in varchar2,
         X_location_control_flag        in varchar2,
         X_serial_number_control_flag   in varchar2) return BOOLEAN;

FUNCTION Validate_Container_Id
	(X_container_id                 in number,
	 X_sequence_number              in number,
         x_delivery_id                  in number,
         error_code		        in out varchar2) return NUMBER;


FUNCTION AR_INTERFACED
        (X_delivery_id            	in  number) return BOOLEAN;

FUNCTION  VALID_FREIGHT_TYPE
	(X_in_id                        in number,
	 X_in_code                      in varchar2) return NUMBER;

FUNCTION  Valid_Carrier_Code
	(X_organization_id              in number,
	 X_carrier_code                 in varchar2) return BOOLEAN;

PROCEDURE VALIDATE_CURRENCY
	(X_in_code                      in  varchar2,
	 X_in_name                      in  varchar2,
         X_amount                       in  number,
	 X_out_code                     out varchar2,
	 X_out_name                     out varchar2,
	 error_code                     in out varchar2);

PROCEDURE  VALIDATE_UOM
	(X_class                        in  varchar2,
	 X_uom_code                     in  out varchar2,
         X_uom_desc                     in  varchar2,
	 error_code                     in  out varchar2);


PROCEDURE  VALIDATE_USER
	(X_user_id                      in out number,
	 X_user_name                    in varchar2,
	 error_code                     in out varchar2);


PROCEDURE UPDATE_SHIPPING_ONLINE
        (x_picking_header_id            in number,
         x_batch_id                     in number);

FUNCTION SHIP_MULTI_ORG
        (x_picking_header_id            in  number ) return BOOLEAN;


PROCEDURE  VALIDATE_SO_CODE
	(X_lookup_type	in varchar2,
	 X_code         in out varchar2,
	 X_meaning       in varchar2,
	 X_error_code   in out varchar2);


-- write messages to output if debug is on
PROCEDURE println;
PROCEDURE println (msg IN VARCHAR2);


END WSH_DEL_OI_CORE;

 

/
