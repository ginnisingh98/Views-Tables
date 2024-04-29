--------------------------------------------------------
--  DDL for Package WMS_XDOCK_CUSTOM_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_XDOCK_CUSTOM_APIS_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSXDCAS.pls 120.2 2005/07/01 16:49:24 appldev noship $ */


-- Global constant indicating if we allow partial WIP crossdocking, i.e. if a demand
-- can be fulfilled through supplies of type WIP and other non-Inventory supply types.
-- This should only be used for OE demand lines.  WIP demand lines are backordered component
-- demand which we do not create crossdock reservations for.
g_allow_partial_wip_xdock       CONSTANT VARCHAR2(1) := 'N';


--      API Name    : Get_Crossdock_Criteria
--      Package     : WMS_XDOCK_CUSTOM_APIS_PUB
--      Description : This API is used to define a custom method of determining a valid
--                    crossdock criteria to return for a given WDD demand line during Planned
--                    Crossdocking.  This would be called in lieu of the rules engine in the pegging
--                    logic.  The output is expected to be a valid crossdock criteria ID of type
--                    'Planned'.  If the variable x_api_is_implemented is TRUE, then we will use
--                    the value in x_crossdock_criteria_id.  If this value is NULL, we assume that a
--                    crossdock criteria could not be determined and the WDD demand line will not be
--                    crossdocked.  If the variable x_api_is_implemented is FALSE, then the pegging
--                    logic will call the rules engine instead to determine a valid crossdock
--                    criteria.
--
--      Input parameters:
--       p_wdd_release_record       WDD demand line we are trying to determine a valid planned
--                                  crossdock criteria for.  The demand line record contains relevant
--                                  information such as org, item, customer ID, project, task, etc.
--
--      IN OUT parameters:
--
--      Output parameters:
--       x_return_status
--           if the Get_Planned_Crossdock_Criteria API succeeds, the value is
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
--       x_api_is_implemented
--           Indicates if the custom API is implemented or not (TRUE or FALSE BOOlEAN value)
--       x_crossdock_criteria_id
--           The output crossdock criteria ID of type 'Planned'.  If a NULL value is returned,
--           this means no valid crossdock criteria could be determined.  If a value of -1 is returned,
--           this will be interpreted as 'Not Implemented'.  The pegging logic will then call the rules
--           engine to determine a valid crossdock criteria instead.
--
PROCEDURE Get_Crossdock_Criteria
  (p_wdd_release_record         IN      WSH_PR_CRITERIA.relRecTyp,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_crossdock_criteria_id      OUT     NOCOPY NUMBER);


--      API Name    : Get_Expected_Time
--      Package     : WMS_XDOCK_CUSTOM_APIS_PUB
--      Description : This API is used to define a custom method of determining the expected receipt
--                    or ship time for a given Supply or Demand line used for crossdocking.
--                    This will be called from the crossdock pegging engine first.  If the API is not
--                    implemented, we will then call the default Get_Expected_Time API instead.
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
--       p_dock_schedule_method     Dock schedule method for the crossdock criterion (if value is passed).
--                                  This will correspond to either the supply_schedule_method or
--                                  demand_schedule_method depending on the line type (supply or demand).
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
--       x_api_is_implemented
--           Indicates if the custom API is implemented or not (TRUE or FALSE BOOlEAN value)
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
--           If a dock appointment exists but a crossdock criterion is not passed, this should have
--           a NULL value.
--
PROCEDURE Get_Expected_Time
  (p_source_type_id             IN      NUMBER,
   p_source_header_id           IN      NUMBER,
   p_source_line_id             IN      NUMBER,
   p_source_line_detail_id      IN      NUMBER,
   p_supply_or_demand           IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER,
   p_dock_schedule_method       IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_dock_start_time            OUT     NOCOPY DATE,
   x_dock_mean_time             OUT     NOCOPY DATE,
   x_dock_end_time              OUT     NOCOPY DATE,
   x_expected_time              OUT     NOCOPY DATE);


--      API Name    : Get_Expected_Delivery_Time
--      Package     : WMS_XDOCK_CUSTOM_APIS_PUB
--      Description : This API is used to define a custom method of determining the expected ship
--                    time for a given delivery.  This will be called from the crossdock pegging
--                    engine first.  It is used for opportunistic crossdocking when determining
--		      which deliveries unassigned pegged WDD lines can be merged with. If the API
--                    is not implemented, we will then call the default Get_Expected_Delivery_Time
--                    API instead.  Since shipping merges a line to a delivery without taking time
--		      into account (crossdock window), opportunistic crossdock will need to first
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
--       p_dock_schedule_method     Dock schedule method for the crossdock criterion.
--                                  This will correspond to the demand_schedule_method for the
--                                  crossdock criterion.
--
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
--       x_api_is_implemented
--           Indicates if the custom API is implemented or not (TRUE or FALSE BOOlEAN value)
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
   p_dock_schedule_method       IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_dock_appointment_id        OUT     NOCOPY NUMBER,
   x_dock_start_time            OUT     NOCOPY DATE,
   x_dock_end_time              OUT     NOCOPY DATE,
   x_expected_time              OUT     NOCOPY DATE);


--      API Name    : Sort_Supply_Lines
--      Package     : WMS_XDOCK_CUSTOM_APIS_PUB
--      Description : This API is used to sort an input table of valid supply lines for crossdocking.
--                    This is called for Planned Crossdocking if the crossdocking goal is 'Custom'.
--                    The input table contains supply lines that are all valid for crossdocking to the
--                    inputted demand.  The prioritize documents input comes from the crossdock criteria
--                    used and indicates if we should maintain the relative ordering of the supply source
--                    types in p_shopping_basket_tb.
--
--      Input parameters:
--       p_wdd_release_record       WDD demand line record we are trying to crossdock.
--       p_prioritize_documents     Flag indicating if the supply source documents should be
--                                  prioritized or not.  The possible values are:
--                                       1 = Yes
--                                       2 = No
--                                  If the documents are to be prioritized, the supply lines in
--                                  the input p_shopping_basket_tb will already be sorted by the
--                                  supply source types in the order they should be consumed.  In
--                                  this case, the custom API should sort the supply lines by the source
--                                  types to maintain the relative ordering of the supply documents.
--                                  For example, if the following are the supply lines returned in
--                                  p_shopping_basket_tb and p_prioritize_documents = 1 (Yes), the custom
--                                  API should first sort Supply Lines 1, 2, and 3 in one set.  Then
--                                  it should sort Supply Lines 4 and 5.
--                                     Supply Lines before sorting by custom API
--                                       Supply Line 1: PO1
--                                       Supply Line 2: PO2
--                                       Supply Line 3: PO3
--                                       Supply Line 4: ASN1
--                                       Supply Line 5: ASN2
--                                     Supply Lines after sorting by custom API.  (Note that the PO supply
--                                     lines all still come before the ASN ones).
--                                       Supply Line 1: PO3
--                                       Supply Line 2: PO1
--                                       Supply Line 3: PO2
--                                       Supply Line 4: ASN2
--                                       Supply Line 5: ASN1
--       p_shopping_basket_tb       Table of valid supply lines for crossdocking.  The supply lines
--                                  all lie within the crossdock window of the demand and are valid
--                                  source types for crossdocking.  The supply line records stored
--                                  in this table are the row records from the global temp table,
--                                  wms_xdock_pegging_gtmp.  They have the following data structure.
--                                       inventory_item_id           NUMBER
--                                       xdock_source_code           NUMBER,
--                                       source_type_id              NUMBER
--                                       source_header_id            NUMBER
--                                       source_line_id              NUMBER
--                                       source_line_detail_id       NUMBER
--                                       dock_start_time             DATE
--                                       dock_mean_time              DATE
--                                       dock_end_time               DATE
--                                       expected_time               DATE
--                                       quantity                    NUMBER
--                                       reservable_quantity         NUMBER
--                                       uom_code                    VARCHAR2(3)
--                                       project_id                  NUMBER
--                                       task_id                     NUMBER
--                                  Note that this table can be sparsely populated if an exception
--                                  occurs while calculating the available to reserve quantity for the
--                                  supply lines.
--
--      IN OUT parameters:
--
--      Output parameters:
--       x_return_status
--           if the Sort_Supply_Lines API succeeds, the value is
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
--       x_api_is_implemented
--           Indicates if the custom API is implemented or not (TRUE or FALSE BOOlEAN value)
--       x_sorted_order_tb
--           Output table that indicates what order the supply lines in p_shopping_basket_tb
--           are to be sorted.  This table should be indexed by consecutive integers starting
--           with 1, i.e. 1, 2, 3, 4, ...  The table entry with index 1 will contain the pointer
--           to the index value in p_shopping_basket_tb corresponding to the first supply line
--           record that should be consumed.  The same logic applies to index 2, 3, 4, ... in
--           x_sorted_order_tb.
--              For example:
--                 p_shopping_basket_tb(1) := SUPPLY1
--                 p_shopping_basket_tb(3) := SUPPLY2
--                 p_shopping_basket_tb(4) := SUPPLY3
--                 p_shopping_basket_tb(7) := SUPPLY9
--              We want to sort these supplies and consume in this order:
--                 SUPPLY3, SUPPLY1, SUPPLY9, SUPPLY2
--              The output x_sorted_order_tb should look like this:
--                 x_sorted_order_tb(1) := 4
--                 x_sorted_order_tb(2) := 1
--                 x_sorted_order_tb(3) := 7
--                 x_sorted_order_tb(4) := 3
--           If for some reason the custom logic does not want to use a supply line that exists
--           in p_shopping_basket_tb, just do not include that entry in x_sorted_order_tb.  This output
--           table can have less than or an equal amount of entries as p_shopping_basket_tb.  It can
--           never have more.  Additionally, (very important!!!) there should not be multiple entries
--           in x_sorted_order_tb pointing to the same index value.  If an invalid sorted order table
--           is returned, the custom logic will not be used to sort the shopping basket table.
PROCEDURE Sort_Supply_Lines
  (p_wdd_release_record         IN      WSH_PR_CRITERIA.relRecTyp,
   p_prioritize_documents       IN      NUMBER,
   p_shopping_basket_tb         IN      WMS_XDock_Pegging_Pub.shopping_basket_tb,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_sorted_order_tb            OUT     NOCOPY WMS_XDock_Pegging_Pub.sorted_order_tb);


--      API Name    : Sort_Demand_Lines
--      Package     : WMS_XDOCK_CUSTOM_APIS_PUB
--      Description : This API is used to sort an input table of valid demand lines for crossdocking.
--                    This is called for Opportunistic Crossdocking if the crossdocking goal is 'Custom'.
--                    The input table contains demand lines that are all valid for crossdocking to the
--                    inputted MOL supply.  The prioritize documents input comes from the crossdock criteria
--                    used and indicates if we should maintain the relative ordering of the demand source
--                    types in p_shopping_basket_tb.
--
--      Input parameters:
--       p_move_order_line_id       Move Order line ID for the supply we are trying to crossdock.
--       p_prioritize_documents     Flag indicating if the demand source documents should be
--                                  prioritized or not.  The possible values are:
--                                       1 = Yes
--                                       2 = No
--                                  If the documents are to be prioritized, the demand lines in
--                                  the input p_shopping_basket_tb will already be sorted by the
--                                  demand source types in the order they should be consumed.  In
--                                  this case, the custom API should sort the demand lines by the source
--                                  types to maintain the relative ordering of the demand documents.
--                                  For example, if the following are the demand lines returned in
--                                  p_shopping_basket_tb and p_prioritize_documents = 1 (Yes), the custom
--                                  API should first sort Demand Lines 1, 2, and 3 in one set.  Then
--                                  it should sort Demand Lines 4 and 5.
--                                     Demand Lines before sorting by custom API
--                                       Demand Line 1: Scheduled Sales Order1
--                                       Demand Line 2: Scheduled Sales Order2
--                                       Demand Line 3: Scheduled Sales Order3
--                                       Demand Line 4: Backordered Internal Order1
--                                       Demand Line 5: Backordered Internal Order2
--                                     Demand Lines after sorting by custom API.  (Note that the
--                                     Scheduled Sales Order demand lines all still come before the
--                                     Backordered Internal Order ones).
--                                       Demand Line 1: Scheduled Sales Order3
--                                       Demand Line 2: Scheduled Sales Order1
--                                       Demand Line 3: Scheduled Sales Order2
--                                       Demand Line 4: Backordered Internal Order2
--                                       Demand Line 5: Backordered Internal Order1
--       p_shopping_basket_tb       Table of valid demand lines for crossdocking.  The demand lines
--                                  all lie within the crossdock window of the demand and are valid
--                                  source types for crossdocking.  The demand line records stored
--                                  in this table are the row records from the global temp table,
--                                  wms_xdock_pegging_gtmp.  They have the following data structure.
--                                       inventory_item_id           NUMBER
--                                       xdock_source_code           NUMBER,
--                                       source_type_id              NUMBER
--                                       source_header_id            NUMBER
--                                       source_line_id              NUMBER
--                                       source_line_detail_id       NUMBER
--                                       dock_start_time             DATE
--                                       dock_mean_time              DATE
--                                       dock_end_time               DATE
--                                       expected_time               DATE
--                                       quantity                    NUMBER
--                                       reservable_quantity         NUMBER
--                                       uom_code                    VARCHAR2(3)
--                                       project_id                  NUMBER
--                                       task_id                     NUMBER
--                                  Note that this table can be sparsely populated if an exception
--                                  occurs while calculating the available to reserve quantity for the
--                                  demand lines.
--
--      IN OUT parameters:
--
--      Output parameters:
--       x_return_status
--           if the Sort_Demand_Lines API succeeds, the value is
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
--       x_api_is_implemented
--           Indicates if the custom API is implemented or not (TRUE or FALSE BOOlEAN value)
--       x_sorted_order_tb
--           Output table that indicates what order the demand lines in p_shopping_basket_tb
--           are to be sorted.  This table should be indexed by consecutive integers starting
--           with 1, i.e. 1, 2, 3, 4, ...  The table entry with index 1 will contain the pointer
--           to the index value in p_shopping_basket_tb corresponding to the first demand line
--           record that should be consumed.  The same logic applies to index 2, 3, 4, ... in
--           x_sorted_order_tb.
--              For example:
--                 p_shopping_basket_tb(1) := DEMAND1
--                 p_shopping_basket_tb(3) := DEMAND2
--                 p_shopping_basket_tb(4) := DEMAND3
--                 p_shopping_basket_tb(7) := DEMAND9
--              We want to sort these demands and consume in this order:
--                 DEMAND3, DEMAND1, DEMAND9, DEMAND2
--              The output x_sorted_order_tb should look like this:
--                 x_sorted_order_tb(1) := 4
--                 x_sorted_order_tb(2) := 1
--                 x_sorted_order_tb(3) := 7
--                 x_sorted_order_tb(4) := 3
--           If for some reason the custom logic does not want to use a demand line that exists
--           in p_shopping_basket_tb, just do not include that entry in x_sorted_order_tb.  This output
--           table can have less than or an equal amount of entries as p_shopping_basket_tb.  It can
--           never have more.  Additionally, (very important!!!) there should not be multiple entries
--           in x_sorted_order_tb pointing to the same index value.  If an invalid sorted order table
--           is returned, the custom logic will not be used to sort the shopping basket table.
PROCEDURE Sort_Demand_Lines
  (p_move_order_line_id         IN      NUMBER,
   p_prioritize_documents       IN      NUMBER,
   p_shopping_basket_tb         IN      WMS_XDock_Pegging_Pub.shopping_basket_tb,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_sorted_order_tb            OUT     NOCOPY WMS_XDock_Pegging_Pub.sorted_order_tb);


END WMS_XDOCK_CUSTOM_APIS_PUB;


 

/
