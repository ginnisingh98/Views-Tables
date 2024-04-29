--------------------------------------------------------
--  DDL for Package WSH_OI_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OI_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: WSHSCVLS.pls 115.8 99/07/16 08:21:05 porting ship $ */

----------------------------------------------------------------------
-- Name		: WSH_OI_VALIDATE
-- Purpose	: Functions/Procedures for performing field Level
--                validations, on the four Ship Confirm Open Interface
--                tables.
--                These are in turn used in the Ship Confirm Open
--                Interface PL/SQL Function driver, run_interface
--                and can also be re-used by any other API/Form, that
--                wants to perform Ship Confirm field level validations.
-- History	: Sukhbir S. Jolly	Created
--
----------------------------------------------------------------------

-- Bug 878148 . Added organization_id as a new parameter
   PROCEDURE WEIGHT_UOM(x_weight_uom_code IN OUT VARCHAR2 ,
                        x_return_code     IN OUT VARCHAR2,
			x_organization_id IN NUMBER);

   --------------------------------------------------------------------------
   -- Validate the volume_uom_code, only if it is not null (i.e. specified) in
   -- the deliveries interface table.
   --------------------------------------------------------------------------

-- Bug 878148 . Added organization_id as a new parameter
   PROCEDURE VOLUME_UOM(x_volume_uom_code IN OUT VARCHAR2 ,
                        x_return_code     IN OUT VARCHAR2,
			x_organization_id IN NUMBER);

  --------------------------------------------------------------------------
  -- Validate gross weight and net weight in
  -- the Packed Containers Interface Table.
  -- If both are not null and not less than 0
  -- then, gross weight should alway be greater
  -- than or equal to net weight.
  --------------------------------------------------------------------------
  PROCEDURE gross_greater_net(x_gross_weight IN NUMBER,
                              x_net_weight   IN NUMBER,
                              x_return_code  IN OUT VARCHAR2);

   --------------------------------------------------------------------------
   -- Validate the picked_by_id/picked_by_name, only if either one or both
   -- have been specified in the deliveries interface table.
   --------------------------------------------------------------------------

   PROCEDURE PICKER(x_picked_by_id   IN OUT NUMBER ,
                    x_picked_by_name IN     VARCHAR2 ,
                    x_return_code    IN OUT VARCHAR2);

   --------------------------------------------------------------------------
   -- Validate the packed_by_id/packed_by_name, only if either one or both
   -- have been specified in the deliveries interface table.
   --------------------------------------------------------------------------

   PROCEDURE PACKER(x_packed_by_id   IN OUT NUMBER,
                    x_packed_by_name IN     VARCHAR2 ,
                    x_return_code    IN OUT VARCHAR2);

   --------------------------------------------------------------------------
   -- Validate the freight_carrier_code, only if it has been specified in the
   -- deliveries interface table.
   --------------------------------------------------------------------------

   PROCEDURE FREIGHT_CARRIER(x_organization_id      IN     NUMBER,
                             x_freight_carrier_code IN     VARCHAR2 ,
                             x_return_code          IN OUT VARCHAR2);

   --------------------------------------------------------------------------
   -- Validate the freight_terms_code, only if it has been specified in the
   -- deliveries interface table.
   --------------------------------------------------------------------------

   PROCEDURE FREIGHT_TERMS(x_freight_terms_code IN OUT VARCHAR2 ,
                           x_return_code        IN OUT VARCHAR2 );

   --------------------------------------------------------------------------
   -- Validate the fob_code, only if it has been specified in the deliveries
   -- interface table.
   --------------------------------------------------------------------------

   PROCEDURE FOB(x_fob_code    IN     VARCHAR2 ,
                 x_return_code IN OUT VARCHAR2 );

   --------------------------------------------------------------------------
   -- Validate the report_set_id/report_set, only if either or both have been
   -- specified in the deliveries interface table.
   --------------------------------------------------------------------------

   PROCEDURE REPORT_SET(x_report_set_id IN OUT NUMBER ,
                        x_report_set    IN      VARCHAR2 ,
                        x_return_code   IN OUT  VARCHAR2 );

   --------------------------------------------------------------------------
   -- Validate the loading_order_flag/loading_order_desc, only if either or
   -- both have been specified in the deliveries interface table.
   -- Examples of
   --------------------------------------------------------------------------

   PROCEDURE LOADING_ORDER(x_loading_order_flag IN OUT VARCHAR2 ,
                           x_loading_order_desc IN     VARCHAR2 ,
                           x_return_code        IN OUT VARCHAR2 );

   -----------------------------------------------------------------------
   -- If we created a new departure then validate if the departure assigned
   -- to the delivery x_delivery_id and x_departure_id have the same
   -- freight carrier.
   -----------------------------------------------------------------------

   PROCEDURE SAME_CARRIER(x_delivery_id  IN     NUMBER,
                          x_departure_id IN     NUMBER,
                          x_return_code  IN OUT VARCHAR2 );

   -----------------------------------------------------------------------------
   -- Validate if there is at least one picking_line_detail_id, in the
   -- Picking Details Interface table, that does not exist in the table
   -- so_picking_line_details, for a specific transaction under consideration
   -----------------------------------------------------------------------------

   PROCEDURE PLD_EXIST_IN_PLDI(x_transaction_id IN     NUMBER ,
                               x_return_code    IN OUT VARCHAR2);

   -----------------------------------------------------------------------------
   -- Validate if there is at least one picking_line_detail_id, in the
   -- Freight Charges Interface table, that does not exist in the table
   -- so_picking_line_details, for a specific transaction under consideration
   -----------------------------------------------------------------------------

   PROCEDURE PLD_EXIST_IN_FCI( x_transaction_id IN     NUMBER ,
                               x_return_code    IN OUT VARCHAR2) ;

   PROCEDURE CONTAINER_WAREHOUSE( x_container_org      IN OUT NUMBER ,
                                  x_container_org_code IN OUT VARCHAR2 ,
                                  x_organization_id    IN     NUMBER ,
                                  x_return_code        IN OUT VARCHAR2 ) ;

   ----------------------------------------------------------------------------------
   -- Validate if at least the container_id or the sequence_number for the container
   -- has been specified.
   ----------------------------------------------------------------------------------

   PROCEDURE SEQNUM_CONT_EXIST( x_container_id    IN     NUMBER ,
                                x_sequence_number IN     NUMBER ,
                                x_return_code     IN OUT VARCHAR2 );

   ----------------------------------------------------------------------------------
   -- Validate the container when either the container_id or sequence_number or both
   -- have been specified. If the container_id is specified, then it takes precedence
   -- and if not found in WSH_PACKED_CONTAINERS, then it is a validation error. If
   -- only the sequence_number of the container has been specified, and it does not
   -- exist in WSH_PACKED_CONTAINERS table, then it means that the user wants to
   -- create a new container, and is not a validation error.
   ----------------------------------------------------------------------------------

   PROCEDURE CONTAINER(rec_container_id    	IN     NUMBER,
                       rec_sequence_number 	IN     NUMBER,
                       rec_delivery_id     	IN     NUMBER,
                       x_container_id		IN OUT NUMBER,
		       x_return_code     	IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Validate if the Parent Container already exists in the packed containers table
   -- Also validate if the Parent Sequence Number and Sequence Number are Equal, if
   -- they are both specified (i.e. not null)
   ----------------------------------------------------------------------------------

   PROCEDURE PARENT_SEQ_SELF(x_parent_sequence_number   IN      NUMBER,
                             x_sequence_number          IN      NUMBER,
                             x_delivery_id              IN      NUMBER,
                             x_return_code              IN  OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- GM EDIFACT (11.5) validate the parent sequence number.
   ----------------------------------------------------------------------------------

   PROCEDURE Parent_Seq_Concur(x_parent_sequence_number IN NUMBER,
                               p_parent_container_id IN OUT NUMBER,
                               x_container_item_id IN NUMBER,
                               x_delivery_id IN NUMBER,
                               x_delivery_name IN VARCHAR2,
                               x_organization_id IN NUMBER,
                               p_error_code OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Validate the Parent Container ID. It has to be a valid container_id in
   -- wsh_packed_containers.
   ----------------------------------------------------------------------------------

   PROCEDURE PARENT_CONT(x_parent_container_id IN NUMBER,
                         p_parent_sequence_number IN OUT NUMBER,
                         x_container_item_id IN NUMBER,
                         x_organization_id IN NUMBER,
                         p_error_code IN OUT VARCHAR2);

   -------------------------------------------------------------------------------
   --FUNCTION Container_Inverse_Check
   -------------------------------------------------------------------------------
   FUNCTION Container_Inverse_Check(x_parent_container_item_id IN NUMBER,
                                    x_container_item_id IN NUMBER,
                                    x_organization_id IN NUMBER) RETURN BOOLEAN;

   ----------------------------------------------------------------------------------
   -- Validate master_serial_number. It must be unique for all master containers.
   ----------------------------------------------------------------------------------

   PROCEDURE MASTER_SERIAL_NUMBER(x_master_serial_number NUMBER,
                                  x_return_code          IN  OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Validate master container id.
   ----------------------------------------------------------------------------------

   PROCEDURE master_container_id(
      X_parent_container_id    IN     NUMBER,
      X_parent_sequence_number IN     NUMBER,
      X_container_id           IN     NUMBER,
      X_delivery_id            IN     NUMBER,
      X_master_container_id    IN OUT NUMBER,
      X_return_code            IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Populate master_container_id in wsh_packed_containers
   ----------------------------------------------------------------------------------

   PROCEDURE populate_master_cont_id(
      X_delivery_id            IN     NUMBER,
      X_sequence_number        IN     NUMBER,
      X_container_id           IN     NUMBER,
      X_parent_container_id    IN     NUMBER,
      X_parent_sequence_number IN     NUMBER,
      X_master_container_id    IN     NUMBER,
      X_return_code            IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Populate master_serial_number in wsh_packed_containers
   ----------------------------------------------------------------------------------

   PROCEDURE populate_master_serial_num(
      X_delivery_id            IN     NUMBER,
      X_sequence_number        IN     NUMBER,
      X_container_id           IN     NUMBER,
      X_parent_container_id    IN     NUMBER,
      X_parent_sequence_number IN     NUMBER,
      X_master_serial_number   IN     NUMBER,
      X_return_code            IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Populate parent_container_id in wsh_packed_containers
   ----------------------------------------------------------------------------------

   PROCEDURE populate_parent_cont_id(
      X_delivery_id            IN     NUMBER,
      X_sequence_number        IN     NUMBER,
      X_container_id           IN     NUMBER,
      X_return_code            IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Populate parent_sequence_number in wsh_packed_containers
   ----------------------------------------------------------------------------------

   PROCEDURE populate_parent_seq_num(
      X_sequence_number     IN     NUMBER,
      X_delivery_id         IN     NUMBER,
      X_container_id        IN     NUMBER,
      X_return_code         IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Update parent_sequence_number in wsh_packed_containers for this container,
   -- according to the parent_container_id.
   ----------------------------------------------------------------------------------

   PROCEDURE update_parent_seq_num(
      X_parent_container_id    IN     NUMBER,
      X_parent_sequence_number IN OUT NUMBER,
      X_delivery_id            IN     NUMBER,
      X_container_id           IN     NUMBER,
      X_return_code            IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Update parent_container_id in wsh_packed_containers for this container,
   -- according to the parent_sequence_number.
   ----------------------------------------------------------------------------------

   PROCEDURE update_parent_cont_id(
      X_parent_sequence_number IN     NUMBER,
      X_parent_contaienr_id    IN OUT NUMBER,
      X_delivery_id            IN     NUMBER,
      X_container_id           IN     NUMBER,
      X_return_code            IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Update master_container_id in wsh_packed_containers for this container,
   -- according to the parent_container_id or parent_sequence_number.
   ----------------------------------------------------------------------------------

   PROCEDURE update_master_cont_id(
      X_parent_sequence_number IN     NUMBER,
      X_parent_container_id    IN     NUMBER,
      X_delivery_id            IN     NUMBER,
      X_container_id           IN     NUMBER,
      X_sequence_number        IN     NUMBER,
      X_master_container_id    IN OUT NUMBER,
      X_return_code            IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Update master_serial_number in wsh_packed_containers for this container,
   -- according to the parent_container_id or parent_sequence_number.
   ----------------------------------------------------------------------------------

   PROCEDURE update_master_serial_num(
      X_parent_sequence_number IN     NUMBER,
      X_parent_container_id    IN     NUMBER,
      X_delivery_id            IN     NUMBER,
      X_container_id           IN     NUMBER,
      X_master_serial_number   IN OUT NUMBER,
      X_return_code            IN OUT VARCHAR2);


   ----------------------------------------------------------------------------------
   -- Validate if the container quantity is negative and not a whole number
   ----------------------------------------------------------------------------------

   PROCEDURE QTY( x_quantity    IN  NUMBER ,
                  x_return_code IN OUT VARCHAR2 );

   --------------------------------------------------------------------------------------
   -- Validate if the delivery under consideration is already AR Interfaced
   --------------------------------------------------------------------------------------

   PROCEDURE IF_AR_INTFACED(x_delivery_id IN  NUMBER ,
                            x_return_code IN  OUT VARCHAR2 );

   --------------------------------------------------------------------------------------
   -- Validate the freight charge type id and desc , if either one or both of them are
   -- specified
   --------------------------------------------------------------------------------------

   PROCEDURE FREIGHT_CHARGE_TYPE(x_freight_charge_type_id   IN     NUMBER,
                                 x_freight_charge_type_desc IN     VARCHAR2,
                                 x_type_id                  IN OUT NUMBER,
				 x_return_code              IN OUT VARCHAR2);

   ----------------------------------------------------------------------------
   -- Validate the currency code, at least the currency code or name, has to be
   -- specified
   ----------------------------------------------------------------------------

   PROCEDURE FRT_CURRENCY_CODE(x_currency_code IN     VARCHAR2,
                           x_currency_name     IN     VARCHAR2,
                           x_amount            IN     NUMBER,
                           x_valid_cur_code       OUT VARCHAR2,
                           x_valid_cur_name       OUT VARCHAR2,
                           x_return_code       IN OUT VARCHAR2);

   ----------------------------------------------------------------------------
   -- Validate if the delivery currency and the freight charge currency are the
   -- same
   ----------------------------------------------------------------------------

   PROCEDURE DEL_FRT_CURR(x_currency_code  IN     VARCHAR2,
                          x_del_currency   IN     VARCHAR2,
                          x_return_code    IN OUT VARCHAR2);


   ----------------------------------------------------------------------------
   -- Validate if the currency specified in the deliveries table is the same
   -- on all the delivery lines associated with it.
   ----------------------------------------------------------------------------


   PROCEDURE SAME_CURRENCY(x_transaction_id IN NUMBER,
			   x_delivery_id IN NUMBER,
			   x_currency_code IN VARCHAR2,
                           x_return_code IN OUT VARCHAR2);


   ----------------------------------------------------------------------------
   -- Validate values for Ship Confirm Action Codes , when specified
   ----------------------------------------------------------------------------

   PROCEDURE ACTION_CODE( x_action_code   IN     NUMBER,
                          x_return_code   IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------------------
   -- Validate if the value is negative or zero, the x_entity_code, indicates the entity being considered
   -- i.e. VOLUME, WEIGHT etc.
   ----------------------------------------------------------------------------------------------

   PROCEDURE IF_NEGATIVE_ZERO( x_value       IN     NUMBER,
                               x_entity_code IN     VARCHAR2,
                               x_return_code IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------------------
   -- Validate if the value is negative, the x_entity_code, indicates the entity being considered
   -- i.e. VOLUME, WEIGHT etc. This value could be zero.
   ----------------------------------------------------------------------------------------------

   PROCEDURE IF_NEGATIVE( x_value       IN     NUMBER,
                          x_entity_code IN     VARCHAR2,
                          x_return_code IN OUT VARCHAR2);

   ------------------------------------------------------------------------
   -- Validate customer_id and customer_number, if at least one of them have
   -- been specified
   -------------------------------------------------------------------------

   PROCEDURE CUSTOMER( x_customer_id     IN OUT NUMBER,
                       x_customer_number IN OUT VARCHAR2,
                       x_return_code     IN OUT VARCHAR2);

   --------------------------------------------------------------------------------
   -- Validate the warehouse, if either the organization_id or organization_code are
   -- specified
   --------------------------------------------------------------------------------

   PROCEDURE WAREHOUSE( x_org_id          IN OUT NUMBER,
                        x_org_code        IN OUT VARCHAR2,
                        x_return_code     IN OUT VARCHAR2);

   --------------------------------------------------------------------------------
   -- Validate for Duplicate AETCs, this is a check specifically for Automotive
   --------------------------------------------------------------------------------

   PROCEDURE DUPLICATE_AETC( x_aetc        IN VARCHAR2,
                             x_delivery_id IN NUMBER,
                             x_return_code IN OUT VARCHAR2);


   --------------------------------------------------------------------------------
   -- Validate Container Inventory Item ID, when Item ID is specified only
   --------------------------------------------------------------------------------

   PROCEDURE CONTAINER_ITEM( x_organization_id              IN     NUMBER,
                             x_cont_inventory_item_id       IN     NUMBER,
                             x_subinv_restricted_flag       IN OUT VARCHAR2,
                             x_revision_control_flag        IN OUT VARCHAR2,
                             x_lot_control_flag             IN OUT VARCHAR2,
                             x_serial_number_control_flag   IN OUT VARCHAR2,
                             x_return_code                  IN OUT VARCHAR2);

   --------------------------------------------------------------------------------
   -- Validate Subinventory
   --------------------------------------------------------------------------------

   PROCEDURE SUBINVENTORY (x_warehouse_id IN     NUMBER,
                          x_subinventory  IN OUT VARCHAR2,
                          x_return_code   IN OUT VARCHAR2);

   --------------------------------------------------------------------------------
   -- Validate For Inequality , when the arguments are numbers
   --------------------------------------------------------------------------------

   PROCEDURE NOT_EQUAL(value1        IN     NUMBER,
                       value2        IN     NUMBER,
                       entity_code   IN     VARCHAR2,
                       x_return_code IN OUT VARCHAR2);

   --------------------------------------------------------------------------------
   -- Validate For Inequality , when the arguments are numbers
   --------------------------------------------------------------------------------

   PROCEDURE NOT_EQUAL(value1        IN     NUMBER,
                      value2        IN     VARCHAR2,
                      entity_code   IN     VARCHAR2,
                      x_return_code IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- Validate Locator
   ----------------------------------------------------------------------------------

   PROCEDURE LOCATOR( x_locator_id 		IN     NUMBER,
		      x_locator    		IN     VARCHAR2,
                      x_valid_warehouse_id   	IN     NUMBER,
                      x_valid_loc     		IN OUT NUMBER,
	              x_seg_array          	IN FND_FLEX_EXT.SegmentArray,
                      x_return_code       	IN OUT VARCHAR2);


   ----------------------------------------------------------------------------------
   -- Validate Inventory Item ID, if specified
   ----------------------------------------------------------------------------------

   PROCEDURE INVENTORY_ITEM( x_inventory_item_id IN     NUMBER,
			     x_inventory_item    IN     VARCHAR2,
                             x_organization_id   IN     NUMBER,
			     x_sopld_item_id     IN     NUMBER,
                             x_valid_item_id     IN OUT NUMBER,
 			     x_seg_array         IN FND_FLEX_EXT.SegmentArray,
                             x_return_code       IN OUT VARCHAR2);


   ----------------------------------------------------------------------------------
   -- Validate Vehicle Item ID, if specified
   -- It does not validate with the vehicle id existing in wsh_departures.
   ----------------------------------------------------------------------------------

   PROCEDURE VEHICLE_ITEM( x_vehicle_item_id   IN     NUMBER,
                           x_vehicle_item      IN     VARCHAR2,
                           x_organization_id   IN     NUMBER,
                           x_valid_item_id     IN OUT NUMBER,
                           x_seg_array         IN FND_FLEX_EXT.SegmentArray,
                           x_return_code       IN OUT VARCHAR2);


   ------------------------------------------------------------------------------------
   -- Validate Inventory Item Location , when Item Location ID was specified
   ------------------------------------------------------------------------------------

   PROCEDURE ITEM_LOCATION( x_organization_id       IN     NUMBER,
                            x_inventory_location_id IN     NUMBER,
                            x_return_code           IN OUT VARCHAR2);

   ------------------------------------------------------------------------------------
   -- Validate if both attributes are NULL , for NUMBER
   ------------------------------------------------------------------------------------

   PROCEDURE BOTH_ARE_NULL( x_attr1       IN     NUMBER,
                            x_attr2       IN     NUMBER,
                            x_entity_code IN     VARCHAR2,
                            x_return_code IN OUT VARCHAR2);

   ------------------------------------------------------------------------------------
   -- Validate if both attributes are NULL , for VARCHAR2 and NUMBER attributes
   ------------------------------------------------------------------------------------

   PROCEDURE BOTH_ARE_NULL( x_attr1       IN     NUMBER,
                            x_attr2       IN     VARCHAR2,
                            x_entity_code IN     VARCHAR2,
                            x_return_code IN OUT VARCHAR2);

   ------------------------------------------------------------------------------------
   -- Validate that if the serial number is specified in the picking details interface
   -- table , if the serial number control flag = N
   ------------------------------------------------------------------------------------

   PROCEDURE SERIAL_NUM_REQD( x_serial_number    IN     VARCHAR2,
                              x_serial_ctrl_flag IN     VARCHAR2,
                              x_return_code      IN OUT VARCHAR2);

   ------------------------------------------------------------------------------------
   -- Validate if serial number qty > 1
   ------------------------------------------------------------------------------------

   PROCEDURE SERIAL_QTY( x_serial_qty    IN     NUMBER,
                         x_return_code   IN OUT VARCHAR2);

   ------------------------------------------------------------------------------------
   -- Validate if the Delivery is already Packed and that there are more lines to be
   -- added to the delivery, for that particular transaction
   ------------------------------------------------------------------------------------

   PROCEDURE DEL_PACKED( x_delivery_status IN     VARCHAR2,
                         x_transaction_id  IN     NUMBER,
                         x_return_code     IN OUT VARCHAR2);

   -----------------------------------------------------------------------------
   -- Validate if there is at least one picking_line_detail_id, in the
   -- Freight Charges Interface or Picking Line Details Interface table, that
   -- does not exist in the table so_picking_line_details, for a specific
   -- transaction under consideration. This is specifically for the SCOI Form
   -- or other Form
   -----------------------------------------------------------------------------

   PROCEDURE PLD_EXIST_FORM( x_picking_line_detail_id IN     NUMBER,
                             x_return_code            IN OUT VARCHAR2);


   PROCEDURE CHECK_PREV_ERR_IN_DELIVERY( x_transaction_id IN     NUMBER,
                                         x_delivery_id    IN     NUMBER,
                                         x_delivery_name  IN     VARCHAR2,
                                         x_return_code    IN OUT VARCHAR2);

   --------------------------------------------------------------------------
   -- Validate the ship to, when it is specified. This is a common function
   -- for Ultimate, Intermediate and Pooled Shipto.
   --------------------------------------------------------------------------

   PROCEDURE SHIPTO( x_shipto      IN OUT NUMBER,
                     x_entity_code IN     VARCHAR2,
                     x_return_code IN OUT VARCHAR2);



   --------------------------------------------------------------------------
   -- Validate reseting variables if org/item have changed
   --------------------------------------------------------------------------

   PROCEDURE CHANGED_ITEM_ORG(x_warehouse_id		   	IN     	NUMBER,
			      x_last_warehouse_id		IN OUT 	NUMBER,
		 	      x_valid_item_id			IN OUT 	NUMBER,
			      x_last_item_id			IN OUT 	NUMBER,
			      x_subinv_restricted_flag		IN OUT 	VARCHAR2,
    			      x_revision_control_flag 		IN OUT 	VARCHAR2,
    			      x_lot_control_flag		IN OUT 	VARCHAR2,
    			      x_serial_number_control_flag      IN OUT 	VARCHAR2,
		              x_return_code                     IN OUT 	VARCHAR2);

   --------------------------------------------------------------------------
   -- Validate if a reservation, ensure no interface controls, if input are
   -- the same if any inventory controls have changed from the reservation
   -- then raise error
   --------------------------------------------------------------------------

   PROCEDURE RES_INV_CTRL_CHANGE(x_lot_number		IN 	VARCHAR2,
				 x_sopld_lot_number	IN 	VARCHAR2,
			         x_revision		IN 	VARCHAR2,
                                 x_sopld_revision	IN 	VARCHAR2,
			         x_subinventory		IN 	VARCHAR2,
                                 x_sopld_subinventory	IN 	VARCHAR2,
				 x_locator_id		IN 	NUMBER,
                                 x_sopld_locator_id	IN 	NUMBER,
				 x_return_code		IN OUT	VARCHAR2);


   --------------------------------------------------------------------------
   --  PLD SUBINVENTORY VALIDATION

   --  Scenario            SOPLD   Statement
   --             value    value   satisfied  Action
   --  ---------  -----    -----   ---------  ----------------
   --  1          sub1     sub1    elsif 1    copies SOPLD value
   --  2          sub1     sub2    if       - calls validation
   --  3          sub1     null    if       - calls validation
   --  4          null     null    elsif 2  - assigns default
   --  5          null     sub1    elsif 1    copies SOPLD value

   --------------------------------------------------------------------------

   PROCEDURE PLD_SUBINVENTORY(x_subinventory		   IN OUT VARCHAR2,
			      x_sopld_subinventory	   IN OUT VARCHAR2,
			      x_valid_warehouse_id         IN OUT NUMBER,
    	 	              x_valid_item_id		   IN OUT NUMBER,
    	                      x_subinv_restricted_flag     IN OUT VARCHAR2,
			      x_valid_sub		   IN OUT VARCHAR2,
			      x_default_sub		   IN OUT VARCHAR2,
			      x_return_code                IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- PLD LOT NUMBER VALIDATION
   ----------------------------------------------------------------------------------

   PROCEDURE PLD_LOT_NUMBER(x_lot_number   	   IN OUT VARCHAR2,
			    x_lot_control_flag	   IN OUT VARCHAR2,
			    x_sopld_lot_number     IN OUT VARCHAR2,
			    x_valid_warehouse_id   IN OUT NUMBER,
		            x_valid_item_id        IN OUT NUMBER ,
		            x_valid_sub            IN OUT VARCHAR2,
		            x_valid_lot            IN OUT VARCHAR2,
			    x_return_code          IN OUT VARCHAR2);


   ----------------------------------------------------------------------------------
   -- PLD REVISION VALIDATION
   ----------------------------------------------------------------------------------

   PROCEDURE PLD_REVISION(x_revision		  	IN OUT VARCHAR2,
		          x_sopld_revision		IN OUT VARCHAR2,
			  x_valid_warehouse_id		IN OUT NUMBER,
			  x_valid_item_id		IN OUT NUMBER,
			  x_valid_revision		IN OUT VARCHAR2,
		 	  x_revision_control_flag	IN OUT VARCHAR2,
			  x_return_code          	IN OUT VARCHAR2);


   ----------------------------------------------------------------------------------
   -- PLD ITEM LOCATION VALIDATION
   -- Get location_control flags if item/org/sub have changed VALIDATION
   ----------------------------------------------------------------------------------

   PROCEDURE PLD_ITEM_LOCATION(x_valid_warehouse_id 		IN OUT NUMBER,
			       x_last_warehouse_id		IN OUT NUMBER,
			       x_valid_item_id			IN OUT NUMBER,
			       x_last_item_id			IN OUT NUMBER,
			       x_valid_sub			IN OUT VARCHAR2,
			       x_last_sub			IN OUT VARCHAR2,
			       x_location_control_flag		IN OUT VARCHAR2,
			       x_location_restricted_flag	IN OUT VARCHAR2,
			       x_valid_loc			IN OUT NUMBER,
			       x_return_code			IN OUT VARCHAR2);

   ----------------------------------------------------------------------------------
   -- PLD LOCATOR VALIDATION
   ----------------------------------------------------------------------------------

   PROCEDURE PLD_LOCATOR(x_locator_id			IN OUT NUMBER,
		         x_sopld_locator_id		IN OUT NUMBER,
		     	 x_valid_loc			IN OUT NUMBER,
		     	 x_default_loc			IN OUT NUMBER,
		     	 x_locator_concat_segments	IN OUT VARCHAR2,
		     	 x_location_control_flag	IN OUT VARCHAR2,
		     	 x_valid_warehouse_id		IN OUT NUMBER,
		     	 x_valid_item_id		IN OUT NUMBER,
                     	 x_valid_sub			IN OUT VARCHAR2,
		     	 x_location_restricted_flag	IN OUT VARCHAR2,
		     	 x_valid_flag			IN OUT BOOLEAN,
			 seg_array			IN FND_FLEX_EXT.SegmentArray,
		     	 x_return_code			IN OUT VARCHAR2);


   ----------------------------------------------------------------------------------
   -- PLD LOCATOR VALIDATION
   ----------------------------------------------------------------------------------

   PROCEDURE PLD_SERIAL_NUMBER(x_sn				IN OUT VARCHAR2,
			       x_serial_number_control_flag	IN OUT VARCHAR2,
			       x_shipped_quantity 		IN OUT NUMBER,
			       x_valid_warehouse_id		IN OUT NUMBER,
			       x_valid_item_id			IN OUT NUMBER,
			       x_valid_sub			IN OUT VARCHAR2,
            		       x_valid_revision			IN OUT VARCHAR2,
			       x_valid_lot			IN OUT VARCHAR2,
			       x_valid_loc			IN OUT NUMBER,
			       x_location_restricted_flag	IN OUT VARCHAR2,
			       x_location_control_flag		IN OUT VARCHAR2,
			       x_row_id				IN OUT VARCHAR2,
			       x_picking_line_id		IN OUT NUMBER,
                               x_picking_line_detail_id		IN OUT NUMBER,
		     	       x_return_code			IN OUT VARCHAR2);


  ----------------------------------------------------------------------------------
  -- PLD LINE ADDITION VALIDATION
  -- Validate this line can be added to this delivery.
  ----------------------------------------------------------------------------------

  PROCEDURE PLD_LINE_ADD(x_delivery_id			IN     NUMBER,
			 x_sopld_delivery_id		IN     NUMBER,
			 x_del_status			IN OUT VARCHAR2,
			 x_result			IN OUT BOOLEAN,
			 x_result_num			IN OUT NUMBER,
			 x_picking_line_detail_id	IN OUT NUMBER,
			 x_token_name			IN OUT VARCHAR2,
			 x_return_code			IN OUT VARCHAR2);




  PROCEDURE flexfields(id 		IN  	NUMBER,
		       valid_id		IN OUT	NUMBER,
		       item  		IN   	VARCHAR2,
		       app_short_name  	IN 	VARCHAR2,
		       key_flx_code    	IN 	VARCHAR2,
   		       struct_number 	IN 	NUMBER,
		       org_id		IN 	NUMBER,
		       seg_array       	IN 	FND_FLEX_EXT.SegmentArray,
		       val_or_ids	IN	VARCHAR2,
                       flag             IN OUT  BOOLEAN,
                       wh_clause        IN      VARCHAR2 DEFAULT NULL);



END WSH_OI_VALIDATE ;

 

/
