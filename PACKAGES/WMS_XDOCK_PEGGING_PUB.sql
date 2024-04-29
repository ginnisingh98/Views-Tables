--------------------------------------------------------
--  DDL for Package WMS_XDOCK_PEGGING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_XDOCK_PEGGING_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSXDCKS.pls 120.2.12010000.3 2009/08/13 09:16:45 ajunnikr ship $ */

-- Record to store a valid supply or demand line for planned or opportunistic crossdocking.
-- This corresponds to the ROWTYPE of the  global temp table, wms_xdock_pegging_gtmp
-- but also includes the ROWID column so the record can be updated easily later on
-- once retrieved.
TYPE shopping_basket_rec IS RECORD
  (ROWID                       urowid,
   inventory_item_id           NUMBER,
   xdock_source_code           NUMBER,
   source_type_id              NUMBER,
   source_header_id            NUMBER,
   source_line_id              NUMBER,
   source_line_detail_id       NUMBER,
   dock_start_time             DATE,
   dock_mean_time              DATE,
   dock_end_time               DATE,
   expected_time               DATE,
   quantity                    NUMBER,
   reservable_quantity         NUMBER,
   uom_code                    VARCHAR2(3),
   primary_quantity            NUMBER,
   secondary_quantity          NUMBER,
   secondary_uom_code          VARCHAR2(3),
   project_id                  NUMBER,
   task_id                     NUMBER,
   lpn_id                      NUMBER,
   wip_supply_type             NUMBER
   );

-- Table to store the valid supply or demand lines for planned or opportunistic crossdocking.
-- This type is defined in the specs so the custom logic package can reference it.
TYPE shopping_basket_tb IS TABLE OF shopping_basket_rec INDEX BY BINARY_INTEGER;

-- Table type used to store the sorted order of supply line records in the shopping basket
-- table when using custom logic.
TYPE sorted_order_tb IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


-- For Wave Planning -- > Crossdocking Simulation
l_split_flag varchar2(1) := 'N';

-- The following 4 functions are used to cache crossdock criteria records.  The caller can
-- Set, Get, Delete, or Clear the crossdock criteria cache.

-- This function will store the crossdock criteria record inputted into the cache
FUNCTION set_crossdock_criteria
  (p_criterion_id IN NUMBER) RETURN BOOLEAN;

-- This function will retrieve the crossdock criteria record inputted from the cache
FUNCTION get_crossdock_criteria
  (p_criterion_id IN NUMBER) RETURN wms_crossdock_criteria%ROWTYPE;

-- This function will delete the crossdock criteria record inputted from the cache
FUNCTION delete_crossdock_criteria
  (p_criterion_id IN NUMBER) RETURN BOOLEAN;

-- This function will clear all of the crossdock criteria records stored in the cache
FUNCTION clear_crossdock_cache RETURN BOOLEAN;


-- This is a function used to retrieve the default routing ID given an item, org,
-- and vendor as inputs.  This function will use the same logic as the get_defaul_routing_id
-- in the INV_RCV_COMMON_APIS package.  However we will cache all of the values retrieved
-- for performance.  The order to search for a default routing ID is: item, vendor, org.
-- The org and item should always be inputted and be non-null.
FUNCTION get_default_routing_id
  (p_organization_id   IN  NUMBER,
   p_item_id           IN  NUMBER,
   p_vendor_id         IN  NUMBER
   ) RETURN NUMBER DETERMINISTIC;


--      API Name    : Planned_Cross_Dock
--      Package     : WMS_XDock_Pegging_Pub
--      Description : This API will perform crossdock pegging to fulfill demand lines during
--                    Pick Release.  This procedure will be called from WSH_PICK_LIST.Release_Batch
--                    (For 'Crossdock Only' or 'Prioritize Crossdock' allocation modes) and
--                    INV_Pick_Release_Pub.Pick_Release (for 'Prioritize Inventory' allocation mode).
--                    The main input is p_wsh_release_table which is a table of valid WDD lines to
--                    allocate material against.  This API will loop through each WDD line and try to find
--                    valid supply lines to fulfill it.  If a WDD line is satisfied through crossdock,
--                    the released_status on p_wsh_release_table and also the database table
--                    WSH_DELIVERY_DETAILS will be updated to 'S' (Released to Warehouse).
--                    p_trolin_delivery_ids and p_del_detail_id must be kept in sync with each other.
--                    Those two tables are needed if we split WDD lines since shipping would not have
--                    visibility to the new WDD lines.
--
--      Input parameters:
--       p_api_version		    API Version (Should always be 1.0)
--       p_init_msg_list	    Initialize Message List (Shipping should pass FALSE)
--       p_commit		    Commit (Shipping should always pass FALSE)
--       p_batch_id                 Batch ID for the pick release batch.  This corresponds to the table
--                                  WSH_PICKING_BATCHES which will contain all of the information we
--                                  need.  This includes, org, allocation mode, crossdock criterion ID
--                                  and existing reservations only flag.
--
--      IN OUT parameters:
--       p_wsh_release_table        Table of valid demand lines to pick release against.
--                                  Assume that all WDD records are for the same org, p_organization_id.
--                                  API will only process WDD lines with released_status of
--                                  'R' (Ready to Release) or 'B' (Backordered).
--                                  Shipping should pass in WSH_PR_CRITERIA.release_table in the
--                                  WSH_PICK_LIST.Release_Batch API when pick release is run.
--       p_trolin_delivery_ids      Table of delivery IDs for transactable demand lines.
--                                  Crossdocked lines needs to keep this table updated so crossdocked
--                                  or split WDD lines can be picked up to autocreate/merge deliveries.
--                                  Shipping should pass in local variable 'l_trolin_delivery_ids' from
--                                  the Release_Batch API.  This table has a one to one relationship
--                                  with p_del_detail_id and stores the delivery_id for the corresponding
--                                  delivery_detail_id in p_del_detail_id.
--       p_del_detail_id            Table of delivery detail IDs for transactable demand lines.
--                                  Crossdocked lines needs to keep this table updated so crossdocked
--                                  or split WDD lines can be picked up to autocreate/merge deliveries.
--                                  Shipping should pass in local variable 'l_del_detail_id' from
--                                  the Release_Batch API.  This table has a one to one relationship
--                                  with p_trolin_delivery_ids and stores a list of delivery_detail_id
--                                  values for all of the transactable WDD lines in p_wsh_release_table.
--
--      Output parameters:
--       x_return_status
--           if the Planned_Cross_Dock API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--


PROCEDURE Planned_Cross_Dock
  (p_api_version		IN  	NUMBER,
   p_init_msg_list	        IN  	VARCHAR2,
   p_commit		        IN	VARCHAR2,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   p_batch_id                   IN      NUMBER,
   p_wsh_release_table          IN OUT  NOCOPY WSH_PR_CRITERIA.relRecTabTyp,
   p_trolin_delivery_ids        IN OUT  NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
   p_del_detail_id              IN OUT  NOCOPY WSH_PICK_LIST.DelDetTabTyp,
   p_simulation_mode in varchar2 default 'N');


--      API Name    : Opportunistic_Cross_Dock
--      Package     : WMS_XDock_Pegging_Pub
--      Description : This API will perform opportunistic crossdock pegging to fulfill a move order
--                    line supply that has been received.  It will find valid demand lines to peg this
--                    supply to.  The splitting of WDD lines, creation and splitting of reservations,
--                    splitting and updating of MOL will all be done in this API.  It will first try to
--                    satisfy any high level receiving reservations for the same org/item.  Then it will
--                    use the demand sources as listed in the crossdock criterion passed.  Note that if the
--                    move order line does not have a crossdock criterion ID stamped on it, we will not
--                    try to peg demand lines to it.  This should not occur since there is a default
--                    crossdock rule at the org level.
--
--      Input parameters:
--       p_organization_id          Organization ID where MOL is received
--       p_move_order_line_id       MOL supply line for which we are trying to find demand lines to peg to.
--       p_crossdock_criterion_id   Crossdock criterion ID.  This will determine what is valid for pegging
--			            and should always be passed.
--
--      IN OUT parameters:
--
--      Output parameters:
--       x_return_status
--           if the Opportunistic_Cross_Dock API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--
PROCEDURE Opportunistic_Cross_Dock
  (p_organization_id            IN      NUMBER,
   p_move_order_line_id         IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2);


--      API Name    : Get_Expected_Time
--      Package     : WMS_XDock_Pegging_Pub
--      Description : This API will calculate the expected receipt or ship time for a given
--                    Supply or Demand line used for crossdocking.  This will be called from the
--                    crossdock pegging engine and the concurrent exception program to recalculate
--                    the expected receipt and ship times for crossdocked reservations.
--
--      Input parameters:
--       p_source_type_id           Source type of supply or demand line.  This corresponds to the
--                                  lookup 'Reservation_Types' used by reservations.  e.g. 1 = PO,
--                                  2 = Sales Order, 5 = WIP, 7 = Internal Req, 8 = Internal Order, etc.
--       p_source_header_id         Source Header ID such as PO Header ID, RCV Shipment Header ID,
--                                  OE Order Header ID, etc.  This corresponds to what reservations
--                                  inserts for various supply or demand types.
--       p_source_line_id           Source Line ID such as PO Line Location ID, RCV Shipment Line ID,
--                                  OE Order Line ID, etc.  This corresponds to what reservations
--                                  inserts for various supply or demand types.
--       p_source_line_detail_id    Source Line Detail ID such as Delivery Detail ID. This corresponds
--                                  to what reservations inserts for various supply or demand types.
--       p_supply_or_demand         Line type (Supply or Demand) you want to get the expected receipt or
--                                  ship time for: 1 = Supply
--                                                 2 = Demand
--                                  This variable might be needed since WIP type reservations use the
--                                  same source type code for WIP as a supply AND demand (backordered
--                                  component demand)
--       p_crossdock_criterion_id   Crossdock criterion ID if available.  This will determine how to
--                                  calculate the expected receipt or ship time in case a dock appointment
--                                  exists.  Dock appointments are an interval with a start and
--                                  end time so it is possible to use the begin, mean, or end time.
--
--      IN OUT parameters:
--
--      Output parameters:
--       x_return_status
--           if the Get_Expected_Time API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--       x_dock_start_time
--           The dock appointment start time (if it exists)
--       x_dock_mean_time
--           The dock appointment mean time (if it exists)
--       x_dock_end_time
--           The dock appointment end time (if it exists)
--       x_expected_time
--           The expected receipt or ship time for the line.  If the crossdock criterion is passed
--           and a dock appointment exists, we will calculate the expected time based on the dock
--           start and end time using the supply_schedule_method or demand_schedule_method.
--
PROCEDURE Get_Expected_Time
  (p_source_type_id             IN      NUMBER,
   p_source_header_id           IN      NUMBER,
   p_source_line_id             IN      NUMBER,
   p_source_line_detail_id      IN      NUMBER := NULL,
   p_supply_or_demand           IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER := NULL,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_dock_start_time            OUT     NOCOPY DATE,
   x_dock_mean_time             OUT     NOCOPY DATE,
   x_dock_end_time              OUT     NOCOPY DATE,
   x_expected_time              OUT     NOCOPY DATE);


--      API Name    : Get_Expected_Delivery_Time
--      Package     : WMS_XDock_Pegging_Pub
--      Description : This API will calculate the expected ship time for a given delivery.
--		      This will be called from opportunistic crossdocking when determining
--		      which deliveries unassigned pegged WDD lines can be merged with.
--		      Since shipping merges a line to a delivery without taking time into
--		      account (crossdock window), opportunistic crossdock will need to first
--		      get a list of valid deliveries we can merge to.  Then for each
--		      delivery, find the expected ship time so we merge only to deliveries
--		      within the crossdock window.  If none of the deliveries fall within
--		      the crossdock window, we will need to create a new delivery.
--
--      Input parameters:
--       p_delivery_id              Delivery ID we are trying to find the expected ship time for.
--       p_crossdock_criterion_id   Crossdock criterion ID.  This will determine how to calculate
--			            the expected ship time in case a dock appointment exists.
--				    Dock appointments are an interval with a start and end time, so
--				    so it is possible to use the start, mean, or end time for the
--				    expected ship time.  In case multiple dock appointments exist,
--				    this will also let us evaluate a dock appointment as a single
--				    time so we can find the closest appointment to the WDD lines
--				    assigned to the delivery.

--      IN OUT parameters:
--
--      Output parameters:
--       x_return_status
--           if the Get_Expected_Delivery_Time API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--       x_dock_appointment_id
--           If a dock appointment exists, this corresponds to the dock appointment ID.
--       x_dock_start_time
--           The dock appointment start time (if it exists).  If a dock appointment is not found
--           for the delivery and the trip stop does not have a departure date, this output
--	     parameter will correspond to the minimum of the expected ship date for the WDD records
--           tied to the delivery.
--       x_dock_end_time
--           The dock appointment end time (if it exists).  If a dock appointment is not found
--           for the delivery and the trip stop does not have a departure date, this output
--	     parameter will correspond to the maximum of the expected ship date for the WDD records
--	     tied to the delivery.
--       x_expected_time
--           The expected ship time for the delivery.  If the crossdock criterion is passed and a
--	     dock appointment exists, we will calculate the expected ship time based on the dock
--	     start and end time using the demand_schedule_method.  In this case, the dock appointment
--	     output parameters will also be populated.  If a dock appointment is not found and the
--	     trip stop does not have a departure date, this parameter will be NULL.
--
PROCEDURE Get_Expected_Delivery_Time
  (p_delivery_id                IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_dock_appointment_id        OUT     NOCOPY NUMBER,
   x_dock_start_time            OUT     NOCOPY DATE,
   x_dock_end_time              OUT     NOCOPY DATE,
   x_expected_time              OUT     NOCOPY DATE);


END WMS_XDock_Pegging_Pub;


/
