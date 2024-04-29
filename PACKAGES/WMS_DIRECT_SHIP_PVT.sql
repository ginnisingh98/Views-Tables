--------------------------------------------------------
--  DDL for Package WMS_DIRECT_SHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DIRECT_SHIP_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSDSPVS.pls 120.2.12010000.1 2008/07/28 18:33:43 appldev ship $ */

        -- standard global constants
        G_PKG_NAME CONSTANT VARCHAR2(30)                := 'WMS_DIRECT_SHIP_PVT';
        p_message_type  CONSTANT VARCHAR2(1)            := 'E';


TYPE t_genref IS REF CURSOR;

PROCEDURE DEBUG(p_message       IN VARCHAR2,
                p_module        IN VARCHAR2 default 'abc',
                p_level         IN VARCHAR2 DEFAULT 9);

PROCEDURE GET_TRIPSTOP_INFO( x_tripstop_info OUT NOCOPY t_genref
                               ,p_trip_id        IN NUMBER
                               ,p_org_id         IN NUMBER);

PROCEDURE GET_DELIVERY_INFO(x_delivery_info OUT NOCOPY t_genref,
                              p_delivery_id IN NUMBER,
			      p_org_id IN NUMBER); /*Bug 2767767: Passing the org id to get the correct value of Enforce Ship Method*/

FUNCTION GET_DELIVERY_LPN(p_delivery_id NUMBER) RETURN VARCHAR2;

FUNCTION GET_SHIPMETHOD_MEANING(p_ship_method_code  IN  VARCHAR2) RETURN  VARCHAR2;

FUNCTION GET_FOBLOC_CODE_MEANING(p_fob_code  IN  VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_FOB_LOCATION(p_fob_location_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_FREIGHT_TERM(p_freight_term_code VARCHAR2)RETURN VARCHAR2;

FUNCTION GET_BOL(p_delivery_id  NUMBER)RETURN NUMBER;

FUNCTION get_enforce_ship RETURN VARCHAR2;


PROCEDURE CHECK_DELIVERY(x_return_status        OUT NOCOPY VARCHAR2
                        ,x_msg_count            OUT NOCOPY NUMBER
                        ,x_msg_data             OUT NOCOPY VARCHAR2
                        ,x_error_code                   OUT NOCOPY NUMBER
                        ,p_delivery_id                  IN  NUMBER
                        ,p_org_id                               IN  NUMBER
                        ,p_dock_door_id             IN  NUMBER
                         );

PROCEDURE UPDATE_DELIVERY(
              x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,p_delivery_id            IN  NUMBER
             ,p_net_weight                IN  NUMBER
             ,p_gross_weight           IN  NUMBER
             ,p_wt_uom_code            IN  VARCHAR2
             ,p_waybill                   IN  VARCHAR2
             ,p_ship_method_code     IN  VARCHAR2
             ,p_fob_code                  IN  VARCHAR2
             ,p_fob_location_id     IN  NUMBER
             ,p_freight_term_code    IN  VARCHAR2
             ,p_freight_term_name    IN  VARCHAR2
             ,p_intmed_shipto_loc_id IN  NUMBER
                         );

PROCEDURE MISSING_ITEM_CUR( x_missing_item_cur     OUT NOCOPY t_genref
                           ,p_delivery_id          IN  NUMBER
                           ,p_dock_door_id         IN  NUMBER
                           ,p_organization_id      IN  NUMBER
                           );


-- Call this API from Continue button of Delivery Info page. If delivery_id
-- is passed then it will confirm the delivery, if LPN id is passed, then it will
-- confirm the delivery belonging to a LPN, if org_id and dock door id is passed and
-- delivery id/ lpn id is kept null then all deliveries loaded on the dock will be
-- Shipconfirmed

PROCEDURE SHIP_CONFIRM(
              x_return_status         OUT  NOCOPY VARCHAR2
              ,x_msg_count            OUT  NOCOPY NUMBER
              ,x_msg_data               OUT  NOCOPY VARCHAR2
              ,x_missing_item_cur     OUT  NOCOPY t_genref
              ,x_error_code             OUT  NOCOPY NUMBER
              ,p_delivery_id            IN  NUMBER
              ,p_net_weight             IN  NUMBER   DEFAULT NULL
              ,p_gross_weight           IN  NUMBER   DEFAULT NULL
              ,p_wt_uom_code            IN  VARCHAR2 DEFAULT NULL
              ,p_waybill                   IN  VARCHAR2   DEFAULT NULL
              ,p_ship_method_code     IN  VARCHAR2 DEFAULT NULL
              ,p_fob_code                  IN  VARCHAR2 DEFAULT NULL
              ,p_fob_location_id             IN  NUMBER   DEFAULT NULL
              ,p_freight_term_code    IN  VARCHAR2 DEFAULT NULL
              ,p_freight_term_name    IN  VARCHAR2 DEFAULT NULL
              ,p_intmed_shipto_loc_id IN  NUMBER   DEFAULT NULL
              ,p_org_id                    IN  NUMBER   DEFAULT NULL
              ,p_dock_door_id           IN  NUMBER   DEFAULT NULL
                         );

PROCEDURE CONFIRM_ALL_DELIVERIES(
              x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data                  OUT  NOCOPY VARCHAR2
             ,x_missing_item_cur     OUT  NOCOPY t_genref
             ,x_error_code                OUT  NOCOPY NUMBER
             ,p_delivery_id            IN  NUMBER
             ,p_net_weight                IN  NUMBER
             ,p_gross_weight           IN  NUMBER
             ,p_wt_uom_code            IN  VARCHAR2
             ,p_waybill                   IN  VARCHAR2
             ,p_ship_method_code     IN  VARCHAR2
             ,p_fob_code                  IN  VARCHAR2
             ,p_fob_location_id     IN  NUMBER
             ,p_freight_term_code    IN  VARCHAR2
             ,p_freight_term_name    IN  VARCHAR2
             ,p_intmed_shipto_loc_id IN  NUMBER
             ,p_org_id                    IN  NUMBER
             ,p_dock_door_id           IN  NUMBER
                              );

PROCEDURE CREATE_TRIP(
             x_return_status    OUT NOCOPY VARCHAR2
            ,p_organization_id  IN  NUMBER
            ,p_dock_door_id     IN  NUMBER
	    ,p_delivery_id      IN NUMBER /*bug 2741857 */
            ,p_direct_ship_flag IN  VARCHAR2 DEFAULT 'N'
            );


PROCEDURE UPDATE_TRIPSTOP(
              x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,p_trip_id              IN  NUMBER
             ,p_vehicle_item_id      IN  NUMBER
             ,p_vehicle_num_prefix   IN  VARCHAR2
             ,p_vehicle_num          IN  VARCHAR2
             ,p_seal_code            IN  VARCHAR2
             ,p_org_id               IN  NUMBER   DEFAULT NULL
             ,p_dock_door_id         IN  NUMBER   DEFAULT NULL
             ,p_ship_method_code     IN VARCHAR2  DEFAULT NULL
                );


PROCEDURE PRINT_SHIPPING_DOCUMENT(
                  x_return_status        OUT NOCOPY VARCHAR2
                  ,x_msg_count            OUT NOCOPY NUMBER
                  ,x_msg_data             OUT NOCOPY VARCHAR2
                  ,p_trip_id              IN  NUMBER
                  ,p_vehicle_item_id      IN  NUMBER
                  ,p_vehicle_num_prefix   IN  VARCHAR2
                  ,p_vehicle_num          IN  VARCHAR2
                  ,p_seal_code            IN  VARCHAR2
                  ,p_document_set_id      IN  NUMBER
                  ,p_org_id               IN  NUMBER DEFAULT NULL
                  ,p_dock_door_id         IN  NUMBER DEFAULT NULL
                  ,p_ship_method_code     IN  VARCHAR2 DEFAULT NULL
                     );

PROCEDURE CLOSE_TRIP(
              x_return_status        OUT NOCOPY VARCHAR2
              ,x_msg_count            OUT NOCOPY NUMBER
              ,x_msg_data             OUT NOCOPY VARCHAR2
              ,p_trip_id              IN  NUMBER
              ,p_vehicle_item_id      IN  NUMBER
              ,p_vehicle_num_prefix   IN  VARCHAR2
              ,p_vehicle_num          IN  VARCHAR2
              ,p_seal_code            IN  VARCHAR2
              ,p_document_set_id      IN  NUMBER
              ,p_org_id               IN  NUMBER DEFAULT NULL
              ,p_dock_door_id         IN  NUMBER DEFAULT NULL
              ,p_ship_method_code     IN VARCHAR2 DEFAULT NULL
                 );

-- API Name         : UNLOAD_TRUCK
-- Type             : Procedure
-- Function         : This procedure does the following:
--                    1.Change LPN context to "Resides in Inventory"
--                    2.Unpack the LPN in Shipping
--                    3.Remove inventory details from Shipping (Sub, Loc, Qty).
--                    4.Remove the Reservation records
--                    5.Reset the serial_number_control_code,current_status
--                     ->if serial control code is "At SO Issue", reset current status to "Defined but not used"
--                     ->if serial control code is "Predefined" or "At Receipt" reset status to "resides in stores"
--                     ->Reset Group Mark Id
-- Input Parameters :
--   p_org_id             Organization Id
--   p_outermost_lpn_id   Outermost LPN Id
-- Output Parameters    :
--   x_return_status      Standard Output Parameter
--   x_msg_count          Standard Output Parameter
--   x_msg_data           Standard Output Parameter

PROCEDURE UNLOAD_TRUCK ( x_return_status     OUT NOCOPY VARCHAR2
                        ,x_msg_count         OUT NOCOPY NUMBER
                        ,x_msg_data          OUT NOCOPY VARCHAR2
                        ,p_org_id             IN  NUMBER
                        ,p_outermost_lpn_id  IN  NUMBER
			,p_relieve_rsv       IN  VARCHAR2 DEFAULT 'Y');

PROCEDURE CLEANUP_TEMP_RECS (x_return_status     OUT NOCOPY VARCHAR2
                            ,x_msg_count         OUT NOCOPY NUMBER
                            ,x_msg_data          OUT NOCOPY VARCHAR2
                            ,p_org_id             IN  NUMBER
                            ,p_outermost_lpn_id  IN  NUMBER
                            ,p_trip_id           IN  NUMBER
                            ,p_dock_door_id      IN  NUMBER DEFAULT NULL);


PROCEDURE get_global_values(x_userid        OUT NOCOPY number,
                            x_logonid       OUT NOCOPY number,
                            x_last_upd_date OUT NOCOPY date,
                            x_current_date  OUT NOCOPY date );

PROCEDURE validate_status_lpn_contents(x_return_status  OUT NOCOPY VARCHAR2
                                                  ,x_msg_count    OUT NOCOPY NUMBER
                                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                                  ,p_lpn_id        IN NUMBER
                                                  ,p_org_id        IN NUMBER
                                                  );

PROCEDURE update_freight_cost(x_return_status OUT NOCOPY VARCHAR2
                              ,x_msg_count OUT NOCOPY NUMBER
                              ,x_msg_data  OUT NOCOPY VARCHAR2
                              ,p_lpn_id IN NUMBER
                              );

procedure create_resv(x_return_status OUT NOCOPY VARCHAR2
                                        ,x_msg_count OUT NOCOPY NUMBER
                                        ,x_msg_data OUT NOCOPY VARCHAR2
                                        ,p_group_id IN NUMBER
                                        ,p_org_id IN NUMBER
                                        );

PROCEDURE load_truck (x_return_status  OUT NOCOPY VARCHAR2
                                             ,x_msg_data      OUT NOCOPY VARCHAR2
                                             ,x_msg_count     OUT NOCOPY NUMBER
                                             ,p_group_id      IN NUMBER
                                             ,P_ORG_ID        IN NUMBER
                                             ,p_dock_door_id  IN NUMBER
                                             );

PROCEDURE close_truck (x_return_status OUT NOCOPY VARCHAR2
                                         ,x_msg_data OUT  NOCOPY VARCHAR2
                                         ,x_msg_count OUT  NOCOPY NUMBER
                                         ,x_error_code OUT NOCOPY NUMBER
                                         ,x_missing_item_cur  OUT NOCOPY t_genref
                                         ,p_dock_door_id IN  NUMBER
                                         ,p_group_id IN NUMBER
                                         ,p_org_id   IN NUMBER
                                         );


PROCEDURE EXPLODE_DELIVERY_DETAILS(
                 x_return_status                OUT NOCOPY VARCHAR2
                ,x_msg_count                    OUT NOCOPY NUMBER
                ,X_MSG_DATA                     OUT NOCOPY VARCHAR2
		--Bug No 3390432
		-- New Out Parameter
		,x_transaction_temp_id          OUT NOCOPY NUMBER
                ,p_organization_id               IN  NUMBER
                ,p_lpn_id                        IN  NUMBER
                ,p_serial_number_control_code    IN  NUMBER
                ,p_delivery_detail_id            IN  NUMBER
                ,p_quantity                      IN  NUMBER
                ,p_transaction_temp_id           IN  NUMBER   DEFAULT NULL
                ,p_reservation_id                IN  NUMBER   DEFAULT NULL
                ,p_last_action                   IN VARCHAR2 DEFAULT 'U');

PROCEDURE STAGE_LPNS(
                    x_return_status   OUT NOCOPY VARCHAR2
                   ,x_msg_count       OUT NOCOPY NUMBER
                   ,x_msg_data        OUT NOCOPY VARCHAR2
                   ,p_group_id        IN NUMBER
                   ,p_organization_id IN NUMBER
                   ,p_dock_door_id    IN NUMBER
                 ) ;

PROCEDURE GET_LPN_AVAILABLE_QUANTITY(
                                     x_return_status            OUT NOCOPY VARCHAR2,
                                     x_msg_count                OUT NOCOPY NUMBER,
                                     x_msg_data                 OUT NOCOPY VARCHAR2,
                                     p_organization_id          IN  NUMBER,
                                     p_lpn_id                   IN  NUMBER,
                                     p_inventory_item_id        IN  NUMBER,
                                     p_revision                 IN  VARCHAR2,
                                     p_line_id                  IN  NUMBER,
                                     p_header_id                IN  NUMBER,
                                     x_qoh                      OUT NOCOPY NUMBER,
                                     x_att                      OUT NOCOPY NUMBER);

PROCEDURE create_update_containers(
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,
--  x_container_wdds   OUT nocopy    wsh_util_core.id_tab_type,
  p_org_id          IN  NUMBER,
  p_outermost_lpn_id          IN  NUMBER,
  p_delivery_id     IN NUMBER DEFAULT null);

PROCEDURE UPDATE_SHIPPED_QUANTITY(
         x_return_status OUT NOCOPY VARCHAR2
        ,x_msg_count     OUT NOCOPY NUMBER
        ,x_msg_data      OUT NOCOPY VARCHAR2
        ,p_delivery_id   IN NUMBER
        ,p_org_id        IN NUMBER DEFAULT NULL
        );
PROCEDURE Container_Nesting(
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_count                   OUT NOCOPY VARCHAR2,
  x_msg_data                    OUT NOCOPY VARCHAR2,
  p_organization_id             IN  NUMBER,
  p_outermost_lpn_id            IN  NUMBER,
  p_action_code                 IN  VARCHAR2 DEFAULT 'PACK') ;

procedure check_order_line_split(
                             x_return_status OUT NOCOPY VARCHAR2
                            ,x_msg_count     OUT NOCOPY NUMBER
                            ,x_msg_data      OUT NOCOPY VARCHAR2
                            ,x_error_code    OUT NOCOPY NUMBER
                            ,p_delivery_id   IN NUMBER
                                                );
procedure CHECK_MISSING_ITEM_CUR(p_delivery_id      IN   NUMBER
                                 ,p_dock_door_id    IN   NUMBER
                                 ,p_organization_id IN  number
                                 ,x_return_Status   OUT NOCOPY VARCHAR2
                                 ,x_missing_count   OUT NOCOPY NUMBER
                              );
PROCEDURE chk_del_for_direct_ship(x_return_status OUT NOCOPY VARCHAR2
                                 ,x_msg_count    OUT NOCOPY NUMBER
                                 ,x_msg_data     OUT NOCOPY VARCHAR2
                                 ,p_delivery_id   IN NUMBER
                                  );

/* procedures added for Patchset I*/

PROCEDURE PROCESS_LPN(p_lpn_id IN NUMBER,
                        p_org_id IN NUMBER,
                        p_dock_door_id NUMBER,
                        x_remaining_qty OUT NOCOPY NUMBER,
                        x_num_line_processed OUT NOCOPY NUMBER,
                        x_project_id OUT NOCOPY NUMBER,
                        x_task_id OUT NOCOPY NUMBER,
                        x_cross_project_allowed OUT NOCOPY VARCHAR2,
                        x_cross_unit_allowed OUT NOCOPY VARCHAR2,
                        x_group_by_customer_flag OUT NOCOPY VARCHAR2,
                        x_group_by_fob_flag  OUT NOCOPY VARCHAR2,
                        x_group_by_freight_terms_flag OUT NOCOPY VARCHAR2,
                        x_group_by_intmed_ship_flag OUT NOCOPY VARCHAR2,
                        x_group_by_ship_method_flag OUT NOCOPY VARCHAR2,
                        x_group_by_ship_to_loc_value OUT NOCOPY VARCHAR2,
                        x_group_by_ship_from_loc_value OUT NOCOPY VARCHAR2,
                        x_group_by_customer_value OUT NOCOPY VARCHAR2,
                        x_group_by_fob_value OUT NOCOPY VARCHAR2,
                        x_group_by_freight_terms_value OUT NOCOPY VARCHAR2,
                        x_group_by_intmed_value OUT NOCOPY VARCHAR2,
                        x_group_by_ship_method_value OUT NOCOPY VARCHAR2,
			x_ct_wt_enabled        OUT NOCOPY NUMBER,
                        x_return_status        OUT NOCOPY VARCHAR2,
                        x_msg_count            OUT NOCOPY NUMBER,
                        x_msg_data             OUT NOCOPY VARCHAR2
                        );

/* This procedure creates reservations for a line if it is not there and
   inserts processed line record into WDS.
*/
PROCEDURE Process_Line(p_lpn_id IN NUMBER,
                        p_org_id IN NUMBER,
                        p_dock_door_id NUMBER,
                        p_order_header_id IN NUMBER,
                        p_order_line_id IN NUMBER,
                        p_inventory_item_id IN NUMBER,
                        p_revision IN VARCHAR2,
                        p_end_item_unit_number IN VARCHAR2,
                        p_ordered_quantity IN NUMBER,
                        p_processed_quantity IN NUMBER,
                        p_date_requested IN DATE,
                        p_primary_uom_code IN VARCHAR2,
                        x_remaining_quantity OUT NOCOPY NUMBER,
                        x_return_status        OUT NOCOPY VARCHAR2,
                        x_msg_count            OUT NOCOPY NUMBER,
                        x_msg_data             OUT NOCOPY VARCHAR2
                        ) ;

/*
  This procedure perform the following processing for a lpn.
  1. Update staged flag of all reservations for all the lines packed into LPN.
  2. Stage LPN
  3. Update Freight Cost for LPN
 */
PROCEDURE Load_LPN (x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count OUT NOCOPY NUMBER,
                    x_msg_data OUT NOCOPY VARCHAR2,
                    p_lpn_id IN NUMBER,
                    p_org_id IN NUMBER,
                    p_dock_door_id IN NUMBER
                    );
/*
  This procedure distributes the un-used quantity in the lpn among all the loaded lines.
  First it checks if for a lpn_content record a exact matching reservation is found the
  update the existing reservation else create new reservation.
 */

PROCEDURE Perform_Overship_Distribution (p_lpn_id IN NUMBER,
                                         p_org_id IN NUMBER,
                                         p_dock_door_id IN NUMBER,
                                         x_return_status OUT NOCOPY VARCHAR2,
                                         x_msg_count OUT NOCOPY NUMBER,
                                         x_msg_data OUT NOCOPY VARCHAR2
                                       ) ;
FUNCTION Validate_Del_Grp_Rules(p_line_processed IN NUMBER,
                                p_header_id IN NUMBER,
                                p_line_id IN NUMBER) RETURN BOOLEAN ;


/*This procedure checks if any holds are applied on a particular order line being shipped and
  also applies the credit check hold for a customer of a particular line
 */
PROCEDURE Check_Holds(p_order_header_id IN NUMBER,
                      p_order_line_id IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data  OUT NOCOPY VARCHAR2
                      );
/* This procedure cleanup all the temp data for a backordered delivery for this lpn */
PROCEDURE cleanup_orphan_rec(
                             p_org_id IN NUMBER
                          );
/*
  This method checks that there should be no record for this lpn in wstt (delivery)
  having direct_ship_flag N or loaded by some other method than direct ship.
 */

FUNCTION Validate_Del_For_DS(p_lpn_id IN NUMBER,
                             p_org_id IN NUMBER,
                             p_dock_door_id IN NUMBER,
                             p_header_id IN NUMBER,
                             p_line_id IN NUMBER
                             )RETURN BOOLEAN;

/*
 This function finds out if there is any record in lpn contents having
 available quantity >0 and end_item_unit_number=p_end_unit_number
 */
FUNCTION Validate_End_Unit_Num(p_item_id IN NUMBER,
                                p_end_unit_number IN VARCHAR2
                                )RETURN BOOLEAN ;

/* This function finds out that the item in g_lpn_contents_tab at index is having available quantity
   and its end_item_unit_number matches p_end_unit_number.
*/
FUNCTION Validate_End_Unit_Num_At( p_index IN NUMBER,
                                p_end_unit_number IN VARCHAR2
                               ) RETURN BOOLEAN ;
END; -- WMS_DIRECT_SHIP_PVT

/
