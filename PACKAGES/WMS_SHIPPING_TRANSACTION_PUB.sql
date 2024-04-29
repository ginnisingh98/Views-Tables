--------------------------------------------------------
--  DDL for Package WMS_SHIPPING_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SHIPPING_TRANSACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSPSHPS.pls 120.3.12010000.3 2009/07/08 12:03:08 nittshar ship $ */
/*#
  * These procedures act as an integration between Shipping and WMS
  * for direct ship, LPN ship, managing trips and delivery, closing trucks.
  * @rep:scope public
  * @rep:product WMS
  * @rep:lifecycle active
  * @rep:displayname Integraion object between Shipping and WMS
  * @rep:category BUSINESS_ENTITY WMS_SHIPPING_TRANSACTION
*/


TYPE t_genref IS REF CURSOR;

G_PKG_NAME constant VARCHAR2(30) := 'WMS_SHIPPING_TRANSACTION_PUB';
--G_ALLOW_SHIP_SET_BREAK VARCHAR2(1) := 'N'; -- code removed added for bug#8596010

G_ALLOW_SHIP_SET_BREAK VARCHAR2(1) := '';  -- code added for bug#8596010

FUNCTION IS_LOADED(p_organization_id IN NUMBER,
                   p_dock_door_id   IN NUMBER,
                   p_dock_appoint_flag   IN VARCHAR2,
                   p_direct_ship_flag    IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;

     PROCEDURE GET_DOCK_DOORS(x_dock_door_LOV OUT NOCOPY t_genref,
                              p_txn_dock_app  IN VARCHAR2,
			      p_organization_id IN NUMBER,
			      p_dock_door IN VARCHAR2);

     procedure get_deliveries( x_delivery_lov OUT NOCOPY t_genref,
                               p_trip_id IN NUMBER);

     procedure get_delivery_info(x_delivery_info OUT NOCOPY t_genref,
                            p_delivery_id IN NUMBER);

     PROCEDURE GET_STAGING_LANE(x_staging_lane_LOV    OUT NOCOPY t_genref,
				p_txn_dock	      IN VARCHAR2,
				p_organization_id     IN NUMBER,
                                p_sub_code            IN VARCHAR2,
				p_dock_appointment_id IN NUMBER,
				p_staging_lane        IN VARCHAR2);

     PROCEDURE GET_DELIVERY_DETAIL_ID(x_delivery_detail_id OUT NOCOPY t_genref,
                                      p_organization_id    IN NUMBER,
                                      p_locator_id         IN NUMBER,
                                      p_trip_id            IN NUMBER);

     PROCEDURE POPULATE_WSTT(x_return           OUT NOCOPY NUMBER,
			     x_msg_code         OUT NOCOPY VARCHAR2,
			     p_organization_id 	IN NUMBER,
			     p_lpn_id	        IN NUMBER,
			     p_trip_id		IN NUMBER,
                             p_dock_door_id     IN NUMBER,
                             p_direct_ship_flag IN VARCHAR2 DEFAULT 'N');

     FUNCTION GET_DELIVERY_NAME(p_delivery_id   IN NUMBER)
         RETURN VARCHAR2;

     PROCEDURE GET_LPN_LOV(x_lpn_lov                 out NOCOPY t_genref,
                           p_organization_id         IN NUMBER,
                           p_locator_id              IN NUMBER,
                           p_trip_id                 IN NUMBER,
                           p_trip_stop_id            IN NUMBER,
                           p_lpn                     IN VARCHAR2);

  procedure nested_serial_check(x_result OUT NOCOPY NUMBER,
                              x_outermost_lpn OUT NOCOPY VARCHAR2,
                              x_outermost_lpn_id OUT NOCOPY NUMBER,
                              x_parent_lpn_id OUT NOCOPY NUMBER,
                              x_parent_lpn OUT NOCOPY VARCHAR2,
                              x_inventory_item_id OUT NOCOPY NUMBER,
                              x_quantity OUT NOCOPY NUMBER,
                              x_requested_quantity OUT NOCOPY NUMBER,
                              x_delivery_detail_id OUT NOCOPY NUMBER,
			      x_transaction_temp_id OUT NOCOPY NUMBER,
			      x_item_name OUT NOCOPY VARCHAR2,
                              x_subinventory_code OUT NOCOPY VARCHAR2,
                              x_revision OUT NOCOPY VARCHAR2,
                              x_locator_id OUT NOCOPY NUMBER,
                              x_lot_number OUT NOCOPY VARCHAR2,
                              p_trip_id IN NUMBER,
                              p_outermost_lpn_id IN NUMBER);

 PROCEDURE LPN_DISCREPANCY_CHECK( x_result OUT NOCOPY NUMBER,
                                 x_parent_lpn_id OUT NOCOPY NUMBER,
                                 x_parent_lpn OUT NOCOPY VARCHAR2,
                                 x_inventory_item_id OUT NOCOPY NUMBER,
                                 x_quantity OUT NOCOPY NUMBER,
                                 x_requested_quantity OUT NOCOPY NUMBER,
				 x_item_name OUT NOCOPY VARCHAR2,
                                 p_trip_id IN NUMBER,
			         p_delivery_id IN NUMBER,
                                 p_outermost_lpn_id IN NUMBER);

  PROCEDURE check_lpn_in_same_trip(p_outermost_lpn_id IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_dock_door_id IN NUMBER,
                              x_result OUT NOCOPY NUMBER,
                              x_loaded_dock_door OUT NOCOPY VARCHAR2,
                              x_delivery_name OUT NOCOPY VARCHAR2,
                              x_trip_name     OUT NOCOPY VARCHAR2);

  PROCEDURE LPN_SUBMIT(p_outermost_lpn_id IN NUMBER,
                       p_trip_id         IN NUMBER,
                     p_organization_id IN NUMBER,
                     p_dock_door_id    IN NUMBER,
                     x_error_code         OUT NOCOPY NUMBER,
                     x_outermost_lpn OUT NOCOPY VARCHAR2,
                     x_outermost_lpn_id OUT NOCOPY NUMBER,
                     x_parent_lpn_id OUT NOCOPY NUMBER,
                     x_parent_lpn OUT NOCOPY VARCHAR2,
                     x_inventory_item_id OUT NOCOPY NUMBER,
                     x_quantity OUT NOCOPY NUMBER,
                     x_requested_quantity OUT NOCOPY NUMBER,
                     x_delivery_detail_id OUT NOCOPY NUMBER,
                     x_transaction_Temp_id OUT NOCOPY NUMBER,
                     x_item_name OUT NOCOPY VARCHAR2,
                     x_subinventory_code OUT NOCOPY VARCHAR2,
                     x_revision OUT NOCOPY VARCHAR2,
                     x_locator_id OUT NOCOPY NUMBER,
                     x_lot_number OUT NOCOPY VARCHAR2,
                     x_loaded_dock_door OUT NOCOPY VARCHAR2,
                     x_delivery_name OUT NOCOPY VARCHAR2,
                     x_trip_name     OUT NOCOPY VARCHAR2,
                     x_delivery_detail_ids OUT NOCOPY VARCHAR2,
                     p_is_rfid_call  IN VARCHAR2 DEFAULT 'N'
                       );

  PROCEDURE CHECK_LPN_DELIVERIES( p_trip_id IN NUMBER,
				  p_organization_id IN NUMBER,
				  p_dock_door_id IN NUMBER,
				  p_outermost_lpn_id  IN NUMBER,
				  p_delivery_id       IN NUMBER,
				  x_error_code OUT NOCOPY NUMBER,
				  x_missing_item OUT NOCOPY t_genref,
				  x_missing_lpns OUT NOCOPY t_genref,
				  x_ship_set     OUT NOCOPY VARCHAR2,
				  x_delivery_info OUT NOCOPY t_genref,
				  x_deli_count OUT NOCOPY NUMBER,
				  p_rfid_call   IN VARCHAR2 DEFAULT 'N');

  PROCEDURE CREATE_DELIVERY(p_outermost_lpn_id IN NUMBER,
                            p_trip_id          IN NUMBER,
                            p_organization_id  IN NUMBER,
                            p_dock_door_id     IN NUMBER,
                            x_delivery_id      OUT NOCOPY NUMBER,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_message          OUT NOCOPY VARCHAR2,
                            p_direct_ship_flag IN  VARCHAR2  DEFAULT 'N');

  PROCEDURE GET_LPN_DELIVERY(x_deliveryLOV OUT NOCOPY t_genref,
                             p_trip_id       IN NUMBER,
                             p_organization_id IN NUMBER,
                             p_dock_door_id  IN NUMBER,
                             p_delivery_name IN VARCHAR2);

  PROCEDURE update_trip(p_delivery_id IN NUMBER DEFAULT NULL
			,p_trip_id    IN NUMBER DEFAULT NULL
			,p_ship_method_code IN VARCHAR2
			,x_return_status    OUT nocopy VARCHAR2
			,x_msg_data         OUT nocopy VARCHAR2
			,x_msg_count        OUT nocopy number);

  --This procedure calls update_trip if delivery belongs to a trip
  --and ship_method_code can be propagated up to the trip level
  PROCEDURE UPDATE_DELIVERY(p_delivery_id      IN NUMBER,
			    p_gross_weight     IN NUMBER,
                            p_weight_uom       IN VARCHAR2,
                            p_waybill          IN VARCHAR2,
                            p_bol              IN VARCHAR2,
                            p_ship_method_code IN VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2);

  PROCEDURE MISSING_ITEM_CHECK( x_missing_item OUT NOCOPY t_genref,
				p_trip_id IN NUMBER,
				p_dock_door_id IN NUMBER,
				p_organization_id IN NUMBER,
                                x_missing_count   OUT NOCOPY NUMBER);

  PROCEDURE nontransactable_item_check(x_nt_item OUT NOCOPY t_genref,
				       p_trip_id IN NUMBER,
				       p_dock_door_id IN NUMBER,
				       p_organization_id IN NUMBER,
				       x_nt_count   OUT NOCOPY NUMBER);

  PROCEDURE SHIP_SET_CHECK( p_trip_id IN NUMBER,
                            p_dock_door_id IN NUMBER,
                            p_organization_id IN NUMBER,
                            x_ship_set      OUT NOCOPY VARCHAR2,
                            x_return_Status OUT NOCOPY VARCHAR2,
                            x_error_msg     OUT NOCOPY VARCHAR2,
                            p_direct_ship_flag IN varchar2 default 'N');

  PROCEDURE MISSING_LPN_CHECK(x_missing_lpns OUT NOCOPY t_genref,
                            p_trip_id IN NUMBER,
                            p_dock_door_id IN NUMBER,
                            p_organization_id IN NUMBER,
                            x_missing_count   OUT NOCOPY NUMBER);

  PROCEDURE GET_MISSING_LPN_LOV(x_lpn_lov                 out NOCOPY t_genref,
                           p_organization_id         IN NUMBER,
                           p_dock_door_id            IN NUMBER,
                           p_trip_id                 IN NUMBER,
                           p_lpn                     IN VARCHAR2);

   PROCEDURE PRINT_LABEL(p_del_rows         IN      wsh_util_core.id_tab_type,
                         x_return_status    OUT     NOCOPY VARCHAR2);

   PROCEDURE SHIP_CONFIRM(p_delivery_id IN NUMBER,
			  p_organization_id IN NUMBER,
			  p_delivery_name IN VARCHAR2,
                          p_carrier_id IN NUMBER,
                          p_ship_method_code IN VARCHAR2,
                          p_gross_weight IN NUMBER,
			  p_gross_weight_uom IN VARCHAR2,
                          p_bol IN VARCHAR2,
                          p_waybill IN VARCHAR2,
			  p_action_flag IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER);

   PROCEDURE SHIP_CONFIRM_ALL(p_delivery_id IN NUMBER,
                          p_organization_id IN NUMBER,
                          p_delivery_name IN VARCHAR2,
                          p_carrier_id IN NUMBER,
                          p_ship_method_code IN VARCHAR2,
                          p_gross_weight IN NUMBER,
                          p_gross_weight_uom IN VARCHAR2,
                          p_bol IN VARCHAR2,
                          p_waybill IN VARCHAR2,
                          p_action_flag IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER);

   PROCEDURE SHIP_CONFIRM_LPN_DELIVERIES(x_return_status OUT NOCOPY VARCHAR2,
                          		 x_msg_data OUT NOCOPY VARCHAR2,
                          		 x_msg_count OUT NOCOPY NUMBER,
                                         p_trip_stop_id  IN NUMBER,
                                         p_trip_id IN NUMBER,
                                         p_dock_door_id IN NUMBER,
                                         p_organization_id IN NUMBER,
                                         p_verify_only IN VARCHAR2,
					 p_close_trip_flag IN VARCHAR2 DEFAULT 'N',
					 p_allow_ship_set_break IN VARCHAR2 DEFAULT 'N');

   procedure get_serial_number_for_so(
	x_serial_lov out NOCOPY t_genref,
	p_inventory_item_id IN NUMBER,
	p_organization_id   IN NUMBER,
	p_subinventory_code IN VARCHAR2,
	p_locator_id	    IN NUMBER,
	p_revision	    IN VARCHAR2,
	p_lot_number        IN VARCHAR2,
	p_serial_number	    IN VARCHAR2);

   PROCEDURE insert_Serial_Numbers(
	x_status 	    OUT NOCOPY VARCHAR2,
	p_fm_serial_number  IN VARCHAR2,
	p_to_serial_number  IN VARCHAR2,
	p_transaction_Temp_id IN NUMBER);

   PROCEDURE Validate_LPN_Status(x_result 	   OUT NOCOPY NUMBER,
				 x_msg_code 	   OUT NOCOPY VARCHAR2,
                                 p_trip_id 	   IN NUMBER,
                                 p_organization_id IN NUMBER,
                                 p_lpn_id 	   IN NUMBER);

    procedure wms_installed_status(x_status OUT NOCOPY VARCHAR2);

    procedure GET_SERIAL_STATUS_CODE(x_serial_status_id OUT NOCOPY NUMBER,
				     x_serial_status_code OUT NOCOPY VARCHAR2,
				     p_organization_id IN NUMBER,
				     p_inventory_item_id IN NUMBER);

    procedure UNASSIGN_DELIVERY_LINE(p_delivery_detail_id IN NUMBER,
				     x_return_status OUT NOCOPY VARCHAR2,
                                     p_delivery_id   IN NUMBER DEFAULT NULL,
                                     p_commit_flag   IN VARCHAR2
                                                     DEFAULT FND_API.G_TRUE );


    PROCEDURE update_wdd_loc_by_lpn
      (x_return_status OUT NOCOPY VARCHAR2,
       p_lpn_id NUMBER,
       p_subinventory_code VARCHAR2,
       p_locator_id NUMBER);

    PROCEDURE GET_LOADED_LPN_LOV(x_lpn_lov                 out NOCOPY t_genref,
				 p_organization_id         IN NUMBER,
				 p_dock_door_id            IN NUMBER,
				 p_lpn                     IN VARCHAR2);

    PROCEDURE GET_LOADED_DOCK_DOORS(x_dock_door_LOV   OUT NOCOPY t_genref,
				    p_organization_id in NUMBER,
				    p_dock_door       IN VARCHAR2);
    PROCEDURE lpn_unload(p_organization_id  IN NUMBER,
			 p_outermost_lpn_id IN NUMBER,
			 x_error_code       OUT NOCOPY NUMBER);



    /* Direct Shipping */

    -- LOV for Direct Ship LPN
    PROCEDURE get_directshiplpn_lov (
		x_lpn OUT NOCOPY t_genref
	,    	p_organization_id IN NUMBER
	,	p_lpn IN VARCHAR2);

    -- LOV for Order
	 PROCEDURE get_order_lov(
	        x_order_lov OUT NOCOPY t_genref
         ,	p_org_id IN NUMBER
         ,     	p_order IN VARCHAR2);

    -- LOV for Order line
/*	 PROCEDURE get_orderline_lov(
	      	x_orderline_lov OUT t_genref
         ,	p_org_id IN NUMBER
	 ,   	p_header_id IN NUMBER
         ,     	p_outermost_lpn_id  IN NUMBER
         ,     	p_order_line IN VARCHAR2);
*/
         PROCEDURE get_orderline_lov(
		   x_orderline_lov OUT NOCOPY T_GENREF
		,  p_org_id IN NUMBER
		,  p_header_id IN NUMBER
		,  p_order_line IN VARCHAR2
		,  p_outermost_lpn_id IN NUMBER
		,  p_cross_proj_flag IN VARCHAR2
		,  p_project_id  IN NUMBER
		,  p_task_id IN NUMBER
	);

    -- LOV for Freight Cost Type
    PROCEDURE Get_FreightCost_Type(
               	x_freight_type_code   out NOCOPY t_genref
         ,  	p_text                in  VARCHAR2);

	 -- LOV for Freight Term
    PROCEDURE Get_Freight_Term (
               	x_freight_terms   out NOCOPY t_genref
         , 	p_text            in  varchar2);

	 -- LOV for Document Set
    Procedure Get_document_set_lov(
               	x_report_set out NOCOPY t_genref
         , 	p_text       in  varchar2);

    -- LOV for Conversion Type
    Procedure GET_CONVERSION_TYPE(
               	x_conversion_type out NOCOPY t_genref
         , 	p_text            in  varchar2);

	 -- LOV for Currency
    Procedure GET_CURRENCY_CODE(
               x_currency   out NOCOPY t_genref
         ,	p_text       in  varchar2);

    -- LOV for Unload Truck LPN
    Procedure Get_unloadTruck_lpn_lov (
               x_lpn_lov                 out NOCOPY t_genref
         ,     p_organization_id         IN NUMBER
         ,     p_dock_door_id            IN NUMBER
         ,     p_lpn                     IN VARCHAR2);


    PROCEDURE Get_LPN_Contents (
               x_lpn_contents    OUT NOCOPY t_genref,
               p_lpn_id          IN  NUMBER,
               p_org_id          IN  NUMBER);

    /* Direct Sbipping */

    FUNCTION get_container_name(p_container_name IN VARCHAR2) RETURN
      VARCHAR2 ;

    --This procedure updates the serial_summary_entry
    --column in wms_lpn_contents for content LPN that
    --has serial @ SO issue items.  This procedure is
    --called after user has entered serial numbers at the
    --time of loading to dock.
    PROCEDURE update_lpn_contents
      (p_outermost_lpn_id IN NUMBER,
       p_org_id           IN NUMBER,
       x_return_status    OUT nocopy VARCHAR2,
       x_msg_count        OUT nocopy NUMBER,
       x_msg_data         OUT nocopy VARCHAR2);

/*
API Name:close_truck

Input parameters:
  P_dock_door_id : Shipping dock door id
  P_organization_id : organization_id
  p_shipping_mode : 'NORMAL'--Equivalent to normal LPN ship;
                    'DIRECT'--Equivalent to Direct LPN ship;
                     NULL   --will process both above;
Output parameters:
  x_return_status : 'S' --Sucess,
                    'W' --Warning
                    'E' --ERROR
  x_return_msg   : Returned message

  */


/*#
  * This procedure CLOSE_TRUCK is used to close the truck after LPNs have
  * been loaded on the truck at the dock door through an RFID device event.
  * @ param P_dock_door_id Shipping dock door id
  * @ paraminfo {@rep:required}
  * @ param P_organization_id organization_id
  * @ paraminfo {@rep:required}
  * @ param p_shipping_mode NORMAL(Normal LPN ship),DIRECT (Direct LPN ship),NULL(Both)
  * @ paraminfo {@rep:required}
  * @ param p_commit_flag commit the transaction or not
  * @ paraminfo {@rep:required}
  * @ param x_return_status Status of request. ( S = Success, E = Error, W = Warning)
  * @ paraminfo {@rep:required}
  * @ param  x_return_msg Returned message
  * @ paraminfo {@rep:required}
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Close truck after the Truck Load through RFID
  * @rep:businessevent close_truck
  */
procedure close_truck
  (P_dock_door_id    IN NUMBER,
   P_organization_id IN NUMBER,
   p_shipping_mode   IN VARCHAR2 DEFAULT NULL,
   p_commit_flag     IN VARCHAR2 DEFAULT fnd_api.g_true,
   x_return_status   OUT  NOCOPY VARCHAR2,
   x_return_msg      OUT  NOCOPY VARCHAR2);

END WMS_SHIPPING_TRANSACTION_PUB;

/
