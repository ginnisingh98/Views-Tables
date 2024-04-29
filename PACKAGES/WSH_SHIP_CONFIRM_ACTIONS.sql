--------------------------------------------------------
--  DDL for Package WSH_SHIP_CONFIRM_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIP_CONFIRM_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHDDSHS.pls 120.2.12010000.2 2009/03/23 10:54:18 gbhargav ship $ */

--<TPA_PUBLIC_NAME=WSH_TPA_DELIVERY_DETAILS_PKG>
--<TPA_PUBLIC_FILE_NAME=WSHTPDD>

TYPE t_InterfaceRecord is RECORD (
     shipping_quantity oe_order_lines_all.shipping_quantity%TYPE,
     shipping_quantity_UOM    oe_order_lines_all.shipping_quantity_uom%TYPE,
     actual_shipment_date     oe_order_lines_all.actual_shipment_date%TYPE,
     over_ship_reason_code    oe_order_lines_all.over_ship_reason_code%TYPE);
TYPE process_order_table is table of t_InterfaceRecord INDEX BY BINARY_INTEGER;


--
--Procedure:        Ship_Confirm_A_Trip_Stop
--Parameters:       p_stop_id,
--                  x_return_status
--Description:      This procedure will ship confirm the whole trip stop.
--                  It submits the inventory interface program -- inv_interface
PROCEDURE Ship_Confirm_A_Trip_Stop
		(p_stop_id number,
		 x_return_status out NOCOPY  varchar2);

--
--Function:              More_Shipment_Exist
--Parameters:            p_delivery_id,
--                       p_source_line_id
--Description:           This function returns a boolean value to indicate
--                       if there is more shipment exist for the source line
--                       that is being shipped within the delivery

FUNCTION More_Shipment_Exist(p_delivery_id number,p_source_code varchar2, p_source_line_id number) RETURN BOOLEAN;

--
--Function:              Get_Line_Expected_Qty
--Parameters:            p_source_line_id
--                       p_batch_id
--Description:           This function returns expected shipped quantity
--                       for a source line besides the shipped quantity in
--                       the current stop

FUNCTION Get_Line_Expected_Qty(p_source_line_id number, p_batch_id number) RETURN NUMBER ;


--R12:MOAC made get_new_tolerance internal to this package


--
--Function:              Part_of_PTO
--Parameters:            p_source_line_id
--Description:           This function returns a boolean value to
--                       indicate if the order line is part of a PTO

FUNCTION Part_Of_PTO(p_source_code varchar2,p_source_line_id number) RETURN BOOLEAN;
FUNCTION Top_Of_Model(p_source_code varchar2,p_source_line_id number) RETURN NUMBER;

/* OE_interface can be called from the ship confirm program or
   it can be called from a concurrent program by user in the case of
	 oe interface failed and it needs to be re-run manually by user */
	 --
	 --Procedure:             oe_interface
	 --                       errbuf
	 --                       retcode
	 --                       p_stop_id
	 --Description:           It loops through all deliveries at the stop and
	 --                       call interface_header_to_OM to interface all
	 --                       deliveries to Order Management

PROCEDURE oe_interface(errbuf OUT NOCOPY  VARCHAR2, retcode OUT NOCOPY  VARCHAR2, p_stop_id IN number);


-- start bug 1578251: move oe_interface logic to oe_interface_trip_stop and set completion_status
--
--Procedure:  oe_interface_trip_stop
--            p_batch_id
--            x_completion_status
--            x_num_stop_removed, number of stops removed
--             from the batch.
--            p_stop_tab the table of stop_ids which were in
--            the patch before calling this API
--            x_stop_tab  This table will be populated as follow.  If the call
--            to Interface_Stop_To_OM returns warning or error, then if there
--            some stops that are processed successfully, then these stops will
--            be populated in x_stop_tab, if non of the stops are successful
--            then x_stop_tab will be populated with p_stop_tab
--
--
--Description:           It loops through all deliveries at the stop and
--            call interface_header_to_OM to interface all
--            deliveries to Order Management

PROCEDURE oe_interface_trip_stop(p_batch_id           IN  number,
                             p_stop_tab IN wsh_util_core.id_tab_type,
                             x_stop_tab OUT NOCOPY wsh_util_core.id_tab_type,
                             x_num_stops_removed OUT NOCOPY NUMBER,
                             x_completion_status OUT NOCOPY  VARCHAR2);
-- end bug 1578251: move oe_interface logic to oe_interface_trip_stop and set completion_status


-- start bug 1578251: Interface_ALL to batch process the stops
--
--Procedure:        Interface_ALL
--Parameters:       errbuf
--                  retcode
--                  p_mode ('INV', 'OM DSNO', 'INV OM DSNO', etc.)
--                  p_stop_id
--                  p_delivery_id (supersedes p_stop_id)
--                  p_log_level
--Description:      It loops through all stops that need interfacing
--                  It calls interfaces selected by p_mode
procedure interface_ALL(errbuf        OUT NOCOPY  VARCHAR2,
                        retcode       OUT NOCOPY  VARCHAR2,
                        p_mode        IN  VARCHAR2 DEFAULT 'ALL',
                        p_stop_id     IN  NUMBER   DEFAULT NULL,
                        p_delivery_id IN  NUMBER   DEFAULT NULL,
                        p_log_level   IN  NUMBER   DEFAULT 0,
                        p_batch_id IN NUMBER DEFAULT NULL,
                        p_trip_type IN VARCHAR2 DEFAULT NULL,
                        p_organization_id IN NUMBER DEFAULT NULL,
                        p_stops_per_batch IN NUMBER DEFAULT NULL);

-- end bug 1578251: Interface_ALL to batch process the stops


--
--Procedure:        Inv_Interface
--Parameters:       errbuf
--                  retcode
--                  p_stop_id
--Description:      It is a wrapper for Interface_ALL (bug 1578251)
-- This procedure is maintained for backward compatibility
procedure inv_interface(errbuf    out NOCOPY  varchar2,
                        retcode   out NOCOPY  varchar2,
                        p_stop_id in  number);


-- begin bug 1578251: create new procedure Inv_Interface_Trip_stop
--
--Procedure:        Inv_Interface_Trip_Stop
--Parameters:       p_batch_id
--                  x_completion_status
--Description:      It loops through all deliveries at the stop
--                  and handles INV Interface.
procedure inv_interface_trip_stop(p_batch_id           IN  NUMBER,
                                  x_completion_status OUT NOCOPY  VARCHAR2);
-- end bug 1578251: create new procedure inv_Interface_Trip_Stop


procedure process_inv_online  ( p_batch_id in number ,
				p_transaction_header_id  in number  ,
			        x_return_status         out NOCOPY  varchar2 ) ;

procedure update_interfaced_details ( p_batch_id in number  , x_return_status out NOCOPY  varchar2  ) ;

-- Name        	Get_Account
-- Purpose     	This function will return default account for interface to
-- 					inventory when ship confirm
-- Arguments   	p_delivery_detail_id
--             	x_return_status  result from execution of this function
-- Assumption  	IF account not found, NULL will be returned
-- TPA selector   WSH_TPA_SELECTOR_PKG.DeliveryDetailTP

FUNCTION Get_Account(
  p_delivery_detail_id           IN     NUMBER
, x_return_status                   OUT NOCOPY  VARCHAR2
) RETURN NUMBER;
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DeliveryDetailTP>


FUNCTION ALL_INTERFACED ( p_batch_id in number ) RETURN BOOLEAN  ;
FUNCTION INV_INTERFACED ( p_batch_id in number ) RETURN BOOLEAN  ;
FUNCTION OM_INTERFACED  ( p_batch_id in number ) RETURN BOOLEAN  ;

-- bug 1651076
ont_source_code  varchar2(40) := NULL;

--Added to fix bug 1678453
l_currentDate DATE;


--HVOP:INV heali
    --Recode of table for mtl_transactions_interface
    TYPE  Mtl_txn_if_rec_type IS RECORD(
         source_code			WSH_BULK_TYPES_GRP.tbl_v40,
         source_header_id               WSH_BULK_TYPES_GRP.tbl_num,
         source_line_id			WSH_BULK_TYPES_GRP.tbl_num,
         inventory_item_id              WSH_BULK_TYPES_GRP.tbl_num,
         subinventory                   WSH_BULK_TYPES_GRP.tbl_v40,
         trx_quantity           	WSH_BULK_TYPES_GRP.tbl_num,
         trx_date               	WSH_BULK_TYPES_GRP.tbl_date,
         organization_id              	WSH_BULK_TYPES_GRP.tbl_num,
         trx_source_id          	WSH_BULK_TYPES_GRP.tbl_num,
         trx_source_type_id     	WSH_BULK_TYPES_GRP.tbl_num,
         trx_action_id          	WSH_BULK_TYPES_GRP.tbl_num,
         trx_type_id            	WSH_BULK_TYPES_GRP.tbl_num,
         distribution_account_id        WSH_BULK_TYPES_GRP.tbl_num,
         trx_reference          	WSH_BULK_TYPES_GRP.tbl_v240,
         trx_header_id          	WSH_BULK_TYPES_GRP.tbl_num,
         trx_source_line_id             WSH_BULK_TYPES_GRP.tbl_num,
         trx_source_delivery_id         WSH_BULK_TYPES_GRP.tbl_num,
         revision              		WSH_BULK_TYPES_GRP.tbl_v3,
         locator_id              	WSH_BULK_TYPES_GRP.tbl_num,
         picking_line_id              	WSH_BULK_TYPES_GRP.tbl_num,
         transfer_subinventory          WSH_BULK_TYPES_GRP.tbl_v10,
         transfer_organization          WSH_BULK_TYPES_GRP.tbl_num,
         ship_to_location_id            WSH_BULK_TYPES_GRP.tbl_num,
         requisition_line_id            WSH_BULK_TYPES_GRP.tbl_num,
         requisition_distribution_id    WSH_BULK_TYPES_GRP.tbl_num,
         trx_uom              		WSH_BULK_TYPES_GRP.tbl_v3,
         trx_interface_id               WSH_BULK_TYPES_GRP.tbl_num,
         shipment_number                WSH_BULK_TYPES_GRP.tbl_v30,
         expected_arrival_date          WSH_BULK_TYPES_GRP.tbl_date,
         encumbrance_account            WSH_BULK_TYPES_GRP.tbl_num,
         encumbrance_amount             WSH_BULK_TYPES_GRP.tbl_num,
         movement_id              	WSH_BULK_TYPES_GRP.tbl_num,
         freight_code              	WSH_BULK_TYPES_GRP.tbl_v30,
         waybill_airbill              	WSH_BULK_TYPES_GRP.tbl_v30,
	 content_lpn_id			WSH_BULK_TYPES_GRP.tbl_num,
         requested_quantity		WSH_BULK_TYPES_GRP.tbl_num,
         inv_interfaced_flag		WSH_BULK_TYPES_GRP.tbl_v1,
         ship_method_code		WSH_BULK_TYPES_GRP.tbl_v30,
         cycle_count_quantity		WSH_BULK_TYPES_GRP.tbl_num,
         src_requested_quantity_uom	WSH_BULK_TYPES_GRP.tbl_v3,
         transaction_temp_id		WSH_BULK_TYPES_GRP.tbl_num,
-- HW OPMCONV.Use length of 80 for lot_number
         lot_number			WSH_BULK_TYPES_GRP.tbl_v80,
         serial_number			WSH_BULK_TYPES_GRP.tbl_v30,
         to_serial_number		WSH_BULK_TYPES_GRP.tbl_v30,
         trip_id			WSH_BULK_TYPES_GRP.tbl_num,
-- HW OPMCONV. No need for sublot anymore
--       sublot_number			WSH_BULK_TYPES_GRP.tbl_v32,
         ship_tolerance_above		WSH_BULK_TYPES_GRP.tbl_num,
         ship_tolerance_below		WSH_BULK_TYPES_GRP.tbl_num,
         src_requested_quantity		WSH_BULK_TYPES_GRP.tbl_num,
         org_id				WSH_BULK_TYPES_GRP.tbl_num,
-- OPM 3064890 added qty2
         trx_quantity2           	WSH_BULK_TYPES_GRP.tbl_num,
         error_flag			WSH_BULK_TYPES_GRP.tbl_v1,
-- HW OPMCONV. New variables
         GRADE_CODE                     WSH_BULK_TYPES_GRP.tbl_v150,
         SECONDARY_TRX_UOM              WSH_BULK_TYPES_GRP.tbl_v3,
--Added for Bug 4538005
          ship_from_location_id		WSH_BULK_TYPES_GRP.tbl_num,
	  ship_to_site_use_id		WSH_BULK_TYPES_GRP.tbl_num
	 );




     --Roecode of table for mtl_serial_numbers_interface
     -- Attributes Added For Bug 3628620
     TYPE  Mtl_ser_txn_if_rec_type IS RECORD(
         source_code			WSH_BULK_TYPES_GRP.tbl_v30,
         source_line_id			WSH_BULK_TYPES_GRP.tbl_num,
         fm_serial_number		WSH_BULK_TYPES_GRP.tbl_v30,
         to_serial_number		WSH_BULK_TYPES_GRP.tbl_v30,
         transaction_interface_id	WSH_BULK_TYPES_GRP.tbl_num,
         attribute_category             WSH_BULK_TYPES_GRP.tbl_v30,
         attribute1                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute2                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute3                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute4                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute5                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute6                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute7                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute8                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute9                     WSH_BULK_TYPES_GRP.tbl_v150,
         attribute10                    WSH_BULK_TYPES_GRP.tbl_v150,
         attribute11                    WSH_BULK_TYPES_GRP.tbl_v150,
         attribute12                    WSH_BULK_TYPES_GRP.tbl_v150,
         attribute13                    WSH_BULK_TYPES_GRP.tbl_v150,
         attribute14                    WSH_BULK_TYPES_GRP.tbl_v150,
         attribute15                    WSH_BULK_TYPES_GRP.tbl_v150
         );

     --Roecode of table for mtl_transaction_lots_interface
     TYPE  Mtl_lot_txn_if_rec_type IS RECORD(
         source_code			WSH_BULK_TYPES_GRP.tbl_v30,
         source_line_id			WSH_BULK_TYPES_GRP.tbl_num,
-- HW OPMCONV. Make length of lot 80
         lot_number			WSH_BULK_TYPES_GRP.tbl_v80,
         trx_quantity			WSH_BULK_TYPES_GRP.tbl_num,
         transaction_interface_id	WSH_BULK_TYPES_GRP.tbl_num,
         serial_transaction_temp_id     WSH_BULK_TYPES_GRP.tbl_num,
-- HW OPMCONV. New variables
         secondary_trx_quantity         WSH_BULK_TYPES_GRP.tbl_num,
         grade_code                     WSH_BULK_TYPES_GRP.tbl_v150
         );

 -- HW OPMCONV. Removed parameters x_opm_org_exist
-- and x_non_opm_org_exist
-- HW BUG#:3999479- Need x_non_opm_org_exist
     PROCEDURE Interface_Detail_To_Inv(
        p_batch_id               IN              NUMBER,
        P_transaction_header_id IN              NUMBER,
--      x_opm_org_exist         OUT NOCOPY      BOOLEAN,
        x_non_opm_org_exist     OUT NOCOPY      BOOLEAN,
        x_return_status         OUT NOCOPY      VARCHAR2);

--HVOP:INV heali

--HVOP:OM heali
PROCEDURE Interface_Stop_To_OM(
  p_batch_id     IN NUMBER,
  x_return_status out NOCOPY  varchar2);

--HVOP:OM heali


--
--Procedure:        Interface_ALL_wrp
--Parameters:       errbuf
--                  retcode
--                  p_mode ('INV', 'OM DSNO', 'INV OM DSNO', etc.)
--                  p_stop_id
--                  p_delivery_id (supersedes p_stop_id)
--                  p_log_level
--                  p_organization_id
--                  p_num_requests  number of concurrent requests
--Description:      This is a wrapper to the original procedure interface_all
--                  and will allow the user to enter the organization_id
--                  and the number of the concurrent requests needed.

procedure interface_ALL_wrp(errbuf        OUT NOCOPY  VARCHAR2,
                        retcode       OUT NOCOPY  VARCHAR2,
                        p_mode        IN  VARCHAR2 DEFAULT 'ALL',
                        p_stop_id     IN  NUMBER   DEFAULT NULL,
                        p_delivery_id IN  NUMBER   DEFAULT NULL,
                        p_log_level   IN  NUMBER   DEFAULT 0,
                        p_batch_id IN NUMBER DEFAULT NULL,

                        p_trip_type IN VARCHAR2 DEFAULT NULL,
                        p_organization_id IN NUMBER DEFAULT NULL,
                        p_num_requests IN NUMBER DEFAULT NULL,
                        p_stops_per_batch IN NUMBER DEFAULT NULL);


--Standalone WMS project changes
--
--Procedure:        Process_Lines_To_OM
--Parameters:       line_id_tab             table of line_ids need to be interfaced
--                  x_return_status         return status of the API.
--
--Description:      This API is created to be called only from Standalone code
--                  API interfaces the lines passed to OM only if there are no
--                  unshipped wdd remaining for the order line.
--                  -If complete quantity is shipped then BUlk mode variable are popualted
--                  AND/OR
--                  -If line is shipped within tolerances then Non BUlk mode variable are
--                  popualted
--                  Based on Bulk and Non bulk varaiables OM API will be called in Bulk and
--	                Non Bulk mode.

PROCEDURE Process_lines_To_OM(p_line_id_tab IN wsh_util_core.id_Tab_type,
                                 x_return_status  OUT NOCOPY  VARCHAR2);


--Standalone WMS project changes
--
--Procedure:        Process_Delivery_To_OM
--Parameters:       delivery_id             Delivery_id need to be interfaced
--                  x_return_status         return status of the API.
--
--Description:      This API is created to be used only by Standalone code.
--                  API will interfaces the delivery passed to OM only if
--                  the delivery is completely shipped or shipped within tolerances.
--                  For tolerance case remaining delivery details will be cancelled


PROCEDURE Process_Delivery_To_OM (p_delivery_id IN  NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2);

--Standalone WMS project changes ,created new record
TYPE oe_interface_rec is RECORD (
      source_header_id          wsh_delivery_details.source_header_id%TYPE,
      source_header_number      wsh_delivery_details.source_header_number%TYPE,
      source_line_set_id        wsh_delivery_details.source_line_set_id%TYPE,
      source_line_id            wsh_delivery_details.source_line_id%TYPE,
      order_line_quantity          oe_order_lines_all.ordered_quantity%TYPE,
      requested_quantity_uom    wsh_delivery_details.requested_quantity_uom%TYPE,
      requested_quantity_uom2   wsh_delivery_details.requested_quantity_uom2%TYPE,
      ordered_quantity          oe_order_lines_all.ordered_quantity%TYPE,
      order_quantity_uom        oe_order_lines_all.order_quantity_uom%TYPE,
      ordered_quantity2         oe_order_lines_all.ordered_quantity2%TYPE,
      ordered_quantity_uom2     oe_order_lines_all.ordered_quantity_uom2%TYPE,
      model_remnant_flag        oe_order_lines_all.model_remnant_flag%TYPE,
      item_type_code            oe_order_lines_all.item_type_code%TYPE,
      calculate_price_flag      oe_order_lines_all.calculate_price_flag%TYPE,
      ship_tolerance_below      wsh_delivery_details.ship_tolerance_below%TYPE,
      ship_tolerance_above      wsh_delivery_details.ship_tolerance_above%TYPE,
      org_id                    oe_order_lines_all.org_id%TYPE,
      organization_id           wsh_delivery_details.organization_id%TYPE,
      oe_interfaced_flag        wsh_delivery_details.oe_interfaced_flag%TYPE,
      initial_pickup_date    wsh_new_deliveries.initial_pickup_date%TYPE,
      top_model_line_id         wsh_delivery_details.top_model_line_id%TYPE                                                                                                            ,
      ato_line_id               wsh_delivery_details.ato_line_id%TYPE,
      ship_set_id               wsh_delivery_details.ship_set_id%TYPE,
      ship_model_complete_flag  wsh_delivery_details.ship_model_complete_flag%TYPE,
      arrival_set_id            wsh_delivery_details.arrival_set_id%TYPE,
      inventory_item_id         wsh_delivery_details.inventory_item_id%TYPE,
      flow_status_code          oe_order_lines_all.flow_status_code%TYPE,
      total_requested_quantity        wsh_delivery_details.requested_quantity%TYPE,
      total_requested_quantity2       wsh_delivery_details.requested_quantity2%TYPE,
      total_shipped_quantity          wsh_delivery_details.shipped_quantity%TYPE,
      total_shipped_quantity2         wsh_delivery_details.shipped_quantity2%TYPE);



END WSH_SHIP_CONFIRM_ACTIONS;

/
