--------------------------------------------------------
--  DDL for Package INV_SHIPPING_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SHIPPING_TRANSACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPWSHS.pls 120.4.12010000.1 2008/07/24 01:44:25 appldev ship $ */
--
	TYPE t_genref IS REF CURSOR;

G_PKG_NAME constant VARCHAR2(30) := 'INV_SHIPPING_TRANSACTION_PUB';

     FUNCTION GET_SHIPMETHOD_MEANING(p_ship_method_code  IN  VARCHAR2)
       RETURN  VARCHAR2;

     --Transportation enhancement for patchset I.
     --This procedure calls wsh_fte_comp_constraint_grp.validate_constraint
     --This procdure is called in the fieldExit for the ShipMethold field
     PROCEDURE validate_ship_method(p_shipmethod_code IN  VARCHAR2,
				    p_delivery_id     IN  NUMBER,
				    x_return_status   OUT nocopy VARCHAR2,
				    x_msg_count       OUT nocopy NUMBER,
				    x_msg_data        OUT nocopy varchar2);
     --

     PROCEDURE GET_VALID_DELIVERY(x_deliveryLOV OUT NOCOPY t_genref,
                                  p_delivery_name IN VARCHAR2,
				  p_organization_id IN NUMBER);

     PROCEDURE GET_VALID_DELIVERY_VIA_LPN(x_deliveryLOV OUT NOCOPY t_genref,
					  p_delivery_name IN VARCHAR2,
					  p_organization_id IN NUMBER,
					  p_lpn_id IN NUMBER);

     PROCEDURE GET_VALID_DELIVERY_LINE(x_deliveryLineLOV OUT NOCOPY t_genref,
                                       p_delivery_id IN NUMBER,
                                       p_inventory_item_id IN NUMBER);

     PROCEDURE GET_VALID_CARRIER(x_carrierLOV OUT NOCOPY t_genref,
                                 p_carrier_name IN VARCHAR2);

     PROCEDURE GET_SHIP_METHOD_LOV(x_shipMethodLOV OUT NOCOPY t_genref,
                                   p_organization_id  IN NUMBER,
                                   p_ship_method_name IN VARCHAR2);

     PROCEDURE GET_DELIVERY_INFO(x_delivery_info OUT NOCOPY t_genref,
                            p_delivery_id IN NUMBER);

     PROCEDURE INV_DELIVERY_LINE_INFO(x_deliveryLineInfo OUT NOCOPY t_genref,
                                      p_delivery_id IN NUMBER,
                                      p_inventory_item_id IN NUMBER,
				      p_serial_flag   IN VARCHAR2,
                                      x_return_Status OUT NOCOPY VARCHAR2);

     PROCEDURE SERIAL_AT_SALES_CHECK(x_result OUT NOCOPY NUMBER,
                                     x_item_name  OUT NOCOPY VARCHAR2,
                                     p_delivery_id IN NUMBER);

     PROCEDURE GET_DELIVERY_LINE_SERIAL_INFO(
                                             p_delivery_detail_id IN NUMBER,
                                             x_return_Status OUT NOCOPY VARCHAR2,
                                             x_inventory_item_id OUT NOCOPY NUMBER,
                                             x_transaction_Temp_id OUT NOCOPY NUMBER,
                                             x_subinventory_code OUT NOCOPY VARCHAR2,
                                             x_revision OUT NOCOPY VARCHAR2,
                                             x_locator_id OUT NOCOPY NUMBER,
                                             x_lot_number OUT NOCOPY VARCHAR2,
					     x_num_serial_record OUT NOCOPY NUMBER
                                             );

     PROCEDURE GET_TRIP_NAME(p_delivery_id IN NUMBER,
			     x_trip_name OUT NOCOPY VARCHAR2,
			     x_trip_id OUT NOCOPY NUMBER);

     PROCEDURE GET_TRIP_LOV(x_trip_lov OUT NOCOPY t_genref,
			    p_trip_name IN VARCHAR2);

     PROCEDURE GET_DOCK_DOOR( x_dock_door OUT NOCOPY t_genref,
			      p_trip_id   IN  NUMBER);

     PROCEDURE GET_ITEMS_IN_LPN(x_items OUT NOCOPY t_genref,
			        p_lpn_id IN NUMBER);

     --Returns an entire delivery to stock.  No partial shipment
     PROCEDURE INV_RETURN_TO_STOCK(p_delivery_id IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_data OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER
                                   );

     PROCEDURE INV_DELAY_SHIPMENT(p_delivery_id IN NUMBER,
                                 p_delivery_line_id IN NUMBER,
                                 p_shipped_quantity IN NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_data OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER);

     PROCEDURE INV_LINE_RETURN_TO_STOCK(p_delivery_id IN NUMBER,
                                        p_delivery_line_id IN NUMBER,
                                        p_shipped_quantity IN NUMBER,
                                        x_return_status OUT NOCOPY VARCHAR2,
                                        x_msg_data OUT NOCOPY VARCHAR2,
                                        x_msg_count OUT NOCOPY NUMBER,
                                        p_commit_flag IN VARCHAR2 DEFAULT FND_API.g_true,
					p_relieve_rsv IN VARCHAR2 DEFAULT 'Y');
  /**
   Bug No 3952081
   Overriding INV_LINE_RETURN_TO_STOCK to include duom attributes
  **/
     PROCEDURE INV_LINE_RETURN_TO_STOCK(p_delivery_id IN NUMBER,
                                        p_delivery_line_id IN NUMBER,
                                        p_shipped_quantity IN NUMBER,
                                        p_sec_shipped_quantity IN NUMBER,
                                        x_return_status OUT NOCOPY VARCHAR2,
                                        x_msg_data OUT NOCOPY VARCHAR2,
                                        x_msg_count OUT NOCOPY NUMBER,
                                        p_commit_flag IN VARCHAR2 DEFAULT FND_API.g_true,
					p_relieve_rsv IN VARCHAR2 DEFAULT 'Y');

     PROCEDURE INV_REPORT_MISSING_QTY(
                                      p_delivery_line_id IN NUMBER,
                                      p_missing_quantity IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_data OUT NOCOPY VARCHAR2,
                                      x_msg_count OUT NOCOPY NUMBER);

     PROCEDURE INV_REPORT_MISSING_QTY(
                                      p_delivery_line_id IN NUMBER,
                                      p_missing_quantity IN NUMBER,
                                      p_sec_missing_quantity IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_data OUT NOCOPY VARCHAR2,
                                      x_msg_count OUT NOCOPY NUMBER);

     PROCEDURE SUBMIT_DELIVERY_LINE(p_delivery_line_id IN NUMBER,
                                    p_quantity IN NUMBER,
                                    p_trackingNumber   IN VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_data OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER);

     PROCEDURE SUBMIT_DELIVERY_LINE(p_delivery_line_id IN NUMBER,
                                    p_quantity IN NUMBER,
                                    p_sec_quantity IN NUMBER,
                                    p_trackingNumber   IN VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_data OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER);
     FUNCTION GET_LINE_TRANSACTION_TYPE(
         				p_order_line_id        IN NUMBER,
					x_trx_source_type_id   OUT NOCOPY NUMBER,
					x_trx_Action_id	       OUT NOCOPY NUMBER,
         				x_return_status OUT NOCOPY VARCHAR2 ) return NUMBER;
     FUNCTION GET_DELIVERY_TRANSACTION_TYPE(
         				p_delivery_detail_id   IN NUMBER,
					x_trx_source_type_id   OUT NOCOPY NUMBER,
					x_trx_Action_id	       OUT NOCOPY NUMBER,
         				x_return_status OUT NOCOPY VARCHAR2 ) return NUMBER;
     PROCEDURE CHECK_DELIVERY_LOADED(
                                    p_delivery_id IN NUMBER,
                                    x_return_Status OUT NOCOPY VARCHAR2);

     PROCEDURE CHECK_DELIVERY_STATUS(
                                    p_delivery_id IN NUMBER,
                                    x_return_Status OUT NOCOPY VARCHAR2,
                                    x_error_msg     OUT NOCOPY VARCHAR2);
     PROCEDURE CHECK_SHIP_SET(
			     p_delivery_id IN NUMBER,
                             x_ship_set      OUT NOCOPY VARCHAR2,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2);

     PROCEDURE CHECK_COMPLETE_DELVIERY(
                             p_delivery_id IN NUMBER,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2);

     PROCEDURE UNASSIGN_DELIVERY_LINES(
                             p_delivery_id IN NUMBER,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2);

     PROCEDURE CHECK_ENTIRE_EZ_DELIVERY(
                             p_delivery_id IN NUMBER,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2);

     PROCEDURE CHECK_EZ_SHIP_DELIVERY(
	                     p_delivery_id IN NUMBER,
                             x_item_name     OUT NOCOPY VARCHAR2,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_code    OUT NOCOPY NUMBER,
                             x_error_msg     OUT NOCOPY VARCHAR2);

     PROCEDURE CONFIRM_DELIVERY (
                             p_ship_delivery     IN  VARCHAR2  DEFAULT NULL,
                             p_delivery_id       IN  NUMBER,
                             p_organization_id   IN  NUMBER,
                             p_delivery_name     IN  VARCHAR2,
                             p_carrier_id        IN  NUMBER,
                             p_ship_method_code  IN  VARCHAR2,
                             p_gross_weight      IN  NUMBER,
                             p_gross_weight_uom  IN  VARCHAR2,
                             p_bol               IN  VARCHAR2,
                             p_waybill           IN  VARCHAR2,
                             p_action_flag       IN  VARCHAR2,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_ret_code          OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER);

     PROCEDURE UNASSIGN_LINES_AND_CONFIRM (
                             p_delivery_id       IN  NUMBER,
                             p_organization_id   IN  NUMBER,
                             p_delivery_name     IN  VARCHAR2,
                             p_carrier_id        IN  NUMBER,
                             p_ship_method_code  IN  VARCHAR2,
                             p_gross_weight      IN  NUMBER,
                             p_gross_weight_uom  IN  VARCHAR2,
                             p_bol               IN  VARCHAR2,
                             p_waybill           IN  VARCHAR2,
                             p_action_flag       IN  VARCHAR2,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_data          OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER);

/** ssia 10/17/2002 Added the following method for serial shipping enhancement project
    The procedure split delivery line is used when user wants to ship short and does not
    report any missing quantity, i.e, when user wants to delay shipment or want to return
    some quantity to stock.
    In that case, we need to split the delivery line to two lines.
    The original delivery will be the one with the ship quantity, the second delivery
    is the remaining quantity
 **/
     PROCEDURE INV_SPLIT_DELIVERY_LINE(
        p_delivery_detail_id            IN NUMBER,
        p_ship_quantity                 IN NUMBER,
        p_requested_quantity            IN NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2,
        x_new_delivery_detail_id        OUT NOCOPY NUMBER,
        x_new_transaction_temp_id       OUT NOCOPY NUMBER);
 /**
  Bug No 3952081
  Overriding the procedure INV_SPLIT_DELIVERY_LINE to include
  DUOM attribute as input arguments
 **/
     PROCEDURE INV_SPLIT_DELIVERY_LINE(
        p_delivery_detail_id            IN NUMBER,
        p_ship_quantity                 IN NUMBER,
        p_requested_quantity            IN NUMBER,
        p_sec_ship_quantity                 IN NUMBER,
        p_sec_requested_quantity            IN NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2,
        x_new_delivery_detail_id        OUT NOCOPY NUMBER,
        x_new_transaction_temp_id       OUT NOCOPY NUMBER);

 /** ssia 10/17/2002 This is added for serial shipping enhancement project.
     The procedure is used to delete the serial numbers in msnt table on a
     particular delivery if user wants to ship short, have a new selected
     serial numbers. In that case, we just delete the serial numbers for that
     delivery and insert the new selected serial numbers.
     This procedures only handles the deletion. The insert serial number
     is handled by inv_trx_util_pub.insert_ser_trx
  **/

     PROCEDURE INV_PROCESS_SERIALS(
        p_transaction_temp_id   IN NUMBER,
        p_delivery_detail_id    IN NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);


     /** This procedure gets the enforce_ship_method parameter from shipping**/
     PROCEDURE get_enforce_ship(p_org_id        IN  NUMBER,
				x_enforce_ship  OUT NOCOPY VARCHAR2,
				x_return_status OUT nocopy VARCHAR2,
				x_msg_data      OUT nocopy VARCHAR,
				x_msg_count     OUT nocopy NUMBER);


     /** This procedure gets the enforce_ship_method parameter from shipping
 *       and Ship Method at trip level, if trip exists for this Delivery**/
     PROCEDURE get_shipmethod_details
                               (p_org_id                IN  NUMBER,
				p_delivery_id           IN  NUMBER,
				p_enforce_shipmethod    IN  OUT NOCOPY VARCHAR2,
				p_trip_id               IN  OUT NOCOPY NUMBER,
				x_trip_shipmethod_code      OUT NOCOPY VARCHAR2,
				x_trip_shipmethod_meaning   OUT NOCOPY VARCHAR2,
				x_return_status         OUT NOCOPY VARCHAR2,
				x_msg_data              OUT NOCOPY VARCHAR,
				x_msg_count             OUT NOCOPY NUMBER) ;
-- Start of fix for 4629955
     FUNCTION GET_FREIGHT_CODE(p_carrier_id  IN  NUMBER)
       RETURN  VARCHAR2;
-- End of fix for 4629955

/* The following API will check whether lot specific conversion defined
   Parameters and meanings:
   p_delivery_detail_id - IN parameter, delivery detail ID
   x_lot_number	- OUT parameter, lot_number associated with the delivery detail ID
   Return values and meanings :
   0  - No conversion defined
   1 - The secondary qty
*/

FUNCTION is_lotspec_conv(p_delivery_detail_id IN NUMBER, x_lot_number OUT NOCOPY VARCHAR2) RETURN NUMBER;

END INV_SHIPPING_TRANSACTION_PUB;

/
